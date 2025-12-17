local log = require("shared.log")
local toml = require("shared.toml")
local config_path = "/os/lattice.toml"





-- Begin loading drivers
local DeviceManager = require("os.kernel.device_manager")


log.info("Welcome to Lattice OS")
