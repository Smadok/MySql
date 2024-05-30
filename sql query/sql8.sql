use school_sport_clubs;
drop procedure IF exists checkMothTax ;
delimiter |
CREATE procedure checkMothTax(IN studId INT, IN groupId INT, IN paymentMonth INT, IN paymentYear INT)
BEGIN
DECLARE result INT;
SET result = 0;
	IF( SELECT paymentAmount
		FROM taxespayments
		WHERE student_id = studId
		AND group_id = groupId
		AND MONTH = paymentMonth
		AND year = paymentYear)
    THEN
		SET result = 1;
	ELSE
		SET result = 0;
    END IF;
    
SELECT result as IsTaxPayed;
end;
|
delimiter ;
CALL `school_sport_clubs`.`checkMothTax`(1, 1,1,2015);

Delimiter $

Create procedure proc1(in random int)
Begin
declare result int;
set result=0;
IF( SELECT paymentAmount
		FROM taxespayments
		WHERE student_id = studId
		AND group_id = groupId
		AND MONTH = paymentMonth
		AND year = paymentYear)
        then
        set result=1;
        else
        set result=0;
        end if;
        Select result;
End$
Delimiter ;




#drop procedure getAllPaymentsAmount;
delimiter |
CREATE procedure getAllPaymentsAmount(IN firstMonth INT, IN secMonth INT, IN paymentYear INT, IN studId INT)
BEGIN
	DECLARE iterator int;
	IF(firstMonth >= secMonth)
    THEN 
		SELECT 'Please enter correct months!' as RESULT;
	ELSE IF((SELECT COUNT(*)
			FROM taxesPayments
			WHERE student_id =studId ) = 0)
        THEN SELECT 'Please enter correct student_id!' as RESULT;
		ELSE
	
	SET ITERATOR = firstMonth;

		WHILE(iterator >= firstMonth AND iterator <= secMonth)
		DO
			SELECT student_id, group_id, paymentAmount, month
			FROM taxespayments
			WHERE student_id = studId
			AND year = paymentYear
			AND month = iterator;
    
			SET iterator = iterator + 1;
		END WHILE;
		END IF;
    
    END IF;
END;
|
DELIMITER ;
CALL getAllPaymentsAmount(1,6,2015,1);


drop procedure if exists test2;
delimiter |
Create procedure test2(IN firstMonth INT, IN secMonth INT, IN paymentYear INT, IN studId INT)
Begin
DECLARE iterrator INT;
create temporary table tempTbl(
student_id int, 
group_id int,
paymentAmount double,
month int
)Engine=Memory;
if(firstMonth>=secMonth)
then select"error" as result;
else 
		if((Select COUNT(*) from taxespayments where student_id=studId)=0)
        then select"error" as result;
        else
        Set iterrator = firstMonth;
        
        while iterrator<=secMonth do
        INSERT INTO tempTbl
        SELECT student_id, group_id, paymentAmount, `month`
        from taxespayments
        where student_id=studId
        and `year` = paymentYear
        and `month`=iterrator;
        set iterrator=iterrator+1;
        end while;
		end if;
end if;
SELECT *
        FROM tempTbl;

End |
delimiter ;
CALL test2(1,6,2023,1);
CALL getAllPaymentsAmount(1,6,2023,1);




use school_sport_clubs;

drop procedure if exists OPTIMIZED_monthHonorariumPayment;

delimiter |
create procedure OPTIMIZED_monthHonorariumPayment(IN monthOfPayment INT, in yearOFpayment INT)
procLabel: begin
declare countOfCoaches int;
declare iterator int;
declare countOfRowsBeforeUpdate int;
declare countOfRowsAfterUpdate int;
declare finished int;
declare tempCoachId int;
declare tempSumOfHours int;

 DECLARE tempCoachCursor CURSOR FOR
    SELECT  coach_id, SUM(number_of_hours)
	FROM coach_work
	where month(coach_work.date) = monthOfPayment
	AND YEAR(coach_work.date) = yearOFpayment
	AND isPayed = 0
	GROUP BY coach_work.coach_id;
    
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SELECT 'SQL Exception';
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

create temporary table tempTbl(
id int auto_increment primary key,
coach_id int,
number_of_hours int,
pay_for_hour decimal,
amount decimal,
paymentMonth int,
paymentYear int
)Engine = Memory;
	
	#Плащане на редовна месечна заплата:
    SET @RESULT =0;
    call monthSalaryPayment(monthOfPayment, yearOFpayment, @RESULT);
    SELECT @RESULT as resultFromMonhtPayment; #only for control and test
    
   	SELECT COUNT(*)
    INTO countOfRowsBeforeUpdate
    FROM coach_work
    where month(coach_work.date) = monthOfPayment
    AND YEAR(coach_work.date) = yearOFpayment
    AND isPayed = 0;
    
    START TRANSACTION;
    OPEN tempCoachCursor;
    set finished = 0;
while_loop_label: WHILE(finished = 0)
	DO
	FETCH tempCoachCursor INTO  tempCoachId, tempSumOfHours;
		
   IF(finished = 1)
      THEN leave while_loop_label;
      ELSE
	SELECT  tempCoachId, tempSumOfHours;
	INSERT INTO tempTbl(coach_id, number_of_hours, pay_for_hour, amount, paymentMonth, paymentYear)
	SELECT tempCoachId, tempSumOfHours, c.hour_salary, tempSumOfHours*c.hour_salary, monthOfPayment, yearOFpayment
        FROM coaches as c
	WHERE c.id = tempCoachId;
	END IF;
	END WHILE;
    CLOSE tempCoachCursor;
    
    SELECT * FROM tempTbl;#only for control and test
	INSERT INTO salarypayments(`coach_id`, `month`,`year`,`salaryAmount`,`dateOfPayment`)
        SELECT coach_id, paymentMonth, paymentYear, amount, NOW()
	FROM tempTbl
        ON DUPLICATE KEY UPDATE 
        salaryAmount = salaryAmount + amount,
        dateOfPayment = NOW();

	UPDATE coach_work
	SET isPayed = 1
	WHERE month(coach_work.date) = monthOfPayment
	AND YEAR(coach_work.date) = yearOFpayment
	AND isPayed = 0;
	SELECT  ROW_COUNT() INTO countOfRowsAfterUpdate;
    SELECT countOfRowsAfterUpdate as countOfRowsAfterUpdate; #only for control and test
    SELECT countOfRowsBeforeUpdate as countOfRowsBeforeUpdate;#only for control and test
	  IF(countOfRowsBeforeUpdate = countOfRowsAfterUpdate)
      THEN 
		commit;
      ELSE
		rollback;
      END IF;
	drop table tempTbl;
END;
|
delimiter ;



delimiter |
create event nam
ON SCHEDULE every 1 day
STARTS TIMESTAMP(CURRENT_DATE, '08:00:00') 
DO
BEGIN
declare previous_day date;
SET previous_day = DATE_SUB(CURDATE(), INTERVAL 1 DAY);

INSERT INTO daily_reports (sale_date, product_name, quantity, total_amount)
    SELECT sale_date, product_name, quantity, total_amount
FROM sales
WHERE DATE(sale_date) = previous_day;

END
|
delimiter ;

delimiter |
create trigger triger1

before update on employees
for each row
begin
if day(new.date_of_birth)=day(now()) and month(new.date_of_birth)=month(now()) then
set new.salary=new.salary*1.05;
end
delimiter ;

delimiter |
create procedure pro1(in start_date date, in end_date date, out total_sales double)
begin
declare finished int default 0
declare total double default 0.00
declare total_sales double

Start transaction

declare cur cursor for
select amount
from table1
where sale_date between start_date and end_date
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
read_loop: while(finished=0) do
fetch cur into sale_amount
IF (finished = 1) THEN
            LEAVE read_loop;
        END IF;
        set total = total+sale_amount;
        end while;
        close cursor;
        SET total_sales = total;
		commit;
end
delimiter ;







Delimiter $
create procedure test(in p_store_id int,in p_film_id int,in p_customer_id int )
begin
	DECLARE film_available INT;
    
    SELECT COUNT(*)
    INTO film_available
    FROM inventory
    WHERE store_id = store_id
      AND film_id = film_id
      AND available = TRUE;

    IF film_available > 0 THEN
        -- Добавяне на запис в таблицата за наеми (rentals)
        INSERT INTO rentals (rental_date, inventory_id, customer_id, return_date)
        VALUES (NOW(), 
                (SELECT inventory_id FROM inventory WHERE store_id = store_id AND film_id = film_id AND available = TRUE LIMIT 1), 
                customer_id, 
                NULL);

	
        UPDATE inventory
        SET available = FALSE
        WHERE store_id = store_id
          AND film_id = film_id
          AND available = TRUE;

        SELECT 'успешно нает.' AS result;
    ELSE
        SELECT 'не е наличен за наем.' AS result;
    END IF;
      
      

end
delimiter ;



