const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../db');

const JWT_SECRET = process.env.JWT_SECRET || 'fowra_super_secret_key_123';

// Helper function to generate JWT
const generateToken = (user) => {
    return jwt.sign(
        { id: user.id, email: user.email, name: user.name },
        JWT_SECRET,
        { expiresIn: '30d' }
    );
};

// SIGN UP ROUTE
router.post('/signup', async (req, res) => {
    try {
        const { name, year, className, email, password } = req.body;

        // Check if user already exists
        const [existingUsers] = await pool.execute('SELECT * FROM users WHERE email = ?', [email]);
        if (existingUsers.length > 0) {
            return res.status(400).json({ message: 'User with this email already exists' });
        }

        // Hash password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Insert user
        const [result] = await pool.execute(
            'INSERT INTO users (name, year, class, email, password) VALUES (?, ?, ?, ?, ?)',
            [name, year, className, email, hashedPassword]
        );

        const newUser = { id: result.insertId, name, email, year, class: className };
        const token = generateToken(newUser);

        res.status(201).json({
            message: 'User created successfully',
            user: newUser,
            token
        });
    } catch (error) {
        console.error('Signup error:', error);
        res.status(500).json({ message: 'Server error during signup' });
    }
});

// LOGIN ROUTE
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Find user by email
        const [users] = await pool.execute('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        const user = users[0];

        // Check password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        // Generate token
        const token = generateToken(user);

        res.json({
            message: 'Login successful',
            user: { id: user.id, name: user.name, email: user.email, year: user.year, class: user.class },
            token
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: 'Server error during login' });
    }
});

module.exports = router;
