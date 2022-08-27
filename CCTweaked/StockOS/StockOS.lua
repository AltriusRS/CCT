instrument = "bit"
speaker = peripheral.find("speaker")
screen = peripheral.find("monitor")
rs = peripheral.find("rsBridge")
volume = 1
safe = true

function siren(duration)
    local blips = 0
    if screen ~= nil then
        while blips < (duration / 0.5) do
            if speaker ~= nil then
                speaker.playNote(instrument, 3, 2)
            end
            screen.setBackgroundColor(0x4000)
            wipe()
            sleep(0.25)
            wipe()
            screen.setBackgroundColor(0x8000)
            wipe()

            if speaker ~= nil then
                speaker.playNote(instrument, 3, 1)
            end
            sleep(0.25)
            blips = blips + 1
        end
    end
end

function wipe()
    if screen ~= nil then
        screen.clear()
        screen.setCursorPos(1, 1)
    end
end

if screen ~= nil then
    screen.setPaletteColour(colors.red, 0xFF0000)
    screen.setPaletteColour(colors.blue, 0x0827F5)
    screen.setBackgroundColor(2048)
    screen.setTextColor(1)
    wipe()
    sleep(0.5)
    screen.write("Starting....")
end

function throw(message)
    if speaker ~= nil then
        speaker.playNote(instrument, 3, 0.1)
    end

    if screen ~= nil then
        screen.setBackgroundColor(0x800)
        screen.setTextColor(0x1)
        wipe()
        screen.write("Your computer ran into a problem")
        screen.setCursorPos(1, 2)
        screen.write("and needs to restart")
        screen.setCursorPos(1, 3)
        screen.write("Please wait whilst we collect")
        screen.setCursorPos(1, 4)
        screen.write("information on")
        screen.setCursorPos(1, 5)
        screen.write("what you fucked up.")
        screen.setCursorPos(1, 7)
        screen.write("Collecting: 99%")
        screen.setCursorPos(1, 9)
        screen.write("Error: ")
        screen.write(message)
    end
    print(message)
end

function get_items()
    return rs.listItems()
end

function split_str (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function format_item_name(text, length)
    if text == nil then
        text = "Unknown"
    end

    while #text < (length + 1) do
        text = text .. " "
    end
    return text
end

function render_list(items)
    screen.setTextColor(0x1)

    local longest = 0
    local listed = {}
    for _, v in pairs(items) do
        v.displayName = split_str(v.displayName, "[")[2]
        v.displayName = split_str(v.displayName, "]")[1]
        if #v.displayName > longest then
            longest = #v.displayName
        end

        if v.amount > 1 then
            table.insert(listed, { v.displayName, v.amount })
        end
    end

    local line = 2;
    print("Longest", longest, "Scale", screen.getTextScale())
    table.sort(listed, function(a, b)
        return a[2] > b[2]
    end)

    for _, v in pairs(listed) do
        screen.setCursorPos(1, line)
        if line % 2 == 0 then
            screen.setBackgroundColor(0x80)
        else
            screen.setBackgroundColor(0x8000)
        end
        screen.clearLine()
        screen.write(format_item_name(v[1], longest) .. " - " .. v[2] .. "  ")
        line = line + 1
    end

end

function start()
    if speaker ~= nil then
        speaker.playNote(instrument, volume, 1)
        sleep(0.25)
        speaker.playNote(instrument, volume, 12)
    end

    sleep(3)

    while safe do
        items = get_items()
        wipe()
        screen.setBackgroundColor(0x2)
        screen.setTextColor(0x8000)
        screen.clearLine()
        screen.write("Refined Stock Levels")
        render_list(items)
        sleep(3)
    end

    sleep(3)

    if speaker ~= nil then
        speaker.playNote(instrument, volume, 12)
        sleep(0.25)
        speaker.playNote(instrument, volume, 1)
    end

    screen.setBackgroundColor(0x800)
    wipe()
end

if rs == nil then
    throw("You fucking idiot, you need an RS Bridge to use this.")
else
    start()
end