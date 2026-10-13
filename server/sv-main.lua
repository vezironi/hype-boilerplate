AddEventHandler('onServerResourceStart', function(resource)
    if resource ~= RESOURCE_NAME then return end

    initSQL()
end)
