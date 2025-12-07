const express = require('express');
const router = express.Router();
const controller = require('../controllers/exampleController');

router.get('/hello', controller.sayHello);

module.exports = router;
