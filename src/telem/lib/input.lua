return {
    helloWorld = require 'telem.lib.input.HelloWorldInputAdapter',
    custom = require 'telem.lib.input.CustomInputAdapter',

    -- storage
    itemStorage = require 'telem.lib.input.ItemStorageInputAdapter',
    --fluidStorage = require 'telem.lib.input.FluidStorageInputAdapter',
    itemStorageTransposer  = require 'telem.lib.input.ItemStorageTransposerInputAdapter',
    itemStorageDrawers = require 'telem.lib.input.ItemStorageDrawersInputAdapter',
    fluidStorageTransposer = require 'telem.lib.input.FluidStorageTransposerInputAdapter',
    meStorage = require 'telem.lib.input.MEStorageInputAdapter',

    -- machinery
    greg = {
        batteryBuffer = require 'telem.lib.input.greg.BatteryBufferInputAdapter',
    },

    -- modem
    modem = require 'telem.lib.input.ModemInputAdapter',
    minitel = require 'telem.lib.input.MinitelModemInputAdapter'
}