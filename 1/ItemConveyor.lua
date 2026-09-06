local M = {}

local buferS = peripheral.wrap("gtceu:wood_crate_0")
local turtle = peripheral.wrap("turtle_0")
local idTurtl = 2
local turtleP = "turtle_0"

rednet.open("back")

local storage = 
{
    "create:item_vault_0",
    "create:item_vault_1",
    "create:item_vault_2"
}
local buferSlots = 
{
    4,  5,   6,
    13, 14, 15, 
    22, 23, 24
}
local craftSlotsTurtle = 
{
    2, 3, 4,
    6, 7, 8,
    10, 11, 12
}
local craftSlotsMachine = 
{
    1, 2, 3,
    4, 5, 6,
    7, 8, 9
}

local storageInfo = { }

local function getInitialInfo()
    storageInfo = { }

    for _, name in ipairs(storage) do
        local p = peripheral.wrap(name)
        table.insert(storageInfo, 
        {
            name = name, 
            object = p,
        }) 
    end
end
getInitialInfo()

local function sizeStorage()
    for _, size in ipairs(storageInfo) do
        
    end
end

function M.pushItemFromStorage(machineName, recipeItems)
    for i, itemName in pairs(recipeItems) do 
        local found = false           
        for _, storage in ipairs(storageInfo) do
            local items = storage.object.list()
                
            for storageSlot, item in pairs(items) do
                if item.name == itemName.name then
                    local count = itemName.count
                    local moved = storage.object.pushItems(machineName, storageSlot, count, i)
                    if moved > 0 then found = true break end
                end
            end
            if found then break end
        end
        if not found then print("Не найден предмет: " .. itemName.name) return end
    end
end

function M.pullItemInStorage(section, machineName)
    if section == "Для черепашки" then
        for _, slot in ipairs(craftSlotsTurtle) do
            for _, storage in ipairs(storageInfo) do
                local moved = storage.object.pullItems(machineName, slot, nil)
                if moved > 0 then break end
            end    
        end
    else
        local Pa = peripheral.wrap(machineName)
        local items = Pa.list()

        for slot, item in pairs(items) do
            for _, storage in ipairs(storageInfo) do
                local moved = storage.object.pullItems(machineName, slot, nil)

                if moved > 0 then
                    break
                end
            end
        end
    end
end

function M.pushItemFromBufer(section, machineName)
    
    for i, storageSlot in ipairs(buferSlots) do
        local item = buferS.getItemDetail(storageSlot)
        
        if item then
            if section == "Для черепашки" then
                buferS.pushItems(machineName, storageSlot, nil, craftSlotsTurtle[i])
            else
                buferS.pushItems(machineName, storageSlot, nil, i)
            end
        end
    end
end

function M.pullItemInBufer(section, machineName)
    if section == "Для черепашки" then
        buferS.pullItems(machineName, 1, nil, 14) 
        return
    else
        local Pa = peripheral.wrap(machineName)
        local items = Pa.list()
        for slot, item in pairs(items) do
            buferS.pullItems(machineName, slot, nil, 14) 
        end
        return
    end
end

return M
