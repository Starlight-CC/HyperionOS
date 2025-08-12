--local computer = component.getFirst("computer")
computer.nvram["BCFG"]=[[{["bootSeq"]={["1"]="Hyperion DEV",["2"]="Hyperion"},["bootCfg"]={["Hyperion DEV"]={["drive"]="disk_1",["path"]="/boot/Hyprkrnl.sys",["globals"]={["test"]="Hello"}},["Hyperion"]={["drive"]="disk_2",["path"]="/boot/Hyprkrnl.sys",["globals"]={["test"]="Hello"}}}}]]
_G._DEVELOPMENT=true
_G.component=component

-- Get CFG
local biosCfg = load("return "..computer.nvram.BCFG)()
computer.beep(800,0.2)

-- Difine functions
local function copy(tabl)
    local out = {}
    for i,v in pairs(tabl) do
        local t=type(v)
        if t=="table" then
            if i == "_G" then
                out._G=out
            else
                out[i]=copy(v)
            end
        else
            out[i]=v
        end
    end
    return out
end

local function t2t(table)
    local output = "{"
    for i,v in pairs(table) do
        local coma=true
        if type(i) == "string" then
            output=output.."[\""..i.."\"]="
        end
        if type(v) == "table" then
            if v == table then
                output=string.sub(output,1,#output-(#i+1))
                coma=false
            else
                output=output..Table2Lua(v)
            end
        elseif type(v) == "string" then
            output=output.."\""..v.."\""
        elseif type(v) == "number" then
            output=output..tostring(v)
        elseif type(v) == "function" then
            output=string.sub(output,1,#output-(#i+1))
            coma=false
        end
        if coma then
            output=output..","
        end
    end
    if #table>0 or string.sub(output,#output,#output) == "," then
        output=string.sub(output,1,#output-1)
    end
    output=output.."}"
    return output
end

local function hasKey(tabl, query)
    for i,v in pairs(tabl) do
        if i==query then
            return true
        end
    end
    return false
end

-- Start boot seq
local disks={}
for i,v in component.list() do
    if i=="disk" then
        disks[v.id]=v
    end
end

for i,v in pairs(biosCfg.bootSeq) do
    print("Atempting boot option "..i.." labled \""..v.."\".")
    local drive={}
    if not hasKey(disks,biosCfg.bootCfg[v].drive) then
        print("└─ Drive not found.")
        print(" ")
        goto invalid_boot
    else
        drive=disks[biosCfg.bootCfg[v].drive]
        print("├─ Drive found with id of \""..drive.id.."\"")
    end
    if not drive:fileExists(biosCfg.bootCfg[v].path) then
        print("└─ Path not found.")
        print(" ")
        goto invalid_boot
    else
        print("├─ Kernel exists at path \""..biosCfg.bootCfg[v].path.."\"")
    end
    local _VG=copy(_G)
    print("├─ Created virtual ENV.")
    if biosCfg.bootCfg[v].globals then
        print("├─┬ Editing ENV.")
        for i2,v2 in pairs(biosCfg.bootCfg[v].globals) do
            _VG[i2]=v2
            print("│ ├─ Added \""..i2.."\" to ENV")
        end
        print("├─┘")
    end
    print("├─ Compiling kernel...")
    local code = drive:open(biosCfg.bootCfg[v].path).read()
    local _,func = pcall(load,code,drive.id.." | "..biosCfg.bootCfg[v].path,nil,_VG)
    if not func then
        print("└─ Compilation failure.")
        print(" ")
        goto invalid_boot
    else
        print("├─ Executing.")
    end
    local bootArgs=biosCfg.bootCfg[v].bootArgs or {}
    bootArgs.bootDrive=drive
    local ok, err = pcall(func, bootArgs)
    if not ok then
        print("└─ Kernel exited with error \""..err.."\".")
        print(" ")
        goto invalid_boot
    else
        print("└─ Kernel exited.")
        print(" ")
        goto invalid_boot
    end
    ::invalid_boot::
end
computer.beep(400,0.4)
print("No boot options available")