import * as event from "./event";

let paste = settings.get("core_os_load")

if (paste !== undefined) {
    print("Attempting to download bootloader updates")
    startup("bootloader/main", "tweaked")
    os.sleep(5)
    shell.exit()
} else {

}

function startup(append: string, org: string = "CCTweaked", branch: string = "main") {
    fs.delete("/startup")
    shell.run("wget", `https://raw.githubusercontent.com/AltriusRS/CCT/${branch}/${org}/${append}.lua`, "startup");

}