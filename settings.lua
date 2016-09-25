local addon, ns = ...

local rotations = {
    crab = {
        {
            id = 2,
            flag = function(petIndex)
                return C_PetBattles.GetMaxHealth(1,petIndex) - C_PetBattles.GetHealth(1,petIndex) > 300 and C_PetBattles.GetAbilityState(1,petIndex,2)
            end,
        },
        {
            id = 1,
            flag = function(petIndex) return true end,
        },
    },
    
    zandalar = {
        {
            id = 1,
            flag = function(petIndex) return true end,
        },
    },
    
    default = {
        {
            id = 1,
            flag = function(petIndex) return true end,
        },
    },
}

local speciesid = {
    [746] = "crab", -- 君王蟹
    [573] = "crab", -- 塔边小蟹
    [1180] = "zandalar", -- 赞达拉袭胫者
}


local strategy = {  -- 只有3个，和三个宠物有关。
    {
        init = function () attacked = false end,
        change = function() return attacked end,
        oneTurn = function() attacked = true end,
        attacked = false,
    },
    {
        init = function () attacked = false end,
        change = function() return attacked end,
        oneTurn = function() attacked = true end,
        attacked = false,
    },
    {
        init = nil,
        change = function() return C_PetBattles.GetHealth(1,2) < 1 end,
        oneTurn = nil,
    },
}

ns.rotations = rotations
ns.speciesid = speciesid
ns.strategy = strategy

-- /run print(C_PetJournal.FindPetIDByName("塔边小蟹"))
-- C_PetBattles.GetPetSpeciesID(1,1)



