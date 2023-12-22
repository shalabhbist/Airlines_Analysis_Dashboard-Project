-- Step - 1 : Create Database
CREATE DATABASE P305;
USE P305;

-- Step - 2 : Create the table
CREATE TABLE IF NOT EXISTS MainData_Final (
    airline_id INT,
    carrier_group_id INT,
    unique_carrier_code VARCHAR(8),
    unique_carrier_entity_code INT,
    region_code VARCHAR(8),
    origin_airport_id INT,
    origin_airport_sequence_id INT,
    origin_airport_market_id INT,
    origin_world_area_code INT,
    destination_airport_id INT,
    destination_airport_sequence_id INT,
    destination_airport_market_id INT,
    destination_world_area_code INT,
    aircraft_group_id INT,
    aircraft_type_id INT,
    aircraft_configuration_id INT,
    distance_group_id INT,
    service_class_id VARCHAR(8),
    datasource_id VARCHAR(8),
    departures_scheduled INT,
    departures_performed INT,
    payload INT,
    distance INT,
    available_seats INT,
    transported_passengers INT,
    transported_freight INT,
    transported_mail INT,
    ramp_to_ramp_time INT,
    air_time INT,
    unique_carrier VARCHAR(100),
    carrier_code VARCHAR(8),
    carrier_name VARCHAR(100),
    origin_airport_code VARCHAR(5),
    origin_city VARCHAR(50),
    origin_state_code VARCHAR(8),
    origin_state_fips VARCHAR(8),
    origin_state VARCHAR(50),
    origin_country_code VARCHAR(5),
    origin_country VARCHAR(50),
    destination_airport_code VARCHAR(8),
    destination_city VARCHAR(50),
    destination_state_code VARCHAR(8),
    destination_state_fips VARCHAR(8),
    destination_state VARCHAR(50),
    destination_country_code VARCHAR(8),
    destination_country VARCHAR(50),
    YEAR INT,
    MONTH INT,
    DAY INT,
    from_to_airport_code VARCHAR(11),
    from_to_airport_id VARCHAR(17),
    from_to_city VARCHAR(100),
    from_to_state_code VARCHAR(8),
    from_to_state VARCHAR(100)
);

-- Step - 3 : Paste file 'MainData_Final.csv' in mysql workbench data folder

-- Step - 4 : Import by using following query

LOAD DATA INFILE 'MainData_Final.csv' INTO TABLE MainData_Final  -- load data in this table
FIELDS TERMINATED BY ',' -- where , is used as delimator
IGNORE 1 LINES; -- ignores 1st line which are headings

-- Step - 5 : Import all '.csv' files
    -- for some headings you get this "ï»¿"
    -- to fix follow step 6
    
-- Step 6 : Fix Headings
SHOW TABLES;
-- ======================================================================
-- 1
SELECT * FROM `flight types`;
ALTER TABLE `flight types` CHANGE `ï»¿%Datasource ID` `%Datasource_id` VARCHAR(2);

-- 2
SELECT * FROM `aircraft groups`;
ALTER TABLE `aircraft groups` CHANGE `ï»¿%Aircraft Group ID` `%Aircraft_Group_ID` INT;

-- 3
SELECT * FROM `aircraft types`;
ALTER TABLE `aircraft types` CHANGE `ï»¿%Aircraft Type ID` `%Aircraft_Type_ID` INT;

-- 4
SELECT * FROM `airlines`;
ALTER TABLE `airlines` CHANGE `ï»¿%Airline ID` `%Airline_ID` INT;

-- 5
SELECT * FROM `carrier groups`;
ALTER TABLE `carrier groups` CHANGE `ï»¿%Carrier Group ID` `%Carrier_Group_ID` INT;

-- 6
SELECT * FROM `carrier operating region`;
ALTER TABLE `carrier operating region` CHANGE `ï»¿%Region Code` `%Region_Code` INT; -- check

-- 7
SELECT * FROM `destination markets`;

-- 8 
SELECT * FROM `distance groups`;
ALTER TABLE `distance groups` CHANGE `ï»¿%Distance Group ID` `%Distance_Group_ID` INT;

-- 9 
SELECT * FROM `origin markets`;

-- ==============================================================================================================

-- KPI - 1

-- Add new columns to existing table
ALTER TABLE MainData_Final
ADD COLUMN monthno INT,
ADD COLUMN monthfullname VARCHAR(20),
ADD COLUMN QUARTER VARCHAR(2),
ADD COLUMN yearmonth VARCHAR(8),
ADD COLUMN weekdayno INT,
ADD COLUMN weekdayname VARCHAR(20),
ADD COLUMN financialmonth INT,
ADD COLUMN financialquarter VARCHAR(2);

-- Update the new columns based on existing data
-- Update Monthno
UPDATE MainData_Final
SET
    monthno = MONTH(STR_TO_DATE(CONCAT(YEAR, '-', LPAD(MONTH, 2, '00'), '-01'), '%Y-%m-%d'));
UPDATE MainData_Final

-- Update MonthFullName
SET
    monthfullname = DATE_FORMAT(CONCAT(YEAR, '-', LPAD(MONTH, 2, '00'), '-01'), '%M');
    
-- Update Quarter
UPDATE MainData_Final
SET
    QUARTER = CONCAT('Q', QUARTER(STR_TO_DATE(CONCAT(YEAR, '-', LPAD(MONTH, 2, '00'), '-01'), '%Y-%m-%d')));
    
-- Update Year Month
UPDATE MainData_Final
SET
    yearmonth = DATE_FORMAT(CONCAT(YEAR, '-', LPAD(MONTH, 2, '00'), '-01'), '%Y-%b');
    
-- Update weekday no
UPDATE MainData_Final
SET
    weekdayno = DAYOFWEEK(CONCAT(YEAR, '-', LPAD(MONTH, 2, '00'), '-01'));
    
-- Update weekdayname
UPDATE MainData_Final
SET
    weekdayname = DAYNAME(CONCAT(YEAR, '-', LPAD(MONTH, 2, '00'), '-01'));
    
-- Update financialmonth
UPDATE MainData_Final
SET
    financialmonth = IF(MONTH >= 4, MONTH - 3, MONTH + 9);
    
--Update financialquarter
UPDATE MainData_Final
SET financialquarter = CONCAT('Q', QUARTER(STR_TO_DATE(CONCAT('2000-', LPAD(financialmonth, 2, '00'), '-01'), '%Y-%m-%d')));

-- Add index on the Year, Month, and Day columns for better performance in date-based queries
CREATE INDEX idx_date ON MainData_Final (YEAR, MONTH, DAY);

SHOW TABLES;
SELECT * FROM `maindata_final`;

-- CUSTOM
ALTER TABLE `maindata_final`
ADD COLUMN `COMBINED DATE` DATE;

-- ADD CUSTOM DATE
UPDATE `maindata_final`
SET `COMBINED DATE` = STR_TO_DATE(CONCAT(`Year`, '-', LPAD(`Month`, 2, '0'), '-', LPAD(`Day`, 2, '0')), '%Y-%m-%d');

-- FINANCIAL YEAR
ALTER TABLE `maindata_final`
ADD COLUMN `Financial Year` VARCHAR(9);

-- Update the FinancialYear column with the calculated financial year
UPDATE maindata_final
SET `Financial Year` = CASE
    WHEN MONTH(`COMBINED DATE`) >= 4 THEN CONCAT(YEAR(`COMBINED DATE`), '-', YEAR(`COMBINED DATE`) + 1)
    ELSE CONCAT(YEAR(`COMBINED DATE`) - 1, '-', YEAR(`COMBINED DATE`))
END;

-- %LOAD FACTOR
ALTER TABLE `maindata_final` 
ADD COLUMN `%LOAD FACTOR` DECIMAL(3, 2);

ALTER TABLE `maindata_final` 
DROP COLUMN `%LOAD FACTOR`;

SELECT * FROM `maindata_final`;

-- %LOAD FACTOR QUERY
UPDATE `maindata_final`
SET `%LOAD FACTOR` = IF(available_seats > 0, transported_passengers / available_seats, 0);




-- Add a new column named WeekEndOrWeekDay
ALTER TABLE MainData_Final
ADD COLUMN WeekEndOrWeekDay VARCHAR(9);

-- Update the WeekEndOrWeekDay column based on the day of the week
UPDATE MainData_Final
SET WeekEndOrWeekDay = CASE
    WHEN DAYOFWEEK(CONCAT(YEAR, '-', LPAD(MONTH, 2, '00'), '-01')) IN (1, 7) THEN 'WEEKEND'
    ELSE 'WEEKDAY'
END;


--  
SELECT * FROM `maindata_final`;

-- KPI 2

-- YEARLY

SELECT 
    `year`,
    CONCAT(ROUND(AVG(`%LOAD FACTOR`)* 100, 2), '%') AS lf
FROM 
    `maindata_final`
GROUP BY 
    `year`;


SELECT  
    `year`,
    CONCAT(ROUND(SUM(transported_passengers) / SUM(available_seats) * 100, 2), '%') AS LoadFactor
FROM 
    `maindata_final`
GROUP BY 
    `year`;

-- MONTHLY

SELECT 
    `monthfullname`,
    CONCAT(ROUND(SUM(transported_passengers) / SUM(available_seats) * 100, 2), '%') AS LoadFactor
FROM `maindata_final`
GROUP BY `monthfullname`
ORDER BY 
    CASE 
        WHEN `monthfullname` = 'January' THEN 1
        WHEN `monthfullname` = 'February' THEN 2
        WHEN `monthfullname` = 'March' THEN 3
        WHEN `monthfullname` = 'April' THEN 4
        WHEN `monthfullname` = 'May' THEN 5
        WHEN `monthfullname` = 'June' THEN 6
        WHEN `monthfullname` = 'July' THEN 7
        WHEN `monthfullname` = 'August' THEN 8
        WHEN `monthfullname` = 'September' THEN 9
        WHEN `monthfullname` = 'October' THEN 10
        WHEN `monthfullname` = 'November' THEN 11
        WHEN `monthfullname` = 'December' THEN 12
    END,
    `monthfullname`;


-- Quarterly

SELECT 
    `quarter`,
    CONCAT(ROUND(SUM(transported_passengers) / SUM(available_seats) * 100, 2), '%') AS LoadFactor
FROM `maindata_final`
GROUP BY `quarter`
ORDER BY `quarter` ;


-- KPI 3 - Find the load Factor percentage on a Carrier Name basis.

SELECT 
    `carrier_name`,
    COALESCE(
        CONCAT(
            ROUND(
                SUM(COALESCE(transported_passengers, 0)) / 
                NULLIF(SUM(COALESCE(available_seats, 1)), 0) * 100, 
                2
            ), 
            '%'
        ),
        '0%'
    ) AS LoadFactor
FROM 
    `maindata_final`
GROUP BY 
    `carrier_name`
ORDER BY 
    LoadFactor;



-- KPI 4 - Identify Top 10 Carrier Names based passengers preference 

SELECT 
    `carrier_name`,
    SUM(`transported_passengers`) AS TotalTransportedPassengers
FROM `maindata_final`
GROUP BY `carrier_name`
ORDER BY TotalTransportedPassengers DESC
LIMIT 10;

-- KPI 5 - Display top Routes ( from-to City) based on Number of Flights 

SELECT 
    `from_to_city`,
    `airline_id`,
    COUNT(*) AS NumberOfFlights
FROM `maindata_final`
GROUP BY `from_to_city`, `airline_id`
ORDER BY NumberOfFlights DESC;

-- KPI 6 - Identify the how much load factor is occupied on Weekend vs Weekdays.
DESC `maindata_final`;

SELECT 
    `WeekEndOrWeekDay`,
    ROUND(AVG(`maindata_final`.`%LOAD FACTOR`) * 100, 2) AS LOADFACTOR
FROM `maindata_final`
GROUP BY `WeekEndOrWeekDay`;


-- KPI 7 -
/* 
Use the filter to provide a search capability to find the flights between Source Country, Source State, Source City to Destination Country , Destination State, Destination City
*/

SELECT  
    `origin_country`,
    `origin_state`,
    `origin_city`,
    `destination_country`,
    `destination_state`,
    `destination_city`,
    `COMBINED DATE`,
    `WeekEndOrWeekDay`,
    ROUND(AVG(`%LOAD FACTOR`) * 100, 2) AS LOADFACTOR
FROM `maindata_final`
GROUP BY `origin_country`, `origin_state`, `origin_city`, `destination_country`, `destination_state`, `destination_city`, `COMBINED DATE`, `WeekEndOrWeekDay`;


---------------------------

-- KPI - 7
SELECT  
    `origin_country`,
    `origin_state`,
    `origin_city`,
    `destination_country`,
    `destination_state`,
    `destination_city`,
    `COMBINED DATE`,
    `WeekEndOrWeekDay`,
    ROUND(AVG(`%LOAD FACTOR`) * 100, 2) AS LOADFACTOR
FROM `maindata_final`
WHERE
    `origin_country` = 'United States' AND
    `destination_country` = 'Canada'
GROUP BY 
    `origin_country`, `origin_state`, `origin_city`, 
    `destination_country`, `destination_state`, `destination_city`, 
    `COMBINED DATE`, `WeekEndOrWeekDay`;


-- OR

CALL get_Countries('United States','Canada');



-- KPI 8 - Identify number of flights based on Distance groups
SELECT * FROM `maindata_final`;
DESC `distance groups`;

SELECT
    `distance groups`.`Distance Interval` AS Distance_Interval,
    COUNT(`maindata_final`.airline_id) AS Total_Flights
FROM
    `maindata_final`
JOIN
    `distance groups` ON `maindata_final`.distance_group_id = `distance groups`.`%Distance_Group_ID`
GROUP BY
    `distance groups`.`%Distance_Group_ID`, `distance groups`.`Distance Interval`;




