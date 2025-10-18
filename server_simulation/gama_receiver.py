# gama_receiver.py
# -----------------
# Cài thư viện cần thiết:
# pip install websockets
# python gama_receiver.py

import asyncio
import websockets
import json

HOST = 'localhost'
PORT = 3001  # Phải trùng với cổng mà GAMA dùng để connect

async def handle_client(websocket):
    print("Client connected from {websocket.remote_address}")
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

async def main():
    print("Starting WebSocket server on ws://{HOST}:{PORT}")
    async with websockets.serve(handle_client, HOST, PORT):
        await asyncio.Future()  # Run forever

if __name__ == "__main__":
    asyncio.run(main())
