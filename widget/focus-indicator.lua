--An indicator that flashes around the edges of the screen to indicate focus.
--To use, call the show() method when the screen focus changes (for example by connecting
--it to the focused_screen property change signal on screen-handler).
local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local animate = require("util.animate")


local focus_indicator = {}

local function new(args)
    local ret = wibox {
        border_width = 0, screen = args.screen,
        height = args.height or 18,
        bg = args.bg or beautiful.bg_urgent, ontop = args.ontop or false,
        visible = false, input_passthrough = true,

    }


    ret._timer = gears.timer {
        timeout = args.timeout or 0.5, single_shot = true,
        callback = function() ret.visible = false end
    }

    local f = (awful.placement.top + awful.placement.maximize_horizontally)
    f(ret, {})

    function ret:show()
        self._timer:stop()
        self.visible = true
        self._timer:start()
    end

    return ret
end

return setmetatable(focus_indicator, { __call = function(_, ...) return new(...) end })
