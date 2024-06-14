local o = require 'telem.lib.ObjectModel'
local t = require 'telem.lib.util'

local OutputAdapter     = require 'telem.lib.OutputAdapter'
local MetricCollection  = require 'telem.lib.MetricCollection'

local component = require("component")
local internet

local GrafanaOutputAdapter = o.class(OutputAdapter)
GrafanaOutputAdapter.type = 'GrafanaOutputAdapter'

function GrafanaOutputAdapter:constructor (endpoint, apiKey)
    self:super('constructor')
    internet = component.internet
    self.endpoint = assert(endpoint, 'Endpoint is required')
    self.apiKey = assert(apiKey, 'API key is required')
end

function GrafanaOutputAdapter:write (collection)
    assert(o.instanceof(collection, MetricCollection), 'Collection must be a MetricCollection')

    local groupmetrics = {}
    local sep = '^(.-):'
    for _,v in pairs(collection.metrics) do
        local adapterreal = (v.adapter and v.adapter ~= '' and '' .. v.adapter) or 'null'
        local sourcereal = (v.source and v.source ~= '' and '' .. v.source) or 'null'
        local unitreal = (v.unit and v.unit ~= '' and '' .. v.unit) or 'null'

        local _,_,s = v.name:find(sep)
        if s == nil then
            s = 'unknown'
        end
        if groupmetrics[s] == nil then
            groupmetrics[s]={}
        end
        local gma = groupmetrics[s]
        if gma[adapterreal] == nil then
            gma[adapterreal]={}
        end
        local gms = gma[adapterreal]
        if gms[sourcereal] == nil then
            gms[sourcereal]={}
        end
        local gmu = gms[sourcereal]
        if gmu[unitreal] == nil then
            gmu[unitreal]={}
        end
        table.insert(gmu[unitreal],v)
    end

    local outf = {}

    sep = '^.-:(.-)$'
    for prk,adt in pairs(groupmetrics) do
        local measurementname = prk
        for adk,srt in pairs(adt) do
            local adapterreal = (adk ~= 'null' and ',adapter=' .. adk) or ''
            for srk,unt in pairs(srt) do
                local sourcereal = (srk ~= 'null' and ',source=' .. srk) or ''
                for suk,vt in pairs(unt) do
                    local unitreal = (suk ~= 'null' and ',unit=' .. suk) or ''
                    local insert_str = measurementname .. unitreal .. sourcereal .. adapterreal
                    local metricstr = ''
                    for _,v in pairs(vt) do
                        local metricname = ''
                        if measurementname == 'unknown' then
                            metricname = v.name
                        elseif v.name ~= nil then
                            _,_,metricname =  v.name:find(sep)
                            if metricname == nil then
                                metricname = 'metric'
                            end
                        end
                        if metricstr=='' then
                            metricstr = ' ' .. metricname .. ('=%f'):format(v.value)
                        else
                            metricstr = metricstr .. ','.. metricname .. ('=%f'):format(v.value)
                        end
                    end
                    table.insert(outf,insert_str .. metricstr)
                end
            end
        end
    end

    -- for _,v in pairs(collection.metrics) do
    --     local unitreal = (v.unit and v.unit ~= '' and ',unit=' .. v.unit) or ''
    --     local sourcereal = (v.source and v.source ~= '' and ',source=' .. v.source) or ''
    --     local adapterreal = (v.adapter and v.adapter ~= '' and ',adapter=' .. v.adapter) or ''

    --     table.insert(outf, v.name .. unitreal .. sourcereal .. adapterreal .. (' metric=%f'):format(v.value))
    -- end

    -- t.pprint(collection)

    -- local res = http.post({
    --     url = self.endpoint,
    --     body = table.concat(outf, '\n'),
    --     headers = { Authorization = ('Bearer %s'):format(self.apiKey) }
    -- })

    local res = internet.request(
        self.endpoint,
        table.concat(outf, '\n'),
       { Authorization = ('Bearer %s'):format(self.apiKey) }
    )
    res.close()
    -- print(table.concat(outf, '\n'))
end

return GrafanaOutputAdapter