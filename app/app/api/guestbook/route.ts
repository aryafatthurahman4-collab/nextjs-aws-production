import { NextRequest, NextResponse } from "next/server";
import { getPool } from "@/lib/db";

export async function GET() {
  try {
    const pool = getPool();
    const result = await pool.query(
      "SELECT * FROM guestbook ORDER BY created_at DESC"
    );
    return NextResponse.json({ entries: result.rows });
  } catch (error) {
    console.error("Error fetching guestbook entries:", error);
    return NextResponse.json(
      { error: "Failed to fetch guestbook entries" },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { name, message } = body;

    if (!name || !message) {
      return NextResponse.json(
        { error: "Name and message are required" },
        { status: 400 }
      );
    }

    const pool = getPool();
    const result = await pool.query(
      "INSERT INTO guestbook (name, message) VALUES ($1, $2) RETURNING *",
      [name, message]
    );

    return NextResponse.json({ entry: result.rows[0] }, { status: 201 });
  } catch (error) {
    console.error("Error creating guestbook entry:", error);
    return NextResponse.json(
      { error: "Failed to create guestbook entry" },
      { status: 500 }
    );
  }
}
