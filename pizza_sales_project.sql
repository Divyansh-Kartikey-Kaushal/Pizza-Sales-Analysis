CREATE database pizzahut;
USE pizzahut;
CREATE TABLE  orders(
order_id INT NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL,
PRIMARY KEY (order_id)
);

CREATE TABLE  order_details(
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
PRIMARY KEY (order_details_id)
);

-- BASIC
-- 1. Retrive the total number of order placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- 3. Identify the highest prize pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4. Idnetify the most common pizza size order.
#1st Method
SELECT 
    pizzas.size,
    COUNT(order_details.quantity) AS Number_of_orders_on_Size
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY Number_of_orders_on_Size DESC
LIMIT 1;
#2nd Method
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- 5. List the top 5 most ordereed pizza along with their quantities.
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- INTERMEDIATE
-- 1. Join the necesssary tables to find the total quantity of each pizza category.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- 2. Determine the distribution of orders by hours of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

-- 3. Join relevant tables to find the category wise distribtion of pizzas.
SELECT 
    category, COUNT(name) AS pizza_distribution
FROM
    pizza_types
GROUP BY category;

-- 4. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS average_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity_per_day;
    
-- 5. Determine the top 3 most orderd pizza types based on revenue.    
    
SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- ADVANCE
-- 1. Calculate the percentage contribution of each pizza type to the total revenue. 

SELECT 
    pizza_types.category,
    ROUND(ROUND(SUM(order_details.quantity * pizzas.price),
                    2) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- 2. Analyze the cumulative revenue generated over time.
SELECT 
    order_date, 
    SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT 
        orders.order_date, 
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM 
        order_details
    JOIN 
        pizzas 
        ON order_details.pizza_id = pizzas.pizza_id
    JOIN 
        orders 
        ON orders.order_id = order_details.order_id
    GROUP BY 
        orders.order_date
) AS sales;

-- 3. Determine the top 3 most ordered pizza type based on revenue for each pizza category
SELECT 
    category, 
    name, 
    revenue
FROM (
    SELECT 
        category, 
        name, 
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT 
            pizza_types.category, 
            pizza_types.name, 
            SUM(order_details.quantity * pizzas.price) AS revenue
        FROM 
            pizza_types
        JOIN 
            pizzas 
            ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN 
            order_details 
            ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY 
            pizza_types.category, 
            pizza_types.name
    ) AS a
) AS b
WHERE 
    rn <= 3;







