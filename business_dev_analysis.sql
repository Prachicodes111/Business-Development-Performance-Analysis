create database lead_performance;

use lead_performance;

create table  Raj_performance(
    day VARCHAR(10),
    date DATE,
    leads INT,
    time_spent INT,
    avg_time_per_lead FLOAT,
    daily_team_review VARCHAR(10),
    incomplete_leads INT
);
 
 create table  Arya_performance(
    day VARCHAR(10),
    date DATE,
    leads INT,
    time_spent INT,
    avg_time_per_lead FLOAT,
    daily_team_review VARCHAR(10),
    incomplete_leads INT
);


create table  ali_performance(
    day VARCHAR(10),
    date DATE,
    leads INT,
    time_spent INT,
    avg_time_per_lead FLOAT,
    daily_team_review VARCHAR(10),
    incomplete_leads INT
);
 

SELECT *, 'Raj' AS source_table FROM raj_performance 
UNION ALL
SELECT *, 'Arya' AS source_table FROM arya_performance
UNION ALL
SELECT *, 'Ali' AS source_table FROM ali_performance;

create view all_performance_data as
SELECT *, 'Raj' AS source_table FROM raj_performance 
UNION ALL
SELECT *, 'Arya' AS source_table FROM arya_performance
UNION ALL
SELECT *, 'Ali' AS source_table FROM ali_performance;

select * from all_performance_data;

-- summary stats--
SELECT source_table,
       COUNT(*) AS Total_Records,
       sum(leads) as total_leads,
       round(AVG(Leads),1) AS Avg_Leads,
      round( AVG(Time_Spent),2) AS Avg_Time_Spent,
      round(AVG(Avg_Time_Per_Lead),2) AS Avg_Time_Per_Lead,
       SUM(Incomplete_Leads) AS Total_Incomplete_Leads
FROM all_performance_data
GROUP BY source_table;


-- 1) lead generation efficiency--

select source_table, sum(leads) as total_leads ,
sum(time_spent) as total_time_spent,
sum(leads)/sum(time_spent) * 100 as lead_generation_efficiency
from all_performance_data 
group by source_table
order by lead_generation_efficiency desc;


-- 2) Daily performance variability--

select source_table,
round(STDDEV(leads),2) as daily_leads_stddev from all_performance_data
group by source_table
order by daily_leads_stddev desc;

-- 3) Time Management Analysis --

SELECT 
    source_table,
    ROUND(
        SUM((avg_time_per_lead - avg_x) * (leads - avg_y)) /
        SQRT(
            SUM(POW(avg_time_per_lead - avg_x, 2)) *
            SUM(POW(leads - avg_y, 2))
        ), 2
    ) AS correlation
FROM 
(
    SELECT 
        source_table,
        avg_time_per_lead,
        leads,
        AVG(time_spent/leads) OVER (PARTITION BY source_table) AS avg_x,
        AVG(leads) OVER (PARTITION BY source_table) AS avg_y
    FROM all_performance_data
) AS correlation_data  
GROUP BY source_table
ORDER BY correlation DESC;





-- Where: X = avg_time_per_lead and Y = leads 

-- If Raj shows 0.09, this means more time spent strongly correlates with more leads. Encourage Raj to maintain this balance.--
-- If Arya shows -0.51, it indicates that increasing time spent doesn't significantly improve leads. Arya may need to improve time efficiency or strategy.--

-- 4) average leads on the basis of daily team review status
select source_table, 
round(avg(leads),2) as avg_leads, daily_team_review
from all_performance_data 
group by source_table, daily_team_review;

-- Percentage Difference Calculation
SELECT source_table,
ROUND((MAX(avg_leads) - MIN(avg_leads)) / MIN(avg_leads) * 100, 2) AS percentage_difference
 from(
 select source_table, 
round(avg(leads),2) as avg_leads, daily_team_review
from all_performance_data 
group by source_table, daily_team_review)
as review_data
group by source_table;

-- 6) performance consistency (CV)

SELECT source_table,
round(STDDEV_POP(leads) / AVG(leads) * 100 ,2) as Coefficient_of_variation
from all_performance_data
group by source_table 
order by Coefficient_of_variation asc
;

select * from all_performance_data;

-- 9) Comparative Day Analysis (Weekdays vs Weekends)
select source_table, 
round(avg(leads),2) as avg_leads,
case
when dayofweek(date) in (1,7) then 'weekend'
else 'weekday'
end as days
from all_performance_data
group by source_table, days
;
# there is no data for weekend for' arya and ali ' because they didn't worked on weekends


select * from all_performance_data;

-- 7) high performance 
WITH RankedPerformance AS (
    SELECT 
        source_table,
        date,
        leads,
        time_spent,
        ROW_NUMBER() OVER (PARTITION BY source_table ORDER BY leads DESC) AS rn,
        COUNT(*) OVER (PARTITION BY source_table) AS total_days
    FROM all_performance_data
),
Top10Percent AS (
    SELECT 
        source_table,
        date,
        leads,
        time_spent
    FROM RankedPerformance
    WHERE rn <= total_days * 0.1  -- Top 10% days
)
SELECT 
    source_table,
    ROUND(AVG(time_spent), 2) AS avg_time_high_performance
FROM Top10Percent
GROUP BY source_table
ORDER BY avg_time_high_performance DESC;


--
-- Q8) Impact of Longer Lead Generation Time
SELECT 
    source_table,
    CONCAT(FLOOR(time_spent / 30) * 30, '-', FLOOR(time_spent / 30) * 30 + 30, ' mins') AS time_bin,
    ROUND(AVG(leads), 2) AS avg_leads
FROM all_performance_data
GROUP BY source_table, time_bin
ORDER BY source_table, avg_leads DESC;













       









 
 