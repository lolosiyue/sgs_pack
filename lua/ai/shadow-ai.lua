--����
--�ʵ�
local y_rende_skill = {}
y_rende_skill.name = "y_rende"
table.insert(sgs.ai_skills, y_rende_skill)
y_rende_skill.getTurnUseCard = function(self)
	if self.player:getHandcardNum() <= 1 then return end
	for _, player in ipairs(self.friends_noself) do
		if ((player:hasSkill("haoshi") and not player:containsTrick("supply_shortage"))
				or player:hasSkill("longluo") or (not player:containsTrick("indulgence") and player:hasSkill("yishe"))
				and player:faceUp()) or player:hasSkill("jijiu") then
			return sgs.Card_Parse("#y_rendecard:.:")
		end
	end
	if self.player:usedTimes("#y_rendecard") < 2 or self:getOverflow() > 0 then
		return sgs.Card_Parse("#y_rendecard:.:")
	end
	if self.player:getLostHp() > 0 then
		return sgs.Card_Parse("#y_rendecard:.:")
	end
end

sgs.ai_skill_use_func["#y_rendecard"] = function(card, use, self)
	local rd_card = {}
	local x = self.player:getHandcardNum()
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	self:sort(self.friends_noself, "defense")
	if x > 2 then
		for _, friend in ipairs(self.friends_noself) do
			for _, card in ipairs(cards) do
				use.card = sgs.Card_Parse("#y_rendecard:" .. card:getId() .. ":")
				if use.to then use.to:append(friend) end
				return
			end
		end
	elseif x == 2 then
		for _, friend in ipairs(self.friends_noself) do
			local i = 0
			for _, acard in ipairs(cards) do
				table.insert(rd_card, acard:getId())
				i = i + 1
				if i == 2 then
					use.card = sgs.Card_Parse("#y_rendecard:" .. table.concat(rd_card, "+") .. ":")
					if use.to then use.to:append(friend) end
					return
				end
			end
		end
	end
end
sgs.ai_use_value.y_rendecard = 8.5
sgs.ai_use_priority.y_rendecard = 8.8

--����ʦ
--����
local y_anxu_skill = {}
y_anxu_skill.name = "y_anxu"
table.insert(sgs.ai_skills, y_anxu_skill)
y_anxu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#y_anxucard") then return end
	local canuse = false
	for _, friend in ipairs(self.friends) do
		if friend:isWounded() then
			canuse = true
			break
		end
	end
	if canuse == true then
		return sgs.Card_Parse("#y_anxucard:.:")
	end
end

sgs.ai_skill_use_func["#y_anxucard"] = function(card, use, self)
	self:sort(self.friends, "hp")
	for _, friend in ipairs(self.friends) do
		if friend:isWounded() then
			--if not friend:containsTrick("indulgence") then
			local cards = self.player:getHandcards()
			for _, card in sgs.qlist(cards) do
				if not card:isKindOf("Peach") and not card:isKindOf("Shit") then
					use.card = sgs.Card_Parse("#y_anxucard:" .. card:getId() .. ":")
					if use.to then
						use.to:append(friend)
					end
					return
				end
			end
			--end
		end
	end
end

sgs.ai_skill_discard.y_anxu = function(self, discard_num, min_num, optional, include_equip)
	local to_discard = {}
	local cards = self.player:getCards("he")
	local x = self.player:getCardCount(true)
	cards = sgs.QList2Table(cards)
	self:sortByDynamicUsePriority(cards, true)
	local i
	for _, card in ipairs(cards) do
		table.insert(to_discard, card:getId())
		i = i + 1
		if i == discard_num then break end
	end
	return to_discard
end
sgs.ai_use_value.y_anxucard = 9
sgs.ai_use_priority.y_anxucard = 4.2
sgs.dynamic_value.benefit.y_anxucard = true

--������
--��װ
local y_rongzhuang_skill = {}
y_rongzhuang_skill.name = "y_rongzhuang"
table.insert(sgs.ai_skills, y_rongzhuang_skill)
y_rongzhuang_skill.getTurnUseCard = function(self)
	local hcards = self.player:getCards("h")
	local ecards = self.player:getCards("e")
	ecards = sgs.QList2Table(ecards)
	hcards = sgs.QList2Table(hcards)
	local x = self.player:getEquips():length()
	if x ~= 0 then
		local slashcard
		self:sortByUseValue(hcards, true)
		for _, hcard in ipairs(hcards) do
			for _, ecard in ipairs(ecards) do
				if ecard:getSuit() == hcard:getSuit() then
					slashcard = hcard
					break
				end
			end
			if slashcard then break end
		end
		if slashcard then
			local card_str = ("slash:y_rongzhuang[%s:%s]=%d"):format(slashcard:getSuitString(),
				slashcard:getNumberString(), slashcard:getEffectiveId())
			local slash = sgs.Card_Parse(card_str)
			assert(slash)
			return slash
		end
	end
end

function sgs.ai_cardsview.y_rongzhuang(self, class_name, player)
	local hcards = player:getCards("h")
	local ecards = player:getCards("e")
	local i = 0
	if class_name == "Jink" then
		for _, hcard in sgs.qlist(hcards) do
			i = 0
			for _, ecard in sgs.qlist(ecards) do
				if ecard:getSuit() == hcard:getSuit() then
					i = 1
					break
				end
			end
			if i == 0 then
				return ("jink:y_rongzhuang[%s:%s]=%d"):format(hcard:getSuitString(), hcard:getNumberString(),
					hcard:getEffectiveId())
			end
		end
	elseif class_name == "Slash" then
		for _, acard in sgs.qlist(hcards) do
			for _, bcard in sgs.qlist(ecards) do
				if bcard:getSuit() == acard:getSuit() then
					return ("slash:y_rongzhuang[%s:%s]=%d"):format(acard:getSuitString(), acard:getNumberString(),
						acard:getEffectiveId())
				end
			end
		end
	end
end

--����
sgs.ai_skill_invoke.y_chongqi = function(self, data)
	local p = data:toPlayer()
	return self:isEnemy(p)
end

sgs.y_mayunlu_keep_value =
{
	Peach = 6,
	Analeptic = 5.4,
	ExNihilo = 5.9,
	snatch = 5.3,
	EightDiagram = 5.7,
	RenwangShield = 5.8,
	OffensiveHorse = 5.1,
	DefensiveHorse = 5.2,
	Indulgence = 5.6,
	Nullification = 5.5,
	Dismantlement = 5.1,
	Crossbow = 5.0,
	Jink = 4,
	Slash = 4.1,
	ThunderSlash = 4.5,
	FireSlash = 4.9,

}

--��ά	
--־��		
sgs.ai_skill_invoke.y_zhiji = function(self, data)
	return true
end

--����	
local y_tiaoxin_skill = {}
y_tiaoxin_skill.name = "y_tiaoxin"
table.insert(sgs.ai_skills, y_tiaoxin_skill)
y_tiaoxin_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#y_tiaoxincard") then return end
	for _, enemy in ipairs(self.enemies) do
		if enemy:distanceTo(self.player) <= enemy:getAttackRange() then
			return sgs.Card_Parse("#y_tiaoxincard:.:")
		end
	end
end

sgs.ai_skill_use_func["#y_tiaoxincard"] = function(card, use, self)
	self:sort(self.enemies, "threat")
	for _, enemy in ipairs(self.enemies) do
		if enemy:distanceTo(self.player) <= enemy:getAttackRange() and
			(self:getCardsNum("Slash", enemy) == 0 or self:getCardsNum("Jink") > 0 or self.player:getHp() >= 2) and not enemy:isNude() then
			use.card = card
			if use.to then
				use.to:append(enemy)
			end
			return
		end
	end
end

--����
--�¾�
sgs.ai_skill_invoke.y_yongjue = function(self, data)
	local p = data:toPlayer()
	if self:isFriend(p) then
		return true
	else
		return false
	end
end

sgs.ai_skill_invoke.y_yjtargetmove = function(self, data)
	local use = data:toCardUse()
	if use.card:isKindOf("AmazingGrace") or use.card:isKindOf("ExNihilo") then return false end
	if use.card:isKindOf("GodSalvation") and self.player:isWounded() then return false end
	return true
end


--����
sgs.ai_skill_invoke.y_cunsi = function(self, data)
	if self.player:getRole() == "lord" then return false end
	if #self.friends_noself < 1 then return false end
	local x = self.player:getHandcardNum()
	if x == 1 then return true end
	local i = 0
	for _, card in sgs.qlist(self.player:getCards("h")) do
		if card:isKindOf("Peach") or card:isKindOf("Analeptic") then
			i = i + 1
		end
	end
	if i > 0 then return false end
	return true
end

sgs.ai_skill_playerchosen.y_cunsi = function(self, targets)
	for _, friend in ipairs(self.friends_noself) do
		if friend:hasSkill("longdan") then
			return friend
		end
	end
	for _, tar in sgs.qlist(targets) do
		if self:isFriend(tar) then
			return tar
		end
	end
end

sgs.ai_skill_cardchosen.y_cunsi = function(self, who, flags)
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card then
			self:setCardFlag(card:getId(), "tjcard")
			break
		end
	end
	return card_for_y_toujing(self, who, "tjcard")
end

--��ٻ
--����
local y_shenzhi_skill = {}
y_shenzhi_skill.name = "y_shenzhi"
table.insert(sgs.ai_skills, y_shenzhi_skill)
y_shenzhi_skill.getTurnUseCard = function(self)
	if self.player:getHp() >= self.player:getHandcardNum() then return end
	if self.player:isWounded() then
		local card_str = ("peach:y_shenzhi[no_suit:0]=.")
		local peach = sgs.Card_Parse(card_str)
		assert(peach)
		return peach
	end
end

function sgs.ai_cardsview.y_shenzhi(self, class_name, player)
	if class_name == "Peach" then
		local x = player:getHp()
		local y = player:getHandcardNum()
		if x < 0 then x = 0 end
		if y > x then
			return ("peach:y_shenzhi[no_suit:0]=.")
		end
	end
end

--����
sgs.ai_skill_invoke.y_shushen = function(self, data)
	if #self.friends_noself > 0 then
		return true
	else
		for _, enemy in ipairs(self.enemies) do
			if enemy:hasSkill("kongcheng") and enemy:isKongcheng() then
				return true
			end
		end
	end
	return false
end

sgs.ai_skill_playerchosen.y_shushen = function(self, targets)
	self:sort(self.friends, "defense")
	for _, friend in ipairs(self.friends) do
		if friend:getHandcardNum() < friend:getHp() and not (friend:hasSkill("kongcheng") and friend:isKongcheng()) then
			return friend
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if enemy:hasSkill("kongcheng") and enemy:isKongcheng() then
			return enemy
		end
	end
end

--����
--����
sgs.ai_skill_invoke.y_baiyi = function(self, data)
	if self.player:isNude() then return false end
	if (self:getCardsNum("JinK") == 1 or self:getCardsNum("Peach") == 1) and self.player:getHandcardNum() == 1 then return false end
	return true
end

sgs.ai_skill_invoke.y_baiyier = function(self, data)
	for _, enemy in ipairs(self.enemies) do
		if not enemy:isNude() then
			return true
		end
	end
	for _, friend in ipairs(self.friends) do
		if friend:containsTrick("indulgence") or friend:containsTrick("supply_shortage") or friend:containsTrick("lightning") then
			return true
		end
	end
	return false
end

sgs.ai_skill_playerchosen.y_baiyi = function(self, targets)
	for _, friend in ipairs(self.friends) do
		if friend:containsTrick("indulgence") or friend:containsTrick("supply_shortage") then
			return friend
		end
		if friend:containsTrick("lightning") then
			for _, enemy in ipairs(self.enemies) do
				if enemy:hasSkill("guicai") or enemy:hasSkill("guidao") or enemy:hasSkill("guanxing") then
					return friend
				end
			end
		end
	end
	self:sort(self.enemies, "defense")
	for _, en in ipairs(self.enemies) do
		if not en:isNude() then
			return en
		end
	end
end
sgs.ai_skill_invoke.y_yuanjiu = function(self, data)
	for _, acard in sgs.qlist(self.player:getPile("y_yuanjiuPile")) do
		for _, bcard in sgs.qlist(self.player:getPile("y_yuanjiuPile")) do
			if acard ~= bcard and sgs.Sanguosha:getCard(acard):getNumber() == sgs.Sanguosha:getCard(bcard):getNumber() then
				return true
			end
		end
	end
	local dying = data:toDying()
	if self:askForSinglePeach(dying.who) then return true end
	return false
end

--[[��̩
--Ԯ��
sgs.ai_skill_invoke.y_yuanjiu = function(self, data)
    local x = self.player:getPile("y_yuanjiuPile"):length()
	local pcards=self.player:getPile("y_yuanjiuPile")
	local can_peach=true
	if x>0 then
		for _, acard in sgs.qlist(pcards) do
            for _, bcard in sgs.qlist(pcards) do
		        if acard~=bcard and sgs.Sanguosha:getCard(acard):getNumber()==sgs.Sanguosha:getCard(bcard):getNumber() then
					can_peach = false break
				end
			end
			if can_peach==false then break end
		end
	end
    local cards=self.player:getCards("h")
	local y = self.player:getHandcardNum()
	local dy = data:toDying()
	if can_peach==true then
	    if self:isFriend(dy.who) then
		    return true
		else
		    return false
		end
	else
	    return true
	end
end
			
sgs.ai_skill_cardchosen.y_yuanjiu = function(self, who, flags)
    local hcard = self.player:getCards("h")
	local pcard = self.player:getPile("y_yuanjiuPile")
	local x = self.player:getPile("y_yuanjiuPile"):length()
	local i=0
    for _, acard in sgs.qlist(hcard) do
		for _, bcard in sgs.qlist(pcard) do
		    local ccard = sgs.Sanguosha:getCard(bcard)
			if ccard:getNumber()~=acard:getNumber() then
				i=i+1
                if i==x then
                    self:setCardFlag(acard:getId(),"pcard")				
					return card_for_y_yuanjiu(self, who, "pcard")
				end
			end
		end
	end
end

sgs.ai_skill_askforag.y_yuanjiu = function(self, card_ids)
    for _, card_id in ipairs(card_ids) do
	    if sgs.Sanguosha:getCard(card_id):isKindOf("Peach")then
			return card_id
        end
		if sgs.Sanguosha:getCard(card_id):isKindOf("Analeptic") and self.player:getHp()<1 then
		    return card_id
		end
    end	
    for i, card_id2 in ipairs(card_ids) do
        for j, card_id3 in ipairs(card_ids) do
            if i ~= j and sgs.Sanguosha:getCard(card_id2):getNumber() == sgs.Sanguosha:getCard(card_id3):getNumber() then
                return card_id2
            end
        end
    end
end]]

--����
--�ⷳ
--jfskills = {"buqu","tuntian","quanji"}
--jfpiles = {"buqu","field","power"}

local y_jiefan_skill = {}
y_jiefan_skill.name = "y_jiefan"
table.insert(sgs.ai_skills, y_jiefan_skill)
y_jiefan_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#y_jiefancard") then return nil end
	return sgs.Card_Parse("#y_jiefancard:.:")
end

sgs.ai_skill_use_func["#y_jiefancard"] = function(card, use, self)
	use.card = card
	--[[for _, friend in ipairs(self.friends) do
        if friend:containsTrick("indulgence") or friend:containsTrick("supply_shortage") or friend:containsTrick("lightning") then
			if use.to then
                use.to:append(friend)
			end
			return
		end
		if friend:isWounded() then
		    if friend:getArmor() and friend:getArmor():isKindOf("SilverLion") then
			    if use.to then
                    use.to:append(friend)
				end
			    return
			end
		end
		if friend:hasSkill("xiaoji") or friend:hasSkill("xuanfeng") then
		    if friend:getEquips():length()>0 then
			    if use.to then
                    use.to:append(friend)
				end
			    return
			end
		end
	    if friend:hasSkill(jfskills[1]) and friend:getPile(jfpiles[1]):length()>0 then
		    if use.to then
                use.to:append(friend)
			end
			return
		end
	end]]
	for _, enemy in ipairs(self.enemies) do
		--[[ for i=2, 99, 1 do
	        if enemy:hasSkill(jfskills[i]) and enemy:getPile(jfpiles[i]):length()>0 then
		        if use.to then
                    use.to:append(enemy)
				end
				return
			end
		end]]
		if enemy:getEquips():length() > 0 then
			if not enemy:hasSkill("xiaoji") and not enemy:hasSkill("xuanfeng") then
				for _, ecard in sgs.qlist(enemy:getCards("e")) do
					if ecard:isKindOf("Armor") or ecard:isKindOf("DefensiveHorse") or ecard:isKindOf("Weapon") then
						if use.to then
							use.to:append(enemy)
						end
						return
					end
				end
			end
		end
	end
	if use.to then
		use.to:append(self.player)
	end
	return
end

sgs.ai_skill_choice.y_jiefan = function(self, choices)
	return "draw"
end

--����
--����		
y_huanshi_skill = {}
y_huanshi_skill.name = "y_huanshi"
table.insert(sgs.ai_skills, y_huanshi_skill)
y_huanshi_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#y_huanshicard") then return end
	local t = 0
	for _, p in ipairs(self.friends_noself) do
		if p:getHandcardNum() > 0 then t = t + 1 end
	end
	for _, q in ipairs(self.enemies) do
		if q:getHandcardNum() > 0 then t = t + 1 end
	end
	if t > 1 then
		return sgs.Card_Parse("#y_huanshicard:.:")
	end
end

sgs.ai_skill_use_func["#y_huanshicard"] = function(card, use, self)
	use.card = card
	if #self.friends_noself >= 1 then
		local friends = {}
		for _, friend in ipairs(self.friends_noself) do
			if not friend:isKongcheng() then
				table.insert(friends, friend)
			end
		end
		if #friends >= 2 then
			if use.to then
				use.to:append(friends[1])
				use.to:append(friends[2])
				return
			end
		elseif #friends == 1 then
			self:sort(self.enemies, "defense")
			for _, enemy in ipairs(self.enemies) do
				if not enemy:isKongcheng() then
					if use.to then
						use.to:append(enemy)
						use.to:append(friends[1])
						return
					end
				end
			end
		end
	end
	return nil
end

--��Ԯ
sgs.ai_skill_use["@@y_hongyuan"] = function(self, prompt)
	local targets = {}
	for _, friend in ipairs(self.friends) do
		if self.player:inMyAttackRange(friend) or self.player:getSeat() == friend:getSeat() then
			table.insert(targets, friend:objectName())
		end
	end
	return "#y_hongyuancard:.:->" .. table.concat(targets, "+")
end

--����
--����
sgs.ai_skill_invoke.y_zishou = function(self, data)
	local x = self.player:getLostHp()
	local y = self.player:getHp()
	local j, s, p, n = 0, 0, 0, 0
	for _, card in sgs.qlist(self.player:getHandcards()) do
		if card:isKindOf("Jink") then
			j = j + 1
		elseif card:isKindOf("Slash") then
			s = s + 1
		elseif card:isKindOf("Nullification") then
			n = n + 1
		elseif card:isKindOf("Peach") then
			p = p + 1
		end
	end
	if x >= 2 then
		return true
	elseif x == 1 then
		if s > 0 and self.player:canSlash() then
			if y >= (j + s + n) then
				return true
			end
		elseif y > (j + s + n) then
			return true
		end
	elseif x < 1 then
		if s > 0 and self.player:canSlash() then
			if (y - (j + s + n + p)) >= 2 then
				return true
			end
		elseif (y - (j + s + n + p)) > 2 then
			return true
		end
	end
	return false
end

--����

sgs.ai_skill_use["@@y_yangzheng"] = function(self, prompt)
	if self.player:getMark("y_yzRec") == 1 then return end
	if #self.friends_noself < 1 then return end
	local x = self.player:getHandcardNum()
	local y = self.player:getHp()
	if x < y then return end
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	self:sort(self.friends_noself, "defense")
	for _, friend in ipairs(self.friends_noself) do
		if not friend:containsTrick("indulgence") then
			for _, card in ipairs(cards) do
				return "#y_yangzhengcard:" .. card:getId() .. ":->" .. friend:objectName()
			end
		end
	end
end

--½ѷ
--��Ӫ
y_fenying_skill = {}
y_fenying_skill.name = "y_fenying"
table.insert(sgs.ai_skills, y_fenying_skill)
y_fenying_skill.getTurnUseCard = function(self)
	for _, en in ipairs(self.enemies) do
		if not en:isKongcheng() and en:getHandcardNum() < self.player:getHandcardNum() and self.player:canPindian(en)
			and (en:getHandcardNum() < 3 or ((self.player:getHandcardNum() - self.player:getHp()) - en:getHandcardNum()) > -1) then
			return sgs.Card_Parse("#y_fenyingcard:.:")
		end
	end
	return
end

sgs.ai_skill_use_func["#y_fenyingcard"] = function(card, use, self)
	local tar
	self:sort(self.enemies, "defense")
	for _, en in ipairs(self.enemies) do
		if not en:isKongcheng() and en:getHandcardNum() < self.player:getHandcardNum() and self.player:canPindian(en) then
			tar = en
			break
		end
	end
	if tar then
		local x = tar:getHandcardNum()
		local fy_card = {}
		local cards = sgs.QList2Table(self.player:getCards("he"))
		self:sortByDynamicUsePriority(cards, true)
		local i = 0
		for _, acard in ipairs(cards) do
			table.insert(fy_card, acard:getId())
			i = i + 1
			if i == x then break end
		end
		use.card = sgs.Card_Parse("#y_fenyingcard:" .. table.concat(fy_card, "+") .. ":")
		if use.to then
			use.to:append(tar)
		end
		return
	end
end

sgs.ai_skill_invoke.y_fenying = function(self, data)
	return true
end

--����
sgs.ai_skill_invoke.y_dushi = function(self, data)
	if self.player:getHandcardNum() < self.player:getHp() then
		return true
	else
		for _, en in ipairs(self.enemies) do
			if not en:isNude() then
				return true
			end
		end
		for _, fr in ipairs(self.friends) do
			if self:isFriend(fr) then
				if fr:containsTrick("indulgence") or fr:containsTrick("supply_shortage") then
					return true
				elseif fr:containsTrick("lightning") then
					for _, fr in ipairs(self.friends) do
						if fr:hasSkill("guicai") or fr:hasSkill("guidao") or fr:hasSkill("guanxing") then
							return false
						end
					end
					return true
				end
			end
		end
	end
	return false
end

function sgs.ai_slash_prohibit.y_dushi(self, to)
	if to:getHandcardNum() == to:getHp() then return false end
	if to:getHandcardNum() > to:getHp() then
		if to:getHp() > 1 then return true end
	end
end

sgs.ai_skill_playerchosen.y_dushi = function(self, targets)
	for _, t in sgs.qlist(targets) do
		if self:isFriend(t) then
			if t:containsTrick("indulgence") or t:containsTrick("supply_shortage") then
				return t
			elseif t:containsTrick("lightning") then
				local target = true
				for _, fr in ipairs(self.friends) do
					if fr:hasSkill("guicai") or fr:hasSkill("guidao") or fr:hasSkill("guanxing") then
						target = false
					end
				end
				if target == true then return t end
			end
		elseif self:isEnemy(t) then
			if t:getHandcardNum() == 1 and self.player:isWounded() then
				return t
			end
		end
	end
	self:sort(self.enemies, "defense")
	for _, en in ipairs(self.enemies) do
		if not en:isNude() then
			return en
		end
	end
end

--����
--�ɱ
sgs.ai_skill_invoke.y_zhensha = function(self, data)
	local player = data:toPlayer()
	return self:isEnemy(player)
end

--ʶ��
sgs.ai_skill_invoke.y_shipo = function(self, data)
	for _, p in ipairs(self.enemies) do
		if not p:isKongcheng() then
			return true
		end
	end
	return false
end

sgs.ai_skill_playerchosen.y_shipo = function(self, targets)
	self:sort(self.enemies, "defense")
	for _, p in ipairs(self.enemies) do
		if not p:isKongcheng() then
			return p
		end
	end
end

function sgs.ai_slash_prohibit.y_shipo(self, to)
	if to:getHp() == 1 then
		return self:getCardsNum("Analpetic") + self:getCardsNum("Peach") > 0
	end
	return self:getCardsNum("Jink") > 0 and (self.player:getHandcardNum() - self:getCardsNum("Jink")) < 2
end

--�����
--���
local y_wuji_skill = {}
y_wuji_skill.name = "y_wuji"
table.insert(sgs.ai_skills, y_wuji_skill)
y_wuji_skill.getTurnUseCard = function(self)
	if self.player:getHandcardNum() < 2 then return end
	if self.player:getHandcardNum() < 3 and self.player:getHp() == 1 then return end
	local enemy = false
	for _, en in ipairs(self.enemies) do
		if self.player:distanceTo(en) <= self.player:getAttackRange() + 1 then
			enemy = true
		end
	end
	if enemy == false then return end
	if self.player:hasFlag("addjink") and self.player:hasFlag("addtar") and self.player:hasFlag("addrange") then return end
	-- if not self.player:canSlashWithoutCrossbow() and not (self.player:getWeapon() and self.player:getWeapon():getClassName() == "Crossbow") then return end
	local s, p = false, false
	for _, card in sgs.qlist(self.player:getCards("h")) do
		if not card:isKindOf("Peach") and not card:isKindOf("Slash") then
			p = true
		end
		if card:isKindOf("Slash") then
			s = true
		end
	end
	if self.player:getHandcardNum() > self.player:getHp() then p = true end
	if s ~= true or p ~= true then return end
	return sgs.Card_Parse("#y_wujicard:.:")
end

sgs.ai_skill_use_func["#y_wujicard"] = function(card, use, self)
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _, card in ipairs(cards) do
		if not card:isKindOf("Peach") then
			if self:getCardsNum("Slash") > 1 then
				use.card = sgs.Card_Parse("#y_wujicard:" .. card:getId() .. ":")
				return
			elseif not card:isKindOf("Slash") then
				use.card = sgs.Card_Parse("#y_wujicard:" .. card:getId() .. ":")
				return
			end
		end
	end
end

sgs.ai_skill_choice.Y_wuji = function(self, choices)
	local i = 0
	for _, p in ipairs(self.enemies) do
		if self.player:canSlash(p) then
			i = i + 1
		end
	end
	if i > 1 then
		if not self.player:hasFlag("addtar") then
			return "addtar"
		end
		if not self.player:hasFlag("addjink") then
			return "addjink"
		end
	end
	if not self.player:hasFlag("addrange") then
		return "addrange"
	end
end

--����
sgs.ai_skill_invoke.y_laoyue = true

sgs.ai_use_value.y_wujicard = 4

--��Ԫ
--����
local y_shenzhu_skill = {}
y_shenzhu_skill.name = "y_shenzhu"
table.insert(sgs.ai_skills, y_shenzhu_skill)
y_shenzhu_skill.getTurnUseCard = function(self)
	if self.player:isKongcheng() then return end
	if self.player:hasUsed("#y_shenzhucard") then return end
	--if self.player:hasFlag("y_szempty") then return end
	local sz = false
	for _, card in sgs.qlist(self.player:getCards("h")) do
		if card:isKindOf("Slash") then
			sz = true
			break
		end
	end
	if sz == true then
		return sgs.Card_Parse("#y_shenzhucard:.:")
	end
end

sgs.ai_skill_use_func["#y_shenzhucard"] = function(card, use, self)
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards, true)
	for _, card in ipairs(cards) do
		if card:isKindOf("Slash") then
			use.card = sgs.Card_Parse("#y_shenzhucard:" .. card:getId() .. ":")
			return
		end
	end
end

sgs.ai_skill_askforag.y_shenzhu = function(self, card_ids)
	self:sortByUseValue(card_ids)
	for _, id in ipairs(card_ids) do
		local card = sgs.Sanguosha:getCard(id)
		for _, p in ipairs(self.friends) do
			if card:isKindOf("Armor") and not card:isKindOf("Vine") and not p:getArmor() then
				return id
			elseif card:isKindOf("DefensiveHorse") and not p:getDefensiveHorse() then
				return id
			elseif card:isKindOf("Weapon") and not p:getWeapon() then
				return id
			elseif card:isKindOf("OffensiveHorse") and not p:getOffensiveHorse() then
				return id
			end
		end
	end
	local cid
	for _, id in ipairs(card_ids) do
		local card = sgs.Sanguosha:getCard(id)
		if card:isKindOf("FireSlash") then
			cid = id
			break
		elseif card:isKindOf("ThunderSlash") then
			cid = id
		elseif sgs.Sanguosha:getCard(id):isKindOf("Slash") and not card:isKindOf("ThunderSlash") then
			cid = id
		end
	end
	if cid ~= nil then return cid end
end

sgs.ai_skill_playerchosen.y_shenzhu = function(self, targets)
	for _, tar in sgs.qlist(targets) do
		if self:isFriend(tar) then
			return tar
		end
	end
end

--����
sgs.ai_skill_invoke.y_bailian = function(self, data)
	return true
end

--�Ƴ���
--����
sgs.ai_skill_invoke.y_caipei = function(self, data)
	for _, fr in ipairs(self.friends) do
		if not fr:isKongcheng() then
			return self:getCardsNum("Peach") < self.player:getHandcardNum()
		end
	end
end

sgs.ai_skill_playerchosen.y_caipei = function(self, targets)
	local cur = self.room:getCurrent()
	if self:isFriend(cur) then
		return cur
	else
		for _, fr in ipairs(self.friends) do
			if not fr:isKongcheng() then
				return fr
			end
		end
	end
end

function sgs.ai_cardneed.y_caipei(to, card)
	return card:getTypeId() == sgs.Card_TypeTrick
end

--����
sgs.ai_skill_invoke.y_kongzhen = function(self, data)
	local player = data:toPlayer()
	return self:isFriend(player)
end


--½��
--����
sgs.ai_skill_invoke.y_huaiju = function(self, data)
	local move = data:toMoveOneTime()
	if move.from:getSeat() ~= self.player:getSeat() then
		return true
	elseif move.from:getSeat() == self.player:getSeat() then
		if #self.friends_noself > 0 then return true end
	end
	return false
end

sgs.ai_skill_playerchosen.y_huaiju = function(self, targets)
	self:sort(self.friends_noself, "defense")
	for _, fr in ipairs(self.friends_noself) do
		if not (fr:hasSkill("kongcheng") and fr:isKongcheng()) and not fr:hasSkill("keji") then
			return fr
		end
	end
	for _, f in ipairs(self.friends_noself) do
		if f then return f end
	end
end

--����
sgs.ai_skill_use["@@y_huntian"] = function(self, prompt)
	local cards = sgs.QList2Table(self.player:getHandcards())
	local htcard
	local nextplayer = self.player:getNextAlive()
	self:sortByUseValue(cards, true)
	for _, card in ipairs(cards) do
		if (self.player:containsTrick("supply_shortage") and card:getSuit() == sgs.Card_Club)
			or (self.player:containsTrick("indulgence") and card:getSuit() == sgs.Card_Heart)
			or (self.player:containsTrick("lightning") and card:getSuit() ~= sgs.Card_Spade) then
			htcard = card
			break
		end
	end
	if not htcard then
		for _, acard in ipairs(cards) do
			if self:isFriend(nextplayer) then
				if (nextplayer:containsTrick("supply_shortage") and acard:getSuit() == sgs.Card_Club)
					or (nextplayer:containsTrick("indulgence") and acard:getSuit() == sgs.Card_Heart)
					or (nextplayer:containsTrick("lightning") and acard:getSuit() ~= sgs.Card_Spade) then
					htcard = acard
					break
				end
			elseif self:isEnemy(nextplayer) then
				if (nextplayer:containsTrick("lightning") and acard:getSuit() == sgs.Card_Spade) then
					htcard = acard
					break
				end
			end
		end
	end
	if not htcard then
		for _, c in ipairs(cards) do
			if c then
				htcard = c
				break
			end
		end
	end
	return "#y_huntiancard:" .. htcard:getId() .. ":"
end

sgs.ai_skill_choice.y_huntian = function(self, choices)
	local heart, spade, club, spade, notspade
	local peach = 0
	for _, c in sgs.qlist(self.player:getCards("h")) do
		if c:getSuit() == sgs.Card_Heart then
			heart = true
		elseif c:getSuit() == sgs.Card_Spade then
			spade = true
		elseif c:getSuit() == sgs.Card_Club then
			club = true
		end
		if c:getSuit() ~= sgs.Card_Spade then
			notspade = true
		elseif c:getSuit() == sgs.Card_Spade then
			spade = true
		end
		if c:isKingOf("Peach") then
			peach = peach + 1
		end
	end
	local nextplayer = self.player:getNextAlive()
	if (self.player:containsTrick("supply_shortage") and club == true)
		or (self.player:containsTrick("indulgence") and heart == true)
		or (self.player:containsTrick("lightning") and notspade == true) then
		return "1"
	elseif self.player:getHandcardNum() == peach then
		if self.player:isWounded() then
			return "2"
		elseif self:isFriend(nextplayer) and nextplayer:isWounded() and not nextplayer:containsTrick("supply_shortage") and not nextplayer:containsTrick("indulgence") then
			return "4"
		else
			return "2"
		end
	elseif self:isFriend(nextplayer) then
		if nextplayer:containsTrick("supply_shortage") then
			if club == true then
				return "3"
			else
				return "5"
			end
		elseif nextplayer:containsTrick("indulgence") then
			if heart == true then
				return "3"
			else
				return "2"
			end
		elseif nextplayer:containsTrick("lightning") then
			if notspade == true then
				return "3"
			else
				return "5"
			end
		else
			return "5"
		end
	elseif self:isEnemy(nextplayer) then
		if nextplayer:containsTrick("lightning") then
			if spade == true then
				return "3"
			else
				return "5"
			end
		else
			return "4"
		end
	else
		return "4"
	end
end

sgs.ai_skill_invoke.y_huntian2 = true

sgs.ai_skill_choice.y_huntian2 = function(self, choices, data)
	local p = data:toPlayer()
	if self:isFriend(p) then
		return "htdraw"
	else
		return "htdiscard"
	end
end

--����
--δ��
sgs.ai_skill_invoke.y_weiji = function(self, data)
	if self.player:getMaxHp() == 1 then
		if self:getCardsNum("Peach") > 0 or self:getCardsNum("Analeptic") > 0 then
			return true
		end
	elseif self.player:getMaxHp() > 1 then
		return true
	end
	return false
end

sgs.ai_skill_playerchosen.y_weiji = function(self, targets)
	self:sort(self.friends, "defense")
	local minhp = 9
	local minhcards = 99
	local tar = self.player
	for _, fr in ipairs(self.friends) do
		if fr:getHp() < minhp and (not fr:containsTrick("indulgence")) and not ((fr:hasSkill("kongcheng") or fr:hasSkill("kongzhen")) and fr:isKongcheng()) then
			minhp = fr:getHp()
			tar = fr
		elseif fr:getHandcardNum() == minhcards and (not fr:containsTrick("indulgence")) and not ((fr:hasSkill("kongcheng") or fr:hasSkill("kongzhen")) and fr:isKongcheng()) then
			minhcards = fr:getHandcardNum()
			tar = fr
		end
	end
	return tar
end

--����
function sgs.ai_cardsview.y_jiushang(self, class_name, player)
	if class_name == "Analeptic" then
		if player:getMaxHp() > 1 and player:getLostHp() > 0 then
			return ("analeptic:y_jiushang[no_suit:0]=.")
		end
	end
end

--½��
--��ϧ
y_xiangxi_skill = {}
y_xiangxi_skill.name = "y_xiangxi"
table.insert(sgs.ai_skills, y_xiangxi_skill)
y_xiangxi_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#y_xiangxicard") then return end
	if #self.friends_noself > 0 then
		return sgs.Card_Parse("#y_xiangxicard:.:")
	end
end

sgs.ai_skill_use_func["#y_xiangxicard"] = function(card, use, self)
	local target
	local tarA, tarB, tarC, tarD, tarE
	for _, f in ipairs(self.friends_noself) do
		if (f:containsTrick("supply_shortage") or f:containsTrick("indulgence")) and (self.player:getHandcardNum() - self.player:getHp()) < 2 then
			tarA = f
		elseif f:getEquips():length() > 0 then
			if f:hasSkill("xiaoji") or f:hasSkill("xuanfeng") then
				tarC = f
			elseif f:isWounded() and f:getArmor() and f:getArmor():objectName() == "silverlion" then
				tarB = f
			end
		elseif (self.player:getMark("y_kegou") == 1 and f:getHandcardNum() - f:getHp() >= 1 and f:getHandcardNum() >= self.player:getHandcardNum()) then
			tarB = f
		elseif (self.player:getMark("y_kegou") ~= 1 and self.player:getHandcardNum() - self.player:getHp() > 1 and f:getHandcardNum() < self.player:getHandcardNum()) then
			tarC = f
		elseif self.player:isWounded() then
			tarD = f
		else
			tarE = f
		end
	end
	if tarE then target = tarE end
	if tarD then target = tarD end
	if tarC then target = tarC end
	if tarB then target = tarB end
	if tarA then target = tarA end
	if target ~= nil then
		use.card = card
		if use.to then
			use.to:append(target)
		end
	end
end

sgs.ai_skill_choice.y_xiangxi = function(self, choices, data)
	local lk = data:toPlayer()
	if self:isFriend(lk) and lk:isWounded() and math.abs(lk:getHandcardNum() - self.player:getHandcardNum()) < 2 then
		return "j"
	elseif lk:getHandcardNum() - self.player:getHandcardNum() > 1 then
		return "h"
	elseif (self.player:containsTrick("supply_shortage") and (self.player:hasSkill("yongsi") or self.player:hasSkill("tuxi"))) or self.player:containsTrick("indulgence") then
		return "j"
	elseif self.player:hasSkill("xiaoji") or self.player:hasSkill("xuanfeng") then
		return "e"
	elseif self.player:isWounded() and self.player:getArmor():objectName() == "silverlion" then
		return "e"
	elseif (self:isFriend(lk) and lk:isWounded()) or (not self:isFriend(lk) and not lk:isWounded()) then
		return "j"
	else
		return "h"
	end
end

--�˹�
sgs.ai_skill_invoke.y_kegou = true

--���
sgs.ai_skill_invoke.y_yingzi = true

--��³��
--�ؾ�
sgs.ai_skill_invoke.y_shouju = function(self, data)
	local id = data:toInt()
	local card = sgs.Sanguosha:getCard(id)
	local sj = false
	self:sort(self.friends, "defense")
	for _, p in ipairs(self.friends) do
		if (card:isKindOf("Armor") and not p:getArmor()) or (card:isKindOf("Weapon") and not p:getWeapon())
			or (card:isKindOf("DefensiveHorse") and not p:getDefensiveHorse())
			or (card:isKindOf("OffensiveHorse") and not p:getOffensiveHorse()) then
			sj = true
		end
	end
	if sj == false then return false end
	for _, c in sgs.qlist(self.player:getCards("h")) do
		if c:isKindOf("Basic") and not c:isKindOf("Peach") then
			return true
		end
	end
	return false
end

sgs.ai_skill_playerchosen.y_shouju = function(self, targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets, "defense")
	for _, t in ipairs(targets) do
		if t:hasFlag("y_eqcard") then
			for _, ts in ipairs(targets) do
				if ts:getSeat() == self.player:getSeat() then
					return ts
				end
			end
			if self:isFriend(t) then
				return t
			end
		elseif t:hasFlag("y_dtcard") then
			if self:isEnemy(t) then
				return t
			end
		end
	end
end


--����
sgs.ai_skill_invoke.y_wenliang = function(self, data)
	local p = data:toPlayer()
	if self:isFriend(p) then
		if p:getArmor() and p:getArmor():objectName() == "silverlion" and p:isWounded() then return true end
		if not (p:getArmor() and p:getArmor():isKindOf("EightDiagram")) then
			if p:getHandcardNum() < 2 and p:getHp() == 1 then return true end
			for _, c in sgs.qlist(self.player:getCards("h")) do
				if not c:isKindOf("Peach") then
					return true
				end
			end
		else
			return p:isKongcheng() and p:getHp() == 1
		end
	elseif self:isEnemy(p) then
		if p:getHp() == 1 or p:getHandcardNum() <= 1 then
			return false
		elseif (p:getArmor() and (p:getArmor():isKindOf("EightDiagram") or p:getArmor():isKindOf("RenwangShield")))
			or (p:getDefensiveHorse() or p:getWeapon() or p:getOffensiveHorse()) then
			return true
		end
	end
	return false
end

--����
sgs.ai_skill_invoke.y_duoqi = function(self, data)
	return true
end


sgs.ai_skill_invoke.y_youfang = function(self, data)
	local move = data:toMoveOneTime()
	if not move.from or not move.from:isAlive() then return false end
	if move.from and self:isFriend(move.from) then
		return true
	end
	return false
end

sgs.ai_skill_choice.y_youfang = function(self, choices, data)
	local move = data:toMoveOneTime()
	local target = move.from
	choices = choices:split("+")
	if self:isFriend(target) then
		if table.contains(choices, "recover") and target:getLostHp() > 0 and self:isWeak(target) then
			return "recover"
		end
		if table.contains(choices, "draw") and self:needBear(target) then
			return "draw"
		end
		if table.contains(choices, "recover") and target:getLostHp() > 0 then
			return "recover"
		end
	end
	return "draw"
end


sgs.ai_skill_invoke.y_zhixi = function(self, data)
	local move = data:toMoveOneTime()
	if not move.to or not move.to:isAlive() then return false end
	if move.to and self:isFriend(move.to) then
		return false
	end
	return true
end


sgs.ai_skill_invoke.y_xiaoyi = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.y_xiaoyi = function(self, targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets, "defense")
	local card = self.player:getTag("y_xiaoyi"):toCard()
	local cards = sgs.CardList()
	cards:append(card)
	local cards = sgs.QList2Table(cards)
	local c, friend = self:getCardNeedPlayer(cards)
	if c and friend then
		return friend
	end
	return self.player
end


local y_lianzhu_skill = {}
y_lianzhu_skill.name = "y_lianzhu"
table.insert(sgs.ai_skills, y_lianzhu_skill)
y_lianzhu_skill.getTurnUseCard = function(self, inclusive)
	if not self.player:hasUsed("#y_lianzhucard") then
		return sgs.Card_Parse("#y_lianzhucard:.:")
	end
end

sgs.ai_skill_use_func["#y_lianzhucard"] = function(card, use, self)
	self:updatePlayers()
	local targets = {}


	for _, friend in ipairs(self.friends) do
		table.insert(targets, friend:objectName())
	end


	local handcards = sgs.QList2Table(self.player:getCards("h"))
	local discard_cards = {}

	for _, c in ipairs(handcards) do
		if not c:isKindOf("Peach")
			and not c:isKindOf("Duel")
			and not c:isKindOf("Indulgence")
			and not c:isKindOf("SupplyShortage")
			and not (self:getCardsNum("Jink") == 1 and c:isKindOf("Jink"))
			and not (self:getCardsNum("Analeptic") == 1 and c:isKindOf("Analeptic"))
		then
			table.insert(discard_cards, c:getEffectiveId())
			if (#discard_cards >= #targets) then break end
		end
	end
	if #discard_cards > 0 and #discard_cards == #targets then
		use.card = sgs.Card_Parse(string.format("#y_lianzhucard:%s:", table.concat(discard_cards, "+")))
		if use.to then
			for _, friend in ipairs(self.friends) do
				if use.to:length() < #discard_cards then
					use.to:append(friend)
				else
					break
				end
			end
		end
	end
end

sgs.ai_skill_invoke.y_fanjin = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.y_fanjin = function(self, targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets, "defense")

	for _, p in ipairs(targets) do
		if self:isEnemy(p) and not p:isKongcheng() then
			local list = self.player:property("y_fanjin"):toString():split("+")
			if #list > 0 then
				local allhas = true
				for _, l in pairs(list) do
					local handcards = sgs.QList2Table(p:getCards("h"))
					local has = false
					for _, c in ipairs(handcards) do
						if c:getEffectiveId() == tonumber(l) then
							has = true
						end
						if not has then
							allhas = false
						end
					end
				end
				if not allhas then
					return p
				end
			end
		end
	end
	for _, p in ipairs(targets) do
		if not self:isFriend(p) and not p:isKongcheng() then
			local list = self.player:property("y_fanjin"):toString():split("+")
			if #list > 0 then
				local allhas = true
				for _, l in pairs(list) do
					local handcards = sgs.QList2Table(p:getCards("h"))
					local has = false
					for _, c in ipairs(handcards) do
						if c:getEffectiveId() == tonumber(l) then
							has = true
						end
						if not has then
							allhas = false
						end
					end
				end
				if not allhas then
					return p
				end
			end
		end
	end
	for _, p in ipairs(targets) do
		if self:isFriend(p) and not p:isKongcheng() then
			local list = self.player:property("y_fanjin"):toString():split("+")
			if #list > 0 then
				local allhas = true
				for _, l in pairs(list) do
					local handcards = sgs.QList2Table(p:getCards("h"))
					local has = false
					for _, c in ipairs(handcards) do
						if c:getEffectiveId() == tonumber(l) then
							has = true
						end
						if not has then
							allhas = false
						end
					end
				end
				if not allhas then
					return p
				end
			end
		end
	end
	return targets[1]
end

sgs.ai_skill_cardchosen.y_fanjin = function(self, who, flags)
	local handcards = sgs.QList2Table(who:getHandcards())
	if #handcards == 1 and handcards[1]:hasFlag("visible") then table.insert(cards, handcards[1]) end
	local list = self.player:property("y_fanjin"):toString():split("+")
	if #list > 0 then
		for _, l in pairs(list) do
			for _, c in ipairs(handcards) do
				if c:getEffectiveId() == tonumber(l) then
					return c:getEffectiveId()
				end
			end
		end
	end
	return nil
end

sgs.ai_skill_use["@@y_xianzhou"] = function(self, prompt)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	local to_discard = {}
	self:sortByKeepValue(cards)

	local damage = self.room:getTag("y_xianzhou"):toDamage()
	local from = damage.from
	if not from or from:isDead() then return "." end
	local to = self.player
	local n = damage.damage
	local nature = damage.nature
	if self:needToLoseHp(to, from, damage.card) or not self:damageIsEffective(to, nature, from) then return "." end
	if self:isFriend(from) then
		for _, card in ipairs(cards) do
			table.insert(to_discard, card:getEffectiveId())
			if #to_discard == self.player:getHp() then
				break
			end
		end
		if #to_discard == self.player:getHp() then
			return "#y_xianzhoucard:" .. table.concat(to_discard, "+") .. ":"
		end
	else
		if n > 1 or self:hasHeavyDamage(from, damage.card, to) or self:needToThrowCard(from) or self.player:getHp() <= 1 then
			for _, card in ipairs(cards) do
				if not card:isKindOf("Peach") then
					table.insert(to_discard, card:getEffectiveId())
					if #to_discard == self.player:getHp() then
						break
					end
				end
			end
			if #to_discard == self.player:getHp() then
				return "#y_xianzhoucard:" .. table.concat(to_discard, "+") .. ":"
			end
		else
			for _, card in ipairs(cards) do
				if #to_discard == self.player:getHp() then
					break
				end
				if not self:keepCard(card) then
					table.insert(to_discard, card:getEffectiveId())
				end
			end
			if #to_discard == self.player:getHp() then
				return "#y_xianzhoucard:" .. table.concat(to_discard, "+") .. ":"
			end
		end
	end
	return "."
end

sgs.ai_skill_invoke.y_huiyu = function(self, data)
	local use = data:toCardUse()
	local slash = sgs.Sanguosha:cloneCard("slash", use.card:getSuit(), use.card:getNumber())
	slash:deleteLater()
	local targets = sgs.QList2Table(use.to)
	if self.player:objectName() == use.from:objectName() then
		for _, p in ipairs(targets) do
			if self:isFriend(p) and self.player:canSlash(p) and not self:slashProhibit(slash, p)
				and self:slashIsEffective(slash, p) and self:dontHurt(p, self.player)
			then
				return false
			end
		end
		for _, p in ipairs(targets) do
			if self:isEnemy(p) and self.player:canSlash(p) and not self:slashProhibit(slash, p)
				and self:slashIsEffective(slash, p) and self:isGoodTarget(p, self.enemies, slash)
			then
				return true
			end
		end
		return true
	else
		if self:needToLoseHp(self.player, use.from, use.card) then
			return true
		end
		for _, p in ipairs(targets) do
			if self:isEnemy(p) and self.player:canSlash(p) and not self:slashProhibit(slash, p)
				and self:slashIsEffective(slash, p) and self:isGoodTarget(p, self.enemies, slash)
			then
				return true
			end
		end
	end
	return false
end
