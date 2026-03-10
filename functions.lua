local json = require("dkjson")
local sqrt = math.sqrt
function planetUpdate(i1,i2,dt)
    ptable = objects[i1]
    ptable2 = objects[i2]

    
                dx = ptable2.pos[1] - ptable.pos[1]
                dy = ptable2.pos[2] - ptable.pos[2]
                d = sqrt(dx^2+dy^2)
                movDir = {dx/d,dy/d}
                local f = G/(d^2+5)
                xf = dx/d*f
                yf = dy/d*f
                ptable.xvel = ptable.xvel + xf*ptable2.mass
                ptable.yvel = ptable.yvel + yf*ptable2.mass

                ptable2.xvel = ptable2.xvel + xf*ptable.mass
                ptable2.yvel = ptable2.yvel + yf*ptable.mass

    --ptable.xvel = ptable.xvel + sunDir[1] * gravMult
    --ptable.yvel = ptable.yvel + sunDir[2] * gravMult
    --ptable.xvel = ptable.xvel * 0.999
    --ptable.yvel = ptable.yvel * 0.999

    return {ptable,ptable2}
end
function planetDraw(ptable)
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
        clr = getStarColor(ptable.mass)
        local brightness = 0.7 + math.sin(love.timer.getTime())*0.3
        love.graphics.setColor(clr[1],clr[2],clr[3],brightness/5)
             love.graphics.circle("fill",ptable.pos[1]*scale+xoffset+cxoffset,ptable.pos[2]*scale+yoffset+cyoffset,math.ceil(ptable.size*scale*2.5))
        love.graphics.setColor(clr[1],clr[2],clr[3])
        else
        love.graphics.setColor(1,1,1)
        end
        love.graphics.circle("fill",ptable.pos[1]*scale+xoffset+cxoffset,ptable.pos[2]*scale+yoffset+cyoffset,math.ceil(ptable.size*scale))
    end
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

function randomStart(planNum,starNum)
for i=1,planNum do
    local x = love.math.random(-1000,1000)
    local y = love.math.random(-1000,1000)
    local mass = randFloat(0.05,3)
    local vel = {randFloat(-0.2,0.2),randFloat(-0.2,0.2)}

    local size = love.math.random(1,3)
    local p = newPlanet(size,{x,y},vel,mass,"p")
    table.insert(objects,p)
end
for i=1,starNum do
    local x = love.math.random(-1000,1000)
    local y = love.math.random(-1000,1000)
    local mass = love.math.random(70,250)
    local vel = {randFloat(-0.15,0.15),randFloat(-0.15,0.15)}
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