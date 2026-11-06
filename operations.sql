USE financedb;
SELECT premium_month,
SUM(premium_amount) AS total_revenue
FROM cleaned_premium
WHERE payment_status = 'Received'
GROUP BY premium_month
ORDER BY premium_month;

SELECT DATE_FORMAT(processed_date, '%Y-%m') AS month,
SUM(total_paid) AS total_claims_paid
FROM cleaned_header
WHERE claim_status = 'Paid'
GROUP BY DATE_FORMAT(processed_date, '%Y-%m')
ORDER BY month;

SELECT DATE_FORMAT(processed_date, '%Y-%m') AS month,
COUNT(*) AS denied_claims,
SUM(total_billed) AS denied_amount
FROM cleaned_header
WHERE claim_status = 'Denied'
GROUP BY month
ORDER BY month;

SELECT AVG(DATEDIFF(processed_date, received_date)) AS average_processing_days
FROM cleaned_header
WHERE processed_date IS NOT NULL
AND received_date IS NOT NULL;

SELECT denial_code,
COUNT(*) AS total_denied_claims
FROM cleaned_header
WHERE claim_status = 'Denied'
GROUP BY denial_code
ORDER BY total_denied_claims DESC;

SELECT DATE_FORMAT(processed_date, '%Y-%m') AS month,
COUNT(*) AS total_claims,
SUM(claim_status = 'Paid') AS paid_claims,
SUM(claim_status = 'Denied') AS denied_claims,
SUM(total_billed) AS total_billed,
SUM(total_paid) AS total_paid
FROM cleaned_header
GROUP BY month
ORDER BY month;

SELECT p.premium_month,
p.revenue,
COALESCE(c.claims_paid, 0) AS claims_paid,
(p.revenue - COALESCE(c.claims_paid, 0)) AS profit_loss
FROM (SELECT premium_month,
	SUM(premium_amount) AS revenue
    FROM cleaned_premium
    WHERE payment_status = 'Received'
    GROUP BY premium_month ) p
LEFT JOIN (SELECT DATE_FORMAT(processed_date, '%Y-%m') AS claim_month,
	SUM(total_paid) AS claims_paid
    FROM cleaned_header
    WHERE claim_status = 'Paid'
    GROUP BY DATE_FORMAT(processed_date, '%Y-%m')) c 
    ON p.premium_month = c.claim_month
ORDER BY p.premium_month;

SELECT   
    plan_id,
    SUM(premium_amount) AS total_revenue
FROM cleaned_premium
WHERE payment_status = 'Received'
GROUP BY plan_id;

SELECT
    member_id,
    SUM(total_paid) AS total_claims
FROM cleaned_header
WHERE claim_status = 'Paid'
GROUP BY member_id;

SELECT
    p.plan_id,
    SUM(p.revenue) AS total_revenue,
    SUM(IFNULL(c.claims, 0)) AS total_claims,
    SUM(p.revenue) - SUM(IFNULL(c.claims, 0)) AS net_profit_loss
FROM
(
    SELECT
        member_id,
        plan_id,
        SUM(premium_amount) AS revenue
    FROM cleaned_premium
    WHERE payment_status = 'Received'
    GROUP BY member_id, plan_id
) p
LEFT JOIN
(
    SELECT
        member_id,
        SUM(total_paid) AS claims
    FROM cleaned_header
    WHERE claim_status = 'Paid'
    GROUP BY member_id
) c
ON p.member_id = c.member_id
GROUP BY p.plan_id
ORDER BY net_profit_loss DESC;
