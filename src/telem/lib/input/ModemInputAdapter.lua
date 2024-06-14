local o = require 'telem.lib.ObjectModel'
local t = require 'telem.lib.util'
local vendor
local lualzw

local InputAdapter      = require 'telem.lib.InputAdapter'
local Metric            = require 'telem.lib.Metric'
local MetricCollection  = require 'telem.lib.MetricCollection'
local textutils = require 'telem.lib.textutils'

local component = require('component')
local event = require ('event')
local modem

local ModemInputAdapter = o.class(InputAdapter)
ModemInputAdapter.type = 'ModemInputAdapter'
ModemInputAdapter.port = 41696

function ModemInputAdapter:constructor (address)
    self:super('constructor')
    modem =  component.modem

    self.inputAddress = address
    self.receiveTimeout = 1

    -- boot components
    self:setBoot(function ()
        self.components = {}

        self:addComponentByPeripheralID(modem.address)

        if not vendor then
            self:dlog('ModemInput:boot :: Loading vendor modules...')

            vendor = require 'telem.vendor'

            self:dlog('ModemInput:boot :: Vendor modules ready.')
        end

        if not lualzw then
            self:dlog('ModemInput:boot :: Loading lualzw...')

            lualzw = vendor.lualzw

            self:dlog('ModemInput:boot :: lualzw ready.')
        end

        self:dlog('ModemInput:boot :: Opening modem...')

        modem.open(self.port)

        self:dlog('ModemInput:boot :: Boot complete.')
    end)()
end

function ModemInputAdapter:read ()
    -- local _, modem = next(self.components)
    -- local peripheralName = getmetatable(modem).name

    self:dlog('ModemInput:read :: sending request to ' .. self.inputAddress)
    -- TODO Support for using relays, meshes, etc. that change the source address

    modem.send(self.inputAddress,self.port,"act")
    local recv,_,_,_,_,_ = event.pull(self.receiveTimeout,"modem_message",nil,self.inputAddress,self.port,nil,"ok")

    if recv==nil then
        self:dlog('ModemInput:read :: Connection stale, retrying next cycle')
        return MetricCollection()
    end

    modem.send(self.inputAddress,self.port,"GET_COLLECTION")

    self:dlog('ModemInput:read :: listening for response')
    local recv,_,fromaddr,_,distance,message = event.pull(self.receiveTimeout,"modem_message",nil,self.inputAddress,self.port,nil,nil)

    if recv==nil then
        t.log('ModemInput:read :: Receive timed out after ' .. self.receiveTimeout .. ' seconds, retrying next cycle')
        return MetricCollection()
    end

    local unwrapped = message
    
    -- decompress if needed
    if type(message) == 'string' and string.sub(message, 1, 1) == 'c' then
        unwrapped = textutils.unserialize(lualzw.decompress(message))
    elseif type(message) == 'string' then
        unwrapped = textutils.unserialize(message)
    end
    
    local unpacked = MetricCollection.unpack(unwrapped)

    self:dlog('ModemInput:read :: response received')

    return unpacked
end

return ModemInputAdapter