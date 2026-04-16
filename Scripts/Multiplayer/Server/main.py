from typing import Any
import os
import json
import argparse
import socket
import hashlib
import random

def SendData(Socket: socket.socket, Data: str) -> None:
    data = []

    while (len(Data) >= 8192):
        data.append(Data[:8192])
        Data = Data[8192:]
    
    for d in data:
        Socket.send(d.encode("utf-8"))

    Socket.send("--END--".encode("utf-8"))

def RecvData(Socket: socket.socket) -> str:
    recvData = ""

    while (True):
        recv = Socket.recv(8192).decode("utf-8").strip()

        if (len(recv) == 0):
            return ""

        recvData += recv[:recv.rfind("--END--")] if (recv.endswith("--END--")) else recv

        if (recv.endswith("--END--")):
            break
    
    return recvData.strip()

def ClientReceive(Socket: socket.socket, Address: tuple[str, int], Data: str) -> None:
    if (len(Data) == 0):
        raise ValueError("No data. Probably connection closed.")

    try:
        parserdData: dict[str, Any] = json.loads(Data)
        action: str = parsedData["action"]
        arguments: list[Any] = parsedData["args"]

        if (action == "connect"):
            username = arguments[0]
            passwd = arguments[1].encode("utf-8")
            passwdHash = hashlib.sha3_512(passwd).hexdigest()

            if (username not in INFO["players"]):
                INFO["players"][username] = {
                    "auth_hash": passwdHash,
                    "position": [0, 0, 0],
                    "rotation": [0, 0, 0],
                    "scale": [1, 1, 1],
                    "groups": [],
                    "items": [],
                    "health": 100,
                    "water": 100,
                    "food": 100,
                    "stamina": 100,
                    "session_id": None
                }

            if (INFO["players"][username]["auth_hash"] == passwdHash):
                INFO["players"][username]["session_id"] = random.randint()  # TODO
        elif (action == "set_pos"):
            pass
    except:
        pass

def ClientConnected(Socket: socket.socket, Address: tuple[str, int]) -> None:
    while (True):
        try:
            data = RecvData(Socket)
            ClientReceive(Socket, Address, data)
        except:
            break
    
    Socket.close()

def EnsureFilesAndData() -> None:
    if (not os.path.exists(args.CONFIG_FILE)):
        with open(args.CONFIG_FILE, "x") as f:
            f.write(json.dumps(DEFAULT_CONFIG))

    if (not os.path.exists(args.INFO_FILE)):
        with open(args.INFO_FILE, "x") as f:
            f.write(json.dumps(DEFAULT_INFO))

def ReadConfig() -> dict[str, Any]:
    with open(args.CONFIG_FILE, "r") as f:
        conf = json.loads(f.read())

    for k, v in DEFAULT_CONFIG.items():
        if (k not in conf):
            conf[k] = v

    return conf

def ReadInfo() -> dict[str, Any]:
    with open(args.INFO_FILE, "r") as f:
        info = json.loads(f.read())

    for k, v in DEFAULT_INFO.items():
        if (k not in info):
            info[k] = v

    return info

DEFAULT_CONFIG_FILE: str = "./default_config.json"
DEFAULT_INFO_FILE: str = "./default_info.json"

with open(DEFAULT_CONFIG_FILE, "r") as f:
    DEFAULT_CONFIG: dict[str, Any] = json.loads(f.read())

with open(DEFAULT_INFO_FILE, "r") as f:
    DEFAULT_INFO: dict[str, Any] = json.loads(f.read())

parser = argparse.ArgumentParser(prog = "BWI Server", description = "Start a BWI server.")
parser.add_argument("--config", dest = "CONFIG_FILE", type = str, default = "./config.json", required = False, help = "Configuration file.")
parser.add_argument("--info", dest = "INFO_FILE", type = str, default = "./info.json", required = False, help = "Information file.")

args = parser.parse_args()

EnsureFilesAndData()
CONFIG = ReadConfig()
INFO = ReadInfo()

if (__name__ == "__main__"):
    Server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    Server.bind((CONFIG["server"]["host"], CONFIG["server"]["port"]))
    Server.listen()

    while (True):
        try:
            clientSocket, clientAddr = Server.accept()
            ClientConnected(clientSocket, clientAddr)
        except KeyboardInterrupt:
            break

    Server.shutdown(socket.SHUT_RDWR)
    Server.close()
