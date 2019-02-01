-- Homework 07 SQL
-- Dan Boulden
-- Jan 2019


USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(first_name, " ", last_name) AS "Actor Name" FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Joe";
-- Test to see that the code pulls all the "Joe's" instead of just the first. I looked at the data and found that "Julia" appears more then one time so...
-- SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Julia";

-- 2b. Find all actors whose last name contain the letters `GEN`:
-- This finds the actors with the last name that starts with GEN
-- SELECT actor_id, first_name, last_name FROM actor WHERE substr(last_name, 1, 3) = "GEN";
SELECT  first_name, last_name FROM actor WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT  first_name, last_name FROM actor WHERE last_name LIKE "%LI%" ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
-- I am assuming that you want us to use the "country" table for this as it has those fields
SELECT country_id, country 
FROM country 
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description,
-- so create a column in the table `actor` named `description` 
-- 	      and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_update;
-- view the table to see that description was added
SELECT * FROM sakila.actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;
-- view the talbe to be sure that description was droped
SELECT * FROM sakila.actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*)  AS "Actor Last Name Count"
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(*)  AS "Actor_Last_Name_Count"
FROM actor
GROUP BY last_name
HAVING Actor_Last_Name_Count > 1;

--   Alternate version (same results, but allows for the field to not be a whole number)
-- SELECT last_name, count(*)  AS "Actor_Last_Name_Count"
-- FROM actor
-- GROUP BY last_name
-- HAVING Actor_Last_Name_Count >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

-- This SELECT is to see what actors have the first name GROUCHO, for a gaining of understanding of the issue.
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "GROUCHO";
-- This code changes the first name of GROUCHO WILLIAMS to HARPO
UPDATE actor SET first_name = "HARPO" WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";
SELECT actor_id, first_name, last_name FROM actor WHERE last_name = "WILLIAMS";


-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
--    In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor SET first_name = "GROUCHO" WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

-- Just to check that it worked
SELECT actor_id, first_name, last_name FROM actor WHERE last_name = "WILLIAMS";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
--    Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
SHOW CREATE TABLE address;
-- hover over the "Create Table" cell to the right of "address" to see the query, Rigth click to copy it.


-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address, address.address2
FROM staff
INNER JOIN address
ON staff.address_id=address.address_id;



-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005,
--     Use tables `staff` and `payment`.
SELECT staff.first_name, staff.last_name, concat("$", format(SUM(payment.amount), 2)) AS "total_amount"
FROM staff
RIGHT JOIN payment 
ON staff.staff_id=payment.staff_id
WHERE payment_date LIKE "2005-08%"
GROUP BY last_name, first_name;


-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT film.title,  COUNT(film_actor.actor_id) AS num_of_actors
FROM film
INNER JOIN film_actor 
ON film.film_id=film_actor.film_id
GROUP BY film.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT COUNT(inventory.film_id) AS "Num_of_Hunchback_Impossible"
FROM inventory
INNER JOIN film 
ON inventory.film_id=film.film_id
WHERE title="Hunchback Impossible";


-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
--    ![Total amount paid](Images/total_payment.png)
SELECT customer.first_name, customer.last_name, concat("$", format(SUM(payment.amount), 2)) AS "Total Amount Paid"
FROM customer
RIGHT JOIN payment 
ON customer.customer_id=payment.customer_id
GROUP BY last_name, first_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. [subquery]

SELECT film.title AS "Films starting with the letters K & Q"
FROM film
WHERE language_id IN
	(SELECT language_id
    FROM language
    WHERE name = "English"
    ) AND film.title LIKE "K%" OR film.title LIKE "Q%";


-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
  SELECT film_id
  FROM film_text
  WHERE title = "Alone Trip"
));


-- 7c. You want to run an email marketing campaign in Canada,
-- for which you will need the names and email addresses of all Canadian customers.
--    Use joins to retrieve this information.

-- THIS IS THE ANSWER TO 7c [there is a doublecheck afterworkds]
SELECT customer.first_name, customer.last_name, customer.email, country.country
FROM customer
JOIN address ON customer.address_id=address.address_id
JOIN city ON address.city_id=city.city_id
JOIN country ON city.country_id=country.country_id
WHERE  country.country="Canada";


--     !!!!! This is a double check of 7c
-- SELECT customer.first_name, customer.last_name, customer.email, address_id
-- FROM customer
-- WHERE address_id IN
-- (SELECT address_id
-- FROM address
-- WHERE city_id IN
-- (SELECT city_id
-- FROM city
-- WHERE country_id IN
-- (SELECT country_id
-- FROM country
-- WHERE country="Canada"
-- )));
--     additional checksums to be sure this worked correctley (note that the customer table has no address_id 1 or 3)
-- SELECT country_id, city_id FROM city WHERE country_id="20";
-- SELECT address_id, city_id FROM address WHERE city_id="179" OR city_id="196" OR city_id="300" OR city_id="313" OR city_id="383" OR city_id="430" OR city_id="565";



-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
--     Identify all movies categorized as _family_ films.

SELECT film.film_id, film.title AS "Family Films"
FROM film
WHERE film_id IN
(SELECT film_id
FROM film_category
WHERE category_id IN
(SELECT category_id
FROM category
WHERE name="Family"
));




-- 7e. Display the most frequently rented movies in descending order.

SELECT title, COUNT(inventory.film_id) as "Frequency_of_rental"
FROM film
JOIN inventory ON film.film_id=inventory.film_id
JOIN rental ON inventory.inventory_id=rental.inventory_id
GROUP BY inventory.film_id
ORDER BY Frequency_of_rental DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT staff.store_id, concat("$", format(SUM(amount), 2))  AS "Total Dollars Per Store"
FROM payment
LEFT JOIN staff 
ON payment.staff_id=staff.staff_id
GROUP BY staff.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country
FROM store
JOIN address ON store.address_id=address.address_id
JOIN city ON address.city_id=city.city_id
JOIN country ON city.country_id=country.country_id;


-- 7h. List the top five genres in gross revenue in descending order.
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

DROP TABLE IF EXISTS rental_totals;

CREATE TABLE rental_totals
SELECT film.title, COUNT(inventory.film_id) as "Frequency_of_rental", 
SUM(payment.amount) as "Gross_Revenue", category.name AS "Category_Title", 
COUNT(category.category_id) as "Category"
FROM film
JOIN inventory ON film.film_id=inventory.film_id
JOIN rental ON inventory.inventory_id=rental.inventory_id
JOIN payment ON rental.rental_id=payment.rental_id
JOIN film_category ON inventory.film_id=film_category.film_id
JOIN category ON film_category.category_id=category.category_id
GROUP BY inventory.film_id
ORDER BY Gross_Revenue DESC;

DROP TABLE IF EXISTS category_revenue_totals;

CREATE TABLE category_revenue_totals
SELECT Category_Title AS "Category_Title", SUM(Gross_Revenue) AS "Gross_Revenue"
FROM rental_totals
GROUP BY Category_Title
ORDER BY SUM(Gross_Revenue) DESC
LIMIT 5;

SELECT * FROM sakila.category_revenue_totals;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view.
-- If you haven't solved 7h, you can substitute another query to create a view.

-- 8b. How would you display the view that you created in 8a?

-- This is just to show me what is in the category_revenue_totals table, so I can work with it.
-- SELECT * FROM sakila.category_revenue_totals;

-- NOTE this uses the category_revenue_totals table created in 7h

DROP VIEW IF EXISTS category_revenue_total_top_5;

CREATE VIEW category_revenue_total_top_5 AS 
SELECT Category_Title, Gross_Revenue
FROM category_revenue_totals
LIMIT 5;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW IF EXISTS category_revenue_total_top_5;


--      oo  -Yep... I'm done!
--     </>
--     []
