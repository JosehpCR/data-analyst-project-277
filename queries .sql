-- customers_count
SELECT COUNT(customer_id) FROM customers;

-- top_10_total_income
WITH sellers AS (
    SELECT
        e.employee_id AS seller_id,
        (e.first_name || ' ' || e.last_name) AS seller
    FROM employees AS e
)

SELECT
    sellers.seller,
    COUNT(*) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sellers
INNER JOIN sales AS s ON sellers.seller_id = s.sales_person_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- avg_department_income = 267166
SELECT FLOOR(AVG(s.quantity * p.price))
FROM
    sales AS s
INNER JOIN products AS p ON
    s.product_id = p.product_id;

-- lowest_average_income
WITH sellers AS (
    SELECT
        e.employee_id AS seller_id,
        (
            e.first_name || ' ' || e.last_name
        ) AS seller
    FROM
        employees AS e
),

sellers_average_income AS (
    SELECT
        sellers.seller,
        AVG(s2.quantity * p2.price) AS average_income,
        (
            SELECT AVG(s3.quantity * p3.price)
            FROM
                sales AS s3
            INNER JOIN products AS p3 ON
                s3.product_id = p3.product_id
        ) AS avg_department_income
    FROM sellers

    INNER JOIN sales AS s2
        ON
            sellers.seller_id = s2.sales_person_id
    INNER JOIN products AS p2
        ON
            s2.product_id = p2.product_id
    GROUP BY 1
)

SELECT
    s.seller,
    FLOOR(s.average_income) AS average_income
FROM sellers_average_income AS s
WHERE s.average_income < s.avg_department_income

ORDER BY 2 ASC;

-- day_of_the_week_income
WITH weekdays_income_with_numbers AS (
    SELECT
        (e.first_name || ' ' || e.last_name) AS seller,
        EXTRACT(ISODOW FROM s.sale_date) AS weekday_number,
        TRIM(TO_CHAR(s.sale_date, 'day')) AS day_of_week,
        SUM(s.quantity * p.price) AS income
    FROM employees AS e
    INNER JOIN sales AS s
        ON
            e.employee_id = s.sales_person_id
    INNER JOIN products AS p
        ON
            s.product_id = p.product_id
    GROUP BY 2, 1, 3
)

SELECT
    seller,
    day_of_week,
    FLOOR(income) AS income
FROM weekdays_income_with_numbers;

-- age_groups
SELECT
    (
        CASE
            WHEN
                c.age >= 16
                AND c.age <= 25 THEN '16-25'
            WHEN
                c.age >= 26
                AND c.age <= 40 THEN '26-40'
            ELSE '40+'
        END
    ) AS age_category,
    COUNT(c.age) AS age_count
FROM
    customers AS c
GROUP BY 1
ORDER BY 1;

-- customers_by_month
SELECT
    TO_CHAR(s.sale_date, 'yyyy-mm') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY 1;

-- special_offer
WITH sales_with_number AS (
    SELECT
        c.customer_id,
        s.sale_date,
        p.price,
        (c.first_name || ' ' || c.last_name) AS customer,
        (e.first_name || ' ' || e.last_name) AS seller,
        ROW_NUMBER()
            OVER (
                PARTITION BY c.customer_id
                ORDER BY s.sale_date ASC
            )
            AS rn
    FROM
        customers AS c
    INNER JOIN sales AS s
        ON
            c.customer_id = s.customer_id
    INNER JOIN products AS p
        ON
            s.product_id = p.product_id
    INNER JOIN employees AS e ON
        s.sales_person_id = e.employee_id
)

SELECT
    swn.customer,
    swn.sale_date,
    swn.seller
FROM sales_with_number AS swn
WHERE swn.rn = 1 AND swn.price = 0
ORDER BY 1;
