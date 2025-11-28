SELECT COUNT(*) AS customers_count
FROM customers;

-- top_10_total_income
WITH sellers AS (
    SELECT
        e.employee_id AS seller_id,
        (e.first_name || ' ' || e.last_name) AS seller
    FROM employees AS e
)SELECT
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
)SELECT
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
)SELECT
    seller,
    day_of_week,
    FLOOR(income) AS income
FROM weekdays_income_with_numbers;
