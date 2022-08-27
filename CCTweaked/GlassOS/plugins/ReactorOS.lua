local runtime = true

local label = os.getComputerLabel()
local modem = peripheral.find("modem")

if modem ~= nil then
    modem.open(2)
else
    write("No modem located. Modem is required for capability")
    runtime = false
end

local function checkName()
    local n2 = settings.get("reactorName")
end

local reactor = peripheral.find("fissionReactorLogicAdapter")
local r_type = nil

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

while runtime do
    repeat event, _, channel, replyChannel, message, _ = os.pullEvent("modem_message") until channel == 2

    if message.op == 1 then
        if message.p == "IDENTIFY" then
            modem.transmit(replyChannel, channel, {
                reactorKind = r_type,
                reactorName = name
            })
        end
    end
end