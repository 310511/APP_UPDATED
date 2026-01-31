#!/bin/bash
# Restart All Services - All Output Visible in Terminal
# This script stops all services and restarts them with visible output

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "🛑 Stopping all existing services..."
echo ""

# Kill all existing processes
pkill -f "uvicorn.*server:socket_app" 2>/dev/null || true
pkill -f "node.*engage-server" 2>/dev/null || true
pkill -f "expo start" 2>/dev/null || true
pkill -f "redis-server" 2>/dev/null || true

sleep 2
echo "✅ All services stopped"
echo ""

# Check and start Redis
echo "🔍 Checking Redis..."
if ! redis-cli ping >/dev/null 2>&1; then
    echo "   ❌ Redis not running"
    echo "   💡 Please start Redis manually:"
    echo "      Option 1: redis-server (if installed)"
    echo "      Option 2: docker run -d -p 6379:6379 --name redis-skipon redis:latest"
    echo ""
else
    echo "   ✅ Redis is already running"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Starting all services..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Services will be started in separate terminal windows"
echo "   Each service will have its own window with visible output"
echo ""

# Function to open a new terminal window and run a command (fixed syntax)
open_terminal() {
    local title=$1
    local command=$2
    local dir=$3
    
    osascript -e "tell application \"Terminal\"" \
              -e "activate" \
              -e "tell application \"System Events\" to keystroke \"t\" using command down" \
              -e "delay 0.5" \
              -e "do script \"cd '$dir' && clear && echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' && echo '🚀 $title' && echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' && echo '' && $command\" in front window" \
              -e "end tell" 2>/dev/null || \
    osascript <<APPLESCRIPT
tell application "Terminal"
    activate
    do script "cd '$dir' && clear && echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' && echo '🚀 $title' && echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' && echo '' && $command"
end tell
APPLESCRIPT
}

# Start Backend on port 3001
echo "📱 Starting Backend (Port 3001)..."
open_terminal "Backend-3001" "python3 -m uvicorn server:socket_app --host 0.0.0.0 --port 3001 --reload" "$PROJECT_DIR/backend"

sleep 2

# Start Backend on port 3003
echo "📱 Starting Backend (Port 3003)..."
open_terminal "Backend-3003" "python3 -m uvicorn server:socket_app --host 0.0.0.0 --port 3003 --reload" "$PROJECT_DIR/backend"

sleep 2

# Start Engage Server
echo "📱 Starting Engage Server (Port 3002)..."
open_terminal "Engage-Server" "npm run start:engage" "$PROJECT_DIR/backend"

sleep 2

# Start Frontend
echo "📱 Starting Frontend..."
open_terminal "Frontend" "npm start" "$PROJECT_DIR/frontend (1)"

sleep 3

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All services are starting!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Service Status:"
echo "  • Redis: localhost:6379"
echo "  • Backend (REST + Socket.IO): http://localhost:3001"
echo "  • Backend (Socket.IO only): http://localhost:3003"
echo "  • Engage Server: http://localhost:3002"
echo "  • Frontend: Check the Frontend terminal window"
echo ""
echo "🔍 All output is visible in separate terminal windows"
echo "   Look for new Terminal windows that opened"
echo ""
