--An indicator that flashes around the edges of the screen to indicate focus.
--To use, call the show() method when the screen focus changes (for example by connecting
--it to the focused_screen property change signal on screen-handler).
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")


local focus_indicator = {}

local function new(args)
    local s = args.screen or args.wibar and args.wibar.screen
    local ret = wibox {
        border_width = 0, screen = s,
        bg = args.bg or beautiful.bg_urgent, ontop = args.ontop or false,
        visible = false, input_passthrough = true,
    }

    ret:geometry(args.wibar and args.wibar:geometry() or
        { width = args.width or 5, height = args.height or 5,
            x = args.x or 0, y = args.y or 0 })


    local timer = gears.timer {
        timeout = args.timeout or 0.5, single_shot = true,
        callback = function() ret.visible = false end
    }

    function ret:show()
        timer:stop()
        self.visible = true
        timer:start()
    end

    function ret:hide()
        timer:stop()
        self.visible = false
    end

    if s then
        s:connect_signal("focused", function(_) ret:show() end)
    end

    return ret
end

return setmetatable(focus_indicator, { __call = function(_, ...) return new(...) end })
