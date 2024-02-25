with cte1 as(
select distinct on(s.visitor_id)
       s.visitor_id, 
       s.visit_date, 
       l.created_at, 
       l.status_id, amount, 
       lead_id, closing_reason, 
       medium, 
       source, 
       campaign 
from sessions s 
left join leads l 
on s.visitor_id = l.visitor_id
and s.visit_date <= l.created_at
where medium != 'organic'
order by s.visitor_id, visit_date desc
),

cte2 as (
select utm_source, 
       utm_medium, 
       utm_campaign, 
       cast(campaign_date as date) as campaign_date,
       sum(daily_spent) as total_cost
from vk_ads va
group by 1,2,3,4
union
select utm_source, 
       utm_medium, 
       utm_campaign, 
       cast(campaign_date as date) as campaign_date,
       sum(daily_spent) as total_cost
from ya_ads ya
group by 1,2,3,4),

 cte3 as (
 select  source, 
         medium, 
         campaign, 
         cast(visit_date as date) as visit_date,
         count (visitor_id) as visitors_count,
         count (visitor_id) filter(where cte1.created_at is not null)as leads_count,
         count (visitor_id) filter(where cte1.status_id = 142) as purchases_count,
         sum(amount) filter(where cte1.status_id = 142) as revenue
from cte1
group by source, medium, campaign, visit_date )

select to_char(visit_date, 'yyyy-mm-dd') as visit_date,
       visitors_count, 
       cte3.source as utm_source, 
       cte3.medium as utm_medium, 
       cte3.campaign as  utm_campaign,
       total_cost,leads_count, 
       purchases_count, 
       revenue
from cte3
left join cte2
on cte3.medium = cte2.utm_medium and 
cte3.source = cte2.utm_source and 
cte3.campaign = cte2.utm_campaign and 
cte3.visit_date = cte2.campaign_date
where cte3.medium != 'organic'
order by 9 desc nulls last, 1 asc, visitors_count desc, utm_source asc, utm_medium asc, utm_campaign asc
limit 15