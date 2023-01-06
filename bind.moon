abutton = require "awful.button"
akey = require "awful.key"
gtable = require "gears.table"

modifiers =
    "M": "Mod4"
    "A": "Mod1"
    "S": "Shift"
    "C": "Control"

split = (s, sep)->
    sep = sep or "%s"
    [m for m in s\gmatch string.format "([^%s]+)", sep]

parse_key = (s)->
    res = split s, "-"
    [modifiers[k] for k in *res when modifiers[k]], res[#res]


parse_btn = (s)->
    if type(s) == "number" then return {}, s
    res = split s, "-"
    [modifiers[k] for k in *res when modifiers[k]], tonumber res[#res]


mkkey = (keydef, arg)->
    mods, key = parse_key keydef
    akey mods, key, arg.cb, description: arg.desc, group: arg.group

mkbtn = (btndef, arg)->
    mods, btn = parse_btn btndef
    abutton mods, btn, arg


keytable = (tbl)-> gtable.join table.unpack [mkkey k, a for k, a in pairs tbl]

btntable = (tbl)-> gtable.join table.unpack [mkbtn b, a for b, a in pairs tbl]

return {:mkkey, :keytable, :mkbtn, :btntable}
