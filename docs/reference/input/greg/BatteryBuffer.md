# Greg Battery Buffer Input <RepoLink path="lib/input/greg/BatteryBufferInputAdapter.lua" />

```lua
telem.input.greg.batteryBuffer (
	peripheralID: string, 
	slotnum: number,
	categories?: string[] | '*'
)
```

::: warning Mod Dependencies
Requires **Greg5** and **[Computronics](https://github.com/GTNewHorizons/Computronics)**.
:::

Requires **[Transposer](https://ocdoc.cil.li/block:transposer)**.
This adapter produces a metric for most of the available information from a [BatteryBuffer](https://gtnh.miraheze.org/wiki/Battery_Buffer) Adapter. ~~By default, the metrics are limited to an opinionated basic list, but this can be expanded with the `categories` parameter at initialization. The default `basic` category provides all the information needed to monitor the power supply.~~


## Usage

```lua{4}
local telem = require 'telem'

local backplane = telem.backplane()
	:addInput('my_battery', telem.input.greg.batteryBuffer('a81a9f51-838f-4d49-9489-e4e418aa9da4',16))
	:cycleEvery(5)()
```