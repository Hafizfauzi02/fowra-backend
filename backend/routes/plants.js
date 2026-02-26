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

// GET all plants for the logged in user
router.get('/', authMiddleware, async (req, res) => {
    try {
        const [plants] = await pool.execute(
            'SELECT * FROM plants WHERE user_id = ? ORDER BY created_at DESC',
            [req.user.id]
        );
        res.json(plants);
    } catch (error) {
        console.error('Fetch plants error:', error);
        res.status(500).json({ message: 'Failed to fetch plants' });
    }
});

// POST a new plant
router.post('/', authMiddleware, async (req, res) => {
    try {
        const {
            name,
            image_path,
            sun_exposure,
            water_amount,
            soil_ph,
            harvest_days,
            height
        } = req.body;

        const [result] = await pool.execute(
            `INSERT INTO plants 
      (user_id, name, image_path, sun_exposure, water_amount, soil_ph, harvest_days, height) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            [req.user.id, name, image_path || 'assets/plantlist/tomato.webp', sun_exposure, water_amount, soil_ph, harvest_days, height]
        );

        res.status(201).json({
            message: 'Plant added successfully',
            plantId: result.insertId
        });
    } catch (error) {
        console.error('Add plant error:', error);
        res.status(500).json({ message: 'Failed to add plant' });
    }
});

// DELETE a plant by ID
router.delete('/:id', authMiddleware, async (req, res) => {
    try {
        const plantId = req.params.id;

        // First, check if the plant exists and belongs to the user
        const [plants] = await pool.execute(
            'SELECT * FROM plants WHERE id = ? AND user_id = ?',
            [plantId, req.user.id]
        );

        if (plants.length === 0) {
            return res.status(404).json({ message: 'Plant not found or not authorized to delete' });
        }

        // Output the deletion
        await pool.execute('DELETE FROM plants WHERE id = ?', [plantId]);

        res.json({ message: 'Plant deleted successfully' });
    } catch (error) {
        console.error('Delete plant error:', error);
        res.status(500).json({ message: 'Failed to delete plant' });
    }
});

// PUT update a plant by ID
router.put('/:id', authMiddleware, async (req, res) => {
    try {
        const plantId = req.params.id;
        const {
            name,
            image_path,
            sun_exposure,
            water_amount,
            soil_ph,
            harvest_days,
            height
        } = req.body;

        // First, check if the plant exists and belongs to the user
        const [plants] = await pool.execute(
            'SELECT * FROM plants WHERE id = ? AND user_id = ?',
            [plantId, req.user.id]
        );

        if (plants.length === 0) {
            return res.status(404).json({ message: 'Plant not found or not authorized to update' });
        }

        // Output the update
        await pool.execute(
            `UPDATE plants SET 
            name = ?, image_path = ?, sun_exposure = ?, water_amount = ?, soil_ph = ?, harvest_days = ?, height = ?
            WHERE id = ?`,
            [name, image_path, sun_exposure, water_amount, soil_ph, harvest_days, height, plantId]
        );

        res.json({ message: 'Plant updated successfully' });
    } catch (error) {
        console.error('Update plant error:', error);
        res.status(500).json({ message: 'Failed to update plant' });
    }
});

module.exports = router;
