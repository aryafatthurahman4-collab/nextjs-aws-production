"use client";

import { useState, useEffect } from "react";

interface GuestbookEntry {
  id: number;
  name: string;
  message: string;
  created_at: string;
}

export default function Guestbook() {
  const [entries, setEntries] = useState<GuestbookEntry[]>([]);
  const [name, setName] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    fetchEntries();
  }, []);

  async function fetchEntries() {
    try {
      const response = await fetch("/api/guestbook");
      const data = await response.json();
      setEntries(data.entries || []);
    } catch (error) {
      console.error("Error fetching entries:", error);
    } finally {
      setLoading(false);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name || !message) return;

    setSubmitting(true);
    try {
      const response = await fetch("/api/guestbook", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, message }),
      });

      if (response.ok) {
        setName("");
        setMessage("");
        await fetchEntries();
      }
    } catch (error) {
      console.error("Error submitting entry:", error);
    } finally {
      setSubmitting(false);
    }
  }

  if (loading) {
    return (
      <div className="text-center py-8">
        <div className="text-gray-600 dark:text-gray-300">Loading guestbook...</div>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto">
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 mb-6">
        <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
          Guestbook
        </h2>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Nama
            </label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 dark:bg-gray-700 dark:text-white"
              placeholder="Nama Anda"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Pesan
            </label>
            <textarea
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 dark:bg-gray-700 dark:text-white"
              placeholder="Tulis pesan Anda..."
              rows={3}
              required
            />
          </div>

          <button
            type="submit"
            disabled={submitting}
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition-colors disabled:opacity-50"
          >
            {submitting ? "Mengirim..." : "Kirim"}
          </button>
        </form>
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
        <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-4">
          Pesan ({entries.length})
        </h3>

        {entries.length === 0 ? (
          <p className="text-gray-600 dark:text-gray-300 text-center py-4">
            Belum ada pesan. Jadilah yang pertama menulis.
          </p>
        ) : (
          <div className="space-y-4">
            {entries.map((entry) => (
              <div
                key={entry.id}
                className="border-b border-gray-200 dark:border-gray-700 pb-4 last:border-0"
              >
                <div className="flex justify-between items-start mb-2">
                  <h4 className="font-semibold text-gray-900 dark:text-white">
                    {entry.name}
                  </h4>
                  <span className="text-sm text-gray-500 dark:text-gray-400">
                    {new Date(entry.created_at).toLocaleString("id-ID")}
                  </span>
                </div>
                <p className="text-gray-700 dark:text-gray-300">{entry.message}</p>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
