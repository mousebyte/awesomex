awful = require "awful"
gtable = require "gears.table"
naughty = require "naughty"

modifiers =
    "M": "Mod4"
    "A": "Mod1"
    "S": "Shift"
    "C": "Control"

split = (s, sep)->
    sep = sep or "%s"
    return [m for m in s\gmatch string.format "([^%s]+)", sep]

parse_key = (s)->
    res = split s, "-"
    mods = {}
    for key in *res
        if modifiers[key] then table.insert mods, modifiers[key]
        else if keygroup = key\match "<(%w+)>" then return :mods, key: nil, :keygroup
        else return :mods, :key, keygroup: nil


parse_btn = (s)->
    if type(s) == "number" then return mods: {}, btn: s
    res = split s, "-"
    mods = {}
    for key in *res
        if modifiers[key] then table.insert mods, modifiers[key]
        else return :mods, btn: tonumber key


mkkey = (keydef, arg)->
    mods = {}
    {:mods, :key, :keygroup} = parse_key keydef
    {:cb, :desc, :group} = arg
    if keygroup
        return awful.key {
            keygroup: keygroup
            modifiers: mods
            on_press: cb
            description: desc
            group: group
        }
    else return awful.key(mods, key, cb, { description: desc, group: group })

mkbtn = (btndef, arg)->
    {:mods, :btn} = parse_btn btndef
    return awful.button(mods, btn, arg)


keytable = (tbl)->
    res = {}
    for keydef, arg in pairs tbl
        res = gtable.join res, mkkey keydef, arg
    return res

btntable = (tbl)->
    res = {}
    for btndef, arg in pairs tbl
        res = gtable.join res, mkbtn btndef, arg
    return res

return {:mkkey, :keytable, :mkbtn, :btntable}
