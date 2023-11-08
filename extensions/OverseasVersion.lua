extension = sgs.Package("OverseasVersion")

ov_gexuan = sgs.General(extension,"ov_gexuan","qun",3)
ov_danfa = sgs.CreateTriggerSkill{
	name = "ov_danfa",
--	view_as_skill = ov_danfavs,
	events = {sgs.EventPhaseProceeding,sgs.CardUsed,sgs.CardResponded},
	on_trigger = function(self,event,player,data,room)
        if event==sgs.EventPhaseProceeding
		and player:getCardCount()>0
		then
			if player:getPhase()==sgs.Player_Start
			or player:getPhase()==sgs.Player_Finish
			then
		        local c = room:askForCard(player,"..","ov_danfa0:",data,sgs.Card_MethodNone)
				if not c then return end
				NotifySkillInvoked(self,player)
				player:addToPile("ov_dan",c)
			end
	   	elseif player:getPile("ov_dan"):length()>0
	    then
			local card
			if event==sgs.CardResponded
			then
				if data:toCardResponse().m_isUse
				then
					card = data:toCardResponse().m_card
				end
			else card = data:toCardUse().card end
			if not card or card:getTypeId()==0 then return end
			for c,id in sgs.list(player:getPile("ov_dan"))do
				c = sgs.Sanguosha:getCard(id)
				if player:getMark(c:getSuit().."ov_danfa-Clear")>0
				or card:getSuit()~=c:getSuit()
				then continue end
				player:addMark(c:getSuit().."ov_danfa-Clear")
				MarkRevises(player,"&ov_danfa-Clear",card:getSuitString().."_char")
				Skill_msg(self,player,math.random(1,2))
				player:drawCards(1,"ov_danfa")
			end
		end
		return false
	end,
}
ov_gexuan:addSkill(ov_danfa)
ov_lingbaoCard = sgs.CreateSkillCard{
	name = "ov_lingbaoCard",
	handling_method = sgs.Card_MethodDiscard,
	filter = function(self,targets,to_select,from)
		local r,b = 0,0
		for c,id in sgs.list(self:getSubcards())do
			c = sgs.Sanguosha:getCard(id)
			if c:isRed() then r = r+1 end
			if c:isBlack() then b = b+1 end
		end
		if r==b then return #targets<2
		else return #targets<1 end
	end,
	feasible = function(self,targets)
		local r,b = 0,0
		for c,id in sgs.list(self:getSubcards())do
			c = sgs.Sanguosha:getCard(id)
			if c:isRed() then r = r+1 end
			if c:isBlack() then b = b+1 end
		end
		if r==b then return #targets>1
		else return #targets>0 end
	end,
	about_to_use = function(self,room,use)
		self:cardOnUse(room,use)
		local r,b = 0,0
		for c,id in sgs.list(self:getSubcards())do
			c = sgs.Sanguosha:getCard(id)
			if c:isRed() then r = r+1 end
			if c:isBlack() then b = b+1 end
		end
		if use.to:length()>1
		then
			use.to:at(0):drawCards(1,"ov_lingbao")
			room:askForDiscard(use.to:at(1),"ov_lingbao",1,1,false,true)
		elseif r>1
		then
			room:recover(use.to:at(0),sgs.RecoverStruct(use.from,self))
		else
			r = "hej"
			b = sgs.IntList()
			for i=1,2 do
				if use.to:at(0):getCards("hej"):length()<=b:length() then break end
				use.from:setTag("askForCardChosen_ForAI",ToData(b))
				local id = room:askForCardChosen(use.from,use.to:at(0),r,"ov_lingbao",false,sgs.Card_MethodDiscard,b,b:length()>0)
				use.from:removeTag("askForCardChosen_ForAI")
				if id<0 then break end
				local cp = room:getCardPlace(id)
				if cp==sgs.Player_PlaceHand
				then r="ej" end
				room:throwCard(id,use.to:at(0),use.from)
				for ic,c in sgs.list(use.to:at(0):getCards("hej"))do
					ic = c:getEffectiveId()
					if room:getCardPlace(ic)~=cp
					then continue end
					b:append(ic)
				end
			end
		end
	end
}
ov_lingbao = sgs.CreateViewAsSkill{
	name = "ov_lingbao",
	n = 2,
	expand_pile = "ov_dan",
	view_filter = function(self,selected,to_select)
	   	for _,c in sgs.list(selected)do
	    	if c:getSuit()==to_select:getSuit()
			then return end
	   	end
		return sgs.Self:getPile("ov_dan"):contains(to_select:getEffectiveId())
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_lingbaoCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>1 and c
	end,
	enabled_at_play = function(self,player)
		return player:getPile("ov_dan"):length()>1
		and player:usedTimes("#ov_lingbaoCard")<1
	end,
}
ov_gexuan:addSkill(ov_lingbao)
ov_sidao = sgs.CreateTriggerSkill{
	name = "ov_sidao",
--	view_as_skill = ov_sidaovs,
	waked_skills = "_ov_lingbaoxianhu|_ov_taijifuchen|_ov_chongyingshenfu",
	events = {sgs.EventPhaseProceeding,sgs.GameStart},
	on_trigger = function(self,event,player,data,room)
        if event==sgs.EventPhaseProceeding
		then
			if player:getPhase()==sgs.Player_Start
			then
				local id = player:getTag("ov_sidao"):toInt()
				if id<1 or room:getCardOwner(id) then return end
				Skill_msg(self,player,math.random(1,2))
				local c = sgs.Sanguosha:getCard(id)
				player:obtainCard(c)
				if room:getCardOwner(id):objectName()~=player:objectName()
				or room:getCardPlace(id)~=sgs.Player_PlaceHand
				then return end
				if player:canUse(c)
				then
					room:useCard(sgs.CardUseStruct(c,player,player))
				end
			end
	   	elseif event==sgs.GameStart
	    then
	    	local ids = sgs.IntList()
			local c = PatternsCard("_ov_lingbaoxianhu",nil,true)
			if c then ids:append(c:getEffectiveId()) end
			c = PatternsCard("_ov_taijifuchen",nil,true)
			if c then ids:append(c:getEffectiveId()) end
			c = PatternsCard("_ov_chongyingshenfu",nil,true)
			if c then ids:append(c:getEffectiveId()) end
			if ids:length()<1 then return end
			Skill_msg(self,player,math.random(1,2))
			room:fillAG(ids,player)
			c = sgs.IntList()
			for ic,id in sgs.list(ids)do
				ic = sgs.Sanguosha:getCard(id)
				local e = ic:getRealCard():toEquipCard():location()
				if player:hasEquipArea(e) then c:append(id) end
			end
			local id = room:askForAG(player,c,c:isEmpty(),self:objectName())
			room:clearAG(player)
			if id==-1 then return end
			player:setTag("ov_sidao",sgs.QVariant(id))
			InstallEquip(id,player,"ov_sidao")
		end
		return false
	end,
}
ov_gexuan:addSkill(ov_sidao)
ov_lingbaoxianhuTr = sgs.CreateTriggerSkill{
	name = "_ov_lingbaoxianhu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Death,sgs.DamageCaused},
	can_trigger = function(self,target)
		return target and target:hasWeapon("_ov_lingbaoxianhu")
	end,
	on_trigger = function(self,event,player,data,room)
   		if event==sgs.Death
	   	then
			local death = data:toDeath()
			if death.who==player then return end
    	elseif event==sgs.DamageCaused
		then
		    local damage = data:toDamage()
        	if damage.damage<2 then return end
		end
       	room:sendCompulsoryTriggerLog(player,"_ov_lingbaoxianhu")
    	room:setEmotion(player,"weapon/_ov_lingbaoxianhu")
		room:gainMaxHp(player)
		room:recover(player,sgs.RecoverStruct(player,player:getWeapon()))
		return false
	end
}
ov_lingbaoxianhu = sgs.CreateWeapon{
	name = "_ov_lingbaoxianhu",
	class_name = "OvLingbaoxianhu",
	range = 3,
	on_install = function(self,player)
		local room = player:getRoom()
		room:acquireSkill(player,ov_lingbaoxianhuTr,false,true,false)
		return false
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player,"_ov_lingbaoxianhu",true,true)
		return false
	end,
}
ov_lingbaoxianhu:clone(2,1):setParent(extension)
ov_taijifuchenTr = sgs.CreateTriggerSkill{
	name = "_ov_taijifuchen",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	can_trigger = function(self,target)
		return target and target:hasWeapon("_ov_taijifuchen")
	end,
	on_trigger = function(self,event,player,data,room)
   		if event==sgs.CardUsed
	   	then
	    	local use = data:toCardUse()
			if not use.card:isKindOf("Slash")
			then return end
			local can = nil
			for i,to in sgs.list(use.to)do
				if to:objectName()~=player:objectName()
				then can = true end
			end
			if not can then return end
			room:sendCompulsoryTriggerLog(player,"_ov_taijifuchen")
			room:setEmotion(player,"weapon/_ov_taijifuchen")
			can = use.no_respond_list
			for c,to in sgs.list(use.to)do
				if to:objectName()~=player:objectName()
				then
					c = room:askForDiscard(to,"_ov_taijifuchen",1,1,true,true,"_ov_taijifuchen0:")
					if c
					then
						if c:getSuit()==use.card:getSuit()
						then player:obtainCard(c) end
					else
						table.insert(can,to:objectName())
					end
				end
			end
			use.no_respond_list = can
			data:setValue(use)
		end
		return false
	end
}
ov_taijifuchen = sgs.CreateWeapon{
	name = "_ov_taijifuchen",
	class_name = "OvTaijifuchen",
	range = 5,
	on_install = function(self,player)
		local room = player:getRoom()
		room:acquireSkill(player,ov_taijifuchenTr,false,true,false)
		return false
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player,"_ov_taijifuchen",true,true)
		return false
	end,
}
ov_taijifuchen:clone(2,1):setParent(extension)
ov_chongyingshenfuTr = sgs.CreateTriggerSkill{
	name = "_ov_chongyingshenfu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged,sgs.DamageForseen},
	can_trigger = function(self,target)
		return target and target:hasArmorEffect("_ov_chongyingshenfu")
	end,
	on_trigger = function(self,event,player,data,room)
    	if event==sgs.Damaged
		then
		    local damage = data:toDamage()
            if damage.card and damage.card:getTypeId()>0
			then
	         	room:setEmotion(player,"armor/_ov_chongyingshenfu")
                room:sendCompulsoryTriggerLog(player,"_ov_chongyingshenfu")
    	        player:addMark("_ov_chongyingshenfu"..damage.card:objectName())
			end
		elseif event==sgs.DamageForseen
		then
		    local damage = data:toDamage()
            if damage.card and damage.card:getTypeId()>0
			then
                local n = player:getMark("_ov_chongyingshenfu"..damage.card:objectName())
				if n<1 then return end
				room:sendCompulsoryTriggerLog(player,"_ov_chongyingshenfu")
	         	room:setEmotion(player,"armor/_ov_chongyingshenfu")
    	        return DamageRevises(data,-n,player)
			end
		end
		return false
	end
}
ov_chongyingshenfu = sgs.CreateArmor{
	name = "_ov_chongyingshenfu",
	class_name = "OvChongyingshenfu",
	on_install = function(self,player)
		local room = player:getRoom()
		room:acquireSkill(player,ov_chongyingshenfuTr,false,true,false)
		return false
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player,"_ov_chongyingshenfu",true,true)
		return false
	end,
}
ov_chongyingshenfu:clone(2,1):setParent(extension)

ov_dongzhao = sgs.General(extension,"ov_dongzhao","wei",3)
ov_miaolve = sgs.CreateTriggerSkill{
	name = "ov_miaolve",
--	view_as_skill = ov_miaolve,
	waked_skills = "_ov_mantianguohai",
	events = {sgs.Damaged,sgs.GameStart},
	on_trigger = function(self,event,player,data,room)
        if event==sgs.Damaged
		then
			local damage = data:toDamage()
			for i=1,damage.damage do
				local cs = PatternsCard("_ov_mantianguohai",true,true)
				local dc = dummyCard()
				for _,c in sgs.list(cs)do
					if room:getCardOwner(c:getEffectiveId())
					or dc:subcardsLength()>0
					then continue end
					dc:addSubcard(c)
				end
				i = {}
				if dc:subcardsLength()>0 then table.insert(i,"obtainMantianguohai") end
				cs = sgs.ZhinangClassName
				cs = PatternsCard(cs,true,true)
				if #cs>0 then table.insert(i,"obtainZhinang") end
				if #i<1 or not player:askForSkillInvoke(self:objectName(),data)
				then break end
				room:broadcastSkillInvoke(self:objectName())
				i = room:askForChoice(player,"ov_miaolve",table.concat(i,"+"))
				if i=="obtainMantianguohai"
				then
					player:obtainCard(dc)
					player:drawCards(1,"ov_miaolve")
				elseif #cs>0
				then
					for _,c in sgs.list(cs)do
						if room:getCardPlace(c:getEffectiveId())==sgs.Player_PlaceTable
						or room:getCardOwner(c:getEffectiveId())
						then continue end
						player:obtainCard(c)
						break
					end
				end
			end
	   	elseif event==sgs.GameStart
	    then
			local cs = PatternsCard("_ov_mantianguohai",true,true)
			if #cs<2 then return end
	    	local c = dummyCard()
			c:addSubcard(cs[1])
			c:addSubcard(cs[2])
			Skill_msg(self,player,math.random(1,2))
			player:obtainCard(c)
		end
		return false
	end,
}
ov_dongzhao:addSkill(ov_miaolve)
ov_yingjia = sgs.CreateTriggerSkill{
	name = "ov_yingjia",
	events = {sgs.CardFinished,sgs.EventPhaseStart},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
			if event==sgs.CardFinished
			then
				local use = data:toCardUse()
				if use.card:isKindOf("TrickCard")
				and player:objectName()==owner:objectName()
				then
					player:addMark(use.card:objectName().."ov_yingjia-Clear")
					local n = player:getMark(use.card:objectName().."ov_yingjia-Clear")
					if n>player:getMark("&ov_yingjia")
					then
						room:setPlayerMark(player,"&ov_yingjia",n)
					end
				end
			else
				if player:getPhase()==sgs.Player_NotActive
				then
					local n = owner:getMark("&ov_yingjia")
					room:setPlayerMark(owner,"&ov_yingjia",0)
					if n>1
					then
						if owner:getCardCount()>0
						and room:askForCard(owner,".","ov_yingjia0:",data,"ov_yingjia")
						then
							room:broadcastSkillInvoke(self)
							local to = PlayerChosen(self,owner,nil,"ov_yingjia1:")
							to:gainAnExtraTurn()
						end
					end
				end
			end
		end
	end,
}
ov_dongzhao:addSkill(ov_yingjia)
ov_mantianguohai = sgs.CreateTrickCard{
	name = "_ov_mantianguohai",
	class_name = "Mantianguohai",
	subclass = sgs.LuaTrickCard_TypeNormal,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	subtype = "ov_dongzhao_card",
--	damage_card = true,
	filter = function(self,targets,to_select,source)
	    return to_select:getCardCount(true,true)>0
		and to_select:objectName()~=source:objectName()
		and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)+1
	end,
	on_effect = function(self,effect)
		local from,to,room = effect.from,effect.to,effect.to:getRoom()
		if effect.no_respond then else end
		if to:getCardCount(true,true)<1 or to:isDead() or from:isDead() then return end
		local id = room:askForCardChosen(from,to,"hej","_ov_mantianguohai")
		from:obtainCard(sgs.Sanguosha:getCard(id),false)
		if from:getCardCount()<1 or to:isDead() or from:isDead() then return end
		id = room:askForExchange(from,"_ov_mantianguohai",1,1,true,"_ov_mantianguohai0:"..to:objectName())
		room:giveCard(from,to,id,"_ov_mantianguohai")
		return false
	end,
}
for i=0,3 do
	ov_mantianguohai:clone(i,5):setParent(extension)
end

ov_duosidawang = sgs.General(extension,"ov_duosidawang","qun",5)
ov_duosidawang:setStartHp(4)
ov_equan = sgs.CreateTriggerSkill{
	name = "ov_equan",
	events = {sgs.Damaged},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
			if event==sgs.Damaged
			and owner:getPhase()~=sgs.Player_NotActive
			then
				local damage = data:toDamage()
				room:sendCompulsoryTriggerLog(owner,self:objectName(),true,true)
				player:gainMark("&ov_equan_du",damage.damage)
			end
		end
	end,
}
ov_equanbf = sgs.CreateTriggerSkill{
	name = "#ov_equanbf",
	events = {sgs.EventPhaseChanging,sgs.EventPhaseProceeding,sgs.EnterDying},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and (target:getMark("&ov_equan_du_skill-Clear")>0
		or target:getMark("&ov_equan_du")>0 or target:hasFlag("ov_equan_du"))
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.EventPhaseChanging
		and player:getMark("&ov_equan_du_skill-Clear")>0
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
				for _,sk in sgs.list(player:getSkillList())do
					if sk:isAttachedLordSkill() then continue end
					room:removePlayerMark(player,"Qingcheng"..sk:objectName())
				end
			end
		elseif event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Start
		then
			local n = player:getMark("&ov_equan_du")
			if n>0
			then
				Skill_msg("ov_equan",player)
				player:loseAllMarks("&ov_equan_du")
				player:setFlags("ov_equan_du")
				room:loseHp(player,n)
				player:setFlags("-ov_equan_du")
			end
		elseif event==sgs.EnterDying
		and player:hasFlag("ov_equan_du")
		then
			Skill_msg("ov_equan",player)
			player:setFlags("-ov_equan_du")
			room:addPlayerMark(player,"&ov_equan_du_skill-Clear")
			for _,sk in sgs.list(player:getSkillList())do
				if sk:isAttachedLordSkill() then continue end
				room:addPlayerMark(player,"Qingcheng"..sk:objectName())
			end
		end
	end,
}
ov_duosidawang:addSkill(ov_equan)
ov_duosidawang:addSkill(ov_equanbf)
ov_manji = sgs.CreateTriggerSkill{
	name = "ov_manji",
	events = {sgs.HpLost},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
			if owner:objectName()~=player:objectName()
			then
				room:sendCompulsoryTriggerLog(owner,self:objectName(),true,true)
				if owner:getHp()<=player:getHp()
				then
					room:recover(owner,sgs.RecoverStruct(owner))
				end
				if owner:getHp()>=player:getHp()
				then
					owner:drawCards(1,self:objectName())
				end
			end
		end
	end,
}
ov_duosidawang:addSkill(ov_manji)
extension:insertRelatedSkills("ov_equan", "#ov_equanbf")

ov_yuejiu = sgs.General(extension,"ov_yuejiu","qun")
ov_cuijin = sgs.CreateTriggerSkill{
	name = "ov_cuijin",
	events = {sgs.CardFinished,sgs.DamageCaused,sgs.CardUsed},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
			if event==sgs.CardFinished
			then
				local use = data:toCardUse()
				local damage = room:getTag("damage_caused_"..use.card:toString()):toDamage()
				if damage and damage.to then return end
--				damage = use.card:property("damage_caused")
--				if damage and damage.to then return end
				if use.card:hasFlag("ov_cuijin_"..owner:objectName())
				then
					Skill_msg(self,owner)
					room:damage(sgs.DamageStruct("ov_cuijin",owner,use.from))
				end
			elseif event==sgs.DamageCaused
			then
				local damage = data:toDamage()
				if damage.card and damage.card:hasFlag("ov_cuijin_"..owner:objectName())
				then
					Skill_msg(self,owner)
					DamageRevises(data,1,player)
				end
			else
				local use = data:toCardUse()
				if use.card:isKindOf("Slash")
				and (owner:inMyAttackRange(use.from) or use.from:objectName()==owner:objectName())
				and room:askForCard(owner,"..","ov_cuijin0:",data,"ov_cuijin")
				then
					room:broadcastSkillInvoke(self:objectName())
					use.card:setFlags("ov_cuijin_"..owner:objectName())
				end
			end
		end
	end,
}
ov_yuejiu:addSkill(ov_cuijin)

ov_wuban = sgs.General(extension,"ov_wuban","shu")
ov_jintao = sgs.CreateTriggerSkill{
	name = "ov_jintao",
	events = {sgs.ConfirmDamage,sgs.CardUsed},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
			and player:getPhase()==sgs.Player_Play
			then
				player:addMark("ov_jintao-PlayClear")
				if player:getMark("ov_jintao-PlayClear")==1
				then use.card:setFlags("ov_jintao")
				elseif player:getMark("ov_jintao-PlayClear")==2
				then
					room:sendCompulsoryTriggerLog(player,self:objectName(),true,true)
					local can = use.no_respond_list
					for i,to in sgs.list(use.to)do
						table.insert(can,to:objectName())
					end
					use.no_respond_list = can
					data:setValue(use)
				end
			end
		elseif event==sgs.ConfirmDamage
		then
			local damage = data:toDamage()
			if damage.card
			and damage.card:hasFlag("ov_jintao")
			then
				room:sendCompulsoryTriggerLog(player,self:objectName(),true,true)
				DamageRevises(data,1,player)
			end
		end
	end,
}
ov_wuban:addSkill(ov_jintao)
ov_jintaobf = sgs.CreateTargetModSkill{
	name = "#ov_jintaobf",
	pattern = "Slash",
	residue_func = function(self,from,card)--额外使用
		if from:hasSkill("ov_jintao") then return 1 end
	end,
	distance_limit_func = function(self,from,card,to)--使用距离
		if from:hasSkill("ov_jintao") then return 998 end
	end,
	extra_target_func = function(self,from,card)--目标数
	end
}
ov_wuban:addSkill(ov_jintaobf)
extension:insertRelatedSkills("ov_jintao", "#ov_jintaobf")

ov_jiachong = sgs.General(extension,"ov_jiachong","qun",3)
ov_beiniCard = sgs.CreateSkillCard{
	name = "ov_beiniCard",
	mute = true,
	filter = function(self,targets,to_select,from)
		return to_select:getHp()>from:getHp()
	end,
	on_use = function(self,room,source,targets)
		for c,to in sgs.list(targets)do
			c = dummyCard()
			c:setSkillName("_ov_beini")
			local use = sgs.CardUseStruct(c,to,source)
			if source:askForSkillInvoke("ov_beini",ToData("ov_beini0:"..to:objectName()),false)
			then
				use = sgs.CardUseStruct(c,source,to)
				to:drawCards(2,"ov_beini")
				if source:isProhibited(to,c)
				then room:broadcastSkillInvoke("ov_beini") continue end
			else
				source:drawCards(2,"ov_beini")
				if to:isProhibited(source,c)
				then room:broadcastSkillInvoke("ov_beini") continue end
			end
			room:useCard(use)
		end
	end
}
ov_beini = sgs.CreateViewAsSkill{
	name = "ov_beini",
	view_as = function(self,cards)
		return ov_beiniCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_beiniCard")<1
	end,
}
ov_jiachong:addSkill(ov_beini)
ov_dingfa = sgs.CreateTriggerSkill{
	name = "ov_dingfa",
	events = {sgs.CardsMoveOneTime,sgs.EventPhaseEnd},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.CardsMoveOneTime
		then
	    	local move = data:toMoveOneTime()
			if move.from
			and player:getPhase()~=sgs.Player_NotActive
			and move.from:objectName()==player:objectName()
			then
				local n = 0
				for _,fp in sgs.list(move.from_places)do
					if fp==sgs.Player_PlaceHand
					then
						if move.to
						and move.to:objectName()~=player:objectName()
						then n = n+1
						elseif move.to_place~=sgs.Player_PlaceEquip
						or not move.to
						then
							if bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON)==sgs.CardMoveReason_S_REASON_USE
							and sgs.Sanguosha:getCard(move.card_ids:at(fp)):isKindOf("EquipCard") then continue end
							n = n+1
						end
					elseif fp==sgs.Player_PlaceEquip
					then
						if not move.to
						or move.to:objectName()~=player:objectName()
						or move.to_place~=sgs.Player_PlaceHand
						then n = n+1 end
					end 
				end
				if n<1 then return end
				room:addPlayerMark(player,"&ov_dingfa-Clear",n)
			end
		elseif event==sgs.EventPhaseEnd
		then
			local n = player:getMark("&ov_dingfa-Clear")
      	    if n>=player:getHp()
			and player:getPhase()==sgs.Player_Discard
			and player:askForSkillInvoke(self:objectName(),data)
			then
				room:broadcastSkillInvoke(self:objectName())
				n = "to_damage"
				if player:isWounded() then n = "to_damage+recover" end
				n = room:askForChoice(player,"ov_dingfa",n)
				if n=="to_damage"
				then
					n = PlayerChosen(self,player,room:getOtherPlayers(player),"ov_dingfa0:")
					room:damage(sgs.DamageStruct("ov_dingfa",player,n))
				else
					room:recover(player,sgs.RecoverStruct(player))
				end
			end
		end
		return false
	end
}
ov_jiachong:addSkill(ov_dingfa)

ov_yujin = sgs.General(extension,"ov_yujin","qun")
ov_zhenjunCard = sgs.CreateSkillCard{
	name = "ov_zhenjunCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self,targets,to_select,from)
		return to_select:objectName()~=from:objectName()
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
		for c,to in sgs.list(targets)do
			room:giveCard(source,to,self,"ov_zhenjun")
			c = room:askForUseCard(to,"Slash|^black","ov_zhenjun1:")
			if c
			then
				c = room:getTag("damage_caused_"..c:toString()):toDamage()
				if c and c.to then c = c.damage+1
				else c = 1 end
				source:drawCards(c,"ov_zhenjun")
			else
				c = sgs.SPlayerList()
				for i,p in sgs.list(room:getAlivePlayers())do
					if p:objectName()==to:objectName()
					or to:inMyAttackRange(p)
					then c:append(p) end
				end
				c = PlayerChosen("ov_zhenjun",source,c,"ov_zhenjun2:"..to:objectName())
				room:damage(sgs.DamageStruct("ov_zhenjun",source,c))
			end
		end
	end
}
ov_zhenjunvs = sgs.CreateViewAsSkill{
	name = "ov_zhenjun",
	n = 1,
	view_filter = function(self,selected,to_select)
		return to_select
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_zhenjunCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@ov_zhenjun")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_zhenjun = sgs.CreateTriggerSkill{
	name = "ov_zhenjun",
	events = {sgs.EventPhaseStart},
	view_as_skill = ov_zhenjunvs,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.EventPhaseStart
		and player:getPhase()==sgs.Player_Play
		and player:getCardCount()>0
		then
      	    room:askForUseCard(player,"@@ov_zhenjun","ov_zhenjun0:")
		end
		return false
	end
}
ov_yujin:addSkill(ov_zhenjun)

ov_xunchen = sgs.General(extension,"ov_xunchen","qun",3)
ov_weipoCard = sgs.CreateSkillCard{
	name = "ov_weipoCard",
	filter = function(self,targets,to_select,from)
		return #targets<1
	end,
	on_use = function(self,room,source,targets)
		room:addPlayerMark(source,"ov_weipo-Clear")
		for i,to in sgs.list(targets)do
			i = {}
			for c,zc in sgs.list(sgs.ZhinangClassName)do
				c = PatternsCard(zc,nil,true)
				if c then table.insert(i,c:objectName()) end
			end
			if #i<1 then continue end
			i = table.concat(i,"+")
			i = room:askForChoice(source,"ov_weipo",i)
			to:setTag(source:objectName().."ov_weipo",ToData(i))
			room:addPlayerMark(to,"&ov_weipo+#"..source:objectName())
			room:attachSkillToPlayer(to,"ov_weipobf")
		end
	end
}
ov_weipovs = sgs.CreateViewAsSkill{
	name = "ov_weipo",
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		return ov_weipoCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:getMark("ov_weipo-Clear")<1
	end,
}
ov_weipo = sgs.CreateTriggerSkill{
	name = "ov_weipo",
	events = {sgs.EventPhaseChanging},
	view_as_skill = ov_weipovs,
	waked_skills = "_ov_binglinchengxia",
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.from==sgs.Player_NotActive
		then
		   	for _,p in sgs.list(room:getAlivePlayers())do
				if p:getMark("&ov_weipo+#"..player:objectName())<1 then continue end
				room:removePlayerMark(p,"&ov_weipo+#"..player:objectName())
				room:detachSkillFromPlayer(p,"ov_weipobf",true,true)
				p:removeTag(player:objectName().."ov_weipo")
			end
		end
		return false
	end,
}
ov_xunchen:addSkill(ov_weipo)
ov_weipobfCard = sgs.CreateSkillCard{
	name = "ov_weipobfCard",
	filter = function(self,targets,to_select,from)
		return to_select:hasSkill("ov_weipo")
		and from:getMark("&ov_weipo+#"..to_select:objectName())>0
		and from:getMark(to_select:objectName().."ov_weipo-PlayClear")<1
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
		for i,to in sgs.list(targets)do
			local cname = source:getTag(to:objectName().."ov_weipo"):toString()
			room:addPlayerMark(source,to:objectName().."ov_weipo-PlayClear")
			cname = PatternsCard(cname,true,true)
			for _,c in sgs.list(cname)do
				if room:getCardOwner(c:getEffectiveId())
				then continue end
				source:obtainCard(c)
				break
			end
		end
	end
}
ov_weipobf = sgs.CreateViewAsSkill{
	name = "ov_weipobf&",
	n = 1,
	view_filter = function(self,selected,to_select)
		return to_select:isKindOf("Slash")
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_weipobfCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
	   	local tos = player:getAliveSiblings()
		tos:append(player)
		for _,p in sgs.list(tos)do
			if player:getMark(p:objectName().."ov_weipo-PlayClear")<1
			and p:hasSkill("ov_weipo")
			then return true end
		end
	end,
}
addToSkills(ov_weipobf)
ov_chenshi = sgs.CreateTriggerSkill{
	name = "ov_chenshi",
	events = {sgs.TargetSpecified,sgs.TargetConfirmed},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
			if owner:objectName()==player:objectName() then continue end
			local use = data:toCardUse()
			if not use.card:isKindOf("Binglinchengxia") then break end
			if event==sgs.TargetSpecified
			then
				if use.from:objectName()~=player:objectName()
				or player:getCardCount()<1 then continue end
				local c = room:askForCard(player,"..","ov_chenshi0:"..owner:objectName(),ToData(owner),sgs.Card_MethodNone)
				if not c then continue end
				ToSkillInvoke(self,player,owner,true)
				room:giveCard(player,owner,c,self:objectName())
				local card_ids = room:getNCards(3,false)
				room:fillAG(card_ids,player)
				room:askForAG(player,sgs.IntList(),true,self:objectName())
				room:clearAG(player)
				c = dummyCard()
				for i,id in sgs.list(card_ids)do
					i = sgs.Sanguosha:getCard(id)
					if i:isKindOf("Slash")
					then continue end
					c:addSubcard(id)
				end
				room:returnToTopDrawPile(card_ids)
				room:throwCard(c,nil)
			else
				if not use.to:contains(player) or player:getCardCount()<1 then continue end
				local c = room:askForCard(player,"..","ov_chenshi1:"..owner:objectName(),ToData(owner),sgs.Card_MethodNone)
				if not c then continue end
				ToSkillInvoke(self,player,owner,true)
				room:giveCard(player,owner,c,self:objectName())
				local card_ids = room:getNCards(3,false)
				room:fillAG(card_ids,player)
				room:askForAG(player,sgs.IntList(),true,self:objectName())
				room:clearAG(player)
				c = dummyCard()
				for i,id in sgs.list(card_ids)do
					i = sgs.Sanguosha:getCard(id)
					if i:isKindOf("Slash")
					then c:addSubcard(id) end
				end
				room:returnToTopDrawPile(card_ids)
				room:throwCard(c,nil)
			end
		end
	end,
}
ov_xunchen:addSkill(ov_chenshi)
ov_moushi = sgs.CreateTriggerSkill{
	name = "ov_moushi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged,sgs.DamageInflicted},
	on_trigger = function(self,event,player,data,room)
    	if event==sgs.Damaged
		then
		    local damage = data:toDamage()
            if damage.card and damage.card:getTypeId()~=0
			then
				room:sendCompulsoryTriggerLog(player,"ov_moushi",true,true)
				local SuitString = player:getTag("ov_moushi"):toString()
    	        room:setPlayerMark(player,"&ov_moushi+"..SuitString.."_char",0)
    	        room:setPlayerMark(player,"&ov_moushi+"..damage.card:getSuitString().."_char",1)
				player:setTag("ov_moushi",ToData(damage.card:getSuitString()))
			end
		elseif event==sgs.DamageInflicted
		then
		    local damage = data:toDamage()
            if damage.card
			and damage.card:getTypeId()~=0
			and player:getMark("&ov_moushi+"..damage.card:getSuitString().."_char")>0
			then
				room:sendCompulsoryTriggerLog(player,"ov_moushi",true,true)
    	        return DamageRevises(data,-damage.damage,player)
			end
		end
		return false
	end
}
ov_xunchen:addSkill(ov_moushi)
ov_binglinchengxia = sgs.CreateTrickCard{
	name = "_ov_binglinchengxia",
	class_name = "Binglinchengxia",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	subtype = "ov_xunchen_card",
--	damage_card = true,
	filter = function(self,targets,to_select,source)
	    return to_select:objectName()~=source:objectName()
		and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)
	end,
	on_effect = function(self,effect)
		local from,to,room = effect.from,effect.to,effect.to:getRoom()
		if effect.no_respond then else end
		local card_ids = room:getNCards(4,false)
		local move = sgs.CardsMoveStruct()
		move.card_ids = card_ids
		move.to = from
		move.to_place = sgs.Player_PlaceTable
		move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER,from:objectName(),self:objectName(),nil)
		room:moveCardsAtomic(move,true)
		room:getThread():delay(1111)
		local ids = sgs.IntList()
		for c,id in sgs.list(card_ids)do
			ids:append(id)
		end
		for c,id in sgs.list(ids)do
			c = sgs.Sanguosha:getCard(id)
			if not from:isProhibited(to,c)
			and c:isKindOf("Slash")
			and to:isAlive()
			then
				room:useCard(sgs.CardUseStruct(c,from,to))
				card_ids:removeOne(id)
			end
		end
		room:returnToTopDrawPile(card_ids)
		return false
	end,
}
ov_binglinchengxia:clone(0,7):setParent(extension)
ov_binglinchengxia:clone(1,7):setParent(extension)
ov_binglinchengxia:clone(0,13):setParent(extension)

ov_mayulu = sgs.General(extension,"ov_mayulu","shu",4,false)
ov_mayulu:addSkill("mashu")
ov_fengpo = sgs.CreateTriggerSkill{
	name = "ov_fengpo",
	events = {sgs.TargetSpecified,sgs.Death,sgs.ConfirmDamage},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.TargetSpecified
		then
	    	local use = data:toCardUse()
			use.card:removeTag("ov_fengpo")
       	    if use.to:length()==1
			and (use.card:isKindOf("Slash") or use.card:isKindOf("Duel"))
			and player:askForSkillInvoke(self:objectName(),ToData(use.to:at(0)))
			then
		       	room:broadcastSkillInvoke("fengpo")
				room:doGongxin(player,use.to:at(0),use.to:at(0):handCards(),"ov_fengpo")
				local x = 0
				for _,c in sgs.list(use.to:at(0):getHandcards())do
					if c:isRed() and player:getMark("ov_fengpo_deathdamage")>0
					or c:getSuit()==3 then x = x+1 end
				end
				local choice = "ov_fengpo1="..x.."+ov_fengpo2="..x
				choice = room:askForChoice(player,"ov_fengpo",choice,data)
				if choice:startsWith("ov_fengpo2")
				then use.card:setTag("ov_fengpo",ToData(x))
				else player:drawCards(x,"ov_fengpo") end
			end
 		elseif event==sgs.Death
		then
			local death = data:toDeath()
	        local damage = death.damage
			if damage and damage.from
			and damage.from:objectName()==player:objectName()
			then player:addMark("ov_fengpo_deathdamage") end
		else
		    local damage = data:toDamage()
            if damage.card
			then
                local x = damage.card:getTag("ov_fengpo"):toInt()
				if x<1 then return end
				Skill_msg(self,player)
    	        DamageRevises(data,x,player)
			end
		end
		return false
	end
}
ov_mayulu:addSkill(ov_fengpo)

ov_fuwan = sgs.General(extension,"ov_fuwan","qun")
ov_moukui = sgs.CreateTriggerSkill{
	name = "ov_moukui",
	events = {sgs.TargetSpecified,sgs.Dying,sgs.CardFinished},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.TargetSpecified
		then
	    	local use = data:toCardUse()
       	    if use.card:isKindOf("Slash")
			then
				local x = 0
				for _,to in sgs.list(use.to)do
					if player:askForSkillInvoke(self:objectName(),ToData(to))
					then
						room:broadcastSkillInvoke("moukui")
						local choice = "ov_moukui1"
						if to:getCardCount(false)>0
						then
							choice = "ov_moukui1+ov_moukui2="..to:objectName().."+beishui_choice=ov_moukui3"
						end
						choice = room:askForChoice(player,"ov_moukui",choice,ToData(to))
						if choice:startsWith("ov_moukui1")
						then player:drawCards(1,"ov_moukui")
						elseif choice:startsWith("ov_moukui2")
						then
							local id = room:askForCardChosen(player,to,"h","ov_moukui",false,sgs.Card_MethodDiscard)
							if id<0 then continue end
							room:throwCard(id,to,player)
						else
							player:drawCards(1,"ov_moukui")
							local id = room:askForCardChosen(player,to,"h","ov_moukui",false,sgs.Card_MethodDiscard)
							if id<0 then continue end
							room:throwCard(id,to,player)
							use.card:setFlags("beishui_choice"..to:objectName())
						end
					end
				end
			end
 		elseif event==sgs.Dying
		then
			local dying = data:toDying()
	        local damage = dying.damage
			if damage and damage.from
			and damage.from:objectName()==player:objectName()
			then dying.who:setFlags("ov_moukui_dying") end
		else
	    	local use = data:toCardUse()
       	    if use.card:isKindOf("Slash")
			then
				for _,to in sgs.list(use.to)do
					if to:isDead() then continue end
					if use.card:hasFlag("beishui_choice"..to:objectName())
					and not to:hasFlag("ov_moukui_dying")
					then
						Skill_msg(self,player)
						if player:getCardCount()>0
						then
							local id = room:askForCardChosen(to,player,"he","ov_moukui",false,sgs.Card_MethodDiscard)
							if id~=-1 then room:throwCard(id,player,to) end
						end
					end
					to:setFlags("-ov_moukui_dying")
					use.card:setFlags("-beishui_choice"..to:objectName())
				end
			end
		end
		return false
	end
}
ov_fuwan:addSkill(ov_moukui)

ov_hejin = sgs.General(extension,"ov_hejin","qun")
ov_mouzhuCard = sgs.CreateSkillCard{
	name = "ov_mouzhuCard",
	will_throw = false,
	skill_name = "mouzhu",
	filter = function(self,targets,to_select,from)
		return to_select:objectName()~=from:objectName()
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
		for _,to in sgs.list(targets)do
			local tos = room:getOtherPlayers(to)
			tos:removeOne(source)
			local n = 0
			for c,p in sgs.list(tos)do
				if p:getHp()<=source:getHp()
				and p:getCardCount()>0
				then
					c = room:askForCard(p,"..","ov_mouzhu0:"..source:objectName(),ToData(source),sgs.Card_MethodNone)
					if c then room:giveCard(p,source,c,"ov_mouzhu") n = n+1 end
				end
			end
			if n<1
			then
				room:loseHp(source)
				for c,p in sgs.list(tos)do
					room:loseHp(p)
				end
			else
				tos = {}
				local dc = dummyCard()
				dc:setSkillName("_ov_mouzhu")
				if not source:isProhibited(to,dc)
				then table.insert(tos,"mz_slash="..source:objectName()..":"..n) end
				dc = dummyCard("duel")
				dc:setSkillName("_ov_mouzhu")
				if not source:isProhibited(to,dc)
				then table.insert(tos,"mz_duel="..source:objectName()..":"..n) end
				if #tos<1 then continue end
				tos = table.concat(tos,"+")
				tos = room:askForChoice(to,"ov_mouzhu",tos)
				if tos:startsWith("mz_slash")
				then tos = "slash" else tos = "duel" end
				tos = dummyCard(tos)
				tos:setSkillName("_ov_mouzhu")
				room:setTag("ov_mouzhu_"..tos:toString(),ToData(n))
				room:useCard(sgs.CardUseStruct(tos,source,to))
			end
		end
	end
}
ov_mouzhuvs = sgs.CreateViewAsSkill{
	name = "ov_mouzhu",
	view_as = function(self,cards)
		return ov_mouzhuCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_mouzhuCard")<1
	end,
}
ov_mouzhu = sgs.CreateTriggerSkill{
	name = "ov_mouzhu",
	events = {sgs.ConfirmDamage},
	view_as_skill = ov_mouzhuvs,
	can_trigger = function(self,target)
		return target and target:isAlive()
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.ConfirmDamage
		then
		    local damage = data:toDamage()
            if damage.card and damage.from
			and damage.from:objectName()==player:objectName()
			then
                local x = room:getTag("ov_mouzhu_"..damage.card:toString()):toInt()
				if x<1 then return end
				local owner = room:findPlayerBySkillName(self:objectName())
				owner = owner or player
				Skill_msg(self,owner)
				if x~=damage.damage
				then x = x-damage.damage
				else x = 0 end
    	        DamageRevises(data,x,owner)
				room:removeTag("ov_mouzhu_"..damage.card:toString())
			end
		end
		return false
	end
}
ov_hejin:addSkill(ov_mouzhu)
ov_yanhuoCard = sgs.CreateSkillCard{
	name = "ov_yanhuoCard",
--	target_fixed = true,
--	will_throw = false,
	skill_name = "yanhuo",
	filter = function(self,targets,to_select,source)
		return #targets<source:getCardCount()
	end,
	feasible = function(self,targets)
		return #targets>0
	end,
	on_use = function(self,room,source,targets)
		for n,to in sgs.list(targets)do
			n = source:getCardCount()
			if #targets<2
			then
				room:askForDiscard(to,"ov_yanhuo",n,n,false,true)
			else
				room:askForDiscard(to,"ov_yanhuo",1,1,false,true)
			end
		end
	end,
}
ov_yanhuovs = sgs.CreateViewAsSkill{
	name = "ov_yanhuo",
	view_as = function(self,cards)
		return ov_yanhuoCard:clone()
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@ov_yanhuo")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return false
	end
}
ov_yanhuo = sgs.CreateTriggerSkill{
	name = "ov_yanhuo",
	events = {sgs.Death},
	view_as_skill = ov_yanhuovs,
	can_trigger = function(self,target)
		return true
	end,
 	on_trigger = function(self,event,player,data,room)
 		if event==sgs.Death
		then
			local death = data:toDeath()
			if death.who:objectName()~=player:objectName()
			or not player:hasSkill(self)
			or player:getCardCount()<1
			then return end
			room:askForUseCard(player,"@@ov_yanhuo","ov_yanhuo0:"..player:getCardCount())
		end
		return false
	end,
}
ov_hejin:addSkill(ov_yanhuo)

ov_hucheer = sgs.General(extension,"ov_hucheer","qun")
ov_shenxing = sgs.CreateDistanceSkill{
	name = "ov_shenxing",
	correct_func = function(self,from,to)
		local n = 0
		if from:hasSkill(self)
		and not from:getDefensiveHorse()
		and not from:getOffensiveHorse()
		then n = n-1 end
		return n
	end
}
ov_shenxingbf = sgs.CreateMaxCardsSkill{
    name = "#ov_shenxingbf",
	extra_func = function(self,target)
		if target:hasSkill("ov_shenxing")
		and not target:getDefensiveHorse()
		and not target:getOffensiveHorse()
		then return 1 end
	end 
}
ov_hucheer:addSkill(ov_shenxing)
ov_hucheer:addSkill(ov_shenxingbf)
extension:insertRelatedSkills("ov_shenxing", "#ov_shenxingbf")
ov_daojiCard = sgs.CreateSkillCard{
	name = "ov_daojiCard",
--	will_throw = false,
	skill_name = "daoji",
	filter = function(self,targets,to_select,from)
		return from:inMyAttackRange(to_select)
		and to_select:getCardCount()>0
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
		for _,to in sgs.list(targets)do
			local id = room:askForCardChosen(source,to,"he","ov_daoji")
			if id~=-1
			then
				id = sgs.Sanguosha:getCard(id)
				source:obtainCard(id,false)
				if id:getTypeId()==1
				then source:drawCards(1,"ov_daoji")
				elseif id:getTypeId()==3
				and id:isAvailable(source)
				then
					room:useCard(sgs.CardUseStruct(id,source,source))
					room:damage(sgs.DamageStruct("ov_daoji",source,to))
				end
			end
		end
	end
}
ov_daoji = sgs.CreateViewAsSkill{
	name = "ov_daoji",
	n = 1,
	view_filter = function(self,selected,to_select)
		return to_select:getTypeId()~=1
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_daojiCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_daojiCard")<1
	end,
}
ov_hucheer:addSkill(ov_daoji)

ov_fuhuanghou = sgs.General(extension,"ov_fuhuanghou","qun",3,false)
ov_fuhuanghou:addSkill("tenyearzhuikong")
ov_fuhuanghou:addSkill("mobileqiuyuan")

ov_zangba = sgs.General(extension,"ov_zangba","wei")
ov_guanyu = sgs.CreateTriggerSkill{
	name = "ov_guanyu",
--	view_as_skill = ov_guanyu,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart},
	on_trigger = function(self,event,player,data,room)
        if event==sgs.GameStart
	    then
			room:sendCompulsoryTriggerLog(player,"ov_guanyu",true,true)
	    	local toc = dummyCard()
			local ts = sgs.IntList()
			for c,id in sgs.list(room:getDrawPile())do
				c = sgs.Sanguosha:getCard(id)
				if ts:contains(c:getTypeId())
				then continue end
				toc:addSubcard(id)
				ts:append(c:getTypeId())
			end
			player:obtainCard(toc)
		end
		return false
	end,
}
ov_zangba:addSkill(ov_guanyu)
ov_hengjiang = sgs.CreateTriggerSkill{
	name = "ov_hengjiang",
	events = {sgs.TargetSpecifying,sgs.CardFinished},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	local use = data:toCardUse()
		if event==sgs.TargetSpecifying
		then
       	    if use.card:getTypeId()==1
			or use.card:isNDTrick()
			then
				if use.to:length()>1
				or player:getPhase()~=sgs.Player_Play
				or use.from:objectName()~=player:objectName()
				or player:getMark("ov_hengjiang-PlayClear")>0
				or not player:askForSkillInvoke(self:objectName(),data)
				then return end
				player:addMark("ov_hengjiang-PlayClear")
				use.card:setTag("ov_hengjiang",ToData(true))
				room:broadcastSkillInvoke("hengjiang")
				use.to = sgs.SPlayerList()
				for _,p in sgs.list(room:getAlivePlayers())do
					if not player:isProhibited(p,use.card)
					and player:inMyAttackRange(p)
					and not use.to:contains(p)
					then
						use.to:append(p)
						room:doAnimate(1,player:objectName(),p:objectName())
					end
				end
				room:sortByActionOrder(use.to)
				Log_message("#ov_hengjiang0",player,use.to,nil,use.card:objectName())
				data:setValue(use)
			end
		elseif use.card:getTag("ov_hengjiang"):toBool()
		then
			Skill_msg(self,player)
			use.card:removeTag("ov_hengjiang")
			local n = 0
			for _,p in sgs.list(room:getAlivePlayers())do
				if p:hasFlag("ov_hengjiangResponded_"..use.card:toString())
				then
					n = n+1
					p:setFlags("-ov_hengjiangResponded_"..use.card:toString())
				end
			end
			if n>0 then player:drawCards(n,"ov_hengjiang") end
		end
		return false
	end
}
ov_hengjiangbf = sgs.CreateTriggerSkill{
	name = "#ov_hengjiangbf",
--	view_as_skill = ov_danfavs,
	events = {sgs.CardUsed,sgs.CardResponded},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName("ov_hengjiang")
	end,
	on_trigger = function(self,event,player,data,room)
		local card
		if event==sgs.CardResponded
		then card = data:toCardResponse().m_toCard
		else card = data:toCardUse().whocard end
		if not card or not card:getTag("ov_hengjiang"):toBool() then return end
		player:setFlags("ov_hengjiangResponded_"..card:toString())
		return false
	end,
}
ov_zangba:addSkill(ov_hengjiang)
ov_zangba:addSkill(ov_hengjiangbf)
extension:insertRelatedSkills("ov_hengjiang", "#ov_hengjiangbf")

ov_liuhong = sgs.General(extension,"ov_liuhong$","qun")
ov_yujuevsCard = sgs.CreateSkillCard{
	name = "ov_yujuevsCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		if to_select:hasSkill("ov_yujue")
		and to_select:objectName()~=from:objectName()
		and #targets<1
		then
			local n = 2-from:getMark(to_select:objectName().."ov_yujue-PlayClear")
			if to_select:hasLordSkill("ov_fengqi")
			and from:getKingdom()=="qun"
			then n = n+2 end
			if n>0 then return true end
		end
	end,
	about_to_use = function(self,room,use)
		for _,to in sgs.list(use.to)do
			room:broadcastSkillInvoke("ov_yujue")--播放配音
			room:doAnimate(1,use.from:objectName(),to:objectName())
			room:notifySkillInvoked(to,"ov_yujue")
			local msg = sgs.LogMessage()
			msg.type = "$bf_huangtian0"
			msg.from = use.from
			msg.arg = to:getGeneralName()
			msg.arg2 = "ov_yujue"
			room:sendLog(msg)
			to:obtainCard(self,false)
			room:addPlayerMark(use.from,to:objectName().."ov_yujue-PlayClear",self:subcardsLength())
		end
	end
}
ov_yujuevs = sgs.CreateViewAsSkill{
	name = "ov_yujuevs&",
	n = 4,
	view_filter = function(self,selected,to_select)
		for _,lh in sgs.list(sgs.Self:getAliveSiblings())do
			if lh:hasSkill("ov_yujue")
			then
				local n = 2-sgs.Self:getMark(lh:objectName().."ov_yujue-PlayClear")
				if lh:hasLordSkill("ov_fengqi")
				and sgs.Self:getKingdom()=="qun"
				then n = n+2 end
				if n>0 then return #selected<n end
			end
		end
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_yujuevsCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		for _,lh in sgs.list(player:getAliveSiblings())do
			if lh:hasSkill("ov_yujue")
			then
				local n = 2-player:getMark(lh:objectName().."ov_yujue-PlayClear")
				if lh:hasLordSkill("ov_fengqi")
				and player:getKingdom()=="qun"
				then n = n+2 end
				if n>0 then return true end
			end
		end
	end,
}
ov_yujue = sgs.CreateTriggerSkill{
	name = "ov_yujue",
	events = {sgs.EventAcquireSkill,sgs.CardsMoveOneTime},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		for _,p in sgs.list(room:getOtherPlayers(player))do
			if p:hasSkill("ov_yujuevs") then continue end
			room:attachSkillToPlayer(p,"ov_yujuevs")
		end
		if event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			if not move.to or not move.from
			or move.to_place~=sgs.Player_PlaceHand
			or player:getPhase()~=sgs.Player_NotActive
			or move.to:objectName()~=player:objectName()
			or move.from:objectName()==player:objectName()
			then return end
			local from = BeMan(room,move.from)
	       	for i,id in sgs.list(move.card_ids)do
				if move.from_places:at(i)~=sgs.Player_PlaceHand
				and move.from_places:at(i)~=sgs.Player_PlaceEquip
				then continue end
				i = {}
				if from:getMark("ov_yujue1-Clear")<1
				then table.insert(i,"ov_yujue1") end
				if from:getMark("ov_yujue2-Clear")<1
				then table.insert(i,"ov_yujue2") end
		 		if #i<1 or not player:askForSkillInvoke(self:objectName(),ToData(from))
				then break end
				i = table.concat(i,"+")
				i = room:askForChoice(from,"ov_yujue",i)
				from:addMark(i.."-Clear")
				if i=="ov_yujue1"
				then
					id = sgs.SPlayerList()
					i = room:getAlivePlayers()
					i:removeOne(player)
					for _,p in sgs.list(i)do
						if from:inMyAttackRange(p)
						and from:canDiscard(p,"he")
						then id:append(p) end
					end
					if id:isEmpty() then continue end
					i = PlayerChosen(self,from,id,"ov_yujue10:")
					local id = room:askForCardChosen(from,i,"he","ov_yujue",false,sgs.Card_MethodDiscard)
					if id<0 then break end
					room:throwCard(id,i,from)
				end
			end
		end
	end,
}
ov_liuhong:addSkill(ov_yujue)
addToSkills(ov_yujuevs)
ov_yujuebf = sgs.CreateTriggerSkill{
	name = "#ov_yujuebf",
--	view_as_skill = ov_danfavs,
	events = {sgs.CardUsed},
	can_trigger = function(self,target)
		return target and target:getMark("ov_yujue2-Clear")>0
		and target:getMark("ov_yujue2use-Clear")<1
	end,
	on_trigger = function(self,event,player,data,room)
		local use = data:toCardUse()
		if use.card:getTypeId()==0
		then return end
		player:addMark("ov_yujue2use-Clear")
		Skill_msg("ov_yujue",player)
		local cs = {}
		for c,id in sgs.list(room:getDrawPile())do
			c = sgs.Sanguosha:getCard(id)
			if use.card:getType()~=c:getType()
			then continue end
			table.insert(cs,c)
		end
		for c,id in sgs.list(room:getDiscardPile())do
			c = sgs.Sanguosha:getCard(id)
			if use.card:getType()~=c:getType()
			then continue end
			table.insert(cs,c)
		end
		if #cs<1 then return end
		player:obtainCard(cs[math.random(1,#cs)])
		return false
	end,
}
ov_liuhong:addSkill(ov_yujuebf)
extension:insertRelatedSkills("ov_yujue", "#ov_yujuebf")
ov_gezhi = sgs.CreateTriggerSkill{
	name = "ov_gezhi",
--	view_as_skill = ov_danfavs,
	events = {sgs.CardUsed,sgs.EventPhaseEnd},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardUsed
		and player:getPhase()==sgs.Player_Play
		then
			local use = data:toCardUse()
			if use.card:getTypeId()==0
			or player:getMark(use.card:getTypeId().."ov_gezhi-PlayClear")>0
			then return end
			player:addMark(use.card:getTypeId().."ov_gezhi-PlayClear")
			if player:getHandcardNum()<1 then return end
			local c = room:askForCard(player,".","ov_gezhi0:",data,sgs.Card_MethodRecast)
			if c
			then
				room:broadcastSkillInvoke("ov_gezhi")--播放配音
				UseCardRecast(player,c,"@ov_gezhi")
				room:addPlayerMark(player,"&ov_gezhi-PlayClear")
			end
		elseif event==sgs.EventPhaseEnd
		and player:getPhase()==sgs.Player_Play
		and player:getMark("&ov_gezhi-PlayClear")>1
		then
			local tos = sgs.SPlayerList()
			for c,p in sgs.list(room:getAlivePlayers())do
				if p:getMark("ov_gezhibf1")>0
				and p:getMark("ov_gezhibf2")>0
				and p:getMark("ov_gezhibf3")>0
				then continue end
				tos:append(p)
			end
			if tos:isEmpty() then return end
			tos = room:askForPlayerChosen(player,tos,self:objectName(),"ov_gezhi1:",true,true)
			if not tos then return end
			room:broadcastSkillInvoke("ov_gezhi")--播放配音
			if player:hasLordSkill("ov_fengqi")
			and player:objectName()~=tos:objectName()
			then
				local lord = {}
				for _,skill in sgs.list(tos:getGeneral():getVisibleSkillList())do
					if skill:isLordSkill() and not tos:hasLordSkill(skill)
					and not table.contains(lord,skill:objectName())
					then table.insert(lord,skill:objectName()) end
				end
				if tos:getGeneral2()
				then
					for _,skill in sgs.list(tos:getGeneral2():getVisibleSkillList())do
						if skill:isLordSkill() and not tos:hasLordSkill(skill)
						and not table.contains(lord,skill:objectName())
						then table.insert(lord,skill:objectName()) end
					end
				end
				if #lord>0
				and ToSkillInvoke("ov_fengqi",tos,player,ToData("ov_fengqi0"))
				then
					room:notifySkillInvoked(player,"ov_fengqi")
					for _,sk in sgs.list(lord)do
						tos:acquireSkill(sk)
						room:getThread():trigger(sgs.EventAcquireSkill,room,tos,ToData(sk))
						Log_message("#ov_fengqi1",tos,nil,nil,sk)
					end
				end
			end
			local choice = {}
			for i=1,3 do
				if tos:getMark("ov_gezhibf"..i)>0 then continue end
				table.insert(choice,"ov_gezhibf"..i)
			end
			choice = table.concat(choice,"+")
			choice = room:askForChoice(tos,"ov_gezhibf",choice)
			Log_message("#ov_gezhibf0",tos,nil,nil,"ov_gezhi",choice)
			room:addPlayerMark(tos,choice)
			if choice~="ov_gezhibf3"
			then return end
			room:gainMaxHp(tos)
		end
		return false
	end,
}
ov_liuhong:addSkill(ov_gezhi)
ov_gezhibf1 = sgs.CreateAttackRangeSkill{
	name = "#ov_gezhibf1",
    extra_func = function(self,target)
		if target:getMark("ov_gezhibf1")>0
		then return 2 end
	end,
}
ov_liuhong:addSkill(ov_gezhibf1)
extension:insertRelatedSkills("ov_gezhi", "#ov_gezhibf1")
ov_gezhibf2 = sgs.CreateMaxCardsSkill{
    name = "#ov_gezhibf2",
	extra_func = function(self,target)
		if target:getMark("ov_gezhibf2")>0
		then return 2 end
	end 
}
ov_liuhong:addSkill(ov_gezhibf2)
extension:insertRelatedSkills("ov_gezhi", "#ov_gezhibf2")
ov_fengqi = sgs.CreateTriggerSkill{
	name = "ov_fengqi$",
	events = {sgs.EventPhaseChanging},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self,target)
		if target and target:isAlive()
		and target:getKingdom()=="qun"
		then
			for _,owner in sgs.list(target:getRoom():findPlayersBySkillName(self:objectName()))do
				if owner:hasLordSkill(self) then return true end
			end
		end
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
			if owner:hasLordSkill(self) and player~=owner
			then
				if change.to==sgs.Player_Play
				then room:changeTranslation(player,"ov_yujuevs",2)
				elseif change.from==sgs.Player_Play
				then room:changeTranslation(player,"ov_yujuevs",1) end
			end
		end
	end,
}
ov_liuhong:addSkill(ov_fengqi)

ov_caocao = sgs.General(extension,"ov_caocao","qun")
ov_lingfa = sgs.CreateTriggerSkill{
	name = "ov_lingfa",
	events = {sgs.RoundStart,sgs.CardUsed,sgs.CardFinished},
	waked_skills = "ov_zhian",
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
			if event==sgs.RoundStart
			and owner:objectName()==player:objectName()
			then
				player:addMark("ov_lingfa")
				if player:getMark("ov_lingfa")<2
				then
					if ToSkillInvoke(self,player,nil,ToData("ov_lingfa1"))
					then
						player:setTag("ov_lingfa1",ToData(true))
						room:addPlayerMark(player,"&ov_lingfa10")
					end
				elseif player:getMark("ov_lingfa")<3
				then
					player:removeTag("ov_lingfa1")
					room:removePlayerMark(player,"&ov_lingfa10")
					if ToSkillInvoke(self,player,nil,ToData("ov_lingfa2"))
					then
						player:setTag("ov_lingfa2",ToData(true))
						room:addPlayerMark(player,"&ov_lingfa20")
					end
				elseif player:getMark("ov_lingfa")<4
				then
					Skill_msg(self,player)
					player:removeTag("ov_lingfa2")
					player:setMark("ov_lingfa",0)
					room:removePlayerMark(player,"&ov_lingfa20")
					room:detachSkillFromPlayer(player,"ov_lingfa")
					room:acquireSkill(player,"ov_zhian")
				end
			elseif event==sgs.CardUsed
			and owner:objectName()~=player:objectName()
			then
				local use = data:toCardUse()
				if use.card:isKindOf("Slash")
				and owner:getTag("ov_lingfa1"):toBool()
				then
					Skill_msg(self,owner,math.random(1,2))
					if player:getCardCount()>0
					and room:askForCard(player,"..","ov_lingfa1:"..owner:objectName(),ToData(owner))
					then return end
					room:damage(sgs.DamageStruct("ov_lingfa",owner,player))
				end
			elseif event==sgs.CardFinished
			and owner:objectName()~=player:objectName()
			then
				local use = data:toCardUse()
				if use.card:isKindOf("Peach")
				and owner:getTag("ov_lingfa2"):toBool()
				then
					local c = nil
					Skill_msg(self,owner,math.random(1,2))
					if player:getCardCount()>0
					then
						c = room:askForCard(player,"..","ov_lingfa2:"..owner:objectName(),ToData(owner),sgs.Card_MethodNone)
					end
					if c then room:giveCard(player,owner,c,"ov_lingfa")
					else room:damage(sgs.DamageStruct("ov_lingfa",owner,player)) end
				end
			end
		end
	end,
}
ov_caocao:addSkill(ov_lingfa)
ov_zhian = sgs.CreateTriggerSkill{
	name = "ov_zhian",
	events = {sgs.CardFinished},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
			if event==sgs.CardFinished
			then
				local use = data:toCardUse()
				if use.card:isKindOf("EquipCard")
				or use.card:isKindOf("DelayedTrick")
				then
					if room:getCardPlace(use.card:getEffectiveId())~=sgs.Player_PlaceEquip
					and room:getCardPlace(use.card:getEffectiveId())~=sgs.Player_PlaceDelayedTrick
					or owner:getMark("ov_zhian-Clear")>0
					then return end
					local choice = {}
					local to = room:getCardOwner(use.card:getEffectiveId())
					if to and owner:canDiscard(to,use.card:getEffectiveId())
					then table.insert(choice,"ov_zhian1="..use.card:objectName()) end
					if owner:getHandcardNum()>0 then table.insert(choice,"ov_zhian2="..use.card:objectName()) end
					if use.from:isAlive() then table.insert(choice,"ov_zhian3="..use.from:objectName()) end
					if #choice>0 and ToSkillInvoke(self,owner,use.from)
					then
						owner:addMark("ov_zhian-Clear")
						choice = table.concat(choice,"+")
						choice = room:askForChoice(owner,"ov_zhian",choice,data)
						if choice:startsWith("ov_zhian1")
						then room:throwCard(use.card,to,owner)
						elseif choice:startsWith("ov_zhian2")
						then
							room:askForDiscard(owner,"ov_zhian",1,1)
							owner:obtainCard(use.card)
						else
							room:damage(sgs.DamageStruct("ov_zhian",owner,player))
						end
					end
				end
			end
		end
	end,
}
addToSkills(ov_zhian)

ov_zhangmancheng = sgs.General(extension,"ov_zhangmancheng","qun")
ov_fengji = sgs.CreateTriggerSkill{
	name = "ov_fengji",
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getCardCount()>0
		and player:getPile("ov_shi"):isEmpty()
		and player:getPhase()==sgs.Player_Play
		then
			local c = room:askForCard(player,"..","ov_fengji0:",data,sgs.Card_MethodNone)
			if c
			then
				ToSkillInvoke(self,player,true)
				player:addToPile("ov_shi",c)
				SetShifa(self,player).effect = function(owner,x)
					local ov_shi = owner:getPile("ov_shi")
					if ov_shi:isEmpty() then return end
					local dc = dummyCard()
					for i,id in sgs.list(ov_shi)do
						local c = sgs.Sanguosha:getCard(id)
						for _,d in sgs.list(room:getDrawPile())do
							if dc:subcardsLength()>=x then break end
							d = sgs.Sanguosha:getCard(d)
							if d:objectName()~=c:objectName()
							then continue end
							dc:addSubcard(d)
						end
					end
					owner:obtainCard(dc)
					dc:clearSubcards()
					dc:addSubcards(ov_shi)
					room:throwCard(dc,nil)
				end
			end
		end
		return false
	end,
}
ov_zhangmancheng:addSkill(ov_fengji)
ov_yiju = sgs.CreateTriggerSkill{
	name = "ov_yiju",
	events = {sgs.DamageInflicted,sgs.PreCardUsed},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.DamageInflicted
		then
		    local damage = data:toDamage()
            if player:getPile("ov_shi"):length()>0
			then
				Skill_msg(self,player,math.random(1,2))
				local dc = dummyCard()
				dc:addSubcards(player:getPile("ov_shi"))
				room:throwCard(dc,nil)
    	        DamageRevises(data,1,player)
			end
		else
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
			and player:getSlashCount()>1 and player:getSlashCount()<=player:getHp()
			then room:broadcastSkillInvoke(self:objectName()) end
		end
		return false
	end
}
ov_zhangmancheng:addSkill(ov_yiju)
ov_yijubf = sgs.CreateTargetModSkill{
	name = "#ov_yijubf",
	pattern = "Slash",
	residue_func = function(self,from,card)--额外使用
		if from:hasSkill("ov_yiju") and from:getPile("ov_shi"):length()>0
		then return from:getHp()-1 end
	end,
	distance_limit_func = function(self,from,card,to)--使用距离
	end,
	extra_target_func = function(self,from,card)--目标数
	end
}
ov_zhangmancheng:addSkill(ov_yijubf)
extension:insertRelatedSkills("ov_yiju", "#ov_yijubf")
ov_yijubf1 = sgs.CreateAttackRangeSkill{
	name = "#ov_yijubf1",
    fixed_func = function(self,target)
		if target:hasSkill("ov_yiju")
		and target:getPile("ov_shi"):length()>0
		then return target:getHp() end
		return -1
	end,
}
ov_zhangmancheng:addSkill(ov_yijubf1)
extension:insertRelatedSkills("ov_yiju", "#ov_yijubf1")
ov_budao = sgs.CreateTriggerSkill{
	name = "ov_budao",
	events = {sgs.EventPhaseProceeding},
	limit_mark = "@ov_budao",
	frequency = sgs.Skill_Limited,
	waked_skills = "ov_sfzhouhu,ov_sffengqi,ov_sfzuhuo",
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getMark("@ov_budao")>0
		and player:getPhase()==sgs.Player_Start
		and ToSkillInvoke(self,player)
		then
			room:doSuperLightbox(player:getGeneralName(),self:objectName())
			room:removePlayerMark(player,"@ov_budao")
			room:loseMaxHp(player)
			room:recover(player,sgs.RecoverStruct(player))
			local choice = {}
			if not player:hasSkill("ov_sfzhouhu") then table.insert(choice,"ov_sfzhouhu") end
			if not player:hasSkill("ov_sffengqi") then table.insert(choice,"ov_sffengqi") end
			if not player:hasSkill("ov_sfzuhuo") then table.insert(choice,"ov_sfzuhuo") end
			choice = table.concat(choice,"+")
			choice = room:askForChoice(player,"ov_budao",choice)
			room:acquireSkill(player,choice)
			local to = room:askForPlayerChosen(player,room:getOtherPlayers(player),self:objectName(),"ov_budao0:"..choice,true,true)
			if to
			then
				room:acquireSkill(to,choice)
				if to:getCardCount()<1 then return end
				local c = room:askForCard(to,"..!","ov_budao1:"..player:objectName(),ToData(player),sgs.Card_MethodNone)
				if c then room:giveCard(to,player,c,"ov_budao") end
			end
		end
		return false
	end,
}
ov_zhangmancheng:addSkill(ov_budao)
ov_sfzhouhuCard = sgs.CreateSkillCard{
	name = "ov_sfzhouhuCard",
	target_fixed = true,
}
ov_sfzhouhuvs = sgs.CreateViewAsSkill{
	name = "ov_sfzhouhu",
	n = 1,
	view_filter = function(self,selected,to_select)
		return to_select:isRed()
		and not to_select:isEquipped()
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_sfzhouhuCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_sfzhouhuCard")<1
	end,
}
ov_sfzhouhu = sgs.CreateTriggerSkill{
	name = "ov_sfzhouhu",
	events = {sgs.CardUsed},
	view_as_skill = ov_sfzhouhuvs,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:objectName()~="ov_sfzhouhuCard" then return end
			SetShifa("ov_sfzhouhu",player).effect = function(owner,x)
				room:broadcastSkillInvoke(self:objectName())
				room:recover(owner,sgs.RecoverStruct(owner,nil,x))
			end
		end
	end,
}
addToSkills(ov_sfzhouhu)
ov_sffengqiCard = sgs.CreateSkillCard{
	name = "ov_sffengqiCard",
	target_fixed = true,
}
ov_sffengqivs = sgs.CreateViewAsSkill{
	name = "ov_sffengqi",
	n = 1,
	view_filter = function(self,selected,to_select)
		return to_select:isBlack()
		and not to_select:isEquipped()
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_sffengqiCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_sffengqiCard")<1
	end,
}
ov_sffengqi = sgs.CreateTriggerSkill{
	name = "ov_sffengqi",
	events = {sgs.CardUsed},
	view_as_skill = ov_sffengqivs,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:objectName()~="ov_sffengqiCard" then return end
			SetShifa("ov_sffengqi",player).effect = function(owner,x)
				room:broadcastSkillInvoke(self:objectName())
				owner:drawCards(x*2,"ov_sffengqi")
			end
		end
	end,
}
addToSkills(ov_sffengqi)
ov_sfzuhuoCard = sgs.CreateSkillCard{
	name = "ov_sfzuhuoCard",
	target_fixed = true,
}
ov_sfzuhuovs = sgs.CreateViewAsSkill{
	name = "ov_sfzuhuo",
	n = 1,
	view_filter = function(self,selected,to_select)
		return to_select:getTypeId()~=1
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_sfzuhuoCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_sfzuhuoCard")<1
	end,
}
ov_sfzuhuo = sgs.CreateTriggerSkill{
	name = "ov_sfzuhuo",
--	frequency = sgs.Skill_Compulsory,
	view_as_skill = ov_sfzuhuovs,
	events = {sgs.DamageInflicted,sgs.CardUsed},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and (target:getMark("&ov_sfzuhuo")>0 or target:hasSkill(self))
	end,
	on_trigger = function(self,event,player,data,room)
    	if event==sgs.DamageInflicted
		and player:getMark("&ov_sfzuhuo")>0
		then
		    local damage = data:toDamage()
			Skill_msg(self,player)
			room:removePlayerMark(player,"&ov_sfzuhuo")
            return DamageRevises(data,-damage.damage,player)
		elseif event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:objectName()~="ov_sfzuhuoCard" then return end
			SetShifa("ov_sfzuhuo",player).effect = function(owner,x)
				if x<owner:getMark("&ov_sfzuhuo") then x = owner:getMark("&ov_sfzuhuo") end
				room:broadcastSkillInvoke(self:objectName())
				room:setPlayerMark(owner,"&ov_sfzuhuo",x)
			end
		end
		return false
	end
}
addToSkills(ov_sfzuhuo)

ov_handang = sgs.General(extension,"ov_handang","wu")
ov_gongqiCard = sgs.CreateSkillCard{
	name = "ov_gongqiCard",
	target_fixed = true,
	skill_name = "gongqi",
	on_use = function(self,room,source,targets)
		room:setPlayerMark(source,"&ov_gongqi+:+"..self:getSuitString().."_char-PlayClear",1)
		local c = self:getSubcards():at(0)
		c = sgs.Sanguosha:getCard(c)
		if c:isKindOf("EquipCard")
		then
			local tos = sgs.SPlayerList()
			for c,p in sgs.list(room:getOtherPlayers(source))do
				if source:canDiscard(p,"he")
				then tos:append(p) end
			end
			if tos:isEmpty() then return end
			tos = room:askForPlayerChosen(source,tos,"ov_gongqi","ov_gongqi0:",true)
			if not tos then return end
			room:doAnimate(1,source:objectName(),tos:objectName())
			local id = room:askForCardChosen(source,tos,"he","ov_lingbao",false,sgs.Card_MethodDiscard)
			if id<0 then return end
			room:throwCard(id,tos,source)
		end
	end
}
ov_gongqi = sgs.CreateViewAsSkill{
	name = "ov_gongqi",
	n = 1,
	view_filter = function(self,selected,to_select)
		return not sgs.Self:isJilei(to_select)
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_gongqiCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_gongqiCard")<1
	end,
}
ov_handang:addSkill(ov_gongqi)
ov_gongqibf = sgs.CreateAttackRangeSkill{
	name = "#ov_gongqibf",
    extra_func = function(self,target)
		if target:hasSkill("ov_gongqi")
		then return 998 end
	end,
}
ov_gongqibf1 = sgs.CreateTargetModSkill{
	name = "#ov_gongqibf1",
	pattern = "Slash",
	residue_func = function(self,from,card)--额外使用
		if from:hasSkill("ov_gongqi")
		and from:getMark("&ov_gongqi+:+"..card:getSuitString().."_char-PlayClear")>0
		then self:setObjectName("ov_gongqi") return 998 end
	end,
	distance_limit_func = function(self,from,card,to)--使用距离
	end,
	extra_target_func = function(self,from,card)--目标数
	end
}
ov_handang:addSkill(ov_gongqibf)
ov_handang:addSkill(ov_gongqibf1)
extension:insertRelatedSkills("ov_gongqi", "#ov_gongqibf")
extension:insertRelatedSkills("ov_gongqi", "#ov_gongqibf1")
ov_jiefanCard = sgs.CreateSkillCard{
	name = "ov_jiefanCard",
--	will_throw = false,
	skill_name = "jiefan",
	filter = function(self,targets,to_select,from)
		return #targets<1
	end,
	on_use = function(self,room,source,targets)
		room:doSuperLightbox(source:getGeneralName(),"ov_jiefan")
		room:removePlayerMark(source,"@ov_jiefan")
		for _,to in sgs.list(targets)do
			to:setTag("ov_jiefan",ToData(true))
			for _,p in sgs.list(room:getAlivePlayers())do
				if p:inMyAttackRange(to)
				and not room:askForCard(p,"Weapon","ov_jiefan0:"..to:objectName(),ToData(to))
				then to:drawCards(1,"ov_jiefan") end
			end
		end
	end
}
ov_jiefanvs = sgs.CreateViewAsSkill{
	name = "ov_jiefan",
	view_as = function(self,cards)
		return ov_jiefanCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:getMark("@ov_jiefan")>0
	end,
}
ov_jiefan = sgs.CreateTriggerSkill{
	name = "ov_jiefan",
	events = {sgs.Dying},
	limit_mark = "@ov_jiefan",
	frequency = sgs.Skill_Limited,
	view_as_skill = ov_jiefanvs,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if player:getMark("@ov_jiefan")<1
		and dying.who:getTag("ov_jiefan"):toBool()
		then
			Skill_msg(self,player)
			room:addPlayerMark(player,"@ov_jiefan")
			dying.who:removeTag("ov_jiefan")
		end
		return false
	end,
}
ov_handang:addSkill(ov_jiefan)

ov_chengpu = sgs.General(extension,"ov_chengpu","wu")
ov_lihuovs = sgs.CreateViewAsSkill{
	name = "ov_lihuo",
	n = 1,
	view_filter = function(self,selected,to_select)
		return not sgs.Self:isJilei(to_select)
		and not to_select:isKindOf("NatureSlash")
		and to_select:isKindOf("Slash")
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = sgs.Sanguosha:cloneCard("fire_slash")
		c:setSkillName("mobilelihuo")
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return CardIsAvailable(player,"fire_slash","mobilelihuo")
	end,
}
ov_lihuo = sgs.CreateTriggerSkill{
	name = "ov_lihuo",
	events = {sgs.Dying,sgs.ChangeSlash,sgs.CardFinished},
	view_as_skill = ov_lihuovs,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event==sgs.Dying
		then
			local dying = data:toDying()
			if dying.who:objectName()~=player:objectName()
			and dying.damage and dying.damage.card
			and dying.damage.card:objectName()=="fire_slash"
			and dying.damage.card:getSkillName()=="mobilelihuo"
			then player:setFlags("ov_lihuo_Dying") end
		elseif event==sgs.ChangeSlash
		then
			local use = data:toCardUse()
			if use.card:isKindOf("NatureSlash") then return end
			if use.card:isKindOf("Slash")
			and player:askForSkillInvoke(self,data,false)
			then
				local fs = dummyCard("fire_slash")
				fs:setSkillName("mobilelihuo")
				if use.card:isVirtualCard() then fs:addSubcards(use.card:getSubcards())
				else fs:addSubcard(use.card:getEffectiveId()) end
				use.card = fs
				local tos = sgs.SPlayerList()
				for c,p in sgs.list(room:getOtherPlayers(player))do
					if CanToCard(fs,player,p,use.to)
					then tos:append(p) end
				end
				if tos:length()>0
				then
					local to = room:askForPlayerChosen(player,tos,self:objectName(),"ov_lihuo0:",true,true)
					if to then use.to:append(to) room:sortByActionOrder(use.to) end
				end
				data:setValue(use)
			end
		else
			local use = data:toCardUse()
			if player:hasFlag("ov_lihuo_Dying")
			and use.card:getSkillName()=="mobilelihuo"
			then
				player:setFlags("-ov_lihuo_Dying")
				Skill_msg(self,player)
				room:loseHp(player)
			end
		end
		return false
	end,
}
ov_lihuobf = sgs.CreateTargetModSkill{
	name = "#ov_lihuobf",
	pattern = "Slash",
	residue_func = function(self,from,card)--额外使用
	end,
	distance_limit_func = function(self,from,card,to)--使用距离
	end,
	extra_target_func = function(self,from,card)--目标数
		if from:hasSkill("ov_lihuo") and card:objectName()=="fire_slash"
		then return 1 end
	end
}
ov_chengpu:addSkill(ov_lihuo)
ov_chengpu:addSkill(ov_lihuobf)
extension:insertRelatedSkills("ov_lihuo", "#ov_lihuobf")
ov_chunlao = sgs.CreateTriggerSkill{
	name = "ov_chunlao",
	events = {sgs.Dying,sgs.EventPhaseProceeding},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event==sgs.Dying
		then
			local dying = data:toDying()
			local ov_chun = dying.who:getPile("ov_chun")
			if ov_chun:length()>0
			and ToSkillInvoke(self,player,dying.who)
			then
				room:broadcastSkillInvoke("chunlao",2)
				local dc = dummyCard()
				dc:addSubcards(ov_chun)
				room:throwCard(dc,nil)
				player:drawCards(1,"ov_chunlao")
				room:recover(dying.who,sgs.RecoverStruct(player))
			end
		elseif event==sgs.EventPhaseProceeding
		then
			if player:getPhase()~=sgs.Player_Start then return end
			local tos = sgs.SPlayerList()
			for c,p in sgs.list(room:getAllPlayers())do
				if p:getCardCount(true,true)>0
				then tos:append(p) end
				if p:getPile("ov_chun"):length()>0
				then return end
			end
			if tos:length()>0
			then
				tos = room:askForPlayerChosen(player,tos,self:objectName(),"ov_chunlao0:",true,true)
				if tos
				then
					local id = room:askForCardChosen(player,tos,"hej",self:objectName())
					if id>=0 then tos:addToPile("ov_chun",id) end
					room:broadcastSkillInvoke("chunlao",1)
				end
			end
		end
		return false
	end,
}
ov_chunlaobf = sgs.CreateTriggerSkill{
	name = "#ov_chunlaobf",
	events = {sgs.ConfirmDamage,sgs.CardUsed},
	can_trigger = function(self,target)
		return target and target:getPile("ov_chun"):length()>0
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event==sgs.ConfirmDamage
		then
		    local damage = data:toDamage()
			if damage.card and damage.card:hasFlag("ov_chunlaobf")
			then
				Skill_msg("ov_chunlao",player)
				return DamageRevises(data,1,player)
			end
		elseif event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
			and player:getCardCount()>0
			then
				local tos = sgs.SPlayerList()
				for c,p in sgs.list(room:getAlivePlayers())do
					if p:hasSkill("ov_chunlao")
					then tos:append(p) end
				end
				if tos:length()>0
				then
					player:setTag("ov_chunlaobf",data)
					tos = room:askForPlayerChosen(player,tos,"ov_chunlaobf","ov_chunlaobf0:",true)
					if tos
					then
						local c = room:askForExchange(player,"ov_chunlaobf",1,1,true,"ov_chunlaobf1:"..tos:objectName())
						if c
						then
							ToSkillInvoke("ov_chunlao",player,tos,true)
							room:broadcastSkillInvoke("chunlao",3)
							room:giveCard(player,tos,c,"ov_chunlao")
							use.card:setFlags("ov_chunlaobf")
						end
					end
				end
			end
		end
		return false
	end,
}
ov_chengpu:addSkill(ov_chunlao)
ov_chengpu:addSkill(ov_chunlaobf)
extension:insertRelatedSkills("ov_chunlao", "#ov_chunlaobf")

ov_xujing = sgs.General(extension,"ov_xujing","shu",3)
ov_bomingCard = sgs.CreateSkillCard{
	name = "ov_bomingCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		return to_select:objectName()~=from:objectName()
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
		for _,to in sgs.list(targets)do
			room:giveCard(source,to,self,"ov_boming")
		end
	end
}
ov_bomingvs = sgs.CreateViewAsSkill{
	name = "ov_boming",
	n = 1,
	view_filter = function(self,selected,to_select)
		return to_select
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_bomingCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_bomingCard")<2
	end,
}
ov_boming = sgs.CreateTriggerSkill{
	name = "ov_boming",
	events = {sgs.CardsMoveOneTime,sgs.EventPhaseProceeding},
	view_as_skill = ov_bomingvs,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event==sgs.CardsMoveOneTime
		then
			if player:getPhase()==sgs.Player_NotActive
			then return end
	    	local move = data:toMoveOneTime()
			if move.to
			and (not move.from or move.from:objectName()~=move.to:objectName())
			and move.to:objectName()~=player:objectName()
			and move.to_place==sgs.Player_PlaceHand
			then
				local to = BeMan(room,move.to)
				to:addMark("ov_boming-Clear",move.card_ids:length())
			end
		elseif player:getPhase()==sgs.Player_Finish
		then
			local n = 0
			for _,p in sgs.list(room:getOtherPlayers(player))do
				n = n+p:getMark("ov_boming-Clear")
			end
			if n<2 then return end
			Skill_msg(self,player)
			player:drawCards(2,"ov_boming")
		end
		return false
	end,
}
ov_xujing:addSkill(ov_boming)
ov_ejian = sgs.CreateTriggerSkill{
	name = "ov_ejian",
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event==sgs.CardsMoveOneTime
		then
	    	local move = data:toMoveOneTime()
			if move.to and move.from
			and move.from:objectName()==player:objectName()
			and move.to:objectName()~=player:objectName()
			and move.to_place==sgs.Player_PlaceHand
			then
				local to = BeMan(room,move.to)
				for i,id in sgs.list(move.card_ids)do
					i = move.from_places:at(i)
					if i==sgs.Player_PlaceHand
					or i==sgs.Player_PlaceEquip
					then
						i = sgs.Sanguosha:getCard(id)
						local dc = dummyCard()
						for _,c in sgs.list(to:getCards("he"))do
							if c:getType()==i:getType()
							and c:getEffectiveId()~=id
							then dc:addSubcard(c) end
						end
						if dc:subcardsLength()
						and ToSkillInvoke(self,player,to)
						then
							local choice = "ov_ejian1="..i:getType().."+ov_ejian2="..player:objectName()
							choice = room:askForChoice(to,"ov_ejian",choice,ToData(player))
							if choice~="ov_ejian1="..i:getType()
							then room:damage(sgs.DamageStruct("ov_ejian",player,to))
							else room:throwCard(dc,to) end
						end
					end
				end
			end
		end
		return false
	end,
}
ov_xujing:addSkill(ov_ejian)

ov_simashi = sgs.General(extension,"ov_simashi","wei")
ov_simashi:addSkill("baiyi")
ov_jinglveCard = sgs.CreateSkillCard{
	name = "ov_jinglveCard",
--	will_throw = false,
	skill_name = "jinglve",
	filter = function(self,targets,to_select,from)
		return #targets<1
	end,
	on_use = function(self,room,source,targets)
		local names = source:getTag("JinglveTargets"):toString():split("+")
		for i,to in sgs.list(targets)do
			i = room:doGongxin(source,to,to:handCards(),"ov_jinglve")
			if i~=-1
			then
				room:setPlayerMark(to,"ov_sishi_"..source:objectName(),i+1)
				i = sgs.Sanguosha:getCard(i)
				i = "&ov_jinglve+:+"..i:objectName().."+"..i:getSuitString().."_char+"..i:getNumberString()
				local tos = sgs.SPlayerList()
				tos:append(source)
				room:setPlayerMark(to,i,1,tos)
			end
			i = to:objectName()
			if table.contains(names,i) then continue end
			table.insert(names,i)
		end
		source:setTag("JinglveTargets",ToData(table.concat(names,"+")))
	end
}
ov_jinglvevs = sgs.CreateViewAsSkill{
	name = "ov_jinglve",
	view_as = function(self,cards)
		return ov_jinglveCard:clone()
	end,
	enabled_at_play = function(self,player)
		local tos = player:getAliveSiblings()
		tos:append(player)
		for i,p in sgs.list(tos)do
			if player:getMark("ov_sishi_"..player:objectName())<1
			then
				return player:usedTimes("#ov_jinglveCard")<1
			end
		end
	end,
}
ov_jinglve = sgs.CreateTriggerSkill{
	name = "ov_jinglve",
	events = {sgs.JinkEffect,sgs.NullificationEffect,sgs.EventPhaseChanging,sgs.CardUsed},
	view_as_skill = ov_jinglvevs,
	can_trigger = function(self,target)
		return target and target:isAlive()
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
	   	for i,owner in sgs.list(room:findPlayersBySkillName("ov_jinglve"))do
		i = player:getMark("ov_sishi_"..owner:objectName())
		if i<1 then continue end
		if event==sgs.JinkEffect
		or event==sgs.NullificationEffect
		then
			local c = data:toCard()
			if c:getEffectiveId()==i-1
			then
				Skill_msg(self,owner)
				return true
			end
		elseif event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:getEffectiveId()==i-1
			and use.card:getTypeId()>0
			and use.to:length()>0
			then
				Skill_msg(self,owner)
				use.to = sgs.SPlayerList()
				data:setValue(use)
				return true
			end
		elseif event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
				if room:getCardPlace(i-1)~=sgs.Player_PlaceTable
				then
					Skill_msg(self,owner)
					room:obtainCard(owner,i-1)
				end
				i = sgs.Sanguosha:getCard(i-1)
				i = "&ov_jinglve+:+"..i:objectName().."+"..i:getSuitString().."_char+"..i:getNumberString()
				room:setPlayerMark(player,i,0)
				room:setPlayerMark(player,"ov_sishi_"..owner:objectName(),0)
			end
		end
		end
		return false
	end,
}
ov_simashi:addSkill(ov_jinglve)
--ov_simashi:addSkill("shanli")
ov_shanli = sgs.CreateTriggerSkill{
	name = "ov_shanli",
	events = {sgs.EventPhaseProceeding},
	frequency = sgs.Skill_Wake,
	can_trigger = function(self,target)
		return target and target:hasSkill(self) and target:getMark(self:objectName())<1 and target:getPhase()==sgs.Player_Start
		and (target:getTag("BaiyiUsed"):toBool() and #target:getTag("JinglveTargets"):toString():split("+")>1 or target:canWake(self:objectName()))
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event==sgs.EventPhaseProceeding
		then
			room:broadcastSkillInvoke("shanli")
			SkillWakeTrigger(self,player)
			local ls = {}
			for i,l in sgs.list(sgs.Sanguosha:getLords())do
				for _,s in sgs.list(l:getSkillList())do
					if s:isLordSkill()
					then
						table.insert(ls,s:objectName())
					end
				end
			end
			local ts = {}
			for i=1,#ls do
				i = ls[math.random(1,#ls)]
				table.insert(ts,i)
				table.removeOne(ls,i)
				if #ts>2 then break end
			end
			if #ts<1 then return end
			ls = room:askForChoice(player,"ov_shanli",table.concat(ts,"+"))
			local to = PlayerChosen(self,player,nil,"ov_shanli0:"..ls)
			if to:hasLordSkill(ls,true) then return end
			room:acquireSkill(to,ls)
		end
		return false
	end,
}
ov_simashi:addSkill(ov_shanli)

ov_mazhong = sgs.General(extension,"ov_mazhong","shu")
ov_fumanCard = sgs.CreateSkillCard{
	name = "ov_fumanCard",
	will_throw = false,
	skill_name = "fuman",
	filter = function(self,targets,to_select,from)
		return to_select:objectName()~=from:objectName()
		and from:getMark(to_select:objectName().."ov_fuman-PlayClear")<1
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
		for i,to in sgs.list(targets)do
			room:giveCard(source,to,self,"ov_fuman")
    		i = sgs.Sanguosha:cloneCard("slash",self:getSuit(),self:getNumber())
           	i:setSkillName("ov_fuman")
	        local wrap = sgs.Sanguosha:getWrappedCard(self:getEffectiveId())
			wrap:takeOver(i)
			room:notifyUpdateCard(to,self:getEffectiveId(),wrap)
			wrap = to:getTag("ov_fuman_"..source:objectName()):toIntList()
			wrap:append(self:getEffectiveId())
			to:setTag("ov_fuman_"..source:objectName(),ToData(wrap))
			room:addPlayerMark(source,to:objectName().."ov_fuman-PlayClear")
		end
	end
}
ov_fumanvs = sgs.CreateViewAsSkill{
	name = "ov_fuman",
	n = 1,
	view_filter = function(self,selected,to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_fumanCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		for i,p in sgs.list(player:getAliveSiblings())do
			if player:getMark(p:objectName().."ov_fuman-PlayClear")<1
			then return true end
		end
	end,
}
ov_fuman = sgs.CreateTriggerSkill{
	name = "ov_fuman",
	events = {sgs.CardResponded,sgs.CardFinished},
	view_as_skill = ov_fumanvs,
	can_trigger = function(self,target)
		return target and target:isAlive()
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
	   	for i,owner in sgs.list(room:findPlayersBySkillName("ov_fuman"))do
			local ids = player:getTag("ov_fuman_"..owner:objectName()):toIntList()
			if ids:isEmpty() then continue end
			if event==sgs.CardResponded
			then i = data:toCardResponse().m_card
			else i = data:toCardUse().card end
			if ids:contains(i:getEffectiveId())
--			and i:getSkillName()=="ov_fuman"
--			and i:isKindOf("Slash")
			then
				i = room:getTag("damage_caused_"..i:toString()):toDamage()
				if i and i.to then i = 2
				else i = 1 end
				Skill_msg(self,owner)
				owner:drawCards(i,"ov_fuman")
			end
			i = sgs.IntList()
			for _,id in sgs.list(ids)do
				if room:getCardPlace(id)==sgs.Player_PlaceHand
				and room:getCardOwner(id)==player
				then i:append(id) end
			end
			player:setTag("ov_fuman_"..owner:objectName(),ToData(i))
		end
		return false
	end,
}
ov_mazhong:addSkill(ov_fuman)

ov_caozhao = sgs.General(extension,"ov_caozhao","wei")
ov_fuzuanCard = sgs.CreateSkillCard{
	name = "ov_fuzuanCard",
--	will_throw = false,
--	skill_name = "jiefan",
	filter = function(self,targets,to_select,from)
		if #targets>0 then return end
		for _,sk in sgs.list(to_select:getSkillList())do
			if sk:isAttachedLordSkill() then continue end
			if sk:isChangeSkill() then return true end
		end
	end,
	on_use = function(self,room,source,targets)
		for i,to in sgs.list(targets)do
			i = {}
			for _,sk in sgs.list(to:getSkillList())do
				if sk:isAttachedLordSkill() then continue end
				if sk:isChangeSkill() then table.insert(i,sk:objectName()) end
			end
			if #i<1 then continue end
			i = table.concat(i,"+")
			i = room:askForChoice(source,"ov_fuzuan",i)
			local n = to:getChangeSkillState(i)
			n = n<2 and 2 or 1
			local x,tos = n.."_num",sgs.SPlayerList()
			tos:append(to)
			Log_message("$ov_fuzuan10",source,tos,nil,i,x)
	       	room:setChangeSkillState(to,i,n)
		end
	end
}
ov_fuzuanvs = sgs.CreateViewAsSkill{
	name = "ov_fuzuan",
	response_pattern = "@@ov_fuzuan",
	view_as = function(self,cards)
		return ov_fuzuanCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_fuzuanCard")<1
	end,
}
ov_fuzuan = sgs.CreateTriggerSkill{
	name = "ov_fuzuan",
	events = {sgs.Damage,sgs.Damaged},
	view_as_skill = ov_fuzuanvs,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
	    local damage = data:toDamage()
    	if event==sgs.Damage
		and damage.to:objectName()==player:objectName()
		then return end
		local tos = sgs.SPlayerList()
		for _,p in sgs.list(room:getAlivePlayers())do
			for _,sk in sgs.list(p:getSkillList())do
				if sk:isAttachedLordSkill() then continue end
				if sk:isChangeSkill() then tos:append(p) break end
			end
		end
		if tos:isEmpty() then return end
		room:askForUseCard(player,"@@ov_fuzuan","ov_fuzuan0:",-1,sgs.Card_MethodUse,false)
		return false
	end,
}
ov_caozhao:addSkill(ov_fuzuan)
ov_congqi = sgs.CreateTriggerSkill{
	name = "ov_congqi",
	events = {sgs.GameStart},
	frequency = sgs.Skill_Compulsory,
	waked_skills = "ov_feifu",
	on_trigger = function(self,event,player,data,room)
        if event==sgs.GameStart
	    then
			room:sendCompulsoryTriggerLog(player,"ov_congqi",true,true)
			for _,p in sgs.list(room:getAlivePlayers())do
				if p:hasSkill("ov_feifu") then continue end
				room:acquireSkill(p,"ov_feifu")
			end
			if ToSkillInvoke(self,player,nil,ToData("ov_congqi0"))
			then
				room:loseMaxHp(player)
				local to = PlayerChosen(self,player,room:getOtherPlayers(player),"ov_congqi1:")
				room:acquireSkill(to,"ov_fuzuan")
			end
		end
		return false
	end,
}
ov_caozhao:addSkill(ov_congqi)
ov_feifu = sgs.CreateTriggerSkill{
	name = "ov_feifu",
	change_skill = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified,sgs.TargetConfirmed}, 
	on_trigger = function(self,event,player,data,room)
		local use = data:toCardUse()
		if use.card:isKindOf("Slash")
		and use.to:length()==1 then else return end
    	local n = room:getChangeSkillState(player,self:objectName())
		if event==sgs.TargetSpecified then if n<2 then return end
		elseif use.to:contains(player) and n<2 then else return end
		local to = use.to:at(0)
		n = n<2 and 2 or 1
		if to:getCardCount()<1 then return end
		room:sendCompulsoryTriggerLog(player,self:objectName(),true,true,n)
		local c = room:askForCard(to,"..!","ov_feifu0:"..use.from:objectName(),ToData(use.from),sgs.Card_MethodNone)
		room:setChangeSkillState(player,self:objectName(),n)
		c = c or to:getCards("he"):at(0)
		if c
		then
			room:giveCard(to,use.from,c,"ov_feifu")
			if use.from:handCards():contains(c:getEffectiveId())
			and c:isKindOf("EquipCard") and c:isAvailable(use.from)
			then room:askForUseCard(use.from,c:toString(),"ov_feifu1:"..c:objectName()) end
		end
	end
}
addToSkills(ov_feifu)

ov_tianyu = sgs.General(extension,"ov_tianyu","wei")
ov_zhenxi = sgs.CreateTriggerSkill{
	name = "ov_zhenxi",
	events = {sgs.TargetSpecified}, 
	on_trigger = function(self,event,player,data,room)
		local use = data:toCardUse()
		if event==sgs.TargetSpecified
	   	then
			if not use.card:isKindOf("Slash")
			or player:getMark("ov_zhenxi-Clear")>0
		    then return end
			for c,to in sgs.list(use.to)do
				if ToSkillInvoke(self,player,to)
				then
					player:addMark("ov_zhenxi-Clear")
					local can = to:getHp()>player:getHp()
					if not can
					then
						can = true
						for _,p in sgs.list(room:getOtherPlayers(to))do
							if p:getHp()>to:getHp() then can = false break end
						end
					end
					local choice = {}
					if to:getHandcardNum()>0 then table.insert(choice,"ov_zhenxi1") end
					c = sgs.SPlayerList()
					c:append(to)
					if room:canMoveField("ej",c) then table.insert(choice,"ov_zhenxi2") end
					if can and #choice>1 then table.insert(choice,"ov_zhenxi3") end
					if #choice<1 then continue end
					choice = table.concat(choice,"+")
					choice = room:askForChoice(player,"ov_zhenxi",choice)
					if choice=="ov_zhenxi1"
					then
						choice = player:distanceTo(to)
						for i=1,choice do
							if to:isKongcheng() then break end
							local id = room:askForCardChosen(player,to,"h","ov_zhenxi",false,sgs.Card_MethodDiscard)
							if id<0 then continue end
							room:throwCard(id,to,player)
						end
					elseif choice=="ov_zhenxi2"
					then
						choice = sgs.SPlayerList()
						choice:append(to)
						room:moveField(player,"ov_zhenxi",true,"ej",choice)
					else
						choice = player:distanceTo(to)
						for i=1,choice do
							if to:isKongcheng() then break end
							local id = room:askForCardChosen(player,to,"h","ov_zhenxi",false,sgs.Card_MethodDiscard)
							if id<0 then continue end
							room:throwCard(id,to,player)
						end
						choice = sgs.SPlayerList()
						choice:append(to)
						room:moveField(player,"ov_zhenxi",true,"ej",choice)
					end
					break
				end
			end
		end
		return false
	end
}
ov_tianyu:addSkill(ov_zhenxi)
ov_yangshi = sgs.CreateTriggerSkill{
	name = "ov_yangshi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged}, 
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Damaged
	   	then
			local can = true
			room:sendCompulsoryTriggerLog(player,"ov_yangshi",true,true)
			for i,p in sgs.list(room:getOtherPlayers(player))do
				if player:inMyAttackRange(p)
				then continue end
				can = false
			end
			if can
			then
				for c,id in sgs.list(room:getDrawPile())do
					c = sgs.Sanguosha:getCard(id)
					if c:isKindOf("Slash")
					then
						player:obtainCard(c)
						break
					end
				end
			else
				room:addPlayerMark(player,"&ov_yangshi")
			end
		end
		return false
	end
}
ov_tianyu:addSkill(ov_yangshi)
ov_yangshibf = sgs.CreateAttackRangeSkill{
	name = "#ov_yangshibf",
    fixed_func = function(self,target)
		if target:hasSkill("ov_yangshi")
		then return target:getMark("&ov_yangshi") end
		return -1
	end,
}
ov_tianyu:addSkill(ov_yangshibf)
extension:insertRelatedSkills("ov_yangshi", "#ov_yangshibf")

ov_wangcang = sgs.General(extension,"ov_wangcang","wei",3)
ov_kaijiCard = sgs.CreateSkillCard{
	name = "ov_kaijiCard",
--	will_throw = false,
	filter = function(self,targets,to_select,from)
		return #targets<from:getMark("ov_kaiji")
	end,
	on_use = function(self,room,source,targets)
		local can
		for ids,to in sgs.list(targets)do
			ids=to:drawCardsList(1,"ov_kaiji")
			for c,id in sgs.list(ids)do
				c = sgs.Sanguosha:getCard(id)
				if c:getTypeId()~=1
				then can = true end
			end
		end
		if can
		then
			source:drawCardsList(1,"ov_kaiji")
		end
	end
}
ov_kaijivs = sgs.CreateViewAsSkill{
	name = "ov_kaiji",
	response_pattern = "@@ov_kaiji",
	view_as = function(self,cards)
		return ov_kaijiCard:clone()
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_kaiji = sgs.CreateTriggerSkill{
	name = "ov_kaiji",
	events = {sgs.Dying,sgs.EventPhaseProceeding},
	view_as_skill = ov_kaijivs,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event==sgs.Dying
		then
			local dying = data:toDying()
			dying.who:setTag("ov_kaiji",ToData(true))
		elseif player:getPhase()==sgs.Player_Start
		then
			local can = 1
			for i,p in sgs.list(room:getPlayers())do
				if p:getTag("ov_kaiji"):toBool()
				then can = can+1 end
			end
			room:setPlayerMark(player,"ov_kaiji",can)
			room:askForUseCard(player,"@@ov_kaiji","ov_kaiji0:"..can)
		end
		return false
	end,
}
ov_wangcang:addSkill(ov_kaiji)
ov_shepan = sgs.CreateTriggerSkill{
	name = "ov_shepan",
	events = {sgs.TargetConfirmed}, 
	on_trigger = function(self,event,player,data,room)
		local use = data:toCardUse()
		if event==sgs.TargetConfirmed
	   	then
			if use.card:getTypeId()==0
			or not use.to:contains(player)
			or player:getMark("ov_shepan-Clear")>0
			or player:objectName()==use.from:objectName()
		    then return end
			if ToSkillInvoke(self,player,use.from)
			then
				local choice = "ov_shepan1"
				player:addMark("ov_shepan-Clear")
				if use.from:getCardCount(true,true)>0
				then choice = "ov_shepan1+ov_shepan2" end
				choice = room:askForChoice(player,"ov_shepan",choice,data)
				if choice=="ov_shepan1"
				then player:drawCards(1,"ov_shepan")
				else
					choice = room:askForCardChosen(player,use.from,"hej","ov_shepan")
					if choice>=0 then room:moveCardsInToDrawpile(player,choice,"ov_shepan",1) end
				end
				if player:getHandcardNum()==use.from:getHandcardNum()
				then
					player:setTag("ov_shepan",data)
					player:removeMark("ov_shepan-Clear")
					if ToSkillInvoke(self,player,nil,ToData("ov_shepan0:"..use.card:objectName()))
					then
						choice = use.nullified_list
						table.insert(choice,player:objectName())
						use.nullified_list = choice
						data:setValue(use)
					end
				end
			end
		end
		return false
	end
}
ov_wangcang:addSkill(ov_shepan)

ov_wujing = sgs.General(extension,"ov_wujing","wu")
ov_fenghanCard = sgs.CreateSkillCard{
	name = "ov_fenghanCard",
--	will_throw = false,
	filter = function(self,targets,to_select,from)
		return #targets<from:getMark("ov_fenghan")
	end,
	on_use = function(self,room,source,targets)
		for ids,to in sgs.list(targets)do
			to:drawCardsList(1,"ov_fenghan")
		end
	end
}
ov_fenghanvs = sgs.CreateViewAsSkill{
	name = "ov_fenghan",
	response_pattern = "@@ov_fenghan",
	view_as = function(self,cards)
		return ov_fenghanCard:clone()
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_fenghan = sgs.CreateTriggerSkill{
	name = "ov_fenghan",
	events = {sgs.TargetConfirmed}, 
	view_as_skill = ov_fenghanvs,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.TargetConfirmed
	   	then
			local use = data:toCardUse()
			if not use.from or player:getMark("ov_fenghan-Clear")>0
			or player:objectName()~=use.from:objectName()
		    then return end
			if use.card:isKindOf("Slash")
			or use.card:isKindOf("TrickCard") and use.card:isDamageCard()
			then
				room:setPlayerMark(player,"ov_fenghan",use.to:length())
				if room:askForUseCard(player,"@@ov_fenghan","ov_fenghan0:"..use.to:length())
				then player:addMark("ov_fenghan-Clear") end
			end
		end
		return false
	end
}
ov_wujing:addSkill(ov_fenghan)
ov_congji = sgs.CreateTriggerSkill{
	name = "ov_congji",
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.CardsMoveOneTime
		then
	    	local move = data:toMoveOneTime()
			if move.from and move.card_ids:length()>0
			and move.to_place==sgs.Player_DiscardPile
			and player:getPhase()==sgs.Player_NotActive
			and move.from:objectName()==player:objectName()
			and bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON)==sgs.CardMoveReason_S_REASON_DISCARD
			then
				local d = dummyCard()
				for i,id in sgs.list(move.card_ids)do
					if move.from_places:at(i)==sgs.Player_PlaceHand
					or move.from_places:at(i)==sgs.Player_PlaceEquip
					then
						if sgs.Sanguosha:getCard(id):isRed()
						and room:getCardPlace(id)==move.to_place
						then d:addSubcard(id) end
					end
				end
				if d:subcardsLength()<1 then return end
				local to = room:askForPlayerChosen(player,room:getOtherPlayers(player),self:objectName(),"ov_congji0:",true,true)
				if to then room:broadcastSkillInvoke(self:objectName()) room:obtainCard(to,d) end
			end
		end
		return false
	end
}
ov_wujing:addSkill(ov_congji)

ov_zhouchu = sgs.General(extension,"ov_zhouchu","wu")
ov_guoyi = sgs.CreateTriggerSkill{
	name = "ov_guoyi",
	events = {sgs.CardFinished,sgs.TargetSpecified},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if use.card:hasFlag("ov_guoyi")
			then
				Skill_msg(self,player)
				use.card:setFlags("-ov_guoyi")
				use.card:setFlags("ov_guoyiCard")
				use.card:cardOnUse(room,use)
				use.card:setFlags("-ov_guoyiCard")
			end
		elseif event==sgs.TargetSpecified
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
			or use.card:isNDTrick()
			then
				if use.card:hasFlag("ov_guoyiCard") then return end
				for i,to in sgs.list(use.to)do
					if player:objectName()==to:objectName() then continue end
					local hn,hp,x = true,true,player:getLostHp()+1
					for _,p in sgs.list(room:getOtherPlayers(to))do
						if p:getHandcardNum()>to:getHandcardNum()
						then hn = false end
						if p:getHp()>to:getHp()
						then hp = false end
					end
					if (hn or hp or player:getHandcardNum()<=x)
					and ToSkillInvoke(self,player,to)
					then
						if to:getCardCount()>=x
						and room:askForDiscard(to,"ov_guoyi",x,x,true,true,"ov_guoyi0:"..x)
						then to:addMark("ov_guoyi0-Clear")
						elseif to:getMark("ov_guoyidebf-Clear")<1
						then
							to:addMark("ov_guoyidebf-Clear")
							room:setPlayerCardLimitation(to,"use,response",".|.|.|hand",false)
						end
						if (hn or hp ) and player:getHandcardNum()<=x
						or to:getMark("ov_guoyi0-Clear")>0 and to:getMark("ov_guoyidebf-Clear")>0
						then use.card:setFlags("ov_guoyi") end
					end
				end
			end
		end
		return false
	end
}
ov_guoyidebf = sgs.CreateTriggerSkill{
	name = "#ov_guoyidebf",
	events = {sgs.EventPhaseChanging},
	can_trigger = function(self,target)
		if target and target:isAlive()
		then
			for _,p in sgs.list(target:getRoom():getAlivePlayers())do
				if p:getMark("ov_guoyidebf-Clear")>0 then return true end
			end
		end
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			or change.from==sgs.Player_NotActive
			then
				for _,p in sgs.list(room:getAlivePlayers())do
					if p:getMark("ov_guoyidebf-Clear")<1 then continue end
					room:removePlayerCardLimitation(p,"use,response",".|.|.|hand")
					p:removeMark("ov_guoyidebf-Clear")
				end
			end
		end
	end
}
ov_zhouchu:addSkill(ov_guoyi)
ov_zhouchu:addSkill(ov_guoyidebf)
extension:insertRelatedSkills("ov_guoyi", "#ov_guoyidebf")
ov_chuhai = sgs.CreateTriggerSkill{
	name = "ov_chuhai",
    shiming_skill = true,
	events = {sgs.Dying,sgs.CardsMoveOneTime},
	on_trigger = function(self,event,player,data,room)
		if player:getTag("ov_chuhai_shiming"):toBool()
		then return end
		if event==sgs.Dying
		then
			local dying = data:toDying()
			local damage = dying.damage
			if dying.who:objectName()==player:objectName() then return end
			if damage and damage.from and damage.from:objectName()==player:objectName()
			then dying.who:setTag("ov_chuhai"..player:objectName(),ToData(true)) end
			local hplost = dying.hplost
			if hplost and hplost.from and hplost.from:objectName()==player:objectName()
			then dying.who:setTag("ov_chuhai"..player:objectName(),ToData(true)) end
			local n = 0
			for _,p in sgs.list(room:getPlayers())do
				if p:getTag("ov_chuhai"..player:objectName()):toBool()
				then n = n+1 end
			end
			if n>1
			then
				ShimingSkillDoAnimate("ov_chuhai",player,true)
				player:setTag("ov_chuhai_shiming",ToData(true))
				player:addMark("ov_chuhai_shiming-Clear")
			end
		else
	     	local move = data:toMoveOneTime()
			if move.to and move.to:objectName()==player:objectName()
			and move.from and move.from:objectName()~=player:objectName()
			and move.reason.m_reason==sgs.CardMoveReason_S_REASON_GIVE
			and move.to_phase==sgs.Player_PlaceHand
			then
				local ids = {}
				for _,id in sgs.list(move.card_ids)do
					if player:handCards():contains(id)
					then table.insert(ids,id) end
				end
				if #ids<1 then return end
				Skill_msg(self,player,3)
				local c = room:askForCard(player,table.concat(ids,",").."!","ov_chuhai0:",data,sgs.Card_MethodNone)
				if not c then c = sgs.Sanguosha:getCard(ids[1]) end
				room:moveCardTo(c,nil,sgs,Player_DiscardPile)
			end
		end
		return false
	end
}
ov_chuhaibf = sgs.CreateTriggerSkill{
	name = "#ov_chuhaibf",
	events = {sgs.EventPhaseChanging},
	can_trigger = function(self,target)
		return target and target:isAlive()
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
				for _,owner in sgs.list(room:findPlayersBySkillName("ov_chuhai"))do
					if owner:getMark("ov_chuhai_shiming-Clear")<1 then continue end
					owner:throwJudgeArea()
					for c,p in sgs.list(room:getOtherPlayers(owner))do
						if p:getCardCount()<1 then continue end
						c = room:askForExchange(p,"ov_chuhai",1,1,true,"ov_chuhai1:"..owner:objectName())
						room:giveCard(p,owner,c,"ov_chuhai")
					end
				end
			end
		end
	end
}
ov_zhouchu:addSkill(ov_chuhai)
ov_zhouchu:addSkill(ov_chuhaibf)
extension:insertRelatedSkills("ov_chuhai", "#ov_chuhaibf")

ov_wangcan = sgs.General(extension,"ov_wangcan","wei",3)
ov_dianyi = sgs.CreateTriggerSkill{
	name = "ov_dianyi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damage,sgs.EventPhaseChanging}, 
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Damage
	   	then
			if player:getPhase()~=sgs.Player_NotActive
			then player:addMark("ov_dianyi-Clear") end
		else
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
				room:sendCompulsoryTriggerLog(player,"ov_dianyi",true,true)
				if player:getMark("ov_dianyi-Clear")<1
				then PlayerHandcardNum(player,self,4)
				else player:throwAllHandCards() end
			end
		end
		return false
	end
}
ov_wangcan:addSkill(ov_dianyi)
ov_yingjiCard = sgs.CreateSkillCard{
	name = "ov_yingjiCard",
	will_throw = false,
	filter = function(self,targets,to_select,player)
		local pattern = self:getUserString()
		if pattern=="normal_slash" then pattern = "slash" end
		return SCfilter(pattern,targets,to_select,nil,"ov_yingji")
	end,
	feasible = function(self,targets)
		local pattern = self:getUserString()
		if pattern=="normal_slash" then pattern = "slash" end
		return SCfeasible(pattern,targets,nil,"ov_yingji")
	end,
	on_validate = function(self,use)
		local to_guhuo = self:getUserString()
		NotifySkillInvoked("ov_yingji",use.from,use.to,false)
		to_guhuo = use.from:getRoom():askForChoice(use.from,"ov_yingji",to_guhuo)
		local use_card = sgs.Sanguosha:cloneCard(to_guhuo)
		use_card:setSkillName("_ov_yingji")
		use.from:drawCards(1,"ov_yingji")
		return use_card
	end,
	on_validate_in_response = function(self,yuji)
		local to_guhuo = self:getUserString()
		NotifySkillInvoked("ov_yingji",yuji,nil,false)
		to_guhuo = yuji:getRoom():askForChoice(yuji,"ov_yingji",to_guhuo)
		local use_card = sgs.Sanguosha:cloneCard(to_guhuo)
		use_card:setSkillName("_ov_yingji")
		yuji:drawCards(1,"ov_yingji")
		return use_card
	end
}
ov_yingji = sgs.CreateViewAsSkill{
	name = "ov_yingji",	
	view_as = function(self,cards)
		local card = ov_yingjiCard:clone()
		card:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
		return card
	end,
	enabled_at_response = function(self,player,pattern)
		if string.sub(pattern,1,1)=="."
		or string.sub(pattern,1,1)=="@"
		or pattern=="peach" and player:getMark("Global_PreventPeach")>0
		then return end
		local card = PatternsCard(pattern:split("+"))
		if card and player:isKongcheng()
		and player:getPhase()==sgs.Player_NotActive
		and (card:getTypeId()==1 or card:isNDTrick())
		then return true end
	end,
	enabled_at_play = function(self,player)				
		return player:isKongcheng()
		and player:getPhase()==sgs.Player_NotActive
	end,
	enabled_at_nullification = function(self,player)
		return player:isKongcheng()
		and player:getPhase()==sgs.Player_NotActive
	end
}
ov_wangcan:addSkill(ov_yingji)
ov_shanghe = sgs.CreateTriggerSkill{
	name = "ov_shanghe",
	events = {sgs.Dying},
	limit_mark = "@ov_shanghe",
	frequency = sgs.Skill_Limited,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if player:getMark("@ov_shanghe")>0
		and dying.who:objectName()==player:objectName()
		and player:askForSkillInvoke(self:objectName(),data,false)
		then
			NotifySkillInvoked(self,player,room:getOtherPlayers(player))
			room:doSuperLightbox(player:getGeneralName(),"ov_shanghe")
			room:removePlayerMark(player,"@ov_shanghe")
			local can = true
			for c,to in sgs.list(room:getOtherPlayers(player))do
				if to:getCardCount()<1 then continue end
				c = room:askForCard(to,"..!","ov_shanghe0:"..player:objectName(),ToData(player),sgs.Card_MethodNone)
				if c
				then
					room:giveCard(to,player,c,"ov_shanghe")
					if c:isKindOf("Analeptic")
					then can = false end
				end
			end
			if can
			then
				room:recover(player,sgs.RecoverStruct(player,nil,1-player:getHp()))
			end
		end
		return false
	end,
}
ov_wangcan:addSkill(ov_shanghe)

ov_huojun = sgs.General(extension,"ov_huojun","shu")
ov_sidaivs = sgs.CreateViewAsSkill{
	name = "ov_sidai",
	response_pattern = "@@ov_sidai",
	view_as = function(self,cards)
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:setSkillName("ov_sidai")
		for _,c in sgs.list(sgs.Self:getHandcards())do
			if c:getTypeId()==1 then slash:addSubcard(c) end
		end
		slash:setFlags("ov_sidai")
		return slash
	end,
	enabled_at_play = function(self,player)
		return CardIsAvailable(player,"slash","ov_sidai")
		and player:getMark("@ov_sidai")>0
	end,
}
ov_sidai = sgs.CreateTriggerSkill{
	name = "ov_sidai",
	events = {sgs.PreCardUsed,sgs.CardUsed,sgs.DamageCaused,sgs.Damage}, 
	view_as_skill = ov_sidaivs,
	limit_mark = "@ov_sidai",
	frequency = sgs.Skill_Limited,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.PreCardUsed
	   	then
			local use = data:toCardUse()
			if use.card:getSkillName()~="ov_sidai"
			and not use.card:hasFlag("ov_sidai") then return end
			room:doSuperLightbox(player:getGeneralName(),"ov_sidai")
			room:removePlayerMark(player,"@ov_sidai")
		elseif event==sgs.CardUsed
	   	then
			local use = data:toCardUse()
			if use.card:getSkillName()~="ov_sidai"
			and not use.card:hasFlag("ov_sidai")
		    then return end
			local nsl
			for c,id in sgs.list(use.card:getSubcards())do
				c = sgs.Sanguosha:getCard(id)
				if c:isKindOf("Jink")
				then nsl = true end
			end
			if not nsl then return end
			Skill_msg(self,player)
			nsl = use.no_respond_list
			for c,to in sgs.list(use.to)do
				if room:askForCard(to,"BasicCard","ov_sidai0:"..use.card:objectName(),ToData(player))
				then else table.insert(nsl,to:objectName()) end
			end
			use.no_respond_list = nsl
			data:setValue(use)
		elseif event==sgs.Damage
	   	then
		    local damage = data:toDamage()
        	if damage.card
			and (damage.card:getSkillName()=="ov_sidai" or damage.card:hasFlag("ov_sidai"))
        	then
				local nsl
				for c,id in sgs.list(damage.card:getSubcards())do
					c = sgs.Sanguosha:getCard(id)
					if c:isKindOf("Peach")
					then nsl = true end
				end
				if not nsl then return end
				Skill_msg(self,player)
				room:loseMaxHp(damage.to)
			end
		elseif event==sgs.DamageCaused
	   	then
		    local damage = data:toDamage()
        	if damage.card
			and (damage.card:getSkillName()=="ov_sidai" or damage.card:hasFlag("ov_sidai"))
        	then
				local nsl
				for c,id in sgs.list(damage.card:getSubcards())do
					c = sgs.Sanguosha:getCard(id)
					if c:isKindOf("Analeptic")
					then nsl = true end
				end
				if not nsl then return end
				Skill_msg(self,player)
				DamageRevises(data,damage.damage,player)
			end
		end
		return false
	end
}
ov_sidaibf = sgs.CreateTargetModSkill{
	name = "#ov_sidaibf",
	pattern = "Slash",
	residue_func = function(self,from,card)--额外使用
		if from:hasSkill("ov_sidai") and (card:getSkillName()=="ov_sidai" or card:hasFlag("ov_sidai"))
		then return 998 end
	end,
	distance_limit_func = function(self,from,card,to)--使用距离
		if from:hasSkill("ov_sidai") and (card:getSkillName()=="ov_sidai" or card:hasFlag("ov_sidai"))
		then return 998 end
	end,
	extra_target_func = function(self,from,card)--目标数
	end
}
ov_huojun:addSkill(ov_sidai)
ov_huojun:addSkill(ov_sidaibf)
extension:insertRelatedSkills("ov_sidai", "#ov_sidaibf")
ov_jieyu = sgs.CreateTriggerSkill{
	name = "ov_jieyu",
--	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged,sgs.EventPhaseProceeding,sgs.RoundStart}, 
	on_trigger = function(self,event,player,data,room)
		if event==sgs.RoundStart then player:setMark("ov_jieyu_lun",0) end
		if player:getMark("ov_jieyu_lun")>0 then return end
		local can
		if event==sgs.Damaged
	   	then
			player:addMark("ov_jieyu_lun")
			if ToSkillInvoke(self,player)
			then can = true end
		elseif player:getPhase()==sgs.Player_Finish
		then
			if ToSkillInvoke(self,player)
			then
				player:addMark("ov_jieyu_lun")
				can = true
			end
		end
		if can
		then
			can = {}
			local dp = {}
			local dc = dummyCard()
			player:throwAllHandCards()
			for c,id in sgs.list(room:getDiscardPile())do
				table.insert(dp,sgs.Sanguosha:getCard(id))
			end
			for i,c in sgs.list(RandomList(dp))do
				if table.contains(can,c:objectName())
				then continue end
				if c:isKindOf("BasicCard")
				then dc:addSubcard(c) end
				table.insert(can,c:objectName())
			end
			if dc:subcardsLength()>0
			then room:obtainCard(player,dc) end
		end
		return false
	end
}
ov_huojun:addSkill(ov_jieyu)

ov_niujin = sgs.General(extension,"ov_niujin","wei")
ov_cuorui = sgs.CreateTriggerSkill{
	name = "ov_cuorui",
	frequency = sgs.Skill_Limited,
	limit_mark = "@ov_cuorui",
	events = {sgs.EventPhaseProceeding}, 
	on_trigger = function(self,event,player,data,room)
		if player:getPhase()~=sgs.Player_Start
		or player:getMark("@ov_cuorui")<1
		or not ToSkillInvoke(self,player)
		then return end
		room:broadcastSkillInvoke("cuorui")
		room:removePlayerMark(player,"@ov_cuorui")
		local n = player:getHandcardNum()
		for i,p in sgs.list(room:getAlivePlayers())do
			i = p:getHandcardNum()
			if i>n then n = i end
		end
		n = n-player:getHandcardNum()
		n = n>5 and 5 or n
		player:drawCards(n,"ov_cuorui")
		if player:hasJudgeArea()
		then player:throwJudgeArea()
		else
			n = PlayerChosen(self,player,room:getOtherPlayers(player),"ov_cuorui0:")
			room:damage(sgs.DamageStruct("ov_cuorui",player,n))
		end
		return false
	end
}
ov_niujin:addSkill(ov_cuorui)
ov_liewei = sgs.CreateTriggerSkill{
	name = "ov_liewei",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Death}, 
	on_trigger = function(self,event,player,data,room)
		local death = data:toDeath()
		if death.damage and death.damage.from
		and death.damage.from:objectName()==player:objectName()
		then
			room:sendCompulsoryTriggerLog(player,"ov_liewei",true)
			room:broadcastSkillInvoke("liewei")
			local choice = "ov_liewei1"
			if player:hasSkill("ov_cuorui") and player:getMark("@ov_cuorui")<1
			then choice = "ov_liewei1+ov_liewei2" end
			if room:askForChoice(player,"ov_liewei",choice,data)~="ov_liewei1"
			then room:addPlayerMark(player,"@ov_cuorui")
			else player:drawCards(2,"ov_liewei") end
		end
		return false
	end
}
ov_niujin:addSkill(ov_liewei)

ov_liufuren = sgs.General(extension,"ov_liufuren","qun",3,false)
ov_zhuiduCard = sgs.CreateSkillCard{
	name = "ov_zhuiduCard",
--	will_throw = false,
	filter = function(self,targets,to_select,from)
		return #targets<1
		and to_select:isWounded()
		and to_select:objectName()~=from:objectName()
	end,
	on_use = function(self,room,source,targets)
		for i,to in sgs.list(targets)do
			i = {"ov_zhuidu1"}
			if to:hasEquip() then table.insert(i,"ov_zhuidu2") end
			if to:isFemale() and source:getCardCount()>0 and #i>1
			then table.insert(i,"beishui_choice=ov_zhuidu3") end
			i = table.concat(i,"+")
			i = room:askForChoice(source,"ov_zhuidu",i)
			if i=="ov_zhuidu1"
			then room:damage(sgs.DamageStruct(self,source,to))
			elseif i=="ov_zhuidu2"
			then
				local id = room:askForCardChosen(source,to,"e","ov_zhuidu",false,sgs.Card_MethodDiscard)
				if id<0 then continue end
				room:throwCard(id,to,source)
			else
				room:askForDiscard(source,"ov_zhuidu",1,1,false,true)
				room:damage(sgs.DamageStruct(self,source,to))
				if to:isDead() or not to:hasEquip() then continue end
				local id = room:askForCardChosen(source,to,"e","ov_zhuidu",false,sgs.Card_MethodDiscard)
				if id<0 then continue end
				room:throwCard(id,to,source)
			end
		end
	end
}
ov_zhuidu = sgs.CreateViewAsSkill{
	name = "ov_zhuidu",
	response_pattern = "@@ov_zhuidu",
	view_as = function(self,cards)
		return ov_zhuiduCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_zhuiduCard")<1
	end,
}
ov_liufuren:addSkill(ov_zhuidu)
ov_shigong = sgs.CreateTriggerSkill{
	name = "ov_shigong",
	events = {sgs.Dying},
	limit_mark = "@ov_shigong",
	frequency = sgs.Skill_Limited,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		local target = room:getCurrent()
		if player:getMark("@ov_shigong")>0
		and dying.who:objectName()==player:objectName()
		and player:getPhase()==sgs.Player_NotActive
		and ToSkillInvoke(self,player,target)
		then
			room:doSuperLightbox(player:getGeneralName(),"ov_shigong")
			room:removePlayerMark(player,"@ov_shigong")
			dying = {"ov_shigong1="..player:objectName()}
			if target:getHandcardNum()>=target:getHp()
			then table.insert(dying,"ov_shigong2="..player:objectName()) end
			dying = table.concat(dying,"+")
			dying = room:askForChoice(target,"ov_shigong",dying,ToData(player))
			if dying:startsWith("ov_shigong1")
			then
				room:gainMaxHp(target)
				room:recover(target,sgs.RecoverStruct(target))
				target:drawCards(1,"ov_shigong")
				room:recover(player,sgs.RecoverStruct(target,nil,player:getMaxHp()-player:getHp()))
			else
				dying = target:getHp()
				room:askForDiscard(target,"ov_shigong",dying,dying)
				room:recover(player,sgs.RecoverStruct(target,nil,1-player:getHp()))
			end
		end
		return false
	end,
}
ov_liufuren:addSkill(ov_shigong)

ov_mateng = sgs.General(extension,"ov_mateng$","qun")
ov_mateng:addSkill("mashu")
ov_xiongzhengCard = sgs.CreateSkillCard{
	name = "ov_xiongzhengCard",
--	will_throw = false,
	mute = true,
	filter = function(self,targets,to_select,from)
		local tos = from:getAliveSiblings()
		tos:append(from)
		for i,p in sgs.list(tos)do
			if p:getMark("&ov_xiongzheng+to+#"..from:objectName())>0
			then
				i = to_select:getMark("&ov_xiongzheng+damage+#"..p:objectName())
				if to_select:objectName()==from:objectName()
				then return i>0 end
				local d = dummyCard()
				d:setSkillName("_ov_xiongzheng")
				if i<1 and from:isProhibited(to_select,d)
				then return end
				if #targets>0
				then
					if targets[1]:getMark("&ov_xiongzheng+damage+#"..p:objectName())>0
					then return i>0 end
					return i<1
				end
				return true
			end
		end
	end,
	on_effect = function(self,effect)
		local room,to,from = effect.to:getRoom(),effect.to,effect.from
		local xzto = from:getTag("ov_xiongzheng"):toPlayer()
		if to:getMark("&ov_xiongzheng+damage+#"..xzto:objectName())>0
		then
			room:broadcastSkillInvoke("ov_xiongzheng")--播放配音
			to:drawCards(2,"ov_xiongzheng")
		else
			xzto = dummyCard()
			xzto:setSkillName("_ov_xiongzheng")
			room:useCard(sgs.CardUseStruct(xzto,from,to))
		end
	end
}
ov_xiongzhengvs = sgs.CreateViewAsSkill{
	name = "ov_xiongzheng",
	response_pattern = "@@ov_xiongzheng",
	view_as = function(self,cards)
		return ov_xiongzhengCard:clone()
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_xiongzheng = sgs.CreateTriggerSkill{
	name = "ov_xiongzheng",
	view_as_skill = ov_xiongzhengvs,
	events = {sgs.RoundStart,sgs.RoundEnd},
	on_trigger = function(self,event,player,data,room)
		local to = player:getTag("ov_xiongzheng"):toPlayer()
		if event==sgs.RoundStart
	   	then
			to = sgs.SPlayerList()
			for i,p in sgs.list(room:getAlivePlayers())do
				if p:getMark("ov_xiongzheng_"..player:objectName())<1
				then to:append(p) end
			end
			if to:isEmpty() then return end
			to = room:askForPlayerChosen(player,to,"ov_xiongzheng","ov_xiongzheng1:",true,true)
			if not to then return end
			room:broadcastSkillInvoke(self:objectName())
			to:addMark("ov_xiongzheng_"..player:objectName())
			room:setPlayerMark(to,"&ov_xiongzheng+to+#"..player:objectName(),1)
			player:setTag("ov_xiongzheng",ToData(to))
		elseif to
		then
			room:askForUseCard(player,"@@ov_xiongzheng","ov_xiongzheng0:")
			for i,p in sgs.list(room:getAlivePlayers())do
				room:setPlayerMark(p,"&ov_xiongzheng+damage+#"..to:objectName(),0)
			end
			if to:isAlive()
			then
				room:setPlayerMark(to,"&ov_xiongzheng+to+#"..player:objectName(),0)
			end
			player:removeTag("ov_xiongzheng")
		end
		return false
	end
}
ov_xiongzhengbf = sgs.CreateTriggerSkill{
	name = "#ov_xiongzhengbf",
--	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged}, 
	can_trigger = function(self,target)
		if target and target:isAlive()
		then
			local room = target:getRoom()
			for _,owner in sgs.list(room:findPlayersBySkillName("ov_xiongzheng"))do
				if target:getMark("&ov_xiongzheng+to+#"..owner:objectName())>0
				then return true end
			end
		end
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Damaged
	   	then
		    local damage = data:toDamage()
			if damage.from and damage.from:isAlive()
			then
				room:setPlayerMark(damage.from,"&ov_xiongzheng+damage+#"..player:objectName(),1)
			end
		end
		return false
	end
}
ov_mateng:addSkill(ov_xiongzheng)
ov_mateng:addSkill(ov_xiongzhengbf)
extension:insertRelatedSkills("ov_xiongzheng", "#ov_xiongzhengbf")
ov_luannianCard = sgs.CreateSkillCard{
	name = "ov_luannianCard",
	skill_name = "_ov_luannian",
--	will_throw = false,
	filter = function(self,targets,to_select,from)
		if #targets>0 then return end
		if to_select:hasLordSkill("ov_luannian")
		and self:subcardsLength()==to_select:getMark("&ov_luannian")
		and to_select:getMark("ov_luannian-PlayClear")<1
		then
			local tos = to_select:getAliveSiblings()
			tos:append(to_select)
			for i,p in sgs.list(tos)do
				if p:getMark("&ov_xiongzheng+to+#"..to_select:objectName())>0
				then return true end
			end
		end
	end,
	about_to_use = function(self,room,use)
		local Lord = use.to:at(0)
--		room:broadcastSkillInvoke("ov_luannian")--播放配音
		room:doAnimate(1,use.from:objectName(),Lord:objectName())
		room:notifySkillInvoked(Lord,"ov_luannian")
		local msg = sgs.LogMessage()
		msg.type = "$bf_huangtian0"
		msg.from = use.from
		msg.arg = Lord:getGeneralName()
		msg.arg2 = "ov_luannian"
		room:sendLog(msg)
		room:addPlayerMark(Lord,"&ov_luannian")
		room:addPlayerMark(Lord,"ov_luannian-PlayClear")
		local to = Lord:getTag("ov_xiongzheng"):toPlayer()
		if to and to:isAlive()
		then
			Lord = sgs.SPlayerList()
			Lord:append(to)
			use.to = Lord
			self:cardOnUse(room,use)
			room:damage(sgs.DamageStruct(self,use.from,to))
		end
	end
}
ov_luannianVS = sgs.CreateViewAsSkill{
	name = "ov_luannianvs&",
	n = 998,
	view_filter = function(self,selected,to_select)
		return sgs.Self:canDiscard(sgs.Self,to_select:getEffectiveId())
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_luannianCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return c
	end,
	enabled_at_play = function(self,player)
	   	for _,p in sgs.list(player:getAliveSiblings())do
			if p:hasLordSkill("ov_luannian")
			and p:getMark("ov_luannian-PlayClear")<1
			then return  player:getKingdom()=="qun" end
		end
	end,
}
ov_luannian = sgs.CreateTriggerSkill{
	name = "ov_luannian$",
	events = {sgs.EventAcquireSkill,sgs.CardsMoveOneTime,sgs.RoundStart},
	can_trigger = function(self,target)
		return target and target:hasLordSkill(self)
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		for _,p in sgs.list(room:getLieges("qun",player))do
			if p:hasSkill("ov_luannianvs") then continue end
			room:attachSkillToPlayer(p,"ov_luannianvs")
		end
		if event==sgs.RoundStart
	   	then
			room:setPlayerMark(player,"&ov_luannian",0)
		end
	end,
}
ov_mateng:addSkill(ov_luannian)
addToSkills(ov_luannianVS)

ov_jiling = sgs.General(extension,"ov_jiling","qun")
ov_shuangren = sgs.CreateTriggerSkill{
	name = "ov_shuangren",
	events = {sgs.EventPhaseStart,sgs.EventPhaseEnd,sgs.CardFinished},
	on_trigger = function(self,event,player,data,room)
		if player:getPhase()~=sgs.Player_Play then return end
		if event==sgs.CardFinished
	   	then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
		    then
				local damage = room:getTag("damage_caused_"..use.card:toString()):toDamage()
				if damage and damage.to then player:addMark("ov_shuangren-PlayClear") end
			end
			return
		end
		local tos,to = sgs.SPlayerList(),nil
		for i,p in sgs.list(room:getOtherPlayers(player))do
			if player:canPindian(p)
			then tos:append(p) end
		end
		if tos:isEmpty() then return end
		if event==sgs.EventPhaseStart
		or player:getMark("ov_shuangren-PlayClear")<1 and room:askForCard(player,"..","ov_shuangren2:",data,"ov_shuangren")
	   	then to = room:askForPlayerChosen(player,tos,"ov_shuangren","ov_shuangren0:",event==sgs.EventPhaseStart,true) end
		if not to then return end
		player:addMark("ov_shuangren-PlayClear")
		room:broadcastSkillInvoke("shuangren")
		if player:pindian(to,"ov_shuangren")
		then
			local to_s = sgs.SPlayerList()
			for i,p in sgs.list(room:getAlivePlayers())do
				if to:distanceTo(p)<2
				then to_s:append(p) end
			end
			to_s = room:askForPlayersChosen(player,to_s,"ov_shuangren",0,2,"ov_shuangren1:"..to:objectName(),true,true)
			for i,p in sgs.list(to_s)do
				i = dummyCard()
				i:setSkillName("_shuangren")
				room:useCard(sgs.CardUseStruct(i,player,p))
			end
		elseif ToSkillInvoke(self,to,player,ToData("ov_shuangren3:"..player:objectName()))
		then
			local dc = dummyCard()
			dc:setSkillName("_shuangren")
			room:useCard(sgs.CardUseStruct(dc,to,player))
		end
		return false
	end
}
ov_jiling:addSkill(ov_shuangren)

ov_jianshuo = sgs.General(extension,"ov_jianshuo","qun",6)
ov_xiongsiCard = sgs.CreateSkillCard{
	name = "ov_xiongsiCard",
--	will_throw = false,
	filter = function(self,targets,to_select,from)
		if #targets>0 or to_select:getMark("ov_xiongsi")>0 then return end
		return SCfilter("slash",targets,to_select,self,"ov_xiongsi")
	end,
	about_to_use = function(self,room,use)
		use.card = dummyCard()
		use.card:setSkillName("ov_xiongsi")
		use.card:setFlags("ov_xiongsi")
		self:cardOnUse(room,use)
		room:addPlayerHistory(use.from,use.card:getClassName())
		local to,damage = use.to:at(0),room:getTag("damage_caused_"..use.card:toString()):toDamage()
		room:addPlayerMark(to,"ov_xiongsi")
		use.from:setMark(use.card:toString(),0)
		if damage and damage.to then return end
		use.from:addMark("ov_xiongsi_"..to:objectName())
		room:acquireSkill(to,"ov_linglu")
	end
}
ov_xiongsivs = sgs.CreateViewAsSkill{
	name = "ov_xiongsi",
	response_pattern = "@@ov_xiongsi",
	view_as = function(self,cards)
		return ov_xiongsiCard:clone()
	end,
	enabled_at_play = function(self,player)
		return CardIsAvailable(player,"slash","ov_xiongsi")
	end,
}
ov_xiongsi = sgs.CreateTriggerSkill{
	name = "ov_xiongsi",
	events = {sgs.EventPhaseChanging,sgs.Death}, 
	waked_skills = "ov_linglu",
	view_as_skill = ov_xiongsivs,
	can_trigger = function(self,target)
		return target and target:hasSkill(self)
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
	   	then
			local change = data:toPhaseChange()
			if change.from==sgs.Player_NotActive
			then
				for i,p in sgs.list(room:getAlivePlayers())do
					if player:getMark("ov_xiongsi_"..p:objectName())>0
					and p:hasSkill("ov_linglu")
					then
						room:detachSkillFromPlayer(p,"ov_linglu")
					end
				end
			end
		elseif event==sgs.Death
		then
			local death = data:toDeath()
			if player:objectName()~=death.who:objectName() then return end
			for i,p in sgs.list(room:getAlivePlayers())do
				if player:getMark("ov_xiongsi_"..p:objectName())>0
				and p:hasSkill("ov_linglu")
				then
					room:detachSkillFromPlayer(p,"ov_linglu")
				end
			end
		end
		return false
	end
}
ov_jianshuo:addSkill(ov_xiongsi)
ov_linglu = sgs.CreateTriggerSkill{
	name = "ov_linglu",
	events = {sgs.EventPhaseStart},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseStart
		and player:getPhase()==sgs.Player_Play
	   	then
			local to = room:askForPlayerChosen(player,room:getAlivePlayers(),"ov_linglu","ov_linglu0:",true,true)
			if not to then return end
			to:addMark("ov_linglu-Clear")
			room:broadcastSkillInvoke(self:objectName())
			room:setPlayerMark(to,"&ov_linglu+#"..player:objectName(),1)
		end
		return false
	end
}
ov_linglubf = sgs.CreateTriggerSkill{
	name = "#ov_linglubf",
	events = {sgs.EventPhaseChanging,sgs.Damage}, 
	can_trigger = function(self,target)
		if target and target:isAlive()
		then
			local room = target:getRoom()
			for i,p in sgs.list(room:getPlayers())do
				if target:getMark("&ov_linglu+#"..p:objectName())>0
				then return true end
			end
		end
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
	   	then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			and player:getMark("ov_linglu-Clear")<1
			then
				for n,p in sgs.list(room:getPlayers())do
					if player:getMark("&ov_linglu+#"..p:objectName())>0
					then
						room:setPlayerMark(player,"&ov_linglu+#"..p:objectName(),0)
						room:setPlayerMark(player,"&ov_linglu+damage",0)
						Skill_msg("ov_linglu",player)
						if p:isAlive()
						and player:getMark("ov_xiongsi_"..p:objectName())>0
						and ToSkillInvoke("ov_xiongsi",p,player)
						then n = 2 else n = 1 end
						for i=1,n do
							room:loseHp(player)
						end
					end
				end
			end
		else
		    local damage = data:toDamage()
			room:addPlayerMark(player,"&ov_linglu+damage",damage.damage)
			if player:getMark("&ov_linglu+damage")>1
			then
				for i,p in sgs.list(room:getPlayers())do
					if player:getMark("&ov_linglu+#"..p:objectName())>0
					then
						Skill_msg("ov_linglu",player)
						room:setPlayerMark(player,"&ov_linglu+#"..p:objectName(),0)
						room:setPlayerMark(player,"&ov_linglu+damage",0)
						player:drawCards(2,"ov_linglu")
					end
				end
			end
		end
		return false
	end
}
addToSkills(ov_linglu)
addToSkills(ov_linglubf)
extension:insertRelatedSkills("ov_linglu", "#ov_linglubf")

ov_niufudongxie = sgs.General(extension,"ov_niufudongxie","qun")
ov_niufudongxie:setGender(sgs.General_Neuter)
ov_juntun = sgs.CreateTriggerSkill{
	name = "ov_juntun",
	events = {sgs.Damaged,sgs.GameStart,sgs.Dying},
	priority = {5},
	waked_skills = "ov_xiongjun",
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self,event,player,data,room)
		for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
			if event==sgs.GameStart and player:objectName()==owner:objectName()
			or event==sgs.Damaged and player:getTag("ov_juntunDying"):toBool()
			then
				player:removeTag("ov_juntunDying")
				local to = room:askForPlayerChosen(owner,room:getAlivePlayers(),"ov_juntun","ov_juntun0:",true,true)
				if not to then return end
				room:broadcastSkillInvoke(self:objectName())
				to:addMark("ov_juntun_"..owner:objectName())
				room:acquireSkill(to,"ov_xiongjun")
			elseif event==sgs.Dying
			then
				local dying = data:toDying()
				dying.who:setTag("ov_juntunDying",ToData(true))
			end
		end
		return false
	end,
}
ov_juntunbf = sgs.CreateTriggerSkill{
	name = "#ov_juntunbf",
	events = {sgs.Damage}, 
	can_trigger = function(self,target)
		if target and target:isAlive()
		then
			local room = target:getRoom()
			for _,owner in sgs.list(room:findPlayersBySkillName("ov_juntun"))do
				if target:getMark("ov_juntun_"..owner:objectName())>0
				and owner:objectName()~=target:objectName()
				and target:hasSkill("ov_xiongjun")
				then return target:isAlive() end
			end
		end
	end,
	on_trigger = function(self,event,player,data,room)
	    local damage = data:toDamage()
	   	for _,owner in sgs.list(room:findPlayersBySkillName("ov_juntun"))do
			if player:getMark("ov_juntun_"..owner:objectName())>0
			and owner:objectName()~=player:objectName()
			and owner:getTag("ov_baonieNum"):toInt()<5
			then
				Skill_msg("ov_juntun",owner)
				GainOvBaonieNum(owner,damage.damage)
			end
		end
		return false
	end
}
ov_juntun:setProperty("ov_baonieNum",ToData(true))
ov_niufudongxie:addSkill(ov_juntun)
ov_niufudongxie:addSkill(ov_juntunbf)
extension:insertRelatedSkills("ov_juntun", "#ov_juntunbf")
ov_xiongxiCard = sgs.CreateSkillCard{
	name = "ov_xiongxiCard",
--	will_throw = false,
	filter = function(self,targets,to_select,from)
		return #targets<1
		and to_select:getMark("ov_xiongxi-Clear")<1
		and to_select:objectName()~=from:objectName()
	end,
	on_use = function(self,room,source,targets)
		for i,to in sgs.list(targets)do
			room:damage(sgs.DamageStruct("ov_xiongxi",source,to))
			room:addPlayerMark(to,"ov_xiongxi-Clear")
		end
	end
}
ov_xiongxi = sgs.CreateViewAsSkill{
	name = "ov_xiongxi",
	n = 998,
	response_pattern = "@@ov_xiongxi",
	view_filter = function(self,selected,to_select)
		local n = 5-sgs.Self:getMark("@ov_baonieNum")
		return sgs.Self:canDiscard(sgs.Self,to_select:getEffectiveId())
		and #selected<n
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_xiongxiCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		local n = 5-sgs.Self:getMark("@ov_baonieNum")
		return #cards>=n and c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_xiongxiCard")--<1
	end,
}
ov_xiongxi:setProperty("ov_baonieNum",ToData(true))
ov_niufudongxie:addSkill(ov_xiongxi)
ov_xiafeng = sgs.CreateTriggerSkill{
	name = "ov_xiafeng",
	events = {sgs.EventPhaseStart,sgs.CardUsed},
	on_trigger = function(self,event,player,data,room)
		local bn = player:getTag("ov_baonieNum"):toInt()
		if event==sgs.EventPhaseStart
		and player:getPhase()==sgs.Player_Play
		and bn>0 and ToSkillInvoke(self,player)
	   	then
			local n = {}
			bn = bn>3 and 3 or bn
			for i=1,bn do
				table.insert(n,i)
			end
			n = table.concat(n,"+")
			n = room:askForChoice(player,"ov_xiafeng",n)
			GainOvBaonieNum(player,-n)
			room:setPlayerMark(player,"&ov_xiafeng-Clear",n)
			room:setPlayerMark(player,"ov_xiafeng-Clear",n)
		elseif event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:getTypeId()~=0
			and player:getMark("ov_xiafeng-Clear")>0
			then
				Skill_msg(self,player)
				room:removePlayerMark(player,"ov_xiafeng-Clear")
				local can = use.no_respond_list
				for i,to in sgs.list(use.to)do
					table.insert(can,to:objectName())
				end
				use.no_respond_list = can
				data:setValue(use)
			end
		end
		return false
	end
}
ov_xiafengbf = sgs.CreateMaxCardsSkill{
    name = "#ov_xiafengbf",
	extra_func = function(self,target)
		if target:hasSkill("ov_xiafeng")
		then return target:getMark("&ov_xiafeng-Clear") end
	end 
}
ov_xiafengbf1 = sgs.CreateTargetModSkill{
	name = "#ov_xiafengbf1",
	pattern = "^SkillCard",
	residue_func = function(self,from,card)--额外使用
		if from:hasSkill("ov_xiafeng") and from:getMark("ov_xiafeng-Clear")>0
		then return 998 end
	end,
	distance_limit_func = function(self,from,card,to)--使用距离
		if from:hasSkill("ov_xiafeng") and from:getMark("ov_xiafeng-Clear")>0
		then return 998 end
	end,
	extra_target_func = function(self,from,card)--目标数
	end
}
ov_niufudongxie:addSkill(ov_xiafeng)
ov_niufudongxie:addSkill(ov_xiafengbf)
ov_niufudongxie:addSkill(ov_xiafengbf1)
extension:insertRelatedSkills("ov_xiafeng", "#ov_xiafengbf")
extension:insertRelatedSkills("ov_xiafeng", "#ov_xiafengbf1")
ov_xiongjun = sgs.CreateTriggerSkill{
	name = "ov_xiongjun",
	events = {sgs.Damage},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data,room)
	    local damage = data:toDamage()
		for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
			room:sendCompulsoryTriggerLog(owner,"ov_xiongjun",true,true)
			owner:drawCards(1,"ov_xiongjun")
		end
		return false
	end
}
addToSkills(ov_xiongjun)

ov_bingyuan = sgs.General(extension,"ov_bingyuan","qun",3)
ov_bingdeCard = sgs.CreateSkillCard{
	name = "ov_bingdeCard",
	target_fixed = true,
	on_use = function(self,room,source,targets)
		local suits = {"spade","club","heart","diamond"}
		local tos = {}
		for _,s in sgs.list(suits)do
			if source:getMark(s.."no_bingde-PlayClear")>0
			then continue end
			table.insert(tos,s)
		end
		if source:getMark("no_suitov_bingde-PlayClear")>0
		then table.insert(tos,"no_suit") end
		if #tos<1 then return end
		tos = table.concat(tos,"+")
		tos = room:askForChoice(source,"ov_bingde",tos)
		source:addMark(tos.."no_bingde-PlayClear")
		MarkRevises(source,"&ov_bingde-PlayClear",tos.."_char")
		if self:getSuitString()==tos
		then
			room:addPlayerHistory(source,"#ov_bingdeCard",-1)
		end
		tos = source:getMark(tos.."ov_bingde-PlayClear")
		if tos<1 then return end
		source:drawCards(tos,"ov_bingde")
	end
}
ov_bingdevs = sgs.CreateViewAsSkill{
	name = "ov_bingde",
	n = 1,
	view_filter = function(self,selected,to_select)
		return not sgs.Self:isJilei(to_select)
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_bingdeCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_bingdeCard")<1
	end,
}
ov_bingde = sgs.CreateTriggerSkill{
	name = "ov_bingde",
	events = {sgs.CardUsed},
	view_as_skill = ov_bingdevs,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:getTypeId()~=0
			and player:getPhase()==sgs.Player_Play
			then
				player:addMark(use.card:getSuitString().."ov_bingde-PlayClear")
				MarkRevises(player,"&use-PlayClear",use.card:getSuitString().."_char")
			end
		end
		return false
	end
}
ov_bingyuan:addSkill(ov_bingde)
ov_qingtao = sgs.CreateTriggerSkill{
	name = "ov_qingtao",
	events = {sgs.EventPhaseEnd,sgs.EventPhaseProceeding},
	on_trigger = function(self,event,player,data,room)
		if (event==sgs.EventPhaseEnd and player:getPhase()==sgs.Player_Draw
		or event==sgs.EventPhaseProceeding
			and player:getPhase()==sgs.Player_Finish
			and player:getMark("ov_qingtaoUse-Clear")<1)
		and player:getCardCount()>0
	   	then
			local c = room:askForCard(player,"..","ov_qingtao0:",ToData(player),sgs.Card_MethodRecast)
			if c
			then
				room:broadcastSkillInvoke(self:objectName())
				local n = 1
				if c:isKindOf("Analeptic")
				or c:getTypeId()~=1
				then n = 2 end
				UseCardRecast(player,c,"@ov_qingtao",n)
				player:addMark("ov_qingtaoUse-Clear")
			end
		end
		return false
	end
}
ov_bingyuan:addSkill(ov_qingtao)

ov_furong = sgs.General(extension,"ov_furong","shu")
ov_xiewei = sgs.CreateTriggerSkill{
	name = "ov_xiewei",
	events = {sgs.RoundStart,sgs.EventPhaseStart},
	can_trigger = function(self,target)
		return target and target:isAlive()
	end,
	on_trigger = function(self,event,player,data,room)
	   	for _,owner in sgs.list(room:findPlayersBySkillName("ov_xiewei"))do
		if event==sgs.RoundStart
	   	then owner:setMark("ov_xieweiUse",0)
		elseif owner:getMark("ov_xieweiUse")<1
		and player:getPhase()==sgs.Player_Play
		and player:objectName()~=owner:objectName()
		and ToSkillInvoke(self,owner,player)
		then
			owner:addMark("ov_xieweiUse")
			room:broadcastSkillInvoke("xuewei")
			local choice = "ov_xiewei2="..owner:objectName()
			if owner:aliveCount()>2
			then
				choice = "ov_xiewei1="..owner:objectName().."+ov_xiewei2="..owner:objectName()
			end
			choice = room:askForChoice(player,"ov_xiewei",choice,ToData(owner))
			if choice=="ov_xiewei1="..owner:objectName()
			then
				choice = room:getOtherPlayers(player)
				choice:removeOne(owner)
				choice = PlayerChosen(self,owner,choice,"ov_xiewei3:"..player:objectName())
				room:addPlayerMark(player,"ov_xieweidebf-Clear",2)
				room:addPlayerMark(player,choice:objectName().."_ov_xieweidebf-Clear")
			else
				choice = dummyCard("duel")
				choice:setSkillName("_ov_xiewei")
				room:useCard(sgs.CardUseStruct(choice,owner,player))
			end
		end
		end
		return false
	end
}
ov_furong:addSkill(ov_xiewei)
ov_xieweibf = sgs.CreateProhibitSkill{
	name = "#ov_xieweibf",
	is_prohibited = function(self,from,to,card)
		if card:isKindOf("Slash")
		and to and from:getMark(to:objectName().."_ov_xieweidebf-Clear")>0
		then self:setObjectName("ov_xiewei") return true end
	end
}
ov_xieweibf2 = sgs.CreateMaxCardsSkill{
    name = "#ov_xieweibf2",
	extra_func = function(self,target)
		if target:getMark("ov_xieweidebf-Clear")>0
		then return -2 end
	end 
}
ov_furong:addSkill(ov_xieweibf)
ov_furong:addSkill(ov_xieweibf2)
extension:insertRelatedSkills("ov_xiewei", "#ov_xieweibf")
extension:insertRelatedSkills("ov_xiewei", "#ov_xieweibf2")
ov_liechi = sgs.CreateTriggerSkill{
	name = "ov_liechi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged,sgs.Dying}, 
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Damaged
	   	then
		    local damage = data:toDamage()
			if damage.from and damage.from:getHp()>=player:getHp()
			then
				room:sendCompulsoryTriggerLog(player,"ov_liechi",true)
				room:broadcastSkillInvoke("liechi")
				local choice = {}
				table.insert(choice,"ov_liechi1="..damage.from:objectName())
				if damage.from:getCardCount()>0
				then
					table.insert(choice,"ov_liechi2="..damage.from:objectName())
				end
				if #choice>1 and hasCard(player,"EquipCard")
				and player:getMark("ov_liechi_Dying-Clear")>0
				then table.insert(choice,"beishui_choice=ov_liechi3") end
				choice = table.concat(choice,"+")
				choice = room:askForChoice(player,"ov_liechi",choice,ToData(damage.from))
				if choice=="ov_liechi1="..damage.from:objectName()
				then
					choice = damage.from:getHandcardNum()-player:getHandcardNum()
					if choice>0
					then
						room:askForDiscard(damage.from,"ov_liechi",choice,choice)
					end
				elseif choice=="ov_liechi2="..damage.from:objectName()
				then
					choice = room:askForCardChosen(player,damage.from,"he","ov_liechi",false,sgs.Card_MethodDiscard)
					if choice>-1 then room:throwCard(choice,damage.from,player) end
				else
					choice = room:askForCard(player,"EquipCard!","ov_liechi0:",data)
					if not choice
					then
						choice = hasCard(player,"EquipCard")
						if choice then room:throwCard(choice:at(0),player)
						else return end
					end
					choice = damage.from:getHandcardNum()-player:getHandcardNum()
					if choice>0
					then
						room:askForDiscard(damage.from,"ov_liechi",choice,choice)
					end
					if damage.from:getCardCount()<1 then return end
					choice = room:askForCardChosen(player,damage.from,"he","ov_liechi",false,sgs.Card_MethodDiscard)
					if choice>-1 then room:throwCard(choice,damage.from,player) end
				end
			end
		else
			local dying = data:toDying()
			if dying.who:objectName()==player:objectName()
			then player:addMark("ov_liechi_Dying-Clear") end
		end
		return false
	end
}
ov_furong:addSkill(ov_liechi)

ov_chenwudongxi = sgs.General(extension,"ov_chenwudongxi","wu")
ov_chenwudongxi:addSkill("yilie")
ov_fenming = sgs.CreateTriggerSkill{
	name = "ov_fenming",
	events = sgs.EventPhaseProceeding,
	on_trigger = function(self,event,player,data,room)
		if player:getPhase()==sgs.Player_Start
		then
			local to = room:askForPlayerChosen(player,room:getAlivePlayers(),"ov_fenming","ov_fenming0:",true,true)
			if to
			then
				room:broadcastSkillInvoke("fenming")
				local choice = "ov_fenming1="..to:objectName().."+ov_fenming2="..to:objectName().."+beishui_choice=ov_fenming3"
				choice = room:askForChoice(player,"ov_fenming",choice,ToData(to))
				if choice=="ov_fenming1="..to:objectName()
				then room:askForDiscard(to,"ov_fenming",1,1,false,true)
				elseif choice=="ov_fenming2="..to:objectName()
				then room:setPlayerChained(to,true)
				else
					room:setPlayerChained(player,true)
					room:askForDiscard(to,"ov_fenming",1,1,false,true)
					room:setPlayerChained(to,true)
				end
			end
		end
		return false
	end
}
ov_chenwudongxi:addSkill(ov_fenming)

ov_wangling = sgs.General(extension,"ov_wangling","wei")
ov_mibei = sgs.CreateTriggerSkill{
	name = "ov_mibei",
	events = {sgs.EventPhaseEnd,sgs.CardUsed,sgs.CardResponded},
    shiming_skill = true,
	waked_skills = "ov_mouli",
	on_trigger = function(self,event,player,data,room)
		if player:getTag("ov_mibei_shiming"):toBool()
		then return end
		if event==sgs.EventPhaseEnd
		then
			if player:getMark("ov_mibeiUse-Clear")<1
			and player:getPhase()==sgs.Player_Play
			then
				Skill_msg(self,player,2)
				ShimingSkillDoAnimate(self,player)
				player:addMark("ov_mibeidebf-Clear")
				room:setPlayerMark(player,"&ov_mibei",0)
				for i=1,3 do
					player:setMark("ov_mibeiUse_"..i,0)
				end
			end
		else
			local card
			if event==sgs.CardResponded
			then
				card = data:toCardResponse()
				if card.m_isUse then card = card.m_card
				else card = nil end
			else card = data:toCardUse().card end
			if not card or card:getTypeId()<1 then return end
			player:addMark("ov_mibeiUse_"..card:getTypeId())
			player:addMark("ov_mibeiUse-Clear")
			local n = 0
			for i=1,3 do
				i = player:getMark("ov_mibeiUse_"..i)
				i = i>2 and 2 or i
				n = n+i
			end
			if n>player:getMark("&ov_mibei")
			then Skill_msg(self,player,1) end
			room:setPlayerMark(player,"&ov_mibei",n)
			if n>5
			then
				ShimingSkillDoAnimate(self,player,true)
				room:setPlayerMark(player,"&ov_mibei",0)
				player:setTag("ov_mibei_shiming",ToData(true))
				room:acquireSkill(player,"ov_mouli")
			end
		end
		return false
	end
}
ov_mibeidebf = sgs.CreateMaxCardsSkill{
    name = "#ov_mibeidebf",
	extra_func = function(self,target)
		if target:getMark("ov_mibeidebf-Clear")>0
		then return -1 end
	end 
}
ov_wangling:addSkill(ov_mibei)
ov_wangling:addSkill(ov_mibeidebf)
extension:insertRelatedSkills("ov_mibei", "#ov_mibeidebf")
ov_xingqi = sgs.CreateTriggerSkill{
	name = "ov_xingqi",
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseProceeding},
	can_trigger = function(self,target)
		if not target then return end
		local room = target:getRoom()
		local can = 0
		for _,p in sgs.list(room:getAlivePlayers())do
			can = can+p:getCards("ej"):length()
		end
		return target:hasSkill(self)
		and target:getMark(self:objectName())<1
		and target:getPhase()==sgs.Player_Start
		and (target:canWake(self:objectName()) or can>target:getHp())
	end,
	on_trigger = function(self,event,player,data,room)
	    SkillWakeTrigger(self,player,0)
		room:recover(player,sgs.RecoverStruct(player))
		if player:getTag("ov_mibei_shiming"):toBool()
		then room:addPlayerMark(player,"ov_xingqibf")
		else
			local dc = dummyCard()
			for c,id in sgs.list(room:getDrawPile())do
				c = sgs.Sanguosha:getCard(id)
				if player:getMark(c:getType().."ov_xingqi-PlayClear")>0
				then continue end
				player:addMark(c:getType().."ov_xingqi-PlayClear")
				dc:addSubcard(id)
			end
			room:obtainCard(player,dc)
		end
	end
}
ov_xingqibf = sgs.CreateTargetModSkill{
	name = "#ov_xingqibf",
	pattern = "^SkillCard",
	residue_func = function(self,from,card)--额外使用
	end,
	distance_limit_func = function(self,from,card,to)--使用距离
		if from:hasSkill("ov_xingqi") and from:getMark("ov_xingqibf")>0
		then return 998 end
	end,
	extra_target_func = function(self,from,card)--目标数
	end
}
ov_wangling:addSkill(ov_xingqi)
ov_wangling:addSkill(ov_xingqibf)
extension:insertRelatedSkills("ov_xingqi", "#ov_xingqibf")
ov_mouliCard = sgs.CreateSkillCard{
	name = "ov_mouliCard",
	will_throw = false,
	filter = function(self,targets,to_select)
		local pattern = self:getUserString()
		if pattern=="normal_slash" then pattern = "slash" end
		return SCfilter(pattern,targets,to_select,nil,"ov_mouli")
	end,
	feasible = function(self,targets)
		local pattern = self:getUserString()
		if pattern=="normal_slash" then pattern = "slash" end
		return SCfeasible(pattern,targets,nil,"ov_mouli")
	end,
	on_validate = function(self,use)
		local room = use.from:getRoom()
		NotifySkillInvoked("ov_mouli",use.from,use.to)
		local to_guhuo = self:getUserString()
		room:addPlayerMark(use.from,"ov_mouliUse-Clear")
		to_guhuo = room:askForChoice(use.from,"ov_mouli",to_guhuo)
		for c,id in sgs.list(room:getDrawPile())do
			c = sgs.Sanguosha:getCard(id)
			if c:objectName()==to_guhuo
			then return c end
		end
		return nil
	end,
	on_validate_in_response = function(self,yuji)
		local room = yuji:getRoom()
		NotifySkillInvoked("ov_mouli",yuji)
		local to_guhuo = self:getUserString()
		room:addPlayerMark(yuji,"ov_mouliUse-Clear")
		to_guhuo = room:askForChoice(yuji,"ov_mouli",to_guhuo)
		for c,id in sgs.list(room:getDrawPile())do
			c = sgs.Sanguosha:getCard(id)
			if c:objectName()==to_guhuo
			then return c end
		end
		return nil
	end
}
ov_mouli = sgs.CreateViewAsSkill {
	name = "ov_mouli",	
	view_as = function(self,cards)
		local card = ov_mouliCard:clone()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_PLAY
		then
			local card = sgs.Self:getTag("ov_mouli"):toCard()
			pattern = card:objectName()
		end
		card:setUserString(pattern)
		return card
	end,
	enabled_at_response = function(self,player,pattern)
		if string.sub(pattern,1,1)=="."
		or string.sub(pattern,1,1)=="@"
		or player:getMark("ov_mouliUse-Clear")>0
		or pattern=="peach" and player:getMark("Global_PreventPeach")>0
		or sgs.Sanguosha:getCurrentCardUseReason()~=sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
		then return end
		for i,c in sgs.list(PatternsCard(pattern:split("+"),true))do
			if c and c:getTypeId()==1
			then return true end
		end
	end,
	enabled_at_play = function(self,player)				
		if player:getMark("ov_mouliUse-Clear")>0 then return end
		for i,c in sgs.list(PatternsCard("BasicCard",true))do
			if c:isAvailable(player)
			then return true end
		end
	end,	
}
ov_mouli:setGuhuoDialog("l")
addToSkills(ov_mouli)

ov_bianfuren = sgs.General(extension,"ov_bianfuren","wei",3,false)
ov_wanweibfVs = sgs.CreateViewAsSkill{
	name = "ov_wanwei",
	response_pattern = "@@ov_wanwei!",
	view_as = function(self,cards)
		return sgs.Sanguosha:getCard(sgs.Self:getMark("ov_wanwei_id"))
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_wanwei = sgs.CreateTriggerSkill{
	name = "ov_wanwei",
	events = {sgs.DamageInflicted},
	view_as_skill = ov_wanweibfVs,
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName("ov_wanwei")
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.DamageInflicted
		then
			local damage = data:toDamage()
			for _,p in sgs.list(room:getAlivePlayers())do
				if p:getHp()<damage.to:getHp() then return end
			end
			for b,p in sgs.list(room:findPlayersBySkillName("ov_wanwei"))do
				if p:getMark("ov_wanwei-Clear")>0 then continue end
				for _,ap in sgs.list(room:getAlivePlayers())do
					if ap:getMaxHp()>p:getMaxHp()
					then b = false break end
				end
				local dr = false
				if p:objectName()~=damage.to:objectName()
				and ToSkillInvoke(self,p,damage.to)
				then
					p:addMark("ov_wanwei-Clear")
					room:loseHp(p,1,true,nil,"ov_wanwei")
					dr = true
					room:broadcastSkillInvoke("wanwei")
				end
				if (p:objectName()==damage.to:objectName() or b)
				and p:isAlive() and ToSkillInvoke(self,p)
				then
					p:addMark("ov_wanwei-Clear")
					p:addMark("ov_wanweibf-Clear")
					room:broadcastSkillInvoke("wanwei")
				end
				if dr
				then
					return DamageRevises(data,-damage.damage,p)
				end
			end
		end
	end
}
ov_bianfuren:addSkill(ov_wanwei)
ov_wanweibf = sgs.CreateTriggerSkill{
	name = "#ov_wanweibf",
	events = {sgs.EventPhaseChanging},
	can_trigger = function(self,target)
		return target and target:isAlive()
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to~=sgs.Player_NotActive then return end
			for _,ap in sgs.list(room:getAlivePlayers())do
				if ap:getMark("ov_wanweibf-Clear")<1 then continue end
				Skill_msg("ov_wanwei",ap)
				change = room:getNCards(1)
				room:obtainCard(ap,change:at(0),false)
				change = room:getNCards(1,false,false)
				local move = sgs.CardsMoveStruct(change,nil,nil,sgs.Player_DrawPile,sgs.Player_PlaceTable,
				sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER,ap:objectName(),"ov_wanwei",nil))
				local moves = sgs.CardsMoveList()
				moves:append(move)
				room:notifyMoveCards(true,moves,false,room:getAlivePlayers())
				room:notifyMoveCards(false,moves,false,room:getAlivePlayers())
				room:returnToEndDrawPile(change)
				room:setPlayerMark(ap,"ov_wanwei_id",change:at(0))
				move = sgs.Sanguosha:getCard(change:at(0))
				if move:isAvailable(ap)
				then
					if room:askForUseCard(ap,"@@ov_wanwei!","ov_wanweibf0:"..move:objectName()) then
					elseif move:targetFixed() then room:useCard(sgs.CardUseStruct(move,ap,sgs.SPlayerList()))
					else
						for _,p in sgs.list(room:getCardTargets(ap,move,room:getAlivePlayers()))do
							room:useCard(sgs.CardUseStruct(move,ap,p))
							break
						end
					end
				end
			end
		end
	end
}
ov_bianfuren:addSkill(ov_wanweibf)
extension:insertRelatedSkills("ov_wanwei", "#ov_wanweibf")
ov_bianfuren:addSkill(ov_wanweibfVs)
extension:insertRelatedSkills("ov_wanwei", "#ov_wanweibfVs")
ov_yuejianCard = sgs.CreateSkillCard{
	name = "ov_yuejianCard",
	will_throw = false,
	target_fixed = true,
	skill_name = "yuejian",
	handling_method = sgs.Card_MethodNone,
	on_use = function(self,room,source,targets)
		room:moveCardsInToDrawpile(source,self:getSubcards(),"ov_yuejian")
		room:askForGuanxing(source,self:getSubcards(),0)
		if self:subcardsLength()>=1
		then
			room:addMaxCards(source,1,false)
		end
		if self:subcardsLength()>=2
		then
			room:recover(source,sgs.RecoverStruct(source))
		end
		if self:subcardsLength()>=3
		then
			room:gainMaxHp(source)
		end
	end
}
ov_yuejianvs = sgs.CreateViewAsSkill{
	name = "ov_yuejian",
	n = 998,
	response_pattern = "@@ov_yuejian",
	view_filter = function(self,selected,to_select)
		return #selected<1 or #selected<sgs.Self:getHandcardNum()-sgs.Self:getMaxCards()
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_yuejianCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_yuejianCard")<1
		and player:getCardCount()>0
	end,
}
ov_bianfuren:addSkill(ov_yuejianvs)

ov_chenzhen = sgs.General(extension,"ov_chenzhen","shu",3)
ov_muyueCard = sgs.CreateSkillCard{
	name = "ov_muyueCard",
--	will_throw = false,
	target_fixed = true,
	handling_method = sgs.Card_MethodDiscard,
	on_use = function(self,room,source,targets)
		room:broadcastSkillInvoke("shameng",1)
		local msg = sgs.LogMessage()
		msg.type = "#ov_muyueCard"
		msg.from = source
		msg.arg = AgCardsToName(source,nil,true)
		room:sendLog(msg)
		local to = PlayerChosen("ov_muyue",source,nil,"ov_muyue0:")
		for n,id in sgs.list(room:getDrawPile())do
			n = sgs.Sanguosha:getCard(id):objectName()
			if n==msg.arg then room:obtainCard(to,id) to = n break end
		end
		if self:subcardsLength()>0
		and sgs.Sanguosha:getCard(self:getEffectiveId()):objectName()==to
		then to = 1 else to = 0 end
		room:setPlayerMark(source,"ov_muyuebf",to)
	end
}
ov_muyuevs = sgs.CreateViewAsSkill{
	name = "ov_muyue",
	n = 1,
	response_pattern = "@@ov_muyue",
	view_filter = function(self,selected,to_select)
		if sgs.Self:getMark("ov_muyuebf")>0 then return end
		return sgs.Self:canDiscard(sgs.Self,to_select:getEffectiveId())
	end,
	view_as = function(self,cards)
		local c = ov_muyueCard:clone()
		c:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
		if sgs.Self:getMark("ov_muyuebf")>0 then return c end
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_muyueCard")<1
		and player:getCardCount()>0
	end,
}
ov_chenzhen:addSkill(ov_muyuevs)
ov_chayi = sgs.CreateTriggerSkill{
	name = "ov_chayi",
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self,event,player,data,room)
		if player:getPhase()==sgs.Player_Finish
		then
			local to = room:askForPlayerChosen(player,room:getAlivePlayers(),"ov_chayi","ov_chayi0:",true,true)
			if to
			then
				room:broadcastSkillInvoke("shameng",2)
				room:setPlayerMark(to,"ov_chayiHN",to:getHandcardNum()+1)
				local n = room:askForChoice(to,"ov_chayi","ov_chayi1+ov_chayi2")
				Log_message("$ov_chayiHN",to,nil,nil,n)
				if n=="ov_chayi1" then room:showAllCards(to)
				else room:addPlayerMark(to,"ov_chayidebf") end
				to:setTag("ov_chayi",ToData(n))
			end
		end
	end
}
ov_chenzhen:addSkill(ov_chayi)
ov_chayibf = sgs.CreateTriggerSkill{
	name = "#ov_chayibf",
	events = {sgs.EventPhaseChanging,sgs.CardUsed,sgs.CardResponded},
	can_trigger = function(self,target)
		return target and (target:getMark("ov_chayiHN")>0 or target:getMark("ov_chayidebf")>0)
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.from==sgs.Player_NotActive
			and player:getMark("ov_chayiHN")>0
			then
				if player:getMark("ov_chayiHN")-1~=player:getHandcardNum()
				then
					Skill_msg("ov_chayi",player)
					if player:getTag("ov_chayi"):toString()=="ov_chayi1"
					then room:addPlayerMark(player,"ov_chayidebf")
					else room:showAllCards(player) end
				end
				room:setPlayerMark(player,"ov_chayiHN",0)
			end
		elseif player:getMark("ov_chayidebf")>0
		then
			local card
			if event==sgs.CardResponded
			then
				if data:toCardResponse().m_isUse
				then card = data:toCardResponse().m_card
				else return end
			else card = data:toCardUse().card end
			if card:getTypeId()<1 then return end
			Skill_msg("ov_chayi",player)
			room:removePlayerMark(player,"ov_chayidebf")
			room:askForDiscard(player,"ov_chayi",1,1,false,true)
		end
	end
}
ov_chenzhen:addSkill(ov_chayibf)
extension:insertRelatedSkills("ov_chayi", "#ov_chayibf")

ov_sunshao = sgs.General(extension,"ov_sunshao","wu",3)
ov_dingyi = sgs.CreateTriggerSkill{
	name = "ov_dingyi",
	events = {sgs.GameStart},
	on_trigger = function(self,event,player,data,room)
		local tos = room:getAlivePlayers()
		Skill_msg(self,player,math.random(1,2))
		while tos:length()>0 do
			local ch = "ov_dingyi1+ov_dingyi2+ov_dingyi3+ov_dingyi4"
			ch = room:askForChoice(player,"ov_dingyi",ch)
			local to = room:askForPlayerChosen(player,tos,"ov_dingyi","ov_dingyi0:"..ch)
			if to
			then
				tos:removeOne(to)
				room:addPlayerMark(to,"&"..ch)
			end
		end
	end
}
ov_sunshao:addSkill(ov_dingyi)
ov_dingyibf1 = sgs.CreateTriggerSkill{
	name = "#ov_dingyibf1",
	events = {sgs.DrawNCards},
	can_trigger = function(self,target)
		return target and target:getMark("&ov_dingyi1")>0
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.DrawNCards
		then
			local n = data:toInt()+1
			Skill_msg("ov_dingyi",player)
			if player:getMark("ov_fubibf")>0
			then n = n+1 end
			data:setValue(n)
		end
	end
}
ov_sunshao:addSkill(ov_dingyibf1)
extension:insertRelatedSkills("ov_dingyi", "#ov_dingyibf1")
ov_dingyibf2 = sgs.CreateMaxCardsSkill{
    name = "#ov_dingyibf2",
	extra_func = function(self,target)
		if target:getMark("&ov_dingyi2")>0
		then
			local n = 2
	    	if target:getMark("ov_fubibf")>0
			then n = n*2 end
			return n
		end
	end 
}
ov_sunshao:addSkill(ov_dingyibf2)
extension:insertRelatedSkills("ov_dingyi", "#ov_dingyibf2")
ov_dingyibf3 = sgs.CreateAttackRangeSkill{
	name = "#ov_dingyibf3",
    extra_func = function(self,target)
		if target:getMark("&ov_dingyi3")>0
		then
			local n = 1
	    	if target:getMark("ov_fubibf")>0
			then n = n*2 end
			return n
		end
	end,
}
ov_sunshao:addSkill(ov_dingyibf3)
extension:insertRelatedSkills("ov_dingyi", "#ov_dingyibf3")
ov_dingyibf4 = sgs.CreateTriggerSkill{
	name = "#ov_dingyibf4",
	events = {sgs.QuitDying},
	can_trigger = function(self,target)
		return target and target:getMark("&ov_dingyi4")>0
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.QuitDying
		then
			local n = 1
			Skill_msg("ov_dingyi",player)
	    	if player:getMark("ov_fubibf")>0 then n = n*2 end
			room:recover(player,sgs.RecoverStruct(player,nil,n))
		end
	end
}
ov_sunshao:addSkill(ov_dingyibf4)
extension:insertRelatedSkills("ov_dingyi", "#ov_dingyibf4")
ov_zuici = sgs.CreateTriggerSkill{
	name = "ov_zuici",
	events = {sgs.Damaged},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Damaged
		then
		    local damage = data:toDamage()
			if damage.from
			then
				local can
				for i=1,4 do
					if damage.from:getMark("&ov_dingyi"..i)>0
					then can = true break end
				end
				if can
				and ToSkillInvoke(self,player,damage.from)
				then
					room:broadcastSkillInvoke("mobilezuici")
					for i=1,4 do
						room:removePlayerMark(damage.from,"&ov_dingyi"..i)
					end
					can = table.concat(sgs.ZhinangClassName,"+")
					can = room:askForChoice(player,"ov_zuici",can,ToData(damage.from))
					for _,c in sgs.list(PatternsCard(can,true,true))do
						if room:getCardOwner(c:getId()) then continue end
						room:obtainCard(damage.from,c)
						break
					end
				end
			end
		end
	end
}
ov_sunshao:addSkill(ov_zuici)
ov_fubiCard = sgs.CreateSkillCard{
	name = "ov_fubiCard",
	handling_method = sgs.Card_MethodDiscard,
	filter = function(self,targets,to_select)
		for i=1,4 do
			if to_select:getMark("&ov_dingyi"..i)>0
			then return #targets<1 end
		end
	end,
	on_use = function(self,room,source,targets)
		room:broadcastSkillInvoke("mobilefubi")
		room:addPlayerMark(source,"ov_fubiCard_lun")
		if self:subcardsLength()>0
		then room:addPlayerMark(targets[1],"ov_fubibf")
		else
			for i=1,4 do
				room:removePlayerMark(targets[1],"&ov_dingyi"..i)
			end
			local ch = "ov_dingyi1+ov_dingyi2+ov_dingyi3+ov_dingyi4"
			ch = room:askForChoice(source,"ov_fubi",ch,ToData(targets[1]))
			room:addPlayerMark(targets[1],"&"..ch)
		end
	end
}
ov_fubivs = sgs.CreateViewAsSkill{
	name = "ov_fubi",
	n = 1,
	response_pattern = "@@ov_fubi",
	view_filter = function(self,selected,to_select)
		return sgs.Self:canDiscard(sgs.Self,to_select:getEffectiveId())
	end,
	view_as = function(self,cards)
		local c = ov_fubiCard:clone()
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return c
	end,
	enabled_at_play = function(self,player)
		return player:getMark("ov_fubiCard_lun")<1
	end,
}
ov_sunshao:addSkill(ov_fubivs)
ov_fubibf = sgs.CreateTriggerSkill{
	name = "#ov_fubibf",
	events = {sgs.EventPhaseChanging,sgs.Death},
	can_trigger = function(self,target)
		return target and target:hasSkill(self)
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
		and player:getMark("ov_fubiCard_lun")<1
		then
			local change = data:toPhaseChange()
			if change.from==sgs.Player_NotActive
			then
				for _,p in sgs.list(room:getAlivePlayers())do
					room:removePlayerMark(p,"ov_fubibf")
				end
			end
		elseif event==sgs.Death
		then
			local death = data:toDeath()
			if death.who:objectName()==player:objectName()
			then
				for _,p in sgs.list(room:getAlivePlayers())do
					room:removePlayerMark(p,"ov_fubibf")
				end
			end
		end
	end
}
ov_sunshao:addSkill(ov_fubibf)
extension:insertRelatedSkills("ov_fubi", "#ov_fubibf")

ov_madai = sgs.General(extension,"ov_madai","shu")
ov_madai:addSkill("mashu")
ov_qianxi = sgs.CreateTriggerSkill{
	name = "ov_qianxi",
	events = {sgs.EventPhaseProceeding,sgs.Damage,sgs.EventPhaseChanging},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Damage
		then
		    local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash")
			and damage.to:getMark(player:objectName().."ov_qianxidebf-Clear")>0
			then
				damage.to:addMark(player:objectName().."ov_qianxidebf_damage-Clear")
			end
		elseif  event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
				for i,p in sgs.list(room:getAlivePlayers())do
					if p:getMark(player:objectName().."ov_qianxidebf-Clear")>0
					then
						i = p:getTag("ov_qianxidebf"):toString()
						room:removePlayerCardLimitation(p,"use,response",".|"..i.."|.|hand")
					end
				end
			end
		elseif player:getPhase()==sgs.Player_Start
		and ToSkillInvoke(self,player)
		then
			room:broadcastSkillInvoke("qianxi")
			player:drawCards(1,"ov_qianxi")
			local dc = room:askForDiscard(player,"ov_qianxi",1,1,false,true)
			if dc
			then
				local tos = sgs.SPlayerList()
				for i,p in sgs.list(room:getAlivePlayers())do
					if player:distanceTo(p)==1
					then tos:append(p) end
				end
				dc = dc:getColorString()
				tos = room:askForPlayerChosen(player,tos,"ov_qianxi","ov_qianxi0:"..dc,false,true)
				if tos
				then
					tos:addMark(player:objectName().."ov_qianxidebf-Clear")
					room:setPlayerCardLimitation(tos,"use,response",".|"..dc.."|.|hand",false)
					tos:setTag("ov_qianxidebf",ToData(dc))
				end
			end
		elseif player:getPhase()==sgs.Player_Finish
		then
			for i,p in sgs.list(room:getAlivePlayers())do
				if p:getMark(player:objectName().."ov_qianxidebf_damage-Clear")>0
				then
					Skill_msg(self,player)
					i = p:getTag("ov_qianxidebf"):toString()
					if i=="red" then i = "black"
					else i = "red" end
					room:setPlayerCardLimitation(p,"use,response",".|"..i,false)
				end
			end
		end
	end
}
ov_qianxidebf = sgs.CreateTriggerSkill{
	name = "#ov_qianxidebf",
	events = {sgs.EventPhaseChanging},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getTag("ov_qianxidebf"):toString()~=""
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
				change = player:getTag("ov_qianxidebf"):toString()
				if change=="red" then change = "black"
				else change = "red" end
				room:removePlayerCardLimitation(player,"use,response",".|"..change)
				player:removeTag("ov_qianxidebf")
			end
		end
	end
}
ov_madai:addSkill(ov_qianxi)
ov_madai:addSkill(ov_qianxidebf)
extension:insertRelatedSkills("ov_qianxi", "#ov_qianxidebf")

ov_fazheng = sgs.General(extension,"ov_fazheng","shu",3)
ov_enyuan = sgs.CreateTriggerSkill{
	name = "ov_enyuan",
	events = {sgs.Damaged,sgs.CardsMoveOneTime}, 
	on_trigger = function(self,event,player,data,room)
    	if event==sgs.Damaged
		then
		    local damage = data:toDamage()
			for i=1,damage.damage do
				player:setFlags("Damaged")
				if damage.from
				and ToSkillInvoke(self,player,damage.from,data)
				then
					room:broadcastSkillInvoke("enyuan")
					i = damage.from:getHandcardNum()>0
					if i
					then
						i = room:askForExchange(damage.from,"ov_enyuan",1,1,false,"ov_enyuan0:"..player:objectName())
					end
					if i
					then
						room:giveCard(damage.from,player,i,"ov_enyuan")
						if i:getSuit()~=2
						then
							player:drawCards(1,"ov_enyuan")
						end
					else room:loseHp(damage.from) end
				else break end
			end
			player:setFlags("-Damaged")
		elseif event==sgs.CardsMoveOneTime
		then
	    	local move = data:toMoveOneTime()
			if move.from and move.to
			and move.to:objectName()==player:objectName()
			and move.from:objectName()~=player:objectName()
			and move.to_place==sgs.Player_PlaceHand
			then
				local n = 0
				local from = BeMan(room,move.from)
				for i,id in sgs.list(move.card_ids)do
					i = move.from_places:at(i)
					if i==sgs.Player_PlaceHand
					or i==sgs.Player_PlaceEquip
					then n = n+1 end
				end
				player:setFlags("CardsMoveOneTime")
				if n>1
				and ToSkillInvoke(self,player,from)
				then
					player:setFlags("-CardsMoveOneTime")
					room:broadcastSkillInvoke("enyuan")
					if (from:isKongcheng() or not from:hasEquip())
					and player:askForSkillInvoke(self,ToData("ov_enyuan1:"..from:objectName()),false)
					then room:recover(from,sgs.RecoverStruct(player))
					else from:drawCards(1,"ov_enyuan") end
				end
				player:setFlags("-CardsMoveOneTime")
			end
		end
		return false
	end
}
ov_fazheng:addSkill(ov_enyuan)
ov_xuanhuoCard = sgs.CreateSkillCard{
	name = "ov_xuanhuoCard",
	will_throw = false,
	skill_name = "xuanhuo",
	filter = function(self,targets,to_select,from)
		return to_select:objectName()~=from:objectName()
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
		for i,target in sgs.list(targets)do
			room:giveCard(source,target,self,"ov_xuanhuo")
			local to = source:aliveCount()>2
			if to
			then
				to = room:getOtherPlayers(target)
				to:removeOne(source)
				to = room:askForPlayerChosen(source,to,"ov_xuanhuo","ov_xuanhuo3:"..target:objectName())
				room:doAnimate(1,target:objectName(),to:objectName())
			end
			i = {}
			if to
			then
				table.insert(i,"ov_xuanhuo1="..source:objectName()..":"..to:objectName())
			end
			table.insert(i,"ov_xuanhuo2="..source:objectName())
			i = room:askForChoice(target,"ov_xuanhuo",table.concat(i,"+"),ToData(to))
			if i~="ov_xuanhuo2="..source:objectName()
			then
				i = room:askForChoice(target,"ov_xuanhuo","slash+duel",ToData(to))
				i = dummyCard(i)
				i:setSkillName("_ov_xuanhuo")
				if target:isProhibited(to,i) then return end
				room:useCard(sgs.CardUseStruct(i,target,to))
			elseif target:getCardCount()>0
			then
				i = dummyCard()
				to = {}
				for n=1,2 do
					if i:subcardsLength()>=target:getCardCount() then break end
					n = room:askForCardChosen(source,target,"he","ov_xuanhuo",false,sgs.Card_MethodNone,i:getSubcards())
					to[n] = room:getCardPlace(n)
					target:addToPile("#ov_xuanhuo",n)
					i:addSubcard(n)
				end
				for c,id in sgs.list(i:getSubcards())do
					c = sgs.Sanguosha:getCard(id)
					room:moveCardTo(c,target,to[id])
				end
				source:obtainCard(i,false)
			end
		end
	end
}
ov_xuanhuovs = sgs.CreateViewAsSkill{
	name = "ov_xuanhuo",
	n = 2,
	response_pattern = "@@ov_xuanhuo",
	view_filter = function(self,selected,to_select)
		return to_select
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_xuanhuoCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>1 and c
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_xuanhuo = sgs.CreateTriggerSkill{
	name = "ov_xuanhuo",
	events = {sgs.EventPhaseEnd},
	view_as_skill = ov_xuanhuovs,
	on_trigger = function(self,event,player,data,room)
		if player:getPhase()==sgs.Player_Draw
		and player:getCardCount()>0
		then
			room:askForUseCard(player,"@@ov_xuanhuo","ov_xuanhuo0:")
		end
	end
}
ov_fazheng:addSkill(ov_xuanhuo)

ov_sunluban = sgs.General(extension,"ov_sunluban","wu",3,false)
ov_zenhui = sgs.CreateTriggerSkill{
	name = "ov_zenhui",
	events = {sgs.TargetSpecifying},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.TargetSpecifying
		then
			local use = data:toCardUse()
			if player:getMark("ov_zenhuiUse-PlayClear")>0
			or use.to:length()>1
			then return end
			if use.card:isKindOf("Slash")
			or use.card:isNDTrick() and use.card:isBlack()
			then
				local tos = sgs.SPlayerList()
				for i,p in sgs.list(room:getAlivePlayers())do
					if use.to:contains(p) then continue end
					if player:canUse(use.card,p)
					then tos:append(p) end
				end
				if tos:isEmpty() then return end
				player:setTag("ov_zenhuiData",data)
				tos = room:askForPlayerChosen(player,tos,"ov_zenhui","ov_zenhui0:"..use.card:objectName(),true,true)
				if not tos then return end
				player:addMark("ov_zenhuiUse-PlayClear")
				room:broadcastSkillInvoke("zenhui")
				local choice = "ov_zenhui2"
				if tos:getCardCount(true,true)>0
				then choice = "ov_zenhui1+ov_zenhui2" end
				choice = room:askForChoice(player,"ov_zenhui",choice,ToData(tos))
				if choice=="ov_zenhui1"
				then
					choice = room:askForCardChosen(player,tos,"hej","ov_zenhui")
					room:obtainCard(player,choice,false)
					use.from = tos
				else
					if use.card:isKindOf("Collateral")
					then
						local tos = sgs.SPlayerList()
						for i,to in sgs.list(room:getAlivePlayers())do
							if can:canSlash(to) then tos:append(to) end
						end
						tos = room:askForPlayerChosen(player,tos,"ov_qirang1","ov_qirang1:"..can:objectName()..":ov_zenhui",true)
						if tos then can:setTag("collateralVictim",ToData(tos)) else return end
					end
					use.to:append(tos)
					room:sortByActionOrder(use.to)
				end
				data:setValue(use)
			end
			
		end
		return false
	end
}
ov_sunluban:addSkill(ov_zenhui)
ov_jiaojin = sgs.CreateTriggerSkill{
	name = "ov_jiaojin",
	events = {sgs.DamageInflicted}, 
	on_trigger = function(self,event,player,data,room)
    	if event==sgs.DamageInflicted
		then
		    local damage = data:toDamage()
			if damage.from and damage.from:isMale()
			and room:askForCard(player,"^BasicCard","ov_jiaojin0:",data,"ov_jiaojin")
			then
				room:broadcastSkillInvoke("jiaojin")
				return DamageRevises(data,-damage.damage,player)
			end
		end
		return false
	end
}
ov_sunluban:addSkill(ov_jiaojin)

ov_caohong = sgs.General(extension,"ov_caohong","wei")
ov_yuanhuCard = sgs.CreateSkillCard{
	name = "ov_yuanhuCard",
	will_throw = false,
	skill_name = "yuanhu",
	filter = function(self,targets,to_select,from)
		local n = sgs.Sanguosha:getCard(self:getEffectiveId())
		n = n:getRealCard():toEquipCard():location()
		return to_select:hasEquipArea(n)
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
		for i,target in sgs.list(targets)do
			if target:getHp()<=source:getHp()
			or target:getHandcardNum()<=source:getHandcardNum()
			then
				source:drawCards(1,"ov_yuanhu")
				source:addMark("ov_yuanhuUse-Clear")
			end
			InstallEquip(self,source,"ov_yuanhu",target)
			i = sgs.Sanguosha:getCard(self:getEffectiveId())
			if i:isKindOf("Weapon")
			then
				i = sgs.SPlayerList()
				for _,p in sgs.list(room:getAlivePlayers())do
					if target:distanceTo(p)==1
					and source:canDiscard(p,"hej")
					then i:append(p) end
				end
				if i:isEmpty() then continue end
				i = PlayerChosen("ov_yuanhu",source,i,"ov_yuanhu1:"..target:objectName())
				local id = room:askForCardChosen(source,i,"hej","ov_yuanhu",false,sgs.Card_MethodDiscard)
				room:throwCard(id,i,source)
			elseif i:isKindOf("Armor")
			then
				target:drawCards(1,"ov_yuanhu")
			else
				room:recover(target,sgs.RecoverStruct(source))
			end
		end
	end
}
ov_yuanhuvs = sgs.CreateViewAsSkill{
	name = "ov_yuanhu",
	n = 1,
	response_pattern = "@@ov_yuanhu",
	view_filter = function(self,selected,to_select)
		return to_select:isKindOf("EquipCard")
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_yuanhuCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_yuanhuCard")<1
	end,
}
ov_yuanhu = sgs.CreateTriggerSkill{
	name = "ov_yuanhu",
	events = {sgs.EventPhaseProceeding},
	view_as_skill = ov_yuanhuvs,
	on_trigger = function(self,event,player,data,room)
		if player:getPhase()==sgs.Player_Finish
		and player:getMark("ov_yuanhuUse-Clear")>0
		and player:getCardCount()>0
		then
			room:askForUseCard(player,"@@ov_yuanhu","ov_yuanhu0:")
		end
	end
}
ov_caohong:addSkill(ov_yuanhu)
ov_juezhu = sgs.CreateTriggerSkill{
	name = "ov_juezhu",
	events = {sgs.EventPhaseProceeding,sgs.Death},
	frequency = sgs.Skill_Limited,
	limit_mark = "@ov_juezhu",
	waked_skills = "feiying",
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Start
		and player:getMark("@ov_juezhu")>0
		and player:hasEquipArea()
		and ToSkillInvoke(self,player)
		then
			room:doSuperLightbox(player:getGeneralName(),self:objectName())
			room:removePlayerMark(player,"@ov_juezhu")
			local n = ThrowEquipArea(self,player)
			player:setMark("ov_juezhu_EquipArea",n)
			n = PlayerChosen(self,player,nil,"ov_juezhu0:")
			room:acquireSkill(n,"feiying")
			n:throwJudgeArea()
			n:setTag("ov_juezhu_"..player:objectName(),ToData(true))
		elseif event==sgs.Death
		then
			local death = data:toDeath()
			if death.who:getTag("ov_juezhu_"..player:objectName()):toBool()
			then
				Skill_msg(self,player)
				player:obtainEquipArea(player:getMark("ov_juezhu_EquipArea"))
			end
		end
	end
}
ov_caohong:addSkill(ov_juezhu)

ov_zhanhe = sgs.General(extension,"ov_zhanhe","qun")
ov_zhilve = sgs.CreateTriggerSkill{
	name = "ov_zhilve",
	events = {sgs.EventPhaseProceeding,sgs.DrawNCards,sgs.CardUsed},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Start
		and ToSkillInvoke(self,player)
		then
			room:broadcastSkillInvoke("xingzhilve")
			local choice = "ov_zhilve2"
			if room:canMoveField("ej")
			then choice = "ov_zhilve1+ov_zhilve2" end
			choice = room:askForChoice(player,"ov_zhilve",choice)
			if choice=="ov_zhilve1"
			then
				choice = MoveFieldCard(self,player)
				if not choice then return end
				if choice.to_place~=sgs.Player_PlaceEquip
				then room:addPlayerMark(player,"ov_zhilvedebf-Clear")
				else room:loseHp(player) end
			else
				room:addPlayerMark(player,"ov_zhilvebf-Clear")
			end
		elseif event==sgs.DrawNCards
		and player:getMark("ov_zhilvebf-Clear")>0
		then
			Skill_msg(self,player)
			data:setValue(data:toInt()+1)
		elseif event==sgs.CardUsed
		and player:getMark("ov_zhilvebf-Clear")>0
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
			and player:getMark("ov_zhilveUseSlash-Clear")<1
			then
				Skill_msg(self,player)
				room:addPlayerMark(player,"ov_zhilveUseSlash-Clear")
				room:addPlayerHistory(player,use.card:getClassName(),-1)
				use.m_addHistory = false
				data:setValue(use)
			end
		end
	end
}
ov_zhanhe:addSkill(ov_zhilve)
ov_zhilvebf = sgs.CreateTargetModSkill{
	name = "#ov_zhilvebf",
	pattern = "Slash",
	residue_func = function(self,from,card)--额外使用
	end,
	distance_limit_func = function(self,from,card,to)--使用距离
		if from:hasSkill("ov_zhilve")
		and from:getMark("ov_zhilvebf-Clear")>0
		and from:getMark("ov_zhilveUseSlash-Clear")<1
		then return 998 end
	end,
	extra_target_func = function(self,from,card)--目标数
	end
}
ov_zhanhe:addSkill(ov_zhilvebf)
extension:insertRelatedSkills("ov_zhilve", "#ov_zhilvebf")
ov_zhilvedebf = sgs.CreateMaxCardsSkill{
    name = "#ov_zhilvedebf",
	extra_func = function(self,target)
		if target:getMark("ov_zhilvedebf-Clear")>0
		then return -1 end
	end 
}
ov_zhanhe:addSkill(ov_zhilvedebf)
extension:insertRelatedSkills("ov_zhilve", "#ov_zhilvedebf")

ov_guanqiujian = sgs.General(extension,"ov_guanqiujian","wei")
ov_zhengrong = sgs.CreateTriggerSkill{
	name = "ov_zhengrong",
	events = {sgs.Damage,sgs.CardFinished},
	on_trigger = function(self,event,player,data,room)
		if player:getPhase()~=sgs.Player_Play
		then return end
		if event==sgs.Damage
		then
			if player:getMark("ov_zhengrongDamage-PlayClear")>0
			then return end
			player:addMark("ov_zhengrongDamage-PlayClear")
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if use.card:getTypeId()<1
			or use.to:length()<1
			then return end
			local can
			for i,to in sgs.list(use.to)do
				if to:objectName()~=player:objectName()
				then
					player:addMark("ov_zhengrongCard-PlayClear")
					can = true
					break
				end
			end
			if not can
			or math.mod(player:getMark("ov_zhengrongCard-PlayClear"),2)==1
			then return end
		end
		local tos = sgs.SPlayerList()
		for i,p in sgs.list(room:getOtherPlayers(player))do
			if p:getCardCount()>0
			then tos:append(p) end
		end
		if tos:isEmpty() then return end
		tos = room:askForPlayerChosen(player,tos,"ov_zhengrong","ov_zhengrong0:",true,true)
		if not tos then return end
		room:broadcastSkillInvoke("zhengrong")
		tos = room:askForCardChosen(player,tos,"he","ov_zhengrong")
		if tos<0 then return end
		player:addToPile("honor",tos)
	end
}
ov_guanqiujian:addSkill(ov_zhengrong)
ov_hongjuCard = sgs.CreateSkillCard{
	name = "ov_hongjuCard",
	will_throw = false,
	target_fixed = true,
	handling_method = sgs.Card_MethodNone,
	on_use = function(self,room,source,targets)
		local tocs = dummyCard()
		local toc = self:getSubcards()
		self:clearSubcards()
		for _,id in sgs.list(toc)do
			if source:handCards():contains(id)
			then tocs:addSubcard(id) else self:addSubcard(id) end
		end
		toc = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE,source:objectName())
		source:addToPile("honor",tocs)
		room:obtainCard(source,self,toc)
	end
}
ov_hongjuVS = sgs.CreateViewAsSkill{
	name = "ov_hongju",
	n = 999,
	response_pattern = "@@ov_hongju",
	expand_pile = "honor",
	view_filter = function(self,selected,to_select)
		if to_select:isEquipped()
		then return end
		return true
	end,
	view_as = function(self,cards)
		local card = ov_hongjuCard:clone()
		local n,x = 0,0
		for _,c in sgs.list(cards)do
			card:addSubcard(c)
			if sgs.Self:getPileName(c:getEffectiveId())~="honor"
			then n = n+1 else x = x+1 end
		end
		return #cards>0 and n==x and card
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_hongju = sgs.CreateTriggerSkill{
	name = "ov_hongju",
	frequency = sgs.Skill_Wake,
	view_as_skill = ov_hongjuVS,
	events = {sgs.EventPhaseStart},
	waked_skills = "ov_qingce,ov_saotao",
	can_trigger = function(self,target)
	   	return target and target:hasSkill(self)
		and target:getPhase()==sgs.Player_Start
	   	and target:getMark(self:objectName())<1
		and (target:canWake(self:objectName()) or target:getPile("honor"):length()>2)
	end,
	on_trigger = function(self,event,player,data,room)
	  	room:broadcastSkillInvoke("hongju")--播放配音
		SkillWakeTrigger(self,player,0,"guanqiujian")
		player:drawCards(player:getPile("honor"):length(),"ov_hongju")
		room:askForUseCard(player,"@@ov_hongju","@ov_hongju0",-1,sgs.Card_MethodNone)
		room:acquireSkill(player,"ov_qingce")
		if ToSkillInvoke(self,player,nil,ToData("ov_hongju1:"))
		then
			room:loseMaxHp(player)
			room:acquireSkill(player,"ov_saotao")
		end
	end
}
ov_guanqiujian:addSkill(ov_hongju)
ov_qingceCard = sgs.CreateSkillCard{
	name = "ov_qingceCard",
	skill_name = "qingce",
--	will_throw = false,
--	target_fixed = true,
--	handling_method = sgs.Card_MethodNone,
	filter = function(self,targets,to_select,from)
		return to_select:getCardCount(true,true)>0
		and to_select:objectName()~=from:objectName()
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
		for i,target in sgs.list(targets)do
			i = room:askForCardChosen(source,target,"hej","ov_qingce",false,sgs.Card_MethodDiscard)
			if i<0 then continue end
			room:throwCard(i,target,source)
		end
	end
}
ov_qingce = sgs.CreateViewAsSkill{
	name = "ov_qingce",
	n = 1,
	expand_pile = "honor",
	response_pattern = "@@ov_qingce",
	view_filter = function(self,selected,to_select)
		return sgs.Self:getPileName(to_select:getEffectiveId())=="honor"
	end,
	view_as = function(self,cards)
		local card = ov_qingceCard:clone()
		for _,c in sgs.list(cards)do
			card:addSubcard(c)
		end
		return #cards>0 and card
	end,
	enabled_at_play = function(self,player)
		return player:getPile("honor"):length()>0
	end,
}
addToSkills(ov_qingce)
ov_saotao = sgs.CreateTriggerSkill{
	name = "ov_saotao",
	events = {sgs.CardUsed},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
			or use.card:isNDTrick()
			then
				room:sendCompulsoryTriggerLog(player,"ov_saotao",true,true)
				local no_respond = use.no_respond_list
				for i,to in sgs.list(room:getAlivePlayers())do
					table.insert(no_respond,to:objectName())
				end
				use.no_respond_list = no_respond
				data:setValue(use)
			end
		end
	end
}
addToSkills(ov_saotao)

ov_puyangxing = sgs.General(extension,"ov_puyangxing","wu",3)
ov_zhengjian = sgs.CreateTriggerSkill{
	name = "ov_zhengjian",
	events = {sgs.GameStart},
	on_trigger = function(self,event,player,data,room)
        if event==sgs.GameStart
	    then
			Skill_msg(self,player,math.random(1,2))
			local choice = room:askForChoice(player,"ov_zhengjian","ov_zhengjian1+ov_zhengjian2")
			Log_message("$ov_zhengjian0",player,nil,nil,"ov_zhengjian",choice)
			player:setTag("ov_zhengjian",ToData(choice))
			room:setPlayerMark(player,"&"..choice,1)
		end
		return false
	end,
}
ov_zhengjianbf = sgs.CreateTriggerSkill{
	name = "#ov_zhengjianbf",
	events = {sgs.EventPhaseEnd,sgs.CardUsed,sgs.CardsMoveOneTime}, 
	can_trigger = function(self,target)
		return target and target:isAlive()
	end,
	on_trigger = function(self,event,player,data,room)
		for i,owner in sgs.list(room:findPlayersBySkillName("ov_zhengjian"))do
	    i = owner:getTag("ov_zhengjian"):toString()
		if owner:objectName()==player:objectName()
		or player:getPhase()~=sgs.Player_Play
		or i=="" then continue end
		if event==sgs.EventPhaseEnd
		then
			if player:getMark(i.."-PlayClear")<1
			then
				Skill_msg("ov_zhengjian",owner,math.random(1,2))
				if owner:getTag("ov_zhongchi"):toBool()
				then
					if ToSkillInvoke("ov_zhengjian",owner,player)
					then
						room:damage(sgs.DamageStruct("ov_zhengjian",owner,player))
					end
				else
					local c = room:askForExchange(player,"ov_zhengjian",1,1,true,"ov_zhengjian0:"..owner:objectName())
					if c then room:giveCard(player,owner,c,"ov_zhengjian") else continue end
				end
				if ToSkillInvoke("ov_zhengjian",owner,nil,ToData("ov_zhengjian3:"))
				then
					local choice = room:askForChoice(owner,"ov_zhengjian","ov_zhengjian1+ov_zhengjian2")
					Log_message("$ov_zhengjian10",owner,nil,nil,"ov_zhengjian",choice)
					room:setPlayerMark(owner,"&"..i,0)
					room:setPlayerMark(owner,"&"..choice,1)
					owner:setTag("ov_zhengjian",ToData(choice))
				end
			end
		elseif event==sgs.CardUsed
		and i=="ov_zhengjian1"
		then
			local use = data:toCardUse()
			if use.card:getTypeId()==2 or use.card:getTypeId()==3
			then player:addMark(i.."-PlayClear") end
		elseif event==sgs.CardsMoveOneTime
		and i=="ov_zhengjian2"
		then
	    	local move = data:toMoveOneTime()
			if move.to and move.to:objectName()==player:objectName()
			and move.to_place==sgs.Player_PlaceHand
			then player:addMark(i.."-PlayClear") end
		end
		end
		return false
	end
}
ov_puyangxing:addSkill(ov_zhengjian)
ov_puyangxing:addSkill(ov_zhengjianbf)
extension:insertRelatedSkills("ov_zhengjian", "#ov_zhengjianbf")
ov_zhongchi = sgs.CreateTriggerSkill{
	name = "ov_zhongchi",
	events = {sgs.DamageForseen,sgs.CardsMoveOneTime}, 
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data,room)
    	if event==sgs.DamageForseen
		then
		    local damage = data:toDamage()
			if player:getTag("ov_zhongchi"):toBool()
			and damage.card and damage.card:isKindOf("Slash")
			then
				room:sendCompulsoryTriggerLog(player,"ov_zhongchi",true,true)
				DamageRevises(data,1,player)
			end
		elseif event==sgs.CardsMoveOneTime
		then
	    	local move = data:toMoveOneTime()
			if move.to and move.to:objectName()==player:objectName()
			and move.reason.m_skillName=="ov_zhengjian"
			and move.to_place==sgs.Player_PlaceHand
			and BeMan(room,move.from):getMark("ov_zhongchi")<1
			then
				BeMan(room,move.from):addMark("ov_zhongchi")
				room:addPlayerMark(player,"&ov_zhongchi")
				if player:getMark("&ov_zhongchi")>=(player:getSiblings():length()+1)/2
				then
					room:sendCompulsoryTriggerLog(player,"ov_zhongchi",true,true)
					player:setTag("ov_zhongchi",ToData(true))
					Log_message("$ov_zhongchi0",player,nil,nil,"ov_zhengjian")
					room:changeTranslation(player,"ov_zhengjian",2)
				end
			end
		end
		return false
	end
}
ov_puyangxing:addSkill(ov_zhongchi)

ov_beimihu = sgs.General(extension,"ov_beimihu$","qun",3,false)
ov_beimihu:addSkill("zongkui")
ov_beimihu:addSkill("guju")
ov_beimihu:addSkill("baijia")
ov_bingzhao = sgs.CreateTriggerSkill{
	name = "ov_bingzhao$",
	events = {sgs.DamageDone,sgs.GameStart,sgs.BeforeCardsMove},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.DamageDone
		then
			local damage = data:toDamage()
			if damage.to:getMark("&kui")>0
			then
				for _,owner in sgs.list(room:findPlayersBySkillName("ov_bingzhao"))do
					if owner:hasLordSkill("ov_bingzhao")
					and owner:getMark("&ov_bingzhao+:+"..damage.to:getKingdom())>0
					then owner:setTag("ov_bingzhao",ToData(damage.to)) end
				end
			end
		elseif event==sgs.GameStart
		and player:hasLordSkill("ov_bingzhao")
		then
			local kd = sgs.Sanguosha:getKingdoms()
			table.removeOne(kd,player:getKingdom())
			if #kd<1 then return end
			kd = table.concat(kd,"+")
			kd = room:askForChoice(player,"ov_bingzhao",kd)
			room:addPlayerMark(player,"&ov_bingzhao+:+"..kd)
		elseif event==sgs.BeforeCardsMove
		then
	     	local move = data:toMoveOneTime()
			if move.reason.m_reason==sgs.CardMoveReason_S_REASON_DRAW
			and move.reason.m_skillName=="guju"
			then
				local move_to = BeMan(room,move.to)
				if move_to and move_to:hasLordSkill("ov_bingzhao")
				then
					local to = move_to:getTag("ov_bingzhao"):toPlayer()
					move_to:removeTag("ov_bingzhao")
					if to and to:isAlive() and ToSkillInvoke(self,to,move_to)
					then
						to = move.card_ids:length()+1
						room:returnToTopDrawPile(move.card_ids)
						move.card_ids = sgs.IntList()
						data:setValue(move)
						move_to:drawCards(to,"guju")
					end
				end
			end
		end
	end,
}
ov_beimihu:addSkill(ov_bingzhao)

ov_liuxie = sgs.General(extension,"ov_liuxie$","qun",3)
ov_liuxie:addSkill("tianming")
ov_liuxie:addSkill("mizhao")
ov_zhuitingVS = sgs.CreateViewAsSkill{
	name = "ov_zhuitingvs&",
	n = 1,
	view_filter = function(self,selected,to_select)
	   	for _,p in sgs.list(sgs.Self:getAliveSiblings())do
			if p:hasLordSkill("ov_zhuiting")
			and p:getMark("ov_zhuiting")>0
			then
				return to_select:getColor()==p:getMark("ov_zhuiting")-1
				and not to_select:isEquipped()
			end
		end
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = sgs.Sanguosha:cloneCard("nullification")
		c:setSkillName("ov_zhuiting")
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return false
	end,
	enabled_at_response = function(self,player,pattern)
	   	if pattern~="nullification" then return end
		for _,p in sgs.list(player:getAliveSiblings())do
			if p:hasLordSkill("ov_zhuiting")
			and p:getMark("ov_zhuiting")>0
			and player:getHandcardNum()>0
			then
				return player:getKingdom()=="qun"
				or player:getKingdom()=="wei"
			end
		end
	end,
	enabled_at_nullification = function(self,player)				
	   	for _,p in sgs.list(player:getAliveSiblings())do
			if p:hasLordSkill("ov_zhuiting")
			and p:getMark("ov_zhuiting")>0
			and player:getHandcardNum()>0
			then
				return player:getKingdom()=="qun"
				or player:getKingdom()=="wei"
			end
		end
	end
}
ov_zhuiting = sgs.CreateTriggerSkill{
	name = "ov_zhuiting$",
	events = {sgs.EventAcquireSkill,sgs.CardsMoveOneTime,sgs.CardEffected,sgs.PostCardEffected},
	can_trigger = function(self,target)
		return target and target:hasLordSkill(self)
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		for _,p in sgs.list(room:getOtherPlayers(player))do
			if p:getKingdom()~="qun" and p:getKingdom()~="wei"
			or p:hasSkill("ov_zhuitingvs")
			then continue end
			room:attachSkillToPlayer(p,"ov_zhuitingvs")
		end
		if event==sgs.CardEffected
		then
            local effect = data:toCardEffect()
			if effect.card:isKindOf("TrickCard")
			then
				room:setPlayerMark(player,"ov_zhuiting",effect.card:getColor()+1)
			end
		elseif event==sgs.PostCardEffected
		then
            local effect = data:toCardEffect()
			if effect.card:isKindOf("TrickCard")
			then
				room:setPlayerMark(player,"ov_zhuiting",0)
			end
		end
	end,
}
ov_liuxie:addSkill(ov_zhuiting)
addToSkills(ov_zhuitingVS)

ov_liuyao = sgs.General(extension,"ov_liuyao$","qun")
ov_liuyao:addSkill("kannan")
ov_niju = sgs.CreateTriggerSkill{
	name = "ov_niju$",
	events = {sgs.PindianVerifying},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.PindianVerifying
	   	then
			for c,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
				local pindian = data:toPindian()
				local qun = room:getLieges("qun",owner):length()
				if not owner:hasLordSkill(self) or qun<1 then continue end
				if (pindian.from:objectName()==owner:objectName() or pindian.to:objectName()==owner:objectName())
				and ToSkillInvoke(self,owner,nil,data)
				then
					local ids = sgs.IntList()
					ids:append(pindian.from_card:getEffectiveId())
					ids:append(pindian.to_card:getEffectiveId())
					room:fillAG(ids,owner)
					local id = room:askForAG(owner,ids,false,self:objectName(),"ov_niju0")
					local choice = room:askForChoice(owner,"ov_niju","ov_niju2="..qun.."+ov_niju3="..qun)
					room:clearAG(owner)
					if id==pindian.from_card:getEffectiveId()
					then
						if choice:startsWith("ov_niju2")
						then
							pindian.from_number = pindian.from_number+qun
							if pindian.from_number>13 then pindian.from_number=13 end
							Log_message("$ov_niju10",owner,nil,id,"+"..qun,pindian.from_number)
						else
							pindian.from_number = pindian.from_number-qun
							if pindian.from_number<1 then pindian.from_number=1 end
							Log_message("$ov_niju10",owner,nil,id,"-"..qun,pindian.from_number)
						end
					else
						if choice:startsWith("ov_niju2")
						then
							pindian.to_number = pindian.to_number+qun
							if pindian.to_number>13 then pindian.to_number=13 end
							Log_message("$ov_niju10",owner,nil,id,"+"..qun,pindian.to_number)
						else
							pindian.to_number = pindian.to_number-qun
							if pindian.to_number<1 then pindian.to_number=1 end
							Log_message("$ov_niju10",owner,nil,id,"-"..qun,pindian.to_number)
						end
					end
					data:setValue(pindian)
					if pindian.from_number==pindian.to_number
					then owner:drawCards(qun,"ov_niju") end
				end
			end
		end
		return false
	end
}
ov_liuyao:addSkill(ov_niju)

ov_liuyu = sgs.General(extension,"ov_liuyu$","qun",2)
ov_liuyu:addSkill("zhige")
ov_liuyu:addSkill("zongzuo")
ov_chongwang = sgs.CreateTriggerSkill{
	name = "ov_chongwang$",
	events = {sgs.EventPhaseStart,sgs.EventPhaseChanging},
--	view_as_skill = ov_chongwangVS,
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	for c,owner in sgs.list(room:findPlayersBySkillName("ov_chongwang"))do
			if not owner:hasLordSkill(self) then continue end
			if owner:objectName()==player:objectName()
			then
				if event==sgs.EventPhaseChanging
				then
					local change = data:toPhaseChange()
					if change.to==sgs.Player_NotActive
					then
						for i,p in sgs.list(room:getOtherPlayers(owner))do
							if p:getMark("&ov_chongwang+#"..owner:objectName())>0
							then
								room:setPlayerMark(p,"&ov_chongwang+#"..owner:objectName(),0)
							end
						end
					end
				end
			elseif event==sgs.EventPhaseStart
			and player:getMark("ov_chongwang"..owner:objectName())<1
			and player:getPhase()==sgs.Player_Play
			and player:getKingdom()=="qun"
			and player:getCardCount()>0
			then
				player:setTag("ov_chongwang",ToData(owner))
				c = room:askForExchange(player,"ov_chongwang",1,1,true,"ov_chongwang0:"..owner:objectName(),true)
				if c
				then
					ToSkillInvoke(self,player,owner,true)
					room:giveCard(player,owner,c,"ov_chongwang")
					player:addMark("ov_chongwang"..owner:objectName())
					room:addPlayerMark(player,"&ov_chongwang+#"..owner:objectName())
				end
			end
		end
	end,
}
ov_chongwangbf = sgs.CreateProhibitSkill{
	name = "#ov_chongwangbf",
	is_prohibited = function(self,from,to,card)
		if card:isKindOf("Slash")
		or card:isKindOf("TrickCard") and card:isDamageCard()
		then
			if from:hasLordSkill("ov_chongwang")
			then
				if to and to:getMark("&ov_chongwang+#"..from:objectName())>0
				then return true end
			elseif to and to:hasLordSkill("ov_chongwang")
			then
				if from and from:getMark("&ov_chongwang+#"..to:objectName())>0
				then return true end
			end
		end
	end
}
ov_liuyu:addSkill(ov_chongwang)
ov_liuyu:addSkill(ov_chongwangbf)
extension:insertRelatedSkills("ov_chongwang", "#ov_chongwangbf")

ov_zhangxiu = sgs.General(extension,"ov_zhangxiu$","qun")
ov_zhangxiu:addSkill("xiongluan")
ov_zhangxiu:addSkill("congjian")
ov_juxiangCard = sgs.CreateSkillCard{
	name = "ov_juxiangCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		return to_select:hasLordSkill("ov_juxiang")
		and to_select:objectName()~=from:objectName()
		and to_select:getMark("ov_juxiang-PlayClear")<1
		and #targets<1
	end,
	about_to_use = function(self,room,use)
		local lord = use.to:at(0)
		room:broadcastSkillInvoke("ov_juxiang")--播放配音
		room:doAnimate(1,use.from:objectName(),lord:objectName())
		room:notifySkillInvoked(lord,"ov_juxiang")
		room:addPlayerMark(lord,"ov_juxiang-PlayClear")
		local msg = sgs.LogMessage()
		msg.type = "$bf_huangtian0"
		msg.from = use.from
		msg.arg = lord:getGeneralName()
		msg.arg2 = "ov_juxiang"
		room:sendLog(msg)
		msg = self:getSubcards():at(0)
		msg = sgs.Sanguosha:getCard(msg)
		local e = msg:getRealCard():toEquipCard():location()
		if lord:hasEquipArea(e)
		then
			InstallEquip(msg,use.from,"ov_juxiang",lord)
		else
			room:giveCard(use.from,lord,self,"ov_juxiang")
			lord:obtainEquipArea(e)
		end
	end
}
ov_juxiangVS = sgs.CreateViewAsSkill{
	name = "ov_juxiangvs&",
	n = 1,
	view_filter = function(self,selected,to_select)
		return to_select:isEquipped()
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_juxiangCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		for _,p in sgs.list(player:getAliveSiblings())do
			if p:hasLordSkill("ov_juxiang")
			and p:getMark("ov_juxiang-PlayClear")<1
			then
				return player:getKingdom()=="qun"
				and player:hasEquip()
			end
		end
	end,
}
ov_juxiang = sgs.CreateTriggerSkill{
	name = "ov_juxiang$",
	events = {sgs.EventAcquireSkill,sgs.CardsMoveOneTime},
	can_trigger = function(self,target)
		return target and target:hasLordSkill(self)
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		for _,p in sgs.list(room:getLieges("qun",player))do
			if p:hasSkill("ov_juxiangvs") then continue end
			room:attachSkillToPlayer(p,"ov_juxiangvs")
		end
	end,
}
ov_zhangxiu:addSkill(ov_juxiang)
addToSkills(ov_juxiangVS)

ov_zhanglu = sgs.General(extension,"ov_zhanglu$","qun",3)
ov_zhanglu:addSkill("yishe")
ov_zhanglu:addSkill("bushi")
ov_zhanglu:addSkill("midao")
ov_shijunCard = sgs.CreateSkillCard{
	name = "ov_shijunCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		return to_select:hasLordSkill("ov_shijun")
		and to_select:objectName()~=from:objectName()
		and to_select:getMark("ov_shijun-PlayClear")<1
		and to_select:getPile("rice"):isEmpty()
		and #targets<1
	end,
	about_to_use = function(self,room,use)
		local lord = use.to:at(0)
		room:broadcastSkillInvoke("ov_shijun")--播放配音
		room:doAnimate(1,use.from:objectName(),lord:objectName())
		room:notifySkillInvoked(lord,"ov_shijun")
		room:addPlayerMark(lord,"ov_shijun-PlayClear")
		local msg = sgs.LogMessage()
		msg.type = "$bf_huangtian0"
		msg.from = use.from
		msg.arg = lord:getGeneralName()
		msg.arg2 = "ov_shijun"
		room:sendLog(msg)
		use.from:drawCards(1,"ov_shijun")
		msg = room:askForExchange(use.from,"ov_shijun",1,1,true,"ov_shijun0:"..lord:objectName())
		if msg then lord:addToPile("rice",msg) end
	end
}
ov_shijunvs = sgs.CreateViewAsSkill{
	name = "ov_shijunvs&",
	view_as = function(self,cards)
		return ov_shijunCard:clone()
	end,
	enabled_at_play = function(self,player)
		for _,p in sgs.list(player:getAliveSiblings())do
			if p:hasLordSkill("ov_shijun")
			and p:getPile("rice"):isEmpty()
			and p:getMark("ov_shijun-PlayClear")<1
			then
				return player:getKingdom()=="qun"
			end
		end
	end,
}
ov_shijun = sgs.CreateTriggerSkill{
	name = "ov_shijun$",
	events = {sgs.EventAcquireSkill,sgs.CardsMoveOneTime},
	can_trigger = function(self,target)
		return target and target:hasLordSkill(self)
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		for _,p in sgs.list(room:getLieges("qun",player))do
			if p:hasSkill("ov_shijunvs") then continue end
			room:attachSkillToPlayer(p,"ov_shijunvs")
		end
	end,
}
ov_zhanglu:addSkill(ov_shijun)
addToSkills(ov_shijunvs)

ov_sunjian = sgs.General(extension,"ov_sunjian$","wu",5)
ov_sunjian:setStartHp(4)
ov_sunjian:addSkill("yinghun")
ov_sunjian:addSkill("olwulie")
ov_poluCard = sgs.CreateSkillCard{
	name = "ov_poluCard",
--	will_throw = false,
	skill_name = "mobilepolu",
	filter = function(self,targets,to_select,from)
		return to_select:isAlive()
	end,
	on_use = function(self,room,source,targets)
		local n = source:getMark("&ov_polu")
		for i,to in sgs.list(targets)do
			to:drawCardsList(n,"ov_polu")
		end
		room:addPlayerMark(source,"&ov_polu")
	end
}
ov_poluvs = sgs.CreateViewAsSkill{
	name = "ov_polu",
	response_pattern = "@@ov_polu",
	view_as = function(self,cards)
		return ov_poluCard:clone()
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_polu = sgs.CreateTriggerSkill{
	name = "ov_polu$",
	events = {sgs.Death},
	view_as_skill = ov_poluvs,
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.Death
		then
			local death = data:toDeath()
			if player:objectName()~=death.who:objectName() then return end
			for c,owner in sgs.list(room:getAllPlayers(true))do
				if owner:isDead() and owner:objectName()~=death.who:objectName()
				or not owner:hasLordSkill(self) then continue end
				if death.damage
				and death.damage.from
				and death.damage.from:getKingdom()=="wu"
				then
					room:askForUseCard(owner,"@@ov_polu","ov_polu0:"..owner:getMark("&ov_polu"))
				end
				if death.who:getKingdom()=="wu"
				then
					room:askForUseCard(owner,"@@ov_polu","ov_polu0:"..owner:getMark("&ov_polu"))
				end
			end
		end
	end,
}
ov_sunjian:addSkill(ov_polu)

ov_menghuo = sgs.General(extension,"ov_menghuo$","qun")
ov_menghuo:addSkill("huoshou")
ov_menghuo:addSkill("mobilezaiqi")
ov_qiushou = sgs.CreateTriggerSkill{
	name = "ov_qiushou$",
	events = {sgs.Death,sgs.Damage,sgs.CardFinished},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.Damage
		then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("SavageAssault")
			and damage.from:objectName()==player:objectName()
			then
				local n = room:getTag("ov_qiushou_"..damage.card:toString()):toInt()
				room:setTag("ov_qiushou_"..damage.card:toString(),ToData(n+damage.damage))
			end
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if use.card:isKindOf("SavageAssault")
			and use.from:objectName()==player:objectName()
			then
				local n = room:getTag("ov_qiushou_"..use.card:toString()):toInt()
				for i,owner in sgs.list(room:findPlayersBySkillName("ov_qiushou"))do
					if n>3 and owner:hasLordSkill(self)
					then
						room:sendCompulsoryTriggerLog(owner,"ov_qiushou",true,true)
						for _,p in sgs.list(room:getAlivePlayers())do
							if p:getKingdom()=="shu" or p:getKingdom()=="qun"
							then p:drawCardsList(1,"ov_qiushou") end
						end
					end
				end
				room:removeTag("ov_qiushou_"..use.card:toString())
			end
		elseif event==sgs.Death
		then
			local death = data:toDeath()
			if death.damage and death.damage.card
			and death.damage.card:isKindOf("SavageAssault")
			then
				local n = room:getTag("ov_qiushou_"..death.damage.card:toString()):toInt()
				room:setTag("ov_qiushou_"..death.damage.card:toString(),ToData(n+3))
			end
		end
	end,
}
ov_menghuo:addSkill(ov_qiushou)


ov_zhangji = sgs.General(extension,"ov_zhangji","wei",3)
ov_dingzhenCard = sgs.CreateSkillCard{
	name = "ov_dingzhenCard",
--	will_throw = false,
	filter = function(self,targets,to_select,from)
		return from:distanceTo(to_select)<=from:getHp()
	end,
	on_use = function(self,room,source,targets)
		for i,to in sgs.list(targets)do
			if room:askForCard(to,"Slash","ov_dingzhen1:"..source:objectName(),ToData(source))
			then continue end
			room:addPlayerMark(to,"&ov_dingzhen+#"..source:objectName())
		end
	end
}
ov_dingzhenvs = sgs.CreateViewAsSkill{
	name = "ov_dingzhen",
	response_pattern = "@@ov_dingzhen",
	view_as = function(self,cards)
		return ov_dingzhenCard:clone()
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_dingzhen = sgs.CreateTriggerSkill{
	name = "ov_dingzhen",
	view_as_skill = ov_dingzhenvs,
	events = {sgs.RoundStart,sgs.CardUsed,sgs.EventPhaseChanging},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.RoundStart
		and player:hasSkill(self)
	   	then
			for i,p in sgs.list(room:getAlivePlayers())do
				room:setPlayerMark(p,"&ov_dingzhen+#"..player:objectName(),0)
			end
			room:askForUseCard(player,"@@ov_dingzhen","ov_dingzhen0:"..player:getHp())
		elseif event==sgs.EventPhaseChanging
	   	then
			local change = data:toPhaseChange()
			if change.from==sgs.Player_NotActive
			then
				for i,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
					if player:getMark("&ov_dingzhen+#"..owner:objectName())<1 then continue end
					room:addPlayerMark(player,owner:objectName().."ov_dingzhen-Clear")
				end
			end
		elseif event==sgs.CardUsed
		and player:getPhase()~=sgs.Player_NotActive
		then
			local use = data:toCardUse()
			for i,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
				if player:getMark(owner:objectName().."ov_dingzhen-Clear")<1
				or use.card:getTypeId()<1 then continue end
				room:removePlayerMark(player,owner:objectName().."ov_dingzhen-Clear")
			end
		end
		return false
	end
}
ov_dingzhenbf = sgs.CreateProhibitSkill{
	name = "#ov_dingzhenbf",
	is_prohibited = function(self,from,to,card)
		if card:getTypeId()~=0
		and to and to:hasSkill("ov_dingzhen")
		and from:getMark(to:objectName().."ov_dingzhen-Clear")>0
		then self:setObjectName("ov_dingzhen") return true end
	end
}
ov_zhangji:addSkill(ov_dingzhen)
ov_zhangji:addSkill(ov_dingzhenbf)
extension:insertRelatedSkills("ov_dingzhen", "#ov_dingzhenbf")
ov_youye = sgs.CreateTriggerSkill{
	name = "ov_youye",
	events = {sgs.Damaged,sgs.Damage,sgs.EventPhaseProceeding},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local xu = player:getPile("ov_xu")
		local function ov_youyePREVIEW()
			local sp = sgs.SPlayerList()
			sp:append(room:getCurrent())
	    	local guojias = sgs.SPlayerList()
	    	guojias:append(player)
	    	local move = sgs.CardsMoveStruct(xu,player,player,sgs.Player_PlaceSpecial,sgs.Player_PlaceHand,
	    	sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,player:objectName(),self:objectName(),nil))
	    	move.from_pile_name = "ov_xu"
			local moves = sgs.CardsMoveList()
	    	moves:append(move)
	    	room:notifyMoveCards(true,moves,false,guojias)
	    	room:notifyMoveCards(false,moves,false,guojias)
			local ids = sgs.IntList()
			for i,id in sgs.list(xu)do
				ids:append(id)
			end
			player:setFlags("Current")
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE,player:objectName(),self:objectName(),nil)
			room:askForYiji(player,xu,self:objectName(),true,true,false,xu:length(),sp,reason,"ov_youye0:"..sp:at(0):objectName())
			move = sgs.CardsMoveStruct(sgs.IntList(),player,nil,sgs.Player_PlaceHand,sgs.Player_PlaceTable,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,player:objectName(),self:objectName(),nil))
			for i,id in sgs.list(ids)do
				if room:getCardPlace(id)~=sgs.Player_PlaceSpecial or room:getCardOwner(id)~=player
				then move.card_ids:append(id) xu:removeOne(id) end
			end
			player:setFlags("-Current")
			ids = sgs.IntList()
			for i,id in sgs.list(xu)do
				ids:append(id)
			end
	    	moves = sgs.CardsMoveList()
	    	moves:append(move)
	    	room:notifyMoveCards(true,moves,false,guojias)
	    	room:notifyMoveCards(false,moves,false,guojias)
	    	if player:isDead() or xu:isEmpty() then return end
			sp = room:getAlivePlayers()
			while room:askForYiji(player,xu,self:objectName(),true,true,false,-1,sp,reason,"ov_youye1:")do
				move = sgs.CardsMoveStruct(sgs.IntList(),player,nil,sgs.Player_PlaceHand,sgs.Player_PlaceTable,
				sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,player:objectName(),self:objectName(),nil))
				for i,id in sgs.list(ids)do
					if room:getCardPlace(id)~=sgs.Player_PlaceSpecial or room:getCardOwner(id)~=player
					then move.card_ids:append(id) xu:removeOne(id) end
				end
				ids = sgs.IntList()
				for i,id in sgs.list(xu)do
					ids:append(id)
				end
				moves = sgs.CardsMoveList()
				moves:append(move)
				room:notifyMoveCards(true,moves,false,guojias)
				room:notifyMoveCards(false,moves,false,guojias)
				if player:isDead() or xu:isEmpty() then return end
			end
			sp = dummyCard()
			sp:addSubcards(xu)
			room:obtainCard(player,sp)
		end
		if event==sgs.Damage
		then
			local damage = data:toDamage()
			if damage.to:hasSkill(self) and damage.from:objectName()==player:objectName()
			then player:addMark(damage.to:objectName().."ov_youye-Clear") end
			if damage.from:objectName()==player:objectName()
			and player:hasSkill(self)
			and xu:length()>0
			then
				room:sendCompulsoryTriggerLog(player,"ov_youye",true,true)
				ov_youyePREVIEW()
			end
		elseif event==sgs.Damaged
		then
			local damage = data:toDamage()
			if damage.to:objectName()==player:objectName()
			and player:hasSkill(self)
			and xu:length()>0
			then
				room:sendCompulsoryTriggerLog(player,"ov_youye",true,true)
				ov_youyePREVIEW()
			end
		elseif event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Finish
		then
			for i,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
				if player:getMark(owner:objectName().."ov_youye-Clear")>0
				or owner:objectName()==player:objectName()
				or owner:getPile("ov_xu"):length()>4
				then continue end
				room:sendCompulsoryTriggerLog(owner,"ov_youye",true,true)
				i = room:getNCards(1)
				owner:addToPile("ov_xu",i)
			end
		end
	end,
}
ov_zhangji:addSkill(ov_youye)

ov_fengxi = sgs.General(extension,"ov_fengxi","shu")
ov_qingkouvs = sgs.CreateViewAsSkill{
	name = "ov_qingkou",
	response_pattern = "@@ov_qingkou",
	view_as = function(self,cards)
		local c = sgs.Sanguosha:cloneCard("duel")
		c:setSkillName("ov_qingkou")
		return c
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_qingkou = sgs.CreateTriggerSkill{
	name = "ov_qingkou",
	view_as_skill = ov_qingkouvs,
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Start
		and CardIsAvailable(player,"duel","ov_qingkou")
	   	then
			local c = room:askForUseCard(player,"@@ov_qingkou","ov_qingkou0:")
			if c
			then
				c = room:getTag("damage_caused_"..c:toString()):toDamage()
				if c and c.from
				then
					Skill_msg(self,player)
					c.from:drawCardsList(1,"ov_qingkou")
					if c.from:objectName()==player:objectName()
					then
						player:skip(sgs.Player_Judge)
						player:skip(sgs.Player_Discard)
					end
				end
			end
		end
		return false
	end
}
ov_fengxi:addSkill(ov_qingkou)

ov_zhangning = sgs.General(extension,"ov_zhangning","qun",3,false)
ov_xingzhuiCard = sgs.CreateSkillCard{
	name = "ov_xingzhuiCard",
	target_fixed = true,
}
ov_xingzhuivs = sgs.CreateViewAsSkill{
	name = "ov_xingzhui",
	view_as = function(self,cards)
		return ov_xingzhuiCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_xingzhuiCard")<1
	end,
}
ov_xingzhui = sgs.CreateTriggerSkill{
	name = "ov_xingzhui",
	events = {sgs.CardUsed},
	view_as_skill = ov_xingzhuivs,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:objectName()~="ov_xingzhuiCard" then return end
			room:loseHp(player)
			SetShifa("ov_xingzhui",player).effect = function(owner,x)
				room:broadcastSkillInvoke(self:objectName())
				local ids = room:getNCards(x*2,false)
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER,owner:objectName(),"ov_xingzhui",nil)
				local move = sgs.CardsMoveStruct(ids,owner,sgs.Player_PlaceTable,reason)
				room:moveCardsAtomic(move,true)
				local d,dd = dummyCard(),dummyCard()
				for c,id in sgs.list(ids)do
					c = sgs.Sanguosha:getCard(id)
					if c:isBlack() then d:addSubcard(id)
					else dd:addSubcard(id) end
				end
				room:getThread():delay(1111)
				if d:subcardsLength()>0
				then
					owner:setMark("ov_xingzhui_x",x)
					room:fillAG(d:getSubcards(),owner)
					owner:setMark("ov_xingzhui_num",d:subcardsLength())
					local to = room:askForPlayerChosen(owner,room:getOtherPlayers(owner),"ov_xingzhui","ov_xingzhui0:",true,true)
					room:clearAG(owner)
					if to
					then
						to:obtainCard(d)
						if d:subcardsLength()>=x
						then
							room:damage(sgs.DamageStruct("ov_xingzhui",owner,to,x,sgs.DamageStruct_Thunder))
						end
					end
				end
				if dd:subcardsLength()>0
				then room:throwCard(dd,nil) end
			end
		end
	end,
}
ov_zhangning:addSkill(ov_xingzhui)
ov_juchen = sgs.CreateTriggerSkill{
	name = "ov_juchen",
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Finish
	   	then
			local n,m
			for c,p in sgs.list(room:getOtherPlayers(player))do
				if p:getHandcardNum()>player:getHandcardNum()
				then n = true end
				if p:getHp()>player:getHp()
				then m = true end
			end
			if n and m
			and ToSkillInvoke(self,player)
			then
				n = dummyCard()
				m = room:getAlivePlayers()
				room:sortByActionOrder(m)
				for c,p in sgs.list(m)do
					if p:getCardCount()<1 then continue end
					c = room:askForDiscard(p,"ov_juchen",1,1,false,true)
					if c:isRed() and not room:getCardOwner(c:getEffectiveId())
					then n:addSubcard(c) end
				end
				if n:subcardsLength()<1 then return end
				player:obtainCard(n)
			end
		end
		return false
	end
}
ov_zhangning:addSkill(ov_juchen)

ov_yufuluo = sgs.General(extension,"ov_yufuluo","qun",6)
ov_jiekuang = sgs.CreateTriggerSkill{
	name = "ov_jiekuang",
	events = {sgs.TargetConfirming,sgs.CardFinished},
--	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local function ov_jiekuangJudge()
			for i,p in sgs.list(room:getAlivePlayers())do
				if p:hasFlag("Global_Dying")
				then return end
			end
			return true
		end
		if event==sgs.TargetConfirming
		then
			for i,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
				local use = data:toCardUse()
				owner:setTag("ov_jiekuang",data)
				if (use.card:isKindOf("BasicCard") or use.card:isNDTrick())
--				and use.from:objectName()~=use.to:at(0):objectName()
				and use.from:objectName()~=owner:objectName()
				and ov_jiekuangJudge() and use.to:length()<2
				and use.to:at(0):getHp()<owner:getHp()
				and owner:getMark("ov_jiekuang-Clear")<1
				and ToSkillInvoke(self,owner,use.to:at(0))
				then
					owner:addMark("ov_jiekuang-Clear")
					if room:askForChoice(owner,"ov_jiekuang","ov_jiekuang1+ov_jiekuang2")~="ov_jiekuang1"
					then room:loseMaxHp(owner) else room:loseHp(owner) end
					owner:addMark("ov_jiekuang"..use.card:toString())
					use.to:removeOne(use.to:at(0))
					use.to:append(owner)
					room:sortByActionOrder(use.to)
					data:setValue(use)
				end
			end
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			for d,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
				if owner:getMark("ov_jiekuang"..use.card:toString())>0
				then
					owner:removeMark("ov_jiekuang"..use.card:toString())
					d = room:getTag("damage_caused_"..use.card:toString()):toDamage()
					if d and d.to then continue end
					d = dummyCard(use.card:objectName())
					d:setSkillName("_ov_jiekuang")
					if owner:canUse(d,use.from)
					then
						Skill_msg(self,owner)
						room:useCard(sgs.CardUseStruct(d,owner,use.from))
					end
				end
			end
		end
	end,
}
ov_yufuluo:addSkill(ov_jiekuang)
ov_neirao = sgs.CreateTriggerSkill{
	name = "ov_neirao",
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseStart},
	waked_skills = "ov_luanlve",
	can_trigger = function(self,target)
	   	return target and target:hasSkill(self)
	   	and target:getMark(self:objectName())<1
		and target:getPhase()==sgs.Player_Start
		and (target:canWake(self:objectName()) or target:getHp()+target:getMaxHp()<10)
	end,
	on_trigger = function(self,event,player,data,room)
		SkillWakeTrigger(self,player,0,player:getGeneralName())
		room:handleAcquireDetachSkills(player,"-ov_jiekuang|ov_luanlve")
		local n = player:getCardCount()
		player:throwAllHandCardsAndEquips()
		local d = dummyCard()
		for c,id in sgs.list(room:getDrawPile())do
			if d:subcardsLength()>=n then break end
			c = sgs.Sanguosha:getCard(id)
			if c:isKindOf("Slash")
			then
				d:addSubcard(id)
			end
		end
		player:obtainCard(d)
		n = n-d:subcardsLength()
		d:clearSubcards()
		for c,id in sgs.list(room:getDiscardPile())do
			if d:subcardsLength()>=n then break end
			c = sgs.Sanguosha:getCard(id)
			if c:isKindOf("Slash")
			then
				d:addSubcard(id)
			end
		end
		player:obtainCard(d)
	end
}
ov_yufuluo:addSkill(ov_neirao)
ov_luanlveCard = sgs.CreateSkillCard{
	name = "ov_luanlveCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		return SCfilter("snatch",targets,to_select,self,"ov_luanlve")
		and to_select:getMark("ov_luanlve-PlayClear")<1
	end,
	about_to_use = function(self,room,use)
		local d = dummyCard("snatch")
		d:setSkillName("ov_luanlve")
		d:addSubcards(self:getSubcards())
		use.card = d
		self:cardOnUse(room,use)
		room:addPlayerHistory(use.from,use.card:getClassName())
		room:addPlayerMark(use.from,"&ov_luanlve")
	end
}
ov_luanlvevs = sgs.CreateViewAsSkill{
	name = "ov_luanlve",
	n = 998,
	view_filter = function(self,selected,to_select)
		local n = sgs.Self:getMark("&ov_luanlve")
		return to_select:isKindOf("Slash")
		and #selected<n
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_luanlveCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		local n = sgs.Self:getMark("&ov_luanlve")
		return #cards>=n and c
	end,
	enabled_at_play = function(self,player)
		for d,p in sgs.list(player:getAliveSiblings())do
			if p:getMark("ov_luanlve-PlayClear")<1
			then
				d = dummyCard("snatch")
				d:setSkillName("ov_luanlve")
				return d:isAvailable(player)
			end
		end
	end,
}
ov_luanlve = sgs.CreateTriggerSkill{
	name = "ov_luanlve",
	events = {sgs.CardUsed},
	view_as_skill = ov_luanlvevs,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Snatch")
			then
				Skill_msg(self,player)
				local can = use.no_respond_list
				for i,to in sgs.list(room:getAlivePlayers())do
					table.insert(can,to:objectName())
					if use.to:contains(to)
					then
						room:addPlayerMark(to,"ov_luanlve-PlayClear")
					end
				end
				use.no_respond_list = can
				data:setValue(use)
			end
		end
		return false
	end
}
addToSkills(ov_luanlve)

ov_jiangji = sgs.General(extension,"ov_jiangji","wei",3)
ov_jichoucard = sgs.CreateSkillCard{
	name = "ov_jichoucard",
	will_throw = false,
	filter = function(self,targets,to_select,player)
		local pattern = self:getUserString()
		if pattern=="normal_slash"
		then pattern = "slash" end
		local skill_name = "ov_jichou"
		if sgs.Self:getMark("ov_jilun_use")>0
		then skill_name = "_ov_jilun" end
		return SCfilter(pattern,targets,to_select,nil,skill_name)
	end,	
	feasible = function(self,targets)
		local pattern = self:getUserString()
		if pattern=="normal_slash"
		then pattern = "slash" end
		local skill_name = "ov_jichou"
		if sgs.Self:getMark("ov_jilun_use")>0
		then skill_name = "_ov_jilun" end
		return SCfeasible(pattern,targets,nil,skill_name)
	end,	
	on_validate = function(self,use)
		local yuji = use.from
		local room = yuji:getRoom()
		local to_guhuo = self:getUserString()
		to_guhuo = room:askForChoice(yuji,"ov_jichou",to_guhuo)
		local skill_name = "ov_jichou"
		if yuji:getMark("ov_jilun_use")>0
		then skill_name = "_ov_jilun" end
		local use_card = sgs.Sanguosha:cloneCard(to_guhuo)
		use_card:setSkillName(skill_name)
		return use_card
	end,
	on_validate_in_response = function(self,yuji)
		local room = yuji:getRoom()
		local to_guhuo = self:getUserString()
		to_guhuo = room:askForChoice(yuji,"ov_jichou",to_guhuo)
		local skill_name = "ov_jichou"
		if yuji:getMark("ov_jilun_use")>0
		then skill_name = "_ov_jilun" end
		local use_card = sgs.Sanguosha:cloneCard(to_guhuo)
		use_card:setSkillName(skill_name)
		return use_card
	end
}
ov_jichouCard = sgs.CreateSkillCard{
	name = "ov_jichouCard",
	target_fixed = true,
	about_to_use = function(self,room,use)
		local choice,p_choices = {},{}
		for c,p in sgs.list(patterns)do
			c = PatternsCard(p)
			if c and c:isNDTrick()
			and c:isAvailable(use.from)
			and use.from:getMark("ov_jichou_"..p)<1
			then table.insert(p_choices,p) end
		end
		if #p_choices>0 and use.from:getMark("ov_jichou-Clear")<1
		then table.insert(choice,"ov_jichou-Clear") end
		local d = dummyCard()
		for i,c in sgs.list(use.from:getHandcards())do
			if use.from:getMark("ov_jichou_"..c:objectName())>0
			then d:addSubcard(c) end
		end
		if d:subcardsLength()>0 and use.from:getMark("ov_jichoucard-PlayClear")<1
		then table.insert(choice,"ov_jichoucard-PlayClear") end
		choice = table.concat(choice,"+")
		choice = room:askForChoice(use.from,"ov_jichou",choice)
		if choice=="ov_jichoucard-PlayClear"
		then
			self:cardOnUse(room,use)
			room:addPlayerMark(use.from,choice)
			choice = PlayerChosen("ov_jichou",use.from,room:getOtherPlayers(use.from),"ov_jichou0:")
			room:giveCard(use.from,choice,d,"ov_jichou")
		else
			p_choices = table.concat(p_choices,"+")
			p_choices = room:askForChoice(use.from,"ov_jichou",p_choices)
			d = PatternsCard(p_choices)
			if d
			then
				room:setPlayerMark(use.from,"ov_jichou_id",d:getEffectiveId())
				if room:askForUseCard(use.from,"@@ov_jichou","ov_jichou1:"..p_choices)
				then room:addPlayerMark(use.from,choice) end
			end
		end
	end
}
ov_jichouvs = sgs.CreateViewAsSkill{
	name = "ov_jichou",
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern=="@@ov_jichou"
		then
			pattern = sgs.Self:getMark("ov_jichou_id")
			pattern = sgs.Sanguosha:getCard(pattern)
			pattern = pattern:objectName()
			pattern = sgs.Sanguosha:cloneCard(pattern)
			local skill_name = "ov_jichou"
			if sgs.Self:getMark("ov_jilun_use")>0
			then skill_name = "_ov_jilun" end
			pattern:setSkillName(skill_name)
			return pattern
		elseif sgs.Sanguosha:getCurrentCardUseReason()~=sgs.CardUseStruct_CARD_USE_REASON_PLAY
		and pattern~=""
		then
			local c = ov_jichoucard:clone()
			c:setUserString(pattern)
			return c
		end
		return ov_jichouCard:clone()
	end,
	enabled_at_response = function(self,player,pattern)
	   	if pattern=="@@ov_jichou" then return true end
		for c,p in sgs.list(pattern:split("+"))do
			c = dummyCard(p)
			if c and c:isNDTrick() and player:getMark("ov_jichou_"..p)<1
			and sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
			then return player:getMark("ov_jichou-Clear")<1 end
		end
	end,
	enabled_at_nullification = function(self,player)				
	   	return player:getMark("ov_jichou_nullification")<1
		and player:getMark("ov_jichou-Clear")<1
	end,
	enabled_at_play = function(self,player)
		for c,p in sgs.list(AllCardPatterns())do
			c = dummyCard(p)
			if c and c:isNDTrick()
			and player:getMark("ov_jichou_"..p)<1
			and player:getMark("ov_jichou-Clear")<1
			then return true end
		end
		for i,c in sgs.list(player:getHandcards())do
			if player:getMark("ov_jichou_"..c:objectName())>0
			then
				return player:getMark("ov_jichoucard-PlayClear")<1
			end
		end
	end,
}
ov_jichou = sgs.CreateTriggerSkill{
	name = "ov_jichou",
	events = {sgs.TargetConfirming,sgs.PreCardUsed},
	view_as_skill = ov_jichouvs,
	on_trigger = function(self,event,player,data,room)
		local use = data:toCardUse()
		if event==sgs.TargetConfirming
		then
			if player:getMark("ov_jichou_"..use.card:objectName())>0
			and use.card:getSkillName()~="ov_jichou"
			and use.to:contains(player)
			then
				Skill_msg(self,player)
				local can = use.no_respond_list
				table.insert(can,player:objectName())
				use.no_respond_list = can
				data:setValue(use)
			end
		elseif use.card:getSkillName()=="ov_jichou"
		then
			room:addPlayerMark(player,"ov_jichou-Clear")
			room:addPlayerMark(player,"ov_jichou_"..use.card:objectName())
			room:setPlayerCardLimitation(player,"use",use.card:getClassName().."|.|.|hand",false)
		end
		return false
	end
}
ov_jiangji:addSkill(ov_jichou)
ov_jilun = sgs.CreateTriggerSkill{
	name = "ov_jilun",
	events = {sgs.Damaged,sgs.PreCardUsed},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.Damaged
		then
			local n,choice,p_choices = 0,{},{}
			for c,p in sgs.list(AllCardPatterns())do
				c = PatternsCard(p)
				if c and c:isNDTrick()
				and player:getMark("ov_jichou_"..p)>0
				then
					if c:isAvailable(player)
					and player:getMark("ov_jilun_"..p)<1
					then table.insert(p_choices,p) end
					n = n+1
				end
			end
			n = n>5 and 5 or n<1 and 1 or n
			if n>0 then table.insert(choice,"ov_jilun1="..n) end
			if #p_choices>0 then table.insert(choice,"ov_jilun2") end
			if #choice<1 or not ToSkillInvoke(self,player) then return end
			choice = table.concat(choice,"+")
			choice = room:askForChoice(player,"ov_jilun",choice)
			if choice=="ov_jilun2"
			then
				choice = table.concat(p_choices,"+")
				choice = room:askForChoice(player,"ov_jilun",choice)
				p_choices = PatternsCard(choice)
				room:setPlayerMark(player,"ov_jichou_id",p_choices:getEffectiveId())
				room:addPlayerMark(player,"ov_jilun_use")
				if room:askForUseCard(player,"@@ov_jichou","ov_jilun0:"..choice)
				then return end
				room:removePlayerMark(player,"ov_jilun_use")
			end
			player:drawCardsList(n,"ov_jilun")
		else
			local use = data:toCardUse()
			if use.card:getSkillName()=="ov_jilun"
			then
				room:addPlayerMark(player,"ov_jilun_"..use.card:objectName())
				room:removePlayerMark(player,"ov_jilun_use")
			end
		end
	end,
}
ov_jiangji:addSkill(ov_jilun)

ov_fanchou = sgs.General(extension,"ov_fanchou","qun")
ov_xingluanCard = sgs.CreateSkillCard{
	name = "ov_xingluanCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		return self:subcardsLength()+to_select:getMark("ov_xingluanNum-Clear")<4
		and #targets<1
	end,
	about_to_use = function(self,room,use)
		for i,to in sgs.list(use.to)do
			i = self:getEffectiveId()
			i = sgs.Sanguosha:getCard(i)
			i = i:getTypeId()
			room:setPlayerMark(use.from,"ov_xingluanType",i)
			room:addPlayerMark(to,"ov_xingluanNum-Clear",self:subcardsLength())
			room:giveCard(use.from,to,self,"ov_xingluan")
		end
	end
}
ov_xingluanvs = sgs.CreateViewAsSkill{
	name = "ov_xingluan",
	n = 3,
	expand_pile = "#ov_xingluan",
	response_pattern = "@@ov_xingluan!",
	view_filter = function(self,selected,to_select)
		if sgs.Self:getPileName(to_select:getEffectiveId())~="#ov_xingluan"
		then return end
		local n = sgs.Self:getMark("ov_xingluanType")
		if n<1
		then
			if #selected>0
			then
				return selected[1]:getType()==to_select:getType()
			end
		else
			return to_select:getTypeId()==n
		end
		return true
	end,
	view_as = function(self,cards)
		local c = ov_xingluanCard:clone()
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_xingluan = sgs.CreateTriggerSkill{
	name = "ov_xingluan",
	events = {sgs.EventPhaseProceeding},
	view_as_skill = ov_xingluanvs,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Finish
		and ToSkillInvoke(self,player)
	   	then
			room:broadcastSkillInvoke("xingluan")
			local move = sgs.CardsMoveStruct()
			move.card_ids = room:getNCards(6,false)
--			move.to = player
			move.to_place = sgs.Player_PlaceTable
			move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER,player:objectName(),self:objectName(),nil)
			room:moveCardsAtomic(move,true)
			room:getThread():delay(1111)
			local dc = dummyCard()
			room:setPlayerMark(player,"ov_xingluanType",0)
			while move.card_ids:length()>0 do
				local ids = sgs.IntList()
				for _,id in sgs.list(move.card_ids)do
					ids:append(id)
				end
				room:notifyMoveToPile(player,move.card_ids,"ov_xingluan",sgs.Player_PlaceTable,true)
				room:askForUseCard(player,"@@ov_xingluan!","ov_xingluan0:")
				room:notifyMoveToPile(player,move.card_ids,"ov_xingluan",sgs.Player_PlaceTable,false)
				local n = player:getMark("ov_xingluanType")
				for _,id in sgs.list(ids)do
					if room:getCardPlace(id)~=sgs.Player_PlaceTable
					then move.card_ids:removeOne(id)
					elseif n>0 and sgs.Sanguosha:getCard(id):getTypeId()~=n
					then
						dc:addSubcard(id)
						move.card_ids:removeOne(id)
					end
				end
			end
			dc:addSubcards(move.card_ids)
			room:throwCard(dc,nil)
			dc = player:getMark("ov_xingluanNum-Clear")
			move = room:getAlivePlayers()
			room:sortByActionOrder(move)
			for i,p in sgs.list(move)do
				if p:getMark("ov_xingluanNum-Clear")>=dc
				and p:getMark("ov_xingluanNum-Clear")>0
				then room:loseHp(p) end
			end
		end
		return false
	end
}
ov_fanchou:addSkill(ov_xingluan)

ov_zhugeguo = sgs.General(extension,"ov_zhugeguo","shu",3,false)
ov_qirang = sgs.CreateTriggerSkill{
	name = "ov_qirang",
	events = {sgs.CardUsed,sgs.CardsMoveOneTime},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Tiaojiyanmei")
			then
--				player:addMark(use.card:toString().."ov_qirangbf-PlayClear")
			end
			if player:getMark(use.card:toString().."ov_qirangbf-PlayClear")>0
			then
				Skill_msg(self,player)
				local can = use.no_respond_list
				for i,to in sgs.list(room:getAlivePlayers())do
					table.insert(can,to:objectName())
				end
				use.no_respond_list = can
				can = sgs.SPlayerList()
				for i,to in sgs.list(room:getAlivePlayers())do
					if player:canUse(use.card,to,true)
					or use.to:contains(to)
					then can:append(to) end
				end
				if use.to:length()>0 and can:length()>0
				and not use.card:isKindOf("DelayedTrick")
				then
					player:setTag("ov_qirangData",data)
					can = room:askForPlayerChosen(player,can,"ov_qirang","ov_qirang0:"..use.card:objectName(),true)
					if can
					then
						local msg = sgs.LogMessage()
						msg.from = player
						msg.to:append(can)
						msg.card_str = use.card:toString()
						msg.type = "$ov_qirangTarget"
						if use.to:contains(can)
						then
							use.to:removeOne(can)
							msg.arg = "Target-"
						else
							if use.card:isKindOf("Collateral")
							then
								local tos = sgs.SPlayerList()
								for i,to in sgs.list(room:getAlivePlayers())do
									if can:canSlash(to) then tos:append(to) end
								end
								tos = room:askForPlayerChosen(player,tos,"ov_qirang1","ov_qirang1:"..can:objectName()..":ov_qirang",true)
								if tos then can:setTag("collateralVictim",ToData(tos)) else return end
							end
							use.to:append(can)
							room:sortByActionOrder(use.to)
							msg.arg = "Target+"
						end
						room:doAnimate(1,player:objectName(),can:objectName())
						room:sendLog(msg)
					end
				end
				data:setValue(use)
			end
		elseif event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			if move.to
			and move.to:objectName()==player:objectName()
			and move.to_place==sgs.Player_PlaceEquip
			then
				Skill_msg("olqirang",player,math.random(1,2))
				local tricks = {}
				for c,id in sgs.list(room:getDrawPile())do
					c = sgs.Sanguosha:getCard(id)
					if c:isKindOf("TrickCard")
					then table.insert(tricks,c) end
				end
				tricks = RandomList(tricks)
				if #tricks>0
				then
					room:addPlayerMark(player,tricks[1]:toString().."ov_qirangbf-PlayClear")
					player:obtainCard(tricks[1])
				end
			end
		end
		return false
	end
}
ov_qirangbf = sgs.CreateTargetModSkill{
	name = "#ov_qirangbf",
	pattern = "TrickCard",
	residue_func = function(self,from,card)--额外使用
	end,
	distance_limit_func = function(self,from,card,to)--使用距离
		if from:hasSkill("ov_qirang")
		and from:getMark(card:toString().."ov_qirangbf-PlayClear")>0
		then return 998 end
	end,
	extra_target_func = function(self,from,card)--目标数
	end
}
ov_zhugeguo:addSkill(ov_qirang)
ov_zhugeguo:addSkill(ov_qirangbf)
extension:insertRelatedSkills("ov_qirang", "#ov_qirangbf")
ov_yuhua = sgs.CreateTriggerSkill{
	name = "ov_yuhua",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime,sgs.EventPhaseChanging},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			if move.from and move.from:objectName()==player:objectName()
			and (not move.to or move.to:objectName()~=player:objectName()
				or move.to_place~=sgs.Player_PlaceHand and move.to_place~=sgs.Player_PlaceEquip)
			and player:getPhase()==sgs.Player_NotActive
			then
				local n = false
				for i,id in sgs.list(move.card_ids)do
					i = move.from_places:at(i)
					if i==sgs.Player_PlaceHand
					or i==sgs.Player_PlaceEquip
					then
						if sgs.Sanguosha:getCard(id):getTypeId()~=1
						then n = true break end
					end
				end
				for i,id in sgs.list(move.card_ids)do
					i = move.from_places:at(i)
					if i==sgs.Player_PlaceHand
					or i==sgs.Player_PlaceEquip
					then
						if n and sgs.Sanguosha:getCard(id):getTypeId()~=1
						then n = type(n)~="number" and 1 or n+1 end
					end
				end
				n = type(n)~="number" and 0 or (n>5 and 5 or n)
				if n>0
				and ToSkillInvoke(self,player)
				then
					room:broadcastSkillInvoke("olyuhua")
					room:askForGuanxing(player,room:getNCards(n,false))
					if player:askForSkillInvoke(self,data,false)
					then player:drawCardsList(n,"ov_yuhua") end
				end
			end
        elseif event==sgs.EventPhaseChanging
        then
	     	local change = data:toPhaseChange()
			if change.to==sgs.Player_Discard
			then
				room:sendCompulsoryTriggerLog(player,"ov_yuhua",true)
				room:broadcastSkillInvoke("olyuhua")
				for i,c in sgs.list(player:getHandcards())do
					if c:getTypeId()~=1 then room:ignoreCards(player,c) end
				end
			end
		end
		return false
	end,
}
ov_zhugeguo:addSkill(ov_yuhua)

ov_zhangfei = sgs.General(extension,"ov_zhangfei","shu")
ov_zhangfei:addSkill("tenyearpaoxiao")
ov_xuhe = sgs.CreateTriggerSkill{
	name = "ov_xuhe",
	events = {sgs.SlashMissed,sgs.ConfirmDamage,sgs.CardFinished},
	on_trigger = function(self,event,player,data,room)
		if event == sgs.SlashMissed
		then
			local effect = data:toSlashEffect()
			if effect.jink and effect.jink:isKindOf("Jink")
			and ToSkillInvoke(self,player,effect.to)
			then
				local choices = "ov_xuhe1="..player:objectName().."+ov_xuhe2="..player:objectName()
				if room:askForChoice(effect.to,"ov_xuhe",choices,ToData(player))~="ov_xuhe1="..player:objectName()
				then room:setPlayerMark(effect.to,"&ov_xuhe+#"..player:objectName().."-Clear",1)
				else room:damage(sgs.DamageStruct("ov_xuhe",player,effect.to)) end
				player:setTag("ov_xuhe",ToData(effect.slash:toString()))
			end
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if use.card:getTypeId()>0
			then
				if use.card:toString()==player:getTag("ov_xuhe"):toString()
				then player:removeTag("ov_xuhe") return end
				for i,p in sgs.list(room:getAlivePlayers())do
					room:setPlayerMark(p,"&ov_xuhe+#"..player:objectName().."-Clear",0)
				end
			end
		else
			local damage = data:toDamage()
			if damage.card and damage.card:getTypeId()>0
			and damage.to:getMark("&ov_xuhe+#"..player:objectName().."-Clear")>0
			then
				Skill_msg(self,player)
				DamageRevises(data,2,player)
			end
		end
		return false
	end
}
ov_zhangfei:addSkill(ov_xuhe)

ov_zhaoxiang = sgs.General(extension,"ov_zhaoxiang","shu",4,false)
ov_zhaoxiang:addSkill("tenyearfanghun")
ov_zhaoxiang:addSkill("olfuhan")
ov_queshi = sgs.CreateTriggerSkill{
	name = "ov_queshi",
--	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart,sgs.ChoiceMade},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.GameStart
		then
			Skill_msg(self,player)
			for _,c in sgs.list(PatternsCard("sp_moonspear,moonspear",true))do
				if room:getCardPlace(c:getEffectiveId())~=sgs.Player_PlaceHand
				then InstallEquip(c,player,self) break end
			end
		else
			local struct = data:toString()
			if struct=="skillInvoke:olfuhan:yes"
			then
				Skill_msg(self,player)
				for _,c in sgs.list(PatternsCard("sp_moonspear,moonspear",true))do
					if room:getCardPlace(c:getEffectiveId())~=sgs.Player_PlaceHand
					then player:obtainCard(c) break end
				end
			end
		end
		return false
	end
}
ov_zhaoxiang:addSkill(ov_queshi)

ov_erqiao = sgs.General(extension,"ov_erqiao","wu",3,false)
ov_xingwuCard = sgs.CreateSkillCard{
	name = "ov_xingwuCard",
	handling_method = sgs.Card_MethodDiscard,
	will_throw = false,
	filter = function(self,targets,to_select,from)
		return #targets<1 and to_select:objectName()~=from:objectName()
	end,
	on_use = function(self,room,source,targets)
		room:throwCard(self,source)
		for dc,to in sgs.list(targets)do
			if to:hasEquip()
			then
				dc = dummyCard()
				dc:addSubcards(to:getEquipsId())
				room:throwCard(dc,to,source)
			end
			room:damage(sgs.DamageStruct("ov_xingwu",source,to,to:isMale() and 2 or 1))
		end
	end
}
ov_xingwuvs = sgs.CreateViewAsSkill{
	name = "ov_xingwu",
	n = 3,
	expand_pile = "ov_xingwu",
	response_pattern = "@@ov_xingwu",
	view_filter = function(self,selected,to_select)
		return sgs.Self:getPileName(to_select:getEffectiveId())=="ov_xingwu"
	end,
	view_as = function(self,cards)
		local card = ov_xingwuCard:clone()
		for _,c in sgs.list(cards)do
			card:addSubcard(c)
		end
		return #cards>2 and card
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_xingwu = sgs.CreateTriggerSkill{
	name = "ov_xingwu",
	view_as_skill = ov_xingwuvs,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart
		and player:getPhase() == sgs.Player_Discard
		then
			local card = room:askForCard(player,".","ov_xingwu0:",sgs.QVariant(),sgs.Card_MethodNone)
			if card then
				room:broadcastSkillInvoke("xingwu")
				player:addToPile(self:objectName(),card)
				card = player:getPile(self:objectName())
				if card:length()>2
				then
					room:askForUseCard(player,"@@ov_xingwu","ov_xingwu1:")
				end
			end
		end
		return false
	end
}
ov_erqiao:addSkill(ov_xingwu)
ov_pingting = sgs.CreateTriggerSkill{
	name = "ov_pingting",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime,sgs.EventAcquireSkill,sgs.EventLoseSkill,sgs.RoundStart,sgs.Dying},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.EventLoseSkill and data:toString() == self:objectName() then
			room:handleAcquireDetachSkills(player,"-tianxiang|-liuli",true)
		elseif event == sgs.EventAcquireSkill and data:toString() == self:objectName() then
			if player:getPile("ov_xingwu"):length()>0 then
				room:sendCompulsoryTriggerLog(player,"ov_pingting")
				room:handleAcquireDetachSkills(player,"tianxiang|liuli")
			end
		elseif event == sgs.RoundStart
		then
			room:sendCompulsoryTriggerLog(player,"ov_pingting")
			player:drawCards(1,"ov_pingting")
			local card = room:askForCard(player,".!","ov_pingting0:",sgs.QVariant(),sgs.Card_MethodNone)
			if card then player:addToPile("ov_xingwu",card) end
		elseif event == sgs.Dying
		then
			local dy = data:toDying()
			if dy.who==player or player:getPhase()==sgs.Player_NotActive then return end
			room:sendCompulsoryTriggerLog(player,"ov_pingting")
			player:drawCards(1,"ov_pingting")
			local card = room:askForCard(player,".!","ov_pingting0:",sgs.QVariant(),sgs.Card_MethodNone)
			if card then player:addToPile("ov_xingwu",card) end
		elseif event == sgs.CardsMoveOneTime
		then
			local move = data:toMoveOneTime()
			if move.to_place == sgs.Player_PlaceSpecial and move.to_pile_name == "ov_xingwu"
			and move.to:objectName() == player:objectName()
			then
				if player:getPile("ov_xingwu"):length() == 1 then
					room:sendCompulsoryTriggerLog(player,"ov_pingting")
					room:handleAcquireDetachSkills(player,"tianxiang|liuli")
				end
			elseif move.from_places:contains(sgs.Player_PlaceSpecial)
			and table.contains(move.from_pile_names,"ov_xingwu")
			and move.from:objectName() == player:objectName()
			then
				if player:getPile("ov_xingwu"):isEmpty() then
					room:handleAcquireDetachSkills(player,"-tianxiang|-liuli",true)
				end
			end
		end
		return false
	end
}
ov_erqiao:addSkill(ov_pingting)
ov_erqiao:addRelateSkill("tianxiang")
ov_erqiao:addRelateSkill("liuli")

ov_shenguanyu = sgs.General(extension,"ov_shenguanyu","god")
ov_wushen = sgs.CreateTriggerSkill{
	name = "ov_wushen", 
	events = {sgs.EventAcquireSkill,sgs.EventLoseSkill,sgs.CardsMoveOneTime,sgs.CardUsed},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data,room)
	   	if event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
			then
				if use.card:getSuit()==2
				or player:getMark("ov_wushenbf-PlayClear")<1
				then
					room:sendCompulsoryTriggerLog(player,"ov_wushen",true)
					room:broadcastSkillInvoke("wushen")
				end
				local msg = sgs.LogMessage()
				msg.from = player
				msg.card_str = use.card:toString()
				msg.type = "$ov_wushenTarget"
				local no_respond = use.no_respond_list
				for _,p in sgs.list(room:getAlivePlayers())do
					if player:getMark("ov_wushenbf-PlayClear")<1
					then table.insert(no_respond,p:objectName()) end
					if p:getMark("&nightmare")<1
					or use.card:getSuit()~=2
					or use.to:contains(p)
					then continue end
					use.to:append(p)
					msg.to:append(p)
					room:doAnimate(1,player:objectName(),p:objectName())
				end
				msg.arg2 = use.card:objectName()
				msg.arg = "Target+"
				if msg.to:length()>0
				then room:sendLog(msg) end
				use.no_respond_list = no_respond
				room:sortByActionOrder(use.to)
				data:setValue(use)
				player:addMark("ov_wushenbf-PlayClear")
			end
	   	elseif event==sgs.EventLoseSkill
		then
			if data:toString()=="ov_wushen"
			then
				local hw = sgs.CardList()
				for _,c in sgs.list(player:getHandcards())do
					if c:getSuit()==2 or c:getSkillName()=="ov_wushen"
					then hw:append(c) end
				end
				if hw:length()>0
				then
					room:filterCards(player,hw,true)
				end
			end
		else
			for _,c in sgs.list(player:getHandcards())do
				if c:getSuit()~=2 or c:getSkillName()=="ov_wushen" then continue end
				local toc = sgs.Sanguosha:cloneCard("slash",2,c:getNumber())
				toc:setSkillName("ov_wushen")
				local wrap = sgs.Sanguosha:getWrappedCard(c:getEffectiveId())
				wrap:takeOver(toc)
				room:notifyUpdateCard(player,c:getEffectiveId(),wrap)
			end
		end
	end,
}
ov_wushenbf = sgs.CreateTargetModSkill{
	name = "#ov_wushenbf",
	pattern = "^SkillCard",
	residue_func = function(self,from,card)--额外使用
		if from:hasSkill("ov_wushen") and card:getSuit()==2
		then return 998 end
	end,
	distance_limit_func = function(self,from,card,to)--使用距离
		if from:hasSkill("ov_wushen") and card:getSuit()==2
		then return 998 end
	end,
	extra_target_func = function(self,from,card)--目标数
	end
}
ov_shenguanyu:addSkill(ov_wushen)
ov_shenguanyu:addSkill(ov_wushenbf)
extension:insertRelatedSkills("ov_wushen", "#ov_wushenbf")
ov_wuhun = sgs.CreateTriggerSkill{
	name = "ov_wuhun",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged,sgs.Damage,sgs.Death},
	can_trigger = function(self,target)
		return target and target:hasSkill(self)
	end,
	on_trigger = function(self,event,player,data,room)
		if event == sgs.Damaged
		then
			local damage = data:toDamage()
			if damage.from and player:isAlive()
			and damage.from:objectName()~=player:objectName()
			then
				room:sendCompulsoryTriggerLog(player,"ov_wuhun",true)
				room:broadcastSkillInvoke("wuhun",1)
				damage.from:gainMark("&nightmare",damage.damage)
			end
		elseif event==sgs.Damage
		then
			local damage = data:toDamage()
			if player:isAlive()
			and damage.to:getMark("&nightmare")>0
			then
				room:sendCompulsoryTriggerLog(player,"ov_wuhun",true)
				room:broadcastSkillInvoke("wuhun",2)
				damage.to:gainMark("&nightmare")
			end
		else
			local death = data:toDeath()
			if death.who:objectName()==player:objectName()
			then
				death = sgs.SPlayerList()
				for _,p in sgs.list(room:getAlivePlayers())do
					if p:getMark("&nightmare")>0
					then death:append(p) end
				end
				if death:isEmpty() or not ToSkillInvoke(self,player) then return end
				local judge = sgs.JudgeStruct()
				judge.pattern = "Peach,GodSalvation"
				judge.good = false
				judge.negative = false
				judge.reason = "ov_wuhun"
				judge.who = player
				room:judge(judge)
				if judge:isBad()
				then
					room:broadcastSkillInvoke("wuhun",3)
					return
				end
				room:broadcastSkillInvoke("wuhun",math.random(4,5))
				room:doSuperLightbox("shenguanyu","ov_wuhun")
				death = room:askForPlayersChosen(player,death,"ov_wuhun",1,death:length(),"ov_wuhun0:",true)
				for _,p in sgs.list(death)do
					room:loseHp(p,p:getMark("&nightmare"))
				end
			end
		end
		return false
	end
}
ov_shenguanyu:addSkill(ov_wuhun)

ov_zhangnan = sgs.General(extension,"ov_zhangnan","shu")
ov_fenwuvs = sgs.CreateViewAsSkill{
	name = "ov_fenwu",
	response_pattern = "@@ov_fenwu",
	view_as = function(self,cards)
		local c = sgs.Sanguosha:cloneCard("slash")
		c:setSkillName("_ov_fenwu")
		c:setFlags("ov_fenwu")
		return c
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_fenwu = sgs.CreateTriggerSkill{
	name = "ov_fenwu",
	view_as_skill = ov_fenwuvs,
	events = {sgs.EventPhaseProceeding,sgs.PreCardUsed,sgs.CardFinished,sgs.ConfirmDamage},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Finish
		and CardIsAvailable(player,"slash","ov_fenwu")
	   	then
			room:askForUseCard(player,"@@ov_fenwu","ov_fenwu0:")
			player:removeTag("ov_fenwu")
		elseif event==sgs.PreCardUsed
		then
			local use = data:toCardUse()
			if use.card:getSkillName()=="ov_fenwu"
			or use.card:hasFlag("ov_fenwu")
			then
				ToSkillInvoke(self,player,true,nil,false)
				room:loseHp(player)
				if player:isDead()
				then
					use.to = sgs.SPlayerList()
					data:setValue(use)
					return true
				end
			end
		elseif event==sgs.ConfirmDamage
		then
			local damage = data:toDamage()
			local names = player:getTag("ov_fenwu"):toString():split("+")
			if damage.card and #names>1
			and (damage.card:getSkillName()=="ov_fenwu" or damage.card:hasFlag("ov_fenwu"))
			then
				Skill_msg(self,player)
				DamageRevises(data,1,player)
			end
		elseif event==sgs.CardFinished
		and player:getPhase()~=sgs.Player_NotActive
		then
			local use = data:toCardUse()
			local names = player:getTag("ov_fenwu"):toString():split("+")
			if use.card:isKindOf("BasicCard")
			and not table.contains(names,use.card:objectName())
			then
				table.insert(names,use.card:objectName())
				names = table.concat(names,"+")
				player:setTag("ov_fenwu",ToData(names))
			end
		end
		return false
	end
}
ov_zhangnan:addSkill(ov_fenwu)

ov_huchuquan = sgs.General(extension,"ov_huchuquan","qun")
ov_fupan = sgs.CreateTriggerSkill{
	name = "ov_fupan",
	events = {sgs.Damaged,sgs.Damage},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if player:askForSkillInvoke(self)
		then
			if event==sgs.Damaged
			then room:broadcastSkillInvoke(self,1)
			else room:broadcastSkillInvoke(self,2) end
			local damage = data:toDamage()
			player:drawCardsList(damage.damage,self:objectName())
			local ids,sp = player:handCards(),sgs.SPlayerList()
			for c,p in sgs.list(room:getOtherPlayers(player))do
				if p:getMark("ov_fupan_damage_"..player:objectName())>0
				then continue end
				sp:append(p)
			end
			for c,id in sgs.list(player:getEquipsId())do
				ids:append(id)
			end
			if sp:isEmpty() or ids:isEmpty() then return end
			sp = room:askForYijiStruct(player,ids,"ov_fupan",true,false,false,1,sp)
			if sp and sp.to
			and player:isAlive()
			then
				sp = BeMan(room,sp.to)
				if sp:getMark("ov_fupan_"..player:objectName())<1
				then player:drawCardsList(2,self:objectName())
				elseif player:askForSkillInvoke(self,ToData("ov_fupan0:"..sp:objectName()))
				then
					room:broadcastSkillInvoke(self,3)
					sp:addMark("ov_fupan_damage_"..player:objectName())
					room:damage(sgs.DamageStruct("ov_fupan",player,sp))
				end
				sp:addMark("ov_fupan_"..player:objectName())
			end
		end
	end,
}
ov_huchuquan:addSkill(ov_fupan)

ov_baoxin = sgs.General(extension,"ov_baoxin","qun")
ov_mutaoCard = sgs.CreateSkillCard{
	name = "ov_mutaoCard",
--	will_throw = false,
	filter = function(self,targets,to_select,from)
		return from:isAlive()
	end,
	on_use = function(self,room,source,targets)
		local function ov_mutaoJudge(to)
			local n = 0
			for i,c in sgs.list(to:getHandcards())do
				if c:isKindOf("Slash") then n = n+1 end
			end
			return n
		end
		for c,to in sgs.list(targets)do
			local n = ov_mutaoJudge(to)
			if n<1 then continue end
			local to1 = to:getNextAlive()
			for i=1,n do
				c = room:askForCard(to,"Slash!","ov_mutao0:"..to1:objectName(),ToData(to1),sgs.Card_MethodNone)
				if c then room:giveCard(to,to1,c,"ov_mutao",true)
				else
					for _,h in sgs.list(to:getHandcards())do
						if h:isKindOf("Slash") then room:giveCard(to,to1,h,"ov_mutao",true) break end
					end
				end
				if ov_mutaoJudge(to)<1
				or i>=n then break end
				to1 = to1:getNextAlive()
			end
			n = n>3 and 3 or n
			room:damage(sgs.DamageStruct("ov_mutao",to,to1,n))
		end
	end
}
ov_mutao = sgs.CreateViewAsSkill{
	name = "ov_mutao",
	response_pattern = "@@ov_mutao",
	view_as = function(self,cards)
		return ov_mutaoCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_mutaoCard")<1
	end,
}
ov_baoxin:addSkill(ov_mutao)
ov_yimou = sgs.CreateTriggerSkill{
	name = "ov_yimou",
	events = {sgs.Damaged},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.Damaged
		then
			local damage = data:toDamage()
			if damage.to:objectName()~=player:objectName() then return end
			for i,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
				if owner:distanceTo(player)>1 or not ToSkillInvoke(self,owner,player)
				then continue end
				i = {"ov_yimou1"}
				if player:getHandcardNum()>0
				then table.insert(i,"ov_yimou2") end
				if #i>1 and owner:getHandcardNum()>0
				and player:objectName()~=owner:objectName()
				then table.insert(i,"beishui_choice=ov_yimou3") end
				i = table.concat(i,"+")
				i = room:askForChoice(owner,"ov_yimou",i,ToData(player))
				if i=="ov_yimou1"
				then
					for c,id in sgs.list(room:getDrawPile())do
						c = sgs.Sanguosha:getCard(id)
						if c:isKindOf("Slash")
						then
							player:obtainCard(c)
							break
						end
					end
				elseif i=="ov_yimou2"
				then
					i = PlayerChosen(self,owner,room:getOtherPlayers(player),"ov_yimou0:"..player:objectName())
					if i
					then
						damage = room:askForExchange(player,"ov_yimou",1,1,false,"ov_yimou01:"..i:objectName())
						if damage
						then
							room:giveCard(player,i,damage,"ov_yimou")
							player:drawCardsList(2,self:objectName())
						end
					end
				else
					i = dummyCard()
					i:addSubcards(owner:handCards())
					room:giveCard(owner,player,i,"ov_yimou")
					for c,id in sgs.list(room:getDrawPile())do
						c = sgs.Sanguosha:getCard(id)
						if c:isKindOf("Slash")
						then
							player:obtainCard(c)
							break
						end
					end
					i = PlayerChosen(self,owner,room:getOtherPlayers(player),"ov_yimou0:"..player:objectName())
					if i
					then
						damage = room:askForExchange(player,"ov_yimou",1,1,false,"ov_yimou01:"..i:objectName())
						if damage
						then
							room:giveCard(player,i,damage,"ov_yimou")
							player:drawCardsList(2,self:objectName())
						end
					end
				end
			end
		end
	end,
}
ov_baoxin:addSkill(ov_yimou)

ov_yanxiang = sgs.General(extension,"ov_yanxiang","qun",3)
ov_kujianCard = sgs.CreateSkillCard{
	name = "ov_kujianCard",
	will_throw = false,
	mute = true,
	filter = function(self,targets,to_select,from)
		return to_select:objectName()~=from:objectName()
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
		room:broadcastSkillInvoke("ov_kujian",1)
		for c,to in sgs.list(targets)do
			c = to:getTag("ov_kujian_"..source:objectName()):toIntList()
			for i,id in sgs.list(self:getSubcards())do
				c:append(id)
			end
			to:setTag("ov_kujian_"..source:objectName(),ToData(c))
			room:giveCard(source,to,self,"ov_kujian")
		end
	end
}
ov_kujianvs = sgs.CreateViewAsSkill{
	name = "ov_kujian",
	n = 3,
	view_filter = function(self,selected,to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = ov_kujianCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_kujianCard")<1
	end,
}
ov_kujian = sgs.CreateTriggerSkill{
	name = "ov_kujian",
	events = {sgs.CardsMoveOneTime,sgs.CardFinished,sgs.CardResponded},
	view_as_skill = ov_kujianvs,
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			local from = BeMan(room,move.from)
			if from and player:hasSkill(self)
			and move.from_places:contains(sgs.Player_PlaceHand)
			and bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON)~=sgs.CardMoveReason_S_REASON_USE
			and bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON)~=sgs.CardMoveReason_S_REASON_RESPONSE
			then
				for c,id in sgs.list(move.card_ids)do
					local ids = from:getTag("ov_kujian_"..player:objectName()):toIntList()
					if ids:contains(id)
					then
						ids:removeOne(id)
						from:setTag("ov_kujian_"..player:objectName(),ToData(ids))
						Skill_msg(self,player,2)
						room:askForDiscard(player,"ov_kujian",1,1,false,true)
						room:askForDiscard(from,"ov_kujian",1,1,false,true)
					end
				end
			end
		else
			local card
			if event==sgs.CardResponded
			then card = data:toCardResponse().m_card
			else card = data:toCardUse().card end
			if card:getTypeId()==0 then return end
			for i,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
				local ids = player:getTag("ov_kujian_"..owner:objectName()):toIntList()
				if ids:length()<1 then continue end
				if card:isVirtualCard()
				then
					for c,id in sgs.list(card:getSubcards())do
						if ids:contains(id)
						then
							ids:removeOne(id)
							Skill_msg(self,owner,3)
							owner:drawCardsList(1,self:objectName())
							player:drawCardsList(1,self:objectName())
						end
					end
				elseif ids:contains(card:getEffectiveId())
				then
					Skill_msg(self,owner,3)
					ids:removeOne(card:getEffectiveId())
					owner:drawCardsList(1,self:objectName())
					player:drawCardsList(1,self:objectName())
				end
				player:setTag("ov_kujian_"..owner:objectName(),ToData(ids))
			end
		end
		return false
	end
}
ov_yanxiang:addSkill(ov_kujian)
ov_ruilian = sgs.CreateTriggerSkill{
	name = "ov_ruilian",
	events = {sgs.RoundStart},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.RoundStart
	   	then
			for i,p in sgs.list(room:getAlivePlayers())do
				room:setPlayerMark(p,"&ov_ruilian+#"..player:objectName(),0)
				p:removeTag("ov_ruilian")
			end
			local to = room:askForPlayerChosen(player,room:getAlivePlayers(),"ov_ruilian","ov_ruilian0:",true,true)
			if not to then return end
			room:broadcastSkillInvoke(self:objectName())
			room:setPlayerMark(to,"&ov_ruilian+#"..player:objectName(),1)
		end
		return false
	end
}
ov_ruilianbf = sgs.CreateTriggerSkill{
	name = "#ov_ruilianbf",
	events = {sgs.CardsMoveOneTime,sgs.EventPhaseChanging}, 
	can_trigger = function(self,target)
		if target and target:isAlive()
		then
			local room = target:getRoom()
			for _,owner in sgs.list(room:findPlayersBySkillName("ov_ruilian"))do
				if target:getMark("&ov_ruilian+#"..owner:objectName())>0
				then return true end
			end
		end
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			if move.from
			and player:getPhase()~=sgs.Player_NotActive
			and move.from:objectName()==player:objectName()
			and bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON)==sgs.CardMoveReason_S_REASON_DISCARD
			then
				local ids = player:getTag("ov_ruilian"):toIntList()
				for i,id in sgs.list(move.card_ids)do
					ids:append(id)
				end
				player:setTag("ov_ruilian",ToData(ids))
			end
		else
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
				for i,owner in sgs.list(room:findPlayersBySkillName("ov_ruilian"))do
					if player:getMark("&ov_ruilian+#"..owner:objectName())<1 then continue end
					local ids = player:getTag("ov_ruilian"):toIntList()
					if ids:length()<2 then continue end
					local ts = {}
					for c,id in sgs.list(ids)do
						c = sgs.Sanguosha:getCard(id)
						if table.contains(ts,c:getType())
						then continue end
						table.insert(ts,c:getType())
					end
					if #ts<1 or not ToSkillInvoke("ov_ruilian",owner,player) then continue end
					ts = room:askForChoice(owner,"ov_ruilian",table.concat(ts,"+"))
					ids = sgs.CardList()
					for c,id in sgs.list(room:getDiscardPile())do
						c = sgs.Sanguosha:getCard(id)
						if c:getType()~=ts
						then continue end
						ids:append(c)
					end
					ids = RandomList(ids)
					if ids:length()>0 then owner:obtainCard(ids:at(0)) end
					if ids:length()>1 then player:obtainCard(ids:at(1)) end
				end
			end
		end
		return false
	end
}
ov_yanxiang:addSkill(ov_ruilian)
ov_yanxiang:addSkill(ov_ruilianbf)
extension:insertRelatedSkills("ov_ruilian", "#ov_ruilianbf")

ov_liyi = sgs.General(extension,"ov_liyi","shu")
ov_jiaohua = sgs.CreateTriggerSkill{
	name = "ov_jiaohua",
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			if move.to
			and move.to_place==sgs.Player_PlaceHand
			and not room:getTag("FirstRound"):toBool()
			and move.reason.m_reason==sgs.CardMoveReason_S_REASON_DRAW
			then
				local can = true
				local to = BeMan(room,move.to)
				for i,p in sgs.list(room:getOtherPlayers(to))do
					if to:getHp()>p:getHp() then can = false end
				end
				can = can or to:objectName()==player:objectName()
				if not can then return end
				can = {}
				if player:getMark("basic_ov_jiaohua-Clear")<1
				then table.insert(can,"basic") end
				if player:getMark("trick_ov_jiaohua-Clear")<1
				then table.insert(can,"trick") end
				if player:getMark("equip_ov_jiaohua-Clear")<1
				then table.insert(can,"equip") end
				if #can<1 then return end
				for i,id in sgs.list(move.card_ids)do
					if move.from_places:at(i)==sgs.Player_DrawPile
					then
						local c = sgs.Sanguosha:getCard(id)
						if table.contains(can,c:getType())
						then table.removeOne(can,c:getType()) end
					end
				end
				if #can<1 or not ToSkillInvoke(self,player,to) then return end
				can = room:askForChoice(player,"ov_jiaohua",table.concat(can,"+"))
				player:addMark(can.."_ov_jiaohua-Clear")
				local cs = sgs.CardList()
				for c,id in sgs.list(room:getDrawPile())do
					c = sgs.Sanguosha:getCard(id)
					if c:getType()~=can
					then continue end
					cs:append(c)
				end
				for c,id in sgs.list(room:getDiscardPile())do
					c = sgs.Sanguosha:getCard(id)
					if c:getType()~=can
					then continue end
					cs:append(c)
				end
				cs = RandomList(cs)
				if cs:length()>0 then to:obtainCard(cs:at(0)) end
			end
		end
		return false
	end
}
ov_liyi:addSkill(ov_jiaohua)

ov_xiahoushang = sgs.General(extension,"ov_xiahoushang","wei")
ov_tanfeng = sgs.CreateTriggerSkill{
	name = "ov_tanfeng",
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Start
	   	then
			local sp = sgs.SPlayerList()
			for i,p in sgs.list(room:getOtherPlayers(player))do
				if player:canDiscard(p,"hej")
				then sp:append(p) end
			end
			if sp:isEmpty() then return end
			local to = room:askForPlayerChosen(player,sp,"ov_tanfeng","ov_tanfeng0:",true,true)
			if not to then return end
			room:broadcastSkillInvoke(self:objectName())
			local id = room:askForCardChosen(player,to,"hej","ov_tanfeng",false,sgs.Card_MethodDiscard)
			if id<0 then return end
			room:throwCard(id,to,player)
			sp = {"ov_tanfeng1="..player:objectName()}
			if to:canSlash(player,false) and to:getCardCount()>0
			then table.insert(sp,"ov_tanfeng2="..player:objectName()) end
			if #sp<1 then return end
			sp = room:askForChoice(to,"ov_tanfeng",table.concat(sp,"+"),ToData(player))
			if sp:startsWith("ov_tanfeng1")
			then
				room:damage(sgs.DamageStruct("ov_tanfeng",player,to,1,sgs.DamageStruct_Fire))
				if to:isDead() or player:isDead() then return end
				sp = {}
				if not player:isSkipped(sgs.Player_Judge)
				then table.insert(sp,"Player_Judge") end
				if not player:isSkipped(sgs.Player_Draw)
				then table.insert(sp,"Player_Draw") end
				if not player:isSkipped(sgs.Player_Play)
				then table.insert(sp,"Player_Play") end
				if not player:isSkipped(sgs.Player_Discard)
				then table.insert(sp,"Player_Discard") end
				if not player:isSkipped(sgs.Player_Finish)
				then table.insert(sp,"Player_Finish") end
				if #sp<1 then return end
				sp = room:askForChoice(to,"ov_tanfeng",table.concat(sp,"+"),ToData(player))
				player:skip(sgs[sp])
			else
				sp = room:askForExchange(to,"ov_tanfeng",1,1,false,"ov_tanfeng01:"..player:objectName())
				if sp
				then
					id = dummyCard()
					id:setSkillName("_ov_tanfeng")
					id:addSubcards(sp:getSubcards())
					room:useCard(sgs.CardUseStruct(id,to,player))
				end
			end
		end
		return false
	end
}
ov_xiahoushang:addSkill(ov_tanfeng)

ov_qiaorui = sgs.General(extension,"ov_qiaorui","qun",5)
ov_xiaweivs = sgs.CreateViewAsSkill{
	name = "ov_xiawei",
	n = 1,
	expand_pile = "&ov_wei",
	view_filter = function(self,selected,to_select)
		if sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_PLAY
		then return to_select:isAvailable(sgs.Self) end
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		for c,p in sgs.list(pattern:split("+"))do
			c = dummyCard(p)
			if c and to_select:getClassName()==c:getClassName()
			then return true end
		end
	end,
	view_as = function(self,cards)
		return #cards>0 and cards[1]
	end,
	enabled_at_response = function(self,player,pattern)
		if string.sub(pattern,1,1)=="." or string.sub(pattern,1,1)=="@"
		or player:getPile("&ov_wei"):isEmpty() then return end
		for c,p in sgs.list(pattern:split("+"))do
			c = dummyCard(p)
			if not c then continue end
			for dc,id in sgs.list(player:getPile("&ov_wei"))do
				dc = sgs.Sanguosha:getCard(id)
				if dc:getClassName()==c:getClassName()
				then return true end
			end
		end
	end,
	enabled_at_nullification = function(self,player)
		if player:getPile("&ov_wei"):isEmpty() then return end
		for dc,id in sgs.list(player:getPile("&ov_wei"))do
			dc = sgs.Sanguosha:getCard(id)
			if dc:isKindOf("Nullification")
			then return true end
	   	end
	end,
	enabled_at_play = function(self,player)
		if player:getPile("&ov_wei"):isEmpty() then return end
		for dc,id in sgs.list(player:getPile("&ov_wei"))do
			dc = sgs.Sanguosha:getCard(id)
			if dc:isAvailable(player)
			then return true end
	   	end
	end,
}
ov_xiawei = sgs.CreateTriggerSkill{
	name = "ov_xiawei",
	events = {sgs.EventPhaseProceeding,sgs.EventPhaseChanging,sgs.GameStart},
	view_as_skill = ov_xiaweivs,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Start
		and ToSkillInvoke(self,player)
	   	then
			local wx = SetWangxing(self,player)
			wx = room:getNCards(wx.x+1)
			player:addToPile("&ov_wei",wx)
		elseif event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			local ids = player:getPile("&ov_wei")
			if change.from==sgs.Player_NotActive
			and ids:length()>0
			then
				Skill_msg(self,player)
				change = dummyCard()
				change:addSubcards(ids)
				room:throwCard(change,nil)
			end
		elseif event==sgs.GameStart
		then
			Skill_msg(self,player,math.random(1,2))
			local ids = sgs.IntList()
			for c,id in sgs.list(room:getDrawPile())do
				if ids:length()>1 then continue end
				c = sgs.Sanguosha:getCard(id)
				if c:getTypeId()~=1
				then continue end
				ids:append(id)
			end
			if ids:length()<1 then return end
			player:addToPile("&ov_wei",ids)
		end
		return false
	end
}
ov_qiaorui:addSkill(ov_xiawei)
ov_qongji = sgs.CreateTriggerSkill{
	name = "ov_qongji",
	events = {sgs.CardsMoveOneTime,sgs.DamageForseen},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			if move.from
			and player:getMark("ov_qongji-Clear")<1
			and move.from:objectName()==player:objectName()
			and move.from_places:contains(sgs.Player_PlaceSpecial)
			then
				if bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON)~=sgs.CardMoveReason_S_REASON_USE
				and bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON)~=sgs.CardMoveReason_S_REASON_RESPONSE
				then return end
				for i,pn in sgs.list(move.from_pile_names)do
					if pn=="&ov_wei"
					then
						room:sendCompulsoryTriggerLog(player,self:objectName(),true,true)
						player:drawCardsList(1,self:objectName())
						player:addMark("ov_qongji-Clear")
						break
					end
				end
			end
		elseif event==sgs.DamageForseen
		then
			local damage = data:toDamage()
			if player:getPile("&ov_wei"):isEmpty()
--			and player:getMark("ov_qongji-Clear")<1
			then
				room:sendCompulsoryTriggerLog(player,self:objectName(),true,true)
				DamageRevises(data,1,player)
				player:addMark("ov_qongji-Clear")
			end
		end
		return false
	end
}
ov_qiaorui:addSkill(ov_qongji)

ov_xiahouen = sgs.General(extension,"ov_xiahouen","wei",5)
ov_fujian = sgs.CreateTriggerSkill{
	name = "ov_fujian",
	events = {sgs.EventPhaseProceeding,sgs.CardsMoveOneTime,sgs.GameStart},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding and player:getPhase()==sgs.Player_Start
		or event==sgs.GameStart
	   	then
			if player:getWeapon() then return end
			room:sendCompulsoryTriggerLog(player,self:objectName(),true,true,1)
			local cs = sgs.CardList()
			for c,id in sgs.list(room:getDrawPile())do
				c = sgs.Sanguosha:getCard(id)
				if c:isKindOf("Weapon")
				then cs:append(c) end
			end
			cs = RandomList(cs)
			if cs:length()>0
			then
				cs = cs:at(0)
				player:obtainCard(cs)
				if room:getCardOwner(cs:getEffectiveId())==player
				then
					room:moveCardTo(cs,player,sgs.Player_PlaceEquip)
				end
			end
		elseif event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			if move.from
			and not room:getTag("FirstRound"):toBool()
			and player:getPhase()==sgs.Player_NotActive
			and move.from:objectName()==player:objectName()
--			and move.from_places:contains(sgs.Player_PlaceEquip)
			then
				for i,id in sgs.list(move.card_ids)do
					if move.from_places:at(i)==sgs.Player_PlaceEquip
					and (move.to_place~=sgs.Player_PlaceHand or not move.to or move.to:objectName()~=player:objectName())
					or move.from_places:at(i)==sgs.Player_PlaceHand
					and (move.to_place~=sgs.Player_PlaceEquip or not move.to or move.to:objectName()~=player:objectName())
					then
						id = sgs.Sanguosha:getCard(id)
						if id:isKindOf("Weapon")
						then
							room:sendCompulsoryTriggerLog(player,self:objectName(),true,true,2)
							room:loseHp(player)
						end
					end
				end
				
			end
		end
		return false
	end
}
ov_xiahouen:addSkill(ov_fujian)
ov_jianwei = sgs.CreateTriggerSkill{
	name = "ov_jianwei",
	events = {sgs.EventPhaseProceeding,sgs.TargetSpecifying},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Start
	   	then
			local sp = sgs.SPlayerList()
			for i,p in sgs.list(room:getOtherPlayers(player))do
				if player:inMyAttackRange(p)
				and player:canPindian(p)
				then sp:append(p) end
			end
			if sp:isEmpty() then return end
			local to = room:askForPlayerChosen(player,sp,"ov_jianwei","ov_jianwei0:",true,true)
			if not to then return end
			room:broadcastSkillInvoke(self:objectName())
			player:pindian(to,"ov_jianwei")
		elseif event==sgs.TargetSpecifying
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
			and player:getWeapon()
			then
				Skill_msg(self,player,math.random(1,2))
				for c,to in sgs.list(use.to)do
					to:addQinggangTag(use.card)
				end
			end
		end
		return false
	end
}
ov_xiahouen:addSkill(ov_jianwei)
ov_jianweibf = sgs.CreateTriggerSkill{
	name = "#ov_jianweibf",
	events = {sgs.EventPhaseProceeding,sgs.Pindian,sgs.PindianVerifying}, 
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName("ov_jianwei")
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Start
		then
	     	local sp = sgs.SPlayerList()
			for i,p in sgs.list(room:findPlayersBySkillName("ov_jianwei"))do
				if player:objectName()~=p:objectName()
				and player:canPindian(p)
				then sp:append(p) end
			end
			while sp:length()>0 do
				local to = room:askForPlayerChosen(player,sp,"ov_jianweibf","ov_jianweibf0:",true)
				if not to then return end
				ToSkillInvoke("ov_jianwei",player,to,true)
				player:pindian(to,"ov_jianwei")
				sp:removeOne(to)
			end
		elseif event==sgs.PindianVerifying
		then
			local pindian = data:toPindian()
			for i,owner in sgs.list(room:findPlayersBySkillName("ov_jianwei"))do
				local n = owner:getAttackRange()
				if pindian.from:objectName()==owner:objectName()
				and owner:getWeapon()
				then
					Skill_msg("ov_jianwei",owner)
					pindian.from_number = pindian.from_number+n
					if pindian.from_number>13 then pindian.from_number = 13 end
					Log_message("$ov_niju10",owner,nil,pindian.from_card:getEffectiveId(),"+"..n,pindian.from_number)
					data:setValue(pindian)
				end
				if pindian.to:objectName()==owner:objectName()
				and owner:getWeapon()
				then
					Skill_msg("ov_jianwei",owner)
					pindian.to_number = pindian.to_number+n
					if pindian.to_number>13 then pindian.to_number = 13 end
					Log_message("$ov_niju10",owner,nil,pindian.to_card:getEffectiveId(),"+"..n,pindian.to_number)
					data:setValue(pindian)
				end
			end
		elseif event==sgs.Pindian
		then
			local pindian = data:toPindian()
			if pindian.reason=="ov_jianwei"
			then
				for _,owner in sgs.list(room:findPlayersBySkillName("ov_jianwei"))do
					if pindian.from:objectName()~=owner:objectName()
					and pindian.to:objectName()~=owner:objectName()
					then continue end
					Skill_msg("ov_jianwei",owner)
					if pindian.to:objectName()==owner:objectName()
					then
						if pindian.success
						then
							if owner:getWeapon()
							then
								pindian.from:obtainCard(owner:getWeapon())
							end
						else
							local b,d,flags = sgs.IntList(),dummyCard(),"hej"
							while pindian.from:getCards("hej"):length()>b:length() do
								owner:setTag("askForCardChosen_ForAI",ToData(b))
								local id = room:askForCardChosen(owner,pindian.from,flags,"ov_jianwei",false,sgs.Card_MethodNone,b)
								owner:removeTag("askForCardChosen_ForAI")
								if id<0 then break end
								local cp = room:getCardPlace(id)
								if cp==sgs.Player_PlaceHand
								then flags = "ej" end
								d:addSubcard(id)
								for i,c in sgs.list(pindian.from:getCards("hej"))do
									i = c:getEffectiveId()
									if room:getCardPlace(i)~=cp
									then continue end
									b:append(i)
								end
							end
							owner:obtainCard(d,false)
						end
					elseif pindian.success
					then
						local b,d,flags = sgs.IntList(),dummyCard(),"hej"
						while pindian.to:getCards("hej"):length()>b:length() do
							owner:setTag("askForCardChosen_ForAI",ToData(b))
							local id = room:askForCardChosen(owner,pindian.to,flags,"ov_jianwei",false,sgs.Card_MethodNone,b)
							owner:removeTag("askForCardChosen_ForAI")
							if id<0 then break end
							local cp = room:getCardPlace(id)
							if cp==sgs.Player_PlaceHand
							then flags = "ej" end
							d:addSubcard(id)
							for i,c in sgs.list(pindian.to:getCards("hej"))do
								i = c:getEffectiveId()
								if room:getCardPlace(i)~=cp
								then continue end
								b:append(i)
							end
						end
						owner:obtainCard(d,false)
					elseif owner:getWeapon()
					then
						pindian.to:obtainCard(owner:getWeapon())
					end
				end
			end
		end
		return false
	end
}
ov_xiahouen:addSkill(ov_jianweibf)
extension:insertRelatedSkills("ov_jianwei", "#ov_jianweibf")

ov_feiyi = sgs.General(extension,"ov_feiyi","shu",3)
ov_shengxi = sgs.CreateTriggerSkill{
	name = "ov_shengxi",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseProceeding,sgs.Damage,sgs.CardFinished},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
	   	then
			if player:getPhase()==sgs.Player_Start
			and ToSkillInvoke(self,player)
			then
				room:broadcastSkillInvoke("mobilezhishengxi")
				for i,c in sgs.list(PatternsCard("Tiaojiyanmei",true,true))do
					if room:getCardOwner(c:getEffectiveId())
					then continue end
					player:obtainCard(c)
					break
				end
			elseif player:getPhase()==sgs.Player_Finish
			and player:getMark("ov_shengxiUse-Clear")>0
			and player:getMark("ov_shengxiDamage-Clear")<1
			and ToSkillInvoke(self,player)
			then
				room:broadcastSkillInvoke("mobilezhishengxi")
				for i,c in sgs.list(PatternsCard(sgs.ZhinangClassName,true,true))do
					if room:getCardPlace(c:getEffectiveId())==sgs.Player_PlaceTable
					or room:getCardOwner(c:getEffectiveId())
					then continue end
					player:obtainCard(c)
					break
				end
				player:drawCardsList(1,self:objectName())
			end
		elseif event==sgs.Damage
		and player:getPhase()~=sgs.Player_NotActive
		then player:addMark("ov_shengxiDamage-Clear")
		elseif event==sgs.CardFinished
		and player:getPhase()~=sgs.Player_NotActive
		then
			local use = data:toCardUse()
			if use.card:getTypeId()>0
			then
				player:addMark("ov_shengxiUse-Clear")
			end
		end
		return false
	end
}
ov_feiyi:addSkill(ov_shengxi)
ov_kuanji = sgs.CreateTriggerSkill{
	name = "ov_kuanji",
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			if move.from
			and player:getMark("ov_kuanji-Clear")<1
			and move.to_place==sgs.Player_DiscardPile
			and move.from:objectName()==player:objectName()
			and bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON)~=sgs.CardMoveReason_S_REASON_USE
			then
				local ids = sgs.IntList()
				for i,id in sgs.list(move.card_ids)do
					i = move.from_places:at(i)
					if (i==sgs.Player_PlaceHand or i==sgs.Player_PlaceEquip)
					and room:getCardPlace(id)==sgs.Player_DiscardPile
					then ids:append(id) end
				end
				if ids:isEmpty()
				then return end
				room:fillAG(ids,player)
				local to = room:askForPlayerChosen(player,room:getOtherPlayers(player),"ov_kuanji","ov_kuanji0:",true,true)
				room:clearAG(player)
				if not to then return end
				room:broadcastSkillInvoke("mobilezhijianyu")
				player:addMark("ov_kuanji-Clear")
				local dc = dummyCard()
				while ids:length()>0 do
					room:fillAG(ids,player)
					local id = room:askForAG(player,ids,dc:subcardsLength()>0,self:objectName())
					if id<0 then break end
					room:clearAG(player)
					dc:addSubcard(id)
					ids:removeOne(id)
				end
				to:obtainCard(dc)
			end
		end
		return false
	end
}
ov_feiyi:addSkill(ov_kuanji)
ov_tiaojiyanmei = sgs.CreateTrickCard{
	name = "_ov_tiaojiyanmei",
	class_name = "Tiaojiyanmei",
	subclass = sgs.LuaTrickCard_TypeNormal,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	subtype = "ov_feiyi_card",
--	damage_card = true,
	can_recast = true,
	filter = function(self,targets,to_select,source)
		if source:isCardLimited(self,sgs.Card_MethodUse) then return #targets<1 end
		if #targets>sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)+1
		then return	end
		for i,target in sgs.list(targets)do
			if target:getHandcardNum()==to_select:getHandcardNum()
			then return end
		end
		return true
	end,
	feasible = function(self,targets)
		if sgs.Self:isCardLimited(self,sgs.Card_MethodUse) then return #targets<1 end
		return #targets>1 or #targets<1 and not sgs.Self:isCardLimited(self,sgs.Card_MethodRecast)
	end,
	about_to_use = function(self,room,use)
       	if use.to:length()<2
		then UseCardRecast(use.from,self,"ov_tiaojiyanmei")
		else self:cardOnUse(room,use) end
	end,
	on_use = function(self,room,source,targets)
		local tos = {}
		for i,to in sgs.list(targets)do
			table.insert(tos,to)
		end
		local func = function(a,b)
			return a:getHandcardNum()>b:getHandcardNum()
		end
		table.sort(tos,func)
		for i,to in sgs.list(targets)do
			if to:getHandcardNum()==tos[1]:getHandcardNum()
			then to:setFlags(self:toString().."throwCard") end
			if to:getHandcardNum()==tos[#tos]:getHandcardNum()
			then to:setFlags(self:toString().."drawCard") end
			if to:getHandcardNum()>tos[#tos]:getHandcardNum()
			then to:setFlags(self:toString().."throwCard") end
			if to:getHandcardNum()<tos[1]:getHandcardNum()
			then to:setFlags(self:toString().."drawCard") end
		end
		tos = {}
		room:removeTag(self:toString().."throwCard")
		local nullified_list = room:getTag("CardUseNullifiedList"):toStringList()
		local effect = sgs.CardEffectStruct()
		effect.from = source
		effect.card = self
		effect.multiple = #targets>1
	   	local log = sgs.LogMessage()
		log.type = "$ov_tiaojiyanmeiChosen"
		for i,to in sgs.list(targets)do
			effect.to = to
			effect.no_offset = self:hasFlag("no_offset_"..source:objectName()..to:objectName())
			effect.no_respond = self:hasFlag("no_respond_"..source:objectName()..to:objectName())
			effect.nullified = table.contains(nullified_list,"_ALL_TARGETS") or table.contains(nullified_list,to:objectName())
	    	room:cardEffect(effect)
			to:setFlags("-"..self:toString().."throwCard")
			to:setFlags("-"..self:toString().."drawCard")
			table.insert(tos,to:getHandcardNum())
			log.to:append(to)
		end
		log.arg = table.concat(tos,",")
		for _,to1 in sgs.list(targets)do
			for _,to2 in sgs.list(targets)do
				log.arg2 = "HandcardNum~"
				if to1:getHandcardNum()~=to2:getHandcardNum()
				then room:sendLog(log) return end
			end
		end
		log.arg2 = "HandcardNum="
		room:sendLog(log)
		effect = dummyCard()
		local throw = room:getTag(self:toString().."throwCard"):toIntList()
		for i,id in sgs.list(throw)do
			if room:getCardPlace(id)==sgs.Player_DiscardPile
			then effect:addSubcard(id) end
		end
		if effect:subcardsLength()<1 then return end
		room:fillAG(effect:getSubcards(),source)
		throw = PlayerChosen(self,source,nil,"_ov_tiaojiyanmei0:",true)
		room:clearAG(source)
		if throw
		then
			throw:obtainCard(effect)
		end
	end,
	on_effect = function(self,effect)
		local from,to,room = effect.from,effect.to,effect.to:getRoom()
		if effect.no_respond then else end
		if effect.to:hasFlag(self:toString().."throwCard")
		then
			local tc = room:askForDiscard(to,"_ov_tiaojiyanmei",1,1,false,true)
			if tc
			then
				local throw = room:getTag(self:toString().."throwCard"):toIntList()
				for i,id in sgs.list(tc:getSubcards())do
					throw:append(id)
				end
				room:setTag(self:toString().."throwCard",ToData(throw))
			end
		end
		if effect.to:hasFlag(self:toString().."drawCard")
		then
			effect.to:drawCardsList(1,self:objectName())
		end
		return false
	end,
}
for i=0,3 do
	ov_tiaojiyanmei:clone(i,6):setParent(extension)
end

ov_qiaogong = sgs.General(extension,"ov_qiaogong","wu",3)
ov_yizhu = sgs.CreateTriggerSkill{
	name = "ov_yizhu",
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
	   	then
			if player:getPhase()==sgs.Player_Finish
			then
				Skill_msg(self,player,math.random(1,2))
				player:drawCardsList(2,self:objectName())
				local x = player:aliveCount()*2
				local dc = room:askForExchange(player,"ov_yizhu",2,2,true,"ov_yizhu0:"..x)
				dc = dc:getSubcards()
				for i,id in sgs.list(dc)do
					i = math.random(1,x)
					room:moveCardsInToDrawpile(player,id,"ov_yizhu",i)
				end
				player:setTag("ov_yizhu_ids",ToData(dc))
			end
		end
		return false
	end
}
ov_yizhubf = sgs.CreateTriggerSkill{
	name = "#ov_yizhubf",
	events = {sgs.TargetSpecifying},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName("ov_yizhu")
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.TargetSpecifying
		then
			for i,owner in sgs.list(room:findPlayersBySkillName("ov_yizhu"))do
				i = owner:getTag("ov_yizhu_ids"):toIntList()
				if player:objectName()==owner:objectName()
				or i:isEmpty() then continue end
				local use = data:toCardUse()
				if i:contains(use.card:getId())
				and use.card:getTypeId()>0
				and use.to:length()<2
				then
					local tos = sgs.SPlayerList()
					Skill_msg("ov_yizhu",owner,math.random(1,2))
					for _,p in sgs.list(room:getAlivePlayers())do
						if use.to:contains(p) then continue end
						if use.from:canUse(use.card,p)
						then tos:append(p) end
					end
					if tos:isEmpty() then continue end
					owner:setTag("ov_yizhuData",data)
					i = PlayerChosen("ov_yizhu",owner,tos,"ov_yizhu1:"..use.card:objectName(),true)
					if i
					then
						local msg = sgs.LogMessage()
						msg.from = owner
						msg.card_str = use.card:toString()
						msg.type = "$ov_qirangTarget"
						msg.to:append(i)
						if use.card:isKindOf("EquipCard")
						or use.card:isKindOf("DelayedTrick")
						or room:askForChoice(owner,"ov_yizhu","ov_yizhu2+ov_yizhu3",data)=="ov_yizhu2"
						then
							use.to = sgs.SPlayerList()
							use.to:append(i)
							msg.arg = "Target="
						else
							if use.card:isKindOf("Collateral")
							then
								local tos = sgs.SPlayerList()
								for _,to in sgs.list(room:getAlivePlayers())do
									if i:canSlash(to) then tos:append(to) end
								end
								tos = room:askForPlayerChosen(player,tos,"ov_qirang1","ov_qirang1:"..i:objectName()..":ov_yizhu",true)
								if tos then i:setTag("collateralVictim",ToData(tos)) else return end
							end
							use.to:append(i)
							room:sortByActionOrder(use.to)
							msg.arg = "Target+"
						end
						room:sendLog(msg)
						data:setValue(use)
						owner:drawCardsList(1,"ov_yizhu")
					end
				end
			end
		end
		return false
	end
}
ov_qiaogong:addSkill(ov_yizhu)
ov_qiaogong:addSkill(ov_yizhubf)
extension:insertRelatedSkills("ov_yizhu", "#ov_yizhubf")
ov_luanchouCard = sgs.CreateSkillCard{
	name = "ov_luanchouCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		return #targets<2
	end,
	feasible = function(self,targets)
		return #targets>1
	end,
	on_use = function(self,room,source,targets)
		for i,to in sgs.list(room:getAlivePlayers())do
			if to:getMark("ov_luanchou_"..source:objectName())<1
			or table.contains(targets,to)
			then continue end
			to:removeMark("ov_luanchou_"..source:objectName())
			room:detachSkillFromPlayer(to,"ov_gonghuan")
		end
		for i,to in sgs.list(targets)do
			if to:getMark("ov_luanchou_"..source:objectName())>0
			then continue end
			to:addMark("ov_luanchou_"..source:objectName())
			room:acquireSkill(to,"ov_gonghuan")
		end
	end
}
ov_luanchouvs = sgs.CreateViewAsSkill{
	name = "ov_luanchou",
	view_as = function(self,cards)
		return ov_luanchouCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_luanchouCard")<1
	end,
}
ov_luanchou = sgs.CreateTriggerSkill{
	name = "ov_luanchou",
	waked_skills = "ov_gonghuan",
	view_as_skill = ov_luanchouvs,
	events = {sgs.Death,sgs.EventLoseSkill},
	can_trigger = function(self,target)
		return target and target:hasSkill(self)
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Death
		then
			local death = data:toDeath()
			if death.who:objectName()~=player:objectName()
			then return end
		elseif data:toString()~="ov_luanchou"
		then return end
		for i,to in sgs.list(room:getAlivePlayers())do
			if to:getMark("ov_luanchou_"..player:objectName())<1
			then continue end
			to:removeMark("ov_luanchou_"..player:objectName())
			room:detachSkillFromPlayer(to,"ov_gonghuan")
		end
		return false
	end
}
ov_qiaogong:addSkill(ov_luanchou)
ov_gonghuan = sgs.CreateTriggerSkill{
	name = "ov_gonghuan",
	events = {sgs.DamageInflicted},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.DamageInflicted
		then
			local gh = room:findPlayersBySkillName("ov_gonghuan")
			gh:removeOne(player)
			for i,owner in sgs.list(gh)do
				owner:setTag("ov_gonghuan",data)
				if player:getHp()>owner:getHp()
				or player:getMark("ov_gonghuanDamage")>0
				or not ToSkillInvoke(self,owner,player)
				then continue end
				local damage = data:toDamage()
				damage.to = owner
				damage.transfer = true
				damage.transfer_reason = "ov_gonghuan"
				data:setValue(damage)
				owner:addMark("ov_gonghuanDamage")
				room:damage(damage)
				owner:removeMark("ov_gonghuanDamage")
				return true
			end
		end
		return false
	end
}
addToSkills(ov_gonghuan)

ov_xushu = sgs.General(extension,"ov_xushu","qun")
ov_jiangevs = sgs.CreateViewAsSkill{
	name = "ov_jiange",
	n = 1,
	view_filter = function(self,selected,to_select)
		if to_select:isKindOf("BasicCard")
		or sgs.Self:isJilei(to_select)
		then return end
		if sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_PLAY
		then
			local d = dummyCard()
			d:setSkillName("ov_jiange")
			d:addSubcard(to_select)
			return d:isAvailable(sgs.Self)
		end
		return true
	end,
	view_as = function(self,cards)
		local c = sgs.Sanguosha:cloneCard("slash")
		c:setSkillName("ov_jiange")
		c:setFlags("ov_jiange")
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"slash")
		then return player:getMark("ov_jiange-Clear")<1 end
	end,
	enabled_at_play = function(self,player)
		return CardIsAvailable(player,"slash","ov_jiange")
		and player:getMark("ov_jiange-Clear")<1
	end,
}
ov_jiange = sgs.CreateTriggerSkill{
	name = "ov_jiange",
	view_as_skill = ov_jiangevs,
	events = {sgs.CardResponded,sgs.CardFinished},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardResponded
		then
			local res = data:toCardResponse()
			if res.m_card:getSkillName()~="ov_jiange"
			and not res.m_card:hasFlag("ov_jiange")
			then return end
			room:addPlayerMark(player,"ov_jiange-Clear")
			if player:getPhase()~=sgs.Player_NotActive
			then return end
			Skill_msg(self,player)
			player:drawCardsList(1,self:objectName())
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if use.card:getSkillName()~="ov_jiange"
			and not use.card:hasFlag("ov_jiange")
			then return end
			room:addPlayerMark(player,"ov_jiange-Clear")
			if player:getPhase()~=sgs.Player_NotActive
			then return end
			Skill_msg(self,player)
			player:drawCardsList(1,self:objectName())
		end
		return false
	end
}
ov_xushu:addSkill(ov_jiange)
ov_jiangebf = sgs.CreateTargetModSkill{
	name = "#ov_jiangebf",
	pattern = "Slash",
	residue_func = function(self,from,card)--额外使用
		if from:hasSkill("ov_jiange")
		and (card:getSkillName()=="ov_jiange" or card:hasFlag("ov_jiange"))
		then return 998 end
	end,
	distance_limit_func = function(self,from,card,to)--使用距离
		if from:hasSkill("ov_jiange")
		and (card:getSkillName()=="ov_jiange" or card:hasFlag("ov_jiange"))
		then return 998 end
	end,
	extra_target_func = function(self,from,card)--目标数
	end
}
ov_xushu:addSkill(ov_jiangebf)
extension:insertRelatedSkills("ov_jiange", "#ov_jiangebf")
ov_xiawang = sgs.CreateTriggerSkill{
	name = "ov_xiawang",
	events = {sgs.Damaged},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.Damaged
		then
			local damage = data:toDamage()
			if damage.to:objectName()~=player:objectName()
			or not damage.card or not damage.card:isBlack()
			or not damage.from then return end
			for i,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
				if not owner:canSlash(damage.from,false)
				or owner:distanceTo(player)>1
				then continue end
				i = room:askForUseSlashTo(owner,damage.from,"ov_xiawang0:"..damage.from:objectName())
				if i
				then
					i = room:getTag("damage_caused_"..i:toString()):toDamage()
					if i and i.to
					then
						Skill_msg(self,owner)
						i = room:getCurrent()
						if i:getPhase()==sgs.Player_Play
						then room:setPlayerFlag(i,"Global_PlayPhaseTerminated")
						else i:setTag("FinishPhase",ToData(i:getPhase())) end
					end
				end
			end
		end
	end,
}
ov_xushu:addSkill(ov_xiawang)

ov_tongyuan = sgs.General(extension,"ov_tongyuan","qun")
ov_chaofengCard = sgs.CreateSkillCard{
	name = "ov_chaofengCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		return to_select:objectName()~=from:objectName()
		and from:canPindian(to_select)
		and #targets<3
	end,
	on_use = function(self,room,source,targets)
		local pd = targetsPindian("ov_chaofeng",source,targets)
		if pd and pd.success_owner
		then
			local d = dummyCard("fire_slash")
			d:setSkillName("_ov_chaofeng")
			local use = sgs.CardUseStruct()
			use.card = d
			use.from = pd.success_owner
			if pd.success_owner==source
			then
				for c,to in sgs.list(targets)do
					if use.from:canSlash(to,d,false)
					then use.to:append(to) end
				end
			else
				if use.from:canSlash(source,d,false)
				then use.to:append(source) end
				for c,to in sgs.list(targets)do
					if use.from:objectName()~=to:objectName()
					and use.from:canSlash(to,d,false)
					then use.to:append(to) end
				end
			end
			if use.to:length()<1 then return end
			room:useCard(use)
		end
	end
}
ov_chaofengcard = sgs.CreateSkillCard{
	name = "ov_chaofengcard",
	will_throw = false,
	filter = function(self,targets,to_select,player)
		local pattern = self:getUserString()
		if pattern=="normal_slash" then pattern = "slash" end
		return SCfilter(pattern,targets,to_select,self,"ov_chaofeng")
	end,
	feasible = function(self,targets)
		local pattern = self:getUserString()
		if pattern=="normal_slash" then pattern = "slash" end
		return SCfeasible(pattern,targets,self,"ov_chaofeng")
	end,
	on_validate = function(self,use)
		local yuji = use.from
		local room = yuji:getRoom()
		local to_guhuo = self:getUserString()
		local choices = {}
		if string.find(to_guhuo,"slash")
		and sgs.Sanguosha:getCurrentCardUseReason()~=sgs.CardUseStruct_CARD_USE_REASON_PLAY
		then
			for c,pm in sgs.list(patterns)do
				c = dummyCard(pm)
				c:setSkillName("ov_chaofeng")
				c:addSubcard(self)
				if c:isAvailable(yuji) and c:isKindOf("Slash")
				then table.insert(choices,pm) end
			end
		else
			for c,pm in sgs.list(to_guhuo:split("+"))do
				c = dummyCard(pm)
				c:setSkillName("ov_chaofeng")
				c:addSubcard(self) if c:isAvailable(yuji)
				then table.insert(choices,pm) end
			end
		end
		if #choices<1 then return nil end
		to_guhuo = room:askForChoice(yuji,"ov_chaofeng",table.concat(choices,"+"))
		local use_card = sgs.Sanguosha:cloneCard(to_guhuo)
		use_card:setSkillName("ov_chaofeng")
		use_card:addSubcard(self)
		return use_card
	end,
	on_validate_in_response = function(self,yuji)
		local room = yuji:getRoom()
		local to_guhuo = self:getUserString()
		local choices = {}
		if string.find(to_guhuo,"slash")
		and sgs.Sanguosha:getCurrentCardUseReason()~=sgs.CardUseStruct_CARD_USE_REASON_PLAY
		then
			for c,pm in sgs.list(patterns)do
				c = dummyCard(pm)
				c:setSkillName("ov_chaofeng")
				c:addSubcard(self)
				if yuji:isCardLimited(c,self:getHandlingMethod())
				or not c:isKindOf("Slash") then continue end
				table.insert(choices,pm)
			end
		else
			for c,pm in sgs.list(to_guhuo:split("+"))do
				c = dummyCard(pm)
				c:setSkillName("ov_chaofeng")
				c:addSubcard(self)
				if yuji:isCardLimited(c,self:getHandlingMethod())
				then continue end
				table.insert(choices,pm)
			end
		end
		if #choices<1 then return nil end
		to_guhuo = room:askForChoice(yuji,"ov_chaofeng",table.concat(choices,"+"))
		local use_card = sgs.Sanguosha:cloneCard(to_guhuo)
		use_card:setSkillName("ov_chaofeng")
		use_card:addSubcard(self)
		return use_card
	end
}
ov_chaofengvs = sgs.CreateViewAsSkill{
	name = "ov_chaofeng",
	n = 1,
	view_filter = function(self,selected,to_select)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if string.find(pattern,"@@ov_chaofeng") then return end
		if sgs.Self:isJilei(to_select) then return end
		if sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_PLAY
		then
			local card = sgs.Self:getTag("ov_chaofeng"):toCard()
			local d = dummyCard(card:objectName())
			d:setSkillName("ov_chaofeng")
			d:addSubcard(to_select)
			return d:isAvailable(sgs.Self)
			and to_select:isKindOf("Jink")
		end
		return string.find(pattern,"slash") and to_select:isKindOf("Jink")
		or string.find(pattern,"jink") and to_select:isKindOf("Slash")
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if string.find(pattern,"@@ov_chaofeng")
		then return ov_chaofengCard:clone() end
		local c = ov_chaofengcard:clone()
		if sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_PLAY
		then
			local card = sgs.Self:getTag("ov_chaofeng"):toCard()
			c:setUserString(card:objectName())
		else c:setUserString(pattern) end
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@ov_chaofeng")
		or string.find(pattern,"slash")
		or string.find(pattern,"jink")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return CardIsAvailable(player,"slash","ov_chaofeng")
	end,
}
ov_chaofeng = sgs.CreateTriggerSkill{
	name = "ov_chaofeng",
	events = {sgs.EventPhaseStart},
	view_as_skill = ov_chaofengvs,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseStart
		and player:getPhase()==sgs.Player_Play
	   	then
			for _,p in sgs.list(room:getOtherPlayers(player))do
				if player:canPindian(p)
				then
					room:askForUseCard(player,"@@ov_chaofeng","ov_chaofeng0:")
					break
				end
			end
			local list = {}
			for d,p in sgs.list(AllCardPatterns())do
				d = dummyCard(p)
				if d and d:isKindOf("Slash")
				then table.insert(list,p) end
			end
			room:setPlayerProperty(player,"allowed_guhuo_dialog_buttons",ToData(table.concat(list,"+")))
		else
			room:setPlayerProperty(player,"allowed_guhuo_dialog_buttons",ToData())
		end
		return false
	end
}
ov_chaofeng:setGuhuoDialog("l")
ov_tongyuan:addSkill(ov_chaofeng)
ov_chuanshu = sgs.CreateTriggerSkill{
	name = "ov_chuanshu",
	events = {sgs.EventPhaseProceeding,sgs.EventPhaseChanging},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Start
	   	then
			local to = room:askForPlayerChosen(player,room:getAlivePlayers(),"ov_chuanshu","ov_chunshu0:",true,true)
			if not to then return end
			room:broadcastSkillInvoke(self:objectName())
			room:setPlayerMark(to,"&ov_chuanshu+#"..player:objectName(),1)
			to:addMark("ov_chunshu_slash"..player:objectName())
		elseif event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.from==sgs.Player_NotActive
			then
				for i,p in sgs.list(room:getAlivePlayers())do
					room:setPlayerMark(p,"&ov_chuanshu+#"..player:objectName(),0)
					p:removeMark("ov_chunshu_slash"..player:objectName())
				end
			end
		end
		return false
	end
}
ov_tongyuan:addSkill(ov_chuanshu)
ov_chunshubf = sgs.CreateTriggerSkill{
	name = "#ov_chunshubf",
	events = {sgs.ConfirmDamage,sgs.CardFinished,sgs.PindianVerifying,sgs.DamageCaused}, 
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName("ov_chuanshu")
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.ConfirmDamage
		then
			local damage = data:toDamage()
			for i,owner in sgs.list(room:findPlayersBySkillName("ov_chuanshu"))do
				if player:getMark("ov_chunshu_slash"..owner:objectName())>0
				and damage.card and damage.card:isKindOf("Slash")
				and damage.to:objectName()~=owner:objectName()
				then
					Skill_msg("ov_chuanshu",owner)
					DamageRevises(data,1,player)
					damage = data:toDamage()
				end
			end
		elseif event==sgs.DamageCaused
		then
			local damage = data:toDamage()
			for i,owner in sgs.list(room:findPlayersBySkillName("ov_chuanshu"))do
				if player:getMark("ov_chunshu_slash"..owner:objectName())>0
				and damage.card and damage.card:isKindOf("Slash")
				and player:objectName()~=owner:objectName()
				then
					Skill_msg("ov_chuanshu",owner)
					owner:drawCardsList(damage.damage,self:objectName())
				end
			end
		elseif event==sgs.PindianVerifying
		then
			local pindian = data:toPindian()
			for i,owner in sgs.list(room:findPlayersBySkillName("ov_chuanshu"))do
			if pindian.from:getMark("&ov_chuanshu+#"..owner:objectName())>0
			then
				Skill_msg("ov_chuanshu",owner)
				pindian.from_number = pindian.from_number+3
				if pindian.from_number>13 then pindian.from_number=13 end
				Log_message("$ov_niju10",pindian.from,nil,pindian.from_card:getEffectiveId(),"+3",pindian.from_number)
				data:setValue(pindian)
			end
			if pindian.to:getMark("&ov_chuanshu+#"..owner:objectName())>0
			then
				Skill_msg("ov_chuanshu",owner)
				pindian.to_number = pindian.to_number+3
				if pindian.to_number>13 then pindian.to_number=13 end
				Log_message("$ov_niju10",pindian.to,nil,pindian.to_card:getEffectiveId(),"+3",pindian.to_number)
				data:setValue(pindian)
			end
			end
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") then return end
			for i,owner in sgs.list(room:findPlayersBySkillName("ov_chuanshu"))do
				player:removeMark("ov_chunshu_slash"..owner:objectName())
			end
		end
		return false
	end
}
ov_tongyuan:addSkill(ov_chunshubf)
extension:insertRelatedSkills("ov_chuanshu", "#ov_chunshubf")

ov_liyan = sgs.General(extension,"ov_liyan","qun")
ov_zhenhuCard = sgs.CreateSkillCard{
	name = "ov_zhenhuCard",
	will_throw = false,
	skill_name = "_ov_zhenhu",
	filter = function(self,targets,to_select,from)
		return to_select:objectName()~=from:objectName()
		and from:canPindian(to_select)
		and #targets<3
	end,
	on_use = function(self,room,source,targets)
		local pd = targetsPindian("ov_zhenhu",source,targets)
		if pd and pd.success_owner
		and pd.success_owner:objectName()==source:objectName()
		then
			source:addMark("ov_zhenhu_success")
			return
		end
		room:loseHp(source)
	end
}
ov_zhenhuvs = sgs.CreateViewAsSkill{
	name = "ov_zhenhu",
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if string.find(pattern,"@@ov_zhenhu")
		then return ov_zhenhuCard:clone() end
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@ov_zhenhu")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_zhenhu = sgs.CreateTriggerSkill{
	name = "ov_zhenhu",
	events = {sgs.ConfirmDamage,sgs.TargetSpecified,sgs.CardFinished},
	view_as_skill = ov_zhenhuvs,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.ConfirmDamage
		then
			local damage = data:toDamage()
			if damage.card
			and damage.to:getMark(damage.card:toString().."ov_zhenhu_damage")>0
			then
				Skill_msg(self,player)
				DamageRevises(data,1,player)
			end
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if use.card:isDamageCard()
			then
				for _,to in sgs.list(use.to)do
					to:removeMark(use.card:toString().."ov_zhenhu_damage")
				end
			end
		elseif event==sgs.TargetSpecified
		then
			local use = data:toCardUse()
			if use.card:isDamageCard()
			and ToSkillInvoke(self,player,nil,data)
			then
				player:drawCardsList(1,self:objectName())
				for _,p in sgs.list(room:getOtherPlayers(player))do
					if player:canPindian(p)
					then
						local use_ = room:askForUseCardStruct(player,"@@ov_zhenhu!","ov_zhenhu0:")
						if use_ and use_.to
						and player:getMark("ov_zhenhu_success")>0
						then
							player:removeMark("ov_zhenhu_success")
							for _,to in sgs.list(use.to)do
								if use_.to:contains(to)
								then
									to:addMark(use.card:toString().."ov_zhenhu_damage")
								end
							end
						end
						break
					end
				end
			end
		end
		return false
	end
}
ov_liyan:addSkill(ov_zhenhu)
ov_lvren = sgs.CreateTriggerSkill{
	name = "ov_lvren",
	events = {sgs.PreCardUsed,sgs.PindianVerifying,sgs.DamageCaused}, 
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName("ov_lvren")
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.PindianVerifying
		then
			local pindian = data:toPindian()
			for i,owner in sgs.list(room:findPlayersBySkillName("ov_lvren"))do
			i = owner:getTag("targetsPindian_"..pindian.reason):toString():split("+")
			i = #i>0 and #i*2 or 2
			if pindian.from:objectName()==owner:objectName()
			then
				Skill_msg("ov_lvren",owner)
				pindian.from_number = pindian.from_number+i
				if pindian.from_number>13 then pindian.from_number=13 end
				Log_message("$ov_niju10",pindian.from,nil,pindian.from_card:getEffectiveId(),"+"..i,pindian.from_number)
				data:setValue(pindian)
			elseif pindian.to:objectName()==owner:objectName()
			then
				Skill_msg("ov_lvren",owner)
				pindian.to_number = pindian.to_number+i
				if pindian.to_number>13 then pindian.to_number=13 end
				Log_message("$ov_niju10",pindian.to,nil,pindian.to_card:getEffectiveId(),"+"..i,pindian.to_number)
				data:setValue(pindian)
			end
			end
		elseif event==sgs.DamageCaused
		then
			local damage = data:toDamage()
			if player:hasSkill(self)
			and player:objectName()~=damage.to:objectName()
			and damage.to:getMark("&ov_ren+#"..player:objectName())<1
			then
				Skill_msg("ov_lvren",player)
				room:addPlayerMark(damage.to,"&ov_ren+#"..player:objectName())
			end
		elseif event==sgs.PreCardUsed
		then
			local use = data:toCardUse()
			if use.card:isDamageCard()
			and not use.card:isKindOf("DelayedTrick")
			and player:hasSkill(self)
			and use.to:length()>0
			then
				local sp = sgs.SPlayerList()
				for i,p in sgs.list(room:getOtherPlayers(player))do
					if p:getMark("&ov_ren+#"..player:objectName())<1
					or player:isProhibited(p,use.card)
					or use.to:contains(p)
					then continue end
					sp:append(p)
				end
				if sp:isEmpty() then return end
				player:setTag("ov_lvren",data)
				local to = room:askForPlayerChosen(player,sp,"ov_lvren","ov_lvren0:"..use.card:objectName(),true,true)
				if not to then return end
				room:broadcastSkillInvoke(self:objectName())
				use.to:append(to)
				room:sortByActionOrder(use.to)
				data:setValue(use)
				room:removePlayerMark(to,"&ov_ren+#"..player:objectName())
			end
		end
		return false
	end
}
ov_liyan:addSkill(ov_lvren)

ov_wangyue = sgs.General(extension,"ov_wangyue","qun")
ov_yulong = sgs.CreateTriggerSkill{
	name = "ov_yulong",
	events = {sgs.ConfirmDamage,sgs.TargetSpecified,sgs.CardFinished},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.ConfirmDamage
		then
			local damage = data:toDamage()
			if damage.card
			and player:getMark(damage.card:toString().."ov_yulong_damage")>0
			then
				Skill_msg(self,player)
				DamageRevises(data,1,player)
			end
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			local damage = room:getTag("damage_caused_"..use.card:toString()):toDamage()
			if damage and damage.to
			and player:getMark(use.card:toString().."ov_yulong")>0
			then
				Skill_msg(self,player)
				player:removeMark(use.card:toString().."ov_yulong")
				room:addPlayerHistory(player,use.card:getClassName(),-1)
			end
			player:removeMark(use.card:toString().."ov_yulong_damage")
		elseif event==sgs.TargetSpecified
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
			and use.to:length()>0
			then
				local sp = sgs.SPlayerList()
				for _,to in sgs.list(use.to)do
					if player:canPindian(to)
					then sp:append(to) end
				end
				if sp:isEmpty() then return end
				local to = room:askForPlayerChosen(player,sp,"ov_yulong","ov_yulong0:",true,true)
				if not to then return end
				room:broadcastSkillInvoke(self:objectName())
				sp = player:PinDian(to,"ov_yulong")
				if sp.success
				then
					player:addMark(use.card:toString().."ov_yulong")
					if sp.from_card:isRed()
					then
						local no_respond = use.no_respond_list
						for _,to in sgs.list(use.to)do
							table.insert(no_respond,to:objectName())
						end
						use.no_respond_list = no_respond
						data:setValue(use)
						Skill_msg(self,player)
					elseif sp.from_card:isBlack()
					then
						player:addMark(use.card:toString().."ov_yulong_damage")
					end
				end
			end
		end
		return false
	end
}
ov_wangyue:addSkill(ov_yulong)
ov_jianming = sgs.CreateTriggerSkill{
	name = "ov_jianming",
	events = {sgs.CardUsed,sgs.CardResponded},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardResponded
		then
			local res = data:toCardResponse()
			if not res.m_card:isKindOf("Slash")
			or player:getMark(res.m_card:getSuit().."ov_jianming-Clear")>0
			then return end
			player:addMark(res.m_card:getSuit().."ov_jianming-Clear")
			room:sendCompulsoryTriggerLog(player,self:objectName(),true,true)
			MarkRevises(player,"&ov_jianming-Clear",res.m_card:getSuitString().."_char")
			player:drawCardsList(1,self:objectName())
		elseif event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash")
			or player:getMark(use.card:getSuit().."ov_jianming-Clear")>0
			then return end
			player:addMark(use.card:getSuit().."ov_jianming-Clear")
			room:sendCompulsoryTriggerLog(player,self:objectName(),true,true)
			MarkRevises(player,"&ov_jianming-Clear",use.card:getSuitString().."_char")
			player:drawCardsList(1,self:objectName())
		end
		return false
	end
}
ov_wangyue:addSkill(ov_jianming)

ov_shenlvmeng = sgs.General(extension,"ov_shenlvmeng","god",3)
ov_shelie = sgs.CreateTriggerSkill{
	name = "ov_shelie",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseProceeding,sgs.EventPhaseChanging,sgs.CardFinished,sgs.RoundStart},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase() == sgs.Player_Draw
		and player:askForSkillInvoke(self:objectName())
		then
       		room:broadcastSkillInvoke("shelie")--播放配音
    		local card_ids = room:getNCards(5,false)
			local ids = sgs.IntList()
	   		for _,id in sgs.list(card_ids)do
	    		ids:append(id)
			end
	    	room:fillAG(card_ids)
	       	local dummy,dc = dummyCard(),dummyCard()
	    	while ids:length()>0 do
	    		local id = room:askForAG(player,ids,false,"ov_shelie")
	    		dummy:addSubcard(id)
	    		room:takeAG(player,id,false)
	    		for _,to_id in sgs.list(card_ids)do
	    			if sgs.Sanguosha:getCard(to_id):getSuit()==sgs.Sanguosha:getCard(id):getSuit()
					and ids:contains(to_id)
					then
	    				if to_id~=id
						then
							dc:addSubcard(to_id)
							room:takeAG(nil,to_id,false)
						end
	    				ids:removeOne(to_id)
	    			end
	    		end
	    	end
         	room:clearAG()
			player:obtainCard(dummy)
			room:throwCard(dc,nil)
	    	return true
        elseif event==sgs.RoundStart
        then player:removeMark("ov_shelieUse")
        elseif event==sgs.EventPhaseChanging
        then
	     	local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
				local suits = player:getTag("ov_shelieSuits"):toIntList()
				player:removeTag("ov_shelieSuits")
				if suits:length()>=player:getHp()
				and player:getMark("ov_shelieUse")<1
				then
					Skill_msg(self,player)
					player:addMark("ov_shelieUse")
					suits = room:askForChoice(player,"ov_shelie","Player_Draw+Player_Play")
					PhaseExtra(player,sgs[suits],true)
				end
			end
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if use.card:getTypeId()>0
			and player:getPhase()~=sgs.Player_NotActive
			then
				local suits = player:getTag("ov_shelieSuits"):toIntList()
				if suits:contains(use.card:getSuit())
				then return end
				suits:append(use.card:getSuit())
				player:setTag("ov_shelieSuits",ToData(suits))
				MarkRevises(player,"&ov_shelie-Clear",use.card:getSuitString().."_char")
			end
		end
		return false
	end
}
ov_shenlvmeng:addSkill(ov_shelie)
ov_gongxinCard = sgs.CreateSkillCard{
	name = "ov_gongxinCard",
	will_throw = false,
	skill_name = "gongxin",
	filter = function(self,targets,to_select,from)
		return to_select:objectName()~=from:objectName()
	end,
	on_use = function(self,room,source,targets)
		for c,to in sgs.list(targets)do
            local id = room:doGongxin(source,to,to:handCards(),"ov_gongxin")
	    	if id>=0
			then
				c = "ov_gongxin1"
				room:showCard(to,id)
				local n = getPileSuitNum(to:getHandcards())
				if source:canDiscard(to,id) then c = "ov_gongxin1+ov_gongxin2" end
				c = room:askForChoice(source,"ov_gongxin",c,ToData(to))
				if c=="ov_gongxin1"
				then room:moveCardsInToDrawpile(source,id,"ov_gongxin",1,true)
				else room:throwCard(id,to,source) end
				if getPileSuitNum(to:getHandcards())<n
				then
					c = "red+black+cancel"
					c = room:askForChoice(source,"ov_gongxin",c,ToData(to))
					if c~="cancel"
					then
						room:setPlayerCardLimitation(to,"use,response",".|"..c,false)
						to:addMark(source:objectName().."ov_gongxindebf-Clear")
						to:setTag("ov_gongxindebf",ToData(c))
					end
				end
			end
		end
	end,
}
ov_gongxinVS = sgs.CreateViewAsSkill{
	name = "ov_gongxin",
	view_as = function(self,cards)
        return ov_gongxinCard:clone() 
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_gongxinCard")<1
	end,
}
ov_gongxindebf = sgs.CreateTriggerSkill{
	name = "#ov_gongxindebf",
	events = {sgs.EventPhaseChanging},
	can_trigger = function(self,target)
		if target and target:isAlive()
		then
			for i,p in sgs.list(target:getRoom():getAlivePlayers())do
				if p:getTag("ov_gongxindebf"):toString()~=""
				then return true end
			end
		end
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			or change.from==sgs.Player_NotActive
			then
				for i,p in sgs.list(room:getAlivePlayers())do
					if p:getMark(player:objectName().."ov_gongxindebf-Clear")>0
					then
						i = p:getTag("ov_gongxindebf"):toString()
						room:removePlayerCardLimitation(p,"use,response",".|"..i)
						p:removeTag("ov_gongxindebf")
					end
				end
			end
		end
	end
}
ov_shenlvmeng:addSkill(ov_gongxinVS)
ov_shenlvmeng:addSkill(ov_gongxindebf)
extension:insertRelatedSkills("ov_gongxin", "#ov_gongxindebf")

ov_weixu = sgs.General(extension,"ov_weixu","qun")
ov_suizheng = sgs.CreateTriggerSkill{
	name = "ov_suizheng",
	events = {sgs.GameStart},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.GameStart
		then
			room:sendCompulsoryTriggerLog(player,self:objectName(),true,true)
			local to = PlayerChosen(self,player,room:getOtherPlayers(player),"ov_suizheng0:")
			room:addPlayerMark(to,"&ov_suizheng+#"..player:objectName())
		end
	end
}
ov_suizhengbf = sgs.CreateTriggerSkill{
	name = "#ov_suizhengbf",
	events = {sgs.Damage,sgs.Damaged},
	can_trigger = function(self,target)
		if target and target:isAlive()
		then
			for i,owner in sgs.list(target:getRoom():findPlayersBySkillName("ov_suizheng"))do
				if target:getMark("&ov_suizheng+#"..owner:objectName())>0
				then return true end
			end
		end
	end,
	on_trigger = function(self,event,player,data,room)
		for i,owner in sgs.list(room:findPlayersBySkillName("ov_suizheng"))do
			if player:getMark("&ov_suizheng+#"..owner:objectName())<1 then continue end
			room:sendCompulsoryTriggerLog(owner,"ov_suizheng",true,true)
			if event==sgs.Damage
			then
				owner:drawCardsList(1,"ov_suizheng")
			else
				owner:setTag("ov_suizheng",ToData(player))
				i = room:askForDiscard(owner,"ov_suizheng",2,2,true,true,"ov_suizheng1:"..player:objectName(),"BasicCard")
				if i
				then
					room:recover(player,sgs.RecoverStruct(owner))
				else
					room:loseHp(owner)
					if owner:isDead() then continue end
					i = room:askForChoice(owner,"ov_suizheng","slash+duel",ToData(player))
					local cs = sgs.CardList()
					for c,id in sgs.list(room:getDiscardPile())do
						c = sgs.Sanguosha:getCard(id)
						if c:isKindOf("Slash") and i=="slash"
						or c:isKindOf("Duel") and i=="duel"
						then cs:append(c) end
					end
					for c,id in sgs.list(room:getDrawPile())do
						c = sgs.Sanguosha:getCard(id)
						if c:isKindOf("Slash") and i=="slash"
						or c:isKindOf("Duel") and i=="duel"
						then cs:append(c) end
					end
					cs = RandomList(cs)
					if cs:length()>0
					then
						player:obtainCard(cs:at(0))
					end
				end
			end
		end
	end
}
ov_weixu:addSkill(ov_suizheng)
ov_weixu:addSkill(ov_suizhengbf)
extension:insertRelatedSkills("ov_suizheng", "#ov_suizhengbf")
ov_tuidao = sgs.CreateTriggerSkill{
	name = "ov_tuidao",
	events = {sgs.EventPhaseProceeding},
	frequency = sgs.Skill_Limited,
	limit_mark = "@ov_tuidao",
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Start
		and player:hasSkill("ov_suizheng",true)
		and player:getMark("@ov_tuidao")>0
		then
			local can,to = true,nil
			for i,p in sgs.list(room:getAlivePlayers())do
				if p:getMark("&ov_suizheng+#"..player:objectName())>0
				then can = p:getHp()<3 to = p break end
			end
			can = can and ToSkillInvoke(self,player,to)
			if not can then return end
			room:doSuperLightbox(player:getGeneralName(),self:objectName())
			room:removePlayerMark(player,"@ov_tuidao")
			ThrowEquipArea(self,player,nil,nil,2,3)
			if to
			then
				can = {}
				for i=2,3 do
					if to:hasEquipArea(i)
					then
						table.insert(can,"@Equip"..i.."lose")
					end
				end
				if #can>0
				then
					can = room:askForChoice(player,"ov_tuidao",table.concat(can,"+"),ToData(to))
					can = string.sub(can,7,7)-0
					to:throwEquipArea(can)
				end
			end
			local Type = room:askForChoice(player,"ov_tuidao","BasicCard+TrickCard+EquipCard",ToData(to))
			can = room:getOtherPlayers(player)
			local dc = dummyCard()
			if to
			then
				for _,c in sgs.list(to:getCards("he"))do
					if c:isKindOf(Type)
					then dc:addSubcard(c) end
				end
				room:removePlayerMark(to,"&ov_suizheng+#"..player:objectName())
				can:removeOne(to)
			else
				for c,id in sgs.list(room:getDrawPile())do
					if sgs.Sanguosha:getCard(id):isKindOf(Type)
					and dc:subcardsLength()<2
					then dc:addSubcard(c) end
				end
			end
			if dc:subcardsLength()>0
			then player:obtainCard(dc) end
			to = PlayerChosen(self,player,can,"ov_tuidao0:")
			room:addPlayerMark(to,"&ov_suizheng+#"..player:objectName())
			if dc:subcardsLength()>0 then to:obtainCard(dc) end
		end
	end
}
ov_weixu:addSkill(ov_tuidao)

ov_haomeng = sgs.General(extension,"ov_haomeng","qun")
ov_gongge = sgs.CreateTriggerSkill{
	name = "ov_gongge",
	events = {sgs.ConfirmDamage,sgs.TargetSpecified,sgs.CardFinished,sgs.EventPhaseChanging},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.ConfirmDamage
		then
			local damage = data:toDamage()
			if damage.card and damage.to:getMark("ov_gongge3"..damage.card:toString())>0
			then
				Skill_msg(self,player)
				DamageRevises(data,damage.to:getMark("ov_gongge3"..damage.card:toString()),player)
			end
		elseif event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_Draw
			and player:getMark("&ov_gonggedebf")>0
			then
				Skill_msg(self,player)
				room:setPlayerMark(player,"&ov_gonggedebf",0)
				player:skip(change.to)
			end
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if use.card:isDamageCard()
			then
				for i,to in sgs.list(use.to)do
					if to:isDead() then continue end
					i = to:getMark("ov_gongge3"..use.card:toString())
					if i>0
					then
						Skill_msg(self,player)
						room:recover(to,sgs.RecoverStruct(player,nil,i))
					end
					to:setMark("ov_gongge3"..use.card:toString(),0)
					i = player:getMark("ov_gongge2"..to:objectName())
					if i>0 and to:getHp()>=player:getHp()
					then
						Skill_msg(self,player)
						i = room:askForExchange(player,"ov_gongge",i,i,true,"ov_gongge01:"..i..":"..to:objectName())
						room:giveCard(player,to,i,"ov_gongge")
					end
					player:setMark("ov_gongge2"..to:objectName(),0)
				end
			end
		elseif event==sgs.TargetSpecified
		then
			local use = data:toCardUse()
			if player:getMark("ov_gonggeUse-Clear")<1
			and use.card:isDamageCard()
			then
				player:setTag("ov_gongge",data)
				local to = room:askForPlayerChosen(player,use.to,"ov_gongge","ov_gongge0:",true,true)
				if to
				then
					player:addMark("ov_gonggeUse-Clear")
					local x = 0
					for _,s in sgs.list(to:getSkillList())do
						if s:isAttachedLordSkill() then continue end
						x = x+1
					end
					room:broadcastSkillInvoke("ov_gongge")
					to:setTag("ov_gongge"..player:objectName(),ToData(x))
					local choices = {}
					table.insert(choices,"ov_gongge1="..x+1)
					table.insert(choices,"ov_gongge2="..x+1)
					table.insert(choices,"ov_gongge3="..x)
					choices = table.concat(choices,"+")
					choices = room:askForChoice(player,"ov_gongge",choices,ToData(to))
					if choices:startsWith("ov_gongge1")
					then
						player:drawCardsList(x+1,"ov_gongge")
						use.card:setFlags(player:objectName().."ov_gongge"..to:objectName())
					elseif choices:startsWith("ov_gongge2")
					then
						choices = dummyCard()
						local place = {}
						for i=0,x do
							if to:getCardCount()<1 then break end
							i = room:askForCardChosen(player,to,"he","ov_gongge",false,sgs.Card_MethodDiscard)
							choices:addSubcard(i)
							place[i] = room:getCardPlace(i)
							to:addToPile("#ov_gongge",i)
						end
						for _,id in sgs.list(choices:getSubcards())do
							room:moveCardTo(sgs.Sanguosha:getCard(id),to,place[id])
						end
						room:throwCard(choices,to,player)
						player:addMark("ov_gongge2"..to:objectName(),x)
					else
						to:addMark("ov_gongge3"..use.card:toString(),x)
					end
				end
			end
		end
		return false
	end
}
ov_gonggebf = sgs.CreateTriggerSkill{
	name = "#ov_gonggebf",
	events = {sgs.CardUsed,sgs.CardResponded},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName("ov_gongge")
	end,
	on_trigger = function(self,event,player,data,room)
		local card
		if event==sgs.CardResponded
		then card = data:toCardResponse().m_toCard
		else card = data:toCardUse().whocard end
		for i,owner in sgs.list(room:findPlayersBySkillName("ov_gongge"))do
			if card and card:hasFlag(owner:objectName().."ov_gongge"..player:objectName())
			then room:addPlayerMark(owner,"&ov_gonggedebf") end
		end
		return false
	end,
}
ov_haomeng:addSkill(ov_gongge)
ov_haomeng:addSkill(ov_gonggebf)
extension:insertRelatedSkills("ov_gongge", "#ov_gonggebf")

ov_caoxiu = sgs.General(extension,"ov_caoxiu","wei")
ov_qianju = sgs.CreateDistanceSkill{
	name = "ov_qianju",
	correct_func = function(self,from,to)
		if from:hasSkill(self) and from:hasEquip()
		then return -from:getEquips():length() end
	end
}
ov_qianjubf = sgs.CreateTriggerSkill{
	name = "#ov_qianjubf",
	events = {sgs.Damage},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:hasSkill("ov_qianju")
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Damage
		then
		    local damage = data:toDamage()
			if player:distanceTo(damage.to)<=1
			and player:getMark("ov_qianjuUse-Clear")<1
			then
				local ins = sgs.IntList()
				for i=0,4 do
					if player:hasEquipArea(i)
					and not player:getEquip(i)
					then ins:append(i) end
				end
				if ins:isEmpty() then return end
				room:sendCompulsoryTriggerLog(player,"ov_qianju",true,true)
				player:addMark("ov_qianjuUse-Clear")
				local ids = sgs.IntList()
				for c,id in sgs.list(room:getDiscardPile())do
					c = sgs.Sanguosha:getCard(id)
					if c:isKindOf("EquipCard")
					then
						c = c:getRealCard():toEquipCard():location()
						if ins:contains(c) then ids:append(id) end
					end
				end
				for c,id in sgs.list(room:getDrawPile())do
					c = sgs.Sanguosha:getCard(id)
					if c:isKindOf("EquipCard")
					then
						c = c:getRealCard():toEquipCard():location()
						if ins:contains(c) then ids:append(id) end
					end
				end
				room:fillAG(ids,player)
				ids = room:askForAG(player,ids,ids:isEmpty(),"ov_qianju")
				room:clearAG(player)
				if ids>=0
				then
					InstallEquip(ids,player,self)
				end
			end
		end
		return false
	end,
}
ov_caoxiu:addSkill(ov_qianju)
ov_caoxiu:addSkill(ov_qianjubf)
extension:insertRelatedSkills("ov_qianju", "#ov_qianjubf")
ov_qingxi = sgs.CreateTriggerSkill{
	name = "ov_qingxi",
	events = {sgs.ConfirmDamage,sgs.TargetSpecified},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.ConfirmDamage
		then
			local damage = data:toDamage()
			if damage.card and player:getMark(damage.card:toString().."ov_qingxi-Clear")>0
			then
				Skill_msg(self,player)
				DamageRevises(data,player:getMark(damage.card:toString().."ov_qingxi-Clear"),player)
			end
		elseif event==sgs.TargetSpecified
		then
			local use = data:toCardUse()
			if player:getMark("ov_qingxiUse-Clear")<1
			and use.card:isKindOf("Slash")
			then
				player:addMark("ov_qingxiUse-Clear")
				for i,to in sgs.list(use.to)do
					if ToSkillInvoke(self,player,to)
					then
						local x = player:getEquips():length()
						x = x<1 and 1 or x
						local choices = {}
						table.insert(choices,"ov_qingxi1="..player:objectName()..":"..x)
						if to:hasEquip() then table.insert(choices,"ov_qingxi2="..player:objectName()) end
						choices = table.concat(choices,"+")
						choices = room:askForChoice(to,"ov_qingxi",choices,ToData(player))
						if choices:startsWith("ov_qingxi1")
						then
							player:drawCardsList(x,"ov_qingxi")
							choices = use.no_respond_list
							table.insert(choices,to:objectName())
							use.no_respond_list = choices
						else
							x = to:getEquips():length()
							to:throwAllEquips()
							choices = dummyCard()
							local place = {}
							for i=1,x do
								if player:getEquips():isEmpty() then break end
								i = choices:getSubcards()
								i = room:askForCardChosen(to,player,"e","ov_qingxi",false,sgs.Card_MethodDiscard,i)
								choices:addSubcard(i)
								place[i] = room:getCardPlace(i)
								player:addToPile("#ov_qingxi",i)
							end
							for _,id in sgs.list(choices:getSubcards())do
								room:moveCardTo(sgs.Sanguosha:getCard(id),player,place[id])
							end
							room:throwCard(choices,player,to)
							player:addMark(use.card:toString().."ov_qingxi-Clear")
						end
					end
				end
				data:setValue(use)
			end
		end
		return false
	end
}
ov_caoxiu:addSkill(ov_qingxi)

ov_sunyi = sgs.General(extension,"ov_sunyi","wu")
ov_zaoliCard = sgs.CreateSkillCard{
	name = "ov_zaoliCard",
	skill_name = "_ov_zaoli",
	mute = true,
	target_fixed = true,
	handling_method = sgs.Card_MethodDiscard,
	on_use = function(self,room,source,targets)
		source:drawCardsList(self:subcardsLength(),"ov_zaoli")
		local cns = sgs.IntList()
		for c,id in sgs.list(self:getSubcards())do
			c = sgs.Sanguosha:getCard(id)
			if c:isKindOf("EquipCard")
			then
				c = c:getRealCard():toEquipCard():location()
				if cns:contains(c) then continue end
				cns:append(c)
			end
		end
		local n = 0
		while cns:length()>0 do
			local ids = sgs.IntList()
			for c,id in sgs.list(room:getDrawPile())do
				c = sgs.Sanguosha:getCard(id)
				if c:isKindOf("EquipCard")
				then
					c = c:getRealCard():toEquipCard():location()
					if cns:contains(c) then ids:append(id) end
				end
			end
			if ids:isEmpty() then break end
			room:fillAG(ids,source)
			ids = room:askForAG(source,ids,ids:isEmpty(),"ov_zaoli")
			room:clearAG(source)
			if ids>=0
			then
				n = n+1
				InstallEquip(ids,source,"ov_zaoli")
				ids = sgs.Sanguosha:getCard(ids)
				ids = ids:getRealCard():toEquipCard():location()
				cns:removeOne(ids)
			end
		end
		if n>2 then room:loseHp(source) end
	end
}
ov_zaolivs = sgs.CreateViewAsSkill{
	name = "ov_zaoli",
	n = 998,
	expand_pile = "#judgePile",
	response_pattern = "@@ov_zaoli!",
	view_filter = function(self,selected,to_select)
		return sgs.Self:canDiscard(sgs.Self,to_select:getEffectiveId())
		and to_select:getTypeId()~=3
	end,
	view_as = function(self,cards)
		local card = ov_zaoliCard:clone()
		for _,c in sgs.list(cards)do
			card:addSubcard(c)
		end
		for _,c in sgs.list(sgs.Self:getEquips())do
			if sgs.Self:canDiscard(sgs.Self,c:getEffectiveId())
			then card:addSubcard(c) end
		end
		for _,c in sgs.list(sgs.Self:getHandcards())do
			if sgs.Self:canDiscard(sgs.Self,c:getEffectiveId())
			and c:getTypeId()==3 then card:addSubcard(c) end
		end
		return #cards>0 and card
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_zaoli = sgs.CreateTriggerSkill{
	name = "ov_zaoli",
	view_as_skill = ov_zaolivs,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart,sgs.EventPhaseChanging},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseStart
		and player:getPhase()==sgs.Player_Play
		and player:getCardCount(true,true)>0
		then
			room:sendCompulsoryTriggerLog(player,"ov_zaoli",true,true)
			local card = player:getJudgingAreaID()
			room:notifyMoveToPile(player,card,"judgePile",sgs.Player_PlaceDelayedTrick,true)
			local can = room:askForUseCard(player,"@@ov_zaoli!","ov_zaoli0:",-1,sgs.Card_MethodDiscard)
			room:notifyMoveToPile(player,card,"judgePile",sgs.Player_PlaceDelayedTrick,false)
			if can then return end
			card = ov_zaoliCard:clone()
			for _,c in sgs.list(player:getCards("hej"))do
				if player:canDiscard(player,c:getEffectiveId())
				and c:getTypeId()==3 then card:addSubcard(c) end
			end
			room:useCard(sgs.CardUseStruct(card,player,sgs.SPlayerList()))
		elseif event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.from==sgs.Player_NotActive
			then
				local ids = {}
				for _,c in sgs.list(player:getHandcards())do
					table.insert(ids,c:getEffectiveId())
				end
				ids = table.concat(ids,",")
				player:setTag("ov_zaoliIds",ToData(ids))
				room:setPlayerCardLimitation(player,"use,response",ids.."|.|.|hand",false)
			end
		end
		return false
	end
}
ov_zaolibf = sgs.CreateTriggerSkill{
	name = "#ov_zaolibf",
	events = {sgs.EventPhaseChanging},
	can_trigger = function(self,target)
		return target and target:getTag("ov_zaoliIds"):toString()~=""
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
				local ids = player:getTag("ov_zaoliIds"):toString()
				room:removePlayerCardLimitation(player,"use,response",ids.."|.|.|hand")
				player:removeTag("ov_zaoliIds")
			end
		end
	end
}
ov_sunyi:addSkill(ov_zaoli)
ov_sunyi:addSkill(ov_zaolibf)
extension:insertRelatedSkills("ov_zaoli", "#ov_zaolibf")

ov_guohuai = sgs.General(extension,"ov_guohuai","wei")
ov_jingce = sgs.CreateTriggerSkill{
	name = "ov_jingce",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damage,sgs.CardFinished,sgs.CardsMoveOneTime},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Damage
		then
			if player:getPhase()~=sgs.Player_NotActive
			then
				player:addMark("ov_jingceDamage-Clear")
			end
		elseif event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			if move.to and move.to:objectName()==player:objectName()
			and move.reason.m_reason==sgs.CardMoveReason_S_REASON_DRAW
			and player:getPhase()==sgs.Player_Play
			then
				player:addMark("ov_jingceDRAW-PlayClear")
			end
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if player:getPhase()==sgs.Player_Play
			and use.card:getTypeId()>0
			then
				room:addPlayerMark(player,"&ov_jingce-PlayClear")
				if player:getMark("&ov_jingce-PlayClear")==player:getHp()
				and ToSkillInvoke(self,player)
				then
					room:broadcastSkillInvoke("jingce")
					local can = player:getMark("ov_jingceDRAW-PlayClear")>0 or player:getMark("ov_jingceDamage-Clear")>0
					player:drawCardsList(player:getMark("&ov_jingce-PlayClear"),"ov_jingce")
					if can then player:gainMark("&ov_jingceCE") end
				end
			end
		end
		return false
	end
}
ov_guohuai:addSkill(ov_jingce)
ov_yuzhang = sgs.CreateTriggerSkill{
	name = "ov_yuzhang",
	events = {sgs.EventPhaseChanging,sgs.Damaged},
	on_trigger = function(self,event,player,data,room)
		if player:getMark("&ov_jingceCE")<1
		then return end
		if event == sgs.EventPhaseChanging
		then
	    	local change = data:toPhaseChange()
            if change.to>0 and change.to<7
	    	then
		    	local to_phase = "Player_Start"
				if change.to==2 then to_phase = "Player_Judge"
				elseif change.to==3 then to_phase = "Player_Draw"
				elseif change.to==4 then to_phase = "Player_Play"
				elseif change.to==5 then to_phase = "Player_Discard"
				elseif change.to==6 then to_phase = "Player_Finish" end
				if ToSkillInvoke(self,player,nil,ToData("ov_yuzhang:"..to_phase))
				then
					player:loseMark("&ov_jingceCE")
					player:skip(change.to)
 				end
			end
		else
		    local damage = data:toDamage()
			if damage.from
			and ToSkillInvoke(self,player,damage.from)
			then
				player:loseMark("&ov_jingceCE")
				local choices = "ov_yuzhang1="..damage.from:objectName().."+ov_yuzhang2="..damage.from:objectName()
				choices = room:askForChoice(player,"ov_yuzhang",choices,ToData(damage.from))
				if choices:startsWith("ov_yuzhang1")
				then
					damage.from:addMark("ov_yuzhang1debf-Clear")
					room:setPlayerCardLimitation(damage.from,"use,response",".|.|.|hand",false)
				else room:askForDiscard(damage.from,"ov_yuzhang",2,2,false,true) end
			end
 		end
	end
}
ov_yuzhang1debf = sgs.CreateTriggerSkill{
	name = "#ov_yuzhang1debf",
	events = {sgs.EventPhaseChanging},
	can_trigger = function(self,target)
		if target and target:isAlive()
		then
			for _,p in sgs.list(target:getRoom():getAlivePlayers())do
				if p:getMark("ov_yuzhang1debf-Clear")>0
				then return true end
			end
		end
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			or change.from==sgs.Player_NotActive
			then
				for _,p in sgs.list(room:getAlivePlayers())do
					if p:getMark("ov_yuzhang1debf-Clear")<1 then continue end
					room:removePlayerCardLimitation(p,"use,response",".|.|.|hand")
					p:removeMark("ov_yuzhang1debf-Clear")
				end
			end
		end
	end
}
ov_guohuai:addSkill(ov_yuzhang)
ov_guohuai:addSkill(ov_yuzhang1debf)
extension:insertRelatedSkills("ov_yuzhang", "#ov_yuzhang1debf")

ov_dianwei = sgs.General(extension,"ov_dianwei","qun")
ov_liexiCard = sgs.CreateSkillCard{
	name = "ov_liexiCard",
	handling_method = sgs.Card_MethodDiscard,
	filter = function(self,targets,to_select,from)
		return #targets<1 and to_select:objectName()~=from:objectName()
	end,
	on_use = function(self,room,source,targets)
		for _,to in sgs.list(targets)do
			if self:subcardsLength()>to:getHp()
			then room:damage(sgs.DamageStruct("ov_liexi",source,to))
			else room:damage(sgs.DamageStruct("ov_liexi",to,source)) end
			for c,id in sgs.list(self:getSubcards())do
				c = sgs.Sanguosha:getCard(id)
				if c:isKindOf("Weapon")
				then
					room:damage(sgs.DamageStruct("ov_liexi",source,to))
					break
				end
			end
		end
	end
}
ov_liexivs = sgs.CreateViewAsSkill{
	name = "ov_liexi",
	n = 998,
	response_pattern = "@@ov_liexi",
	view_filter = function(self,selected,to_select)
		return sgs.Self:canDiscard(sgs.Self,to_select:getEffectiveId())
	end,
	view_as = function(self,cards)
		local card = ov_liexiCard:clone()
		for _,c in sgs.list(cards)do
			card:addSubcard(c)
		end
		return #cards>0 and card
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_liexi = sgs.CreateTriggerSkill{
	name = "ov_liexi",
	view_as_skill = ov_liexivs,
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding and player:getPhase()==sgs.Player_Start
		then room:askForUseCard(player,"@@ov_liexi","ov_liexi0:") end
	end
}
ov_dianwei:addSkill(ov_liexi)
ov_shezhong = sgs.CreateTriggerSkill{
	name = "ov_shezhong",
	events = {sgs.EventPhaseProceeding,sgs.Damage,sgs.Damaged},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Finish
		then
			if player:getMark("ov_shezhongUse-Clear")>0
			then
				local tos = math.min(player:getMark("ov_shezhong-Clear"),player:aliveCount()-1)
				tos = room:askForPlayersChosen(player,room:getOtherPlayers(player),"ov_shezhong",0,tos,"ov_shezhong0:"..tos,true)
				if tos:length()>0 then room:broadcastSkillInvoke("ov_shezhong",2) end
				for _,to in sgs.list(tos)do
					room:setPlayerMark(to,"&ov_shezhong",1)
				end
			end
			local tos = sgs.SPlayerList()
			for _,to in sgs.list(room:getOtherPlayers(player))do
				if to:getMark(player:objectName().."ov_shezhong-Clear")>0
				and to:getHp()>player:getHandcardNum()
				and player:getHandcardNum()<5
				then tos:append(to) end
			end
			if tos:isEmpty() then return end
			tos = room:askForPlayerChosen(player,tos,"ov_shezhong","ov_shezhong1:",true,true)
			if tos
			then
				room:broadcastSkillInvoke("ov_shezhong",1)
				player:drawCardsList(tos:getHp()-player:getHandcardNum(),"ov_shezhong")
			end
		elseif event==sgs.Damage
		then
			local damage = data:toDamage()
			player:addMark("ov_shezhong-Clear",damage.damage)
			if damage.to:objectName()~=player:objectName()
			then player:addMark("ov_shezhongUse-Clear") end
		elseif event==sgs.Damaged
		then
			local damage = data:toDamage()
			if damage.from
			then
				damage.from:addMark(player:objectName().."ov_shezhong-Clear")
			end
		end
	end
}
ov_shezhongbf = sgs.CreateTriggerSkill{
	name = "#ov_shezhongbf",
	events = {sgs.DrawNCards},
	can_trigger = function(self,target)
		return target and target:getMark("&ov_shezhong")>0
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.DrawNCards
		then
			local n = data:toInt()
			Skill_msg("ov_shezhong",player)
			room:setPlayerMark(player,"&ov_shezhong",0)
			data:setValue(n-1)
		end
		return false
	end
}
ov_dianwei:addSkill(ov_shezhong)
ov_dianwei:addSkill(ov_shezhongbf)
extension:insertRelatedSkills("ov_shezhong", "#ov_shezhongbf")

ov_lusu = sgs.General(extension,"ov_lusu","qun")
ov_kaizeng = sgs.CreateTriggerSkill{
	name = "ov_kaizeng",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventAcquireSkill,sgs.EventLoseSkill,sgs.CardsMoveOneTime},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventLoseSkill
		then
			if data:toString()==self:objectName()
			then
				for _,p in sgs.list(room:getOtherPlayers(player))do
					if p:hasSkill("ov_kaizengvs")
					then
						room:detachSkillFromPlayer(p,"ov_kaizengvs",true,true)
					end
				end
			end
		else
			for _,p in sgs.list(room:getOtherPlayers(player))do
				if p:hasSkill("ov_kaizengvs") then continue end
				room:attachSkillToPlayer(p,"ov_kaizengvs")
			end
		end
	end
}
ov_lusu:addSkill(ov_kaizeng)
ov_kaizengCard = sgs.CreateSkillCard{
	name = "ov_kaizengCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		return to_select:hasSkill("ov_kaizeng")
		and to_select:objectName()~=from:objectName()
		and #targets<1
	end,
	about_to_use = function(self,room,use)
		local ls = use.to:at(0)
		room:doAnimate(1,use.from:objectName(),ls:objectName())
		room:notifySkillInvoked(ls,"ov_kaizeng")
		use.from:addHistory("#jl_huangdianCard")
		local msg = sgs.LogMessage()
		msg.type = "$bf_huangtian0"
		msg.from = use.from
		msg.arg = ls:getGeneralName()
		msg.arg2 = "ov_kaizeng"
		room:sendLog(msg)
		msg = {}
		for dc,p in sgs.list(AllCardPatterns())do
			dc = dummyCard(p)
			if dc and dc:isKindOf("BasicCard")
			then table.insert(msg,p) end
		end
		table.insert(msg,"TrickCard")
		table.insert(msg,"EquipCard")
		msg = room:askForChoice(use.from,"ov_kaizeng",table.concat(msg,"+"),ToData(ls))
--		Log_message("#ov_kaizeng",use.from,nil,nil,msg)
		local dc = room:askForExchange(ls,"ov_kaizeng",ls:getCardCount(),1,true,"ov_kaizeng0:"..use.from:objectName()..":"..msg,true)
		if dc
		then
			room:broadcastSkillInvoke("ov_kaizeng")--播放配音
			room:giveCard(ls,use.from,dc,"ov_kaizeng")
			if ls:isDead() then return end
			if dc:subcardsLength()>1
			then ls:drawCardsList(1,"ov_kaizeng") end
			if ls:isDead() then return end
			for c,id in sgs.list(dc:getSubcards())do
				c = sgs.Sanguosha:getCard(id)
				if c:objectName()==msg
				or c:isKindOf(msg)
				then
					for d,x in sgs.list(room:getDrawPile())do
						d = sgs.Sanguosha:getCard(x)
						if c:getTypeId()<2
						then
							if d:objectName()~=c:objectName()
							and d:getTypeId()<2
							then
								ls:obtainCard(d)
								break
							end
						elseif c:getTypeId()~=d:getTypeId()
						and d:getTypeId()>1
						then
							ls:obtainCard(d)
							break
						end
					end
					break
				end
			end
		end
	end
}
ov_kaizengVS = sgs.CreateViewAsSkill{
	name = "ov_kaizengvs&",
	view_as = function(self,cards)
		return ov_kaizengCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_kaizengCard")<1
	end,
}
addToSkills(ov_kaizengVS)
ov_yangming = sgs.CreateTriggerSkill{
	name = "ov_yangming",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseEnd,sgs.CardFinished},
	on_trigger = function(self,event,player,data,room)
		local n = 0
		for i=1,3 do
			if player:getMark(i.."ov_yangming-PlayClear")>0
			then n = n+1 end
		end
		if event==sgs.EventPhaseEnd
		and player:getPhase()==sgs.Player_Play
		and n>0 and ToSkillInvoke(self,player)
		then
			player:drawCardsList(n,"ov_yangming")
			room:addMaxCards(player,n)
		elseif event==sgs.CardFinished
		and player:getPhase()==sgs.Player_Play
		then
			local use = data:toCardUse()
			if use.card:getTypeId()>0
			and player:getMark(use.card:getTypeId().."ov_yangming-PlayClear")<1
			then
				player:addMark(use.card:getTypeId().."ov_yangming-PlayClear")
				MarkRevises(player,"&ov_yangming-PlayClear",use.card:getType().."_char")
			end
		end
		return false
	end
}
ov_lusu:addSkill(ov_yangming)

ov_xiahouzie = sgs.General(extension,"ov_xiahouzie","qun",4,false)
ov_xiahouzie:setStartHp(3)
ov_xiechangCard = sgs.CreateSkillCard{
	name = "ov_xiechangCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		return from:canPindian(to_select) and #targets<1
		and to_select:objectName()~=from:objectName()
	end,
	on_use = function(self,room,source,targets)
		for i,target in sgs.list(targets)do
			if source:pindian(target,"ov_xiechang")
			then
				if target:getCardCount()>0
				then
					i = room:askForCardChosen(source,target,"he","ov_xiechang")
					if i>=0
					then
						room:obtainCard(source,i,false)
						if sgs.Sanguosha:getCard(i):isKindOf("EquipCard")
						then
							i = dummyCard()
							i:setSkillName("_ov_xiechang")
							if source:canUse(i,target)
							then
								room:useCard(sgs.CardUseStruct(i,source,target))
							end
						end
					end
				end
			else
				room:damage(sgs.DamageStruct("ov_xiechang",target,source))
				room:setPlayerMark(target,"&ov_xiechang+#"..source:objectName(),1)
			end
		end
	end
}
ov_xiechangvs = sgs.CreateViewAsSkill{
	name = "ov_xiechang",
	view_as = function(self,cards)
		return ov_xiechangCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_xiechangCard")<1
	end,
}
ov_xiechang = sgs.CreateTriggerSkill{
	name = "ov_xiechang",
	events = {sgs.ConfirmDamage},
	view_as_skill = ov_xiechangvs,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.ConfirmDamage
		then
			local damage = data:toDamage()
			if damage.to:getMark("&ov_xiechang+#"..player:objectName())>0
			then
				Skill_msg(self,player)
				room:setPlayerMark(damage.to,"&ov_xiechang+#"..player:objectName(),0)
				DamageRevises(data,1,player)
			end
		end
		return false
	end
}
ov_xiahouzie:addSkill(ov_xiechang)
ov_duoren = sgs.CreateTriggerSkill{
	name = "ov_duoren",
	events = {sgs.Death,sgs.Dying},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Death
		then
			local death = data:toDeath()
			local damage = death.damage
			if damage and damage.from
			and damage.from:objectName()==player:objectName()
			and ToSkillInvoke(self,player,death.who)
			then
				room:doSuperLightbox(player:getGeneralName(),"ov_duoren")
				room:loseMaxHp(player)
				damage = {}
				for i,sk in sgs.list(death.who:getSkillList())do
					if sk:isAttachedLordSkill()
					or sk:isLordSkill()
					then continue end
					table.insert(damage,sk:objectName())
				end
				if #damage<1 then return end
				damage = table.concat(damage,"|")
				player:setTag("ov_duorenSkills",ToData(damage))
				room:handleAcquireDetachSkills(player,damage)
			end
			local hplost = death.hplost
			if hplost and hplost.from
			and hplost.from:objectName()==player:objectName()
			and ToSkillInvoke(self,player,death.who)
			then
				room:loseMaxHp(player)
				hplost = {}
				for i,sk in sgs.list(death.who:getSkillList())do
					if sk:isAttachedLordSkill()
					or sk:isLordSkill()
					then continue end
					table.insert(hplost,sk:objectName())
				end
				if #hplost<1 then return end
				hplost = table.concat(hplost,"|")
				player:setTag("ov_duorenSkills",ToData(hplost))
				room:handleAcquireDetachSkills(player,hplost)
			end
		else
			local dy = data:toDying()
			if dy.who:objectName()==player:objectName()
			then return end
			dy = dy.damage
			if dy and dy.from
			and dy.from:objectName()==player:objectName()
			then
				dy = {}
				for i,sk in sgs.list(player:getTag("ov_duorenSkills"):toString():split("|"))do
					table.insert(dy,"-"..sk)
				end
				if #dy<1 then return end
				Skill_msg(self,player)
				player:removeTag("ov_duorenSkills")
				room:handleAcquireDetachSkills(player,table.concat(dy,"|"))
			end
		end
		return false
	end
}
ov_xiahouzie:addSkill(ov_duoren)

ov_zhaoe = sgs.General(extension,"ov_zhaoe","qun",3,false)
ov_yanshi = sgs.CreateTriggerSkill{
	name = "ov_yanshi",
	events = {sgs.GameStart,sgs.ConfirmDamage,sgs.Damage},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.GameStart
		then
			Skill_msg(self,player,1)
			local to = PlayerChosen(self,player,room:getOtherPlayers(player),"ov_yanshi0:")
			room:setPlayerMark(to,"&ov_yanshi+#"..player:objectName(),1)
		elseif event==sgs.ConfirmDamage
		then
			local damage = data:toDamage()
			if damage.to:getMark("&ov_zeshi+#"..player:objectName())>0
			then
				Skill_msg(self,player,math.random(2,3))
				DamageRevises(data,1,player)
			end
		elseif event==sgs.Damage
		then
			local damage = data:toDamage()
			if damage.to:getMark("&ov_zeshi+#"..player:objectName())>0
			then
				Skill_msg(self,player,math.random(2,3))
				player:drawCardsList(damage.damage,"ov_yanshi")
				Log_message("#ov_zeshi2",damage.to,nil,nil,"ov_zeshi")
				room:setPlayerMark(damage.to,"&ov_zeshi+#"..player:objectName(),0)
			end
		end
		return false
	end
}
ov_yanshibf = sgs.CreateTriggerSkill{
	name = "#ov_yanshibf",
	events = {sgs.Damaged},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName("ov_yanshi")
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Damaged
		then
			local damage = data:toDamage()
			if damage.from
			and damage.from:objectName()~=damage.to:objectName()
			then
				for _,owner in sgs.list(room:findPlayersBySkillName("ov_yanshi"))do
					if (owner:objectName()==damage.to:objectName() or damage.to:getMark("&ov_yanshi+#"..owner:objectName())>0)
					and damage.from:getMark("&ov_yanshi+#"..owner:objectName())+damage.from:getMark("&ov_zeshi+#"..owner:objectName())<1
					and damage.from:objectName()~=owner:objectName()
					then
						Skill_msg("ov_yanshi",owner)
						Log_message("#ov_zeshi1",damage.from,nil,nil,"ov_zeshi")
						room:setPlayerMark(damage.from,"&ov_zeshi+#"..owner:objectName(),1)
					end
				end
			end
		end
		return false
	end
}
ov_yanshibf1 = sgs.CreateTargetModSkill{
	name = "#ov_yanshibf1",
	pattern = ".",
	residue_func = function(self,from,card)-- 额外使用
	end,
	distance_limit_func = function(self,from,card,to)-- 使用距离
		if to and to:getMark("&ov_zeshi+#"..from:objectName())>0
		then return 999 end
	end,
	extra_target_func = function(self,from,card)--目标数
	end
}
ov_zhaoe:addSkill(ov_yanshi)
ov_zhaoe:addSkill(ov_yanshibf)
extension:insertRelatedSkills("ov_yanshi", "#ov_yanshibf")
ov_zhaoe:addSkill(ov_yanshibf1)
extension:insertRelatedSkills("ov_yanshi", "#ov_yanshibf1")
ov_renchou = sgs.CreateTriggerSkill{
	name = "ov_renchou",
	events = {sgs.Death},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self,target)
		return target and target:isDead()
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Death
		then
			local death = data:toDeath()
			local from = death.damage
			from = from and from.from
			from = from or death.hplost and death.hplost.from
			if not from then return end
			for _,owner in sgs.list(room:findPlayersBySkillName("ov_renchou"))do
				if owner==death.who
				then
					for _,p in sgs.list(room:getOtherPlayers(owner))do
						if p:getMark("&ov_yanshi+#"..owner:objectName())>0
						then
							room:sendCompulsoryTriggerLog(owner,"ov_renchou",true,true)
							room:doSuperLightbox(owner:getGeneralName(),"ov_renchou")
							room:damage(sgs.DamageStruct("ov_renchou",p,from,p:getHp()))
						end
					end
				end
				if death.who:getMark("&ov_yanshi+#"..owner:objectName())>0
				then
					room:sendCompulsoryTriggerLog(owner,"ov_renchou",true,true)
					room:doSuperLightbox(owner:getGeneralName(),"ov_renchou")
					room:damage(sgs.DamageStruct("ov_renchou",owner,from,owner:getHp()))
				end
			end
		end
		return false
	end
}
ov_zhaoe:addSkill(ov_renchou)

ov_gongsunfan = sgs.General(extension,"ov_gongsunfan","qun")
ov_huiyuan = sgs.CreateTriggerSkill{
	name = "ov_huiyuan",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardsMoveOneTime,sgs.CardFinished},
	on_trigger = function(self,event,player,data,room)
		if player:getPhase()~=sgs.Player_Play
		then return end
		if event==sgs.CardsMoveOneTime
		then
	    	local move = data:toMoveOneTime()
			if move.to_place==sgs.Player_PlaceHand
			and move.to:objectName()==player:objectName()
--			and (not move.from or move.from:objectName()~=player:objectName())
			then
				for c,id in sgs.list(move.card_ids)do
					c = sgs.Sanguosha:getCard(id)
					if player:getMark(c:getType().."ov_huiyuan-PlayClear")<1
					then
						player:addMark(c:getType().."ov_huiyuan-PlayClear")
						MarkRevises(player,"&ov_huiyuan-PlayClear",c:getType().."_char")
					end
				end
			end
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if use.card:getTypeId()>0
			and player:getMark(use.card:getType().."ov_huiyuan-PlayClear")<1
			then
				local to = sgs.SPlayerList()
				for i,p in sgs.list(room:getAlivePlayers())do
					if p:getHandcardNum()>0 then to:append(p) end
				end
				if to:isEmpty() then return end
				to = room:askForPlayerChosen(player,to,self:objectName(),"ov_huiyuan0:",true,true)
				if not to then return end
				local id = room:askForCardChosen(player,to,"h","ov_huiyuan")
				if id<0 then return end
				room:showCard(to,id)
				id = sgs.Sanguosha:getCard(id)
				if id:getType()==use.card:getType()
				then room:obtainCard(player,id)
				else
					room:throwCard(id,to,player)
					to:drawCards(1,"ov_huiyuan")
				end
				if player:inMyAttackRange(to)
				and not to:inMyAttackRange(player)
				then
					Skill_msg("ov_youji",player)
					room:damage(sgs.DamageStruct("ov_huiyuan",player,to))
				end
			end
		end
		return false
	end
}
ov_gongsunfan:addSkill(ov_huiyuan)
ov_shoushou = sgs.CreateTriggerSkill{
	name = "ov_shoushou",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardsMoveOneTime,sgs.Damage,sgs.Damaged},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardsMoveOneTime
		then
	    	local move = data:toMoveOneTime()
			if move.to_place==sgs.Player_PlaceHand
			and move.to:objectName()==player:objectName()
			and move.from and move.from:objectName()~=player:objectName()
			then
				if move.from_places:contains(sgs.Player_PlaceEquip)
				or move.from_places:contains(sgs.Player_PlaceHand)
				then
					for i,p in sgs.list(room:getAlivePlayers())do
						if p:inMyAttackRange(player)
						then
							Skill_msg(self,player)
							room:addPlayerMark(player,"ov_shoushou1")
							break
						end
					end
				end
			end
		else
			for i,p in sgs.list(room:getOtherPlayers(player))do
				if p:inMyAttackRange(player) then continue end
				Skill_msg(self,player)
				room:addPlayerMark(player,"ov_shoushou2")
				break
			end
		end
		return false
	end
}
ov_gongsunfan:addSkill(ov_shoushou)
ov_shoushoubf = sgs.CreateDistanceSkill{
	name = "#ov_shoushoubf",
	correct_func = function(self,from,to)
		if to and to:hasSkill("ov_shoushou")
		then return to:getMark("ov_shoushou1")-to:getMark("ov_shoushou2") end
	end
}
ov_gongsunfan:addSkill(ov_shoushoubf)
extension:insertRelatedSkills("ov_shoushou", "#ov_shoushoubf")

ov_yangang = sgs.General(extension,"ov_yangang","qun")
ov_zhiqu = sgs.CreateTriggerSkill{
	name = "ov_zhiqu",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Finish
		then
			local to = room:askForPlayerChosen(player,room:getOtherPlayers(player),self:objectName(),"ov_zhiqu0:",true,true)
			if not to then return end
			local n = 0
			for i,p in sgs.list(room:getAlivePlayers())do
				if player:distanceTo(p)<2
				then n = n+1 end
			end
			n = room:getNCards(n)
			room:returnToTopDrawPile(n)
			local can = player:inMyAttackRange(to) and to:inMyAttackRange(player)
			if can then Skill_msg("ov_boji",player) end
			local cs = sgs.CardList()
			for c,id in sgs.list(n)do
				c = sgs.Sanguosha:getCard(id)
				if c:isKindOf("Slash")
				or can and c:isKindOf("TrickCard")
				then cs:append(c) end
			end
			room:addPlayerMark(to,"ov_zhiqubf")
			while cs:length()>0 do
				n = cs:at(0)
				room:setCardFlag(n,"ov_zhiqubf")
				if to:isAlive() and player:canUse(n,to,true)
				then
					if n:targetFixed()
					then room:useCard(sgs.CardUseStruct(n,player,sgs.SPlayerList()))
					else room:useCard(sgs.CardUseStruct(n,player,to)) end
				else room:throwCard(n,nil) end
				room:setCardFlag(n,"-ov_zhiqubf")
				cs:removeOne(n)
			end
			room:removePlayerMark(to,"ov_zhiqubf")
		end
		return false
	end
}
ov_yangang:addSkill(ov_zhiqu)
ov_zhiqubf = sgs.CreateProhibitSkill{
	name = "#ov_zhiqubf",
	is_prohibited = function(self,from,to,card)
		if card:hasFlag("ov_zhiqubf") and to
		and not to:hasSkill("ov_zhiqu")
		and to:getMark("ov_zhiqubf")<1
		then return true end
	end
}
ov_yangang:addSkill(ov_zhiqubf)
extension:insertRelatedSkills("ov_zhiqu", "#ov_zhiqubf")
ov_xianfeng = sgs.CreateTriggerSkill{
	name = "ov_xianfeng",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damage},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Damage
		and player:getPhase()==sgs.Player_Play
		then
	    	local damage = data:toDamage()
			if damage.to:objectName()~=player:objectName()
			and damage.card and damage.card:getTypeId()>0
			then
				Skill_msg(self,player)
				local choice = "ov_xianfeng1="..player:objectName().."+ov_xianfeng2="..player:objectName()
				choice = room:askForChoice(damage.to,"ov_xianfeng",choice,ToData(player))
				if choice=="ov_xianfeng1="..player:objectName()
				then
					damage.to:drawCards(1,"ov_xianfeng")
					room:addPlayerMark(player,"ov_xianfeng1")
				else
					player:drawCards(1,"ov_xianfeng")
					room:addPlayerMark(damage.to,"ov_xianfeng2"..player:objectName())
				end
			end
		end
		return false
	end
}
ov_xianfengbf = sgs.CreateDistanceSkill{
	name = "#ov_xianfengbf",
	correct_func = function(self,from,to)
		local n = 0
		if from:getMark("ov_xianfeng1")>0
		then n = n-from:getMark("ov_xianfeng1") end
		if to and from:getMark("ov_xianfeng2"..to:objectName())>0
		then n = n-from:getMark("ov_xianfeng2"..to:objectName()) end
		return n
	end
}
ov_yangang:addSkill(ov_xianfeng)
ov_yangang:addSkill(ov_xianfengbf)
extension:insertRelatedSkills("ov_xianfeng", "#ov_xianfengbf")
ov_xianfengbf1 = sgs.CreateTriggerSkill{
	name = "#ov_xianfengbf1",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.from==sgs.Player_NotActive
			then
				room:setPlayerMark(player,"ov_xianfeng1",0)
				for i,p in sgs.list(room:getAlivePlayers())do
					room:setPlayerMark(p,"ov_xianfeng2"..player:objectName(),0)
				end
			end
		end
		return false
	end
}
ov_yangang:addSkill(ov_xianfengbf1)
extension:insertRelatedSkills("ov_xianfeng", "#ov_xianfengbf1")

ov_zhangzhao = sgs.General(extension,"ov_zhangzhao","wu")
ov_lijianCard = sgs.CreateSkillCard{
	name = "ov_lijianCard",
	handling_method = sgs.Card_MethodNone,
	will_throw = false,
	target_fixed = true,
	on_use = function(self,room,source,targets)
		room:obtainCard(source,self)
	end
}
ov_lijianvs = sgs.CreateViewAsSkill{
	name = "ov_lijian",
	n = 998,
	expand_pile = "#ov_lijian",
	response_pattern = "@@ov_lijian",
	view_filter = function(self,selected,to_select)
		return sgs.Self:getPileName(to_select:getEffectiveId())=="#ov_lijian"
	end,
	view_as = function(self,cards)
		local card = ov_lijianCard:clone()
		for _,c in sgs.list(cards)do
			card:addSubcard(c)
		end
		return #cards>0 and card
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
ov_lijian = sgs.CreateTriggerSkill{
	name = "ov_lijian",
	view_as_skill = ov_lijianvs,
	events = {sgs.EventPhaseEnd,sgs.CardsMoveOneTime},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName("ov_lijian")
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseEnd
		and player:getPhase()==sgs.Player_Discard
		then
			for _,owner in sgs.list(room:findPlayersBySkillName("ov_lijian"))do
				local ids = sgs.IntList()
				for _,id in sgs.list(room:getTag("ov_lijian"):toIntList())do
					if room:getCardPlace(id)==sgs.Player_DiscardPile
					then ids:append(id) end
				end
				if ids:isEmpty() or owner==player
				or owner:getMark("ov_lijianUse")>0
				then continue end
				room:fillAG(ids,owner)
				local can = ToSkillInvoke(self,owner,player)
				room:clearAG(owner)
				if can
				then
					room:addPlayerMark(owner,"ov_lijianUse")
					room:notifyMoveToPile(owner,ids,"ov_lijian",sgs.Player_DiscardPile,true)
					can = room:askForUseCard(owner,"@@ov_lijian","ov_lijian0:"..player:objectName())
					room:notifyMoveToPile(owner,ids,"ov_lijian",sgs.Player_DiscardPile,false)
					if can
					then
						for _,id in sgs.list(can:getSubcards())do
							ids:removeOne(id)
						end
						can = can:subcardsLength()
					else
						can = 0
					end
					if ids:length()>0
					then
						room:giveCard(owner,player,ids,"ov_lijian")
					end
					if ids:length()>can
					and owner:askForSkillInvoke("ov_lijian_damage",ToData("ov_lijian_damage:"..player:objectName()))
					then
						room:damage(sgs.DamageStruct("ov_lijian",owner,player))
					end
				end
			end
			room:removeTag("ov_lijian")
		elseif event==sgs.CardsMoveOneTime
		then
			local move = data:toMoveOneTime()
			if move.to_place==sgs.Player_DiscardPile
			and player:getMark("ov_lijianUse")>0
			and player:hasSkill(self)
			then
				room:addPlayerMark(player,"&ov_lijian+-+angyang",move.card_ids:length())
				if player:getMark("&ov_lijian+-+angyang")>=8
				then
					room:setPlayerMark(player,"ov_lijianUse",0)
					room:setPlayerMark(player,"&ov_lijian+-+angyang",0)
				end
			end
			if bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON)==sgs.CardMoveReason_S_REASON_DISCARD
			and player:getPhase()==sgs.Player_Discard
			then
				local ids = room:getTag("ov_lijian"):toIntList()
				InsertList(ids,move.card_ids)
				room:setTag("ov_lijian",ToData(ids))
			end
		end
		return false
	end
}
ov_zhangzhao:addSkill(ov_lijian)
ov_chungang = sgs.CreateTriggerSkill{
	name = "ov_chungang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardsMoveOneTime
		then
			local move = data:toMoveOneTime()
			if move.to_place==sgs.Player_PlaceHand
			and move.to:getPhase()~=sgs.Player_Draw
			and not room:getTag("FirstRound"):toBool()
			and move.card_ids:length()>1
			then
				if move.to:objectName()~=player:objectName()
				then
					room:sendCompulsoryTriggerLog(player,"ov_chungang")
					room:askForDiscard(BeMan(room,move.to),"ov_chungang",1,1,false,true,"ov_chungang0:")
				end
			end
		end
		return false
	end
}
ov_zhangzhao:addSkill(ov_chungang)

ov_zhanggong = sgs.General(extension,"ov_zhanggong","wu")
ov_quanqianCard = sgs.CreateSkillCard{
	name = "ov_quanqianCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self,targets,to_select,from)
		return #targets<1 and to_select:objectName()~=from:objectName()
	end,
	on_use = function(self,room,source,targets)
		room:addPlayerMark(source,"ov_quanqianUse")
		room:giveCard(source,targets[1],self,"ov_quanqian")
		if self:subcardsLength()>1
		then
			for _,c in sgs.list(PatternsCard("EquipCard",true))do
				if room:getCardPlace(c:getEffectiveId())==sgs.Player_DrawPile
				then source:obtainCard(c) break end
			end
			local choice = room:askForChoice(source,"ov_quanqian","ov_quanqian1+ov_quanqian2",ToData(targets[1]))
			if choice=="ov_quanqian1"
			then
				choice = targets[1]:getHandcardNum()-source:getHandcardNum()
				if choice>0
				then
					source:drawCards(choice,"ov_quanqian")
				end
			else
				self:clearSubcards()
				room:doGongxin(source,targets[1],targets[1]:handCards(),"ov_quanqian")
				choice = room:askForSuit(source,"ov_quanqian")
				for _,c in sgs.list(targets[1]:getHandcards())do
					if c:getSuit()==choice then self:addSubcard(c) end
				end
				if self:subcardsLength()>0
				then
					source:obtainCard(self,false)
				end
			end
		end
	end
}
ov_quanqianvs = sgs.CreateViewAsSkill{
	name = "ov_quanqian",
	n = 998,
	view_filter = function(self,selected,to_select)
		for _,c in sgs.list(selected)do
			if c:getSuit()==to_select:getSuit()
			then return end
		end
		return not to_select:isEquipped()
		and #selected<4
	end,
	view_as = function(self,cards)
		local card = ov_quanqianCard:clone()
		for _,c in sgs.list(cards)do
			card:addSubcard(c)
		end
		return #cards>0 and card
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_quanqianCard")<1
		and player:getMark("ov_quanqianUse")<1
	end,
}
ov_quanqian = sgs.CreateTriggerSkill{
	name = "ov_quanqian",
	view_as_skill = ov_quanqianvs,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardsMoveOneTime
		then
			local move = data:toMoveOneTime()
			if bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD
			and move.from and player:objectName()==move.from:objectName() and player:getMark("ov_quanqianUse")>0
			then
				local n = 0
				for _,p in sgs.list(move.from_places)do
					if p==sgs.Player_PlaceHand
					then n = n + 1 end
				end
				room:addPlayerMark(player,"&ov_quanqian+-+angyang",n)
				if player:getMark("&ov_quanqian+-+angyang")>=6
				then
					room:setPlayerMark(player,"ov_quanqianUse",0)
					room:setPlayerMark(player,"&ov_quanqian+-+angyang",0)
				end
			end
		end
		return false
	end
}
ov_zhanggong:addSkill(ov_quanqian)
ov_rouke = sgs.CreateTriggerSkill{
	name = "ov_rouke",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardsMoveOneTime
		then
			local move = data:toMoveOneTime()
			if move.to_place==sgs.Player_PlaceHand
			and move.to:objectName()==player:objectName()
			and not room:getTag("FirstRound"):toBool()
			and player:getPhase()~=sgs.Player_Draw
			and move.card_ids:length()>1
			then
				room:sendCompulsoryTriggerLog(player,"ov_rouke")
				player:drawCards(1,"ov_rouke")
			end
		end
		return false
	end
}
ov_zhanggong:addSkill(ov_rouke)

ov_liubei = sgs.General(extension,"ov_liubei","shu")
ov_shenyi = sgs.CreateTriggerSkill{
	name = "ov_shenyi",
	--frequency = sgs.Skill_Frequent,
	events = {sgs.Damage},
	can_trigger = function(self,target)
		return target and target:isAlive()
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Damage
		then
	    	local damage = data:toDamage()
			for _,owner in sgs.list(room:findPlayersBySkillName("ov_shenyi"))do
				if (damage.to==owner or owner:inMyAttackRange(damage.to))
				and damage.from and damage.from~=damage.to and damage.from~=owner
				and damage.to:getMark(owner:objectName().."ov_shenyiDamage-Clear")<1
				and damage.to:isAlive()
				then
					local names = {}
					for _,n in sgs.list(AllCardPatterns())do
						if owner:getMark("ov_shenyi"..n)<1
						then table.insert(names,n) end
					end
					damage.to:addMark(owner:objectName().."ov_shenyiDamage-Clear")
					if #names<1 or owner:getMark("ov_shenyi-Clear")>0 then continue end
					if ToSkillInvoke(self,owner,damage.to)
					then
						owner:addMark("ov_shenyi-Clear")
						names = room:askForChoice(owner,"ov_shenyi",table.concat(names,"+"))
						owner:addMark("ov_shenyi"..names)
						for _,id in sgs.list(room:getDrawPile())do
							local c = sgs.Sanguosha:getCard(id)
							if c:objectName()==names
							then
								owner:addToPile("ov_xiayi",c)
								break
							end
						end
						if damage.to~=owner
						and owner:getHandcardNum()>0
						then
							damage.to:setTag(owner:objectName().."ov_shenyiCids",ToData(owner:handCards()))
							room:giveCard(owner,damage.to,owner:handCards(),"ov_shenyi")
						end
					end
				end
			end
		end
		return false
	end
}
ov_shenyibf = sgs.CreateTriggerSkill{
	name = "#ov_shenyibf",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardsMoveOneTime
		then
			local move = data:toMoveOneTime()
			if move.from_places:contains(sgs.Player_PlaceHand)
			and (move.to~=move.from or move.to_place~=sgs.Player_PlaceEquip)
			then
				local from = BeMan(room,move.from)
				for _,owner in sgs.list(room:findPlayersBySkillName("ov_shenyi"))do
					local ids = from:getTag(owner:objectName().."ov_shenyiCids"):toIntList()
					if ids:isEmpty() then continue end
					local n = 0
					for i,id in sgs.list(move.card_ids)do
						if move.from_places:at(i)==sgs.Player_PlaceHand
						and ids:contains(id)
						then
							n = n+1
							ids:removeOne(id)
						end
					end
					if n<1 then continue end
					from:setTag(owner:objectName().."ov_shenyiCids",ToData(ids))
					Skill_msg("ov_shenyi",owner)
					owner:drawCards(n,"ov_shenyi")
				end
			end
			if move.from_places:contains(sgs.Player_PlaceEquip)
			and (move.to~=move.from or move.to_place~=sgs.Player_PlaceHand)
			then
				local from = BeMan(room,move.from)
				for _,owner in sgs.list(room:findPlayersBySkillName("ov_shenyi"))do
					local ids = from:getTag(owner:objectName().."ov_shenyiCids"):toIntList()
					if ids:isEmpty() then continue end
					local n = 0
					for i,id in sgs.list(move.card_ids)do
						if move.from_places:at(i)==sgs.Player_PlaceEquip
						and ids:contains(id)
						then
							n = n+1
							ids:removeOne(id)
						end
					end
					if n<1 then continue end
					from:setTag(owner:objectName().."ov_shenyiCids",ToData(ids))
					Skill_msg("ov_shenyi",owner)
					owner:drawCards(n,"ov_shenyi")
				end
			end
		end
		return false
	end
}
ov_liubei:addSkill(ov_shenyi)
ov_liubei:addSkill(ov_shenyibf)
extension:insertRelatedSkills("ov_shenyi", "#ov_shenyibf")
ov_xinghanTrVS = sgs.CreateViewAsSkill{
	name = "ov_xinghan",
	n = 1,
	expand_pile = "ov_xiayi",
	view_filter = function(self,selected,to_select)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if string.find(pattern,"@@ov_xinghan")
		then
			return sgs.Self:getPile("ov_xiayi"):at(0)==to_select:getId()
			and to_select:isAvailable(sgs.Self)
		end
		return sgs.Self:getPile("ov_xiayi"):contains(to_select:getId())
		and not sgs.Self:isCardLimited(to_select,to_select:getHandlingMethod())
	end,
	view_as = function(self,cards)
	   	if #cards<1 then return end
		return cards[1]
	end,
	enabled_at_response = function(self,player,pattern)
		for _,n in sgs.list(pattern:split("+"))do
			for _,id in sgs.list(player:getPile("ov_xiayi"))do
				local c = sgs.Sanguosha:getCard(id)
				if string.find(c:objectName(),n)
				and (player:isKongcheng() or player:hasFlag("Global_Dying"))
				then return true end
			end
		end
		return string.find(pattern,"@@ov_xinghan")
	end,
	enabled_at_play = function(self,player)
	   	if player:getPile("ov_xiayi"):isEmpty() then return end
		return player:isKongcheng() or player:hasFlag("Global_Dying")
	end,
}
ov_xinghan = sgs.CreateTriggerSkill{
	name = "ov_xinghan",
	view_as_skill = ov_xinghanTrVS,
	events = {sgs.EventPhaseProceeding,sgs.EventPhaseChanging},
	on_trigger = function(self,event,player,data,room)
   		if event==sgs.EventPhaseProceeding
	   	then
	       	if player:getPhase()~=sgs.Player_Start
			or player:getPile("ov_xiayi"):length()<=player:aliveCount() then return end
	        while player:getPile("ov_xiayi"):length()>0 and room:askForUseCard(player,"@@ov_xinghan","ov_xinghan0:") do
				player:addMark("ov_xinghan-Clear")
			end
		elseif event==sgs.EventPhaseChanging
	   	then
	     	local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			and player:getMark("ov_xinghan-Clear")>0
			then
				Skill_msg(self,player)
				player:throwAllHandCards("ov_xinghan")
				room:loseHp(player,math.max(1,player:getHp()-1),false,player,"ov_xinghan")
			end
		end
	end
}
ov_liubei:addSkill(ov_xinghan)

ov_xiahouzie2 = sgs.General(extension,"ov_xiahouzie2","qun",3,false)
ov_chengxiCard = sgs.CreateSkillCard{
	name = "ov_chengxiCard",
	handling_method = sgs.Card_MethodNone,
	will_throw = false,
	target_fixed = true,
	on_use = function(self,room,source,targets)
		local tos = sgs.SPlayerList()
		source:drawCards(1,"ov_chengxi")
		for _,p in sgs.list(room:getOtherPlayers(source))do
			if source:canPindian(p)
			and source:getMark(p:objectName().."ov_chengxi-PlayClear")<1
			then tos:append(p) end
		end
		tos = room:askForPlayerChosen(source,tos,"ov_chengxi","ov_chengxi0:")
		room:doAnimate(1,source:objectName(),tos:objectName())
		room:addPlayerMark(source,tos:objectName().."ov_chengxi-PlayClear")
		if source:pindian(tos,"ov_chengxi")
		then
			room:addPlayerMark(source,"&ov_chengxi")
		else
			local d = dummyCard()
			d:setSkillName("_ov_chengxi")
			if tos:canSlash(source,d,false)
			then
				room:useCard(sgs.CardUseStruct(d,tos,source))
			end
		end
	end
}
ov_chengxivs = sgs.CreateViewAsSkill{
	name = "ov_chengxi",
	n = 0,
	view_as = function(self,cards)
		return ov_chengxiCard:clone()
	end,
	enabled_at_play = function(self,player)
		for _,p in sgs.list(player:getAliveSiblings())do
			if player:canPindian(p)
			and player:getMark(p:objectName().."ov_chengxi-PlayClear")<1
			then return true end
		end
		return false
	end,
}
ov_chengxi = sgs.CreateTriggerSkill{
	name = "ov_chengxi",
	view_as_skill = ov_chengxivs,
	events = {sgs.CardFinished},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardFinished
		then
			local use = data:toCardUse()
			local n = player:getMark("&ov_chengxi")
			if (use.card:getTypeId()==1 or use.card:isNDTrick())
			and n>0
			then
				room:setPlayerMark(player,"&ov_chengxi",0)
				Skill_msg(self,player)
				for i=1,n do
					local d = dummyCard(use.card:objectName())
					d:setSkillName("_ov_chengxi")
					room:useCard(sgs.CardUseStruct(d,player,use.to))
				end
			end
		end
		return false
	end
}
ov_xiahouzie2:addSkill(ov_chengxi)

ov_zhangwei = sgs.General(extension,"ov_zhangwei","qun",3,false)
ov_huzhong = sgs.CreateTriggerSkill{
	name = "ov_huzhong",
	events = {sgs.TargetSpecifying},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.TargetSpecifying
		and player:getPhase()==sgs.Player_Play
		then
			local use = data:toCardUse()
			if use.card:objectName()=="slash"
			and use.to:at(0)~=player
			and use.to:length()==1
			then
				if player:isKongcheng() and use.to:at(0):isKongcheng() then return end
				if ToSkillInvoke(self,player,use.to:at(0))
				then
					if player:getHandcardNum()>0
					and room:askForCard(player,".","ov_huzhong0:"..use.to:at(0):objectName(),data)
					then
						local tos = room:getCardTargets(player,use.card,use.to)
						if tos:isEmpty() then return end
						tos = PlayerChosen(self,player,tos,"ov_huzhong1:")
						use.to:append(tos)
						room:sortByActionOrder(use.to)
						data:setValue(use)
					else
						room:askForDiscard(use.to:at(0),"ov_huzhong",1,1)
						room:setCardFlag(use.card,"ov_huzhongbf")
					end
				end
			end
		end
		return false
	end
}
ov_zhangwei:addSkill(ov_huzhong)
ov_huzhongbf = sgs.CreateTriggerSkill{
	name = "#ov_huzhongbf",
	events = {sgs.CardFinished,sgs.Damage},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if use.card:hasFlag("ov_huzhongbf")
			then
				room:setCardFlag(use.card,"-ov_huzhongbf")
				Skill_msg("ov_huzhong",player)
				if use.card:hasFlag("ov_huzhongbfDamage")
				then
					room:setCardFlag(use.card,"-ov_huzhongbfDamage")
					player:drawCards(1,"ov_huzhong")
					room:addSlashCishu(player,1)
				else
					room:damage(sgs.DamageStruct("ov_huzhong",use.to:at(0),player))
				end
			end
		elseif event==sgs.Damage
		then
		    local damage = data:toDamage()
			if damage.card and damage.card:hasFlag("ov_huzhongbf")
			then
				room:setCardFlag(damage.card,"ov_huzhongbfDamage")
			end
		end
		return false
	end
}
ov_zhangwei:addSkill(ov_huzhongbf)
extension:insertRelatedSkills("ov_huzhong", "#ov_huzhongbf")
ov_fenwang = sgs.CreateTriggerSkill{
	name = "ov_fenwang",
	events = {sgs.DamageInflicted,sgs.DamageCaused},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.DamageInflicted
		then
		    local damage = data:toDamage()
			if damage.nature~=sgs.DamageStruct_Normal
			then
				Skill_msg(self,player)
				if player:getHandcardNum()>0
				and room:askForCard(player,".","ov_fenwang0:",data)
				then else DamageRevises(data,1,player)  end
			end
		elseif event==sgs.DamageCaused
		then
		    local damage = data:toDamage()
			if damage.nature==sgs.DamageStruct_Normal
			and damage.to:getHandcardNum()<player:getHandcardNum()
			then
				Skill_msg(self,player)
				DamageRevises(data,1,player)
			end
		end
		return false
	end
}
ov_zhangwei:addSkill(ov_fenwang)

ov_xiahoudun = sgs.General(extension,"ov_xiahoudun","qun")
ov_danlieCard = sgs.CreateSkillCard{
	name = "ov_danlieCard",
	will_throw = false,
	handling_method = sgs.Card_MethodPindian,
	filter = function(self,targets,to_select,from)
		return #targets<3 and from:canPindian(to_select)
		and to_select:objectName()~=from:objectName()
	end,
	on_use = function(self,room,source,targets)
		local pd = targetsPindian("ov_danlie",source,targets)
		if pd and pd.success_owner==source
		then
			for _,p in sgs.list(targets)do
				room:damage(sgs.DamageStruct("ov_danlie",source,p))
			end
		else
			room:loseHp(source,1,false,source,"ov_danlie")
		end
	end
}
ov_danlievs = sgs.CreateViewAsSkill{
	name = "ov_danlie",
	n = 0,
	view_as = function(self,cards)
		return ov_danlieCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#ov_danlieCard")<1
	end,
}
ov_danlie = sgs.CreateTriggerSkill{
	name = "ov_danlie",
	view_as_skill = ov_danlievs,
	events = {sgs.PindianVerifying},
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:getRoom():findPlayerBySkillName("ov_danlie")
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.PindianVerifying
		then
			local pindian = data:toPindian()
			for i,owner in sgs.list(room:findPlayersBySkillName("ov_danlie"))do
				i = owner:getLostHp()
				if i<1 then continue end
				if pindian.from==owner
				then
					Skill_msg("ov_danlie",owner)
					pindian.from_number = pindian.from_number+i
					if pindian.from_number>13 then pindian.from_number=13 end
					Log_message("$ov_niju10",pindian.from,nil,pindian.from_card:getEffectiveId(),"+"..i,pindian.from_number)
					data:setValue(pindian)
				elseif pindian.to==owner
				then
					Skill_msg("ov_danlie",owner)
					pindian.to_number = pindian.to_number+i
					if pindian.to_number>13 then pindian.to_number=13 end
					Log_message("$ov_niju10",pindian.to,nil,pindian.to_card:getEffectiveId(),"+"..i,pindian.to_number)
					data:setValue(pindian)
				end
			end
		end
		return false
	end
}
ov_xiahoudun:addSkill(ov_danlie)















ov_on_trigger = sgs.CreateTriggerSkill{
	name = "ov_on_trigger",
	events = {sgs.EventPhaseChanging},
	frequency = sgs.Skill_Compulsory,
	global = true,
	can_trigger = function(self,target)
		if table.contains(sgs.Sanguosha:getBanPackages(),"OverseasVersion")
		then else return target and target:isAlive() end
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
        then
	     	local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive then end
	       	for i,c in sgs.list(player:getHandcards())do
		   		if c:isKindOf("Mantianguohai")
				then room:ignoreCards(player,c) end
	    	end
		end
		return false
	end,
}
addToSkills(ov_on_trigger)

sgs.LoadTranslationTable{
	["OverseasVersion"] = "海外服",
	["ov_zhangzhao"] = "张昭",
	["#ov_zhangzhao"] = "功劝克举",
	["ov_lijian"] = "力谏",
	[":ov_lijian"] = "<b>昂扬技，</b>其他角色弃牌阶段结束时，你可以选择获得任意张此阶段弃置的牌，然后将其余牌交给该角色，若其获得的牌数大于你，则你可以对其造成1点伤害。<b>激昂</b>：八张牌进入弃牌堆。",
	["ov_lijian_damage:ov_lijian_damage"] = "力谏：你可以对%src造成1点伤害",
	["#ov_lijian"] = "弃牌堆",
	["ov_lijian0"] = "力谏：你可以选择获得任意张此阶段弃置的牌",
	["ov_chungang"] = "纯刚",
	[":ov_chungang"] = "锁定技，其他角色在摸牌阶段外一次性获得不小于两张牌时，你令其弃置一张牌。",
	["ov_zhanggong"] = "张肱",
	["#ov_zhanggong"] = "为世令器",
	["ov_quanqian"] = "劝迁",
	[":ov_quanqian"] = "<b>昂扬技，</b>出牌阶段限一次，你可以将至多四张花色不同的手牌交给一名其他角色，若给出的牌数不小于2，则你从牌堆中随机获得一张装备牌，然后你选择一项：1.将手牌摸至与其相同；2.观看其手牌并选择一种花色，然后获得其手牌中所有此花色的牌。<b>激昂</b>：你弃置六张手牌。",
	["ov_quanqian1"] = "将手牌摸至与其相同",
	["ov_quanqian2"] = "观看其手牌并选择一种花色",
	["ov_rouke"] = "柔克",
	[":ov_rouke"] = "锁定技，当你于摸牌阶段外一次性获得不小于两张牌时，你摸一张牌。",
	["ov_zhaoxiang"] = "赵襄",
	["ov_queshi"] = "鹊拾",
	[":ov_queshi"] = "游戏开始时，你将【银月枪】置入你的装备区；当你发动“扶汉”后，你从游戏外、场上、牌堆或弃牌堆中获得【银月枪】。",
	["ov_erqiao"] = "大乔小乔",
	["ov_xingwu"] = "星舞",
	[":ov_xingwu"] = "弃牌阶段开始时，你可以将一张牌置于武将牌上，然后你可以将三张“星舞”牌置入弃牌堆并选择一名角色，弃置其装备区所有牌，然后若其为男/非男性角色，你对其造成2/1点伤害。",
	["ov_xingwu0"] = "星舞：你可以将一张牌置于武将牌上",
	["ov_xingwu1"] = "星舞：你可以将三张“星舞牌”置入弃牌堆并选择一名角色",
	["ov_pingting"] = "娉婷",
	[":ov_pingting"] = "锁定技，每轮开始时或当其他角色于你回合内进入濒死状态时，你摸一张牌，然后将一张牌置于武将牌上（称为“星舞”）。若你拥有“星舞”牌，你视为拥有“天香”和“流离”。",
	["ov_pingting0"] = "娉婷：请将一张牌置于武将牌上",
	["angyang"] = "昂扬",
	["ov_liubei"] = "侠刘备",
	["#ov_liubei"] = "为国为民",
	["ov_shenyi"] = "伸义",
	[":ov_shenyi"] = "每回合限一次，你或你攻击范围内的角色本回合第一次受到其他角色的伤害后，你可以声明一种基本牌或锦囊牌的牌名（每种牌名限一次），然后从牌堆中将一张同名牌置于武将牌上，称为“侠义”；若受到伤害的角色不为你，你将所有手牌交给其，当其失去一张交给其的牌时，你摸一张牌。",
	["ov_xinghan"] = "兴汉",
	[":ov_xinghan"] = "当你没有手牌且需要使用或打出手牌或处于濒死状态时，你可以使用或打出“侠义”牌。准备阶段，若“侠义”牌数大于存活角色数，你可以依次使用“侠义”牌，若如此做，回合结束时，你弃置所有手牌并失去X点体力（X为你的体力值-1且至少为1）。",
	["ov_xinghan0"] = "兴汉：你可以使用“侠义”牌",
	["ov_xiayi"] = "侠义",
	["ov_xiahouzie2"] = "夏侯子萼",
	["#ov_xiahouzie2"] = "承继婆娑",
	["ov_chengxi"] = "承袭",
	[":ov_chengxi"] = "出牌阶段每名角色限一次，你可以摸一张牌，然后与一名其他角色拼点：若你赢，你使用的下一张基本牌或非延时锦囊牌结算后，你视为对相同目标使用一张同名牌；若你没赢，其视为对你使用一张【杀】。",
	["ov_chengxi0"] = "承袭：请选择一名其他角色拼点",
	["ov_zhangwei"] = "张葳",
	["#ov_zhangwei"] = "血骑教习",
	["ov_huzhong"] = "护众",
	[":ov_huzhong"] = "出牌阶段，你使用普通【杀】指定其他角色为唯一目标时，你可以选择一项：1.弃置一张手牌，此【杀】可额外选择一个目标；2.其弃置一张手牌，若此杀造成伤害，你摸一张牌且本阶段出【杀】次数+1，未造成伤害，其对你造成1点伤害。",
	["ov_huzhong0"] = "护众：你可以弃置一张手牌或令%src弃置一张手牌",
	["ov_huzhong1"] = "护众：请选择此【杀】一个额外目标",
	["ov_fenwang"] = "焚亡",
	[":ov_fenwang"] = "你受到属性伤害时，需弃置一张手牌，否则此伤害+1。你对其他角色造成普通伤害时，若你的手牌数大于其，此伤害+1。",
	["ov_fenwang0"] = "焚亡：你需弃置一张手牌，否则此伤害+1",
	["ov_xiahoudun"] = "侠夏侯惇",
	["#ov_xiahoudun"] = "刚烈勇猛",
	["ov_danlie"] = "胆烈",
	[":ov_danlie"] = "出牌阶段限一次，你可以与至多3名其他角色同时拼点；若你赢，你对没赢的角色造成1点伤害；若你没赢，你失去1点体力。你的拼点牌点数+X（X为你已损失的体力值）。",
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
	["ov_bianfuren"] = "卞夫人",
	["#ov_bianfuren"] = "奕世之雍容",
	["ov_wanwei"] = "挽危",
	[":ov_wanwei"] = "每回合限一次。当体力值最少的角色受到伤害时：1、若之不为你，你可以失去1点体力并防止此伤害；2、若之为你或你的体力上限全场最高，你可以于此回合结束时获得牌堆顶牌并展示牌堆底牌（若此牌可使用，你使用之）。",
	["ov_wanweibf0"] = "挽危：你可以使用此【%src】",
	["ov_yuejian"] = "约俭",
	[":ov_yuejian"] = "出牌阶段限一次，你可以将至多X张牌置于牌堆顶或底（X为你手牌数高于手牌上限的值且至少为1）；因此失去的牌数不小于：1、你手牌上限+1，2、你回复1点体力，3、你增加1点体力上限。",
	["ov_chenzhen"] = "陈震",
	["#ov_chenzhen"] = "睦约使节",
	["ov_muyue"] = "睦约",
	[":ov_muyue"] = "出牌阶段限一次。你可以弃置一张牌并声明一种基本牌或普通锦囊牌，然后令一名角色从牌堆中获得一张此牌名的牌。若你弃置的牌与此牌名相同，你下一次发动此技能无需弃牌。",
	["ov_muyue0"] = "睦约：请选择一名角色获得牌",
	["ov_chayi"] = "察异",
	[":ov_chayi"] = "结束阶段，你可以令一名其他角色选择一项：1、展示手牌，2、下一次使用牌时弃置一张牌。其下回合开始时，若其手牌数与你选择其时不同，其执行另一项",
	["ov_chayi0"] = "察异：你可以选择一名其他角色",
	["ov_chayi1"] = "展示手牌",
	["ov_chayi2"] = "下一次使用牌时弃置一张牌",
	["$ov_chayiHN"] = "%from 选择了 %arg",
	["#ov_muyueCard"] = "%from 声明了【%arg】",
	["ov_sunshao"] = "孙邵",
--	["#ov_sunshao"] = "  ",
	["ov_dingyi"] = "定仪",
	[":ov_dingyi"] = "游戏开始时，你令每名角色获得一项效果：1、摸牌阶段摸牌数+1，2、手牌上限+2，3、攻击范围+1，4、脱离濒死状态时回复1点体力。",
	["$ov_dingyi1"] = "经国序民，还需制礼定仪",
	["$ov_dingyi2"] = "无礼而治世，欲使国泰，安可得哉？",
	["ov_dingyi0"] = "定仪：请选择一名角色获得效果：%src",
	["ov_dingyi1"] = "摸牌数+1",
	["ov_dingyi2"] = "手牌上限+2",
	["ov_dingyi3"] = "攻击范围+1",
	["ov_dingyi4"] = "脱死回复",
	["ov_zuici"] = "罪辞",
	[":ov_zuici"] = "当你受到伤害后，你可以令来源失去“定仪”效果，然后其获得一张你指定的智囊。",
	["ov_fubi"] = "辅弼",
	[":ov_fubi"] = "每轮限一次，出牌阶段，你可以选择一名角色并选择一项：1、更换其“定仪”效果，2、你弃置一张牌并令其“定仪”效果数值翻倍，直到你下回合开始。",
	["ov_gongsunfan"] = "公孙范",
	["#ov_gongsunfan"] = "助瓒讨袁",
	["ov_huiyuan"] = "回援",
	[":ov_huiyuan"] = "当你于出牌阶段使用牌结算后，若你此阶段未获得过此牌类型的牌，你可以展示一名角色的一张手牌，若与之类型相同，你获得展示的牌，否则你弃置展示牌并令其摸一张牌。<br />游击：对其造成1点伤害。",
	["ov_huiyuan0"] = "回援：你可以选择一名角色展示其一张手牌",
	["ov_shoushou"] = "收绶",
	[":ov_shoushou"] = "当你获得其他角色的牌后，若你处于任意角色的攻击范围内，其他角色计算与你的距离+1；当你造成或受到伤害后，若你不处于任意角色的攻击范围内，其他角色计算与你的距离-1。",
	["ov_yangang"] = "严纲",
	["#ov_yangang"] = "马下败将",
	["ov_zhiqu"] = "直取",
	[":ov_zhiqu"] = "结束阶段，你可以选择一名其他角色，依次对其使用牌堆顶X张牌中的【杀】（X为你距离1以内的角色数）。<br />搏击：依次使用其中的锦囊牌，这些牌只能指定你或其为目标。",
	["ov_zhiqu0"] = "直取：你可以选择一名其他角色",
	["ov_xianfeng"] = "先锋",
	[":ov_xianfeng"] = "当你于出牌阶段内使用牌对其他角色造成伤害后，你令请选择一项：1.其摸一张牌，你计算与其他角色距离-1直到你下回合开始；2.你摸一张牌，其计算与你距离-1直到你下回合开始。",
	["ov_xianfeng:ov_xianfeng1"] = "你摸一张牌，%src计算与你们距离-1直到其下回合开始",
	["ov_xianfeng:ov_xianfeng2"] = "%src摸一张牌，你计算与其距离-1直到其下回合开始",
	["ov_youji"] = "游击",
	["ov_boji"] = "搏击",
	["ov_lusu"] = "鲁肃",
	["#ov_lusu"] = "性善好施",
	["~ov_lusu"] = "人心不足，巴蛇吞象....",
	["ov_kaizeng"] = "慨赠",
	[":ov_kaizeng"] = "其他角色出牌阶段限一次，其可以声明一种基本牌名或非基本牌类型，然后你可以交给其任意张牌。若你给出多于一张牌，你摸一张牌；若你给出的牌中包含其声明的牌名或类型，你从牌堆中获得一张不同牌名或类型的牌。",
	["ov_kaizeng0"] = "你可以交给%src任意张牌，其声明了 %dest",
	["#ov_kaizeng"] = "%from 声明了 %arg",
	["$ov_kaizeng1"] = "此心唯念天下之士，不较细软锱珠！",
	["$ov_kaizeng2"] = "千金散尽何须虑，但求天下俱欢颜！",
	["ov_kaizengvs"] = "慨赠",
	[":ov_kaizengvs"] = "出牌阶段限一次，你可以声明一种基本牌名或非基本牌类型，然后“慨赠”角色可以交给你任意张牌。",
	["ov_yangming"] = "扬名",
	[":ov_yangming"] = "出牌阶段结束时，你可以摸X张牌并令你本回合手牌上限+X。（X为你此阶段使用牌的类型数）",
	["$ov_yangming1"] = "善名高布凌霄阙，仁德始铸黄金台！",
	["$ov_yangming2"] = "失千金之利，得万人之心！",
	["ov_xiahouzie"] = "夏侯紫萼",
	["#ov_xiahouzie"] = "孤草飘零",
	["~ov_xiahouzie"] = "祖父，紫萼不能为您昭雪了.......",
	["ov_xiechang"] = "血偿",
	[":ov_xiechang"] = "出牌阶段限一次，你可以与一名其他角色拼点：若你赢，你获得其一张牌，若此牌为装备牌，你视为对其使用一张【杀】；若你没赢，其对你造成1点伤害，且你下一次对其造成的伤害+1。",
	["$ov_xiechang1"] = "风尘难掩忠魂血，杀尽宦祸不得偿！",
	["$ov_xiechang2"] = "霜刃绚练，血舞婆娑！",
	["ov_duoren"] = "夺刃",
	[":ov_duoren"] = "当你造成其他角色死亡时，你可以扣减1点体力上限，然后获得其所有非主公技，直到你造成伤害令其他角色陷入濒死状态。",
	["$ov_duoren1"] = "便以汝血，封汝之刀！",
	["$ov_duoren2"] = "血婆娑之剑，从不会沾无辜之血！",
	["ov_zhaoe"] = "赵娥",
	["#ov_zhaoe"] = "烈女誓仇",
	["~ov_zhaoe"] = "乞就刑戮，肃明王法.......",
	["ov_yanshi"] = "言誓",
	[":ov_yanshi"] = "游戏开始时，你选择一名其他角色；当你或其受到其余角色的伤害后，来源获得“誓”标记；你对“誓”角色使用牌无距离限制且造成的伤害+1，造成伤害后摸等同伤害数的牌并移去其“誓”标记。",
	["#ov_zeshi1"] = "%from 获得了“%arg”标记",
	["#ov_zeshi2"] = "%from 移除了“%arg”标记",
	["$ov_yanshi1"] = "骨肉至亲，血脉相连！",
	["$ov_yanshi2"] = "当以贼血，汙此白刃！",
	["$ov_yanshi3"] = "挟长持短，昼夜哀酸！",
	["ov_renchou"] = "刃仇",
	[":ov_renchou"] = "锁定技。当你或“言誓”角色死亡时，其中存活的角色对来源造成等同自己体力值的伤害。",
	["ov_zeshi"] = "誓",
	["$ov_renchou1"] = "塞亡父之冤魂，雪三弟之永恨！",
	["$ov_renchou2"] = "禄福夜雪白，都庭朝露红！",
	["ov_dianwei"] = "典韦",
	["#ov_dianwei"] = "任侠报怨",
	["~ov_dianwei"] = "少智无谋，空负此身勇武......",
	["ov_liexi"] = "烈袭",
	[":ov_liexi"] = "准备阶段，你可以弃置任意张牌并选择一名其他角色。若你弃置的牌数大于其体力值，则你对其造成1点伤害，否则其对你造成1点伤害；若你弃置的牌中包含武器牌，则你对其造成1点伤害",
	["ov_liexi0"] = "烈袭：你可以弃置任意张牌并选择一名其他角色",
	["$ov_liexi1"] = "短兵强击，贯汝心扉！",
	["$ov_liexi2"] = "性刚情烈，目不容奸！",
	["ov_shezhong"] = "慑众",
	[":ov_shezhong"] = "结束阶段，你可以选择一至两项“1、若你本回合对其他角色造成过伤害，令至多X名其他角色下个摸阶段摸牌数-1（X为你本回合造成的伤害数）；2、摸牌至与本回合对你造成过伤害的一名角色的体力值相同（至多摸至5张）。",
	["ov_shezhong0"] = "慑众：你可以选择令至多%src名其他角色下个摸阶段摸牌数-1",
	["ov_shezhong1"] = "慑众：你可以选择一名此回合对你造成过伤害的角色，摸牌至与其体力值相同",
	["$ov_shezhong1"] = "此乃吾之私怨，与汝等何干？",
	["$ov_shezhong2"] = "拦吾去路者，下场有如此贼！",
	["ov_beimihu"] = "卑弥呼",
	["#ov_beimihu"] = "邪马台女王",
	["ov_bingzhao"] = "秉诏",
	[":ov_bingzhao"] = "主公技，游戏开始时，你选择一个与你势力不同的势力。当你因“骨疽”摸牌时，若受到伤害的角色为此势力角色，则其可以令你多摸一张牌。",
	["ov_gexuan"] = "葛玄",
	["#ov_gexuan"] = "冲应真人",
	["~ov_gexuan"] = "金丹难成，大道难修",
	["$ov_gexuan"] = "科有天禁不可抑，华精庵蔼化仙人",
	["ov_danfa"] = "丹法",
	[":ov_danfa"] = "准备阶段或结束阶段，你可以将一张牌当做“丹”置于武将牌上。每回合每种花色限一次，当你使用与“丹”中花色相同的牌时，你摸一张牌。",
	["ov_danfa0"] = "丹法：你可以将一张牌当做“丹”置于武将牌上",
	["ov_dan"] = "丹",
	["$ov_danfa1"] = "取五灵三使之要，炼九光七曜之丹",
	["$ov_danfa2"] = "云液踊跃成雪霜，流珠之英能延年",
	["ov_lingbao"] = "灵宝",
	[":ov_lingbao"] = "出牌阶段限一次，你可以移去两张不同花色的“丹”牌，若：均为红色，你令一名角色回复1点体力；均为黑色，你弃置一名角色至多两个区域内各一张牌；颜色不同，你令一名角色摸一张牌，令另一名角色弃置一张牌。",
	["$ov_lingbao1"] = "洞明于至道，俯弘于世教",
	["$ov_lingbao2"] = "凝神太虚镜，北冥探玄珠",
	["ov_sidao"] = "司道",
	[":ov_sidao"] = "游戏开始时，你选择一个法宝置入装备区（【灵宝仙葫】、【太极拂尘】、【冲应神符】）。准备阶段，若你选择的法宝在游戏外、牌堆中或弃牌堆中，你获得并使用之。",
	["$ov_sidao1"] = "执吾法器，以司正道",
	["$ov_sidao2"] = "内修道法，外需宝器",
	["_ov_lingbaoxianhu"] = "灵宝仙葫",
	[":_ov_lingbaoxianhu"] = "装备牌·武器<br /><b>攻击范围</b>：3<br /><b>武器技能</b>：锁定技，当你造成大于1点的伤害或其他角色死亡时，你增加1点体力上限并回复1点体力。",
	["_ov_taijifuchen"] = "太极拂尘",
	[":_ov_taijifuchen"] = "装备牌·武器<br /><b>攻击范围</b>：5<br /><b>武器技能</b>：锁定技，其他角色需先弃置一张牌才能响应你使用的【杀】；若弃置的牌与此【杀】花色相同，你获得之。",
	["_ov_taijifuchen0"] = "太极拂尘：你需先弃置一张牌才能响应此【杀】",
	["_ov_chongyingshenfu"] = "冲应神符",
	[":_ov_chongyingshenfu"] = "装备牌·防具<br /><b>防具技能</b>：锁定技，你受到一种牌造成的伤害后，本局相同牌名的牌对你造成的伤害-1。",
	["ov_dongzhao"] = "董昭",
	["#ov_dongzhao"] = "陈筹定世",
	["~ov_dongzhao"] = "为曹公助画方略，实昭之幸也……",
	["ov_miaolve"] = "妙略",
	[":ov_miaolve"] = "游戏开始时，你获得2张【瞒天过海】。当你受到1点伤害后，你可以选择获得一张【瞒天过海】并摸一张牌，或获得一张智囊牌。",
	["$ov_miaolve1"] = "智者通权达变，以解临近之难",
	["$ov_miaolve2"] = "依吾计而行，此患乃除耳",
	["ov_yingjia"] = "迎驾",
	[":ov_yingjia"] = "一名角色回合结束时，若你于此回合内使用过至少2张同名的锦囊牌，你可以弃置一张手牌，然后令一名角色执行一个额外的回合。",
	["ov_yingjia0"] = "迎驾：你可以弃置一张手牌，然后令一名角色执行一个额外的回合",
	["ov_yingjia1"] = "迎驾：请选择令一名角色执行一个额外的回合",
	["$ov_yingjia1"] = "行非常之事，乃有非常之功，愿将军三思",
	["$ov_yingjia2"] = "将军今留匡弼,事势不便,惟移驾幸许耳",
	["_ov_mantianguohai"] = "瞒天过海",
	[":_ov_mantianguohai"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：至多2名区域内有牌的其他角色<br /><b>效果</b>：你获得目标区域内一张牌，然后交给其一张牌。<br /><b>额外效果</b>：此牌不计入你的手牌上限。",
	["_ov_mantianguohai0"] = "瞒天过海：请选择一张牌交给 %src",
	["ov_dongzhao_card"] = "董昭专属",
	["obtainMantianguohai"] = "获得一张【瞒天过海】并摸一张牌",
	["obtainZhinang"] = "获得一张智囊牌",
	["ov_duosidawang"] = "朵思大王",
	["#ov_duosidawang"] = "踞泉毒蛟",
	["~ov_duosidawang"] = "快快放箭！快快放箭！",
	["ov_equan"] = "恶泉",
	[":ov_equan"] = "锁定技，于你的回合内受到伤害的角色获得等量的“毒”标记。其准备阶段，移去这些“毒”标记，然后失去等量的体力；因此进入濒死状态的角色本回合所有技能失效。",
	["$ov_equan1"] = "哈哈哈哈哈哈，有此毒泉，大王尽可宽心",
	["$ov_equan2"] = "有此四泉足矣，何用刀兵？",
	["ov_equan_du"] = "毒",
	["ov_equan_du_skill"] = "技能失效",
	["ov_manji"] = "蛮汲",
	[":ov_manji"] = "锁定技，当其他角色失去体力后，若你的体力值：小于等于其，你回复1点体力；大于等于其，你摸一张牌。",
	["$ov_manji1"] = "嗯~~不错，不错",
	["$ov_manji2"] = "额哈哈哈哈哈哈，痛快！痛快！",
	["ov_yuejiu"] = "乐就",
	["#ov_yuejiu"] = "仲家军督",
	["~ov_yuejiu"] = "哼，动手吧！",
	["ov_cuijin"] = "催进",
	[":ov_cuijin"] = "当你或你攻击范围内的角色使用【杀】时，你可以弃置一张牌。若此【杀】造成伤害，则伤害+1；否则此【杀】使用者受到你造成的1点伤害。",
	["ov_cuijin0"] = "催进：你可以弃置一张牌，令此【杀】造成伤害时伤害+1，或未能造成伤害时对使用者造成1点伤害。",
	["$ov_cuijin1"] = "诸君速行，违者军法论处！",
	["$ov_cuijin2"] = "快！贻误军机者，定斩不赦！",
	["ov_wuban"] = "吴班",
	["#ov_wuban"] = "碧血的英豪",
	["~ov_wuban"] = "恨……杀不尽吴狗！",
	["ov_jintao"] = "进讨",
	[":ov_jintao"] = "锁定技，你使用的【杀】无视距离且次数+1；你于出牌阶段使用的第一张【杀】伤害+1，第二张【杀】不可响应。",
	["$ov_jintao1"] = "一雪前耻，誓报前仇！",
	["$ov_jintao2"] = "量敌而进，直讨吴境！",
	["ov_jiachong"] = "贾充",
	["#ov_jiachong"] = "凶凶踽行",
	["~ov_jiachong"] = "此生从事忠佞，此刻只乞不获恶谥",
	["ov_beini"] = "悖逆",
	[":ov_beini"] = "出牌阶段限一次，你可以选择一名体力值大于你的角色，令你或其摸2张牌，然后未摸牌的角色视为对摸牌的角色使用一张【杀】。",
	["ov_beini:ov_beini0"] = "悖逆：你可以令 %src 摸2张牌，否则你摸2张牌",
	["$ov_beini1"] = "今日污无用清名，明朝自得新圣褒嘉",
	["$ov_beini2"] = "吾佐奉朝日暖煦，又何惮落月残辉？",
	["ov_dingfa"] = "定法",
	[":ov_dingfa"] = "弃牌阶段结束时，若你本回合失去的牌数大于等于你的体力值，你可以选择一项：1、对一名其他角色造成1点伤害，2、回复1点体力",
	["to_damage"] = "造成伤害",
	["ov_dingfa0"] = "定法：请选择对一名其他角色造成1点伤害",
	["$ov_dingfa1"] = "峻礼教之防，准五服以制罪",
	["$ov_dingfa2"] = "礼律并重，臧善否恶，宽简弼国",
	["ov_yujin"] = "于禁",
	["#ov_yujin"] = "逐暴定乱",
	["~ov_yujin"] = "禁今命归九泉，何颜......",
	["ov_zhenjun"] = "镇军",
	[":ov_zhenjun"] = "出牌阶段开始时，你可以将一张牌交给一名其他角色，令其选择一项：1、使用一张不为黑色的【杀】，然后你摸X+1张牌（X为此【杀】造成的伤害数）；2、你对其或其攻击范围内的一名角色造成1点伤害。",
	["ov_zhenjun0"] = "镇军：你可以将一张牌交给一名其他角色",
	["ov_zhenjun1"] = "镇军：你可以使用一张不为黑色的【杀】",
	["ov_zhenjun2"] = "镇军：请选择对 %src 或其攻击范围内的一名角色造成1点伤害",
	["$ov_zhenjun1"] = "将怀其威，则镇其军！",
	["$ov_zhenjun2"] = "治军之道，得之于严！",
	["ov_xunchen"] = "荀谌",
	["#ov_xunchen"] = "谋刃略锋",
	["~ov_xunchen"] = "袁公不济，吾自当以死祭之",
	["ov_weipo"] = "危迫",
	[":ov_weipo"] = "每回合限一次，出牌阶段，你可以选择一名角色并指定【兵临城下】或一种智囊的牌名，直到你下回合开始，其可以于出牌阶段弃置一张【杀】并获得一张你指定的牌（限一次）。",
	["ov_weipobf"] = "危迫",
	[":ov_weipobf"] = "你可以于出牌阶段弃置一张【杀】并获得一张指定的牌（限一次）。",
	["ov_chenshi"] = "陈势",
	[":ov_chenshi"] = "当其他角色指定/成为【兵临城下】的目标后，其可以交给你一张牌，然后将牌堆顶3张牌中不为【杀】的牌/所有的【杀】置入弃牌堆。",
	["ov_chenshi0"] = "陈势：你可以交给 %src 一张牌，然后将牌堆顶3张牌中不为【杀】的牌置入弃牌堆",
	["ov_chenshi1"] = "陈势：你可以交给 %src 一张牌，然后将牌堆顶3张牌中所有的【杀】置入弃牌堆",
	["$ov_chenshi1"] = "将军已为此二者所围，形式实不容乐观",
	["$ov_chenshi2"] = "此二人若合立攻之，则将军危矣",
	["ov_moushi"] = "谋识",
	[":ov_moushi"] = "锁定技，当你受到伤害时，若造成伤害的牌与上次对你造成伤害的牌花色相同，你防止此伤害。",
	["_ov_binglinchengxia"] = "兵临城下",
	[":_ov_binglinchengxia"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名其他角色<br /><b>效果</b>：你展示牌堆顶4张牌，然后依次对目标使用其中的【杀】，其余牌置于牌堆顶。",
	["ov_xunchen_card"] = "荀谌专属",
	["ov_mayulu"] = "马云騄",
	["#ov_mayulu"] = "剑胆琴心",
	["ov_fengpo"] = "凤魄",
	[":ov_fengpo"] = "当你使用【杀】或【决斗】指定唯一目标后，你可以观看其手牌并选择一项：1、摸X张牌；2、此牌伤害+X（X为其♦手牌数，若你本局杀死过角色，则改为其红色手牌数）。",
	["ov_fengpo1"] = "摸%src张牌",
	["ov_fengpo2"] = "此牌伤害+%src",
	["ov_fuwan"] = "伏完",
	["ov_moukui"] = "谋溃",
	[":ov_moukui"] = "当你使用【杀】指定一个目标后，你可以选择一项：1、摸一张牌；2、弃置其一张手牌。背水：若此【杀】未令其进入濒死状态，其弃置你一张牌。",
	["ov_moukui1"] = "摸一张牌",
	["ov_moukui2"] = "弃置%src一张手牌",
	["ov_moukui3"] = "若此【杀】未令其进入濒死状态，其弃置你一张牌",
	["ov_hejin"] = "何进",
	["ov_mouzhu"] = "谋诛",
	[":ov_mouzhu"] = "出牌阶段限一次，你可以选择一名其他角色，令除其外体力值小于等于你的其他角色依次选择是否交给你一张牌。若你未因此而获得牌，则你与这些角色依次失去1点体力；否则其选择视为你对其使用一张伤害基数为X的【杀】或【决斗】（X为你以此法获得的牌数且至多为4）。",
	["mz_duel"] = "令%src视为对你使用一张伤害基数为%arg的【决斗】",
	["mz_slash"] = "令%src视为对你使用一张伤害基数为%arg的【杀】",
	["ov_mouzhu0"] = "谋诛：你可以选择一张牌交给 %src",
	["ov_yanhuo"] = "延祸",
	[":ov_yanhuo"] = "当你死亡时，你可以令一名角色弃置X张牌，或令至多X名角色各弃置一张牌（X为你的牌数）。",
	["ov_yanhuo0"] = "延祸：你可以令一名角色弃置%src张牌，或令至多%src名角色各弃置一张牌",
	["ov_hucheer"] = "胡车儿",
	["ov_shenxing"] = "神行",
	[":ov_shenxing"] = "锁定技，若你装备区里没有坐骑牌，你计算与其他角色距离-1，你的手牌上限+1。",
	["ov_daoji"] = "盗戟",
	[":ov_daoji"] = "出牌阶段限一次，你可以弃置一张非基本牌并选择一名攻击范围内的其他角色，你获得其一张牌。若此牌为：基本牌，你摸一张牌；装备牌，你使用之并对其造成1点伤害。",
	["ov_fuhuanghou"] = "伏皇后",
	["ov_zangba"] = "臧霸",
	["~ov_zangba"] = "断刃沉江，负主重托……",
	["ov_guanyu"] = "扞御",
	[":ov_guanyu"] = "锁定技，游戏开始时，你获得每种类别的牌各一张。",
	["$ov_guanyu1"] = "霸起泰山，称雄东方！",
	["$ov_guanyu2"] = " 乱贼何惧，霸自可御之！",
	["ov_hengjiang"] = "横江",
	[":ov_hengjiang"] = "出牌阶段限一次，当你使用基本牌或普通锦囊牌指定唯一目标后，你可以将此牌目标改为攻击范围内所有的角色；此牌结算后，你摸X张牌（X为响应此牌的角色数）。",
	["#ov_hengjiang0"] = "%from 将此【%arg】的目标改为 %to",
	["$ov_hengjiang1"] = "霸必奋勇杀敌，一雪夷陵之耻！",
	["$ov_hengjiang2"] = "江横索寒，阻敌绝境之中！",
	["ov_liuhong"] = "刘宏",
	["~ov_liuhong"] = "汉室中兴，还需尔等忠良....",
	["ov_yujue"] = "鬻爵",
	[":ov_yujue"] = "其他角色出牌阶段，其可以交给你任意张牌（每阶段至多2张）。当你于回合外获得其他角色的一张牌后，你可以令其选择一项：1、弃置攻击范围内另一名角色的一张牌；2、使用下一张牌时随机获得一张同类型的牌（每回合每项限一次）。",
	["$ov_yujue1"] = "财物交足，官位任取",
	["$ov_yujue2"] = "卖官鬻爵，取财之道",
	["ov_yujuevs"] = "鬻爵",
	[":ov_yujuevs"] = "出牌阶段，你可以交给拥有“鬻爵”的一名角色任意张牌（每阶段至多2张）。",
	[":ov_yujuevs1"] = "出牌阶段，你可以交给拥有“鬻爵”的一名角色任意张牌（每阶段至多2张）。",
	[":ov_yujuevs2"] = "出牌阶段，你可以交给拥有“鬻爵”的一名角色任意张牌（每阶段至多4张）。",
	["ov_gezhi"] = "革制",
	[":ov_gezhi"] = "当你于出牌阶段首次使用每种类型的牌时，你可以重铸一张手牌。出牌阶段结束时，若你此阶段以此法重铸过至少2张牌，你可以令一名角色选择一项：1、攻击范围+2；2、手牌上限+2；3、增加1点体力上限（每名角色每项限一次）。",
	["ov_gezhi0"] = "革制：你可以重铸一张手牌",
	["ov_gezhibf"] = "革制效果",
	["#ov_gezhibf0"] = "%from 在“%arg”中选择了 %arg2",
	["ov_gezhibf1"] = "攻击范围+2",
	["ov_gezhibf2"] = "手牌上限+2",
	["ov_gezhibf3"] = "增加1点体力上限",
	["$ov_gezhi1"] = "改革旧制，保我汉室长存",
	["$ov_gezhi2"] = "革除旧弊，方乃中兴",
	["ov_fengqi"] = "烽起",
	[":ov_fengqi"] = "主公技，锁定技，其他群势力角色出牌阶段，“鬻爵”的描述改为“至多4张”；其他角色成为“革制”的目标时，其可以获得其武将牌上的主公技。",
	["ov_fengqi:ov_fengqi0"] = "烽起：你可以获得你武将牌上的主公技",
	["#ov_fengqi1"] = "%from 获得了技能“%arg”",
	["ov_gezhi1"] = "革制：你可以令一名角色选择一项其未拥有的效果；1、攻击范围+2；2、手牌上限+2；3、增加1点体力上限",
	["ov_yujue1"] = "弃置攻击范围内另一名角色的一张牌",
	["ov_yujue2"] = "使用下一张牌时随机获得一张同类型的牌",
	["ov_yujue10"] = "鬻爵：请选择弃置攻击范围内另一名角色的一张牌",
	["ov_caocao"] = "曹操",
	["#ov_caocao"] = "峥嵘而立",
	["~ov_caocao"] = "奸宦当道，难以匡正啊……",
	["ov_lingfa"] = "令法",
	[":ov_lingfa"] = "第一轮开始时，你可以令本轮所有其他角色使用【杀】时需弃置一张牌；第二轮开始时，你可以令本轮所有其他角色使用【桃】后需交给你一张牌；若其未执行，你对造成1点伤害。第三轮开始时，你失去此技能，然后获得“治暗”。",
	["ov_lingfa:ov_lingfa1"] = "令法：你可以令本轮所有其他角色使用【杀】时需弃置一张牌",
	["ov_lingfa:ov_lingfa2"] = "令法：你可以令本轮所有其他角色使用【桃】后需交给你一张牌",
	["ov_lingfa2"] = "令法：你可以交给%src一张牌,否则其将对你造成1点伤害",
	["ov_lingfa1"] = "令法：你可以弃置一张牌,否则%src将对你造成1点伤害",
	["ov_lingfa10"] = "使用杀需弃牌",
	["ov_lingfa20"] = "使用桃需交牌",
	["$ov_lingfa1"] = "吾明令在此，汝何以犯之？",
	["$ov_lingfa2"] = "法不阿贵，绳不挠曲！",
	["ov_zhian"] = "治暗",
	[":ov_zhian"] = "每回合限一次，当有角色使用装备牌或延时锦囊牌后，你可以选择一项：1、从场上弃置此牌；2、弃置一张手牌并获得此牌；3、对其造成1点伤害。",
	["ov_zhian1"] = "从场上弃置此【%src】",
	["ov_zhian2"] = "弃置一张手牌并获得此【%src】",
	["ov_zhian3"] = "对%src造成1点伤害",
	["$ov_zhian1"] = "此等蝼蚁不除，必溃千丈之堤！",
	["$ov_zhian2"] = "尔等权贵贪赃枉法，岂可轻饶？",
	["ov_zhangmancheng"] = "张曼成",
	["#ov_zhangmancheng"] = "南阳渠帅",
	["~ov_zhangmancheng"] = "天师，曼成尽力了……",
	["ov_fengji"] = "蜂集",
	[":ov_fengji"] = "出牌阶段开始时，若你没有“示”，你可以将一张牌置于武将牌上，称为“示”并施法：从牌堆中获得X张与“示”同名的牌，然后移去“示”。",
	["ov_fengji0"] = "蜂集：你可以将一张牌置于武将牌上，称为“示”并施法",
	["ov_fengji1"] = "从牌堆中获得%src张与示同名的牌",
	["$ov_fengji1"] = "蜂趋蚁附，皆为道来",
	["$ov_fengji2"] = "蜂攒蚁集，皆为道往！",
	["ov_yiju"] = "蚁聚",
	[":ov_yiju"] = "若你拥有“示”，你于出牌阶段可使用的【杀】数和攻击范围均等于体力值；当你受到伤害时，你移去“示”，然后此伤害+1。",
	["$ov_yiju1"] = "鸱张蚁聚，谓从天道",
	["$ov_yiju2"] = "黄巾之道，苍天之事",
	["ov_budao"] = "布道",
	[":ov_budao"] = "限定技，准备阶段，你可以扣减1点体力上限并回复1点体力，选择获得一个施法技能，然后你可以令一名其他角色获得相同技能并交给你一张牌。",
	["ov_budao0"] = "布道：你可以令一名其他角色也获得“%src”并交给你一张牌",
	["ov_budao1"] = "布道：请选择一张牌交给%src",
	["$ov_budao1"] = "得天之力，从天之道！",
	["$ov_budao2"] = "黄天大道，泽及苍生！",
	["ov_shi"] = "示",
	["ov_sfzhouhu"] = "咒护",
	[":ov_sfzhouhu"] = "出牌阶段限一次，你可以弃置一张红色手牌并施法：回复X点体力。",
	["ov_sfzhouhu0"] = "回复%src点体力",
	["ov_sffengqi"] = "丰祈",
	[":ov_sffengqi"] = "出牌阶段限一次，你可以弃置一张黑色手牌并施法：摸2X张牌。",
	["ov_sfzuhuo"] = "阻祸",
	[":ov_sfzuhuo"] = "出牌阶段限一次，你可以弃置一张非基本牌并施法：你受到的下X次伤害时，防止之。",
	["ov_handang"] = "韩当",
	["ov_gongqi"] = "弓骑",
	[":ov_gongqi"] = "你的攻击范围无限。出牌阶段限一次，你可以弃置一张牌，然后此阶段你使用与弃置牌花色相同的【杀】无次数限制；若你以此法弃置的牌为装备牌，你可以弃置一名其他角色的一张牌。",
	["ov_gongqi0"] = "弓骑：你可以选择弃置一名其他角色的一张牌",
	["ov_jiefan"] = "解烦",
	[":ov_jiefan"] = "限定技，出牌阶段，你可以选择一名角色，然后令攻击范围内有其的角色依次选择一项：1、弃置一张武器牌；令其摸一张牌。当其陷入濒死状态时，此技能视为未发动过。",
	["ov_jiefan0"] = "解烦：你可以弃置一张武器牌，否则%src将摸一张牌",
	["ov_caozhao"] = "曹肇",
	["#ov_caozhao"] = "宛童啖桃",
	["~ov_caozhao"] = "虽极荣宠，亦有尽时……",
	["ov_fuzuan"] = "复纂",
	[":ov_fuzuan"] = "你可以于以下时机调换一名角色一个转换技的状态；出牌阶段限一次、你对其他角色造成伤害后、你受到伤害后。",
	["ov_fuzuan0"] = "复纂：你可以调换一名角色一个转换技的状态",
	["$ov_fuzuan10"] = "%from 将 %to 的转换技“%arg”状态转换为 %arg2",
	["$ov_fuzuan1"] = "望陛下听臣忠言，勿信资等无知之论",
	["$ov_fuzuan2"] = "前朝王莽之乱，可为今世之鉴！",
	["ov_congqi"] = "宠齐",
	[":ov_congqi"] = "锁定技，游戏开始时，所有角色获得技能“非服”，你选择是否扣减1点体力上限令一名其他角色获得“复纂”。",
	["ov_congqi:ov_congqi0"] = "宠齐：你可以扣减1点体力上限令一名其他角色获得“复纂”",
	["ov_congqi1"] = "宠齐：请选择令一名其他角色获得“复纂”",
	["$ov_congqi1"] = "吾既身承宠遇，敢不为君分忧",
	["$ov_congqi2"] = "臣得君上垂青，已是此生之幸",
	["ov_feifu"] = "非服",
	[":ov_feifu"] = "转换技，锁定技，当你①成为②指定【杀】的唯一目标后，目标角色须交给使用者一张牌；若为装备牌，获得牌的角色可以使用之。",
	[":ov_feifu1"] = "转换技，锁定技，当你①成为<font color=\"#01A5AF\"><s>②指定</s></font>【杀】的唯一目标后，目标角色须交给使用者一张牌；若为装备牌，获得牌的角色可以使用之。",
	[":ov_feifu2"] = "转换技，锁定技，当你<font color=\"#01A5AF\"><s>①成为</s></font>②指定【杀】的唯一目标后，目标角色须交给使用者一张牌；若为装备牌，获得牌的角色可以使用之。",
	["ov_feifu0"] = "非服：请选择一张牌交给%src",
	["ov_feifu1"] = "非服：你可以使用此【%src】",
	["$ov_feifu1"] = "此亦久矣，岂能复几！",
	["$ov_feifu2"] = "以侯归第，终败于其！",
	["ov_tianyu"] = "田豫",
	["#ov_tianyu"] = "规略明练",
	["~ov_tianyu"] = "钟鸣漏尽，夜行不休……",
	["ov_zhenxi"] = "震袭",
	[":ov_zhenxi"] = "每回合限一次，当你使用【杀】指定一个目标后，你可以选择一项：1、弃置其X张手牌（X为你与其的距离）；2、移动其场上的一张牌。若其体力值大于你或为全场最大，你可以依次执行两项。",
	["ov_zhenxi1"] = "弃置其手牌",
	["ov_zhenxi2"] = "移动其场上的一张牌",
	["ov_zhenxi3"] = "你可以依次执行两项",
	["$ov_zhenxi1"] = "戮胡首领，捣其王庭！",
	["$ov_zhenxi2"] = "震疆扫寇，袭贼平戎！",
	["ov_yangshi"] = "扬师",
	[":ov_yangshi"] = "锁定技，当你受到伤害后，你的攻击范围+1，若其他角色均处于你的攻击范围内，则改为从牌堆中获得一张【杀】。",
	["$ov_yangshi1"] = "扬师北疆，剪覆胡奴！",
	["$ov_yangshi2"] = "陈兵百万，慑敌心胆！",
	["ov_wangcang"] = "王昶",
	["#ov_wangcang"] = "识度良臣",
	["~ov_wangcang"] = "吾切至之言，望尔等引以为戒",
	["ov_kaiji"] = "开济",
	[":ov_kaiji"] = "准备阶段，你可以令至多X名角色各摸一张牌（X为进入过濒死状态的角色数+1），若有角色因此获得了非基本牌，你摸一张牌。",
	["ov_kaiji0"] = "开济：你可以令至多%src名角色各摸一张牌",
	["$ov_kaiji1"] = "力除秦汉之弊，方可治化复兴",
	["$ov_kaiji2"] = "约官食禄，勿与百姓争利",
	["ov_shepan"] = "慑叛",
	[":ov_shepan"] = "每回合限一次，当你成为其他角色使用牌的目标后，你可以摸一张牌或将其区域内一张牌置于牌堆顶，然后若你与其手牌数相同，此技能视为未发动过且你可以令此牌对你无效。",
	["ov_shepan:ov_shepan0"] = "慑叛：你可以令此【%src】对你无效",
	["ov_shepan1"] = "摸一张牌",
	["ov_shepan2"] = "将其区域内一张牌置于牌堆顶",
	["$ov_shepan1"] = "遣五军按大道发还，贼望必喜而轻敌",
	["$ov_shepan2"] = "以所获铠马驰环城，贼见必怒而失智",
	["ov_wujing"] = "吴景",
	["#ov_wujing"] = "坚攻勉策",
--	["~ov_wujing"] = "吴景",
	["ov_fenghan"] = "锋捍",
	[":ov_fenghan"] = "每回合限一次，当你使用【杀】或伤害类锦囊牌指定目标后，你可以令至多X名角色各摸一张牌（X为此牌的目标数）。",
	["ov_fenghan0"] = "锋捍：你可以令至多%src名角色各摸一张牌",
	["$ov_fenghan1"] = "锋捍",
	["$ov_fenghan2"] = "锋捍",
	["ov_congji"] = "从击",
	[":ov_congji"] = "你的回合外，当你的红色牌因弃置而进入弃牌堆后，你可以将这些牌交给一名其他角色。",
	["ov_congji0"] = "从击：你可以将这些因弃置的红色牌交给一名其他角色",
	["$ov_congji1"] = "从击",
	["$ov_congji2"] = "从击",
	["ov_wangcan"] = "王粲",
	["#ov_wangcan"] = "溢才捷密",
	["ov_dianyi"] = "典仪",
	[":ov_dianyi"] = "锁定技，回合结束时，若你本回合：造成过伤害，你弃置所有手牌；未造成伤害，你将手牌数调整至4张。",
	["$ov_dianyi1"] = "旧仪废弛，兴造制度",
	["$ov_dianyi2"] = "礼仪卒度，笑语卒获",
	["ov_yingji"] = "应机",
	[":ov_yingji"] = "当你于回合外需要使用或打出一种基本牌或普通锦囊牌时，若你没有手牌，你可以摸一张牌并视为使用或打出了对应的牌。",
	["$ov_yingji1"] = "辩适于世，论和于时",
	["$ov_yingji2"] = "辩言出于口，不失思忖心",
	["ov_shanghe"] = "觞贺",
	[":ov_shanghe"] = "限定技，当你陷入濒死状态时，你可以令所有其他角色各交给你一张牌，若其中没有【酒】，你回复体力至1点。",
	["ov_shanghe0"] = "觞贺：请选择将一张牌交给%src",
	["$ov_shanghe1"] = "今使海内回心，望风而愿治，皆明公之功也",
	["$ov_shanghe2"] = "明公平定兵乱，使百姓可安，粲当奉觞以贺",
	["ov_huojun"] = "霍峻",
	["#ov_huojun"] = "葭萌铁师",
	["~ov_huojun"] = "恨不能与使君共成霸业......",
	["ov_sidai"] = "伺怠",
	[":ov_sidai"] = "限定技，出牌阶段，你可以将手牌中所有的基本牌当做【杀】使用（无距离与次数限制）。若其中包含：【酒】，造成伤害时伤害翻倍；【桃】，造成伤害后令受到伤害的角色扣减1点体力上限；【闪】，目标角色需先弃置一张基本牌才能响应。",
	["ov_sidai0"] = "伺怠：请先弃置一张基本牌才能响应此【%src】",
	["$ov_sidai1"] = "敌军疲乏，正是战机，随我杀！",
	["$ov_sidai2"] = "敌军无备，随我冲锋！",
	["ov_jieyu"] = "竭御",
	[":ov_jieyu"] = "每轮限一次，结束阶段或当你每轮第一次受到伤害后，你可以弃置所有手牌，然后从弃牌堆中获得不同牌名的基本牌各一张。",
	["$ov_jieyu1"] = "葭萌，蜀之咽喉，峻必竭力守之！",
	["$ov_jieyu2"] = " 吾头可得，城不可得！",
	["ov_liufuren"] = "刘夫人",
	["#ov_liufuren"] = "酷妒的海棠",
	["~ov_liufuren"] = "害人终害己，最毒妇人心……",
	["ov_zhuidu"] = "追妒",
	[":ov_zhuidu"] = "出牌阶段限一次，你可以选择一名已受伤的其他角色并选择一项：1、对其造成1点伤害；2、弃置其装备区的一张牌。若其为女性角色，你可以背水：弃置一张牌。",
	["ov_zhuidu1"] = "对其造成1点伤害",
	["ov_zhuidu2"] = "弃置其装备区的一张牌",
	["ov_zhuidu3"] = "弃置一张牌",
	["$ov_zhuidu1"] = "到了阴司地府，你们也别想好过！",
	["$ov_zhuidu2"] = "髡头墨面，杀人诛心!",
	["ov_shigong"] = "示恭",
	[":ov_shigong"] = "限定技，当你于回合外进入濒死状态时，你可以令当前回合角色选择一项：1、增加1点体力上限并回复1点体力，摸一张牌，然后令你回复体力至上限；2、弃置X张牌（X为其体力值），然后令你回复体力至1点。",
	["ov_shigong1"] = "增加1点体力上限并回复1点体力，摸一张牌，然后令%src回复体力至上限",
	["ov_shigong2"] = "弃置X张牌（X为你的体力数），然后令%src回复体力至1点",
	["$ov_shigong1"] = "冀州安定，此司空之功也…",
	["$ov_shigong2"] = "妾当自缚，以示诚心。",
	["ov_mateng"] = "马腾",
	["#ov_mateng"] = "驰骋西陲",
	["~ov_mateng"] = "皇叔，剩下的就靠你了",
	["ov_xiongzheng"] = "雄争",
	[":ov_xiongzheng"] = "每轮开始时，你可以选择一名角色（每名角色限选择一次），然后此轮结束时，你可以选择一项：1、视为依次对任意名本轮未对其造成过伤害的其他角色使用一张【杀】；2、令任意名本轮对其造成过伤害的角色摸两张牌。",
	["ov_xiongzheng0"] = "雄争：你可以选择任意名角色执行效果",
	["ov_xiongzheng1"] = "雄争：你可以选择一名角色",
	["$ov_xiongzheng1"] = "西凉男儿，怀天下之志",
	["$ov_xiongzheng2"] = "金戈铁马，争乱世之雄",
	["ov_luannian"] = "乱年",
	[":ov_luannian"] = "主公技，其他群势力角色出牌阶段限一次，其可以弃置X张牌（X为此技能本轮发动的次数），对“雄争”目标造成1点伤害。",
	["$ov_luannian1"] = "凶年荒岁，当兴乱自保",
	["$ov_luannian2"] = "天下大势，分分合合！",
	["ov_luannianvs"] = "乱年",
	[":ov_luannianvs"] = "群势力角色出牌阶段限一次，你可以弃置X张牌（X为此技能本轮发动的次数），对“雄争”目标造成1点伤害。",
	["damage"] = "伤害",
	["to"] = "目标",
	["ov_jianshuo"] = "蹇硕",
	["#ov_jianshuo"] = "西园硕犀",
	["~ov_jianshuo"] = "郭胜，汝竟下此狠手！",
	["ov_xiongsi"] = "凶兕",
	[":ov_xiongsi"] = "出牌阶段，你可以视为对一名其他角色使用一张【杀】（每名角色限一次），然后若此【杀】未造成伤害，其获得技能“令戮”直到你下回合开始，且其指定你为“令戮”的目标时，其可以令你于失败时执行两次结算。",
	["$ov_xiongsi1"] = "豺狼虎兕雄壮，西园将校威风！",
	["$ov_xiongsi2"] = "灵帝遗命，岂容尔等放肆？",
	["ov_linglu"] = "令戮",
	[":ov_linglu"] = "强令：令一名角色于其下回合结束前造成至少2点伤害。成功》其摸两张牌；失败》其失去1点体力。",
	["ov_linglu0"] = "令戮：你可以令一名角色于其下回合结束前造成至少2点伤害",
	["ov_niufudongxie"] = "牛辅&董翓",
	["&ov_niufudongxie"] = "牛辅董翓",
	["#ov_niufudongxie"] = "虺伴蝎行",
	["~ov_niufudongxie"] = "董公遗命，谁可继之.....",
	["ov_juntun"] = "军屯",
	[":ov_juntun"] = "游戏开始时或一名角色的濒死结算后，你可以令一名角色获得“凶军”。拥有“凶军”的其他角色造成伤害后，你额外获得等量的暴虐值。",
	["ov_juntun0"] = "军屯：你可以令一名角色获得“凶军”",
	["$ov_juntun1"] = "屯安逸之地，慑山东之贼",
	["$ov_juntun2"] = "长安丰饶，当以军养军",
	["ov_xiongxi"] = "凶袭",
	[":ov_xiongxi"] = "出牌阶段，你可以弃置X张牌（X为你的暴虐值与上限之差），然后对一名本回合未以此法选择过的角色造成1点伤害。",
	["$ov_xiongxi1"] = "凶兵厉袭，片瓦不存！",
	["$ov_xiongxi2"] = "尽起西凉狼兵，袭掠中原之地！",
	["ov_xiafeng"] = "黠凤",
	[":ov_xiafeng"] = "出牌阶段开始时，你可以消耗至多3点暴虐值，令本回合你手牌上限+X，使用的前X张牌无距离和次数限制且不能被响应（X为你消耗的暴虐值）。",
	["$ov_xiafeng1"] = "穷奇凶厉，黠凤诡诈",
	["$ov_xiafeng2"] = "鸾凤襄蛟，黠凤殷狰",
	["ov_xiongjun"] = "凶军",
	[":ov_xiongjun"] = "锁定技，当你造成伤害后，拥有“凶军”的角色各摸一张牌。",
	["$ov_xiongjun1"] = "凶军",
	["$ov_xiongjun2"] = "凶军",
	["ov_bingyuan"] = "邴原",
	["#ov_bingyuan"] = "峰名谷怀",
	["~ov_bingyuan"] = "人能弘道，非道弘人",
	["ov_bingde"] = "秉德",
	[":ov_bingde"] = "出牌阶段限一次，你可以弃置一张牌并选择一种花色，然后摸X张牌（X为你此阶段使用此花色的牌数）。若你以此法弃置牌的花色与选择的花色相同，此技能视为未发动过（你此阶段下次不能再选择此花色）。",
	["$ov_bingde1"] = "秉德纯懿，志行忠方",
	["$ov_bingde2"] = "慎所与，节所偏，德必迩矣",
	["ov_qingtao"] = "清滔",
	[":ov_qingtao"] = "摸牌阶段结束时，你可以重铸一张牌，若此牌为【酒】或非基本牌，你额外摸一张牌。若你此回合未发动过此技能，你可以于结束阶段发动此技能",
	["ov_qingtao0"] = "清滔：你可以选择一张牌重铸之",
	["$ov_qingtao1"] = "君子当如滔流，循道而不失其行",
	["$ov_qingtao2"] = "探赜索隐，钩深致远。日月在躬，隐之弥曜",
	["use"] = "使用",
	["ov_puyangxing"] = "濮阳兴",
	["#ov_puyangxing"] = "协邪肆民",
	["~ov_puyangxing"] = "陛下已流放吾等，为何...啊——",
	["ov_zhengjian"] = "征建",
	[":ov_zhengjian"] = "游戏开始时，你选择一项要求：1、使用过非基本牌；2、获得过牌。其他角色出牌阶段结束时，若其此阶段未完成“征建”要求，其交给你一张牌，然后你可以变更“征建”要求。",
	[":ov_zhengjian2"] = "游戏开始时，你选择一项要求：1、使用过非基本牌；2、获得过牌。其他角色出牌阶段结束时，若其此阶段未完成“征建”要求，你可以对其造成1点伤害，然后你可以变更“征建”要求。",
	["ov_zhengjian0"] = "征建：请选择一张牌交给%src",
	["ov_zhengjian:ov_zhengjian3"] = "征建：你可以变更“征建”要求",
	["ov_zhengjian1"] = "使用过非基本牌",
	["ov_zhengjian2"] = "获得过牌",
	["$ov_zhengjian0"] = "%from 为 %arg 选择的要求为 %arg2",
	["$ov_zhengjian10"] = "%from 将 %arg 的要求变更为 %arg2",
	["$ov_zhengjian1"] = "修建未成，皆因尔等懈怠！",
	["$ov_zhengjian2"] = " 哼！何故建田不成？",
	["ov_zhongchi"] = "众斥",
	[":ov_zhongchi"] = "锁定技，当累计X名角色因“征建”交给你牌后（X为游戏人数的一半，向上取整），本局你受到【杀】的伤害+1，然后将“征建”中的“其交给你一张牌”修改为“你可以对其造成1点伤害”。",
	["$ov_zhongchi0"] = "%from 修改了“%arg”的描述",
	["$ov_zhongchi1"] = "陛下，兴已知错！",
	["$ov_zhongchi2"] = "微臣有罪，任凭陛下处置。",
	["ov_liuxie"] = "刘协",
	["ov_zhuiting"] = "坠庭",
	[":ov_zhuiting"] = "主公技，当一张锦囊牌对你生效前，其他群势力或魏势力角色可以将一张与该锦囊牌颜色相同的手牌当做【无懈可击】使用。",
	["$ov_zhuiting1"] = "坠庭",
	["$ov_zhuiting2"] = "坠庭",
	["ov_zhuitingvs"] = "坠庭",
	[":ov_zhuitingvs"] = "当一张锦囊牌对“坠庭”角色生效前，群势力或魏势力角色可以将一张与该锦囊牌颜色相同的手牌当做【无懈可击】使用。",
	["ov_liuyao"] = "刘繇",
	["ov_niju"] = "逆拒",
	[":ov_niju"] = "主公技，你的拼点牌亮出后，你可以令其中一张拼点牌点数+X或-X，然后若两张拼点牌点数相同，你摸X张牌（X为其他群势力数）。",
	["ov_niju0"] = "逆拒：请选择一张拼点牌变更点数",
	["$ov_niju10"] = "%from 令拼点牌 %card 点数%arg,视为 %arg2",
	["ov_niju2"] = "点数+%src",
	["ov_niju3"] = "点数-%src",
	["$ov_niju1"] = "逆拒",
	["$ov_niju2"] = "逆拒",
	["ov_liuyu"] = "刘虞",
	["ov_chongwang"] = "崇望",
	[":ov_chongwang"] = "主公技，每名其他群势力角色限一次，其出牌阶段开始时，其可以交给你一张牌，然后你与其使用【杀】或伤害类锦囊牌不能指定对方为目标，直到你下回合结束。",
	["ov_chongwang0"] = "崇望：你可以交给%src一张牌，然后你与其使用【杀】或伤害类锦囊牌不能指定对方为目标，直到其下回合结束",
	["$ov_chongwang1"] = "崇望",
	["$ov_chongwang2"] = "崇望",
	["ov_zhangxiu"] = "张绣",
	["ov_juxiang"] = "踞襄",
	[":ov_juxiang"] = "主公技，其他群势力角色出牌阶段限一次，其可以将装备区一张牌移动给你，若你对应装备栏已废除，则改为将此装备牌交给你并恢复该装备栏。",
	["$ov_juxiang1"] = "踞襄",
	["$ov_juxiang2"] = "踞襄",
	["ov_juxiangvs"] = "踞襄",
	[":ov_juxiangvs"] = "群势力角色出牌阶段限一次，你可以将装备区一张牌移动给“踞襄”角色，若其对应装备栏已废除，则改为将此装备牌交给其并恢复该装备栏。",
	["ov_zhanglu"] = "张鲁",
	["ov_shijun"] = "师君",
	[":ov_shijun"] = "主公技，其他群势力角色出牌阶段限一次，若你没有“米”，其可以摸一张牌，然后将一张牌当做“米”置于你的武将牌上。",
	["$ov_shijun1"] = "师君",
	["$ov_shijun2"] = "师君",
	["ov_shijunvs"] = "师君",
	[":ov_shijunvs"] = "群势力角色出牌阶段限一次，若“师君”角色没有“米”，你可以摸一张牌，然后将一张牌当做“米”置于其的武将牌上",
	["ov_shijun0"] = "师君：请选择一张牌当做“米”置于%src武将牌上",
	["ov_sunjian"] = "孙坚",
	["ov_polu"] = "破虏",
	[":ov_polu"] = "主公技，当吴势力角色杀死角色或死亡后，你可以令任意名角色各摸X张牌（X为你发动此技能的次数）。",
	["ov_polu0"] = "破虏：你可以令任意名角色各摸%src张牌",
	["ov_menghuo"] = "孟获",
	["ov_qiushou"] = "酋首",
	[":ov_qiushou"] = "主公技，锁定技，当【南蛮入侵】结算后，若此牌造成的伤害大于3点或有角色因此死亡，你令所有蜀势力和群势力角色各摸一张牌。",
	["$ov_qiushou1"] = "酋首",
	["$ov_qiushou2"] = "酋首",
	["ov_zhangji"] = "张既",
	["#ov_zhangji"] = "边安人宁",
	["~ov_zhangji"] = "恨不见四海肃眘，羌胡徕服",
	["ov_dingzhen"] = "定镇",
	[":ov_dingzhen"] = "每轮开始时，你可以选择距离X以内的任意名角色（X为你的体力值），令这些角色需弃置一张【杀】，否则本轮其回合内使用的第一张牌不能指定你为目标。",
	["ov_dingzhen0"] = "定镇：你可以选择距离%src以内的任意名角色",
	["ov_dingzhen1"] = "定镇：你可以弃置一张【杀】，否则你回合内使用的第一张牌不能指定 %src 为目标",
	["$ov_dingzhen1"] = "招抚流民，兴复县邑",
	["$ov_dingzhen2"] = "容民畜众，群羌归土",
	["ov_youye"] = "攸业",
	[":ov_youye"] = "锁定技，其他角色的结束阶段，若其本回合未对你造成过伤害，你将牌堆顶一张牌当做“蓄”置于武将牌上（至多5张）。当你造成或受到伤害后，你将所有“蓄”交给任意名角色，当前回合角色至少须获得1张。",
	["ov_youye0"] = "攸业：请分配至少一张牌给%src",
	["ov_youye1"] = "攸业：请任意分配这些牌",
	["ov_xu"] = "蓄",
	["$ov_youye1"] = "筑城西疆，开万代太平",
	["$ov_youye2"] = "镇边戍卫，许万民攸业",
	["ov_fengxi"] = "冯习",
	["#ov_fengxi"] = "赤胆的忠魂",
	["~ov_fengxi"] = "陛下，速退白帝.....",
	["ov_qingkou"] = "轻寇",
	[":ov_qingkou"] = "准备阶段，你可以视为使用一张【决斗】，然后以此法造成了伤害的角色摸一张牌；若为你，则你跳过本回合的判定阶段和弃牌阶段。",
	["ov_qingkou0"] = "轻寇：你可以视为使用一张【决斗】",
	["$ov_qingkou1"] = "哈哈哈啊哈，鼠辈岂能挡我大汉雄师",
	["$ov_qingkou2"] = "凛凛汉将，岂畏江东鼠辈？",
	["ov_zhangning"] = "张宁",
	["#ov_zhangning"] = "大贤后人",
	["~ov_zhangning"] = "风过烟尘散，雨罢雷音绝",
	["ov_xingzhui"] = "星坠",
	[":ov_xingzhui"] = "出牌阶段限一次，你可以失去1点体力并施法：亮出牌堆顶2X张牌，然后你可以令一名其他角色获得其中的黑色牌，若其获得的牌数大于等于X，你对其造成X点雷电伤害。",
	["ov_xingzhui0"] = "星坠：你可以令一名其他角色获得这些黑色牌",
	["$ov_xingzhui1"] = "中宫暗弱，紫宫当明",
	["$ov_xingzhui2"] = "星坠如雨，月掩轩辕",
	["ov_juchen"] = "聚尘",
	[":ov_juchen"] = "结束阶段，若你的手牌数与体力值均不为全场最大，你可以令所有角色依次弃置一张牌，然后你获得其中的红色牌。",
	["$ov_juchen1"] = "流沙聚散，黄巾浮沉",
	["$ov_juchen2"] = "积土为台，聚尘为砂",
	["ov_yufuluo"] = "于夫罗",
	["#ov_yufuluo"] = "援汉雄狼",
	["~ov_yufuluo"] = "於夫罗",
	["ov_jiekuang"] = "竭匡",
	[":ov_jiekuang"] = "每回合限一次，当体力值小于你的角色成为其他角色使用基本牌或普通锦囊牌的唯一目标时，若场上没有角色濒死，你可以失去1点体力或扣减1点体力上限，将此牌目标转移给你；此牌结算后，若此牌未对你造成伤害且使用者可成为同名牌的合法目标，你视为对其使用之。",
	["ov_jiekuang1"] = "失去1点体力",
	["ov_jiekuang2"] = "扣减1点体力上限",
	["$ov_jiekuang1"] = "竭匡",
	["$ov_jiekuang2"] = "竭匡",
	["ov_neirao"] = "内扰",
	[":ov_neirao"] = "觉醒技，准备阶段，若你的体力值与体力上限之和小于等于9，你失去“竭匡”并获得“乱掠”，然后弃置所有牌并从牌堆或弃牌堆中获得等量的【杀】",
	["$ov_neirao1"] = "内扰",
	["$ov_neirao2"] = "内扰",
	["ov_luanlve"] = "乱掠",
	[":ov_luanlve"] = "出牌阶段，你可以将X张【杀】当做【顺手牵羊】对一名此阶段未成为过【顺手牵羊】目标的角色使用（X为你以此法使用牌的次数）；你使用的【顺手牵羊】不能被响应。",
	["$ov_luanlve1"] = "乱掠",
	["$ov_luanlve2"] = "乱掠",
	["ov_jiangji"] = "蒋济",
	["#ov_jiangji"] = "盛魏昌杰",
	["~ov_jiangji"] = "洛水之誓，言犹在耳……呃咳咳",
	["ov_jichou"] = "急筹",
	[":ov_jichou"] = "每回合限一次，你可以视为使用一张普通锦囊牌，然后你不能再以此法或从手牌中使用此牌名的牌，且不能响应此牌名的牌。出牌阶段限一次，你可以将手牌中“急筹”使用过的牌交给一名其他角色。",
	["ov_jichou0"] = "急筹：请选择一名角色交给其你手牌中“急筹”使用过的牌",
	["ov_jichou1"] = "急筹：你可以视为使用【%src】",
	["ov_jichou-Clear"] = "视为使用一张普通锦囊牌",
	["ov_jichoucard-PlayClear"] = "将手牌中“急筹”使用过的牌交给一名其他角色",
	["$ov_jichou1"] = "此危亡之时，当出此急谋",
	["$ov_jichou2"] = "急筹布划，运策捭阖",
	["ov_jilun"] = "机论",
	[":ov_jilun"] = "当你受到伤害后，你可以选择一项：1、摸X张牌（X为“急筹”使用过的牌数，至少为1，至多为5）；2、视为使用一张“急筹”使用过的牌（每种牌名限一次）。",
	["ov_jilun0"] = "机论：你可以视为使用【%src】",
	["ov_jilun1"] = "摸%src张牌",
	["ov_jilun2"] = "视为使用一张“急筹”使用过的牌",
	["$ov_jilun1"] = "时移不移，违天之祥也",
	["$ov_jilun2"] = "民望不因，违人之咎也",
	["ov_zhangnan"] = "张南",
	["#ov_zhangnan"] = "澄辉的义烈",
	["~ov_zhangnan"] = "骨埋吴地，魂归汉土……",
	["ov_fenwu"] = "奋武",
	[":ov_fenwu"] = "结束阶段，你可以失去1点体力，视为使用一张【杀】，若你本回合使用过多于一种基本牌，则此【杀】伤害+1。",
	["ov_fenwu0"] = "奋武：你可以失去1点体力，视为使用一张【杀】",
	["$ov_fenwu1"] = "合围夷道，兵困吴贼！",
	["$ov_fenwu2"] = "纵兵摧城，奋武破敌",
	["ov_huchuquan"] = "呼厨泉",
	["#ov_huchuquan"] = "踞北桀鹰",
	["~ov_huchuquan"] = "久困汉庭，无力再叛",
	["ov_fupan"] = "复叛",
	[":ov_fupan"] = "当你造成或受到伤害后，你可以摸X张牌（X为伤害值），然后将一张牌交给一名其他角色，若为你第一次以此法交给其牌，则你摸2张牌；否则你可以对其造成1点伤害，然后你不能再以此法交给其牌。",
	["ov_fupan:ov_fupan0"] = "复叛：你可以对%src造成1点伤害，然后你不能再交给其牌",
	["$ov_fupan1"] = "胜者为王，吾等无话可说",
	["$ov_fupan2"] = "今乱平阳之地，汉人如何可防？！",
	["$ov_fupan3"] = "此为吾等，复兴匈奴之良机！",
	["ov_baoxin"] = "鲍信",
	["#ov_baoxin"] = "坚朴的忠相",
	["~ov_baoxin"] = "区区黄巾流寇，如何挡我？呃啊……",
	["ov_mutao"] = "募讨",
	[":ov_mutao"] = "出牌阶段限一次，你可以选择一名角色，令其将手牌中所有杀依次交给由其下家开始的每名角色，然后其对最后一名角色造成X点伤害（X为其手牌中的【杀】数且至多为3）。",
	["ov_mutao0"] = "募讨：请选择一张【杀】交给%src",
	["$ov_mutao1"] = "董贼暴乱，天下定当奋节讨之！",
	["$ov_mutao2"] = "募州郡义士，讨祸国逆贼！",
	["ov_yimou"] = "毅谋",
	[":ov_yimou"] = "你距离1以内的角色受到伤害后，你可以选择一项：1、其获得牌堆中的一张【杀】；2、其交给你选择的另一名角色一张手牌，然后摸2张牌。若其不为你，你可以背水：将所有手牌交给其。",
	["ov_yimou0"] = "毅谋：请选择一名%src交给手牌目标的角色",
	["ov_yimou01"] = "毅谋：请选择一张手牌交给%src",
	["ov_yimou1"] = "其获得牌堆中的一张【杀】",
	["ov_yimou2"] = "其交给你选择的另一名角色一张手牌",
	["ov_yimou3"] = "将所有手牌交给其",
	["$ov_yimou1"] = "今蓄士众之力，据其要害，贼可破之",
	["$ov_yimou2"] = "泰然若定，攻敌自溃！",
	["ov_yanxiang"] = "阎象",
	["#ov_yanxiang"] = "明尚夙达",
	["~ov_yanxiang"] = "若遇明主，或可，青史留名！",
	["ov_kujian"] = "苦谏",
	[":ov_kujian"] = "出牌阶段限一次，你可以将至多3张手牌交给一名其他角色，这些牌称为“谏”。当其使用或打出“谏”牌后，你与其各摸1张牌.当其不因使用或打出而从手牌中失去“谏”牌后，你与其各弃置一张牌。",
	["$ov_kujian1"] = "吾之所言，皆为公之大业！",
	["$ov_kujian2"] = "公岂徒有纳谏之名乎？",
	["$ov_kujian3"] = "明公虽奕世克昌，未若有周之盛",
	["ov_ruilian"] = "睿敛",
	[":ov_ruilian"] = "每轮开始时，你可以选择一名角色，其下个回合结束时，若其本回合弃置过不少于2张牌，你可以选择其中一种牌类型，你与其依次从弃牌堆中获得一张此类型的牌。",
	["ov_ruilian0"] = "睿敛：你可以选择一名角色",
	["$ov_ruilian1"] = "公若擅进庸肆，必失民心",
	["$ov_ruilian2"] = "外敛虚进之势，内减弊民之政",
	["ov_liyi"] = "李遗",
	["#ov_liyi"] = "伏被俞元",
	["~ov_liyi"] = "安南重任，万不可轻之",
	["ov_jiaohua"] = "教化",
	[":ov_jiaohua"] = "当你或体力值最小的其他角色摸牌后，你可以令之从牌堆或弃牌堆中获得一张此次未摸到的类型的牌（每回合每种类型限一次）。",
	["$ov_jiaohua2"] = "知礼数，崇王化，则民不复叛矣",
	["$ov_jiaohua1"] = "教民崇化，以定南疆",
	["ov_xiahoushang"] = "夏侯尚",
	["#ov_xiahoushang"] = "魏胤前驱",
	["~ov_xiahoushang"] = "陛下垂怜至此，臣，纵死无憾！",
	["ov_tanfeng"] = "探锋",
	[":ov_tanfeng"] = "准备阶段，你可以弃置一名其他角色区域里的一张牌，然后其选择一项：1、你对其造成1点火焰伤害，然后其令你跳过本回合的一个阶段；2、将一张牌当做【杀】对你使用。",
	["ov_tanfeng0"] = "探锋：你可以弃置一名其他角色区域里的一张牌",
	["ov_tanfeng01"] = "探锋：请选择一张牌当做【杀】对%src使用",
	["ov_tanfeng1"] = "受到%src的1点火焰伤害，然后令其跳过一个阶段",
	["ov_tanfeng2"] = "将一张牌当做【杀】对%src使用",
	["$ov_tanfeng2"] = "探锋之锐，以待进取之机！",
	["$ov_tanfeng1"] = "探敌薄防之地，夺敌不备之间",
	["ov_qiaorui"] = "桥蕤",
	["#ov_qiaorui"] = "穷勇技尽",
	["~ov_qiaorui"] = "曹贼....安敢犯仲国之威.....",
	["ov_xiawei"] = "狭威",
	[":ov_xiawei"] = "游戏开始时，你将牌堆中2张基本牌当做“威”置于武将牌上；你可以将“威”如手牌般使用或打出；回合开始时，你移去所有“威”。<br />妄行：准备阶段，你可以将牌堆顶X+1张牌当做“威”置于武将牌上。",
	["&ov_wei"] = "威",
	["$ov_xiawei1"] = "既闻仲帝威名，还不速速归降！",
	["$ov_xiawei2"] = "仲朝国土，岂容贼军放肆！",
	["ov_qongji"] = "穷技",
	[":ov_qongji"] = "锁定技，每回合限一次，你使用或打出“威”牌时，你摸一张牌；若你没有“威”，你受到的伤害+1。",
	["$ov_qongji1"] = "吾计虽穷，势不可衰！",
	["$ov_qongji2"] = "战在其势，何妨技穷？",
	["ov_xiahouen"] = "夏侯恩",
	["#ov_xiahouen"] = "长坂剑圣",
	["~ov_xiahouen"] = "长坂剑神…呃…也陨落了",
	["ov_fujian"] = "负剑",
	[":ov_fujian"] = "锁定技，游戏开始时或准备阶段，若你的装备区没有武器牌，你从牌堆中随机获得一张武器牌并置入装备区。当你于回合外失去武器牌后，你失去1点体力。",
	["$ov_fujian1"] = "得此宝剑，如虎添翼！",
	["$ov_fujian2"] = "丞相至宝，汝岂配用之？哇嚓啊！",
	["ov_jianwei"] = "剑威",
	[":ov_jianwei"] = "若你装备区有武器牌，你使用【杀】无视防具且拼点牌点数+X（X为你的攻击范围）。其他角色的准备阶段，其可以与你拼点；你的准备阶段，你可以与攻击范围内的一名角色拼点。若你以此法拼点赢，你获得其每个区域各一张牌；若你以此法拼点没赢，其获得你装备区的武器牌。",
	["ov_jianwei0"] = "剑威：你可以与攻击范围内的一名角色拼点",
	["ov_jianweibf0"] = "你可以与一名“剑威”角色拼点",
	["$ov_jianwei1"] = "小小匹夫，可否闻长坂剑神之名号！",
	["$ov_jianwei2"] = "此剑吹毛得过，削铁如泥！",
	["ov_xushu"] = "徐庶",
	["#ov_xushu"] = "仗剑为侠",
	["~ov_xushu"] = "天下为公……",
	["ov_jiange"] = "剑歌",
	[":ov_jiange"] = "每回合限一次，你可以将一张非基本牌当做【杀】使用或打出（无距离与次数限制）；若此时为你的回合外，你摸一张牌。",
	["$ov_jiange1"] = "纵剑为舞，击缶而歌！",
	["$ov_jiange2"] = "辞亲历山野，仗剑唱大风！",
	["ov_xiawang"] = "侠望",
	[":ov_xiawang"] = "你距离1以内的角色受到黑色牌的伤害后，你可以对来源使用一张【杀】；若此【杀】造成了伤害，则于结算后结束当前阶段。",
	["ov_xiawang0"] = "侠望：你可以对%src使用一张【杀】",
	["$ov_xiawang1"] = "天下兴亡，侠者当为之己任！",
	["$ov_xiawang2"] = "隐居江湖之远，敢争天下之先！",
	["ov_tongyuan"] = "童渊",
	["#ov_tongyuan"] = "凤鸣麟出",
	["~ov_tongyuan"] = "隐居山水，空老病榻",
	["ov_chaofeng"] = "朝凤",
	[":ov_chaofeng"] = "你可以将一张【杀】当做【闪】或将一张【闪】当做任意一种【杀】使用或打出。出牌阶段开始时，你可以与至多三名角色同时拼点；赢的角色视为对所有没赢的角色使用一张火【杀】。",
	["ov_chaofeng0"] = "朝凤：你可以与至多三名角色同时拼点",
	["$ov_chaofeng1"] = "枪出惊百鸟，技现震诸雄",
	["$ov_chaofeng2"] = "出如鸾凤高翱，收若百鸟归林",
	["ov_chuanshu"] = "传术",
	[":ov_chuanshu"] = "准备阶段，你可以选择一名角色，直到你下回合开始前：其拼点牌点数+3且使用下一张【杀】对其他角色造成的伤害+1，若其不为你，则此【杀】造成伤害时，你摸等同伤害值的牌。",
	["ov_chunshu0"] = "传术：你可以选择一名角色，直到你下回合开始前：其拼点牌点数+3且使用下一张【杀】对其他角色造成的伤害+1",
	["$ov_chuanshu1"] = "此术集百家之法，当传万世",
	["$ov_chuanshu2"] = "某虽无名于世，此术可传之万年！",
	["ov_liyan"] = "李彦",
	["#ov_liyan"] = "暴虎冯河",
	["~ov_liyan"] = "戾气入髓，不可再起杀心……",
	["ov_zhenhu"] = "震虎",
	[":ov_zhenhu"] = "当你使用伤害类牌指定目标后，你可以摸一张牌并与至多三名其他角色同时拼点；若你赢，此牌对没赢的角色造成的伤害+1；若你没赢，你失去1点体力。",
	["ov_zhenhu0"] = "震虎：请选择与至多三名其他角色同时拼点",
	["$ov_zhenhu1"] = "戟出势如虎，百兽尽皆服！",
	["$ov_zhenhu2"] = "横戟冲阵，敌纵为猛虎凶豺，亦不敢前！",
	["ov_lvren"] = "履刃",
	[":ov_lvren"] = "当你对其他角色造成伤害时，其获得“刃”标记；你使用伤害类牌可以额外指定一名有“刃”标记的角色并移去其“刃”标记，你拼点时，每有一名角色与你拼点，你的拼点牌点数+2。",
	["ov_lvren0"] = "履刃：你可以为此【%src】额外指定一名有“刃”标记的角色并移去其“刃”标记",
	["ov_ren"] = "刃",
	["$ov_lvren1"] = "坚甲厉刃，破之如鲁缟！",
	["$ov_lvren2"] = "攻城破阵，如履平地！",
	["ov_wangyue"] = "王越",
	["#ov_wangyue"] = "驭龙在天",
	["~ov_wangyue"] = "汉室中兴，不系于吾一人……",
	["ov_yulong"] = "驭龙",
	[":ov_yulong"] = "当你使用【杀】指定目标后，你可以与其中一名目标拼点。若你赢，此【杀】造成伤害则不计入次数，且根据拼点牌颜色获得效果：黑色，伤害+1；红色，不能被响应。",
	["ov_yulong0"] = "驭龙：你可以与此【杀】其中一名目标拼点",
	["$ov_yulong1"] = "三尺青锋，为君驭六龙，定九州！",
	["$ov_yulong2"] = "十年砺剑，当率千军之众，堪万夫之雄！",
	["ov_jianming"] = "剑鸣",
	[":ov_jianming"] = "锁定技，每回合每种花色限一次，当你使用或打出一种花色的【杀】时，你摸一张牌。",
	["$ov_jianming1"] = "弹剑作谱，鸣之铮铮。",
	["$ov_jianming2"] = "剑鸣凄凄，穿心刺骨！",
	["ov_chengpu"] = "程普",
	["ov_lihuo"] = "疠火",
	[":ov_lihuo"] = "你使用的普通【杀】可以改为火【杀】，结算后若此【杀】的伤害令其他角色进入过濒死状态，你失去1点体力；你使用火【杀】的目标+1。",
	["ov_lihuo0"] = "疠火：你可以为此火【杀】增加一个额外目标",
	["ov_chunlao"] = "醇醪",
	[":ov_chunlao"] = "准备阶段，若场上没有“醇”，你可以将一名角色区域内一张牌当做“醇”置于其武将牌旁。“醇”角色使用【杀】时可以交给你一张牌令此【杀】伤害+1；其进入濒死状态时，你可以移去“醇”并摸一张牌，然后其回复1点体力。",
	["ov_chunlao0"] = "醇醪：你可以将一名角色区域内一张牌当做“醇”置于其武将牌旁",
	["ov_chun"] = "醇",
	["ov_chunlaobf0"] = "你可以交给一名“醇醪”角色一张牌令此【杀】伤害+1",
	["ov_chunlaobf1"] = "醇醪：请选择一张牌交给%src",
	["ov_xujing"] = "许靖",
	["#ov_xujing"] = "篡贤取良",
	["ov_boming"] = "博名",
	[":ov_boming"] = "出牌阶段限两次，你可以将一张牌交给一名其他角色。结束阶段，若其他角色本回合获得的牌数大于等于2，你摸两张牌。",
	["ov_ejian"] = "恶荐",
	[":ov_ejian"] = "当其他角色获得你的牌后，若其有其他与此牌类型相同的牌，你可以令其选择一项：1、弃置这些牌，2、受到你的1点伤害。",
	["ov_ejian1"] = "弃置其他%sec",
	["ov_ejian2"] = "受到%src的1点伤害",
	["ov_simashi"] = "司马师",
	["ov_jinglve"] = "景略",
	[":ov_jinglve"] = "出牌阶段限一次，若场上没有“死士”牌，你可以观看一名角色的手牌并标记其中一张牌为“死士”。当其使用“死士”牌时，你令此牌无效；其回合结束时，若“死士”牌在牌堆、弃牌堆或任意角色区域内，你获得之。",
	["ov_shanli0"] = "擅立：请选择一名角色获得主公技“%src”",
	["ov_shanli"] = "擅立",
	[":ov_shanli"] = "觉醒技，准备阶段，若你已发动过“败移”且“景略”指定过至少两名角色，你扣减1点体力上限，然后从三个主公技中选择一个令一名角色获得之。",
	["ov_mazhong"] = "马忠",
	["ov_fuman"] = "抚蛮",
	[":ov_fuman"] = "出牌阶段每名角色限一次，你可以将一张手牌交给一名其他角色，令此牌视为【杀】。当其使用或打出此【杀】后，你摸一张牌；若此【杀】造成伤害，则改为摸两张牌。",
	["ov_niujin"] = "牛金",
	["ov_cuorui"] = "挫锐",
	[":ov_cuorui"] = "限定技，准备阶段，你可以将手牌摸至X张（X为场上最大手牌数，至多摸5张），然后废除判定区，若已废除则改为对一名其他角色造成1点伤害。",
	["ov_liewei"] = "裂围",
	[":ov_liewei"] = "锁定技，你杀死一名角色后选择一项：1、摸两张牌；2、令“挫锐”视为未发动过。",
	["ov_liewei1"] = "摸两张牌",
	["ov_liewei2"] = "令“挫锐”视为未发动过",
	["ov_jiling"] = "纪灵",
	["ov_shuangren"] = "双刃",
	[":ov_shuangren"] = "出牌阶段开始时，你可以与一名其他角色拼点。若你赢，你可以视为对其距离1以内的至多两名角色依次使用【杀】；若你没赢，其可以视为对你使用【杀】。出牌阶段结束时，若你本回合未发动过“双刃”且未使用【杀】造成伤害，你可以弃置一张牌并发动“双刃”。",
	["ov_shuangren0"] = "双刃：你可以与一名其他角色拼点",
	["ov_shuangren1"] = "双刃：你可以视为对%src距离1以内的至多两名角色依次使用【杀】",
	["ov_shuangren2"] = "你可以弃置一张牌并发动“双刃”",
	["ov_shuangren:ov_shuangren3"] = "双刃：你可以视为对%src使用【杀】",
	["ov_furong"] = "傅肜",
	["ov_xiewei"] = "血卫",
	[":ov_xiewei"] = "每轮限一次，其他角色出牌阶段开始时，你可以令其选择一项：1、本回合不能对你选择的另一名其他角色使用【杀】且手牌上限-2；2、视为你对其使用一张【决斗】。",
	["ov_xiewei1"] = "本回合不能对%src选择的另一名其他角色使用【杀】且手牌上限-2",
	["ov_xiewei2"] = "视为%src对你使用一张【决斗】",
	["ov_xiewei3"] = "血卫：请令一名其他角色本回合不能成为%src使用【杀】的目标",
	["ov_liechi"] = "烈斥",
	[":ov_liechi"] = "锁定技，当你受到伤害后，若你的体力值小于等于来源，你选择一项：1、令其将手牌弃至与你手牌相同；2、弃置其一张牌。若你本回合进入过濒死状态，你可以背水：弃置一张装备牌。",
	["ov_liechi1"] = "令%src将手牌弃至与你手牌相同",
	["ov_liechi2"] = "弃置%src一张牌",
	["ov_liechi3"] = "弃置一张装备牌",
	["ov_liechi0"] = "烈斥：请弃置一张装备牌",
	["ov_chenwudongxi"] = "陈武&董袭",
	["&ov_chenwudongxi"] = "陈武董袭",
	["ov_fenming"] = "奋命",
	[":ov_fenming"] = "准备阶段，你可以选择一名角色，并选择一项：1、令其弃置一张牌；2、令其横置。背水：你横置。",
	["ov_fenming0"] = "奋命：你可以选择一名角色",
	["ov_fenming1"] = "令%src弃置一张牌",
	["ov_fenming2"] = "令%src横置",
	["ov_fenming3"] = "你横置",
	["ov_wangling"] = "王凌",
	["#ov_wangling"] = "风节格尚",
	["~ov_wangling"] = "一生尽忠事魏，不料，今日晚节尽毁啊！",
	["ov_mibei"] = "秘备",
	[":ov_mibei"] = "使命技，使用每种类别的牌各两张。成功》你获得技能“谋立”；失败》出牌阶段结束时，若你本回合未使用过牌，则你本回合手牌上限-1并复原此技能。",
	["$ov_mibei1"] = "秘为之备，不可有失",
	["$ov_mibei2"] = "事以秘成，语以泄败！",
	["ov_xingqi"] = "星启",
	[":ov_xingqi"] = "觉醒技，准备阶段，若场上的牌数大于你的体力值，你回复1点体力，然后若“秘备”：未完成，你从牌堆中获得每种类别的牌各一张；已完成，本局你使用牌无距离限制。",
	["$ov_xingqi1"] = "司马氏虽权尊势重，吾等徐图亦无不可",
	["$ov_xingqi2"] = "先谋后事者昌，先事后谋者亡",
	["ov_mouli"] = "谋立",
	[":ov_mouli"] = "每回合限一次，当你需要使用一种基本牌时，你可以使用牌堆中对应的牌。",
	["$ov_mouli1"] = "僭孽为害，吾岂可谋而不行？",
	["$ov_mouli2"] = "澄汰王室，迎立宗子",
	["ov_madai"] = "马岱",
	["ov_qianxi"] = "潜袭",
	[":ov_qianxi"] = "准备阶段，你可以摸一张牌，然后弃置一张牌，令距离为1的一名角色本回合不能使用或打出与此牌颜色相同的手牌。结束阶段，若你本回合使用【杀】对其造成过伤害，其不能使用或打出另一种颜色的牌，直到其下回合结束。",
	["ov_qianxi0"] = "潜袭：请选择令距离为1的一名角色本回合不能使用或打出%src手牌",
	["ov_fazheng"] = "法正",
	["ov_enyuan"] = "恩怨",
	[":ov_enyuan"] = "当你获得一名其他角色至少两张牌后，你可以令其摸一张牌；若其手牌区或装备区没有牌，你可以改为令其回复1点体力。当你受到1点伤害后，你可以令来源选择交给你一张手牌或失去1点体力；若交出的牌不为♥，你摸一张牌。",
	["ov_enyuan0"] = "恩怨：你可以交给%src一张手牌，否则失去1点体力",
	["ov_enyuan:ov_enyuan1"] = "恩怨：你可以改为令%src回复1点体力",
	["ov_xuanhuo"] = "眩惑",
	[":ov_xuanhuo"] = "摸阶段结束时，你可以交给一名其他角色两张牌，令其选择一项：1、视为对你选择的另一名角色使用【杀】或【决斗】；2、你获得其两张牌。",
	["ov_xuanhuo0"] = "眩惑：你可以交给一名其他角色两张牌",
	["ov_xuanhuo:ov_xuanhuo1"] = "视为对%src选择的%arg使用【杀】或【决斗】",
	["ov_xuanhuo:ov_xuanhuo2"] = "%src获得你两张牌",
	["ov_xuanhuo3"] = "眩惑：请选择一名角色成为%src使用【杀】或【决斗】的目标",
	["ov_sunluban"] = "孙鲁班",
	["ov_zenhui"] = "谮毁",
	[":ov_zenhui"] = "出牌阶段限一次，当你使用【杀】或黑色普通锦囊牌指定唯一目标时，你可以选择能成为此牌目标的另一名角色，并选择一项：获得其区域内一张牌，其代替你成为此牌的使用者；2、令其成为此牌额外目标。",
	["ov_zenhui0"] = "谮毁：你可以选择能成为此【%src】目标的另一名角色",
	["ov_zenhui1"] = "代替使用",
	["ov_zenhui2"] = "额外目标",
	["ov_jiaojin"] = "骄矜",
	[":ov_jiaojin"] = "当你受到男性角色的伤害时，你可以弃置一张非基本牌，然后防止此伤害。",
	["ov_jiaojin0"] = "骄矜：你可以弃置一张非基本牌，然后防止此伤害",
	["ov_caohong"] = "曹洪",
	["ov_yuanhu"] = "援护",
	[":ov_yuanhu"] = "出牌阶段限一次，你可以将一张装备牌置于一名角色的装备区里，若此牌为：武器牌，你弃置其距离为1的一名角色区域内一张牌；防具牌，其摸一张牌；坐骑牌或宝物牌，其回复1点体力。若其手牌数或体力值小于等于你，你摸一张牌，且可以于本回合结束阶段再发动此技能。",
	["ov_yuanhu0"] = "你可以再次发动“援护”",
	["ov_yuanhu1"] = "援护：请选择弃置%src距离为1的一名角色区域内一张牌",
	["ov_juezhu"] = "决助",
	[":ov_juezhu"] = "限定技，准备阶段，你可以废除一个坐骑栏，令一名角色获得技能“飞影”并废除其判定区，其死亡后，你恢复已此法废除的坐骑栏。",
	["ov_juezhu0"] = "决助：请选择令一名角色获得技能“飞影”并废除其判定区",
	["$ov_juezhu1"] = "曹君速速上马，洪自断后",
	["$ov_juezhu2"] = "天下可无洪，不可无君",
	["ov_zhanhe"] = "星张郃",
	["#ov_zhanhe"] = "宁国中郎将",
	["ov_zhilve"] = "知略",
	[":ov_zhilve"] = "准备阶段，你可以选择一项：1、移动场上一张牌，然后若此牌为：装备牌，你失去1点体力；延时锦囊牌，你本回合手牌上限-1；2、本回合你于摸牌阶段额外摸一张牌，使用第一张【杀】无距离限制且不计入次数。",
	["ov_zhilve1"] = "移动场上一张牌",
	["ov_zhilve2"] = "摸牌阶段额外摸一张牌，使用第一张【杀】无距离限制且不计入次数",
	["ov_guanqiujian"] = "毌丘俭",
	["ov_zhengrong"] = "征荣",
	[":ov_zhengrong"] = "你于出牌阶段对其他角色使用累计偶数张牌后，或于出牌阶段第一次造成伤害后，你可以将一名其他角色的一张牌当做“荣”置于你的武将牌上。",
	["ov_zhengrong0"] = "征荣：你可以将一名其他角色的一张牌当做“荣”置于你的武将牌上",
	["ov_hongju"] = "鸿举",
	[":ov_hongju"] = "觉醒技，准备阶段，若你的“荣”数不小于3，你摸等同“荣”数的牌，并将任意手牌替换等量的“荣”，获得技能“清侧”，然后选择是否减1点体力上限并获得技能“扫讨”。",
	["@ov_hongju0"] = "鸿举：你可以将任意手牌替换等量的“荣”",
	["ov_hongju:ov_hongju1"] = "鸿举：你可以减1点体力上限并获得“扫讨”",
	["ov_qingce"] = "清侧",
	[":ov_qingce"] = "出牌阶段，你可以移去一张“荣”，然后弃置一名其他角色区域内的一张牌。",
	["ov_saotao"] = "扫讨",
	[":ov_saotao"] = "锁定技，你使用【杀】和普通锦囊牌不能被响应。",
	["ov_fanchou"] = "樊稠",
	["ov_xingluan"] = "兴乱",
	[":ov_xingluan"] = "结束阶段，你可以亮出牌堆顶6张牌，然后将其中一种类型的牌交给任意名角色（每名角色至多3张）；以此法获得牌数大于等于你的角色各失去1点体力。",
	["ov_xingluan0"] = "兴乱：请选择亮出牌中一种类型的牌任意交给一名角色（每名角色至多3张）",
	["#ov_xingluan"] = "亮出牌",
	["ov_zhugeguo"] = "诸葛果",
	["ov_qirang"] = "祈禳",
	[":ov_qirang"] = "当有牌进入你的装备区后，你可以从牌堆中获得一张锦囊牌，此阶段你使用此牌无距离限制、不能响应且可增加或减少一个目标。",
	["ov_qirang0"] = "祈禳：你可以为此【%src】增加或减少一个目标",
	["ov_qirang1"] = "%dest：请为%src指定【借刀杀人】使用【杀】的目标",
	["ov_yuhua"] = "羽化",
	[":ov_yuhua"] = "锁定技，弃牌阶段内，非基本牌不计入你的手牌上限。你于回合外失去非基本牌后，你可以观看牌堆顶X张牌并将这些牌任意置于牌堆顶和牌堆底，然后你可以摸X张牌（X为你此次失去的牌数，至多为5）。",
	["$ov_qirangTarget"] = "%from 为此 %card %arg了目标 %to",
	["Target+"] = "增加",
	["Target-"] = "减少",
	["Target="] = "修改",
	["ov_zhangfei"] = "张飞",
	["ov_xuhe"] = "虚吓",
	[":ov_xuhe"] = "当你使用【杀】被目标使用【闪】抵消时，你可以令其选择一项：1、受到你造成的1点伤害；2、令你本回合使用的下一张牌对其造成的伤害+2。",
	["ov_xuhe1"] = "受到%src造成的1点伤害",
	["ov_xuhe2"] = "%src本回合使用的下一张牌对你造成的伤害+2",
	["ov_shenguanyu"] = "神关羽",
	["ov_wushen"] = "武神",
	[":ov_wushen"] = "锁定技，你每阶段使用首张【杀】不能响应；你的♥手牌视为【杀】；你使用♥【杀】无距离次数限制，且额外指定所有“梦魇”角色为目标。",
	["$ov_wushenTarget"] = "%from 为此 %arg2{%card} %arg了目标 %to",
	["ov_wuhun"] = "武魂",
	[":ov_wuhun"] = "锁定技，当你受到其他角色的1点伤害后，或对“梦魇”角色造成伤害后，其获得1枚“梦魇”标记。你死亡时，你选择是否判定，若结果不为【桃】或【桃园结义】，你令至少一名“梦魇”角色失去等同其“梦魇”数的体力。",
	["ov_wuhun0"] = "武魂：请选择至少一名“梦魇”角色",
	["ov_feiyi"] = "费祎",
	["#ov_feiyi"] = "洞世权相",
	["ov_shengxi"] = "生息",
	[":ov_shengxi"] = "准备阶段，你可以从游戏外、牌堆中或弃牌堆中获得一张【调剂盐梅】。结束阶段，若你本回合使用过牌且未造成伤害，你可以获得一张智囊并摸一张牌。",
	["ov_kuanji"] = "宽济",
	[":ov_kuanji"] = "每回合限一次，当你的牌不因使用而置入弃牌时，你可以令一名其他角色获得其中任意张牌。",
	["ov_kuanji0"] = "宽济：你可以选择令一名其他角色获得其中任意张牌",
	["_ov_tiaojiyanmei"] = "调剂盐梅",
	[":_ov_tiaojiyanmei"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：两名手牌数不同的角色<br /><b>效果</b>：手牌数较多的目标弃置一张牌，手牌数较少的目标摸一张牌。<br /><b>额外效果</b>：然后若这两名角色手牌数相同，你可以将以此法弃置的牌交给一名角色。<br /><b>重铸</b>：出牌阶段，你可以将此牌置入弃牌堆，然后摸一张牌。",
	["_ov_tiaojiyanmei0"] = "调剂盐梅：你可以将这些牌交给一名角色",
	["ov_tiaojiyanmei"] = "调剂盐梅",
	["ov_feiyi_card"] = "费祎专属",
	["$ov_tiaojiyanmeiChosen"] = "%to 的手牌数为 %arg 结果为 %arg2",
	["HandcardNum="] = "均相同",
	["HandcardNum~"] = "有不同",
	["ov_qiaogong"] = "桥公",
	["#ov_qiaogong"] = "高风朔望",
	["~ov_qiaogong"] = "为父所念，唯汝二人啊.....",
	["ov_yizhu"] = "遗珠",
	[":ov_yizhu"] = "结束阶段，你摸两张牌，然后将两张牌随机置于牌堆顶2X张牌中（X为角色数）。当其他角色使用“遗珠”牌指定唯一目标时，你可以为此牌修改或增加一个目标，并摸一张牌。",
	["ov_yizhu0"] = "遗珠：请选择两张牌随机置于牌堆顶%src张牌中",
	["ov_yizhu1"] = "遗珠:你可以为此【%src】修改或增加一个目标",
	["ov_yizhu2"] = "修改目标",
	["ov_yizhu3"] = "增加目标",
	["$ov_yizhu1"] = "将军若得遇小女，万望护送而归",
	["$ov_yizhu2"] = "老夫有二女，视之如明珠",
	["ov_luanchou"] = "鸾俦",
	[":ov_luanchou"] = "出牌阶段限一次，你可以令两名角色获得“共患”，直到你再次发动此技能。",
	["$ov_luanchou1"] = "夫妻相濡以沫，方可百年偕老",
	["$ov_luanchou2"] = "愿汝永结鸾俦，以期共盟鸳蝶",
	["ov_gonghuan"] = "共患",
	[":ov_gonghuan"] = "每回合限一次，另一名“共患”角色受到伤害时，若其体力值小于等于你，你可以将此伤害转移给你。",
	["ov_shenlvmeng"] = "神吕蒙",
	["ov_shelie"] = "涉猎",
	[":ov_shelie"] = "摸牌阶段，你可以改为亮出牌堆顶5张牌，获得其中每种花色各一张。每轮限一次，回合结束时，若你本回合使用过的花色数大于等于你的体力值，你获得一个额外的摸牌阶段或出牌阶段。",
	["ov_gongxin"] = "攻心",
	[":ov_gongxin"] = "出牌阶段限一次，你可以观看一名其他角色的手牌，然后你可以展示其中一张牌，置于牌堆顶或弃置之。若其手牌中花色数因此减少，你可以令其本回合不能使用或打出一种颜色的牌。", 
	["ov_gongxin1"] = "置于牌堆顶",
	["ov_gongxin2"] = "弃置之",
	["ov_weixu"] = "魏续",
	["#ov_weixu"] = "缚陈降曹",
	["~ov_weixu"] = "颜良小儿，竟杀我同伴！看我为其......唔啊！",
	["ov_suizheng"] = "随征",
	[":ov_suizheng"] = "锁定技，游戏开始时，你选择一名其他角色。当其造成伤害后，你摸一张牌；当其受到伤害后，你需弃置两张基本牌并令其回复1点体力，否则你失去1点体力并令其获得一张【杀】或【决斗】。",
	["ov_suizheng0"] = "随征：请选择一名其他角色",
	["ov_suizheng1"] = "随征：你需弃置两张基本牌并令%src回复1点体力，否则将失去1点体力",
	["$ov_suizheng1"] = "续得将军器重，愿随将军出征！",
	["$ov_suizheng2"] = "将军莫慌，万事有吾！",
	["$ov_suizheng3"] = "吾与将军有亲，哼！尔等岂可与我相比？",
	["ov_tuidao"] = "颓盗",
	[":ov_tuidao"] = "限定技，准备阶段，若“随征”角色的体力值小于等于2/已死亡，你可以废除你与其一个坐骑栏并选择一个牌类型，获得其所有该类型的牌/从牌堆中获得两张该类别的牌，然后选择另一名角色为新的“随征”角色并令其获得这些牌。",
	["ov_tuidao0"] = "颓盗：请选择一名其他角色为新的“随征”角色",
	["$ov_tuidao1"] = "将军大势已去，续无可奈何啊",
	["$ov_tuidao2"] = "续投明主，还望将军勿怪才是",
	["ov_haomeng"] = "郝萌",
	["ov_gongge"] = "攻阁",
	[":ov_gongge"] = "摧坚：你可以选择一项：1、摸X+1张牌，其响应此牌后你跳过下一个摸牌阶段;2、弃置其X+1张牌，结算后若其体力值大于等于你，你交给其X张牌；3、此牌对其造成伤害+X，结算后，其回复X点体力。",
	["ov_gongge0"] = "攻阁：你可以选择一名目标角色摧坚",
	["ov_gongge01"] = "攻阁：请选择%src张牌交给%dest",
	["ov_gongge1"] = "摸%src张牌",
	["ov_gongge2"] = "弃置其%src张牌",
	["ov_gongge3"] = "此牌对其造成伤害+%src",
	["ov_gonggedebf"] = "跳过摸牌",
	["ov_caoxiu"] = "曹休",
	["ov_qianju"] = "千驹",
	[":ov_qianju"] = "锁定技，你计算与其他角色的距离-X（X为你装备区牌数）。每回合限一次，当你对距离1以内的角色造成伤害后，你从牌堆或弃牌堆将一张空置装备栏对应的牌置入装备区。",
	["ov_qingxi"] = "倾袭",
	[":ov_qingxi"] = "当你每回合使用的第一张【杀】指定目标后，你可以令目标选择一项：1、你摸X张牌（X为你装备区牌数且至少为1），此【杀】不能被其响应；2、弃置装备区所有牌，然后弃置你装备区等量的牌，此【杀】伤害+1。",
	["ov_qingxi1"] = "%src摸%arg张牌，你不能响应此【杀】",
	["ov_qingxi2"] = "弃置装备区所有牌，然后弃置%src装备区等量的牌，此【杀】伤害+1",
	["ov_sunyi"] = "孙翊",
	["#ov_sunyi"] = "骄悍激躁",
	["~ov_sunyi"] = "叛我贼子，虽死亦不饶之！",
	["ov_zaoli"] = "躁厉",
	[":ov_zaoli"] = "锁定技，出牌阶段，你只能使用或打出本回合内获得的手牌。出牌阶段开始时，你弃置区域内所有装备牌和任意牌，摸等量的牌，然后从牌堆中将相同副类别的装备牌置入装备区；若你置入了多于2张牌，你失去1点体力。",
	["ov_zaoli0"] = "躁厉：你可以选择弃置区域内任意牌",
	["$ov_zaoli1"] = "喜怒不行于色，诈伪要名之徒！",
	["$ov_zaoli2"] = "摇唇鼓舌，竖子是之也！",
	["ov_guohuai"] = "郭淮",
	["ov_jingce"] = "精策",
	[":ov_jingce"] = "当你于出牌阶段使用第X张牌后（X为你的体力值），你可以摸等量的牌；若你此阶段已摸过牌或本回合已造成过伤害，你获得1枚“策”标记。",
	["ov_jingceCE"] = "策",
	["ov_yuzhang"] = "御嶂",
	[":ov_yuzhang"] = "你可以弃置1枚“策”并跳过一个阶段。当你受到伤害后，你可以弃置1枚“策”并选择一项令来源执行：1、本回合不能再使用或打出手牌；2、弃置两张牌。",
	["ov_yuzhang:ov_yuzhang"] = "御嶂：你可以弃置1枚“策”并跳过 %src",
	["ov_yuzhang1"] = "%src本回合不能再使用或打出手牌",
	["ov_yuzhang2"] = "%src弃置两张牌",
	["$ov_yuzhang1"] = "吾已料敌布防，蜀军休想进犯",
	["$ov_yuzhang2"] = "诸君依策行事，定保魏境无虞",
	["ov_zhouchu"] = "周处",
	["#ov_zhouchu"] = "英情天逸",
	["~ov_zhouchu"] = "改励自砥，誓除三害.....",
	["ov_guoyi"] = "果毅",
	[":ov_guoyi"] = "当你使用【杀】或普通锦囊牌指定一名其他角色为目标后，若其的体力值或手牌数为全场最高，或你的手牌数不大于X（X为你已损失的体力值+1），你可以令其选择一项：1、本回合不能使用或打出手牌，2、弃置X张牌。若条件均满足或其本回合两个选项均已选择，则此牌连续结算两次。",
	["$ov_guoyi1"] = "心怀远志，何愁声名不彰！",
	["$ov_guoyi2"] = "从今始学，成为有用之才！",
	["ov_chuhai"] = "除害",
	[":ov_chuhai"] = "使命技：令两名其他角色进入濒死状态。成功：当前回合结束时，废除你的判定区，然后每名其他角色依次交给你一张牌；完成前：其他角色交给你牌时，须将其中一张置入弃牌堆。",
	["$ov_chuhai1"] = "有我在此，安敢为害？！",
	["$ov_chuhai2"] = "小小孽畜，还不伏诛？！",
	["$ov_chuhai3"] = "此番不成，明日再战!",
	["ov_guoyi0"] = "果毅：你可以弃置%src张牌，否则此回合不能使用或打出手牌",
	["ov_chuhai0"] = "除害：请选择弃置获得牌中的一张牌",
	["ov_chuhai1"] = "除害：请选择将一张牌交给%src",
}

return {extension}