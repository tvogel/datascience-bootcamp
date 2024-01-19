DROP DATABASE IF EXISTS sql_workshop ;
CREATE DATABASE sql_workshop;

USE sql_workshop;

CREATE TABLE authors (
	author_id INT AUTO_INCREMENT,
    author_name VARCHAR(255),
    PRIMARY KEY (author_id)
);

CREATE TABLE books (
	book_id INT AUTO_INCREMENT,
    book_title VARCHAR(255),
    year_published VARCHAR(255),
    author_id INT,
    PRIMARY KEY (book_id),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);
