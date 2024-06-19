local o = require 'telem.lib.ObjectModel'
local t = require 'telem.lib.util'
local vendor
local lualzw

local InputAdapter      = require 'telem.lib.InputAdapter'
local Metric            = require 'telem.lib.Metric'
local MetricCollection  = require 'telem.lib.MetricCollection'
local textutils = require 'telem.lib.textutils'

local minitel

local MinitelModemInputAdapter = o.class(InputAdapter)
MinitelModemInputAdapter.type = 'MinitelModemInputAdapter'
MinitelModemInputAdapter.port = 41696

function MinitelModemInputAdapter:constructor (hostname)
    self:super('constructor')

    self.receiveHostname=hostname
    self.receiveTimeout = 1

    -- boot components
    self:setBoot(function ()
        self.components = {}

        if not vendor then
            self:dlog('MinitelModemInput:boot :: Loading vendor modules...')

            vendor = require 'telem.vendor'

            self:dlog('MinitelModemInput:boot :: Vendor modules ready.')
        end

        if not lualzw then
            self:dlog('MinitelModemInput:boot :: Loading lualzw...')

            lualzw = vendor.lualzw

            self:dlog('MinitelModemInput:boot :: lualzw ready.')
        end

        if not minitel then
            self:dlog('MinitelModemOutput:boot :: Loading minitel...')

            minitel = require("minitel")
            -- minitel.net.streamdelay = self.receiveTimeout

            self:dlog('MinitelModemOutput:boot :: minitel ready.')
        end


        self:dlog('MinitelModemInput:boot :: Boot complete.')
    end)()
end

function MinitelModemInputAdapter:read ()
    -- local _, modem = next(self.components)
    -- local peripheralName = getmetatable(modem).name

    self:dlog('MinitelModemInput:read :: sending request to ' .. self.receiveHostname)
    local socket = minitel.open(self.receiveHostname,self.port)
    if socket==nil then
        self:dlog('MinitelModemInput:read :: Connection stale, retrying next cycle')
        return MetricCollection()
    end
    socket:write("GET_COLLECTION")
    self:dlog('MinitelModemInput:read :: listening for response')
    repeat
        os.sleep(0.1)
    until socket.state == "closed"
    local message = socket:read("*a")
    socket:close()
    local unwrapped = message
    
    -- decompress if needed
    if type(message) == 'string' and string.sub(message, 1, 1) == 'c' then
        unwrapped = textutils.unserialize(lualzw.decompress(message))
    elseif type(message) == 'string' then
        unwrapped = textutils.unserialize(message)
    end
    
    local unpacked = MetricCollection.unpack(unwrapped)

    self:dlog('MinitelModemInput:read :: response received')

    return unpacked
end

return MinitelModemInputAdapter