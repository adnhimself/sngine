<?php
/**
 * RSS Feed Test & Demo Script
 * 
 * This script tests the RSS implementation and shows available endpoints
 */

// Include the bootloader to access system functions
require('bootloader.php');

echo "<h1>Sngine RSS Feed Implementation Test</h1>";
echo "<p><strong>System URL:</strong> " . $system['system_url'] . "</p>";

echo "<h2>Available RSS Endpoints:</h2>";

echo "<h3>🔸 Blog Posts RSS Feeds:</h3>";
echo "<ul>";
echo "<li><strong>All Blogs:</strong><br>";
echo "<code>" . $system['system_url'] . "/rss/blogs</code><br>";
echo "<a href='/rss/blogs' target='_blank'>View Feed</a></li>";

echo "<li><strong>All Blogs (alternative URL):</strong><br>";
echo "<code>" . $system['system_url'] . "/rss.php?type=blogs</code><br>";
echo "<a href='/rss.php?type=blogs' target='_blank'>View Feed</a></li>";

echo "<li><strong>Blogs by User ID (example user_id=1):</strong><br>";
echo "<code>" . $system['system_url'] . "/rss/blogs/user/1</code><br>";
echo "<a href='/rss/blogs/user/1' target='_blank'>View Feed</a></li>";
echo "</ul>";

echo "<h3>🔸 Regular Posts RSS Feeds:</h3>";
echo "<ul>";
echo "<li><strong>All Posts:</strong><br>";
echo "<code>" . $system['system_url'] . "/rss/posts</code><br>";
echo "<a href='/rss/posts' target='_blank'>View Feed</a></li>";

echo "<li><strong>All Posts (alternative URL):</strong><br>";
echo "<code>" . $system['system_url'] . "/rss.php?type=posts</code><br>";
echo "<a href='/rss.php?type=posts' target='_blank'>View Feed</a></li>";

echo "<li><strong>Posts by User ID (example user_id=1):</strong><br>";
echo "<code>" . $system['system_url'] . "/rss/posts/user/1</code><br>";
echo "<a href='/rss/posts/user/1' target='_blank'>View Feed</a></li>";
echo "</ul>";

echo "<h3>🔸 Custom Parameters:</h3>";
echo "<ul>";
echo "<li><strong>Limited Results (max 50):</strong><br>";
echo "<code>" . $system['system_url'] . "/rss/blogs?limit=10</code><br>";
echo "<a href='/rss/blogs?limit=10' target='_blank'>View Feed (10 items)</a></li>";

echo "<li><strong>User-specific with limit:</strong><br>";
echo "<code>" . $system['system_url'] . "/rss.php?type=posts&user_id=1&limit=5</code><br>";
echo "<a href='/rss.php?type=posts&user_id=1&limit=5' target='_blank'>View Feed (5 items)</a></li>";
echo "</ul>";

// Test database connectivity and show some stats
echo "<h2>📊 Database Stats:</h2>";

try {
    // Count total public blog posts
    $blog_count = $db->query("SELECT COUNT(*) as count FROM posts 
        INNER JOIN posts_articles ON posts.post_id = posts_articles.post_id 
        WHERE posts.post_type = 'article' 
        AND posts.privacy = 'public' 
        AND posts.in_group = '0' 
        AND posts.in_event = '0' 
        AND (posts.pre_approved = '1' OR posts.has_approved = '1')");
    $blog_count_result = $blog_count->fetch_assoc();
    
    // Count total public regular posts
    $post_count = $db->query("SELECT COUNT(*) as count FROM posts 
        WHERE posts.post_type != 'article' 
        AND posts.privacy = 'public' 
        AND posts.in_group = '0' 
        AND posts.in_event = '0' 
        AND (posts.pre_approved = '1' OR posts.has_approved = '1')");
    $post_count_result = $post_count->fetch_assoc();
    
    echo "<ul>";
    echo "<li><strong>Public Blog Posts Available:</strong> " . $blog_count_result['count'] . "</li>";
    echo "<li><strong>Public Regular Posts Available:</strong> " . $post_count_result['count'] . "</li>";
    echo "</ul>";
    
    if ($blog_count_result['count'] == 0 && $post_count_result['count'] == 0) {
        echo "<p><em>⚠️ No public posts found. RSS feeds will be empty until you create some public content.</em></p>";
    }
    
} catch (Exception $e) {
    echo "<p><strong>Database Error:</strong> " . $e->getMessage() . "</p>";
}

echo "<h2>📝 Usage Instructions:</h2>";
echo "<ol>";
echo "<li><strong>Test the feeds:</strong> Click on the links above to view the RSS XML output</li>";
echo "<li><strong>For external use:</strong> Copy the RSS URLs to use in RSS readers, IFTTT, etc.</li>";
echo "<li><strong>Find User IDs:</strong> Check user profiles or database to get specific user IDs</li>";
echo "<li><strong>Integration:</strong> Use these URLs in external services for content aggregation</li>";
echo "</ol>";

echo "<h2>🛠️ Technical Notes:</h2>";
echo "<ul>";
echo "<li>Only <strong>public posts</strong> are included in RSS feeds</li>";
echo "<li>Posts from <strong>groups and events are excluded</strong></li>";
echo "<li>Only <strong>approved posts</strong> are included</li>";
echo "<li>Feeds are limited to <strong>50 items maximum</strong> (default: 20)</li>";
echo "<li>RSS feeds are <strong>RSS 2.0 compliant</strong> with rich content support</li>";
echo "</ul>";

echo "<h2>🔗 Quick Links:</h2>";
echo "<ul>";
echo "<li><a href='/blogs' target='_blank'>View Blogs Section</a></li>";
echo "<li><a href='/' target='_blank'>View Main Site</a></li>";
echo "<li><a href='/rss/blogs' target='_blank'>Test Blog RSS Feed</a></li>";
echo "<li><a href='/rss/posts' target='_blank'>Test Posts RSS Feed</a></li>";
echo "</ul>";

echo "<hr>";
echo "<p><small>RSS Implementation for Sngine - Ready for content aggregation and external integration!</small></p>";
?>

<style>
body { font-family: Arial, sans-serif; max-width: 800px; margin: 20px auto; padding: 20px; }
code { background: #f4f4f4; padding: 2px 5px; border-radius: 3px; }
h2 { color: #333; border-bottom: 1px solid #ddd; padding-bottom: 5px; }
h3 { color: #555; }
ul li { margin-bottom: 10px; }
a { color: #0066cc; }
</style>