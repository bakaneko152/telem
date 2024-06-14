---
outline: deep
---

# Applied Energistics ME Storage Input <RepoLink path="lib/input/MEStorageInputAdapter.lua" />

```lua
telem.input.meStorage (peripheralID: string)
```

::: warning Mod Dependencies
Requires **Applied Energistics 2**.
:::

This adapter produces a metric for each item and fluid ID in an ME storage network, with the metric names being the IDs, and the value being the total amount of that item/fluid in storage.  
Need [ME Controller](https://appliedenergistics.org/ae2-site-archive/ME-Controller/index.html) or [
ME Interface](https://appliedenergistics.org/ae2-site-archive/ME-Interface/index.html).

~~Items that are craftable but not stored are not included in the metrics.~~

## Usage

```lua{4}
local telem = require('telem')

local backplane = telem.backplane()
  :addInput('my_me', telem.input.meStorage('meBridge_0'))
  :cycleEvery(1)()
```

Given an ME Bridge peripheral with the ID `meBridge_0` attached to an ME storage network with the following items and fluids:

![Applied Energistics ME Terminal inventory](/assets/me-inventory.webp)

This appends the following metrics to the backplane:

<MetricTable
  :metrics="[
    {
      name: 'storage:minecraft:lava',
      value: 2925,
      unit: 'mB',
      adapter: 'my_me',
      source: 'meBridge_0'
    },
    {
      name: 'storage:minecraft:oak_planks',
      value: 3,
      unit: 'item',
      adapter: 'my_me',
      source: 'meBridge_0'
    },
    {
      name: 'storage:minecraft:redstone',
      value: 1408,
      unit: 'item',
      adapter: 'my_me',
      source: 'meBridge_0'
    }
  ]"
/>