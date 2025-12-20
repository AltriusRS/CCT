-- Simple install.lua (The one on the website)
package.path = package.path .. ";/bin/?.lua;/bin/?/?.lua"
if fs.exists("/bin/mesh.lua") then
    print("Deleting old mesh.lua...")
    fs.delete("/bin/mesh.lua")
    os.sleep(1)
end
shell.run("wget", "https://lattice-os.cc/pkg/api/main/package/bin/mesh/mesh.lua", "/bin/mesh.lua")
os.sleep(1)
shell.run("/bin/mesh.lua", "bootstrap")

os.sleep(1)

print("\n--- Lattice Network Configuration ---")
write("Enter Grid SSID: ")
local ssid = read()

write("Enter Grid Secret Key (leave blank for random): ")
local key = read("*") -- '*' hides the input
if key == "" then
    -- Reuse your nanoid logic or a simple random string
    key = "lat_" .. math.random(100000, 999999)
end

print("Writing network configuration...")
local net_cfg = string.format([[
[network]
ssid = "%s"
key = "%s"
channel = 4242
]], ssid, key)

local f = fs.open("/os/network.toml", "w")
f.write(net_cfg)
f.close()

print("Network configured for Grid: " .. ssid)

os.sleep(10)
os.reboot()
