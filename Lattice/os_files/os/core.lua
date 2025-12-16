local log = require("shared.log")
local hardware = require("os.boot.hardware_surveyor")


log.info("Detected peripherals:")

for ptype, list in pairs(hardware.by_type) do
    log.info(string.format(" - %s: %d", ptype, #list))
end