# Case Study #2 - Pizza Runner
![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/312bbb4d-1306-44fe-9a53-3c2e51625541)

### I used a snowflake for first time in this case study!

# ERD
![Pizza Runner](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/b3afbd35-4061-42c4-9817-1a4fc1c9ecb8)

# Data Preparation

As we can see in `customer_orders` we have the iniquities, and they have to be cleaned before the analysis:
- In `exclusions` column we can see null written in string 
- In `extras` column we can see null written in string and null
![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/cc2db3b3-43d0-44a2-8c53-101c76b0a551)

<b>Creating new table with clean data:</b>
````sql
DROP TABLE IF EXISTS customer_orders_prep;
CREATE TABLE customer_orders_prep as
(SELECT 
"order_id",
"customer_id",
"pizza_id",
"order_time",
CASE WHEN "exclusions" is NULL or "exclusions" LIKE 'null' then '' 
ELSE "exclusions"
END as exclusions, 
CASE WHEN "extras" is NULL or "extras" LIKE 'null' then ''
ELSE "extras" 
END as extras
FROM customer_orders);
````
<b>Table after cleaning:</b>
  ![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/c5a2dc94-be7c-423a-bbe4-15a56f4fb2f1)

  As we can see in `runner_orders` we also have the inquities
  - In `distance` column we can see distances with 'km'
  - In `duration` column we can see duration with 'mins', 'minute' and 'minutes'

![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/f130c42f-35bd-47ee-bac1-4a1b6f9384c8)

<b>Creating new table with clean data:</b>
````sql
DROP TABLE IF EXISTS runner_orders_prep;
CREATE TABLE runner_orders_prep as
select 
"order_id",
"runner_id",
CASE
    WHEN "pickup_time" LIKE 'null' then ''
ELSE "pickup_time"
END as "pickup_time",
CASE 
    WHEN "distance" LIKE '%km' then  TRIM("distance",'%km')
    WHEN "distance" LIKE 'null' then ' '
ELSE "distance"
END AS "distance",
CASE 
    WHEN "duration" LIKE '%minutes' then TRIM("duration", '%minutes')
    WHEN "duration" LIKE '%mins' then TRIM("duration", '%mins')
    WHEN "duration" LIKE '%minute' then TRIM("duration", '%minute')
    WHEN "duration" LIKE 'null' then ' '
ELSE "duration"
END AS "duration",
CASE 
    WHEN "cancellation" IS null or "cancellation" LIKE 'null' then ' ' 
ELSE "cancellation"
END as "cancellation"
FROM runner_orders
````
<b>Table after cleaning:</b>
![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/8bf91487-62fb-4bdc-b613-ef2f501a78ac)

# Case Study Questions
### A. Pizza Metrics
1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?
    
***
**1. How many pizzas were ordered?**
```sql
SELECT 
COUNT("pizza_id") as volume
FROM customer_orders_prep;
````
![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/efb000a8-34de-4c98-9cd4-daad86ad14b7)

**2. How many unique customer orders were made?**
```sql
SELECT
COUNT(DISTINCT "customer_id") AS unique_customers
FROM customer_orders_prep;
````
![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/3a027748-3c72-41b0-90ae-fcae57786720)

**3. How many successful orders were delivered by each runner?**
   
 ```sql
SELECT "runner_id", count("order_id") AS count_successful
from runner_orders_prep
WHERE "pickup_time" <> ''
GROUP BY "runner_id"
````
![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/145cfa0b-532c-4448-93c0-9ea93ff42323)

**4.How many of each type of pizza was delivered?**
   ```sql
SELECT co."pizza_id",
count(co."order_id") as volume
FROM customer_orders_prep co
JOIN runner_orders_prep ro ON co."order_id"= ro."order_id"
WHERE ro."pickup_time" <> ''
GROUP BY  "pizza_id"
````
![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/74a5f895-8987-4896-b498-9563e4f8e442)

**5. How many Vegetarian and Meatlovers were ordered by each customer?**
  ```sql
   SELECT 
co."customer_id",
p."pizza_name",
count(co."order_id") AS volume,
FROM pizza_names p 
JOIN customer_orders_prep co ON p."pizza_id" = co."pizza_id"
GROUP BY co."customer_id", p."pizza_name"
ORDER BY "customer_id"
````
![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/2a4642ea-4bd7-4243-885c-70307c3477a0)

**6.What was the maximum number of pizzas delivered in a single order?**
   ```sql
   SELECT 
max(counted) AS maximum
FROM 
(SELECT count("pizza_id") as counted, co."order_id"
FROM customer_orders_prep co
JOIN runner_orders_prep ro ON co."order_id"= ro."order_id"
WHERE ro."pickup_time" <> ''
GROUP BY co."order_id")
````
![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/59f3af4d-3e9e-4f15-be15-1da844d8adc2)

**7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**
   ```sql
    SELECT 
"customer_id",
SUM(CASE 
WHEN co."EXCLUSIONS" = '' AND co."EXTRAS" = '' then 1
END) as not_changed,
SUM(CASE 
WHEN co."EXCLUSIONS" <> '' OR co."EXTRAS" <> '' then 1-- changed
END) changed
FROM customer_orders_prep co
JOIN runner_orders_prep ro ON co."order_id"= ro."order_id"
WHERE ro."pickup_time" <> ''
GROUP BY "customer_id"
````
![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/6d90ca45-15d4-493f-9fb1-d99a18913e0f)

**8.How many pizzas were delivered that had both exclusions and extras?**
   ```sql
    SELECT count(co."order_id") as pizzas
FROM customer_orders_prep co
JOIN runner_orders_prep ro ON co."order_id"= ro."order_id"
WHERE co."EXCLUSIONS" <> '' 
AND co."EXTRAS" <> ''
AND ro."pickup_time" <> ''
````
![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/6487ca77-9ca6-446c-8bc4-4ad269ffb3b6)

**9.What was the total volume of pizzas ordered for each hour of the day?**
   ```sql
    SELECT count(hour("order_time")) as volume,
hour("order_time") as each_hour
FROM customer_orders_prep co
group by each_hour
order by each_hour desc 
````
![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/68273b38-ab06-44a9-9401-e3c9629ab9c7)

**10. What was the volume of orders for each day of the week?**
  ```sql
    SELECT count(date_part(day,"order_time")) as volume,
date_part(day,"order_time") as each_day
FROM customer_orders_prep co
group by each_day
order by each_day desc 
````
![image](https://github.com/kostekmmz/8weeksqlchallange/assets/148641524/df3f9e99-e0d6-406c-9bb1-4c3964285427)
