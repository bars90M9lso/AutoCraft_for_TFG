break
local monitor = peripheral.find("monitor")
assert(monitor, "Монитор не найден!")
monitor.clear()

local w, h = monitor.getSize() -- Размер 100х52

-- Ввод текста
local function text(x, y, str, color)
    monitor.setCursorPos(x, y)
    monitor.setTextColor(color or colors.white)
    monitor.write(str)
end

-- Заполнение областей
local function fill(x1, y1, x2, y2, color)
    monitor.setBackgroundColor(color)

    for y = y1, y2 do
        monitor.setCursorPos(x1, y)
        monitor.write(string.rep(" ", x2 - x1 + 1))
    end
end

-- Рисование кнопки
local function button(x1, y1, x2, y2, text, color)
    monitor.setBackgroundColor(color)

    for y = y1, y2 do
        monitor.setCursorPos(x1, y)
        monitor.write(string.rep(" ", x2 - x1 + 1))
    end

    local tx = math.floor((x1 + x2 - #text) / 2)
    local ty = math.floor((y1 + y2) / 2)

    monitor.setTextColor(colors.white)
    monitor.setCursorPos(tx, ty)
    monitor.write(text)

    monitor.setBackgroundColor(colors.black)
end

-- Общий интерфейс
local function interface()
    monitor.setBackgroundColor(colors.black)
    monitor.setTextScale(0.5)

    monitor.setTextColor(colors.white)

    -- Правая панель
    fill(w - 10, 0, w, h, colors.green)

    text(w - 4, h - 50, "Меню", colors.white)

    button(w - 10, h - 45, w, h - 40, "AutoCraft", colors.blue)
    button(w - 10, h - 35, w, h - 30, "Energe", colors.orange)
    button(w - 10, h - 25, w, h - 20, "MoonCraft", colors.blue)
    
    button(w - 10, h - 5, w, h, "Pump", colors.blue)    
end


-- Статус
local function status(text)
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)

    monitor.setCursorPos(1, h)
    monitor.write(string.rep(" ", w))

    monitor.setCursorPos(2, h)
    monitor.write(text)
end




interface()
--status("Готово. Нажмите кнопку.")


-- Обработка кликов
while true do
    local event, side, x, y = os.pullEvent("monitor_touch")

    if x >= 3 and x <= 25 and y >= 4 and y <= 8 then
        status("Нажата КНОПКА 1")

    elseif x >= 28 and x <= 50 and y >= 4 and y <= 8 then
        status("Нажата КНОПКА 2")

    elseif x >= 3 and x <= 25 and y >= 10 and y <= 14 then
        status("Нажата КНОПКА 3")

    elseif x >= 28 and x <= 50 and y >= 10 and y <= 14 then
        status("Нажата КНОПКА 4")
end
end
