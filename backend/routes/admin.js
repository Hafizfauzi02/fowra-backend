const express = require('express');
const router = express.Router();
const pool = require('../db');

// Enable CORS specifically for the admin routes if needed, 
// though index.js already has global cors().

// GET overview stats
router.get('/stats', async (req, res) => {
  try {
    const [userCount] = await pool.execute('SELECT COUNT(*) as count FROM users');
    const [plantCount] = await pool.execute('SELECT COUNT(*) as count FROM plants');

    // Count today's diary entries
    const today = new Date().toISOString().split('T')[0];
    const [diaryCount] = await pool.execute('SELECT COUNT(*) as count FROM diary_entries WHERE entry_date = ?', [today]);

    res.json({
      success: true,
      data: {
        totalStudents: userCount[0].count,
        totalPlants: plantCount[0].count,
        entriesToday: diaryCount[0].count
      }
    });
  } catch (error) {
    console.error('Stats error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch stats' });
  }
});

// GET all students
router.get('/students', async (req, res) => {
  try {
    const [users] = await pool.execute('SELECT id, name, year, class, email, created_at FROM users ORDER BY created_at DESC');
    res.json({ success: true, data: users });
  } catch (error) {
    console.error('Students error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch students' });
  }
});

// GET plants for a specific student
router.get('/student/:id/plants', async (req, res) => {
  try {
    const { id } = req.params;
    const [plants] = await pool.execute('SELECT * FROM plants WHERE user_id = ? ORDER BY created_at DESC', [id]);
    res.json({ success: true, data: plants });
  } catch (error) {
    console.error('Student plants error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch plants for student' });
  }
});

// GET diary entries for a specific student
router.get('/student/:id/diary', async (req, res) => {
  try {
    const { id } = req.params;
    const [entries] = await pool.execute('SELECT * FROM diary_entries WHERE user_id = ? ORDER BY entry_date DESC', [id]);
    res.json({ success: true, data: entries });
  } catch (error) {
    console.error('Student diary error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch diary entries for student' });
  }
});

module.exports = router;
