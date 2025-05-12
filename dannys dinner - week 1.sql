-- What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(m.price) as total_amount_spent
from sales s inner join menu m
on s.product_id = m.product_id
group by s.customer_id;
-- How many days has each customer visited the restaurant?
select customer_id,count(order_date) as days_visited
from sales 
group by customer_id;
-- What was the first item from the menu purchased by each customer?
with ranked_sales as (
select s.customer_id,s.order_date,m.product_name,
       row_number()over(partition by s.customer_id order by order_date asc) as rn
from sales s inner join menu m
on s.product_id = m.product_id
)
select customer_id,product_name,order_date
from ranked_sales
where rn=1;


-- What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name,count(s.product_id) as total_purchases
from sales s inner join menu m on s.product_id = m.product_id
group by m.product_name
order by total_purchases desc
limit 1;
-- 5.Which item was the most popular for each customer?
with cte as(
select s.customer_id, 
       m.product_name,
       count(s.product_id) as purchase_times,
       row_number()over(partition by s.customer_id order by count(s.product_id) DESC) as rn
from sales s inner join menu m
on s.product_id = m.product_id
group by s.customer_id, m.product_name 
)
select customer_id, product_name
from cte
where rn =1;

-- 6.Which item was purchased first by the customer after they became a member?
with cte as(
select s.customer_id, m.product_name,s.order_date,
       row_number()over(partition by s.customer_id order by s.order_date) as rn
from sales s inner join menu m 
on s.product_id = m.product_id
inner join members mem
on s.customer_id = mem.customer_id
where s.order_date >= mem.join_date
)
select customer_id, product_name,order_date
from cte
where rn=1;
-- 7.Which item was purchased just before the customer became a member?
with cte as(
select s.customer_id, m.product_name,s.order_date,
       row_number()over(partition by s.customer_id order by s.order_date desc) as rn
from sales s inner join menu m
on s.product_id = m.product_id
inner join members mem
on s.customer_id = mem.customer_id
where s.order_date < mem.join_date
)
select customer_id, product_name,order_date
from cte
where rn = 1;
-- 8.What is the total items and amount spent for each member before they became a member?
select s.customer_id, count(s.product_id) as total_items , sum(m.price) as amount_spent
from sales s inner join menu m
on s.product_id = m.product_id
inner join members mem
on s.customer_id = mem.customer_id
where s.order_date < mem.join_date
group by s.customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- how many points would each customer have?
select s.customer_id,
  sum(case 
      when m.product_name = 'sushi' then m.price * 20
      else m.price * 10
    end) as points
from sales s 
join menu m on s.product_id = m.product_id
group by s.customer_id;
-- In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?
 select s.customer_id, 
 sum(case
	when s.order_date between mem.join_date and date_add(mem.join_date, interval 6 day)
	then m.price * 20
	when s.order_date > date_add(mem.join_date, interval 6 day) and m.product_name = 'sushi'
    then m.price * 20
	else m.price * 10 end) as points
from sales s inner join members mem on s.customer_id = mem.customer_id
join menu m on s.product_id = m.product_id
where s.order_date >= mem.join_date 
  and s.order_date <= '2021-01-31'
  and s.customer_id in ('A', 'B')
group by  s.customer_id;






























































































































