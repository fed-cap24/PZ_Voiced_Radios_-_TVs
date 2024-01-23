-- Save the original AddRadioLine function
local originalAddRadioLine = RadioBroadCast.AddRadioLine

-- Create a lookup table for air times and tags based on the text

local radioLineData = {
    ["Fiver Zero Two"] = { tag = "GUID:AEBS_Intro", airTime = 4.70 },
    ["Air Activity detected"] = { tag = "GUID:AEBS_Choppah", airTime = 1.50 },
    ["Knox Power Grid: Power fluctuations detected."] = { tag = "GUID:AEBS_Power_1", airTime = 3.50 },
    ["Knox Power Grid: Systems failing. Network compromised."] = { tag = "GUID:AEBS_Power_2", airTime = 4.69 },
    ["Knox Power Grid: Blackout."] = { tag = "GUID:AEBS_Power_3", airTime = 2.17 },
    ["Light fog."] = { tag = "GUID:AEBS_fog_0", airTime = 0.90 },
    ["Thick fog."] = { tag = "GUID:AEBS_fog_1", airTime = 0.90 },
    ["Very thick fog."] = { tag = "GUID:AEBS_fog_2", airTime = 0.90 },
    ["^<bzzt>$"] = { tag = "GUID:AEBS_buzz_1", airTime = 1.90 },
    ["^<fzzt>$"] = { tag = "GUID:AEBS_buzz_1", airTime = 1.90 },
    ["^<wzzt>$"] = { tag = "GUID:AEBS_buzz_2", airTime = 1.15 },
    -- Add more entries here for each text pattern
}

-- Lookup tables for wind strength, wind direction, and cloudiness
local windStrengthLookup = {
    ["Mild"] = "AEBS_wind_1",
    ["Moderate"] = "AEBS_wind_2",
    ["Strong"] = "AEBS_wind_3",
    ["Storm-strength"] = "AEBS_wind_4",
}

local windDirLookup = {
    ["South"] = "s",
    ["South-West"] = "sw",
    ["North-West"] = "nw",
    ["Central"] = "c",
    ["North"] = "n",
    ["North-East"] = "ne",
    ["West"] = "w",
    ["East"] = "e",
    ["South-East"] = "se",
}

local cloudinessLookup = {
    ["Clear skies."] = "AEBS_clouds_0",
    ["Some clouds."] = "AEBS_clouds_1",
    ["Heavy cloud cover."] = "AEBS_clouds_2",
    ["Periodical cloudy spells."] = "AEBS_clouds_3",
    ["Periods of heavy cloud."] = "AEBS_clouds_4",
}

-- Override the AddRadioLine function
function RadioBroadCast:AddRadioLine(_rl)
    -- Extract the text from the RadioLine
    
    local text = _rl.getText()

    -- Handle complex pattern for temperature and humidity
    if text:find("average temperature") then
        local prefixTag = ""
        -- Determine the prefix based on the text
        if text:find("Today,") then
            prefixTag = "GUID:AEBS_Pre_today+"
        elseif text:find("Tomorrow,") then
            prefixTag = "GUID:AEBS_Pre_tomorrow+"
        elseif text:find("Day after tomorrow,") then
            prefixTag = "GUID:AEBS_Pre_dayafter+"
        end

        local numbers = {}
        local units = {}
        for number, unit in text:gmatch("(%d+%.?%d*) °([CF])") do
            table.insert(numbers, number)
            table.insert(units, unit)
        end
        -- Extract the humidity percentage without a unit
        local humidity = text:match("Humidity: (%d+)%%")
        if humidity then
            table.insert(numbers, humidity) -- The fourth value is the humidity percentage
        end
        if #numbers == 4 and #units == 3 then
            local tags = {}
            for i = 1, 3 do -- The first three are temperatures
                table.insert(tags, string.format("VoicedFloat_%s+AEBS_%s", numbers[i], units[i]))
            end
            -- The fourth is humidity percentage
            table.insert(tags, string.format("VoicedPercent_%s", numbers[4]))
            local tag = prefixTag .. table.concat(tags, "+")
            -- Create a new RadioLine with the constructed tag
            _rl = RadioLine.new(comp(text), _rl:getR(), _rl:getG(), _rl:getB(), tag)
            _rl:setAirTime(14.92) -- Assuming the air time for this pattern is 14.92
        end
        -- Handle complex pattern for wind and clouds
    elseif text:find("[cdt=9.15](.+) wind from the (.+). Maximum of (%d+%.%d+) (KpH|MpH) expected. (.+)") then
        local windStrengthWord, windDirWord, windSpeed, windSpeedUnit, cloudinessWord = text:match("[cdt=9.15](.+) wind from the (.+). Maximum of (%d+%.%d+) (KpH|MpH) expected. (.+)")
        local windStrengthCode = windStrengthLookup[windStrengthWord] or "AEBS_wind_1"
        local windDirCode = "AEBS_zone_name_" .. (windDirLookup[windDirWord] or "s")
        local windSpeedCode = "VoicedFloat_" .. windSpeed
        local windSpeedUnitCode = windSpeedUnit == "KpH" and "AEBS_KpH" or "AEBS_MpH"
        local cloudinessCode = cloudinessLookup[cloudinessWord] or "AEBS_clouds_0"
    
        local tag = string.format("GUID:%s+AEBS_wind_0_1+%s+AEBS_wind_0_2+%s+%s+AEBS_wind_0_3+%s", windStrengthCode, windDirCode, windSpeedCode, windSpeedUnitCode, cloudinessCode)
        -- Create a new RadioLine with the constructed tag
        _rl = RadioLine.new(comp(text), _rl:getR(), _rl:getG(), _rl:getB(), tag)
        _rl:setAirTime(9.15) -- Assuming the air time for this pattern is 9.15
        end
    else
        -- Find the corresponding data based on the text
        for pattern, data in pairs(radioLineData) do
            if text:find(pattern) then
                -- Set the tag and air time if a match is found
                _rl = RadioLine.new(comp(text), _rl:getR(), _rl:getG(), _rl:getB(), data.tag)
                _rl:setAirTime(data.airTime)
                break
            end
        end
    end

    -- Call the original AddRadioLine function
    originalAddRadioLine(self, _rl)
end