import psycopg2

DB_CONFIG = {
    "dbname": "food_delivery_pro",
    "user": "postgres",
    "password": "MatadorSQL",
    "host": "127.0.0.1",
    "port": "5432"
}

conn = None

try:
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    print("Успешное подключение к БД!")

    # Запускаем бесконечное меню
    while True:
        print("\n=== ПАНЕЛЬ АДМИНИСТРАТОРА ===")
        print("1. Показать меню ресторана")
        print("2. Массовое изменение цен")
        print("3. Управление стоп-листом")
        print("4. Добавить новое блюдо в меню")
        print("5. Отчет по выручке ресторана")
        print("6. Изменение статуса заказа")
        print("7. Поиск клиента по части имени")
        print("0. Выход")

        choice = input("Выберите действие (0-7): ").strip()

        if choice == '0':
            print("До свидания!")
            break
        elif choice == '1':
            rest_id = input("Введите ID ресторана: ")
            sql = "SELECT item_name, price, is_available FROM menu_items WHERE restaurant_id = %s ORDER BY id;"
            cursor.execute(sql, (rest_id,))
            items = cursor.fetchall()

            if not items:
                print("Блюд не найдено!")
                continue

            print(f"\n--- МЕНЮ (Ресторан ID {rest_id}) ---")
            for row in items:
                name, price, available = row[0], row[1], row[2]
                status = "" if available else "[НЕТ В НАЛИЧИИ]"
                print(f"- {name:<24} | {price} руб. {status}")

        elif choice == '2':
            rest_id = input("Введите ID ресторана: ")
            percent = float(input("Процент наценки: "))
            # 15% = 1.15
            multiplier = 1 + (percent / 100)

            # Достаем текущие цены
            sql_select = "SELECT id, item_name, price FROM menu_items WHERE restaurant_id = %s AND is_available = TRUE;"
            cursor.execute(sql_select, (rest_id,))
            items = cursor.fetchall()

            if not items:
                print("Нет доступных блюд.")
                continue

            # Предпросмотр
            print("\n--- ПРЕДВАРИТЕЛЬНЫЙ ПРОСМОТР ---")
            for row in items:
                item_id, name, old_price = row[0], row[1], float(row[2])
                new_price = round(old_price * multiplier, 2)
                print(f"{name:<15} | {old_price} ---> {new_price} руб.")

            # Запрашиваем разрешение
            confirm = input("\nПрименить изменения в базе? (Y/N): ").strip().upper()

            if confirm == "Y":
                sql_update = """
                    UPDATE menu_items
                    SET price = price * %s
                    WHERE restaurant_id = %s AND is_available = TRUE;
                """
                cursor.execute(sql_update, (multiplier, rest_id))
                conn.commit()
                print(f"[УСПЕХ] Цены обновлены у {cursor.rowcount} блюд!")
            else:
                print("[ОТМЕНА] Ничего не меняли.")

        elif choice == '3':
            item_id = input("Введите ID блюда для стоп-листа: ")

            sql = "UPDATE menu_items SET is_available = FALSE WHERE id = %s;"
            cursor.execute(sql, (item_id,))

            if cursor.rowcount > 0:
                conn.commit()
                print(f"[УСПЕХ] Блюдо ID {item_id} добавлено в стоп-лист.")
            else:
                conn.rollback()
                print(f"[ОШИБКА] Блюдо с ID {item_id} не найдено.")
        
        elif choice == '4':
            rest_id = input('Введите id ресторана: ')
            item_name = input('Введите название блюда: ')
            item_price = input('Введите цену блюда: ')

            cursor.execute('INSERT INTO menu_items (item_name, restaurant_id, price) VALUES (%s, %s, %s)', (item_name, rest_id, item_price))

            if cursor.rowcount > 0:
                print(f'Успешно! Блюду присвоен номер: [{rest_id}]')
                conn.commit()
            else:
                print('Ошибка: ошибка в вводе данных.')
                continue
        elif choice == '5':
            rest_id = input('Введите id ресторана: ')

            query_profit = """
            SELECT r.title, SUM(mi.price * oi.quantity) as profit
            FROM restaurants r 
            JOIN menu_items mi ON mi.restaurant_id = r.id
            JOIN order_items oi ON oi.item_id = mi.id
            GROUP BY r.title, r.id
            HAVING r.id = %s
            """
            cursor.execute(query_profit, (rest_id,))

            result = cursor.fetchone()
            print(f'Ресторан: {result[0]}\nПрибыль: {result[1]}')
        elif choice == '6':
            order_id = input('Введите id заказа: ')
            new_status = input('Введите новый статус: ')
            cursor.execute('UPDATE orders SET status = %s WHERE id = %s', (new_status, order_id))

            if cursor.rowcount > 0:
                print(f'Успешно! Заказу с id[{order_id}] обновлен статус на {new_status}')
                conn.commit()
            else:
                print('Ошибка в вводе данных')
                continue
        
        elif choice == '7':
            excerpt = input('Введите отрывок имени: ')
            sql = 'SELECT * FROM customers WHERE full_name LIKE %s'
            search_param = f'%{excerpt}%'
            cursor.execute(sql, (search_param,))
            customers = cursor.fetchall()
            print(customers)
            if customers:
                print(f'{'id':<4} | {'Полное имя':<30} | {'Почта':<20}')
                print('-' * 55)
                for customer in customers:
                    print(f'{customer[0]:<4} | {customer[1]:<30} | {customer[2]:<20}')
                    print('-' * 55)
            else:
                print('Совпадений не найдено')
                continue
        else:
            print("Ошибка: введите цифру от 0 до 3.")
        

except psycopg2.Error as e:
    print(f"\n[КРИТИЧЕСКАЯ ОШИБКА БД]: {e}")
    if conn:
        conn.rollback()

finally:
    if conn:
        conn.close()
        print("Соединение с базой закрыто.")
