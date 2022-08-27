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
                speaker.playNote("chime", 0.5, 12)
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
    table.sort(entities, (a: any, b: any) => a.quantity > b.quantity)
    return processed;
}

function formatName(name: string): string {
    let n = name.split("[")[1].split("]")[0];
    while (n.length < 20) {
        n = `${n} `
    }
    if (n.length > 20) n = `${n.substring(0, 17)}...`;
    return n;
}

function writeToScreen(items: any[]) {
    if (screen !== undefined) {
        screen.clear();
        screen.setCursorPos(1, 1)
        let [width, height] = screen.getSize();
        screen.setBackgroundColor(colors.orange)
        screen.setTextColor(colors.black)
        screen.clearLine()
        screen.write("Stock OS - 1.0.1")
        let name = `${os.date("%a %d/%m/%y - %H:%M")}`
        screen.setCursorPos(width - name.length, 1)
        screen.write(name)
        screen.setTextColor(colors.white)
        screen.setBackgroundColor(colors.black)
        let cursor = 2;
        while (cursor <= height) {
            screen.setCursorPos(1, cursor);
            screen.clearLine()
            screen.write(`${formatName(items[cursor - 1].name)} | ${items[cursor - 1].quantity}`)
            cursor += 1
        }
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
    let scale = 5;
    screen.setTextScale(scale);
    let [width, _] = screen.getSize();
    while (width < 35 && scale > 0.5) {
        scale = scale - 0.5
        screen.setTextScale(scale);
        let [w, h] = screen.getSize();
        print("Setting screen scale to ", scale, "New dimensions", w, h)
        width = w;
    }
    let [w, _h] = screen.getSize();
    if (scale === 0.5 && w < 35) {
        screen.setTextScale(0.5)
        screen.setTextColor(colors.black)
        screen.setBackgroundColor(colors.red)
        screen.clear();
        screen.setCursorPos(1, 1)
        screen.write("Screen too small")
        playChime("error")
    } else {
        if (speaker === undefined) print("Warn: A speaker is optional, but recommended");
        print("All checks passed")
        playChime("start")

        while (keepRendering) {
            let items = grabItems()
            writeToScreen(items)
            os.sleep(0.75)
        }

        sleep(2)
        playChime("stop")
    }
}

print("Unexpected end of application...")
sleep(5)