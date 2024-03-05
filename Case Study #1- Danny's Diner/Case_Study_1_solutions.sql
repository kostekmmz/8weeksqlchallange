/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

  SELECT 
  sa.customer_id,
  SUM(menu.price) as total_amount
FROM dannys_diner.sales sa
JOIN dannys_diner.menu menu ON sa.product_id = menu.product_id 
group by sa.customer_id
order by total_amount desc 

-- 2. How many days has each customer visited the restaurant?

SELECT 
	customer_id, 
	count(sa.order_date) visits
FROM dannys_diner.sales sa
group by sa.customer_id
order by visits desc 

-- 3. What was the first item from the menu purchased by each customer?

with T as
(select 
	sa.customer_id, 
    sa.order_date,
    dense_rank() over (order by sa.order_date desc) as daterank,
	menu.product_name 
	from dannys_diner.sales sa
	join dannys_diner.menu on sa.product_id = menu.product_id
)  
SELECT customer_id, 
product_name 
FROM t
WHERE daterank = 8


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select count(sa.product_id),
 menu.product_name 
 from dannys_diner.sales sa
join dannys_diner.menu menu on sa.product_id = menu.product_id
group by menu.product_name
LIMIT 1  

-- 5. Which item was the most popular for each customer?

with t as (
select 
	count(sa.product_id), 
	sa.customer_id,
  	menu.product_name,
    DENSE_RANK() OVER(PARTITION BY sa.customer_id order by count(sa.product_id) desc)
    --ROW_NUMBER() OVER(PARTITION BY sa.customer_id ORDER BY COUNT(sa.product_id) DESC)
from dannys_diner.sales sa
  join dannys_diner.menu on sa.product_id = menu.product_id
group by sa.customer_id,  menu.product_name
)

select customer_id, product_name from t
WHERE dense_rank = 1 
order by customer_id asc
 
 
-- 6. Which item was purchased first by the customer after they became a member?
with t as
 (SELECT 
 sa.customer_id,
 sa.order_date,
 mem.join_date,
 menu.product_name,
 CASE 
 WHEN sa.order_date >= mem.join_date then
DENSE_RANK() OVER(PARTITION BY sa.customer_id order by(mem.join_date - sa.order_date) desc)
ELSE NULL
END AS RANK
FROM dannys_diner.sales sa
	JOIN dannys_diner.members mem ON sa.customer_id = mem.customer_id
 	join dannys_diner.menu on sa.product_id = menu.product_id
    WHERE sa.order_date >= mem.join_date
 ) 
    select customer_id, product_name
   from t
   where rank = 1



-- 7. Which item was purchased just before the customer became a member?
 with t as(
 SELECT 
 sa.customer_id,
 sa.order_date,
 mem.join_date,
 menu.product_name,
 CASE 
 WHEN sa.order_date < mem.join_date then
DENSE_RANK() OVER(PARTITION BY sa.customer_id order by(sa.order_date - mem.join_date) desc)
ELSE NULL
END AS RANK
FROM dannys_diner.sales sa
	JOIN dannys_diner.members mem ON sa.customer_id = mem.customer_id
 	join dannys_diner.menu on sa.product_id = menu.product_id
    WHERE sa.order_date < mem.join_date)
   select customer_id, product_name
 	from t
   where rank = 1




-- 8. What is the total items and amount spent for each member before they became a member?
 select
sa.customer_id,
count(menu.product_name) as total_items,
sum(menu.price) as amount_spent
FROM dannys_diner.sales sa
JOIN dannys_diner.members mem ON sa.customer_id = mem.customer_id
 	join dannys_diner.menu on sa.product_id = menu.product_id
    where order_date < join_date
    group by sa.customer_id
    order by customer_id asc
    
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have

 SELECT 
	customer_id,
	sum(points) as total_points
FROM(
SELECT 
	sa.customer_id,
    CASE WHEN menu.product_id = 1 THEN sum(menu.price)*20
    ELSE sum(menu.price)*10
    END AS POINTS
FROM 
	dannys_diner.sales sa
JOIN
	dannys_diner.menu on sa.product_id = menu.product_id
    GROUP BY sa.customer_id, menu.product_id) AS x
    GROUP BY customer_id
    order by total_points desc

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

 
SELECT 
	sa.customer_id,
   SUM
   (
  CASE
        WHEN sa.order_date - mem.join_date >= 0 
     		and sa.order_date - mem.join_date <= 6 THEN price * 10 * 2
        WHEN sa.product_id = 1 THEN menu.price * 10 * 2
        ELSE price * 10
     END
     ) as total_points
FROM 
	dannys_diner.sales sa
JOIN
	dannys_diner.menu on sa.product_id = menu.product_id
JOIN 
	dannys_diner.members mem ON sa.customer_id = mem.customer_id

where EXTRACT(MONTH FROM order_date) = 1
AND EXTRACT(YEAR FROM order_date) = 2021

GROUP BY sa.customer_id



