# Live Code: MySQL Advanced Features
## Studi Kasus: Membership & Engagement Analytics (REY)

Pastikan container Docker sudah berjalan (`docker-compose up -d`).

---

### Langkah 1: Eksplorasi Data
```sql
USE db_rey_mikroskil;
SELECT * FROM subscriptions;
SELECT * FROM users;
```

### Langkah 2: Membuat Database VIEW (Cohort Analysis)
Kita butuh View untuk menghitung spesifik umur setiap subscription dalam bulan agar bisa dianalisis retensinya.

```sql
-- View untuk menentukan Cohort Month dan Umur Subscription (dalam bulan)
CREATE OR REPLACE VIEW view_user_cohort AS
SELECT 
    user_id, 
    start_date,
    end_date,
    DATE_FORMAT(start_date, '%Y-%m-01') AS cohort_month,
    -- Menghitung selisih bulan antara start_date dan end_date (atau hari ini jika masih aktif)
    TIMESTAMPDIFF(MONTH, start_date, IFNULL(end_date, CURRENT_DATE)) AS sub_age_months
FROM subscriptions;

SELECT * FROM view_user_cohort;

-- Final Table: Agregasi Cohort dan Umur
-- Menampilkan sebaran user berdasarkan kapan mereka mulai dan berapa lama mereka bertahan
SELECT 
    cohort_month,
    sub_age_months,
    COUNT(user_id) AS total_users
FROM view_user_cohort
GROUP BY cohort_month, sub_age_months
ORDER BY cohort_month, sub_age_months;
```

### Langkah 3: Menghitung Statistik (Z-Score & Normalization)
Daripada menentukan poin manual (1 notif = 1 poin), kita akan menghitung seberapa aktif user dibanding rata-rata teman-temannya.

**Formula Z-Score:** `z = (x - mean) / stddev`
**Formula Normalisasi:** `(z - min_z) / (max_z - min_z) * 100`

```sql
-- View untuk menghitung aggregasi aktivitas mentah per user
CREATE OR REPLACE VIEW view_raw_activities AS
SELECT 
    u.user_id,
    (
        (SELECT COUNT(*) FROM notifications n WHERE n.user_id = u.user_id AND n.is_opened = TRUE) +
        (SELECT COUNT(*) FROM reyfit_logs r WHERE r.user_id = u.user_id) +
        (SELECT COUNT(*) FROM health_diaries h WHERE h.user_id = u.user_id)
    ) AS raw_activity
FROM users u;

-- Query untuk menghitung Z-Score dan Normalisasi (Window Functions)
SELECT 
    user_id,
    raw_activity,
    -- Menghitung Z-Score
    (raw_activity - AVG(raw_activity) OVER()) / NULLIF(STDDEV(raw_activity) OVER(), 0) as z_score
FROM view_raw_activities;
```

### Langkah 4: Membuat STORED PROCEDURE (Refresh Ranking)
Prosedur ini akan memproses semua data statistik dan menyimpannya ke tabel ranking agar cepat diakses oleh aplikasi (Product Team).

```sql
DELIMITER //

CREATE PROCEDURE sp_refresh_engagement_rankings()
BEGIN
    TRUNCATE TABLE user_engagement_scores;

    INSERT INTO user_engagement_scores (user_id, total_activity, z_score, normalized_score, segment)
    SELECT 
        user_id,
        raw_activity,
        z_score,
        -- Normalisasi ke skala 0 - 100
        CASE 
            WHEN max_z = min_z THEN 100 
            ELSE (z_score - min_z) / (max_z - min_z) * 100 
        END as normalized_score,
        CASE 
            WHEN z_score > 1 THEN 'Superstar'
            WHEN z_score > 0 THEN 'Average'
            ELSE 'Passive'
        END as segment
    FROM (
        SELECT 
            user_id,
            raw_activity,
            z_score,
            MIN(z_score) OVER() as min_z,
            MAX(z_score) OVER() as max_z
        FROM (
            SELECT 
                user_id,
                raw_activity,
                (raw_activity - AVG(raw_activity) OVER()) / NULLIF(STDDEV(raw_activity) OVER(), 0) as z_score
            FROM view_raw_activities
        ) z_calc
    ) final_calc;
END //

DELIMITER ;

-- Jalankan
CALL sp_refresh_engagement_rankings();
SELECT * FROM user_engagement_scores ORDER BY normalized_score DESC;
```

### Langkah 5: Membuat TRIGGER (Automasi)
Setiap ada user baru daftar di tabel `users`, kita ingin dia otomatis punya entry di tabel `user_engagement_scores` dengan poin 0.
```sql
DELIMITER //

CREATE TRIGGER trer_after_user_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO user_engagement_scores (user_id, total_activity, z_score, normalized_score, segment)
    VALUES (NEW.user_id, 0, 0, 0, 'New Joiner');
END //

DELIMITER ;

-- Test Trigger
INSERT INTO users (name, email) VALUES ('Andi', 'andi@email.com');
-- Panggil Refresh agar statistik terupdate untuk user baru
CALL sp_refresh_engagement_rankings();
SELECT * FROM user_engagement_scores WHERE user_id = (SELECT LAST_INSERT_ID());
```
