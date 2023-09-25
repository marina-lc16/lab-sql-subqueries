
USE SAKILA;

/*
#Challenge
Write SQL queries to perform the following tasks using the Sakila database:
*/

# 1.- Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

/*
sakila.film: film_id, title, 
sakila.inventory: inventory_id, film_id
sakila.rental: rental_id, inventory_id
*/

SELECT *
FROM sakila.film as f
left JOIN sakila.inventory as i
USING (film_id);

SELECT title, film_id, inventory_id
FROM sakila.film 
left JOIN sakila.inventory 
USING (film_id);

SELECT distinct(f.title) as film_title, 
count(i.film_id) as availability
FROM sakila.film as f
LEFT JOIN sakila.inventory as i
ON i.film_id = f.film_id
WHERE f.title = 'HUNCHBACK IMPOSSIBLE'
GROUP BY f.title
ORDER BY availability ASC;

# 2.- List all films whose length is longer than the average length of all the films in the Sakila database.

/*
sakila.film: film_id, title, length
*/

SELECT *
FROM sakila.film;

SELECT title, film_id, length
FROM sakila.film;

SELECT title, (AVG(length))
FROM sakila.film
GROUP BY title;

SELECT (AVG(length))
FROM sakila.film;

SELECT title, (AVG(length))
FROM sakila.film
WHERE length > (SELECT AVG(length)
FROM sakila.film)
GROUP BY title
ORDER BY AVG(length);

# 3.- Use a subquery to display all actors who appear in the film "Alone Trip".

/*
sakila.film_actor: actor_id, film_id
sakila:film: film_id, title
*/

SELECT *
FROM sakila.film_actor;

SELECT actor_id, film_id
FROM sakila.film_actor;

# Join actor+film
SELECT fa.actor_id, f.title
FROM sakila.film_actor as fa
JOIN sakila.film as f
ON fa.film_id = f.film_id;

SELECT fa.actor_id, f.title
FROM sakila.film_actor as fa
JOIN sakila.film as f
ON fa.film_id = f.film_id
WHERE f.title =
	(SELECT	f.title
    FROM sakila.film as f
    WHERE f.title = "ALONE TRIP");
   
# 4.- Sales have been lagging among young families, and you want to target family movies for a promotion. 
# Identify all movies categorized as family films.

/*
sakila.film: film_id, title
sakila.category: category_id, name
sakila.film_category: film_id, category_id
*/

SELECT * FROM sakila.film;
SELECT * FROM sakila.category;
SELECT * FROM sakila.film_category;

# all movie title as family film 
SELECT f.title as movie_title, c.name as category_name
FROM sakila.film_category as fc
JOIN sakila.category as c
ON fc.category_id = c.category_id
JOIN sakila.film as f
ON f.film_id = fc.film_id
HAVING c.name = "Family";


# 5.- Retrieve the name and email of customers from Canada using both subqueries and joins. 
# To use joins, you will need to identify the relevant tables and their primary and foreign keys.

/*
sakila.customer: customer_id, store_id, first_name, last_name, email, address_id
sakila.address: address_id, district, city_id
sakila.city: country_id
sakila.country: country_id, country
*/

SELECT * FROM sakila.customer;
SELECT * FROM sakila.address;

# Join tables
SELECT c.first_name, c.email, co.country
FROM sakila.customer as c
JOIN sakila.address as a
ON c.address_id = a.address_id
JOIN sakila.city as ci
ON a.city_id = ci.city_id
JOIN sakila.country as co
ON ci.country_id = co.country_id;

#  name and email of customers from Canada
SELECT c.first_name, c.email, co.country
FROM sakila.customer as c
JOIN sakila.address as a
ON c.address_id = a.address_id
JOIN sakila.city as ci
ON a.city_id = ci.city_id
JOIN sakila.country as co
ON ci.country_id = co.country_id
WHERE co.country = (SELECT co.country
FROM sakila.country as co
WHERE co.country = "Canada");


# 6.- Determine which films were starred by the most prolific actor in the Sakila database. 
# A prolific actor is defined as the actor who has acted in the most number of films. 
# First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

/*
sakila.film: film_id, title
sakila.actor: actor_id
sakila.film_actor: actor_id, film_id
*/

SELECT count(distinct title) FROM sakila.film;

# frequencies per actor_id
SELECT actor_id, count(actor_id) 
FROM sakila.film_actor
GROUP BY actor_id;

# all movies that an actor_id have done (separetly)

SELECT count(f.title) as total_movies_actor, fa.actor_id as most_prolific_actor
FROM sakila.film_actor as fa
JOIN sakila.film as f
ON fa.film_id = f.film_id
group by fa.actor_id
ORDER BY total_movies_actor DESC
LIMIT 1;


# movies that the most prolific actor appeared on

SELECT f.title AS film_title, fa.actor_id
FROM film AS f
JOIN film_actor AS fa ON f.film_id = fa.film_id
JOIN (
    SELECT a.actor_id, COUNT(fa.film_id) AS film_count
    FROM actor AS a
    JOIN film_actor AS fa ON a.actor_id = fa.actor_id
    GROUP BY a.actor_id 
    ORDER BY film_count DESC
    LIMIT 1
) AS most_prolific_actor
ON most_prolific_actor.actor_id = fa.actor_id;


# 7.- Find the films rented by the most profitable customer in the Sakila database. 
# You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

/*
sakila.payment: payment_id, customer_id, amount, rental_id
sakila.film: film_id, title,
sakila.rental: rental_id, inventory_id
sakila.inventory: inventory_id, film_id, store_id
-- Customer who has made the largest sum of payments.
*/
SELECT *
FROM sakila.customer;

SELECT *
FROM sakila.payment;

# Customer who has made the largest sum of payments
SELECT customer_id, count(amount) as payments
FROM sakila.payment
GROUP BY customer_id
ORDER BY count(amount) DESC
LIMIT 1;

# Films rented by the most profitable customer

SELECT
    film.title, actor_id
FROM sakila.film
JOIN ( SELECT film_actor.actor_id,COUNT(*) AS film_count
    FROM sakila.film_actor
    GROUP BY film_actor.actor_id
    ORDER BY film_count DESC
    LIMIT 1
) AS prolific_actor ON film.film_id IN (
    SELECT film_id
    FROM sakila.film_actor
    WHERE actor_id = prolific_actor.actor_id
);

# 8.- Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
# You can use subqueries to accomplish this.

/*client_id=customer_id
total_amount_spent
total_amount_spent > AVG(total_amount_spent)
*/

SELECT *
FROM sakila.payment;

SELECT customer_id, amount
FROM sakila.payment;

SELECT customer_id, round(AVG(amount),2)
FROM sakila.payment
GROUP BY customer_id;

SELECT customer_id, round(AVG(amount),2) as expenses
FROM sakila.payment
WHERE amount > (SELECT round(AVG(amount),2)
FROM sakila.payment)
GROUP BY customer_id
ORDER BY round(AVG(amount),2);
