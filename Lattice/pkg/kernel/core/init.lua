local log = require("shared.log")
local toml = require("shared.toml")

local RESET_SIGNAL = 10
local POWER_LIGHT = 3
local ERROR_LIGHT = 7


log.info("Starting Lattice kernel")

local device_manager = require("os.kernel.device_manager")
device_manager.init()

redstone.setAnalogOutput("front", POWER_LIGHT)

log.info("Welcome to Lattice OS")

for _, dev in ipairs(device_manager.get_devices()) do
    log.info(dev.name .. " (" .. dev.type .. "): " .. dev.status)
end

-- Initial display output
for _, dev in ipairs(device_manager.get_devices()) do
    if dev.type == "monitor" and dev.status == "ok" then
        local d = dev.driver
        d.set_scale(1)
        d.clear()
        d.write_at(2, 2, "Lattice OS")
        d.write_at(2, 4, "Display driver online")
    end
end

-- Init services
local audio = require("os.services.audio")
audio.init()

-- Boot confirmation beep
os.sleep(0.5)
local ok, err = audio.ding()
if not ok then
    log.error("Failed to play beep sound: " .. err)
end

--- Handle the attaching and detaching of peripherals.
--- This allows the kernel to react to changes in the
--- attached devices which it is trying to manage.
local function device_event_loop()
    while true do
        local event, side = os.pullEvent()

        if event == "peripheral_attach" then
            device_manager.handle_attach(side)
        elseif event == "peripheral_detach" then
            device_manager.handle_detach(side)
        end
    end
end

local debug = require("os.services.debug")
debug.init()

--- Handle redstone events.
--- This allows the kernel to trigger a hard reset when the redstone signal is high.
--- It also allows the kernel to trigger a warning light when an error is detected.
---
local function interrupt_on_redstone()
    while true do
        --- Wait for a redstone signal to trigger an interrupt
        os.pullEvent("redstone")
        local strength = redstone.getAnalogInput("front")
        if strength >= RESET_SIGNAL then
            os.reboot()
        end
    end
end

--- Begin executing the user space
parallel.waitForAny(
    interrupt_on_redstone,
    device_event_loop,
    debug.run
)

redstone.setAnalogOutput("front", ERROR_LIGHT)

log.info("Goodbye!")
