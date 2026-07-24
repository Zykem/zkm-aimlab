CREATE TABLE IF NOT EXISTS `zykem_aimlab_stats` (
    `identifier`      VARCHAR(64)  NOT NULL,
    `total_sessions`  INT UNSIGNED NOT NULL DEFAULT 0,
    `total_hits`      INT UNSIGNED NOT NULL DEFAULT 0,
    `total_headshots` INT UNSIGNED NOT NULL DEFAULT 0,
    `headshot_rate`   DECIMAL(6,5) NOT NULL DEFAULT 0.00000,
    `updated_at`      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;