use ski_slope;

Select * FROM lift
Where price <20;

select COUNT(number),isWorking
From lift
group by isWorking;

Select *
from club_cards join 
lift_cards on club_cards.card_id=lift_cards.lift_id join
lift on lift_cards.lift_id = lift.lift_id;


Select card_id,age_type
From club_cards 
where card_id in (Select card_id
				 from lift_cards
				 Where lift_id in (Select lift_id
									from lift
                                    where lift_id =1));
Select Count(club_cards.card_id)
from club_cards join
lift_cards on club_cards.card_id=lift_cards.lift_id join
lift on lift_cards.lift_id = lift.lift_id;

select * from lift_cards;
