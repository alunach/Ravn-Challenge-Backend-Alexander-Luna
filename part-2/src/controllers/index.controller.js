const { Pool } = require('pg');

const pool = new Pool({
        host: 'localhost',
        user: 'postgres',
        password: '4321',
        database: 'postgres',
        port: '5432'
});

const getSalesRevenueByCount = async (req, res) => {
    const count = req.params.count;
    const response = 
    await pool.query('SELECT authors.name, SUM(sales.quantity*sales.item_price)::numeric::money AS sales_revenue'
    +' FROM sale_items sales INNER JOIN books ON books.id = sales.book_id INNER JOIN authors ON books.author_id = authors.id'
    +' GROUP BY authors.name ORDER BY sales_revenue DESC LIMIT $1', [count]
    , (error, data) => {
        if(error){
            res.writeHead(404);
            res.write('incorrect consult: maybe count is not a number');
            res.end();
        }else{
            res.json(data);
        }
        res.end();
    });

}

// can be converted to ES
module.exports = {
    getSalesRevenueByCount
}