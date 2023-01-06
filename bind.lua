local awful = require("awful")
local gtable = require("gears.table")
local naughty = require("naughty")
local modifiers = {
  ["M"] = "Mod4",
  ["A"] = "Mod1",
  ["S"] = "Shift",
  ["C"] = "Control"
}
local split
split = function(s, sep)
  sep = sep or "%s"
  local _accum_0 = { }
  local _len_0 = 1
  for m in s:gmatch(string.format("([^%s]+)", sep)) do
    _accum_0[_len_0] = m
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
local parse_key
parse_key = function(s)
  local res = split(s, "-")
  local mods = { }
  for _index_0 = 1, #res do
    local key = res[_index_0]
    if modifiers[key] then
      table.insert(mods, modifiers[key])
    else
      do
        local keygroup = key:match("<(%w+)>")
        if keygroup then
          return {
            mods = mods,
            key = nil,
            keygroup = keygroup
          }
        else
          return {
            mods = mods,
            key = key,
            keygroup = nil
          }
        end
      end
    end
  end
end
local parse_btn
parse_btn = function(s)
  if type(s) == "number" then
    return {
      mods = { },
      btn = s
    }
  end
  local res = split(s, "-")
  local mods = { }
  for _index_0 = 1, #res do
    local key = res[_index_0]
    if modifiers[key] then
      table.insert(mods, modifiers[key])
    else
      return {
        mods = mods,
        btn = tonumber(key)
      }
    end
  end
end
local mkkey
mkkey = function(keydef, arg)
  local mods = { }
  local key, keygroup
  do
    local _obj_0 = parse_key(keydef)
    mods, key, keygroup = _obj_0.mods, _obj_0.key, _obj_0.keygroup
  end
  local cb, desc, group
  cb, desc, group = arg.cb, arg.desc, arg.group
  if keygroup then
    return awful.key({
      keygroup = keygroup,
      modifiers = mods,
      on_press = cb,
      description = desc,
      group = group
    })
  else
    return awful.key(mods, key, cb, {
      description = desc,
      group = group
    })
  end
end
local mkbtn
mkbtn = function(btndef, arg)
  local mods, btn
  do
    local _obj_0 = parse_btn(btndef)
    mods, btn = _obj_0.mods, _obj_0.btn
  end
  return awful.button(mods, btn, arg)
end
local keytable
keytable = function(tbl)
  local res = { }
  for keydef, arg in pairs(tbl) do
    res = gtable.join(res, mkkey(keydef, arg))
  end
  return res
end
local btntable
btntable = function(tbl)
  local res = { }
  for btndef, arg in pairs(tbl) do
    res = gtable.join(res, mkbtn(btndef, arg))
  end
  return res
end
return {
  mkkey = mkkey,
  keytable = keytable,
  mkbtn = mkbtn,
  btntable = btntable
}
