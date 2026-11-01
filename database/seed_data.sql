INSERT INTO room_types (id, name, description, base_price, capacity, amenities) VALUES
('rt_standard', 'Стандартный двухместный', 'Уютный светлый номер с двуспальной кроватью, Wi-Fi и кондиционером.', 3500.00, 2, 'Wi-Fi, Кондиционер, Душ, Телевизор'),
('rt_comfort', 'Комфорт улучшенный', 'Просторный номер повышенного комфорта с мини-баром и рабочей зоной.', 5200.00, 3, 'Wi-Fi, Кондиционер, Ванна, Телевизор, Мини-бар, Сейф'),
('rt_suite', 'Люкс Премиум', 'Двухкомнатный номер с панорамным видом на город, джакузи и гостиной.', 9500.00, 4, 'Wi-Fi, Кондиционер, Джакузи, Smart TV, Мини-бар, Сейф, Панорамный вид, Халаты'),
('rt_presidential', 'Президентский Сьют', 'Роскошный представительский сьют с личной террасой и отдельной обеденной зоной.', 18000.00, 5, 'Wi-Fi, Климат-контроль, Джакузи, Smart TV 65", Премиум мини-бар, Терраса, Личный батлер');

INSERT INTO rooms (id, number, floor, room_type_id, status, notes) VALUES
('rm_101', '101', 1, 'rt_standard', 'available', NULL),
('rm_102', '102', 1, 'rt_standard', 'available', NULL),
('rm_103', '103', 1, 'rt_standard', 'cleaning', NULL),
('rm_201', '201', 2, 'rt_comfort', 'occupied', 'Постоялец продлил проживание'),
('rm_202', '202', 2, 'rt_comfort', 'available', NULL),
('rm_203', '203', 2, 'rt_comfort', 'maintenance', 'Плановый ремонт сантехники'),
('rm_301', '301', 3, 'rt_suite', 'available', NULL),
('rm_302', '302', 3, 'rt_suite', 'occupied', NULL),
('rm_401', '401', 4, 'rt_presidential', 'available', 'Представительский этаж');

INSERT INTO services (id, name, price, description) VALUES
('srv_1', 'Завтрак "Шведский стол"', 800.00, 'Разнообразный шведский стол с 07:00 до 11:00'),
('srv_2', 'Посещение СПА-комплекса', 1500.00, 'Бассейн, финская сауна, хаммам'),
('srv_3', 'Трансфер из аэропорта', 2000.00, 'Встреча в зале прилета на комфортабельном седане'),
('srv_4', 'Прачечная и химчистка', 600.00, 'Срочная стирка и глажка одежды'),
('srv_5', 'Поздний выезд (до 18:00)', 1800.00, 'Продление проживания до вечера');

INSERT INTO guests (id, full_name, phone, email, birth_date, discount_percent) VALUES
('gst_1', 'Иван Сергеевич Иванов', '+79161234567', 'guest@hotel.ru', '1990-04-15', 10.00),
('gst_2', 'Елена Павловна Васильева', '+79219876543', 'elena.v@example.com', '1985-11-23', 5.00),
('gst_3', 'Дмитрий Александрович Кузнецов', '+79035554433', 'kuznetsov@example.com', '1993-07-08', 0.00);

INSERT INTO passports (id, guest_id, series, number, issued_by, issue_date, registration_address) VALUES
('pass_1', 'gst_1', '4510', '123456', 'ГУ МВД по г. Москве', '2015-05-20', 'г. Москва, ул. Тверская, д. 12, кв. 45'),
('pass_2', 'gst_2', '4012', '654321', 'УФМС по г. Санкт-Петербургу', '2018-09-14', 'г. Санкт-Петербург, Невский пр-т, д. 88, кв. 12'),
('pass_3', 'gst_3', '2214', '789101', 'МВД по Нижегородской обл.', '2020-02-10', 'г. Нижний Новгород, ул. Белинского, д. 5, кв. 2');

INSERT INTO bookings (id, guest_id, room_id, check_in_date, check_out_date, status, total_price, notes) VALUES
('bk_1', 'gst_1', 'rm_201', CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE + INTERVAL '3 day', 'checked_in', 21020.00, 'Гость просил номер с видом на парк'),
('bk_2', 'gst_2', 'rm_302', CURRENT_DATE, CURRENT_DATE + INTERVAL '2 day', 'checked_in', 20850.00, NULL),
('bk_3', 'gst_3', 'rm_101', CURRENT_DATE + INTERVAL '5 day', CURRENT_DATE + INTERVAL '8 day', 'confirmed', 11300.00, NULL);

INSERT INTO booking_services (id, booking_id, service_id, quantity, price_at_booking, total_amount) VALUES
('bs_1', 'bk_1', 'srv_1', 1, 800.00, 800.00),
('bs_2', 'bk_1', 'srv_2', 1, 1500.00, 1500.00),
('bs_3', 'bk_2', 'srv_1', 1, 800.00, 800.00),
('bs_4', 'bk_2', 'srv_3', 1, 2000.00, 2000.00),
('bs_5', 'bk_3', 'srv_1', 1, 800.00, 800.00);

INSERT INTO payments (id, booking_id, guest_name, amount, payment_method, status, transaction_code) VALUES
('pay_1', 'bk_1', 'Иван Сергеевич Иванов', 21020.00, 'card', 'completed', 'TX-948102'),
('pay_2', 'bk_2', 'Елена Павловна Васильева', 20850.00, 'sbp', 'completed', 'TX-104928'),
('pay_3', 'bk_3', 'Дмитрий Александрович Кузнецов', 2000.00, 'card', 'completed', 'TX-554433');

INSERT INTO employees (id, full_name, position, phone, email, shift, salary, hire_date) VALUES
('emp_1', 'Орлов Михаил Юрьевич', 'manager', '+79001112233', 'manager@hotel.ru', 'Дневная', 120000.00, '2021-03-01'),
('emp_2', 'Смирнова Анна Викторовна', 'receptionist', '+79004445566', 'reception@hotel.ru', '1/3', 65000.00, '2022-06-15'),
('emp_3', 'Ковалева Мария Петровна', 'maid', '+79007778899', 'kovaleva@hotel.ru', '2/2', 48000.00, '2023-01-10'),
('emp_4', 'Романов Артем Игоревич', 'concierge', '+79002223344', 'romanov@hotel.ru', '2/2', 55000.00, '2023-04-20');

INSERT INTO reviews (id, guest_id, guest_name, rating, comment, response) VALUES
('rev_1', 'gst_1', 'Иван Сергеевич Иванов', 5, 'Прекрасный отель! Завтрак превзошел ожидания, спа-зона очень чистая.', 'Спасибо за ваш теплый отзыв! Всегда рады видеть вас снова!'),
('rev_2', 'gst_2', 'Елена Павловна Васильева', 4, 'Очень просторный люкс и отличная шумоизоляция. Единственное — трансфер задержался на 10 минут.', 'Приносим извинения за задержку трансфера из-за дорожных пробок. Будем рады новой встрече!');
