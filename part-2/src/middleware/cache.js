const getExpeditiousCache = require('express-expeditious');

const defaultOptions = {
    namespace: 'expresscache',
    defaultTtl: '1 minute', //TODO: 60 * 1000
    statusCodeExpires: {
        404: '1 minute',
        500: 0 // 1 minute in milliseconds
    }
}

const cacheInit = getExpeditiousCache(defaultOptions);

module.exports = { cacheInit }