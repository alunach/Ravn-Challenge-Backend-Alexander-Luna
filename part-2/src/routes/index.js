const { Router } = require('express');
const router = Router();

const { getSalesRevenueByCount } = require('../controllers/index.controller');

router.get('/sales-revenue/:count', getSalesRevenueByCount);


module.exports = router;