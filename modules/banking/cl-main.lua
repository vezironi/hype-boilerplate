--- Returns the balance of a society/job account.
--- Banking exports are server-side only, so this asks the server. The player must be an
--- admin or belong to the job/gang that owns the account, otherwise 0 is returned.
---@param account string The account name (usually a job or gang name).
---@return number The account balance.
function Modules.Client.Banking.GetAccountMoney(account)
    if not account then return 0 end
    return lib.callback.await('hype-core:server:get-account-money', false, account) or 0
end
