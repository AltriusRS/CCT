-- Import core dependencies
local log = require("shared.log")
local Registry = require("kernel.driver_registry")

local DeviceManager = {}

DeviceManager.__index = DeviceManager

function DeviceManager.new(registry_path)
    local self = setmetatable({}, DeviceManager)

    self.registry = Registry.load(registry_path)
    self.devices = {}

    return self
end

function DeviceManager:scan()
    self.devices = {}

    for _, name in ipairs(peripheral.getNames()) do
        local ok, wrapped = pcall(peripheral.wrap, name)
        if not ok then
            -- extremely rare, but defensive
            table.insert(self.devices, {
                name = name,
                type = "unknown",
                peripheral = nil,
                status = "error",
                error = "Failed to wrap peripheral",
                warnings = {},
            })
        else
            table.insert(self.devices, {
                name = name,
                type = peripheral.getType(name),
                peripheral = wrapped,

                driver = nil,
                driver_meta = nil,

                status = "unbound",
                error = nil,
                warnings = {},
            })
        end
    end
end

function DeviceManager:bind()
    for _, device in ipairs(self.devices) do
        local meta = self.registry:get(device.type)

        if not meta then
            device.status = "error"
            device.error =
                "No driver registered for device type '" .. device.type .. "'"
            goto continue
        end

        device.driver_meta = meta

        -- Attempt to load driver module
        local ok, driver_def = pcall(require, meta.package)
        if not ok then
            device.status = "error"
            device.error =
                "Failed to load driver package '" .. meta.package .. "'"
            goto continue
        end

        -- Attempt to initialise driver
        local ok2, instance = pcall(driver_def.init, device.peripheral)
        if not ok2 then
            device.status = "error"
            device.error =
                "Driver init failed: " .. tostring(instance)
            goto continue
        end

        device.driver = instance
        device.status = "ok"

        ::continue::
    end
end

function DeviceManager:init()
    self:scan()
    self:bind()
end

return DeviceManager
