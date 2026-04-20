-- Headphones FX Toggle.lua
-- @description Toggle Headphones FX container 
-- @about Toggles the Headphones FX container in the Monitor FX section of the
-- Master track on/off and updates the toolbar button state 
-- @author Primo Studios
-- @version 1.0

-- USER CONFIGURATION: Set this to the name of the plugin or container to toggle
local TARGET_FX_NAME = "Headphones"
local DEBUG = false -- enable or disable DEBUG mode

-- Cache values
local _, _, section, cmd_id = reaper.get_action_context()
local master_track = reaper.GetMasterTrack(0)
local last_state = -1 -- Initialize to invalid state to force first update

-- DEBUG messages, when DEBUG is true
local function Msg(str)
    if DEBUG then reaper.ShowConsoleMsg(tostring(str) .. "\n") end
end

-- Sets the button state to value of state arg
local function SetButtonState(state)
    if state == last_state then return end

    Msg("Toolbar state changed to: " .. (state == 1 and "ON" or "OFF"))
    reaper.SetToggleCommandState(section, cmd_id, state)
    reaper.RefreshToolbar2(section, cmd_id)
    last_state = state
end

-- Gets the FX on the Master track by name, not position
local function GetMonitorFXByName(target_name)
    if not master_track then return nil end
    local fx_count = reaper.TrackFX_GetRecCount(master_track)
    local lower_target = target_name:lower()

    for i = 0, fx_count - 1 do
        local monitor_fx_idx = i + 0x1000000
        local _, name = reaper.TrackFX_GetFXName(master_track, monitor_fx_idx, "")

        -- Check if the target name exists within the FX name
        if name:lower():find(lower_target, 1, true) then
            return monitor_fx_idx
        end
    end
    return nil
end

Msg("Monitor FX Toggle Executing...")

-- Locate the target FX
local fx_idx = GetMonitorFXByName(TARGET_FX_NAME)

-- Execute Toggle/Sync Logic
-- we check the state of the button and the FX, if they are different
-- we set button state to match FX state, else we toggle states on both
if fx_idx then
    local btn_state = reaper.GetToggleCommandStateEx(section, cmd_id)
    local fx_enabled = reaper.TrackFX_GetEnabled(master_track, fx_idx)
    local fx_state = fx_enabled and 1 or 0
    Msg("btn_state=" .. btn_state)
    Msg("fx_state=" .. fx_state)

    if btn_state ~= fx_state then
        Msg("The Toolbar Button and FX state are out of sync. The button will now be synced to the FX state.")
        Msg("Logic: States differ. Syncing Button to match FX (" .. fx_state .. ")")
        SetButtonState(fx_state)
    else
        local new_state = not fx_enabled -- flip the state and set it
        Msg("Logic: States match. Toggling FX to " .. (new_state and "ENABLED" or "DISABLED"))
        reaper.TrackFX_SetEnabled(master_track, fx_idx, new_state)
        SetButtonState(new_state and 1 or 0)
    end
else
    Msg("Error: '" .. TARGET_FX_NAME .. "' not found in Monitor FX.")
end
