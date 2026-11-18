import { Pool } from "pg";

let pool: Pool | null = null;

export function getPool(): Pool {
  if (!pool) {
    const connectionString = process.env.DATABASE_URL;
    
    if (!connectionString) {
      throw new Error("DATABASE_URL environment variable is not set");
    }

    pool = new Pool({
      connectionString,
      ssl: process.env.DATABASE_SSL === "true" ? { rejectUnauthorized: false } : undefined,
      max: parseInt(process.env.DB_POOL_MAX || "5", 10),
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
    });

    // Initialize schema
    initializeSchema(pool);
  }

  return pool;
}

async function initializeSchema(pool: Pool) {
  try {
    // Create todos table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS todos (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        completed BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
      );

      CREATE INDEX IF NOT EXISTS todos_created_at_idx ON todos (created_at DESC);
      CREATE INDEX IF NOT EXISTS todos_completed_idx ON todos (completed);
    `);

    // Create guestbook table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS guestbook (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
      );

      CREATE INDEX IF NOT EXISTS guestbook_created_at_idx ON guestbook (created_at DESC);
    `);
  } catch (error) {
    console.error("Error initializing schema:", error);
  }
}
