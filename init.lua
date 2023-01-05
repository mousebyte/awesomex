local ret = {
    bind   = require("awesomex.moon.bind"),
    client = require("awesomex.client"),
    screen = require("awesomex.screen"),
    widget = require("awesomex.widget"),
    fzy    = require("awesomex.fzy_lua")
}

return setmetatable(ret, { __index = function(_, k)
    rawset(ret, k, require("awful." .. k))
    return rawget(ret, k)
end })
