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
local ItemConveyor = require("ItemConveyor")

local monitor = peripheral.wrap("left")
local recipeFile = "recipes"

local buferS = peripheral.wrap("gtceu:wood_crate_0")

local idTurtl = 2
rednet.open("back")

local storage = {
                    "create:item_vault_0",
                    "create:item_vault_1",
                    "create:item_vault_2"
                }
local storageInfo = { }

local blockM = { }
local turtle = { }
local lvM = { }
local mvM = { }
local hvM = { }

local function getInitialInfo()
    storageInfo = { }
    turtle = { }
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
        print(name, peripheral.getType(name))
        if p and peripheral.getType(name) == "turtle" then
            table.insert(turtle, { 
                                                name = name, 
                                                object = p,

                                            })
        end

        if p and string.match(peripheral.getType(name), "^gtceu:lv_") then
            table.insert(lvM, { 
                                                name = name, 
                                                object = p,

                                            })
        end

        if p and string.match(peripheral.getType(name), "^gtceu:mv_") then
            table.insert(mvM, { 
                                                name = name, 
                                                object = p,

                                            })
        end

        if p and string.match(peripheral.getType(name), "^gtceu:hv_") then
            table.insert(hvM, { 
                                                name = name, 
                                                object = p,

                                            })
        end
    end
end

local function saveRecipe(section, name, tag, machineName, items)
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

local function preliminarySavingRecipe(section)
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
    local recipe = {}
    if section == "Для машинок" then
        recipe = {items = {}, fluids = {}}
    end

    for i, storageSlot in ipairs(slots) do
        local item = buferS.getItemDetail(storageSlot)
        
        if item then
            if section == "Для черепашки" then
                recipe[craftSlots[i]] = {name = item.name,  count = item.count}
            else
                recipe.items[i] = {name = item.name,  count = item.count}
            end
        end
    end
    return recipe
end

local function addCraftM()

    local P = "gtceu:mv_chemical_reactor_1"
    local tag = nil
    local machineName = {}

    print("Положите рецепт и назовите рецепта: ")
    term.redirect(term.native())
    local recipeName = read()
    
    if recipeName == "" then
        print("Название не введено")
        return
    end

    print("В крафте используется житкость? y/n: ")
    local fluidFlag = read()
    local fluidCount = 0
    local fluidStorage = {}
    local fluidRecipe = {}

    if fluidFlag == "y" then
        local fluids = FluidPump.getInfoHomeStorage()
        for i, fluid in ipairs(fluids) do
            print(fluid.name)
            print("Количесво житкости? ")
            fluidCount = tonumber(read())
            fluidStorage[i] = fluid.storage
            fluidRecipe[i] = {name = fluid.tag, count = fluidCount}
        end
    end
    
    print("Выбери тип машинки:")
    print("1 - LV")
    print("2 - MV")
    print("3 - HV")

    local choice = tonumber(read())

    local machineType

    if choice == 1 then
        for i, machine  in ipairs(lvM) do
            print(i, " ", machine.name, " ", machine.object)

            --machineName = {name = name. , object = p}
        end
    elseif choice == 2 then
        
        --machineName =
    elseif choice == 3 then
        
        --machineName =
    end

    term.redirect(monitor)
    local recipe = preliminarySavingRecipe("Для машинок")

    ItemConveyor.pushItemFromBufer("Для машинок", P)
    if fluidFlag == "y" then
        for i, fluids in ipairs(fluidRecipe) do
            recipe.fluids[i] = {name = fluids.name,  count = fluids.count}
            fluidStorage[i].pushFluid(P, fluids.count)
        end
    end

    sleep(0.1)
    local Pa = peripheral.wrap(P)
    while Pa.getProgress() > 0 do
        local progress = Pa.getProgress()
        local maxProgress = Pa.getMaxProgress()

        print("Прогресс: " .. progress .. "/" .. maxProgress)
        sleep(0.1)
    end
    sleep(0.1)

    ItemConveyor.pullItemInBufer("Для машинок", P)
    ItemConveyor.pullItemInStorage("Для машинок", P)
    if fluidFlag == "y" then
        local tanks = Pa.tanks()

        for i, tank in pairs(tanks) do
            print(tank.name) 
            FluidPump.pushFluidFromMachine(tank.name, Pa)
        end
    end

    local res = buferS.getItemDetail(14)
    if res then res = res.name end
    
    print("Сохранить рецепт? (y/n)")
    term.redirect(term.native())
    local isSave = read()
    term.redirect(monitor)

    if isSave == "y" then
        saveRecipe("Для машинок", recipeName, res, machineName, recipe)
        print("Рецепт сохранён: " .. recipeName)
    else
        return
    end
end

local function addCraftV()
    
    print("Положите рецепт и назовите рецепта: ")
    term.redirect(term.native())
    local recipeName = read()
    term.redirect(monitor)

    if recipeName == "" then
        print("Название не введено")
        return
    end

    local recipe = preliminarySavingRecipe("Для черепашки")
    ItemConveyor.pushItemFromBufer("Для черепашки", "turtle_0")

    rednet.send(idTurtl, "craft")
    local senderID, command = rednet.receive()
    
    if command == "Done" then
        local section = recipe.section

        ItemConveyor.pullItemInStorage("Для черепашки", "turtle_0")
        ItemConveyor.pullItemInBufer("Для черепашки", "turtle_0")

        local res = buferS.getItemDetail(14)
        if res then res = res.name end

        write("Сохранить рецепт? (y/n)")
        term.redirect(term.native())
        local isSave = read()
        term.redirect(monitor)

        if isSave == "y" then
            saveRecipe("Для черепашки", recipeName, res, recipe)
            print("Рецепт сохранён: " .. recipeName)
        else
            return
        end
    end
end

local function CraftRes(recipe)
    local turtleP = "turtle_0"
    local P = "gtceu:mv_chemical_reactor_1"

    local section = recipe.section
    local recipeName = recipe.data.name
    local recipeItems = recipe.data.recipe.items
    local recipeFluids = recipe.data.recipe.fluids

    if section == "Для черепашки" then
        ItemConveyor.pushItemFromStorage(section, turtleP, recipeItems)

        rednet.send(idTurtl, "craft")
        local senderID, command = rednet.receive()
        
        if command == "Done" then
            ItemConveyor.pullItemInStorage(section, turtleP)
            ItemConveyor.pullItemInBufer(section, turtleP)
        end

    elseif section == "Для машинок" then
        ItemConveyor.pushItemFromStorage(P, recipeItems)
        if #recipeFluids > 0 then
            for _, fluids in pairs(recipeFluids) do
                FluidPump.pullFluidInMachine(fluids.name, fluids.count, P)
            end
        end
        
        sleep(0.1)
        local Pa = peripheral.wrap(P)
        while Pa.getProgress() > 0 do
            local progress = Pa.getProgress()
            local maxProgress = Pa.getMaxProgress()

            print("Прогресс: " .. progress .. "/" .. maxProgress)
            sleep(0.1)
        end

        ItemConveyor.pullItemInBufer("Для машинок", P)
        ItemConveyor.pullItemInStorage("Для машинок", P)
        if #recipeFluids > 0 then
            local tanks = Pa.tanks()

            for i, tank in pairs(tanks) do
                print(tank.name) 
                FluidPump.pushFluidFromMachine(tank.name, Pa)
            end
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

    monitor.setCursorPos(40, 10)
    monitor.write("[ craftM ]")

    return recipeButtons
end

term.redirect(monitor)
local recipeButtons = drawMenu()
getInitialInfo()
FluidPump.getInitialInfo()
ItemConveyor.getInitialInfo()

while true do
    local event, side, x, y = os.pullEvent("monitor_touch")

    -- Нажатие на рецепт слева
    if recipeButtons[y] and x < 40 then

        local selectedRecipe = recipeButtons[y]

        monitor.clear()

        monitor.setCursorPos(1, 1)
        monitor.write("Крафт: " .. selectedRecipe.name)

        CraftRes(selectedRecipe)

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

    -- craftM
    if x >= 40 and x <= 52 and y >= 10 and y <= 12 then

        monitor.clear()
        addCraftM()
        print("Готово!")
        sleep(1)
        drawMenu()

    end
end