return {
    --- Prints debug messages to the console. Disable on production servers.
    Debug = true,

    --- Automatically executes 'install/database.sql' on resource start.
    AutoRunSQL = true,

    --- The locale to use for translations. This can be overridden by the 'ox:locale' convar.
    Locale = GetConvar('ox:locale', 'en'),

    --- Opens the NUI with a chat command and an (optional) rebindable key.
    Command = {
        enable = true,
        name = 'boilerplate',
        help = 'Opens the boilerplate interface',
        --- Set to false to skip RegisterKeyMapping.
        ---@type string|false
        key = 'F5',
    },

    --- 'auto' detects and uses whichever supported resource is running.
    DrawText = 'auto',
    Inventory = 'auto',
    Notifications = 'auto',
    ProgressBarSystem = 'auto',
    Target = 'auto',

    --- These modules have no auto-detection, so they need the resource named explicitly.
    --- Banking: fd_banking | kartik-banking | okokBanking | qb-banking | Renewed-Banking |
    ---          tgg-banking | tgiann-bank | wasabi_banking
    --- Fuel: LegacyFuel | ps-fuel | lj-fuel | cdn-fuel | hyon_gas_station | okokGasStation |
    ---       nd_fuel | myFuel | fast-fuel | ti_fuel | ox_fuel | Renewed-Fuel | rcore_fuel
    --- VehicleKeys: qb-vehiclekeys | qbx_vehiclekeys | fast-vehiclekeys | 0r-vehiclekeys |
    ---              jaksam-vehicles-keys | mk_vehiclekeys | qs-vehiclekeys | wasabi_carlock |
    ---              cd_garage | okokGarage | t1ger_keys | MrNewbVehicleKeys | Renewed | tgiann-hotwire
    Banking = 'none',
    Fuel = 'none',
    VehicleKeys = 'none',
}
