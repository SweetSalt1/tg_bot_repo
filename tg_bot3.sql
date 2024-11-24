CREATE DATABASE IF NOT EXISTS python_tbot;
USE python_tbot;

CREATE TABLE IF NOT EXISTS users
(
	id INT AUTO_INCREMENT PRIMARY KEY,   				-- Уникальный код пользователя
	vk_id VARCHAR(35) NOT NULL,							-- вк id (обязательно)
    telegram_id VARCHAR(32) NOT NULL DEFAULT 'none',	-- телеграмм id (обязательно)
    tg_username VARCHAR(35) NOT NULL DEFAULT 'none',	-- имя в телеграмме
    FIO VARCHAR(35) NOT NULL DEFAULT 'none',			-- Фамилия Имя Отчество (в 1 строку)
    role_user VARCHAR(25) DEFAULT '-',					-- Роль в отряде
    group_user VARCHAR(10),								-- группа (кратко)
    institute VARCHAR(30),								-- Название института
    email VARCHAR(25),									-- Почта (можно не заполнять, потому что нет NOT NULL)
	phone_num VARCHAR(18),								-- Телефон (Можно не заполнять, потому что нет NOT NULL)
	UNIQUE (email, phone_num)							-- Элементы в этих столбцах могут быть только уникальными
);

CREATE TABLE notifications 
(
    id INT AUTO_INCREMENT PRIMARY KEY, 					-- Уникальный идентификатор уведомления
    title VARCHAR(255) NOT NULL,       					-- Заголовок уведомления (обязательно)
    message TEXT NOT NULL,             					-- Текст уведомления (обязательно)
    send_time DATETIME,       							-- Дата и время запланированной отправки (вручную)
    foto_url TEXT,                    					-- Ссылка на изображение, видео, аудио или геолокацию
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 		-- Время создания уведомления (автоматически)
);

-- Связь 2 первых таблиц
CREATE TABLE user_notifications
(
    id INT AUTO_INCREMENT PRIMARY KEY,          								-- Уникальный идентификатор связи
    user_id INT NOT NULL,                       								-- ID пользователя
    notification_id INT NOT NULL,               								-- ID уведомления
    status_ ENUM('pending', 'sent', 'failed') DEFAULT 'pending', 				-- Статус отправки уведомления
    sent_at DATETIME DEFAULT NULL,              										-- Время, когда уведомление было отправлено
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,						-- Связь с таблицей users
    FOREIGN KEY (notification_id) REFERENCES notifications(id) ON DELETE CASCADE		-- Связь с таблицей notifications
);

CREATE TABLE events_ 
(
    id INT AUTO_INCREMENT PRIMARY KEY,        		-- Уникальный идентификатор мероприятия
    title VARCHAR(255) NOT NULL,              		-- Название мероприятия
    description_ TEXT,                         		-- Описание мероприятия
    event_date DATE NOT NULL,                 		-- Дата проведения мероприятия
    event_time TIME NOT NULL,                 		-- Время проведения мероприятия
    location VARCHAR(255),                   		-- Местоположение мероприятия
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 	-- Дата создания записи
);

-- добавление пользователя
INSERT INTO users (vk_id, telegram_id, tg_username, FIO, role_user, group_user, institute, email, phone_num) -- Cтолбцы 
VALUES ('vk_id', 'telegram_id', 'tg_username', 'F I O', 'role_user', 'group_user', 'institute', 'email', 'phone_num');  -- Что будет заноситься во всю строку по столбцам

-- изменение данных пользователя
UPDATE users
SET role_user = 'komandir', email = 'kjasfhlkjf@gmail.com', phone_num = '+79732341256'
WHERE tg_username = 'abid';

-- Для команды /users 
 SELECT FIO, tg_username role_user FROM users;

-- Для команды /usersInfo
SELECT FIO, tg_username, email, phone_num, group_user, institute FROM users;
 
-- Удаление пользователя
DELETE FROM users 
WHERE id = 42 OR FIO = 'Иван Иванов Иванович';

-- Вывод таблицы users (для обычного пользователя, не админа)
SELECT * FROM users;

-- -----------------------------------------------------------------------------------------------------------------------
-- добавление уведомления
INSERT INTO notifications (title, message, send_time, foto_url)
VALUES ('title', 'messege', 'yyyy-mm-dd hh:mm:ss', 'ссылка');

-- Вывод таблицы notification
SELECT * FROM notifications;

-- вывод данных пользователя и уведомления, а так же изменение статуса уведомления
SELECT 
    u.id AS user_id,						-- ID пользователя из таблицы users, обозначается как user_id в результате.
    u.vk_id,								-- VK ID пользователя из таблицы users.
    u.telegram_id,							-- Telegram ID пользователя из таблицы users.
    u.tg_username,							
    u.FIO,									
    n.id AS notification_id,				-- ID уведомления из таблицы notifications, обозначается как notification_id.			
    n.title,								-- Заголовок уведомления из таблицы notifications
    n.message,								-- Текст уведомления из таблицы notifications.
    n.send_time,							-- время запланированной отправки (вручную)
    un.status_,								-- Статус уведомления (pending, sent, failed) из таблицы user_notifications.
    un.sent_at								-- время создания уведомления (автоматически)
FROM 
    user_notifications un								-- Основная таблица, где хранятся связи между пользователями и уведомлениями.
INNER JOIN 
    users u ON un.user_id = u.id						-- Присоединяем таблицу users: связываем user_notifications.user_id с users.id.
INNER JOIN 
    notifications n ON un.notification_id = n.id		-- Присоединяем таблицу notifications: связываем user_notifications.notification_id с notifications.id.
WHERE 
    un.status = 'pending' 								-- Выбираем только уведомления, которые еще не отправлены
    AND (n.send_time IS NULL OR n.send_time <= NOW()) 	-- Отправляем уведомления с запланированным временем в прошлом или без времени
ORDER BY 
    n.send_time ASC; 									-- Сортируем по времени отправки
    
-- -----------------------------------------------------------------------------------------------------------------------------
-- Добавление нового мероприятия
INSERT INTO events_ (title, description_, event_date, event_time, location) 
VALUES ('Название мероприятия', 'Описание мероприятия', '2024-12-01', '15:00:00', 'Адрес мероприятия');

-- Вывод списка всех мероприятий
SELECT 
    id, 
    title, 
    description_, 
    event_date, 
    event_time, 
    location
FROM 
    events_
ORDER BY 
    event_date DESC, 
    event_time DESC;			-- сортировка в порядке убывания

-- Изменение мероприятия
UPDATE events_
SET 
    title = COALESCE('Новое название', title),					-- Вводится новое название, иначе останется старое
    description_ = COALESCE('Новое описание', description), 
    event_date = COALESCE('2024-12-01', event_date), 
    event_time = COALESCE('15:00:00', event_time), 
    location = COALESCE('Новое местоположение', location)
WHERE 
    id = 42;													-- id мероприятия

-- удаление мероприятия
DELETE FROM events_ 
WHERE id = 42;

