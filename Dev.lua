--[[
    Tempo Hub - dev loader

    Same hub, with the diagnostics turned on. Run this instead of the normal
    loadstring when you need to see what the script is actually doing:

        loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Dev.lua"))()

    What the flag turns on today:
      RH2  -  the Live panel in Shooting. State, last shot, average off, best,
              fill rate, measured latency, the game's own verdict, frame
              hitches, which input path took the shot, and the absolute
              geometry of the shoot button. That last one matters because
              "built" is not the same as "on screen": a button parked off the
              viewport, sized zero, or left invisible all look identical from
              the outside, and that cost four rounds of diagnosis once.

    This is plain on purpose - it is a tool, not a product, and it carries
    nothing that needs hiding. It unlocks no paid feature and changes no
    behaviour; every toggle does exactly what it does on the normal loader.
    It only decides whether the numbers are drawn.
]]

local REPO = "https://raw.githubusercontent.com/teekmill17-droid/TempoHub/refs/heads/main/"

-- Set before the hub loads, because each script reads it once while building
-- its tabs. Setting it afterwards does nothing until the next execution.
getgenv().TempoDev = true

local ok, chunk = pcall(function()
	return game:HttpGet(REPO .. "Loader.lua")
end)
if not ok or type(chunk) ~= "string" or #chunk < 512 then
	warn("[Tempo dev] could not fetch the loader - check your connection")
	return
end

local fn, err = loadstring(chunk)
if not fn then
	warn("[Tempo dev] loader would not compile: " .. tostring(err))
	return
end

fn()
