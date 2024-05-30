DROP DATABASE IF EXISTS ski_slope;
CREATE DATABASE ski_slope;
USE ski_slope;

CREATE TABLE slope(
	slope_id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255),
    lenght INT,
    thickness INT,
    altitude int,
    difficulty VARCHAR(255)
);
CREATE TABLE lift(
	lift_id INT AUTO_INCREMENT PRIMARY KEY ,
	name VARCHAR(255),
    number INT unique,
    type ENUM('cabin', 'chairlift', 'draglift'),
    lenght INT,
    price DOUBLE,
    isWorking boolean,
    capacity INT
);
CREATE TABLE club_cards(
card_id INT AUTO_INCREMENT PRIMARY KEY,
day_type  ENUM('Morning', 'Afternoon', 'Night'),
price DOUBLE,
age_type ENUM('Adult', 'Student', 'Child')
);
CREATE TABLE lift_cards(
card_id int,
lift_id int,
primary key(card_id,lift_id),
foreign key(card_id) references club_cards(card_id),
foreign key(lift_id) references lift(lift_id)
);
CREATE TABLE SlopeLift (
    slope_id INT,
    lift_id INT,
    PRIMARY KEY (slope_id, lift_id),
    FOREIGN KEY (slope_id) REFERENCES slope(slope_id),
    FOREIGN KEY (lift_id) REFERENCES lift(lift_id)
);
CREATE TABLE orders(
order_id INT AUTO_INCREMENT PRIMARY KEY,
card_id  INT,
dateOfOrder DATETIME ,
totalPrice Double,
foreign key(card_id) references club_cards(card_id)
);
CREATE TABLE orders_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    operation ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    old_order_id INT,
	new_order_id INT,
    old_card_id INT,
    new_card_id INT,
    old_dateOfOrder DATETIME,
    new_dateOfOrder DATETIME,
    old_totalPrice DOUBLE,
    new_totalPrice DOUBLE,
    dateOfLog DATETIME
);
CREATE TABLE equipment (
    equipment_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    category VARCHAR(255),
    quantity INT,
    price DOUBLE,
    purchase_date DATE
);
CREATE TABLE order_equipment (
    order_id INT,
    equipment_id INT,
    quantity INT,
    PRIMARY KEY (order_id, equipment_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
);

INSERT INTO slope (slope_id, Name, lenght, thickness, altitude, difficulty)
VALUES
    (1, 'Bankso', 5800, 30, 2500, 'Easy'),
    (2, 'Borovetc', 3899, 20, 1800, 'Intermediate'),
    (3, 'Pamporovo', 1000, 15, 2200, 'Difficult'),
    (4, 'Vitosha', 4500, 25, 1900, 'Intermediate'),
    (5, 'Rila', 6200, 40, 2600, 'Difficult'),
    (6, 'Pirin', 5600, 35, 2300, 'Advanced');

INSERT INTO lift (lift_id, name, Number, Type, lenght, Price, isWorking, Capacity)
VALUES
    (1, 'Lift1', 280, 'cabin', 1200, 25.00, true, 2),
    (2, 'Lift2', 120, 'cabin', 900, 15.00, false, 4),
    (3, 'Lift3', 111, 'chairlift', 1000, 10.00, true, 8),
    (4, 'Lift4', 200, 'cabin', 1500, 30.00, true, 6),
    (5, 'Lift5', 80, 'draglift', 800, 25.00, true, 2),
    (6, 'Lift6', 150, 'chairlift', 1000, 20.00, true, 4);
    
INSERT INTO club_cards (card_id, day_type, Price, age_type)
VALUES
	(1, 'Morning', 40.00, 'Adult'),
    (2, 'Afternoon', 40.00, 'Adult'),
    (3, 'Night', 35.00, 'Student'),
    (4, 'Afternoon', 25.00, 'Child'),
    (5, 'Afternoon', 40.00, 'Adult'),
    (6, 'Night', 35.00, 'Student'),
    (7, 'Afternoon', 45.00, 'Adult'),
    (8, 'Night', 30.00, 'Student'),
    (9, 'Morning', 35.00, 'Child');
    
INSERT INTO lift_cards(card_id,lift_id)
VALUES	(1,1),
		(2,2),
		(3,3),
		(4,4),
		(5,5),
        (6,6),
        (7,1),
		(8, 2),
		(9, 3);
INSERT INTO SlopeLift (slope_id, lift_id)
VALUES
    (1, 1),
    (2, 1),
    (3, 3),
    (4, 3),
    (5, 5),
    (6, 6);
    INSERT INTO orders (card_id, dateOfOrder, totalPrice)
VALUES
    (1, '2024-04-23 10:00:00', 40.00),
    (2, '2024-04-24 12:30:00', 40.00),
    (3, '2024-04-25 18:45:00', 35.00);
    INSERT INTO equipment (name, category, quantity, price, purchase_date)
VALUES 
    ('Skis', 'Ski', 10, 100.00, '2023-01-15'),
    ('Snowboard', 'Snowboard', 8, 150.00, '2023-02-10'),
    ('Helmet', 'Cloths', 15, 50.00, '2023-01-20'),
    ('Poles', 'Ski', 15, 50.00, '2023-03-05'),
    ('Snowshoes', 'Snowboard', 5, 100.00, '2023-02-28'),
    ('Goggles', 'Cloths', 20, 30.00, '2023-01-25');
    INSERT INTO order_equipment (order_id, equipment_id, quantity)
VALUES 
    (1, 1, 2),
    (1, 3, 4), 
    (2, 2, 1),
    (3, 1, 1),
    (3, 3, 2);
