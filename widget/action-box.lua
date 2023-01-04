local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local action_box = {}

local function new(args)
    local ret = awful.popup {
        widget = {
            {
                id = "kdtxt",
                markup = '<span size="xx-large">λ: </span>',
                align = 'center', valign = 'center',
                widget = wibox.widget.textbox
            },
            margins = 10,
            widget = wibox.container.margin
        },
        visible = false, ontop = true,
        screen = "primary", border_width = 2,
        border_color = beautiful.border_focus,
        placement = awful.placement.centered,
        shape = gears.shape.rounded_rect,
    }

    ret.map = args.map
    ret.actions = args.actions

    ret._action_str = ''

    local function parse(map, actions, str)
        local parsed, count = { verbs = '', adjectives = '', nouns = '' }, ''
        for i = 1, #str do
            local char = str:sub(i, i)
            if char >= '0' and char <= '9' then
                count = count .. char
            else
                for kind in pairs(parsed) do
                    parsed[kind] = map[kind][char] or parsed[kind]
                end
            end
        end

        actions[parsed.nouns](tonumber(count) or 1, parsed.adjectives, parsed.verbs)
    end

    local function update_contents(w)
        w.widget.kdtxt.markup = '<span size="xx-large">λ: ' .. w._action_str .. '</span>'
        if w.map.verbs[w._action_str:sub(-1)] then parse(w.map, w.actions, w._action_str) end
    end

    ret._timer = gears.timer {
        timeout = 0.3, single_shot = true,
        callback = function()
            ret.visible = false
            ret._action_str = ''
            update_contents(ret)
        end
    }

    function ret:hide()
        self._timer:start()
    end

    function ret:try_add_key(key)
        local lastkey = self._action_str:sub(-1)
        local lastkey_num = tonumber(lastkey) ~= nil
        if (self.map.nouns[lastkey] and self.map.verbs[key]) or self.map.nouns[key] or
            ((lastkey == '' or lastkey_num) and
                (tonumber(key) or self.map.adjectives[key])) then
            self._action_str = self._action_str .. key
            update_contents(self)
        end
    end

    function ret:delete_key()
        self._action_str = self._action_str:sub(1, -2)
        update_contents(self)
    end

    return ret

end

return setmetatable(action_box, { __call = function(_, ...) return new(...) end })
