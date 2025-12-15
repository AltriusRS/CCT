-- Name: install.lua
-- Description: Installs the bootloader for the ATM-OS
-- Author: AltriusRS
-- License: MIT
-- Last Updated: 2025-12-15

function log(message)
    local utc_time = textutils.formatTime(os.time())
    print("[" .. utc_time .. "] " .. message)
end

local asset_base = "https://raw.githubusercontent.com/AltriusRS/CCT/refs/heads/main/ATM-10/"
local log_file = "/boot/install.log"
local os_directory = "/os"
local library_directory = "/lib"


log("Starting installation")
log("> Installing bootstrapper dependencies")


fs.delete(os_directory)
fs.delete(library_directory)

fs.makeDir(os_directory)
fs.makeDir(library_directory)



print("Downloading shared libraries")



local bootloader = {
    name = "ATM-10",
    version = "1.0.0",
    author = "AltriusRS",
    license = "MIT",
    lastUpdated = "2025-12-15",
    manifest = {
        dependencies = {
            "shared/sha2",
            "shared/toml",
            "shared/log",
            "shared/downloader"
        }
    }
}

-- Install dependencies

for dep_id, dep_name in ipairs(bootloader.manifest.dependencies) do
    print("(" .. dep_id .. " / " .. #bootloader.manifest.dependencies .. ") Installing dependency: " .. dep_name)
    -- TODO: Implement dependency installation logic
end




-- Download initial bootload manifest
TOML = require("shared/toml")
DOWNLOADER = require("shared/downloader")

-- Download initial bootload manifest
local manifest_url = "https://example.com/manifest.toml"
local manifest_path = "/boot/manifest.toml"

print("Downloading initial bootload manifest")
DOWNLOADER.download(manifest_url, manifest_path)

-- Parse manifest
local manifest = TOML.parse_file(manifest_path)

-- Install bootloader
print("Installing bootloader")
-- TODO: Implement bootloader installation logic
