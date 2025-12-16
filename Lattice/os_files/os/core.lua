local log = require("shared.log")
local hardware = require("shared.hardware_surveyor")


log.info("Detected peripherals:")

for ptype, list in pairs(hardware.by_type) do
    log.info(string.format(" - %s: %d", ptype, #list))
end

log.info("Welcome to Lattice OS")