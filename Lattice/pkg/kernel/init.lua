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

-- Play a beep sound on the default speaker to indicate a successful boot
local audio = require("os.services.audio")
audio.init()
os.sleep(1)
local ok, err = audio.beep()
if not ok then
    log.error("Failed to play beep sound: " .. err)
end
