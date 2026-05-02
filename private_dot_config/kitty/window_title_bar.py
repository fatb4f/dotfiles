# pyright: reportMissingImports=false
from kitty.fast_data_types import Screen

HOME_DIR = "/home/x404"


def _short_path(cwd: str, title: str) -> str:
    cwd = (cwd or "").strip()
    if not cwd:
        return (title or "shell").strip() or "shell"
    if cwd == HOME_DIR:
        return "~"
    if cwd.startswith(HOME_DIR + "/"):
        rel = cwd[len(HOME_DIR) + 1 :]
        tail = rel.rsplit("/", 1)[-1]
        return f"~/{tail}" if tail else "~"
    return cwd.rsplit("/", 1)[-1] or "/"


def draw_window_title(data) -> str:
    return _short_path(data.get("active_wd", ""), data.get("title", ""))
