local idComp = 1

rednet.open("front")

while true do
    local senderID, command = rednet.receive()

    if command == "craft" then
        turtle.craft()
        rednet.send(idComp, "Done")     
    end
end