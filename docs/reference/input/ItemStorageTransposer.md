---
outline: deep
---

# Item Storage Transposer Input <RepoLink path="lib/input/ItemStorageTransposerInputAdapter.lua" />

```lua
telem.input.itemStorageTransposer (peripheralID: string, side: sides.side)
```

Requires **[Transposer](https://ocdoc.cil.li/block:transposer)**.
This adapter produces a metric for each item ID in an item storage peripheral (chest, etc.), with the metric name being the item ID and the value being the total number of that item in storage.

## Usage

```lua{5}
local telem = require("telem")
local sides = require("sides")

local backplane = telem.backplane()
  :addInput('my_items', telem.input.itemStorageTransposer('93bfd57c-f31e-4041-966a-e6657ff1391f',sides.south))
  :cycleEvery(1)()
```

Given a chest peripheral with the ID `minecraft:chest_2` and the following inventory:

![Minecraft inventory with 45 redstone and 8 spruce planks](/assets/inventory.png)

This appends the following metrics to the backplane:

<MetricTable
  :metrics="[
    {
      name: 'storage:minecraft:redstone',
      value: 45,
      unit: 'item',
      adapter: 'my_items',
      source: 'minecraft:chest_2'
    },
    {
      name: 'storage:minecraft:spruce_planks',
      value: 8,
      unit: 'item',
      adapter: 'my_items',
      source: 'minecraft:chest_2'
    }
  ]"
/>