USE magist;

-- List of categories with number of respective products
SELECT product_category_name, count(1)
FROM order_items
JOIN products USING(product_id)
group by product_category_name;

-- What categories of tech products does Magist have?
-- We selected the following:
SET @tech_categories = (SELECT GROUP_CONCAT(product_category_name)
FROM product_category_name_translation
WHERE product_category_name IN
 ('cool_stuff',
'eletronicos',
'informatica_acessorios',
'pcs',
'consoles_games',
'pc_gamer', -- little sales
'relogios_presentes',
'seguros_e_servicos', -- little sales 
'tablets_impressao_imagem'));
SELECT @tech_categories;

-- English names of selected categories
SELECT * FROM product_category_name_translation
WHERE FIND_IN_SET(product_category_name, @tech_categories);

-- Define mapping of categories to 'tech' and 'other' super-category
SELECT *,
    CASE
        WHEN FIND_IN_SET(product_category_name, @tech_categories) > 0 THEN 'tech'
        ELSE 'other'
    END AS super_category
FROM
    product_category_name_translation;

-- Temporary table of tech products
DROP TABLE IF EXISTS tech_products;
CREATE TEMPORARY TABLE tech_products (UNIQUE (product_id)) AS
SELECT DISTINCT product_id
FROM order_items
JOIN products USING (product_id)
WHERE find_in_set(product_category_name, @tech_categories);

-- Number of months covered in the database
-- >> 25
SET @months = (SELECT 
    TIMESTAMPDIFF(MONTH,
        MIN(order_purchase_timestamp),
        MAX(order_purchase_timestamp))
        AS months_in_orders
FROM
    orders);
SELECT @months;

-- Temporary table of per-seller totals (sales and payments for tech vs. other)
DROP TABLE IF EXISTS seller_totals;
CREATE TEMPORARY TABLE seller_totals (UNIQUE (seller_id)) AS
WITH seller_sums AS (
	SELECT seller_id,
		COUNT(DISTINCT order_id) AS order_count,
		AVG(price) AS avg_price, 
		AVG(IF(find_in_set(product_category_name, @tech_categories), price, NULL)) AS avg_tech_price,
		SUM(price) AS total_sales, 
		SUM(IF(find_in_set(product_category_name, @tech_categories), price, 0)) AS tech_sales
	FROM order_items
	JOIN products USING (product_id)
	JOIN orders USING (order_id)
	WHERE order_status NOT IN ('canceled', 'unavailable')
	GROUP BY seller_id
ORDER BY seller_id
)
SELECT *, 
	total_sales / @months AS total_monthly, tech_sales / total_sales AS tech_ratio
FROM seller_sums;

SELECT * from seller_totals;

-- Temporary table identifying sellers as tech sellers by tech sales ratio
DROP TABLE IF EXISTS tech_sellers_by_tech_ratio;
CREATE TEMPORARY TABLE tech_sellers_by_tech_ratio (UNIQUE (seller_id)) AS (
	SELECT DISTINCT seller_id
    FROM seller_totals
    WHERE tech_ratio > 0.5
);
-- >> 344 sellers in tech_sellers_by_tech_ratio
SELECT COUNT(1) FROM tech_sellers_by_tech_ratio;

-- Temporary table identifying sellers as tech sellers if they ever sold a tech product
DROP TABLE IF EXISTS tech_sellers_any_tech_product;
CREATE TEMPORARY TABLE tech_sellers_any_tech_product (UNIQUE (seller_id)) AS (
	SELECT DISTINCT seller_id
    FROM order_items
    JOIN products USING (product_id)
    WHERE FIND_IN_SET(product_category_name, @tech_categories)
);

-- >> 649 sellers in tech_sellers_any_tech_product
SELECT COUNT(1) FROM tech_sellers_any_tech_product;

-- 3.1. In relation to the products:
-- What categories of tech products does Magist have?
-- How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?
-- What’s the average price of the products being sold?

-- Are expensive tech products popular? *
-- Idea: Let's look at a histogram
SET @bin_width_fine = 50;
SET @bin_width_coarse = 250;
SET @bin_limit_coarse = 1000;
SET @total_ordered = (SELECT COUNT(1) FROM order_items);
SET @tech_ordered = (SELECT COUNT(1) FROM order_items INNER JOIN tech_products USING (product_id) );
SET @total_sales = (SELECT SUM(price) FROM order_items);
SET @tech_sales = (SELECT SUM(price) FROM order_items INNER JOIN tech_products p USING(product_id) );
SELECT 
	CASE 
		WHEN price < @bin_limit_coarse THEN TRUNCATE(price / @bin_width_fine, 0) * @bin_width_fine
		ELSE TRUNCATE(price / @bin_width_coarse, 0) * @bin_width_coarse
	END
    AS price_category,
    MIN(price),
    MAX(price),
    COUNT(1) AS ordered_total,
    COUNT(1) / @total_ordered AS ordered_total_fraction,
    SUM(FIND_IN_SET(p.product_category_name,
            @tech_categories) != 0) AS ordered_tech,
    SUM(FIND_IN_SET(p.product_category_name,
            @tech_categories) != 0) / @tech_ordered AS ordered_tech_fraction,
    ROUND(SUM(price)) AS sales_total,
    ROUND(SUM(price) / @total_sales, 4) AS sales_total_fraction,
    ROUND(SUM(price * (FIND_IN_SET(p.product_category_name,
                    @tech_categories) != 0))) AS sales_tech,
    ROUND(SUM(price * (FIND_IN_SET(p.product_category_name,
                    @tech_categories) != 0)) / @tech_sales,
            4) AS sales_tech_fraction
FROM
    order_items i
        LEFT JOIN
    products p USING (product_id)
GROUP BY price_category
ORDER BY price_category;

-- 3.2. In relation to the sellers:
-- How many months of data are included in the magist database?
-- >> 25
-- (Calculated before)
SELECT @months;
    
-- Date range covered
SELECT 
	MIN(order_purchase_timestamp),
    MAX(order_purchase_timestamp),
    TIMESTAMPDIFF(MONTH,
        MIN(order_purchase_timestamp),
        MAX(order_purchase_timestamp))
        AS months_in_orders
FROM
    orders;
    
-- How many sellers are there? 
-- >> 3095
SET @total_seller_count = (SELECT COUNT(1) AS total_sellers FROM sellers);
SELECT @total_seller_count;
-- How many Tech sellers are there? 
-- >> 344
SET @tech_seller_count = (
	SELECT COUNT(1) AS tech_sellers
	FROM tech_sellers_by_tech_ratio
);
SELECT  @tech_seller_count;

-- What percentage of overall sellers are Tech sellers?
-- >> 11 %
SELECT @total_seller_count, @tech_seller_count, @tech_seller_count / @total_seller_count * 100 as tech_sellers_percentage;

-- What is the total amount earned by all sellers? 
-- >> 13,494,401 
SET @total_earnings = (SELECT SUM(price) FROM order_items
LEFT JOIN orders o USING(order_id)
WHERE order_status NOT IN ('canceled', 'unavailable'));

-- What is the total amount earned by all Tech sellers?
-- >> 3,256,929 (24%)
SET @tech_earnings = (SELECT SUM(price) FROM order_items
LEFT JOIN orders o USING(order_id)
INNER JOIN tech_sellers_by_tech_ratio USING(seller_id)
WHERE order_status NOT IN ('canceled', 'unavailable'));

-- Results
SELECT @total_earnings, @tech_earnings, @tech_earnings / @total_earnings * 100 AS tech_earnings_percentage;

-- Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?
-- >> 174.40, 378.71
SELECT @total_earnings / @months / @total_seller_count AS total_income_monthly, @tech_earnings / @months / @tech_seller_count AS tech_income_monthly;

-- List of sellers and their earnings
SELECT seller_id, SUM(price) AS total_earning
FROM order_items
GROUP BY seller_id
ORDER BY total_earning;

-- Number of sellers with more than 2500 monthly sales
-- >> 18
SELECT COUNT(1)
FROM seller_totals
WHERE total_monthly > 2500
AND NOT EXISTS(SELECT 1 FROM tech_sellers_by_tech_ratio AS ts WHERE ts.seller_id = seller_totals.seller_id);

-- In general wrong (N-1-M relationship):
-- SELECT order_id, SUM(price), SUM(freight_value), SUM(payment_value)
-- FROM order_items
-- JOIN order_payments USING (order_id)
-- GROUP BY order_id;

-- seller quartiles (all)
WITH 
seller_quartiles AS (
	SELECT *, 
		NTILE(4) OVER (ORDER BY total_sales) AS quartile_by_total_sales
	FROM seller_totals
),
seller_quartile_sums AS (
	SELECT quartile_by_total_sales, 
		COUNT(1) AS seller_count, 
        AVG(order_count / @months) AS avg_monthly_order_count, 
        AVG(avg_price) AS avg_price, 
        AVG(avg_tech_price) AS avg_tech_price, 
        AVG(total_monthly) AS avg_monthly_sales, 
        SUM(total_sales) AS total_sales, 
        SUM(tech_sales) AS tech_sales
	FROM seller_quartiles
	GROUP BY quartile_by_total_sales
)
SELECT *, tech_sales / total_sales AS tech_ratio
FROM seller_quartile_sums;

-- seller quartiles (tech only)
WITH 
seller_quartiles AS (
	SELECT *, 
		NTILE(4) OVER (ORDER BY total_sales) AS quartile_by_total_sales
	FROM seller_totals
--    INNER JOIN tech_sellers_any_tech_product USING (seller_id)
    INNER JOIN tech_sellers_by_tech_ratio USING (seller_id)
),
seller_quartile_sums AS (
	SELECT quartile_by_total_sales, 
		COUNT(1) AS seller_count, 
        AVG(order_count / @months) AS avg_monthly_order_count, 
        AVG(avg_price) AS avg_price, 
        AVG(avg_tech_price) AS avg_tech_price, 
        AVG(total_monthly) AS avg_monthly_sales, 
        SUM(total_sales) AS total_sales, 
        SUM(tech_sales) AS tech_sales
	FROM seller_quartiles
	GROUP BY quartile_by_total_sales
)
SELECT *, tech_sales / total_sales AS tech_ratio
FROM seller_quartile_sums;

-- Number orders with tech items
-- >> 19806
select count(distinct order_id)
from order_items
join products p using(product_id) 
where FIND_IN_SET(p.product_category_name, @tech_categories);

-- Number of orders with any items
select count(distinct order_id)
from order_items
join products p using(product_id) 
-- where FIND_IN_SET(p.product_category_name, @tech_categories)
;

-- Average freight value
select avg(freight_value) from order_items;

-- List of order status values
select distinct order_status from orders;

-- Number of and average of review scores
-- >> 97770, 4.09
SELECT 
    COUNT(1), AVG(review_score)
FROM
    order_reviews
JOIN
    orders USING (order_id)
WHERE
    order_status NOT IN ('cancelled' , 'unavailable');
    
-- Number of and average of review scores for tech sellers
-- >> 21779, 4.00
SELECT 
    COUNT(1), AVG(review_score)
FROM
    order_reviews
JOIN
    orders USING (order_id)
JOIN
    order_items USING (order_id)
INNER JOIN
	tech_sellers_by_tech_ratio USING (seller_id)
JOIN
	seller_totals USING (seller_id)
WHERE
    order_status NOT IN ('cancelled' , 'unavailable')
	-- AND total_monthly > 2500
    ;

-- Number of and average of review scores for non-tech sellers
-- >> 89621, 4.03
SELECT 
    COUNT(1), AVG(review_score)
FROM
    order_reviews
JOIN
    orders USING (order_id)
JOIN
    order_items USING (order_id)
JOIN
	seller_totals USING (seller_id)
WHERE
    order_status NOT IN ('cancelled' , 'unavailable')
	and not exists (select 1 from tech_sellers_by_tech_ratio where tech_sellers_by_tech_ratio.seller_id = order_items.seller_id)
    ;

/* North = 'AC', 'AP','AM', 'RO', 'RR', 'TO', 'PA'
Northeast ='AL','BA', 'CE','MA','PE','PB','PI','RN', 'SE'
Central-West = 'DF','GO', 'MT', 'MS'
Southeast = 'RJ', 'SP', 'MG', 'ES' 
South = 'PR', 'RS', 'SC'
*/

-- Temporary table for mapping states to regions in Brazil
DROP TABLE IF EXISTS regions;
CREATE TEMPORARY TABLE regions (region varchar(255), state varchar(255), index(region), index(state), unique(region, state));
INSERT INTO regions (region, state)
SELECT DISTINCT 'North', state
FROM geo
WHERE state IN ('AC', 'AP','AM', 'RO', 'RR', 'TO', 'PA');
INSERT INTO regions (region, state)
SELECT DISTINCT 'Northeast', state
FROM geo
WHERE state IN ('AL','BA', 'CE','MA','PE','PB','PI','RN', 'SE');
INSERT INTO regions (region, state)
SELECT DISTINCT 'Central-West', state
FROM geo
WHERE state IN ('DF','GO', 'MT', 'MS');
INSERT INTO regions (region, state)
SELECT DISTINCT 'Southeast', state
FROM geo
WHERE state IN ('RJ', 'SP', 'MG', 'ES' );
INSERT INTO regions (region, state)
SELECT DISTINCT 'South', state
FROM geo
WHERE state IN ('PR', 'RS', 'SC');
INSERT INTO regions (region, state)
SELECT DISTINCT 'All', state
FROM geo;

SELECT * from regions;

-- Average delivery time from order time by region
SELECT region, COUNT(1) AS order_count, AVG(timestampdiff(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS avg_delivery_days
FROM orders
LEFT JOIN customers USING (customer_id)
LEFT JOIN geo ON zip_code_prefix = customer_zip_code_prefix
LEFT JOIN regions USING(state)
WHERE order_status = 'delivered'
GROUP BY region
ORDER BY region;

