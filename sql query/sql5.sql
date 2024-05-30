use school_sport_clubs;
select sports.name, sportgroups.location
FROM sports LEFT JOIN sportgroups
ON sports.id = sportgroups.id;

use school_sport_clubs;
select sports.name,coaches.name
FROM sports JOIN coaches
ON sports.id IN (SELECT sport_id
				FROM sportgroups
                WHERE 
                sportgroups.coach_id = coaches.id
				);
USE school_sport_clubs;
INSERT INTO `students` (`name`,`egn`,`address`,`phone`,`class`) 
VALUES ('Ivan Ivanov Ivanov','9207186371','София-Сердика','0888892950','10');

select * from students
ORDER BY name;

DELETE FROM students
WHERE egn='9207186371';

SELECT students.name,sports.name
From students join sports
ON students.id IN(select student_id
					FROM student_sport
                    Where student_sport.student_id=sports.id);
                    
SELECT students.name, students.class, sportgroups.id
 FROM students JOIN sportgroups
 ON students.id IN (
	SELECT student_id
	FROM student_sport
	WHERE student_sport.sportGroup_id = sportgroups.id 
 )
 where sportgroups.dayOfWeek = 'Monday';
 

 
select sports.name,coaches.name
FROM coaches JOIN sports
ON coaches.id IN (SELECT coach_id
				FROM sportgroups
                WHERE 
                sportgroups.sport_id = sports.id 
				)
                where sports.name='Football';
select sportgroups.location,sportgroups.dayOfWeek,sportgroups.hourOfTraining,sports.name
from sportgroups join sports
ON sportgroups.id in (select id
					From sports
                    Where sportgroups.sport_id=sports.id)
where sports.name='Volleyball'; 

(select s.name as Sport, sg.location as place
from sports as s left join sportgroups as sg
on s.id=sg.sport_id)union

(select s.name as Sport, sg.location as place
from sports as s right join sportgroups as sg
on s.id=sg.sport_id);

select firstStud.name as Student1, secondStud.name as Student2, sports.name as sport
from students as firstStud
join students as secondStud
on firstStud.id>secondStud.id
join sports on firstStud.id in ( select student_id
								 from student_sport
								 where sportGroup_id in (select id from sportgroups
														 where sportgroups.sport_id=sport_id))
AND secondStud.id in ( 	select student_id
						from student_sport
						where sportGroup_id in ( select id from sportgroups
												where sportgroups.sport_id=sports.id))
Where firstStud.id in (select student_id
						from student_sport
                        where sportGroup_id in (select sportGroup_id
												from student_sport
												where student_id=secondStud.id))
order by sport;

select name
from students
where id in (select student_id
			from student_sport
            where sportGroup_id in (select id
									from sportgroups
									where sport_id in (select id 
														from sports
                                                        where name ='Football')));
									
select name
from coaches
where id in(select id
			from sportgroups
            where coach_id in ( select id 
								from sports
								where sports.id=2));

select distinct sports.name ,coaches.name
from sports join sportgroups
on sports.id = sportgroups.sport_id join
student_sport on sportgroups.sport_id = student_sport.sportGroup_id join
students on student_sport.sportGroup_id=students.id join
coaches on sportgroups.coach_id = coaches.id
where students.id=1;



                                
