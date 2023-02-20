/*===== Exercise 1: DVD Rental ====*/
-- 1) Get a list of all film languages.
SELECT "language".*
FROM "language"
JOIN film ON film.language_id = language.language_id;

-- 2)
	-- 1) Get all films, even if they don’t have languages.
SELECT film.title, film.description, language.name
FROM film
LEFT JOIN "language" ON "language".language_id = film.language_id;

	-- 2) Get all languages, even if there are no films in those languages.
SELECT film.title, film.description, language.name
FROM language
LEFT JOIN film ON film.language_id = language.language_id;

-- 3) Create a new table called new_film with the following columns : id, name. Add some new films to the table.
CREATE TABLE new_film(
	id SERIAL PRIMARY KEY,
	NAME VARCHAR NOT NULL 
);

INSERT INTO new_film(name)
VALUES('Avenger'),
	   ('Spider Man'),
	   ('Iron Man'),
	   ('Captain America');
	   
/*
	4) Create a new table called customer_review, which will contain film reviews that customers will make.
	Think about the DELETE constraint: if a film is deleted, its review should be automatically deleted.
	It should have the following columns:
	
		1) review_id – a primary key, non null, auto-increment.
		2) film_id – references the new_film table. The film that is being reviewed.
		3) language_id – references the language table. What language the review is in.
		4) title – the title of the review.
		5) score – the rating of the review (1-10).
		6) review_text – the text of the review. No limit on the length.
		7) last_update – when the review was last updated.
*/

CREATE TABLE customer_review(
	review_id SERIAL PRIMARY KEY,
	film_id INTEGER NOT NULL,
	language_id INTEGER NOT NULL, 
	title VARCHAR NOT NULL,
	score SMALLINT NOT NULL, 
	review_text TEXT NOT NULL,
	last_update TIMESTAMP NOT NULL,
	CONSTRAINT fk_film FOREIGN KEY(film_id) REFERENCES new_film(id) ON UPDATE CASCADE ON DELETE CASCADE ,
	CONSTRAINT fk_language FOREIGN KEY(language_id) REFERENCES language(language_id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- 6) Add 2 movie reviews. Make sure you link them to valid objects in the other tables.
INSERT INTO customer_review(film_id, language_id, title, score, review_text)
VALUES (1, 5, 'Bon film', 6, 'Tres bon film d"action'),
		 (4, 1, 'Pas aimé', 6, 'Je n"ai pas frenchement aimé le film');
		 
-- 7) Delete a film that has a review from the new_film table, what happens to the customer_review table?
DELETE FROM new_film
WHERE new_film.id = 4;


/*==== EXERCICE 2 ====*/
-- 1) Use UPDATE to change the language of some films. Make sure that you use valid languages.
UPDATE film
SET language_id = 3
WHERE film_id IN (3, 6, 9);


-- 2) Which foreign keys (references) are defined for the customer table? 
	-- How does this affect the way in which we INSERT into the customer table?
La clé étrangère addresse_id à pour propriéte ON UPDATE CASCADE ce qui signifie que 
lorsque l"adresse sera actualisé dans la table adresse, toutes les occurences de customer ayant cet id
verront leur adresse actualisé également, et l"attribut ON DELETE RESTRICT signifie que pour pouvoir supprimer 
une addresse ON va devoir supprimer toutes les occurences de customer ayant cet id.

-- 3) We created a new table called customer_review. Drop this table. 
	-- Is this an easy step, or does it need extra checking?
DROP TABLE customer_review;

-- 4) Find out how many rentals are still outstanding (ie. have not been returned to the store yet).
SELECT COUNT(rental.rental_id) AS rentals_outstanding
FROM rental
WHERE rental.return_date IS NULL 

-- 5) Find the 30 most expensive movies which are outstanding (ie. have not been returned to the store yet)
SELECT film.*, rental.return_date
FROM film
INNER JOIN inventory ON inventory.film_id = film.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
WHERE rental.return_date IS NULL
ORDER BY film.rental_rate desc
LIMIT 30;

/*
	6) Your friend is at the store, and decides to rent a movie. He knows he wants to see 4 movies, 
	but he can’t remember their names. Can you help him find which movies he wants to rent?
*/
		--1) The 1st film : The film is about a sumo wrestler, and one of the actors is Penelope Monroe.
SELECT film.*
FROM film
INNER JOIN film_actor ON film_actor.film_id = film.film_id
INNER JOIN actor ON actor.actor_id = film_actor.actor_id
WHERE actor.first_name || ' ' || actor.last_name = 'Penelope Monroe'
AND film.description ILIKE '%sumo wrestler%';

		--2) The 2nd film : A short documentary (less than 1 hour long), rated “R”.
SELECT film.*
FROM film
INNER JOIN film_category ON film_category.film_id = film.film_id
INNER JOIN category ON category.category_id = film_category.category_id
WHERE film.rating = 'R'
AND film.length < 60
AND category.name = 'Documentary';

		--3) The 3rd film : A film that his friend Matthew Mahan rented. He paid over $4.00 for the rental, 
			--and he returned it between the 28th of July and the 1st of August, 2005.
SELECT film.*
FROM film
INNER JOIN inventory ON inventory.film_id = film.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN customer ON customer.customer_id = rental.customer_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
WHERE customer.first_name || ' ' || customer.last_name = 'Matthew Mahan'
AND rental.return_date BETWEEN '2005-07-28' AND '2005-08-01'
AND payment.amount = 4.99;

		-- 4) The 4th film : His friend Matthew Mahan watched this film, as well. 
			-- It had the word “boat” in the title or description, 
			-- and it looked like it was a very expensive DVD to replace.
SELECT film.*
FROM film
INNER JOIN inventory ON inventory.film_id = film.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN customer ON customer.customer_id = rental.customer_id
WHERE customer.first_name || ' ' || customer.last_name = 'Matthew Mahan'
AND (film.title ILIKE '%boat%' OR film.description ILIKE '%boat%')
ORDER BY film.replacement_cost DESC
LIMIT 1