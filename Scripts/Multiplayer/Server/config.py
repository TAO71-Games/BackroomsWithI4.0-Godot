from typing import Any
import classes

class Config():
    def __init__(self) -> None:
        self.Server: dict[str, Any] = {"host": "0.0.0.0", "port": 65287, "max_players": 1000}
        self.PlayerAdminTag: str = "admin"

class Info():
    def __init__(self) -> None:
        self.Worlds: list[classes.Map] = []
        self.Players: list[classes.Player] = []
        self.Objects: list[classes.Item] = []
