# CareLoop No-Show Guard

Repository: https://github.com/YajatKumar2/careloop-no-show-guard

## Summary
- **Part 1 (Python):** 1,020 raw bookings were cleaned to 990 valid rows; 218 were no-shows (22.0%).
- **Part 2 (SQL):** No-shows climb with lead time: 16.2% when booked 1–7 days ahead vs 60.5% when booked 31+ days ahead.
- **Part 3 (ML):** Logistic regression ranked risk best (test ROC-AUC 0.789); at a 0.35 threshold it caught 57% of test no-shows while flagging 49 of 198 bookings.
- **Part 4 (GenAI):** Gemini classified 9 of 9 non-blank notes into allowed reasons; both "forgot / no reminder" notes came from bookings with no reminder sent (2 of 2).

## Recommendation
Each evening, the front desk should phone the bookings that the model scores at 0.35 or above, starting with long lead times and patients with past no-shows. At the 22.0% overall no-show rate, about 1 in 5 slots is lost today. Calling 49 of 198 bookings caught 57% of the real no-shows in testing. Every booking should also get a reminder: in the model, holding other features constant, a reminder is linked to about 69% lower odds of a no-show (odds × 0.31), and the call notes show forgetting without a reminder as a real reason. Bookings made 31+ days ahead (60.5% no-show) need an extra confirmation call a few days before the visit.

## Model choice
Logistic regression (scaled in a pipeline) was chosen because it had the highest 5-fold cross-validated ROC-AUC on the training set (0.774, vs tuned random forest 0.767, random forest 0.745, depth-3 tree 0.678). The threshold of 0.35 was picked on out-of-fold training probabilities because its F1 (0.49) and recall (0.47) were higher than at 0.5 (F1 0.35, recall 0.25). On the test set, used once, it scored ROC-AUC 0.789, precision 0.57 and recall 0.57.

## Limitations
1. The 10 call notes are only an illustration and cannot show the real reasons for no-shows across all clinics.
2. Cleaning statistics (medians, quartiles, outlier fences) were calculated on all 990 rows before the train/test split, and the split is random rather than past-to-future, so the test score may be slightly optimistic.
3. The data are observational, so the reminder effect is an association, not proof that reminders cause fewer no-shows.

## Files
- notebooks/01_ingest_clean.ipynb — Part 1 (Tasks 1.1–1.6)
- sql/load_data.sql, sql/02_queries.sql — Part 2 (with the duplicate-key error as a comment)
- notebooks/part2_sql_checks.ipynb — pandas check of the Task 2.2 SQL counts
- notebooks/03_model.ipynb — Part 3
- notebooks/04_genai.ipynb — Part 4 (API key typed at run time, not stored)
- outputs/ — rejected_rows.json, appointments_clean.csv, clinics_enriched.csv, test_risk_scores.csv, notes_analysed.csv
- data/ — the three original files