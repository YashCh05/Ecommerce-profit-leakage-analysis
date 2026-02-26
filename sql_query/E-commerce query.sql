USE ecom;
SELECT COUNT(*) FROM final_analytics_dataset;

-- Q1 — Monthly Revenue, Profit & Return Rate Trend
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(order_value) AS total_revenue,
    SUM(gross_profit) AS total_profit,
    ROUND(AVG(return_flag) * 100, 2) AS return_rate_pct,
    SUM(return_loss) AS total_return_loss
FROM final_analytics_dataset
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- Q2 — Loss-Making Products With High Return Rate
SELECT 
    product_id,
    category,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(return_flag) * 100, 2) AS return_rate_pct,
    SUM(gross_profit) AS total_profit
FROM final_analytics_dataset
GROUP BY product_id, category
HAVING 
    SUM(gross_profit) < 0
    AND AVG(return_flag) > (
        SELECT AVG(return_flag) 
        FROM final_analytics_dataset
    )
ORDER BY total_profit ASC;

-- Q3 — COD vs Prepaid Profitability
SELECT 
    payment_type,
    COUNT(order_id) AS total_orders,
    SUM(order_value) AS total_revenue,
    SUM(gross_profit) AS total_profit,
    ROUND(AVG(return_flag) * 100, 2) AS return_rate_pct,
    ROUND(AVG(gross_profit), 2) AS avg_profit_per_order
FROM final_analytics_dataset
GROUP BY payment_type
ORDER BY total_profit DESC;

-- Q4 — Serial Returner Detection
SELECT 
    customer_id,
    city,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(return_flag) * 100, 2) AS return_rate_pct,
    SUM(gross_profit) AS total_profit
FROM final_analytics_dataset
GROUP BY customer_id, city
HAVING 
    COUNT(order_id) >= 5
    AND AVG(return_flag) > 0.4
    AND SUM(gross_profit) < 0
ORDER BY return_rate_pct DESC;

-- Q5 — Discount Sensitivity Analysis
SELECT 
    CASE 
        WHEN discount_pct <= 0.05 THEN '0-5%'
        WHEN discount_pct <= 0.10 THEN '5-10%'
        WHEN discount_pct <= 0.20 THEN '10-20%'
        ELSE '20%+'
    END AS discount_bucket,

    COUNT(order_id) AS total_orders,
    ROUND(AVG(return_flag) * 100, 2) AS return_rate_pct,
    ROUND(AVG(profit_margin_pct) * 100, 2) AS avg_profit_margin_pct

FROM final_analytics_dataset
GROUP BY discount_bucket
ORDER BY discount_bucket;

-- BONUS — Cities Causing Highest Net Loss
SELECT 
    city,
    SUM(return_loss) AS total_return_loss,
    SUM(gross_profit) AS total_profit,
    SUM(gross_profit) - SUM(return_loss) AS net_impact
FROM final_analytics_dataset
GROUP BY city
ORDER BY net_impact ASC
LIMIT 5;
