"use client";

import { useState, useEffect } from "react";

interface Todo {
  id: number;
  title: string;
  description: string | null;
  completed: boolean;
  created_at: string;
  updated_at: string;
}

export default function TodoApp() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [newTodo, setNewTodo] = useState({ title: "", description: "" });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchTodos();
  }, []);

  const fetchTodos = async () => {
    try {
      setLoading(true);
      const response = await fetch("/api/todos");
      const data = await response.json();
      setTodos(data.todos || []);
      setError(null);
    } catch (err) {
      setError("Failed to fetch todos");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const addTodo = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTodo.title.trim()) return;

    try {
      const response = await fetch("/api/todos", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(newTodo),
      });

      if (response.ok) {
        setNewTodo({ title: "", description: "" });
        fetchTodos();
      }
    } catch (err) {
      console.error("Failed to add todo:", err);
    }
  };

  const toggleTodo = async (id: number) => {
    try {
      const todo = todos.find((t) => t.id === id);
      if (!todo) return;

      const response = await fetch(`/api/todos/${id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ completed: !todo.completed }),
      });

      if (response.ok) {
        fetchTodos();
      }
    } catch (err) {
      console.error("Failed to update todo:", err);
    }
  };

  const deleteTodo = async (id: number) => {
    try {
      const response = await fetch(`/api/todos/${id}`, {
        method: "DELETE",
      });

      if (response.ok) {
        fetchTodos();
      }
    } catch (err) {
      console.error("Failed to delete todo:", err);
    }
  };

  if (loading) {
    return <div className="text-center py-8">Loading todos...</div>;
  }

  if (error) {
    return <div className="text-center py-8 text-red-500">{error}</div>;
  }

  return (
    <div className="max-w-2xl mx-auto bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
      <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
        Todo List
      </h2>

      <form onSubmit={addTodo} className="mb-6">
        <div className="flex gap-2">
          <input
            type="text"
            placeholder="What needs to be done?"
            value={newTodo.title}
            onChange={(e) => setNewTodo({ ...newTodo, title: e.target.value })}
            className="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 dark:bg-gray-700 dark:text-white"
          />
          <button
            type="submit"
            className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
          >
            Add
          </button>
        </div>
        <input
          type="text"
          placeholder="Description (optional)"
          value={newTodo.description}
          onChange={(e) =>
            setNewTodo({ ...newTodo, description: e.target.value })
          }
          className="w-full mt-2 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 dark:bg-gray-700 dark:text-white"
        />
      </form>

      <div className="space-y-3">
        {todos.length === 0 ? (
          <p className="text-center text-gray-500 dark:text-gray-400 py-4">
            No todos yet. Add one above!
          </p>
        ) : (
          todos.map((todo) => (
            <div
              key={todo.id}
              className={`flex items-start gap-3 p-4 border rounded-lg ${
                todo.completed
                  ? "bg-gray-50 dark:bg-gray-700 border-gray-200 dark:border-gray-600"
                  : "bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-700"
              }`}
            >
              <input
                type="checkbox"
                checked={todo.completed}
                onChange={() => toggleTodo(todo.id)}
                className="mt-1 w-4 h-4 text-blue-500 rounded focus:ring-blue-500"
              />
              <div className="flex-1">
                <h3
                  className={`font-medium ${
                    todo.completed
                      ? "line-through text-gray-500 dark:text-gray-400"
                      : "text-gray-900 dark:text-white"
                  }`}
                >
                  {todo.title}
                </h3>
                {todo.description && (
                  <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                    {todo.description}
                  </p>
                )}
                <p className="text-xs text-gray-400 dark:text-gray-500 mt-2">
                  {new Date(todo.created_at).toLocaleDateString()}
                </p>
              </div>
              <button
                onClick={() => deleteTodo(todo.id)}
                className="text-red-500 hover:text-red-700 transition-colors"
              >
                <svg
                  className="w-5 h-5"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                  />
                </svg>
              </button>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
