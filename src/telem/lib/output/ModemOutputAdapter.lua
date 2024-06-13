local o = require 'telem.lib.ObjectModel'
local t = require 'telem.lib.util'
local vendor
local lualzw

local OutputAdapter     = require 'telem.lib.OutputAdapter'
local MetricCollection  = require 'telem.lib.MetricCollection'
local textutils = require 'telem.lib.textutils'
local component = require('component')
local event = require ('event')
local modem = component.modem

local ModemOutputAdapter = o.class(OutputAdapter)
ModemOutputAdapter.type = 'ModemOutputAdapter'
ModemOutputAdapter.port = 41696


function ModemOutputAdapter:constructor (address)
    self:super('constructor')

    self.sendAddres=address

    self:dlog('ModemOutput:boot :: Boot complete.')

    -- boot components
    self:setBoot(function ()
        self.components = {}

        self:addComponentByPeripheralID(modem.address)

        if not vendor then
            self:dlog('ModemOutput:boot :: Loading vendor modules...')

            vendor = require 'telem.vendor'

            self:dlog('ModemOutput:boot :: Vendor modules ready.')
        end

        if not lualzw then
            self:dlog('ModemOutput:boot :: Loading lualzw...')

            lualzw = vendor.lualzw

            self:dlog('ModemOutput:boot :: lualzw ready.')
        end

        self:dlog('ModemOutput:boot :: Opening modem...')

        modem.open(self.port)

        self:dlog('ModemOutput:boot :: Boot complete.')
    end)()

    -- register async adapter
    self:setAsyncCycleHandler(function (backplane)

        self:dlog('ModemOutput:asyncCycleHandler :: Listener started')

        while true do
            -- local event, id, p2, p3 = os.pullEvent()
            -- TODO Support for using relays, meshes, etc. that change the source address
            local recv,_,fromaddr,_,_,message = event.pull(nil,"modem_message",nil,self.sendAddres,self.port,nil,nil)
            if recv ~= nil then
                if message=="act" then
                    self:dlog('ModemOutput:asyncCycleHandler :: received connection from ' .. fromaddr)
            
                    self:dlog('ModemOutput:asyncCycleHandler :: sending ack...') 
                    modem.send(self.sendAddres, self.port,"ok")
        
                    self:dlog('ModemOutput:asyncCycleHandler :: ack sent, connection ')
                    local recv,_,fromaddr,_,_,message = event.pull(nil,"modem_message",nil,self.sendAddres,self.port,nil,nil)
                    if recv~=nil then
                        self:dlog('ModemOutput:asyncCycleHandler :: received request from ' .. fromaddr)
                        if message == "GET_COLLECTION" then
                            self:dlog('ModemOutput:asyncCycleHandler :: request = GET_COLLECTION')
        
                            local payload = backplane.collection:pack()

        
                            -- use compression for payloads with > 32 metrics
                            if #payload.m > 32 then
                                self:dlog('ModemOutput:asyncCycleHandler :: compressing large payload...')
                                payload = textutils.serialize(payload, { compact = true })
                                payload = lualzw.compress(payload)
                            else
                                payload = textutils.serialize(payload, { compact = true })
                            end

                            modem.send(self.sendAddres,self.port,payload)
        
                            self:dlog('ModemOutput:asyncCycleHandler :: response sent')
                        else
                            t.log('ModemOutput: Unknown request: ' .. tostring(message))
                        end
                    end
                end
            end
        end
    end)
end

function ModemOutputAdapter:write (collection)
    self:boot()

    assert(o.instanceof(collection, MetricCollection), 'Collection must be a MetricCollection')

    -- no op, all async :)
end

return ModemOutputAdapter