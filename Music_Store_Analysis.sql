use music_database;

-- Senior most Employee based on Job Title

Select * 
from employee 
order by levels desc
limit 1;

-- Countries with Most Invoices

Select billing_country, Count(*) as NumberofInvoices
from invoice
Group by billing_country
Order by NumberofInvoices desc;

-- Top 3 values of Total Invoice

Select billing_country, total
from invoice
Order by total desc
Limit 3;

-- Cities with highest sum of invoices 

Select billing_city, SUM(total) as SumofInvoiceTotals
from invoice
Group by billing_city
Order by SumofInvoiceTotals desc;

-- Best Customer to be declared who spent the most money

Select c.customer_id, c.first_name, c.last_name, SUM(i.total) as InvoiceTotal
from customer c
join invoice i
On c.customer_id = i.customer_id
Group by c.customer_id
Order by InvoiceTotal desc
Limit 1;

-- Getting Email, first name, last name, genre of all Rock Music Listeners

Select distinct c.email, c.first_name, c.last_name, g.name
from customer c
Join invoice i on c.customer_id = i.customer_id
Join invoice_line il on i.invoice_id = il.invoice_id
Join track t on t.track_id = il.track_id
Join genre g on g.genre_id = t.genre_id
where g.name = "Rock"
order by email;

-- Artist who have written the most rock music
-- Getting Artist name and total track count of the Top 10 Rock Bands

Select a.artist_id, a.name, COUNT(t.name) as TotalTracks
from artist a
Join album ab on ab.artist_id = a.artist_id 
Join track t on t.album_id = ab.album_id
Join genre g on g.genre_id = t.genre_id
where g.name = "Rock"
Group by a.artist_id
Order by TotalTracks desc
Limit 10;

-- All the track names that have a song length longer than the average song length
-- Getting the Name and Milliseconds for each track
-- Order by Song Length 

Select name, milliseconds 
from track
where milliseconds > (
	Select AVG(milliseconds) as Avg_track_length from track)
Order by milliseconds desc;

-- Amount spent by customer on each Artists
-- Return customer name, artist name and total spent

With best_selling_artist AS (
	Select a.artist_id, a.name as artist_name, SUM(i.unit_price * i.quantity) as total_sales
    from invoice_line i
    Join track t on t.track_id = i.track_id
    Join album ab on ab.album_id = t.album_id
    Join artist a on a.artist_id = ab.artist_id
    Group by 1
    Order by 3 desc
    Limit 1
)
Select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price*il.quantity) as Amount_spent
from invoice i 
Join customer c on c.customer_id = i.customer_id
Join invoice_line il on il.invoice_id = i.invoice_id
Join track t on t.track_id = il.track_id
Join album ab on ab.album_id = t.album_id
Join best_selling_artist bsa on bsa.artist_id = ab.artist_id
Group by 1,2,3,4
-- Order by 4,5
Order by 5 desc;

-- Most popular music genre for each country
-- Customers in Country who spent most on Genres

With popular_genre As
(
	Select COUNT(il.quantity) As purchases, c.country, g.name, g.genre_id,
    ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS RowNo
    From invoice_line il
    Join invoice i on i.invoice_id = il.invoice_id
    Join customer c on c.customer_id = i.customer_id
    Join track t on t.track_id = il.track_id
    Join genre g on g.genre_id = t.genre_id
    Group by 2,3,4
    Order by 2 asc, 1 desc
)

Select * from popular_genre where RowNo <= 1;

-- Country that has spent the most on music for each country
-- Getting the country along with the top customer and how much they spent

WITH RECURSIVE
	customer_with_country As (
		Select c.customer_id, c.first_name, c.last_name, i.billing_country, SUM(total) As total_spending
        From invoice i
        Join customer c on c.customer_id = i.customer_id
        Group by 1,2,3,4
        Order by 2,3 desc),

	country_max_spending AS(
		Select billing_country, Max(total_spending) As max_spending
        from customer_with_country
        Group by billing_country)

Select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
Join country_max_spending ms on ms.billing_country = cc.billing_country
where cc.total_spending = ms.max_spending 
Order by 1;

-- CTE Method

With customer_with_country As(
	Select c.customer_id, first_name,last_name, billing_country, SUM(total) As total_spending,
    ROW_NUMBER() Over(Partition by billing_country Order by SUM(total) desc) as RowNo
    From invoice i
    Join customer c on c.customer_id = i.customer_id
    Group by 1,2,3,4
    Order by 4 Asc, 5 Desc)
    
Select * from customer_with_country where RowNo <= 1;
