-- https://github.com/GTNewHorizons/OpenComputers/blob/master/src/main/scala/li/cil/oc/integration/appeng/NetworkControl.scala
-- https://github.com/PoroCoco/myaenetwork/blob/main/web.lua
local o = require 'telem.lib.ObjectModel'
local t = require 'telem.lib.util'

local InputAdapter      = require 'telem.lib.InputAdapter'
local Metric            = require 'telem.lib.Metric'
local MetricCollection  = require 'telem.lib.MetricCollection'

local MEStorageInputAdapter = o.class(InputAdapter)
MEStorageInputAdapter.type = 'MEStorageInputAdapter'

function AE_get_items(me)
    local isModpackGTNH, storedItems = pcall(me.allItems) --tries the allItems method only available on the GTNH modpack.
    if isModpackGTNH then
        return storedItems
    else
        return me.getItemsInNetwork()
    end
end

function MEStorageInputAdapter:constructor (peripheralID)
    self:super('constructor')

    -- TODO this will be a configurable feature later
    self.prefix = 'aestorage:'

    -- boot components
    self:setBoot(function ()
        self.components = {}

        self:addComponentByPeripheralID(peripheralID)
    end)()
end

function MEStorageInputAdapter:read ()
    self:boot()
    
    local source, storage = next(self.components)
    local items = AE_get_items(storage)
    local fluids = storage.getFluidsInNetwork()

    local metrics = MetricCollection()

    for _,v in pairs(items) do
        if v then metrics:insert(Metric({ name = self.prefix .. v.name, value = v.amount, unit = 'item', source = source })) end
    end

    for _,v in pairs(fluids) do
        if v then metrics:insert(Metric({ name = self.prefix .. v.name, value = v.amount, unit = 'mB', source = source })) end
    end

    return metrics
end

return MEStorageInputAdapter