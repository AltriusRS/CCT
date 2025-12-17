-- Name: install.lua
-- Description: Installs Lattice OS using Mesh repository index
-- Author: Arthur Amos
-- License: MIT

package.path = package.path .. ";/lib/?.lua;/lib/?/init.lua"

local REPO_BASE =
"https://lattice-os.cc/pkg/"

local INDEX_URL = REPO_BASE .. "index.toml"
local INDEX_PATH = "/tmp/index.toml"

local REQUIRED_GROUPS = {
    "packages.boot",
    "packages.kernel",
    "packages.shared",
    "packages.drivers_core",
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

fs.delete("/lib")
fs.delete("/os")
fs.delete("/boot")

fs.makeDir("/lib")
fs.makeDir("/os")
fs.makeDir("/boot")
fs.makeDir("/tmp")

-- -----------------------------
-- Bootstrap downloader + toml
-- -----------------------------

local function wget(url, path)
    local ok = shell.run("wget", url, path)
    if not ok then
        error("Failed to download: " .. url)
    end
end

log("Bootstrapping core libraries")

wget(REPO_BASE .. "shared/toml.lua", "/lib/toml.lua")
wget(REPO_BASE .. "shared/sha2.lua", "/lib/sha2.lua")
wget(REPO_BASE .. "shared/downloader.lua", "/lib/downloader.lua")

local toml = require("toml")
local sha2 = require("sha2")
local downloader = require("downloader")

-- -----------------------------
-- Fetch and parse index
-- -----------------------------

log("Downloading package index")
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

local function install_packages()
    for _, group_path in ipairs(REQUIRED_GROUPS) do
        local group = resolve(index, group_path)

        if not group then
            error("Missing package group: " .. group_path)
        end

        for name, pkg in pairs(group) do
            local dest = "/" .. pkg.path
            local url = REPO_BASE .. pkg.path

            log("Installing " .. pkg.path)
            downloader.download(url, dest)

            local hash = downloader.sha256(dest)
            if hash ~= pkg.sha256 then
                error("Checksum mismatch for " .. pkg.path)
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

[boot]
entry = "/boot/lboot.lua"
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

log("Installation complete")
log("The system will reboot in 20 seconds")
os.sleep(20)
log("Goodbye!")
os.sleep(3)
os.reboot()
