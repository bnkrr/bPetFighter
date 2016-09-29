local addon, ns = ...

function hasAura(owner, aid, t)
    t = t or 0
    local petIndex = C_PetBattles.GetActivePet(owner)
    local numAuras = C_PetBattles.GetNumAuras(owner, petIndex)
    if numAuras > 0 then
        for i=1,numAuras do
            aid2, _, t2 = C_PetBattles.GetAuraInfo(owner,petIndex,i)  -- ability id, _, left turns
            if aid2 == aid and t2 >= t then
                return true
            end
        end
    end
    return false
end


local rotations = {
    crab = {
        {
            id = 2,
            flag = function(self, petIndex)
                return C_PetBattles.GetMaxHealth(1,petIndex) - C_PetBattles.GetHealth(1,petIndex) > 300 and C_PetBattles.GetAbilityState(1,petIndex,2)
            end,
        },
        {
            id = 1,
            flag = function(self, petIndex) return true end,
        },
    },
    
    zandalar = {
        {
            id = 3,
            flag = function(self, petIndex)  --trigger when 200% damage
                if C_PetBattles.GetHealth(2,1) < 300 then   -- kill enemy
                    return select(2,C_PetBattles.GetAbilityState(1, petIndex, self.id)) == 0
                elseif hasAura(2,542,1) then -- 200% damage
                    return select(2,C_PetBattles.GetAbilityState(1, petIndex, self.id)) == 0
                else
                    return false
                end
            end,
        },
        {
            id = 1,
            flag = function(self, petIndex)  --trigger when +130 damage
                if hasAura(2,918,2) then --   +130 damage
                    return select(2,C_PetBattles.GetAbilityState(1, petIndex, self.id)) == 0
                else
                    return false
                end
            end,
        },
        {
            id = 2,
            flag = function(self, petIndex) return true end,
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
    --[746] = "crab", -- 君王蟹
    --[573] = "crab", -- 塔边小蟹
    [1180] = "zandalar", -- 赞达拉袭胫者
}

ZandalarStrategy = function() end


local strategy = {  -- 只有3个，和三个宠物有关。
    {
        init = function (self)
            --self.attacked = false
            self.battleState = nil
        end,
        change = function(self)
            if C_PetBattles.GetHealth(1,1) < 1 then
                return true
            else
                return false
            end
        end,
        oneTurn = function(self)
            self.attacked = true
        end,
        attacked = false,
    },
    {
        init = nil,
        change = function(self) return C_PetBattles.GetHealth(1,2) < 1 end,
        oneTurn = nil,
    },
    {
        init = nil,
        change = function(self) return C_PetBattles.GetHealth(1,3) < 1 end,
        oneTurn = nil,
    },
}

ns.rotations = rotations
ns.speciesid = speciesid
ns.strategy = strategy

