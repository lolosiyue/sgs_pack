-- this script file defines all functions written by Lua

-- trigger skills
function sgs.CreateTriggerSkill(spec)
	assert(type(spec.name)=="string")
	assert(type(spec.on_trigger)=="function")
	if spec.frequency then assert(type(spec.frequency)=="number") end
	if spec.limit_mark then assert(type(spec.limit_mark)=="string") end
    if spec.change_skill then assert(type(spec.change_skill)=="boolean") end
	if spec.limited_skill then assert(type(spec.limited_skill)=="boolean") end
	if spec.hide_skill then assert(type(spec.hide_skill)=="boolean") end
	if spec.shiming_skill then assert(type(spec.shiming_skill)=="boolean") end
	if spec.waked_skills then assert(type(spec.waked_skills)=="string") end
	local frequency = spec.frequency or sgs.Skill_NotFrequent
	local limit_mark = spec.limit_mark or ""
    local change_skill = spec.change_skill or false
	local limited_skill = spec.limited_skill or false
	local hide_skill = spec.hide_skill or false
	local shiming_skill = spec.shiming_skill or false
	local waked_skills = spec.waked_skills or ""
    local skill = sgs.LuaTriggerSkill(spec.name,frequency,limit_mark,change_skill,limited_skill,hide_skill,shiming_skill,waked_skills)
	if type(spec.guhuo_type)=="string" and spec.guhuo_type~="" then skill:setGuhuoDialog(spec.guhuo_type) end
	if type(spec.juguan_type)=="string" and spec.juguan_type~="" then skill:setJuguanDialog(spec.juguan_type) end
	if type(spec.tiansuan_type)=="string" and spec.tiansuan_type~="" then skill:setTiansuanDialog(spec.tiansuan_type) end
	if type(spec.events)=="number" then
		skill:addEvent(spec.events)
	elseif type(spec.events)=="table" then
		for _,event in ipairs(spec.events)do
			skill:addEvent(event)
		end
	end
	if type(spec.global)=="boolean" then skill:setGlobal(spec.global) end
	skill.on_trigger = spec.on_trigger
	if spec.can_trigger then
		skill.can_trigger = spec.can_trigger
	end
	if spec.can_wake then
		skill.can_wake = spec.can_wake
	end
	if spec.view_as_skill then
		skill:setViewAsSkill(spec.view_as_skill)
	end
	if type(spec.priority)=="number" then
		skill.priority = spec.priority
	--[[elseif type(spec.priority)=="table" then
		for triggerEvent,priority in pairs(spec.priority)do
			skill:insertPriorityTable(triggerEvent,priority)
		end
	end]]
	elseif type(spec.priority)=="table" then
		if type(spec.events)=="table" then
			for i = 1,#spec.events,1 do
				if i>#spec.priority then break end
				skill:insertPriorityTable(spec.events[i],spec.priority[i])
			end
		elseif type(spec.events)=="number" then
			skill:insertPriorityTable(spec.events,spec.priority[1])
		end
	end
	if type(dynamic_frequency)=="function" then
		skill.dynamic_frequency = spec.dynamic_frequency
	end
	return skill
end

function sgs.CreateScenarioRule(spec)
	assert(type(spec.on_trigger)=="function")
	assert(spec.scenario)
    local rule = sgs.LuaScenarioRule(spec.scenario)
	if type(spec.events)=="number" then
		rule:addEvent(spec.events)
	elseif type(spec.events)=="table" then
		for _,event in ipairs(spec.events)do
			rule:addEvent(event)
		end
	end
	if type(spec.global)=="boolean" then rule:setGlobal(spec.global) end
	if spec.can_trigger then
		rule.can_trigger = spec.can_trigger
	end
	rule.on_trigger = spec.on_trigger
	spec.priority = spec.priority or 1
	if type(spec.priority)=="number" then
		rule.priority = spec.priority
	elseif type(spec.priority)=="table" then
		if type(spec.events)=="table" then
			for i = 1,#spec.events,1 do
				if i>#spec.priority then break end
				rule:insertPriorityTable(spec.events[i],spec.priority[i])
			end
		elseif type(spec.events)=="number" then
			rule:insertPriorityTable(spec.events,spec.priority[1])
		end
	end
	return rule
end

function sgs.CreateScenario(spec)
	assert(type(spec.name)=="string")
	assert(spec.roles)
	local scenario = sgs.Scenario(spec.name)
	if type(spec.expose)=="boolean"
	then scenario:setExposeRoles(spec.expose) end
	if spec.rule then
		scenario:setRule(spec.rule)
	end
	for r,g in pairs(spec.roles)do
		if type(g)~="string" then g = "sujiang" end
		if r:match("lord")
		then
			scenario:setScenarioLord(g)
		elseif r:match("loyalist")
		then
			scenario:addScenarioLoyalists(g)
		elseif r:match("rebel")
		then
			scenario:addScenarioRebels(g)
		elseif r:match("renegade")
		then
			scenario:addScenarioRenegades(g)
		end
	end
	return scenario
end

function sgs.CreateProhibitSkill(spec)
	assert(type(spec.name)=="string")
	assert(type(spec.is_prohibited)=="function")
	if spec.frequency then assert(type(spec.frequency)=="number") end
	local frequency = spec.frequency or sgs.Skill_Compulsory
	local skill = sgs.LuaProhibitSkill(spec.name,frequency)
	skill.is_prohibited = spec.is_prohibited
	return skill
end

function sgs.CreateProhibitPindianSkill(spec)
	assert(type(spec.name)=="string")
	assert(type(spec.is_pindianprohibited)=="function")
	if spec.frequency then assert(type(spec.frequency)=="number") end
	local frequency = spec.frequency or sgs.Skill_Compulsory
	local skill = sgs.LuaProhibitPindianSkill(spec.name,frequency)
	skill.is_pindianprohibited = spec.is_pindianprohibited
	return skill
end

function sgs.CreateFilterSkill(spec)
	assert(type(spec.name)=="string")
	assert(type(spec.view_filter)=="function")
	assert(type(spec.view_as)=="function")
	if spec.frequency then assert(type(spec.frequency)=="number") end
	local frequency = spec.frequency or sgs.Skill_Compulsory
	local skill = sgs.LuaFilterSkill(spec.name,frequency)
	skill.view_filter = spec.view_filter
	skill.view_as = spec.view_as
	return skill
end

function sgs.CreateDistanceSkill(spec)
	assert(type(spec.name)=="string")
	if spec.frequency then assert(type(spec.frequency)=="number") end
	local frequency = spec.frequency or sgs.Skill_Compulsory
	local skill = sgs.LuaDistanceSkill(spec.name,frequency)
	if type(spec.correct_func)=="function" then skill.correct_func = spec.correct_func end
	if type(spec.fixed_func)=="function" then skill.fixed_func = spec.fixed_func end
	return skill
end

function sgs.CreateMaxCardsSkill(spec)
	assert(type(spec.name)=="string")
	assert(type(spec.extra_func)=="function" or type(spec.fixed_func)=="function")
	if spec.frequency then assert(type(spec.frequency)=="number") end
	local frequency = spec.frequency or sgs.Skill_Compulsory
	local skill = sgs.LuaMaxCardsSkill(spec.name,frequency)
	if spec.extra_func then
		skill.extra_func = spec.extra_func
	else
		skill.fixed_func = spec.fixed_func
	end
	return skill
end

function sgs.CreateTargetModSkill(spec)
	assert(type(spec.name)=="string")
	assert(type(spec.residue_func)=="function" or type(spec.distance_limit_func)=="function" or type(spec.extra_target_func)=="function")
	if spec.pattern then assert(type(spec.pattern)=="string") end
	if spec.frequency then assert(type(spec.frequency)=="number") end
	local frequency = spec.frequency or sgs.Skill_Compulsory
	local skill = sgs.LuaTargetModSkill(spec.name,spec.pattern or "Slash",frequency)
	if spec.residue_func then
		skill.residue_func = spec.residue_func
	end
	if spec.distance_limit_func then
		skill.distance_limit_func = spec.distance_limit_func
	end
	if spec.extra_target_func then
		skill.extra_target_func = spec.extra_target_func
	end
	return skill
end

function sgs.CreateInvaliditySkill(spec)
	assert(type(spec.name)=="string")
	assert(type(spec.skill_valid)=="function")
	if spec.frequency then assert(type(spec.frequency)=="number") end
	local frequency = spec.frequency or sgs.Skill_Compulsory
	local skill = sgs.LuaInvaliditySkill(spec.name,frequency)
	skill.skill_valid = spec.skill_valid
	return skill
end

function sgs.CreateAttackRangeSkill(spec)
	assert(type(spec.name)=="string")
	assert(type(spec.extra_func)=="function" or type(spec.fixed_func)=="function")
	if spec.frequency then assert(type(spec.frequency)=="number") end
	local frequency = spec.frequency or sgs.Skill_Compulsory
	local skill = sgs.LuaAttackRangeSkill(spec.name,frequency)
	if spec.extra_func then
		skill.extra_func = spec.extra_func or 0
	end
	if spec.fixed_func then
		skill.fixed_func = spec.fixed_func or 0
	end
	return skill
end

function sgs.CreateViewAsEquipSkill(spec)
	assert(type(spec.name)=="string")
	assert(type(spec.view_as_equip)=="function")
	if spec.frequency then assert(type(spec.frequency)=="number") end
	local frequency = spec.frequency or sgs.Skill_Compulsory
	local skill = sgs.LuaViewAsEquipSkill(spec.name,frequency)
	if spec.view_as_equip then
		skill.view_as_equip = spec.view_as_equip or ""
	end
	return skill
end

function sgs.CreateCardLimitSkill(spec)
	assert(type(spec.name)=="string")
	assert(type(spec.limit_list)=="function")
	assert(type(spec.limit_pattern)=="function")
	if spec.frequency then assert(type(spec.frequency)=="number") end
	local frequency = spec.frequency or sgs.Skill_Compulsory
	local skill = sgs.LuaCardLimitSkill(spec.name,frequency)
	if spec.limit_list then
		skill.limit_list = spec.limit_list or ""
	end
	if spec.limit_pattern then
		skill.limit_pattern = spec.limit_pattern or ""
	end
	return skill
end

function sgs.CreateMasochismSkill(spec)
	assert(type(spec.on_damaged)=="function")
	spec.events = sgs.Damaged
	function spec.on_trigger(skill,event,player,data,room)
		local damage = data:toDamage()
		spec.on_damaged(skill,player,damage,room)
		return false
	end
	return sgs.CreateTriggerSkill(spec)
end

function sgs.CreatePhaseChangeSkill(spec)
	assert(type(spec.on_phasechange)=="function")
	spec.events = sgs.EventPhaseStart
	function spec.on_trigger(skill,event,player,data,room)
		return spec.on_phasechange(skill,player,room)
	end
	return sgs.CreateTriggerSkill(spec)
end

function sgs.CreateDrawCardsSkill(spec)
	assert(type(spec.draw_num_func)=="function")
	if not spec.is_initial then spec.events = sgs.DrawNCards else spec.events = sgs.DrawInitialCards end
	function spec.on_trigger(skill,event,player,data,room)
		local n = data:toInt()
		local nn = spec.draw_num_func(skill,player,n,room)
		data:setValue(nn)
		return false
	end
	return sgs.CreateTriggerSkill(spec)
end

function sgs.CreateGameStartSkill(spec)
	assert(type(spec.on_gamestart)=="function")
	spec.events = sgs.GameStart
	function spec.on_trigger(skill,event,player,data,room)
		spec.on_gamestart(skill,player,room)
		return false
	end
	return sgs.CreateTriggerSkill(spec)
end

function sgs.CreateRetrialSkill(spec)
	assert(type(spec.on_retrial)=="function")
	assert(type(spec.exchange)=="boolean")
	spec.events = sgs.AskForRetrial
	function spec.on_trigger(skill,event,player,data,room)
		local judge = data:toJudge()
        local card = spec.on_retrial(skill,player,judge,room)
		if not card then return false end
		room:retrial(card,player,judge,skill:objectName(),spec.exchange)
		return false
	end
	return sgs.CreateTriggerSkill(spec)
end

--------------------------------------------

-- skill cards

function sgs.CreateSkillCard(spec)
	assert(spec.name)
	if spec.skill_name then assert(type(spec.skill_name)=="string") end

	local card = sgs.LuaSkillCard(spec.name,spec.skill_name)

	if type(spec.will_throw)=="boolean" then
		card:setWillThrow(spec.will_throw)
	end

	if type(spec.can_recast)=="boolean" then
		card:setCanRecast(spec.can_recast)
	end

	if type(spec.handling_method)=="number" then
		card:setHandlingMethod(spec.handling_method)
	end

	if type(spec.mute)=="boolean" then
		card:setMute(spec.mute)
	end

	if type(spec.target_fixed)=="boolean"
	then card:setTargetFixed(spec.target_fixed)end
	
	if type(spec.filter)=="function" then
		function card:filter(...)
			local result,vote = spec.filter(self,...)
			if type(result)=="boolean" and type(vote)=="number" then
				return result,vote
			elseif type(result)=="boolean" and vote==nil then
				if result then vote = 1 else vote = 0 end
				return result,vote
			elseif type(result)=="number" then
				return result>0,result
			else
				return false,0
			end
		end
	end
	card.feasible = spec.feasible
	card.about_to_use = spec.about_to_use
	card.on_use = spec.on_use
	card.on_effect = spec.on_effect
	card.on_validate = spec.on_validate
	card.on_validate_in_response = spec.on_validate_in_response

	return card
end

function sgs.CreateBasicCard(spec)
	assert(type(spec.name)=="string" or type(spec.class_name)=="string")
	if not spec.name then spec.name = spec.class_name
	elseif not spec.class_name then spec.class_name = spec.name end
	if spec.suit then assert(type(spec.suit)=="number") end
	if spec.number then assert(type(spec.number)=="number") end
	if spec.subtype then assert(type(spec.subtype)=="string") end
	local card = sgs.LuaBasicCard(spec.suit or sgs.Card_SuitToBeDecided,spec.number or 0,spec.name,spec.class_name,spec.subtype or "BasicCard")

	if type(spec.target_fixed)=="boolean"
	then card:setTargetFixed(spec.target_fixed)end

	if type(spec.can_recast)=="boolean" then
		card:setCanRecast(spec.can_recast)
	end
	
	if type(spec.damage_card)=="boolean" then
		card:setDamageCard(spec.damage_card)
	end
	
	if type(spec.is_gift)=="boolean" then
		card:setGift(spec.is_gift)
	end
	
	if type(spec.single_target)=="boolean" then
		card:setSingleTargetCard(spec.single_target)
	end

	if type(spec.filter)=="function" then
		function card:filter(...)
			local result,vote = spec.filter(self,...)
			if type(result)=="boolean" and type(vote)=="number" then
				return result,vote
			elseif type(result)=="boolean" and vote==nil then
				if result then vote = 1 else vote = 0 end
				return result,vote
			elseif type(result)=="number" then
				return result>0,result
			else
				return false,0
			end
		end
	end
	card.feasible = spec.feasible
	card.available = spec.available
	card.about_to_use = spec.about_to_use
	card.on_use = spec.on_use
	card.on_effect = spec.on_effect

	return card
end

--============================================
-- default functions for Trick cards

function isAvailable_AOE(self,player)
	for _,p in sgs.qlist(player:getAliveSiblings())do
		if player:isProhibited(p,self) then continue end
		return self:cardIsAvailable(player)
	end
end

function onUse_AOE(self,room,card_use,tos)
	tos = tos or room:getOtherPlayers(card_use.from)
	card_use.to = sgs.SPlayerList()
	local pt = {}
	for skill,to in sgs.qlist(tos)do
		skill = room:isProhibited(card_use.from,to,self)
		if skill
		then
			skill = sgs.Sanguosha:getMainSkill(skill:objectName())
			pt[skill:objectName()] = pt[skill:objectName()] or sgs.SPlayerList()
			pt[skill:objectName()]:append(to)
		else card_use.to:append(to) end
	end
	for s,ts in pairs(pt)do
		for _,owner in sgs.qlist(room:getAllPlayers())do
			if owner:hasSkill(s)
			then
				local logm = sgs.LogMessage()
				logm.arg = s
				logm.arg2 = self:objectName()
				logm.type = "#SkillAvoidFrom"
				logm.from = owner
				if ts:contains(owner) and ts:length()<2
				then logm.type = "#SkillAvoid"
				else logm.to = ts end
				room:sendLog(logm)
				room:broadcastSkillInvoke(s)
				room:notifySkillInvoked(owner,s)
				break
			end
		end
	end
	self:cardOnUse(room,card_use)
end

function isAvailable_GlobalEffect(self,player)
	local players = player:getAliveSiblings()
	players:append(player)
	for _,p in sgs.qlist(players)do
		if player:isProhibited(p,self) then continue end
		return self:cardIsAvailable(player)
	end
end

function onUse_GlobalEffect(self,room,card_use,tos)
	tos = tos or room:getAllPlayers()
	card_use.to = sgs.SPlayerList()
	local pto = {}
	for skill,to in sgs.qlist(tos)do
		skill = room:isProhibited(card_use.from,to,self)
		if skill
		then
			skill = sgs.Sanguosha:getMainSkill(skill:objectName())
			pto[skill:objectName()] = pto[skill:objectName()] or sgs.SPlayerList()
			pto[skill:objectName()]:append(to)
		else card_use.to:append(to) end
	end
	for s,ts in pairs(pto)do
		for _,owner in sgs.qlist(room:getAllPlayers())do
			if owner:hasSkill(s)
			then
				local logm = sgs.LogMessage()
				logm.arg = s
				logm.arg2 = self:objectName()
				logm.type = "#SkillAvoidFrom"
				logm.from = owner
				if ts:contains(owner) and ts:length()<2
				then logm.type = "#SkillAvoid"
				else logm.to = ts end
				room:sendLog(logm)
				room:broadcastSkillInvoke(s)
				room:notifySkillInvoked(owner,s)
				break
			end
		end
	end
	self:cardOnUse(room,card_use)
end

function onUse_DelayedTrick(self,room,card_use)
	card_use.card = sgs.Sanguosha:getWrappedCard(self:getEffectiveId())
	
	local data = sgs.QVariant()
	data:setValue(card_use)
	local thread = room:getThread()
	thread:trigger(sgs.PreCardUsed,room,card_use.from,data)
	card_use = data:toCardUse()
	
	local logm = sgs.LogMessage()
	logm.from = card_use.from
	logm.to = card_use.to
	logm.type = "#UseCard"
	logm.card_str = self:toString()
	room:sendLog(logm)
	
	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_USE,card_use.from:objectName(),card_use.to:first():objectName(),self:getSkillName(),"")
	reason.m_extraData:setValue(card_use.card)
	reason.m_useStruct = card_use
	
	room:moveCardTo(self,nil,sgs.Player_PlaceTable,reason,true)
	
	thread:trigger(sgs.CardUsed,room,card_use.from,data)
	card_use = data:toCardUse()
	thread:trigger(sgs.CardFinished,room,card_use.from,data)
end

function use_DelayedTrick(self,room,source,targets_table)
	if not room:CardInTable(self) then return end
	
	local nullified_list = room:getTag("CardUseNullifiedList"):toStringList()
	
	local targets = sgs.SPlayerList()
	for _,p in ipairs(targets_table)do
		if table.contains(nullified_list,"_ALL_TARGETS")
		or table.contains(nullified_list,p:objectName())
		or p:containsTrick(self:objectName()) or p:isDead()
		then elseif p:hasJudgeArea() then targets:append(p) end
	end
	
	for _,target in sgs.qlist(targets)do
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_USE,source:objectName(),target:objectName(),self:getSkillName(),"")
		reason.m_extraData:setValue(self:getRealCard())
		reason.m_useStruct = sgs.CardUseStruct(self,source,targets)
		room:moveCardTo(self,target,sgs.Player_PlaceDelayedTrick,reason,true)
		return
	end
	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_USE,source:objectName(),"",self:getSkillName(),"")
	reason.m_extraData:setValue(self:getRealCard())
	reason.m_useStruct = sgs.CardUseStruct(self,source,targets)
	room:moveCardTo(self,nil,sgs.Player_DiscardPile,reason,true)
end

function use_DelayedTrick_Movable(self,room,source,targets_table)
	if not room:CardInTable(self) then return end
	local nullified_list = room:getTag("CardUseNullifiedList"):toStringList()
	local targets = sgs.SPlayerList()
	for _,p in ipairs(targets_table)do
		if table.contains(nullified_list,"_ALL_TARGETS")
		or table.contains(nullified_list,p:objectName())
		or p:containsTrick(self:objectName()) or p:isDead()
		then elseif p:hasJudgeArea() then targets:append(p) end
	end
	for _,target in sgs.qlist(targets)do
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_USE,source:objectName(),target:objectName(),self:getSkillName(),"")
		reason.m_extraData:setValue(self:getRealCard())
		reason.m_useStruct = sgs.CardUseStruct(self,source,targets)
		room:moveCardTo(self,target,sgs.Player_PlaceDelayedTrick,reason,true)
		return
	end
	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_USE,source:objectName(),"",self:getSkillName(),"")
	reason.m_extraData:setValue(self:getRealCard())
	reason.m_useStruct = sgs.CardUseStruct(self,source,targets)
	room:moveCardTo(self,nil,sgs.Player_DiscardPile,reason,true)
end

function onNullified_DelayedTrick_movable(self,source,tos)
	local room = source:getRoom()
	tos = tos or room:getOtherPlayers(source)
	for _,to in sgs.qlist(tos)do
		if to:containsTrick(self:objectName()) then continue end
		local logm = sgs.LogMessage()
		if not to:hasJudgeArea() then
			logm.type = "#NoJudgeAreaAvoid"
			logm.from = to
			logm.arg = self:objectName()
			room:sendLog(logm)
			continue
		end
		local skill = room:isProhibited(source,to,self)
		if skill
		then
			skill = sgs.Sanguosha:getMainSkill(skill:objectName())
			logm.arg = skill:objectName()
			logm.arg2 = self:objectName()
			logm.type = "#SkillAvoidFrom"
			if to:hasSkill(skill)
			then
				logm.type = "#SkillAvoid"
				logm.from = to
				room:sendLog(logm)
				room:broadcastSkillInvoke(logm.arg)
				room:notifySkillInvoked(to,logm.arg)
			else
				for _,owner in sgs.list(room:getAllPlayers())do
					if owner:hasSkill(skill)
					then
						logm.from = owner
						logm.to:append(to)
						room:sendLog(logm)
						room:broadcastSkillInvoke(logm.arg)
						room:notifySkillInvoked(owner,logm.arg)
						break
					end
				end
			end
			continue
		end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER,source:objectName(),to:objectName(),self:getSkillName(),"")
		reason.m_extraData:setValue(self:getRealCard())
		reason.m_useStruct = sgs.CardUseStruct(self,nil,to)
		room:moveCardTo(self,to,sgs.Player_PlaceDelayedTrick,reason,true)
		local data = sgs.QVariant()
		data:setValue(reason.m_useStruct)
		local thread = room:getThread()
		thread:trigger(sgs.TargetConfirming,room,to,data)
		if data:toCardUse().to:isEmpty()
		then self:on_nullified(to)
		else
			for _,ps in sgs.qlist(room:getAllPlayers())do
				thread:trigger(sgs.TargetConfirmed,room,ps,data)
			end
		end
		break
	end
end

function onNullified_DelayedTrick_unmovable(self,target)
	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER,target:objectName())
	target:getRoom():throwCard(self,reason,nil)
end

--============================================

function sgs.CreateTrickCard(spec)
	assert(type(spec.name)=="string" or type(spec.class_name)=="string")
	
	spec.name = spec.name or spec.class_name
	spec.class_name = spec.class_name or spec.name
	spec.suit = spec.suit or sgs.Card_SuitToBeDecided
	spec.number = spec.number or 0
	
	assert(type(spec.suit)=="number")
	assert(type(spec.number)=="number")

	if type(spec.subtype)~="string"
	then
		local subtype_table = {"TrickCard","single_target_trick","delayed_trick","aoe","global_effect"}
		spec.subtype = subtype_table[(spec.subclass or 0)+1]
	end
	
	local card = sgs.LuaTrickCard(spec.suit,spec.number,spec.name,spec.class_name,spec.subtype)

	if type(spec.target_fixed)=="boolean"
	then card:setTargetFixed(spec.target_fixed)end
	
	if type(spec.can_recast)=="boolean" then
		card:setCanRecast(spec.can_recast)
	end
	
	if type(spec.damage_card)=="boolean" then
		card:setDamageCard(spec.damage_card)
	end
	
	if type(spec.is_gift)=="boolean" then
		card:setGift(spec.is_gift)
	end
	
	if type(spec.single_target)=="boolean" then
		card:setSingleTargetCard(spec.single_target)
	end
	
	if type(spec.subclass)=="number" then card:setSubClass(spec.subclass)
	else card:setSubClass(sgs.LuaTrickCard_TypeNormal) end
	
	if spec.subclass
	then
		if spec.subclass==sgs.LuaTrickCard_TypeDelayedTrick
		then
			if not spec.about_to_use then spec.about_to_use = onUse_DelayedTrick end
			if not spec.on_use
			then 
				if spec.movable then spec.on_use = use_DelayedTrick_Movable
				else spec.on_use = use_DelayedTrick end
			end
			if not spec.on_nullified then
				if spec.movable then spec.on_nullified = onNullified_DelayedTrick_movable
				else spec.on_nullified = onNullified_DelayedTrick_unmovable end
			end
		elseif spec.subclass==sgs.LuaTrickCard_TypeAOE
		then
			if not spec.available then spec.available = isAvailable_AOE end
			if not spec.about_to_use then spec.about_to_use = onUse_AOE end
			if not spec.target_fixed then card:setTargetFixed(true) end
		elseif spec.subclass==sgs.LuaTrickCard_TypeGlobalEffect
		then
			if not spec.available then spec.available = isAvailable_GlobalEffect end
			if not spec.about_to_use then spec.about_to_use = onUse_GlobalEffect end
			if not spec.target_fixed then card:setTargetFixed(true) end
		end
	end
	
	if type(spec.filter)=="function" then
		function card:filter(...)
			local result,vote = spec.filter(self,...)
			if type(result)=="boolean" and type(vote)=="number" then
				return result,vote
			elseif type(result)=="boolean" and vote==nil then
				if result then vote = 1 else vote = 0 end
				return result,vote
			elseif type(result)=="number" then
				return result>0,result
			else
				return false,0
			end
		end
	end
	
	card.feasible = spec.feasible
	card.available = spec.available
	card.is_cancelable = spec.is_cancelable
	card.on_nullified = spec.on_nullified
	card.about_to_use = spec.about_to_use
	card.on_use = spec.on_use
	card.on_effect = spec.on_effect
	
	return card
end

function sgs.CreateViewAsSkill(spec)
	assert(type(spec.name)=="string")
	if spec.response_pattern then assert(type(spec.response_pattern)=="string") end
	if spec.frequency then assert(type(spec.frequency)=="number") end
	if spec.limit_mark then assert(type(spec.limit_mark)=="string") end
	
	--spec.response_pattern = spec.response_pattern or "@@"..spec.name
	local response_or_use = spec.response_or_use or false
	if spec.expand_pile then assert(type(spec.expand_pile)=="string") end
	local expand_pile = spec.expand_pile or ""
	local frequency = spec.frequency or sgs.Skill_NotFrequent
	local limit_mark = spec.limit_mark or ""

	local skill = sgs.LuaViewAsSkill(spec.name,spec.response_pattern,response_or_use,expand_pile,frequency,limit_mark)
	spec.n = spec.n or 0

	function skill:view_as(cards)
		return spec.view_as(self,cards)
	end

	function skill:view_filter(selected,to_select)
		if #selected>=spec.n then return false end
		return spec.view_filter(self,selected,to_select)
	end
	
	if type(spec.guhuo_type)=="string" and spec.guhuo_type~="" then skill:setGuhuoDialog(spec.guhuo_type) end
	if type(spec.juguan_type)=="string" and spec.juguan_type~="" then skill:setJuguanDialog(spec.juguan_type) end
	if type(spec.tiansuan_type)=="string" and spec.tiansuan_type~="" then skill:setTiansuanDialog(spec.tiansuan_type) end
	
	skill.should_be_visible = spec.should_be_visible
	skill.enabled_at_play = spec.enabled_at_play
	skill.enabled_at_response = spec.enabled_at_response
	skill.enabled_at_nullification = spec.enabled_at_nullification

	return skill
end

function sgs.CreateOneCardViewAsSkill(spec)
	assert(type(spec.name)=="string")
	if spec.response_pattern then assert(type(spec.response_pattern)=="string") end
	if spec.frequency then assert(type(spec.frequency)=="number") end
	if spec.limit_mark then assert(type(spec.limit_mark)=="string") end
	
	--spec.response_pattern = spec.response_pattern or "@@"..spec.name
	local response_or_use = spec.response_or_use or false
	if spec.filter_pattern then assert(type(spec.filter_pattern)=="string") end
	if spec.expand_pile then assert(type(spec.expand_pile)=="string") end
	local expand_pile = spec.expand_pile or ""
	local frequency = spec.frequency or sgs.Skill_NotFrequent
	local limit_mark = spec.limit_mark or ""

	local skill = sgs.LuaViewAsSkill(spec.name,spec.response_pattern,response_or_use,expand_pile,frequency,limit_mark)

	if type(spec.guhuo_type)=="string" and spec.guhuo_type~="" then skill:setGuhuoDialog(spec.guhuo_type) end
	if type(spec.juguan_type)=="string" and spec.juguan_type~="" then skill:setJuguanDialog(spec.juguan_type) end
	if type(spec.tiansuan_type)=="string" and spec.tiansuan_type~="" then skill:setTiansuanDialog(spec.tiansuan_type) end
	
	function skill:view_as(cards)
		if #cards~=1 then return nil end
		return spec.view_as(self,cards[1])
	end

	function skill:view_filter(selected,to_select)
		if #selected>=1 or to_select:hasFlag("using") then return false end
		if spec.view_filter then return spec.view_filter(self,to_select) end
		if spec.filter_pattern then
			local pat = spec.filter_pattern
			if string.endsWith(pat,"!") then
				if sgs.Self:isJilei(to_select) then return false end
				pat = string.sub(pat,1,-2)
			end
			return sgs.Sanguosha:matchExpPattern(pat,sgs.Self,to_select)
		end
	end

	skill.enabled_at_play = spec.enabled_at_play
	skill.enabled_at_response = spec.enabled_at_response
	skill.enabled_at_nullification = spec.enabled_at_nullification

	return skill
end

function sgs.CreateZeroCardViewAsSkill(spec)
	assert(type(spec.name)=="string")
	if spec.response_pattern then assert(type(spec.response_pattern)=="string") end
	if spec.frequency then assert(type(spec.frequency)=="number") end
	if spec.limit_mark then assert(type(spec.limit_mark)=="string") end
	
	--spec.response_pattern = spec.response_pattern or "@@"..spec.name
	local response_or_use = spec.response_or_use or false
	local frequency = spec.frequency or sgs.Skill_NotFrequent
	local limit_mark = spec.limit_mark or ""

	local skill = sgs.LuaViewAsSkill(spec.name,spec.response_pattern,response_or_use,"",frequency,limit_mark)

	if type(spec.guhuo_type)=="string" and spec.guhuo_type~="" then skill:setGuhuoDialog(spec.guhuo_type) end
	if type(spec.juguan_type)=="string" and spec.juguan_type~="" then skill:setJuguanDialog(spec.juguan_type) end
	if type(spec.tiansuan_type)=="string" and spec.tiansuan_type~="" then skill:setTiansuanDialog(spec.tiansuan_type) end
	
	function skill:view_as(cards)
		if #cards>0 then return nil end
		return spec.view_as(self)
	end

	function skill:view_filter(selected,to_select)
		return false
	end

	skill.enabled_at_play = spec.enabled_at_play
	skill.enabled_at_response = spec.enabled_at_response
	skill.enabled_at_nullification = spec.enabled_at_nullification

	return skill
end

function sgs.CreateEquipCard(spec)
	assert(type(spec.location)=="number")
	assert(type(spec.name)=="string" or type(spec.class_name)=="string")
	
	spec.name = spec.name or spec.class_name
	spec.class_name = spec.class_name or spec.name
	spec.suit = spec.suit or sgs.Card_SuitToBeDecided
	spec.number = spec.number or 0
	
	local card
	if spec.location==sgs.EquipCard_WeaponLocation
	then
		spec.range = spec.range or 1
		card = sgs.LuaWeapon(spec.suit,spec.number,spec.range,spec.name,spec.class_name)
	elseif spec.location==sgs.EquipCard_ArmorLocation
	then card = sgs.LuaArmor(spec.suit,spec.number,spec.name,spec.class_name)
	elseif spec.location==sgs.EquipCard_OffensiveHorseLocation
	then
		spec.correct = spec.correct or -1
		card = sgs.LuaOffensiveHorse(spec.suit,spec.number,spec.correct,spec.name,spec.class_name)
	elseif spec.location==sgs.EquipCard_DefensiveHorseLocation
	then
		spec.correct = spec.correct or 1
		card = sgs.LuaDefensiveHorse(spec.suit,spec.number,spec.correct,spec.name,spec.class_name)
	elseif spec.location==sgs.EquipCard_TreasureLocation
	then card = sgs.LuaTreasure(spec.suit,spec.number,spec.name,spec.class_name) end
	assert(card)
	if type(spec.is_gift)=="boolean" then card:setGift(spec.is_gift) end
	if type(spec.target_fixed)=="boolean" then card:setTargetFixed(spec.target_fixed)end
	if type(spec.feasible)=="function" then card.feasible = spec.feasible end
	if type(spec.filter)=="function" then
		function card:filter(...)
			local result,vote = spec.filter(self,...)
			if type(result)=="boolean" and type(vote)=="number" then
				return result,vote
			elseif type(result)=="boolean" and vote==nil then
				if result then vote = 1 else vote = 0 end
				return result,vote
			elseif type(result)=="number" then
				return result>0,result
			else
				return false,0
			end
		end
	end
	card.available = spec.available
	card.on_install = spec.on_install
	card.on_uninstall = spec.on_uninstall
	
	return card
end

function sgs.CreateWeapon(spec)
	spec.location = sgs.EquipCard_WeaponLocation
	return sgs.CreateEquipCard(spec)
end

function sgs.CreateArmor(spec)
	spec.location = sgs.EquipCard_ArmorLocation	
	return sgs.CreateEquipCard(spec)
end

function sgs.CreateOffensiveHorse(spec)
	spec.location = sgs.EquipCard_OffensiveHorseLocation
	return sgs.CreateEquipCard(spec)
end

function sgs.CreateDefensiveHorse(spec)
	spec.location = sgs.EquipCard_DefensiveHorseLocation
	return sgs.CreateEquipCard(spec)
end

function sgs.CreateTreasure(spec)
	spec.location = sgs.EquipCard_TreasureLocation
	return sgs.CreateEquipCard(spec)
end


function sgs.LoadTranslationTable(t)
	for key,value in pairs(t)do
		sgs.AddTranslationEntry(key,value)
	end
end