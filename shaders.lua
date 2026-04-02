local shaders = {}

shaders.whiteout = love.graphics.newShader[[
vec4 effect(vec4 color,Image texture,vec2 texture_coords,vec2 screen_coords) {
    return vec4(1,1,1,1);
}
]]
shaders.normal = love.graphics.newShader[[
vec4 effect(vec4 color,Image texture,vec2 texture_coords,vec2 screen_coords) {
    vec4 texcolor = Texel(texture,texture_coords);
    return color * texcolor;
}
]]
shaders.light = love.graphics.newShader[[
extern vec2 sourcePos;
extern float radius;
vec4 effect(vec4 color,Image texture,vec2 texture_coords,vec2 screen_coords) {
    float distance = length(screen_coords - sourcePos);
    float nAlpha = (1-distance/radius);
    nAlpha = (1-(1-nAlpha)*(1-nAlpha))/2;
    return vec4(color.rgb,nAlpha);
}
]]

return shaders