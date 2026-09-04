--[[
    parsePlaceholders 
    setWorkingEnabled
    isWorkingEnabled
    pullFluid
    setBufferedText
    tanks 
    setSuspendAfterFinish
    pushFluid
]]
local M = {}
local monitor = peripheral.wrap("left")

local CAPASITI = 4000000
local homeTank = { 
                   "gtceu:lv_super_tank_25",
                   "gtceu:lv_super_tank_13",
                   "gtceu:lv_super_tank_26",
                   "gtceu:lv_super_tank_27",
                 }
local FluidTanks = { }


local function getInitialInfo()
    FluidTanks = { home = {}, storage = {} }
    local homeNames = {}

    for _, name in ipairs(homeTank) do
        local p = peripheral.wrap(name)
        table.insert(FluidTanks.home, {
                                        name = name, 
                                        object = p,
                                        fluidsId = nil,  
                                        fluids = " ", 
                                        amount = 0, 
                                        empty = true 
                                      }) 
    end

    for _, tank in ipairs(FluidTanks.home) do
        homeNames[peripheral.getName(tank.object)] = true
    end

    for _, name in ipairs(peripheral.getNames()) do
        local p = peripheral.wrap(name)

        if p and peripheral.getType(name) == "gtceu:lv_super_tank" and not homeNames[name] then
            table.insert(FluidTanks.storage, { 
                                                name = name, 
                                                object = p,
                                                fluidsId = nil, 
                                                fluids = " ", 
                                                amount = 0, 
                                                empty = true  
                                            })
        end
    end
end

local function updateHomeTanks()
    for _, tank in ipairs(FluidTanks.home) do
        local fluids = tank.object.tanks()

        for _, fluid in ipairs(fluids) do
            if fluid.name then
                tank.fluidsId = fluid.name
                tank.fluids = fluid.name:match(":(.+)$")
                tank.amount = fluid.amount
                tank.empty = false
            else
                tank.fluidsId = nil
                tank.fluids = "Пустой"
                tank.amount = 0
                tank.empty = true
            end
            break
        end
    end
end

local function updateStorageTanks()
    for _, tank in ipairs(FluidTanks.storage) do
        local fluids = tank.object.tanks()

        for _, fluid in ipairs(fluids) do
            if fluid.name then
                tank.fluidsId = fluid.name
                tank.fluids = fluid.name:match(":(.+)$")
                tank.amount = fluid.amount
                tank.empty = false
            else
                tank.fluidsId = nil
                tank.fluids = "Пустой"
                tank.amount = 0
                tank.empty = true
            end
            break
        end
    end
end

local function getInfoStorage()
    updateStorageTanks()
    for i, tank in ipairs(FluidTanks.storage) do
        if tank.empty then
            print(i .. ". Пустой")
        else
            print(i .. ". Жидкость: " .. tank.fluids .. " " .. tank.amount)
        end
    end
end

function M.getInfoHomeStorage()
    updateHomeTanks()
    local fluids = {}

    for i, tank in ipairs(FluidTanks.home) do
        if not tank.empty then
            table.insert(fluids, {name = tank.fluids, tag = tank.fluidsId, storage = tank.object})
        end       
    end

    return fluids
end

function M.pullFluidInMachine(fluidRecipe, count, machineName) 
    updateStorageTanks()

    for _, storageTank in ipairs(FluidTanks.storage) do
        if fluidRecipe == storageTank.fluidsId then
            storageTank.object.pushFluid(machineName, count)
            updateStorageTanks()
            return true
        end
    end
    
    print("Нет такой жидкости: " .. fluidRecipe)
    return false
end

function M.pushFluidFromMachine(fluidRes, machineName)
    updateStorageTanks()

    local targetTank = nil

    -- Ищем хранилище с такой же жидкостью
    for _, storageTank in ipairs(FluidTanks.storage) do
        if not storageTank.empty and fluidRes == storageTank.fluidsId then
            targetTank = storageTank
            break
        end
    end
            
    --Если нет нужного хранилища
    if not targetTank then
        for _, storageTank in ipairs(FluidTanks.storage) do
            if storageTank.empty then
                targetTank = storageTank
                break
            end
        end
    end
        
    --Отправка
    if targetTank then
        machineName.pushFluid(targetTank.name)
        print("Перекачка жидкости " .. fluidRes .. " в " .. targetTank.name)
    else
        print("Нет свободного танка для " .. fluidRes)
    end
                            
    updateStorageTanks()
end

local function pullFluidInHome() 
    updateHomeTanks()
    updateStorageTanks()

    print("Введите название житкости")
    local fluid = io.read()

    for _, storageTank in ipairs(FluidTanks.storage) do

        if fluid == storageTank.fluids then

            for _, homeTank in ipairs(FluidTanks.home) do
                if homeTank.empty then
                    storageTank.object.pushFluid(homeTank.name)
                    updateHomeTanks()
                    updateStorageTanks()
                    return
                end
            end
            
            print("Нет свободного домашнего танка")
            return
        end
    end

    print("Нет такой жидкости")
end

local function pushFluidInStorage()
    updateHomeTanks()
    updateStorageTanks()

    for _, homeTank in ipairs(FluidTanks.home) do
        if not homeTank.empty then 
            local targetTank = nil

            -- Ищем хранилище с такой же жидкостью
            for _, storageTank in ipairs(FluidTanks.storage) do
                if not storageTank.empty and homeTank.fluidsId == storageTank.fluidsId then
                    targetTank = storageTank
                    break
                end
            end
            
            --Если нет нужного хранилища
            if not targetTank then
                for _, storageTank in ipairs(FluidTanks.storage) do
                    if storageTank.empty then
                        targetTank = storageTank
                        break
                    end
                end
            end
        
            --Отправка
            if targetTank then
                homeTank.object.pushFluid(targetTank.name)
                print("Перекачка жидкости " .. homeTank.fluids .. " в " .. targetTank.name)
            else
                print("Нет свободного танка для " .. homeTank.fluids)
            end
                    
            updateHomeTanks()
            updateStorageTanks()

        end
    end
end

monitor.clear()
getInitialInfo()

term.redirect(monitor)
monitor.setCursorPos(40, 1)
monitor.write("[ PUSH ]")
monitor.setCursorPos(40, 5)
monitor.write("[ info ]")
monitor.setCursorPos(40, 10)
monitor.write("[ pull ]")
monitor.setCursorPos(1, 1)


--[[
while true do
    
    local event, side, x, y = os.pullEvent("monitor_touch")

    if x >= 40 and x <= 50 and y >= 1 and y <= 3 then
        monitor.clear()
        print("Запуск pushFluid...")
        pushFluidInStorage()
        print("Готово!")
    end

    if x >= 40 and x <= 50 and y >= 5 and y <= 8 then
        monitor.clear()
        getInfoStorage()
        print("Готово!")
    end

    if x >= 40 and x <= 50 and y >= 10 and y <= 12 then
        monitor.clear()
        pullFluidInHome()
        print("Готово!")
    end
end
]]
return M