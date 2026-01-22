const { Pool } = require('pg'); //pool  manages PostgreSQL connections

const pool = new Pool({
    user: 'postgres',
    host:'localhost',
    database:'project_auth',
    password: 'admin',
    port: 5432 //postgres uses this port by default as its listening port

});

module.exports = pool

