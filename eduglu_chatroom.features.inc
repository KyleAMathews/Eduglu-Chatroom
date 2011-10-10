<?php

/**
 * Implementation of hook_ctools_plugin_api().
 */
function eduglu_chatroom_ctools_plugin_api() {
  list($module, $api) = func_get_args();
  if ($module == "boxes" && $api == "box") {
    return array("version" => 1);
  }
  elseif ($module == "context" && $api == "context") {
    return array("version" => 3);
  }
}

/**
 * Implementation of hook_imagecache_default_presets().
 */
function eduglu_chatroom_imagecache_default_presets() {
  $items = array(
    'chatroom_pic' => array(
      'presetname' => 'chatroom_pic',
      'actions' => array(
        '0' => array(
          'weight' => '0',
          'module' => 'imagecache',
          'action' => 'imagecache_scale_and_crop',
          'data' => array(
            'width' => '25',
            'height' => '25',
          ),
        ),
      ),
    ),
  );
  return $items;
}
