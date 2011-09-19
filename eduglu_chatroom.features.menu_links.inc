<?php

/**
 * Implementation of hook_menu_default_menu_links().
 */
function eduglu_book_menu_default_menu_links() {
  $menu_links = array();

  // Exported menu link: features:chatroom
  $menu_links['features:chatroom'] = array(
    'menu_name' => 'features',
    'link_path' => 'chatroom',
    'router_path' => 'chatroom',
    'link_title' => 'Chatroom',
    'options' => array(),
    'module' => 'system',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '0',
  );
  // Translatables
  // Included for use with string extractors like potx.
  t('Chatroom');


  return $menu_links;
}
