#курсори
use school_sport_clubs;
drop procedure if exists  CursorTest;
delimiter |
create procedure CursorTest()
begin
declare finished int;
declare tempName varchar(100);
declare tempEgn varchar(10);
declare coachCursor CURSOR for
SELECT name, egn
from coaches
where month_salary is not null;
declare continue handler FOR NOT FOUND set finished = 1;
set finished = 0;
OPEN coachCursor;
coach_loop: while( finished = 0)
DO
FETCH coachCursor INTO tempName,tempEgn;
       IF(finished = 1)
       THEN 
       LEAVE coach_loop;
       END IF;	
       SELECT tempName,tempEgn; # or do something with these variables...
end while;
CLOSE coachCursor;
SET finished = 0;
SELECT 'Finished!';
end|

delimiter ;
call CursorTest()





DELIMITER $

CREATE PROCEDURE cursor_proc()
BEGIN
    DECLARE finished INT DEFAULT 0;
    DECLARE tempName VARCHAR(100);
    DECLARE tempEgn VARCHAR(100);
    
    DECLARE cursor1 CURSOR FOR
        SELECT name, egn
        FROM coaches
        WHERE month_salary IS NOT NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET finished = 1;

    OPEN cursor1;

    coach_loop: WHILE (finished = 0) DO
        FETCH cursor1 INTO tempName, tempEgn;
        IF (finished = 1) THEN
            LEAVE coach_loop;
        END IF;
        
        -- You can do something with tempName and tempEgn here
        -- For example: 
        -- SELECT tempName, tempEgn;

        -- Displaying the values (for demonstration)
        SELECT CONCAT('Name: ', tempName, ', EGN: ', tempEgn) AS CoachDetails;
    END WHILE;

    CLOSE cursor1;
    SET finished = 0;
    SELECT 'Finished!' AS Status;
END$

DELIMITER ;
CALL cursor_proc();


