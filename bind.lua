local abutton = require("awful.button")
local akey = require("awful.key")
local gtable = require("gears.table")
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
  return (function()
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #res do
      local k = res[_index_0]
      if modifiers[k] then
        _accum_0[_len_0] = modifiers[k]
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end)(), res[#res]
end
local parse_btn
parse_btn = function(s)
  if type(s) == "number" then
    return { }, s
  end
  local res = split(s, "-")
  return (function()
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #res do
      local k = res[_index_0]
      if modifiers[k] then
        _accum_0[_len_0] = modifiers[k]
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end)(), tonumber(res[#res])
end
local mkkey
mkkey = function(keydef, arg)
  local mods, key = parse_key(keydef)
  return akey(mods, key, arg.cb, {
    description = arg.desc,
    group = arg.group
  })
end
local mkbtn
mkbtn = function(btndef, arg)
  local mods, btn = parse_btn(btndef)
  return abutton(mods, btn, arg)
end
local keytable
keytable = function(tbl)
  return gtable.join(table.unpack((function()
    local _accum_0 = { }
    local _len_0 = 1
    for k, a in pairs(tbl) do
      _accum_0[_len_0] = mkkey(k, a)
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)()))
end
local btntable
btntable = function(tbl)
  return gtable.join(table.unpack((function()
    local _accum_0 = { }
    local _len_0 = 1
    for b, a in pairs(tbl) do
      _accum_0[_len_0] = mkbtn(b, a)
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)()))
end
return {
  mkkey = mkkey,
  keytable = keytable,
  mkbtn = mkbtn,
  btntable = btntable
}
