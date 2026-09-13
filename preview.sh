#!/bin/sh
# Serve rendered output over HTTP, e.g. for opening week-NN.html?print-pdf in a browser.
# Usage: ./preview.sh [PORT]   (default 8888)
PORT="${1:-8888}"
echo "Serving _output/ on port ${PORT}"
echo "Open: http://localhost:${PORT}"
python3 -m http.server "$PORT" --directory _output
