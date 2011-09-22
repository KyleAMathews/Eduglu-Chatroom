<?php

/**
 * Implementation of hook_default_box().
 */
function eduglu_chatroom_default_box() {
  $export = array();
  $box = new stdClass;
  $box->disabled = FALSE; /* Edit this to true to make a default box disabled initially */
  $box->api_version = 1;
  $box->delta = 'chatroom_connected';
  $box->plugin_key = 'simple';
  $box->title = '';
  $box->description = 'Connected people';
  $box->options = array(
    'body' => '<h2>Connected</h2>',
    'format' => '4',
  );

  $export['chatroom_connected'] = $box;
  return $export;
}
