#!/bin/bash
# Database setup script

set -e

echo "=== Database Setup Script ==="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found. Please copy .env.example to .env and configure it."
    exit 1
fi

# Load environment variables
source .env

# Check database configuration
if [ -z "$DATABASE_URL" ]; then
    echo "Error: DATABASE_URL not set in .env"
    exit 1
fi

echo "Testing database connection..."

# Test connection using Node.js
docker compose exec app node -e "
const { Client } = require('pg');
const client = new Client({ 
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : undefined
});

client.connect()
  .then(() => client.query('SELECT version()'))
  .then(result => {
    console.log('✓ Database connection successful');
    console.log('Database version:', result.rows[0].version);
    client.end();
  })
  .catch(err => {
    console.error('✗ Database connection failed:', err.message);
    client.end();
    process.exit(1);
  });
"

echo "✓ Database setup completed!"
