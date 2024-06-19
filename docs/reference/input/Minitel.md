---
outline: deep
---

# Minitel Input <RepoLink path="lib/input/MinitelModemInputAdapter.lua" />

```lua
telem.input.minitel (hostname: string)
```

::: warning lib Dependencies
Requires **[Minitel](https://oc.shadowkat.net/minitel/)**.
:::

This adapter requests metrics from a specified in-game network address running a [MinitelModemOutputAdapter](/reference/output/Minitel). Connections between computers are established over wired or wireless modems. The target address must be on the same network as this input adapter.

## Usage

::: code-group

```lua{9} [Computer 1: Transmitter]
local thread = require("thread")
local telem = require("telem")

-- Transmitter address: "COM1"
-- Receiver address: "COM2"

local backplane = telem.backplane():debug(true)
  :addInput('custom_short', telem.input.custom(function ()
    return { custom_short_1 = 929, custom_short_2 = 424.2 }
  end))
  :addOutput('modem_out', telem.output.minitel('COM2'))

local thread_table = telem.util.list2thread(backplane:cycleEvery(10))
thread.waitForAny(thread_table)
```

```lua{4} [Computer 2: Receiver]
local telem = require("telem")

-- Transmitter address: "COM1"
-- Receiver address: "COM2"

local backplane = telem.backplane():debug(true)
  :addInput('modem_in', telem.input.minitel('COM1'))
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