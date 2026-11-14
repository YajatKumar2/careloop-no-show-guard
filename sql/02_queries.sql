USE noshowguard;

-- Task 2.1 duplicate key test
-- INSERT with appointment_id 'A0001' a second time gave:
-- MySQL Error (1062): Duplicate entry 'A0001' for key 'appointments.PRIMARY'

-- now we will do task 2.2 clinics with at least 95 appointments
SELECT c.clinic_name,
       c.city,
       COUNT(*) AS appointments,
       SUM(a.no_show) AS no_shows,
       ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1) AS no_show_pct
FROM appointments a
JOIN clinics c ON a.clinic_id = c.clinic_id
GROUP BY c.clinic_id, c.clinic_name, c.city
HAVING COUNT(*) >= 95
ORDER BY no_show_pct DESC;

-- then task 2.2 all clinics, no HAVING
SELECT c.clinic_name,
       c.city,
       COUNT(*) AS appointments,
       SUM(a.no_show) AS no_shows,
       ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1) AS no_show_pct
FROM appointments a
JOIN clinics c ON a.clinic_id = c.clinic_id
GROUP BY c.clinic_id, c.clinic_name, c.city
ORDER BY no_show_pct DESC;


-- task 2.3 no-show rate by lead time band
SELECT CASE
         WHEN lead_days <= 7 THEN '1-7'
         WHEN lead_days <= 14 THEN '8-14'
         WHEN lead_days <= 30 THEN '15-30'
         ELSE '31+'
       END AS lead_band,
       COUNT(*) AS appointments,
       SUM(no_show) AS no_shows,
       ROUND(100.0 * SUM(no_show) / COUNT(*), 1) AS no_show_pct
FROM appointments
GROUP BY lead_band
ORDER BY MIN(lead_days);

-- Task 2.4 monthly no-show rate and change from previous month
WITH monthly AS (
  SELECT SUBSTR(appt_date, 1, 7) AS month,
         COUNT(*) AS appointments,
         ROUND(100.0 * SUM(no_show) / COUNT(*), 1) AS no_show_pct
  FROM appointments
  GROUP BY month
)
SELECT month,
       appointments,
       no_show_pct,
       no_show_pct - LAG(no_show_pct) OVER (ORDER BY month) AS change_pp
FROM monthly
ORDER BY month;

-- Task 2.5 rank within city and compare with overall rate
WITH clinic_rates AS (
  SELECT c.clinic_name,
         c.city,
         ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1) AS no_show_pct
  FROM appointments a
  JOIN clinics c ON a.clinic_id = c.clinic_id
  GROUP BY c.clinic_id, c.clinic_name, c.city
)
SELECT clinic_name,
       city,
       no_show_pct,
       RANK() OVER (PARTITION BY city ORDER BY no_show_pct DESC) AS rank_in_city,
       CASE
         WHEN no_show_pct > (SELECT 100.0 * SUM(no_show) / COUNT(*) FROM appointments) THEN 'above'
         WHEN no_show_pct < (SELECT 100.0 * SUM(no_show) / COUNT(*) FROM appointments) THEN 'below'
         ELSE 'equal'
       END AS vs_overall
FROM clinic_rates
ORDER BY city, rank_in_city;