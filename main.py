import psycopg2

DB_CONFIG = {
    'dbname': 'food_delivery_pro',
    'user': 'postgres',
    'password': 'MatadorSQL',
    'host': '127.0.0.1',
    'port': '5432'
}

conn = None
cursor = None
try:
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    menu = """
1 - Показать меню ресторана
2 - Массовое изменение цен 
3 - Управление стоп-листом
0 - Выход\n
"""

    # ВЫВОД МЕНЮ
    choise = 0
    while True:
        choise = input(f'{menu}>>> ')
       
        if choise == '0':
           print('Выходим...')
           break
        # МЕНЮ РЕСТОРАНА
        elif choise == '1':
            # ЗАПРАШИВАЕМ ID РЕСТОРАНА
            restaurant_id_input = int(input('Введите id ресторана: '))

            if restaurant_id_input <= 0:
                print('Id ресторана должно быть положительным числом')
                continue

            cursor.execute(
                'SELECT r.title, m.id, m.item_name, m.price, m.is_available FROM restaurants r JOIN menu_items m ON m.restaurant_id = r.id WHERE restaurant_id = %s',
                (restaurant_id_input,)
            )
            restaurant_menu = cursor.fetchall()

            # ПРОВЕРКА НА СУЩЕСТВОВАНИЕ РЕСТОРАНА
            if restaurant_menu:
                print(f'\n{'Ресторан':<35} | {'ID блюда':<10} | {'Блюдо':<40} | {'Цена':<10} | {'Статус'}')
                print('-' * 120)

                # ВЫВОДИМ МЕНЮ
                for item in restaurant_menu:
                    print(f'{item[0]:<35} | {item[1]:<10} | {item[2]:<40} | {(str(item[3]) + ' руб.'):<10} | {item[4]}')
                    print('-' * 120)
            else: 
                print('Ресторана с таким id нет в базе')

        # МАССОВОЕ ИЗМЕНЕНИЕ ЦЕН
        elif choise == '2':
            # ЗАПРАШИВАЕМ id И ПРОЦЕНТ НАЦЕНКИ
            restaurant_id_input = int(input('Введите id ресторана: '))
            if restaurant_id_input <= 0:
                print('Id ресторана должно быть положительным числом')
                continue

            percent_markup = int(input('На сколько % повысить цены (число): '))
            if percent_markup <= 0:
                print('Процент наценки должен быть положительным числом')
                continue
            # ВЫВОД ОБНОВЛЕНИЙ В ТАБЛИЦЕ
            cursor.execute(
                "SELECT item_name, price, (price + price / 100 * %s) FROM menu_items WHERE restaurant_id = %s",
                (percent_markup, restaurant_id_input)
            )
            new_menu = cursor.fetchall()
            if new_menu:
                print(f'{'Название':<40} | {'Старая цена':<12} | {'Новая цена'}')
                print('-' * 70)
                for item in new_menu:
                    print(f'{item[0]:<40} | {(str(item[1]) + ' руб.'):<12} | {item[2]:.2f} руб.')
                    print('-' * 70)
                
                # ПРИМЕНЯЕМ НОВЫЕ ЦЕНЫ
                is_commit = input('Применить новые цены? (y/n): ')
                if is_commit.lower().strip() == 'y':
                    cursor.execute(
                        "UPDATE menu_items SET price = price + (price / 100) * %s",
                        (percent_markup,)
                    )
                    conn.commit()
                    print('Цены успешно обновлены!')
                elif is_commit.lower().strip() == 'n':
                    print('Действия отменены')
                else:
                    print('Неправильный ввод')
            else:
                print('Ресторана с таким id не существует, или в ресторане нет блюд')

        # УПРАВЛЕНИЕ СТОП-ЛИСТОМ
        elif choise == '3':
            # ЗАПРАШИВАЕМ ID
            item_id_input = int(input('Введите id блюда: '))

            if item_id_input <= 0:
                print('Id блюда должно быть положительным числом')
                continue
            # СООБЩИМ, ЕСЛИ БЛЮДО ИТАК В СТОП-ЛИСТЕ ИЛИ ОТСУТСТВУЕТ ВОВСЕ
            cursor.execute("SELECT is_available, item_name FROM menu_items WHERE id = %s", (item_id_input,))

            # ПОЛУЧИМ РЕЗУЛЬТАТ ЗАПРОСА
            result = cursor.fetchone()
            if not result:
                print(f'Блюда с id {item_id_input} нет в ресторане')
                continue
            elif result[0] == False:
                print(f'Блюдо "{result[1]}" уже находится в стоп-листе')
                continue

            # ИЗМЕНИМ СТАТУС ДОСТУПНОСТИ
            cursor.execute("UPDATE menu_items SET is_available = FALSE WHERE id = %s", (item_id_input,))

            # СОХРАНИМ 
            conn.commit()

            # СООБЩИМ ОБ УСПЕШНОСТИ
            print(f'Блюдо "{result[1]}" добавлено в стоп-лист')
        else:
            print('Ошибка выбора. Ввод должен быть числом (0-3)')
except conn.Error as db_error:
    print(f'Ошибка БД: {db_error}')
    print('Отменяем операцию')
    conn.rollback()
except ValueError:
    print('Ошибка: ввод должен быть числом')
    print('Оменяем операцию')
    conn.rollback()
finally:
    if 'conn' in locals() and conn:
        cursor.close() 
        conn.close()
        print('Соедение разорвано')
