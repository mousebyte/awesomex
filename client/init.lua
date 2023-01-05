local ret = {
    focus = require("awesomex.client.focus")
}

return setmetatable(ret, { __index = function(_, k)
    local client = require("awful.client")
    rawset(ret, k, client[k])
    return rawget(ret, k)
end })
