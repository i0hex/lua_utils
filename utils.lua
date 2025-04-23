-- Written by lua5.1
--[[
	Array: Table contains only array elements
	Map/Table: Table contains array elements and not array elements
--]]

-- Check if a file exists at the specified path
local function isFileExist(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

-- Splice the given file base path, file base name and file extension
local function spliceFilePath(fileBasePath, fileBaseName, fileExtension)
    if not fileBasePath or not fileBaseName or not fileExtension then return nil end
    if string.sub(fileBasePath, -1) ~= "/" then fileBasePath = fileBasePath.."/" end
    if string.sub(fileExtension, 1, 1) ~= "." then fileExtension = "."..fileExtension end
    return fileBasePath..fileBaseName..fileExtension
end

-- Copy the contents of the source file to the target file
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

-- Serialize table to string
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

-- Remove BOM bytes from UTF8 BOM format file
local function removeUTF8BOMByte(str)
    if string.byte(str, 1) == 239 and
        string.byte(str, 2) == 187 and
        string.byte(str, 3) == 191 then
        str = string.char(string.byte(str, 4, string.len(str)))
    end
    return str
end

-- Clone table
local function cloneTable(tbl)
	local cached_tbl = {}
	local function _clone(tbl)
		if type(tbl) ~= "table" then
			return tbl
		elseif cached_tbl[tbl] then
			return cached_tbl[tbl]
		end
		local clone_tbl = {}
		cached_tbl[tbl] = clone_tbl
		for k, v in pairs(tbl) do
			clone_tbl[_clone(k)] = _clone(v)
		end
		return setmetatable(clone_tbl, getmetatable(tbl))
	end
	return _clone(tbl)
end

-- Determine if an element is in the array
local function isArrayContainsElem(arr, elem, checkFunc)
	if not checkFunc then
		checkFunc = function(x, y)
			return x == y
		end
	end
	for _, v in ipairs(arr) do
		if checkFunc(elem, v) then return true end
	end
	return false
end

-- Deleting element from a table
local function delTableElem(tbl, elem, checkFunc, isAll)
	if not checkFunc then
		checkFunc = function(x, y)
			return x == y
		end
	end
	local flag = false
	for k, v in pairs(tbl) do
		if checkFunc(elem, v) then
			tbl[k] = nil
			if type(k) == "number" then
				table.remove(tbl, k)
			end
			flag = true
			if not isAll then return true end
		end
	end
	return flag
end
