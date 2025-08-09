-- <@COMPILE> --
-- Method="minify"
-- <@COMPILE_END> --
if _DEVELOPMENT then
    return function(program)
        return load(program)
    end
end

return function(program)
    if string.sub(program,1,14)~="--<@EXE=hex>--" then error("file is not hyperEXE") end
    program=program:sub(15)
    local lexer=require("lua.lexer")
end
