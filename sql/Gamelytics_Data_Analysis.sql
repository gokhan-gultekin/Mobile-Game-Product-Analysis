CREATE DATABASE gamelytics_project;

USE gamelytics_project;
SELECT DATABASE();

CREATE TABLE registrations (
    reg_ts BIGINT,
    uid INT PRIMARY KEY
);

CREATE TABLE authentications (
    auth_ts BIGINT,
    uid INT
);
CREATE INDEX idx_auth_uid
ON authentications(uid);

CREATE TABLE ab_test (
    user_id INT,
    revenue DECIMAL(12,2),
    testgroup CHAR(1)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 26.7/Uploads/reg_data.csv'
INTO TABLE registrations
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(reg_ts, uid);

SELECT COUNT(*) AS total_registrations
FROM registrations;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 26.7/Uploads/auth_data.csv'
INTO TABLE authentications
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(auth_ts, uid);

SELECT COUNT(*) AS total_authentications
FROM authentications;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 26.7/Uploads/ab_test.csv'
INTO TABLE ab_test
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(user_id, revenue, testgroup);

SELECT COUNT(*) AS total_ab_test
FROM ab_test;

SELECT *
FROM ab_test
LIMIT 10;

SELECT 
    testgroup,
    COUNT(*) AS users
FROM ab_test
GROUP BY testgroup;

SELECT
    r.uid,
    r.reg_ts,
    a.auth_ts
FROM registrations r
JOIN authentications a
    ON r.uid = a.uid
LIMIT 20;

SELECT
    r.uid,
    r.reg_ts,
    a.auth_ts
FROM registrations r
JOIN authentications a
    ON r.uid = a.uid
WHERE a.auth_ts > r.reg_ts
LIMIT 20;

SELECT
    COUNT(DISTINCT r.uid) AS returning_players
FROM registrations r
JOIN authentications a
    ON r.uid = a.uid
WHERE a.auth_ts > r.reg_ts;

SELECT COUNT(*) AS total_players
FROM registrations;


SHOW INDEX FROM authentications;

SELECT COUNT(*) AS returning_players
FROM registrations r
WHERE EXISTS (
    SELECT 1
    FROM authentications a
    WHERE a.uid = r.uid
      AND a.auth_ts > r.reg_ts
);

CREATE INDEX idx_auth_uid_ts
ON authentications(uid, auth_ts);
DROP INDEX idx_auth_uid
ON authentications;
SHOW INDEX FROM authentications;

SELECT COUNT(*) AS d1_retained_players
FROM registrations r
WHERE EXISTS (
    SELECT 1
    FROM authentications a
    WHERE a.uid = r.uid
      AND a.auth_ts >= UNIX_TIMESTAMP(
            DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 1 DAY
          )
      AND a.auth_ts < UNIX_TIMESTAMP(
            DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 2 DAY
          )
);

SELECT
    FROM_UNIXTIME(MAX(auth_ts)) AS last_observation_time
FROM authentications;

SELECT COUNT(*) AS d1_eligible_players
FROM registrations
WHERE DATE(FROM_UNIXTIME(reg_ts)) < '2020-09-23';

SELECT COUNT(*) AS d7_retained_players
FROM registrations r
WHERE EXISTS (
    SELECT 1
    FROM authentications a
    WHERE a.uid = r.uid
      AND a.auth_ts >= UNIX_TIMESTAMP(
            DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 7 DAY
          )
      AND a.auth_ts < UNIX_TIMESTAMP(
            DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 8 DAY
          )
);

SELECT COUNT(*) AS d7_eligible_players
FROM registrations
WHERE DATE(FROM_UNIXTIME(reg_ts)) < '2020-09-17';

SELECT COUNT(*) AS d30_retained_players
FROM registrations r
WHERE EXISTS (
    SELECT 1
    FROM authentications a
    WHERE a.uid = r.uid
      AND a.auth_ts >= UNIX_TIMESTAMP(
            DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 30 DAY
          )
      AND a.auth_ts < UNIX_TIMESTAMP(
            DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 31 DAY
          )
);
SELECT COUNT(*) AS d30_eligible_players
FROM registrations
WHERE DATE(FROM_UNIXTIME(reg_ts))
      < DATE_SUB('2020-09-23', INTERVAL 29 DAY);

SELECT COUNT(*) AS d1_plus_retained
FROM registrations r
WHERE EXISTS (
    SELECT 1
    FROM authentications a
    WHERE a.uid = r.uid
      AND a.auth_ts >= UNIX_TIMESTAMP(
            DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 1 DAY
          )
);
SELECT COUNT(*) AS d7_plus_retained
FROM registrations r
WHERE EXISTS (
    SELECT 1
    FROM authentications a
    WHERE a.uid = r.uid
      AND a.auth_ts >= UNIX_TIMESTAMP(
            DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 7 DAY
          )
);
SELECT COUNT(*) AS d30_plus_retained
FROM registrations r
WHERE EXISTS (
    SELECT 1
    FROM authentications a
    WHERE a.uid = r.uid
      AND a.auth_ts >= UNIX_TIMESTAMP(
            DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 30 DAY
          )
);

SELECT
    YEAR(FROM_UNIXTIME(reg_ts)) AS registration_year,
    COUNT(*) AS registered_players
FROM registrations
GROUP BY YEAR(FROM_UNIXTIME(reg_ts))
ORDER BY registration_year;

SELECT
    YEAR(FROM_UNIXTIME(r.reg_ts)) AS registration_year,
    COUNT(*) AS eligible_players,

    SUM(
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM authentications a
                WHERE a.uid = r.uid
                  AND a.auth_ts >= UNIX_TIMESTAMP(
                      DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 1 DAY
                  )
            )
            THEN 1
            ELSE 0
        END
    ) AS d1_plus_retained,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM authentications a
                    WHERE a.uid = r.uid
                      AND a.auth_ts >= UNIX_TIMESTAMP(
                          DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 1 DAY
                      )
                )
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS d1_plus_retention_pct

FROM registrations r

WHERE DATE(FROM_UNIXTIME(r.reg_ts)) < '2020-09-23'

GROUP BY YEAR(FROM_UNIXTIME(r.reg_ts))
ORDER BY registration_year;

SELECT
    YEAR(FROM_UNIXTIME(r.reg_ts)) AS registration_year,
    COUNT(*) AS eligible_players,

    SUM(
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM authentications a
                WHERE a.uid = r.uid
                  AND a.auth_ts >= UNIX_TIMESTAMP(
                      DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 7 DAY
                  )
            )
            THEN 1
            ELSE 0
        END
    ) AS d7_plus_retained,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM authentications a
                    WHERE a.uid = r.uid
                      AND a.auth_ts >= UNIX_TIMESTAMP(
                          DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 7 DAY
                      )
                )
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS d7_plus_retention_pct

FROM registrations r

WHERE DATE(FROM_UNIXTIME(r.reg_ts)) < '2020-09-17'

GROUP BY YEAR(FROM_UNIXTIME(r.reg_ts))
ORDER BY registration_year;

SELECT
    YEAR(FROM_UNIXTIME(r.reg_ts)) AS registration_year,
    COUNT(*) AS eligible_players,

    SUM(
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM authentications a
                WHERE a.uid = r.uid
                  AND a.auth_ts >= UNIX_TIMESTAMP(
                      DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 30 DAY
                  )
            )
            THEN 1
            ELSE 0
        END
    ) AS d30_plus_retained,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM authentications a
                    WHERE a.uid = r.uid
                      AND a.auth_ts >= UNIX_TIMESTAMP(
                          DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 30 DAY
                      )
                )
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS d30_plus_retention_pct

FROM registrations r

WHERE DATE(FROM_UNIXTIME(r.reg_ts)) < '2020-08-25'

GROUP BY YEAR(FROM_UNIXTIME(r.reg_ts))
ORDER BY registration_year;

SELECT
    uid,
    COUNT(*) AS auth_count
FROM authentications
GROUP BY uid
ORDER BY auth_count DESC;

SELECT
    auth_count,
    COUNT(*) AS player_count
FROM (
    SELECT
        uid,
        COUNT(*) AS auth_count
    FROM authentications
    GROUP BY uid
) AS player_auth_counts
GROUP BY auth_count
ORDER BY auth_count;

SELECT
    CASE
        WHEN auth_count = 1 THEN 'One-time'
        WHEN auth_count BETWEEN 2 AND 5 THEN 'Low'
        WHEN auth_count BETWEEN 6 AND 11 THEN 'Medium'
        ELSE 'High'
    END AS engagement_segment,

    COUNT(*) AS player_count

FROM (
    SELECT
        uid,
        COUNT(*) AS auth_count
    FROM authentications
    GROUP BY uid
) AS player_auth_counts

GROUP BY engagement_segment
ORDER BY
    CASE engagement_segment
        WHEN 'One-time' THEN 1
        WHEN 'Low' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'High' THEN 4
    END;

    SELECT
    engagement_segment,
    COUNT(*) AS player_count,
    SUM(auth_count) AS total_auth_events,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS player_share_pct,
    ROUND(
        100.0 * SUM(auth_count) / SUM(SUM(auth_count)) OVER (),
        2
    ) AS auth_share_pct
FROM (
    SELECT
        uid,
        COUNT(*) AS auth_count,
        CASE
            WHEN COUNT(*) = 1 THEN 'One-time'
            WHEN COUNT(*) BETWEEN 2 AND 5 THEN 'Low'
            WHEN COUNT(*) BETWEEN 6 AND 11 THEN 'Medium'
            ELSE 'High'
        END AS engagement_segment
    FROM authentications
    GROUP BY uid
) AS player_segments

GROUP BY engagement_segment

ORDER BY
    CASE engagement_segment
        WHEN 'One-time' THEN 1
        WHEN 'Low' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'High' THEN 4
    END;

    SELECT
    uid,
    COUNT(*) AS auth_count,
    FROM_UNIXTIME(MIN(auth_ts)) AS first_auth,
    FROM_UNIXTIME(MAX(auth_ts)) AS last_auth,
    DATEDIFF(
        FROM_UNIXTIME(MAX(auth_ts)),
        FROM_UNIXTIME(MIN(auth_ts))
    ) AS lifespan_days
FROM authentications
GROUP BY uid
ORDER BY auth_count DESC;

SELECT
    engagement_segment,
    COUNT(*) AS player_count,
    ROUND(AVG(auth_count), 2) AS avg_auth_count,
    ROUND(AVG(lifespan_days), 2) AS avg_lifespan_days
FROM (
    SELECT
        uid,
        COUNT(*) AS auth_count,

        DATEDIFF(
            FROM_UNIXTIME(MAX(auth_ts)),
            FROM_UNIXTIME(MIN(auth_ts))
        ) AS lifespan_days,

        CASE
            WHEN COUNT(*) = 1 THEN 'One-time'
            WHEN COUNT(*) BETWEEN 2 AND 5 THEN 'Low'
            WHEN COUNT(*) BETWEEN 6 AND 11 THEN 'Medium'
            ELSE 'High'
        END AS engagement_segment

    FROM authentications
    GROUP BY uid
) AS player_metrics

GROUP BY engagement_segment

ORDER BY
    CASE engagement_segment
        WHEN 'One-time' THEN 1
        WHEN 'Low' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'High' THEN 4
    END;

WITH player_metrics AS (
    SELECT
        uid,
        COUNT(*) AS auth_count,
        DATEDIFF(
            FROM_UNIXTIME(MAX(auth_ts)),
            FROM_UNIXTIME(MIN(auth_ts))
        ) AS lifespan_days
    FROM authentications
    GROUP BY uid
),

ranked_high_players AS (
    SELECT
        lifespan_days,
        ROW_NUMBER() OVER (
            ORDER BY lifespan_days
        ) AS row_num
    FROM player_metrics
    WHERE auth_count >= 12
)

SELECT
    AVG(lifespan_days) AS median_lifespan_days
FROM ranked_high_players
WHERE row_num IN (23335, 23336);

WITH player_metrics AS (
    SELECT
        uid,
        COUNT(*) AS auth_count,
        DATEDIFF(
            FROM_UNIXTIME(MAX(auth_ts)),
            FROM_UNIXTIME(MIN(auth_ts))
        ) AS lifespan_days
    FROM authentications
    GROUP BY uid
),

segmented_players AS (
    SELECT
        uid,
        auth_count,
        lifespan_days,
        CASE
            WHEN auth_count = 1 THEN 'One-time'
            WHEN auth_count BETWEEN 2 AND 5 THEN 'Low'
            WHEN auth_count BETWEEN 6 AND 11 THEN 'Medium'
            ELSE 'High'
        END AS engagement_segment
    FROM player_metrics
),

ranked_players AS (
    SELECT
        engagement_segment,
        lifespan_days,

        ROW_NUMBER() OVER (
            PARTITION BY engagement_segment
            ORDER BY lifespan_days
        ) AS row_num,

        COUNT(*) OVER (
            PARTITION BY engagement_segment
        ) AS segment_count

    FROM segmented_players
)

SELECT
    engagement_segment,
    AVG(lifespan_days) AS median_lifespan_days
FROM ranked_players

WHERE row_num IN (
    FLOOR((segment_count + 1) / 2),
    FLOOR((segment_count + 2) / 2)
)

GROUP BY engagement_segment

ORDER BY
    CASE engagement_segment
        WHEN 'One-time' THEN 1
        WHEN 'Low' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'High' THEN 4
    END;

SELECT
    COUNT(DISTINCT a.uid) AS matched_users
FROM authentications a
INNER JOIN ab_test ab
    ON a.uid = ab.user_id;

WITH player_engagement AS (
    SELECT
        uid,
        COUNT(*) AS auth_count,

        CASE
            WHEN COUNT(*) = 1 THEN 'One-time'
            WHEN COUNT(*) BETWEEN 2 AND 5 THEN 'Low'
            WHEN COUNT(*) BETWEEN 6 AND 11 THEN 'Medium'
            ELSE 'High'
        END AS engagement_segment

    FROM authentications
    GROUP BY uid
)

SELECT
    pe.engagement_segment,
    COUNT(*) AS users,
    SUM(CASE WHEN ab.revenue > 0 THEN 1 ELSE 0 END) AS paying_users

FROM player_engagement pe

INNER JOIN ab_test ab
    ON pe.uid = ab.user_id

GROUP BY pe.engagement_segment

ORDER BY
    CASE pe.engagement_segment
        WHEN 'One-time' THEN 1
        WHEN 'Low' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'High' THEN 4
    END;

WITH player_engagement AS (
    SELECT
        uid,
        COUNT(*) AS auth_count,

        CASE
            WHEN COUNT(*) = 1 THEN 'One-time'
            WHEN COUNT(*) BETWEEN 2 AND 5 THEN 'Low'
            WHEN COUNT(*) BETWEEN 6 AND 11 THEN 'Medium'
            ELSE 'High'
        END AS engagement_segment

    FROM authentications
    GROUP BY uid
)

SELECT
    pe.engagement_segment,
    COUNT(*) AS users,
    SUM(
        CASE
            WHEN ab.revenue > 0 THEN 1
            ELSE 0
        END
    ) AS paying_users,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN ab.revenue > 0 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS payer_conversion_pct,
    ROUND(
        SUM(ab.revenue) / COUNT(*),
        2
    ) AS arpu,
    ROUND(
        SUM(ab.revenue) /
        NULLIF(
            SUM(
                CASE
                    WHEN ab.revenue > 0 THEN 1
                    ELSE 0
                END
            ),
            0
        ),
        2
    ) AS arppu
FROM player_engagement pe
INNER JOIN ab_test ab
    ON pe.uid = ab.user_id

GROUP BY pe.engagement_segment
ORDER BY
    CASE pe.engagement_segment
        WHEN 'One-time' THEN 1
        WHEN 'Low' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'High' THEN 4
    END;

SELECT
    user_id,
    revenue,
    testgroup
FROM ab_test
WHERE revenue > 0
ORDER BY revenue DESC
LIMIT 20;

SELECT
    testgroup,
    COUNT(*) AS total_users,
    SUM(
        CASE WHEN revenue > 0 THEN 1 ELSE 0 END
    ) AS paying_users,
    ROUND(AVG(revenue), 2) AS arpu,
    ROUND(
        AVG(
            CASE
                WHEN revenue > 0 THEN revenue
            END
        ),
        2
    ) AS arppu,
    MIN(
        CASE
            WHEN revenue > 0 THEN revenue
        END
    ) AS min_payer_revenue,
    MAX(revenue) AS max_revenue
FROM ab_test
GROUP BY testgroup;

SELECT
    testgroup,
    COUNT(*) AS total_users,
    SUM(
        CASE WHEN revenue > 0 THEN 1 ELSE 0 END
    ) AS paying_users,
    ROUND(
        100.0 * SUM(
            CASE WHEN revenue > 0 THEN 1 ELSE 0 END
        ) / COUNT(*),
        3
    ) AS payer_conversion_pct
FROM ab_test
GROUP BY testgroup;



-- ============================================
-- 7. POWER BI VIEWS
-- ============================================

-- Retention Summary

CREATE OR REPLACE VIEW retention_summary AS

SELECT
    'D1+' AS retention_metric,
    COUNT(*) AS eligible_players,
    SUM(
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM authentications a
                WHERE a.uid = r.uid
                  AND a.auth_ts >= UNIX_TIMESTAMP(
                      DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 1 DAY
                  )
            )
            THEN 1
            ELSE 0
        END
    ) AS retained_players
FROM registrations r
WHERE r.reg_ts < UNIX_TIMESTAMP('2020-09-23')

UNION ALL

SELECT
    'D7+',
    COUNT(*),
    SUM(
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM authentications a
                WHERE a.uid = r.uid
                  AND a.auth_ts >= UNIX_TIMESTAMP(
                      DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 7 DAY
                  )
            )
            THEN 1
            ELSE 0
        END
    )
FROM registrations r
WHERE r.reg_ts < UNIX_TIMESTAMP('2020-09-17')

UNION ALL

SELECT
    'D30+',
    COUNT(*),
    SUM(
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM authentications a
                WHERE a.uid = r.uid
                  AND a.auth_ts >= UNIX_TIMESTAMP(
                      DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 30 DAY
                  )
            )
            THEN 1
            ELSE 0
        END
    )
FROM registrations r
WHERE r.reg_ts < UNIX_TIMESTAMP('2020-08-25');

SELECT *
FROM retention_summary;

-- Cohort Retention Summary

CREATE OR REPLACE VIEW cohort_retention AS

SELECT
    YEAR(FROM_UNIXTIME(r.reg_ts)) AS cohort_year,

    ROUND(
        100.0 * SUM(
            CASE WHEN EXISTS (
                SELECT 1
                FROM authentications a
                WHERE a.uid = r.uid
                  AND a.auth_ts >= UNIX_TIMESTAMP(
                      DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 1 DAY
                  )
            ) THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS d1_retention,

    ROUND(
        100.0 * SUM(
            CASE WHEN EXISTS (
                SELECT 1
                FROM authentications a
                WHERE a.uid = r.uid
                  AND a.auth_ts >= UNIX_TIMESTAMP(
                      DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 7 DAY
                  )
            ) THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS d7_retention,

    ROUND(
        100.0 * SUM(
            CASE WHEN EXISTS (
                SELECT 1
                FROM authentications a
                WHERE a.uid = r.uid
                  AND a.auth_ts >= UNIX_TIMESTAMP(
                      DATE(FROM_UNIXTIME(r.reg_ts)) + INTERVAL 30 DAY
                  )
            ) THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS d30_retention

FROM registrations r

WHERE
    YEAR(FROM_UNIXTIME(r.reg_ts)) BETWEEN 2012 AND 2019

GROUP BY
    YEAR(FROM_UNIXTIME(r.reg_ts))

ORDER BY
    cohort_year;

SELECT *
FROM cohort_retention;

-- Engagement Summary

CREATE OR REPLACE VIEW engagement_summary AS

WITH player_activity AS (
    SELECT
        uid,
        COUNT(*) AS auth_count,
        DATEDIFF(
            FROM_UNIXTIME(MAX(auth_ts)),
            FROM_UNIXTIME(MIN(auth_ts))
        ) AS lifespan_days
    FROM authentications
    GROUP BY uid
),

segmented_players AS (
    SELECT
        uid,
        auth_count,
        lifespan_days,
        CASE
            WHEN auth_count = 1 THEN 'One-time'
            WHEN auth_count BETWEEN 2 AND 5 THEN 'Low'
            WHEN auth_count BETWEEN 6 AND 11 THEN 'Medium'
            ELSE 'High'
        END AS engagement_segment
    FROM player_activity
)

SELECT
    engagement_segment,
    COUNT(*) AS player_count,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS player_share,
    SUM(auth_count) AS total_auth_events,
    ROUND(
        100.0 * SUM(auth_count) /
        SUM(SUM(auth_count)) OVER (),
        2
    ) AS auth_event_share,
    ROUND(AVG(auth_count), 2) AS avg_auth_count,
    ROUND(AVG(lifespan_days), 2) AS avg_lifespan_days

FROM segmented_players

GROUP BY engagement_segment;

SELECT *
FROM engagement_summary;

-- Engagement Median Lifespan

CREATE OR REPLACE VIEW engagement_median_lifespan AS

WITH player_activity AS (
    SELECT
        uid,
        COUNT(*) AS auth_count,
        DATEDIFF(
            FROM_UNIXTIME(MAX(auth_ts)),
            FROM_UNIXTIME(MIN(auth_ts))
        ) AS lifespan_days
    FROM authentications
    GROUP BY uid
),

segmented_players AS (
    SELECT
        uid,
        lifespan_days,
        CASE
            WHEN auth_count = 1 THEN 'One-time'
            WHEN auth_count BETWEEN 2 AND 5 THEN 'Low'
            WHEN auth_count BETWEEN 6 AND 11 THEN 'Medium'
            ELSE 'High'
        END AS engagement_segment
    FROM player_activity
),

ranked_players AS (
    SELECT
        engagement_segment,
        lifespan_days,

        ROW_NUMBER() OVER (
            PARTITION BY engagement_segment
            ORDER BY lifespan_days
        ) AS row_num,

        COUNT(*) OVER (
            PARTITION BY engagement_segment
        ) AS segment_count

    FROM segmented_players
)

SELECT
    engagement_segment,
    ROUND(AVG(lifespan_days), 1) AS median_lifespan_days

FROM ranked_players

WHERE row_num IN (
    FLOOR((segment_count + 1) / 2),
    FLOOR((segment_count + 2) / 2)
)

GROUP BY engagement_segment;

SELECT *
FROM engagement_median_lifespan;

-- Monetization by Engagement Segment

CREATE OR REPLACE VIEW monetization_by_engagement AS

WITH player_activity AS (
    SELECT
        uid,
        COUNT(*) AS auth_count
    FROM authentications
    GROUP BY uid
),

segmented_players AS (
    SELECT
        uid,
        CASE
            WHEN auth_count = 1 THEN 'One-time'
            WHEN auth_count BETWEEN 2 AND 5 THEN 'Low'
            WHEN auth_count BETWEEN 6 AND 11 THEN 'Medium'
            ELSE 'High'
        END AS engagement_segment
    FROM player_activity
)

SELECT
    s.engagement_segment,

    COUNT(*) AS matched_users,

    SUM(
        CASE WHEN ab.revenue > 0 THEN 1 ELSE 0 END
    ) AS paying_users,

    ROUND(
        100.0 * SUM(CASE WHEN ab.revenue > 0 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS payer_conversion,

    ROUND(
        SUM(ab.revenue) / COUNT(*),
        2
    ) AS arpu,

    ROUND(
        SUM(ab.revenue) /
        NULLIF(
            SUM(CASE WHEN ab.revenue > 0 THEN 1 ELSE 0 END),
            0
        ),
        2
    ) AS arppu

FROM segmented_players s

INNER JOIN ab_test ab
    ON s.uid = ab.user_id

GROUP BY s.engagement_segment;

SELECT *
FROM monetization_by_engagement;

-- A/B Test Summary

CREATE OR REPLACE VIEW ab_test_summary AS

SELECT
    testgroup,

    COUNT(*) AS total_users,

    SUM(
        CASE WHEN revenue > 0 THEN 1 ELSE 0 END
    ) AS paying_users,

    ROUND(
        100.0 * SUM(CASE WHEN revenue > 0 THEN 1 ELSE 0 END)
        / COUNT(*),
        3
    ) AS payer_conversion,

    ROUND(
        SUM(revenue) / COUNT(*),
        2
    ) AS arpu,

    ROUND(
        SUM(revenue) /
        NULLIF(
            SUM(CASE WHEN revenue > 0 THEN 1 ELSE 0 END),
            0
        ),
        2
    ) AS arppu,

    MIN(
        CASE WHEN revenue > 0 THEN revenue END
    ) AS min_payer_revenue,

    MAX(revenue) AS max_revenue

FROM ab_test

GROUP BY testgroup;
SELECT *
FROM ab_test_summary;
