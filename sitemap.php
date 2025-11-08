<?php

/**
 * sitemap
 *
 * Generates an XML sitemap for public-facing resources.
 *
 * @package Sngine
 * @author
 */

require('bootstrap.php');

set_time_limit(0);
header('Content-Type: application/xml; charset=utf-8');

define('SITEMAP_MAX_ENTRIES', 50000);

/**
 * Normalize a URL/path into an absolute URL.
 *
 * @param string $loc
 * @return string|null
 */
function sitemap_normalize_loc($loc)
{
  global $system;
  if (!$loc) {
    return null;
  }
  if (!preg_match('#^https?://#i', $loc)) {
    $base = rtrim($system['system_url'], '/');
    $loc = $base . '/' . ltrim($loc, '/');
  }
  return $loc;
}

/**
 * Pick the first non-empty, non-zero datetime string.
 *
 * @param mixed ...$dates
 * @return string|null
 */
function sitemap_pick_date(...$dates)
{
  foreach ($dates as $value) {
    if (empty($value)) {
      continue;
    }
    if ($value === '0000-00-00 00:00:00') {
      continue;
    }
    return $value;
  }
  return null;
}

/**
 * Append a URL entry to the sitemap list.
 *
 * @param array  $urls
 * @param string $loc
 * @param mixed  $lastmod
 * @param string $changefreq
 * @param float  $priority
 * @return void
 */
function sitemap_add_url(array &$urls, $loc, $lastmod = null, $changefreq = null, $priority = null)
{
  $normalized = sitemap_normalize_loc($loc);
  if (!$normalized) {
    return;
  }
  if (!isset($urls[$normalized]) && count($urls) >= SITEMAP_MAX_ENTRIES) {
    return;
  }

  $entry = [
    'loc' => $normalized,
  ];

  if (!empty($lastmod)) {
    $timestamp = is_numeric($lastmod) ? (int) $lastmod : strtotime($lastmod);
    if ($timestamp) {
      $entry['lastmod'] = date(DATE_W3C, $timestamp);
    }
  }

  if (!empty($changefreq)) {
    $entry['changefreq'] = $changefreq;
  }

  if ($priority !== null) {
    $priority = max(0.0, min(1.0, (float) $priority));
    $entry['priority'] = number_format($priority, 1, '.', '');
  }

  $urls[$normalized] = $entry;
}

$urls = [];

/* Home */
sitemap_add_url($urls, '/', null, 'daily', 1.0);

/* Static pages */
if ($get_static = $db->query("SELECT page_url, page_is_redirect, page_redirect_url FROM static_pages ORDER BY page_order ASC")) {
  while ($static_page = $get_static->fetch_assoc()) {
    if ($static_page['page_is_redirect'] === '1') {
      if (!empty($static_page['page_redirect_url'])) {
        sitemap_add_url($urls, $static_page['page_redirect_url'], null, 'monthly', 0.4);
      }
    } else {
      sitemap_add_url($urls, 'static/' . $static_page['page_url'], null, 'monthly', 0.5);
    }
  }
}

/* Directory */
if (!empty($system['directory_enabled'])) {
  sitemap_add_url($urls, 'directory', null, 'weekly', 0.6);
}

if (!empty($system['system_public'])) {
  /* Module landing pages */
  $module_pages = [
    ['flag' => 'blogs_enabled', 'path' => 'blogs', 'freq' => 'daily', 'priority' => 0.7],
    ['flag' => 'pages_enabled', 'path' => 'pages', 'freq' => 'weekly', 'priority' => 0.6],
    ['flag' => 'groups_enabled', 'path' => 'groups', 'freq' => 'weekly', 'priority' => 0.6],
    ['flag' => 'events_enabled', 'path' => 'events', 'freq' => 'weekly', 'priority' => 0.6],
    ['flag' => 'market_enabled', 'path' => 'market', 'freq' => 'weekly', 'priority' => 0.5],
    ['flag' => 'offers_enabled', 'path' => 'offers', 'freq' => 'weekly', 'priority' => 0.5],
    ['flag' => 'jobs_enabled', 'path' => 'jobs', 'freq' => 'weekly', 'priority' => 0.5],
    ['flag' => 'courses_enabled', 'path' => 'courses', 'freq' => 'weekly', 'priority' => 0.5],
    ['flag' => 'forums_enabled', 'path' => 'forums', 'freq' => 'weekly', 'priority' => 0.5],
    ['flag' => 'movies_enabled', 'path' => 'movies', 'freq' => 'weekly', 'priority' => 0.4],
    ['flag' => 'games_enabled', 'path' => 'games', 'freq' => 'weekly', 'priority' => 0.4],
    ['flag' => 'funding_enabled', 'path' => 'funding', 'freq' => 'weekly', 'priority' => 0.4],
  ];

  foreach ($module_pages as $module) {
    if (!empty($system[$module['flag']])) {
      sitemap_add_url($urls, $module['path'], null, $module['freq'], $module['priority']);
    }
  }

  /* Blogs */
  if (!empty($system['blogs_enabled'])) {
    if ($blog_categories = $db->query("SELECT category_id, category_name FROM blogs_categories ORDER BY category_id ASC")) {
      while ($category = $blog_categories->fetch_assoc()) {
        $category_slug = get_url_text($category['category_name']);
        if (!$category_slug) {
          $category_slug = $category['category_id'];
        }
        sitemap_add_url(
          $urls,
          'blogs/category/' . $category['category_id'] . '/' . $category_slug,
          null,
          'monthly',
          0.5
        );
      }
    }

    $blogs_query = "
      SELECT posts.post_id, posts.time, posts_articles.title
      FROM posts
      INNER JOIN posts_articles ON posts.post_id = posts_articles.post_id
      WHERE posts.post_type = 'article'
        AND posts.in_group = '0'
        AND posts.in_event = '0'
        AND posts.is_hidden = '0'
        AND posts.privacy = 'public'
        AND posts.for_subscriptions = '0'
        AND posts.is_paid = '0'
        AND posts.for_adult = '0'
        AND (posts.pre_approved = '1' OR posts.has_approved = '1')
      ORDER BY posts.time DESC
      LIMIT " . SITEMAP_MAX_ENTRIES;

    if ($blogs = $db->query($blogs_query)) {
      while ($blog = $blogs->fetch_assoc()) {
        $slug = get_url_text($blog['title'], 10);
        if (!$slug) {
          $slug = $blog['post_id'];
        }
        sitemap_add_url(
          $urls,
          'blogs/' . $blog['post_id'] . '/' . $slug,
          sitemap_pick_date($blog['time']),
          'monthly',
          0.5
        );
      }
    }
  }

  /* Pages */
  if (!empty($system['pages_enabled'])) {
    $pages_query = "
      SELECT page_name, page_date
      FROM pages
      WHERE page_name <> ''
      ORDER BY page_id DESC
      LIMIT " . SITEMAP_MAX_ENTRIES;

    if ($pages = $db->query($pages_query)) {
      while ($page = $pages->fetch_assoc()) {
        sitemap_add_url(
          $urls,
          'pages/' . $page['page_name'],
          sitemap_pick_date($page['page_date']),
          'weekly',
          0.6
        );
      }
    }
  }

  /* Groups */
  if (!empty($system['groups_enabled'])) {
    $groups_query = "
      SELECT group_name, group_date
      FROM `groups`
      WHERE group_privacy = 'public'
      ORDER BY group_id DESC
      LIMIT " . SITEMAP_MAX_ENTRIES;

    if ($groups = $db->query($groups_query)) {
      while ($group = $groups->fetch_assoc()) {
        sitemap_add_url(
          $urls,
          'groups/' . $group['group_name'],
          sitemap_pick_date($group['group_date']),
          'weekly',
          0.5
        );
      }
    }
  }

  /* Events */
  if (!empty($system['events_enabled'])) {
    $events_query = "
      SELECT event_id, event_title, event_date, event_start_date, event_end_date
      FROM `events`
      WHERE event_privacy = 'public'
      ORDER BY event_id DESC
      LIMIT " . SITEMAP_MAX_ENTRIES;

    if ($events = $db->query($events_query)) {
      while ($event = $events->fetch_assoc()) {
        $slug = get_url_text($event['event_title'], 10);
        if (!$slug) {
          $slug = $event['event_id'];
        }
        sitemap_add_url(
          $urls,
          'events/' . $event['event_id'] . '/' . $slug,
          sitemap_pick_date($event['event_end_date'], $event['event_start_date'], $event['event_date']),
          'weekly',
          0.5
        );
      }
    }
  }
}

/* Output XML */
echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' . "\n";

foreach ($urls as $entry) {
  echo "  <url>\n";
  echo '    <loc>' . htmlspecialchars($entry['loc'], ENT_QUOTES | ENT_XML1, 'UTF-8') . "</loc>\n";
  if (!empty($entry['lastmod'])) {
    echo '    <lastmod>' . $entry['lastmod'] . "</lastmod>\n";
  }
  if (!empty($entry['changefreq'])) {
    echo '    <changefreq>' . $entry['changefreq'] . "</changefreq>\n";
  }
  if (isset($entry['priority'])) {
    echo '    <priority>' . $entry['priority'] . "</priority>\n";
  }
  echo "  </url>\n";
}

echo "</urlset>\n";
