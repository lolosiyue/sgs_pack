extension = sgs.Package("sd", sgs.Package_GeneralPack)

--==沙雕包1.0（8）==--
--[[《目录》：
大宝&大鬼&大妖、五虎上将；神黄盖、神华佗；神笔马良、魔王-孙笑川(主公)；管云鹏、广西鹿哥
]]

--SD1 001 大宝&大鬼&大妖
DABAO_DAGUI_DAYAO = sgs.General(extension, "DABAO_DAGUI_DAYAO", "god", 10, true, false, false, 3)

--“佐幸”技能卡：
dy_zuoxingCard = sgs.CreateSkillCard{
	name = "dy_zuoxingCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		local card = sgs.Self:getTag("dy_zuoxing"):toCard()
		card:setSkillName("dy_zuoxing")
		if card and card:targetFixed() then
			return false
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetFilter(qtargets, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, qtargets)
	end,
	feasible = function(self, targets)
		local card = sgs.Self:getTag("dy_zuoxing"):toCard()
		card:setSkillName("dy_zuoxing")
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if card and card:canRecast() and #targets == 0 then
			return false
		end
		return card and card:targetsFeasible(qtargets, sgs.Self)
	end,
	on_validate = function(self, card_use)
		local player = card_use.from
		local room = player:getRoom()
		room:loseMaxHp(player, 1)
		local use_card = sgs.Sanguosha:cloneCard(self:getUserString())
		use_card:setSkillName("dy_zuoxing")
		local available = true
		for _, p in sgs.qlist(card_use.to) do
			if player:isProhibited(p, use_card) then
				available = false
				break
			end
		end
		available = available and use_card:isAvailable(player)
		if not available then return nil end
		use_card:deleteLater()
		return use_card
	end,
}
dy_zuoxing = sgs.CreateViewAsSkill{
	name = "dy_zuoxing",
	n = 0,
	view_filter = function(self, selected, to_select)
		return false
	end,
	view_as = function(self, cards)
		local c = sgs.Self:getTag("dy_zuoxing"):toCard()
		if c then
			local card = dy_zuoxingCard:clone()
			card:setUserString(c:objectName())	
			return card
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#dy_zuoxingCard") and player:getMaxHp() > 1
	end,
}
dy_zuoxing:setGuhuoDialog("r")
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("dy_zuoxing") then skills:append(dy_zuoxing) end
----
thisisyinjian = sgs.CreateTriggerSkill{
	name = "thisisyinjian",
	priority = 10,
	frequency = sgs.Skill_Compulsory,
	waked_skills = "mobilepojun, jieyingg, dy_zuoxing",
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		if not player:hasSkill("mobilepojun") then
			room:acquireSkill(player, "mobilepojun")
		end
		if not player:hasSkill("jieyingg") then
			room:acquireSkill(player, "jieyingg")
		end
		if not player:hasSkill("dy_zuoxing") then
			room:acquireSkill(player, "dy_zuoxing")
		end
	end,
}
DABAO_DAGUI_DAYAO:addSkill(thisisyinjian)
DABAO_DAGUI_DAYAO:addRelateSkill("mobilepojun")
DABAO_DAGUI_DAYAO:addRelateSkill("jieyingg")
DABAO_DAGUI_DAYAO:addRelateSkill("dy_zuoxing")
--阴间三兄弟回合开始专属音响（彩蛋，有30%的可能播放）
mobileyinjianAudio = sgs.CreateTriggerSkill{
    name = "mobileyinjianAudio",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_RoundStart and math.random() < 0.3 then
		    --room:sendCompulsoryTriggerLog("comefromyinjian", self:objectName())
			room:broadcastSkillInvoke(self:objectName())
		end
	end,
	can_trigger = function(self, player)
	    return player:getGeneralName() == "DABAO_DAGUI_DAYAO" or player:getGeneral2Name() == "DABAO_DAGUI_DAYAO"
	end,
}
if not sgs.Sanguosha:getSkill("mobileyinjianAudio") then skills:append(mobileyinjianAudio) end




--

--SD1 002 五虎上将
f_wuhushangjiang = sgs.General(extension, "f_wuhushangjiang", "shu", 5, true)

f_hujiang = sgs.CreateTriggerSkill{
	name = "f_hujiang",
	priority = 10,
	frequency = sgs.Skill_Compulsory,
	waked_skills = "tenyearwusheng, olpaoxiao, ollongdan, tenyearliegong, tieji",
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:acquireSkill(player, "tenyearwusheng")
		room:acquireSkill(player, "olpaoxiao")
		room:acquireSkill(player, "ollongdan")
		room:acquireSkill(player, "tenyearliegong")
		room:acquireSkill(player, "tieji")
	end,
}
f_wuhushangjiang:addSkill(f_hujiang)
f_wuhushangjiang:addRelateSkill("tenyearwusheng")
f_wuhushangjiang:addRelateSkill("olpaoxiao")
f_wuhushangjiang:addRelateSkill("ollongdan")
f_wuhushangjiang:addRelateSkill("tenyearliegong")
f_wuhushangjiang:addRelateSkill("tieji")

f_jianghunCard = sgs.CreateSkillCard{
    name = "f_jianghunCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    room:addPlayerMark(source, "f_jianghun_used")
		room:loseMaxHp(source, 1)
		local num = source:getMark("f_jianghun_used")
		room:drawCards(source, num)
		room:broadcastSkillInvoke("f_jianghun")
	end,
}
f_jianghun = sgs.CreateZeroCardViewAsSkill{
    name = "f_jianghun",
	view_as = function()
		return f_jianghunCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_jianghunCard")
	end,
}
f_wuhushangjiang:addSkill(f_jianghun)


--

--SD1 003 神黄盖
f_shenhuanggai = sgs.General(extension, "f_shenhuanggai", "god", 8, true)

f_kuzhaCard = sgs.CreateSkillCard{
    name = "f_kuzhaCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    room:loseMaxHp(source, 1)
		if not source:hasSkill("noskurou") then
		    room:acquireSkill(source, "noskurou")
		end
	end,
}
f_kuzha = sgs.CreateZeroCardViewAsSkill{
    name = "f_kuzha",
	view_as = function()
		return f_kuzhaCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_kuzhaCard")
	end,
}
f_kuzha_finish = sgs.CreateTriggerSkill{
    name = "f_kuzha_finish",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then
			return false
		end
		for _, p in sgs.qlist(room:getAllPlayers()) do
		    if player:hasSkill("noskurou") then
			    room:detachSkillFromPlayer(player, "noskurou", false, true)
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_kuzha")
	end,
}
f_shenhuanggai:addSkill(f_kuzha)
if not sgs.Sanguosha:getSkill("f_kuzha_finish") then skills:append(f_kuzha_finish) end

f_shenxianshizuCard = sgs.CreateSkillCard{
	name = "f_shenxianshizuCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets < 1 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
	    local room = effect.to:getRoom()
		room:removePlayerMark(effect.from, "@f_shenxianshizu")
		room:obtainCard(effect.to, effect.from:wholeHandCards(), false)
		room:setPlayerFlag(effect.from, "zbkcSource")
		room:setPlayerFlag(effect.to, "zbkcTarget")
		--room:setEmotion(effect.to, "huoshaochibi")
		room:doSuperLightbox("f_shenhuanggai", "huoshaochibi")
	end,
}
f_shenxianshizuVS = sgs.CreateZeroCardViewAsSkill{
    name = "f_shenxianshizu",
	view_as = function()
		return f_shenxianshizuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@f_shenxianshizu") > 0
	end,
}
f_shenxianshizu = sgs.CreateTriggerSkill{
	name = "f_shenxianshizu",
	frequency = sgs.Skill_Limited,
	limit_mark = "@f_shenxianshizu",
	view_as_skill = f_shenxianshizuVS,
	on_trigger = function()
	end,
}
f_shenhuanggai:addSkill(f_shenxianshizu)
--通过“身先”获得的BUFF：
f_shenxianshizuA = sgs.CreateTargetModSkill{
	name = "f_shenxianshizuA",
	distance_limit_func = function(self, from, card, to)
		if from:hasSkill("f_shenxianshizu") and from:hasFlag("zbkcSource") and card:isKindOf("Slash") and to and to:hasFlag("zbkcTarget") then
			return 1000
		else
			return 0
		end
	end,
}
f_shenxianshizuB = sgs.CreateTargetModSkill{
	name = "f_shenxianshizuB",
	residue_func = function(self, from, card, to)
		if from:hasSkill("f_shenxianshizu") and from:hasFlag("zbkcSource") and card:isKindOf("Slash") and to and to:hasFlag("zbkcTarget") then
			return 1000
		else
			return 0
		end
	end,
}
f_shenxianshizu_fire = sgs.CreateTriggerSkill{
	name = "f_shenxianshizu_fire",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.nature == sgs.DamageStruct_Fire and damage.from:objectName() == player:objectName() and player:hasFlag("zbkcSource") and damage.to:hasFlag("zbkcTarget") then
			room:sendCompulsoryTriggerLog(player, "f_shenxianshizu")
			room:broadcastSkillInvoke("f_shenxianshizu")
			damage.damage = damage.damage + 1
			data:setValue(damage)
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_shenxianshizu")
	end,
}
if not sgs.Sanguosha:getSkill("f_shenxianshizuA") then skills:append(f_shenxianshizuA) end
if not sgs.Sanguosha:getSkill("f_shenxianshizuB") then skills:append(f_shenxianshizuB) end
if not sgs.Sanguosha:getSkill("f_shenxianshizu_fire") then skills:append(f_shenxianshizu_fire) end





--

--SD1 004 神华佗
f_shenhuatuo = sgs.General(extension, "f_shenhuatuo", "god", 3, true)

f_liaoduCard = sgs.CreateSkillCard{
    name = "f_liaoduCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
	    return #targets == 0
	end,
	on_use = function(self, room, source, targets)
	    local gy = targets[1]
		local recover = sgs.RecoverStruct()
		recover.recover = 1
		recover.who = gy
		room:recover(gy, recover)
		room:drawCards(gy, 1, "f_liaodu")
		if gy:hasJudgeArea() then
			gy:throwJudgeArea() --以此来实现清空判定区
			gy:obtainJudgeArea()
		end
		if gy:isChained() then
			room:setPlayerProperty(gy, "chained", sgs.QVariant(false))
		end
		if not gy:faceUp() then
			gy:turnOver()
		end
	end,
}
f_liaodu = sgs.CreateViewAsSkill{
    name = "f_liaodu",
	n = 1,
	view_filter = function(self, selected, to_select)
	    return to_select:isKindOf("EquipCard")
	end,
	view_as = function(self, cards)
	    if #cards == 0 then return end
		local guagu_card = f_liaoduCard:clone()
		guagu_card:addSubcard(cards[1])
		return guagu_card
	end,
	enabled_at_play = function(self, player)
	    return not player:hasUsed("#f_liaoduCard")
	end,
}
f_shenhuatuo:addSkill(f_liaodu)

f_mafeiCard = sgs.CreateSkillCard{
    name = "f_mafeiCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
	    return #targets == 0
	end,
	on_use = function(self, room, source, targets)
	    local br = targets[1]
		br:turnOver()
		if not br:faceUp() then
			room:addPlayerMark(br, "&f_mafeisan")
		end
	end,
}
f_mafei = sgs.CreateViewAsSkill{
    name = "f_mafei",
	n = 1,
	view_filter = function(self, selected, to_select)
	    return to_select:isKindOf("TrickCard")
	end,
	view_as = function(self, cards)
	    if #cards == 0 then return end
		local yao_card = f_mafeiCard:clone()
		yao_card:addSubcard(cards[1])
		return yao_card
	end,
	enabled_at_play = function(self, player)
	    return not player:hasUsed("#f_mafeiCard")
	end,
}
f_mafeiBuff = sgs.CreateTriggerSkill{
    name = "f_mafeiBuff",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted, sgs.PreHpRecover, sgs.TurnedOver},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DamageInflicted and not player:faceUp() then
		    local damage = data:toDamage()
			if not player:isNude() then
				room:askForDiscard(player, "f_mafei", 1, 1, false, true)
			end
			local log = sgs.LogMessage()
			log.type = "$f_mafeiBuff_jianshang"
			log.from = player
			room:sendLog(log)
			room:broadcastSkillInvoke("f_mafei")
			damage.damage = damage.damage - 1
			data:setValue(damage)
			if damage.damage < 1 then return true end
		elseif event == sgs.PreHpRecover and not player:faceUp() then
		    local recover = data:toRecover()
			local log = sgs.LogMessage()
			log.type = "$f_mafeiBuff_recover"
			log.from = player
			room:sendLog(log)
			room:broadcastSkillInvoke("f_mafei")
			recover.recover = recover.recover + 1
			data:setValue(recover)
		elseif event == sgs.TurnedOver and player:faceUp() then
			room:broadcastSkillInvoke("f_mafei")
			room:removePlayerMark(player, "&f_mafeisan")
		end
	end,
	can_trigger = function(self, player)
	    return player:getMark("&f_mafeisan") > 0
	end,
}
f_shenhuatuo:addSkill(f_mafei)
if not sgs.Sanguosha:getSkill("f_mafeiBuff") then skills:append(f_mafeiBuff) end

f_wuqinCard = sgs.CreateSkillCard{
    name = "f_wuqinCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
	    return #targets == 0
	end,
	on_use = function(self, room, source, targets)
	    local tudi = targets[1]
		--room:doLightbox("$f_wuqin_start")
		if math.random() > 0.2 then
		    room:getThread():delay(2000)
			local log = sgs.LogMessage()
			log.type = "$f_wuqin_tiger_success"
			log.from = source
			room:sendLog(log)
			if tudi:getMark("&f_wuqin_tiger") == 0 then
				room:addPlayerMark(tudi, "&f_wuqin_tiger")
			end
		end
		if math.random() > 0.2 then
		    room:getThread():delay(2000)
			local log = sgs.LogMessage()
			log.type = "$f_wuqin_deer_success"
			log.from = source
			room:sendLog(log)
			if tudi:getMark("&f_wuqin_deer") == 0 then
				room:addPlayerMark(tudi, "&f_wuqin_deer")
			end
		end
		if math.random() > 0.2 then
		    room:getThread():delay(2000)
			local log = sgs.LogMessage()
			log.type = "$f_wuqin_bear_success"
			log.from = source
			room:sendLog(log)
			if tudi:getMark("&f_wuqin_bear") == 0 then
				room:addPlayerMark(tudi, "&f_wuqin_bear")
			end
		end
		if math.random() > 0.2 then
		    room:getThread():delay(2000)
			local log = sgs.LogMessage()
			log.type = "$f_wuqin_ape_success"
			log.from = source
			room:sendLog(log)
			if tudi:getMark("&f_wuqin_ape") == 0 then
				room:addPlayerMark(tudi, "&f_wuqin_ape")
			end
		end
		if math.random() > 0.2 then
		    room:getThread():delay(2000)
			local log = sgs.LogMessage()
			log.type = "$f_wuqin_bird_success"
			log.from = source
			room:sendLog(log)
			if tudi:getMark("&f_wuqin_bird") == 0 then
				room:addPlayerMark(tudi, "&f_wuqin_bird")
			end
		end
		local log = sgs.LogMessage()
		log.type = "$f_wuqin_finish"
		log.from = source
		room:sendLog(log)
	end,
}
f_wuqin = sgs.CreateViewAsSkill{
    name = "f_wuqin",
	n = 1,
	view_filter = function(self, selected, to_select)
	    return to_select:isKindOf("BasicCard")
	end,
	view_as = function(self, cards)
	    if #cards == 0 then return end
		local wqx_card = f_wuqinCard:clone()
		wqx_card:addSubcard(cards[1])
		return wqx_card
	end,
	enabled_at_play = function(self, player)
	    return not player:hasUsed("#f_wuqinCard")
	end,
}
f_shenhuatuo:addSkill(f_wuqin)
--“五禽戏”
  --虎戏
f_wuqin_tigerBuff = sgs.CreateTriggerSkill{
	name = "f_wuqin_tigerBuff",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.card and (damage.card:isKindOf("Slash") or damage.card:isKindOf("Duel")) then
			local log = sgs.LogMessage()
			log.type = "$f_wuqin_tigerBuff"
			log.from = player
			log.card_str = damage.card:toString()
			room:sendLog(log)
			damage.damage = damage.damage + 1
			data:setValue(damage)
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&f_wuqin_tiger") > 0
	end,
}
  --鹿戏
f_wuqin_deerBuff = sgs.CreateTriggerSkill{
	name = "f_wuqin_deerBuff",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.PreHpRecover},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local recover = data:toRecover()
		if recover.card and (recover.card:isKindOf("Peach") or recover.card:isKindOf("Analeptic")) then
			local log = sgs.LogMessage()
			log.type = "$f_wuqin_deerBuff"
			log.from = player
			log.card_str = recover.card:toString()
			room:sendLog(log)
			recover.recover = recover.recover + 1
			data:setValue(recover)
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&f_wuqin_deer") > 0
	end,
}
  --熊戏
f_wuqin_bearBuff = sgs.CreateTriggerSkill{
	name = "f_wuqin_bearBuff",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local card = nil
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			card = use.card
		else
			card = data:toCardResponse().m_card
		end
		if card and (card:isKindOf("Jink") or card:isKindOf("Nullification")) then
			local log = sgs.LogMessage()
			log.type = "$f_wuqin_bearBuff"
			log.from = player
			room:sendLog(log)
			room:drawCards(player, 1, "f_wuqin")
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&f_wuqin_bear") > 0
	end,
}
  --猿戏
f_wuqin_apeBuff = sgs.CreateTargetModSkill{
	name = "f_wuqin_apeBuff",
	frequency = sgs.Skill_Frequent,
	pattern = "Snatch, SupplyShortage",
	distance_limit_func = function(self, from)
		if from:getMark("&f_wuqin_ape") > 0 then
			return 1000
		else
			return 0
		end
	end,
}
f_wuqin_apeBuff_message = sgs.CreateTriggerSkill{
	name = "f_wuqin_apeBuff_message",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card and (use.card:isKindOf("Snatch") or use.card:isKindOf("SupplyShortage")) then
			local log = sgs.LogMessage()
			log.type = "$f_wuqin_apeBuff"
			log.from = player
			log.card_str = use.card:toString()
			room:sendLog(log)
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&f_wuqin_ape") > 0
	end,
}
  --鸟戏
f_wuqin_birdBuff = sgs.CreateTriggerSkill{
    name = "f_wuqin_birdBuff",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.card:isVirtualCard() and damage.card:getSuit() == sgs.Card_NoSuit then return false end
		if math.random() > 0.5 then
			local log = sgs.LogMessage()
			log.type = "$f_wuqin_birdBuff"
			log.from = player
			room:sendLog(log)
			room:setEmotion(player, "jink")
		    return true
		end
	end,
	can_trigger = function(self, player)
	    return player:getMark("&f_wuqin_bird") > 0
	end,
}
-----
f_wuqin_MarkClear = sgs.CreateTriggerSkill{
    name = "f_wuqin_MarkClear",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then return false end
		if player:getMark("&f_wuqin_tiger") == 0 and player:getMark("&f_wuqin_deer") == 0 and player:getMark("&f_wuqin_bear") == 0
		and player:getMark("&f_wuqin_ape") == 0 and player:getMark("&f_wuqin_bird") == 0 then return false end
        for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:getMark("&f_wuqin_tiger") > 0 or p:getMark("&f_wuqin_deer") > 0 or p:getMark("&f_wuqin_bear") > 0
			or p:getMark("&f_wuqin_ape") > 0 or p:getMark("&f_wuqin_bird") > 0 then
				if p:getMark("&f_wuqin_tiger") > 0 then
			    	room:removePlayerMark(p, "&f_wuqin_tiger")
				end
				if p:getMark("&f_wuqin_deer") > 0 then
			    	room:removePlayerMark(p, "&f_wuqin_deer")
				end
				if p:getMark("&f_wuqin_bear") > 0 then
			    	room:removePlayerMark(p, "&f_wuqin_bear")
				end
				if p:getMark("&f_wuqin_ape") > 0 then
			    	room:removePlayerMark(p, "&f_wuqin_ape")
				end
				if p:getMark("&f_wuqin_bird") > 0 then
			    	room:removePlayerMark(p, "&f_wuqin_bird")
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return true
	end,
}
if not sgs.Sanguosha:getSkill("f_wuqin_tigerBuff") then skills:append(f_wuqin_tigerBuff) end
if not sgs.Sanguosha:getSkill("f_wuqin_deerBuff") then skills:append(f_wuqin_deerBuff) end
if not sgs.Sanguosha:getSkill("f_wuqin_bearBuff") then skills:append(f_wuqin_bearBuff) end
if not sgs.Sanguosha:getSkill("f_wuqin_apeBuff") then skills:append(f_wuqin_apeBuff) end
if not sgs.Sanguosha:getSkill("f_wuqin_apeBuff_message") then skills:append(f_wuqin_apeBuff_message) end
if not sgs.Sanguosha:getSkill("f_wuqin_birdBuff") then skills:append(f_wuqin_birdBuff) end
if not sgs.Sanguosha:getSkill("f_wuqin_MarkClear") then skills:append(f_wuqin_MarkClear) end


--

--SD1 005 神笔马良
f_sbmaliang = sgs.General(extension, "f_sbmaliang", "god", 3, true)

f_shenbi = sgs.CreateTriggerSkill{
	name = "f_shenbi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local move = data:toMoveOneTime()
		if event == sgs.CardsMoveOneTime and not room:getTag("FirstRound"):toBool() and move.to and move.to:objectName() == player:objectName() and player:hasSkill(self:objectName()) then
			if player:getPhase() ~= sgs.Player_NotActive and move.reason.m_skillName ~= "f_shenbi" then
				for _, id in sgs.qlist(move.card_ids) do
					if room:getCardOwner(id):objectName() == player:objectName() and room:getCardPlace(id) == sgs.Player_PlaceHand then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						player:drawCards(1, self:objectName())
						room:addPlayerMark(player, "f_shenbiBuff")
						break
					end
				end
			end
		elseif event == sgs.EventPhaseChanging and data:toPhaseChange().to == sgs.Player_NotActive then
		    for _, sb in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if sb:getMark("f_shenbiBuff") > 0 then
			    	local n = sb:getMark("f_shenbiBuff")
					room:removePlayerMark(sb, "f_shenbiBuff", n)
				end
			end
		end
	end,
}
f_shenbiX = sgs.CreateTargetModSkill{
    name = "f_shenbiX",
	pattern = "Card",
	distance_limit_func = function(self, from, card, to)
	    local n = 0
		if from:hasSkill("f_shenbi") and from:getMark("f_shenbiBuff") > 0 then
			local m = from:getMark("f_shenbiBuff")
			n = n + m
		end
		return n
	end,
}
f_shenbiY = sgs.CreateTargetModSkill{
	name = "f_shenbiY",
	pattern = "Card",
	residue_func = function(self, from, card, to)
		local n = 0
		if from:hasSkill("f_shenbi") and from:getMark("f_shenbiBuff") > 0 then
			local m = from:getMark("f_shenbiBuff")
			n = n + m
		end
		return n
	end,
}
f_sbmaliang:addSkill(f_shenbi)
if not sgs.Sanguosha:getSkill("f_shenbiX") then skills:append(f_shenbiX) end
if not sgs.Sanguosha:getSkill("f_shenbiY") then skills:append(f_shenbiY) end

--SD1 006 魔王-孙笑川
  --新势力：魔
--[[do
	require "lua.config"
	local config = config
	--local kingdoms = config.kingdoms
	table.insert(config.kingdoms, "devil")
	config.kingdom_colors["devil"] = "#CC33CC"
end]]

f_sunxiaochuan = sgs.General(extension, "f_sunxiaochuan$", "devil", 4, true)

f_baotu = sgs.CreateTriggerSkill{
	name = "f_baotu",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local from,to = damage.from,damage.to
		for _, th in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if from:objectName() ~= th:objectName() and to:objectName() ~= th:objectName() and th:inMyAttackRange(to)
			and th:getHandcardNum() >= to:getHandcardNum() and room:askForCard(th, '.|.|.|.', '#f_baotu', data, sgs.Card_MethodDiscard, to, false, self:objectName()) then
				room:broadcastSkillInvoke(self:objectName())
				local log = sgs.LogMessage()
				log.type = "$f_baotu"
				log.from = th
				log.to:append(player)
				room:sendLog(log)
				damage.from = th
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		end
	end,
	can_trigger = function(self, player)
	    return true
	end,
}
f_sunxiaochuan:addSkill(f_baotu)

f_ruya = sgs.CreateTriggerSkill{
	name = "f_ruya",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.to:isNude() then return false end
		if player:getHandcardNum() > damage.to:getHandcardNum() then return false end
		local _data = sgs.QVariant()
		_data:setValue(damage.to)
		if not player:askForSkillInvoke(self:objectName(), _data) then return false end
		local card = room:askForExchange(damage.to, self:objectName(), 999, 1, true, "#f_ruya:"..player:getGeneralName())
		if card then
			room:broadcastSkillInvoke(self:objectName())
			room:obtainCard(player, card, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), damage.to:objectName(), self:objectName(), ""), false)
		    if card:getSubcards():length() >= 2 then
				damage.damage = damage.damage - 1
				if damage.damage < 1 then
					return true
				end
				data:setValue(damage)
			end
		end
	end,
}
f_sunxiaochuan:addSkill(f_ruya)

f_tianhuang_dmc = sgs.CreateTriggerSkill{
	name = "f_tianhuang_dmc$",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, "f_tianhuang", data) then
			room:broadcastSkillInvoke("f_tianhuang", math.random(1,2))
			local c = 0
			for _, yb in sgs.qlist(room:getOtherPlayers(player)) do
			    if yb:getKingdom() == "qun" or yb:getKingdom() == "devil" then
				    c = c + 1
				end
			end
			count = data:toInt() + c
			data:setValue(count)
			room:addPlayerMark(player, "f_tianhuang_nmsl", c)
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_tianhuang") and player:isLord()
	end,
}
f_tianhuang_lmc = sgs.CreateMaxCardsSkill{
    name = "f_tianhuang_lmc$",
    extra_func = function(self, target)
	    if target:hasSkill("f_tianhuang") then
		    local ma = target:getMark("f_tianhuang_nmsl")
		    return -ma
		else
			return 0
		end
	end,
}
f_tianhuangClear = sgs.CreateTriggerSkill{
    name = "f_tianhuangClear",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then
            return false
        end
        for _, p in sgs.qlist(room:getAllPlayers()) do
			local m = p:getMark("f_tianhuang_nmsl")
			room:removePlayerMark(p, "f_tianhuang_nmsl", m)
		end
	end,
	can_trigger = function(self, player)
	    return player:getMark("f_tianhuang_nmsl") > 0
	end,
}
f_tianhuang = sgs.CreateTriggerSkill{
	name = "f_tianhuang$",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		--[[local sxcs = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:hasLordSkill(self:objectName()) then
				sxcs:append(p)
			end
		end
		local sxc = room:askForPlayerChosen(player, sxcs, self:objectName(), "@tianhuang-to", true)
		if sxc then
			damage.from = sxc
			data:setValue(damage)
		end
		return false]]
		for _, sxc in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if sxc:hasLordSkill(self:objectName()) and sxc:objectName() ~= player:objectName() then
				if room:askForSkillInvoke(player, "f_tianhuang-to", data) then
					room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
					local log = sgs.LogMessage()
					log.type = "$f_tianhuang"
					log.from = player
					log.to:append(sxc)
					room:sendLog(log)
					damage.from = sxc
					data:setValue(damage)
				end
			end
			break
		end
	end,
	can_trigger = function(self, player)
	    return player:getKingdom() == "qun" or player:getKingdom() == "devil"
	end,
}
f_sunxiaochuan:addSkill(f_tianhuang)
if not sgs.Sanguosha:getSkill("f_tianhuang_dmc") then skills:append(f_tianhuang_dmc) end
if not sgs.Sanguosha:getSkill("f_tianhuang_lmc") then skills:append(f_tianhuang_lmc) end
if not sgs.Sanguosha:getSkill("f_tianhuangClear") then skills:append(f_tianhuangClear) end

--SD1 007 管云鹏
f_guanyunpeng = sgs.General(extension, "f_guanyunpeng", "qun", 5, true)
f_guanyunpengg = sgs.General(extension, "f_guanyunpengg", "god", 4, true, true, true)

f_yinren = sgs.CreateTriggerSkill{
	name = "f_yinren",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged, sgs.CardsMoveOneTime, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if not player:isSkipped(change.to) and change.to == sgs.Player_Start and room:askForSkillInvoke(player, "f_yinren_skipplayerstart", data) then
				room:broadcastSkillInvoke(self:objectName(), 1)
				player:gainMark("&f_yinren", 3)
				room:addPlayerMark(player, "f_yinren_phaseskip")
				player:skip(change.to)
			end
			if not player:isSkipped(change.to) and change.to == sgs.Player_Judge and room:askForSkillInvoke(player, "f_yinren_skipplayerjudge", data) then
				room:broadcastSkillInvoke(self:objectName(), 1)
				player:gainMark("&f_yinren", 3)
				room:addPlayerMark(player, "f_yinren_phaseskip")
				player:skip(change.to)
			end
			if not player:isSkipped(change.to) and change.to == sgs.Player_Draw and room:askForSkillInvoke(player, "f_yinren_skipplayerdraw", data) then
				room:broadcastSkillInvoke(self:objectName(), 1)
				player:gainMark("&f_yinren", 3)
				room:addPlayerMark(player, "f_yinren_phaseskip")
				player:skip(change.to)
			end
			if not player:isSkipped(change.to) and change.to == sgs.Player_Play and room:askForSkillInvoke(player, "f_yinren_skipplayerplay", data) then
				room:broadcastSkillInvoke(self:objectName(), 1)
				player:gainMark("&f_yinren", 3)
				room:addPlayerMark(player, "f_yinren_phaseskip")
				player:skip(change.to)
			end
			if not player:isSkipped(change.to) and change.to == sgs.Player_Discard and room:askForSkillInvoke(player, "f_yinren_skipplayerdiscard", data) then
				room:broadcastSkillInvoke(self:objectName(), 1)
				player:gainMark("&f_yinren", 3)
				room:addPlayerMark(player, "f_yinren_phaseskip")
				player:skip(change.to)
			end
			if not player:isSkipped(change.to) and change.to == sgs.Player_Finish and room:askForSkillInvoke(player, "f_yinren_skipplayerfinish", data) then
				room:broadcastSkillInvoke(self:objectName(), 1)
				player:gainMark("&f_yinren", 3)
				room:addPlayerMark(player, "f_yinren_phaseskip")
				player:skip(change.to)
			end
		else
			if player:getPhase() ~= sgs.Player_NotActive then return false end
			if event == sgs.Damaged then
				local damage = data:toDamage()
				room:broadcastSkillInvoke(self:objectName(), 3)
				player:gainMark("&f_yinren", 1)
				room:notifySkillInvoked(player, self:objectName())
			else
				local move = data:toMoveOneTime()
				if (move.from and (move.from:objectName() == player:objectName()) and (move.from_places:contains(sgs.Player_PlaceHand) or  move.from_places:contains(sgs.Player_PlaceEquip)))
				and not (move.to and (move.to:objectName() == player:objectName() and (move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_PlaceEquip))) then
					room:broadcastSkillInvoke(self:objectName(), 2)
					player:gainMark("&f_yinren", 1)
					room:notifySkillInvoked(player, self:objectName())
				end
			end
		end
	end,
}
f_guanyunpeng:addSkill(f_yinren)

f_huigui = sgs.CreateTriggerSkill{
    name = "f_huigui",
	frequency = sgs.Skill_Wake,
	waked_skills = "f_longwang",
	events = {sgs.EventPhaseStart},
	can_wake = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_RoundStart or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getMark("&f_yinren") < 36 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		room:broadcastSkillInvoke(self:objectName())
		player:loseAllMarks("&f_yinren")
		if player:hasSkill("f_yinren") then
		    room:detachSkillFromPlayer(player, "f_yinren")
		end
		room:detachSkillFromPlayer(player, "f_longwang", true)
		room:changeHero(player, "f_guanyunpengg", true, false, player:getGeneral2Name() and player:getGeneral2Name() == "f_guanyunpeng", false) --同时获得“龙王”
		local log = sgs.LogMessage() --嗯造一个获得技能的信息
		log.type = "$f_huigui_getSkill"
		log.from = player
		room:sendLog(log)
		if player:hasJudgeArea() then
			player:throwJudgeArea()
		end
		room:setPlayerProperty(player, "kingdom", sgs.QVariant("god"))
		room:setPlayerProperty(player, "maxhp", sgs.QVariant(4))
		if player:isWounded() then
			local y = player:getHp()
			local recover = sgs.RecoverStruct()
			recover.who = player
			recover.recover = 4 - y
			room:recover(player, recover)
		end
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
f_guanyunpeng:addSkill(f_huigui)
f_guanyunpeng:addRelateSkill("f_longwang")
--“龙王”
f_longwang = sgs.CreateTriggerSkill{
    name = "f_longwang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart, sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Play then
			local longwang_cards = {}
			local longwang_one_basic_count = 0
			for _, id in sgs.qlist(room:getDrawPile()) do
				if sgs.Sanguosha:getCard(id):isKindOf("BasicCard") and not table.contains(longwang_cards, id) and longwang_one_basic_count < 1 then
					longwang_one_basic_count = longwang_one_basic_count + 1
					table.insert(longwang_cards, id)
				end
			end
			local longwang_one_trick_count = 0
			for _, id in sgs.qlist(room:getDrawPile()) do
				if sgs.Sanguosha:getCard(id):isKindOf("TrickCard") and not table.contains(longwang_cards, id) and longwang_one_trick_count < 1 then
					longwang_one_trick_count = longwang_one_trick_count + 1
					table.insert(longwang_cards, id)
				end
			end
			local longwang_one_equip_count = 0
			for _, id in sgs.qlist(room:getDrawPile()) do
				if sgs.Sanguosha:getCard(id):isKindOf("EquipCard") and not table.contains(longwang_cards, id) and longwang_one_equip_count < 1 then
					longwang_one_equip_count = longwang_one_equip_count + 1
					table.insert(longwang_cards, id)
				end
			end
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, id in ipairs(longwang_cards) do
				dummy:addSubcard(id)
			end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName(), 1)
			room:obtainCard(player, dummy, false)
		elseif event == sgs.ConfirmDamage then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName(), 2)
			local damage = data:toDamage()
			local waizui = damage.damage
			damage.damage = waizui + 1
			data:setValue(damage)
		end
	end,
}
f_guanyunpengg:addSkill(f_longwang)





--

--SD1 008 广西鹿哥
f_guangxiluge = sgs.General(extension, "f_guangxiluge", "qun", 3, true)

f_xitiCard = sgs.CreateSkillCard{
    name = "f_xitiCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    local choices = {}
		for i = 0, 4 do
			if source:hasEquipArea(i) then
				table.insert(choices, i)
			end
		end
		if choices == "" then return false end
		local choice = room:askForChoice(source, "f_xiti", table.concat(choices, "+"))
		local area = tonumber(choice), 0
		source:throwEquipArea(area)
		--“喜提”开始
		local ids1 = room:getNCards(1, false)
		local move1 = sgs.CardsMoveStruct()
		move1.card_ids = ids1
		move1.to = source
		move1.to_place = sgs.Player_PlaceTable
		move1.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move1, true)
		local id1 = ids1:first()
		local card1 = sgs.Sanguosha:getCard(id1)
		local a = card1:getNumber()
        if a >= 17 then --虽然说点数最大的也就是13，但说不定有能改点数大小的技能
			source:obtainCard(card1)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card1)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids2 = room:getNCards(1, false)
		local move2 = sgs.CardsMoveStruct()
		move2.card_ids = ids2
		move2.to = source
		move2.to_place = sgs.Player_PlaceTable
		move2.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move2, true)
		local id2 = ids2:first()
		local card2 = sgs.Sanguosha:getCard(id2)
		local b = a + card2:getNumber()
        if b >= 17 then
			source:obtainCard(card2)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card2)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids3 = room:getNCards(1, false)
		local move3 = sgs.CardsMoveStruct()
		move3.card_ids = ids3
		move3.to = source
		move3.to_place = sgs.Player_PlaceTable
		move3.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move3, true)
		local id3 = ids3:first()
		local card3 = sgs.Sanguosha:getCard(id3)
		local c = b + card3:getNumber()
        if c >= 17 then
			source:obtainCard(card3)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card3)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids4 = room:getNCards(1, false)
		local move4 = sgs.CardsMoveStruct()
		move4.card_ids = ids4
		move4.to = source
		move4.to_place = sgs.Player_PlaceTable
		move4.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move4, true)
		local id4 = ids4:first()
		local card4 = sgs.Sanguosha:getCard(id4)
		local d = c + card4:getNumber()
        if d >= 17 then
			source:obtainCard(card4)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card4)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids5 = room:getNCards(1, false)
		local move5 = sgs.CardsMoveStruct()
		move5.card_ids = ids5
		move5.to = source
		move5.to_place = sgs.Player_PlaceTable
		move5.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move5, true)
		local id5 = ids5:first()
		local card5 = sgs.Sanguosha:getCard(id5)
		local e = d + card5:getNumber()
        if e >= 17 then
			source:obtainCard(card5)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card5)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids6 = room:getNCards(1, false)
		local move6 = sgs.CardsMoveStruct()
		move6.card_ids = ids6
		move6.to = source
		move6.to_place = sgs.Player_PlaceTable
		move6.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move6, true)
		local id6 = ids6:first()
		local card6 = sgs.Sanguosha:getCard(id6)
		local f = e + card6:getNumber()
        if f >= 17 then
			source:obtainCard(card6)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card6)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids7 = room:getNCards(1, false)
		local move7 = sgs.CardsMoveStruct()
		move7.card_ids = ids7
		move7.to = source
		move7.to_place = sgs.Player_PlaceTable
		move7.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move7, true)
		local id7 = ids7:first()
		local card7 = sgs.Sanguosha:getCard(id7)
		local g = f + card7:getNumber()
        if g >= 17 then
			source:obtainCard(card7)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card7)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids8 = room:getNCards(1, false)
		local move8 = sgs.CardsMoveStruct()
		move8.card_ids = ids8
		move8.to = source
		move8.to_place = sgs.Player_PlaceTable
		move8.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move8, true)
		local id8 = ids8:first()
		local card8 = sgs.Sanguosha:getCard(id8)
		local h = g + card8:getNumber()
        if h >= 17 then
			source:obtainCard(card8)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card8)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids9 = room:getNCards(1, false)
		local move9 = sgs.CardsMoveStruct()
		move9.card_ids = ids9
		move9.to = source
		move9.to_place = sgs.Player_PlaceTable
		move9.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move9, true)
		local id9 = ids9:first()
		local card9 = sgs.Sanguosha:getCard(id9)
		local i = h + card9:getNumber()
        if i >= 17 then
			source:obtainCard(card9)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card9)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids10 = room:getNCards(1, false)
		local move10 = sgs.CardsMoveStruct()
		move10.card_ids = ids10
		move10.to = source
		move10.to_place = sgs.Player_PlaceTable
		move10.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move10, true)
		local id10 = ids10:first()
		local card10 = sgs.Sanguosha:getCard(id10)
		local j = i + card10:getNumber()
        if j >= 17 then
			source:obtainCard(card10)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card10)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids11 = room:getNCards(1, false)
		local move11 = sgs.CardsMoveStruct()
		move11.card_ids = ids11
		move11.to = source
		move11.to_place = sgs.Player_PlaceTable
		move11.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move11, true)
		local id11 = ids11:first()
		local card11 = sgs.Sanguosha:getCard(id11)
		local k = j + card11:getNumber()
        if k >= 17 then
			source:obtainCard(card11)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card11)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids12 = room:getNCards(1, false)
		local move12 = sgs.CardsMoveStruct()
		move12.card_ids = ids12
		move12.to = source
		move12.to_place = sgs.Player_PlaceTable
		move12.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move12, true)
		local id12 = ids12:first()
		local card12 = sgs.Sanguosha:getCard(id12)
		local l = k + card12:getNumber()
        if l >= 17 then
			source:obtainCard(card12)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card12)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids13 = room:getNCards(1, false)
		local move13 = sgs.CardsMoveStruct()
		move13.card_ids = ids13
		move13.to = source
		move13.to_place = sgs.Player_PlaceTable
		move13.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move13, true)
		local id13 = ids13:first()
		local card13 = sgs.Sanguosha:getCard(id13)
		local m = l + card13:getNumber()
        if m >= 17 then
			source:obtainCard(card13)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card13)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids14 = room:getNCards(1, false)
		local move14 = sgs.CardsMoveStruct()
		move14.card_ids = ids14
		move14.to = source
		move14.to_place = sgs.Player_PlaceTable
		move14.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move14, true)
		local id14 = ids14:first()
		local card14 = sgs.Sanguosha:getCard(id14)
		local n = m + card14:getNumber()
        if n >= 17 then
			source:obtainCard(card14)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card14)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids15 = room:getNCards(1, false)
		local move15 = sgs.CardsMoveStruct()
		move15.card_ids = ids15
		move15.to = source
		move15.to_place = sgs.Player_PlaceTable
		move15.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move15, true)
		local id15 = ids15:first()
		local card15 = sgs.Sanguosha:getCard(id15)
		local o = n + card15:getNumber()
        if o >= 17 then
			source:obtainCard(card15)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card15)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids16 = room:getNCards(1, false)
		local move16 = sgs.CardsMoveStruct()
		move16.card_ids = ids16
		move16.to = source
		move16.to_place = sgs.Player_PlaceTable
		move16.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move16, true)
		local id16 = ids16:first()
		local card16 = sgs.Sanguosha:getCard(id16)
		local p = o + card16:getNumber()
        if p >= 17 then
			source:obtainCard(card16)
			room:addPlayerMark(source, "&f_xiti")
			return false
        else
			source:obtainCard(card16)
			room:addPlayerMark(source, "&f_xiti")
		end
		room:getThread():delay(1000)
		local ids17 = room:getNCards(1, false)
		local move17 = sgs.CardsMoveStruct()
		move17.card_ids = ids17
		move17.to = source
		move17.to_place = sgs.Player_PlaceTable
		move17.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "f_xiti", nil)
		room:moveCardsAtomic(move17, true)
		local id17 = ids17:first()
		local card17 = sgs.Sanguosha:getCard(id17)
		--local q = p + card17:getNumber() --最极端情况：翻开全是A
        --if q >= 17 then
			source:obtainCard(card17)
			room:addPlayerMark(source, "&f_xiti")
			return false
        --[[else
			source:obtainCard(card17)
			room:addPlayerMark(source, "&f_xiti")
		end]]
	--return false
	end,
}
f_xiti = sgs.CreateZeroCardViewAsSkill{
    name = "f_xiti",
	view_as = function()
		return f_xitiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_xitiCard") and player:hasEquipArea()
	end,
}
f_xiti_followup = sgs.CreateTriggerSkill{
	name = "f_xiti_followup",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card then
				room:broadcastSkillInvoke("f_xiti")
				room:removePlayerMark(player, "&f_xiti")
				room:drawCards(player, 1, "f_xiti")
			end
		else
			if player:getPhase() == sgs.Player_Play then
				local r = player:getMark("&f_xiti")
				room:removePlayerMark(player, "&f_xiti", r)
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_xiti") and player:getMark("&f_xiti") > 0
	end,
}
f_guangxiluge:addSkill(f_xiti)
if not sgs.Sanguosha:getSkill("f_xiti_followup") then skills:append(f_xiti_followup) end

f_enzaoCard = sgs.CreateSkillCard{
	name = "f_enzao",
	will_throw = false,
	filter = function(self, targets, to_select)
		local plist = sgs.PlayerList()
		for i = 1, #targets do plist:append(targets[i]) end
		local rangefix = 0
		if not self:getSubcards():isEmpty() and sgs.Self:getWeapon() and sgs.Self:getWeapon():getId() == self:getSubcards():first() then
			local card = sgs.Self:getWeapon():getRealCard():toWeapon()
			rangefix = rangefix + card:getRange() - sgs.Self:getAttackRange(false)
		end
		if not self:getSubcards():isEmpty() and sgs.Self:getOffensiveHorse() and sgs.Self:getOffensiveHorse():getId() == self:getSubcards():first() then
			rangefix = rangefix + 1
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card, user_str = nil, self:getUserString()
			if user_str ~= "" then
				local us = user_str:split("+")
				card = sgs.Sanguosha:cloneCard(us[1])
			end
			return card and card:targetFilter(plist, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, plist)
			and ((card:isKindOf("Slash") and sgs.Self:canSlash(to_select, true, rangefix)))
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return false
		end
		local card = sgs.Self:getTag("f_enzao"):toCard()
		return card and card:targetFilter(plist, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, plist)
		and ((card:isKindOf("Slash") and sgs.Self:canSlash(to_select, true, rangefix)))
	end,
	target_fixed = function(self)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card, user_str = nil, self:getUserString()
			if user_str ~= "" then
				local us = user_str:split("+")
				card = sgs.Sanguosha:cloneCard(us[1])
			end
			return card and card:targetFixed()
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return true
		end
		local card = sgs.Self:getTag("f_enzao"):toCard()
		return card and card:targetFixed()
	end,
	feasible = function(self, targets)
		local plist = sgs.PlayerList()
		for i = 1, #targets do plist:append(targets[i]) end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card, user_str = nil, self:getUserString()
			if user_str ~= "" then
				local us = user_str:split("+")
				card = sgs.Sanguosha:cloneCard(us[1])
			end
			return card and card:targetsFeasible(plist, sgs.Self)
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return true
		end
		local card = sgs.Self:getTag("f_enzao"):toCard()
		return card and card:targetsFeasible(plist, sgs.Self)
	end,
	on_validate = function(self, card_use)
		local player = card_use.from
		local room, to_f_enzao = player:getRoom(), self:getUserString()
		if self:getUserString() == "slash" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local f_enzao_list = {}
			table.insert(f_enzao_list, "slash")
			local sts = sgs.GetConfig("BanPackages", "")
			if not string.find(sts, "maneuvering") then
				table.insert(f_enzao_list, "normal_slash")
				table.insert(f_enzao_list, "fire_slash")
				table.insert(f_enzao_list, "thunder_slash")
				table.insert(f_enzao_list, "ice_slash")
			end
			to_f_enzao = room:askForChoice(player, "f_enzao_slash", table.concat(f_enzao_list, "+"))
		end
		local card = nil
		if self:subcardsLength() == 1 then card = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(self:getSubcards():first())) end
		local user_str
		if to_f_enzao == "slash" then
			if card and card:isKindOf("Slash") then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		elseif to_f_enzao == "normal_slash" then
			user_str = "slash"
		else
			user_str = to_f_enzao
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str, card and card:getSuit() or sgs.Card_SuitToBeDecided, card and card:getNumber() or -1)
		use_card:setSkillName("_f_enzao")
		use_card:addSubcards(self:getSubcards())
		use_card:deleteLater()
		return use_card
	end,
	on_validate_in_response = function(self, user)
		local room, user_str = user:getRoom(), self:getUserString()
		local to_f_enzao
		if user_str == "peach+analeptic" then
			local f_enzao_list = {}
			table.insert(f_enzao_list, "peach")
			local sts = sgs.GetConfig("BanPackages", "")
			if not string.find(sts, "maneuvering") then
				table.insert(f_enzao_list, "analeptic")
			end
			to_f_enzao = room:askForChoice(user, "f_enzao_saveself", table.concat(f_enzao_list, "+"))
		elseif user_str == "slash" then
			local f_enzao_list = {}
			table.insert(f_enzao_list, "slash")
			local sts = sgs.GetConfig("BanPackages", "")
			if not string.find(sts, "maneuvering") then
				table.insert(f_enzao_list, "normal_slash")
				table.insert(f_enzao_list, "fire_slash")
				table.insert(f_enzao_list, "thunder_slash")
				table.insert(f_enzao_list, "ice_slash")
			end
			to_f_enzao = room:askForChoice(user, "f_enzao_slash", table.concat(f_enzao_list, "+"))
		else
			to_f_enzao = user_str
		end
		local card = nil
		if self:subcardsLength() == 1 then card = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(self:getSubcards():first())) end
		local user_str
		if to_f_enzao == "slash" then
			if card and card:isKindOf("Slash") then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		elseif to_f_enzao == "normal_slash" then
			user_str = "slash"
		else
			user_str = to_f_enzao
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str, card and card:getSuit() or sgs.Card_SuitToBeDecided, card and card:getNumber() or -1)
		use_card:setSkillName("_f_enzao")
		use_card:addSubcards(self:getSubcards())
		use_card:deleteLater()
		return use_card
	end,
}
f_enzao = sgs.CreateViewAsSkill{
	name = "f_enzao",
	n = 1,
	response_or_use = true,
	view_filter = function(self, selected, to_select)
		return not to_select:isKindOf("BasicCard")
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local skillcard = f_enzaoCard:clone()
		skillcard:setSkillName(self:objectName())
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE
		or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			skillcard:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			for _, card in ipairs(cards) do
				skillcard:addSubcard(card)
			end
			return skillcard
		end
		local c = sgs.Self:getTag("f_enzao"):toCard()
		if c then
			skillcard:setUserString(c:objectName())
			for _, card in ipairs(cards) do
				skillcard:addSubcard(card)
			end
			return skillcard
		else
			return nil
		end
	end,
	enabled_at_play = function(self, player)
		if player:getMark("&f_enzaoKey") == 0 then return false end
		local basic = {"slash", "peach"}
		local sts = sgs.GetConfig("BanPackages", "")
		if not string.find(sts, "maneuvering") then
			table.insert(basic, "fire_slash")
			table.insert(basic, "thunder_slash")
			table.insert(basic, "ice_slash")
			table.insert(basic, "analeptic")
		end
		for _, patt in ipairs(basic) do
			local poi = sgs.Sanguosha:cloneCard(patt, sgs.Card_NoSuit, -1)
			if poi and poi:isAvailable(player) and not (patt == "peach" and not player:isWounded()) then
				return true
			end
		end
		return false
	end,
	enabled_at_response = function(self, player, pattern)
        if player:getMark("&f_enzaoKey") == 0 then return false end
		if string.startsWith(pattern, ".") or string.startsWith(pattern, "@") then return false end
        if pattern == "peach" and player:getMark("Global_PreventPeach") > 0 then return false end
        return pattern ~= "nullification"
	end,
}
f_enzaoBuffget = sgs.CreateTriggerSkill{
    name = "f_enzaoBuffget",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardFinished},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:getSkillName() == "f_enzao" then
			if player:getMark("f_enzaoInfinity") == 0 then
				room:addPlayerMark(player, "f_enzaoInfinity")
			end
		else
			if player:getMark("f_enzaoInfinity") > 0 then
				room:removePlayerMark(player, "f_enzaoInfinity")
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_enzao") and player:getMark("&f_enzaoKey") > 0
	end,
}
f_enzaoBuff_d = sgs.CreateTargetModSkill{
	name = "f_enzaoBuff_d",
	pattern = "Card",
	distance_limit_func = function(self, from, card)
		if from:hasSkill("f_enzao") and from:getMark("f_enzaoInfinity") > 0 then
			return 1000
		else
			return 0
		end
	end,
}
f_enzaoBuff_r = sgs.CreateTargetModSkill{
	name = "f_enzaoBuff_r",
	pattern = "Card",
	residue_func = function(self, from, card)
		if from:hasSkill("f_enzao") and from:getMark("f_enzaoInfinity") > 0 then
			return 1000
		else
			return 0
		end
	end,
}
--“嗯造”激活
f_enzaoACT = sgs.CreateTriggerSkill{
    name = "f_enzaoACT",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ThrowEquipArea, sgs.EventPhaseStart, sgs.EventPhaseEnd}, --后两个时机仅为检查用，无法立即生效
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local log = sgs.LogMessage()
		log.type = "#f_enzaoACT"
		log.arg = "f_enzao"
		log.from = player
		room:sendLog(log)
		room:broadcastSkillInvoke("f_enzao")
		room:addPlayerMark(player, "&f_enzaoKey")
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_enzao") and player:getMark("&f_enzaoKey") == 0 and not player:hasEquipArea()
	end,
}
f_enzao:setGuhuoDialog("l")
f_guangxiluge:addSkill(f_enzao)
if not sgs.Sanguosha:getSkill("f_enzaoBuffget") then skills:append(f_enzaoBuffget) end
if not sgs.Sanguosha:getSkill("f_enzaoBuff_d") then skills:append(f_enzaoBuff_d) end
if not sgs.Sanguosha:getSkill("f_enzaoBuff_r") then skills:append(f_enzaoBuff_r) end
if not sgs.Sanguosha:getSkill("f_enzaoACT") then skills:append(f_enzaoACT) end



--

sgs.LoadTranslationTable{
    ["sd"] = "沙雕包",
	
	--大宝&大鬼&大妖
	["DABAO_DAGUI_DAYAO"] = "大宝&大鬼&大妖",
	["&DABAO_DAGUI_DAYAO"] = "大宝大鬼大妖",
	["#DABAO_DAGUI_DAYAO"] = "阴间三兄弟",
	["designer:DABAO_DAGUI_DAYAO"] = "时光流逝FC",
	["cv:DABAO_DAGUI_DAYAO"] = "官方,eяxaт музыкa",
	["illustrator:DABAO_DAGUI_DAYAO"] = "戏子多殇`",
	  --这里是阴间
	["thisisyinjian"] = "这里是阴间",
	[":thisisyinjian"] = "<b>说明技，</b>你拥有技能“手杀界破军”、“劫营”、“佐幸(测试版)”。",
	["$thisisyinjian"] = "（BGM:EA7-BASS）",
	    --佐幸（测试版）
	  ["dy_zuoxing"] = "佐幸",
	  [":dy_zuoxing"] = "出牌阶段限一次，若你的体力上限大于1，你可以减1点体力上限，视为使用一张普通锦囊牌。",
	  ["$dy_zuoxing1"] = "以聪虑难，悉咨于上。",
	  ["$dy_zuoxing2"] = "奉孝不才，愿献勤心。",
	  ["$dy_zuoxing3"] = "既为奇佐，岂可徒有虚名？",
	  --阵亡
	["~DABAO_DAGUI_DAYAO"] = "开玩笑，阴间武将会阵亡？",
	
	--五虎上将
	["f_wuhushangjiang"] = "五虎上将",
	["#f_wuhushangjiang"] = "冠绝天下",
	["designer:f_wuhushangjiang"] = "时光流逝FC",
	["cv:f_wuhushangjiang"] = "官方",
	["illustrator:f_wuhushangjiang"] = "官方,网络,三国志11",
	  --虎将
	["f_hujiang"] = "虎将",
	[":f_hujiang"] = "<b>说明技，</b>你拥有技能“界武圣”、“OL界咆哮”、“OL界龙胆”、“界烈弓”、“铁骑”。",
	  --将魂
	["f_jianghun"] = "将魂",
	[":f_jianghun"] = "出牌阶段限一次，你可以减1点体力上限，摸X张牌（X为你于本局发动此技能的次数）。",
	["$f_jianghun"] = "（虎啸声）",
	  --阵亡
	["~f_wuhushangjiang"] = "丞相...兴复汉室的重任，就..拜托你了.....", --暂无语音
	
	--神黄盖
	["f_shenhuanggai"] = "神黄盖",
	["#f_shenhuanggai"] = "破天焚舰",
	["designer:f_shenhuanggai"] = "时光流逝FC",
	["cv:f_shenhuanggai"] = "官方",
	["illustrator:f_shenhuanggai"] = "嗑瞌一休",
	  --苦诈
	["f_kuzha"] = "苦诈",
	["f_kuzha_finish"] = "苦诈",
	[":f_kuzha"] = "出牌阶段限一次，你可以减1点体力上限并获得“苦肉-旧版”直到回合结束。",
	["$f_kuzha1"] = "披甲转战南北！",
	["$f_kuzha2"] = "攻城略地，尚不惧生死，又何惧鞭挞！",
	  --身先
	["f_shenxianshizu"] = "身先",
	["f_shenxianshizuA"] = "身先",
	["f_shenxianshizuB"] = "身先",
	["f_shenxianshizu_fire"] = "身先",
	[":f_shenxianshizu"] = "限定技，出牌阶段，你将所有手牌交给一名其他角色。若如此做，直到回合结束，你对其使用【杀】无距离和次数限制，你对其造成的火焰伤害+1。",
	["@f_shenxianshizu"] = "身先",
	["huoshaochibi"] = "火烧赤壁！",
	["$f_shenxianshizu1"] = "诈降之术，因势利导！",
	["$f_shenxianshizu2"] = "东风已起，点火，冲啊！",
	  --阵亡
	["~f_shenhuanggai"] = "赤壁今已寒，犹忆当年火......",
	
	--神华佗
	["f_shenhuatuo"] = "神华佗",
	["#f_shenhuatuo"] = "悬壶济世",
	["designer:f_shenhuatuo"] = "时光流逝FC",
	["cv:f_shenhuatuo"] = "官方,音频怪物,Aki阿杰",
	["illustrator:f_shenhuatuo"] = "凝聚永恒",
	  --疗毒
	["f_liaodu"] = "疗毒",
	[":f_liaodu"] = "出牌阶段限一次，你可以弃置一张装备牌并选择一名角色，则其回复1点体力、摸一张牌、复原武将牌并清空判定区。",
	["$f_liaodu1"] = "血脉流通，则诸病不生。",
	["$f_liaodu2"] = "正本清源，则药到病除。",
	  --麻沸
	["f_mafei"] = "麻沸",
	["f_mafeiBuff"] = "麻沸",
	[":f_mafei"] = "出牌阶段限一次，你可以弃置一张锦囊牌，令一名角色翻面。锁定技，以此法翻为背面的角色：受到伤害时，弃置一张牌令此伤害-1；回复体力时，回复量+1。该角色拥有上述效果直到其翻为正面为止。",
	["f_mafeisan"] = "麻沸散",
	["$f_mafeiBuff_jianshang"] = "因为 <font color='yellow'><b>麻沸散</b></font> 的效果，%from 受到的伤害-1",
	["$f_mafeiBuff_recover"] = "因为 <font color='yellow'><b>麻沸散</b></font> 的效果，%from 的回复量+1",
	["$f_mafei1"] = "祛病除魔，妙手回春。",
	["$f_mafei2"] = "悬壶济世，普度众生。",
	  --五禽
	["f_wuqin"] = "五禽",
	["f_wuqin_tigerBuff"] = "[五禽戏]虎戏",
	["f_wuqin_deerBuff"] = "[五禽戏]鹿戏",
	["f_wuqin_bearBuff"] = "[五禽戏]熊戏",
	["f_wuqin_apeBuff"] = "[五禽戏]猿戏",
	["f_wuqin_apeBuff_message"] = "[五禽戏]猿戏",
	["f_wuqin_bird"] = "[五禽戏]鸟戏",
	["f_wuqin_MarkClear"] = "五禽",
	[":f_wuqin"] = "出牌阶段限一次，你可以弃置一张基本牌并选择一名角色，表演“<font color='green'><b>五禽戏</b></font>”。根据你成功表演的功法数，其获得对应效果直到其回合结束：\
	<font color='orange'><b>[虎戏]</b></font>【杀】或【决斗】的伤害+1；\
	<font color='yellow'><b>[鹿戏]</b></font>【桃】或【酒】的回复量+1；\
	<font color='brown'><b>[熊戏]</b></font>每使用或打出一张【闪】或【无懈可击】，摸一张牌；\
	<font color='grey'><b>[猿戏]</b></font>使用【顺手牵羊】或【兵粮寸断】无距离限制；\
	<font color='blue'><b>[鸟戏]</b></font>受到实体卡牌的伤害时，有一定概率闪避(防止伤害)。",
	["$f_wuqin_start"] = "五禽戏",
	["f_wuqin_tiger"] = "虎戏",
	["f_wuqin_deer"] = "鹿戏",
	["f_wuqin_bear"] = "熊戏",
	["f_wuqin_ape"] = "猿戏",
	["f_wuqin_bird"] = "鸟戏",
	["$f_wuqin_tiger_success"] = "%from 表演“<font color='green'><b>五禽戏</b></font>”之“<font color='orange'><b>虎戏</b></font>” <font color='red'><b>成功</b></font>！",
	["$f_wuqin_deer_success"] = "%from 表演“<font color='green'><b>五禽戏</b></font>”之“<font color='yellow'><b>鹿戏</b></font>” <font color='red'><b>成功</b></font>！",
	["$f_wuqin_bear_success"] = "%from 表演“<font color='green'><b>五禽戏</b></font>”之“<font color='brown'><b>熊戏</b></font>” <font color='red'><b>成功</b></font>！",
	["$f_wuqin_ape_success"] = "%from 表演“<font color='green'><b>五禽戏</b></font>”之“<font color='grey'><b>猿戏</b></font>” <font color='red'><b>成功</b></font>！",
	["$f_wuqin_bird_success"] = "%from 表演“<font color='green'><b>五禽戏</b></font>”之“<font color='blue'><b>鸟戏</b></font>” <font color='red'><b>成功</b></font>！",
	["$f_wuqin_finish"] = "%from 的“<font color='green'><b>五禽戏</b></font>” <font color='red'><b>表演结束</b></font>",
	["$f_wuqin_tigerBuff"] = "因为“<font color='orange'><b>虎戏</b></font>”的加成效果，此 %card 造成的伤害+1",
	["$f_wuqin_deerBuff"] = "因为“<font color='yellow'><b>鹿戏</b></font>”的加成效果，此 %card 回复量+1",
	["$f_wuqin_bearBuff"] = "因为“<font color='brown'><b>熊戏</b></font>”的加成效果，%from 摸一张牌",
	["$f_wuqin_apeBuff"] = "因为“<font color='grey'><b>猿戏</b></font>”的加成效果，此 %card 无距离限制",
	["$f_wuqin_birdBuff"] = "因为“<font color='blue'><b>鸟戏</b></font>”的加成效果，%from 回避此伤害",
	["$f_wuqin1"] = "（音乐：五禽戏<男声>“一起来五禽戏！......”）",
	["$f_wuqin2"] = "（音乐：五禽戏<女声>“一支华佗五禽曲，虎鹿熊猿鸟戏；一段中医养生道理，逍遥人欢喜”）",
	  --阵亡
	["~f_shenhuatuo"] = "人心不古，药石难治......",
	
	--神笔马良
	["f_sbmaliang"] = "神笔马良",
	["#f_sbmaliang"] = "马良就是神！",
	["designer:f_sbmaliang"] = "时光流逝FC",
	["cv:f_sbmaliang"] = "官方",
	["illustrator:f_sbmaliang"] = "官方",
	  --神笔
	["f_shenbi"] = "神笔",
	["f_shenbiX"] = "神笔",
	["f_shenbiY"] = "神笔",
	[":f_shenbi"] = "锁定技，你的回合内：当你不因此技能效果获得牌时，摸一张牌；你使用牌的距离和次数+X（X为你于此回合内因此技能效果摸牌的次数）。",
	["f_shenbiBuff"] = "",
	["$f_shenbi1"] = "慢着，让我来。",
	["$f_shenbi2"] = "两国修好，不动干戈。",
	["$f_shenbi3"] = "敌不犯我，我不犯人。",
	  --阵亡
	["~f_sbmaliang"] = "兄弟们，我……",
	
	--魔王-孙笑川
	["devil"] = "魔",
	["f_sunxiaochuan"] = "魔王-孙笑川",
	["&f_sunxiaochuan"] = "孙笑川",
	["#f_sunxiaochuan"] = "儒雅随和",
	["designer:f_sunxiaochuan"] = "诺多战士",
	["cv:f_sunxiaochuan"] = "孙笑川,Slippy,Shahmen",
	["illustrator:f_sunxiaochuan"] = "孙笑川",
	  --暴徒（强化）
	["f_baotu"] = "暴徒",
	[":f_baotu"] = "当其他角色对你攻击范围内的角色造成伤害时，若你的手牌数不小于受到伤害的角色，你可以弃置一张牌并成为伤害来源，且令此伤害+1。",
	["#f_baotu"] = "暴徒：你可以弃一张牌并成为本次伤害的伤害来源",
	["$f_baotu"] = "%from 发动了“<font color='yellow'><b>暴徒</b></font>”，将 <font color='yellow'><b>伤害来源</b></font> 从 %to 改成 %from",
	["$f_baotu1"] = "你吼辣么大声干森么嘛？",
	["$f_baotu2"] = "那你去物管啊！",
	["$f_baotu3"] = "你踏马的你在这抒情是吧",
	["$f_baotu4"] = "你是有病是吧？",
	["$f_baotu5"] = "你是不是聋鸣？",
	  --儒雅（强化）
	["f_ruya"] = "儒雅",
	[":f_ruya"] = "当你对其他角色造成伤害时，若你的手牌数不大于其，你可以令其交给你至少一张牌，若其交给你两张或更多的牌，你令此伤害-1。",
	["#f_ruya"] = "儒雅：请交给 %src 至少一张牌",
	["$f_ruya1"] = "我这个人是非常儒雅随和的一个人",
	["$f_ruya2"] = "关我锤子事",
	["$f_ruya3"] = "你能不能稳重一点",
	["$f_ruya4"] = "劳资真的觉得烦",
	["$f_ruya5"] = "我是你爹！",
	  --天皇（改动并强化）
	["f_tianhuang"] = "天皇",
	["f_tianhuang_dmc"] = "天皇",
	["f_tianhuang_lmc"] = "天皇",
	["f_tianhuangClear"] = "天皇",
	[":f_tianhuang"] = "主公技，你于摸牌阶段可多摸X张牌，若如此做，本回合你的手牌上限-X；其他“群”或“魔”势力角色造成伤害时，其可令伤害来源视为你。（X为场上其他“群”或“魔”势力角色数）",
	["f_tianhuang_nmsl"] = "你再骂？",
	--["@tianhuang-to"] = "天皇：你可以选择将伤害来源改为孙笑川",
	["f_tianhuang-to"] = "[天皇]你可以选择将伤害来源改为孙笑川",
	["$f_tianhuang"] = "因为 %from 发动了“<font color='yellow'><b>天皇</b></font>”的效果，<font color='yellow'><b>伤害来源</b></font> 从 %from 改成 %to",
	["$f_tianhuang1"] = "（家乡の小曲）",
	["$f_tianhuang2"] = "（阴 间 哀 乐）",
	  --阵亡
	["~f_sunxiaochuan"] = "不爱，别伤害",
	
	--管云鹏
	["f_guanyunpeng"] = "管云鹏",
	["#f_guanyunpeng"] = "歪嘴战神",
	["designer:f_guanyunpeng"] = "时光流逝FC",
	["cv:f_guanyunpeng"] = "?,管云鹏,Varien",
	["illustrator:f_guanyunpeng"] = "管云鹏",
	  --隐忍
	["f_yinren"] = "隐忍",
	[":f_yinren"] = "回合外，每当你受到伤害或失去牌时，你获得1枚“隐忍”标记；回合内的任意阶段开始前，你可以跳过之并获得3枚“隐忍”标记。",
	["f_yinren_skipplayerstart"] = "隐忍(跳过准备阶段)",
	["f_yinren_skipplayerjudge"] = "隐忍(跳过判定阶段)",
	["f_yinren_skipplayerdraw"] = "隐忍(跳过摸牌阶段)",
	["f_yinren_skipplayerplay"] = "隐忍(跳过出牌阶段)",
	["f_yinren_skipplayerdiscard"] = "隐忍(跳过弃牌阶段)",
	["f_yinren_skipplayerfinish"] = "隐忍(跳过结束阶段)",
	["f_yinren_phaseskip"] = "",
	["$f_yinren1"] = "修罗，隐忍！", --跳过阶段
	["$f_yinren2"] = "你再这样扎下去，老太君活不过半时辰！", --失去牌
	["$f_yinren3"] = "别后悔！", --受到伤害
	  --回归
	["f_huigui"] = "回归",
	[":f_huigui"] = "觉醒技，回合开始时，若你的“隐忍”标记达到36枚或更多，你移除所有“隐忍”标记并失去技能“隐忍”，更换全新的武将头像(将体力上限和体力值重置为4)，获得技能“龙王”并将势力变更为“神”。",
	["$f_huigui_getSkill"] = "%from 获得了技能“<font color='yellow'><b>龙王</b></font>”",
	["$f_huigui"] = "（三年之期已到，恭迎龙王回归！）",
	["f_guanyunpengg"] = "龙王管云鹏",
	    --龙王
	  ["f_longwang"] = "龙王",
	  [":f_longwang"] = "锁定技，你因“回归”而获得此技能后，立即废除判定区；出牌阶段开始时，你从牌堆获得随机的基本牌、锦囊牌、装备牌各一张；你造成的所有伤害+1。",
	  ["$f_longwang1"] = "四大家族欠下的血债，今日，要一并讨之！", --得牌
	  ["$f_longwang2"] = "好！准备一亿美元，给四大家族，黄泉路上花！", --造成伤害
	  --阵亡
	["~f_guanyunpeng"] = "为什么三年...这么久......", --暂无语音
	
	--广西鹿哥
	["f_guangxiluge"] = "广西鹿哥",
	["#f_guangxiluge"] = "喜提新车",
	["designer:f_guangxiluge"] = "时光流逝FC",
	["cv:f_guangxiluge"] = "火红的萨日朗DJ版",
	["illustrator:f_guangxiluge"] = "鹿哥",
	  --喜提
	["f_xiti"] = "喜提",
	["f_xiti_followup"] = "喜提",
	[":f_xiti"] = "出牌阶段限一次，你可以废除一个装备栏，依次展示牌堆顶的一张牌：若此牌与你刚刚以此法展示的所有牌的点数之和小于17，你获得之并继续此流程，否则你获得之并终止此流程。\
	你将你此次以此法获得的牌数记录为X，然后于此回合的出牌阶段限X次，你每使用一张牌，摸一张牌。", --16.8
	["f_xiti:0"] = "废除武器栏",
	["f_xiti:1"] = "废除防具栏",
	["f_xiti:2"] = "废除+1马栏",
	["f_xiti:3"] = "废除-1马栏",
	["f_xiti:4"] = "废除宝物栏",
	["$f_xiti1"] = "霸霸霸霸，霸，霸，霸，霸霸霸霸，俺没吃药~",
	["$f_xiti2"] = "狗给你狗窝，狗给你狗窝，狗给你狗窝，狗给你狗窝......",
	  --嗯造
	["f_enzao"] = "嗯造",
	["f_enzaoBuff"] = "嗯造",
	["f_enzaoACT"] = "嗯造-激活",
	[":f_enzao"] = "<font color='yellow'><b>激活技，</b></font>你可以将一张非基本牌当作任意一种(官方)基本牌使用或打出；你以此法使用的牌结算后，你使用的下一张牌无距离限制且不计入使用次数的限制。\
	<font color='orange'><b>当你的所有装备栏均已被废除时，你激活此技能。</b></font>",
	["f_enzaoKey"] = "“嗯造”已激活",
	["#f_enzaoACT"] = "%from 的所有装备栏均已被废除，“%arg” 被激活，已可使用",
	["f_enzao_list"] = "嗯造",
	["f_enzao_slash"] = "嗯造",
	["f_enzao_saveself"] = "嗯造",
	["f_enzaoInfinity"] = "",
	["$f_enzao1"] = "草原最美的花，火红的萨日朗，一梦到天涯遍地是花香",
	["$f_enzao2"] = "流浪的人儿啊，心上有了她，千里万里也会回头望",
	  --阵亡
	["~f_guangxiluge"] = "（抱歉，我只有bgm，没有台词......）",
}

--沙雕包1.5（2）--
--[[《目录》：
界·魔王-孙笑川(主公)、南方巨兽龙
]]

--SD1.5 001 界·魔王-孙笑川
j_sunxiaochuan = sgs.General(extension, "j_sunxiaochuan$", "devil", 4, true)

j_baotu = sgs.CreateTriggerSkill{
	name = "j_baotu",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local from,to = damage.from,damage.to
		for _, th in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if from:objectName() ~= th:objectName() and not th:isNude() and room:askForCard(th, '.|.|.|.', '#j_baotu', data, sgs.Card_MethodDiscard, to, false, self:objectName()) then
				room:broadcastSkillInvoke(self:objectName())
				local log = sgs.LogMessage()
				log.type = "$j_baotu"
				log.from = th
				log.to:append(player)
				room:sendLog(log)
				damage.from = th
				damage.damage = damage.damage + 1
				data:setValue(damage)
				--room:setPlayerFlag(player, "DF_j_baotu")
			end
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
j_sunxiaochuan:addSkill(j_baotu)

j_ruya = sgs.CreateTriggerSkill{
	name = "j_ruya",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		--[[if player:hasFlag("DF_j_baotu") then
			room:setPlayerFlag(player, "-DF_j_baotu")
			return false
		else]]
			if damage.to:isNude() then return false end
			local _data = sgs.QVariant()
			_data:setValue(damage.to)
			if not player:askForSkillInvoke(self:objectName(), _data) then return false end
			local card = room:askForExchange(damage.to, self:objectName(), 999, 1, true, "#j_ruya:"..player:getGeneralName())
			if card then
				room:broadcastSkillInvoke(self:objectName())
				room:obtainCard(player, card, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), damage.to:objectName(), self:objectName(), ""), false)
		    	if card:getSubcards():length() >= 2 then
					damage.damage = damage.damage - 1
					if damage.damage < 1 then
						return true
					end
					data:setValue(damage)
				end
			end
		--end
	end,
}
j_sunxiaochuan:addSkill(j_ruya)

j_sunxiaochuan:addSkill("f_tianhuang")

--SD1.5 002 南方巨兽龙
f_Giga = sgs.General(extension, "f_Giga", "wei", 5, false) --雌性
f_Giga_carolini = sgs.General(extension, "f_Giga_carolini", "god", 5, false, true, true) --雄性

f_xuwei = sgs.CreateTriggerSkill{
	name = "f_xuwei",
	frequency = sgs.Skill_Compulsory,
	--events = {sgs.GameStart},
	events = {sgs.DrawInitialCards},
	waked_skills = "f_weiya, f_tongzhi, f_longzu",
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName(), 1)
		room:addPlayerMark(player, self:objectName(), 2) --给两枚标记，1枚防止第一回合转换；另1枚用作转换识别
		room:addPlayerMark(player, "f_xuwei_movie") --用于识别“电影形态”身份
	end,
}
f_xuweiChange = sgs.CreateTriggerSkill{ --将形态转换分离为不与主技能有任何联系的全局技能，防止因武将变更导致失效
	name = "f_xuweiChange",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TurnStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getMark("f_xuwei") > 1 then
			room:removePlayerMark(player, "f_xuwei")
		else
			if player:getMark("f_xuwei_movie") > 0 then
				room:sendCompulsoryTriggerLog(player, "f_xuwei")
				room:broadcastSkillInvoke("f_xuwei", 2)
				local mhp = player:getMaxHp()
				local hp = player:getHp()
				room:changeHero(player, "f_Giga_carolini", false, false, false, true) --变更为“史实形态”
				if player:getMaxHp() ~= mhp then room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) end
				if player:getHp() ~= hp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end
				room:setPlayerProperty(player, "kingdom", sgs.QVariant("god")) --修正为神势力
				player:setGender(sgs.General_Male) --修正性别
				room:setPlayerMark(player, "f_xuwei_movie", 0)
				room:setPlayerMark(player, "f_xuwei_carolini", 1) --用于识别“史实形态”身份
			elseif player:getMark("f_xuwei_carolini") > 0 then
				room:sendCompulsoryTriggerLog(player, "f_xuwei")
				room:broadcastSkillInvoke("f_xuwei", 1)
				local mhp = player:getMaxHp()
				local hp = player:getHp()
				room:changeHero(player, "f_Giga", false, false, false, true) --变更为“电影形态”
				if player:getMaxHp() ~= mhp then room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) end
				if player:getHp() ~= hp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end
				room:setPlayerMark(player, "f_xuwei_carolini", 0)
				room:setPlayerMark(player, "f_xuwei_movie", 1)
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("f_xuwei") > 0
	end,
}
f_Giga:addSkill(f_xuwei)
f_Giga:addRelateSkill("f_weiya")
f_Giga:addRelateSkill("f_tongzhi")
f_Giga:addRelateSkill("f_longzu")
if not sgs.Sanguosha:getSkill("f_xuweiChange") then skills:append(f_xuweiChange) end

--==形态1：电影形态==--
local function isSpecialOne(player, name)
	local g_name = sgs.Sanguosha:translate(player:getGeneralName())
	if string.find(g_name, name) then return true end
	if player:getGeneral2() then
		g_name = sgs.Sanguosha:translate(player:getGeneral2Name())
		if string.find(g_name, name) then return true end
	end
	return false
end
f_mieba = sgs.CreateTriggerSkill{
	name = "f_mieba",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.from:objectName() == player:objectName() and damage.to then
			local n = 0
			if isSpecialOne(damage.to, "霸") then n = n + 1 end
			if isSpecialOne(damage.to, "王") then n = n + 1 end
			if isSpecialOne(damage.to, "龙") then n = n + 1 end
			if (isSpecialOne(damage.to, "项羽") or isSpecialOne(damage.to, "孙策")) then n = n + 2 end --霸王与小霸王
			if n > 0 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				damage.damage = damage.damage + n
				room:setPlayerFlag(player, "f_wenheDown")
				data:setValue(damage)
			end
		end
	end,
}
f_Giga:addSkill(f_mieba)

f_wenhe = sgs.CreateTriggerSkill{
	name = "f_wenhe",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed, sgs.CardResponded, sgs.DamageCaused, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse then
				if not card:isDamageCard() and not card:isKindOf("SkillCard") and player:hasSkill(self:objectName()) then
					local names, name = player:property("f_wenheRecord"):toString():split("+"), card:objectName()
					if table.contains(names, name) then return false end
					table.insert(names, name)
					room:setPlayerProperty(player, "f_wenheRecord", sgs.QVariant(table.concat(names, "+"))) --记录牌名
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:drawCards(player, 1, self:objectName())
				end
			end
		elseif event == sgs.DamageCaused then
			local damage = data:toDamage()
			if not player:hasSkill(self:objectName()) then return false end
			if player:getMark(self:objectName()) < 1 and not player:hasFlag("f_wenheDown") then
				room:addPlayerMark(player, self:objectName())
			elseif player:getMark(self:objectName()) >= 1 and not player:hasFlag("f_wenheDown") then
				room:addPlayerMark(player, self:objectName())
				room:setPlayerFlag(player, "f_wenhePrevent") --防止伤害用
			end
			if player:hasFlag("f_wenheDown") then
				room:setPlayerFlag(player, "-f_wenheDown")
			end
			if player:hasFlag("f_wenhePrevent") then
				room:setPlayerFlag(player, "-f_wenhePrevent")
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				if player:getMark("f_wenheDrawFQC") < 3 then
					room:drawCards(player, 1, self:objectName())
				end
				room:addPlayerMark(player, "f_wenheDrawFQC")
				return true
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark(self:objectName()) > 0 then
					room:setPlayerMark(p, self:objectName(), 0)
					room:setPlayerMark(p, "f_wenheDrawFQC", 0)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_Giga:addSkill(f_wenhe)

f_quhuo = sgs.CreateTriggerSkill{
	name = "f_quhuo",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.nature == sgs.DamageStruct_Fire and damage.to:objectName() == player:objectName() then
			local judge = sgs.JudgeStruct()
			judge.pattern = ".|red"
			judge.good = true
			judge.reason = self:objectName()
			judge.who = player
			room:judge(judge)
			if judge:isGood() then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				if damage.card then
					local ids = sgs.IntList()
					if damage.card:isVirtualCard() then
						ids = damage.card:getSubcards()
					else
						ids:append(damage.card:getEffectiveId())
					end
					if ids:length() > 0 then
						local all_place_table = true
						for _, id in sgs.qlist(ids) do
							if room:getCardPlace(id) ~= sgs.Player_PlaceTable then
								all_place_table = false
								break
							end
						end
						if all_place_table then
							room:obtainCard(player, damage.card)
						end
					end
				end
				return true
			end
		end
	end,
}
f_Giga:addSkill(f_quhuo)

f_daoshang = sgs.CreateTriggerSkill{
	name = "f_daoshang",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified, sgs.EnterDying},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.from:getWeapon() ~= nil and use.card then
				local no_respond_list = use.no_respond_list
				for _, nj in sgs.qlist(use.to) do
					if not nj:hasSkill(self:objectName()) then continue end
					room:sendCompulsoryTriggerLog(nj, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					table.insert(no_respond_list, nj:objectName())
				end
				use.no_respond_list = no_respond_list
				data:setValue(use)
			end
		elseif event == sgs.EnterDying then
			local dying = data:toDying()
			if dying.who:objectName() ~= player:objectName() or not player:hasSkill(self:objectName()) then return false end
			if dying.damage and dying.damage.from and dying.damage.from:getWeapon() ~= nil then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:killPlayer(player, dying.damage)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_Giga:addSkill(f_daoshang)

--==形态2：史实形态==--
f_weiya = sgs.CreateTriggerSkill{
	name = "f_weiya",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				room:broadcastSkillInvoke(self:objectName())
				room:damage(sgs.DamageStruct(self:objectName(), player, p))
			end
		end
	end,
}
f_Giga_carolini:addSkill(f_weiya)

f_tongzhi = sgs.CreateTriggerSkill{
	name = "f_tongzhi",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damage then
			local damage = data:toDamage()
			if damage.from:objectName() == player:objectName() and player:hasSkill(self:objectName())
			and damage.to and damage.to:getHp() < player:getHp() then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				damage.to:gainMark("&f_tongzhi", 1)
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart and player:getMark("&f_tongzhi") > 0 and not player:isAllNude() then
				for _, cnj in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					if player:getMark("&f_tongzhi") == 0 or player:isAllNude() then break end
					if not room:askForSkillInvoke(cnj, self:objectName(), data) then continue end
					local prey = room:askForCardChosen(cnj, player, "hej", self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:obtainCard(cnj, prey, false)
					player:loseMark("&f_tongzhi", 1)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_Giga_carolini:addSkill(f_tongzhi)

f_longzu = sgs.CreateTriggerSkill{
	name = "f_longzu",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.Damage, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.from:objectName() == player:objectName() and player:hasSkill(self:objectName()) and player:getMark(self:objectName()) == 0
			and use.card and use.card:isDamageCard() then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:addPlayerMark(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					local choice = room:askForChoice(player, "f_longzus", "1+2+3")
					if choice == "1" then
						--召唤【南方巨兽龙族】灵魂之一：丘布特魁纣龙
						room:setCardFlag(use.card, "f_longzu-KZXJGWN") --魁纣雄踞冈瓦纳
					elseif choice == "2" then
						--召唤【南方巨兽龙族】灵魂之一：卡洛琳南方巨兽龙
						room:setCardFlag(use.card, "f_longzu-NFJSCXS") --南方巨兽逞凶煞
					elseif choice == "3" then
						--召唤【南方巨兽龙族】灵魂之一：玫瑰马普龙
						room:setCardFlag(use.card, "f_longzu-MGRXYCX") --玫瑰如血映残霞
					end
				end
			end
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if damage.from:objectName() == player:objectName() and damage.card then
				local n = damage.damage
				if damage.card:hasFlag("f_longzu-KZXJGWN") then
					room:setCardFlag(damage.card, "-f_longzu-KZXJGWN")
					room:drawCards(player, n, self:objectName())
				elseif damage.card:hasFlag("f_longzu-NFJSCXS") then
					room:setCardFlag(damage.card, "-f_longzu-NFJSCXS")
					while n > 0 and not damage.to:isNude() do
						local card = room:askForCardChosen(player, damage.to, "he", self:objectName())
						room:throwCard(card, damage.to, player)
						n = n - 1
					end
				elseif damage.card:hasFlag("f_longzu-MGRXYCX") then
					room:setCardFlag(damage.card, "-f_longzu-MGRXYCX")
					room:recover(player, sgs.RecoverStruct(player, nil, n))
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark(self:objectName()) > 0 then
					room:setPlayerMark(p, self:objectName(), 0)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_Giga_carolini:addSkill(f_longzu)

sgs.LoadTranslationTable{
	--界·魔王-孙笑川
	["j_sunxiaochuan"] = "界·魔王-孙笑川",
	["&j_sunxiaochuan"] = "界孙笑川",
	["#j_sunxiaochuan"] = "儒雅の天皇",
	["designer:j_sunxiaochuan"] = "诺多战士",
	["cv:j_sunxiaochuan"] = "孙笑川,Slippy,Shahmen",
	["illustrator:j_sunxiaochuan"] = "孙笑川",
	  --界暴徒
	["j_baotu"] = "暴徒",
	[":j_baotu"] = "当其他角色造成伤害时，你可以弃置一张牌并成为伤害来源，且令此伤害+1。",
	["#j_baotu"] = "暴徒：你可以弃一张牌并成为本次伤害的伤害来源",
	["$j_baotu"] = "%from 发动了“<font color='yellow'><b>暴徒</b></font>”，将 <font color='yellow'><b>伤害来源</b></font> 从 %to 改成 %from",
	["$j_baotu1"] = "你吼辣么大声干森么嘛？",
	["$j_baotu2"] = "那你去物管啊！",
	["$j_baotu3"] = "你踏马的你在这抒情是吧",
	["$j_baotu4"] = "你是有病是吧？",
	["$j_baotu5"] = "你是不是聋鸣？",
	  --界儒雅
	["j_ruya"] = "儒雅",
	[":j_ruya"] = "当你不因“暴徒”对其他角色造成伤害时，你可以令其交给你至少一张牌，若其交给你两张或更多的牌，你令此伤害-1。",
	["#j_ruya"] = "儒雅：请交给 %src 至少一张牌",
	["$j_ruya1"] = "我这个人是非常儒雅随和的一个人",
	["$j_ruya2"] = "关我锤子事",
	["$j_ruya3"] = "你能不能稳重一点",
	["$j_ruya4"] = "劳资真的觉得烦",
	["$j_ruya5"] = "我是你爹！",
	  --阵亡
	["~j_sunxiaochuan"] = "不爱，别伤害",
	
	--南方巨兽龙（初始为电影形态）
	["f_Giga"] = "南方巨兽龙",
	["&f_Giga"] = "北方昆卡巨猎龙",
	["#f_Giga"] = "纯纯的小丑",
	["designer:f_Giga"] = "侏罗纪世界3,时光流逝FC",
	["cv:f_Giga"] = "果妹,亿载龙殿",
	["illustrator:f_Giga"] = "侏罗纪世界3,网络",
	  --虚位
	["f_xuwei"] = "虚位",
	["f_xuweiChange"] = "虚位",
	[":f_xuwei"] = "<font color=\"#0066FF\"><b>形态</b></font>转换技，你拥有两种形态：“电影形态/史实形态”。锁定技，你的初始形态为“电影形态”；你的第二个回合及之后的每个回合开始前，你转换一次形态。" ..
	"（“电影形态”具体技能见<font color='black'><b>黑字</b></font>，“史实形态”具体技能见<font color=\"#01A5AF\"><b>青字</b></font>）",
	["f_xuwei_movie"] = "",
	["f_xuwei_carolini"] = "",
	["$f_xuwei1"] = "", --游戏开始以电影形态登场；转换为电影形态
	["$f_xuwei2"] = "", --转换为史实形态
	  --电影形态
	    --灭霸
	  ["f_mieba"] = "灭霸",
	  [":f_mieba"] = "锁定技，当你对一名其他角色造成伤害时，若该角色的名字出现：1.霸；2.王；3.龙，每满足一项，此伤害+1，且只要至少满足一项，此次伤害即不计入“温和”的伤害次数。<font color='red'>（注：“西楚霸王”项羽与“小霸王”孙策也跑不掉，通通+2）</font>",
	  ["$f_mieba1"] = "",
	  ["$f_mieba2"] = "",
	    --温和
	  ["f_wenhe"] = "温和",
	  [":f_wenhe"] = "锁定技，你每使用一张未被记录的非伤害类卡牌，你记录之，然后摸一张牌；当你于一个回合造成两次及以上的伤害时，你防止之，改为摸一张牌（每回合限以此法摸三次）。",
	  ["f_wenheDrawFQC"] = "",
	  ["$f_wenhe1"] = "",
	  ["$f_wenhe2"] = "",
	    --趋火
	  ["f_quhuo"] = "趋火",
	  [":f_quhuo"] = "锁定技，当你受到火焰伤害时，你进行判定：若判定结果为红色，你防止之并获得本应对你造成此次伤害的牌。",
	  ["$f_quhuo1"] = "",
	  ["$f_quhuo2"] = "",
	    --刀殇
	  ["f_daoshang"] = "刀殇",
	  [":f_daoshang"] = "锁定技，装备区里有武器牌的角色对你使用牌你不可响应；当你因受到装备区里有武器牌的角色的伤害而即将进入濒死状态时，你跳过之，改为立即死亡。",
	  ["$f_daoshang1"] = "",
	  ["$f_daoshang2"] = "",
	    --阵亡
	  ["~f_Giga"] = "呜呜呜，我想看世界燃烧~",
	  ----
	  --史实形态
	  ["f_Giga_carolini"] = "[神]卡洛琳南方巨兽龙",
	  ["&f_Giga_carolini"] = "卡洛琳南方巨兽龙",
	    --威压
	  ["f_weiya"] = "威压",
	  [":f_weiya"] = "锁定技，准备阶段开始时，你对所有其他角色各造成1点伤害。",
	  ["$f_weiya1"] = "",
	  ["$f_weiya2"] = "",
	    --统治
	  ["f_tongzhi"] = "统治",
	  [":f_tongzhi"] = "当你对一名其他角色造成伤害后，若其体力值小于你，其获得1枚“统治”标记。一名有“统治”标记的角色回合开始时，你可以获得其区域里的一张牌，然后其移除1枚“统治”标记。",
	  [":&f_tongzhi"] = "该生物正在卡洛琳南方巨兽龙的支配下瑟瑟发抖着",
	  ["$f_tongzhi1"] = "",
	  ["$f_tongzhi2"] = "",
	    --龙族
	  ["f_longzu"] = "龙族",
	  ["f_longzus"] = "南方巨兽龙族",
	  [":f_longzu"] = "每个回合限一次，当你使用伤害类卡牌指定一名目标时，你可以召唤【南方巨兽龙族】的灵魂并选择一种，令此牌附带相应效果：\
	  1.[魁纣雄踞]造成伤害后，你摸等同于伤害值的牌。\
	  2.[巨兽凶煞]造成伤害后，你弃置目标等同于伤害值的牌。\
	  3.[玫瑰喋血]造成伤害后，你回复等同于伤害值的体力。", --注：魁纣雄踞(丘布特魁纣龙)；巨兽凶煞(卡洛琳南方巨兽龙)；玫瑰喋血(玫瑰马普龙)
	  ["f_longzus:1"] = "[魁纣雄踞]造成伤害后，你摸等同于伤害值的牌",
	  ["f_longzus:2"] = "[巨兽凶煞]造成伤害后，你弃置目标等同于伤害值的牌",
	  ["f_longzus:3"] = "[玫瑰喋血]造成伤害后，你回复等同于伤害值的体力",
	  ["$f_longzu1"] = "魁纣，暴君踞冈瓦纳，南方巨兽逞凶煞，玫瑰如血映残霞。",
	  ["$f_longzu2"] = "魁兽分庭辟下荒，玫瑰喋血兆凶相。",
	    --阵亡
	  ["~f_Giga_carolini"] = "",
	--
}







--

--==沙雕包2.0（12）==--
sdCard = sgs.Package("sdCard", sgs.Package_CardPack)
--[[《目录》：
魏：无名小卒、蔡徐坤
蜀：红色风暴&蓝色妖姬(专属卡牌:黄金切尔西)、宇宙丁真
吴&蜀：凌元；吴&晋：苟咔
群：狂暴流氓云、大狗&杜神&彪爷
神：神徐盛、神黄忠(专属卡牌:赤血刃/没日弓)
魔：汤姆、杰瑞
]]

--SD2 001 无名小卒
f_wumingxiaozu = sgs.General(extension, "f_wumingxiaozu", "wei", 3, false)

f_zhineng = sgs.CreateTriggerSkill{
	name = "f_zhineng",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if p:getMark(self:objectName()) >= 2 then continue end
				if not room:askForSkillInvoke(p, self:objectName(), data) then continue end
				room:broadcastSkillInvoke(self:objectName())
				local yinjians = room:askForPlayerChosen(p, room:getAllPlayers(), self:objectName())
				room:drawCards(yinjians, 5, self:objectName())
				room:addPlayerMark(p, self:objectName())
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, self:objectName(), 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_wumingxiaozu:addSkill(f_zhineng)

f_shenji = sgs.CreateTriggerSkill{
	name = "f_shenji",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.to:objectName() ~= player:objectName() or not damage.card:isRed() then return false end
		room:sendCompulsoryTriggerLog(player, self:objectName())
		room:broadcastSkillInvoke(self:objectName())
		damage.damage = damage.damage + 1
		data:setValue(damage)
	end,
}
f_wumingxiaozu:addSkill(f_shenji)

--SD2 002 蔡徐坤
f_CXK = sgs.General(extension, "f_CXK", "wei", 3, true)

f_zhiyinyi = sgs.CreateTriggerSkill{
	name = "f_zhiyinyi",
	priority = 25,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.AfterDrawInitialCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:doLightbox("$JiNiTaiMei", 36000)
	end,
}
f_CXK:addSkill(f_zhiyinyi)

f_kunli = sgs.CreateDrawCardsSkill{
	name = "f_kunli",
	frequency = sgs.Skill_Compulsory,
	draw_num_func = function(self, player, n)
		local room = player:getRoom()
		if math.random() <= 0.25 and player:hasSkill(self:objectName()) then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName(), 1) --鸡！
			room:broadcastSkillInvoke(self:objectName(), 1) --你！
			room:broadcastSkillInvoke(self:objectName(), 1) --太！
			room:broadcastSkillInvoke(self:objectName(), 1) --美！
			room:broadcastSkillInvoke(self:objectName(), 2)
			return n*2.5
		else
			return n
		end
	end,
}
f_kunlim = sgs.CreateTriggerSkill{
	name = "f_kunlim",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if math.random() > 0.25 then
			room:broadcastSkillInvoke(self:objectName())
			room:setPlayerFlag(player, "f_kunlix")
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_kunli") and player:getPhase() == sgs.Player_Discard
	end,
}
f_kunlix = sgs.CreateMaxCardsSkill{
	name = "f_kunlix",
	extra_func = function(self, player)
		if player:hasFlag(self:objectName()) and player:hasSkill("f_kunli") then
			local n = player:getHp()
			return n*1.5 + 1 --n+n*1.5=n*2.5
		else
			return 0
		end
	end,
}
f_CXK:addSkill(f_kunli)
if not sgs.Sanguosha:getSkill("f_kunlim") then skills:append(f_kunlim) end
if not sgs.Sanguosha:getSkill("f_kunlix") then skills:append(f_kunlix) end
--“坤历”的语音，还用于坤坤的出杀和受伤音效：
f_kunkun = sgs.CreateTriggerSkill{
	name = "f_kunkun",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed, sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") then
				room:broadcastSkillInvoke("f_kunli", 1)
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			room:broadcastSkillInvoke("f_kunli", 2)
		end
	end,
	can_trigger = function(self, player)
		return player:getGeneralName() == "f_CXK" or player:getGeneral2Name() == "f_CXK"
	end,
}
if not sgs.Sanguosha:getSkill("f_kunkun") then skills:append(f_kunkun) end

f_kunstudyZYGet = sgs.CreateTriggerSkill{
	name = "f_kunstudyZYGet",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:getGeneralName() ~= "f_CXK" and player:getGeneral2Name() ~= "f_CXK" then return false end
			room:sendCompulsoryTriggerLog(player, "f_kunstudy")
			room:broadcastSkillInvoke("f_kunstudy", 1)
			player:gainMark("&f_ZhiYin", 50)
		else
			local card = nil
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				card = response.m_card
			end
			if card and not card:isKindOf("SkillCard") then
				room:sendCompulsoryTriggerLog(player, "f_kunstudy")
				--room:broadcastSkillInvoke("f_kunstudy") --不设了，否则触发频率太频繁，会太吵
				local judge = sgs.JudgeStruct()
				judge.pattern = "."
				judge.play_animation = false
				judge.who = player
				judge.reason = "f_kunstudy"
				room:judge(judge)
				if judge.card then
					local n = card:getNumber() + judge.card:getNumber()
					player:gainMark("&f_ZhiYin", n)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_kunstudy")
	end,
}
f_kunstudyCard = sgs.CreateSkillCard{
	name = "f_kunstudyCard",
	target_fixed = true,
	on_use = function(self, room, kunkun, targets)
        local choices = {}
		--运球帷幄
		if kunkun:getMark("&f_ZhiYin") >= 25 and not kunkun:hasSkill("ks_YQWW") and not kunkun:hasFlag("ks_YQWW") then
			table.insert(choices, "ks_YQWW")
		end
		--铁山靠
		if kunkun:getMark("&f_ZhiYin") >= 50 and not kunkun:hasSkill("ks_TSK") and not kunkun:hasFlag("ks_TSK") then
			table.insert(choices, "ks_TSK")
		end
		--乌鸦坐飞机
		if kunkun:getMark("&f_ZhiYin") >= 75 and not kunkun:hasSkill("ks_WYZFJ") and not kunkun:hasFlag("ks_WYZFJ") then
			table.insert(choices, "ks_WYZFJ")
		end
		--千鸟螺旋丸
		if kunkun:getMark("&f_ZhiYin") >= 100 and not kunkun:hasSkill("ks_QNLXW") and not kunkun:hasFlag("ks_QNLXW") then
			table.insert(choices, "ks_QNLXW")
		end
		--捂当
		if kunkun:getMark("&f_ZhiYin") >= 125 and not kunkun:hasSkill("ks_WD") and not kunkun:hasFlag("ks_WD") then
			table.insert(choices, "ks_WD")
		end
		--蠢蠢欲动
		if kunkun:getMark("&f_ZhiYin") >= 150 and not kunkun:hasSkill("ks_CCYD") and not kunkun:hasFlag("ks_CCYD") then
			table.insert(choices, "ks_CCYD")
		end
		--得牌
		if kunkun:getMark("&f_ZhiYin") >= 20 and kunkun:getMark("ks_GetCards") < 2 then
			table.insert(choices, "ks_GetCards")
		end
		table.insert(choices, "cancel")
		local choice = room:askForChoice(kunkun, "f_kunstudy", table.concat(choices, "+"))
		if choice == "cancel" then return false end
		if choice == "ks_GetCards" then
			local kunstudy_cards = {}
			local kunstudy_red_count = 0
			for _, id in sgs.qlist(room:getDrawPile()) do
				if sgs.Sanguosha:getCard(id):isRed() and not table.contains(kunstudy_cards, id) and kunstudy_red_count < 1 then
					kunstudy_red_count = kunstudy_red_count + 1
					table.insert(kunstudy_cards, id)
				end
			end
			local kunstudy_black_count = 0
			for _, id in sgs.qlist(room:getDrawPile()) do
				if sgs.Sanguosha:getCard(id):isBlack() and not table.contains(kunstudy_cards, id) and kunstudy_black_count < 1 then
					kunstudy_black_count = kunstudy_black_count + 1
					table.insert(kunstudy_cards, id)
				end
			end
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, id in ipairs(kunstudy_cards) do
				dummy:addSubcard(id)
			end
			room:broadcastSkillInvoke("f_kunstudy", 1)
			room:obtainCard(kunkun, dummy, false)
			kunkun:loseMark("&f_ZhiYin", 20)
			room:addPlayerMark(kunkun, "ks_GetCards")
		else
			room:broadcastSkillInvoke("f_kunstudy", 2)
			if choice == "ks_YQWW" then
				room:acquireSkill(kunkun, "ks_YQWW")
				kunkun:loseMark("&f_ZhiYin", 25)
				room:setPlayerFlag(kunkun, "ks_YQWW")
			elseif choice == "ks_TSK" then
				room:acquireSkill(kunkun, "ks_TSK")
				kunkun:loseMark("&f_ZhiYin", 50)
				room:setPlayerFlag(kunkun, "ks_TSK")
			elseif choice == "ks_WYZFJ" then
				room:acquireSkill(kunkun, "ks_WYZFJ")
				kunkun:loseMark("&f_ZhiYin", 75)
				room:setPlayerFlag(kunkun, "ks_WYZFJ")
			elseif choice == "ks_QNLXW" then
				room:acquireSkill(kunkun, "ks_QNLXW")
				kunkun:loseMark("&f_ZhiYin", 100)
				room:setPlayerFlag(kunkun, "ks_QNLXW")
			elseif choice == "ks_WD" then
				room:acquireSkill(kunkun, "ks_WD")
				kunkun:loseMark("&f_ZhiYin", 125)
				room:setPlayerFlag(kunkun, "ks_WD")
			elseif choice == "ks_CCYD" then
				room:acquireSkill(kunkun, "ks_CCYD")
				kunkun:loseMark("&f_ZhiYin", 150)
				room:setPlayerFlag(kunkun, "ks_CCYD")
			end
		end
	end,
}
f_kunstudy = sgs.CreateZeroCardViewAsSkill{
	name = "f_kunstudy",
	waked_skills = "ks_YQWW, ks_TSK, ks_WYZFJ, ks_QNLXW, ks_WD, ks_CCYD",
	view_as = function()
		return f_kunstudyCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("&f_ZhiYin") >= 20
	end,
}
f_kunstudyGetCardsFQCclear = sgs.CreateTriggerSkill{
	name = "f_kunstudyGetCardsFQCclear",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Play then return false end
		if player:hasFlag("ks_YQWW") then room:setPlayerFlag(player, "-ks_YQWW") end
		if player:hasFlag("ks_TSK") then room:setPlayerFlag(player, "-ks_TSK") end
		if player:hasFlag("ks_WYZFJ") then room:setPlayerFlag(player, "-ks_WYZFJ") end
		if player:hasFlag("ks_QNLXW") then room:setPlayerFlag(player, "-ks_QNLXW") end
		if player:hasFlag("ks_WD") then room:setPlayerFlag(player, "-ks_WD") end
		if player:hasFlag("ks_CCYD") then room:setPlayerFlag(player, "-ks_CCYD") end
		room:setPlayerMark(player, "ks_GetCards", 0)
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_CXK:addSkill(f_kunstudy)
f_CXK:addRelateSkill("ks_YQWW")
f_CXK:addRelateSkill("ks_TSK")
f_CXK:addRelateSkill("ks_WYZFJ")
f_CXK:addRelateSkill("ks_QNLXW")
f_CXK:addRelateSkill("ks_WD")
f_CXK:addRelateSkill("ks_CCYD")
if not sgs.Sanguosha:getSkill("f_kunstudyZYGet") then skills:append(f_kunstudyZYGet) end
if not sgs.Sanguosha:getSkill("f_kunstudyGetCardsFQCclear") then skills:append(f_kunstudyGetCardsFQCclear) end
--==坤学库==--
--1.ikun基础班《运球帷幄》
ks_YQWWCard = sgs.CreateSkillCard{
	name = "ks_YQWWCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
        local last, naxt
		for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			if p:getNextAlive():objectName() == source:objectName() then --找到上家
				last = p
			end
		end
		naxt = source:getNextAlive()
		local choices = {}
		--从上家开始
		if not last:isKongcheng() then
			table.insert(choices, "YQWW_lastalive")
		end
		--从下家开始
		if not naxt:isKongcheng() then
			table.insert(choices, "YQWW_nextalive")
		end
		local choice = room:askForChoice(source, "ks_YQWW", table.concat(choices, "+"))
		if choice == "YQWW_lastalive" then room:setPlayerFlag(source, "YQWW_lastalive")
		elseif choice == "YQWW_nextalive" then room:setPlayerFlag(source, "YQWW_nextalive") end
		while not source:hasFlag("YQWW_END") do
			--每次轮回都重新锁定上下家，防止运球中途本来锁定的上/下家有人死亡而导致时实的上/下家改变从而导致闪退
			for _, p in sgs.qlist(room:getOtherPlayers(source)) do
				if p:getNextAlive():objectName() == source:objectName() then
					last = p
				end
			end
			naxt = source:getNextAlive()
			--
			room:broadcastSkillInvoke("ks_YQWW")
			--从左(上家)往右(下家)运球(牌)
			if source:hasFlag("YQWW_lastalive") then
				if not last:isKongcheng() then
					local basketball = room:askForCardChosen(source, last, "h", "ks_YQWW")
					room:setCardFlag(basketball, "ks_YQWW_basketball")
					room:obtainCard(source, basketball, false) --运球开始
					local bsktbal
					for _, c in sgs.qlist(source:getHandcards()) do
						if c:hasFlag("ks_YQWW_basketball") then bsktbal = c end --锁定运来的牌
					end
					--local bsktbal = room:askForExchange(source, "ks_YQWW", 1, 1, false, "#ks_YQWW:".. naxt:getGeneralName())
					room:setPlayerFlag(naxt, "ks_YQWWgive") --锁定下家
					if not room:askForUseCard(source, "@@ks_YQWWX", "@ks_YQWWX") then --不是给运来的牌
						room:askForUseCard(source, "@@ks_YQWWY!", "@ks_YQWWY") --给的是运来的牌
					end
					if source:hasFlag("ks_YQWWX") and source:getMark("ks_YQWWX") == bsktbal:getNumber() then
						room:setCardFlag(bsktbal, "-ks_YQWW_basketball")
						--room:obtainCard(naxt, bsktbal, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, naxt:objectName(), source:objectName(), "ks_YQWW", ""), false)
						if source:getMark("&f_ZhiYin") >= 25 then
							if not room:askForUseCard(source, "@@ks_YQWWcontinue", "@ks_YQWWcontinue") then --达成条件，询问是否重复运球
								room:setPlayerFlag(source, "YQWW_END")
							end
						else
							room:setPlayerFlag(source, "YQWW_END")
						end
						room:setPlayerFlag(source, "-ks_YQWWX")
					else
						room:setCardFlag(bsktbal, "-ks_YQWW_basketball")
						--room:obtainCard(naxt, bsktbal, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, naxt:objectName(), source:objectName(), "ks_YQWW", ""), false)
						room:setPlayerFlag(source, "YQWW_END")
					end
				else
					room:setCardFlag(bsktbal, "-ks_YQWW_basketball")
					room:setPlayerFlag(source, "YQWW_END")
				end
			--从右(下家)往左(上家)运球(牌)
			elseif source:hasFlag("YQWW_nextalive") then
				if not naxt:isKongcheng() then
					local basketball = room:askForCardChosen(source, naxt, "h", "ks_YQWW")
					room:setCardFlag(basketball, "ks_YQWW_basketball")
					room:obtainCard(source, basketball, false) --运球开始
					local bsktbal
					for _, c in sgs.qlist(source:getHandcards()) do
						if c:hasFlag("ks_YQWW_basketball") then bsktbal = c end --锁定运来的牌
					end
					--local bsktbal = room:askForExchange(source, "ks_YQWW", 1, 1, false, "#ks_YQWW:".. last:getGeneralName())
					room:setPlayerFlag(last, "ks_YQWWgive") --锁定上家
					if not room:askForUseCard(source, "@@ks_YQWWX", "@ks_YQWWX") then --不是给运来的牌
						room:askForUseCard(source, "@@ks_YQWWY!", "@ks_YQWWY") --给的是运来的牌
					end
					if source:hasFlag("ks_YQWWX") and source:getMark("ks_YQWWX") == bsktbal:getNumber() then
						room:setCardFlag(bsktbal, "-ks_YQWW_basketball")
						--room:obtainCard(last, bsktbal, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, last:objectName(), source:objectName(), "ks_YQWW", ""), false)
						if source:getMark("&f_ZhiYin") >= 25 then
							if not room:askForUseCard(source, "@@ks_YQWWcontinue", "@ks_YQWWcontinue") then --达成条件，询问是否重复运球
								room:setPlayerFlag(source, "YQWW_END")
							end
						else
							room:setPlayerFlag(source, "YQWW_END")
						end
						room:setPlayerFlag(source, "-ks_YQWWX")
					else
						room:setCardFlag(bsktbal, "-ks_YQWW_basketball")
						--room:obtainCard(last, bsktbal, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, last:objectName(), source:objectName(), "ks_YQWW", ""), false)
						room:setPlayerFlag(source, "YQWW_END")
					end
				else
					room:setCardFlag(bsktbal, "-ks_YQWW_basketball")
					room:setPlayerFlag(source, "YQWW_END")
				end
			end
		end
		if source:hasFlag("YQWW_lastalive") then room:setPlayerFlag(source, "-YQWW_lastalive") end
		if source:hasFlag("YQWW_nextalive") then room:setPlayerFlag(source, "-YQWW_nextalive") end
		room:setPlayerMark(source, "ks_YQWWX", 0)
		room:setPlayerFlag(source, "-YQWW_END")
		room:detachSkillFromPlayer(source, "ks_YQWW")
	end,
}
ks_YQWW = sgs.CreateZeroCardViewAsSkill{
	name = "ks_YQWW",
	view_as = function()
		return ks_YQWWCard:clone()
	end,
	enabled_at_play = function(self, player)
		--[[if not player:getNextAlive():isKongcheng() then return true end
		for _, p in sgs.qlist(player:getAliveSiblings()) do
			if p:getNextAlive():objectName() == player:objectName() and not p:isKongcheng() then return true end
		end
		return false]]
		return true
	end,
}
--完成运球（不是给运来的牌）
ks_YQWWXCard = sgs.CreateSkillCard{
	name = "ks_YQWWXCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		room:setPlayerFlag(source, "ks_YQWWX") --表明不是给的运来的牌
		for _, id in sgs.qlist(self:getSubcards()) do
			local num = sgs.Sanguosha:getCard(id):getNumber()
			room:setPlayerMark(source, "ks_YQWWX", num) --记录该牌的点数
		end
		for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			if p:hasFlag("ks_YQWWgive") then
				room:setPlayerFlag(p, "-ks_YQWWgive")
				p:obtainCard(self) --完成一次运球
				break
			end
		end
	end,
}
ks_YQWWX = sgs.CreateOneCardViewAsSkill{
	name = "ks_YQWWX",
	view_filter = function(self, to_select)
		return not to_select:hasFlag("ks_YQWW_basketball") and not to_select:isEquipped()
	end,
	view_as = function(self, card)
		local bb_card = ks_YQWWXCard:clone()
		bb_card:addSubcard(card:getId())
		return bb_card
	end,
	response_pattern = "@@ks_YQWWX",
}
--完成运球（给的是运来的牌）
ks_YQWWYCard = sgs.CreateSkillCard{
	name = "ks_YQWWYCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			if p:hasFlag("ks_YQWWgive") then
				room:setPlayerFlag(p, "-ks_YQWWgive")
				p:obtainCard(self) --完成一次运球
				break
			end
		end
	end,
}
ks_YQWWY = sgs.CreateOneCardViewAsSkill{
	name = "ks_YQWWY",
	view_filter = function(self, to_select)
		return to_select:hasFlag("ks_YQWW_basketball") and not to_select:isEquipped()
	end,
	view_as = function(self, card)
		local bb_card = ks_YQWWYCard:clone()
		bb_card:addSubcard(card:getId())
		return bb_card
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@ks_YQWWY")
	end,
}
  --询问是否重复流程：
ks_YQWWcontinueCard = sgs.CreateSkillCard{
	name = "ks_YQWWcontinueCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		source:loseMark("&f_ZhiYin", 25)
		room:drawCards(source, 1, "ks_YQWW")
		if source:hasFlag("YQWW_lastalive") then
			room:setPlayerFlag(source, "-YQWW_lastalive")
			room:setPlayerFlag(source, "YQWW_nextalive")
		elseif source:hasFlag("YQWW_nextalive") then
			room:setPlayerFlag(source, "-YQWW_nextalive")
			room:setPlayerFlag(source, "YQWW_lastalive")
		end
	end,
}
ks_YQWWcontinue = sgs.CreateZeroCardViewAsSkill{
	name = "ks_YQWWcontinue",
	view_as = function()
		return ks_YQWWcontinueCard:clone()
	end,
	response_pattern = "@@ks_YQWWcontinue",
}
if not sgs.Sanguosha:getSkill("ks_YQWW") then skills:append(ks_YQWW) end
if not sgs.Sanguosha:getSkill("ks_YQWWX") then skills:append(ks_YQWWX) end
if not sgs.Sanguosha:getSkill("ks_YQWWY") then skills:append(ks_YQWWY) end
if not sgs.Sanguosha:getSkill("ks_YQWWcontinue") then skills:append(ks_YQWWcontinue) end
--2.ikun提高班·科目一《铁山靠》
ks_TSK = sgs.CreateTriggerSkill{
	name = "ks_TSK",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if player:getHandcardNum() + player:getEquips():length() < damage.damage or not player:canDiscard(player, "he") or not player:hasSkill(self:objectName()) then return false end
		if room:askForSkillInvoke(player, self:objectName(), data) then
			room:askForDiscard(player, self:objectName(), damage.damage, damage.damage, false, true)
			room:broadcastSkillInvoke(self:objectName())
			if damage.card and damage.card:isKindOf("Slash") then
				player:removeQinggangTag(damage.card)
			end
			damage.to = damage.from
			damage.transfer = true
			room:damage(damage)
			room:detachSkillFromPlayer(player, "ks_TSK")
			return true
		end
	end,
}
if not sgs.Sanguosha:getSkill("ks_TSK") then skills:append(ks_TSK) end
--3.ikun提高班·科目二《乌鸦坐飞机》
ks_WYZFJCard = sgs.CreateSkillCard{
	name = "ks_WYZFJCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		local n = self:subcardsLength()
		if #targets == n then return false end
		return to_select:objectName() ~= sgs.Self:objectName()
	end,
	feasible = function(self, targets)
		return #targets == self:subcardsLength()
	end,
	on_use = function(self, room, source, targets)
	    local suijigives = {}
		for _, c in sgs.qlist(self:getSubcards()) do
			table.insert(suijigives, c)
		end
		for _, p in pairs(targets) do
			local random_card = suijigives[math.random(1, #suijigives)]
			room:obtainCard(p, random_card, false)
			table.removeOne(suijigives, random_card)
		end
		
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("ks_WYZFJ")
		local use = sgs.CardUseStruct()
		use.card = slash
		use.from = source
		for _, p in pairs(targets) do
			if source:canSlash(p, nil, false) then
				use.to:append(p)
			end
		end
		room:useCard(use)
		room:setPlayerMark(source, "ks_WYZFJdetachSkill", 1) --后续移除技能用（从一开始的标志换成了标记，确保后续能正常移除）
	end,
}
ks_WYZFJ = sgs.CreateViewAsSkill{
    name = "ks_WYZFJ",
	n = 999,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local WYZFJ_card = ks_WYZFJCard:clone()
			for _, card in pairs(cards) do
				WYZFJ_card:addSubcard(card)
			end
			WYZFJ_card:setSkillName(self:objectName())
			return WYZFJ_card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isNude()
	end,
}
ks_WYZFJfinished = sgs.CreateTriggerSkill{
	name = "ks_WYZFJfinished",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damage, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damage then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and damage.card:getSkillName() == "ks_WYZFJ" and not damage.to:isAllNude() then
				room:sendCompulsoryTriggerLog(player, "ks_WYZFJ")
				room:broadcastSkillInvoke("ks_WYZFJ")
				local dt = room:askForCardChosen(player, damage.to, "hej", "ks_WYZFJ")
				room:obtainCard(player, dt, false)
			end
		else
			if player:getMark("ks_WYZFJdetachSkill") > 0 and player:hasSkill("ks_WYZFJ") then
				room:detachSkillFromPlayer(player, "ks_WYZFJ")
				room:setPlayerMark(player, "ks_WYZFJdetachSkill", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("ks_WYZFJ") then skills:append(ks_WYZFJ) end
if not sgs.Sanguosha:getSkill("ks_WYZFJfinished") then skills:append(ks_WYZFJfinished) end
--4.ikun提高班·科目三《千鸟螺旋丸》
ks_QNLXWCard = sgs.CreateSkillCard{
	name = "ks_QNLXWCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		if not room:askForUseCard(source, "@@ks_QNLXWS", "@ks_QNLXWS-kd_lxgannnnnnnnnn") then return false end
		while not source:hasFlag("QNLXW_END") do
			local n = source:getMark("&ks_QNLXW") + 1
			local m = 0.8/n
			if math.random() <= m then --成功
				room:addPlayerMark(source, "&ks_QNLXW")
				if not room:askForUseCard(source, "@@ks_QNLXWS", "@ks_QNLXWS-kd_lxgannnnnnnnnn") then
					room:setPlayerFlag(source, "QNLXW_END")
				end
			else --失败
				room:setPlayerFlag(source, "QNLXW_END")
			end
		end
		if source:getMark("&ks_QNLXW") > 0 then
			local t = source:getMark("&ks_QNLXW")
			local xiaoheizi = room:askForPlayerChosen(source, room:getAllPlayers(), "ks_QNLXW", "ks_QNLXW_xhzYBSBS:" .. t, true, true)
			if xiaoheizi then
				room:removePlayerMark(source, "&ks_QNLXW", t) --没有写成setPlayerMark，为了还原将搓好的螺旋丸甩向敌方的感觉
				room:damage(sgs.DamageStruct("ks_QNLXW", source, xiaoheizi, t, sgs.DamageStruct_Thunder))
			end
			room:setPlayerMark(source, "&ks_QNLXW", 0)
		end
		room:setPlayerFlag(source, "-QNLXW_END")
		room:detachSkillFromPlayer(source, "ks_QNLXW")
	end,
}
ks_QNLXW = sgs.CreateZeroCardViewAsSkill{
    name = "ks_QNLXW",
	view_as = function()
		return ks_QNLXWCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng()
	end,
	--response_pattern = "@@ks_QNLXW", --要不试试自己套自己的娃？
}
  --“手搓螺旋丸”流程：
ks_QNLXWSCard = sgs.CreateSkillCard{
	name = "ks_QNLXWSCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("ks_QNLXW") --你特么手搓螺旋丸就是放个语音是吧
	end,
}
ks_QNLXWS = sgs.CreateOneCardViewAsSkill{
    name = "ks_QNLXWS",
	filter_pattern = ".|black|.|hand",
	view_as = function(self, originalCard)
	    local QNLXWS_card = ks_QNLXWSCard:clone()
		QNLXWS_card:addSubcard(originalCard:getId())
		return QNLXWS_card
	end,
	response_pattern = "@@ks_QNLXWS",
}
if not sgs.Sanguosha:getSkill("ks_QNLXW") then skills:append(ks_QNLXW) end
if not sgs.Sanguosha:getSkill("ks_QNLXWS") then skills:append(ks_QNLXWS) end
--5.ikun提高班·科目四《捂当》
ks_WD = sgs.CreateTriggerSkill{
	name = "ks_WD",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if not player:hasSkill(self:objectName()) then return false end
		if room:askForSkillInvoke(player, self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName())
			local n = damage.damage
			player:gainHujia(n)
			room:drawCards(player, n, self:objectName())
			if n > 1 then
				player:turnOver()
			end
			room:detachSkillFromPlayer(player, "ks_WD")
		end
	end,
}
if not sgs.Sanguosha:getSkill("ks_WD") then skills:append(ks_WD) end
--6.ikun提高班·科目五《蠢蠢欲动》
ks_CCYDCard = sgs.CreateSkillCard{
	name = "ks_CCYDCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isNude()
	end,
	on_effect = function(self, effect)
	    local room = effect.from:getRoom()
		while not effect.from:hasFlag("CCYD_END") do
			--先判定目标还有没有牌，没牌直接终止循环
			if effect.to:isNude() then
				room:setPlayerFlag(effect.from, "CCYD_END")
			end
			if effect.from:hasFlag("CCYD_END") then break end
			room:broadcastSkillInvoke("ks_CCYD")
			local card = room:askForCardChosen(effect.from, effect.to, "he", "ks_CCYD")
			room:obtainCard(effect.from, card)
			room:showCard(effect.from, card)
			local judge = sgs.JudgeStruct()
			if sgs.Sanguosha:getCard(card):isRed() then judge.pattern = ".|red"
			elseif sgs.Sanguosha:getCard(card):isBlack() then judge.pattern = ".|black" end
			judge.good = true
			judge.play_animation = true
			judge.who = effect.from
			judge.reason = "ks_CCYD"
			room:judge(judge)
			if judge:isGood() then
				if not room:askForUseCard(effect.from, "@@ks_CCYDcontinue", "@ks_CCYDcontinue") then
					room:setPlayerFlag(effect.from, "CCYD_END")
				end
			else
				room:obtainCard(effect.from, judge.card)
				room:setPlayerFlag(effect.from, "CCYD_END")
				room:loseHp(effect.from, 1)
			end
		end
		if effect.from:isAlive() then
			room:setPlayerFlag(effect.from, "-CCYD_END")
			room:detachSkillFromPlayer(effect.from, "ks_CCYD")
		end
	end,
}
ks_CCYD = sgs.CreateZeroCardViewAsSkill{
    name = "ks_CCYD",
	view_as = function()
		return ks_CCYDCard:clone()
	end,
}
  --询问是否重复流程：
ks_CCYDcontinueCard = sgs.CreateSkillCard{
	name = "ks_CCYDcontinueCard",
	target_fixed = true,
	on_use = function()
	end,
}
ks_CCYDcontinue = sgs.CreateZeroCardViewAsSkill{
	name = "ks_CCYDcontinue",
	view_as = function()
		return ks_CCYDcontinueCard:clone()
	end,
	response_pattern = "@@ks_CCYDcontinue",
}
if not sgs.Sanguosha:getSkill("ks_CCYD") then skills:append(ks_CCYD) end
if not sgs.Sanguosha:getSkill("ks_CCYDcontinue") then skills:append(ks_CCYDcontinue) end
--==========--

f_ikun = sgs.CreateTriggerSkill{
	name = "f_ikun",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.HpRecover, sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
		    room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName(), 1)
			for _, xhz in sgs.qlist(room:getOtherPlayers(player)) do
			    xhz:gainMark("&ikun", math.random(0,1))
				if xhz:getMark("&ikun") > 0 then
					if not xhz:hasSkill("f_kunstudy") then room:acquireSkill(xhz, "f_kunstudy") end
					xhz:gainMark("&f_ZhiYin", 20)
				end
			end
		elseif event == sgs.HpRecover then
			local recover = data:toRecover()
			if recover.who and recover.who:getMark("&ikun") > 0 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), 2)
				room:drawCards(recover.who, recover.recover, self:objectName())
				room:drawCards(player, recover.recover, self:objectName())
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			if damage.from and damage.from:getMark("&ikun") > 0 then
				if not damage.from:isNude() and damage.from:canDiscard(damage.from, "he") then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName(), 3)
					room:askForDiscard(damage.from, self:objectName(), damage.damage, damage.damage, false, true)
				end
			end
		end
	end,
}
f_ikuns = sgs.CreateTriggerSkill{
	name = "f_ikuns",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards, sgs.CardUsed}, --sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawNCards then
		    local count = data:toInt()
			for _, cxk in sgs.qlist(room:findPlayersBySkillName("f_ikun")) do
				if not room:askForSkillInvoke(cxk, "@f_ikunDraw", data) then continue end
				room:broadcastSkillInvoke("f_ikun", 4)
				room:drawCards(cxk, count, "f_ikun")
				local lizhi = room:askForExchange(cxk, "f_ikun", count, count, true, "#f_ikunGiveCards:".. player:getGeneralName())
				if lizhi then
					room:obtainCard(player, lizhi, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), cxk:objectName(), "f_ikun", ""), false)
					if not player:hasFlag("f_ikunDrawNCardsCancel") then room:setPlayerFlag(player, "f_ikunDrawNCardsCancel") end
					lizhi:deleteLater()
				end
			end
			if player:hasFlag("f_ikunDrawNCardsCancel") then
				room:setPlayerFlag(player, "-f_ikunDrawNCardsCancel")
				data:setValue(-1000) --return true
			end
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.from:objectName() == player:objectName() and use.card and not use.card:isKindOf("SkillCard") then
				for _, lr in sgs.qlist(use.to) do
					if lr:getMark("&ikun") > 0 or lr:hasSkill("f_ikun") then continue end
					room:addPlayerMark(lr, "f_ikunToBe")
					local n = lr:getMark("f_ikunToBe")
					local m = n*2.5/100
					if m >= 1 or math.random() <= m then
						local log = sgs.LogMessage()
						log.type = "$f_ToBeIkun"
						log.from = player
						log.to:append(lr)
						room:sendLog(log)
						room:broadcastSkillInvoke("f_ikun", 5)
						lr:gainMark("&ikun", 1) --恭喜坤坤大家庭又增添一位新学员！
						room:setPlayerMark(lr, "f_ikunToBe", 0)
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&ikun") > 0
	end,
}
f_CXK:addSkill(f_ikun)
if not sgs.Sanguosha:getSkill("f_ikuns") then skills:append(f_ikuns) end

--SD2 003 红色风暴&蓝色妖姬（红色风暴+蓝色妖姬+《环太平洋》机甲“暴风赤红”,提及《环太平洋》机甲“忧蓝罗密欧”）
f_CP = sgs.General(extension, "f_CP", "shu", 6, true, false, false, 3)

f_xingyuan = sgs.CreateTriggerSkill{
	name = "f_xingyuan",
	frequency = sgs.Skill_Frequent,
	waked_skills = "red_jufeng, bluck_youya, bfch_xdlyz, bfch_dlzp, bfch_ldy",
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		--room:addPlayerMark(player, "@fcXuLi", 0) --初始蓄力点
		room:addPlayerMark(player, "fcXuLiMAX", 3) --蓄力点上限，可叠加
		if not player:hasEquipArea(4) then return false end
		local cds = sgs.IntList()
		for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
			if sgs.Sanguosha:getEngineCard(id):isKindOf("Fgoldenchelsea") and room:getCardPlace(id) ~= sgs.Player_DrawPile then
				cds:append(id)
			end
		end
		if not cds:isEmpty() then
			room:shuffleIntoDrawPile(player, cds, self:objectName(), true)
			local cards, cards_copy = sgs.CardList(), sgs.CardList()
			for _, id in sgs.qlist(room:getDrawPile()) do
				local card = sgs.Sanguosha:getCard(id)
				if card:isKindOf("Fgoldenchelsea") then
					room:setTag("FGC_ID", sgs.QVariant(id))
					cards:append(card)
					cards_copy:append(card)
				end
			end
			if not cards:isEmpty() then
				local equipA
				while not equipA do
					if cards:isEmpty() then break end
					if not equipA then
						equipA = cards:at(math.random(0, cards:length() - 1))
						for _, card in sgs.qlist(cards_copy) do
							if card:getSubtype() == equipA:getSubtype() then
								cards:removeOne(card)
							end
						end
					end
				end
				if equipA then
					local Moves = sgs.CardsMoveList()
					local equip = equipA:getRealCard():toEquipCard()
					local equip_index = equip:location()
					if player:getEquip(equip_index) == nil and player:hasEquipArea(equip_index) then
						--将“黄金切尔西”置入装备区
						room:sendCompulsoryTriggerLog(player, self:objectName())
						sgs.Sanguosha:playAudioEffect("audio/card/common/_f_goldenchelsea.ogg", false)
						Moves:append(sgs.CardsMoveStruct(equipA:getId(), player, sgs.Player_PlaceEquip, sgs.CardMoveReason()))
					else
						Moves:append(sgs.CardsMoveStruct(equipA:getId(), player, sgs.Player_PlaceHand, sgs.CardMoveReason()))
					end
					room:moveCardsAtomic(Moves, true)
				end
			end
		end
	end,
}
f_xingyuans = sgs.CreateTriggerSkill{ --解锁特殊形态
	name = "f_xingyuans",
	global = true,
	priority = {-1, -1, -1, -1},
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardsMoveOneTime, sgs.PreCardUsed, sgs.DamageCaused, sgs.Dying},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then --红色风暴
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceEquip)
			and player:getPhase() == sgs.Player_NotActive and player:hasSkill("f_xingyuan") and player:getMark("@CP_Red_unlock") == 0 then
				if not player:isAlive() then return false end
				if move.from_places:at(i) == sgs.Player_PlaceEquip then
					local can_invoke = false
					for _, id in sgs.qlist(move.card_ids) do
						local card = sgs.Sanguosha:getCard(id)
						if card:isKindOf("Fgoldenchelsea") then
							can_invoke = true
						end
					end
					if can_invoke then
						room:sendCompulsoryTriggerLog(player, "f_xingyuan")
						room:broadcastSkillInvoke("f_xingyuan", 1)
						room:doLightbox("$to_CP_Red")
						room:getThread():delay(7000)
						local current, last
						current = room:getCurrent()
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							if p:getNextAlive():objectName() == player:objectName() then --找到上家
								last = p
							end
						end
						if current:objectName() ~= last:objectName() then
							room:swapSeat(current, last)
						end
						if current:getEquips():length() > 0 and player:canDiscard(current, "e") then
							local te = room:askForCardChosen(player, current, "e", "f_xingyuan")
							room:throwCard(te, current, player)
							if current:getEquips():length() > 0 then
								local de = current:getEquips():length()
								room:damage(sgs.DamageStruct("f_xingyuan", player, current, de))
							end
						end
						--解锁并转换为“红色风暴”形态
						if not player:hasFlag("f_xingyuanNoRes") then room:setPlayerFlag(player, "f_xingyuanNoRes") end
						player:gainMark("@CP_Red_unlock", 1)
						local mhp = player:getMaxHp()
						local hp = player:getHp()
						room:changeHero(player, "CP_Red", false, false, false, true)
						if player:getMaxHp() ~= mhp then room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) end
						if player:getHp() ~= hp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end
						room:drawCards(player, 2, self:objectName())
					end
				end
			end
		elseif event == sgs.PreCardUsed then --蓝色妖姬
			local use = data:toCardUse()
			if use.from:objectName() == player:objectName() and use.from:isMale()
			and use.card:isKindOf("Slash") and use.to:length() == 1 then
				for _, p in sgs.qlist(room:findPlayersBySkillName("f_xingyuan")) do
					local ut = 0
					for _, u in sgs.qlist(use.to) do
						if u:objectName() == p:objectName() then ut = ut + 1 end
					end
					if not p:inMyAttackRange(player) or p:getMark("@CP_Bluck_unlock") > 0 or ut > 0 then continue end
					local use_slash = false
					if p:canSlash(player, nil, false) then
						room:setPlayerFlag(p, "f_xingyuan_bluck-slash")
						use_slash = room:askForUseSlashTo(p, player, "@f_xingyuan_bluck-slash:" .. player:objectName())
					end
					if use_slash then
						if player:hasFlag("f_xingyuan_bluckTarget") then
							room:setPlayerFlag(player, "-f_xingyuan_bluckTarget")
							room:sendCompulsoryTriggerLog(p, "f_xingyuan")
							room:broadcastSkillInvoke("f_xingyuan", 2)
							room:doLightbox("$to_CP_Bluck")
							local nullified_list = use.nullified_list
							for _, q in sgs.qlist(use.to) do
				    			table.insert(nullified_list, q:objectName())
							end
				    		use.nullified_list = nullified_list
				    		data:setValue(use)
							local last
							for _, pp in sgs.qlist(room:getOtherPlayers(p)) do
								if pp:getNextAlive():objectName() == p:objectName() then --找到上家
									last = pp
								end
							end
							for _, q in sgs.qlist(use.to) do
								if q:objectName() ~= last:objectName() then
									room:swapSeat(q, last)
								end
							end
							--解锁并转换为“蓝色妖姬”形态
							if not p:hasFlag("f_xingyuanNoRes") then room:setPlayerFlag(p, "f_xingyuanNoRes") end
							p:gainMark("@CP_Bluck_unlock", 1)
							local mhp = p:getMaxHp()
							local hp = p:getHp()
							room:changeHero(p, "CP_Bluck", false, false, false, true)
							if p:getMaxHp() ~= mhp then room:setPlayerProperty(p, "maxhp", sgs.QVariant(mhp)) end
							if p:getHp() ~= hp then room:setPlayerProperty(p, "hp", sgs.QVariant(hp)) end
							if p:isWounded() then room:recover(p, sgs.RecoverStruct(p)) end
						end
					end
					if p:hasFlag("f_xingyuan_bluck-slash") then room:setPlayerFlag(p, "-f_xingyuan_bluck-slash") end
				end
			end
		elseif event == sgs.DamageCaused then --判定蓝色妖姬
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and damage.from:objectName() == player:objectName()
			and player:hasFlag("f_xingyuan_bluck-slash") then
			room:setPlayerFlag(damage.to, "f_xingyuan_bluckTarget") end
		elseif event == sgs.Dying then --暴风赤红
			local dying = data:toDying()
			if dying.who:objectName() == player:objectName() and player:hasSkill("f_xingyuan")
			and player:getMark("@CP_CrimsonTyphoon_unlock") == 0 then
				room:sendCompulsoryTriggerLog(player, "f_xingyuan")
				room:broadcastSkillInvoke("f_xingyuan", 3)
				room:doLightbox("$to_CP_CrimsonTyphoon")
				room:getThread():delay(1000)
				if player:hasEquipArea(1) then player:throwEquipArea(1) end
				if player:hasEquipArea(2) then player:throwEquipArea(2) end
				if player:hasEquipArea(3) then player:throwEquipArea(3) end
				local maxhp = player:getMaxHp()
				local recover = math.min(3 - player:getHp(), maxhp - player:getHp())
				room:recover(player, sgs.RecoverStruct(player, nil, recover))
				local hc = player:getHandcardNum()
				local draw = maxhp - hc
				if draw > 0 then
					room:drawCards(player, draw, self:objectName())
				end
				--解锁并转换为“环太平洋·暴风赤红”形态
				player:gainMark("@CP_CrimsonTyphoon_unlock", 1)
				if not player:hasFlag("f_xingyuanNoRes") then room:setPlayerFlag(player, "f_xingyuanNoRes") end
				local mhp = player:getMaxHp()
				local hp = player:getHp()
				room:changeHero(player, "CP_CrimsonTyphoon", false, false, false, true)
				if player:getMaxHp() ~= mhp then room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) end
				if player:getHp() ~= hp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end
				if player:hasSkill("bfch_dlzp") and player:getMark("@fcXuLi") < player:getMark("fcXuLiMAX") then
					room:sendCompulsoryTriggerLog(player, "bfch_dlzp")
					player:gainMark("@fcXuLi")
				end
				player:gainAnExtraTurn()
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_xingyuanRes = sgs.CreateTriggerSkill{ --形态重置
	name = "f_xingyuanRes",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart, sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if (event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_RoundStart)
		or (event == sgs.DamageInflicted and damage.to:objectName() == player:objectName()) then
			if player:getGeneralName() ~= "f_CP" then
				local mhp = player:getMaxHp()
				local hp = player:getHp()
				room:changeHero(player, "f_CP", false, false, false, true)
				if player:getMaxHp() ~= mhp then room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) end
				if player:getHp() ~= hp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end
			end
			if player:hasEquipArea(4) and (player:getTreasure() == nil or not player:getTreasure():isKindOf("Fgoldenchelsea")) then
				if player:getTreasure() ~= nil then player:throwEquipArea(4) end --硬核替换
				player:obtainEquipArea(4)
				local cds = sgs.IntList()
				for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
					if sgs.Sanguosha:getEngineCard(id):isKindOf("Fgoldenchelsea") and room:getCardPlace(id) ~= sgs.Player_DrawPile then
						cds:append(id)
					end
				end
				if not cds:isEmpty() then
					room:shuffleIntoDrawPile(player, cds, self:objectName(), true)
					local cards, cards_copy = sgs.CardList(), sgs.CardList()
					for _, id in sgs.qlist(room:getDrawPile()) do
						local card = sgs.Sanguosha:getCard(id)
						if card:isKindOf("Fgoldenchelsea") then
							room:setTag("FGC_ID", sgs.QVariant(id))
							cards:append(card)
							cards_copy:append(card)
						end
					end
					if not cards:isEmpty() then
						local equipA
						while not equipA do
							if cards:isEmpty() then break end
							if not equipA then
								equipA = cards:at(math.random(0, cards:length() - 1))
								for _, card in sgs.qlist(cards_copy) do
									if card:getSubtype() == equipA:getSubtype() then
										cards:removeOne(card)
									end
								end
							end
						end
						if equipA then
							local Moves = sgs.CardsMoveList()
							local equip = equipA:getRealCard():toEquipCard()
							local equip_index = equip:location()
							if player:getEquip(equip_index) == nil and player:hasEquipArea(equip_index) then
								--将“黄金切尔西”置入装备区
								room:sendCompulsoryTriggerLog(player, self:objectName())
								sgs.Sanguosha:playAudioEffect("audio/card/common/_f_goldenchelsea.ogg", false)
								Moves:append(sgs.CardsMoveStruct(equipA:getId(), player, sgs.Player_PlaceEquip, sgs.CardMoveReason()))
							else
								Moves:append(sgs.CardsMoveStruct(equipA:getId(), player, sgs.Player_PlaceHand, sgs.CardMoveReason()))
							end
							room:moveCardsAtomic(Moves, true)
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_xingyuan") and not player:hasFlag("f_xingyuanNoRes")
	end,
}
f_CP:addSkill(f_xingyuan)
if not sgs.Sanguosha:getSkill("f_xingyuans") then skills:append(f_xingyuans) end
if not sgs.Sanguosha:getSkill("f_xingyuanRes") then skills:append(f_xingyuanRes) end
---
f_CP:addRelateSkill("red_jufeng")
---
f_CP:addRelateSkill("bluck_youya")
---
f_CP:addRelateSkill("bfch_xdlyz")
f_CP:addRelateSkill("bfch_dlzp")
f_CP:addRelateSkill("bfch_ldy")
---
f_huanxingCard = sgs.CreateSkillCard{
	name = "f_huanxingCard",
	target_fixed = true,
	mute = true,
	on_use = function(self, room, source, targets)
		local choices = {}
		local n = source:getHandcardNum() + source:getEquips():length()
		if source:getMark("@CP_Red_unlock") > 0 and n >= 2
		and source:getGeneralName() ~= "CP_Red" then
			table.insert(choices, "Red")
		end
		if source:getMark("@CP_Bluck_unlock") > 0 and n >= 2
		and source:getGeneralName() ~= "CP_Bluck" then
			table.insert(choices, "Bluck")
		end
		if source:getMark("@CP_CrimsonTyphoon_unlock") > 0 and source:getHandcardNum() >= 2 and source:getEquips():length() >= 1
		and source:getGeneralName() ~= "CP_CrimsonTyphoon" then
			table.insert(choices, "CrimsonTyphoon")
		end
		table.insert(choices, "cancel")
		local choice = room:askForChoice(source, "f_huanxing", table.concat(choices, "+"))
		if choice == "cancel" then
			room:addPlayerHistory(source, "#f_huanxingCard", -1)
			return
		end
		if choice == "Red" then
			room:askForUseCard(source, "@@f_huanxing_red", "@f_huanxing_red")
		elseif choice == "Bluck" then
			room:askForUseCard(source, "@@f_huanxing_bluck", "@f_huanxing_bluck")
		elseif choice == "CrimsonTyphoon" then
			room:askForUseCard(source, "@@f_huanxing_ct", "@f_huanxing_ct")
		end
	end,
}
f_huanxing = sgs.CreateZeroCardViewAsSkill{
	name = "f_huanxing",
	view_as = function()
		return f_huanxingCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_huanxingCard") and not player:isNude()
		and not (player:getMark("@CP_Red_unlock") == 0 and player:getMark("@CP_Bluck_unlock") == 0 and player:getMark("@CP_CrimsonTyphoon_unlock") == 0)
	end,
}
f_CP:addSkill(f_huanxing)
--转换为“红色风暴”形态
f_huanxing_redCard = sgs.CreateSkillCard{
	name = "f_huanxing_redCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("f_huanxing", 1)
		local mhp = source:getMaxHp()
		local hp = source:getHp()
		room:changeHero(source, "CP_Red", false, false, false, true)
		if source:getMaxHp() ~= mhp then room:setPlayerProperty(source, "maxhp", sgs.QVariant(mhp)) end
		if source:getHp() ~= hp then room:setPlayerProperty(source, "hp", sgs.QVariant(hp)) end
	end,
}
f_huanxing_red = sgs.CreateViewAsSkill{
	name = "f_huanxing_red",
	n = 2,
	view_filter = function(self, selected, to_select)
		if #selected == 0 then
			return to_select:isRed()
		elseif #selected == 1 then
			local card = selected[1]
			if to_select:isRed() then
				return true
			end
		else
			return false
		end
	end,
	view_as = function(self, cards)
		if #cards == 2 then
			local cardA = cards[1]
			local cardB = cards[2]
			local Red_card = f_huanxing_redCard:clone()
			Red_card:addSubcard(cardA)
			Red_card:addSubcard(cardB)
			Red_card:setSkillName(self:objectName())
			return Red_card
		end
	end,
	response_pattern = "@@f_huanxing_red",
}
if not sgs.Sanguosha:getSkill("f_huanxing_red") then skills:append(f_huanxing_red) end
--转换为“蓝色妖姬”形态
f_huanxing_bluckCard = sgs.CreateSkillCard{
	name = "f_huanxing_bluckCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("f_huanxing", 2)
		local mhp = source:getMaxHp()
		local hp = source:getHp()
		room:changeHero(source, "CP_Bluck", false, false, false, true)
		if source:getMaxHp() ~= mhp then room:setPlayerProperty(source, "maxhp", sgs.QVariant(mhp)) end
		if source:getHp() ~= hp then room:setPlayerProperty(source, "hp", sgs.QVariant(hp)) end
	end,
}
f_huanxing_bluck = sgs.CreateViewAsSkill{
	name = "f_huanxing_bluck",
	n = 2,
	view_filter = function(self, selected, to_select)
		if #selected == 0 then
			return to_select:isBlack()
		elseif #selected == 1 then
			local card = selected[1]
			if to_select:isBlack() then
				return true
			end
		else
			return false
		end
	end,
	view_as = function(self, cards)
		if #cards == 2 then
			local cardA = cards[1]
			local cardB = cards[2]
			local Bluck_card = f_huanxing_bluckCard:clone()
			Bluck_card:addSubcard(cardA)
			Bluck_card:addSubcard(cardB)
			Bluck_card:setSkillName(self:objectName())
			return Bluck_card
		end
	end,
	response_pattern = "@@f_huanxing_bluck",
}
if not sgs.Sanguosha:getSkill("f_huanxing_bluck") then skills:append(f_huanxing_bluck) end
--转换为“环太平洋·暴风赤红”形态
function GetColor(card)
	if card:isRed() then return "red" elseif card:isBlack() then return "black" end
end
f_huanxing_ctCard = sgs.CreateSkillCard{
	name = "f_huanxing_ctCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("f_huanxing", 3)
		local mhp = source:getMaxHp()
		local hp = source:getHp()
		room:changeHero(source, "CP_CrimsonTyphoon", false, false, false, true)
		if source:getMaxHp() ~= mhp then room:setPlayerProperty(source, "maxhp", sgs.QVariant(mhp)) end
		if source:getHp() ~= hp then room:setPlayerProperty(source, "hp", sgs.QVariant(hp)) end
		if source:hasSkill("bfch_dlzp") and source:getMark("@fcXuLi") < source:getMark("fcXuLiMAX") then
			--room:sendCompulsoryTriggerLog(source, "bfch_dlzp")
			source:gainMark("@fcXuLi")
		end
	end,
}
f_huanxing_ct = sgs.CreateViewAsSkill{
	name = "f_huanxing_ct",
	n = 3,
	view_filter = function(self, selected, to_select)
		if #selected == 0 then
			return not to_select:isEquipped()
		elseif #selected == 1 then
			local card = selected[1]
			if GetColor(to_select) ~= GetColor(card) then
				return not to_select:isEquipped()
			end
		elseif #selected == 2 then
			return to_select:isEquipped()
		else
			return false
		end
	end,
	view_as = function(self, cards)
		if #cards == 3 then
			local cardA = cards[1]
			local cardB = cards[2]
			local cardC = cards[3]
			local CT_card = f_huanxing_ctCard:clone()
			CT_card:addSubcard(cardA)
			CT_card:addSubcard(cardB)
			CT_card:addSubcard(cardC)
			CT_card:setSkillName(self:objectName())
			return CT_card
		end
	end,
	response_pattern = "@@f_huanxing_ct",
}
if not sgs.Sanguosha:getSkill("f_huanxing_ct") then skills:append(f_huanxing_ct) end

--==特殊形态1：红色风暴==--
CP_Red = sgs.General(extension, "CP_Red", "shu", 6, true, true, true, 3)

red_jufeng = sgs.CreateTargetModSkill{
	name = "red_jufeng",
	pattern = "BasicCard",
	residue_func = function(self, player, card)
		if player:hasSkill(self:objectName()) and card:isRed() then
			return 1000
		else
			return 0
		end
	end,
}
red_jufengBuff = sgs.CreateTriggerSkill{
	name = "red_jufengBuff",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage, sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.from and damage.card and damage.from:objectName() == player:objectName() and damage.card:isRed() and damage.card:isKindOf("TrickCard") then
				room:sendCompulsoryTriggerLog(player, "red_jufeng")
				room:broadcastSkillInvoke("red_jufeng")
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.from:objectName() == player:objectName() and use.card:isRed() and use.card:isKindOf("EquipCard") then
				room:sendCompulsoryTriggerLog(player, "red_jufeng")
				room:broadcastSkillInvoke("red_jufeng")
				room:drawCards(player, 1, "red_jufeng")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("red_jufeng")
	end,
}
CP_Red:addSkill("f_xingyuan")
CP_Red:addSkill("f_huanxing")
CP_Red:addSkill(red_jufeng)
if not sgs.Sanguosha:getSkill("red_jufengBuff") then skills:append(red_jufengBuff) end

--==特殊形态2：蓝色妖姬==--
CP_Bluck = sgs.General(extension, "CP_Bluck", "shu", 6, true, true, true, 3)

bluck_youya = sgs.CreateTargetModSkill{
	name = "bluck_youya",
	pattern = "BasicCard",
	distance_limit_func = function(self, player, card)
		if player:hasSkill(self:objectName()) and card:isBlack() then
			return 1000
		else
			return 0
		end
	end,
}
bluck_youyaBuff = sgs.CreateTriggerSkill{
	name = "bluck_youyaBuff",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified, sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.from:objectName() == player:objectName() and use.card:isBlack() and use.card:isKindOf("TrickCard") then
				local no_respond_list = use.no_respond_list
				for _, p in sgs.qlist(use.to) do
					room:sendCompulsoryTriggerLog(player, "bluck_youya")
					room:broadcastSkillInvoke("bluck_youya")
					table.insert(no_respond_list, p:objectName())
				end
				use.no_respond_list = no_respond_list
				data:setValue(use)
			end
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.from:objectName() == player:objectName() and use.card:isBlack() and use.card:isKindOf("EquipCard") then
				if player:isWounded() then
					room:sendCompulsoryTriggerLog(player, "bluck_youya")
					room:broadcastSkillInvoke("bluck_youya")
					room:recover(player, sgs.RecoverStruct(player))
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("bluck_youya")
	end,
}
CP_Bluck:addSkill("f_xingyuan")
CP_Bluck:addSkill("f_huanxing")
CP_Bluck:addSkill(bluck_youya)
if not sgs.Sanguosha:getSkill("bluck_youyaBuff") then skills:append(bluck_youyaBuff) end

--==特殊形态3：环太平洋·暴风赤红==--
CP_CrimsonTyphoon = sgs.General(extension, "CP_CrimsonTyphoon", "shu", 6, true, true, true, 3)

CP_CrimsonTyphoon:addSkill("f_xingyuan")
CP_CrimsonTyphoon:addSkill("f_huanxing")

bfch_xdlyzCard = sgs.CreateSkillCard{
	name = "bfch_xdlyzCard",
	target_fixed = false,
	mute = true,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and sgs.Self:canSlash(to_select, nil)
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local sh, choice = 0, room:askForChoice(effect.from, "bfch_xdlyz", "1+2+3")
		if choice == "1" then
			room:loseMaxHp(effect.from, 1)
			if effect.from:isAlive() then
				sh = 1
			end
		elseif choice == "2" then
			room:loseMaxHp(effect.from, 2)
			if effect.from:isAlive() then
				sh = 2
			end
		elseif choice == "3" then
			room:loseMaxHp(effect.from, 3)
			if effect.from:isAlive() then
				sh = 3
			end
		end
		room:broadcastSkillInvoke("bfch_xdlyzAMX")
		room:doLightbox("$ThunderCloudFormation", 9000)
		while sh > 0 and effect.from:isAlive() and effect.to:isAlive() do
			room:getThread():delay()
			local xdlyz = sgs.Sanguosha:cloneCard("thunder_slash", sgs.Card_NoSuit, 0)
			xdlyz:setSkillName("bfch_xdlyz")
			room:useCard(sgs.CardUseStruct(xdlyz, effect.from, effect.to), false)
			sh = sh - 1
		end
	end,
}
bfch_xdlyz = sgs.CreateZeroCardViewAsSkill{
	name = "bfch_xdlyz",
	view_as = function()
		return bfch_xdlyzCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#bfch_xdlyzCard")
	end,
}
bfch_xdlyzAMX = sgs.CreateTriggerSkill{
	name = "bfch_xdlyzAMX",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damage, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damage then
			local damage = data:toDamage()
			if damage.from and damage.from:objectName() == player:objectName() and player:hasSkill("bfch_xdlyz")
			and damage.card and damage.card:isKindOf("Slash") and damage.card:getSkillName() == "bfch_xdlyz" then
				room:addPlayerMark(player, "&bfch_xdlyz", damage.damage)
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Play then
				local n = player:getMark("&bfch_xdlyz")
				if n > 0 and player:hasSkill("bfch_xdlyz") then
					room:sendCompulsoryTriggerLog(player, "bfch_xdlyz")
					room:gainMaxHp(player, n, "bfch_xdlyz")
				end
				room:setPlayerMark(player, "&bfch_xdlyz", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
CP_CrimsonTyphoon:addSkill(bfch_xdlyz)
if not sgs.Sanguosha:getSkill("bfch_xdlyzAMX") then skills:append(bfch_xdlyzAMX) end

bfch_dlzpCard = sgs.CreateSkillCard{
	name = "bfch_dlzpCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local dlzp = effect.from:getMark("@fcXuLi")
		if dlzp > 3 then dlzp = 3 end
		local choices = {}
		for i = 1, dlzp do
			table.insert(choices, i)
		end
		local choice = room:askForChoice(effect.from, "bfch_dlzp", table.concat(choices, "+"))
		local n = tonumber(choice), 1
		effect.from:loseMark("@fcXuLi", n)
		if n > 1 then
			room:damage(sgs.DamageStruct("bfch_dlzp", effect.from, effect.to, n-1, sgs.DamageStruct_Thunder))
		end
		if effect.to:isAlive() and effect.to:faceUp() and math.random() <= n/3 then
			effect.to:turnOver()
		end
	end,
}
bfch_dlzp = sgs.CreateZeroCardViewAsSkill{
	name = "bfch_dlzp",
	view_as = function()
		return bfch_dlzpCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#bfch_dlzpCard") and player:getMark("@fcXuLi") > 0
	end,
}
bfch_dlzpXL = sgs.CreateTriggerSkill{
	name = "bfch_dlzpXL",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then return false end
		room:sendCompulsoryTriggerLog(player, "bfch_dlzp")
		player:gainMark("@fcXuLi", 1)
	end,
	can_trigger = function(self, player)
		return player:hasSkill("bfch_dlzp") and player:getMark("@fcXuLi") < player:getMark("fcXuLiMAX")
	end,
}
CP_CrimsonTyphoon:addSkill(bfch_dlzp)
if not sgs.Sanguosha:getSkill("bfch_dlzpXL") then skills:append(bfch_dlzpXL) end

bfch_ldyCard = sgs.CreateSkillCard{
	name = "bfch_ldyCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and sgs.Self:inMyAttackRange(to_select)
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		effect.from:throwAllHandCards()
		room:setPlayerFlag(effect.to, "bfch_ldyVictim")
		room:setPlayerCardLimitation(effect.to, "use,response", ".", false)
		room:damage(sgs.DamageStruct("bfch_ldy", effect.from, effect.to, 1, sgs.DamageStruct_Ice))
	end,
}
bfch_ldy = sgs.CreateZeroCardViewAsSkill{
	name = "bfch_ldy",
	view_as = function()
		return bfch_ldyCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#bfch_ldyCard") and not player:isKongcheng()
	end,
}
bfch_ldyClear = sgs.CreateTriggerSkill{
	name = "bfch_ldyClear",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("bfch_ldyVictim") then
				room:setPlayerFlag(p, "-bfch_ldyVictim")
				room:removePlayerCardLimitation(p, "use,response", ".")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getPhase() == sgs.Player_Play
	end,
}
CP_CrimsonTyphoon:addSkill(bfch_ldy)
if not sgs.Sanguosha:getSkill("bfch_ldyClear") then skills:append(bfch_ldyClear) end

--==特殊形态4：环太平洋·忧蓝罗密欧==--
--[[CP_RomeoBlue = sgs.General(extension, "CP_RomeoBlue", "?", ?, true, true, true, ?)
（此形态存档已于2020年丢失。）
----
]]

--==专属装备·黄金切尔西（宝物）==--
Fgoldenchelseas = sgs.CreateDistanceSkill{
	name = "Fgoldenchelseas",
	correct_func = function(self, from, to)
		if from:getTreasure() ~= nil and from:getTreasure():isKindOf("Fgoldenchelsea") then
			return -1
		else
			return 0
		end
	end,
}
Fgoldenchelseat = sgs.CreateDistanceSkill{
	name = "Fgoldenchelseat",
	correct_func = function(self, from, to)
		if to:getTreasure() ~= nil and to:getTreasure():isKindOf("Fgoldenchelsea") then
			return 1
		else
			return 0
		end
	end,
}
Fgoldenchelsea = sgs.CreateTreasure{
	name = "_f_goldenchelsea",
	class_name = "Fgoldenchelsea",
	target_fixed = false,
	on_install = function()
		--......
	end,
	on_uninstall = function()
		--......
		--销毁装备+失去体力的相关代码写在隐藏触发技“Fgoldenchelsea_remove”内。
	end,
}
Fgoldenchelsea:clone(sgs.Card_Diamond, 11):setParent(sdCard)
if not sgs.Sanguosha:getSkill("Fgoldenchelseas") then skills:append(Fgoldenchelseas) end
if not sgs.Sanguosha:getSkill("Fgoldenchelseat") then skills:append(Fgoldenchelseat) end
------

function destroyEquip(room, move, tag_name) --销毁装备
	local id = room:getTag(tag_name):toInt()
	if move.to_place == sgs.Player_DiscardPile and id > 0 and move.card_ids:contains(id) then
		local move1 = sgs.CardsMoveStruct(id, nil, nil, room:getCardPlace(id), sgs.Player_PlaceTable,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, "destroy_equip", ""))
		local card = sgs.Sanguosha:getCard(id)
		local log = sgs.LogMessage()
		log.type = "#DestroyEqiup"
		log.card_str = card:toString()
		room:sendLog(log)
		room:moveCardsAtomic(move1, true)
		room:removeTag(card:getClassName())
	end
end
Fgoldenchelsea_remove = sgs.CreateTriggerSkill{
	name = "Fgoldenchelsea_remove",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceEquip) then
			for _, id in sgs.qlist(move.card_ids) do
				local card = sgs.Sanguosha:getCard(id)
				if card:isKindOf("Fgoldenchelsea") then
					room:sendCompulsoryTriggerLog(player, "Fgoldenchelsea")
					--销毁
					destroyEquip(room, move, "FGC_ID")
					room:loseHp(player, 1)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("Fgoldenchelsea_remove") then skills:append(Fgoldenchelsea_remove) end

--SD2 004 宇宙丁真
f_UniverseYYDZ = sgs.General(extension, "f_UniverseYYDZ", "shu", 4, true)

f_yiyan = sgs.CreateTriggerSkill{
	name = "f_yiyan",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.PreCardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.from:objectName() == player:objectName() and use.card:isKindOf("SkillCard") and not player:hasFlag("f_dingzhengCollateral") then
			for _, dz in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if dz:isKongcheng() then continue end
				if room:askForDiscard(dz, self:objectName(), 1, 1, true, false, "@f_yiyan-invoke:" .. use.card:getSkillName()) then
					local choice = room:askForChoice(dz, self:objectName(), "yes+no+cancel")
					if choice == "cancel" then continue end
					room:sendCompulsoryTriggerLog(dz, self:objectName())
					room:addPlayerMark(player, self:objectName())
					if choice == "yes" then
						room:setEmotion(player, "no-question")
						room:broadcastSkillInvoke(self:objectName(), 1) --√
						room:drawCards(player, 2, self:objectName())
					elseif choice == "no" then
						room:setEmotion(player, "f_fake")
						room:broadcastSkillInvoke(self:objectName(), 2) --×
						--[[local nullified_list = use.nullified_list
						for _, p in sgs.qlist(use.to) do
				    		table.insert(nullified_list, p:objectName())
						end
				    	use.nullified_list = nullified_list
				    	data:setValue(use)]]
						room:askForDiscard(player, self:objectName(), 2, 2, false, true, "@f_yiyan-discard")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getMark(self:objectName()) == 0
	end,
}
f_UniverseYYDZ:addSkill(f_yiyan)

-----------------【借刀杀人】技能卡 -----------------
f_dingzhengCollateral = sgs.CreateOneCardViewAsSkill{
	name = "f_dingzhengCollateral",
	view_filter = function(self, card)
		return card:hasFlag("f_dingzhengCollateral")
	end,
	view_as = function(self, card)
		local ct_card = sgs.Sanguosha:cloneCard("collateral", card:getSuit(), card:getNumber())
		ct_card:addSubcard(card:getId())
		ct_card:setSkillName("f_dingzheng")
		return ct_card
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@f_dingzhengCollateral")
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengCollateral") then skills:append(f_dingzhengCollateral) end
------------------------------------------------------
f_dingzheng = sgs.CreateTriggerSkill{
	name = "f_dingzheng",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.CardFinished, sgs.TurnStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.CardUsed then
			if use.from:objectName() == player:objectName() and use.to:length() > 0 and use.card and not use.card:isVirtualCard() then
				for _, dz in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					if dz:isNude() or dz:getMark(self:objectName()) > 0 then continue end
					local card = room:askForDiscard(dz, self:objectName(), 1, 1, true, true, "@f_dingzheng-invoke")
					if card then
						room:sendCompulsoryTriggerLog(dz, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						room:addPlayerMark(dz, self:objectName())
						local YYDZ = dz:property("SkillDescriptionRecord_f_dingzheng"):toString():split("+")
						--第一选：基本牌/锦囊牌/装备牌
						local choices1 = {}
						table.insert(choices1, "Basic")
						table.insert(choices1, "Trick")
						if card:getNumber() == 1 or (card:getNumber() >= 11 and card:getNumber() <= 13) then --A,J,Q,K
							table.insert(choices1, "Equip")
						end
						table.insert(choices1, "cancel")
						local choice1 = room:askForChoice(dz, self:objectName(), table.concat(choices1, "+"))
						if choice1 == "cancel" then room:setPlayerMark(dz, self:objectName(), 0) continue end
						--<基本牌>
						if choice1 == "Basic" then
							room:setPlayerFlag(player, "f_dingzhengNoEquips")
							--第二选-1：杀/桃/火杀/雷杀/酒/冰杀(不包括[闪])
							local choices21 = {}
							if not table.contains(YYDZ, "slash") then
								table.insert(choices21, "slash")
							end
							if not table.contains(YYDZ, "peach") then
								table.insert(choices21, "peach")
							end
							if not table.contains(YYDZ, "fire_slash") then
								table.insert(choices21, "fire_slash")
							end
							if not table.contains(YYDZ, "thunder_slash") then
								table.insert(choices21, "thunder_slash")
							end
							if not table.contains(YYDZ, "analeptic") then
								table.insert(choices21, "analeptic")
							end
							if not table.contains(YYDZ, "ice_slash") then
								table.insert(choices21, "ice_slash")
							end
							table.insert(choices21, "cancel")
							local choice21 = room:askForChoice(dz, self:objectName(), table.concat(choices21, "+"))
							if choice21 == "cancel" then room:setPlayerMark(dz, self:objectName(), 0) continue end
							--【杀】
							if choice21 == "slash" then
								local log = sgs.LogMessage()
								log.type = "$udz_Slash"
								room:sendLog(log)
								local slash = sgs.Sanguosha:cloneCard("slash", use.card:getSuit(), use.card:getNumber())
								slash:addSubcard(use.card:getId())
								slash:setSkillName(self:objectName())
								room:useCard(sgs.CardUseStruct(slash, player, use.to), false)
								table.insert(YYDZ, "slash")
								room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
								room:changeTranslation(dz, "f_dingzheng", 11)
							--【桃】
							elseif choice21 == "peach" then
								local log = sgs.LogMessage()
								log.type = "$udz_Peach"
								room:sendLog(log)
								local peach = sgs.Sanguosha:cloneCard("peach", use.card:getSuit(), use.card:getNumber())
								peach:addSubcard(use.card:getId())
								peach:setSkillName(self:objectName())
								room:useCard(sgs.CardUseStruct(peach, player, use.to), false)
								table.insert(YYDZ, "peach")
								room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
								room:changeTranslation(dz, "f_dingzheng", 11)
							--【火杀】
							elseif choice21 == "fire_slash" then
								local log = sgs.LogMessage()
								log.type = "$udz_FireSlash"
								room:sendLog(log)
								local fire_slash = sgs.Sanguosha:cloneCard("fire_slash", use.card:getSuit(), use.card:getNumber())
								fire_slash:addSubcard(use.card:getId())
								fire_slash:setSkillName(self:objectName())
								room:useCard(sgs.CardUseStruct(fire_slash, player, use.to), false)
								table.insert(YYDZ, "fire_slash")
								room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
								room:changeTranslation(dz, "f_dingzheng", 11)
							--【雷杀】
							elseif choice21 == "thunder_slash" then
								local log = sgs.LogMessage()
								log.type = "$udz_ThunderSlash"
								room:sendLog(log)
								local thunder_slash = sgs.Sanguosha:cloneCard("thunder_slash", use.card:getSuit(), use.card:getNumber())
								thunder_slash:addSubcard(use.card:getId())
								thunder_slash:setSkillName(self:objectName())
								room:useCard(sgs.CardUseStruct(thunder_slash, player, use.to), false)
								table.insert(YYDZ, "thunder_slash")
								room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
								room:changeTranslation(dz, "f_dingzheng", 11)
							--【酒】
							elseif choice21 == "analeptic" then
								local log = sgs.LogMessage()
								log.type = "$udz_Analeptic"
								room:sendLog(log)
								local analeptic = sgs.Sanguosha:cloneCard("analeptic", use.card:getSuit(), use.card:getNumber())
								analeptic:addSubcard(use.card:getId())
								analeptic:setSkillName(self:objectName())
								room:useCard(sgs.CardUseStruct(analeptic, player, use.to), false)
								table.insert(YYDZ, "analeptic")
								room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
								room:changeTranslation(dz, "f_dingzheng", 11)
							--【冰杀】
							elseif choice21 == "ice_slash" then
								local log = sgs.LogMessage()
								log.type = "$udz_IceSlash"
								room:sendLog(log)
								local ice_slash = sgs.Sanguosha:cloneCard("ice_slash", use.card:getSuit(), use.card:getNumber())
								ice_slash:addSubcard(use.card:getId())
								ice_slash:setSkillName(self:objectName())
								room:useCard(sgs.CardUseStruct(ice_slash, player, use.to), false)
								table.insert(YYDZ, "ice_slash")
								room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
								room:changeTranslation(dz, "f_dingzheng", 11)
							end
						--<锦囊牌>
						elseif choice1 == "Trick" then
							room:setPlayerFlag(player, "f_dingzhengNoEquips")
							--第二选-2：标准包/军争篇+应变篇
							local choice22 = room:askForChoice(dz, self:objectName(), "Trick_BZ+Trick_JY+cancel")
							if choice22 == "cancel" then room:setPlayerMark(dz, self:objectName(), 0) continue end
							if choice22 == "Trick_BZ" then
								--第三选-1：过河拆桥/顺手牵羊/借刀杀人/无中生有/南蛮入侵/万箭齐发/五谷丰登/桃园结义/决斗/乐不思蜀/闪电(不包括[无懈可击])
								local choices31 = {}
								if not table.contains(YYDZ, "dismantlement") then
									table.insert(choices31, "dismantlement")
								end
								if not table.contains(YYDZ, "snatch") then
									table.insert(choices31, "snatch")
								end
								if not table.contains(YYDZ, "collateral") then
									table.insert(choices31, "collateral")
								end
								if not table.contains(YYDZ, "ex_nihilo") then
									table.insert(choices31, "ex_nihilo")
								end
								if not table.contains(YYDZ, "savage_assault") then
									table.insert(choices31, "savage_assault")
								end
								if not table.contains(YYDZ, "archery_attack") then
									table.insert(choices31, "archery_attack")
								end
								if not table.contains(YYDZ, "amazing_grace") then
									table.insert(choices31, "amazing_grace")
								end
								if not table.contains(YYDZ, "god_salvation") then
									table.insert(choices31, "god_salvation")
								end
								if not table.contains(YYDZ, "duel") then
									table.insert(choices31, "duel")
								end
								if not table.contains(YYDZ, "indulgence") then
									table.insert(choices31, "indulgence")
								end
								if not table.contains(YYDZ, "lightning") then
									table.insert(choices31, "lightning")
								end
								table.insert(choices31, "cancel")
								local choice31 = room:askForChoice(dz, self:objectName(), table.concat(choices31, "+"))
								if choice31 == "cancel" then room:setPlayerMark(dz, self:objectName(), 0) continue end
								--【过河拆桥】
								if choice31 == "dismantlement" then
									local log = sgs.LogMessage()
									log.type = "$udz_Dismantlement"
									room:sendLog(log)
									local useto = sgs.SPlayerList()
									for _, p in sgs.qlist(use.to) do
										if not p:isAllNude() then useto:append(p) end
									end
									if not useto:isEmpty() then
										local dismantlement = sgs.Sanguosha:cloneCard("dismantlement", use.card:getSuit(), use.card:getNumber())
										dismantlement:addSubcard(use.card:getId())
										dismantlement:setSkillName(self:objectName())
										room:useCard(sgs.CardUseStruct(dismantlement, player, useto), false)
									end
									table.insert(YYDZ, "dismantlement")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【顺手牵羊】
								elseif choice31 == "snatch" then
									local log = sgs.LogMessage()
									log.type = "$udz_Snatch"
									room:sendLog(log)
									local useto = sgs.SPlayerList()
									for _, p in sgs.qlist(use.to) do
										if not p:isAllNude() then useto:append(p) end
									end
									if not useto:isEmpty() then
										local snatch = sgs.Sanguosha:cloneCard("snatch", use.card:getSuit(), use.card:getNumber())
										snatch:addSubcard(use.card:getId())
										snatch:setSkillName(self:objectName())
										room:useCard(sgs.CardUseStruct(snatch, player, useto), false)
									end
									table.insert(YYDZ, "snatch")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【借刀杀人】
								elseif choice31 == "collateral" then
									local log = sgs.LogMessage()
									log.type = "$udz_Collateral"
									room:sendLog(log)
									local can_jd = false
									for _, p in sgs.qlist(room:getOtherPlayers(player)) do
										if p:getWeapon() ~= nil then
											can_jd = true
										end
									end
									if can_jd then
										room:obtainCard(player, use.card)
										room:setPlayerFlag(player, "f_dingzhengCollateral")
										room:setCardFlag(use.card, "f_dingzhengCollateral")
										room:askForUseCard(player, "@@f_dingzhengCollateral!", "@f_dingzhengCollateral-card")
										room:setPlayerFlag(player, "-f_dingzhengCollateral")
										room:setCardFlag(use.card, "-f_dingzhengCollateral")
									end
									table.insert(YYDZ, "collateral")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【无中生有】
								elseif choice31 == "ex_nihilo" then
									local log = sgs.LogMessage()
									log.type = "$udz_ExNihilo"
									room:sendLog(log)
									local ex_nihilo = sgs.Sanguosha:cloneCard("ex_nihilo", use.card:getSuit(), use.card:getNumber())
									ex_nihilo:addSubcard(use.card:getId())
									ex_nihilo:setSkillName(self:objectName())
									room:useCard(sgs.CardUseStruct(ex_nihilo, player, use.to), false)
									table.insert(YYDZ, "ex_nihilo")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【南蛮入侵】
								elseif choice31 == "savage_assault" then
									local log = sgs.LogMessage()
									log.type = "$udz_SavageAssault"
									room:sendLog(log)
									local savage_assault = sgs.Sanguosha:cloneCard("savage_assault", use.card:getSuit(), use.card:getNumber())
									savage_assault:addSubcard(use.card:getId())
									savage_assault:setSkillName(self:objectName())
									room:useCard(sgs.CardUseStruct(savage_assault, player, use.to), false)
									table.insert(YYDZ, "savage_assault")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【万箭齐发】
								elseif choice31 == "archery_attack" then
									local log = sgs.LogMessage()
									log.type = "$udz_ArcheryAttack"
									room:sendLog(log)
									local archery_attack = sgs.Sanguosha:cloneCard("archery_attack", use.card:getSuit(), use.card:getNumber())
									archery_attack:addSubcard(use.card:getId())
									archery_attack:setSkillName(self:objectName())
									room:useCard(sgs.CardUseStruct(archery_attack, player, use.to), false)
									table.insert(YYDZ, "archery_attack")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【五谷丰登】
								elseif choice31 == "amazing_grace" then
									local log = sgs.LogMessage()
									log.type = "$udz_AmazingGrace"
									room:sendLog(log)
									local amazing_grace = sgs.Sanguosha:cloneCard("amazing_grace", use.card:getSuit(), use.card:getNumber())
									amazing_grace:addSubcard(use.card:getId())
									amazing_grace:setSkillName(self:objectName())
									room:useCard(sgs.CardUseStruct(amazing_grace, player, use.to), false)
									table.insert(YYDZ, "amazing_grace")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【桃园结义】
								elseif choice31 == "god_salvation" then
									local log = sgs.LogMessage()
									log.type = "$udz_GodSalvation"
									room:sendLog(log)
									local god_salvation = sgs.Sanguosha:cloneCard("god_salvation", use.card:getSuit(), use.card:getNumber())
									god_salvation:addSubcard(use.card:getId())
									god_salvation:setSkillName(self:objectName())
									room:useCard(sgs.CardUseStruct(god_salvation, player, use.to), false)
									table.insert(YYDZ, "god_salvation")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【决斗】
								elseif choice31 == "duel" then
									local log = sgs.LogMessage()
									log.type = "$udz_Duel"
									room:sendLog(log)
									local duel = sgs.Sanguosha:cloneCard("duel", use.card:getSuit(), use.card:getNumber())
									duel:addSubcard(use.card:getId())
									duel:setSkillName(self:objectName())
									room:useCard(sgs.CardUseStruct(duel, player, use.to), false)
									table.insert(YYDZ, "duel")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【乐不思蜀】
								elseif choice31 == "indulgence" then
									local log = sgs.LogMessage()
									log.type = "$udz_Indulgence"
									room:sendLog(log)
									local useto = sgs.SPlayerList()
									for _, p in sgs.qlist(use.to) do
										if p:hasJudgeArea() then
											local n = 0
											for _, c in sgs.qlist(p:getJudgingArea()) do
												if c:isKindOf("Indulgence") then n = n + 1 end
											end
											if n > 0 then continue
											else useto:append(p) end
										end
									end
									if not useto:isEmpty() then
										local tos = {}
										for _, p in sgs.qlist(useto) do
											table.insert(tos, p)
										end
										local to = tos[math.random(1, #tos)]
										room:setPlayerFlag(player, "f_dingzhengIDGsource")
										room:setPlayerFlag(to, "f_dingzhengIDGtarget")
									end
									table.insert(YYDZ, "indulgence")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【闪电】
								elseif choice31 == "lightning" then
									local log = sgs.LogMessage()
									log.type = "$udz_Lightning"
									room:sendLog(log)
									local useto = sgs.SPlayerList()
									for _, p in sgs.qlist(use.to) do
										if p:hasJudgeArea() then
											local n = 0
											for _, c in sgs.qlist(p:getJudgingArea()) do
												if c:isKindOf("Lightning") then n = n + 1 end
											end
											if n > 0 then continue
											else useto:append(p) end
										end
									end
									if not useto:isEmpty() then
										local tos = {}
										for _, p in sgs.qlist(useto) do
											table.insert(tos, p)
										end
										local to = tos[math.random(1, #tos)]
										room:setPlayerFlag(player, "f_dingzhengLTNsource")
										room:setPlayerFlag(to, "f_dingzhengLTNtarget")
									end
									table.insert(YYDZ, "lightning")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								end
							elseif choice22 == "Trick_JY" then
								--第三选-2：铁索连环/火攻/兵粮寸断/水淹七军/洞烛先机/逐近弃远/出其不意(不包括[随机应变])
								local choices32 = {}
								if not table.contains(YYDZ, "iron_chain") then
									table.insert(choices32, "iron_chain")
								end
								if not table.contains(YYDZ, "fire_attack") then
									table.insert(choices32, "fire_attack")
								end
								if not table.contains(YYDZ, "supply_shortage") then
									table.insert(choices32, "supply_shortage")
								end
								if not table.contains(YYDZ, "drowning") then
									table.insert(choices32, "drowning")
								end
								if not table.contains(YYDZ, "dongzhuxianji") then
									table.insert(choices32, "dongzhuxianji")
								end
								if not table.contains(YYDZ, "zhujinqiyuan") then
									table.insert(choices32, "zhujinqiyuan")
								end
								if not table.contains(YYDZ, "chuqibuyi") then
									table.insert(choices32, "chuqibuyi")
								end
								table.insert(choices32, "cancel")
								local choice32 = room:askForChoice(dz, self:objectName(), table.concat(choices32, "+"))
								if choice32 == "cancel" then room:setPlayerMark(dz, self:objectName(), 0) continue end
								--【铁索连环】
								if choice32 == "iron_chain" then
									local log = sgs.LogMessage()
									log.type = "$udz_IronChain"
									room:sendLog(log)
									local iron_chain = sgs.Sanguosha:cloneCard("iron_chain", use.card:getSuit(), use.card:getNumber())
									iron_chain:addSubcard(use.card:getId())
									iron_chain:setSkillName(self:objectName())
									room:useCard(sgs.CardUseStruct(iron_chain, player, use.to), false)
									table.insert(YYDZ, "iron_chain")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【火攻】
								elseif choice32 == "fire_attack" then
									local log = sgs.LogMessage()
									log.type = "$udz_FireAttack"
									room:sendLog(log)
									local useto = sgs.SPlayerList()
									for _, p in sgs.qlist(use.to) do
										if not p:isKongcheng() then useto:append(p) end
									end
									if not useto:isEmpty() then
										local fire_attack = sgs.Sanguosha:cloneCard("fire_attack", use.card:getSuit(), use.card:getNumber())
										fire_attack:addSubcard(use.card:getId())
										fire_attack:setSkillName(self:objectName())
										room:useCard(sgs.CardUseStruct(fire_attack, player, useto), false)
									end
									table.insert(YYDZ, "fire_attack")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【兵粮寸断】
								elseif choice32 == "supply_shortage" then
									local log = sgs.LogMessage()
									log.type = "$udz_SupplyShortage"
									room:sendLog(log)
									local useto = sgs.SPlayerList()
									for _, p in sgs.qlist(use.to) do
										if p:hasJudgeArea() then
											local n = 0
											for _, c in sgs.qlist(p:getJudgingArea()) do
												if c:isKindOf("SupplyShortage") then n = n + 1 end
											end
											if n > 0 then continue
											else useto:append(p) end
										end
									end
									if not useto:isEmpty() then
										local tos = {}
										for _, p in sgs.qlist(useto) do
											table.insert(tos, p)
										end
										local to = tos[math.random(1, #tos)]
										room:setPlayerFlag(player, "f_dingzhengSSsource")
										room:setPlayerFlag(to, "f_dingzhengSStarget")
									end
									table.insert(YYDZ, "supply_shortage")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【水淹七军】
								elseif choice32 == "drowning" then
									local log = sgs.LogMessage()
									log.type = "$udz_Drowning"
									room:sendLog(log)
									local drowning = sgs.Sanguosha:cloneCard("drowning", use.card:getSuit(), use.card:getNumber())
									drowning:addSubcard(use.card:getId())
									drowning:setSkillName(self:objectName())
									room:useCard(sgs.CardUseStruct(drowning, player, use.to), false)
									table.insert(YYDZ, "drowning")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【洞烛先机】
								elseif choice32 == "dongzhuxianji" then
									local log = sgs.LogMessage()
									log.type = "$udz_Dongzhuxianji"
									room:sendLog(log)
									local dongzhuxianji = sgs.Sanguosha:cloneCard("dongzhuxianji", use.card:getSuit(), use.card:getNumber())
									dongzhuxianji:addSubcard(use.card:getId())
									dongzhuxianji:setSkillName(self:objectName())
									room:useCard(sgs.CardUseStruct(dongzhuxianji, player, use.to), false)
									table.insert(YYDZ, "dongzhuxianji")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【逐近弃远】
								elseif choice32 == "zhujinqiyuan" then
									local log = sgs.LogMessage()
									log.type = "$udz_Zhujinqiyuan"
									room:sendLog(log)
									local useto = sgs.SPlayerList()
									for _, p in sgs.qlist(use.to) do
										if not p:isAllNude() then useto:append(p) end
									end
									if not useto:isEmpty() then
										local zhujinqiyuan = sgs.Sanguosha:cloneCard("zhujinqiyuan", use.card:getSuit(), use.card:getNumber())
										zhujinqiyuan:addSubcard(use.card:getId())
										zhujinqiyuan:setSkillName(self:objectName())
										room:useCard(sgs.CardUseStruct(zhujinqiyuan, player, useto), false)
									end
									table.insert(YYDZ, "zhujinqiyuan")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【出其不意】
								elseif choice32 == "chuqibuyi" then
									local log = sgs.LogMessage()
									log.type = "$udz_Chuqibuyi"
									room:sendLog(log)
									local useto = sgs.SPlayerList()
									for _, p in sgs.qlist(use.to) do
										if not p:isKongcheng() then useto:append(p) end
									end
									if not useto:isEmpty() then
										local chuqibuyi = sgs.Sanguosha:cloneCard("chuqibuyi", use.card:getSuit(), use.card:getNumber())
										chuqibuyi:addSubcard(use.card:getId())
										chuqibuyi:setSkillName(self:objectName())
										room:useCard(sgs.CardUseStruct(chuqibuyi, player, useto), false)
									end
									table.insert(YYDZ, "chuqibuyi")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								end
							end
						--<装备牌>
						elseif choice1 == "Equip" then
							--第二选-3：武器牌/防具牌/+1马牌/-1马牌/宝物牌
							local choice23 = room:askForChoice(dz, self:objectName(), "Equip_Weapon+Equip_Armor+Equip_Defen+Equip_Offen+Equip_Treasure+cancel")
							if choice23 == "cancel" then room:setPlayerMark(dz, self:objectName(), 0) continue end
							if choice23 == "Equip_Weapon" then
								--第三选-3：诸葛连弩/青釭剑/雌雄双股剑/寒冰剑/青龙偃月刀/丈八蛇矛/贯石斧/方天画戟/麒麟弓/古锭刀/朱雀羽扇/乌铁锁链/五行鹤翎扇
								local choices33 = {}
								if not table.contains(YYDZ, "crossbow") then
									table.insert(choices33, "crossbow")
								end
								if not table.contains(YYDZ, "qinggang_sword") then
									table.insert(choices33, "qinggang_sword")
								end
								if not table.contains(YYDZ, "double_sword") then
									table.insert(choices33, "double_sword")
								end
								if not table.contains(YYDZ, "ice_sword") then
									table.insert(choices33, "ice_sword")
								end
								if not table.contains(YYDZ, "blade") then
									table.insert(choices33, "blade")
								end
								if not table.contains(YYDZ, "spear") then
									table.insert(choices33, "spear")
								end
								if not table.contains(YYDZ, "axe") then
									table.insert(choices33, "axe")
								end
								if not table.contains(YYDZ, "halberd") then
									table.insert(choices33, "halberd")
								end
								if not table.contains(YYDZ, "kylin_bow") then
									table.insert(choices33, "kylin_bow")
								end
								if not table.contains(YYDZ, "guding_blade") then
									table.insert(choices33, "guding_blade")
								end
								if not table.contains(YYDZ, "fan") then
									table.insert(choices33, "fan")
								end
								if not table.contains(YYDZ, "wutiesuolian") then
									table.insert(choices33, "wutiesuolian")
								end
								if not table.contains(YYDZ, "wuxinghelingshan") then
									table.insert(choices33, "wuxinghelingshan")
								end
								table.insert(choices33, "cancel")
								local choice33 = room:askForChoice(dz, self:objectName(), table.concat(choices33, "+"))
								if choice33 == "cancel" then room:setPlayerMark(dz, self:objectName(), 0) continue end
								--【诸葛连弩】
								if choice33 == "crossbow" then
									local log = sgs.LogMessage()
									log.type = "$udz_Crossbow"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengCrossbow")
									table.insert(YYDZ, "crossbow")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【青釭剑】
								elseif choice33 == "qinggang_sword" then
									local log = sgs.LogMessage()
									log.type = "$udz_QinggangSword"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengQinggangSword")
									table.insert(YYDZ, "qinggang_sword")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【雌雄双股剑】
								elseif choice33 == "double_sword" then
									local log = sgs.LogMessage()
									log.type = "$udz_DoubleSword"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengDoubleSword")
									table.insert(YYDZ, "double_sword")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【寒冰剑】
								elseif choice33 == "ice_sword" then
									local log = sgs.LogMessage()
									log.type = "$udz_IceSword"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengIceSword")
									table.insert(YYDZ, "ice_sword")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【青龙偃月刀】
								elseif choice33 == "blade" then
									local log = sgs.LogMessage()
									log.type = "$udz_Blade"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengBlade")
									table.insert(YYDZ, "blade")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【丈八蛇矛】
								elseif choice33 == "spear" then
									local log = sgs.LogMessage()
									log.type = "$udz_Spear"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengSpear")
									table.insert(YYDZ, "spear")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【贯石斧】
								elseif choice33 == "axe" then
									local log = sgs.LogMessage()
									log.type = "$udz_Axe"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengAxe")
									table.insert(YYDZ, "axe")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【方天画戟】
								elseif choice33 == "halberd" then
									local log = sgs.LogMessage()
									log.type = "$udz_Halberd"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengHalberd")
									table.insert(YYDZ, "halberd")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【麒麟弓】
								elseif choice33 == "kylin_bow" then
									local log = sgs.LogMessage()
									log.type = "$udz_KylinBow"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengKylinBow")
									table.insert(YYDZ, "kylin_bow")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【古锭刀】
								elseif choice33 == "guding_blade" then
									local log = sgs.LogMessage()
									log.type = "$udz_GudingBlade"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengGudingBlade")
									table.insert(YYDZ, "guding_blade")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【朱雀羽扇】
								elseif choice33 == "fan" then
									local log = sgs.LogMessage()
									log.type = "$udz_Fan"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengFan")
									table.insert(YYDZ, "fan")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【乌铁锁链】
								elseif choice33 == "wutiesuolian" then
									local log = sgs.LogMessage()
									log.type = "$udz_Wutiesuolian"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengWutiesuolian")
									table.insert(YYDZ, "wutiesuolian")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【五行鹤翎扇】
								elseif choice33 == "wuxinghelingshan" then
									local log = sgs.LogMessage()
									log.type = "$udz_Wuxinghelingshan"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengWuxinghelingshan")
									table.insert(YYDZ, "wuxinghelingshan")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								end
							elseif choice23 == "Equip_Armor" then
								--第三选-4：八卦阵/仁王盾/藤甲/白银狮子/黑光铠/护心镜
								local choices34 = {}
								if not table.contains(YYDZ, "eight_diagram") then
									table.insert(choices34, "eight_diagram")
								end
								if not table.contains(YYDZ, "renwang_shield") then
									table.insert(choices34, "renwang_shield")
								end
								if not table.contains(YYDZ, "vine") then
									table.insert(choices34, "vine")
								end
								if not table.contains(YYDZ, "silver_lion") then
									table.insert(choices34, "silver_lion")
								end
								if not table.contains(YYDZ, "heiguangkai") then
									table.insert(choices34, "heiguangkai")
								end
								if not table.contains(YYDZ, "huxinjing") then
									table.insert(choices34, "huxinjing")
								end
								table.insert(choices34, "cancel")
								local choice34 = room:askForChoice(dz, self:objectName(), table.concat(choices34, "+"))
								if choice34 == "cancel" then room:setPlayerMark(dz, self:objectName(), 0) continue end
								--【八卦阵】
								if choice34 == "eight_diagram" then
									local log = sgs.LogMessage()
									log.type = "$udz_EightDiagram"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengEightDiagram")
									table.insert(YYDZ, "eight_diagram")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【仁王盾】
								elseif choice34 == "renwang_shield" then
									local log = sgs.LogMessage()
									log.type = "$udz_RenwangShield"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengRenwangShield")
									table.insert(YYDZ, "renwang_shield")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【藤甲】
								elseif choice34 == "vine" then
									local log = sgs.LogMessage()
									log.type = "$udz_Vine"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengVine")
									table.insert(YYDZ, "vine")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【白银狮子】
								elseif choice34 == "silver_lion" then
									local log = sgs.LogMessage()
									log.type = "$udz_SilverLion"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengSilverLion")
									table.insert(YYDZ, "silver_lion")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【黑光铠】
								elseif choice34 == "heiguangkai" then
									local log = sgs.LogMessage()
									log.type = "$udz_Heiguangkai"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengHeiguangkai")
									table.insert(YYDZ, "heiguangkai")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【护心镜】
								elseif choice34 == "huxinjing" then
									local log = sgs.LogMessage()
									log.type = "$udz_Huxinjing"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengHuxinjing")
									table.insert(YYDZ, "huxinjing")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								end
							elseif choice23 == "Equip_Defen" then
								--第三选-5：的卢/绝影/爪黄飞电/骅骝
								local choices35 = {}
								if not table.contains(YYDZ, "dilu") then
									table.insert(choices35, "dilu")
								end
								if not table.contains(YYDZ, "jueying") then
									table.insert(choices35, "jueying")
								end
								if not table.contains(YYDZ, "zhuahuangfeidian") then
									table.insert(choices35, "zhuahuangfeidian")
								end
								if not table.contains(YYDZ, "hualiu") then
									table.insert(choices35, "hualiu")
								end
								table.insert(choices35, "cancel")
								local choice35 = room:askForChoice(dz, self:objectName(), table.concat(choices35, "+"))
								if choice35 == "cancel" then room:setPlayerMark(dz, self:objectName(), 0) continue end
								--【的卢】
								if choice35 == "dilu" then
									local log = sgs.LogMessage()
									log.type = "$udz_Dilu"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengDilu")
									table.insert(YYDZ, "dilu")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【绝影】
								elseif choice35 == "jueying" then
									local log = sgs.LogMessage()
									log.type = "$udz_Jueying"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengJueying")
									table.insert(YYDZ, "jueying")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【爪黄飞电】
								elseif choice35 == "zhuahuangfeidian" then
									local log = sgs.LogMessage()
									log.type = "$udz_Zhuahuangfeidian"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengZhuahuangfeidian")
									table.insert(YYDZ, "zhuahuangfeidian")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【骅骝】
								elseif choice35 == "hualiu" then
									local log = sgs.LogMessage()
									log.type = "$udz_Hualiu"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengHualiu")
									table.insert(YYDZ, "hualiu")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								end
							elseif choice23 == "Equip_Offen" then
								--第三选-6：赤兔/大宛/紫骍
								local choices36 = {}
								if not table.contains(YYDZ, "chitu") then
									table.insert(choices36, "chitu")
								end
								if not table.contains(YYDZ, "dayuan") then
									table.insert(choices36, "dayuan")
								end
								if not table.contains(YYDZ, "zixing") then
									table.insert(choices36, "zixing")
								end
								table.insert(choices36, "cancel")
								local choice36 = room:askForChoice(dz, self:objectName(), table.concat(choices36, "+"))
								if choice36 == "cancel" then room:setPlayerMark(dz, self:objectName(), 0) continue end
								--【赤兔】
								if choice36 == "chitu" then
									local log = sgs.LogMessage()
									log.type = "$udz_Chitu"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengChitu")
									table.insert(YYDZ, "chitu")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【大宛】
								elseif choice36 == "dayuan" then
									local log = sgs.LogMessage()
									log.type = "$udz_Dayuan"
									room:sendLog(log)
									room:acquireSkill(player,  "f_dingzhengDayuan")
									table.insert(YYDZ, "dayuan")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【紫骍】
								elseif choice36 == "zixing" then
									local log = sgs.LogMessage()
									log.type = "$udz_Zixing"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengZixing")
									table.insert(YYDZ, "zixing")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								end
							elseif choice23 == "Equip_Treasure" then
								--第三选-7：木牛流马/天机图/太公阴符/铜雀
								local choices37 = {}
								if not table.contains(YYDZ, "wooden_ox") then
									table.insert(choices37, "wooden_ox")
								end
								if not table.contains(YYDZ, "tianjitu") then
									table.insert(choices37, "tianjitu")
								end
								if not table.contains(YYDZ, "taigongyinfu") then
									table.insert(choices37, "taigongyinfu")
								end
								if not table.contains(YYDZ, "tongque") then
									table.insert(choices37, "tongque")
								end
								table.insert(choices37, "cancel")
								local choice37 = room:askForChoice(dz, self:objectName(), table.concat(choices37, "+"))
								if choice37 == "cancel" then room:setPlayerMark(dz, self:objectName(), 0) continue end
								--【木牛流马】
								if choice37 == "wooden_ox" then
									local log = sgs.LogMessage()
									log.type = "$udz_WoodenOx"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengWoodenOx")
									table.insert(YYDZ, "wooden_ox")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【天机图】
								elseif choice37 == "tianjitu" then
									local log = sgs.LogMessage()
									log.type = "$udz_Tianjitu"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengTianjitu")
									table.insert(YYDZ, "tianjitu")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【太公阴符】
								elseif choice37 == "taigongyinfu" then
									local log = sgs.LogMessage()
									log.type = "$udz_Taigongyinfu"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengTaigongyinfu")
									table.insert(YYDZ, "taigongyinfu")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								--【铜雀】
								elseif choice37 == "tongque" then
									local log = sgs.LogMessage()
									log.type = "$udz_Tongque"
									room:sendLog(log)
									room:acquireSkill(player, "f_dingzhengTongque")
									table.insert(YYDZ, "tongque")
									room:setPlayerProperty(dz, "SkillDescriptionRecord_f_dingzheng", sgs.QVariant(table.concat(YYDZ, "+")))
									room:changeTranslation(dz, "f_dingzheng", 11)
								end
							end
						end
						if dz:getMark(self:objectName()) > 0 and not player:hasFlag("f_dingzhengWWJDTarget") then
							room:setPlayerFlag(player, "f_dingzhengWWJDTarget")
						end
					end
				end
				if player:hasFlag("f_dingzhengWWJDTarget") then
					room:setPlayerFlag(player, "-f_dingzhengWWJDTarget")
					if use.card:isKindOf("EquipCard") and not player:hasFlag("f_dingzhengNoEquips") then  --无效代码对装备牌没用，需要手动丢入弃牌堆
						room:throwCard(use.card, nil, player)
					else
						local nullified_list = use.nullified_list
						for _, p in sgs.qlist(use.to) do
							table.insert(nullified_list, p:objectName())
						end
						use.nullified_list = nullified_list
						data:setValue(use)
					end
					if player:hasFlag("f_dingzhengNoEquips") then
					room:setPlayerFlag(player, "-f_dingzhengNoEquips") end
				end
			end
		elseif event == sgs.CardFinished then --使用延时锦囊
			local IDGuf, IDGut, LTNuf, LTNut, SSuf, SSut = nil, nil, nil, nil, nil, nil
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("f_dingzhengIDGsource") then
					room:setPlayerFlag(p, "-f_dingzhengIDGsource")
					IDGuf = p
				end
				if p:hasFlag("f_dingzhengIDGtarget") then
					room:setPlayerFlag(p, "-f_dingzhengIDGtarget")
					IDGut = p
				end
				---
				if p:hasFlag("f_dingzhengLTNsource") then
					room:setPlayerFlag(p, "-f_dingzhengLTNsource")
					LTNuf = p
				end
				if p:hasFlag("f_dingzhengLTNtarget") then
					room:setPlayerFlag(p, "-f_dingzhengLTNtarget")
					LTNut = p
				end
				---
				if p:hasFlag("f_dingzhengSSsource") then
					room:setPlayerFlag(p, "-f_dingzhengSSsource")
					SSuf = p
				end
				if p:hasFlag("f_dingzhengSStarget") then
					room:setPlayerFlag(p, "-f_dingzhengSStarget")
					SSut = p
				end
			end
			if IDGuf and IDGut then
				local indulgence = sgs.Sanguosha:cloneCard("indulgence", use.card:getSuit(), use.card:getNumber())
				indulgence:addSubcard(use.card:getId())
				indulgence:setSkillName(self:objectName())
				room:useCard(sgs.CardUseStruct(indulgence, IDGuf, IDGut), false)
			elseif LTNuf and LTNut then
				local lightning = sgs.Sanguosha:cloneCard("lightning", use.card:getSuit(), use.card:getNumber())
				lightning:addSubcard(use.card:getId())
				lightning:setSkillName(self:objectName())
				room:useCard(sgs.CardUseStruct(lightning, LTNuf, LTNut), false)
			elseif SSuf and SSut then
				local supply_shortage = sgs.Sanguosha:cloneCard("supply_shortage", use.card:getSuit(), use.card:getNumber())
				supply_shortage:addSubcard(use.card:getId())
				supply_shortage:setSkillName(self:objectName())
				room:useCard(sgs.CardUseStruct(supply_shortage, SSuf, SSut), false)
			end
			for _, p in sgs.qlist(room:getAllPlayers()) do --确保万无一失
				if p:hasFlag("f_dingzhengIDGsource") then
					room:setPlayerFlag(p, "-f_dingzhengIDGsource")
				end
				if p:hasFlag("f_dingzhengIDGtarget") then
					room:setPlayerFlag(p, "-f_dingzhengIDGtarget")
				end
				---
				if p:hasFlag("f_dingzhengLTNsource") then
					room:setPlayerFlag(p, "-f_dingzhengLTNsource")
				end
				if p:hasFlag("f_dingzhengLTNtarget") then
					room:setPlayerFlag(p, "-f_dingzhengLTNtarget")
				end
				---
				if p:hasFlag("f_dingzhengSSsource") then
					room:setPlayerFlag(p, "-f_dingzhengSSsource")
				end
				if p:hasFlag("f_dingzhengSStarget") then
					room:setPlayerFlag(p, "-f_dingzhengSStarget")
				end
			end
		elseif event == sgs.TurnStart then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, self:objectName(), 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_dingzhengg = sgs.CreateTargetModSkill{
	name = "f_dingzhengg",
	pattern = "Card",
	distance_limit_func = function(self, dz, card)
		if card:getSkillName() == "f_dingzheng" and not card:isKindOf("SkillCard") then
			return 1000
		else
			return 0
		end
	end,
}
f_UniverseYYDZ:addSkill(f_dingzheng)
if not sgs.Sanguosha:getSkill("f_dingzhengg") then skills:append(f_dingzhengg) end
--==视为装备==--
--武器牌
f_dingzhengCrossbow = sgs.CreateViewAsEquipSkill{ --诸葛连弩
	name = "f_dingzhengCrossbow",
	view_as_equip = function(self, player)
		return "crossbow"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengCrossbow") then skills:append(f_dingzhengCrossbow) end
f_dingzhengQinggangSword = sgs.CreateViewAsEquipSkill{ --青釭剑
	name = "f_dingzhengQinggangSword",
	view_as_equip = function(self, player)
		return "qinggang_sword"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengQinggangSword") then skills:append(f_dingzhengQinggangSword) end
f_dingzhengDoubleSword = sgs.CreateViewAsEquipSkill{ --雌雄双股剑
	name = "f_dingzhengDoubleSword",
	view_as_equip = function(self, player)
		return "double_sword"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengDoubleSword") then skills:append(f_dingzhengDoubleSword) end
f_dingzhengIceSword = sgs.CreateViewAsEquipSkill{ --寒冰剑
	name = "f_dingzhengIceSword",
	view_as_equip = function(self, player)
		return "ice_sword"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengIceSword") then skills:append(f_dingzhengIceSword) end
f_dingzhengBlade = sgs.CreateViewAsEquipSkill{ --青龙偃月刀
	name = "f_dingzhengBlade",
	view_as_equip = function(self, player)
		return "blade"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengBlade") then skills:append(f_dingzhengBlade) end
f_dingzhengSpear = sgs.CreateViewAsEquipSkill{ --丈八蛇矛
	name = "f_dingzhengSpear",
	view_as_equip = function(self, player)
		return "spear"
	end,
}
f_dingzhengSpears = sgs.CreateTriggerSkill{ --因为视为装备技法则限制，需手动添加主动发动的技能
	name = "f_dingzhengSpears",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventAcquireSkill, sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventAcquireSkill then
			if data:toString() == "f_dingzhengSpear" and not player:hasSkill("spear") then
				room:attachSkillToPlayer(player, "spear")
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == "f_dingzhengSpear" and player:hasSkill("spear")
			and not (player:getWeapon() ~= nil and player:getWeapon():isKindOf("Spear")) then
				room:detachSkillFromPlayer(player, "spear", true)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengSpear") then skills:append(f_dingzhengSpear) end
if not sgs.Sanguosha:getSkill("f_dingzhengSpears") then skills:append(f_dingzhengSpears) end
f_dingzhengAxe = sgs.CreateViewAsEquipSkill{ --贯石斧
	name = "f_dingzhengAxe",
	view_as_equip = function(self, player)
		return "axe"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengAxe") then skills:append(f_dingzhengAxe) end
f_dingzhengHalberd = sgs.CreateViewAsEquipSkill{ --方天画戟
	name = "f_dingzhengHalberd",
	view_as_equip = function(self, player)
		return "halberd"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengHalberd") then skills:append(f_dingzhengHalberd) end
f_dingzhengKylinBow = sgs.CreateViewAsEquipSkill{ --麒麟弓
	name = "f_dingzhengKylinBow",
	view_as_equip = function(self, player)
		return "kylin_bow"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengKylinBow") then skills:append(f_dingzhengKylinBow) end
f_dingzhengGudingBlade = sgs.CreateViewAsEquipSkill{ --古锭刀
	name = "f_dingzhengGudingBlade",
	view_as_equip = function(self, player)
		return "guding_blade"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengGudingBlade") then skills:append(f_dingzhengGudingBlade) end
f_dingzhengFan = sgs.CreateViewAsEquipSkill{ --朱雀羽扇
	name = "f_dingzhengFan",
	view_as_equip = function(self, player)
		return "fan"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengFan") then skills:append(f_dingzhengFan) end
f_dingzhengWutiesuolian = sgs.CreateViewAsEquipSkill{ --乌铁锁链
	name = "f_dingzhengWutiesuolian",
	view_as_equip = function(self, player)
		return "wutiesuolian"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengWutiesuolian") then skills:append(f_dingzhengWutiesuolian) end
f_dingzhengWuxinghelingshan = sgs.CreateViewAsEquipSkill{ --五行鹤翎扇
	name = "f_dingzhengWuxinghelingshan",
	view_as_equip = function(self, player)
		return "wuxinghelingshan"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengWuxinghelingshan") then skills:append(f_dingzhengWuxinghelingshan) end
--防具牌
f_dingzhengEightDiagram = sgs.CreateViewAsEquipSkill{ --八卦阵
	name = "f_dingzhengEightDiagram",
	view_as_equip = function(self, player)
		return "eight_diagram"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengEightDiagram") then skills:append(f_dingzhengEightDiagram) end
f_dingzhengRenwangShield = sgs.CreateViewAsEquipSkill{ --仁王盾
	name = "f_dingzhengRenwangShield",
	view_as_equip = function(self, player)
		return "renwang_shield"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengRenwangShield") then skills:append(f_dingzhengRenwangShield) end
f_dingzhengVine = sgs.CreateViewAsEquipSkill{ --藤甲
	name = "f_dingzhengVine",
	view_as_equip = function(self, player)
		return "vine"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengVine") then skills:append(f_dingzhengVine) end
f_dingzhengSilverLion = sgs.CreateViewAsEquipSkill{ --白银狮子
	name = "f_dingzhengSilverLion",
	view_as_equip = function(self, player)
		return "silver_lion"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengSilverLion") then skills:append(f_dingzhengSilverLion) end
f_dingzhengHeiguangkai = sgs.CreateViewAsEquipSkill{ --黑光铠
	name = "f_dingzhengHeiguangkai",
	view_as_equip = function(self, player)
		return "heiguangkai"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengHeiguangkai") then skills:append(f_dingzhengHeiguangkai) end
f_dingzhengHuxinjing = sgs.CreateViewAsEquipSkill{ --护心镜
	name = "f_dingzhengHuxinjing",
	view_as_equip = function(self, player)
		return "huxinjing"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengHuxinjing") then skills:append(f_dingzhengHuxinjing) end
-- +1马牌
f_dingzhengDilu = sgs.CreateViewAsEquipSkill{ --的卢
	name = "f_dingzhengDilu",
	view_as_equip = function(self, player)
		return "dilu"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengDilu") then skills:append(f_dingzhengDilu) end
f_dingzhengJueying = sgs.CreateViewAsEquipSkill{ --绝影
	name = "f_dingzhengJueying",
	view_as_equip = function(self, player)
		return "jueying"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengJueying") then skills:append(f_dingzhengJueying) end
f_dingzhengZhuahuangfeidian = sgs.CreateViewAsEquipSkill{ --爪黄飞电
	name = "f_dingzhengZhuahuangfeidian",
	view_as_equip = function(self, player)
		return "zhuahuangfeidian"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengZhuahuangfeidian") then skills:append(f_dingzhengZhuahuangfeidian) end
f_dingzhengHualiu = sgs.CreateViewAsEquipSkill{ --骅骝
	name = "f_dingzhengHualiu",
	view_as_equip = function(self, player)
		return "hualiu"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengHualiu") then skills:append(f_dingzhengHualiu) end
-- -1马牌
f_dingzhengChitu = sgs.CreateViewAsEquipSkill{ --赤兔
	name = "f_dingzhengChitu",
	view_as_equip = function(self, player)
		return "chitu"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengChitu") then skills:append(f_dingzhengChitu) end
f_dingzhengDayuan = sgs.CreateViewAsEquipSkill{ --大宛
	name = "f_dingzhengDayuan",
	view_as_equip = function(self, player)
		return "dayuan"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengDayuan") then skills:append(f_dingzhengDayuan) end
f_dingzhengZixing = sgs.CreateViewAsEquipSkill{ --紫骍
	name = "f_dingzhengZixing",
	view_as_equip = function(self, player)
		return "zixing"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengZixing") then skills:append(f_dingzhengZixing) end
--宝物牌
f_dingzhengWoodenOx = sgs.CreateViewAsEquipSkill{ --木牛流马
	name = "f_dingzhengWoodenOx",
	view_as_equip = function(self, player)
		return "wooden_ox"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengWoodenOx") then skills:append(f_dingzhengWoodenOx) end
f_dingzhengTianjitu = sgs.CreateViewAsEquipSkill{ --天机图
	name = "f_dingzhengTianjitu",
	view_as_equip = function(self, player)
		return "tianjitu"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengTianjitu") then skills:append(f_dingzhengTianjitu) end
f_dingzhengTaigongyinfu = sgs.CreateViewAsEquipSkill{ --太公阴符
	name = "f_dingzhengTaigongyinfu",
	view_as_equip = function(self, player)
		return "taigongyinfu"
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengTaigongyinfu") then skills:append(f_dingzhengTaigongyinfu) end
f_dingzhengTongque = sgs.CreateViewAsEquipSkill{ --铜雀
	name = "f_dingzhengTongque",
	view_as_equip = function(self, player)
		return ""
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzhengTongque") then skills:append(f_dingzhengTongque) end
-----------------
f_dingzheng_equipEnd = sgs.CreateTriggerSkill{
	name = "f_dingzheng_equipEnd",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceEquip then
			for _, e in sgs.qlist(move.card_ids) do
				local equips = sgs.Sanguosha:getCard(e)
				-----
				if equips:isKindOf("Weapon") then
					if player:hasSkill("f_dingzhengCrossbow") then room:detachSkillFromPlayer(player, "f_dingzhengCrossbow", false, true) end
					if player:hasSkill("f_dingzhengQinggangSword") then room:detachSkillFromPlayer(player, "f_dingzhengQinggangSword", false, true) end
					if player:hasSkill("f_dingzhengDoubleSword") then room:detachSkillFromPlayer(player, "f_dingzhengDoubleSword", false, true) end
					if player:hasSkill("f_dingzhengIceSword") then room:detachSkillFromPlayer(player, "f_dingzhengIceSword", false, true) end
					if player:hasSkill("f_dingzhengBlade") then room:detachSkillFromPlayer(player, "f_dingzhengBlade", false, true) end
					if player:hasSkill("f_dingzhengSpear") then room:detachSkillFromPlayer(player, "f_dingzhengSpear", false, true) end
					if player:hasSkill("f_dingzhengAxe") then room:detachSkillFromPlayer(player, "f_dingzhengAxe", false, true) end
					if player:hasSkill("f_dingzhengHalberd") then room:detachSkillFromPlayer(player, "f_dingzhengHalberd", false, true) end
					if player:hasSkill("f_dingzhengKylinBow") then room:detachSkillFromPlayer(player, "f_dingzhengKylinBow", false, true) end
					if player:hasSkill("f_dingzhengGudingBlade") then room:detachSkillFromPlayer(player, "f_dingzhengGudingBlade", false, true) end
					if player:hasSkill("f_dingzhengFan") then room:detachSkillFromPlayer(player, "f_dingzhengFan", false, true) end
					if player:hasSkill("f_dingzhengWutiesuolian") then room:detachSkillFromPlayer(player, "f_dingzhengWutiesuolian", false, true) end
					if player:hasSkill("f_dingzhengWuxinghelingshan") then room:detachSkillFromPlayer(player, "f_dingzhengWuxinghelingshan", false, true) end
				elseif equips:isKindOf("Armor") then
					if player:hasSkill("f_dingzhengEightDiagram") then room:detachSkillFromPlayer(player, "f_dingzhengEightDiagram", false, true) end
					if player:hasSkill("f_dingzhengRenwangShield") then room:detachSkillFromPlayer(player, "f_dingzhengRenwangShield", false, true) end
					if player:hasSkill("f_dingzhengVine") then room:detachSkillFromPlayer(player, "f_dingzhengVine", false, true) end
					if player:hasSkill("f_dingzhengSilverLion") then room:detachSkillFromPlayer(player, "f_dingzhengSilverLion", false, true) end
					if player:hasSkill("f_dingzhengHeiguangkai") then room:detachSkillFromPlayer(player, "f_dingzhengHeiguangkai", false, true) end
					if player:hasSkill("f_dingzhengHuxinjing") then room:detachSkillFromPlayer(player, "f_dingzhengHuxinjing", false, true) end
				elseif equips:isKindOf("DefensiveHorse") then
					if player:hasSkill("f_dingzhengDilu") then room:detachSkillFromPlayer(player, "f_dingzhengDilu", false, true) end
					if player:hasSkill("f_dingzhengJueying") then room:detachSkillFromPlayer(player, "f_dingzhengJueying", false, true) end
					if player:hasSkill("f_dingzhengZhuahuangfeidian") then room:detachSkillFromPlayer(player, "f_dingzhengZhuahuangfeidian", false, true) end
					if player:hasSkill("f_dingzhengHualiu") then room:detachSkillFromPlayer(player, "f_dingzhengHualiu", false, true) end
				elseif equips:isKindOf("OffensiveHorse") then
					if player:hasSkill("f_dingzhengChitu") then room:detachSkillFromPlayer(player, "f_dingzhengChitu", false, true) end
					if player:hasSkill("f_dingzhengDayuan") then room:detachSkillFromPlayer(player, "f_dingzhengDayuan", false, true) end
					if player:hasSkill("f_dingzhengZixing") then room:detachSkillFromPlayer(player, "f_dingzhengZixing", false, true) end
				elseif equips:isKindOf("Treasure") then
					if player:hasSkill("f_dingzhengWoodenOx") then room:detachSkillFromPlayer(player, "f_dingzhengWoodenOx", false, true) end
					if player:hasSkill("f_dingzhengTianjitu") then room:detachSkillFromPlayer(player, "f_dingzhengTianjitu", false, true) end
					if player:hasSkill("f_dingzhengTaigongyinfu") then room:detachSkillFromPlayer(player, "f_dingzhengTaigongyinfu", false, true) end
					if player:hasSkill("f_dingzhengTongque") then room:detachSkillFromPlayer(player, "f_dingzhengTongque", false, true) end
				end
				-----
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("f_dingzheng_equipEnd") then skills:append(f_dingzheng_equipEnd) end

--SD2 005 凌元
f_lingyuan = sgs.General(extension, "f_lingyuan", "wu+shu", 4, true)

--凌(统)
f_lingyuan:addSkill("tenyearxuanfeng")
f_lingyuan:addSkill("tenyearyongjin")

--(蒲)元
f_lingyuan:addSkill("tianjiang")
f_lingyuan:addSkill("zhuren")

f_lingyuangouCard = sgs.CreateSkillCard{
	name = "f_lingyuangouCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		source:loseMark("@f_lingyuangou")
		room:doLightbox("$f_lingyuangouKongEr")
		--1：快乐零元购
		for i = 0, 4 do
			if source:hasEquipArea(i) then
				local zmb = {}
				for _, p in sgs.qlist(room:getOtherPlayers(source)) do
					local zmb_card = nil
					if i == 0 then zmb_card = p:getWeapon()
					elseif i == 1 then zmb_card = p:getArmor()
					elseif i == 2 then zmb_card = p:getDefensiveHorse()
					elseif i == 3 then zmb_card = p:getOffensiveHorse()
					elseif i == 4 then zmb_card = p:getTreasure()
					end
					if zmb_card ~= nil then
						table.insert(zmb, zmb_card)
					else
						continue
					end
				end
				if #zmb > 0 then
					local random_card = zmb[math.random(1, #zmb)]
					room:obtainCard(source, random_card)
					room:useCard(sgs.CardUseStruct(random_card, source, source))
				end
			end
		end
		--2：惨遭蝙蝠侠逮住
		for i = 0, 4 do
			if source:hasEquipArea(i) then
				local other_players = room:getOtherPlayers(source)
				local wgyz_card = nil
				if i == 0 then wgyz_card = source:getWeapon()
				elseif i == 1 then wgyz_card = source:getArmor()
				elseif i == 2 then wgyz_card = source:getDefensiveHorse()
				elseif i == 3 then wgyz_card = source:getOffensiveHorse()
				elseif i == 4 then wgyz_card = source:getTreasure()
				end
				if wgyz_card ~= nil then
					local players = {}
					for _, ot in sgs.qlist(other_players) do
						table.insert(players, ot)
					end
					local random_player = players[math.random(1, #players)]
					room:obtainCard(random_player, wgyz_card)
					if random_player:hasEquipArea(i) and random_player:isAlive() then --判断是否存活，是必要的步骤呢XD
						room:useCard(sgs.CardUseStruct(wgyz_card, random_player, random_player))
					end
				end
			end
		end
		--3：祖国人会来救场吗？
		local judge1 = sgs.JudgeStruct()
		judge1.pattern = "."
		judge1.good = true
		judge1.play_animation = false
		judge1.who = source
		judge1.reason = "f_lingyuangou"
		room:judge(judge1)
		room:getThread():delay()
		local judge2 = sgs.JudgeStruct()
		judge2.pattern = "."
		judge2.good = true
		judge2.play_animation = false
		judge2.who = source
		judge2.reason = "f_lingyuangou"
		room:judge(judge2)
		----
		--if judge1.card:isRed() and judge2.card:isRed() then --无事发生。
		if judge1.card:isRed() and judge2.card:isBlack() then --偷袭！
			room:broadcastSkillInvoke("f_lingyuangouCD", 1)
			room:doLightbox("malaoshiAnimate")
			room:obtainCard(source, judge2.card)
		elseif judge1.card:isBlack() and judge2.card:isBlack() then --任何邪恶，终将绳之以法！
			room:broadcastSkillInvoke("f_lingyuangouCD", 2)
			room:doLightbox("haojingAnimate")
			source:throwEquipArea()
			room:loseHp(source, source:getHp())
		elseif judge1.card:isBlack() and judge2.card:isRed() then --回归主线$
			room:doLightbox("f_lingyuangouAgain")
			for i = 0, 4 do
				if source:hasEquipArea(i) then
					local zmb = {}
					for _, p in sgs.qlist(room:getOtherPlayers(source)) do
						local zmb_card = nil
						if i == 0 then zmb_card = p:getWeapon()
						elseif i == 1 then zmb_card = p:getArmor()
						elseif i == 2 then zmb_card = p:getDefensiveHorse()
						elseif i == 3 then zmb_card = p:getOffensiveHorse()
						elseif i == 4 then zmb_card = p:getTreasure()
						end
						if zmb_card ~= nil then
							table.insert(zmb, zmb_card)
						else
							continue
						end
					end
					if #zmb > 0 then
						local random_card = zmb[math.random(1, #zmb)]
						room:obtainCard(source, random_card)
						room:useCard(sgs.CardUseStruct(random_card, source, source))
					end
				end
			end
		end
	end,
}
f_lingyuangouVS = sgs.CreateZeroCardViewAsSkill{
	name = "f_lingyuangou",
	view_as = function()
		return f_lingyuangouCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@f_lingyuangou") > 0 and player:hasEquipArea() and not player:hasFlag("f_lingyuangou_limited")
	end,
	response_pattern = "@@f_lingyuangou",
}
f_lingyuangou = sgs.CreateTriggerSkill{
	name = "f_lingyuangou",
	frequency = sgs.Skill_Limited,
	limit_mark = "@f_lingyuangou",
	view_as_skill = f_lingyuangouVS,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_RoundStart and player:getMark("@f_lingyuangou") > 0 and player:hasEquipArea() then
			if not room:askForUseCard(player, "@@f_lingyuangou", "@f_lingyuangou-card") then
				room:setPlayerFlag(player, "f_lingyuangou_limited")
			end
		end
	end,
}
f_lingyuangouCD = sgs.CreateTriggerSkill{ --空壳，用以承载“凌元购”彩蛋语音
	name = "f_lingyuangouCD",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
f_lingyuan:addSkill(f_lingyuangou)
f_lingyuan:addRelateSkill("f_lingyuangouCD") if not sgs.Sanguosha:getSkill("f_lingyuangouCD") then skills:append(f_lingyuangouCD) end


--

--SD2 006 苟咔
f_GoCar = sgs.General(extension, "f_GoCar", "wu+jin", 10, true, true)
f_GoCar:setGender(sgs.General_Sexless)





--

--SD2 007 狂暴流氓云
f_KBliumangyun = sgs.General(extension, "f_KBliumangyun", "qun", 4, true)

f_KBliumangyun:addSkill("ollongdan")

f_chongzhen = sgs.CreateTriggerSkill{
	name = "f_chongzhen",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("BasicCard") and use.from:objectName() == player:objectName() then
				if use.card:getSkillName() == "ollongdan" then
					local me = 0
					for _, p in sgs.qlist(use.to) do
						if p:objectName() == player:objectName() then
							me = 1
							break
						end
					end
					if me == 0 then
						local victim = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName(), "f_SuperChongzhen", true, true)
						if not victim:isAllNude() then
							room:sendCompulsoryTriggerLog(player, self:objectName())
							room:broadcastSkillInvoke(self:objectName())
							local card_id = room:askForCardChosen(player, victim, "hej", self:objectName())
							local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
							room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, false)
						end
					elseif me == 1 then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						room:drawCards(player, 1, self:objectName())
					end
				else
					for _, p in sgs.qlist(use.to) do
						if p:isAllNude() or p:objectName() == player:objectName() then continue end
						local _data = sgs.QVariant()
						_data:setValue(p)
						p:setFlags("f_chongzhenTarget")
						local invoke = room:askForSkillInvoke(player, self:objectName(), _data)
						p:setFlags("-f_chongzhenTarget")
						if invoke then
							room:broadcastSkillInvoke(self:objectName())
							local card_id = room:askForCardChosen(player, p, "hej", self:objectName())
							local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
							room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, false)
						end
					end
				end
			end
		elseif event == sgs.CardResponded then
			local resp = data:toCardResponse()
			if resp.m_card:isKindOf("BasicCard") and resp.m_who then
				if resp.m_card:getSkillName() == "ollongdan" then
					if resp.m_who:objectName() ~= player:objectName() then
						local victim = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName(), "f_SuperChongzhen", true, true)
						if not victim:isAllNude() then
							room:sendCompulsoryTriggerLog(player, self:objectName())
							room:broadcastSkillInvoke(self:objectName())
							local card_id = room:askForCardChosen(player, victim, "hej", self:objectName())
							local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
							room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, false)
						end
					else
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						room:drawCards(player, 1, self:objectName())
					end
				else
					if resp.m_who:objectName() == player:objectName() or resp.m_who:isAllNude() then return false end
					local _data = sgs.QVariant()
					_data:setValue(resp.m_who)
					if room:askForSkillInvoke(player, self:objectName(), _data) then
						room:broadcastSkillInvoke(self:objectName())
						local card_id = room:askForCardChosen(player, resp.m_who, "hej", self:objectName())
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
						room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, false)
		        	end
				end
			end
		end
	end,
}
f_KBliumangyun:addSkill(f_chongzhen)

f_yicon = sgs.CreateDistanceSkill{
	name = "f_yicon",
	correct_func = function(self, from)
		if from:hasSkill(self:objectName()) then
			return -1
		else
			return 0
		end
	end,
}
f_yiconn = sgs.CreateMaxCardsSkill{
	name = "f_yiconn",
	extra_func = function(self, player)
		if player:hasSkill("f_yicon") and player:getHp() <= 2 then
			return 1
		else
			return 0
		end
	end,
}
f_yiconAudio = sgs.CreateTriggerSkill{
	name = "f_yiconAudio",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.HpChanged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getHp() <= 2 then
			room:sendCompulsoryTriggerLog(player, "f_yicon")
			room:broadcastSkillInvoke("f_yicon")
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_yicon")
	end,
}
f_KBliumangyun:addSkill(f_yicon)
if not sgs.Sanguosha:getSkill("f_yiconn") then skills:append(f_yiconn) end
if not sgs.Sanguosha:getSkill("f_yiconAudio") then skills:append(f_yiconAudio) end

--

--SD2 008 大狗&杜神&彪爷
DAGOU_DUSHEN_BIAOYE = sgs.General(extension, "DAGOU_DUSHEN_BIAOYE", "qun", 3, true)

thisisjunba = sgs.CreateTriggerSkill{
	name = "thisisjunba",
	priority = 10,
	frequency = sgs.Skill_Compulsory,
	waked_skills = "dg_linghan, mobilezhimiewu, rangjie",
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		if not player:hasSkill("dg_linghan") then
			room:acquireSkill(player, "dg_linghan")
		end
		if not player:hasSkill("mobilezhimiewu") then
			room:acquireSkill(player, "mobilezhimiewu")
		end
		if not player:hasSkill("rangjie") then
			room:acquireSkill(player, "rangjie")
		end
		player:gainMark("&mobilezhiwuku", 280) --280为杜预“势如破竹”灭吴的年份
	end,
}
DAGOU_DUSHEN_BIAOYE:addSkill(thisisjunba)
DAGOU_DUSHEN_BIAOYE:addRelateSkill("dg_linghan")
DAGOU_DUSHEN_BIAOYE:addRelateSkill("mobilezhimiewu")
DAGOU_DUSHEN_BIAOYE:addRelateSkill("rangjie")
--“灵汉”
dg_linghan = sgs.CreateTriggerSkill{
	name = "dg_linghan",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if not use.card:isKindOf("TrickCard") or use.card:isVirtualCard() then return false end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:isDead() or not p:hasSkill(self) then continue end
			local names = p:property("SkillDescriptionRecord_dg_linghan"):toString():split("+")
			if use.card:isKindOf("ExNihilo") or use.card:isKindOf("Dismantlement") or use.card:isKindOf("Nullification")
			or use.card:isKindOf("Qizhengxiangsheng") or use.card:isKindOf("Fqizhengxiangsheng")
			or (p:hasSkill("dg_linghan", true) and table.contains(names, use.card:objectName())) then
				room:sendCompulsoryTriggerLog(p, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:drawCards(p, 1, self:objectName())
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
dg_linghann = sgs.CreateTriggerSkill{
	name = "dg_linghann",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.TargetConfirming, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirming then
			local use = data:toCardUse()
			if not use.card:isKindOf("TrickCard") then return false end
			local names, name = player:property("SkillDescriptionRecord_dg_linghan"):toString():split("+"), use.card:objectName()
			if table.contains(names, name) then return false end
			table.insert(names, name)
			room:setPlayerProperty(player, "SkillDescriptionRecord_dg_linghan", sgs.QVariant(table.concat(names, "+")))
			room:changeTranslation(player, "dg_linghan", 11)
			local log = sgs.LogMessage()
			log.type = "#WuyanGooD"
			log.from = player
			log.to:append(use.from)
			log.arg = name
			log.arg2 = self:objectName()
			room:sendLog(log)
			room:notifySkillInvoked(player, self:objectName())
			room:broadcastSkillInvoke("dg_linghan")
			local nullified_list = use.nullified_list
			table.insert(nullified_list, player:objectName())
			use.nullified_list = nullified_list
			data:setValue(use)
		else
			if player:getPhase() ~= sgs.Player_RoundStart then return false end
			local record, other, all, dg_linghan, tricks = sgs.IntList(), sgs.IntList(), sgs.IntList(), player:property("SkillDescriptionRecord_dg_linghan"):toString():split("+"), {}
			for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
				local c = sgs.Sanguosha:getEngineCard(id)
				if not c:isKindOf("TrickCard") or table.contains(tricks, c:objectName()) then continue end
				table.insert(tricks, c:objectName())
				if table.contains(dg_linghan, c:objectName()) then
					record:append(id)
				else
					other:append(id)
				end
			end
			for _, id in sgs.qlist(record) do
				all:append(id)
			end
			for _, id in sgs.qlist(other) do
				all:append(id)
			end
			
			local choices = {}
			if not other:isEmpty() then
				table.insert(choices, "add")
			end
			if not record:isEmpty() then
				table.insert(choices, "remove")
			end
			if #choices == 0 then return false end
			table.insert(choices, "cancel")
			room:fillAG(all, player, other)
			local choice = room:askForChoice(player, "dg_linghan", table.concat(choices, "+"), sgs.QVariant(), "tip")
			room:clearAG(player)
			if choice == "cancel" then return false end
			local log = sgs.LogMessage()
			log.type = "#InvokeSkill"
			log.from = player
			log.arg = self:objectName()
			room:sendLog(log)
			room:notifySkillInvoked(player, self:objectName())
			room:broadcastSkillInvoke("dg_linghan")
			if choice == "remove" then
				room:fillAG(record, player)
				local id = room:askForAG(player, record, false, self:objectName())
				room:clearAG(player)
				local name = sgs.Sanguosha:getEngineCard(id):objectName()
				log.type = "#dg_linghanRemove"
				log.from = player
				log.arg = self:objectName()
				log.arg2 = name
				room:sendLog(log)
				table.removeOne(dg_linghan, name)
				room:setPlayerProperty(player, "SkillDescriptionRecord_dg_linghan", sgs.QVariant(table.concat(dg_linghan, "+")))
				if #dg_linghan == 0 then
					room:changeTranslation(player, "dg_linghan", 1)
				else
					room:changeTranslation(player, "dg_linghan", 11)
				end
			else
				room:fillAG(other, player)
				local id = room:askForAG(player, other, false, self:objectName())
				room:clearAG(player)
				local name = sgs.Sanguosha:getEngineCard(id):objectName()
				log.type = "#dg_linghanAdd"
				log.from = player
				log.arg = self:objectName()
				log.arg2 = name
				room:sendLog(log)
				table.insert(dg_linghan, name)
				room:setPlayerProperty(player, "SkillDescriptionRecord_dg_linghan", sgs.QVariant(table.concat(dg_linghan, "+")))
				room:changeTranslation(player, "dg_linghan", 11)
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("dg_linghan")
	end,
}
if not sgs.Sanguosha:getSkill("dg_linghan") then skills:append(dg_linghan) end
if not sgs.Sanguosha:getSkill("dg_linghann") then skills:append(dg_linghann) end

--神徐盛、神黄忠皮肤系统--
f_forSXSandSHZ = sgs.CreateTriggerSkill{
	name = "f_forSXSandSHZ",
	global = true,
	priority = {1314, -1314},
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.GameStart, sgs.Death, sgs.EventPhaseStart, sgs.EventPhaseEnd, sgs.EventPhaseChanging, sgs.CardUsed, sgs.CardResponded, sgs.CardFinished, sgs.BuryVictim},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			local sxs, shz = 0, 0
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if isSpecialOne(p, "七夕纪念") then
					if isSpecialOne(p, "神徐盛") then sxs = sxs + 1 end
					if isSpecialOne(p, "神黄忠") then shz = shz + 1 end
				end
			end
			if sxs > 0 and shz > 0 then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if isSpecialOne(p, "七夕纪念") then
						if isSpecialOne(p, "神徐盛") then
							if p:getGeneralName() == "f_shenxusheng" or p:getGeneralName() == "f_shenxusheng_skin" then
								room:changeHero(p, "f_shenxusheng_forSHZ", false, true, false, false)
							end
							if p:getGeneral2Name() == "f_shenxusheng" or p:getGeneral2Name() == "f_shenxusheng_skin" then
								room:changeHero(p, "f_shenxusheng_forSHZ", false, true, true, false)
							end
						end
						if isSpecialOne(p, "神黄忠") then
							if p:getGeneralName() == "f_shenhuangzhongg" or p:getGeneralName() == "f_shenhuangzhongg_skin" then
								room:changeHero(p, "f_shenhuangzhongg_forSXS", false, true, false, false)
							end
							if p:getGeneral2Name() == "f_shenhuangzhongg" or p:getGeneral2Name() == "f_shenhuangzhongg_skin" then
								room:changeHero(p, "f_shenhuangzhongg_forSXS", false, true, true, false)
							end
						end
					end
				end
			else
				if player:getSeat() ~= 1 then return false end
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if isSpecialOne(p, "七夕纪念") then
						if room:askForSkillInvoke(p, "@f_forSXSandSHZ_changeSkin", data) then
							if p:getGeneralName() == "f_shenxusheng" then
								room:changeHero(p, "f_shenxusheng_skin", false, true, false, false)
							elseif p:getGeneral2Name() == "f_shenxusheng" then
								room:changeHero(p, "f_shenxusheng_skin", false, true, true, false)
							end
							if p:getGeneralName() == "f_shenhuangzhongg" then
								room:changeHero(p, "f_shenhuangzhongg_skin", false, true, false, false)
							elseif p:getGeneral2Name() == "f_shenhuangzhongg"  then
								room:changeHero(p, "f_shenhuangzhongg_skin", false, true, true, false)
							end
						end
					end
				end
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who and death.who:objectName() == player:objectName() and isSpecialOne(player, "七夕纪念") then
				if isSpecialOne(player, "神徐盛") then
					player:speak("忠......")
				elseif isSpecialOne(player, "神黄忠") then
					player:speak("宝儿..对不起，我再也不能...守护......")
				end
			end
		
		else
			local sxs, shz = 0, 0
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if isSpecialOne(p, "七夕纪念") then
					if isSpecialOne(p, "神徐盛") then sxs = sxs + 1 end
					if isSpecialOne(p, "神黄忠") then shz = shz + 1 end
				end
			end
			if sxs > 0 and shz > 0 then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if isSpecialOne(p, "七夕纪念") then
						local mhp = p:getMaxHp()
						local hp = p:getHp()
						local m, n = p:getMark("@f_haishiSM"), p:getMark("@f_shanmengHS")
						if isSpecialOne(p, "神徐盛") then
							if p:getGeneralName() == "f_shenxusheng" or p:getGeneralName() == "f_shenxusheng_skin" then
								room:changeHero(p, "f_shenxusheng_forSHZ", false, false, false, false)
							end
							if p:getGeneral2Name() == "f_shenxusheng" or p:getGeneral2Name() == "f_shenxusheng_skin" then
								room:changeHero(p, "f_shenxusheng_forSHZ", false, false, true, false)
							end
						end
						if isSpecialOne(p, "神黄忠") then
							if p:getGeneralName() == "f_shenhuangzhongg" or p:getGeneralName() == "f_shenhuangzhongg_skin" then
								room:changeHero(p, "f_shenhuangzhongg_forSXS", false, false, false, false)
							end
							if p:getGeneral2Name() == "f_shenhuangzhongg" or p:getGeneral2Name() == "f_shenhuangzhongg_skin" then
								room:changeHero(p, "f_shenhuangzhongg_forSXS", false, false, true, false)
							end
						end
						if p:getMaxHp() ~= mhp then room:setPlayerProperty(p, "maxhp", sgs.QVariant(mhp)) end
						if p:getHp() ~= hp then room:setPlayerProperty(p, "hp", sgs.QVariant(hp)) end
						if m == 0 then room:setPlayerMark(p, "@f_haishiSM", 0) end
						if n == 0 then room:setPlayerMark(p, "@f_shanmengHS", 0) end
					end
				end
			elseif sxs == 0 or shz == 0 then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if isSpecialOne(p, "七夕纪念") then
						local mhp = p:getMaxHp()
						local hp = p:getHp()
						local m, n = p:getMark("@f_haishiSM"), p:getMark("@f_shanmengHS")
						if isSpecialOne(p, "神徐盛") then
							if p:getGeneralName() == "f_shenxusheng_forSHZ" then
								local choice = room:askForChoice(p, "@f_forSXSandSHZ_changeSkin", data)
								if choice == "1" then
									room:changeHero(p, "f_shenxusheng", false, false, false, false)
								elseif choice == "2" then
									room:changeHero(p, "f_shenxusheng_skin", false, false, false, false)
								end
							end
							if p:getGeneral2Name() == "f_shenxusheng_forSHZ" then
								local choice = room:askForChoice(p, "@f_forSXSandSHZ_changeSkin", data)
								if choice == "1" then
									room:changeHero(p, "f_shenxusheng", false, false, true, false)
								elseif choice == "2" then
									room:changeHero(p, "f_shenxusheng_skin", false, false, true, false)
								end
							end
						end
						if isSpecialOne(p, "神黄忠") then
							if p:getGeneralName() == "f_shenhuangzhongg_forSXS" then
								local choice = room:askForChoice(p, "@f_forSXSandSHZ_changeSkin", data)
								if choice == "1" then
									room:changeHero(p, "f_shenhuangzhongg", false, false, false, false)
								elseif choice == "2" then
									room:changeHero(p, "f_shenhuangzhongg_skin", false, false, false, false)
								end
							end
							if p:getGeneral2Name() == "f_shenhuangzhongg_forSXS" then
								local choice = room:askForChoice(p, "@f_forSXSandSHZ_changeSkin", data)
								if choice == "1" then
									room:changeHero(p, "f_shenhuangzhongg", false, false, true, false)
								elseif choice == "2" then
									room:changeHero(p, "f_shenhuangzhongg_skin", false, false, true, false)
								end
							end
						end
						if p:getMaxHp() ~= mhp then room:setPlayerProperty(p, "maxhp", sgs.QVariant(mhp)) end
						if p:getHp() ~= hp then room:setPlayerProperty(p, "hp", sgs.QVariant(hp)) end
						if m == 0 then room:setPlayerMark(p, "@f_haishiSM", 0) end
						if n == 0 then room:setPlayerMark(p, "@f_shanmengHS", 0) end
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("f_forSXSandSHZ") then skills:append(f_forSXSandSHZ) end

--SD2 009 神徐盛
f_shenxusheng = sgs.General(extension, "f_shenxusheng", "god", 4, false)
f_shenxusheng_skin = sgs.General(extension, "f_shenxusheng_skin", "god", 4, false, true, true)
f_shenxusheng_forSHZ = sgs.General(extension, "f_shenxusheng_forSHZ", "god", 4, false, true, true)

f_pojun = sgs.CreateTriggerSkill{
	name = "f_pojun",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetSpecified, sgs.CardFinished, sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.TargetSpecified then
			if use.card and use.card:isDamageCard() and not use.card:isKindOf("SkillCard") then
				room:setPlayerMark(player, "f_pojunTargets", use.to:length()) --记录目标数
				for _, t in sgs.qlist(use.to) do
					if (t:isMale() and t:getMark("f_pojuned") > 1) or (not t:isMale() and t:getMark("f_pojuned") >= 1) then continue end
					if t:objectName() == player:objectName() then continue end
					local n = math.min(t:getCards("he"):length(), t:getHp())
					local _data = sgs.QVariant() _data:setValue(t)
					if n > 0 and player:askForSkillInvoke(self:objectName(), _data) then
						room:addPlayerMark(t, "f_pojuned")
						room:broadcastSkillInvoke(self:objectName())
						room:doAnimate(1, player:objectName(), t:objectName())
						local dis_num = {}
						for i = 1, n do
							table.insert(dis_num, tostring(i))
						end
						local discard_n = tonumber(room:askForChoice(player, self:objectName() .. "_num", table.concat(dis_num, "+"))) - 1
						local orig_places = sgs.PlaceList()
						local cards = sgs.IntList()
						t:setFlags("f_pojun_InTempMoving")
						for i = 0, discard_n do
							local id = room:askForCardChosen(player, t, "he", self:objectName() .. "_dis", false, sgs.Card_MethodNone)
							local place = room:getCardPlace(id)
							orig_places:append(place)
							cards:append(id)
							t:addToPile("#f_pojun", id, false)
						end
						for i = 0, discard_n do
							room:moveCardTo(sgs.Sanguosha:getCard(cards:at(i)), t, orig_places:at(i), false)
						end
						t:setFlags("-f_pojun_InTempMoving")
						local dummy = sgs.Sanguosha:cloneCard("slash")
						dummy:addSubcards(cards)
						local tt = sgs.SPlayerList()
						tt:append(t)
						local to_throw, bsc, trk, eqp = {}, 0, 0, 0
						t:addToPile("f_pojun", dummy, false, tt)
						for _, id in sgs.qlist(t:getPile("f_pojun")) do
							local cd = sgs.Sanguosha:getCard(id)
							if cd:isKindOf("BasicCard") then bsc = bsc + 1 end
							if cd:isKindOf("TrickCard") then trk = trk + 1 end
							if cd:isKindOf("EquipCard") then eqp = eqp + 1 end
							table.insert(to_throw, cd)
						end
						if bsc > 0 and player:isWounded() then
							room:recover(player, sgs.RecoverStruct(player), true)
						end
						if trk > 0 then
							room:drawCards(player, 1, self:objectName())
						end
						if eqp > 0 and #to_throw > 0 then
							local totw = to_throw[math.random(1, #to_throw)]
							room:throwCard(totw, t, player)
						end
					end
				end
			end
		elseif event == sgs.CardFinished then
			if use.card and not use.card:isKindOf("SkillCard") and player:getMark("f_pojunTargets") > 0 then
				room:setPlayerMark(player, "f_pojunTargets", 0)
			end
		else
			local damage = data:toDamage()
			local to = damage.to
			if damage.card and damage.card:isDamageCard() and to and to:isAlive()
			and player:getMark("f_pojunTargets") <= player:getHp() then
				room:setPlayerMark(player, "f_pojunTargets", 0)
				if to:getHandcardNum() > player:getHandcardNum() or to:getEquips():length() > player:getEquips():length() then return false end
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:doAnimate(1, player:objectName(), to:objectName())
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		end
	end,
}
f_pojunReturn = sgs.CreateTriggerSkill{
	name = "f_pojunReturn",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if data:toPhaseChange().to == sgs.Player_NotActive then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if not p:getPile("f_pojun"):isEmpty() then
					local dummy = sgs.Sanguosha:cloneCard("slash")
					dummy:addSubcards(p:getPile("f_pojun"))
					room:obtainCard(p, dummy, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE, p:objectName(), self:objectName(), ""), false)
				end
				room:setPlayerMark(p, "f_pojuned", 0)
				room:setPlayerMark(p, "f_yichenged", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_pojunFakeMove = sgs.CreateTriggerSkill{
	name = "f_pojunFakeMove",
	global = true,
	priority = 10,
	frequency = sgs.Skill_Frequent,
	events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local allplayers = room:getAllPlayers()
		for _, p in sgs.qlist(allplayers) do
			if p:hasFlag("f_pojun_InTempMoving") then
				return true
			end
		end
		return false
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shenxusheng:addSkill(f_pojun)
f_shenxusheng_skin:addSkill("f_pojun")
f_shenxusheng_forSHZ:addSkill("f_pojun")
if not sgs.Sanguosha:getSkill("f_pojunReturn") then skills:append(f_pojunReturn) end
if not sgs.Sanguosha:getSkill("f_pojunFakeMove") then skills:append(f_pojunFakeMove) end

f_yicheng = sgs.CreateTriggerSkill{
	name = "f_yicheng",
	global = true,
	priority = 3,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirmed, sgs.TargetConfirming, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.TargetConfirmed then
			if use.from and use.card and use.card:isDamageCard() and use.to and use.to:contains(player) then
				for _, sxs in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					if use.from:objectName() == sxs:objectName() or player:objectName() == sxs:objectName() then continue end
					if sxs:getMark("f_yichenged") > 0 or sxs:hasFlag("f_yichengAsked") then continue end
					if room:askForSkillInvoke(sxs, self:objectName(), data) then
						room:addPlayerMark(sxs, "f_yichenged")
						room:broadcastSkillInvoke(self:objectName())
						if player:isMale() then
							room:drawCards(player, 2, self:objectName())
						else
							room:drawCards(player, 1, self:objectName())
						end
						local yic = room:askForDiscard(player, self:objectName(), 1, 1)
						if yic then
							for _, c in sgs.qlist(yic:getSubcards()) do
								local cd = sgs.Sanguosha:getCard(c)
								if cd:getSuit() == use.card:getSuit() then
									local nullified_list = use.nullified_list
				    				table.insert(nullified_list, player:objectName())
				    				use.nullified_list = nullified_list
				    				data:setValue(use)
									break
								end
							end
						end
					else
						room:setPlayerFlag(sxs, "f_yichengAsked")
					end
				end
			end
		else
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("f_yichengAsked") then
					room:setPlayerFlag(p, "-f_yichengAsked")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shenxusheng:addSkill(f_yicheng)
f_shenxusheng_skin:addSkill("f_yicheng")
f_shenxusheng_forSHZ:addSkill("f_yicheng")

f_dazhuang = sgs.CreateTriggerSkill{
	name = "f_dazhuang",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.from and damage.from:objectName() == player:objectName()
		and player:getMark("f_dazhuang_lun") == 0 and player:hasEquipArea() then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:addPlayerMark(player, "f_dazhuang_lun")
				room:broadcastSkillInvoke(self:objectName())
				local dz = damage.damage
				while dz > 0 do
					local use_id = -1
					for _, id in sgs.qlist(room:getDrawPile()) do
						local card = sgs.Sanguosha:getCard(id)
						if card:isKindOf("EquipCard") then
							local e = card:getRealCard():toEquipCard():location()
							if player:hasEquipArea(e) then
								use_id = id
								break
							end
						end
					end
					if use_id >= 0 then
						local use_card = sgs.Sanguosha:getCard(use_id)
						if player:isAlive() and player:canUse(use_card, player, true) then
							room:useCard(sgs.CardUseStruct(use_card, player, player))
						end
					end
					dz = dz - 1
				end
			end
		end
	end,
}
f_shenxusheng:addSkill(f_dazhuang)
f_shenxusheng_skin:addSkill("f_dazhuang")
f_shenxusheng_forSHZ:addSkill("f_dazhuang")

f_haishiSM = sgs.CreateTriggerSkill{
	name = "f_haishiSM",
	global = true,
	frequency = sgs.Skill_Limited,
	limit_mark = "@f_haishiSM",
	events = {sgs.AskForPeachesDone, sgs.PreHpRecover},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.AskForPeachesDone then
			local dying = data:toDying()
			if dying.who:objectName() == player:objectName() then
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if not p:hasSkill(self:objectName()) or p:getMark("@f_haishiSM") == 0 then continue end
					if not isSpecialOne(p, "七夕纪念") then continue end
					if (isSpecialOne(p, "神徐盛") and isSpecialOne(player, "神黄忠"))
					or (isSpecialOne(p, "神黄忠") and isSpecialOne(player, "神徐盛")) then
						if room:askForSkillInvoke(p, self:objectName(), data) then
							p:loseMark("@f_haishiSM")
							room:broadcastSkillInvoke(self:objectName())
							room:doLightbox("$f_haishiSM_toSHZ")
							if player:isWounded() then
								local rec = player:getMaxHp() - player:getHp()
								room:recover(player, sgs.RecoverStruct(p, nil, rec))
							end
							if not p:isAllNude() then
								local dummy_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
								for _, cd in sgs.qlist(p:getCards("hej")) do
									dummy_card:addSubcard(cd)
								end
								local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, player:objectName(), p:objectName(), self:objectName(), nil)
								room:moveCardTo(dummy_card, p, player, sgs.Player_PlaceHand, reason, false)
								dummy_card:deleteLater()
							end
							--代价：
							room:killPlayer(p)
						end
					end
				end
			end
		elseif event == sgs.PreHpRecover then
			local recover = data:toRecover()
			if recover.who and recover.who:objectName() == player:objectName() and player:hasSkill(self:objectName())
			and isSpecialOne(player, "神徐盛") and isSpecialOne(player, "神黄忠") then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				recover.recover = recover.recover + 1
				data:setValue(recover)
			end
		end
	end,
	can_trigger = function(self, player)
		return isSpecialOne(player, "七夕纪念") and (isSpecialOne(player, "神徐盛") or isSpecialOne(player, "神黄忠"))
	end,
}
f_shenxusheng:addSkill(f_haishiSM)
f_shenxusheng_skin:addSkill("f_haishiSM")
f_shenxusheng_forSHZ:addSkill("f_haishiSM")





--

--SD2 010 神黄忠
f_shenhuangzhongg = sgs.General(extension, "f_shenhuangzhongg", "god", 4, true)
f_shenhuangzhongg_skin = sgs.General(extension, "f_shenhuangzhongg_skin", "god", 4, true, true, true)
f_shenhuangzhongg_forSXS = sgs.General(extension, "f_shenhuangzhongg_forSXS", "god", 4, true, true, true)

f_kaigong = sgs.CreateTriggerSkill{
	name = "f_kaigong",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetSpecified, sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.from and use.from:objectName() == player:objectName() and use.card and use.card:isKindOf("Slash") then
				if player:getMark("f_kaigong_d1") > 0 and player:getMark("f_kaigong_d2") > 0
				and player:getMark("f_kaigong_d3") > 0 and player:getMark("f_kaigong_d4") > 0 then return false end
				for _, p in sgs.qlist(use.to) do
					local up_damage = 0
					if player:getMark("f_kaigong_d1") == 0 and p:getHandcardNum() >= player:getHp() then
						up_damage = up_damage + 1
					end
					if player:getMark("f_kaigong_d2") == 0 and p:getHandcardNum() <= player:getAttackRange() then
						up_damage = up_damage + 1
					end
					if player:getMark("f_kaigong_d3") == 0 and player:getHandcardNum() >= p:getHandcardNum() then
						up_damage = up_damage + 1
					end
					if player:getMark("f_kaigong_d4") == 0 and player:getHp() <= p:getHp() then
						up_damage = up_damage + 1
					end
					if up_damage == 0 then return false end
					if room:askForSkillInvoke(player, self:objectName(), ToData("f_kaigongUpDamage:" .. up_damage)) then
						if not use.card:hasFlag(self:objectName()) then room:setCardFlag(use.card, self:objectName()) end
						room:broadcastSkillInvoke(self:objectName())
						room:setPlayerMark(p, self:objectName(), up_damage)
					else if player:getState() == "robot" then return false end
						local choices = {}
						for i = 0, up_damage do
							table.insert(choices, i)
						end
						local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
						local UD = tonumber(choice)
						if UD > 0 then
							if not use.card:hasFlag(self:objectName()) then room:setCardFlag(use.card, self:objectName()) end
							room:broadcastSkillInvoke(self:objectName())
							room:setPlayerMark(p, self:objectName(), UD)
						end
					end
				end
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.from and damage.from:objectName() == player:objectName() and damage.to and damage.to:getMark(self:objectName()) > 0
			and damage.card and damage.card:isKindOf("Slash") and damage.card:hasFlag(self:objectName()) then
				local n = damage.to:getMark(self:objectName())
				room:setPlayerMark(damage.to, self:objectName(), 0)
				local log = sgs.LogMessage()
				log.type = "$f_kaigongUD"
				log.from = player
				log.to:append(damage.to)
				log.card_str = damage.card:toString()
				log.arg2 = n
				room:sendLog(log)
			    damage.damage = damage.damage + n
				room:broadcastSkillInvoke(self:objectName())
				data:setValue(damage)
			end
		end
	end,
}
f_shenhuangzhongg:addSkill(f_kaigong)
f_shenhuangzhongg_skin:addSkill("f_kaigong")
f_shenhuangzhongg_forSXS:addSkill("f_kaigong")

f_gonghun = sgs.CreateTriggerSkill{
	name = "f_gonghun",
	frequency = sgs.Skill_Frequent,
	events = {sgs.GameStart, sgs.MarkChanged, sgs.ConfirmDamage},
	waked_skills = "liegong, tenyearliegong, f_mouliegong, smzy_shenliegong",
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			room:setPlayerMark(player, "&f_gonghun", 1)
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == "&f_gonghun" and mark.gain > 0 and mark.who and mark.who:objectName() == player:objectName() then
				if player:getMark("&f_gonghun") == 1 then --一阶
					if not player:hasSkill("liegong") then
						room:acquireSkill(player, "liegong")
					end
				elseif player:getMark("&f_gonghun") == 2 then --升至二阶
					room:broadcastSkillInvoke(self:objectName(), 1)
					local log = sgs.LogMessage()
					log.type = "$f_gonghun_1to2"
					log.from = player
					room:sendLog(log)
					if not player:hasSkill("tenyearliegong") then
						room:acquireSkill(player, "tenyearliegong")
					end
				elseif player:getMark("&f_gonghun") == 3 then --升至三阶
					room:broadcastSkillInvoke(self:objectName(), 2)
					local log = sgs.LogMessage()
					log.type = "$f_gonghun_2to3"
					log.from = player
					room:sendLog(log)
					if not player:hasSkill("f_mouliegong") then
						room:acquireSkill(player, "f_mouliegong")
					end
					room:setPlayerMark(player, "&f_mouliegong+heart", 1)
					room:setPlayerMark(player, "&f_mouliegong+diamond", 1)
					room:setPlayerMark(player, "&f_mouliegong+club", 1)
					room:setPlayerMark(player, "&f_mouliegong+spade", 1)
				elseif player:getMark("&f_gonghun") == 4 then --升至四阶
					room:broadcastSkillInvoke(self:objectName(), 3)
					local log = sgs.LogMessage()
					log.type = "$f_gonghun_3to4"
					log.from = player
					room:sendLog(log)
					if not player:hasSkill("smzy_shenliegong") then
						room:acquireSkill(player, "smzy_shenliegong")
					end
					room:loseHp(player, 1)
				elseif player:getMark("&f_gonghun") == 5 then --升至满阶
					room:broadcastSkillInvoke(self:objectName(), 4)
					local log = sgs.LogMessage()
					log.type = "$f_gonghun_4to5"
					log.from = player
					room:sendLog(log)
					local cds, mssb_gw = sgs.IntList(), math.random(0,99)
					for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
						local mssb = sgs.Sanguosha:getEngineCard(id)
						if mssb_gw < 23 or mssb_gw > 97 then
							if mssb:isKindOf("Fchixieren") and room:getCardPlace(id) ~= sgs.Player_DrawPile then
								cds:append(id)
								break
							end
						end
						if mssb_gw >= 23 then
							if mssb:isKindOf("Fmorigong") and room:getCardPlace(id) ~= sgs.Player_DrawPile then
								cds:append(id)
								break
							end
						end
					end
					if not cds:isEmpty() then
						room:shuffleIntoDrawPile(player, cds, self:objectName(), true)
						local ids = sgs.IntList()
						for _, id in sgs.qlist(room:getDrawPile()) do
							local cd = sgs.Sanguosha:getCard(id)
							if mssb_gw < 23 or mssb_gw > 97 then
								if cd:isKindOf("Fchixieren") then
									room:setTag("CXR_ID", sgs.QVariant(id))
									ids:append(id)
								end
							end
							if mssb_gw >= 23 then
								if cd:isKindOf("Fmorigong") then
									room:setTag("MRG_ID", sgs.QVariant(id))
									ids:append(id)
								end
							end
						end
						if not ids:isEmpty() then
							local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
							for _, i in sgs.qlist(ids) do
								dummy:addSubcard(i)
								break
							end
							room:obtainCard(player, dummy)
							dummy:deleteLater()
						end
					end
				end
				if player:getMark("&f_gonghun") > 1 then
					local choices = {}
					if player:getMark("f_kaigong_d1") == 0 then
						table.insert(choices, "1")
					end
					if player:getMark("f_kaigong_d2") == 0 then
						table.insert(choices, "2")
					end
					if player:getMark("f_kaigong_d3") == 0 then
						table.insert(choices, "3")
					end
					if player:getMark("f_kaigong_d4") == 0 then
						table.insert(choices, "4")
					end
					if #choices == 0 then return false end
					local choice = room:askForChoice(player, "f_gonghunDelete", table.concat(choices, "+"))
					--[[local rmove = tonumber(choice)
					room:addPlayerMark(player, "f_kaigong_d" .. rmove)]]
					if choice == "1" then room:addPlayerMark(player, "f_kaigong_d1")
					elseif choice == "2" then room:addPlayerMark(player, "f_kaigong_d2")
					elseif choice == "3" then room:addPlayerMark(player, "f_kaigong_d3")
					elseif choice == "4" then room:addPlayerMark(player, "f_kaigong_d4") end
				end
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.from and damage.from:objectName() == player:objectName() and player:getMark("&f_gonghun") > 1
			and damage.card and damage.card:isKindOf("Slash") then
				local n = player:getMark("&f_gonghun") - 1
				local log = sgs.LogMessage()
				log.type = "$f_gonghunMD"
				log.from = player
				log.to:append(damage.to)
				log.card_str = damage.card:toString()
				log.arg2 = n
				room:sendLog(log)
			    damage.damage = damage.damage + n
				data:setValue(damage)
			end
		end
	end,
}
f_gonghunMission = sgs.CreateTriggerSkill{
	name = "f_gonghunMission",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local card = nil
		if event == sgs.CardUsed then
			card = data:toCardUse().card
		else
			card = data:toCardResponse().m_card
		end
		if card and not card:isKindOf("SkillCard") then
			--升二阶
			if card:isKindOf("Slash") and not card:isVirtualCard()
			and player:getMark("&f_gonghun") == 1 and player:getMark("f_gonghun_1to2") == 0 then
				room:addPlayerMark(player, "f_gonghun_1to2")
			--升三阶
			elseif card:isKindOf("Slash") and (card:isRed() or card:isBlack()) and player:getMark("&f_gonghun") == 2 then
				if card:isRed() and player:getMark("f_gonghun_2to3_red") == 0 then
					room:addPlayerMark(player, "f_gonghun_2to3_red")
				end
				if card:isBlack() and player:getMark("f_gonghun_2to3_black") == 0 then
					room:addPlayerMark(player, "f_gonghun_2to3_black")
				end
			--升四阶
			elseif card:isKindOf("Slash") and card:getSuit() ~= sgs.Card_NoSuit and player:getMark("&f_gonghun") == 3 then
				if card:getSuit() == sgs.Card_Heart and player:getMark("f_gonghun_3to4_heart") == 0 then
					room:addPlayerMark(player, "f_gonghun_3to4_heart")
				end
				if card:getSuit() == sgs.Card_Diamond and player:getMark("f_gonghun_3to4_diamond") == 0 then
					room:addPlayerMark(player, "f_gonghun_3to4_diamond")
				end
				if card:getSuit() == sgs.Card_Club and player:getMark("f_gonghun_3to4_club") == 0 then
					room:addPlayerMark(player, "f_gonghun_3to4_club")
				end
				if card:getSuit() == sgs.Card_Spade and player:getMark("f_gonghun_3to4_spade") == 0 then
					room:addPlayerMark(player, "f_gonghun_3to4_spade")
				end
			--升满阶
			elseif card:isKindOf("Slash") and card:isVirtualCard() and (card:subcardsLength() == 0 or card:subcardsLength() >= 4)
			and player:getMark("&f_gonghun") == 4 and player:getMark("f_gonghun_4to5") == 0 then
				room:addPlayerMark(player, "f_gonghun_4to5")
			end
			--==升阶之路==--
			if not player:hasSkill("f_gonghun") then return false end
			if player:getMark("f_gonghun_1to2") > 0 then
				if room:askForSkillInvoke(player, self:objectName(), ToData("toTwo")) then
					room:setPlayerMark(player, "f_gonghun_1to2", 0)
					if math.random() <= 0.9 then
						room:addPlayerMark(player, "&f_gonghun")
					else
						local log = sgs.LogMessage()
						log.type = "$f_gonghun_fail"
						log.from = player
						room:sendLog(log)
						sgs.Sanguosha:playSystemAudioEffect("lose")
					end
				end
			elseif player:getMark("f_gonghun_2to3_red") > 0 and player:getMark("f_gonghun_2to3_black") > 0 then
				if room:askForSkillInvoke(player, self:objectName(), ToData("toThree")) then
					room:setPlayerMark(player, "f_gonghun_2to3_red", 0)
					room:setPlayerMark(player, "f_gonghun_2to3_black", 0)
					if math.random() <= 0.8 then
						room:addPlayerMark(player, "&f_gonghun")
					else
						local log = sgs.LogMessage()
						log.type = "$f_gonghun_fail"
						log.from = player
						room:sendLog(log)
						sgs.Sanguosha:playSystemAudioEffect("lose")
					end
				end
			elseif player:getMark("f_gonghun_3to4_heart") > 0 and player:getMark("f_gonghun_3to4_diamond") > 0
			and player:getMark("f_gonghun_3to4_club") > 0 and player:getMark("f_gonghun_3to4_spade") > 0 then
				if room:askForSkillInvoke(player, self:objectName(), ToData("toFour")) then
					room:setPlayerMark(player, "f_gonghun_3to4_heart", 0)
					room:setPlayerMark(player, "f_gonghun_3to4_diamond", 0)
					room:setPlayerMark(player, "f_gonghun_3to4_club", 0)
					room:setPlayerMark(player, "f_gonghun_3to4_spade", 0)
					if math.random() <= 0.7 then
						room:addPlayerMark(player, "&f_gonghun")
					else
						local log = sgs.LogMessage()
						log.type = "$f_gonghun_fail"
						log.from = player
						room:sendLog(log)
						sgs.Sanguosha:playSystemAudioEffect("lose")
					end
				end
			elseif player:getMark("f_gonghun_4to5") > 0 then
				if room:askForSkillInvoke(player, self:objectName(), ToData("toMaxFive")) then
					room:setPlayerMark(player, "f_gonghun_4to5", 0)
					if math.random() <= 0.6 then
						room:addPlayerMark(player, "&f_gonghun")
					else
						local log = sgs.LogMessage()
						log.type = "$f_gonghun_fail"
						log.from = player
						room:sendLog(log)
						sgs.Sanguosha:playSystemAudioEffect("lose")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shenhuangzhongg:addSkill(f_gonghun)
f_shenhuangzhongg_skin:addSkill("f_gonghun")
f_shenhuangzhongg_forSXS:addSkill("f_gonghun")
f_shenhuangzhongg:addRelateSkill("liegong")
f_shenhuangzhongg:addRelateSkill("tenyearliegong")
f_shenhuangzhongg:addRelateSkill("f_mouliegong")
f_shenhuangzhongg:addRelateSkill("smzy_shenliegong")
if not sgs.Sanguosha:getSkill("f_gonghunMission") then skills:append(f_gonghunMission) end
--“谋烈弓”
f_mouliegong_limit = sgs.CreateTriggerSkill{
	name = "f_mouliegong_limit",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.ChangeSlash},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		local slash = sgs.Sanguosha:cloneCard("slash")
		if use.card:isKindOf("Slash") and player:getWeapon() == nil then
	        slash:setSkillName(self:objectName())
			slash:addSubcards(use.card:getSubcards())
			use.card = slash
	    end
	    data:setValue(use)
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_mouliegong") and not player:hasFlag("f_mouliegong_RMnaturelimit")
	end,
}
f_mouliegong_record = sgs.CreateTriggerSkill{
	name = "f_mouliegong_record",
	global = true,
	priority = {4, 4, 4},
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.SlashMissed, sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
		    local use = data:toCardUse() if use.card:isKindOf("SkillCard") then return false end
			if use.from:hasSkill("f_mouliegong") then
				local suit = use.card:getSuit()
				if suit == sgs.Card_Heart and player:getMark("&f_mouliegong+heart") == 0 then
					room:addPlayerMark(player, "&f_mouliegong+heart")
				elseif suit == sgs.Card_Diamond and player:getMark("&f_mouliegong+diamond") == 0 then
					room:addPlayerMark(player, "&f_mouliegong+diamond")
				elseif suit == sgs.Card_Club and player:getMark("&f_mouliegong+club") == 0 then
					room:addPlayerMark(player, "&f_mouliegong+club")
				elseif suit == sgs.Card_Spade and player:getMark("&f_mouliegong+spade") == 0 then
					room:addPlayerMark(player, "&f_mouliegong+spade")
				end
			end
		elseif event == sgs.SlashMissed then --使用【闪】也可以记录
		    local effect = data:toSlashEffect()
			if effect.to:isAlive() and effect.to:hasSkill("f_mouliegong") then
				local suit = effect.jink:getSuit()
				if suit == sgs.Card_Heart and effect.to:getMark("&f_mouliegong+heart") == 0 then
					room:addPlayerMark(effect.to, "&f_mouliegong+heart")
				elseif suit == sgs.Card_Diamond and effect.to:getMark("&f_mouliegong+diamond") == 0 then
					room:addPlayerMark(effect.to, "&f_mouliegong+diamond")
				elseif suit == sgs.Card_Club and effect.to:getMark("&f_mouliegong+club") == 0 then
					room:addPlayerMark(effect.to, "&f_mouliegong+club")
				elseif suit == sgs.Card_Spade and effect.to:getMark("&f_mouliegong+spade") == 0 then
					room:addPlayerMark(effect.to, "&f_mouliegong+spade")
				end
			end
		elseif event == sgs.TargetConfirmed then
		    local use = data:toCardUse() if use.card:isKindOf("SkillCard") then return false end
		    for _, mhz in sgs.qlist(use.to) do
		        if mhz:hasSkill("f_mouliegong") then
		            local suit = use.card:getSuit()
					if suit == sgs.Card_Heart and mhz:getMark("&f_mouliegong+heart") == 0 then
						room:addPlayerMark(mhz, "&f_mouliegong+heart")
					elseif suit == sgs.Card_Diamond and mhz:getMark("&f_mouliegong+diamond") == 0 then
						room:addPlayerMark(mhz, "&f_mouliegong+diamond")
					elseif suit == sgs.Card_Club and mhz:getMark("&f_mouliegong+club") == 0 then
						room:addPlayerMark(mhz, "&f_mouliegong+club")
					elseif suit == sgs.Card_Spade and mhz:getMark("&f_mouliegong+spade") == 0 then
						room:addPlayerMark(mhz, "&f_mouliegong+spade")
					end
		        end
		    end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_mouliegong = sgs.CreateTriggerSkill{
	name = "f_mouliegong",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirmed, sgs.ConfirmDamage, sgs.Dying, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirmed then
		    local use = data:toCardUse()
			if not use.from:hasSkill(self:objectName()) or player:objectName() ~= use.from:objectName() or (use.to:length() ~= 1 and not player:hasFlag("f_mouliegong_RMtargetlimit")) or not use.card:isKindOf("Slash") then return false end
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName())
				local x = -1
				if player:getMark("&f_mouliegong+heart") > 0 then x = x + 1 end
				if player:getMark("&f_mouliegong+diamond") > 0 then x = x + 1 end
				if player:getMark("&f_mouliegong+club") > 0 then x = x + 1 end
				if player:getMark("&f_mouliegong+spade") > 0 then x = x + 1 end
				if x >= 1 then
					local card_ids = room:getNCards(x)
					room:fillAG(card_ids)
					for _, c in sgs.qlist(card_ids) do
						local card = sgs.Sanguosha:getCard(c)
						if card:getSuit() == sgs.Card_Heart and player:getMark("&f_mouliegong+heart") > 0 then
							room:addPlayerMark(player, "f_mouliegong_MoreDamage")
						end
						if card:getSuit() == sgs.Card_Diamond and player:getMark("&f_mouliegong+diamond") > 0 then
							room:addPlayerMark(player, "f_mouliegong_MoreDamage")
						end
						if card:getSuit() == sgs.Card_Club and player:getMark("&f_mouliegong+club") > 0 then
							room:addPlayerMark(player, "f_mouliegong_MoreDamage")
						end
						if card:getSuit() == sgs.Card_Spade and player:getMark("&f_mouliegong+spade") > 0 then
							room:addPlayerMark(player, "f_mouliegong_MoreDamage")
						end
					end
				end
				--[[if player:getMark("mouliegongf_MoreDamage") >= 3 then
					room:doLightbox("mou_huangzhong_formalAnimate") --阳光老男孩！
				end]]
				for _, p in sgs.qlist(use.to) do
					if player:getMark("&f_mouliegong+heart") > 0 then
						room:setPlayerCardLimitation(p, "use,response", ".|heart|.|.", false)
					end
					if player:getMark("&f_mouliegong+diamond") > 0 then
						room:setPlayerCardLimitation(p, "use,response", ".|diamond|.|.", false)
					end
					if player:getMark("&f_mouliegong+club") > 0 then
						room:setPlayerCardLimitation(p, "use,response", ".|club|.|.", false)
					end
					if player:getMark("&f_mouliegong+spade") > 0 then
						room:setPlayerCardLimitation(p, "use,response", ".|spade|.|.", false)
					end
					if not player:hasFlag("f_mouliegongSource") then
						room:setPlayerFlag(player, "f_mouliegongSource")
					end
					if not p:hasFlag("f_mouliegongTarget") then
						room:setPlayerFlag(p, "f_mouliegongTarget")
					end
				end
			end
		elseif event == sgs.ConfirmDamage then
		    local damage = data:toDamage()
			local xhy = damage.damage
			local n = player:getMark("f_mouliegong_MoreDamage")
			if damage.card and damage.to:hasFlag("f_mouliegongTarget") and damage.card:isKindOf("Slash") then
				if damage.from and player:objectName() == damage.from:objectName() and player:getMark("f_mouliegong_MoreDamage") > 0 then
					local log = sgs.LogMessage()
					log.type = "$f_mouliegongBUFF"
					log.from = player
					log.to:append(damage.to)
					log.card_str = damage.card:toString()
					log.arg2 = n
					room:sendLog(log)
			    	damage.damage = xhy + n
					data:setValue(damage)
				end
				room:removePlayerCardLimitation(damage.to, "use,response", ".|heart|.|.")
				room:removePlayerCardLimitation(damage.to, "use,response", ".|diamond|.|.")
				room:removePlayerCardLimitation(damage.to, "use,response", ".|club|.|.")
				room:removePlayerCardLimitation(damage.to, "use,response", ".|spade|.|.")
			end
		elseif event == sgs.Dying then
			local dying = data:toDying()
			if player:objectName() == dying.who:objectName() and player:hasFlag("f_mouliegongTarget") then --如果该角色是因为受到伤害而进入濒死，那么不会有此标志
				room:removePlayerCardLimitation(player, "use,response", ".|heart|.|.")
				room:removePlayerCardLimitation(player, "use,response", ".|diamond|.|.")
				room:removePlayerCardLimitation(player, "use,response", ".|club|.|.")
				room:removePlayerCardLimitation(player, "use,response", ".|spade|.|.")
				room:setPlayerFlag(player, "-f_mouliegongTarget")
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if player:hasFlag("f_mouliegongSource") and use.card:isKindOf("Slash") then
				room:clearAG()
				if player:getMark("&f_mouliegong+heart") > 0 then
					room:removePlayerMark(player, "&f_mouliegong+heart")
				end
				if player:getMark("&f_mouliegong+diamond") > 0 then
					room:removePlayerMark(player, "&f_mouliegong+diamond")
				end
				if player:getMark("&f_mouliegong+club") > 0 then
					room:removePlayerMark(player, "&f_mouliegong+club")
				end
				if player:getMark("&f_mouliegong+spade") > 0 then
					room:removePlayerMark(player, "&f_mouliegong+spade")
				end
				room:setPlayerFlag(player, "-f_mouliegongSource")
				local n = player:getMark("f_mouliegong_MoreDamage") --确保清除增伤标记
				if n > 0 then
					room:removePlayerMark(player, "f_mouliegong_MoreDamage", n)
				end
				for _, p in sgs.qlist(use.to) do --确保清除卡牌限制
					room:removePlayerCardLimitation(p, "use,response", ".|heart|.|.")
					room:removePlayerCardLimitation(p, "use,response", ".|diamond|.|.")
					room:removePlayerCardLimitation(p, "use,response", ".|club|.|.")
					room:removePlayerCardLimitation(p, "use,response", ".|spade|.|.")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("f_mouliegong") then skills:append(f_mouliegong) end
if not sgs.Sanguosha:getSkill("f_mouliegong_limit") then skills:append(f_mouliegong_limit) end
if not sgs.Sanguosha:getSkill("f_mouliegong_record") then skills:append(f_mouliegong_record) end
--“神烈弓”（直接照搬司马子元大佬的代码了QVQ，mbss）
smzy_shenliegongvs = sgs.CreateViewAsSkill{
	name = "smzy_shenliegong",
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
			return player:getMark("slg_fire_time") < x
		end
	end,
}
smzy_shenliegong = sgs.CreateTriggerSkill{
	name = "smzy_shenliegong",
	view_as_skill = smzy_shenliegongvs,
	events = {sgs.EventPhaseChanging, sgs.TargetConfirmed, sgs.CardFinished, sgs.DamageCaused, sgs.Damage},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				if player:getMark("slg_fire_time") > 0 then room:setPlayerMark(player, "slg_fire_time", 0) end
			end
		elseif event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if not use.from or player:objectName() ~= use.from:objectName() or (not use.card:isKindOf("FireSlash")) then return false end
			if use.card:getSkillName() ~= self:objectName() then return false end
			local n = use.card:subcardsLength()
			if n >= 1 then
				local msg = sgs.LogMessage()
				msg.from = player
				msg.type = "#smzy_FireLiegong1"
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
			room:addPlayerMark(player, "slg_fire_time", 1)
			local n = use.card:subcardsLength()
			if n >= 2 then
				local msg = sgs.LogMessage()
				msg.from = player
				msg.type = "#smzy_FireLiegong2"
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
					msg.type = "#smzy_FireLiegong3"
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
				if n >= 4 and damage.to and damage.to:isAlive() and damage.to:getSeat() ~= player:getSeat() then
					local to_lose = {}
					if not damage.to:getVisibleSkillList():isEmpty() then
						for _, _skill in sgs.qlist(damage.to:getVisibleSkillList()) do
							table.insert(to_lose, "-".._skill:objectName())
						end
					end
					if #to_lose > 0 then
						local msg = sgs.LogMessage()
						msg.from = player
						msg.type = "#smzy_FireLiegong4"
						msg.card_str = damage.card:toString()
						msg.arg = self:objectName()
						msg.to:append(damage.to)
						room:sendLog(msg)
						room:handleAcquireDetachSkills(damage.to, to_lose[math.random(1, #to_lose)])
					end
				end
			end
		end
	end,
}
smzy_shenliegong_tarmod = sgs.CreateTargetModSkill{
	name = "smzy_shenliegong_tarmod",
	pattern = ".",
	residue_func = function(self, from, card, to)
		local n = 0
		if from:hasSkill("smzy_shenliegong") and card:isKindOf("FireSlash") and card:getSkillName() == "smzy_shenliegong" then
			n = n + 9999
		end
		return n
	end,
	distance_limit_func = function(self, from, card, to)
		local n = 0
		if from:hasSkill("smzy_shenliegong") and card:isKindOf("FireSlash") and card:getSkillName() == "smzy_shenliegong" then
			n = n + 9999
		end
		return n
	end,
}
if not sgs.Sanguosha:getSkill("smzy_shenliegong") then skills:append(smzy_shenliegong) end
if not sgs.Sanguosha:getSkill("smzy_shenliegong_tarmod") then skills:append(smzy_shenliegong_tarmod) end

f_shanmengHSCard = sgs.CreateSkillCard{
	name = "f_shanmengHSCard",
	target_fixed = true,--false,
	will_throw = true,
	on_use = function(self, room, source, targets)
	    local choices = {}
		local yes = 0
		for _, p in sgs.qlist(room:getAllPlayers(true)) do --死亡角色加入表中
			if p:isDead() then
				table.insert(choices, p:getGeneralName())
				yes = 1
			end
		end
		if yes == 1 then
			table.insert(choices, "cancel")
			local choice = room:askForChoice(source, "f_shanmengHS-ask", table.concat(choices, "+")) --玩家选择一名死亡的角色
			if choice ~= "cancel" then
				for _, air in sgs.qlist(room:getAllPlayers(true)) do
					if air:isDead() and air:getGeneralName() == choice then --判断死亡的人的名字，跟选择的人是否符合，令其复活
						room:removePlayerMark(source, "@f_shanmengHS")
						room:doLightbox("$f_shanmengHS_toSXS")
						room:doAnimate(1, source:objectName(), air:objectName())
						room:revivePlayer(air) --复活吧，偶滴...对不起走错片场了
						if isSpecialOne(source, "神黄忠") then
							room:changeHero(air, "f_shenxusheng_forSHZ", true, true, false, true)
						elseif isSpecialOne(source, "神徐盛") then
							room:changeHero(air, "f_shenhuangzhongg_forSXS", true, true, false, true)
						end
						local dc = air:getMaxHp() - air:getHandcardNum()
						if dc > 0 then room:drawCards(air, dc, "f_shanmengHS")
						end
						local mhp = source:getMaxHp()
						local hp = source:getHp()
						--代价：
						if isSpecialOne(source, "神黄忠") then
							if source:getGeneralName() == "f_shenhuangzhongg" or source:getGeneralName() == "f_shenhuangzhongg_skin"
							or source:getGeneralName() == "f_shenhuangzhongg_forSXS" then
								room:changeHero(source, "sujiang", false, false, false, true)
							end
							if source:getGeneral2Name() == "f_shenhuangzhongg" or source:getGeneral2Name() == "f_shenhuangzhongg_skin"
							or source:getGeneral2Name() == "f_shenhuangzhongg_forSXS" then
								room:changeHero(source, "sujiang", false, false, true, true)
							end
						end
						if isSpecialOne(source, "神徐盛") then
							if source:getGeneralName() == "f_shenxusheng" or source:getGeneralName() == "f_shenxusheng_skin"
							or source:getGeneralName() == "f_shenxusheng_forSXS" then
								room:changeHero(source, "sujiangf", false, false, false, true)
							end
							if source:getGeneral2Name() == "f_shenxusheng" or source:getGeneral2Name() == "f_shenxusheng_skin"
							or source:getGeneral2Name() == "f_shenxusheng_forSXS" then
								room:changeHero(source, "sujiangf", false, false, true, true)
							end
						end
						if source:getMaxHp() ~= mhp then room:setPlayerProperty(source, "maxhp", sgs.QVariant(mhp)) end
						if source:getHp() ~= hp then room:setPlayerProperty(source, "hp", sgs.QVariant(hp)) end
						room:setPlayerMark(source, "&f_gonghun", 0)
					end
				end
			end
		end
	end,
}
f_shanmengHSVS = sgs.CreateViewAsSkill{
    name = "f_shanmengHS",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isKindOf("Fchixieren") or to_select:isKindOf("Fmorigong")
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = f_shanmengHSCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		if isSpecialOne(player, "神黄忠") and isSpecialOne(player, "神徐盛") then return false end
		for _, lvr in sgs.qlist(player:getAliveSiblings()) do
			if (isSpecialOne(player, "神黄忠") and isSpecialOne(lvr, "神徐盛"))
			or (isSpecialOne(player, "神徐盛") and isSpecialOne(lvr, "神黄忠")) then return false end
		end
		return isSpecialOne(player, "七夕纪念") and player:getMark("@f_shanmengHS") > 0
	end,
}
f_shanmengHS = sgs.CreateTriggerSkill{
	name = "f_shanmengHS",
	global = true,
	frequency = sgs.Skill_Limited,
	limit_mark = "@f_shanmengHS",
	view_as_skill = f_shanmengHSVS,
	events = {sgs.CardsMoveOneTime, sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() and move.to_place == sgs.Player_DiscardPile then
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("Fchixieren") then
						destroyEquip(room, move, "CXR_ID")
					elseif card:isKindOf("Fmorigong") then
						destroyEquip(room, move, "MRG_ID")
					end
				end
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.from and damage.from:objectName() == player:objectName() and player:hasSkill(self:objectName())
			and isSpecialOne(player, "神黄忠") and isSpecialOne(player, "神徐盛") then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shenhuangzhongg:addSkill(f_shanmengHS)
f_shenhuangzhongg_skin:addSkill("f_shanmengHS")
f_shenhuangzhongg_forSXS:addSkill("f_shanmengHS")

--==【灭世“神兵”】==--
--赤血刃
Fchixierens = sgs.CreateTriggerSkill{
	name = "Fchixieren",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.card and damage.card:isKindOf("Slash") and damage.from:objectName() == player:objectName() and player:isWounded() then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				local recover = damage.damage
				room:recover(player, sgs.RecoverStruct(player, nil, recover))
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getWeapon():isKindOf("Fchixieren")
	end,
}
Fchixieren = sgs.CreateWeapon{
	name = "_f_chixieren",
	class_name = "Fchixieren",
	range = 1,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, Fchixierens, false, true, false)
		room:acquireSkill(player, "f_mieshiSB")
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "Fchixieren", true, true)
		room:detachSkillFromPlayer(player, "f_mieshiSB", false, true)
	end,
}
Fchixieren:clone(sgs.Card_Diamond, 1):setParent(sdCard)
if not sgs.Sanguosha:getSkill("Fchixieren") then skills:append(Fchixierens) end
--没日弓
Fmorigongs = sgs.CreateTriggerSkill{
	name = "Fmorigong",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Predamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.card and damage.card:isKindOf("Slash") and damage.from:objectName() == player:objectName() and damage.to then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:loseHp(damage.to, damage.damage)
				return true
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getWeapon():isKindOf("Fmorigong")
	end,
}
Fmorigong = sgs.CreateWeapon{
	name = "_f_morigong",
	class_name = "Fmorigong",
	range = 6,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, Fmorigongs, false, true, false)
		room:acquireSkill(player, "f_mieshiSB")
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "Fmorigong", true, true)
		room:detachSkillFromPlayer(player, "f_mieshiSB", false, true)
	end,
}
Fmorigong:clone(sgs.Card_Heart, 12):setParent(sdCard)
if not sgs.Sanguosha:getSkill("Fmorigong") then skills:append(Fmorigongs) end
--<神兵灭世>--
f_mieshiSBCard = sgs.CreateSkillCard{
	name = "f_mieshiSBCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		local mssb = sgs.Sanguosha:getCard(self:getSubcards():first())
		if mssb:isKindOf("Fchixieren") then
			return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and sgs.Self:distanceTo(to_select) == 1
		elseif mssb:isKindOf("Fmorigong") then
			return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
		end
	end,
	on_effect = function(self, effect)
	    local room = effect.from:getRoom()
		local mssb = sgs.Sanguosha:getCard(self:getSubcards():first())
		if mssb:isKindOf("Fchixieren") then
			local hp = effect.from:getHp()
			room:loseHp(effect.from, hp)
			local mhp = effect.to:getMaxHp()
			room:loseMaxHp(effect.to, mhp)
		elseif mssb:isKindOf("Fmorigong") then
			local hp = effect.to:getHp()
			room:loseHp(effect.to, hp)
		end
	end,
}
f_mieshiSB = sgs.CreateViewAsSkill{
    name = "f_mieshiSB&",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isKindOf("Fchixieren") or to_select:isKindOf("Fmorigong")
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = f_mieshiSBCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isNude()
	end,
}
if not sgs.Sanguosha:getSkill("f_mieshiSB") then skills:append(f_mieshiSB) end
--==================--

--

--SD2 011 汤姆
f_TOM = sgs.General(extension, "f_TOM", "devil", 4, true, true, true)

--SD2 012 杰瑞
f_JERRY = sgs.General(extension, "f_JERRY", "devil", 3, true, true, true)



--

sgs.LoadTranslationTable{
    ["sdCard"] = "沙雕卡牌包",
	
	--无名小卒
	["f_wumingxiaozu"] = "无名小卒",
	["#f_wumingxiaozu"] = "只能一轮八十牌的垃圾",
	["designer:f_wumingxiaozu"] = "时光流逝FC",
	["cv:f_wumingxiaozu"] = "吃蛋挞的折棒,英雄杀",
	["illustrator:f_wumingxiaozu"] = "木美人,君桓文化",
	  --只能
	["f_zhineng"] = "只能",
	[":f_zhineng"] = "<font color='green'><b>每个回合限两次，</b></font>当一名角色受到伤害后，你可以令一名角色摸五张牌。",
	["$f_zhineng1"] = "众所周知，三国杀是一款非常平衡的游戏",
	["$f_zhineng2"] = "威震华夏的武圣关云长拥有将红牌当杀的神技，而历史角落的无名小卒却只能一轮八十牌",
	  --神寄
	["f_shenji"] = "神寄",
	[":f_shenji"] = "锁定技，你受到红色牌的伤害+1。",
	["$f_shenji1"] = "呃~",
	["$f_shenji2"] = "讨厌~",
	  --阵亡
	["~f_wumingxiaozu"] = "余香空留此，玉指轻揉散。",
	
	--蔡徐坤
	["f_CXK"] = "蔡徐坤",
	--["&f_CXK"] = "只因",
	["&f_CXK"] = "CXK",
	["#f_CXK"] = "王者归来",
	["designer:f_CXK"] = "时光流逝FC",
	["cv:f_CXK"] = "SWIN-S,蔡徐坤,幻昼,旋涡鸣人",
	["illustrator:f_CXK"] = "蔡徐坤",
	  --只因忆(记->鸡->只因)
	["f_zhiyinyi"] = "只因忆",
	[":f_zhiyinyi"] = "锁定技，分发起始手牌后，场上所有角色必须先行观看你举世闻名的影像片段：《只因你太美》，看完后才能开始进行游戏。",
	["$JiNiTaiMei"] = "anim=JiNiTaiMei",
	["$f_zhiyinyi"] = "（《只因你太美》）",
	  --坤历
	["f_kunli"] = "坤历",
	["f_kunlim"] = "坤历",
	["f_kunlix"] = "坤历",
	[":f_kunli"] = "锁定技，你于摸牌阶段的摸牌数有25%的概率*2.5（向下取整）；你于每回合的手牌上限有1-25%的概率*2.5（向上取整）。",
	["$f_kunli1"] = "击！",
	["$f_kunli2"] = "你干嘛啊哎哟~",
	["f_kunkun"] = "",
	  --坤学
	["f_kunstudy"] = "坤学",
	["f_kunstudyZYGet"] = "坤学",
	["f_kunstudyGetCardsFQCclear"] = "坤学",
	[":f_kunstudy"] = "<font color=\"#66FFCC\"><b>学习技，</b></font>锁定技，游戏开始时，(若你为CXK本尊,)你获取50点“只因”点数。你每使用或打出一张牌，进行一次判定，" ..
	"获取为你使用/打出的牌与判定牌点数之和的“只因”点数。\
	出牌阶段，你可以<font color='green'><b>点击此按钮</b></font>，支付“只因”点数兑换相应技能(或相应效果)（其中的所有技能每个出牌阶段皆限兑换一次，且皆限发动一次，" ..
	"发动并结算完成后你即失去该技能，但不会从技能库删去）：\
	1.运球帷幄，支付25点“只因”点数兑换；\
	2.铁山靠，支付50点“只因”点数兑换；\
	3.乌鸦坐飞机，支付75点“只因”点数兑换；\
	4.千鸟螺旋丸，支付100点“只因”点数兑换；\
	5.捂当，支付125点“只因”点数兑换；\
	6.蠢蠢欲动，支付150点“只因”点数兑换。\
	7.从牌堆随机获得一张红色牌和一张黑色牌，支付20点“只因”点数兑换。（每个出牌阶段限兑换两次<s>半</s>）", --名字取自汤姆老师的ikun提高班课程。
	["f_ZhiYin"] = "只因",
	["ks_GetCards"] = "从牌堆随机获得一张红色牌和一张黑色牌",
	["$f_kunstudy1"] = "你是我的，我是，你的，谁", --游戏开始获取点数；兑换牌
	["$f_kunstudy2"] = "第一次呀变成这样的我~你让我怎么去否认~", --兑换技能
	  --==坤学库==--
	    --1.运球帷幄
	  ["ks_YQWW"] = "运球帷幄",
	  ["ks_yqww"] = "运球帷幄",
	  ["ks_YQWWX"] = "运球帷幄",
	  ["ks_yqwwx"] = "运球帷幄",
	  ["ks_YQWWY"] = "运球帷幄",
	  ["ks_yqwwy"] = "运球帷幄",
	  ["ks_YQWWcontinue"] = "运球帷幄",
	  ["ks_yqwwcontinue"] = "运球帷幄",
	  [":ks_YQWW"] = "[限发动一次]出牌阶段，你可以获得你[上家/下家](一开始可选择)的一张手牌，然后将你的一张手牌交给[下家/上家]。若你以此法获得的牌与给出的牌不同且点数相同，" ..
	  "你可以消耗25点“只因”点数，摸一张牌并调换[]内的内容，重复此流程。",
	  ["YQWW_lastalive"] = "从上家开始",
	  ["YQWW_nextalive"] = "从下家开始",
	  ["#ks_YQWW"] = "请交给 %src 一张手牌，视为完成一次“运球”<br/> <b>提示</b>: 按照要求完成一次完美的“运球”，则可以再进行一次“运球”<br/>",
	  ["@ks_YQWWX"] = "请选择一张[不为你运来的手牌]，此牌将交给目标角色，视为完成一次“运球”",
	  ["~ks_YQWWX"] = "若你点【取消】，视为你选择将[你运来的手牌]交给目标角色",
	  ["@ks_YQWWY"] = "请选择一张[你运来的手牌]，此牌将交给目标角色，视为完成一次“运球”",
	  ["~ks_YQWWY"] = "选择该牌，点【确定】即可",
	  ["@ks_YQWWcontinue"] = "你可以消耗25点“只因”点数，重复此流程",
	  ["$ks_YQWW"] = "嗷嗷....嗷嗷嗷嗷....嗷嗷嗷嗷....",
	    --2.铁山靠
	  ["ks_TSK"] = "铁山靠",
	  [":ks_TSK"] = "[限发动一次]当你受到伤害时，你可以弃置等同于此次伤害数的牌，反弹此伤害。",
	  ["$ks_TSK"] = "（BGM：幻昼）",
	    --3.乌鸦坐飞机
	  ["ks_WYZFJ"] = "乌鸦坐飞机",
	  ["ks_wyzfj"] = "乌鸦坐飞机",
	  ["ks_WYZFJfinished"] = "乌鸦坐飞机",
	  [":ks_WYZFJ"] = "[限发动一次]出牌阶段，你可以选择任意张牌并选择等量其他角色，令这些角色随机获得你这些牌各一张，若如此做，视为你对这些角色使用一张无距离限制且不计次的【杀】。" ..
	  "然后你获得所有因此受到伤害的角色区域里各一张牌。",
	  ["ks_WYZFJdetachSkill"] = "",
	  ["$ks_WYZFJ"] = "再多一眼看一眼就会爆炸",
	    --4.千鸟螺旋丸
	  ["ks_QNLXW"] = "千鸟螺旋丸",
	  ["ks_qnlxw"] = "千鸟螺旋丸",
	  ["ks_QNLXWS"] = "千鸟螺旋丸",
	  ["ks_qnlxws"] = "千鸟螺旋丸",
	  [":ks_QNLXW"] = "[限发动一次]出牌阶段，你可以弃置一张黑色手牌，进行一次“手搓螺旋丸”。若成功，则你可以重复或终止流程；若失败，你终止流程。\
	  <font color='blue'><b>注：“手搓螺旋丸”的成功率为80%/X（X初始为1，每成功进行一次“手搓螺旋丸”流程，X+1；流程终止后，X重置为1）</b></font>\
	  该“手搓螺旋丸”流程终止后，你可以对一名角色造成X-1点雷电伤害。",
	  ["@ks_QNLXWS-kd_lxgannnnnnnnnn"] = "你可以弃置一张黑色手牌，进行一次“手搓螺旋丸”",
	  ["~ks_QNLXWS"] = "若你点【取消】，视为你终止流程",
	  ["ks_QNLXW_xhzYBSBS"] = "你可以选择一名露出只因脚的小黑子，对其造成 %src 点雷电伤害（小黑子，油饼食不食？）",
	  ["$ks_QNLXW"] = "裤裆，拉线杆！",
	    --5.捂当
	  ["ks_WD"] = "捂当",
	  [":ks_WD"] = "[限发动一次]当你受到伤害时，你可以获得X点护甲并摸X张牌，然后若X>1，你翻面。（X为此次的伤害值）",
	  ["$ks_WD"] = "再近一点靠近点快被融化",
	    --6.蠢蠢欲动
	  ["ks_CCYD"] = "蠢蠢欲动",
	  ["ks_ccyd"] = "蠢蠢欲动",
	  ["ks_CCYDcontinue"] = "蠢蠢欲动",
	  ["ks_ccydcontinue"] = "蠢蠢欲动",
	  [":ks_CCYD"] = "[限发动一次]出牌阶段，你可以选择一名其他角色，获得其一张牌并展示，然后判定：若判定牌与此牌颜色相同，你可以重复此流程；否则你获得判定牌并失去1点体力。",
	  ["@ks_CCYDcontinue"] = "你可以重复此流程",
	  ["~ks_CCYDcontinue"] = "若想重复此流程点【确定】；点【取消】则结束流程",
	  ["$ks_CCYD"] = "迎面走来的你让我如此蠢蠢欲动，这种感觉我从未有Cause I got a crush on you，who you",
	  --==========--
	  --爱坤
	["f_ikun"] = "爱坤",
	[":f_ikun"] = "锁定技，游戏开始时，随机任意名其他角色成为“ikun”，获得技能“坤学”并获取20点“只因”点数。然后于游戏进行中：\
	○每当你因“ikun”回复1点体力，其与你各摸一张牌；\
	○每当“ikun”对你造成1点伤害，其须自弃一张牌；\
	○每当“ikun”的摸牌阶段，你可以取消其摸牌，改为你摸等量的牌然后交给其等量的牌；\
	○每当“ikun”使用牌指定不为“ikun”(且不为你)的角色为目标时，有一定概率让其成为“ikun”（初始概率0%，其每成为“ikun”使用牌的目标概率就增加2.5%，直到让其成为“ikun”为止）。",
	["@f_ikunDraw"] = "[爱坤]支配其摸牌阶段",
	["#f_ikunGiveCards"] = "请交给你的ikun %src 等同于此次你的摸牌数的牌",
	["$f_ikun1"] = "只因你实在是太美，baby~只因你太美，baby~", --游戏开始
	["$f_ikun2"] = "我应该拿你怎样，Uh 所有人都在看着你", --“ikun”治愈了你
	["$f_ikun3"] = "我的心总是不安，Oh 我现在已病入膏肓", --“ikun”伤害了你
	["$f_ikun4"] = "Eh Oh，难道 真的 因你而疯狂吗", --“ikun”的摸牌阶段由你支配
	["$f_ikun5"] = "我本来不是这种人，因你变成奇怪的人", --“ikun”让更多不为“ikun”的人成为“ikun”
	  --阵亡
	["~f_CXK"] = "顶流，从不会褪去......下一次，再待我卷土重来。",
	
	--红色风暴&蓝色妖姬
	["f_CP"] = "红色风暴＆蓝色妖姬", --成有才＆皮小浪
	["&f_CP"] = "红蓝兄弟",
	["#f_CP"] = "暴风赤红＆忧蓝罗密欧",
	["designer:f_CP"] = "时光流逝FC",
	["cv:f_CP"] = "成有才,Duke Dumont;皮小浪,告五人;Ramin Djawadi,Tom Morello",
	["illustrator:f_CP"] = "成有才,皮小浪,环太平洋",
	  --形源
	["f_xingyuan"] = "形源",
	["f_xingyuans"] = "形源",
	["f_xingyuanRes"] = "形源-形态重置",
	[":f_xingyuan"] = "<font color=\"#0066FF\"><b>形态</b></font>转换技，<font color=\"#0066FF\"><b>形态</b></font><font color='orange'><b>解锁技，</b></font>" ..
	"游戏开始时，你为初始形态，并将“<font color=\"#FFD700\"><b>黄金切尔西</b></font>”置入你的装备区（此装备离开你装备区时销毁，且你失去1点体力）。" ..
	"游戏进程中，有三种特殊形态等待你去解锁，解锁条件(每种条件每局各限触发一次)分别如下：\
	1.<font color='red'><b>“红色风暴”形态</b></font>（此形态专属技能见<font color='red'><b>红字</b></font>）\
	<b>解锁条件：</b>回合外，当你失去装备区里的“<font color=\"#FFD700\"><b>黄金切尔西</b></font>”时，你令当前回合角色成为你的上家，" ..
	"弃置其装备区里的一张牌并对其造成X点伤害(X为其此时装备区里的牌数)，然后你解锁并转换为此形态，摸两张牌，" ..
	"且下回合<font color='black'><b>◐形态重置◑</b></font>无效。\
	2.<font color='blue'><b>“蓝色妖姬”形态</b></font>（此形态专属技能见<font color='blue'><b>蓝字</b></font>）\
	<b>解锁条件：</b>回合外，当一名在你攻击范围内的男性角色使用【杀】选择不为你的唯一目标时，你可以对其使用一张【杀】，若你以此法使用的【杀】造成伤害，该角色此次使用的【杀】无效，" ..
	"且你令该角色此次使用的【杀】的目标成为你的上家，然后你解锁并转换为此形态，回复1点体力，" ..
	"且下回合<font color='black'><b>◐形态重置◑</b></font>无效。\
	3.<font color='red'><b>“环太平洋·暴风赤红”形态</b></font>（此形态专属技能见<font color=\"#01A5AF\"><b>青字</b></font>）\
	<b>解锁条件：</b>当你进入濒死状态时，你废除防具栏和两个坐骑栏，回复体力至3点并将手牌补至体力上限，然后你解锁并转换为此形态，进行一个额外的回合，" ..
	"且该回合<font color='black'><b>◐形态重置◑</b></font>无效。\
	4.<font color='blue'><b>“环太平洋·忧蓝罗密欧”形态</b></font>（此形态存档已于2020年丢失，<font color='black'><b>无法解锁</b></font>。）\
	<b>******</b>\
	<font color='black'><b>◐形态重置◑</b></font>：锁定技，回合开始时或当你受到伤害时，(若你不为初始形态)你换回初始形态、" ..
	"(若你装备区里没有“<font color=\"#FFD700\"><b>黄金切尔西</b></font>”)将“<font color=\"#FFD700\"><b>黄金切尔西</b></font>”置入你的装备区。",
	["@CP_Red_unlock"] = "解锁“红色风暴”形态",
	["@CP_Bluck_unlock"] = "解锁“蓝色妖姬”形态",
	["@CP_CrimsonTyphoon_unlock"] = "解锁“环太平洋·暴风赤红”形态",
	["@f_xingyuan_bluck-slash"] = "你可以对%src使用一张【杀】，若成功造成伤害则解锁“蓝色妖姬”形态",
	["$to_CP_Red"] = "英雄可以受委屈，但是你不能踩我的切尔西......",
	["$to_CP_Bluck"] = "没有蓝色妖姬的爱情，就像一盘散沙......",
	["$to_CP_CrimsonTyphoon"] = "image=image/animate/to_CP_CrimsonTyphoon.png",
	["$f_xingyuan1"] = "英雄可以受委屈，但是你不能踩我的 切尔西！（SuPreme 至高无上）", --解锁“红色风暴”形态
	["$f_xingyuan2"] = "蓝色妖姬你不爱，非要在渣男身上找存在。（没有蓝色妖姬的爱情，就像一盘散沙）", --解锁“蓝色妖姬”形态
	["$f_xingyuan3"] = "（BGM:Pacific Rim）", --解锁“环太平洋·暴风赤红”形态
	  --换形
	["f_huanxing"] = "换形",
	[":f_huanxing"] = "<font color=\"#0066FF\"><b>形态</b></font>转换技，出牌阶段限一次，你可以按照以下规则弃牌，则你转换为对应的你已于本局解锁的特殊形态：\
	1.弃置两张红色牌，转换为“红色风暴”形态；\
	2.弃置两张黑色牌，转换为“蓝色妖姬”形态；\
	3.弃置一张红色手牌、一张黑色手牌和一张装备区里的牌，转换为“环太平洋·暴风赤红”形态。",
	["f_huanxing:Red"] = "弃置两张红色牌，转换为“红色风暴”形态",
	["f_huanxing:Bluck"] = "弃置两张黑色牌，转换为“蓝色妖姬”形态",
	["f_huanxing:CrimsonTyphoon"] = "弃置一张红色手牌、一张黑色手牌和一张装备区里的牌，转换为“环太平洋·暴风赤红”形态",
	["f_huanxing_red"] = "换形",
	["@f_huanxing_red"] = "你可以弃置两张红色牌，转换为“红色风暴”形态",
	["f_huanxing_bluck"] = "换形",
	["@f_huanxing_bluck"] = "你可以弃置两张黑色牌，转换为“蓝色妖姬”形态",
	["f_huanxing_ct"] = "换形",
	["@f_huanxing_ct"] = "你可以弃置一张红色手牌、一张黑色手牌和一张装备区里的牌，转换为“红色风暴”形态",
	["~f_huanxing_ct"] = "先选定不同颜色的手牌各一张，然后再选定装备区里的牌",
	["$f_huanxing1"] = "（BGM:Red Light Green Light）", --转换为“红色风暴”形态
	["$f_huanxing2"] = "（BGM:爱人错过）", --转换为“蓝色妖姬”形态
	["$f_huanxing3"] = "（BGM:Pacific Rim）", --转换为“环太平洋·暴风赤红”形态
	  --“红色风暴”形态
	  ["CP_Red"] = "红色风暴",
	    --飓风
	  ["red_jufeng"] = "飓风",
	  ["red_jufengBuff"] = "飓风",
	  [":red_jufeng"] = "<font color='red'><b>锁定技。你使用红色基本牌无次数限制、红色锦囊牌伤害+1、每使用一张红色装备牌就摸一张牌。</b></font>",
	  ["$red_jufeng1"] = "惹得天怒地也恼，人间再无红颜笑，留一半相思上大道...",
	  ["$red_jufeng2"] = "怕什么天道轮回，什么魄散魂飞，若没有你那才叫可悲...",
	    --阵亡
	  ["~CP_Red"] = "",
	  ----
	  --“蓝色妖姬”形态
	  ["CP_Bluck"] = "蓝色妖姬",
	    --优雅
	  ["bluck_youya"] = "优雅",
	  ["bluck_youyaBuff"] = "优雅",
	  [":bluck_youya"] = "<font color='blue'><b>锁定技。你使用黑色基本牌无距离限制、黑色锦囊牌不可被目标响应、每使用一张黑色装备牌就回复1点体力。</b></font>",
	  ["$bluck_youya1"] = "（BGM:我们是一只小小的羊）前奏",
	  ["$bluck_youya2"] = "我们是一群小小的羊......",
	    --阵亡
	  ["~CP_Bluck"] = "",
	  ----
	  --“环太平洋·暴风赤红”形态
	  ["CP_CrimsonTyphoon"] = "暴风赤红",
	    --旋刀雷云阵
	  ["bfch_xdlyz"] = "旋刀雷云阵",
	  ["bfch_xdlyzAMX"] = "旋刀雷云阵",
	  [":bfch_xdlyz"] = "出牌阶段限一次，你可以减至多3点体力上限，视为对一名其他角色使用等量的雷【杀】（不计次）。此阶段结束时，你加Y点体力上限。" ..
	  "（Y为此阶段你以此法造成的伤害值；<font color='red'><b>注意:无亡语效果</b></font>）",
	  ["bfch_xdlyz:1"] = "减1点体力上限，视为对其使用1张雷【杀】",
	  ["bfch_xdlyz:2"] = "减2点体力上限，视为对其连续使用2张雷【杀】",
	  ["bfch_xdlyz:3"] = "减3点体力上限，视为对其连续使用3张雷【杀】",
	  ["$ThunderCloudFormation"] = "anim=ThunderCloudFormation",
	  ["$bfch_xdlyz"] = "（雷云阵形，准备！）",
	  ["$bfch_xdlyzAMX"] = "（雷云阵形，准备！）", --游戏中实际播放的是这个
	    --(I-22)等离子炮
	  ["bfch_dlzp"] = "等离子炮",
	  ["bfch_dlzpXL"] = "等离子炮",
	  [":bfch_dlzp"] = "<b><font color=\"#00FFFF\">蓄</font><font color=\"#99CCFF\">力</font><font color='blue'>技</font>（0/<font color='blue'>3</font>）</b>，" ..
	  "出牌阶段限一次，你可以消耗Z点蓄力点，对一名其他角色造成Z-1点雷电伤害并且有Z/3的概率将其翻为背面。当你转换为此形态后或回合结束时，你获得1点蓄力点。（1≤Z≤3）",
	  ["@fcXuLi"] = "蓄力点",
	  ["fcXuLiMAX"] = "",
	  ["bfch_dlzp:1"] = "消耗1点蓄力点，对其造成0点雷电伤害并有1/3的概率将其翻为背面",
	  ["bfch_dlzp:2"] = "消耗2点蓄力点，对其造成1点雷电伤害并有2/3的概率将其翻为背面",
	  ["bfch_dlzp:3"] = "消耗3点蓄力点，对其造成2点雷电伤害并100%将其翻为背面",
	  ["$bfch_dlzp"] = "（蓄力声）",
	    --冷冻液
	  ["bfch_ldy"] = "冷冻液",
	  ["bfch_ldyClear"] = "冷冻液",
	  [":bfch_ldy"] = "出牌阶段限一次，你可以弃置所有手牌（至少一张），令一名攻击范围内的其他角色不能使用或打出牌直到此阶段结束并受到1点冰冻伤害。",
	  ["$bfch_ldy"] = "（喷射声）",
	    --阵亡
	  ["~CP_CrimsonTyphoon"] = "",
	  --==专属装备==--
	  --<黄金切尔西>--
	  ["_f_goldenchelsea"] = "黄金切尔西",
	  ["Fgoldenchelsea"] = "黄金切尔西",
	  ["Fgoldenchelseas"] = "黄金切尔西",
	  ["Fgoldenchelseat"] = "黄金切尔西",
	  ["Fgoldenchelsea_remove"] = "黄金切尔西-失去",
	  ["#DestroyEqiup"] = "%card 被销毁",
	  [":_f_goldenchelsea"] = "装备牌·宝物<br /> <b>宝物技能</b>：锁定技，你与其他角色的距离-1；其他角色与你的距离+1。<br /> 此装备离开装备区时销毁，且失去该装备的角色失去1点体力。",
	  ----
	  --阵亡
	["~f_CP"] = "小美，为什么......",
	
	--宇宙丁真
	["f_UniverseYYDZ"] = "宇宙丁真",
	["#f_UniverseYYDZ"] = "丁真宇宙",
	["designer:f_UniverseYYDZ"] = "时光流逝FC",
	["cv:f_UniverseYYDZ"] = "丁真珍珠",
	["illustrator:f_UniverseYYDZ"] = "丁真珍珠",
	  --义眼
	["f_yiyan"] = "义眼",
	[":f_yiyan"] = "<font color='red'><b>每名角色限一次，</b></font>当其使用[技能卡牌]时，你可以弃置一张手牌，对此[技能卡牌]进行一次“真假鉴定”：\
	<font color=\"#4DB873\"><b>√</b></font>鉴定为<font color=\"#4DB873\"><b>真</b></font>：该角色摸两张牌；\
	<font color='red'><b>×</b></font>鉴定为<font color='red'><b>假</b></font>：该角色<font color='blue'><s>此次使用的[技能卡牌]无效</s></font>弃置两张牌。",
	["@f_yiyan-invoke"] = "你可以弃置一张手牌，对[技能卡牌]<font color='yellow'><b>%src</b></font>进行“真假鉴定”",
	["@f_yiyan-discard"] = "打假是每个宇宙人的1！5！（请弃置两张牌）",
	["f_yiyan:yes"] = "一眼丁真，鉴定为：真",
	["f_yiyan:no"] = "一眼丁真，鉴定为：假",
	["$f_yiyan1"] = "（鉴定为[真]）芝士雪豹。", --鉴定为真
	["$f_yiyan2"] = "（鉴定为[假]）", --鉴定为假
	  --顶蒸
	["f_dingzheng"] = "顶蒸",
	["f_dingzhengg"] = "顶蒸",
	["f_dingzheng_equipEnd"] = "顶蒸",
	[":f_dingzheng"] = "每个回合限一次，当一名角色使用<b>有目标角色</b>的非虚拟非转化牌时，你可以弃置一张牌，进行一次“万物鉴定”，将此牌鉴定为一种你未于本局鉴定过的牌名的牌。" ..
	"若如此做，且你以此法鉴定的牌为：\
	1.基本牌或锦囊牌，改为该角色<font color='black'><b>无视限制</b></font>将此牌当作你鉴定的牌使用（通常情况下目标角色不变）；\
	2.装备牌，改为该角色视为装备你鉴定的牌，直到有一张与你鉴定的牌相同副类别的牌进入其装备区。\
	<font color='red'><b>◕鉴定范围：标准包(不包括【闪】和【无懈可击】)、军争篇、应变篇(不包括【随机应变】)</b></font>\
	<font color='blue'><b>◮鉴定限制：仅弃置的牌点数为字母，才可以鉴定出装备牌</b></font>",
	[":f_dingzheng11"] = "每个回合限一次，当一名角色使用<b>有目标角色</b>的非虚拟非转化牌时，你可以弃置一张牌，进行一次“万物鉴定”，将此牌鉴定为一种你未于本局鉴定过的牌名的牌。" ..
	"若如此做，且你以此法鉴定的牌为：\
	1.基本牌或锦囊牌，改为该角色<font color='black'><b>无视限制</b></font>将此牌当作你鉴定的牌使用（通常情况下目标角色不变）；\
	2.装备牌，改为该角色视为装备你鉴定的牌，直到有一张与你鉴定的牌相同副类别的牌进入其装备区。\
	<font color='red'><b>◕鉴定范围：标准包(不包括【闪】和【无懈可击】)、军争篇、应变篇(不包括【随机应变】)</b></font>\
	<font color='blue'><b>◮鉴定限制：仅弃置的牌点数为字母，才可以鉴定出装备牌</b></font>\
	<font color=\"#6600CC\"><b>已鉴定：%arg11</b></font>",
	["@f_dingzheng-invoke"] = "你可以弃置一张牌，进行“万物鉴定”<br/> 提示：弃置点数为字母的牌，可以鉴定出装备牌",
	--==鉴定区（6+18+30=54）==--
	  --<基本牌>（6）
	    ["f_dingzheng:Basic"] = "基本牌",
		--【杀】
		  ["$udz_Slash"] = "刈剡丁真，鉴定为【<font color='yellow'><b>杀</b></font>】",
		--【桃】
		  ["$udz_Peach"] = "医研丁真，鉴定为【<font color='yellow'><b>桃</b></font>】",
		--【火杀】
		  ["$udz_FireSlash"] = "熠炎丁真，鉴定为【<font color='yellow'><b>火杀</b></font>】",
		--【雷杀】
		  ["$udz_ThunderSlash"] = "佚魇丁真，鉴定为【<font color='yellow'><b>雷杀</b></font>】",
		--【酒】
		  ["$udz_Analeptic"] = "溢颜丁真，鉴定为【<font color='yellow'><b>酒</b></font>】",
		--【冰杀】
		  ["$udz_IceSlash"] = "抑演丁真，鉴定为【<font color='yellow'><b>冰杀</b></font>】",
	  --<锦囊牌>（18）
	    ["f_dingzheng:Trick"] = "锦囊牌",
		--[标准包]（11）
		  ["f_dingzheng:Trick_BZ"] = "标准包",
		  --【过河拆桥】
		    ["$udz_Dismantlement"] = "意湮丁真，鉴定为【<font color='yellow'><b>过河拆桥</b></font>】",
		  --【顺手牵羊】
		    ["$udz_Snatch"] = "易焉丁真，鉴定为【<font color='yellow'><b>顺手牵羊</b></font>】",
		  --【借刀杀人】
		    ["$udz_Collateral"] = "以掩丁真，鉴定为【<font color='yellow'><b>借刀杀人</b></font>】",
			["f_dingzhengCollateral"] = "顶蒸-借刀杀人",
			["f_dingzhengcollateral"] = "顶蒸-借刀杀人",
			["@f_dingzhengCollateral-card"] = "你已通过“万物鉴定”将此牌鉴定为了【借刀杀人】，请使用之",
		  --【无中生有】
		    ["$udz_ExNihilo"] = "艺衍丁真，鉴定为【<font color='yellow'><b>无中生有</b></font>】",
		  --【南蛮入侵】
		    ["$udz_SavageAssault"] = "异烟丁真，鉴定为【<font color='yellow'><b>南蛮入侵</b></font>】",
		  --【万箭齐发】
		    ["$udz_ArcheryAttack"] = "亿雁丁真，鉴定为【<font color='yellow'><b>万箭齐发</b></font>】",
		  --【五谷丰登】
		    ["$udz_AmazingGrace"] = "益宴丁真，鉴定为【<font color='yellow'><b>五谷丰登</b></font>】",
		  --【桃园结义】
		    ["$udz_GodSalvation"] = "义言丁真，鉴定为【<font color='yellow'><b>桃园结义</b></font>】",
		  --【决斗】
		    ["$udz_Duel"] = "毅严丁真，鉴定为【<font color='yellow'><b>决斗</b></font>】",
		  --【乐不思蜀】
		    ["$udz_Indulgence"] = "逸筵丁真，鉴定为【<font color='yellow'><b>乐不思蜀</b></font>】",
		  --【闪电】
		    ["$udz_Lightning"] = "移阎丁真，鉴定为【<font color='yellow'><b>闪电</b></font>】",
		--[军争篇+应变篇]（7）
		  ["f_dingzheng:Trick_JY"] = "军争篇+应变篇",
		  --【铁索连环】
		    ["$udz_IronChain"] = "依檐丁真，鉴定为【<font color='yellow'><b>铁索连环</b></font>】",
		  --【火攻】
		    ["$udz_FireAttack"] = "疑焰丁真，鉴定为【<font color='yellow'><b>火攻</b></font>】",
		  --【兵粮寸断】
		    ["$udz_SupplyShortage"] = "忆咽丁真，鉴定为【<font color='yellow'><b>兵粮寸断</b></font>】",
		  --【水淹七军】
		    ["$udz_Drowning"] = "已淹丁真，鉴定为【<font color='yellow'><b>水淹七军</b></font>】",
		  --【洞烛先机】
		    ["$udz_Dongzhuxianji"] = "弈验丁真，鉴定为【<font color='yellow'><b>洞烛先机</b></font>】",
		  --【逐近弃远】
		    ["$udz_Zhujinqiyuan"] = "宜沿丁真，鉴定为【<font color='yellow'><b>逐近弃远</b></font>】",
		  --【出其不意】
		    ["$udz_Chuqibuyi"] = "一艳丁真，鉴定为【<font color='yellow'><b>出其不意</b></font>】",
	  --<装备牌>（30）
	    ["f_dingzheng:Equip"] = "装备牌",
		--[武器牌]（13）
		  ["f_dingzheng:Equip_Weapon"] = "武器牌",
		  --【诸葛连弩】
		    ["$udz_Crossbow"] = "音源丁真，鉴定为【<font color='yellow'><b>诸葛连弩</b></font>】",
			["f_dingzhengCrossbow"] = "诸葛连弩",
			[":f_dingzhengCrossbow"] = "视为装备技，你视为装备【诸葛连弩】。",
		  --【青釭剑】
		    ["$udz_QinggangSword"] = "与予丁真，鉴定为【<font color='yellow'><b>青釭剑</b></font>】",
			["f_dingzhengQinggangSword"] = "青釭剑",
			[":f_dingzhengQinggangSword"] = "视为装备技，你视为装备【青釭剑】。",
		  --【雌雄双股剑】
		    ["$udz_DoubleSword"] = "鸳鸯丁真，鉴定为【<font color='yellow'><b>雌雄双股剑</b></font>】",
			["f_dingzhengDoubleSword"] = "雌雄双股剑",
			[":f_dingzhengDoubleSword"] = "视为装备技，你视为装备【雌雄双股剑】。",
		  --【寒冰剑】
		    ["$udz_IceSword"] = "永喑丁真，鉴定为【<font color='yellow'><b>寒冰剑</b></font>】",
			["f_dingzhengIceSword"] = "寒冰剑",
			[":f_dingzhengIceSword"] = "视为装备技，你视为装备【寒冰剑】。",
		  --【青龙偃月刀】
		    ["$udz_Blade"] = "偃月丁真，鉴定为【<font color='yellow'><b>青龙偃月刀</b></font>】",
			["f_dingzhengBlade"] = "青龙偃月刀",
			[":f_dingzhengBlade"] = "视为装备技，你视为装备【青龙偃月刀】。",
		  --【丈八蛇矛】
		    ["$udz_Spear"] = "焉瘾丁真，鉴定为【<font color='yellow'><b>丈八蛇矛</b></font>】",
			["f_dingzhengSpear"] = "丈八蛇矛",
			["f_dingzhengSpears"] = "丈八蛇矛",
			[":f_dingzhengSpear"] = "视为装备技，你视为装备【丈八蛇矛】。",
		  --【贯石斧】
		    ["$udz_Axe"] = "硬压丁真，鉴定为【<font color='yellow'><b>贯石斧</b></font>】",
			["f_dingzhengAxe"] = "贯石斧",
			[":f_dingzhengAxe"] = "视为装备技，你视为装备【贯石斧】。",
		  --【方天画戟】
		    ["$udz_Halberd"] = "英应丁真，鉴定为【<font color='yellow'><b>方天画戟</b></font>】",
			["f_dingzhengHalberd"] = "方天画戟",
			[":f_dingzhengHalberd"] = "视为装备技，你视为装备【方天画戟】。",
		  --【麒麟弓】
		    ["$udz_KylinBow"] = "远曳丁真，鉴定为【<font color='yellow'><b>麒麟弓</b></font>】",
			["f_dingzhengKylinBow"] = "麒麟弓",
			[":f_dingzhengKylinBow"] = "视为装备技，你视为装备【麒麟弓】。",
		  --【古锭刀】
		    ["$udz_GudingBlade"] = "愉乐丁真，鉴定为【<font color='yellow'><b>古锭刀</b></font>】",
			["f_dingzhengGudingBlade"] = "古锭刀",
			[":f_dingzhengGudingBlade"] = "视为装备技，你视为装备【古锭刀】。",
		  --【朱雀羽扇】
		    ["$udz_Fan"] = "咏燚丁真，鉴定为【<font color='yellow'><b>朱雀羽扇</b></font>】",
			["f_dingzhengFan"] = "朱雀羽扇",
			[":f_dingzhengFan"] = "视为装备技，你视为装备【朱雀羽扇】。",
		  --【乌铁锁链】
		    ["$udz_Wutiesuolian"] = "鹰眼丁真，鉴定为【<font color='yellow'><b>乌铁锁链</b></font>】",
			["f_dingzhengWutiesuolian"] = "乌铁锁链",
			[":f_dingzhengWutiesuolian"] = "视为装备技，你视为装备【乌铁锁链】。",
		  --【五行鹤翎扇】
		    ["$udz_Wuxinghelingshan"] = "印羽丁真，鉴定为【<font color='yellow'><b>五行鹤翎扇</b></font>】",
			["f_dingzhengWuxinghelingshan"] = "五行鹤翎扇",
			[":f_dingzhengWuxinghelingshan"] = "视为装备技，你视为装备【五行鹤翎扇】。",
		--[防具牌]（6）
		  ["f_dingzheng:Equip_Armor"] = "防具牌",
		  --【八卦阵】
		    ["$udz_EightDiagram"] = "阴阳丁真，鉴定为【<font color='yellow'><b>八卦阵</b></font>】",
			["f_dingzhengEightDiagram"] = "八卦阵",
			[":f_dingzhengEightDiagram"] = "视为装备技，你视为装备【八卦阵】。",
		  --【仁王盾】
		    ["$udz_RenwangShield"] = "隐预丁真，鉴定为【<font color='yellow'><b>仁王盾</b></font>】",
			["f_dingzhengRenwangShield"] = "仁王盾",
			[":f_dingzhengRenwangShield"] = "视为装备技，你视为装备【仁王盾】。",
		  --【藤甲】
		    ["$udz_Vine"] = "遇焱丁真，鉴定为【<font color='yellow'><b>藤甲</b></font>】",
			["f_dingzhengVine"] = "藤甲",
			[":f_dingzhengVine"] = "视为装备技，你视为装备【藤甲】。",
		  --【白银狮子】
		    ["$udz_SilverLion"] = "银吟丁真，鉴定为【<font color='yellow'><b>白银狮子</b></font>】",
			["f_dingzhengSilverLion"] = "白银狮子",
			[":f_dingzhengSilverLion"] = "视为装备技，你视为装备【白银狮子】。",
		  --【黑光铠】
		    ["$udz_Heiguangkai"] = "眼缘丁真，鉴定为【<font color='yellow'><b>黑光铠</b></font>】",
			["f_dingzhengHeiguangkai"] = "黑光铠",
			[":f_dingzhengHeiguangkai"] = "视为装备技，你视为装备【黑光铠】。",
		  --【护心镜】
		    ["$udz_Huxinjing"] = "映御丁真，鉴定为【<font color='yellow'><b>护心镜</b></font>】",
			["f_dingzhengHuxinjing"] = "护心镜",
			[":f_dingzhengHuxinjing"] = "视为装备技，你视为装备【护心镜】。",
		--[+1马牌]（4）
		  ["f_dingzheng:Equip_Defen"] = "+1马牌",
		  --【的卢】
		    ["$udz_Dilu"] = "跃仰丁真，鉴定为【<font color='yellow'><b>的卢</b></font>】",
			["f_dingzhengDilu"] = "的卢",
			[":f_dingzhengDilu"] = "视为装备技，你视为装备【的卢】。",
		  --【绝影】
		    ["$udz_Jueying"] = "幽影丁真，鉴定为【<font color='yellow'><b>绝影</b></font>】",
			["f_dingzhengJueying"] = "绝影",
			[":f_dingzhengJueying"] = "视为装备技，你视为装备【绝影】。",
		  --【爪黄飞电】
		    ["$udz_Zhuahuangfeidian"] = "悦约丁真，鉴定为【<font color='yellow'><b>爪黄飞电</b></font>】",
			["f_dingzhengZhuahuangfeidian"] = "爪黄飞电",
			[":f_dingzhengZhuahuangfeidian"] = "视为装备技，你视为装备【爪黄飞电】。",
		  --【骅骝】
		    ["$udz_Hualiu"] = "有用丁真，鉴定为【<font color='yellow'><b>骅骝</b></font>】",
			["f_dingzhengHualiu"] = "骅骝",
			[":f_dingzhengHualiu"] = "视为装备技，你视为装备【骅骝】。",
		--[-1马牌]（3）
		  ["f_dingzheng:Equip_Offen"] = "-1马牌",
		  --【赤兔】
		    ["$udz_Chitu"] = "优越丁真，鉴定为【<font color='yellow'><b>赤兔</b></font>】",
			["f_dingzhengChitu"] = "赤兔",
			[":f_dingzhengChitu"] = "视为装备技，你视为装备【赤兔】。",
		  --【大宛】
		    ["$udz_Dayuan"] = "玉域丁真，鉴定为【<font color='yellow'><b>大宛</b></font>】",
			["f_dingzhengDayuan"] = "大宛",
			[":f_dingzhengDayuan"] = "视为装备技，你视为装备【大宛】。",
		  --【紫骍】
		    ["$udz_Zixing"] = "悠游丁真，鉴定为【<font color='yellow'><b>紫骍</b></font>】",
			["f_dingzhengZixing"] = "紫骍",
			[":f_dingzhengZixing"] = "视为装备技，你视为装备【紫骍】。",
		--[宝物牌]（4）
		  ["f_dingzheng:Equip_Treasure"] = "宝物牌",
		  --【木牛流马】
		    ["$udz_WoodenOx"] = "友援丁真，鉴定为【<font color='yellow'><b>木牛流马</b></font>】",
			["f_dingzhengWoodenOx"] = "木牛流马",
			[":f_dingzhengWoodenOx"] = "视为装备技，你视为装备【木牛流马】。",
		  --【天机图】
		    ["$udz_Tianjitu"] = "押盈丁真，鉴定为【<font color='yellow'><b>天机图</b></font>】",
			["f_dingzhengTianjitu"] = "天机图",
			[":f_dingzhengTianjitu"] = "视为装备技，你视为装备【天机图】。",
		  --【太公阴符】
		    ["$udz_Taigongyinfu"] = "因余丁真，鉴定为【<font color='yellow'><b>太公阴符</b></font>】",
			["f_dingzhengTaigongyinfu"] = "太公阴符",
			[":f_dingzhengTaigongyinfu"] = "视为装备技，你视为装备【太公阴符】。",
		  --【铜雀】
		    ["$udz_Tongque"] = "淫欲丁真，鉴定为【<font color='yellow'><b>铜雀</b></font>】",
			["f_dingzhengTongque"] = "铜雀",
			[":f_dingzhengTongque"] = "视为装备技，你视为装备【铜雀】。",
	    ----
	----
	["$f_dingzheng1"] = "",
	["$f_dingzheng2"] = "",
	  --阵亡
	["~f_UniverseYYDZ"] = "抑郁丁真，不想鉴定......",
	
	--凌元
	["f_lingyuan"] = "凌元", --新杀界凌统+新杀蒲元+“零元购”
	["&f_lingyuan"] = "〇〇", --零(〇)圆(〇)
	["#f_lingyuan"] = "阴间兄弟",
	["designer:f_lingyuan"] = "时光流逝FC",
	["cv:f_lingyuan"] = "官方,DJ Lucy,Adit Sparky",
	["illustrator:f_lingyuan"] = "官方,King Vader",
	  --(旋风+勇进)+(天匠+铸刃)
	  --凌元购
	["f_lingyuangou"] = "凌元购",
	["f_lingyuangouCD"] = "凌元购[隐藏配音]",
	[":f_lingyuangou"] = "限定技，回合开始时，若你有装备栏，你可以选择发动，则你依次执行以下步骤：\
	1.按照顺序检索你的每个装备栏，若你有该装备栏，你随机获得一名其他角色对应装备栏的牌，然后装备之；\
	2.按照顺序检索你的每个装备栏，若你的该装备栏有牌，你交给随机一名其他角色，然后若其有对应的装备栏，其装备之；\
	3.你依次进行两次判定，若判定结果为：\
	(1)红,红，无事发生；(2)红,黑，你获得其中的黑色判定牌；\
	(3)黑,黑，你废除装备区并进入濒死状态；(4)黑,红，你再执行一次步骤1。\
	<font color='red'><b>▫检索顺序：武器栏->防具栏->+1马栏->-1马栏->宝物栏</b></font>",
	["@f_lingyuangou"] = "凌元购",
	["@f_lingyuangou-card"] = "你想开始“凌元购”吗？",
	["$f_lingyuangou"] = "（BGM:Ngana Rindu?）",
	["$f_lingyuangouKongEr"] = "可爱的羊巴鲁，刚好拿下殷都，要把你给劈了......",
	["malaoshiAnimate"] = "image=image/animate/lyg_malaoshi.png",
	["haojingAnimate"] = "image=image/animate/lyg_haojing.png",
	["f_lingyuangouAgain"] = "image=image/animate/f_lingyuangouAgain.png",
	["$f_lingyuangouCD1"] = "这两个年轻人不讲武德，来 骗！来 偷袭！我69岁的老蝙蝠侠，这好吗？这不好",
	["$f_lingyuangouCD2"] = "任何邪恶，终将绳之以法！",
	  --阵亡
	["~f_lingyuan"] = "老七阴，也终将要成为历史了么！.......",
	
	--苟咔
	["f_GoCar"] = "苟咔",
	["#f_GoCar"] = "麒麟弓对我无效",
	["designer:f_GoCar"] = "时光流逝FC",
	["cv:f_GoCar"] = "游卡桌游",
	["illustrator:f_GoCar"] = "游卡桌游",
	  --阵亡
	["~f_GoCar"] = "",
	
	--狂暴流氓云
	["f_KBliumangyun"] = "狂暴流氓云",
	["#f_KBliumangyun"] = "8说了,开冲",
	["designer:f_KBliumangyun"] = "时光流逝FC",
	["cv:f_KBliumangyun"] = "官方",
	["illustrator:f_KBliumangyun"] = "DH", --皮肤：单骑救主
	  --龙胆(OL界限突破版)
	  --冲阵
	["f_chongzhen"] = "冲阵",
	[":f_chongzhen"] = "当你使用或打出一张基本牌时，你可以获得【目标角色】区域里的一张牌；若目标角色为你，改为你摸《0》张牌。\
	<font color='blue'><b>超级冲阵：若此基本牌为发动“龙胆”使用或打出的牌，【】内的内容改为“任意一名角色”、《》内的数字改为“1”。</b></font>",
	["f_SuperChongzhen"] = "【<font color='blue'><b>超级冲阵</b></font>】你可以选择任意一名角色，获得其区域里的一张牌",
	["$f_chongzhen1"] = "欲破强敌，须乱其阵！",
	["$f_chongzhen2"] = "冲敌破阵，斩将之刃！",
	  --义丛
	["f_yicon"] = "义丛",
	["f_yiconn"] = "义丛",
	["f_yiconAudio"] = "义丛",
	[":f_yicon"] = "锁定技，你与其他角色的距离-1；当你的体力值不大于2时，你的手牌上限+1。",
	["$f_yicon1"] = "敞开营门，随我号令！",
	["$f_yicon2"] = "勇者，以退为进！",
	  --阵亡
	["~f_KBliumangyun"] = "魂归在何处，仰天长问三两声......",
	
	--大狗&杜神&彪爷
	["DAGOU_DUSHEN_BIAOYE"] = "大狗&杜神&彪爷",
	["&DAGOU_DUSHEN_BIAOYE"] = "大狗杜神彪爷",
	["#DAGOU_DUSHEN_BIAOYE"] = "手杀军八三阴",
	["designer:DAGOU_DUSHEN_BIAOYE"] = "时光流逝FC",
	["cv:DAGOU_DUSHEN_BIAOYE"] = "官方,OsMan,SINDICVT",
	["illustrator:DAGOU_DUSHEN_BIAOYE"] = "戏子多殇`",
	  --这里是军八
	["thisisjunba"] = "这里是军八",
	[":thisisjunba"] = "<b>说明技，</b>你拥有技能“灵汉”、“灭吴”、“让节”。游戏开始时，你领取<font color='green'><b>280</b></font>枚“武库”标记。",
	["$thisisjunba"] = "（BGM:Liberty Walk）",
	    --灵汉
	  ["dg_linghan"] = "灵汉",
	  ["dg_linghann"] = "灵汉",
	  [":dg_linghan"] = "锁定技，一名角色使用非虚拟非转化的牌时，若此牌为：智囊牌名的锦囊牌(无中生有/过河拆桥/无懈可击)、“灵汉”已记录的牌名或【奇正相生】，你摸一张牌。" ..
	  "每种牌名限一次，你成为锦囊牌的目标时，你记录此牌名，然后取消之；你的回合开始时，你可以在“灵汉”记录中增加或移除一种锦囊牌名。",
	  [":dg_linghan1"] = "锁定技，一名角色使用非虚拟非转化的牌时，若此牌为：智囊牌名的锦囊牌(无中生有/过河拆桥/无懈可击)、“灵汉”已记录的牌名或【奇正相生】，你摸一张牌。" ..
	  "每种牌名限一次，你成为锦囊牌的目标时，你记录此牌名，然后取消之；你的回合开始时，你可以在“灵汉”记录中增加或移除一种锦囊牌名。",
	  [":dg_linghan11"] = "锁定技，一名角色使用非虚拟非转化的牌时，若此牌为：智囊牌名的锦囊牌(无中生有/过河拆桥/无懈可击)、“灵汉”已记录的牌名或【奇正相生】，你摸一张牌。" ..
	  "每种牌名限一次，你成为锦囊牌的目标时，你记录此牌名，然后取消之；你的回合开始时，你可以在“灵汉”记录中增加或移除一种锦囊牌名。\
	  <font color=\"orange\"><b>已记录：%arg11</b></font>",
	  ["#dg_linghanRemove"] = "%from 从“%arg”记录中移除了【%arg2】",
	  ["#dg_linghanAdd"] = "%from 从“%arg”记录中增加了【%arg2】",
	  ["dg_linghan:add"] = "增加一个“灵汉”记录",
	  ["dg_linghan:remove"] = "移除一个“灵汉”记录",
	  ["dg_linghan:tip"] = "亮着的卡牌已记录，仍暗的卡牌未记录",
	  ["$dg_linghan1"] = "主公有此四胜，纵绍强亦可败之。",
	  ["$dg_linghan2"] = "主公以有道之师伐不义之徒，胜之必矣。",
	  ["$dg_linghan3"] = "良策者，胜败之机也。",
	  ["$dg_linghan4"] = "以帷幄之规，下攻拔之捷。",
	  ["$dg_linghan5"] = "不求有功于社稷，但求无过于本心。",
	  ["$dg_linghan6"] = "投忠君之士，谋定国之计。",
	  --阵亡
	["~DAGOU_DUSHEN_BIAOYE"] = "害搁这听阵亡语音呢，我们挂机都能",
	
	--神徐盛
	["f_shenxusheng"] = "神徐盛[七夕纪念]",
	["&f_shenxusheng"] = "神徐盛",
	["f_shenxusheng_skin"] = "神徐盛[七夕纪念]",
	["&f_shenxusheng_skin"] = "神徐盛",
	["f_shenxusheng_forSHZ"] = "神徐盛[七夕纪念]",
	["&f_shenxusheng_forSHZ"] = "神徐盛",
	["#f_shenxusheng"] = "海誓山盟",
	["designer:f_shenxusheng"] = "时光流逝FC",
	["cv:f_shenxusheng"] = "网络,张馨予",
	["illustrator:f_shenxusheng"] = "云涯",
	--
	["f_forSXSandSHZ"] = "",
	["@f_forSXSandSHZ_changeSkin"] = "更换武将皮肤",
	["@f_forSXSandSHZ_changeSkin:1"] = "原画",
	["@f_forSXSandSHZ_changeSkin:2"] = "皮肤",
	--
	  --魄君
	["f_pojun"] = "魄君",
	["f_pojunReturn"] = "魄君",
	["f_pojunFakeMove"] = "魄君",
	[":f_pojun"] = "<font color='green'><b>每个回合对每名其他角色限一次</b></font><font color='red'><b>（若为男性角色，则改为限两次）</b></font>，当你使用伤害类牌指定一个目标后，" ..
	"你可以将其至多X张牌扣置于该角色的武将牌旁（X为其体力值），若其中有：基本牌，你回复1点体力；锦囊牌，你摸一张牌；装备牌，你弃置其中一张牌。" ..
	"若如此做，当前回合结束后，该角色获得这些牌。当你使用目标数不超过你当前体力值的伤害类牌对手牌数与装备数均不大于你的其他角色造成伤害时，此伤害+1。",
	["f_pojun_num"] = "魄君-扣置数",
	["f_pojun_dis"] = "魄君-扣置",
	["$f_pojun1"] = "犯大吴疆土者，盛必击而破之。",
	["$f_pojun2"] = "江东铁壁据长江兮，魄君剑舞正此时。",
	  --怡娍
	["f_yicheng"] = "怡娍",
	[":f_yicheng"] = "每个回合限一次，当一名其他角色成为使用来源不为你的伤害类牌的目标后，你可以令该角色摸一张牌<font color='red'><b>（若为男性角色，则改为摸两张牌）</b></font>" ..
	"然后弃置一张牌。若以此法弃置的牌的花色与该伤害类牌相同，则此伤害类牌对该角色无效。",
	["$f_yicheng1"] = "问世间情是何物，直教生死相许。",
	["$f_yicheng2"] = "天南地北双飞客，老翅几回寒暑。",
	  --搭妆
	["f_dazhuang"] = "搭妆",
	[":f_dazhuang"] = "每轮限一次，当你造成伤害后，你可以连续使用牌堆中的Y张装备牌（Y为你此次造成的伤害值）。",
	["$f_dazhuang1"] = "欢乐趣，离别苦~",
	["$f_dazhuang2"] = "就中更有痴儿女~",
	  --❤海誓❤
	["f_haishiSM"] = "海誓",
	[":f_haishiSM"] = "<b><font color='pink'>情侣</font>联动技<font color='#FE2E86'>【情侣：神徐盛[七夕纪念]×神黄忠[七夕纪念]】</font>，</b>限定技，" ..
	"当你的（为其他角色的）“情侣”濒死状态询问结束后，你可以令其回满体力并将你区域内的所有牌交给其。若如此做，<font color='red'><b>代价：</b></font>你死亡。\
	<font color='pink'><b>❤/海誓山盟/：</b></font><font color='#FE2E86'>若你的主将与副将互为“情侣”，你的回复值+1。</font>",
	["@f_haishiSM"] = "海誓",
	["$f_haishiSM_toSHZ"] = "你说，如果有来生，我们还会再相见吗？",
	["$f_haishiSM1"] = "君应有语，渺万里层云......",
	["$f_haishiSM2"] = "千山暮雪，只影向谁去......",
	  --阵亡
	["~f_shenxusheng"] = "忠......",
	["~f_shenxusheng_skin"] = "忠......",
	["~f_shenxusheng_forSHZ"] = "忠......",
	
	--神黄忠
	["f_shenhuangzhongg"] = "神黄忠[七夕纪念]",
	["&f_shenhuangzhongg"] = "神黄忠",
	["f_shenhuangzhongg_skin"] = "神黄忠[七夕纪念]",
	["&f_shenhuangzhongg_skin"] = "神黄忠",
	["f_shenhuangzhongg_forSXS"] = "神黄忠[七夕纪念]",
	["&f_shenhuangzhongg_forSXS"] = "神黄忠",
	["#f_shenhuangzhongg"] = "山盟海誓",
	["designer:f_shenhuangzhongg"] = "时光流逝FC,小霸汪孙伯符",
	["cv:f_shenhuangzhongg"] = "官方,TI intro,古巨基",
	["illustrator:f_shenhuangzhongg"] = "石琨,一串糖葫芦,三国志12",
	  --开弓
	["f_kaigong"] = "开弓",
	[":f_kaigong"] = "当你使用【杀】指定一个目标后，每满足下列一项条件，你可以令此【杀】伤害+1：\
	1、目标的手牌数不小于你的体力值；\
	2、目标的手牌数不大于你的攻击范围；\
	3、你的手牌数不小于目标的手牌数；\
	4、你的体力值不大于目标的体力值。",
	["f_kaigong:f_kaigongUpDamage"] = "你可以发动“开弓”令此【杀】伤害+%src<br/> ->你也可以点【取消】，自定义此【杀】伤害的增值（至多+%src）",
	["f_kaigong:0"] = "此【杀】伤害+0",
	["f_kaigong:1"] = "此【杀】伤害+1",
	["f_kaigong:2"] = "此【杀】伤害+2",
	["f_kaigong:3"] = "此【杀】伤害+3",
	["f_kaigong:4"] = "此【杀】伤害+4",
	["$f_kaigongUD"] = "因为“<font color='yellow'><b>开弓</b></font>”的加成，%from 使用的 %card 对 %to 造成的伤害 + %arg2",
	["$f_kaigong1"] = "还有哪个愿饮我锋矢？",
	["$f_kaigong2"] = "老夫张弓一射，便叫敌军立毙一将！",
	  --弓魂
	["f_gonghun"] = "弓魂",
	["f_gonghunMission"] = "弓魂",
	[":f_gonghun"] = "<b><font color='blue'>阶</font><font color='#5A2DFF'>梯</font><font color='purple'>技</font>，</b>游戏开始时，你为【1阶】。" ..
	"你每完成一次“升阶”，你的【杀】伤害+1，且你删除“开弓”中的一项条件。\
	【1阶】你获得技能“标烈弓”；当你使用或打出一张非虚拟非转化【杀】后，你可以进行一次“升阶”（成功率90%）；\
	【2阶】你获得技能“界烈弓”；当你使用或打出不同颜色的【杀】（不包括无颜色）各一张后，你可以进行一次“升阶”（成功率80%）；\
	【3阶】你获得技能“谋烈弓”并输入核密码；当你使用或打出不同花色的【杀】（不包括无花色）各一张后，你可以进行一次“升阶”（成功率70%）；\
	【4阶】你获得技能“神烈弓”并失去1点体力；当你使用或打出一张虚拟【杀】或转化前的牌数不少于4的转化【杀】后，你可以进行一次“升阶”（成功率60%）；\
	【5阶】（满阶）你随机获得一张<font color='red'><b>【灭世“神兵”】</b>（赤血刃(23%)/没日弓(75%)/<font color='orange'>彩蛋:二者皆得(2%)</font>）</font>。",
	["$f_gonghun_fail"] = "很遗憾，%from 升阶<font color='red'><b>失败</b></font>",
	["f_gonghunMission:toTwo"] = "[弓魂-升阶]你可以升至<b><font color='yellow'>//</font><font color=\"#66FF66\">二阶</font><font color='yellow'>//</font></b>",
	["$f_gonghun_1to2"] = "%from 升阶<font color=\"#4DB873\"><b>成功</b></font>，升入“<font color='yellow'><b>弓魂</b></font>”<font color=\"#66FF66\"><b>二阶</b></font>！",
	["f_gonghunMission:toThree"] = "[弓魂-升阶]你可以升至<b><font color='yellow'>//</font><font color=\"#00CCFF\"><b>三阶</b></font><font color='yellow'>//</font></b>",
	["$f_gonghun_2to3"] = "%from 升阶<font color=\"#4DB873\"><b>成功</b></font>，升入“<font color='yellow'><b>弓魂</b></font>”<font color=\"#00CCFF\"><b>三阶</b></font>！",
	["f_gonghunMission:toFour"] = "[弓魂-升阶]你可以升至<b><font color='yellow'>//</font><font color='purple'><b>四阶</b></font><font color='yellow'>//</font></b>",
	["$f_gonghun_3to4"] = "%from 升阶<font color=\"#4DB873\"><b>成功</b></font>，升入“<font color='yellow'><b>弓魂</b></font>”<font color='purple'><b>四阶</b></font>！",
	["f_gonghunMission:toMaxFive"] = "[弓魂-升阶]你可以升至<b><font color='yellow'>//</font><font color='orange'><b>五阶</b></font><font color='yellow'>//</font></b>",
	["$f_gonghun_4to5"] = "%from 升阶<font color=\"#4DB873\"><b>成功</b></font>，升入“<font color='yellow'><b>弓魂</b></font>”<font color='orange'><b>五阶</b></font>，" ..
	"达到<font color='red'><b>满阶</b></font>！",
	["f_gonghunDelete"] = "删除“开弓”条件",
	["f_gonghunDelete:1"] = "删除“开弓”条件：目标的手牌数不小于你的体力值",
	["f_gonghunDelete:2"] = "删除“开弓”条件：目标的手牌数不大于你的攻击范围",
	["f_gonghunDelete:3"] = "删除“开弓”条件：你的手牌数不小于目标的手牌数",
	["f_gonghunDelete:4"] = "删除“开弓”条件：你的体力值不大于目标的体力值",
	["$f_gonghunMD"] = "因为“<font color='yellow'><b>弓魂</b></font>”的加成，%from 使用的 %card 对 %to 造成的伤害 + %arg2",
	["$f_gonghun1"] = "（成功提示音：升至2阶）",
	["$f_gonghun2"] = "（成功提示音：升至3阶）",
	["$f_gonghun3"] = "（成功提示音：升至4阶）",
	["$f_gonghun4"] = "（成功提示音：升至5阶，恭喜达到满阶！）",
	    --谋烈弓
	  ["f_mouliegong"] = "谋·烈弓",
	  ["f_mouliegong_limit"] = "烈弓",
	  ["f_mouliegong_record"] = "烈弓",
	  [":f_mouliegong"] = "若你的装备区里没有武器牌，你的【杀】只能当普通【杀】使用或打出。你使用牌时或成为其他角色使用牌的目标后，若此牌的花色未被“烈弓”记录，则记录此种花色。" ..
	  "当你使用【杀】指定唯一目标后，你可以亮出牌堆顶的X张牌（X为你记录的花色数-1，且至少为0），每有一张牌花色与“烈弓”记录的花色相同，你令此【杀】伤害+1，" ..
	  "且其不能使用“烈弓”记录花色的牌响应此【杀】。若如此做，此【杀】结算结束后，清除“烈弓”记录的花色。",
	  ["f_mouliegong_MoreDamage"] = "",
	  ["$f_mouliegongBUFF"] = "因为“<font color='yellow'><b>烈弓</b></font>”的加成，%from 使用的 %card 对 %to 造成的伤害 + %arg2",
	  ["$f_mouliegong1"] = "矢贯坚石，劲冠三军！",
	  ["$f_mouliegong2"] = "吾虽年迈，箭矢犹锋！",
	    --神烈弓
	  ["smzy_shenliegong"] = "神·烈弓",
	  ["smzy_shenliegong_tarmod"] = "烈弓",
	  [":smzy_shenliegong"] = "你可以将至少一张花色各不相同的手牌当无距离和次数限制的【火杀】使用，若以此法使用的转化前的牌数不小于：1，此【火杀】不可被【闪】响应；" ..
	  "2，此【火杀】结算完毕后，你摸三张牌；3，此【火杀】的伤害+1；4，此【火杀】造成伤害后，你令目标角色随机失去一个技能。" ..
	  "每回合限一次。若你已受伤，改为每回合限两次。",
	  ["#smzy_FireLiegong1"] = "由于“%arg”的技能效果，%from 使用的 %card 不能被【<font color = 'yellow'><b>闪</b></font>】响应",
	  ["#smzy_FireLiegong2"] = "由于“%arg”的技能效果，%from 使用的 %card 在结算完毕后，%from摸 <font color = 'yellow'><b>3</b></font> 张牌",
	  ["#smzy_FireLiegong3"] = "由于“<font color = 'yellow'><b>烈弓</b></font>”的技能效果，%from 使用的 %card 造成的伤害从 %arg 点增加至 %arg2 点",
	  ["#smzy_FireLiegong4"] = "由于“%arg”的技能效果，%to 受到 %from 使用的 %card 造成的伤害后将随机失去1个武将技能",
	  ["$smzy_shenliegong1"] = "烈弓神威，箭矢毙敌！",
	  ["$smzy_shenliegong2"] = "鋷甲锵躯，肝胆俱裂！",
	  --❤山盟❤
	["f_shanmengHS"] = "山盟",
	["f_shanmenghs"] = "山盟",
	[":f_shanmengHS"] = "<b><font color='pink'>情侣</font>联动技<font color='#FE2E86'>【情侣：神黄忠[七夕纪念]×神徐盛[七夕纪念]】</font>，</b>限定技，" ..
	"出牌阶段，若场上没有你的“情侣”，你可以销毁一张<font color='red'><b>【灭世“神兵”】</b></font>，令一名已阵亡角色重生为你的“情侣”，并令其将体力值与手牌数补至体力上限。" ..
	"若如此做，<font color='red'><b>代价：</b></font>你将武将牌替换为“士兵”并失去“弓魂”的【杀】伤害加成效果（替换前后体力上限与体力值保持不变）。\
	<font color='pink'><b>❤/山盟海誓/：</b></font><font color='#FE2E86'>若你的主将与副将互为“情侣”，你的伤害值+1。</font>",
	["@f_shanmengHS"] = "山盟",
	["f_shanmengHS-ask"] = "山盟:复活爱人",
	["$f_shanmengHS_toSXS"] = "会的，遇见你是我的命中注定。到那一次，\
	我一定要紧紧抓住你的手，永远不放开。",
	["$f_shanmengHS1"] = "苦海，翻起爱恨...在世间，难逃避命运...",
	["$f_shanmengHS2"] = "相亲，竟不可接近...或我应该，相信是缘分...",
	--["$f_shanmengHS3"] = "复~活~吧~，我~的~爱~人~!~!~!~",
	  --==【灭世“神兵”】==--
	  --<赤血刃>--
	  ["_f_chixieren"] = "赤血刃",
	  ["Fchixieren"] = "赤血刃", --血杀！
	  [":_f_chixieren"] = "装备牌·武器<br /><b>攻击范围</b>：1\
	  <b>武器技能</b>：当你的【杀】造成伤害后，你可以回复与此【杀】造成的伤害值等量的体力。<font color='black'><b>此牌进入弃牌堆时销毁。</b></font>\
	  <font color='red'><b>神兵灭世：</b></font>出牌阶段，你可以销毁此牌并选择一名距离为1的其他角色，你失去所有体力，然后移除其所有体力卡。",
	  --<没日弓>--
	  ["_f_morigong"] = "没日弓",
	  ["Fmorigong"] = "没日弓", --暗杀！
	  [":_f_morigong"] = "装备牌·武器<br /><b>攻击范围</b>：6\
	  <b>武器技能</b>：你可以令你的【杀】造成的伤害改为体力流失。<font color='black'><b>此牌进入弃牌堆时销毁。</b></font>\
	  <font color='red'><b>神兵灭世：</b></font>出牌阶段，你可以销毁此牌并选择一名其他角色，移除其所有体力值。",
	  -------
	    --神兵灭世
	  ["f_mieshiSB"] = "灭世",
	  ["f_mieshisb"] = "神兵灭世",
	  [":f_mieshiSB"] = "出牌阶段，你可以<font color='green'><b>点击此按钮</b></font>，选择一张【灭世“神兵”】（赤血刃/没日弓），" ..
	  "触发其<font color='red'><b>神兵灭世</b></font>效果。",
	  --==================--
	  --阵亡
	["~f_shenhuangzhongg"] = "宝儿..对不起，我再也不能...守护......",
	["~f_shenhuangzhongg_skin"] = "宝儿..对不起，我再也不能...守护......",
	["~f_shenhuangzhongg_forSXS"] = "宝儿..对不起，我再也不能...守护......",
	
	--汤姆
	["f_TOM"] = "汤姆",
	["#f_TOM"] = "失败之王",
	["designer:f_TOM"] = "时光流逝FC",
	["cv:f_TOM"] = "猫和老鼠",
	["illustrator:f_TOM"] = "猫和老鼠",
	  --阵亡
	["~f_TOM"] = "",
	
	--杰瑞
	["f_JERRY"] = "杰瑞",
	["#f_JERRY"] = "勿以赢小而不麻",
	["designer:f_JERRY"] = "时光流逝FC",
	["cv:f_JERRY"] = "猫和老鼠",
	["illustrator:f_JERRY"] = "猫和老鼠",
	  --阵亡
	["~f_JERRY"] = "",
	----
	--完结附赠篇详见：“sdEnd.lua”。
}
sgs.Sanguosha:addSkills(skills)
return {extension, sdCard} 