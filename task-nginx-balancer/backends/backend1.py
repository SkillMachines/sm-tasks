from http.server import BaseHTTPRequestHandler, HTTPServer
import json, datetime

class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass  # suppress default access log noise

    def do_GET(self):
        body = json.dumps({
            "backend": "backend1",
            "port": 8001,
            "status": "ok",
            "time": datetime.datetime.utcnow().isoformat() + "Z",
        }).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", len(body))
        self.end_headers()
        self.wfile.write(body)

if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 8001), Handler)
    print("backend1 listening on :8001")
    server.serve_forever()
