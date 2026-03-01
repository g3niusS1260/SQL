-- CREATE TABLE books (
-- 	id SERIAL PRIMARY KEY,
-- 	title VARCHAR(150) NOT NULL,
-- 	price NUMERIC(10, 2)
-- );

-- CREATE TABLE categories (
-- 	id SERIAL PRIMARY KEY,
-- 	name VARCHAR(50) UNIQUE NOT NULL
-- );

-- CREATE TABLE books_categories(
-- 	book_id INTEGER REFERENCES books(id) ON DELETE CASCADE,
-- 	category_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
-- 	added_at TIMESTAMPTZ DEFAULT CURRENT_DATE,
-- 	PRIMARY KEY(book_id, category_id)
-- );

-- INSERT INTO categories (name)
-- VALUES 
-- ('Фантастика'), ('Роман'), ('Психология'), ('Бизнес'), ('Программирование'), 
-- ('История'), ('Триллер'), ('Детское'), ('Классика');

-- INSERT INTO books(title, price)
-- VALUES
-- ('Дворец ледяных сердец', 299), ('Гарри Поттер и Филосовский камень', 900),
-- ('Мертвая зона', 600), ('Четыре сезона', 300),
-- ('Война и Мир', 450), ('Граф Монте-Кристо', 299),
-- ('Оно', 560), ('Евгений Онегин', 800),
-- ('Девятый', 600), ('Вариация', 340);

-- INSERT INTO books_categories(book_id, category_id)
-- VALUES
-- (1, 2),
-- (1, 3),
-- (2, 4),
-- (2, 3),
-- (3, 5),
-- (3, 6),
-- (4, 5),
-- (5, 5),
-- (6, 5),
-- (7, 8),
-- (8, 1),
-- (9, 7),
-- (10, 9);

SELECT 
	b.title,
	c.name
FROM books b
JOIN books_categories bc ON b.id = bc.book_id
JOIN categories c ON c.id = bc.category_id;

SELECT 
	b.title AS book,
	c.name AS genre
FROM books b
JOIN books_categories bc ON b.id = bc.book_id
JOIN categories c ON c.id = bc.category_id
WHERE c.name = 'Программирование';

SELECT 
	c.name AS genre,
	COUNT(*)
FROM categories c
JOIN books_categories bc ON bc.category_id = c.id
GROUP BY genre;

SELECT 
	c.name AS genre,
	AVG(b.price) AS avg
FROM categories c
JOIN books_categories bc ON bc.category_id = c.id
JOIN books b ON bc.book_id = b.id
GROUP BY genre;

SELECT 
	b.title AS book,
	COUNT(*) AS total_genre
FROM books b
JOIN books_categories bc ON bc.book_id = b.id
JOIN categories c ON bc.category_id = c.id
GROUP BY book
HAVING COUNT(*) > 1;
