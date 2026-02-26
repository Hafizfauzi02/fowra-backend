const pool = require('./db');

async function createTable() {
    try {
        const createTableQuery = `
      CREATE TABLE IF NOT EXISTS diary_entries (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        entry_date DATE NOT NULL,
        watering BOOLEAN DEFAULT FALSE,
        misting BOOLEAN DEFAULT FALSE,
        fertilizing BOOLEAN DEFAULT FALSE,
        rotating BOOLEAN DEFAULT FALSE,
        notes TEXT,
        image_path VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE KEY user_date_unique (user_id, entry_date),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `;
        await pool.query(createTableQuery);
        console.log("successfully created diary_entries table");
    } catch (err) {
        console.error("error creating table:", err);
    } finally {
        pool.end();
    }
}

createTable();
