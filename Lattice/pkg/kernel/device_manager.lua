-- device_manager.lua
local nanoid = require("shared.nanoid")
local log = require("shared.log")
local Registry = require("kernel.driver_registry")

local DeviceManager = {
    initialized = false,
    registry = nil,
    devices = {},
    listeners = {}
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
                id = nanoid(),
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
                id = nanoid(),
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

function DeviceManager.bind_device(device)
    local meta = DeviceManager.registry:get(device.type)

    if not meta then
        device.status = "error"
        device.error = "No driver registered for device type '" .. device.type .. "'"
        log.error(device.error)
        return
    end

    device.driver_meta = meta

    local ok, driver_def = pcall(require, meta.package)
    if not ok then
        device.status = "error"
        device.error = "Failed to load driver package '" .. meta.package .. "'"
        log.debug(device.error)
        return
    end

    local ok2, instance = pcall(driver_def.init, device.peripheral)
    if not ok2 then
        device.status = "error"
        device.error = "Driver init failed: " .. tostring(instance)
        log.trace(device.error)
        return
    end

    device.driver = instance
    device.status = "ok"

    log.trace(
        "Device '" .. device.name .. "' bound to driver '" .. meta.name .. "'"
    )
end

function DeviceManager.unbind_device(device)
    if device.driver and device.driver.shutdown then
        pcall(device.driver.shutdown)
    end

    device.driver = nil
    device.status = "detached"
end

function DeviceManager.get_devices()
    return DeviceManager.devices
end

function DeviceManager.handle_attach(name)
    log.info("Peripheral attached: " .. name)

    local ok, wrapped = pcall(peripheral.wrap, name)
    if not ok then
        log.error("Failed to wrap attached peripheral '" .. name .. "'")
        return
    end

    local device = {
        name = name,
        type = peripheral.getType(name),
        peripheral = wrapped,
        driver = nil,
        driver_meta = nil,
        status = "unbound",
        error = nil,
        warnings = {},
    }

    DeviceManager.bind_device(device)
    table.insert(DeviceManager.devices, device)

    emit("attached", device)
end

function DeviceManager.handle_detach(name)
    log.info("Peripheral detached: " .. name)

    for i, device in ipairs(DeviceManager.devices) do
        if device.name == name then
            DeviceManager.unbind_device(device)
            table.remove(DeviceManager.devices, i)
            emit("detached", device)
            return
        end
    end
end

function DeviceManager.on(event, fn)
    if not DeviceManager.listeners[event] then
        DeviceManager.listeners[event] = {}
    end
    table.insert(DeviceManager.listeners[event], fn)
end

local function emit(event, payload)
    local list = DeviceManager.listeners[event]
    if not list then return end

    for _, fn in ipairs(list) do
        pcall(fn, payload)
    end
end

return DeviceManager
