-- Lattice Audio Service
-- This service provides audio functionality for Lattice OS.

local log = require("shared.log")
local device_manager = require("os.kernel.device_manager")

local Audio = {
    initialized = false,
    speakers = {},
    busy = false,
}


function Audio.init()
    if Audio.initialized then
        log.trace("Audio service already initialized")
    end

    log.trace("initializing audio service")

    Audio.speakers = {}

    for _, device in ipairs(device_manager.get_devices()) do
        if device.type == "speaker" and device.status == "ok" then
            table.insert(Audio.speakers, device)
        end
    end

    if #Audio.speakers == 0 then
        log.warn("Audio service intialized with no speakers")
    else
        log.info("Audio service found " .. #Audio.speakers .. " speaker(s)")
    end

    Audio.initialized = true
end

-- internal helper: get a speaker
-- Optionally specify a device ID to get a specific speaker
local function get_speaker(device_id)
    if #Audio.speakers == 0 then
        return nil, "no speakers available"
    end

    if device_id then
        for id, speaker in ipairs(Audio.speakers) do
            if id == device_id then
                return speaker
            end
        end
        return nil, "speaker not found"
    else
        return Audio.speakers[1]
    end
end

-- Play a beep sound on a specific speaker or the default speaker
function Audio.beep(device_id)
    if not Audio.initialized then
        return false, "audio service not initialized"
    end

    if Audio.busy then
        return false, "audio busy"
    end

    local speaker, err = get_speaker()
    if not speaker then
        return false, err
    end

    Audio.busy = true

    local ok, result = pcall(speaker.beep, speaker)

    Audio.busy = false

    if not ok then
        log.error("Audio beep failed: " .. tostring(result))
        return false, result
    end

    return true
end

-- optional extension point
function Audio.play_note(instrument, volume, pitch)
    if not Audio.initialized then
        return false, "audio service not initialized"
    end

    if Audio.busy then
        return false, "audio busy"
    end

    local speaker, err = get_speaker()
    if not speaker then
        return false, err
    end

    Audio.busy = true

    local ok, result = pcall(
        speaker.play_note,
        speaker,
        instrument,
        volume,
        pitch
    )

    Audio.busy = false

    if not ok then
        log.error("Audio play_note failed: " .. tostring(result))
        return false, result
    end

    return true
end

return Audio
