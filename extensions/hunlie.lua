extension = sgs.Package("hunlie", sgs.Package_GeneralPack)


sgs.LoadTranslationTable{
	["hunlie"] = "魂烈",
}


Table2IntList = function(theTable)
	local result = sgs.IntList()
	for i = 1, #theTable, 1 do
		result:append(theTable[i])
	end
	return result
end


--全局配置类技能
cuifeng_slash = sgs.CreateTriggerSkill{
	name = "cuifeng_slash",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end
}


--实时记录每个人的体力上限（神夏侯惇、神大乔需要用到）
record_maxHp = sgs.CreateTriggerSkill{
	name = "record_maxHp",
	frequency = sgs.Skill_Compulsory,
	global = true,
	can_trigger = function(self, target)
		return target
	end,
	events = {sgs.GameStart, sgs.EventPhaseStart, sgs.TurnStart, sgs.Revive, sgs.Revived, sgs.MaxHpChanged},
	priority = {100, 100, 100, 100, 100, -100},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.GameStart then
			player:setTag("hunlie_global_MaxHp", sgs.QVariant(player:getMaxHp()))
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then player:setTag("hunlie_global_MaxHp", sgs.QVariant(player:getMaxHp())) end
		elseif event == sgs.TurnStart then
			player:setTag("hunlie_global_MaxHp", sgs.QVariant(player:getMaxHp()))
		elseif event == sgs.Revive then
			player:setTag("hunlie_global_MaxHp", sgs.QVariant(player:getMaxHp()))
		elseif event == sgs.Revived then
			player:setTag("hunlie_global_MaxHp", sgs.QVariant(player:getMaxHp()))
		elseif event == sgs.MaxHpChanged then
			player:setTag("hunlie_global_MaxHp", sgs.QVariant(player:getMaxHp()))
		end
		return false
	end
}


hunlie_tarmod = sgs.CreateTargetModSkill{
	name = "hunlie_tarmod",
	pattern = ".",
	residue_func = function(self, from, card, to)
		local n = 0
		if from:hasSkill("sgkgodshayi") and card:isKindOf("Slash") then n = n + 9999 end
		if from:hasSkill("sgkgodliegong") and card:isKindOf("FireSlash") and card:getSkillName() == "sgkgodliegong" then n = n + 9999 end
		return n
	end,
	distance_limit_func = function(self, from, card, to)
		local n = 0
		if from:hasSkill("sgkgodshayi") and card:isKindOf("Slash") then n = n + 9999 end
		if from:hasSkill("sgkgodliegong") and card:isKindOf("FireSlash") and card:getSkillName() == "sgkgodliegong" then n = n + 9999 end
		return n
	end
}


local sgkgodhidden = sgs.SkillList()
if not sgs.Sanguosha:getSkill("cuifeng_slash") then sgkgodhidden:append(cuifeng_slash) end
if not sgs.Sanguosha:getSkill("record_maxHp") then sgkgodhidden:append(record_maxHp) end
if not sgs.Sanguosha:getSkill("hunlie_tarmod") then sgkgodhidden:append(hunlie_tarmod) end
sgs.Sanguosha:addSkills(sgkgodhidden)


sgs.LoadTranslationTable{
	["cuifeng_slash"] = "摧锋",
}


--神月英
sgkgodyueying = sgs.General(extension, "sgkgodyueying", "sy_god", "3", false)


--[[
	技能名：知命
	相关武将：神月英
	技能描述：其他角色的准备阶段，若其有手牌，你可弃置一张手牌然后弃置其一张手牌，若两张牌颜色相同，你令其跳过此回合的摸牌阶段或出牌阶段。
	引用：sgkgodzhiming
]]--
sgkgodzhiming = sgs.CreateTriggerSkill{
	name = "sgkgodzhiming",
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data, room)
		if player:getPhase() ~= sgs.Player_Start then return false end
		if not room:findPlayerBySkillName(self:objectName()) then return false end
		local s = room:findPlayerBySkillName(self:objectName())
		if not s then return false end
		if s:getSeat() == player:getSeat() then return false end
		if player:isKongcheng() then return false end
		if not s:canDiscard(s, "h") then return false end
		local card = room:askForCard(s, ".", "@sgkgodzhiming:" .. player:objectName(), data, self:objectName())
		if not card then return false end
		room:notifySkillInvoked(s, self:objectName())
		room:broadcastSkillInvoke(self:objectName())
		room:doAnimate(1, s:objectName(), player:objectName())
		local id = room:askForCardChosen(s, player, "h", self:objectName())
		room:throwCard(id, player, s)
		if card:sameColorWith(sgs.Sanguosha:getCard(id)) then
			if room:askForChoice(s, self:objectName(), "sgkgodzhimingdraw+sgkgodzhimingplay") == "sgkgodzhimingdraw" then
				player:skip(sgs.Player_Draw)
			else
				player:skip(sgs.Player_Play)
			end
		end
	end,
	can_trigger = function()
		return true
	end
}


--[[
	技能名：夙隐
	相关武将：神月英
	技能描述：当你于回合外失去所有手牌后，你可以令一名其他角色翻面。
	引用：sgkgodsuyin
]]--
sgkgodsuyin = sgs.CreateTriggerSkill{
	name = "sgkgodsuyin",
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data, room)
		local move = data:toMoveOneTime()
		if move.from and move.from:objectName() == player:objectName() then
			if move.from_places:contains(sgs.Player_PlaceHand) then
				if move.is_last_handcard then
					if player:getPhase() == sgs.Player_NotActive then
						if not player:askForSkillInvoke(self:objectName(), data) then return false end
						local s = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "@suyin-turnover")
						if not s then return false end
						room:doAnimate(1, player:objectName(), s:objectName())
						room:broadcastSkillInvoke(self:objectName())
						s:turnOver()
					end
				end
			end
		end
	end
}


sgkgodyueying:addSkill(sgkgodzhiming)
sgkgodyueying:addSkill(sgkgodsuyin)


sgs.LoadTranslationTable{
	["sgkgodyueying"] = "神月英",
	["&sgkgodyueying"] = "神月英",
	["#sgkgodyueying"] = "夕风霞影",
	["sgkgodzhiming"] = "知命",
	[":sgkgodzhiming"] = "其他角色的准备阶段，若其有手牌，你可弃置一张手牌然后弃置其一张手牌，若两张牌颜色相同，你令其跳过此回合的摸牌阶段或出牌阶段。",
	["@sgkgodzhiming"] = "你可以弃置一张手牌对%src发动“知命”",
	["sgkgodzhimingdraw"] = "令其跳过摸牌阶段",
	["sgkgodzhimingplay"] = "令其跳过出牌阶段",
	["sgkgodsuyin"] = "夙隐",
	["@suyin-turnover"] = "你可以发动“夙隐”令一名其他角色将武将牌翻面<br/> <b>操作提示</b>: 选择一名角色→点击确定<br/>",
	[":sgkgodsuyin"] = "当你于回合外失去所有手牌后，你可以令一名其他角色翻面。",
	["$sgkgodzhiming"] = "风起日落，天行有常。",
	["$sgkgodsuyin"] = "欲别去归隐，无负奢望。",
	["~sgkgodyueying"]= "只盼明日，能共沐晨光……",
	["designer:sgkgodyueying"] = "魂烈",
	["illustrator:sgkgodyueying"] = "魂烈",
	["cv:sgkgodyueying"] = "魂烈",
}


--神张角
sgkgodzhangjiao = sgs.General(extension, "sgkgodzhangjiao", "sy_god", "3")


--[[
	技能名：电界
	相关武将：神张角
	技能描述：你可以跳过摸牌阶段或出牌阶段，然后判定，若结果为：梅花，你可令任意名角色横置；黑桃，你可对一名角色造成2点雷电伤害。
	引用：sgkgoddianjie
]]--
sgkgoddianjieCard = sgs.CreateSkillCard{
	name = "sgkgoddianjieCard",
	target_fixed = false,
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		return not to_select:isChained()
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		for i = 1, #targets, 1 do
			room:doAnimate(1, source:objectName(), targets[i]:objectName())
		end
		for i = 1, #targets, 1 do
			room:broadcastProperty(targets[i], "chained")
			room:setEmotion(targets[i], "chain")
			room:getThread():trigger(sgs.ChainStateChanged, room, targets[i])
			room:setPlayerProperty(targets[i], "chained", sgs.QVariant(true))
		end
	end
}

sgkgoddianjieVS = sgs.CreateZeroCardViewAsSkill{
	name = "sgkgoddianjie",
	response_pattern = "@@sgkgoddianjie",
	view_as = function()
		return sgkgoddianjieCard:clone()
	end
}

sgkgoddianjie = sgs.CreateTriggerSkill{
	name = "sgkgoddianjie",
	view_as_skill = sgkgoddianjieVS,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data, room)
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_Draw and change.to ~= sgs.Player_Play then return false end
		if player:isSkipped(change.to) then return false end
		if not player:askForSkillInvoke(self:objectName(), data) then return false end
		if change.to == sgs.Player_Draw then
			room:broadcastSkillInvoke(self:objectName(), 1)
		else
			room:broadcastSkillInvoke(self:objectName(), 2)
		end
		player:skip(change.to)
		local judge = sgs.JudgeStruct()
		judge.who = player
		judge.pattern = ".|black"
		judge.reason = self:objectName()
		judge.good = true
		judge.negative = false
		room:judge(judge)
		if judge:isGood() then
			if judge.card:getSuit() == sgs.Card_Spade then
				local s = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "@dianjie-thunder", true)
				if not s then return false end
				room:doAnimate(1, player:objectName(), s:objectName())
				room:damage(sgs.DamageStruct(nil, player, s, 2, sgs.DamageStruct_Thunder))
			elseif judge.card:getSuit() == sgs.Card_Club then
				local unchained = sgs.SPlayerList()
				for _, pe in sgs.qlist(room:getAlivePlayers()) do
					if not pe:isChained() then unchained:append(pe) end
				end
				if unchained:isEmpty() then return false end
				room:askForUseCard(player, "@@sgkgoddianjie", "@dianjie-chain")
			end
		end
	end
}


--[[
	技能名：神道
	相关武将：神张角
	技能描述：一名角色的判定牌生效前，你可以用一张手牌或场上的牌替换之。
	引用：sgkgodshendao
]]--
sgkgodshendao=sgs.CreateTriggerSkill{
	name = "sgkgodshendao",
	events = {sgs.AskForRetrial},
	on_trigger = function(self, event, player, data, room)
		local judge = data:toJudge()
		local q = sgs.QVariant()
		q:setValue(judge)
		player:setTag("shendao_judge", q)
		local non_nude_count = 0
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:getCards("ej"):length() > 0 then  --场上有牌的角色
				non_nude_count = non_nude_count + 1
				targets:append(p)
			end
		end
		if non_nude_count == 0 and player:isKongcheng() then return false end
		if not player:askForSkillInvoke(self:objectName(), data) then return false end
		local card
		if player:isKongcheng() and non_nude_count ~= 0 then  --特例1：自己没有手牌，但是场上还有牌
			local target = room:askForPlayerChosen(player, targets, self:objectName())
			card = sgs.Sanguosha:getCard(room:askForCardChosen(player, target, "ej", self:objectName()))
		else
			if (not player:isKongcheng()) and non_nude_count == 0 then  --特例2：自己有手牌，但是场上没有牌
				local prompt = "@shendao-card:"..judge.who:objectName()..":"..self:objectName()..
				":"..judge.reason..":"..judge.card:getEffectiveId()
				card = room:askForCard(player,  "." , prompt, data, sgs.Card_MethodResponse, judge.who, true)
			else
				if (not player:isKongcheng()) and non_nude_count ~= 0 then  --一般情况下，自己有手牌，并且场上也有牌
					local choice = room:askForChoice(player, self:objectName(), "shendao_selfhandcard+shendao_wholearea")
					if choice == "shendao_selfhandcard" then
						local prompt = "@shendao-card:"..judge.who:objectName()..":"..self:objectName()..
						":"..judge.reason..":"..judge.card:getEffectiveId()
						card = room:askForCard(player,  "." , prompt, data, sgs.Card_MethodResponse, judge.who, true)
					else
						local target = room:askForPlayerChosen(player, targets, self:objectName())
						card = sgs.Sanguosha:getCard(room:askForCardChosen(player, target, "ej", self:objectName()))
					end
				end
			end
		end
		room:broadcastSkillInvoke(self:objectName())
		room:retrial(card, player, judge, self:objectName(), true)
	end
}


--[[
	技能名：雷魂
	相关武将：神张角
	技能描述：锁定技，当你即将受到雷电伤害时，防止之，改为回复等量的体力。
	引用：sgkgodleihun
]]--
sgkgodleihun = sgs.CreateTriggerSkill{
	name = "sgkgodleihun",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data, room)
		local damage = data:toDamage()
		if damage.nature ~= sgs.DamageStruct_Thunder then return false end
		room:sendCompulsoryTriggerLog(player, self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		room:broadcastSkillInvoke(self:objectName())
		if player:isWounded() then
			local recover = sgs.RecoverStruct()
			recover.recover = math.min(damage.damage, player:getLostHp())
			room:recover(player, recover)
		end
		return true
	end
}


sgkgodzhangjiao:addSkill(sgkgoddianjie)
sgkgodzhangjiao:addSkill(sgkgodshendao)
sgkgodzhangjiao:addSkill(sgkgodleihun)


sgs.LoadTranslationTable{
	["sgkgodzhangjiao"] = "神张角",
	["&sgkgodzhangjiao"] = "神张角",
	["#sgkgodzhangjiao"] = "雷霆万钧",
	["sgkgoddianjie"] = "电界",
	[":sgkgoddianjie"] = "你可以跳过摸牌阶段或出牌阶段，然后判定，若结果为：梅花，你可令任意名角色横置；黑桃，你可对一名角色造成2点雷电伤害。",
	["@dianjie-thunder"] = "你可以对一名角色造成2点雷电伤害",
	["@dianjie-chain"] = "你可以横置任意名角色的武将牌",
	["~sgkgoddianjie"] = "选择任意名未被横置的角色→点击“确定”",
	["sgkgodshendao"] = "神道",
	[":sgkgodshendao"] = "一名角色的判定牌生效前，你可以用一张手牌或场上的牌替换之。",
	["shendao_selfhandcard"] = "用一张自己的手牌改判",
	["shendao_wholearea"] = "用一张场上的牌改判",
	["@shendao-card"] = "请发动“%dest”来修改 %src 的“%arg”判定",
	["sgkgodleihun"] = "雷魂",
	[":sgkgodleihun"] = "锁定技，当你即将受到雷电伤害时，防止之，改为回复等量的体力。",
	["$sgkgoddianjie1"] = "电破苍穹，雷震九州！",
	["$sgkgoddianjie2"] = "风雷如律令，法咒显圣灵！",
	["$sgkgodshendao"] = "人世之伎俩，于鬼神无用！",
	["$sgkgodleihun"] = "肉体凡胎，也敢扰我清静？！",
	["~sgkgodzhangjiao"] = "吾之信仰，也将化为微尘……",
	["designer:sgkgodzhangjiao"] = "魂烈",
	["illustrator:sgkgodzhangjiao"] = "魂烈",
	["cv:sgkgodzhangjiao"] = "魂烈",
}


--神吕蒙
sgkgodlvmeng = sgs.General(extension, "sgkgodlvmeng", "sy_god", 3)


--[[
	技能名：涉猎
	相关武将：神吕蒙
	技能描述：锁定技，摸牌阶段，你放弃摸牌，改为依次选择四次牌的类别，然后从牌堆随机获得这些牌。
	引用：sgkgodshelie
]]--
sgkgodshelie = sgs.CreateTriggerSkill{
    name = "sgkgodshelie",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data, room)
		if player:getPhase() ~= sgs.Player_Draw then return false end
		if room:getDrawPile():isEmpty() then room:swapPile() end --没牌可摸那就尴尬了
		local basic_cards, trick_cards, equip_cards = sgs.IntList(), sgs.IntList(), sgs.IntList()
		for _, c in sgs.qlist(room:getDrawPile()) do
		    local card = sgs.Sanguosha:getCard(c)
			if card:isKindOf("BasicCard") then
			    basic_cards:append(card:getEffectiveId())
			elseif card:isKindOf("TrickCard") then
			    trick_cards:append(card:getEffectiveId())
			elseif card:isKindOf("EquipCard") then
			    equip_cards:append(card:getEffectiveId())
			end
		end
		local shelie_types = {"BasicCard","TrickCard","EquipCard"}
		local dummy = sgs.Sanguosha:cloneCard("jink", sgs.Card_NoSuit, 0)
		for i = 1, 4 do
		    local id
			if basic_cards:isEmpty() then table.removeOne(shelie_types, "BasicCard") end
			if trick_cards:isEmpty() then table.removeOne(shelie_types, "TrickCard") end
			if equip_cards:isEmpty() then table.removeOne(shelie_types, "EquipCard") end
			if #shelie_types == 0 then break end
			local choice = room:askForChoice(player, self:objectName(), table.concat(shelie_types, "+"))
			if choice == "BasicCard" then
			    id = basic_cards:at(math.random(0, basic_cards:length()-1))
				basic_cards:removeOne(id)
				dummy:addSubcard(id)
			elseif choice == "TrickCard" then
			    id = trick_cards:at(math.random(0, trick_cards:length()-1))
				trick_cards:removeOne(id)
				dummy:addSubcard(id)
			elseif choice == "EquipCard" then
			    id = equip_cards:at(math.random(0, equip_cards:length()-1))
				equip_cards:removeOne(id)
				dummy:addSubcard(id)
			end
		end
		room:sendCompulsoryTriggerLog(player, self:objectName())
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		room:obtainCard(player, dummy, false)
		dummy:deleteLater()
		basic_cards, trick_cards, equip_cards = sgs.IntList(), sgs.IntList(), sgs.IntList()
		return true
	end
}


--[[
	技能名：攻心
	相关武将：神吕蒙
	技能描述：出牌阶段限一次，你可以观看一名其他角色的手牌并展示其中所有的红桃牌，然后若展示的牌数：为1，你弃置之并对其造成1点伤害；大于1，你获得其中一张。
	引用：sgkgodgongxin
]]--
sgkgodgongxinCard = sgs.CreateSkillCard{
    name = "sgkgodgongxinCard",
	filter = function(self, targets, to_select)
	    return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isKongcheng()
	end,
	on_effect = function(self, effect)
	    local room = effect.from:getRoom()
		if not effect.to:isKongcheng() then
		    local ids = sgs.IntList()
			for _, card in sgs.qlist(effect.to:getHandcards()) do
				if card:getSuit() == sgs.Card_Heart then
					ids:append(card:getEffectiveId())
				end
			end
			if ids:isEmpty() then
			    room:fillAG(effect.to:handCards(), effect.from)
				room:getThread():delay(1000)
				room:clearAG()
			else
			    room:fillAG(ids)
			    local card_id = room:doGongxin(effect.from, effect.to, ids)
				room:getThread():delay(1000)
				room:clearAG()
			    if ids:length() == 1 then
			        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, effect.from:objectName(), nil, "sgkgodgongxin", nil)
				    room:throwCard(sgs.Sanguosha:getCard(card_id), reason, effect.to, effect.from)
				    room:damage(sgs.DamageStruct("sgkgodgongxin", effect.from, effect.to))
			    else
			        if ids:length() > 1 then
				        local card = sgs.Sanguosha:getCard(card_id)
					    effect.from:obtainCard(card)
					end
				end
			end
		end
	end
}

sgkgodgongxin = sgs.CreateZeroCardViewAsSkill{
    name = "sgkgodgongxin",
	view_as = function()
	    return sgkgodgongxinCard:clone()
	end,
	enabled_at_play = function(self, player)
	    return not player:hasUsed("#sgkgodgongxinCard")
	end
}


sgkgodlvmeng:addSkill(sgkgodshelie)
sgkgodlvmeng:addSkill(sgkgodgongxin)


sgs.LoadTranslationTable{
	["sgkgodlvmeng"] = "神吕蒙",
	["#sgkgodlvmeng"] = "圣光国士",
	["&sgkgodlvmeng"] = "神吕蒙",
	["~sgkgodlvmeng"] = "死去方知万事空……",
	["designer:sgkgodlvmeng"] = "魂烈",
	["illustrator:sgkgodlvmeng"] = "魂烈",
	["cv:sgkgodlvmeng"] = "魂烈",
	["sgkgodshelie"] = "涉猎",
	[":sgkgodshelie"] = "锁定技，摸牌阶段，你放弃摸牌，改为依次选择四次牌的类别，然后从牌堆随机获得这些牌。",
	["$sgkgodshelie"] = "涉猎阅旧闻，暂使心魂澄。",
	["sgkgodgongxin"] = "攻心",
	[":sgkgodgongxin"] = "出牌阶段限一次，你可以观看一名其他角色的手牌并展示其中所有的红桃牌，然后若展示的牌数：为1，你弃置之并对其造成1点伤害；大于1，"..
	"你获得其中一张。",
	["$sgkgodgongxin"] = "攻城为下，攻心为上。",
}


--神赵云
sgkgodzhaoyun = sgs.General(extension, "sgkgodzhaoyun", "sy_god", 2)


--[[
	技能名：绝境
	相关武将：神赵云
	技能描述：锁定技，一名角色的回合结束时，若你的体力值：不大于1，你摸一张牌；大于1，你失去1点体力，然后摸两张牌。
	引用：sgkgodjuejing
]]--
sgkgodjuejing = sgs.CreateTriggerSkill{
    name = "sgkgodjuejing",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data, room)
		if not room:findPlayerBySkillName(self:objectName()) then return false end
		local zhaoyun = room:findPlayerBySkillName(self:objectName())
		if player:getPhase() == sgs.Player_Finish then
		    room:sendCompulsoryTriggerLog(zhaoyun, self:objectName())
			room:notifySkillInvoked(zhaoyun, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			if zhaoyun:getHp() >= 2 then
			    room:loseHp(zhaoyun)
				zhaoyun:drawCards(2)
			else
			    zhaoyun:drawCards(1)
			end
		end
	end,
	can_trigger = function(self, target)
	    return true
	end
}


--[[
	技能名：龙魂
	相关武将：神赵云
	技能描述：你可以将X张同花色的牌按以下规则使用或打出：红桃当【桃】；方块当火【杀】；黑桃当【无懈可击】；梅花当【闪】。（X为你的体力值且至少为1）
	引用：sgkgodlonghun
]]--
sgkgodlonghun = sgs.CreateViewAsSkill{
    name = "sgkgodlonghun",
	response_or_use = true,
	n = 999,
	view_filter = function(self, selected, card)
	    local n = math.max(1, sgs.Self:getHp())
		if #selected >= n or card:hasFlag("using") then
			return false 
		end
		if n > 1 and not #selected == 0 then
			local suit = selected[1]:getSuit()
			return card:getSuit() == suit
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			if sgs.Self:isWounded() and card:getSuit() == sgs.Card_Heart then
				return true
			elseif card:getSuit() == sgs.Card_Diamond then
				local slash = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, -1)
				slash:addSubcard(card:getEffectiveId())
				slash:deleteLater()
				return slash:isAvailable(sgs.Self)
			else
				return false
			end
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if pattern == "jink" then
				return card:getSuit() == sgs.Card_Club
			elseif pattern == "nullification" then
				return card:getSuit() == sgs.Card_Spade
			elseif string.find(pattern, "peach") then
				return card:getSuit() == sgs.Card_Heart
			elseif pattern == "slash" then
				return card:getSuit() == sgs.Card_Diamond
			end
			return false
		end
		return false
	end ,
	view_as = function(self, cards)
		local n = math.max(1, sgs.Self:getHp())
		if #cards ~= n then 
			return nil 
		end
		local card = cards[1]
		local new_card = nil
		if card:getSuit() == sgs.Card_Spade then
			new_card = sgs.Sanguosha:cloneCard("nullification", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Heart then
			new_card = sgs.Sanguosha:cloneCard("peach", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Club then
			new_card = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Diamond then
			new_card = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, 0)
		end
		if new_card then
			new_card:setSkillName(self:objectName())
			for _, c in ipairs(cards) do
				new_card:addSubcard(c)
			end
		end
		return new_card
	end ,
	enabled_at_play = function(self, player)
		return player:isWounded() or sgs.Slash_IsAvailable(player)
	end ,
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash" or pattern == "jink" or (string.find(pattern, "peach") and not player:hasFlag("Global_PreventPeach")) or (pattern == "nullification")
	end ,
	enabled_at_nullification = function(self, player)
		local n = math.max(1, player:getHp())
		local count = 0
		for _, card in sgs.qlist(player:getHandcards()) do
			if card:getSuit() == sgs.Card_Spade then count = count + 1 end
			if count >= n then return true end
		end
		for _, card in sgs.qlist(player:getEquips()) do
			if card:getSuit() == sgs.Card_Spade then count = count + 1 end
			if count >= n then return true end
		end
		return false
	end
}


sgkgodzhaoyun:addSkill(sgkgodjuejing)
sgkgodzhaoyun:addSkill(sgkgodlonghun)


sgs.LoadTranslationTable{
    ["sgkgodzhaoyun"] = "神赵云",
	["#sgkgodzhaoyun"] = "神威如龙",
	["&sgkgodzhaoyun"] = "神赵云",
	["~sgkgodzhaoyun"] = "血染鳞甲，龙坠九天……",
	["designer:sgkgodzhaoyun"] = "魂烈",
    ["illustrator:sgkgodzhaoyun"] = "魂烈",
    ["cv:sgkgodzhaoyun"] = "魂烈",
	["sgkgodjuejing"] = "绝境",
	[":sgkgodjuejing"] = "锁定技，一名角色的回合结束时，若你的体力值：不大于1，你摸一张牌；大于1，你失去1点体力，然后摸两张牌。",
	["$sgkgodjuejing"] = "龙战于野，其血玄黄。",
	["sgkgodlonghun"] = "龙魂",
	[":sgkgodlonghun"] = "你可以将X张同花色的牌按以下规则使用或打出：红桃当【桃】；方块当火【杀】；黑桃当【无懈可击】；梅花当【闪】。（X为你的体力值且至少为1）",
	["$sgkgodlonghun1"] = "金甲映日，驱邪祛秽。",
	["$sgkgodlonghun2"] = "腾龙行云，首尾不见。",
	["$sgkgodlonghun3"] = "潜龙于渊，涉灵愈伤。",
	["$sgkgodlonghun4"] = "千里一怒，红莲灿世。",
}


--神张辽
sgkgodzhangliao=sgs.General(extension,"sgkgodzhangliao","sy_god","4")


--[[
	技能名：逆战
	相关武将：神张辽
	技能描述：锁定技，一名角色的准备阶段，若其：已受伤，获得1个“逆战”标记；未受伤，移去1个“逆战”标记。
	引用：sgkgodnizhan
]]--
sgkgodnizhan = sgs.CreateTriggerSkill{
	name = "sgkgodnizhan",
	events = {sgs.EventPhaseStart, sgs.EventLoseSkill},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data, room)
		if not room:findPlayerBySkillName(self:objectName()) then return false end
		local s = room:findPlayerBySkillName(self:objectName())
		if not s then return false end
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				if player:isWounded() then
					room:sendCompulsoryTriggerLog(s, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:doAnimate(1, s:objectName(), player:objectName())
					player:gainMark("&nizhan")
				else
					if player:getMark("&nizhan") > 0 then
						room:sendCompulsoryTriggerLog(s, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						room:doAnimate(1, s:objectName(), player:objectName())
						player:loseMark("&nizhan")
					end
				end
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == self:objectName() then
				for _,p in sgs.qlist(room:getAllPlayers()) do
					if p:getMark("&nizhan")>0 then p:loseAllMarks("&nizhan") end
				end
			end
		end
		return false
	end,
	can_trigger = function()
		return true
	end
}

sgkgodnizhanClear = sgs.CreateTriggerSkill{
	name = "#sgkgodnizhan",
	events = {sgs.Death},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data, room)
		local death = data:toDeath()
		if death.who:hasSkill("sgkgodnizhan") then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("&nizhan")>0 then p:loseAllMarks("&nizhan") end
			end
		end
	end,
	can_trigger = function()
		return target and target:hasSkill("sgkgodnizhan")
	end
}


extension:insertRelatedSkills("sgkgodnizhan","#sgkgodnizhan")


--[[
	技能名：摧锋
	相关武将：神张辽
	技能描述：出牌阶段限一次，你可以移动场上1个“逆战”标记，视为移动前的角色对移动后的角色使用【杀】（不计入每回合使用次数限制）。
	引用：sgkgodcuifeng
]]--
sgkgodcuifengCard = sgs.CreateSkillCard{
	name = "sgkgodcuifengCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select, Self)
		if #targets == 0 then
			return to_select:getMark("&nizhan") > 0
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local players = room:getAlivePlayers()
		players:removeOne(target)
		local t = room:askForPlayerChosen(source, players, "sgkgodcuifeng")
	    if t then
			room:doAnimate(1, target:objectName(), t:objectName())
			target:loseMark("&nizhan")
			t:gainMark("&nizhan")
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			slash:setSkillName("cuifeng_slash")
			if not sgs.Sanguosha:isProhibited(target, t, slash) then
				local use = sgs.CardUseStruct()
				use.from = target
				use.to:append(t)
				use.card = slash
				room:useCard(use, false)
			end
		end
	end
}

sgkgodcuifeng = sgs.CreateZeroCardViewAsSkill{
	name = "sgkgodcuifeng",
	view_as = function()
		return sgkgodcuifengCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#sgkgodcuifengCard")
	end
}


--[[
	技能名：威震
	相关武将：神张辽
	技能描述：锁定技，若一名角色拥有的“逆战”标记数不小于：1，你摸牌阶段的摸牌数+1；2，其摸牌阶段的摸牌数-1；3，你对其造成的伤害+1；4，其非锁定技无效。
	引用：sgkgodweizhen
]]--
function forbidNonCompulsorySkills(vic, trigger_name)
	local room = vic:getRoom()
	local skill_list = {}
	for _, sk in sgs.qlist(vic:getVisibleSkillList()) do
		if not table.contains(skill_list, sk:objectName()) then 
			if sk:getFrequency() ~= sgs.Skill_Compulsory and sk:getFrequency() ~= sgs.Skill_Wake then
				table.insert(skill_list, sk:objectName())
			end
		end
	end
	if #skill_list > 0 then
		vic:setTag("Qingcheng", sgs.QVariant(table.concat(skill_list, "+")))
		for _, skill_qc in ipairs(skill_list) do
			room:addPlayerMark(vic, "Qingcheng"..skill_qc)
			room:addPlayerMark(vic, trigger_name..skill_qc)
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:filterCards(p, p:getCards("he"), true)
			end
		end
	end
end

function activateAllSkills(vic, trigger_name)
	local room = vic:getRoom()
	local Qingchenglist = vic:getTag("Qingcheng"):toString():split("+")
	if #Qingchenglist > 0 then
		for _, name in ipairs(Qingchenglist) do
			room:setPlayerMark(vic, "Qingcheng"..name, 0)
			room:setPlayerMark(vic, trigger_name..name, 0)
		end
		vic:removeTag("Qingcheng")
		for _, t in sgs.qlist(room:getAllPlayers()) do
			room:filterCards(t, t:getCards("he"), true)
		end
	end
end

sgkgodweizhen = sgs.CreateTriggerSkill{
	name = "sgkgodweizhen",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DrawNCards, sgs.DamageCaused, sgs.MarkChanged, sgs.EventAcquireSkill, sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data, room)
		if not room:findPlayerBySkillName(self:objectName()) then return false end
		local zhangliao = room:findPlayerBySkillName(self:objectName())
		if event == sgs.DrawNCards then
			local x = 0
			if player:getMark("&nizhan") >= 2 then x = x - 1 end
			if player:getSeat() == zhangliao:getSeat() then
				for _, pe in sgs.qlist(room:getAlivePlayers()) do
					if pe:getMark("&nizhan") >= 1 then x = x + 1 end
				end
				if x ~= 0 then
					room:sendCompulsoryTriggerLog(zhangliao, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
				end
			end
			data:setValue(data:toInt() + x)
		elseif event == sgs.DamageCaused then
			local damage = data:toDamage()
			if damage.from and damage.from:getSeat() == zhangliao:getSeat() and damage.to:getMark("&nizhan") >= 3 then
				room:broadcastSkillInvoke(self:objectName())
				room:sendCompulsoryTriggerLog(zhangliao, self:objectName())
				room:doAnimate(1, zhangliao:objectName(), damage.to:objectName())
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == "&nizhan" then
				if mark.who:getMark("&nizhan") >= 4 and mark.who:getMark(self:objectName()) == 0 then
					room:sendCompulsoryTriggerLog(zhangliao, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:doAnimate(1, zhangliao:objectName(), mark.who:objectName())
					room:addPlayerMark(mark.who, self:objectName())
					forbidNonCompulsorySkills(mark.who, self:objectName())
				end
				if mark.who:getMark("&nizhan") < 3 then
					if mark.who:getMark(self:objectName()) > 0 then
						room:setPlayerMark(mark.who, self:objectName(), 0)
						activateAllSkills(mark.who, self:objectName())
					end
				end
			end
		elseif event == sgs.EventAcquireSkill then
			if data:toString() == self:objectName() then
				for _, pe in sgs.qlist(room:getAlivePlayers()) do
					if pe:getMark("&nizhan") >= 4 and pe:getMark(self:objectName()) == 0 then
						room:doAnimate(1, zhangliao:objectName(), pe:objectName())
						room:addPlayerMark(pe, self:objectName())
						forbidNonCompulsorySkills(pe, self:objectName())
					end
				end
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == self:objectName() then
				for _, pe in sgs.qlist(room:getAlivePlayers()) do
					if pe:getMark(self:objectName()) > 0 then
						room:setPlayerMark(mark.who, self:objectName(), 0)
						activateAllSkills(mark.who, self:objectName())
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return true
	end
}


sgkgodzhangliao:addSkill(sgkgodnizhan)
sgkgodzhangliao:addSkill(sgkgodnizhanClear)
sgkgodzhangliao:addSkill(sgkgodcuifeng)
sgkgodzhangliao:addSkill(sgkgodweizhen)


sgs.LoadTranslationTable{
	["sgkgodzhangliao"] = "神张辽",
	["&sgkgodzhangliao"] = "神张辽",
	["#sgkgodzhangliao"] = "威名裂胆",
	["sgkgodnizhan"] = "逆战",
	[":sgkgodnizhan"] = "锁定技，一名角色的准备阶段，若其：已受伤，获得1个“逆战”标记；未受伤，移去1个“逆战”标记。",
	["nizhan"] = "逆战",
	["$sgkgodnizhan"] = "已是成败二分之时！",
	["sgkgodcuifeng"] = "摧锋",
	[":sgkgodcuifeng"] = "出牌阶段限一次，你可以移动场上1个“逆战”标记，视为移动前的角色对移动后的角色使用【杀】（不计入每回合使用次数限制）。",
	["$sgkgodcuifeng"] = "全军化为一体，总攻！",
	["sgkgodweizhen"] = "威震",
	[":sgkgodweizhen"] = "锁定技，若一名角色拥有的“逆战”标记数不小于：1，你摸牌阶段的摸牌数+1；2，其摸牌阶段的摸牌数-1；3，你对其造成的伤害+1；4，其非锁定"..
	"技无效。",
	["$sgkgodweizhen"] = "让你见识我军的真正实力！",
	["~sgkgodzhangliao"] = "不求留名青史，但求无愧于心……",
	["designer:sgkgodzhangliao"] = "魂烈",
	["illustrator:sgkgodzhangliao"] = "魂烈",
	["cv:sgkgodzhangliao"] = "魂烈",
}


--神陆逊
sgkgodluxun=sgs.General(extension,"sgkgodluxun","sy_god",3)


--[[
	技能名：劫焰
	相关武将：神陆逊
	技能描述：当一张红色【杀】或红色非延时锦囊仅指定一个目标后，你可以弃置一张手牌令此牌无效，然后对目标角色造成1点火焰伤害。
	引用：sgkgodjieyan
]]--
sgkgodjieyan = sgs.CreateTriggerSkill{
	name = "sgkgodjieyan",
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data, room)
		local use = data:toCardUse()
		if not room:findPlayerBySkillName(self:objectName()) then return false end
		local s = room:findPlayerBySkillName(self:objectName())
		if not use.card:isRed() then return false end
		if use.to:length() ~= 1 then return false end
		if use.card:isKindOf("Slash") or use.card:isNDTrick() then
			if not s then return false end
			if s:isKongcheng() then return false end
			if not s:askForSkillInvoke(self:objectName(),data) then return false end
			local prompt = string.format("@sgkgodjieyan:%s:%s", use.card:objectName(), use.to:at(0):objectName())
			local c = room:askForCard(s, ".|.|.|hand|.", prompt, data, sgs.Card_MethodDiscard)
			if not c then return false end
			room:broadcastSkillInvoke(self:objectName())
			local to = use.to:at(0)
			room:doAnimate(1, s:objectName(), to:objectName())
			room:damage(sgs.DamageStruct(self:objectName(), s, to, 1, sgs.DamageStruct_Fire))
			return true
		end
	end,
	can_trigger=function()
		return true
	end
}


--[[
	技能名：焚营
	相关武将：神陆逊
	技能描述：当一名角色受到火焰伤害后，若你的手牌数不大于体力上限，你可以弃置一张红色牌，然后对该其或与其距离为1的一名角色造成等量的火焰伤害。
	引用：sgkgodfenying
]]--
sgkgodfenying = sgs.CreateTriggerSkill{
	name = "sgkgodfenying",
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data, room)
		local damage = data:toDamage()
		if not room:findPlayerBySkillName(self:objectName()) then return false end
		local s = room:findPlayerBySkillName(self:objectName())
		if not damage.to:isAlive() then return false end
		if damage.nature ~= sgs.DamageStruct_Fire then return false end
		if damage.damage <= 0then return false end
		local n = damage.damage
		if s:isNude() then return false end
		if s:getHandcardNum() > s:getMaxHp() then return false end
		local distance = 1000
		for _,p in sgs.qlist(room:getOtherPlayers(damage.to)) do
			if p:distanceTo(damage.to) < distance then
				distance = p:distanceTo(damage.to)
			end
		end
		local all = sgs.SPlayerList()
		for _,p in sgs.qlist(room:getOtherPlayers(damage.to)) do
			if p:distanceTo(damage.to) == distance then
				all:append(p)
			end
		end
		all:append(damage.to)
		if all:isEmpty() then return false end
		local c_red = 0
		for _, c in sgs.qlist(s:getCards("he")) do
			if c:isRed() then c_red = c_red + 1 end
		end
		if c_red == 0 then return false end
		if not s:askForSkillInvoke(self:objectName(), data) then return false end
		local card = room:askForCard(s, ".|red|.|.", "@sgkgodfenying", data, sgs.Card_MethodDiscard)
		if not card then return false end
		local t = room:askForPlayerChosen(s, all, self:objectName())
		room:doAnimate(1, s:objectName(), t:objectName())
		room:broadcastSkillInvoke(self:objectName())
		room:damage(sgs.DamageStruct(self:objectName(), s, t, n, sgs.DamageStruct_Fire))
	end,
	can_trigger = function()
		return true
	end
}


sgkgodluxun:addSkill(sgkgodjieyan)
sgkgodluxun:addSkill(sgkgodfenying)


sgs.LoadTranslationTable{
	["sgkgodluxun"] = "神陆逊",
	["&sgkgodluxun"] = "神陆逊",
	["#sgkgodluxun"] = "焚炎灭阵",
	["sgkgodjieyan"] = "劫焰",
	["#jieyan"] = "<font color=\"gold\"><b>【劫焰】</b></font>效果触发，%from 对 %to 使用的 %arg 无效。",
	[":sgkgodjieyan"] = "当一张红色【杀】或红色非延时锦囊仅指定一名角色为目标后，你可以弃置一张手牌令其无效，然后对目标角色造成1点火焰伤害。",
	["@sgkgodjieyan"] = "你可以弃置一张牌，令此%src无效，并对%dest造成1点火焰伤害。",
	["sgkgodfenying"] = "焚营",
	[":sgkgodfenying"] = "当一名角色受到火焰伤害后，若你的手牌数不大于体力上限，你可以弃置一张红色牌，然后对该其或与其距离为1的一名角色造成等量的火焰伤害。",
	["@sgkgodfenying"] = "你可以弃置一张红色牌发动“焚营”",
	["$sgkgodjieyan"] = "炙浊之气，已溢满万剑。",
	["$sgkgodfenying"] = "随着大火，往生去吧！",
	["~sgkgodluxun"] = "火，终究是……无情之物……",
	["designer:sgkgodluxun"] = "魂烈",
	["illustrator:sgkgodluxun"] = "魂烈",
	["cv:sgkgodluxun"] = "魂烈",
}


--神郭嘉
sgkgodguojia=sgs.General(extension,"sgkgodguojia","sy_god", 3, true, true)


--[[
	技能名：天启
	相关武将：神郭嘉
	技能描述：出牌阶段限一次，或当你于濒死状态外需要使用或打出一张基本牌或非延时锦囊牌时，你可以将牌堆顶的牌当此牌使用或打出，若转化前后的牌类别不同，你于此
	牌结算前失去1点体力。
	引用：sgkgodtianqi
]]--
function tianduguojia(guojia, c)
	local room = sgs.Sanguosha:currentRoom()
	local drawcard = sgs.QList2Table(room:getDrawPile())
	local id = drawcard[1]
	local card = sgs.Sanguosha:getCard(id)
	if card:isKindOf("BasicCard") and c:isKindOf("BasicCard") then return false end
	if card:isKindOf("TrickCard") and c:isKindOf("TrickCard") then return false end
	if card:isKindOf("EquipCard") and c:isKindOf("EquipCard") then return false end
	return true
end

sgkgodtianqiCard = sgs.CreateSkillCard{
	name = "sgkgodtianqi",
    will_throw = false,
	filter = function(self, targets, to_select)
		local players = sgs.PlayerList()
		for i = 1 , #targets do
			players:append(targets[i])
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card = nil
			if self:getUserString() and self:getUserString() ~= "" then
				card = sgs.Sanguosha:cloneCard(self:getUserString():split("+")[1])
				return card and card:targetFilter(players, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, players)
			end
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return false
		end
		local _card = sgs.Self:getTag("sgkgodtianqi"):toCard()
		if _card == nil then
			return false
		end
		local card = sgs.Sanguosha:cloneCard(_card)
		card:deleteLater()
		return card and card:targetFilter(players, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, players)
	end,
	feasible = function(self, targets)
		local players = sgs.PlayerList()
		for i = 1 , #targets do
			players:append(targets[i])
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card = nil
			if self:getUserString() and self:getUserString() ~= "" then
				card = sgs.Sanguosha:cloneCard(self:getUserString():split("+")[1])
				return card and card:targetsFeasible(players, sgs.Self)
			end
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return true
		end
		local _card = sgs.Self:getTag("sgkgodtianqi"):toCard()
		if _card == nil then
			return false
		end
		local card = sgs.Sanguosha:cloneCard(_card)
		card:deleteLater()
		return card and card:targetsFeasible(players, sgs.Self)
	end ,
	on_validate = function(self, card_use)
		local guojia = card_use.from
		local room = guojia:getRoom()
		if room:getCurrent():objectName() == guojia:objectName() then room:setPlayerFlag(guojia, "tianqi_used") end
		if not guojia:isAlive() then return nil end
		local user_str = self:getUserString()
		if self:getUserString() == "slash" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local tianqi_list = {}
			table.insert(tianqi_list, "slash")
			local sts = sgs.GetConfig("BanPackages", ""):split(",")
			if not table.contains(sts, "maneuvering") then
				table.insert(tianqi_list, "thunder_slash")
				table.insert(tianqi_list, "fire_slash")
			end
			user_str = room:askForChoice(guojia, "tianqi_slash", table.concat(tianqi_list, "+"))
			guojia:setTag("TianqiSlash", sgs.QVariant(user_str))
		end
		if room:getDrawPile():isEmpty() then room:swapPile() end
		local poi = sgs.Sanguosha:cloneCard(user_str, sgs.Card_NoSuit, 0)
		local drawcard = sgs.QList2Table(room:getDrawPile())
		local id = drawcard[1]
		local card = sgs.Sanguosha:getCard(id)
		local ids = sgs.IntList()
		ids:append(id)
		room:fillAG(ids)
		local news = sgs.LogMessage()
		news.type = "#tianqiclaim"
		news.from = guojia
		news.arg = poi:objectName()
		room:sendLog(news)
		local log = sgs.LogMessage()
		log.type = "#tianqishow"
		log.from = guojia
		log.card_str = card:toString()
		room:sendLog(log)
		room:getThread():delay(500)
		room:clearAG()
		if tianduguojia(guojia, poi) then room:loseHp(guojia) end
		if guojia:isAlive() then
			local use_card = sgs.Sanguosha:cloneCard(user_str, sgs.Card_NoSuit, 0)
			use_card:setSkillName("sgkgodtianqi")
			use_card:addSubcard(card)
			use_card:deleteLater()
			local tos = card_use.to
			for _, to in sgs.qlist(tos) do
				local skill = room:isProhibited(guojia, to, use_card)
				if skill then
					card_use.to:removeOne(to)
				end
			end
			return use_card
		else
			return nil
		end
	end ,
	on_validate_in_response = function(self, guojia)
		local room = guojia:getRoom()
		if not guojia:isAlive() then return nil end
		local to_tianqi = ""
		if self:getUserString() == "slash" then
			local tianqi_list = {}
			table.insert(tianqi_list, "slash")
			local sts = sgs.GetConfig("BanPackages", "")
			if not string.find(sts, "maneuvering") then
				table.insert(tianqi_list, "normal_slash")
				table.insert(tianqi_list, "thunder_slash")
				table.insert(tianqi_list, "fire_slash")
			end
			to_tianqi = room:askForChoice(guojia, "tianqi_slash", table.concat(tianqi_list, "+"))
			guojia:setTag("TianqiSlash", sgs.QVariant(to_tianqi))
		else
			to_tianqi = self:getUserString()
		end
		if room:getDrawPile():isEmpty() then room:swapPile() end
		local user_str = ""
		if to_tianqi == "slash" then
			user_str = "slash"
		elseif to_tianqi == "normal_slash" then
			user_str = "slash"
		else
			user_str = to_tianqi
		end
		local poi = sgs.Sanguosha:cloneCard(user_str, sgs.Card_NoSuit, 0)
		local drawcard = sgs.QList2Table(room:getDrawPile())
		local id = drawcard[1]
		local card = sgs.Sanguosha:getCard(id)
		local ids = sgs.IntList()
		ids:append(id)
		room:fillAG(ids)
		local news = sgs.LogMessage()
		news.type = "#tianqiclaim"
		news.from = guojia
		news.arg = poi:objectName()
		room:sendLog(news)
		local log = sgs.LogMessage()
		log.type = "#tianqishow"
		log.from = guojia
		log.card_str = card:toString()
		room:sendLog(log)
		room:getThread():delay(500)
		room:clearAG()
		if tianduguojia(guojia, poi) then room:loseHp(guojia) end
		if guojia:isAlive() then
			local use_card = sgs.Sanguosha:cloneCard(user_str, sgs.Card_NoSuit, 0)
			use_card:setSkillName("sgkgodtianqi")
			use_card:addSubcard(card)
			use_card:deleteLater()
			return use_card
		else
			return nil
		end
	end
}

sgkgodtianqiVS = sgs.CreateZeroCardViewAsSkill{
	name = "sgkgodtianqi",
	response_or_use = true,
	enabled_at_response = function(self, player, pattern)
		if player:hasFlag("Global_Dying") then return false end
		if string.sub(pattern, 1, 1) == "." or string.sub(pattern, 1, 1) == "@" then return false end
        if pattern == "peach" then
		    return not player:hasFlag("Global_PreventPeach")
		end
		if string.find(pattern, "[%u%d]") then return false end
		return true
	end,
	enabled_at_play = function(self, player)
		if player:hasFlag("Global_Dying") then return false end
		return not player:hasFlag("tianqi_used")
	end,
	view_as = function(self)
	    if not sgs.Self:hasFlag("Global_Dying") then
		    local pattern
			if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			    local c = sgs.Self:getTag("sgkgodtianqi"):toCard()
				if c then
					pattern = c:objectName()
				else
					return nil
				end
			else
				if sgs.Self:getTag("TianqiSlash"):toString() ~= "" then
					pattern = sgs.Self:getTag("TianqiSlash"):toString()
				else
					pattern = sgs.Sanguosha:getCurrentCardUsePattern()
				end
		    end
		    if pattern then
				local tq = sgkgodtianqiCard:clone()
				tq:setUserString(pattern)
				return tq
			else
				return nil
			end
		end
	end,
	enabled_at_nullification = function(self, player)
		return not player:hasFlag("Global_Dying")
	end
}

sgkgodtianqi = sgs.CreateTriggerSkill{
	name = "sgkgodtianqi",
	events= {sgs.PreCardUsed, sgs.EventPhaseChanging},
	view_as_skill = sgkgodtianqiVS,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.PreCardUsed then
			local use = data:toCardUse()
			if use.card and use.card:getSkillName() == "sgkgodtianqi" and player:getPhase() == sgs.Player_Play then
				if not player:hasFlag("tianqi_used") then room:setPlayerFlag(player, "tianqi_used") end
			end
		else
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive and player:hasFlag("tianqi_used") then
				room:setPlayerFlag(player, "-tianqi_used")
			end
		end
	end,
	can_trigger = function()
		return true
	end
}
sgkgodtianqi:setGuhuoDialog("lr")


--[[
	技能名：天机
	相关武将：神郭嘉
	技能描述：一名角色的出牌阶段开始时，你可以观看牌堆顶的牌，然后若你的手牌：最多，你可以用一张手牌替换之；不为最多，你可以获得之。
	引用：sgkgodtianji
]]--
function card2type(card)
	if card:isKindOf("BasicCard") then return "BasicCard" end
	if card:isKindOf("TrickCard") then return "TrickCard" end
	if card:isKindOf("EquipCard") then return "EquipCard" end
end

sgkgodtianji=sgs.CreateTriggerSkill{
	name = "sgkgodtianji",
	priority = -2,
	events = {sgs.EventPhaseStart},
	frequency = sgs.Skill_Frequent,
	on_trigger= function(self, event, player, data, room)
		if room:findPlayersBySkillName(self:objectName()):isEmpty() then return false end
		local s = room:findPlayerBySkillName(self:objectName())
		if player:getPhase() ~= sgs.Player_Play then return false end
		if room:getDrawPile():isEmpty() then room:swapPile() end
		if s:askForSkillInvoke(self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName())
			local ids = sgs.IntList()
			local drawpile = room:getDrawPile()
			drawpile = sgs.QList2Table(drawpile)
			local id = drawpile[1]
			ids:append(id)
			room:fillAG(ids, s)
			room:getThread():delay(450)
			local flag = false
			local x = s:getHandcardNum()
			local choices = {"tianji_exchange","tianji_obtain","cancel"}
			for _,p in sgs.qlist(room:getOtherPlayers(s)) do
				if p:getHandcardNum() > x then
					flag = true
					break
				end
			end
			s:setTag("tianji_canget", sgs.QVariant(flag))
			if s:isKongcheng() then
				table.removeOne(choices, "tianji_exchange")
			end
			if flag == false then
				table.removeOne(choices,"tianji_obtain")
			end
			local card = sgs.Sanguosha:getCard(id)
			local choice = room:askForChoice(s, self:objectName(), table.concat(choices,"+"))
			if choice == "tianji_exchange" then
				local prompt = string.format("@tianji_exchange:%s:%s:%s", card:objectName(), card:getSuitString(), card:getNumberString())
				local c = room:askForCard(s, ".!", prompt, data, sgs.Card_MethodNone)
				local move = sgs.CardsMoveStruct()
				move.card_ids:append(c:getEffectiveId())
				move.to_place = sgs.Player_DrawPile
				move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, s:objectName(), self:objectName(), "")
				room:moveCardsAtomic(move, false)
				room:obtainCard(s, id, false)
				s:removeTag("top_card")
			elseif choice == "tianji_obtain" then
				room:obtainCard(s, id, false)
				s:removeTag("top_card")
			end
			room:clearAG()
			s:removeTag("tianji_canget")
		end
	end,
	can_trigger = function()
		return true
	end
}


sgkgodguojia:addSkill(sgkgodtianqi)
sgkgodguojia:addSkill(sgkgodtianji)


sgs.LoadTranslationTable{
	["sgkgodguojia"] = "神郭嘉",
	["&sgkgodguojia"] = "神郭嘉",
	["#sgkgodguojia"] = "天人合一",
	["#tianqishow"] = "%from 亮出了牌堆顶的 %card",
	["sgkgodtianqi"] = "天启",
	[":sgkgodtianqi"] = "出牌阶段限一次，或当你于濒死状态外需要使用或打出一张基本牌或非延时锦囊牌时，你可以将牌堆顶的牌当此牌使用或打出，若转化前后的牌类别"..
	"不同，你于此牌结算前失去1点体力。",
	["#tianqishow"] = "%from 亮出了牌堆顶的 %card",
	["tianqi_slash"] = "天启",
	["#tianqiclaim"] = "%from 声明了【%arg】",
	["sgkgodtianji"] = "天机",
	["@tianji_exchange"] = "请用一张手牌来替换牌堆顶的这张%src[%dest%arg]。",
	[":sgkgodtianji"] = "一名角色的出牌阶段开始时，你可以观看牌堆顶的牌，然后若你的手牌：最多，你可以用一张手牌替换之；不为最多，你可以获得之。",
	["tianji_exchange"] = "用一张手牌替换之",
	["tianji_obtain"] = "获得之",
	["Sgkgodtianjicard"] = "请选择用于交换的手牌",
	["$sgkgodtianqi1"] = "荡破天光，领得天启！",
	["$sgkgodtianqi2"] = "谋事在人，成事在天。",
	["$sgkgodtianji"] = "天机可知，却不可说。",
	["~sgkgodguojia"] = "窥天意，竭心力，皆为吾主！",
	["designer:sgkgodguojia"] = "魂烈",
	["illustrator:sgkgodguojia"] = "魂烈",
	["cv:sgkgodguojia"] = "魂烈",
}


--神吕布
sgkgodlvbu = sgs.General(extension, "sgkgodlvbu", "sy_god", 5)


--[[
	技能名：狂暴
	相关武将：神吕布
	技能描述：锁定技，游戏开始时，你获得2个“暴怒”标记。当你造成或受到伤害后，你获得1个“暴怒”标记。
	引用：sgkgodkuangbao
]]--
sgkgodkuangbao = sgs.CreateTriggerSkill{
    name = "sgkgodkuangbao",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.Damaged, sgs.Damage},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.GameStart then
		    room:broadcastSkillInvoke(self:objectName())
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:notifySkillInvoked(player, self:objectName())
			player:gainMark("&fierce", 2)
		else
		    room:broadcastSkillInvoke(self:objectName())
			local X = 0
			if player:hasFlag("wuqian_buff") then
			    X = 2
			else
			    X = 1
			end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:notifySkillInvoked(player, self:objectName())
			player:gainMark("&fierce", X)
		end
	end
}


--[[
	技能名：无谋
	相关武将：神吕布
	技能描述：锁定技，当你使用非延时锦囊牌时，你选择一项：1.弃置1个“暴怒”标记；2.受到1点伤害。
	引用：sgkgodwumou
]]--
sgkgodwumou = sgs.CreateTriggerSkill{
	name = "sgkgodwumou",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data, room)
		local use = data:toCardUse()
		if use.card:isNDTrick() then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			room:notifySkillInvoked(player, self:objectName())
			local num = player:getMark("&fierce")
			if num >= 1 and room:askForChoice(player, self:objectName(), "loseonemark+getdamaged") == "loseonemark" then
				player:loseMark("&fierce")
			else
				room:damage(sgs.DamageStruct(self:objectName(), nil, player))
			end
		end
		return false
	end
}


--[[
	技能名：无前
	相关武将：神吕布
	技能描述：出牌阶段限一次，你可以弃置2个“暴怒”标记，若如此做，你于此回合内拥有“无双”且造成伤害后额外获得1个“暴怒”标记。
	引用：sgkgodwuqian
]]--
sgkgodwuqianCard = sgs.CreateSkillCard{
    name = "sgkgodwuqianCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
	    source:loseMark("&fierce", 2)
		source:setFlags("wuqian_buff")
		if source:hasSkill("wushuang") or source:hasSkill("sy_wushuang") then 
		    source:setFlags("have_wushuang")
			return false 
		end
		room:acquireSkill(source, "sy_wushuang")
	end
}

sgkgodwuqianVS = sgs.CreateZeroCardViewAsSkill{
    name = "sgkgodwuqian",
	view_as = function()
	    return sgkgodwuqianCard:clone()
	end,
	enabled_at_play = function(self, player)
	    return (not player:hasUsed("#sgkgodwuqianCard")) and player:getMark("&fierce") >= 2
	end
}

sgkgodwuqian = sgs.CreateTriggerSkill{
	name = "sgkgodwuqian",
	events = {sgs.EventPhaseChanging, sgs.Death},
	view_as_skill = sgkgodwuqianVS,
	can_trigger = function(self, target)
		return target and target:hasFlag("wuqian_buff")
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
		end
		if event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then
				return false
			end
		end
		if not player:hasFlag("have_wushuang") then
		    room:detachSkillFromPlayer(player, "sy_wushuang", false, true)
		else
		    player:setFlags("-have_wushuang")
		end
		return false
	end
}


--[[
	技能名：神愤
	相关武将：神吕布
	技能描述：出牌阶段限一次，你可以弃置6个“暴怒”标记，若如此做，你对所有其他角色各造成1点伤害，然后这些角色弃置所有牌，你翻面。
	引用：sgkgodshenfen
]]--
sgkgodshenfenCard = sgs.CreateSkillCard{
	name = "sgkgodshenfenCard" ,
	target_fixed = true ,
	on_use = function(self, room, source, targets)
		source:loseMark("&fierce", 6)
		room:doSuperLightbox("sgkgodlvbu", "sgkgodshenfen")
		local players = room:getOtherPlayers(source)
		for _, player in sgs.qlist(players) do
			room:doAnimate(1, source:objectName(), player:objectName())
		end
		for _, player in sgs.qlist(players) do
			room:damage(sgs.DamageStruct("sgkgodshenfen", source, player))
		end
		for _, player in sgs.qlist(players) do
			player:throwAllHandCardsAndEquips()
		end
		source:turnOver()
	end
}

sgkgodshenfen = sgs.CreateZeroCardViewAsSkill{
	name = "sgkgodshenfen",
	view_as = function()
		return sgkgodshenfenCard:clone()
	end , 
	enabled_at_play = function(self,player)
		return player:getMark("&fierce") >= 6 and not player:hasUsed("#sgkgodshenfenCard")
	end
}


sgkgodlvbu:addSkill(sgkgodkuangbao)
sgkgodlvbu:addSkill(sgkgodwumou)
sgkgodlvbu:addSkill(sgkgodwuqian)
sgkgodlvbu:addSkill(sgkgodshenfen)


sgs.LoadTranslationTable{
    ["sgkgodlvbu"] = "神吕布",
	["&sgkgodlvbu"] = "神吕布",
	["#sgkgodlvbu"] = "修罗之道",
	["~sgkgodlvbu"] = "我不会消失！不会——",
	["fierce"] = "暴怒",
	["sgkgodkuangbao"] = "狂暴",
	[":sgkgodkuangbao"] = "锁定技，游戏开始时，你获得2个“暴怒”标记。当你造成或受到伤害后，你获得1个“暴怒”标记。",
	["$sgkgodkuangbao"] = "找死！",
	["sgkgodwumou"] = "无谋",
	[":sgkgodwumou"] = "锁定技，当你使用非延时锦囊牌时，你选择一项：1、弃1枚“暴怒”标记；2、受到1点伤害。",
	["loseonemark"] = "弃1枚“暴怒”标记",
	["getdamaged"] = "受到1点伤害",
	["$sgkgodwumou"] = "老子可不管这些！",
	["sgkgodwuqian"] = "无前",
	[":sgkgodwuqian"] = "出牌阶段限一次，你可以弃置2个“暴怒”标记，若如此做，你于此回合内拥有“无双”且造成伤害后额外获得1个“暴怒”标记。",
	["$sgkgodwuqian"] = "看你还能挣扎多久？",
	["sgkgodshenfen"] = "神愤",
	[":sgkgodshenfen"] = "出牌阶段限一次，你可以弃置6个“暴怒”标记，若如此做，你对所有其他角色各造成1点伤害，然后这些角色弃置所有牌，你翻面。",
	["$sgkgodshenfen"] = "神挡杀神！佛挡杀佛！",
	["designer:sgkgodlvbu"] = "魂烈",
    ["illustrator:sgkgodlvbu"] = "魂烈",
    ["cv:sgkgodlvbu"] = "魂烈",
}


--神关羽
sgkgodguanyu = sgs.General(extension, "sgkgodguanyu", "sy_god", 5)


--[[
	技能名：武神
	相关武将：神关羽
	技能描述：锁定技，你的【杀】和【桃】均视为【决斗】。
	引用：sgkgodwushen
]]--
sgkgodwushen = sgs.CreateFilterSkill{
    name = "sgkgodwushen",
	view_filter = function(self, to_select)
		local room = sgs.Sanguosha:currentRoom()
		local place = room:getCardPlace(to_select:getEffectiveId())
		return (to_select:isKindOf("Slash") or to_select:isKindOf("Peach")) and (place == sgs.Player_PlaceHand)
	end,
	view_as = function(self, card)
		local duel = sgs.Sanguosha:cloneCard("duel", card:getSuit(), card:getNumber())
		duel:setSkillName(self:objectName())
		local wushen = sgs.Sanguosha:getWrappedCard(card:getId())
		wushen:takeOver(duel)
		return wushen
	end
}


--[[
	技能名：索魂
	相关武将：神关羽
	技能描述：锁定技，当你受到1点伤害后，若来源不为你，其获得1个“魂”标记。当你进入濒死状态时，你减一半（向上取整）的体力上限并回复体力至体力上限，若如此做，
	拥有“魂”标记的角色各弃置所有的“魂”标记，然后你对其造成其弃置的“魂”标记数的伤害。
	引用：sgkgodsuohun
]]--
sgkgodsuohun = sgs.CreateTriggerSkill{
    name = "sgkgodsuohun",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreDamageDone, sgs.Damaged, sgs.Dying},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.PreDamageDone then
		    local damage = data:toDamage()
			if damage.from and damage.to:objectName() == player:objectName() then
				if player:getMaxHp() == 1 then
					local k = sgs.QVariant()
					k:setValue(damage.from)
				    player:setTag("final_push", k)
				end
			end
		elseif event == sgs.Damaged then
		    local damage = data:toDamage()
			if damage.from and damage.from:objectName() ~= player:objectName() and damage.to:objectName() == player:objectName() then
			    room:doAnimate(1, player:objectName(), damage.from:objectName())
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:notifySkillInvoked(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				damage.from:gainMark("&sk_soul", damage.damage)
			end
		elseif event == sgs.Dying then
		    local dying = data:toDying()
			if dying.who:objectName() == player:objectName() then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:notifySkillInvoked(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local killer = dying.who:getTag("final_push"):toPlayer()
				if dying.who:getMaxHp() == 1 and killer then
					local damage = sgs.DamageStruct()
					damage.from = killer
					room:killPlayer(player, damage)  --如果有人在神关羽体力上限为1时给了他最后一下，直接视为这个人杀了神关羽，《极略三国》上曾经就是这么处理的
					return false
				end
				local n = math.ceil(player:getMaxHp()/2)
				room:loseMaxHp(player, n)
				if player:isDead() then return false end
				room:broadcastSkillInvoke(self:objectName())
				local re = sgs.RecoverStruct()
			    re.who = player
				re.recover = player:getMaxHp() - player:getHp()
		        room:recover(player, re, true)
				for _, t in sgs.qlist(room:getOtherPlayers(player)) do
				    room:doAnimate(1, player:objectName(), t:objectName())
				end
				for _, t in sgs.qlist(room:getOtherPlayers(player)) do
				    room:setPlayerMark(t, "suohun_temp", t:getMark("&sk_soul"))
					t:loseAllMarks("&sk_soul")
				end
				for _, t in sgs.qlist(room:getOtherPlayers(player)) do
				    local n = t:getMark("suohun_temp")
				    if n > 0 then room:damage(sgs.DamageStruct(self:objectName(), player, t, n)) end
					room:setPlayerMark(t, "suohun_temp", 0)
				end
			end
		end
		return false
	end
}

sgkgodsuohunClear = sgs.CreateTriggerSkill{
    name = "#sgkgodsuohun",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data, room)
		local death = data:toDeath()
		if death.who:objectName() == player:objectName() then
		    for _, t in sgs.qlist(room:getAllPlayers()) do
			    if t:getMark("&sk_soul") > 0 then t:loseAllMarks("&sk_soul") end
			end
		end
	end,
	can_trigger = function(self, target)
	    return target and target:hasSkill("sgkgodsuohun")
	end
}


extension:insertRelatedSkills("sgkgodsuohun", "#sgkgodsuohun")
sgkgodguanyu:addSkill(sgkgodwushen)
sgkgodguanyu:addSkill(sgkgodsuohun)
sgkgodguanyu:addSkill(sgkgodsuohunClear)


sgs.LoadTranslationTable{
    ["sgkgodguanyu"] = "神关羽",
	["&sgkgodguanyu"] = "神关羽",
	["#sgkgodguanyu"] = "鬼神再临",
	["~sgkgodguanyu"] = "吾一世英名，竟葬于小人之手！",
	["sk_soul"] = "魂",
	["sgkgodwushen"] = "武神",
	[":sgkgodwushen"] = "锁定技，你的【桃】和【杀】均视为【决斗】。",
	["$sgkgodwushen"] = "武神现世，天下莫敌！",
	["sgkgodsuohun"] = "索魂",
	[":sgkgodsuohun"] = "锁定技，当你受到1点伤害后，若来源不为你，其获得1个“魂”标记。当你进入濒死状态时，你减一半（向上取整）的体力上限并回复体力至体力上限"..
	"，若如此做，拥有“魂”标记的角色各弃置所有的“魂”标记，然后你对其造成其弃置的“魂”标记数的伤害。",
	["$sgkgodsuohun"] = "还不速速领死！",
	["designer:sgkgodguanyu"] = "魂烈",
    ["illustrator:sgkgodguanyu"] = "魂烈",
    ["cv:sgkgodguanyu"] = "魂烈",
}


--神司马懿
sgkgodsima = sgs.General(extension, "sgkgodsima", "sy_god", "3", true)


--[[
	技能名：极略
	相关武将：神司马
	技能描述：出牌阶段，你可以摸一张牌，然后选择一项：1、使用一张牌；2、弃置一张牌，本阶段你不能再使用“极略”。
	引用：sgkgodjilue
]]--
sgkgodjilueCard = sgs.CreateSkillCard{
	name = "sgkgodjilueCard",
	target_fixed = true,
	on_use = function(self,room,source,targets)
		room:drawCards(source, 1)
		local pattern = "|.|.|.|."
		for _,cd in sgs.qlist(source:getHandcards()) do
			if cd:isKindOf("EquipCard") and not source:isLocked(cd)  then
				if cd:isAvailable(source) then
					pattern = "EquipCard,"..pattern
					break
				end
			end
		end
		for _,cd in sgs.qlist(source:getHandcards()) do
			if cd:isKindOf("Analeptic") and not source:isLocked(cd)  then
				local card = sgs.Sanguosha:cloneCard("Analeptic", cd:getSuit(), cd:getNumber())
				if card:isAvailable(source) then
					pattern = "Analeptic,"..pattern
					break
				end
			end
		end
		for _,cd in sgs.qlist(source:getHandcards()) do
			if cd:isKindOf("Slash") and not source:isLocked(cd)  then
				local card = sgs.Sanguosha:cloneCard("Slash", cd:getSuit(), cd:getNumber())
				if card:isAvailable(source) then
				    for _,p in sgs.qlist(room:getOtherPlayers(source)) do
					    if (not sgs.Sanguosha:isProhibited(source, p, cd)) and source:canSlash(p, card, true) then
					        pattern = "Slash,"..pattern
					        break
						end
					end
				end
				break
			end
		end
		for _,cd in sgs.qlist(source:getHandcards()) do
			if cd:isKindOf("Peach") and not source:isLocked(cd)  then
				if cd:isAvailable(source) then
					pattern = "Peach,"..pattern
					break
				end
			end
		end
		for _,cd in sgs.qlist(source:getHandcards()) do
			if cd:isKindOf("TrickCard") and not source:isLocked(cd) then
				for _,p in sgs.qlist(room:getOtherPlayers(source)) do
					if not sgs.Sanguosha:isProhibited(source, p, cd) then 
						pattern = "TrickCard+^Nullification,"..pattern
						break
					end
				end
				break
			end
		end
		if pattern ~= "|.|.|.|." then
		    local card = room:askForUseCard(source, pattern, "@sgkgodjilue", -1)
			if not card then
				room:askForDiscard(source, "sgkgodjilue", 1, 1, false, true)
				room:setPlayerFlag(source, "jiluefailed")
			end
		else
			room:askForDiscard(source, "sgkgodjilue", 1, 1, false, true)
			room:setPlayerFlag(source, "jiluefailed")
		end
	end
}

sgkgodjilue = sgs.CreateViewAsSkill{
	name = "sgkgodjilue",
	n = 0,
	view_as=function(self,cards)
		return sgkgodjilueCard:clone()
	end,
	enabled_at_play = function(self,player)
		return not player:hasFlag("jiluefailed")
	end
}


--[[
	技能名：通天
	相关武将：神司马
	技能描述：限定技，出牌阶段，你可以弃置至少一张花色各不相同的牌，然后若你以此法弃置的牌包含：黑桃，获得“反馈”；红桃，获得“观星”；梅花，获得“完杀”，方块，
	获得“制衡”。
	引用：sgkgodtongtian
]]--
sgkgodtongtianCard = sgs.CreateSkillCard{
	name = "sgkgodtongtianCard",
	target_fixed = true,
	will_throw = true,
	filter = function(self, targets, to_select, player)
		return true
	end,
	on_use = function(self, room, source, targets)
		room:doSuperLightbox("sgkgodsima", "sgkgodtongtian")
		source:loseMark("@tian")
		for _, id in sgs.qlist(self:getSubcards()) do
			local c = sgs.Sanguosha:getCard(id)
			if c:getSuit() == sgs.Card_Spade then
			    if (not source:hasSkill("fankui")) and (not source:hasSkill("nosfankui")) then room:acquireSkill(source, "tongtian_fankui") end
			elseif c:getSuit() == sgs.Card_Heart then
			    if not source:hasSkill("guanxing") then room:acquireSkill(source, "tongtian_guanxing") end
			elseif c:getSuit() == sgs.Card_Club then
			    if not source:hasSkill("wansha") then room:acquireSkill(source, "tongtian_wansha") end
			elseif c:getSuit() == sgs.Card_Diamond then
			    if (not source:hasSkill("zhiheng")) and (not source:hasSkill("hujuzhiheng")) then room:acquireSkill(source, "tongtian_zhiheng") end
			end
		end
	end
}

sgkgodtongtianViewAsSkill = sgs.CreateViewAsSkill{
	name = "sgkgodtongtian",
	n = 4,
	view_filter = function(self, selected, to_select)
		if #selected >= 4 then return false end
		for _,card in ipairs(selected) do
			if card:getSuit() == to_select:getSuit() then return false end
		end
		return true
	end,
	view_as = function(self, cards)
		if #cards == 0 then return false end
		local ttCard = sgkgodtongtianCard:clone()
		for _,card in ipairs(cards) do
			ttCard:addSubcard(card)
		end
		return ttCard
	end,
	enabled_at_play=function(self, player)
		return player:getMark("@tian") >= 1
	end
}

sgkgodtongtian = sgs.CreateTriggerSkill{
	name = "sgkgodtongtian",
	frequency = sgs.Skill_Limited,
	limit_mark = "@tian",
	events = {},
	view_as_skill = sgkgodtongtianViewAsSkill,
	on_trigger = function()
	end
}


--反馈（通天）
tongtian_fankui = sgs.CreateTriggerSkill{
    name = "tongtian_fankui",
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data, room)
		local damage = data:toDamage()
		local source = damage.from
		if not source then return false end
		if source:isNude() then return false end
		if source and player:askForSkillInvoke(self:objectName(), data) then
			room:doAnimate(1, player:objectName(), source:objectName())
		    room:broadcastSkillInvoke("tongtian_fankui")
			local card_id = room:askForCardChosen(player, source, "he", "tongtian_fankui")
			room:obtainCard(player, card_id, false)
		end
	end
}


--制衡（通天）
tongtian_zhihengCard = sgs.CreateSkillCard{
	name = "tongtian_zhihengCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		room:throwCard(self, source)
		if source:isAlive() then
			local count = self:subcardsLength()
			room:drawCards(source, count)
		end
	end
}

tongtian_zhiheng = sgs.CreateViewAsSkill{
	name = "tongtian_zhiheng",
	n = 1000,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local zhiheng_card = tongtian_zhihengCard:clone()
			for _,card in pairs(cards) do
				zhiheng_card:addSubcard(card)
			end
			zhiheng_card:setSkillName(self:objectName())
			return zhiheng_card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#tongtian_zhihengCard")
	end
}


--观星（通天）
tongtian_guanxing = sgs.CreateTriggerSkill{
	name = "tongtian_guanxing",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data, room)
		if player:getPhase() == sgs.Player_Start then
			if player:askForSkillInvoke(self:objectName(), data) then
				local count = room:alivePlayerCount()
				if count > 5 then
					count = 5
				end
				room:broadcastSkillInvoke(self:objectName())
				local cards = room:getNCards(count)
				room:askForGuanxing(player,cards)
			end
		end
	end
}


--完杀（通天）
tongtian_wansha = sgs.CreateTriggerSkill{
    name = "tongtian_wansha",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.AskForPeaches, sgs.PreventPeach, sgs.AfterPreventPeach},
	priority = {7, 7, 7},
	on_trigger = function(self, event, player, data, room)
		local dying = data:toDying()
		if event == sgs.AskForPeaches then
		    if player:objectName() == room:getAllPlayers():first():objectName() then
				local sima = room:getCurrent()
				if not sima or sima:getPhase() == sgs.Player_NotActive or not sima:hasSkill(self) then return false end
				room:broadcastSkillInvoke(self:objectName())
				room:notifySkillInvoked(sima, self:objectName())
				local log = sgs.LogMessage()
				log.from = sima
				log.arg = self:objectName()
				if dying.who:objectName() ~= sima:objectName() then
					log.type = "#WanshaTwo"
					log.to:append(dying.who)
				else
					log.type = "#WanshaOne"
				end
				room:sendLog(log)
			end
		elseif event == sgs.PreventPeach then
			local current = room:getCurrent()
			if current and current:isAlive() and current:getPhase() ~= sgs.Player_NotActive and current:hasSkill("tongtian_wansha") then
				if player:objectName() ~= current:objectName() and player:objectName() ~= dying.who:objectName() then
					player:setFlags("tongtian_wansha")
					room:addPlayerMark(player, "Global_PreventPeach")
				end
			end
		elseif event == sgs.AfterPreventPeach then
			if player:hasFlag("tongtian_wansha") and player:getMark("Global_PreventPeach") > 0 then
				player:setFlags("-tongtian_wansha")
				room:removePlayerMark(player, "Global_PreventPeach")
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}


local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("tongtian_fankui") then skills:append(tongtian_fankui) end
if not sgs.Sanguosha:getSkill("tongtian_zhiheng") then skills:append(tongtian_zhiheng) end
if not sgs.Sanguosha:getSkill("tongtian_guanxing") then skills:append(tongtian_guanxing) end
if not sgs.Sanguosha:getSkill("tongtian_wansha") then skills:append(tongtian_wansha) end
sgs.Sanguosha:addSkills(skills)
sgkgodsima:addSkill(sgkgodjilue)
sgkgodsima:addSkill(sgkgodtongtian)
sgkgodsima:addRelateSkill("tongtian_fankui")
sgkgodsima:addRelateSkill("tongtian_zhiheng")
sgkgodsima:addRelateSkill("tongtian_guanxing")
sgkgodsima:addRelateSkill("tongtian_wansha")


sgs.LoadTranslationTable{
	["sgkgodsima"] = "神司马懿",
	["&sgkgodsima"] = "神司马懿",
	["~sgkgodsima"] = "生门已闭，唯有赴死……",
	["#sgkgodsima"]= "晋国之祖",
	["sgkgodjilue"] = "极略",
	["$sgkgodjilue1"] = "轻举妄为，徒招横祸。",
	["$sgkgodjilue2"] = "因果有律，世间无常。",
	["$sgkgodjilue3"] = "万物无一，强弱有变。",
	[":sgkgodjilue"] = "出牌阶段，你可以摸一张牌，然后选择一项：1、使用一张非转化的牌；2、弃置一张牌，本阶段你不能再发动“极略”。",
	["@sgkgodjilue"] = "【极略】技能效果，请使用一张（非转化的）牌，否则你弃置一张牌，且本阶段你不能再发动【极略】。",
	["sgkgodtongtian"] = "通天",
	["$sgkgodtongtian"] = "反乱不除，必生枝节。",
	["@tian"] = "通天",
	[":sgkgodtongtian"] = "限定技，出牌阶段，你可以弃置至少一张花色各不相同的牌，然后若你以此法弃置的牌包含：黑桃，获得“反馈”；红桃，获得“观星”；梅花，获"..
	"得“完杀”，方块，获得“制衡”。",
	["tongtian_fankui"] = "反馈",
	[":tongtian_fankui"] = "每当你受到伤害后，你可以获得来源的一张牌。",
	["$tongtian_fankui"] = "逆势而为，不自量力。",
	["tongtian_guanxing"] = "观星",
	[":tongtian_guanxing"] = "准备阶段，你可以观看牌堆顶的X张牌（X为存活角色数且至多为5），将其中任意数量的牌以任意顺序置于牌堆顶，其余以任意顺序置于牌堆底。",
	["$tongtian_guanxing"] = "吾之身前，万籁俱静。",
	["tongtian_zhiheng"] = "制衡",
	[":tongtian_zhiheng"] = "<font color=\"green\"><b>出牌阶段限一次。</b></font>你可以弃置至少一张牌，然后摸等量的牌。",
	["$tongtian_zhiheng"] = "吾之身后，了无生机。",
	["tongtian_wansha"] = "完杀",
	[":tongtian_wansha"] = "<font color=\"blue\"><b>锁定技。</b></font>在你的回合，除你以外，只有处于濒死状态的角色才能使用【桃】。",
	["$tongtian_wansha"] = "狂战似魔，深谋如鬼。",
	["designer:sgkgodsima"] = "魂烈",
	["illustrator:sgkgodsima"] = "魂烈",
	["cv:sgkgodsima"] = "魂烈",
}


--神曹操
sgkgodcaocao = sgs.General(extension, "sgkgodcaocao", "sy_god", 3)


--[[
	技能名：归心
	相关武将：神曹操
	技能描述：当你受到1点伤害后，你可以先获得每名其他角色区域里的一张牌，再摸X张牌（X为阵亡的角色数），然后翻面。
	引用：sgkgodguixin
]]--
sgkgodguixin = sgs.CreateMasochismSkill{
    name = "sgkgodguixin",
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		local n = player:getMark("guixin_times")
		player:setMark("guixin_times", 0)
		local data = sgs.QVariant()
		data:setValue(damage)
		local players = room:getOtherPlayers(player)
		for i = 1, damage.damage do
		    player:addMark("guixin_times")
			if player:askForSkillInvoke(self:objectName(), data) then
			    player:setFlags("guixin_using")
				room:broadcastSkillInvoke(self:objectName())
				room:doSuperLightbox("sgkgodcaocao", self:objectName())
				for _, p in sgs.qlist(players) do
				    room:doAnimate(1, player:objectName(), p:objectName())
				end
				for _, p in sgs.qlist(players) do
				    if p:isAlive() and (not p:isAllNude()) then
					    local card_id = room:askForCardChosen(player, p, "hej", self:objectName())
					    room:obtainCard(player, card_id, false)
					end
				end
				local x = 0
				for _, t in sgs.qlist(room:getPlayers()) do
				    if t:isDead() then x = x + 1 end
				end
				if x > 0 then
				    room:getThread():delay(500)
				    player:drawCards(x)
				end
				x = 0
				player:turnOver()
				player:setFlags("-guixin_using")
			else
			    break
			end
		end
		player:setMark("guixin_times", n)
	end
}


--[[
	技能名：飞影
	相关武将：神曹操
	技能描述：锁定技，若你正面朝上，你使用【杀】无距离限制；若你背面朝上，你不能成为【杀】的目标。
	引用：sgkgodgfeiying
]]--
sgkgodfeiying = sgs.CreateTargetModSkill{
    name = "sgkgodfeiying",
	pattern = "Slash",
	distance_limit_func = function(self, player, card)
	    if player:hasSkill("sgkgodfeiying") and player:faceUp() then
		    return 9999
		else
		    return 0
		end
	end
}

sgkgodfeiyingSlash = sgs.CreateProhibitSkill{
    name = "#sgkgodfeiying",
	is_prohibited = function(self, from, to, card)
	    if to:hasSkill("sgkgodfeiying") and (not to:faceUp()) then
		    return card:isKindOf("Slash")
		end
	end
}


extension:insertRelatedSkills("sgkgodfeiying", "#sgkgodfeiying")


sgkgodcaocao:addSkill(sgkgodguixin)
sgkgodcaocao:addSkill(sgkgodfeiying)
sgkgodcaocao:addSkill(sgkgodfeiyingSlash)


sgs.LoadTranslationTable{
	["sgkgodcaocao"] = "神曹操",
	["#sgkgodcaocao"] = "超世英杰",
	["&sgkgodcaocao"] = "神曹操",
	["~sgkgodcaocao"] = "就让大地，成为我的棺木吧……",
	["sgkgodguixin"] = "归心",
	["$sgkgodguixin"] = "周公吐哺，天下归心！",
	[":sgkgodguixin"] = "当你受到1点伤害后，你可以先获得每名其他角色区域里的一张牌，再摸X张牌（X为阵亡的角色数），然后翻面。",
	["sgkgodfeiying"] = "飞影",
	["sgkgodfeiyingSlash"] = "飞影",
	["#sgkgodfeiying"] = "飞影",
	[":sgkgodfeiying"] = "锁定技，若你正面朝上，你使用【杀】无距离限制；若你背面朝上，你不能成为【杀】的目标。",
	["designer:sgkgodcaocao"] = "魂烈",
	["illustrator:sgkgodcaocao"] = "魂烈",
	["cv:sgkgodcaocao"] = "魂烈",
}


--神诸葛
sgkgodzhuge = sgs.General(extension, "sgkgodzhuge", "sy_god", 3)


--[[
	技能名：七星
	相关武将：神诸葛
	技能描述：你获得11张起始手牌。分发起始手牌后，你将其中7张牌扣置于武将牌旁，称为“星”；摸牌阶段结束时，你可以用至少一张手牌替换等量的“星”。
	引用：sgkgodqixing
]]--
sgkgodqixingCard = sgs.CreateSkillCard{
	name = "sgkgodqixingCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local pile = source:getPile("xing")
		local subCards = self:getSubcards()
		local to_handcard = sgs.IntList()
		local to_pile = sgs.IntList()
		local set = source:getPile("xing")
		for _,id in sgs.qlist(subCards) do
			set:append(id)
		end
		for _,id in sgs.qlist(set) do
			if not subCards:contains(id) then
				to_handcard:append(id)
			elseif not pile:contains(id) then
				to_pile:append(id)
			end
		end
		assert(to_handcard:length() == to_pile:length())
		if to_pile:length() == 0 or to_handcard:length() ~= to_pile:length() then return end
		room:notifySkillInvoked(source, "sgkgodqixing")
		source:addToPile("xing", to_pile, false)
		local to_handcard_x = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		for _,id in sgs.qlist(to_handcard) do
			to_handcard_x:addSubcard(id)
		end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE, source:objectName())
		room:obtainCard(source, to_handcard_x, reason, false)
	end,
}

sgkgodqixingVS = sgs.CreateViewAsSkill{
	name = "sgkgodqixing", 
	n = 998,
	response_pattern = "@@sgkgodqixing",
	expand_pile = "xing",
	view_filter = function(self, selected, to_select)
		if #selected < sgs.Self:getPile("xing"):length() then
			return not to_select:isEquipped()
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == sgs.Self:getPile("xing"):length() then
			local c = sgkgodqixingCard:clone()
			for _,card in ipairs(cards) do
				c:addSubcard(card)
			end
			return c
		end
		return nil
	end,
}

sgkgodqixing = sgs.CreateTriggerSkill{
	name = "sgkgodqixing",
	events = {sgs.EventPhaseEnd},
	view_as_skill = sgkgodqixingVS,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName()) and player:getPile("xing"):length() > 0
			and player:getPhase() == sgs.Player_Draw
	end,
	on_trigger = function(self, event, player, data, room)
		player:getRoom():askForUseCard(player, "@@sgkgodqixing", "@qixing-exchange", -1, sgs.Card_MethodNone)
		return false
	end,
}

sgkgodqixingStart = sgs.CreateTriggerSkill{
	name = "#sgkgodqixingStart",
	events = {sgs.DrawInitialCards,sgs.AfterDrawInitialCards},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.DrawInitialCards then
			room:sendCompulsoryTriggerLog(player, "sgkgodqixing")
			data:setValue(data:toInt() + 7)
		elseif event == sgs.AfterDrawInitialCards then
			local exchange_card = room:askForExchange(player, "sgkgodqixing", 7, 7)
			room:broadcastSkillInvoke("sgkgodqixing")
			player:addToPile("xing", exchange_card:getSubcards(), false)
			exchange_card:deleteLater()
		end
		return false
	end,
}

sgkgodqixingAsk = sgs.CreateTriggerSkill{
	name = "#sgkgodqixingAsk",
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data, room)
		if player:getPhase() == sgs.Player_Start then
			if player:getPile("xing"):length() > 0 and player:hasSkill("sgkgodkuangfeng") then
				room:askForUseCard(player, "@@sgkgodkuangfeng", "@kuangfeng-card", -1, sgs.Card_MethodNone)
			end
		end
		if player:getPhase() == sgs.Player_Finish then
			if player:getPile("xing"):length() > 0 and player:hasSkill("sgkgoddawu") then
				room:askForUseCard(player, "@@sgkgoddawu", "@dawu-card", -1, sgs.Card_MethodNone)
			end
		end
		return false
	end,
}

sgkgodqixingClear = sgs.CreateTriggerSkill{
	name = "#sgkgodqixingClear",
	events = {sgs.EventPhaseStart, sgs.Death, sgs.EventLoseSkill},
	can_trigger = function(self, player)
		return player ~= nil
	end,
	on_trigger = function(self, event, player, data, room)
		if sgs.event == EventPhaseStart or event == sgs.Death then
			if event == sgs.Death then
				local death = data:toDeath()
				if death.who:objectName() ~= player:objectName() then
					return false
				end
			end
			if not player:getTag("sgkgodqixing_user"):toBool() then
				return false
			end
			local invoke = false
			if (event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_RoundStart) or event == sgs.Death then
				invoke = true
			end
			if not invoke then
				return false
			end
			local players = room:getAllPlayers()
			for _,p in sgs.qlist(players) do
				p:loseAllMarks("&kuangfeng")
				p:loseAllMarks("&dawu")
			end
			player:removeTag("sgkgodqixing_user")
		elseif event == sgs.EventLoseSkill and data:toString() == "sgkgodqixing" then
			player:clearOnePrivatePile("xing")
		end
		return false
	end,
}


--[[
	技能名：狂风
	相关武将：神诸葛
	技能描述：准备阶段，你可以将一张“星”置入弃牌堆并选择一名角色，若如此做，当其于你的下个回合开始之前受到：火焰伤害时，你令此伤害+1；雷电伤害时，你令其弃置
	两张牌；普通伤害时，你将牌堆顶的牌置入“星”。
	引用：sgkgodkuangfeng
]]--
sgkgodkuangfengCard = sgs.CreateSkillCard{
	name = "sgkgodkuangfengCard",
	handling_method = sgs.Card_MethodNone,
	will_throw = false,
	filter = function(self, targets, to_select, player)
		return #targets == 0
	end,
	on_effect = function(self, effect)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "sgkgodkuangfeng", "")
		effect.to:getRoom():throwCard(self, reason, nil)
		effect.from:setTag("sgkgodqixing_user", sgs.QVariant(true))
		effect.to:gainMark("&kuangfeng")
	end,
}

sgkgodkuangfengVS = sgs.CreateOneCardViewAsSkill{
	name = "sgkgodkuangfeng", 
	response_pattern = "@@sgkgodkuangfeng",
	filter_pattern = ".|.|.|xing",
	expand_pile = "xing",
	view_as = function(self, card)
		local kf = sgkgodkuangfengCard:clone()
		kf:addSubcard(card)
		return kf
	end,
}

sgkgodkuangfeng = sgs.CreateTriggerSkill{
	name = "sgkgodkuangfeng",
	events = {sgs.DamageForseen},
	view_as_skill = sgkgodkuangfengVS,
	can_trigger = function(self, player)
		return player ~= nil and player:getMark("&kuangfeng") > 0
	end,
	on_trigger = function(self, event, player, data, room)
		if not room:findPlayerBySkillName(self:objectName()) then return false end
		local shenzhuge = room:findPlayerBySkillName(self:objectName())
		local damage = data:toDamage()
		if damage.nature == sgs.DamageStruct_Fire then
		    room:broadcastSkillInvoke(self:objectName(), 2)
			room:doAnimate(1, shenzhuge:objectName(), damage.to:objectName())
			room:sendCompulsoryTriggerLog(shenzhuge, self:objectName())
			room:notifySkillInvoked(shenzhuge, self:objectName())
			damage.damage = damage.damage + 1
			data:setValue(damage)
		elseif damage.nature == sgs.DamageStruct_Thunder then
		    room:broadcastSkillInvoke(self:objectName(), 2)
			room:doAnimate(1, shenzhuge:objectName(), damage.to:objectName())
			room:sendCompulsoryTriggerLog(shenzhuge, self:objectName())
			room:notifySkillInvoked(shenzhuge, self:objectName())
			room:askForDiscard(damage.to, self:objectName(), 2, 2, false, true)
		elseif damage.nature == sgs.DamageStruct_Normal then
		    room:broadcastSkillInvoke(self:objectName(), 2)
			room:doAnimate(1, shenzhuge:objectName(), damage.to:objectName())
			room:sendCompulsoryTriggerLog(shenzhuge, self:objectName())
			room:notifySkillInvoked(shenzhuge, self:objectName())
			if room:getDrawPile():length() < 1 then room:swapPile() end
			local id = room:getNCards(1, true)
			local c = id:first()
			local card = sgs.Sanguosha:getCard(c)
			shenzhuge:addToPile("xing", card, false)
		end
		return false
	end,
}


--[[
	技能名：大雾
	相关武将：神诸葛
	技能描述：回合结束阶段开始时，你可以将至少一张“星”置入弃牌堆并选择等量的角色，若如此做，当其于你的下个回合开始之前受到非雷电伤害时，你防止此伤害。
	引用：sgkgodkuangfeng
]]--
sgkgoddawuCard = sgs.CreateSkillCard{
	name = "sgkgoddawuCard",
	handling_method = sgs.Card_MethodNone,
	will_throw = false,
	filter = function(self, targets, to_select, player)
		return #targets < self:subcardsLength()
	end,
	on_use = function(self, room, source, targets)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "sgkgoddawu", "")
		room:throwCard(self, reason, nil)
		source:setTag("sgkgodqixing_user", sgs.QVariant(true))
		for _,p in ipairs(targets) do
			p:gainMark("&dawu")
		end
	end,
}

sgkgoddawuVS = sgs.CreateViewAsSkill{
	name = "sgkgoddawu", 
	n = 999,
	response_pattern = "@@sgkgoddawu",
	expand_pile = "xing",
	view_filter = function(self, selected, to_select)
		return sgs.Self:getPile("xing"):contains(to_select:getId())
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local dw = sgkgoddawuCard:clone()
			for _,card in pairs(cards) do
				dw:addSubcard(card)
			end
			return dw
		end
		return nil
	end,
}

sgkgoddawu = sgs.CreateTriggerSkill{
	name = "sgkgoddawu",
	events = {sgs.DamageForseen},
	view_as_skill = sgkgoddawuVS,
	can_trigger = function(self, player)
		return player ~= nil and player:getMark("&dawu") > 0
	end,
	on_trigger = function(self, event, player, data, room)
		local damage = data:toDamage()
		if damage.nature ~= sgs.DamageStruct_Thunder then
			local log = sgs.LogMessage()
			log.from = damage.to
			log.type = "#FogProtect"
			log.arg = tostring(damage.damage)
			if damage.nature == sgs.DamageStruct_Fire then
			    log.arg2 = "fire_nature"
			elseif damage.nature == sgs.DamageStruct_Normal then
			    log.arg2 = "normal_nature"
			end
			room:sendLog(log)
			return true
		else
			return false
		end
	end,
}


sgkgodzhuge:addSkill(sgkgodqixing)
sgkgodzhuge:addSkill(sgkgodqixingStart)
sgkgodzhuge:addSkill(sgkgodqixingAsk)
sgkgodzhuge:addSkill(sgkgodqixingClear)
extension:insertRelatedSkills("sgkgodqixing", "#sgkgodqixingStart")
extension:insertRelatedSkills("sgkgodqixing", "#sgkgodqixingAsk")
extension:insertRelatedSkills("sgkgodqixing", "#sgkgodqixingClear")
sgkgodzhuge:addSkill(sgkgodkuangfeng)
sgkgodzhuge:addSkill(sgkgoddawu)


sgs.LoadTranslationTable{
    ["sgkgodzhuge"] = "神诸葛亮",
    ["&sgkgodzhuge"] = "神诸葛亮",
    ["~sgkgodzhuge"] = "大业未竟，奈何天命将至……",
    ["#sgkgodzhuge"] = "赤壁妖术师",
    ["sgkgodqixing"] = "七星",
    ["#sgkgodqixingStart"] = "七星",
    ["#sgkgodqixingClear"] = "七星",
    ["#sgkgodqixingAsk"] = "七星",
    ["$sgkgodqixing"] = "伏望天慈，佑我蜀汉！",
	["~sgkgodqixing"] = "选择你要作为“星”移出游戏的卡牌→点击“确定”",
    [":sgkgodqixing"] = "你获得11张起始手牌。分发起始手牌后，你将其中7张牌扣置于武将牌旁，称为“星”；摸牌阶段结束时，你可以用至少一张手牌替换等量的“星”。",
	["xing"] = "星",
	["sgkgodkuangfeng"] = "狂风",
	[":sgkgodkuangfeng"] = "准备阶段，你可以将一张“星”置入弃牌堆并选择一名角色，若如此做，当其于你的下个回合开始之前受到：①火焰伤害时，你令此伤害+1；"..
	"②雷电伤害时，你令其弃置两张牌；③普通伤害时，你将牌堆顶的牌置入“星”。",
	["~sgkgodkuangfeng"] = "选择一张“星”→选择一名角色→点击“确定”",
	["$sgkgodkuangfeng1"] = "欲破曹公，宜用火攻。",
	["$sgkgodkuangfeng2"] = "万事俱备，只欠东风。",
	["sgkgoddawu"] = "大雾",
	[":sgkgoddawu"] = "回合结束阶段开始时，你可以将至少一张“星”置入弃牌堆并选择等量的角色，若如此做，当其于你的下个回合开始之前受到非雷电伤害时，你防止此伤害。",
	["~sgkgoddawu"] = "选择至少一张“星”→选择等量的角色→点击“确定”",
	["$sgkgoddawu"] = "一幕深雾锁长江，难分渺茫。",
    ["designer:sgkgodzhuge"] = "魂烈",
    ["illustrator:sgkgodzhuge"] = "魂烈",
    ["cv:sgkgodzhuge"] = "魂烈",
}


--神周瑜
sgkgodzhouyu = sgs.General(extension, "sgkgodzhouyu", "sy_god", 4)


--[[
	技能名：琴音
	相关武将：神周瑜
	技能描述：你可以跳过弃牌阶段，然后摸/弃置两张牌，令所有角色各失去/回复1点体力。若你已发动过“业炎”，可再执行一次相同的失去/回复体力的效果。
	引用：sgkgodqinyin
]]--
sgkgodqinyin = sgs.CreateTriggerSkill{
    name = "sgkgodqinyin",
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data, room)
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_Discard then return false end
		if player:isSkipped(sgs.Player_Discard) then return false end
		if not player:askForSkillInvoke(self:objectName(), data) then return false end
		player:skip(sgs.Player_Discard)
		if player:getCards("he"):length() < 2 then
		    player:drawCards(2, self:objectName())
			room:broadcastSkillInvoke(self:objectName(), 1)
			for _, pe in sgs.qlist(room:getOtherPlayers(player)) do
				room:doAnimate(1, player:objectName(), pe:objectName())
			end
			for _, t in sgs.qlist(room:getAlivePlayers()) do
			    room:loseHp(t)
			end
			if player:getTag("sgkgodyeyan_used"):toBool() == true then
				if player:askForSkillInvoke(self:objectName(), data) then
					for _, pe in sgs.qlist(room:getOtherPlayers(player)) do
						room:doAnimate(1, player:objectName(), pe:objectName())
					end
					for _, t in sgs.qlist(room:getAlivePlayers()) do
						room:loseHp(t)
					end
				end
			end
		else
		    local choice = room:askForChoice(player, self:objectName(), "qinyin_alllose+qinyin_allrecover")
			if choice == "qinyin_alllose" then
			    player:drawCards(2, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), 1)
				for _, t in sgs.qlist(room:getAlivePlayers()) do
				    room:doAnimate(1, player:objectName(), t:objectName())
				end
				for _, t in sgs.qlist(room:getAlivePlayers()) do
				    room:loseHp(t)
				end
				if player:getTag("sgkgodyeyan_used"):toBool() == true then
					if player:askForSkillInvoke(self:objectName(), data) then
						for _, pe in sgs.qlist(room:getOtherPlayers(player)) do
							room:doAnimate(1, player:objectName(), pe:objectName())
						end
						for _, t in sgs.qlist(room:getAlivePlayers()) do
							room:loseHp(t)
						end
					end
				end
			else
			    room:askForDiscard(player, self:objectName(), 2, 2, false, true)
				room:broadcastSkillInvoke(self:objectName(), 2)
				for _, t in sgs.qlist(room:getAlivePlayers()) do
				    room:doAnimate(1, player:objectName(), t:objectName())
				end
				for _, t in sgs.qlist(room:getAlivePlayers()) do
				    local re = sgs.RecoverStruct()
			        re.who = player
		            room:recover(t, re, true)
				end
				if player:getTag("sgkgodyeyan_used"):toBool() == true then
					if player:askForSkillInvoke(self:objectName(), data) then
						for _, t in sgs.qlist(room:getAlivePlayers()) do
							room:doAnimate(1, player:objectName(), t:objectName())
						end
						for _, t in sgs.qlist(room:getAlivePlayers()) do
							local re = sgs.RecoverStruct()
							re.who = player
							room:recover(t, re, true)
						end
					end
				end
			end
		end
	end
}


--[[
	技能名：业炎
	相关武将：神周瑜
	技能描述：限定技，出牌阶段，你可以弃置至少一种花色不同的手牌，然后对一至两名其他角色各造成等量的火焰伤害，若你以此法弃置的牌花色数不少于三种，你须先失去
	3点体力。
	引用：sgkgodyeyan
]]--
sgkgodyeyanCard = sgs.CreateSkillCard{
    name = "sgkgodyeyanCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select, player)
		return to_select:objectName() ~= sgs.Self:objectName() and #targets < 2
	end,
	feasible = function(self, targets)
	    return #targets > 0 and #targets <= 2
	end,
	on_use = function(self, room, source, targets)
		local n = self:subcardsLength()
		if n >= 3 then room:loseHp(source, 3) end
		room:doSuperLightbox("sgkgodzhouyu", "sgkgodyeyan")
		for i = 1, #targets do
		    room:damage(sgs.DamageStruct("sgkgodyeyan", source, targets[i], n, sgs.DamageStruct_Fire))
		end
		source:loseMark("@sk_fire")
		source:setTag("sgkgodyeyan_used", sgs.QVariant(true))
	end
}

sgkgodyeyanVS = sgs.CreateViewAsSkill{
    name = "sgkgodyeyan",
	n = 4,
	view_filter = function(self, selected, to_select)
		if to_select:isEquipped() then return false end
		if #selected >= 4 then return false end
		for _,card in ipairs(selected) do
			if card:getSuit() == to_select:getSuit() then return false end
		end
		return true
	end,
	view_as = function(self, cards)
		if #cards == 0 then return false end
		local yeyan = sgkgodyeyanCard:clone()
		for _,card in ipairs(cards) do
			yeyan:addSubcard(card)
		end
		return yeyan
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@sk_fire") >= 1 and not player:isKongcheng()
	end
}

sgkgodyeyan = sgs.CreateTriggerSkill{
    name = "sgkgodyeyan",
	view_as_skill = sgkgodyeyanVS,
	frequency = sgs.Skill_Limited,
	limit_mark = "@sk_fire",
	events = {},
	on_trigger = function()
	end
}


sgkgodzhouyu:addSkill(sgkgodqinyin)
sgkgodzhouyu:addSkill(sgkgodyeyan)


sgs.LoadTranslationTable{
    ["sgkgodzhouyu"] = "神周瑜",
	["&sgkgodzhouyu"] = "神周瑜",
	["#sgkgodzhouyu"] = "赤壁的火神",
	["~sgkgodzhouyu"] = "残焰黯然，弦歌不复……",
	["@sk_fire"] = "业炎",
	["sgkgodqinyin"] = "琴音",
	[":sgkgodqinyin"] = "你可以跳过弃牌阶段，然后摸/弃置两张牌，令所有角色各失去/回复1点体力。若你已发动过“业炎”，可再执行一次相同的失去/回复体力的效果。",
	["$sgkgodqinyin1"] = "琴音齐疾，碎心裂胆。",
	["$sgkgodqinyin2"] = "琴音齐徐，如沐甘霖。",
	["qinyin_alllose"] = "令所有角色各失去1点体力",
	["qinyin_allrecover"] = "令所有角色各回复1点体力",
	["sgkgodyeyan"] = "业炎",
	["sgkgodyeyanCard"] = "业炎",
	[":sgkgodyeyan"] = "限定技，出牌阶段，你可以弃置至少一种花色不同的手牌，然后对一至两名其他角色各造成等量的火焰伤害，若你以此法弃置的牌花色数不少于三种，"..
	"你须先失去3点体力。",
	["$sgkgodyeyan1"] = "红莲业火，焚尽人间！",
	["$sgkgodyeyan2"] = "浮生罪业，皆归灰烬！",
	["$sgkgodyeyan3"] = "血色火海，葬敌万千！",
	["designer:sgkgodzhouyu"] = "魂烈",
    ["illustrator:sgkgodzhouyu"] = "魂烈",
    ["cv:sgkgodzhouyu"] = "魂烈",
}


--神刘备
sgkgodliubei = sgs.General(extension, "sgkgodliubei", "sy_god", "4")


--[[
	技能名：君望
	相关武将：神刘备
	技能描述：锁定技，其他角色的出牌阶段开始时，若其手牌数不小于你，其须交给你一张手牌。
	引用：sgkgodjunwang
]]--
sgkgodjunwang = sgs.CreateTriggerSkill{
    name = "sgkgodjunwang",
	frequency = sgs.Skill_Compulsory,
	priority = -2,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data, room)
		if not room:findPlayerBySkillName(self:objectName()) then return false end
		local liubei = room:findPlayerBySkillName(self:objectName())
		if player:getHandcardNum() > 0 and player:getPhase() == sgs.Player_Play and player:objectName() ~= liubei:objectName() and player:getHandcardNum() >= liubei:getHandcardNum() then
		    room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
			room:sendCompulsoryTriggerLog(liubei, self:objectName())
			room:notifySkillInvoked(liubei, self:objectName())
			room:doAnimate(1, liubei:objectName(), player:objectName())
			local c = room:askForCard(player, ".!", "@junwang:" .. liubei:objectName(), data, sgs.Card_MethodNone)
		    room:obtainCard(liubei, c, false)
		end
	end,
	can_trigger = function(self, target)
	    return true
	end
}


--[[
	技能名：激诏
	相关武将：神刘备
	技能描述：出牌阶段对每名其他角色限一次，你可以交给其至少一张手牌，并令其获得一个“诏”标记。拥有“诏”标记的角色回合结束时，若其本回合内未造成过伤害，其受到
	你造成的1点伤害并失去“诏”标记。
	引用：sgkgodjizhao
]]--
sgkgodjizhaoCard = sgs.CreateSkillCard{
    name = "sgkgodjizhaoCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select) 
		if #targets == 0 then
			if to_select:objectName() ~= sgs.Self:objectName() then
				return to_select:getMark("&zhao") == 0
			end
		end
		return false
	end,
	about_to_use = function(self, room, use)
		local source = use.from
	    local target = use.to:first()
		local msg = sgs.LogMessage()
		msg.type = "#ChoosePlayerWithSkill"
		msg.from = source
		msg.arg = "sgkgodjizhao"
		msg.to:append(target)
		room:sendLog(msg)
		room:doAnimate(1, source:objectName(), target:objectName())
		room:broadcastSkillInvoke("sgkgodjizhao", 1)
		room:notifySkillInvoked(source, "sgkgodjizhao")
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, target:objectName(), "sgkgodjizhao", "")
		room:obtainCard(target, self, reason, false)
		target:gainMark("&zhao", 1)
	end
}

sgkgodjizhao = sgs.CreateViewAsSkill{
    name = "sgkgodjizhao",
	n = 9999,
	view_filter = function(self, selected, to_select)
        return not to_select:isEquipped()
    end,
	view_as = function(self, cards)
	    if #cards >= 1 then
		    local jizhao_card = sgkgodjizhaoCard:clone()
		    for _, c in ipairs(cards) do
			    jizhao_card:addSubcard(c)
			end
		    return jizhao_card
		end
	end,
	enabled_at_play = function(self, player)
        return not player:isKongcheng()
    end
}

sgkgodjizhaoCount = sgs.CreateTriggerSkill{
    name = "#gkgodjizhao",
	events = {sgs.EventPhaseStart, sgs.Damage},
	on_trigger = function(self, event, player, data, room)
		if not room:findPlayerBySkillName(self:objectName()) then return false end
		local liubei = room:findPlayerBySkillName(self:objectName())
		if event == sgs.EventPhaseStart then
		    if player:getPhase() == sgs.Player_Start and player:objectName() ~= liubei:objectName() and player:getMark("@zhao") > 0 then
			    player:setTag("jizhao_damage", sgs.QVariant(false))
			end
		    if player:getPhase() == sgs.Player_Finish and player:objectName() ~= liubei:objectName() then 
				if player:getMark("&zhao") > 0 then
					local jizhao = player:getTag("jizhao_damage"):toBool()
					if not jizhao then
						player:loseAllMarks("&zhao")
						room:broadcastSkillInvoke("sgkgodjizhao", 2)
						room:notifySkillInvoked(liubei, "sgkgodjizhao")
						room:doAnimate(1, liubei:objectName(), player:objectName())
						local msg = sgs.LogMessage()
						msg.from = liubei
						msg.to:append(player)
						msg.arg = "sgkgodjizhao"
						msg.type = "#jizhao"
						room:sendLog(msg)
						room:damage(sgs.DamageStruct("sgkgodjizhao", liubei, player, 1))
					end
				end
				player:removeTag("jizhao_damage")
			end
		elseif event == sgs.Damage then
		    local damage = data:toDamage()
			if damage.from and damage.from:getMark("&zhao") > 0 then
			    if damage.from:getPhase() == sgs.Player_NotActive then return false end
				damage.from:setTag("jizhao_damage", sgs.QVariant(true))
			end
		end
	end,
	can_trigger = function(self, target)
	    return true
	end
}


extension:insertRelatedSkills("sgkgodjizhao", "#sgkgodjizhao")
sgkgodliubei:addSkill(sgkgodjunwang)
sgkgodliubei:addSkill(sgkgodjizhao)
sgkgodliubei:addSkill(sgkgodjizhaoCount)


sgs.LoadTranslationTable{
	["sgkgodliubei"] = "神刘备",
	["&sgkgodliubei"] = "神刘备",
	["~sgkgodliubei"] = "朕今日……注定命丧此地……",
	["#sgkgodliubei"] = "烈龙之怒",
	["sgkgodjunwang" ]= "君望",
	["$sgkgodjunwang1"] = "此诚危急存亡之时，当需一搏！",
	["$sgkgodjunwang2"] = "吾以汉室之名，借英雄一臂之力！",
	[":sgkgodjunwang"] = "锁定技，其他角色的出牌阶段开始时，若其手牌数不小于你，其须交给你一张手牌。",
	["@junwang"] = "【君望】效果触发，请交给%src一张手牌。",
	["sgkgodjizhao"] = "激诏",
	["#sgkgodjizhao"] = "激诏",
	["$sgkgodjizhao1"] = "破联盟，屠吴狗！",
	["$sgkgodjizhao2"] = "不取东吴，誓不为人！",
	[":sgkgodjizhao"] = "<font color=\"green\"><b>出牌阶段对每名其他角色限一次</b></font>，你可以交给其至少一张手牌，并令其获得一个“诏”标记。拥有“诏”标"..
	"记的角色回合结束时，若其本回合内未造成过伤害，其受到你造成的1点伤害并失去“诏”标记。",
	["zhao"] = "诏",
	["#jizhao"] = "%to 本回合内未造成过伤害，将触发 %from 的“%arg”效果。",
	["designer:sgkgodliubei"] = "魂烈",
	["illustrator:sgkgodliubei"] = "魂烈",
	["cv:sgkgodliubei"] = "魂烈",
}


--神贾诩
sgkgodjiaxu=sgs.General(extension,"sgkgodjiaxu","sy_god", 3)


--[[
	技能名：湮灭
	相关武将：神贾诩
	技能描述：出牌阶段，你可以弃置一张黑桃牌并选择一名有手牌的其他角色，你令其先弃置所有手牌并摸等量的牌再展示，然后你可以弃置其中全部非基本牌，对其造成X点伤
	害（X为以此法弃置的牌数）。
	引用：sgkgodyanmie
]]--
sgkgodyanmieCard = sgs.CreateSkillCard{
    name = "sgkgodyanmieCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
	    return (not to_select:hasSkill(self:objectName())) and (not to_select:isKongcheng())
	end,
	feasible = function(self, targets)
	    return #targets == 1 and targets[1]:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
	    local target = targets[1]
		local n = target:getHandcardNum()
		room:setPlayerMark(target, "toyanmie", n)
		local N = target:getMark("toyanmie")
		room:throwCard(target:wholeHandCards(), target, nil)
		target:drawCards(N)
		room:showAllCards(target)
		room:setPlayerMark(target, "toyanmie", 0)
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		local a = 0
	    for _, c in sgs.qlist(target:getHandcards()) do
	        if not c:isKindOf("BasicCard") then
		        a = a + 1
			    dummy:addSubcard(c)
		    end
	    end
		local choices = {"dis-yanmie", "zhaquan"}
		if a <= 0 then
			 return false
		else
	        local choice = room:askForChoice(source, "sgkgodyanmie", table.concat(choices, "+"))
	        if choice == "dis-yanmie" then
		        room:doAnimate(1, source:objectName(), target:objectName())
				room:throwCard(dummy, target, source)
		        room:damage(sgs.DamageStruct("sgkgodyanmie", source, target, a))
		    else
		        return false
	        end
	    end
	end
}

sgkgodyanmie = sgs.CreateViewAsSkill{
    name = "sgkgodyanmie",
	n = 1,
	view_filter = function(self, selected, to_select)
	    return to_select:getSuit() == sgs.Card_Spade
	end,
	view_as = function(self, cards)
	    if #cards == 1 then
		    local yanmiecard = sgkgodyanmieCard:clone()
			yanmiecard:addSubcard(cards[1])
			return yanmiecard
		end
	end
}


--[[
	技能名：顺世
	相关武将：神贾诩
	技能描述：当你成为其他角色使用的【杀】或【桃】的目标时，你可以令你与至少一名除该角色外的其他角色各摸一张牌，然后这些角色也成为此牌的目标。
	备注：太阳神三国杀目前没有【梅】这张牌，但无名杀有。
	引用：sgkgodshunshi
]]--
sgkgodshunshiCard = sgs.CreateSkillCard{
    name = "sgkgodshunshiCard",
	filter = function(self, targets, to_select)
		local n = sgs.Self:getMark("shunshi")
		return to_select:getMark("shunshi_from") == 0 and (to_select:objectName() ~= sgs.Self:objectName()) and #targets < n
	end,
	feasible = function(self, targets)
	    local n = sgs.Self:getMark("shunshi")
		return #targets > 0 and #targets <= n
	end,
	on_use = function(self, room, source, targets)
	    local room = source:getRoom()
		source:drawCards(1)
		for i = 1, #targets, 1 do
		    targets[i]:setMark("shunshi_target", 1)
			targets[i]:drawCards(1)
		end
	end
}

sgkgodshunshiVS = sgs.CreateZeroCardViewAsSkill{
    name = "sgkgodshunshi",
	response_pattern = "@@sgkgodshunshi",
	view_as = function()
		return sgkgodshunshiCard:clone()
	end
}

sgkgodshunshi = sgs.CreateTriggerSkill{
    name = "sgkgodshunshi",
	view_as_skill = sgkgodshunshiVS,
	events = {sgs.TargetConfirming},
	on_trigger = function(self, event, jiaxu, data)
	    local room = jiaxu:getRoom()
		if room:getAlivePlayers():length() <= 2 then return false end
		local use = data:toCardUse()
		if not use.from then return false end
		if use.from:objectName() == jiaxu:objectName() then return false end
		if not use.to:contains(jiaxu) then return false end
		local players = room:getOtherPlayers(jiaxu)
		local X = players:length() - 1
		if use.card:isKindOf("Slash") then
		    room:setTag("shunshi_tag", sgs.QVariant("shunshi_slash"))
		    room:setPlayerMark(use.from, "shunshi_from", 1)
		    room:setPlayerMark(jiaxu, "shunshi", X)
			room:askForUseCard(jiaxu, "@@sgkgodshunshi", "@shunshi_select")
			room:setPlayerMark(use.from, "shunshi_from", 0)
			room:setPlayerMark(jiaxu, "shunshi", 0)
			for _, p in sgs.qlist(room:getAlivePlayers()) do
			    if p:getMark("shunshi_target") > 0 then
					use.to:append(p)
					room:sortByActionOrder(use.to)
				    data:setValue(use)
					p:setMark("shunshi_target", 0)
				    room:getThread():trigger(sgs.TargetConfirming, room, p, data)
				end
			end
			room:removeTag("shunshi_tag")
		elseif use.card:isKindOf("Peach") then
		    room:setTag("shunshi_tag", sgs.QVariant("shunshi_peach"))
		    room:setPlayerMark(use.from, "shunshi_from", 1)
		    room:setPlayerMark(jiaxu, "shunshi", X)
			room:askForUseCard(jiaxu, "@@sgkgodshunshi", "@shunshi_select")
			room:setPlayerMark(use.from, "shunshi_from", 0)
			room:setPlayerMark(jiaxu, "shunshi", 0)
			for _, p in sgs.qlist(room:getAlivePlayers()) do
			    if p:getMark("shunshi_target") > 0 then
					use.to:append(p)
					room:sortByActionOrder(use.to)
				    data:setValue(use)
					p:setMark("shunshi_target", 0)
				    room:getThread():trigger(sgs.TargetConfirming, room, p, data)
				end
			end
			room:removeTag("shunshi_tag")
		end
		return false
	end
}


sgkgodjiaxu:addSkill(sgkgodyanmie)
sgkgodjiaxu:addSkill(sgkgodshunshi)


sgs.LoadTranslationTable{
	["sgkgodjiaxu"] = "神贾诩",
	["&sgkgodjiaxu"] = "神贾诩",
	["~sgkgodjiaxu"] = "我死了，诸位就能幸免吗？哈哈哈哈哈哈……",
	["#sgkgodjiaxu"] = "冷眼下瞰",
	["sgkgodyanmie"] = "湮灭",
	["luasgkgodyanmie"] = "湮灭",
	[":sgkgodyanmie"] = "出牌阶段，你可以弃置一张黑桃牌并选择一名有手牌的其他角色，你令其先弃置所有手牌并摸等量的牌再展示，然后你可以弃置其中全部非基本牌，"..
	"对其造成X点伤害（X为以此法弃置的牌数）。",
	["dis-yanmie"] = "弃置全部非基本牌并造成等量伤害",
	["zhaquan"] = "取消",
	["sgkgodshunshi"] = "顺世",
	["#sgkgodshunshi"] = "顺世",
	["@shunshi_target"] = "顺世",
	[":sgkgodshunshi"] = "当你成为其他角色使用的【杀】或【桃】的目标时，你可以令你与至少一名除该角色外的其他角色各摸一张牌，然后这些角色也成为此牌的目标。",
	["@shunshi_select"] = "你可以发动“顺世”",
	["~sgkgodshunshi"] = "选择“顺世”额外指定的目标→点击“确定”",
	["$sgkgodyanmie1"] = "能救你的人已经不在了！",
	["$sgkgodyanmie2"] = "留你一命，用余生后悔去吧！",
	["$sgkgodshunshi1"] = "死人，是不会说话的。",
	["$sgkgodshunshi2"] = "此天意，非人力所能左右。",
	["designer:sgkgodjiaxu"] = "魂烈",
	["illustrator:sgkgodjiaxu"] = "魂烈",
	["cv:sgkgodjiaxu"] = "魂烈",
}


--神孙权
sgkgodsunquan = sgs.General(extension, "sgkgodsunquan", "sy_god", "5")


--[[
	技能名：虎踞
	相关武将：神孙权
	技能描述：锁定技，任一角色的准备阶段，你摸4张牌，若此时是你的回合，你减1点体力上限，失去“虎踞”，获得“制衡”、“雄略”和“虎缚”。
	引用：sgkgodhuju
]]--
sgkgodhuju = sgs.CreateTriggerSkill{
    name = "sgkgodhuju",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data, room)
		if not room:findPlayerBySkillName(self:objectName()) then return false end
		local sunquan = room:findPlayerBySkillName(self:objectName())
		if player:getPhase() == sgs.Player_Start then
		    room:broadcastSkillInvoke(self:objectName(), math.random(1, 3))
			room:sendCompulsoryTriggerLog(sunquan, self:objectName())
			room:notifySkillInvoked(sunquan, self:objectName())
			sunquan:drawCards(4, self:objectName())
			if player:getSeat() == sunquan:getSeat() then
				room:doSuperLightbox("sgkgodsunquan", self:objectName())
				room:loseMaxHp(sunquan)
				if not sunquan:hasSkill("zhiheng") and not sunquan:hasSkill("tongtian_zhiheng") then
				    room:acquireSkill(sunquan, "hujuzhiheng")
				end
				if not sunquan:hasSkill("sgkgodhufu") then room:acquireSkill(sunquan, "sgkgodhufu") end
				if not sunquan:hasSkill("sr_xionglve") then room:acquireSkill(sunquan, "sr_xionglve") end
				room:detachSkillFromPlayer(sunquan, "sgkgodhuju")
			end
		end
	end,
	can_trigger = function(self, target)
	    return true
	end
}


--制衡（虎踞）
hujuzhihengCard = sgs.CreateSkillCard{
	name = "hujuzhihengCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		room:throwCard(self, source)
		if source:isAlive() then
			local count = self:subcardsLength()
			room:drawCards(source, count)
		end
	end
}

hujuzhiheng = sgs.CreateViewAsSkill{
	name = "hujuzhiheng",
	n = 999,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local zhiheng_card = hujuzhihengCard:clone()
			for _,card in pairs(cards) do
				zhiheng_card:addSubcard(card)
			end
			zhiheng_card:setSkillName(self:objectName())
			return zhiheng_card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#hujuzhihengCard")
	end
}


--[[
	技能名：虎缚
	相关武将：神孙权
	技能描述：出牌阶段限一次，你可以令一名其他角色弃置X张牌（X为其装备区的牌数）。
	引用：sgkgodhufu
]]--
sgkgodhufuCard = sgs.CreateSkillCard{
    name = "sgkgodhufuCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
        return (#targets == 0) and (to_select:objectName() ~= sgs.Self:objectName()) and (to_select:getEquips():length() > 0)
    end,
	on_use = function(self, room, source, targets)
	    local target = targets[1]
		local room = source:getRoom()
		local X = target:getEquips():length()
		room:askForDiscard(target, "sgkgodhufu", X, X, false, true)
	end
}

sgkgodhufu = sgs.CreateZeroCardViewAsSkill{
    name = "sgkgodhufu",
	view_as = function()
	    return sgkgodhufuCard:clone()
	end,
	enabled_at_play = function(self, player)
	    return not player:hasUsed("#sgkgodhufuCard")
	end
}
	
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("sgkgodhufu") then skills:append(sgkgodhufu) end
if not sgs.Sanguosha:getSkill("hujuzhiheng") then skills:append(hujuzhiheng) end
sgs.Sanguosha:addSkills(skills)
sgkgodsunquan:addSkill(sgkgodhuju)
sgkgodsunquan:addRelateSkill("sgkgodhufu")
sgkgodsunquan:addRelateSkill("hujuzhiheng")
sgkgodsunquan:addRelateSkill("sr_xionglve")


sgs.LoadTranslationTable{
	["sgkgodsunquan"] = "神孙权",
	["&sgkgodsunquan"] = "神孙权",
	["#sgkgodsunquan"] = "峰林之上",
	["~sgkgodsunquan"] = "效季良不得，陷为天下……轻薄子……",
	["sgkgodhuju"] = "虎踞",
	["$sgkgodhuju1"] = "踞虎盘龙，步步为营！",
	["$sgkgodhuju2"] = "虎踞江东，利在鼎足！",
	["$sgkgodhuju3"] = "虎跃天堑，剑指中原！",
	["Tolose"] = "失去1点体力",
	["Hujuwake"] = "减1点体力上限",
	[":sgkgodhuju"] = "锁定技，任一角色的准备阶段，你摸4张牌，若此时是你的回合，你减1点体力上限，失去“虎踞”，获得“制衡”、“雄略”和“虎缚”。",
	["hujuzhiheng"] = "制衡",
	[":hujuzhiheng"] = "出牌阶段限一次，你可以弃置至少一张牌，然后摸等量的牌。",
	["$hujuzhiheng1"] = "大人虎变，其文炳也。",
	["$hujuzhiheng2"] = "虎视眈眈，其欲逐逐。",
	["sgkgodhufu"] = "虎缚",
	["$sgkgodhufu1"] = "虎兕出柙，恩怨必报！",
	["$sgkgodhufu2"] = "委肉虎蹊，祸必不振！",
	[":sgkgodhufu"] = "出牌阶段限一次，你可以令一名其他角色弃置X张牌（X为其装备区的牌数）。",
	["designer:sgkgodsunquan"] = "魂烈",
	["illustrator:sgkgodsunquan"] = "魂烈",
	["cv:sgkgodsunquan"] = "魂烈",
}


--神貂蝉
sgkgoddiaochan = sgs.General(extension, "sgkgoddiaochan", "sy_god", 3, false)


--[[
	技能名：天姿
	相关武将：神貂蝉
	技能描述：摸牌阶段，你可以放弃摸牌，然后令所有其他角色各选择一项：1. 交给你一张牌；2. 令你摸一张牌。
	引用：sgkgodtianzi
]]--
sgkgodtianzi = sgs.CreateTriggerSkill{
    name = "sgkgodtianzi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data, room)
		if player:getPhase() ~= sgs.Player_Draw then return false end
		if player:askForSkillInvoke(self:objectName(), data) then
		    room:broadcastSkillInvoke(self:objectName())
			room:notifySkillInvoked(player, self:objectName())
		    local choices = {"GiveToHer", "LetHerDraw"}
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				room:doAnimate(1, player:objectName(), p:objectName())
			    if p:isNude() then
				    player:drawCards(1)
				else
				    local choice = room:askForChoice(p, self:objectName(), table.concat(choices, "+"))
				    if choice == "LetHerDraw" then
				        player:drawCards(1)
				    else
				        local c = room:askForCardChosen(p, p, "he", self:objectName())
					    if c then room:obtainCard(player, c, false) end
			 	    end
			    end
			end
			return true
		end
	end
}


--[[
	技能名：魅心
	相关武将：神貂蝉
	技能描述：出牌阶段限一次，你可以选择一名其他男性角色，若如此做，当你于此阶段内使用：基本牌后，你弃置其一张牌；锦囊牌后，你获得其一张牌；装备牌后，你对其
	造成1点伤害。
	引用：sgkgodmeixin
]]--
sgkgodmeixinCard = sgs.CreateSkillCard{
    name = "sgkgodmeixinCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
	    if #targets == 0 then
		    return to_select:objectName() ~= sgs.Self:objectName() and to_select:isMale() and to_select:isAlive()
		end
		return false
	end,
	on_use = function(self, room, source, targets)
	    local target = targets[1]
		local room = source:getRoom()
		target:setFlags("meixin_target")
	end
}

sgkgodmeixinVS = sgs.CreateZeroCardViewAsSkill{
    name = "sgkgodmeixin",
	view_as = function()
	    return sgkgodmeixinCard:clone()
	end,
	enabled_at_play = function(self, player)
	    return not player:hasUsed("#sgkgodmeixinCard")
	end
}

sgkgodmeixin = sgs.CreateTriggerSkill{
    name = "sgkgodmeixin",
	view_as_skill = sgkgodmeixinVS,
	events = {sgs.EventPhaseStart, sgs.CardFinished},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.CardFinished then
		    local current = room:getCurrent()
			if not current then return false end
			if current:getPhase() ~= sgs.Player_Play then return false end
			local use = data:toCardUse()
			local card = use.card
			if use.from:objectName() == current:objectName() then
			    if card:isKindOf("BasicCard") then
				    for _, t in sgs.qlist(room:getOtherPlayers(current)) do
					    if t:hasFlag("meixin_target") and (not t:isNude()) then
							room:doAnimate(1, player:objectName(), t:objectName())
					        room:notifySkillInvoked(current, self:objectName())
						    room:broadcastSkillInvoke(self:objectName(), math.random(1,4))
					        local card_id = room:askForCardChosen(current, t, "he", self:objectName())
						    local c = sgs.Sanguosha:getCard(card_id)
						    room:throwCard(c, t, current)
						end
					end
				elseif card:isKindOf("TrickCard") then
				    for _, t in sgs.qlist(room:getOtherPlayers(current)) do
					    if t:hasFlag("meixin_target") and (not t:isNude()) then
							room:doAnimate(1, player:objectName(), t:objectName())
					        room:notifySkillInvoked(current, self:objectName())
						    room:broadcastSkillInvoke(self:objectName(), math.random(1,4))
					        local id = room:askForCardChosen(current, t, "he", self:objectName())
						    room:obtainCard(current, id, false)
						end
					end
				elseif card:isKindOf("EquipCard") then
				    for _, t in sgs.qlist(room:getOtherPlayers(player)) do
					    if t:hasFlag("meixin_target") and t:isAlive() then
							room:doAnimate(1, player:objectName(), t:objectName())
					        room:notifySkillInvoked(current, self:objectName())
						    room:broadcastSkillInvoke(self:objectName(), math.random(1,4))
						    room:damage(sgs.DamageStruct(self:objectName(), current, t))
						end
					end
				end
			end
		elseif event == sgs.EventPhaseStart then
		    local current = room:getCurrent()
		    if current:getPhase() == sgs.Player_Finish then
			    for _, p in sgs.qlist(room:getOtherPlayers(current)) do
				    if p:hasFlag("meixin_target") then p:setFlags("-meixin_target") end
				end
			end
		end
	end
}


sgkgoddiaochan:addSkill(sgkgodtianzi)
sgkgoddiaochan:addSkill(sgkgodmeixin)


sgs.LoadTranslationTable{
	["sgkgoddiaochan"] = "神貂蝉",
	["&sgkgoddiaochan"] = "神貂蝉",
	["#sgkgoddiaochan"] = "乱世的舞魅",
	["~sgkgoddiaochan"] = "自古美人如名将，不许人间见白头……",
	["sgkgodtianzi"] = "天姿",
	[":sgkgodtianzi"] = "摸牌阶段，你可以放弃摸牌，然后令所有其他角色各选择一项：1. 交给你一张牌；2. 令你摸一张牌。",
	["LetHerDraw"] = "该角色摸1张牌",
	["GiveToHer"] = "交给该角色1张牌",
	["tianzigive"] = "【天姿】效果，请交给@src一张牌。",
	["$sgkgodtianzi"] = "香囊暗解，罗带轻分，薄幸谁常往？",
	["sgkgodmeixin"] = "魅心",
	[":sgkgodmeixin"] = "出牌阶段限一次，你可以选择一名其他男性角色，若如此做，当你于此阶段内使用：基本牌后，你弃置其一张牌；锦囊牌后，你获得其一张牌；装备牌后，你对其造成1点伤害。",
	["$sgkgodmeixin1"] = "妾心妾意，惟愿常相伴。",
	["$sgkgodmeixin2"] = "夫为乐，为乐当及时。",
	["$sgkgodmeixin3"] = "滔滔日夜东注，多少醉生梦死。",
	["$sgkgodmeixin4"] = "银壶金樽复美酒，与君同销万古愁。",
	["designer:sgkgoddiaochan"]= "魂烈",
	["illustrator:sgkgoddiaochan"] = "魂烈",
	["cv:sgkgoddiaochan"] = "魂烈",
}


--神张飞
sgkgodzhangfei = sgs.General(extension, "sgkgodzhangfei", "sy_god", 4)


--[[
	技能名：杀意
	相关武将：神张飞
	技能描述：锁定技，出牌阶段开始时，你展示所有手牌，若有【杀】，你摸一张牌，否则你于此阶段内可将黑色牌当【杀】使用。你使用【杀】无距离和次数限制。
	引用：sgkgodshayi
]]--
sgkgodshayi = sgs.CreateOneCardViewAsSkill{
    name = "sgkgodshayi",
	view_filter = function(self, to_select)
	    local value = sgs.Self:getMark("shayi")
		if value == 1 then
		    return to_select:isBlack()
		end
		return false
	end,
	view_as = function(self, card)
	    local slash = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
		slash:addSubcard(card)
		slash:setSkillName(self:objectName())
		return slash
	end,
	enabled_at_play = function(self, player)
	    return player:getMark("shayi") > 0 and not player:isNude()
	end
}


sgkgodshayiDo = sgs.CreateTriggerSkill{
    name = "#sgkgodshayiDo",
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd, sgs.CardUsed},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseStart then
		    if player:getPhase() == sgs.Player_Play then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:notifySkillInvoked(player, self:objectName())
			    local slash_count = 0
				for _, id in sgs.qlist(player:getHandcards()) do
				    if id:isKindOf("Slash") then slash_count = slash_count + 1 end
				end
				room:broadcastSkillInvoke("sgkgodshayi", 1)
				room:showAllCards(player)
				if slash_count > 0 then
				    player:drawCards(1)
				else
				    room:setPlayerMark(player, "shayi", 1)
				end
			end
		elseif event == sgs.EventPhaseEnd then
		    if player:getPhase() == sgs.Player_Play then
			    room:setPlayerMark(player, "shayi", 0)
			end
		elseif event == sgs.CardUsed then
		    local use = data:toCardUse()
			local zhangfei = room:getCurrent()
			if not zhangfei then return false end
			if not zhangfei:hasSkill("sgkgodshayi") then return false end
			if use.card and use.card:subcardsLength() > 0 and use.card:getSkillName() ~= "sgkgodshayi" and use.from and use.from:objectName() == zhangfei:objectName() then
			    if use.card:isKindOf("Slash") then
				    if use.m_addHistory then
					    room:broadcastSkillInvoke("sgkgodshayi", math.random(2, 4))
						room:notifySkillInvoked(zhangfei, "sgkgodshayi")
					    room:addPlayerHistory(zhangfei, use.card:getClassName(), -2)
					end
				end
			end
		end
		return false
	end
}


function forbidAllSkills(vic)
	local room = vic:getRoom()
	for _, sk in sgs.qlist(vic:getVisibleSkillList()) do
		room:addPlayerMark(vic, "Qingcheng"..sk:objectName())
	end
end

function activateAllSkills(vic)
	local room = vic:getRoom()
	for _, sk in sgs.qlist(vic:getVisibleSkillList()) do
		room:setPlayerMark(vic, "Qingcheng"..sk:objectName(), 0)
	end
end


--[[
	技能名：震魂
	相关武将：神张飞
	技能描述：出牌阶段限一次，你可以弃置一张牌，然后令所有其他角色的非锁定技于此阶段内无效。
	引用：sgkgodzhenhun
]]--
sgkgodzhenhunCard = sgs.CreateSkillCard{
    name = "sgkgodzhenhunCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
	    for _, p in sgs.qlist(room:getOtherPlayers(source)) do
		    room:doAnimate(1, source:objectName(), p:objectName())
		end
		for _, p in sgs.qlist(room:getOtherPlayers(source)) do
		    forbidNonCompulsorySkills(p, "sgkgodzhenhun")
		end
		room:addPlayerMark(source, "zhenhun_done")
	end
}

sgkgodzhenhunVS = sgs.CreateViewAsSkill{
    name = "sgkgodzhenhun",
	n = 1,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = sgkgodzhenhunCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return (not player:isNude()) and (not player:hasUsed("#sgkgodzhenhunCard")) and player:getMark("zhenhun_done") <= 0
	end
}

sgkgodzhenhun = sgs.CreateTriggerSkill{
    name = "sgkgodzhenhun",
	view_as_skill = sgkgodzhenhunVS,
	events = {sgs.EventPhaseEnd, sgs.Death, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseEnd then
		    if player:getPhase() == sgs.Player_Play and player:getMark("zhenhun_done") > 0 then
		        for _, t in sgs.qlist(room:getOtherPlayers(player)) do
			        activateAllSkills(t, "sgkgodzhenhun")
			    end
			    room:setPlayerMark(player, "zhenhun_done", 0)
			end
		elseif event == sgs.EventPhaseChanging then
		    local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
			    for _, t in sgs.qlist(room:getOtherPlayers(player)) do
			        activateAllSkills(t, "sgkgodzhenhun")
			    end
			    room:setPlayerMark(player, "zhenhun_done", 0)
			end
		elseif event == sgs.Death then
		    local death = data:toDeath()
			if death.who:hasSkill(self:objectName()) then
			    for _, t in sgs.qlist(room:getOtherPlayers(death.who)) do
			        activateAllSkills(t, "sgkgodzhenhun")
			    end
				room:setPlayerMark(death.who, "zhenhun_done", 0)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
	    return target and target:hasSkill(self:objectName())
	end
}


extension:insertRelatedSkills("sgkgodshayi", "#sgkgodshayiDo")
sgkgodzhangfei:addSkill(sgkgodshayi)
sgkgodzhangfei:addSkill(sgkgodshayiDo)
sgkgodzhangfei:addSkill(sgkgodzhenhun)


sgs.LoadTranslationTable{
["sgkgodzhangfei"] = "神张飞",
["&sgkgodzhangfei"] = "神张飞",
["~sgkgodzhangfei"] = "汝等杂碎！还吾头来……",
["#sgkgodzhangfei"] = "横扫千军",
["sgkgodshayi"] = "杀意",
["sgkgodshayiDo"] = "杀意",
["#sgkgodshayiDo"] = "杀意",
["$sgkgodshayi1"] = "长矛所向，万夫不当！",
["$sgkgodshayi2"] = "呆若木鸡，是等死吗？",
["$sgkgodshayi3"] = "喝啊啊啊啊——",
["$sgkgodshayi4"] = "看爷爷我大杀四方！",
[":sgkgodshayi"] = "锁定技，出牌阶段开始时，你展示所有手牌，若有【杀】，你摸一张牌，否则你于此阶段内可将黑色牌当【杀】使用。你使用【杀】无距离和次数限制。",
["sgkgodzhenhun"] = "震魂",
["$sgkgodzhenhun"] = "都跪下，叫老子一声爹！",
[":sgkgodzhenhun"] = "出牌阶段限一次，你可以弃置一张牌，然后令所有其他角色的非锁定技于此阶段内无效。",
["designer:sgkgodzhangfei"] = "魂烈",
["illustrator:sgkgodzhangfei"] = "魂烈",
["cv:sgkgodzhangfei"] = "魂烈",
}


--神司马徽
sgkgodsimahui = sgs.General(extension, "sgkgodsimahui", "sy_god", 3)


--[[
	技能名：隐世
	相关武将：神司马徽
	技能描述：锁定技，当你受到伤害时，你摸X张牌（X为伤害值），然后若此伤害不为雷电伤害，你防止之。
	备注：初代的神司马徽免疫一切伤害，只有体力流失、扣体力上限、吃菜、神关羽/十周年神张飞的强制死亡才能打动他。
	引用：sgkgodyinshi
]]--
sgkgodyinshi = sgs.CreateTriggerSkill{
    name = "sgkgodyinshi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data, room)
		local damage = data:toDamage()
		if damage.to:objectName() == player:objectName() then
		    room:sendCompulsoryTriggerLog(player, self:objectName())
			room:notifySkillInvoked(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			player:drawCards(damage.damage)
			if damage.nature ~= sgs.DamageStruct_Thunder then return true end
		end
	end
}


--[[
	技能名：知天
	相关武将：神司马徽
	技能描述：锁定技，准备阶段，你随机展示三张未上场且你拥有的武将牌并选择其中一个技能，然后选择一名角色，若如此做，你将所有手牌交给该角色，令其获得此技能并
	失去1点体力。
	备注：初代的神司马徽抽到什么技能全随机，没得选，纯粹开盲盒，而且给别人牌和技能也是自己流失体力。现在你可以空城状态下给别人一个恃勇然后让他流失1点体力。
	备注：我玩初代的神司马徽曾经出现过我送给别人一个通天，下回合给我自己来了个极略版的武神（锁定技，你的桃和杀均视为决斗）。
	引用：sgkgodzhitian
]]--
local json = require ("json")
function isNormalGameMode (mode_name)
	return mode_name:endsWith("p") or mode_name:endsWith("pd") or mode_name:endsWith("pz")
end
function acquireGenerals(zuoci, n)
	local room = zuoci:getRoom()
	local Huashens = {}
	for i=1, n, 1 do
		local generals = sgs.Sanguosha:getLimitedGeneralNames()
		local banned = {"zuoci", "guzhielai", "dengshizai", "jiangboyue", "bgm_xiahoudun"}
		local alives = room:getAlivePlayers()
		for _,p in sgs.qlist(alives) do
			if not table.contains(banned, p:getGeneralName()) then
				table.insert(banned, p:getGeneralName())
			end
			if p:getGeneral2() and not table.contains(banned, p:getGeneral2Name()) then
				table.insert(banned, p:getGeneral2Name())
			end
		end
		if (isNormalGameMode(room:getMode()) or room:getMode():find("_mini_")or room:getMode() == "custom_scenario") then
			table.removeTable(generals, sgs.GetConfig("Banlist/Roles", ""):split(","))
		elseif (room:getMode() == "04_1v3") then
			table.removeTable(generals, sgs.GetConfig("Banlist/HulaoPass", ""):split(","))
		elseif (room:getMode() == "06_XMode") then
			table.removeTable(generals, sgs.GetConfig("Banlist/XMode", ""):split(","))
			for _,p in sgs.qlist(room:getAlivePlayers())do
				table.removeTable(generals, (p:getTag("XModeBackup"):toStringList()) or {})
			end
		elseif (room:getMode() == "02_1v1") then
			table.removeTable(generals, sgs.GetConfig("Banlist/1v1", ""):split(","))
			for _,p in sgs.qlist(room:getAlivePlayers())do
				table.removeTable(generals, (p:getTag("1v1Arrange"):toStringList()) or {})
			end
		end
		for i=1, #generals, 1 do
			if table.contains(banned, generals[i]) then
				table.remove(generals, i)
			end
		end
		for i=1, #generals, 1 do
			local ageneral = sgs.Sanguosha:getGeneral(generals[i])
			if ageneral ~= nil then 
				local N = ageneral:getVisibleSkillList():length()
				local x = 0
				for _, pe in sgs.qlist(room:getAlivePlayers()) do
					for _, sk in sgs.qlist(ageneral:getVisibleSkillList()) do
						if pe:hasSkill(sk:objectName()) then x = x + 1 end
					end
				end
				if x == N then table.remove(generals, i) end
			end
		end
		if #generals > 0 then
			table.insert(Huashens, generals[math.random(1, #generals)])
		end
	end
	zuoci:setTag("absense_generals_record", sgs.QVariant(table.concat(Huashens, "+")))
end

function getZhitianSkill(zuoci)
	local room = zuoci:getRoom()
	Hs_String = zuoci:getTag("absense_generals_record"):toString()
	local zhitian_skills = {}
	if Hs_String and Hs_String ~= "" then
		local Huashens = Hs_String:split("+")		
		for _, general_name in ipairs(Huashens) do
			local msg = sgs.LogMessage()
			msg.type = "#ShowAbsenseGenerals"
			msg.from = zuoci
			msg.arg = general_name
			room:sendLog(msg)		
			local general = sgs.Sanguosha:getGeneral(general_name)		
			for _, sk in sgs.qlist(general:getVisibleSkillList()) do
				table.insert(zhitian_skills, sk:objectName())
			end
		end
	end
	if #zhitian_skills > 0 then
		for _, pe in sgs.qlist(room:getAlivePlayers()) do
			for _, gsk in sgs.qlist(pe:getVisibleSkillList()) do
				if table.contains(zhitian_skills, gsk:objectName()) then table.removeOne(zhitian_skills, gsk:objectName()) end
			end
		end
	end
	if #zhitian_skills > 0 then
		return zhitian_skills
	else
		return {}
	end
end

sgkgodzhitian = sgs.CreateTriggerSkill{
    name = "sgkgodzhitian",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data, room)
		if player:getPhase() == sgs.Player_Start then
		    acquireGenerals(player, 3)
			local skill_list = getZhitianSkill(player)
			local skill = room:askForChoice(player, self:objectName(), table.concat(skill_list, "+"), data)
			local target = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "@zhitian-target:"..skill)
			if target then
				room:doAnimate(1, player:objectName(), target:objectName())
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:notifySkillInvoked(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				if not player:isKongcheng() then room:obtainCard(target, player:wholeHandCards(), false) end
				room:acquireSkill(target, skill)
				room:loseHp(target)
			end
		end
	end
}


sgkgodsimahui:addSkill(sgkgodyinshi)
sgkgodsimahui:addSkill(sgkgodzhitian)


sgs.LoadTranslationTable{
	["sgkgodsimahui"] = "神司马徽",
	["#sgkgodsimahui"] = "水镜先生",
	["&sgkgodsimahui"] = "神司马徽",
	["~sgkgodsimahui"] = "万物顺应成天，老夫自当归去……",
	["sgkgodyinshi"] = "隐世",
	["$sgkgodyinshi"] = "逃遁避世，虽逢无道，心无所闷。",
	[":sgkgodyinshi"] = "锁定技，当你受到伤害时，你摸X张牌（X为伤害值），然后若此伤害不为雷电伤害，你防止之。",
	["sgkgodzhitian"] = "知天",
	["$sgkgodzhitian"] = "见龙在田，利见大人。",
	[":sgkgodzhitian"] = "锁定技，准备阶段，你随机展示三张未上场且你拥有的武将牌并选择其中一个技能，然后选择一名角色，若如此做，你将所有手牌交给该角色，令其"..
	"获得此技能并失去1点体力。",
	["#ShowAbsenseGenerals"] = "%from展示了一张武将牌“%arg”",
	["@zhitian-target"] = "“知天”效果触发，你须将所有手牌交给一名角色并令其获得“%src”<br/> <b>操作提示</b>: 选择一名角色→点击确定<br/>",
	["designer:sgkgodsimahui"] =" 魂烈",
	["illustrator:sgkgodsimahui"] = "魂烈",
	["cv:sgkgodsimahui"] = "魂烈",
}


--神甘宁
sgkgodganning = sgs.General(extension, "sgkgodganning", "sy_god", 4)


--[[
	技能名：掠阵
	相关武将：神甘宁
	技能描述：当你使用【杀】指定目标后，你可以将牌堆顶的3张牌置入弃牌堆，其中每有1张非基本牌，你弃置目标角色1张牌。
	备注：这个是初代神甘宁，后面经历过两次改版，而且SP神甘宁都出了，但这个版本的我真不想改。
	引用：sgkgodluezhen
]]--
sgkgodluezhen = sgs.CreateTriggerSkill{
    name = "sgkgodluezhen",
	events = {sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data, room)
		local use = data:toCardUse()
		if not use.from then return false end
		if player:objectName() ~= use.from:objectName() or (not use.card:isKindOf("Slash")) then return false end
		if use.to:contains(player) then return false end
		if room:getDrawPile():length()< 3 then room:swapPile() end
		local cards = room:getDrawPile()
		for _, t in sgs.qlist(use.to) do
		    if t:isNude() then return false end
		    if not player:askForSkillInvoke(self:objectName(), data) then return false end
			room:broadcastSkillInvoke(self:objectName())
		    local a = 0
			local b = 0
			local luezhen = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			while b < 3 do
			    local cardsid = cards:at(0)
				local move = sgs.CardsMoveStruct()
				move.card_ids:append(cardsid)
				move.to = player
			    move.to_place = sgs.Player_PlaceTable
			    move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), self:objectName(), nil)
			    room:moveCardsAtomic(move, true)
				local c = sgs.Sanguosha:getCard(cardsid)
				if not c:isKindOf("BasicCard") then a = a + 1 end
				luezhen:addSubcard(cardsid)
				b = b + 1
				if cards:length() == 0 then room:swapPile() end
			end
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), nil)
			room:throwCard(luezhen, reason, nil)
			luezhen:deleteLater()
			if a > 0 then
			    room:setPlayerFlag(t, "sgkgodluezhen_InTempMoving")
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
				local card_ids = sgs.IntList()
			    local original_places = sgs.IntList()
			    for i = 0, a - 1, 1 do
				    if not player:canDiscard(t, "he") then break end
				    local c = room:askForCardChosen(player, t, "he", self:objectName())
					card_ids:append(c)
				    original_places:append(room:getCardPlace(card_ids:at(i)))
			        dummy:addSubcard(card_ids:at(i))
			        t:addToPile("#luezhen", card_ids:at(i), false)
				end
				for i = 0, dummy:subcardsLength() - 1, 1 do
				    room:moveCardTo(sgs.Sanguosha:getCard(card_ids:at(i)), t, original_places:at(i), false)
				end
				room:setPlayerFlag(t, "-sgkgodluezhen_InTempMoving")
				if dummy:subcardsLength() > 0 then
				    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW, player:objectName(), self:objectName(), "")
					room:throwCard(dummy, reason, nil)
				end
				dummy:deleteLater()
			end
		end
	end
}

sgkgodluezhenFakeMove = sgs.CreateTriggerSkill{
    name = "#sgkgodluezhen",
	events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime},
	priority = 20,
	on_trigger = function(self, event, player, data, room)
		for _, p in sgs.qlist(room:getAllPlayers()) do
		    if p:hasFlag("sgkgodluezhen_InTempMoving") then return true end
		end
		return false
	end
}


extension:insertRelatedSkills("sgkgodluezhen", "#sgkgodluezhen")


--[[
	技能名：游龙
	相关武将：神甘宁
	技能描述：出牌阶段，若弃牌堆的牌数多于摸牌堆，你可以将黑色手牌当【顺手牵羊】使用。
	引用：sgkgodyoulong
]]--
sgkgodyoulong = sgs.CreateOneCardViewAsSkill{
    name = "sgkgodyoulong",
	view_filter = function(self, to_select)
	    local value = sgs.Self:getMark("youlong")
		if value == 1 then
		    return to_select:isBlack() and (not to_select:isEquipped())
		end
		return false
	end,
	view_as = function(self, card)
	    local youlong_snatch = sgs.Sanguosha:cloneCard("snatch", card:getSuit(), card:getNumber())
		youlong_snatch:addSubcard(card)
		youlong_snatch:setSkillName(self:objectName())
		return youlong_snatch
	end,
	enabled_at_play = function(self, player)
	    return player:getMark("youlong") > 0 and not player:isKongcheng()
	end
}

sgkgodyoulongMoveCheck = sgs.CreateTriggerSkill{
    name = "#sgkgodyoulong-MoveCheck",
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data, room)
		local move = data:toMoveOneTime()
		if not room:findPlayerBySkillName("sgkgodyoulong") then return false end
		local ganning = room:findPlayerBySkillName("sgkgodyoulong")
		if move.to_place == sgs.Player_DiscardPile then
		    local a = room:getDiscardPile():length()
			local b = room:getDrawPile():length()
			if a > b then
			    room:setPlayerMark(ganning, "youlong", 1)
			else
			    room:setPlayerMark(ganning, "youlong", 0)
			end
		end
	end,
	can_trigger = function(self, target)
	    return true
	end
}


extension:insertRelatedSkills("sgkgodyoulong", "#sgkgodyoulong-MoveCheck")


sgkgodganning:addSkill(sgkgodluezhen)
sgkgodganning:addSkill(sgkgodluezhenFakeMove)
sgkgodganning:addSkill(sgkgodyoulong)
sgkgodganning:addSkill(sgkgodyoulongMoveCheck)


sgs.LoadTranslationTable{
["sgkgodganning"] = "神甘宁",
["#sgkgodganning"] = "疾驱斩浪",
["&sgkgodganning"] = "神甘宁",
["~sgkgodganning"] = "哼！江东好汉，誓死不降！",
["sgkgodluezhen"] = "掠阵",
["#sgkgodluezhenFakeMove"] = "掠阵",
["$sgkgodluezhen1"] = "天不怕，临阵杀人！",
["$sgkgodluezhen2"] = "地不慌，攻池破城！",
[":sgkgodluezhen"] = "当你使用【杀】指定目标后，你可以将牌堆顶的3张牌置入弃牌堆，其中每有1张非基本牌，你弃置目标角色1张牌。",
["sgkgodyoulong"] = "游龙",
["#sgkgodyoulong-MoveCheck"] = "游龙",
["$sgkgodyoulong1"] = "青甲刀，拿人头！",
["$sgkgodyoulong2"] = "游龙手，夺绣花！",
[":sgkgodyoulong"] = "出牌阶段，若弃牌堆的牌数多于摸牌堆，你可以将黑色手牌当【顺手牵羊】使用。",
["designer:sgkgodganning"] = "魂烈",
["illustrator:sgkgodganning"] = "魂烈",
["cv:sgkgodganning"] = "魂烈",
}


--神典韦
sgkgoddianwei = sgs.General(extension, "sgkgoddianwei", "sy_god", 6)


--[[
	技能名：掷戟
	相关武将：神典韦
	技能描述：出牌阶段限一次，你可以弃置至少一张武器牌，然后对至多等量的其他角色各造成等量的伤害。准备阶段，若你已受伤，或当你受到伤害后，你可从场上、牌堆、
	弃牌堆中获得一张武器牌，然后弃置一张非装备牌。
	引用：sgkgodzhiji
]]--
sgkgodzhijiCard = sgs.CreateSkillCard{
    name = "sgkgodzhijiCard",
	target_fixed = false,
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select)
		return to_select:getSeat() ~= sgs.Self:getSeat() and #targets < self:subcardsLength()
	end,
	feasible = function(self, targets)
	    return #targets > 0 and #targets <= self:subcardsLength()
	end,
	on_use = function(self, room, source, targets)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW, source:objectName(), "sgkgodzhiji", "")
		room:throwCard(self, reason, nil)
		room:broadcastSkillInvoke("sgkgodzhiji", math.random(1, 3))
		for i = 1, #targets, 1 do
			room:damage(sgs.DamageStruct("sgkgodzhiji", source, targets[i], self:getSubcards():length()))
		end
	end
}

sgkgodzhijiVS = sgs.CreateViewAsSkill{
    name = "sgkgodzhiji",
	n = 999,
	view_filter = function(self, selected, to_select)
	    return (not sgs.Self:isJilei(to_select)) and to_select:isKindOf("Weapon")
	end,
	view_as = function(self, cards)
	    if #cards == 0 then return nil end
		local zhiji_card = sgkgodzhijiCard:clone()
		for _, c in ipairs(cards) do
		    zhiji_card:addSubcard(c)
		end
		zhiji_card:setSkillName("sgkgodzhiji")
		return zhiji_card
	end,
	enabled_at_play = function(self, player)
	    return not player:hasUsed("#sgkgodzhijiCard") and player:canDiscard(player, "he")
	end
}

sgkgodzhiji = sgs.CreateTriggerSkill{
    name = "sgkgodzhiji",
	view_as_skill = sgkgodzhijiVS,
	events = {sgs.Damaged, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.Damaged or (event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Start and player:isWounded()) then
			local to_get = {}
			local hasweapon = sgs.SPlayerList()
			for _, pe in sgs.qlist(room:getOtherPlayers(player)) do
				if pe:getWeapon() ~= nil then hasweapon:append(pe) end
			end
			if not hasweapon:isEmpty() then table.insert(to_get, "zhiji_fromOther") end
			local Weapon_items = sgs.IntList()
			for _, c in sgs.qlist(room:getDrawPile()) do
				if sgs.Sanguosha:getCard(c):isKindOf("Weapon") then
					local weapon = sgs.Sanguosha:getCard(c)
					Weapon_items:append(weapon:getEffectiveId())
				end
			end
			for _, c in sgs.qlist(room:getDiscardPile()) do
				if sgs.Sanguosha:getCard(c):isKindOf("Weapon") then
					local weapon = sgs.Sanguosha:getCard(c)
					Weapon_items:append(weapon:getEffectiveId())
				end
			end
			if not Weapon_items:isEmpty() then table.insert(to_get, "zhiji_fromPile") end
			if #to_get == 0 then return false end
			if player:askForSkillInvoke(self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName(), 4)
				local choice = room:askForChoice(player, self:objectName(), table.concat(to_get, "+"), data)
				if choice == "zhiji_fromOther" then
					local t = room:askForPlayerChosen(player, hasweapon, self:objectName())
					if t then
						room:doAnimate(1, player:objectName(), t:objectName())
						room:obtainCard(player, t:getWeapon(), true)
					end
				else
					local N = Weapon_items:length() - 1
					local ran_weapon = Weapon_items:at(math.random(0, N))
					room:obtainCard(player, ran_weapon, false)
				end
				Weapon_items = sgs.IntList()
				local has_not_equip = false
				for _, _card in sgs.qlist(player:getCards("he")) do
					if not _card:isKindOf("EquipCard") then
						has_not_equip = true
						break
					end
				end
				if has_not_equip then room:askForDiscard(player, self:objectName(), 1, 1, false, true, nil, "^EquipCard") end
			end
		end
		return false
	end
}


sgkgoddianwei:addSkill(sgkgodzhiji)


sgs.LoadTranslationTable{
["sgkgoddianwei"] = "神典韦",
["#sgkgoddianwei"] = "丘峦崩摧",
["&sgkgoddianwei"] = "神典韦",
["~sgkgoddianwei"] = "主公安然，末将，死而……无憾……",
["sgkgodzhiji"] = "掷戟",
["$sgkgodzhiji1"] = "恶来之力，助我神威！",
["$sgkgodzhiji2"] = "铁戟出，地狱开！",
["$sgkgodzhiji3"] = "这一戟，定让你魂飞魄散！",
["$sgkgodzhiji4"] = "这天下，没有我拿不动的兵器！",
[":sgkgodzhiji"] = "出牌阶段限一次，你可以弃置至少一张武器牌，然后对至多等量的其他角色各造成等量的伤害。准备阶段，若你已受伤，或当你受到伤害后，你可从场上、"..
"牌堆、弃牌堆中获得一张武器牌，然后弃置一张非装备牌。",
["zhiji_fromOther"] = "从场上获得一张武器牌",
["zhiji_fromPile"] = "从牌堆或弃牌堆中获得一张武器牌",
["designer:sgkgoddianwei"] = "魂烈",
["illustrator:sgkgoddianwei"] = "魂烈",
["cv:sgkgoddianwei"] = "魂烈",
}


--神夏侯惇
sgkgodxiahoudun = sgs.General(extension, "sgkgodxiahoudun", "sy_god", 5)


--[[
	技能名：啖睛
	相关武将：神夏侯惇
	技能描述：当你受到伤害/失去体力/减体力上限/弃置牌后，你可以令一名其他角色也执行此效果。
	引用：sgkgoddanjing
]]--
function Nature2String(nature)
	if nature == sgs.DamageStruct_Normal then return "normal" end
	if nature == sgs.DamageStruct_Fire then return "fire" end
	if nature == sgs.DamageStruct_Thunder then return "thunder" end
	if nature == sgs.DamageStruct_Ice then return "ice" end
	if nature == sgs.DamageStruct_Poison then return "poison" end
end

sgkgoddanjing = sgs.CreateTriggerSkill{
	name = "sgkgoddanjing",
	events = {sgs.Damaged, sgs.HpLost, sgs.CardsMoveOneTime, sgs.MaxHpChanged},
	priority = {1, 1, 1, 10},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.Damaged then
			local damage = data:toDamage()
			local q = sgs.QVariant()
			q:setValue(damage)
			player:setTag("danjing_damage", q)
			if damage.damage > 0 then
				local current_nature = damage.nature
				local prompt = "@danjing_dmg:"..tostring(damage.damage)..":"..Nature2String(current_nature)
				local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), "sgkgoddanjing_damage", prompt, true, true)
				if target then
					room:doAnimate(1, player:objectName(), target:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:damage(sgs.DamageStruct(self:objectName(), player, target, damage.damage, current_nature))
				end
			end
		elseif event == sgs.HpLost then
			local lose = data:toHpLost().lose
			local prompt = "@danjing_lose:"..tostring(lose)
			local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), "sgkgoddanjing_lose", prompt, true, true)
			if target then
				room:doAnimate(1, player:objectName(), target:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:loseHp(target, lose)
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() and bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD then
				local x = move.card_ids:length()
				local prompt = "@danjing_discard:"..tostring(x)
				local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), "sgkgoddanjing_discard", prompt, true, true)
				if target then
					room:doAnimate(1, player:objectName(), target:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:askForDiscard(target, self:objectName(), x, x, false, true)
				end
			end
		elseif event == sgs.MaxHpChanged then
			local max0 = player:getTag("hunlie_global_MaxHp"):toInt()
			if player:getMaxHp() < max0 then
				local dif = max0 - player:getMaxHp()
				local prompt = "@danjing_maxhp:"..tostring(dif)
				local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), "sgkgoddanjing_maxhp", prompt, true, true)
				if target then
					room:doAnimate(1, player:objectName(), target:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:loseMaxHp(target, dif)
				end
			end
		end
		return false
	end
}


--[[
	技能名：忠魂
	相关武将：神夏侯惇
	技能描述：限定技，游戏开始时，或出牌阶段，你可以减1点体力上限并选择一名其他角色，令其加1点体力上限并回复1点体力，若如此做，当其受到伤害时，若此伤害有
	来源且不为你，将此伤害转移给你；当你死亡时，其获得你的所有技能。
	引用：sgkgodzhonghun
]]--
sgkgodzhonghunCard = sgs.CreateSkillCard{
	name = "sgkgodzhonghunCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		if #targets == 0 then
		    return to_select:objectName() ~= sgs.Self:objectName() and to_select:getMark("&sgkgodzhonghun") == 0
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local zhonghun_data = sgs.QVariant()
		zhonghun_data:setValue(target)
		source:setTag("zhonghunTarget", zhonghun_data)
		room:addPlayerMark(source, "sgkgodzhonghun")
		room:addPlayerMark(target, "&sgkgodzhonghun")
		room:loseMaxHp(source)
		room:gainMaxHp(target, 1)
		local rec = sgs.RecoverStruct()
		rec.recover = 1
		rec.who = source
		room:recover(target, rec, true)
	end
}

sgkgodzhonghunVS = sgs.CreateZeroCardViewAsSkill{
	name = "sgkgodzhonghun",
	view_as = function()
		return sgkgodzhonghunCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#sgkgodzhonghunCard") and player:getMark("sgkgodzhonghun") == 0
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@sgkgodzhonghun" and player:getMark("sgkgodzhonghun") == 0
	end
}


sgkgodzhonghun = sgs.CreateTriggerSkill{
    name = "sgkgodzhonghun",
	view_as_skill = sgkgodzhonghunVS,
	frequency = sgs.Skill_Limited,
	events = {sgs.GameStart, sgs.DamageInflicted, sgs.Death},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.GameStart then
			if player:hasSkill(self:objectName())  then
				if not room:askForUseCard(player, "@@sgkgodzhonghun", "@sgkgodzhonghun") then room:setPlayerMark(player, self:objectName(), 0) end
			end
		elseif event == sgs.DamageInflicted then
			if not room:findPlayerBySkillName(self:objectName()) then return false end
			local xiahou = room:findPlayerBySkillName(self:objectName())
			local damage = data:toDamage()
			if player:getMark("&"..self:objectName()) > 0 and damage.damage > 0 and damage.from and damage.from:getSeat() ~= xiahou:getSeat() then
				damage.to = xiahou
				damage.transfer = true
				data:setValue(damage)
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if not death.who:hasSkill(self:objectName()) then return false end
			if death.who:objectName() ~= player:objectName() then return false end
			local zhonghun_tar = player:getTag("zhonghunTarget"):toPlayer()
			if zhonghun_tar and zhonghun_tar:isAlive() then
				local my_skills = {}
				local skill_list = player:getVisibleSkillList()
				for _, skill in sgs.qlist(skill_list) do
					table.insert(my_skills, skill:objectName())
				end
				if #my_skills == 0 then return false end
				room:doAnimate(1, player:objectName(), zhonghun_tar:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
				room:handleAcquireDetachSkills(zhonghun_tar, table.concat(my_skills, "|"))
			end
		end
	end,
	can_trigger = function(self, target)
	    return target:hasSkill(self:objectName()) or target:getMark("&"..self:objectName()) > 0
	end
}


sgkgodxiahoudun:addSkill(sgkgoddanjing)
sgkgodxiahoudun:addSkill(sgkgodzhonghun)


sgs.LoadTranslationTable{
    ["sgkgodxiahoudun"] = "神夏侯惇",
	["&sgkgodxiahoudun"] = "神夏侯惇",
	["#sgkgodxiahoudun"] = "不灭忠候",
	["~sgkgodxiahoudun"] = "我要……亲自向丞相、谢罪……",
	["sgkgoddanjing"] = "啖睛",
	["sgkgoddanjing_damage"] = "啖睛",
	["sgkgoddanjing_discard"] = "啖睛",
	["sgkgoddanjing_lose"] = "啖睛",
	["sgkgoddanjing_maxhp"] = "啖睛",
	["normal"] = "无属性",
	["fire"] = "火焰",
	["thunder"] = "雷电",
	["ice"] = "冰冻",
	["poison"] = "毒性",
	[":sgkgoddanjing"] = "当你受到伤害/失去体力/减体力上限/弃置牌后，你可以令一名其他角色也执行此效果。",
	["@danjing_dmg"] = "你可以发动“啖睛”对一名其他角色造成%src点%dest伤害",
	["@danjing_lose"] = "你可以发动“啖睛”令一名其他角色失去%src点体力",
	["@danjing_maxhp"] = "你可以发动“啖睛”令一名其他角色失去%src点体力上限",
	["@danjing_discard"] = "你可以发动“啖睛”令一名其他角色弃置%src张牌",
	["$sgkgoddanjing1"] = "我看见你了！",
	["$sgkgoddanjing2"] = "想走？把人头留下！",
	["$sgkgoddanjing3"] = "父精母血，不可弃之！",
	["sgkgodzhonghun"] = "忠魂",
	[":sgkgodzhonghun"] = "限定技，游戏开始时，或出牌阶段，你可以减1点体力上限并选择一名其他角色，令其加1点体力上限并回复1点体力，若如此做，当其受到伤害时，"..
	"若此伤害有来源且不为你，将此伤害转移给你；当你死亡时，其获得你的所有技能。",
	["$sgkgodzhonghun1"] = "都等什么？继续冲！",
	["$sgkgodzhonghun2"] = "还没分出胜负！",
	["@sgkgodzhonghun"] = "你可以选择一名其他角色对其发动“忠魂”，则本局游戏你将替其承担一切有来源且不为你造成的伤害，你死后其获得你的所有武将技能。",
}


--神孙尚香
sgkgodsunshangxiang = sgs.General(extension, "sgkgodsunshangxiang", "sy_god", 3, false)


--[[
	技能名：贤助
	相关武将：神孙尚香
	技能描述：当一名角色回复体力后，或失去装备区里的牌后，你可以令其摸两张牌。
	引用：sgkgodxianzhu
]]--
sgkgodxianzhu = sgs.CreateTriggerSkill{
	name = "sgkgodxianzhu",
	events = {sgs.CardsMoveOneTime, sgs.HpRecover},
	on_trigger = function(self, event, player, data, room)
		if not room:findPlayerBySkillName(self:objectName()) then return false end
		local sunshangxiang = room:findPlayerBySkillName(self:objectName())
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceEquip) then
				local _data = sgs.QVariant()
				_data:setValue(player)
				if sunshangxiang:askForSkillInvoke(self:objectName(), _data) then
					room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
					room:doAnimate(1, sunshangxiang:objectName(), player:objectName())
					player:drawCards(2, self:objectName())
				end
			end
		elseif event == sgs.HpRecover then
			local _data = sgs.QVariant()
			_data:setValue(player)
			if sunshangxiang:askForSkillInvoke(self:objectName(), _data) then
				room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
				room:doAnimate(1, sunshangxiang:objectName(), player:objectName())
				player:drawCards(2, self:objectName())
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target ~= nil
	end
}


sgkgodsunshangxiang:addSkill(sgkgodxianzhu)


--[[
	技能名：良缘
	相关武将：神孙尚香
	技能描述：限定技，出牌阶段，你可以选择一名其他男性角色，则于本局游戏中，你的自然回合结束时，该角色进行一个额外的回合。
	引用：sgkgodliangyuan
]]--
sgkgodliangyuanCard = sgs.CreateSkillCard{
	name = "sgkgodliangyuan",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
	    if #targets == 0 then
		    return to_select:objectName() ~= sgs.Self:objectName() and to_select:isMale() and to_select:isAlive()
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		source:loseMark("@liangyuan")
		local target = targets[1]
		room:addPlayerMark(target, "liangyuan_exturn_to")
		room:addPlayerMark(source, "liangyuan_exturn_from")
	end
}

sgkgodliangyuanVS = sgs.CreateZeroCardViewAsSkill{
	name = "sgkgodliangyuan",
	view_as = function()
		return sgkgodliangyuanCard:clone()
	end,
	enabled_at_play = function(self, player)
		return (not player:hasUsed("#sgkgodliangyuan")) and player:getMark("@liangyuan") > 0
	end
}

sgkgodliangyuan = sgs.CreateTriggerSkill{
	name = "sgkgodliangyuan",
	frequency = sgs.Skill_Limited,
	limit_mark = "@liangyuan",
	view_as_skill = sgkgodliangyuanVS,
	on_trigger = function()
	end
}

sgkgodliangyuan_check = sgs.CreateTriggerSkill{
	name = "#sgkgodliangyuan_check",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data, room)
		local change = data:toPhaseChange()
		if change.to == sgs.Player_NotActive then
			if player:getMark("liangyuan_exturn_from") > 0 then
				local liangyuan_male
				for _, pe in sgs.qlist(room:getAlivePlayers()) do
					if pe:getMark("liangyuan_exturn_to") > 0 then
						liangyuan_male = pe
						break
					end
				end
				if liangyuan_male then
					local playerdata = sgs.QVariant()
					playerdata:setValue(liangyuan_male)
					room:setTag("sgkgodliangyuan_exturn_Target", playerdata)
				end
			end
		end
	end
}

sgkgodliangyuan_exgive = sgs.CreateTriggerSkill{
	name = "#sgkgodliangyuan_exgive",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data, room)
		if room:getTag("sgkgodliangyuan_exturn_Target") then
			local target = room:getTag("sgkgodliangyuan_exturn_Target"):toPlayer()
			room:removeTag("sgkgodliangyuan_exturn_Target")
			if target and target:isAlive() then
				target:gainAnExtraTurn()
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and (target:getPhase() == sgs.Player_NotActive)
	end
}


extension:insertRelatedSkills("sgkgodliangyuan", "#sgkgodliangyuan_check")
extension:insertRelatedSkills("sgkgodliangyuan", "#sgkgodliangyuan_exgive")
sgkgodsunshangxiang:addSkill(sgkgodliangyuan)
sgkgodsunshangxiang:addSkill(sgkgodliangyuan_check)
sgkgodsunshangxiang:addSkill(sgkgodliangyuan_exgive)


sgs.LoadTranslationTable{
    ["sgkgodsunshangxiang"] = "神孙尚香",
	["&sgkgodsunshangxiang"] = "神孙尚香",
	["#sgkgodsunshangxiang"] = "蕙兰巾帼",
	["~sgkgodsunshangxiang"] = "夫君，你可会记得我的好……",
	["sgkgodxianzhu"] = "贤助",
	[":sgkgodxianzhu"] = "当一名角色回复体力后，或失去装备区里的牌后，你可以令其摸两张牌。",
	["$sgkgodxianzhu1"] = "春风复多情，吹我罗裳开。",
	["$sgkgodxianzhu2"] = "春林花多媚，春鸟意多哀。",
	["sgkgodliangyuan"] = "良缘",
	["@liangyuan"] = "良缘",
	[":sgkgodliangyuan"] = "限定技，出牌阶段，你可以选择一名其他男性角色，则于本局游戏中，你的自然回合结束时，该角色进行一个额外的回合。",
	["$sgkgodliangyuan"] = "我心如松柏，君情复何似？",
}


--神许褚
sgkgodxuchu = sgs.General(extension, "sgkgodxuchu", "sy_god", 5, true)


--[[
	技能名：虎痴
	相关武将：神许褚
	技能描述：出牌阶段，你可以视为使用【决斗】（不能被【无懈可击】响应），以此法受到伤害的角色摸3张牌。若有角色因此进入濒死状态或此【决斗】没有造成伤害，你
	于此阶段内不能再发动此技能。
	引用：sgkgodhuchi
]]--
sgkgodhuchiVS = sgs.CreateZeroCardViewAsSkill{
	name = "sgkgodhuchi",
	view_as = function(self, cards)
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		duel:setSkillName("sgkgodhuchi")
		return duel
	end,
	enabled_at_play = function(self, player)
		return not player:hasFlag("huchi_duel_forbidden")
	end
}

sgkgodhuchi = sgs.CreateTriggerSkill{
	name = "sgkgodhuchi",
	view_as_skill = sgkgodhuchiVS,
	events = {sgs.PreCardUsed, sgs.TrickCardCanceling, sgs.PreDamageDone, sgs.Damage, sgs.Damaged, sgs.Dying, sgs.CardFinished, sgs.EventPhaseChanging},
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.PreCardUsed then
			local use = data:toCardUse()
			if use.from and use.card and use.card:getSkillName() == self:objectName() then
				if use.from:hasSkill(self:objectName()) then room:addPlayerMark(use.from, "huchi_damage_globalcheck", 1) end
			end
		elseif event == sgs.TrickCardCanceling then
			local effect = data:toCardEffect()
			if effect.card and effect.card:isKindOf("Duel") and effect.card:getSkillName() == "sgkgodhuchi" then
				return true
			end
		elseif event == sgs.PreDamageDone then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Duel") and damage.card:getSkillName() == self:objectName() and damage.damage > 0 then
				damage.to:drawCards(3, self:objectName())
			end
		elseif event == sgs.Damage or event == sgs.Damaged then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Duel") and damage.card:getSkillName() == self:objectName() and damage.damage > 0 then
				if player:hasSkill(self:objectName()) and player:isAlive() then
					if player:getMark("huchi_damage_globalcheck") > 0 then
						room:setPlayerMark(player, "huchi_damage_globalcheck", 0)
					end
				end
			end
		elseif event == sgs.Dying then
			local dying = data:toDying()
			if dying.damage and dying.damage.card and dying.damage.card:getSkillName() == self:objectName() then
				if player:hasSkill(self:objectName()) then room:setPlayerFlag(player, "huchi_duel_forbidden") end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.from and use.card and use.card:isKindOf("Duel") and use.card:getSkillName() == self:objectName() then
				if use.from:hasSkill(self:objectName()) then
					if use.from:getMark("huchi_damage_globalcheck") > 0 then room:setPlayerFlag(use.from, "huchi_duel_forbidden") end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				if player:hasFlag("huchi_duel_forbidden") then room:setPlayerFlag(player, "-huchi_duel_forbidden") end
				room:setPlayerMark(player, "huchi_damage_globalcheck", 0)
			end
		end
		return false
	end
}


sgkgodxuchu:addSkill(sgkgodhuchi)


--[[
	技能名：卸甲
	相关武将：神许褚
	技能描述：锁定技，若你的装备区里没有防具牌，你使用【杀】和【决斗】对其他角色造成的伤害+X（X为你从装备区里失去防具牌的次数+1）。
	引用：sgkgodxiejia
]]--
sgkgodxiejia = sgs.CreateTriggerSkill{
	name = "sgkgodxiejia",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.DamageCaused then
			local damage = data:toDamage()
			if damage.chain or damage.transfer or (not damage.by_user) then return false end
			if player:getArmor() == nil and damage.card and (damage.card:isKindOf("Slash") or damage.card:isKindOf("Duel")) then
				if damage.to and damage.to:getSeat() ~= player:getSeat() then
					local x = player:getMark("&"..self:objectName())
					if x == 0 then
						room:doAnimate(1, player:objectName(), damage.to:objectName())
						room:broadcastSkillInvoke(self:objectName(), 1)
						room:sendCompulsoryTriggerLog(player, self:objectName())
						damage.damage = damage.damage + 1
						data:setValue(damage)
					elseif x > 0 then
						room:doAnimate(1, player:objectName(), damage.to:objectName())
						room:broadcastSkillInvoke(self:objectName(), 1)
						local msg = sgs.LogMessage()
						msg.type = "#XiejiaLoseArmor"
						msg.from = player
						msg.arg = tostring(x)
						msg.arg2 = tostring(x+1)
						msg.to:append(damage.to)
						msg.card_str = damage.card:toString()
						room:sendLog(msg)
						damage.damage = damage.damage + (x + 1)
						data:setValue(damage)
					end
				end
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and (move.from:objectName() == player:objectName()) and move.from_places:contains(sgs.Player_PlaceEquip) then
				local i = 0
				for _, id in sgs.qlist(move.card_ids) do
					if move.from_places:at(i) == sgs.Player_PlaceEquip then
						if sgs.Sanguosha:getCard(id):isKindOf("Armor") then
							room:sendCompulsoryTriggerLog(player, self:objectName())
							room:notifySkillInvoked(player, self:objectName())
							room:broadcastSkillInvoke(self:objectName(), 2)
							room:addPlayerMark(player, "&"..self:objectName(), 1)
						end
					end
					i = i + 1
				end
			end
		end
		return false
	end
}


sgkgodxuchu:addSkill(sgkgodxiejia)


sgs.LoadTranslationTable{
    ["sgkgodxuchu"] = "神许褚",
	["&sgkgodxuchu"] = "神许褚",
	["#sgkgodxuchu"] = "雷铸虎躯",
	["~sgkgodxuchu"] = "居然……是我先倒下……",
	["sgkgodhuchi"] = "虎痴",
	[":sgkgodhuchi"] = "出牌阶段，你可以视为使用【决斗】（不能被【无懈可击】响应），以此法受到伤害的角色摸3张牌。若有角色因此进入濒死状态或此【决斗】没有"..
	"造成伤害，你于此阶段内不能再发动此技能。",
	["$sgkgodhuchi1"] = "哈哈哈哈哈哈！痛快！痛快！",
	["$sgkgodhuchi2"] = "不是你死，便是我亡！",
	["sgkgodxiejia"] = "卸甲",
	[":sgkgodxiejia"] = "锁定技，若你的装备区里没有防具牌，你使用【杀】和【决斗】对其他角色造成的伤害+X（X为你从装备区里失去防具牌的次数+1）。",
	["#XiejiaLoseArmor"] = "%from 已从装备区里失去过 %arg 次防具牌，此 %card 对 %to 的伤害额外增加 %arg2 点",
	["$sgkgodxiejia1"] = "拔山扛鼎，力敌千军！",
	["$sgkgodxiejia2"] = "卸下重甲，方能战个痛快！",
}


--神大乔
sgkgoddaqiao = sgs.General(extension, "sgkgoddaqiao", "sy_god", 3, false)


--[[
	技能名：望月
	相关武将：神大乔
	技能描述：当一名角色弃牌/失去体力/减少体力上限后，你可以令另一名角色摸牌/回复体力/增加体力上限，每项每回合限一次。
	引用：sgkgodwangyue
]]--
sgkgodwangyue = sgs.CreateTriggerSkill{
	name = "sgkgodwangyue",
	events = {sgs.EventPhaseChanging, sgs.CardsMoveOneTime, sgs.HpLost, sgs.MaxHpChanged},
	priority = {10, 1, 1, 10},
	can_trigger = function(self, target)
		return target and target ~= nil
	end,
	on_trigger = function(self, event, player, data, room)
		if not room:findPlayerBySkillName(self:objectName()) then return false end
		local daqiao = room:findPlayerBySkillName(self:objectName())
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				room:setPlayerMark(daqiao, self:objectName().."_letdraw", 0)  --刷新大乔的每个选项记录
				room:setPlayerMark(daqiao, self:objectName().."_letrecoverhp", 0)
				room:setPlayerMark(daqiao, self:objectName().."_letaddmaxhp", 0)
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() and move.to_place == sgs.Player_DiscardPile and daqiao:getMark(self:objectName().."_letdraw") == 0
				and bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MA_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD then
				local x = move.card_ids:length()
				daqiao:setTag("wangyue_value", sgs.QVariant(x))
				local target = room:askForPlayerChosen(daqiao, room:getOtherPlayers(player), self:objectName().."_draw", "@wangyue_draw:"..tostring(x), true, true)
				if target then
					room:broadcastSkillInvoke(self:objectName())
					room:doAnimate(1, daqiao:objectName(), target:objectName())
					target:drawCards(x, self:objectName())
					room:addPlayerMark(daqiao, self:objectName().."_letdraw")
				end
			end
		elseif event == sgs.HpLost then
			local x = data:toHpLost().lose
			if daqiao:getMark(self:objectName().."_letrecoverhp") == 0 then
				local target = room:askForPlayerChosen(daqiao, room:getOtherPlayers(player), self:objectName().."_rec", "@wangyue_rec:"..tostring(x), true, true)
				if target then
					room:broadcastSkillInvoke(self:objectName())
					room:doAnimate(1, daqiao:objectName(), target:objectName())
					if target:isWounded() then
						local rec = sgs.RecoverStruct()
						rec.recover = math.min(x, target:getLostHp())
						rec.who = daqiao
						room:recover(target, rec, true)
					end
					room:addPlayerMark(daqiao, self:objectName().."_letrecoverhp")
				end
			end
		elseif event == sgs.MaxHpChanged then
			local max0 = player:getTag("hunlie_global_MaxHp"):toInt()  --获取变动前的maxHp
			if player:getMaxHp() < max0 then
				local dif = max0 - player:getMaxHp()
				if daqiao:getMark(self:objectName().."_letaddmaxhp") == 0 then
					local target = room:askForPlayerChosen(daqiao, room:getOtherPlayers(player), self:objectName().."_maxhp", "@wangyue_maxhp:"..tostring(dif), true, true)
					if target then
						room:broadcastSkillInvoke(self:objectName())
						room:doAnimate(1, daqiao:objectName(), target:objectName())
						room:gainMaxHp(target, dif)
						room:addPlayerMark(daqiao, self:objectName().."_letaddmaxhp")
					end
				end
			end
		end
		return false
	end
}


sgkgoddaqiao:addSkill(sgkgodwangyue)


--[[
	技能名：落雁
	相关武将：神大乔
	技能描述：回合结束阶段，你可选择一名角色，若如此做，当其于出牌阶段内使用第1/2/3张牌后，其随机弃置一张牌/失去1点体力/减1点体力上限。
	引用：sgkgodluoyan
]]--
sgkgodluoyan = sgs.CreateTriggerSkill{
	name = "sgkgodluoyan",
	events = {sgs.EventPhaseStart, sgs.CardFinished},
	can_trigger = function(self, target)
		return target and target ~= nil and (target:hasSkill(self:objectName()) or target:getMark("&"..self:objectName()) > 0)
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Finish then
				if player:hasSkill(self:objectName()) then
					local targets = sgs.SPlayerList()
					for _, pe in sgs.qlist(room:getAlivePlayers()) do
						if pe:getMark("&"..self:objectName()) == 0 then targets:append(pe) end
					end
					local has_luoyan = -1
					for _, pe in sgs.qlist(room:getAlivePlayers()) do
						if pe:getMark("&"..self:objectName()) > 0 then
							has_luoyan = pe
							break
						end
					end
					if targets:length() > 0 and player:askForSkillInvoke(self:objectName(), data) then
						local tar = room:askForPlayerChosen(player, targets, self:objectName())
						if tar then
							room:doAnimate(1, player:objectName(), tar:objectName())
							room:broadcastSkillInvoke(self:objectName())
							if has_luoyan ~= -1 then
								room:setPlayerMark(has_luoyan, "&"..self:objectName(), 0)
								room:setPlayerMark(has_luoyan, "luoyan_cardcount", 0)
							end
							room:addPlayerMark(tar, "&"..self:objectName(), 1)
						end
					end
				end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			local current = room:getCurrent()
			if use.from and use.from:getSeat() == current:getSeat() and player:getSeat() == current:getSeat() then
				if player:getMark("&"..self:objectName()) > 0 and player:getMark("luoyan_cardcount") < 3 then
					if use.card and use.card:getTypeId() ~= sgs.Card_TypeSkill then
						room:addPlayerMark(player, "luoyan_cardcount")
						if player:getMark("luoyan_cardcount") == 1 then
							if not player:isNude() then
								local cards = sgs.QList2Table(player:getCards("he"))
								local rc = cards[math.random(1, #cards)]
								local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW, player:objectName(), self:objectName(),"")
								room:throwCard(rc, reason, nil)
							end
						elseif player:getMark("luoyan_cardcount") == 2 then
							room:loseHp(player)
						elseif player:getMark("luoyan_cardcount") == 3 then
							room:loseMaxHp(player)
						end
					end
				end
			end
		end
		return false
	end
}


sgkgoddaqiao:addSkill(sgkgodluoyan)


sgs.LoadTranslationTable{
    ["sgkgoddaqiao"] = "神大乔",
	["&sgkgoddaqiao"] = "神大乔",
	["#sgkgoddaqiao"] = "韶华易逝",
	["~sgkgoddaqiao"] = "伯符，我终于能再度与你相遇……",
	["sgkgodwangyue"] = "望月",
	["sgkgodwangyue_draw"] = "望月",
	["sgkgodwangyue_rec"] = "望月",
	["sgkgodwangyue_maxhp"] = "望月",
	[":sgkgodwangyue"] = "当一名角色弃牌/失去体力/减少体力上限后，你可以令另一名角色摸牌/回复体力/增加体力上限，每项每回合限一次。",
	["@wangyue_draw"] = "你可以发动“望月”令一名角色摸%src张牌",
	["@wangyue_rec"] = "你可以发动“望月”令一名角色回复%src点体力",
	["@wangyue_maxhp"] = "你可以发动“望月令一名角色增加%src点体力上限”",
	["$sgkgodwangyue1"] = "清风吹寒裘，寒月照易人。",
	["$sgkgodwangyue2"] = "斜月照帘帷，念君何时归？",
	["sgkgodluoyan"] = "落雁",
	[":sgkgodluoyan"] = "回合结束阶段，你可选择一名角色，若如此做，当其于出牌阶段内使用第1/2/3张牌后，其随机弃置一张牌/失去1点体力/减1点体力上限。",
	["$sgkgodluoyan1"] = "秋风落黄叶，飘零独易居。",
	["$sgkgodluoyan2"] = "水影寒沾衣，独雁何处归？",
}


--神黄忠
sgkgodhuangzhong = sgs.General(extension, "sgkgodhuangzhong", "sy_god", 4, true)


--[[
	技能名：烈弓
	相关武将：神黄忠
	技能描述：你可以将至少一张花色各不相同的手牌当无距离和次数限制的【火杀】使用，若以此法使用的转化前的牌数不小于：1，此【火杀】不可被【闪】响应；2，此【火
	杀】结算完毕后，你摸三张牌；3，此【火杀】的伤害+1；4，此【火杀】造成伤害后，你令目标角色随机失去一个技能。每回合限一次，若你已受伤，改为每回合限两次。
	引用：sgkgodliegong
]]--
sgkgodliegongvs = sgs.CreateViewAsSkill{
	name = "sgkgodliegong",
	n = 4,
	view_filter = function(self, selected, to_select)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			if #selected >= 4 or to_select:hasFlag("using") then return false end
			for _, card in ipairs(selected) do
				if to_select:isEquipped() or card:getSuit() == to_select:getSuit() then return false end
			end
			local fire = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, -1)
			fire:addSubcard(to_select:getEffectiveId())
			fire:deleteLater()
			return not sgs.Self:isJilei(fire)
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 0 then return false end
		local lg_fire = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, -1)
		for _, card in ipairs(cards) do
			lg_fire:addSubcard(card)
		end
		lg_fire:setSkillName(self:objectName())
		return lg_fire
	end,
	enabled_at_play = function(self, player)
		if not player:isKongcheng() then
			local x = 1
			if player:isWounded() then x = 2 end
			return player:getMark("lg_fire_time") < x
		end
	end
}

sgkgodliegong = sgs.CreateTriggerSkill{
	name = "sgkgodliegong",
	view_as_skill = sgkgodliegongvs,
	events = {sgs.EventPhaseChanging, sgs.TargetConfirmed, sgs.CardFinished, sgs.DamageCaused, sgs.Damage},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				if player:getMark("lg_fire_time") > 0 then room:setPlayerMark(player, "lg_fire_time", 0) end
			end
		elseif event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if not use.from or player:objectName() ~= use.from:objectName() or (not use.card:isKindOf("FireSlash")) then return false end
			if use.card:getSkillName() ~= self:objectName() then return false end
			local n = use.card:subcardsLength()
			if n >= 1 then
				local msg = sgs.LogMessage()
				msg.from = player
				msg.type = "#FireLiegong1"
				msg.card_str = use.card:toString()
				msg.arg = self:objectName()
				room:sendLog(msg)
				local jink_table = sgs.QList2Table(player:getTag("Jink_" .. use.card:toString()):toIntList())
				local index = 1
				for _, t in sgs.qlist(use.to) do
					jink_table[index] = 0
					index = index + 1
				end
				local jink_data = sgs.QVariant()
				jink_data:setValue(Table2IntList(jink_table))
				player:setTag("Jink_" .. use.card:toString(), jink_data)
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if not use.from or player:objectName() ~= use.from:objectName() or (not use.card:isKindOf("FireSlash")) then return false end
			if use.card:getSkillName() ~= self:objectName() then return false end
			room:addPlayerMark(player, "lg_fire_time", 1)
			local n = use.card:subcardsLength()
			if n >= 2 then
				local msg = sgs.LogMessage()
				msg.from = player
				msg.type = "#FireLiegong2"
				msg.card_str = use.card:toString()
				msg.arg = self:objectName()
				room:sendLog(msg)
				player:drawCards(3, self:objectName())
			end
		elseif event == sgs.DamageCaused then
			local damage = data:toDamage()
			if damage.card and (not damage.chain) and (not damage.transfer) and damage.card:getSkillName() == self:objectName() then
				local n = damage.card:subcardsLength()
				if n >= 3 then
					local msg = sgs.LogMessage()
					msg.from = player
					msg.type = "#FireLiegong3"
					msg.card_str = damage.card:toString()
					msg.arg = tostring(damage.damage)
					msg.arg2 = tostring(damage.damage + 1)
					room:sendLog(msg)
					damage.damage = damage.damage + 1
					data:setValue(damage)
				end
			end
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if damage.card and damage.card:getSkillName() == self:objectName() and damage.damage > 0 then
				local n = damage.card:subcardsLength()
				if n >= 4 and damage.to and damage.to:isAlive() and damage.to:getSeat() ~= player:getSeat() and (not damage.transfer) then
					local to_lose = {}
					if not damage.to:getVisibleSkillList():isEmpty() then
						for _, _skill in sgs.qlist(damage.to:getVisibleSkillList()) do
							table.insert(to_lose, "-".._skill:objectName())
						end
					end
					if #to_lose > 0 then
						local msg = sgs.LogMessage()
						msg.from = player
						msg.type = "#FireLiegong4"
						msg.card_str = damage.card:toString()
						msg.arg = self:objectName()
						msg.to:append(damage.to)
						room:sendLog(msg)
						room:handleAcquireDetachSkills(damage.to, to_lose[math.random(1, #to_lose)])
					end
				end
			end
		end
		return false
	end
}


sgkgodhuangzhong:addSkill(sgkgodliegong)


sgs.LoadTranslationTable{
    ["sgkgodhuangzhong"] = "神黄忠",
	["&sgkgodhuangzhong"] = "神黄忠",
	["#sgkgodhuangzhong"] = "气概天参",
	["~sgkgodhuangzhong"] = "终究敌不过这沧桑岁月……",
	["sgkgodliegong"] = "烈弓",
	[":sgkgodliegong"] = "你可以将至少一张花色各不相同的手牌当无距离和次数限制的【火杀】使用，若以此法使用的转化前的牌数不小于：1，此【火杀】不可被【闪】响"..
	"应；2，此【火杀】结算完毕后，你摸三张牌；3，此【火杀】的伤害+1；4，此【火杀】造成伤害后，你令目标角色随机失去一个技能。每回合限一次，若你已受伤，改为每"..
	"回合限两次。",
	["#FireLiegong1"] = "由于“%arg”的技能效果，%from 使用的 %card 不能被【<font color = 'yellow'><b>闪</b></font>】响应",
	["#FireLiegong2"] = "由于“%arg”的技能效果，%from 使用的 %card 在结算完毕后，%from摸 <font color = 'yellow'><b>3</b></font> 张牌",
	["#FireLiegong3"] = "由于“<font color = 'yellow'><b>烈弓</b></font>”的技能效果，%from 使用的 %card 造成的伤害从 %arg 点增加至 %arg2 点",
	["#FireLiegong4"] = "由于“%arg”的技能效果，%to 受到 %from 使用的 %card 造成的伤害后将随机失去1个武将技能",
	["$sgkgodliegong1"] = "烈弓神威，箭矢毙敌！",
	["$sgkgodliegong2"] = "鋷甲锵躯，肝胆俱裂！"
}
return {extension}