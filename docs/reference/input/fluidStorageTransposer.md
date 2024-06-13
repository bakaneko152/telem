---
outline: deep
---

# Fluid Storage Transposer Input <RepoLink path="lib/input/FluidStorageTransposerInputAdapter.lua" />

```lua
telem.input.fluidStorageTransposer (peripheralID: string, side: sides.side)
```
Requires **[Transposer](https://ocdoc.cil.li/block:transposer)**.
This adapter produces a metric for each fluid ID in a fluid storage peripheral (tank, drum, etc.), with the metric name being the fluid ID and the value being the total amount of that fluid in storage.

## Usage

```lua{4}
local telem = require 'telem'
local sides = require("sides")

local backplane = telem.backplane()
  :addInput('my_fluid', telem.input.fluidStorageTransposer('93bfd57c-f31e-4041-966a-e6657ff1391f',sides.north))
  :cycleEvery(1)()
```

Given a fluid storage peripheral with the ID `functionalstorage:fluid_2` and the following tanks:

![Functional Storage Fluid Drawer (1x2) with 11 B of lava and 6 B of water](/assets/tanks.png)

This appends the following metrics to the backplane:

<MetricTable
  :metrics="[
    {
      name: 'storage:minecraft:lava',
      value: 11000,
      unit: 'mB',
      adapter: 'my_fluid',
      source: 'functionalstorage:fluid_2'
    },
    {
      name: 'storage:minecraft:water',
      value: 6000,
      unit: 'mB',
      adapter: 'my_fluid',
      source: 'functionalstorage:fluid_2'
    }
  ]"
/>