WITH sold_tickets AS (SELECT DISTINCT extract(YEAR from b2.book_date)                      AS year,
                                      extract(Month from b2.book_date)                     AS month,
                                      count(t2.ticket_no)
                                      OVER (PARTITION BY extract(Month from b2.book_date)) AS monthly_tickets_sold
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
FROM (SELECT DISTINCT extract(YEAR from b.book_date)                      AS year,
                      extract(Month from b.book_date)                     AS month,
                      sum(b.total_amount)
                      OVER (PARTITION BY extract(Month from b.book_date)) AS monthly_income
      FROM bookings as b) as b
         INNER JOIN sold_tickets as t
                    ON t.year = b.year AND t.month = b.month
