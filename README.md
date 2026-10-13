# hype-boilerplate

Framework-agnostic FiveM resource starter. Ships a bridge for **ESX / QB / qbx**, a
pluggable module layer for the third-party resources a script usually has to support
(banking, inventory, fuel, notifications, textui, progressbar, target, vehicle keys),
plus locales, shared utilities and automatic SQL installation.

## Requirements

| Resource | Required | Notes |
| --- | --- | --- |
| [ox_lib](https://github.com/overextended/ox_lib) | yes | callbacks, locales, `require` |
| [oxmysql](https://github.com/overextended/oxmysql) | optional | only for `Config.AutoRunSQL` / your own queries |
| ESX, qb-core, qbx_core | optional | auto-detected by `frameworks/main.lua` |

No database? Drop `'@oxmysql/lib/MySQL.lua'` from `server_scripts` in `fxmanifest.lua`
and set `Config.AutoRunSQL = false`.

## Layout

```
config/config.lua      settings, including one key per module
shared/utils.lua       Debug + string/table/number helpers
shared/main.lua        RESOURCE_NAME, locale loading, IsResourceRunning
frameworks/main.lua    Framework table + framework detection
frameworks/<name>/     per-framework implementations (es_extended, qb-core, qbx_core)
modules/main.lua       Modules table
modules/<name>/        per-feature bridges, one folder per module
client/, server/       your script
install/database.sql   schema, re-runnable
locales/*.json         ox_lib locales
web/                   Vue 3 + Vite + Tailwind interface (see web/README.md)
```

Load order is explicit in `fxmanifest.lua` and matters: `shared/utils.lua` (Debug)
→ `shared/main.lua` (resource constants, locales) → `frameworks/main.lua` and
`modules/main.lua` (the tables) → the per-provider files, which are globbed, so a new
`modules/<name>/cl-main.lua` or `modules/<group>/<provider>/cl-main.lua` is picked up
with no manifest edit.

## Config

```lua
Debug      = true                        -- console output from Debug()
AutoRunSQL = true                        -- run install/database.sql on start
Locale     = GetConvar('ox:locale', 'en')
Command    = { enable = true, name = 'boilerplate', help = '...', key = 'F5' }
```

### Modules

Each module in `modules/` reads one config key to decide which third-party resource it
talks to:

```lua
DrawText          = 'auto'   -- jg-textui | ox_lib | okokTextUI | ps-ui
Inventory         = 'auto'   -- codem-inventory | core_inventory | jpr-inventory | origen_inventory
                             -- | ox_inventory | ps-inventory | qb-inventory | tgiann-inventory
Notifications     = 'auto'   -- okokNotify | ps-ui | ox_lib
ProgressBarSystem = 'auto'   -- ox_lib | lation_ui | keep-progressbar | progressbar | wasabi_uikit | ZSX_UIV2
Target            = 'auto'   -- ox_target | qb-target

Banking     = 'none'         -- no auto-detection: name the resource explicitly
Fuel        = 'none'
VehicleKeys = 'none'
```

`'auto'` uses whichever supported resource is running; naming a resource pins it, which
is also how you use a renamed fork or your own implementation added to a module's `else`
branch. `Banking`, `Fuel` and `VehicleKeys` have no detection, so they stay inert (and
their setters raise a "no system configured" error) until you set them.

Modules currently in the box:

| Module | Config key | Auto-detect |
| --- | --- | --- |
| Banking | `Banking` | no |
| TextUI | `DrawText` | yes |
| Fuel | `Fuel` | no |
| Inventory | `Inventory` | yes |
| Notify | `Notifications` | yes |
| Progressbar | `ProgressBarSystem` | yes |
| Target | `Target` | yes |
| Vehicle keys | `VehicleKeys` | no |

### Adding a module

1. Add the config key to `config/config.lua`.
2. Create `modules/<name>/cl-main.lua` / `sv-main.lua` and add the table to
   `modules/main.lua`.
3. Branch on the config key inside the module. A single file per provider
   (`modules/<group>/<provider>/cl-main.lua`) can instead guard at the top, like
   `progressbar` and `target` do.

## API

`Framework.Client` / `Framework.Server` (and matching `exports`) normalise player
data per framework:

```lua
-- client
Framework.Client.GetFrameworkName() GetIsPlayerLoaded() GetPlayerData() GetPlayerCoords(ped)
  GetPlayerIdentifier() GetCharacterName() GetPlayerMetaData(key) GetIsPlayerDead()
  GetPlayerMoney(account) GetPlayerJob() GetPlayerGang()

-- server
Framework.Server.GetPlayers() GetPlayer(src) PlayerIsAdmin(src) GetPlayerByIdentifier(id)
  GetPlayerSource(id) GetPlayerIdentifier(src) GetCharacterName(src) GetPlayerBirthday(src)
  GetPlayerPhoneNumber(src) GetPlayerGender(src) GetPlayerLicense(src) GetPlayerMoney(src, account)
  AddPlayerMoney(...) RemovePlayerMoney(...) GetPlayerJob(src) SetPlayerJob(...)
  GetPlayerGang(src) GetPlayerMetaData(...) SetPlayerMetaData(...) RegisterUsableItem(...)
```

Framework events are rebroadcast under one name, so listen to these instead of the
framework's own:

```lua
-- client
hype-core:client:player-loaded
hype-core:client:player-unloaded
hype-core:client:player-job-updated   (job)

-- server
hype-core:server:player-loaded        (playerId)
hype-core:server:player-unloaded      (playerId)
hype-core:server:player-job-updated   (playerId, job)
```

`Modules.Client` / `Modules.Server`:

```lua
Modules.Client.Banking.GetAccountMoney(account)
Modules.Client.Fuel.GetFuel(veh) / SetFuel(veh, fuel)
Modules.Client.Inventory.HasItem(items, count)
Modules.Client.Notify.SendNotify(title, message, time, type)
Modules.Client.Progressbar.Open(options)
Modules.Client.Target.AddBoxZone/AddSphereZone/AddModel/AddLocalEntity/RemoveZone/RemoveModel/RemoveLocalEntity
Modules.Client.TextUI.ShowTextUI(text) / HideTextUI()
Modules.Client.Vehiclekeys.GiveKeys(plate, veh, origin) / RemoveKeys(plate, veh)

Modules.Server.Banking.GetAccountMoney/AddAccountMoney/RemoveAccountMoney
Modules.Server.Inventory.HasItem/CanCarryItem/AddItem/RemoveItem
Modules.Server.Notify.SendNotify(playerId, title, message, time, type)
```

## Utilities

`Debug(status, message, ...)` prints `[DEBUG:SERVER|CLIENT]` lines with `success`,
`error`, `warning` and `info` levels, formats varargs through `string.format`, and goes
silent when `Config.Debug = false`.

Shared: `SplitString`, `TrimString`, `Round`, `Clamp`, `TableContains`, `TableSize`,
`DeepCopy`, `MergeTable`, `FormatMoney`, `IsResourceRunning`, `RESOURCE_NAME`.

## Database

`install/database.sql` runs in a single transaction on start while
`Config.AutoRunSQL = true`. Statements are split on `;`, and comments and blank lines
are stripped, so keep one statement per block, avoid stored procedures, and write
everything re-runnable (`CREATE TABLE IF NOT EXISTS`). A failure prints the reason and
tells the server owner to import the file manually.
