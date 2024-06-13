-- https://github.com/GTNewHorizons/Computronics/blob/master/src/main/java/pl/asie/computronics/integration/storagedrawers/DriverDrawerGroup.java

local o = require 'telem.lib.ObjectModel'
local t = require 'telem.lib.util'

local InputAdapter      = require 'telem.lib.InputAdapter'
local Metric            = require 'telem.lib.Metric'
local MetricCollection  = require 'telem.lib.MetricCollection'

local ItemStorageDrawersInputAdapter = o.class(InputAdapter)
ItemStorageDrawersInputAdapter.type = 'ItemStorageDrawersInputAdapter'

function ItemStorageDrawersInputAdapter:constructor (peripheralID)
    self:super('constructor')

    -- TODO this will be a configurable feature later
    self.prefix = 'storage:'

    -- boot components
    self:setBoot(function ()
        self.components = {}

        self:addComponentByPeripheralID(peripheralID)
    end)()
end

function ItemStorageDrawersInputAdapter:read ()
    self:boot()
    
    local source, itemStorage = next(self.components)

    local storagesize = itemStorage.getDrawerCount()
    local tempMetrics = {}

    for i=1, storagesize do
		local item_size = itemStorage.getItemCount(i)
		if item_size ~= nil then
            local prefixkey = self.prefix .. itemStorage.getItemName(i)
            tempMetrics[prefixkey] = (tempMetrics[prefixkey] or 0) + item_size
		end
	end
    
    local metrics = MetricCollection()

    for k,v in pairs(tempMetrics) do
        if v then metrics:insert(Metric({ name = k, value = v, unit = 'item', source = source })) end
    end

    return metrics
end

return ItemStorageDrawersInputAdapter