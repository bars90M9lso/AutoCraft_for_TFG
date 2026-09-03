local buferS = peripheral.wrap("gtceu:wood_crate_0")
local turtleP = "turtle_0"
local idComp = 1

rednet.open("front")

while true do
    local senderID, command = rednet.receive()

    if command == "AddCraft" then
        turtle.craft()
        buferS.pullItems(turtleP, 1, 1, 14)
        rednet.send(idComp, "Done") 
    end
    
end
