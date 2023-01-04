-- Basically wraps awful.screen to add a signal for focused screen changes.
-- The signal is automatically emitted when a client on a different screen is focused,
-- and when a client's screen property changes while it is focused.
-- In order for the signal to be emitted when manually changing the screen focus,
-- the focus_handler wrapper functions must be used.

local gears = require("gears")
local awful = require("awful")


local focus_handler = {}

function focus_handler:get_focused_screen()
    return self._focused_screen
end

local function update_focused_screen(h, s)
    if s == nil then s = awful.screen.focused() end
    if s ~= h._focused_screen then
        rawset(h, '_focused_screen', s)
        h:emit_signal("property::focused_screen")
    end
end

function focus_handler:focus_screen_relative(i)
    awful.screen.focus_relative(i)
    update_focused_screen(self)
end

function focus_handler:focus_screen(s)
    awful.screen.focus(s and screen[s])
    update_focused_screen(self)
end

local function setup(args)
    local ret = gears.object {
        class = focus_handler,
        enable_properties = true,
        enable_auto_signals = true
    }

    client.connect_signal("focus", function(c)
        update_focused_screen(ret, c.screen)
    end)

    client.connect_signal("property::screen", function(c)
        if client.focus == c then update_focused_screen(ret, c.screen) end
    end)

    return ret
end

return setmetatable(focus_handler, { __call = function(_, ...) return setup(...) end })
