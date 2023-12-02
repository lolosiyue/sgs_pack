yongjian = sgs.Package("yongjian", sgs.Package_CardPack)

function AddPresentCard(c, suit, number, is_gift, revise)
	c = c:clone(suit, number)
	if c
	then
		if is_gift
		then
			--c:setProperty("YingBianEffects",ToData("present_card"))
			c:addCharTag("present_card")
			c:setGift(true)
		end
		if revise then c:setObjectName(revise) end
		c:setParent(yongjian)
	end
end

function AddCloneCard(name, suit, number, is_gift, revise)
	local c = sgs.Sanguosha:cloneCard(name)
	if c
	then
		c = sgs.Sanguosha:cloneCard(c:getClassName(), suit, number)
		if is_gift
		then
			--c:setProperty("YingBianEffects",ToData("present_card"))
			c:addCharTag("present_card")
			c:setGift(true)
		end
		c:setObjectName(revise or name)
		c:setParent(yongjian)
	end
end

yj_poison = sgs.CreateBasicCard {
	name = "yj_poison",
	class_name = "YjPoison",
	subtype = "debuff_card",
	can_recast = false,
	available = function(self, player)
		return false
	end,
	filter = function(self, targets, to_select, source)
		--if source:isProhibited(to_select,self) then return end
		return #targets < 1 and source ~= to_select
	end,
	about_to_use = function(self, room, use)
		room:broadcastSkillInvoke("yj_poison", use.from:isMale(), 1)
		for _, to in sgs.list(use.to) do
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, use.from:objectName(),
				to:objectName(), "yj_poison", "")
			Log_message("$yj_poison", use.from, use.to, self:getEffectiveId(), "yj_poison")
			use.from:addMark("BanPoisonEffect")
			room:obtainCard(to, self, reason)
			use.from:removeMark("BanPoisonEffect")
			break
		end
	end,
}
AddPresentCard(yj_poison, 0, 4, true)
AddPresentCard(yj_poison, 0, 5, true)
AddPresentCard(yj_poison, 0, 9, true)
AddPresentCard(yj_poison, 0, 10, true)
AddPresentCard(yj_poison, 1, 4)

AddCloneCard("slash", 2, 5, true)
AddCloneCard("slash", 2, 10, true)
AddCloneCard("slash", 2, 11, true)
AddCloneCard("slash", 2, 12, true)

AddCloneCard("slash", 0, 6, nil, "yj_stabs_slash")
AddCloneCard("slash", 0, 7, nil, "yj_stabs_slash")
AddCloneCard("slash", 0, 8, nil, "yj_stabs_slash")
AddCloneCard("slash", 1, 2, nil, "yj_stabs_slash")
AddCloneCard("slash", 1, 6, nil, "yj_stabs_slash")
AddCloneCard("slash", 1, 7, nil, "yj_stabs_slash")
AddCloneCard("slash", 1, 8, nil, "yj_stabs_slash")
AddCloneCard("slash", 1, 9, nil, "yj_stabs_slash")
AddCloneCard("slash", 1, 10, nil, "yj_stabs_slash")
AddCloneCard("slash", 3, 13, nil, "yj_stabs_slash")

AddCloneCard("jink", 2, 2, true)
AddCloneCard("jink", 3, 2, true)
AddCloneCard("jink", 3, 5)
AddCloneCard("jink", 3, 6)
AddCloneCard("jink", 3, 7)
AddCloneCard("jink", 3, 8)
AddCloneCard("jink", 3, 12)

AddCloneCard("peach", 2, 7)
AddCloneCard("peach", 2, 8)
AddCloneCard("peach", 3, 11, true)

AddCloneCard("snatch", 0, 3, true)

AddCloneCard("nullification", 0, 11)
AddCloneCard("nullification", 1, 11)
AddCloneCard("nullification", 1, 12)

AddCloneCard("amazing_grace", 2, 3, true)

AddCloneCard("duel", 3, 1, true)

yj_numabf = sgs.CreateDistanceSkill {
	name = "yj_numa",
	fixed_func = function(self, from, to)
		local to_dh = to and to:getOffensiveHorse()
		if to_dh and to_dh:objectName() == "yj_numa"
			and to:getMark("Equips_Nullified") < 1
		then
			return 1
		end
		return -1
	end
}
yj_numa = sgs.CreateOffensiveHorse {
	name = "yj_numa",
	class_name = "YjNuma",
	--	correct = -1,
	is_gift = true,
	on_install = function(c, player)
		local room = player:getRoom()
		room:acquireSkill(player, yj_numabf, false, true, false)
	end,
	on_uninstall = function(c, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "yj_numa", true, true)
	end
}
AddPresentCard(yj_numa, 1, 13, true)
addToSkills(yj_numabf)

--[[
AddCloneCard("OffensiveHorse",1,13,true,"yj_numa")
sgs.HorseSkill.yj_numa = {
	on_install = function(c,player,room)
		room:attachSkillToPlayer(player,"yj_numa")
	end,
	on_uninstall = function(c,player,room)
		room:detachSkillFromPlayer(player,"yj_numa",true,true)
	end
}
AddCloneCard("DefensiveHorse",2,13,true,"yj_zhanxiang")
addToSkills(yj_zhanxiangTr)
sgs.HorseSkill.yj_zhanxiang = {
	on_install = function(c,player,room)
		room:acquireSkill(player,"yj_zhanxiang",false,true,false)
		player:setTag("yj_zhanxiang",ToData(true))
	end,
	on_uninstall = function(c,player,room)
		player:detachSkill("yj_zhanxiang")
		player:removeTag("yj_zhanxiang")
	end
}

--]]

yj_zhanxiangTr = sgs.CreateTriggerSkill {
	name = "yj_zhanxiang",
	events = { sgs.BeforeCardsMove },
	can_trigger = function(self, target)
		local dh = target and target:getDefensiveHorse()
		return dh and dh:objectName() == "yj_zhanxiang"
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.BeforeCardsMove
		then
			local move = data:toMoveOneTime()
			if move.to and player:objectName() == move.to:objectName()
			then
				local ids = {}
				for _, id in sgs.list(move.card_ids) do
					if player:getTag("PresentCard"):toString() == tostring(id)
					then
						table.insert(ids, id)
					end
				end
				if #ids > 0
				then
					room:sendCompulsoryTriggerLog(player, "yj_zhanxiang", true)
					room:setEmotion(player, "armor/yj_zhanxiang")
					local tos = sgs.SPlayerList()
					if move.from then tos:append(BeMan(room, move.from)) end
					Log_message("$yj_zhanxiang", player, tos, table.concat(ids, "+"), "yj_zhengyu_fail")
					move.reason.m_skillName = "yj_zhengyu_fail"
					move.to_place = sgs.Player_DiscardPile
					move.to = nil
					data:setValue(move)
				end
			end
		end
		return false
	end
}
yj_zhanxiang = sgs.CreateDefensiveHorse {
	name = "yj_zhanxiang",
	class_name = "YjZhanxiang",
	--	correct = 1,
	is_gift = true,
	on_install = function(c, player)
		local room = player:getRoom()
		room:acquireSkill(player, yj_zhanxiangTr, false, true, false)
	end,
	on_uninstall = function(c, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "yj_zhanxiang", true, true)
	end
}
AddPresentCard(yj_zhanxiang, 2, 13, true)

yj_chenhuodajie = sgs.CreateTrickCard {
	name = "yj_chenhuodajie",
	class_name = "YjChenhuodajie",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	damage_card = true,
	available = function(self, player)
		for _, to in sgs.list(player:getAliveSiblings()) do
			if CanToCard(self, player, to)
			then
				return self:cardIsAvailable(player)
			end
		end
	end,
	filter = function(self, targets, to_select, source)
		if source:isProhibited(to_select, self) then return end
		return to_select:getHandcardNum() > 0 and to_select:objectName() ~= source:objectName()
			and #targets <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, source, self, to_select)
	end,
	on_effect = function(self, effect)
		local from, to, room = effect.from, effect.to, effect.to:getRoom()
		if to:getHandcardNum() < 1 then return end
		local id = room:askForCardChosen(from, to, "h", self:objectName())
		if id >= 0
		then
			room:showCard(to, id)
			local c = sgs.Sanguosha:getCard(id)
			if room:askForCard(to, id, "yj_chenhuodajie0:" .. c:objectName() .. ":" .. from:objectName(), ToData(effect), sgs.Card_MethodNone)
			then
				room:obtainCard(from, c)
			else
				room:damage(sgs.DamageStruct(self, from, to))
			end
		end
		return false
	end,
}
AddPresentCard(yj_chenhuodajie, 0, 12)
AddPresentCard(yj_chenhuodajie, 0, 13)
AddPresentCard(yj_chenhuodajie, 2, 6)

yj_guaguliaodu = sgs.CreateTrickCard {
	name = "yj_guaguliaodu",
	class_name = "YjGuaguliaodu",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	--	damage_card = true,
	available = function(self, player)
		local tos = player:getAliveSiblings()
		tos:append(player)
		for _, to in sgs.list(tos) do
			if CanToCard(self, player, to)
			then
				return self:cardIsAvailable(player)
			end
		end
	end,
	filter = function(self, targets, to_select, source)
		if source:isProhibited(to_select, self) then return end
		return to_select:isWounded()
			and #targets <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, source, self, to_select)
	end,
	on_effect = function(self, effect)
		local from, to, room = effect.from, effect.to, effect.to:getRoom()
		room:recover(to, sgs.RecoverStruct(from, self))
		if hasCard(to, "YjPoison")
		then
			to:addMark("BanPoisonEffect")
			room:askForCard(to, "YjPoison", "yj_guaguliaodu0:yj_poison", ToData(effect))
			to:removeMark("BanPoisonEffect")
		end
		return false
	end,
}
AddPresentCard(yj_guaguliaodu, 0, 1)
AddPresentCard(yj_guaguliaodu, 2, 1)

yj_shushangkaihua = sgs.CreateTrickCard {
	name = "yj_shushangkaihua",
	class_name = "YjShushangkaihua",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = true,
	can_recast = false,
	is_cancelable = true,
	is_gift = true,
	--	damage_card = true,
	available = function(self, player)
		if player:isProhibited(player, self) then return end
		return self:cardIsAvailable(player)
	end,
	about_to_use = function(self, room, use)
		if use.to:isEmpty() then use.to:append(use.from) end
		self:cardOnUse(room, use)
	end,
	on_effect = function(self, effect)
		local from, to, room = effect.from, effect.to, effect.to:getRoom()
		local discard = room:askForDiscard(to, "yj_shushangkaihua", 2, 1, false, true, "yj_shushangkaihua0:")
		if discard and discard:subcardsLength() > 0
		then
			local n = discard:subcardsLength()
			for _, id in sgs.list(discard:getSubcards()) do
				if sgs.Sanguosha:getCard(id):isKindOf("EquipCard")
				then
					n = n + 1
					break
				end
			end
			to:drawCards(n, self:objectName())
		end
		return false
	end,
}
AddPresentCard(yj_shushangkaihua, 3, 3, true)
AddPresentCard(yj_shushangkaihua, 3, 4, true)

yj_tuixinzhifu = sgs.CreateTrickCard {
	name = "yj_tuixinzhifu",
	class_name = "YjTuixinzhifu",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	--	damage_card = true,
	available = function(self, player)
		for _, to in sgs.list(player:getAliveSiblings()) do
			if CanToCard(self, player, to)
			then
				return self:cardIsAvailable(player)
			end
		end
	end,
	filter = function(self, targets, to_select, source)
		if source:isProhibited(to_select, self) then return end
		local range_fix = -sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, source, self, to_select)
		if self:isVirtualCard()
			and self:subcardsLength() > 0
		then
			local oh = source:getOffensiveHorse()
			if oh and self:getSubcards():contains(oh:getId())
			then
				range_fix = range_fix + 1
			end
		end
		return source:distanceTo(to_select, range_fix) == 1 and to_select:getCardCount(true, true) > 0
			and #targets <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, source, self, to_select)
	end,
	on_effect = function(self, effect)
		local from, to, room = effect.from, effect.to, effect.to:getRoom()
		local flags = to:getCards("ej"):length() < 1 and "h" or "hej"
		local dc = dummyCard()
		for i = 1, 2 do
			if from:isAlive()
				and to:getCardCount(true, true) > dc:subcardsLength()
			then
				i = dc:getSubcards()
				local id = room:askForCardChosen(from, to, flags, self:objectName(), false, sgs.Card_MethodNone, i, true)
				if id and id ~= -1
				then
					if i:contains(id)
					then
						for n, f in sgs.list(to:getCards(flags)) do
							n = f:getEffectiveId()
							if i:contains(n) or id == n then
							elseif room:getCardPlace(id) == room:getCardPlace(n)
							then
								dc:addSubcard(n)
								break
							end
						end
					else
						dc:addSubcard(id)
					end
					if flags:match("h")
					then
						local can
						for _, cid in sgs.list(to:handCards()) do
							if dc:getSubcards():contains(cid)
							then else
								can = true
								break
							end
						end
						if not can then flags = "ej" end
					end
				else
					break
				end
			end
		end
		if dc:subcardsLength() > 0
		then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, from:objectName(), to:objectName(),
				"yj_tuixinzhifu", "")
			room:obtainCard(from, dc, reason, false)
			if from:isAlive() and to:isAlive()
			then
				dc = dc:subcardsLength()
				from:setTag("yj_tuixinzhifu", ToData(to))
				dc = room:askForExchange(from, "yj_tuixinzhifu", dc, dc, false,
					"yj_tuixinzhifu0:" .. dc .. ":" .. to:objectName())
				room:giveCard(from, to, dc, "yj_tuixinzhifu")
			end
		end
		return false
	end,
}
AddPresentCard(yj_tuixinzhifu, 3, 9)
AddPresentCard(yj_tuixinzhifu, 3, 10)

yj_nvzhuangTr = sgs.CreateTriggerSkill {
	name = "yj_nvzhuang",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.TargetConfirmed, sgs.DamageForseen },
	can_trigger = function(self, target)
		return target and target:hasArmorEffect("yj_nvzhuang")
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.TargetConfirmed
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
				and use.to:contains(player)
				and player:isMale()
			then
				room:sendCompulsoryTriggerLog(player, "yj_nvzhuang", true)
				room:setEmotion(player, "armor/yj_nvzhuang")
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|black"
				judge.good = false
				judge.negative = true
				judge.reason = self:objectName()
				judge.who = player
				room:judge(judge)
				if judge:isBad()
				then
					room:setCardFlag(use.card, "yj_nvzhuang_debuff")
				end
			end
		elseif event == sgs.DamageForseen
		then
			local damage = data:toDamage()
			if damage.card and damage.card:hasFlag("yj_nvzhuang_debuff")
			then
				Skill_msg(self, player)
				DamageRevises(data, 1, player)
			end
		end
		return false
	end
}
yj_nvzhuang = sgs.CreateArmor {
	name = "yj_nvzhuang",
	class_name = "YjNvzhuang",
	is_gift = true,
	--	target_fixed = false,
	filter = function(self, targets, to_select, source)
		return to_select ~= source
	end,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, yj_nvzhuangTr, false, true, false)
		return false
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "yj_nvzhuang", true, true)
		return false
	end,
}
AddPresentCard(yj_nvzhuang, 2, 9, true)

yj_qixingbaodao = sgs.CreateWeapon {
	name = "yj_qixingbaodao",
	class_name = "YjQixingbaodao",
	range = 2,
	is_gift = true,
	on_install = function(self, player)
		local room = player:getRoom()
		room:sendCompulsoryTriggerLog(player, "yj_qixingbaodao", true)
		room:setEmotion(player, "weapon/yj_qixingbaodao")
		local dc = dummyCard()
		for i, c in sgs.list(player:getCards("ej")) do
			if c:getEffectiveId() ~= self:getEffectiveId()
			then
				dc:addSubcard(c)
			end
		end
		if dc:subcardsLength() > 0
		then
			room:throwCard(dc, player)
		end
	end
}
AddPresentCard(yj_qixingbaodao, 0, 2, true)

yj_xingecard = sgs.CreateSkillCard {
	name = "yj_xingecard",
	will_throw = false,
	filter = function(self, targets, to_select, source)
		return to_select:objectName() ~= source:objectName()
			and #targets < 1
	end,
	on_effect = function(self, effect)
		local source, target, room = effect.from, effect.to, effect.to:getRoom()
		room:giveCard(source, target, self, "yj_xinge")
	end,
}
yj_xingeTr = sgs.CreateViewAsSkill {
	name = "yj_xinge",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards < 1 then return end
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		pattern = yj_xingecard:clone()
		for _, cid in sgs.list(cards) do
			pattern:addSubcard(cid)
		end
		return pattern
	end,
	enabled_at_play = function(self, player)
		return player:usedTimes("#yj_xingecard") < 1
	end,
}
yj_xinge = sgs.CreateTreasure {
	name = "yj_xinge",
	class_name = "YjXinge",
	--	is_gift = true,
	on_install = function(self, player)
		local room = player:getRoom()
		room:attachSkillToPlayer(player, "yj_xinge")
		return false
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "yj_xinge", true, true)
		return false
	end,
}
AddPresentCard(yj_xinge, 2, 4, true)
addToSkills(yj_xingeTr)

yj_yinfengyiTr = sgs.CreateTriggerSkill {
	name = "yj_yinfengyi",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.PreHpLost, sgs.DamageForseen },
	can_trigger = function(self, target)
		return target and target:hasArmorEffect("yj_yinfengyi")
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.PreHpLost
		then
			if player:hasFlag("YjPoison")
			then
				data:setValue(data:toInt() + 1)
				player:setFlags("-YjPoison")
			else
				local lose = data:toHpLost()
				if lose.reason == "yj_poison"
				then
					room:sendCompulsoryTriggerLog(player, "yj_yinfengyi", true)
					room:setEmotion(player, "armor/yj_yinfengyi")
					lose.lose = lose.lose + 1
					data:setValue(lose)
				end
			end
		elseif event == sgs.DamageForseen
		then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("TrickCard")
			then
				room:sendCompulsoryTriggerLog(player, "yj_yinfengyi", true)
				room:setEmotion(player, "armor/yj_yinfengyi")
				return DamageRevises(data, 1, player)
			end
		end
		return false
	end
}
yj_yinfengyi = sgs.CreateArmor {
	name = "yj_yinfengyi",
	class_name = "YjYinfengyi",
	--	is_gift = true,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, yj_yinfengyiTr, false, true, false)
		return false
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "yj_yinfengyi", true, true)
		return false
	end,
}
AddPresentCard(yj_yinfengyi, 1, 3, true)

yj_yitianjianTr = sgs.CreateTriggerSkill {
	name = "yj_yitianjian",
	--	frequency = sgs.Skill_Compulsory,
	events = { sgs.Damage },
	can_trigger = function(self, target)
		return target and target:hasWeapon("yj_yitianjian")
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.Damage
		then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash")
				and player:isWounded() and player:getHandcardNum() > 0
				and room:askForCard(player, ".|.|.|hand", "yj_yitianjian0:", data, "yj_yitianjian")
			then
				room:setEmotion(player, "weapon/yj_yitianjian")
				room:recover(player, sgs.RecoverStruct(player, player:getWeapon()))
			end
		end
		return false
	end
}
yj_yitianjian = sgs.CreateWeapon {
	name = "yj_yitianjian",
	class_name = "YjYitianjian",
	range = 2,
	on_install = function(self, player)
		player:getRoom():acquireSkill(player, yj_yitianjianTr, false, true, false)
	end,
	on_uninstall = function(self, player)
		player:getRoom():detachSkillFromPlayer(player, "yj_yitianjian", true, true)
	end,
}
AddPresentCard(yj_yitianjian, 1, 5)

yj_zheji = sgs.CreateWeapon {
	name = "yj_zheji",
	class_name = "YjZheji",
	range = 0,
	--	is_gift = true,
	on_install = function() end,
	on_uninstall = function() end,
}
AddPresentCard(yj_zheji, 1, 1, true)

function CardIsPresent(id)
	local c = id
	if type(id) == "number" then c = sgs.Sanguosha:getCard(id) else id = id:getEffectiveId() end
	return c:getSkillName() == "" and
		table.contains(sgs.Sanguosha:getEngineCard(id):property("CharTag"):toStringList(), "present_card")
end

yj_zhengyuCard = sgs.CreateSkillCard {
	name = "yj_zhengyuCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select, source)
		for c, id in sgs.list(self:getSubcards()) do
			c = sgs.Sanguosha:getCard(id)
			if c:isKindOf("EquipCard")
			then
				c = c:getRealCard():toEquipCard():location()
				if to_select:hasEquipArea(c)
				then else
					return false
				end
			end
		end
		return #targets < 1
			and source:objectName() ~= to_select:objectName()
	end,
	about_to_use = function(self, room, use)
		room:broadcastSkillInvoke("yj_zhengyu", use.from:isMale(), 1)
		for _, to in sgs.list(use.to) do
			local moves = sgs.CardsMoveList()
			room:doAnimate(1, use.from:objectName(), to:objectName())
			for c, id in sgs.list(self:getSubcards()) do
				local move1 = sgs.CardsMoveStruct()
				move1.card_ids:append(id)
				move1.from = use.from
				move1.to = to
				move1.to_place = sgs.Player_PlaceHand
				move1.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECYCLE, use.from:objectName(),
					to:objectName(), "yj_zhengyu", "")
				Log_message("$PresentCard", use.from, use.to, id, "yj_zhengyu")
				c = sgs.Sanguosha:getCard(id)
				if c:isKindOf("EquipCard")
				then
					move1.to_place = sgs.Player_PlaceEquip
					c = c:getRealCard():toEquipCard()
					c = to:getEquip(c:location())
					if c and not to:getTag("yj_zhanxiang"):toBool()
					then
						local move2 = sgs.CardsMoveStruct()
						move2.from = to
						move2.to = nil
						move2.to_place = sgs.Player_DiscardPile
						move2.card_ids:append(c:getEffectiveId())
						move2.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_MASK_BASIC_REASON, use.from:objectName(),
							to:objectName(), "yj_zhengyu", "")
						moves:append(move2)
					end
				end
				moves:append(move1)
				to:setTag("PresentCard", ToData(tostring(id)))
				to:setTag("PresentFrom", ToData(use.from))
			end
			room:moveCardsAtomic(moves, true)
			to:removeTag("PresentCard")
			to:removeTag("PresentFrom")
		end
	end
}
yj_zhengyu = sgs.CreateViewAsSkill {
	name = "yj_zhengyu&",
	n = 1,
	view_filter = function(self, selected, to_select)
		return CardIsPresent(to_select)
			and not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		local c = yj_zhengyuCard:clone()
		for _, ic in sgs.list(cards) do
			c:addSubcard(ic)
		end
		return #cards > 0 and c
	end,
	enabled_at_play = function(self, player)
		for _, c in sgs.qlist(player:getHandcards()) do
			if CardIsPresent(c) then return true end
		end
	end,
}
addToSkills(yj_zhengyu)

yj_on_trigger = sgs.CreateTriggerSkill {
	name = "yj_on_trigger",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardOffset, sgs.EventPhaseProceeding, sgs.EventPhaseEnd, sgs.CardsMoveOneTime },
	priority = { 4 },
	global = true,
	can_trigger = function(self, target)
		if table.contains(sgs.Sanguosha:getBanPackages(), "yongjian")
		then else
			return target and target:isAlive()
		end
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.CardsMoveOneTime
		then
			local move = data:toMoveOneTime()
			if move.to_place == sgs.Player_PlaceHand
				and player:objectName() == move.to:objectName()
			then
				local ids = {}
				for _, id in sgs.list(move.card_ids) do
					if player:handCards():contains(id)
					then
						if player:getPhase() == sgs.Player_Play
							and CardIsPresent(id) and not player:hasSkill("yj_zhengyu")
						then
							room:attachSkillToPlayer(player, "yj_zhengyu")
						end
						if sgs.Sanguosha:getCard(id):isKindOf("YjPoison")
							and move.reason.m_skillName == "draw_phase"
						then
							table.insert(ids, id)
						end
					end
				end
				while #ids > 0 do
					local c = room:askForUseCard(player, table.concat(ids, ","), "yj_poison0:")
					if c then table.removeOne(ids, c:getEffectiveId()) else break end
				end
			elseif move.from_places:contains(sgs.Player_PlaceHand)
				and player:objectName() == move.from:objectName()
			then
				local function visibleSpecial(id, i)
					if move.to_place == sgs.Player_PlaceSpecial
					then
						for _, p in sgs.list(move.to:getAliveSiblings()) do
							if move.to:pileOpen(move.to:getPileName(id), p:objectName())
							then else
								return
							end
						end
						return true
					elseif move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_DrawPile
					then
						return sgs.Sanguosha:getCard(id):hasFlag("visible")
					else
						return move.open:at(i)
							or move.to_place == sgs.Player_PlaceTable
							or move.to_place == sgs.Player_PlaceDelayedTrick
					end
				end
				for i, id in sgs.list(move.card_ids) do
					if sgs.Sanguosha:getCard(id):isKindOf("YjPoison")
						and move.from_places:at(i) == sgs.Player_PlaceHand
						and player:isAlive() and visibleSpecial(id, i)
						and player:getMark("BanPoisonEffect") < 1
					then
						Skill_msg("yj_poison", player)
						room:loseHp(player, 1, true, nil, "yj_poison")
					end
				end
			end
		elseif event == sgs.EventPhaseProceeding
		then
			if player:getPhase() == sgs.Player_Play
			then
				for _, c in sgs.list(player:getHandcards()) do
					if CardIsPresent(c) and not player:hasSkill("yj_zhengyu")
					then
						room:attachSkillToPlayer(player, "yj_zhengyu")
						break
					end
				end
			end
		elseif event == sgs.CardOffset
		then
			local effect = data:toCardEffect()
			if effect.card and effect.card:objectName() == "yj_stabs_slash"
				and effect.offset_card
				and effect.offset_card:isKindOf("Jink")
				and effect.to:getHandcardNum() > 0
			then
				Skill_msg("yj_stabs_slash", effect.from)
				if room:askForDiscard(effect.to, "yj_stabs_slash", 1, 1, true, false, "yj_stabs_slash0:")
				then else
					return true
				end
			end
		elseif event == sgs.EventPhaseEnd
		then
			if player:hasSkill("yj_zhengyu")
			then
				room:detachSkillFromPlayer(player, "yj_zhengyu", true, true)
			end
		end
		return false
	end
}
addToSkills(yj_on_trigger)
sgs.LoadTranslationTable {
	["yongjian"] = "用间篇",
	["  "] = "  ",
	["yj_poison"] = "毒",
	[":yj_poison"] = "基本牌<br /><b>时机</b>：当【毒】以正面朝上的形式（包含赠予、转化、打出、拼点、弃置等）离开你的手牌区时<br /><b>效果</b>：你失去1点体力。<br /><br /><b>额外效果</b>：当你于摸牌阶段摸取【毒】时，你可以将之交给其他角色（防止【毒】失去体力的效果）。",
	["yj_poison1"] = "毒",
	[":yj_poison1"] = "基本牌<br /><b>时机</b>：当【毒】以正面朝上的形式（包含赠予、转化、打出、拼点、弃置等）离开你的手牌区时<br /><b>效果</b>：你失去1点体力。<br /><br /><b>额外效果</b>：当你于摸牌阶段摸取【毒】时，你可以将之交给其他角色（防止【毒】失去体力的效果）。",
	["yj_poison0"] = "毒：你可以将摸取的【毒】交给其他角色（防止【毒】失去体力的效果）",
	["$yj_poison"] = "%from 发动【%arg】的效果，将 %card 交给了 %to",
	["yj_chenhuodajie"] = "趁火打劫",
	[":yj_chenhuodajie"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名其他角色<br /><b>效果</b>：你展示其一张手牌，然后其选择一项：将此牌交给你；或受到你造成的1点伤害。",
	["yj_chenhuodajie0"] = "趁火打劫：你可以将此【%src】交给 %dest ；或受到 %dest 造成的1点伤害",
	["yj_guaguliaodu"] = "刮骨疗毒",
	[":yj_guaguliaodu"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名已受伤的角色<br /><b>效果</b>：目标回复1点体力，然后其可以弃置一张【毒】（防止【毒】失去体力的效果）。",
	["yj_guaguliaodu0"] = "刮骨疗毒：你可以弃置一张【毒】（防止【毒】失去体力的效果）",
	["yj_shushangkaihua"] = "树上开花",
	[":yj_shushangkaihua"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：你<br /><b>效果</b>：弃置一至两张牌，然后摸等量的牌；若弃置的牌中有装备牌，则多摸一张牌。",
	["yj_shushangkaihua0"] = "树上开花：请选择弃置一至两张牌",
	["yj_stabs_slash"] = "刺杀",
	[":yj_stabs_slash"] = "基本牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：攻击范围内的一名其他角色<br /><b>效果</b>：对目标角色造成1点伤害。<br /><br /><b>额外效果</b>：目标使用【闪】抵消此【刺杀】时，若其有手牌，其需弃置一张手牌，否则此【刺杀】依旧造成伤害。",
	["yj_stabs_slash0"] = "刺杀:请弃置一张手牌，否则此【刺杀】依旧造成伤害",
	["yj_tuixinzhifu"] = "推心置腹",
	[":yj_tuixinzhifu"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：与你距离为1的角色<br /><b>效果</b>：你获得其区域内至多两张牌，然后交给其等量的手牌。",
	["yj_tuixinzhifu0"] = "推心置腹：请选择 %src 张手牌交给 %dest",
	["yj_zhengyu"] = "赠予",
	[":yj_zhengyu"] = "出牌阶段，选择一张可赠予的手牌，将之正面朝上置入一名其他角色的区域；若为装备牌则置入装备区，否则置入手牌区。",
	["yj_zhengyu_fail"] = "赠予失效",
	["present_card"] = "赠予",
	[":present_card"] = "此牌可赠予",
	["yj_numa"] = "驽马",
	[":yj_numa"] = "装备牌·坐骑<br /><b>坐骑技能</b>：锁定技，你计算与其他角色的距离-1；其他角色与你的距离为1。",
	["yj_zhanxiang"] = "战象",
	[":yj_zhanxiang"] = "装备牌·坐骑<br /><b>坐骑技能</b>：锁定技，其他角色与你的距离+1；其他角色对你赠予的牌视为赠予失效（置入弃牌堆）。",
	["$yj_zhanxiang"] = "%to 对 %from %arg ，%card 置入弃牌堆",
	["yj_nvzhuang"] = "女装",
	[":yj_nvzhuang"] = "装备牌·防具<br /><b>防具技能</b>：锁定技，若你为男性角色，当你成为【杀】的目标时，你进行判定，若结果为黑色，此【杀】伤害+1。",
	["yj_qixingbaodao"] = "七星宝刀",
	[":yj_qixingbaodao"] = "装备牌·武器<br /><b>攻击范围</b>：2<br /><b>武器技能</b>：锁定技，当此牌进入你的装备区时，你弃置你判定区与装备区的其他牌。",
	["yj_yinfengyi"] = "引蜂衣",
	[":yj_yinfengyi"] = "装备牌·防具<br /><b>防具技能</b>：锁定技，你受到锦囊牌的伤害+1，【毒】失去的体力值+1。",
	["yj_yitianjian"] = "倚天剑",
	[":yj_yitianjian"] = "装备牌·武器<br /><b>攻击范围</b>：2<br /><b>武器技能</b>：当你的【杀】造成伤害后，你可以弃置一张手牌，然后回复1点体力。",
	["yj_yitianjian0"] = "倚天剑：你可以弃置一张手牌，然后回复1点体力",
	["yj_zheji"] = "折戟",
	[":yj_zheji"] = "装备牌·武器<br /><b>攻击范围</b>：0<br /><b>武器技能</b>：这是一把坏掉的武器·····",
	["$PresentCard"] = "%from 向 %to %arg 了 %card",
	["yj_xinge"] = "信鸽",
	[":yj_xinge"] = "装备牌·宝物<br /><b>宝物技能</b>：出牌阶段限一次，你可以将一张手牌交给一名其他角色。",
	["debuff_card"] = "减益牌", --或奸细牌？
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
}




zhulu = sgs.Package("zhulu", sgs.Package_CardPack)

local c = sgs.Sanguosha:cloneCard("Slash", 0, 8)
c:setParent(zhulu)
local c = sgs.Sanguosha:cloneCard("Slash", 0, 9)
c:setParent(zhulu)
local c = sgs.Sanguosha:cloneCard("Slash", 0, 11)
c:setParent(zhulu)
local c = sgs.Sanguosha:cloneCard("Slash", 1, 11)
c:setParent(zhulu)
local c = sgs.Sanguosha:cloneCard("Slash", 3, 6)
c:setParent(zhulu)
local c = sgs.Sanguosha:cloneCard("Slash", 3, 11)
c:setParent(zhulu)

local c = sgs.Sanguosha:cloneCard("FireSlash", 2, 3)
c:setParent(zhulu)

local c = sgs.Sanguosha:cloneCard("ThunderSlash", 0, 4)
c:setParent(zhulu)
local c = sgs.Sanguosha:cloneCard("ThunderSlash", 1, 4)
c:setParent(zhulu)

local c = sgs.Sanguosha:cloneCard("Jink", 2, 4)
c:setParent(zhulu)
local c = sgs.Sanguosha:cloneCard("Jink", 2, 8)
c:setParent(zhulu)
local c = sgs.Sanguosha:cloneCard("Jink", 3, 4)
c:setParent(zhulu)
local c = sgs.Sanguosha:cloneCard("Jink", 3, 8)
c:setParent(zhulu)

local c = sgs.Sanguosha:cloneCard("Peach", 2, 6)
c:setParent(zhulu)

local c = sgs.Sanguosha:cloneCard("Analeptic", 1, 6)
c:setParent(zhulu)
local c = sgs.Sanguosha:cloneCard("Analeptic", 1, 8)
c:setParent(zhulu)

zl_caochuanjiejian = sgs.CreateTrickCard {
	name = "zl_caochuanjiejian",
	class_name = "ZlCaochuanjiejian",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = true,
	can_recast = false,
	is_cancelable = true,
	available = function(self, player)
		return false
	end,
	on_use = function(self, room, source, targets)
		local ce = source:getTag("ZlCaochuanjiejian"):toCardEffect()
		if ce and ce.from
		then
			if #targets > 0 or table.contains(targets, ce.from)
			then else
				table.insert(targets, ce.from)
			end
			local effect = sgs.CardEffectStruct()
			effect.from = source
			effect.card = self
			local use = room:getTag("cardUseStruct" .. self:toString()):toCardUse()
			source:removeTag("ZlJiejian" .. ce.card:toString())
			for _, to in sgs.list(targets) do
				effect.to = to
				effect.no_offset = table.contains(use.no_offset_list, "_ALL_TARGETS") or
					table.contains(use.no_offset_list, to:objectName())
				effect.no_respond = table.contains(use.no_respond_list, "_ALL_TARGETS") or
					table.contains(use.no_respond_list, to:objectName())
				effect.nullified = table.contains(use.nullified_list, "_ALL_TARGETS") or
					table.contains(use.nullified_list, to:objectName())
				if effect.nullified then
					room:setEmotion(to, "skill_nullify")
				elseif room:isCanceled(effect) then
				else
					room:setEmotion(source, "revive")
					room:setEmotion(source, "blsemotion")
					source:setTag("ZlJiejian" .. ce.card:toString(), ToData(true))
				end
			end
		end
		source:removeTag("ZlCaochuanjiejian")
	end,
}
zl_caochuanjiejian:clone(0, 3):setParent(zhulu)
zl_caochuanjiejian:clone(0, 6):setParent(zhulu)

zl_jiejiaguitian = sgs.CreateTrickCard {
	name = "zl_jiejiaguitian",
	class_name = "ZlJiejiaguitian",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	--	damage_card = true,
	available = function(self, player)
		local tos = player:getAliveSiblings()
		tos:append(player)
		for _, to in sgs.list(tos) do
			if CanToCard(self, player, to)
			then
				return self:cardIsAvailable(player)
			end
		end
	end,
	filter = function(self, targets, to_select, source)
		if source:isProhibited(to_select, self) then return end
		return to_select:hasEquip()
			and #targets <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, source, self, to_select)
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local dc = dummyCard()
		dc:addSubcards(effect.to:getEquips())
		if dc:subcardsLength() > 0
		then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECYCLE, effect.from:objectName(),
				effect.to:objectName(), "zl_jiejiaguitian", "")
			room:obtainCard(effect.to, dc, reason, false)
		end
		return false
	end,
}
zl_jiejiaguitian:clone(1, 3):setParent(zhulu)
zl_jiejiaguitian:clone(3, 3):setParent(zhulu)

zl_zhulutianxia = sgs.CreateTrickCard {
	name = "zl_zhulutianxia",
	class_name = "ZlZhulutianxia",
	can_recast = false,
	target_fixed = true,
	subclass = sgs.LuaTrickCard_TypeGlobalEffect,
	on_use = function(self, room, source, targets)
		local ids = sgs.IntList()
		for _, id in sgs.list(room:getDrawPile()) do
			if ids:length() >= #targets then break end
			if sgs.Sanguosha:getCard(id):isKindOf("EquipCard")
			then
				ids:append(id)
			end
		end
		for _, id in sgs.list(room:getDiscardPile()) do
			if ids:length() >= #targets then break end
			if sgs.Sanguosha:getCard(id):isKindOf("EquipCard")
			then
				ids:append(id)
			end
		end
		room:setTag("ZlZhulutianxiaIds", ToData(ids))
		local effect = sgs.CardEffectStruct()
		effect.from = source
		effect.card = self
		effect.multiple = #targets > 1
		local use = room:getTag("cardUseStruct" .. self:toString()):toCardUse()
		for _, to in sgs.list(targets) do
			local abled_ids, canids = sgs.IntList(), sgs.IntList()
			local toids = room:getTag("ZlZhulutianxiaIds"):toIntList()
			for c, id in sgs.list(ids) do
				c = sgs.Sanguosha:getCard(id)
				c = c:getRealCard():toEquipCard():location()
				if to:hasEquipArea(c) and toids:contains(id)
				then
					canids:append(id)
				else
					abled_ids:append(id)
				end
			end
			effect.to = to
			room:fillAG(ids, nil, abled_ids)
			room:setTag("ZlZhulutianxia", ToData(canids))
			effect.no_offset = table.contains(use.no_offset_list, "_ALL_TARGETS") or
				table.contains(use.no_offset_list, to:objectName())
			effect.no_respond = table.contains(use.no_respond_list, "_ALL_TARGETS") or
				table.contains(use.no_respond_list, to:objectName())
			effect.nullified = table.contains(use.nullified_list, "_ALL_TARGETS") or
				table.contains(use.nullified_list, to:objectName())
			if canids:length() > 0 then room:cardEffect(effect) else room:setEmotion(to, "skill_nullify") end
			room:clearAG()
		end
		ids = room:getTag("ZlZhulutianxiaIds"):toIntList()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, nil, self:objectName(), nil)
		if ids:isEmpty() then return end
		effect = dummyCard()
		effect:addSubcards(ids)
		room:throwCard(effect, reason, nil) --弃牌
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local ids = room:getTag("ZlZhulutianxiaIds"):toIntList()
		local ag_list = room:getTag("ZlZhulutianxia"):toIntList()
		local card_id = room:askForAG(effect.to, ag_list, false, self:objectName(), "zl_zhulutianxiaAG")
		room:takeAG(effect.to, card_id, false)
		ids:removeOne(card_id)
		room:setTag("ZlZhulutianxiaIds", ToData(ids))
		if InstallEquip(card_id, effect.to, self) then return end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, effect.to:objectName(), nil,
			self:objectName(), nil)
		room:throwCard(card_id, reason, nil)
	end,
}
zl_zhulutianxia:clone(1, 9):setParent(zhulu)

local zl_kh = yj_shushangkaihua:clone(2, 9)
zl_kh:setParent(zhulu)
local zl_kh = yj_shushangkaihua:clone(2, 11)
zl_kh:setParent(zhulu)
local zl_kh = yj_shushangkaihua:clone(3, 9)
zl_kh:setParent(zhulu)

zl_wufengjianTr = sgs.CreateTriggerSkill {
	name = "zl_wufengjian",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardUsed },
	can_trigger = function(self, target)
		return target and target:hasWeapon("zl_wufengjian")
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
			then
				room:setEmotion(player, "weapon/zl_wufengjian")
				room:sendCompulsoryTriggerLog(player, "zl_wufengjian", true)
				local w = player:getWeapon()
				w = w and w:objectName() == "zl_wufengjian" and "^" .. w:getEffectiveId() or "."
				if w ~= "." and player:getCardCount() < 2 or player:getCardCount() < 1 then return end
				room:askForDiscard(player, "zl_wufengjian", 1, 1, false, true, "zl_wufengjian0:", w)
			end
		end
		return false
	end
}
zl_wufengjian = sgs.CreateWeapon {
	name = "zl_wufengjian",
	class_name = "ZlWufengjian",
	range = 1,
	on_install = function(self, player)
		player:getRoom():acquireSkill(player, zl_wufengjianTr, false, true, false)
	end,
	on_uninstall = function(self, player)
		player:getRoom():detachSkillFromPlayer(player, "zl_wufengjian", true, true)
	end,
}
local zlwufengjian = zl_wufengjian:clone(0, 5)
--zlwufengjian:setProperty("YingBianEffects",ToData("present_card"))
zlwufengjian:addCharTag("present_card")
zlwufengjian:setGift(true)
zlwufengjian:setParent(zhulu)

zl_yexingyiTr = sgs.CreateTriggerSkill {
	name = "zl_yexingyi",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardEffected },
	can_trigger = function(self, target)
		return target and target:hasArmorEffect("zl_yexingyi")
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.CardEffected
		then
			local effect = data:toCardEffect()
			if effect.card:isKindOf("TrickCard")
				and effect.card:isBlack()
			then
				room:sendCompulsoryTriggerLog(player, "zl_yexingyi", true)
				room:setEmotion(player, "armor/zl_yexingyi")
				effect.nullified = true
				data:setValue(effect)
			end
		end
		return false
	end
}
zl_yexingyi = sgs.CreateArmor {
	name = "zl_yexingyi",
	class_name = "ZlYexingyi",
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, zl_yexingyiTr, false, true, false)
		return false
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "zl_yexingyi", true, true)
		return false
	end,
}
zl_yexingyi:clone(0, 10):setParent(zhulu)

local zlzheji = yj_zheji:clone(1, 5)
--zlzheji:setProperty("YingBianEffects",ToData("present_card"))
zlzheji:addCharTag("present_card")
zlzheji:setGift(true)
zlzheji:setParent(zhulu)

zl_jinheCard = sgs.CreateSkillCard {
	name = "zl_jinheCard",
	will_throw = false,
	target_fixed = true,
	on_use = function(self, room, source, targets)
		if self:subcardsLength() < 1 then self:addSubcards(source:getPile("zl_li")) end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW, source:objectName(), nil, "zl_jinhe", nil)
		room:throwCard(self, reason, nil)
		local dc = dummyCard()
		for s, id in sgs.list(self:getSubcards()) do
			s = sgs.Sanguosha:getCard(id):getSuit()
			for _, h in sgs.list(source:getHandcards()) do
				if dc:getSubcards():contains(h:getEffectiveId()) then continue end
				if s == h:getSuit() then dc:addSubcard(h) end
			end
		end
		local t = source:getTreasure()
		if t and t:isKindOf("ZlJinhe") then dc:addSubcard(t) end
		if dc:subcardsLength() < 1 then return end
		room:throwCard(dc, reason, source)
	end
}
zl_jinheTr = sgs.CreateViewAsSkill {
	name = "zl_jinhe",
	view_as = function(self)
		return zl_jinheCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getPile("zl_li"):length() > 0
	end,
}
zl_jinhe = sgs.CreateTreasure {
	name = "zl_jinhe",
	class_name = "ZlJinhe",
	--target_fixed = false,
	on_install = function(self, player)
		local room = player:getRoom()
		room:attachSkillToPlayer(player, "zl_jinhe")
		local from = player:getTag("PresentFrom"):toPlayer()
		if player:getTag("PresentCard"):toString() == self:toString()
			and from and from:isAlive()
		then
			Skill_msg(self, from)
			room:setEmotion(from, "treasure/zl_jinhe")
			local ids = room:getNCards(2, false)
			room:returnToTopDrawPile(ids)
			room:fillAG(ids, from)
			local id = room:askForAG(from, ids, false, "zl_jinhe", "zl_jinhe0")
			room:clearAG(from)
			ids = sgs.SPlayerList()
			ids:append(from)
			player:addToPile("zl_li", id, false, ids)
			room:setTag("ZlJinheOwner", ToData(from))
		end
	end,
	on_uninstall = function(self, player)
		player:getRoom():detachSkillFromPlayer(player, "zl_jinhe", true, true)
	end,
}
addToSkills(zl_jinheTr)
local zljinhe = zl_jinhe:clone(1, 10)
--zljinhe:setProperty("YingBianEffects",ToData("present_card"))
zljinhe:addCharTag("present_card")
zljinhe:setGift(true)
zljinhe:setParent(zhulu)

--local zl_numa = sgs.Sanguosha:cloneCard("OffensiveHorse",2,5)
zl_numa = sgs.CreateOffensiveHorse {
	name = "zl_numa",
	class_name = "ZlNuma",
	--	correct = -1,
	is_gift = true,
	on_install = function(self, player)
		local room = player:getRoom()
		local dc = dummyCard()
		for _, eid in sgs.list(player:getEquipsId()) do
			if eid ~= self:getEffectiveId()
				and player:canDiscard(player, eid)
			then
				dc:addSubcard(eid)
			end
		end
		room:sendCompulsoryTriggerLog(player, "zl_numa", true)
		room:setEmotion(player, "horse/zl_numa")
		if dc:subcardsLength() > 0
		then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW, player:objectName(), nil, "zl_numa", nil)
			room:throwCard(dc, reason, player)
		end
	end,
	on_uninstall = function(self, player)
	end
}
local zlnuma = zl_numa:clone(2, 5)
--zlnuma:setProperty("YingBianEffects",ToData("present_card"))
zlnuma:addCharTag("present_card")
--zlnuma:setObjectName("zl_numa")
--zlnuma:setGift(true)
zlnuma:setParent(zhulu) --[[
sgs.HorseSkill.zl_numa = {
	on_install = function(self,player,room)
		local dc = dummyCard()
		for _,eid in sgs.list(player:getEquipsId())do
			if eid~=self:getEffectiveId()
			and player:canDiscard(player,eid)
			then dc:addSubcard(eid) end
		end
		room:sendCompulsoryTriggerLog(player,"zl_numa",true)
		room:setEmotion(player,"horse/zl_numa")
		if dc:subcardsLength()>0
		then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW,player:objectName(),nil,"zl_numa",nil)
			room:throwCard(dc,reason,player)
		end
	end
}--]]

zl_nvzhuang = sgs.CreateArmor {
	name = "zl_nvzhuang",
	class_name = "ZlNvzhuang",
	on_install = function(self, player)
		if player:isMale()
		then
			local room = player:getRoom()
			room:setEmotion(player, "armor/zl_nvzhuang")
			room:sendCompulsoryTriggerLog(player, "zl_nvzhuang", true)
			if player:hasEquip(self) and player:getCardCount() < 2 or player:getCardCount() < 1 then return end
			room:askForDiscard(player, "zl_nvzhuang", 1, 1, false, true, "zl_nvzhuang0:", "^" .. self:getEffectiveId())
		end
	end,
	on_uninstall = function(self, player)
		if player:hasArmorEffect("zl_nvzhuang") and player:isMale()
		then
			player:setFlags("zl_nvzhuangBuff")
		end
	end,
}
local zlnvzhuang = zl_nvzhuang:clone(2, 10)
--zlnvzhuang:setProperty("YingBianEffects",ToData("present_card"))
zlnvzhuang:addCharTag("present_card")
zlnvzhuang:setGift(true)
zlnvzhuang:setParent(zhulu)

zl_yajiaoqiangTr = sgs.CreateTriggerSkill {
	name = "zl_yajiaoqiang",
	events = { sgs.CardUsed, sgs.CardResponded, sgs.CardFinished },
	can_trigger = function(self, target)
		return target and target:hasWeapon("zl_yajiaoqiang")
			and target:getPhase() == sgs.Player_NotActive
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:getTypeId() > 0 and use.card:isBlack()
				and player:getMark("zl_yajiaoqiang-Clear") < 1
			then
				player:setTag("ZlYajiaoqiang", ToData(use.card:toString()))
				player:addMark("zl_yajiaoqiang-Clear")
			end
		elseif event == sgs.CardResponded
		then
			local res = data:toCardResponse()
			if res.m_isUse and res.m_card:getTypeId() > 0 and res.m_card:isBlack()
				and player:getMark("zl_yajiaoqiang-Clear") < 1
			then
				player:addMark("zl_yajiaoqiang-Clear")
				if res.m_card:getEffectiveId() >= 0 and not room:getCardOwner(res.m_card:getEffectiveId())
					and player:askForSkillInvoke(self, data, false)
				then
					ToSkillInvoke(self, player, true)
					room:obtainCard(player, res.m_card)
				end
			end
		else
			local use = data:toCardUse()
			if player:getTag("ZlYajiaoqiang"):toString() == use.card:toString()
				and use.card:getEffectiveId() >= 0
			then
				player:removeTag("ZlYajiaoqiang")
				if not room:getCardOwner(use.card:getEffectiveId())
					and player:askForSkillInvoke(self, data, false)
				then
					ToSkillInvoke(self, player, true)
					room:obtainCard(player, use.card)
				end
			end
		end
		return false
	end
}
zl_yajiaoqiang = sgs.CreateWeapon {
	name = "zl_yajiaoqiang",
	class_name = "ZlYajiaoqiang",
	range = 3,
	on_install = function(self, player)
		player:getRoom():acquireSkill(player, zl_yajiaoqiangTr, false, true, false)
	end,
	on_uninstall = function(self, player)
		player:getRoom():detachSkillFromPlayer(player, "zl_yajiaoqiang", true, true)
	end,
}
zl_yajiaoqiang:clone(3, 5):setParent(zhulu)

zl_yinfengjiaTr = sgs.CreateTriggerSkill {
	name = "zl_yinfengjia",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.DamageInflicted },
	can_trigger = function(self, target)
		return target and target:hasArmorEffect("zl_yinfengjia")
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.DamageInflicted
		then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("TrickCard")
			then
				room:sendCompulsoryTriggerLog(player, "zl_yinfengjia", true)
				room:setEmotion(player, "armor/zl_yinfengjia")
				return DamageRevises(data, 1, player)
			end
		end
		return false
	end
}
zl_yinfengjia = sgs.CreateArmor {
	name = "zl_yinfengjia",
	class_name = "ZlYinfengjia",
	on_install = function(self, player)
		player:getRoom():acquireSkill(player, zl_yinfengjiaTr, false, true, false)
	end,
	on_uninstall = function(self, player)
		player:getRoom():detachSkillFromPlayer(player, "zl_yinfengjia", true, true)
	end,
}
local zlyinfengyi = zl_yinfengjia:clone(3, 10)
--zlyinfengyi:setProperty("YingBianEffects",ToData("present_card"))
zlyinfengyi:addCharTag("present_card")
zlyinfengyi:setGift(true)
zlyinfengyi:setParent(zhulu)

zlCardOnTrigger = sgs.CreateTriggerSkill {
	name = "zlCardOnTrigger",
	events = { sgs.CardsMoveOneTime, sgs.CardEffected, sgs.EventPhaseEnd, sgs.EventPhaseProceeding, sgs.CardFinished },
	frequency = sgs.Skill_Compulsory,
	global = true,
	can_trigger = function(self, target)
		if table.contains(sgs.Sanguosha:getBanPackages(), "zhulu")
		then else
			return target and target:isAlive()
		end
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.CardsMoveOneTime
		then
			local move = data:toMoveOneTime()
			if move.to_place == sgs.Player_PlaceHand
				and player:objectName() == move.to:objectName()
				and player:getPhase() == sgs.Player_Play
			then
				for _, id in sgs.list(move.card_ids) do
					if not player:hasSkill("yj_zhengyu")
						and player:handCards():contains(id) and CardIsPresent(id)
					then
						room:attachSkillToPlayer(player, "yj_zhengyu")
					end
				end
			end
			if move.from_places:contains(sgs.Player_PlaceEquip)
				and player:objectName() == move.from:objectName()
			then
				for c, id in sgs.list(move.card_ids) do
					if move.from_places:at(c) ~= sgs.Player_PlaceEquip then continue end
					c = sgs.Sanguosha:getCard(id)
					if c:isKindOf("ZlJinhe")
					then
						if player:getPile("zl_li"):length() > 0
						then
							if move.to_place == sgs.Player_PlaceEquip
							then
								local sp = sgs.SPlayerList()
								sp:append(room:getTag("ZlJinheOwner"):toPlayer())
								BeMan(room, move.to):addToPile("zl_li", player:getPile("zl_li"), false, sp)
							else
								player:clearOnePrivatePile("zl_li")
							end
						end
						if move.to_place == sgs.Player_DiscardPile
							and move.reason.m_skillName ~= "zl_jinhe"
						then
							Skill_msg("zl_jinhe", player)
							player:throwAllHandCards()
						elseif move.to_place == sgs.Player_PlaceTable
						then
							player:setFlags("zl_jinhe" .. id)
						end
					elseif c:isKindOf("ZlNvzhuang")
						and player:hasFlag("zl_nvzhuangBuff")
					then
						player:setFlags("-zl_nvzhuangBuff")
						room:setEmotion(player, "armor/zl_nvzhuang")
						room:sendCompulsoryTriggerLog(player, "zl_nvzhuang", true)
						room:askForDiscard(player, "zl_nvzhuang", 1, 1, false, true, "zl_nvzhuang0:", "^" .. id)
					end
				end
			elseif move.from_places:contains(sgs.Player_PlaceTable)
				and move.reason.m_playerId == player:objectName()
				and move.to_place == sgs.Player_DiscardPile
			then
				for i, id in sgs.list(move.card_ids) do
					if player:hasFlag("zl_jinhe" .. id)
					then
						player:setFlags("-zl_jinhe" .. id)
						Skill_msg("zl_jinhe", player)
						player:throwAllHandCards()
					end
				end
			end
		elseif event == sgs.CardEffected
		then
			local effect = data:toCardEffect()
			if effect.no_offset then return end
			if effect.card:isNDTrick() and effect.card:isDamageCard()
				or effect.card:isKindOf("Slash")
			then
				local can = {}
				local hc = hasCard(effect.to, "ZlCaochuanjiejian", "&h")
				if hc
				then
					for _, c in sgs.list(hc) do
						table.insert(can, c:getEffectiveId())
					end
				end
				for _, skill in sgs.list(effect.to:getSkillList(true, false)) do
					if skill:inherits("ViewAsSkill")
					then
						skill = sgs.Sanguosha:getViewAsSkill(skill:objectName())
						if skill:isEnabledAtResponse(effect.to, "zl_caochuanjiejian")
						then
							table.insert(can, "zl_caochuanjiejian")
						end
					end
				end
				if #can > 0
				then
					effect.to:setTag("ZlCaochuanjiejian", data)
					hc = "zl_caochuanjiejian_use:" .. effect.card:objectName() .. ":" .. effect.from:objectName()
					if room:askForUseCard(effect.to, table.concat(can, ","), hc, -1, sgs.Card_MethodUse, true, effect.from, effect.card)
						and effect.to:getTag("ZlJiejian" .. effect.card:toString()):toBool()
					then
						effect.to:setFlags("Global_NonSkillNullify")
						return true
					end
				end
			end
		elseif event == sgs.CardFinished
		then
			local use = data:toCardUse()
			if use.card:getTypeId() > 0
			then
				for _, to in sgs.list(use.to) do
					if to:getTag("ZlJiejian" .. use.card:toString()):toBool()
					then
						to:removeTag("ZlJiejian" .. use.card:toString())
						if to:isDead() or room:getCardOwner(use.card:getEffectiveId()) then continue end
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, to:objectName(),
							use.from:objectName(), "zl_caochuanjiejian", "")
						room:obtainCard(to, use.card, reason)
					end
				end
			end
		elseif event == sgs.EventPhaseProceeding
		then
			if player:getPhase() == sgs.Player_Play
			then
				for _, c in sgs.list(player:getHandcards()) do
					if CardIsPresent(c) and not player:hasSkill("yj_zhengyu")
					then
						room:attachSkillToPlayer(player, "yj_zhengyu")
						break
					end
				end
			end
		elseif event == sgs.EventPhaseEnd
		then
			if player:hasSkill("yj_zhengyu")
			then
				room:detachSkillFromPlayer(player, "yj_zhengyu", true, true)
			end
		end
		return false
	end,
}
addToSkills(zlCardOnTrigger)
sgs.LoadTranslationTable {
	["zhulu"] = "逐鹿天下",
	["zl_caochuanjiejian"] = "草船借箭",
	[":zl_caochuanjiejian"] = "锦囊牌<br /><b>时机</b>：当【杀】或伤害类锦囊对你生效前<br /><b>目标</b>：此【杀】或伤害类锦囊<br /><b>效果</b>：抵消此【杀】或伤害类锦囊对你的效果，然后此牌结算结束后，你获得之。",
	["zl_caochuanjiejian_use"] = "你可以使用【草船借箭】抵消%dest【%src】对你的效果",
	["zl_jiejiaguitian"] = "解甲归田",
	[":zl_jiejiaguitian"] = "锦囊牌·单目标锦囊<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名装备区有牌的角色<br /><b>效果</b>：目标获得其装备区里所有的牌。",
	["zl_zhulutianxia"] = "逐鹿天下",
	[":zl_zhulutianxia"] = "锦囊牌·全局效果<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：所有存活角色<br /><b>效果</b>：从牌堆中亮出等同目标数的装备牌，各目标依次将其中一张置于其装备区里。",
	["zl_zhulutianxiaAG"] = "逐鹿天下：请选择一张装备牌置入装备区",
	["zl_wufengjian"] = "无锋剑",
	[":zl_wufengjian"] = "装备牌·武器<br /><b>攻击范围</b>：1<br /><b>武器技能</b>：锁定技，你使用【杀】时，你须弃置一张其他牌。",
	["zl_wufengjian0"] = "无锋剑：请选择一张其他牌弃置",
	["zl_yexingyi"] = "夜行衣",
	[":zl_yexingyi"] = "锁定技，黑色锦囊牌对你无效。",
	["zl_jinhe"] = "锦盒",
	[":zl_jinhe"] = "装备牌·宝物<br /><b>宝物技能</b>：出牌阶段，你可以移去“礼”，然后弃置【锦盒】和与“礼”相同花色的手牌；当【锦盒】不以此法进入弃牌堆时，你弃置所有手牌。<br /><b>额外效果</b>：当【锦盒】被赠予时，来源观看牌堆顶2张牌，并将其中一张牌当做“礼”扣置于【锦盒】下。",
	["zl_jinhe0"] = "锦盒：请选择将一张牌当做“礼”扣置于【锦盒】下",
	["zl_li"] = "礼",
	["zl_nvzhuang"] = "女装",
	[":zl_nvzhuang"] = "装备牌·防具<br /><b>防具技能</b>：锁定技，当你装备或卸载【女装】时，若你为男性，你须弃置一张其他牌。",
	["zl_nvzhuang0"] = "女装：请选择一张其他牌弃置",
	["zl_yajiaoqiang"] = "涯角枪",
	[":zl_yajiaoqiang"] = "装备牌·武器<br /><b>攻击范围</b>：3<br /><b>武器技能</b>：当你于回合外使用黑色牌时，若之为你本回合第一次使用的黑色牌，则结算后你可以获得之。",
	["zl_yinfengjia"] = "引蜂甲",
	[":zl_yinfengjia"] = "装备牌·防具<br /><b>防具技能</b>：锁定技，你受到锦囊牌的伤害时，此伤害+1。",
	["zl_numa"] = "驽马",
	[":zl_numa"] = "装备牌·坐骑<br /><b>坐骑技能</b>：锁定技，你计算与其他角色的距离-1。<br /><b>额外效果</b>：锁定技，当【驽马】进入你的装备区后，你弃置装备区里的其他牌。",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
}





Zhongdan = sgs.Package("zhongdanyingjie")

cuiyan = sgs.General(Zhongdan, "cuiyan", "wei", 3)
zd_xunzhi = sgs.CreatePhaseChangeSkill {
	name = "zd_xunzhi",
	on_phasechange = function(self, player)
		local room = player:getRoom()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if player:getPhase() == sgs.Player_Start
				and p:getNextAlive() == player and p:getHp() ~= player:getHp()
				and player:getNextAlive():getHp() ~= player:getHp()
				and room:askForSkillInvoke(player, self:objectName())
			then
				room:broadcastSkillInvoke(self:objectName())
				room:loseHp(player)
				room:addMaxCards(player, 2, false)
				break
			end
		end
	end
}
cuiyan:addSkill(zd_xunzhi)
zd_yawang = sgs.CreateTriggerSkill {
	name = "zd_yawang",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.EventPhaseStart, sgs.CardUsed, sgs.CardResponded, sgs.EventPhaseEnd },
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Draw then
				local x = 0
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getHp() == player:getHp() then
						x = x + 1
					end
				end
				room:broadcastSkillInvoke(self:objectName())
				room:sendCompulsoryTriggerLog(player, self:objectName())
				player:drawCards(x, self:objectName())
				room:setPlayerMark(player, "zd_yawang-Clear", x)
				return true
			elseif player:getPhase() == sgs.Player_Play and player:getMark("zd_yawang_stop-Clear") > 0 then
				room:setPlayerCardLimitation(player, "use", ".", false)
			end
		elseif player:getPhase() == sgs.Player_Play and (event == sgs.CardUsed or event == sgs.CardResponded) then
			local card
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse and player:getMark("zd_yawang-Clear") > 0 then
				room:removePlayerMark(player, "zd_yawang-Clear")
				if player:getMark("zd_yawang-Clear") == 0 then
					room:setPlayerCardLimitation(player, "use", ".", false)
					room:addPlayerMark(player, "zd_yawang_stop-Clear")
				end
			end
		elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Play then
			room:removePlayerCardLimitation(player, "use", ".")
		end
	end
}
cuiyan:addSkill(zd_yawang)

huangfusong = sgs.General(Zhongdan, "huangfusong", "qun")
zd_fenyueCard = sgs.CreateSkillCard {
	name = "zd_fenyueCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		return #targets < 1 and sgs.Self:canPindian(to_select)
	end,
	on_use = function(self, room, source, targets)
		if source:pindian(targets[1], "zd_fenyue", self) then
			room:broadcastSkillInvoke("zd_fenyue", 2)
			local choices = "zd_fenyue1"
			if source:canSlash(targets[1], nil, false) then
				choices = "zd_fenyue1+zd_fenyue2"
			end
			if room:askForChoice(source, "zd_fenyue", choices, ToData(targets[1])) == "zd_fenyue2" then
				local slash = sgs.Sanguosha:cloneCard("slash")
				slash:setSkillName("_zd_fenyue")
				room:useCard(sgs.CardUseStruct(slash, source, targets[1]))
			else
				room:addPlayerMark(targets[1], "ban_ur")
				room:setPlayerCardLimitation(targets[1], "use,response", ".|.|.|hand", false)
			end
		else
			room:broadcastSkillInvoke("zd_fenyue", 1)
			room:setPlayerFlag(source, "Global_PlayPhaseTerminated")
		end
	end
}
zd_fenyue = sgs.CreateOneCardViewAsSkill {
	name = "zd_fenyue",
	filter_pattern = ".|.|.|hand",
	view_as = function(self, card)
		local skillcard = zd_fenyueCard:clone()
		skillcard:addSubcard(card:getId())
		skillcard:setSkillName(self:objectName())
		return skillcard
	end,
	enabled_at_play = function(self, player)
		local tos = player:getAliveSiblings()
		tos:append(player)
		local n = 0
		for _, p in sgs.list(tos) do
			if p:getRole() == "loyalist"
			then
				n = n + 1
			end
		end
		return player:usedTimes("#zd_fenyueCard") < n
	end
}
huangfusong:addSkill(zd_fenyue)

ZhongdanCard = sgs.Package("ZhongdanCard", sgs.Package_CardPack)

zd_shengdongjixi = sgs.CreateTrickCard {
	name = "zd_shengdongjixi",
	class_name = "ZdShengdongjixi",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	--	damage_card = true,
	available = function(self, player)
		local tos = player:getAliveSiblings()
		tos:append(player)
		for _, to in sgs.list(tos) do
			if CanToCard(self, player, to)
			then
				return self:cardIsAvailable(player)
			end
		end
	end,
	filter = function(self, targets, to_select, source)
		if source:isProhibited(to_select, self) then return end
		if #targets >= (1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, source, self, to_select)) * 2
		then
			return false
		elseif #targets % 2 == 0
		then
			local range_fix = -sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, source, self, to_select)
			if self:isVirtualCard()
				and self:subcardsLength() > 0
			then
				local oh = source:getOffensiveHorse()
				if oh and self:getSubcards():contains(oh:getId())
				then
					range_fix = range_fix + 1
				end
			end
			return source:distanceTo(to_select, range_fix) == 1
		else
			return targets[#targets]:objectName() ~= to_select:objectName()
		end
	end,
	feasible = function(self, targets)
		return #targets % 2 == 0 and #targets > 0
	end,
	about_to_use = function(self, room, use)
		local tos = sgs.SPlayerList()
		local _to
		for i, to in sgs.list(use.to) do
			if (i + 1) % 2 ~= 0
			then
				tos:append(to)
				_to = to
			else
				_to:setTag("ZdShengdongTo", ToData(to))
			end
		end
		use.to = tos
		self:cardOnUse(room, use)
	end,
	on_use = function(self, room, source, targets)
		for _, to in sgs.list(targets) do
			local target = to:getTag("ZdShengdongTo"):toPlayer()
			room:doAnimate(1, to:objectName(), target:objectName())
			local log = sgs.LogMessage()
			log.type = "$ZdShengdongTo"
			log.from = source
			log.to:append(to)
			log.arg = target:getGeneralName()
			room:sendLog(log)
		end
		local use = room:getTag("cardUseStruct" .. self:toString()):toCardUse()
		local effect = sgs.CardEffectStruct()
		effect.from = source
		effect.card = self
		effect.multiple = #targets > 1
		for _, to in sgs.list(targets) do
			effect.to = to
			effect.no_offset = table.contains(use.no_offset_list, "_ALL_TARGETS") or
				table.contains(use.no_offset_list, to:objectName())
			effect.no_respond = table.contains(use.no_respond_list, "_ALL_TARGETS") or
				table.contains(use.no_respond_list, to:objectName())
			effect.nullified = table.contains(use.nullified_list, "_ALL_TARGETS") or
				table.contains(use.nullified_list, to:objectName())
			room:cardEffect(effect)
		end
	end,
	on_effect = function(self, effect)
		if effect.to:isDead() or effect.from:isDead()
			or effect.from:getHandcardNum() < 1 then
			return
		end
		local room = effect.to:getRoom()
		local dc = room:askForExchange(effect.from, "zd_shengdongjixi", 1, 1, false,
			"zd_shengdongjixi0:" .. effect.to:objectName())
		room:giveCard(effect.from, effect.to, dc, "zd_shengdongjixi")
		local target = effect.to:getTag("ZdShengdongTo"):toPlayer()
		if target:isAlive()
		then
			local dc = room:askForExchange(effect.to, "zd_shengdongjixi", 2, 2, true,
				"zd_shengdongjixi1:" .. target:objectName())
			room:giveCard(effect.to, target, dc, "zd_shengdongjixi")
		end
		return false
	end,
}
zd_shengdongjixi:clone(0, 3):setParent(ZhongdanCard)
zd_shengdongjixi:clone(0, 4):setParent(ZhongdanCard)
zd_shengdongjixi:clone(0, 11):setParent(ZhongdanCard)
zd_shengdongjixi:clone(3, 3):setParent(ZhongdanCard)
zd_shengdongjixi:clone(0, 4):setParent(ZhongdanCard)

zd_caomujiebing = sgs.CreateTrickCard {        --锦囊牌
	name = "zd_caomujiebing",
	class_name = "ZdCaomujiebing",             --卡牌的类名
	subtype = "delayed_trick",                 --卡牌的子类型
	subclass = sgs.LuaTrickCard_TypeDelayedTrick, --卡牌的类型 延时锦囊
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	movable = false,
	available = function(self, player)
		for _, to in sgs.list(player:getAliveSiblings()) do
			if CanToCard(self, player, to)
			then
				return self:cardIsAvailable(player)
			end
		end
	end,
	filter = function(self, targets, to_select, player)
		if player:isProhibited(to_select, self) then return end
		return not to_select:containsTrick("zd_caomujiebing")
			and to_select:objectName() ~= player:objectName()
			and #targets < 1
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local log = sgs.LogMessage()
		log.type = "#DelayedTrick"
		log.arg = self:objectName()
		log.from = effect.to
		room:sendLog(log)
		local judge = sgs.JudgeStruct()
		judge.pattern = ".|club"
		judge.good = true
		judge.negative = true
		judge.reason = self:objectName()
		judge.who = effect.to
		room:judge(judge)
		if judge:isBad() then effect.to:addMark("ZdCaomuDebf-Clear") end
		log = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, effect.to:objectName())
		room:throwCard(self, log, nil) --弃牌
		return false
	end,
}
zd_caomujiebing:clone(0, 10):setParent(ZhongdanCard)
zd_caomujiebing:clone(1, 4):setParent(ZhongdanCard)


ZdZengbingCard = sgs.CreateSkillCard {
	name = "ZdZengbingCard",
	skill_name = "zd_zengbingjianzao",
	handling_method = sgs.Card_MethodDiscard,
	will_throw = false,
	target_fixed = true,
	about_to_use = function(self, room, use)
		room:throwCard(self, use.from)
	end
}
ZdZengbing = sgs.CreateViewAsSkill {
	name = "ZdZengbing",
	n = 2,
	view_filter = function(self, selected, to_select)
		if sgs.Self:isJilei(to_select) then return end
		return true
	end,
	view_as = function(self, cards)
		local c = ZdZengbingCard:clone()
		local can = #cards > 1
		for _, ic in sgs.list(cards) do
			c:addSubcard(ic)
			can = can or ic:getTypeId() ~= 1
		end
		return can and c
	end,
	enabled_at_response = function(self, player, pattern)
		if string.find(pattern, "@@ZdZengbing")
		then
			return true
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
}
addToSkills(ZdZengbing)
zd_zengbingjianzao = sgs.CreateTrickCard {
	name = "zd_zengbingjianzao",
	class_name = "Zdzengbingjianzao",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	--	damage_card = true,
	available = function(self, player)
		local tos = player:getAliveSiblings()
		tos:append(player)
		for _, to in sgs.list(tos) do
			if CanToCard(self, player, to)
			then
				return self:cardIsAvailable(player)
			end
		end
	end,
	filter = function(self, targets, to_select, source)
		if source:isProhibited(to_select, self) then return end
		return #targets <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, source, self, to_select)
	end,
	on_effect = function(self, effect)
		if effect.to:isDead() then return end
		local room = effect.to:getRoom()
		effect.to:drawCards(3, "zd_zengbingjianzao")
		if room:askForUseCard(effect.to, "@@ZdZengbing!", "ZdZengbing0:", -1, sgs.Card_MethodDiscard)
		then else
			room:askForDiscard(effect.to, "zd_zengbingjianzao", 2, 2, false, true)
		end
		return false
	end,
}
zd_zengbingjianzao:clone(2, 3):setParent(ZhongdanCard)
zd_zengbingjianzao:clone(2, 4):setParent(ZhongdanCard)
zd_zengbingjianzao:clone(2, 7):setParent(ZhongdanCard)
zd_zengbingjianzao:clone(2, 8):setParent(ZhongdanCard)
zd_zengbingjianzao:clone(2, 9):setParent(ZhongdanCard)
zd_zengbingjianzao:clone(2, 11):setParent(ZhongdanCard)

zd_qijiayebing = sgs.CreateTrickCard {
	name = "zd_qijiayebing",
	class_name = "ZdQijiayebing",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	--	damage_card = true,
	available = function(self, player)
		local tos = player:getAliveSiblings()
		for _, to in sgs.list(tos) do
			if CanToCard(self, player, to)
			then
				return self:cardIsAvailable(player)
			end
		end
	end,
	filter = function(self, targets, to_select, source)
		if source:isProhibited(to_select, self) then return end
		return #targets <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, source, self, to_select)
			and to_select:hasEquip() and to_select:objectName() ~= source:objectName()
	end,
	on_effect = function(self, effect)
		if effect.to:isDead() then return end
		local room = effect.to:getRoom()
		local choices = {}
		if hasCard(effect.to, "Weapon,OffensiveHorse")
		then
			table.insert(choices, "ZdQijia1")
		end
		if hasCard(effect.to, "Armor,DefensiveHorse")
		then
			table.insert(choices, "ZdQijia2")
		end
		if #choices < 1 then return end
		if room:askForChoice(effect.to, "zd_qijiayebing", table.concat(choices, "+")) == "ZdQijia1"
		then
			choices = dummyCard()
			choices:addSubcards(hasCard(effect.to, "Weapon,OffensiveHorse"))
			room:throwCard(choices, effect.to)
		else
			choices = dummyCard()
			choices:addSubcards(hasCard(effect.to, "Armor,DefensiveHorse"))
			room:throwCard(choices, effect.to)
		end
		return false
	end,
}
zd_qijiayebing:clone(1, 12):setParent(ZhongdanCard)
zd_qijiayebing:clone(1, 13):setParent(ZhongdanCard)

zd_jinchantuoqiao = sgs.CreateTrickCard {
	name = "zd_jinchantuoqiao",
	class_name = "ZdJinchantuoqiao",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = true,
	can_recast = false,
	is_cancelable = true,
	--	damage_card = true,
	available = function(self, player)
		return false
	end,
	on_use = function(self, room, source, targets)
		local use = source:getTag("ZdJinchan"):toCardUse()
		local effect = sgs.CardEffectStruct()
		effect.from = source
		effect.card = self
		effect.to = use.from
		if room:isCanceled(effect) then return end
		source:drawCards(2, "zd_jinchantuoqiao")
		source:addMark("ZdJinchan-Clear")
	end
}
zd_jinchantuoqiao:clone(0, 11):setParent(ZhongdanCard)
zd_jinchantuoqiao:clone(0, 13):setParent(ZhongdanCard)
zd_jinchantuoqiao:clone(1, 12):setParent(ZhongdanCard)
zd_jinchantuoqiao:clone(1, 13):setParent(ZhongdanCard)
zd_jinchantuoqiao:clone(2, 1):setParent(ZhongdanCard)
zd_jinchantuoqiao:clone(2, 13):setParent(ZhongdanCard)
zd_jinchantuoqiao:clone(3, 12):setParent(ZhongdanCard)

zd_fulei = sgs.CreateTrickCard {               --锦囊牌
	name = "zd_fulei",
	class_name = "ZdFulei",                    --卡牌的类名
	subtype = "delayed_trick",                 --卡牌的子类型
	subclass = sgs.LuaTrickCard_TypeDelayedTrick, --卡牌的类型 延时锦囊
	target_fixed = true,
	can_recast = false,
	is_cancelable = true,
	movable = true,
	damage_card = true,
	available = function(self, player)
		if player:isProhibited(player, self)
			or player:containsTrick("zd_fulei") then
		else
			return self:cardIsAvailable(player)
		end
	end,
	about_to_use = function(self, room, use)
		if use.to:isEmpty() then use.to:append(use.from) end
		room:removeTag("ZdFulei" .. self:toString())
		self:cardOnUse(room, use)
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local log = sgs.LogMessage()
		log.type = "#DelayedTrick"
		log.arg = self:objectName()
		log.from = effect.to
		room:sendLog(log)
		local judge = sgs.JudgeStruct()
		judge.pattern = ".|spade"
		judge.good = false
		judge.negative = true
		judge.reason = self:objectName()
		judge.who = effect.to
		room:judge(judge)
		if judge:isBad()
		then
			log = room:getTag("ZdFulei" .. self:toString()):toInt()
			log = log + 1
			room:damage(sgs.DamageStruct(self, nil, effect.to, log, sgs.DamageStruct_Thunder))
			room:setTag("ZdFulei" .. self:toString(), ToData(log))
		end
		if effect.to:isAlive() then
			self.on_nullified(self, effect.to)
		else
			room:removeTag("ZdFulei" .. self:toString())
		end
		return false
	end,
}
zd_fulei:clone(0, 1):setParent(ZhongdanCard)
zd_fulei:clone(2, 12):setParent(ZhongdanCard)

zd_lanyinjiaTrVS = sgs.CreateViewAsSkill {
	name = "zd_lanyinjia",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards < 1 then return end
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		pattern = sgs.Sanguosha:cloneCard("jink")
		pattern:setSkillName("zd_lanyinjia")
		for _, cid in sgs.list(cards) do
			pattern:addSubcard(cid)
		end
		return pattern
	end,
	enabled_at_response = function(self, player, pattern)
		return string.find(pattern, "jink")
			and player:getHandcardNum() + player:getHandPile():length() > 0
	end,
	enabled_at_play = function(self, player)
		return false
	end,
}
zd_lanyinjiaTr = sgs.CreateTriggerSkill {
	name = "zd_lanyinjia",
	--frequency = sgs.Skill_Compulsory,
	view_as_skill = zd_lanyinjiaTrVS,
	events = { sgs.DamageInflicted },
	on_trigger = function(self, event, player, data, room)
		if event == sgs.DamageCaused
		then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash")
			then
				Skill_msg(self, player)
				--room:sendCompulsoryTriggerLog(player,"zd_lanyinjia")
				room:setEmotion(player, "armor/zd_lanyinjia")
				if player:getArmor() then room:throwCard(player, player:getArmor()) end
			end
		end
	end
}
zd_lanyinjia = sgs.CreateArmor {
	name = "zd_lanyinjia",
	class_name = "ZdLanyinjia",
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, zd_lanyinjiaTr, true, true, false)
		return false
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "zd_lanyinjia", true, true)
		return false
	end,
}
zd_lanyinjia:clone(0, 2):setParent(ZhongdanCard)
zd_lanyinjia:clone(1, 2):setParent(ZhongdanCard)
addToSkills(zd_lanyinjiaTrVS)

zd_qibaodaoTr = sgs.CreateTriggerSkill {
	name = "zd_qibaodao",
	frequency = sgs.Skill_Compulsory,
	view_as_skill = zd_qibaodaoTrVS,
	events = { sgs.TargetConfirmed, sgs.ConfirmDamage },
	can_trigger = function(self, target)
		return target and target:hasWeapon("zd_qibaodao")
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.TargetConfirmed
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
				and use.from == player
			then
				local can = true
				for _, to in sgs.list(use.to) do
					if can and to:hasArmorEffect(nil)
					then
						can = false
						room:sendCompulsoryTriggerLog(player, "zd_qibaodao")
						room:setEmotion(player, "weapon/zd_qibaodao")
					end
					to:addQinggangTag(use.card)
				end
			end
		elseif event == sgs.ConfirmDamage
		then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash")
				and damage.to:getLostHp() < 1
			then
				room:sendCompulsoryTriggerLog(player, "zd_qibaodao")
				room:setEmotion(player, "weapon/zd_qibaodao")
				DamageRevises(data, 1, player)
			end
		end
	end
}
zd_qibaodao = sgs.CreateWeapon {
	name = "zd_qibaodao",
	class_name = "ZdQibaodao",
	range = 2,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, zd_qibaodaoTr, false, true, false)
		return false
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "zd_qibaodao", true, true)
		return false
	end,
}
zd_qibaodao:clone(0, 6):setParent(ZhongdanCard)

zd_zhungangshuoTr = sgs.CreateTriggerSkill {
	name = "zd_zhungangshuo",
	view_as_skill = zd_qibaodaoTrVS,
	events = { sgs.TargetConfirmed, sgs.ConfirmDamage },
	can_trigger = function(self, target)
		return target and target:hasWeapon("zd_zhungangshuo")
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.TargetConfirmed
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
				and use.from == player
			then
				for _, to in sgs.list(use.to) do
					if player:getHandcardNum() > 0
						and ToSkillInvoke(self, player, to)
					then
						room:setEmotion(player, "weapon/zd_zhungangshuo")
						local id = room:askForCardChosen(to, player, "h", "zd_zhungangshuo")
						room:throwCard(id, player, to)
						if to:getHandcardNum() > 0
						then
							id = room:askForCardChosen(player, to, "h", "zd_zhungangshuo")
							room:throwCard(id, to, player)
						end
					end
				end
			end
		end
	end
}
zd_zhungangshuo = sgs.CreateWeapon {
	name = "zd_zhungangshuo",
	class_name = "ZdZhunangshuo",
	range = 3,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, zd_zhungangshuoTr, false, true, false)
		return false
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "zd_zhungangshuo", true, true)
		return false
	end,
}
zd_zhungangshuo:clone(0, 5):setParent(ZhongdanCard)




zd_dongcha = sgs.CreateTriggerSkill {
	name = "zd_dongcha",
	events = { sgs.GameStart, sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data, room)
		if event == sgs.GameStart
		then
			local rebel = {}
			for _, p in sgs.list(room:getAlivePlayers()) do
				if p:getRole() ~= "rebel" then continue end
				table.insert(rebel, p)
			end
			if #rebel < 1 then return end
			Skill_msg(self, player)
			rebel = rebel[math.random(1, #rebel)]
			room:notifyProperty(player, rebel, "role")
		elseif player:getPhase() == sgs.Player_Start
			and event == sgs.EventPhaseStart
		then
			local tos = sgs.SPlayerList()
			for _, p in sgs.list(room:getAlivePlayers()) do
				if p:getCards("ej"):isEmpty() then continue end
				tos:append(p)
			end
			if tos:isEmpty() then return end
			local to = room:askForPlayerChosen(player, tos, self:objectName(), "zd_dongcha0:", true, true)
			if to
			then
				local card_id = room:askForCardChosen(player, to, "ej", self:objectName())
				room:throwCard(card_id, to, player)
			end
		end
	end
}
zd_sheshen = sgs.CreateTriggerSkill {
	name = "zd_sheshen",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.AskForPeachesDone },
	can_trigger = function(self, target)
		local lord = sgs.Sanguosha:currentRoom():getTag("ZhongdanLord"):toPlayer()
		return target:objectName() == lord:objectName() and target:getHp() < 1
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.AskForPeachesDone then
			for _, owner in sgs.list(room:findPlayersBySkillName(self:objectName())) do
				if player:getHp() > 0 then break end
				room:sendCompulsoryTriggerLog(owner, self:objectName())
				room:gainMaxHp(player)
				room:recover(player, sgs.RecoverStruct(owner, nil, owner:getHp()))
				local d = dummyCard()
				d:addSubcards(owner:handCards())
				d:addSubcards(owner:getEquipsId())
				room:obtainCard(player, d, false)
				room:killPlayer(owner)
			end
		end
	end
}
addToSkills(zd_dongcha)
addToSkills(zd_sheshen)

--[[
zhongdanScenario = sgs.CreateScenario{--创建剧情模式
	name = "zhongdanyingjie",--剧情名称
	expose = false,--身份是否可见
	roles = {--身份数（-1代表不指定武将，默认为素将，可以将-1改为特定武将名，例如樊城之战["lord"] = "guanyu"）
		["lord"] = -1,
		["loyalist1"] = -1,
		["loyalist2"] = -1,
		["rebel1"] = -1,
		["rebel2"] = -1,
		["rebel3"] = -1,
		["rebel4"] = -1,
		["renegade"] = -1,
	}
}
zhongdanScenarioRule = sgs.CreateScenarioRule{--创建剧情规则（就是创建一个特殊的全局触发技，但这个全局触发技只有进入剧情才启用）
	events = {sgs.GameReady},--触发时机
	global = true,--全局触发
	scenario = zhongdanScenario,--设定触发技的剧情模式
	on_trigger = function(self,event,player,data,room)--触发函数
		if event==sgs.GameReady
        then
			if room:getTag("zhongdanyingjie"):toBool() then return end
			local lord = room:getLord()
			if not lord then return end
			local loyalist = {}
			local ops = room:getOtherPlayers(lord)
           	for _,p in sgs.list(ops)do
				if p:getRole()~="loyalist" then continue end
				table.insert(loyalist,p)
			end
			loyalist = loyalist[math.random(1,#loyalist)]
			room:setTag("zhongdanyingjie",ToData(true))
			local log = sgs.LogMessage()
			log.type = "$jl_bingfen"
			log.from = room:getOwner()
			log.arg = "zhongdanyingjie"
			room:sendLog(log)
			room:broadcastProperty(lord,"role","loyalist")
			room:setPlayerProperty(lord,"ZhongdanLoyalist",ToData(true))
			room:setTag("ZhongdanLoyalist",ToData(lord))
			room:notifyProperty(loyalist,loyalist,"role","lord")
			room:setTag("ZhongdanLord",ToData(loyalist))
			
			local rgs = {}
			local total = sgs.GetConfig("MaxChoice",5)
			local lords = sgs.Sanguosha:getRandomGenerals(total*(ops:length()+1))
			for i=1,total do
				table.insert(rgs,lords[i])
			end
			if not table.contains(rgs,"cuiyan") then table.insert(rgs,"cuiyan") end
			if not table.contains(rgs,"huangfusong") then table.insert(rgs,"huangfusong") end
			local lg = room:askForGeneral(lord,table.concat(rgs,"+"))
			table.removeOne(lords,lg)
			lord:setGeneralName(lg)
			room:changeHero(lord,lg,true,true,false,false)
			for _,s in sgs.list(lord:getSkillList())do
				if s:isLordSkill()
				then
					lord:loseSkill(s:objectName())
				end
			end
			if lord:isMale() and lord:getHp()<=4
			then room:acquireSkill(lord,zd_dongcha)
			else room:acquireSkill(lord,zd_sheshen) end
			local heros = {}
           	for _,p in sgs.list(ops)do
				rgs = {}
				for i=1,total do
					table.insert(rgs,lords[1])
					table.remove(lords,1)
				end
				heros[p:objectName()] = room:askForGeneral(p,table.concat(rgs,"+"))
			end
           	for _,p in sgs.list(ops)do
				room:changeHero(p,heros[p:objectName()],true,true,false,false)
			end
			local dc = dummyCard()
			for c,id in sgs.list(room:getDrawPile())do
				c = sgs.Sanguosha:getEngineCard(id)
				log = c:getPackage()
				if log~="maneuvering"
				and log~="standard_cards"
				and log~="limitation_broken"
				then continue end
				if c:isKindOf("Iightning")
				or c:isKindOf("AmazingGrace")
				or c:isKindOf("Snatch")
				or c:isKindOf("Collateral")
				or c:isKindOf("ExNihilo")
				or c:isKindOf("Nullification")
				or c:isKindOf("SupplyShortage")
				or c:isKindOf("Blade")
				or c:isKindOf("EightDiagram")
				or c:isKindOf("QinggangSword")
				then dc:addSubcard(id) end
			end
			log = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER,"","","ToTable","zhongdanyingjie")
			room:moveCardTo(dc,nil,sgs.Player_PlaceTable,log)
		end
		return false
	end,
}
zhongdanScenario:setRule(zhongdanScenarioRule)
sgs.Sanguosha:addScenario(zhongdanScenario)
--]]
local BanZhongdan
ZhongdanOnTrigger = sgs.CreateTriggerSkill {
	name = "ZhongdanOnTrigger",
	events = { sgs.BuryVictim, sgs.GameOverJudge, sgs.BeforeGameOverJudge, sgs.DrawNCards, sgs.EventPhaseEnd,
		sgs.TargetConfirming, sgs.CardsMoveOneTime },
	frequency = sgs.Skill_Compulsory,
	global = true,
	can_trigger = function(self, target)
		if BanZhongdan == false then return true elseif BanZhongdan then return end
		BanZhongdan = table.contains(sgs.Sanguosha:getBanPackages(), "ZhongdanCard")
		return not BanZhongdan
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.GameReady
		then
			if table.contains(sgs.Sanguosha:getBanPackages(), "zhongdanyingjie")
				or room:getTag("zhongdanyingjie"):toBool()
				or room:getMode() ~= "08p" then
				return
			end
			local lord = room:getLord()
			local loyalist = {}
			for _, p in sgs.list(room:getAlivePlayers()) do
				if p:getRole() ~= "loyalist" then continue end
				table.insert(loyalist, p)
			end
			if #loyalist < 1 or not lord then return end
			loyalist = loyalist[math.random(1, #loyalist)]
			room:setTag("zhongdanyingjie", ToData(true))
			local log = sgs.LogMessage()
			log.type = "$jl_bingfen"
			log.from = room:getOwner()
			log.arg = "zhongdanyingjie"
			room:sendLog(log)
			room:broadcastProperty(lord, "role", "loyalist")
			room:setPlayerProperty(lord, "ZhongdanLoyalist", ToData(true))
			room:setTag("ZhongdanLoyalist", ToData(lord))
			room:notifyProperty(loyalist, loyalist, "role", "lord")
			room:setTag("ZhongdanLord", ToData(loyalist))
			for _, s in sgs.list(lord:getSkillList()) do
				if s:isLordSkill()
				then
					lord:loseSkill(s:objectName())
				end
			end
			if lord:isMale() and lord:getHp() <= 4
			then
				room:acquireSkill(lord, zd_dongcha)
			else
				room:acquireSkill(lord, zd_sheshen)
			end
			local dc = dummyCard()
			for c, id in sgs.list(room:getDrawPile()) do
				c = sgs.Sanguosha:getEngineCard(id)
				log = c:getPackage()
				if log ~= "maneuvering"
					and log ~= "standard_cards"
					and log ~= "limitation_broken"
				then
					continue
				end
				if c:isKindOf("Iightning")
					or c:isKindOf("AmazingGrace")
					or c:isKindOf("Snatch")
					or c:isKindOf("Collateral")
					or c:isKindOf("ExNihilo")
					or c:isKindOf("Nullification")
					or c:isKindOf("SupplyShortage")
					or c:isKindOf("Blade")
					or c:isKindOf("EightDiagram")
					or c:isKindOf("QinggangSword")
				then
					dc:addSubcard(id)
				end
			end
			log = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, "", "", "ToTable", "zhongdanyingjie")
			room:moveCardTo(dc, nil, sgs.Player_PlaceTable, log)
		elseif event == sgs.BuryVictim
			and room:getTag("zhongdanyingjie"):toBool()
		then
			local death = data:toDeath()
			if death.who:property("ZhongdanLoyalist"):toBool()
			then
				local damage = death.damage
				local lord = room:getTag("ZhongdanLord"):toPlayer()
				if damage and damage.from
				then
					if damage.from:objectName() == lord:objectName()
					then
						damage.from:throwAllHandCardsAndEquips()
					else
						damage.from:drawCards(3, "kill")
					end
					room:setTag("SkipGameRule", ToData(true))
				end
				room:broadcastProperty(lord, "role")
				room:setEmotion(lord, "lord")
				local sk = lord:getGeneral():getSkillList()
				if lord:getGeneral2()
				then
					for _, s in sgs.list(lord:getGeneral2():getSkillList()) do
						sk:append(s)
					end
				end
				for _, s in sgs.list(sk) do
					if s:isLordSkill()
					then
						room:acquireSkill(lord, s)
					end
				end
				return true
			elseif death.who:getRole() == "loyalist"
			then
				local damage = death.damage
				if damage and damage.from
					and damage.from:property("ZhongdanLoyalist"):toBool()
				then

				end
			end
		elseif event == sgs.GameOverJudge
		then
			local death = data:toDeath()
		elseif event == sgs.BeforeGameOverJudge
			and room:getTag("zhongdanyingjie"):toBool()
		then
			local death = data:toDeath()
			local lord = room:getTag("ZhongdanLord"):toPlayer()
			if death.who:property("ZhongdanLoyalist"):toBool()
			then
				death.who:setProperty("role", ToData("loyalist"))
				lord:setProperty("role", ToData("lord"))
			elseif lord:objectName() == death.who:objectName()
			then
				death.who:setProperty("role", ToData("lord"))
				room:getTag("ZhongdanLoyalist"):toPlayer():setProperty("role", ToData("loyalist"))
			end
		elseif event == sgs.CardsMoveOneTime
		then
			local move = data:toMoveOneTime()
			if move.from and bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD
				and move.from:objectName() == player:objectName()
			then
				for i, id in sgs.list(move.card_ids) do
					if sgs.Sanguosha:getCard(id):isKindOf("ZdJinchantuoqiao")
						and move.from_places:at(i) == sgs.Player_PlaceHand
					then
						player:drawCards(1, "zd_jinchantuoqiao")
					end
				end
			end
		elseif event == sgs.TargetConfirming
		then
			local use = data:toCardUse()
			if use.card:getTypeId() > 2 or use.card:getTypeId() < 1
				or table.contains(use.no_offset_list, player:objectName())
				or use.from == player then
				return
			end
			local cs = hasCard(player, "ZdJinchantuoqiao")
			if cs and cs:length() == player:getHandcardNum()
			then
				player:setTag("ZdJinchan", data)
				if room:askForUseCard(player, "ZdJinchantuoqiao", "ZdJinchan0:" .. use.from:objectName() .. ":" .. use.card:objectName(), -1, sgs.Card_MethodUse, true, use.from, use.card)
					and player:getMark("ZdJinchan-Clear") > 0
				then
					player:removeMark("ZdJinchan-Clear")
					cs = use.nullified_list
					table.insert(cs, player:objectName())
					use.nullified_list = cs
					data:setValue(use)
				end
			end
		elseif event == sgs.DrawNCards
			and player:getMark("ZdCaomuDebf-Clear") > 0
		then
			local n = data:toInt()
			data:setValue(n - 1)
		elseif event == sgs.EventPhaseEnd
			and player:getMark("ZdCaomuDebf-Clear") > 0
			and player:getPhase() == sgs.Player_Draw
		then
			for _, p in sgs.list(room:getOtherPlayers(player)) do
				if p:distanceTo(player) == 1
				then
					p:drawCards(1, "zd_caomujiebing")
				end
			end
		end
		return false
	end,
}
addToSkills(ZhongdanOnTrigger)




wenheluanwu = sgs.Package("wenheluanwu")
wl_luanwu = sgs.CreateTrickCard {
	name = "wl_luanwu",
	class_name = "WlLuanwu",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = true,
	can_recast = false,
	is_cancelable = true,
	about_to_use = function(self, room, use)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if use.to:isEmpty() then use.to:append(use.from) end
		self:cardOnUse(room, use)
	end,
	on_effect = function(self, effect)
		local to, source, room = effect.to, effect.from, effect.to:getRoom()
		for _, p in sgs.list(room:getOtherPlayers(to)) do
			room:doAnimate(1, to:objectName(), p:objectName())
		end
		for d, p in sgs.list(room:getOtherPlayers(to)) do
			local sj = sgs.SPlayerList()
			n = room:getOtherPlayers(p)
			d = 998
			for x, ap in sgs.list(n) do
				x = p:distanceTo(ap)
				if x < d then d = x end
			end
			for x, ap in sgs.list(n) do
				x = p:distanceTo(ap)
				if x <= d then sj:append(ap) end
			end
			d = room:askForUseSlashTo(p, sj, "wl_luanwu_slash:")
			if d then else room:loseHp(p, 1, false, source, "wl_luanwu") end
		end
	end
}
wl_luanwu:clone(0, 10):setParent(wenheluanwu)
wl_luanwu:clone(1, 4):setParent(wenheluanwu)
wl_douzhuanxingyi = sgs.CreateTrickCard {
	name = "wl_douzhuanxingyi",
	class_name = "WlDouzhuanxingyi",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	--	damage_card = true,
	filter = function(self, targets, to_select, source)
		if source:isProhibited(to_select, self) then return end
		return to_select:objectName() ~= source:objectName()
			and #targets <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, source, self)
	end,
	on_effect = function(self, effect)
		local from, to, room = effect.from, effect.to, effect.to:getRoom()
		local n = from:getHp() + to:getHp()
		local fh = math.random(1, n)
		fh = fh > from:getMaxHp() and from:getMaxHp() or fh
		local th = n - fh
		if th > to:getMaxHp()
		then
			fh = fh + th - to:getMaxHp()
			th = to:getMaxHp()
		end
		local log = sgs.LogMessage()
		log.type = "$wl_douzhuanxingyi"
		log.from = from
		log.to:append(to)
		log.arg = "wl_douzhuanxingyi"
		log.arg2 = fh
		log.arg3 = th
		room:sendLog(log)
		room:setPlayerProperty(from, "hp", ToData(fh))
		room:setPlayerProperty(to, "hp", ToData(th))
		room:broadcastProperty(from, "hp")
		room:broadcastProperty(to, "hp")
		return false
	end,
}
wl_douzhuanxingyi:clone(2, 1):setParent(wenheluanwu)
wl_douzhuanxingyi:clone(3, 5):setParent(wenheluanwu)
wl_lidaitaojing = sgs.CreateTrickCard {
	name = "wl_lidaitaojing",
	class_name = "WlLidaitaojing",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	--	damage_card = true,
	filter = function(self, targets, to_select, source)
		if source:isProhibited(to_select, self) then return end
		return to_select:objectName() ~= source:objectName()
			and #targets <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, source, self)
	end,
	on_effect = function(self, effect)
		local from, to, room = effect.from, effect.to, effect.to:getRoom()
		local hand = from:handCards()
		for _, id in sgs.list(to:handCards()) do
			hand:append(id)
		end
		local n = hand:length()
		local x = math.random(0, n)
		local log = sgs.LogMessage()
		log.type = "$wl_lidaitaojing"
		log.from = from
		log.to:append(to)
		log.arg = "wl_lidaitaojing"
		log.arg2 = x
		log.arg3 = n - x
		room:sendLog(log)
		local moves = sgs.CardsMoveList()
		local move1 = sgs.CardsMoveStruct()
		move1.to_place = sgs.Player_PlaceHand
		move1.to = from
		move1.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, from:objectName(), "", "wl_lidaitaojing", "")
		local move2 = sgs.CardsMoveStruct()
		move2.to = to
		move2.to_place = sgs.Player_PlaceHand
		move2.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, from:objectName(), to:objectName(),
			"wl_lidaitaojing", "")
		for r, id in sgs.list(RandomList(hand)) do
			if r + 1 <= x
			then
				if from:handCards():contains(id) then continue end
				move1.card_ids:append(id)
			else
				if to:handCards():contains(id) then continue end
				move2.card_ids:append(id)
			end
		end
		moves:append(move1)
		moves:append(move2)
		room:moveCardsAtomic(moves, false)
		return false
	end,
}
wl_lidaitaojing:clone(3, 12):setParent(wenheluanwu)
wl_lidaitaojing:clone(2, 1):setParent(wenheluanwu)
wl_lidaitaojing:clone(2, 13):setParent(wenheluanwu)
wl_toulianghuanzhu = sgs.CreateTrickCard {
	name = "wl_toulianghuanzhu",
	class_name = "WlToulianghuanzhu",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = true,
	can_recast = false,
	is_cancelable = true,
	about_to_use = function(self, room, use)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if use.to:isEmpty() then use.to:append(use.from) end
		self:cardOnUse(room, use)
	end,
	on_effect = function(self, effect)
		local to, from, room = effect.to, effect.from, effect.to:getRoom()
		for _, p in sgs.list(room:getOtherPlayers(to)) do
			room:doAnimate(1, to:objectName(), p:objectName())
		end
		local ap = room:getAllPlayers()
		local toes = {}
		for _, p in sgs.list(ap) do
			toes[p:objectName()] = sgs.IntList()
		end
		for ie = 0, 4 do
			local es = {}
			for e, p in sgs.list(ap) do
				e = p:getEquip(ie)
				if e then table.insert(es, e:getId()) end
			end
			for _, p in sgs.list(RandomList(ap)) do
				if #es > 0 and p:hasEquipArea(ie)
				then
					toes[p:objectName()]:append(es[1])
					table.remove(es, 1)
				end
			end
		end
		local moves = sgs.CardsMoveList()
		for _, p in sgs.list(ap) do
			local move = sgs.CardsMoveStruct()
			move.card_ids = p:getEquipsId()
			move.to_place = sgs.Player_PlaceTable
			move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, from:objectName(), p:objectName(),
				"wl_lidaitaojing", "")
			if move.card_ids:length() > 0 then moves:append(move) end
		end
		local moves1 = sgs.CardsMoveList()
		for _, p in sgs.list(ap) do
			local log = sgs.LogMessage()
			log.type = "$wl_toulianghuanzhu0"
			log.arg = "wl_toulianghuanzhu"
			log.arg2 = toes[p:objectName()]:length()
			for _, id in sgs.list(toes[p:objectName()]) do
				log.type = "$wl_toulianghuanzhu"
				log.card_str = table.concat(sgs.QList2Table(toes[p:objectName()]), "+")
				local move1 = sgs.CardsMoveStruct()
				move1.to_place = sgs.Player_PlaceEquip
				move1.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, from:objectName(), p:objectName(),
					"wl_lidaitaojing", "")
				--move1.from = room:getCardOwner(id)
				move1.card_ids:append(id)
				move1.to = p
				moves1:append(move1)
			end
			log.to:append(p)
			room:sendLog(log)
		end
		room:moveCardsAtomic(moves, false)
		room:moveCardsAtomic(moves1, false)
	end
}
wl_toulianghuanzhu:clone(0, 11):setParent(wenheluanwu)
wl_toulianghuanzhu:clone(1, 12):setParent(wenheluanwu)
wl_toulianghuanzhu:clone(1, 13):setParent(wenheluanwu)
wl_toulianghuanzhu:clone(0, 13):setParent(wenheluanwu)

local BanWenhe
WenheOnTrigger = sgs.CreateTriggerSkill {
	name = "WenheOnTrigger",
	frequency = sgs.Skill_Compulsory,
	global = true,
	events = { sgs.ConfirmDamage, sgs.RoundStart, sgs.GameReady, sgs.CardsMoveOneTime, sgs.Death,
		sgs.RoundEnd, sgs.GameOverJudge, sgs.EventPhaseChanging, sgs.HpChanged },
	priority = { 5, 5, 5, 5, 5, 5, 5 },
	can_trigger = function(self, target)
		if BanWenhe == false then return true elseif BanWenhe then return end
		BanWenhe = sgs.Sanguosha:currentRoom():getMode() ~= "08p" or
			table.contains(sgs.Sanguosha:getBanPackages(), "wenheluanwu")
		return not BanWenhe
	end,
	on_trigger = function(self, event, player, data, room)
		local log = sgs.LogMessage()
		log.type = "$jl_bingfen"
		log.from = room:getOwner()
		log.arg = "wenheluanwu"
		if event == sgs.GameReady
		then
			if not room:getLord() then return end
			room:sendLog(log)
			room:setTag("wenheluanwu", ToData(true))
			for _, p in sgs.list(room:getAlivePlayers()) do
				if p:getRole() == "lord"
				then
					--room:setPlayerProperty(p,"hp",ToData(p:getHp()-1))
					--room:setPlayerProperty(p,"maxhp",ToData(p:getMaxHp()-1))
					p:setProperty("hp", ToData(p:getHp() - 1))
					p:setProperty("maxhp", ToData(p:getMaxHp() - 1))
					room:broadcastProperty(p, "hp")
					room:broadcastProperty(p, "maxhp")
				end
				p:setProperty("role", ToData("renegade"))
				room:broadcastProperty(p, "role")
				room:acquireSkill(p, "wansha", true, true, false)
			end
			room:doLightbox("$wenheluanwuLightbox1", 4333, 77)
			local dc = dummyCard()
			for c, id in sgs.list(room:getDrawPile()) do
				c = sgs.Sanguosha:getEngineCard(id)
				log = c:getPackage()
				if log ~= "maneuvering"
					and log ~= "standard_cards"
					and log ~= "limitation_broken"
				then
					continue
				end
				if c:isKindOf("Indulgence")
					or c:isKindOf("WoodenOx")
					or c:isKindOf("GodSalvation")
					or c:isKindOf("Nullification")
					or c:isKindOf("SupplyShortage")
				then
					dc:addSubcard(id)
				end
			end
			log = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, "", "", "ToTable", "wenheluanwu")
			room:moveCardTo(dc, nil, sgs.Player_PlaceTable, log)
			--room:doLightbox("$wenheluanwuLightbox2",3333)
		elseif not room:getTag("wenheluanwu"):toBool()
		then
			return
		end
		if event == sgs.Death
		then
			log.type = "$wenheluanwuJISHA"
			local death = data:toDeath()
			log.to:append(death.who)
			death = death.damage
			if not death then return end
			death = death.from
			if not death or death:isDead()
				or death ~= player then
				return
			end
			log.arg = "wenheluanwu_jisha"
			log.arg2 = "wenheluanwu_jiangli"
			log.from = death
			room:sendLog(log)
			local sj = room:getTag("wenheluanwu_sj"):toString()
			if sj == "wl_zhongshang"
			then
				sj = 2
				log.type = "$wl_hengdaoyuema"
				log.arg = "wl_zhongshang"
				log.arg2 = ":wl_zhongshang"
				room:sendLog(log)
			else
				sj = 1
			end
			room:gainMaxHp(death, 1 * sj)
			death:drawCards(3 * sj, "wenheluanwu")
		elseif event == sgs.HpChanged
		then
			if room:getTag("TurnLengthCount"):toInt() > 1 then return end
			if player:isWounded()
			then
				if player:hasSkill("bazhen") then return end
				player:setTag("WLbazhen", ToData(true))
				room:acquireSkill(player, "bazhen")
			elseif player:getTag("WLbazhen"):toBool()
				and player:hasSkill("bazhen")
			then
				player:removeTag("WLbazhen")
				room:detachSkillFromPlayer(player, "bazhen", true, true)
			end
		elseif event == sgs.RoundEnd
		then
			if room:getTag("WL_Round"):toInt() < 1 then return end
			room:setTag("WL_Round", ToData(0))
			local sj = room:getTag("wenheluanwu_sj"):toString()
			local ap = room:getAlivePlayers()
			for _, to in sgs.list(ap) do
				if to:getTag("WLbazhen"):toBool()
					and to:hasSkill("bazhen")
				then
					to:removeTag("WLbazhen")
					room:detachSkillFromPlayer(to, "bazhen", true, true)
				end
			end
			if sj == "wl_epiaozaidao"
			then
				log.type = "$wl_hengdaoyuema"
				log.arg = "wl_epiaozaidao"
				log.arg2 = ":wl_epiaozaidao"
				room:sendLog(log)
				local tos = sgs.QList2Table(ap)
				local func = function(a, b)
					return a:getHandcardNum() < b:getHandcardNum()
				end
				table.sort(tos, func)
				local n = room:getTag("TurnLengthCount"):toInt()
				func = tos[1]:getHandcardNum()
				for x, to in sgs.list(ap) do
					if to:getHandcardNum() > func then continue end
					room:loseHp(to, n, false, nil, "wl_epiaozaidao")
				end
			end
		elseif event == sgs.RoundStart
		then
			if room:getTag("WL_Round"):toInt() > 0 then return end
			room:setTag("WL_Round", ToData(1))
			local sj = { "wl_luanwu", "wl_hengdaoyuema", "wl_zhongshang", "wl_pofuchenzhou", "wl_hengshaoqianjun",
				"wl_yananzhendu", "wl_epiaozaidao" }
			local n = room:getTag("TurnLengthCount"):toInt()
			local ap = room:getAlivePlayers()
			if n < 2 then
				sj = sj[1]
			else
				sj = RandomList(sj)[1]
			end
			log.arg = sj
			log.arg3 = ":" .. sj
			log.arg2 = "wenheluanwu_sj"
			log.type = "$wenheluanwu_sj"
			room:sendLog(log)
			room:doSuperLightbox(sj, sj)
			room:setTag("wenheluanwu_sj", ToData(sj))
			if sj == "wl_luanwu"
			then
				ap = RandomList(ap)
				ap = ap:at(0)
				log = ap:getNextAlive()
				local tos = sgs.SPlayerList()
				tos:append(ap)
				while ap:objectName() ~= log:objectName() do
					tos:append(log)
					log = log:getNextAlive()
				end
				for d, to in sgs.list(tos) do
					sj = sgs.SPlayerList()
					d = 998
					n = room:getOtherPlayers(to)
					for x, p in sgs.list(n) do
						x = to:distanceTo(p)
						if x < d then d = x end
					end
					for x, p in sgs.list(n) do
						x = to:distanceTo(p)
						if x <= d then sj:append(p) end
					end
					d = room:askForUseSlashTo(to, sj, "wl_luanwu_slash:")
					if d then else room:loseHp(to) end
				end
			end
		elseif event == sgs.CardsMoveOneTime
		then
			if player:isDead() then return end
			local move = data:toMoveOneTime()
			local sj = room:getTag("wenheluanwu_sj"):toString()
			if sj == "wl_yananzhendu"
			then
				for _, c in sgs.list(player:getHandcards()) do
					if c:isKindOf("Peach")
					then
						local toc = sgs.Sanguosha:cloneCard("yj_poison", c:getSuit(), c:getNumber())
						toc:setSkillName("wl_yananzhendu")
						local wrap = sgs.Sanguosha:getWrappedCard(c:getEffectiveId())
						wrap:takeOver(toc)
						room:notifyUpdateCard(player, c:getEffectiveId(), wrap)
					end
				end
				if move.reason.m_skillName == "draw_phase"
					and player:objectName() == move.to:objectName()
				then
					local ids = {}
					for _, id in sgs.list(move.card_ids) do
						if sgs.Sanguosha:getCard(id):isKindOf("Poison")
							and player:handCards():contains(id)
						then
							table.insert(ids, id)
						end
					end
					while #ids > 0 do
						local c = room:askForUseCard(player, "Poison," .. table.concat(ids, ","), "yj_poison0:")
						if c then table.removeOne(ids, c:getEffectiveId()) else break end
					end
				end
				if move.from and player:objectName() == move.from:objectName()
				then
					local function visibleSpecial(id, i)
						if move.to_place == sgs.Player_PlaceSpecial
						then
							for _, p in sgs.list(move.to:getAliveSiblings()) do
								if move.to:pileOpen(move.to:getPileName(id), p:objectName())
								then else
									return
								end
							end
							return true
						elseif move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_DrawPile
						then
							return sgs.Sanguosha:getCard(id):hasFlag("visible")
						else
							return move.open:at(i)
								or move.to_place == sgs.Player_PlaceTable
								or move.to_place == sgs.Player_PlaceDelayedTrick
						end
					end
					for i, id in sgs.list(move.card_ids) do
						if sgs.Sanguosha:getCard(id):isKindOf("Peach")
							and move.from_places:at(i) == sgs.Player_PlaceHand
							and player:isAlive() and visibleSpecial(id, i)
							and player:getMark("BanPoisonEffect") < 1
						then
							log.type = "$wl_hengdaoyuema"
							log.arg = "wl_yananzhendu"
							log.arg2 = ":wl_yananzhendu"
							room:sendLog(log)
							Skill_msg("yj_poison", player)
							room:loseHp(player, 1, false, nil, "yj_poison")
						end
					end
				end
			else
				for i, c in sgs.list(player:getHandcards()) do
					if c:getSkillName() == "wl_yananzhendu"
					then
						local hw = sgs.CardList()
						hw:append(c)
						room:filterCards(player, hw, true)
					end
				end
			end
		elseif event == sgs.ConfirmDamage
		then
			local damage = data:toDamage()
			local sj = room:getTag("wenheluanwu_sj"):toString()
			if sj == "wl_hengshaoqianjun"
			then
				log.type = "$wl_hengdaoyuema"
				log.arg = "wl_hengshaoqianjun"
				log.arg2 = ":wl_hengshaoqianjun"
				room:sendLog(log)
				DamageRevises(data, 1, player)
			end
		elseif event == sgs.EventPhaseChanging
		then
			if player:isDead() then return end
			local change = data:toPhaseChange()
			local sj = room:getTag("wenheluanwu_sj"):toString()
			if change.to == sgs.Player_NotActive
			then
				local ap = room:getAlivePlayers()
				room:sortByActionOrder(ap)
				if sj == "wl_hengdaoyuema"
				then
					log.type = "$wl_hengdaoyuema"
					log.arg = "wl_hengdaoyuema"
					log.arg2 = ":wl_hengdaoyuema"
					room:sendLog(log)
					local tos = sgs.QList2Table(ap)
					local func = function(a, b)
						return a:getEquips():length() < b:getEquips():length()
					end
					table.sort(tos, func)
					sj = sgs.IntList()
					for i, id in sgs.list(room:getDrawPile()) do
						if sgs.Sanguosha:getCard(id):isKindOf("EquipCard")
						then
							sj:append(id)
						end
					end
					sj = RandomList(sj)
					func = tos[1]:getEquips():length()
					for x, to in sgs.list(ap) do
						if to:getEquips():length() > func
						then
							continue
						end
						room:loseHp(to)
						if to:isDead()
							or sj:isEmpty()
						then
							continue
						end
						for i, id in sgs.list(sj) do
							if InstallEquip(id, to, "wenheluanwu")
							then
								sj:removeOne(id)
								break
							end
						end
					end
				end
			elseif change.from == sgs.Player_NotActive
			then
				if sj == "wl_pofuchenzhou"
				then
					log.type = "$wl_hengdaoyuema"
					log.arg = "wl_pofuchenzhou"
					log.arg2 = ":wl_pofuchenzhou"
					room:sendLog(log)
					room:loseHp(player)
					if player:isDead() then return end
					player:drawCards(3, "wl_pofuchenzhou")
				end
			end
		elseif event == sgs.GameOverJudge
		then
			log = room:getAlivePlayers()
			if log:length() > 1 then return end
			room:gameOver(log:at(0):objectName())
		end
		return false
	end,
}
addToSkills(WenheOnTrigger)

sgs.LoadTranslationTable {
	["zhongdanyingjie"] = "忠胆英杰",
	["ZhongdanCard"] = "忠胆英杰卡牌",
	["$jl_bingfen"] = "%from（玩家）启用了 %arg",
	["cuiyan"] = "崔琰",
	["#cuiyan"] = "伯夷之风",
	["illustrator:cuiyan"] = "F.源",
	["zd_yawang"] = "雅望",
	[":zd_yawang"] = "锁定技，摸牌阶段开始时，你放弃摸牌，然后摸X张牌，令你于此回合的出牌阶段内使用的牌数不大于X。（X为体力值与你相同的角色数）",
	["$zd_yawang1"] = "琰，定不负诸位雅望。",
	["$zd_yawang2"] = "君子，当以正气，立于乱世！",
	["zd_xunzhi"] = "殉志",
	[":zd_xunzhi"] = "准备阶段开始时，若你的上家与下家的体力值均与你不同，你可以失去1点体力，令你的手牌上限+2。",
	["$zd_xunzhi1"] = "春秋大业，自在我心！",
	["$zd_xunzhi2"] = "成大义者，这点儿牺牲，算不得什么！",
	["~cuiyan"] = "尔等，尽是欺世盗名之辈......",
	["huangfusong"] = "皇甫嵩",
	["#huangfusong"] = "志定雪霜",
	["illustrator:huangfusong"] = "秋呆呆",
	["zd_fenyue"] = "奋钺",
	[":zd_fenyue"] = "<font color=\"green\"><b>出牌阶段限X次，</b></font>你可以与一名角色拼点：若你赢，你选择视为对其使用【杀】或令其于此回合内不能使用或打出手牌；若你没赢后，你结束此阶段。（X为忠臣数）",
	["zd_fenyue1"] = "其于此回合内不能使用或打出手牌",
	["zd_fenyue2"] = "视为对其使用【杀】",
	["$zd_fenyue1"] = "逆贼势大，且扎营寨，击其懈怠。",
	["$zd_fenyue2"] = "兵有其变，不在众寡。",
	["~huangfusong"] = "只恨黄巾未除，不能报效朝廷。",
	["zd_shengdongjixi"] = "声东击西",
	[":zd_shengdongjixi"] = "锦囊牌<br /><font color=\"#bab8ba\"><b>（替换【顺手牵羊】）</b></font><br /><b>时机</b>：出牌阶段<br /><b>目标</b>：距离为1的一名角色<br /><b>效果</b>：你交给目标一张手牌，然后其将两张牌交给另一名你选择的角色。",
	["zd_shengdongjixi0"] = "声东击西：请选择将一张手牌交给%src",
	["zd_shengdongjixi1"] = "声东击西：请选择将两张手牌交给%src",
	["zd_caomujiebing"] = "草木皆兵",
	[":zd_caomujiebing"] = "锦囊牌·延时锦囊<br /><font color=\"#bab8ba\"><b>（替换【兵粮寸断】）</b></font><br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名其他角色<br /><b>效果</b>：将此牌置于目标判定区。若判定阶段判定的结果不为♣：其摸牌阶段摸牌数-1，然后摸牌阶段结束时，与其距离为1的角色各摸一张牌。",
	["zd_zengbingjianzao"] = "增兵减灶",
	[":zd_zengbingjianzao"] = "锦囊牌<br /><font color=\"#bab8ba\"><b>（替换【无中生有】和【五谷丰登】）</b></font><br /><b>时机</b>：出牌阶段<br /><b>目标</b>：你<br /><b>效果</b>：目标摸三张牌，然后选择一项：1.弃置一张非基本牌；2.弃置两张牌。",
	["ZdZengbing0"] = "增兵减灶：请选择弃置一张非基本牌或两张牌",
	["zd_qijiayebing"] = "弃甲曳兵",
	[":zd_qijiayebing"] = "锦囊牌<br /><font color=\"#bab8ba\"><b>（替换【借刀杀人】）</b></font><br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名装备区有牌的其他角色<br /><b>效果</b>：目标选择弃置：1.所有的武器牌和-1坐骑牌；2.所有的防具牌和+1坐骑牌。",
	["ZdQijia1"] = "弃置所有的武器牌和-1坐骑牌",
	["ZdQijia2"] = "弃置所有的防具牌和+1坐骑牌",
	["zd_jinchantuoqiao"] = "金蝉脱壳",
	[":zd_jinchantuoqiao"] = "锦囊牌<br /><font color=\"#bab8ba\"><b>（替换【无懈可击】）</b></font><br /><b>时机</b>：你成为其他角色使用基本牌或锦囊牌的目标时，若你手牌中只有【金蝉脱壳】<br /><b>目标</b>：目标牌<br /><b>效果</b>：令目标牌对你无效，然后你摸两张牌。<br /><b>额外效果</b>：当你因弃置而失去【金蝉脱壳】后，你摸一张牌。",
	["ZdJinchan0"] = "你可以使用【金蝉脱壳】令%src对你使用的【%dest】无效",
	["zd_fulei"] = "浮雷",
	[":zd_fulei"] = "锦囊牌·延时锦囊<br /><font color=\"#bab8ba\"><b>（替换【闪电】）</b></font><br /><b>时机</b>：出牌阶段<br /><b>目标</b>：你<br /><b>效果</b>：将此牌置于目标判定区。若判定阶段判定的结果为♠，则其受到X点雷电伤害（X为此牌判定♠的次数）；判定结束后此牌移至下家判定区。",
	["zd_lanyinjia"] = "烂银甲",
	[":zd_lanyinjia"] = "装备牌·武器<br /><font color=\"#bab8ba\"><b>（替换【八卦阵】）</b></font><br /><b>装备效果</b>：你可以将一张手牌当做【闪】使用或打出；【烂银甲】不会被无效或无视；当你受到【杀】的伤害时，你弃置【烂银甲】。",
	["zd_qibaodao"] = "七宝刀",
	[":zd_qibaodao"] = "装备牌·武器<br /><font color=\"#bab8ba\"><b>（替换【青釭剑】）</b></font><br /><b>装备效果</b>：锁定技，你使用的【杀】无视防具；若目标未损失体力，此【杀】对其伤害+1。",
	["zd_zhungangshuo"] = "衠钢槊",
	[":zd_zhungangshuo"] = "装备牌·武器<br /><font color=\"#bab8ba\"><b>（替换【青龙偃月刀】）</b></font><br /><b>装备效果</b>：当你使用【杀】指定目标后，你可以令目标弃置你一张手牌，然后你弃置其一张手牌。",
	["$ZdShengdongTo"] = "%from 选择令 %to 将两张牌交给 %arg",
	["zd_dongcha"] = "洞察",
	[":zd_dongcha"] = "游戏开始时，随机一名反贼身份对你可见；准备阶段，你可以弃置场上的一张牌。",
	["zd_dongcha0"] = "洞察：你可以弃置场上的一张牌",
	["zd_sheshen"] = "舍身",
	[":zd_sheshen"] = "锁定技，主公处于濒死状态时，你令其增加1点体力上限，回复X点体力（X为你的体力值），获得你所有牌，然后你死亡。",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["wenheluanwu"] = "文和乱武",
	["$wenheluanwuLightbox1"] = "欢迎进入 <<文和乱武>>",
	["$wenheluanwuLightbox2"] = "                 乱世-----开始了",
	["$wenheluanwuJISHA"] = "%from %arg了 %to ，获得 %arg2",
	["wenheluanwu_jisha"] = "击杀",
	["wenheluanwu_jiangli"] = "击杀奖励",
	["$wenheluanwu_sj"] = "本轮 %arg2 为 %arg",
	["wenheluanwu_sj"] = "随机事件",
	["wl_luanwu"] = "乱武",
	[":wl_luanwu"] = "从随机一名角色开始，所有角色各选择一项：1、对另一名距离最近的角色使用一张【杀】；2、失去1点体力",
	["wl_hengdaoyuema"] = "横刀越马",
	[":wl_hengdaoyuema"] = "每回合结束时，所有装备区牌数最少的角色各失去1点体力，并随机将牌堆中的一张装备牌置入其装备区",
	["wl_zhongshang"] = "重赏",
	[":wl_zhongshang"] = "本轮次中，所有角色的击杀奖励翻倍",
	["wl_pofuchenzhou"] = "破釜沉舟",
	[":wl_pofuchenzhou"] = "每名角色的回合开始时，其失去1点体力，然后摸3张牌",
	["wl_hengshaoqianjun"] = "横扫千军",
	[":wl_hengshaoqianjun"] = "本轮次中，所有即将造成的伤害+1",
	["wl_yananzhendu"] = "宴安鸩毒",
	[":wl_yananzhendu"] = "本轮次中，所有【桃】均视为【毒】",
	["wl_epiaozaidao"] = "饿莩载道",
	[":wl_epiaozaidao"] = "本轮结束时，所有手牌最少的角色失去等同当前轮数的体力",
	["wl_luanwu_slash"] = "乱武：请对距离最近的一名其他角色使用【杀】，否则失去1点体力",
	["$wl_hengdaoyuema"] = "%arg 效果触发：%arg2",
	["wl_luanwu"] = "乱武",
	[":wl_luanwu"] = "锦囊牌<br /><font color=\"#bab8ba\"><b>（替换【兵粮寸断】）</b></font><br /><b>时机</b>：出牌阶段<br /><b>目标</b>：你<br /><b>效果</b>：其他角色各选择一项：1、对其距离最近的另一名角色使用一张【杀】；2、失去1点体力。",
	["wl_douzhuanxingyi"] = "斗转星移",
	[":wl_douzhuanxingyi"] = "锦囊牌<br /><font color=\"#bab8ba\"><b>（替换【桃园结义】和【木牛流马】）</b></font><br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名其他角色<br /><b>效果</b>：随机分配你和目标角色的体力（至少为1且不能大于体力上限）。",
	["$wl_douzhuanxingyi"] = "%arg 为 %from 分配了 %arg2 点体力，为 %to 分配了 %arg3 点体力",
	["wl_lidaitaojing"] = "李代桃僵",
	[":wl_lidaitaojing"] = "锦囊牌<br /><font color=\"#bab8ba\"><b>（替换红色【无懈可击】）</b></font><br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名其他角色<br /><b>效果</b>：随机分配你和目标角色的所有手牌。",
	["$wl_lidaitaojing"] = "%arg 为 %from 分配了 %arg2 张手牌，为 %to 分配了 %arg3 张手牌",
	["wl_toulianghuanzhu"] = "偷梁换柱",
	[":wl_toulianghuanzhu"] = "锦囊牌<br /><font color=\"#bab8ba\"><b>（替换黑色【无懈可击】）</b></font><br /><b>时机</b>：出牌阶段<br /><b>目标</b>：你<br /><b>效果</b>：随机分配场上所有角色装备区里的牌。",
	["$wl_toulianghuanzhu"] = "%arg 为 %to 分配了 %arg2 张装备牌 %card",
	["$wl_toulianghuanzhu0"] = "%arg 为 %to 分配了 %arg2 张装备牌",
	["ToTable"] = "移除",
}



return { yongjian, zhulu, Zhongdan, ZhongdanCard, wenheluanwu }
