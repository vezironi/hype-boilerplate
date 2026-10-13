local Config = require "config.config"

function Modules.Server.Banking.GetAccountMoney(account)
    if not account then return 0 end

    if Config.Banking == 'fd_banking' then
    elseif Config.Banking == 'kartik-banking' then
        return exports['kartik-banking']:GetAccountMoney(account) or 0 
    elseif Config.Banking == 'okokBanking' then
        return exports.okokBanking:GetAccount(account) or 0
    elseif Config.Banking == 'qb-banking' then
        return exports['qb-banking']:GetAccountBalance(account) or 0
    elseif Config.Banking == 'Renewed-Banking' then
        return exports['Renewed-Banking']:getAccountMoney(account) or 0
    elseif Config.Banking == 'tgg-banking' then
        return exports['tgg-banking']:GetSocietyAccountMoney(account) or 0
    elseif Config.Banking == 'tgiann-bank' then
        return exports['tgiann-bank']:GetJobAccountBalance(account) or 0
    elseif Config.Banking == 'wasabi_banking' then
        return exports.wasabi_banking:GetAccountBalance(account, 'society') or 0
    end

    return 0
end

function Modules.Server.Banking.AddAccountMoney(account, amount, reason)
    if not account or amount <= 0 then return false end

    if Config.Banking == 'fd_banking' then
        return exports.fd_banking:AddMoney(account, amount, reason)
    elseif Config.Banking == 'kartik-banking' then
        return exports['kartik-banking']:AddAccountMoney(account, amount, reason)
    elseif Config.Banking == 'okokBanking' then
        return exports.okokBanking:AddMoney(account, amount)
    elseif Config.Banking == 'qb-banking' then
        return exports['qb-banking']:AddMoney(account, amount, reason)
    elseif Config.Banking == 'Renewed-Banking' then
        return exports['Renewed-Banking']:addAccountMoney(account, amount)
    elseif Config.Banking == 'tgg-banking' then
        return exports['tgg-banking']:AddSocietyMoney(account, amount)
    elseif Config.Banking == 'tgiann-bank' then
        return exports['tgiann-bank']:AddJobMoney(account, amount)
    elseif Config.Banking == 'wasabi_banking' then
        return exports.wasabi_banking:AddMoney('society', account, amount)
    end

    error("No valid banking system configured, please set Config.Banking to your banking system or setup your own in the else statement.")
end

function Modules.Server.Banking.RemoveAccountMoney(account, amount, reason)
    if not account or amount <= 0 then return false end

    if Config.Banking == 'fd_banking' then
        return exports.fd_banking:RemoveMoney(account, amount, reason)
    elseif Config.Banking == 'kartik-banking' then
        return exports['kartik-banking']:RemoveAccountMoney(account, amount, reason)
    elseif Config.Banking == 'okokBanking' then
        return exports.okokBanking:RemoveMoney(account, amount)
    elseif Config.Banking == 'qb-banking' then
        return exports['qb-banking']:RemoveMoney(account, amount, reason)
    elseif Config.Banking == 'Renewed-Banking' then
        return exports['Renewed-Banking']:removeAccountMoney(account, amount)
    elseif Config.Banking == 'tgg-banking' then
        return exports['tgg-banking']:RemoveSocietyMoney(account, amount)
    elseif Config.Banking == 'tgiann-bank' then
        return exports['tgiann-bank']:RemoveJobMoney(account, amount)
    elseif Config.Banking == 'wasabi_banking' then
        return exports.wasabi_banking:RemoveMoney('society', account, amount)
    end

    error("No valid banking system configured, please set Config.Banking to your banking system or setup your own in the else statement.")
end

--- Returns whether a player may read the balance of an account from the client.
--- Allowed for admins and for members of the job or gang that owns the account.
---@param playerId number The server-side player source ID.
---@param account string The account name (usually a job or gang name).
---@return boolean
local function canViewAccount(playerId, account)
    if not Framework.Name then return false end
    if Framework.Server.PlayerIsAdmin(playerId) then return true end

    local job = Framework.Server.GetPlayerJob(playerId)
    if job and job.name == account then return true end

    local gang = Framework.Server.GetPlayerGang(playerId)
    if gang and gang.name == account then return true end

    return false
end

lib.callback.register('hype-core:server:get-account-money', function(source, account)
    if not source or not account or not canViewAccount(source, account) then return 0 end
    return Modules.Server.Banking.GetAccountMoney(account)
end)
