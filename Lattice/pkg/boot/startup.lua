package.path = package.path .. ";/os/boot/"
print(package.path)
print(shell.exec("ls", "/os/boot"))
shell.exec("/os/boot/lboot")