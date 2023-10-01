package.path = './b41firearms2csv/?.lua;' .. package.path

if #arg == 0 then
    error([[usage:
    lua.exe b41firearms2csv\main.lua <Path to steam library where PZ installed>\steamapps\workshop\content\108600\2256623447\mods\Firearms\media\scripts
    lua b41firearms2csv/main.lua <Path to steam library where PZ installed>/steamapps/workshop/content/108600/2256623447/mods/Firearms/media/scripts]]
    )
end

local b41cfg_dir = arg[1]

print("Firearms B41 config path:", b41cfg_dir)

local ls_cmd, sep = 'ls -1 ', '/'
local ok = os.execute(ls_cmd .. b41cfg_dir)
if not ok or ok == 1 then
    ls_cmd, sep = 'dir /B ', '\\'
end

local weapon_files = {
    ['Firearms_Items_AssaultRifles.txt'] = true,
    ['Firearms_Items_Handguns.txt'] = true,
    ['Firearms_Items_LeverActionRifles.txt'] = true,
    ['Firearms_Items_Revolvers.txt'] = true,
    ['Firearms_Items_Rifles.txt'] = true,
    ['Firearms_Items_SMGs.txt'] = true,
    ['Firearms_Items_Shotguns.txt'] = true,
}

print('directory listing:', ls_cmd .. b41cfg_dir)
local ls_prog = io.popen(ls_cmd .. b41cfg_dir)

local parser = require('parser').new()

for file_name in ls_prog:lines() do
    if weapon_files[file_name] then
        print('processing', file_name)
        local content = ''
        for line in io.lines(b41cfg_dir .. sep .. file_name) do
            content = content .. '\n' .. line
        end
        parser:parse(content)
    end
end

ls_prog:close()

parser:dump()

print(parser:csv('DisplayName', 'AmmoType', 'MaxAmmo', 'HitChance', 'AimingPerkHitChanceModifier', 'MinDamage', 'MaxDamage', 'StopPower', 'PushBackMod', 'KnockdownMod', 'MinRange', 'MaxRange', 'SoundRadius', 'CritDmgMultiplier', 'CriticalChance', 'AimingPerkCritModifier', 'Weight', 'TwoHandWeapon', 'ProjectileCount', 'PiercingBullets', 'MaxHitCount'))
