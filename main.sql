INSERT INTO customers (full_name, email, registtration_date)
VALUES ('Иванов Иван', 'ivashka@mail.com', CURRENT_DATE);

-- Задание 1
-- Начало транзакции
BEGIN;

-- Запись нового заказа
INSERT INTO orders (customer_id, order_date, status)
VALUES(9, CURRENT_DATE, 'Принят')
RETURNING id; -- Возвращаем id после создания заказа

-- Запись блюд в заказ
INSERT INTO order_items(order_id, item_id, quantity)
VALUES
(currval(pg_get_serial_sequence('orders', 'id')), 3, 2),
(currval(pg_get_serial_sequence('orders', 'id')), 1, 1),
(currval(pg_get_serial_sequence('orders', 'id')), 2, 1);

-- Сохраняем транзакцию
COMMIT;

-- Задание 2
-- Начало транзакции
BEGIN;

-- Создаем заказ
INSERT INTO orders (customer_id, order_date, status)
VALUES(6, CURRENT_DATE, 'Принят')
RETURNING id;

-- Добавляем в order_items блюдо с id = 8, но с неверным количеством 0
INSERT INTO order_items (order_id, item_id, quantity)
VALUES (currval(pg_get_serial_sequence('orders', 'id')), 8, 0);

-- Сохраняем транзакцию
COMMIT;

-- Мы получили ошибку, значит отменяем транзакцию
ROLLBACK;

Задание 3
Создадим индекс для более быстрого поиска 
CREATE INDEX customers_full_name_index
ON customers(full_name);
