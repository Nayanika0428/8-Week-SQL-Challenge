use dannys_diner;

# Case Study Questions

# 1. What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(m.price) as Total_Amt 
from sales as s Left Join menu m 
on s.product_id = m.product_id 
group by s.customer_id; 


# 2. How many days has each customer visited the restaurant?
select customer_id , count(distinct order_date) as number_days_visited from sales group by customer_id;


# 3. What was the first item from the menu purchased by each customer?
WITH cte AS 
(
select * from sales where order_date in (select min(order_date) from sales group by customer_id)
)
select c.customer_id, m.product_name 
from cte c join menu m on c.product_id=m.product_id 
group by customer_id, product_name;


# 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name as Most_frequent_item, count(s.product_id) as Number_of_times_bought
from sales s join menu m 
on s.product_id= m.product_id 
group by m.product_name 
order by Number_of_times_bought desc 
limit 1;




# 5. Which item was the most popular for each customer?
with cte1 as (
select customer_id, product_id , count(product_id) as num_times, 
dense_rank() over (partition by customer_id order by count(product_id) desc) as Rn
from sales
group by customer_id, product_id)

select c.customer_id, c.product_id, m.product_name, c.num_times
from cte1 c join menu m
on c.product_id = m.product_id 
where c.Rn = 1
order by c.customer_id;



# 6. Which item was purchased first by the customer after they became a member?
with cte as (
select s.customer_id , s.product_id, me.product_name, s.order_date, m.join_date
from members m left join sales s 
on s.customer_id =m.customer_id 
join menu me
on s.product_id =me.product_id
where s.order_date >= m.join_date 
order by customer_id)

select R.customer_id, R.product_name, R.order_date, R.join_date 
from 
(select *,  
Rank() over(partition by customer_id order by order_date) as Rn 
from cte) as R
where R.Rn =1;




