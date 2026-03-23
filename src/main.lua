local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
local lib = mods['adamant-Modpack_Lib']

config = chalk.auto('config.lua')
public.config = config

local backup, revert = lib.createBackupSystem()

-- =============================================================================
-- MODULE DEFINITION
-- =============================================================================

public.definition = {
    id       = "PoseidonWavesFix",
    name     = "Poseidon Waves Fix",
    category = "Bug Fixes",
    group    = "Boons & Hammers",
    tooltip  = "Fixes Poseidon waves on Axe special and Hidden Helix Torch.",
    default  = true,
    dataMutation = true,
}

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local function apply()
    if not TraitData.PoseidonSpecialBoon then return end
    backup(TraitData.PoseidonSpecialBoon.OnEnemyDamagedAction.Args, "MultihitProjectileWhitelist")
    backup(TraitData.PoseidonSpecialBoon.OnEnemyDamagedAction.Args, "MultihitProjectileConditions")
    local args = TraitData.PoseidonSpecialBoon.OnEnemyDamagedAction.Args
    table.insert(args.MultihitProjectileWhitelist, "ProjectileAxeSpecial")
    args.MultihitProjectileConditions.ProjectileAxeSpecial = { Count = 4, Window = 0.3 }
    args.MultihitProjectileConditions.ProjectileTorchOrbit.Count = 4
end

local function registerHooks()
end

-- =============================================================================
-- Wiring
-- =============================================================================

public.definition.apply = apply
public.definition.revert = revert

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if lib.isEnabled(config) then apply() end
        if public.definition.dataMutation and not mods['adamant-Modpack_Core'] then
            SetupRunData()
        end
    end)
end)

local uiCallback = lib.standaloneUI(public.definition, config, apply, revert)
rom.gui.add_to_menu_bar(uiCallback)
