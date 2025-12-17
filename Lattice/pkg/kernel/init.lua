local log = require("shared.log")
local toml = require("shared.toml")

log.info("Starting Lattice kernel")

local registry_path = "/os/drivers/registry.toml"
if not fs.exists(registry_path) then
    log.error("Driver registry not found: " .. registry_path)
    return
end

local device_manager = require("os.kernel.device_manager")
device_manager.init(registry_path)

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
local ok, err = audio.beep()
if not ok then
    log.error("Failed to play beep sound: " .. err)
end


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

parallel.waitForAny(
    device_event_loop,
    debug.run
)
