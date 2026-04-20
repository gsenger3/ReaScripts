-- __startup.lua
-- This script runs automatically when Reaper starts.
-- Used to synch the Primo Studios Monitor FX toggle buttons at startup

-- Get the correct path separator for the OS
local sep = package.config:sub(1,1)

local function RunScript(name)
    -- Construct path to the script in the Primo Studios subfolder
    local resource_path = reaper.GetResourcePath()
    local path = table.concat({resource_path, "Scripts", "Primo Studios", name}, sep)

    -- Verify the file exists using native REAPER function
    if not reaper.file_exists(path) then
        reaper.ShowConsoleMsg("Startup Error: Could not find script at " .. path .. "\n")
        return
    end

    -- Ensure AddRemoveReaScript is available (it should be on v6.27+)
    if reaper.AddRemoveReaScript then
        -- Register/get the Command ID for the script in the Main section (0)
        -- 'commit = true' ensures it's saved to reaper-kb.ini immediately
        local cmd_id = reaper.AddRemoveReaScript(true, 0, path, true)
        
        if cmd_id and cmd_id ~= 0 then
            -- Execute the script to trigger its toggle/sync logic
            reaper.Main_OnCommand(cmd_id, 0)
        else
            reaper.ShowConsoleMsg("Startup Error: Failed to get Command ID for " .. name .. "\n")
        end
    else
        -- Fallback for extremely weird edge cases where the API table isn't fully populated
        local cmd_name = "_" .. name:gsub(" ", "_"):upper()
        local cmd_id = reaper.NamedCommandLookup(cmd_name)
        if cmd_id > 0 then reaper.Main_OnCommand(cmd_id, 0) end
    end
end

-- Small delay to ensure the UI is ready before triggering sync
reaper.defer(function()
    RunScript("Primo-Monitors FX Toggle.lua")
    RunScript("Primo-Headphones FX Toggle.lua")
end)
