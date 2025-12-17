## Drivers

All drivers in Lattice must implement the following basic contract.

```lua
return {
    id = "monitor" -- Examples: "monitor", "modem", "basicEnergyCube" <- mekanism
    name = "Generic Monitor Driver" -- The driver name is used for handling errors

    -- Initialize the driver with the peripheral handle.
    init = function(device)
        -- The "device" in this method is the result of calling `peripheral.wrap` on a peripheral.
        -- You recieve the raw peripheral handle, Lattice receives a generic driver overview.
        
        return {
            _status = "OK",
            status = function()
                return {
                    name = "Generic Monitor Driver",
                    status = "OK",
                    version = "1.0",
                    type = "monitor",
                    address = 1,
                    peripheral = "monitor"
                }
            end
        }
    end
}
```

## Driver Status

All drivers in Lattice must implement status reporting.
This means that Lattice expects the driver to be able to produce a status report.
example

```lua
local status = device.status()

print("Driver Name: " .. status.name)
print("Status: " .. status.status)
print("Version: " .. status.version)
print("Type: " .. status.type)
print("Address: " .. status.address)
print("Peripheral: " .. status.peripheral)
```

This sample code, run with the Generic Monitor Driver (monitor) would output:
```
Driver Name: Generic Monitor Driver
Status: OK
Version: 1.0
Type: monitor
Address: 1
Peripheral: monitor
```
