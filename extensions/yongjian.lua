yongjian = sgs.Package("yongjian",sgs.Package_CardPack)

function AddPresentCard(c,suit,number,present,revise)
	c = c:clone(suit,number)
	if c
	then
		if present then c:setProperty("YingBianEffects",ToData("present_card")) end
		if revise then c:setObjectName(revise) end
		c:setParent(yongjian)
	end
end

function AddCloneCard(name,suit,number,present,revise)
	name = sgs.Sanguosha:cloneCard(name,suit,number)
	if name
	then
		if present then name:setProperty("YingBianEffects",ToData("present_card")) end
		if revise then name:setObjectName(revise) end
		name:setParent(yongjian)
	end
end


yj_poison = sgs.CreateBasicCard{
	name = "yj_poison",
	class_name = "YjPoison",
	subtype = "debuff_card",
    can_recast = false,
    available = function(self,player)
        return false
    end,
	filter = function(self,targets,to_select,source)
	    return #targets<1 and not source:isProhibited(to_select,self)
		and source:objectName()~=to_select:objectName()
	end,
	about_to_use = function(self,room,use)
		if use.to:length()>0
		then
			room:broadcastSkillInvoke("yj_poison",use.from:isMale(),1)
			for _,to in sgs.list(use.to)do
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION,use.from:objectName(),to:objectName(),"yj_poison","")
				Log_message("$yj_poison",use.from,use.to,self:getEffectiveId(),"yj_poison")
				use.from:addMark("BanPoisonEffect")
				room:obtainCard(to,self,reason)
				use.from:removeMark("BanPoisonEffect")
			end
		end
	end,
}
AddPresentCard(yj_poison,0,4,true)
AddPresentCard(yj_poison,0,5,true)
AddPresentCard(yj_poison,0,9,true)
AddPresentCard(yj_poison,0,10,true)
AddPresentCard(yj_poison,1,4)

yj_slash = sgs.CreateBasicCard{
	name = "slash",
	class_name = "Slash",
	subtype = "attack_card",
    can_recast = false,
	damage_card = true,
    available = function(self,player)
    	for n,to in sgs.list(player:getAliveSiblings())do
			if self:cardIsAvailable(player)
			and CanToCard(self,player,to)
			then
				n = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue,player,self)
				if player:hasWeapon("vscrossbow")
				then
					n = n+3
					if self:isVirtualCard()
					and self:subcardsLength()>0
					then
						local w = player:getWeapon()
						if w and w:objectName()=="vscrossbow"
						and self:getSubcards():contains(w:getId())
						then n = n-3 end
					end
				end
				if player:hasWeapon("crossbow")
				then
					n = n+999
					if self:isVirtualCard()
					and self:subcardsLength()>0
					then
						local w = player:getWeapon()
						if w and w:objectName()=="crossbow"
						and self:getSubcards():contains(w:getId())
						then n = n-999 end
					end
				end
				if player:getSlashCount()<=n
				or player:canSlashWithoutCrossbow() then return true end
				n = player:property("extra_slash_specific_assignee"):toString():split("+")
				if table.contains(n,to:objectName()) then return true end
			end
		end
    end,
	filter = function(self,targets,to_select,source)
		local x = 0
		if self:isVirtualCard()
		and self:subcardsLength()>0
		then
			local w = source:getWeapon()
			if w and self:getSubcards():contains(w:getId())
			then x = x+source:getAttackRange()-source:getAttackRange(false) end
			local oh = source:getOffensiveHorse()
			if oh and self:getSubcards():contains(oh:getId())
			then x = x+1 end
		end
		return source:canSlash(to_select,self,true,x)
	   	and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)
	end,
	on_use = function(self,room,source,targets)
 		local effect = sgs.CardEffectStruct()
		effect.from = source
		effect.card = self
		effect.multiple = #targets>1
		local no_offset_list = room:getTag("CardUseNoOffsetList"):toStringList()
		local no_respond_list = room:getTag("CardUseNoRespondList"):toStringList()
		local nullified_list = room:getTag("CardUseNullifiedList"):toStringList()
		room:setTag("drank"..self:toString(),ToData(source:getMark("drank")))
        room:setPlayerMark(source,"drank",0)
		for _,to in sgs.list(targets)do
			effect.to = to
			effect.no_offset = table.contains(no_offset_list,"_ALL_TARGETS") or table.contains(no_offset_list,to:objectName())
			effect.no_respond = table.contains(no_respond_list,"_ALL_TARGETS") or table.contains(no_respond_list,to:objectName())
			effect.nullified = table.contains(nullified_list,"_ALL_TARGETS") or table.contains(nullified_list,to:objectName())
			room:cardEffect(effect)
        end
		room:removeTag("drank"..self:toString())
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		local se = sgs.SlashEffectStruct()
        se.from = effect.from
        se.nature = sgs.DamageStruct_Normal
        se.slash = effect.card
        se.to = effect.to
        se.drank = room:getTag("drank"..self:toString()):toInt()
        se.nullified = effect.nullified
        se.no_offset = effect.no_offset
        se.no_respond = effect.no_respond
        se.multiple = effect.multiple
		local jn = effect.from:getTag("Jink_"..effect.card:toString()):toIntList()
		if jn:isEmpty() then se.jink_num = 1
		else
			se.jink_num = jn:at(0)
			jn:removeOne(jn:at(0))
			effect.from:setTag("Jink_"..effect.card:toString(),ToData(jn))
		end
		room:slashEffect(se)
	end,
}
AddPresentCard(yj_slash,2,5,true)
AddPresentCard(yj_slash,2,10,true)
AddPresentCard(yj_slash,2,11,true)
AddPresentCard(yj_slash,2,12,true)
--[[
AddCloneCard("Slash",2,5,true,"slash")
AddCloneCard("Slash",2,10,true,"slash")
AddCloneCard("Slash",2,11,true,"slash")
AddCloneCard("Slash",2,12,true,"slash")--]]

AddPresentCard(yj_slash,0,6,nil,"yj_stabs_slash")
AddPresentCard(yj_slash,0,7,nil,"yj_stabs_slash")
AddPresentCard(yj_slash,0,8,nil,"yj_stabs_slash")
AddPresentCard(yj_slash,1,2,nil,"yj_stabs_slash")
AddPresentCard(yj_slash,1,6,nil,"yj_stabs_slash")
AddPresentCard(yj_slash,1,7,nil,"yj_stabs_slash")
AddPresentCard(yj_slash,1,8,nil,"yj_stabs_slash")
AddPresentCard(yj_slash,1,9,nil,"yj_stabs_slash")
AddPresentCard(yj_slash,1,10,nil,"yj_stabs_slash")
AddPresentCard(yj_slash,3,13,nil,"yj_stabs_slash")
--[[
AddCloneCard("Slash",0,6,nil,"yj_stabs_slash")
AddCloneCard("Slash",0,7,nil,"yj_stabs_slash")
AddCloneCard("Slash",0,8,nil,"yj_stabs_slash")
AddCloneCard("Slash",1,2,nil,"yj_stabs_slash")
AddCloneCard("Slash",1,6,nil,"yj_stabs_slash")
AddCloneCard("Slash",1,7,nil,"yj_stabs_slash")
AddCloneCard("Slash",1,8,nil,"yj_stabs_slash")
AddCloneCard("Slash",1,9,nil,"yj_stabs_slash")
AddCloneCard("Slash",1,10,nil,"yj_stabs_slash")
AddCloneCard("Slash",3,13,nil,"yj_stabs_slash")--]]

yj_jink = sgs.CreateBasicCard{
	name = "jink",
	class_name = "Jink",
	subtype = "defense_card",
    can_recast = false,
	target_fixed = true,
--	damage_card = true,
    available = function(self,player)
        return false
    end,
}
AddPresentCard(yj_jink,2,2,true)
AddPresentCard(yj_jink,3,2,true)
AddPresentCard(yj_jink,3,5)
AddPresentCard(yj_jink,3,6)
AddPresentCard(yj_jink,3,7)
AddPresentCard(yj_jink,3,8)
AddPresentCard(yj_jink,3,12)
--[[
AddCloneCard("Jink",2,2,true,"jink")
AddCloneCard("Jink",3,2,true,"jink")
AddCloneCard("Jink",3,5,nil,"jink")
AddCloneCard("Jink",3,6,nil,"jink")
AddCloneCard("Jink",3,7,nil,"jink")
AddCloneCard("Jink",3,8,nil,"jink")
AddCloneCard("Jink",3,12,nil,"jink")--]]

yj_peach = sgs.CreateBasicCard{
	name = "peach",
	class_name = "Peach",
	subtype = "recover_card",
    can_recast = false,
	target_fixed = true,
    available = function(self,player)
        if player:isProhibited(player,self) then return end
		return player:getLostHp()>0 and self:cardIsAvailable(player)
    end,
	about_to_use = function(self,room,use)
		if use.to:isEmpty() then use.to:append(use.from) end
		self:cardOnUse(room,use)
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		room:setEmotion(effect.from,"peach")
		room:recover(effect.to,sgs.RecoverStruct(effect.from,self))
	end
}
AddPresentCard(yj_peach,2,7)
AddPresentCard(yj_peach,2,8)
AddPresentCard(yj_peach,3,11,true)
--[[
AddCloneCard("Peach",2,7,nil,"peach")
AddCloneCard("Peach",2,8,nil,"peach")
AddCloneCard("Peach",3,11,true,"peach")--]]

yj_snatch = sgs.CreateTrickCard{
	name = "snatch",
	class_name = "Snatch",
    can_recast = false,
--	target_fixed = true,
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
    available = function(self,player)
    	for _,to in sgs.list(player:getAliveSiblings())do
			if CanToCard(self,player,to)
			then
				return self:cardIsAvailable(player)
			end
		end
    end,
	filter = function(self,targets,to_select,source)
        if source:isProhibited(to_select,self) then return end
		return #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)
		and to_select:getCardCount(true,true)>0
		and source:distanceTo(to_select)==1
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		if effect.from and effect.to:getCardCount(true,true)>0
		then
			local id = room:askForCardChosen(effect.from,effect.to,"hej",self:objectName())
			if id<0 then return end
			room:obtainCard(effect.from,sgs.Sanguosha:getCard(id),false)
		end
	end,
}
AddPresentCard(yj_snatch,0,3,true)
--AddCloneCard("Snatch",0,3,true,"snatch")

yj_nullification = sgs.CreateTrickCard{
	name = "nullification",
	class_name = "Nullification",
    can_recast = false,
	target_fixed = true,
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
    available = function(self,player)
        return false
    end,
	on_use = function(self,room,source,targets)
		local no_offset_list = room:getTag("CardUseNoOffsetList"):toStringList()
		local no_respond_list = room:getTag("CardUseNoRespondList"):toStringList()
    	for _,p in sgs.list(room:getAlivePlayers())do
			if table.contains(no_offset_list,"_ALL_TARGETS") or table.contains(no_offset_list,p:objectName())
			then room:setPlayerMark(p,"no_offset_"..self:toString().."-Clear",1) end
			if table.contains(no_respond_list,"_ALL_TARGETS") or table.contains(no_respond_list,p:objectName())
			then room:setPlayerMark(p,"no_respond_"..self:toString().."-Clear",1) end
        end
		if room:getCardPlace(self:getEffectiveId())==sgs.Player_PlaceTable
		then
			local reason = source and source:objectName() or ""
			reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_USE,reason,"",self:getSkillName(),"")
			reason.m_extraData = ToData(self)
			reason.m_useStruct.from = source
			reason.m_useStruct.card = self
			reason.m_useStruct.no_offset_list = no_offset_list
			reason.m_useStruct.no_respond_list = no_respond_list
			room:moveCardTo(self,source,nil,sgs.Player_DiscardPile,reason,true)
		end
		if source
		then
			local users = room:getTag("CurrentCardUsers_"..self:toString()):toStringList()
			table.insert(users,source:objectName()) 
			room:setTag("CurrentCardUsers_"..self:toString(),ToData(table.concat(users,"+")))
		end
	end,
}
AddPresentCard(yj_nullification,0,11)
AddPresentCard(yj_nullification,1,11)
AddPresentCard(yj_nullification,1,12)
--[[
AddCloneCard("Nullification",0,11,nil,"nullification")
AddCloneCard("Nullification",1,11,nil,"nullification")
AddCloneCard("Nullification",1,12,nil,"nullification")--]]

yj_amazing_grace = sgs.CreateTrickCard{
	name = "amazing_grace",
	class_name = "AmazingGrace",
    can_recast = false,
	target_fixed = true,
	subclass = sgs.LuaTrickCard_TypeGlobalEffect,
	on_use = function(self,room,source,targets)
    	local ids = room:getNCards(#targets)
		room:fillAG(ids)
		local effect = sgs.CardEffectStruct()
		effect.from = source
		effect.card = self
		effect.multiple = #targets>1
		room:setTag("AmazingGrace",ToData(ids))
		local no_offset_list = room:getTag("CardUseNoOffsetList"):toStringList()
		local no_respond_list = room:getTag("CardUseNoRespondList"):toStringList()
		local nullified_list = room:getTag("CardUseNullifiedList"):toStringList()
		for _,to in sgs.list(targets)do
			effect.to = to
			effect.no_offset = table.contains(no_offset_list,"_ALL_TARGETS") or table.contains(no_offset_list,to:objectName())
			effect.no_respond = table.contains(no_respond_list,"_ALL_TARGETS") or table.contains(no_respond_list,to:objectName())
			effect.nullified = table.contains(nullified_list,"_ALL_TARGETS") or table.contains(nullified_list,to:objectName())
			room:cardEffect(effect)
        end
		room:clearAG()
		ids = room:getTag("AmazingGrace"):toIntList()
       	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER,nil,nil,self:objectName(),nil)
		if ids:isEmpty() then return end
       	effect = dummyCard()
	    effect:addSubcards(ids)
    	room:throwCard(effect,reason,nil)--弃牌
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		local ag_list = room:getTag("AmazingGrace"):toIntList()
        local card_id = room:askForAG(effect.to,ag_list,false,self:objectName())
        room:takeAG(effect.to,card_id)
        ag_list:removeOne(card_id)
		room:setTag("AmazingGrace",ToData(ag_list))
	end,
}
AddPresentCard(yj_amazing_grace,2,3,true)
--AddCloneCard("AmazingGrace",2,3,true,"amazing_grace")

yj_duel = sgs.CreateTrickCard{
	name = "duel",
	class_name = "Duel",
    can_recast = false,
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
--	target_fixed = true,
	damage_card = true,
    available = function(self,player)
    	for _,to in sgs.list(player:getAliveSiblings())do
			if CanToCard(self,player,to)
			then
				return self:cardIsAvailable(player)
			end
		end
    end,
	filter = function(self,targets,to_select,source)
        if source:isProhibited(to_select,self) then return end
		return #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)
		and source:objectName()~=to_select:objectName()
	end,
	on_effect = function(self,effect)
		local room,from,to = effect.to:getRoom(),effect.from,effect.to
		room:setEmotion(from,"duel")
		room:setEmotion(to,"duel")
		if effect.no_respond
		then room:damage(sgs.DamageStruct(self,from,to))
		else
			while from do
	        	local slash = to:isAlive() and room:askForCard(to,"slash","duel-slash:"..from:objectName(),
				ToData(effect),sgs.Card_MethodResponse,from,false,"duel",false,self)
				if slash
				then
					local ids = to:getTag("DuelSlash"..self:toString()):toIntList()
					for _,id in sgs.list(slash:getSubcards())do
						ids:append(id)
					end
					to:setTag("DuelSlash"..self:toString(),ToData(ids))
				end
				if slash and from:isAlive()
				and table.contains(from:getTag("Wushuang_"..self:toString()):toStringList(),to:objectName())
	        	then
					slash = to:isAlive() and room:askForCard(to,"slash","duel-slash:"..from:objectName(),
					ToData(effect),sgs.Card_MethodResponse,from,false,"duel",false,self)
					if slash
					then
						local ids = to:getTag("DuelSlash"..self:toString()):toIntList()
						for _,id in sgs.list(slash:getSubcards())do
							ids:append(id)
						end
						to:setTag("DuelSlash"..self:toString(),ToData(ids))
					end
				end
				if slash
	        	then
					local ids = to:getTag("DuelSlash"..self:toString()):toIntList()
					for _,id in sgs.list(slash:getSubcards())do
						ids:append(id)
					end
					to:setTag("DuelSlash"..self:toString(),ToData(ids))
		        	local to_from = from
					from = to
					to = to_from
                else
					slash = sgs.DamageStruct(self,from,to)
					slash.by_user = effect.from==from
					room:damage(slash)
					break
				end
			end
		end
		from:removeTag("DuelSlash"..self:toString())
		to:removeTag("DuelSlash"..self:toString())
	end,
}
AddPresentCard(yj_duel,3,1,true)
--AddCloneCard("Duel",3,1,true,"duel")

AddCloneCard("OffensiveHorse",1,13,true,"yj_numa")
yj_numabf = sgs.CreateDistanceSkill{
	name = "yj_numa",
	correct_func = function(self,from,to)
		local to_dh = to and to:getOffensiveHorse()
		if to_dh and to_dh:objectName()=="yj_numa"
		then return -997 end
	end
}
addToSkills(yj_numabf)
sgs.HorseSkill.yj_numa = {
	on_install = function(c,player,room)
		player:acquireSkill("yj_numa")
	end,
	on_uninstall = function(c,player,room)
		player:detachSkill("yj_numa")
	end
}
AddCloneCard("DefensiveHorse",2,13,true,"yj_zhanxiang")
yj_zhanxiangTr = sgs.CreateTriggerSkill{
	name = "yj_zhanxiang",
	events = {sgs.BeforeCardsMove},
	can_trigger = function(self,target)
		local dh = target and target:getDefensiveHorse()
		return dh and dh:objectName()=="yj_zhanxiang"
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.BeforeCardsMove
	   	then
	     	local move = data:toMoveOneTime()
			if move.to and player:objectName()==move.to:objectName()
	       	then
				local ids = {}
				for _,id in sgs.list(move.card_ids)do
					if player:getTag("PresentCard"):toString()==tostring(id)
					then table.insert(ids,id) end
				end
				if #ids>0
				then
					room:sendCompulsoryTriggerLog(player,"yj_zhanxiang",true)
					room:setEmotion(player,"armor/yj_zhanxiang")
					local tos = sgs.SPlayerList()
					if move.from then tos:append(BeMan(room,move.from)) end
					Log_message("$yj_zhanxiang",player,tos,table.concat(ids,"+"),"yj_zhengyu_fail")
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
yj_chenhuodajie = sgs.CreateTrickCard{
	name = "yj_chenhuodajie",
	class_name = "YjChenhuodajie",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	damage_card = true,
    available = function(self,player)
    	for _,to in sgs.list(player:getAliveSiblings())do
			if CanToCard(self,player,to)
			then
				return self:cardIsAvailable(player)
			end
		end
    end,
	filter = function(self,targets,to_select,source)
	    return to_select:getHandcardNum()>0
		and to_select:objectName()~=source:objectName()
		and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)
	end,
	on_effect = function(self,effect)
		local from,to,room = effect.from,effect.to,effect.to:getRoom()
		if to:getHandcardNum()<1 then return end
		local id = room:askForCardChosen(from,to,"h",self:objectName())
		if id~=-1
		then
			room:showCard(to,id)
			local c = sgs.Sanguosha:getCard(id)
			if room:askForCard(to,id,"yj_chenhuodajie0:"..c:objectName()..":"..from:objectName(),ToData(effect),sgs.Card_MethodNone)
			then room:obtainCard(from,c) else room:damage(sgs.DamageStruct(self,from,to)) end
		end
		return false
	end,
}
AddPresentCard(yj_chenhuodajie,0,12)
AddPresentCard(yj_chenhuodajie,0,13)
AddPresentCard(yj_chenhuodajie,2,6)

yj_guaguliaodu = sgs.CreateTrickCard{
	name = "yj_guaguliaodu",
	class_name = "YjGuaguliaodu",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
--	damage_card = true,
    available = function(self,player)
    	for _,to in sgs.list(player:getAliveSiblings())do
			if CanToCard(self,player,to)
			then
				return self:cardIsAvailable(player)
			end
		end
    end,
	filter = function(self,targets,to_select,source)
	    return to_select:isWounded()
		and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)
	end,
	on_effect = function(self,effect)
		local from,to,room = effect.from,effect.to,effect.to:getRoom()
		room:recover(to,sgs.RecoverStruct(from,self))
		if hasCard(to,"YjPoison")
		then
			to:addMark("BanPoisonEffect")
			room:askForCard(to,"YjPoison","yj_guaguliaodu0:yj_poison",ToData(effect))
			to:removeMark("BanPoisonEffect")
		end
		return false
	end,
}
AddPresentCard(yj_guaguliaodu,0,1)
AddPresentCard(yj_guaguliaodu,2,1)

yj_shushangkaihua = sgs.CreateTrickCard{
	name = "yj_shushangkaihua",
	class_name = "YjShushangkaihua",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = true,
	can_recast = false,
	is_cancelable = true,
--	damage_card = true,
	about_to_use = function(self,room,use)
		if use.to:isEmpty() then use.to:append(use.from) end
		self:cardOnUse(room,use)
	end,
	on_effect = function(self,effect)
		local from,to,room = effect.from,effect.to,effect.to:getRoom()
		local discard = room:askForDiscard(to,"yj_shushangkaihua",2,1,false,true,"yj_shushangkaihua0:")
		if discard and discard:subcardsLength()>0
		then
			local n = discard:subcardsLength()
			for _,id in sgs.list(discard:getSubcards())do
				if sgs.Sanguosha:getCard(id):isKindOf("EquipCard")
				then n = n+1 break end
			end
			to:drawCards(n,self:objectName())
		end
		return false
	end,
}
AddPresentCard(yj_shushangkaihua,3,3,true)
AddPresentCard(yj_shushangkaihua,3,4,true)

yj_tuixinzhifu = sgs.CreateTrickCard{
	name = "yj_tuixinzhifu",
	class_name = "YjTuixinzhifu",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
--	damage_card = true,
    available = function(self,player)
    	for _,to in sgs.list(player:getAliveSiblings())do
			if CanToCard(self,player,to)
			then
				return self:cardIsAvailable(player)
			end
		end
    end,
	filter = function(self,targets,to_select,source)
	    local range_fix = 0
		if self:isVirtualCard()
		and self:subcardsLength()>0
		then
			local oh = source:getOffensiveHorse()
			if oh and self:getSubcards():contains(oh:getId())
			then range_fix = range_fix+1 end
		end
		return source:distanceTo(to_select,range_fix)==1 and to_select:getCardCount(true,true)>0
		and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)
	end,
	on_effect = function(self,effect)
		local from,to,room = effect.from,effect.to,effect.to:getRoom()
		local flags = to:getCards("ej"):length()<1 and "h" or "hej"
		local dc = dummyCard()
		for i=1,2 do
			if from:isAlive()
			and to:getCardCount(true,true)>dc:subcardsLength()
			then
				i = dc:getSubcards()
				from:setTag("askForCardChosen_ForAI",ToData(i))
				local id = room:askForCardChosen(from,to,flags,self:objectName(),false,sgs.Card_MethodNone,i,true)
				from:removeTag("askForCardChosen_ForAI")
				if id and id~=-1
				then
					if i:contains(id)
					then
						for n,f in sgs.list(to:getCards(flags))do
							n = f:getEffectiveId()
							if i:contains(n) or id==n then
							elseif room:getCardPlace(id)==room:getCardPlace(n)
							then dc:addSubcard(n) break end
						end
					else
						dc:addSubcard(id)
					end
					if flags:match("h")
					then
						local can
						for _,cid in sgs.list(to:handCards())do
							if dc:getSubcards():contains(cid)
							then else can = true break end
						end
						if not can then flags = "ej" end
					end
				else break end
			end
		end
		if dc:subcardsLength()>0
		then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION,from:objectName(),to:objectName(),"yj_tuixinzhifu","")
			room:obtainCard(from,dc,reason,false)
			if from:isAlive() and to:isAlive()
			then
	    	   	dc = dc:subcardsLength()
				from:setTag("yj_tuixinzhifu",ToData(to))
				dc = room:askForExchange(from,"yj_tuixinzhifu",dc,dc,false,"yj_tuixinzhifu0:"..dc..":"..to:objectName())
				room:giveCard(from,to,dc,"yj_tuixinzhifu")
			end
		end
		return false
	end,
}
AddPresentCard(yj_tuixinzhifu,3,9)
AddPresentCard(yj_tuixinzhifu,3,10)

yj_nvzhuangTr = sgs.CreateTriggerSkill{
	name = "yj_nvzhuang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetConfirmed,sgs.DamageForseen},
	can_trigger = function(self,target)
		return target and target:hasArmorEffect("yj_nvzhuang")
		and ArmorNotNullified(target)
	end,
	on_trigger = function(self,event,player,data,room)
    	if event==sgs.TargetConfirmed
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
			and use.to:contains(player)
			and player:isMale()
			then
                room:sendCompulsoryTriggerLog(player,"yj_nvzhuang",true)
	         	room:setEmotion(player,"armor/yj_nvzhuang")
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|black"
				judge.good = false
				judge.negative = true
				judge.reason = self:objectName()
				judge.who = player
				room:judge(judge)
				if judge:isBad()
				then
					room:setCardFlag(use.card,"yj_nvzhuang_debuff")
				end
			end
    	elseif event==sgs.DamageForseen
		then
 		    local damage = data:toDamage()
            if damage.card and damage.card:hasFlag("yj_nvzhuang_debuff")
			then
    	        Skill_msg(self,player)
				DamageRevises(data,1,player)
			end
		end
		return false
	end
}
yj_nvzhuang = sgs.CreateArmor{
	name = "yj_nvzhuang",
	class_name = "YjNvzhuang",
--	is_gift = true,
	on_install = function(self,player)
		local room = player:getRoom()
		room:acquireSkill(player,yj_nvzhuangTr,false,true,false)
		return false
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player,"yj_nvzhuang",true,true)
		return false
	end,
}
AddPresentCard(yj_nvzhuang,2,9,true)

yj_qixingbaodao = sgs.CreateWeapon{
	name = "yj_qixingbaodao",
	class_name = "YjQixingbaodao",
	range = 2,
--	is_gift = true,
	on_install = function(self,player)
		local room = player:getRoom()
        room:sendCompulsoryTriggerLog(player,"yj_qixingbaodao",true)
	   	room:setEmotion(player,"weapon/yj_qixingbaodao")
		local dc = dummyCard()
		for i,c in sgs.list(player:getCards("ej"))do
			if c:getEffectiveId()~=self:getEffectiveId()
			then dc:addSubcard(c) end
		end
		if dc:subcardsLength()>0
		then
			room:throwCard(dc,player)
		end
	end
}
AddPresentCard(yj_qixingbaodao,0,2,true)

yj_xingecard = sgs.CreateSkillCard{
	name = "yj_xingecard",
	will_throw = false,
	filter = function(self,targets,to_select,source)
		return to_select:objectName()~=source:objectName()
		and #targets<1
	end,
	on_effect = function(self,effect)
		local source,target,room = effect.from,effect.to,effect.to:getRoom()
		room:giveCard(source,target,self,"yj_xinge")
	end,
}
yj_xingeTr = sgs.CreateViewAsSkill{
	name = "yj_xinge",
	n = 1,
	view_filter = function(self,selected,to_select)
       	return not to_select:isEquipped()
	end,
	view_as = function(self,cards)
	   	if #cards<1 then return end
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		pattern = yj_xingecard:clone()
	   	for _,cid in sgs.list(cards)do
	   	    pattern:addSubcard(cid)
	   	end
		return pattern
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#yj_xingecard")<1
	end,
}
yj_xinge = sgs.CreateTreasure{
	name = "yj_xinge",
	class_name = "YjXinge",
--	is_gift = true,
	on_install = function(self,player)
		local room = player:getRoom()
		room:attachSkillToPlayer(player,"yj_xinge")
		return false
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player,"yj_xinge",true,true)
		return false
	end,
}
AddPresentCard(yj_xinge,2,4,true)
addToSkills(yj_xingeTr)

yj_yinfengyiTr = sgs.CreateTriggerSkill{
	name = "yj_yinfengyi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreHpLost,sgs.DamageForseen},
	can_trigger = function(self,target)
		return target and target:hasArmorEffect("yj_yinfengyi")
		and ArmorNotNullified(target)
	end,
	on_trigger = function(self,event,player,data,room)
    	if event==sgs.PreHpLost
		then
			if player:hasFlag("YjPoison")
			then
				data:setValue(data:toInt()+1)
				player:setFlags("-YjPoison")
			else
				local lose = data:toHpLost()
				if lose.reason=="yj_poison"
				then
					room:sendCompulsoryTriggerLog(player,"yj_yinfengyi",true)
					room:setEmotion(player,"armor/yj_yinfengyi")
					lose.lose = lose.lose+1
					data:setValue(lose)
				end
			end
    	elseif event==sgs.DamageForseen
		then
 		    local damage = data:toDamage()
            if damage.card and damage.card:isKindOf("TrickCard")
			then
                room:sendCompulsoryTriggerLog(player,"yj_yinfengyi",true)
	         	room:setEmotion(player,"armor/yj_yinfengyi")
				return DamageRevises(data,1,player)
			end
		end
		return false
	end
}
yj_yinfengyi = sgs.CreateArmor{
	name = "yj_yinfengyi",
	class_name = "YjYinfengyi",
--	is_gift = true,
	on_install = function(self,player)
		local room = player:getRoom()
		room:acquireSkill(player,yj_yinfengyiTr,false,true,false)
		return false
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player,"yj_yinfengyi",true,true)
		return false
	end,
}
AddPresentCard(yj_yinfengyi,1,3,true)

yj_yitianjianTr = sgs.CreateTriggerSkill{
	name = "yj_yitianjian",
--	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damage},
	can_trigger = function(self,target)
		return target and target:hasWeapon("yj_yitianjian")
	end,
	on_trigger = function(self,event,player,data,room)
   		if event==sgs.Damage
		then
		    local damage = data:toDamage()
        	if damage.card and damage.card:isKindOf("Slash")
			and player:isWounded() and player:getHandcardNum()>0
			and room:askForCard(player,".|.|.|hand","yj_yitianjian0:",data,"yj_yitianjian")
        	then
	         	room:setEmotion(player,"weapon/yj_yitianjian")
		    	room:recover(player,sgs.RecoverStruct(player,player:getWeapon()))
			end
		end
		return false
	end
}
yj_yitianjian = sgs.CreateWeapon{
	name = "yj_yitianjian",
	class_name = "YjYitianjian",
	range = 2,
	on_install = function(self,player)
		player:getRoom():acquireSkill(player,yj_yitianjianTr,false,true,false)
	end,
	on_uninstall = function(self,player)
		player:getRoom():detachSkillFromPlayer(player,"yj_yitianjian",true,true)
	end,
}
AddPresentCard(yj_yitianjian,1,5)

yj_zheji = sgs.CreateWeapon{
	name = "yj_zheji",
	class_name = "YjZheji",
	range = 0,
--	is_gift = true,
	on_install = function() end,
	on_uninstall = function() end,
}
AddPresentCard(yj_zheji,1,1,true)

function PresentCardJudge(id)
	id = type(id)=="number" and id or id:getEffectiveId()
	return id>=0 and sgs.Sanguosha:getEngineCard(id):property("YingBianEffects"):toString()=="present_card"
end

yj_zhengyuCard = sgs.CreateSkillCard{
	name = "yj_zhengyuCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self,targets,to_select,source)
		for c,id in sgs.list(self:getSubcards())do
			c = sgs.Sanguosha:getCard(id)
			if c:isKindOf("EquipCard")
			then
				c = c:getRealCard():toEquipCard():location()
				if to_select:hasEquipArea(c)
				then else return false end
			end
		end
	    return #targets<1
		and source:objectName()~=to_select:objectName()
	end,
	about_to_use = function(self,room,use)
		room:broadcastSkillInvoke("yj_zhengyu",use.from:isMale(),1)
		for _,to in sgs.list(use.to)do
			local moves = sgs.CardsMoveList()
			room:doAnimate(1,use.from:objectName(),to:objectName())
			for c,id in sgs.list(self:getSubcards())do
				local move1 = sgs.CardsMoveStruct()
				move1.card_ids:append(id)
				move1.from = use.from
				move1.to = to
				move1.to_place = sgs.Player_PlaceHand
				move1.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECYCLE,use.from:objectName(),to:objectName(),"yj_zhengyu","")
				Log_message("$PresentCard",use.from,use.to,id,"yj_zhengyu")
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
						move2.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_MASK_BASIC_REASON,use.from:objectName(),to:objectName(),"yj_zhengyu","")
						moves:append(move2)
					end
				end
				moves:append(move1)
				to:setTag("PresentCard",ToData(tostring(id)))
				to:setTag("PresentFrom",ToData(use.from))
			end
			room:moveCardsAtomic(moves,true)
			to:removeTag("PresentCard")
			to:removeTag("PresentFrom")
		end
	end
}
yj_zhengyu = sgs.CreateViewAsSkill{
	name = "yj_zhengyu&",
	n = 1,
	view_filter = function(self,selected,to_select)
		return PresentCardJudge(to_select)
		and not to_select:isEquipped()
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = yj_zhengyuCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		for i,c in sgs.list(player:getHandcards())do
			if PresentCardJudge(c)
			then return true end
		end
	end,
}
addToSkills(yj_zhengyu)

yj_on_trigger = sgs.CreateTriggerSkill{
	name = "yj_on_trigger",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.SlashMissed,sgs.EventPhaseProceeding,sgs.EventPhaseEnd,sgs.CardsMoveOneTime},
	priority = {4},
	global = true,
	can_trigger = function(self,target)
		if table.contains(sgs.Sanguosha:getBanPackages(),"yongjian")
		then else return target and target:isAlive() end
	end,
	on_trigger = function(self,event,player,data,room)
   		if event==sgs.CardsMoveOneTime
	   	then
	     	local move = data:toMoveOneTime()
			if move.to_place==sgs.Player_PlaceHand
			and player:objectName()==move.to:objectName()
			then
				local ids = {}
				for _,id in sgs.list(move.card_ids)do
					if player:handCards():contains(id)
					then
						if sgs.Sanguosha:getCard(id):isKindOf("YjPoison")
						and move.reason.m_skillName=="draw_phase"
						then table.insert(ids,id) end
						if player:getPhase()==sgs.Player_Play
						and PresentCardJudge(id) and not player:hasSkill("yj_zhengyu")
						then room:attachSkillToPlayer(player,"yj_zhengyu") end
					end
				end
				while #ids>0 do
					local c = room:askForUseCard(player,table.concat(ids,","),"yj_poison0:")
					if c then table.removeOne(ids,c:getEffectiveId()) else break end
				end
			elseif move.from_places:contains(sgs.Player_PlaceHand)
			and player:objectName()==move.from:objectName()
			then
				function visibleSpecial(id,i)
					if move.to_place==sgs.Player_PlaceSpecial
					then
						for _,p in sgs.list(move.to:getAliveSiblings())do
							if move.to:pileOpen(move.to:getPileName(id),p:objectName())
							then else return end
						end
						return true
					elseif move.to_place==sgs.Player_PlaceHand
					then return sgs.Sanguosha:getCard(id):hasFlag("visible")
					elseif move.to_place==sgs.Player_DrawPile
					then
						
					else
						return move.open:at(i)
					end
				end
				for i,id in sgs.list(move.card_ids)do
					if sgs.Sanguosha:getCard(id):isKindOf("YjPoison")
					and move.from_places:at(i)==sgs.Player_PlaceHand
					and player:isAlive() and visibleSpecial(id,i)
					and player:getMark("BanPoisonEffect")<1
					then
						Skill_msg("yj_poison",player)
						if tonumber(sgs.Sanguosha:getVersion())>=20221231
						then room:loseHp(player,1,false,nil,"yj_poison")
						else
							player:setFlags("YjPoison")
							room:loseHp(player)
							player:setFlags("-YjPoison")
						end
					end
				end
			end
		elseif event==sgs.EventPhaseProceeding
	   	then
	       	if player:getPhase()==sgs.Player_Play
			then
				for _,c in sgs.list(player:getHandcards())do
					if PresentCardJudge(c) and not player:hasSkill("yj_zhengyu")
					then room:attachSkillToPlayer(player,"yj_zhengyu") break end
				end
			end
		elseif event==sgs.SlashMissed
		then
			local effect = data:toSlashEffect()
			if effect.slash:objectName()=="yj_stabs_slash"
			and effect.to:getHandcardNum()>0
			and effect.jink
			then
				Skill_msg("yj_stabs_slash",effect.from)
				if room:askForDiscard(effect.to,"yj_stabs_slash",1,1,true,false,"yj_stabs_slash0:")
				then else room:slashResult(effect,nil) end
			end
    	elseif event==sgs.EventPhaseEnd
		then
	       	if player:hasSkill("yj_zhengyu")
			then
				room:detachSkillFromPlayer(player,"yj_zhengyu",true,true)
			end
		end
		return false
	end
}
addToSkills(yj_on_trigger)

sgs.LoadTranslationTable{
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
	["yj_slash"] = "杀",
	[":yj_slash"] = "基本牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：攻击范围内的一名其他角色<br /><b>效果</b>：对目标角色造成1点伤害。",
	["yj_jink"] = "闪",
	[":yj_jink"] = "基本牌<br /><b>时机</b>：【杀】对你生效时<br /><b>目标</b>：此【杀】<br /><b>效果</b>：抵消此【杀】的效果。",
	["yj_peach"] = "桃",
	[":yj_peach"] = "基本牌<br /><b>时机</b>：出牌阶段/一名角色处于濒死状态时<br /><b>目标</b>：已受伤的你/处于濒死状态的角色<br /><b>效果</b>：目标角色回复1点体力。",
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
	["yj_amazing_grace"] = "五谷丰登",
	[":yj_amazing_grace"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：所有角色<br /><b>效果</b>：你亮出牌堆顶等于目标数的牌，每名目标角色获得其中一张牌，然后将其余的牌置入弃牌堆。",
	["yj_duel"] = "决斗",
	[":yj_duel"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名其他角色<br /><b>效果</b>：由目标角色开始，你与其轮流：打出一张【杀】，否则受到对方的1点伤害并结束此牌结算。",
	["yj_snatch"] = "顺手牵羊",
	[":yj_snatch"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：距离1的一名区域内有牌的角色<br /><b>效果</b>：你获得目标角色区域内的一张牌。",
	["yj_nullification"] = "无懈可击",
	[":yj_nullification"] = "锦囊牌<br /><b>时机</b>：锦囊牌对目标角色生效前，或一张【无懈可击】生效前<br /><b>目标</b>：该锦囊牌<br /><b>效果</b>：抵消该锦囊牌对该角色产生的效果，或抵消另一张【无懈可击】产生的效果。",
	["debuff_card"] = "减益牌",--或奸细牌？
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




zhulu = sgs.Package("zhulu",sgs.Package_CardPack)

local zl_slash = yj_slash:clone(0,8)
zl_slash:setParent(zhulu)
local zl_slash = yj_slash:clone(0,9)
zl_slash:setParent(zhulu)
local zl_slash = yj_slash:clone(0,11)
zl_slash:setParent(zhulu)
local zl_slash = yj_slash:clone(1,11)
zl_slash:setParent(zhulu)
local zl_slash = yj_slash:clone(3,6)
zl_slash:setParent(zhulu)
local zl_slash = yj_slash:clone(3,11)
zl_slash:setParent(zhulu)

zl_fire_slash = sgs.CreateBasicCard{
	name = "fire_slash",
	class_name = "FireSlash",
	subtype = "attack_card",
    can_recast = false,
	damage_card = true,
    available = function(self,player)
    	for n,to in sgs.list(player:getAliveSiblings())do
			if self:cardIsAvailable(player)
			and CanToCard(self,player,to)
			then
				n = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue,player,self)
				if player:hasWeapon("vscrossbow")
				then
					n = n+3
					if self:isVirtualCard()
					and self:subcardsLength()>0
					then
						local w = player:getWeapon()
						if w and w:objectName()=="vscrossbow"
						and self:getSubcards():contains(w:getId())
						then n = n-3 end
					end
				end
				if player:hasWeapon("crossbow")
				then
					n = n+999
					if self:isVirtualCard()
					and self:subcardsLength()>0
					then
						local w = player:getWeapon()
						if w and w:objectName()=="crossbow"
						and self:getSubcards():contains(w:getId())
						then n = n-999 end
					end
				end
				if player:getSlashCount()<=n
				or player:canSlashWithoutCrossbow() then return true end
				n = player:property("extra_slash_specific_assignee"):toString():split("+")
				if table.contains(n,to:objectName()) then return true end
			end
		end
    end,
	filter = function(self,targets,to_select,source)
		local x = 0
		if self:isVirtualCard()
		and self:subcardsLength()>0
		then
			local w = source:getWeapon()
			if w and self:getSubcards():contains(w:getId())
			then x = x+source:getAttackRange()-source:getAttackRange(false) end
			local oh = source:getOffensiveHorse()
			if oh and self:getSubcards():contains(oh:getId())
			then x = x+1 end
		end
		return source:canSlash(to_select,self,true,x)
	   	and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)
	end,
	on_use = function(self,room,source,targets)
 		local effect = sgs.CardEffectStruct()
		effect.from = source
		effect.card = self
		effect.multiple = #targets>1
		local no_offset_list = room:getTag("CardUseNoOffsetList"):toStringList()
		local no_respond_list = room:getTag("CardUseNoRespondList"):toStringList()
		local nullified_list = room:getTag("CardUseNullifiedList"):toStringList()
		room:setTag("drank"..self:toString(),ToData(source:getMark("drank")))
        room:setPlayerMark(source,"drank",0)
		for _,to in sgs.list(targets)do
			effect.to = to
			effect.no_offset = table.contains(no_offset_list,"_ALL_TARGETS") or table.contains(no_offset_list,to:objectName())
			effect.no_respond = table.contains(no_respond_list,"_ALL_TARGETS") or table.contains(no_respond_list,to:objectName())
			effect.nullified = table.contains(nullified_list,"_ALL_TARGETS") or table.contains(nullified_list,to:objectName())
			room:cardEffect(effect)
        end
		room:removeTag("drank"..self:toString())
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		local se = sgs.SlashEffectStruct()
        se.from = effect.from
        se.nature = sgs.DamageStruct_Fire
        se.slash = effect.card
        se.to = effect.to
        se.drank = room:getTag("drank"..self:toString()):toInt()
        se.nullified = effect.nullified
        se.no_offset = effect.no_offset
        se.no_respond = effect.no_respond
        se.multiple = effect.multiple
		local jn = effect.from:getTag("Jink_"..effect.card:toString()):toIntList()
		if jn:isEmpty() then se.jink_num = 1
		else
			se.jink_num = jn:at(0)
			jn:removeOne(jn:at(0))
			effect.from:setTag("Jink_"..effect.card:toString(),ToData(jn))
		end
		room:slashEffect(se)
	end,
}
zl_fire_slash:clone(2,3):setParent(zhulu)
zl_thunder_slash = sgs.CreateBasicCard{
	name = "thunder_slash",
	class_name = "ThunderSlash",
	subtype = "attack_card",
    can_recast = false,
	damage_card = true,
    available = function(self,player)
    	for n,to in sgs.list(player:getAliveSiblings())do
			if self:cardIsAvailable(player)
			and CanToCard(self,player,to)
			then
				n = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue,player,self)
				if player:hasWeapon("vscrossbow")
				then
					n = n+3
					if self:isVirtualCard()
					and self:subcardsLength()>0
					then
						local w = player:getWeapon()
						if w and w:objectName()=="vscrossbow"
						and self:getSubcards():contains(w:getId())
						then n = n-3 end
					end
				end
				if player:hasWeapon("crossbow")
				then
					n = n+999
					if self:isVirtualCard()
					and self:subcardsLength()>0
					then
						local w = player:getWeapon()
						if w and w:objectName()=="crossbow"
						and self:getSubcards():contains(w:getId())
						then n = n-999 end
					end
				end
				if player:getSlashCount()<=n
				or player:canSlashWithoutCrossbow() then return true end
				n = player:property("extra_slash_specific_assignee"):toString():split("+")
				if table.contains(n,to:objectName()) then return true end
			end
		end
    end,
	filter = function(self,targets,to_select,source)
		local x = 0
		if self:isVirtualCard()
		and self:subcardsLength()>0
		then
			local w = source:getWeapon()
			if w and self:getSubcards():contains(w:getId())
			then x = x+source:getAttackRange()-source:getAttackRange(false) end
			local oh = source:getOffensiveHorse()
			if oh and self:getSubcards():contains(oh:getId())
			then x = x+1 end
		end
		return source:canSlash(to_select,self,true,x)
	   	and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)
	end,
	on_use = function(self,room,source,targets)
 		local effect = sgs.CardEffectStruct()
		effect.from = source
		effect.card = self
		effect.multiple = #targets>1
		local no_offset_list = room:getTag("CardUseNoOffsetList"):toStringList()
		local no_respond_list = room:getTag("CardUseNoRespondList"):toStringList()
		local nullified_list = room:getTag("CardUseNullifiedList"):toStringList()
		room:setTag("drank"..self:toString(),ToData(source:getMark("drank")))
        room:setPlayerMark(source,"drank",0)
		for _,to in sgs.list(targets)do
			effect.to = to
			effect.no_offset = table.contains(no_offset_list,"_ALL_TARGETS") or table.contains(no_offset_list,to:objectName())
			effect.no_respond = table.contains(no_respond_list,"_ALL_TARGETS") or table.contains(no_respond_list,to:objectName())
			effect.nullified = table.contains(nullified_list,"_ALL_TARGETS") or table.contains(nullified_list,to:objectName())
			room:cardEffect(effect)
        end
		room:removeTag("drank"..self:toString())
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		local se = sgs.SlashEffectStruct()
        se.from = effect.from
        se.nature = sgs.DamageStruct_Thunder
        se.slash = effect.card
        se.to = effect.to
        se.drank = room:getTag("drank"..self:toString()):toInt()
        se.nullified = effect.nullified
        se.no_offset = effect.no_offset
        se.no_respond = effect.no_respond
        se.multiple = effect.multiple
		local jn = effect.from:getTag("Jink_"..effect.card:toString()):toIntList()
		if jn:isEmpty() then se.jink_num = 1
		else
			se.jink_num = jn:at(0)
			jn:removeOne(jn:at(0))
			effect.from:setTag("Jink_"..effect.card:toString(),ToData(jn))
		end
		room:slashEffect(se)
	end,
}
local zl_slash = zl_thunder_slash:clone(0,4)
zl_slash:setParent(zhulu)
local zl_slash = zl_thunder_slash:clone(1,4)
zl_slash:setParent(zhulu)

local zl_jink = yj_jink:clone(2,4)
zl_jink:setParent(zhulu)
local zl_jink = yj_jink:clone(2,8)
zl_jink:setParent(zhulu)
local zl_jink = yj_jink:clone(3,4)
zl_jink:setParent(zhulu)
local zl_jink = yj_jink:clone(3,4)
zl_jink:setParent(zhulu)
local zl_peach = yj_peach:clone(2,6)
zl_peach:setParent(zhulu)

zl_analeptic = sgs.CreateBasicCard{
	name = "analeptic",
	class_name = "Analeptic",
	subtype = "buff_card",
    can_recast = false,
	target_fixed = true,
--	damage_card = true,
    available = function(self,player)
		return player:usedTimes(self:getClassName())<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue,player,self)
		and self:cardIsAvailable(player)
    end,
	about_to_use = function(self,room,use)
		if use.to:isEmpty() then use.to:append(use.from) end
		self:cardOnUse(room,use)
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		room:setEmotion(effect.to,"analeptic")
		if effect.to:hasFlag("Global_Dying") and sgs.Sanguosha:getCurrentCardUseReason()~=sgs.CardUseStruct_CARD_USE_REASON_PLAY
		then room:recover(effect.to,sgs.RecoverStruct(effect.from,self))
		else room:addPlayerMark(effect.to,"drank") end
	end
}
local zlanaleptic = zl_analeptic:clone(1,6)
zlanaleptic:setParent(zhulu)
local zlanaleptic = zl_analeptic:clone(1,8)
zlanaleptic:setParent(zhulu)

zl_caochuanjiejian = sgs.CreateTrickCard{
	name = "zl_caochuanjiejian",
	class_name = "ZlCaochuanjiejian",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = true,
	can_recast = false,
	is_cancelable = true,
    available = function(self,player)
    	return false
    end,
	on_use = function(self,room,source,targets)
		local ce = source:getTag("ZlCaochuanjiejian"):toCardEffect()
		if ce and ce.from
		then
			if #targets>0 or table.contains(targets,ce.from)
			then else table.insert(targets,ce.from) end
			local effect = sgs.CardEffectStruct()
			effect.from = source
			effect.card = self
			local no_offset_list = room:getTag("CardUseNoOffsetList"):toStringList()
			local no_respond_list = room:getTag("CardUseNoRespondList"):toStringList()
			local nullified_list = room:getTag("CardUseNullifiedList"):toStringList()
			source:removeTag("ZlJiejian"..ce.card:toString())
			for _,to in sgs.list(targets)do
				effect.to = to
				effect.no_offset = table.contains(no_offset_list,"_ALL_TARGETS") or table.contains(no_offset_list,to:objectName())
				effect.no_respond = table.contains(no_respond_list,"_ALL_TARGETS") or table.contains(no_respond_list,to:objectName())
				effect.nullified = table.contains(nullified_list,"_ALL_TARGETS") or table.contains(nullified_list,to:objectName())
				if effect.nullified then room:setEmotion(to,"skill_nullify")
				elseif room:isCanceled(effect) then 
				else
					room:setEmotion(source,"revive")
					room:setEmotion(source,"blsemotion")
					source:setTag("ZlJiejian"..ce.card:toString(),ToData(true))
				end
			end
		end
		source:removeTag("ZlCaochuanjiejian")
	end,
}
zl_caochuanjiejian:clone(0,3):setParent(zhulu)
zl_caochuanjiejian:clone(0,6):setParent(zhulu)

zl_jiejiaguitian = sgs.CreateTrickCard{
	name = "zl_jiejiaguitian",
	class_name = "ZlJiejiaguitian",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
--	damage_card = true,
    available = function(self,player)
    	local tos = player:getAliveSiblings()
		tos:append(player)
		for _,to in sgs.list(tos)do
			if CanToCard(self,player,to)
			then
				return self:cardIsAvailable(player)
			end
		end
    end,
	filter = function(self,targets,to_select,source)
	    return to_select:hasEquip()
		and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		local dc = dummyCard()
		dc:addSubcards(effect.to:getEquips())
		if dc:subcardsLength()>0
		then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECYCLE,effect.from:objectName(),effect.to:objectName(),"zl_jiejiaguitian","")
			room:obtainCard(effect.to,dc,reason,false)
		end
		return false
	end,
}
zl_jiejiaguitian:clone(1,3):setParent(zhulu)
zl_jiejiaguitian:clone(3,3):setParent(zhulu)

zl_zhulutianxia = sgs.CreateTrickCard{
	name = "zl_zhulutianxia",
	class_name = "ZlZhulutianxia",
    can_recast = false,
	target_fixed = true,
	subclass = sgs.LuaTrickCard_TypeGlobalEffect,
	on_use = function(self,room,source,targets)
    	local ids = sgs.IntList()
		for _,id in sgs.list(room:getDrawPile())do
			if ids:length()>=#targets then break end
			if sgs.Sanguosha:getCard(id):isKindOf("EquipCard")
			then ids:append(id) end
		end
		for _,id in sgs.list(room:getDiscardPile())do
			if ids:length()>=#targets then break end
			if sgs.Sanguosha:getCard(id):isKindOf("EquipCard")
			then ids:append(id) end
		end
		room:setTag("ZlZhulutianxiaIds",ToData(ids))
		local effect = sgs.CardEffectStruct()
		effect.from = source
		effect.card = self
		effect.multiple = #targets>1
		local no_offset_list = room:getTag("CardUseNoOffsetList"):toStringList()
		local no_respond_list = room:getTag("CardUseNoRespondList"):toStringList()
		local nullified_list = room:getTag("CardUseNullifiedList"):toStringList()
		for _,to in sgs.list(targets)do
			local abled_ids,canids = sgs.IntList(),sgs.IntList()
			local toids = room:getTag("ZlZhulutianxiaIds"):toIntList()
			for c,id in sgs.list(ids)do
				c = sgs.Sanguosha:getCard(id)
				c = c:getRealCard():toEquipCard():location()
				if to:hasEquipArea(c) and toids:contains(id)
				then canids:append(id) else abled_ids:append(id) end
			end
			effect.to = to
			room:fillAG(ids,nil,abled_ids)
			room:setTag("ZlZhulutianxia",ToData(canids))
			effect.no_offset = table.contains(no_offset_list,"_ALL_TARGETS") or table.contains(no_offset_list,to:objectName())
			effect.no_respond = table.contains(no_respond_list,"_ALL_TARGETS") or table.contains(no_respond_list,to:objectName())
			effect.nullified = table.contains(nullified_list,"_ALL_TARGETS") or table.contains(nullified_list,to:objectName())
			if canids:length()>0 then room:cardEffect(effect) else room:setEmotion(to,"skill_nullify") end
			room:clearAG()
        end
		ids = room:getTag("ZlZhulutianxiaIds"):toIntList()
       	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER,nil,nil,self:objectName(),nil)
		if ids:isEmpty() then return end
       	effect = dummyCard()
	    effect:addSubcards(ids)
    	room:throwCard(effect,reason,nil)--弃牌
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		local ids = room:getTag("ZlZhulutianxiaIds"):toIntList()
		local ag_list = room:getTag("ZlZhulutianxia"):toIntList()
        local card_id = room:askForAG(effect.to,ag_list,false,self:objectName(),"zl_zhulutianxiaAG")
        room:takeAG(effect.to,card_id,false)
        ids:removeOne(card_id)
		room:setTag("ZlZhulutianxiaIds",ToData(ids))
       	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER,effect.to:objectName(),nil,self:objectName(),nil)
		if InstallEquip(card_id,effect.to,self) then else room:throwCard(card_id,reason,nil) end
	end,
}
zl_zhulutianxia:clone(1,9):setParent(zhulu)

local zl_kh = yj_shushangkaihua:clone(2,9)
zl_kh:setParent(zhulu)
local zl_kh = yj_shushangkaihua:clone(2,11)
zl_kh:setParent(zhulu)
local zl_kh = yj_shushangkaihua:clone(3,9)
zl_kh:setParent(zhulu)

zl_wufengjianTr = sgs.CreateTriggerSkill{
	name = "zl_wufengjian",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	can_trigger = function(self,target)
		return target and target:hasWeapon("zl_wufengjian")
	end,
	on_trigger = function(self,event,player,data,room)
   		if event==sgs.CardUsed
		then
	       	local use = data:toCardUse()
        	if use.card:isKindOf("Slash")
        	then
	         	room:setEmotion(player,"weapon/zl_wufengjian")
                room:sendCompulsoryTriggerLog(player,"zl_wufengjian",true)
				local w = player:getWeapon()
				w = w and w:objectName()=="zl_wufengjian" and w:getEffectiveId() or "."
				if w~="." and player:getCardCount()<2 or player:getCardCount()<1 then return end
				room:askForDiscard(player,"zl_wufengjian",1,1,false,true,"zl_wufengjian0:","^"..w)
			end
		end
		return false
	end
}
zl_wufengjian = sgs.CreateWeapon{
	name = "zl_wufengjian",
	class_name = "ZlWufengjian",
	range = 1,
	on_install = function(self,player)
		player:getRoom():acquireSkill(player,zl_wufengjianTr,false,true,false)
	end,
	on_uninstall = function(self,player)
		player:getRoom():detachSkillFromPlayer(player,"zl_wufengjian",true,true)
	end,
}
local zlwufengjian = zl_wufengjian:clone(0,5)
zlwufengjian:setProperty("YingBianEffects",ToData("present_card"))
zlwufengjian:setParent(zhulu)

zl_yexingyiTr = sgs.CreateTriggerSkill{
	name = "zl_yexingyi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardEffected},
	can_trigger = function(self,target)
		return target and target:hasArmorEffect("zl_yexingyi")
		and ArmorNotNullified(target)
	end,
	on_trigger = function(self,event,player,data,room)
    	if event==sgs.CardEffected
		then
    		local effect = data:toCardEffect()
			if effect.card:isKindOf("TrickCard")
			and effect.card:isBlack()
			then
                room:sendCompulsoryTriggerLog(player,"zl_yexingyi",true)
	         	room:setEmotion(player,"armor/zl_yexingyi")
				effect.nullified = true
				data:setValue(effect)
			end
		end
		return false
	end
}
zl_yexingyi = sgs.CreateArmor{
	name = "zl_yexingyi",
	class_name = "ZlYexingyi",
	on_install = function(self,player)
		local room = player:getRoom()
		room:acquireSkill(player,zl_yexingyiTr,false,true,false)
		return false
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player,"zl_yexingyi",true,true)
		return false
	end,
}
zl_yexingyi:clone(0,10):setParent(zhulu)

local zlzheji = yj_zheji:clone(1,5)
zlzheji:setProperty("YingBianEffects",ToData("present_card"))
zlzheji:setParent(zhulu)

zl_jinheCard = sgs.CreateSkillCard{
	name = "zl_jinheCard",
	will_throw = false,
	target_fixed = true,
	on_use = function(self,room,source,targets)
		local dc = dummyCard()
       	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW,source:objectName(),nil,"zl_jinhe",nil)
		room:throwCard(self,reason,nil)
		for s,id in sgs.list(self:getSubcards())do
			s = sgs.Sanguosha:getCard(id):getSuit()
			for _,h in sgs.list(source:getHandcards())do
				if dc:getSubcards():contains(h:getEffectiveId()) then continue end
				if s==h:getSuit() then dc:addSubcard(h) end
			end
		end
		local t = source:getTreasure()
		if t and t:isKindOf("ZlJinhe") then dc:addSubcard(t) end
		if dc:subcardsLength()<1 then return end
		room:throwCard(dc,reason,source)
	end
}
zl_jinheTr = sgs.CreateViewAsSkill{
	name = "zl_jinhe",
	view_as = function(self)
		local c = zl_jinheCard:clone()
	   	for _,id in sgs.list(sgs.Self:getPile("zl_li"))do
	    	c:addSubcard(id)
	   	end
		return c
	end,
	enabled_at_play = function(self,player)
	   	return player:getPile("zl_li"):length()>0
	end,
}
zl_jinhe = sgs.CreateTreasure{
	name = "zl_jinhe",
	class_name = "ZlJinhe",
	target_fixed = false,
	on_install = function(self,player)
		local room = player:getRoom()
		room:attachSkillToPlayer(player,"zl_jinhe")
		local from = player:getTag("PresentFrom"):toPlayer()
		if player:getTag("PresentCard"):toString()==self:toString()
		and from and from:isAlive()
		then
			Skill_msg(self,from)
			room:setEmotion(from,"treasure/zl_jinhe")
			local ids = room:getNCards(2,false)
			room:returnToTopDrawPile(ids)
			room:fillAG(ids,from)
			local id = room:askForAG(from,ids,false,"zl_jinhe","zl_jinhe0")
			room:clearAG(from)
			ids = sgs.SPlayerList()
			ids:append(from)
			player:addToPile("zl_li",id,false,ids)
			room:setTag("ZlJinheOwner",ToData(from))
		end
	end,
	on_uninstall = function(self,player)
		player:getRoom():detachSkillFromPlayer(player,"zl_jinhe",true,true)
	end,
}
addToSkills(zl_jinheTr)
local zljinhe = zl_jinhe:clone(1,10)
zljinhe:setProperty("YingBianEffects",ToData("present_card"))
zljinhe:setParent(zhulu)

local zl_numa = sgs.Sanguosha:cloneCard("OffensiveHorse",2,5)
zl_numa:setProperty("YingBianEffects",ToData("present_card"))
zl_numa:setObjectName("zl_numa")
zl_numa:setParent(zhulu)
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
}

zl_nvzhuang = sgs.CreateArmor{
	name = "zl_nvzhuang",
	class_name = "ZlNvzhuang",
	on_install = function(self,player)
		if player:isMale()
		then
			local room = player:getRoom()
			room:setEmotion(player,"armor/zl_nvzhuang")
			room:sendCompulsoryTriggerLog(player,"zl_nvzhuang",true)
			if player:hasEquip(self) and player:getCardCount()<2
			or player:getCardCount()<1 then return end
			room:askForDiscard(player,"zl_nvzhuang",1,1,false,true,"zl_nvzhuang0:","^"..self:getEffectiveId())
		end
	end,
	on_uninstall = function(self,player)
		if player:isMale()
		then
			local room = player:getRoom()
			room:setEmotion(player,"armor/zl_nvzhuang")
			room:sendCompulsoryTriggerLog(player,"zl_nvzhuang",true)
			if player:hasEquip(self) and player:getCardCount()<2
			or player:getCardCount()<1 then return end
			room:askForDiscard(player,"zl_nvzhuang",1,1,false,true,"zl_nvzhuang0:","^"..self:getEffectiveId())
		end
	end,
}
local zlnvzhuang = zl_nvzhuang:clone(2,10)
zlnvzhuang:setProperty("YingBianEffects",ToData("present_card"))
zlnvzhuang:setParent(zhulu)

zl_yajiaoqiangTr = sgs.CreateTriggerSkill{
	name = "zl_yajiaoqiang",
	events = {sgs.CardUsed,sgs.CardFinished},
	can_trigger = function(self,target)
		return target and target:hasWeapon("zl_yajiaoqiang")
		and target:getPhase()==sgs.Player_NotActive
	end,
	on_trigger = function(self,event,player,data,room)
    	local use = data:toCardUse()
   		if event==sgs.CardUsed
		then
        	if use.card:getTypeId()>0 and use.card:isBlack()
			and player:getMark("zl_yajiaoqiang-Clear")<1
        	then
                player:setTag("ZlYajiaoqiang",ToData(use.card:toString()))
				player:addMark("zl_yajiaoqiang-Clear")
			end
		elseif player:getTag("ZlYajiaoqiang"):toString()==use.card:toString()
		then
			player:removeTag("ZlYajiaoqiang")
			if not room:getCardOwner(use.card:getEffectiveId())
			and ToSkillInvoke(self,player)
			then
				room:obtainCard(player,use.card)
			end
		end
		return false
	end
}
zl_yajiaoqiang = sgs.CreateWeapon{
	name = "zl_yajiaoqiang",
	class_name = "ZlYajiaoqiang",
	range = 3,
	on_install = function(self,player)
		player:getRoom():acquireSkill(player,zl_yajiaoqiangTr,false,true,false)
	end,
	on_uninstall = function(self,player)
		player:getRoom():detachSkillFromPlayer(player,"zl_yajiaoqiang",true,true)
	end,
}
zl_yajiaoqiang:clone(3,5)

zl_yinfengjiaTr = sgs.CreateTriggerSkill{
	name = "zl_yinfengjia",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	can_trigger = function(self,target)
		return target and target:hasArmorEffect("zl_yinfengjia")
		and ArmorNotNullified(target)
	end,
	on_trigger = function(self,event,player,data,room)
    	if event==sgs.DamageInflicted
		then
 		    local damage = data:toDamage()
            if damage.card and damage.card:isKindOf("TrickCard")
			then
                room:sendCompulsoryTriggerLog(player,"zl_yinfengjia",true)
	         	room:setEmotion(player,"armor/zl_yinfengjia")
				return DamageRevises(data,1,player)
			end
		end
		return false
	end
}
zl_yinfengjia = sgs.CreateArmor{
	name = "zl_yinfengjia",
	class_name = "ZlYinfengjia",
	on_install = function(self,player)
		player:getRoom():acquireSkill(player,zl_yinfengjiaTr,false,true,false)
	end,
	on_uninstall = function(self,player)
		player:getRoom():detachSkillFromPlayer(player,"zl_yinfengjia",true,true)
	end,
}
local zlyinfengyi = zl_yinfengjia:clone(3,10)
zlyinfengyi:setProperty("YingBianEffects",ToData("present_card"))
zlyinfengyi:setParent(zhulu)




zlCardOnTrigger = sgs.CreateTriggerSkill{
	name = "zlCardOnTrigger",
	events = {sgs.CardsMoveOneTime,sgs.CardEffected,sgs.EventPhaseEnd,sgs.EventPhaseProceeding,sgs.CardFinished},
	frequency = sgs.Skill_Compulsory,
	global = true,
	can_trigger = function(self,target)
		if table.contains(sgs.Sanguosha:getBanPackages(),"zhulu")
		then else return target and target:isAlive() end
	end,
	on_trigger = function(self,event,player,data,room)
 		if event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			if move.to_place==sgs.Player_PlaceHand
			and player:objectName()==move.to:objectName()
			and player:getPhase()==sgs.Player_Play
			then
				for _,id in sgs.list(move.card_ids)do
					if not player:hasSkill("yj_zhengyu")
					and player:handCards():contains(id) and PresentCardJudge(id)
					then room:attachSkillToPlayer(player,"yj_zhengyu") end
				end
			end
			if move.from_places:contains(sgs.Player_PlaceEquip)
			and player:objectName()==move.from:objectName()
			then
				for i,id in sgs.list(move.card_ids)do
					if sgs.Sanguosha:getCard(id):isKindOf("ZlJinhe")
					and move.from_places:at(i)==sgs.Player_PlaceEquip
					then
						if player:getPile("zl_li"):length()>0
						then
							if move.to_place==sgs.Player_PlaceEquip
							then
								local sp = sgs.SPlayerList()
								sp:append(room:getTag("ZlJinheOwner"):toPlayer())
								BeMan(room,move.to):addToPile("zl_li",player:getPile("zl_li"),false,sp)
							else player:clearOnePrivatePile("zl_li") end
						end
						if move.to_place==sgs.Player_DiscardPile
						and move.reason.m_skillName~="zl_jinhe"
						then
							Skill_msg("zl_jinhe",player)
							player:throwAllHandCards()
						end
					end
				end
			end
		elseif event==sgs.CardEffected
		then
    		local effect = data:toCardEffect()
			if effect.card:isKindOf("Slash")
			or effect.card:isNDTrick() and effect.card:isDamageCard()
			then
	         	if effect.no_offset
				then return end
				local can = {}
				local hc = hasCard(effect.to,"ZlCaochuanjiejian","&h")
				if hc
				then
					for _,c in sgs.list(hc)do
						table.insert(can,c:getEffectiveId())
					end
				end
                for _,skill in sgs.list(effect.to:getSkillList(true,false))do
	                if skill:inherits("ViewAsSkill")
		        	then
		            	skill = sgs.Sanguosha:getViewAsSkill(skill:objectName())
		            	if skill:isEnabledAtResponse(effect.to,"zl_caochuanjiejian")
	                 	then table.insert(can,"ZlCaochuanjiejian") end
		        	end
	        	end
       	        if #can>0
		        then
                    effect.to:setTag("ZlCaochuanjiejian",data)
				   	hc = "zl_caochuanjiejian_use:"..effect.card:objectName()..":"..effect.from:objectName()
				  	if room:askForUseCard(effect.to,table.concat(can,","),hc,-1,sgs.Card_MethodUse,true,effect.from,effect.card)
					and effect.to:getTag("ZlJiejian"..effect.card:toString()):toBool()
					then effect.to:setFlags("Global_NonSkillNullify") return true end
		        end
            end
		elseif event==sgs.CardFinished
	   	then
	       	local use = data:toCardUse()
	       	if use.card:getTypeId()>0
	       	then
				for _,to in sgs.list(use.to)do
					if to:getTag("ZlJiejian"..use.card:toString()):toBool()
					then
						to:removeTag("ZlJiejian"..use.card:toString())
						if to:isDead() or room:getCardOwner(use.card:getEffectiveId()) then continue end
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION,to:objectName(),use.from:objectName(),"zl_caochuanjiejian","")
						room:obtainCard(to,use.card,reason)
					end
				end
			end
		elseif event==sgs.EventPhaseProceeding
	   	then
	       	if player:getPhase()==sgs.Player_Play
			then
				for _,c in sgs.list(player:getHandcards())do
					if PresentCardJudge(c) and not player:hasSkill("yj_zhengyu")
					then room:attachSkillToPlayer(player,"yj_zhengyu") break end
				end
			end
    	elseif event==sgs.EventPhaseEnd
		then
	       	if player:hasSkill("yj_zhengyu")
			then
				room:detachSkillFromPlayer(player,"yj_zhengyu",true,true)
			end
		end
		return false
	end,
}
addToSkills(zlCardOnTrigger)




sgs.LoadTranslationTable{
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
	[":zl_nvzhuang"] = "装备牌·防具<br /><b>防具技能</b>：锁定技，当你装备或卸载【女装】时，你须弃置一张其他牌",
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





return {yongjian,zhulu}