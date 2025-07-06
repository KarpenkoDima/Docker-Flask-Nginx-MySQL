-- Create DB
CREATE DATABASE IF NOT EXISTS myapp;
USE myapp;

-- Create user
CREATE USER IF NOT EXISTS 'myuser'@'%' IDENTIFIED BY 'mypassword';
GRANT ALL PRIVILEGES ON myapp.* TO 'myuser'@'%';
FLUSH PRIVILEGES;

-- create table users
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test data
INSERT INTO users (name, email) VALUES 
('Иван Иванов', 'ivan@example.com'),
('Мария Петрова', 'maria@example.com'),
('Алексей Сидоров', 'alexey@example.com');