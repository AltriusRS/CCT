-- Name: install.lua
-- Description: Installs the bootloader for the ATM-OS
-- Author: AltriusRS
-- License: MIT
-- Last Updated: 2025-12-15

package.path = package.path .. ";/lib/?.lua;/lib/?/init.lua"

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
local asset_base = "https://raw.githubusercontent.com/AltriusRS/CCT/refs/heads/main/Lattice/pkg/"
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


local function write_lattice_manifest()
    local contents = [[
[system]
name = "Lattice"
version = "0.1.0"
codename = "Scaffold"

[node]
role = "controller"

[boot]
entry = "/boot/init.lua"

[dependencies]
shared = ["sha2", "toml", "downloader", "log"]

[ui]
monitor = true
speaker = true
]]

    local f = fs.open(os_directory .. "/lattice.toml", "w")
    f.write(contents)
    f.close()
end


local function write_repo_config()
    local contents = [[
[repository]
base = "https://raw.githubusercontent.com/AltriusRS/CCT/main/Lattice/pkg"
index = "index.toml"
]]

    local f = fs.open(os_directory .. "/repo.toml", "w")
    f.write(contents)
    f.close()
end

local function install_bootloader()
    local remote = asset_base .. "boot/init.lua"
    local local_path = "/boot/init.lua"

    local ok, result = pcall(shell.run, "wget", remote, local_path)

    if not ok then
        log("Lua error while downloading bootloader: " .. tostring(result))
        shell.exit(1)
    end

    if not result then
        log("Failed to download bootloader")
        shell.exit(1)
    end

    log("> Bootloader installed")
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

log("> Installing core dependencies")

for _, dep in ipairs(bootloader.manifest.dependencies) do
    log("> - " .. dep)
    basic_dl(dep)
end

log("> Writing lattice.toml")
write_lattice_manifest()

log("> Writing repo configuration")
write_repo_config()

log("> Installing bootloader")
install_bootloader()

log("Installation complete")
log("Lattice OS scaffold installed")

if speaker then
    speaker.playNote("pling")
end

log("You may now reboot")