import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "app"))
from main import app


def test_health():
    r = app.test_client().get("/health")
    assert r.status_code == 200
    assert r.get_json()["status"] == "ok"


def test_add_and_list_todo():
    c = app.test_client()
    r = c.post("/todos", json={"title": "learn jenkins"})
    assert r.status_code == 201
    assert any(t["title"] == "learn jenkins" for t in c.get("/todos").get_json())


def test_empty_title_rejected():
    assert app.test_client().post("/todos", json={"title": ""}).status_code == 400
