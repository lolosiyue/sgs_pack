--==《新武将》==--
extension = sgs.Package("kearjsrgqi", sgs.Package_GeneralPack)
local skills = sgs.SkillList()

--buff集中
keqislashmore = sgs.CreateTargetModSkill {
	name = "keqislashmore",
	pattern = ".",
	residue_func = function(self, from, card, to)
		local n = 0
		if from:hasSkill("keqizhenglue") and to and (to:getMark("&keqilue") > 0) then
			n = n + 1000
		end
		if from:hasSkill("keqilimu") and not from:getJudgingArea():isEmpty() and to and from:inMyAttackRange(to) then
			n = n + 1000
		end
		return n
	end,
	distance_limit_func = function(self, from, card, to)
		local n = 0
		if from:hasSkill("keqizhenglue") and to and to:getMark("&keqilue") > 0 then
			n = n + 1000
		end
		if from:hasSkill("keqilimu") and not from:getJudgingArea():isEmpty() and to and from:inMyAttackRange(to) then
			n = n + 1000
		end
		return n
	end
}
if not sgs.Sanguosha:getSkill("keqislashmore") then skills:append(keqislashmore) end



keqicaocao = sgs.General(extension, "keqicaocao", "qun", 4)

keqizhenglue = sgs.CreateTriggerSkill {
	name = "keqizhenglue",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseChanging, sgs.Damage },
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			room:setPlayerMark(damage.from, "banzhenglue-Clear", 1)
			if damage.from:hasSkill(self:objectName()) and (damage.to:getMark("&keqilue") > 0) then
				if (damage.from:getMark("zhengluemopai-Clear") == 0) then
					if room:askForSkillInvoke(damage.from, "keqizhengluegaincard", data) then
						room:broadcastSkillInvoke(self:objectName())
						damage.from:drawCards(1)
						if damage.card then
							damage.from:obtainCard(damage.card)
						end
						room:setPlayerMark(damage.from, "zhengluemopai-Clear", 1)
					end
				end
			end
		end
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) and (player:getRole() == "lord") then
				local ccs = room:findPlayersBySkillName(self:objectName())
				local players = sgs.SPlayerList()
				for _, cc in sgs.qlist(ccs) do
					if room:askForSkillInvoke(cc, self:objectName(), data) then
						room:broadcastSkillInvoke(self:objectName())
						cc:drawCards(1)
						for _, p in sgs.qlist(players) do
							players:removeOne(p)
						end
						for _, pp in sgs.qlist(room:getAllPlayers()) do
							if (pp:getMark("&keqilue") == 0) then
								players:append(pp)
							end
						end
						if (player:getMark("banzhenglue-Clear") == 0) then
							if (player:getState() ~= "online") then
								local getlies = room:askForPlayersChosen(cc, players, self:objectName(),
									math.min(2, players:length()), 2, "keqizhenglue-ask", true, true)
								for _, p in sgs.qlist(getlies) do
									if (p:getMark("&keqilue") == 0) then
										p:gainMark("&keqilue")
									end
								end
								--[[local aigetlies = sgs.SPlayerList()
								local aione = room:askForPlayerChosen(cc, players, self:objectName(), "keqizhenglue-ask", true, false)
								players:removeOne(one)
								local aitwo = room:askForPlayerChosen(cc, players, self:objectName(), "keqizhenglue-ask", true, false)
								aigetlies:append(aione)
								aigetlies:append(aitwo)
								for _,p in sgs.qlist(aigetlies) do
									if (p:getMark("&keqilue") == 0) then
									    p:gainMark("&keqilue")
									end
								end	]]
							else
								local getlies = room:askForPlayersChosen(cc, players, self:objectName(), 0, 2,
									"keqizhenglue-ask", true, true)
								for _, p in sgs.qlist(getlies) do
									if (p:getMark("&keqilue") == 0) then
										p:gainMark("&keqilue")
									end
								end
							end
						else
							local one = room:askForPlayerChosen(cc, players, self:objectName(), "keqizhenglue-ask", true,
								true)
							if one then
								if (one:getMark("&keqilue") == 0) then
									one:gainMark("&keqilue")
								end
							end
						end
					end
				end
			end
		end
	end,
}
keqicaocao:addSkill(keqizhenglue)



keqihuilie = sgs.CreatePhaseChangeSkill {
	name = "keqihuilie",
	frequency = sgs.Skill_Wake,
	waked_skills = "keqipingrong,feiying",
	on_phasechange = function(self, player)
		local room = player:getRoom()
		local num = 0
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:getMark("&keqilue") > 0 then
				num = num + 1
			end
		end
		if (num > 2) then
			room:notifySkillInvoked(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			room:doSuperLightbox("keqicaocao", "keqihuilie")
			room:setPlayerMark(player, self:objectName(), 1)
			if room:changeMaxHpForAwakenSkill(player) then
				if player:getMark(self:objectName()) == 1 then
					--room:acquireSkill(player, "kesuni")
					room:handleAcquireDetachSkills(player, "keqipingrong|feiying")
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:hasSkill(self:objectName()) and
			target:getPhase() == sgs.Player_Start
			and target:getMark(self:objectName()) == 0
	end
}
keqicaocao:addSkill(keqihuilie)

keqipingrong = sgs.CreateTriggerSkill {
	name = "keqipingrong",
	priority = 9,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseChanging, sgs.Damage, sgs.RoundStart },
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.RoundStart) then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "bankeqipingrong", 0)
			end
		end
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if (damage.from:getMark("inthekeqipingrong") > 0) then
				room:setPlayerMark(damage.from, "inthekeqipingrong", 0)
			end
		end
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) then
				--执行额外回合惩罚
				if (player:getMark("inthekeqipingrong") > 0) then
					room:loseHp(player, 1, true, player)
					room:setPlayerMark(player, "inthekeqipingrong", 0)
				end
				--选择出本轮未发动过此技能的角色
				local ccs = room:findPlayersBySkillName(self:objectName())
				local theccs = sgs.SPlayerList()
				for _, p in sgs.qlist(ccs) do
					if (p:getMark("bankeqipingrong") == 0) then
						theccs:append(p)
					end
				end
				local players = sgs.SPlayerList()
				for _, cc in sgs.qlist(theccs) do
					for _, p in sgs.qlist(players) do
						players:removeOne(p)
					end
					for _, pp in sgs.qlist(room:getAllPlayers()) do
						if (pp:getMark("&keqilue") > 0) then
							players:append(pp)
						end
					end
					local one = room:askForPlayerChosen(cc, players, self:objectName(), "keqipingrong-ask", true, true)
					if one then
						room:broadcastSkillInvoke(self:objectName())
						room:setPlayerMark(cc, "bankeqipingrong", 1)
						one:loseAllMarks("&keqilue")
						room:setPlayerMark(cc, "keqipingrongexturn", 1)
					end
				end
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("keqipingrongexturn") > 0) then
						room:setPlayerMark(p, "keqipingrongexturn", 0)
						room:setPlayerMark(p, "inthekeqipingrong", 1)
						room:setPlayerMark(p, "zhengluemopai-Clear", 0)
						p:gainAnExtraTurn()
					end
				end
			end
		end
	end,
}
if not sgs.Sanguosha:getSkill("keqipingrong") then skills:append(keqipingrong) end




keqiliubei = sgs.General(extension, "keqiliubei", "qun", 4)

keqizhenqiaoexex = sgs.CreateProhibitSkill {
	name = "keqizhenqiaoexex",
	is_prohibited = function(self, from, to, card)
		return ((from:getState() ~= "online") and (from:hasSkill("keqizhenqiao")) and card:isKindOf("Weapon"))
	end
}
if not sgs.Sanguosha:getSkill("keqizhenqiaoexex") then skills:append(keqizhenqiaoexex) end




keqijishan = sgs.CreateTriggerSkill {
	name = "keqijishan",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.DamageInflicted, sgs.Damage },
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if damage.from:hasSkill(self:objectName()) and (damage.from:getMark("bandajishan-Clear") == 0) then
				local firstfris = sgs.SPlayerList()
				local fris = sgs.SPlayerList()
				local yes = 1
				for _, p in sgs.qlist(room:getAllPlayers()) do
					yes = 1
					for _, pp in sgs.qlist(room:getAllPlayers()) do
						if (p:getHp() > pp:getHp()) then
							yes = 0
							break
						end
					end
					if (yes == 1) then
						firstfris:append(p)
					end
				end
				for _, p in sgs.qlist(firstfris) do
					if (p:getMark("&keqijishan") > 0) then
						fris:append(p)
					end
				end
				local one = room:askForPlayerChosen(damage.from, fris, self:objectName(), "keqijishan-ask", true, true)
				if one then
					room:broadcastSkillInvoke(self:objectName())
					room:setPlayerMark(damage.from, "bandajishan-Clear", 1)
					room:recover(one, sgs.RecoverStruct())
				end
			end
		end
		if (event == sgs.DamageInflicted) then
			local damage = data:toDamage()
			local lbs = room:findPlayersBySkillName(self:objectName())
			local use = 0
			for _, lb in sgs.qlist(lbs) do
				if (use == 0) and (lb:getMark("banjishan-Clear") == 0) then
					local to_data = sgs.QVariant()
					to_data:setValue(damage.to)
					if (lb:getState() ~= "online") then
						if (((lb:getHp() + lb:getHp() + lb:getHandcardNum()) > (damage.to:getHp() + damage.to:getHp() + damage.to:getHandcardNum()))
								and lb:isYourFriend(damage.to) and damage.to:isYourFriend(lb))
							or (lb:objectName() == damage.to:objectName()) then
							room:broadcastSkillInvoke(self:objectName())
							use = 1
							room:setPlayerMark(lb, "banjishan-Clear", 1)
							room:setPlayerMark(damage.to, "&keqijishan", 1)
							room:loseHp(lb, 1, true, lb)
							lb:drawCards(1)
							damage.to:drawCards(1)
							return true
						end
					else
						local will_use = room:askForSkillInvoke(lb, "keqijishan_pre", to_data)
						if will_use then
							room:broadcastSkillInvoke(self:objectName())
							use = 1
							room:setPlayerMark(lb, "banjishan-Clear", 1)
							room:setPlayerMark(damage.to, "&keqijishan", 1)
							room:loseHp(lb, 1, true, lb)
							lb:drawCards(1)
							damage.to:drawCards(1)
							return true
						end
					end
				end
			end
		end
	end,
}
keqiliubei:addSkill(keqijishan)


keqizhenqiao = sgs.CreateTriggerSkill {
	name = "keqizhenqiao",
	events = { sgs.CardFinished, sgs.TargetSpecified, sgs.GameReady },
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local room = player:getRoom()
		if (event == sgs.TargetSpecified) then
			local use = data:toCardUse()
			if player:hasSkill(self:objectName()) and use.card:isKindOf("Slash") and (not player:getWeapon()) then
				room:broadcastSkillInvoke(self:objectName())
				room:setCardFlag(use.card, "usingzhenqiao")
			end
		end
		if (event == sgs.CardFinished) then
			local use = data:toCardUse()
			if (use.card:hasFlag("usingzhenqiao")) then
				if use.card:isKindOf("Slash") then
					for _, p in sgs.qlist(use.to) do
						local se = sgs.SlashEffectStruct()
						se.from = use.from
						se.to = p
						se.slash = use.card
						se.nullified = table.contains(use.nullified_list, "_ALL_TARGETS") or
							table.contains(use.nullified_list, p:objectName())
						se.no_offset = table.contains(use.no_offset_list, "_ALL_TARGETS") or
							table.contains(use.no_offset_list, p:objectName())
						se.no_respond = table.contains(use.no_respond_list, "_ALL_TARGETS") or
							table.contains(use.no_respond_list, p:objectName())
						se.multiple = use.to:length() > 1
						se.nature = sgs.DamageStruct_Normal
						if use.card:objectName() == "fire_slash" then
							se.nature = sgs.DamageStruct_Fire
						elseif use.card:objectName() == "thunder_slash" then
							se.nature = sgs.DamageStruct_Thunder
						elseif use.card:objectName() == "ice_slash" then
							se.nature = sgs.DamageStruct_Ice
						end
						if use.from:getMark("drank") > 0 then
							room:setCardFlag(use.card, "drank")
							use.card:setTag("drank", sgs.QVariant(use.from:getMark("drank")))
						end
						se.drank = use.card:getTag("drank"):toInt()
						room:slashEffect(se)
					end
				end
			end
		end
		return false
	end
}
keqiliubei:addSkill(keqizhenqiao)

keqizhenqiaoex = sgs.CreateAttackRangeSkill {
	name = "keqizhenqiaoex",
	extra_func = function(self, target)
		local n = 0
		if target:hasSkill("keqizhenqiao") then
			n = n + 1
		end
		return n
	end
}
if not sgs.Sanguosha:getSkill("keqizhenqiaoex") then skills:append(keqizhenqiaoex) end


keqisunjiantwo = sgs.General(extension, "keqisunjiantwo", "qun", 4)

keqipingtaoCard = sgs.CreateSkillCard {
	name = "keqipingtaoCard",
	target_fixed = false,
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:objectName() ~= sgs.Self:objectName())
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		--此为AI
		if (target:getState() ~= "online") and ((target:getHp() + target:getHp() + target:getCardCount()) <= 8)
			and (not target:isNude()) then
			local to_all = sgs.IntList()
			local to_throw = sgs.IntList()
			for _, c in sgs.qlist(target:getCards("he")) do
				to_all:append(c:getEffectiveId())
			end
			local rr = math.random(0, to_all:length() - 1)
			to_throw:append(to_all:at(rr))
			room:broadcastSkillInvoke("keqipingtao")
			player:obtainCard(sgs.Sanguosha:getCard(to_all:at(rr)))
		else
			local card = room:askForExchange(target, self:objectName(), 1, 1, true,
				"#keqipingtao:" .. player:getGeneralName(), true)
			if card then
				room:broadcastSkillInvoke("keqipingtao")
				room:obtainCard(player, card,
					sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), target:objectName(),
						self:objectName(), ""), false)
			else
				local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				slash:setSkillName("keqipingtao")
				local card_use = sgs.CardUseStruct()
				card_use.from = player
				card_use.to:append(target)
				card_use.card = slash
				room:useCard(card_use, false)
				slash:deleteLater()
			end
		end
	end
}

keqipingtao = sgs.CreateZeroCardViewAsSkill {
	name = "keqipingtao",
	enabled_at_play = function(self, player)
		return not player:hasUsed("#keqipingtaoCard")
	end,
	view_as = function()
		return keqipingtaoCard:clone()
	end
}
keqisunjiantwo:addSkill(keqipingtao)


keqijueliedistwoCard = sgs.CreateSkillCard {
	name = "keqijueliedistwoCard",
	target_fixed = true,
	mute = true,
	on_use = function(self, room, source, targets)
		if source:isAlive() then
			local num = self:subcardsLength()
			room:setPlayerMark(source, "keqijueliemarktwo", num)
			room:broadcastSkillInvoke("keqijuelietwo")
		end
	end
}

keqijuelietwoVS = sgs.CreateViewAsSkill {
	name = "keqijuelietwo",
	n = 999,
	response_pattern = "@@keqijuelietwo",
	view_filter = function(self, selected, to_select)
		return not sgs.Self:isJilei(to_select)
	end,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local dis_card = keqijueliedistwoCard:clone()
		for _, card in pairs(cards) do
			dis_card:addSubcard(card)
		end
		dis_card:setSkillName("keqijuelietwo")
		return dis_card
	end,
	enabled_at_play = function(self, player)
		return false
	end,
}

keqijuelietwo = sgs.CreateTriggerSkill {
	name = "keqijuelietwo",
	events = { sgs.DamageCaused, sgs.TargetSpecified, sgs.CardFinished },
	frequency = sgs.Skill_Frequent,
	view_as_skill = keqijuelietwoVS,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local room = player:getRoom()
		if (event == sgs.CardFinished) then
			local use = data:toCardUse()
			if use.card:hasFlag("newjueliecard") then
				for _, p in sgs.qlist(use.to) do
					room:setPlayerFlag(p, "-canjueliejiashang")
				end
			end
		end
		if (event == sgs.TargetSpecified) then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") then
				for _, p in sgs.qlist(use.to) do
					local to_data = sgs.QVariant()
					to_data:setValue(p)
					if not player:isNude() then
						local will_use = room:askForSkillInvoke(player, self:objectName(), to_data)
						if will_use then
							room:askForUseCard(player, "@@keqijuelietwo", "keqijuelie-ask")
							if (player:getMark("keqijueliemarktwo") > 0) then
								room:setCardFlag(use.card, "newjueliecard")
								room:setPlayerFlag(p, "canjueliejiashang")
								for i = 0, player:getMark("keqijueliemarktwo") - 1, 1 do
									if p:canDiscard(p, "he") then
										local to_throw = room:askForCardChosen(player, p, "he", self:objectName())
										local card = sgs.Sanguosha:getCard(to_throw)
										room:throwCard(card, p, player)
									end
								end
								room:setPlayerMark(player, "keqijueliemarktwo", 0)
							end
						end
					end
				end
			end
		end
		if (event == sgs.DamageCaused) then
			local damage = data:toDamage()
			if damage.card:isKindOf("Slash")
				and damage.to:hasFlag("canjueliejiashang")
				and damage.card:hasFlag("newjueliecard") then
				local hpyes = 1
				local spyes = 1
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getHp() < player:getHp()) then
						hpyes = 0
					end
					if (p:getHandcardNum() < player:getHandcardNum()) then
						spyes = 0
					end
				end
				if (hpyes == 1) or (spyes == 1) then
					local hurt = damage.damage
					damage.damage = hurt + 1
					data:setValue(damage)
				end
			end
		end
		return false
	end
}
keqisunjiantwo:addSkill(keqijuelietwo)


keqidongbai = sgs.General(extension, "keqidongbai", "qun", 3, false)

keqishichong = sgs.CreateTriggerSkill {
	name = "keqishichong",
	frequency = sgs.Skill_NotFrequent,
	change_skill = true,
	events = { sgs.TargetSpecified },
	on_trigger = function(self, event, player, data, room)
		if event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if (use.to:length() == 1) and (not use.to:contains(use.from)) and (not use.card:isKindOf("SkillCard")) then
				local target = use.to:at(0)
				local use = 0
				if (player:getChangeSkillState("keqishichong") == 1) then
					use = 1
					if (not target:isKongcheng()) and room:askForSkillInvoke(player, self:objectName(), data) then
						room:broadcastSkillInvoke(self:objectName())
						local log = sgs.LogMessage()
						log.type = "$keqishichonguse"
						log.from = player
						room:sendLog(log)
						room:setChangeSkillState(player, "keqishichong", 2)
						local card_id = room:askForCardChosen(player, target, "h", self:objectName())
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
						room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason,
							room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
					end
				else
					if (use == 0) and target:isYourFriend(player) and (target:getState() ~= "online") and (not target:isKongcheng()) then
						local card = room:askForExchange(target, self:objectName(), 1, 1, false,
							"#keqishichongg:" .. player:getGeneralName(), false)
						if card then
							room:broadcastSkillInvoke(self:objectName())
							local log = sgs.LogMessage()
							log.type = "$keqishichonguse"
							log.from = target
							room:sendLog(log)
							room:obtainCard(player, card,
								sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(),
									target:objectName(), self:objectName(), ""), false)
							room:setChangeSkillState(player, "keqishichong", 1)
						end
					else
						local card = room:askForExchange(target, self:objectName(), 1, 1, false,
							"#keqishichongg:" .. player:getGeneralName(), true)
						if card then
							room:broadcastSkillInvoke(self:objectName())
							local log = sgs.LogMessage()
							log.type = "$keqishichonguse"
							log.from = target
							room:sendLog(log)
							room:obtainCard(player, card,
								sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(),
									target:objectName(), self:objectName(), ""), false)
							room:setChangeSkillState(player, "keqishichong", 1)
						end
					end
				end
			end
		end
	end
}
keqidongbai:addSkill(keqishichong)



keqilianzhuCard = sgs.CreateSkillCard {
	name = "keqilianzhuCard",
	will_throw = false,
	filter = function(self, targets, to_select)
		return (to_select:objectName() ~= sgs.Self:objectName())
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		room:showCard(source, self:getSubcards():first())
		room:getThread():delay(800)
		target:obtainCard(self)
		local players = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if (p:getKingdom() == target:getKingdom()) and (p:objectName() ~= source:objectName()) then
				local dismantlement = sgs.Sanguosha:cloneCard("dismantlement", sgs.Card_NoSuit, 0)
				dismantlement:setSkillName("keqilianzhu")
				local card_use = sgs.CardUseStruct()
				card_use.from = source
				card_use.to:append(p)
				card_use.card = dismantlement
				room:useCard(card_use, false)
				dismantlement:deleteLater()
			end
		end
	end,
}
keqilianzhu = sgs.CreateViewAsSkill {
	name = "keqilianzhu",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isBlack() and (not sgs.Self:isJilei(to_select)) and (not to_select:isEquipped())
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local lzcard = keqilianzhuCard:clone()
		lzcard:addSubcard(cards[1])
		return lzcard
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#keqilianzhuCard")
	end
}
keqidongbai:addSkill(keqilianzhu)



keqihejin = sgs.General(extension, "keqihejin", "qun", 4)
keqizhaobing = sgs.CreateTriggerSkill {
	name = "keqizhaobing",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Finish) and (not player:isKongcheng()) then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					local num = player:getHandcardNum()
					player:throwAllHandCards()
					local targets = sgs.SPlayerList()
					if (player:getState() ~= "online") then
						--只针对敌人
						local aienys = sgs.SPlayerList()
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							if not p:isYourFriend(player) then
								aienys:append(p)
							end
						end
						targets = room:askForPlayersChosen(player, room:getOtherPlayers(player), self:objectName(),
							math.min(num, aienys:length()), num, "keqizhaobing-ask", false, true)
					else
						targets = room:askForPlayersChosen(player, room:getOtherPlayers(player), self:objectName(), 0,
							num, "keqizhaobing-ask", false, true)
					end
					for _, p in sgs.qlist(targets) do
						if (p:getState() ~= "online") then
							local give = 0
							if p:isYourFriend(player) or ((p:getHp() + p:getHp() + p:getCardCount()) <= 8) then
								for _, c in sgs.qlist(p:getCards("h")) do
									if (c:isKindOf("Slash")) then
										player:obtainCard(c)
										give = 1
										break
									end
								end
							end
							if (give == 0) then
								room:loseHp(p, 1, true, player)
							end
						else
							local pattern = {}
							for _, c in sgs.qlist(p:getCards("h")) do
								if (not target:isJilei(c)) and c:isKindOf("Slash") then
									table.insert(pattern, c:getEffectiveId())
								end
							end
							local card = room:askForExchange(p, self:objectName(), 1, 1, true,
								"#keqizhaobing:" .. player:getGeneralName(), true, table.concat(pattern, ","))
							if card then
								room:obtainCard(player, card,
									sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(),
										p:objectName(), self:objectName(), ""), false)
							else
								room:loseHp(p, 1, true, player)
							end
						end
					end
				end
			end
		end
	end,
}
keqihejin:addSkill(keqizhaobing)

keqizhuhuan = sgs.CreateTriggerSkill {
	name = "keqizhuhuan",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Start) then
				if (not player:isKongcheng()) and room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					room:showAllCards(player)
					local num = 0
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					for _, c in sgs.qlist(player:getCards("h")) do
						if c:isKindOf("Slash") then
							num = num + 1
							dummy:addSubcard(c:getId())
						end
					end
					room:throwCard(dummy, reason, player)
					dummy:deleteLater()
					local one = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(),
						"keqizhuhuan-ask", false, true)
					if (one:getState() ~= "online") then
						if one:isYourFriend(player) or ((one:getHp() + one:getHp() + one:getHandcardNum()) <= 7)
							or (player:isYourFriend(one)) or (one:getRole() == player:getRole())
							or ((not one:isYourFriend(player)) and (not player:isWounded())) then
							local recover = sgs.RecoverStruct()
							recover.who = player
							room:recover(player, recover)
							player:drawCards(num)
						else
							room:damage(sgs.DamageStruct(self:objectName(), player, one))
							if (one:getCardCount() <= num) then
								one:throwAllHandCardsAndEquips()
							else
								if (num > 0) then
									room:askForDiscard(one, self:objectName(), num, num, false, true,
										"keqizhuhuan-discardda")
								end
							end
						end
					else
						local result = room:askForChoice(one, self:objectName(), "getdamage+getrecover")
						if result == "getdamage" then
							room:damage(sgs.DamageStruct(self:objectName(), player, one))
							if (one:getCardCount() <= num) then
								one:throwAllHandCardsAndEquips()
							else
								room:askForDiscard(one, self:objectName(), num, num, false, true, "keqizhuhuan-discardda")
							end
						end
						if result == "getrecover" then
							local recover = sgs.RecoverStruct()
							recover.who = player
							room:recover(player, recover)
							player:drawCards(num)
						end
					end
				end
			end
		end
	end,
}
keqihejin:addSkill(keqizhuhuan)



keqiyanhuo = sgs.CreateTriggerSkill {
	name = "keqiyanhuo",
	global = true,
	events = { sgs.Death, sgs.DamageCaused },
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Death) then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then return false end
			if death.who:hasSkill(self:objectName()) then
				room:setTag("keqiyanhuonum", sgs.QVariant(1))
			end
		end
		if (event == sgs.DamageCaused) then
			local damage = data:toDamage()
			if (room:getTag("keqiyanhuonum"):toInt() == 1) and damage.card:isKindOf("Slash") then
				room:broadcastSkillInvoke(self:objectName())
				room:sendCompulsoryTriggerLog(damage.from, "keqiyanhuo")
				local hurt = damage.damage
				damage.damage = 1 + hurt
				data:setValue(damage)
			end
		end
	end
}
keqihejin:addSkill(keqiyanhuo)



keqihuangfusong = sgs.General(extension, "keqihuangfusong", "qun", 4)

keqiguanhuoCard = sgs.CreateSkillCard {
	name = "keqiguanhuoCard",
	target_fixed = false,
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		return (#targets < 1) and (not to_select:isKongcheng())
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		room:addPlayerMark(player, "usekeqiguanhuo-PlayClear", 1)
		local fire_attack = sgs.Sanguosha:cloneCard("fire_attack", sgs.Card_NoSuit, 0)
		fire_attack:setSkillName("keqiguanhuo")
		local card_use = sgs.CardUseStruct()
		card_use.from = player
		card_use.to:append(target)
		card_use.card = fire_attack
		room:useCard(card_use, false)
		fire_attack:deleteLater()
	end
}
--主技能
keqiguanhuoVS = sgs.CreateViewAsSkill {
	name = "keqiguanhuo",
	n = 0,
	view_as = function(self, cards)
		return keqiguanhuoCard:clone()
	end,
	enabled_at_play = function(self, player)
		return true
	end,
}
keqiguanhuo = sgs.CreateTriggerSkill {
	name = "keqiguanhuo",
	view_as_skill = keqiguanhuoVS,
	events = { sgs.CardUsed, sgs.Damage, sgs.CardFinished, sgs.DamageForseen },
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if use.card:isKindOf("FireAttack") and (use.card:getSkillName() == "keqiguanhuo") then
				room:setCardFlag(use.card, "keqiguanhuocard")
			end
		end
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if damage.card:hasFlag("keqiguanhuocard") then
				room:setCardFlag(damage.card, "-keqiguanhuocard")
				--FORAI
				if damage.from:getState() ~= "online" then
					for _, c in sgs.qlist(damage.from:getCards("h")) do
						if (c:getSuit() == sgs.Card_Spade) then room:setPlayerMark(damage.from, "keqiguanhuospade", 1) end
						if (c:getSuit() == sgs.Card_Club) then room:setPlayerMark(damage.from, "keqiguanhuoclub", 1) end
						if (c:getSuit() == sgs.Card_Heart) then room:setPlayerMark(damage.from, "keqiguanhuoheart", 1) end
						if (c:getSuit() == sgs.Card_Diamond) then room:setPlayerMark(damage.from, "keqiguanhuodiamond", 1) end
					end
					local num = (damage.from:getMark("keqiguanhuospade") + damage.from:getMark("keqiguanhuoclub") + damage.from:getMark("keqiguanhuoheart") + damage.from:getMark("keqiguanhuodiamond"))
					if (num >= 4) then
						room:setPlayerMark(damage.from, "aiguanhuo-PlayClear", 1)
					else
						room:setPlayerMark(damage.from, "aiguanhuo-PlayClear", 0)
					end
					room:setPlayerMark(damage.from, "keqiguanhuospade", 0)
					room:setPlayerMark(damage.from, "keqiguanhuoclub", 0)
					room:setPlayerMark(damage.from, "keqiguanhuoheart", 0)
					room:setPlayerMark(damage.from, "keqiguanhuodiamond", 0)
				end
				--end
			end
		end
		if (event == sgs.CardFinished) then
			local use = data:toCardUse()
			if use.card:hasFlag("keqiguanhuocard") then
				--FORAI
				if use.from:getState() ~= "online" then
					for _, c in sgs.qlist(use.from:getCards("h")) do
						if (c:getSuit() == sgs.Card_Spade) then room:setPlayerMark(use.from, "keqiguanhuospade", 1) end
						if (c:getSuit() == sgs.Card_Club) then room:setPlayerMark(use.from, "keqiguanhuoclub", 1) end
						if (c:getSuit() == sgs.Card_Heart) then room:setPlayerMark(use.from, "keqiguanhuoheart", 1) end
						if (c:getSuit() == sgs.Card_Diamond) then room:setPlayerMark(use.from, "keqiguanhuodiamond", 1) end
					end
					local num = (use.from:getMark("keqiguanhuospade") + use.from:getMark("keqiguanhuoclub") + use.from:getMark("keqiguanhuoheart") + use.from:getMark("keqiguanhuodiamond"))
					if (num >= 4) then
						room:setPlayerMark(use.from, "aiguanhuo-PlayClear", 1)
					else
						room:setPlayerMark(use.from, "aiguanhuo-PlayClear", 0)
					end
					room:setPlayerMark(use.from, "keqiguanhuospade", 0)
					room:setPlayerMark(use.from, "keqiguanhuoclub", 0)
					room:setPlayerMark(use.from, "keqiguanhuoheart", 0)
					room:setPlayerMark(use.from, "keqiguanhuodiamond", 0)
				end
				--end
				if use.from:hasSkill(self:objectName()) then
					if (use.from:getMark("usekeqiguanhuo-PlayClear") == 1) then
						room:setPlayerMark(use.from, "&usekeqiguanhuoda-PlayClear", 1)
					elseif (use.from:getMark("usekeqiguanhuo-PlayClear") > 1) then
						room:handleAcquireDetachSkills(use.from, "-keqiguanhuo")
					end
				end
			end
		end
		if (event == sgs.DamageForseen) then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("FireAttack") and (damage.from:getMark("&usekeqiguanhuoda-PlayClear") > 0) then
				room:broadcastSkillInvoke(self:objectName())
				room:sendCompulsoryTriggerLog(damage.from, "keqiguanhuo")
				local hurt = damage.damage
				damage.damage = 1 + hurt
				data:setValue(damage)
			end
		end
	end,
}
keqihuangfusong:addSkill(keqiguanhuo)


keqijuxia = sgs.CreateTriggerSkill {
	name = "keqijuxia",
	events = { sgs.TargetConfirmed },
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local room = player:getRoom()
		if (event == sgs.TargetConfirmed) and use.to:contains(player)
			and (player:getMark("&usekeqijuxia-Clear") == 0) and (player:objectName() ~= use.from:objectName()) then
			local skill_listuse = {}
			local skill_listplayer = {}
			for _, skill in sgs.qlist(use.from:getVisibleSkillList()) do
				if (not table.contains(skill_listuse, skill:objectName())) and not skill:isAttachedLordSkill() then
					table.insert(skill_listuse, skill:objectName())
				end
			end
			for _, skill in sgs.qlist(player:getVisibleSkillList()) do
				if (not table.contains(skill_listplayer, skill:objectName())) and not skill:isAttachedLordSkill() then
					table.insert(skill_listplayer, skill:objectName())
				end
			end
			local numuse = #skill_listuse
			local numplayer = #skill_listplayer
			if (numuse > numplayer) then
				if (use.from:getState() ~= "online") then
					if use.from:isYourFriend(player) or player:isYourFriend(use.from) then
						room:broadcastSkillInvoke(self:objectName())
						room:setPlayerMark(player, "&usekeqijuxia-Clear", 1)
						local nullified_list = use.nullified_list
						table.insert(nullified_list, player:objectName())
						use.nullified_list = nullified_list
						data:setValue(use)
						player:drawCards(2)
					end
				else
					if use.from:askForSkillInvoke(self, ToData("keqijuxia-pre:" .. player:objectName())) then
						room:broadcastSkillInvoke(self:objectName())
						room:setPlayerMark(player, "&usekeqijuxia-Clear", 1)
						local nullified_list = use.nullified_list
						table.insert(nullified_list, player:objectName())
						use.nullified_list = nullified_list
						data:setValue(use)
						player:drawCards(2)
					end
				end
			end
		end
	end
}
keqihuangfusong:addSkill(keqijuxia)



keqikongrong = sgs.General(extension, "keqikongrong", "qun", 3)


keqilirang = sgs.CreateTriggerSkill {
	name = "keqilirang",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart, sgs.EventPhaseEnd, sgs.CardsMoveOneTime },
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Draw) then
				local krs = room:findPlayersBySkillName(self:objectName())
				local yes = 1
				for _, kr in sgs.qlist(krs) do
					if (kr:getMark("bankeqilirang_lun") == 0) and (yes == 1)
						and (not (kr:objectName() == player:objectName()))
						and (kr:getCardCount() >= 2) then
						if kr:getState() == "online" then
							local card = room:askForExchange(kr, self:objectName(), 2, 2, true,
								"#keqilirang:" .. player:getGeneralName(), true)
							if card then
								room:broadcastSkillInvoke(self:objectName())
								local log = sgs.LogMessage()
								log.type = "$keqiliranggeipai"
								log.from = kr
								room:sendLog(log)
								room:setPlayerMark(kr, "bankeqilirang_lun", 1)
								room:obtainCard(player, card,
									sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(),
										kr:objectName(), self:objectName(), ""), false)
								room:setPlayerMark(player, "beusekeqilirang", 1)
								room:setPlayerMark(kr, "usingkeqilirang", 1)
								--这个轮标记是为了给“名仕”的
								room:setPlayerMark(player, "&mskeqilirang_lun", 1)
								room:setPlayerMark(kr, "&msusekeqilirang_lun", 1)
								yse = 0
							end
						else
							--[[if (kr:getRole() == player:getRole())
							or ((kr:getRole() == "lord") and(player:getRole() == "loyalist"))
							or ((player:getRole() == "lord") and(kr:getRole() == "loyalist"))
							or (((player:getRole() == "lord") and(kr:getRole() == "renegade")) and (player:getHp()+player:getHp()+player:getHandcardNum() < 8 ))
							or (((kr:getRole() == "lord") and (player:getRole() == "renegade")) and (kr:getHp()+kr:getHp()+kr:getHandcardNum() < 8 ))then]]
							if kr:isYourFriend(player) and player:isYourFriend(kr) then
								room:setPlayerFlag(kr, "aiuselirang")
							end
							if room:askForSkillInvoke(kr, "keqilirang_use", data) then
								room:setPlayerFlag(kr, "-aiuselirang")
								local card = room:askForExchange(kr, self:objectName(), 2, 2, true,
									"#keqilirang:" .. player:getGeneralName(), true)
								if card then
									room:broadcastSkillInvoke(self:objectName())
									local log = sgs.LogMessage()
									log.type = "$keqiliranggeipai"
									log.from = kr
									room:sendLog(log)
									room:setPlayerMark(kr, "bankeqilirang_lun", 1)
									room:obtainCard(player, card,
										sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(),
											kr:objectName(), self:objectName(), ""), false)
									room:setPlayerMark(player, "beusekeqilirang", 1)
									room:setPlayerMark(kr, "usingkeqilirang", 1)
									--这个轮标记是为了给“名仕”的
									room:setPlayerMark(player, "&mskeqilirang_lun", 1)
									room:setPlayerMark(kr, "&msusekeqilirang_lun", 1)
									yse = 0
								end
							end
						end
					end
				end
			end
		end
		if (event == sgs.CardsMoveOneTime) then
			local kongrong = room:findPlayerBySkillName(self:objectName())
			local current = room:getCurrent()
			local move = data:toMoveOneTime()
			local source = move.from
			if source and (source:getMark("beusekeqilirang") > 0) then
				if player:objectName() == source:objectName() then
					if kongrong and (kongrong:objectName() ~= current:objectName()) then
						if (current:getPhase() == sgs.Player_Discard) then
							local tag = room:getTag("lirangToGet")
							local lirangToGet = tag:toString()
							if lirangToGet == nil then
								lirangToGet = ""
							end
							for _, card_id in sgs.qlist(move.card_ids) do
								local flag = bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
								if flag == sgs.CardMoveReason_S_REASON_DISCARD then
									if source:objectName() == current:objectName() then
										if lirangToGet == "" then
											lirangToGet = tostring(card_id)
										else
											lirangToGet = lirangToGet .. "+" .. tostring(card_id)
										end
									end
								end
							end
							if lirangToGet then
								room:setTag("lirangToGet", sgs.QVariant(lirangToGet))
							end
						end
					end
				end
			end
		end
		if (event == sgs.EventPhaseEnd) then
			if (player:getPhase() == sgs.Player_Discard) then
				for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					if (p:getMark("usingkeqilirang") > 0) then
						local kongrong = p
						if kongrong then
							local tag = room:getTag("lirangToGet")
							local lirang_cardsToGet
							if tag then
								lirang_cardsToGet = tag:toString():split("+")
							else
								return false
							end
							room:removeTag("lirangToGet")
							local cardsToGet = sgs.IntList()
							local cards = sgs.IntList()
							for i = 1, #lirang_cardsToGet, 1 do
								local card_data = lirang_cardsToGet[i]
								if card_data == nil then return false end
								if card_data ~= "" then --弃牌阶段没弃牌则字符串为""
									local card_id = tonumber(card_data)
									if room:getCardPlace(card_id) == sgs.Player_DiscardPile then
										cardsToGet:append(card_id)
										cards:append(card_id)
									end
								end
							end
							if cardsToGet:length() > 0 then
								if room:askForSkillInvoke(kongrong, "keqilirang_get", data) then
									room:broadcastSkillInvoke(self:objectName())
									local move = sgs.CardsMoveStruct()
									move.card_ids = cards
									move.to = kongrong
									move.to_place = sgs.Player_PlaceHand
									room:moveCardsAtomic(move, true)
								end
							end
						end
						break
					end
				end
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getMark("beusekeqilirang") > 0 then
						room:setPlayerMark(p, "beusekeqilirang", 0)
					end
					if p:getMark("usingkeqilirang") > 0 then
						room:setPlayerMark(p, "usingkeqilirang", 0)
					end
				end
			end
		end
	end
}
keqikongrong:addSkill(keqilirang)

keqimingshi = sgs.CreateTriggerSkill {
	name = "keqimingshi",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.DamageInflicted, sgs.Damage },
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.DamageInflicted) then
			local damage = data:toDamage()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if (p:getMark("&mskeqilirang_lun") > 0)
					and (damage.to:getMark("&msusekeqilirang_lun") > 0)
					and (damage.to:getMark("banmingshi-Clear") == 0) then
					--本回合禁用！
					room:setPlayerMark(damage.to, "banmingshi-Clear", 1)
					if (p:getState() ~= "online") then
						if (p:isYourFriend(damage.to) and damage.to:isYourFriend(p) and ((p:getHp() + p:getHp() + p:getCardCount()) > 8))
							or ((damage.to:getRole() == "lord") and (p:getRole() == "loyalist") and ((damage.to:getHp() + damage.to:getHp() + damage.to:getCardCount()) <= (damage.to:getHp() + damage.to:getHp() + damage.to:getCardCount())))
							or ((damage.to:getRole() == "lord") and (p:getRole() == "renegade") and ((damage.to:getHp() + damage.to:getHp() + damage.to:getCardCount()) <= 7)) then
							room:broadcastSkillInvoke(self:objectName())
							damage.to = p
							damage.transfer = true
							data:setValue(damage)
							local log = sgs.LogMessage()
							log.type = "$keqimingshitran"
							log.from = p
							room:sendLog(log)
						end
					else
						local to_data = sgs.QVariant()
						to_data:setValue(damage.to)
						local will_use = room:askForSkillInvoke(p, self:objectName(), to_data)
						if will_use then
							room:broadcastSkillInvoke(self:objectName())
							damage.to = p
							damage.transfer = true
							data:setValue(damage)
							local log = sgs.LogMessage()
							log.type = "$keqimingshitran"
							log.from = p
							room:sendLog(log)
						end
					end
				end
			end
		end
	end,
}
keqikongrong:addSkill(keqimingshi)



keqiliuhong = sgs.General(extension, "keqiliuhong$", "qun", 4)

keqichaozheng = sgs.CreateTriggerSkill {
	name = "keqichaozheng",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart },
	--view_as_skill = keqichaozhengVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Start) then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					--For AI
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						--统计一下是否有队友需要回血
						local eny = 0
						local fri = 0
						for _, oth in sgs.qlist(room:getOtherPlayers(p)) do
							if oth:isYourFriend(p) and ((oth:getHp() + oth:getHp() + oth:getCardCount()) <= 8) then
								fri =
									fri + 1
							else
								eny = eny + 1
							end
						end
						if ((p:getHp() + p:getHp() + p:getCardCount()) <= 8) or (fri >= eny) then
							room:setPlayerFlag(p, "chaozhengwantred")
							--[[for _,c in sgs.qlist(p:getCards("h")) do
								if c:isRed() then
									room:setCardFlag(c,"chaozhengred")
								end
							end]]
						else
							room:setPlayerFlag(p, "chaozhengwantblack")
							--[[for _,c in sgs.qlist(p:getCards("h")) do
								if c:isBlack() then
									room:setCardFlag(c,"chaozhengblack")
								end
							end]]
						end
					end
					--议事
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						room:setPlayerMark(p, "keyishiing", 1)
						--每个人提前挑选牌准备展示
						if not p:isKongcheng() then
							local id = room:askForExchange(p, "keqichaozheng", 1, 1, false, "keqichaozheng_yishi")
								:getSubcards():first()
							--local id = room:askForCardChosen(p, p, "h", "keqichaozheng_yishi", false, sgs.Card_MethodNone, sgs.IntList(), false)
							local card = sgs.Sanguosha:getCard(id)
							room:setCardFlag(card, "useforyishi")
							if card:isRed() then
								room:setPlayerMark(p, "keyishi_red", 1)
							elseif card:isBlack() then
								room:setPlayerMark(p, "keyishi_black", 1)
							end
							--标记选择了牌的人（没有空城的人）
							room:setPlayerMark(p, "chooseyishi", 1)
						end
					end
					--依次展示选好的牌，公平公正公开
					room:getThread():delay(800)
					local yishirednum = 0
					local yishiblacknum = 0
					for _, p in sgs.qlist(room:getAllPlayers()) do
						for _, c in sgs.qlist(p:getCards("h")) do
							if c:hasFlag("useforyishi") then
								if c:isRed() then yishirednum = yishirednum + 1 end
								if c:isBlack() then yishiblacknum = yishiblacknum + 1 end
								room:showCard(p, c:getEffectiveId())
								room:setCardFlag(c, "-useforyishi")
								break
							end
						end
					end
					room:getThread():delay(1200)
					--0为平局（默认），1：红色；2：黑色
					local yishiresult = 0
					if (yishirednum > yishiblacknum) then
						yishiresult = 1
						local log = sgs.LogMessage()
						log.type = "$keyishired"
						log.from = player
						room:sendLog(log)
						room:doLightbox("$keyishired")
					elseif (yishirednum < yishiblacknum) then
						yishiresult = 2
						local log = sgs.LogMessage()
						log.type = "$keyishiblack"
						log.from = player
						room:sendLog(log)
						room:doLightbox("$keyishiblack")
					elseif (yishirednum == yishiblacknum) then
						yishiresult = 0
						local log = sgs.LogMessage()
						log.type = "$keyishipingju"
						log.from = player
						room:sendLog(log)
						room:doLightbox("$keyishipingju")
					end
					--朝争效果：
					if (yishiresult == 1) then
						for _, p in sgs.qlist(room:getAllPlayers()) do
							if (p:getMark("keyishi_red") > 0) then
								room:recover(p, sgs.RecoverStruct())
							end
						end
					elseif (yishiresult == 2) then
						for _, p in sgs.qlist(room:getAllPlayers()) do
							if (p:getMark("keyishi_red") > 0) then
								room:loseHp(p, 1, true, player)
							end
						end
					end
					--开始清理标记
					for _, p in sgs.qlist(room:getAllPlayers()) do
						if (p:getMark("keyishiing") > 0) then room:setPlayerMark(p, "keyishiing", 0) end
						if (p:getMark("chooseyishi") > 0) then room:setPlayerMark(p, "chooseyishi", 0) end
					end
					for _, p in sgs.qlist(room:getAllPlayers()) do
						if (p:getMark("keyishi_red") > 0) then room:setPlayerMark(p, "keyishi_red", 0) end
						if (p:getMark("keyishi_black") > 0) then room:setPlayerMark(p, "keyishi_black", 0) end
					end
					--结束后朝争效果
					if (yishirednum == 0) then
						player:drawCards(yishiblacknum)
					elseif (yishiblacknum == 0) then
						player:drawCards(yishirednum)
					end
					--清除ai
					for _, p in sgs.qlist(room:getAllPlayers()) do
						--[[for _,c in sgs.qlist(p:getCards("h")) do
							room:setCardFlag(c,"-chaozhengred")
							room:setCardFlag(c,"-chaozhengblack")
						end	]]
						room:setPlayerFlag(p, "-chaozhengwantblack")
						room:setPlayerFlag(p, "-chaozhengwantred")
					end
				end
			end
		end
	end,
}
keqiliuhong:addSkill(keqichaozheng)


keqishenchongCard = sgs.CreateSkillCard {
	name = "keqishenchongCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:objectName() ~= sgs.Self:objectName())
	end,
	on_use = function(self, room, player, targets)
		room:removePlayerMark(player, "@keqishenchong")
		room:doSuperLightbox("keqiliuhong", "keqishenchong")
		local target = targets[1]
		room:setPlayerMark(player, "useshenchong", 1)
		room:setPlayerMark(target, "beuseshenchong", 1)
		room:handleAcquireDetachSkills(target, "feiyang|bahu")
	end
}

keqishenchongVS = sgs.CreateZeroCardViewAsSkill {
	name = "keqishenchong",
	frequency = sgs.Skill_Limited,
	limit_mark = "@keqishenchong",
	enabled_at_play = function(self, player)
		return (player:getMark("@keqishenchong") > 0)
	end,
	view_as = function()
		return keqishenchongCard:clone()
	end
}
keqishenchong = sgs.CreateTriggerSkill {
	name = "keqishenchong",
	frequency = sgs.Skill_Limited,
	limit_mark = "@keqishenchong",
	view_as_skill = keqishenchongVS,
	events = { sgs.Death },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() then
			return false
		end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if (p:getMark("beuseshenchong") > 0) then
				room:broadcastSkillInvoke(self:objectName())
				room:sendCompulsoryTriggerLog(p, self:objectName())
				local skills = p:getVisibleSkillList()
				local detachList = {}
				for _, skill in sgs.qlist(skills) do
					if not skill:inherits("SPConvertSkill") and not skill:isAttachedLordSkill() then
						table.insert(detachList, "-" .. skill:objectName())
					end
				end
				room:handleAcquireDetachSkills(p, table.concat(detachList, "|"))
				p:throwAllHandCards()
				if p:isAlive() then
					room:setPlayerMark(p, "&keqishenchong", 1)
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target and target:hasSkill(self:objectName())
	end
}
keqiliuhong:addSkill(keqishenchong)


keqijulian = sgs.CreateTriggerSkill {
	name = "keqijulian$",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.CardsMoveOneTime, sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data, room)
		if (event == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if move.to and move.to:objectName() == player:objectName()
				and (player:getKingdom() == "qun") and (player:getRole() ~= "lord") then
				local zhugong = room:findPlayerBySkillName(self:objectName())
				if (zhugong:getRole() == "lord") then
					if (player:getPhase() ~= sgs.Player_Draw) and (move.reason.m_skillName ~= "keqijulian")
						and (player:getKingdom() == "qun") and (player:getPhase() ~= sgs.Player_NotActive) then
						for _, id in sgs.qlist(move.card_ids) do
							if room:getCardOwner(id):objectName() == player:objectName() and room:getCardPlace(id) == sgs.Player_PlaceHand then
								if (player:getMark("usekeqijulian-Clear") < 2) and room:askForSkillInvoke(player, self:objectName(), data) then
									room:broadcastSkillInvoke("keqichaozheng")
									room:addPlayerMark(player, "usekeqijulian-Clear")
									local log = sgs.LogMessage()
									log.type = "$keqijulianmopai"
									log.from = player
									room:sendLog(log)
									player:drawCards(1, self:objectName())
									break
								end
							end
						end
					end
				end
			end
		end
		if (event == sgs.EventPhaseStart) and player:hasLordSkill(self:objectName())
			and (player:getPhase() == sgs.Player_Finish) then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke("keqichaozheng")
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if (p:getKingdom() == "qun") and (not p:isKongcheng()) then
						local card_id = room:askForCardChosen(player, p, "h", self:objectName())
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
						room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason,
							room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}
keqiliuhong:addSkill(keqijulian)


keqiliuyan = sgs.General(extension, "keqiliuyan$", "qun", 3)

--[[
keqilimuCard = sgs.CreateSkillCard{
	name = "keqilimuCard",
	target_fixed = true,
	will_throw = false,
	about_to_use = function(self, room, use)
		local c = sgs.Sanguosha:getCard(self:getSubcards():first())
		local card = sgs.Sanguosha:cloneCard("indulgence", c:getSuit(), c:getNumber())
		card:addSubcard(c:getEffectiveId())
		card:setSkillName(self:getSkillName())
		room:useCard(sgs.CardUseStruct(card, use.from, use.from), true)
		room:recover(use.from, sgs.RecoverStruct(use.from))	
	end
}
keqilimu = sgs.CreateOneCardViewAsSkill{
	name = "keqilimu",
	filter_pattern = ".|diamond|.|.",
	response_or_use = true,
	view_as = function(self, card)
		local lm = keqilimuCard:clone()
		lm:addSubcard(card:getEffectiveId())
		lm:setSkillName(self:objectName())
		return lm
	end,
	enabled_at_play = function(self, player)
		local card = sgs.Sanguosha:cloneCard("indulgence")
		card:deleteLater()
		return not player:containsTrick("indulgence") and not player:isProhibited(player, card)
	end
}
keqiliuyan:addSkill(keqilimu)]]
keqiliuyan:addSkill("limu")

keqitushe = sgs.CreateTriggerSkill {
	name = "keqitushe",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.TargetSpecified },
	on_trigger = function(self, event, player, data, room)
		local use = data:toCardUse()
		if not use.to:isEmpty() and not use.card:isKindOf("EquipCard") and not use.card:isKindOf("SkillCard") then
			if (player:getState() ~= "online") then
				local yes = 1
				for _, p in sgs.qlist(player:getCards("h")) do
					if p:isKindOf("BasicCard") then
						yes = 0
					end
				end
				if (yes == 1) then
					room:showAllCards(player)
					room:broadcastSkillInvoke(self:objectName())
					player:drawCards(use.to:length(), self:objectName())
				end
			else
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					room:showAllCards(player)
					local yes = 1
					for _, p in sgs.qlist(player:getCards("h")) do
						if p:isKindOf("BasicCard") then
							yes = 0
						end
					end
					if (yes == 1) then
						player:drawCards(use.to:length(), self:objectName())
					end
				end
			end
		end
	end
}
keqiliuyan:addSkill(keqitushe)

keqitongjueCard = sgs.CreateSkillCard {
	name = "keqitongjueCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, selected, to_select)
		return (#selected == 0) and (to_select:objectName() ~= sgs.Self:objectName()) and
			(to_select:getKingdom() == "qun")
	end,
	on_use = function(self, room, source, targets)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(), targets[1]:objectName(),
			"keqitongjue", "")
		room:obtainCard(targets[1], self, reason, false)
		room:setPlayerMark(source, "usekeqitongjue-Clear", 1)
		room:setPlayerMark(targets[1], "beusekeqitongjue-Clear", 1)
	end
}
keqitongjue = sgs.CreateViewAsSkill {
	name = "keqitongjue$",
	n = 999,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local rende_card = keqitongjueCard:clone()
		for _, c in ipairs(cards) do
			rende_card:addSubcard(c)
		end
		return rende_card
	end,
	enabled_at_play = function(self, player)
		return not (player:isKongcheng() or player:hasUsed("#keqitongjueCard"))
	end
}
keqiliuyan:addSkill(keqitongjue)

keqitongjueex = sgs.CreateProhibitSkill {
	name = "keqitongjueex",
	is_prohibited = function(self, from, to, card)
		return ((from:getMark("usekeqitongjue-Clear") > 0) and (to:getMark("beusekeqitongjue-Clear") > 0)) and
			(not card:isKindOf("SkillCard"))
	end
}
if not sgs.Sanguosha:getSkill("keqitongjueex") then skills:append(keqitongjueex) end




--南华老仙

keqinanhualaoxiantwo = sgs.General(extension, "keqinanhualaoxiantwo", "qun", 3)

keqitaipingyaoshupro = sgs.CreateProhibitSkill {
	name = "keqitaipingyaoshupro",
	is_prohibited = function(self, from, to, card)
		return (from:getState() ~= "online") and (card:isKindOf("ThunderSlash") or card:isKindOf("FireSlash")) and
			(to:getArmor() ~= nil) and (to:getArmor():objectName() == "_keqi_taipingyaoshu")
	end
}
if not sgs.Sanguosha:getSkill("keqitaipingyaoshupro") then skills:append(keqitaipingyaoshupro) end

--装备技能
keqitaipingyaoshuskill = sgs.CreateTriggerSkill {
	name = "keqitaipingyaoshuskill",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.DamageInflicted },
	can_trigger = function(self, target)
		return target and target:hasArmorEffect("_keqi_taipingyaoshu")
	end,
	on_trigger = function(self, event, player, data, room)
		if (event == sgs.DamageInflicted) then
			local damage = data:toDamage()
			if (damage.nature ~= sgs.DamageStruct_Normal) then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				return true
			end
		end
	end
}
if not sgs.Sanguosha:getSkill("keqitaipingyaoshuskill") then skills:append(keqitaipingyaoshuskill) end
--装备
KQTaipingyaoshu = sgs.CreateArmor {
	name = "_keqi_taipingyaoshu",
	class_name = "KQTaipingyaoshu",
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, keqitaipingyaoshuskill, false, true, false)
		return false
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		player:drawCards(2)
		if (player:getHp() > 1) then
			room:loseHp(player, 1, true)
		end
		room:detachSkillFromPlayer(player, "keqitaipingyaoshuskill", true, true)
		return false
	end,
}

--KQTaipingyaoshu:setParent(extension)
--加入一张牌
--for i=0,200,1 do
local card = KQTaipingyaoshu:clone()
card:setSuit(2)
card:setNumber(3)
card:setParent(extension)
--end

keqishoushukeep = sgs.CreateMaxCardsSkill {
	name = "keqishoushukeep",
	frequency = sgs.Skill_Frequent,
	extra_func = function(self, target)
		if (target:getArmor() ~= nil) then
			if (target:getArmor():objectName() == "_keqi_taipingyaoshu") then
				local players = sgs.SPlayerList()
				local num = 1
				for _, p in sgs.qlist(target:getAliveSiblings()) do
					if not players:isEmpty() then
						for _, pp in sgs.qlist(players) do
							if (p:getKingdom() ~= pp:getKingdom()) then
								num = num + 1
							end
						end
						players:append(p)
					else
						num = num + 1
					end
				end
				return math.max(num - 1, 0)
			end
		end
	end
}
if not sgs.Sanguosha:getSkill("keqishoushukeep") then skills:append(keqishoushukeep) end

function kedestroyEquip(room, move, tag_name) --销毁装备
	local id = room:getTag(tag_name):toInt()
	if id > 0 and move.card_ids:contains(id) then
		local move1 = sgs.CardsMoveStruct(id, nil, nil, room:getCardPlace(id), sgs.Player_PlaceTable,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, "destroy_equip", ""))
		local card = sgs.Sanguosha:getCard(id)
		local log = sgs.LogMessage()
		log.type = "#keDestroyEqiup"
		log.card_str = card:toString()
		room:sendLog(log)
		room:moveCardsAtomic(move1, true)
		room:removeTag(card:getClassName())
	end
end

--武将技能
keqishoushutwo = sgs.CreateTriggerSkill {
	name = "keqishoushutwo",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.RoundStart, sgs.CardsMoveOneTime, sgs.GameStart },
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if (move.from and (move.from:objectName() == player:objectName())
					and (move.from_places:contains(sgs.Player_PlaceHand)
						or move.from_places:contains(sgs.Player_PlaceEquip))) then
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("KQTaipingyaoshu") then
						kedestroyEquip(room, move, "KE_tpys")
					end
				end
			end
		end
		if (event == sgs.GameStart) and player:hasSkill(self:objectName()) then
			local yes = 1
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if (p:getArmor() ~= nil) then
					if (p:getArmor():objectName() == "_keqi_taipingyaoshu") then
						yes = 0
						break
					end
				end
			end
			if (yes == 1) then
				local target = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName(), "keqishoushu-ask",
					false, true)
				if target then
					room:broadcastSkillInvoke(self:objectName())
					--if (target:getArmor() ~= nil) then
					for _, c in sgs.qlist(target:getCards("e")) do
						if c:isKindOf("Armor") then
							room:throwCard(c, target)
						end
					end
					--end
					local cards = sgs.IntList()
					for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
						if sgs.Sanguosha:getEngineCard(id):isKindOf("KQTaipingyaoshu") and (room:getCardPlace(id) ~= sgs.Player_DrawPile)
							and (room:getCardPlace(id) ~= sgs.Player_PlaceHand) and (room:getCardPlace(id) ~= sgs.Player_PlaceEquip) then
							cards:append(id)
							break
						end
					end
					if not cards:isEmpty() then
						room:setTag("KE_tpys", sgs.QVariant(cards:at(0)))
						--room:shuffleIntoDrawPile(target, cards, self:objectName(), true)
						local thecard = sgs.Sanguosha:getCard(cards:at(0))
						room:moveCardTo(thecard, target, sgs.Player_PlaceEquip)
					end
				end
			end
		end
	end,
}
keqinanhualaoxiantwo:addSkill(keqishoushutwo)

sgs.LoadTranslationTable {
	["keqijsrgcard"] = "江山如故",

	["_keqi_taipingyaoshu"] = "太平要术",
	[":_keqi_taipingyaoshu"] = "装备牌·防具<br /><b>防具技能</b>：锁定技，防止你受到的属性伤害；你的手牌上限+X（X为场上势力数-1）；当你失去装备区里的【太平要术】后，你摸两张牌，然后若你的体力值大于1，你失去1点体力。",

}

keqiwendaotwo = sgs.CreateTriggerSkill {
	name = "keqiwendaotwo",
	events = { sgs.AskForRetrial },
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local judge = data:toJudge()
		if (judge.who:objectName() == player:objectName()) then
			local players = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if not p:isNude() then
					players:append(p)
				end
			end
			if player:getState() == "online" then
				local daomeidans = room:askForPlayersChosen(player, players, self:objectName(), 0, 2, "keqiwendao-ask",
					false, true)
				if (daomeidans:length() > 0) then room:broadcastSkillInvoke(self:objectName()) end
				local to_throw = sgs.IntList()
				for _, p in sgs.qlist(daomeidans) do
					local card = room:askForDiscard(p, self:objectName(), 1, 1, false, true, "keqiwendao-discard")
					to_throw:append(card:getEffectiveId())
				end
				if not to_throw:isEmpty() then
					room:fillAG(to_throw)
					local to_get = sgs.IntList()
					local card_id = room:askForAG(player, to_throw, false, self:objectName(), "keqiwendao-choice")
					room:clearAG()
					room:retrial(sgs.Sanguosha:getCard(card_id), player, judge, self:objectName())
				end
			else
				if room:askForSkillInvoke(player, self:objectName(), data) then
					local daomeidans = room:askForPlayersChosen(player, players, self:objectName(), 0, 2,
						"keqiwendao-ask", false, true)
					if (daomeidans:length() > 0) then room:broadcastSkillInvoke(self:objectName()) end
					local to_throw = sgs.IntList()
					for _, p in sgs.qlist(daomeidans) do
						local card = room:askForDiscard(p, self:objectName(), 1, 1, false, true, "keqiwendao-discard")
						to_throw:append(card:getEffectiveId())
					end
					if not to_throw:isEmpty() then
						room:fillAG(to_throw)
						local to_get = sgs.IntList()
						local card_id = room:askForAG(player, to_throw, false, self:objectName(), "keqiwendao-choice")
						room:clearAG()
						room:retrial(sgs.Sanguosha:getCard(card_id), player, judge, self:objectName())
					end
				end
			end
		end
	end
}
keqinanhualaoxiantwo:addSkill(keqiwendaotwo)

keqixuanhuatwo = sgs.CreateTriggerSkill {
	name = "keqixuanhuatwo",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart, sgs.Damaged },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Damaged) then
			local damage = data:toDamage()
			if (damage.reason == self:objectName()) then
				room:setPlayerMark(player, "keqixuanhuahit", 1)
			end
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Start) then
				if room:askForSkillInvoke(player, "keqixuanhuatwofirst", data) then
					room:broadcastSkillInvoke(self:objectName())
					local room = player:getRoom()
					local judge = sgs.JudgeStruct()
					judge.pattern = ".|spade|2,3,4,5,6,7,8,9|."
					judge.good = true
					judge.play_animation = true
					judge.reason = self:objectName()
					judge.who = player
					room:judge(judge)
					if judge:isGood() then
						local damage = sgs.DamageStruct()
						damage.to = player
						damage.damage = 3
						damage.reason = self:objectName()
						damage.nature = sgs.DamageStruct_Thunder
						room:damage(damage)
					end
					if (player:getMark("keqixuanhuahit") == 0) then
						local target = room:askForPlayerChosen(player, room:getAllPlayers(), "keqixuanhuaco_ask",
							"keqixuanhuaco-ask", true, true)
						if target then
							room:recover(target, sgs.RecoverStruct())
						end
					end
					room:setPlayerMark(player, "keqixuanhuahit", 0)
				end
			end
			if (player:getPhase() == sgs.Player_Finish) then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					local room = player:getRoom()
					local judge = sgs.JudgeStruct()
					judge.pattern = ".|spade|2,3,4,5,6,7,8,9|."
					judge.good = false
					judge.play_animation = true
					judge.reason = self:objectName()
					judge.who = player
					room:judge(judge)
					if judge:isGood() then
						local damage = sgs.DamageStruct()
						damage.to = player
						damage.damage = 3
						damage.reason = self:objectName()
						damage.nature = sgs.DamageStruct_Thunder
						room:damage(damage)
					end
					if (player:getMark("keqixuanhuahit") == 0) then
						local target = room:askForPlayerChosen(player, room:getAllPlayers(), "keqixuanhuada_ask",
							"keqixuanhuada-ask", true, true)
						if target then
							local damagee = sgs.DamageStruct()
							damagee.to = target
							damagee.from = player
							damagee.damage = 1
							damagee.reason = self:objectName()
							damagee.nature = sgs.DamageStruct_Thunder
							room:damage(damagee)
						end
					end
					room:setPlayerMark(player, "keqixuanhuahit", 0)
				end
			end
		end
	end,
}

keqinanhualaoxiantwo:addSkill(keqixuanhuatwo)



--桥玄
keqiqiaoxuan = sgs.General(extension, "keqiqiaoxuan", "qun", 3)

keqijuezhi = sgs.CreateTriggerSkill {
	name = "keqijuezhi",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.CardsMoveOneTime, sgs.DamageCaused, sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) then
			room:setPlayerMark(player, "canusekeqijuezhi", 1)
		end
		if (event == sgs.DamageCaused) then
			local damage = data:toDamage()
			if damage.card and (damage.from:objectName() == player:objectName())
				and (player:getPhase() ~= sgs.Player_NotActive) and (player:getMark("canusekeqijuezhi") > 0) then
				local gain = 0
				if (not player:hasEquipArea(0)) and (damage.to:getWeapon() ~= nil) then gain = gain + 1 end
				if (not player:hasEquipArea(1)) and (damage.to:getArmor() ~= nil) then gain = gain + 1 end
				if (not player:hasEquipArea(2)) and (damage.to:getDefensiveHorse() ~= nil) then gain = gain + 1 end
				if (not player:hasEquipArea(3)) and (damage.to:getOffensiveHorse() ~= nil) then gain = gain + 1 end
				if (not player:hasEquipArea(4)) and (damage.to:getTreasure() ~= nil) then gain = gain + 1 end
				if (gain > 0) then
					room:broadcastSkillInvoke(self:objectName())
					room:setPlayerMark(player, "canusekeqijuezhi", 0)
					room:sendCompulsoryTriggerLog(player, self:objectName())
					local hurt = damage.damage
					damage.damage = hurt + gain
					data:setValue(damage)
				end
			end
		end
		if (event == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if (move.from and (move.from:objectName() == player:objectName())
					and (move.from_places:contains(sgs.Player_PlaceEquip)))
			then
				for _, id in sgs.qlist(move.card_ids) do
					if sgs.Sanguosha:getCard(id):isKindOf("Weapon") then
						if player:hasEquipArea(0) then
							if room:askForSkillInvoke(player, "keqijuezhi_wq", data) then
								room:broadcastSkillInvoke(self:objectName())
								player:throwEquipArea(0)
							end
						end
					end
					if sgs.Sanguosha:getCard(id):isKindOf("Armor") then
						if player:hasEquipArea(1) then
							if room:askForSkillInvoke(player, "keqijuezhi_fj", data) then
								room:broadcastSkillInvoke(self:objectName())
								player:throwEquipArea(1)
							end
						end
					end
					if sgs.Sanguosha:getCard(id):isKindOf("DefensiveHorse") then
						if player:hasEquipArea(2) then
							if room:askForSkillInvoke(player, "keqijuezhi_fy", data) then
								room:broadcastSkillInvoke(self:objectName())
								player:throwEquipArea(2)
							end
						end
					end
					if sgs.Sanguosha:getCard(id):isKindOf("OffensiveHorse") then
						if player:hasEquipArea(3) then
							if room:askForSkillInvoke(player, "keqijuezhi_jg", data) then
								room:broadcastSkillInvoke(self:objectName())
								player:throwEquipArea(3)
							end
						end
					end
					if sgs.Sanguosha:getCard(id):isKindOf("Treasure") then
						if player:hasEquipArea(4) then
							if room:askForSkillInvoke(player, "keqijuezhi_bw", data) then
								room:broadcastSkillInvoke(self:objectName())
								player:throwEquipArea(4)
							end
						end
					end
				end
			end
		end
	end,

}
keqiqiaoxuan:addSkill(keqijuezhi)


keqijizhao = sgs.CreateTriggerSkill {
	name = "keqijizhao",
	frequency = sgs.Skill_Frequent,
	events = { sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Finish) or (player:getPhase() == sgs.Player_Start) then
				local target = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName(), "keqijizhao-ask",
					true, true)
				if target then
					if target:getState() ~= "online" then
						room:broadcastSkillInvoke(self:objectName())
						if not room:askForUseCard(target, ".", "keqijizhaouse-ask") then
							choice = sgs.SPlayerList()
							choice:append(target)
							room:moveField(player, "keqijizhao", true, "ej", choice)
						end
					else
						room:broadcastSkillInvoke(self:objectName())
						local pattern = {}
						for _, c in sgs.qlist(target:getCards("h")) do
							if (not target:isJilei(c)) and (c:isAvailable(target)) then
								table.insert(pattern, c:getEffectiveId())
							end
						end
						if (#pattern > 0) then
							if not room:askForUseCard(target, table.concat(pattern, ","), "keqijizhaouse-ask") then
								choice = sgs.SPlayerList()
								choice:append(target)
								room:moveField(player, "keqijizhao", true, "ej", choice)
							end
						end
					end
				end
			end
		end
	end,
}
keqiqiaoxuan:addSkill(keqijizhao)



keqiwangyun = sgs.General(extension, "keqiwangyun", "qun", 3)

keqishelunCard = sgs.CreateSkillCard {
	name = "keqishelunCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:objectName() ~= sgs.Self:objectName()) and
			(sgs.Self:inMyAttackRange(to_select))
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		--FORAI
		for _, p in sgs.qlist(room:getOtherPlayers(target)) do
			if (p:getState() ~= "online") then
				if target:isYourFriend(p) then
					room:setPlayerFlag(p, "shulunfriend")
					--[[for _,c in sgs.qlist(p:getCards("h")) do
						if c:isRed() then
							room:setCardFlag(c,"chaozhengred")
						end
					end]]
				else
					room:setPlayerFlag(p, "shuluneny")
					--[[for _,c in sgs.qlist(p:getCards("h")) do
						if c:isBlack() then
							room:setCardFlag(c,"chaozhengblack")
						end
					end]]
				end
			end
		end
		local yishiplayers = sgs.SPlayerList()
		--确定议事人员
		for _, p in sgs.qlist(room:getOtherPlayers(target)) do
			if (p:getHandcardNum() <= player:getHandcardNum()) then
				yishiplayers:append(p)
			end
		end
		--开始议事
		for _, p in sgs.qlist(yishiplayers) do
			room:setPlayerMark(p, "keyishiing", 1)
			--每个人提前挑选牌准备展示
			if not p:isKongcheng() then
				local id = room:askForExchange(p, "keqishelun", 1, 1, false, "keqichaozheng_yishi"):getSubcards():first()
				--local id = room:askForCardChosen(p, p, "h", "keqichaozheng_yishi", false, sgs.Card_MethodNone, sgs.IntList(), false)
				local card = sgs.Sanguosha:getCard(id)
				room:setCardFlag(card, "useforyishi")
				if card:isRed() then
					room:setPlayerMark(p, "keyishi_red", 1)
				elseif card:isBlack() then
					room:setPlayerMark(p, "keyishi_black", 1)
				end
				--标记选择了牌的人（没有空城的人）
				room:setPlayerMark(p, "chooseyishi", 1)
			end
		end
		--依次展示选好的牌，公平公正公开
		room:getThread():delay(800)
		local yishirednum = 0
		local yishiblacknum = 0
		for _, p in sgs.qlist(room:getAllPlayers()) do
			for _, c in sgs.qlist(p:getCards("h")) do
				if c:hasFlag("useforyishi") then
					if c:isRed() then yishirednum = yishirednum + 1 end
					if c:isBlack() then yishiblacknum = yishiblacknum + 1 end
					room:showCard(p, c:getEffectiveId())
					room:setCardFlag(c, "-useforyishi")
					break
				end
			end
		end
		room:getThread():delay(1200)
		--0为平局（默认），1：红色；2：黑色
		local yishiresult = 0
		if (yishirednum > yishiblacknum) then
			yishiresult = 1
			local log = sgs.LogMessage()
			log.type = "$keyishired"
			log.from = player
			room:sendLog(log)
			room:doLightbox("$keyishired")
		elseif (yishirednum < yishiblacknum) then
			yishiresult = 2
			local log = sgs.LogMessage()
			log.type = "$keyishiblack"
			log.from = player
			room:sendLog(log)
			room:doLightbox("$keyishiblack")
		elseif (yishirednum == yishiblacknum) then
			yishiresult = 0
			local log = sgs.LogMessage()
			log.type = "$keyishipingju"
			log.from = player
			room:sendLog(log)
			room:doLightbox("$keyishipingju")
		end
		--赦论效果
		if (yishiresult == 1) then
			if player:canDiscard(target, "he") then
				local to_throw = room:askForCardChosen(player, target, "he", self:objectName())
				local card = sgs.Sanguosha:getCard(to_throw)
				room:throwCard(card, target, player);
			end
		elseif (yishiresult == 2) then
			room:damage(sgs.DamageStruct(self:objectName(), player, target))
		end
		--结束
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if (p:getMark("keyishiing") > 0) then room:setPlayerMark(p, "keyishiing", 0) end
			if (p:getMark("chooseyishi") > 0) then room:setPlayerMark(p, "chooseyishi", 0) end
		end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if (p:getMark("keyishi_red") > 0) then room:setPlayerMark(p, "keyishi_red", 0) end
			if (p:getMark("keyishi_black") > 0) then room:setPlayerMark(p, "keyishi_black", 0) end
		end
		--ai清除
		for _, p in sgs.qlist(room:getAllPlayers()) do
			room:setPlayerFlag(p, "-shulunfriend")
			room:setPlayerFlag(p, "-shuluneny")
			for _, c in sgs.qlist(p:getCards("h")) do
				room:setCardFlag(c, "-chaozhengred")
				room:setCardFlag(c, "-chaozhengblack")
			end
		end
	end
}

keqishelunVS = sgs.CreateZeroCardViewAsSkill {
	name = "keqishelun",
	enabled_at_play = function(self, player)
		return not player:hasUsed("#keqishelunCard")
	end,
	view_as = function()
		return keqishelunCard:clone()
	end
}
keqishelun = sgs.CreateTriggerSkill {
	name = "keqishelun",
	view_as_skill = keqishelunVS,
	on_trigger = function(self, event, player, data)
	end,
}
keqiwangyun:addSkill(keqishelun)


keqifayi = sgs.CreateTriggerSkill {
	name = "keqifayi",
	frequency = sgs.Skill_Frequent,
	events = { sgs.MarkChanged },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.MarkChanged) then
			local mark = data:toMark()
			if mark.name == "chooseyishi" then
				if (mark.gain < 0) then
					local players = sgs.SPlayerList()
					for _, p in sgs.qlist(room:getAllPlayers()) do
						if ((p:getMark("keyishi_red") > 0) and (player:getMark("keyishi_black") > 0))
							or ((p:getMark("keyishi_black") > 0) and (player:getMark("keyishi_red") > 0)) then
							players:append(p)
						end
					end
					local eny = room:askForPlayerChosen(player, players, self:objectName(), "keqifayi-ask", true, true)
					if eny then
						room:broadcastSkillInvoke(self:objectName())
						room:damage(sgs.DamageStruct(self:objectName(), player, eny))
					end
				end
			end
		end
	end,
}
keqiwangyun:addSkill(keqifayi)


keqiyangbiao = sgs.General(extension, "keqiyangbiao", "qun", 4, true, false, false, 3)

keqizhaohan = sgs.CreateTriggerSkill {
	name = "keqizhaohan",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.SwappedPile, sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.SwappedPile) then
			room:setTag("keqizhaohan", sgs.QVariant(1))
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Start) then
				if (room:getTag("keqizhaohan"):toInt() ~= 1) then
					room:broadcastSkillInvoke(self:objectName(), 1)
					local recover = sgs.RecoverStruct()
					recover.who = player
					room:recover(player, recover)
				else
					room:broadcastSkillInvoke(self:objectName(), 2)
					room:loseHp(player, 1, true, player)
				end
			end
		end
	end
}
keqiyangbiao:addSkill(keqizhaohan)

keqirangjie = sgs.CreateTriggerSkill {
	name = "keqirangjie",
	events = { sgs.Damaged, sgs.EventPhaseChanging, sgs.CardsMoveOneTime },
	frequency = sgs.Skill_Frequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and (move.from:objectName() == player:objectName())
				and (move.from:hasFlag("usingkeqirangjie"))
				and move.from_places:contains(sgs.Player_PlaceEquip)
				and (move.card_ids:length() == 1)
				and move.to and (move.to_place == sgs.Player_PlaceEquip) then
				for _, id in sgs.qlist(move.card_ids) do
					if sgs.Sanguosha:getCard(id):getSuit() == sgs.Card_Diamond then
						for _, p in sgs.qlist(room:getAllPlayers()) do
							if (p:getMark("sourcekeqirangjie") > 0) then
								room:setPlayerMark(p, "keqirangjiediamond", 1)
								break
							end
						end
					elseif sgs.Sanguosha:getCard(id):getSuit() == sgs.Card_Heart then
						for _, p in sgs.qlist(room:getAllPlayers()) do
							if (p:getMark("sourcekeqirangjie") > 0) then
								room:setPlayerMark(p, "keqirangjieheart", 1)
								break
							end
						end
					elseif sgs.Sanguosha:getCard(id):getSuit() == sgs.Card_Club then
						for _, p in sgs.qlist(room:getAllPlayers()) do
							if (p:getMark("sourcekeqirangjie") > 0) then
								room:setPlayerMark(p, "keqirangjieclub", 1)
								break
							end
						end
					elseif sgs.Sanguosha:getCard(id):getSuit() == sgs.Card_Spade then
						for _, p in sgs.qlist(room:getAllPlayers()) do
							if (p:getMark("sourcekeqirangjie") > 0) then
								room:setPlayerMark(p, "keqirangjiespade", 1)
								break
							end
						end
					end
				end
			end
			--[[if move.from and (move.from:objectName() == player:objectName()) and (move.to_place == sgs.Player_DiscardPile) then
				for _,id in sgs.qlist(move.card_ids) do	
					room:setCardFlag(sgs.Sanguosha:getCard(id),"keqirangjie")
				end
			end]]
		end
		if (event == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if (move.to_place == sgs.Player_DiscardPile) then
				local tag = room:getTag("rangjieToGet")
				local rangjieToGet = tag:toString()
				if rangjieToGet == nil then
					rangjieToGet = ""
				end
				for _, card_id in sgs.qlist(move.card_ids) do
					if rangjieToGet == "" then
						rangjieToGet = tostring(card_id)
					else
						rangjieToGet = rangjieToGet .. "+" .. tostring(card_id)
					end
				end
				if rangjieToGet then
					room:setTag("rangjieToGet", sgs.QVariant(rangjieToGet))
				end
			end
		end
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) then
				room:removeTag("rangjieToGet")
				for _, id in sgs.qlist(room:getDiscardPile()) do
					if (sgs.Sanguosha:getCard(id):hasFlag("keqirangjie")) then
						room:setCardFlag(sgs.Sanguosha:getCard(id), "-keqirangjie")
					end
				end
			end
		end

		if (event == sgs.Damaged) and player:hasSkill(self:objectName()) then
			local damage = data:toDamage()
			for i = 0, damage.damage - 1, 1 do
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					room:setPlayerMark(player, "sourcekeqirangjie", 1)
					choice = sgs.SPlayerList()
					for _, p in sgs.qlist(room:getAllPlayers()) do
						room:setPlayerFlag(p, "usingkeqirangjie")
						choice:append(p)
					end
					room:moveField(player, "keqirangjie", true, "ej", choice)

					--移动后会得到一个标记，红或者黑，然后选牌
					--[[local card_ids = sgs.IntList()
					for _, id in sgs.qlist(room:getDiscardPile()) do
						if (sgs.Sanguosha:getCard(id):hasFlag("keqirangjie"))
						and (((player:getMark("keqirangjieblack")>0) and (sgs.Sanguosha:getCard(id):isBlack()))
						or (((player:getMark("keqirangjiered")>0) and (sgs.Sanguosha:getCard(id):isRed())))) then
							card_ids:append(id)
						end
					end]]
					local tag = room:getTag("rangjieToGet")
					local rangjie_cardsToGet
					if tag then
						rangjie_cardsToGet = tag:toString():split("+")
					else
						return false
					end
					local cards = sgs.IntList()
					for i = 1, #rangjie_cardsToGet, 1 do
						local card_data = rangjie_cardsToGet[i]
						if card_data == nil then return false end
						if card_data ~= "" then --弃牌阶段没弃牌则字符串为""
							local card_id = tonumber(card_data)
							if room:getCardPlace(card_id) == sgs.Player_DiscardPile then
								if (((player:getMark("keqirangjiediamond") > 0) and (sgs.Sanguosha:getCard(card_id):getSuit() == sgs.Card_Diamond))
										or ((player:getMark("keqirangjieheart") > 0) and (sgs.Sanguosha:getCard(card_id):getSuit() == sgs.Card_Heart))
										or ((player:getMark("keqirangjieclub") > 0) and (sgs.Sanguosha:getCard(card_id):getSuit() == sgs.Card_Club))
										or ((player:getMark("keqirangjiespade") > 0) and (sgs.Sanguosha:getCard(card_id):getSuit() == sgs.Card_Spade))
									) then
									if not cards:contains(card_id) then
										cards:append(card_id)
									end
								end
							end
						end
					end
					if not cards:isEmpty() then
						room:fillAG(cards, player)
						local to_back = room:askForAG(player, cards, false, self:objectName())
						local backcard = sgs.Sanguosha:getCard(to_back)
						player:obtainCard(backcard)
						--[[if (card_ids:length() > 0) then
							room:fillAG(card_ids)
							local card_id = room:askForAG(player, card_ids, false,self:objectName(), "keqirangjie-choice")
							local card = sgs.Sanguosha:getCard(card_id)
							player:obtainCard(card)
						end]]
						room:clearAG()
					end
					for _, p in sgs.qlist(room:getAllPlayers()) do
						room:setPlayerFlag(p, "-usingkeqirangjie")
						room:setPlayerMark(p, "keqirangjiediamond", 0)
						room:setPlayerMark(p, "keqirangjieheart", 0)
						room:setPlayerMark(p, "keqirangjieclub", 0)
						room:setPlayerMark(p, "keqirangjiespade", 0)
					end
					room:setPlayerMark(player, "sourcekeqirangjie", 0)
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}
keqiyangbiao:addSkill(keqirangjie)

keqiyizhengCard = sgs.CreateSkillCard {
	name = "keqiyizhengCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets == 0
			and (not to_select:isKongcheng()) and (to_select:objectName() ~= sgs.Self:objectName())
			and (sgs.Self:canPindian(to_select, true)) and (to_select:getHandcardNum() > sgs.Self:getHandcardNum())
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		local success = player:pindian(target, "keguangfu", nil)
		if success then
			room:setPlayerMark(target, "&keqiyizheng", 1)
		else
			local result = room:askForChoice(target, self:objectName(), "zero+one+two")
			if result == "one" then
				local damage = sgs.DamageStruct()
				damage.from = target
				damage.to = player
				damage.damage = 1
				room:damage(damage)
			end
			if result == "two" then
				local damage = sgs.DamageStruct()
				damage.from = target
				damage.to = player
				damage.damage = 2
				room:damage(damage)
			end
		end
	end
}

keqiyizhengVS = sgs.CreateViewAsSkill {
	name = "keqiyizheng",
	n = 0,
	view_as = function(self, cards)
		return keqiyizhengCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not (player:hasUsed("#keqiyizhengCard"))
	end,
}
keqiyizheng = sgs.CreateTriggerSkill {
	name = "keqiyizheng",
	view_as_skill = keqiyizhengVS,
	events = { sgs.EventPhaseChanging },
	can_trigger = function(self, player)
		return player
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			local room = player:getRoom()
			if (change.to == sgs.Player_Draw) and (player:isAlive()) and (player:getMark("&keqiyizheng") > 0) then
				room:setPlayerMark(player, "&keqiyizheng", 0)
				if not player:isSkipped(sgs.Player_Draw) then
					player:skip(sgs.Player_Draw)
				end
			end
		end
	end,
}
keqiyangbiao:addSkill(keqiyizheng)


keqizhujun = sgs.General(extension, "keqizhujun", "qun", 4)

keqifendi = sgs.CreateTriggerSkill {
	name = "keqifendi",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.TargetSpecified, sgs.Damage, sgs.CardFinished },
	can_trigger = function(self, player)
		return player
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardFinished) then
			local use = data:toCardUse()
			if (use.card:getSkillName() == "keqifendislash") then --use.card:hasFlag("keqifendislash") then
				for _, p in sgs.qlist(use.to) do
					if (p:getMark("beusekeqifendi") > 0) then
						room:setPlayerMark(p, "beusekeqifendi", 0)
						local pattern = {}
						for _, c in sgs.qlist(p:getCards("h")) do
							if not c:hasFlag("keqifendicard") then
								table.insert(pattern, c:getEffectiveId())
							end
						end
						room:removePlayerCardLimitation(p, "use,response", table.concat(pattern, ","))
						--[[local pattern = {}
						for _,c in sgs.qlist(p:getCards("h")) do
							if c:hasFlag("keqifendicard") then
								table.insert(pattern,c:getEffectiveId())
							end
						end
						room:removePlayerCardLimitation(p, "use,response", pattern)]]
					end
				end
			end
		end
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if damage.card and (damage.card:getSkillName() == "keqifendislash") --damage.card:hasFlag("keqifendislash")
				and (player:hasSkill(self:objectName())) then
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, c in sgs.qlist(damage.to:getCards("h")) do
					if c:hasFlag("keqifendicard") then
						dummy:addSubcard(c:getId())
					end
				end
				if (dummy:subcardsLength() == 0) then
					for _, id in sgs.qlist(room:getDiscardPile()) do
						if sgs.Sanguosha:getCard(id):hasFlag("keqifendicard") then
							dummy:addSubcard(id)
						end
					end
				end
				player:obtainCard(dummy)
				dummy:deleteLater()
			end
		end

		if (event == sgs.TargetSpecified) then
			local use = data:toCardUse()
			if use.card and use.card:isKindOf("Slash") and (use.to:length() == 1) and player:hasSkill(self:objectName()) then
				local target = use.to:at(0)
				if not target:isKongcheng() then
					local _data = sgs.QVariant()
					_data:setValue(target)
					if (player:getMark("bankeqifendi-Clear") < 1) and player:askForSkillInvoke(self:objectName(), _data) then
						room:setPlayerMark(player, "bankeqifendi-Clear", 1)
						room:setPlayerMark(target, "beusekeqifendi", 1)
						--room:setCardFlag(use.card,"keqifendislash")
						use.card:setSkillName("keqifendislash")
						room:broadcastSkillInvoke(self:objectName())
						--if (target:getHandcardNum() > 1) then
						local choices = {}
						for i = 1, target:getHandcardNum() do
							table.insert(choices, i)
						end
						if choices == "" then return false end
						local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
						local num = tonumber(choice)
						local to_all = sgs.IntList()
						local to_show = sgs.IntList()
						local keyi = 0
						for _, c in sgs.qlist(target:getCards("h")) do
							to_all:append(c:getEffectiveId())
						end
						--循环随机里面的一张牌装到to_show里面，直到to_show装满
						repeat
							keyi = 0
							local rr = math.random(0, to_all:length() - 1)
							if not to_show:contains(to_all:at(rr)) then
								to_show:append(to_all:at(rr))
								room:setCardFlag(sgs.Sanguosha:getCard(to_all:at(rr)), "keqifendicard")
							end
							if to_show:length() == num then
								keyi = 1
							end
						until (keyi == 1)
						room:showCard(target, to_show)
						--[[else
							local card = target:getRandomHandCard()
							local to_show = sgs.IntList()
							to_show:append(card:getEffectiveId())
							room:showCard(target,to_show)
							room:setCardFlag(card,"keqifendicard")]]

						local pattern = {}
						for _, c in sgs.qlist(target:getCards("h")) do
							if not c:hasFlag("keqifendicard") then
								table.insert(pattern, c:getEffectiveId())
							end
						end
						room:setPlayerCardLimitation(target, "use,response", table.concat(pattern, ","), false)
					end
				end
			end
		end
	end,
}
keqizhujun:addSkill(keqifendi)


keqijuxiang = sgs.CreateTriggerSkill {
	name = "keqijuxiang",
	events = { sgs.CardsMoveOneTime, sgs.DrawInitialCards, sgs.GameStart },
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		--不然手气卡也发动，真的搞
		if (event == sgs.DrawInitialCards) then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasSkill(self:objectName()) then
					room:setPlayerMark(p, "bankeqijuxiang", 1)
				end
			end
		end
		if (event == sgs.GameStart) then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasSkill(self:objectName()) then
					room:setPlayerMark(p, "bankeqijuxiang", 0)
				end
			end
		end
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.to and (move.to:objectName() == player:objectName())
				and (move.to_place == sgs.Player_PlaceHand) and player:hasSkill(self:objectName())
				and (player:getPhase() ~= sgs.Player_Draw)
				and (player:getMark("bankeqijuxiang") == 0) then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					local to_throw = sgs.IntList()
					local have_throw = sgs.IntList()
					local num = 0
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					for _, id in sgs.qlist(move.card_ids) do
						if (have_throw:length() == 0) then
							num = num + 1
						else
							for _, oldid in sgs.qlist(have_throw) do
								if (sgs.Sanguosha:getCard(id):getSuit() ~= sgs.Sanguosha:getCard(oldid):getSuit()) then
									num = num + 1
								end
							end
						end
						dummy:addSubcard(id)
						have_throw:append(id)
					end
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(),
						self:objectName(), nil)
					room:throwCard(dummy, reason, player)
					dummy:deleteLater()
					room:addSlashCishu(room:getCurrent(), num, true)
					local log = sgs.LogMessage()
					log.type = "$keqijuxiangadd"
					log.from = room:getCurrent()
					room:sendLog(log)
				end
			end
		end
	end,
}
keqizhujun:addSkill(keqijuxiang)

keqisunjian = sgs.General(extension, "keqisunjian", "qun", 4, true, true)

keqisunjian:addSkill("keqipingtao")
keqijueliedisCard = sgs.CreateSkillCard {
	name = "keqijueliedisCard",
	target_fixed = true,
	mute = true,
	on_use = function(self, room, source, targets)
		if source:isAlive() then
			local num = self:subcardsLength()
			room:setPlayerMark(source, "keqijueliemark", num)
			room:broadcastSkillInvoke("keqijuelie")
		end
	end
}

keqijuelieVS = sgs.CreateViewAsSkill {
	name = "keqijuelie",
	n = 999,
	response_pattern = "@@keqijuelie",
	view_filter = function(self, selected, to_select)
		return not sgs.Self:isJilei(to_select)
	end,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local dis_card = keqijueliedisCard:clone()
		for _, card in pairs(cards) do
			dis_card:addSubcard(card)
		end
		dis_card:setSkillName("keqijuelie")
		return dis_card
	end,
	enabled_at_play = function(self, player)
		return false
	end,
}

keqijuelie = sgs.CreateTriggerSkill {
	name = "keqijuelie",
	events = { sgs.DamageCaused, sgs.TargetSpecified },
	frequency = sgs.Skill_Frequent,
	view_as_skill = keqijuelieVS,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local room = player:getRoom()
		if (event == sgs.TargetSpecified) then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") then
				for _, p in sgs.qlist(use.to) do
					local to_data = sgs.QVariant()
					to_data:setValue(p)
					if not player:isNude() then
						local will_use = room:askForSkillInvoke(player, self:objectName(), to_data)
						if will_use then
							room:askForUseCard(player, "@@keqijuelie", "keqijuelie-ask")
							if (player:getMark("keqijueliemark") > 0) then
								for i = 0, player:getMark("keqijueliemark") - 1, 1 do
									if p:canDiscard(p, "he") then
										local to_throw = room:askForCardChosen(player, p, "he", self:objectName())
										local card = sgs.Sanguosha:getCard(to_throw)
										room:throwCard(card, p, player);
									end
								end
								room:setPlayerMark(player, "keqijueliemark", 0)
							end
						end
					end
				end
			end
		end
		if (event == sgs.DamageCaused) then
			local damage = data:toDamage()
			if damage.card:isKindOf("Slash") then
				local hpyes = 1
				local spyes = 1
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getHp() < player:getHp()) then
						hpyes = 0
					end
					if (p:getHandcardNum() < player:getHandcardNum()) then
						spyes = 0
					end
				end
				if (hpyes == 1) or (spyes == 1) then
					local hurt = damage.damage
					damage.damage = hurt + 1
					data:setValue(damage)
				end
			end
		end
		return false
	end
}
keqisunjian:addSkill(keqijuelie)




keqinanhualaoxian = sgs.General(extension, "keqinanhualaoxian", "qun", 3, true, true)
keqishoushu = sgs.CreateTriggerSkill {
	name = "keqishoushu",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.RoundStart, sgs.CardsMoveOneTime, sgs.GameStart },
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if (move.from and (move.from:objectName() == player:objectName())
					and (move.from_places:contains(sgs.Player_PlaceHand)
						or move.from_places:contains(sgs.Player_PlaceEquip))) then
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("KQTaipingyaoshu") then
						kedestroyEquip(room, move, "KE_tpys")
					end
				end
			end
		end
		if (event == sgs.RoundStart) and player:hasSkill(self:objectName()) then
			local yes = 1
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if (p:getArmor() ~= nil) then
					if (p:getArmor():objectName() == "_keqi_taipingyaoshu") then
						yes = 0
						break
					end
				end
			end
			if (yes == 1) then
				local target = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName(), "keqishoushu-ask",
					false, true)
				if target then
					room:broadcastSkillInvoke(self:objectName())
					--if (target:getArmor() ~= nil) then
					for _, c in sgs.qlist(target:getCards("e")) do
						if c:isKindOf("Armor") then
							room:throwCard(c, target)
						end
					end
					--end
					local cards = sgs.IntList()
					for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
						if sgs.Sanguosha:getEngineCard(id):isKindOf("KQTaipingyaoshu") and (room:getCardPlace(id) ~= sgs.Player_DrawPile)
							and (room:getCardPlace(id) ~= sgs.Player_PlaceHand) and (room:getCardPlace(id) ~= sgs.Player_PlaceEquip) then
							cards:append(id)
							break
						end
					end
					if not cards:isEmpty() then
						room:setTag("KE_tpys", sgs.QVariant(cards:at(0)))
						--room:shuffleIntoDrawPile(target, cards, self:objectName(), true)
						local thecard = sgs.Sanguosha:getCard(cards:at(0))
						room:moveCardTo(thecard, target, sgs.Player_PlaceEquip)
					end
				end
			end
		end
	end,
}
keqinanhualaoxian:addSkill(keqishoushu)

keqiwendao = sgs.CreateTriggerSkill {
	name = "keqiwendao",
	events = { sgs.AskForRetrial },
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local judge = data:toJudge()
		if (judge.who:objectName() == player:objectName()) then
			local players = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if not p:isNude() then
					players:append(p)
				end
			end
			if player:getState() == "online" then
				local daomeidans = room:askForPlayersChosen(player, players, self:objectName(), 0, 2, "keqiwendao-ask",
					false, true)
				if (daomeidans:length() > 0) then room:broadcastSkillInvoke(self:objectName()) end
				local to_throw = sgs.IntList()
				for _, p in sgs.qlist(daomeidans) do
					local card = room:askForDiscard(p, self:objectName(), 1, 1, false, true, "keqiwendao-discard")
					to_throw:append(card:getEffectiveId())
				end
				if not to_throw:isEmpty() then
					room:fillAG(to_throw)
					local to_get = sgs.IntList()
					local card_id = room:askForAG(player, to_throw, false, self:objectName(), "keqiwendao-choice")
					room:clearAG()
					room:retrial(sgs.Sanguosha:getCard(card_id), player, judge, self:objectName())
				end
			else
				if room:askForSkillInvoke(player, self:objectName(), data) then
					local daomeidans = room:askForPlayersChosen(player, players, self:objectName(), 0, 2,
						"keqiwendao-ask", false, true)
					if (daomeidans:length() > 0) then room:broadcastSkillInvoke(self:objectName()) end
					local to_throw = sgs.IntList()
					for _, p in sgs.qlist(daomeidans) do
						local card = room:askForDiscard(p, self:objectName(), 1, 1, false, true, "keqiwendao-discard")
						to_throw:append(card:getEffectiveId())
					end
					if not to_throw:isEmpty() then
						room:fillAG(to_throw)
						local to_get = sgs.IntList()
						local card_id = room:askForAG(player, to_throw, false, self:objectName(), "keqiwendao-choice")
						room:clearAG()
						room:retrial(sgs.Sanguosha:getCard(card_id), player, judge, self:objectName())
					end
				end
			end
		end
	end
}
keqinanhualaoxian:addSkill(keqiwendao)

keqixuanhua = sgs.CreateTriggerSkill {
	name = "keqixuanhua",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart, sgs.Damaged },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Damaged) then
			local damage = data:toDamage()
			if (damage.reason == self:objectName()) then
				room:setPlayerMark(player, "keqixuanhuahit", 1)
			end
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Start) then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					local room = player:getRoom()
					local judge = sgs.JudgeStruct()
					judge.pattern = ".|spade|2,3,4,5,6,7,8,9|."
					judge.good = true
					judge.play_animation = true
					judge.reason = self:objectName()
					judge.who = player
					room:judge(judge)
					if judge:isGood() then
						local damage = sgs.DamageStruct()
						damage.to = player
						damage.damage = 3
						damage.reason = self:objectName()
						damage.nature = sgs.DamageStruct_Thunder
						room:damage(damage)
					end
					if (player:getMark("keqixuanhuahit") == 0) then
						local target = room:askForPlayerChosen(player, room:getAllPlayers(), "keqixuanhuaco_ask",
							"keqixuanhuaco-ask", true, true)
						if target then
							room:recover(target, sgs.RecoverStruct())
						end
					end
					room:setPlayerMark(player, "keqixuanhuahit", 0)
				end
			end
			if (player:getPhase() == sgs.Player_Finish) then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					local room = player:getRoom()
					local judge = sgs.JudgeStruct()
					judge.pattern = ".|spade|2,3,4,5,6,7,8,9|."
					judge.good = false
					judge.play_animation = true
					judge.reason = self:objectName()
					judge.who = player
					room:judge(judge)
					if judge:isGood() then
						local damage = sgs.DamageStruct()
						damage.to = player
						damage.damage = 3
						damage.reason = self:objectName()
						damage.nature = sgs.DamageStruct_Thunder
						room:damage(damage)
					end
					if (player:getMark("keqixuanhuahit") == 0) then
						local target = room:askForPlayerChosen(player, room:getAllPlayers(), "keqixuanhuada_ask",
							"keqixuanhuada-ask", true, true)
						if target then
							local damagee = sgs.DamageStruct()
							damagee.to = target
							damagee.from = player
							damagee.damage = 1
							damagee.reason = self:objectName()
							damagee.nature = sgs.DamageStruct_Thunder
							room:damage(damagee)
						end
					end
					room:setPlayerMark(player, "keqixuanhuahit", 0)
				end
			end
		end
	end,
}
keqinanhualaoxian:addSkill(keqixuanhua)

keqiduanwei = sgs.General(extension, "keqiduanwei", "qun", 4, true, true)
--[[
keqilangmie = sgs.CreateTriggerSkill{
    name = "keqilangmie",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart,sgs.Damage,sgs.CardUsed},
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if use.card:isKindOf("BasicCard") then room:addPlayerMark(use.from,"keqilangmiebc-Clear",1) end
			if use.card:isKindOf("TrickCard") then room:addPlayerMark(use.from,"keqilangmietc-Clear",1) end
			if use.card:isKindOf("EquipCard") then room:addPlayerMark(use.from,"keqilangmieec-Clear",1) end
		end
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			room:addPlayerMark(damage.from,"keqilangmieda-Clear",damage.damage)
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Finish) then
				local dws = room:findPlayersBySkillName(self:objectName())
				for _,p in sgs.qlist(dws) do
					if not (p:objectName() == player:objectName()) then
						local choices = {}
						if (player:getMark("keqilangmiebc-Clear")>1) or (player:getMark("keqilangmietc-Clear")>1) or (player:getMark("keqilangmieec-Clear")>1) then
							table.insert(choices, "langmieuse")
						end
						if (player:getMark("keqilangmieda-Clear") > 1) then
							table.insert(choices, "langmieda")
						end
						local choice = room:askForChoice(p, self:objectName(), table.concat(choices, "+"))
						if choice == "langmieuse" then
							if room:askForDiscard(p, self:objectName(), 1, 1, true, true, "keqilangmie-discarduse") then
								p:drawCards(2)
							end
						end
						if choice == "langmieda" then
							if room:askForDiscard(p, self:objectName(), 1, 1, true, true, "keqilangmie-discardda") then
								room:damage(sgs.DamageStruct(self:objectName(), p, player))
							end
						end
					end
				end
			end
		end
	end,
}]]
keqiduanwei:addSkill("secondlangmie")

keqiwangrong = sgs.General(extension, "keqiwangrong", "qun", 3, false, true)

keqifengzi = sgs.CreateTriggerSkill {
	name = "keqifengzi",
	events = sgs.CardUsed,
	on_trigger = function(self, event, player, data, room)
		if player:getPhase() ~= sgs.Player_Play or player:getMark("fengzi_Used-PlayClear") > 0 then return false end
		local use = data:toCardUse()
		if not use.card:isKindOf("BasicCard") and not use.card:isNDTrick() then return false end
		if not player:canDiscard(player, "h") then return false end
		local typee = (use.card:isKindOf("BasicCard") and "BasicCard") or "TrickCard"
		local card = room:askForCard(player, "" .. typee .. "|.|.|hand",
			"@fengzi-discard:" .. use.card:getType() .. "::" .. use.card:objectName(), data, self:objectName())
		if not card then return false end
		player:peiyin(self)
		player:addMark("fengzi_Used-PlayClear")
		room:setCardFlag(use.card, "fengzi_double")
		return false
	end
}

keqifengziDouble = sgs.CreateTriggerSkill {
	name = "#keqifengziDouble",
	events = sgs.CardFinished,
	can_trigger = function(self, player)
		return player and player:isAlive()
	end,
	on_trigger = function(self, event, player, data, room)
		local use = data:toCardUse()
		if not use.card:isKindOf("BasicCard") and not use.card:isNDTrick() then return false end
		if not use.card:hasFlag("fengzi_double") then return false end
		room:setCardFlag(use.card, "-fengzi_double")
		--if use.card:hasPreAction() then end
		if use.card:isKindOf("Slash") then --【杀】需要单独处理
			for _, p in sgs.qlist(use.to) do
				local se = sgs.SlashEffectStruct()
				se.from = use.from
				se.to = p
				se.slash = use.card
				se.nullified = table.contains(use.nullified_list, "_ALL_TARGETS") or
					table.contains(use.nullified_list, p:objectName())
				se.no_offset = table.contains(use.no_offset_list, "_ALL_TARGETS") or
					table.contains(use.no_offset_list, p:objectName())
				se.no_respond = table.contains(use.no_respond_list, "_ALL_TARGETS") or
					table.contains(use.no_respond_list, p:objectName())
				se.multiple = use.to:length() > 1
				se.nature = sgs.DamageStruct_Normal
				if use.card:objectName() == "fire_slash" then
					se.nature = sgs.DamageStruct_Fire
				elseif use.card:objectName() == "thunder_slash" then
					se.nature = sgs.DamageStruct_Thunder
				elseif use.card:objectName() == "ice_slash" then
					se.nature = sgs.DamageStruct_Ice
				end
				if use.from:getMark("drank") > 0 then
					room:setCardFlag(use.card, "drank")
					use.card:setTag("drank", sgs.QVariant(use.from:getMark("drank")))
				end
				se.drank = use.card:getTag("drank"):toInt()
				room:slashEffect(se)
			end
		else
			use.card:use(room, use.from, use.to)
		end
		return false
	end
}

keqijizhanw = sgs.CreatePhaseChangeSkill {
	name = "keqijizhanw",
	on_phasechange = function(self, player, room)
		if player:getPhase() ~= sgs.Player_Draw or not player:askForSkillInvoke(self) then return false end
		player:peiyin(self)

		local gets = sgs.IntList()
		local ids = room:showDrawPile(player, 1, self:objectName())
		gets:append(ids:first())
		local num = sgs.Sanguosha:getEngineCard(ids:first()):getNumber()

		while player:isAlive() do
			local choices = {}
			table.insert(choices, "more=" .. num)
			table.insert(choices, "less=" .. num)
			table.insert(choices, "cancel")
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"), sgs.QVariant(num))
			if choice == "cancel" then break end

			ids = room:showDrawPile(player, 1, self:objectName())
			gets:append(ids:first())
			local next_num = sgs.Sanguosha:getEngineCard(ids:first()):getNumber()
			if (next_num == num) or (next_num > num and choice:startsWith("less")) or (next_num < num and choice:startsWith("more")) then break end
			num = next_num
		end

		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:deleteLater()
		for _, id in sgs.qlist(gets) do
			if room:getCardPlace(id) ~= sgs.Player_PlaceTable then continue end
			slash:addSubcard(id)
		end

		if slash:subcardsLength() > 0 then
			if player:isDead() then
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(),
					self:objectName(), "")
				room:throwCard(slash, reason, nil)
				return true
			end
			room:obtainCard(player, slash)
		end
		return true
	end
}

keqifusong = sgs.CreateTriggerSkill {
	name = "keqifusong",
	events = sgs.Death,
	can_trigger = function(self, player)
		return player and player:hasSkill(self)
	end,
	on_trigger = function(self, event, player, data, room)
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() then return false end

		local players = sgs.SPlayerList()
		local max_hp = player:getMaxHp()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:getMaxHp() <= max_hp then continue end
			players:append(p)
		end

		if players:isEmpty() then return false end
		local target = room:askForPlayerChosen(player, players, self:objectName(), "@fusong-invoke", true, true)
		if not target then return false end
		player:peiyin(self)

		local skills = {}
		if not target:hasSkill("keqifengzi", true) then table.insert(skills, "keqifengzi") end
		if not target:hasSkill("keqijizhanw", true) then table.insert(skills, "keqijizhanw") end
		if #skills == 0 then return false end
		local skill = room:askForChoice(target, self:objectName(), table.concat(skills, "+"))
		room:acquireSkill(target, skill)
		return false
	end
}

keqiwangrong:addSkill(keqifengzi)
keqiwangrong:addSkill(keqifengziDouble)
keqiwangrong:addSkill(keqijizhanw)
keqiwangrong:addSkill(keqifusong)
extension:insertRelatedSkills("keqifengzi", "#keqifengziDouble")


sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable {
	["kearjsrgqi"] = "江山如故·起",


	--曹操
	["keqicaocao"] = "曹操-起",
	["&keqicaocao"] = "曹操",
	["#keqicaocao"] = "汉征西将军",
	["designer:keqicaocao"] = "官方",
	["cv:keqicaocao"] = "樰默",
	["illustrator:keqicaocao"] = "凡果",

	["keqizhenglue"] = "政略",
	[":keqizhenglue"] = "主公的回合结束时，你可以摸一张牌并令一名（若其本回合没有造成过伤害，改为至多两名）没有“猎”标记的角色获得1枚“猎”标记；你对有“猎”标记的角色使用牌无距离和次数限制；每个回合限一次，当你对有“猎”标记的角色造成伤害后，你可以摸一张牌并获得造成此伤害的牌。",

	["keqihuilie"] = "会猎",
	[":keqihuilie"] = "觉醒技，<font color='green'><b>准备阶段，</s></font>若有“猎”标记的角色数大于2，你减1点体力上限并获得技能“平戎”和“飞影”。",

	["keqipingrong"] = "平戎",
	[":keqipingrong"] = "每轮限一次，一个回合结束时，你可以令一名有“猎”标记的角色弃置所有“猎”标记，然后你于此回合结束后执行一个额外的回合，该额外回合结束时，若你于此回合内未造成过伤害，你失去1点体力。",

	["keqilue"] = "猎",
	["keqizhengluegaincard"] = "政略：获得此造成伤害的牌并摸一张牌",
	["keqizhenglue-ask"] = "你可以发动“政略”选择获得“猎”标记的角色",
	["keqipingrong-ask"] = "你可以选择发动“平戎”的角色",

	["$keqizhenglue1"] = "治政用贤不以德，则四方定。",
	["$keqizhenglue2"] = "秉至公而服天下，孤大略成。",
	["$keqihuilie1"] = "孤上承天命，会猎于江夏，幸勿观望。",
	["$keqihuilie2"] = "今雄兵百万，奉词伐罪，敢不归顺？",
	["$keqipingrong1"] = "万里平戎，岂曰功名，孤心昭昭鉴日月。",
	["$keqipingrong2"] = "四极倾颓，民心思定，试以只手补天裂。",

	["~keqicaocao"] = "汉征西，归去兮，复汉土兮…挽汉旗…",


	--刘备
	["keqiliubei"] = "刘备-起",
	["&keqiliubei"] = "刘备",
	["#keqiliubei"] = "负戎荷戈",
	["designer:keqiliubei"] = "官方",
	["cv:keqiliubei"] = "玖心粽子",
	["illustrator:keqiliubei"] = "君桓文化",

	["keqijishan"] = "积善",
	["keqijishan_pre"] = "积善：防止伤害",
	["keqijishan-ask"] = "你可以发动“积善”令一名角色回复1点体力",
	[":keqijishan"] = "每个回合限一次，当一名角色受到伤害时，你可以失去1点体力并防止此伤害，然后你与其各摸一张牌；每个回合限一次，当你造成伤害后，你可以令一名体力值最小且因“积善”而防止过伤害的角色回复1点体力。",

	["keqizhenqiao"] = "振鞘",
	[":keqizhenqiao"] = "锁定技，你的攻击范围+1；当你使用【杀】指定目标后，若你的装备区里没有武器牌，你令此【杀】结算完毕后额外执行一次结算。",


	["$keqijishan1"] = "勿以善小而不为。",
	["$keqijishan2"] = "积善成德，而神明自得。",
	["$keqizhenqiao1"] = "豺狼满朝，且看我剑出鞘。",
	["$keqizhenqiao2"] = "欲申大义，此剑一匡天下。",

	["~keqiliubei"] = "大义未信，唯念黎庶之苦……",


	--孙坚
	["keqisunjian"] = "孙坚-起-初版",
	["&keqisunjian"] = "孙坚",
	["#keqisunjian"] = "拨定烈志",
	["designer:keqisunjian"] = "官方",
	["cv:keqisunjian"] = "樰默",
	["illustrator:keqisunjian"] = "凡果",

	["keqisunjiantwo"] = "孙坚-起",
	["&keqisunjiantwo"] = "孙坚",
	["#keqisunjiantwo"] = "拨定烈志",
	["designer:keqisunjiantwo"] = "官方",
	["cv:keqisunjiantwo"] = "樰默",
	["illustrator:keqisunjiantwo"] = "凡果",

	["keqipingtao"] = "平讨",
	[":keqipingtao"] = "出牌阶段限一次，你可以令一名其他角色选择一项：1.交给你一张牌，然后令你本回合可以多使用一张【杀】；2.令你视为对其使用一张不计入次数的【杀】。",

	["keqijuelie"] = "绝烈",
	["keqijuelie-ask"] = "你可以选择发动“绝烈”弃置的牌",
	[":keqijuelie"] = "当你使用【杀】造成伤害时，若你是手牌数或体力值最小的角色，此伤害+1；当你使用【杀】指定一名角色为目标后，你可以弃置任意张牌，然后依次弃置其等量的牌。",

	["keqijuelietwo"] = "绝烈",
	[":keqijuelietwo"] = "当你使用【杀】指定一名角色为目标后，你可以弃置任意张牌，然后依次弃置其等量的牌，若你是手牌数或体力值最小的角色，此【杀】对其造成的伤害+1。",

	["keqijueliedis"] = "绝烈",
	["keqijueliedistwo"] = "绝烈",
	["#keqipingtao"] = "你可以交给 %src 一张牌，否则其视为对你使用一张【杀】",

	["$keqipingtao1"] = "平贼之功，非我莫属!",
	["$keqipingtao2"] = "贼乱数郡，宜速讨灭！",
	["$keqijuelie1"] = "诸君放手，祸福，某一肩担之！",
	["$keqijuelie2"] = "先登破城，方不负孙氏勇烈！",
	["$keqijuelietwo1"] = "诸君放手，祸福，某一肩担之！",
	["$keqijuelietwo2"] = "先登破城，方不负孙氏勇烈！",

	["~keqisunjian"] = "我，竟会被暗箭所伤…",
	["~keqisunjiantwo"] = "我，竟会被暗箭所伤…",

	--董白
	["keqidongbai"] = "董白-起",
	["&keqidongbai"] = "董白",
	["#keqidongbai"] = "魔姬",
	["designer:keqidongbai"] = "官方",
	["cv:keqidongbai"] = "官方",
	["illustrator:keqidongbai"] = "SoniaTang",

	["keqishichong"] = "恃宠",
	["#keqishichongg"] = "你可以交给 %src 一张手牌",
	[":keqishichong"] = "转换技，当你使用牌指定一名其他角色为唯一目标后，\
	①你可以获得其一张手牌；\
	②其可以交给你一张手牌。",

	[":keqishichong1"] = "转换技，当你使用牌指定一名其他角色为唯一目标后，\
	①你可以获得其一张手牌；\
	<font color='#01A5AF'><s>②其可以交给你一张手牌。</s></font>",

	[":keqishichong2"] = "转换技，当你使用牌指定一名其他角色为唯一目标后，\
	<font color='#01A5AF'><s>①你可以获得其一张手牌；</s></font>\
	②其可以交给你一张手牌。",

	["keqilianzhu"] = "连诛",
	["keqilianzhuCard"] = "连诛",
	[":keqilianzhu"] = "出牌阶段限一次，你可以展示一张手牌并交给一名其他角色，然后你依次视为对与其势力相同的其他角色使用一张【过河拆桥】。",
	["$keqishichonguse"] = "%from 发动了<font color='yellow'><b>“恃宠”</b></font>！",

	["$keqishichong1"] = "我家猫咪喜欢的，都要留下。",
	["$keqishichong2"] = "有所付出，才能得到赏赐。",
	["$keqilianzhu1"] = "一荣俱荣，一损俱损，这道理我懂。",
	["$keqilianzhu2"] = "拿了本小姐的东西，就留下点什么吧。",

	["~keqidongbai"] = "爷爷，快来救救我。",

	--段煨
	["keqiduanwei"] = "段煨-起",
	["&keqiduanwei"] = "段煨",
	["#keqiduanwei"] = "凉国之英",
	["designer:keqiduanwei"] = "官方",
	["cv:keqiduanwei"] = "官方",
	["illustrator:keqiduanwei"] = "匠人绘",

	["keqilangmie"] = "狼灭",
	[":keqilangmie"] = "其他角色的结束阶段，你可以选择一项：\
	1.若其本回合使用过至少两张相同类型的牌，你弃置一张牌并摸两张牌；\
	2.若其本回合造成过至少2点伤害，你弃置一张牌并对其造成1点伤害。",

	["keqilangmie:langmieuse"] = "弃置一张牌并摸两张牌",
	["keqilangmie:langmieda"] = "弃置一张牌对其造成1点伤害",

	["keqilangmie-discarduse"] = "你可以弃置一张牌，然后摸两张牌",
	["keqilangmie-discardda"] = "你可以弃置一张牌，然后对其造成1点伤害",


	["~keqiduanwei"] = "狼伴其侧，终不胜防。",

	--何进
	["keqihejin"] = "何进-起",
	["&keqihejin"] = "何进",
	["#keqihejin"] = "独意误国谋",
	["designer:keqihejin"] = "官方",
	["cv:keqihejin"] = "官方",
	["illustrator:keqihejin"] = "凡果-棉鞋",

	["keqizhaobing"] = "诏兵",
	[":keqizhaobing"] = "<font color='green'><b>结束阶段，</s></font>你可以弃置所有手牌，然后令至多X名其他角色各选择一项：1.展示并交给你一张【杀】；2.失去1点体力（X为你此次弃置的牌数）。",
	["keqizhaobing-ask"] = "请选择发动“诏兵”的角色",

	["keqizhuhuan"] = "诛宦",
	[":keqizhuhuan"] = "<font color='green'><b>准备阶段，</s></font>你可以展示所有手牌（至少一张）并弃置其中所有的【杀】，然后令一名其他角色选择一项：1.受到1点伤害并弃置X张牌；2.令你回复1点体力然后你摸X张牌（X为你此次弃置【杀】的数量）。",
	["keqizhuhuan:getdamage"] = "受到1点伤害并弃置X张牌",
	["keqizhuhuan:getrecover"] = "令其回复1点体力然后其摸X张牌",
	["keqizhuhuan-ask"] = "请选择发动“诛宦”的角色",
	["keqizhuhuan-discardda"] = "请选择弃置的牌",

	["keqiyanhuo"] = "延祸",
	[":keqiyanhuo"] = "锁定技，当你死亡时，你令本局游戏因【杀】造成的伤害+1。",

	["$keqizhaobing1"] = "吾乃皇亲贵胄，威同天子！",
	["$keqizhaobing2"] = "老夫奉诏讨贼，当恩威并施。",
	["$keqizhuhuan1"] = "尔等祸乱朝纲，罪无可赦，按律当诛！",
	["$keqizhuhuan2"] = "天下人之愿，皆系于汝等，还不快认罪服法！",
	["$keqiyanhuo1"] = "你们都要为我殉葬！",
	["$keqiyanhuo2"] = "杀了我，你们也别想活！",

	["~keqihejin"] = "诛宦不成，反遭其害，贻笑天下人矣...",


	--皇甫嵩
	["keqihuangfusong"] = "皇甫嵩-起",
	["&keqihuangfusong"] = "皇甫嵩",
	["#keqihuangfusong"] = "安危定倾",
	["designer:keqihuangfusong"] = "官方",
	["cv:keqihuangfusong"] = "官方",
	["illustrator:keqihuangfusong"] = "君桓文化",

	["keqiguanhuo"] = "观火",
	[":keqiguanhuo"] = "出牌阶段，你可以视为使用一张【火攻】，若此牌未造成伤害，此牌结算完毕后：若此牌是你本阶段第一次以此法使用的牌，本阶段你使用【火攻】造成的伤害+1，否则你失去技能“观火”。",
	["usekeqiguanhuoda"] = "观火加伤",

	["keqijuxia"] = "居下",
	[":keqijuxia"] = "每个回合限一次，当其他角色使用牌指定你为目标后，若其技能数大于你，其可以令此牌对你无效并令你摸两张牌。",
	["usekeqijuxia"] = "已使用居下",

	["keqijuxia:keqijuxia-pre"] = "你可以发动“居下”令此牌对 %src 无效并令其摸两张牌",

	["$keqiguanhuo1"] = "敌军依草结营，正犯兵家大忌！",
	["$keqiguanhuo2"] = "兵法所云，火攻之计，正合此时之势！",
	["$keqijuxia1"] = "众将平日随心，战则务尽死力！",
	["$keqijuxia2"] = "汝等不怀余力，皆有平贼之功！",
	["~keqihuangfusong"] = "力有所能，臣必为也！",

	--孔融
	["keqikongrong"] = "孔融-起",
	["&keqikongrong"] = "孔融",
	["#keqikongrong"] = "北海太守",
	["designer:keqikongrong"] = "官方",
	["cv:keqikongrong"] = "官方",
	["illustrator:keqikongrong"] = "官方",

	["keqilirang"] = "礼让",
	[":keqilirang"] = "每轮限一次，其他角色摸牌阶段开始时，你可以交给其两张牌，若如此做，此回合的弃牌阶段结束时，你可以获得其于此阶段因弃置进入弃牌堆的牌。",

	["keqilirang_use"] = "礼让",
	["keqilirang_get"] = "礼让：获得弃置的牌",

	["keqimingshi"] = "名仕",
	[":keqimingshi"] = "当你于一个回合首次受到伤害时，本轮因“礼让”效果而获得过牌的其他角色可以将此伤害转移给其。",

	["#keqilirang"] = "你可以发动“礼让”交给 %src 两张牌",
	["mskeqilirang"] = "礼让角色",
	["msusekeqilirang"] = "使用礼让",

	["$keqimingshitran"] = "%from 发动了<font color='yellow'><b>“名仕”</b></font>，转移了伤害！",
	["$keqiliranggeipai"] = "%from 发动了<font color='yellow'><b>“礼让”</b></font>！",


	["$keqilirang1"] = "人之所至，礼之所及。",
	["$keqilirang2"] = "施之以礼，还之以德。",
	["$keqimingshi1"] = "纵有强权在侧，亦不可失吾风骨。",
	["$keqimingshi2"] = "黜邪崇正，何惧之有？",
	["~keqikongrong"] = "不遵超仪？诬害之辞也！",



	--刘宏
	["keqiliuhong"] = "刘宏-起",
	["&keqiliuhong"] = "刘宏",
	["#keqiliuhong"] = "轧庭焚礼",
	["designer:keqiliuhong"] = "官方",
	["cv:keqiliuhong"] = "官方",
	["illustrator:keqiliuhong"] = "君桓文化",

	["keqichaozheng"] = "朝争",
	["keqichaozheng_yishi"] = "请选择议事展示的牌",
	[":keqichaozheng"] = "<font color='green'><b>准备阶段，</b></font>你可以令所有其他角色议事，若结果为：红色，意见为红色的角色各回复1点体力；黑色，意见为红色的角色各失去1点体力。若所有角色的意见相同，议事结束后你摸X张牌（X为此次议事的角色数）。",

	["keqishenchong"] = "甚宠",
	[":keqishenchong"] = "限定技，出牌阶段，你可以令一名其他角色获得技能“飞扬”和“跋扈”，若如此做，当你死亡时，其失去所有技能并弃置所有手牌。",

	["keqijulian"] = "聚敛",
	[":keqijulian"] = "主公技，其他群势力角色的回合限两次，当其于摸牌阶段外不因“聚敛”摸牌后，其可以摸一张牌；结束阶段，你可以获得所有其他群势力角色的各一张手牌。",
	["$keqijulianmopai"] = "%from 发动了<font color='yellow'><b>“聚敛”</b></font>，摸一张牌！",

	["$keyishired"] = "议事结果：红色",
	["$keyishiblack"] = "议事结果：黑色",
	["$keyishipingju"] = "议事结果：无结果",


	["$keqichaozheng1"] = "彼岁汉祚无恙，此岁再图中兴。",
	["$keqichaozheng2"] = "新岁开元，蒙诸君助国，请满饮此杯！",
	["$keqishenchong1"] = "今备高官厚禄，慰君劳苦功高，待卿鸣钟而食。",
	["$keqishenchong2"] = "值开元伊始，普天同庆，赐众卿爵加一等！",
	["~keqiliuhong"] = "饮至达旦，不胜酒力。",


	--刘焉
	["keqiliuyan"] = "刘焉-起",
	["&keqiliuyan"] = "刘焉",
	["#keqiliuyan"] = "裂土之宗",
	["designer:keqiliuyan"] = "官方",
	["cv:keqiliuyan"] = "官方",
	["illustrator:keqiliuyan"] = "心中一凛",

	["keqilimu"] = "立牧",
	[":keqilimu"] = "出牌阶段，你可以将一张♦牌当【乐不思蜀】对自己使用并回复1点体力；若你的判定区里有牌，你对攻击范围内的角色使用牌无距离和次数限制。",

	["keqitushe"] = "图射",
	[":keqitushe"] = "当你使用非装备牌指定目标后，你可以展示所有手牌，若其中没有基本牌，你摸X张牌（X为此牌指定的目标数）。",

	["keqitongjue"] = "通绝",
	[":keqitongjue"] = "主公技，出牌阶段限一次，你可以将任意张手牌交给一名其他群势力角色，若如此做，本回合你使用牌不能指定其为目标。",

	["$keqitushe1"] = "非英杰不图？吾既谋之且射毕。",
	["$keqitushe2"] = "汉室衰微，朝纲祸乱，必图后福。",

	["~keqiliuyan"] = "背疮难治，失子难继！",

	--桥玄
	["keqiqiaoxuan"] = "桥玄-起",
	["&keqiqiaoxuan"] = "桥玄",
	["#keqiqiaoxuan"] = "泛爱博容",
	["designer:keqiqiaoxuan"] = "官方",
	["cv:keqiqiaoxuan"] = "官方",
	["illustrator:keqiqiaoxuan"] = "君桓文化",

	["keqijuezhi"] = "绝质",
	[":keqijuezhi"] = "当你失去装备区内的一张装备牌时，你可以废除对应的装备栏；你的回合内每阶段限一次，你使用牌对目标角色造成的伤害+X（X为其装备区内与你已废除装备栏类型相同的牌数）。",

	["keqijizhao"] = "急召",
	[":keqijizhao"] = "<font color='green'><b>准备阶段或结束阶段，</b></font>你可以选择一名角色，其选择一项：1.使用一张手牌；2.你可以移动其区域内的一张牌。",

	["keqijuezhi_wq"] = "绝质：废除武器栏",
	["keqijuezhi_fj"] = "绝质：废除防具栏",
	["keqijuezhi_fy"] = "绝质：废除防御马栏",
	["keqijuezhi_jg"] = "绝质：废除进攻马栏",
	["keqijuezhi_bw"] = "绝质：废除宝物栏",
	["keqijizhao-ask"] = "你可以选择发动“急召”的角色",
	["keqijizhaouse-ask"] = "你可以使用一张牌，否则其可以移动你区域内的一张牌",


	["$keqijuezhi1"] = "汝等无忠无信，岂能事主？",
	["$keqijuezhi2"] = "心直口快，无需遮拦。",
	["$keqijizhao1"] = "冥冥之中，自有天数。",
	["$keqijizhao2"] = "周而复始，轮回流转。",
	["~keqiqiaoxuan"] = "唉，算不到我有此劫。",

	--王荣
	["keqiwangrong"] = "王荣-起",
	["&keqiwangrong"] = "王荣",
	["#keqiwangrong"] = "灵怀皇后",
	["designer:keqiwangrong"] = "官方",
	["cv:keqiwangrong"] = "官方",
	["illustrator:keqiwangrong"] = "君桓文化",


	["keqifengzi"] = "丰姿",
	[":keqifengzi"] = "出牌阶段限一次，你使用基本牌或非延时类锦囊牌时，可以弃置一张同类型的手牌，令此牌的效果结算两次。",
	["@fengzi-discard"] = "你可以弃置一张 %src 令 %arg 结算两次",
	["keqijizhanw"] = "吉占",
	[":keqijizhanw"] = "摸牌阶段开始时，你可以放弃摸牌，展示牌堆顶的一张牌，猜测牌堆顶的下一张牌点数大于或小于此牌，然后展示之，若猜对你可重复此流程，最后你获得以此法展示的牌。",
	["keqijizhanw:more"] = "点数大于%src",
	["keqijizhanw:less"] = "点数小于%src",
	["keqifusong"] = "赋颂",
	[":keqifusong"] = "当你死亡时，你可令一名体力上限大于你的角色选择获得“丰姿”或“吉占”。",
	["@fusong-invoke"] = "你可以发动“赋颂”",
	["$keqifengzi1"] = "丰姿秀丽，礼法不失",
	["$keqifengzi2"] = "倩影姿态，悄然入心",
	["$keqijizhanw1"] = "得吉占之兆，言福运之气",
	["$keqijizhanw2"] = "吉占逢时，化险为夷",
	["$keqifusong1"] = "陛下垂爱，妾身方有此位",
	["$keqifusong2"] = "长情颂，君王恩",
	["~keqiwangrong"] = "只求吾儿一生平安",


	--王允
	["keqiwangyun"] = "王允-起",
	["&keqiwangyun"] = "王允",
	["#keqiwangyun"] = "居功自矜",
	["designer:keqiwangyun"] = "官方",
	["cv:keqiwangyun"] = "官方",
	["illustrator:keqiwangyun"] = "凡果",


	["keqishelun"] = "赦论",
	["keqishelunCard"] = "赦论",
	[":keqishelun"] = "出牌阶段限一次，你可以选择一名攻击范围内的其他角色，你令该角色以外所有手牌数不大于你的角色议事，若结果为：红色，你弃置其一张牌；黑色，你对其造成1点伤害。",

	["keqifayi"] = "伐异",
	[":keqifayi"] = "当你议事结束后，你可以对一名本次议事的意见与你不同的角色造成1点伤害。",

	["keqifayi-ask"] = "你可以发动“伐异”对一名角色造成1点伤害",

	["$keqishelun1"] = "你终于走到了这一天。",
	["$keqishelun2"] = "看看这身边还有谁替你说话？",
	["$keqifayi1"] = "一石二鸟之计！",
	["$keqifayi2"] = "我已为你布好了死局！",
	["~keqiwangyun"] = "我怎么也会走到这一天，呃...",

	--杨彪
	["keqiyangbiao"] = "杨彪-起",
	["&keqiyangbiao"] = "杨彪",
	["#keqiyangbiao"] = "德彰海内",
	["designer:keqiyangbiao"] = "官方",
	["cv:keqiyangbiao"] = "官方",
	["illustrator:keqiyangbiao"] = "木美人",


	["keqizhaohan"] = "昭汉",
	[":keqizhaohan"] = "锁定技，<font color='green'><b>准备阶段，</b></font>若牌堆没有洗过牌，你回复1点体力，否则你失去1点体力。",

	["keqirangjie"] = "让节",
	[":keqirangjie"] = "当你受到1点伤害后，你可以移动场上的一张牌，然后你可以获得弃牌堆中的一张本回合置入其中的且与你本次移动的牌相同花色的牌。",

	["keqiyizheng"] = "义争",
	[":keqiyizheng"] = "出牌阶段限一次，你可以与一名手牌数大于你的角色拼点，若你赢，其跳过下个摸牌阶段；若你没赢，其可以对你造成0~2点伤害。",

	["keqiyizhengCard:zero"] = "不对其造成伤害",
	["keqiyizhengCard:one"] = "对其造成1点伤害",
	["keqiyizhengCard:two"] = "对其造成2点伤害",

	["$keqizhaohan1"] = "天道昭昭，再兴如光武亦可期！",
	["$keqizhaohan2"] = "汉祚将终，我又岂能无憾？",
	["$keqirangjie1"] = "公既执掌权柄，又何必令君臣遭乱？",
	["$keqirangjie2"] = "公虽权倾朝野，亦当遵圣上之意。",
	["$keqiyizheng1"] = "一人劫天子，一人质公卿，此可行耶？",
	["$keqiyizheng2"] = "诸君举事，当上顺天心，奈何如是！",
	["~keqiyangbiao"] = "未能效死佑汉，只因宗族之重……",

	--朱儁
	["keqizhujun"] = "朱儁-起",
	["&keqizhujun"] = "朱儁",
	["#keqizhujun"] = "征无遗虑",
	["designer:keqizhujun"] = "官方",
	["cv:keqizhujun"] = "官方",
	["illustrator:keqizhujun"] = "沉睡千年",


	["keqifendi"] = "分敌",
	[":keqifendi"] = "每个回合限一次，当你使用【杀】指定唯一目标后，你可以展示其至少一张手牌，若如此做，该角色不能使用或打出其余手牌直到此【杀】结算完毕，当此【杀】对其造成伤害后，你获得其手牌中或弃牌堆里这些展示的牌。",

	["keqijuxiang"] = "拒降",
	[":keqijuxiang"] = "当你不于摸牌阶段获得牌时，你可以弃置这些牌，然后令当前回合角色本回合可以多使用X张【杀】（X为本次弃置的牌的花色数）。",

	["keqifendi-tip"] = "请选择展示其手牌的数量",
	["$keqijuxiangadd"] = "%from 增加了【杀】的使用次数！",

	["$keqifendi1"] = "全军撤围，待其出城迎战，再攻敌自散矣！",
	["$keqifendi2"] = "佯解敌围，而后城外击之，此为易破之道！",
	["$keqijuxiang1"] = "今非秦项之际，如若受之，徒增逆意！",
	["$keqijuxiang2"] = "兵有形同而势异者，此次乞降断不可受！",
	["~keqizhujun"] = "郭汜小竖！气煞我也！嗯...",


	--南华老仙
	["keqinanhualaoxian"] = "南华老仙-起-初版",
	["&keqinanhualaoxian"] = "南华老仙-初版",
	["#keqinanhualaoxian"] = "冯虚御风",
	["designer:keqinanhualaoxian"] = "官方",
	["cv:keqinanhualaoxian"] = "官方",
	["illustrator:keqinanhualaoxian"] = "君桓文化",

	["keqinanhualaoxiantwo"] = "南华老仙",
	["&keqinanhualaoxiantwo"] = "南华老仙",
	["#keqinanhualaoxiantwo"] = "冯虚御风",
	["designer:keqinanhualaoxiantwo"] = "官方",
	["cv:keqinanhualaoxiantwo"] = "官方",
	["illustrator:keqinanhualaoxiantwo"] = "君桓文化",



	["keqishoushu"] = "授术",
	[":keqishoushu"] = "锁定技，<font color='green'><b>每轮开始时，</s></font>若场上没有【太平要术】，你将游戏外的【太平要术】置入一名角色的装备区（替换原装备）；【太平要术】离开装备区时销毁。",

	["keqishoushutwo"] = "授术",
	[":keqishoushutwo"] = "锁定技，<font color='green'><b>游戏开始时，</s></font>若场上没有【太平要术】，你将游戏外的【太平要术】置入一名角色的装备区（替换原装备）；【太平要术】离开装备区时销毁。",

	["keqiwendao"] = "问道",
	[":keqiwendao"] = "当你的判定牌生效前，你可以令至多两名角色各弃置一张牌，然后你选择其中一张代替此判定牌。",

	["keqiwendaotwo"] = "问道",
	["keqixuanhuatwofirst"] = "宣化",
	[":keqiwendaotwo"] = "当你的判定牌生效前，你可以令至多两名角色各弃置一张牌，然后你选择其中一张代替此判定牌。",

	["keqixuanhua"] = "宣化",
	[":keqixuanhua"] = "<font color='green'><b>准备阶段，</s></font>你可以进行一次【闪电】判定，若你未以此法受到伤害，你可以令一名角色回复1点体力；<font color='green'><b>结束阶段，</s></font>你可以进行一次判定结果反转的【闪电】判定，若你未以此法受到伤害，你可以对一名角色造成1点雷电伤害。",

	["keqixuanhuatwo"] = "宣化",
	[":keqixuanhuatwo"] = "<font color='green'><b>准备阶段，</s></font>你可以进行一次【闪电】判定，若你未以此法受到伤害，你可以令一名角色回复1点体力；<font color='green'><b>结束阶段，</s></font>你可以进行一次判定结果反转的【闪电】判定，若你未以此法受到伤害，你可以对一名角色造成1点雷电伤害。",

	["keqishoushu-ask"] = "请选择装备【太平要术】的角色",
	["keqiwendao-ask"] = "你可以选择发动“问道”[改判]弃牌的角色",
	["keqiwendao-discard"] = "问道：请弃置一张牌",
	["keqiwendao-choice"] = "请选择其中一张牌作为判定牌",

	["keqixuanhuaco-ask"] = "你可以发动“宣化”令一名角色回复1点体力",
	["keqixuanhuada-ask"] = "你可以发动“宣化”对一名角色造成1点伤害",

	["#keDestroyEqiup"] = "【太平要术】被销毁！",
	["destroy_equip"] = "授术",
	["keqitaipingyaoshuskill"] = "太平要术",

	["keqixuanhuaco_ask"] = "宣化",
	["keqixuanhuada_ask"] = "宣化",

	["$keqishoushu1"] = "汝得天书，当代天宣化，普救世人。",
	["$keqishoushu2"] = "若萌异心，必获恶报。",
	["$keqishoushutwo1"] = "汝得天书，当代天宣化，普救世人。",
	["$keqishoushutwo2"] = "若萌异心，必获恶报。",

	["$keqiwendao1"] = "其耆欲深者，其天机浅。",
	["$keqiwendao2"] = "杀生者不死，生生者不生。",
	["$keqiwendaotwo1"] = "其耆欲深者，其天机浅。",
	["$keqiwendaotwo2"] = "杀生者不死，生生者不生。",

	["$keqixuanhua1"] = "乘天地之正，御六气之辩。",
	["$keqixuanhua2"] = "燀赫乎宇宙，凭陵乎昆仑。",
	["$keqixuanhuatwo1"] = "乘天地之正，御六气之辩。",
	["$keqixuanhuatwo2"] = "燀赫乎宇宙，凭陵乎昆仑。",

	["~keqinanhualaoxian"] = "死生，命也。",
	["~keqinanhualaoxiantwo"] = "死生，命也。",


}
return { extension }
