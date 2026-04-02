local json = require("dkjson")
local sqrt = math.sqrt
function planetUpdate(i1,i2,dt)
    ptable = objects[i1]
    if ptable.mass > 10 then
        ptable.type = "s"
    end
    if ptable.mass > 2700 and ptable.type ~= "b" then
        ptable.type = "b"
        ptable.size = math.random(1,2)
    end
    ptable2 = objects[i2]

    
                dx = ptable2.pos[1] - ptable.pos[1]
                dy = ptable2.pos[2] - ptable.pos[2]
                d = sqrt(dx^2+dy^2)
                if d < 0.001 then
                    return {ptable, ptable2}
                end
                movDir = {dx/d,dy/d}
                local f = G/(d^2+5) * dt * speedMod
                xf = dx/d*f
                yf = dy/d*f
                if xf ~= xf or yf ~= yf then
                    return {ptable, ptable2}
                end
                ptable.xvel = ptable.xvel + xf*ptable2.mass
                ptable.yvel = ptable.yvel + yf*ptable2.mass

                ptable2.xvel = ptable2.xvel - xf*ptable.mass
                ptable2.yvel = ptable2.yvel - yf*ptable.mass

    --ptable.xvel = ptable.xvel + sunDir[1] * gravMult
    --ptable.yvel = ptable.yvel + sunDir[2] * gravMult
    --ptable.xvel = ptable.xvel * 0.999
    --ptable.yvel = ptable.yvel * 0.999

    return {ptable,ptable2}
end
function planetDraw(ptable)
    --love.graphics.setShader(shaders.whiteout)
    cxoffset = cxpos + winX * (1/2 * scale)
    cyoffset = cypos + winY * (1/2 * scale)
    if curPlanId == ptable.id then
    love.graphics.setColor(1,0,0)
    love.graphics.circle("fill",ptable.pos[1]*scale+xoffset+cxoffset,ptable.pos[2]*scale+yoffset+cyoffset,math.ceil(ptable.size*scale+1))
    love.graphics.setColor(0,1,0)
    local lx = (ptable.pos[1] + ptable.xvel*3)*scale+xoffset+cxoffset
    local ly = (ptable.pos[2] + ptable.yvel*3)*scale+yoffset+cyoffset
    love.graphics.line(ptable.pos[1]*scale+xoffset+cxoffset,ptable.pos[2]*scale+yoffset+cyoffset,lx,ly )
    else
        if ptable.type == "s" then
        if ptable.mass > 1450 then
            if ptable.size < 17 then
                ptable.size = ptable.size + 3
            end
        clr = {1.0,.35,0.1}

        else
        clr = getStarColor(ptable.mass)
        end
        if scale <0.1 then
            local offset = 1-(scale-0.01)/0.09
            clr[1] = clr[1] +offset/3
            clr[2] = clr[2] +offset/3
            clr[3] = clr[3] +offset/3
        end
        local brightness = 0.7 + math.sin(love.timer.getTime()+ptable.id*2.5)*0.3
        love.graphics.setColor(clr[1],clr[2],clr[3],brightness/5)
        --love.graphics.circle("fill",ptable.pos[1]*scale+xoffset+cxoffset,ptable.pos[2]*scale+yoffset+cyoffset,math.ceil(ptable.size*scale*2.5))
        love.graphics.setColor(clr[1],clr[2],clr[3])
        love.graphics.setShader(shaders.light)
        shaders.light:send("sourcePos", {ptable.pos[1]*scale+xoffset+cxoffset,ptable.pos[2]*scale+yoffset+cyoffset})
        shaders.light:send("radius",math.ceil(ptable.size*scale*((ptable.mass/85)*2.5)^0.7))
        love.graphics.circle("fill",ptable.pos[1]*scale+xoffset+cxoffset,ptable.pos[2]*scale+yoffset+cyoffset,math.ceil(ptable.size*scale*((ptable.mass/85)*2.5)^0.7))
        love.graphics.setShader(shaders.normal)
        love.graphics.setColor(clr[1],clr[2],clr[3])
        love.graphics.circle("fill",ptable.pos[1]*scale+xoffset+cxoffset,ptable.pos[2]*scale+yoffset+cyoffset,math.ceil(ptable.size*scale))

    end
        if ptable.type == "p" then
            clr = {0.9,0.9,0.9}
            --[[
            if scale <0.1 then
                local offset = 1-(scale-0.01)/0.09
                clr[1] = clr[1] +offset
                clr[2] = clr[2] +offset
                clr[3] = clr[3] +offset
            end]]
            love.graphics.setColor(clr[1],clr[2],clr[3])
            love.graphics.circle("fill",ptable.pos[1]*scale+xoffset+cxoffset,ptable.pos[2]*scale+yoffset+cyoffset,math.ceil(ptable.size*scale))
        end
        if ptable.type == "b" then
            
            love.graphics.setColor(1,0.65,0.1)
            
            for i=0,ptable.size/3 do 
            love.graphics.circle("line",ptable.pos[1]*scale+xoffset+cxoffset+math.random(-1,1),ptable.pos[2]*scale+yoffset+cyoffset+math.random(-1,1),math.ceil(ptable.size*scale+1+i))
            end
        end

    end
    --love.graphics.setShader(shaders.normal)
end


function newPlanet(psize,ppos,speed,pmass,t)
    local planetTable = {   
        id = nId,
        size = psize,
        pos = ppos,
        xvel = speed[1],
        yvel = speed[2],
        mass = pmass,
        type = t
    }
    nId = nId + 1
    return planetTable
end

function getObjectFromId(id)
    for i,v in ipairs(objects) do
        if v.id == id then
            return i
        end
    end
    return 0
end

function interpolate(n,v)
    local n1 = n[1]
    local n2 = n[2]
    local n3 = n[3]
    if v <0.5 then
    return n1 + (n2-n1)*v
    else
    return n2 + (n3-n2)*v
    end
end
function getStarColor(mass)
    local t = math.min(mass/600,1)
    local colors = {
        {1.0,0.3,0.3},
        {1.0,0.6,0.3},
        {1.0,1.0,0.7},
        {0.9,0.9,1.0},
        {0.6,0.8,1.0} 
    }
    local n = #colors-1
    local pos = t*n
    local i = math.floor(pos)+1
    local f = pos%1

    local c1 = colors[i]
    local c2 = colors[i+1] or colors[i]

    return {
        c1[1] + (c2[1]-c1[1])*f,
        c1[2] + (c2[2]-c1[2])*f,
        c1[3] + (c2[3]-c1[3])*f
    }
end

function randomStart(planNum,starNum,maxRad,generateOrbits)
for i=1,planNum do
    local r = (love.math.random()^0.7)*maxRad
    local angle = love.math.random()*math.pi*2
    local x = math.cos(angle)*r
    local y = math.sin(angle)*r
    local mass = randFloat(0.05,0.9)
    if generateOrbits then
        local dist = math.sqrt(x^2+y^2)
        if dist <1 then dist=1 end
        local nspeed = math.sqrt(G*5000/dist)
        local dx = -y/dist*nspeed
        local dy = x/dist*nspeed
        vel = {dx,dy}
    else
    vel = {randFloat(-1,1),randFloat(-1,1)}
    end
    local size = love.math.random(1,3)
    local p = newPlanet(size,{x,y},vel,mass,"p")
    table.insert(objects,p)
end
for i=1,starNum do
    local r = (love.math.random()^0.7)*maxRad
    local angle = love.math.random()*math.pi*2
    local x = math.cos(angle)*r
    local y = math.sin(angle)*r
    local mass = love.math.random(70,200)
        if generateOrbits then
        local dist = math.sqrt(x^2+y^2)
        if dist <1 then dist=1 end
        local nspeed = math.sqrt(G*5000/dist)
        local dx = -y/dist*nspeed
        local dy = x/dist*nspeed
        vel = {dx,dy}
    else
    vel = {randFloat(-1,1),randFloat(-1,1)}
    end
    local size = love.math.random(3,9)
    local s = newPlanet(size,{x,y},vel,mass,"s")
    table.insert(objects,s)
end
end
function saveGame(filename)
    local file = io.open(filename,"w")
    local jsonStr = json.encode(objects,{indent=true})
    file:write(jsonStr)
    file:close()
end
function loadGame(filename)
    local file = io.open(filename,"r")
    local text = file:read("*all")
    file:close()
    objects = json.decode(text)
end
function randFloat(min,max)
    return min + love.math.random() * (max-min)
end