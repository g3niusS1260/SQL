import psycopg2 

connection = psycopg2.connect(
    dbname="food_delivery_pro", 
    user="postgres", 
    password="MatadorSQL", 
    host="127.0.0.1", 
    port="5432"
)

input_email = input('Введите email: ')

try:
    cursor = connection.cursor()

    # Проверим, есть ли в базе клиент с таким email
    sql_query = f'SELECT * FROM customers WHERE email = \'{input_email}\''

    cursor.execute(sql_query)
    customer = cursor.fetchall()

    if customer: # Если клиент с такой почтой существует
        print(f'Добро пожаловать, {customer[0][1]}')
        customer_id = customer[0][0]
    else: # Если нет - создадим нового клиента
        new_customer_name = input('У вас нет профиля, напишите ФИО для регистрации аккаунта: ')
        sql_insert = """
            INSERT INTO customers (full_name, email)
            VALUES(%s, %s)
            RETURNING id;
        """

        # Отправим INSERT-запрос
        cursor.execute(sql_insert, (new_customer_name, input_email))

        # Получим id нового клиента
        customer_id = cursor.fetchone()[0]
        
    # Создадим заказ
    sql_insert_order = """
        INSERT INTO orders (customer_id, status)
        VALUES(%s, %s)
        RETURNING id
    """

    # Отправим INSERT-запрос
    cursor.execute(sql_insert_order, (customer_id, 'Принят'))

    # Получим id нового заказа
    order_id = cursor.fetchone()[0]

    # Наполним заказ
    count_position = 0 # Счетчик позиций, нужен для того, чтобы проверять наличие блюд в заказе
    while True:
        try: # Если ввели число - спросим сколько порций
            item_id = int(input('Введите ID блюда (или 0 для завершения): '))
            if item_id == 0:
                print('Заказ собран!✅')
                break
            try: # Если ввели число - добавим заказ
                quantity = int(input('Сколько порций? : '))  

                sql_insert_order_items = """
                     INSERT INTO order_items (order_id, item_id, quantity)
                     VALUES(%s, %s, %s)
                 """

                # Отправим INSERT-запрос
                cursor.execute(sql_insert_order_items, (order_id, item_id, quantity))

                # Увеличим наш счетчик
                count_position += 1

            except ValueError:
                print('❌Количество должно быть числовым значением❌')
                continue
        except ValueError:
            print('❌ID блюда должно быть числовым значением❌')
            continue
    if count_position > 0: # Если заказ не пустой
        # Когда пользователь ввёл 0 - сделаем коммит
        connection.commit()
        print('=== ЗАКАЗ ОФОРМЛЕН ===')

        # Выведем красивый чек
        sql_query_check = f"""
            SELECT 
                o.id AS order_id,
                SUM(mi.price * oi.quantity) AS total_sum
            FROM orders o
            JOIN order_items oi ON oi.order_id = o.id
            JOIN menu_items mi ON mi.id = oi.item_id
            GROUP BY o.id
            HAVING o.id = {order_id};
        """

        # Отправим INSERT-запрос
        cursor.execute(sql_query_check)

        # Получим чек
        check = cursor.fetchall()

        print(f'ID заказа: {check[0][0]}\nЦена заказа: {check[0][1]}')
        print('=== ЗАКАЗ ОФОРМЛЕН ===')
    else: # Если заказ оказался пустым (если пользователь сразу ввёл 0)
        raise ValueError
except psycopg2.Error as error_message:
    print(f'У-упс, возникла ошибка: {error_message}')
except ValueError:
    print('Что-то пошло не так, возможно вы не указали блюда в заказе.')
finally:
    cursor.close()
    connection.close()
    print('Связь разорвана')