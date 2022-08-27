position = 1

options = {
    GlassOS = {
        name = "GlassOS.core",
        info = "Glass OS is a HUD overlay built using the Advanced Peripherals AR Goggles + AR Controller\
It displays information about your connected ME terminals, Refined Storage systems, and Energy Detectors!\
Optionally, it also shows information from a selection of plugins\
\
Required Blocks\
- 1x Advanced Computer\
- 1x AR Controller\
\
Optional Blocks\
- 1x Wired Modem (needed for plugin connection)\
- 1x Advanced Peripherals ME Bridge\
- 1x Advanced Peripherals RS Bridge\
- 1x Advanced Peripherals Energy Detector\
",
        display = "GlassOS",
        version = "1.0.0",
        paste = "GlassOS/GlassOS",
        plugins = {
            ReactorOSPlugin = {
                name = "GlassOS.plugins.ReactorOS",
                info = "GlassOS plugin designed to interact with ReactorOS.\
This plugin requires an advanced computer placed directly next to one of:\
- Mekanism:fission_reactor_logic_adaptor\
- Mekanism:fusion_reactor_logic_adaptor\
- Draconic Evolution:reactor_stabilizer\
\
Without placing the computer next to one of the above blocks, this plugin will not work.\
\
Requirements:\
- 1x Advanced Computer\
- 1x Wired Modem\
- 1x 'Reactor Block'*\
\
*See compatible reactor block list above",
                display = "ReactorOS",
                version = "1.0.0",
                paste = "GlassOS/plugins/ReactorOS"
            }
        }
    },
    ReactorOS = {
        name = "ReactorOS.core",
        info = "Smart control algorithms for Mekanism Fission + Fusion reactors, as well as a basic attempt at a Draconic Reactor control algorithm",
        display = "ReactorOS",
        version = "1.0.0",
        paste = "ReactorOS/ReactorOS"
    },
    StockOS = {
        name = "StockOS.core",
        info = "Stock OS is an integration for Refined Storage which makes use of large monitors to show current stock levels of the most numerous items in your system.",
        display = "StockOS",
        version = "1.0.0",
        paste = "StockOS/StockOS"
    }
}

optLen = 4
printing = 1
inInfo = false

m = nil

function info()
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
    write("Info - " .. m.display .. "@" .. m.version .. " (Press I to exit) \n")
    write(m.info)
end

function install()
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.gray)
    term.clear()
    if m == nil then
        write("Failed to process nil module")
    else
        write("Attempting to install " .. m.name .. " Version " .. m.version .. "\n")
        write("clearing trash\n")
        shell.execute("rm", "startup")
        write("Installing boot disk\n")
        settings.set("core_os_load", m.paste)
        settings.save()
        shell.run("wget", "https://raw.githubusercontent.com/AltriusRS/CCT/main/CCTweaked/Bootloader/BootOS.lua", "startup")
        write("Installation completed.\nRebooting...")
        shell.execute("reboot")
    end
end

while true do
    if not inInfo then
        printing = 1
        term.clear()
        term.setCursorPos(1, 1)
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        write("CoreOS - Select OS to install (press I for info)\n")
        for _, object in next, options do
            if printing == position then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.black)
                write(object.display .. " (v" .. object.version .. ")\n")
                m = object
            else
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                write(object.display .. " (v" .. object.version .. ")\n")
            end
            printing = printing + 1
            if object.plugins ~= nil then
                for _, pobject in next, object.plugins do
                    if printing == position then
                        term.setBackgroundColor(colors.gray)
                        term.setTextColor(colors.black)
                        write(" - Plugin: " .. pobject.display .. " (v" .. pobject.version .. ")\n")
                        m = pobject
                    else
                        term.setBackgroundColor(colors.black)
                        term.setTextColor(colors.white)
                        write(" - Plugin: " .. pobject.display .. " (v" .. pobject.version .. ")\n")
                    end
                    printing = printing + 1
                end
            end
        end
    end

    _, key = os.pullEvent("key")
    if key == keys.up then
        if position == 1 then
            position = optLen
        else
            position = position - 1
        end
    elseif key == keys.down then
        if position == optLen then
            position = 1
        else
            position = position + 1
        end
    elseif key == keys.enter or key == keys.numPadEnter then
        install()
        break
    elseif key == keys.i then
        if inInfo then
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            inInfo = false
        else
            inInfo = true
            info()
        end
    end
end
