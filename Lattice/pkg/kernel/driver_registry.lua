local toml = require("shared.toml")

local Registry = {}

Registry.__index = Registry

function Registry.load(path)
    if not fs.exists(path) then
        error("Driver registry not found: " .. path)
    end

    local data = toml.parse_file(path)

    if not data.drivers then
        error("Driver registry is missing drivers table")
    end

    return setmetatable({
        drivers = data.drivers
    }, Registry)
end

function Registry:get(device_type)
    return self.drivers[device_type]
end

return Registry
