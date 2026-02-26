const pool = require('./db');

async function dropUniqueIndex() {
    try {
        console.log("Locating and removing the foreign key constraint on user_id...");
        // In MySQL, if the Foreign Key name wasn't explicitly provided during CREATE TABLE, 
        // it defaults to the table name + _ibfk_1. Let's drop it explicitly.
        try {
            await pool.query('ALTER TABLE diary_entries DROP FOREIGN KEY diary_entries_ibfk_1');
        } catch (e) { console.log('Notice: FK already dropped or named differently'); }

        console.log("Removing unique constraint user_date_unique...");
        await pool.query('ALTER TABLE diary_entries DROP INDEX user_date_unique');
        console.log("Successfully removed user_date_unique index.");

        console.log("Restoring the foreign key on user_id...");
        await pool.query('ALTER TABLE diary_entries ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE');
        console.log("Foreign key successfully restored!");

    } catch (err) {
        // If the error code is ER_CANT_DROP_FIELD_OR_KEY, it's already removed, which is fine!
        if (err.code === 'ER_CANT_DROP_FIELD_OR_KEY') {
            console.log("Index already removed or doesn't exist. Proceeding safely.");
        } else {
            console.error("Error executing query:", err);
        }
    } finally {
        pool.end();
    }
}

dropUniqueIndex();
