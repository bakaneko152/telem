local o = require 'telem.lib.ObjectModel'
local t = require 'telem.lib.util'

local InputAdapter      = require 'telem.lib.InputAdapter'
local Metric            = require 'telem.lib.Metric'
local MetricCollection  = require 'telem.lib.MetricCollection'

local FluidStorageTransposerInputAdapter = o.class(InputAdapter)
FluidStorageTransposerInputAdapter.type = 'FluidStorageTransposerInputAdapter'

function FluidStorageTransposerInputAdapter:constructor (peripheralID,side)
    self:super('constructor')

    -- TODO this will be a configurable feature later
    self.prefix = 'fluid:'
    self.inputside = side
    -- boot components
    self:setBoot(function ()
        self.components = {}

        self:addComponentByPeripheralID(peripheralID)
    end)()
end

function FluidStorageTransposerInputAdapter:read ()
    self:boot()
    
    local source, fluidStorage = next(self.components)

    local tankcount = fluidStorage.getTankCount(self.inputside)
    local tempMetrics = {}

    for i=1, tankcount do
        local fluid = fluidStorage.getFluidInTank(self.inputside,i)
        if fluid then
            local prefixkey = self.prefix .. fluid.name
            -- tempMetrics[prefixkey] = (tempMetrics[prefixkey] or 0) + fluid.amount / 1000
            tempMetrics[prefixkey] = (tempMetrics[prefixkey] or 0) + fluid.amount
        end
	end

    local metrics = MetricCollection()

    for k,v in pairs(tempMetrics) do
        if v then metrics:insert(Metric({ name = k, value = v, unit = 'mB', source = source })) end
    end

    return metrics
end

return FluidStorageTransposerInputAdapter