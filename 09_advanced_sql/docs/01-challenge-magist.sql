WITH
selected_payments AS (
  SELECT *
  FROM order_payments
  WHERE payment_type = 'credit_card'
  AND payment_value >= 1000
),
selected_orders AS (
  SELECT *
  FROM orders
  WHERE YEAR(order_purchase_timestamp) = 2018
  AND order_status = 'delivered'
  AND EXISTS (
    SELECT 1
    FROM selected_payments
    WHERE selected_payments.order_id = orders.order_id
  )
),
selected_products AS (
  SELECT *
  FROM products
  LEFT JOIN product_category_name_translation USING(product_category_name)
  WHERE product_category_name_english IN ('health_beauty', 'perfumery')
  AND EXISTS (
    SELECT 1
    FROM order_items
    INNER JOIN selected_orders USING(order_id)
    WHERE order_items.product_id = products.product_id
  )
)
SELECT '1. average weight' AS property, AVG(product_weight_g) AS value
FROM selected_products
UNION
SELECT '2. seller city', city
FROM geo
WHERE EXISTS(
  SELECT 1
  FROM sellers
  JOIN order_items USING(seller_id)
  JOIN selected_products USING(product_id)
  WHERE sellers.seller_zip_code_prefix = geo.zip_code_prefix
)
UNION
SELECT '3. customer city', city
FROM geo
WHERE EXISTS(
  SELECT 1
  FROM customers
  JOIN orders USING(customer_id)
  JOIN order_items USING(order_id)
  JOIN selected_products USING(product_id)
  WHERE customers.customer_zip_code_prefix = geo.zip_code_prefix
)
ORDER BY property, value
;

