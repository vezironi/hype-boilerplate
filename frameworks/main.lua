Framework = {
    Name = nil,
    Server = {},
    Client = {}
}

if IsResourceRunning('es_extended') then
    Framework.Name = 'es_extended'
elseif IsResourceRunning('qbx_core') then
    Framework.Name = 'qbx_core'
elseif IsResourceRunning('qb-core') then
    Framework.Name = 'qb-core'
end