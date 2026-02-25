DROP TABLE IF EXISTS books;
CREATE TABLE books (
	id SERIAL PRIMARY KEY,
	title  VARCHAR(150) NOT NULL,
	author_first_name VARCHAR(100),
	author_last_name VARCHAR(150),
	publication_year INTEGER CHECK (publication_year >= 1950 AND publication_year <= 2026),
	isbn VARCHAR(13) UNIQUE,
	pages INTEGER CHECK (pages > 0),
	is_borrowed BOOLEAN DEFAULT FALSE
);

INSERT INTO books (title, author_first_name, author_last_name, publication_year, isbn, pages, is_borrowed)
VALUES
('Гарри Поттер и Филосовский камень', 'Джоан', 'Роулинг', 1977, '9785389074354', 432, FALSE),
('Гарри Поттер и Принц-полукровка', 'Джоан', 'Роулинг', 2005, '9785389077911', 672, FALSE),
('Почти серъёзно', 'Юрий', 'Никулин', 1976, '9785171185152', 608, FALSE),
('С неба упали три яблока', 'Наринэ', 'Абгарян', 2015, '9785179827764', 384, FALSE),
('Женщины Лазаря', 'Марина', 'Степнова', 2011, '9785170909179', 448, FALSE),
('Доля вероятности', 'Ребекка', 'Ярос', 2024, '9785389272040', 448, FALSE),
('Поток: Психология оптимального переживания', 'Михай', 'Чиксентмихайи', 1990, '9785916718881', 461, FALSE),
('Железное пламя', 'Ребекка', 'Яррос', 2023, '9785353108580', 912, FALSE),
('Вариация', 'Ребекка', 'Яррос', 2024, '9785389300286', 640, FALSE);

-- Оператор CONCAT: соединяет имя автора и фамилию через пробел
SELECT CONCAT(author_first_name, ' ', author_last_name) AS full_author_name FROM books;

-- Пагинация: выведем книги с 4-ой по 6-ую
SELECT title FROM books
LIMIT 2
OFFSET 4;

-- GROUP BY, HAVING: кол-во страниц самой толстой книги у авторы, но только для тех авторов, у которых суммарно во всех книгах более 1000 страниц
SELECT CONCAT(author_first_name, ' ', author_last_name) AS full_author_name, MAX(pages) AS max_pages FROM books
GROUP BY CONCAT(author_first_name, ' ', author_last_name)
HAVING(SUM(pages) > 1000);

-- UPDATE: поменяем статус is_borrowed в книге 'Поток' на true
UPDATE books 
SET is_borrowed = TRUE
WHERE title = 'Поток: Психология оптимального переживания';

-- Сложный фильтр: выведем все книги, в названии которых есть слово 'Программирование' и которые изданы похже 2015
SELECT title, CONCAT(author_first_name, ' ', author_last_name) AS full_author_name FROM books
WHERE title LIKE '%Программирование%' AND publication_year > 2015;
