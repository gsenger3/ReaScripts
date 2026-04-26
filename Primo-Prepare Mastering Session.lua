-- Prepare Mastering Session.lua
-- @description Prepare project tracks for mastering
-- @about Sets random colors for all tracks, aligns them sequentially, and creates regions.
-- @author Primo Studios
-- @version 1.0

local function Main()
    -- Ask for confirmation before proceeding
    local title = "Confirm Mastering Preparation"
    local message = "Are you sure you want to prepare the tracks for mastering?\n\n" ..
                    "This sequentially aligns all tracks, randomizes all track colors and creates regions for each track."
    local response = reaper.MB(message, title, 4) -- 4 = Yes/No buttons
    
    if response ~= 6 then return end -- 6 = 'Yes', else exit

    -- begin the prep for mastering...
    local track_count = reaper.CountTracks(0)
    if track_count == 0 then return end

    reaper.Undo_BeginBlock()
    
    -- Seed the random number generator
    math.randomseed(os.time())

    local current_time = 0

    for i = 0, track_count - 1 do
        local track = reaper.GetTrack(0, i)

        -- Step 1: Set all tracks in project to a random color
        local r = math.random(0, 255)
        local g = math.random(0, 255)
        local b = math.random(0, 255)
        local color = reaper.ColorToNative(r, g, b) | 0x1000000
        reaper.SetTrackColor(track, color)

        -- Step 2: Sequentially align all tracks in the timeline
        local item_count = reaper.GetTrackNumMediaItems(track)
        if item_count > 0 then
            -- Determine the span of items on the current track
            local min_start = math.huge
            local max_end = -math.huge
            
            -- Store items and positions to calculate move
            local items = {}
            for j = 0, item_count - 1 do
                local item = reaper.GetTrackMediaItem(track, j)
                local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
                local len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
                local item_end = pos + len
                
                if pos < min_start then min_start = pos end
                if item_end > max_end then max_end = item_end end
                
                items[#items + 1] = { ptr = item, pos = pos }
            end

            -- Calculate movement offset to place the first item at current_time
            local offset = current_time - min_start
            
            for j = 1, #items do
                reaper.SetMediaItemInfo_Value(items[j].ptr, "D_POSITION", items[j].pos + offset)
            end
            
            -- Step 3: Create a region for the track
            local _, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
            
            if track_name == "" then track_name = "Track " .. (i + 1) end
            local track_duration = max_end - min_start
            reaper.AddProjectMarker2(0, true, current_time, current_time + track_duration, track_name, -1, color)

            -- Update current_time for the next track to start after the current track's items
            current_time = current_time + track_duration
        end
    end

    reaper.Undo_EndBlock("Prepare Mastering Session", -1)
    reaper.UpdateArrange()
end

Main()