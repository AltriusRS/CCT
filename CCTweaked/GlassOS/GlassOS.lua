-- GENERAL VARIABLES
local version = "0.1.0"
local backbar = "--------------------"
local alerted = false
local updateInterval = 60 * 20
local second = 20
local runtime = true
local padding = 10

-- OS VARIABLES
local guiScale = settings.get("glass.guiScale")    -- Retreive the guiScale variable from the system

-- PERIPHERALS
local controller = peripheral.find("arController")   -- Locate AR Controller peripheral
local rs = peripheral.find("rsBridge")       -- Locate Refined Storage Bridge peripheral
local rf = peripheral.find("energyDetector") -- Locate Energy Detector peripheral
local me = peripheral.find("meBridge")       -- Locate ME Bridge peripheral
local modem = peripheral.find("modem")          -- Locate modem peripheral

-- MODULE TABLES
local fission_reactors = {} -- Table containing all connected Mekansim Fission Reactors
local fusion_reactors = {} -- Table containing all connected Mekansim Fusion Reactors

-- MODULE TRACKERS
local fission_index = 0 -- Track which tab of the fission graph to draw
local fusion_index = 0 -- Track which tab of the fusion graph to draw

-- UI POSITIONING
-- LEFT PANELS
local fiY = 30     -- Fission Reactor Module
local fuY = fiY + 90 -- Fusion Reactor Module
local rsY = fuY + 90 -- Refined Storage Panel (Default)
local meY = rsY + 90 -- AE2 / ME Storage Panel (Default)
local rfY = meY + 40 -- Cable Throughput panel (Default)

-- Color globals
local fontColor = 0xffffff
local green = 0x29cd38
local red = 0xba1010
local orange = 0xbd7110

if modem == nil then
    write("No modem installed\n")
else
    modem.open(1)
    local hosts = modem.getNamesRemote()
    write("Connected Modem Peripherals: " .. table.getn(hosts) .. "\n")
    for _, value in next, hosts do

        local names = modem.getMethodsRemote(value)

        for _, item in next, names do
            if item == "getLabel" then
                local label = modem.callRemote(value, item)
                if label ~= nil then
                    if string.find(label, "ReactorOS") then
                        write("Found ReactorOS instance on peripheral\n")
                        write("- " .. value .. "\n")
                        modem.transmit(2, 1, { op = 1, p = "IDENTIFY" })
                        local event, side, channel, replyChannel, message, distance
                        repeat
                            event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
                        until channel == 1

                        write(message.reactorKind .. " - " .. message.reactorName)
                    end
                end
            end
            --write("  #" .. item .. "\n")
        end

        -- if string.find(value, "fission_reactor_casing") ~= nil then
        --     table.insert(fission_reactors, table.getn(fission_reactors), value)
        -- elseif string.find(value, "fusion_reactor_casing") ~= nil then
        --     table.insert(fusion_reactors,table.getn(fusion_reactors), value)
        -- end
    end
    -- write("Found "..(table.getn(fission_reactors)).." Mekanism Fission Reactors\n")
    -- write("Found "..(table.getn(fusion_reactors)).." Mekanism Fusion Reactors\n")
end

if guiScale == 4 then
    rsY = 25
    meY = rsY + 50
    rfY = meY + 30
end

if guiScale == nil then
    guiScale = 2
    settings.set("glass.guiScale", 2)
end

if controller == nil then
    write("No AR Controller was found\n")
    runtime = false
else
    controller.setRelativeMode(true, 1600, 900)
end

if rf == nil then
    write("No Energy Detector was found - Energy stats unavailable\n")
else
    rf.setTransferRateLimit(100000000)
end

if rs == nil then
    write("No RS Bridge was found - Refined Storage unavailable\n")
end

if me == nil then
    write("No ME Bridge was found - ME Storage unavailable\n")
end

local function gradientC(color1, color2, level)
    -- level = level * 100

    local reddiff = -1 * (color1["red"] - color2["red"])
    local redpixel = reddiff / 100

    local bluediff = -1 * (color1["blue"] - color2["blue"])
    local bluepixel = bluediff / 100

    local greendiff = -1 * (color1["green"] - color2["green"])
    local greenpixel = greendiff / 100

    local newred = color1["red"] + level * redpixel
    local newblue = color1["blue"] + level * bluepixel
    local newgreen = color1["green"] + level * greenpixel

    local rh = string.format("%02x", newred) -- minimum returned numbers 2, left padded with 0's see https://developer.roblox.com/en-us/articles/Format-String
    local gh = string.format("%02x", newgreen)
    local bh = string.format("%02x", newblue)
    local hex = "0x" .. rh .. gh .. bh
    local newcolor = tonumber(hex)

    return newcolor
end

local function alert(message, subtext, color, duration, fade)
    local testx = 400
    local testy = 250
    local testy2 = 260

    if guiScale == 4 then
        testx = 200
        testy = 125
        testy2 = 130
    end

    controller.clear()
    if duration == nil or duration < 2 then
        duration = 2
    end

    local displayed = 0
    local darkened = false
    while displayed < duration do
        controller.clear()
        if darkened then
            controller.drawCenteredString(message, testx, testy, 0x000000)
            controller.drawCenteredString(subtext, testx, testy2, gradientC(color, color, 0))
            darkened = false
        else
            controller.drawCenteredString(message, testx, testy, gradientC(color, color, 0))
            controller.drawCenteredString(subtext, testx, testy2, gradientC(color, color, 0))
            darkened = true
        end

        displayed = displayed + 0.5
        os.sleep(0.5)
    end

    local fader = 0

    if fade ~= nil then
        if fade < 2 then
            fade = 2
        end
        while displayed < duration + fade do
            controller.clear()
            controller.drawCenteredString(
                    message,
                    testx,
                    testy2,
                    gradientC(color, { red = 0, green = 0, blue = 0 }, fader)
            )
            controller.drawCenteredString(
                    message,
                    testx,
                    testy2,
                    gradientC(color, { red = 0, green = 0, blue = 0 }, fader)
            )
            displayed = displayed + 0.25
            fader = fader + 10
            os.sleep(0.25)
        end
    end
    controller.clear()
end

local function close(code, message, exiting)
    controller.clear()
    if code == 1 then
        controller.drawString("Glass OS Exited", padding, 10, 0xb20000)
        controller.drawString("Exit Type: Error", padding, 20, 0xb20000)
        controller.drawString(message, padding, 30, 0xb20000)
    elseif code == 0 then
        controller.drawString("Glass OS Exited", padding, 10, 0x20b200)
        controller.drawString("Exit Type: Clean", padding, 20, 0x20b200)
        controller.drawString(message, padding, 30, 0x20b200)
    elseif code == 3 then
        controller.drawString("Glass OS Exited", padding, 10, 0xb26700)
        controller.drawString("Exit Type: Update", padding, 20, 0xb26700)
        controller.drawString(message, padding, 30, 0xb26700)
    end
    if exiting then
        runtime = false
    end
end

local function updateSelf()
    close(3, "GlassOS is updating.", false)
    runtime = false
    os.reboot()
end

local function pretty_num(amount)
    local prefix = ""

    while amount > 1024 do
        if prefix == "" then
            prefix = "K"
        elseif prefix == "K" then
            prefix = "M"
        elseif prefix == "M" then
            prefix = "G"
        elseif prefix == "G" then
            prefix = "T"
        elseif prefix == "T" then
            break
        end
        amount = math.floor(amount / 1024)
    end

    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if (k == 0) then
            break
        end
    end
    return formatted .. prefix
end

local function nums(amount)
    if amount == -1 then
        return "Infinity"
    end

    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if (k == 0) then
            break
        end
    end

    return formatted
end

local function isNan(value)
    if tostring(value) == "nan" then
        return true
    end
    return false
end

local function drawProgressBar(current, max, upper, lower, color)
    if current > 0 then
        local pc = current / max * 100
        if pc < 0 then
            pc = pc * -1
        end

        if max == -1 then
            pc = 0
        end

        local width = math.ceil(pc)
        controller.fill(padding, upper, width + padding, lower, color)
    end
end

local function renderRSPower()
    local current = rs.getEnergyStorage()
    local usage = rs.getEnergyUsage()
    local max = rs.getMaxEnergyStorage()
    local pc = (current / max) * 100

    if pc < 0 then
        pc = pc * -1
    end

    local totalItems = 0
    local itemStore = rs.getMaxItemDiskStorage()
    local items = rs.listItems()

    for _, value in next, items do
        totalItems = totalItems + value.amount
    end
    local itemCapacity = (totalItems / itemStore) * 100

    if itemCapacity < 0 then
        itemCapacity = itemCapacity * -1
    end

    local totalFluids = 0
    local fluidStore = rs.getMaxFluidDiskStorage()
    local fluids = rs.listFluids()

    for _, value in next, fluids do
        totalFluids = totalFluids + value.amount
    end
    local fluidCapacity = (totalFluids / fluidStore) * 100

    if fluidCapacity < 0 then
        fluidCapacity = fluidCapacity * -1
    end

    if isNan(pc) then
        pc = 0
    end

    if isNan(fluidCapacity) then
        fluidCapacity = 0
    end

    if isNan(itemCapacity) then
        itemCapacity = 0
    end

    local energyColor = green
    local itemColor = green
    local fluidColor = green

    if pc < 40 then
        energyColor = red
    elseif pc < 80 then
        energyColor = orange
    end

    if itemCapacity > 80 then
        itemColor = red
    elseif itemCapacity > 40 then
        itemColor = orange
    end

    if fluidCapacity > 80 then
        fluidColor = red
    elseif fluidCapacity > 40 then
        fluidColor = orange
    end

    if guiScale == 2 then
        controller.drawString("Refined Storage System", padding, rsY, fontColor)
        controller.drawString(
                "Energy: " .. pretty_num(current) .. " / " .. pretty_num(max) .. "FE (" .. math.ceil(pc) .. "%)",
                padding,
                rsY + 10,
                0x717171
        )
        controller.drawString(backbar, padding, rsY + 20, 0x333333)
        drawProgressBar(current, max, rsY + 20, rsY + 25, energyColor)
        controller.drawString(
                "Using:  " .. pretty_num(math.ceil(usage)) .. "FE/t (" .. pretty_num(math.ceil(usage * second)) .. "FE/s)",
                padding,
                rsY + 30,
                0x717171
        )

        controller.drawString(
                "Items: " .. nums(totalItems) .. " / " .. nums(itemStore) .. " (" .. math.ceil(itemCapacity) .. "%)",
                padding,
                rsY + 40,
                0x717171
        )
        controller.drawString(backbar, padding, rsY + 50, 0x333333)
        drawProgressBar(totalItems, itemStore, rsY + 50, rsY + 55, itemColor)

        controller.drawString(
                "Fluids: " .. nums(totalFluids) .. " / " .. nums(fluidStore) .. " (" .. math.ceil(fluidCapacity) .. "%)",
                padding,
                rsY + 60,
                0x717171
        )
        controller.drawString(backbar, padding, rsY + 70, 0x333333)
        drawProgressBar(totalFluids, fluidStore, rsY + 70, rsY + 75, fluidColor)
    elseif guiScale == 4 then
        controller.drawString("Refined Storage System", padding, rsY, fontColor)
        controller.drawString(
                "Energy: " .. pretty_num(current) .. " / " .. pretty_num(max) .. "FE (" .. math.ceil(pc) .. "%)",
                padding,
                rsY + 5,
                0x717171
        )
        controller.drawString(backbar, padding, rsY + 10, 0x333333)
        drawProgressBar(current, max, rsY + 10, rsY + 15, energyColor)
        controller.drawString(
                "Using:  " .. pretty_num(math.ceil(usage)) .. "FE/t (" .. pretty_num(math.ceil(usage * second)) .. "FE/s)",
                padding,
                rsY + 20,
                0x717171
        )

        controller.drawString(
                "Items: " .. nums(totalItems) .. " / " .. nums(itemStore) .. " (" .. math.ceil(itemCapacity) .. "%)",
                padding,
                rsY + 25,
                0x717171
        )
        controller.drawString(backbar, padding, rsY + 30, 0x333333)
        drawProgressBar(totalItems, itemStore, rsY + 30, rsY + 35, itemColor)

        controller.drawString(
                "Fluids: " .. nums(totalFluids) .. " / " .. nums(fluidStore) .. " (" .. math.ceil(fluidCapacity) .. "%)",
                padding,
                rsY + 40,
                0x717171
        )
        controller.drawString(backbar, padding, rsY + 45, 0x333333)
        drawProgressBar(totalFluids, fluidStore, rsY + 45, rsY + 50, fluidColor)
    end

    if pc < 80 and alerted == false then
        alerted = true
        alert("POWER FAILURE - Refined Storage", "Systems shutting down", { red = 255, green = 0, blue = 0 }, 5, 2)
    elseif pc >= 80 and alerted then
        alert("POWER RESTORED - Refined Storage", "All systems optimal", { red = 0, green = 188, blue = 15 }, 3, nil)
        alerted = false
    end
end

local function RSPower()
    local current = rs.getEnergyStorage()
    local max = rs.getMaxEnergyStorage()
    local pc = (current / max) * 100
    if pc < 80 and alerted == false then
        renderRSPower()
    elseif pc >= 80 and alerted then
        renderRSPower()
    end
end

local function renderMEPower()
    local current = me.getEnergyStorage()
    local usage = me.getEnergyUsage()
    local max = me.getMaxEnergyStorage()
    local pc = (current / max) * 100

    if isNan(pc) then
        pc = 0
    end

    local energyColor = green

    if pc < 40 then
        energyColor = red
    elseif pc < 80 then
        energyColor = orange
    end

    if guiScale == 2 then
        controller.drawString("ME System", padding, meY, fontColor)
        controller.drawString(
                "Energy: " .. pretty_num(current) .. " / " .. pretty_num(max) .. "FE (" .. math.ceil(pc) .. "%)",
                padding,
                meY + 10,
                0x717171
        )
        controller.drawString(backbar, padding, meY + 20, 0x333333)
        drawProgressBar(current, max, meY + 20, meY + 25, energyColor)
        controller.drawString(
                "Using:  " .. pretty_num(math.ceil(usage)) .. "FE/t (" .. pretty_num(math.ceil(usage * second)) .. "FE/s)",
                padding,
                meY + 30,
                0x717171
        )
    elseif guiScale == 4 then
        controller.drawString("Refined Storage System", padding, meY, fontColor)
        controller.drawString(
                "Energy: " .. pretty_num(current) .. " / " .. pretty_num(max) .. "FE (" .. math.ceil(pc) .. "%)",
                padding,
                meY + 5,
                0x717171
        )
        controller.drawString(backbar, padding, meY + 10, 0x333333)
        drawProgressBar(current, max, meY + 10, meY + 15, energyColor)
        controller.drawString(
                "Using:  " .. pretty_num(math.ceil(usage)) .. "FE/t (" .. pretty_num(math.ceil(usage * second)) .. "FE/s)",
                padding,
                meY + 20,
                0x717171
        )
    end

    if pc < 80 and alerted == false then
        alerted = true
        alert("POWER FAILURE - ME System", "Systems shutting down", { red = 255, green = 0, blue = 0 }, 5, 2)
    elseif pc >= 80 and alerted then
        alert("POWER RESTORED - ME System", "All systems optimal", { red = 0, green = 188, blue = 15 }, 3, nil)
        alerted = false
    end
end

local function MEPower()
    local current = rs.getEnergyStorage()
    local usage = rs.getEnergyUsage()
    local max = rs.getMaxEnergyStorage()
    local pc = (current / max) * 100
    if pc < 80 and alerted == false then
        renderMEPower()
    elseif pc >= 80 and alerted then
        renderMEPower()
    end
end

function round(exact, quantum)
    local quant, frac = math.modf(exact / quantum)
    return quantum * (quant + (frac > 0.5 and 1 or 0))
end

local function Energy()
    local transfer = rf.getTransferRate()
    local limit = rf.getTransferRateLimit()
    local pc = (transfer / limit) * 100

    while pc >= 80 do
        rf.setTransferRateLimit(limit * 1.25)
        transfer = rf.getTransferRate()
        limit = rf.getTransferRateLimit()
        pc = (transfer / limit) * 100
    end
end

local function renderEnergy()
    local transfer = rf.getTransferRate()
    local limit = rf.getTransferRateLimit()
    local pc = (transfer / limit) * 100

    while pc >= 80 do
        rf.setTransferRateLimit(limit * 1.25)
        transfer = rf.getTransferRate()
        limit = rf.getTransferRateLimit()
        pc = (transfer / limit) * 100
    end

    if guiScale == 2 then
        controller.drawString("Energy Management", padding, rfY, fontColor)
        controller.drawString(
                "Using:           " ..
                        pretty_num(math.ceil(transfer)) .. " FE/t (" .. pretty_num(math.ceil(transfer * second)) .. "FE/s)",
                padding,
                rfY + 10,
                0x717171
        )
        controller.drawString(
                "Transfer Limit:  " .. round(pc, 2) .. " % (of " .. pretty_num(limit) .. "FE/t)",
                padding,
                rfY + 20,
                0x717171
        )
    elseif guiScale == 4 then
        controller.drawString("Energy Management", padding, rfY, fontColor)
        controller.drawString(
                "Using:           " ..
                        pretty_num(math.ceil(transfer)) .. " FE/t (" .. pretty_num(math.ceil(transfer * second)) .. "FE/s)",
                padding,
                rfY + 5,
                0x717171
        )
        controller.drawString(
                "Transfer Limit:  " .. round(pc, 2) .. " % (of " .. pretty_num(limit) .. "FE/t)",
                padding,
                rfY + 10,
                0x717171
        )
    end
end

local function processArgs(text)
    local a = {}
    local e = 0
    local index = 0
    while true do
        local b = e + 1
        b = text:find("%S", b)
        if b == nil then
            break
        end
        if text:sub(b, b) == "'" then
            e = text:find("'", b + 1)
            b = b + 1
        elseif text:sub(b, b) == '"' then
            e = text:find('"', b + 1)
            b = b + 1
        else
            e = text:find("%s", b + 1)
        end
        if e == nil then
            e = #text + 1
        end
        a[index] = text:sub(b, e - 1)
        index = index + 1
    end
    return a
end

local function renderFission()
    fission_index = fission_index + 1
    if fission_index > table.getn(fission_reactors) then
        fission_index = 1
    end

    for index, name in next, fission_reactors do
        if index == fission_index then
            controller.drawString(fission_index .. "/" .. table.getn(fission_reactors) .. " | Fission Reactor #" .. index, padding, fiY + 30, fontColor)
            local details = modem.callRemote(name, "getItemDetails")
            for idex, field in next, details do
                write(idex .. " - " .. field)
            end
            controller.drawString(type(details), padding, fiY, fontColor)

            -- local statusColor = red

            -- if status then
            --     statusColor = "green"
            --     status = "ONLINE"
            -- else 
            --     status = "OFFLINE"
            -- end

            -- controller.drawString("Status: "..status, padding, fiY, statusColor)
        end
    end
end

local function plugins()

end

local function renderFrame()

    if modem ~= nil then
        plugins()
    end

    controller = peripheral.find("arController")
    if controller == nil then
        write("No AR Controller was found\n")
        runtime = false
    else
        controller.setRelativeMode(true, 1600, 900)
    end
    controller.clear()
    controller.drawString("GlassOS V" .. version .. " | Uptime " .. os.clock() .. " seconds", padding, 10, fontColor)
    rf = peripheral.find("energyDetector")
    rs = peripheral.find("rsBridge")
    modem = peripheral.find("modem")

    if os.clock() >= updateInterval then
        updateSelf()
    elseif os.clock() + 60 >= updateInterval then
        if guiScale == 2 then
            controller.drawString(
                    "GlassOS will update in " .. math.ceil(updateInterval - os.clock()) .. " seconds",
                    padding,
                    20,
                    0x00a59d
            )
        elseif guiScale == 4 then
            controller.drawString(
                    "GlassOS will update in " .. math.ceil(updateInterval - os.clock()) .. " seconds",
                    padding,
                    15,
                    0x00a59d
            )
        end
    end

    if table.getn(fission_reactors) == 0 then
        fuY = fiY
        rsY = fuY + 90
        meY = rsY + 90
        rfY = meY + 45
        if guiScale == 4 then
            fiY = 30
            fuY = fiY + 50
            rsY = fuY + 50
            meY = rsY + 50
            rfY = meY + 30
        end
    else
        renderFission()
    end

    if table.getn(fusion_reactors) == 0 then
        rsY = fuY
        meY = rsY + 90
        rfY = meY + 45
        if guiScale == 4 then
            fiY = 30
            fuY = fiY + 50
            rsY = fuY + 50
            meY = rsY + 50
            rfY = meY + 30
        end
    else
        -- renderFusion()
    end

    if rs ~= nil then
        renderRSPower()
        meY = rsY + 90
        rfY = meY + 45
        if guiScale == 4 then
            meY = rsY + 50
            rfY = meY + 30
        end
    else
        if guiScale == 2 then
            controller.drawString("Refined Storage System", padding, rsY, fontColor)
            controller.drawString("Status: Not Installed", padding, rsY + 10, 0xaa0000)
            meY = rsY + 25
        elseif guiScale == 4 then
            controller.drawString("Refined Storage System", padding, rsY, fontColor)
            controller.drawString("Status: Not Installed", padding, rsY + 5, 0xaa0000)
            meY = rsY + 20
        end
    end

    if me ~= nil then
        renderMEPower()
        rfY = meY + 45
        if guiScale == 4 then
            rfY = meY + 30
        end
    else
        if guiScale == 2 then
            controller.drawString("ME System", padding, meY, fontColor)
            controller.drawString("Status: Not Installed", padding, meY + 10, 0xaa0000)
            rfY = meY + 25
        elseif guiScale == 4 then
            controller.drawString("ME System", padding, meY, fontColor)
            controller.drawString("Status: Not Installed", padding, meY + 5, 0xaa0000)
            rfY = meY + 20
        end
    end

    if rf ~= nil then
        renderEnergy()
    else
        if guiScale == 2 then
            controller.drawString("Energy Management", padding, rfY, fontColor)
            controller.drawString("Status: Not Installed", padding, rfY + 10, 0xaa0000)
        elseif guiScale == 4 then
            controller.drawString("Energy Management", padding, rfY, fontColor)
            controller.drawString("Status: Not Installed", padding, rfY + 5, 0xaa0000)
        end
    end

    -- if guiScale == 2 then
    --     controller.drawString("Produced by Altrius#9733", 10, 430, 0x171515)
    -- end
end

renderFrame()

while runtime do
    if rf ~= nil then
        Energy()
    end
    if rs ~= nil then
        RSPower()
    end
    if me ~= nil then
        MEPower()
    end

    if math.floor(os.clock()) % 10 == 0 then
        renderFrame()
    end

    os.sleep(0.1)
end
