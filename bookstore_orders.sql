SELECT u.name,
       b.title,
       b.price                                                    as price_per_unit,
       c.amount,
       b.price * c.amount                                         AS price,
       o.id                                                       as order_id,
       round(sum(b.price * c.amount) OVER (PARTITION BY o.id),2) as order_price
FROM book_store.cart as c
         INNER JOIN book_store.books as b ON b.id = c.book_id
         INNER JOIN book_store.orders as o ON o.id = c.order_id
         INNER JOIN book_store.users as u ON u.id = o.user_id
