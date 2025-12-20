-- Simple install.lua (The one on the website)
package.path = package.path .. ";/bin/?.lua;/bin/?/?.lua"
shell.run("wget", "https://lattice-os.cc/pkg/api/main/package/bin/mesh/mesh.lua", "/bin/mesh.lua")
shell.run("/bin/mesh.lua", "bootstrap")
os.reboot()
