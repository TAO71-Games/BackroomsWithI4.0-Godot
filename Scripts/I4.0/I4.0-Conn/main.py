from typing import Any

def __print__(Mode: str, Values: list[Any] = []) -> None:
    print(f"|===|ENTER_MODE;{Mode}{';' if (len(Values) > 0) else ''}{';'.join([str(v) for v in Values])}|===|", end = "\n", flush = True)

if (__name__ == "__main__"):
    try:
        __print__("PROGRAM_START")
        import api as _

        __print__("PROGRAM_END", ["GOOD"])
    except Exception as ex:
        __print__("PROGRAM_END", ["ERR", ex])
        exit(1)