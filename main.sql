CREATE TABLE IF NOT EXISTS inventory (
	id SERIAL PRIMARY KEY,
	item_name VARCHAR(50) NOT NULL,
	quantity INTEGER DEFAULT 0 CHECK(quantity > 0),
	category VARCHAR(50),
	is_available BOOLEAN DEFAULT false,
	price NUMERIC(10, 2) CHECK(price > 0)
);

-- INSERT INTO inventory (item_name, quantity, category, is_available, price)
-- VALUES
-- ('Наушники', 12, 'Оргтехника', true, 3500),
-- ('Принтер', 2, 'Оргтехника', true, 15000),
-- ('Изолента', 10, 'Расходные материалы', true, 200),
-- ('Шкаф', 1, 'Мебель', false, 10000),
-- ('Книжная полка', 40, 'Мебель', true, 4500),
-- ('Точилка', 1, 'Канцтовары', false, 50),
-- ('Карандаш', 200, 'Канцтовары', true, 35),
-- ('Пищевая пленка', 300, 'Расходные материалы', true, 250);

-- Выыод только названия и количества
SELECT item_name, quantity FROM inventory;

-- Товары, которых меньше 5 штук
SELECT * FROM inventory
WHERE quantity < 5;

-- Товары от 1000 до 10000
SELECT * FROM inventory
WHERE price BETWEEN 1000 and 10000;

-- Товары только с категориями 'Мебель', 'Оргтехника'
SELECT * FROM inventory
WHERE category IN ('Мебель', 'Оргтехника');

-- Товары, в которых входит слово 'Пищевая'
SELECT * FROM inventory
WHERE item_name LIKE '%Пищевая%';

-- Только недоступные товары
SELECT * FROM inventory
WHERE is_available = False;

-- Сортировка по алфавиту
SELECT item_name, category FROM inventory
ORDER BY category, item_name;

-- Самые дорогие товары на складе
SELECT item_name, price FROM inventory
ORDER BY price DESC LIMIT(3);