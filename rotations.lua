local rotations = {
    crab = {
        {
            id = 2,
            flag = function()
                return C_PetBattles.GetMaxHealth(1,1) - C_PetBattles.GetHealth(1,1) > 10 and C_PetBattles.GetAbilityState(1,1,2)
            end
        },
        {
            id = 1,
            flag = function() return true end
        },
    },
    
    zandala = {
    },
    
    default = {
        {
            id = 1,
            flag = function() return true end
        },
    },
}

local speciesid = {
    [746] = "crab", -- 君王蟹
    [573] = "crab", -- 塔边小蟹
}


ns.rotations = rotations
ns.speciesid = speciesid

-- /run print(C_PetJournal.FindPetIDByName("塔边小蟹"))
-- C_PetBattles.GetPetSpeciesID(1,1)

--如何确定位置？
--如何得知当前宠物的rotation？


