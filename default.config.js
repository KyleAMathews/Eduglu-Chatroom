var config = {}

config.mysql = {}
config.drupal = {}

// MySQL settings.
config.mysql.user_name = 'username';
config.mysql.password = 'password';
config.mysql.database = 'database_name';

// Drupal-specific settings.
config.drupal.api_key = 'copy key from your drupal site at /admin/settings/eduglu-chatroom';

// General settings.
config.port = "3000"

module.exports = config;
