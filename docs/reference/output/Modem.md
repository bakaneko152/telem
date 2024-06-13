---
outline: deep
---

# Modem Output <RepoLink path="lib/output/ModemOutputAdapter.lua" />

```lua
telem.output.modem (address: string)
```

Responds to requests from [ModemInputAdapter](/reference/input/Modem) clients. Connections between computers are established over wired or wireless modems. Clients must be on the same network as this output adapter.

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

## Behavior

This adapter does not participate in scheduled cycles like other output adapters. Instead, it utilizes [`setAsyncCycleHandler()`](/reference/OutputAdapter#setasynccyclehandler) to register a coroutine that listens for connections and responds to metric requests immediately.

The collection used for responses is pulled from the `collection` property of this adapter's associated [Backplane](/reference/Backplane), which will be updated with metrics produced during scheduled cycles.