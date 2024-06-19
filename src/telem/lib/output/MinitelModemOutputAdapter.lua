local o = require 'telem.lib.ObjectModel'
local t = require 'telem.lib.util'
local vendor
local lualzw

local OutputAdapter     = require 'telem.lib.OutputAdapter'
local MetricCollection  = require 'telem.lib.MetricCollection'
local textutils = require 'telem.lib.textutils'
local minitel

local MinitelModemOutputAdapter = o.class(OutputAdapter)
MinitelModemOutputAdapter.type = 'MinitelModemOutputAdapter'
MinitelModemOutputAdapter.port = 41696


function MinitelModemOutputAdapter:constructor (hostname)
    self:super('constructor')

    self.toHostname=hostname

    self:dlog('MinitelModemOutput:boot :: Boot complete.')

    -- boot components
    self:setBoot(function ()
        self.components = {}

        if not vendor then
            self:dlog('MinitelModemOutput:boot :: Loading vendor modules...')

            vendor = require 'telem.vendor'

            self:dlog('MinitelModemOutput:boot :: Vendor modules ready.')
        end

        if not lualzw then
            self:dlog('MinitelModemOutput:boot :: Loading lualzw...')

            lualzw = vendor.lualzw

            self:dlog('MinitelModemOutput:boot :: lualzw ready.')
        end

        if not minitel then
            self:dlog('MinitelModemOutput:boot :: Loading minitel...')

            minitel = require("minitel")

            self:dlog('MinitelModemOutput:boot :: minitel ready.')
        end

        self:dlog('MinitelModemOutput:boot :: Boot complete.')
    end)()

    -- register async adapter
    self:setAsyncCycleHandler(function (backplane)

        self:dlog('MinitelModemOutput:asyncCycleHandler :: Listener started')

        while true do
            local socket = minitel.listen(self.port)
            self:dlog('MinitelModemOutput:asyncCycleHandler :: received connection from ' .. socket.addr)
            if socket.addr ~= self.toHostname then
                self:dlog('MinitelModemOutput:asyncCycleHandler :: wrong addr')
                socket:close()
            else
                local message = ""
                repeat
                    message = socket:read("*a")
                    os.sleep(0.1)
                until message ~= "" or socket.state == "closed"
                self:dlog('MinitelModemOutput:asyncCycleHandler :: received request from ' .. socket.addr)
                if message == "GET_COLLECTION" then
                    self:dlog('MinitelModemOutput:asyncCycleHandler :: request = GET_COLLECTION')

                    local payload = backplane.collection:pack()


                    -- use compression for payloads with > 8 metrics
                    if #payload.m > 8 then
                        self:dlog('MinitelModemOutput:asyncCycleHandler :: compressing large payload...')
                        payload = textutils.serialize(payload, { compact = true })
                        payload = lualzw.compress(payload)
                    else
                        payload = textutils.serialize(payload, { compact = true })
                    end

                    socket:write(payload)

                    self:dlog('MinitelModemOutput:asyncCycleHandler :: response sent')
                else
                    t.log('MinitelModemOutput: Unknown request: ' .. tostring(message))
                end

                socket:close()
            end
        end
    end)
end

function MinitelModemOutputAdapter:write (collection)
    self:boot()

    assert(o.instanceof(collection, MetricCollection), 'Collection must be a MetricCollection')

    -- no op, all async :)
end

return MinitelModemOutputAdapter