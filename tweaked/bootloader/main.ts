import * as events from "./event";

let paste = {
    append: settings.get("coreos.append"),
    branch: settings.get("coreos.branch"),
    org: settings.get("coreos.org")
}

if (paste.append && paste.branch && paste.org) {
    // Update bootloader
    print("Attempting to download bootloader updates")
    download("startup", "bootloader/main", "tweaked")

    // Install software
    print("Attempting to download software updates")
    download("software", paste.append, paste.org, paste.branch)
    print("Downloads finished, launching in 5 seconds")
    os.sleep(5)
    shell.run("software")

    // Use this generic ending code to exit and reboot the system
    os.sleep(5)
    os.reboot()
} else {
    print("Error, coreOS settings corrupted or invalid.")
    print("Reinstalling CoreOS and resetting device.")
    download("startup", "coreOS/CoreOS", "CCTweaked")
    os.reboot()
}

function download(path: string, append: string, org: string = "CCTweaked", branch: string = "main") {
    fs.delete(path)
    shell.run("wget", `https://raw.githubusercontent.com/AltriusRS/CCT/${branch}/${org}/${append}.lua`, path);
}