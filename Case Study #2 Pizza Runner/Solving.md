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
