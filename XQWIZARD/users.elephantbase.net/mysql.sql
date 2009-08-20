CREATE TABLE tb_user (
	uid INTEGER NOT NULL PRIMARY KEY,
	usertype INTEGER NOT NULL DEFAULT 0,
	lastip CHAR(15) NOT NULL DEFAULT '',
	lasttime INTEGER NOT NULL DEFAULT 0,
	score INTEGER NOT NULL DEFAULT 0,
	points INTEGER NOT NULL DEFAULT 0,
	charged INTEGER NOT NULL DEFAULT 0,
	KEY (lasttime),
	KEY (score));

CREATE TABLE tb_retry (
	username CHAR(15) NOT NULL PRIMARY KEY,
	retrycount INTEGER NOT NULL DEFAULT 0,
	retrytime INTEGER NOT NULL DEFAULT 0);

CREATE TABLE tb_password (
	username CHAR(15) NOT NULL PRIMARY KEY,
	email CHAR(32) NOT NULL,
	password CHAR(6) NOT NULL);

CREATE TABLE tb_rankw (
	uid INTEGER NOT NULL PRIMARY KEY,
	score INTEGER NOT NULL DEFAULT 0,
	rank INTEGER NOT NULL AUTO_INCREMENT,
	KEY (rank));

CREATE TABLE tb_rankw0 (
	uid INTEGER NOT NULL PRIMARY KEY,
	rank INTEGER NOT NULL DEFAULT 0);

CREATE TABLE tb_rankm (
	uid INTEGER NOT NULL PRIMARY KEY,
	score INTEGER NOT NULL DEFAULT 0,
	rank INTEGER NOT NULL AUTO_INCREMENT,
	KEY (rank));

CREATE TABLE tb_rankm0 (
	uid INTEGER NOT NULL PRIMARY KEY,
	rank INTEGER NOT NULL DEFAULT 0);

CREATE TABLE tb_rankq (
	uid INTEGER NOT NULL PRIMARY KEY,
	score INTEGER NOT NULL DEFAULT 0,
	rank INTEGER NOT NULL AUTO_INCREMENT,
	KEY (rank));

CREATE TABLE tb_rankq0 (
	uid INTEGER NOT NULL PRIMARY KEY,
	rank INTEGER NOT NULL DEFAULT 0);

CREATE TABLE tb_chargecode (
	chargecode CHAR(32) NOT NULL PRIMARY KEY,
	points INTEGER NOT NULL DEFAULT 0);

CREATE TABLE tb_log (
	uid INTEGER NOT NULL PRIMARY KEY,
	eventip VARCHAR(16) NOT NULL,
	eventtime INTEGER NOT NULL,
	eventtype INTEGER NOT NULL,
	detail INTEGER NOT NULL DEFAULT 0);

CREATE TABLE tb_task (
	taskname VARCHAR(64) NOT NULL PRIMARY KEY,
	lasttime INTEGER NOT NULL DEFAULT 0,
	nexttime INTEGER NOT NULL DEFAULT 0,
	tasklock INTEGER NOT NULL DEFAULT 0);

INSERT INTO tb_task (taskname) VALUES ("dailytask");