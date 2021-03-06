#
# Database Structure of Skeleton application
#

# InnoDb is required
SET storage_engine=INNODB;

# Tables
# Users
# - PRIMARY UNIQUE email
# - UNIQUE login
# - status - pending > active > disabled > deleted
CREATE TABLE users
(
  id BIGINT(20) unsigned PRIMARY KEY NOT NULL AUTO_INCREMENT,
  login VARCHAR(255),
  email VARCHAR(255),
  created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated TIMESTAMP DEFAULT '0000-00-00 00:00:00' NOT NULL,
  status VARCHAR(32) DEFAULT 'disabled' NOT NULL
);
CREATE UNIQUE INDEX users_login_uindex ON users (login);
CREATE UNIQUE INDEX users_email_uindex ON users (email);

# Users Actions
# - activation account
# - change email
# - recovery access
# - remove account
CREATE TABLE users_actions
(
  userId BIGINT(20) unsigned NOT NULL,
  code VARCHAR(32) NOT NULL,
  action VARCHAR(32) NOT NULL,
  params LONGTEXT,
  created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  expired TIMESTAMP DEFAULT '0000-00-00 00:00:00' NOT NULL,
  CONSTRAINT users_actions_userId_code_pk PRIMARY KEY (userId, code),
  CONSTRAINT users_actions_users_id_fk FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX users_actions_userId_action_uindex ON users_actions (userId, action);

# Authentication by providers
# - cookie - for `remember me`
# - equals - for login-password
# - token - for API
# - facebook
# - twitter
# - google
CREATE TABLE auth
(
  userId BIGINT(20) unsigned NOT NULL,
  provider VARCHAR(64) NOT NULL,
  foreignKey VARCHAR(255) NOT NULL,
  token VARCHAR(64) NOT NULL,
  tokenSecret VARCHAR(64) NOT NULL,
  tokenType VARCHAR(32) NOT NULL,
  created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated TIMESTAMP DEFAULT '0000-00-00 00:00:00' NOT NULL,
  expired TIMESTAMP DEFAULT '0000-00-00 00:00:00' NOT NULL,
  CONSTRAINT auth_userId_provider_pk PRIMARY KEY (userId, provider),
  CONSTRAINT auth_users_id_fk FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
);

# ACL based on three table
# > Roles
CREATE TABLE acl_roles
(
  id INT(10) unsigned NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  CONSTRAINT acl_roles_id_name_pk PRIMARY KEY (id, name)
);
CREATE UNIQUE INDEX acl_roles_name_uindex ON acl_roles (name);

# > Privileges
CREATE TABLE acl_privileges
(
  roleId INT(10) unsigned NOT NULL,
  module VARCHAR(32) NOT NULL,
  privilege VARCHAR(32) NOT NULL,
  CONSTRAINT acl_privileges_acl_roles_id_fk FOREIGN KEY (roleId) REFERENCES acl_roles (id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX acl_privileges_roleId_module_privilege_uindex ON acl_privileges (roleId, module, privilege);

# > User to Roles
CREATE TABLE acl_users_roles
(
  userId BIGINT(20) unsigned NOT NULL,
  roleId INT(10) unsigned NOT NULL,
  CONSTRAINT acl_users_roles_userId_roleId_pk PRIMARY KEY (userId, roleId),
  CONSTRAINT acl_users_roles_users_id_fk FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT acl_users_roles_acl_roles_id_fk FOREIGN KEY (roleId) REFERENCES acl_roles (id) ON DELETE CASCADE ON UPDATE CASCADE
);

# Options entity
CREATE TABLE options
(
  namespace VARCHAR(64) DEFAULT 'default' NOT NULL,
  `key` VARCHAR(255) NOT NULL,
  value LONGTEXT NOT NULL,
  description LONGTEXT,
  created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated TIMESTAMP DEFAULT '0000-00-00 00:00:00' NOT NULL,
  CONSTRAINT options_key_namespace_pk PRIMARY KEY (`key`, namespace)
);

# Categories for all modules
CREATE TABLE categories
(
  id BIGINT(20) unsigned PRIMARY KEY NOT NULL AUTO_INCREMENT,
  rootId BIGINT(20) unsigned,
  parentId BIGINT(20) unsigned,
  name VARCHAR(255) NOT NULL,
  alias VARCHAR(255) NOT NULL,
  created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated TIMESTAMP DEFAULT '0000-00-00 00:00:00' NOT NULL,
  CONSTRAINT categories_categories_id_fk FOREIGN KEY (parentId) REFERENCES categories (id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX UNIQUE_alias ON categories (parentId, alias);

# Media for all modules
CREATE TABLE media
(
  id BIGINT(20) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  userId BIGINT(20) unsigned NOT NULL,
  module VARCHAR(24) DEFAULT 'users' NOT NULL,
  title LONGTEXT,
  type VARCHAR(24),
  file VARCHAR(255),
  thumb VARCHAR(255),
  size INT(11) unsigned NOT NULL,
  created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated TIMESTAMP DEFAULT '0000-00-00 00:00:00' NOT NULL,
  CONSTRAINT media_users_id_fk FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
);

# Static pages
CREATE TABLE pages
(
  id INT(10) unsigned PRIMARY KEY NOT NULL AUTO_INCREMENT,
  userId BIGINT(20) unsigned,
  title LONGTEXT NOT NULL,
  alias VARCHAR(255) NOT NULL,
  content LONGTEXT,
  keywords LONGTEXT,
  description LONGTEXT,
  created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated TIMESTAMP DEFAULT '0000-00-00 00:00:00' NOT NULL,
  CONSTRAINT pages_users_id_fk FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX pages_alias_uindex ON pages (alias);

# Comments for all modules and entities
# > Settings
CREATE TABLE com_settings
(
  id INT(10) unsigned PRIMARY KEY NOT NULL AUTO_INCREMENT,
  alias VARCHAR(255) NOT NULL,
  options LONGTEXT,
  created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated TIMESTAMP DEFAULT '0000-00-00 00:00:00' NOT NULL,
  countPerPage SMALLINT(6) DEFAULT '10' NOT NULL,
  relatedTable VARCHAR(64)
);
CREATE UNIQUE INDEX com_settings_alias_uindex ON com_settings (alias);

# > Comments
CREATE TABLE com_content
(
  id BIGINT(20) unsigned PRIMARY KEY NOT NULL AUTO_INCREMENT,
  settingsId INT(10) unsigned NOT NULL,
  foreignKey INT(10) unsigned NOT NULL,
  userId BIGINT(20) unsigned NOT NULL,
  parentId BIGINT(20) unsigned,
  content LONGTEXT,
  created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated TIMESTAMP DEFAULT '0000-00-00 00:00:00' NOT NULL,
  status VARCHAR(255) DEFAULT 'active' NOT NULL,
  CONSTRAINT com_content_com_settings_id_fk FOREIGN KEY (settingsId) REFERENCES com_settings (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT com_content_users_id_fk FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT com_content_com_content_id_fk FOREIGN KEY (parentId) REFERENCES com_content (id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX comments_target ON com_content (settingsId, foreignKey);
