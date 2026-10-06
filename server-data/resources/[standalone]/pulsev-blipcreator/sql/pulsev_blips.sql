-- Import manually into the server database. No existing table is rewritten.
-- Audit DATETIME values are UTC text supplied by the server.
CREATE TABLE IF NOT EXISTS pulsev_blips (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(64) NOT NULL,
    note VARCHAR(512) NOT NULL DEFAULT '',
    sprite SMALLINT UNSIGNED NOT NULL DEFAULT 280,
    color TINYINT UNSIGNED NOT NULL DEFAULT 3,
    scale DECIMAL(4,2) NOT NULL DEFAULT 0.80,
    alpha TINYINT UNSIGNED NOT NULL DEFAULT 255,
    display TINYINT UNSIGNED NOT NULL DEFAULT 2,
    short_range TINYINT(1) NOT NULL DEFAULT 1,
    x DOUBLE NOT NULL,
    y DOUBLE NOT NULL,
    z DOUBLE NOT NULL,
    rotation SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    category VARCHAR(48) NOT NULL DEFAULT 'Genel',
    map_category TINYINT UNSIGNED NOT NULL DEFAULT 2,
    enabled TINYINT(1) NOT NULL DEFAULT 1,
    version INT UNSIGNED NOT NULL DEFAULT 1,
    created_by VARCHAR(64) NOT NULL,
    updated_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    PRIMARY KEY (id),
    KEY idx_pulsev_blips_enabled (enabled),
    KEY idx_pulsev_blips_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- New table only; preserves all existing blips. Revoke stores an explicit denial.
CREATE TABLE IF NOT EXISTS pulsev_blip_permissions (
    license VARCHAR(48) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    allowed TINYINT(1) NOT NULL DEFAULT 1,
    updated_at DATETIME NOT NULL,
    PRIMARY KEY (license)
) ENGINE=InnoDB;
