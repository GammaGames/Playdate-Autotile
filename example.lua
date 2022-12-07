import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "autotile"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local seed, cutoff = 0, 0.4
local width, height = 10, 6
local at = Autotile("monochrome-tilemap", width, height)

-- Autotile Helper for Playdate SDK
-- Use this file as your `main.lua`. I also exported a build that has that for you.
-- Up and Down buttons to change the seed, Left and Right to adjust the cutoff

function UpdateNoise()
    math.randomseed(seed)
    -- Source: https://chrisdownie.net/software/2022/03/31/playdate-perlin-noise/
    local repeatValue = 0 -- Don't repeat
    local octaves = 1 -- Combine 5 Perlin values
    local persistence = 0.5 -- Each value is weighed as half as much as the previous

    local noises = gfx.perlinArray(
        at.columns * at.rows,
        math.random(), 1,
        math.random(), 1,
        0, 0,
        repeatValue,
        octaves,
        persistence
    )
    at:setCallback(
        noises, at.columns,
        function(val)
            if val > cutoff then
                return Autotile.STATE.SOLID
            else
                return Autotile.STATE.EMPTY
            end
        end
    )
end

local function initialize()
    at:moveTo(200, 120)
    UpdateNoise()
end

initialize()

function pd.update()
    local updated = false
    gfx.sprite.update()
    pd.timer.updateTimers()

    if pd.buttonJustPressed(pd.kButtonUp) then
        updated = true
        seed += 1
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        updated = true
        seed -= 1
    end

    if pd.buttonJustPressed(pd.kButtonLeft) then
        updated = true
        cutoff -= 0.01
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        updated = true
        cutoff += 0.01
    end

    if updated then
        print("Seed:", seed, "Cutoff:", cutoff)
        UpdateNoise()
    end
end
