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
select customer_id, product_id , count(product_id) as p from sales group by customer_id, product_id;

Select customer_id, product_id,
count(product_id) over (partition by customer_id, product_id) as count 
from sales;


