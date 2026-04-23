from typing import Any, Self
import copy
import classes

class Config():
    def __init__(self) -> None:
        self.Server: dict[str, Any] = {"Host": "0.0.0.0", "Port": 65287, "MaxPlayers": 1000}
        self.PlayerAdminTag: str = "admin"
    
    def ToDict(self) -> dict[str, Any]:
        d = copy.deepcopy(self.__dict__)

        for k, v in d.items():
            if ("GetDictionary_Save" in v):
                d[k] = v.GetDictionary_Save()
            elif ("GetDictionary_Player" in v):
                d[k] = v.GetDictionary_Player()
            else:
                d[k] = v

        return d
    
    @classmethod
    def FromDict(cls, D: dict[str, Any]) -> Self:
        instance = cls.__new__(cls)

        for k, v in D.items():
            setattr(instance, k, v)
        
        return instance

class Info():
    def __init__(self) -> None:
        self.Worlds: list[classes.Map] = []
        self.Players: list[classes.Player] = []
        self.Objects: list[classes.Item] = []
    
    def ToDict(self) -> dict[str, Any]:
        d = copy.deepcopy(self.__dict__)

        for k, v in d.items():
            if ("GetDictionary_Save" in v):
                d[k] = v.GetDictionary_Save()
            elif ("GetDictionary_Player" in v):
                d[k] = v.GetDictionary_Player()
            else:
                d[k] = v

        return d
    
    @classmethod
    def FromDict(cls, D: dict[str, Any]) -> Self:
        instance = cls.__new__(cls)

        for k, v in D.items():
            setattr(instance, k, v)
        
        return instance