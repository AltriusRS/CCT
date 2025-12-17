-- device_manager.lua

local log = require("shared.log")
local Registry = require("kernel.driver_registry")

local DeviceManager = {
    initialized = false,
    registry = nil,
    devices = {},
}

function DeviceManager.init(registry_path)
    if DeviceManager.initialized then
        log.trace("Device manager already initialized")
        return
    end

    log.trace("Initializing device manager")

    DeviceManager.registry = Registry.load(registry_path)
    DeviceManager.devices = {}

    DeviceManager.scan()
    DeviceManager.bind()

    DeviceManager.initialized = true
    log.trace("Device manager initialized")
end

function DeviceManager.scan()
    log.trace("Scanning for peripherals")
    DeviceManager.devices = {}

    for _, name in ipairs(peripheral.getNames()) do
        local ok, wrapped = pcall(peripheral.wrap, name)

        if not ok then
            log.error("Failed to wrap peripheral '" .. name .. "': " .. wrapped)
            table.insert(DeviceManager.devices, {
                name = name,
                type = "unknown",
                peripheral = nil,
                driver = nil,
                driver_meta = nil,
                status = "error",
                error = "Failed to wrap peripheral",
                warnings = {},
            })
        else
            log.debug("Wrapped peripheral '" .. name .. "'")
            table.insert(DeviceManager.devices, {
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

    log.trace("Devices scanned")
end

function DeviceManager.bind()
    log.trace("Binding devices")

    for _, device in ipairs(DeviceManager.devices) do
        local meta = DeviceManager.registry:get(device.type)

        if not meta then
            device.status = "error"
            device.error =
                "No driver registered for device type '" .. device.type .. "'"
            log.error(device.error)
            goto continue
        end

        device.driver_meta = meta

        local ok, driver_def = pcall(require, meta.package)
        if not ok then
            device.status = "error"
            device.error =
                "Failed to load driver package '" .. meta.package .. "'"
            log.debug(device.error)
            goto continue
        end

        local ok2, instance = pcall(driver_def.init, device.peripheral)
        if not ok2 then
            device.status = "error"
            device.error = "Driver init failed: " .. tostring(instance)
            log.trace(device.error)
            goto continue
        end

        device.driver = instance
        device.status = "ok"
        log.trace(
            "Device '" ..
            device.name ..
            "' bound to driver '" ..
            meta.name ..
            "'"
        )

        ::continue::
    end

    log.trace("Devices bound")
end

function DeviceManager.get_devices()
    return DeviceManager.devices
end

return DeviceManager
