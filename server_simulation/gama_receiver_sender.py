# gama_receiver.py
# -----------------
# Cài thư viện cần thiết:
# pip install websockets
# python gama_receiver.py

import asyncio
import websockets
import json
import threading
import sys

HOST = 'localhost'
PORT = 3001  # Phải trùng với cổng mà GAMA dùng để connect

# Biến toàn cục để lưu websocket connection (giả sử chỉ 1 client)
active_websocket = None

def send_message_to_client(action):
    """Gửi message đến client qua websocket"""
    global active_websocket
    if active_websocket:
        try:
            message = json.dumps({"action": action})
            # Sử dụng loop hiện tại để gửi async
            loop = asyncio.get_event_loop()
            asyncio.run_coroutine_threadsafe(active_websocket.send(message), loop)
            print(f"Đã gửi yêu cầu '{action}' đến client.")
        except Exception as e:
            print(f"Lỗi khi gửi message: {e}")
    else:
        print("Chưa có client kết nối.")

def input_loop():
    """Loop đọc input từ console để gửi lệnh"""
    print("\n--- Hướng dẫn lệnh console ---")
    print("Nhập 'request' để gửi yêu cầu dữ liệu đến GAMA.")
    print("Nhập 'stop' để gửi yêu cầu dừng chế độ on-demand.")
    print("Nhập 'quit' để thoát chương trình.")
    print("------------------------------")
    
    while True:
        try:
            cmd = input("> ").strip().lower()
            if cmd == 'request':
                send_message_to_client('request')
            elif cmd == 'stop':
                send_message_to_client('stop')
            elif cmd == 'quit':
                print("Đang thoát...")
                sys.exit(0)
            else:
                print("Lệnh không hợp lệ. Thử lại.")
        except EOFError:
            break

async def handle_client(websocket):
    global active_websocket
    active_websocket = websocket
    print(f"Client connected from {websocket.remote_address}")
    
    try:
        async for message in websocket:
            print("\nReceived raw:", message)
            try:
                data = json.loads(message)
                print("Parsed JSON:", data)
            except json.JSONDecodeError:
                print("Not a valid JSON message, content:", message)
    except websockets.ConnectionClosed:
        print("Client disconnected")
    finally:
        active_websocket = None

async def main():
    # Khởi động thread cho input loop
    input_thread = threading.Thread(target=input_loop, daemon=True)
    input_thread.start()
    
    print(f"Starting WebSocket server on ws://{HOST}:{PORT}")
    print("Server đang chạy. Sử dụng console để gửi lệnh đến GAMA.")
    
    async with websockets.serve(handle_client, HOST, PORT):
        await asyncio.Future()  # Run forever

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nServer stopped by user.")