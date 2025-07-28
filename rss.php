<?php

/**
 * RSS Feed Generator - Fixed Version
 * 
 * @package Sngine
 * @author Fixed RSS URLs
 */

// fetch bootloader
require('bootloader.php');

// Set RSS content type header
header('Content-Type: application/rss+xml; charset=UTF-8');

// Get blog posts for RSS
$blogs = $user->get_blogs(['results' => 20]);

// Generate RSS XML
echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
echo '<rss xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">';
echo '<channel>';
echo '<atom:link href="' . $system['system_url'] . '/rss.php?type=blogs" rel="self" type="application/rss+xml"/>';
echo '<title>' . htmlspecialchars($system['system_title']) . ' - Blog Posts</title>';
echo '<description>Explore the latest articles</description>';
echo '<link>' . $system['system_url'] . '/blogs</link>';
echo '<language>en-us</language>';
echo '<lastBuildDate>' . gmdate('D, d M Y H:i:s') . ' +0000</lastBuildDate>';
echo '<generator>Sngine RSS Feed Generator</generator>';

if ($blogs) {
  foreach ($blogs as $blog) {
    echo '<item>';
    echo '<title>' . htmlspecialchars($blog['blog']['title']) . '</title>';
    // Fix: Use correct URL pattern without extra /blog/ segment
    echo '<link>' . $system['system_url'] . '/blogs/' . $blog['post_id'] . '/' . $blog['blog']['title_url'] . '</link>';
    echo '<guid>' . $system['system_url'] . '/blogs/' . $blog['post_id'] . '</guid>';
    echo '<description>' . htmlspecialchars($blog['blog']['text_snippet']) . '</description>';
    echo '<content:encoded><![CDATA[';
    if ($blog['blog']['parsed_cover']) {
      echo '<img src="' . $blog['blog']['parsed_cover'] . '" alt="' . htmlspecialchars($blog['blog']['title']) . '" style="max-width:100%;height:auto;margin-bottom:15px;" />';
    }
    echo $blog['blog']['parsed_text'];
    echo ']]></content:encoded>';
    if ($blog['blog']['category_name']) {
      echo '<category>' . htmlspecialchars($blog['blog']['category_name']) . '</category>';
    }
    echo '<author>' . htmlspecialchars($blog['post_author_name']) . '</author>';
    echo '<pubDate>' . gmdate('D, d M Y H:i:s', strtotime($blog['time'])) . ' +0000</pubDate>';
    echo '</item>';
  }
}

echo '</channel>';
echo '</rss>';
?>