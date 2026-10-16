-- Active: 1789013061927@@127.0.0.1@5432@testdb@practice
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    prefecture TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

