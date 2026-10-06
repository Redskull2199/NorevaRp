CREATE TABLE IF NOT EXISTS `real_vehicleshop` (
  `id` int(11) DEFAULT NULL,
  `information` longtext DEFAULT NULL,
  `vehicles` longtext DEFAULT NULL,
  `categories` longtext DEFAULT NULL,
  `feedbacks` longtext DEFAULT NULL,
  `complaints` longtext DEFAULT NULL,
  `preorders` longtext DEFAULT NULL,
  `employees` longtext DEFAULT NULL,
  `soldvehicles` longtext DEFAULT NULL,
  `transactions` longtext DEFAULT NULL,
  `perms` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
