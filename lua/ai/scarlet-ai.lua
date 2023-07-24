sgs.ai_skill_invoke.s4_cloud_yongqian = function(self, data)
    return true
end

sgs.ai_skill_playerchosen.s4_cloud_yongqian = function(self, targets)
    self:sort(self.enemies, "handcard")
    for _, enemy in ipairs(self.enemies) do
        if self:canAttack(enemy, self.player) and not self:canLiuli(enemy, self.friends_noself) and
            not self:findLeijiTarget(enemy, 50, self.player) then
            return enemy
        end
    end
    return nil
end

sgs.ai_skill_choice.s4_cloud_tuxi = function(self, choices)
    return "1"
end

sgs.ai_skill_invoke.s4_cloud_tuxi = function(self, data)
    local target = data:toPlayer()
    if target and self:isEnemy(target) then
        if self.player:getHandcardNum() <= target:getHandcardNum() then
            return true
        end
        if self.player:getHp() <= target:getHp() then
            return true
        end
        if self.player:getEquips():length() <= target:getEquips():length() and self.player:canDiscard(self.player, "he") then
            return true
        end
    end
    return false
end

sgs.ai_skill_discard.s4_cloud_tuxi = function(self, discard_num, min_num, optional, include_equip)

    local target = self.room:getCurrent()

    if not target then
        return {}
    end
    if self:isEnemy(target) then
        return self:askForDiscard("dummy", discard_num, min_num, false, include_equip)
    end
    return {}
end
