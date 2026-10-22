# Mobile-Game-Product-Analysis
**Gamelytics – Mobile Game Product Analytics & Strategy**

An independent product analytics case study focused on understanding player behavior, evaluating product performance, and developing data-driven recommendations for mobile game growth.

**Project Overview**

This project analyzes mobile game registration, authentication, and monetization data to investigate player retention, engagement patterns, and revenue performance.

The analysis combines SQL (MySQL) for data preparation and analytical queries with Power BI for dashboard development and visualization.

**Objectives**
- Evaluate player retention using D1, D7, and D30 retention metrics.
- Segment players based on authentication frequency and activity lifespan.
- Analyze monetization using payer conversion, ARPU, and ARPPU.
- Compare A/B test groups and interpret experiment results.
- Identify opportunities to improve player engagement and long-term retention.

**Tools & Methods**

Tools: MySQL, Power BI

Methods: Retention Analysis, Cohort Analysis, Player Segmentation, Monetization Analysis, A/B Test Evaluation, KPI Definition, RICE Prioritization

**Key Findings**
- Analyzed approximately 1 million player registrations and 9.6 million authentication events.
- Identified 10.72% D30+ rolling retention in the analyzed player population.
- Examined differences in player activity and monetization across engagement segments.
- Evaluated payer conversion differences between A/B test groups to inform product decisions.
Authentication events are used as an indicator of player activity and should not be interpreted as gameplay sessions.

**Product Strategy**

The project translates analytical findings into product improvement opportunities, including feature prioritization using the RICE framework and a proposed retention-focused initiative supported by KPI definitions, event tracking requirements, and an A/B test design.

The proposed feature and experiment design are recommendations, not implemented product changes.

Project Files
- [Full Project Report](Gamelytics_Project_Report.pdf)
- [SQL Analysis](sql/Gamelytics_Data_Analysis.sql)
- [Power BI Dashboard (PDF)](powerbi/Gamelytics_Product_Analytics_Dashboard.pdf)
- [Power BI Source File](powerbi/Gamelytics_Product_Analytics_Dashboard.pbix)

**Data Source**

Source: Gamelytics: Mobile Analytics Challenge – Kaggle

Dataset Publisher: debs2x

Description

reg_data.csv: Player registration records and timestamps

auth_data.csv: Player authentication events and timestamps

ab_test.csv: A/B test group assignments and player revenue

The project examines approximately 1 million player registrations and 9.6 million authentication events.

Data interpretation: Authentication events are used as a proxy for player activity. They should not be interpreted as gameplay sessions or measures of actual time spent playing.

**Project Scope**

Independent portfolio project developed to demonstrate practical skills in product analytics, business intelligence, and data-informed product management.
