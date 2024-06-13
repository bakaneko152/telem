---
outline: deep
---

# Modem Input <RepoLink path="lib/input/ModemInputAdapter.lua" />

```lua
telem.input.modem (address: string)
```

This adapter requests metrics from a specified in-game network address running a [ModemOutputAdapter](/reference/output/Modem). Connections between computers are established over wired or wireless modems. The target address must be on the same network as this input adapter.

## Usage

::: code-group

```lua{9} [Computer 1: Transmitter]
local thread = require("thread")
local telem = require("telem")

-- Transmitter address: "1b8f0cc5-c3c1-4746-8183-2175d9cc94f7"
-- Receiver address: "45d7f9a2-d81e-4891-a758-ad5337c6dde4"

local backplane = telem.backplane():debug(true)
  :addInput('custom_short', telem.input.custom(function ()
    return { custom_short_1 = 929, custom_short_2 = 424.2 }
  end))
  :addOutput('modem_out', telem.output.modem('45d7f9a2-d81e-4891-a758-ad5337c6dde4'))

local thread_table = telem.util.list2thread(backplane:cycleEvery(10))
thread.waitForAny(thread_table)
```

```lua{4} [Computer 2: Receiver]
local telem = require("telem")

-- Transmitter address: "1b8f0cc5-c3c1-4746-8183-2175d9cc94f7"
-- Receiver address: "45d7f9a2-d81e-4891-a758-ad5337c6dde4"

local backplane = telem.backplane():debug(true)
  :addInput('modem_in', telem.input.modem('1b8f0cc5-c3c1-4746-8183-2175d9cc94f7'))
  :cycleEvery(10)()

```

:::


<MetricTable
  show-heritage
  :metrics="[
    {
      name: 'custom_short_1',
      value: 929,
      unit: 'bars',
      adapter: 'modem_in:custom_in',
      source: 'custom_source_1'
    },
    {
      name: 'custom_long_2',
      value: 424.2,
      adapter: 'modem_in:custom_in',
      source: 'custom_source_2'
    }
  ]"
/>