-- Setup Database
CREATE DATABASE IF NOT EXISTS db_rey_mikroskil;
USE db_rey_mikroskil;

-- PROJECT 1: Membership Cohort Analysis
-- Table: subscriptions
-- (loader maps XLSX `join_date` -> start_date, `termination_date` -> end_date)
CREATE TABLE IF NOT EXISTS subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'active'
);

-- PROJECT 2: User Rank & Engagement Modeling
-- Table: user_logins (per-user last-login record from app)
CREATE TABLE IF NOT EXISTS user_logins (
    login_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    platform VARCHAR(50),
    last_login_at DATETIME
);

-- Table: reyfit_logs (monthly fitness aggregate)
CREATE TABLE IF NOT EXISTS reyfit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    active_month DATE NOT NULL,
    step_counts INT,
    total_hydration_ml INT
);

-- Table: health_diaries (monthly diary-entry count)
CREATE TABLE IF NOT EXISTS health_diaries (
    diary_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    active_month DATE NOT NULL,
    count_diaries INT
);

-- Table for storing scores (Project 2 output)
CREATE TABLE IF NOT EXISTS user_engagement_scores (
    user_id INT PRIMARY KEY,
    total_activity INT DEFAULT 0,
    z_score FLOAT DEFAULT 0,
    normalized_score FLOAT DEFAULT 0,
    segment VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Derived view: users (no PII — built from activity tables)
-- Lists every distinct user_id with their earliest and latest observed activity.
CREATE OR REPLACE VIEW users AS
SELECT
    user_id,
    MIN(activity_date) AS first_activity,
    MAX(activity_date) AS last_activity
FROM (
    SELECT user_id, start_date AS activity_date FROM subscriptions
    UNION ALL
    SELECT user_id, DATE(last_login_at) FROM user_logins
    UNION ALL
    SELECT user_id, active_month FROM reyfit_logs
    UNION ALL
    SELECT user_id, active_month FROM health_diaries
) AS all_activities
WHERE user_id IS NOT NULL
GROUP BY user_id;
