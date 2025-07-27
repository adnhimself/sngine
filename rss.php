<?php

/**
 * RSS Feed Generator
 * 
 * @package Sngine
 * @author Custom RSS Implementation
 */

// fetch bootloader
require('bootloader.php');

// Set content type for RSS
header('Content-Type: application/rss+xml; charset=UTF-8');

try {
    // Get parameters
    $feed_type = isset($_GET['type']) ? $_GET['type'] : 'blogs'; // 'blogs' or 'posts'
    $user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
    $limit = isset($_GET['limit']) ? min((int)$_GET['limit'], 50) : 20; // Max 50 items
    
    // Initialize RSS XML
    $rss = new SimpleXMLElement('<?xml version="1.0" encoding="UTF-8"?><rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:atom="http://www.w3.org/2005/Atom"></rss>');
    
    $channel = $rss->addChild('channel');
    
    // Add atom:link for self-reference (RSS best practice)
    $atom_link = $channel->addChild('atom:link', '', 'http://www.w3.org/2005/Atom');
    $atom_link->addAttribute('href', $system['system_url'] . '/rss.php?type=' . $feed_type . ($user_id ? '&user_id=' . $user_id : ''));
    $atom_link->addAttribute('rel', 'self');
    $atom_link->addAttribute('type', 'application/rss+xml');
    
    if ($feed_type === 'blogs') {
        // RSS for Blog Posts
        $channel->addChild('title', htmlspecialchars($system['system_title'] . ' - Blog Posts' . ($user_id ? ' by User ID: ' . $user_id : '')));
        $channel->addChild('description', htmlspecialchars($system['system_description_blogs'] ?: 'Latest blog posts from ' . $system['system_title']));
        $channel->addChild('link', $system['system_url'] . '/blogs');
        
        // Get blog posts
        $where_conditions = ["posts.post_type = 'article'", "posts.in_group = '0'", "posts.in_event = '0'", "(posts.pre_approved = '1' OR posts.has_approved = '1')"];
        
        if ($user_id) {
            $where_conditions[] = "posts.user_id = " . secure($user_id, 'int');
        }
        
        // Only get public posts for RSS
        $where_conditions[] = "posts.privacy = 'public'";
        
        $where_clause = "WHERE " . implode(" AND ", $where_conditions);
        
        $query = "SELECT 
            posts.post_id, 
            posts.user_id, 
            posts.user_type, 
            posts.time, 
            posts.text as post_text,
            posts_articles.title, 
            posts_articles.text, 
            posts_articles.cover, 
            posts_articles.tags,
            blogs_categories.category_name,
            CASE 
                WHEN posts.user_type = 'user' THEN CONCAT(users.user_firstname, ' ', users.user_lastname)
                WHEN posts.user_type = 'page' THEN pages.page_title
                ELSE 'Unknown'
            END as author_name,
            CASE 
                WHEN posts.user_type = 'user' THEN users.user_name
                WHEN posts.user_type = 'page' THEN pages.page_name
                ELSE NULL
            END as author_username
        FROM posts 
        INNER JOIN posts_articles ON posts.post_id = posts_articles.post_id 
        LEFT JOIN blogs_categories ON posts_articles.category_id = blogs_categories.category_id
        LEFT JOIN users ON posts.user_type = 'user' AND posts.user_id = users.user_id AND users.user_banned = '0'
        LEFT JOIN pages ON posts.user_type = 'page' AND posts.user_id = pages.page_id
        $where_clause
        ORDER BY posts.post_id DESC 
        LIMIT $limit";
        
    } else {
        // RSS for Regular Posts
        $channel->addChild('title', htmlspecialchars($system['system_title'] . ' - Posts' . ($user_id ? ' by User ID: ' . $user_id : '')));
        $channel->addChild('description', htmlspecialchars('Latest posts from ' . $system['system_title']));
        $channel->addChild('link', $system['system_url']);
        
        // Get regular posts (excluding articles/blogs)
        $where_conditions = ["posts.post_type != 'article'", "posts.in_group = '0'", "posts.in_event = '0'", "(posts.pre_approved = '1' OR posts.has_approved = '1')"];
        
        if ($user_id) {
            $where_conditions[] = "posts.user_id = " . secure($user_id, 'int');
        }
        
        // Only get public posts for RSS
        $where_conditions[] = "posts.privacy = 'public'";
        
        $where_clause = "WHERE " . implode(" AND ", $where_conditions);
        
        $query = "SELECT 
            posts.post_id, 
            posts.user_id, 
            posts.user_type, 
            posts.post_type,
            posts.time, 
            posts.text,
            CASE 
                WHEN posts.user_type = 'user' THEN CONCAT(users.user_firstname, ' ', users.user_lastname)
                WHEN posts.user_type = 'page' THEN pages.page_title
                ELSE 'Unknown'
            END as author_name,
            CASE 
                WHEN posts.user_type = 'user' THEN users.user_name
                WHEN posts.user_type = 'page' THEN pages.page_name
                ELSE NULL
            END as author_username
        FROM posts 
        LEFT JOIN users ON posts.user_type = 'user' AND posts.user_id = users.user_id AND users.user_banned = '0'
        LEFT JOIN pages ON posts.user_type = 'page' AND posts.user_id = pages.page_id
        $where_clause
        ORDER BY posts.post_id DESC 
        LIMIT $limit";
    }
    
    // Add channel metadata
    $channel->addChild('language', 'en-us');
    $channel->addChild('lastBuildDate', date(DATE_RSS));
    $channel->addChild('generator', 'Sngine RSS Feed Generator');
    
    // Execute query
    $result = $db->query($query);
    
    if ($result && $result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $item = $channel->addChild('item');
            
            if ($feed_type === 'blogs') {
                // Blog post item
                $item->addChild('title', htmlspecialchars($row['title']));
                $item->addChild('link', $system['system_url'] . '/blogs/blog/' . $row['post_id'] . '/' . get_url_text($row['title']));
                $item->addChild('guid', $system['system_url'] . '/blogs/blog/' . $row['post_id']);
                
                // Description (blog content snippet)
                $description = strip_tags(html_entity_decode($row['text']));
                $description = mb_substr($description, 0, 300) . (mb_strlen($description) > 300 ? '...' : '');
                $item->addChild('description', htmlspecialchars($description));
                
                // Full content
                $content = $item->addChild('content:encoded', '', 'http://purl.org/rss/1.0/modules/content/');
                $content_text = html_entity_decode($row['text']);
                if ($row['cover']) {
                    $cover_url = $system['system_uploads'] . '/' . $row['cover'];
                    $content_text = '<img src="' . htmlspecialchars($cover_url) . '" alt="' . htmlspecialchars($row['title']) . '" style="max-width:100%;height:auto;margin-bottom:15px;" />' . $content_text;
                }
                // Use CDATA for content
                $dom = dom_import_simplexml($content);
                $dom->appendChild($dom->ownerDocument->createCDATASection($content_text));
                
                // Category
                if ($row['category_name']) {
                    $item->addChild('category', htmlspecialchars($row['category_name']));
                }
                
            } else {
                // Regular post item
                $post_title = $row['text'] ? strip_tags(html_entity_decode($row['text'])) : 'Post by ' . $row['author_name'];
                $post_title = mb_substr($post_title, 0, 100) . (mb_strlen($post_title) > 100 ? '...' : '');
                
                $item->addChild('title', htmlspecialchars($post_title ?: 'Post by ' . $row['author_name']));
                $item->addChild('link', $system['system_url'] . '/post/' . $row['post_id']);
                $item->addChild('guid', $system['system_url'] . '/post/' . $row['post_id']);
                
                // Description
                $description = $row['text'] ? strip_tags(html_entity_decode($row['text'])) : 'A ' . $row['post_type'] . ' post';
                $description = mb_substr($description, 0, 300) . (mb_strlen($description) > 300 ? '...' : '');
                $item->addChild('description', htmlspecialchars($description));
                
                // Category based on post type
                if ($row['post_type']) {
                    $item->addChild('category', htmlspecialchars(ucfirst($row['post_type']) . ' Post'));
                }
            }
            
            // Common fields
            $item->addChild('author', htmlspecialchars($row['author_name']));
            $item->addChild('pubDate', date(DATE_RSS, strtotime($row['time'])));
        }
    }
    
    // Output RSS
    echo $rss->asXML();
    
} catch (Exception $e) {
    // Error handling - return a basic RSS with error message
    $error_rss = '<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
    <channel>
        <title>RSS Feed Error</title>
        <description>An error occurred while generating the RSS feed</description>
        <link>' . $system['system_url'] . '</link>
        <item>
            <title>RSS Error</title>
            <description>' . htmlspecialchars($e->getMessage()) . '</description>
            <link>' . $system['system_url'] . '</link>
        </item>
    </channel>
</rss>';
    echo $error_rss;
}

// Function to get URL-friendly text (if not already defined)
if (!function_exists('get_url_text')) {
    function get_url_text($text) {
        return strtolower(trim(preg_replace('/[^A-Za-z0-9-]+/', '-', $text), '-'));
    }
}
?>