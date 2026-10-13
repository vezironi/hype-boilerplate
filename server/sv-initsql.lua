local Config <const> = require "config.config"

local SQL_FILE <const> = 'install/database.sql'

--- Strips comments / blank lines so the transaction never receives empty queries.
---@param content string
---@return string[]
local function parseStatements(content)
    local statements = {}

    for _, statement in ipairs(SplitString(content, ";")) do
        local lines = {}

        for line in statement:gmatch("[^\r\n]+") do
            line = TrimString(line)

            if line ~= "" and not line:match("^%-%-") and not line:match("^#") then
                lines[#lines + 1] = line
            end
        end

        if #lines > 0 then
            statements[#statements + 1] = table.concat(lines, " ")
        end
    end

    return statements
end

--- Runs 'install/database.sql' in a single transaction. No-op when
--- Config.AutoRunSQL is false or the file is missing.
---@param callback? fun()
---@return boolean success
function initSQL(callback)
    if not Config.AutoRunSQL then
        return false
    end

    local content = LoadResourceFile(RESOURCE_NAME, SQL_FILE)

    if not content or content == "" then
        Debug("info", "no '%s' to run, skipping", SQL_FILE)
        return false
    end

    local statements = parseStatements(content)

    if #statements == 0 then
        Debug("info", "'%s' has no statements, skipping", SQL_FILE)
        return false
    end

    local success, err = pcall(MySQL.transaction.await, statements)

    if not success then
        print(("^1[SQL ERROR] There was an error while automatically running the required SQL (%s). " ..
            "Don't worry, you just need to run the SQL file manually, found at '%s'. " ..
            "If you've already ran the SQL code previously, and this error is annoying you, " ..
            "set Config.AutoRunSQL = false^0"):format(tostring(err), SQL_FILE))

        return false
    end

    Debug("success", "ran %d statement(s) from '%s'", #statements, SQL_FILE)

    if callback then
        callback()
    end

    return true
end
