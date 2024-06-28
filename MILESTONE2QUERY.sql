# Pet Database SQL Statements
use mm_5075_04;

# SQL Query 1. Top 10 Highest Earning Sitters
SELECT	sitter.sitter_id,
		sitter.sitter_firstname, 
        sitter.sitter_lastname, 
        SUM(booking.transaction_amount) as total_earned
FROM	sitter
		INNER JOIN booking
        ON sitter.sitter_id = booking.sitter_id
GROUP BY sitter.sitter_id
ORDER BY total_earned desc
LIMIT 10;

# SQL 2. Owners with Unpaid Bills
SELECT	o.owner_id,
		o.owner_firstname,
		o.owner_lastname,
        SUM(b.transaction_amount) as amount_due
FROM	`owner` as o
		INNER JOIN booking as b
        ON o.owner_id = b.owner_id
        INNER JOIN `schedule` as s
        ON b.schedule_id = s.schedule_id
WHERE	b.transaction_status = 'UNPAID'
		AND s.schedule_end_time < NOW()
GROUP BY owner_id
ORDER BY amount_due DESC
LIMIT 10;

# SQL Query 3. Pet Species By Hours Watched
SELECT	DISTINCT 
		pet.pet_species,
        hours_by_species.hours_watched,
		(hours_by_species.hours_watched / total_watched.total_hours) as perc_of_hours_watched
FROM	pet
		INNER JOIN (
			SELECT	pet_species,
					SUM((time_to_sec(timediff(schedule_end_time, schedule_start_time))/3600)) as hours_watched
			FROM	pet
					INNER JOIN `schedule`
                    ON pet.pet_id = `schedule`.pet_id
                    INNER JOIN booking
                    ON `schedule`.schedule_id = booking.schedule_id
			GROUP BY pet_species
        ) hours_by_species
        INNER JOIN (
			SELECT	SUM((time_to_sec(timediff(schedule_end_time, schedule_start_time))/3600)) as total_hours
			FROM	pet
					INNER JOIN `schedule`
                    ON pet.pet_id = `schedule`.pet_id
                    INNER JOIN booking
                    ON `schedule`.schedule_id = booking.schedule_id
        ) as total_watched
WHERE	hours_by_species.pet_species = pet.pet_species
ORDER BY perc_of_hours_watched DESC; 

# SQL 4. The Dogs Being Watched the Most
SELECT	pet.pet_id,
		pet.pet_name,
		SUM((time_to_sec(timediff(schedule_end_time, schedule_start_time))/3600)) as hours_watched
FROM	pet
		INNER JOIN `schedule`
        ON pet.pet_id = `schedule`.pet_id
        INNER JOIN booking
        ON `schedule`.schedule_id = booking.schedule_id
WHERE	pet_species like '%Dog%'
GROUP BY pet.pet_id
ORDER BY hours_watched DESC
LIMIT 10;

# SQL 5. Sitters with the Highest Ratings
SELECT	sitter.sitter_id,
		sitter.sitter_firstname,
		sitter.sitter_lastname,
        AVG(review.review_rating) as average_rating,
        COUNT(review.review_id) as number_of_reviews
FROM	sitter
		INNER JOIN review
        ON sitter.sitter_id = review.sitter_id
GROUP BY sitter.sitter_id
HAVING COUNT(review.review_id) > 1
ORDER BY average_rating DESC, number_of_reviews DESC
LIMIT 10;