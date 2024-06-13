-- https://oc.cil.li/topic/564-download-from-computercraft-app-store/
-- bakaneko imp
local textutils = {}
-- local expect = require 'telem.lib.expect'
-- local expect, field = expect.expect, expect.field
local expect,field = require('telem.vendor').expect.expect, require('telem.vendor').expect.field


local g_tLuaKeywords = {
    [ "and" ] = true,
    [ "break" ] = true,
    [ "do" ] = true,
    [ "else" ] = true,
    [ "elseif" ] = true,
    [ "end" ] = true,
    [ "false" ] = true,
    [ "for" ] = true,
    [ "function" ] = true,
    [ "if" ] = true,
    [ "in" ] = true,
    [ "local" ] = true,
    [ "nil" ] = true,
    [ "not" ] = true,
    [ "or" ] = true,
    [ "repeat" ] = true,
    [ "return" ] = true,
    [ "then" ] = true,
    [ "true" ] = true,
    [ "until" ] = true,
    [ "while" ] = true,
}

local function serializeImpl( t, tTracking,  indent, opts)
    local sType = type(t)
    if sType == "table" then
        if tTracking[t] ~= nil then
            error( "Cannot serialize table with recursive entries", 0 )
        end
        tTracking[t] = true

        if next(t) == nil then
            -- Empty tables are simple
            return "{}"
        else
            -- Other tables take more work
            local open, sub_indent, open_key, close_key, equal, comma = "{\n", indent .. "  ", "[ ", " ] = ", " = ", ",\n"
            if opts.compact then
                open, sub_indent, open_key, close_key, equal, comma = "{", "", "[", "]=", "=", ","
            end
            local sResult = open
            -- local sSubIndent = indent .. "  "
            local tSeen = {}
            for k,v in ipairs(t) do
                tSeen[k] = true
                sResult = sResult .. sub_indent .. serializeImpl( v, tTracking, sub_indent, opts) .. comma
            end
            for k,v in pairs(t) do
                if not tSeen[k] then
                    local sEntry
                    if type(k) == "string" and not g_tLuaKeywords[k] and string.match( k, "^[%a_][%a%d_]*$" ) then
                        sEntry = k .. equal .. serializeImpl( v, tTracking, sub_indent, opts) .. comma
                    else
                        sEntry = open_key .. serializeImpl( k, tTracking, sub_indent, opts) .. close_key .. serializeImpl( v, tTracking, sub_indent, opts) .. comma
                    end
                    sResult = sResult .. sub_indent .. sEntry
                end
            end
            sResult = sResult .. sub_indent .. "}"
            if opts.allow_repetitions then
                tTracking[t] = nil
            else
                tTracking[t] = false
            end
            return sResult
        end
        
    elseif sType == "string" then
        return string.format( "%q", t )
    
    elseif sType == "number" or sType == "boolean" or sType == "nil" then
        return tostring(t)
        
    else
        error( "Cannot serialize type "..sType, 0 )
        
    end
end

EMPTY_ARRAY = {}

local function serializeJSONImpl( t, tTracking )
    local sType = type(t)
    if t == EMPTY_ARRAY then
        return "[]"

    elseif sType == "table" then
        if tTracking[t] ~= nil then
            error( "Cannot serialize table with recursive entries", 0 )
        end
        tTracking[t] = true

        if next(t) == nil then
            -- Empty tables are simple
            return "{}"
        else
            -- Other tables take more work
            local sObjectResult = "{"
            local sArrayResult = "["
            local nObjectSize = 0
            local nArraySize = 0
            for k,v in pairs(t) do
                if type(k) == "string" then
                    local sEntry = serializeJSONImpl( k, tTracking ) .. ":" .. serializeJSONImpl( v, tTracking )
                    if nObjectSize == 0 then
                        sObjectResult = sObjectResult .. sEntry
                    else
                        sObjectResult = sObjectResult .. "," .. sEntry
                    end
                    nObjectSize = nObjectSize + 1
                end
            end
            for n,v in ipairs(t) do
                local sEntry = serializeJSONImpl( v, tTracking )
                if nArraySize == 0 then
                    sArrayResult = sArrayResult .. sEntry
                else
                    sArrayResult = sArrayResult .. "," .. sEntry
                end
                nArraySize = nArraySize + 1
            end
            sObjectResult = sObjectResult .. "}"
            sArrayResult = sArrayResult .. "]"
            if nObjectSize > 0 or nArraySize == 0 then
                return sObjectResult
            else
                return sArrayResult
            end
        end

    elseif sType == "string" then
        return string.format( "%q", t )

    elseif sType == "number" or sType == "boolean" then
        return tostring(t)

    else
        error( "Cannot serialize type "..sType, 0 )

    end
end

function textutils.serialize( t, opts)
    local tTracking = {}
    expect(2, opts, "table", "nil")

    if opts then
        field(opts, "compact", "boolean", "nil")
        field(opts, "allow_repetitions", "boolean", "nil")
    else
        opts = {}
    end
    return serializeImpl( t, tTracking, "", opts )
end

function textutils.unserialize( s )
    local func = load( "return "..s, "unserialize" )
    if func then
        local ok, result = pcall( func )
        if ok then
            return result
        end
    end
    return nil
end

function textutils.serializeJSON( t )
    local tTracking = {}
    return serializeJSONImpl( t, tTracking )
end

function textutils.urlEncode( str )
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w ])", function(c)
            return string.format("%%%02X", string.byte(c))
        end )
        str = string.gsub(str, " ", "+")
    end
    return str    
end

-- GB versions
serialise = serialize
unserialise = unserialize
serialiseJSON = serializeJSON

return textutils