local o = require 'telem.lib.ObjectModel'
local t = require 'telem.lib.util'

local InputAdapter      = require 'telem.lib.InputAdapter'
local Metric            = require 'telem.lib.Metric'
local MetricCollection  = require 'telem.lib.MetricCollection'

local ItemStorageTransposerInputAdapter = o.class(InputAdapter)
ItemStorageTransposerInputAdapter.type = 'ItemStorageTransposerInputAdapter'

function ItemStorageTransposerInputAdapter:constructor (peripheralID,side)
    self:super('constructor')

    -- TODO this will be a configurable feature later
    self.prefix = 'storage:'

    self.inputside=side

    -- boot components
    self:setBoot(function ()
        self.components = {}

        self:addComponentByPeripheralID(peripheralID)
    end)()
end

function ItemStorageTransposerInputAdapter:read ()
    self:boot()
    
    local source, itemStorage = next(self.components)
    local tempMetrics = {}
    local stacksIterator = itemStorage.getAllStacks(self.inputside)
    
    for item in stacksIterator do
        if item then
            if item.name ~= nil then
                local prefixkey = self.prefix .. item.name
                local itemcount = 0
                if item.count ~= nil then
                    itemcount = item.count
                end
                tempMetrics[prefixkey] = (tempMetrics[prefixkey] or 0) + itemcount
            end
        end
    end

    local metrics = MetricCollection()

    for k,v in pairs(tempMetrics) do
        if v then metrics:insert(Metric({ name = k, value = v, unit = 'item', source = source })) end
    end

    return metrics
end

return ItemStorageTransposerInputAdapter