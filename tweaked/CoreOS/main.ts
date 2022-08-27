import * as events from "./event";

const apps = [
    {
        name: "GlassOS",
        info: `Glass OS is a HUD overlay built using the Advanced Peripherals AR Goggles + AR Controller
It displays information about your connected ME terminals, Refined Storage systems, and Energy Detectors!
Optionally, it also shows information from a selection of plugins

Required Blocks
- 1x Advanced Computer
- 1x AR Controller

Optional Blocks
- 1x Wired Modem (needed for plugin connection)
- 1x Advanced Peripherals ME Bridge
- 1x Advanced Peripherals RS Bridge
- 1x Advanced Peripherals Energy Detector
`,
        version: "1.0.0",
        download: {
            append: "GlassOS/GlassOS",
            branch: "main",
            org: "CCTweaked"
        }
    },
    {
        name: "ReactorOS",
        info: "Smart control algorithms for Mekanism Fission + Fusion reactors, as well as a basic attempt at a Draconic Reactor control algorithm",
        version: "1.0.0",
        download: {
            append: "ReactorOS/ReactorOS",
            branch: "main",
            org: "CCTweaked"
        }
    },
    {
        name: "StockOS",
        info: "Stock OS is an integration for Refined Storage which makes use of large monitors to show current stock levels of the most numerous items in your system.",
        version: "1.0.0",
        download: {
            append: "StockOS/StockOS",
            branch: "main",
            org: "CCTweaked"
        }
    }
]
let looping = true;

while (looping) {
    let event = events.pullEvent("key");
    print(event.get_args().keys());
    // let key = event['key']
    // if (key === keys.up) {
    //     print("Up")
    looping = false;
    // } else {
    //     print(key)
    // }

}

print("CoreOS Exited with an unknown error")