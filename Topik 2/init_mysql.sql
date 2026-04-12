-- Setup Database
CREATE DATABASE IF NOT EXISTS db_rey_mikroskil;
USE db_rey_mikroskil;

-- PROJECT 1: Membership Cohort Analysis
-- Table: subscriptions
CREATE TABLE IF NOT EXISTS subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'active'
);

-- Seed Data Project 1
INSERT INTO subscriptions (user_id, start_date, end_date, status) VALUES
(1, '2025-01-10', NULL, 'active'),
(2, '2025-01-15', '2025-03-15', 'inactive'),
(3, '2025-01-20', NULL, 'active'),
(4, '2025-02-05', NULL, 'active'),
(5, '2025-02-12', '2025-04-12', 'inactive'),
(6, '2025-02-25', NULL, 'active'),
(7, '2025-03-01', NULL, 'active'),
(8, '2025-03-10', NULL, 'active');

-- PROJECT 2: User Rank & Engagement Modeling
-- Table: users (master table)
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE
);

INSERT INTO users (name, email) VALUES
('Budi', 'budi@email.com'),
('Ani', 'ani@email.com'),
('Siti', 'siti@email.com'),
('Joko', 'joko@email.com'),
('Rina', 'rina@email.com');

-- Table: notifications (engagement)
CREATE TABLE IF NOT EXISTS notifications (
    notif_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    type VARCHAR(50),
    is_opened BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO notifications (user_id, type, is_opened) VALUES
(1, 'daily_reminder', TRUE),
(1, 'promo', TRUE),
(2, 'daily_reminder', FALSE),
(3, 'health_tip', TRUE);

-- Table: reyfit_logs (fitness)
CREATE TABLE IF NOT EXISTS reyfit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    steps INT,
    calories_burned FLOAT,
    log_date DATE
);

INSERT INTO reyfit_logs (user_id, steps, calories_burned, log_date) VALUES
(1, 10000, 400, '2025-04-01'),
(1, 8000, 320, '2025-04-02'),
(2, 2000, 80, '2025-04-01'),
(3, 12000, 480, '2025-04-01');

-- Table: health_diaries (health entries)
CREATE TABLE IF NOT EXISTS health_diaries (
    diary_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    mood VARCHAR(50),
    symptoms TEXT,
    created_at DATE
);

INSERT INTO health_diaries (user_id, mood, created_at) VALUES
(1, 'happy', '2025-04-01'),
(1, 'neutral', '2025-04-02'),
(3, 'happy', '2025-04-01');

-- Table for storing scores (Project 2 output)
CREATE TABLE IF NOT EXISTS user_engagement_scores (
    user_id INT PRIMARY KEY,
    total_activity INT DEFAULT 0,
    z_score FLOAT DEFAULT 0,
    normalized_score FLOAT DEFAULT 0,
    segment VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
