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
        if self.player:getHp() > 1 then
            return {}
        end
        return self:askForDiscard("dummy", 1, 1, false, include_equip)
    end
    return {}
end

sgs.ai_choicemade_filter.skillInvoke.s4_cloud_tuxi = function(self, player, promptlist)
    local current = self.room:getCurrent()
    if promptlist[#promptlist] == "yes" then
        if not self:needToLoseHp(current, player, nil) then
            sgs.updateIntention(player, current, 40)
        end
    end
end

sgs.ai_skill_invoke.s4_cloud_liegong = function(self, data)
    return sgs.ai_skill_invoke.liegong(self, data)
end

sgs.ai_skill_invoke.s4_cloud_yongyi = function(self, data)
    local card = data:toCard()
    local record = self.player:property("s4_cloud_yongyiRecords"):toString()
    local records
    if (record) then
        records = record:split(",")
    end
    if self:isWeak() and #records <= 2 then
        return false
    end
    return true
end
--[[
addAiSkills("s4_cloud_yongyi").getTurnUseCard = function(self)
    local record = self.player:property("s4_cloud_yongyiRecords"):toString()
    local records
    if (record) then
        records = record:split(",")
    end
        local fs = sgs.Sanguosha:cloneCard("analeptic")
        if fs and fs:isKindOf("Analeptic") then
            fs:setSkillName("s4_cloud_yongyi")
            local d = self:aiUseCard(fs)
            if fs:isAvailable(self.player) and #records > 0 and self.player:getMark("s4_cloud_yongyi_used-Clear") == 0 and
                d.card and d.to then
                    return "#s4_cloud_yongyi:.:" .. "analeptic"
            end
        end
        if fs then
            fs:deleteLater()
        end
end
]]
local s4_cloud_yongyi_skill = {}
s4_cloud_yongyi_skill.name = "s4_cloud_yongyi"
table.insert(sgs.ai_skills, s4_cloud_yongyi_skill)
s4_cloud_yongyi_skill.getTurnUseCard = function(self)
    if self.player:getMark("s4_cloud_yongyi_used-Clear") == 0 then
        return sgs.Card_Parse("#s4_cloud_yongyi:.:analeptic")
    end
    return nil
end

sgs.ai_skill_use_func["#s4_cloud_yongyi"] = function(card, use, self)
    local record = self.player:property("s4_cloud_yongyiRecords"):toString()
    local records
    if (record) then
        records = record:split(",")
    end
    local fs = sgs.Sanguosha:cloneCard("analeptic")
    fs:deleteLater()
    if fs and fs:isKindOf("Analeptic") then
        fs:setSkillName("s4_cloud_yongyi")
        local d = self:aiUseCard(fs)
        if fs:isAvailable(self.player) and #records > 0 and d.card and d.to then
            use.card = card
            return
        end
    end
end

sgs.ai_guhuo_card.s4_cloud_yongyi = function(self, toname, class_name)
    if (class_name == "Analeptic") and sgs.Sanguosha:getCurrentCardUseReason() ==
        sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
        return "#s4_cloud_yongyi:.:" .. toname
    end
end
--[[
function sgs.ai_cardsview_valuable.s4_cloud_yongyi(self, class_name, player)
    if class_name == "Analeptic" then
        local record = player:property("s4_cloud_yongyiRecords"):toString()
        local records
        if (record) then
            records = record:split(",")
        end
        if player:getMark("s4_cloud_yongyi_used-Clear") == 0 and #records > 0 then
            --return "#s4_cloud_yongyi:.:analeptic"
        end
        return nil
    end
end]]

sgs.ai_skill_invoke.s4_weiT_lord = function(self, data)
    return true
end
sgs.ai_skill_invoke.s4_weiT_adviser = function(self, data)
    return true
end
sgs.ai_skill_invoke.s4_weiT_gerenal = function(self, data)
    return true
end

sgs.ai_skill_invoke.s4_weiT_xionglue = function(self, data)
    return true
end
sgs.ai_skill_invoke.s4_weiT_naxian = function(self, data)
    return true
end
