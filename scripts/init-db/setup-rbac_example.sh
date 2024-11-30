#!/usr/bin/env bash
psql -v -U postgres  <<-EOSQL

-- Create the admin role
CREATE ROLE role_admin WITH LOGIN PASSWORD 'adminpassword';

CREATE DATABASE rbac_example OWNER role_admin;

\c rbac_example;

-- Create two tables
CREATE TABLE table1 (
    id SERIAL PRIMARY KEY,
    data TEXT NOT NULL
);

CREATE TABLE table2 (
    id SERIAL PRIMARY KEY,
    info TEXT NOT NULL
);

-- Insert some sample data
INSERT INTO table1 (data) VALUES ('Data for Table 1 - Row 1'), ('Data for Table 1 - Row 2');
INSERT INTO table2 (info) VALUES ('Info for Table 2 - Row 1'), ('Info for Table 2 - Row 2');

-- Create roles
CREATE ROLE role1 WITH LOGIN PASSWORD 'password1';
CREATE ROLE role2 WITH LOGIN PASSWORD 'password2';

-- Grant the ability to switch to role1 and role2
GRANT role1 TO role_admin;
GRANT role2 TO role_admin;

-- Revoke default access for PUBLIC (everyone)
REVOKE ALL ON table1 FROM PUBLIC;
REVOKE ALL ON table2 FROM PUBLIC;

-- Grant access to each role
GRANT SELECT, INSERT, UPDATE, DELETE ON table1 TO role1;
GRANT SELECT, INSERT, UPDATE, DELETE ON table2 TO role2;
EOSQL
