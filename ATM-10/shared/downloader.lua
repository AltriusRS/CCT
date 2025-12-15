local DOWNLOADER = {
    version = "0.1.0",
    author = "Arthur",
}


DOWNLOADER.download = function(url, path)
    local response = https.get(url)
    if response then
        local file = fs.open(path, "w")
        file.write(response.readAll())
        file.close()
        response.close()
        return true
    else
        return false
    end
end

-- Calculates the SHA-256 hash of a file
DOWNLOADER.sha256 = function(path)
    local signature, err = pcall(DOWNLOADER.sha256_unsafe, path)
    if signature then
        return signature
    else
        print("Error calculating SHA-256 hash:", err)
        return nil
    end
end

-- Calculates the SHA-256 hash of a file without error handling
-- DO NOT USE THIS FUNCTION DIRECTLY.
-- Always use DOWNLOADER.sha256 instead.
DOWNLOADER.sha256_unsafe = function(path)
    -- Depend on sha2 library for this functions
    local sha2 = require("sha2")
    local file = fs.open(path, "r")
    if file then
        local data = file.readAll()
        file.close()
        return sha2.sha256(data)
    else
        return nil
    end
end


return DOWNLOADER