const express = require('express');
const app = express();
const morgan = require('morgan');

/// settings
app.set('port',process.env.PORT || 3000);
app.set('json spaces',2);

/// middlewares
app.use(morgan('dev')); //dev, cobined
app.use(express.urlencoded({extended : false})); //data from imput
app.use(express.json());

/// routes
app.use(require('./routes/index'));

/// starting server
app.listen(app.get('port'), () => {
    console.log(`Server on port ${app.get('port')}`);
});
