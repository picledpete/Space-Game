--[[
function love.wheelmoved(x,y)
    if y>0 and scale<10 then
        scale = scale * 1.2
    elseif scale >0.01 and y<0 then
        scale = scale/1.2
    end

    xoffset = winX/2 * (1-scale)
    yoffset = winY/2 * (1-scale)
    cxoffset = cxpos + winX * (1/2 * scale)
    cyoffset = cypos + winY * (1/2 * scale)
end

function love.mousepressed(x,y,button)

    if button == 3 then
        dragMode = 3
        mouseDragging = true
        cxpos = cxpos + x/100
        cypos = cypos + y/100
    end
    if button == 2 and speedMod == 0 then
        npx = (x-xoffset-cxoffset)/scale
        npy = (y-yoffset-cyoffset)/scale
        np = newPlanet(
        7,
        {npx,npy},
        {0,0},
        100,
        "p"
    )
    curPlanId = np.id
        table.insert( objects,np )
    
    if button == 1 then
                curPlanId = 0
        for i,v in ipairs(objects) do
            npx = (x-xoffset-cxoffset)/scale
            npy = (y-yoffset-cyoffset)/scale
            dx = npx -v.pos[1]
            dy = npy -v.pos[2]
            if dx^2+dy^2<v.size^2 then
                curPlanId = v.id
                break
            end
        end

    end
end]]
function love.mousereleased(x,y,button)
    if button == 3 then
        mouseDragging = false
        dragMode = 0
    end
end

function love.mousemoved(x,y,dx,dy)
    if mouseDragging and dragMode == 3 then
    cxpos = cxpos + dx/1
    cypos = cypos + dy/1
    cxoffset = cxpos + winX * (1/2 * scale)
    cyoffset = cypos + winY * (1/2 * scale)
    end
end

function love.keypressed(key)
    if key == "x" then
        speedMod = speedMod + 1
    end
    if key == "a" then
        speedMod = math.abs(speedMod - 1)
    end
    if key == "y" then
        speedMod = speedMod + 10
    end
    if key == "b" then
        speedMod = speedMod - 10
        if speedMod <0 then
            speedMod = 0
        end
    end
    if key == "start" then
        planetMenu = not planetMenu
    end
    if key == "select" then
        focusObject = not focusObject
    end
   --[[ if key == "lshift" then
        shift = true
    end
    if key == "lctrl" then
        ctrl = 1
    end ]]
    if key == "m" then
        cxpos = 0
        cypos = 0
    end
   -- if key == "h" then
   --     saveGame("test1.json")
   -- end
    if key == "r" and scale<10 then
        scale=scale*1.2
    end
    if key == "l" and scale>0.01 then
        scale=scale/1.2
    end
    ckey = key
    keyDown = true
end
function love.keyreleased(key)
    if key == "lshift" then
        shift = false
    end
    if key == "lctrl" then
        ctrl = 0
    end
    keyDown = false

end