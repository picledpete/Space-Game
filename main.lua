require("functions")
local sqrt = math.sqrt
function love.load()
    love.window.setMode(800,600,{vsync=1})
    G = 0.05
    nId = 1
    dt1 = 0
    curPlanet = {}
    mouseDragging = false
    keyDown = false
    ckey = ""
    speedMod = 0
    dragMode = 0
    winX = 800
    winY = 600
    rotSpeed = 3
    cxpos = 0
    cypos = 0
    ctrl = 0
    shift = false
    scale = 1/2
    xoffset = winX/2 * (1-scale)
    yoffset = winY/2 * (1-scale)
    planetMenu = false
    curPlanId = 0
    gravMult = 0.9
    --sunX,sunY = winX/2,winY/2
    cx,cy = 100,100
    incr = 0
    --[[bh1 = newPlanet(
    3,{-650,-100},{0,0},100000000,"s"
    )]]
    cxoffset = cxpos + winX * (1/2 * scale)
    cyoffset = cypos + winY * (1/2 * scale)
    objects = {

    }

    --loadGame("test1.json")
    randomStart(115,16)
end

function love.update(dt)
    dt1 = dt
    local collisions = {}
    for i=1,#objects-1 do
        for j=i+1,#objects do
            local res = planetUpdate(i,j)
            objects[i] = res[1]
            objects[j] = res[2]
        end
    end
    for i,v in ipairs(objects) do
        objects[i].pos[1] = objects[i].pos[1] + objects[i].xvel*dt *speedMod
        objects[i].pos[2] = objects[i].pos[2] + objects[i].yvel*dt *speedMod
    end

    for i,v in ipairs(objects) do
        for i2=i+1,#objects do
            local v2 = objects[i2]
            if v.id ~= v2.id then
            local dx = v2.pos[1] - v.pos[1]
            local dy = v2.pos[2] - v.pos[2]
            local d = dx^2 + dy^2
            local rsum = v.size + v2.size
            if d<rsum^2 then
            
                if v.mass > v2.mass then
                    table.insert(collisions,{v,v2})
                else 
                    table.insert(collisions,{v2,v})
                end
                
            end


            end
        end
        local ctable = getObjectFromId(curPlanId)
            if curPlanId ~= 0 and planetMenu then
        local rotV = 0
        local speed = math.sqrt(objects[ctable].xvel^2 + objects[ctable].yvel^2)
        if speed ~= 0 then
        local movSpeed = 0
                if love.keyboard.isDown("up") and shift then
                    movSpeed = 0.03 -ctrl*0.02
                elseif love.keyboard.isDown("down") and shift then
                    movSpeed = -0.03 +ctrl*0.02
                elseif love.keyboard.isDown("down") then
                    movSpeed = -1/2
                elseif love.keyboard.isDown("up") then
                    movSpeed = 1/2
                else
                    movSpeed = 0
                end

                
                dirX = objects[ctable].xvel/speed
                dirY = objects[ctable].yvel/speed
                objects[ctable].xvel = objects[ctable].xvel + dirX*movSpeed
                objects[ctable].yvel = objects[ctable].yvel + dirY*movSpeed
            elseif love.keyboard.isDown("up") or love.keyboard.isDown("down") then
                objects[ctable].xvel = objects[ctable].xvel + 0.01
                objects[ctable].yvel = objects[ctable].yvel + 0.01
            end
                if love.keyboard.isDown("left") then
                    rotV = -rotSpeed * dt
                elseif love.keyboard.isDown("right") then
                    rotV = rotSpeed * dt
                else
                    rotV = 0
                end
                if rotV ~= 0 then
                    local cosr = math.cos(rotV)
                    local sinr = math.sin(rotV)
                    local preXv = objects[ctable].xvel
                    objects[ctable].xvel = preXv * cosr - objects[ctable].yvel * sinr
                    objects[ctable].yvel = preXv * sinr + objects[ctable].yvel * cosr
                end
    end
    end
    for i,v in ipairs(collisions) do
                
                mergeBodies(v[1],v[2])
            end
    if love.keyboard.isDown("w") then
        cypos = cypos+4
    end
    if love.keyboard.isDown("s") then
        cypos = cypos-4
    end
    if love.keyboard.isDown("d") then
        cxpos = cxpos-4
    end
    if love.keyboard.isDown("a") then
        cxpos = cxpos+4
    end
end
function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Objects: "..#objects,0,0,250,"left")
    love.graphics.printf("Speed: x"..speedMod,0,15,250,"left")
    love.graphics.printf("Zoom: x"..scale,0,30,250,"left")
    
    for i,v in ipairs(objects) do
        planetDraw(v)
    end
    if planetMenu then
        if curPlanId ~= 0 then
            love.graphics.printf("Id: "..curPlanId,0,45,250,"left")
            local ctable = getObjectFromId(curPlanId)
            
            if ctable ~= 0 then
                if keyDown and ckey == "z" then
                    keyDown = false
                    objects[ctable].mass = objects[ctable].mass /10
                end
                if keyDown and ckey == "x" then
                    keyDown = false
                    objects[ctable].mass = objects[ctable].mass *10
                end
                if keyDown and ckey == "c" then
                    keyDown = false
                    objects[ctable].mass = objects[ctable].mass +1
                end
                if keyDown and ckey == "v" then
                    keyDown = false
                    objects[ctable].mass = objects[ctable].mass -1
                end
                if keyDown and ckey == "q" then
                    keyDown = false
                    objects[ctable].size = math.abs(objects[ctable].size -1)
                end
                if keyDown and ckey == "e" then
                    keyDown = false
                    objects[ctable].size = objects[ctable].size +1
                end
                if keyDown and ckey == "w" then
                    keyDown = false
                    objects[ctable].size = objects[ctable].size +1
                end
                if keyDown and ckey == "t" then
                    keyDown = false
                    if objects[ctable].type == "p" then
                        objects[ctable].type = "s"
                    else
                        objects[ctable].type = "p"
                    end
                end
                
                love.graphics.printf("Mass: "..objects[ctable].mass,0,60,250,"left")
                love.graphics.printf("Size: "..objects[ctable].size,0,75,250,"left")
                
                if objects[ctable].type == "p" then
                        love.graphics.printf("Type: Planet",0,90,250,"left")
                    else
                        love.graphics.printf("Type: Star",0,90,250,"left")
                    end
                    love.graphics.printf("Velocities: {"..objects[ctable].xvel..","..objects[ctable].yvel.."}",0,105,250,"left")
                    love.graphics.printf("Coordinates: {"..objects[ctable].pos[1]..","..objects[ctable].pos[2].."}",0,135,250,"left")
            else
                curPlanId = 0
            end
        end
    end
end





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
    end
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
end
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
    if key == "=" then
        speedMod = speedMod + 1
    end
    if key == "-" then
        speedMod = math.abs(speedMod - 1)
    end
    if key == "]" then
        speedMod = speedMod + 5
    end
    if key == "[" then
        speedMod = speedMod - 5
        if speedMod <0 then
            speedMod = 0
        end
    end
    if key == "r" then
        planetMenu = not planetMenu
    end
    if key == "lshift" then
        shift = true
    end
    if key == "lctrl" then
        ctrl = 1
    end
    if key == "m" then
        cxpos = 0
        cypos = 0
    end
    if key == "h" then
        saveGame("test1.json")
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

end
function mergeBodies(tab1,tab2,type)
    nrad = math.floor(math.sqrt(tab1.size^2 + tab2.size^2)+0.5)
    m = tab1.mass + tab2.mass
    vx = (tab1.xvel*tab1.mass +tab2.xvel *tab2.mass)/m
    vy = (tab1.yvel*tab1.mass +tab2.yvel *tab2.mass)/m
    nplan = newPlanet(nrad,tab1.pos,{vx,vy},m,tab1.type)
    table.insert(objects,nplan)
    for i=#objects,1,-1 do
        if objects[i].id == tab1.id or objects[i].id == tab2.id then
            table.remove(objects,i)

        end
    end
end
function love.resize(w,h)
    winX = w
    winY = h
end