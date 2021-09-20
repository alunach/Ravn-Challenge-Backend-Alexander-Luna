const { Router } = require('express');
const { cacheInit } = require('../middleware/cache');

const router = Router();

const { getSalesRevenueByCount } = require('../controllers/index.controller');

router.get('/sales-revenue/:count'
    , cacheInit
    , getSalesRevenueByCount);


module.exports = router;