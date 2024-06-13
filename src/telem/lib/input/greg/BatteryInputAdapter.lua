local o = require 'telem.lib.ObjectModel'
local t = require 'telem.lib.util'

local InputAdapter      = require 'telem.lib.InputAdapter'
local Metric            = require 'telem.lib.Metric'
local MetricCollection  = require 'telem.lib.MetricCollection'

local BatteryInputAdapter = o.class(InputAdapter)
BatteryInputAdapter.type = 'BatteryInputAdapter'

function BatteryInputAdapter:constructor (peripheralID, slotnum, batteryvolt, categories)
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
    self.batteryvolt = batteryvolt

    self.categories = {'energy'}

    -- boot components
    self:setBoot(function ()
        self.components = {}

        self:addComponentByPeripheralID(peripheralID)
    end)()
end

function BatteryInputAdapter:read ()
    self:boot()
    
    local source, battery = next(self.components)

    local metrics = MetricCollection()

    local loaded = {}

    for _,v in ipairs(self.categories) do
        -- skip, already loaded
        if loaded[v] then
            -- do nothing

        -- minimum necessary for monitoring a fission reactor safely
        -- elseif v == 'basic' then
        --     metrics:insert(Metric{ name = self.prefix .. 'energy_filled_percentage', value = turbine.getEnergyFilledPercentage(), unit = nil, source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'energy_production_rate', value = mekanismEnergyHelper.joulesToFE(turbine.getProductionRate()), unit = 'FE/t', source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'energy_max_production', value = mekanismEnergyHelper.joulesToFE(turbine.getMaxProduction()), unit = 'FE/t', source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'steam_filled_percentage', value = turbine.getSteamFilledPercentage(), unit = nil, source = source })

        -- -- some further production metrics
        -- elseif v == 'advanced' then
        --     metrics:insert(Metric{ name = self.prefix .. 'comparator_level', value = turbine.getComparatorLevel(), unit = nil, source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'dumping_mode', value = DUMPING_MODES[turbine.getDumpingMode()], unit = nil, source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'flow_rate', value = turbine.getFlowRate() / 1000, unit = 'B/t', source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'max_flow_rate', value = turbine.getMaxFlowRate() / 1000, unit = 'B/t', source = source })

        -- elseif v == 'energy' then
        --     metrics:insert(Metric{ name = self.prefix .. 'energy', value = mekanismEnergyHelper.joulesToFE(turbine.getEnergy()), unit = 'FE', source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'max_energy', value = mekanismEnergyHelper.joulesToFE(turbine.getMaxEnergy()), unit = 'FE', source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'energy_needed', value = mekanismEnergyHelper.joulesToFE(turbine.getEnergyNeeded()), unit = 'FE', source = source })

        -- elseif v == 'steam' then
        --     metrics:insert(Metric{ name = self.prefix .. 'steam_input_rate', value = turbine.getLastSteamInputRate() / 1000, unit = 'B/t', source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'steam', value = turbine.getSteam().amount / 1000, unit = 'B', source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'steam_capacity', value = turbine.getSteamCapacity() / 1000, unit = 'B', source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'steam_needed', value = turbine.getSteamNeeded() / 1000, unit = 'B', source = source })

        -- -- measurements based on the multiblock structure itself
        -- elseif v == 'formation' then
        --     metrics:insert(Metric{ name = self.prefix .. 'formed', value = (turbine.isFormed() and 1 or 0), unit = nil, source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'height', value = turbine.getHeight(), unit = 'm', source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'length', value = turbine.getLength(), unit = 'm', source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'width', value = turbine.getWidth(), unit = 'm', source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'blades', value = turbine.getBlades(), unit = nil, source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'coils', value = turbine.getCoils(), unit = nil, source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'condensers', value = turbine.getCondensers(), unit = nil, source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'dispersers', value = turbine.getDispersers(), unit = nil, source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'vents', value = turbine.getVents(), unit = nil, source = source })
        --     metrics:insert(Metric{ name = self.prefix .. 'max_water_output', value = turbine.getMaxWaterOutput() / 1000, unit = 'B/t', source = source })
        -- end
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

return BatteryInputAdapter