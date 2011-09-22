<?php

/**
 * Implementation of hook_context_default_contexts().
 */
function eduglu_chatroom_context_default_contexts() {
  $export = array();
  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'eduglu_chatroom';
  $context->description = 'Sets up blocks for the Eduglu Chatroom';
  $context->tag = 'eduglu';
  $context->conditions = array(
    'menu' => array(
      'values' => array(
        'chatroom' => 'chatroom',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'boxes-chatroom_connected' => array(
          'module' => 'boxes',
          'delta' => 'chatroom_connected',
          'region' => 'right',
          'weight' => 0,
        ),
      ),
    ),
  );
  $context->condition_mode = 0;

  // Translatables
  // Included for use with string extractors like potx.
  t('Sets up blocks for the Eduglu Chatroom');
  t('eduglu');

  $export['eduglu_chatroom'] = $context;
  return $export;
}
