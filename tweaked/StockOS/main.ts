import * as event from "./event";
import * as pretty from "cc.pretty";

let instrument = "bit";

// grab peripherals
// @ts-ignore
const speaker: SpeakerPeripheral = peripheral.find("speaker")[0];
// @ts-ignore
const screen: MonitorPeripheral = peripheral.find("monitor")[0];
const rs: any = peripheral.find("rsBridge")[0];

function playChime(chime: string) {
    if (speaker !== undefined) {
        switch (chime) {
            case "process":
                speaker.playNote("chime", 0.1, 12)
                break;
            case "start":
                speaker.playNote(instrument, 1, 1)
                sleep(0.25)
                speaker.playNote(instrument, 1, 12)
                break;
            case "stop":
                speaker.playNote(instrument, 1, 12)
                sleep(0.25)
                speaker.playNote(instrument, 1, 1)
                break;
            case "error":
                speaker.playNote(instrument, 3, 3)
                sleep(0.25)
                speaker.playNote(instrument, 3, 3)
                break;
            case "alert":
                let passes = 0;
                while (passes < 10) {
                    speaker.playNote(instrument, 3, 8)
                    sleep(0.25)
                    speaker.playNote(instrument, 3, 8)
                    sleep(0.25)
                    passes += 1
                }

                break;
        }
    } else {
        print("Speaker not installed, skipping chime: ", chime)
        print(speaker)
    }
}

function grabItems(): any[] {
    let processed = [];

    let entities = rs.listItems();
    for (let entity in entities) {
        screen.clear()
        processed.push({
            name: entities[entity].displayName,
            quantity: entities[entity].amount
        })
    }

    return processed;
}

function writeToScreen(items: any[]) {
    if (screen !== undefined) {
        screen.clear();
        screen.setCursorPos(1, 1)
        let [width, height] = screen.getSize();
        screen.write(`This display is: ${width} by ${height}`)
    }
}

print("Welcome to StockOS. Please wait whilst we run initial checks")

sleep(1)

let keepRendering = true;

if (screen === undefined) {
    print("Error: No screen detected, but one is required. Please install some advanced monitors.")
    playChime("error");
} else if (rs === undefined) {
    print("Error: No RS Bridge detected, but one is required. Please install one.")
    playChime("error");
} else {
    screen.setTextScale(1)
    if (speaker === undefined) print("Warn: A speaker is optional, but recommended");
    print("All checks passed")
    playChime("start")

    while (keepRendering) {
        playChime("process")
        let items = grabItems()
        writeToScreen(items)
        os.sleep(1)
    }

    sleep(2)
    playChime("stop")
}

print("Unexpected end of application...")
sleep(5)