USE magist;

-- Total number of orders
-- >> 99441
SELECT count(1) FROM orders;

-- Number/percentage of orders by order_status
-- >> # order_status count percentage
-- >> delivered      96478    97.0203
-- >> unavailable      609     0.6124
-- >> shipped          107     1.1132
-- >> canceled         625     0.6285
-- >> invoiced         314     0.3158
-- >> processing       301     0.3027
-- >> approved           2     0.0020
-- >> created            5     0.0050
SELECT 
    order_status,
    COUNT(1) as count,
    COUNT(1) / sum(count(1)) over () * 100 AS percentage
FROM
    orders
GROUP BY order_status;

-- Development of order count
-- currently at -15% peak over a year
-- could look at seasonal change
SELECT 
    YEAR(order_purchase_timestamp) AS `year`,
    MONTH(order_purchase_timestamp) AS `month`,
    COUNT(1),
    count(1)/max(count(1)) over () * 100
    as orders_percent_peak
FROM
    orders
GROUP BY `year` , `month`
ORDER BY `year` , `month`;

-- Product count
-- plain count vs distinct count
SELECT 
    COUNT(1) AS row_count,
    COUNT(DISTINCT product_id) AS id_count, -- DISTINCT not meaningful because it is a unique column
    COUNT(DISTINCT product_category_name,
        product_name_length,
        product_description_length,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm) AS distinct_product_count
FROM
    products;

-- Categories with most products
SELECT 
    p.product_category_name,
    pcnt.product_category_name_english,
    COUNT(1) AS row_count,
    COUNT(DISTINCT p.product_category_name,
        product_name_length,
        product_description_length,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm) AS distinct_product_count
FROM
    products as p
JOIN product_category_name_translation as pcnt ON pcnt.product_category_name = p.product_category_name
GROUP BY product_category_name
ORDER BY distinct_product_count DESC
;

-- Products in transactions
SELECT 
    p.product_category_name,
    pcnt.product_category_name_english,
    COUNT(p.product_id) AS row_count,
    COUNT(DISTINCT p.product_category_name,
        product_name_length,
        product_description_length,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm) AS distinct_product_count,
	COUNT(p.product_id) 
		- SUM(EXISTS(SELECT oi.product_id FROM order_items AS oi WHERE oi.product_id = p.product_id))
        AS never_ordered_count
FROM
    products as p
LEFT JOIN product_category_name_translation as pcnt ON pcnt.product_category_name = p.product_category_name
GROUP BY product_category_name
ORDER BY distinct_product_count DESC
;

-- How many of those products were present in actual transactions?
-- >> All products are in at least one order
-- List all products that are not in any order
-- >> result empty
SELECT p.product_id
FROM products p
LEFT JOIN order_items i USING(product_id)
WHERE i.product_id IS NULL;

-- What’s the price for the most expensive and cheapest products?
-- >> 0.85, 6735
SELECT MIN(price), MAX(price)
FROM order_items;

-- Most expensive product and one of its orders
SELECT order_id, price, p.*
FROM order_items
LEFT JOIN products p USING(product_id)
ORDER BY price DESC
LIMIT 1;

-- What are the highest and lowest payment values?
-- >> 9.59, 13664.10
WITH op AS (
SELECT order_id, SUM(payment_value) AS payment
FROM order_payments
GROUP BY order_id )
SELECT MIN(payment), MAX(payment) FROM op
WHERE payment != 0;

-- Order with highest sum of payments
SELECT order_id, SUM(payment_value) AS payment
FROM order_payments
GROUP BY order_id
ORDER BY payment DESC
LIMIT 1;
