const pool = require('./db');

async function addEntryTime() {
    try {
        console.log("Adding entry_time column to diary_entries...");
        await pool.query('ALTER TABLE diary_entries ADD COLUMN entry_time TIME DEFAULT NULL');
        console.log("Successfully added entry_time column.");
    } catch (err) {
        if (err.code === 'ER_DUP_FIELDNAME') {
            console.log("Column entry_time already exists. Proceeding safely.");
        } else {
            console.error("Error executing query:", err);
        }
    } finally {
        pool.end();
    }
}

addEntryTime();
