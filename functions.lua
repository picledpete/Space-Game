local sqrt = math.sqrt
function planetUpdate(table,dt)
    ptable = table

        for i,v in ipairs(objects) do
            if v.id ~= ptable.id then
                dx = v.pos[1] - ptable.pos[1]
                dy = v.pos[2] - ptable.pos[2]
                d = sqrt(dx^2+dy^2)
                movDir = {dx/d,dy/d}
                xf = movDir[1] * G * v.mass/(d^2 + 20)
                yf = movDir[2] * G * v.mass/(d^2 + 20)
                ptable.xvel = ptable.xvel + xf * dt
                ptable.yvel = ptable.yvel + yf * dt
            end

    end
    --ptable.xvel = ptable.xvel + sunDir[1] * gravMult
    --ptable.yvel = ptable.yvel + sunDir[2] * gravMult
    ptable.pos = {ptable.pos[1] + ptable.xvel *dt ,ptable.pos[2] + ptable.yvel* dt}
    return ptable
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
        love.graphics.setColor(1,1,1)
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