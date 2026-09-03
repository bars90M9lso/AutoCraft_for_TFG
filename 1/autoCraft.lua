--[[
for create:item_vault
    size
    getItemDetail
    list
    getItemLimit
    pullItems
    pushItems

    
local methods = peripheral.getMethods("create:item_vault_0")
for i, method in ipairs(methods) do
    print(i .. ": " .. method)
end
]]
local FluidPump = require("FluidPump")
local monitor = peripheral.wrap("left")
local recipeFile = "recipes"

local buferS = peripheral.wrap("gtceu:wood_crate_0")

local turtle = peripheral.wrap("turtle_0")
local idTurtl = 2
rednet.open("back")

local storage = {
                    "create:item_vault_0",
                    "create:item_vault_1",
                    "create:item_vault_2"
                }
local storageInfo = { }

local blockM = { }
local lvM = { }
local mvM = { }
local hvM = { }

local function getInitialInfo()
    storageInfo = { }
    lvM = { }
    mvM = { }
    hvM = { }

    for _, name in ipairs(storage) do
        local p = peripheral.wrap(name)
        table.insert(storageInfo, {
                                        name = name, 
                                        object = p,
                                       }) 
    end

    for _, name in ipairs(peripheral.getNames()) do
        local p = peripheral.wrap(name)

        if p and peripheral.getType(name) == "gtceu:lv" then
            table.insert(lvM, { 
                                                name = name, 
                                                object = p,

                                            })
        end

        if p and peripheral.getType(name) == "gtceu:mv" then
            table.insert(mvM, { 
                                                name = name, 
                                                object = p,

                                            })
        end

        if p and peripheral.getType(name) == "gtceu:hv" then
            table.insert(hvM, { 
                                                name = name, 
                                                object = p,

                                            })
        end
    end
end

local function saveRecipe(section, name, tag, items)
    local recipes = {}

    if fs.exists(recipeFile) then
        local file = fs.open(recipeFile, "r")
        recipes = textutils.unserialize(file.readAll()) or {}
        file.close()
    end

    if not recipes[section] then
        recipes[section] = {}
    end

    recipes[section][name] = 
    {
        name = tag,
        recipe = items
    }

    local file = fs.open(recipeFile, "w")
    file.write(textutils.serialize(recipes))
    file.close()
end

local function loadRecipes()
    if not fs.exists(recipeFile) then
        return {}
    end

    local file = fs.open(recipeFile, "r")
    local recipes = textutils.unserialize(file.readAll())
    file.close()

    return recipes or {}
end

local function sizeStorage()
    for _, size in ipairs(storageInfo) do
        print(size.freeSize)
    end
end

local function addCraftM()
    local slots = {
                   4,  5,   6,
                   13, 14, 15, 
                   22, 23, 24
                  }
    local P = "gtceu:lv_assembler_0"
    local tag = nil

    term.redirect(term.native())
    write("Название результата: ")
    local recipeName = read()

    write("В крафте используется житкость? y/n: ")
    local fluidFlag = read()
    local fluidCount = 0


    if fluidFlag == "y" then
        write("количесво житкости? y/n: ")
        fluidCount = read()
    end
    
    if recipeName == "" then
        print("Название не введено")
        return
    end

    term.redirect(monitor)
    local recipe = {}

    for i, storageSlot in ipairs(slots) do
        local item = buferS.getItemDetail(storageSlot)
        
        if item then
            recipe[i] = {name = item.name,  count = item.count}
            buferS.pushItems(P, storageSlot, nil, i)
        end
    end
    sleep(0.2)
    local Pa = peripheral.wrap(P)
    while Pa.getProgress() > 0 do
        local progress = Pa.getProgress()
        local maxProgress = Pa.getMaxProgress()

        print("Прогресс: " .. progress .. "/" .. maxProgress)
        sleep(0.5)
    end
    buferS.pullItems(P, 1, nil, 14)
    
    local res = buferS.getItemDetail(14)
    if res then tag = res.name end

    saveRecipe("Для машинок", recipeName, tag, recipe)
    print("Рецепт сохранён: " .. recipeName)
end

local function addCraftV()
    local slots = {
                   4,  5,   6,
                   13, 14, 15, 
                   22, 23, 24
                  }
    local craftSlots = {
                        2, 3, 4,
                        6, 7, 8,
                        10, 11, 12
                       }
    local turtleP = "turtle_0"
    local recipe = {}
    local tag = nil

    term.redirect(term.native())
    write("Название результата: ")
    local recipeName = read()
    term.redirect(monitor)

    if recipeName == "" then
        print("Название не введено")
        return
    end

    for i, storageSlot in ipairs(slots) do
        local item = buferS.getItemDetail(storageSlot)
        
        if item then
            recipe[craftSlots[i]] = {name = item.name,  count = item.count}
            buferS.pushItems(turtleP, storageSlot, nil, craftSlots[i])
        end
    end

    rednet.send(idTurtl, "AddCraft")
    local senderID, command = rednet.receive()
    
    if command == "Done" then

        for _, slot in ipairs(craftSlots) do
            for _, storage in ipairs(storageInfo) do
                local moved = storage.object.pullItems(turtleP, slot, nil)
                
                if moved > 0 then
                    break
                end
            end
            
        end

        local res = buferS.getItemDetail(14)
        if res then tag = res.name end

        saveRecipe("Для черепашки", recipeName, tag, recipe)
        print("Рецепт сохранён: " .. recipeName)
    end
end

local function CraftV(recipe)
    local craftSlotsV = 
    {
        2, 3, 4,
        6, 7, 8,
        10, 11, 12
    }
    local craftSlotsM = 
    {
        1, 2, 3,
        4, 5, 6,
        7, 8, 9
    }
    local turtleP = "turtle_0"
    local P = "gtceu:lv_assembler_0"

    local section = recipe.section
    local recipeName = recipe.data.name
    local recipe = recipe.data.recipe

    if section == "Для черепашки" then
        for craftSlot, itemName in pairs(recipe) do
            local found = false
            
            for _, storage in ipairs(storageInfo) do
                local items = storage.object.list()
                
                for storageSlot, item in pairs(items) do
                    if item.name == itemName.name then
                        local count = itemName.count
                        local moved = storage.object.pushItems(turtleP, storageSlot, count, craftSlot)
                        if moved > 0 then found = true break end
                    end
                end

                if found then break end
            end

            if not found then print("Не найден предмет: " .. itemName.name) return end
        end

        rednet.send(idTurtl, "AddCraft")
        local senderID, command = rednet.receive()
        
        if command == "Done" then

            for _, slot in ipairs(craftSlotsV) do
                for _, storage in ipairs(storageInfo) do
                    local moved = storage.object.pullItems(turtleP, slot, nil)
                    
                    if moved > 0 then
                        break
                    end
                end
                
            end
        end

    elseif section == "Для машинок" then
        for craftSlot, itemName in pairs(recipe) do
            local found = false
            
            for _, storage in ipairs(storageInfo) do
                local items = storage.object.list()
                
                for storageSlot, item in pairs(items) do
                    if item.name == itemName.name then
                        local count = itemName.count
                        local moved = storage.object.pushItems(P, storageSlot, count, craftSlot)
                        if moved > 0 then found = true break end
                    end
                end

                if found then break end
            end

            if not found then print("Не найден предмет: " .. itemName.name) return end
        end
        sleep(0.2)
        local Pa = peripheral.wrap(P)
        while Pa.getProgress() > 0 do
            local progress = Pa.getProgress()
            local maxProgress = Pa.getMaxProgress()

            print("Прогресс: " .. progress .. "/" .. maxProgress)
            sleep(0.1)
        end
        local items = Pa.list()
        for slot, item in pairs(items) do
            local moved = buferS.pullItems(P, slot, nil, 13) 
            print("Перемещено: " .. moved)
        end
    end
end

local function drawMenu()
    monitor.clear()

    local recipes = loadRecipes()
    local recipeButtons = {}

    local y = 1

    for sectionName, sectionRecipes in pairs(recipes) do

        -- Заголовок раздела
        monitor.setCursorPos(1, y)
        monitor.write("[" .. sectionName .. "]")

        y = y + 1

        -- Рецепты внутри раздела
        for recipeName, recipeData in pairs(sectionRecipes) do

            monitor.setCursorPos(3, y)

            local displayName = recipeName

            if #displayName > 35 then
                displayName = displayName:sub(1, 35)
            end

            monitor.write(displayName)

            -- Запоминаем рецепт
            recipeButtons[y] = {
                section = sectionName,
                name = recipeName,
                data = recipeData
            }

            y = y + 1

            if y > 50 then
                break
            end
        end

        -- Пустая строка между разделами
        y = y + 1

        if y > 50 then
            break
        end
    end

    -- Кнопки справа
    monitor.setCursorPos(40, 1)
    monitor.write("[ addCraftV ]")

    monitor.setCursorPos(40, 5)
    monitor.write("[ sizeS ]")

    monitor.setCursorPos(40, 10)
    monitor.write("[ craftM ]")

    return recipeButtons
end

term.redirect(monitor)
local recipeButtons = drawMenu()
getInitialInfo()

while true do
    local event, side, x, y = os.pullEvent("monitor_touch")

    -- Нажатие на рецепт слева
    if recipeButtons[y] and x < 40 then

        local selectedRecipe = recipeButtons[y]

        monitor.clear()

        monitor.setCursorPos(1, 1)
        monitor.write("Крафт: " .. selectedRecipe.name)

        CraftV(selectedRecipe)

        sleep(1)

        recipeButtons = drawMenu()
    end

    -- addCraftV
    if x >= 40 and x <= 52 and y >= 1 and y <= 3 then
        monitor.clear()

        addCraftV()

        print("Готово!")

        sleep(1)

        drawMenu()
    end

    -- sizeStorage
    if x >= 40 and x <= 52 and y >= 5 and y <= 8 then
        monitor.clear()

        sizeStorage()

        print("Готово!")

        sleep(1)

        drawMenu()
    end

    -- craftM
    if x >= 40 and x <= 52 and y >= 10 and y <= 12 then

        monitor.clear()
        addCraftM()
        print("Готово!")
        sleep(1)
        drawMenu()

    end
end