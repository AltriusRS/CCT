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

if (!screen) {
    print("Error: No screen detected, but one is required. Please install some advanced monitors.")
    playChime("error");
} else if (!rs) {
    print("Error: No RS Bridge detected, but one is required. Please install one.")
} else {
    if (!speaker) print("Warn: A speaker is optimal, but not required");
}
