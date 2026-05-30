# pyright: reportMissingImports=false
from datetime import datetime

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer, get_options
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    Formatter,
    TabBarData,
    as_rgb,
    draw_attributed_string,
    draw_tab_with_powerline,
)
from kitty.utils import color_as_int

opts = get_options()
icon_fg = as_rgb(color_as_int(opts.color16))
icon_bg = as_rgb(color_as_int(opts.color8))
bat_text_color = as_rgb(color_as_int(opts.color15))
clock_color = as_rgb(color_as_int(opts.color15))
date_color = as_rgb(color_as_int(opts.color8))
RIGHT_MARGIN = 1
REFRESH_TIME = 1
ICON = "  "
HOME_DIR = "/home/x404"

UNPLUGGED_ICONS = {
    10: "",
    20: "",
    30: "",
    40: "",
    50: "",
    60: "",
    70: "",
    80: "",
    90: "",
    100: "",
}
PLUGGED_ICONS = {
    1: "",
}
UNPLUGGED_COLORS = {
    15: as_rgb(color_as_int(opts.color1)),
    16: as_rgb(color_as_int(opts.color15)),
}
PLUGGED_COLORS = {
    15: as_rgb(color_as_int(opts.color1)),
    16: as_rgb(color_as_int(opts.color6)),
    99: as_rgb(color_as_int(opts.color6)),
    100: as_rgb(color_as_int(opts.color2)),
}


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


def draw_title(data) -> str:
    return _short_path(data.get("active_wd", ""), data.get("title", ""))


def _draw_icon(screen: Screen, index: int) -> int:
    if index != 1:
        return screen.cursor.x
    fg, bg, bold, italic = (
        screen.cursor.fg,
        screen.cursor.bg,
        screen.cursor.bold,
        screen.cursor.italic,
    )
    screen.cursor.bold, screen.cursor.italic, screen.cursor.fg, screen.cursor.bg = (
        True,
        False,
        icon_fg,
        icon_bg,
    )
    screen.draw(ICON)
    screen.cursor.x = len(ICON)
    screen.cursor.fg, screen.cursor.bg, screen.cursor.bold, screen.cursor.italic = (
        fg,
        bg,
        bold,
        italic,
    )
    return screen.cursor.x


def _redraw_tab_bar(_):
    tm = get_boss().active_tab_manager
    if tm is not None:
        tm.mark_tab_bar_dirty()


def get_battery_cells() -> list:
    try:
        with open("/sys/class/power_supply/BAT0/status", "r") as f:
            status = f.read()
        with open("/sys/class/power_supply/BAT0/capacity", "r") as f:
            percent = int(f.read())
        if status == "Discharging\n":
            icon_color = UNPLUGGED_COLORS[
                min(UNPLUGGED_COLORS.keys(), key=lambda x: abs(x - percent))
            ]
            icon = UNPLUGGED_ICONS[
                min(UNPLUGGED_ICONS.keys(), key=lambda x: abs(x - percent))
            ]
        elif status == "Not charging\n":
            icon_color = UNPLUGGED_COLORS[
                min(UNPLUGGED_COLORS.keys(), key=lambda x: abs(x - percent))
            ]
            icon = PLUGGED_ICONS[
                min(PLUGGED_ICONS.keys(), key=lambda x: abs(x - percent))
            ]
        else:
            icon_color = PLUGGED_COLORS[
                min(PLUGGED_COLORS.keys(), key=lambda x: abs(x - percent))
            ]
            icon = PLUGGED_ICONS[
                min(PLUGGED_ICONS.keys(), key=lambda x: abs(x - percent))
            ]
        return [(bat_text_color, str(percent) + "% "), (icon_color, icon)]
    except FileNotFoundError:
        return []


def _draw_right_status(draw_data: DrawData, screen: Screen) -> None:
    draw_attributed_string(Formatter.reset, screen)
    cells = get_battery_cells()
    cells.append((clock_color, datetime.now().strftime(" %H:%M")))
    cells.append((date_color, datetime.now().strftime(" %d.%m.%Y")))

    while True:
        if not cells:
            return
        padding = screen.columns - screen.cursor.x - sum(len(text) for _, text in cells) - RIGHT_MARGIN
        if padding >= 0:
            break
        cells = cells[1:]

    if padding:
        screen.draw(" " * padding)

    tab_bg = as_rgb(int(draw_data.inactive_bg))
    default_bg = as_rgb(int(draw_data.default_bg))
    for i, (fg, text) in enumerate(cells):
        screen.cursor.fg = tab_bg if i == 0 else default_bg
        screen.cursor.bg = 0 if i == 0 else tab_bg
        screen.draw("" if i == 0 else "")
        screen.cursor.fg = fg
        screen.cursor.bg = tab_bg
        screen.draw(text)

    screen.cursor.fg = 0
    screen.cursor.bg = 0


timer_id = None


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global timer_id
    if timer_id is None:
        timer_id = add_timer(_redraw_tab_bar, REFRESH_TIME, True)

    _draw_icon(screen, index)

    title_padding = "  " if tab.is_active else " "
    title_template = (
        "{fmt.fg.tab}"
        "{bell_symbol}{activity_symbol}"
        + title_padding
        + " {custom}"
        + title_padding
    )
    new_draw_data = draw_data._replace(
        title_template=title_template,
        active_title_template=title_template,
    )
    end = draw_tab_with_powerline(
        new_draw_data,
        screen,
        tab,
        before,
        max_title_length,
        index,
        is_last,
        extra_data,
    )
    if is_last:
        _draw_right_status(new_draw_data, screen)
    return end
