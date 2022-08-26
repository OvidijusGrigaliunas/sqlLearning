WITH sold_tickets AS (SELECT DISTINCT extract(YEAR from b2.book_date)       AS year,
                                      extract(Month from b2.book_date)      AS month,
                                      count(tf2.ticket_no)
                                      OVER (PARTITION BY extract(YEAR from b2.book_date),
                                          extract(Month from b2.book_date)) AS monthly_tickets_sold
                      FROM bookings AS b2
                               INNER JOIN tickets t2 ON b2.book_ref = t2.book_ref
                               INNER JOIN ticket_flights tf2 on t2.ticket_no = tf2.ticket_no
                               INNER JOIN flights f ON tf2.flight_id = f.flight_id
                      WHERE f.status <> 'Cancelled')
SELECT b.year,
       b.month,
       b.monthly_income,
       t.monthly_tickets_sold,
       round(b.monthly_income / t.monthly_tickets_sold, 2) AS avg_ticket_price,
       sum(b.monthly_income)
       OVER (PARTITION BY b.year)                          AS yearly_income,
       sum(t.monthly_tickets_sold)
       OVER (PARTITION BY b.year)                          AS yearly_tickets_sold
FROM (SELECT DISTINCT b.year, b.month, sum(b.amount) AS monthly_income
      FROM (SELECT extract(YEAR from b.book_date)  AS year,
                   extract(Month from b.book_date) AS month,
                   tf.amount
            FROM bookings AS b
                     INNER JOIN tickets t2 ON b.book_ref = t2.book_ref
                     INNER JOIN ticket_flights tf ON t2.ticket_no = tf.ticket_no
                     INNER JOIN flights f ON tf.flight_id = f.flight_id
            WHERE f.status <> 'Cancelled') AS b
      GROUP BY b.year, b.month) AS b
         INNER JOIN sold_tickets AS t
                    ON b.year = t.year AND b.month = t.month;
