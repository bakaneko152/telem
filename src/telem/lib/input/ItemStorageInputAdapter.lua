local o = require 'telem.lib.ObjectModel'
local t = require 'telem.lib.util'

local InputAdapter      = require 'telem.lib.InputAdapter'
local Metric            = require 'telem.lib.Metric'
local MetricCollection  = require 'telem.lib.MetricCollection'

local ItemStorageInputAdapter = o.class(InputAdapter)
ItemStorageInputAdapter.type = 'ItemStorageInputAdapter'

function ItemStorageInputAdapter:constructor (peripheralID,side)
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

function ItemStorageInputAdapter:read ()
    self:boot()
    
    local source, itemStorage = next(self.components)

    local storagesize = itemStorage.getInventorySize(self.inputside)
    if storagesize==nil then
        self:dlog('ItemStorageInputAdapter:read :: no inventory, retrying next cycle')
        return MetricCollection()
    end

    local tempMetrics = {}

    for i=1, storagesize do
		local item = itemStorage.getStackInSlot(self.inputside, i)
		if item ~= nil then
            local prefixkey = self.prefix .. item.name
            tempMetrics[prefixkey] = (tempMetrics[prefixkey] or 0) + item.size
		end
	end

    local metrics = MetricCollection()

    for k,v in pairs(tempMetrics) do
        if v then metrics:insert(Metric({ name = k, value = v, unit = 'item', source = source })) end
    end

    return metrics
end

return ItemStorageInputAdapter