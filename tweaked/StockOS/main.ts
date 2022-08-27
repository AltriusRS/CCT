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

function grabItems(): any {
    let processed = [];
    let total = 0

    let entities = rs.listItems();
    for (let entity in entities) {
        processed.push({
            name: entities[entity].displayName,
            quantity: entities[entity].amount
        })
        total += entities[entity].amount
    }
    table.sort(processed, (a: any, b: any) => a.quantity > b.quantity)
    return {
        processed,
        total,
        capacity: rs.getMaxItemDiskStorage(),
        energy: {
            current: rs.getEnergyStorage(),
            max: rs.getMaxEnergyStorage()
        }
    };
}

function formatName(name: string | undefined): string {
    if (name === undefined) name = "[N/A]"
    let n = name.split("[")[1].split("]")[0];
    while (n.length < 20) {
        n = `${n} `
    }
    if (n.length > 20) n = `${n.substring(0, 17)}...`;
    return n;
}

const units = ["", "K", "M", "B"]

function formatNumber(num: number | undefined, isBar: boolean = false): string {
    if (num === undefined) num = 0;
    let x = 0;
    while (num > 1000) {
        x += 1;
        num = num / 1000
    }
    let n2 = `` + Math.round(num * 100) / 100;
    if (n2.split(".").length !== 2) {
        n2 = n2 + ".00"
    } else if (n2.split(".")[1].length !== 2) {
        n2 = `${n2.split(".")[0]}.${n2.split(".")[1]}0`
    }
    let text = `${n2}${units[x]}`;

    let required = 7;
    if (isBar) required = 5;

    while (text.length < required) {
        text = ` ${text}`
    }

    return text
}

function writeToScreen(items: any[]) {
    if (screen !== undefined) {
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
            screen.write(` ${formatNumber(items[(cursor - 2)].quantity)} | ${formatName(items[(cursor - 2)].name)}`)
            cursor += 1
        }
    }
}

function percentage(current, max): number {
    return (current / max) * 100
}

function buildBar(width: number, percentage: number, current: number, max: number, cursorY: number = 0) {
    if (width < 5) width = 5;
    let color = "D";
    if (percentage >= 75) color = "1";
    if (percentage >= 90) color = "E"

    let bar = ""
    let blit = ""
    let fblit = ""
    let colorwidth = (percentage / 100) * width;

    while (bar.length < (width - 7)) {
        if (bar.length < colorwidth) {
            blit = blit + color;
            fblit = fblit + "F"
        } else {
            blit = blit + "F"
            fblit = fblit + "0"
        }
        bar += " "
    }


    screen.setCursorPos(34, cursorY + 1)
    if (width > 6) {
        screen.write(" ")
        screen.blit(bar, fblit, blit)
    }
    screen.write(" " + formatNumber(percentage, true) + "%")
    screen.setCursorPos(34, cursorY + 2)
    screen.write(` Current: ${formatNumber(current, true)}`)
    screen.setCursorPos(34, cursorY + 3)
    screen.write(` Maximum: ${formatNumber(max, true)}`)
}

let errored = false
let lastError = 0;

function writeGraphs(data: any, itemPC: number) {
    let [w, h] = screen.getSize();
    for (let i = 2; i <= h; i++) {
        screen.setCursorPos(33, i);
        screen.write("|")
    }

    screen.setCursorPos(34, 2)
    screen.write(" Storage Capacity")
    buildBar(w - 35, itemPC, data.total, data.capacity, 2)
    screen.setCursorPos(34, 7)
    screen.write(" Energy Storage")
    buildBar(w - 35, percentage(data.energy.current, data.energy.max), data.energy.current, data.energy.max, 7)
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
    // permit app to start

    // Automatically scale the display
    let scale = 1;
    screen.setTextScale(scale);
    let [width, height] = screen.getSize();
    while (width < 35 && scale > 0.5) {
        scale = scale - 0.5
        screen.setTextScale(scale);
        let [w, h] = screen.getSize();
        print("Setting screen scale to ", scale, "New dimensions", w, h)
        width = w;
    }
    let [w, _h] = screen.getSize();
    if (scale === 0.5 && w < 35) {
        // Throw an error if the screen is not big enough
        screen.setTextScale(0.5)
        screen.setTextColor(colors.black)
        screen.setBackgroundColor(colors.red)
        screen.clear();
        screen.setCursorPos(1, 1)
        print("Screen too small")
        screen.write("Screen too small")
        playChime("error")
    } else {
        // Screen size is valid,

        if (speaker === undefined) print("Warn: A speaker is optional, but recommended");
        print("All checks passed")
        playChime("start");

        while (keepRendering) {
            let stats = grabItems()
            let itemPC = percentage(stats.total, stats.capacity);
            if (itemPC > 95 && (!errored || lastError > 15)) {
                errored = true;
                lastError = 0;
                playChime("alert")
                screen.setTextScale(2)
                screen.setBackgroundColor(colors.red)
                screen.setTextColor(colors.black)
                screen.clear();
                let [w2, h2] = screen.getSize();
                let message = "ITEM STORAGE CRITICAL"
                screen.setCursorPos((w2 - message.length) / 2, h2 / 2)
                screen.write(message);
                os.sleep(5)
                screen.setTextScale(scale)
            } else {
                lastError++
                writeToScreen(stats.processed)
                writeGraphs(stats, itemPC)

                if (itemPC > 80 && !errored) {
                    screen.setCursorPos((w - "LOW ITEM STORAGE".length) / 2, height);
                    screen.clearLine();
                    screen.setBackgroundColor(colors.orange);
                    screen.setTextColor(colors.black);
                    screen.write("LOW ITEM STORAGE")
                }
            }
            os.sleep(0.75)
        }

        sleep(2)
        playChime("stop")
    }
}

print("Unexpected end of application...")
sleep(5)