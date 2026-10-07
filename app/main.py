import os
from flask import Flask, jsonify, request

app = Flask(__name__)
todos = []  # simple in-memory list (resets when container restarts)

VERSION = os.getenv("APP_VERSION", "dev")


@app.get("/health")
def health():
    return jsonify(status="ok", version=VERSION)


@app.get("/todos")
def list_todos():
    return jsonify(todos)


@app.post("/todos")
def add_todo():
    data = request.get_json(silent=True) or {}
    title = data.get("title", "").strip()
    if not title:
        return jsonify(error="title is required"), 400
    todo = {"id": len(todos) + 1, "title": title, "done": False}
    todos.append(todo)
    return jsonify(todo), 201


@app.put("/todos/<int:todo_id>/done")
def mark_done(todo_id):
    for t in todos:
        if t["id"] == todo_id:
            t["done"] = True
            return jsonify(t)
    return jsonify(error="not found"), 404


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "5000")))
