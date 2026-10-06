CREATE TABLE IF NOT EXISTS `neva_bank_transactions` (
    `id`         INT(11)      NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(50)  NOT NULL,
    `type`       VARCHAR(20)  NOT NULL COMMENT 'Options: deposit, withdraw, transfer_in, transfer_out',
    `amount`     INT(11)      NOT NULL,
    `title`      VARCHAR(255) DEFAULT NULL,
    `date`       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (`id`),
    KEY `idx_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `neva_bank_cards` (
    `id`          INT(11)      NOT NULL AUTO_INCREMENT,
    `identifier`  VARCHAR(50)  NOT NULL,
    `card_number` VARCHAR(20)  DEFAULT NULL,
    `card_name`   VARCHAR(50)  DEFAULT 'My Card',
    `pin`         VARCHAR(4)   DEFAULT NULL,
    `is_blocked`  TINYINT(1)   NOT NULL DEFAULT 0,
    
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


