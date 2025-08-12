local oldComponent = component
_G.component={}
local components={}
local all={}

for i,v in oldComponent.list() do
    if not components[i] then
        components[i]={}
    end
    components[i][#components[i]+1]=v
    all[i][#all[i]+1]=v
end

function component.list(filter)
    local componentsLocal = components
    filter=filter or "all"
    local filtered
    return function()
        
    end
end