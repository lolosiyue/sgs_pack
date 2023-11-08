--高达一号
  --“龙魂”AI
local xj_longhun_skill = {}
xj_longhun_skill.name = "xj_longhun"
table.insert(sgs.ai_skills, xj_longhun_skill)
xj_longhun_skill.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByUseValue(cards, true)
	for _, card in ipairs(cards) do
		if card:getSuit() == sgs.Card_Diamond and self:slashIsAvailable() then
			return sgs.Card_Parse(("fire_slash:xj_longhun[%s:%s]=%d"):format(card:getSuitString(), card:getNumberString(), card:getId()))
		end
	end
end

sgs.ai_view_as.xj_longhun = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place == sgs.Player_PlaceSpecial then return end
	if card:getSuit() == sgs.Card_Diamond then
		return ("fire_slash:xj_longhun[%s:%s]=%d"):format(suit, number, card_id)
	elseif card:getSuit() == sgs.Card_Club then
		return ("jink:xj_longhun[%s:%s]=%d"):format(suit, number, card_id)
	elseif card:getSuit() == sgs.Card_Heart and player:getMark("Global_PreventPeach") == 0 then
		return ("peach:xj_longhun[%s:%s]=%d"):format(suit, number, card_id)
	elseif card:getSuit() == sgs.Card_Spade then
		return ("nullification:xj_longhun[%s:%s]=%d"):format(suit, number, card_id)
	end
end

sgs.xj_longhun_suit_value = {
	heart = 6.7,
	spade = 5,
	club = 4.2,
	diamond = 3.9,
}

function sgs.ai_cardneed.xj_longhun(to, card, self)
	if to:isNude() then return true end
	return card:getSuit() == sgs.Card_Heart or card:getSuit() == sgs.Card_Spade
end

--周宣
  --“寤寐”AI
sgs.ai_skill_invoke.xj_wumei = true

sgs.ai_skill_playerchosen.xj_wumei = function(self, targets)
	local targets = sgs.QList2Table(targets)
	self:sort(self.friends_noself)
	for _, p in ipairs(self.friends_noself) do
		if self:isFriend(p) then
			return p
		end
	end
	return self.player
end

  --“占梦”AI
sgs.ai_skill_invoke.xj_zhanmeng = true

sgs.ai_skill_choice.xj_zhanmeng = function(self, choices, data)
	if self.player:getMark("xj_zhanmengThree") == 0 then return "3" end --优先选3，12随缘
	return "1" or "2"
end

sgs.ai_skill_playerchosen.xj_zhanmeng = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
	    if self:isEnemy(p) and not p:isNude() then
		    return p
		end
	end
	return nil
end

--==武庙诸葛亮美化包==--
--电脑有一定概率更换皮肤
sgs.ai_skill_invoke.wmzgl_SkinChange = function(self, data)
    if math.random() > 0.5 then return true end
	return false
end

--【鞠躬尽瘁】
function SmartAI:useCardWmJugongjincui(card, use)
	if self.player:getHp() >= 3 and self.player:getMark("&WmJugongjincui") == 0 and not self.player:isLord() and not self.player:isProhibited(self.player, card) then
		use.card = card
	end
	return
end

sgs.ai_keep_value.WmJugongjincui = 3.2
sgs.ai_use_value.WmJugongjincui = 10
sgs.ai_use_priority.WmJugongjincui = 10
sgs.ai_card_intention.WmJugongjincui = 100

--【出师表】
sgs.weapon_range.WmChushibiao = 6
sgs.ai_use_priority.WmChushibiao = 2.75

--【八阵图】
sgs.ai_use_priority.WmBazhentu = 0.7
sgs.ai_skill_invoke["WmBazhentu"] = function(self, data)
	local target = data:toPlayer()
	if self:isFriend(target) then return false end
	return true
end

--【孔明灯】
sgs.ai_skill_invoke.WmKongmingdeng = function(self, data)
	if self.player:getHandcardNum() < 3 then return false end
	return true
end

sgs.ai_skill_playerchosen.WmKongmingdeng = function(self, targets)
	local targets = sgs.QList2Table(targets)
	self:sort(self.friends_noself)
	for _, p in ipairs(self.friends_noself) do --先给手牌少的
		if self:isFriend(p) and p:getHandcardNum() < 3 then
			return p
		end
	end
	for _, p in ipairs(self.friends_noself) do
		if self:isFriend(p) then
			return p
		end
	end
	return nil
end

sgs.ai_skill_discard.WmKongmingdeng = function(self)
	local to_discard = {}
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	table.insert(to_discard, cards[1]:getEffectiveId())
	return to_discard
end

--【火兽】
sgs.ai_skill_invoke.WmHuoshou = function(self, data)
	local target = data:toPlayer()
	if self:isFriend(target) then return false end
	if target:getArmor() and target:hasArmorEffect("silver_lion") then return false end --白银狮子，火兽的一生之敌（过河拆桥
	return true
end

--【七星灯】
sgs.ai_skill_choice.WM_addCards = function(self, choices, data)
	return "addQxd"
end
-------