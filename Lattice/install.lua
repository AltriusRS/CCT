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
os.sleep(10)
os.reboot()
