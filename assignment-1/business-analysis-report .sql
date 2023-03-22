# 1. ================ Customer Order Ranking Analysis in one year ======================================================


WITH TOTAL_ORDER_BY_CUSTOMER_IN_ONE_YEAR AS (SELECT o.O_CUSTKEY as cutomer_id,
                                                    COUNT(*)    AS total_order
                                             FROM orders AS o
                                             WHERE o.O_ORDERDATE BETWEEN '1996-01-01'
                                                 AND '1996-12-30'
                                               AND O_ORDERSTATUS = 'O' # O =  successfully order
                                             GROUP BY o.`O_CUSTKEY`)

select cutomer_id, total_order, dense_rank() over (order by total_order DESC ) as rank_number
from TOTAL_ORDER_BY_CUSTOMER_IN_ONE_YEAR;



# 2.================= Customer Coupon Analysis Based on Daily Total Amount in one day ==================================


WITH TOTAL_AMOUNT_BY_CUSTOMER_IN_PER_DAY AS
         (SELECT c.`C_NAME`          AS customer_name,
                 SUM(o.O_TOTALPRICE) AS total_price
          FROM orders AS o
                   JOIN customer AS c
                        ON o.O_CUSTKEY = c.`C_CUSTKEY`
          WHERE o.`O_ORDERDATE` = '1996-01-02'
          GROUP BY o.`O_CUSTKEY`
          LIMIT 10)
SELECT temp.customer_name,
       temp.total_price,
       CASE
           WHEN temp.total_price > 100000
               THEN '5%'
           WHEN temp.total_price > 150000
               THEN '7%'
           WHEN temp.total_price > 200000
               THEN '10%'
           ELSE '0%'
           END AS cuppon

FROM TOTAL_AMOUNT_BY_CUSTOMER_IN_PER_DAY AS temp;


# 3.======================== Customer Order Success and Failure by Nation Wise =========================================


SELECT n.N_NATIONKEY,
       c.C_NAME,
       SUM(o.O_ORDERSTATUS = 'O') AS total_success,
       SUM(o.O_ORDERSTATUS = 'F') AS total_fail
FROM orders AS o
         JOIN customer AS c ON o.O_CUSTKEY = c.C_CUSTKEY
         JOIN nation AS n ON n.N_NATIONKEY = c.C_NATIONKEY
GROUP BY c.C_CUSTKEY
LIMIT 10;


# 4. ========================Total Stock quantity by specific date =====================================================


SELECT p.`P_NAME`          AS product_name,
       SUM(l.`L_QUANTITY`) AS total_quantity
FROM `lineitem` AS l
         JOIN part AS p
              ON l.`L_PARTKEY` = p.`P_PARTKEY`
WHERE l.`L_RECEIPTDATE` = '1998-07-08'
GROUP BY l.`L_PARTKEY`
LIMIT 10;


# 5.=============== Sales Comparison Report: Total Sales, Yesterday's Sales, and Comparison for Selected Date ==========


SELECT o.O_ORDERDATE,
       SUM(o.O_TOTALPRICE) AS current_total_sale,
       p.previous_total_sale,
       CASE
           WHEN SUM(o.O_TOTALPRICE) > p.previous_total_sale THEN CONCAT(SUM(o.O_TOTALPRICE) - p.previous_total_sale,
                                                                        " taka over sold from yesterday")
           WHEN SUM(o.O_TOTALPRICE) < p.previous_total_sale THEN CONCAT(p.previous_total_sale - SUM(o.O_TOTALPRICE),
                                                                        " taka less sold from yesterday")
           END  AS sales_comparison

FROM orders AS o
         LEFT JOIN (SELECT `O_ORDERDATE`, SUM(O_TOTALPRICE) AS previous_total_sale
                    FROM orders
                    GROUP BY `O_ORDERDATE`) AS p ON o.`O_ORDERDATE` = DATE_ADD(p.`O_ORDERDATE`, INTERVAL 1 DAY)

WHERE o.`O_ORDERDATE` BETWEEN '1996-01-02' AND '1996-01-30'
GROUP BY `O_ORDERDATE`
ORDER BY o.`O_ORDERDATE` ASC
LIMIT 10;
