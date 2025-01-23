show databases;
use pop;

select * from user_details;
select * from upi_transactions;
select * from credit_card_transactions;
select * from loyalty_program;
select * from ecommerce_orders;

-- 1 Write an SQL query to calculate the number of new customers on a daily basis.

select * from user_details;
select ud.first_order_date  , count(ud.user_id) as new_customers  from user_details ud
where ud.first_order_date = (select min(ud2.first_order_date) from user_details ud2  where ud.user_id = ud2.user_id )
group by ud.first_order_date
order by ud.first_order_date;


-- 3 Find users who have both UPI and e-commerce orders and calculate the total amount spent by each user.
with cte as (
select ut.user_id , ut.amount as upi_amount , ec.total_amount as ecomm_total  from upi_transactions ut inner join ecommerce_orders ec on ut.user_id = ec.user_id 
where ut.status = 'success' and ec.order_status = 'delivered' )

select user_id , upi_amount + ecomm_total as total_spend_amount from cte;


-- 4 country with most number of successful upi transactions 
with cte as (
select ut.* , ud.country from upi_transactions ut 
inner join user_details ud using (user_id)
where ut.status = 'success'
order by amount desc)
select country  ,  count(transaction_id) , sum(amount) from cte
group by 1 
order by 3 desc 
limit 1;


-- 5 find the top country with most points earned by users for successful UPI transactions.
select lp.user_id , lp.points_earned , lp.tier , ud.country  from loyalty_program lp 
inner join upi_transactions using (user_id)
inner join user_details ud using (user_id)
where status = 'Success' 
order by 2 desc
limit 1;

-- 6 Which user took longest for ordering from our upi after signing up and with that order status wheather it was delivered or cancelled
select user_id , user_name , total_orders ,user_signup_date ,  first_order_date , datediff(first_order_date,user_signup_date ) as diff , ec.order_status
from user_details
inner join ecommerce_orders ec using (user_id)
order by 6 desc;

-- 7 Is there any correlation with the revenue generated and the points earned

with cte as (
select distinct ut.user_id , ut.amount as amount from upi_transactions ut 
union all
select distinct cct.user_id , cct.amount as amount  from credit_card_transactions cct 
union all
select distinct ec.user_id , ec.total_amount as amount from ecommerce_orders ec
order by 1)
select user_id , sum(amount) as total_amount , sum(lp.points_earned) as total_points_earned from cte  
inner join loyalty_program lp using (user_id)
group by 1
order by 3 desc;

-- yes, there is a correlation between the revenue_generated and the points offered to the customer


-- 8 find the quarterly count of new signups 
with cte as (
select user_id, date(user_signup_date) as `date` from user_details
order by 2),
cte2 as (
select * , case when date between '2024-01-01' and '2024-03-31' then 'Quarter 1' 
				when date between '2024-04-01' and '2024-06-30' then 'Quarter 2' 
                when date between '2024-07-01' and '2024-09-30' then 'Quarter 3'
                when date between '2024-10-01' and '2024-12-31' then 'Quarter 4'
                when date > '2025-01-01' then '2025 quarter'
                end as quarter
from cte)

select quarter , count(user_id) as sign_up from cte2
group by 1;

-- 9  hours with most credit card transactions that were successfull

select hour(transaction_date),  sum(amount) 
from credit_card_transactions 
where transaction_status = 'success'
group by 1
order by 2 desc;

-- 10 users who haven't make any transactions upi or credit card transactions in last 6 or more than 6 months
with data as (
select user_id , amount , transaction_date , 'UPI' as method from upi_transactions ut
union all
select user_id , amount , transaction_date , 'CreditCard' as method from credit_card_transactions cct 
order by user_id)
select * from data
where transaction_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);


-- 11 user vs amount
select merchant_name , count( user_id) as user_count , sum(amount) as total_mount
from  credit_card_transactions 
where transaction_type not like '%withdrawal%' and transaction_status = 'success'
group by merchant_name
order by 1 ;

select merchant_name , count( user_id) as user_count , sum(amount) as total_mount
from  credit_card_transactions 
where transaction_type not like '%withdrawal%' and transaction_status = 'success'
group by merchant_name
order by 3 desc;
-- most users use credit on amazon but the amount spend is highest in walmart





