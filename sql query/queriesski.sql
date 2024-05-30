use ski_slope;
SELECT *
FROM lift
WHERE price < 30 AND type like 'cabin%';
--------------------

select COUNT(number) as lift_count,isWorking
From lift
group by isWorking;
-------------------------

SELECT cc.age_type,s.difficulty,s.name
FROM club_cards AS cc JOIN
lift_cards AS lc ON cc.card_id=lc.card_id JOIN
lift AS l ON lc.lift_id=l.lift_id JOIN
slopelift AS sl ON l.lift_id=sl.lift_id JOIN
slope AS s ON sl.slope_id=s.slope_id
WHERE cc.age_type="Child";
--------------------------
Select *
from club_cards as cc left join 
lift_cards as lc on cc.card_id=lc.lift_id left join
lift as l on lc.lift_id = l.lift_id;

-------------------------

Select card_id
From club_cards 
where card_id in (Select card_id
				 from lift_cards
				 Where lift_id in (Select lift_id
									from lift
                                    where isWorking =0));
-------------------------
SELECT SUM(e.price * oe.quantity),o.dateOfOrder
FROM order_equipment oe
JOIN orders o ON  oe.order_id=o.order_id
JOIN equipment e ON oe.equipment_id = e.equipment_id
group by o.dateOfOrder;
--------------------------
DROP TRIGGER IF EXISTS after_delete_orders;
delimiter |
CREATE TRIGGER after_delete_orders
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO orders_logs (
        operation,
        old_order_id, 
        old_card_id, 
        old_dateOfOrder, 
        old_totalPrice,
        dateOfLog)
    VALUES (
        'DELETE',
        old.order_id, 
        old.card_id, 
        old.dateOfOrder, 
        old.totalPrice,
        NOW());
END|
delimiter ;

SET foreign_key_checks = 0;
DELETE FROM orders;
SET foreign_key_checks = 1;
select * from orders_logs;
---------------------
use ski_slope;
drop PROCEDURE if exists updateOrderTotal;
DELIMITER |

CREATE PROCEDURE updateOrderTotal()
BEGIN
    DECLARE finished INT DEFAULT FALSE;
    DECLARE totalValue DOUBLE;
    DECLARE currentOrderId INT;
    DECLARE currentCardId INT;
    DECLARE currentCardPrice DOUBLE;
    DECLARE currentLiftPrice DOUBLE;
    DECLARE currentEquipmentPrice DOUBLE;
    
    DECLARE cur CURSOR FOR 
    SELECT order_id, card_id 
    FROM orders;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO currentOrderId, currentCardId;
        IF finished THEN
            LEAVE read_loop;
        END IF;

        SET totalValue = 0;

        SELECT SUM(l.price)
        INTO currentLiftPrice
        FROM lift_cards lc
        JOIN lift l ON lc.lift_id = l.lift_id
        WHERE lc.card_id = currentCardId;

        IF currentLiftPrice IS NOT NULL THEN
            SET totalValue = totalValue + currentLiftPrice;
        END IF;

        SELECT price
        INTO currentCardPrice
        FROM club_cards
        WHERE card_id = currentCardId;

        IF currentCardPrice IS NOT NULL THEN
            SET totalValue = totalValue + currentCardPrice;
        END IF;

        SELECT SUM(e.price * oe.quantity)
        INTO currentEquipmentPrice
        FROM order_equipment oe
        JOIN equipment e ON oe.equipment_id = e.equipment_id
        WHERE oe.order_id = currentOrderId;

        IF currentEquipmentPrice IS NOT NULL THEN
            SET totalValue = totalValue + currentEquipmentPrice;
        END IF;

        UPDATE orders
        SET totalPrice = totalValue
        WHERE order_id = currentOrderId;
    END LOOP;

    CLOSE cur;
END |
DELIMITER ;

CALL updateOrderTotal();

    INSERT INTO order_equipment (order_id, equipment_id, quantity)
VALUES 
    (2, 1, 1);
CALL updateOrderTotal();
select*from orders
use ski_slope
DELIMITER //
CREATE TRIGGER discount_trigger BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE card_purchases INT;
    SELECT COUNT(*) INTO card_purchases FROM orders WHERE card_id = NEW.card_id;
    IF card_purchases > 10 THEN
        SET NEW.totalPrice = NEW.totalPrice * 0.9; -- Applying 10% discount
    END IF;
END;
//
DELIMITER ;