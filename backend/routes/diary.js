const express = require('express');
const router = express.Router();
const pool = require('../db');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'fowra_super_secret_key_123';

// Middleware to verify JWT token
const authMiddleware = (req, res, next) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
        return res.status(401).json({ message: 'No auth token found, access denied' });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        res.status(401).json({ message: 'Token is invalid' });
    }
};
router.get('/:date', authMiddleware, async (req, res) => {
    try {
        const { date } = req.params;
        const [entries] = await pool.execute(
            'SELECT * FROM diary_entries WHERE user_id = ? AND entry_date = ? ORDER BY created_at ASC',
            [req.user.id, date]
        );

        res.json({ message: 'Diary entries retrieved successfully', data: entries });
    } catch (error) {
        console.error('Fetch diary error:', error);
        res.status(500).json({ message: 'Failed to fetch diary entry' });
    }
});

// POST to create or update a diary entry
router.post('/', authMiddleware, async (req, res) => {
    try {
        const {
            id = null,
            entry_date,
            entry_time = null,
            watering = false,
            misting = false,
            fertilizing = false,
            rotating = false,
            notes = '',
            image_path = null
        } = req.body;

        if (!entry_date) {
            return res.status(400).json({ message: 'entry_date is required' });
        }

        if (id) {
            // Update existing entry
            const query = `
                UPDATE diary_entries 
                SET entry_time=?, watering=?, misting=?, fertilizing=?, rotating=?, notes=?, image_path=? 
                WHERE id=? AND user_id=?
            `;
            await pool.execute(query, [
                entry_time, watering, misting, fertilizing, rotating, notes, image_path, id, req.user.id
            ]);
            res.status(200).json({ message: 'Diary entry updated successfully' });
        } else {
            // Create new entry
            const query = `
                INSERT INTO diary_entries 
                (user_id, entry_date, entry_time, watering, misting, fertilizing, rotating, notes, image_path) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            `;
            await pool.execute(query, [
                req.user.id, entry_date, entry_time, watering, misting, fertilizing, rotating, notes, image_path
            ]);
            res.status(201).json({ message: 'Diary entry created successfully' });
        }
    } catch (error) {
        console.error('Save diary error:', error);
        res.status(500).json({ message: 'Failed to save diary entry' });
    }
});

// DELETE a diary entry by ID
router.delete('/:id', authMiddleware, async (req, res) => {
    try {
        const { id } = req.params;
        const [result] = await pool.execute(
            'DELETE FROM diary_entries WHERE user_id = ? AND id = ?',
            [req.user.id, id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Diary entry not found or already deleted' });
        }

        res.json({ message: 'Diary entry deleted successfully' });
    } catch (error) {
        console.error('Delete diary error:', error);
        res.status(500).json({ message: 'Failed to delete diary entry' });
    }
});

module.exports = router;
