import * as event from "./event";

let lines = 5;
let scale = 1;
let instrument = "bit";

// grab peripherals
let speaker: any = peripheral.find("speaker");
let screen: any = peripheral.find("monitor");
let rs: any = peripheral.find("rsBridge");

function playChime(chime: string) {
    if (speaker) {
        switch (chime) {
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
                speaker.playNote(instrument, 1, 12)
                sleep(0.25)
                speaker.playNote(instrument, 1, 1)
                break;
        }
    } else {
        print("Speaker not installed, skipping chime: ", chime)
    }
}

print("Welcome to StockOS. Please wait whilst we run initial checks")

sleep(1)

if (screen !== undefined) {
    print("Error: No screen detected, but one is required. Please install some advanced monitors.")
    playChime("error");
} else if (rs !== undefined) {
    print("Error: No RS Bridge detected, but one is required. Please install one.")
} else {
    if (speaker !== undefined) print("Warn: A speaker is optimal, but not required");
    print("All checks passed")
    print(rs)
    print(screen)
    print(speaker)
    playChime("start")
    sleep(5)
    playChime("stop")
}

print("Unexpected end of application...")
sleep(5)