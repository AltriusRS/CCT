-- Simple install.lua (The one on the website)
shell.run("wget", "https://lattice-os.cc/pkg/api/package/bin/mesh.lua", "/bin/mesh.lua")
shell.run("/bin/mesh.lua", "bootstrap")
os.reboot()
