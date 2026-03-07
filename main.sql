-- Рестораны
CREATE TABLE restaurants(
	id SERIAL PRIMARY KEY,
	title VARCHAR(100) NOT NULL,
	address TEXT,
	category VARCHAR(50),
	rating NUMERIC(2, 1) CHECK (rating >= 1.0 AND rating <= 5.0)
);

-- список блюд
CREATE TABLE menu_items(
	id SERIAL PRIMARY KEY,
	item_name VARCHAR(100) NOT NULL,
	restaurant_id INTEGER REFERENCES restaurants(id) ON DELETE CASCADE,
	price NUMERIC(8, 2) CHECK (price > 0.0) NOT NULL,
	is_available BOOLEAN DEFAULT TRUE
);

Клиенты
CREATE TABLE customers(
	id SERIAL PRIMARY KEY,
	full_name VARCHAR(100) NOT NULL,
	email VARCHAR(150) NOT NULL,
	registtration_date DATE DEFAULT CURRENT_DATE
);

-- Шапка заказа
CREATE TABLE orders(
	id SERIAL PRIMARY KEY,
	customer_id INTEGER REFERENCES customers(id) ON DELETE CASCADE,
	order_date DATE DEFAULT CURRENT_DATE,
	status VARCHAR(30) DEFAULT 'Принят'
);

-- Связующая таблица, объединяет блюда и заказы
CREATE TABLE order_items(
	order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
	item_id INTEGER REFERENCES menu_items(id),
	quantity INTEGER CHECK(quantity > 0),
	PRIMARY KEY(item_id, order_id)
);

-- Наполнение данными
INSERT INTO restaurants(title, address, category, rating)
VALUES
('Крошка Картошка', 'г. Брянск, ул. Малинина, д. 16', 'Русская', 4.5),
('Итальянский рай', 'г. Брянск, ул. Краснова, д. 1', 'Итальянская', 4.0),
('Вкус Востока', 'г. Брянск, ул. Московская, д. 2', 'Восточная', 5.0),
('China Club', 'г. Брянск, ул. Калинина, д. 34', 'Китайская', 4.5),
('Burger Bar', 'г. Брянск, ул. Малинина, д. 16', 'Американская', 3.8);

INSERT INTO menu_items(item_name, restaurant_id, price, is_available)
VALUES
-- 'Итальянский рай'
('Пицца Пеперони', 2, 800, TRUE),
('Лазанья', 2, 1200, TRUE),
('Пицца Маргаритта', 2, 900, TRUE),
('Паста Карбонара', 2, 1300, FALSE),

-- Крошка Картошка
('Картошка со сливочным маслом', 1, 350, TRUE),
('Печеный Мэш', 1, 240, TRUE),
('Щи из квашеной капустой', 1, 150, FALSE),
('Суп гороховый', 1, 300, TRUE),

-- Вкус Востока
('Плов', 3, 400, TRUE),
('Манты', 3, 200, TRUE),
('Чак-Чак', 3, 600, FALSE),
('Арахисовая халва', 3, 300, TRUE),

-- China Club
('Утка по-Пекински', 4, 1000, TRUE),
('Курица гунбао', 4, 500, TRUE),
('Мапо тофу ', 4, 300, TRUE),
('Чаофань ', 4, 259, FALSE),

-- Burger Club
('Чикенбургер', 5, 70, TRUE),
('Двойной чикенбургер', 5, 150, TRUE),
('Бифштекс-Бургер', 5, 280, TRUE),
('Фишбургер', 5, 89, FALSE);


INSERT INTO customers(full_name, email, registtration_date)
VALUES
('Петров Игорь Геннадьевич', 'petrushka@mail.com', '2020-09-22'),
('Сидорова Мария Ивановна', 'mashka@mail.com', '2021-11-11'),
('Маришин Василий Владиславович', 'vaskamarishin@mail.com', '2025-01-19'),
('Сундуков Александр Олегович', 'saenduksashs@mail.com', CURRENT_DATE),
('Меньшев Игорь Трофимович', 'bolshemenhse@mail.com', '2026-02-14');
('Метелин Игорь Федорович', 'igorysik228@mail.com', '2023-12-19'),
('Зима Олег Яковлевич', 'winter@mail.com', '2017-01-15'),
('Дроздова Марина Игоревна', 'drozdmara@mail.com', CURRENT_DATE);

INSERT INTO orders (customer_id, order_date, status)
VALUES
(1, '2026-03-06', 'Принят'),
(2, '2026-03-06', 'Принят'),
(3, '2026-03-07', 'Принят');
(5, '2026-02-16', 'Доставлен'),
(6, '2020-03-01', 'Доставлен'),
(7, '2018-03-10', 'Доставлен'),
(8, '2026-03-06', 'Доставлен');

INSERT INTO order_items(order_id, item_id, quantity)
VALUES
(1, 1, 1),
(1, 2, 2),
(2, 1, 10),
(2, 4, 6),
(2, 3, 9),
(3, 12, 2),
(3, 11, 1),
(3, 10, 12),
(4, 17, 2),
(5, 19, 1),
(5, 9, 1),
(6, 1, 2),
(6, 8, 1),
(7, 18, 3),
(2, 11, 11),
(4, 19, 1),
(4, 2, 4);
(8, 1, 4);
SELECT
	c.full_name,
	r.title,
	o.order_date
FROM customers c
JOIN orders o ON o.customer_id = c.id
JOIN order_items oi ON oi.order_id = o.id
JOIN menu_items m ON m.id = oi.item_id
JOIN restaurants r ON r.id = m.restaurant_id;

SELECT 
	o.id AS order_id,
	m.item_name AS item,
	m.price * oi.quantity AS price_to_item
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN menu_items m ON m.id = oi.item_id;

SELECT 
	c.full_name AS client,
	COUNT(*) AS total_orders
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.full_name
ORDER BY total_orders DESC
LIMIT(1);

SELECT 
	r.title,
	SUM(m.price * oi.quantity) AS revenue
FROM restaurants r
JOIN menu_items m ON m.restaurant_id = r.id
JOIN order_items oi ON oi.item_id = m.id
GROUP BY r.title


SELECT 
	r.title, 
	AVG(m.price * oi.quantity) AS average_check
FROM restaurants r
JOIN menu_items m ON m.restaurant_id = r.id
JOIN order_items oi ON oi.item_id = m.id
GROUP BY title
HAVING AVG(m.price * oi.quantity) >= 500.00;
