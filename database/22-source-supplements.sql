-- Source: server-data/resources/[ox]/ox_inventory/modules/mysql/server.lua
CREATE TABLE `ox_inventory` (
			`owner` varchar(60) DEFAULT NULL,
			`name` varchar(100) NOT NULL,
			`data` longtext DEFAULT NULL,
			`lastupdated` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
			UNIQUE KEY `owner` (`owner`,`name`)
		);

-- Source: server-data/resources/[fivebazaar]/xt-prison/modules/server/db.lua
CREATE TABLE IF NOT EXISTS `xt_prison` (
        `identifier` VARCHAR(100) NOT NULL,
        `jailtime` INT(11) NOT NULL DEFAULT '0',
        PRIMARY KEY (`identifier`) USING BTREE
    );

-- Source: server-data/resources/[fivebazaar]/randol_lockers/server/sv_lockers.lua
CREATE TABLE IF NOT EXISTS lockers (
                id INT(11) NOT NULL AUTO_INCREMENT,
                citizenid VARCHAR(60) DEFAULT NULL,
                name VARCHAR(255) DEFAULT NULL,
                owned BOOLEAN DEFAULT FALSE,
                label VARCHAR(50) DEFAULT NULL,
                coords TEXT DEFAULT NULL,
                player VARCHAR(50) DEFAULT NULL,
                price BIGINT DEFAULT NULL,
                storage BIGINT DEFAULT NULL,
                slots BIGINT DEFAULT NULL,
                keyholders TEXT NULL DEFAULT NULL COLLATE utf8mb4_unicode_ci,
                PRIMARY KEY (id) USING BTREE,
                KEY citizenid (citizenid) USING BTREE
            ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Source: server-data/resources/[fivebazaar]/real-bank/server/main.lua
CREATE TABLE IF NOT EXISTS `bank_invoices` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `citizenid` varchar(50) NOT NULL,
            `sender` varchar(50) DEFAULT NULL,
            `amount` decimal(10,2) NOT NULL,
            `reason` varchar(100) DEFAULT NULL,
            `description` varchar(255) DEFAULT NULL,
            `society` varchar(50) DEFAULT NULL,
            `isPaid` tinyint(1) NOT NULL DEFAULT 0,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            `paid_at` timestamp NULL DEFAULT NULL,
            PRIMARY KEY (`id`),
            KEY `citizenid` (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- DDL only from local SQL reference; active-script requirement: bank_accounts
CREATE TABLE IF NOT EXISTS `bank_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(11) DEFAULT NULL,
  `account_name` varchar(50) DEFAULT NULL,
  `account_balance` int(11) NOT NULL DEFAULT 0,
  `account_type` enum('shared','job','gang') NOT NULL,
  `users` longtext DEFAULT '[]',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `account_name` (`account_name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- DDL only from local SQL reference; active-script requirement: crypto_transactions
CREATE TABLE IF NOT EXISTS `crypto_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(11) DEFAULT NULL,
  `title` varchar(50) DEFAULT NULL,
  `message` varchar(50) DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- DDL only from local SQL reference; active-script requirement: phone_invoices
CREATE TABLE IF NOT EXISTS `phone_invoices` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(11) DEFAULT NULL,
  `amount` int(11) NOT NULL DEFAULT 0,
  `society` tinytext DEFAULT NULL,
  `sender` varchar(50) DEFAULT NULL,
  `sendercitizenid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- DDL only from local SQL reference; active-script requirement: player_mails
CREATE TABLE IF NOT EXISTS `player_mails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(11) DEFAULT NULL,
  `sender` varchar(50) DEFAULT NULL,
  `subject` varchar(50) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `read` tinyint(4) DEFAULT 0,
  `mailid` int(11) DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `button` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- DDL only from local SQL reference; active-script requirement: player_warns
CREATE TABLE IF NOT EXISTS `player_warns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `senderIdentifier` varchar(50) DEFAULT NULL,
  `targetIdentifier` varchar(50) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `warnId` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- DDL only from local SQL reference; active-script requirement: inventories
CREATE TABLE IF NOT EXISTS `inventories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) NOT NULL,
  `items` longtext DEFAULT '[]',
  PRIMARY KEY (`identifier`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ox_inventory/modules/mysql/server.lua QB vehicle fields
ALTER TABLE player_vehicles ADD COLUMN IF NOT EXISTS glovebox LONGTEXT NULL, ADD COLUMN IF NOT EXISTS trunk LONGTEXT NULL;
