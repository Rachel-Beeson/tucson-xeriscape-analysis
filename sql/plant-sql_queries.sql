-- ===============================================
-- TUCSON XERISCAPING ANALYSIS - SQL QUERIES
-- Author: Rachel Beeson
-- Date: July 2025
-- Database: PostgreSQL
-- ===============================================


-- TABLE CREATION QUERIES
-- ===============================================


-- Main Plants Table
CREATE TABLE plants (
    scientific_name VARCHAR(255),
    common_names TEXT,
    family VARCHAR(100),
    duration VARCHAR(50),
    habit VARCHAR(100),
    size_category VARCHAR(50),
    bloom_color VARCHAR(100),
    fragrant VARCHAR(3),
    bloom_months VARCHAR(100),
    native_yn VARCHAR(3),
    native_habitat TEXT,
    ecological_plant_groups TEXT,
    water_use VARCHAR(50),
    light_requirement VARCHAR(100),
    calcium_carbonate_tolerance VARCHAR(50),
    drought_tolerance VARCHAR(50),
    soil_types TEXT,
    watering VARCHAR(100),
    heat_tolerance VARCHAR(50),
    yard_use_category TEXT,
    wildlife_insect_attraction TEXT,
    toxic_to_humans VARCHAR(3),
    toxic_to_pets VARCHAR(3),
    toxic_parts TEXT,
    retailer_nursery_source TEXT,
    price_avg_range VARCHAR(100),
    sizes_available TEXT,
    shopping_notes_status TEXT,
    image VARCHAR(500),
    page_link_href VARCHAR(500)
);


-- Microclimate Zones Table
CREATE TABLE microclimate_zones (
    location_category VARCHAR(100),
    specific_areas VARCHAR(255),
    heat_level VARCHAR(50),
    water_access VARCHAR(50),
    microclimate_notes TEXT,
    plant_category_match VARCHAR(100)
);


-- Tucson Soil Data Table
CREATE TABLE tucson_soil (
    area VARCHAR(100),
    soil_caco3_content VARCHAR(50),
    texture TEXT,
    drainage VARCHAR(50),
    chemical_mineral TEXT,
    ecological_context TEXT
);


-- Tucson Rainfall Data Table
CREATE TABLE tucson_rainfall (
    area VARCHAR(50),
    annual_total_in DECIMAL(4,2),
    jan DECIMAL(3,2),
    feb DECIMAL(3,2),
    mar DECIMAL(3,2),
    apr DECIMAL(3,2),
    may DECIMAL(3,2),
    jun DECIMAL(3,2),
    jul DECIMAL(3,2),
    aug DECIMAL(3,2),
    sep DECIMAL(3,2),
    oct DECIMAL(3,2),
    nov DECIMAL(3,2),
    dec DECIMAL(3,2)
);


-- CORE ANALYSIS QUERIES
-- ===============================================


-- 1. Water Use Breakdown Analysis
SELECT 
    water_use, 
    COUNT(*) as plant_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM plants), 1) as percentage
FROM plants 
GROUP BY water_use 
ORDER BY plant_count DESC;


-- 2. Native vs Non-Native Analysis
SELECT 
    native_yn as native_status,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM plants), 1) as percentage
FROM plants 
GROUP BY native_yn
ORDER BY count DESC;


-- 3. Plant Family Diversity Analysis
SELECT 
    family, 
    COUNT(*) as count
FROM plants 
GROUP BY family 
ORDER BY count DESC 
LIMIT 10;


-- 4. Water Efficiency by Native Status
SELECT 
    native_yn,
    water_use,
    COUNT(*) as count
FROM plants 
GROUP BY native_yn, water_use
ORDER BY native_yn, water_use;


-- 5. Heat Tolerance Distribution
SELECT 
    heat_tolerance, 
    COUNT(*) as plant_count
FROM plants 
GROUP BY heat_tolerance
ORDER BY plant_count DESC;


-- PRICING AND BUDGET ANALYSIS
-- ===============================================


-- 6. Price Data Availability
SELECT 
    CASE 
        WHEN price_avg_range = '—' OR price_avg_range IS NULL OR price_avg_range = 'Not found' 
        THEN 'No price data'
        ELSE 'Has price data'
    END as price_status,
    COUNT(*) as count
FROM plants
GROUP BY price_status;


-- 7. Budget-Friendly Plant Options (Family Safe)
SELECT 
    scientific_name, 
    common_names, 
    water_use, 
    price_avg_range
FROM plants 
WHERE water_use = 'Low' 
    AND toxic_to_humans = 'Not toxic' 
    AND toxic_to_pets = 'Not toxic'
    AND (price_avg_range LIKE '$6%' OR price_avg_range LIKE '$7%' OR price_avg_range LIKE '$8%')
ORDER BY price_avg_range
LIMIT 10;


-- SEASONAL BLOOM ANALYSIS
-- ===============================================


-- 8. Monthly Bloom Count Analysis
SELECT 
    'January' as month, COUNT(*) as bloom_count, 1 as sort_order
FROM plants 
WHERE bloom_months LIKE '%Jan%'
UNION ALL
SELECT 'February', COUNT(*), 2 FROM plants WHERE bloom_months LIKE '%Feb%'
UNION ALL
SELECT 'March', COUNT(*), 3 FROM plants WHERE bloom_months LIKE '%Mar%'
UNION ALL
SELECT 'April', COUNT(*), 4 FROM plants WHERE bloom_months LIKE '%Apr%'
UNION ALL
SELECT 'May', COUNT(*), 5 FROM plants WHERE bloom_months LIKE '%May%'
UNION ALL
SELECT 'June', COUNT(*), 6 FROM plants WHERE bloom_months LIKE '%Jun%'
UNION ALL
SELECT 'July', COUNT(*), 7 FROM plants WHERE bloom_months LIKE '%Jul%'
UNION ALL
SELECT 'August', COUNT(*), 8 FROM plants WHERE bloom_months LIKE '%Aug%'
UNION ALL
SELECT 'September', COUNT(*), 9 FROM plants WHERE bloom_months LIKE '%Sep%'
UNION ALL
SELECT 'October', COUNT(*), 10 FROM plants WHERE bloom_months LIKE '%Oct%'
UNION ALL
SELECT 'November', COUNT(*), 11 FROM plants WHERE bloom_months LIKE '%Nov%'
UNION ALL
SELECT 'December', COUNT(*), 12 FROM plants WHERE bloom_months LIKE '%Dec%'
ORDER BY sort_order;


-- 9. Monsoon Season Bloomers (July-September)
SELECT 
    scientific_name, 
    common_names, 
    bloom_months, 
    water_use
FROM plants 
WHERE bloom_months LIKE '%Jul%' 
   OR bloom_months LIKE '%Aug%' 
   OR bloom_months LIKE '%Sep%'
ORDER BY water_use, scientific_name;


-- 10. Winter Interest Plants (January-February Bloomers)
SELECT 
    scientific_name, 
    common_names, 
    bloom_months, 
    water_use
FROM plants 
WHERE bloom_months LIKE '%Jan%' 
   OR bloom_months LIKE '%Feb%'
ORDER BY bloom_months;


-- SAFETY AND FAMILY-FRIENDLY ANALYSIS
-- ===============================================


-- 11. Toxicity Safety Analysis
SELECT 
    toxic_to_humans, 
    toxic_to_pets, 
    COUNT(*) as count
FROM plants 
GROUP BY toxic_to_humans, toxic_to_pets
ORDER BY count DESC;


-- 12. Family-Safe Plant Options by Price Range
SELECT 
    scientific_name, 
    common_names, 
    water_use, 
    price_avg_range
FROM plants 
WHERE toxic_to_humans = 'Not toxic' 
    AND toxic_to_pets = 'Not toxic'
    AND water_use = 'Low'
ORDER BY price_avg_range;


-- MICROCLIMATE AND IMPLEMENTATION ANALYSIS
-- ===============================================


-- 13. Plant Options by Microclimate Zone
SELECT 
    m.location_category,
    m.heat_level,
    m.plant_category_match,
    COUNT(DISTINCT p.scientific_name) as available_plants
FROM microclimate_zones m
LEFT JOIN plants p ON p.heat_tolerance = m.plant_category_match
GROUP BY m.location_category, m.heat_level, m.plant_category_match
ORDER BY available_plants DESC;


-- 14. Soil Characteristics Analysis
SELECT 
    soil_caco3_content, 
    drainage, 
    COUNT(*) as areas
FROM tucson_soil
GROUP BY soil_caco3_content, drainage;


-- SEASONAL RAINFALL PATTERNS
-- ===============================================


-- 15. Seasonal Rainfall Analysis
SELECT 
    area,
    annual_total_in,
    (jan + feb + mar) as winter_spring,
    (apr + may + jun) as late_spring_early_summer,
    (jul + aug + sep) as monsoon_season,
    (oct + nov + dec) as fall_winter
FROM tucson_rainfall
ORDER BY annual_total_in;


-- WATERING REQUIREMENTS ANALYSIS
-- ===============================================


-- 16. Watering Category Distribution
SELECT 
    watering, 
    COUNT(*) as plant_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM plants), 1) as percentage
FROM plants 
GROUP BY watering
ORDER BY plant_count DESC;


-- 17. Water Independence by Heat Tolerance
SELECT 
    watering,
    heat_tolerance,
    COUNT(*) as plants,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM plants), 1) as percentage_of_total
FROM plants 
GROUP BY watering, heat_tolerance
ORDER BY watering, heat_tolerance;


-- BUSINESS INTELLIGENCE QUERIES
-- ===============================================


-- 18. Top Budget Plants for Each Heat Zone
SELECT 
    heat_tolerance,
    scientific_name,
    common_names,
    water_use,
    price_avg_range
FROM plants 
WHERE toxic_to_humans = 'Not toxic' 
    AND toxic_to_pets = 'Not toxic'
    AND (price_avg_range LIKE '$6%' OR price_avg_range LIKE '$7%' OR 
         price_avg_range LIKE '$8%' OR price_avg_range LIKE '$9%' OR 
         price_avg_range LIKE '$10%' OR price_avg_range LIKE '$11%' OR
         price_avg_range LIKE '$12%' OR price_avg_range LIKE '$13%' OR
         price_avg_range LIKE '$14%' OR price_avg_range LIKE '$15%')
ORDER BY heat_tolerance, price_avg_range;


-- 19. Nursery Availability Analysis
SELECT 
    retailer_nursery_source as nursery,
    COUNT(*) as plants_available
FROM plants 
WHERE retailer_nursery_source IS NOT NULL 
    AND retailer_nursery_source != ''
    AND retailer_nursery_source != 'Not found'
GROUP BY retailer_nursery_source
ORDER BY plants_available DESC;


-- 20. Complete Plant Recommendation Summary
SELECT 
    scientific_name,
    common_names,
    heat_tolerance,
    water_use,
    watering,
    price_avg_range,
    bloom_months,
    native_yn,
    toxic_to_humans,
    toxic_to_pets,
    retailer_nursery_source
FROM plants 
WHERE toxic_to_humans = 'Not toxic' 
    AND toxic_to_pets = 'Not toxic'
    AND price_avg_range IS NOT NULL
    AND price_avg_range != '—'
    AND price_avg_range != 'Not found'
ORDER BY heat_tolerance, water_use, price_avg_range;