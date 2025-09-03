const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const mysql = require('mysql2/promise');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*", // Configure for your domain
    methods: ["GET", "POST"]
  }
});

app.use(cors());
app.use(express.json());

// Database connection (match your Sngine config)
const dbConfig = {
  host: 'localhost',
  user: 'your_db_user',
  password: 'your_db_password',
  database: 'your_sngine_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

const pool = mysql.createPool(dbConfig);

// JWT Secret (should match your Sngine secret)
const JWT_SECRET = 'your-jwt-secret';

// Connected users map
const connectedUsers = new Map();

// Socket.io connection handling
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // Authenticate user
  socket.on('authenticate', async (data) => {
    try {
      const { userId, accessToken } = data;
      
      // Verify user with Sngine database
      const [rows] = await pool.execute(
        'SELECT user_id, user_name, user_picture FROM users WHERE user_id = ? AND user_activated = 1',
        [userId]
      );
      
      if (rows.length > 0) {
        const user = rows[0];
        socket.userId = user.user_id;
        socket.userData = user;
        
        // Add to connected users
        connectedUsers.set(user.user_id, {
          socketId: socket.id,
          userData: user,
          lastSeen: new Date()
        });
        
        // Join user-specific room
        socket.join(`user_${user.user_id}`);
        
        // Update user online status in database
        await pool.execute(
          'UPDATE users SET user_last_seen = NOW() WHERE user_id = ?',
          [user.user_id]
        );
        
        socket.emit('authenticated', { success: true, user });
        
        // Notify friends that user is online
        await notifyFriendsOnlineStatus(user.user_id, true);
        
        console.log(`User ${user.user_name} authenticated`);
      } else {
        socket.emit('authenticated', { success: false, error: 'Invalid user' });
      }
    } catch (error) {
      console.error('Authentication error:', error);
      socket.emit('authenticated', { success: false, error: 'Authentication failed' });
    }
  });

  // Handle new messages
  socket.on('send_message', async (data) => {
    if (!socket.userId) return;
    
    try {
      const { conversationId, message, messageType = 'text' } = data;
      
      // Insert message into database
      const [result] = await pool.execute(
        'INSERT INTO conversations_messages (conversation_id, user_id, message, message_type, time) VALUES (?, ?, ?, ?, NOW())',
        [conversationId, socket.userId, message, messageType]
      );
      
      const messageId = result.insertId;
      
      // Get conversation participants
      const [participants] = await pool.execute(
        'SELECT user_one_id, user_two_id FROM conversations WHERE conversation_id = ?',
        [conversationId]
      );
      
      if (participants.length > 0) {
        const { user_one_id, user_two_id } = participants[0];
        const recipientId = user_one_id === socket.userId ? user_two_id : user_one_id;
        
        // Prepare message data
        const messageData = {
          message_id: messageId,
          conversation_id: conversationId,
          user_id: socket.userId,
          message: message,
          message_type: messageType,
          time: new Date().toISOString(),
          sender: socket.userData
        };
        
        // Send to recipient if online
        io.to(`user_${recipientId}`).emit('new_message', messageData);
        
        // Send confirmation to sender
        socket.emit('message_sent', { messageId, ...messageData });
        
        // Update conversation last message
        await pool.execute(
          'UPDATE conversations SET last_message_id = ?, last_message_time = NOW() WHERE conversation_id = ?',
          [messageId, conversationId]
        );
      }
    } catch (error) {
      console.error('Send message error:', error);
      socket.emit('message_error', { error: 'Failed to send message' });
    }
  });

  // Handle typing indicators
  socket.on('typing_start', (data) => {
    if (!socket.userId) return;
    
    const { conversationId, recipientId } = data;
    io.to(`user_${recipientId}`).emit('user_typing', {
      conversationId,
      userId: socket.userId,
      userData: socket.userData,
      typing: true
    });
  });

  socket.on('typing_stop', (data) => {
    if (!socket.userId) return;
    
    const { conversationId, recipientId } = data;
    io.to(`user_${recipientId}`).emit('user_typing', {
      conversationId,
      userId: socket.userId,
      typing: false
    });
  });

  // Handle post reactions in real-time
  socket.on('post_reaction', async (data) => {
    if (!socket.userId) return;
    
    try {
      const { postId, reaction, action } = data; // action: 'add' or 'remove'
      
      // Get post author
      const [postRows] = await pool.execute(
        'SELECT user_id FROM posts WHERE post_id = ?',
        [postId]
      );
      
      if (postRows.length > 0) {
        const postAuthorId = postRows[0].user_id;
        
        // Notify post author if different user
        if (postAuthorId !== socket.userId) {
          io.to(`user_${postAuthorId}`).emit('post_reaction', {
            postId,
            reaction,
            action,
            userId: socket.userId,
            userData: socket.userData
          });
        }
        
        // Broadcast to all users viewing this post
        io.emit('post_reaction_update', {
          postId,
          reaction,
          action,
          userId: socket.userId
        });
      }
    } catch (error) {
      console.error('Post reaction error:', error);
    }
  });

  // Handle new notifications
  socket.on('send_notification', async (data) => {
    if (!socket.userId) return;
    
    try {
      const { toUserId, type, message, relatedId } = data;
      
      // Insert notification into database
      const [result] = await pool.execute(
        'INSERT INTO notifications (to_user_id, from_user_id, action, node_type, node_id, time) VALUES (?, ?, ?, ?, ?, NOW())',
        [toUserId, socket.userId, message, type, relatedId]
      );
      
      // Send real-time notification
      io.to(`user_${toUserId}`).emit('new_notification', {
        notification_id: result.insertId,
        from_user: socket.userData,
        type,
        message,
        time: new Date().toISOString()
      });
    } catch (error) {
      console.error('Notification error:', error);
    }
  });

  // Handle disconnect
  socket.on('disconnect', async () => {
    if (socket.userId) {
      // Remove from connected users
      connectedUsers.delete(socket.userId);
      
      // Update last seen in database
      await pool.execute(
        'UPDATE users SET user_last_seen = NOW() WHERE user_id = ?',
        [socket.userId]
      );
      
      // Notify friends that user is offline
      await notifyFriendsOnlineStatus(socket.userId, false);
      
      console.log(`User ${socket.userData?.user_name} disconnected`);
    }
  });
});

// Helper function to notify friends about online status
async function notifyFriendsOnlineStatus(userId, isOnline) {
  try {
    const [friends] = await pool.execute(
      'SELECT user_two_id as friend_id FROM friends WHERE user_one_id = ? AND status = 1 UNION SELECT user_one_id as friend_id FROM friends WHERE user_two_id = ? AND status = 1',
      [userId, userId]
    );
    
    friends.forEach(friend => {
      io.to(`user_${friend.friend_id}`).emit('friend_status', {
        userId,
        isOnline,
        lastSeen: new Date().toISOString()
      });
    });
  } catch (error) {
    console.error('Error notifying friends:', error);
  }
}

// API endpoint for Sngine to trigger notifications
app.post('/api/notify', async (req, res) => {
  try {
    const { userId, type, data } = req.body;
    
    if (connectedUsers.has(userId)) {
      io.to(`user_${userId}`).emit(type, data);
      res.json({ success: true, delivered: true });
    } else {
      res.json({ success: true, delivered: false, reason: 'User offline' });
    }
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    connectedUsers: connectedUsers.size,
    timestamp: new Date().toISOString()
  });
});

const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log(`Sngine Socket.io server running on port ${PORT}`);
  console.log(`Connected users will be tracked in real-time`);
});

module.exports = { io, connectedUsers };