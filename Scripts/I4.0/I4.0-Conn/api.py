from typing import Any
from I40Client.configuration import ClientConfiguration
from I40Client.server_connection import ClientSocket
import I40Client.Utilities.chatbot_tools as CBTools
import os
import base64
import argparse
import socket
import asyncio

def __print__(Mode: str, Values: list[Any] = []) -> None:
    print(f"|===|ENTER_MODE;{Mode}{';' if (len(Values) > 0) else ''}{';'.join([str(v) for v in Values])}|===|", end = "\n", flush = True)

async def __connect__(Host: str, Port: int) -> None:
    __print__("CONNECT", ["CONNECTING"])

    try:
        await conSocket.Connect(Host = Host, Port = Port, Secure = True)
    except:
        await conSocket.Connect(Host = Host, Port = Port, Secure = False)
    
    __print__("CONNECT", ["CONNECTED"])

async def IsModelAvailable(Service: str, ModelName: str) -> bool:
    try:
        response = await conSocket.GetModelInfo(ModelName)
        return response["service"] == Service
    except Exception as ex:
        return False

async def __ensure_model_available__(Service: str, ModelName: str) -> None:
    available = await IsModelAvailable(Service, ModelName)

    if (not available):
        raise RuntimeError(f"Model ('{Service}', '{ModelName}') not available.")

async def __cb_send__(ModelName: str) -> None:
    await __connect__(Server_Host, Server_Port)
    await __ensure_model_available__("chatbot", ModelName)

    __print__("CB_PROCESSING")

    response = conSocket.AdvancedSendAndReceive(
        ModelName = ModelName,
        Key = None,
        PromptConversation = Chatbot_Conv,
        PromptParameters = Chatbot_PP,
        UserParameters = Chatbot_UP,
        Service = "inference"
    )
    warnings = []
    errors = []
    filesSaved = []

    __print__("LISTEN_TOKENS")

    async for token in response:
        tokenResponse = token["response"] if ("response" in token) else {}
        tokenText = tokenResponse["text"] if ("text" in tokenResponse) else ""
        tokenFiles = tokenResponse["files"] if ("files" in tokenResponse) else []
        tokenExtraData = tokenResponse["extra"] if ("extra" in tokenResponse) else {}
        isThinking = tokenExtraData["thinking"] if ("thinking" in tokenExtraData) else False

        warnings += token["warnings"] if ("warnings" in token) else []
        errors += token["errors"] if ("errors" in token) else []

        if (isThinking):
            continue

        for file in tokenFiles:
            fileExt = "webp" if (file["type"] == "image") else "wav" if (file["type"] == "audio") else "mp4" if (file["type"] == "video") else "unknown"
            fileID = 0

            while (os.path.exists(f"FILE_{fileID}.{fileExt}")):
                fileID += 1
            
            with open(f"FILE_{fileID}.{fileExt}", "wb") as f:
                f.write(base64.b64decode(file[file["type"]]))
            
            filesSaved.append(f"FILE_{fileID}.{fileExt}")

        print(tokenText, end = "", flush = True)
    
    __print__("STOP_LISTEN_TOKENS")
    __print__("INFERENCE_END", ["chatbot", filesSaved, warnings, errors])

    await conSocket.Close()

async def SendToChatbot() -> None:
    await __cb_send__(Chatbot_Models[0])
    return

    for cb in Chatbot_Models:
        try:
            await __cb_send__(cb)
            break
        except:
            continue
    
    raise RuntimeError("Could not get response from model.")

Server_APIKey: str = ""
Server_Host: str = "main.tao71.org"
Server_Port: int = 8060

Chatbot_Models: list[str] = ["chatbot-latest-free"]
Chatbot_PP: dict[str, Any] = {"reasoning_mode": "think"}
Chatbot_UP: dict[str, Any] = {}
Chatbot_Conv: list[dict[str, str | dict[str, str]]] = [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "Hello!"}
]

config = ClientConfiguration()
config.Encryption_Hash = "sha512"
config.Encryption_Threads = 1
config.PingInterval = 20
config.Service_DefaultAPIKey = Server_APIKey

conSocket = ClientSocket(Type = "websocket", Configuration = config)

if (__name__ == "__main__"):
    asyncio.set_event_loop(asyncio.new_event_loop())
    asyncio.get_event_loop().run_until_complete(SendToChatbot())
    asyncio.get_event_loop().close()