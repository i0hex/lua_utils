--[[ 
    @brief Check if a file exists at the specified path
    @param[in] path Path to check
    @return status:boolean
--]]
local function isFileExist(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

--[[
    @brief Splice the given file base path, file base name and file extension
    @param[in] fileBasePath:string File base path
    @param[in] fileBaseName:string File base name
    @param[in] fileExtension:string File extension
    @return filePath:string
--]]
local function spliceFilePath(fileBasePath, fileBaseName, fileExtension)
    if not fileBasePath or not fileBaseName or not fileExtension then return nil end
    if string.sub(fileBasePath, -1) ~= "/" then fileBasePath = fileBasePath.."/" end
    if string.sub(fileExtension, 1, 1) ~= "." then fileExtension = "."..fileExtension end
    return fileBasePath..fileBaseName..fileExtension
end

--[[
    @brief Copy the contents of the source file to the target file
    @param[in] src:string Path of the source file
    @param[in] dst:string Path of the target file
    @return status:boolean
--]]
local function copyFile(src, dst)
    local srcFile = io.open(src, "rb")
    if not srcFile then return false end
    local contents = srcFile:read("*a")
    srcFile:close()

    local dstFile = io.open(dst, "wb")
    if not dstFile then return false end
    dstFile:write(contents)
    dstFile:close()
    return true
end

--[[
    @brief Serialize table to string
    @param[in] targetTable:table Target table
    @param[in] tableName:string Table name
    @param[in] depthOfTable:number Depth of table
    @return str:string
--]]
local function serializeTable(targetTable, tableName, depthOfTable)
    assert(type(targetTable) == "table")
    depthOfTable = depthOfTable or 1
    tableName = tableName or ""

    local result = ""
    local indent = ""
    for i = 1, depthOfTable do indent = indent.."\t" end
    for k, v in pairs(targetTable) do
        local key = type(k) == "number" and "["..k.."]" or k
        result = result..indent..key.." = "

        if type(v) == "table" then
            result = result.."\n"..indent.."{\n"..serializeTable(v, nil, depthOfTable + 1)..indent.."}"
        elseif type(v) == "string" then
            result = result..'"'..v..'"'
        else
            result = result..tostring(v)
        end
        result = result.."\n"
    end
    
    if depthOfTable == 1 then
        if result == "" then
            return "{}"
        end
        
        if tableName == "" then
            return "{\n"..result.."}"
        end

        return tableName.." =\n{\n"..result.."}" 
    end
    return result
end

--[[
    @brief Remove BOM bytes from UTF8 BOM format file
    @param[in] str:string Contents of the UTF8 BOM format file
    @return str:string
    @remark There are three BOM bytes: 0xEF, 0xBB, 0xBF
--]]
local function removeUTF8BOMByte(str)
    if string.byte(str, 1) == 239 and
        string.byte(str, 2) == 187 and
        string.byte(str, 3) == 191 then
        str = string.char(string.byte(str, 4, string.len(str)))
    end
    return str
end