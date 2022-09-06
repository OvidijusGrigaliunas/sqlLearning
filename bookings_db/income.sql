-- Apskaičiuoja kiek bilietų buvo pirktą ir kiek užsidirbta kiekvieną mėnesį ir kiekvienus metus

-- Apskaičiuoja kiek bilietų buvo pirkta
WITH sold_tickets AS (SELECT EXTRACT(YEAR FROM b2.book_date)  AS year,
                             EXTRACT(MONTH FROM b2.book_date) AS month,
                             COUNT(tf2.ticket_no)             AS monthly_tickets_sold
                      FROM bookings AS b2
                               INNER JOIN tickets t2 ON b2.book_ref = t2.book_ref
                               INNER JOIN ticket_flights tf2 ON t2.ticket_no = tf2.ticket_no
                      GROUP BY EXTRACT(YEAR FROM b2.book_date), EXTRACT(MONTH FROM b2.book_date))
SELECT b.year,
       b.month,
       b.monthly_income,
       t.monthly_tickets_sold,
       ROUND(b.monthly_income / t.monthly_tickets_sold, 2) AS avg_ticket_price,
       SUM(b.monthly_income)
       OVER (PARTITION BY b.year)                          AS yearly_income,
       SUM(t.monthly_tickets_sold)
       OVER (PARTITION BY b.year)                          AS yearly_tickets_sold
FROM (SELECT EXTRACT(YEAR FROM b.book_date)  AS year,
             EXTRACT(MONTH FROM b.book_date) AS month,
             SUM(tf.amount)                  AS monthly_income
      FROM bookings AS b
               INNER JOIN tickets t2 ON b.book_ref = t2.book_ref
               INNER JOIN ticket_flights tf ON t2.ticket_no = tf.ticket_no
      GROUP BY EXTRACT(YEAR FROM b.book_date), EXTRACT(MONTH FROM b.book_date)) AS b
         INNER JOIN sold_tickets AS t
                    ON b.year = t.year AND b.month = t.month;
