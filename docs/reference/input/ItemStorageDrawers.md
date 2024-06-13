---
outline: deep
---

# Item Storage Drawers Input <RepoLink path="lib/input/ItemStorageDrawersInputAdapter.lua" />

```lua
telem.input.itemStorageDrawers  (peripheralID: string)
```

Requires **[Computronics](https://github.com/GTNewHorizons/Computronics)**.
Requires **[StorageDrawers](https://github.com/GTNewHorizons/StorageDrawers)**.

## Usage

```lua{5}
local telem = require("telem")
local sides = require("sides")

local backplane = telem.backplane()
  :addInput('my_items', telem.input.itemStorageDrawers('18701ac1-803d-40c0-b620-067416369348'))
  :cycleEvery(1)()
```
