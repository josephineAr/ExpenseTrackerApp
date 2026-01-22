//importng Express
const express = require ("express"); //importng express

const cors = require('cors');
const pool =require('./db');
const app = express(); //creates an express App

//middleware
app.use(cors());  //allows external apps to access backend
app.use(express.json()); //allows backend to read json data from frontend

//test route
app.get('test-db',async (req,res) => {
    try{
        const result = await pool.query('SELECT NOW()');
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({error:err.message});
}

});
app.listen(3000, () =>{
    console.log('Server running on http://localhost:3000');
});