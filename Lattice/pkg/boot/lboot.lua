-- Lattice OS boot entrypoint
-- Stage-1 bootstrap

package.path = package.path .. ";/lib/?.lua;/lib/?/init.lua"

local function println(msg)
    print("[LATTICE] " .. msg)
end

println("Booting Lattice OS")

-- Load system manifest
local ok, toml = pcall(require, "shared/toml")
if not ok then
    println("Failed to load TOML library")
    println("Reason: "..toml)
    return
end

print(toml)

local cfg = toml.parse_file("/os/lattice.toml")

println("Node role: " .. (cfg.node and cfg.node.role or "unknown"))
println("Boot complete")