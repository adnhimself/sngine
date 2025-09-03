/**
 * Sngine Socket.io Integration Script
 * Add this to your Sngine theme to replace polling with real-time Socket.io
 */

// Socket.io client integration for Sngine
class SngineSocketClient {
  constructor(socketUrl) {
    this.socket = null;
    this.socketUrl = socketUrl;
    this.isConnected = false;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.heartbeatInterval = null;
    
    this.init();
  }

  init() {
    // Load Socket.io client
    if (typeof io === 'undefined') {
      const script = document.createElement('script');
      script.src = 'https://cdn.socket.io/4.7.4/socket.io.min.js';
      script.onload = () => this.connect();
      document.head.appendChild(script);
    } else {
      this.connect();
    }
  }

  connect() {
    this.socket = io(this.socketUrl, {
      transports: ['websocket', 'polling'],
      upgrade: true,
      rememberUpgrade: true
    });

    // Authentication
    this.socket.on('connect', () => {
      console.log('Connected to Sngine Socket server');
      this.isConnected = true;
      this.reconnectAttempts = 0;
      
      // Authenticate with user data
      if (typeof user_id !== 'undefined') {
        this.socket.emit('authenticate', {
          userId: user_id,
          accessToken: this.getAccessToken()
        });
      }
      
      // Stop the old polling heartbeat
      this.stopPollingHeartbeat();
    });

    this.socket.on('authenticated', (data) => {
      if (data.success) {
        console.log('Authenticated with Socket server');
        this.setupEventHandlers();
      } else {
        console.error('Authentication failed:', data.error);
      }
    });

    this.socket.on('disconnect', () => {
      console.log('Disconnected from Socket server');
      this.isConnected = false;
      
      // Fallback to polling if socket fails
      this.startPollingHeartbeat();
    });

    this.socket.on('connect_error', (error) => {
      console.error('Socket connection error:', error);
      this.handleReconnection();
    });
  }

  setupEventHandlers() {
    // Real-time messages
    this.socket.on('new_message', (data) => {
      this.handleNewMessage(data);
    });

    this.socket.on('user_typing', (data) => {
      this.handleTypingIndicator(data);
    });

    // Real-time notifications
    this.socket.on('new_notification', (data) => {
      this.handleNewNotification(data);
    });

    // Real-time post reactions
    this.socket.on('post_reaction', (data) => {
      this.handlePostReaction(data);
    });

    this.socket.on('post_reaction_update', (data) => {
      this.updatePostReactionCount(data);
    });

    // Friend online status
    this.socket.on('friend_status', (data) => {
      this.handleFriendStatus(data);
    });

    // Live streaming events
    this.socket.on('live_viewer_joined', (data) => {
      this.handleLiveViewerJoined(data);
    });

    this.socket.on('live_comment', (data) => {
      this.handleLiveComment(data);
    });
  }

  // Message handling
  handleNewMessage(data) {
    const { conversation_id, message, sender } = data;
    
    // Update chat interface
    if (typeof update_chat_conversation === 'function') {
      update_chat_conversation(conversation_id, data);
    }
    
    // Show notification if not in chat
    if (current_page !== 'messages') {
      this.showMessageNotification(sender.user_name, message);
    }
    
    // Update unread count
    this.updateUnreadCount();
  }

  handleTypingIndicator(data) {
    const { conversationId, userId, typing } = data;
    
    // Show/hide typing indicator in chat
    const chatBox = document.querySelector(`[data-conversation="${conversationId}"]`);
    if (chatBox) {
      const typingIndicator = chatBox.querySelector('.typing-indicator');
      if (typing) {
        if (!typingIndicator) {
          this.showTypingIndicator(chatBox, data.userData.user_name);
        }
      } else {
        if (typingIndicator) {
          typingIndicator.remove();
        }
      }
    }
  }

  // Notification handling
  handleNewNotification(data) {
    // Update notification count
    this.updateNotificationCount();
    
    // Show browser notification if enabled
    if (browser_notifications_enabled && 'Notification' in window) {
      new Notification(data.message, {
        icon: data.from_user.user_picture || '/content/themes/default/images/blank_profile_male.png',
        tag: 'sngine-notification'
      });
    }
    
    // Update notifications dropdown
    this.updateNotificationsDropdown(data);
  }

  // Post reaction handling
  handlePostReaction(data) {
    const { postId, reaction, userId, userData } = data;
    
    // Show notification to post author
    if (notifications_sound && typeof Audio !== 'undefined') {
      const audio = new Audio('/content/themes/default/sounds/notification.mp3');
      audio.play().catch(() => {}); // Ignore autoplay restrictions
    }
  }

  updatePostReactionCount(data) {
    const { postId, reaction, action } = data;
    const postElement = document.querySelector(`[data-post-id="${postId}"]`);
    
    if (postElement) {
      const reactionButton = postElement.querySelector(`[data-reaction="${reaction}"]`);
      if (reactionButton) {
        const countElement = reactionButton.querySelector('.reaction-count');
        if (countElement) {
          let count = parseInt(countElement.textContent) || 0;
          count = action === 'add' ? count + 1 : Math.max(0, count - 1);
          countElement.textContent = count;
        }
      }
    }
  }

  // Friend status handling
  handleFriendStatus(data) {
    const { userId, isOnline } = data;
    const friendElement = document.querySelector(`[data-user-id="${userId}"]`);
    
    if (friendElement) {
      const statusIndicator = friendElement.querySelector('.online-status');
      if (statusIndicator) {
        statusIndicator.classList.toggle('online', isOnline);
        statusIndicator.classList.toggle('offline', !isOnline);
      }
    }
  }

  // Send message through socket
  sendMessage(conversationId, message, messageType = 'text') {
    if (this.isConnected) {
      this.socket.emit('send_message', {
        conversationId,
        message,
        messageType
      });
    } else {
      // Fallback to AJAX
      this.sendMessageAjax(conversationId, message, messageType);
    }
  }

  // Send typing indicator
  sendTyping(conversationId, recipientId, isTyping) {
    if (this.isConnected) {
      this.socket.emit(isTyping ? 'typing_start' : 'typing_stop', {
        conversationId,
        recipientId
      });
    }
  }

  // Send post reaction
  sendPostReaction(postId, reaction, action) {
    if (this.isConnected) {
      this.socket.emit('post_reaction', {
        postId,
        reaction,
        action
      });
    }
  }

  // Utility methods
  getAccessToken() {
    // Get access token from localStorage or cookies
    return localStorage.getItem('access_token') || 
           this.getCookie('access_token') || 
           'default-token';
  }

  getCookie(name) {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop().split(';').shift();
    return null;
  }

  stopPollingHeartbeat() {
    // Stop Sngine's original polling
    if (typeof ticker !== 'undefined') {
      clearInterval(ticker);
      console.log('Stopped polling heartbeat - using Socket.io instead');
    }
  }

  startPollingHeartbeat() {
    // Restart polling as fallback
    if (typeof min_data_heartbeat !== 'undefined') {
      ticker = setInterval(() => {
        // Original Sngine heartbeat logic
        heartbeat();
      }, min_data_heartbeat);
      console.log('Started polling heartbeat as fallback');
    }
  }

  handleReconnection() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      setTimeout(() => {
        console.log(`Reconnection attempt ${this.reconnectAttempts}`);
        this.connect();
      }, Math.pow(2, this.reconnectAttempts) * 1000);
    } else {
      console.log('Max reconnection attempts reached, falling back to polling');
      this.startPollingHeartbeat();
    }
  }

  showMessageNotification(senderName, message) {
    // Show in-app notification
    if (typeof show_notification === 'function') {
      show_notification('info', `${senderName}: ${message.substring(0, 50)}...`);
    }
  }

  updateUnreadCount() {
    // Update message count in header
    const messageCount = document.querySelector('.messages-counter');
    if (messageCount) {
      let count = parseInt(messageCount.textContent) || 0;
      messageCount.textContent = count + 1;
      messageCount.style.display = 'block';
    }
  }

  updateNotificationCount() {
    // Update notification count in header
    const notificationCount = document.querySelector('.notifications-counter');
    if (notificationCount) {
      let count = parseInt(notificationCount.textContent) || 0;
      notificationCount.textContent = count + 1;
      notificationCount.style.display = 'block';
    }
  }

  showTypingIndicator(chatBox, userName) {
    const indicator = document.createElement('div');
    indicator.className = 'typing-indicator';
    indicator.innerHTML = `<span>${userName} is typing...</span>`;
    chatBox.appendChild(indicator);
    
    // Auto-remove after 3 seconds
    setTimeout(() => {
      if (indicator.parentNode) {
        indicator.remove();
      }
    }, 3000);
  }

  // Fallback AJAX methods
  sendMessageAjax(conversationId, message, messageType) {
    // Use existing Sngine AJAX for fallback
    $.post(ajax_path + 'chat/send.php', {
      conversation_id: conversationId,
      message: message,
      message_type: messageType
    });
  }
}

// Initialize Socket client when page loads
document.addEventListener('DOMContentLoaded', function() {
  // Only initialize if user is logged in
  if (typeof user_id !== 'undefined' && user_id) {
    window.sngineSocket = new SngineSocketClient('ws://localhost:3001');
    
    // Replace original message sending
    if (typeof send_message === 'function') {
      const originalSendMessage = send_message;
      send_message = function(conversationId, message, messageType) {
        if (window.sngineSocket && window.sngineSocket.isConnected) {
          window.sngineSocket.sendMessage(conversationId, message, messageType);
        } else {
          originalSendMessage(conversationId, message, messageType);
        }
      };
    }
  }
});

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
  module.exports = SngineSocketClient;
}