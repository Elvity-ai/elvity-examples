#!/usr/bin/env bash
psql -v -U postgres  <<-EOSQL

-- Create the app role role
CREATE ROLE app_role WITH LOGIN PASSWORD 'app_role_password';

CREATE DATABASE rbac_example OWNER app_role;

\c rbac_example;

-- Create two tables
CREATE TABLE expense (
    id SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    description TEXT NOT NULL,
    vendor TEXT NOT NULL,
    amount DECIMAL NOT NULL
);

CREATE TABLE revenue (
    id SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    customer TEXT NOT NULL,
    product TEXT NOT NULL,
    amount DECIMAL NOT NULL
);

CREATE TABLE salaries (
    id SERIAL PRIMARY KEY,
    employee TEXT NOT NULL,
    salary DECIMAL NOT NULL
);

CREATE TABLE employee(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL
);

-- Insert some sample data
INSERT INTO expense (date, description, vendor, amount) VALUES ('2022-01-01', 'travel', 'airbnb', 100.00);
INSERT INTO revenue (date, customer, product, amount) VALUES ('2022-01-01', 'XYZ Corp', 'development', 500.00);

INSERT INTO employee (name, email) VALUES ('John Doe', 'j@j.com');
INSERT INTO salaries (employee, salary) VALUES ('John Doe', 10000);

-- Create roles
CREATE ROLE hr;
CREATE ROLE finance;

-- Grant the ability to switch to hr and finance
GRANT hr TO app_role;
GRANT finance TO app_role;

-- Revoke default access for PUBLIC (everyone)
REVOKE ALL ON expense FROM PUBLIC;
REVOKE ALL ON revenue FROM PUBLIC;
REVOKE ALL ON salaries FROM PUBLIC;
REVOKE ALL ON employee FROM PUBLIC;

-- Grant access to each role
GRANT SELECT, INSERT, UPDATE, DELETE ON expense, revenue TO finance;
GRANT SELECT, INSERT, UPDATE, DELETE ON salaries, employee TO hr;
EOSQL
