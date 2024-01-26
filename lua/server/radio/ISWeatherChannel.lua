--***********************************************************
--**                    THE INDIE STONE                    **
--**				  Author: turbotutone				   **
--**               Modded By: Fed_Cap24                    **
--***********************************************************

WeatherChannel = {};
WeatherChannel.channelUUID = "EMRG-711984"; --required for DynamicRadio
WeatherChannel.debugTestAll = false;

local function comp(_str)
    --local radio = getZomboidRadio();
    --return radio:computerize(_str);
    return _str;
end

-- FIXME: ISDebugUtils isn't loaded on the server
ISDebugUtils = ISDebugUtils or {}
function ISDebugUtils.roundNum(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function roundstring(_val)
    return tostring(ISDebugUtils.roundNum(_val,2));
end

local function roundstring100(_val)
    return tostring(ISDebugUtils.roundNum(_val,0));
end

local activity = {
    "anomalous",
    "suspicious",
    "hostile",
    "undead",
    "class 5",
    "class 4",
    "class 3",
    "survivor",
    "vehicle",
    "airborne",
    "friendly",
    "unknown",
    "neutral",
};

local zones = {
    { name = "south", sectors = { 2, 5, 8, 9 } , code="AEBS_zone_name_s"},
    { name = "south-west", sectors = { 1, 3, 6, 7 } , code="AEBS_zone_name_sw"},
    { name = "north-west", sectors = { 10, 14, 15, 18 } , code="AEBS_zone_name_nw"},
    { name = "central", sectors = { 11, 12, 13, 19 } , code="AEBS_zone_name_c"},
    { name = "north", sectors = { 17, 4, 16, 23 } , code="AEBS_zone_name_n"},
    { name = "north-east", sectors = { 21, 25, 29, 31 } , code="AEBS_zone_name_ne"},
    { name = "west", sectors = { 22, 24, 28, 32 } , code="AEBS_zone_name_w"},
    { name = "east", sectors = { 27, 30, 33, 36 } , code="AEBS_zone_name_e"},
    { name = "south-east", sectors = { 20, 26, 34, 35 } , code="AEBS_zone_name_se"},
}

function WeatherChannel.Init()
    activity = {
        getRadioText("AEBS_rand_pre_0"),
        getRadioText("AEBS_rand_pre_1"),
        getRadioText("AEBS_rand_pre_2"),
        --getRadioText("AEBS_rand_pre_3"),
        getRadioText("AEBS_rand_pre_4"),
        getRadioText("AEBS_rand_pre_5"),
        getRadioText("AEBS_rand_pre_6"),
        getRadioText("AEBS_rand_pre_7"),
        getRadioText("AEBS_rand_pre_8"),
        getRadioText("AEBS_rand_pre_9"),
        getRadioText("AEBS_rand_pre_10"),
        getRadioText("AEBS_rand_pre_11"),
        getRadioText("AEBS_rand_pre_12"),
    };

    zones = {
        { name = getRadioText("AEBS_zone_name_s"), sectors = { 2, 5, 8, 9 } , code="AEBS_zone_name_s"},
        { name = getRadioText("AEBS_zone_name_sw"), sectors = { 1, 3, 6, 7 } , code="AEBS_zone_name_sw"},
        { name = getRadioText("AEBS_zone_name_nw"), sectors = { 10, 14, 15, 18 } , code="AEBS_zone_name_nw"},
        { name = getRadioText("AEBS_zone_name_c"), sectors = { 11, 12, 13, 19 } , code="AEBS_zone_name_c"},
        { name = getRadioText("AEBS_zone_name_n"), sectors = { 17, 4, 16, 23 } , code="AEBS_zone_name_n"},
        { name = getRadioText("AEBS_zone_name_ne"), sectors = { 21, 25, 29, 31 } , code="AEBS_zone_name_ne"},
        { name = getRadioText("AEBS_zone_name_w"), sectors = { 22, 24, 28, 32 } , code="AEBS_zone_name_w"},
        { name = getRadioText("AEBS_zone_name_e"), sectors = { 27, 30, 33, 36 } , code="AEBS_zone_name_e"},
        { name = getRadioText("AEBS_zone_name_se"), sectors = { 20, 26, 34, 35 } , code="AEBS_zone_name_se"},
    }
end

--required for DynamicRadio:
function WeatherChannel.OnLoadRadioScripts()
    WeatherChannel.Init();
    table.insert(DynamicRadio.scripts, WeatherChannel);
end

--required for DynamicRadio:
function WeatherChannel.OnEveryHour(_channel, _gametime, _radio)
    local hour = _gametime:getHour();

    if hour<120 then
        local bc = WeatherChannel.CreateBroadcast(_gametime);

        _channel:setAiringBroadcast(bc);
    end
end

Events.OnLoadRadioScripts.Add(WeatherChannel.OnLoadRadioScripts);

function WeatherChannel.CreateBroadcast(_gametime)
    local bc = RadioBroadCast.new("GEN-"..tostring(ZombRand(100000,999999)),-1,-1);

    if WeatherChannel.debugTestAll then
        WeatherChannel.TestAll(_gametime, bc)
    else
        WeatherChannel.FillBroadcast(_gametime, bc);
    end

    return bc;
end

function WeatherChannel.FillBroadcast(_gametime, _bc)
    local hour = _gametime:getHour();
    local c = { r=1.0, g=1.0, b=1.0 };
    local _rl =  RadioLine.new(comp(getRadioText("AEBS_Intro")), c.r, c.g, c.b,"GUID:AEBS_Intro"); -- Time:3.68
    _rl:setAirTime(3.68);
    _bc:AddRadioLine(_rl);

    WeatherChannel.AddFuzz(c, _bc);

    WeatherChannel.AddPowerNotice(c, _bc);

    WeatherChannel.GetRandomString(c, _bc, 100);

    WeatherChannel.AddFuzz(c, _bc);

    WeatherChannel.AddForecasting(c, _bc, hour);

    WeatherChannel.AddFuzz(c, _bc);

    WeatherChannel.GetRandomString(c, _bc, 100);

    if getGameTime():getNightsSurvived() == getGameTime():getHelicopterDay1() then
        WeatherChannel.AddFuzz(c, _bc, 6);
        _rl = RadioLine.new(comp(getRadioText("AEBS_Choppah")), c.r, c.g, c.b,"GUID:AEBS_Choppah"); -- Time:1.96
        _rl:setAirTime(1.96);
        _bc:AddRadioLine(_rl);
    end

    WeatherChannel.AddFuzz(c, _bc);
end

function WeatherChannel.AddFuzz(_c, _bc, _chance)
    local rand = ZombRand(1,_chance or 12);

    if rand==1 or rand==2 then
        local _rl = RadioLine.new("<bzzt>", _c.r, _c.g, _c.b,"GUID:AEBS_buzz_1");
        _rl:setAirTime(1.97);
        _bc:AddRadioLine(_rl);
    elseif rand==3 or rand==4 then
        local _rl = RadioLine.new("<fzzt>", _c.r, _c.g, _c.b,"GUID:AEBS_buzz_1");
        _rl:setAirTime(1.97);
        _bc:AddRadioLine(_rl);
    elseif rand==5 or rand==6 then
        local _rl = RadioLine.new("<wzzt>", _c.r, _c.g, _c.b,"GUID:AEBS_buzz_2");
        _rl:setAirTime(1.26);
        _bc:AddRadioLine(_rl);
    end
end

function WeatherChannel.AddPowerNotice(_c, _bc, _force)
    if _force or (getGameTime():getNightsSurvived() == getSandboxOptions():getElecShutModifier()-2) then
        local _rl = RadioLine.new(comp(getRadioText("AEBS_Power_1")), _c.r, _c.g, _c.b,"GUID:AEBS_Power_1");
        _rl:setAirTime(6.80);
        _bc:AddRadioLine(_rl);
    end
    if _force or (getGameTime():getNightsSurvived() == getSandboxOptions():getElecShutModifier()-1) then
        local _rl = RadioLine.new(comp(getRadioText("AEBS_Power_2")), _c.r, _c.g, _c.b,"GUID:AEBS_Power_2");
        _rl:setAirTime(18.48);
        _bc:AddRadioLine(_rl);
    end
    if _force or (getGameTime():getNightsSurvived() >= getSandboxOptions():getElecShutModifier()) then
        local _rl = RadioLine.new(comp(getRadioText("AEBS_Power_3")), _c.r, _c.g, _c.b,"GUID:AEBS_Power_3");
        _rl:setAirTime(20.81);
        _bc:AddRadioLine(_rl);
    end
end

function WeatherChannel.AddForecasting(_c, _bc, _hour)
    local clim = getClimateManager();
    local forecaster = clim:getClimateForecaster();

    --if _hour<19 then
        -- forecast today and tomorrow
        local forecast = forecaster:getForecast();
        WeatherChannel.AddForecast(_c, _bc, forecast, getRadioText("AEBS_Pre_today"), _hour<12,"AEBS_Pre_today");

        local forecast = forecaster:getForecast(1);
        WeatherChannel.AddForecast(_c, _bc, forecast, getRadioText("AEBS_Pre_tomorrow"), true,"AEBS_Pre_tomorrow");

        WeatherChannel.AddExtremesForecasting(_c, _bc, 2);
    --[[
    else
        -- if after seven forecast for tomorrow and the day after tomorrow
        local forecast = forecaster:getForecast(1);
        WeatherChannel.AddForecast(_c, _bc, forecast, getRadioText("AEBS_Pre_tomorrow"), true);

        local forecast = forecaster:getForecast(2);
        WeatherChannel.AddForecast(_c, _bc, forecast, getRadioText("AEBS_Pre_dayafter"), true);

        WeatherChannel.AddExtremesForecasting(_c, _bc, 3);
    end
    --]]
end

--Here it Sets up the forecast string, Be careful, GUID: should have + signs, for multiple Clips.

function WeatherChannel.AddForecast(_c, _bc, _forecast, _prefix, _doFog,_prefixCode)
    local fx = _prefixCode.."+";
    local s = _prefix;
    aux_s, aux_fx = WeatherChannel.GetForecastString(1, _forecast);
    fx = fx .. aux_fx
    s = s .. aux_s
    local _rl = RadioLine.new(comp(s), _c.r, _c.g, _c.b,"GUID:"..fx); -- Aproximate time: 16.75
    _rl:setAirTime(16.75);
    _bc:AddRadioLine( _rl ); 
    

    s , fx= WeatherChannel.GetForecastString(2, _forecast);
    _rl = RadioLine.new(comp(s), _c.r, _c.g, _c.b,"GUID:"..fx); -- Aproximate time: 11.38
    _rl:setAirTime(11.38);
    _bc:AddRadioLine(_rl);

    if _doFog and _forecast:isHasFog() then
        s , fx= WeatherChannel.GetForecastString(3, _forecast);
        _rl = RadioLine.new(comp(s), _c.r, _c.g, _c.b,"GUID:"..fx); -- Aproximate time: 1.91
        _rl:setAirTime(1.91);
        _bc:AddRadioLine(_rl);
    end

    if _forecast:isWeatherStarts() then
        -- a new weather period starts
        s , fx= WeatherChannel.GetForecastString(4, _forecast);
        _rl = RadioLine.new(comp(s), _c.r, _c.g, _c.b,"GUID:"..fx); -- Aproximate time: 10.00
        _rl:setAirTime(10.00);
        _bc:AddRadioLine(_rl);
    elseif _forecast:getWeatherOverlap() then
        -- a already started weather period overlaps this day
        s , fx= WeatherChannel.GetForecastString(5, _forecast);
        _rl = RadioLine.new(comp(s), _c.r, _c.g, _c.b,"GUID:"..fx); -- Aproximate time: 10.00
        _rl:setAirTime(10.00);
        _bc:AddRadioLine(_rl);
    end
end

function WeatherChannel.GetForecastString(_type, _forecast)
    local fx = "";
    local s = "";
    if _type==1 then
        local v = _forecast:getTemperature();
        local a,b,c = v:getTotalMean(), v:getTotalMin(), v:getTotalMax();
        local d = roundstring100(_forecast:getHumidity():getTotalMean()*100);
        s = string.format(" "..getRadioText("AEBS_temperature"), Temperature.getTemperatureString(a), Temperature.getTemperatureString(b), Temperature.getTemperatureString(c), d);

        local input = string.format("%s",Temperature.getTemperatureString(a))

        local aux = {};
        for value in input:gmatch("%S+") do
            table.insert(aux, value);
        end
        aux[2] = string.sub(aux[2], 2);
        local temp_a = "VoicedFloat_"..aux[1].."+AEBS_"..aux[2];
        input = string.format("%s",Temperature.getTemperatureString(b))
        aux = {};
        for value in input:gmatch("%S+") do
            table.insert(aux, value)
        end
        aux[2] = string.sub(aux[2], 2);
        local temp_b = "VoicedFloat_"..aux[1].."+AEBS_"..aux[2];
        input = string.format("%s",Temperature.getTemperatureString(c))
        aux = {};
        for value in input:gmatch("%S+") do
            table.insert(aux, value);
        end
        aux[2] = string.sub(aux[2], 2);
        local temp_c = "VoicedFloat_"..aux[1].."+AEBS_"..aux[2];

        fx = string.format("AEBS_temperature_1+%s+AEBS_temperature_2+%s+AEBS_temperature_3+%s+AEBS_temperature_4+VoicedPercent_%s",temp_a, temp_b, temp_c, d); -- Aproximate time: 0.99+1.9+1.20+0.63+1.9+1.20+0.77+1.9+1.20+0.73+1.4 = 13.82
        --[[
        elseif _type==2 then
            local v = _forecast:getWindPower();
            local a,b,c = v:getTotalMean(), v:getTotalMin(), v:getTotalMax();
            a = roundstring(ClimateManager.ToKph(a)).." KpH";
            b = roundstring(ClimateManager.ToKph(b)).." KpH";
            c = roundstring(ClimateManager.ToKph(c)).." KpH";
            local d = _forecast:getMeanWindAngleString();
            local e = "Mostly clear sky."
            local cloudsA = _forecast:getCloudiness():getTotalMean();
            local cloudsB = _forecast:getCloudiness():getTotalMax();

            if cloudsA>0.7 then
                e = "Very strong cloud cover.";
            elseif cloudsA>0.4 then
                e = "Medium cloudiness.";
                if cloudsB>0.7 then
                    e = e .. " Periods of strong cloud cover."
                end
            else
                if cloudsB>0.7 then
                    e = e .. " Periods of strong cloud cover."
                elseif cloudsB>0.4 then
                    e = e .. " Periodically medium cloud cover."
                end
            end

            s = string.format("Wind speed mean %s, min %s, max %s, average direction %s... %s", a, b, c, d, e);
        --]]
    elseif _type==2 then
        local v = _forecast:getWindPower();
        local a,b,c = v:getTotalMean(), v:getTotalMin(), v:getTotalMax();
        --a = roundstring(ClimateManager.ToKph(a)).." KpH";
        --b = roundstring(ClimateManager.ToKph(b)).." KpH";
        --c = roundstring(ClimateManager.ToKph(c)).." KpH";
        local wind_speed_code = "";
        if getCore():getOptionDisplayAsCelsius() then
            local aux = roundstring(ClimateManager.ToKph(c));
            c = aux.." KpH";
            wind_speed_code = "VoicedFloat_"..aux.."+AEBS_KpH";
        else
            local aux = roundstring(ClimateManager.ToMph(c));
            c = aux.." MpH";
            wind_speed_code = "VoicedFloat_"..aux.."+AEBS_MpH";
        end
        local d = _forecast:getMeanWindAngleString();
        local dnew = getRadioText("AEBS_zone_name_"..d:lower());
        local wind_dir_code = "";
        if dnew then
            wind_dir_code = "AEBS_zone_name_"..d:lower().."+";
            d = dnew;   
        end
        local e = getRadioText("AEBS_clouds_0");
        local clouds_code = "AEBS_clouds_0";
        local cloudsA = _forecast:getCloudiness():getTotalMean();
        local cloudsB = _forecast:getCloudiness():getTotalMax();

        if cloudsA>0.7 then
            e = getRadioText("AEBS_clouds_2");
            clouds_code = "AEBS_clouds_2";
        elseif cloudsA>0.4 then
            e = getRadioText("AEBS_clouds_1");
            clouds_code = "AEBS_clouds_1";
            if cloudsB>0.7 then
                e = e .. " "..getRadioText("AEBS_clouds_4");
                clouds_code = clouds_code .. "+".."AEBS_clouds_4";
            end
        else
            if cloudsB>0.7 then
                e = e .. " "..getRadioText("AEBS_clouds_4");
                clouds_code = clouds_code .. "+".."AEBS_clouds_4";
            elseif cloudsB>0.4 then
                e = e .. " "..getRadioText("AEBS_clouds_3");
                clouds_code = clouds_code .. "+".."AEBS_clouds_3";
            end
        end

        local w = getRadioText("AEBS_wind_1");
        local wind_strength_code = "AEBS_wind_1";
        if a>0.75 then
            w = getRadioText("AEBS_wind_4");
            wind_strength_code = "AEBS_wind_4";
        elseif a>0.5 then
            w = getRadioText("AEBS_wind_3");
            wind_strength_code = "AEBS_wind_3";
        elseif a>0.25 then
            w = getRadioText("AEBS_wind_2");
            wind_strength_code = "AEBS_wind_2";
        end

        s = string.format(getRadioText("AEBS_wind_0"), w, d, c, e);
        fx = string.format("%s+AEBS_wind_0_1+%sAEBS_wind_0_2+%s+AEBS_wind_0_3+%s",wind_strength_code,wind_dir_code,wind_speed_code,clouds_code); --Expected time: 0.8+0.7+0.75+0.9+1.5+1.20+0.6+2.7 = 9.15
        --s = string.format("Wind speed mean %s, min %s, max %s, average direction %s... %s", a, b, c, d, e);
    elseif _type==3 then
        local v = _forecast:getFogStrength();
        if v==1 then
            s = getRadioText("AEBS_fog_2");
            fx = "AEBS_fog_2";
        elseif v>0.75 then
            s = getRadioText("AEBS_fog_1");
            fx = "AEBS_fog_1";
        else
            s = getRadioText("AEBS_fog_0");
            fx = "AEBS_fog_0";
        end
    elseif _type==4 or _type==5 then
        --local hour = _gametime:getHour();
        if _type==4 then
            --s = string.format(getRadioText("AEBS_weather_0_a"), tostring(ISDebugUtils.roundNum(_forecast:getWeatherStartTime(),0)));
            s = string.format(getRadioText("AEBS_weather_0_a"), WeatherChannel.GetDaySegmentForHour(_forecast:getWeatherStartTime()));
            fx = "AEBS_weather_0_a+"..WeatherChannel.GetDaySegmentCodeForHour(_forecast:getWeatherStartTime())
        else
            local endTime = _forecast:getWeatherEndTime();
            if endTime>=22 then
                s = getRadioText("AEBS_weather_0_b");
                fx = "AEBS_weather_0_b";
            else
                --s = string.format(getRadioText("AEBS_weather_0_c"), tostring(ISDebugUtils.roundNum(endTime,0)));
                s = string.format(getRadioText("AEBS_weather_0_c"), WeatherChannel.GetDaySegmentForHour(endTime));
                fx = "AEBS_weather_0_c+"..WeatherChannel.GetDaySegmentCodeForHour(endTime);
            end

        end

        local t = {};
        local t_fx = {};
        if _forecast:isHasHeavyRain() then
            table.insert(t,getRadioText("AEBS_weather_heavy_rain"));
            table.insert(t_fx,"AEBS_weather_heavy_rain");
        end
        if _forecast:isHasStorm() then
            table.insert(t,getRadioText("AEBS_weather_storm"));
            table.insert(t_fx,"AEBS_weather_storm");
        end
        if _forecast:isHasTropicalStorm() then
            table.insert(t,getRadioText("AEBS_weather_tropical"));
            table.insert(t_fx,"AEBS_weather_tropical");
        end
        if _forecast:isHasBlizzard() then
            table.insert(t,getRadioText("AEBS_weather_blizzard"));
            table.insert(t_fx,"AEBS_weather_blizzard");
        end

        if #t>0 then
            if #t==1 then
                s = s .. getRadioText("AEBS_weather_predicted")..t[1];
                fx = fx .. "+AEBS_weather_predicted+"..t_fx[1];
            else
                s = s .. getRadioText("AEBS_weather_predicted");
                fx = fx .. "+AEBS_weather_predicted"
                for k,v in ipairs(t) do
                    if k<#t then
                        s = s .. v .. (v~=#t-1 and ", " or "");
                    else
                        s = s .. getRadioText("AEBS_weather_and_a") .. v .. "...";
                    end
                end
                for k,v in ipairs(t_fx) do
                    if k<#t_fx then
                        fx = fx .. "+".. v;
                    else
                        fx = fx .. "+AEBS_weather_and_a+" .. v;
                    end
                end
            end
        else
            s = s .. getRadioText("AEBS_weather_light_moderate");
            fx = fx .. "+AEBS_weather_light_moderate"
        end

        if _forecast:isChanceOnSnow() then
            s = s..getRadioText("AEBS_weather_snowfall");
            fx = "+AEBS_weather_snowfall"
        end
    end
    return s,fx;
end

function WeatherChannel.GetDaySegmentForHour(_hour)
    if _hour<=4 or _hour>=23 then
        return getRadioText("AEBS_segment_night");
    elseif _hour>=4 and _hour<8 then
        return getRadioText("AEBS_segment_early_morning");
    elseif _hour>=8 and _hour<12 then
        return getRadioText("AEBS_segment_morning");
    elseif _hour>=12 and _hour<18 then
        return getRadioText("AEBS_segment_afternoon");
    elseif _hour>=18 and _hour<23 then
        return getRadioText("AEBS_segment_evening");
    end
end

function WeatherChannel.GetDaySegmentCodeForHour(_hour)
    if _hour<=4 or _hour>=23 then
        return "AEBS_segment_night";
    elseif _hour>=4 and _hour<8 then
        return "AEBS_segment_early_morning";
    elseif _hour>=8 and _hour<12 then
        return "AEBS_segment_morning";
    elseif _hour>=12 and _hour<18 then
        return "AEBS_segment_afternoon";
    elseif _hour>=18 and _hour<23 then
        return "AEBS_segment_evening";
    end
end

function WeatherChannel.AddExtremesForecasting(_c, _bc, offset, _len)
    local clim = getClimateManager();
    local forecaster = clim:getClimateForecaster();

    for i=offset,offset+(_len or 3) do
        local forecast = forecaster:getForecast(i);

        if forecast and ( forecast:isHasBlizzard() or forecast:isHasTropicalStorm() or forecast:isHasStorm() ) then
            local type = getRadioText("AEBS_weather_storm_C");
            local weather_code = "AEBS_weather_storm_C";
            if forecast:isHasTropicalStorm() then
                type = getRadioText("AEBS_weather_tropical_C");
                weather_code = "AEBS_weather_tropical_C";
            elseif forecast:isHasBlizzard() then
                type = getRadioText("AEBS_weather_blizzard_C");
                weather_code = "AEBS_weather_blizzard_C";
            end

            local s = string.format(getRadioText("AEBS_weather_warning"), type, tostring(i));
            local fx = "AEBS_weather_warning_1+"..weather_code.."+AEBS_weather_warning_2+VoicedNumber_"..tostring(i).."+AEBS_weather_warning_3"
            local _rl = RadioLine.new(comp(s), _c.r, _c.g, _c.b,"GUID:"..fx); --Too lazy to calculate: 10.00 seconds
            _rl:setAirTime(10.00);
            _bc:AddRadioLine( _rl );
            return;
        end
    end
end

function WeatherChannel.GetRandomString(_c, _bc, _doItThreshold, _forceRand)
    local rand = ZombRand(1,100);

    if _doItThreshold and rand>_doItThreshold then
        return;
    end

    local rand = _forceRand or ZombRand(1,10000);

    local s = nil;
    local fx = nil;
    if rand<500 then
        local zone = zones[ZombRand(1,#zones)];
        s = string.format(getRadioText("AEBS_random_0"), zone.name, zone.sectors[1], zone.sectors[2], zone.sectors[3], zone.sectors[4]);
        fx = "AEBS_random_0_1+"..zone.code.."+AEBS_random_0_2+VoicedNumber_"..tostring(zone.sectors[1]).."+VoicedNumber_"..tostring(zone.sectors[2]).."+VoicedNumber_"..tostring(zone.sectors[3]).."+AEBS_random_0_3+VoicedNumber_"..tostring(zone.sectors[4]);
    elseif rand<1000 then
        local i=ZombRand(1,36);
        s = string.format(getRadioText("AEBS_random_1"), i );
        fx = "AEBS_random_1+VoicedNumber_"..tostring(i).."+AEBS_buzz_2";
    elseif rand<1500 then
        local i = ZombRand(1,1000);
        s = string.format(getRadioText("AEBS_random_2"), i );
        fx = "AEBS_random_2_1+VoicedNumber_"..tostring(i).."+AEBS_random_2_2";
    elseif rand<2000 then
        local act_num=ZombRand(1,#activity);
        local sect=ZombRand(1,36);
        s = string.format(getRadioText("AEBS_random_3"), activity[act_num], sect );
        if act_num >= 3 then
            act_num = act_num + 1; --Activity number 3 is disabled
        end
        fx = "AEBS_rand_pre_"..tostring(act_num).."+AEBS_random_3+VoicedNumber_"..tostring(sect).."+AEBS_buzz_2"; 
    --elseif rand==9000 then
    --    s = getRadioText("AEBS_random_4");
    elseif rand>=9000 and rand<9002 then
        s = getRadioText("AEBS_random_5");
        fx = "AEBS_random_5";
    elseif rand>=9002 and rand<9004 then
        s = getRadioText("AEBS_random_6");
        fx = "AEBS_random_6";
    elseif rand>=9004 and rand<9006 then
        s = getRadioText("AEBS_random_7");
        fx = "AEBS_random_7";
    elseif rand>=9006 and rand<9008 then
        s = getRadioText("AEBS_random_8");
        fx = "AEBS_random_8";
    elseif rand>=9008 and rand<9010 then
        s = getRadioText("AEBS_random_9");
        fx = "AEBS_random_9";
    elseif rand>=9010 and rand<9012 then
        s = getRadioText("AEBS_random_10");
        fx = "AEBS_random_10";
    elseif rand>=9012 and rand<9014 then
        s = getRadioText("AEBS_random_11");
        fx = "AEBS_random_11";
    elseif rand>=9014 and rand<9016 then
        s = getRadioText("AEBS_random_12");
        fx = "AEBS_random_12";
    elseif rand>=9016 and rand<9018 then
        s = getRadioText("AEBS_random_13");
        fx = "AEBS_random_13";
    end

    if s~=nil then
        --local radio = getZomboidRadio();
        --s = radio:scrambleString(s, 20, false, nil);
        local c = {r=0.5,g=0.5,b=0.5};
        local _rl = RadioLine.new(s, c.r, c.g, c.b,"GUID:"..fx); --Aproximate time: 7 (didn't calculate, I'm lazy)
        _rl:setAirTime(7.00);
        _bc:AddRadioLine(_rl);
    end
end


function WeatherChannel.TestAll(_gametime, _bc)
    local clim = getClimateManager();
    local forecaster = clim:getClimateForecaster();

    local c = { r=1.0, g=1.0, b=1.0 };
    local _rl =  RadioLine.new(comp(getRadioText("AEBS_Intro")), c.r, c.g, c.b,"GUID:AEBS_Intro");
    _rl:setAirTime(4.70);
    _bc:AddRadioLine(_rl);
    WeatherChannel.AddPowerNotice(c, _bc, true);

    local forecast = forecaster:getForecast();
    WeatherChannel.AddForecast(c, _bc, forecast, getRadioText("AEBS_Pre_today"), true, "AEBS_Pre_today");

    local forecast = forecaster:getForecast(1);
    WeatherChannel.AddForecast(c, _bc, forecast, getRadioText("AEBS_Pre_tomorrow"), true, "AEBS_Pre_tomorrow");

    local forecast = forecaster:getForecast(2);
    WeatherChannel.AddForecast(c, _bc, forecast, getRadioText("AEBS_Pre_dayafter"), true, "AEBS_Pre_dayafter");

    WeatherChannel.AddExtremesForecasting(c, _bc, 3, 20);

    WeatherChannel.GetRandomString(c, _bc, 100, 0);
    WeatherChannel.GetRandomString(c, _bc, 100, 500);
    WeatherChannel.GetRandomString(c, _bc, 100, 1000);
    WeatherChannel.GetRandomString(c, _bc, 100, 1500);
    WeatherChannel.GetRandomString(c, _bc, 100, 9000);
    WeatherChannel.GetRandomString(c, _bc, 100, 9001);
    WeatherChannel.GetRandomString(c, _bc, 100, 9002);
    WeatherChannel.GetRandomString(c, _bc, 100, 9003);
    WeatherChannel.GetRandomString(c, _bc, 100, 9004);
    WeatherChannel.GetRandomString(c, _bc, 100, 9005);
    WeatherChannel.GetRandomString(c, _bc, 100, 9006);
    WeatherChannel.GetRandomString(c, _bc, 100, 9007);
    WeatherChannel.GetRandomString(c, _bc, 100, 9008);
    WeatherChannel.GetRandomString(c, _bc, 100, 9009);
    WeatherChannel.GetRandomString(c, _bc, 100, 9010);

    _rl = RadioLine.new(comp(getRadioText("AEBS_Choppah")), c.r, c.g, c.b,"GUID:AEBS_Choppah");
    _rl:setAirTime(1.96);
    _bc:AddRadioLine(_rl);
    WeatherChannel.AddFuzz(c, _bc, 6);
end

