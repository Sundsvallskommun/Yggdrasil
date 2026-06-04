-- The merged api-service-notifier owns a single schema (messaging + users + csvimport tables).
-- The former user_management and teams_sender_db schemas are no longer used.
CREATE DATABASE IF NOT EXISTS notifier CHARACTER SET utf8mb4 COLLATE utf8mb4_swedish_ci;
