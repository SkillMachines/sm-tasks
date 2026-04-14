from http.server import BaseHTTPRequestHandler, HTTPServer
import json, datetime

class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def do_GET(self):
        body = json.dumps({
            "backend": "backend3",
            "port": 8003,
            "status": "ok",
            "time": datetime.datetime.utcnow().isoformat() + "Z",
        }).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", len(body))
        self.end_headers()
        self.wfile.write(body)

if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 8003), Handler)
    print("backend3 listening on :8003")
    server.serve_forever()
