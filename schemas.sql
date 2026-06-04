-- Import rules first import city, then products, the customer and lastly sales tables


-- project monday coffee
create table city(
city_id INT PRIMARY KEY,
city_name VARCHAR(15),	
population BIGINT,	
estimated_rent FLOAT,	
city_rank INT
);

create table customers(
customer_id	INT PRIMARY KEY,
customer_name VARCHAR(25),	
city_id INT,
CONSTRAINT fk_city FOREIGN KEY(city_id) REFERENCES city(city_id)
);

create table products(
product_id INT PRIMARY KEY,
product_name VARCHAR(35),
price FLOAT
);

create table sales(
sale_id	INT PRIMARY KEY,
sale_date date,
product_id INT,	
customer_id	INT,
total FLOAT,	
rating INT,
CONSTRAINT fk_products FOREIGN KEY(product_id) REFERENCES products(product_id),
CONSTRAINT fk_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

-- end of schema





















