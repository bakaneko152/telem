local o = require 'telem.lib.ObjectModel'
local t = require 'telem.lib.util'
local component = require("component")

local OutputAdapter = o.class()
OutputAdapter.type = 'OutputAdapter'

function OutputAdapter:constructor()
    assert(self.type ~= OutputAdapter.type, 'OutputAdapter cannot be instantiated')

    self.debugState = false

    self.asyncCycleHandler = nil

    self.isCacheable = false

    -- boot components
    self:setBoot(function ()
        self.components = {}
    end)()
end

function OutputAdapter:setBoot(proc)
    assert(type(proc) == 'function', 'proc must be a function')

    self.boot = proc

    return self.boot
end

function OutputAdapter:setAsyncCycleHandler(proc)
    assert(type(proc) == 'function', 'proc must be a function')
    
    self.asyncCycleHandler = proc

    return self.asyncCycleHandler
end

function OutputAdapter:addComponentByPeripheralID (id)
    local tempComponent = component.proxy(id)

    assert(tempComponent, 'Could not find peripheral ID ' .. id)

    self.components[id] = tempComponent
end

function OutputAdapter:addComponentByPeripheralType (type)
    local key = type .. '_' .. #{self.components}

    -- local tempComponent = component.find(type)
    local tempComponent = {}
    for address, _ in component.list(type, false) do
        table.insert(tempComponent, component.proxy(address))
    end
    if next(tempComponent) == nil then
        tempComponent=nil
     end

    assert(tempComponent, 'Could not find peripheral type ' .. type)

    self.components[key] = tempComponent
end

function OutputAdapter:cacheable ()
    self.isCacheable = true
end

function OutputAdapter:getState ()
    t.err(self.type .. ' has not implemented getState()')
end

function OutputAdapter:loadState (state)
    t.err(self.type .. ' has not implemented loadState()')
end

function OutputAdapter:write (metrics)
    t.err(self.type .. ' has not implemented write()')
end

function OutputAdapter:debug(debug)
    self.debugState = debug and true or false

    return self
end

function OutputAdapter:dlog(msg)
    if self.debugState then t.log(msg) end
end

return OutputAdapter