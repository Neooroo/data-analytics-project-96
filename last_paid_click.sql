with cte1 AS (
SELECT s.visitor_id, 
       s.visit_date,
       s.source AS utm_source,
       s.medium AS utm_medium,
       s.campaign AS utm_campaign,
       l.lead_id,
       l.created_at,
       l.amount,
       l.closing_reason,
       l.status_id,
       row_number() over(partition by s.visitor_id
       order by s.visit_date desc) as numb
FROM sessions s
LEFT JOIN leads l ON s.visitor_id = l.visitor_id
                  AND s.visit_date < l.created_at
WHERE s.medium <> 'organic' )

SELECT visitor_id, 
       visit_date,
       utm_source,
       utm_medium,
       utm_campaign,
       lead_id,
       created_at,
       amount,
       closing_reason,
       status_id
FROM cte1
WHERE numb = 1
order by amount DESC nulls last, 
         visit_date,
         utm_source, 
         utm_medium, 
         utm_campaign
limit 10