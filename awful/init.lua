-- wraps the `awful` library module to provide extended features and
-- quality of life improvements.
local ret = {
    screen = require("awesome-util.awful.screen")
}

return setmetatable(ret, { __index = function(_, k)
    rawset(ret, k, require("awful." .. k))
    return rawget(ret, k)
end })
