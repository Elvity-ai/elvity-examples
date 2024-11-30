#!/usr/bin/env bash
psql -v -U postgres  <<-EOSQL

CREATE ROLE example_admin WITH BYPASSRLS;
CREATE USER example LOGIN PASSWORD 'example' IN ROLE example_admin;
CREATE DATABASE rls_example OWNER example_admin;

EOSQL

psql -v -U postgres -d rls_example <<-EOSQL2
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO example;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO example;

CREATE TABLE Purchase (
    Purchase_ID SERIAL PRIMARY KEY,
    User_ID INT NOT NULL,
    Product_Name VARCHAR(255) NOT NULL,
    Quantity INT NOT NULL,
    Purchase_Date DATE NOT NULL
);

-- enable RLS on table
ALTER TABLE Purchase
    ENABLE ROW LEVEL SECURITY,
    FORCE ROW LEVEL SECURITY;

-- RLS policy based on user_id
CREATE POLICY user_policy ON Purchase
    USING (User_ID = current_setting('app.current_user_id')::INT);

-- some data
INSERT INTO Purchase (User_ID, Product_Name, Quantity, Purchase_Date)
VALUES
    (101, 'Laptop', 1, '2024-11-20'),
    (102, 'Smartphone', 2, '2024-11-21'),
    (103, 'Tablet', 1, '2024-11-22'),
    (104, 'Headphones', 3, '2024-11-23'),
    (105, 'Smartwatch', 2, '2024-11-24');

 REVOKE ALL ON Purchase FROM PUBLIC;
 ALTER TABLE Purchase OWNER TO example_admin;
EOSQL2
