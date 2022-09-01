SELECT u.name,
       b.title,
       b.price                                                    AS price_per_unit,
       c.amount,
       b.price * c.amount                                         AS price,
       o.id                                                       AS order_id,
       ROUND(SUM(b.price * c.amount) OVER (PARTITION BY o.id), 2) AS order_price
FROM book_store.cart AS c
         INNER JOIN book_store.books AS b ON b.id = c.book_id
         INNER JOIN book_store.orders AS o ON o.id = c.order_id
         INNER JOIN book_store.users AS u ON u.id = o.user_id
