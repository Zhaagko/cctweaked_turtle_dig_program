-- variable declaration

-- available program names: f - move only forward,
--  fb - move and dig forward, then move to the left and dig back to the start
local availableProgramNames = {"f", "fb"}

-- default path length
local digPathLen = 50

-- default value of programName is "f"
local programName = "f"

-- list of minecraft trash blocks names
local trashBlockNames = {
    "minecraft:granite",
    "minecraft:diorite",
    "minecraft:andesite",
    "minecraft:dirt",
    "minecraft:cobblestone",
    "minecraft:gravel",
    "minecraft:deepslate",
    "minecraft:cobbled_deepslate",
    "minecraft:tuff",
    "minecraft:smooth_basalt",
}

local function digBlocksInForward()
    -- dig blocks in forward of turtle
    local tries = 16
  
    while turtle.detect() and tries > 0 do
        turtle.dig()
        tries = tries - 1
    end
    
    if tries == 0 then
        error("There are a some obstacle on the path", 0)
    end
end

local function digBlocks()
    digBlocksInForward()
    turtle.digUp()
    turtle.digDown()
end

local function isValueInTable(expectedValue, table)
    for k, v in ipairs(table) do
        if v == expectedValue then
            return true
        end
    end
    return false
end

local function isTrashBlock(blockName)
    return isValueInTable(blockName, trashBlockNames)
end

local function clearTurtleInventory()
    local originalSlot = turtle.getSelectedSlot()
    for slot = 1, 16 do
        if turtle.select(slot) then
            local item = turtle.getItemDetail(slot)
            if item then
                print(string.format("Item %s detected in slot %d", item["name"], slot), "\n")
                if isTrashBlock(item["name"]) then
                    turtle.drop()
                end
            end
        end
    end
    turtle.select(originalSlot)
end

local function excavateInForward(pathLen)
    local travelledLen = 0
    while travelledLen < pathLen do
        travelledLen = travelledLen + 1
        digBlocks()
        turtle.forward()
        if travelledLen % 90 == 0 then
            clearTurtleInventory()
        end
    end
    clearTurtleInventory()
end

local function excavateForwardAndReturnBack(pathLen)
    excavateInForward(pathLen)
    turtle.turnLeft()
    excavateInForward(1)
    turtle.turnLeft()
    excavateInForward(pathLen)
end

local function getTurtleProgramByName(progName)
    if progName == "f" then
        return excavateInForward
        elseif progName == "fb" then
            return excavateForwardAndReturnBack
    end
end

local function validateFuelLevelByProgramName(progName, pathLen)
    local requiredFuelLevel = 0
    local currentFuelLevel = turtle.getFuelLevel()
    if progName == "fow" then
        requiredFuelLevel = pathLen
        elseif progName == "fowb" then
            requiredFuelLevel = pathLen * 2
    end
    if requiredFuelLevel > currentFuelLevel then
        error("For this program required %d fuel. %d exists", requiredFuelLevel, currentFuelLevel)
    end
end

-- here is start of programm
if #arg then
    if arg[1] then
        digPathLen = tonumber(arg[1])
    end
    if arg[2] then
        local argProgName = tostring(arg[2])
        if isValueInTable(argProgName, availableProgramNames) then
            programName = argProgName
        end
    end
end


validateFuelLevelByProgramName(programName, digPathLen)
local turtleProgram = getTurtleProgramByName(programName)

-- run choised program
turtleProgram(digPathLen)

print("Success")
