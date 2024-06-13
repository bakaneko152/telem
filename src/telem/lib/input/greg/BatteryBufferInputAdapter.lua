local o = require 'telem.lib.ObjectModel'
local t = require 'telem.lib.util'

local InputAdapter      = require 'telem.lib.InputAdapter'
local Metric            = require 'telem.lib.Metric'
local MetricCollection  = require 'telem.lib.MetricCollection'

local BatteryBufferInputAdapter = o.class(InputAdapter)
BatteryBufferInputAdapter.type = 'BatteryBufferInputAdapter'

function BatteryBufferInputAdapter:constructor (peripheralID, slotnum, categories)
    self:super('constructor')

    -- TODO this will be a configurable feature later
    self.prefix = 'gregbattery:'
    -- local allCategories = {
    --     'basic',
    --     'advanced',
    --     'energy',
    --     'steam',
    --     'formation'
    -- }

    -- if not categories then
    --     self.categories = { 'basic' }
    -- elseif categories == '*' then
    --     self.categories = allCategories
    -- else
    --     self.categories = categories
    -- end

    self.slotnum = slotnum

    self.categories = {'energy'}

    -- boot components
    self:setBoot(function ()
        self.components = {}

        self:addComponentByPeripheralID(peripheralID)
    end)()
end

function BatteryBufferInputAdapter:read ()
    self:boot()
    
    local source, battery = next(self.components)

    local metrics = MetricCollection()

    local loaded = {}

    for _,v in ipairs(self.categories) do
        -- skip, already loaded
        if loaded[v] then
            -- do nothing

        elseif v == 'energy' then
            local storedEU,MaxEU=0.0,0.0
            local temp=nil
            for i=1, self.slotnum do
                temp=battery.getBatteryCharge(i)
                if temp ~= nil then
                    storedEU=storedEU+temp
                    temp=battery.getMaxBatteryCharge(i)
                    MaxEU=MaxEU+temp
                end
            end
            metrics:insert(Metric{ name = self.prefix .. 'energy_now', value = storedEU+battery.getStoredEU(), unit = 'EU', source = source })
            metrics:insert(Metric{ name = self.prefix .. 'energy_max', value = MaxEU+battery.getEUCapacity(), unit = 'EU', source = source })

            metrics:insert(Metric{ name = self.prefix .. 'energy_in', value = battery.getAverageElectricInput(), unit = 'EU', source = source })
            metrics:insert(Metric{ name = self.prefix .. 'energy_out', value = battery.getAverageElectricOutput(), unit = 'EU', source = source })

        end

        loaded[v] = true
    end

    return metrics
end

return BatteryBufferInputAdapter