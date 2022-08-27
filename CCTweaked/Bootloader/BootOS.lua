paste = settings.get("core_os_load")

print("Paste settings:", paste)

if paste ~= nil then
    print("Attempting to download bootloader updates")
    shell.run("rm", "startup")
    shell.run("pastebin", "get", "ARH6KnQn", "startup")
    os.sleep(2)
    print("Attempting to download software updates")
    shell.run("rm", "software")
    shell.run("pastebin", "get", paste, "software")
    print("Downloads finished, launching in 5 seconds")
    os.sleep(5)
    shell.run("software")

    -- Generic end-code
    os.sleep(5)
    shell.run("reboot")
else
    print("ERROR - Unable to install selected operating system.")
    print("Invalid configuration")
    print("Reloading CoreOS")
    os.sleep(5)
    shell.run("rm", "startup")
    shell.run("pastebin", "get", "Azi4cNuq", "startup")
    shell.run("reboot")
end