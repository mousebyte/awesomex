local ret = {
    action_box = require("awesomex.widget.action-box"),
    focus_indicator = require("awesomex.widget.focus-indicator"),
    fuzzy_select = require("awesomex.widget.fuzzy-select")
}

return setmetatable(ret, { __index = function(_, k)
    rawset(ret, k, require("awful.widget." .. k))
    return rawget(ret, k)
end })
