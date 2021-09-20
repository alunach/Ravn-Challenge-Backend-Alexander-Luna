CREATE TABLE authors (
  id serial PRIMARY KEY,
  name text,
  date_of_birth timestamp
);
						
CREATE TABLE books (
  id serial PRIMARY KEY,
  author_id integer REFERENCES authors (id),
  isbn text
);
						
CREATE TABLE sale_items (
  id serial PRIMARY KEY,
  book_id integer REFERENCES books (id),
  customer_name text,
  item_price money,			
  quantity integer
);
/* seed data from the tables above */
/* deletes and restart sequences*/
DELETE FROM sale_items;
DELETE FROM books;
DELETE FROM authors;

DELETE FROM books_authors;
DELETE FROM full_names;

ALTER SEQUENCE authors_id_seq RESTART WITH 1;
ALTER SEQUENCE books_id_seq RESTART WITH 1;
ALTER SEQUENCE sale_items_id_seq RESTART WITH 1;

/* Authors */
/* delimiter can be any character that is not in the text */
\copy authors(name) FROM 'C:\Users\aluna\Desktop\portafolio\ravn\Ravn-Challenge-Backend-Alexander-Luna\authors.csv' DELIMITER '!' CSV HEADER;
/* remove author's name duplicates */
WITH unique_name AS
    (SELECT DISTINCT ON (name) * FROM authors)
DELETE FROM authors WHERE authors.id NOT IN (SELECT id FROM unique_name);
/* generate random timestamp data */
UPDATE authors SET date_of_birth=timestamp '1967-03-10 20:00:00' +random() * (timestamp '1967-03-20 20:00:00' - timestamp '1967-03-10 10:00:00');
/* Process data: fix the timestamp format */
UPDATE authors SET date_of_birth=to_char(date_of_birth, 'yyyy-MM-dd hh:mm:ss')::timestamp;
/* reset sequence */
ALTER SEQUENCE authors_id_seq RESTART WITH 1;
UPDATE authors SET id=nextval('authors_id_seq');

/* Books */
CREATE TEMP TABLE books_authors (
	author_id integer,
	author_name text,
	isbn text
);

\copy books_authors(isbn, author_name) FROM 'C:\Users\aluna\Desktop\portafolio\ravn\Ravn-Challenge-Backend-Alexander-Luna\books.csv' DELIMITER ';' CSV HEADER;

/* update the authors id by joining their names */
WITH authors_subquery AS
    (SELECT authors.id AS id_as, books_authors.isbn AS isbn_as FROM books_authors JOIN authors ON authors.name = books_authors.author_name)
UPDATE books_authors SET author_id = authors_subquery.id_as FROM (SELECT id_as, isbn_as FROM authors_subquery) AS authors_subquery WHERE authors_subquery.isbn_as = isbn;

INSERT INTO books (author_id, isbn) (SELECT author_id, isbn FROM books_authors);

/* Process data: trim names authors after after data seed in books and correct date of birth of “Lorelai Gilmore” - Lauren Graham */
UPDATE authors SET name = TRIM(REGEXP_REPLACE(name, '\s+', ' ', 'g'));
UPDATE authors SET date_of_birth = '1967-03-16 00:00:00' WHERE name = 'Lauren Graham';
/* Sale_items */
CREATE TEMP TABLE full_names (
	first_name text,
	last_name text	
);

\copy full_names(first_name, last_name) FROM 'C:\Users\aluna\Desktop\portafolio\ravn\Ravn-Challenge-Backend-Alexander-Luna\customer_names.csv' DELIMITER ';' CSV HEADER;

WITH customer_names AS
    (SELECT CONCAT(first_name, ' ', last_name) AS name FROM full_names)
INSERT INTO sale_items (customer_name) (SELECT name FROM customer_names JOIN (SELECT * from generate_series(1, 5)) AS gen_five ON true ORDER BY random());

UPDATE sale_items SET book_id = FLOOR(random() * 99 + 1)::integer;
UPDATE sale_items SET quantity = FLOOR(random() * 3 + 1)::integer;
UPDATE sale_items SET item_price = (random() * 200.00 + 100.00)::numeric::money;

/* create indexes */
CREATE INDEX i_authors_date_of_birth ON authors (date_of_birth ASC);
CREATE INDEX i_authors_name ON authors (name ASC);

/* 1. Who are the first 10 authors ordered by date_of_birth? */

SELECT name, date_of_birth FROM authors ORDER BY date_of_birth LIMIT 10;
/* 2. What is the sales total for the author named “Lorelai Gilmore”? - Lauren Graham*/
WITH graham AS
    (SELECT id, name FROM authors WHERE name = 'Lauren Graham' ORDER BY name)
SELECT SUM(sales.quantity*sales.item_price)::numeric::money AS sales_total FROM sale_items sales INNER JOIN books ON books.id = sales.book_id INNER JOIN graham ON books.author_id = graham.id;
/* 3. What are the top 10 performing authors, ranked by sales revenue? */
SELECT authors.name, SUM(sales.quantity*sales.item_price)::numeric::money AS sales_revenue FROM sale_items sales INNER JOIN books ON books.id = sales.book_id INNER JOIN authors ON books.author_id = authors.id GROUP BY authors.name ORDER BY sales_revenue DESC LIMIT 10;