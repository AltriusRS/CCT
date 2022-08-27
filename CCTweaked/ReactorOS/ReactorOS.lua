local version = "0.0.1"
local name = settings.get("reactorName")
local runtime = true
local reactor = peripheral.find("fissionReactorLogicAdapter")
local chatbox = peripheral.find("chatBox")
local r_type = nil
local damage_last_tick = 0
local ticks_passed = 0
local manual_restart = false
local status = false
local has_messaged = false
local waste_alerts = {
    fifty = false,
    seventy_five = false,
    ninety = false,
    max = false
}

local fuel_alerts = {
    empty = false,
    five = false,
    ten = false,
    twenty = false,
    fifty = false
}

write("Locating (Mekanism) Fission Reactor Logic Adapter\n")

if reactor ~= nil then
    r_type = "mekanism_fission_reactor"
    write("Found (Mekanism) Fission Reactor Logic Adapter\n")
else
    write("Locating (Mekanism) Fusion Reactor Logic Adapter\n")
    reactor = peripheral.find("fusionReactorLogicAdapter")
    if reactor ~= nil then
        r_type = "mekanism_fusion_reactor"
        write("Found (Mekanism) Fusion Reactor Logic Adapter\n")
    else
        write("Unable to locate (Mekanism) reactors")

        -- Check if it is a draconic reactor?

        -- reactor = peripheral.find("fusionReactorLogicAdapter")
        -- if reactor ~= nil then
        --     r_type = "mekanism_fusion_reactor"
        -- end

        runtime = false
    end
end

if runtime then
    if name == nil then
        settings.set("reactorName", r_type)
        name = r_type
    end
end

local function manageFission()
    local isOn = reactor.getStatus()
    local damage = reactor.getDamagePercent()

    if damage > 40 then
        manual_restart = true
        reactor.scram()
        isOn = reactor.getStatus()
        if chatbox ~= nil then
            chatbox.sendMessage("REACTOR SCRAM - MANUAL RESTART REQUIRED\nThis reactor needs to be manually reactivated.", name)
        end
    end

    if manual_restart then
        if isOn then
            chatbox.sendMessage("Reactor activated. Watching...", name)
            has_messaged = false
            manual_restart = false
            damage_last_tick = damage
            ticks_passed = 0
            status = isOn
        end
    else
        if isOn and damage > damage_last_tick then
            if ticks_passed >= 2 then
                reactor.scram()
                if chatbox ~= nil then
                    chatbox.sendMessage("REACTOR SCRAM - DAMAGED", name)
                end
                ticks_passed = 0
                status = false
            else
                chatbox.sendMessage("Taking Damage", name)
                os.sleep(0.05)
                chatbox.sendMessage("(" .. reactor.getDamagePercent() .. "%)", name)
                ticks_passed = ticks_passed + 1
                damage_last_tick = damage
            end

        elseif not isOn and damage == 0 and status == false then
            reactor.activate()
            if chatbox ~= nil then
                chatbox.sendMessage("Reactor is fully repaired", name)
                os.sleep(0.05)
                chatbox.sendMessage("Reactor is now online", name)
            end
            damage_last_tick = 0
            ticks_passed = 0
            status = true
        elseif isOn == false and damage == 0 and status then
            damage_last_tick = 0
            ticks_passed = 0

            if chatbox ~= nil and has_messaged == false then
                chatbox.sendMessage("Reactor is remaining offline\nReason: Player SCRAM", name)
                has_messaged = true
                manual_restart = true
            end
        end

        local waste = reactor.getWasteFilledPercentage() * 100

        if waste >= 50 and waste_alerts.fifty ~= true then
            waste_alerts.fifty = true
            if chatbox ~= nil then
                chatbox.sendMessage("NUCLEAR WASTE LEVEL: 50%", name)
            end
        elseif waste >= 75 and waste_alerts.seventy_five ~= true then
            waste_alerts.seventy_five = true
            if chatbox ~= nil then
                chatbox.sendMessage("NUCLEAR WASTE LEVEL: 75%", name)
            end
        elseif waste >= 90 and waste_alerts.ninety ~= true then
            waste_alerts.ninety = true
            if chatbox ~= nil then
                chatbox.sendMessage("NUCLEAR WASTE LEVEL: 90%\nShutting down reactor.\nManual restart required", name)
            end
            manual_restart = true
            reactor.scram()
            waste_alerts.fifty = false
            waste_alerts.seventy_five = false
            waste_alerts.ninety = false
            waste_alerts.max = false
        end

        local fuel = reactor.getFuelFilledPercentage() * 100

        if fuel <= 20 and fuel_alerts.twenty ~= true then
            fuel_alerts.twenty = true
            if chatbox ~= nil then
                chatbox.sendMessage("NUCLEAR FUEL LEVEL: 20%", name)
            end
        elseif fuel <= 10 and fuel_alerts.ten ~= true then
            fuel_alerts.ten = true
            if chatbox ~= nil then
                chatbox.sendMessage("NUCLEAR FUEL LEVEL: 10%", name)
            end
        elseif fuel <= 5 and fuel_alerts.five ~= true then
            fuel_alerts.five = true
            if chatbox ~= nil then
                chatbox.sendMessage("NUCLEAR FUEL LEVEL: 5%\nShutting down reactor.\nManual restart required", name)
            end
            manual_restart = true
            reactor.scram()
            fuel_alerts.empty = false
            fuel_alerts.ten = false
            fuel_alerts.five = false
            fuel_alerts.twenty = false
        end
    end
end

local function checkName()
    local n2 = settings.get("reactorName")
    if n2 ~= name and n2 ~= nil then
        chatbox.sendMessage("Renamed " .. r_type .. "\nOld name: " .. name .. "\nNew name: " .. n2, "ReactorOS (v" .. version .. ")")
        name = n2
    end
end

if chatbox ~= nil then
    chatbox.sendMessage("Initialized new " .. r_type .. " (Label: " .. name .. ")", "ReactorOS (v" .. version .. ")")
end

while runtime do
    checkName()
    if r_type == "mekanism_fission_reactor" then
        manageFission()
    elseif r_type == "mekanism_fusion_reactor" then
        write("Fusion reactors currently not supported")
        runtime = false
    end

    os.sleep(0.1)
end