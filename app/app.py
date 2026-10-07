from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({"message": "Welcome to DevOps CI/CD Application!", "status": "active"})

@app.route("/health")
def health():
    return jsonify({"status": "ok", "version": "dev"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
