WITH sold_tickets AS (SELECT DISTINCT extract(YEAR from b2.book_date)       AS year,
                                      extract(Month from b2.book_date)      AS month,
                                      count(t2.ticket_no)
                                      OVER (PARTITION BY extract(YEAR from b2.book_date),
                                          extract(Month from b2.book_date)) AS monthly_tickets_sold
                      FROM bookings AS b2
                               INNER JOIN tickets t2 on b2.book_ref = t2.book_ref)
SELECT b.year,
       b.month,
       b.monthly_income,
       t.monthly_tickets_sold,
       sum(b.monthly_income)
       OVER (PARTITION BY b.year) AS yearly_income,
       sum(t.monthly_tickets_sold)
       OVER (PARTITION BY b.year) AS yearly_tickets_sold
FROM (SELECT DISTINCT extract(YEAR from b.book_date)                                                     AS year,
                      extract(Month from b.book_date)                                                    AS month,
                      sum(b.total_amount)
                      OVER (PARTITION BY extract(YEAR from b.book_date),extract(Month from b.book_date)) AS monthly_income
      FROM bookings as b
               INNER JOIN tickets t2 on b.book_ref = t2.book_ref
               INNER JOIN ticket_flights tf on t2.ticket_no = tf.ticket_no
               INNER JOIN flights f on f.flight_id = tf.flight_id
      WHERE f.status <> 'Cancelled') as b
         INNER JOIN sold_tickets as t
                    ON b.year = t.year AND b.month = t.month
