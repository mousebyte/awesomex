# AwesomeX
AwesomeX is a drop-in extension module for `awful` providing new features, widgets, and quality of life improvements.

This project is in the early stages of development and breaking changes are possible down the line.

## Getting Started
To install AwesomeX, clone the repository into your awesome configuration directory.
```bash
cd ~/.config/awesome
git clone https://github.com/mousebyte/awesomex
```
Then, in your runtime configuration, replace `awful` with `awesomex`.
```lua
local awful = require("awesomex")
```

That's it! Restart awesome to make sure everything is working properly. Any references to unmodified components will be
automatically forwarded to the stock `awful` module using the `__index` metamethod.

## Extended Modules
The behavior of some modules has been extended.

### Screen
The [`screen`](https://awesomewm.org/doc/api/classes/screen.html) module has been extended with a signal emitted when the
focused screen changes. The signal will fire in the following situations:
* When the focused screen changes via a call to [`awful.screen.focus`](https://awesomewm.org/doc/api/classes/screen.html#awful.screen.focus),
  [`awful.screen.focus_bydirection`](https://awesomewm.org/doc/api/classes/screen.html#awful.screen.focus_bydirection), or
  [`awful.screen.focus_relative`](https://awesomewm.org/doc/api/classes/screen.html#awful.screen.focus_relative).
* When a client on a different screen emits the [`focus`](https://awesomewm.org/doc/api/classes/client.html#client.focus) signal.
* When the focused client's [`screen`](https://awesomewm.org/doc/api/classes/client.html#client.screen) property changes.

You can connect to the signal per-screen:
```lua
local scr = screen[1]
scr:connect_signal("focused", function(s) do_stuff(s) end)
```

or globally across all screens:
```lua
screen.connect_signal("focused", function(s) do_stuff(s) end)
```

## Widgets
AwesomeX provides several new widgets, located in `awful.widget` as per usual.

### Focus Indicator
The focus indicator widget flashes over a screen's wibar (or any other widget) when that screen gains focus.
It uses the new focus signal internally. Setup is simple and should work out of the box. assuming you have your
wibars stored on your `screen` objects:
```lua
for s in screen do
    s.focus_indicator = awful.widget.focus_indicator { wibar = s.mywibar }
end
```

The background color of the widget defaults to `beautiful.bg_urgent`, this can be overridden with the `bg` argument.
I recommend setting your compositor to animate opacity changes for the best effect.

### Fuzzy Search Dialog
The fuzzy select widget provides a customizable fuzzy search dialog supporting custom data sources, filter and sorting functions,
and list-item generation. Here's an example of how to create a dialog that allows you to select and focus any client.
```lua
local client_jumper = awful.widget.fuzzy_select { 
    title = 'Focus Client',
    --function to return a table of items
    source = client.get
    --function to filter items, should return true if filter matches item v
    filter = function(filter, v)
        return awful.fzy.has_match(filter, v.name)
    end,
    --function to sort items, should return true if item a goes before item b
    sort = function(filter, a, b)
        return awful.fzy.score(filter, a.name) > awful.fzy.score(filter, b.name)
    end,
    --function to create a widget representing item v
    item = function(v)
        return wibox.widget {
            markup = '<span size="large">'..gears.string.xml_escape(v.name)..'</span>',
            widget = wibox.widget.textbox
        }
    end,
    --table of additional keybindings for the widget's keygrabber. self.fuzzy is a reference
    --to client_jumper.
    keybindings = {
        {{'Control'}, 'j', function(self) self.fuzzy:select_next() end },
        {{'Control'}, 'k', function(self) self.fuzzy:select_previous() end },
        {{}, 'Return', function(self)
            self.fuzzy.selected_item.value:jump_to(false)
            self:stop()
        end}
    }
}

-- Run the widget:
client_jumper.screen = awful.screen.focused()
client_jumper:run()
```
