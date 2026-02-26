const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;

// Routers
const authRoutes = require('./routes/auth');
const plantRoutes = require('./routes/plants');
const diaryRoutes = require('./routes/diary');
const adminRoutes = require('./routes/admin');

// Middleware
app.use(cors());
app.use(express.json());

// Main Route
app.get('/', (req, res) => {
    res.send('Fowra API is running! Go to <a href="/api/admin/tables">/api/admin/tables</a> to view your database.');
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/plants', plantRoutes);
app.use('/api/diary', diaryRoutes);
app.use('/api/admin', adminRoutes);

// Start Server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
