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

