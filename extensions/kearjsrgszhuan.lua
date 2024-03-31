--==《新武将》==--
extension = sgs.Package("kearjsrgszhuan", sgs.Package_GeneralPack)
local skills = sgs.SkillList()

function KezhuanToData(self)
	local data = sgs.QVariant()
	if type(self) == "string"
		or type(self) == "boolean"
		or type(self) == "number"
	then
		data = sgs.QVariant(self)
	elseif self ~= nil then
		data:setValue(self)
	end
	return data
end

--buff集中
kezhuanslashmore = sgs.CreateTargetModSkill {
	name = "kezhuanslashmore",
	pattern = ".",
	residue_func = function(self, from, card, to)
		local n = 0
		if from:hasSkill("kezhuanzhenfeng") and (card:getSkillName() == "kezhuanzhenfeng") then
			n = n + 1000
		end
		return n
	end,
	extra_target_func = function(self, from, card)
		--[[local n = 0
		if (from:getMark("&kechengneifaNotBasic") > 0 and card:isNDTrick()) then
			n = n + 1
		end
		return n]]
	end,
	distance_limit_func = function(self, from, card, to)
		local n = 0
		if (card:getSkillName() == "kezhuancuifeng") then
			n = n + 1000
		end
		--[[if from:hasSkill("kezhuanfuni") and card:isKindOf("Slash") then
			n = -from:getAttackRange()
			n = -100
		end]]
		if from:hasSkill("kezhuanrihui")
			and card:isKindOf("Slash") and to
			and (to:getMark("kezhuanrihui-Clear") == 0)
			and (to:getJudgingArea():length() == 0) then
			n = n + 1000
		end
		if from:hasSkill("kezhuanzhenfeng") and (card:getSkillName() == "kezhuanzhenfeng") then
			n = n + 1000
		end
		if (from:getMark("&kezhuanfuni") > 0) then
			n = n + 1000
		end
		return n
	end
}
if not sgs.Sanguosha:getSkill("kezhuanslashmore") then skills:append(kezhuanslashmore) end

kezhuanguojia = sgs.General(extension, "kezhuanguojia", "wei", 3, true)

kezhuanqingzi = sgs.CreateTriggerSkill {
	name = "kezhuanqingzi",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart, sgs.Death },
	can_trigger = function(self, target)
		return target ~= nil and target:hasSkill(self:objectName())
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Death) then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if (p:getMark("&kezhuanqingzi") > 0) then
					room:setPlayerMark(p, "&kezhuanqingzi", 0)
					room:handleAcquireDetachSkills(p, "-tenyearshensu")
				end
			end
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Start) then
				local players = sgs.SPlayerList()
				local aiplayers = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if player:canDiscard(p, "e") then
						players:append(p)
					end
				end
				for _, p in sgs.qlist(players) do
					if player:canDiscard(p, "e")
						and ((player:isYourFriend(p) and (p:getHp() + p:getHp() + p:getHandcardNum() >= 8))
							or ((not player:isYourFriend(p))) and (p:getHp() + p:getHp() + p:getHandcardNum() <= 4)) then
						aiplayers:append(p)
					end
				end
				if not players:isEmpty() then
					local ones = sgs.SPlayerList()
					if player:getState() == "online" then
						ones = room:askForPlayersChosen(player, players, self:objectName(), 0, 999, "kezhuanqingzi-ask",
							true, true)
					else
						ones = room:askForPlayersChosen(player, aiplayers, self:objectName(), aiplayers:length(),
							aiplayers:length(), "kezhuanqingzi-ask", true, true)
					end
					if not ones:isEmpty() then room:broadcastSkillInvoke(self:objectName()) end
					for _, q in sgs.qlist(ones) do
						local to_throw = room:askForCardChosen(player, q, "e", self:objectName())
						local card = sgs.Sanguosha:getCard(to_throw)
						room:throwCard(card, q, player)
						if not q:hasSkill("tenyearshensu") then
							room:setPlayerMark(q, "&kezhuanqingzi", 1)
							room:handleAcquireDetachSkills(q, "tenyearshensu")
						end
					end
				end
			end
			if (player:getPhase() == sgs.Player_RoundStart) then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("&kezhuanqingzi") > 0) then
						room:handleAcquireDetachSkills(p, "-tenyearshensu")
						room:setPlayerMark(p, "&kezhuanqingzi", 0)
					end
				end
			end
		end
	end,
}
kezhuanguojia:addSkill(kezhuanqingzi)

kezhuandingce = sgs.CreateTriggerSkill {
	name = "kezhuandingce",
	events = { sgs.Damaged },
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if event == sgs.Damaged then
			local to_data = sgs.QVariant()
			to_data:setValue(damage.from)
			if (damage.from:objectName() == player:objectName()) then
				if (player:getHandcardNum() >= 4) then
					room:setPlayerFlag(player, "dingceself")
				end
			elseif player:isYourFriend(damage.from) and (damage.from:objectName() ~= player:objectName())
				and (damage.from:getHandcardNum() > damage.from:getHp() + 3) then
				room:setPlayerFlag(player, "dingcefriend")
			elseif not player:isYourFriend(damage.from) then
				room:setPlayerFlag(player, "dingceeny")
			end

			local will_use = room:askForSkillInvoke(player, self:objectName(), to_data)
			if will_use then
				room:broadcastSkillInvoke(self:objectName())
				local selfno = 0
				if player:isKongcheng() then selfno = 1 end
				local card_id = room:askForDiscard(player, self:objectName(), 1, 1, false, false, "kezhuandingce-discard")
					:getSubcards():first()
				local mycard = sgs.Sanguosha:getCard(card_id)
				if mycard:isRed() then
					room:setPlayerFlag(player, "bestdingcered")
				else
					room:setPlayerFlag(player,
						"bestdingceblack")
				end
				if player:canDiscard(damage.from, "h") then
					local to_throw = room:askForCardChosen(player, damage.from, "h", self:objectName())
					local hecard = sgs.Sanguosha:getCard(to_throw)
					room:throwCard(hecard, damage.from, player)
					if (selfno == 0) and mycard and hecard and ((mycard:isRed() and hecard:isRed()) or (mycard:isBlack() and hecard:isBlack())) then
						local dzxj = sgs.Sanguosha:cloneCard("dongzhuxianji", sgs.Card_NoSuit, 0)
						dzxj:setSkillName("kezhuandingce")
						dzxj:deleteLater()
						local card_use = sgs.CardUseStruct()
						card_use.from = player
						card_use.to:append(player)
						card_use.card = dzxj
						room:useCard(card_use, false)
						dzxj:deleteLater()
					end
				end
				room:setPlayerFlag(player, "-bestdingcered")
				room:setPlayerFlag(player, "-bestdingceblack")
			end

			room:setPlayerFlag(player, "-dingceself")
			room:setPlayerFlag(player, "-dingcefriend")
			room:setPlayerFlag(player, "-dingceeny")
		end
	end
}
kezhuanguojia:addSkill(kezhuandingce)


local function zhuanJfNames(player)
	local aps = player:getAliveSiblings()
	aps:append(player)
	local ption = ""
	for _, p in sgs.list(aps) do
		for _, s in sgs.list(p:getSkillList()) do
			if s:isAttachedLordSkill() then continue end
			ption = ption .. s:getDescription()
		end
	end
	local names = {}
	for c = 0, sgs.Sanguosha:getCardCount() - 1 do
		c = sgs.Sanguosha:getEngineCard(c)
		if c:getTypeId() > 2 or table.contains(names, c:objectName())
			or player:getMark(c:getType() .. "kezhuanzhenfeng-PlayClear") > 0 then
			continue
		end
		if string.find(ption, "【" .. sgs.Sanguosha:translate(c:objectName()) .. "】")
			and (c:isNDTrick() or c:isKindOf("BasicCard")) and (not c:isKindOf("kezhuan_ying"))
		then
			table.insert(names, c:objectName())
		end
	end
	return names
end

function zhuandummyCard(name, suit, number)
	name = name or "slash"
	local c = sgs.Sanguosha:cloneCard(name)
	if c
	then
		if suit then c:setSuit(suit) end
		if number then c:setNumber(number) end
		c:deleteLater()
		return c
	end
end

kezhuanzhenfengCard = sgs.CreateSkillCard {
	name = "kezhuanzhenfengCard",
	target_fixed = true,
	about_to_use = function(self, room, use)
		room:addPlayerMark(use.from, "aizhenfengtimes-PlayClear")
		local p_choices = {}
		for d, p in sgs.list(zhuanJfNames(use.from)) do
			d = zhuandummyCard(p)
			d:setSkillName("kezhuanzhenfeng")
			if d:isAvailable(use.from)
			then
				table.insert(p_choices, p)
			end
		end
		if use.from:getState() == "online" then
			table.insert(p_choices, "cancel")
		end
		p_choices = room:askForChoice(use.from, "kezhuanzhenfeng", table.concat(p_choices, "+"))
		for i = 0, sgs.Sanguosha:getCardCount() - 1 do
			local c = sgs.Sanguosha:getEngineCard(i)
			if c:objectName() == p_choices
			then
				room:setPlayerMark(use.from, "kezhuanzhenfeng_id", i)
				room:askForUseCard(use.from, "@@kezhuanzhenfeng", "kezhuanzhenfeng1:" .. p_choices)
				break
			end
		end
	end
}
kezhuanzhenfengvs = sgs.CreateViewAsSkill {
	name = "kezhuanzhenfeng",
	view_as = function(self, cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern == "@@kezhuanzhenfeng"
		then
			pattern = sgs.Self:getMark("kezhuanzhenfeng_id")
			pattern = sgs.Sanguosha:getEngineCard(pattern)
			pattern = sgs.Sanguosha:cloneCard(pattern:objectName())
			pattern:setSkillName("kezhuanzhenfeng")
			return pattern
		elseif sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_PLAY
			and pattern ~= ""
		then
			local gn = zhuanJfNames(sgs.Self)
			for d, p in sgs.list(pattern:split("+")) do
				d = sgs.Sanguosha:cloneCard(p)
				d:setSkillName("kezhuanzhenfeng")
				if table.contains(gn, p)
				then
					return d
				end
			end
			return false
		end
		return kezhuanzhenfengCard:clone()
	end,
	enabled_at_response = function(self, player, pattern)
		if pattern == "@@kezhuanzhenfeng" then
			return true
		elseif sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
			or player:getPhase() ~= sgs.Player_Play then
			return
		end
		local gn = zhuanJfNames(player)
		for _, p in sgs.list(pattern:split("+")) do
			if table.contains(gn, p)
			then
				return true
			end
		end
	end,
	enabled_at_nullification = function(self, player)
		return player:getPhase() == sgs.Player_Play
			and player:getMark("trickkezhuanzhenfeng-PlayClear") < 1
	end,
	enabled_at_play = function(self, player)
		for c, p in sgs.list(zhuanJfNames(player)) do
			c = zhuandummyCard(p)
			c:setSkillName("kezhuanzhenfeng")
			if c:isAvailable(player)
			then
				return true
			end
		end
	end,
}

kezhuanzhenfeng = sgs.CreateTriggerSkill {
	name = "kezhuanzhenfeng",
	--events = { sgs.CardEffected, sgs.PreCardUsed, sgs.SlashHit, sgs.TrickEffect },
	events = { sgs.CardEffected, sgs.PreCardUsed },
	view_as_skill = kezhuanzhenfengvs,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.CardEffected
		then
			local effect = data:toCardEffect()
			if effect.card:getSkillName() == "kezhuanzhenfeng"
				and effect.to == player
			then
				if -- effect.card:isKindOf("TrickCard")
				-- 	or effect.card:isKindOf("Slash")
				-- 	or
					effect.nullified then
					return
				end
				for _, s in sgs.list(effect.to:getSkillList()) do
					if s:isAttachedLordSkill() then continue end
					if string.find(s:getDescription(), "【" .. sgs.Sanguosha:translate(effect.card:objectName()) .. "】")
					then
						room:sendCompulsoryTriggerLog(effect.from, self:objectName())
						room:damage(sgs.DamageStruct(self:objectName(), effect.from, effect.to))
						room:getThread():delay(500)
						break
					end
				end
			end
			-- elseif event == sgs.TrickEffect
			-- then
			-- 	local effect = data:toCardEffect()
			-- 	if effect.card:getSkillName() == "kezhuanzhenfeng"
			-- 		and effect.to == player and not effect.nullified
			-- 	then
			-- 		for _, s in sgs.list(effect.to:getSkillList()) do
			-- 			if s:isAttachedLordSkill() then continue end
			-- 			if string.find(s:getDescription(), "【" .. sgs.Sanguosha:translate(effect.card:objectName()) .. "】")
			-- 			then
			-- 				room:sendCompulsoryTriggerLog(effect.from, self:objectName())
			-- 				room:damage(sgs.DamageStruct(self:objectName(), effect.from, effect.to))
			-- 				room:getThread():delay(500)
			-- 				break
			-- 			end
			-- 		end
			-- 	end
			-- elseif event == sgs.SlashHit
			-- then
			-- 	local effect = data:toSlashEffect()
			-- 	if effect.slash:getSkillName() == "kezhuanzhenfeng"
			-- 		and effect.from == player and not effect.nullified
			-- 	then
			-- 		for _, s in sgs.list(effect.to:getSkillList()) do
			-- 			if s:isAttachedLordSkill() then continue end
			-- 			if string.find(s:getDescription(), "【" .. sgs.Sanguosha:translate(effect.slash:objectName()) .. "】")
			-- 			then
			-- 				--Skill_msg(self,effect.from)
			-- 				room:sendCompulsoryTriggerLog(effect.from, self:objectName())
			-- 				room:damage(sgs.DamageStruct(self:objectName(), effect.from, effect.to))
			-- 				room:getThread():delay(500)
			-- 				break
			-- 			end
			-- 		end
			-- 	end
		else
			local use = data:toCardUse()
			if use.card:getSkillName() == "kezhuanzhenfeng"
				and use.from == player
			then
				room:addPlayerMark(player, use.card:getType() .. "kezhuanzhenfeng-PlayClear")
			end
		end
		return false
	end
}
kezhuanguojia:addSkill(kezhuanzhenfeng)
kezhuanguojia:addRelateSkill("tenyearshensu")

kezhuan_ying = sgs.CreateBasicCard {
	name = "_kezhuan_ying",
	class_name = "kezhuan_ying",
	subtype = "kespecial_card",
	can_recast = false,
	damage_card = false,
	available = function(self, player)
		return false
	end,
}

for i = 0, 16, 1 do
	local card = kezhuan_ying:clone()
	card:setSuit(0)
	card:setNumber(1)
	card:setParent(extension)
end



kezhuanzhangren = sgs.General(extension, "kezhuanzhangren", "qun", 4)

function kezhuandestroyEquip(room, move, tag_name)
	local id = room:getTag(tag_name):toInt()
	if id > 0 and move.card_ids:contains(id) then
		local move1 = sgs.CardsMoveStruct(id, nil, nil, room:getCardPlace(id), sgs.Player_PlaceTable,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, "destroy_equip", ""))
		local card = sgs.Sanguosha:getCard(id)
		room:moveCardsAtomic(move1, true)
		room:removeTag(card:getClassName())
	end
end

function kezhuangetCardList(intlist)
	local ids = sgs.CardList()
	for _, id in sgs.qlist(intlist) do
		ids:append(sgs.Sanguosha:getCard(id))
	end
	return ids
end

kezhuanfuni = sgs.CreateTriggerSkill {
	name = "kezhuanfuni",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardsMoveOneTime, sgs.EventPhaseChanging, sgs.RoundStart, sgs.TargetSpecified },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.TargetSpecified) and player:hasSkill(self:objectName()) then
			local use = data:toCardUse()
			if (use.from:getMark("&kezhuanfuni") > 0) then
				if not (use.card:isKindOf("EquipCard") or use.card:isKindOf("SkillCard")) then
					local log = sgs.LogMessage()
					log.type = "$kezhuanfunixiangying"
					log.from = player
					room:sendLog(log)
				end
				local no_respond_list = use.no_respond_list
				for _, szm in sgs.qlist(use.to) do
					table.insert(no_respond_list, szm:objectName())
				end
				use.no_respond_list = no_respond_list
				data:setValue(use)
			end
		end
		if (event == sgs.RoundStart) and player:hasSkill(self:objectName()) then
			room:broadcastSkillInvoke(self:objectName())
			local yiji_cards = sgs.IntList()
			local num = math.ceil(player:aliveCount() / 2)
			while (num > 0)
			do
				for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
					if sgs.Sanguosha:getEngineCard(id):isKindOf("kezhuan_ying") and (room:getCardPlace(id) ~= sgs.Player_DrawPile)
						and (room:getCardPlace(id) ~= sgs.Player_PlaceHand) and (room:getCardPlace(id) ~= sgs.Player_PlaceEquip) then
						if not yiji_cards:contains(id) then
							room:setCardFlag(sgs.Sanguosha:getCard(id), "-kefirstdes")
							yiji_cards:append(id)
							break
						end
					end
				end
				num = num - 1
			end
			if not yiji_cards:isEmpty() then
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				dummy:addSubcards(kezhuangetCardList(yiji_cards))
				player:obtainCard(dummy)
				dummy:deleteLater()
				local _zhangren = sgs.SPlayerList()
				_zhangren:append(player)
				local origin_yiji = sgs.IntList()
				for _, id in sgs.qlist(yiji_cards) do
					origin_yiji:append(id)
				end
				while room:askForYiji(player, yiji_cards, self:objectName(), true, false, true, -1, room:getAlivePlayers(), sgs.CardMoveReason(), "kezhuanfuni-distribute") do
					for _, id in sgs.qlist(origin_yiji) do
						if (room:getCardOwner(id):objectName() ~= player:objectName()) then
							yiji_cards:removeOne(id)
						end
					end
					origin_yiji = sgs.IntList()
					for _, id in sgs.qlist(yiji_cards) do
						origin_yiji:append(id)
					end
					if not player:isAlive() then return end
				end
			end
		end
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("&kezhuanfuni") > 0) then
						room:setPlayerMark(p, "&kezhuanfuni", 0)
					end
				end
			end
		end
		if (event == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if (move.to_place == sgs.Player_DiscardPile) then
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("kezhuan_ying") then
						for _, p in sgs.qlist(room:getAllPlayers()) do
							if p:hasSkill(self:objectName()) then
								room:setPlayerMark(p, "&kezhuanfuni", 1)
							end
						end
						room:setTag("KE_ying", sgs.QVariant(id))
						kezhuandestroyEquip(room, move, "KE_ying")
						if not card:hasFlag("kefirstdes") then
							local log = sgs.LogMessage()
							log.type = "#kezhuandestroyEquip"
							log.card_str = card:toString()
							room:sendLog(log)
							room:setCardFlag(card, "kefirstdes")
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
kezhuanzhangren:addSkill(kezhuanfuni)


kezhuanchuanxinCard = sgs.CreateSkillCard {
	name = "kezhuanchuanxinCard",
	mute = true,
	filter = function(self, targets, to_select)
		local targets_list = sgs.PlayerList()
		for _, target in ipairs(targets) do
			targets_list:append(target)
		end
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("kezhuanchuanxin")
		slash:deleteLater()
		return slash:targetFilter(targets_list, to_select, sgs.Self)
	end,
	on_use = function(self, room, source, targets)
		local targets_list = sgs.SPlayerList()
		for _, target in ipairs(targets) do
			if source:canSlash(target, nil, false) then
				targets_list:append(target)
			end
		end
		if targets_list:length() > 0 then
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			slash:setSkillName("kezhuanchuanxin")
			slash:addSubcard(self)
			room:useCard(sgs.CardUseStruct(slash, source, targets_list))
		end
	end
}
kezhuanchuanxinVS = sgs.CreateViewAsSkill {
	name = "kezhuanchuanxin",
	n = 1,
	view_filter = function(self, selected, to_select)
		return #selected == 0 and not sgs.Self:isJilei(to_select)
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then
			return nil
		end
		local card = kezhuanchuanxinCard:clone()
		for _, cd in ipairs(cards) do
			card:addSubcard(cd)
		end
		return card
	end,
	enabled_at_play = function()
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@kezhuanchuanxin")
	end
}
kezhuanchuanxin = sgs.CreateTriggerSkill {
	name = "kezhuanchuanxin",
	events = { sgs.EventPhaseStart, sgs.DamageCaused, sgs.HpRecover },
	view_as_skill = kezhuanchuanxinVS,
	can_trigger = function(self, player)
		return player
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Finish) then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:hasSkill(self:objectName()) and not p:isNude() then
						local yes = 0
						for _, pp in sgs.qlist(room:getAllPlayers()) do
							if p:canSlash(pp, true) or (p:getMark("&kezhuanfuni") > 0) then
								yes = 1
								break
							end
						end
						if (yes == 1) then
							room:askForUseCard(p, "@@kezhuanchuanxin", "kezhuanchuanxin-ask")
						end
					end
				end
			end
		end
		if (event == sgs.DamageCaused) then
			local damage = data:toDamage()
			if damage.from:hasSkill(self:objectName())
				and (damage.to:getMark("kezhuanchuanxin-Clear") > 0)
				and damage.card and (damage.card:getSkillName() == "kezhuanchuanxin") then
				room:sendCompulsoryTriggerLog(damage.from, self:objectName())
				local log = sgs.LogMessage()
				log.type = "$kezhuanchuanxinda"
				log.from = player
				log.arg = damage.to:getMark("kezhuanchuanxin-Clear")
				room:sendLog(log)
				local hurt = damage.damage
				damage.damage = hurt + damage.to:getMark("kezhuanchuanxin-Clear")
				data:setValue(damage)
			end
		end
		if (event == sgs.HpRecover) then
			local recover = data:toRecover()
			if recover.who and (recover.who:objectName() == player:objectName()) then
				room:addPlayerMark(player, "kezhuanchuanxin-Clear", recover.recover)
			end
		end
	end
}
kezhuanzhangren:addSkill(kezhuanchuanxin)

kezhuanfuniex = sgs.CreateAttackRangeSkill {
	name = "kezhuanfuniex",
	--[[fixed_func = function(self, target)
		if target:hasSkill("kezhuanfuni") then
			return 0
		else
			return -1
		end
	end]]
	extra_func = function(self, target)
		local n = 0
		if target:hasSkill("kezhuanfuni") then
			n = n - 999
		end
		return n
	end
}
if not sgs.Sanguosha:getSkill("kezhuanfuniex") then skills:append(kezhuanfuniex) end

--[[kezhuanfuniexex = sgs.CreateProhibitSkill{
	name = "kezhuanfuniexex",
	is_prohibited = function(self, from, to, card)
		return from:hasSkill("kezhuanfuni") and (from:getAttackRange() <= 0) and card:isKindOf("Slash") and to and (to:objectName() ~= from:objectName())
	end
}
if not sgs.Sanguosha:getSkill("kezhuanfuniexex") then skills:append(kezhuanfuniexex) end]]



kezhuanmachao = sgs.General(extension, "kezhuanmachao", "qun", 4)

kezhuanzhuiming = sgs.CreateTriggerSkill {
	name = "kezhuanzhuiming",
	events = { sgs.TargetSpecified, sgs.DamageCaused },
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.DamageCaused) then
			local damage = data:toDamage()
			if (not damage.chain) and (not damage.transfer) and damage.card and damage.card:hasFlag("kezhuanzhuimingcard") then
				room:sendCompulsoryTriggerLog(damage.from, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local hurt = damage.damage
				damage.damage = hurt + 1
				data:setValue(damage)
			end
		end
		if (event == sgs.TargetSpecified) then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") and (use.to:length() == 1) then
				local target = use.to:at(0)
				local to_data = sgs.QVariant()
				to_data:setValue(target)
				if not player:isYourFriend(target) then room:setPlayerFlag(player, "wantusezhuiming") end
				local will_use = room:askForSkillInvoke(player, self:objectName(), to_data)
				room:setPlayerFlag(player, "-wantusezhuiming")
				if will_use then
					room:broadcastSkillInvoke(self:objectName())
					--for ai
					local red = 0
					local black = 0
					for _, c in sgs.qlist(target:getCards("e")) do
						if c:isRed() then red = red + 1 else black = black + 1 end
					end
					if (red >= black) then
						room:setPlayerFlag(player, "wantchoosered")
					end
					if not player:hasFlag("wantchoosered") then
						room:setPlayerFlag(player, "wantchooseblack")
					end
					--对于ai，如果马超牌少，说明后续没有什么杀，就不用弃掉太多桃酒，否则大概率丢干净
					if (player:getHandcardNum() <= 2) then
						room:setPlayerFlag(target, "machaomeipai")
					end
					--如果普通杀藤甲或者黑杀仁王盾，或者人家有白银狮子，才不会丢盔弃甲呢！
					if ((use.card:objectName() == "slash") and ((target:getArmor() ~= nil) and (target:getArmor():objectName() == "vine")))
						or ((use.card:isBlack()) and ((target:getArmor() ~= nil) and (target:getArmor():objectName() == "renwang_shield")))
						or ((target:getArmor() ~= nil) and (target:getArmor():objectName() == "silver_lion")) then
						room:setPlayerFlag(target, "zhuimingnotdisany")
					end
					local result = room:askForChoice(player, self:objectName(), "zhuimingblack+zhuimingred")
					if result == "zhuimingblack" then
						--for ai
						room:setPlayerFlag(target, "zhuimingblacke")
						local allnum = 0
						for _, c in sgs.qlist(target:getCards("he")) do if c:isBlack() then allnum = allnum + 1 end end
						for _, c in sgs.qlist(target:getCards("e")) do
							if c:isBlack() then
								room:setPlayerFlag(target,
									"readytodisblack")
							end
						end
						local willdis = 0
						if (allnum > 3) then willdis = math.random(1, 3) else willdis = math.random(1, 5) end
						if willdis > 1 then room:setPlayerFlag(target, "readytodisblack") end
						--end ai
						local log = sgs.LogMessage()
						log.type = "$kezhuanzhuimingblack"
						log.from = player
						room:sendLog(log)
						room:setPlayerMark(player, "zhuimingblack", 1)
						room:getThread():delay(300)
						room:askForDiscard(target, self:objectName(), 999, 0, true, true, "zhuimingblack-dis")
						room:getThread():delay(200)
					else
						--for ai
						room:setPlayerFlag(target, "zhuimingrede")
						local allnum = 0
						for _, c in sgs.qlist(target:getCards("he")) do if c:isRed() then allnum = allnum + 1 end end
						for _, c in sgs.qlist(target:getCards("e")) do
							if c:isRed() then
								room:setPlayerFlag(target,
									"readytodisred")
							end
						end
						local willdis = 0
						if (allnum > 3) then willdis = math.random(1, 3) else willdis = math.random(1, 5) end
						if willdis > 1 then room:setPlayerFlag(target, "readytodisred") end
						--end ai
						local log = sgs.LogMessage()
						log.type = "$kezhuanzhuimingred"
						log.from = player
						room:sendLog(log)
						room:setPlayerMark(player, "zhuimingred", 1)
						room:getThread():delay(300)
						room:askForDiscard(target, self:objectName(), 999, 0, true, true, "zhuimingred-dis")
						room:getThread():delay(200)
					end
					if not target:isNude() then
						local to_show = room:askForCardChosen(player, target, "he", self:objectName())
						local thecard = sgs.Sanguosha:getCard(to_show)
						local to_showlist = sgs.IntList()
						to_showlist:append(to_show)
						room:showCard(target, to_showlist)
						if (thecard:isBlack() and (player:getMark("zhuimingblack") > 0))
							or (thecard:isRed() and (player:getMark("zhuimingred") > 0)) then
							local log = sgs.LogMessage()
							log.type = "$kezhuanzhuimingtrigger"
							log.from = player
							room:sendLog(log)
							room:addPlayerHistory(player, use.card:getClassName(), -1)
							local no_respond_list = use.no_respond_list
							for _, szm in sgs.qlist(use.to) do
								table.insert(no_respond_list, szm:objectName())
							end
							use.no_respond_list = no_respond_list
							data:setValue(use)
							room:setCardFlag(use.card, "kezhuanzhuimingcard")
						end
					end
					--for ai clear
					room:setPlayerMark(player, "zhuimingblack", 0)
					room:setPlayerMark(player, "zhuimingred", 0)
					room:setPlayerFlag(player, "-wantchoosered")
					room:setPlayerFlag(player, "-wantchooseblack")
					room:setPlayerFlag(target, "-readytodisblack")
					room:setPlayerFlag(target, "-readytodisred")
					room:setPlayerFlag(target, "-machaomeipai")
					room:setPlayerFlag(target, "-zhuimingnotdisany")
					room:setPlayerFlag(target, "-zhuimingrede")
					room:setPlayerFlag(target, "-zhuimingblacke")
				end
			end
		end
	end
}
kezhuanmachao:addSkill(kezhuanzhuiming)
kezhuanmachao:addSkill("mashu")




kezhuanzhangfei = sgs.General(extension, "kezhuanzhangfei", "shu", 5)

kezhuanbaohe = sgs.CreateTriggerSkill {
	name = "kezhuanbaohe",
	events = { sgs.EventPhaseEnd, sgs.CardOffset, sgs.DamageCaused, sgs.CardFinished },
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardFinished) then
			local use = data:toCardUse()
			if (use.card:getSkillName() == "kezhuanbaohe") then
				room:removeTag("kezhuanbaoheda")
			end
		end
		if (event == sgs.EventPhaseEnd) then
			if (player:getPhase() == sgs.Player_Play) then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:hasSkill(self:objectName()) and (p:getCardCount() >= 2) then
						local players = sgs.SPlayerList()
						for _, pp in sgs.qlist(room:getOtherPlayers(player)) do
							if (p:objectName() ~= pp:objectName()) then
								if pp:inMyAttackRange(player) then
									players:append(pp)
								end
							end
						end
						--for ai
						local frinum = 0
						local enynum = 0
						for _, fri in sgs.qlist(players) do
							if p:isYourFriend(fri) then
								frinum = frinum + 1
								if (fri:getHp() + fri:getHp() + fri:getHandcardNum() <= 3) or (fri:getHp() <= 1) then
									frinum = frinum + 1
								end
							end
							if not p:isYourFriend(fri) then
								enynum = enynum + 1
								if (fri:getHp() + fri:getHp() + fri:getHandcardNum() <= 3) or (fri:getHp() <= 1) then
									enynum = enynum + 1
								end
							end
						end
						if (enynum > frinum) then room:setPlayerFlag(p, "wantusebaohe") end
						--room:setPlayerFlag(p,"wantusebaohe")
						if room:askForDiscard(p, self:objectName(), 2, 2, true, true, "kezhuanbaohe-ask:" .. player:objectName()) then
							local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
							slash:setSkillName("kezhuanbaohe")
							local card_use = sgs.CardUseStruct()
							card_use.from = p
							card_use.to = players
							card_use.card = slash
							room:useCard(card_use, false)
							slash:deleteLater()
						end
						room:setPlayerFlag(p, "-wantusebaohe")
					end
				end
			end
		end
		if (event == sgs.CardOffset) then
			local effect = data:toCardEffect()
			local room = player:getRoom()
			if effect.card and effect.card:isKindOf("Slash") and effect.card:getSkillName() == "kezhuanbaohe" then
				if not room:getTag("kezhuanbaoheda") then
					room:setTag("kezhuanbaoheda", sgs.QVariant(1))
				else
					local num = room:getTag("kezhuanbaoheda"):toInt() + 1
					room:setTag("kezhuanbaoheda", sgs.QVariant(num))
				end
			end
		end
		-- if (event == sgs.CardResponded) then
		-- 	local response = data:toCardResponse()
		-- 	local restocard = response.m_toCard
		-- 	local rescard = response.m_card
		-- 	local resto = room:getCardUser(response.m_toCard)
		-- 	if (restocard:getSkillName() == "kezhuanbaohe") then
		-- 		if not room:getTag("kezhuanbaoheda") then
		-- 			room:setTag("kezhuanbaoheda", sgs.QVariant(1))
		-- 		else
		-- 			local num = room:getTag("kezhuanbaoheda"):toInt() + 1
		-- 			room:setTag("kezhuanbaoheda", sgs.QVariant(num))
		-- 		end
		-- 	end
		-- end
		if (event == sgs.DamageCaused) then
			local damage = data:toDamage()
			if damage.card and (damage.card:getSkillName() == "kezhuanbaohe") and (room:getTag("kezhuanbaoheda"):toInt() >= 1) then
				room:sendCompulsoryTriggerLog(damage.from, self:objectName())
				local log = sgs.LogMessage()
				log.type = "$kezhuanbaoheda"
				log.from = player
				log.arg = room:getTag("kezhuanbaoheda"):toInt()
				room:sendLog(log)
				local hurt = damage.damage
				damage.damage = hurt + room:getTag("kezhuanbaoheda"):toInt()
				data:setValue(damage)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
kezhuanzhangfei:addSkill(kezhuanbaohe)

kezhuanxushiCard = sgs.CreateSkillCard {
	name = "kezhuanxushiCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets < 99
			and (to_select:objectName() ~= sgs.Self:objectName())
	end,
	on_use = function(self, room, player, targets)
		local players = sgs.SPlayerList()
		if targets[1] then players:append(targets[1]) end
		if targets[2] then players:append(targets[2]) end
		if targets[3] then players:append(targets[3]) end
		if targets[4] then players:append(targets[4]) end
		if targets[5] then players:append(targets[5]) end
		if targets[6] then players:append(targets[6]) end
		if targets[7] then players:append(targets[7]) end
		if targets[8] then players:append(targets[8]) end
		if targets[9] then players:append(targets[9]) end
		if targets[10] then players:append(targets[10]) end
		local num = 0
		for _, pp in sgs.qlist(players) do
			if not player:isNude() then
				local card = room:askForExchange(player, "kezhuanxushi", 1, 0, true, "kezhuanxushigive:" ..
					pp:objectName(), true)
				if card then
					room:obtainCard(pp, card,
						sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), player:objectName(),
							self:objectName(), ""), false)
					num = num + card:getSubcards():length() + card:getSubcards():length()
				end
			end
		end
		local yiji_cards = sgs.IntList()
		while (num > 0)
		do
			for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
				if sgs.Sanguosha:getEngineCard(id):isKindOf("kezhuan_ying") and (room:getCardPlace(id) ~= sgs.Player_DrawPile)
					and (room:getCardPlace(id) ~= sgs.Player_PlaceHand) and (room:getCardPlace(id) ~= sgs.Player_PlaceEquip) then
					if not yiji_cards:contains(id) then
						room:setCardFlag(sgs.Sanguosha:getCard(id), "-kefirstdes")
						yiji_cards:append(id)
						break
					end
				end
			end
			num = num - 1
		end
		if not yiji_cards:isEmpty() then
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			dummy:addSubcards(kezhuangetCardList(yiji_cards))
			player:obtainCard(dummy)
			dummy:deleteLater()
		end
	end
}

kezhuanxushi = sgs.CreateViewAsSkill {
	name = "kezhuanxushi",
	n = 0,
	view_as = function(self, cards)
		return kezhuanxushiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return (not player:hasUsed("#kezhuanxushiCard")) and (not player:isNude())
	end,
}
kezhuanzhangfei:addSkill(kezhuanxushi)



kezhuanxiahourong = sgs.General(extension, "kezhuanxiahourong", "wei", 4)

kezhuanfenjianex = sgs.CreateTriggerSkill {
	name = "#kezhuanfenjianex",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.AskForPeaches, sgs.DamageInflicted },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.AskForPeaches) then
			local dying_data = data:toDying()
			local source = dying_data.who
			--for _, p in sgs.qlist(room:getAllPlayers()) do
			if room:getCurrentDyingPlayer() and (room:getCurrentDyingPlayer():objectName() == source:objectName()) then
				if (player:getMark("&kezhuanfenjianpeach-Clear") < 1) and player:hasSkill(self:objectName()) and (player:objectName() ~= source:objectName()) then
					local to_data = sgs.QVariant()
					to_data:setValue(source)
					if player:isYourFriend(source) then room:setPlayerFlag(player, "wantusefenjian") end
					local will_use = room:askForSkillInvoke(player, self:objectName(), to_data)
					room:setPlayerFlag(player, "-wantusefenjian")
					if will_use then
						room:addPlayerMark(player, "&kezhuanfenjianpeach-Clear", 1)
						local peach = sgs.Sanguosha:cloneCard("peach", sgs.Card_NoSuit, 0)
						peach:setSkillName("kezhuanfenjian")
						local card_use = sgs.CardUseStruct()
						card_use.from = player
						card_use.to:append(source)
						card_use.card = peach
						room:useCard(card_use, false)
						peach:deleteLater()
					end
				end
			end
		end
		--end
		if (event == sgs.DamageInflicted) then
			local damage = data:toDamage()
			if (damage.to:getMark("&kezhuanfenjianpeach-Clear") > 0) or (damage.to:getMark("&kezhuanfenjianduel-Clear") > 0) then
				room:broadcastSkillInvoke("kezhuanfenjian")
				room:sendCompulsoryTriggerLog(damage.to, self:objectName())
				local hurt = damage.damage
				damage.damage = hurt + damage.to:getMark("&kezhuanfenjianpeach-Clear") +
					damage.to:getMark("&kezhuanfenjianduel-Clear")
				data:setValue(damage)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}

kezhuanfenjianCard = sgs.CreateSkillCard {
	name = "kezhuanfenjianCard",
	target_fixed = false,
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		return #targets < 1
			and (to_select:objectName() ~= sgs.Self:objectName()) and not sgs.Self:isProhibited(to_select, duel)
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		room:addPlayerMark(player, "&kezhuanfenjianduel-Clear", 1)
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		duel:setSkillName("kezhuanfenjian")
		local card_use = sgs.CardUseStruct()
		card_use.from = player
		card_use.to:append(target)
		card_use.card = duel
		room:useCard(card_use, false)
		duel:deleteLater()
	end
}

kezhuanfenjian = sgs.CreateViewAsSkill {
	name = "kezhuanfenjian",
	n = 0,
	view_as = function(self, cards)
		return kezhuanfenjianCard:clone()
	end,
	enabled_at_play = function(self, player)
		return (not player:hasUsed("#kezhuanfenjianCard"))
	end,
}
kezhuanxiahourong:addSkill(kezhuanfenjian)
kezhuanxiahourong:addSkill(kezhuanfenjianex)
extension:insertRelatedSkills("kezhuanfenjian", "#kezhuanfenjianex")



kezhuansunshuangxiang = sgs.General(extension, "kezhuansunshuangxiang", "wu", 3, false)

kezhuanguijiCard = sgs.CreateSkillCard {
	name = "kezhuanguijiCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets < 1
			and (to_select:objectName() ~= sgs.Self:objectName()) and (to_select:getGender() == sgs.General_Male)
			and (to_select:getHandcardNum() < sgs.Self:getHandcardNum())
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		room:setPlayerMark(target, "&kezhuanguiji", 1)
		room:setPlayerMark(player, "usekezhuanguiji", 1)
		player:setFlags("kezhuanguijiTarget")
		target:setFlags("kezhuanguijiTarget")
		local n1 = player:getHandcardNum()
		local n2 = target:getHandcardNum()
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:objectName() ~= player:objectName() and p:objectName() ~= target:objectName() then
				room:doNotify(p, sgs.CommandType.S_COMMAND_EXCHANGE_KNOWN_CARDS,
					json.encode({ player:objectName(), target:objectName() }))
			end
		end
		local exchangeMove = sgs.CardsMoveList()
		local move1 = sgs.CardsMoveStruct(player:handCards(), target, sgs.Player_PlaceHand,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, player:objectName(), target:objectName(), "kezhuanguiji",
				""))
		local move2 = sgs.CardsMoveStruct(target:handCards(), player, sgs.Player_PlaceHand,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, target:objectName(), player:objectName(), "kezhuanguiji",
				""))
		exchangeMove:append(move1)
		exchangeMove:append(move2)
		room:moveCardsAtomic(exchangeMove, false)
		player:setFlags("-kezhuanguijiTarget")
		target:setFlags("-kezhuanguijiTarget")
	end
}

kezhuanguijiVS = sgs.CreateViewAsSkill {
	name = "kezhuanguiji",
	n = 0,
	view_as = function(self, cards)
		return kezhuanguijiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return (player:getMark("usekezhuanguiji") == 0) and (not player:hasUsed("#kezhuanguijiCard"))
	end,
}

kezhuanguiji = sgs.CreateTriggerSkill {
	name = "kezhuanguiji",
	events = { sgs.EventPhaseEnd, sgs.Death },
	view_as_skill = kezhuanguijiVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseEnd) then
			if (player:getPhase() == sgs.Player_Play) and (player:getMark("&kezhuanguiji") > 0) then
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if (p:getMark("usekezhuanguiji") > 0) and p:hasSkill(self:objectName()) then
						--for ai
						local yingnum = 0
						for _, c in sgs.qlist(player:getCards("h")) do
							if c:isKindOf("kezhuan_ying") then
								yingnum = yingnum + 1
							end
						end
						if ((player:getHandcardNum() - yingnum) > p:getHandcardNum()) then
							room:setPlayerFlag(p,
								"wantuseguijiagain")
						end
						if room:askForSkillInvoke(p, "kezhuanguijiagain", data) then
							room:setPlayerFlag(p, "-wantuseguijiagain")
							room:broadcastSkillInvoke(self:objectName())
							player:setFlags("kezhuanguijiTarget")
							p:setFlags("kezhuanguijiTarget")
							local n1 = player:getHandcardNum()
							local n2 = p:getHandcardNum()
							for _, p in sgs.qlist(room:getAlivePlayers()) do
								if p:objectName() ~= player:objectName() and p:objectName() ~= p:objectName() then
									room:doNotify(p, sgs.CommandType.S_COMMAND_EXCHANGE_KNOWN_CARDS,
										json.encode({ player:objectName(), p:objectName() }))
								end
							end
							local exchangeMove = sgs.CardsMoveList()
							local move1 = sgs.CardsMoveStruct(player:handCards(), p, sgs.Player_PlaceHand,
								sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, player:objectName(), p:objectName(),
									"kezhuanguiji", ""))
							local move2 = sgs.CardsMoveStruct(p:handCards(), player, sgs.Player_PlaceHand,
								sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, p:objectName(), player:objectName(),
									"kezhuanguiji", ""))
							exchangeMove:append(move1)
							exchangeMove:append(move2)
							room:moveCardsAtomic(exchangeMove, false)
							player:setFlags("-kezhuanguijiTarget")
							p:setFlags("-kezhuanguijiTarget")
							room:setPlayerMark(player, "&kezhuanguiji", 0)
							room:setPlayerMark(p, "usekezhuanguiji", 0)
							break
						end
						room:setPlayerFlag(p, "-wantuseguijiagain")
						room:setPlayerMark(p, "usekezhuanguiji", 0)
					end
				end
				room:setPlayerMark(player, "&kezhuanguiji", 0)
			end
		end
		if (event == sgs.Death) then
			local death = data:toDeath()
			if death.who:objectName() == player:objectName() then
				if (player:getMark("&kezhuanguiji") > 0) then
					for _, p in sgs.qlist(room:getAllPlayers()) do
						room:setPlayerMark(p, "usekezhuanguiji", 0)
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end
}
kezhuansunshuangxiang:addSkill(kezhuanguiji)


kezhuanjiaohaoCard = sgs.CreateSkillCard {
	name = "kezhuanjiaohaoCard",
	will_throw = false,
	mute = true,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select, liubei)
		if #targets ~= 0 or (to_select:objectName() == liubei:objectName())
			or (not to_select:hasSkill("kezhuanjiaohao")) then
			return false
		end
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		local equip = card:getRealCard():toEquipCard()
		local equip_index = equip:location()
		return to_select:getEquip(equip_index) == nil
	end,
	on_effect = function(self, effect)
		local liubei = effect.from
		liubei:getRoom():broadcastSkillInvoke("kezhuanjiaohao", math.random(3, 4))
		liubei:getRoom():moveCardTo(self, liubei, effect.to, sgs.Player_PlaceEquip,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, liubei:objectName(), "kezhuanjiaohao", ""))
	end
}
kezhuanjiaohaoex = sgs.CreateOneCardViewAsSkill {
	name = "kezhuanjiaohaoex&",
	filter_pattern = "EquipCard|.|.|hand",
	view_as = function(self, card)
		local kezhuanjiaohao_card = kezhuanjiaohaoCard:clone()
		kezhuanjiaohao_card:addSubcard(card)
		kezhuanjiaohao_card:setSkillName(self:objectName())
		return kezhuanjiaohao_card
	end,
	enabled_at_play = function(self, player)
		return (not player:hasUsed("#kezhuanjiaohaoCard"))
	end,
}
if not sgs.Sanguosha:getSkill("kezhuanjiaohaoex") then skills:append(kezhuanjiaohaoex) end

kezhuanjiaohao = sgs.CreateTriggerSkill {
	name = "kezhuanjiaohao",
	events = { sgs.EventPhaseStart, sgs.EventPhaseEnd },
	frequency = sgs.Skill_Frequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseEnd) then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasSkill("kezhuanjiaohaoex") then
					room:handleAcquireDetachSkills(player, "-kezhuanjiaohaoex", false, true, false)
				end
			end
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Play) then
				--for _, p in sgs.qlist(room:getAllPlayers()) do
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:hasSkill(self:objectName()) then
						room:handleAcquireDetachSkills(player, "kezhuanjiaohaoex", false, true, false)
						--room:acquireOneTurnSkills(player, self:objectName(), "kezhuanjiaohaoex")
						break
					end
				end
			end
			if (player:getPhase() == sgs.Player_Start) and player:hasSkill(self:objectName()) then
				local num = 0
				if (player:getWeapon() == nil) then num = num + 1 end
				if (player:getArmor() == nil) then num = num + 1 end
				if (player:getDefensiveHorse() == nil) then num = num + 1 end
				if (player:getOffensiveHorse() == nil) then num = num + 1 end
				if (player:getTreasure() == nil) then num = num + 1 end
				local num = math.ceil(num / 2)
				if (num > 0) then
					room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
				end
				local yiji_cards = sgs.IntList()
				while (num > 0)
				do
					for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
						if sgs.Sanguosha:getEngineCard(id):isKindOf("kezhuan_ying") and (room:getCardPlace(id) ~= sgs.Player_DrawPile)
							and (room:getCardPlace(id) ~= sgs.Player_PlaceHand) and (room:getCardPlace(id) ~= sgs.Player_PlaceEquip) then
							if not yiji_cards:contains(id) then
								room:setCardFlag(sgs.Sanguosha:getCard(id), "-kefirstdes")
								yiji_cards:append(id)
								break
							end
						end
					end
					num = num - 1
				end
				if not yiji_cards:isEmpty() then
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					dummy:addSubcards(kezhuangetCardList(yiji_cards))
					player:obtainCard(dummy)
					dummy:deleteLater()
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
kezhuansunshuangxiang:addSkill(kezhuanjiaohao)

kezhuanhuangzhong = sgs.General(extension, "kezhuanhuangzhong", "shu", 4)

kezhuancuifengCard = sgs.CreateSkillCard {
	name = "kezhuancuifengCard",
	target_fixed = true,
	mute = true,
	will_throw = false,
	about_to_use = function(self, room, use)
		--local card = sgs.Sanguosha:getCard(self:getEffectiveId())
		local choices = {}
		for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
			local tcard = sgs.Sanguosha:getEngineCard(id)
			if tcard:isDamageCard()
			then
				if table.contains(choices, tcard:objectName())
				then
					continue
				end
				local transcard = sgs.Sanguosha:cloneCard(tcard:objectName())
				transcard:setSkillName("kezhuancuifeng")
				--transcard:addSubcard(self)
				if not transcard:isAvailable(use.from) then continue end
				if (not tcard:isKindOf("DelayedTrick")) and (tcard:isSingleTargetCard()
						or ((use.from:aliveCount() == 2) and (tcard:isKindOf("AOE")))) then
					table.insert(choices, tcard:objectName())
				end
			end
		end
		if #choices < 1 then return end
		table.insert(choices, "cancel")
		local choice = room:askForChoice(use.from, "kezhuancuifeng", table.concat(choices, "+"))
		if choice == "cancel" then return end
		for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
			local c = sgs.Sanguosha:getEngineCard(id)
			if c:objectName() == choice then
				room:setPlayerMark(use.from, "kezhuancuifengName", id)
				break
			end
		end
		--room:setPlayerMark(use.from,"kezhuancuifengId",self:getEffectiveId())
		room:askForUseCard(use.from, "@@kezhuancuifeng", "kezhuancuifeng-ask:" .. choice)
	end
}
kezhuancuifengVS = sgs.CreateViewAsSkill {
	name = "kezhuancuifeng",
	n = 0,
	view_as = function(self, cards)
		if sgs.Sanguosha:getCurrentCardUsePattern() == "@@kezhuancuifeng"
		then
			local c = sgs.Sanguosha:getEngineCard(sgs.Self:getMark("kezhuancuifengName"))
			local transcard = sgs.Sanguosha:cloneCard(c:objectName())
			--transcard:addSubcard(sgs.Self:getMark("kezhuancuifengId"))
			transcard:setSkillName("kezhuancuifeng")
			return transcard
		elseif #cards == 0
		then
			return kezhuancuifengCard:clone()
		end
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@kezhuancuifeng"
	end,
	enabled_at_play = function(self, player)
		return (player:getMark("@kezhuancuifeng") > 0)
	end
}

kezhuancuifeng = sgs.CreateTriggerSkill {
	name = "kezhuancuifeng",
	events = { sgs.CardUsed, sgs.Damage, sgs.CardFinished, sgs.EventPhaseChanging },
	frequency = sgs.Skill_Limited,
	limit_mark = "@kezhuancuifeng",
	view_as_skill = kezhuancuifengVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if (use.from:objectName() == player:objectName()) then
				if (use.card:getSkillName() == "kezhuancuifeng") and player:hasSkill(self:objectName()) then
					room:removePlayerMark(player, "@kezhuancuifeng")
					room:setPlayerMark(player, "usingcuifeng", 1)
				end
			end
		end
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if damage.card and (damage.card:getSkillName() == "kezhuancuifeng") then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("usingcuifeng") > 0) then
						room:addPlayerMark(p, "cuifengda", damage.damage)
						break
					end
				end
			end
		end
		if (event == sgs.CardFinished) then
			local use = data:toCardUse()
			if (use.from:objectName() == player:objectName()) then
				if (use.card:getSkillName() == "kezhuancuifeng") then
					room:setPlayerMark(player, "usingcuifeng", 0)
					if (player:getMark("cuifengda") ~= 1) and player:hasSkill(self:objectName()) then
						--room:addPlayerMark(player,"@kezhuancuifeng")
						room:setPlayerMark(player, "&kezhuancuifengchongzhi", 1)
					end
					room:setPlayerMark(player, "cuifengda", 0)
				end
			end
		end
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) and (player:getMark("&kezhuancuifengchongzhi") > 0) then
				room:addPlayerMark(player, "@kezhuancuifeng")
				room:setPlayerMark(player, "&kezhuancuifengchongzhi", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
kezhuanhuangzhong:addSkill(kezhuancuifeng)



kezhuandengnanCard = sgs.CreateSkillCard {
	name = "kezhuandengnanCard",
	target_fixed = true,
	mute = true,
	will_throw = false,
	about_to_use = function(self, room, use)
		local choices = {}
		for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
			local tcard = sgs.Sanguosha:getEngineCard(id)
			if not tcard:isDamageCard() and tcard:isNDTrick()
			then
				if table.contains(choices, tcard:objectName())
				then
					continue
				end
				local transcard = sgs.Sanguosha:cloneCard(tcard:objectName())
				transcard:setSkillName("kezhuandengnan")
				if not transcard:isAvailable(use.from) then continue end
				table.insert(choices, tcard:objectName())
			end
		end
		if #choices < 1 then return end
		table.insert(choices, "cancel")
		local choice = room:askForChoice(use.from, "kezhuandengnan", table.concat(choices, "+"))
		if choice == "cancel" then return end
		for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
			local c = sgs.Sanguosha:getEngineCard(id)
			if c:objectName() == choice then
				room:setPlayerMark(use.from, "kezhuandengnanName", id)
				break
			end
		end
		room:askForUseCard(use.from, "@@kezhuandengnan", "kezhuandengnan-ask:" .. choice)
	end
}
kezhuandengnanVS = sgs.CreateViewAsSkill {
	name = "kezhuandengnan",
	n = 0,
	view_as = function(self, cards)
		if sgs.Sanguosha:getCurrentCardUsePattern() == "@@kezhuandengnan"
		then
			local c = sgs.Sanguosha:getEngineCard(sgs.Self:getMark("kezhuandengnanName"))
			local transcard = sgs.Sanguosha:cloneCard(c:objectName())
			transcard:setSkillName("kezhuandengnan")
			return transcard
		elseif #cards == 0
		then
			return kezhuandengnanCard:clone()
		end
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@kezhuandengnan"
	end,
	enabled_at_play = function(self, player)
		return (player:getMark("@kezhuandengnan") > 0)
	end
}

kezhuandengnan = sgs.CreateTriggerSkill {
	name = "kezhuandengnan",
	events = { sgs.TargetSpecified, sgs.Damaged, sgs.CardUsed, sgs.EventPhaseChanging },
	frequency = sgs.Skill_Limited,
	limit_mark = "@kezhuandengnan",
	view_as_skill = kezhuandengnanVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if (use.from:objectName() == player:objectName()) then
				if (use.card:getSkillName() == "kezhuandengnan") and player:hasSkill(self:objectName()) then
					room:removePlayerMark(player, "@kezhuandengnan")
				end
			end
		end
		if (event == sgs.TargetSpecified) then
			local use = data:toCardUse()
			if (use.card:getSkillName() == "kezhuandengnan") and use.from:hasSkill(self:objectName()) then
				--player:drawCards(10)
				room:setPlayerMark(use.from, "usingdengnan-Clear", 1)
				for _, p in sgs.qlist(use.to) do
					--room:setPlayerMark(p,"&kezhuandengnantar",1)
					if (p:getMark("&kezhuandengnanover") == 0) then
						if (p:getMark("&kezhuandengnanda") > 0) then
							room:setPlayerMark(p, "&kezhuandengnanda", 0)
							room:setPlayerMark(p, "&kezhuandengnanover", 1)
						else
							room:setPlayerMark(p, "&kezhuandengnantar", 1)
						end
					end
				end
			end
		end
		if (event == sgs.Damaged) then
			local damage = data:toDamage()
			local hz = room:findPlayerBySkillName(self:objectName())
			if hz and (hz:getPhase() ~= sgs.Player_NotActive) then
				--hz:drawCards(5)
				--room:setPlayerMark(damage.to,"&kezhuandengnanda",1)
				if (damage.to:getMark("&kezhuandengnanover") == 0) then
					if (damage.to:getMark("&kezhuandengnantar") > 0) then
						room:setPlayerMark(damage.to, "&kezhuandengnantar", 0)
						room:setPlayerMark(damage.to, "&kezhuandengnanover", 1)
					else
						room:setPlayerMark(damage.to, "&kezhuandengnanda", 1)
					end
				end
			end
		end
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) then
				if (player:getMark("usingdengnan-Clear") > 0) then
					local yes = 1
					for _, p in sgs.qlist(room:getAllPlayers()) do
						if (p:getMark("&kezhuandengnantar") > 0) and (p:getMark("&kezhuandengnanda") == 0) then
							yes = 0
							break
						end
					end
					if (yes == 1) then
						room:addPlayerMark(player, "@kezhuandengnan")
					end
				end
				for _, pp in sgs.qlist(room:getAllPlayers()) do
					room:setPlayerMark(pp, "&kezhuandengnantar", 0)
					room:setPlayerMark(pp, "&kezhuandengnanover", 0)
					room:setPlayerMark(pp, "&kezhuandengnanda", 0)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
kezhuanhuangzhong:addSkill(kezhuandengnan)


kezhuanpangtong = sgs.General(extension, "kezhuanpangtong", "qun", 3)


kezhuanmanjuanVsCard = sgs.CreateSkillCard {
	name = "kezhuanmanjuanVsCard",
	filter = function(self, targets, to_select, from)
		local pattern = self:getUserString()
		if pattern == "@@kezhuanmanjuan"
		then
			local c = sgs.Sanguosha:getCard(from:getMark("kezhuanmanjuan_id"))
			if c:targetFixed() then return end
			local plist = sgs.PlayerList()
			for i = 1, #targets do plist:append(targets[i]) end
			return c:targetFilter(plist, to_select, from)
		else
			local plist = sgs.PlayerList()
			for i = 1, #targets do plist:append(targets[i]) end
			for i = 0, sgs.Sanguosha:getCardCount() - 1 do
				local c = sgs.Sanguosha:getCard(i)
				if from:getMark(i .. "manjuanPile-Clear") > 0
					and from:getMark(c:getNumber() .. "manjuanNumber-Clear") < 1
					and not from:isLocked(c)
				then
					i = c:isKindOf("Slash") and "slash" or c:objectName()
					if pattern:match(i)
					then
						if sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
							or c:targetFixed() then
							return true
						end
						return c:targetFilter(plist, to_select, from)
					end
				end
			end
		end
	end,
	feasible = function(self, targets)
		local pattern = self:getUserString()
		if pattern == "@@kezhuanmanjuan"
		then
			local c = sgs.Sanguosha:getCard(sgs.Self:getMark("kezhuanmanjuan_id"))
			if c:targetFixed() then return true end
			local plist = sgs.PlayerList()
			for i = 1, #targets do plist:append(targets[i]) end
			return c:targetsFeasible(plist, sgs.Self)
		else
			local plist = sgs.PlayerList()
			for i = 1, #targets do plist:append(targets[i]) end
			for i = 0, sgs.Sanguosha:getCardCount() - 1 do
				local c = sgs.Sanguosha:getCard(i)
				if sgs.Self:getMark(i .. "manjuanPile-Clear") > 0
					and sgs.Self:getMark(c:getNumber() .. "manjuanNumber-Clear") < 1
					and not sgs.Self:isLocked(c)
				then
					i = c:isKindOf("Slash") and "slash" or c:objectName()
					if pattern:match(i)
					then
						if sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
							or c:targetFixed() then
							return true
						end
						return c:targetsFeasible(plist, sgs.Self)
					end
				end
			end
		end
	end,
	on_validate = function(self, use)
		local room = use.from:getRoom()
		local pattern = self:getUserString()
		if pattern == "@@kezhuanmanjuan"
		then
			local c = sgs.Sanguosha:getCard(use.from:getMark("kezhuanmanjuan_id"))
			room:broadcastSkillInvoke("kezhuanmanjuan") --播放配音
			room:setCardFlag(c, "kezhuanmanjuan")
			return c
		else
			local ids = sgs.IntList()
			for i = 0, sgs.Sanguosha:getCardCount() - 1 do
				local c = sgs.Sanguosha:getCard(i)
				if use.from:getMark(i .. "manjuanPile-Clear") > 0
					and use.from:getMark(c:getNumber() .. "manjuanNumber-Clear") < 1
					and not use.from:isCardLimited(c, sgs.Card_MethodUse)
				then
					c = c:isKindOf("Slash") and "slash" or c:objectName()
					if string.find(pattern, c) and use.from:canUse(c, use.to)
					then
						ids:append(i)
					end
				end
			end
			room:fillAG(ids, use.from)
			local c = room:askForAG(use.from, ids, ids:length() < 2, "kezhuanmanjuan", "kezhuanmanjuan0")
			room:clearAG(use.from)
			c = c < 0 and ids:at(0) or c
			c = sgs.Sanguosha:getCard(c)
			room:broadcastSkillInvoke("kezhuanmanjuan") --播放配音
			room:setCardFlag(c, "kezhuanmanjuan")
			return c
		end
	end,
	on_validate_in_response = function(self, from)
		local room = from:getRoom()
		local pattern = self:getUserString()
		if pattern == "@@kezhuanmanjuan"
		then
			local c = sgs.Sanguosha:getCard(from:getMark("kezhuanmanjuan_id"))
			room:broadcastSkillInvoke("kezhuanmanjuan") --播放配音
			room:setCardFlag(c, "kezhuanmanjuan")
			return c
		else
			local hm = sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
			hm = hm and sgs.Card_MethodUse or sgs.Card_MethodResponse
			local ids = sgs.IntList()
			for i = 0, sgs.Sanguosha:getCardCount() - 1 do
				local c = sgs.Sanguosha:getCard(i)
				if from:getMark(i .. "manjuanPile-Clear") > 0
					and from:getMark(c:getNumber() .. "manjuanNumber-Clear") < 1
					and not from:isCardLimited(c, hm)
				then
					c = c:isKindOf("Slash") and "slash" or c:objectName()
					if string.find(pattern, c) then ids:append(i) end
				end
			end
			room:fillAG(ids, from)
			local c = room:askForAG(from, ids, ids:length() < 2, "kezhuanmanjuan", "kezhuanmanjuan1")
			room:clearAG(from)
			c = c < 0 and ids:at(0) or c
			c = sgs.Sanguosha:getCard(c)
			room:broadcastSkillInvoke("kezhuanmanjuan") --播放配音
			room:setCardFlag(c, "kezhuanmanjuan")
			return c
		end
	end
}

kezhuanmanjuanCard = sgs.CreateSkillCard {
	name = "kezhuanmanjuanCard",
	target_fixed = true,
	about_to_use = function(self, room, use)
		local ids = sgs.IntList()
		for i = 0, sgs.Sanguosha:getCardCount() - 1 do
			local c = sgs.Sanguosha:getCard(i)
			if use.from:getMark(i .. "manjuanPile-Clear") > 0
				and use.from:getMark(c:getNumber() .. "manjuanNumber-Clear") < 1
				and c:isAvailable(use.from) then
				ids:append(i)
			end
		end
		room:fillAG(ids, use.from)
		local id = room:askForAG(use.from, ids, ids:length() < 2, "kezhuanmanjuan", "kezhuanmanjuan0")
		id = id < 0 and ids:at(0) or id
		room:clearAG(use.from)
		room:setPlayerMark(use.from, "kezhuanmanjuan_id", id)
		room:askForUseCard(use.from, "@@kezhuanmanjuan", "kezhuanmanjuan2:" .. sgs.Sanguosha:getCard(id):objectName())
	end
}
kezhuanmanjuanvs = sgs.CreateViewAsSkill {
	name = "kezhuanmanjuan",
	view_as = function(self, cards)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY
		then
			return kezhuanmanjuanCard:clone()
		else
			local c = kezhuanmanjuanVsCard:clone()
			c:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			return c
		end
	end,
	enabled_at_response = function(self, player, pattern)
		if pattern == "@@kezhuanmanjuan" then
			return true
		elseif player:getHandcardNum() > 0 then
			return
		end
		local hm = sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
		hm = hm and sgs.Card_MethodUse or sgs.Card_MethodResponse
		for i = 0, sgs.Sanguosha:getCardCount() - 1 do
			local c = sgs.Sanguosha:getCard(i)
			if player:getMark(i .. "manjuanPile-Clear") > 0
				and player:getMark(c:getNumber() .. "manjuanNumber-Clear") < 1
				and not player:isCardLimited(c, hm)
			then
				c = c:isKindOf("Slash") and "slash" or c:objectName()
				if string.find(pattern, c) then return true end
			end
		end
	end,
	enabled_at_nullification = function(self, player)
		if player:getHandcardNum() > 0 then return end
		for i = 0, sgs.Sanguosha:getCardCount() - 1 do
			local c = sgs.Sanguosha:getCard(i)
			if player:getMark(i .. "manjuanPile-Clear") > 0
				and player:getMark(c:getNumber() .. "manjuanNumber-Clear") < 1
				and not player:isLocked(c) and c:isKindOf("Nullification")
			then
				return true
			end
		end
	end,
	enabled_at_play = function(self, player)
		if player:getHandcardNum() > 0 then return end
		for i = 0, sgs.Sanguosha:getCardCount() - 1 do
			local c = sgs.Sanguosha:getCard(i)
			if player:getMark(i .. "manjuanPile-Clear") > 0
				and player:getMark(c:getNumber() .. "manjuanNumber-Clear") < 1
				and c:isAvailable(player) then
				return true
			end
		end
	end
}
kezhuanmanjuan = sgs.CreateTriggerSkill {
	name = "kezhuanmanjuan",
	events = { sgs.CardsMoveOneTime, sgs.PreCardUsed, sgs.PreCardResponded },
	view_as_skill = kezhuanmanjuanvs,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.CardsMoveOneTime
		then
			local move = data:toMoveOneTime()
			if move.to_place == sgs.Player_DiscardPile
			then
				for _, id in sgs.list(move.card_ids) do
					room:addPlayerMark(player, id .. "manjuanPile-Clear")
				end
			end
		else
			local card
			if event == sgs.PreCardResponded
			then
				local res = data:toCardResponse()
				if res.m_isUse then card = res.m_card end
			else
				card = data:toCardUse().card
			end
			if card and card:hasFlag("kezhuanmanjuan")
			then
				room:setCardFlag(card, "-kezhuanmanjuan")
				room:addPlayerMark(player, card:getNumber() .. "manjuanNumber-Clear")
			end
		end
		return false
	end
}

kezhuanpangtong:addSkill(kezhuanmanjuan)

kezhuanyangmingCard = sgs.CreateSkillCard {
	name = "kezhuanyangmingCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and (not to_select:isKongcheng()) and (to_select:objectName() ~= sgs.Self:objectName()) and
			(sgs.Self:canPindian(to_select, true))
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		local success = player:pindian(target, "kezhuanyangming", nil)
	end
}

kezhuanyangmingVS = sgs.CreateViewAsSkill {
	name = "kezhuanyangming",
	n = 0,
	view_as = function(self, cards)
		return kezhuanyangmingCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not (player:hasUsed("#kezhuanyangmingCard"))
	end,
}

kezhuanyangming = sgs.CreateTriggerSkill {
	name = "kezhuanyangming",
	view_as_skill = kezhuanyangmingVS,
	events = { sgs.Pindian },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Pindian) then
			local pindian = data:toPindian()
			local fromNumber = pindian.from_card:getNumber()
			local toNumber = pindian.to_card:getNumber()
			local jixu = 0
			if (fromNumber == toNumber) then
				room:addPlayerMark(pindian.from, "&kezhuanyangminglose-PlayClear", 1)
				room:addPlayerMark(pindian.to, "&kezhuanyangminglose-PlayClear", 1)
				jixu = 1
			else
				local winner
				local loser
				if fromNumber > toNumber then
					winner = pindian.from
					loser = pindian.to
				else
					winner = pindian.to
					loser = pindian.from
				end
				if (loser == pindian.to) then
					jixu = 1
				end
				room:addPlayerMark(loser, "&kezhuanyangminglose-PlayClear", 1)
			end
			--不管是因为什么拼点，先给输的人标记
			if (jixu == 1) then
				--如果是本技能，再继续
				if (pindian.reason == self:objectName())
					and pindian.from:hasSkill(self:objectName())
					and pindian.from:canPindian(pindian.to, true) then
					if pindian.from:askForSkillInvoke(self:objectName(), KezhuanToData("kezhuanyangming-jixu:" .. pindian.to:objectName())) then
						room:broadcastSkillInvoke(self:objectName())
						local success = pindian.from:pindian(pindian.to, "kezhuanyangming", nil)
					end
				end
			else
				--如果是本技能，再继续
				if (pindian.reason == self:objectName())
					and pindian.from:hasSkill(self:objectName()) then
					if (pindian.to:getMark("&kezhuanyangminglose-PlayClear") > 0) then
						pindian.to:drawCards(pindian.to:getMark("&kezhuanyangminglose-PlayClear"))
					end
					room:recover(pindian.from, sgs.RecoverStruct())
				end
			end
		end
	end
}
kezhuanpangtong:addSkill(kezhuanyangming)


kezhuanlougui = sgs.General(extension, "kezhuanlougui", "wei", 3, true)

kezhuanshacheng = sgs.CreateTriggerSkill {
	name = "kezhuanshacheng",
	events = { sgs.GameStart, sgs.CardFinished, sgs.CardsMoveOneTime },
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if (move.from and (move.from:objectName() == player:objectName())
					and (move.from_places:contains(sgs.Player_PlaceHand)
						or move.from_places:contains(sgs.Player_PlaceEquip)))
				and not (move.to and (move.to:objectName() == player:objectName()
					and (move.to_place == sgs.Player_PlaceHand
						or move.to_place == sgs.Player_PlaceEquip))) then
				room:addPlayerMark(player, "kezhuanshachenglose-Clear", move.card_ids:length())
			end
		end
		if (event == sgs.GameStart) and player:hasSkill(self:objectName()) then
			room:broadcastSkillInvoke(self:objectName())
			local sc_card = room:getNCards(2)
			player:addToPile("kezhuanshacheng", sc_card)
		end
		if (event == sgs.CardFinished) then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") then
				for _, lg in sgs.qlist(room:getAllPlayers()) do
					if lg:hasSkill(self:objectName()) then
						local alldie = 1
						local num = 0
						for _, p in sgs.qlist(use.to) do
							if p:isAlive() then
								alldie = 0
								if lg:isYourFriend(p) then
									room:setPlayerFlag(lg, "wantuseshacheng")
								end
							end
							room:setPlayerMark(p, "&kezhuanshachengcandraw",
								math.min(5, p:getMark("kezhuanshachenglose-Clear")))
							num = num + p:getMark("&kezhuanshachengcandraw")
						end
						if (num > 0) and (alldie == 0) and (not lg:getPile("kezhuanshacheng"):isEmpty()) then
							if lg:askForSkillInvoke(self:objectName(), KezhuanToData("kezhuanshacheng-ask:" .. lg:objectName())) then
								room:broadcastSkillInvoke(self:objectName())
								room:fillAG(lg:getPile("kezhuanshacheng"), lg)
								local id = room:askForAG(lg, lg:getPile("kezhuanshacheng"), false, self:objectName())
								room:clearAG(lg)
								room:throwCard(id, lg, lg)
								local fri = room:askForPlayerChosen(lg, use.to, self:objectName(), "kezhuanshacheng-ask",
									false, true)
								if fri then
									fri:drawCards(fri:getMark("&kezhuanshachengcandraw"))
								end
							end
						end
						for _, pp in sgs.qlist(room:getAllPlayers()) do
							room:setPlayerMark(pp, "&kezhuanshachengcandraw", 0)
						end
						room:setPlayerFlag(lg, "-wantuseshacheng")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
kezhuanlougui:addSkill(kezhuanshacheng)

kezhuanninghan = sgs.CreateTriggerSkill {
	name = "kezhuanninghan",
	events = { sgs.Damaged, sgs.GameStart, sgs.Death, sgs.EventAcquireSkill, sgs.EventLoseSkill },
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Damaged) then
			local damage = data:toDamage()
			if damage.card and (damage.nature == sgs.DamageStruct_Ice) then
				if (room:getCardPlace(damage.card:getId()) == sgs.Player_PlaceTable) then
					for _, p in sgs.qlist(room:getAllPlayers()) do
						if p:hasSkill(self:objectName()) then
							if p:askForSkillInvoke(self:objectName(), KezhuanToData("kezhuanninghan-ask:" .. damage.card:objectName())) then
								room:broadcastSkillInvoke(self:objectName())
								p:addToPile("kezhuanshacheng", damage.card)
								break
							end
						end
					end
				end
			end
		end
		if (event == sgs.GameStart) and player:hasSkill(self:objectName()) then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if not p:hasSkill("kezhuanninghanbuff") then
					room:handleAcquireDetachSkills(p, "kezhuanninghanbuff")
				end
			end
		end
		if (event == sgs.Death) then
			local death = data:toDeath()
			if (death.who:objectName() == player:objectName())
				and player:hasSkill(self:objectName()) then
				local dis = 1
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:hasSkill(self:objectName()) then
						dis = 0
						break
					end
				end
				if dis == 1 then
					for _, p in sgs.qlist(room:getAllPlayers()) do
						room:handleAcquireDetachSkills(p, "-kezhuanninghanbuff")
					end
				end
			end
		end
		if (event == sgs.EventAcquireSkill and data:toString() == "kezhuanninghan") then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if not p:hasSkill("kezhuanninghanbuff") then
					room:handleAcquireDetachSkills(p, "kezhuanninghanbuff")
				end
			end
		end
		if (event == sgs.EventLoseSkill) and data:toString() == "kezhuanninghan" then
			local dis = 1
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:hasSkill(self:objectName()) then
					dis = 0
					break
				end
			end
			if (dis == 1) then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					room:handleAcquireDetachSkills(p, "-kezhuanninghanbuff")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
kezhuanlougui:addSkill(kezhuanninghan)

kezhuanninghanbuff = sgs.CreateFilterSkill {
	name = "kezhuanninghanbuff&",
	view_filter = function(self, to_select)
		local room = sgs.Sanguosha:currentRoom()
		local place = room:getCardPlace(to_select:getEffectiveId())
		return (to_select:getSuit() == sgs.Card_Club) and (to_select:isKindOf("Slash")) and
			(place == sgs.Player_PlaceHand)
	end,
	view_as = function(self, originalCard)
		local slash = sgs.Sanguosha:cloneCard("ice_slash", originalCard:getSuit(), originalCard:getNumber())
		slash:setSkillName(self:objectName())
		local card = sgs.Sanguosha:getWrappedCard(originalCard:getId())
		card:takeOver(slash)
		return card
	end
}
if not sgs.Sanguosha:getSkill("kezhuanninghanbuff") then skills:append(kezhuanninghanbuff) end


kezhuanhansui = sgs.General(extension, "kezhuanhansui$", "qun", 4, true)

kezhuanniluanCard = sgs.CreateSkillCard {
	name = "kezhuanniluanCard",
	will_throw = true,
	filter = function(self, targets, to_select)
		return ((self:subcardsLength() == 1) and (to_select:getMark("kezhuanniluandid") == 0)) or
			((self:subcardsLength() == 0) and (to_select:getMark("kezhuanniluandid") > 0))
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		if (self:subcardsLength() == 0) then
			target:drawCards(2)
		end
		if (self:subcardsLength() == 1) then
			room:damage(sgs.DamageStruct(self:objectName(), source, target))
		end
	end,
}

kezhuanniluanVS = sgs.CreateViewAsSkill {
	name = "kezhuanniluan",
	n = 1,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards == 0 then
			return kezhuanniluanCard:clone()
		elseif #cards == 1 then
			local card = kezhuanniluanCard:clone()
			card:addSubcard(cards[1])
			return card
		else
			return nil
		end
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@kezhuanniluan"
	end,
	enabled_at_play = function(self, player)
		return false
	end
}

kezhuanniluan = sgs.CreateTriggerSkill {
	name = "kezhuanniluan",
	events = { sgs.EventPhaseStart, sgs.Damage, sgs.Damaged },
	view_as_skill = kezhuanniluanVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Damaged) then
			local damage = data:toDamage()
			room:setPlayerMark(damage.from, "kezhuanniluandid", 1)
		end
		if (event == sgs.EventPhaseStart) and (player:getPhase() == sgs.Player_Start) then
			if player:getState() == "online" then
				room:askForUseCard(player, "@@kezhuanniluan", "kezhuanniluan-ask")
			else
				for _, p in sgs.qlist(room:getAllPlayers()) do
					local yes = 0
					if (not player:isYourFriend(p))
						--and ((p:getHp() + p:getHp() + p:getHandcardNum()) <=4)
						and (not player:isNude())
						and (p:getMark("kezhuanniluandid") == 0) then
						room:getThread():delay(300)
						local log = sgs.LogMessage()
						log.type = "$kezhuanniluanlog"
						log.from = player
						room:sendLog(log)
						room:broadcastSkillInvoke(self:objectName())
						room:askForDiscard(player, self:objectName(), 1, 1, false, true, "kezhuanniluan-discard")
						room:damage(sgs.DamageStruct(self:objectName(), player, p))
						yes = 1
						break
					end
					if (player:isYourFriend(p) or player:objectName() == p:objectName())
						and (p:getMark("kezhuanniluandid") > 0) then
						room:getThread():delay(300)
						local log = sgs.LogMessage()
						log.type = "$kezhuanniluanlog"
						log.from = player
						room:sendLog(log)
						room:broadcastSkillInvoke(self:objectName())
						p:drawCards(2)
						yes = 1
						break
					end
					if yes == 0 then
						if (player:getHp() > 3) or ((player:getHp() + player:getHp() + player:getHandcardNum()) >= 8) then
							room:getThread():delay(300)
							local log = sgs.LogMessage()
							log.type = "$kezhuanniluanlog"
							log.from = player
							room:sendLog(log)
							room:broadcastSkillInvoke(self:objectName())
							room:damage(sgs.DamageStruct(self:objectName(), player, player))
						end
					end
				end
			end
		end
	end,
}
kezhuanhansui:addSkill(kezhuanniluan)

kezhuanhuchou = sgs.CreateTriggerSkill {
	name = "kezhuanhuchou",
	events = { sgs.CardUsed, sgs.DamageCaused },
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.DamageCaused) then
			local damage = data:toDamage()
			if damage.from:hasSkill(self:objectName()) and (damage.to:getMark("&kezhuanhuchou") > 0) then
				room:sendCompulsoryTriggerLog(damage.from, self:objectName())
				local hurt = damage.damage
				damage.damage = hurt + 1
				data:setValue(damage)
			end
		end
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if use.card:isDamageCard() then
				for _, p in sgs.qlist(use.to) do
					if p:hasSkill(self:objectName()) then
						for _, p in sgs.qlist(room:getAllPlayers()) do
							room:setPlayerMark(p, "&kezhuanhuchou", 0)
						end
						room:setPlayerMark(use.from, "&kezhuanhuchou", 1)
						break
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end
}
kezhuanhansui:addSkill(kezhuanhuchou)

kezhuanjiemeng = sgs.CreateDistanceSkill {
	name = "kezhuanjiemeng$",
	correct_func = function(self, from)
		local yes = 0
		local num = 0
		if (from:getKingdom() == "qun") then num = num + 1 end
		for _, p in sgs.qlist(from:getAliveSiblings()) do
			if (from:getKingdom() == "qun")
				and (p:hasLordSkill(self:objectName()) or from:hasLordSkill(self:objectName())) then
				yes = 1
			end
			if (p:getKingdom() == "qun") then num = num + 1 end
		end
		if (yes == 1) then
			return -num
		else
			return 0
		end
	end,
}
kezhuanhansui:addSkill(kezhuanjiemeng)



kezhuanzhangchu = sgs.General(extension, "kezhuanzhangchu", "qun", 3, false)

kezhuanhuozhongCard = sgs.CreateSkillCard {
	name = "kezhuanhuozhongCard",
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		local shortage = sgs.Sanguosha:cloneCard("supply_shortage")
		return ((not to_select:containsTrick("SupplyShortage"))
			and (not sgs.Self:isProhibited(to_select, shortage))
			and (to_select:objectName() == sgs.Self:objectName()))
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		local supplyshortage = sgs.Sanguosha:cloneCard("supply_shortage", card:getSuit(), card:getNumber())
		supplyshortage:setSkillName("kezhuanhuozhong")
		supplyshortage:addSubcard(card)
		if not source:isProhibited(target, supplyshortage) then
			room:useCard(sgs.CardUseStruct(supplyshortage, source, target))
			local zhangchus = room:findPlayersBySkillName("kezhuanhuozhong")
			if (zhangchus:length() > 0) then
				local zc = room:askForPlayerChosen(source, zhangchus, "kezhuanhuozhong", "kezhuanhuozhong-choose", false,
					false)
				if zc then
					zc:drawCards(2)
				end
			end
		else
			supplyshortage:deleteLater()
		end
	end,
}

kezhuanhuozhongVS = sgs.CreateViewAsSkill {
	name = "kezhuanhuozhong",
	n = 1,
	view_filter = function(self, selected, to_select)
		return (to_select:isBlack() and not to_select:isKindOf("TrickCard"))
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = kezhuanhuozhongCard:clone()
			card:addSubcard(cards[1])
			return card
		else
			return nil
		end
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#kezhuanhuozhongCard")
	end,
}
kezhuanhuozhongex = sgs.CreateViewAsSkill {
	name = "kezhuanhuozhongex&",
	n = 1,
	view_filter = function(self, selected, to_select)
		return (to_select:isBlack() and not to_select:isKindOf("TrickCard"))
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = kezhuanhuozhongCard:clone()
			card:addSubcard(cards[1])
			return card
		else
			return nil
		end
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#kezhuanhuozhongCard")
	end,
}
if not sgs.Sanguosha:getSkill("kezhuanhuozhongex") then skills:append(kezhuanhuozhongex) end

kezhuanhuozhong = sgs.CreateTriggerSkill {
	name = "kezhuanhuozhong",
	events = { sgs.EventPhaseStart, sgs.EventPhaseEnd },
	view_as_skill = kezhuanhuozhongVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseEnd) then
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:hasSkill("kezhuanhuozhongex") then
					room:handleAcquireDetachSkills(player, "-kezhuanhuozhongex", false, true, false)
				end
			end
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Play) then
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:hasSkill(self:objectName()) then
						room:handleAcquireDetachSkills(player, "kezhuanhuozhongex", false, true, false)
						--room:acquireOneTurnSkills(player, self:objectName(), "kezhuanhuozhongex")
						break
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
kezhuanzhangchu:addSkill(kezhuanhuozhong)


kezhuanrihui = sgs.CreateTriggerSkill {
	name = "kezhuanrihui",
	events = { sgs.Damage, sgs.CardUsed },
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if damage.card:isKindOf("Slash") and (not damage.chain) and (not damage.transfer) then
				local allnum = 0
				local frinum = 0
				local enynum = 0
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getJudgingArea():length() ~= 0) then
						allnum = allnum + 1
						if player:isYourFriend(p) then
							frinum = frinum + 1
						else
							enynum = enynum + 1
						end
					end
				end
				if (frinum >= enynum) then room:setPlayerFlag(player, "wantuserihui") end
				if (allnum > 0) and player:askForSkillInvoke(self:objectName(), KezhuanToData("kezhuanrihui-ask:" .. player:objectName())) then
					room:setPlayerFlag(player, "-wantuserihui")
					room:broadcastSkillInvoke(self:objectName())
					for _, p in sgs.qlist(room:getAllPlayers()) do
						if (p:getJudgingArea():length() ~= 0) then
							p:drawCards(1, self:objectName())
						end
					end
				end
				room:setPlayerFlag(player, "-wantuserihui")
			end
		end
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") then
				for _, p in sgs.qlist(use.to) do
					room:setPlayerMark(p, "kezhuanrihui-Clear", 1)
				end
			end
			--[[if use.card:getSkillName() == "" then
				if use.m_addHistory then
					room:addPlayerHistory(player, use.card:getClassName(),-1)
				end
			end]]
		end
	end,
}
kezhuanzhangchu:addSkill(kezhuanrihui)


kezhuanxiahouen = sgs.General(extension, "kezhuanxiahouen", "wei", 4)

kezhuanchixueqingfengskill = sgs.CreateTriggerSkill {
	name = "kezhuanchixueqingfengskill",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.TargetConfirming, sgs.CardFinished },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.TargetConfirming then
			if use.card:isKindOf("Slash") and use.from:hasSkill(self:objectName()) and use.from:getWeapon():isKindOf("Kezhuan_chixueqingfeng") then
				room:sendCompulsoryTriggerLog(use.from, self:objectName())
				--sgs.Sanguosha:playAudioEffect("audio/equip/qinggang_sword.ogg", false)
				room:setEmotion(use.from, "weapon/qinggang_sword")
				use.from:setFlags("kezhuan_cxqffrom")
				for _, p in sgs.qlist(use.to) do
					room:setPlayerCardLimitation(p, "use,response", ".|.|.|hand", false)
					p:setFlags("kezhuan_cxqfto")
					room:addPlayerMark(p, "Armor_Nullified")
				end
				data:setValue(use)
			end
		elseif event == sgs.CardFinished and use.card:isKindOf("Slash") then
			if not player:hasFlag("kezhuan_cxqffrom") then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("kezhuan_cxqfto") then
					room:removePlayerCardLimitation(p, "use,response", ".|.|.|hand")
					p:setFlags("-kezhuan_cxqfto")
					if p:getMark("Armor_Nullified") then
						room:removePlayerMark(p, "Armor_Nullified")
					end
				end
			end
			player:setFlags("-kezhuan_cxqffrom")
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
Kezhuan_chixueqingfeng = sgs.CreateWeapon {
	name = "_kezhuan_chixueqingfeng",
	class_name = "Kezhuan_chixueqingfeng",
	range = 2,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, kezhuanchixueqingfengskill, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "kezhuanchixueqingfengskill", true, true)
	end,
}

Kezhuan_chixueqingfeng:clone(sgs.Card_Spade, 6):setParent(extension)

kezhuanhujian = sgs.CreateTriggerSkill {
	name = "kezhuanhujian",
	waked_skills = "kezhuanchixueqingfengskill",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseChanging, sgs.GameStart, sgs.CardResponded, sgs.CardUsed },
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.GameStart) and player:hasSkill(self:objectName()) then
			local cards = sgs.IntList()
			for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
				if sgs.Sanguosha:getEngineCard(id):isKindOf("Kezhuan_chixueqingfeng") and (room:getCardPlace(id) ~= sgs.Player_DrawPile)
					and (room:getCardPlace(id) ~= sgs.Player_PlaceHand) and (room:getCardPlace(id) ~= sgs.Player_PlaceEquip)
					and (room:getCardPlace(id) ~= sgs.Player_DiscardPile) then
					cards:append(id)
					break
				end
			end
			if not cards:isEmpty() then
				local thecard = sgs.Sanguosha:getCard(cards:at(0))
				room:broadcastSkillInvoke(self:objectName(), 1)
				player:obtainCard(thecard)
			end
		end
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) then
				for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
					if sgs.Sanguosha:getEngineCard(id):isKindOf("Kezhuan_chixueqingfeng")
						and (room:getCardPlace(id) == sgs.Player_DiscardPile) then
						for _, p in sgs.qlist(room:getAllPlayers()) do
							if (p:getMark("&kezhuanhujian-Clear") > 0) then
								if p:askForSkillInvoke(self:objectName(), KezhuanToData("kezhuanhujian-ask:" .. p:objectName())) then
									room:broadcastSkillInvoke(self:objectName(), 2)
									p:obtainCard(sgs.Sanguosha:getCard(id))
									break
								end
							end
						end
						break
					end
				end
			end
		end
		if (event == sgs.CardResponded) then
			local response = data:toCardResponse()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if (p:getMark("&kezhuanhujian-Clear") > 0) then
					room:setPlayerMark(p, "&kezhuanhujian-Clear", 0)
				end
			end
			room:setPlayerMark(player, "&kezhuanhujian-Clear", 1)
		end
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if (p:getMark("&kezhuanhujian-Clear") > 0) then
					room:setPlayerMark(p, "&kezhuanhujian-Clear", 0)
				end
			end
			room:setPlayerMark(player, "&kezhuanhujian-Clear", 1)
		end
	end,
}
kezhuanxiahouen:addSkill(kezhuanhujian)

kezhuanshiliVS = sgs.CreateOneCardViewAsSkill {
	name = "kezhuanshili",
	response_or_use = true,
	view_filter = function(self, card)
		return (not card:isEquipped()) and card:isKindOf("EquipCard")
	end,
	view_as = function(self, card)
		local duel = sgs.Sanguosha:cloneCard("duel", card:getSuit(), card:getNumber())
		duel:addSubcard(card:getId())
		duel:setSkillName("kezhuanshili")
		return duel
	end,
	enabled_at_play = function(self, player)
		return (player:getMark("usekezhuanshili-PlayClear") == 0)
	end,
}

kezhuanshili = sgs.CreateTriggerSkill {
	name = "kezhuanshili",
	events = { sgs.CardUsed },
	view_as_skill = kezhuanshiliVS,
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if (use.card:getSkillName() == "kezhuanshili") then
				if (player:objectName() == use.from:objectName()) then
					room:setPlayerFlag(player, "usekezhuanshili")
					room:setPlayerMark(player, "usekezhuanshili-PlayClear", 1)
				end
			end
		end
	end,
}
kezhuanxiahouen:addSkill(kezhuanshili)




kezhuanfanjiangzhangda = sgs.General(extension, "kezhuanfanjiangzhangda", "wu", 5)

kezhuanfushan = sgs.CreateTriggerSkill {
	name = "kezhuanfushan",
	frequency = sgs.Skill_Frequent,
	events = { sgs.EventPhaseStart, sgs.EventPhaseEnd },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Start) then
				local players = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:isYourFriend(player) then room:setPlayerFlag(p, "wantusefushan") end
					local card = room:askForExchange(p, self:objectName(), 1, 0, true,
						"kezhuanfushangive:" .. player:objectName(), true)
					room:setPlayerFlag(p, "-wantusefushan")
					if card then
						room:addPlayerMark(p, "&kezhuanfushan-PlayClear", 1)
						room:addPlayerMark(player, "kezhuanfushannum-PlayClear", 1)
						room:obtainCard(player, card,
							sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), player:objectName(),
								self:objectName(), ""), false)
						room:addSlashCishu(player, 1, true)
					end
				end
			end
		end
		if (event == sgs.EventPhaseEnd) then
			if (player:getPhase() == sgs.Player_Play) then
				local willlose = 0
				if sgs.Slash_IsAvailable(player) then
					willlose = willlose + 1
				end
				local num = 0
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getMark("&kezhuanfushan-PlayClear") > 0 then
						num = num + 1
					end
				end
				if (num == player:getMark("kezhuanfushannum-PlayClear")) and (num ~= 0) then
					willlose = willlose + 1
				end
				if (willlose == 2) then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:loseHp(player, 2)
				else
					local cha = player:getMaxHp() - player:getHandcardNum()
					if (cha > 0) then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						player:drawCards(cha)
					end
				end
			end
		end
	end,
}
kezhuanfanjiangzhangda:addSkill(kezhuanfushan)

















kezhuancaimaozhangyun = sgs.General(extension, "kezhuancaimaozhangyun", "wei", 4, true, true)
kezhuancaimaozhangyun:addSkill("lianzhou")
kezhuancaimaozhangyun:addSkill("jinglan")

kezhuanjianggan = sgs.General(extension, "kezhuanjianggan", "wei", 3, true, true)
kezhuanjianggan:addSkill("weicheng")
kezhuanjianggan:addSkill("daoshu")

kezhuanhuangchengyan = sgs.General(extension, "kezhuanhuangchengyan", "qun", 3, true, true)
kezhuanhuangchengyan:addSkill("guanxu")
kezhuanhuangchengyan:addSkill("yashi")

kezhuankanze = sgs.General(extension, "kezhuankanze", "wu", 3, true, true)
kezhuankanze:addSkill("xiashu")
kezhuankanze:addSkill("tenyearkuanshi")



sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable {
	["kearjsrgszhuan"] = "江山如故·转",

	["kezhuan_ying"] = "影",
	["_kezhuan_ying"] = "影",
	["kespecial_card"] = "特殊牌",

	[":_kezhuan_ying"] = "基本牌<br /><b>时机</b>：无<br /><b>目标</b>：无<br /><b>效果</b>：无",

	["_kezhuan_chixueqingfeng"] = "赤血青锋",
	["kezhuanchixueqingfengskill"] = "赤血青锋",
	["Kezhuan_chixueqingfeng"] = "赤血青锋",
	[":_kezhuan_chixueqingfeng"] = "装备牌·武器<br /><b>攻击范围</b>：２\
	<b>武器技能</b>：锁定技，你使用的【杀】结算结束前，目标角色不能使用或打出手牌，且此【杀】无视其防具。",

	--郭嘉
	["kezhuanguojia"] = "郭嘉-转",
	["&kezhuanguojia"] = "郭嘉",
	["#kezhuanguojia"] = "赤壁的先知",
	["designer:kezhuanguojia"] = "官方",
	["cv:kezhuanguojia"] = "官方",
	["illustrator:kezhuanguojia"] = "Kayak&DEEMO",

	["kezhuanqingzi"] = "轻辎",
	[":kezhuanqingzi"] = "<font color='green'><b>准备阶段，</s></font>你可以弃置任意名其他角色装备区里的各一张牌，然后这些角色获得“神速”直到你下回合开始。",

	["kezhuandingce"] = "定策",
	[":kezhuandingce"] = "当你受到伤害后，你可以弃置你和伤害来源的各一张手牌，若这两张牌颜色相同，你视为使用一张【洞烛先机】。",

	["kezhuanzhenfeng"] = "针锋",
	[":kezhuanzhenfeng"] = "<font color='green'><b>出牌阶段每种类型限一次，</s></font>你可以视为使用一张存活角色的技能描述中包含的基本牌或普通锦囊牌（无次数和距离限制），当此牌对一名技能描述中包含此牌名的角色生效后，你对其造成1点伤害。",

	["kezhuanzhenfeng1"] = "你可以视为使用【%src】",
	["kezhuanqingzi-ask"] = "你可以选择发动“轻辎”的角色",
	["kezhuandingce-discard"] = "请选择发动“定策”弃置的牌",

	["$kezhuanqingzi1"] = "下一步棋，我已经计划好了。",
	["$kezhuanqingzi2"] = "我已有所顿悟。",
	["$kezhuandingce1"] = "一身才落拓，狂慧藐凡尘。",
	["$kezhuandingce2"] = "平生多偃蹇，何幸得天恩。",
	["$kezhuanzhenfeng1"] = "深感情之切，策谋以报君！",
	["$kezhuanzhenfeng2"] = "此笺相寄予，数语以销魂。",

	["~kezhuanguojia"] = "奉孝将去，主公保重。",


	--马超
	["kezhuanmachao"] = "马超-转",
	["&kezhuanmachao"] = "马超",
	["#kezhuanmachao"] = "潼关之勇",
	["designer:kezhuanmachao"] = "官方",
	["cv:kezhuanmachao"] = "官方",
	["illustrator:kezhuanmachao"] = "鬼画府",

	["kezhuanzhuiming"] = "追命",
	[":kezhuanzhuiming"] = "当你使用【杀】指定唯一目标后，你可以声明一种颜色且该角色可以弃置任意张牌，然后你展示其一张牌，若此牌的颜色与你声明的颜色相同，此【杀】不计入次数、不能被响应且造成的伤害+1。",

	["$kezhuanzhuimingblack"] = "%from 声明的颜色为 <b>黑色</s> ！",
	["$kezhuanzhuimingred"] = "%from 声明的颜色为 <b>红色</s> ！",
	["$kezhuanzhuimingtrigger"] = "%from 的 <font color='yellow'><b>“追命”</s></font> 生效，此【杀】不计入次数、不能被响应且造成的伤害+1！",
	["kezhuanzhuiming:zhuimingblack"] = "黑色",
	["kezhuanzhuiming:zhuimingred"] = "红色",

	["$kezhuanzhuiming1"] = "以尔等之血，祭我族人！",
	["$kezhuanzhuiming2"] = "去地下忏悔你们的罪行吧！",

	["~kezhuanmachao"] = "西凉众将离心，父仇难报！",


	--张任
	["kezhuanzhangren"] = "张任-转",
	["&kezhuanzhangren"] = "张任",
	["#kezhuanzhangren"] = "索命神射",
	["designer:kezhuanzhangren"] = "官方",
	["cv:kezhuanzhangren"] = "官方",
	["illustrator:kezhuanzhangren"] = "鬼画府，极乐",

	["kezhuanfuni"] = "伏匿",
	["kezhuanfuni-distribute"] = "你可以将这些【影】分配给任意名角色",
	[":kezhuanfuni"] = "锁定技，你的攻击范围始终为0；<font color='green'><b>每轮开始时，</s></font>你将游戏外的X张【影】交给任意名角色（X为存活角色数的一半，向上取整）；当一张【影】进入弃牌堆时，你当前回合使用牌无距离限制且不能被响应。",

	["kezhuanchuanxin"] = "穿心",
	["kezhuanchuanxin-ask"] = "穿心：你可以将一张牌当【杀】使用",
	[":kezhuanchuanxin"] = "一名角色的<font color='green'><b>结束阶段，</s></font>你可以将一张牌当【杀】使用；你以此法使用的【杀】对一名角色造成伤害时，伤害值+X（X为其当前回合回复过的体力值）。",
	["#kezhuandestroyEquip"] = "【影】被销毁！",
	["$kezhuanchuanxinda"] = "%from 本回合回复了 %arg 点体力，此伤害值增加等量数值 !",

	["$kezhuanfuni1"] = "进入埋伏，倒要看你如何脱身。",
	["$kezhuanfuni2"] = "谅你肋生双翅，也逃不出这天罗地网。",
	["$kezhuanchuanxin1"] = "弩搭穿心箭，葬敌落凤坡。",
	["$kezhuanchuanxin2"] = "麒麟弓一出，定穿心取命。",

	["~kezhuanzhangren"] = "诸将无能，悉数终亡。",

	["$kezhuanfunixiangying"] = "%from 的 <font color='yellow'><b>“伏匿”</s></font> 被触发，此牌不能被响应！",


	--张飞
	["kezhuanzhangfei"] = "张飞-转",
	["&kezhuanzhangfei"] = "张飞",
	["#kezhuanzhangfei"] = "长坂之威",
	["designer:kezhuanzhangfei"] = "官方",
	["cv:kezhuanzhangfei"] = "官方",
	["illustrator:kezhuanzhangfei"] = "鬼画府",

	["kezhuanbaohe"] = "暴喝",
	[":kezhuanbaohe"] = "一名角色的<font color='green'><b>出牌阶段结束时，</s></font>你可以弃置两张牌视为对攻击范围内包含其的所有其他角色使用一张【杀】；你以此法使用的【杀】造成的伤害+X（X为此牌被响应的次数）。",
	["$kezhuanbaoheda"] = "%from 的 <font color='yellow'><b>“暴喝”</s></font> 被触发，此牌伤害 + %arg ！",

	["kezhuanxushi"] = "虚势",
	[":kezhuanxushi"] = "出牌阶段限一次，你可以交给任意名其他角色各一张牌，然后从游戏外获得2X张【影】（X为你给出的牌数）。",


	["kezhuanbaohe-ask"] = "你可以弃置两张牌对 %src 发动“暴喝”",
	["kezhuanxushigive"] = "请选择交给 %src 的牌",

	["$kezhuanbaohe1"] = "哇呀呀呀呀呀！",
	["$kezhuanbaohe2"] = "此声一震，桥断水停！",
	["$kezhuanxushi1"] = "我燕人自有妙计！",
	["$kezhuanxushi2"] = "偃旗息鼓，蓄势待发！",

	["~kezhuanzhangfei"] = "我这脾气，该收敛收敛了。",


	--夏侯荣
	["kezhuanxiahourong"] = "夏侯荣-转",
	["&kezhuanxiahourong"] = "夏侯荣",
	["#kezhuanxiahourong"] = "擐甲执兵",
	["designer:kezhuanxiahourong"] = "官方",
	["cv:kezhuanxiahourong"] = "傲雪梅枪",
	["illustrator:kezhuanxiahourong"] = "鬼画府，极乐",

	["#kezhuanfenjianex"] = "奋剑",
	["kezhuanfenjianex"] = "奋剑",
	["kezhuanfenjian"] = "奋剑",

	["kezhuanfenjianpeach"] = "奋剑:桃",
	["kezhuanfenjianduel"] = "奋剑:决斗",

	[":kezhuanfenjian"] = "<font color='green'><b>每回合各限一次，</s></font>你可以令你当前回合受到的伤害+1视为使用一张【决斗】或对一名处于濒死状态的其他角色使用一张【桃】。",

	["$kezhuanfenjian1"] = "临险必夷，背水一战！",
	["$kezhuanfenjian2"] = "处变之际，决胜之间！",

	["~kezhuanxiahourong"] = "天下已定，我固当烹！",

	--孙尚香
	["kezhuansunshuangxiang"] = "孙尚香-转",
	["&kezhuansunshuangxiang"] = "孙尚香",
	["#kezhuansunshuangxiang"] = "情断吴江",
	["designer:kezhuansunshuangxiang"] = "官方",
	["cv:kezhuansunshuangxiang"] = "官方",
	["illustrator:kezhuansunshuangxiang"] = "鬼画府，极乐",

	["kezhuanguiji"] = "闺忌",
	["kezhuanguijiagain"] = "闺忌：与其交换手牌",
	--[":kezhuanguiji"] = "出牌阶段，你可以与一名手牌数小于你的男性角色交换手牌，若如此做，“闺忌”失效直到其死亡时，或其下个<font color='green'><b>出牌阶段结束时，</s></font>你可以与其交换手牌。",
	[":kezhuanguiji"] = "出牌阶段限一次，你可以与一名手牌数小于你的男性角色交换手牌，然后“闺忌”失效直到满足下列一项:\
	1.该角色下个<font color='green'><b>出牌阶段结束时</s></font>，且你可以与其交换手牌；\
	2.该角色死亡时。",

	["kezhuanjiaohaoex"] = "骄豪放牌",
	[":kezhuanjiaohaoex"] = "出牌阶段限一次，你可以将手牌中的一张装备牌置于一名拥有“骄豪”的角色对应空置的装备栏中。",
	["kezhuanjiaohao"] = "骄豪",
	[":kezhuanjiaohao"] = "其他角色的出牌阶段限一次，其可以将手牌中的一张装备牌置于你对应空置的装备栏中；<font color='green'><b>准备阶段，</s></font>你从游戏外获得X张【影】（X为你空置的装备栏数的一半，向上取整）。",

	["$kezhuanguiji1"] = "鸾凤和鸣，情投意合。",
	["$kezhuanguiji2"] = "双剑同鸣，双心灵犀。",
	["$kezhuanjiaohao1"] = "边月随弓影，胡霜拂剑花！",
	["$kezhuanjiaohao2"] = "轻叶心间过，刀剑光影掠！",
	["$kezhuanjiaohao3"] = "这些都交给我吧！",
	["$kezhuanjiaohao4"] = "那小女子就却之不恭喽！",

	["~kezhuansunshuangxiang"] = "何处吴歌起，夜望不知乡。",


	--黄忠
	["kezhuanhuangzhong"] = "黄忠-转",
	["&kezhuanhuangzhong"] = "黄忠",
	["#kezhuanhuangzhong"] = "定军之英",
	["designer:kezhuanhuangzhong"] = "官方",
	["cv:kezhuanhuangzhong"] = "官方",
	["illustrator:kezhuanhuangzhong"] = "鬼画府",

	["kezhuancuifeng"] = "摧锋",
	["kezhuancuifeng-ask"] = "请选择此【%src】的目标 -> 点击确定",
	["kezhuancuifengchongzhi"] = "摧锋重置",
	[":kezhuancuifeng"] = "限定技，出牌阶段，你可以视为使用一张指定唯一目标的伤害类牌（不能是延时类锦囊牌，无距离限制），若此牌没有造成伤害或造成的总伤害值大于1，本<font color='green'><b>回合结束时，</s></font>“摧锋”视为未发动过。",


	["kezhuandengnan"] = "登难",
	[":kezhuandengnan"] = "限定技，出牌阶段，你可以视为使用一张非伤害类普通锦囊牌，若此牌的目标均于本回合受到过伤害，本<font color='green'><b>回合结束时，</s></font>“登难”视为未发动过。",
	["kezhuandengnanover"] = "登难目标达成",
	["kezhuandengnantar"] = "登难目标",
	["kezhuandengnanda"] = "已受到伤害",
	["kezhuandengnan-ask"] = "请选择此【%src】的目标 -> 点击确定",

	["$kezhuandengnan1"] = "一箭从戎起长沙，射得益州做汉家！",
	["$kezhuandengnan2"] = "将拜五虎从风雨，功夸定军造乾坤！",
	["$kezhuancuifeng1"] = "龙骨成镞，矢破苍穹。",
	["$kezhuancuifeng2"] = "凤翎为羽，箭没坚城。",

	["~kezhuanhuangzhong"] = "末将，有负主公重托。",


	--娄圭
	["kezhuanlougui"] = "娄圭-转",
	["&kezhuanlougui"] = "娄圭",
	["#kezhuanlougui"] = "梦梅居士",
	["designer:kezhuanlougui"] = "官方",
	["cv:kezhuanlougui"] = "三国演义",
	["illustrator:kezhuanlougui"] = "鬼画府",

	["kezhuanshacheng"] = "沙城",

	["kezhuanshacheng-ask"] = "请选择“沙城”摸牌的角色",
	[":kezhuanshacheng"] = "<font color='green'><b>游戏开始时，</s></font>你将牌堆顶的两张牌置于武将牌上，称为“沙城”；当一名角色使用的【杀】结算完毕后，你可以将一张“沙城”置入弃牌堆并令一名目标角色摸X张牌（X为其当前回合失去的牌数且至多为5）。",
	["kezhuanshacheng:kezhuanshacheng-ask"] = "你可以发动“沙城”令一名目标角色摸牌",


	["kezhuanninghan"] = "凝寒",
	[":kezhuanninghan"] = "锁定技，所有角色手牌中的♣【杀】均视为冰【杀】；当一名角色受到冰冻伤害后，你可以将造成此伤害的牌置于武将牌上，称为“沙城”。",
	["kezhuanninghan:kezhuanninghan-ask"] = "你可以发动“凝寒”将 %src 置于武将牌上",
	["kezhuanninghanbuff"] = "凝寒杀",
	[":kezhuanninghanbuff"] = "锁定技，你手牌中的♣【杀】均视为冰【杀】。",

	["kezhuanshachengcandraw"] = "沙城可摸牌",

	["$kezhuanshacheng1"] = "天色已晚，丞相为何不筑城建营呢？",
	["$kezhuanshacheng2"] = "晚上极冷，边筑土边泼水，马上冻结，随筑随冻，不就成了？",
	["$kezhuanninghan1"] = "哈哈哈哈哈，丞相熟知兵法，难道不知因时而动？",
	["$kezhuanninghan2"] = "丞相，我只是希望您能早日统一天下，让百姓脱离战乱之苦。",

	["~kezhuanlougui"] = "啊，请丞相好自为之。",




	--韩遂
	["kezhuanhansui"] = "韩遂-转",
	["&kezhuanhansui"] = "韩遂",
	["#kezhuanhansui"] = "雄踞北疆",
	["designer:kezhuanhansui"] = "官方",
	["cv:kezhuanhansui"] = "官方",
	["illustrator:kezhuanhansui"] = "盲特",

	["kezhuanniluan"] = "逆乱",
	["kezhuanniluan-ask"] = "你可以发动“逆乱”",
	[":kezhuanniluan"] = "<font color='green'><b>准备阶段，</s></font>你可以令一名对你造成过伤害的角色摸两张牌，或弃置一张牌对一名未对你造成过伤害的角色造成1点伤害。",
	["$kezhuanniluanlog"] = "%from 发动了 <font color='yellow'><b>“逆乱”</s></font> ",

	["kezhuanhuchou"] = "互雠",
	[":kezhuanhuchou"] = "锁定技，你对上一名对你使用伤害类牌的角色造成的伤害+1。",

	["kezhuanjiemeng"] = "皆盟",
	[":kezhuanjiemeng"] = "主公技，锁定技，群势力角色与其他角色的距离-X（X为群势力角色数）。",

	["$kezhuanniluan1"] = "天下动乱，我怎能坐视不管？",
	["$kezhuanniluan2"] = "骁雄武力，岂可甘为他将？",
	["$kezhuanhuchou1"] = "众十余万，天下扰动。",
	["$kezhuanhuchou2"] = "诛杀宦官，吾亦出力！",

	["~kezhuanhansui"] = "称雄三十载，一败化为尘。",


	--张楚
	["kezhuanzhangchu"] = "张楚-转",
	["&kezhuanzhangchu"] = "张楚",
	["#kezhuanzhangchu"] = "大贤后裔",
	["designer:kezhuanzhangchu"] = "官方",
	["cv:kezhuanzhangchu"] = "官方",
	["illustrator:kezhuanzhangchu"] = "花第",

	["kezhuanhuozhong"] = "惑众",
	["kezhuanhuozhongex"] = "惑众放牌",
	[":kezhuanhuozhong"] = "每名角色的出牌阶段限一次，其可以将一张黑色非锦囊牌当【兵粮寸断】置于其判定区内，然后令一名拥有“惑众”的角色摸两张牌。",
	[":kezhuanhuozhongex"] = "出牌阶段限一次，你可以将一张黑色非锦囊牌当【兵粮寸断】置于你的判定区内，然后令一名拥有“惑众”的角色摸两张牌。",

	["kezhuanrihui"] = "日慧",
	[":kezhuanrihui"] = "当你使用【杀】对目标角色造成伤害后，你可以令判定区有牌的其他角色各摸一张牌；你每回合对判定区没有牌的角色使用的第一张【杀】无次数限制。",

	["kezhuanrihui:kezhuanrihui-ask"] = "你可以发动“日慧”令判定区有牌的角色各摸一张牌",

	["$kezhuanhuozhong1"] = "天地裹黄巾者无数，如麦粟绽于秋雨。",
	["$kezhuanhuozhong2"] = "天地之不仁者，吾可登长辇而伐天地。",
	["$kezhuanrihui1"] = "今连方七十二，宁为战魂，勿做刍狗。",
	["$kezhuanrihui2"] = "吾父黄泉未远，定可见黄天再现人间。",

	["~kezhuanzhangchu"] = "大贤良师之女，不畏一死。",

	--夏侯恩
	["kezhuanxiahouen"] = "夏侯恩-转",
	["&kezhuanxiahouen"] = "夏侯恩",
	["#kezhuanxiahouen"] = "背剑之将",
	["designer:kezhuanxiahouen"] = "官方",
	["cv:kezhuanxiahouen"] = "官方",
	["illustrator:kezhuanxiahouen"] = "蚂蚁君",

	["kezhuanhujian"] = "护剑",
	[":kezhuanhujian"] = "<font color='green'><b>游戏开始时，</s></font>你从游戏外获得一张【赤血青锋】；一个<font color='green'><b>回合结束时，</s></font>此回合最后一名使用或打出牌的角色可以获得弃牌堆中的【赤血青锋】。",
	["kezhuanhujian:kezhuanhujian-ask"] = "护剑：你可以获得弃牌堆中的【赤血青锋】",

	["kezhuanshili"] = "恃力",
	[":kezhuanshili"] = "出牌阶段限一次，你可以将手牌中的一张装备牌当【决斗】使用。",

	["$kezhuanhujian1"] = "得此宝剑，如虎添翼！",
	["$kezhuanhujian2"] = "丞相之宝，汝岂配用之？啊哈！",
	["$kezhuanshili1"] = "小小匹夫，可否闻长坂剑神之名啊？",
	["$kezhuanshili2"] = "此剑吹毛得过，削铁如泥！",

	["~kezhuanxiahouen"] = "长坂剑神，也陨落了。",


	--庞统
	["kezhuanpangtong"] = "庞统-转",
	["&kezhuanpangtong"] = "庞统",
	["#kezhuanpangtong"] = "荆楚之高俊",
	["designer:kezhuanpangtong"] = "官方",
	["cv:kezhuanpangtong"] = "官方",
	["illustrator:kezhuanpangtong"] = "鬼画府，极乐",

	["kezhuanmanjuan"] = "漫卷",
	[":kezhuanmanjuan"] = "每回合每种点数限一次，若你没有手牌，你可以使用或打出本回合置入弃牌堆的牌。",

	["kezhuanyangming"] = "养名",
	[":kezhuanyangming"] = "出牌阶段限一次，你可以与一名角色拼点：若其赢，其摸X张牌（X为其本阶段拼点没赢的次数）且你回复1点体力，否则你可以对其重复此流程。",

	["kezhuanyangming:kezhuanyangming-jixu"] = "你可以发动“养名”继续与 %src 拼点",
	["kezhuanyangminglose"] = "拼点没赢",

	["kezhuanmanjuan0"] = "你可以使用其中一张牌",
	["kezhuanmanjuan2"] = "请选择此牌的目标 -> 点击确定",
	["kezhuanmanjuan1"] = "你可以使用此牌",

	["$kezhuanmanjuan1"] = "吾非百里才，必有千里之行。",
	["$kezhuanmanjuan2"] = "展吾骥足，施吾羽翅！",
	["$kezhuanyangming1"] = "表虽言过其实，实则引人向善。",
	["$kezhuanyangming2"] = "吾与卿之才干，孰高孰低？",

	["~kezhuanpangtong"] = "雏凤未飞已先陨。",


	--范疆＆张达
	["kezhuanfanjiangzhangda"] = "范疆＆张达-转",
	["&kezhuanfanjiangzhangda"] = "范疆＆张达",
	["#kezhuanfanjiangzhangda"] = "你死我亡",
	["designer:kezhuanfanjiangzhangda"] = "官方",
	["cv:kezhuanfanjiangzhangda"] = "官方",
	["illustrator:kezhuanfanjiangzhangda"] = "游漫美绘",

	["kezhuanfushan"] = "负山",
	[":kezhuanfushan"] = "<font color='green'><b>出牌阶段开始时，</s></font>所有其他角色可以依次选择是否交给你一张牌并令你此阶段可以多使用一张【杀】；<font color='green'><b>出牌阶段结束时，</s></font>若你使用【杀】的剩余次数不为0且此阶段以此法交给你牌的角色均存活，你失去2点体力，否则你将手牌摸至体力上限。",

	["kezhuanfushangive"] = "负山：你可以交给 %src 一张牌",

	["$kezhuanfushan1"] = "鞭鞭入肉，似钢钉入骨，此仇如何消得？",
	["$kezhuanfushan2"] = "斥我如奴，鞭我如畜，如何叫我以德报怨？",

	["~kezhuanfanjiangzhangda"] = "什么！刘备伐吴了？",


	--蔡瑁＆张允
	["kezhuancaimaozhangyun"] = "蔡瑁＆张允-转",
	["&kezhuancaimaozhangyun"] = "蔡瑁＆张允",
	["#kezhuancaimaozhangyun"] = "乘雷潜狡",
	["designer:kezhuancaimaozhangyun"] = "官方",
	["cv:kezhuancaimaozhangyun"] = "官方",
	["illustrator:kezhuancaimaozhangyun"] = "君桓文化",
	["~kezhuancaimaozhangyun"] = "丞相，冤枉，冤枉啊！",

	--黄承彦
	["kezhuanhuangchengyan"] = "黄承彦-转",
	["&kezhuanhuangchengyan"] = "黄承彦",
	["#kezhuanhuangchengyan"] = "沔阳雅士",
	["designer:kezhuanhuangchengyan"] = "官方",
	["cv:kezhuanhuangchengyan"] = "官方",
	["illustrator:kezhuanhuangchengyan"] = "凡果",
	["~kezhuanhuangchengyan"] = "卧龙出山天伦逝，悔教吾婿离南阳。",

	--蒋干
	["kezhuanjianggan"] = "蒋干-转",
	["&kezhuanjianggan"] = "蒋干",
	["#kezhuanjianggan"] = "锋镝悬信",
	["designer:kezhuanjianggan"] = "官方",
	["cv:kezhuanjianggan"] = "官方",
	["illustrator:kezhuanjianggan"] = "biou09",
	["~kezhuanjianggan"] = "丞相，再给我一次机会啊！",

	--阚泽
	["kezhuankanze"] = "阚泽-转",
	["&kezhuankanze"] = "阚泽",
	["#kezhuankanze"] = "慧眼的博士",
	["designer:kezhuankanze"] = "官方",
	["cv:kezhuankanze"] = "官方",
	["illustrator:kezhuankanze"] = "游漫美绘",
	["~kezhuankanze"] = "谁又能来宽释我呢？",























}
return { extension }
