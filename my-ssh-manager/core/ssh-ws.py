#!/usr/bin/env python3
"""
SSH-Over-WebSocket Proxy Bridge
Listens on local port 10003, handles WS upgrade headers, 
and pipes payload directly to OpenSSH port 22.
"""

import socket
import threading
import sys

LISTEN_HOST = '127.0.0.1'
LISTEN_PORT = 10003
SSH_HOST = '127.0.0.1'
SSH_PORT = 22
BUFFER_SIZE = 8192

RESPONSE_200 = (
    b"HTTP/1.1 101 Switching Protocols\r\n"
    b"Upgrade: websocket\r\n"
    b"Connection: Upgrade\r\n\r\n"
)

def pipe_sockets(src, dst):
    """Pipes incoming data from src socket directly to dst socket."""
    try:
        while True:
            data = src.recv(BUFFER_SIZE)
            if not data:
                break
            dst.sendall(data)
    except Exception:
        pass
    finally:
        src.close()
        dst.close()

def handle_client(client_socket):
    """Handles initial HTTP WebSocket handshake and bridges to SSH."""
    try:
        request = client_socket.recv(BUFFER_SIZE)
        
        # Check if request is a WebSocket upgrade request
        if b"Upgrade: websocket" in request or b"HTTP/" in request:
            client_socket.sendall(RESPONSE_200)

        # Connect to OpenSSH daemon
        ssh_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        ssh_socket.connect((SSH_HOST, SSH_PORT))

        # Start bidirectional piping
        t1 = threading.Thread(target=pipe_sockets, args=(client_socket, ssh_socket), daemon=True)
        t2 = threading.Thread(target=pipe_sockets, args=(ssh_socket, client_socket), daemon=True)
        t1.start()
        t2.start()

    except Exception:
        client_socket.close()

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        server.bind((LISTEN_HOST, LISTEN_PORT))
        server.listen(100)
        print(f"[*] SSH-WS Proxy listening on {LISTEN_HOST}:{LISTEN_PORT} -> {SSH_HOST}:{SSH_PORT}")
    except Exception as e:
        print(f"[-] Failed to bind port {LISTEN_PORT}: {e}")
        sys.exit(1)

    while True:
        client_socket, addr = server.accept()
        client_thread = threading.Thread(target=handle_client, args=(client_socket,), daemon=True)
        client_thread.start()

if __name__ == '__main__':
    main()