const express = require('express');  //creates routes and handles requests.
const bcrypt = require('bcrypt');  //for hashing passwords
const pool =require('../db');  //the database Connection.used to run SQL querres


const router = express.Router();  //helps define routes separately from index.js

router.post('/signup',async (req, res) => {// endpoint
try{
const {name, email, password} = req.body; //get data from the request

//checking if user exists
const user = await pool.query('SELECT * FROM users WHERE email = $1' , [email]); //pool.query allows you to run SQL commands
if (user.rows.length > 0){
    return res.status(400).json({message: 'User already exists'});

}
//password hash
 const salt = await bcrypt.genSalt(10);
 const hashedPassword = await bcrypt.hash(password, salt);

 //inserting the new user in the database
 const newUser = await pool.query(
    'INSERT INTO users (name, email, password) VALUES ($1, $2, $3 returning *', [name, email, hashedPassword]
 );
 res.json({
    message: 'Signup successful',
    user:{
        id:newUser.rows[0].id,
        name:newUser.rows[0].name,
        email:newUser.rows[0].email
    }
    });
   }catch (err){
    console.error(err.message);
    res.status(500).json({error:"server error"})
   }
 });

 //LOGIN
 router.post("/login", async (req, res) => {
    try{
       const {email, password} = req.body;
       //check if user is there
       const user = await pool.query(
        "SELECT * FROM users WHERE email = $1",[email]
       );
        if (user.rows.length === 0){
            return res.status(401).json({message:"Invalid credentials"});
 
        }
        //check if passwords match
        const validPassword = await bcrypt.compare(
            password,
            user.rows[0].password
        );
        if (!validPassword){
            return res.status(401).json({message:"invalid credentials"});
        }
        res.json({
            message:"Login successful",
            user:{
                id:user.rows[0].id,
                name:user.rows[0].name,
                email:user.rows[0].email,
            }
        })
    }catch(err){
        console.error(err);
        res.status(500).json({message:"server error"});
    }
 })
 module.exports =router;