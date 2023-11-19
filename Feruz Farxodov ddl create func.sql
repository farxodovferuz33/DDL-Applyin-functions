 
-- task 1   working with view
CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
SELECT 
    f.category_id,
    SUM(p.amount) AS total_sales_revenue
FROM 
    film_category f
JOIN 
    film f1 ON f.film_id = f1.film_id
JOIN 
    inventory i ON f1.film_id = i.film_id
JOIN 
    rental r ON i.inventory_id = r.inventory_id
JOIN 
    payment p ON r.rental_id = p.rental_id
WHERE 
    EXTRACT(QUARTER FROM r.rental_date) = EXTRACT(QUARTER FROM CURRENT_DATE)
GROUP BY 
    f.category_id
HAVING 
    SUM(p.amount) > 0;

	
    -- task 2 creating a function 
	
	CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(current_quarter INT)
RETURNS TABLE(category VARCHAR, total_sales_revenue DECIMAL) AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        f.category,
        SUM(p.amount) AS total_sales_revenue
    FROM 
        film_category f
    JOIN 
        film f1 ON f.film_id = f1.film_id
    JOIN 
        inventory i ON f1.film_id = i.film_id
    JOIN 
        rental r ON i.inventory_id = r.inventory_id
    JOIN 
        payment p ON r.rental_id = p.rental_id
    WHERE 
        EXTRACT(QUARTER FROM r.rental_date) = current_quarter
    GROUP BY 
        f.category
    HAVING 
        total_sales_revenue > 0;
END;
$$ LANGUAGE plpgsql;



-- task 3 creating a procedure function
-- "function" to define a procedure-like construct
CREATE OR REPLACE FUNCTION new_movie(movie_title VARCHAR(255))
RETURNS VOID AS $$
DECLARE
    new_film_id INT;
    current_year INT;
BEGIN
    -- Getting the current year
    SELECT EXTRACT(YEAR FROM CURRENT_DATE) INTO current_year;

    -- Generating a new unique film ID
    SELECT MAX(film_id) + 1 INTO new_film_id FROM film;

    -- Checking if the language exists in the language table
    IF NOT EXISTS (SELECT 1 FROM language WHERE name = 'Klingon') THEN
        RAISE EXCEPTION 'Language Klingon does not exist in the language table.';
    END IF;

    -- Inserting the new movie into the film table
    INSERT INTO film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
    VALUES (new_film_id, movie_title, 4.99, 3, 19.99, current_year, (SELECT language_id FROM language WHERE name = 'Klingon'));

END;
$$ LANGUAGE plpgsql;