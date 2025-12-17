-- Name: install.lua
-- Description: Installs Lattice OS using Mesh repository index
-- Author: Arthur Amos
-- License: MIT

package.path = package.path .. ";/lib/?.lua;/lib/?/init.lua"

local REPO_BASE =
"https://lattice-os.cc/pkg/api/package/"

local INDEX_URL = REPO_BASE .. "index.toml"
local INDEX_PATH = "/tmp/index.toml"

local REQUIRED_GROUPS = {
    "packages.boot",
    "packages.kernel",
    "packages.shared",
    "packages.drivers_core",
}

local INSTALL_ROOTS = {
    ["packages.shared"] = "/lib",
    ["packages.kernel"] = "/os/kernel",
    ["packages.boot"] = "/os/boot",
    ["packages.drivers_core"] = "/os/drivers/core",
}

-- -----------------------------
-- Logging (minimal, no UI fluff)
-- -----------------------------

local function log(msg)
    print("[INSTALL] " .. msg)
end

-- -----------------------------
-- Bootstrap dirs
-- -----------------------------

-- TODO: Implement directory purging

-- -----------------------------
-- Bootstrap downloader + toml
-- -----------------------------

local function wget(url, path)
    log("Downloading " .. url)
    local ok = shell.run("wget", url, path)
    if not ok then
        error("Failed to download: " .. url)
    end
end

log("Bootstrapping core libraries")

wget(REPO_BASE .. "shared/toml.lua", "/lib/shared/toml.lua")
wget(REPO_BASE .. "shared/sha2.lua", "/lib/shared/sha2.lua")
wget(REPO_BASE .. "shared/log.lua", "/lib/shared/log.lua")
wget(REPO_BASE .. "shared/downloader.lua", "/lib/shared/downloader.lua")

local toml = require("shared.toml")
local downloader = require("shared.downloader")

-- -----------------------------
-- Fetch and parse index
-- -----------------------------

log("Downloading package index")
fs.delete(INDEX_PATH) -- Delete the existing index file
wget(INDEX_URL, INDEX_PATH)

local index = toml.parse_file(INDEX_PATH)

-- -----------------------------
-- Helper: resolve dotted path
-- -----------------------------

local function resolve(tbl, path)
    for key in string.gmatch(path, "[^%.]+") do
        tbl = tbl[key]
        if not tbl then
            return nil
        end
    end
    return tbl
end

-- -----------------------------
-- Install packages
-- -----------------------------

local function ensure_directory(path)
    if not fs.exists(path) then
        fs.makeDir(path)
    end
end

local function install_packages()
    for _, group_path in ipairs(REQUIRED_GROUPS) do
        local group = resolve(index, group_path)
        if not group then
            error("Missing package group: " .. group_path)
        end

        local root = INSTALL_ROOTS[group_path]
        if not root then
            error("No install root for " .. group_path)
        end

        ensure_directory(root)

        for _, pkg in pairs(group) do
            local filename = fs.getName(pkg.path)
            local dest = root .. "/" .. filename
            local url = REPO_BASE .. pkg.path

            log("Installing " .. pkg.path .. " -> " .. dest)

            downloader.download(url, dest)

            local hash = downloader.sha256(dest)
            if hash ~= pkg.sha256 then
                error(
                    "Checksum mismatch for " ..
                    pkg.path ..
                    " (expected " .. pkg.sha256 .. ", got " .. hash .. ")"
                )
            end
        end
    end
end

install_packages()

-- -----------------------------
-- Write lattice.toml
-- -----------------------------

log("Writing lattice.toml")

local lattice_cfg = [[
[system]
name = "Lattice"
version = "0.1.0"
codename = "Scaffold"

[node]
role = "controller"
]]

local f = fs.open("/os/lattice.toml", "w")
f.write(lattice_cfg)
f.close()

-- -----------------------------
-- Write repo.toml
-- -----------------------------

log("Writing repo.toml")

local repo_cfg = [[
[repository]
base = "https://raw.githubusercontent.com/AltriusRS/CCT/main/Lattice/pkg"
index = "index.toml"
]]

local f2 = fs.open("/os/repo.toml", "w")
f2.write(repo_cfg)
f2.close()

-- -----------------------------
-- Install startup.lua
-- -----------------------------

log("Installing startup.lua")
wget(REPO_BASE .. "boot/startup.lua", "/startup.lua")
local TIMEOUT = 5
log("Installation complete")
log("The system will reboot in " .. TIMEOUT .. " seconds")
os.sleep(TIMEOUT)
log("Goodbye!")
os.sleep(1.4)
os.reboot()
