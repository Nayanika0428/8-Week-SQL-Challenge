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

select R.customer_id, R.product_name as purchased_just_after, R.order_date, R.join_date 
from 
(select *,  
Rank() over(partition by customer_id order by order_date) as Rn 
from cte) as R
where R.Rn =1;



# 7. Which item was purchased just before the customer became a member?
with cte as (
select s.customer_id , s.product_id, me.product_name, s.order_date, m.join_date
from members m left join sales s 
on s.customer_id =m.customer_id 
join menu me
on s.product_id =me.product_id
where s.order_date < m.join_date 
order by customer_id)

select R.customer_id, R.product_name as Purchased_just_before, R.order_date, R.join_date 
from 
(select *,  
Rank() over(partition by customer_id order by order_date desc) as Rn 
from cte) as R
where R.Rn =1;



# 8. What is the total items and amount spent for each member before they became a member?
with cte as (
select s.customer_id , s.product_id, me.price, s.order_date, m.join_date
from sales s left join members m 
on s.customer_id = m.customer_id
join menu me
on s.product_id = me.product_id
where s.order_date < m.join_date OR m.join_date is null
order by customer_id)

select customer_id, count(product_id) as total_items, sum(price) as amount_spent 
from cte 
group by customer_id;



# 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte as (select *,
case when product_name = "sushi" then price*20 else price*10 end as points
from menu)

Select s.customer_id , sum(c.points) as total_points 
from sales s join cte c 
on s.product_id = c.product_id 
group by s.customer_id;



# 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
        # Assuming 10 points rewarded for each $1 spent before joining the program, except sushi. For 2x points collected
        # For the first week after the customer joins the program they earn 2x points on all items
        
        # Customer has even collected points before joining the program , so collectively the total points has been calculated by the end of january

select s.customer_id,
sum(case when s.order_date between m.join_date and Date_add(m.join_date, interval 7 day) then price*20
		 when s.order_date not between m.join_date and Date_add(m.join_date, interval 7 day) 
             and me.product_name = "sushi" then price*20
	     else price*10
    end) as Total_points_by_JAN_end
from sales s join members m 
on s.customer_id = m.customer_id 
join menu me 
on s.product_id = me.product_id 
where s.order_date <= "2021-01-31"
group by s.customer_id
order by s.customer_id;



### Bonus Questions ###

   # merging sales , menu and members table
Select s.customer_id, s.order_date, me.product_name, me.price,
if (s.order_date >= m.join_date, "Y", "N") as member
from sales s left join menu me 
on s.product_id = me.product_id
left join members m
on s.customer_id = m.customer_id
order by s.customer_id;



# Danny also requires further information about the ranking of customer products, but he purposely does not need the 
# ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part 
# of the loyalty program. 
with cte as
(Select s.customer_id, s.order_date, me.product_name, me.price,
if (s.order_date >= m.join_date, "Y", "N") as member
from sales s left join menu me 
on s.product_id = me.product_id
left join members m
on s.customer_id = m.customer_id
order by s.customer_id)

Select *,
CASE
WHEN member= "Y" THEN dense_rank() over(partition by customer_id order by order_date)
ELSE Null 
END as ranking
from cte
order by s.customer_id;






