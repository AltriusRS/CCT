package.path = package.path .. ";/os/boot/"
print(package.path)
print(shell.run("ls", "/os/boot"))
shell.run("/os/boot/lboot")