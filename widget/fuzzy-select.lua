local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local fuzzy_select = {}

local function make_list_item(item, v)
    local ret = wibox.widget {
        item(v),
        height = 15,
        widget = wibox.container.background
    }

    ret.value = v

    function ret:get_selected()
        if self._selected == nil then self._selected = false end
        return self._selected
    end

    function ret:set_selected(b)
        if b then self.bg = beautiful.bg_focus
        else self.bg = beautiful.bg_normal end
        self._selected = b
        self:emit_signal("property::selected", self)
    end

    return ret
end

local function new(args)
    if args.source == nil then return nil end
    local ret = awful.popup {
        widget = {
            {
                {
                    markup = '<span size="xx-large">' .. args.title .. '</span>',
                    align = 'center', valign = 'center',
                    widget = wibox.widget.textbox
                },
                {
                    markup = '<span size="x-large">filter:|</span>',
                    id = "filtertxt",
                    align = 'left', valign = 'top',
                    widget = wibox.widget.textbox
                },
                {
                    id = "itemlist",
                    spacing = 2,
                    layout = wibox.layout.fixed.vertical
                },
                id = "first",
                spacing = 2,
                spacing_widget = wibox.widget.separator,
                layout = wibox.layout.fixed.vertical
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

    ret._source = args.source
    ret._filter_fn = args.filter or function(_, _) return true end
    ret._sort = args.sort or function(_, _, _) return true end
    ret._item = args.item or function(v) return wibox.widget { text = v, widget = wibox.widget.textbox } end
    ret._grabber = awful.keygrabber {
        stop_callback = function(_, _, _, _)
            ret:hide()
        end,
        start_callback = function(_)
            ret:show()
        end,
        keypressed_callback = function(_, _, key)
            if #key == 1 then
                ret.filter = ret.filter .. key
            end
        end,
        keybindings = gears.table.join({
            { {}, 'Escape', function(self) self:stop() end },
            { {}, 'BackSpace', function(_) ret.filter = ret.filter:sub(1, -2) end },
        }, args.keybindings or {})
    }

    ret._grabber.fuzzy = ret

    ret.items = {}

    function ret:get_filter()
        if self._filter == nil then self._filter = '' end
        return self._filter
    end

    function ret:set_filter(v)
        self._filter = v
        self.widget.first.filtertxt.markup = '<span size="x-large">filter:' .. gears.string.xml_escape(v) .. '|</span>'
        self:emit_signal("property::filter", self)
    end

    function ret:get_selected_index()
        return self._selected_index
    end

    function ret:get_selected_item()
        if self._selected_index and self._selected_index <= #self.items then
            return self.widget.first.itemlist.children[self._selected_index]
        else return nil end
    end

    function ret:set_selected_index(v)
        local max = #self.items
        if max == 0 then self._selected_index = nil
        else
            if v < 1 then v = 1
            elseif v > max then v = max end
            if self.selected_item then
                self.selected_item.selected = false
            end
            self._selected_index = v
            self.selected_item.selected = true
        end
        self:emit_signal("property::selected_index", self)
    end

    function ret:update_list()
        self.widget.first.itemlist:reset()
        self.items = {}
        for _, v in ipairs(self._source(self)) do
            if self._filter_fn(self._filter, v) then
                local i = 0
                repeat
                    i = i + 1
                until self.items[i] == nil or self._sort(self._filter, v, self.items[i])
                table.insert(self.items, i, v)
                self.widget.first.itemlist:insert(i, make_list_item(self._item, v))
            end
        end
        if #self.items then
            self.selected_index = 1
        else self.selected_index = nil end
    end

    function ret:show()
        self.filter = ''
        self.visible = true
    end

    function ret:hide()
        self.widget.first.itemlist:reset()
        self.visible = false
    end

    function ret:select_next()
        if self.selected_index then
            self.selected_index = self.selected_index + 1
        end
    end

    function ret:select_previous()
        if self.selected_index then
            self.selected_index = self.selected_index - 1
        end
    end

    function ret:run()
        self._grabber:start()
    end

    ret:connect_signal("property::filter", function(w)
        w:update_list()
    end)

    return ret
end

return setmetatable(fuzzy_select, { __call = function(_, ...) return new(...) end })
