# Telem - Trivial Extract and Load Engine for Minecraft


It's a modified telem to work with OpenComputers that I use on my private server that I play with my friends.

Limited features available.


Tired of creating complex logic to monitor inventory or production? Want something more modern, modular, and scalable? Want something that can empower a dashboard like the screenshot below? You have come to the right place.

![image](https://github.com/cyberbit/telem/assets/7350183/22e0862b-a56e-4ec5-ac9d-956c7aa075bb)

## Requirements
- OpenComputers(I use the GTNH environment)
- Internet Card for installer/Grafana

## Install
```
pastebin run -f paUSHQQC bakaneko152 telem master src/telem
mkdir /home/lib
mv /telem /home/lib/telem
```

## Usage
### Please visit [url](https://bakaneko152.github.io/telem/) for full documentation.
```lua
local telem = require('telem')

local backplane = telem.backplane()                  -- setup the fluent interface
  :addInput('hello_in', telem.input.helloWorld(123)) -- add a named input
  :addOutput('hello_out', telem.output.helloWorld()) -- add a named output

-- call a function that reads all inputs and writes all outputs, then waits 3 seconds, repeating indefinitely
backplane:cycleEvery(3)()

-- threadable option
local thread = require("thread")
local othercode = function ()
    while true do
        -- listen for events, control your reactor, etc.

        -- make sure to yield somewhere in your loop or the backplane will not cycle correctly
        os.sleep()
    end
end

-- cycleEvery() may return multiple functions
local thread_table =  telem.util.list2thread(backplane:cycleEvery(3))
table.insert(thread_table, thread.create(othercode))
thread.waitForAny(thread_table)
```

## Input Adapters
* Item and Fluid Storage
* Modded Storage (AE2,Storage Drawers)
* Modded Machines (Greg5(GTNH))
* Custom Inputs
* Modem
* _More to come!_

## Output Adapters
* Custom Outputs
* Modem
* Grafana (advanced)
* _More to come!_
