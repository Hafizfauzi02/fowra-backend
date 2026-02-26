const express = require('express');
const router = express.Router();
const pool = require('../db');

// HTML template for a simple table view
const generateHtmlTable = (tableName, rows) => {
    if (rows.length === 0) return `<p>Table <strong>${tableName}</strong> is empty.</p>`;

    const columns = Object.keys(rows[0]);

    let html = `
    <h2>Table: ${tableName}</h2>
    <table border="1" cellpadding="8" style="border-collapse: collapse; width: 100%; font-family: sans-serif; margin-bottom: 2rem;">
      <tr style="background-color: #f2f2f2;">
        ${columns.map(col => `<th>${col}</th>`).join('')}
      </tr>
  `;

    rows.forEach(row => {
        html += '<tr>';
        columns.forEach(col => {
            html += `<td>${row[col] !== null ? row[col] : '<i>NULL</i>'}</td>`;
        });
        html += '</tr>';
    });

    html += '</table>';
    return html;
};

// Route to view all tables and their contents
router.get('/tables', async (req, res) => {
    try {
        let htmlContent = `
      <html>
      <head>
        <title>Database Viewer</title>
        <style>
          body { font-family: Arial, sans-serif; padding: 20px; max-width: 1000px; margin: 0 auto; color: #333; }
          h1 { color: #2E654D; }
        </style>
      </head>
      <body>
        <h1>Fowra Database Viewer (fowra_db)</h1>
        <p>This is a simple viewer for your MySQL database tables.</p>
        <hr/>
    `;

        // Fetch users table
        const [users] = await pool.execute('SELECT * FROM users');
        htmlContent += generateHtmlTable('users', users);

        // Fetch plants table
        const [plants] = await pool.execute('SELECT * FROM plants');
        htmlContent += generateHtmlTable('plants', plants);

        htmlContent += `
      </body>
      </html>
    `;

        res.send(htmlContent);
    } catch (error) {
        console.error('Error fetching tables:', error);
        res.status(500).send('Error loading database tables');
    }
});

module.exports = router;
