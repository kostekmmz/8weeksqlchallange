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



