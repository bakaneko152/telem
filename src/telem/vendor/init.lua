-- Telem Vendor Loader by cyberbit
-- MIT License
-- Version 0.7.0
-- Submodules are copyright of their respective authors. For licensing, see https://github.com/cyberbit/telem/blob/main/LICENSE

if package.path:find('telem/vendor') == nil then package.path = package.path .. ';lib/telem/vendor/?;lib/telem/vendor/?.lua;lib/telem/vendor/?/init.lua' end

local lualzw = require 'lualzw'
local fluent = require 'fluent'

local expect = require 'expect'

return {
    lualzw = lualzw,
    fluent = fluent,
    expect = expect
}