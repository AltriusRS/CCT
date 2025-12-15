-- Name: install.lua
-- Description: Installs the bootloader for the ATM-OS
-- Author: AltriusRS
-- License: MIT
-- Last Updated: 2025-12-15


local debug = false




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
local asset_base = "https://raw.githubusercontent.com/AltriusRS/CCT/refs/heads/main/Lattice/pkg"
local log_file = "/boot/install.log"
local os_directory = "/os"
local library_directory = "/lib"

-- Logging Settings
local scrollback = {}
local scrollback_max = 1

local monitor = nil
local speaker = nil
local monitor_size = { w = 1, h = 1 }


local function redraw_monitor()
    if not monitor then return end

    monitor.clear()

    local start = math.max(1, #scrollback - scrollback_max + 1)
    local line = 1

    for i = start, #scrollback do
        monitor.setCursorPos(1, line)
        monitor.write(scrollback[i])
        line = line + 1
    end
end

local function log(message)
    local os_time = textutils.formatTime(os.time())
    local str = "[" .. os_time .. "] " .. tostring(message)

    print(str)

    if monitor then
        table.insert(scrollback, str)

        -- Trim scrollback
        if #scrollback > scrollback_max then
            table.remove(scrollback, 1)
        end

        redraw_monitor()
    end
    os.sleep(1)
end

-- Basic downloader function. Does not validate anything.
local function basic_dl(mod)
    local full_path = asset_base .. mod .. ".lua"
    local disk_path = library_directory .. "/" .. mod .. ".lua"

    local ok, result = pcall(shell.run, "wget", full_path, disk_path)

    if not ok then
        -- Lua-level error
        log("Lua error while downloading " .. mod .. ": " .. tostring(result))
        shell.exit(1)
    end

    if not result then
        -- wget ran but failed
        log("wget failed while downloading " .. mod)
        shell.exit(1)
    end

    if debug then
        log("DBG: Fetched " .. mod)
    end
end


log("Checking available devices")

local names = peripheral.getNames()

for id, name in ipairs(names) do
    local p_type = peripheral.getType(name)
    log("> " .. id .. ": " .. name .. " - " .. p_type)

    if p_type == "speaker" and speaker == nil then
        speaker = peripheral.wrap(name)
    elseif p_type == "monitor" and monitor == nil then
        monitor = peripheral.wrap(name)
    end
end

if monitor then
    local w, h = monitor.getSize()
    monitor_size.w = w
    monitor_size.h = h

    scrollback_max = h - 1

    monitor.setTextScale(0.5) -- optional but nice
    monitor.clear()
    monitor.setCursorPos(1, 1)

    log("Monitor detected (" .. w .. "x" .. h .. ")")
end

if speaker then
    speaker.playNote("chime")
end

log("Starting installation")

-- Delete existing files (This allows for clean updates)
fs.delete(os_directory)
fs.delete(library_directory)

-- Recreate required directories
fs.makeDir(os_directory)
fs.makeDir(library_directory)

log("> Installing bootstrapper dependencies")

log("> - Downloader")
basic_dl("shared/downloader")

log("> - Sha2")
basic_dl("shared/sha2")

local DOWNLOADER = require("lib/shared/downloader")


-- log(DOWNLOADER.sha256("/lib/shared/downloader"))


-- -- Install dependencies

-- for dep_id, dep_name in ipairs(bootloader.manifest.dependencies) do
--     print("(" .. dep_id .. " / " .. #bootloader.manifest.dependencies .. ") Installing dependency: " .. dep_name)
--     -- TODO: Implement dependency installation logic
-- end




-- -- Download initial bootload manifest
-- TOML = require("shared/toml")
-- DOWNLOADER = require("shared/downloader")

-- -- Download initial bootload manifest
-- local manifest_url = "https://example.com/manifest.toml"
-- local manifest_path = "/boot/manifest.toml"

-- print("Downloading initial bootload manifest")
-- DOWNLOADER.download(manifest_url, manifest_path)

-- -- Parse manifest
-- local manifest = TOML.parse_file(manifest_path)

-- -- Install bootloader
-- print("Installing bootloader")
-- -- TODO: Implement bootloader installation logic
