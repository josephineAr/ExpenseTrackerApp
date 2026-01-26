//importng Express
const express = require ("express"); //importng express
//const { Pool } = require('pg');
//const cors = require('cors');
const pool =require('./db');

const app = express(); //creates an express App

//middleware
//app.use(cors());  //allows external apps to access backend
app.use(express.json()); //allows backend to read json data from frontend

const authRoutes = require("./routes/auth"); //this imports routes
app.use('/auth', authRoutes);   //use routes



app.post("/budgets/create", async (req, res) => {
    const { name, total_amount, category, is_shared, user_id } = req.body;
    try {
        //  Insert the budget
        const newBudget = await pool.query(
            "INSERT INTO budgets (name, total_amount, category, is_shared) VALUES ($1, $2, $3, $4) RETURNING *",
            [name, total_amount, category, is_shared]
        );

        //  Link it to the user
        await pool.query(
            "INSERT INTO user_budgets (user_id, budget_id, role) VALUES ($1, $2, $3)",
            [user_id, newBudget.rows[0].id, 'owner']
        );

        res.status(201).json(newBudget.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ message: "Server error while creating budget" });
    }
});

app.post("/budgets/create-shared", async (req, res) => {
    const client = await pool.connect(); 
    try {
        const { name, total_amount, category, is_shared, owner_id, participant_emails } = req.body;
        
        await client.query('BEGIN');

        //  Create shared budget
        const newBudget = await client.query(
            "INSERT INTO budgets (name, total_amount, category, is_shared) VALUES ($1, $2, $3, $4) RETURNING id",
            [name, total_amount, category, is_shared]
        );
        const budgetId = newBudget.rows[0].id;

        //  Link the Owner
        await client.query(
            "INSERT INTO user_budgets (user_id, budget_id, role) VALUES ($1, $2, 'owner')",
            [owner_id, budgetId]
        );

        //  Link Participants by Email
        for (let email of participant_emails) {
            const userLookup = await client.query("SELECT id FROM users WHERE email = $1", [email]);
            if (userLookup.rows.length > 0) {
                await client.query(
                    "INSERT INTO user_budgets (user_id, budget_id, role) VALUES ($1, $2, 'member')",
                    [userLookup.rows[0].id, budgetId]
                );
            }
        }

        await client.query('COMMIT');
        res.status(201).json({ message: "Shared budget created successfully!" });
    } catch (err) {
        await client.query('ROLLBACK');
        res.status(500).json({ message: err.message });
    } finally {
        client.release();
    }
});


app.get("/budgets/:userId", async (req, res) => {
    try {
        const { userId } = req.params;
        const result = await pool.query(
            `SELECT b.* FROM budgets b 
             JOIN user_budgets ub ON b.id = ub.budget_id 
             WHERE ub.user_id = $1`, 
            [userId]
        );
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


app.get("/users/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query("SELECT name, email FROM users WHERE id = $1", [id]);
        if (result.rows.length > 0) {
            res.json(result.rows[0]);
        } else {
            res.status(404).json({ message: "User not found" });
        }
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


app.get("/transactions/expenses/:userId", async (req, res) => {
    try {
        const { userId } = req.params;
        const result = await pool.query(
            "SELECT amount, category, transactiontype FROM transactions WHERE user_id = $1 AND transactiontype = 'Expenses'", 
            [userId]
        );
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});



app.post("/transactions", async (req, res) => {
    const { amount, transactiontype, category, date, notes, user_id, budget_id } = req.body;
    const client = await pool.connect();

    try {
        await client.query('BEGIN'); // Start a transaction

        //  Insert the transaction into the new table
        const txResult = await client.query(
            `INSERT INTO transactions (amount, transactiontype, category, date, notes, user_id, budget_id) 
             VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
            [amount, transactiontype, category, date, notes, user_id, budget_id]
        );

        
        if (transactiontype === "Expenses" && budget_id) {
            await client.query(
                "UPDATE budgets SET current_spent = current_spent + $1 WHERE id = $2",
                [amount, budget_id]
            );
        }

        await client.query('COMMIT'); 
        res.status(201).json(txResult.rows[0]);

    } catch (err) {
        await client.query('ROLLBACK'); 
        console.error(err.message);
        res.status(500).send("Server Error");
    } finally {
        client.release();
    }
});

app.get("/transactions/totals/:userId", async (req, res) => {
    try {
        const { userId } = req.params;
        const result = await pool.query(
            `SELECT 
                COALESCE(SUM(amount) FILTER (WHERE transactiontype = 'Income'), 0) as total_income,
                COALESCE(SUM(amount) FILTER (WHERE transactiontype = 'Expenses'), 0) as total_expense
             FROM transactions WHERE user_id = $1`, 
            [userId]
        );
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


app.delete("/budgets/:id", async (req, res) => {
    try {
        const { id } = req.params;
        // delete budget
        await pool.query("DELETE FROM user_budgets WHERE budget_id = $1", [id]);
        await pool.query("DELETE FROM budgets WHERE id = $1", [id]);
        res.json({ message: "Budget deleted successfully" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get all debts for a user
app.get("/debts/:userId", async (req, res) => {
    try {
        const { userId } = req.params;
        const result = await pool.query(
            "SELECT * FROM debts WHERE user_id = $1 ORDER BY created_at DESC", 
            [userId]
        );
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Create a new debt
app.post("/debts", async (req, res) => {
    try {
        const { user_id, name, amount, type, info } = req.body;
        const result = await pool.query(
            "INSERT INTO debts (user_id, name, amount, type, info) VALUES ($1, $2, $3, $4, $5) RETURNING *",
            [user_id, name, amount, type, info]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Toggle Paid Status
app.patch("/debts/toggle-paid/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const { is_paid } = req.body;
        const result = await pool.query(
            "UPDATE debts SET is_paid = $1 WHERE id = $2 RETURNING *",
            [is_paid, id]
        );
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.listen(3000, () =>{
    console.log('Server running on http://localhost:3000');
});

module.exports = pool;
