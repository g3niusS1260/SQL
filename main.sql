CREATE TABLE IF NOT EXISTS movies(
	id SERIAL PRIMARY KEY,
	title VARCHAR(150) NOT NULL,
	genre VARCHAR(50),
	duration_min INTEGER CHECK(duration_min > 0),
	ticket_price NUMERIC(10, 2) DEFAULT 0.00,
	rating VARCHAR(10),
	is_3d BOOLEAN DEFAULT FALSE,
	release_date DATE
); 

-- Добавили фильмы

-- INSERT INTO movies (title, genre, duration_min, ticket_price, rating, is_3d, release_date)
-- VALUES 
-- ('Интерстеллар', 'Фантастика', 169, 500.00, '12+', FALSE, '2014-11-06'),
-- ('Побег из Шоушенка', 'Драма', 142, 600.00, '18+', FALSE, '1994-09-10'),
-- ('1+1', 'Драма', 112, 540.00, '18+', FALSE, '2011-09-23'),
-- ('Пятница, 13. Часть 3', 'Ужасы', 95, 300.00, '18+', TRUE, '1982-08-13'),
-- ('Титаник', 'Драма', 194, 700.00, '12+', TRUE, '1997-11-01'),
-- ('Зеленая книга', 'Драма', 130, 365.00, '18+', FALSE, '2011-09-11');

-- Подняли всем фильмам жанра 'Драма' цену на 50 рублей
-- UPDATE movies
-- SET ticket_price = ticket_price + 50
-- WHERE genre = 'Драма';

-- Удалим фильм с id = 5
-- DELETE FROM movies
-- WHERE id = 5;

-- Изменим рейтинг 'Интерстеллар' на 16+
-- UPDATE movies
-- SET rating = '16+'
-- WHERE title = 'Интерстеллар';


-- Фильмы дольше 20 минут
-- SELECT title, ticket_price FROM movies
-- WHERE duration_min > 120;

-- Сортировка от дорогих к дешевым
-- SELECT * FROM movies
-- ORDER BY ticket_price DESC;
-- SELECT * FROM movies;

-- Кол-во фильмов в базе
-- SELECT COUNT(*) as total_movies FROM movies;

-- Средняя стоимость
-- SELECT AVG(ticket_price) FROM movies;

-- Кол-во фильм в каждом жанре
-- SELECT genre, COUNT(*) as total_movies FROM movies
-- GROUP BY genre;

-- Жанры, в которых фильмы дороже 300
SELECT genre, AVG(ticket_price) as avg_tickect_price FROM movies
GROUP BY genre
HAVING AVG(ticket_price) > 300;