---
outline: deep
---

# Minitel Modem Output <RepoLink path="lib/output/MinitelModemOutputAdapter.lua" />

```lua
telem.output.minitel (hostname: string)
```

::: warning lib Dependencies
Requires **[Minitel](https://oc.shadowkat.net/minitel/)**.
:::

Responds to requests from [MinitelModemInputAdapter](/reference/input/Minitel) clients. Connections between computers are established over wired or wireless modems. Clients must be on the same network as this output adapter.

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

## Behavior

This adapter does not participate in scheduled cycles like other output adapters. Instead, it utilizes [`setAsyncCycleHandler()`](/reference/OutputAdapter#setasynccyclehandler) to register a coroutine that listens for connections and responds to metric requests immediately.

The collection used for responses is pulled from the `collection` property of this adapter's associated [Backplane](/reference/Backplane), which will be updated with metrics produced during scheduled cycles.