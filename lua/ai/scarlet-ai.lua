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
function sgs.ai_cardneed.s4_cloud_yongqian(to, card)
    return to:getHandcardNum() < 3 and card:isKindOf("Slash")
end

function sgs.ai_cardneed.s4_cloud_tuxi(to, card)
    return to:isKongcheng()
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

function sgs.ai_cardneed.s4_cloud_liegong(to, card)
    return to:getHandcardNum() < 3 and card:isKindOf("Slash")
end

sgs.card_value.s4_cloud_liegong = {
    Analeptic = 4.9,
    Slash = 7.2
}

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
    if fs then
        fs:setSkillName("s4_cloud_yongyi")
        local d = self:aiUseCard(fs)
        if fs:isAvailable(self.player) and #records > 0 and d.card and use.to then
            sgs.ai_use_priority.s4_cloud_yongyi = sgs.ai_use_priority.Analeptic
            use.card = sgs.Card_Parse("#s4_cloud_yongyi:.:analeptic")
            return
        end
    end
end
sgs.ai_use_priority["#s4_cloud_yongyi"] = sgs.ai_use_priority.Analeptic
sgs.ai_use_priority["s4_cloud_yongyi"] = sgs.ai_use_priority.Analeptic
sgs.ai_use_value["#s4_cloud_yongyi"] = 5

sgs.ai_guhuo_card.s4_cloud_yongyi = function(self, toname, class_name)
    if (class_name == "Analeptic") and sgs.Sanguosha:getCurrentCardUseReason() ==
        sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
        return "#s4_cloud_yongyi:.:" .. toname
    end
end

sgs.card_value.s4_cloud_yongyi = {
    Analeptic = 4.9,
    Slash = 7.2
}

sgs.card_value.s4_xianfeng = {
    Slash = 7.2
}

function sgs.ai_cardneed.s4_xianfeng(to, card)
    return card:isKindOf("Slash")
end

sgs.ai_skill_discard.s4_jiwu_invoke = function(self, discard_num, min_num, optional, include_equip)
    if min_num > 0 and (self.player:getCardCount() >= 2 or self:isWeak()) then
        return self:askForDiscard("dummy", min_num, min_num, false, include_equip)
    end
    return {}
end

sgs.ai_skill_choice.s4_jiwu = function(self, choices, data)
    local items = choices:split("+")
    local use = data:toCardUse()
    if table.contains(items, "s4_jiwu_nullified") then
        for _, to in sgs.qlist(use.to) do
            if self:isFriend(to) and use.from and not self:isFriend(use.from) and
                (self:isWeak(to) or self:hasHeavyDamage(use.from, use.card, to)) then
                if not (self:hasCrossbowEffect(use.from) or use.from:hasSkills(sgs.double_slash_skill)) or
                    getCardsNum("Slash", use.from) < 1 then
                    return "s4_jiwu_nullified"
                end
            end
        end
    end
    if table.contains(items, "s4_jiwu_draw") then
        if not use.card:hasFlag("s4_jiwu_nullified") then
            local invoke = true
            for _, to in sgs.qlist(use.to) do
                if ((use.card:isKindOf("Slash") and getCardsNum("Jink", to) > 0) or
                    (use.card:isKindOf("Duel") and getCardsNum("Nullification", to) > 0)) and
                    not self:needToLoseHp(to, use.from, use.card) then
                    invoke = false
                    break
                end
            end
            if invoke or use.card:hasFlag("s4_jiwu_no_respond") then
                return "s4_jiwu_draw"
            end
        end
    end
    if table.contains(items, "s4_jiwu_no_respond_list") then
        if use.from and self:isFriend(use.from) and not use.card:hasFlag("s4_jiwu_nullified") then
            for _, to in sgs.qlist(use.to) do
                if self:isEnemy(to) and
                    (self:isWeak(to) or self:hasHeavyDamage(use.from, use.card, to) or use.card:hasFlag("s4_jiwu")) then
                    if ((use.card:isKindOf("Slash") and getCardsNum("Jink", to) > 0 and
                        not (self:canLiegong(to, use.from))) or
                        (use.card:isKindOf("Duel") and getCardsNum("Slash", to, use.from) > 0)) then
                        return "s4_jiwu_no_respond_list"
                    end
                end
            end
        end
    end
    return "cancel"
end

function sgs.ai_cardneed.s4_jiwu(to, card)
    return to:getHandcardNum() < 3 and card:isKindOf("Slash")
end

sgs.card_value.s4_jiwu = {
    Slash = 7.2
}

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
