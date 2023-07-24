extension = sgs.Package("jilebao")
extensioncard = sgs.Package("jile_card",sgs.Package_CardPack)
--极乐包：致力打造朴实（缝合）的武将（阴间）
--制作：Lua学生
--（一部分图片来自网络；感谢三国杀吧主 BOBO 大神的前瞻制作）

kingdom_yao = false
hidden = true


jl_sandazhugong = sgs.General(extension,"jl_sandazhugong$","god",4)
jl_sandazhugong:addSkill("nosjianxiong")
jl_sandazhugong:addSkill("nosrende")
jl_sandazhugong:addSkill("zhiheng")
function hasToGenerals(player)
	for _,p in sgs.list(player:getAliveSiblings())do
		if p:getKingdom()=="wei"
    	or p:getKingdom()=="shu"
    	or p:getKingdom()=="wu"
		then return true end
	end
	return false
end
jl_zhugongCard = sgs.CreateSkillCard{
	name = "jl_zhugongCard",
	filter = function(self,targets,to_select,from)
		local pattern = self:getUserString()
		if pattern==""
		then pattern = "slash"
		elseif string.find(pattern,"jink")
		then return false end
		return SCfilter(pattern,targets,to_select)
	end,
	feasible = function(self,targets)
		local pattern = self:getUserString()
		if pattern==""
		then pattern = "slash"
		elseif string.find(pattern,"jink")
		then return true end
		return SCfeasible(pattern,targets)
	end,
	on_validate = function(self,use)
		local from = use.from
		local room = from:getRoom()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local plist = sgs.SPlayerList()
		for _,p in sgs.list(room:getOtherPlayers(from))do
	    	if p:getKingdom()=="wei"
        	or p:getKingdom()=="shu"
        	or p:getKingdom()=="wu"
    		then plist:append(p) end
		end
		NotifySkillInvoked("jl_zhugong",from,plist)
		if string.find(pattern,"jink")
		then
        	room:broadcastSkillInvoke("hujia")--播放配音
	    	pattern = "jink"
		else
        	room:broadcastSkillInvoke("jijiang")--播放配音
	    	pattern = "slash"
		end
 		for _,p in sgs.list(plist)do
    		local c = "@jl_zhugong-card:"..from:objectName()..":"..pattern
    		c = room:askForCard(p,pattern,c,ToData(from),sgs.Card_MethodResponse,from)
    		if c
			then
				if c:isVirtualCard()
				then
					c:setSkillName("jl_zhugong")
				end
				return c
			end
		end
		room:setPlayerFlag(from,"nojl_zhugong")
	end,
	on_validate_in_response = function(self,from)
		local room = from:getRoom()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local plist = sgs.SPlayerList()
		for _,p in sgs.list(room:getOtherPlayers(from))do
	    	if p:getKingdom()=="wei"
        	or p:getKingdom()=="shu"
        	or p:getKingdom()=="wu"
    		then plist:append(p) end
		end
		NotifySkillInvoked("jl_zhugong",from,plist)
		if string.find(pattern,"jink")
		then
        	room:broadcastSkillInvoke("hujia")--播放配音
	    	pattern = "jink"
		else
        	room:broadcastSkillInvoke("jijiang")--播放配音
	    	pattern = "slash"
		end
 		for _,p in sgs.list(plist)do
    		local c = "@jl_zhugong-card:"..from:objectName()..":"..pattern
    		c = room:askForCard(p,pattern,c,ToData(from),sgs.Card_MethodResponse,from)
    		if c
			then
				if c:isVirtualCard()
				then
					c:setSkillName("jl_zhugong")
				end
				return c
			end
		end
		room:setPlayerFlag(from,"nojl_zhugong")
	end
}
jl_zhugongVS = sgs.CreateViewAsSkill{
	name = "jl_zhugong$",
	view_as = function()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = jl_zhugongCard:clone()
		c:setUserString(pattern)
		return c
	end,
	enabled_at_play = function(self,player)
		return hasToGenerals(player)
	    and player:hasLordSkill("jl_zhugong")
		and sgs.Slash_IsAvailable(player)
	end,
	enabled_at_response = function(self,player,pattern)
		return hasToGenerals(player)
	    and player:hasLordSkill("jl_zhugong")
	    and (string.find(pattern,"slash")
		or string.find(pattern,"jink")
		or pattern=="@jl_zhugong")
		and not player:hasFlag("nojl_zhugong")
	end
}
jl_zhugong = sgs.CreateTriggerSkill{
	name = "jl_zhugong$",
	events = {sgs.TargetConfirmed,sgs.PreHpRecover},
	view_as_skill = jl_zhugongVS,
	can_trigger = function(self,target)
		return target and target:hasLordSkill(self)
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	room:setPlayerFlag(player,"-nojl_zhugong")
		if event==sgs.TargetConfirmed
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Peach")
			and player:objectName()~=use.from:objectName()
			then
				if use.from:getKingdom()=="wei"
				or use.from:getKingdom()=="shu"
				or use.from:getKingdom()=="wu"
				then
					room:setCardFlag(use.card,"jl_zhugong")
				end
			end
		elseif event==sgs.PreHpRecover
		then
			local rec = data:toRecover()
			if rec.card
			and rec.card:hasFlag("jl_zhugong")
			then
				room:setCardFlag(rec.card,"-jl_zhugong")
                room:sendCompulsoryTriggerLog(player,self:objectName())
             	room:broadcastSkillInvoke("jiuyuan")--播放配音
				rec.recover = rec.recover+1
				data:setValue(rec)
			end
		end
	end,
}
jl_sandazhugong:addSkill(jl_zhugong)

jl_sizhugong = sgs.General(extension,"jl_sizhugong$","qun",8)
jl_sizhugong:addSkill("huangtian")
jl_sizhugong:addSkill("xueyi")
jl_sizhugong:addSkill("baonue")
jl_sizhugong:addSkill("weidi")
jl_sizhugong:addSkill("yongsi")

jl_sanyuanse = sgs.General(extension,"jl_sanyuanse","god",5)
jl_sanyuanse:addSkill("nosbuqu")
jl_sanyuanse:addSkill("kuanggu")
jl_sanyuanse:addSkill("nosjushou")

jl_wuhujiang = sgs.General(extension,"jl_wuhujiang","shu")
jl_wuhujiang:addSkill("wusheng")
jl_wuhujiang:addSkill("paoxiao")
jl_wuhujiang:addSkill("longdan")
jl_wuhujiang:addSkill("nostieji")
jl_wuhujiang:addSkill("liegong")

jl_wuzijiang = sgs.General(extension,"jl_wuzijiang","wei")
jl_wuzijiang:addSkill("yizhong")
jl_wuzijiang:addSkill("nostuxi")
jl_wuzijiang:addSkill("qiaobian")
jl_wuzijiang:addSkill("xiaoguo")
jl_wuzijiang:addSkill("duanliang")

jl_wuguogai = sgs.General(extension,"jl_wuguogai","wu")
jl_wuguogai:setGender(sgs.General_Neuter)
jl_wuguogai:addSkill("noskurou")
jl_wuguogai:addSkill("buyi")

jl_yuxun = sgs.General(extension,"jl_yuxun","wu",3)
jl_yuxun:addSkill("nosguhuo")
jl_yuxun:addSkill("noslianying")

jl_zhenjiao = sgs.General(extension,"jl_zhenjiao","qun",3,false)
jl_zhenjiao:setGender(sgs.General_Neuter)
jl_zhenjiao:addSkill("luoshen")
jl_zhenjiao:addSkill("guidao")

jl_simaji = sgs.General(extension,"jl_simaji","wei",3)
jl_simaji:setGender(sgs.General_Neuter)
jl_simaji:addSkill("nosguicai")
jl_simaji:addSkill("luoshen")

jl_dengren = sgs.General(extension,"jl_dengren","wei")
--jl_dengren:addSkill("zhenggong")
jl_zhenggong = sgs.CreateTriggerSkill{
	name = "jl_zhenggong",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TurnStart,sgs.EventPhaseChanging},
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
		then
    		local change = data:toPhaseChange()
            if change.to==sgs.Player_NotActive
			and player:hasFlag("jl_zhenggong")
			then player:turnOver() player:setFlags("-jl_zhenggong") end
		else
	      	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
		    	if owner:faceUp() and player:objectName()~=owner:objectName()
		    	and owner:askForSkillInvoke(self:objectName())
		    	then
	            	room:broadcastSkillInvoke("zhenggong")--播放配音
			    	owner:setFlags("jl_zhenggong")
					owner:gainAnExtraTurn()
		    	end
	    	end
		end
		return false
	end,
}
jl_dengren:addSkill(jl_zhenggong)
jl_dengren:addSkill("nosjushou")

jl_zgyy = sgs.General(extension,"jl_zgyy","shu",3)
jl_zgyy:setGender(sgs.General_Neuter)
jl_zgyy:addSkill("huoji")
jl_zgyy:addSkill("kanpo")
jl_zgyy:addSkill("nosjizhi")

jl_wumeinv = sgs.General(extension,"jl_wumeinv","god",3,false)
jl_qingshenVS = sgs.CreateOneCardViewAsSkill{
	name = "jl_qingshen",
	filter_pattern = ".|black|.|hand",
	response_or_use = true,
	enabled_at_response = function(self,player,pattern)
		return string.find(pattern,"jink")
	end,
	enabled_at_play = function()
		return false
	end,
	view_as = function(self,card) 
		local jink = sgs.Sanguosha:cloneCard("jink")
		jink:setSkillName(self:objectName())
		jink:addSubcard(card)
		return jink
	end
}
jl_qingshen = sgs.CreateTriggerSkill{
	name = "jl_qingshen",
--	frequency = sgs.Skill_Frequent,
	view_as_skill = jl_qingshenVS,
	events = {sgs.EventPhaseStart,sgs.FinishJudge},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.EventPhaseStart
		and player:getPhase()==sgs.Player_Start
		then
			while player:askForSkillInvoke(self:objectName())do
	         	room:broadcastSkillInvoke("luoshen")--播放配音
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|black"
				judge.good = true
				judge.reason = self:objectName()
				judge.who = player
				judge.time_consuming = true
				room:judge(judge)
				if judge:isBad()
				then break end
			end
		elseif event==sgs.FinishJudge
		then
			local judge = data:toJudge()
			if judge.reason==self:objectName()
			then
				if judge.card:isBlack()
				then
					player:obtainCard(judge.card)
				end
			end
		end
		return false
	end
}
jl_wumeinv:addSkill(jl_qingshen)
jl_liyueCard = sgs.CreateSkillCard{
	name = "jl_liyueCard",
	filter = function(self,targets,to_select,source)
		if not to_select:isMale()
		then return false end
		local duel = sgs.Sanguosha:cloneCard("duel")
		duel:deleteLater()
		if #targets<1
		and to_select:isProhibited(to_select,duel)
		then return false
		elseif #targets==1
		and to_select:isCardLimited(duel,sgs.Card_MethodUse)
		then return false end
		duel = {"jl_liyue+duel+from","jl_liyue+duel+to"}
        AddSelectShownMark(targets,duel)
		return #targets<2
	end,
	feasible = function(self,targets)
		return #targets>1
	end,
	about_to_use = function(self,room,use)
		local from = use.to:at(0)
		local to = use.to:at(1)
        local duel = {"jl_liyue+duel+from","jl_liyue+duel+to"}
        AddSelectShownMark({},duel,sgs.Self)
		self:cardOnUse(room,use)
		duel = sgs.Sanguosha:cloneCard("duel")
		duel:setSkillName("_jl_liyue")
		if not from:isCardLimited(duel,sgs.Card_MethodUse)
		and not from:isProhibited(to,duel)
		then room:useCard(sgs.CardUseStruct(duel,from,to))
		else duel:deleteLater() end
	end,
	on_use = function(self,room,source,targets)
	   	room:broadcastSkillInvoke("lijian")--播放配音
	end
}
jl_liyueVS = sgs.CreateOneCardViewAsSkill{
	name = "jl_liyue",
	filter_pattern = ".!",
	view_as = function(self,card)
		local lijian_card = jl_liyueCard:clone()
		lijian_card:addSubcard(card:getEffectiveId())
		return lijian_card
	end,
	enabled_at_play = function(self,player)
		return player:canDiscard(player,"he") and not player:hasUsed("#jl_liyueCard") and player:getAliveSiblings():length()>1
	end
}
jl_liyue = sgs.CreatePhaseChangeSkill{
	name = "jl_liyue",
--	frequency = sgs.Skill_Frequent,
	view_as_skill = jl_liyueVS,
	on_phasechange = function(self,player)
		if player:getPhase()==sgs.Player_Finish
		then
			local room = player:getRoom()
			if room:askForSkillInvoke(player,self:objectName())
			then
	        	room:broadcastSkillInvoke("biyue")--播放配音
				player:drawCards(1,self:objectName())
			end
		end
		return false
	end
}
jl_wumeinv:addSkill(jl_liyue)
jl_liuseCard = sgs.CreateSkillCard{
	name = "jl_liuseCard",
	filter = function(self,targets,to_select,player)
		return to_select:hasFlag("liuse")
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
		local new = sgs.QVariant()
		new:setValue(targets[1])
		room:setTag("jl_liuse",new)
	   	room:broadcastSkillInvoke("liuli")--播放配音
	end
}
jl_liuseVS = sgs.CreateViewAsSkill{
	name = "jl_liuse",
	n = 1,
	view_filter = function(self,selected,to_select)
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern~=""
		then
        	return not to_select:isEquipped()
		end
       	return to_select:getSuitString()=="diamond"
	end,
	enabled_at_response = function(self,player,pattern)
		return pattern=="@@jl_liuse"
	end,
	enabled_at_play = function(self,player)
		return not player:isNude()
	end,
	view_as = function(self,cards)
	   	if #cards<1 then return end
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern==""
		then
        	pattern = sgs.Sanguosha:cloneCard("indulgence")
	    	pattern:setSkillName("jl_liuse")
		else
	    	pattern = jl_liuseCard:clone()
		end
		pattern:addSubcard(cards[1])
		return pattern
	end
}
jl_liuse = sgs.CreateTriggerSkill{
	name = "jl_liuse",
	events = {sgs.TargetConfirming},
	view_as_skill = jl_liuseVS,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash")
		and use.to:contains(player)
		and player:canDiscard(player,"h")
		and room:alivePlayerCount()>2
		then
			local can
			for _,p in sgs.list(room:getOtherPlayers(use.from))do
				if use.from:canSlash(p,use.card)
				and player:inMyAttackRange(p)
				then
			    	can = true
					room:setPlayerFlag(p,"liuse")
				end
			end
			if can
			and room:askForUseCard(player,"@@jl_liuse","@jl_liuse:"..use.from:objectName())
			then
		    	local to = room:getTag("jl_liuse"):toPlayer()
				if to
				then
		    		use.to:removeOne(player)
		        	use.to:append(to)
			    	room:sortByActionOrder(use.to)
				end
			   	room:setTag("jl_liuse",sgs.QVariant())
			end
			for _,p in sgs.list(room:getOtherPlayers(use.from))do
				room:setPlayerFlag(p,"-liuse")
			end
			data:setValue(use)
		end
		return false
	end
}
jl_wumeinv:addSkill(jl_liuse)
jl_tianyanbf = sgs.CreateFilterSkill{
	name = "#jl_tianyanbf",
	view_filter = function(self,to_select)
		return to_select:getSuit()==0
	end,
	view_as = function(self,card)
		local new_card = sgs.Sanguosha:getWrappedCard(card:getEffectiveId())
		new_card:setSkillName("jl_tianyan")
		new_card:setSuit(2)
		new_card:setModified(true)
		return new_card
	end
}
jl_wumeinv:addSkill(jl_tianyanbf)
jl_tianyanCard = sgs.CreateSkillCard{
	name = "jl_tianyanCard",
	filter = function(self,selected,to_select,source)
		return #selected<1 and to_select:objectName()~=source:objectName()
	end,
	on_use = function(self,room,source,targets)
	   	room:broadcastSkillInvoke("tianxiang")--播放配音
		room:setTag("jl_tianyan",ToData(targets[1]))
	end
}
jl_tianyanVS = sgs.CreateViewAsSkill{
	name = "jl_tianyan",
	n = 1,
	view_filter = function(self,selected,to_select)
		return not to_select:isEquipped()
		and not sgs.Self:isJilei(to_select)
		and to_select:getSuit()==2
	end,
	view_as = function(self,cards)
		if #cards<1 then return end
		local card = jl_tianyanCard:clone()
		card:addSubcard(cards[1])
		return card
	end,
	enabled_at_play = function()
		return false
	end,
	enabled_at_response = function(self,player,pattern)
		return pattern=="@@jl_tianyan"
	end
}
jl_tianyan = sgs.CreateTriggerSkill{
	name = "jl_tianyan",
	events = {sgs.DamageInflicted,sgs.DamageComplete},
	view_as_skill = jl_tianyanVS,
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName("jl_tianyan")
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.DamageInflicted
		then
			if player:hasSkill("jl_tianyan") and player:canDiscard(player,"h")
			and room:askForUseCard(player,"@@jl_tianyan","@jl_tianyan-card")
			then
		    	local to = room:getTag("jl_tianyan"):toPlayer()
				if to
				then
					local damage = data:toDamage()
			    	damage.to = to
			     	damage.transfer = true
					room:damage(damage)
					return true
				end
			end
		elseif event==sgs.DamageComplete
		then
	    	local damage = data:toDamage()
	    	local to = room:getTag("jl_tianyan"):toPlayer()
	    	if player:isAlive() and damage.transfer
			and to and player:objectName()==to:objectName()
			then
		    	room:removeTag("jl_tianyan")
				player:drawCards(player:getLostHp(),"jl_tianyan")
	    	end
		end
		return false
	end
}
jl_wumeinv:addSkill(jl_tianyan)
extension:insertRelatedSkills("jl_tianyan", "#jl_tianyanbf")
jl_xiaoyinCard = sgs.CreateSkillCard{
	name = "jl_xiaoyinCard",
	filter = function(self,targets,to_select)
		return to_select:isMale()
		and to_select:isWounded()
		and #targets<1
		and to_select:objectName()~=sgs.Self:objectName()
	end,
	on_use = function(self,room,source,targets)
	   	room:broadcastSkillInvoke("jieyin")--播放配音
		room:recover(source,sgs.RecoverStruct(source,self),true)
		room:recover(targets[1],sgs.RecoverStruct(source,self),true)
	end
}
jl_xiaoyinVS = sgs.CreateViewAsSkill{
	name = "jl_xiaoyin",
	n = 2,
	view_filter = function(self,selected,to_select)
		if #selected>1 or sgs.Self:isJilei(to_select) then return false end
		return not to_select:isEquipped()
	end,
	view_as = function(self,cards)
		if #cards~=2 then return end
		local jieyin_card = jl_xiaoyinCard:clone()
		for _,card in sgs.list(cards)do
			jieyin_card:addSubcard(card)
		end
		return jieyin_card
	end,
	enabled_at_play = function(self,target)
		return target:getHandcardNum() >= 2 and not target:hasUsed("#jl_xiaoyinCard")
	end
}
jl_xiaoyin = sgs.CreateTriggerSkill{
	name = "jl_xiaoyin",
--	frequency = sgs.Skill_Frequent,
	events = {sgs.CardsMoveOneTime},
	view_as_skill = jl_xiaoyinVS,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.from
		and move.from:objectName()==player:objectName()
		and move.from_places:contains(sgs.Player_PlaceEquip)
		then
			for i = 0,move.card_ids:length()-1,1 do
				if not player:isAlive() then return end
				if move.from_places:at(i)==sgs.Player_PlaceEquip
				then
					if room:askForSkillInvoke(player,self:objectName())
					then player:drawCards(2,self:objectName())
	            	room:broadcastSkillInvoke("xiaoji")--播放配音
					else break end
				end
			end
		end
		return false
	end
}
jl_wumeinv:addSkill(jl_xiaoyin)

jl_wuzhinang = sgs.General(extension,"jl_wuzhinang","wei",3)
jl_wuzhinang:setGender(sgs.General_Neuter)
jl_guikui = sgs.CreateTriggerSkill{
	name = "jl_guikui",
	events = {sgs.AskForRetrial,sgs.Damaged},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
    	if event==sgs.AskForRetrial
		then
    		if player:isKongcheng() then return end
    		local judge = data:toJudge()
            local card = room:askForCard(player,".|.|.|hand","@jl_guikui-card:"..judge.who:objectName(),data,sgs.Card_MethodResponse,judge.who,true)
    		if card
			then
	        	room:broadcastSkillInvoke("guicai")--播放配音
    			room:retrial(card,player,judge,self:objectName())
    		end
		elseif event==sgs.Damaged
		then
    		local damage = data:toDamage()
    		local from = damage.from
    		local data = sgs.QVariant()
    		data:setValue(from)
    		if from
			and not from:isNude()
			and room:askForSkillInvoke(player,self:objectName(),data)
			then
	        	room:broadcastSkillInvoke("fankui")--播放配音
    			local card_id = room:askForCardChosen(player,from,"he",self:objectName())
    			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION,player:objectName())
    			room:obtainCard(player,sgs.Sanguosha:getCard(card_id),reason,false)
    		end
		end
		return false
	end
}
jl_wuzhinang:addSkill(jl_guikui)
jl_tianji = sgs.CreateTriggerSkill{
	name = "jl_tianji",
	frequency = sgs.Skill_Frequent,
	events = {sgs.FinishJudge,sgs.Damaged},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
    	if event==sgs.FinishJudge
		then
    		local judge = data:toJudge()
    		if room:getCardPlace(judge.card:getEffectiveId())==sgs.Player_PlaceJudge
    		and player:askForSkillInvoke(self:objectName(),ToData(judge.card))
    		then
	        	room:broadcastSkillInvoke("tiandu")--播放配音
    			player:obtainCard(judge.card)
    		end
		else
    		local damage = data:toDamage()
    		for i = 1,damage.damage do
    			if player:isDead()
				or not room:askForSkillInvoke(player,self:objectName())
				then return end
	        	room:broadcastSkillInvoke("yiji")--播放配音
	    		local guojias = sgs.SPlayerList()
	    		guojias:append(player)
	    		local cards = room:getNCards(2,false)
	    		local move = sgs.CardsMoveStruct(cards,nil,player,sgs.Player_PlaceTable,sgs.Player_PlaceHand,
	    		sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,player:objectName(),self:objectName(),nil))
	    		local moves = sgs.CardsMoveList()
	    		moves:append(move)
	    		room:notifyMoveCards(true,moves,false,guojias)
	    		room:notifyMoveCards(false,moves,false,guojias)
	    		local origin = sgs.IntList()
	    		for _,id in sgs.list(cards)do
	    			origin:append(id)
	    		end
	    		while room:askForYiji(player,cards,self:objectName(),true,false,true,-1,room:getAlivePlayers())do
	    			move = sgs.CardsMoveStruct(sgs.IntList(),player,nil,sgs.Player_PlaceHand,sgs.Player_PlaceTable,
	    			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,player:objectName(),self:objectName(),nil))
	    			for _,id in sgs.list(origin)do
	    				if room:getCardPlace(id)~=sgs.Player_DrawPile
						then
	    					move.card_ids:append(id)
	    					cards:removeOne(id)
	    				end
	    			end
	    			origin = sgs.IntList()
	    			for _,id in sgs.list(cards)do
	    				origin:append(id)
	    			end
	    			moves = sgs.CardsMoveList()
	    			moves:append(move)
	    			room:notifyMoveCards(true,moves,false,guojias)
	    			room:notifyMoveCards(false,moves,false,guojias)
	    			if player:isDead() then return end
	    		end
	    		if cards:length()>0 then
	    			move = sgs.CardsMoveStruct(cards,player,nil,sgs.Player_PlaceHand,sgs.Player_PlaceTable,
	    			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,player:objectName(),self:objectName(),nil))
	    			moves = sgs.CardsMoveList()
	    			moves:append(move)
	    			room:notifyMoveCards(true,moves,false,guojias)
	    			room:notifyMoveCards(false,moves,false,guojias)
	    			move = dummyCard()
	    			move:addSubcards(cards)
	    			player:obtainCard(move,false)
	    		end
    		end
		end
	end
}
jl_wuzhinang:addSkill(jl_tianji)
jl_qumingCard = sgs.CreateSkillCard{
	name = "jl_qumingCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self,targets,to_select,source)
		return #targets<1
		and to_select:getHp()>source:getHp()
		and to_select:canPindian()
	end,
	on_use = function(self,room,source,targets)
		local tiger = targets[1]
	   	room:broadcastSkillInvoke("quhu")--播放配音
		if source:pindian(tiger,"jl_quming",self)
		then
			local wolves = sgs.SPlayerList()
			for _,player in sgs.list(room:getOtherPlayers(tiger))do
				if tiger:inMyAttackRange(player)
				then wolves:append(player) end
			end
			if wolves:isEmpty() then return end
			local wolf = PlayerChosen(self,source,wolves,"@quhu-damage:"..tiger:objectName())
			room:damage(sgs.DamageStruct(self,tiger,wolf))
		else
			room:damage(sgs.DamageStruct(self,tiger,source))
		end
	end
}
jl_qumingVS = sgs.CreateViewAsSkill{
	name = "jl_quming",
	n = 1,
	view_filter = function(self,selected,to_select)
		return not to_select:isEquipped()
		and not sgs.Self:isJilei(to_select)
	end,
	view_as = function(self,cards)
		if #cards<1 then return end
		local _card = jl_qumingCard:clone()
		for _,card in sgs.list(cards)do
			_card:addSubcard(card)
		end
		return _card
	end,
	enabled_at_play = function(self,player)
		return not player:hasUsed("#jl_qumingCard")
		and not player:isKongcheng()
	end,
}
jl_quming = sgs.CreateTriggerSkill{
	name = "jl_quming",
	events = {sgs.Damaged},
	view_as_skill = jl_qumingVS,
	on_trigger = function(self,event,player,data)
		local damage = data:toDamage()
		local room = player:getRoom()
		for i = 1,damage.damage do
			local to = room:askForPlayerChosen(player,room:getAlivePlayers(),self:objectName(),"jieming-invoke",true,true)
			if not to then break end
	    	room:broadcastSkillInvoke("jieming")--播放配音
			local min = math.min(5,to:getMaxHp())
			local x = min-to:getHandcardNum()
			if x>0
			then to:drawCards(x,self:objectName()) end
		end
	end
}
jl_wuzhinang:addSkill(jl_quming)
jl_luoshivs = sgs.CreateViewAsSkill{
	name = "jl_luoshi",
	view_as = function(self,cards)
		local analeptic = sgs.Sanguosha:cloneCard("analeptic")
		analeptic:setSkillName(self:objectName())
		return analeptic
	end,
	enabled_at_play = function(self,player)
		return sgs.Analeptic_IsAvailable(player)
		and player:faceUp()
	end,
	enabled_at_response = function(self,player,pattern)
		return string.find(pattern,"analeptic")
		and player:faceUp()
	end
}
jl_luoshi = sgs.CreateTriggerSkill{
	name = "jl_luoshi",
	events = {sgs.PreCardUsed,sgs.CardsMoveOneTime,sgs.DamageComplete,sgs.PreDamageDone},
	view_as_skill = jl_luoshivs,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.PreCardUsed
		then
			local use = data:toCardUse()
			local card = use.card
			if card:getSkillName()=="jl_luoshi"
			then
	        	room:broadcastSkillInvoke("jiush")--播放配音
				player:turnOver()
			end
		elseif event==sgs.CardsMoveOneTime
		then
    		local move = data:toMoveOneTime()
    		if move.from==nil or move.from:objectName()==player:objectName() then return end
    		if move.to_place==sgs.Player_DiscardPile
			and (bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON)==sgs.CardMoveReason_S_REASON_DISCARD
			or move.reason.m_reason==sgs.CardMoveReason_S_REASON_JUDGEDONE)
			then
    			local toids = sgs.IntList()
    			local ids = move.card_ids
    			local dummy = sgs.Sanguosha:cloneCard("slash")
    			for i = 0,ids:length()-1 do
    				if sgs.Sanguosha:getCard(ids:at(i)):getSuit()==sgs.Card_Club
					and room:getCardPlace(ids:at(i))==sgs.Player_DiscardPile
					and (move.from_places:at(i)==sgs.Player_PlaceJudge
					or move.from_places:at(i)==sgs.Player_PlaceHand
					or move.from_places:at(i)==sgs.Player_PlaceEquip)
					then toids:append(ids:at(i)) end
    			end
    			if toids:length()>0
				and player:askForSkillInvoke(self:objectName(),data)
				then
	            	room:broadcastSkillInvoke("luoying")--播放配音
    				while toids:length()>0 do
    					room:fillAG(toids,player)
    					local id = room:askForAG(player,toids,true,self:objectName())
    					room:clearAG(player)
						if id==-1 then break end
    					dummy:addSubcard(id)
    					toids:removeOne(id)
    					move.card_ids:removeOne(id)
    				end
    				room:obtainCard(player,dummy,move.reason)
    			end
    			data:setValue(move)
    		end
		elseif event==sgs.PreDamageDone
		then player:setTag("PredamagedFace",sgs.QVariant(player:faceUp()))
		elseif event==sgs.DamageComplete
		then
			if player:getTag("PredamagedFace"):toBool() then return end
			if player:askForSkillInvoke("jl_luoshi",data)
			then
	        	room:broadcastSkillInvoke("jiushi")--播放配音
				player:turnOver()
			end
			player:removeTag("PredamagedFace")
		end
	end
}
jl_wuzhinang:addSkill(jl_luoshi)
jl_shangqing = sgs.CreateTriggerSkill{
	name = "jl_shangqing",
	events = {sgs.Predamage,sgs.EventPhaseChanging,sgs.CardsMoveOneTime,sgs.MaxHpChanged,sgs.HpChanged},
--	frequency = sgs.Skill_Frequent,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local n = player:getLostHp()-player:getHandcardNum()
		if n>0
		and player:getPhase()~=sgs.Player_Discard
		and player:askForSkillInvoke(self:objectName(),data)
		then
	    	room:broadcastSkillInvoke("shangshi")--播放配音
			player:drawCards(n,self:objectName())
		end
		if event==sgs.Predamage
		then
	   		room:sendCompulsoryTriggerLog(player,self:objectName())
	    	room:broadcastSkillInvoke("jueqing")--播放配音
 	    	local damage = data:toDamage()
	    	room:loseHp(damage.to,damage.damage)
	    	return true
		end
		return false
	end
}
jl_wuzhinang:addSkill(jl_shangqing)

jl_lvbu = sgs.General(extension,"jl_lvbu","god",8)
jl_lvbu:addSkill("wushuang")
jl_lvbu:addSkill("mashu")
jl_lvbu:addSkill("xiuluo")
jl_lvbu:addSkill("shenwei")
jl_lvbu:addSkill("shenji")
jl_lvbu:addSkill("kuangbao")
jl_lvbu:addSkill("wumou")
jl_lvbu:addSkill("wuqian")
jl_lvbu:addSkill("shenfen")

jl_zhugeliang = sgs.General(extension,"jl_zhugeliang","god",3)
jl_zhugeliang:addSkill("guanxing")
jl_zhugeliang:addSkill("bazhen")
jl_zhugeliang:addSkill("kongcheng")
jl_zhugeliang:addSkill("qixing")
jl_zhugeliang:addSkill("huoji")
jl_zhugeliang:addSkill("dawu")
jl_zhugeliang:addSkill("kanpo")
jl_zhugeliang:addSkill("kuangfeng")

jl_qizhang = sgs.General(extension,"jl_qizhang","god")
jl_qizhang:setGender(sgs.General_Neuter)
jl_qizhang:addSkill("paoxiao")
jl_qizhang:addSkill("nostuxi")
jl_leidao = sgs.CreateTriggerSkill{
	name = "jl_leidao",
	events = {sgs.CardResponded,sgs.AskForRetrial},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.CardResponded
		then
    		local card_star = data:toCardResponse().m_card
    		if card_star:isKindOf("Jink")
    		then
    			local target = room:askForPlayerChosen(player,room:getAlivePlayers(),self:objectName(),"jl_leidaoinvoke",true,true)
    			if target
				then
	            	room:broadcastSkillInvoke("leiji")--播放配音
    				local judge = sgs.JudgeStruct()
    				judge.pattern = ".|spade"
    				judge.good = false
    				judge.negative = true
    				judge.reason = self:objectName()
    				judge.who = target
    				room:judge(judge)
    				if judge:isBad()
					then
    					room:damage(sgs.DamageStruct(self:objectName(),player,target,2,sgs.DamageStruct_Thunder))
    				end
    			end
    		end
		else
    		local judge = data:toJudge()
    		local card = room:askForCard(player,".|black","@jl_leidaocard:"..judge.who:objectName(),data,sgs.Card_MethodResponse,judge.who,true)
    		if card
			then
	        	room:broadcastSkillInvoke("guidao")--播放配音
    			room:retrial(card,player,judge,self:objectName(),true)
    		end
		end
		return false
	end
}
jl_qizhang:addSkill(jl_leidao)
jl_qizhang:addSkill("jl_shangqing")
jl_qizhang:addSkill("qiaobian")
jl_zhizhengCard = sgs.CreateSkillCard{
	name = "jl_zhizhengCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self,targets,to_select,erzhang)
		if #targets~=0 or to_select:objectName()==erzhang:objectName() then return false end
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		local index = card:getRealCard():toEquipCard():location()
		return to_select:getEquip(index)==nil
	end,
	on_use = function(self,room,source,targets)
	   	room:broadcastSkillInvoke("zhijian")--播放配音
		room:moveCardTo(self,source,targets[1],sgs.Player_PlaceEquip,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT,source:objectName(),"zhijian",""))
		source:drawCards(1,"zhijian")
	end
}
jl_zhizhengVS = sgs.CreateViewAsSkill{
	name = "jl_zhizheng",	
	n = 1,
	view_filter = function(self,selected,to_select)
		return not to_select:isEquipped()
		and not sgs.Self:isJilei(to_select)
		and to_select:isKindOf("EquipCard")
	end,
	view_as = function(self,cards)
		local zhijian_card = jl_zhizhengCard:clone()
		if #cards<1 then return end
		zhijian_card:addSubcard(cards[1])
		zhijian_card:setSkillName(self:objectName())
		return zhijian_card
	end
}
jl_zhizheng = sgs.CreateTriggerSkill{
	name = "jl_zhizheng",
--	frequency = sgs.Skill_NotFrequent,
	view_as_skill = jl_zhizhengVS,
	events = {sgs.CardsMoveOneTime,sgs.EventPhaseEnd},
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
		if event==sgs.CardsMoveOneTime
		then
    		local move = data:toMoveOneTime()
    		local flag = bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON)
    		if player:getPhase()==sgs.Player_Discard
			and move.to_place==sgs.Player_DiscardPile
			and flag==sgs.CardMoveReason_S_REASON_DISCARD
    		then
				local cards = owner:getTag("jl_zhizheng"):toString():split("+")
	    		for _,c in sgs.list(move.card_ids)do
					if room:getCardPlace(c)==sgs.Player_DiscardPile
					then table.insert(cards,c) end
				end
				owner:setTag("jl_zhizheng",sgs.QVariant(table.concat(cards,"+")))
    		end
		elseif player:getPhase()==sgs.Player_Discard
		then
			local cards = owner:getTag("jl_zhizheng"):toString():split("+")
			local move = sgs.CardsMoveStruct()
	    	for _,c in sgs.list(cards)do
				if room:getCardPlace(c)==sgs.Player_DiscardPile
				then move.card_ids:append(c) end
	    	end
			if move.card_ids:length()>0
			and owner:askForSkillInvoke(self:objectName(),ToData(player))
			then
	        	room:broadcastSkillInvoke("guzheng")--播放配音
				room:fillAG(move.card_ids,owner)
				cards = room:askForAG(owner,move.card_ids,false,self:objectName())
	           	room:clearAG(owner)
				move.card_ids:removeOne(cards)
				room:obtainCard(player,cards)
				move.to = owner
				move.to_place = sgs.Player_PlaceHand
				room:moveCardsAtomic(move,true)
			end
			owner:setTag("jl_zhizheng",sgs.QVariant())
		end
		end
		return false
	end,
}
jl_qizhang:addSkill(jl_zhizheng)

jl_sijin = sgs.General(extension,"jl_sijin","god")
jl_sijin:addSkill("zhiheng")
jl_sijin:addSkill("qingnang")
jl_sijin:addSkill("jijiu")
jl_sijin:addSkill("keji")
jl_sijin:addSkill("nosjianxiong")

jl_lubei = sgs.General(extension,"jl_lubei","god")
jl_lubei:addSkill("nosrende")
jl_lubei:addSkill("noslianying")

jl_sanjunshi = sgs.General(extension,"jl_sanjunshi","wei",3)
jl_sanjunshi:addSkill("nosguicai")
jl_sanjunshi:addSkill("tiandu")
jl_sanjunshi:addSkill("quhu")
jl_weimou = sgs.CreateTriggerSkill{
	name = "jl_weimou",
	events = {sgs.Damaged},
	on_trigger = function(self,event,player,data)
		local damage = data:toDamage()
		local room = player:getRoom()
		for i = 1,damage.damage do
			local to = room:askForPlayerChosen(player,room:getAlivePlayers(),self:objectName(),"jieming-invoke",true,true)
			if not to then break end
	      	room:broadcastSkillInvoke("jieming")--播放配音
			local upper = math.min(5,to:getMaxHp())
			local x = upper-to:getHandcardNum()
			if x>0 then to:drawCards(x,self:objectName()) end
		end
		if player:isDead() then return end
		for i = 1,damage.damage do
			if room:askForSkillInvoke(player,self:objectName(),data)
			then
	         	room:broadcastSkillInvoke("yiji")--播放配音
    			local guojias = sgs.SPlayerList()
    			guojias:append(player)
    			local cards = room:getNCards(2,false)
    			local move = sgs.CardsMoveStruct(cards,nil,player,sgs.Player_PlaceTable,sgs.Player_PlaceHand,
    			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,player:objectName(),self:objectName(),nil))
    			local moves = sgs.CardsMoveList()
    			moves:append(move)
    			room:notifyMoveCards(true,moves,false,guojias)
    			room:notifyMoveCards(false,moves,false,guojias)
    			local origin = sgs.IntList()
    			for _,id in sgs.list(cards)do
    				origin:append(id)
    			end
    			while room:askForYiji(player,cards,self:objectName(),true,false,true,-1,room:getAlivePlayers())do
    				move = sgs.CardsMoveStruct(sgs.IntList(),player,nil,sgs.Player_PlaceHand,sgs.Player_PlaceTable,
    				sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,player:objectName(),self:objectName(),nil))
    				for _,id in sgs.list(origin)do
    					if room:getCardPlace(id)~=sgs.Player_DrawPile
						then
    						move.card_ids:append(id)
    						cards:removeOne(id)
    					end
    				end
    				origin = sgs.IntList()
    				for _,id in sgs.list(cards)do
    					origin:append(id)
    				end
    				moves = sgs.CardsMoveList()
    				moves:append(move)
    				room:notifyMoveCards(true,moves,false,guojias)
    				room:notifyMoveCards(false,moves,false,guojias)
    				if not player:isAlive() then return end
    			end
    			if not cards:isEmpty() then
    				move = sgs.CardsMoveStruct(cards,player,nil,sgs.Player_PlaceHand,sgs.Player_PlaceTable,
    				sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,player:objectName(),self:objectName(),nil))
    				moves = sgs.CardsMoveList()
    				moves:append(move)
    				room:notifyMoveCards(true,moves,false,guojias)
    				room:notifyMoveCards(false,moves,false,guojias)
    				moves = sgs.Sanguosha:cloneCard("slash")
    				moves:addSubcards(cards)
    				player:obtainCard(moves,false)
    			end
			end
		end
		local from = damage.from
		local todata = sgs.QVariant()
		todata:setValue(from)
		if not from:isNude()
		and room:askForSkillInvoke(player,self:objectName(),todata)
		then
	     	room:broadcastSkillInvoke("fankui")--播放配音
			local card_id = room:askForCardChosen(player,from,"he",self:objectName())
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION,player:objectName())
			room:obtainCard(player,sgs.Sanguosha:getCard(card_id),false)
		end
	end
}
jl_sanjunshi:addSkill(jl_weimou)

jl_sidudu = sgs.General(extension,"jl_sidudu","wu")
jl_yingjianCard = sgs.CreateSkillCard{
	name = "jl_yingjianCard",
	filter = function(self,targets,to_select,source)
		return #targets<1
		and to_select:objectName()~=source:objectName()
	end,
	on_use = function(self,room,source,targets)
		local card = source:getRandomHandCard()
	   	room:broadcastSkillInvoke("fanjian")--播放配音
		local suit = room:askForSuit(targets[1],"jl_yingjian")
		room:getThread():delay()
		room:obtainCard(targets[1],card)
		if card:getSuit()~=suit
		then
			room:damage(sgs.DamageStruct(self,source,targets[1]))
		end
	end
}
jl_yingjianVS = sgs.CreateZeroCardViewAsSkill{
	name = "jl_yingjian",
	view_as = function()
		return jl_yingjianCard:clone()
	end,
	enabled_at_play = function(self,player)
		return not player:isKongcheng() and not player:hasUsed("#jl_yingjianCard")
	end
}
jl_yingjian = sgs.CreateTriggerSkill{
	name = "jl_yingjian",
--	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	view_as_skill = jl_yingjianVS,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player,"jl_yingjian",data)
		then
	     	room:broadcastSkillInvoke("yingzi")--播放配音
			local count = data:toInt() + 1
			data:setValue(count)
		end
	end
}
jl_sidudu:addSkill(jl_yingjian)
jl_sidudu:addSkill("keji")
local json = require("json")
jl_haomengCard = sgs.CreateSkillCard{
	name = "jl_haomengCard",
	target_fixed = false,
--	will_throw = false,
	filter = function(self,targets,to_select,source)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern~=""
		then
	    	return to_select:getHandcardNum()==source:getMark("jl_haomeng")
	    	and to_select:objectName()~=source:objectName()
	    	and #targets<1
		else
	    	if #targets<1
			then
		    	return to_select:objectName()~=source:objectName()
			elseif #targets<2
			then
	    		pattern = math.abs(to_select:getHandcardNum()-targets[1]:getHandcardNum())
				return pattern==self:subcardsLength()
				and to_select:objectName()~=source:objectName()
	    	end
		end
	end,
	feasible = function(self,targets)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern~=""
		then
	    	return #targets>0
		else
	    	return #targets>1
		end
	end,
	about_to_use = function(self,room,use)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if use.to:length()<2
		then
			room:obtainCard(use.to:first(),self,false)
		else
	    	self:cardOnUse(room,use)
		end
	end,
	on_use = function(self,room,source,targets)
    	local a,b = targets[1],targets[2]
    	a:setFlags("DimengTarget")
    	b:setFlags("DimengTarget")
    	for _,p in sgs.list(room:getAlivePlayers())do
    		if p:objectName()~=a:objectName()
			and p:objectName()~=b:objectName()
			then
    			room:doNotify(p,sgs.CommandType.S_COMMAND_EXCHANGE_KNOWN_CARDS,json.encode({a:objectName(),b:objectName()}))
    		end
    	end
	   	room:broadcastSkillInvoke("dimeng")--播放配音
		pattern = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP,a:objectName(),b:objectName(),"jl_haomeng","")
    	local move1 = sgs.CardsMoveStruct(a:handCards(),b,sgs.Player_PlaceHand,pattern)
    	local move2 = sgs.CardsMoveStruct(b:handCards(),a,sgs.Player_PlaceHand,pattern)
    	pattern = sgs.CardsMoveList()
    	pattern:append(move1)
    	pattern:append(move2)
       	room:moveCardsAtomic(pattern,false)
       	a:setFlags("-DimengTarget")
       	b:setFlags("-DimengTarget")
	end
}
jl_haomengVS = sgs.CreateViewAsSkill{
	name = "jl_haomeng",
	n = 999,
	view_filter = function(self,selected,to_select)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern==""
		then
	    	return not sgs.Self:isJilei(to_select)
		end
		local length = math.floor(sgs.Self:getHandcardNum()/2)
		return #selected<length
		and not to_select:isEquipped()
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern~=""
		and #cards~=math.floor(sgs.Self:getHandcardNum()/2)
		then return end
		pattern = jl_haomengCard:clone()
		for _,c in sgs.list(cards)do
			pattern:addSubcard(c)
		end
		return pattern
	end,
	enabled_at_play = function(self,player)
		return not player:hasUsed("#jl_haomengCard")
	end,
	enabled_at_response = function(self,player,pattern)
		return pattern=="@@jl_haomeng!"
	end
}
jl_haomeng = sgs.CreateTriggerSkill{
	name = "jl_haomeng",
--	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards,sgs.AfterDrawNCards},
	view_as_skill = jl_haomengVS,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.DrawNCards
		then
    		if room:askForSkillInvoke(player,"jl_haomeng",data)
    		then
	        	room:broadcastSkillInvoke("haoshi")--播放配音
    			room:setPlayerFlag(player,"jl_haomeng")
    			local count = data:toInt()+2
    			data:setValue(count)
    		end
		elseif player:hasFlag("jl_haomeng")
		then
    		room:setPlayerFlag(player,"-jl_haomeng")
			if player:getHandcardNum()<6 then return end
			local least = 1000
			for _,p in sgs.list(room:getOtherPlayers(player))do
				least = math.min(p:getHandcardNum(),least)
			end
			room:setPlayerMark(player,"jl_haomeng",least)
			room:askForUseCard(player,"@@jl_haomeng!","@haoshi")
		end
	end
}
jl_sidudu:addSkill(jl_haomeng)
jl_qianying = sgs.CreateTriggerSkill{
	name = "jl_qianying",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self,event,luxun,data)
		local room = luxun:getRoom()
		local move = data:toMoveOneTime()
		if move.from
		and move.from:objectName()==luxun:objectName() 
		and move.from_places:contains(sgs.Player_PlaceHand)
		and move.is_last_handcard
		and room:askForSkillInvoke(luxun,"jl_qianying",data)
		then
	     	room:broadcastSkillInvoke("lianying")--播放配音
			luxun:drawCards(1,self:objectName())
		end
		return false
	end
}
jl_sidudu:addSkill(jl_qianying)
jl_qianyingbf = sgs.CreateProhibitSkill{
	name = "jl_qianyingbf",
	is_prohibited = function(self,from,to,card)
		if card:isKindOf("Slash")
		then
	    	local w = from:getWeapon()
	    	if w and w:isKindOf("JlQiefudao")
			and to and from:objectName()~=to:objectName()
	    	then self:setObjectName("jl_qiefudao") return true end
		end
		if to and to:hasSkill("jl_qianying")
		and (card:isKindOf("Snatch") or card:isKindOf("Indulgence"))
		then self:setObjectName("jl_qianying") return true end
		if to and to:hasSkill("jl_guancheng") and to:isKongcheng()
		and (card:isKindOf("Slash") or card:isKindOf("Duel"))
		then self:setObjectName("jl_guancheng") return true end
		if from:hasSkill("jl_yedu")
		and from:getMark("jl_yedu_no_to_crad-Clear")>0
		then
	    	if to and to:objectName()~=from:objectName()
	    	then
	        	self:setObjectName("jl_yedu")
				return true
			end
		end
		if card:isNDTrick()
		then
	    	if to and to:hasLordSkill("jl_zebing")
			and to:getPile("jl_mou"):isEmpty()
	    	then
				self:setObjectName("jl_zebing")
				return true
			end
		end
	end
}
addToSkills(jl_qianyingbf)
extension:insertRelatedSkills("jl_qianying", "#jl_qianyingbf")

jl_jiangjiao = sgs.General(extension,"jl_jiangjiao","god")
jl_jiangjiao:addSkill("tiaoxin")
jl_jiangjiao:addSkill("nosleiji")
jl_jiangjiao:addSkill("guidao")

jl_sihai = sgs.General(extension,"jl_sihai","god",3)
jl_sihai:setGender(sgs.General_Neuter)
jl_sihai:addSkill("nosyiji")
jl_sihai:addSkill("chengxiang")
jl_sihai:addSkill("miji")
jl_sihai:addSkill("jiang")
jl_sihai:addSkill("nosshangshi")

jl_liuxz = sgs.General(extension,"jl_liuxz","god")
jl_liuxz:setStartHp(3)
jl_liuxz:addSkill("renwang")
jl_hongfacard = sgs.CreateSkillCard{
	name = "jl_hongfacard",
	will_throw = false,
	filter = function(self,targets,to_select,source)
	    local tocard = source:getTag("jl_hongfa"):toCard()
		local plists = source:getAliveSiblings()
		plists:append(source)
       	for _,p in sgs.list(plists)do
	    	local plist = sgs.PlayerList()
	    	for i = 1,#targets,1 do plist:append(targets[i]) end
	    	if tocard
	    	and tocard:targetFilter(plist,p,source)
	    	and not source:isProhibited(p,tocard,plist)
		    then
	        	return #targets<1
	        	and to_select:objectName()~=source:objectName()
	    	end
      	end
	end,
	feasible = function(self,targets)
		return #targets>0
	end,
	on_use = function(self,room,source,targets)
		local sh = self:subcardsLength()
		room:removePlayerMark(source,"@jl_hongfa")
		room:doSuperLightbox("jl_liuxz","jl_hongfa")
		for _,p in sgs.list(targets)do
		    room:obtainCard(p,self,false)
		end
		room:askForUseCard(source,"@@jl_hongfa!","@jl_hongfa-card:"..self:getUserString())
		room:handleAcquireDetachSkills(source,"-renwang|rende")
		if sh>2
		then
	     	room:loseMaxHp(source)
			room:recover(source,sgs.RecoverStruct(source,self))
		end
		return false
	end
}
jl_hongfavs = sgs.CreateViewAsSkill{
	name = "jl_hongfa",
	view_as = function(self,cards)
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local tocard = sgs.Self:getTag("jl_hongfa"):toCard()
		tocard = tocard:objectName()
		if pattern~=""
		then
        	pattern = sgs.Sanguosha:cloneCard(tocard)
	    	pattern:setSkillName("_jl_hongfa")
		else
	    	pattern = jl_hongfacard:clone()
         	for _,c in sgs.list(sgs.Self:getHandcards())do
	    		pattern:addSubcard(c)
	    	end
         	for _,c in sgs.list(sgs.Self:getEquips())do
		    	pattern:addSubcard(c)
			end
	    	pattern:setUserString(tocard)
		end
		return pattern
	end,
	enabled_at_response = function(self,player,pattern)
		return pattern=="@@jl_hongfa!"
	end,
	enabled_at_play = function(self,player)
		return player:getMark("@jl_hongfa")>0
	end
}
jl_hongfa = sgs.CreateTriggerSkill{
	name = "jl_hongfa",
	frequency = sgs.Skill_Limited,
	guhuo_type = "l",
	limit_mark = "@jl_hongfa",
	waked_skills = "rende",
	events = {sgs.NonTrigger},
	view_as_skill = jl_hongfavs,
	on_trigger = function()	end
}
jl_liuxz:addSkill(jl_hongfa)
jl_liuxz:addSkill("jijiang")

--[[
jl_shensunben = sgs.General(extension,"jl_shensunben","god",6)
jl_shensunben:addSkill("fuqi")
jl_shensunben:addSkill("canshi")
jl_hunzi = sgs.CreateTriggerSkill{
	name = "jl_hunzi",
	events = {sgs.EventPhaseStart,sgs.EventLoseSkill},
	frequency = sgs.Skill_Wake,
	on_trigger = function(self,event,player,data,room)
		local can = true
       	for _,p in sgs.list(room:getAlivePlayers())do
      		if player:getHp()<p:getHp()
	       	then can = false end
       	end
        if player:getPhase()==sgs.Player_Start 
	    and player:getMark(self:objectName())<1
		and (can or player:canWake(self:objectName()))
		then
	    	local log = sgs.LogMessage()
	    	log.type = "$SkillWakeTrigger"
	    	log.from = player
	    	log.arg = self:objectName()
	    	room:sendLog(log)
	    	room:broadcastSkillInvoke("hunzhi")
      		room:sendCompulsoryTriggerLog(player,self:objectName())
			room:doSuperLightbox("jl_shensunben","jl_hunzi")
		    room:changeMaxHpForAwakenSkill(player)
			room:addPlayerMark(player,self:objectName())
	    	room:handleAcquireDetachSkills(player,"benghuai|yaowu|shiyong|ransang|lianhuo|wumou|tongji|chouhai|jinjiu|jiaozi|yinghun")
		end
		return false
	end,	
}
jl_shensunben:addSkill(jl_hunzi)
jl_shensunben:addSkill("feiying")
jl_shensunben:addRelateSkill("benghuai")
jl_shensunben:addRelateSkill("yaowu")
jl_shensunben:addRelateSkill("shiyong")
jl_shensunben:addRelateSkill("ransang")
jl_shensunben:addRelateSkill("lianhuo")
jl_shensunben:addRelateSkill("wumou")
jl_shensunben:addRelateSkill("tongji")
jl_shensunben:addRelateSkill("chouhai")
jl_shensunben:addRelateSkill("jinjiu")
jl_shensunben:addRelateSkill("jiaozi")
jl_shensunben:addRelateSkill("yinghun")
--]]

jl_shawo = sgs.General(extension,"jl_shawo","god",5)
jl_shawo:setGender(sgs.General_Neuter)
jl_shawo:addSkill("tiaoxin")
jl_shawo:addSkill("bazhen")
jl_shawo:addSkill("jieming")
jl_shawo:addSkill("jiang")
jl_shawo:addSkill("nosleiji")
jl_shawo:addSkill("guidao")
jl_shawo:addSkill("fankui")
jl_shawo:addSkill("nosyiji")
jl_shawo:addSkill("tianxiang")

jl_huanggaigai = sgs.General(extension,"jl_huanggaigai","wu")
jl_huanggaigai:addSkill("noskurou")
jl_huanggaigai:addSkill("zhaxiang")

jl_sancao = sgs.General(extension,"jl_sancao","wei")
jl_sancao:addSkill("nosjianxiong")
jl_sancao:addSkill("xingshang")
jl_sancao:addSkill("jiushi")

--jl_caoyi = sgs.General(extension,"jl_caoyi","god")
jl_caoshi = sgs.CreateTriggerSkill{
	name = "jl_caoshi",
	events = {sgs.Damaged,sgs.EventPhaseChanging},
	on_trigger = function(self,event,player,data,room)
        if event==sgs.EventPhaseChanging
		then
	    	local change = data:toPhaseChange()
			if change.from~=sgs.Player_NotActive
			then return end
		end
	   	if player:askForSkillInvoke(self:objectName(),data)
		then
	       	local names = {}
	       	for _,p in sgs.list(room:getAlivePlayers())do
	       		table.insert(names,p:getGeneralName())
	       	end
	       	local generals = {}
	       	for _,name in sgs.list(sgs.Sanguosha:getLimitedGeneralNames())do
	       		local general = sgs.Sanguosha:getGeneral(name)
	       		if string.find(sgs.Sanguosha:translate(name),sgs.Sanguosha:translate("jl_caoshi1"))
				and not table.contains(names,name)
			   	then
	            	local can
					for _,skill in sgs.list(general:getVisibleSkillList())do
				    	if not player:hasSkill(skill) then can = true end
					end
				   	if can then table.insert(generals,name) end
		     	end
	        end
	      	generals = room:askForGeneral(player,table.concat(generals,"+"))
	    	local SkillList = {}
	    	for _,skill in sgs.list(sgs.Sanguosha:getGeneral(generals):getVisibleSkillList())do
	    		if not skill:isLordSkill()
	    		and skill:getFrequency()~=sgs.Skill_Limited
	    		and skill:getFrequency()~=sgs.Skill_Wake
		    	then
		    		table.insert(SkillList,skill:objectName())
		    	end
	    	end
	    	if #SkillList<1 then return end
			SkillList = room:askForChoice(player,self:objectName(),table.concat(SkillList,"+"))
	    	room:acquireSkill(player,SkillList)
		end
	end
}
--jl_caoyi:addSkill(jl_caoshi)

jl_liubei = sgs.General(extension,"jl_liubei","god")
jl_derenCard = sgs.CreateSkillCard{
	name = "jl_derenCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self,selected,to_select,source)
		return #selected<1
		and to_select:objectName()~=source:objectName()
	end,
	on_use = function(self,room,source,targets)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE,targets[1]:objectName(),source:objectName(),"jl_deren","")
	   	local cards = room:askForExchange(targets[1],"jl_deren",998,1,false,"@jl_deren:"..source:objectName(),true)
		local n = targets[1]:getMark("jl_deren-PlayClear")
		if cards
		then
	    	room:obtainCard(source,cards,reason,false)
	    	n = n+cards:getSubcards():length()
		end
		if n<2
		then
    		room:loseHp(targets[1])
			n = n+2
		end
		room:setPlayerMark(targets[1],"jl_deren-PlayClear",n)
	end
}
jl_derenVS = sgs.CreateViewAsSkill{
	name = "jl_deren",
	view_as = function(self,cards)
		return jl_derenCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:isAlive()
	end
}
jl_deren = sgs.CreateTriggerSkill{
	name = "jl_deren",
--	events = {sgs.EventPhaseChanging},
	view_as_skill = jl_derenVS,
	on_trigger = function() end,
}
jl_liubei:addSkill(jl_deren)
jl_qiangjiCard = sgs.CreateSkillCard{
	name = "jl_qiangjiCard",
	filter = function(self,targets,to_select,from)
		return SCfilter("slash",targets,to_select)
	end,
	feasible = function(self,targets)
		return SCfeasible("slash",targets)
	end,
	on_validate = function(self,use)
		local from = use.from
		local room = from:getRoom()
		local data = sgs.QVariant()
		data:setValue(from)
		from:addMark("jl_qiangji-Clear")
		NotifySkillInvoked("jl_qiangji",from,use.to)
	   	for _,owner in sgs.list(room:findPlayersBySkillName("jl_qiangji"))do
			if room:askForUseSlashTo(owner,use.to:at(0),"@jl_qiangji:"..from:objectName(),false)
			then return nil end
		end
	end,
	on_validate_in_response = function(self,from)
		local room = from:getRoom()
		NotifySkillInvoked("jl_qiangji",from)
		local data = sgs.QVariant()
		data:setValue(from)
		from:addMark("jl_qiangji-Clear")
	   	for _,owner in sgs.list(room:findPlayersBySkillName("jl_qiangji"))do
			local slash = room:askForCard(owner,"slash","@jl_qiangji:"..from:objectName(),data,sgs.Card_MethodResponse)
			if slash then return true end
		end
	end
}
jl_qiangjiVS = sgs.CreateViewAsSkill{
	name = "jl_qiangjiVS&",
	view_as = function()
		return jl_qiangjiCard:clone()
	end,
	enabled_at_play = function(self,player)
        for _,p in sgs.list(player:getAliveSiblings())do
          	if p:hasSkill("jl_qiangji")
        	then return sgs.Slash_IsAvailable(player) end
    	end
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"slash")
		then return true end
	end
}
jl_qiangji = sgs.CreateTriggerSkill{
	name = "jl_qiangji",
	events = {sgs.CardsMoveOneTime,sgs.BuryVictim},
--	view_as_skill = jl_qiangjiVS,
	can_trigger = function(self,target)
		return true
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
       	for _,p in sgs.list(room:getAlivePlayers())do
		   	p:removeMark("jl_qiangji-Clear")
	    end
		local source = room:findPlayerBySkillName(self:objectName())
		if source and source:isAlive()
		then
        	for _,p in sgs.list(room:getOtherPlayers(source))do
		    	if p:hasSkill("jl_qiangjiVS") then continue end
				room:attachSkillToPlayer(p,"jl_qiangjiVS")
	    	end
		else
        	for _,p in sgs.list(room:getAlivePlayers())do
		    	if p:hasSkill("jl_qiangjiVS")
		    	then
			    	room:detachSkillFromPlayer(p,"jl_qiangjiVS",true,true)
		     	end
		    end
		end
		return false
	end,
}
jl_liubei:addSkill(jl_qiangji)
addToSkills(jl_qiangjiVS)

jl_shusixiang = sgs.General(extension,"jl_shusixiang","shu",3)
jl_guancheng = sgs.CreateTriggerSkill{
	name = "jl_guancheng",
	frequency = sgs.Skill_Frequent,
	waked_skills = "guanxing,kongcheng",
	events = {sgs.EventPhaseStart,sgs.CardsMoveOneTime},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseStart
		then
	    	if player:getPhase()==sgs.Player_Start
	    	then
	        	local skill = sgs.Sanguosha:getTriggerSkill("guanxing")
        		if skill then skill:trigger(event,room,player,data) end
	    	end
		else
	    	local move = data:toMoveOneTime()
	    	if move.from and move.from:objectName()==player:objectName() 
	    	and move.from_places:contains(sgs.Player_PlaceHand)
	    	and move.is_last_handcard
	    	then
	         	room:broadcastSkillInvoke("kongcheng")--播放配音
	    	end
		end
	end
}
jl_shusixiang:addSkill(jl_guancheng)
jl_jincuiCard = sgs.CreateSkillCard{
	name = "jl_jincuiCard",
	will_throw = false,
	filter = function(self,targets,to_select,source)
	   	return #targets<1
		and to_select:objectName()~=source:objectName()
	end,
	on_use = function(self,room,source,targets)
	   	room:broadcastSkillInvoke("mobileyanjincui")--播放配音
		room:doSuperLightbox(source:getGeneralName(),"jl_jincui")
        room:removePlayerMark(source,"@mobileyanjincuiMark")
        room:swapSeat(source,targets[1])
        if source:isAlive() then room:loseHp(source,source:getHp()) end
	   	return false
  	end
}
jl_zhencuiVS = sgs.CreateViewAsSkill{
	name = "jl_zhencui",
	view_as = function()
		return jl_jincuiCard:clone()
	end,
	enabled_at_play = function(self,player)
       	return player:getMark("@mobileyanjincuiMark")>0
	end,
}
jl_zhencui = sgs.CreateTriggerSkill{
	name = "jl_zhencui",
	view_as_skill = jl_zhencuiVS,
	waked_skills = "mobileyanzhenting,mobileyanjincui",
	events = {sgs.GameStart,sgs.TargetConfirmed},
	on_trigger = function(self,event,player,data,room)
	   	if event==sgs.TargetConfirmed
		then
	       	local use = data:toCardUse()
        	if (use.card:isKindOf("Slash") or use.card:isKindOf("DelayedTrick"))
			and use.from:objectName()~=player:objectName()
			and not use.to:contains(player)
	    	then
				for _,to in sgs.list(use.to)do
			    	if player:inMyAttackRange(to)
					and player:getMark("mobileyanzhenting_used-Clear")<1
					and player:askForSkillInvoke("mobileyanzhenting",sgs.QVariant("zhenting0:"..to:objectName().."::"..use.card:objectName()))
					then
	                	room:broadcastSkillInvoke("mobileyanzhenting")--播放配音
						room:addPlayerMark(player,"mobileyanzhenting_used-Clear")
                        use.to:removeOne(to)
                        use.to:append(player)
                        room:sortByActionOrder(use.to)
				    	if use.from:isKongcheng()
				    	or player:askForSkillInvoke("zhenting1",sgs.QVariant("zhenting2:"..use.from:objectName()),false)
				    	then player:drawCards(1,"mobileyanzhenting")
				    	else
                            local id = room:askForCardChosen(player,use.from,"h","mobileyanzhenting")
                            room:throwCard(id,use.from,player)
				    	end
					end
				end
				data:setValue(use)
			end
		elseif player:hasSkill("jl_zhencui")
		and player:getMark("@mobileyanjincuiMark")<1
		then
     		room:addPlayerMark(player,"@mobileyanjincuiMark")
		end
	end
}
jl_shusixiang:addSkill(jl_zhencui)
jl_bingyan = sgs.CreateTriggerSkill{
	name = "jl_bingyan",
	frequency = sgs.Skill_Frequent,
	waked_skills = "bingzheng,sheyan",
	events = {sgs.EventPhaseEnd,sgs.TargetConfirming},
	on_trigger = function(self,event,player,data,room)
	    if event==sgs.EventPhaseEnd
		then
    		if player:getPhase()==sgs.Player_Play
	    	then
	        	local skill = sgs.Sanguosha:getTriggerSkill("bingzheng")
        		if skill then skill:trigger(event,room,player,data) end
	    	end
		else
	       	local skill = sgs.Sanguosha:getTriggerSkill("sheyan")
        	if skill then skill:trigger(event,room,player,data) end
		end
	end
}
jl_shusixiang:addSkill(jl_bingyan)
jl_jianyuCard = sgs.CreateSkillCard{
	name = "jl_jianyuCard",
	will_throw = false,
	filter = function(self,targets,to_select,source)
	   	return #targets<2
	end,
	feasible = function(self,targets)
		return #targets>1
	end,
	about_to_use = function(self,room,use)
		self:cardOnUse(room,use)
        room:addPlayerMark(use.from,"mobilezhijianyu_lun")
        room:addPlayerMark(use.to:first(),"&mobilezhijianyu+#"..use.from:objectName().."#"..use.to:last():objectName())
        room:addPlayerMark(use.to:last(),"&mobilezhijianyu+#"..use.from:objectName().."#"..use.to:first():objectName())
	end,
	on_use = function(self,room,source,targets)
	   	room:broadcastSkillInvoke("mobilezhijianyu")--播放配音
		return false
	end
}
jl_jianxiVS = sgs.CreateViewAsSkill{
	name = "jl_jianxi",
	view_as = function()
		return jl_jianyuCard:clone()
	end,
	enabled_at_play = function(self,player)
       	return player:getMark("mobilezhijianyu_lun")<1
	end,
}
jl_jianxi = sgs.CreateTriggerSkill{
	name = "jl_jianxi",
	view_as_skill = jl_jianxiVS,
	waked_skills = "mobilezhijianyu,mobilezhishengxi",
	events = {sgs.EventPhaseStart,sgs.TargetSpecifying},
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
	   	local skill = sgs.Sanguosha:getTriggerSkill("mobilezhishengxi")
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
        	if skill and owner:getPhase()==sgs.Player_Finish
	    	then skill:trigger(event,room,owner,data) end
        	if event==sgs.TargetSpecifying
	    	then
	        	local use = data:toCardUse()
				if use.card:isKindOf("SkillCard") then return end
	         	for _,to in sgs.list(use.to)do
                    if player:getMark("&mobilezhijianyu+#"..owner:objectName().."#"..to:objectName())>0
					then
                        room:sendCompulsoryTriggerLog(owner,"mobilezhijianyu")
						to:drawCards(1,"mobilezhijianyu")
					end
				end
	    	end
		end
	   	skill = sgs.Sanguosha:getTriggerSkill("mobilezhijianyu")
    	if skill then skill:trigger(event,room,player,data) end
	end
}
jl_shusixiang:addSkill(jl_jianxi)

jl_sicai = sgs.General(extension,"jl_sicai","qun",3)
jl_wolongVS = sgs.CreateViewAsSkill{
	name = "jl_wolong",
	n = 1,
	view_filter = function(self,selected,to_select)
		if sgs.Self:isJilei(to_select)
		or to_select:isEquipped() then return end
		if sgs.Sanguosha:getCurrentCardUsePattern()=="nullification"
		then return to_select:isBlack() end
        return to_select:isRed()
	end,
	view_as = function(self,cards)
		if #cards<1 then return end
		local card = sgs.Sanguosha:cloneCard("fire_attack")
	   	card:setSkillName("huoji")
		if sgs.Sanguosha:getCurrentCardUsePattern()=="nullification"
		then
		    card = sgs.Sanguosha:cloneCard("nullification")
	    	card:setSkillName("kanpo")
		end
		for _,c in sgs.list(cards)do
			card:addSubcard(c)
		end
		return card
	end,
	enabled_at_play = function(self,player)
		for _,c in sgs.list(player:getHandcards())do
		    if c:isRed() then return c end
		end
	end,
	enabled_at_response = function(self,player,pattern)
		return pattern=="nullification"
	end,
	enabled_at_nullification = function(self,player)
		for _,c in sgs.list(player:getHandcards())do
		    if c:isBlack() then return c end
		end
	end
}
jl_wolong = sgs.CreateTriggerSkill{
	name = "jl_wolong",
	view_as_skill = jl_wolongVS,
	events = {sgs.CardAsked},
	waked_skills = "bazhen,huoji,kanpo",
	on_trigger = function(self,event,wolong,data,room)
		if wolong:getArmor() or wolong:getEquip(1) then return end
		wolong:ViewAsEquip("eight_diagram")
	end,
	can_trigger = function(self,target)
		return target and target:isAlive()
		and target:hasSkill(self) 
		and target:hasArmorArea()
	end
}
jl_sicai:addSkill(jl_wolong)
jl_fengcuVS = sgs.CreateViewAsSkill{
	name = "jl_fengcu",
	n = 1,
	view_filter = function(self,selected,to_select)
		if to_select:isEquipped() then return end
        return to_select:getSuitString()=="club"
	end,
	view_as = function(self,cards)
		if #cards<1 then return end
		local card = sgs.Sanguosha:cloneCard("iron_chain")
	   	card:setSkillName("lianhuan")
		for _,c in sgs.list(cards)do
			card:addSubcard(c)
		end
		return card
	end,
	enabled_at_play = function(self,player)
		for _,c in sgs.list(player:getHandcards())do
		    if c:getSuitString()=="club"
			then return c end
		end
	end,
}
jl_fengcu = sgs.CreateTriggerSkill{
	name = "jl_fengcu",
	view_as_skill = jl_fengcuVS,
--	frequency = sgs.Skill_Compulsory,
	waked_skills = "lianhuan,niepan",
	events = {sgs.AskForPeaches,sgs.GameStart,sgs.EventAcquireSkill},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.GameStart
		or event==sgs.EventAcquireSkill
		then
    		if player:getMark("@nirvana")<1
			then
		    	room:addPlayerMark(player,"@nirvana")
			end
		elseif player:getMark("@nirvana")>0
		then
	     	local dying = data:toDying()
	    	if dying.who:objectName()==player:objectName()
	     	and player:askForSkillInvoke("niepan",data)
	    	then
				room:broadcastSkillInvoke("niepan")
		    	room:removePlayerMark(player,"@nirvana")
				room:doSuperLightbox(player:getGeneralName(),"niepan")
		    	player:throwAllCards()
		    	room:setPlayerProperty(player,"chained",sgs.QVariant(false))
		    	if not player:faceUp() then player:turnOver() end
		    	player:drawCards(3,"jl_fengcu")
		    	dying = math.min(3,player:getMaxHp())
		    	room:setPlayerProperty(player,"hp",sgs.QVariant(dying))
	    	end
		end
		return false
	end,
}
jl_sicai:addSkill(jl_fengcu)
jl_shuijing = sgs.CreateTriggerSkill{
	name = "jl_shuijing",
	events = {sgs.DamageInflicted,sgs.Damaged},
	waked_skills = "chenghao,yinshi",
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
			local damage = data:toDamage()
			if event==sgs.Damaged
			and damage.nature~=sgs.DamageStruct_Normal
			and not damage.chain and player:isChained()
			and player:objectName()==damage.to:objectName()
			then
				local n = 0
				for _,p in sgs.list(room:getAlivePlayers())do
					if p:isChained() then n = n+1 end
				end
				if n>0
				and room:askForSkillInvoke(owner,"chenghao",data)
				then
					room:broadcastSkillInvoke("chenghao")
					local guojias = sgs.SPlayerList()
					guojias:append(owner)
					local cards = room:getNCards(n,false)
	   	        	local move = sgs.CardsMoveStruct(cards,nil,owner,sgs.Player_PlaceTable,sgs.Player_PlaceHand,
		        	sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,owner:objectName(),"chenghao",nil))
		        	local moves = sgs.CardsMoveList()
		        	moves:append(move)
		        	room:notifyMoveCards(true,moves,false,guojias)
		        	room:notifyMoveCards(false,moves,false,guojias)
		        	local origin = sgs.IntList()
		        	for _,id in sgs.list(cards)do
		        		origin:append(id)
		        	end
		        	while room:askForYiji(owner,cards,"chenghao",true,false,true,-1,room:getAlivePlayers())do
		        		local move = sgs.CardsMoveStruct(sgs.IntList(),owner,nil,sgs.Player_PlaceHand,sgs.Player_PlaceTable,
		        		sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,owner:objectName(),"chenghao",nil))
		        		for _,id in sgs.list(origin)do
		        			if room:getCardPlace(id)~=sgs.Player_DrawPile
							then
		        				move.card_ids:append(id)
		        				cards:removeOne(id)
		        			end
		        		end
		        		origin = sgs.IntList()
		        		for _,id in sgs.list(cards)do
		        			origin:append(id)
		        		end
		        		local moves = sgs.CardsMoveList()
		        		moves:append(move)
		        		room:notifyMoveCards(true,moves,false,guojias)
		        		room:notifyMoveCards(false,moves,false,guojias)
		        	end
		        	if not cards:isEmpty()
					then
		        		local move = sgs.CardsMoveStruct(cards,owner,nil,sgs.Player_PlaceHand,sgs.Player_PlaceTable,
		        		sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,owner:objectName(),"chenghao",nil))
		        		local moves = sgs.CardsMoveList()
		        		moves:append(move)
		        		room:notifyMoveCards(true,moves,false,guojias)
		        		room:notifyMoveCards(false,moves,false,guojias)
		        		local dummy = sgs.Sanguosha:cloneCard("slash")
		        		dummy:addSubcards(cards)
		        		owner:obtainCard(dummy,false)
		        	end
				end
			end
   	    	if event==sgs.DamageInflicted
			and damage.to:objectName()==owner:objectName()
			and owner:getMark("&dragon_signet")+owner:getMark("&phoenix_signet")<1
	       	and (damage.nature~=sgs.DamageStruct_Normal or damage.card and damage.card:isKindOf("TrickCard"))
	       	and not owner:getArmor()
			then
				room:sendCompulsoryTriggerLog(owner,"yinshi",true,true)
				return DamageRevises(data,-damage.damage,owner)
			end
		end
		return false
	end,
}
jl_sicai:addSkill(jl_shuijing)
jl_xuanjianCard = sgs.CreateSkillCard{
	name = "jl_jianyanCard",
	will_throw = false,
	target_fixed = true,
	on_use = function(self,room,source,targets)
		local choice = room:askForChoice(source,"jianyan","red+black+BasicCard+TrickCard+EquipCard")
		if choice=="red"
		then choice = "heart+diamond"
		elseif choice=="black"
		then choice = "club+spade"
		end
       	local tgdt = sgs.Sanguosha:cloneCard("slash")
		room:broadcastSkillInvoke("jianyan")
    	while choice do
    		local id = room:drawCard()
	      	local move = sgs.CardsMoveStruct()
	     	move.card_ids:append(id)
        	move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER,source:objectName(),"jianyan","")
   	    	move.to_place = sgs.Player_PlaceTable
	    	room:moveCardsAtomic(move,true)
	    	room:getThread():delay(800)
	    	id = sgs.Sanguosha:getCard(id)
			if id:isKindOf(choice)
			or string.find(choice,id:getSuitString())
			then
            	local target = sgs.SPlayerList()
				for _,to in sgs.list(room:getAlivePlayers())do
				    if to:isMale() then target:append(to) end
	    		end
				if target:isEmpty() then tgdt:addSubcard(id) break end
                target = PlayerChosen("jianyan",source,target,"@jianyan:"..id:objectName())
				room:obtainCard(target,id)
				break
			else
	            tgdt:addSubcard(id)
			end
		end
		if tgdt:subcardsLength()<1 then return end
       	choice = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER,source:objectName(),"jianyan",nil)
    	room:throwCard(tgdt,choice,nil)--弃牌
	end
}
jl_xuanjianVS = sgs.CreateViewAsSkill{
	name = "jl_xuanjian",
	view_as = function(self,cards)
		return jl_xuanjianCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#jl_jianyanCard")<1
	end
}
jl_xuanjian = sgs.CreateTriggerSkill{
    name = "jl_xuanjian",
	view_as_skill = jl_xuanjianVS,
	waked_skills = "zhuhai,jianyan",
    events = {sgs.Damage,sgs.EventPhaseStart,sgs.PreCardUsed},
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
    on_trigger = function(self,event,player,data,room)
		for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
        if event==sgs.Damage
		then
            local damage = data:toDamage()
            if damage.from:objectName()~=owner:objectName()
			and damage.from:getPhase()~=sgs.Player_NotActive 
			then
    			room:setPlayerFlag(damage.from,"xuanjian-Clear")
			end
        elseif event==sgs.EventPhaseStart
		then
	    	if player:getPhase()==sgs.Player_Finish 
	    	and player:hasFlag("xuanjian-Clear")
	      	then
		    	local new = sgs.QVariant()
		    	new:setValue(player)
		    	room:setTag("xuanjian",new)
				owner:setFlags("xuanjian")
	    		room:askForUseSlashTo(owner,player,"@xuanjian:"..player:objectName(),false)
	    		owner:setFlags("-xuanjian")
	        end
		elseif owner:hasFlag("xuanjian")
		then
			owner:setFlags("-xuanjian")
		    room:broadcastSkillInvoke("zhuhai")
 	   	end
		end
		return false
    end,
}
jl_sicai:addSkill(jl_xuanjian)

jl_simahuini = sgs.General(extension,"jl_simahuini","qun",3)
jl_jianjieCard = sgs.CreateSkillCard{
	name = "jl_jianjieCard",
	filter = function(self,targets,to_select,from)
		local plists = from:getAliveSiblings()
		plists:append(from)
       	for _,p in sgs.list(plists)do
	    	if p:getMark("&jl_longyin")>0
		    or p:getMark("&jl_fengyin")>0
			then plists = 1 break end
		end
		if plists~=1
		then return #targets<2
		else
			if #targets<1
			then
	    		if to_select:getMark("&jl_longyin")>0
		    	or to_select:getMark("&jl_fengyin")>0
		    	then return true end
			else return targets[1]:objectName()~=to_select:objectName()
			and #targets<2 end
		end
	end,
	feasible = function(self,targets)
		return #targets>1
	end,
	about_to_use = function(self,room,use)
		local choice = {}
		NotifySkillInvoked("jl_jianjie",use.from,use.to)
		if use.to:at(0):getMark("&jl_longyin")>0
		then table.insert(choice,"jl_longyin")
		end
		if use.to:at(0):getMark("&jl_fengyin")>0
		then table.insert(choice,"jl_fengyin")
		end
		if #choice>0
		then
	    	choice = room:askForChoice(use.from,self:objectName(),table.concat(choice,"+"))
			use.to:at(0):loseMark("&"..choice)
			use.to:at(1):gainMark("&"..choice)
			use.to:at(0):setFlags("jl_jianjiebf")
		else
			use.to:at(0):gainMark("&jl_longyin")
			use.to:at(1):gainMark("&jl_fengyin")
		end
		
	end,
}
jl_jianjieVS = sgs.CreateZeroCardViewAsSkill{
	name = "jl_jianjie",
	response_pattern = "@@jl_jianjie",
	view_as = function(self)
		return jl_jianjieCard:clone()
	end,
	enabled_at_play = function(self,player)
		return false
	end,
}
jl_jianjie = sgs.CreateTriggerSkill{
	name = "jl_jianjie",
	events = {sgs.EventPhaseStart,sgs.Death},
	waked_skills = "tenyearzhixi,wumou,benghuai",
	view_as_skill = jl_jianjieVS,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseStart
		then
			if player:getPhase()==sgs.Player_Start
			then
	    		room:askForUseCard(player,"@@jl_jianjie","@jl_jianjie")
			end
		else
			local death = data:toDeath()
			death = death.who
			local death1 = death
			if death:getMark("&jl_longyin")>0
			then
				death = PlayerChosen(self,player,room:getOtherPlayers(death),"#jl_jianjie:jl_longyin")
				death:gainMark("&jl_longyin")
			end
			if death1:getMark("&jl_fengyin")>0
			then
				death = PlayerChosen(self,player,room:getOtherPlayers(death),"#jl_jianjie:jl_fengyin")
				death:gainMark("&jl_fengyin")
			end
		end
       	for _,p in sgs.list(room:getAlivePlayers())do
		   	if not p:hasSkill("tenyearzhixi")
			and p:getMark("&jl_longyin")>0
		   	then room:acquireSkill(p,"tenyearzhixi")
		   	end
		   	if not p:hasSkill("wumou")
			and p:getMark("&jl_fengyin")>0
		   	then room:acquireSkill(p,"wumou")
		   	end
		   	if not p:hasSkill("benghuai")
			and p:getMark("&jl_longyin")>0
			and p:getMark("&jl_fengyin")>0
		   	then room:acquireSkill(p,"benghuai")
		   	end
		   	if p:hasSkill("tenyearzhixi")
			and p:getMark("&jl_longyin")<1
			and p:hasFlag("jl_jianjiebf")
		   	then room:detachSkillFromPlayer(p,"tenyearzhixi",false,true)
		   	end
		   	if p:hasSkill("wumou")
			and p:getMark("&jl_fengyin")<1
			and p:hasFlag("jl_jianjiebf")
		   	then room:detachSkillFromPlayer(p,"wumou",false,true)
		   	end
		   	if p:hasSkill("benghuai")
			and (p:getMark("&jl_longyin")<1
			or p:getMark("&jl_fengyin")<1)
			and p:hasFlag("jl_jianjiebf")
		   	then room:detachSkillFromPlayer(p,"benghuai",false,true)
		   	end
			p:setFlags("-jl_jianjiebf")
	    end
	end,
}
jl_simahuini:addSkill(jl_jianjie)
jl_chencha = sgs.CreateTriggerSkill{
	name = "jl_chencha",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardFinished,sgs.Damage},
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
   		if event==sgs.CardFinished
	   	then
	       	local use = data:toCardUse()
	       	if use.card:isDamageCard()
	       	then
				if not use.card:hasFlag("jl_chencha"..player:objectName())
				and owner:askForSkillInvoke(self:objectName(),ToData(player))
				then room:loseHp(player) end
				use.card:setFlags("-jl_chencha"..player:objectName())
	       	end
    	elseif event==sgs.Damage
		then
		    local damage = data:toDamage()
        	if damage.card
        	then
				damage.card:setFlags("jl_chencha"..player:objectName())
			end
		end
		end
		return false
	end
}
jl_simahuini:addSkill(jl_chencha)
jl_yinshi = sgs.CreateTriggerSkill{
	name = "jl_yinshi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted,sgs.DamageCaused},
	on_trigger = function(self,event,player,data,room)
    	if event==sgs.DamageInflicted
		then
		    local damage = data:toDamage()
        	if damage.from
        	then
	        	room:sendCompulsoryTriggerLog(player,self:objectName())
				if damage.from:getGender()==player:getGender()
				then return DamageRevises(data,-1,player)
				else DamageRevises(data,1,player) end
			end
    	elseif event==sgs.DamageCaused
		then
		    local damage = data:toDamage()
            room:sendCompulsoryTriggerLog(player,self:objectName())
			if damage.to:getGender()~=player:getGender()
			then return DamageRevises(data,-1,player)
			else DamageRevises(data,1,player) end
		end
		return false
	end
}
jl_simahuini:addSkill(jl_yinshi)

jl_liuzhang = sgs.General(extension,"jl_liuzhang","qun",3)
jl_fuhun = sgs.CreateTriggerSkill{
	name = "jl_fuhun",
	events = {sgs.EventPhaseStart,sgs.Death},
	frequency = sgs.Skill_Limited,
	waked_skills = "tushe,limu",
	limit_mark = "@jl_fuhun",
	can_trigger = function(self,target)
		return target and target:hasSkill(self)
		and target:getMark("@jl_fuhun")>0
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseStart
		and player:getMark("@jl_fuhun")>0
		then
			if player:getPhase()==sgs.Player_Start
			and player:askForSkillInvoke(self:objectName(),data)
			then
		    	room:removePlayerMark(player,"@jl_fuhun")
				room:doSuperLightbox("jl_liuzhang","jl_fuhun")
				room:changeHero(player,"liuyan",true)
			end
		end
	end,
}
jl_liuzhang:addSkill(jl_fuhun)
jl_jutu = sgs.CreateTriggerSkill{
	name = "jl_jutu",
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
		then
	    	local change = data:toPhaseChange()
	    	if change.from~=sgs.Player_NotActive then return end
     		local zb
	    	for _,id in sgs.list(room:getDiscardPile())do
	         	id = sgs.Sanguosha:getCard(id)
				if id:isKindOf("Spear")
	        	then zb = id end
		    end
	    	for _,id in sgs.list(room:getDrawPile())do
	         	id = sgs.Sanguosha:getCard(id)
				if id:isKindOf("Spear")
	        	then zb = id end
	    	end
			if zb
			then
	    		room:sendCompulsoryTriggerLog(player,self:objectName())
             	room:useCard(sgs.CardUseStruct(zb,player,player))
			end
		end
		return false
	end,
}
jl_liuzhang:addSkill(jl_jutu)

jl_jugong = sgs.General(extension,"jl_jugong","qun",3)
jl_jugong:addSkill("shibei")
jl_jugong:addSkill("zhichi")

--游卡
jl_youka = sgs.General(extension,"jl_youka","god",6,true,hidden)
jl_wuma = sgs.CreateFilterSkill{
	name = "jl_wuma",
	view_filter = function(self,card)
		return card:isKindOf("DefensiveHorse")
		or card:isKindOf("OffensiveHorse")
	end,
	view_as = function(self,card)
		local jink = sgs.Sanguosha:cloneCard("ex_nihilo",card:getSuit(),card:getNumber())
    	jink:setSkillName("jl_wuma")
	    local wrap = sgs.Sanguosha:getWrappedCard(card:getEffectiveId())
	    wrap:takeOver(jink)
	    return wrap
	end
}
jl_youka:addSkill(jl_wuma)
jl_wumabf = sgs.CreateTriggerSkill{
	name = "#jl_wumabf",
	events = {sgs.CardsMoveOneTime,sgs.DamageInflicted},
	can_trigger = function(self,target)
		return target and target:hasSkill("jl_wuma")
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.DamageInflicted
		then
	    	local damage = data:toDamage()
			if damage.from and damage.from:hasWeapon("kylin_bow")
			and damage.card and damage.card:isKindOf("Slash")
			then
	    		damage.damage = damage.damage+1
				room:setEmotion(damage.from,"weapon/kylin_bow")
				data:setValue(damage)
			end
		end
		if player:getMark("@Equip2lose")<1
		then player:throwEquipArea(2) end
		if player:getMark("@Equip3lose")<1
		then player:throwEquipArea(3) end
		return false
	end
}
jl_youka:addSkill(jl_wumabf)
extension:insertRelatedSkills("jl_wuma", "#jl_wumabf")
jl_yinbingVS = sgs.CreateViewAsSkill{
	name = "jl_yinbing",
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern==""
		then
	       	pattern = sgs.Self:getTag("jl_yinbing"):toCard():objectName()
		end
	   	pattern = sgs.Sanguosha:cloneCard(pattern:split("+")[1])
       	pattern:setSkillName("jl_yinbing")
	   	return pattern
	end,
	enabled_at_response = function(self,player,pattern)
		if string.sub(pattern,1,1)=="."
		or string.sub(pattern,1,1)=="@"
		or string.sub(pattern,1,1)==""
		then return end
        if pattern=="peach+analeptic" and player:getMark("Global_PreventPeach")>0
		then pattern = "analeptic" end
	   	pattern = sgs.Sanguosha:cloneCard(pattern:split("+")[1])
		if pattern
    	and player:getMark("noyinbing-Clear")<1
		then
	     	pattern:deleteLater()
	    	return pattern:isKindOf("BasicCard") or pattern:isKindOf("TrickCard")
		end
	end,
	enabled_at_nullification = function(self,player)
    	return player:getMark("noyinbing-Clear")<1
	end,
	enabled_at_play = function(self,player)
        return player:getMark("noyinbing-Clear")<1
	end
}
jl_yinbing = sgs.CreateTriggerSkill{
	name = "jl_yinbing",
	events = {sgs.CardUsed,sgs.CardResponded},
	view_as_skill = jl_yinbingVS,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardUsed
		or event==sgs.CardResponded
		then
			local card
			if event==sgs.CardResponded
			and not data:toCardResponse().m_isUse
			then card = data:toCardResponse().m_card
			else card = data:toCardUse().card end
            if card and card:getSkillName()=="jl_yinbing"
	    	then
		   		room:addPlayerMark(player,"noyinbing-Clear")
				card = PlayerChosen(self,player,room:getOtherPlayers(player),"#jl_yinbing")
				room:damage(sgs.DamageStruct("jl_yinbing",player,card))
	     	end
     	end
		return false
	end
}
jl_yinbing:setGuhuoDialog("lr")
jl_youka:addSkill(jl_yinbing)
jl_piankecard = sgs.CreateSkillCard{
	name = "jl_piankecard",
	will_throw = false,
	target_fixed = true,
	on_use = function(self,room,source,targets)
		source:addToPile("pianke",self,false)
       	source:drawCards(self:subcardsLength(),self:objectName())
		return false
	end
}
jl_piankevs = sgs.CreateViewAsSkill{
	name = "jl_pianke",
	n = 99,
	view_filter = function(self,selected,to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self,cards)
		local card = jl_piankecard:clone()
		if #cards<1 then return end
		for _,c in sgs.list(cards)do
			card:addSubcard(c)
		end
		return card
	end,
	enabled_at_response = function(self,player,pattern)
		return pattern=="@@jl_pianke"
	end,
	enabled_at_play = function(self,player)
		return not player:isKongcheng()
		and player:getPile("pianke"):isEmpty()
	end
}
jl_pianke = sgs.CreateTriggerSkill{
	name = "jl_pianke",
	events = {sgs.EventPhaseStart,sgs.DamageInflicted},
	view_as_skill = jl_piankevs,
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
	    	if event==sgs.EventPhaseStart
	    	and player:getPhase()==sgs.Player_Play
		    and player:objectName()~=owner:objectName()
	    	and not player:isKongcheng()
	    	and owner:getPile("pianke"):length()>0
	    	and room:askForSkillInvoke(owner,self:objectName(),ToData(player))
	    	then
	         	local card = room:askForExchange(player,self:objectName(),1,1,false,"pianke")
	           	room:obtainCard(owner,card)
	         	local id = owner:getPile("pianke"):first()
	    		id = sgs.Sanguosha:getCard(id)
	           	room:obtainCard(player,id)
				if id:getNumber()~=card:getNumber()
				then room:damage(sgs.DamageStruct("jl_pianke",owner,player))
				else room:loseHp(owner) end
	    	end
		end
		return false
	end
}
jl_youka:addSkill(jl_pianke)

jl_sunbb = sgs.General(extension,"jl_sunbb","wu")
jl_jiang = sgs.CreateTriggerSkill{
	name = "jl_jiang",
	events = {sgs.TargetConfirming,sgs.CardFinished},
	frequency = sgs.Skill_Frequent,
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
		local use = data:toCardUse()
		if event==sgs.CardFinished
		then
			for _,to in sgs.list(use.to)do
		    	if to:isDead() then use.to:removeOne(to) end
			end
	    	if use.to:length()>0
			and owner:hasFlag("jl_jiang"..use.card:toString())
			then
	    		owner:setTag("jl_jiang",data)
				owner:setFlags("-jl_jiang"..use.card:toString())
	         	local c = "jl_jiang0:"..use.card:objectName()..":"..use.card:getSuitString()
				c = room:askForCard(owner,".|"..use.card:getSuitString().."|.|hand",c,data,sgs.Card_MethodNone)
	        	if c
		    	then
			    	local toc = sgs.Sanguosha:cloneCard(use.card:objectName())
			    	toc:setSkillName("_jiang")
			    	toc:addSubcard(c)
			    	if use.from:isAlive()
					and use.from:objectName()~=owner:objectName()
			    	then use.to = use.from end
			    	room:useCard(sgs.CardUseStruct(toc,owner,use.to))
		    	end
			end
		elseif use.from:objectName()==owner:objectName()
		or use.to:contains(owner)
		then
			if (use.card:isKindOf("Duel") or use.card:isKindOf("Slash") and use.card:isRed())
			and owner:askForSkillInvoke(self:objectName(),data)
			then
		    	room:broadcastSkillInvoke("jiang",math.random(1,2))
				owner:setFlags("jl_jiang"..use.card:toString())
				owner:drawCards(1,self:objectName())
			end
		end
		end
		return false
	end
}
jl_sunbb:addSkill(jl_jiang)
jl_yingzi = sgs.CreateTriggerSkill{
	name = "jl_yingzi",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local n = data:toInt()
		for i = 1,2 do
		    if room:askForSkillInvoke(player,"jl_yingzi",data)
	     	then n = n+1 room:broadcastSkillInvoke("yingzi",math.random(7,8))
			else break end
		end
		data:setValue(n)
	end
}
jl_sunbb:addSkill(jl_yingzi)
jl_yinghun = sgs.CreateTriggerSkill{
	name = "jl_yinghun",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self,event,player,data,room)
		if player:getPhase()==sgs.Player_Start
		then
			local n = player:getLostHp()
			local to = room:askForPlayerChosen(player,room:getOtherPlayers(player),"jl_yinghun","jl_yinghun0:"..n,true,true)
			if to
			then
		       	room:broadcastSkillInvoke("yinghun",math.random(3,4))
		    	PlayerHandcardNum(to,self,n)
			end
		end
		return false
	end,
}
jl_sunbb:addSkill(jl_yinghun)
jl_jianzheng = sgs.CreateTriggerSkill{
	name = "jl_jianzheng",
	events = {sgs.TargetSpecifying},
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		local use = data:toCardUse()
		for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
			if use.card:isKindOf("Slash") and use.card:isRed()
			and owner:objectName()~=player:objectName()
			and not use.to:contains(owner)
			then
	    		owner:setTag("jl_jianzheng",data)
				local card = room:askForExchange(owner,"jl_jianzheng",1,1,false,"jl_jianzheng0:"..use.card:objectName(),true)
				if card
				then
		        	NotifySkillInvoked("jianzheng",owner)
					room:moveCardsInToDrawpile(owner,card,"jl_jianzheng",1)
					use.to = sgs.SPlayerList()
					use.to:append(owner)
					data:setValue(use)
				end
			end
		end
	end,
}
jl_sunbb:addSkill(jl_jianzheng)

jl_lvmeng = sgs.General(extension,"jl_lvmeng","wu")
--jl_lvmeng:addSkill("keji")
jl_keji = sgs.CreateTriggerSkill{
	name = "jl_keji",
	frequency = sgs.Skill_Frequent,
	events = {sgs.PreCardUsed,sgs.CardResponded,sgs.EventPhaseChanging},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_Discard
			then
				if not player:hasFlag("jl_kejiSlash")
				and player:askForSkillInvoke(self:objectName())
				then
		        	room:broadcastSkillInvoke("keji",math.random(1,2))
			    	player:skip(change.to)
                 	for _,p in sgs.list(room:getOtherPlayers(player))do
				    	p:gainMark("&jl_kongju")
					end
				end
			end
			player:setFlags("-jl_kejiSlash")
		elseif player:getPhase()==sgs.Player_Play
		then
	    	local card
			if event==sgs.CardResponded
			then card = data:toCardResponse().m_card
			else card = data:toCardUse().card end
			if card:isKindOf("Slash")
			then
				player:setFlags("jl_kejiSlash")
			end
		end
		return false
	end
}
jl_lvmeng:addSkill(jl_keji)
jl_weihecard = sgs.CreateSkillCard{
	name = "jl_weihecard",
	will_throw = false,
	target_fixed = true,
	on_use = function(self,room,source,targets)
		room:removePlayerMark(source,"@jl_weihe")
		room:doSuperLightbox(source:getGeneralName(),"jl_weihe")
		local role = source:getRole()
		if role=="loyalist"
		or role=="lord"
		then role = "lord+loyalist" end
		room:gameOver(role)
		return false
	end
}
jl_weihevs = sgs.CreateViewAsSkill{
	name = "jl_weihe",
	view_as = function(self,cards)
		return jl_weihecard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:getMark("@jl_weihe")>0
		and player:getHandcardNum()>99
	end
}
jl_weihe = sgs.CreateTriggerSkill{
	name = "jl_weihe",
	frequency = sgs.Skill_Compulsory,
--	limit_mark = "@jl_weihe",
	events = {sgs.Death,sgs.CardsMoveOneTime},
--	view_as_skill = jl_weihevs,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Death
		then
	     	local who = data:toDeath().who
	    	if who:objectName()==player:objectName()
			or who:getMark("&jl_kongju")<1
			then return end
			player:drawCards(who:getMark("&jl_kongju"),self:objectName())
		end
		if player:getHandcardNum()>99
		then
	    	player:setTag("jl_houqi",sgs.QVariant(true))
		else
	    	player:setTag("jl_houqi",sgs.QVariant(false))
		end
	end
}
jl_lvmeng:addSkill(jl_weihe)
jl_houqi = sgs.CreateTriggerSkill{
	name = "jl_houqi",
	events = {sgs.MarkChanged},
	frequency = sgs.Skill_Wake,
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
	    	if event==sgs.MarkChanged
			and owner:getMark("jl_houqi")<1
		    then
		    	local mark = data:toMark()
       	    	if string.find(mark.name,"jl_kongju")
				then
					mark = 0
                	for _,p in sgs.list(room:getAlivePlayers())do
		                mark = mark+p:getMark("&jl_kongju")
	            	end
					if mark>99
					or owner:canWake(self:objectName())
					or owner:getTag("jl_houqi"):toBool()
					then
	            		room:sendCompulsoryTriggerLog(owner,self:objectName())
	                	room:addPlayerMark(owner,"jl_houqi")
	                 	room:doSuperLightbox(owner:getGeneralName(),self:objectName())
	                	mark = owner:getRole()
	                	if mark=="loyalist"
	                	or mark=="lord"
	                	then mark = "lord+loyalist" end
	                	room:gameOver(mark)
					end
				end
	    	end
		end
		return false
	end,
}
jl_lvmeng:addSkill(jl_houqi)

jl_caoang = sgs.General(extension,"jl_caoang","wei")
jl_yangguang = sgs.CreateTriggerSkill{
	name = "jl_yangguang",
	events = {sgs.DamageInflicted,sgs.TargetConfirming},
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.TargetConfirming
		then
            local use = data:toCardUse()
	       	if use.card:isKindOf("Slash")
			then
	           	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
               	for _,to in sgs.list(use.to)do
 	                data:setValue(to)
		         	if owner:askForSkillInvoke(self:objectName(),data)
					then
                  		local jink,tos = nil,sgs.SPlayerList()
	                   	for _,id in sgs.list(room:getDrawPile())do
	                       	if jink then break end
							id = sgs.Sanguosha:getCard(id)
	               			if id:isKindOf("Jink")
	                       	then jink = id end
	                   	end
	                   	for _,id in sgs.list(room:getDiscardPile())do
	                       	if jink then break end
	                       	id = sgs.Sanguosha:getCard(id)
		              		if id:isKindOf("Jink")
	                     	then jink = id end
		                end
						if jink
						then
	                    	room:obtainCard(owner,jink)
							jink = sgs.IntList()
	                    	for _,c in sgs.list(owner:getCards("he"))do
	                         	jink:append(c:getEffectiveId())
		                    end
							tos:append(to)
							owner:setTag("jl_yangguang",data)
							if room:askForYiji(owner,jink,self:objectName(),true,true,true,1,tos,sgs.CardMoveReason(),"@jl_yangguang:"..to:objectName())
							then use.card:setTag("jl_yangguang",sgs.QVariant(to:objectName())) end
						end
					end
				end
	           	end
			end
 	        data:setValue(use)
	    elseif event==sgs.DamageInflicted
	    then
	        local damage = data:toDamage()
			if damage.card
			and damage.card:getTag("jl_yangguang"):toString()==player:objectName()
			and room:askForCard(player,"jink","@jl_yangguang1:"..damage.card:objectName(),data,sgs.Card_MethodUse)
			then return true end
		end
		return false
	end,
}
jl_caoang:addSkill(jl_yangguang)

jl_sanyinxiang = sgs.General(extension,"jl_sanyinxiang","god")
jl_kuangcai = sgs.CreateTriggerSkill{
	name = "jl_kuangcai",
	events = {sgs.CardUsed,sgs.EventPhaseStart},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseStart
		and player:getPhase()==sgs.Player_Play
		and player:askForSkillInvoke(self:objectName())
		then
		    room:broadcastSkillInvoke(self:objectName())--播放配音
			room:addPlayerMark(player,"jl_kuangcai-PlayClear")
		elseif event==sgs.CardUsed
		then
			local card = data:toCardUse().card
			if card and card:getTypeId()~=0
			and player:getPhase()==sgs.Player_Play
			and player:getMark("jl_kuangcai-PlayClear")>0
			then
		        room:broadcastSkillInvoke(self:objectName())--播放配音
				player:drawCards(1,self:objectName())
				room:addPlayerMark(player,"&jl_kuangcai-PlayClear")
				if player:getMark("&jl_kuangcai-PlayClear")>=5
				then
					room:setPlayerFlag(player,"Global_PlayPhaseTerminated")
				end
			end
		end
		return false
	end
}
jl_sanyinxiang:addSkill(jl_kuangcai)
jl_sanyinxiang:addSkill("yinshicai")
jl_sanyinxiang:addSkill("cunmu")
jl_sanyinxiang:addSkill("fenyin")

jl_yuanyan = sgs.General(extension,"jl_yuanyan","qun")
jl_yuanyan:addSkill("tushe")
jl_yuanyan:addSkill("luanji")

--[[
jl_jiangj = sgs.General(extension,"jl_jiangj","wei")
jl_kunfencard = sgs.CreateSkillCard{
	name = "jl_kunfencard",
--	will_throw = false,
	filter = function(self,targets,to_select,source)
	   	return #targets<1
	end,
	on_use = function(self,room,source,targets)
	   	room:broadcastSkillInvoke("jl_kunfen")--播放配音
    	for _,to in sgs.list(targets)do
            room:damage(sgs.DamageStruct(self,source,to))
        end
	   	return false
  	end
}
jl_kunfen = sgs.CreateViewAsSkill{
	name = "jl_kunfen",
	n = 2,
	view_filter = function(self,selected,to_select)
		return to_select
	end,
	view_as = function(self,cards)
		local card = jl_kunfencard:clone()
		if #cards<2 then return end
		for _,c in sgs.list(cards)do
			card:addSubcard(c)
		end
		return card
	end,
	enabled_at_play = function(self,player)
		return not player:isNude()
	end
}
jl_jiangj:addSkill(jl_kunfen)
jl_fengliang = sgs.CreateTriggerSkill{
	name = "jl_fengliang",
	frequency = sgs.Skill_Limited,
	limit_mark = "@jl_fengliang",
	waked_skills = "jl_diaoxie",
	events = {sgs.Damage,sgs.EventPhaseChanging},
	can_trigger = function(self,target)
		if not target then return end
		return target:hasSkill(self:objectName())
		and target:getMark("@jl_fengliang")>0
	end,
	on_trigger = function(self,event,player,data,room)
        if event==sgs.EventPhaseChanging
		then
	    	local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			and player:getMark("&jl_fengliang-Clear")>player:getHp()
			and player:askForSkillInvoke(self:objectName(),data)
    		then
				room:doSuperLightbox(player:getGeneralName(),"jl_fengliang")
		    	room:loseMaxHp(player)
	        	room:recover(player,sgs.RecoverStruct(player))
				change = PlayerChosen(self,player,nil,"#jl_fengliang:jl_diaoxie")
	        	room:acquireSkill(change,"jl_diaoxie")
			end
    	elseif event==sgs.Damage
		then
		    local damage = data:toDamage()
			room:addPlayerMark(player,"&jl_fengliang-Clear")
		end
	end
}
jl_jiangj:addSkill(jl_fengliang)
jl_diaoxie = sgs.CreateProhibitSkill{
	name = "jl_diaoxie",
	is_prohibited = function(self,from,to,card)
    	local x = 0 --sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,from,card)
		if card:isDamageCard()
		and (card:isKindOf("BasicCard") or card:isKindOf("SingleTargetTrick"))
		then
            for _,p in sgs.list(from:getAliveSiblings())do
               	if p:hasSkill(self:objectName())
             	then x = x+1 end
         	end
	    	return x>0 and not to:hasSkill(self:objectName())
		end
	end
}
addToSkills(jl_diaoxie)
--]]
jl_gouhuo = sgs.General(extension,"jl_gouhuo","wei",3)
jl_yeducard = sgs.CreateSkillCard{
	name = "jl_yeducard",
	will_throw = false,
	filter = function(self,targets,to_select,source)
	   	return #targets<1
		and to_select:objectName()~=source:objectName()
	end,
	on_use = function(self,room,source,targets)
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern=="@@jl_yedu1" then return end
		for _,to in sgs.list(targets)do
			to:drawCards(1,self:objectName())
			if source:canPindian(to)
			then
	    		local pd = source:PinDian(to,"jl_yedu",self)
				if pd.success
				then
		     		if to:getMark("jl_yeduto")<1
					then
				    	if room:askForDiscard(to,"jl_yedu",1,1,true,true,"@jl_yedu:"..source:objectName())
						then
			    			room:loseHp(to)
							room:addSlashCishu(source,1)
						else
				    		to:turnOver()
	                		source:drawCards(source:getLostHp(),self:objectName())
                			to:drawCards(to:getLostHp(),self:objectName())
							if room:askForDiscard(source,"jl_yedu",1,1,true,true,"@jl_yedu1:")
							then
			        			room:loseHp(source)
								room:addPlayerMark(source,"jl_yeducarduse-PlayClear")
	                    		source:drawCards(source:getMaxHp()-source:getHandcardNum(),self:objectName())
							end
						end
					else
			    		if room:askForChoice(source,"jl_yedu","jl_yeduchoice1+jl_yeduchoice2")=="jl_yeduchoice1"
						then
				     		room:damage(sgs.DamageStruct(self,source,to))
	                		source:drawCards(1,self:objectName())
							if to:isDead() then continue end
                			to:drawCards(1,self:objectName())
							local h1,h2 = source:getHandcardNum(),source:getHandcardNum()
							if h1~=h2
							then
				    			if h1>h2
				    			then
						    		h1 = source
									h2 = to
								else
						    		h1 = to
									h2 = source
								end
								local id = room:askForCardChosen(h2,h1,"h","jl_yedu")
	                        	room:obtainCard(h2,id)
	                        	room:showCard(h2,id)
								id = sgs.Sanguosha:getCard(id)
								if id:isKindOf("BasicCard")
								then
						    		if id:isAvailable(h2)
									and room:askForUseCard(h2,id:getEffectiveId(),"@jl_yedu5:"..id:objectName())
									then else room:loseHp(h2) end
								elseif id:isKindOf("TrickCard")
								then
	                            	id = room:askForExchange(h2,"jl_yedu",1,1,true,"@jl_yedu6:"..h1:objectName(),true,"TrickCard")
									if id
									then
	                                	room:obtainCard(h1,id)
									else
								    	room:askForDiscard(h2,"jl_yedu",2,2,false,true,"@jl_yedu7:","^TrickCard")
									end
								else
							    	room:useCard(sgs.CardUseStruct(id,h2,h2))
									room:loseHp(h2)
								end
							end
						else
							local toc,x = sgs.Sanguosha:cloneCard("slash"),0
							if to:isDead() then continue end
							toc:addSubcards(to:getCards("hej"))
							x = to:getEquips():length()+to:getJudgingArea():length()
							room:setPlayerMark(source,"jl_yedu+"..to:objectName().."-Clear",x)
	                        room:obtainCard(source,toc,false)
						end
					end
				else
		     		if to:getMark("jl_yeduto")<1
					then
		            	room:addPlayerMark(to,"jl_yeduto")
	                	local c = room:askForExchange(to,"jl_yedu",1,1,true,"@jl_yedu2",true,".|club,diamond")
						if c
						then
                    	   	local toc = "indulgence"
							if c:getSuitString()=="club"
							then toc = "supply_shortage" end
							toc = sgs.Sanguosha:cloneCard(toc)
							toc:addSubcard(c)
                        	toc:setSkillName("_jl_yedu")
							room:useCard(sgs.CardUseStruct(toc,to,to))
							if to:isDead() then continue end
	                    	room:recover(to,sgs.RecoverStruct(source,self))
						else
							if to:isDead() then continue end
				    		to:turnOver()
                			to:drawCards(to:getLostHp(),self:objectName())
						end
						if source:isDead() then continue end
						c = room:askForExchange(source,"jl_yedu",1,1,false,"@jl_yedu3",true)
						if c
						then
                    	   	local toc = sgs.Sanguosha:cloneCard("iron_chain")
							toc:addSubcard(c)
                        	toc:setSkillName("_jl_yedu")
							room:useCard(sgs.CardUseStruct(toc,source,source))
				    		source:turnOver()
							if source:canPindian()
							then
	    	                 	room:askForUseCard(source,"@@jl_yedu!","@jl_yedu4:jl_yedu")
								room:addPlayerMark(source,"jl_yeduhzj-Clear")
							end
						end
					else
	                	local js = sgs.IntList()
                        for _,j in sgs.list(to:getCards("j"))do
				    		js:append(j:getEffectiveId())
						end
	                	room:notifyMoveToPile(to,js,"jl_yeduj",sgs.Player_PlaceDelayedTrick,true)
						local c = room:askForUseCard(to,"@@jl_yedu1","@jl_yedu8:jl_yedu",-1,sgs.Card_MethodNone)
	                	room:notifyMoveToPile(to,js,"jl_yeduj",sgs.Player_PlaceDelayedTrick,false)
						if to:isDead() then continue end
						if c
						then
	                        room:obtainCard(source,c,false)
							room:addPlayerMark(source,"jl_yedu_no_to_crad-Clear")
							room:addPlayerMark(to,"jl_yedu_blck_crad")
						else
	                        room:obtainCard(source,pd.from_card)
	                        room:obtainCard(source,pd.to_card)
				    		c = room:askForExchange(to,"jl_yedu",1,1,false,"@jl_yedu9:"..source:objectName())
							if c then room:obtainCard(source,c,false) end
							room:loseHp(to)
				          	room:setPlayerFlag(source,"Global_PlayPhaseTerminated")
							room:addPlayerMark(source,"jl_yedujs-Clear")
							room:addPlayerMark(to,"jl_yedu_hdbj")
						end
					end
				end
				local fc,tc = pd.from_card:getSuitString(),pd.to_card:getSuitString()
				for i = 1,2 do
		     		if i<2
					then i = source
					else i = to fc = tc end
		     		if i:isDead() then continue end
					if fc=="heart"
			    	then
	                 	room:recover(i,sgs.RecoverStruct(source,self))
						room:askForDiscard(i,"jl_yedu",1,1,false,true)
			    	elseif fc=="diamond"
			    	then
	                	i:drawCards(2,self:objectName())
						i:turnOver()
			    	elseif fc=="club"
			    	then
						room:askForDiscard(i,"jl_yedu",2,2,false,true)
			    		i:gainAnExtraTurn()
			    	elseif fc=="spade"
			    	then
						room:loseHp(i)
	                	i:drawCards(1,self:objectName())
			    	end
				end
				if source:isDead() then continue end
				fc = room:askForChoice(source,"jl_yedu","jl_yeduchoice3+jl_yeduchoice4+jl_yeduchoice5+jl_yeduchoice6")
				if fc=="jl_yeduchoice3"
				then
                    to:setChained(true)
                    room:broadcastProperty(to,"chained")
                    room:setEmotion(to,"chain")
                    room:getThread():trigger(sgs.ChainStateChanged,room,to)
					to:drawCards(1,self:objectName())
				elseif fc=="jl_yeduchoice4"
				then
			    	for i = 1,3 do
						if to:isNude() then break end
						i = room:askForCardChosen(source,to,"he","jl_yedu")
						room:throwCard(i,to,source)
					end
					to:drawCards(2,self:objectName())
				elseif fc=="jl_yeduchoice5"
				then
					room:damage(sgs.DamageStruct(self,source,to))
					to:drawCards(3,self:objectName())
				elseif fc=="jl_yeduchoice6"
				then
		    		fc = sgs.Sanguosha:cloneCard("slash")
					fc:addSubcards(to:getCards("h"))
	                room:obtainCard(source,fc,false)
					to:drawCards(4,self:objectName())
				end
		    	fc = source:getHandcardNum()-5
				if fc>0
				then
					if not room:askForDiscard(source,"jl_yedu",fc,fc,true,false,"@jl_yedu10:"..fc)
					then room:loseHp(source,source:getHp()-1,false,source,"jl_yedu") end
				elseif fc<0
				then
			    	if room:askForChoice(source,"jl_yedu","jl_yeduchoice7+jl_yeduchoice8")=="jl_yeduchoice7"
					then
				    	fc = 5-source:getHandcardNum()
						source:drawCards(fc,self:objectName())
					else
	                 	fc = source:getLostHp()
						room:recover(source,sgs.RecoverStruct(source,self,fc))
					end
				end
			end
			room:addPlayerMark(to,"jl_yeduto")
        end
	   	return false
  	end
}
jl_yeduVS = sgs.CreateViewAsSkill{
	name = "jl_yedu",
	n = 3,
	expand_pile = "#jl_yeduj",
	view_filter = function(self,selected,to_select)
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern=="@@jl_yedu1"
		then
	    	for _,c in sgs.list(selected)do
	    		if GetCardPlace(sgs.Self,c)==GetCardPlace(sgs.Self,to_select)
				then return false end
	    	end
			return #selected<3
		end
		return not to_select:isEquipped()
		and #selected<1
	end,
	view_as = function(self,cards)
		local card,x = jl_yeducard:clone(),0
		if #cards<1 then return end
		if sgs.Self:hasEquip()
		then x = x+1 end
		if not sgs.Self:isKongcheng()
		then x = x+1 end
		if not sgs.Self:getJudgingArea():isEmpty()
		then x = x+1 end
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern=="@@jl_yedu1"
		and #cards<x then return end
		for _,c in sgs.list(cards)do
			card:addSubcard(c)
		end
		return card
	end,
	enabled_at_response = function(self,player,pattern)
		if pattern=="@@jl_yedu!"
		or pattern=="@@jl_yedu1"
		then return true end
	end,
	enabled_at_play = function(self,player)
		return not player:isKongcheng()
		and player:usedTimes("#jl_yeducard") <= player:getMark("jl_yeducarduse-PlayClear")
	end
}
jl_yedu = sgs.CreateTriggerSkill{
	name = "jl_yedu",
	view_as_skill = jl_yeduVS,
	events = {sgs.EventPhaseChanging,sgs.CardsMoveOneTime},
	can_trigger = function(self,target)
		return target and target:isAlive()
	end,
	on_trigger = function(self,event,player,data,room)
        if event==sgs.EventPhaseChanging
		then
	    	local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
	           	for _,to in sgs.list(room:getAlivePlayers())do
	       			if player:getMark("jl_yedu+"..to:objectName().."-Clear")>0
	               	then
				    	local x = 6+to:getHp()
				    	x = room:askForExchange(player,"jl_yedu",x,x)
						if x then room:obtainCard(to,x,false) end
					end
	           	end
				room:setPlayerMark(player,"jl_yedu_blck_crad",0)
				room:setPlayerMark(player,"jl_yedu_hdbj",0)
			elseif change.to==sgs.Player_Discard
			then
	    		if player:getMark("jl_yedu_blck_crad")>0
				then
	             	for _,c in sgs.list(player:getHandcards())do
				    	if c:isBlack()
						then room:ignoreCards(player,c) end
					end
				end
			end
 	        data:setValue(change)
		elseif event==sgs.CardsMoveOneTime
		then
    		local move = data:toMoveOneTime()
			if move.to
			and move.to:objectName()==player:objectName()
			and (not move.from or move.from:objectName()~=player:objectName())
			and move.to_place==sgs.Player_PlaceHand
			and player:getMark("jl_yedu_hdbj")>0
			then
			    room:ignoreCards(player,move.card_ids)
			end
		end
		return false
	end,
}
jl_gouhuo:addSkill(jl_yedu)
jl_lijie = sgs.CreateTriggerSkill{
	name = "jl_lijie",
	events = {sgs.GameStart},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.GameStart
		and player:hasSkill("jl_yedu")
		and player:askForSkillInvoke(self:objectName(),sgs.QVariant("@jl_lijie:"))
		then
			room:doSuperLightbox(player:getGeneralName(),"jl_lijie")
			room:changeHero(player,"xunyu",true)
		end
		return false
	end,
}
jl_gouhuo:addSkill(jl_lijie)

local toUseCard
toAskUseCard = sgs.CreateViewAsSkill{
	name = "AskUseCard&",
	n = 998,
	expand_pile = "#AskUse",
	view_filter = function(self,selected,to_select)
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if sgs.Self:hasFlag("isVirtualCard")
		then return false end
        return sgs.Self:getPileName(to_select:getEffectiveId())=="#AskUse"
		and #selected<1
	end,
	view_as = function(self,cards)
		if sgs.Self:hasFlag("isVirtualCard")
		then return toUseCard end
		if #cards<1 then return end
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		return cards[1]
	end,
	enabled_at_response = function(self,player,pattern)
		if pattern=="@@AskUse"
		then return true end
	end,
	enabled_at_play = function(self,player)
		return false
	end
}
addToSkills(toAskUseCard)

function AskUseCard(player,card,skna)
	local room,toc = player:getRoom(),nil
	room:attachSkillToPlayer(player,"AskUseCard")
	if card:isVirtualCard()
	then
		toUseCard = card
		room:setPlayerFlag(player,"isVirtualCard")
		toc = room:askForUseCard(player,"@@AskUse",skna)
		room:setPlayerFlag(player,"-isVirtualCard")
	else
	   	local cs,place = sgs.IntList(),room:getCardPlace(card:getEffectiveId())
    	if place~=sgs.Player_PlaceHand
		then
			cs:append(card:getEffectiveId())
			room:notifyMoveToPile(player,cs,"AskUse",place,true)
			toc = room:askForUseCard(player,"@@AskUse",skna)
			room:notifyMoveToPile(player,cs,"AskUse",place,false)
		else
			toc = room:askForUseCard(player,card:getEffectiveId(),skna)
		end
	end
	room:detachSkillFromPlayer(player,"AskUseCard",true,true)
	return toc
end

jl_sunben = sgs.General(extension,"jl_sunben$","wu")
jl_yeduscard = sgs.CreateSkillCard{
	name = "jl_yeduscard",
	will_throw = false,
	target_fixed = true,
	about_to_use = function(self,room,use)
       	if use.to:isEmpty()
		then
          	for _,p in sgs.list(room:getAlivePlayers())do
        		use.to:append(p)
	    	end
		end
	   	self:cardOnUse(room,use)
       	while use do
	   	local n,x = 0,0
        for _,p in sgs.list(room:getAlivePlayers())do
        	n = n+p:getMark("&jl_fus")
        	x = x+p:getHandcardNum()
	    end
		use.from:drawCards(n,self:objectName())
		x = x-use.from:getHandcardNum()
		if use.from:getHandcardNum() <= x
		then
            use.to = sgs.SPlayerList()
			for _,p in sgs.list(room:getAlivePlayers())do
	    		if p:getMark("&jl_fus")>0
		     	then use.to:append(p) end
				p:loseMark("&jl_fus")
			end
			if use.to:isEmpty()
	    	then break
			else self:cardOnUse(room,use) end
		else
            n = 0
			for _,p in sgs.list(room:getAlivePlayers())do
             	n = n+p:getMark("&jl_fus")
	    		p:throwAllCards()
			end
			if n>0
			then
	        	n = room:getNCards(n,false)
            	room:fillAG(n)
	        	for _,p in sgs.list(room:getAlivePlayers())do
	            	if not n:isEmpty()
		        	then
                    	x = room:askForAG(p,n,false,self:objectName())
        	          	room:obtainCard(p,x)
        	            room:takeAG(p,x,false)
                     	n:removeOne(x)
		           	end
	         	end
             	room:clearAG()
	           	if not n:isEmpty()
		       	then
            		while x do
		             	room:notifyMoveToPile(use.from,n,"jl_yedus",sgs.Player_DrawPile,true)
		            	x = room:askForUseCard(use.from,"@@jl_yedus","jl_yedus12:")
		            	room:notifyMoveToPile(use.from,n,"jl_yedus",sgs.Player_DrawPile,false)
					end
		        end
	        	for _,id in sgs.list(n)do
                   	if room:getCardPlace(id)~=sgs.Player_DrawPile
					then n:removeOne(id) end
				end
            	room:fillAG(n)
	           	if not n:isEmpty()
			   	and use.from:askForSkillInvoke(self:objectName(),sgs.QVariant("jl_yedus13:"),false)
		       	then room:moveCardsInToDrawpile(use.from,n,"jl_yedus",1,true)
				else
	            	for _,id in sgs.list(n)do
		    	    	room:throwCard(id,nil)
			    	end
				end
             	room:clearAG()
			end
	    	break
		end
		end
	  	room:setTag("jl_yedus",sgs.QVariant(false))
       	for _,p in sgs.list(room:getAlivePlayers())do
          	if p:hasFlag("jl_yedus_Dying")
			then
	   			p:setFlags("-jl_yedus_Dying")
		   		room:setPlayerFlag(p,"Global_Dying")
	    		room:enterDying(p,p:getTag("jl_yedus_Dying"):toDamage())
			end
	   	end
	end,
	on_use = function(self,room,source,targets)
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern=="@@jl_yedus1" then return end
		room:removePlayerMark(source,"@jl_yedus")
		room:doSuperLightbox(source:getGeneralName(),"jl_yedus")
		room:setTag("jl_yedus",sgs.QVariant(true))
		local ton,typel,choice,num = 0,nil,nil,nil
		for _,to in sgs.list(targets)do
			to:setFlags("jl_yedus_no_to")
		end
		for _,to in sgs.list(targets)do
	    	local n,can = 0,false
          	for _,p in sgs.list(room:getAlivePlayers())do
        		n = n+p:getMark("&jl_fus")
	    	end
			local c = room:askForDiscard(to,"jl_yedus",1,1,false,true,"jl_yedus0:")
			if c
			then
		    	c = sgs.Sanguosha:getCard(c:getSubcards():at(0))
				if n>0
				then
		        	pattern = room:askForChoice(source,"jl_yedus","jl_yedus1="..n.."+jl_yedus2="..n.."+cancel")
					if pattern=="jl_yedus1="..n
					then c:setNumber(c:getNumber()+n)
					elseif pattern=="jl_yedus2="..n
					then c:setNumber(c:getNumber()-n)
					end
				end
				if choice=="jl_yedus3"
				and typel==c:getType()
				then can = typel
				elseif choice=="jl_yedus4"
				and typel~=c:getType()
				then can = typel end
				to:setFlags("jl_yedusto")
				if choice
				then
			    	if can
					then
                		targets[ton]:drawCards(1,self:objectName())
					else
			    		room:acquireSkill(to,"guhuo")
			    		room:acquireSkill(targets[ton],"chanyuan")
						targets[ton]:setFlags("jl_yedusS")
						to:setFlags("jl_yedusS")
					end
				end
				choice = room:askForChoice(to,"jl_yedus","jl_yedus3+jl_yedus4")
				typel = c:getType()
				if c:isKindOf("BasicCard")
				then
			    	if to:askForSkillInvoke(self:objectName(),sgs.QVariant("jl_yedus7:"..c:objectName()),false)
					then
			    		room:moveCardsInToDrawpile(to,c,"jl_yedus",1,true)
						to:drawCards(1,self:objectName(),false)
					end
				elseif c:isKindOf("TrickCard")
				then
               	   	local toc = sgs.Sanguosha:cloneCard("slash")
		    		toc:addSubcard(c)
                   	toc:setSkillName("_jl_yedus")
					AskUseCard(source,toc,"jl_yedus6:"..c:objectName())
				else
			    	if to:askForSkillInvoke(self:objectName(),sgs.QVariant("jl_yedus5:"..c:objectName()..":"..source:objectName()),false)
					then room:moveCardsInToDrawpile(to,c,"jl_yedus",1,true)
					else room:obtainCard(source,c) end
				end
				if num
				then
		    		if num<c:getNumber()
					then
				    	pattern = room:askForExchange(to,"jl_yedus",1,1,true,"jl_yedus8:"..source:objectName(),true)
						if pattern
						then
					    	room:obtainCard(source,pattern)
							if pattern:isKindOf("EquipCard")
							or pattern:isKindOf("DelayedTrick")
							then
					    		room:askForUseCard(source,pattern:getEffectiveId(),"jl_yedus9:"..pattern:objectName())
							elseif pattern:isAvailable(to)
							and (pattern:isKindOf("BasicCard") or pattern:isKindOf("TrickCard"))
							then
                        	   	local toc = sgs.Sanguosha:cloneCard(pattern:objectName())
                            	toc:setSkillName("_jl_yedus")
			             		AskUseCard(to,toc,"jl_yedus10:"..pattern:objectName())
							end
						else
					    	room:loseHp(to,1,false,source,"jl_yedus")
							n = to:getHp()+to:getHandcardNum()
							if n>=c:getNumber()
							then to:gainMark("&jl_fus") end
						end
						
					elseif num>c:getNumber()
					then
					   	pattern = room:drawCard()
						room:obtainCard(to,pattern,false)
	                   	room:showCard(to,pattern)
						pattern = sgs.Sanguosha:getCard(pattern)
						if pattern:getSuit()==c:getSuit()
						then
			              	if source:askForSkillInvoke(self:objectName(),sgs.QVariant("jl_yedus11:"..to:objectName()),false)
			         		then source:drawCards(2,self:objectName())
			         		else
			                 	for i = 1,2 do
				            		if to:isNude() then break end
				             		i = room:askForCardChosen(source,to,"he","jl_yedus")
				             		room:throwCard(sgs.Sanguosha:getCard(i),to,source)
				            	end
							end
						else to:gainMark("&jl_fus") end
					end
				end
				num = c:getNumber()
			end
			ton = ton+1
        end
		for _,to in sgs.list(targets)do
			to:setFlags("-jl_yedus_no_to")
			to:setFlags("-jl_yedusto")
		end
	   	return false
  	end
}
jl_yedusVS = sgs.CreateViewAsSkill{
	name = "jl_yedus",
	expand_pile = "#jl_yedus",
	n = 1,
	view_filter = function(self,selected,to_select)
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern=="@@jl_yedus"
		then
            return sgs.Self:getPileName(to_select:getEffectiveId())=="#jl_yedus"
		end
	end,
	view_as = function(self,cards)
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern=="@@jl_yedus"
		then
            if #cards<1
			then return end
			return cards[1]
		end
		return jl_yeduscard:clone()
	end,
	enabled_at_response = function(self,player,pattern)
		if pattern=="@@jl_yedus"
		then return true end
	end,
	enabled_at_play = function(self,player)
		return player:getMark("@jl_yedus")>0
	end
}
jl_yedus = sgs.CreateTriggerSkill{
	name = "jl_yedus",
	view_as_skill = jl_yedusVS,
	events = {sgs.EventPhaseChanging,sgs.CardFinished,sgs.AskForPeaches,sgs.AskForPeachesDone},
	frequency = sgs.Skill_Limited,
	limit_mark = "@jl_yedus",
	can_trigger = function(self,target)
		return target and target:isAlive()
	end,
	on_trigger = function(self,event,player,data,room)
        if event==sgs.EventPhaseChanging
		then
	    	local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
             	for _,p in sgs.list(room:getAlivePlayers())do
        	    	if p:hasFlag("jl_yedusS")
					then
	        			p:setFlags("-jl_yedusS")
                		room:detachSkillFromPlayer(p,"guhuo")
                		room:detachSkillFromPlayer(p,"chanyuan")
					end
	        	end
			end
 	        data:setValue(change)
		elseif event==sgs.AskForPeaches
		then
			local death = data:toDying()
			if room:getTag("jl_yedus"):toBool()
			then return true end
		elseif event==sgs.AskForPeachesDone
		then
			local death,tod = data:toDying(),sgs.QVariant()
			if room:getTag("jl_yedus"):toBool()
			then
				room:setPlayerFlag(death.who,"-Global_Dying")
				death.who:setFlags("jl_yedus_Dying")
 	            tod:setValue(death.damage)
				death.who:setTag("jl_yedus_Dying",tod)
				return true
			end
		elseif event==sgs.CardFinished
		then
	       	local use,can = data:toCardUse(),false
	       	if use.card:getSkillName()=="jl_yedus"
			then
	           	if use.card:isKindOf("SkillCard") then return end
				for _,to in sgs.list(use.to)do
    	           	if to:hasFlag("jl_yedus_no_to")
					and not to:hasFlag("jl_yedusto")
					then to:gainMark("&jl_fus") end
	           	end
			end
		end
		return false
	end,
}
jl_sunben:addSkill(jl_yedus)

jl_lijies = sgs.CreateTriggerSkill{
	name = "jl_lijies",
	events = {sgs.GameStart},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.GameStart
		and player:hasSkill("jl_yedus")
		and player:askForSkillInvoke(self:objectName(),sgs.QVariant("@jl_lijies:"))
		then
			room:doSuperLightbox(player:getGeneralName(),"jl_lijies")
			room:changeHero(player,"sunce",true)
		end
		return false
	end,
}
jl_sunben:addSkill(jl_lijies)


jl_shengsheng = sgs.General(extension,"jl_shengsheng","wu")
jl_pojun = sgs.CreateTriggerSkill{
	name = "jl_pojun",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecifying,sgs.CardFinished,sgs.DamageCaused},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.TargetSpecifying
		then
			local use = data:toCardUse()
			if use.card:isDamageCard()
			and use.to:length()==1
			then
	           	room:sendCompulsoryTriggerLog(player,self:objectName())
		        room:broadcastSkillInvoke("jl_pojun")--播放配音
               	for _,to in sgs.list(use.to)do
                 	local n = to:getHandcardNum()+to:getEquips():length()
					n = room:askForExchange(to,self:objectName(),n,n,true)
					room:obtainCard(player,n,false)
					to:setFlags("jl_pj")
		     	end
			end
    		data:setValue(use)
    	elseif event==sgs.DamageCaused
		then
		    local damage = data:toDamage()
			if damage.to:isNude()
			then
                room:sendCompulsoryTriggerLog(player,self:objectName())
     	        room:broadcastSkillInvoke("jl_pojun")--播放配音
	     	    DamageRevises(data,1,player)
			end
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if use.card:isDamageCard()
--			and use.to:length()==1
			then
	           	room:sendCompulsoryTriggerLog(player,self:objectName())
             	for _,to in sgs.list(room:getAlivePlayers())do
                 	if to:hasFlag("jl_pj")
					then
			    		local n = to:getHp()
				    	n = room:askForExchange(player,self:objectName(),n,n,true)
				    	room:obtainCard(to,n,false)
					end
					to:setFlags("-jl_pj")
		    	end
			end
    		data:setValue(use)
		end
	end
}
jl_shengsheng:addSkill(jl_pojun)

--[[
jl_caodun = sgs.General(extension,"jl_caodun","wei")
jl_shanjia = sgs.CreateTriggerSkill{
	name = "jl_shanjia",
	events = {sgs.EventPhaseStart},
	on_trigger = function(self,event,player,data,room)
	   	if event==sgs.EventPhaseStart
	   	and player:getPhase()==sgs.Player_Play
	   	and room:askForSkillInvoke(player,self:objectName(),data)
	   	then
			local n = player:getHandcardNum()+player:getEquips():length()
			room:askForDiscard(player,"jl_shanjia",n,n,false,true)
			player:drawCards(n*2,self:objectName())
			if n>player:getAliveSiblings():length()
			then
	    	    n = sgs.Sanguosha:cloneCard("slash")
	        	n:setSkillName("_jl_shanjia")
				local use = sgs.CardUseStruct()
				use.from = player
				use.card = n
               	for _,to in sgs.list(room:getOtherPlayers(player))do
		    		if not player:isProhibited(to,n)
					then use.to:append(to) end
				end
				room:useCard(use)
			end
		end
		return false
	end
}
jl_caodun:addSkill(jl_shanjia)
--]]
jl_luxun = sgs.General(extension,"jl_luxun","wu")
jl_qianxun = sgs.CreateTriggerSkill{
	name = "jl_qianxun",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetConfirming,sgs.CardFinished,sgs.DamageCaused},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.TargetConfirming
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Indulgence")
			or use.card:isKindOf("Snatch")
			then
	           	room:sendCompulsoryTriggerLog(player,self:objectName())
             	use.to:append(use.from)
             	use.to:removeOne(player)
             	use.from = player
			end
    		data:setValue(use)
 		end
	end
}
jl_luxun:addSkill(jl_qianxun)
jl_lianying = sgs.CreateTriggerSkill{
	name = "jl_lianying",
	events = {sgs.CardsMoveOneTime},
	frequency = sgs.Skill_Frequent,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardsMoveOneTime
		then
    		local move = data:toMoveOneTime()
	       	if move.from
			and move.from:objectName()==player:objectName()
			and move.from_places:contains(sgs.Player_PlaceHand)
			and move.is_last_handcard
	      	and room:askForSkillInvoke(player,self:objectName(),data)
			then
		    	if player:getPhase()~=sgs.Player_NotActive
				then
	               	for _,id in sgs.list(room:getDrawPile())do
				    	id = sgs.Sanguosha:getCard(id)
	               		if id:isAvailable(player)
	                   	then room:obtainCard(player,id) break end
	               	end
				else
	               	for _,id in sgs.list(room:getDrawPile())do
				    	id = sgs.Sanguosha:getCard(id)
	               		if not id:isAvailable(player)
	                   	then room:obtainCard(player,id) break end
	               	end
				end
			end
 	        data:setValue(move)
		end
		return false
	end,
}
jl_luxun:addSkill(jl_lianying)

jl_sunce = sgs.General(extension,"jl_sunce","wu")
jl_baiban = sgs.CreateTriggerSkill{
	name = "jl_baiban",
	events = {sgs.EventPhaseSkipping,sgs.DrawNCards,sgs.TurnedOver,sgs.EventLoseSkill,
	sgs.ChainStateChanged,sgs.CardsMoveOneTime,sgs.EventAcquireSkill},
	frequency = sgs.Skill_Compulsory,
	priority = -998,
	on_trigger = function(self,event,player,data,room)
	   	local skills = player:getTag("jl_baiban"):toString():split("+")
		if player:hasSkill(self:objectName())
		then
			for _,skill in sgs.list(player:getSkillList())do
		    	if not skill:isAttachedLordSkill()
				and skill:objectName()~=self:objectName()
		    	then
			    	room:sendCompulsoryTriggerLog(player,self:objectName())
					table.insert(skills,skill:objectName())
					room:detachSkillFromPlayer(player,skill:objectName())
				end
			end
			player:setTag("jl_baiban",sgs.QVariant(table.concat(skills,"+")))
		end
		if event==sgs.EventLoseSkill
		then
			if data:toString()==self:objectName()
			then
            	for _,m in sgs.list(skills)do
			    	room:sendCompulsoryTriggerLog(player,self:objectName())
	             	room:acquireSkill(player,m)
				end
			end
		elseif event==sgs.EventPhaseSkipping
		then
    		room:sendCompulsoryTriggerLog(player,self:objectName())
	    	return true
    	elseif event==sgs.DrawNCards
		then
    		room:sendCompulsoryTriggerLog(player,self:objectName())
			data:setValue(2)
    	elseif event==sgs.TurnedOver
		then
    		room:sendCompulsoryTriggerLog(player,self:objectName())
	    	room:setPlayerProperty(player,"faceup",sgs.QVariant(true))
			return true
    	elseif event==sgs.ChainStateChanged
		and player:isChained()
		then
		    room:sendCompulsoryTriggerLog(player,self:objectName())
	    	room:setPlayerProperty(player,"chained",sgs.QVariant(false))
			return true
		end
		return false
	end,
}
jl_sunce:addSkill(jl_baiban)

jl_jh_ids = sgs.IntList()
jl_caojinyu = sgs.General(extension,"jl_caojinyu","wei",3,false)
jl_jinghunCard = sgs.CreateSkillCard{
	name = "jl_jinghunCard",
	will_throw = false,
	target_fixed = true,
	about_to_use = function(self,room,use)
		if use.from:hasFlag("jl_jinghun")
		then
	    	room:obtainCard(use.from,self,false)
		else
	    	room:obtainCard(use.from:getTag("jl_jinghun"):toPlayer(),self,false)
		end
	end
}
jl_jinghunVS = sgs.CreateViewAsSkill{
	name = "jl_jinghun",
	expand_pile = "#jinghuncard",
	n = 998,
	view_filter = function(self,selected,to_select)
		local x = sgs.Self:getMark("jl_jinghun_4")
		local pattern = sgs.Self:getPile("#jinghuncard"):length()
		x = x>pattern and pattern or x
		if sgs.Self:hasFlag("jl_jinghun")
		and #selected >= x
		then return end
        return sgs.Self:getPileName(to_select:getEffectiveId())=="#jinghuncard"
	end,
	view_as = function(self,cards)
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local x = 1
		if sgs.Self:hasFlag("jl_jinghun")
		then if #cards<1 then return end
		else
	    	x = sgs.Self:getMark("jl_jinghun_3")
	    	pattern = sgs.Self:getPile("#jinghuncard"):length()
	    	x = x>pattern and pattern or x
	    	if #cards<x then return end
		end
	   	pattern = jl_jinghunCard:clone() 
	   	for _,cid in sgs.list(cards)do
	        pattern:addSubcard(cid)
	   	end
        return pattern
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_jinghun")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return false
	end,
} 
jl_jinghun = sgs.CreateTriggerSkill{
	name = "jl_jinghun",
	events = {sgs.DamageCaused,sgs.EventPhaseChanging},
	view_as_skill = jl_jinghunVS,
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
    	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
		for i = 1,4 do
	    	if owner:getMark("jl_jinghun_"..i)<1
	    	then
    			room:addPlayerMark(owner,"jl_jinghun_"..i)
	    	end
		end
		if event==sgs.DamageCaused
	    then
	        local damage = data:toDamage()
 	        data:setValue(damage.from)
			local x = owner:getMark("jl_jinghun_1")
			owner:setTag("jl_jinghun",data)
			if owner:distanceTo(damage.from) <= x
			and owner:askForSkillInvoke(self:objectName(),data)
			then 
		    	x = owner:getMark("jl_jinghun_2")
			    local ids = room:getNCards(x,false)
		    	room:returnToTopDrawPile(ids)
		    	x = owner:getMark("jl_jinghun_3")
				jl_jh_ids = ids
	           	room:notifyMoveToPile(owner,ids,"jinghuncard",sgs.Player_DrawPile,true)
	           	x = room:askForUseCard(owner,"@@jl_jinghun!","jl_jinghun0:"..damage.from:objectName()..":"..x)
	           	room:notifyMoveToPile(owner,ids,"jinghuncard",sgs.Player_DrawPile,false)
				x = sgs.IntList()
		    	for _,id in sgs.list(ids)do
					if room:getCardPlace(id)~=sgs.Player_DrawPile
					then x:append(id) end
				end
		    	for _,id in sgs.list(x)do
					ids:removeOne(id)
				end
				if ids:length()>0
				then
	             	room:setPlayerFlag(owner,"jl_jinghun")
					x = owner:getMark("jl_jinghun_4")
		    		jl_jh_ids = ids
					room:notifyMoveToPile(owner,ids,"jinghuncard",sgs.Player_DrawPile,true)
	             	x = room:askForUseCard(owner,"@@jl_jinghun","jl_jinghun1:"..owner:objectName()..":"..x)
	             	room:notifyMoveToPile(owner,ids,"jinghuncard",sgs.Player_DrawPile,false)
	             	room:setPlayerFlag(owner,"-jl_jinghun")
				end
				room:loseHp(damage.to,1,false,owner,"jl_jinghun")
				return true
			end
			data:setValue(damage)
		end
		end
		return false
	end,
}
jl_caojinyu:addSkill(jl_jinghun)
jl_guiying = sgs.CreateTriggerSkill{
	name = "jl_guiying",
	events = {sgs.EventPhaseProceeding,sgs.Dying},
	frequency = sgs.Skill_Frequent,
	on_trigger = function(self,event,player,data,room)
		local x = player:isWounded() and 2 or 1
		for i = 1,x do
	    	local jl_jinghuns = {}
	    	for i = 1,4 do
	        	if player:getMark("jl_jinghun_"..i)<5
	        	then table.insert(jl_jinghuns,"jl_jinghun_"..i) end
				room:setPlayerMark(player,"SkillDescriptionArg"..i.."_jl_jinghun",player:getMark("jl_jinghun_"..i))
	    	end
	    	if event==sgs.EventPhaseProceeding
	    	and player:getPhase()==sgs.Player_Start
	    	and #jl_jinghuns>0
	    	and player:askForSkillInvoke(self:objectName(),data)
	    	then
	    	    jl_jinghuns = room:askForChoice(player,"jl_guiying",table.concat(jl_jinghuns,"+"))
	    		room:addPlayerMark(player,jl_jinghuns)
				room:setPlayerMark(player,"SkillDescriptionArg"..string.sub(jl_jinghuns,12,12).."_jl_jinghun",player:getMark(jl_jinghuns))
				room:changeTranslation(player,"jl_jinghun",2)
	    	elseif event==sgs.Dying
	    	and #jl_jinghuns>0
	    	and player:askForSkillInvoke(self:objectName(),data)
	    	then
	    	    jl_jinghuns = room:askForChoice(player,"jl_guiying",table.concat(jl_jinghuns,"+"))
	    		room:addPlayerMark(player,jl_jinghuns)
				room:setPlayerMark(player,"SkillDescriptionArg"..string.sub(jl_jinghuns,12,12).."_jl_jinghun",player:getMark(jl_jinghuns))
				room:changeTranslation(player,"jl_jinghun",2)
	    	end
		end
		return false
	end,
}
jl_caojinyu:addSkill(jl_guiying)


jl_sangg = sgs.General(extension,"jl_sangg","god",3)
jl_sangg:setGender(sgs.General_Sexless)
jl_sangg:addSkill("taoluan")
jl_shehuocard = sgs.CreateSkillCard{
	name = "jishecard",
	will_throw = false,
	target_fixed = true,
	on_use = function(self,room,source,targets)
		source:drawCards(1,self:objectName())
		room:addPlayerMark(source,"&jishe-Clear")
		return false
	end
}
jl_shehuovs = sgs.CreateViewAsSkill{
	name = "jl_shehuo",
	view_as = function(self,cards)
		return jl_shehuocard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:getMaxCards()>0
	end
}
jl_shehuo = sgs.CreateTriggerSkill{
	name = "jl_shehuo",
--	frequency = sgs.Skill_Compulsory,
--	limit_mark = "@jl_shehuo",
	events = {sgs.DamageInflicted,sgs.EventPhaseStart},
	view_as_skill = jl_shehuovs,
	on_trigger = function(self,event,player,data,room)
	   	if event==sgs.EventPhaseStart
	   	and player:getPhase()==sgs.Player_Finish
		and player:isKongcheng()
		then
	    	room:askForUseCard(player,"@@jishe","@jishe:"..player:getHp())
		elseif event==sgs.DamageInflicted
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("lianhuo")
        	if skill
	    	then
	    		skill:trigger(event,room,player,data)
			end
		end
	end
}
jl_sangg:addSkill(jl_shehuo)
jl_huiqing = sgs.CreateTriggerSkill{
	name = "jl_huiqing",
	events = {sgs.DamageInflicted,sgs.EventPhaseStart},
	on_trigger = function(self,event,player,data,room)
	   	if event==sgs.EventPhaseStart
	   	and player:getPhase()==sgs.Player_Finish
		then
	    	local lord = room:getLord()
			if lord
			then
		    	for _,p in sgs.list(room:getAlivePlayers())do
			    	if p:inMyAttackRange(lord)
					then
	            		room:askForUseCard(player,"@@qinqing","@qinqing:")
						break
			    	end
				end
			end
		elseif event==sgs.DamageInflicted
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("huisheng")
        	if skill
	    	then
				return skill:trigger(event,room,player,data)
			end
		end
	end
}
jl_sangg:addSkill(jl_huiqing)
jl_sangg:addRelateSkill("jishe")
jl_sangg:addRelateSkill("lianhuo")
jl_sangg:addRelateSkill("qinqing")
jl_sangg:addRelateSkill("huisheng")

jl_siyishou = sgs.General(extension,"jl_siyishou","qun",6)
jl_siyishou:setStartHp(4)
jl_huoqi = sgs.CreateTriggerSkill{
	name = "jl_huoqi",
	events = {sgs.ConfirmDamage,sgs.EventPhaseStart,sgs.CardEffected},
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
    	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
	   	if event==sgs.EventPhaseStart
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("zaiqi")
        	if skill
	    	then
	    		return skill:trigger(event,room,owner,data)
			end
		elseif event==sgs.CardEffected
		and player:objectName()==owner:objectName()
		then
            local effect = data:toCardEffect()
        	if effect.card:isKindOf("SavageAssault")
	    	then
	           	room:sendCompulsoryTriggerLog(owner,"huoshou")
		        room:broadcastSkillInvoke("huoshou")--播放配音
	    		return true
			end
		elseif event==sgs.ConfirmDamage
		then
	        local damage = data:toDamage()
        	if damage.card
			and damage.card:isKindOf("SavageAssault")
	    	then
	           	room:sendCompulsoryTriggerLog(owner,"huoshou")
		        room:broadcastSkillInvoke("huoshou")--播放配音
	    		damage.from = owner
			end
 	        data:setValue(damage)
		end
		end
	end
}
jl_siyishou:addSkill(jl_huoqi)
jl_qiangxuancard = sgs.CreateSkillCard{
	name = "chexuancard",
--	will_throw = false,
	target_fixed = true,
	on_use = function(self,room,source,targets)
        if source:isDead()
		or source:getTreasure()
		or not source:hasTreasureArea()
		then return end
        local ids = sgs.IntList()
        local id1 = source:getDerivativeCard("_sichengliangyu",sgs.Player_PlaceTable)
        local id2 = source:getDerivativeCard("_tiejixuanyu",sgs.Player_PlaceTable)
        local id3 = source:getDerivativeCard("_feilunzhanyu",sgs.Player_PlaceTable)
        if id1>0 then ids:append(id1) end
        if id2>0 then ids:append(id2) end
        if id3>0 then ids:append(id3) end
        if ids:isEmpty()
		then return end
        room:fillAG(ids,source)
        ids = room:askForAG(source,ids,false,"chexuan")
        room:clearAG(source)
        local log = sgs.LogMessage()
        log.type = "$Install"
        log.from = source
        log.card_str = ids
        room:sendLog(log)
		ids = sgs.Sanguosha:getCard(ids)
        id1 = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT,source:objectName(),"chexuan","")
        room:moveCardTo(ids,source,sgs.Player_PlaceEquip,id1)
    	return false
   	end
}
jl_qiangxuanvs = sgs.CreateViewAsSkill{
	name = "jl_qiangxuan",
	n = 1,
	view_filter = function(self,selected,to_select)
       return to_select:isBlack()
	end,
	view_as = function(self,cards)
		if #cards<1 then return end
		local card = jl_qiangxuancard:clone()
	   	for _,c in sgs.list(cards)do
	        card:addSubcard(c)
	   	end
		return card
	end,
	enabled_at_play = function(self,player)
		return player:getTreasure()==nil
	end
}
jl_qiangxuan = sgs.CreateTriggerSkill{
	name = "jl_qiangxuan",
	events = {sgs.CardsMoveOneTime,sgs.EventPhaseStart},
	view_as_skill = jl_qiangxuanvs,
	on_trigger = function(self,event,player,data,room)
	   	if event==sgs.EventPhaseStart
		then
		elseif event==sgs.CardsMoveOneTime
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("chexuan")
        	if skill
	    	then
	    		skill:trigger(event,room,player,data)
			end
		end
	end
}
jl_siyishou:addSkill(jl_qiangxuan)
jl_kouren = sgs.CreateTriggerSkill{
	name = "jl_kouren",
	events = {sgs.Death,sgs.Damage},
	on_trigger = function(self,event,player,data,room)
	   	if event==sgs.Damage
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("koulve")
        	if skill
	    	then
	    		skill:trigger(event,room,player,data)
			end
		elseif event==sgs.Death
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("suirenq")
        	if skill
	    	then
	    		skill:trigger(event,room,player,data)
			end
		end
	end
}
jl_siyishou:addSkill(jl_kouren)
jl_siyishou:addSkill("luanzhan")
jl_siyishou:addRelateSkill("zaiqi")
jl_siyishou:addRelateSkill("huoshou")
jl_siyishou:addRelateSkill("chexuan")
jl_siyishou:addRelateSkill("qiangshou")
jl_siyishou:addRelateSkill("koulve")
jl_siyishou:addRelateSkill("suirenq")

jl_chaiqiandui = sgs.General(extension,"jl_chaiqiandui","god")
jl_chaixiecard = sgs.CreateSkillCard{
	name = "tiaoxincard",
	will_throw = false,
	filter = function(self,targets,to_select,source)
		return #targets<1
		and to_select:inMyAttackRange(source)
	end,
	on_use = function(self,room,source,targets)
		for _,to in sgs.list(targets)do
	    	if not room:askForUseSlashTo(to,source,"@tiaoxin-slash:"..source:objectName())
			and source:canDiscard(to,"he")
			then
				source:setFlags("jl_chaixie")
		   		room:throwCard(room:askForCardChosen(source,to,"he","tiaoxin"),to,source)
				source:setFlags("-jl_chaixie")
	    	end
		end
	end
}
jl_chaixieVS = sgs.CreateViewAsSkill{
	name = "jl_chaixie",
	n = 1,
	expand_pile = "field",
	view_filter = function(self,selected,to_select)
		return to_select:isBlack()
		or sgs.Self:getPileName(to_select:getEffectiveId())=="field"
	end,
	view_as = function(self,cards)
		local card
		if #cards<1
		then
	    	if sgs.Self:usedTimes("#tiaoxincard")<1
	    	then card = jl_chaixiecard:clone() end
		else
	    	if sgs.Self:getPileName(cards[1]:getEffectiveId())~="field"
			then card = "dismantlement"
			else card = "snatch" end
			card = sgs.Sanguosha:cloneCard(card)
	    	if sgs.Self:getPileName(cards[1]:getEffectiveId())~="field"
			then card:setSkillName("qixi")
			else card:setSkillName("jl_jixi") end
	    	for _,c in sgs.list(cards)do
		    	card:addSubcard(c)
	    	end
		end
		return card
	end,
	enabled_at_play = function(self,player)
		return player:isAlive()
	end
}
jl_chaixie = sgs.CreateTriggerSkill{
	name = "jl_chaixie",
	view_as_skill = jl_chaixieVS,
	events = {sgs.EventPhaseStart,sgs.CardsMoveOneTime,sgs.Damage,
	sgs.CardFinished,sgs.SlashMissed,sgs.Damaged,sgs.CardUsed},
	on_trigger = function(self,event,player,data,room)
        if event==sgs.EventPhaseStart
		then
			if player:getPhase()==sgs.Player_Start
			and player:isWounded()
			then
	         	local skill = sgs.Sanguosha:getTriggerSkill("yinghun")
				player:setFlags("jl_chaixie")
            	if skill then skill:trigger(event,room,player,data) end
				player:setFlags("-jl_chaixie")
			end
	       	local skill = sgs.Sanguosha:getTriggerSkill("nostuxi")
           	if skill then return skill:trigger(event,room,player,data) end
		elseif event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:getSkillName()=="qixi"
			then
				for _,to in sgs.list(use.to)do
		    		to:setFlags("jl_chaixie")
				end
			end
    		data:setValue(use)
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if use.card:getSkillName()=="qixi"
			then
				for _,to in sgs.list(use.to)do
		    		to:setFlags("-jl_chaixie")
				end
			end
    		data:setValue(use)
		elseif event==sgs.SlashMissed
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("mengjin")
			player:setFlags("jl_chaixie")
        	if skill then skill:trigger(event,room,player,data) end
			player:setFlags("-jl_chaixie")
		elseif event==sgs.Damage
		then
	        local damage = data:toDamage()
		    local skill = sgs.Sanguosha:getTriggerSkill("qiaomeng")
		    player:setFlags("jl_chaixie")
            if skill then skill:trigger(event,room,player,data) end
		    player:setFlags("-jl_chaixie")
		elseif event==sgs.Damaged
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("nosfankui")
        	if skill then skill:trigger(event,room,player,data) end
	     	local skill = sgs.Sanguosha:getTriggerSkill("guixin")
        	if skill then skill:trigger(event,room,player,data) end
		    player:setFlags("jl_chaixie")
	     	local skill = sgs.Sanguosha:getTriggerSkill("nosganglie")
        	if skill then skill:trigger(event,room,player,data) end
		    player:setFlags("-jl_chaixie")
		elseif event==sgs.CardsMoveOneTime
		then
    		local move = data:toMoveOneTime()
			if move.to_place==sgs.Player_DiscardPile
			and move.reason.m_reason~=sgs.CardMoveReason_S_REASON_JUDGEDONE
			and (player:hasFlag("jl_chaixie") or BeMan(room,move.from):hasFlag("jl_chaixie"))
			then
		    	local reason = move.reason.m_skillName
				if reason==""
				or reason=="qiaomeng"
				or reason=="yinghun"
				or reason=="nosganglie"
				or reason=="tiaoxin"
				or reason==nil
				then
	             	reason = sgs.IntList()
					for _,id in sgs.list(move.card_ids)do
			         	if room:getCardPlace(id)==sgs.Player_DiscardPile
			     		then reason:append(id) end
		        	end
					player:addToPile("field",reason)
				end
			end
		end
		return false
	end,
}
jl_chaiqiandui:addSkill(jl_chaixie)
jl_chaiqiandui:addRelateSkill("qixi")
jl_chaiqiandui:addRelateSkill("yinghun")
jl_chaiqiandui:addRelateSkill("guixin")
jl_chaiqiandui:addRelateSkill("nostuxi")
jl_chaiqiandui:addRelateSkill("nosganglie")
jl_chaiqiandui:addRelateSkill("jixi")
jl_chaiqiandui:addRelateSkill("qiaomeng")
jl_chaiqiandui:addRelateSkill("tiaoxin")
jl_chaiqiandui:addRelateSkill("nosfankui")
jl_chaiqiandui:addRelateSkill("mengjin")

jl_shuapaiji = sgs.General(extension,"jl_shuapaiji","god",3,false)
jl_shuapaiji:addSkill("nosjizhi")
jl_shuapaiji:addSkill("xiaoji")
jl_shuapaiji:addSkill("noslianying")
jl_shuapaiji:addSkill("nosshangshi")

jl_zhuanhuaqi = sgs.General(extension,"jl_zhuanhuaqi","god")
local jl_xs = {}
jl_xishuacard = sgs.CreateSkillCard{
	name = "jl_xishuacard",
	will_throw = false,
	target_fixed = true,
	about_to_use = function(self,room,use)
		local to_skills = {}
		if use.from:getHandcardNum()>0
		then table.insert(to_skills,"nosguhuo") end
		if use.from:getHandcardNum()>0
		and use.from:getMark("xishua_qice-PlayClear")<1
		then table.insert(to_skills,"qice") end
		if use.from:getHandcardNum()>1
	   	and CardIsAvailable(use.from,"archery_attack","luanji")
		then table.insert(to_skills,"luanji") end
		if use.from:getPile("field"):length()>0
		and CardIsAvailable(use.from,"snatch","jl_jixi")
		then table.insert(to_skills,"jl_jixi") end
		jl_xs.color = use.from:getTag("xishua_shuangxiong"):toString()
	   	for _,c in sgs.list(use.from:getHandcards())do
	    	if c:isRed()
			and not table.contains(to_skills,"wusheng")
	    	and CardIsAvailable(use.from,"slash","wusheng")
	    	then table.insert(to_skills,"wusheng") end
	    	if c:isRed()
			and not table.contains(to_skills,"huoji")
	    	and CardIsAvailable(use.from,"fire_attack","huoji")
	    	then table.insert(to_skills,"huoji") end
	    	if c:isBlack()
			and not table.contains(to_skills,"qixi")
	    	and CardIsAvailable(use.from,"dismantlement","qixi")
	    	then table.insert(to_skills,"qixi") end
	    	if c:isBlack()
			and (c:getTypeId()==1 or c:getTypeId()==3)
			and not table.contains(to_skills,"duanliang")
	    	and CardIsAvailable(use.from,"supply_shortage","duanliang")
	    	then table.insert(to_skills,"duanliang") end
	    	if c:getSuitString()=="diamond"
			and not table.contains(to_skills,"nosguose")
	    	and CardIsAvailable(use.from,"indulgence","nosguose")
	    	then table.insert(to_skills,"nosguose") end
	    	if c:getSuitString()=="diamond"
			and not table.contains(to_skills,"longhun")
	    	and CardIsAvailable(use.from,"fire_slash","longhun")
	    	then table.insert(to_skills,"longhun") end
	    	if c:getSuitString()=="heart"
			and not table.contains(to_skills,"longhun")
	    	and CardIsAvailable(use.from,"peach","longhun")
	    	then table.insert(to_skills,"longhun") end
	    	if c:getSuitString()=="spade"
			and not table.contains(to_skills,"jiuchi")
	    	and CardIsAvailable(use.from,"analeptic","jiuchi")
	    	then table.insert(to_skills,"jiuchi") end
	    	if c:isKindOf("Jink")
			and not table.contains(to_skills,"longdan")
	    	and CardIsAvailable(use.from,"slash","longdan")
	    	then table.insert(to_skills,"longdan") end
	    	if c:getSuitString()=="club"
			and not table.contains(to_skills,"lianhuan")
	    	and CardIsAvailable(use.from,"iron_chain","lianhuan")
	    	then table.insert(to_skills,"lianhuan") end
			if c:getColorString()~=jl_xs.color
			and use.from:getMark("xishua_shuangxiong-Clear")>0
			and not table.contains(to_skills,"shuangxiong")
			and CardIsAvailable(use.from,"duel","shuangxiong")
			then table.insert(to_skills,"shuangxiong") end
		end
	   	for _,c in sgs.list(use.from:getEquips())do
	    	if c:isRed()
			and not table.contains(to_skills,"wusheng")
	    	and CardIsAvailable(use.from,"slash","wusheng")
	    	then table.insert(to_skills,"wusheng") end
	    	if c:isBlack()
			and not table.contains(to_skills,"qixi")
	    	and CardIsAvailable(use.from,"dismantlement","qixi")
	    	then table.insert(to_skills,"qixi") end
	    	if c:isBlack()
			and (c:getTypeId()==1 or c:getTypeId()==3)
			and not table.contains(to_skills,"duanliang")
	    	and CardIsAvailable(use.from,"supply_shortage","duanliang")
	    	then table.insert(to_skills,"duanliang") end
	    	if c:getSuitString()=="diamond"
			and not table.contains(to_skills,"nosguose")
	    	and CardIsAvailable(use.from,"indulgence","nosguose")
	    	then table.insert(to_skills,"nosguose") end
	    	if c:getSuitString()=="diamond"
			and not table.contains(to_skills,"longhun")
	    	and CardIsAvailable(use.from,"fire_slash","longhun")
	    	then table.insert(to_skills,"longhun") end
	    	if c:getSuitString()=="heart"
			and not table.contains(to_skills,"longhun")
	    	and CardIsAvailable(use.from,"peach","longhun")
	    	then table.insert(to_skills,"longhun") end
	    	if c:getSuitString()=="club"
			and not table.contains(to_skills,"lianhuan")
	    	and CardIsAvailable(use.from,"iron_chain","lianhuan")
	    	then table.insert(to_skills,"lianhuan") end
		end
		if #to_skills<1 then return end
		to_skills = room:askForChoice(use.from,"jl_xishua",table.concat(to_skills,"+"))
		jl_xs.name = to_skills
		jl_xs.card = ""
		if to_skills=="nosguhuo"
		then jl_xs.card = AgCardsToName(use.from,"basic+trick",true)
		elseif to_skills=="qice"
		then jl_xs.card = AgCardsToName(use.from,"trick",true)
		elseif to_skills=="qixi"
		then jl_xs.card = "dismantlement"
		elseif to_skills=="duanliang"
		then jl_xs.card = "supply_shortage"
		elseif to_skills=="nosguose"
		then jl_xs.card = "indulgence"
		elseif to_skills=="longdan"
		then jl_xs.card = "slash"
		elseif to_skills=="huoji"
		then jl_xs.card = "fire_attack"
		elseif to_skills=="wusheng"
		then jl_xs.card = "slash"
		elseif to_skills=="lianhuan"
		then jl_xs.card = "iron_chain"
		elseif to_skills=="jl_jixi"
		then jl_xs.card = "snatch"
		elseif to_skills=="luanji"
		then jl_xs.card = "archery_attack"
		elseif to_skills=="jiuchi"
		then jl_xs.card = "analeptic"
		elseif to_skills=="shuangxiong"
		then jl_xs.card = "duel" end
		if room:askForUseCard(use.from,"@@jl_xishua","jl_xishua0:"..to_skills..":"..jl_xs.card)
		then use.from:addMark("xishua_"..to_skills.."-PlayClear") end
	end
}
jl_xishuaCard = sgs.CreateSkillCard{
	name = "jl_xishuaCard",
	will_throw = false,
	filter = function(self,targets,to_select,source)
        local pattern = self:getUserString()
		return SCfilter(pattern,targets,to_select,self)
	end,
	feasible = function(self,targets)
        local pattern = self:getUserString()
		return SCfeasible(pattern,targets,self)
	end,
	on_validate = function(self,use)
		local skills = {}
		local yuji = use.from
		local room = yuji:getRoom()
	   	local n = math.max(1,yuji:getHp())
	    local pattern = self:getUserString()
	    local to_pattern = pattern
		if pattern=="@@jl_xishua"
		then table.insert(skills,jl_xs.name)
		elseif pattern~=""
		then
			local c = sgs.Sanguosha:getCard(self:getSubcards():at(0))
		    if not c:isEquipped()
			then
        		table.insert(skills,"nosguhuo")
			end
			if string.find(pattern,"nullification")
			then
				to_pattern = "nullification"
		    	if c:isBlack()
				and not c:isEquipped()
		    	then
    				table.insert(skills,"kanpo")
				end
		    	if c:getSuitString()=="spade"
				and self:subcardsLength()==n
		    	then
	    			table.insert(skills,"longhun")
				end
			end
			if string.find(pattern,"slash")
			then
				to_pattern = "slash"
			   	if c:isRed()
			   	then
	    			table.insert(skills,"wusheng")
				end
			   	if c:isKindOf("Jink")
			   	then
		    		table.insert(skills,"longdan")
				end
			   	if c:getSuitString()=="diamond"
				and self:subcardsLength()==n
			   	then
		    		table.insert(skills,"longhun")
					to_pattern = "fire_slash"
				end
			end
			if string.find(pattern,"jink")
			then
				to_pattern = "jink"
			   	if c:isKindOf("Slash")
			   	then
		    		table.insert(skills,"longdan")
				end
			   	if c:getSuitString()=="club"
				and self:subcardsLength()==n
			   	then
		    		table.insert(skills,"longhun")
				end
		    	if c:isBlack()
				and not c:isEquipped()
		    	then
    				table.insert(skills,"qingguo")
				end
			end
			if string.find(pattern,"peach")
			then
				to_pattern = "peach"
			   	if c:isRed()
				and yuji:getPhase()==sgs.Player_NotActive
			   	then table.insert(skills,"jijiu") end
			   	if c:getSuitString()=="heart"
				and self:subcardsLength()==n
			   	then table.insert(skills,"longhun") end
			end
			if string.find(pattern,"analeptic")
			then
				to_pattern = "analeptic"
			   	if c:getSuitString()=="spade"
				and not c:isEquipped()
			   	then table.insert(skills,"jiuchi") end
			end
		end
		jl_xs.name = room:askForChoice(yuji,"jl_xishua",table.concat(skills,"+"))
		if jl_xs.name=="nosguhuo"
		then
	    	to_pattern = room:askForChoice(yuji,"guhuo_saveself",pattern)
			self:setUserString(to_pattern)
	        room:broadcastSkillInvoke("nosguhuo")--播放配音
	    	if jl_guhuo(self,yuji)
			then
	    		local use_card = sgs.Sanguosha:cloneCard(to_pattern)
		    	use_card:setSkillName(jl_xs.name)
		    	use_card:addSubcard(self)
				use_card:setFlags("jl_xishua")
		    	return use_card
			end
		elseif jl_xs.name
		then
	   		local use_card = sgs.Sanguosha:cloneCard(to_pattern)
		   	use_card:setSkillName(jl_xs.name)
		   	use_card:addSubcards(self:getSubcards())
			use_card:setFlags("jl_xishua")
		   	return use_card
		end
		return nil
	end,
	on_validate_in_response = function(self,yuji)
		local skills = {}
		local room = yuji:getRoom()
	   	local n = math.max(1,yuji:getHp())
	    local pattern = self:getUserString()
	    local to_pattern = pattern
		if pattern=="@@jl_xishua"
		then table.insert(skills,jl_xs.name)
		elseif pattern~=""
		then
    		local c = sgs.Sanguosha:getCard(self:getSubcards():at(0))
		    if not c:isEquipped()
			then
        		table.insert(skills,"nosguhuo")
			end
			if string.find(pattern,"nullification")
			then
				to_pattern = "nullification"
		    	if c:isBlack()
				and not c:isEquipped()
		    	then
    				table.insert(skills,"kanpo")
				end
		    	if c:getSuitString()=="spade"
				and self:subcardsLength()==n
		    	then
	    			table.insert(skills,"longhun")
				end
			end
			if string.find(pattern,"slash")
			then
				to_pattern = "slash"
			   	if c:isRed()
			   	then
	    			table.insert(skills,"wusheng")
				end
			   	if c:isKindOf("Jink")
			   	then
		    		table.insert(skills,"longdan")
				end
			   	if c:getSuitString()=="diamond"
				and self:subcardsLength()==n
			   	then
		    		table.insert(skills,"longhun")
				end
			end
			if string.find(pattern,"jink")
			then
				to_pattern = "jink"
			   	if c:isKindOf("Slash")
			   	then
		    		table.insert(skills,"longdan")
				end
			   	if c:getSuitString()=="club"
				and self:subcardsLength()==n
			   	then
		    		table.insert(skills,"longhun")
				end
		    	if c:isBlack()
				and not c:isEquipped()
		    	then
    				table.insert(skills,"qingguo")
				end
			end
			if string.find(pattern,"peach")
			then
				to_pattern = "peach"
			   	if c:isRed()
				and yuji:getPhase()==sgs.Player_NotActive
			   	then table.insert(skills,"jijiu") end
			   	if c:getSuitString()=="heart"
				and self:subcardsLength()==n
			   	then table.insert(skills,"longhun") end
			end
			if string.find(pattern,"analeptic")
			then
				to_pattern = "analeptic"
			   	if c:getSuitString()=="spade"
				and not c:isEquipped()
			   	then table.insert(skills,"jiuchi") end
			end
		end
		jl_xs.name = room:askForChoice(yuji,"jl_xishua",table.concat(skills,"+"))
		if jl_xs.name=="nosguhuo"
		then
	    	to_pattern = room:askForChoice(yuji,"guhuo_saveself",pattern)
	        room:broadcastSkillInvoke("nosguhuo")--播放配音
			self:setUserString(to_pattern)
	    	if jl_guhuo(self,yuji)
			then
	    		local use_card = sgs.Sanguosha:cloneCard(to_pattern)
		    	use_card:setSkillName(jl_xs.name)
		    	use_card:addSubcard(self)
				use_card:setFlags("jl_xishua")
		    	return use_card
			end
		elseif jl_xs.name
		then
	   		local use_card = sgs.Sanguosha:cloneCard(to_pattern)
		   	use_card:setSkillName(jl_xs.name)
		   	use_card:addSubcards(self:getSubcards())
			use_card:setFlags("jl_xishua")
		   	return use_card
		end
		return nil
	end
}
jl_xishuaVS = sgs.CreateViewAsSkill{
	name = "jl_xishua",
	n = 998,
	expand_pile = "field",
	view_filter = function(self,selected,to_select)
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
     	local n,suits = math.max(1,sgs.Self:getHp()),{}
	   	if sgs.Self:getPileName(to_select:getEffectiveId())=="field"
		and string.find(pattern,"@@jl_xishua")
	   	then
			if jl_xs.name=="jl_jixi"
			then return true end
		end
		if pattern~=""
		then
	    	if sgs.Self:getPileName(to_select:getEffectiveId())=="field"
	    	then return end
	    	if string.find(pattern,"jink")
			then
		    	if not to_select:isEquipped() and #selected<1
				or to_select:getSuit()==1 and #selected<n
				or to_select:isKindOf("Slash") and #selected<1
				or not to_select:isEquipped() and to_select:isBlack() and #selected<1
				then return true end
			end
	    	if string.find(pattern,"slash")
			then
		    	if not to_select:isEquipped() and #selected<1
				or to_select:getSuit()==3 and #selected<n
				or to_select:isKindOf("Jink") and #selected<1
				or to_select:isRed() and #selected<1
				then return true end
			end
	    	if string.find(pattern,"peach")
			then
		    	if not to_select:isEquipped() and #selected<1
				or to_select:getSuit()==2 and #selected<n
				or to_select:isRed() and sgs.Self:getPhase()==sgs.Player_NotActive and #selected<1
				then return true end
			end
	    	if string.find(pattern,"analeptic")
			then
		    	if not to_select:isEquipped() and #selected<1
				or to_select:getSuit()==0 and to_select:isEquipped() and #selected<1
				then return true end
			end
	    	if string.find(pattern,"nullification")
			then
		    	if not to_select:isEquipped() and #selected<1
				or to_select:getSuit()==0 and #selected<n
				or to_select:isBlack() and not to_select:isEquipped() and #selected<1
				then return true end
			end
		else return end
		if jl_xs.name=="nosguhuo"
		and #selected<1
		and not to_select:isEquipped()
		then return true end
		if jl_xs.name=="qice"
		then return end
		if jl_xs.name=="longhun"
		then
	    	if #selected >= n
			then return end
	    	if #selected>0
	    	then
	        	return to_select:getSuit()==selected[1]:getSuit()
	    	end
			if CardIsAvailable(sgs.Self,"nullification")
	    	then table.insert(suits,"spade") end
	    	if CardIsAvailable(sgs.Self,"fire_slash")
	    	then table.insert(suits,"diamond") end
			if CardIsAvailable(sgs.Self,"peach")
	    	then table.insert(suits,"heart") end
			if CardIsAvailable(sgs.Self,"jink")
	    	then table.insert(suits,"club") end
	    	return sgs.Sanguosha:matchExpPattern(".|"..table.concat(suits,","),sgs.Self,to_select)
		end
		if jl_xs.name=="qixi"
		and #selected<1
		and to_select:isBlack()
		then return true end
		if jl_xs.name=="duanliang"
		and #selected<1
		and to_select:isBlack()
		and (to_select:getTypeId()==1 or to_select:getTypeId()==3)
		then return true end
		if jl_xs.name=="nosguose"
		and #selected<1
		and to_select:getSuit()==3
		then return true end
		if jl_xs.name=="wusheng"
		and #selected<1
		and to_select:isRed()
		then return true end
		if jl_xs.name=="longdan"
		and #selected<1
		and to_select:isKindOf("Jink")
		then return true end
		if jl_xs.name=="huoji"
		and #selected<1
		and to_select:isRed()
		and not to_select:isEquipped()
		then return true end
		if jl_xs.name=="lianhuan"
		and #selected<1
		and to_select:getSuit()==1
		then return true end
		if jl_xs.name=="luanji"
		and #selected<2
		and not to_select:isEquipped()
		then
    		if #selected>0
			then
		    	return selected[1]:getSuit()==to_select:getSuit()
			end
			return true
		end
		if jl_xs.name=="jiuchi"
		and #selected<1
		and not to_select:isEquipped()
		and to_select:getSuit()==0
		then return true end
		if jl_xs.name=="shuangxiong"
		and #selected<1
		and not to_select:isEquipped()
		and to_select:getColorString()~=jl_xs.color
		then return true end
	end,
	view_as = function(self,selected)
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local card = jl_xishuacard:clone()
		if pattern~=""
		then
			card = jl_xishuaCard:clone()
			if string.find(pattern,"@@jl_xishua")
			then
    		if jl_xs.name=="nosguhuo"
	    	then
	        	if #selected<1
	        	then return end
		    	pattern = jl_xs.card
	    	end
			if jl_xs.name=="qice"
			then
		    	pattern = sgs.Sanguosha:cloneCard(jl_xs.card)
				pattern:setSkillName(jl_xs.name)
	    		for _,c in sgs.list(sgs.Self:getHandcards())do
		    		pattern:addSubcard(c)
				end
				pattern:setFlags("jl_xishua")
				return pattern
			end
			if jl_xs.name=="longhun"
			then
				local n = math.max(1,sgs.Self:getHp())
				if #selected<n then return end
				if selected[1]:getSuit()==0
				then n = "nullification"
				elseif selected[1]:getSuit()==1
				then n = "jink"
				elseif selected[1]:getSuit()==2
				then n = "peach"
				elseif selected[1]:getSuit()==3
				then n = "fire_slash" end
				n = sgs.Sanguosha:cloneCard(n)
				n:setSkillName(jl_xs.name)
				for _,c in sgs.list(selected)do
					n:addSubcard(c)
				end
				n:setFlags("jl_xishua")
				return SetCloneCard(n)
			end
			if jl_xs.name=="qixi"
			or jl_xs.name=="duanliang"
			or jl_xs.name=="nosguose"
			or jl_xs.name=="wusheng"
			or jl_xs.name=="wusheng"
			or jl_xs.name=="longdan"
			or jl_xs.name=="huoji"
			or jl_xs.name=="lianhuan"
			or jl_xs.name=="jl_jixi"
			or jl_xs.name=="jiuchi"
			or jl_xs.name=="shuangxiong"
			then
				if #selected<1 then return end
				pattern = sgs.Sanguosha:cloneCard(jl_xs.card)
				pattern:setSkillName(jl_xs.name)
				for _,c in sgs.list(selected)do
					pattern:addSubcard(c)
				end
				pattern:setFlags("jl_xishua")
				return SetCloneCard(pattern)
			end
    		if jl_xs.name=="luanji"
	    	then
				if #selected<2 then return end
				pattern = sgs.Sanguosha:cloneCard(jl_xs.card)
				pattern:setSkillName(jl_xs.name)
				for _,c in sgs.list(selected)do
					pattern:addSubcard(c)
				end
				pattern:setFlags("jl_xishua")
				return SetCloneCard(pattern)
	    	end
    		end
			if #selected<1
			then return end
		end
		card:setUserString(pattern)
	   	for _,c in sgs.list(selected)do
		   	card:addSubcard(c)
	   	end
	   	return card
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_xishua") then return true end
		local skill = sgs.Sanguosha:getViewAsSkill("nosguhuo")
		if skill and skill:isEnabledAtResponse(player,pattern) then return true end
		skill = sgs.Sanguosha:getViewAsSkill("longhun")
		if skill and skill:isEnabledAtResponse(player,pattern) then return true end
		skill = sgs.Sanguosha:getViewAsSkill("wusheng")
		if skill and skill:isEnabledAtResponse(player,pattern) then return true end
		skill = sgs.Sanguosha:getViewAsSkill("longdan")
		if skill and skill:isEnabledAtResponse(player,pattern) then return true end
		skill = sgs.Sanguosha:getViewAsSkill("jijiu")
		if skill and skill:isEnabledAtResponse(player,pattern) then return true end
		skill = sgs.Sanguosha:getViewAsSkill("kanpo")
		if skill and skill:isEnabledAtResponse(player,pattern) then return true end
	end,
	enabled_at_nullification = function(self,player)
		return not player:isNude()
	end,
	enabled_at_play = function(self,player)
		return player:getCardCount()>0
		or player:getPile("field"):length()>0
	end
}
jl_xishua = sgs.CreateTriggerSkill{
	name = "jl_xishua",
	view_as_skill = jl_xishuaVS,
	events = {sgs.EventPhaseProceeding,sgs.Damage},
	on_trigger = function(self,event,player,data,room)
        if event==sgs.EventPhaseProceeding
		then
			if player:getPhase()==sgs.Player_Draw
			and player:askForSkillInvoke("shuangxiong")
			then
		        room:broadcastSkillInvoke("shuangxiong")--播放配音
				player:addMark("xishua_shuangxiong-Clear")
				local judge = sgs.JudgeStruct()
				judge.good = true
				judge.reason = "shuangxiong"
				judge.who = player
				room:judge(judge)
				player:obtainCard(judge.card)
				judge = player:getTag("JudgeCard_shuangxiong"):toCard()
				player:setTag("xishua_shuangxiong",sgs.QVariant(judge:getColorString()))
				return true
			end
	   	elseif event==sgs.Damage
	    then
            local damage = data:toDamage()
			if damage.card
			and damage.card:isVirtualCard()
			then
	    		player:addToPile("field",damage.card)
			end
		end
		return false
	end,
}
jl_zhuanhuaqi:addSkill(jl_xishua)
jl_zhuanhuaqi:addRelateSkill("nosguhuo")
jl_zhuanhuaqi:addRelateSkill("qice")
jl_zhuanhuaqi:addRelateSkill("longhun")
jl_zhuanhuaqi:addRelateSkill("qixi")
jl_zhuanhuaqi:addRelateSkill("duanliang")
jl_zhuanhuaqi:addRelateSkill("nosguose")
jl_zhuanhuaqi:addRelateSkill("wusheng")
jl_zhuanhuaqi:addRelateSkill("longdan")
jl_zhuanhuaqi:addRelateSkill("jijiu")
jl_zhuanhuaqi:addRelateSkill("huoji")
jl_zhuanhuaqi:addRelateSkill("kanpo")
jl_zhuanhuaqi:addRelateSkill("lianhuan")
jl_zhuanhuaqi:addRelateSkill("jixi")
jl_zhuanhuaqi:addRelateSkill("luanji")
jl_zhuanhuaqi:addRelateSkill("jiuchi")
jl_zhuanhuaqi:addRelateSkill("shuangxiong")
jl_zhuanhuaqi:addRelateSkill("qingguo")

jl_baxianding = sgs.General(extension,"jl_baxianding","god")
local xianfa_card = ""
jl_xianfacard = sgs.CreateSkillCard{
	name = "jl_xianfacard",
	will_throw = false,
	target_fixed = true,
	about_to_use = function(self,room,use)
		local to_skills = {}
		if use.from:getMark("@arise")>0
		then
	     	table.insert(to_skills,"xiongyi")
		end
		if use.from:getMark("@jianshuMark")>0
		then
	     	table.insert(to_skills,"jianshu")
		end
		if use.from:getMark("@zengdaoMark")>0
		then
	     	table.insert(to_skills,"zengdao")
		end
		if use.from:getMark("@burn")>0
		then
	     	table.insert(to_skills,"fencheng")
		end
		if use.from:getMark("@chaos")>0
		then
	     	table.insert(to_skills,"luanwu")
		end
		to_skills = room:askForChoice(use.from,"jl_xianfa",table.concat(to_skills,"+"))
		xianfa_card = to_skills
		room:askForUseCard(use.from,"@@jl_xianfa","jl_xianfa0:"..to_skills)
	end
}
jl_xianfaCard = sgs.CreateSkillCard{
	name = "jl_xianfaCard",
	will_throw = false,
	filter = function(self,targets,to_select,source)
		if xianfa_card=="xiongyi"
		then
			return to_select:objectName()~=source:objectName()
		end
		if xianfa_card=="zengdao"
		then
			return to_select:objectName()~=source:objectName()
		   	and #targets<1
		end
		if xianfa_card=="jianshu"
		then
			if #targets>0
			then
		    	return to_select:inMyAttackRange(targets[1])
				and targets[1]:canPindian(to_select)
		    	and #targets<2
			end
			return to_select:objectName()~=source:objectName()
		end
		return #targets>0
	end,
	feasible = function(self,targets)
		if xianfa_card=="xiongyi"
		then return true end
		if xianfa_card=="zengdao"
		then return #targets>0 end
		if xianfa_card=="jianshu"
		then return #targets>1 end
		return #targets<1
	end,
	about_to_use = function(self,room,use)
    	self:setObjectName(xianfa_card)
		if xianfa_card=="xiongyi"
		then use.to:append(use.from)
		else
	    	if use.to:isEmpty()
	    	then
		        for _,p in sgs.list(room:getOtherPlayers(use.from))do
	    	    	use.to:append(p)
	    		end
    		end
		end
		NotifySkillInvoked(xianfa_card,use.from,use.to)
	    self:cardOnUse(room,use)
	    if xianfa_card=="jianshu"
		then
	   		room:removePlayerMark(use.from,"@jianshuMark")
	    	room:obtainCard(use.to:at(0),self)
    		if use.to:at(0):pindian(use.to:at(1),"jianshu")
			then
		    	room:askForDiscard(use.to:at(0),"jianshu",2,2,false,true)
				room:loseHp(use.to:at(1),1,false,use.from,"jianshu")
			else
		    	room:askForDiscard(use.to:at(1),"jianshu",2,2,false,true)
				room:loseHp(use.to:at(0),1,false,use.from,"jianshu")
			end
		end
	end,
	on_use = function(self,room,source,targets)
		local count = 1
		room:doSuperLightbox(source:getGeneralName(),xianfa_card)
		for _,to in sgs.list(targets)do
	    	if xianfa_card=="xiongyi"
			then
	    		room:removePlayerMark(source,"@arise")
				to:drawCards(3,self:objectName())
			end
	    	if xianfa_card=="zengdao"
			then
	    		room:removePlayerMark(source,"@zengdaoMark")
	    		to:addToPile("zengdao",self)
			end
	    	if xianfa_card=="luanwu"
			then
	    		room:removePlayerMark(source,"@chaos")
	          	local players = room:getOtherPlayers(to)
	        	local list = sgs.IntList()
	        	local n = 1000
	        	for _,p in sgs.list(players)do
	        		local distance = to:distanceTo(p)
	        		list:append(distance)
	        		n = math.min(n,distance)
	        	end
	        	local targets = sgs.SPlayerList()
	        	for i = 1,list:length()do
	        		if list:at(i)==n
					and to:canSlash(players:at(i))
					then
	        			targets:append(players:at(i))
	        		end
	        	end
	        	if targets:length()<1
				or not room:askForUseSlashTo(to,targets,"@luanwu-slash")
				then room:loseHp(to) end
	     	end
	    	if xianfa_card=="fencheng"
			then
	    		room:removePlayerMark(source,"@burn")
				local to_count = room:askForDiscard(to,"fencheng",998,count,true,true)
				if to_count
				and to_count:subcardsLength() >= count
				then
			    	count = to_count:subcardsLength()+1
				else
					if count>1
					then
				    	room:damage(sgs.DamageStruct(self,source,to,2,sgs.DamageStruct_Fire))
					end
	    	    	count = 1
	        	end
			end
		end
		count = room:alivePlayerCount()
		if xianfa_card=="xiongyi"
		and count/2 >= #targets
		then 
	      	room:recover(source,sgs.RecoverStruct(source,self))
		end
	end
}
jl_xianfaVS = sgs.CreateViewAsSkill{
	name = "jl_xianfa",
	n = 998,
--	expand_pile = "field",
	view_filter = function(self,selected,to_select)
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern~=""
		then
	    	if xianfa_card=="zengdao"
	        then return to_select:isEquipped() end
	    	if xianfa_card=="jianshu"
	        then
    			return to_select:isBlack()
				and not to_select:isEquipped()
				and #selected<1
			end
		end
	end,
	view_as = function(self,cards)
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern~=""
		then
	    	pattern = jl_xianfaCard:clone()
	    	if #cards<1
			and (xianfa_card=="zengdao" or xianfa_card=="jianshu")
	        then return end
	       	for _,c in sgs.list(cards)do
		       	pattern:addSubcard(c)
	       	end
       		return pattern
		else
    		return jl_xianfacard:clone()
		end
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_xianfa")
		then return true end
	end,
	enabled_at_play = function(self,player)
		local to_skills = {}
		if player:getMark("@arise")>0
		then
	     	table.insert(to_skills,"xiongyi")
		end
		if player:getMark("@jianshuMark")>0
		then
	     	table.insert(to_skills,"jianshu")
		end
		if player:getMark("@zengdaoMark")>0
		then
	     	table.insert(to_skills,"zengdao")
		end
		if player:getMark("@burn")>0
		then
	     	table.insert(to_skills,"fencheng")
		end
		if player:getMark("@chaos")>0
		then
	     	table.insert(to_skills,"luanwu")
		end
		return player:isAlive()
		and #to_skills>0
	end
}
jl_xianfa = sgs.CreateTriggerSkill{
	name = "jl_xianfa",
	view_as_skill = jl_xianfaVS,
	events = {sgs.GameStart,sgs.AskForPeaches,sgs.AskForPeachesDone,
	sgs.EventPhaseStart,sgs.Damaged,sgs.CardUsed},
	on_trigger = function(self,event,player,data,room)
        if event==sgs.GameStart
		then
	    	if player:getMark("@arise")<1
	    	then
	         	room:addPlayerMark(player,"@arise")--xiongyi
		    end
	    	if player:getMark("@jianshuMark")<1
	    	then
	        	room:addPlayerMark(player,"@jianshuMark")
	    	end
    		if player:getMark("@yongdiMark")<1
    		then
    	     	room:addPlayerMark(player,"@yongdiMark")
    		end
    		if player:getMark("@zengdaoMark")<1
    		then
--    	     	room:addPlayerMark(player,"@zengdaoMark")
    		end
    		if player:getMark("@burn")<1
    		then
    	     	room:addPlayerMark(player,"@burn")--fencheng
    		end
    		if player:getMark("@chaos")<1
    		then
    	     	room:addPlayerMark(player,"@chaos")--luanwu
    		end
    		if player:getMark("@laoji")<1
    		then
    	     	room:addPlayerMark(player,"@laoji")--fuli
    		end
    		if player:getMark("@burnheart")<1
    		then
    	     	room:addPlayerMark(player,"@burnheart")--fenxin
    		end
    		if player:getMark("@nirvana")<1
    		then
    	     	room:addPlayerMark(player,"@nirvana")
    		end
		elseif event==sgs.AskForPeaches
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("fuli")
--        	if skill then skill:trigger(event,room,player,data) end
	     	local skill = sgs.Sanguosha:getTriggerSkill("niepan")
--        	if skill then skill:trigger(event,room,player,data) end
			local to_skills = {}
    		if player:getMark("@laoji")>0
    		then
    	     	table.insert(to_skills,"fuli")
    		end
    		if player:getMark("@nirvana")>0
    		then
    	     	table.insert(to_skills,"niepan")
    		end
	    	local dying = data:toDying()
	    	if dying.who:objectName()~=player:objectName()
			or #to_skills<1
			then return end
			table.insert(to_skills,"cancel")
	    	to_skills = room:askForChoice(player,"jl_xianfa",table.concat(to_skills,"+"))
	    	if to_skills=="fuli"
			and player:askForSkillInvoke(to_skills,data)
			then
		    	room:removePlayerMark(player,"@laoji")
                room:broadcastSkillInvoke("fuli")
                room:doSuperLightbox(player:getGeneralName(),"fuli")
		    	local recover = sgs.RecoverStruct()
	          	local kingdoms = {}
               	for _,p in sgs.list(room:getAlivePlayers())do
             		p = p:getKingdom()
		          	if not table.contains(kingdoms,p)
	             	then table.insert(kingdoms,p) end
             	end
		    	recover.recover = math.min(#kingdoms,player:getMaxHp())-player:getHp()
		    	room:recover(player,recover)
		    	player:turnOver()
	    	end
	    	if to_skills=="niepan"
			and player:askForSkillInvoke(to_skills,data)
			then
		    	room:removePlayerMark(player,"@nirvana")
                room:broadcastSkillInvoke("niepan")
                room:doSuperLightbox(player:getGeneralName(),"niepan")
				player:throwAllCards()
				local hp = math.min(3,player:getMaxHp())
				room:setPlayerProperty(player,"hp",sgs.QVariant(hp))
				player:drawCards(3)
				if player:isChained()
				then
					local damage = dying_data.damage
					if damage==nil
					or damage.nature==sgs.DamageStruct_Normal
					then
						room:setPlayerProperty(player,"chained",sgs.QVariant(false))
					end
				end
				room:setPlayerProperty(player,"faceup",sgs.QVariant(true))
	    	end
		elseif event==sgs.EventPhaseStart
		then
	    	if player:getPhase()==sgs.Player_Start
			then
		        local males = sgs.SPlayerList()
				for _,p in sgs.list(room:getOtherPlayers(player))do
                    if p:isMale() then males:append(p) end
				end
                if males:isEmpty() or player:getMark("@yongdiMark")<1 then return end
                males = room:askForPlayerChosen(player,males,"yongdi","@yongdi-invoke",true,true)
				if males
				then
                    room:broadcastSkillInvoke("yongdi")
                    room:doSuperLightbox(player:getGeneralName(),"yongdi")
                    room:removePlayerMark(player,"@yongdiMark")
                    room:gainMaxHp(males)
                    if males:isLord() then return end
                    local skills = {}
	    			for _,skill in sgs.list(males:getGeneral():getVisibleSkillList())do
                        if skill:isLordSkill()
	    				and not males:hasLordSkill(skill,true)
	    				then
                            table.insert(skills,skill:objectName())
	    				end
                    end
                    if males:getGeneral2()
	    			then
	    	    		for _,skill in sgs.list(males:getGeneral2():getVisibleSkillList())do
                            if skill:isLordSkill()
	    			    	and not males:hasLordSkill(skill,true)
	    			    	then
                                table.insert(skills,skill:objectName())
	    			    	end
                        end
                    end
                    if #skills<1 then return end
                    room:handleAcquireDetachSkills(males,table.concat(skills,"+"))
				end
			end
		elseif event==sgs.AskForPeachesDone
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("fenxin")
--        	if skill then skill:trigger(event,room,player,data) end
		end
		return false
	end,
}
jl_baxianding:addSkill(jl_xianfa)
jl_baxianding:addRelateSkill("xiongyi")
jl_baxianding:addRelateSkill("jianshu")
jl_baxianding:addRelateSkill("yongdi")
--jl_baxianding:addRelateSkill("zengdao")
jl_baxianding:addRelateSkill("fuli")
jl_baxianding:addRelateSkill("fencheng")
jl_baxianding:addRelateSkill("fenxin")
jl_baxianding:addRelateSkill("luanwu")
jl_baxianding:addRelateSkill("niepan")

jl_liuyan = sgs.General(extension,"jl_liuyan","qun",3)
jl_tuse = sgs.CreateTriggerSkill{
	name = "jl_tuse",
	frequency = sgs.Skill_Frequent,
	events = {sgs.TargetSpecifying,sgs.CardFinished,sgs.DamageCaused},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.TargetSpecifying
		then
			local use,n = data:toCardUse(),0
			if use.card:isKindOf("SkillCard") then return end
           	for _,to in sgs.list(use.to)do
               	if player:objectName()~=to:objectName()
				then n = n+1 end
		   	end
		   	if n>0
			and player:askForSkillInvoke(self:objectName(),sgs.QVariant("jl_tuse0:"..n))
			then
	            room:broadcastSkillInvoke("jl_tuse")--播放配音
				player:drawCards(n,self:objectName())
			end
    		data:setValue(use)
		end
	end
}
jl_liuyan:addSkill(jl_tuse)
jl_mu = sgs.CreateTrickCard{--锦囊牌
	name = "__jl_mu",
	class_name = "JlMu",--卡牌的类名
	subtype = "delayed_trick",--卡牌的子类型
	subclass = sgs.LuaTrickCard_TypeDelayedTrick,--卡牌的类型 延时锦囊
	target_fixed = true,
	can_recast = false,
	is_cancelable = true,
	movable = false,
	about_to_use = function(self,room,use)
    	if use.to:isEmpty() then use.to:append(use.from) end
	    self:cardOnUse(room,use)
	end,
	on_effect = function(self,effect)
		local target = effect.to
		local room = target:getRoom()
        local log = sgs.LogMessage()
		log.type = "$tianzhai"
		log.arg = self:objectName()
		log.from = target
	   	room:sendLog(log)
		log = "."
		if self:isBlack() then log = ".|black"
		elseif self:isRed() then log = ".|red" end
		local judge = sgs.JudgeStruct()
		judge.pattern = log
		judge.good = false
	    judge.negative = true
		judge.reason = self:objectName()
		judge.who = target
    	room:judge(judge)
        if judge:isBad() then room:loseHp(target,target:getHp(),false,"__jl_mu") end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER,target:objectName())
    	room:throwCard(self,reason,nil)--弃牌
		return false
	end,
}
jl_mu:clone(6,0):setParent(extensioncard)
jl_limuVS = sgs.CreateViewAsSkill{
	name = "jl_limu",
	n = 1,
	view_filter = function(self,selected,to_select)
		return true
	end,
	view_as = function(self,cards)
		if #cards<1 then return end
		local card = sgs.Sanguosha:cloneCard("__jl_mu")
	   	card:setSkillName("jl_limu")
	   	for _,c in sgs.list(cards)do
		   	card:addSubcard(c)
		end
		return card
	end,
	enabled_at_play = function(self,player)
		return not player:containsTrick("__jl_mu")
	end
}
jl_liuyan:addSkill(jl_limuVS)

jl_womensa = sgs.General(extension,"jl_womensa","wei",3)
jl_womensa:addSkill("jl_tianji")
jl_xingtuo = sgs.CreateTriggerSkill{
	name = "jl_xingtuo",
	events = {sgs.Damaged,sgs.Dying},
--	frequency = sgs.Skill_Frequent,
	on_trigger = function(self,event,player,data,room)
	   	if event==sgs.Damaged
	    then
            local damage = data:toDamage()
			local to = room:askForPlayerChosen(player,room:getAlivePlayers(),"jl_xingtuo","jl_xingtuo0:",true,true)
			if to
			then
	        	room:broadcastSkillInvoke("huituo")--播放配音
				local judge = sgs.JudgeStruct()
	        	judge.pattern = ".|red,black"
	        	judge.good = true
--	            judge.negative = true
	        	judge.reason = self:objectName()
	        	judge.who = to
            	room:judge(judge)
				if judge:isGood()
				then
		    		judge = to:getTag("JudgeCard_"..judge.reason):toCard()
					if judge:isRed()
					then
			    		room:recover(to,sgs.RecoverStruct(player))
					elseif judge:isBlack()
					then
				    	to:drawCards(damage.damage,self:objectName())
					end
				end
			end
	   	elseif event==sgs.Dying
	   	then
	     	local dying = data:toDying()
			if dying.who:objectName()==player:objectName()
			and player:askForSkillInvoke(self:objectName(),data)
			then
	        	room:broadcastSkillInvoke("xingshuai")--播放配音
    			for _,p in sgs.list(room:getOtherPlayers(player))do
				   	if p:getKingdom()==player:getKingdom()
					then
    					room:doAnimate(1,player:objectName(),p:objectName())
					end
		    	end
				room:doSuperLightbox(player:getGeneralName(),"jl_xingtuo")
    			for _,p in sgs.list(room:getOtherPlayers(player))do
				   	if p:getKingdom()==player:getKingdom()
					and p:askForSkillInvoke("jl_xingtuo0",sgs.QVariant("jl_xingtuo1:"..player:objectName()),false)
					then
    					room:damage(sgs.DamageStruct(self:objectName(),nil,p))
						room:recover(player,sgs.RecoverStruct(p))
					end
		    	end
			end
		end
		return false
	end,
}
jl_womensa:addSkill(jl_xingtuo)
jl_xianchou = sgs.CreateTriggerSkill{
	name = "jl_xianchou",
	events = {sgs.Damaged,sgs.HpRecover},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data,room)
	   	if event==sgs.Damaged
	    then
            local damage = data:toDamage()
			if player:getMark("jl_xc_damage")<1
			then
				player:addMark("jl_xc_damage")
	           	room:sendCompulsoryTriggerLog(player,"jl_xianchou")
	        	room:broadcastSkillInvoke("xianfu")--播放配音
				room:damage(sgs.DamageStruct("xianfu",nil,player,damage.damage))
		    end
			player:setMark("jl_xc_damage",0)
			if player:isDead() then return end
			room:sendCompulsoryTriggerLog(player,"jl_xianchou")
	       	room:broadcastSkillInvoke("chouce")--播放配音
			local judge = sgs.JudgeStruct()
	       	judge.pattern = ".|red,black"
	       	judge.good = true
--		   	judge.negative = true
	       	judge.reason = self:objectName()
	       	judge.who = player
           	room:judge(judge)
			if judge:isGood()
			then
	         	local to = PlayerChosen(self,player,nil,"jl_xianchou0:")
		       	if to
		       	then
		   	    	judge = player:getTag("JudgeCard_"..judge.reason):toCard()
		    		if judge:isRed()
			    	then
						if to:objectName()~=player:objectName()
						then judge = 1 else judge = 2 end
						to:drawCards(judge,self:objectName())
			    	elseif judge:isBlack()
			    	then
	               		local id = room:askForCardChosen(player,to,"hej","jl_xianchou")
						if id~=-1 then room:throwCard(id,to,player) end
		    		end
		    	end
		   	end
	   	end
		if event==sgs.HpRecover
	   	then
	       	local rec = data:toRecover()
			if player:getMark("jl_xc_recover")<1
			then
				rec.card = nil
				player:addMark("jl_xc_recover")
				room:sendCompulsoryTriggerLog(player,"jl_xianchou")
				room:broadcastSkillInvoke("xianfu")--播放配音
				room:recover(player,rec)
			end
			player:setMark("jl_xc_recover",0)
		end
		return false
	end,
}
jl_womensa:addSkill(jl_xianchou)

function jl_jiangbf(sunce)
	local room = sunce:getRoom()
	if sunce:askForSkillInvoke("jiang")
	then
	   	local count = sunce:getMark("jl_sexiang_jiang")+1
	   	room:broadcastSkillInvoke("jiang",math.random(1,4))--播放配音
		sunce:drawCards(count,"jiang")
	end
end
jl_yuerqiao = sgs.General(extension,"jl_yuerqiao","god")
jl_yuerqiao:setGender(sgs.General_Neuter)
jl_sexiangCard = sgs.CreateSkillCard{
	name = "jl_sexiangCard",
	will_throw = false,
	target_fixed = true,
	about_to_use = function(self,room,use)
		if use.to:isEmpty() then use.to:append(use.from) end
		local card = sgs.Sanguosha:cloneCard("indulgence")
       	card:setSkillName("jl_sexiang")
		card:addSubcard(self)
	   	room:broadcastSkillInvoke("guose",math.random(1,2))--播放配音
       	room:useCard(sgs.CardUseStruct(card,use.from,use.to))
		if use.from:hasSkill("jl_jiangy")
		then room:addPlayerMark(use.from,"jl_sexiang_jiang")
		else room:acquireSkill(use.from,"jl_jiangy") end
		return false
	end
}
jl_sexiangVS = sgs.CreateViewAsSkill{
	name = "jl_sexiang",
	n = 1,
	view_filter = function(self,selected,to_select)
       	return to_select:getSuitString()=="diamond"
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if #cards<1 then return end
		local card = jl_sexiangCard:clone()
		for _,c in sgs.list(cards)do
			card:addSubcard(c)
		end
		return card
	end,
	enabled_at_play = function(self,player)
        return not player:containsTrick("indulgence")
	end
}
jl_sexiang = sgs.CreateTriggerSkill{
	name = "jl_sexiang",
	events = {sgs.DamageInflicted},
	view_as_skill = jl_sexiangVS,
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
    	local can
		for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
	   	if event==sgs.DamageInflicted
		then
	        local damage = data:toDamage()
        	if damage.to:objectName()~=owner:objectName()
			and room:askForCard(owner,".|heart|.|hand","jl_sexiang0:heart:"..damage.to:objectName(),data,"jl_sexiang")
	    	then
	        	room:broadcastSkillInvoke("tianxiang",math.random(1,2))--播放配音
			   	damage.to = owner
			   	damage.transfer = true
				room:damage(damage)
				can = true
	        	if owner:hasSkill("jl_yingziy")
	        	then room:addPlayerMark(owner,"jl_sexiang_yingzi")
	        	else room:acquireSkill(owner,"jl_yingziy") end
			end
-- 	        data:setValue(damage)
		end
		end
		return can
	end
}
jl_yuerqiao:addSkill(jl_sexiang)
jl_yanyinVS = sgs.CreateViewAsSkill{
	name = "jl_yanyin",
	n = 998,
	view_filter = function(self,selected,to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self,cards)
		if #cards<2 then return end
		local card = jl_yanyinCard:clone()
		for _,c in sgs.list(cards)do
			card:addSubcard(c)
		end
		return card
	end,
	enabled_at_play = function(self,player)
		return player:getMark("jl_yanyinCard")<1
	end
}
jl_yanyinCard = sgs.CreateSkillCard{
	name = "jl_yanyinCard",
	target_fixed = true,
	about_to_use = function(self,room,use)
        local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
	   	if use.to:isEmpty()
	   	then
	        for _,p in sgs.list(room:getAlivePlayers())do
	    	   	use.to:append(p)
	    	end
    	end
	    self:cardOnUse(room,use)
	end,
	on_use = function(self,room,source,targets)
		room:addPlayerMark(source,"jl_yanyinCard")
		local to_xz = room:askForChoice(source,"jl_yanyin","jl_yanyin1+jl_yanyin2")
		if to_xz=="jl_yanyin1"
		then
	       	room:broadcastSkillInvoke("yeyan",math.random(1,2))--播放配音
		else
	       	room:broadcastSkillInvoke("qinyin",math.random(1,2))--播放配音
		end
		for _,to in sgs.list(targets)do
			if to_xz=="jl_yanyin1"
			then
    			room:damage(sgs.DamageStruct(self,source,to,1,sgs.DamageStruct_Fire))
			else
    			room:recover(to,sgs.RecoverStruct(source,self))
			end
		end
		return false
	end
}
jl_yanyin = sgs.CreateTriggerSkill{
	name = "jl_yanyin",
	events = {sgs.RoundStart},
	view_as_skill = jl_yanyinVS,
	on_trigger = function(self,event,player,data,room)
       	if event==sgs.RoundStart
	   	then
			room:setPlayerMark(player,"jl_yanyinCard",0)
		end
	end
}
jl_yuerqiao:addSkill(jl_yanyin)
jl_yuerqiao:addRelateSkill("jiang")
jl_yuerqiao:addRelateSkill("nosyingzi")
jl_yingziy = sgs.CreateTriggerSkill{
	name = "jl_yingziy",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player,self:objectName(),data)
		then
			local count = data:toInt()+1
			count = count+player:getMark("jl_sexiang_yingzi")
	       	room:broadcastSkillInvoke("yingzi",math.random(1,4))--播放配音
			data:setValue(count)
		end
	end
}
addToSkills(jl_yingziy)
jl_jiangy = sgs.CreateTriggerSkill{
	name = "jl_jiangy",
	events = {sgs.TargetConfirmed,sgs.TargetSpecified},
	frequency = sgs.Skill_Frequent,
	on_trigger = function(self,event,sunce,data)
		local use = data:toCardUse()
		if event==sgs.TargetSpecified
		or (event==sgs.TargetConfirmed and use.to:contains(sunce))
		then
			if use.card:isKindOf("Duel")
			or use.card:isKindOf("Slash") and use.card:isRed()
			then jl_jiangbf(sunce) end
		end
		return false
	end
}
addToSkills(jl_jiangy)

jl_wudaoshi = sgs.General(extension,"jl_wudaoshi","god",3)
jl_gh_name = ""
function jl_guhuo(self,yuji)
	local room = yuji:getRoom()
	local players = room:getOtherPlayers(yuji)
	local questions = sgs.SPlayerList()
	local user = self:getUserString()						
	for _,p in sgs.list(players)do
		local log = sgs.LogMessage()
		log.type = "#GuhuoQuery"
		log.from = p
  		log.arg = "question"
		if p:getHp()<1
		then
			log.type = "#NOGuhuoQuery"
			room:sendLog(log)
			continue
		end
		if p:askForSkillInvoke("guhuo_question",sgs.QVariant("question0:"..yuji:objectName()..":"..user),false)
		then
			room:setEmotion(p,"question")
			questions:append(p)
		else
			room:setEmotion(p,"no-question")					
	    	log.arg = "no-question"
		end
		room:sendLog(log)
		room:getThread():delay(555)
	end
	local log = sgs.LogMessage()
	log.type = "$GuhuoResult"
	log.from = yuji
	local cid = self:getEffectiveId()
	log.card_str = cid
	room:sendLog(log)
	local can,to_can = false,false
	local card = sgs.Sanguosha:getCard(cid)
	if questions:isEmpty()
	then can = true
	else
		if user=="slash"
		then to_can = string.find(card:objectName(),"slash")
		elseif string.find(user,"slash")
		then to_can = card:objectName()==user
		else to_can = card:match(user) end
		if to_can and card:getSuitString()=="heart"
		then can = true
		else
	    	log = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT,yuji:objectName(),"","guhuo")
			room:throwCard(self,log,nil)
		end	
		if to_can
		then
			for _,p in sgs.list(questions)do
				room:loseHp(p,1,false,yuji,"nosguhuo")
			end
		else
			for _,p in sgs.list(questions)do
				if p:isAlive()
				then
					p:drawCards(1,"nosguhuo")
				end
			end
		end
	end
	for _,p in sgs.list(players)do
		room:setEmotion(p,".")
	end			
	return can
end
jl_guhuoCard = sgs.CreateSkillCard {
	name = "nosguhuocard",
	will_throw = false,
	filter = function(self,targets,to_select,player)
		local pattern = self:getUserString()
		if pattern=="normal_slash"
		then pattern = "slash" end
		return SCfilter(pattern,targets,to_select,nil,"nosguhuo")
	end,	
	feasible = function(self,targets)
		local pattern = self:getUserString()
		if pattern=="normal_slash"
		then pattern = "slash" end
		return SCfeasible(pattern,targets,nil,"nosguhuo")
	end,	
	on_validate = function(self,use)
		local yuji = use.from
		local room = yuji:getRoom()
		local to_guhuo = room:askForChoice(yuji,"guhuo_slash",self:getUserString())
		room:broadcastSkillInvoke("nosguhuo")
		local log = sgs.LogMessage()
		if use.to:isEmpty()
		then log.type = "#GuhuoNoTarget"
		else log.type = "#Guhuo" end
		log.from = yuji
		log.to = use.to
		log.arg = to_guhuo
		log.arg2 = "guhuo"		
		room:sendLog(log)
		if jl_guhuo(self,yuji)
		then
			local use_card = sgs.Sanguosha:cloneCard(to_guhuo)
			use_card:setSkillName("nosguhuo")
			use_card:addSubcard(self)
			return use_card
		end
		return nil
	end,
	on_validate_in_response = function(self,yuji)
		local room = yuji:getRoom()
		local to_guhuo = room:askForChoice(yuji,"guhuo_slash",self:getUserString())
		room:broadcastSkillInvoke("nosguhuo")
		local log = sgs.LogMessage()
		log.type = "#GuhuoNoTarget"
		log.from = yuji
		log.arg = to_guhuo
		log.arg2 = "guhuo"		
		room:sendLog(log)
		if jl_guhuo(self,yuji)
		then
			local use_card = sgs.Sanguosha:cloneCard(to_guhuo)
			use_card:setSkillName("nosguhuo")
			use_card:addSubcard(self)
			return use_card
		end
		return nil
	end
}
jl_daoshucard = sgs.CreateSkillCard{
	name = "zhoufucard",
	will_throw = false,
	filter = function(self,targets,to_select,source)
		return #targets<1
		and self:subcardsLength()>0
		and to_select:objectName()~=source:objectName()
		and to_select:getPile("incantation"):isEmpty()
	end,
	target_fixed = function(self)
		return self:subcardsLength()<1
	end,
	feasible = function(self,targets)
    	if self:subcardsLength()>0
		then return #targets>0 end
		return true
	end,
	about_to_use = function(self,room,use)
        local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
    	if use.to:isEmpty()
		then
	       	local choice = AgCardsToName(use.from,"basic+trick",true)
	    	jl_gh_name = choice
	   		room:askForUseCard(use.from,"@@jl_daoshu","@jl_daoshu:"..choice)
	   	else
       	    self:cardOnUse(room,use)
	    	room:addPlayerMark(use.from,"zhoufucard-PlayClear")
	   	end
	end,
	on_use = function(self,room,source,targets)
		for _,to in sgs.list(targets)do
			room:addPlayerMark(source,"zhoufu_"..self:getSubcards():at(0))
			to:addToPile("incantation",self)
		end
	end
}
jl_daoshuVS = sgs.CreateViewAsSkill{
	name = "jl_daoshu",
	n = 1,
	view_filter = function(self,selected,to_select)
        local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern~=""
		or sgs.Self:getMark("zhoufucard-PlayClear")<1
		then return not to_select:isEquipped() end
	end,
	view_as = function(self,cards)
        local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
	   	local card = jl_daoshucard:clone()
		if pattern~=""
		then
    		if #cards<1 then return end
			card = jl_guhuoCard:clone()
			if pattern=="@@jl_daoshu"
			then pattern = jl_gh_name end
			card:setUserString(pattern)
		end
	   	for _,c in sgs.list(cards)do
	    	card:addSubcard(c)
	   	end
		return card
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_daoshu")
		then return true end
     	local items = pattern:split("+")
	   	for _,c in sgs.list(items)do
	    	c = sgs.Sanguosha:cloneCard(c)
			if c then return c end
		end
	end,
	enabled_at_nullification = function(self,player)
		return not player:isKongcheng()
	end,
	enabled_at_play = function(self,player)
		return player:isAlive()
	end
}
jl_daoshu = sgs.CreateTriggerSkill{
	name = "jl_daoshu",
	view_as_skill = jl_daoshuVS,
	events = {sgs.EventPhaseStart,sgs.CardsMoveOneTime,sgs.Damage,
	sgs.AskForRetrial,sgs.CardResponded,sgs.Damaged,sgs.GameStart},
	on_trigger = function(self,event,player,data,room)
        if event==sgs.EventPhaseStart
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("yishe")
        	if skill then skill:trigger(event,room,player,data) end
			if player:getPhase()==sgs.Player_RoundStart
			or player:getPhase()==sgs.Player_NotActive
			then
	         	local skill = sgs.Sanguosha:getTriggerSkill("#huashen-select")
	         	room:attachSkillToPlayer(player,"huashen")
            	if skill then skill:trigger(event,room,player,data) end
	          	room:detachSkillFromPlayer(player,"huashen",true,true)
			end
		elseif event==sgs.GameStart
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("huashen")
        	if skill then skill:trigger(event,room,player,data) end
		elseif event==sgs.AskForRetrial
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("guidao")
        	if skill then skill:trigger(event,room,player,data) end
	     	local skill = sgs.Sanguosha:getTriggerSkill("midao")
        	if skill then skill:trigger(event,room,player,data) end
		elseif event==sgs.CardResponded
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("nosleiji")
        	if skill then skill:trigger(event,room,player,data) end
		elseif event==sgs.Damage
		then
	        local damage = data:toDamage()
	     	local skill = sgs.Sanguosha:getTriggerSkill("bushi")
	       	room:attachSkillToPlayer(player,"bushi")--布施
           	if skill then skill:trigger(event,room,player,data) end
	       	room:detachSkillFromPlayer(player,"bushi",true,true)
		elseif event==sgs.Damaged
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("xinsheng")
        	if skill then skill:trigger(event,room,player,data) end
	     	skill = sgs.Sanguosha:getTriggerSkill("bushi")
	       	room:attachSkillToPlayer(player,"bushi")
           	if skill then skill:trigger(event,room,player,data) end
	       	room:detachSkillFromPlayer(player,"bushi",true,true)
		elseif event==sgs.CardsMoveOneTime
		then
    		local move = data:toMoveOneTime()
	     	local skill = sgs.Sanguosha:getTriggerSkill("yishe")
        	if skill then skill:trigger(event,room,player,data) end
			if move.reason.m_reason==sgs.CardMoveReason_S_REASON_JUDGEDONE
--			and move.from_places:contains(sgs.Player_PlaceSpecial)
			then
				for _,id in sgs.list(move.card_ids)do
			       	if player:getMark("zhoufu_"..id)>0
					and player:askForSkillInvoke("yingbing",data)
			   		then player:drawCards(2,"yingbing") end
					room:setPlayerMark(player,"zhoufu_"..id,0)
		       	end
			end
		end
		return false
	end,
}
jl_wudaoshi:addSkill(jl_daoshu)
jl_wudaoshi:addRelateSkill("nosleiji")
jl_wudaoshi:addRelateSkill("guidao")
jl_wudaoshi:addRelateSkill("huashen")
jl_wudaoshi:addRelateSkill("xinsheng")
jl_wudaoshi:addRelateSkill("nosguhuo")
jl_wudaoshi:addRelateSkill("zhoufu")
jl_wudaoshi:addRelateSkill("yingbing")
jl_wudaoshi:addRelateSkill("yishe")
jl_wudaoshi:addRelateSkill("bushi")
jl_wudaoshi:addRelateSkill("midao")

jl_miansha = sgs.General(extension,"jl_miansha","god")
jl_yeguiCard = sgs.CreateSkillCard{
	name = "jl_yeguiCard" ,
	filter = function(self,targets,to_select,from)
		return #targets<1
		and from:isAdjacentTo(to_select)
	end,
	on_effect = function(self,effect)
		local room = effect.from:getRoom()
	   	room:broadcastSkillInvoke("gongxin",math.random(1,2))--播放配音
		room:doGongxin(effect.from,effect.to,effect.to:handCards())
	end
}	
jl_yeguiVS = sgs.CreateZeroCardViewAsSkill{
	name = "jl_yegui" ,
	view_as = function()
		return jl_yeguiCard:clone()
	end ,
	enabled_at_play = function(self,target)
		return true --target:usedTimes("#jl_yeguiCard")<1
	end
}
jl_yegui = sgs.CreateTriggerSkill{
	name = "jl_yegui",
	events = {sgs.EventPhaseStart,sgs.ConfirmDamage,sgs.CardEffected,sgs.CardUsed,
	sgs.EventPhaseChanging,sgs.EventPhaseProceeding,sgs.PostCardEffected,sgs.DrawNCards},
	view_as_skill = jl_yeguiVS,
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
        if event==sgs.EventPhaseStart
		then
			if player:getPhase()==sgs.Player_Play
			and player:objectName()~=owner:objectName()
			and owner:isWounded()
			then
	         	room:askForUseCard(owner,"peach","jl_yegui1:peach")
			end
		elseif event==sgs.DrawNCards
		then
     		if player:objectName()==owner:objectName()
			and room:askForSkillInvoke(owner,self:objectName(),sgs.QVariant("jl_yegui2:"))
	    	then
		    	local count = data:toInt()+1
	         	room:broadcastSkillInvoke("yingzi",math.random(1,2))--播放配音
		    	data:setValue(count)
	    	end
		elseif event==sgs.EventPhaseChanging
		then
	    	local change = data:toPhaseChange()
			if owner:isWounded()
			and change.to==sgs.Player_NotActive
			and player:objectName()==owner:objectName()
			and room:askForSkillInvoke(owner,self:objectName(),sgs.QVariant("jl_yegui3:"))
			then room:recover(owner,sgs.RecoverStruct(owner)) end
			if change.to==sgs.Player_Judge
			and player:objectName()==owner:objectName()
			and room:askForSkillInvoke(owner,self:objectName(),sgs.QVariant("jl_yegui4:"))
			then
	    		owner:skip(sgs.Player_Judge)
	         	room:broadcastSkillInvoke("qiaobian",math.random(1,2))--播放配音
	    		if owner:getJudgingArea():isEmpty() then return end
				change = sgs.Sanguosha:cloneCard("slash")
				change:addSubcards(owner:getJudgingArea())
				room:throwCard(change,owner)
			end
 		elseif event==sgs.EventPhaseProceeding
		then
	    	local can = false
			for _,p in sgs.list(room:getAllPlayers())do
		      	p = p:getHandcardNum()
				if owner:getHandcardNum()<p
		  		then can = p end
	    	end
			if can and owner:getPhase()==sgs.Player_Discard
			and room:askForSkillInvoke(owner,self:objectName(),sgs.QVariant("jl_yegui5:"))
			then
	         	room:broadcastSkillInvoke("keji",math.random(1,2))--播放配音
				return true
			end
		elseif event==sgs.CardEffected
		then
            local effect = data:toCardEffect()
			if effect.card:isKindOf("Duel")
			then
				if room:isCanceled(effect)
				then
					effect.to:setFlags("Global_NonSkillNullify")
					return true
				end
				if effect.to:isAlive()
				then
					local second = effect.from
					local first = effect.to
					room:setEmotion(first,"duel");
					room:setEmotion(second,"duel")
					while true do
						if first:isDead()
						then break end
						if room:askForNullification(effect.card,owner,first,true)
						then second = 0 break end
						local slash
						if second:hasSkill("wushuang")
						then
							slash = room:askForCard(first,"slash","@wushuang-slash-1:"..second:objectName(),data,sgs.Card_MethodResponse,second,false,"duel",false,effect.card)
							if slash==nil then break end
							slash = room:askForCard(first,"slash","@wushuang-slash-2:" .. second:objectName(),data,sgs.Card_MethodResponse,second,false,"duel",false,effect.card)
							if slash==nil then break end
						else
							slash = room:askForCard(first,"slash","duel-slash:"..second:objectName(),data,sgs.Card_MethodResponse,second,false,"duel",false,effect.card)
							if slash==nil then break end
						end
						local temp = first
						first = second
						second = temp
					end
					if second~=0
					then
			    		local damage = sgs.DamageStruct(effect.card,second,first)
				    	if second:objectName()~=effect.from:objectName()
				     	then damage.by_user = false end
				    	room:damage(damage)
				 	end
				end
				room:setTag("SkipGameRule",sgs.QVariant(true))
			end
			if effect.to:isKongcheng()
			or effect.to:objectName()~=owner:objectName()
			then return end
			if effect.card:isKindOf("Snatch")
			or effect.card:isKindOf("Dismantlement")
			then
	        	local cards = room:askForExchange(owner,self:objectName(),998,1,false,"jl_yegui0:"..effect.card:objectName(),true)
		    	if cards
		    	then
	             	owner:setFlags(effect.card:toString())
					room:broadcastSkillInvoke("qianxun",math.random(1,2))--播放配音
					owner:addToPile("jl_yegui",cards,false)
		    	end
			end
		elseif event==sgs.PostCardEffected
		then
            local effect = data:toCardEffect()
			if effect.to:getPile("jl_yegui"):isEmpty() then return end
			if effect.to:hasFlag(effect.card:toString())
			then
	           	effect.to:setFlags("-"..effect.card:toString())
				local change = sgs.Sanguosha:cloneCard("slash")
				change:addSubcards(effect.to:getPile("jl_yegui"))
				room:obtainCard(effect.to,change,false)
			end
		elseif event==sgs.CardUsed
		then
	    	local use = data:toCardUse()
			if use.card:isKindOf("AOE")
			or use.card:isKindOf("GlobalEffect")
			or use.card:isKindOf("IronChain")
			then
	    		if room:askForNullification(use.card,owner,use.from,true)
				then use.from:setFlags("Global_NonSkillNullify") return true end
			end
		elseif event==sgs.ConfirmDamage
		then
	        local damage = data:toDamage()
			if damage.from:objectName()==owner:objectName()
			and damage.card and damage.card:isKindOf("Slash")
			and damage.nature~=sgs.DamageStruct_Normal
			then
				damage.damage = damage.damage+1
			end
			data:setValue(damage)
		end
		end
		return false
	end,
}
jl_miansha:addSkill(jl_yegui)

jl_zhouyu = sgs.General(extension,"jl_zhouyu","wu")
jl_xiongzi = sgs.CreateTriggerSkill{
	name = "jl_xiongzi",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player,self:objectName(),data)
		then
			local count = data:toInt()
	        for _,p in sgs.list(room:getAlivePlayers())do
	     		if p:isFemale() then count = count+1 end
	    	end
	       	room:broadcastSkillInvoke(self:objectName())--播放配音
			data:setValue(count)
		end
	end
}
jl_zhouyu:addSkill(jl_xiongzi)
jl_xixiongcard = sgs.CreateSkillCard{
	name = "jl_xixiongcard",
	will_throw = false,
	filter = function(self,targets,to_select,source)
		return #targets<1
		and to_select:isFemale()
		and to_select:getMark("jl_xx_no-PlayClear")<1
	end,
	on_use = function(self,room,source,targets)
		for _,to in sgs.list(targets)do
            local id = room:doGongxin(source,to,to:handCards(),"jl_xixiong")
			room:addPlayerMark(to,"jl_xx_no-PlayClear")
	    	if id~=-1
	    	then
	            id = sgs.Sanguosha:getCard(id)
				for _,c in sgs.list(to:getHandcards())do
	         		if c:getSuit()==id:getSuit()
					then self:addSubcard(c) end
	        	end
				room:obtainCard(source,self)
				to:drawCards(self:subcardsLength(),self:objectName())
			end
		end
	end
}
jl_xixiongVS = sgs.CreateViewAsSkill{
	name = "jl_xixiong",
	view_as = function(self,cards)
		return jl_xixiongcard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:isAlive()
	end
}
jl_zhouyu:addSkill(jl_xixiongVS)

jl_shenma = sgs.General(extension,"jl_shenma","god")
jl_sz_sks = {}
jl_shenzhucard = sgs.CreateSkillCard{
	name = "jl_shenzhucard",
	will_throw = false,
	filter = function(self,targets,to_select,source)
		local c = self:getSubcards():at(0)
		c = sgs.Sanguosha:getCard(c)
		jl_sz_sks = {}
		if c:isKindOf("Slash")
		then
	    	if to_select:getMark("fuman_to")<1
			and to_select:objectName()~=source:objectName()
			then table.insert(jl_sz_sks,"fuman_to") end
		end
        local alive = source:getAliveSiblings()
		alive:append(source)
		local can =true
		if source:getMark("sanyao_hp-PlayClear")<1
		then
			for _,p in sgs.list(alive)do
            	if p:getHp()>to_select:getHp()
            	then can = false break end
         	end
			if can
			then
				table.insert(jl_sz_sks,"sanyao_hp")
			end
		end
		if source:getMark("sanyao_hand-PlayClear")<1
		then
			can = true
			for _,p in sgs.list(alive)do
            	if p:getHandcardNum()>to_select:getHandcardNum()
            	then can = false break end
         	end
			if can
			then
				table.insert(jl_sz_sks,"sanyao_hand")
			end
		end
		if #targets>0
		then
	    	jl_sz_sks = {}
	    	if c:isKindOf("Slash")
	    	then
	        	if targets[1]:getMark("fuman_to")<1
		    	and targets[1]:objectName()~=source:objectName()
		    	then table.insert(jl_sz_sks,"fuman_to") end
	    	end
        	if source:getMark("sanyao_hp-PlayClear")<1
	     	then
	    		can = true
		    	for _,p in sgs.list(alive)do
                	if p:getHp()>targets[1]:getHp()
                	then can = false break end
             	end
		    	if can
		    	then
		    		table.insert(jl_sz_sks,"sanyao_hp")
		    	end
	    	end
    		if source:getMark("sanyao_hand-PlayClear")<1
	    	then
	    		can = true
		    	for _,p in sgs.list(alive)do
                	if p:getHandcardNum()>targets[1]:getHandcardNum()
                  	then can = false break end
             	end
	    		if can
	    		then
		    		table.insert(jl_sz_sks,"sanyao_hand")
	    		end
	    	end
			return
		end
		return #jl_sz_sks>0
	end,
	feasible = function(self,targets)
		return #targets>0
	end,
	about_to_use = function(self,room,use)
	   	jl_sz_sks = type(jl_sz_sks)=="table" and #jl_sz_sks>0 and table.concat(jl_sz_sks,"+") or "fuman_to+sanyao_hp+sanyao_hand"
		jl_sz_sks = room:askForChoice(use.from,"jl_shenzhu",jl_sz_sks)
		local name = "fuman"
		if string.find(jl_sz_sks,"sanyao")
		then name = "sanyao" end
		self:setObjectName(name)
		self:cardOnUse(room,use)
	end,
	on_use = function(self,room,source,targets)
		for _,to in sgs.list(targets)do
			if string.find(jl_sz_sks,"sanyao")
			then
    			room:throwCard(self,source)
				room:damage(sgs.DamageStruct(self,source,to))
				room:addPlayerMark(source,jl_sz_sks.."-PlayClear")
			else
		    	room:obtainCard(to,self)
	        	local id = self:getSubcards():at(0)
				room:addPlayerMark(to,"fuman_to")
				room:addPlayerMark(to,"fuman_to:"..source:objectName()..":"..id)
			end
		end
	end
}
jl_shenzhuVS = sgs.CreateViewAsSkill{
	name = "jl_shenzhu",
	n = 1,
	view_filter = function(self,selected,to_select)
        local can
        local alive = sgs.Self:getAliveSiblings()
		for _,p in sgs.list(alive)do
           	if p:getMark("fuman_to")<1
			and to_select:isKindOf("Slash")
           	then can = true break end
       	end
		if sgs.Self:getMark("sanyao_hand-PlayClear")<1
		or sgs.Self:getMark("sanyao_hp-PlayClear")<1
		then can = true end
		return can
	end,
	view_as = function(self,cards)
        local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
   		if #cards<1 then return end
	   	pattern = jl_shenzhucard:clone()
	   	for _,c in sgs.list(cards)do
	    	pattern:addSubcard(c)
	   	end
		return pattern
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_shenzhu")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return player:isAlive()
	end
}
jl_shenzhu = sgs.CreateTriggerSkill{
	name = "jl_shenzhu",
	view_as_skill = jl_shenzhuVS,
	frequency = sgs.Skill_Compulsory,
	waked_skills = "tieji,sanyao,zhiman,fuman,zishu,yingyuan,nosqianxi",
	events = {sgs.CardsMoveOneTime,sgs.CardResponded,
	sgs.CardUsed,sgs.TargetConfirmed,sgs.TargetSpecifying,sgs.DamageCaused},
	on_trigger = function(self,event,player,data,room)
        if event==sgs.TargetSpecifying
		then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash")
			then return end
       	   	local list = use.no_respond_list
			for _,to in sgs.list(use.to)do
 				if to:isAlive()
				and room:askForSkillInvoke(player,"tieji",ToData(to))
				then
					to:addMark("tieji")
		    		room:broadcastSkillInvoke("tieji")
                    room:addPlayerMark(to,"@skill_invalidity")
                    local judge = sgs.JudgeStruct()
                    judge.pattern = "."
                    judge.good = true
                    judge.reason = "tieji"
                    judge.who = player
                    judge.play_animation = false
                    room:judge(judge)
					judge = player:getTag("JudgeCard_"..judge.reason):toCard():getSuitString()
                    if not room:askForCard(to,".|"..judge,"@tieji-discard:::"..judge,data)
					then
                        local log = sgs.LogMessage()
                        log.type = "#NoJink"
                        log.from = to
                        room:sendLog(log)
                        table.insert(list,to:objectName())
                    end
				end
		   	end
	    	use.no_respond_list = list
			data:setValue(use)
		elseif event==sgs.DamageCaused
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("nosqianxi")
        	if skill and skill:trigger(event,room,player,data)
			then return true end
	     	local skill = sgs.Sanguosha:getTriggerSkill("zhiman")
        	if skill then return skill:trigger(event,room,player,data) end
		elseif event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
		   	if move.to and move.to:objectName()==player:objectName()
			and move.to_place==sgs.Player_PlaceHand
			then
	       		if player:getPhase()~=sgs.Player_NotActive
	        	then
		    		if move.reason.m_skillName~="zishu"
					then
                        room:sendCompulsoryTriggerLog(player,"zishu",true,true,1)
                        player:drawCards(1,"zishu")
					end
				elseif not room:getTag("FirstRound"):toBool()
				then
	        		local ids = player:getTag("zishu"):toString():split("+")
	        		for _,id in sgs.list(move.card_ids)do
			    		table.insert(ids,id)
					end
					player:setTag("zishu",sgs.QVariant(table.concat(ids,"+")))
				end
			end
		elseif event==sgs.CardUsed
		or event==sgs.CardResponded
		then
	     	local skill = sgs.Sanguosha:getTriggerSkill("yingyuan")
           	if skill then skill:trigger(event,room,player,data) end
		elseif event==sgs.TargetConfirmed
		then
			local use = data:toCardUse()
			if use.from:getMark("fuman_to:"..player:objectName()..":"..use.card:getEffectiveId())>0
			then
		    	room:sendCompulsoryTriggerLog(player,"fuman",true,true,1)
                player:drawCards(1,"fuman")
			end
		end
		return false
	end,
}
jl_shenma:addSkill(jl_shenzhu)

jl_zhaoyun = sgs.General(extension,"jl_zhaoyun","god")
jl_zhaoyun:addSkill("longhun")
jl_zhaoyun:addSkill("juejing")
jl_zhaoyun:addSkill("longdan")
jl_zhaoyun:addSkill("yajiao")
jl_zhaoyun:addSkill("chongzhen")

jl_wuyi = sgs.General(extension,"jl_wuyi","god",6)
jl_mingqi_damage = nil
jl_wuyi:setStartHp(4)
jl_wuyi:setGender(sgs.General_Neuter)
jl_mingqiVS = sgs.CreateViewAsSkill{
	name = "jl_mingqi",
	view_as = function(self,cards)
    	local c = sgs.Self:getMark("jl_mingqi_id")
		c = sgs.Sanguosha:getCard(c)
		c = sgs.Sanguosha:cloneCard(c:objectName())
	   	c:setSkillName("_jl_mingqi")
		return c
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_mingqi")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return false
	end
}
jl_mingqi = sgs.CreateTriggerSkill{
	name = "jl_mingqi",
	events = {sgs.Death,sgs.Damage,sgs.Damaged,sgs.TargetSpecifying,
	sgs.EventPhaseChanging,sgs.EventPhaseStart,sgs.CardFinished},
	view_as_skill = jl_mingqiVS,
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
        if event==sgs.EventPhaseChanging
		then
	    	local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
				for _,skill in sgs.list(player:getVisibleSkillList())do
		    		skill = skill:objectName()
					if player:getMark("&duorui+:+"..skill.."+#"..owner:objectName())>0
		    	    then
	    	    		room:removePlayerMark(owner,"jl_mingqi_duorui")
			    		room:removePlayerMark(player,"Qingcheng"..skill)
						room:detachSkillFromPlayer(owner,skill)
			    		room:removePlayerMark(player,"&duorui+:+"..skill.."+#"..owner:objectName())
					end
				end
			end
			if change.from==sgs.Player_Play
			and owner:getMark("&xiantu+:+"..player:getGeneralName())>0
			and owner:getMark("jl_mingqi_nohp")<1
			then
	         	room:broadcastSkillInvoke("xiantu",2)--播放配音
				room:loseHp(owner,1,false,owner,"jl_mingqi")
			end
			owner:setMark("jl_mingqi_nohp",0)
			room:removePlayerMark(owner,"&xiantu+:+"..player:getGeneralName())
		elseif event==sgs.Death
		then
	     	local death = data:toDeath()
	        local damage = death.damage
			if damage
			and damage.from
			then
		    	if owner:getMark("&xiantu+:+"..damage.from:getGeneralName())>0
				then owner:addMark("jl_mingqi_nohp") end
			end
			for _,skill in sgs.list(death.who:getVisibleSkillList())do
		   		skill = skill:objectName()
				if death.who:getMark("&duorui+:+"..skill.."+#"..owner:objectName())>0
		   	    then
		    		room:removePlayerMark(owner,"jl_mingqi_duorui")
			   		room:removePlayerMark(death.who,"Qingcheng"..skill)
					room:detachSkillFromPlayer(owner,skill)
			   		room:removePlayerMark(death.who,"&duorui+:+"..skill.."+#"..owner:objectName())
				end
			end
			if owner:objectName()~=death.who:objectName()
			then return end
			for _,p in sgs.list(room:getOtherPlayers(owner))do
				for _,skill in sgs.list(p:getVisibleSkillList())do
		    		skill = skill:objectName()
					if p:getMark("&duorui+:+"..skill.."+#"..owner:objectName())>0
		    	    then
	    	    		room:removePlayerMark(owner,"jl_mingqi_duorui")
			    		room:removePlayerMark(p,"Qingcheng"..skill)
						room:detachSkillFromPlayer(owner,skill)
			    		room:removePlayerMark(p,"&duorui+:+"..skill.."+#"..owner:objectName())
					end
				end
			end
		elseif event==sgs.EventPhaseStart
		then
	    	local feng = owner:getPile("jl_mingqi_feng")
			if feng:length()>0
			and owner:getPhase()==sgs.Player_Start
			then
	         	room:broadcastSkillInvoke("tuifeng",2)--播放配音
				local card = sgs.Sanguosha:cloneCard("slash")
				card:addSubcards(feng)
				room:throwCard(card,owner)
				feng = feng:length()
				room:addPlayerMark(owner,"&tuifeng+slash-Clear",feng)
				owner:drawCards(feng*2,"jl_mingqi")
			end
			feng = owner:getTag("jl_mingqi"):toString()
			if owner:getPhase()==sgs.Player_Play
			and feng~=""
			then
 	         	local to = room:getOtherPlayers(player)
	    		owner:setMark("jl_mingqiChosen",7)
				to = room:askForPlayerChosen(player,to,"jl_mingqi","jl_mingqi7:",true,true)
				if to
				then
		        	room:broadcastSkillInvoke("choulve",2)--播放配音
	              	to = room:askForExchange(to,self:objectName(),1,1,true,"jl_mingqi8:"..player:objectName()..":"..feng,true)
					if to
					then
				    	room:obtainCard(player,to,false)
	               		to = PatternsCard(feng)
						room:setPlayerMark(player,"jl_mingqi_id",to:getEffectiveId())
						room:askForUseCard(player,"@@jl_mingqi!","jl_mingqi9:"..feng)
					end
				end
			end
			if owner:getPhase()==sgs.Player_NotActive
			and player:getPhase()==sgs.Player_Play
			and room:askForSkillInvoke(owner,self:objectName(),sgs.QVariant("jl_mingqi5:"..player:objectName()))
			then
				owner:drawCards(2,"jl_mingqi")
	           	feng = room:askForExchange(owner,self:objectName(),2,2,true,"jl_mingqi6:"..player:objectName())
				room:addPlayerMark(owner,"&xiantu+:+"..player:getGeneralName())
				room:obtainCard(player,feng,false)
			end
			if owner:getPhase()==sgs.Player_Finish
			then
	    		feng = 998
				local tos = {}
				for _,p in sgs.list(room:getAllPlayers())do
		    		if p:getHandcardNum()<feng
		  	    	then
			    		feng = p:getHandcardNum()
					end
					if owner:objectName()~=p:objectName()
					then table.insert(tos,p) end
	        	end
				local x = math.random(1,#tos)
				tos = tos[x]
	         	room:broadcastSkillInvoke("fujian",2)--播放配音
				room:doAnimate(1,owner:objectName(),tos:objectName())
				x = sgs.IntList()
				for _,id in sgs.list(tos:handCards())do
			    	if x:length() >= feng
		  	    	then break end
			    	x:append(id)
				end
	          	room:fillAG(x,owner)
	            room:askForAG(owner,x,true,"jl_mingqi")
                room:clearAG(owner)
	    		owner:setMark("jl_mingqiChosen",4)
 	         	tos = room:askForPlayerChosen(owner,room:getOtherPlayers(owner),"jl_mingqi","jl_mingqi4:",true,true)
				x = owner:getTag("jl_mingqi_daiyan"):toString()
				owner:setTag("jl_mingqi_daiyan",sgs.QVariant())
				if tos
				then
	             	room:broadcastSkillInvoke("daiyan",2)--播放配音
					for _,id in sgs.list(room:getDrawPile())do
	                   	id = sgs.Sanguosha:getCard(id)
			         	if id:isKindOf("BasicCard")
						and id:getSuitString()=="heart"
	                  	then room:obtainCard(tos,id) break end
	             	end
					if x==tos:objectName() then room:loseHp(tos,1,false,owner,"jl_mingqi") end
		    		owner:setTag("jl_mingqi_daiyan",sgs.QVariant(tos:objectName()))
				end
			end
		elseif event==sgs.Damaged
		then
	        local damage = data:toDamage()
			if damage.to:objectName()==owner:objectName()
			then
            	for i = 1,damage.damage do
	        		if not owner:isNude()
					and room:askForSkillInvoke(owner,self:objectName(),sgs.QVariant("jl_mingqi2:"..damage.card:objectName()))
					then
	                  	room:broadcastSkillInvoke("tuifeng",2)--播放配音
	                	i = room:askForExchange(owner,self:objectName(),1,1,true,"jl_mingqi3:")
						owner:addToPile("jl_mingqi_feng",i,false)
					end
				end
		    	if damage.card
		    	and (damage.card:isKindOf("BasicCard") or damage.card:isNDTrick())
		    	then
		        	room:broadcastSkillInvoke("choulve",2)--播放配音
		        	local on = owner:getTag("jl_mingqi"):toString()
			    	room:removePlayerMark(owner,"&choulve+:+"..on)
		        	on = damage.card:objectName()
			    	owner:setTag("jl_mingqi",sgs.QVariant(on))
			    	room:addPlayerMark(owner,"&choulve+:+"..on)
		    	end
			end
		elseif event==sgs.CardFinished
		then
	    	local use = data:toCardUse()
			if use.card:isKindOf("TrickCard")
			and owner:getPhase()==sgs.Player_Play
			and use.from:objectName()==owner:objectName()
			and owner:getMark("jl_mingqi_yisuan-PlayClear")<1
			and room:getCardPlace(use.card:getEffectiveId())==sgs.Player_DiscardPile
			and room:askForSkillInvoke(owner,self:objectName(),sgs.QVariant("jl_mingqi1:"..use.card:objectName()))
			then
	          	room:broadcastSkillInvoke("yisuan",1)--播放配音
				room:addPlayerMark(owner,"jl_mingqi_yisuan-PlayClear")
				room:loseMaxHp(owner)
				room:obtainCard(owner,use.card)
			end
		elseif event==sgs.TargetSpecifying
		then
	    	local use = data:toCardUse()
			if use.card:isKindOf("SkillCard")
			or use.card:isKindOf("EquipCard")
			or use.from:objectName()~=owner:objectName()
			or owner:getPhase()==sgs.Player_NotActive
			then return end
	    	local tos = sgs.SPlayerList()
			for _,p in sgs.list(room:getAllPlayers())do
				if p:isNude()
				or use.to:contains(p)
		  		then continue end
				tos:append(p)
	    	end
			if tos:isEmpty()
			then return end
			owner:setMark("jl_mingqiChosen",0)
 	     	tos = room:askForPlayerChosen(owner,tos,"jl_mingqi","jl_mingqi0:"..use.card:objectName(),true,true)
			if tos
			then
	          	room:broadcastSkillInvoke("qizhi",2)--播放配音
				local id = room:askForCardChosen(owner,tos,"he","jl_mingqi")
              	room:throwCard(id,tos,owner)
				tos:drawCards(1,"jl_mingqi")
			end
		elseif event==sgs.Damage
		then
	        local damage = data:toDamage()
			jl_mingqi_damage = damage
			if damage.to:isAlive()
			and owner:getPhase()==sgs.Player_Play
			and damage.to:objectName()~=owner:objectName()
			and damage.from:objectName()==owner:objectName()
			and owner:getMark("jl_mingqi_duorui")<1
			and ThrowEquipArea(self,owner,true)
			then
				room:addPlayerMark(owner,"jl_mingqi_duorui")
		    	room:broadcastSkillInvoke("duorui",2)--播放配音
				local sks = {}
				for _,skill in sgs.list(damage.to:getVisibleSkillList())do
		    		if not skill:isLordSkill() 
        			and not skill:isAttachedLordSkill()
		    		and skill:getFrequency()~=sgs.Skill_Wake
		     		and skill:getFrequency()~=sgs.Skill_Limited 
		    	    then table.insert(sks,skill:objectName()) end
				end
				if #sks<1 then return end
				sks = room:askForChoice(owner,self:objectName(),table.concat(sks,"+"))
				room:addPlayerMark(damage.to,"Qingcheng"..sks)
				room:addPlayerMark(damage.to,"&duorui+:+"..sks.."+#"..owner:objectName())
				room:acquireSkill(owner,sks)
				
			end
			data:setValue(damage)
		end
		end
		return false
	end,
}
jl_wuyi:addSkill(jl_mingqi)

jl_ceyu = sgs.General(extension,"jl_ceyu","god")
jl_ceyu:addSkill("jiang")
jl_ceyu:addSkill("qinyin")
jl_jiaoxinVS = sgs.CreateViewAsSkill{
	name = "jl_jiaoxin",
	view_as = function(self,cards)
		return jl_jiaoxinCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:getHp()==1
		and player:isWounded()
	end
}
jl_jiaoxinCard = sgs.CreateSkillCard{
	name = "jl_jiaoxin",
	target_fixed = true,
	on_use = function(self,room,source,targets)
		source:drawCards(1,"jl_jiaoxin")
		room:recover(source,sgs.RecoverStruct(source,self))
		return false
	end
}
jl_ceyu:addSkill(jl_jiaoxinVS)

jl_xusheng = sgs.General(extension,"jl_xusheng","wu")
jl_xusheng:addSkill("mobilepojun")
jl_xusheng:addSkill("lianhuan")
jl_xusheng:addSkill("jiuchi")
jl_xusheng:addSkill("lihuo")
jl_judao = sgs.CreateViewAsEquipSkill{
    name = "jl_judao",
	view_as_equip = function(self,target)
		if target:getWeapon()==nil
		then
	    	return "guding_blade"
		end
	end 
}
jl_xusheng:addSkill(jl_judao)

jl_shensunben = sgs.General(extension,"jl_shensunben","god",27,true,hidden)
jl_shensunben:addSkill("jiang")
jl_kuangang = sgs.CreateTriggerSkill{
	name = "jl_kuangang",
--	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damage},
	on_trigger = function(self,event,player,data)
		local damage = data:toDamage()
		for i = 1,damage.damage do
	    	if event==sgs.Damage
	    	and player:distanceTo(damage.to) <= 1
	    	then jl_jiangbf(player) end
		end
		return false
	end,
}
jl_shensunben:addSkill(jl_kuangang)
jl_yingang = sgs.CreateTriggerSkill{
	name = "jl_yingang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DrawNCards},
	on_trigger = function(self,event,player,data)
		jl_jiangbf(player)
	end
}
jl_shensunben:addSkill(jl_yingang)
jl_wangang = sgs.CreateTriggerSkill{
	name = "jl_wangang" ,
	events = {sgs.Damage,sgs.Damaged} ,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local target = nil
		if event==sgs.Damage
		then
			target = damage.to
		else
			target = damage.from
		end
		if not target
		or target:objectName()==player:objectName()
		then return end
		for i = 1,damage.damage do
			if target:isDead()
			or player:isDead()
			then return end
			jl_jiangbf(player)
			jl_jiangbf(target)
		end
	end
}
jl_shensunben:addSkill(jl_wangang)
jl_kuangCard = sgs.CreateSkillCard{
	name = "jl_kuang",
	target_fixed = true,
	on_use = function(self,room,source,targets)
		room:loseHp(source,1,false,source,"jl_kuang")
		if source:isAlive()
		then
			jl_jiangbf(source)
		end
	end
}
jl_kuang = sgs.CreateZeroCardViewAsSkill{
	name = "jl_kuang",
	view_as = function()
		return jl_kuangCard:clone()
	end
}
jl_shensunben:addSkill(jl_kuang)
jl_fanang = sgs.CreateMasochismSkill{
	name = "jl_fanang",
	on_damaged = function(self,player,damage)
		local from = damage.from
		local room = player:getRoom()
		for i = 1,damage.damage do
			if from
			and from:getCardCount()>0
			then
				jl_jiangbf(player)
			end
		end
	end
}
jl_shensunben:addSkill(jl_fanang)
jl_keang = sgs.CreateTriggerSkill{
	name = "jl_keang" ,
	frequency = sgs.Skill_Frequent ,
	events = {sgs.PreCardUsed,sgs.CardResponded,sgs.EventPhaseChanging} , 
	on_trigger = function(self,event,player,data)
		if event==sgs.EventPhaseChanging
		then
			if player:hasFlag("jl_keang")
			then
				player:setFlags("-jl_keang")
				return
			end
			local change = data:toPhaseChange()
			if change.to==sgs.Player_Discard
			then jl_jiangbf(player) end
		else
			if player:getPhase()==sgs.Player_Play
			then
				local card
				if event==sgs.CardResponded
				then card = data:toCardResponse().m_card			 
				else card = data:toCardUse().card end
				if card:isKindOf("Slash")
				then
					player:setFlags("jl_keang")
				end
			end
		end
		return false
	end
}
jl_shensunben:addSkill(jl_keang)
jl_guiang = sgs.CreateMasochismSkill{
	name = "jl_guiang" ,
	on_damaged = function(self,player,damage)
		local room = player:getRoom()
		local data = sgs.QVariant()
		data:setValue(damage)
		for i = 1,damage.damage do
			for _,p in sgs.list(room:getOtherPlayers(player))do
		    	if p:isAlive()
				and p:getCardCount()>0
			    then
		       		jl_jiangbf(player)
				end
			end
		end
	end
}
jl_shensunben:addSkill(jl_guiang)
jl_guangCard = sgs.CreateSkillCard{
	name = "jl_guangCard",
	will_throw = false,
	filter = function(self,targets,to_select,player)
		local pattern = self:getUserString()
		if pattern=="normal_slash"
		then pattern = "slash" end
		return SCfilter(pattern,targets,to_select,nil,"jl_guang")
	end,	
	feasible = function(self,targets)
		local pattern = self:getUserString()
		if pattern=="normal_slash"
		then pattern = "slash" end
		return SCfeasible(pattern,targets,nil,"jl_guang")
	end,	
	on_validate = function(self,use)
		local yuji = use.from
		local room = yuji:getRoom()		
		local to_guhuo = self:getUserString()
		to_guhuo = room:askForChoice(yuji,"guhuo_slash",to_guhuo)
		local log = sgs.LogMessage()
		if use.to:isEmpty()
		then log.type = "#GuhuoNoTarget"
		else log.type = "#Guhuo" end
		log.from = yuji
		log.to = use.to
		log.arg = to_guhuo
		log.arg2 = "jl_guang"		
		room:sendLog(log)
		local questions = sgs.SPlayerList()
    	for _,p in sgs.list(room:getOtherPlayers(yuji))do
	    	local log = sgs.LogMessage()
	    	log.type = "#GuhuoQuery"
	    	log.from = p
	    	if p:askForSkillInvoke("guhuo_question",sgs.QVariant("question0:"..yuji:objectName()..":"..to_guhuo),false)
	    	then
	    		room:setEmotion(p,"question")
	     		log.arg = "question"
				questions:append(p)
	    	else
	    		room:setEmotion(p,"no-question")					
	        	log.arg = "no-question"
	    	end
	    	room:sendLog(log)
	    	room:getThread():delay(555)
    	end
    	for _,p in sgs.list(room:getOtherPlayers(yuji))do
	   		room:setEmotion(p,".")					
		end
    	local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		local to_can
		if to_guhuo=="slash"
		then to_can = string.find(card:objectName(),"slash")
		elseif string.find(to_guhuo,"slash")
		then to_can = card:objectName()==to_guhuo
		else to_can = card:match(to_guhuo) end
		if to_can
		then
	    	jl_jiangbf(yuji)
		else
        	for _,p in sgs.list(questions)do
	        	jl_jiangbf(p)
			end
		end
		local use_card = sgs.Sanguosha:cloneCard(to_guhuo)
		use_card:setSkillName("jl_guang")
		use_card:addSubcard(self)
		return use_card
	end,
	on_validate_in_response = function(self,yuji)
		local room = yuji:getRoom()		
		local to_guhuo = self:getUserString()
		to_guhuo = room:askForChoice(yuji,"guhuo_slash",to_guhuo)
		local log = sgs.LogMessage()
		log.type = "#GuhuoNoTarget"
		log.from = yuji
		log.arg = to_guhuo
		log.arg2 = "jl_guang"		
		room:sendLog(log)
		local questions = sgs.SPlayerList()
    	for _,p in sgs.list(room:getOtherPlayers(yuji))do
	    	local log = sgs.LogMessage()
	    	log.type = "#GuhuoQuery"
	    	log.from = p
	    	if p:askForSkillInvoke("guhuo_question",sgs.QVariant("question0:"..yuji:objectName()..":"..to_guhuo),false)
	    	then
	    		room:setEmotion(p,"question")
	     		log.arg = "question"
				questions:append(p)
	    	else
	    		room:setEmotion(p,"no-question")					
	        	log.arg = "no-question"
	    	end
	    	room:sendLog(log)
	    	room:getThread():delay(555)
    	end
    	for _,p in sgs.list(room:getOtherPlayers(yuji))do
	   		room:setEmotion(p,".")					
		end
    	local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		local to_can
		if to_guhuo=="slash"
		then to_can = string.find(card:objectName(),"slash")
		elseif string.find(to_guhuo,"slash")
		then to_can = card:objectName()==to_guhuo
		else to_can = card:match(to_guhuo) end
		if to_can
		then
	    	jl_jiangbf(yuji)
		else
        	for _,p in sgs.list(questions)do
	        	jl_jiangbf(p)
			end
		end
		local use_card = sgs.Sanguosha:cloneCard(to_guhuo)
		use_card:setSkillName("jl_guang")
		use_card:addSubcard(self)
		return use_card
	end
}
jl_guang = sgs.CreateViewAsSkill {
	name = "jl_guang",	
	n = 1,	
	view_filter = function(self,selected,to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self,cards)
		if #cards>0
		then
			local card = jl_guangCard:clone()
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if pattern==""
			then
		    	pattern = sgs.Self:getTag("jl_guang"):toCard():objectName()
			end
			card:setUserString(pattern)
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_response = function(self,player,pattern)
		if player:isKongcheng()
		or string.sub(pattern,1,1)=="."
		or string.sub(pattern,1,1)=="@"
		or pattern=="peach"
		and player:getMark("Global_PreventPeach")>0
		then return end
		return true
	end,	
	enabled_at_play = function(self,player)				
		return not player:isKongcheng()
	end,	
	enabled_at_nullification = function(self,player)				
		return not player:isKongcheng() 
	end
}
jl_guang:setGuhuoDialog("lr")
jl_shensunben:addSkill(jl_guang)
jl_qiangangCard = sgs.CreateSkillCard{
	name = "jl_qiangang",
	target_fixed = true,
	on_use = function(self,room,source,targets)
		if self:getSubcards():isEmpty()
		then 
			room:loseHp(source,1,false,source,"jl_qiangang")
		end
		jl_jiangbf(source)
	end
}
jl_qiangang = sgs.CreateViewAsSkill{
	name = "jl_qiangang",
	n = 1,
	enabled_at_play = function(self,player)
		return not player:hasUsed("#jl_qiangang")
	end,
	view_filter = function(self,selected,to_select)
		return to_select:isKindOf("Weapon")
		and not sgs.Self:isJilei(to_select)
	end,
	view_as = function(self,cards) 
		if #cards==0
		then
			return jl_qiangangCard:clone()
		elseif #cards==1
		then
			local card = jl_qiangangCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end
}
jl_shensunben:addSkill(jl_qiangang)
jl_zhiangCard = sgs.CreateSkillCard{
	name = "jl_zhiangPindian",
	target_fixed = false,
	will_throw = false,
	filter = function(self,targets,to_select,source)
		return #targets<1
		and to_select:hasLordSkill("jl_zhiang")
	end,
	on_use = function(self,room,source,targets)
		local target = targets[1]
		jl_jiangbf(target)
	end
}
jl_zhiangPindian = sgs.CreateViewAsSkill{
	name = "jl_zhiangPindian&",
	view_as = function(self,cards)
		return jl_zhiangCard:clone()
	end,
	enabled_at_play = function(self,player)
		if player:usedTimes("#jl_zhiangPindian")<1
		then return player:getKingdom()=="wu" end
	end
}
jl_zhiang = sgs.CreateTriggerSkill{
	name = "jl_zhiang$",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TurnStart,sgs.EventPhaseChanging,sgs.EventAcquireSkill,sgs.EventLoseSkill},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if player:hasLordSkill(self)
		then
			for _,p in sgs.list(room:getOtherPlayers(player))do
				if p:hasSkill("jl_zhiangPindian")
				and p:getKingdom()~="wu"
				then
					room:detachSkillFromPlayer(p,"jl_zhiangPindian",true)
				end
			end
			for _,p in sgs.list(room:getOtherPlayers(player))do
				if p:hasSkill("jl_zhiangPindian")
				or p:getKingdom()~="wu"
				then continue end
				room:attachSkillToPlayer(p,"jl_zhiangPindian")
			end
		elseif player:isLord()
		then
			for _,p in sgs.list(room:getOtherPlayers(player))do
				if p:hasSkill("jl_zhiangPindian")
				then
					room:detachSkillFromPlayer(p,"jl_zhiangPindian",true)
				end
			end
		end
		return false
	end,
}
jl_shensunben:addSkill(jl_zhiang)
addToSkills(jl_zhiangPindian)

--[[
jl_huasuo = sgs.General(extension,"jl_huasuo","god")
jl_huasuo:setGender(sgs.General_Neuter)
jl_jueqing = sgs.CreateTriggerSkill{
	name = "jl_jueqing",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Predamage},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		room:broadcastSkillInvoke("jueqing",math.random(1,2))--播放配音
        room:sendCompulsoryTriggerLog(player,"jl_jueqing")
		DamageRevises(data,1,player)
        room:sendCompulsoryTriggerLog(player,"jl_jueqing")
		local damage = data:toDamage()
		room:loseHp(damage.to,damage.damage,false,player,"jl_jueqing")
		return true
	end,
}
jl_huasuo:addSkill(jl_jueqing)
jl_xiefang = sgs.CreateTriggerSkill{
	name = "jl_xiefang" ,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecifying,sgs.CardsMoveOneTime,sgs.EventPhaseChanging} , 
	on_trigger = function(self,event,player,data,room)
		if event==sgs.TargetSpecifying
	   	then
	    	local use,can = data:toCardUse(),false
			if use.card:isKindOf("SkillCard")
		    then return end
       	   	local list = use.no_respond_list
	    	for _,to in sgs.list(room:getAlivePlayers())do
               	if to:isFemale()
				then
		    		table.insert(list,to:objectName())
					can = true
				end
		    end
           	if can
			then
	           	room:sendCompulsoryTriggerLog(player,self:objectName())
           		room:broadcastSkillInvoke("xiefang",math.random(1,2))
			end
	   	    use.no_respond_list = list
			data:setValue(use)
		end
		for _,p in sgs.list(room:getOtherPlayers(player))do
			if player:distanceTo(p)~=1
			and p:isFemale()
			then
		    	room:setFixedDistance(player,p,1)
				p:addMark("jl_xiefang")
			end
			if p:getMark("jl_xiefang")>0
			and not p:isFemale()
			then
		    	room:setFixedDistance(player,p,-1)
				p:setMark("jl_xiefang",0)
			end
		end
		return false
	end
}
jl_huasuo:addSkill(jl_xiefang)
--]]
--[[
jl_heyan = sgs.General(extension,"jl_heyan","wei",3,false)
jl_qingtancard = sgs.CreateSkillCard{
	name = "jl_qingtancard",
	target_fixed = true,
	about_to_use = function(self,room,use)
		for _,p in sgs.list(room:getOtherPlayers(use.from))do
			if p:isKongcheng() then continue end
			use.to:append(p)
		end
		self:cardOnUse(room,use)
	end,
	on_use = function(self,room,source,targets)
       	room:broadcastSkillInvoke("qingtan")--播放配音
		for _,to in sgs.list(targets)do
			local c = room:askForExchange(to,"jl_qingtan",1,1,false,"jl_qingtan0:")
			self:addSubcard(c)
		end
		for _,id in sgs.list(self:getSubcards())do
	    	room:showCard(room:getCardOwner(id),id)
		end
		for _,id in sgs.list(self:getSubcards())do
        	room:obtainCard(source,id)
		end
	end
}
jl_qingtanVS = sgs.CreateViewAsSkill{
	name = "jl_qingtan",
	view_as = function(self,cards)
		return jl_qingtancard:clone()
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_qingtan")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#jl_qingtancard")<1
	end
}
jl_heyan:addSkill(jl_qingtanVS)
jl_yachai = sgs.CreateMasochismSkill{
	name = "jl_yachai",
	on_damaged = function(self,player,damage)
		local from = damage.from
		local room = player:getRoom()
		local da = sgs.QVariant()
		da:setValue(from)
		if from
		and from~=player
		and player:askForSkillInvoke(self:objectName(),da)
		then
         	room:broadcastSkillInvoke("yachai")--播放配音
	    	da = (from:getHandcardNum()+1)/2
			room:askForDiscard(from,"jl_yachai",da,da)
     		room:obtainCard(player,from:wholeHandCards(),false)
		end
	end
}
jl_heyan:addSkill(jl_yachai)
--]]
jl_erciyuan = sgs.General(extension,"jl_erciyuan","qun")
--jl_erciyuan:setImage("yuantanyuanshang")
jl_neifa1Card = sgs.CreateSkillCard{
	name = "jl_neifa1Card",
	target_fixed = true,
	will_throw = false,
	about_to_use = function(self,room,use)
		
	end,
}
jl_neifa2Card = sgs.CreateSkillCard{
	name = "jl_neifaCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self,targets,to_select,source)
		return #targets<source:getMark("jl_neifa2")
	end,
	on_use = function(self,room,source,targets)
		for _,to in sgs.list(targets)do
			if source:getMark("jl_neifa20")<1
			then room:askForDiscard(to,"jl_neifa",1,1,false,true)
			else to:drawCards(1,"jl_neifa") end
		end
	end
}
jl_neifaCard = sgs.CreateSkillCard{
	name = "jl_neifa",
	target_fixed = true,
	on_use = function(self,room,source,targets)
		room:broadcastSkillInvoke("neifa")--播放配音
		source:drawCards(2,"jl_neifa")
		local c = "."
		if source:getMark("jl_neifa3-PlayClear")>0
		then
			c = ".|black"
			source:removeMark("jl_neifa3-PlayClear")
		elseif source:getMark("jl_neifa9-PlayClear")>0
		then
			c = ".|red"
			source:removeMark("jl_neifa9-PlayClear")
		end
		c = room:askForExchange(source,"jl_neifa",1,1,true,"jl_neifa0:",false,c)
		if c:subcardsLength()<1
		then return end
		local toc
		for _,tc in sgs.list(source:getCards("he"))do
	    	if tc:getColor()~=c:getColor()
			then
		    	toc = c:getColorString()
				toc = room:askForExchange(source,"jl_neifa",1,1,true,"jl_neifa01:"..toc,false,".|^"..toc)
				break
			end
		end
		local jl_neifa_z = source:getMark("&jl_neifa")>0
		if source:getMark("jl_neifa3-PlayClear")>0
		or room:askForChoice(source,"jl_neifa","drawPileTop+drawPileEnd")~="drawPileEnd"
		then
			if jl_neifa_z
			then
				local to_c = room:askForExchange(source,"jl_neifa",1,1,true,"jl_neifa02:",true)
				if to_c
				then
		    		if to_c:getColor()==c:getColor()
					then
						c:addSubcards(to_c:getSubcards())
					elseif to_c:getColor()==toc:getColor()
					then
						toc:addSubcards(to_c:getSubcards())
					end
				end
			end
    		room:moveCardsInToDrawpile(source,c:getSubcards(),"jl_neifa",1)
			if toc
			then
		    	room:moveCardsToEndOfDrawpile(source,toc:getSubcards(),"jl_neifa")
			end
		else
			if jl_neifa_z
			then
				local to_c = room:askForExchange(source,"jl_neifa",1,1,true,"jl_neifa02:",true)
				if to_c
				then
		    		if to_c:getColor()==c:getColor()
					then
						c:addSubcards(to_c:getSubcards())
					elseif to_c:getColor()==toc:getColor()
					then
						toc:addSubcards(to_c:getSubcards())
					end
				end
			end
    		room:moveCardsToEndOfDrawpile(source,c:getSubcards(),"jl_neifa")
			if toc
			then
		    	room:moveCardsInToDrawpile(source,toc:getSubcards(),"jl_neifa",1)
			end
		end
		c = room:getNCards(1,false)
		room:returnToTopDrawPile(c)
		c = sgs.Sanguosha:getCard(c:at(0))
		local compare_func = function(a,b)
	    	return a>b
		end
		JlNeifaZ = function(num)
	    	local n = source:getMark("&jl_fa")
			
		end
		jl_neifa_yin = function(source)
			c = sgs.IntList()
			for _,id in sgs.list(room:getDrawPile())do
	           	id = sgs.Sanguosha:getCard(id)
				if c:contains(id:getTypeId())
				or not id:isBlack()
				then continue end
				c:append(id:getTypeId())
				self:addSubcard(id)
				room:obtainCard(source,id)
	        end
			c = room:askForUseCard(source,"@@jl_neifa1!","jl_neifa1:")
			toc = 0
			local ns = {}
			for _,id in sgs.list(c:getSubcards())do
		     	room:showCard(source,id)
	           	id = sgs.Sanguosha:getCard(id)
				toc = toc+id:getNumber()
				table.insert(ns,id:getNumber())
			end
			table.sort(ns,compare_func)
			if (ns[1]-ns[2])>(ns[2]-ns[3])
			and ns[2]-ns[3]>0
			then ns = ns[2]-ns[3]
			else ns = ns[1]-ns[2] end
		   	room:setPlayerMark(source,"jl_neifa2",ns)
			source:setMark("jl_neifa20",0)
			if math.mod(toc,2)~=1
			then
		    	source:setMark("jl_neifa20",1)
			end
			room:askForUseCard(source,"@@jl_neifa2","jl_neifa2:"..ns..":"..toc)
			c = 1
			while ns*c <= toc do
				if ns*c==toc
				then
			    	source:gainMark("&jl_fa",ns)
					room:addPlayerHistory(source,"#jl_neifa",0)
					source:addMark("jl_neifa3-PlayClear")
				end
				c = c+1
			end
		end
		if c:isRed()
		then jl_neifa_yin(source)
		elseif c:isBlack()
		then
           	local ps,can = room:getOtherPlayers(source),true
	    	room:sortByActionOrder(ps)
			local tos = sgs.SPlayerList()
			for _,p in sgs.list(ps)do
				if p:isKongcheng()
				then continue end
	            toc = room:askForCardChosen(source,p,"h","jl_neifa")
				room:showCard(p,toc)
	           	toc = sgs.Sanguosha:getCard(toc)
				if toc:isBlack()
				then
		    		can = false
					room:obtainCard(source,toc)
					break
				else
    				self:addSubcard(toc)
					tos:append(p)
				end
			end
			if can
			then
				can = self:getSubcards()
				for _,id in sgs.list(can)do
			    	room:obtainCard(source,id)
				end
				for _,p in sgs.list(tos)do
			    	ps = math.random(0,can:length()-1)
					c = can:at(ps)
					room:obtainCard(p,c)
					can:removeOne(c)
				end
			end
			if tos:length()>0
			and tos:length()==source:getMark("&jl_fa")
			and source:askForSkillInvoke(self:objectName(),sgs.QVariant("jl_neifa4:"..tos:length()),false)
			then
				self:clearSubcards()
				self:addSubcards(room:getNCards(tos:length()))
				room:throwCard(self,source)
				self:clearSubcards()
				for _,p in sgs.list(tos)do
			    	room:damage(sgs.DamageStruct(self,source,p))
				end
				c = self
				ps = nil
				for _,p in sgs.list(tos)do
			    	if p:canPindian(source)
					then
				    	if p:pindian(source,"jl_neifa")
						then
			    			ps = p
						else
			    			ps = source
						end
						if ps:askForSkillInvoke("jl_neifa",sgs.QVariant("jl_neifa5:"..tos:length()),false)
						then
							ps:drawCards(tos:length(),"jl_neifa")
							c = room:askForDiscard(ps,"jl_neifa",tos:length(),tos:length(),false,true)
							break
			   			end
					end
				end
	     		can = {}
		    	for _,id1 in sgs.list(c:getSubcards())do
					id1 = sgs.Sanguosha:getCard(id1)
					can = id1
		        	for _,id2 in sgs.list(c:getSubcards())do
				    	id2 = sgs.Sanguosha:getCard(id2)
						if id2~=id1
						then
					    	if id2:getColor()==id1:getColor()
					    	then can = false break end
						end
					end
					if can then break end
				end
		    	local a,b = nil,nil
		    	if can
				and ps
				then
	             	local to = room:askForPlayerChosen(ps,room:getAlivePlayers(),"jl_neifa","jl_neifa6:",true)
		           	if to
		           	then
	           	    	toc = sgs.IntList()
						can = sgs.Sanguosha:getCard(can)
						b = can
						for _,tc in sgs.list(to:getHandcards())do
			           		if tc:getColor()~=can:getColor()
							then toc:append(tc:getEffectiveId()) end
						end
				   		can = room:doGongxin(ps,to,toc,"jl_neifa")
						if can~=-1
						then
    						room:obtainCard(ps,can)
							a = sgs.Sanguosha:getCard(can)
						end
					end
				end
				if a
				and b
				then
			    	if a:getNumber()>b:getNumber()
					then
				    	room:moveCardsInToDrawpile(ps,a:getSubcards(),"jl_neifa",1)
						jl_neifa_yin(ps)
					end
					if room:askForChoice(source,"jl_neifa","a_to_z+cancel")~="cancel"
					then a:setNumber(a:getNumber()+source:getMark("&jl_fa")) end
					can = {}
					table.insert(can,b:getNumber()-a:getNumber())
					table.insert(can,b:getNumber()+a:getNumber())
					table.insert(can,b:getNumber()*a:getNumber())
					table.sort(can,compare_func)
					local max,min = can[1],can[3]
					local y = "y＝max×x^2＋min×x＋a^2"
					local x = "y＝"..max.."×x^2＋"..min.."×x＋"..a:getNumber().."^2"
					room:askForChoice(source,"jl_neifa",y.."+"..x)
					y = (min^2)-4*max*(a:getNumber()^2)
					local log = sgs.LogMessage()
					log.type = "$jl_neifa7"
					log.arg = x
					log.arg2 = "no_jl_neifa7"
					if y<1
					then
						room:sendLog(log)
						return
					end
					log.arg1 = "yes_jl_neifa7"
					room:sendLog(log)
					x = a:getNumber()-b:getNumber()
	             	local to = room:askForPlayerChosen(source,room:getAlivePlayers(),"jl_neifa","jl_neifa8:"..x,true)
		           	if to
		           	then
		     			can = 0
						for i=1,x do
					    	if to:isNude()
							then break end
			        		i = room:askForCardChosen(source,to,"he","jl_neifa")
				        	room:throwCard(i,to,source)
							can = can+1
						end
						b:setNumber(b:getNumber()+can)
					end
					if a:getNumber()==b:getNumber()
					then
				    	source:addMark("&jl_neifa")
					end
				end
			end
			can = false
			c = 1
			toc = source:getMark("&jl_fa")
			while 3*c <= toc do
				if 3*c==toc
				and toc>8
				then
			    	can = true
				end
				c = c+1
			end
			if can
			then
				source:drawCards(21,"jl_neifa")
				c = source:getHandcardNum()-21
				if c>0
				then
		    		c = room:askForDiscard(source,"jl_neifa",c,c)
				end
				room:showAllCards(source)
				c = jl_DouDiZhu(source)
				if source:isKongcheng()
				then
		    		room:addPlayerHistory(source,"#jl_neifa",0)
					source:addMark("jl_neifa9-PlayClear")
				elseif c
				then
		    		room:setPlayerFlag(source,"Global_PlayPhaseTerminated")
					c:setFlags("jl_neifa")
					c:gainAnExtraTurn()
					c:setFlags("-jl_neifa")
				end
			end
		end
		if jl_neifa_z
		then
			source:removeMark("&jl_neifa")
		end
--		jl_DouDiZhu(source)
		return false
	end
}
jl_neifaVS = sgs.CreateViewAsSkill{
	name = "jl_neifa",
	n = 998,	
	view_filter = function(self,selected,to_select)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern==""
		or pattern=="@@jl_neifa!"
		then return end
		if pattern=="@@jl_neifa1!"
		then
	    	if to_select:isBlack()
			and #selected<3
			then
        	   	for _,c in sgs.list(selected)do
			    	if to_select:getType()==c:getType()
					then return end
				end
				return true
			end
		end
	end,
	view_as = function(self,cards)
		local nc = jl_neifaCard:clone()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern=="@@jl_neifa1!"
		then
	    	if #cards<3
			then return end
			nc = jl_neifa1Card:clone()
		end
		if pattern=="@@jl_neifa2"
		then
	    	nc = jl_neifa2Card:clone()
		end
	   	for _,c in sgs.list(cards)do
	    	nc:addSubcard(c)
	   	end
		return nc
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_neifa")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#jl_neifa")<1
	end
}
jl_neifa = sgs.CreateTriggerSkill{
	name = "jl_neifa",
	events = {sgs.EventPhaseStart},
	view_as_skill = jl_neifaVS,
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
        if event==sgs.EventPhaseStart
		then
			if player:getPhase()==sgs.Player_Play
			and player:hasFlag("jl_neifa")
			then
				player:hasFlag("-jl_neifa")
	        	local skc = jl_neifaCard:clone()
				Skill_msg(self,owner)
		    	skc:onUse(room,sgs.CardUseStruct(skc,player,sgs.SPlayerList()))
			end
		end
		end
		return false
	end,
}
jl_erciyuan:addSkill(jl_neifa)
ddz_num = 0
jl_DouDiZhuCard = sgs.CreateSkillCard{
	name = "jl_DouDiZhu",
	target_fixed = true,
	will_throw = false,
	about_to_use = function(self,room,use)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RESPONSE,use.from:objectName(),"","jl_DouDiZhu","")
		room:moveCardTo(self,use.from,sgs.Player_PlaceTable,reason,true)
		for _,c in sgs.list(self:getSubcards())do
			c = sgs.Sanguosha:getCard(c)
			use.from:broadcastSkillInvoke(c)
		end
		room:moveCardTo(self,use.from,nil,sgs.Player_DiscardPile,reason,true)
	end,
}
jl_DouDiZhuVS = sgs.CreateViewAsSkill{
	name = "jl_DouDiZhu&",
	n = 998,	
	view_filter = function(self,selected,to_select)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if to_select:getNumber()<3
		then
	    	to_select:setNumber(to_select:getNumber()+13)
		end
		if to_select:isEquipped()
		or ddz_num>0 and ddz_num <= to_select:getNumber()
		then return end
		if #selected<3
		then
	     	if #selected>1
			then
				if selected[1]:getNumber()==selected[2]:getNumber()
				then
		    		return selected[1]:getNumber()==to_select:getNumber()
				elseif selected[1]:getNumber()+1==selected[2]:getNumber()
				then
		    		return selected[#selected]:getNumber()+1==to_select:getNumber()
				end
				return false
			elseif #selected>0
			then
				if selected[1]:getNumber()==to_select:getNumber()-1
				or selected[1]:getNumber()==to_select:getNumber()
				then return true end
			end
		else
			if selected[1]:getNumber()+1==selected[2]:getNumber()
			then
		   		return selected[#selected]:getNumber()+1==to_select:getNumber()
			end
			if selected[1]:getNumber()==selected[2]:getNumber()
			and #selected>4
			and #selected<6
			then
		   		return selected[#selected]:getNumber()==to_select:getNumber()
	     	end
			return false
		end
		return true
	end,
	view_as = function(self,cards)
		if #cards<1
		then return end
		local nc = jl_DouDiZhuCard:clone()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if #cards>1
		and #cards<5
		and cards[1]:getNumber()+1==cards[2]:getNumber()
		then return end
	   	for _,c in sgs.list(cards)do
	    	nc:addSubcard(c)
	   	end
		return nc
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_DouDiZhu")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return false
	end
}
addToSkills(jl_DouDiZhuVS)
function jl_DouDiZhu(player)
	local room = player:getRoom()
	for _,p in sgs.list(room:getAlivePlayers())do
		room:acquireSkill(p,jl_DouDiZhuVS,false,true,false)
	end
	local to,can,to_can = player,nil,nil
	while to do
		local players = room:getOtherPlayers(to)
		if to:isKongcheng()
		then break end
		can = can or room:askForUseCard(to,"@@jl_DouDiZhu!","jl_DouDiZhu0:")
		if can
		then
			local to_c = true
			ddz_num = sgs.Sanguosha:getCard(can:getSubcards():at(0)):getNumber()
			for _,p in sgs.list(players)do
	    		can = room:askForUseCard(p,"@@jl_DouDiZhu","jl_DouDiZhu1:"..to:objectName())
				if can
				then
					to = p
					to_c = nil
					break
				elseif p==player
				then
					to_can = to
					break
				end
			end
			if to_c then ddz_num = 0 end
			if to_can then break end
		else break end
	end
	ddz_num = 0
	for _,p in sgs.list(room:getAlivePlayers())do
		room:detachSkillFromPlayer(p,"jl_DouDiZhu",true,true)
	end
	return to_can
end

jl_caocao = sgs.General(extension,"jl_caocao","wei",8)
jl_zhijun = sgs.CreateOneCardViewAsSkill{
	name = "jl_zhijun",
	response_or_use = true,
	view_filter = function(self,card)
		if card:getSuit()==0
		or card:getSuit()==1
		then
			local slash = sgs.Sanguosha:cloneCard("__jl_sha")
			slash:addSubcard(card)
			slash:deleteLater()
			return slash:isAvailable(sgs.Self)
		end
	end,
	view_as = function(self,card)
		local slash = sgs.Sanguosha:cloneCard("__jl_sha")
		slash:addSubcard(card)
		slash:setSkillName(self:objectName())
		return SetCloneCard(slash)
	end,
	enabled_at_play = function(self,player)
        return CardIsAvailable(player,"__jl_sha")
	end,
	enabled_at_response = function(self,player,pattern)
		return (string.find(pattern,"slash") or string.find(pattern,"jink"))
		and sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
	end
}
sha = sgs.CreateBasicCard{
	name = "__jl_sha",
	class_name = "JlSha",
	subtype = "buff_card",
--	target_fixed = true,
    can_recast = false,
--	damage_card = true,
	filter = function(self,targets,to_select,source)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
	   	if string.find(pattern,"jink")
		then return end
		return SCfilter("slash",targets,to_select,self,self:getSkillName())
	end,
	target_fixed = function()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
	   	return string.find(pattern,"jink")
	end,
	feasible = function(self,targets)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
	   	if string.find(pattern,"jink")
		then return true end
		return SCfeasible("slash",targets,self,self:getSkillName())
	end,
	about_to_use = function(self,room,use)
	   	local slash = sgs.Sanguosha:cloneCard("slash")
       	slash:setSkillName(self:getSkillName())
		slash:addSubcards(self:getSubcards())
		slash:setTag("drank",sgs.QVariant(use.from:getMark("drank")))
		room:setPlayerMark(use.from,"drank",0)
       	slash:setObjectName("__jl_sha")
		use.card = slash
		self:cardOnUse(room,use)
		room:addPlayerHistory(use.from,use.card:getClassName())
	end,
    available = function(self,player)
        return CardIsAvailable(player,"slash","__jl_sha",self:getSuit(),self:getNumber())
    end,
}
sha:clone(6,0):setParent(extension)
--閷
jl_caocao:addSkill(jl_zhijun)
jl_fushiCard = sgs.CreateSkillCard{
	name = "jl_fushiCard",
	target_fixed = true,
	on_use = function(self,room,source,targets)
		local choice = room:askForChoice(source,"jl_fushi","draw+up_hp")
		if choice=="up_hp"
		then room:recover(source,sgs.RecoverStruct(source,self))
		else source:drawCards(self:subcardsLength(),"jl_fushi") end
	end,
}
jl_fushiVS = sgs.CreateViewAsSkill{ 
	name = "jl_fushi",
	n = 998,
	view_filter = function(self,selected,to_select)
		if sgs.Self:isJilei(to_select)
		or to_select:isEquipped()
		then return end
		for _,card in sgs.list(selected)do
			if card:getSuit()==to_select:getSuit()
			then return end
		end
		return true
	end,
	view_as = function(self,cards) 
		if #cards>1
		then
			local card = jl_fushiCard:clone()
			for _,c in sgs.list(cards)do
				card:addSubcard(c)
			end
			return card
		end
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#jl_fushiCard")<1
	end
}
jl_caocao:addSkill(jl_fushiVS)
jl_jianxiong = sgs.CreateMasochismSkill{
	name = "jl_jianxiong",
	on_damaged = function(self,player,damage)
		local room = player:getRoom()
		local da = sgs.QVariant()
		da:setValue(damage)
		if (damage.from and player:canSlash(damage.from) or damage.card and damage.card:getSubcards():length()>0)
		and player:askForSkillInvoke(self:objectName(),da)
		then
	    	if player:getTag("jl_bianjie"):toBool()
			and player:askForSkillInvoke("jl_bianjie",sgs.QVariant("jl_bianjie0:1"))
			then player:drawCards(1,self:objectName()) end
			da = player:getTag("jl_jianshi"):toInt()
			local can = true
			if damage.from
			and player:canSlash(damage.from)
			then
	    		if da and da>1
				then
	        		if player:askForSkillInvoke("jl_jianshi",sgs.QVariant("jl_jianshi0:"..damage.from:objectName()))
					then
			    		can = false
				    	da = sgs.Sanguosha:cloneCard("slash")
				    	da:setSkillName("_jl_jianxiong")
				    	da:onUse(room,sgs.CardUseStruct(da,player,damage.from))
					end
				elseif room:askForUseSlashTo(player,damage.from,"jl_jianxiong_slash:"..damage.from:objectName())
				then can = false end
			end
			if can
			and damage.card
			and room:getCardPlace(damage.card:getSubcards():at(0))==sgs.Player_PlaceTable
			then
				player:obtainCard(damage.card)
				if da and da>0
				then player:drawCards(1,self:objectName()) end
			end
		end
	end
}
jl_caocao:addSkill(jl_jianxiong)
jl_nengchen = sgs.CreateTriggerSkill{
	name = "jl_nengchen",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DrawNCards},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
     	room:sendCompulsoryTriggerLog(player,self:objectName())
		data:setValue(player:getMaxHp())
	end
}
jl_caocao:addSkill(jl_nengchen)
jl_canzheng = sgs.CreateTriggerSkill{
	name = "jl_canzheng$",
	events = {sgs.Death},
	frequency = sgs.Skill_Frequent,
	on_trigger = function(self,event,player,data,room)
        if event==sgs.Death
		then
	     	local death = data:toDeath()
	        local damage = death.damage
			if damage
			and damage.from
			and damage.from:hasLordSkill(self)
			and damage.from:askForSkillInvoke(self:objectName(),data)
			then
				room:gainMaxHp(damage.from)
				room:recover(damage.from,sgs.RecoverStruct(damage.from))
			end
		end
		return false
	end,
}
jl_caocao:addSkill(jl_canzheng)
jl_daishou = sgs.CreateTriggerSkill{
	name = "jl_daishou",
	frequency = sgs.Skill_Limited,
	limit_mark = "@jl_daishou",
	events = {sgs.DamageInflicted},
	on_trigger = function(self,event,player,data,room)
    	if event==sgs.DamageInflicted
		and player:getMark("@jl_daishou")>0
		then
		    local damage = data:toDamage()
			local dc = room:askForDiscard(player,"jl_daishou",998,1,true,true,"jl_daishou0:",".","jl_daishou")
        	if dc
			then
				room:doSuperLightbox(player:getGeneralName(),self:objectName())
				room:removePlayerMark(player,"@jl_daishou")
		    	return DamageRevises(data,-dc:subcardsLength(),player)
			end
		end
		return false
	end
}
jl_caocao:addSkill(jl_daishou)
jl_bianjie = sgs.CreateTriggerSkill{
	name = "jl_bianjie",
	frequency = sgs.Skill_Wake,
	events = {sgs.DamageInflicted,sgs.DamageCaused,sgs.EventPhaseProceeding},
	on_trigger = function(self,event,player,data,room)
	    if event==sgs.DamageInflicted
		or event==sgs.DamageCaused
		then
	    	local damage = data:toDamage()
			room:addPlayerMark(player,"&jl_bianjie",damage.damage)
		elseif player:getPhase()==sgs.Player_Start
		and player:getMark(self:objectName())<1
		and (player:canWake(self:objectName()) or player:getMark("&jl_bianjie")>player:getMaxHp())
		then
			SkillWakeTrigger(self,player)
			player:setTag("jl_bianjie",sgs.QVariant(true))
		end
	end
}
jl_caocao:addSkill(jl_bianjie)
jl_qiangzhen = sgs.CreateTriggerSkill{
	name = "jl_qiangzhen",
--	frequency = sgs.Skill_Compulsory,
--	events = {sgs.DamageInflicted},
	on_trigger = function(self,event,player,data,room)
	end
}
jl_caocao:addSkill(jl_qiangzhen)
jl_yitian = sgs.CreateTriggerSkill{
	name = "jl_yitian",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DamageCaused},
	on_trigger = function(self,event,player,data,room)
	    if event==sgs.DamageCaused
		and player:getHp()<player:getMaxHp()/2
		and player:askForSkillInvoke(self:objectName(),data)
		then room:recover(player,sgs.RecoverStruct(player)) end
	end
}
jl_caocao:addSkill(jl_yitian)
jl_shewei = sgs.CreateTriggerSkill{
	name = "jl_shewei",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed,sgs.DrawNCards},
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
		local tos = sgs.SPlayerList()
		if event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:getTypeId()==0
			and use.card:objectName():match("qiangxi")
			then
				local x = player:getHandcardNum()-owner:getHandcardNum()
				if x>0
				then
					tos:append(owner)
				elseif x<0
				then
					tos:append(player)
				else
					tos:append(owner)
					tos:append(player)
				end
			end
		elseif player:hasFlag("nosluoyi")
		or player:getMark("&luoyi")>0
		then
			local x = player:getHandcardNum()-owner:getHandcardNum()
			if x>0
			then
				tos:append(owner)
			elseif x<0
			then
				tos:append(player)
			else
				tos:append(owner)
				tos:append(player)
			end
		end
		if tos:isEmpty()
		then return end
		tos = room:askForPlayerChosen(owner,tos,"jl_shewei","jl_shewei0:",true)
		if tos
		then
	    	tos:drawCards(1,self:objectName())
		end
		end
		return false
	end,
}
jl_caocao:addSkill(jl_shewei)
jl_jixu = sgs.CreateTriggerSkill{
	name = "jl_jixu" ,
--	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified} , 
	change_skill = true,
	on_trigger = function(self,event,player,data,room)
    	local n = player:getChangeSkillState("jl_jixu")
		if event==sgs.TargetSpecified
	   	then
	    	local use,can = data:toCardUse(),false
			if use.card:isKindOf("SkillCard")
		    then return end
       	   	local list = use.no_respond_list
	    	for _,to in sgs.list(use.to)do
				data:setValue(to)
              	if use.card:getTypeId()==n
				and to:getHandcardNum()<player:getHandcardNum()
				and player:askForSkillInvoke(self:objectName(),data)
				then
		    		table.insert(list,to:objectName())
					n = n<2 and 2 or 1
	            	room:setChangeSkillState(player,"jl_jixu",n)
				end
		    end
	   	    use.no_respond_list = list
			data:setValue(use)
		end
		return false
	end
}
jl_caocao:addSkill(jl_jixu)
jl_mengsha = sgs.CreateTriggerSkill{
	name = "jl_mengsha",
	events = {sgs.Appear},
	hide_skill = true,
	on_trigger = function(self,event,player,data,room)
   		local target = room:getCurrent()
       	if event==sgs.Appear
		and player:getPhase()==sgs.Player_NotActive
		and target:objectName()~=player:objectName()
	   	and room:askForSkillInvoke(player,self:objectName(),data)
		then
           	room:broadcastSkillInvoke("jl_mengsha")--播放配音
			room:loseMaxHp(target)
		end
	end
}
jl_caocao:addSkill(jl_mengsha)
jl_jianshi = sgs.CreateTriggerSkill{
	name = "jl_jianshi",
	events = {sgs.Death,sgs.QuitDying},
	frequency = sgs.Skill_Frequent,
    shiming_skill = true,
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
        if owner:getTag("jl_jianshi"):toInt()>0
		then continue end
		if event==sgs.Death
		then
	     	local death = data:toDeath()
	        local damage = death.damage
			if damage
			and damage.from:objectName()==owner:objectName()
			then
	    		ShimingSkillDoAnimate(self,owner,true)
				owner:setTag("jl_jianshi",sgs.QVariant(1))
			end
		else
	     	local dying = data:toDying()
	        local damage = dying.damage
			if damage
			and damage.from:objectName()==owner:objectName()
			then
	    		ShimingSkillDoAnimate(self,owner)
				owner:setTag("jl_jianshi",sgs.QVariant(2))
			end
		end
		end
		return false
	end,
}
jl_caocao:addSkill(jl_jianshi)

jl_lvxun = sgs.General(extension,"jl_lvxun","wu",3)
jl_lvxun:addSkill("nosqianxun")
jl_lvxun:addSkill("keji")

jl_yuji = sgs.General(extension,"jl_yuji","god",1)
jl_zhuzhou = sgs.CreateTriggerSkill{
	name = "jl_zhuzhou",
	events = {sgs.Death},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self,target)
		return target:hasSkill(self)
	end,
 	on_trigger = function(self,event,player,data,room)
 		if event==sgs.Death
		then
			local death = data:toDeath()
	        local damage = death.damage
			if damage and damage.from
			and death.who:objectName()==player:objectName()
			then
				room:sendCompulsoryTriggerLog(player,self:objectName())
				room:broadcastSkillInvoke("chanyuan")--播放配音
				room:doSuperLightbox(player:getGeneralName(),self:objectName())
				room:doAnimate(4,damage.from:objectName(),"sunce")
				room:getThread():delay(666)
				room:changeHero(damage.from,"sunce",false)
			end
		end
		return false
	end,
}
jl_yuji:addSkill(jl_zhuzhou)

require("lua.config")
local cfg = config
if kingdom_yao
then
	table.insert(cfg.kingdoms,"yao")
end
cfg.kingdom_colors["yao"] = "#ba7198"
jl_zhoutai = sgs.General(extension,"jl_zhoutai","yao")
jl_buhui = sgs.CreateProhibitSkill{
	name = "jl_buhui",
--	global = true,
	is_prohibited = function(self,from,to,card)
		if card:isKindOf("Slash")
		or card:isKindOf("Peach")
		then
	    	if to and to:hasSkill(self)
	    	then return true end
		end
	end
}
jl_zhoutai:addSkill(jl_buhui)

jl_wangtaoyue = sgs.General(extension,"jl_wangtaoyue","shu",3,false)
jl_huguan = sgs.CreateTriggerSkill{
	name = "jl_huguan",
--	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed,sgs.CardsMoveOneTime,sgs.EventPhaseChanging},
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
		if event==sgs.CardUsed
		then
			local use = data:toCardUse()
			if use.card:isKindOf("SkillCard")
			or player:getPhase()==sgs.Player_NotActive
			then return end
			if use.card:isRed()
			and player:getMark("jl_huguan0-Clear")<1
			then
				local c = room:askForCard(owner,".","jl_huguan0:"..player:objectName(),data,"jl_huguan")
				if c
				then
					room:addPlayerMark(player,"&jl_huguan+"..c:getSuitString().."-Clear")
					room:broadcastSkillInvoke("huguan")--播放配音
					player:addMark("jl_huguan-Clear")
				end
			end
			player:addMark("jl_huguan0-Clear")
		elseif event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_Discard
			then
				for _,c in sgs.list(player:getCards("h"))do
			   		if player:getMark("&jl_huguan+"..c:getSuitString().."-Clear")>0
					then room:ignoreCards(player,c) end
				end
			elseif change.from==sgs.Player_Discard
			and player:getMark("jl_huguan-Clear")>0
			and player:getMark("nojl_huguan-Clear")<1
			then
				Skill_msg(self,player)
				room:broadcastSkillInvoke("huguan")--播放配音
				owner:drawCards(1,self:objectName())
			end
		elseif event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			if move.from
			and player:getPhase()==sgs.Player_Discard
			and move.to_place==sgs.Player_DiscardPile
			and move.from:objectName()==player:objectName()
			then player:addMark("nojl_huguan-Clear") end
		end
		end
		return false
	end,
}
jl_wangtaoyue:addSkill(jl_huguan)
jl_luanpei = sgs.CreateTriggerSkill{
	name = "jl_luanpei",
--	frequency = sgs.Skill_NotFrequent,
	events = {sgs.HpRecover,sgs.CardsMoveOneTime,sgs.EventPhaseChanging},
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
		if event==sgs.HpRecover
		then
			local target = room:getCurrent()
			target:addMark("jl_luanpei-Clear")
		elseif event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			and owner:objectName()~=player:objectName()
			and player:getMark("jl_luanpei-Clear")>0
			then
				local c = player:getTag("jl_luanpei"):toString()
				c = c~="" and c or "."
				c = room:askForCard(owner,".|"..c,"jl_luanpei0:"..player:objectName(),data,"jl_luanpei")
				if c
				then
					room:broadcastSkillInvoke("mingluan")--播放配音
					c = sgs.SPlayerList()
					c:append(player)
					c:append(owner)
					c = PlayerChosen(self,owner,c,"jl_luanpei1:")
					room:recover(c,sgs.RecoverStruct(owner))
					c = owner:getHandcardNum()-player:getHandcardNum()
					room:broadcastSkillInvoke("yaopei")--播放配音
					c = math.min(5,c)
					if c>0
					then
						if player:getHandcardNum()<5
						and c>player:getHandcardNum()
						then
			    			c = c-player:getHandcardNum()
							player:drawCards(c,self:objectName())
						end
					elseif c<0
					then
						c = player:getHandcardNum()-owner:getHandcardNum()
						c = math.min(5,c)
						if owner:getHandcardNum()<5
						and c>owner:getHandcardNum()
						then
			    			c = c-owner:getHandcardNum()
			    			owner:drawCards(c,self:objectName())
						end
					end
				end
				player:setTag("jl_luanpei",sgs.QVariant("."))
			end
		elseif event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			if move.from
			and player:getPhase()==sgs.Player_Discard
			and move.to_place==sgs.Player_DiscardPile
			and move.from:objectName()==player:objectName()
			then
				local suits = {}
				for _,id in sgs.list(move.card_ids)do
					id = sgs.Sanguosha:getCard(id)
					table.insert(suits,"^"..id:getSuitString())
				end
				player:setTag("jl_luanpei",sgs.QVariant(table.concat(suits,",")))
			end
		end
		end
		return false
	end,
}
jl_wangtaoyue:addSkill(jl_luanpei)

jl_zhanshen = sgs.General(extension,"jl_zhanshen","god",12,true,hidden)
jl_zhanshen:setStartHp(8)
jl_poying_s = nil
jl_poyingCard = sgs.CreateSkillCard{
	name = "jl_poyingCard",
--	target_fixed = true,
	will_throw = false,
	skill_name = "_jl_poying",
	filter = function(self,targets,to_select,source)
		return source:canSlash(to_select,jl_poying_s)
		and to_select:getMark("no_s")<1
		and #targets<2
	end,
	on_use = function(self,room,source,targets)
		room:broadcastSkillInvoke("shenji")--播放配音
	end,
}
jl_poyingVS = sgs.CreateViewAsSkill{
	name = "jl_poying",
	view_as = function(self,cards)
		local nc = jl_poyingCard:clone()
		return nc
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_poying")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return false
	end
}
jl_poying = sgs.CreateTriggerSkill{
	name = "jl_poying" ,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecifying,sgs.CardUsed,sgs.EventPhaseChanging,sgs.ConfirmDamage,sgs.DamageCaused,sgs.EnterDying} , 
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	view_as_skill = jl_poyingVS,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.TargetSpecifying
	   	then
	    	local use = data:toCardUse()
			if use.card:isKindOf("SkillCard")
			or not use.card:isKindOf("Slash")
			or not player:hasSkill(self)
		    then return end
			player:addMark("jl_poying-Clear")
			SkillInvoke(self,player,true)
			jl_poying_s = use.card
	    	for _,to in sgs.list(use.to)do
				room:addPlayerMark(to,"no_s")
			end
			local u = room:askForUseCardStruct(player,"@@jl_poying","jl_poying0:")
	    	for _,to in sgs.list(use.to)do
				room:removePlayerMark(to,"no_s")
			end
			if u
			then
				for _,to in sgs.list(u.to)do
					use.to:append(to)
				end
			end
			room:broadcastSkillInvoke("tieji")--播放配音
	    	for _,to in sgs.list(use.to)do
               	for _,s in sgs.list(to:getVisibleSkillList())do
		    		if not s:isAttachedLordSkill()
		    	    then
				    	room:addPlayerMark(to,"jl_poying"..s:objectName())
				    	room:addPlayerMark(to,"Qingcheng"..s:objectName())
					end
				end
		    end
			room:broadcastSkillInvoke("mobilepojun")--播放配音
	    	for _,to in sgs.list(use.to)do
               	local cs = sgs.Sanguosha:cloneCard("slash")
				cs:addSubcards(to:getHandcards())
				cs:addSubcards(to:getEquips())
				to:addToPile("jl_poying",cs,false)
		    end
       	   	local list = use.no_respond_list
			room:broadcastSkillInvoke("liegong")--播放配音
	    	for _,to in sgs.list(use.to)do
               	if to:getHandcardNum()<player:getHandcardNum()
				then
		    		table.insert(list,to:objectName())
				end
		    end
	   	    use.no_respond_list = list
			use.card:setFlags("jl_poying")
			data:setValue(use)
			room:addSlashCishu(player,1)
		elseif event==sgs.EnterDying
		then
	    	local dying = data:toDying()
			local target = room:getCurrent()
			if target:hasSkill(self)
			and target:getMark("jl_poying-Clear")>0
			then
				Skill_msg(self,target)
		    	room:broadcastSkillInvoke("wansha")--播放配音
	    		room:killPlayer(dying.who,dying.damage)
			end
		elseif event==sgs.DamageCaused
		then
	    	local damage = data:toDamage()
			if damage.card
			and damage.card:hasFlag("jl_poying")
			then
				Skill_msg(self,player)
				room:broadcastSkillInvoke("fenyin")--播放配音
		    	player:drawCards(5,self:objectName())
			end
		elseif event==sgs.ConfirmDamage
		then
	    	local damage = data:toDamage()
			if damage.card
			and damage.card:hasFlag("jl_poying")
			and player:getMark("jl_poying-Clear")>0
			then
		    	local usetoc = player:getTag("jl_poying"):toString():split("+")
				Skill_msg(self,player)
				room:broadcastSkillInvoke("mobileliegong")--播放配音
				DamageRevises(data,#usetoc,player)
			end
		elseif event==sgs.CardUsed
		then
	    	local use = data:toCardUse()
			local usetoc = player:getTag("jl_poying"):toString():split("+")
			if use.card:isKindOf("SkillCard")
			or not player:hasSkill(self)
		    then return end
			if not table.contains(usetoc,use.card:getSuitString())
			then table.insert(usetoc,use.card:getSuitString()) end
			if not table.contains(usetoc,use.card:getType())
			then table.insert(usetoc,use.card:getType()) end
			room:setPlayerMark(player,"&jl_poying",#usetoc)
			player:setTag("jl_poying",sgs.QVariant(table.concat(usetoc,"+")))
		elseif event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
               	for _,s in sgs.list(player:getVisibleSkillList())do
		    		local sk = "jl_poying"..s:objectName()
					if player:getMark(sk)>0
		    	    then
				    	room:removePlayerMark(player,"Qingcheng"..s:objectName(),sk)
				    	room:setPlayerMark(player,sk,0)
					end
				end
               	for _,p in sgs.list(room:getAlivePlayers())do
			    	local ids = p:getPile("jl_poying")
					if ids:length()>0
					and player:hasSkill(self)
			    	then
						local cs = sgs.Sanguosha:cloneCard("slash")
						cs:addSubcards(ids)
						player:obtainCard(cs,false)
			    	end
				end
			end
		end
		return false
	end
}
jl_zhanshen:addSkill(jl_poying)
jl_shenjiCard = sgs.CreateSkillCard{
	name = "jl_shenjiCard",
--	target_fixed = true,
--	will_throw = false,
	skill_name = "_jl_shenji",
	filter = function(self,targets,to_select,source)
		return to_select:objectName()~=source:objectName()
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
		for _,to in sgs.list(targets)do
			for i=1,self:subcardsLength()do
		    	if to:isNude()
				then break end
	            i = room:askForCardChosen(source,to,"he","jl_shenji")
				room:throwCard(i,to,source)
			end
			room:damage(sgs.DamageStruct(self,source,to,2))
		end
	end,
}
jl_shenjiVS = sgs.CreateViewAsSkill{
	name = "jl_shenji",
	n = 998,	
	view_filter = function(self,selected,to_select)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		return sgs.Self:canDiscard(sgs.Self,to_select:getEffectiveId())
	end,
	view_as = function(self,cards)
		local nc = jl_shenjiCard:clone()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
	   	if #cards<1 then return end
	   	for _,c in sgs.list(cards)do
	    	nc:addSubcard(c)
	   	end
		return nc
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_shenji")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return false
	end
}
jl_shenji = sgs.CreateTriggerSkill{
	name = "jl_shenji" ,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TurnOver,sgs.TurnStart,sgs.CardUsed,sgs.DrawNCards,sgs.EventPhaseStart} , 
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	view_as_skill = jl_shenjiVS,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.TurnOver
	   	then
			if player:hasSkill(self)
			and player:faceUp()
		    then
				SkillInvoke(self,player,true)
--				room:setPlayerProperty(player,"faceup",sgs.QVariant(true))
				return true
			end
		elseif event==sgs.TurnStart
		then
	    	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
	    		if player:objectName()~=owner:objectName()
				then
		    		SkillInvoke(self,owner,true)
					owner:gainAnExtraTurn()
				end
			end
		elseif event==sgs.EventPhaseStart
		then
	    	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
	    		if player:objectName()~=owner:objectName()
				and player:getPhase()==sgs.Player_NotActive
				then
		    		SkillInvoke(self,owner,true)
					owner:gainAnExtraTurn()
				end
			end
			if player:hasSkill(self)
			and player:getPhase()==sgs.Player_Discard
			then
		    	if room:askForUseCard(player,"@@jl_shenji","jl_shenji0:")
				then else player:addMark("jl_shenji-Clear") end
			end
		elseif event==sgs.DrawNCards
		then
			if player:hasSkill(self)
		    then
		   		SkillInvoke(self,player,true)
        		data:setValue(data:toInt()+4)
			end
		elseif event==sgs.CardUsed
		then
	    	local use,can = data:toCardUse(),nil
			if use.card:isKindOf("SkillCard")
			or not player:hasSkill(self)
		    then return end
       	   	local list = use.no_respond_list
	    	for _,to in sgs.list(use.to)do
               	if player:getMark("jl_shenji-PlayClear")<1
				then
					can = to
					table.insert(list,to:objectName())
				end
		    end
			if can
			then
		   		SkillInvoke(self,player,true)
			end
	   	    use.no_respond_list = list
			player:addMark("jl_shenji-PlayClear")
			data:setValue(use)
		end
		return false
	end
}
jl_zhanshen:addSkill(jl_shenji)
jl_longjiangVS = sgs.CreateViewAsSkill{ 
	name = "jl_longjiang",
	n = 1,
	view_filter = function(self,selected,to_select)
		if sgs.Self:isJilei(to_select)
		then return end
		return to_select:isKindOf("BasicCard")
	end,
	view_as = function(self,cards) 
		if #cards>0
		then
	    	local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if pattern==""
			then
				pattern = sgs.Self:getTag("jl_longjiang"):toCard():objectName()
			end
			local card = sgs.Sanguosha:cloneCard(pattern:split("+")[1])
			for _,c in sgs.list(cards)do
				card:addSubcard(c)
			end
			return card
		end
	end,
	enabled_at_response = function(self,player,pattern)
		pattern = sgs.Sanguosha:cloneCard(pattern:split("+")[1])
		if pattern and pattern:isKindOf("BasicCard")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return not player:isKongcheng()
	end
}
jl_longjiang = sgs.CreateTriggerSkill{
	name = "jl_longjiang" ,
	events = {sgs.EventPhaseProceeding} , 
	view_as_skill = jl_longjiangVS,
	guhuo_type = "l",
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Start
		then
			local dc = room:askForDiscard(player,"jl_longjiang",998,1,true,true,"jl_longjiang0:",".","jl_longjiang")
			if dc
			then
				for _,c in sgs.list(player:getJudgingArea())do
		    		for _,id in sgs.list(dc:getSubcards())do
						id = sgs.Sanguosha:getCard(id)
						if c:getColor()==id:getColor()
						then
							room:throwCard(id,to,player)
						end
					end
				end
			end
		end
		return false
	end
}
jl_zhanshen:addSkill(jl_longjiang)

jl_shenchong = sgs.General(extension,"jl_shenchong","god",9,true,hidden)
jl_shenchong:setStartHp(6)
jl_jiejun = sgs.CreateTriggerSkill{
	name = "jl_jiejun" ,
--	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecifying,sgs.CardFinished,sgs.EventPhaseChanging}, 
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.TargetSpecifying
	   	then
	    	local use = data:toCardUse()
			if not use.card:isKindOf("Slash")
			or not player:hasSkill(self)
			or not player:askForSkillInvoke(self:objectName(),data)
		    then return end
			SkillInvoke("fenyin",player)
			player:drawCards(1,self:objectName())
			room:getThread():delay(555)
			SkillInvoke("zishu",player,nil,1)
			player:drawCards(1,self:objectName())
			room:getThread():delay(555)
			SkillInvoke("jl_kuangcai",player)
			player:drawCards(1,self:objectName())
			room:getThread():delay(555)
			SkillInvoke("zishu",player,nil,1)
			player:drawCards(1,self:objectName())
			room:getThread():delay(555)
			SkillInvoke("kangkai",player)
			player:drawCards(1,self:objectName())
			room:getThread():delay(555)
			SkillInvoke("zishu",player,nil,1)
			player:drawCards(1,self:objectName())
			room:getThread():delay(555)
	    	for _,to in sgs.list(use.to)do
               	if to:isKongcheng()
				then continue end
				local cs = sgs.Sanguosha:cloneCard("slash")
				cs:addSubcards(to:getHandcards())
				room:broadcastSkillInvoke("mobilepojun")--播放配音
				to:addToPile("jl_jiejun",cs,false)
		    end
	    	for _,to in sgs.list(use.to)do
	        	local ns = room:askForExchange(player,"jl_jiejun",1,1,true,"jl_jiejun:"..to:objectName())
				to:obtainCard(ns,false)
		    end
			use.card:setFlags("jl_jiejun")
--			SkillInvoke("jieyingg",player)
			use.m_addHistory = false
			room:addPlayerHistory(player,use.card:getClassName(),-1)
			data:setValue(use)
		elseif event==sgs.CardFinished
	   	then
	    	local use = data:toCardUse()
			if player:hasSkill(self)
			and use.card:hasFlag("jl_jiejun")
			and room:getCardPlace(use.card:getSubcards():at(0))==sgs.Player_DiscardPile
			then
		       	local target = PlayerChosen(self,player,room:getOtherPlayers(player),"jl_jiejun0:")
				SkillInvoke("yingyuan",player)
				target:obtainCard(use.card)
			end
		elseif event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
               	for _,p in sgs.list(room:getAlivePlayers())do
			    	local ids = p:getPile("jl_jiejun")
					if ids:length()>0
					and player:hasSkill(self)
			    	then
						local cs = sgs.Sanguosha:cloneCard("slash")
						cs:addSubcards(ids)
						Skill_msg(self,player)
						SkillInvoke("jieyingg",player)
						player:obtainCard(cs,false)
			    	end
				end
			end
		end
		return false
	end
}
jl_shenchong:addSkill(jl_jiejun)
jl_chousiCard = sgs.CreateSkillCard{
	name = "jl_chousi",
	target_fixed = true,
	on_use = function(self,room,source,targets)
		source:drawCards(5,"jl_chousi")
		room:getThread():delay()
		room:damage(sgs.DamageStruct(self,source,source))
		room:broadcastSkillInvoke("chouce")--播放配音
		local judge = sgs.JudgeStruct()
		judge.pattern = ".|red,black"
		judge.good = true
		judge.reason = "jl_chousi"
		judge.who = source
		judge.play_animation = true
		room:judge(judge)
		if judge:isGood()
		then
			judge = source:getTag("JudgeCard_jl_chousi"):toCard()
	      	local target = PlayerChosen("jl_chousi",source,room:getOtherPlayers(source),"jl_chousi0:")
			if judge:isRed()
			then target:drawCards(2,"jl_chousi")
			elseif target:getCardCount()>0
			then
				local id = room:askForCardChosen(source,target,"he","jl_chousi")
				if id~=-1 then room:throwCard(id,target,source) end
			end
		end
		return false
	end
}
jl_chousi = sgs.CreateViewAsSkill{
	name = "jl_chousi",
	view_as = function(self,cards)
		return jl_chousiCard:clone()
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_chousi")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#jl_chousi")<1
	end
}
jl_shenchong:addSkill(jl_chousi)

jl_shenci = sgs.General(extension,"jl_shenci","god",12,true,hidden)
jl_shenci:setStartHp(6)
jl_jice = sgs.CreateTriggerSkill{
	name = "jl_jice" ,
--	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecifying,sgs.CardFinished,sgs.ConfirmDamage}, 
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.TargetSpecifying
	   	then
	    	local use = data:toCardUse()
			if (use.card:isKindOf("Slash") and use.card:isRed() or use.card:isKindOf("Duel"))
			and player:hasSkill(self)
			and player:askForSkillInvoke(self:objectName(),data)
		    then
				for _,to in sgs.list(use.to)do
					SkillInvoke("jiang",player)
					player:drawCards(1,self:objectName())
					room:getThread():delay(555)
					SkillInvoke("cuike",player)
					room:damage(sgs.DamageStruct(self:objectName(),player,to))
					room:getThread():delay(555)
					SkillInvoke("chouce",player)
					local judge = sgs.JudgeStruct()
					judge.pattern = ".|red,black"
					judge.good = true
					judge.reason = self:objectName()
					judge.who = player
					judge.play_animation = true
					room:judge(judge)
					if judge:isGood()
					then
						judge = player:getTag("JudgeCard_"..self:objectName()):toCard()
						if judge:isRed()
						then player:drawCards(2,self:objectName())
						elseif judge:isBlack()
						and not to:isAllNude()
						then
							local id = room:askForCardChosen(player,to,"hej",self:objectName())
							if id~=-1 then room:throwCard(id,to,player) end
						end
					end
					room:getThread():delay(555)
					SkillInvoke("poxi",player)
					local card_ids = to:handCards()
					local dummy = sgs.Sanguosha:cloneCard("slash")
					local cards = sgs.IntList()
					for _,id in sgs.list(card_ids)do
						cards:append(id)
					end
					room:fillAG(card_ids,player)
					while cards:length()>0 do
						local cid = room:askForAG(player,cards,cards:isEmpty(),self:objectName())
						if cid==-1 then break end
						room:takeAG(player,cid,false)
						cid = sgs.Sanguosha:getCard(cid)
						dummy:addSubcard(cid)
						for _,id in sgs.list(card_ids)do
							local c = sgs.Sanguosha:getCard(id)
							if c:getSuit()==cid:getSuit()
							then
								if c~=cid
								then
									room:takeAG(nil,id,false)
								end
								cards:removeOne(id)
							end
						end
					end
					room:clearAG(player)
					room:throwCard(dummy,to,player)
					room:getThread():delay(555)
					if player:getCardCount()>to:getCardCount()
					then to:setFlags("jl_jice"..use.card:toString()) end
				end
--				data:setValue(use)
			end
		elseif event==sgs.ConfirmDamage
		then
	    	local damage = data:toDamage()
			if damage.card
			and damage.to:hasFlag("jl_jice"..damage.card:toString())
			then
				Skill_msg(self,player)
				room:broadcastSkillInvoke("mobilepojun")--播放配音
				damage.to:setFlags("-jl_jice"..damage.card:toString())
				DamageRevises(data,1,player)
			end
		end
		return false
	end
}
jl_shenci:addSkill(jl_jice)
jl_xiongyiCard = sgs.CreateSkillCard{
	name = "jl_xiongyi",
--	target_fixed = true,
--	will_throw = false,
--	skill_name = "jl_xiongyi",
	filter = function(self,targets,to_select,source)
		return #targets<1
	end,
	on_use = function(self,room,source,targets)
		for _,to in sgs.list(targets)do
			SkillInvoke("paiyi",source)
			to:drawCards(2,self:objectName())
			room:getThread():delay(555)
			SkillInvoke("xionghuo",source)
			room:damage(sgs.DamageStruct(self,source,to,2))
		end
	end,
}
jl_xiongyiVS = sgs.CreateViewAsSkill{
	name = "jl_xiongyi",
	view_as = function(self,cards)
		return jl_xiongyiCard:clone()
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_xiongyi")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#jl_xiongyi")<1
	end
}
jl_xiongyi = sgs.CreateTriggerSkill{
	name = "jl_xiongyi",
	events = {sgs.Death},
	view_as_skill = jl_xiongyiVS,
	can_trigger = function(self,target)
		return true
	end,
 	on_trigger = function(self,event,player,data,room)
 		if event==sgs.Death
		then
			local death = data:toDeath()
	        local damage = death.damage
			if damage
			and damage.from
			and damage.card
			and player:hasSkill(self)
			and damage.card:objectName()==self:objectName()
			and damage.from:objectName()==player:objectName()
			then
				SkillInvoke("zhengnan",player)
				damage = room:askForChoice(player,"jl_xiongyi","dangxian+zhiman")
				room:acquireSkill(player,damage)
			end
		end
		return false
	end,
}
jl_shenci:addSkill(jl_xiongyi)
jl_kuangsheCard = sgs.CreateSkillCard{
	name = "jl_kuangsheCard",
	target_fixed = true,
--	will_throw = false,
--	skill_name = "_jl_kuangshe",
	about_to_use = function(self,room,use)
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:setSkillName("jl_kuangshe")
		slash:addSubcards(self:getSubcards())
		for _,p in sgs.list(room:getOtherPlayers(use.from))do
			if use.from:isProhibited(p,slash) then continue end
			use.to:append(p)
		end
		use.card = slash
		self:cardOnUse(room,use)
		room:addPlayerHistory(use.from,use.card:getClassName())
		slash = use.card:getSubcards()
		if room:getCardPlace(slash:at(0))==sgs.Player_DiscardPile
		then room:moveCardsInToDrawpile(use.from,slash,"jl_kuangshe",1) end
	end,
}
jl_kuangsheVS = sgs.CreateViewAsSkill{
	name = "jl_kuangshe",
	n = 1,	
	view_filter = function(self,selected,to_select)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		return not sgs.Self:isJilei(to_select)
	end,
	view_as = function(self,cards)
		local nc = jl_kuangsheCard:clone()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
	   	if #cards<1 then return end
	   	for _,c in sgs.list(cards)do
	    	nc:addSubcard(c)
	   	end
		return nc
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_kuangshe")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return sgs.Slash_IsAvailable(player)
	end
}
jl_kuangshe = sgs.CreateTriggerSkill{
	name = "jl_kuangshe" ,
--	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed} , 
	view_as_skill = jl_kuangsheVS,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardUsed
		then
	    	local use = data:toCardUse()
			if use.card:getSkillName()~=self:objectName()
			or use.to:isEmpty() then return end
			SkillInvoke("tushe",player)
			player:drawCards(use.to:length(),self:objectName())
			room:getThread():delay(555)
			SkillInvoke("guixin",player)
	    	for _,to in sgs.list(use.to)do
				room:doAnimate(1,player:objectName(),to:objectName())
			end
	    	for _,to in sgs.list(use.to)do
               	if to:isAllNude() then continue end
				room:obtainCard(player,room:askForCardChosen(player,to,"hej",self:objectName()),false)
		    end
			data:setValue(use)
		end
		return false
	end
}
jl_shenci:addSkill(jl_kuangshe)

jl_xyy = sgs.General(extension,"jl_xyy","qun",6)
jl_xyy:setStartHp(4)
jl_yangxi = sgs.CreateTriggerSkill{
	name = "jl_yangxi",
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self,event,player,data,room)
        if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Start
		then
			local to = room:getAlivePlayers()
			to = room:askForPlayerChosen(player,to,self:objectName(),"jl_yangxi0:",true,true)
			if to
			then
				local n = math.random(-2,2)
				if n>0
				then
					room:broadcastSkillInvoke("langxi")
					room:damage(sgs.DamageStruct(self:objectName(),player,to,n))
				elseif n==0 or n<1 and not to:isWounded()
				then room:broadcastSkillInvoke("jl_yangxi",1)
				else
					room:broadcastSkillInvoke("jl_yangxi",math.random(2,3))
					if n>-2 then n = 1
					else n = 2 end
					room:recover(to,sgs.RecoverStruct(player,nil,n))
				end
			end
		end
		return false
	end,
}
jl_xyy:addSkill(jl_yangxi)
jl_yisuanCard = sgs.CreateSkillCard{
	name = "jl_yisuan",
	target_fixed = true,
--	will_throw = false,
--	skill_name = "jl_xiongyi",
	on_use = function(self,room,source,targets)
		room:broadcastSkillInvoke("yisuan",1)
		room:addPlayerMark(source,"jl_yisuan")
		source:setTag("jl_yisuan",sgs.QVariant(source:getGeneralName()))
		local hp,maxhp = source:getHp(),source:getMaxHp()
		room:changeHero(source,"wuyi",false)
		room:setPlayerProperty(source,"maxhp",sgs.QVariant(maxhp))
		room:setPlayerProperty(source,"hp",sgs.QVariant(hp))
	end,
}
jl_yisuanVS = sgs.CreateViewAsSkill{
	name = "jl_yisuan",
	view_as = function(self,cards)
		return jl_yisuanCard:clone()
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_yisuan")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#jl_yisuan")
	end
}
jl_yisuan = sgs.CreateTriggerSkill{
	name = "jl_yisuan",
	events = {sgs.EventPhaseChanging},
	view_as_skill = jl_yisuanVS,
	can_trigger = function(self,target)
		return target and target:getMark("jl_yisuan")>0
	end,
	on_trigger = function(self,event,player,data,room)
        local xyy = player:getTag("jl_yisuan"):toString()
		if xyy~=""
		then
			Skill_msg(self,player)
			room:removePlayerMark(player,"jl_yisuan")
			room:changeHero(player,xyy,false)
		end
		return false
	end,
}
jl_xyy:addSkill(jl_yisuan)

jl_liuxu = sgs.General(extension,"jl_liuxu","god",5)
jl_liuxu:setStartHp(3)
jl_boji = sgs.CreateTriggerSkill{
	name = "jl_boji" ,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardFinished,sgs.Damage,sgs.HpRecover,sgs.CardsMoveOneTime,sgs.BeforeCardsMove,sgs.EventPhaseChanging}, 
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
		if event==sgs.CardFinished
		then
	    	local use = data:toCardUse()
			if use.card:getTypeId()~=2
		    then return end
			player:addMark("jl_boji3")
			if player:getMark("jl_boji3")>2
			and player:getMark("&jl_boji3")<1
			then
                room:sendCompulsoryTriggerLog(owner,"jl_boji")
				room:doAnimate(1,owner:objectName(),player:objectName())
				room:setPlayerMark(player,"&jl_boji3",1)
			end
		elseif event==sgs.Damage
		then
		    local damage = data:toDamage()
			if damage.to:isLord()
			and player:getMark("&jl_boji1")<1
			then
                room:sendCompulsoryTriggerLog(owner,"jl_boji")
				room:doAnimate(1,owner:objectName(),player:objectName())
				room:setPlayerMark(player,"&jl_boji1",1)
			end
		elseif event==sgs.HpRecover
	   	then
	       	local rec = data:toRecover()
			if rec.who
			and rec.who:getMark("&jl_boji2")<1
			and rec.who:objectName()~=player:objectName()
			then
                room:sendCompulsoryTriggerLog(owner,"jl_boji")
				room:doAnimate(1,owner:objectName(),rec.who:objectName())
				room:setPlayerMark(rec.who,"&jl_boji2",1)
			end
		elseif event==sgs.BeforeCardsMove
		and player:getMark("&jl_boji2")>0
		then
	     	local move = data:toMoveOneTime()
			if not player:hasFlag("jl_boji2")
			and move.to_place==sgs.Player_PlaceHand
			and move.to:objectName()==player:objectName()
			and move.from_places:contains(sgs.Player_DrawPile)
			then
                room:sendCompulsoryTriggerLog(owner,"jl_boji")
				room:doAnimate(1,owner:objectName(),player:objectName())
				local slash = dummyCard()
				slash:addSubcard(move.card_ids)
				local dp = sgs.QList2Table(room:getDrawPile())
				if dp[1]==move.card_ids:at(0)
				then slash:addSubcard(dp[move.card_ids:length()+1])
				elseif dp[#dp]==move.card_ids:at(0)
				then slash:addSubcard(dp[#dp-move.card_ids:length()])
				else slash:addSubcard(dp[1]) end
				move.card_ids = sgs.IntList()
				data:setValue(move)
				player:setFlags("jl_boji2")
				room:moveCardTo(slash,player,sgs.Player_PlaceHand,move.reason)
				player:setFlags("-jl_boji2")
			end
		elseif event==sgs.EventPhaseChanging
		and player:getMark("&jl_boji3")>0
		then
			local change = data:toPhaseChange()
			if change.to==sgs.Player_Discard
			then
				for i,c in sgs.list(player:getHandcards())do
					if c:hasFlag("jl_boji3")
					then
						room:ignoreCards(player,c)
					end
				end
			end
		elseif event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			if player:getMark("&jl_boji3")>0
			and move.to_place==sgs.Player_PlaceHand
			and move.to:objectName()==player:objectName()
			then
				for i,id in sgs.list(move.card_ids)do
					room:setCardFlag(id,"jl_boji3")
				end
			end
	    	if player:getMark("&jl_boji1")<1
			or player:hasFlag("jl_boji1")
			then return end
			for _,p in sgs.list(room:getOtherPlayers(player))do
				if p:getHandcardNum()>player:getHandcardNum()
				or player:getHandcardNum()<5
				then return end
			end
            room:sendCompulsoryTriggerLog(owner,"jl_boji")
			player:setFlags("jl_boji1")
			room:loseMaxHp(owner)
			move = sgs.Sanguosha:cloneCard("slash")
			move:setSkillName("_jl_boji")
			room:useCard(sgs.CardUseStruct(move,owner,player))
			room:setPlayerMark(player,"&jl_boji1",0)
			player:setFlags("-jl_boji1")
		end
		end
		return false
	end
}
jl_liuxu:addSkill(jl_boji)
jl_jiuxue = sgs.CreateTriggerSkill{
	name = "jl_jiuxue" ,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardFinished},
	view_as_skill = jl_kuangsheVS,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardFinished
		then
	    	local use = data:toCardUse()
			if use.card:getTypeId()==0
		    then return end
			player:addMark("jl_jiuxue-Clear")
			local x,y = player:getMark("jl_jiuxue-Clear"),player:getCardCount(true,true)
			if y==2*x+x+1
			or y==2*x+x-1
			or y==2*x-x-1
			or y==-(2*x+x+1)
			or y==-(2*x+x-1)
			or y==-(2*x-x+1)
			then
				local xs,ys = {},{}
				local jc = function(n)
					local z = 1
					for i=1,n do
						z = z*i
					end
					return z
				end
				table.insert(xs,jc(x)*2+2)
				table.insert(xs,jc(x)*2-2)
				table.insert(xs,-jc(x)*2+2)
				table.insert(xs,-jc(x)*2-2)
				for i,n in sgs.list(xs)do
					n = 2*n+n+1
					if n>=0
					then
						table.insert(ys,n)
					end
					n = 2*n+n-1
					if n>=0
					then
						table.insert(ys,n)
					end
					n = 2*n-n-1
					if n>=0
					then
						table.insert(ys,n)
					end
					n = -(2*n+n+1)
					if n>=0
					then
						table.insert(ys,n)
					end
					n = -(2*n+n-1)
					if n>=0
					then
						table.insert(ys,n)
					end
					n = -(2*n-n-1)
					if n>=0
					then
						table.insert(ys,n)
					end
				end
				if #ys<1
				then return end
				room:sendCompulsoryTriggerLog(player,"jl_jiuxue")
				y = room:askForChoice(player,self:objectName(),table.concat(ys,"+"))
				y = y-player:getHandcardNum()>0 and y-player:getHandcardNum() or player:getHandcardNum()-y
				PlayerHandcardNum(player,"jl_jiuxue",y)
				room:addPlayerMark(player,"&jl_jiuxuevs")
				if player:getMark("&jl_jiuxuevs")>2
				then
					room:detachSkillFromPlayer(player,"jl_jiuxue",true)
					room:acquireSkill(player,"jl_jiuxuevs",true,true,false)
					room:setPlayerMark(player,"&jl_jiuxuevs",0)
				end
			end
		end
		return false
	end
}
jl_liuxu:addSkill(jl_jiuxue)
jl_shiyi = sgs.CreateTriggerSkill{
	name = "jl_shiyi" ,
--	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardFinished,sgs.GameStart,sgs.TurnStart}, 
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data,room)
	   	for _,owner in sgs.list(room:findPlayersBySkillName(self:objectName()))do
		if event==sgs.CardFinished
		then
	    	local use = data:toCardUse()
			if use.card:getTypeId()==0
		    then return end
			if player:getMark("&jl_shiyi")>0
			then
				Skill_msg(self,owner)
				if room:askForUseCard(owner,use.card:getClassName(),"jl_shiyi1:"..use.card:objectName())
				then owner:addMark("jl_shiyi1") end
				local x = player:getMark("jl_shiyi1")
				for i=1,x do
					if 3*i==x
					then
						if owner:askForSkillInvoke(self:objectName(),ToData(player))
						then
							room:doAnimate(1,owner:objectName(),player:objectName())
							room:damage(sgs.DamageStruct(self:objectName(),owner,player))
						end
						break
					end
				end
				if owner:inMyAttackRange(player)
				then return end
				room:insertAttackRangePair(owner,player)
			end
		elseif event==sgs.GameStart
		and player:objectName()==owner:objectName()
		then
			local to = room:askForPlayerChosen(player,room:getAlivePlayers(),"jl_shiyi","jl_shiyi0:",true,true)
			if to
			then
				room:setPlayerMark(to,"&jl_shiyi",1)
				room:insertAttackRangePair(player,to)
				to:addMark("jl_shiyi")
			end
		elseif event==sgs.TurnStart
		and player:getMark("jl_shiyi")>0
		then
			Skill_msg(self,player)
			player:removeMark("jl_shiyi")
			return true
		end
		end
		return false
	end
}
jl_liuxu:addSkill(jl_shiyi)
jl_jiuxuevs = sgs.CreateTriggerSkill{
	name = "jl_jiuxuevs" ,
	events = {sgs.EventPhaseStart} ,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.EventPhaseStart
		and player:getPhase()==sgs.Player_Play
		then
	    	if player:askForSkillInvoke(self:objectName(),sgs.QVariant("jl_jiuxuevs0:"))
	    	then
				local ms = {}
				table.insert(ms,1.5)
				while #ms<10 do
					local n = math.random()
					n = n+math.random(0,2)
					n = string.sub(n,1,3)
					if not table.contains(ms,n)
					then table.insert(ms,n) end
				end
				ms = RandomList(ms)
				local m = room:askForChoice(player,self:objectName(),table.concat(ms,"+"))
				local msg = sgs.LogMessage()
				msg.type = "#jl_jiuxuevs1"
				msg.arg = self:objectName()
				msg.arg2 = "jl_jiuxuevs2"
				msg.from = player
				if m=="1.5"
				then
					room:sendLog(msg)
					player:drawCards(2,self:objectName())
				else
					msg.arg2 = "jl_jiuxuevs3"
					room:sendLog(msg)
				end
	    	end
		end
		return false
	end
}
--jl_liuxu:addSkill(jl_jiuxuevs)
addToSkills(jl_jiuxuevs)

jl_sunce1 = sgs.General(extension,"jl_sunce1$","wu")
jl_sunce1:addSkill("benghuai")
jl_sunce1:addSkill("chouhai")
jl_sunce1:addSkill("ranshang")
jl_sunce1:addSkill("shiyong")
jl_sunce1:addSkill("lianhuo")
jl_sunce1:addSkill("yaowu")
jl_sunce1:addSkill("tongji")
jl_sunce1:addSkill("kurou")
jl_sunce1:addSkill("jushou")
jl_sunce1:addSkill("fuli")
jl_sunben0 = sgs.CreateTriggerSkill{
	name = "jl_sunben",
	events = {sgs.MaxHpChanged},
	frequency = sgs.Skill_Wake,
	on_trigger = function(self,event,player,data,room)
        if event==sgs.MaxHpChanged
		and player:getMaxHp()==1
		and player:getMark(self:objectName())<1
		then
			SkillWakeTrigger(self,player)
			room:acquireSkill(player,"hunzi")
		end
		return false
	end,
}
jl_sunce1:addSkill(jl_sunben0)

jl_bashen = sgs.General(extension,"jl_bashen","god")
jl_bashen:setGender(sgs.General_Neuter)
jl_bashen:addSkill("nosrende")
jl_bashen:addSkill("zhiheng")
jl_bashen:addSkill("lijian")
jl_bashen:addSkill("anxu")
jl_bashen:addSkill("qiaobian")
jl_bashen:addSkill("guanxing")
jl_bashen:addSkill("kongcheng")
jl_bashen:addSkill("tianming")
jl_bashen:addSkill("mizhao")
jl_bashen:addSkill("nostuxi")

jl_wuxing = sgs.General(extension,"jl_wuxing","god")
jl_wuxing:setGender(sgs.General_Neuter)
jl_wuxing:addSkill("duwu")
jl_wuxing:addSkill("nosjizhi")
jl_wuxing:addSkill("tenyearliegong")
jl_wuxing:addSkill("tenyearzhiheng")
jl_wuxing:addSkill("huashen")
jl_wuxing:addSkill("xinsheng")
jl_wuxing:addSkill("shanjia")
jl_wuxing:addSkill("wuyan")
jl_wuxing:addSkill("jujian")

jl_siju = sgs.General(extension,"jl_siju","god")
jl_siju:addSkill("juanxia")
jl_siju:addSkill("dingcuo")
jl_siju:addSkill("zhouxuanz")
jl_siju:addSkill("chenglve")
jl_siju:addSkill("yinshicai")
jl_siju:addSkill("cunmu")
jl_siju:addSkill("olsanyao")
jl_siju:addSkill("olzhiman")

function jl_zhendian1(player)
	local room = player:getRoom()
	local names = sgs.ZhinangClassName
	local c = room:askForCard(player,table.concat(names,","),"jl_zhendian4:",ToData(),sgs.Card_MethodNone)
	if c then BreakCard(player,c) player:drawCards(2,"jl_zhendian")
	else
		c = SearchCard(player,names)
		if c:length()>0
		then
			c = CardListToIntlist(c)
			room:fillAG(c,player)
			c = room:askForAG(player,c,false,"jl_zhendian")
	       	room:clearAG(player)
			room:obtainCard(player,c)
			player:drawCards(2,"jl_zhendian")
		end
	end
end
function jl_zhendian2(player)
	local room = player:getRoom()
	local choices = {}
	for i = 0,4 do
		table.insert(choices,"@Equip"..i.."lose")
	end
	if #choices>0
	then
		choices = room:askForChoice(player,"jl_zhendian",table.concat(choices,"+"))
		choices = string.sub(choices,7,7)
		local choice = player:getEquip(choices)
		if player:hasEquipArea(choices)
		then player:throwEquipArea(choices)
		else player:obtainEquipArea(choices) end
		if choice
		then
			addRenPile(choice,player)
			room:recover(player,sgs.RecoverStruct(player))
		end
	end
end

jl_chenshou = sgs.General(extension,"jl_chenshou","shu+jin",3)
jl_zhendian = sgs.CreateTriggerSkill{
	name = "jl_zhendian",
	events = {sgs.EventPhaseStart,sgs.MarkChange},
--	frequency = sgs.Skill_Frequent,
    shiming_skill = true,
	on_trigger = function(self,event,player,data,room)
		if player:getTag("jl_zhendian"):toBool() then return end
		local function JlZhendianShiming()
			local cards = {}
			local bc = room:getTag("BreakCard"):toString():split("+")
			for p,id in sgs.list(bc)do
				table.insert(cards,id)
			end
			local RenPile = room:getTag("RenPile"):toString():split("+")
			for _,id in sgs.list(RenPile)do
				table.insert(cards,id)
			end
			for _,p in sgs.list(room:getAlivePlayers())do
				for _,key in sgs.list(p:getPileNames())do
					if p:pileOpen(key,player:objectName())
					then
						for _,id in sgs.list(p:getPile(key))do
							table.insert(cards,id)
						end
					end
				end
			end
			bc = dummyCard()
			local ts,es = {},{}
			for c,id in sgs.list(cards)do
				c = sgs.Sanguosha:getCard(id)
				if table.contains(sgs.ZhinangClassName,c:getClassName())
				then
					bc:addSubcard(id)
					if table.contains(ts,c:objectName()) then continue end
					table.insert(ts,c:objectName())
				elseif c:isKindOf("EquipCard")
				then
					bc:addSubcard(id)
					local index = c:getRealCard():toEquipCard():location()
					if table.contains(es,index) then continue end
					table.insert(es,index)
				end
			end
			if #ts>2 or #es>2
			then
				ShimingSkillDoAnimate(self,player,true)
				ts = dummyCard()
				for c,id in sgs.list(bc:getSubcards())do
					local p = room:getCardOwner(id)
					if p
					then
						c = p:getTag("jl_zhendianIds"):toIntList()
						c:append(id)
						p:setTag("jl_zhendianIds",ToData(c))
					else ts:addSubcard(id) end
				end
				room:obtainCard(player,ts)
				for i,p in sgs.list(room:getAlivePlayers())do
					i = p:getTag("jl_zhendianIds"):toIntList()
					if i:isEmpty() then continue end
					ts:clearSubcards()
					ts:addSubcards(i)
					room:obtainCard(player,ts)
					p:removeTag("jl_zhendianIds")
				end
				room:detachSkillFromPlayer(player,"jl_zhendian",true)
				room:acquireSkill(player,"jl_zhendianvs",true,true,false)
			end
		end
		if event==sgs.MarkChange
		then
		   	local mark = data:toMark()
       	   	if string.find(mark.name,"&zhengsu")
			and player:getTag("zhengsu"):toInt()==player:getMark("jl_zhendian_zhengsu-Clear")
			and mark.gain<1 and not player:hasFlag("zhengsu_successful")
			then
				ShimingSkillDoAnimate(self,player)
				player:setTag("jl_zhendian",sgs.QVariant(true))
			end
		else
			if player:getPhase()==sgs.Player_Play
			and player:askForSkillInvoke(self:objectName())
			then
	    		local choice = room:askForChoice(player,"jl_zhendian","jl_zhendian1+jl_zhendian2+beishui_choice=jl_zhendian3")
				Log_message("$jl_zhendian0",player,nil,nil,"jl_zhendian",choice)
				if choice=="jl_zhendian1"
				then jl_zhendian1(player)
				elseif choice=="jl_zhendian2"
				then jl_zhendian2(player)
				else
					choice = ZhengsuChoice(player)
					player:setMark("jl_zhendian_zhengsu-Clear",choice)
					jl_zhendian1(player)
					jl_zhendian2(player)
				end
				JlZhendianShiming()
			end
		end
		return false
	end,
}
jl_chenshou:addSkill(jl_zhendian)
jl_zhendianvs = sgs.CreateTriggerSkill{
	name = "jl_zhendianvs",
	events = {sgs.EventPhaseStart},
--	frequency = sgs.Skill_Frequent,
	change_skill = true,
	on_trigger = function(self,event,player,data,room)
    	local n = player:getChangeSkillState("jl_zhendianvs")
		if event==sgs.EventPhaseStart
		then
			if player:getPhase()==sgs.Player_Play
			and player:askForSkillInvoke(self:objectName())
			then
				if n<2
				then
					room:setChangeSkillState(player,"jl_zhendianvs",2)
					jl_zhendian1(player)
				else
					room:setChangeSkillState(player,"jl_zhendianvs",1)
					jl_zhendian2(player)
				end
			end
		end
		return false
	end,
}
addToSkills(jl_zhendianvs)
jl_qianxue = sgs.CreateTriggerSkill{
	name = "jl_qianxue",
	events = {sgs.Appear},
	hide_skill = true,
	can_trigger = function(self,target)
		return target and target:hasSkill(self)
		and target:getKingdom()=="shu"
	end,
	on_trigger = function(self,event,player,data,room)
       	if event==sgs.Appear
		then
           	room:broadcastSkillInvoke("jl_qianxue")--播放配音
			local discard = room:askForDiscard(player,"jl_qianxue",3,1,false,false,"jl_qianxue0:",".","jl_qianxue")
			if discard and discard:subcardsLength()>0
			then
				SetShifa(self,player,discard:subcardsLength()).effect = function(owner,x)
					owner:gainHujia(x)
				end
			end
		end
	end
}
jl_chenshou:addSkill(jl_qianxue)
jl_chailu = sgs.CreateTriggerSkill{
	name = "jl_chailu",
	events = {sgs.EventPhaseStart,sgs.EventPhaseEnd},
--	frequency = sgs.Skill_Frequent,
	can_trigger = function(self,target)
		return target and target:hasSkill(self)
		and target:getKingdom()=="jin"
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseStart
		and player:getPhase()==sgs.Player_Play
		then
			local to = room:askForPlayerChosen(player,room:getOtherPlayers(player),self:objectName(),"jl_chailu0:",true,true)
			if to
			then
				local cards = {}
				local bc = room:getTag("BreakCard"):toString():split("+")
				for _,id in sgs.list(bc)do
					table.insert(cards,id)
				end
				local RenPile = room:getTag("RenPile"):toString():split("+")
				for _,id in sgs.list(RenPile)do
					table.insert(cards,id)
				end
				for _,p in sgs.list(room:getAlivePlayers())do
					for _,key in sgs.list(p:getPileNames())do
						if p:pileOpen(key,player:objectName())
						then
							for _,id in sgs.list(p:getPile(key))do
								table.insert(cards,id)
							end
						end
					end
				end
				local names = {"TrickCard","EquipCard"}
				for _,c in sgs.list(cards)do
					c = sgs.Sanguosha:getCard(c)
					if c:isKindOf("TrickCard")
					then
						table.insert(names,"^"..c:getClassName())
					end
				end
				local c = room:askForCard(to,table.concat(names,","),"jl_chailu1:"..player:objectName(),ToData(player),sgs.Card_MethodNone)
				if c then room:obtainCard(player,c) to:drawCards(1,"jl_chailu")
				else player:addMark("jl_chailu") end
			end
		elseif event==sgs.EventPhaseEnd
		and player:getPhase()==sgs.Player_Play
		and player:getMark("jl_chailu")>0
		then
			player:removeMark("jl_chailu")
			if player:hasSkill("jl_zhendianvs")
			then sgs.Sanguosha:getTriggerSkill("jl_zhendianvs"):trigger(sgs.EventPhaseStart,room,player,data)
			elseif player:hasSkill("jl_zhendian")
			then sgs.Sanguosha:getTriggerSkill("jl_zhendian"):trigger(sgs.EventPhaseStart,room,player,data) end
		end
		return false
	end,
}
jl_chenshou:addSkill(jl_chailu)

jl_2_liubei = sgs.General(extension,"jl_2_liubei$","shu")
jl_zebingcard = sgs.CreateSkillCard{
	name = "jl_zebingcard",
	will_throw = false,
	filter = function(self,targets,to_selec,source)
		return SCfilter(self:getUserString(),targets,to_selec,self)
	end,
	feasible = function(self,targets)
		return SCfeasible(self:getUserString(),targets,self)
	end,
	on_validate_in_response = function(self,from)
		local room = from:getRoom()
		room:throwCard(self,from)
		local choice = room:askForChoice(from,"jl_zebing",self:getUserString())
		local c = sgs.Sanguosha:cloneCard(choice)
		c:setSkillName("_jl_zebing")
		if c then return c end
		return nil
	end,
	on_validate = function(self,use)
		local room = use.from:getRoom()
		room:throwCard(self,use.from)
		local choice = room:askForChoice(use.from,"jl_zebing",self:getUserString())
		local c = sgs.Sanguosha:cloneCard(choice)
		c:setSkillName("_jl_zebing")
		if c then return c end
		return nil
	end,
}
jl_zebingCard = sgs.CreateSkillCard{
	name = "jl_zebingCard",
	target_fixed = true,
--	will_throw = false,
--	skill_name = "_jl_zebing",
	about_to_use = function(self,room,use)
		local id = self:getSubcards():at(0)
		local pile = use.from:getPileName(id)
		local n = room:getLieges("shu",use.from)
		if sgs.Sanguosha:getCard(id):hasFlag("jl_zebing")
		then
			id = "jl_zebing10"
			if n:length()>0 then id = "jl_zebing10+jl_zebing20" end
			id = room:askForChoice(use.from,"jl_zebing",id)
			if id=="jl_zebing10"
			then
				id = sgs.Sanguosha:cloneCard("peach")
				id:addSubcards(self:getSubcards())
				id:setSkillName("_jl_zebing")
				use.card = id
				if use.to:isEmpty() then use.to:append(use.from) end
				self:cardOnUse(room,use)
			else
				id = PlayerChosen("jl_zebing",use.from,n,"jl_zebing3:jl_zebing20_effect")
				room:obtainCard(id,self,false)
				use.from:drawCards(1,"jl_zebing")
				id:drawCards(1,"jl_zebing")
			end
			return
		end
		self:cardOnUse(room,use)
		Log_message("$jl_zebing0",use.from,nil,id,pile)
		local c_names = {}
		id = "jl_zebing1"
		if pile=="jl_liang"
		then
			if CardIsAvailable(use.from,"peach")
			then table.insert(c_names,"peach") end
			if CardIsAvailable(use.from,"analeptic")
			then table.insert(c_names,"analeptic") end
		elseif pile=="jl_mou"
		then
			if CardIsAvailable(use.from,"amazing_grace")
			then table.insert(c_names,"amazing_grace") end
			if CardIsAvailable(use.from,"archery_attack")
			then table.insert(c_names,"archery_attack") end
			if CardIsAvailable(use.from,"collateral")
			then table.insert(c_names,"collateral") end
			if CardIsAvailable(use.from,"iron_chain")
			then table.insert(c_names,"iron_chain") end
			if CardIsAvailable(use.from,"savage_assault")
			then table.insert(c_names,"savage_assault") end
		end
		if #c_names>0 then id = "jl_zebing1+jl_zebing2" end
		id = room:askForChoice(use.from,"jl_zebing",id)
		if id=="jl_zebing1"
		then
			if pile=="jl_liang" or pile=="jl_qi"
			then n = room:getOtherPlayers(use.from) end
			if n:length()>0
			then
				id = PlayerChosen("jl_zebing",use.from,n,"jl_zebing3:"..pile.."_effect")
				if id
				then
					if pile=="jl_bing"
					then
						pile = "BasicCard"
						n = 2
					elseif pile=="jl_liang"
					then
						pile = "Peach,GodSalvation"
						n = 1
					elseif pile=="jl_mou"
					then
						pile = "TrickCard"
						n = 2
					elseif pile=="jl_qi"
					then
						pile = "Weapon"
						n = 1
					end
					local c = "jl_zebing4:"..use.from:objectName()..":"..n..":"..pile
					c = room:askForExchange(id,"jl_zebing",n,n,true,c,false,pile)
					if c and c:subcardsLength()>=n
					then
						room:obtainCard(use.from,c)
						if pile=="BasicCard"
						then
							id:drawCards(2,"jl_zebing")
						end
					else
						id = sgs.IntList()
						for i,p in sgs.list(room:getAllPlayers())do
							for _,h in sgs.list(p:getCards("ej"))do
								if sgs.Sanguosha:matchExpPattern(pile,use.from,h)
								then id:append(h:getEffectiveId()) end
							end
						end
						for h,i in sgs.list(room:getDrawPile())do
							h = sgs.Sanguosha:getCard(i)
							if sgs.Sanguosha:matchExpPattern(pile,use.from,h)
							then id:append(i) end
						end
						id = RandomList(id)
						c = dummyCard()
						for i=0,n-1 do
							c:addSubcard(id:at(i))
						end
						room:obtainCard(use.from,c)
					end
					for i,id in sgs.list(c:getSubcards())do
						use.from:addMark(id.."jl_zebing")
						if use.from:getHp()~=1
						then use.from:addMark(id.."jl_zebing_damage")
						else room:setCardFlag(id,"jl_zebing") end
					end
				end
			end
		elseif id=="jl_zebing2"
		then
			c_names = room:askForChoice(use.from,"jl_zebing",table.concat(c_names,"+"))
			id = PatternsCard(c_names)
			room:setPlayerMark(use.from,"jl_zebing",id:getEffectiveId())
			room:askForUseCard(use.from,"@@jl_zebing!","jl_zebing5:"..c_names)
		end
	end,
}
jl_zebingVS = sgs.CreateViewAsSkill{
	name = "jl_zebing$",
	n = 1,
	expand_pile = "jl_bing,jl_liang,jl_mou,jl_qi",
	view_filter = function(self,selected,to_select)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if to_select:hasFlag("jl_zebing")
		then
			for _,p in sgs.list(sgs.Self:getAliveSiblings())do
				if CardIsAvailable(sgs.Self,"peach",nil,to_select:getSuit(),to_select:getNumber())
				or p:getKingdom()=="shu" then return true end
			end
		end
		if string.find(pattern,"jink")
		or string.find(pattern,"peach")
		or string.find(pattern,"analeptic")
		or string.find(pattern,"nullification")
		then return sgs.Self:getPileName(to_select:getEffectiveId())=="jl_liang" end
		if sgs.Self:getHandcards():contains(to_select)
		or string.find(pattern,"@@jl_zebing")
		or to_select:isEquipped()
		then return end
		return true
	end,
	view_as = function(self,cards)
		local nc = jl_zebingCard:clone()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if string.find(pattern,"@@jl_zebing")
		then
			nc = sgs.Sanguosha:getCard(sgs.Self:getMark("jl_zebing"))
			nc = sgs.Sanguosha:cloneCard(nc:objectName())
			nc:setSkillName("_jl_zebing")
			return nc
		elseif string.find(pattern,"jink")
		or string.find(pattern,"peach")
		or string.find(pattern,"analeptic")
		or string.find(pattern,"nullification")
		then nc = jl_zebingcard:clone() end
		nc:setUserString(pattern)
	   	if #cards<1 then return end
	   	for _,c in sgs.list(cards)do
	    	nc:addSubcard(c)
	   	end
		return nc
	end,
	enabled_at_response = function(self,player,pattern)
		return (string.find(pattern,"jink")
		or string.find(pattern,"peach")
		or string.find(pattern,"analeptic")
		or string.find(pattern,"nullification"))
		and player:getPile("jl_liang"):length()>0
		and sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
		or string.find(pattern,"@@jl_zebing")
	end,
	enabled_at_nullification = function(self,player)
		return player:getPile("jl_liang"):length()>0
	end,
	enabled_at_play = function(self,player)
	   	for _,c in sgs.list(player:getHandcards())do
			if c:hasFlag("jl_zebing")
			then
				for _,p in sgs.list(player:getAliveSiblings())do
					if CardIsAvailable(player,"peach",nil,c:getSuit(),c:getNumber())
					or p:getKingdom()=="shu" then return true end
				end
			end
	   	end
		for _,p in sgs.list(player:getAliveSiblings())do
			if (player:getPile("jl_bing"):length()>0 or player:getPile("jl_mou"):length()>0)
			and p:getKingdom()=="shu" then return true end
		end
		return player:getPile("jl_liang"):length()>0
		or player:getPile("jl_qi"):length()>0
	end
}
jl_zebing = sgs.CreateTriggerSkill{
	name = "jl_zebing$",
	events = {sgs.EventPhaseStart,sgs.EventPhaseEnd,sgs.ConfirmDamage,sgs.EnterDying,
	sgs.Damage,sgs.CardsMoveOneTime,sgs.CardEffected},
	view_as_skill = jl_zebingVS,
	can_trigger = function(self,target)
		return target and target:hasLordSkill(self)
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseStart
		then
			if player:getPhase()==sgs.Player_Play
			and player:getMark("jl_zebing")>0
			then
	    	    ExchangePileCard(self,player,"jl_bing",4,true,true)
	    	    ExchangePileCard(self,player,"jl_liang",4,true,true)
	    	    ExchangePileCard(self,player,"jl_mou",4,true,true)
	    	    ExchangePileCard(self,player,"jl_qi",4,true,true)
			end
		elseif event==sgs.EnterDying
		then
	    	local dying = data:toDying()
			local cids = dying.who:getPile("jl_bing")
			if cids:length()>0
			then
				if PreviewCards(self,player,cids,1,1,true,"jl_zebing11:",true)
				then
					local to = room:askForPlayerChosen(dying.who,room:getOtherPlayers(dying.who),self:objectName(),"jl_zebing12:",true,true)
					if to
					then
						if to:getKingdom()~="shu"
						then
							if to:askForSkillInvoke("jl_zebing11",sgs.QVariant("jl_zebing13:"..dying.who:objectName()),false)
							then
								room:setPlayerProperty(to,"kingdom",sgs.QVariant("shu"))
								ns = room:askForExchange(to,"jl_zebing",1,1,true)
								room:obtainCard(dying.who,ns,false)
							end
						else
							room:recover(dying.who,sgs.RecoverStruct(to,nil,1-dying.who:getHp()))
						end
					end
				end
			end
		elseif event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
    		local flag = bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON)
			local cids = player:getPile("jl_qi")
			if move.from
			and cids:length()>0
			and move.from:objectName()~=player:objectName()
			and flag==sgs.CardMoveReason_S_REASON_DISCARD
			then
				flag = sgs.IntList()
				for c,id in sgs.list(move.card_ids)do
					c = sgs.Sanguosha:getCard(id)
					if room:getCardOwner(id)==nil
					and c:isKindOf("EquipCard")
					then flag:append(id) end
				end
				if flag:length()>0
				and player:askForSkillInvoke(self,sgs.QVariant("jl_zebing0:"))
				then
					local x = cids:length()
					local c = PreviewCards(self,player,flag,x,1,true,"jl_zebing01:")
					if c and c:subcardsLength()>0
					then
						x = c:subcardsLength()
						flag = table.concat(sgs.QList2Table(cids),",")
						x = room:askForExchange(player,"jl_zebing",x,x,false,"jl_zebing02:",false,flag)
						room:throwCard(x,player)
						room:obtainCard(player,c)
					end
				end
			end
		elseif event==sgs.CardEffected
		then
            local effect = data:toCardEffect()
			if effect.card:objectName()=="slash"
			and player:getPile("jl_liang"):isEmpty()
			then
				Skill_msg(self,player)
				effect.nullified = true
				data:setValue(effect)
			end
		elseif event==sgs.ConfirmDamage
		then
		    local damage = data:toDamage()
			if damage.card
			and player:getMark(damage.card:toString().."jl_zebing_damage")>0
			then
				Skill_msg(self,player)
				return DamageRevises(data,1,player)
			end
		elseif event==sgs.Damage
		then
		    local damage = data:toDamage()
			if damage.card
			and player:getMark(damage.card:toString().."jl_zebing_damage")>0
			then
				Skill_msg(self,player)
				local choice = "jl_zebing_damage1+jl_zebing_damage2"
				if room:getCardOwner(damage.card:getEffectiveId())==nil
				or room:getCardOwner(damage.card:getEffectiveId())==player
				then choice = "jl_zebing_damage1+jl_zebing_damage2+jl_zebing_damage3" end
				choice = room:askForChoice(player,"jl_zebing",choice)
				if choice=="jl_zebing_damage1"
				then player:drawCards(damage.damage,"jl_zebing")
				elseif choice=="jl_zebing_damage2"
				then room:askForDiscard(damage.to,self:objectName(),damage.damage,damage.damage,false,true)
				elseif choice=="jl_zebing_damage3"
				then
					room:obtainCard(player,damage.card)
					player:removeMark(damage.card:toString().."jl_zebing_damage")
					player:removeMark(damage.card:toString().."jl_zebing")
				end
			end
		elseif event==sgs.EventPhaseEnd
		then
			if player:getPhase()==sgs.Player_Draw
			and player:getMark("jl_zebing")<1
			then
				Skill_msg(self,player)
				player:addMark("jl_zebing")
				local c,su = dummyCard(),{}
				for i,id in sgs.list(room:getDrawPile())do
					i = sgs.Sanguosha:getCard(id):getSuitString()
					if table.contains(su,i) then continue end
					table.insert(su,i)
					c:addSubcard(id)
				end
				if #su<4 then return end
				room:obtainCard(player,c)
				c = room:askForCard(player,".|diamond!","jl_zebing0:diamond:jl_bing",ToData(),sgs.Card_MethodNone)
				if c then player:addToPile("jl_bing",c) end
				c = room:askForCard(player,".|club!","jl_zebing0:club:jl_liang",ToData(),sgs.Card_MethodNone)
				if c then player:addToPile("jl_liang",c) end
				c = room:askForCard(player,".|heart!","jl_zebing0:heart:jl_mou",ToData(),sgs.Card_MethodNone)
				if c then player:addToPile("jl_mou",c) end
				c = room:askForCard(player,".|spade!","jl_zebing0:spade:jl_qi",ToData(),sgs.Card_MethodNone)
				if c then player:addToPile("jl_qi",c) end
			end
			if player:getPhase()==sgs.Player_Finish
			and player:getMark("jl_zebing")>0
			then
	    	    ExchangePileCard(self,player,"jl_bing",4,true,true)
	    	    ExchangePileCard(self,player,"jl_liang",4,true,true)
	    	    ExchangePileCard(self,player,"jl_mou",4,true,true)
	    	    ExchangePileCard(self,player,"jl_qi",4,true,true)
			end
		end
		if player:getPile("jl_bing"):isEmpty()
		then
			if not player:hasLordSkill("jijiang")
			then
				Skill_msg(self,player)
				room:acquireSkill(player,"jijiang")
			end
		elseif player:hasLordSkill("jijiang")
		then
			Skill_msg(self,player)
			room:detachSkillFromPlayer(player,"jijiang")
		end
		if player:getPile("jl_qi"):isEmpty()
		then
			if player:getMark("jl_qi_")<1
			then
				player:addMark("jl_qi_")
				for i,p in sgs.list(room:getAlivePlayers())do
					if p:getKingdom()=="shu" then continue end
					room:insertAttackRangePair(player,p)
					p:addMark("jl_qi"..player:objectName())
				end
			end
		elseif player:getMark("jl_qi_")>0
		then
			player:removeMark("jl_qi_")
			for i,p in sgs.list(room:getAlivePlayers())do
				if p:getMark("jl_qi"..player:objectName())>0
				then
					p:removeMark("jl_qi"..player:objectName())
					room:removeAttackRangePair(player,p)
				end
			end
		end
		return false
	end,
}
jl_2_liubei:addSkill(jl_zebing)
jl_zebingvs = sgs.CreateTriggerSkill{
	name = "#jl_zebingvs" ,
--	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damage,sgs.HpRecover,sgs.CardResponded}, 
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName("jl_zebing")
	end,
	on_trigger = function(self,event,player,data,room)
	   	for _,owner in sgs.list(room:findPlayersBySkillName("jl_zebing"))do
			if owner:hasLordSkill("jl_zebing")
			then
				if event==sgs.HpRecover
				then
					local rec = data:toRecover()
					local cids = owner:getPile("jl_liang")
					if rec.card
					and cids:length()>0
					and (rec.card:isKindOf("Peach") or rec.card:isKindOf("Analeptic"))
					then
						if room:getCardOwner(rec.card:getEffectiveId())==nil
						and PreviewCards("jl_zebing",owner,cids,1,1,true,"jl_zebing21:jl_liang:"..rec.card:objectName(),true)
						then room:obtainCard(owner,rec.card) end
					end
				elseif event==sgs.Damage
				then
					local damage = data:toDamage()
					local cids = owner:getPile("jl_mou")
					if damage.card
					and cids:length()>0
					and damage.card:isKindOf("SavageAssault")
					then
						if room:getCardOwner(damage.card:getEffectiveId())==nil
						and PreviewCards("jl_zebing",owner,cids,1,1,true,"jl_zebing21:jl_mou:savage_assault",true)
						then room:obtainCard(owner,damage.card) end
					end
				elseif event==sgs.CardResponded
				then
					local star = data:toCardResponse()
					local cids = owner:getPile("jl_bing")
					if cids:length()>0
					and player:getKingdom()=="shu"
					and star.m_card:isKindOf("Slash")
					then
						if room:getCardOwner(star.m_card:getEffectiveId())==nil
						and PreviewCards("jl_zebing",owner,cids,1,1,true,"jl_zebing21:jl_bing:slash",true)
						then room:obtainCard(owner,star.m_card) end
					end
				end
			end
		end
		return false
	end
}
jl_2_liubei:addSkill(jl_zebingvs)

jl_caochong = sgs.General(extension,"jl_caochong","wei",3)
jl_chengxiang = sgs.CreateTriggerSkill{
	name = "jl_chengxiang",
	events = {sgs.EventPhaseProceeding,sgs.Damaged,sgs.RoundStart},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Damaged
		or event==sgs.EventPhaseProceeding and player:getPhase()==sgs.Player_Start
		then
			local choices = {}
			for i=1,26 do
				if player:getMark("jlcx_="..i)>0
				or player:getTag("jlcx_="..i):toBool()
				then continue end
				table.insert(choices,"jlcx_="..i)
			end
			if #choices>0
			and ToSkillInvoke(self,player)
			then
				choices = room:askForChoice(player,"jl_chengxiang",table.concat(choices,"+"))
				local n = string.sub(choices,7,-1)
				Log_message("$jl_chengxiang2",player,nil,nil,"jl_chengxiang",n)
				player:addMark(choices)
				n = n-0
				if n<14
				then
					local card_ids = room:getNCards(4)
					room:fillAG(card_ids)
					local dummy = dummyCard()
					local to_throw,ids = sgs.IntList(),sgs.IntList()
					for _,id in sgs.list(card_ids)do
						ids:append(id)
					end
					local sum = 0
					while player do
						for _,id in sgs.list(card_ids)do
							if sum+sgs.Sanguosha:getCard(id):getNumber()>=n
							and ids:contains(id)
							then
								to_throw:append(id)
								room:takeAG(nil,id,false)
								ids:removeOne(id)
							end
						end
						if ids:isEmpty() then break end
						local id = room:askForAG(player,ids,true,self:objectName())
						if id==-1 then break end
						room:takeAG(player,id,false)
						sum = sum+sgs.Sanguosha:getCard(id):getNumber()
						dummy:addSubcard(id)
						ids:removeOne(id)
					end
					room:clearAG()
					if dummy:subcardsLength()>0
					then
						local to = PlayerChosen(self,player,nil,"jl_chengxiang0:")
						to:obtainCard(dummy)
					end
					dummy:clearSubcards()
					dummy:addSubcards(ids)
					dummy:addSubcards(to_throw)
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER,player:objectName(),self:objectName(),nil)
					room:throwCard(dummy,reason,nil)
				else
					local to = PlayerChosen(self,player,nil,"jl_chengxiang1:")
					local sum = 0
					n = n-13
					while to do
						if to:isNude() or sum>n then return end
						local cid = room:askForCardChosen(player,to,"he",self:objectName())
						room:throwCard(cid,to,player)
						sum=sum+sgs.Sanguosha:getCard(cid):getNumber()
					end
				end
			end
		elseif event==sgs.RoundStart
		then
			for i = 1,26 do
				player:setMark("jlcx_="..i,0)
			end
		end
		return false
	end,
}
jl_caochong:addSkill(jl_chengxiang)
jl_renxin = sgs.CreateTriggerSkill{
	name = "jl_renxin",
	events = {sgs.Dying},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data,room)
       	if event==sgs.Dying
		then
			local choices = {}
			for i = 1,26 do
				if player:getTag("jlcx_="..i):toBool() then continue end
				table.insert(choices,"jlcx_="..i)
			end
	     	local dying = data:toDying()
			if dying.who:objectName()==player:objectName()
			and #choices>1
			then
				room:sendCompulsoryTriggerLog(player,self)
				room:recover(player,sgs.RecoverStruct(player,nil,1-player:getHp()))
				choices = room:askForChoice(player,"jl_renxin",table.concat(choices,"+"))
				Log_message("$jl_renxin0",player,nil,nil,"jl_chengxiang",string.sub(choices,7,-1))
				player:setTag(choices,sgs.QVariant(true))
			end
		end
	end
}
jl_caochong:addSkill(jl_renxin)

jl_guanyu = sgs.General(extension,"jl_guanyu","shu")
jl_wushengVS = sgs.CreateOneCardViewAsSkill{
	name = "jl_wusheng",
	response_or_use = true,
	view_filter = function(self,card)
		if not card:isRed() then return end
		if sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_PLAY
		then
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:setSkillName("wusheng")
			slash:addSubcard(card)
			slash:deleteLater()
			return slash:isAvailable(sgs.Self)
		end
		return true
	end,
	view_as = function(self,card)
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:addSubcard(card)
		slash:setSkillName("wusheng")
		return slash
	end,
	enabled_at_play = function(self,player)
		return ("slash"):cardAvailable(player,"wusheng")
	end,
	enabled_at_response = function(self,player,pattern)
		return string.find(pattern,"slash")
	end
}
jl_wusheng = sgs.CreateTriggerSkill{
	name = "jl_wusheng" ,
	events = {sgs.CardUsed} , 
	view_as_skill = jl_wushengVS,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardUsed
		then
	    	local use = data:toCardUse()
			if use.card:getSkillName()~="wusheng" then return end
			Skill_msg(self,player)
			local list,tos = use.no_respond_list,sgs.SPlayerList()
	    	for _,to in sgs.list(use.to)do
				table.insert(list,to:objectName())
				tos:append(to)
			end
			Log_message("$jl_wusheng_bf",player,tos,nil,use.card:objectName())
			use.no_respond_list = list
			data:setValue(use)
		end
		return false
	end
}
jl_guanyu:addSkill(jl_wusheng)

jl_xingdaorong = sgs.General(extension,"jl_xingdaorong","god")
jl_wuyong = sgs.CreateCardLimitSkill{
	name = "jl_wuyong" ,
	limit_list = function(self,player)
		if player and player:hasSkill(self)
		then return "use,response" end
	end,
	limit_pattern = function(self,player)
		if player and player:hasSkill(self)
		then return "BasicCard" end
	end
}
jl_xingdaorong:addSkill(jl_wuyong)
jl_wumou = sgs.CreateCardLimitSkill{
	name = "jl_wumou" ,
	limit_list = function(self,player)
		if player and player:hasSkill(self)
		then return "use" end
	end,
	limit_pattern = function(self,player)
		if player and player:hasSkill(self)
		then return "TrickCard" end
	end
}
jl_xingdaorong:addSkill(jl_wumou)
jl_wudu = sgs.CreateCardLimitSkill{
	name = "jl_wudu" ,
	limit_list = function(self,player)
		if player and player:hasSkill(self)
		then return "use" end
	end,
	limit_pattern = function(self,player)
		if player and player:hasSkill(self)
		then return "EquipCard" end
	end
}
jl_xingdaorong:addSkill(jl_wudu)
jl_wuliang = sgs.CreateTriggerSkill{
	name = "jl_wuliang",
	events = {sgs.Death},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self,target)
		return target and target:isDead()
		and target:hasSkill(self)
	end,
	on_trigger = function(self,event,player,data,room)
       	if event==sgs.Death
		then
           	room:broadcastSkillInvoke("jl_wuliang")--播放配音
			local to = room:askForPlayerChosen(player,room:getOtherPlayers(player),self:objectName(),"jl_wuliang0:",false,true)
			local list = {}
	    	for _,s in sgs.list(player:getSkillList())do
		    	if s:isAttachedLordSkill() then continue end
				table.insert(list,s:objectName())
			end
			room:handleAcquireDetachSkills(to,table.concat(list,"|"))
		end
	end
}
jl_xingdaorong:addSkill(jl_wuliang)

--[[
jl_handang = sgs.General(extension,"jl_handang","wu")
jl_gongqi = sgs.CreateTriggerSkill{
	name = "jl_gongqi",
	events = {sgs.EventPhaseChanging},
--	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data,room)
       	if event==sgs.EventPhaseChanging
		then
			local change = data:toPhaseChange()
			if change.from==sgs.Player_Play
			and room:askForDiscard(player,"jl_gongqi",1,1,true,true,"jl_gongqi0:","EquipCard","jl_gongqi")
			then PhaseExtra(player,change.from,true) end
		end
	end
}
jl_handang:addSkill(jl_gongqi)
jl_jiefanCard = sgs.CreateSkillCard{
	name = "jl_jiefanCard",
--	target_fixed = true,
--	will_throw = false,
	skill_name = "jl_jiefan",
	filter = function(self,targets,to_select,source)
		return #targets<1
	end,
	on_use = function(self,room,source,targets)
		for _,to in sgs.list(targets)do
			local jf = sgs.Sanguosha:getSkill("jl_jiefan")
			jf = jf:getDescription()
			jf = GetStringLength(jf)
			local list = {}
			local choices = "jl_jiefan2"
	    	for i,s in sgs.list(to:getSkillList())do
		    	if s:isAttachedLordSkill() then continue end
				i = s:getDescription()
				i = GetStringLength(i)
				if i<=jf then continue end
				table.insert(list,s:objectName())
			end
			if #list>0 then choices = "jl_jiefan1+jl_jiefan2" end
			choices = room:askForChoice(to,"jl_jiefan",choices)
			if choices=="jl_jiefan1"
			then
				choices = room:askForChoice(to,choices,table.concat(list,"+"))
				room:detachSkillFromPlayer(to,choices)
			else
				choices = GetAvailableGenerals(to)
				room:doAnimate(4,to:objectName(),choices[1])
				room:getThread():delay(666)
				room:changeHero(to,choices[1],false)
			end
		end
	end,
}
jl_jiefanVS = sgs.CreateViewAsSkill{
	name = "jl_jiefan",
	view_as = function(self,cards)
		return jl_jiefanCard:clone()
	end,
	enabled_at_response = function(self,player,pattern)
		if string.find(pattern,"@@jl_jiefan")
		then return true end
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#jl_jiefanCard")<1
	end
}
jl_handang:addSkill(jl_jiefanVS)
--]]

function GetAvailableGenerals(player)
	local generals,no_generals = {},{}
	local BanPackages = sgs.Sanguosha:getBanPackages()
	for _,p in sgs.list(player:getRoom():getAllPlayers())do
		table.insert(no_generals,p:getGeneralName())
	end
	for _,general in sgs.list(sgs.Sanguosha:getLimitedGeneralNames())do
		if table.contains(BanPackages,sgs.Sanguosha:getGeneral(general):getPackage())
		or table.contains(no_generals,general)
		then continue end
		table.insert(generals,general)
	end
	return RandomList(generals)
end

jl_tianzi = sgs.General(extension,"jl_tianzi","god")
jl_weiyeCard = sgs.CreateSkillCard{
	name = "jl_weiyeCard",
	target_fixed = true,
	on_validate = function(self,use)
		local from = use.from
		local room = from:getRoom()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local plist = room:getLieges("wei",from)
		NotifySkillInvoked("jl_weiye",from,plist)
       	room:broadcastSkillInvoke("hujia")--播放配音
 		for _,p in sgs.list(plist)do
    		local c = "jl_weiye_card:"..from:objectName()..":jink"
    		c = room:askForCard(p,"jink",c,ToData(from),sgs.Card_MethodResponse,from)
    		if c
			then
				if c:isVirtualCard()
				then
					c:setSkillName("_jl_weiye")
				end
				return c
			end
		end
		room:setPlayerFlag(from,"nojl_weiye")
	end,
	on_validate_in_response = function(self,from)
		local room = from:getRoom()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local plist = room:getLieges("wei",from)
		NotifySkillInvoked("jl_weiye",from,plist)
       	room:broadcastSkillInvoke("hujia")--播放配音
 		for _,p in sgs.list(plist)do
    		local c = "jl_weiye_card:"..from:objectName()..":jink"
    		c = room:askForCard(p,"jink",c,ToData(from),sgs.Card_MethodResponse,from)
    		if c
			then
				if c:isVirtualCard()
				then
					c:setSkillName("_jl_weiye")
				end
				return c
			end
		end
		room:setPlayerFlag(from,"nojl_weiye")
	end
}
jl_weiyeVS = sgs.CreateViewAsSkill{
	name = "jl_weiye",
	view_as = function()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = jl_weiyeCard:clone()
		c:setUserString(pattern)
		return c
	end,
	enabled_at_play = function(self,player)
		return false
	end,
	enabled_at_response = function(self,player,pattern)
		for _,p in sgs.list(player:getAliveSiblings())do
			if p:getKingdom()=="wei"
			then
				return string.find(pattern,"jink")
				and not player:hasFlag("nojl_weiye")
			end
		end
	end
}
jl_weiye = sgs.CreateTriggerSkill{
	name = "jl_weiye",
	events = {sgs.FinishJudge,sgs.Dying,sgs.CardsMoveOneTime},
	view_as_skill = jl_weiyeVS,
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	for _,owner in sgs.list(room:findPlayersBySkillName("jl_weiye"))do
	   	room:setPlayerFlag(owner,"-nojl_weiye")
		if event==sgs.FinishJudge
		then
    		local judge = data:toJudge()
    		local card = judge.card
			if card:isBlack()
			and player:getKingdom()=="wei"
			and player:objectName()~=owner:objectName()
			and ToSkillInvoke(self,player,owner)
			then
             	room:broadcastSkillInvoke("songwei")--播放配音
				owner:drawCards(1,"jl_weiye")
			end
		elseif event==sgs.Dying
		then
	     	local dying = data:toDying()
			local plist = room:getLieges("wei",owner)
			if dying.who:objectName()==player:objectName()
			and player:objectName()==owner:objectName()
			and plist:length()>0
			and ToSkillInvoke(self,owner)
			then
             	room:broadcastSkillInvoke("xingshuai")--播放配音
				for _,p in sgs.list(plist)do
					if p:askForSkillInvoke(self,ToData("jl_weiye0:"..owner:objectName()),false)
					then
						room:recover(owner,sgs.RecoverStruct(p))
						room:damage(sgs.DamageStruct(self:objectName(),nil,p))
					end
				end
			end
		end
		end
	end,
}
jl_tianzi:addSkill(jl_weiye)
jl_shuituCard = sgs.CreateSkillCard{
	name = "jl_shuituCard",
--	will_throw = false,
	filter = function(self,targets,to_select,from)
		local pattern = self:getUserString()
		if pattern==""
		then pattern = "slash"
		elseif string.find(pattern,"jink")
		then return false end
		return SCfilter(pattern,targets,to_select)
	end,
	feasible = function(self,targets)
		local pattern = self:getUserString()
		if pattern==""
		then pattern = "slash"
		elseif string.find(pattern,"jink")
		then return true end
		return SCfeasible(pattern,targets)
	end,
	on_validate = function(self,use)
		local from = use.from
		local room = from:getRoom()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local plist = room:getLieges("shu",from)
		NotifySkillInvoked("jl_shuitu",from,plist)
		if self:subcardsLength()>0
		then
			room:broadcastSkillInvoke("qinwang")--播放配音
			room:throwCard(self,from)
		else
			room:broadcastSkillInvoke("jijiang")--播放配音
		end
 		for _,p in sgs.list(plist)do
    		local c = "jl_shuitu_card:"..from:objectName()..":slash"
    		c = room:askForCard(p,"slash",c,ToData(from),sgs.Card_MethodResponse,from)
    		if c
			then
				if c:isVirtualCard()
				then
					c:setSkillName("_jl_shuitu")
				end
				if self:subcardsLength()>0
				then
					p:drawCards(1,"jl_shuitu")
				end
				return c
			end
		end
		room:setPlayerFlag(from,"nojl_shuitu")
	end,
	on_validate_in_response = function(self,from)
		local room = from:getRoom()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local plist = room:getLieges("shu",from)
		NotifySkillInvoked("jl_shuitu",from,plist)
		if self:subcardsLength()>0
		then
			room:broadcastSkillInvoke("qinwang")--播放配音
			room:throwCard(self,from)
		else
			room:broadcastSkillInvoke("jijiang")--播放配音
		end
 		for _,p in sgs.list(plist)do
    		local c = "jl_shuitu_card:"..from:objectName()..":slash"
    		c = room:askForCard(p,"slash",c,ToData(from),sgs.Card_MethodResponse,from)
    		if c
			then
				if c:isVirtualCard()
				then
					c:setSkillName("_jl_shuitu")
				end
				if self:subcardsLength()>0
				then
					p:drawCards(1,"jl_shuitu")
				end
				return c
			end
		end
		room:setPlayerFlag(from,"nojl_shuitu")
	end
}
jl_shuituVS = sgs.CreateViewAsSkill{
	name = "jl_shuitu",
	n = 1,
	view_filter = function(self,selected,to_select)
		return not sgs.Self:isJilei(to_select)
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = jl_shuituCard:clone()
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		c:setUserString(pattern)
		return c
	end,
	enabled_at_play = function(self,player)
		for _,p in sgs.list(player:getAliveSiblings())do
			if p:getKingdom()=="shu"
			then
				return sgs.Slash_IsAvailable(player)
			end
		end
	end,
	enabled_at_response = function(self,player,pattern)
		for _,p in sgs.list(player:getAliveSiblings())do
			if p:getKingdom()=="shu"
			then
				return string.find(pattern,"slash")
				and not player:hasFlag("nojl_shuitu")
			end
		end
	end
}
jl_shuitu = sgs.CreateTriggerSkill{
	name = "jl_shuitu",
	events = {sgs.EventPhaseProceeding,sgs.CardsMoveOneTime},
	view_as_skill = jl_shuituVS,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	room:setPlayerFlag(player,"-nojl_shuitu")
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Start
		then
			for _,p in sgs.list(room:getOtherPlayers(player))do
				if p:getHp()<player:getHp() then return end
			end
			room:sendCompulsoryTriggerLog(player,self)
		 	room:broadcastSkillInvoke("ruoyu")--播放配音
			room:gainMaxHp(player)
			room:recover(player,sgs.RecoverStruct(player))
		end
	end,
}
jl_tianzi:addSkill(jl_shuitu)
jl_wuceCard = sgs.CreateSkillCard{
	name = "jl_wuceCard",
	filter = function(self,targets,to_select,from)
		return from:canPindian(to_select)
		and to_select:hasSkill("jl_wuce")
		and #targets<1
	end,
	feasible = function(self,targets)
		return #targets>0
	end,
	on_use = function(self,room,source,targets)
       	room:broadcastSkillInvoke("zhiba")--播放配音
		for _,to in sgs.list(targets)do
			local pd = source:PinDian(to,"jl_wuce")
			if pd.success then continue end
			self:addSubcard(pd.from_card)
			self:addSubcard(pd.to_card)
			room:obtainCard(to,self)
		end
	end
}
jl_wuceVS = sgs.CreateViewAsSkill{
	name = "jl_wucevs&",
	view_as = function()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = jl_wuceCard:clone()
		c:setUserString(pattern)
		return c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#jl_wuceCard")<1
		and player:getKingdom()=="wu"
		and player:canPindian()
	end,
}
jl_wuce = sgs.CreateTriggerSkill{
	name = "jl_wuce",
	events = {sgs.TargetConfirmed,sgs.PreHpRecover,sgs.CardFinished,sgs.CardsMoveOneTime},
--	view_as_skill = jl_wuceVS,
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	for _,owner in sgs.list(room:findPlayersBySkillName("jl_wuce"))do
		if event==sgs.TargetConfirmed
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Peach")
			and use.to:contains(owner)
			and use.from:getKingdom()=="wu"
			and owner:objectName()~=use.from:objectName()
			then room:setCardFlag(use.card,"jl_wuce") end
		elseif event==sgs.PreHpRecover
		then
			local rec = data:toRecover()
			if rec.card
			and rec.card:hasFlag("jl_wuce")
			and owner:objectName()==player:objectName()
			then
				room:setCardFlag(rec.card,"-jl_wuce")
                room:sendCompulsoryTriggerLog(owner,self:objectName())
             	room:broadcastSkillInvoke("jiuyuan")--播放配音
				rec.recover = rec.recover+1
				data:setValue(rec)
			end
		elseif event==sgs.CardFinished
		then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash")
			and use.from:getKingdom()=="wu"
			and owner:objectName()~=use.from:objectName()
			and room:getCardOwner(use.card:getEffectiveId())==nil
			and ToSkillInvoke(self,use.from,owner)
			then
             	room:broadcastSkillInvoke("lijun")--播放配音
				room:obtainCard(owner,use.card)
				if ToSkillInvoke(self,owner,use.from)
				then
					use.from:drawCards(1,"jl_wuce")
				end
			end
		end
		for _,p in sgs.list(room:getLieges("wu",owner))do
			if p:hasSkill("jl_wucevs") then continue end
			room:attachSkillToPlayer(p,"jl_wucevs")
		end
		end
	end,
}
jl_tianzi:addSkill(jl_wuce)
addToSkills(jl_wuceVS)
jl_qunliCard = sgs.CreateSkillCard{
	name = "jl_qunliCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		return to_select:hasSkill("jl_qunli")
		and #targets<1
	end,
	feasible = function(self,targets)
		return #targets>0
	end,
	about_to_use = function(self,room,use)
		local zhangjiao = use.to:at(0)
		room:broadcastSkillInvoke("huangdian")--播放配音
		room:doAnimate(1,use.from:objectName(),zhangjiao:objectName())
		room:notifySkillInvoked(zhangjiao,"jl_qunli")
		local msg = sgs.LogMessage()
		msg.type = "$bf_huangtian0"
		msg.from = use.from
		msg.arg = zhangjiao:getGeneralName()
		msg.arg2 = "jl_qunli"
		room:sendLog(msg)
		zhangjiao:obtainCard(self,false)
	end
}
jl_qunliVS = sgs.CreateViewAsSkill{
	name = "jl_qunlivs&",
	n = 1,
	view_filter = function(self,selected,to_select)
		return to_select:isKindOf("Jink")
		or to_select:isKindOf("Lightning")
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = jl_qunliCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#jl_qunliCard")<1
		and player:getKingdom()=="qun"
	end,
}
jl_qunli = sgs.CreateTriggerSkill{
	name = "jl_qunli",
	events = {sgs.Damage,sgs.CardsMoveOneTime},
--	view_as_skill = jl_qunliVS,
--	global = true,
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
	   	for _,owner in sgs.list(room:findPlayersBySkillName("jl_qunli"))do
			if event==sgs.Damage
			then
				local damage = data:toDamage()
				if player:getKingdom()=="qun"
				and player:objectName()==damage.from:objectName()
				and player:objectName()~=owner:objectName()
				and ToSkillInvoke(self,player,owner)
				then
					room:broadcastSkillInvoke("baonue")--播放配音
					local judge = sgs.JudgeStruct()
					judge.pattern = ".|spade"
					judge.good = true
					judge.play_animation = false
					judge.who = player
					judge.reason = self:objectName()
					room:judge(judge)
					if judge:isGood()
					then
						room:recover(owner,sgs.RecoverStruct(player))
					end
				end
			end
			for _,p in sgs.list(room:getLieges("qun",owner))do
				if p:hasSkill("jl_qunlivs") then continue end
				room:attachSkillToPlayer(p,"jl_qunlivs")
			end
		end
	end,
}
jl_tianzi:addSkill(jl_qunli)
addToSkills(jl_qunliVS)

jl_made = sgs.General(extension,"jl_made","qun")
jl_mengma = sgs.CreateDistanceSkill{
	name = "jl_mengma",
	correct_func = function(self,from,to)
		if from:hasSkill(self)
		then return -998 end
	end
}
jl_made:addSkill(jl_mengma)
jl_pangshu = sgs.CreateTriggerSkill{
	name = "jl_pangshu",
	events = {sgs.SlashMissed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local effect = data:toSlashEffect()
		if effect.to:isAlive() and player:canDiscard(effect.to, "he")
		and player:askForSkillInvoke(self:objectName(),ToData(effect.to))
		then
		   	room:broadcastSkillInvoke("mengjin")
			local c = room:askForCardChosen(player, effect.to, "he", self:objectName(), false, sgs.Card_MethodDiscard)
			c = sgs.Sanguosha:getCard(c)
			room:throwCard(c, effect.to, player)
			if c:getTypeId()~=3
			then
				room:slashResult(effect,nil)
			end
		end
		return false
	end,
}
jl_made:addSkill(jl_pangshu)

jl_ningma = sgs.General(extension,"jl_ningma","wu")
jl_qixiVS = sgs.CreateOneCardViewAsSkill{
	name = "jl_qixi", 
	filter_pattern = ".|black",
	view_as = function(self, card) 
		local acard = sgs.Sanguosha:cloneCard("dismantlement")
		acard:setSkillName(self:objectName())
		acard:addSubcard(card)
		return acard
	end, 
}
jl_qixi = sgs.CreateTriggerSkill{
	name = "jl_qixi",
	events = {sgs.CardsMoveOneTime,sgs.TargetConfirmed,sgs.CardFinished},
	view_as_skill = jl_qixiVS,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.CardsMoveOneTime
		then
	    	local move = data:toMoveOneTime()
			if move.card_ids:length()>0
			and move.to_place==sgs.Player_DiscardPile
			and BeMan(room,move.from):hasFlag("jl_qixi")
			and bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON)==sgs.CardMoveReason_S_REASON_DISCARD
			then
				local d = dummyCard()
				d:addSubcards(move.card_ids)
				BeMan(room,move.from):setFlags("-jl_qixi")
				room:obtainCard(player,d)
			end
		elseif event==sgs.TargetConfirmed
		then
			local use = data:toCardUse()
       	    if use.card:getSkillName()==self:objectName()
			then
				for _,to in sgs.list(use.to)do
					to:setFlags("jl_qixi")
				end
			end
		else
			local use = data:toCardUse()
       	    if use.card:getSkillName()==self:objectName()
			then
				for _,to in sgs.list(use.to)do
					to:setFlags("-jl_qixi")
				end
			end
		end
		return false
	end
}
jl_ningma:addSkill(jl_qixi)
jl_fenwei = sgs.CreateTriggerSkill{
	name = "jl_fenwei",
	frequency = sgs.Skill_Limited,
	limit_mark = "@jl_fenwei",
	events = {sgs.TargetConfirmed},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.TargetConfirmed
		then
			local use = data:toCardUse()
			player:setTag("jl_fenwei",data)
       	    if player:getMark("@jl_fenwei")>0
			and use.to:length()>1 and use.card:getTypeId()~=0
			and player:askForSkillInvoke(self:objectName(),sgs.QVariant("jl_fenwei0:"..use.card:objectName()))
			then
		       	room:broadcastSkillInvoke("fenwei")
				room:doSuperLightbox(player:getGeneralName(),self:objectName())
				room:removePlayerMark(player,"@jl_fenwei")
				local list = use.nullified_list
				for _,to in sgs.list(use.to)do
					table.insert(list,to:objectName())
				end
 				use.nullified_list = list
				data:setValue(use)
				room:obtainCard(player,use.card)
			end
		end
		return false
	end
}
jl_ningma:addSkill(jl_fenwei)

jl_zhangjiao = sgs.General(extension,"jl_zhangjiao$","qun",3,false)
jl_leiji = sgs.CreateTriggerSkill{
	name = "jl_leiji",
	events = {sgs.TargetConfirmed},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.TargetConfirmed
		then
			local use = data:toCardUse()
       	    if use.card:isKindOf("Slash")
			and (use.to:contains(player) or use.from:objectName()==player:objectName())
			and player:askForSkillInvoke(self:objectName(),data)
			then
		       	room:broadcastSkillInvoke(self:objectName())
				local judge = sgs.JudgeStruct()
               	judge.pattern = ".|heart"
	           	judge.good = true
	           	judge.reason = self:objectName()
               	judge.who = player
	           	room:judge(judge)
				if judge:isGood()
				then
					judge = room:askForPlayerChosen(player,room:getAlivePlayers(),self:objectName(),"jl_leiji0:",true,true)
					if judge then room:recover(judge,sgs.RecoverStruct(player,nil,2)) end
				end
			end
		end
		return false
	end
}
jl_zhangjiao:addSkill(jl_leiji)
jl_guidao = sgs.CreateTriggerSkill{
	name = "jl_guidao" ,
	events = {sgs.AskForRetrial} ,
	can_trigger = function(self,target)
		if not (target and target:isAlive() and target:hasSkill(self)) then return end
		if target:isKongcheng()
		then
			for _,e in sgs.list(target:getEquips())do
				if e:isRed() then return true end
			end
		else
			return true
		end
	end ,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local judge = data:toJudge()
		local card = room:askForCard(player,".|red","jl_guidao0:",data,sgs.Card_MethodResponse,judge.who,true)
		if card
		then
			room:broadcastSkillInvoke(self:objectName())
			room:retrial(card,player,judge,self:objectName(),true)
		end
		return false
	end
}
jl_zhangjiao:addSkill(jl_guidao)
jl_huangtianCard = sgs.CreateSkillCard{
	name = "jl_huangtianCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		return to_select:hasLordSkill("jl_huangtian")
		and #targets<1
	end,
	about_to_use = function(self,room,use)
		local zhangjiao = use.to:at(0)
		room:broadcastSkillInvoke("jl_huangtian")--播放配音
		room:doAnimate(1,use.from:objectName(),zhangjiao:objectName())
		room:notifySkillInvoked(zhangjiao,"jl_huangtian")
		local msg = sgs.LogMessage()
		msg.type = "$bf_huangtian0"
		msg.from = use.from
		msg.arg = zhangjiao:getGeneralName()
		msg.arg2 = "jl_huangtian"
		room:sendLog(msg)
		zhangjiao:obtainCard(self,false)
		use.from:addHistory("#jl_huangtianCard")
	end
}
jl_huangtianVS = sgs.CreateViewAsSkill{
	name = "jl_huangtianvs&",
	n = 1,
	view_filter = function(self,selected,to_select)
		return to_select:isKindOf("Slash")
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = jl_huangtianCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return player:usedTimes("#jl_huangtianCard")<1
		and player:isMale()
	end,
}
jl_huangtian = sgs.CreateTriggerSkill{
	name = "jl_huangtian$",
	events = {sgs.EventAcquireSkill,sgs.CardsMoveOneTime},
--	view_as_skill = jl_qunliVS,
	can_trigger = function(self,target)
		return target and target:hasLordSkill(self)
	end ,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		for _,p in sgs.list(room:getOtherPlayers(player))do
			if p:hasSkill("jl_huangtianvs")
			or not p:isMale() then continue end
			room:attachSkillToPlayer(p,"jl_huangtianvs")
		end
	end,
}
jl_zhangjiao:addSkill(jl_huangtian)
addToSkills(jl_huangtianVS)

--[[
jl_chonger = sgs.General(extension,"jl_chonger","wei",3,false)
jl_renxinCard = sgs.CreateSkillCard{
	name = "jl_renxinCard",
	skill_name = "jl_renxin",
	filter = function(self,targets,to_select,from)
		return to_select:isWounded()
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
		for _,to in sgs.list(targets)do
			room:recover(to,sgs.RecoverStruct(source,self))
		end
	end
}
jl_renxin2 = sgs.CreateViewAsSkill{
	name = "jl_renxin2",
	n = 1,
	view_filter = function(self,selected,to_select)
		return to_select:isKindOf("EquipCard")
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = jl_renxinCard:clone()
		c:setUserString(pattern)
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		return #cards>0 and c
	end,
	enabled_at_play = function(self,player)
		return player:isAlive()
	end,
}
jl_chonger:addSkill(jl_renxin2)
jl_chengxiang2 = sgs.CreateTriggerSkill{
	name = "jl_chengxiang2",
	events = {sgs.HpRecover},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event==sgs.HpRecover
		then
       	    if player:askForSkillInvoke(self:objectName(),data)
			then
		       	room:broadcastSkillInvoke(self:objectName())
				local ids = room:getNCards(4,false)
				local move = sgs.CardsMoveStruct()
				move.card_ids = ids
				move.to = player
				move.to_place = sgs.Player_PlaceTable
				move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER,player:objectName(),self:objectName(),nil)
				room:moveCardsAtomic(move,true)
				YijiPreview(self,player,ids,true)
				local origin = sgs.IntList()
				for _,id in sgs.list(ids)do
					origin:append(id)
				end
				while room:askForYiji(player,ids,self:objectName(),true,true,true,-1,room:getAlivePlayers())do
					local cids = sgs.IntList()
					for _,id in sgs.list(origin)do
						if room:getCardPlace(id)~=sgs.Player_DrawPile
						then
							cids:append(id)
							ids:removeOne(id)
						end
					end
					YijiPreview(self,player,cids)
					origin = sgs.IntList()
					for _,id in sgs.list(ids)do
						origin:append(id)
					end
					if player:isDead() then return end
				end
				if ids:isEmpty() then return end
				origin = dummyCard()
				YijiPreview(self,player,ids)
				origin:addSubcards(ids)
				player:obtainCard(origin)
			end
		end
		return false
	end
}
jl_chonger:addSkill(jl_chengxiang2)
--]]

jl_weiyan = sgs.General(extension,"jl_weiyan","qun")
jl_yiyan = sgs.CreateTriggerSkill{
	name = "jl_yiyan" ,
	events = {sgs.Damaged,sgs.Damage,sgs.GameStart},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.GameStart
		then
			Skill_msg(self,player)
			local to = PlayerChosen(self,player,nil,"jl_yiyan0:")
			room:acquireSkill(to,"liegong")
		else
			local damage = data:toDamage()
			for i=1,damage.damage do
				local sp = sgs.SPlayerList()
				for i,p in sgs.list(room:getAlivePlayers())do
					if p:hasSkill("liegong")
					or p:hasSkill("tenyearliegong")
					then sp:append(p) end
				end
				if sp:isEmpty() then return end
				local to = room:askForPlayerChosen(player,sp,"jl_yiyan","jl_yiyan1:",true,true)
				if not to then return end
				room:broadcastSkillInvoke(self:objectName())
				if to:hasSkill("tenyearliegong")
				then
					room:detachSkillFromPlayer(to,"tenyearliegong")
					room:acquireSkill(to,"mobilemouliegong")
				elseif to:hasSkill("liegong")
				then
					room:detachSkillFromPlayer(to,"liegong")
					room:acquireSkill(to,"tenyearliegong")
				end
			end
		end
		return false
	end
}
jl_weiyan:addSkill(jl_yiyan)
jl_dingzhen = sgs.CreateTriggerSkill{
	name = "jl_dingzhen" ,
	events = {sgs.DamageCaused} , 
	can_trigger = function(self,target)
		return target and target:getRoom():findPlayerBySkillName("jl_dingzhen")
		and (target:hasSkill("liegong") or target:hasSkill("tenyearliegong") or target:hasSkill("mobilemouliegong"))
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.DamageCaused
		then
			local damage = data:toDamage()
			for i,owner in sgs.list(room:findPlayersBySkillName("jl_dingzhen"))do
				if damage.card and damage.card:isKindOf("Slash")
				and ToSkillInvoke(self,owner,player)
				then
					i = "jl_dingzhen1+jl_dingzhen2+beishui_choice=jl_dingzhen3"
					i = room:askForChoice(owner,"jl_dingzhen",i)
					if i=="jl_dingzhen1"
					then player:drawCardsList(1,self:objectName())
					elseif i=="jl_dingzhen2"
					then room:addPlayerHistory(player,damage.card:getClassName(),-1)
					else
						room:loseHp(owner,1,false,owner,"jl_dingzhen")
						player:drawCardsList(1,self:objectName())
						room:addPlayerHistory(player,damage.card:getClassName(),-1)
					end
				end
			end
		end
		return false
	end
}
jl_weiyan:addSkill(jl_dingzhen)

jl_mouliubei = sgs.General(extension,"jl_mouliubei$","shu")
jl_gaojianCard = sgs.CreateSkillCard{
	name = "jl_gaojianCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		if self:subcardsLength()<1 then return to_select:objectName()~=from:objectName() end
		return to_select:getMark("&jl_shouling")==self:subcardsLength()
	end,
	on_use = function(self,room,source,targets)
		for _,to in sgs.list(targets)do
			if self:subcardsLength()>=to:getMark("&jl_shouling")
			and self:subcardsLength()>0
			then
				room:giveCard(source,to,self,"jl_gaojian")
				source:gainMark("&jl_youshi",self:subcardsLength()+1)
			else
				for _,p in sgs.list(room:getAlivePlayers())do
					p:loseAllMarks("&jl_shouling")
				end
				to:gainMark("&jl_shouling")
				to:addMark("jl_shouling")
			end
		end
	end
}
jl_gaojianvs = sgs.CreateViewAsSkill{
	name = "jl_gaojian",
	n = 998,
	view_filter = function(self,selected,to_select)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		return pattern=="@@jl_gaojian"
	end,
	view_as = function(self,cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local c = jl_gaojianCard:clone()
	   	for _,ic in sgs.list(cards)do
	    	c:addSubcard(ic)
	   	end
		if pattern=="@@jl_gaojian" then return c end
		if sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_PLAY
		then pattern = sgs.Self:getTag("jl_gaojian"):toCard():objectName() end
		for d,p in sgs.list(pattern:split("+"))do
			c = sgs.Sanguosha:cloneCard(p)
			c:setSkillName("_jl_gaojian")
			if sgs.Self:isLocked(c)
			then continue end
			return c
		end
	end,
	enabled_at_play = function(self,player)
		for d,p in sgs.list(patterns)do
			d = PatternsCard(p)
			if d and d:isAvailable(player) and d:isKindOf("BasicCard")
			then return player:getMark("&jl_youshi")>1 end
		end
	end,
	enabled_at_response = function(self,player,pattern)
		if pattern=="@@jl_gaojian" then return true end
		for d,p in sgs.list(pattern:split("+"))do
			if table.contains(patterns,p)
			then
				d = dummyCard(p)
				return d and d:isKindOf("BasicCard")
				and player:getMark("&jl_youshi")>1
			end
		end
	end
}
jl_gaojian = sgs.CreateTriggerSkill{
	name = "jl_gaojian",
	events = {sgs.EventPhaseStart,sgs.PreCardUsed,sgs.PreCardResponded},
	view_as_skill = jl_gaojianvs,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseStart
		and player:getPhase()==sgs.Player_Play
	   	then room:askForUseCard(player,"@@jl_gaojian","jl_gaojian0:")
		elseif event==sgs.PreCardUsed
		then
	       	local use = data:toCardUse()
			if use.card:getTypeId()>0
			and use.card:getSkillName()=="jl_gaojian"
			then player:loseMark("&jl_youshi",2) end
		elseif event==sgs.PreCardResponded
		then
	       	local res = data:toCardResponse()
			if res.m_card:getSkillName()=="jl_gaojian"
			then player:loseMark("&jl_youshi",2) end
		end
		return false
	end
}
jl_gaojian:setGuhuoDialog("l")
jl_mouliubei:addSkill(jl_gaojian)
jl_gaojianbf = sgs.CreateTriggerSkill{
	name = "#jl_gaojianbf" ,
	events = {sgs.EventPhaseProceeding} , 
	can_trigger = function(self,target)
		return target and target:getMark("&jl_shouling")>0
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseProceeding
		and player:getPhase()==sgs.Player_Start
		then
			Skill_msg("jl_gaojian",player)
			player:gainMark("&jl_shouling")
		end
		return false
	end
}
jl_mouliubei:addSkill(jl_gaojianbf)
extension:insertRelatedSkills("jl_gaojian", "#jl_gaojianbf")
jl_qiangzhengCard = sgs.CreateSkillCard{
	name = "jl_qiangzhengCard",
	will_throw = false,
	target_fixed = true,
	about_to_use = function(self,room,use)
		for d,p in sgs.list(room:getAlivePlayers())do
			if p:getMark("jl_shouling")>0
			then use.to:append(p) end
		end
		self:cardOnUse(room,use)
	end,
	on_use = function(self,room,source,targets)
		room:doSuperLightbox(source:getGeneralName(),"jl_qiangzheng")
		room:removePlayerMark(source,"@jl_qiangzheng")
		for c,to in sgs.list(targets)do
			c = room:askForExchange(to,"jl_qiangzheng",2,2,true,"jl_qiangzheng0:"..source:objectName())
			room:giveCard(to,source,c,"jl_qiangzheng")
		end
		room:gainMaxHp(source)
		room:detachSkillFromPlayer(source,"jl_gaojian")
	end
}
jl_qiangzheng = sgs.CreateViewAsSkill{
	name = "jl_qiangzheng",
	frequency = sgs.Skill_Limited,
	limit_mark = "@jl_qiangzheng",
	view_as = function(self,cards)
		return jl_qiangzhengCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:getMark("@jl_qiangzheng")>0
	end,
}
jl_mouliubei:addSkill(jl_qiangzheng)
jl_duzhanCard = sgs.CreateSkillCard{
	name = "jl_duzhanCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		if #targets<1
		then return true
		elseif #targets<2
		then
			return to_select:inMyAttackRange(targets[1])
			and to_select:objectName()~=from:objectName()
			and to_select:getKingdom()==from:getKingdom()
			and to_select:getHp()>=from:getHp()
		end
	end,
	feasible = function(self,targets)
		return #targets>1
	end,
	about_to_use = function(self,room,use)
		local a,b = use.to:at(0),use.to:at(1)
		self:cardOnUse(room,use)
		if b:canSlash(a)
		and b:askForSkillInvoke("jl_duzhan1",ToData("jl_duzhan1:"..a:objectName()),false)
		then
			local d = dummyCard()
			d:setSkillName("_jl_duzhan")
			room:useCard(sgs.CardUseStruct(d,b,a))
			return
		end
		room:setPlayerMark(b,"&jl_duzhan",1)
	end,
}
jl_duzhanvs = sgs.CreateViewAsSkill{
	name = "jl_duzhan",
	view_as = function(self,cards)
		return jl_duzhanCard:clone()
	end,
	enabled_at_play = function(self,player)
		return false
	end,
	enabled_at_response = function(self,player,pattern)
		if pattern=="@@jl_duzhan" then return true end
	end
}
jl_duzhan = sgs.CreateTriggerSkill{
	name = "jl_duzhan$",
	events = {sgs.EventPhaseEnd},
	view_as_skill = jl_duzhanvs,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseEnd
		and player:getPhase()==sgs.Player_Play
	   	then
			room:askForUseCard(player,"@@jl_duzhan","jl_duzhan0:")
		end
		return false
	end
}
jl_duzhanbf = sgs.CreateTriggerSkill{
	name = "#jl_duzhanbf" ,
	events = {sgs.EventPhaseChanging} , 
	can_trigger = function(self,target)
		return target and target:getMark("&jl_duzhan")>0
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
		then
	     	local change = data:toPhaseChange()
			if change.to==sgs.Player_Play
			then
				Skill_msg("jl_duzhan",player)
				player:skip(sgs.Player_Play)
				room:removePlayerMark(player,"&jl_duzhan")
			end
		end
		return false
	end
}
jl_mouliubei:addSkill(jl_duzhan)
jl_mouliubei:addSkill(jl_duzhanbf)
extension:insertRelatedSkills("jl_duzhan", "#jl_duzhanbf")

jl_dengjiao = sgs.General(extension,"jl_dengjiao","qun")
jl_dengjiao:setStartHp(3)
jl_dengjiao:addSkill("olleiji")
jl_dengjiao:addSkill("olguidao")
jl_dengjiao:addSkill("mobiletuntian")

jl_guanning = sgs.General(extension,"jl_guanning","qun",7)
jl_guanning:setStartHp(3)
jl_dunshi = sgs.CreateTriggerSkill{
	name = "jl_dunshi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventAcquireSkill,sgs.CardsMoveOneTime,sgs.EventLoseSkill},
	on_trigger = function(self,event,player,data,room)
		local skills,els = {},{}
		for _,sk in sgs.list({"chongyi","tianyi","lilu","tongli","zhichi","renzheng","spqianxin"})do
			if player:hasSkill(sk) then table.insert(els,"-"..sk) continue end
			table.insert(skills,sk)
		end
		if event==sgs.EventLoseSkill
		and data:toString()=="jl_dunshi"
		then
			room:handleAcquireDetachSkills(player,table.concat(skills,"|"))
			return
		end
		if #skills<1 then return end
	   	room:sendCompulsoryTriggerLog(player,"jl_dunshi")
		room:handleAcquireDetachSkills(player,table.concat(skills,"|"))
	end,
}
jl_dunshibf = sgs.CreateTriggerSkill{
	name = "#jl_dunshibf" ,
	events = {sgs.Predamage}, 
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self,target)
		return true
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Predamage
		then
	     	local cu = room:getCurrent()
			if cu:getMark("jl_dunshibf-Clear")<1
			then
				for i,owner in sgs.list(room:findPlayersBySkillName("jl_dunshi"))do
					local damage = data:toDamage()
					cu:addMark("jl_dunshibf-Clear")
					room:sendCompulsoryTriggerLog(owner,"jl_dunshi")
					return DamageRevises(data,-damage.damage,damage.to)
				end
			end
		end
		return false
	end
}
jl_guanning:addSkill(jl_dunshi)
jl_guanning:addSkill(jl_dunshibf)
extension:insertRelatedSkills("jl_dunshi", "#jl_dunshibf")

jl_shenxiyun = sgs.General(extension,"jl_shenxiyun","god",3)
jl_shenxiyun:setStartHp(2)
jl_xiance = sgs.CreateTriggerSkill{
	name = "jl_xiance",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreHpRecover,sgs.DamageForseen,sgs.Damaged,sgs.FinishJudge},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.PreHpRecover
		then
			local rec = data:toRecover()
            room:sendCompulsoryTriggerLog(player,self:objectName())
          	room:broadcastSkillInvoke("xianfu")--播放配音
			rec.recover = rec.recover*2
			data:setValue(rec)
		elseif event==sgs.DamageForseen
		then
			local damage = data:toDamage()
            room:sendCompulsoryTriggerLog(player,self:objectName())
          	room:broadcastSkillInvoke("xianfu")--播放配音
			DamageRevises(data,damage.damage,player)
		elseif event==sgs.Damaged
		then
			local damage = data:toDamage()
			for i=1,damage.damage do
				room:sendCompulsoryTriggerLog(player,self:objectName())
				room:broadcastSkillInvoke("chouce")--播放配音
				local judge = sgs.JudgeStruct()
               	judge.pattern = ".|red,black"
	           	judge.good = true
	           	judge.reason = self:objectName()
               	judge.who = player
	           	room:judge(judge)
				i = player:getTag("JudgeCard_"..self:objectName()):toCard()
				if i:isRed() then player:drawCardsList(2,self:objectName())
				elseif i:isBlack()
				then
					i = sgs.SPlayerList()
					for _,p in sgs.list(room:getAlivePlayers())do
						if player:canDiscard(p,"hej")
						then i:append(p) end
					end
					if i:isEmpty() then continue end
					judge = PlayerChosen(self,player,i,"jl_xiance0:")
					i = room:askForCardChosen(player,judge,"hej","jl_xiance",false,sgs.Card_MethodDiscard)
					room:throwCard(i,judge,player)
				end
			end
		elseif event==sgs.FinishJudge
		then
			local judge = data:toJudge()
			if judge.reason==self:objectName()
			then
				player:obtainCard(judge.card)
			end
		end
	end,
}
jl_shenxiyun:addSkill(jl_xiance)
jl_juehunvs = sgs.CreateViewAsSkill{
	name = "jl_juehun" ,
	n = 1 ,
	view_filter = function(self,selected,to_select)
		if to_select:hasFlag("using") then return false end
		local pattern = sgs.Sanguosha:getCurrentCardUseReason()
		if pattern==sgs.CardUseStruct_CARD_USE_REASON_PLAY
		then
			if to_select:getSuit()==2
			then
				pattern = dummyCard("peach")
				pattern:setSkillName("jl_juehun")
				pattern:addSubcard(to_select)
				return pattern:isAvailable(sgs.Self)
			elseif to_select:getSuit()==3
			then
				pattern = dummyCard("fire_slash")
				pattern:setSkillName("jl_juehun")
				pattern:addSubcard(to_select)
				return pattern:isAvailable(sgs.Self)
			end
		elseif pattern==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE
		or pattern==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
		then
			pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if string.find(pattern,"jink")
			then return to_select:getSuit()==1
			elseif string.find(pattern,"nullification")
			then return to_select:getSuit()==0
			elseif string.find(pattern,"peach")
			then return to_select:getSuit()==2
			elseif string.find(pattern,"slash")
			then return to_select:getSuit()==3 end
		end
	end ,
	view_as = function(self,cards)
		if #cards<1 then return end
		local new_card = "fire_slash"
		if cards[1]:getSuit()==0 then new_card = "nullification"
		elseif cards[1]:getSuit()==2 then new_card = "peach"
		elseif cards[1]:getSuit()==1 then new_card = "jink" end
		new_card = sgs.Sanguosha:cloneCard(new_card)
		new_card:setSkillName(self:objectName())
		for _,c in ipairs(cards) do
			new_card:addSubcard(c)
		end
		return new_card
	end ,
	enabled_at_play = function(self,player)
		local cs = player:getHandcards()
		for _,c in sgs.qlist(player:getEquips())do
			cs:append(c)
		end
		for _,c in sgs.qlist(cs)do
			if c:getSuit()==2
			then
				pattern = dummyCard("peach")
				pattern:setSkillName("jl_juehun")
				pattern:addSubcard(c)
				if pattern:isAvailable(player)
				then return true end
			elseif c:getSuit()==3
			then
				pattern = dummyCard("fire_slash")
				pattern:setSkillName("jl_juehun")
				pattern:addSubcard(c)
				if pattern:isAvailable(player)
				then return true end
			end
		end
	end,
	enabled_at_response = function(self,player,pattern)
		return string.find(pattern,"slash") or string.find(pattern,"jink")
		or string.find(pattern,"peach") and player:getMark("Global_PreventPeach")<1
		or string.find(pattern,"nullification")
	end,
	enabled_at_nullification = function(self,player)
		local count = player:getHandcardNum()
		for _,card in sgs.qlist(player:getEquips()) do
			if card:getSuit()==0 then count = count+1 end
		end
		if count>0 then return true end
	end
}
jl_juehun = sgs.CreateTriggerSkill{
	name = "jl_juehun",
	view_as_skill = jl_juehunvs,
	events = {sgs.EnterDying,sgs.QuitDying,sgs.DrawNCards,sgs.TurnStart},
	on_trigger = function(self,event,player,data,room)
		if event==sgs.DrawNCards
		then
			Skill_msg(self,player)
			room:broadcastSkillInvoke("juejing")
			local n = data:toInt()
			data:setValue(n+2)
		elseif event==sgs.TurnStart
		then room:addMaxCards(player,2)
		else
			Skill_msg(self,player)
			room:broadcastSkillInvoke("juejing")
			player:drawCardsList(1,self:objectName())
		end
		return false
	end
}
jl_shenxiyun:addSkill(jl_juehun)











--缤芬模式 -- ai有概率会犯病 ^…^
jl_bingfen1 = { --乱用技能 ~ 20%
	"呃....点错了",
	"哎呀，手快了",
	"骚瑞，我的我的",
	"恩？啊，看错了",
	"怎么回事？",
	".....",
	"。。。",
	"忘了呢",
	"啊这",
	"hhhh",
	"hhhhhh",
	"eeee",
	"emmmmm.....",
	"emmm...",
	"啊。。没看清",
	"啊巴啊巴",
	"我不对劲",
	"哎。。不对。。。",
}
jl_bingfen2 = { --出牌中断 ~ 30%
	"不....这破代码",
	"我....已无牌可出",
	"牌太多了，直接结束",
	"额，碰到特色了？",
	"累了，丢了吧",
	"怎么回事？",
	"这，卡了？",
	"不对，我还有牌没出",
	"啊啊啊...我大把的好牌",
	"???...",
	"???? 怎么结束了",
	"???? 这破代码....",
	"不...不可以....",
	"蒸能如此对我。。。",
	"怎么蒸起来了。。。",
	"蒸。。。",
	"就差一点了。。。。",
	"****的",
	"你****",
	"emmm...",
	"emmmm....",
	"........",
	".....",
}
jl_bingfen3 = { --深情鞭尸 ~ 35%
	"你还不能走！！",
	"这大好的局面，就留下来吧",
	"此千年老尸，岂不鞭之",
	"不行没有你就不好玩了",
	"直接死了多没意思",
	"嘿就是玩",
	"记住，我救的",
	"我桃就是批发的",
	"阿这点错了信吗",
	"23333",
	"2333333333",
	"手快了",
	"随便玩玩",
	"hhh",
	"hhhhhh",
	"           ",
	"留着，让我来",
	"         ",
	"就这样没了，岂不可惜",
	"鞭啊鞭~~~",
	"祖传的鞭法，也就偶尔一用",
	"要相信我",
	"笑死我了",
	"♥♥♥",
	"。。。。。"
}
jl_bingfen4 = {
	"你个存货",
	"你他***的",
	"会不会看技能？",
	"脑瘫儿？",
	"我也是醉了.....",
	"。。。。。。。。",
	"。。。。。",
	"存货",
	"什么牛马？",
	"连技能都不看",
	"累了，投敌吧",
	"？？？",
	"？？？？？？？？？",
	"我开始慌了",
	"怎么有这种队友",
	"存心的吧？",
	"你奸细的吧？",
	"我**你****",
	"有点问题",
	"怎么随到这种队友",
	"！！！！！",
	"！！!",
	"你这有病吧？",
	"",
	"",
	"",
	"",
	""
}
jl_bingfen5 = {
	"好，很好，非常好！",
	"好，好极了",
	"没想到啊",
	"真~天助我",
	"继续啊",
	"继续保持",
	"请继续保持这样",
	"我相信你",
	"好，好兄弟",
	"感谢你为了大义",
	"无比正确的选择",
	"刷新认知了",
	"真心离谱",
	"是谁派出了我方的奸细~~~",
	"OoO!",
	"!!!!",
	"可以啊",
	"我想起了一些开心的事(/≧▽≦)/",
	"这波助攻啊",
	"",
	"",
	"",
	"",
	""
}
				--敌我不分 ~ 人数*5%

jl_wangbaTr = sgs.CreateTriggerSkill{
	name = "jl_wangba",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted,sgs.CardEffected,sgs.CardAsked},
	can_trigger = function(self,target)
		return target and target:hasArmorEffect("jl_wangba")
		and ArmorNotNullified(target)
	end,
	on_trigger = function(self,event,player,data,room)
    	if event==sgs.DamageInflicted
		then
		    local damage = data:toDamage()
            if damage.nature==sgs.DamageStruct_Fire
			then
                room:sendCompulsoryTriggerLog(player,"jl_wangba")
	         	room:setEmotion(player,"armor/jl_wangba2")
    	        DamageRevises(data,1,player)
			end
		    damage = data:toDamage()
        	if damage.damage>1
        	then
	        	room:sendCompulsoryTriggerLog(player,"jl_wangba")
	         	room:setEmotion(player,"armor/jl_wangba1")
		    	DamageRevises(data,1-damage.damage,player)
			end
		elseif event==sgs.CardAsked
		then
    		local pattern = data:toStringList()[1]
    		if string.find(pattern,"jink")
        	and room:askForSkillInvoke(player,"jl_wangba",data)
			then
		       	local judge = sgs.JudgeStruct()
               	judge.pattern = ".|red"
	           	judge.good = true
	           	judge.reason = "jl_wangba"
               	judge.who = player
	           	room:judge(judge)
				if judge:isGood()
				then
	            	judge = sgs.Sanguosha:cloneCard("jink")
	             	judge:setSkillName("_jl_wangba")
	            	room:setEmotion(player,"armor/jl_wangba1")
			    	room:provide(judge)
				end
			end
    	elseif event==sgs.CardEffected
		then
            local effect = data:toCardEffect()
			if effect.card:isKindOf("Slash")
			and effect.card:isBlack()
			then
	        	room:sendCompulsoryTriggerLog(player,"jl_wangba")
	         	room:setEmotion(player,"armor/jl_wangba1")
	    		effect.nullified = true
			end
			if effect.card:objectName()=="slash"
			or effect.card:isKindOf("ArcheryAttack")
			or effect.card:isKindOf("SavageAssault")
			then
	        	room:sendCompulsoryTriggerLog(player,"jl_wangba")
	         	room:setEmotion(player,"armor/jl_wangba1")
	    		effect.nullified = true
			end
	    	data:setValue(effect)
		end
		return false
	end
}
jl_wangba = sgs.CreateArmor{
	name = "jl_wangba",
	class_name = "JlWangba",
	on_install = function(self,player)
		local room = player:getRoom()
		room:acquireSkill(player,jl_wangbaTr,false,true,false)
		return false
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player,"jl_wangba",true,true)
		if player:isWounded()
		and player:isAlive()
		then
	     	room:sendCompulsoryTriggerLog(player,"jl_wangba")
	       	room:setEmotion(player,"armor/jl_wangba1")
	    	room:recover(player,sgs.RecoverStruct(player,self))
		end
		return false
	end,
}
jl_wangba:clone(2,13):setParent(extensioncard)

jl_liushen = sgs.CreateArmor{
	name = "jl_liushen",
	class_name = "JlLiushen",
	on_install = function(self,player)
		local room = player:getRoom()
		local name = player:getGeneralName()
		if name=="guanyu"
		or name=="lvbu"
		or name=="lvmeng"
		or name=="zhugeliang"
		or name=="caocao"
		or name=="zhouyu"
		then
	        room:sendCompulsoryTriggerLog(player,"jl_liushen")
	    	room:changeHero(player,"shen"..name,false)
			player:setTag("jl_liushen",sgs.QVariant(name))
		end
--		room:acquireSkill(player,jl_liushenTr)
		return false
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		local name = player:getTag("jl_liushen"):toString()
		if name~=""
		then
	        room:sendCompulsoryTriggerLog(player,"jl_liushen")
	        room:changeHero(player,name,false)
		end
--		room:detachSkillFromPlayer(player,"#jl_liushenTr",true,true)
		return false
	end,
}
jl_liushen:clone(2,6):setParent(extensioncard)

jl_guanbingcjTr = sgs.CreateTriggerSkill{
	name = "jl_guanbingcj",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed,sgs.DamageCaused,sgs.SlashMissed,sgs.PreCardUsed},
	can_trigger = function(self,target)
		return target and target:hasWeapon("jl_guanbingcj")
	end,
	on_trigger = function(self,event,player,data,room)
   		if event==sgs.CardUsed
	   	then
	       	local use,can = data:toCardUse(),false
	       	if use.card:isKindOf("Slash") 
	       	then
	           	for _,to in sgs.list(use.to)do
			    	to:addQinggangTag(use.card)
    	           	if to:getArmor() then can = to end
	           	end
				if can
				then
                    room:sendCompulsoryTriggerLog(player,"jl_guanbingcj")
	             	room:setEmotion(player,"weapon/jl_guanbingcj")
				end
	       	end
		elseif event==sgs.PreCardUsed
	   	then
	       	local use = data:toCardUse()
	       	if use.card:isKindOf("Slash")
			and use.card:subcardsLength() >= player:getHandcardNum()
			and use.to:length()>1
			then
	         	room:setEmotion(player,"weapon/jl_guanbingcj")
			end
		elseif event==sgs.SlashMissed
		then
			local effect = data:toSlashEffect()
			effect.from:setTag("SlashEffect",data)
			if effect.jink and effect.slash:isKindOf("Slash") and effect.to:isAlive()
			and room:askForDiscard(effect.from,"jl_guanbingcj",2,2,true,true,"@guanbing:jl_guanbingcj:"..effect.slash:objectName(),"^JlGuanbingcj","jl_guanbingcj")
			then
	         	room:setEmotion(effect.from,"weapon/jl_guanbingcj")
                room:slashResult(effect,nil)
			end
    	elseif event==sgs.DamageCaused
		then
		    local damage = data:toDamage()
        	if damage.card and damage.card:isKindOf("Slash")
			and damage.to:isKongcheng()
        	then
	        	room:sendCompulsoryTriggerLog(player,"jl_guanbingcj")
	         	room:setEmotion(player,"weapon/jl_guanbingcj")
		    	DamageRevises(data,1,player)
			end
			damage = data:toDamage()
			player:setTag("SlashDamage",data)
        	if damage.card and damage.card:isKindOf("Slash") and damage.to:getCardCount()>0
	       	and room:askForSkillInvoke(player,"jl_guanbingcj",sgs.QVariant("choice4:"..damage.to:objectName()))--double_sword
			then
	         	room:setEmotion(player,"weapon/jl_guanbingcj")
 				for i = 1,2 do
       	        	if damage.to:isNude() then break end
			    	i = room:askForCardChosen(player,damage.to,"he","jl_guanbingcj")
				   	room:throwCard(i,damage.to,player)
				end
				return DamageRevises(data,-damage.damage,player)
			end
		end
		return false
	end
}
jl_guanbingcj = sgs.CreateWeapon{
	name = "jl_guanbingcj",
	class_name = "JlGuanbingcj",
	range = 13,
	on_install = function(self,player)
		local room = player:getRoom()
		room:acquireSkill(player,jl_guanbingcjTr,false,true,false)
		return false
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player,"jl_guanbingcj",true,true)
		return false
	end,
}
jl_guanbingcj:clone(1,1):setParent(extensioncard)

jl_qiefudaocard = sgs.CreateSkillCard{
	name = "jl_qiefudaocard",
	will_throw = false,
	filter = function(self,targets,to_selec,source)
		return to_selec:objectName()==source:objectName()
	   	and not source:isProhibited(source,sgs.Sanguosha:getCard(self:getSubcards():at(0)))
		and #targets<1
	end,
	on_validate = function(self,use)
		return sgs.Sanguosha:getCard(self:getSubcards():at(0))
	end,
}
jl_qiefudaoTr = sgs.CreateViewAsSkill{
	name = "jl_qiefudao",
	n = 1,
	view_filter = function(self,selected,to_select)
       	return to_select:isKindOf("Slash")
	end,
	view_as = function(self,cards)
	   	if #cards<1 then return end
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		pattern = jl_qiefudaocard:clone()
	   	for _,cid in sgs.list(cards)do
	   	    pattern:addSubcard(cid)
	   	end
		return pattern
	end,
	enabled_at_response = function(self,player,pattern)
		return string.find(pattern,"slash")
		and sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
	end,
	enabled_at_play = function(self,player)
		return sgs.Slash_IsAvailable(player)
	end,
}
jl_qiefudao = sgs.CreateWeapon{
	name = "jl_qiefudao",
	class_name = "JlQiefudao",
	range = 1,
	on_install = function(self,player)
		local room = player:getRoom()
		player:insertAttackRangePair(player)
		room:attachSkillToPlayer(player,"jl_qiefudao")
		return false
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		player:removeAttackRangePair(player)
		room:detachSkillFromPlayer(player,"jl_qiefudao",true,true)
		return false
	end,
}
jl_qiefudao:clone(1,9):setParent(extensioncard)
addToSkills(jl_qiefudaoTr)

jl_bingyuegongTrVS = sgs.CreateViewAsSkill{
	name = "jl_bingyuegong",
	n = 2,
	view_filter = function(self,selected,to_select)
       	return not to_select:isEquipped()
	end,
	view_as = function(self,cards)
	   	if #cards<2 then return end
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
       	pattern = sgs.Sanguosha:cloneCard("slash")
	   	pattern:setSkillName("jl_bingyuegong")
	   	for _,cid in sgs.list(cards)do
	   	    pattern:addSubcard(cid)
	   	end
		return pattern
	end,
	enabled_at_response = function(self,player,pattern)
		return string.find(pattern,"slash")
		and player:getHandcardNum()>1
	end,
	enabled_at_play = function(self,player)
		return player:getHandcardNum()>1
		and sgs.Slash_IsAvailable(player)
	end,
}
jl_bingyuegongTr = sgs.CreateTriggerSkill{
	name = "jl_bingyuegong",
	frequency = sgs.Skill_Compulsory,
	view_as_skill = jl_bingyuegongTrVS,
	events = {sgs.TargetSpecifying,sgs.ChangeSlash,sgs.DamageCaused,
	sgs.SlashMissed,sgs.CardResponded,sgs.CardFinished},
	can_trigger = function(self,target)
		return target and target:hasWeapon("jl_bingyuegong")
	end,
	on_trigger = function(self,event,player,data,room)
   		if event==sgs.TargetSpecifying
	   	then
	       	local use,can = data:toCardUse(),false
	       	if use.card:isKindOf("Slash") 
	       	then
	           	for _,to in sgs.list(use.to)do
			   		to:addQinggangTag(use.card)
    	           	if to:getArmor() then can = to end
	           	end
				if can
				then
                    room:sendCompulsoryTriggerLog(player,"jl_bingyuegong")
	             	room:setEmotion(player,"weapon/jl_bingyuegong")
				end
	           	for _,to in sgs.list(use.to)do
   	             	if to:getGender()~=player:getGender()
	         		and room:askForSkillInvoke(player,"jl_bingyuegong",sgs.QVariant("choice1:"..to:objectName()))--double_sword
					and not room:askForDiscard(to,"jl_bingyuegong",1,1,true,false,"@bingyueg:jl_bingyuegong:"..player:objectName())
					then player:drawCards(1,self:objectName()) end
	           	end
	       	end
		elseif event==sgs.ChangeSlash
	   	then
	       	local use = data:toCardUse()
	       	if use.card:isKindOf("Slash")
			and use.card:subcardsLength()>=player:getHandcardNum()
			and use.to:length()>1
			then
	         	room:setEmotion(player,"weapon/jl_bingyuegong")
			end
			local tos = {}
	       	for _,to in sgs.list(use.to)do
    	        table.insert(tos,to:objectName())
	       	end
			if use.card:objectName()=="slash"
			and room:askForSkillInvoke(player,"jl_bingyuegong",sgs.QVariant("choice2:slash:"..table.concat(tos,"+")),false)--fan
	       	then
	        	tos = sgs.Sanguosha:cloneCard("fire_slash")
	        	tos:setSkillName("jl_bingyuegong")
				if use.card:isVirtualCard()
				then tos:addSubcards(use.card:getSubcards())
				else tos:addSubcard(use.card) end
	         	room:setEmotion(player,"weapon/jl_bingyuegong")
				use.card = tos
				data:setValue(use)
	       	end
		elseif event==sgs.SlashMissed
		then
			local effect = data:toSlashEffect()
			effect.from:setTag("SlashEffect",data)
			if effect.jink and effect.slash:isKindOf("Slash") and effect.to:isAlive()
			and room:askForDiscard(effect.from,"jl_bingyuegong",2,2,true,true,"@guanbing:jl_bingyuegong:"..effect.slash:objectName(),"^JlBingyuegong","jl_bingyuegong")
			then
	         	room:setEmotion(effect.from,"weapon/jl_bingyuegong")
                room:slashResult(effect,nil)
			end
			if effect.jink and effect.slash:isKindOf("Slash") and effect.to:isAlive()
			then
	    		room:askForUseSlashTo(effect.from,effect.to,"@bingyuegong-slash:"..effect.to:objectName())
			end
    	elseif event==sgs.DamageCaused
		then
		    local damage = data:toDamage()
        	if damage.card and damage.card:isKindOf("Slash")
			and damage.to:isKongcheng()
        	then
	        	room:sendCompulsoryTriggerLog(player,"jl_bingyuegong")
	         	room:setEmotion(player,"weapon/jl_bingyuegong")
		    	DamageRevises(data,1,player)
			end
			damage = data:toDamage()
            local give,dh,oh = {},damage.to:getDefensiveHorse(),damage.to:getOffensiveHorse()
        	if damage.card and damage.card:isKindOf("Slash") and (dh or oh)
			and room:askForSkillInvoke(player,"jl_bingyuegong",sgs.QVariant("choice3:"..damage.to:objectName()))--kylin_bow
        	then
	    		if dh then table.insert(give,"DefensiveHorse") end
				if oh then table.insert(give,"OffensiveHorse") end
		     	give = room:askForChoice(player,"jl_bingyuegong",table.concat(give,"+"))
		    	if give=="DefensiveHorse" then room:throwCard(dh,damage.to,player)
				elseif give=="OffensiveHorse" then room:throwCard(oh,damage.to,player) end
			end
			player:setTag("SlashDamage",data)
        	if damage.card and damage.card:isKindOf("Slash") and damage.to:getCardCount()>0
			and room:askForSkillInvoke(player,"jl_bingyuegong",sgs.QVariant("choice4:"..damage.to:objectName()))--ice_sword
			then
	         	room:setEmotion(player,"weapon/jl_bingyuegong")
 				for i = 1,2 do
       	        	if damage.to:getCardCount()>0
					then
			    		i = room:askForCardChosen(player,damage.to,"he","jl_bingyuegong",false,sgs.Card_MethodDiscard)
				    	room:throwCard(i,damage.to,player)
					end
				end
				return DamageRevises(data,-damage.damage,player)
			end
		end
		local card
		if event==sgs.CardResponded
		then card = data:toCardResponse().m_card
		elseif event==sgs.CardFinished
		then card = data:toCardUse().card end
		if card and card:isBlack() and player:getPhase()==sgs.Player_NotActive
		then room:askForUseCard(player,"slash","@jl_bingyuegong:jl_bingyuegong") end
	end
}
jl_bingyuegong = sgs.CreateWeapon{
	name = "jl_bingyuegong",
	class_name = "JlBingyuegong",
	range = 5,
	on_install = function(self,player)
		local room = player:getRoom()
		room:acquireSkill(player,jl_bingyuegongTr,true,true,false)
		return false
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player,"jl_bingyuegong",true,true)
		return false
	end,
}
jl_bingyuegong:clone(1,1):setParent(extensioncard)
addToSkills(jl_bingyuegongTrVS)

jl_yanlinmaoTrVS = sgs.CreateViewAsSkill{
	name = "jl_yanlinmao",
	n = 2,
	view_filter = function(self,selected,to_select)
       	return not to_select:isEquipped()
	end,
	view_as = function(self,cards)
	   	if #cards<2 then return end
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
       	pattern = sgs.Sanguosha:cloneCard("slash")
	   	pattern:setSkillName("jl_yanlinmao")
	   	for _,cid in sgs.list(cards)do
	   	    pattern:addSubcard(cid)
	   	end
		return pattern
	end,
	enabled_at_response = function(self,player,pattern)
		return string.find(pattern,"slash")
		and player:getHandcardNum()>1
	end,
	enabled_at_play = function(self,player)
		return player:getHandcardNum()>1
		and sgs.Slash_IsAvailable(player)
	end,
}
jl_yanlinmaoTr = sgs.CreateTriggerSkill{
	name = "jl_yanlinmao",
	frequency = sgs.Skill_Compulsory,
	view_as_skill = jl_yanlinmaoTrVS,
	events = {sgs.TargetSpecifying,sgs.ChangeSlash,sgs.DamageCaused,sgs.SlashMissed},
	can_trigger = function(self,target)
		return target and target:hasWeapon("jl_yanlinmao")
	end,
	on_trigger = function(self,event,player,data,room)
   		if event==sgs.TargetSpecifying
	   	then
	       	local use,can = data:toCardUse(),false
	       	if use.card:isKindOf("Slash") 
	       	then
	           	for _,to in sgs.list(use.to)do
			   		to:addQinggangTag(use.card)
    	           	if to:getArmor() then can = to end
	           	end
				if can
				then
                    room:sendCompulsoryTriggerLog(player,"jl_yanlinmao")
	             	room:setEmotion(player,"weapon/jl_yanlinmao")
				end
	           	for _,to in sgs.list(use.to)do
   	             	if to:getGender()~=player:getGender()
	         		and room:askForSkillInvoke(player,"jl_yanlinmao",sgs.QVariant("choice1:"..to:objectName()))--double_sword
					and not room:askForDiscard(to,"jl_yanlinmao",1,1,true,false,"@bingyueg:jl_yanlinmao:"..player:objectName())
					then player:drawCards(1,self:objectName()) end
	           	end
	       	end
		elseif event==sgs.ChangeSlash
	   	then
	       	local use = data:toCardUse()
	       	if use.card:isKindOf("Slash")
			and use.card:subcardsLength()>=player:getHandcardNum()
			and use.to:length()>1
			then
	         	room:setEmotion(player,"weapon/jl_yanlinmao")
			end
			local tos = {}
	       	for _,to in sgs.list(use.to)do
    	        table.insert(tos,to:objectName())
	       	end
	       	if use.card:objectName()=="slash"
	       	and room:askForSkillInvoke(player,"jl_yanlinmao",sgs.QVariant("choice2:slash:"..table.concat(tos,"+")),false)--double_sword
	       	then
	        	tos = sgs.Sanguosha:cloneCard("fire_slash")
	        	tos:setSkillName("jl_yanlinmao")
				if use.card:isVirtualCard()
				then tos:addSubcards(use.card:getSubcards())
				else tos:addSubcard(use.card) end
	         	room:setEmotion(player,"weapon/jl_yanlinmao")
				use.card = tos
				data:setValue(use)
	       	end
		elseif event==sgs.SlashMissed
		then
			local effect = data:toSlashEffect()
			effect.from:setTag("SlashEffect",data)
			if effect.jink and effect.slash:isKindOf("Slash") and effect.to:isAlive()
			and room:askForDiscard(effect.from,"jl_yanlinmao",2,2,true,true,"@guanbing:jl_yanlinmao:"..effect.slash:objectName(),"^JlYanlinmao","jl_yanlinmao")
			then
	         	room:setEmotion(effect.from,"weapon/jl_yanlinmao")
                room:slashResult(effect,nil)
			end
			if effect.jink and effect.to:isAlive()
			and effect.slash:isKindOf("Slash")
			then
				room:askForUseSlashTo(effect.from,effect.to,"@bingyuegong-slash:"..effect.to:objectName())
			end
    	elseif event==sgs.DamageCaused
		then
		    local damage = data:toDamage()
        	if damage.card and damage.to:isKongcheng()
			and damage.card:isKindOf("Slash")
        	then
	        	room:sendCompulsoryTriggerLog(player,"jl_yanlinmao")
	         	room:setEmotion(player,"weapon/jl_yanlinmao")
		    	DamageRevises(data,1,player)
			end
			damage = data:toDamage()
   	    	local todata = sgs.QVariant()
       		todata:setValue(damage.to)
            local give,dh,oh = {},damage.to:getDefensiveHorse(),damage.to:getOffensiveHorse()
        	if damage.card and damage.card:isKindOf("Slash") and (dh or oh)
	       	and room:askForSkillInvoke(player,"jl_yanlinmao",ToData("choice3:"..damage.to:objectName()))--double_sword
        	then
	         	room:setEmotion(player,"weapon/jl_yanlinmao")
	    		if dh then table.insert(give,"DefensiveHorse") end
				if oh then table.insert(give,"OffensiveHorse") end
		     	give = room:askForChoice(player,"jl_yanlinmao",table.concat(give,"+"))
		    	if give=="DefensiveHorse" then room:throwCard(dh,damage.to,player)
				elseif give=="OffensiveHorse" then room:throwCard(oh,damage.to,player) end
			end
			player:setTag("SlashDamage",data)
        	if damage.card and damage.card:isKindOf("Slash") and damage.to:getCardCount()>0
	       	and room:askForSkillInvoke(player,"jl_yanlinmao",ToData("choice4:"..damage.to:objectName()))--double_sword
			then
	         	room:setEmotion(player,"weapon/jl_yanlinmao")
 				for i = 1,2 do
       	        	if damage.to:getCardCount()>0
					then
			    		i = room:askForCardChosen(player,damage.to,"he","jl_yanlinmao",false,sgs.Card_MethodDiscard)
				    	room:throwCard(i,damage.to,player)
					end
				end
				return DamageRevises(data,-damage.damage,player)
			end
		end
		return false
	end
}
jl_yanlinmao = sgs.CreateWeapon{
	name = "jl_yanlinmao",
	class_name = "JlYanlinmao",
	range = 5,
	on_install = function(self,player)
		local room = player:getRoom()
		room:acquireSkill(player,jl_yanlinmaoTr,true,true,false)
		return false
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player,"jl_yanlinmao",true,true)
		return false
	end,
}
jl_yanlinmao:clone(1,6):setParent(extensioncard)--【开不了车】大神的作品
addToSkills(jl_yanlinmaoTrVS)

jl_yushanssTrVS = sgs.CreateViewAsSkill{
	name = "jl_yushanss",
	n = 2,
	view_filter = function(self,selected,to_select)
       	return not to_select:isEquipped()
	end,
	view_as = function(self,cards)
	   	if #cards<2 then return end
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
       	pattern = sgs.Sanguosha:cloneCard("slash")
	   	pattern:setSkillName("jl_yushanss")
	   	for _,cid in sgs.list(cards)do
	   	    pattern:addSubcard(cid)
	   	end
		return pattern
	end,
	enabled_at_response = function(self,player,pattern)
		return string.find(pattern,"slash")
		and player:getHandcardNum()>1
	end,
	enabled_at_play = function(self,player)
		return player:getHandcardNum()>1
		and sgs.Slash_IsAvailable(player)
	end,
}
jl_yushanssTr = sgs.CreateTriggerSkill{
	name = "jl_yushanss",
	view_as_skill = jl_yushanssTrVS,
	events = {sgs.TargetSpecifying,sgs.ChangeSlash,sgs.SlashMissed},
	can_trigger = function(self,target)
		return target and target:hasWeapon("jl_yushanss")
	end,
	on_trigger = function(self,event,player,data,room)
   		if event==sgs.TargetSpecifying
	   	then
	       	local use = data:toCardUse()
	       	if use.card:isKindOf("Slash") 
	       	then
	           	for _,to in sgs.list(use.to)do
   	             	if to:getGender()~=player:getGender()
	            	and room:askForSkillInvoke(player,"jl_yushanss",sgs.QVariant("choice1:"..to:objectName()))
					and not room:askForDiscard(to,"jl_yushanss",1,1,true,false,"@bingyueg:jl_yushanss:"..player:objectName())
					then player:drawCards(1,self:objectName()) end
	           	end
	       	end
		elseif event==sgs.ChangeSlash
	   	then
			local tos = {}
	       	local use = data:toCardUse()
	       	for _,to in sgs.list(use.to)do
    	        table.insert(tos,to:objectName())
	       	end
	       	if use.card:objectName()=="slash"
	       	and room:askForSkillInvoke(player,"jl_yushanss",sgs.QVariant("choice2:slash:"..table.concat(tos,"+")),false)
	       	then
	        	tos = sgs.Sanguosha:cloneCard("fire_slash")
				tos:setSkillName("jl_yushanss")
				if use.card:isVirtualCard()
				then tos:addSubcards(use.card:getSubcards())
				else tos:addSubcard(use.card) end
	         	room:setEmotion(player,"weapon/jl_yushanss")
				use.card = tos
				data:setValue(use)
	       	end
		elseif event==sgs.SlashMissed
		then
			local effect = data:toSlashEffect()
			if effect.slash:isKindOf("Slash")
			and effect.to:isAlive()
			then
    			room:askForUseSlashTo(effect.from,effect.to,"@bingyuegong-slash:"..effect.to:objectName())
			end
		end
		return false
	end
}
jl_yushanss = sgs.CreateWeapon{
	name = "jl_yushanss",
	class_name = "JlYushanss",
	range = 12,
	on_install = function(self,player)
		local room = player:getRoom()
		room:acquireSkill(player,jl_yushanssTr,true,true,false)
		return false
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player,"jl_yushanss",true,true)
		return false
	end,
}
jl_yushanss:clone(1,1):setParent(extensioncard)
addToSkills(jl_yushanssTrVS)

jl_bajun = sgs.Sanguosha:cloneCard("DefensiveHorse",2,5)
jl_bajun:setObjectName("jl_bajun")
jl_bajun:setParent(extensioncard)

jl_bajunbf = sgs.CreateDistanceSkill{
	name = "#jl_bajunbf",
	correct_func = function(self,from,to)
		local n = 0
		local to_dh = to and to:getDefensiveHorse()
		local from_dh = from and from:getDefensiveHorse()
		if to_dh and to_dh:objectName()=="jl_bajun"
		then n = n+7 end
		if from_dh and from_dh:objectName()=="jl_bajun"
		then n = n-8 end
		if from:hasSkill("jl_qiangxuan")
		and from:getTreasure()
		then n = n-1 end
		if from:hasSkill("jl_shenzhu")
		then n = n-2 end
		if from:hasSkill("jl_xiefang")
		and to and to:isFemale()
		then n = n-998 end
		return n
	end
}
addToSkills(jl_bajunbf)
--%src
--%dest
--%arg
jl_bajunCard = sgs.CreateSkillCard{
	name = "jl_bajunCard",
	will_throw = false,
	target_fixed = true,
	about_to_use = function(self,room,use)
		local moves = sgs.CardsMoveList()
		for _,p in sgs.list(room:getAlivePlayers())do
			local move1 = sgs.CardsMoveStruct()
			for _,e in sgs.list(p:getEquipsId())do
				if self:getSubcards():contains(e)
				then move1.card_ids:append(e) end
			end
			if move1.card_ids:isEmpty()
			then continue end
			move1.to = use.from
			move1.to_place = sgs.Player_PlaceHand
			move1.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION,use.from:objectName(),p:objectName(),"jl_bajun","")
			moves:append(move1)
		end
		room:moveCardsAtomic(moves,true)
	end
}
jl_bajunVS = sgs.CreateViewAsSkill{
	name = "jl_bajun",
	n = 998,
	expand_pile = "#bajuncard",
	response_pattern = "@@jl_bajun",
	view_filter = function(self,selected,to_select)
        return sgs.Self:getPileName(to_select:getEffectiveId())=="#bajuncard"
	end,
	view_as = function(self,cards)
		if #cards<1 then return end
	    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
	   	pattern = jl_bajunCard:clone() 
	   	for _,cid in sgs.list(cards)do
	        pattern:addSubcard(cid)
	   	end
        return pattern
	end,
	enabled_at_play = function(self,player)
		return false
	end,
} 
addToSkills(jl_bajunVS)

sgs.HorseSkill.jl_bajun = {
	on_install = function(self,player,room)
		Skill_msg(self,player)
		local es = dummyCard()
		for _,eid in sgs.list(player:getEquipsId())do
			if eid~=self:getEffectiveId()
			then es:addSubcard(eid) end
		end
		if es:subcardsLength()<1 then return end
		room:throwCard(es,nil)
	end,
	on_uninstall = function(self,player,room)
		Skill_msg(self,player)
		local es = sgs.IntList()
		for _,pt in sgs.list(room:getOtherPlayers(player))do
			for _,e in sgs.list(pt:getEquipsId())do
				es:append(e)
			end
		end
		if es:length()<1 then return end
		room:notifyMoveToPile(player,es,"bajuncard",sgs.Player_PlaceEquip,true)
		room:askForUseCard(player,"@@jl_bajun","@jl_bajun")
		room:notifyMoveToPile(player,es,"bajuncard",sgs.Player_PlaceEquip,false)
	end
}
--杯具
jl_beijuTr = sgs.CreateTriggerSkill{
	name = "jl_beiju",
	events = {sgs.Damaged},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self,target)
		return target and target:hasTreasure("jl_beiju")
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.Damaged
		then
		    local damage = data:toDamage()
			if damage.damage>1
			then
                room:sendCompulsoryTriggerLog(player,"jl_beiju")
		   		room:throwCard(player:getTreasure(),player)
	    	end
		end
		return false
	end,
}
jl_beiju = sgs.CreateTreasure{
	name = "jl_beiju",
	class_name = "JlBeiju",
	target_fixed = false,
	on_install = function(self,player)
		local room = player:getRoom()
		room:acquireSkill(player,jl_beijuTr,false,true,false)
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player,"jl_beiju",true,true)
        room:sendCompulsoryTriggerLog(player,"jl_beiju")
		local target = room:getCurrent()
		room:loseHp(target,math.min(target:getHp(),2),false,player,"jl_beiju")
		return false
	end,
}
jl_beiju:clone(0,1):setParent(extensioncard)


jl_sstj = sgs.CreateBasicCard{
	name = "jl_sstj",
	class_name = "JlSstj",
	subtype = "buff_card",
--	target_fixed = true,
    can_recast = false,
	filter = function(self,targets,to_select,source)
        local dc = dummyCard()
		dc:addSubcards(self:getSubcards())
		dc:setSkillName("jl_sstj")
		if dc:isAvailable(source)
		then
	    	return source:canSlash(to_select,dc)
	    	and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,dc)
		end
		return #targets<1
	end,
	feasible = function(self,targets)
        local slash = dummyCard()
		slash:setSkillName("jl_sstj")
		slash:addSubcards(self:getSubcards())
		slash = slash:isAvailable(sgs.Self)
        local peach = dummyCard("peach")
		peach:setSkillName("jl_sstj")
		peach:addSubcards(self:getSubcards())
		peach = peach:isAvailable(sgs.Self)
        local analeptic = dummyCard("analeptic")
		analeptic:addSubcards(self:getSubcards())
		analeptic:setSkillName("jl_sstj")
		analeptic = analeptic:isAvailable(sgs.Self)
		if slash and (peach or analeptic) then return #targets>=0
		elseif peach or analeptic then return #targets<1
		elseif slash then return #targets>0 end
	end,
	about_to_use = function(self,room,use)
        local give = {}
		if use.to:isEmpty()
		then
	    	use.to:append(use.from)
			local dc = dummyCard("peach")
			dc:addSubcards(self:getSubcards())
			dc:setSkillName("jl_sstj")
			if dc:isAvailable(player)
			then table.insert(give,"peach") end
			dc = dummyCard("analeptic")
			dc:addSubcards(self:getSubcards())
			dc:setSkillName("jl_sstj")
			if dc:isAvailable(player)
			then table.insert(give,"analeptic") end
		else table.insert(give,"slash") end
		if #give<1 then return end
		give = room:askForChoice(use.from,"jl_sstj",table.concat(give,"+"))
	   	use.card = sgs.Sanguosha:cloneCard(give,self:getSuit(),self:getNumber())
 		use.card:addSubcards(self:getSubcards())
      	use.card:setSkillName("jl_sstj")
		if give=="slash"
		then
			use.card:setTag("drank",ToData(use.from:getMark("drank")))
			room:setPlayerMark(use.from,"drank",0)
			self:setDamageCard(true)
		end
		self:cardOnUse(room,use)
		room:addPlayerHistory(use.from,use.card:getClassName())
	end,
    available = function(self,player)
        local slash = dummyCard()
		slash:setSkillName("jl_sstj")
		slash:addSubcards(self:getSubcards())
		slash = slash:isAvailable(player)
        local peach = dummyCard("peach")
		peach:setSkillName("jl_sstj")
		peach:addSubcards(self:getSubcards())
		peach = peach:isAvailable(player)
        local analeptic = dummyCard("analeptic")
		analeptic:addSubcards(self:getSubcards())
		analeptic:setSkillName("jl_sstj")
		analeptic = analeptic:isAvailable(player)
		return slash or peach or analeptic
    end,
}
jl_sstj:clone(2,6):setParent(extensioncard)

jl_sdjls = sgs.CreateBasicCard{
	name = "jl_sdjls",
	class_name = "JlSdjls",
	subtype = "jiexusheng_card",
--	target_fixed = true,
    can_recast = false,
	damage_card = true,
	filter = function(self,targets,to_select,source)
	    local slash = dummyCard("thunder_slash")
		slash:addSubcards(self:getSubcards())
		slash:setSkillName("jl_sdjls")
	   	return source:inMyAttackRange(to_select) and source:canSlash(to_select,slash)
	   	and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,slash)
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		room:setEmotion(effect.from,"analeptic")
		room:addPlayerMark(effect.from,"drank")
		room:getThread():delay(777)
		room:setPlayerChained(effect.to,true)
		room:getThread():delay(777)
		local se = sgs.SlashEffectStruct()
        se.from = effect.from
        se.nature = sgs.DamageStruct_Thunder
        se.slash = effect.card
        se.to = effect.to
        se.drank = effect.from:getMark("drank")
        se.nullified = effect.nullified
        se.no_offset = effect.no_offset
        se.no_respond = effect.no_respond
        se.multiple = effect.multiple
		local jn = effect.from:getTag("Jink_"..effect.card:toString()):toIntList()
		se.jink_num = jn:isEmpty() and 1 or jn:at(0)
        room:setPlayerMark(effect.from,"drank",0)
		room:slashEffect(se)
		room:addPlayerHistory(effect.from,"Slash")
		return false
	end,
    available = function(self,player)
	    local slash = dummyCard("thunder_slash")
		slash:addSubcards(self:getSubcards())
		slash:setSkillName("jl_sdjls")
        return slash:isAvailable(player)
    end,
}
jl_sdjls:clone(0,7):setParent(extensioncard)
jl_sdjls:clone(1,7):setParent(extensioncard)

jl_wanxiangqq = sgs.CreateTrickCard{
	name = "jl_wanxiangqq",
	class_name = "JlWanxiangqq",
--	subtype = "ba_card",
	subclass = sgs.LuaTrickCard_TypeAOE,
    target_fixed = true,
    can_recast = false,
	is_cancelable = true,
	damage_card = true,
	on_effect = function(self,effect)
		local room,to,from = effect.to:getRoom(),effect.to,effect.from
		local data = sgs.QVariant()
		data:setValue(effect)
		if effect.no_respond
		or not room:askForCard(to,"slash","@jl_wanxiangqq:slash",data,sgs.Card_MethodResponse,from,false,"jl_wanxiangqq",false,self)
		or not room:askForCard(to,"jink","@jl_wanxiangqq:jink",data,sgs.Card_MethodResponse,from,false,"jl_wanxiangqq",false,self)
		then room:damage(sgs.DamageStruct(self,from,to)) end
		return false
	end,
}
jl_wanxiangqq:clone(3,11):setParent(extensioncard)

jl_taoyuanfd = sgs.CreateTrickCard{
	name = "jl_taoyuanfd",
	class_name = "JlTaoyuanfd",
--	subtype = "ba_card",
	subclass = sgs.LuaTrickCard_TypeGlobalEffect,
    target_fixed = true,
    can_recast = false,
	is_cancelable = true,
	on_use = function(self,room,source,targets)
    	local ids = room:getNCards(#targets)
		room:fillAG(ids)
		room:setTag("JlTaoyuanfd",ToData(ids))
		local effect = sgs.CardEffectStruct()
		effect.from = source
		effect.card = self
		effect.multiple = #targets>1
		local no_offset_list = room:getTag("CardUseNoOffsetList"):toStringList()
		local no_respond_list = room:getTag("CardUseNoRespondList"):toStringList()
		local nullified_list = room:getTag("CardUseNullifiedList"):toStringList()
		for _,to in sgs.list(targets)do
			effect.to = to
			effect.no_offset = table.contains(no_offset_list,"_ALL_TARGETS") or table.contains(no_offset_list,to:objectName())
			effect.no_respond = table.contains(no_respond_list,"_ALL_TARGETS") or table.contains(no_respond_list,to:objectName())
			effect.nullified = table.contains(nullified_list,"_ALL_TARGETS") or table.contains(nullified_list,to:objectName())
			if to:isWounded() then room:cardEffect(effect)
			else room:setEmotion(to,"skill_nullify") end
        end
		room:clearAG()
		ids = room:getTag("JlTaoyuanfd"):toIntList()
		if ids:isEmpty() then return end
       	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER,nil,nil,self:objectName(),nil)
       	effect = dummyCard()
	    effect:addSubcards(ids)
    	room:throwCard(effect,reason,nil)--弃牌
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		local ag_list = room:getTag("JlTaoyuanfd"):toIntList()
        local card_id = room:askForAG(effect.to,ag_list,false,self:objectName())
        room:takeAG(effect.to,card_id)
        ag_list:removeOne(card_id)
		room:setTag("JlTaoyuanfd",ToData(ag_list))
	   	room:recover(effect.to,sgs.RecoverStruct(effect.from,self))
		return false
	end,
}
jl_taoyuanfd:clone(3,13):setParent(extensioncard)

jl_lebucq = sgs.CreateTrickCard{--锦囊牌
	name = "jl_lebucq",
	class_name = "JlLebucq",--卡牌的类名
	subtype = "delayed_trick",--卡牌的子类型
	subclass = sgs.LuaTrickCard_TypeDelayedTrick,--卡牌的类型 延时锦囊
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	movable = false,
    available = function(self,player)
    	for _,to in sgs.list(player:getAliveSiblings())do
			if CanToCard(self,player,to)
			then
				return self:cardIsAvailable(player)
			end
		end
    end,
	filter = function(self,targets,to_select,player)
        if player:isProhibited(to_select,self) then return end
	    return not to_select:containsTrick("jl_lebucq")
		and to_select:objectName()~=player:objectName()
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
        local effect = sgs.CardEffectStruct()
		effect.from = source
		effect.card = self
		effect.multiple = #targets>1
    	for _,to in sgs.list(targets)do
	        effect.to = to
			local no_offset_list = room:getTag("CardUseNoOffsetList"):toStringList()
			local no_respond_list = room:getTag("CardUseNoRespondList"):toStringList()
			local nullified_list = room:getTag("CardUseNullifiedList"):toStringList()
			effect.no_offset = table.contains(no_offset_list,"_ALL_TARGETS") or table.contains(no_offset_list,to:objectName())
			effect.no_respond = table.contains(no_respond_list,"_ALL_TARGETS") or table.contains(no_respond_list,to:objectName())
			effect.nullified = table.contains(nullified_list,"_ALL_TARGETS") or table.contains(nullified_list,to:objectName())
			if effect.nullified then room:setEmotion(to,"skill_nullify") continue end
			if to:getCardCount(true,true)>0
			then
				if room:isCanceled(effect) then continue end
				self:onEffect(effect)
			end
			room:moveCardTo(self,to,sgs.Player_PlaceDelayedTrick)
        end
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		local judge = sgs.JudgeStruct()
        local log = sgs.LogMessage()
		log.type = "$tianzhai"
		log.arg = self:objectName()
		log.from = effect.to
		judge.pattern = ".|heart"
		judge.good = true
	    judge.negative = true
		judge.reason = self:objectName()
		judge.who = effect.to
		if effect.to:getPhase()==sgs.Player_Judge
		then
	    	room:sendLog(log)
    		room:judge(judge)
    	    if judge:isBad() then effect.to:skip(sgs.Player_Play) end
       		log = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER,effect.to:objectName())
    		room:throwCard(self,log,nil)--弃牌
		elseif effect.from and effect.to:getCardCount(true,true)>0
		then
			log = room:askForCardChosen(effect.from,effect.to,"hej",self:objectName(),false,sgs.Card_MethodDiscard)
    		room:throwCard(log,effect.to,effect.from)
		end
		return false
	end,
}
jl_lebucq:clone(3,4):setParent(extensioncard)

jl_shunshoubl = sgs.CreateTrickCard{--锦囊牌
	name = "jl_shunshoubl",
	class_name = "JlShunshoubl",--卡牌的类名
	subtype = "delayed_trick",--卡牌的子类型
	subclass = sgs.LuaTrickCard_TypeDelayedTrick,--卡牌的类型 延时锦囊
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
	movable = false,
    available = function(self,player)
    	for _,to in sgs.list(player:getAliveSiblings())do
			if CanToCard(self,player,to)
			then
				return self:cardIsAvailable(player)
			end
		end
    end,
	filter = function(self,targets,to_select,player)
        if player:isProhibited(to_select,self) then return end
	    return not to_select:containsTrick("jl_shunshoubl")
		and player:distanceTo(to_select)==1
		and #targets<1
	end,
	on_use = function(self,room,source,targets)
        local effect = sgs.CardEffectStruct()
		effect.from = source
		effect.card = self
		effect.multiple = #targets>1
		local no_offset_list = room:getTag("CardUseNoOffsetList"):toStringList()
		local no_respond_list = room:getTag("CardUseNoRespondList"):toStringList()
		local nullified_list = room:getTag("CardUseNullifiedList"):toStringList()
    	for _,to in sgs.list(targets)do
	        effect.to = to
			effect.no_offset = table.contains(no_offset_list,"_ALL_TARGETS") or table.contains(no_offset_list,to:objectName())
			effect.no_respond = table.contains(no_respond_list,"_ALL_TARGETS") or table.contains(no_respond_list,to:objectName())
			effect.nullified = table.contains(nullified_list,"_ALL_TARGETS") or table.contains(nullified_list,to:objectName())
			if effect.nullified then room:setEmotion(to,"skill_nullify") continue end
			if to:getCardCount(true,true)>0
			then
				if room:isCanceled(effect) then continue end
				self:onEffect(effect)
			end
			room:moveCardTo(self,to,sgs.Player_PlaceDelayedTrick)
        end
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		local judge = sgs.JudgeStruct()
        local log = sgs.LogMessage()
		log.type = "$tianzhai"
		log.arg = self:objectName()
		log.from = effect.to
		judge.pattern = ".|club"
		judge.good = true
	    judge.negative = true
		judge.who = effect.to
		judge.reason = self:objectName()
		if effect.to:getPhase()==sgs.Player_Judge
		then
	    	room:sendLog(log)
    		room:judge(judge)
    	    if judge:isBad() then effect.to:skip(sgs.Player_Draw) end
       		log = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER,effect.to:objectName())
    		room:throwCard(self,log,nil)--弃牌
		elseif effect.from and effect.to:getCardCount(true,true)>0
		then
			log = room:askForCardChosen(effect.from,effect.to,"hej",self:objectName())
			room:obtainCard(effect.from,sgs.Sanguosha:getCard(log),false)
		end
		return false
	end,
}
jl_shunshoubl:clone(3,4):setParent(extensioncard)

jl_huodou = sgs.CreateTrickCard{
	name = "jl_huodou",
	class_name = "JlHuodou",
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
	    return to_select:objectName()~=source:objectName()
		and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)
	end,
	on_effect = function(self,effect)
		local from,to,room = effect.from,effect.to,effect.to:getRoom()
	   	local data = sgs.QVariant()
	   	data:setValue(effect)
		if effect.no_respond
		then room:damage(sgs.DamageStruct(self,from,to,1,sgs.DamageStruct_Fire))
		else
			while to do
	        	local card = room:askForCard(to,"slash","jlhuodou1:slash",data,sgs.Card_MethodResponse,from,false,"jl_huodou",false,self)
		    	if card
	        	then
		        	if room:askForCard(from,".|"..card:getSuitString().."|.|hand","jlhuodou2:"..card:getSuitString(),data,sgs.Card_MethodDiscard,from,false,"jl_huodou",false,self)
			    	then
					else
						card = sgs.DamageStruct(self,to,from,1,sgs.DamageStruct_Fire)
						card.by_user = false
						room:damage(card)
						break
					end
                else room:damage(sgs.DamageStruct(self,from,to,1,sgs.DamageStruct_Fire)) break end
			end
		end
		return false
	end,
}
jl_huodou:clone(2,1):setParent(extensioncard)

jl_lianhuansr = sgs.CreateTrickCard{
	name = "jl_lianhuansr",
	class_name = "JlLianhuansr",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	is_cancelable = true,
	can_recast = true,
--	damage_card = true,
    available = function(self,player)
    	for _,to in sgs.list(player:getAliveSiblings())do
			if CanToCard(self,player,to)
			then
				return self:cardIsAvailable(player)
			end
		end
		return not player:isCardLimited(self,sgs.Card_MethodRecast)
    end,
	filter = function(self,targets,to_select,source)
		if source:isCardLimited(self,sgs.Card_MethodUse) then return #targets<1 end
		local x = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)
		if math.mod(#targets,2)==1
		then
     		if targets[#targets]:inMyAttackRange(to_select)
			and targets[#targets]:canSlash(to_select)
			then return x+1 end
		else
			if #targets/2>x then return end
			return to_select:objectName()~=source:objectName()
			and to_select:getWeapon()
		end
	end,
	feasible = function(self,targets)
		local ou = math.mod(#targets,2)~=1
		if sgs.Self:isCardLimited(self,sgs.Card_MethodUse) then return #targets<1 end
		if sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_PLAY and self:canRecast()
		then return #targets<1 or #targets>1 and ou
		else return #targets>1 and ou end
	end,
	about_to_use = function(self,room,use)
       	if use.to:length()<2
		then UseCardRecast(use.from,self,"jl_lianhuansr")
		else
        	local n = use.to:length()
			while use.to:length()>n/2 do
				if math.mod(use.to:length(),2)~=1
				then
					use.to:at(use.to:length()-2):setTag("jl_lianhuansr",ToData(use.to:at(use.to:length()-1)))
					use.to:removeOne(use.to:at(use.to:length()-1))
				else
					use.to:at(use.to:length()-3):setTag("jl_lianhuansr",ToData(use.to:at(use.to:length()-2)))
					use.to:removeOne(use.to:at(use.to:length()-2))
				end
			end
	    	self:cardOnUse(room,use)
		end
	end,
	on_use = function(self,room,source,targets)
	   	local log = sgs.LogMessage()
       	log.type = "$jl_lianhuansr"
        log.arg2 = "slash"
	   	log.from = source
    	for _,to in sgs.list(targets)do
			local target = to:getTag("jl_lianhuansr"):toPlayer()
	    	room:doAnimate(1,to:objectName(),target:objectName())
            log.arg = target:getGeneralName()
            log.to = sgs.SPlayerList()
			log.to:append(to)
    		room:sendLog(log)
		end
		local no_offset_list = room:getTag("CardUseNoOffsetList"):toStringList()
		local no_respond_list = room:getTag("CardUseNoRespondList"):toStringList()
		local nullified_list = room:getTag("CardUseNullifiedList"):toStringList()
		local effect = sgs.CardEffectStruct()
		effect.from = source
		effect.card = self
		effect.multiple = #targets>1
    	for _,to in sgs.list(targets)do
			effect.to = to
			effect.no_offset = table.contains(no_offset_list,"_ALL_TARGETS") or table.contains(no_offset_list,to:objectName())
			effect.no_respond = table.contains(no_respond_list,"_ALL_TARGETS") or table.contains(no_respond_list,to:objectName())
			effect.nullified = table.contains(nullified_list,"_ALL_TARGETS") or table.contains(nullified_list,to:objectName())
	    	room:cardEffect(effect)
        end
	end,
	on_effect = function(self,effect)
		local to,source,room = effect.to,effect.from,effect.to:getRoom()
    	local target = to:getTag("jl_lianhuansr"):toPlayer()
        room:setPlayerChained(to,true)
        room:setPlayerChained(target,true)
		local tx = "@jl_lianhuansr:"..target:objectName()..":"..source:objectName()
      	if (effect.no_respond or not room:askForUseSlashTo(to,target,tx))
		and to:getWeapon() then room:obtainCard(source,to:getWeapon()) end
		return false
	end,
}
jl_lianhuansr:clone(2,1):setParent(extensioncard)

jl_dianshan = sgs.CreateTrickCard{--锦囊牌
	name = "jl_dianshan",
	class_name = "JlDianshan",--卡牌的类名
	subtype = "delayed_trick",--卡牌的子类型
	subclass = sgs.LuaTrickCard_TypeDelayedTrick,--卡牌的类型 延时锦囊
	target_fixed = true,
	can_recast = false,
	is_cancelable = true,
	movable = true,
	damage_card = true,
    available = function(self,player)
        return false
    end,
	on_nullified = function(self,player)
		local room = player:getRoom()
       	if room:getCardPlace(self:getEffectiveId())~=sgs.Player_PlaceDelayedTrick then return end
		for skill,to in sgs.list(sgs.reverse(sgs.QList2Table(room:getOtherPlayers(player))))do
			if to:containsTrick(self:objectName()) then continue end
			local logm = sgs.LogMessage()
			if not to:hasJudgeArea() then
				logm.type = "#NoJudgeAreaAvoid"
				logm.from = to
				logm.arg = self:objectName()
				room:sendLog(logm)
				continue
			end
			skill = room:isProhibited(player,to,self)
			if skill
			then
				logm.arg = skill:objectName()
				logm.arg2 = self:objectName()
				logm.type = "#SkillAvoidFrom"
				if skill:isVisible()
				then
					if to:hasSkill(skill)
					then
						logm.type = "#SkillAvoid"
						logm.from = to
						room:sendLog(logm)
						room:broadcastSkillInvoke(logm.arg)
						room:notifySkillInvoked(to,logm.arg)
					else
						for _,owner in sgs.list(room:getOtherPlayers(to))do
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
				end
				continue
			end
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_USE,player:objectName(),to:objectName(),self:getSkillName(),"")
			reason.m_extraData = ToData(self:getRealCard())
			reason.m_useStruct = sgs.CardUseStruct(self,player,to)
			room:moveCardTo(self,to,sgs.Player_PlaceDelayedTrick,reason,true)
		end
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
        local log = sgs.LogMessage()
		log.type = "$tianzhai"
		log.arg = self:objectName()
		log.from = effect.to
		room:sendLog(log)
		local judge = sgs.JudgeStruct()
		judge.pattern = ".|spade"
		judge.good = true
	    judge.negative = true
		judge.reason = self:objectName()
		judge.who = effect.to
		room:judge(judge)
		if judge:isBad()
		then
	       	room:damage(sgs.DamageStruct(self,nil,effect.to,1,sgs.DamageStruct_Thunder))
		end
		if effect.to:isAlive()
		then self.on_nullified(self,effect.to)
		else
       		log = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER,effect.to:objectName())
    		room:throwCard(self,log,nil)--弃牌
		end
		return false
	end,
}
jl_dianshan:clone(1,6):setParent(extensioncard)

jl_wuxiesy = sgs.CreateTrickCard{
	name = "jl_wuxiesy",
	class_name = "JlWuxiesy",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = true,
	can_recast = false,
	is_cancelable = true,
    available = function(self,player)
        if player:isProhibited(player,self) then return end
    	return self:cardIsAvailable(player)
    end,
	about_to_use = function(self,room,use)
    	if use.to:isEmpty()
		then
			local ce = use.from:getTag("jl_wuxiesy"):toCardEffect()
			if ce and ce.to then else use.to:append(use.from) end
		end
	    self:cardOnUse(room,use)
	end,
	on_use = function(self,room,source,targets)
        local effect = sgs.CardEffectStruct()
		effect.from = source
		effect.card = self
		effect.multiple = #targets>1
		local no_offset_list = room:getTag("CardUseNoOffsetList"):toStringList()
		local no_respond_list = room:getTag("CardUseNoRespondList"):toStringList()
		local nullified_list = room:getTag("CardUseNullifiedList"):toStringList()
        local ce = source:getTag("jl_wuxiesy"):toCardEffect()
		if #targets>0
		then
			for _,to in sgs.list(targets)do
				effect.to = to
				effect.no_offset = table.contains(no_offset_list,"_ALL_TARGETS") or table.contains(no_offset_list,to:objectName())
				effect.no_respond = table.contains(no_respond_list,"_ALL_TARGETS") or table.contains(no_respond_list,to:objectName())
				effect.nullified = table.contains(nullified_list,"_ALL_TARGETS") or table.contains(nullified_list,to:objectName())
				if effect.nullified or room:isCanceled(effect)
				then source:drawCards(2,"jl_wuxiesy") end
			end
		elseif ce and ce.to
		then
			effect.to = ce.from or ce.to
			effect.no_offset = table.contains(no_offset_list,"_ALL_TARGETS") or table.contains(no_offset_list,effect.to:objectName())
			effect.no_respond = table.contains(no_respond_list,"_ALL_TARGETS") or table.contains(no_respond_list,effect.to:objectName())
			effect.nullified = table.contains(nullified_list,"_ALL_TARGETS") or table.contains(nullified_list,effect.to:objectName())
			if effect.nullified or room:isCanceled(effect) then return end
			local log = sgs.LogMessage()
			log.type = "$jl_wuxiesy0"
			log.to:append(effect.to)
			log.arg = self:objectName()
			log.arg2 = ce.card:objectName()
			room:sendLog(log)
			source:drawCards(2,"jl_wuxiesy")
			source:setTag("jl_wuxiesy",ToData(ce.card:toString()))
		end
		return false
	end
}
jl_wuxiesy:clone(2,1):setParent(extensioncard)


--175.178.66.93


jl_on_trigger = sgs.CreateTriggerSkill{
	name = "jl_on_trigger",
	events = {sgs.StartJudge,sgs.AskForPeachesDone,sgs.EventPhaseChanging},
	frequency = sgs.Skill_Compulsory,
	global = true,
	can_trigger = function(self,target)
		if table.contains(sgs.Sanguosha:getBanPackages(),"jilebao")
		then else return target and target:isAlive() end
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.EventPhaseChanging
        then
	     	local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
	        	for _,to in sgs.list(player:getMarkNames())do
		        	if string.find(to,"fuman_to")
		        	then
	                	room:setPlayerMark(player,to,0)
					end
				end
				if player:getPile("incantation"):length()>0
				then
	            	local id = player:getPile("incantation"):at(0)
			    	for _,to in sgs.list(room:getAllPlayers())do
		    	    	if to:getMark("zhoufu_"..id)>0
			    		then
					    	room:sendCompulsoryTriggerLog(to,"zhoufu")
	                     	room:broadcastSkillInvoke("zhoufu",math.random(1,2))--播放配音
    				    	room:obtainCard(to,id)
    				    	room:setPlayerMark(to,"zhoufu_"..id,0)
				    		break
			    		end
			    	end
				end
	         	for _,to in sgs.list(room:getAllPlayers())do
		    		if to:getMark("@skill_invalidity")>0
					then
			    		to:setMark("tieji",0)
						room:setPlayerMark(to,"@skill_invalidity",0)
					end
					if to:hasSkill("jl_shenzhu")
					then
	                 	local ids = to:getTag("zishu"):toString():split("+")
						local card = dummyCard()
                    	for _,id in sgs.list(ids)do
				    		if to:handCards():contains(id)
							then card:addSubcard(id) end
						end
						if card:subcardsLength()>0
						then
				    		room:sendCompulsoryTriggerLog(to,"zishu",true,true,2)
							ids = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISCARD,to:objectName(),"zishu","")
							room:moveCardTo(card,nil,sgs.Player_DiscardPile,ids,true)
						end
						to:removeTag("zishu")
					end
				end
			end
		elseif event==sgs.AskForPeachesDone
	   	then
			local death = data:toDying()
			if death.damage and death.who:getHp()<1
			and not death.who:isLord()
			and death.who:hasFlag("Global_Dying")
			then
				local killer = death.damage.from
				if killer and not killer:isLord()
				then
					if killer:hasSkill("jl_xianfa")
					and killer:getMark("@burnheart")>0
					then
						if room:askForSkillInvoke(killer,"fenxin",ToData(death.who))
						then
		                	room:removePlayerMark(killer,"@burnheart")
                            room:broadcastSkillInvoke("fenxin")
                            room:doSuperLightbox(killer:getGeneralName(),"fenxin")
							local role1 = killer:getRole()
							local role2 = death.who:getRole()
							killer:setRole(role2)
							room:setPlayerProperty(killer,"role",sgs.QVariant(role2))
							death.who:setRole(role1)
							room:setPlayerProperty(death.who,"role",sgs.QVariant(role1))
							return false
						end
					end
				end
			end
		elseif event==sgs.StartJudge
		then
			local judge = data:toJudge()
			if player:getPile("incantation"):isEmpty() then return end
			room:broadcastSkillInvoke("zhoufu",math.random(1,2))--播放配音
			judge.card = sgs.Sanguosha:getCard(player:getPile("incantation"):first())
			room:moveCardTo(judge.card,nil,judge.who,sgs.Player_PlaceJudge,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_JUDGE,judge.who:objectName(),"zhoufu","",judge.reason),true)
			judge:updateResult()
			room:setTag("SkipGameRule",sgs.QVariant(true))
		end
		return false
	end,
}
addToSkills(jl_on_trigger)
jl_cardbf = sgs.CreateTargetModSkill{
	name = "jl_cardbf",
	pattern = ".",
	residue_func = function(self,from,card)-- 额外使用
		local n,weapon = 0,from:getWeapon()
		if weapon and weapon:isKindOf("JlBingyuegong")
		and card:isKindOf("Slash")
		then n = n+999 end
		if weapon and weapon:isKindOf("JlYanlinmao")
		and card:isKindOf("Slash")
		then n = n+999 end
		if from:hasSkill("jl_huangtian")
		and card:isKindOf("Slash")
		then n = n+from:getMark("&jl_huangtian-PlayClear") end
		if from:hasSkill("jl_kuangcai")
		and from:getMark("jl_kuangcai-PlayClear")>0
		then n = n+999 end
		if from:hasSkill("jl_limu")
		and from:containsTrick("__jl_mu")
		then n = n+999 end
		if from:hasSkill("jl_mingqi") and card:isKindOf("Slash")
		then n = n+from:getMark("&tuifeng+slash-Clear") end
		if from:hasSkill("jl_qiangzhen")
		and card:isKindOf("Slash") and from:getHp()>4
		then n = n+from:aliveCount() end
		if from:hasSkill("jl_wusheng")
		and card:getSkillName()=="wusheng"
		then n = n+999 end
		return n
	end,
	distance_limit_func = function(self,from,card,to)-- 使用距离
		local n = 0
		if from:hasSkill("wqzhuji")
		and card:isKindOf("TrickCard")
		and from:getMark("&wqzhuji1-Clear")>0
		then n = n+100 end
		if from:hasSkill("jl_kuangcai")
		and from:getMark("jl_kuangcai-PlayClear")>0
		then n = n+999 end
		if to and to:hasSkill("jl_diaoxie")
		and card:isDamageCard()
		and (card:isKindOf("BasicCard") or card:isKindOf("SingleTargetTrick"))
		then n = n+999 end
		if from:hasSkill("jl_limu")
		and from:containsTrick("__jl_mu")
		then n = n+999 end
		if from:hasSkill("jl_yegui")
		then n = n+999 end
		if from:hasSkill("jl_wusheng")
		and card:getSkillName()=="wusheng"
		then n = n+999 end
		return n
	end,
	extra_target_func = function(self,from,card)--目标数
		local n,weapon = 0,from:getWeapon()
		if weapon
		and card:isKindOf("Slash")
		and from:getHandcardNum()>0
		and weapon:isKindOf("JlGuanbingcj")
		and from:getHandcardNum() <= card:subcardsLength()
		then
			local can
			for _,c in sgs.list(from:getHandcards())do
		    	if card:getSubcards():contains(c:getEffectiveId())
				then can = true continue end
				can = false
				break
			end
			if can 
			then
				n = n+2
			end
		end
		if weapon
		and card:isKindOf("Slash")
		and from:getHandcardNum()>0
		and weapon:isKindOf("JlBingyuegong")
		and from:getHandcardNum() <= card:subcardsLength()
		then
			local can
			for _,c in sgs.list(from:getHandcards())do
		    	if card:getSubcards():contains(c:getEffectiveId())
				then can = true continue end
				can = false
				break
			end
			if can 
			then
				n = n+2
			end
		end
		if weapon
		and weapon:isKindOf("JlYanlinmao")
		and card:isKindOf("Slash")
		and from:getHandcardNum() <= card:subcardsLength()
		then n = n+2 end
		if from:hasLordSkill("jl_zebing")
		and from:getMark(card:toString().."jl_zebing")>0
		and card:isNDTrick()
		then n = n+1 end
		if from:hasLordSkill("jl_zebing")
		and from:hasEquip()
		and (card:isKindOf("Dismantlement") or card:isKindOf("Snatch"))
		then n = n+1 end
		return n
	end
}
jl_MaxCards = sgs.CreateMaxCardsSkill{
    name = "#jl_MaxCards",
	extra_func = function(self,target)
        local n = target:getHp()
        local x = 0
		if target:hasSkill("jl_yedu")
		then
			if target:getMark("jl_yeduhzj-Clear")>0
			then x = x+1 end
			if target:getMark("jl_yeduhjs-Clear")>0
			then x = x-1 end
		end
		if target:hasSkill("jl_shehuo")
		then
    		x = x-target:getMark("&jishe-Clear")
		end
		if target:hasSkill("jl_qiangzhen")
		and target:getHp() <= 4
		then
			x = x+target:aliveCount()
		end
		if target:hasSkill("jl_qunli")
		then
	       	for i,p in sgs.list(target:getAliveSiblings())do
				if p:getKingdom()~="qun"then continue end
				x = x+2
			end
		end
		return x
	end 
}
jl_fixed_funcMaxCards = sgs.CreateMaxCardsSkill{
	name = "#jl_fixed_funcMaxCards",
	fixed_func = function(self,player)
		if player:getMark("jl_shenji-Clear")>0
		then return player:getHandcardNum() end
		return -1
	end
}
addToSkills(jl_MaxCards)
addToSkills(jl_cardbf)
addToSkills(jl_fixed_funcMaxCards)
jlCardOnTrigger = sgs.CreateTriggerSkill{
	name = "jlCardOnTrigger",
	events = {sgs.CardsMoveOneTime,sgs.CardAsked,sgs.AskForPeaches,sgs.CardEffected,sgs.DamageCaused},
	frequency = sgs.Skill_Compulsory,
	global = true,
	can_trigger = function(self,target)
		if table.contains(sgs.Sanguosha:getBanPackages(),"jile_card")
		then else return target and target:isAlive() end
	end,
	on_trigger = function(self,event,player,data,room)
 		if event==sgs.CardsMoveOneTime
		then
	     	local move = data:toMoveOneTime()
			if move.to_place==sgs.Player_DiscardPile
			then
				for i,c in sgs.list(move.card_ids)do
					c = sgs.Sanguosha:getCard(c)
					if c:isKindOf("JlDianshan")
					and move.from_places:at(i)~=sgs.Player_PlaceDelayedTrick
					and room:getCardPlace(c:getEffectiveId())==sgs.Player_DiscardPile
					and room:getCurrent()
					then
						room:moveCardTo(c,room:getCurrent(),sgs.Player_PlaceDelayedTrick,true)
					end
				end
	    	end
    	elseif event==sgs.DamageCaused
		then
		    local damage = data:toDamage()
        	if damage.card and damage.to:isKongcheng()
			and damage.card:isKindOf("JlSdjls")
        	then
	        	Skill_msg("jl_sdjls",player)
		    	DamageRevises(data,1,player)
			end
		elseif event==sgs.CardEffected
		then
    		local effect = data:toCardEffect()
			local no_offset_list = room:getTag("CardUseNoOffsetList"):toStringList()
	       	for _,to in sgs.list(room:getAllPlayers())do
				if effect.card:getTypeId()~=2 then break end
				if table.contains(no_offset_list,"_ALL_TARGETS")
				or table.contains(no_offset_list,effect.to:objectName())
				then continue end
				local hc = hasCard(to,"JlWuxiesy","&h")
	         	local can = {}
				if hc
				then
					for _,c in sgs.list(hc)do
						table.insert(can,c:getEffectiveId())
					end
				end
                for _,skill in sgs.list(to:getSkillList(true,false))do
	                if skill:inherits("ViewAsSkill")
		        	then
		            	skill = sgs.Sanguosha:getViewAsSkill(skill:objectName())
		            	if skill:isEnabledAtResponse(to,"jl_wuxiesy")
	                 	then table.insert(can,"jl_wuxiesy") end
		        	end
	        	end
       	        if #can>0
		        then
                    to:setTag("jl_wuxiesy",data)
				   	hc = "jl_wuxiesy-use:"..effect.card:objectName()..":"..effect.to:objectName()
				  	if room:askForUseCard(to,table.concat(can,","),hc,-1,sgs.Card_MethodUse,true,effect.from,effect.card)
					and to:getTag("jl_wuxiesy"):toString()==effect.card:toString()
					then effect.to:setFlags("Global_NonSkillNullify") return true end
                    to:removeTag("jl_wuxiesy")
		        end
            end
			if effect.card:isKindOf("Slash")
			then
				local tocs = player:getHandcards()
				for _,id in sgs.list(player:getHandPile())do
					tocs:append(sgs.Sanguosha:getCard(id))
				end
		    	for _,c in sgs.list(tocs)do
	                if c:isKindOf("JlSstj")
			    	or c:getSkillName()=="jl_sstj"
	             	then
    		    		local toc = sgs.Sanguosha:cloneCard("jink",c:getSuit(),c:getNumber())
                     	toc:setSkillName("jl_sstj")
	                    local wrap = sgs.Sanguosha:getWrappedCard(c:getEffectiveId())
	                    wrap:takeOver(toc)
						room:notifyUpdateCard(player,c:getEffectiveId(),wrap)
			    	end
	         	end
		 	end
		elseif event==sgs.CardAsked
		then
		    local can = {}
    		local pattern = data:toStringList()[1]
			if pattern:match("slash") then table.insert(can,"slash") end
			if pattern:match("jink") then table.insert(can,"jink") end
			if pattern:match("peach") then table.insert(can,"peach") end
			if pattern:match("analeptic") then table.insert(can,"analeptic") end
			if #can>0
			then
				local tocs = player:getHandcards()
				for _,id in sgs.list(player:getHandPile())do
					tocs:append(sgs.Sanguosha:getCard(id))
				end
		    	for _,c in sgs.list(tocs)do
	                if c:isKindOf("JlSstj")
			    	or c:getSkillName()=="jl_sstj"
	             	then
    		    		can = room:askForChoice(player,"jl_sstj",table.concat(can,"+"))
						local toc = sgs.Sanguosha:cloneCard(can,c:getSuit(),c:getNumber())
                     	toc:setSkillName("jl_sstj")
	                    local wrap = sgs.Sanguosha:getWrappedCard(c:getEffectiveId())
	                    wrap:takeOver(toc)
						room:notifyUpdateCard(player,c:getEffectiveId(),wrap)
			    	end
	         	end
			end
		elseif event==sgs.AskForPeaches
		then
			local death = data:toDying()
		    local can = "peach+analeptic"
			if player:objectName()~=death.who:objectName()
			then can = "peach" end
	    	local tocs = player:getHandcards()
			for _,id in sgs.list(player:getHandPile())do
	            tocs:append(sgs.Sanguosha:getCard(id))
	       	end
		   	for _,c in sgs.list(tocs)do
	            if c:isKindOf("JlSstj")
			   	or c:getSkillName()=="jl_sstj"
	           	then
	        		can = room:askForChoice(player,"jl_sstj",can)
    		   		local toc = sgs.Sanguosha:cloneCard(can,c:getSuit(),c:getNumber())
                   	toc:setSkillName("jl_sstj")
	                local wrap = sgs.Sanguosha:getWrappedCard(c:getEffectiveId())
	                wrap:takeOver(toc)
		    		room:notifyUpdateCard(player,c:getEffectiveId(),wrap)
			   	end
	       	end
		end
		if event==sgs.EventPhaseChanging
		or event==sgs.PostCardEffected
		then
	       	for _,to in sgs.list(room:getAllPlayers())do
				local hw = sgs.CardList()
				for _,c in sgs.list(to:getHandcards())do
					if c:isKindOf("JlSstj")
					or c:getSkillName()=="jl_sstj"
					then hw:append(c) end
				end
				for _,c in sgs.list(to:getHandPile())do
					c = sgs.Sanguosha:getCard(c)
					if c:isKindOf("JlSstj")
					or c:getSkillName()=="jl_sstj"
					then hw:append(c) end
				end
				if hw:length()>0
				then
					room:filterCards(to,hw,true)
				end
			end
		end
		return false
	end,
}
addToSkills(jlCardOnTrigger)
extensionBingfen = sgs.Package("jl_bingfen",sgs.Package_CardPack)
jlBingfenOnTrigger = sgs.CreateTriggerSkill{
	name = "jlBingfenOnTrigger",
	events = {sgs.GameStart},
	global = true,
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self,target)
		if table.contains(sgs.Sanguosha:getBanPackages(),"jl_bingfen")
		or not target or target:getState()=="robot" or sgs.jl_bingfen
		then else return target:isAlive() end
	end,
	on_trigger = function(self,event,player,data,room)
		local log = sgs.LogMessage()
		log.type = "$jl_bingfen"
		log.from = player
		log.arg = "jl_bingfen"
		player:speak("AI 有几率会犯病，让场上局势更佳“多姿多彩”")
		room:sendLog(log)
		sgs.jl_bingfen = true
	end,
}
addToSkills(jlBingfenOnTrigger)

sgs.LoadTranslationTable{
	["jilebao"] = "极乐包",
	["jile_card"] = "极乐卡牌包",
	["jl_guanning"] = "管宁",
	["#jl_guanning"] = "万劫不灭",
	["jl_dunshi"] = "盾式",
	[":jl_dunshi"] = "锁定技。你视为拥有：“崇义”、“天义”、“礼赂”、“同礼”、“智迟”、“仁政”、“遣信”；你防止每回合产生的第一次伤害。",
	["jl_shenxiyun"] = "神戏云",
	["#jl_shenxiyun"] = "神威の天才",
	["jl_xiance"] = "先策",
	[":jl_xiance"] = "锁定技，你的体力回复值和受到的伤害值翻倍。当你受到1点伤害后，你进行判定并获得判定牌，若结果为：红色，你摸2张牌；黑色，你弃置一名角色区域内的一张牌。",
	["jl_xiance0"] = "先策：请选择弃置一名角色区域内的一张牌",
	["jl_juehun"] = "绝魂",
	[":jl_juehun"] = "你可以将一张牌按：♥当【桃】、♦当火【杀】、♣当【闪】、♠当【无懈可击】使用或打出。当你陷入或脱离濒死状态时，你摸一张牌。你的摸牌数+2；手牌上限+2。",
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
	["jl_chonger"] = "曹冲儿",
	["#jl_chonger"] = "找妖的神童",
	["jl_renxin2"] = "仁馨",
	[":jl_renxin2"] = "出牌阶段，你可以弃置一张装备牌，然后令一名角色回复1点体力。",
	["jl_chengxiang2"] = "称像",
	[":jl_chengxiang2"] = "当你回复体力时，你可以展示牌堆顶4张牌，然后任意分配这些牌。",
	["jl_sdjls"] = "索锭酒雷杀",
	[":jl_sdjls"] = "基本牌<br />出牌阶段，对一名攻击范围内的角色使用；<br /><b>卡牌效果</b>：你视为使用了【酒】并横置目标，然后对目标造成1点雷电伤害；若目标没有手牌，则此伤害+1。",
	["jiexusheng_card"] = "大宝专用",
	["jl_weiyan"] = "魏延",
	["designer:jl_weiyan"] = "吃蛋挞的折棒",
	["illustrator:jl_weiyan"] = "吃蛋挞的折棒",
	["#jl_weiyan"] = "剑定为贞",
	["jl_yiyan"] = "义延",
	[":jl_yiyan"] = "游戏开始时，你令一名角色获得“烈弓（标）”。当你造成或受到1点伤害后，你可以升级一次【烈弓】：1、烈弓（界）；2、烈弓（谋）。",
	["jl_yiyan0"] = "义延：请选择令一名角色获得“烈弓（标）”",
	["jl_yiyan1"] = "义延：你可以升级一次【烈弓】",
	["jl_dingzhen"] = "鼎阵",
	[":jl_dingzhen"] = "当一名武将牌上有“烈弓”的角色使用【杀】造成伤害时，你可以选择一项：1、令其摸一张牌；2、此【杀】不计入次数限制。背水：你失去1点体力。",
	["jl_dingzhen1"] = "令其摸一张牌",
	["jl_dingzhen2"] = "此【杀】不计入次数限制",
	["jl_dingzhen3"] = "你失去1点体力",
	["jl_mouliubei"] = "谋刘备",
	["#jl_mouliubei"] = "微操大师",
	["jl_gaojian"] = "高见",
	[":jl_gaojian"] = "①出牌阶段开始时，你可以选择一项：1、移除场上所有“手令”标记，然后令一名其他角色获得1枚“手令”标记；2、交给一名“手令”角色X张牌，然后你获得X+1枚“优势”标记（X为其拥有的“手令”数）。②“手令”角色准备阶段，其获得1枚“手令”标记。③你可以移去2枚“优势”标记，然后视为使用或打出一张基本牌。",
	["jl_gaojian0"] = "高见：你可以选择一项",
	["jl_shouling"] = "手令",
	["jl_youshi"] = "优势",
	["jl_qiangzheng"] = "强征",
	[":jl_qiangzheng"] = "限定技，出牌阶段，你可以令本局游戏中获得过“手令”的角色依次交给你两张牌，然后你增加1点体力上限并失去“高见”。",
	["jl_qiangzheng0"] = "强征：请选择两张牌交给%src",
	["jl_duzhan"] = "督战",
	[":jl_duzhan"] = "主公技，出牌阶段结束时，你可以选择一名角色A，然后选择一名攻击范围包含A且体力值不小于你的其他蜀势力角色B。B须选择：1、视为对A使用一张【杀】；2、跳过下个出牌阶段。",
	["jl_duzhan0"] = "督战：你可以选择两名角色",
	["jl_duzhan1:jl_duzhan1"] = "督战：你可以视为对%src使用一张【杀】，否则将跳过下个出牌阶段",
	["jl_dengjiao"] = "邓角",
	["#jl_dengjiao"] = "矫然の天公",
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
	["jl_tianzi"] = "天子",
	["#jl_tianzi"] = "真命天子",
	["designer:jl_tianzi"] = "",
	["illustrator:jl_tianzi"] = "官方",
	["jl_weiye"] = "魏业",
	[":jl_weiye"] = "当你需要使用或打出【闪】时，你可以令其他「魏」势力角色打出（视为你使用或打出）；当其他「魏」势力角色的黑色判定牌生效后，其可以令你摸一张牌；当你陷入濒死状态时，其他「魏」势力角色可以令你回复1点体力，然后其受到1点伤害。",
	["jl_weiye:jl_weiye0"] = "魏业：你可以令 %src 回复1点体力，然后你受到1点伤害",
	["jl_weiye_card"] = "魏业：你可以打出一张【闪】视为 %src 使用或打出了【闪】",
	["jl_shuitu"] = "蜀图",
	[":jl_shuitu"] = "当你需要使用或打出【杀】时，你可以令其他「蜀」势力角色打出（视为你使用或打出）；准备阶段，若你的体力值为场上最少，你增加1点体力上限并回复1点体力，然后获得“激将”；你可以弃置一张牌发动“激将”，响应的角色摸一张牌。",
	["jl_shuitu_card"] = "蜀图：你可以打出一张【杀】视为 %src 使用或打出了【杀】",
	["jl_wuce"] = "吴策",
	[":jl_wuce"] = "其他「吴」势力角色对你使用【桃】的回复值+1；其他「吴」势力角色出牌阶段限一次，其可以与你拼点，若其没赢，你获得双方拼点牌；其他「吴」势力角色出牌阶段限一次，其使用【杀】结算后，其可以将之交给你，然后你可以令其摸一张牌。",
	["jl_wucevs"] = "吴策",
	[":jl_wucevs"] = "「吴」势力角色出牌阶段限一次，你可以与“吴策”角色拼点，若你没赢，其获得双方拼点牌；「吴」势力角色出牌阶段限一次，你使用【杀】结算后，你可以将之交给“吴策”角色，然后其可以令你摸一张牌。",
	["jl_qunli"] = "群力",
	[":jl_qunli"] = "其他「群」势力角色出牌阶段限一次，其可以将一张【闪】或【闪电】交给你；当其他「群」势力角色造成伤害后，其可以进行判定，若为♠，你回复1点体力；你的手牌上限+X（X为场上存活「群」势力角色数×2）。",
	["jl_qunlivs"] = "群力",
	[":jl_qunlivs"] = "「群」势力角色出牌阶段限一次，你可以将一张【闪】或【闪电】交给“群力”角色；你造成伤害后，你可以进行判定，若为♠，“群力”角色回复1点体力",
	["jl_made"] = "马德",
	["#jl_made"] = "一体马人",
	["designer:jl_made"] = "Lua学生",
	["illustrator:jl_made"] = "",
	["jl_mengma"] = "猛马",
	[":jl_mengma"] = "锁定技，你计算与其他角色的距离为1.",
	["jl_pangshu"] = "庞术",
	[":jl_pangshu"] = "当你使用的【杀】被抵消后，你可以弃置目标一张牌，然后若之不为装备牌，此【杀】依旧造成伤害。",
	["jl_ningma"] = "宁马",
	["#jl_ningma"] = "锦翻尤侠",
	["designer:jl_ningma"] = "Lua学生",
	["illustrator:jl_ningma"] = "",
	["jl_qixi"] = "骑袭",
	[":jl_qixi"] = "你可以将一张黑色牌当做【过河拆桥】使用，然后获得因此弃置的牌。",
	["jl_fenwei"] = "愤威",
	[":jl_fenwei"] = "限定技，当一张牌指定多名角色为目标是，你可以令此牌无效，然后获得之。",
	["jl_fenwei:jl_fenwei0"] = "愤威：你可以令此【%src】无效，然后获得之",
	["jl_caochong"] = "曹冲",
	["#jl_caochong"] = "仁爱神童",
	["designer:jl_caochong"] = "Notify",
	["illustrator:jl_caochong"] = "官方",
	["jl_chengxiang"] = "称象",
	[":jl_chengxiang"] = "准备阶段或当你受到伤害后，你可以选择以下一项（每轮每项限一次）：第1~13项：亮出牌堆顶四张牌，令一名角色获得其中点数之和不大于【1~13】的牌；第14~26项：依次弃置一名角色的牌，直到弃置的牌点数之和大于【1~13】。",
	["jl_renxin"] = "仁心",
	[":jl_renxin"] = "锁定技。当你陷入濒死状态时，若“称象”中可选选项大于1，则你回复体力值至1点，然后移除“称象”中的一个选项。",
	["jl_chengxiang0"] = "称象：请选择令一名角色获得这些牌",
	["jl_chengxiang1"] = "称象：请选择一名角色，然后依次弃置其的牌",
	["$jl_chengxiang2"] = "%from 选择了“%arg”中的第 %arg2 项",
	["jl_chengxiang:jlcx_"] = "第%src项",
	["jl_renxin:jlcx_"] = "第%src项",
	["$jl_renxin0"] = "%from 选择移除了“%arg”中的第 %arg2 项",
	["jl_guanyu"] = "关羽",
	["#jl_guanyu"] = "威震华夏",
	["designer:jl_guanyu"] = "lua学生",
	["illustrator:jl_guanyu"] = "官方",
	["jl_wusheng"] = "武圣",
	[":jl_wusheng"] = "你可以将一张红色牌当做【杀】使用或打出；然后若为使用，此【杀】无距离与次数限制，且不能被响应。",
	["$jl_wusheng_bf"] = "%to 不能响应 %from 使用的【%arg】",
	["jl_xingdaorong"] = "邢道荣",
	["#jl_xingdaorong"] = "三国之战神",
	["jl_wuyong"] = "无勇",
	[":jl_wuyong"] = "锁定技。你不能使用和打出基本牌。",
	["jl_wumou"] = "无谋",
	[":jl_wumou"] = "锁定技。你不能使用锦囊牌。",
	["jl_wudu"] = "无度",
	[":jl_wudu"] = "锁定技，你不能使用装备牌。",
	["jl_wuliang"] = "无量",
	[":jl_wuliang"] = "锁定技。当你死亡时，你令一名其他角色获得你所有的技能。",
	["jl_wuliang0"] = "无量；请选择一名其他角色获得你所有的技能。",
	["jl_handang"] = "韩当",
	["#jl_handang"] = "小作文の杀手",
	["jl_gongqi"] = "弓骑",
	[":jl_gongqi"] = "出牌阶段结束后，你可以弃置一张装备牌，然后执行一个额外的出牌阶段。",
	["jl_gongqi0"] = "弓骑：你可以弃置一张装备牌执行一个额外的出牌阶段",
	["jl_jiefan"] = "解烦",
	[":jl_jiefan"] = "出牌阶段限一次，你可以令一名角色选择：1、移除一个技能描述字数大于此技能的技能；2、变更武将牌。",
	["jl_jiefan1"] = "移除一个小作文技能",
	["jl_jiefan2"] = "变更武将牌",
	["jl_2_liubei"] = "刘备",
	["#jl_2_liubei"] = "汉中王",
	["designer:jl_2_liubei"] = "负俗之才",
	["illustrator:jl_2_liubei"] = "明暗交界",
	["jl_zebing"] = "择兵",
	[":jl_zebing"] = "主公技。你的第一个摸牌阶段结束时，你摸4张花色不同的牌，然后将一张♦牌当做“兵”置于武将牌上，将一张♣牌当做“粮”置于武将牌上，将一张♥牌当做“谋”置于武将牌上，将一张♠牌当做“器”置于武将牌上。出牌阶段开始时或结束阶段结束时，你可以将任意张牌分配至“兵”“粮”“谋”“器”中，或将“兵”“粮”“谋”“器”中任意张牌收回手牌；每个“兵”“粮”“谋”“器”中至多有4张牌。出牌阶段，你可以弃置一张“兵”“粮”“谋”"..
	"“器”牌并执行对应效果：若弃置了“兵”，则你令一名其他蜀势力角色交给你两张基本牌，然后其摸两张牌，否则你从场上或牌堆中随机获得两张基本牌；若弃置了“粮”，则你令一名其他角色交给你一张【桃】或【桃园结义】，否则你从场上或牌堆中随机获得一张【桃】；若弃置了“谋”，则你令一名其他蜀势力角色交给你两张锦囊牌，否则你从场上或牌堆中随机获得两张锦囊牌，且其中不为延时锦囊的牌你可以额外指定一名目标；若弃置了“器”，则你"..
	"令一名其他角色交给你一张武器牌，否则你从场上或牌堆中随机获得一张武器牌。当你发动此技能后，若你的体力值不为1，你因此获得的伤害牌造成的伤害+1，且此牌造成伤害后，你选择一项：⒈摸X张牌，⒉令目标弃置X张牌；⒊收回此牌并去除其附加效果。若你体力值为1，你可以将因此获得的牌当做【桃】使用，或交给一名蜀势力角色，然后你与其各摸一张牌。若你没有“兵”，你视为拥有“激将”；若你没有“粮”，普通【杀】对你无效；若"..
	"你没有“谋”，你不能成为普通锦囊牌的目标；若你没有“器”，所有不为蜀势力的角色视为在你的攻击范围内。当你陷入濒死状态时，你可以弃置一张“兵”并选择一名其他角色，若其不为蜀势力，则其可以将势力改为「蜀」，然后交给你一张牌；若其为蜀势力，则你将体力回复至1点；当你需要使用【桃】【酒】【闪】【无懈可击】时，你可以弃置一张“粮”，然后视为使用之。当你需要使用【五谷丰登】【万箭齐发】【南蛮入侵】【铁索连"..
	"环】【借刀杀人】时，你可以弃置一张“谋”，然后视为使用之；若你装备区有牌，则你使用【顺手牵羊】【过河拆桥】可以额外指定一个目标。当一名蜀势力角色打出【杀】/【南蛮入侵】造成伤害后，你可以弃置一张“兵”/“谋”，然后获得之；当一名角色使用【桃】或【酒】回复体力后，你可以弃置一张“粮”，然后获得之。当一张装备牌因其他角色弃置而进入弃牌堆时，你可以弃置一张“器”，然后获得之。",
	["jl_zebing0"] = "择兵：请选择将一张%src牌当做“%dest”置于武将牌上",
	["jl_zebing1"] = "选择目标交给你牌",
	["jl_zebing2"] = "视为使用牌",
	["jl_zebing3"] = "择兵：请执行--%src",
	["jl_zebing4"] = "择兵：请选择%dest张【%arg】交给 %src",
	["jl_zebing5"] = "择兵：请视为使用一张【%src】",
	["jl_bing"] = "兵",
	["jl_liang"] = "粮",
	["jl_mou"] = "谋",
	["jl_qi"] = "器",
	["jl_bing_effect"] = "选择令一名其他蜀势力角色交给你两张基本牌",
	["jl_liang_effect"] = "选择令一名其他角色交给你一张【桃】或【桃园结义】",
	["jl_mou_effect"] = "选择令一名其他蜀势力角色交给你两张锦囊牌",
	["jl_qi_effect"] = "选择令一名其他其他角色交给你一张武器牌",
	["jl_zebing20_effect"] = "选择令一名其他蜀势力角色获得此牌",
	["Peach,GodSalvation"] = "桃】或【桃园结义",
	["$jl_zebing0"] = "%card 来自“%arg”",
	["jl_zebing10"] = "将此牌当做【桃】使用",
	["jl_zebing20"] = "令一名其他蜀势力角色获得此牌",
	["jl_zebing_damage1"] = "摸等伤害值张牌",
	["jl_zebing_damage2"] = "伤害目标弃置等伤害值张牌",
	["jl_zebing_damage3"] = "收回此牌并去除附加效果",
	["jl_zebing:jl_zebing0"] = "择兵：你可以弃置“器”，然后选择获得弃置的装备牌",
	["jl_zebing01"] = "择兵：请选择将要获得的装备牌",
	["jl_zebing02"] = "择兵：请选择将要弃置的“器”牌",
	["jl_zebing21"] = "择兵：你可以弃置一张“%src”牌,然后获得此【%dest】",
	["jl_zebing11"] = "择兵：你可以弃置一张“兵”牌，然后选择一名其他角色",
	["jl_zebing12"] = "择兵：请选择一名其他角色",
	["jl_zebing11:jl_zebing13"] = "择兵：你可以将势力改为「蜀」，然后交给 %src 一张牌",
	["jl_jiuxuevs"] = "究学",
	[":jl_jiuxuevs"] = "平面直角坐标系内，存在y=-x/3+√3与Y轴相交于点A，与X轴相交于点B，点C处于Y轴上且直线CP垂直AB于点P，交Y轴于点C；点P的横坐标为3；在X轴上有一点E，使 S△ACE=1/2 S△ACP；出牌阶段开始时，你可以摸m张牌（m为点E的横坐标max，向上取整）。",
	["jl_jiuxuevs:jl_jiuxuevs0"] = "究学：平面直角坐标系内，存在y=-x/3+√3与Y轴相交于点A，与X轴相交于点B，点C处于Y轴上且直线CP垂直AB于点P，交Y轴于点C；点P的横坐标为3；在X轴上有一点E，使 S△ACE=1/2 S△ACP。你可以选择解出这道题，然后选择正确的答案；是否选择答案？",
	["#jl_jiuxuevs1"] = "%from 解出 %arg 的答案为 %arg2",
	["jl_jiuxuevs2"] = "正确",
	["jl_jiuxuevs3"] = "错误",
	["jl_chenshou"] = "陈寿",
	["#jl_chenshou"] = "浮笔显毫微",
	["designer:jl_chenshou"] = "紫髯的小乔",
	["illustrator:jl_chenshou"] = "三国志大战",
	["jl_zhendian"] = "正典",
	[":jl_zhendian"] = "使命技。出牌阶段开始时，你可以选择一项：1、搜寻或销毁一张智囊牌名的锦囊牌，摸两张牌；2、废除或恢复一个装备栏，将其中的牌置入“仁”区并回复1点体力。背水：先执行一次“整肃”。\n<font color=\"black\"><b>成功</b></font>：若游戏外的智囊牌名或装备牌副类别不少于三种，你获得游戏外的这些牌，将此技能改为转换技，选项1和2分别改为①和②效果。\n<font color=\"black\"><b>失败</b></font>：若你以此法“整肃”失败，则使命失败。",
	["jl_zhendian1"] = "搜寻或销毁一张智囊牌名的锦囊牌",
	["jl_zhendian2"] = "废除或恢复一个装备栏",
	["jl_zhendianvs"] = "正典",
	[":jl_zhendianvs"] = "转换技。出牌阶段开始时，你可以①搜寻或销毁一张智囊牌名的锦囊牌，摸两张牌②废除或恢复一个装备栏，将其中的牌置入“仁”区并回复1点体力。",
	[":jl_zhendianvs1"] = "转换技。出牌阶段开始时，你可以①搜寻或销毁一张智囊牌名的锦囊牌，摸两张牌<font color=\"#01A5AF\"><s>②废除或恢复一个装备栏，将其中的牌置入“仁”区并回复1点体力</s></font>。",
	[":jl_zhendianvs2"] = "转换技。出牌阶段开始时，你可以<font color=\"#01A5AF\"><s>①搜寻或销毁一张智囊牌名的锦囊牌，摸两张牌</s></font>②废除或恢复一个装备栏，将其中的牌置入“仁”区并回复1点体力。",
	["jl_zhendian3"] = "先执行一次“整肃”",
	["beishui_choice=jl_zhendian3"] = "背水 先执行一次“整肃”",
	["jl_zhendian4"] = "正典：你可以选择销毁一张智囊牌名的锦囊牌，否则将搜寻一张智囊牌名的锦囊牌",
	["jl_qianxue"] = "潜学",
	[":jl_qianxue"] = "蜀势力技。隐匿：你登场时弃置X张牌并施法：获得X点护甲。",
	["jl_qianxue0"] = "潜学：请弃置1~3张牌用以[施法]",
	["jl_chailu"] = "采录",
	[":jl_chailu"] = "晋势力技。强令：令一名其他角色交给你一张游戏外没有的非基本牌。\n<font color=\"black\"><b>成功</b></font>：其摸一张牌；\n<font color=\"black\"><b>失败</b></font>：此阶段结束时，你可以多发动一次“正典”。",
	["jl_chailu0"] = "采录-强令：请选择令一名其他角色交给你一张游戏外没有的非基本牌",
	["jl_chailu1"] = "采录-强令：请交给 %src 一张游戏外没有的非基本牌",
	["jl_siju"] = "排位四巨",
	["#jl_siju"] = "得心应手",
	["designer:jl_siju"] = "lua学生",
	["illustrator:jl_siju"] = "",
	["jl_shenchong"] = "神宠",
	["#jl_shenchong"] = "首刹的先知",
	["designer:jl_shenchong"] = "Lua学生",
	["illustrator:jl_shenchong"] = "",
	["jl_jiejun"] = "劫军",
	[":jl_jiejun"] = "当你使用【杀】指定目标时，你可以依次执行：1、摸一张牌（执行6次），2、将目标所有手牌扣置于其武将牌上（此回合结束时你获得这些牌），3、你交给目标一张牌，4、令此【杀】不计入次数，5、此【杀】结算后，你将之交给一名其他角色。",
	["jl_chousi"] = "筹思",
	[":jl_chousi"] = "出牌阶段限一次。你可以摸5张牌并受到1点伤害，然后进行一次判定，若为红色，你令一名其他角色摸两张牌，若为黑色，你弃置一名其他角色一张牌。",
	["jl_jiejun0"] = "劫军：请选择一名其他角色，将此【杀】交给其",
	["jl_chousi0"] = "筹思：请选择一名其他角色；红色，其摸两张牌；黑色，弃置其一张牌",
	["$jl_bingfen"] = "%from（玩家）启用了 %arg",
	["jl_bingfen"] = "缤芬模式",
	["jl_bingfen:jl_bingfen0"] = "你可以开启【缤芬模式】，是否开启【缤芬模式】？",
	["jl_shenci"] = "神赐",
	["#jl_shenci"] = "稀世大王霸",
	["designer:jl_shenci"] = "Lua学生",
	["illustrator:jl_shenci"] = "",
	["jl_jice"] = "激策",
	[":jl_jice"] = "每当你使用红色【杀】或【决斗】指定目标时，你可以依次执行：1、摸一张牌，2、对其造成1点伤害，3、进行判定，红色，你摸两张牌，黑色，弃置其区域内一张牌，4、观看其所有手牌并弃置其中每种花色各一张，5、若你的牌数大于其，此【杀】对其伤害+1。",
	["jl_xiongyi"] = "凶异",
	[":jl_xiongyi"] = "出牌阶段限一次。你可以令一名角色摸两张牌，然后对其造成2点伤害；若其因此阵亡，你选择获得一项技能：“当先”、“制蛮”。",
	["jl_kuangshe"] = "狂射",
	[":jl_kuangshe"] = "你可以将一张牌当做【杀】对所有其他角色使用，并摸等目标数张牌，然后依次获得这些角色区域内一张牌；结算后你将此【杀】置于牌堆顶。",
	["jl_xyy"] = "袭羊羊",
	["#jl_xyy"] = "懿谋羊勇",
	["designer:jl_xyy"] = "Lua学生",
	["illustrator:jl_xyy"] = "Lua学生",
	["jl_yangxi"] = "羊袭",
	[":jl_yangxi"] = "准备阶段，你可以对一名角色随机造成-2~2点伤害。",
	["jl_yangxi0"] = "羊袭：你可以选择一名角色造成伤害",
	["jl_yisuan"] = "懿算",
	[":jl_yisuan"] = "出牌阶段，你可以将武将牌替换为“吴懿”进行游戏；阶段结束后还原。",
	["jl_liuxu"] = "刘诩",
	["#jl_liuxu"] = "寰宇之极数",
	["designer:jl_liuxu"] = "",
	["illustrator:jl_liuxu"] = "",
	["jl_boji"] = "博极",
	[":jl_boji"] = "锁定技若厮刑主公于喋血汝受其倾朝权野之号予号者居咸位列是其牌漫五也汝崩之亦射毕若任伻他益命汝益其锦华佳人之号每其摸牌益之一二若者使锦囊之牌益三有四汝瓒其曰博极群书之号称卿挂相而不达于咸后二者终有此号且惟施于友",
	["jl_jiuxue"] = "究学",
	[":jl_jiuxue"] = "锁定技。设你此回合使用的牌数为X，你区域内的牌数为Y；若 (X,Y) 符合 Y=±(2X±X±1) ，则你将手牌摸至(±2X!±2,Y) 中Y的任意实数根张（Y≥0且向上取整）；若你以此法调整了3次手牌，你修改此技能。\n<font color=\"black\"><b>修改</b></font>：平面直角坐标系内，存在y=-x/3+√3与Y轴相交于点A，与X轴相交于点B，点C处于Y轴上且直线CP垂直AB于点P，交Y轴于点C；点P的横坐标为3；在X轴上有一点E，使 S△ACE=1/2 S△ACP；出牌阶段开始时，你可以摸m张牌（m为点E的横坐标max，向上取整）。",
	["jl_shiyi"] = "师夷",
	[":jl_shiyi"] = "While game start phase,you can target a character,skip the next turn of that character.When a character who is in your attack range uses a handcard,you can use a handcard with a same card-name. And if you uses at least 3 cards in this way,you can cause 1 damage to this character.",
	["jl_boji1"] = "倾朝权野",
	["jl_boji2"] = "锦华佳人",
	["jl_boji3"] = "博极群书",
	["jl_shiyi0"] = "Shiyi:You can choose a target",
	["jl_shiyi1"] = "Shiyi:You can use a 【%src】",
	["jl_sunce1"] = "孙策",
	["#jl_sunce1"] = "江东小王霸",
	["designer:jl_sunce1"] = "",
	["illustrator:jl_sunce1"] = "",
	[":jl_sunben"] = "觉醒技。当你体力上限为1时，你获得技能“魂姿”。",
	["jl_bashen"] = "八神",
	["#jl_bashen"] = "福禄永驻",
	["designer:jl_bashen"] = "",
	["illustrator:jl_bashen"] = "烧饼浪",
	["jl_wuxing"] = "五星上将",
	["#jl_wuxing"] = "热门首选",
	["designer:jl_wuxing"] = "",
	["illustrator:jl_wuxing"] = "",
	["$NotifySkillInvoked_1"] = "%from 发动了 “%arg” ，目标是 %to",
	["$NotifySkillInvoked_2"] = "%from 发动了 “%arg”",
	["up_hp"] = "回复体力",
	["jl_zhijun"] = "治军",
	[":jl_zhijun"] = "你可以将一张♣♠牌当【閷】使用\n<font color=\"black\"><b>閷 基本牌<br /><b>卡牌效果</b>：此牌可视为【杀】或【闪】使用。</b></font>",
	["__jl_sha"] = "閷",
	["jl_sha"] = "閷",
	[":__jl_sha"] = "基本牌<br /><b>卡牌效果</b>：此牌视为【杀】和【闪】的使用效果。",
	["jl_fushi"] = "赋诗",
	[":jl_fushi"] = "出牌阶段限一次，你可以弃置至少两张不同花色的手牌，然后选择摸等量的牌或回复1点体力",
	["jl_jianxiong"] = "奸雄",
	[":jl_jianxiong"] = "当你受到伤害后，你可以获得造成伤害的牌或对伤害来源使用一张【杀】",
	["jl_nengchen"] = "能臣",
	[":jl_nengchen"] = "锁定技，你的摸牌数等于体力上限",
	["jl_canzheng"] = "残政",
	[":jl_canzheng"] = "主公技，当你杀死一名角色后，你可以增加1点体力上限并回复1点体力",
	["jl_daishou"] = "代首",
	[":jl_daishou"] = "限定技，当你受到伤害时，你可以弃置任意张牌，然后令此伤害-X（X为你弃置的牌数）",
	["jl_bianjie"] = "变节",
	[":jl_bianjie"] = "觉醒技，准备阶段，若你造成或受到的伤害数累计大于你的体力上限，你扣减1点体力上限，然后你发动“奸雄”时可以摸一张牌",
	["jl_qiangzhen"] = "强阵",
	[":jl_qiangzhen"] = "转化技，若你的体力值大于4，你使用的杀数+X；若你的体力值不大于4，你的手牌上限+X（X为存活角色数）",
	["jl_yitian"] = "倚天",
	[":jl_yitian"] = "奋发技，当你造成伤害时，你可以回复1点体力 \n<font color=\"red\"><b>奋发技为体力值小于体力上限的一半时可发动（向下取整）</b></font>",
	["jl_shewei"] = "涉危",
	[":jl_shewei"] = "联动技，当一名角色发动“强袭”或“裸衣”时，你可以令你与其当中手牌数较小的一方摸一张牌",
	["jl_jixu"] = "击虚",
	[":jl_jixu"] = "转换技，当你使用[阳]基本牌/[阴]锦囊牌，指定目标后，若你的手牌数大于其，你可以令其无法响应",
	[":jl_jixu2"] = "转换技。当你使用<font color=\"#01A5AF\"><s>[阳]基本牌/</s></font>[阴]锦囊牌，指定目标后，若你的手牌数大于其，你可以令其无法响应",
	[":jl_jixu1"] = "转换技。当你使用[阳]基本牌<font color=\"#01A5AF\"><s>/[阴]锦囊牌</s></font>，指定目标后，若你的手牌数大于其，你可以令其无法响应",
	["jl_mengsha"] = "梦杀",
	[":jl_mengsha"] = "隐匿技，当你于其他角色回合登场后，你可以令当前回合角色扣减1点体力上限",
	["jl_jianshi"] = "剑誓",
	[":jl_jianshi"] = "使命技，当一名角色因你而进入濒死状态后<br />成功：若其死亡，你将“奸雄”中的“获得造成伤害的牌”改为“获得造成伤害的牌并摸一张牌”<br />失败：若其脱离濒死状态，你将“奸雄”中的“对伤害来源使用一张【杀】”改为“视为对伤害来源使用一张【杀】”",
	["jl_caocao"] = "曹操",
	["#jl_caocao"] = "魏武大帝",
	["designer:jl_caocao"] = "",
	["illustrator:jl_caocao"] = "官方",
	["jl_bianjie:jl_bianjie0"] = "你可以发动“变节”效果，摸一张牌",
	["jl_jianshi:jl_jianshi0"] = "你可以执行“剑誓”效果，视为对 %src 使用一张【杀】，否则你获得造成伤害的牌",
	["jl_jianxiong_slash"] = "奸雄：你可以对 %src 使用一张【杀】，否则你获得造成伤害的牌",
	["jl_daishou0"] = "代首：你可以弃置任意张牌，然后减少等量的伤害数",
	["jl_shewei0"] = "涉危：你可以令选择目标摸一张牌",
	["jl_lvxun"] = "吕逊",
	["#jl_lvxun"] = "强势酱油",
	["designer:jl_lvxun"] = "",
	["illustrator:jl_lvxun"] = "",
	["jl_yuji"] = "于吉",
	["designer:jl_yuji"] = "",
	["illustrator:jl_yuji"] = "官方",
	["#jl_yuji"] = "恶毒的道士",
	["jl_zhuzhou"] = "诅咒",
	[":jl_zhuzhou"] = "锁定技。杀死你的角色须执行三国杀最恶毒的诅咒--将武将牌替换为“孙策（山）”。",
	["jl_zhoutai"] = "周泰",
	["#jl_zhoutai"] = "肤如刻画",
	["designer:jl_zhoutai"] = "民间DIY",
	["illustrator:jl_zhoutai"] = "真三国无双",
	["jl_buhui"] = "不悔",
	[":jl_buhui"] = "锁定技。你不能成为【杀】和【桃】的目标。",
	["yao"] = "妖",
	["jl_wangtaoyue"] = "王桃悦",
	["#jl_wangtaoyue"] = "晔兮如莹",
	["designer:jl_wangtaoyue"] = "lua学生",
	["illustrator:jl_wangtaoyue"] = "",
	["jl_huguan"] = "护关",
	[":jl_huguan"] = "一名角色于其回合内使用第一张牌时，若为红色，你可以弃置一张牌，则其此回合内与你弃置牌花色相同的牌不计入手牌上限，然后若其弃牌阶段未弃牌，你摸一张牌。",
	["jl_luanpei"] = "鸾佩",
	[":jl_luanpei"] = "其他角色回合结束时，若此回合内有角色回复过体力，你可以弃置一张其未于弃牌阶段弃置过的花色的牌，则你令你们其中一名角色回复1点体力，然后手牌数较少的角色将手牌补至与另一名角色相同（至多补至5张）。",
	["jl_huguan0"] = "护关：你可以弃置一张牌，则 %src 此回合内与你弃置牌花色相同的牌不计入手牌上限",
	["jl_luanpei0"] = "鸾佩:你可以弃置一张 %src 未于弃牌阶段弃置过的花色的牌",
	["jl_luanpei1"] = "鸾佩：请选择你们其中一名角色回复1点体力",
	["jl_zhanshen"] = "三国战神",
	["designer:jl_zhanshen"] = "暴躁大宝",
	["illustrator:jl_zhanshen"] = "侠民",
	["#jl_zhanshen"] = "破军之矛",
	["jl_poying"] = "破营",
	[":jl_poying"] = "锁定技。当你使用【杀】指定目标时，你依次执行以下选项：⒈额外指定两名其他角色为目标；⒉目标所有技能失效，直至其回合结束；⒊将目标所有牌扣置于其武将牌上，回合结束时你获得之；⒋若你的手牌数大于目标，则此【杀】不能被其响应；⒌此【杀】伤害+X（X为你使用过的花色数和牌类型数）；⒍造成伤害时你摸5张牌；⒎本回合可以使用的【杀】数+1；⒏其他角色于你回合内陷入濒死状态时，你令其立即死亡。",
	["jl_shenji"] = "神骑",
	[":jl_shenji"] = "锁定技。你不能被翻面；其他角色回合开始前或结束后，你执行一个额外回合；摸牌阶段，你额外摸4张牌；出牌阶段，你使用的牌无距离限制且第一张牌不能被响应；弃牌阶段开始时，你选择：⒈将本回合手牌上限改为当前手牌数，⒉弃置任意张牌并弃置一名其他角色等量的牌，然后对其造成2点伤害。",
	["jl_longjiang"] = "龙将",
	[":jl_longjiang"] = "你的基本牌可以当任意基本牌使用或打出；准备阶段，你可以弃置任意张牌，然后弃置判定区内同颜色的牌。",
	["jl_shenji0"] = "神骑：你可以弃置任意张牌并弃置一名其他角色等量的牌，然后对其造成2点伤害，否则你将本回合手牌上限改为当前手牌数",
	["jl_longjiang0"] = "龙将：你可以弃置任意张牌，然后弃置判定区内同颜色的牌。",
	["jl_poying0"] = "破营：请额外指定两名其他角色为目标",
	["jl_huasuo"] = "华索",
	["designer:jl_huasuo"] = "lua学生",
	["illustrator:jl_huasuo"] = "",
	["#jl_huasuo"] = "冷血孑侠",
	["jl_jueqing"] = "绝情",
	[":jl_jueqing"] = "锁定技。你造成的伤害+1，且均视为体力流失。",
	["jl_xiefang"] = "撷芳",
	[":jl_xiefang"] = "锁定技。你计算与其他女性角色距离为1；女性角色不能响应你的牌。",
	["jl_heyan"] = "何晏",
	["designer:jl_heyan"] = "lua学生",
	["illustrator:jl_heyan"] = "",
	["#jl_heyan"] = "傅粉何娘",
	["jl_qingtan"] = "轻弹",
	[":jl_qingtan"] = "出牌阶段限一次。你可以令所有其他有手牌的角色各展示一张手牌，然后你获得这些展示的牌。",
	["jl_qingtan0"] = "轻弹：请选择一张手牌用于展示",
	["jl_yachai"] = "睚钗",
	[":jl_yachai"] = "当你受到其他角色的伤害后，你可以令其弃置一半的手牌（向上取整）并将剩余的手牌交给你。",
	["jl_erciyuan"] = "二次袁",
	["#jl_erciyuan"] = "兄弟患难",
	["designer:jl_erciyuan"] = "",
	["illustrator:jl_erciyuan"] = "官方",
	["jl_neifa"] = "内伐",
	[":jl_neifa"] = "出牌阶段限一次，你可以摸两张牌并将一张牌置于牌阶段顶或底部，然后将不同颜色的另一张牌置"..
	"于牌堆的另一端；若牌堆顶牌的颜色为：[阴]，红色，你从牌堆中摸三张不同类型的黑色牌并展示三张不同类型的黑色"..
	"牌；根据展示结果：y为偶数，你可以令至多x名角色各摸一张牌；y为奇数，你可以令至多x名角色各弃置一张牌；然后"..
	"若y可以被x整除（x为三张牌中最小的差且不为负数，y为点数之和），则你获得x枚“伐”标记（记为z）并可以于此阶段"..
	"内额外发动一次“内伐”且不能再选择[阴]。[阳]，黑色，你展示下家一张手牌，若为黑色，你获得之并令其摸或弃x张牌，"..
	"否则你展示其下家一张牌重复此流程，若无可展示的目标，你获得这些展示的红色牌并随机分配给对应的角色，此时若z等"..
	"于这些角色数，你可以弃置牌堆顶z张牌对这些角色各造成1点伤害，然后受到伤害的角色依次与你拼点，赢的角色可以终止"..
	"未开始的拼点并摸z张牌和弃置等量的牌，若弃置牌中有一张牌的颜色与其他牌颜色均不同，则其可以观看一名角色的手牌并"..
	"获得其中的一张异色牌，记录此牌为a，弃置的异色牌为b，若a点数>b点数，你令其将a置于牌堆顶并视为其发动“内伐”[阴]；"..
	"你可以令a点数+z后执行：计算a点数+b点数、a点数–b点数和a点数*b点数，记最大值为max，最小值为min，若 y=max*x^2+min*"..
	"x+a^2 有两个不相同的根，则你可以弃置一名角色至多（a点数–b点数）张牌并令b点数+等量的牌，若此时a点数等于b点数，你"..
	"下一次发动“内伐”可以额外将一张同色牌置于牌堆顶或底部且你可以令x、y、z、max、min、a点数、b点数随意+z或–z。此时若z"..
	"为3的倍数且大于8，你摸21张牌并将手牌数调整至21张并展示之，然后你可以将手牌按斗地主规则打出直到有人管得上你为止；"..
	"若以此法打出了所有手牌，你此阶段可以额外发动一次“内伐”且不能选择[阳]；若有人以此法管上了你且你要不起，你结束此阶"..
	"段，其获得一个额外回合且其出牌阶段开始时视为其发动一次“内伐”。",
	["jl_neifa0"] = "内伐：请选择一张牌",
	["jl_neifa01"] = "内伐：请选择另一张不同颜色的牌",
	["jl_neifa1"] = "内伐：请选择每种类型各一张的黑色牌",
	["jl_neifa02"] = "内伐：你可以额外选择一张牌按颜色置于牌堆顶或底部",
	["jl_neifa2"] = "内伐：你可以按点数之和 %dest 的奇偶令 %src 名角色摸牌或弃牌 ",
	["jl_neifa:jl_neifa4"] = "内伐：你可以弃置牌堆顶 %src 张牌，对这些角色各造成1点伤害",
	["jl_neifa:jl_neifa5"] = "内伐：你可以终止后面的拼点，然后摸 %src 张牌并弃置等量的牌",
	["jl_neifa6"] = "内伐：你可以观看一名角色的手牌并获得其中的一张异色牌",
	["$jl_neifa7"] = "函数：%arg 在实数域 %arg1 两个不相同的根",
	["no_jl_neifa7"] = "没有",
	["yes_jl_neifa7"] = "有",
	["jl_neifa8"] = "内伐：你可以选择弃置一名角色至多 %src 张牌",
	["jl_DouDiZhu"] = "斗地主",
	["jl_DouDiZhu0"] = "斗地主：请选择牌打出",
	["jl_DouDiZhu1"] = "斗地主：你可以响应 %src ，打出大于其的牌",
	["a_to_z"] = "令a点数+z（z为“伐”数）",
	["jl_fa"] = "伐",
	["  "] = "  ",
	["jl_zhouyu"] = "周瑜",
	["#jl_zhouyu"] = "大嘟嘟",
	["designer:jl_zhouyu"] = "lua学生",
	["illustrator:jl_zhouyu"] = "",
	["jl_xiongzi"] = "雄姿",
	[":jl_xiongzi"] = "摸牌阶段，你可以额外摸X张牌。（X为场上女性角色数）",
	["jl_xixiong"] = "袭凶",
	[":jl_xixiong"] = "出牌阶段每名女性角色限一次。你可以观看一名女性角色的所有手牌，选择获得其中一种花色的所有牌，然后其摸等量的牌。",
	["jl_shenma"] = "神马",
	["designer:jl_shenma"] = "lua学生",
	["illustrator:jl_shenma"] = "lua学生",
	["#jl_shenma"] = "都是浮云",
	["jl_shenzhu"] = "神助",
	[":jl_shenzhu"] = "锁定技。你触发以下技能：<br />“铁骑”、“散谣”、“制蛮”、“抚蛮”、“自书”、“应援”、“潜袭”；<br />你计算与其他角色距离-2。",
	["fuman_to"] = "抚蛮-目标",
	["sanyao_hand"] = "散谣-最大手牌",
	["sanyao_hp"] = "散谣-最大体力",
	["jl_zhaoyun"] = "赵云完全体",
	["&jl_zhaoyun"] = "赵云",
	["#jl_zhaoyun"] = "游刃有余",
	["jl_wuyi"] = "吴懿",
	["designer:jl_wuyi"] = "lua学生",
	["illustrator:jl_wuyi"] = "lua学生",
	["#jl_wuyi"] = "乱世名将",
	["jl_mingqi"] = "名气",
	[":jl_mingqi"] = "当你于回合内使用非装备牌指定目标后，你可以弃置不为此牌目标的一名角色一张牌，然后其摸一张牌。出牌阶段限一次，当你使用的锦囊牌进入弃牌堆后，你可以减1点体力上限收回之。你于出牌阶段内对一名其他角色造成伤害后，你可以废除一个装备栏并选择其一个技能（限定技、觉醒技、主公技除外），则其下回合结束前此技能无效，然后你于其下回合结束或其死亡前拥有此技能且此期间内不能再发动此效果。当你受到1点伤害后，你可以将一张牌当做“锋”置于武将牌上；准备阶段开始时你移去所有“锋”，摸2X张牌，然后本回合你可以使用【杀】数+X（X为本回合移去“锋”的数量）。结束阶段开始时，你随机观看一名其他角色的X张随机手牌（X为全场手牌数最少的角色手牌数）；然后你可以令一名其他角色从牌堆中获得一张♥基本牌，若其于上回合成为过此效果的目标，其失去1点体力。一名其他角色的出牌阶段开始时，你可以摸两张牌，然后交给其两张牌，则本阶段结束后，若其未于本阶段杀死过一名角色，你失去1点体力。",
	["jl_mingqi:jl_mingqi1"] = "名气：你可以失去1点体力上限，收回【%src】",
	["jl_mingqi:jl_mingqi2"] = "名气：你可以将一张牌当做“锋”置于武将牌上",
	["jl_mingqi3"] = "名气：请选择一张牌当做“锋”置于武将牌上",
	["jl_mingqi4"] = "名气：你可以令一名其他角色从牌堆中获得一张♥基本牌",
	["jl_mingqi:jl_mingqi5"] = "名气：你可以摸两张牌，然后交给 %src 两张牌",
	["jl_mingqi0"] = "名气：你可以弃置不为此【%src】目标的一名角色的一张牌，然后其摸一张牌",
	["jl_mingqi_feng"] = "锋",
	["jl_mingqi6"] = "名气：请选择交给 %src 两张牌",
	["jl_mingqi7"] = "名气：你可以令一名其他角色选择是否交给你一张牌",
	["jl_mingqi8"] = "名气：你可以交给 %src 一张牌，然后其视为使用一张【%dest】",
	["jl_mingqi9"] = "名气：请视为使用一张【%src】",
	["jl_ceyu"] = "策瑜",
	["designer:jl_ceyu"] = "lua学生",
	["illustrator:jl_ceyu"] = "",
	["#jl_ceyu"] = "江东英秀",
	["jl_jiaoxin"] = "交心",
	[":jl_jiaoxin"] = "出牌阶段，若你已受伤且体力值为1，你可以摸一张牌并回复1点体力。",
	["jl_xusheng"] = "徐盛",
	["designer:jl_xusheng"] = "lua学生",
	["illustrator:jl_xusheng"] = "",
	["#jl_xusheng"] = "无常索命",
	["jl_judao"] = "菊刀",
	[":jl_judao"] = "锁定技。若你未装备武器，你视为装备着【古锭刀】。",
	["jl_zhuanhuaqi"] = "转化器",
	["#jl_zhuanhuaqi"] = "戏法大师",
	["designer:jl_zhuanhuaqi"] = "lua学生",
	["illustrator:jl_zhuanhuaqi"] = "lua学生",
	["jl_xishua"] = "戏耍",
	[":jl_xishua"] = "你可以发动以下技能：<br />“蛊惑”、“奇策”、“龙魂”、“奇袭”、“断粮”、“国色”、“武圣”、“龙胆”、“急救”、“火计”、“看破”、“连环”、“急袭”、“乱击”、“酒池”、“双雄”、“倾国”；然后将以此法造成伤害的牌当做“田”置于武将牌上。",
	["jl_xishua0"] = "戏耍：发动“%src” ",
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
	["#NOGuhuoQuery"] = "%from 体力值不大于0，不能 %arg",
	["jl_wudaoshi"] = "五道士",
	["#jl_wudaoshi"] = "通天化地",
	["designer:jl_wudaoshi"] = "lua学生",
	["illustrator:jl_wudaoshi"] = "lua学生",
	["jl_daoshu"] = "道术",
	[":jl_daoshu"] = "你可以于相应时机发动以下技能：<br />“雷击”、“鬼道”、“化身”、“新生”、“蛊惑”、“咒缚”、“影兵”、“义舍”、“布施”、“米道”",
	["@jl_daoshu"] = "道术：请选择一张手牌蛊惑【%src】",
	["guhuo_question:question0"] = "%src 选择了蛊惑【%dest】,是否质疑？",
	["jl_yingziy"] = "英姿",
	[":jl_yingziy"] = "摸牌阶段，你可以额外摸一张牌。",
	["jl_jiangy"] = "激昂",
	[":jl_jiangy"] = "每当你指定或成为【决斗】或红色【杀】的目标后，你可以摸一张牌。",
	["jl_miansha"] = "面杀之主",
	["#jl_miansha"] = "神之右手",
	["designer:jl_miansha"] = "lua学生",
	["illustrator:jl_miansha"] = "官方",
	["jl_yegui"] = "越规",
	[":jl_yegui"] = "你可以跳过判定阶段,并将判定区的牌弃置；摸牌阶段，你可以额外摸一张牌；出牌阶段，你可以观看相邻角色的手牌；弃牌阶段，若你的手牌数不为场上最多，你可以跳过弃牌；你使用牌无距离限制；每当【顺手牵羊】或【过河拆桥】对你生效时，你可以将任意张手牌置于武将牌上，此牌结算后你收回之；多目标锦囊生效时，你可以使用【无懈可击】抵消所有效果；【决斗】过程中，你可以使用【无懈可击】抵消效果；其他角色出牌阶段开始时，若你已受伤，你可以使用【桃】；回合结束后，你可以回复1点体力；你的使用属性【杀】伤害+1。",
	["jl_yegui0"] = "越规：你成为了【%src】的目标，可以选择将任意张手牌置于武将牌上",
	["jl_yegui1"] = "越规：你已受伤，可以使用一张【%src】",
	["jl_yegui:jl_yegui2"] = "越规：你可以额外摸一张牌",
	["jl_yegui:jl_yegui3"] = "越规：你已受伤，可以回复1点体力",
	["jl_yegui:jl_yegui4"] = "越规：你可以跳过判定阶段,然后将判定区的牌弃置",
	["jl_yegui:jl_yegui5"] = "越规：你的手牌数不为场上最多，你可以跳过弃牌",
	["  "] = "  ",
	["jl_liuyan"] = "刘焉",
	["#jl_liuyan"] = "立墓为志",
	["designer:jl_liuyan"] = "lua学生",
	["illustrator:jl_liuyan"] = "",
	["jl_tuse"] = "图涩",
	[":jl_tuse"] = "你使用牌指定目标后，你可以摸X张牌。（X为目标中包含的其他角色数）",
	["jl_limu"] = "立墓",
	[":jl_limu"] = "出牌阶段，若你的判定区没有“墓”，你可以将一张牌当作“墓”置于判定区，判定阶段时进行判定，若颜色相同，你失去所有体力，判定结束后弃置“墓”；若你拥有“墓”，你使用牌无距离与次数限制。",
	["__jl_mu"] = "墓",
	["jl_tuse:jl_tuse0"] = "你可以发动“图涩”摸 %src 张牌",
	["jl_womensa"] = "我们仨",
--	["&jl_womensa"] = "嘉才叡",
	["#jl_womensa"] = "太强了",
	["designer:jl_womensa"] = "lua学生",
	["illustrator:jl_womensa"] = "lua学生",
	["jl_xingtuo"] = "兴拓",
	[":jl_xingtuo"] = "当你陷入濒死状态后，你可以令所有其他同势力的角色选择是否受到1点伤害令你回复1点体力。当你受到伤害后，你可以令一名角色进行一次判定，若结果为：红色，其回复1点体力；黑色，其摸X张牌（X为此次伤害数）。",
	["jl_xianchou"] = "先筹",
	[":jl_xianchou"] = "锁定技。当你不因此技能而受到伤害后，你受到等量伤害；当你不因此技能而回复体力后，你回复等量体力；当你受到伤害后，你进行一次判定，若结果为：黑色，弃置一名角色区域内一张牌；红色，令一名角色摸一张牌（若为你则摸两张）。",
	["jl_xingtuo0"] = "兴拓：你可以令一名角色进行判定----若结果为：红色，其回复1点体力；黑色，其摸X张牌（X为此次伤害数）",
	["jl_xianchou0"] = "先筹：请选择一名角色执行效果----黑色，弃置一名角色区域内一张牌；红色，令一名角色摸一张牌（若为你则摸两张）",
	["jl_yuerqiao"] = "瑜二乔",
	["#jl_yuerqiao"] = "赤壁的火欲",
	["designer:jl_yuerqiao"] = "lua学生",
	["illustrator:jl_yuerqiao"] = "",
	["jl_sexiang"] = "色香",
	[":jl_sexiang"] = "出牌阶段，你可以一张♦牌当【乐不思蜀】对自己使用，然后你获得“激昂”。其他角色受到伤害时，你可以弃置一张♥手牌将此伤害转移给你，然后你获得“英姿”。（若已拥有对应技能，则该技能摸牌数值+1）",
	["jl_yanyin"] = "炎音",
	[":jl_yanyin"] = "每轮限一次。你可以弃置至少两张手牌令场上所有角色回复1点体力或受到1点火焰伤害。",
	["jl_yanyin1"] = "全场伤害",
	["jl_yanyin2"] = "全场回复",
	["jl_sexiang0"] = "色香：你可以弃置一张 %src 手牌将 %dest 受到的伤害转移给你",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["$jl_lianhuansr"] = "%from 为 %to 选择使用【%arg2】的目标为 %arg",
	["$tianzhai"] = "%from 的延时锦囊【%arg】开始判定",
	["jl_wuxiesy-use"] = "你可以使用【无懈生有】抵消 %src 对 %dest 效果，然后摸两张牌。",
	["jl_wuxiesyuse"] = "你可以使用【%dest】抵消 %src 效果，然后摸两张牌。",
	["#YinshiProtect"] = "%from 的“<font color=\"yellow\"><b>隐士</b></font>”效果被触发，防止了 %arg 点伤害[%arg2]",
	["jl_sandazhugong"] = "三大主公",
--	["&jl_sandazhugong"] = "曹刘孙",
	["#jl_sandazhugong"] = "三分天下",
	["designer:jl_sandazhugong"] = "BOBO",
	["illustrator:jl_sandazhugong"] = "BOBO",
	["jl_youka"] = "游卡",
	["#jl_youka"] = "罄竹难书",
	["designer:jl_youka"] = "lua学生",
	["jl_wuma"] = "无马",
	[":jl_wuma"] = "锁定技。你始终废除坐骑栏；你的坐骑牌视为【无中生有】；你受到【杀】的伤害时，若来源装备【麒麟弓】，此伤害+1。",
	["jl_pianke"] = "骗氪",
	[":jl_pianke"] = "出牌阶段，若你没有“盒子”，你可以将至少一张手牌当作“盒子”置于武将牌上，然后摸等量的牌；一名其他角色出牌阶段开始时，若你有“盒子”且其有手牌，你可以令其交给你一张手牌，则其随机获得你一张“盒子”，然后若这两张牌点数不同，其受到1点伤害，否则你失去1点体力。",
	["pianke"] = "盒子",
	["jl_yinbing"] = "阴兵",
	[":jl_yinbing"] = "每名角色回合限一次。你可以视为使用或打出一张基本牌或非延时锦囊牌，然后对一名其他角色造成1点伤害。",
	["jl_zhugong"] = "主公",
	[":jl_zhugong"] = "主公技。当你需要使用或打出一张【杀】或【闪】时，你可以令其他魏蜀吴势力角色打出一张【杀】或【闪】（视为由你使用或打出）；其他魏蜀吴势力角色对你使用的【桃】回复值+1。",
	["#jl_zhugonguse"] = "%from %arg 选择使用【%arg1】的目标为 %to",
	["@jl_zhugong-card"] = "你可以替 %src 出 %dest",
	["#jl_yeduj"] = "延时锦囊",
	["jl_sizhugong"] = "四群主公",
--	["&jl_sizhugong"] = "张董袁",
	["#jl_sizhugong"] = "群之霸者",
	["designer:jl_sizhugong"] = "BOBO",
	["illustrator:jl_sizhugong"] = "BOBO",
	["  "] = "  ",
	["jl_sanyuanse"] = "三原色",
--	["&jl_sanyuanse"] = "周魏曹",
	["#jl_sanyuanse"] = "人肉沙包",
	["designer:jl_sanyuanse"] = "BOBO",
	["illustrator:jl_sanyuanse"] = "BOBO",
	["  "] = "  ",
	["jl_wuhujiang"] = "五虎上将",
--	["&jl_wuhujiang"] = "关张赵马黄",
	["#jl_wuhujiang"] = "蜀之脊梁",
	["designer:jl_wuhujiang"] = "BOBO",
	["illustrator:jl_wuhujiang"] = "BOBO",
	["  "] = "  ",
	["jl_wuguogai"] = "吴国盖",
--	["&jl_wuguogai"] = "吴国盖",
	["#jl_wuguogai"] = "郎情妾意",
	["designer:jl_wuguogai"] = "BOBO",
	["illustrator:jl_wuguogai"] = "BOBO",
	["  "] = "  ",
	["jl_yuxun"] = "于逊",
--	["&jl_yuxun"] = "于逊",
	["#jl_yuxun"] = "不败的存在",
	["designer:jl_yuxun"] = "BOBO",
	["illustrator:jl_yuxun"] = "BOBO",
	["  "] = "  ",
	["jl_zhenjiao"] = "甄角",
--	["&jl_zhenjiao"] = "甄角",
	["#jl_zhenjiao"] = "天公美人",
	["designer:jl_zhenjiao"] = "qazxcvbnm11100",
	["illustrator:jl_zhenjiao"] = "qazxcvbnm11100",
	["  "] = "  ",
	["jl_zgyy"] = "诸葛月英",
--	["&jl_zgyy"] = "诸葛月英",
	["#jl_zgyy"] = "奇才卧龙",
	["designer:jl_zgyy"] = "BOBO",
	["illustrator:jl_zgyy"] = "BOBO",
	["jl_wumeinv"] = "五美女",
--	["&jl_wumeinv"] = "甄貂乔乔孙",
	["#jl_wumeinv"] = "当世绝色",
	["designer:jl_wumeinv"] = "BOBO",
	["illustrator:jl_wumeinv"] = "BOBO",
	["jl_qingshen"] = "倾神",
	[":jl_qingshen"] = "你可以将一张黑色手牌当【闪】使用或打出。准备阶段开始时，你可以进行一次判定，若判定结果为黑色，你获得生效后的判定牌且你可以重复此流程。",
	["jl_liyue"] = "离月",
	[":jl_liyue"] = "出牌阶段限一次，你可以弃置一张牌并选择两名男性角色：若如此做，视为其中一名角色对另一名角色使用一张【决斗】。结束阶段开始时，你可以摸一张牌。",
	["jl_liuse"] = "流色",
	[":jl_liuse"] = "你可以将一张♦牌当【乐不思蜀】使用。当你成为【杀】的目标时，你可以弃置一张牌，将此【杀】转移给你攻击范围内的一名其他角色（此【杀】的使用者除外）。",
	["@jl_liuse"] = "你可以弃置一张手牌将 %src 的【杀】的目标转移给你攻击范围内的一名其他角色",
	["jl_tianyan"] = "天颜",
	["jl_tianyanbf"] = "天颜",
	["@jl_tianyan-card"] = "你可以弃置一张♥手牌将此伤害转移给一名其他角色",
	[":jl_tianyan"] = "当你受到伤害时，你可以弃置一张♥手牌，将此伤害转移给一名其他角色，然后该角色摸X张牌（X为该角色已损失的体力值）。你的♠牌均视为♥牌。",
	["jl_xiaoyin"] = "枭姻",
	[":jl_xiaoyin"] = "出牌阶段限一次，你可以弃置两张手牌并选择一名已受伤的男性角色，你和该角色各回复1点体力。每当你失去一张装备区的装备牌后，你可以摸两张牌",
	["jl_wuzhinang"] = "五智囊",
--	["&jl_wuzhinang"] = "懿嘉彧植华",
	["#jl_wuzhinang"] = "魏之奇才",
	["designer:jl_wuzhinang"] = "BOBO",
	["illustrator:jl_wuzhinang"] = "BOBO",
	["jl_guikui"] = "鬼馈",
	[":jl_guikui"] = "每当一名角色的判定牌生效前，你可以打出一张手牌代替之。每当你受到伤害后，你可以获得伤害来源的一张牌。",
	["jl_tianji"] = "天计",
	[":jl_tianji"] = "你的判定牌生效后，你可以获得此牌。每当你受到1点伤害后，你可以观看牌堆顶的两张牌，然后将这两张牌任意分配。",
	["jl_quming"] = "驱命",
	[":jl_quming"] = "出牌阶段限一次，你可以与一名体力值大于你的角色拼点：若你赢，其对其攻击范围内你选择的另一名角色造成1点伤害。若你没赢，其对你造成1点伤害。每当你受到1点伤害后，你可以令一名角色将手牌补至X张（X为该角色的体力上限且至多为5）。",
	["jl_luoshi"] = "落诗",
	[":jl_luoshi"] = "若你武将牌正面朝上，你可以翻面视为使用一张【酒】；当你受到伤害后，若你的武将牌背面朝上，你可以将你的武将牌翻至正面朝上。其他角色的牌因判定或弃置而置入弃牌堆时，你可以获得其中至少一张♣牌。",
	["jl_shangqing"] = "伤情",
	[":jl_shangqing"] = "当你的手牌数小于X时，你可以将手牌补至X张（X为你已损失的体力值）。锁你造成的伤害均视为失去体力。",
	["  "] = "  ",
	["jl_lvbu"] = "完全体吕布",
	["&jl_lvbu"] = "吕布",
	["#jl_lvbu"] = "暴怒修罗战神",
	["designer:jl_lvbu"] = "BOBO",
	["illustrator:jl_lvbu"] = "BOBO",
	["jl_simaji"] = "司马姬",
--	["&jl_simaji"] = "司马姬",
	["#jl_simaji"] = "绝幸的天命",
	["designer:jl_simaji"] = "lua学生",
	["illustrator:jl_simaji"] = "lua学生",
	["jl_dengren"] = "邓仁",
--	["&jl_dengren"] = "邓仁",
	["#jl_dengren"] = "无尽的回合",
	["designer:jl_dengren"] = "BOBO",
	["illustrator:jl_dengren"] = "BOBO",
	["jl_zhugeliang"] = "诸葛亮完全体",
	["&jl_zhugeliang"] = "诸葛亮",
	["#jl_zhugeliang"] = "忠智冠三国",
	["designer:jl_zhugeliang"] = "BOBO",
	["illustrator:jl_zhugeliang"] = "BOBO",
	["jl_qizhang"] = "七张",
--	["&jl_qizhang"] = "七张",
	["#jl_qizhang"] = "智勇兼备",
	["designer:jl_qizhang"] = "BOBO",
	["illustrator:jl_qizhang"] = "BOBO",
	["jl_leidao"] = "雷道",
	[":jl_leidao"] = "每当一名角色的判定牌生效前，你可以打出一张黑色牌替换之。当你使用或打出一张【闪】后，你可以令一名角色进行一次判定，若判定结果为♠，你对其造成2点雷电伤害。",
	["jl_zhizheng"] = "直政",
	[":jl_zhizheng"] = "出牌阶段，你可以将手牌中的一张装备牌置于一名其他角色装备区内：若如此做，你摸一张牌。其他角色的弃牌阶段结束时，你可以将该角色于此阶段内弃置的一张牌从弃牌堆返回其手牌，若如此做，你可以获得弃牌堆里其余于此阶段内弃置的牌。",
	["jl_sijin"] = "四禁",
--	["&jl_sijin"] = "孙华吕曹",
	["#jl_sijin"] = "官方承认",
	["designer:jl_sijin"] = "BOBO",
	["illustrator:jl_sijin"] = "BOBO",
	["jl_lubei"] = "陆备",
--	["&jl_lubei"] = "陆备",
	["#jl_lubei"] = "牌堆全给你",
	["designer:jl_lubei"] = "BOBO",
	["illustrator:jl_lubei"] = "BOBO",
	["jl_sanjunshi"] = "三军师",
--	["&jl_sanjunshi"] = "司马郭荀",
	["#jl_sanjunshi"] = "大魏良材",
	["designer:jl_sanjunshi"] = "BOBO",
	["illustrator:jl_sanjunshi"] = "BOBO",
	["jl_weimou"] = "魏谋",
	[":jl_weimou"] = "每当你受到1点伤害后，你可以令一名角色将手牌补至X张（X为该角色的体力上限且至多为5），然后你可以观看牌堆顶的两张牌，然后分配这些牌。当你受到伤害后，你可以获得伤害来源的一张牌。",
	["jl_sidudu"] = "四都督",
--	["&jl_sidudu"] = "瑜肃蒙逊",
	["#jl_sidudu"] = "吴之屏障",
	["designer:jl_sidudu"] = "BOBO",
	["illustrator:jl_sidudu"] = "BOBO",
	["jl_yingjian"] = "英间",
	[":jl_yingjian"] = "摸牌阶段，你可以额外摸一张牌。出牌阶段限一次，若你有手牌，你可以令一名其他角色选择一种花色，然后其获得你一张手牌，若此牌花色与其选择的花色不同，则其受到1点伤害。",
	["jl_haomeng"] = "好盟",
	[":jl_haomeng"] = "摸牌阶段，你可以额外摸两张牌，然后若你的手牌多于五张，则将一半（向下取整）的手牌交给全场手牌数最少的一名其他角色。出牌阶段限一次，你可以弃置任意数量的牌并选择两名手牌数差等于该数量的其他角色：若如此做，这两名角色交换他们的手牌。",
	["jl_qianying"] = "谦营",
	[":jl_qianying"] = "每当你失去最后的手牌后，你可以摸一张牌。你不能被选择为【顺手牵羊】和【乐不思蜀】的目标。",
	["jl_jiangjiao"] = "姜角",
--	["&jl_jiangjiao"] = "姜角",
	["#jl_jiangjiao"] = "自欠收拾",
	["jl_sihai"] = "宇宙四害",
	["&jl_sihai"] = "四害",
	["#jl_sihai"] = "打我呀",
	["designer:jl_sihai"] = "吃蛋挞的折棒",
	["illustrator:jl_sihai"] = "吃蛋挞的折棒",
	["jl_liuxz"] = "刘玄奘",
--	["&jl_liuxz"] = "刘玄奘",
	["#jl_liuxz"] = "聪明绝顶",
	["designer:jl_liuxz"] = "阎魔老非酋",
	["illustrator:jl_liuxz"] = "阎魔老非酋",
	["jl_hongfa"] = "弘法",
	[":jl_hongfa"] = "限定技。出牌阶段，你可以将所有牌交给一名其他角色，视为使用一张基本牌，然后失去“仁望”获得“仁德”，若以此法交出的牌数大于2，你扣减1点体力上限回复1点体力。",
	["jl_shensunben"] = "神孙笨",
	["#jl_shensunben"] = "究极激昂",
	["jl_kuangang"] = "狂昂",
	[":jl_kuangang"] = "当你对距离为1的角色造成伤害后，你可以发动一次“激昂”。",
	["jl_yingang"] = "英昂",
	[":jl_yingang"] = "摸牌阶段，你可以发动一次“激昂”。",
	["jl_wangang"] = "忘昂",
	[":jl_wangang"] = "当你对其他角色造成1点伤害或受到其他的1点伤害后，你可以与该角色各发动一次“激昂”。",
	["jl_kuang"] = "苦昂",
	[":jl_kuang"] = "出牌阶段，你可以失去1点体力然后发动一次“激昂”。",
	["jl_fanang"] = "反昂",
	[":jl_fanang"] = "当你受到1点伤害后，你可以对来源发动一次“激昂”。",
	["jl_keang"] = "克昂",
	[":jl_keang"] = "若你未于出牌阶段内使用过【杀】，你可以发动一次“激昂”。",
	["jl_guiang"] = "归昂",
	[":jl_guiang"] = "当你受到1点伤害后,你可以对每名有牌的其他角色发动一次“激昂”。",
	["jl_guang"] = "蛊昂",
	[":jl_guang"] = "你可以扣置一张手牌当做任意一张基本牌或普通锦囊牌使用或打出；其他角色可以质疑并翻开此牌；若为真则你发动一次“激昂”，若为假则质疑的角色各发动一次“激昂”。",
	["jl_qiangang"] = "强昂",
	[":jl_qiangang"] = "出牌阶段限一次。你可以弃置一张武器牌或失去1点体力，然后发动一次“激昂”。",
	["jl_zhiang"] = "制昂",
	[":jl_zhiang"] = "主公技。其他吴势力角色出牌阶段限一次。该角色可以使你发动一次“激昂”。",
	["jl_zhiangPindian"] = "制昂",
	[":jl_zhiangPindian"] = "出牌阶段限一次。你可以令一名“制昂”角色发动一次“激昂”。",
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
	["jl_hunzi"] = "魂姿",
	[":jl_hunzi"] = "  ",
	["jl_shawo"] = "杀我啊",
	["&jl_shawo"] = "杀我",
	["#jl_shawo"] = "杀我教教主",
	["jl_huanggaigai"] = "黄盖盖",
	["$jl_huanggaigai"] = "黄盖盖",
	["#jl_huanggaigai"] = "贯通古今",
	["designer:jl_huanggaigai"] = "lua学生",
	["illustrator:jl_huanggaigai"] = "lua学生",
	["jl_sancao"] = "三曹",
--	["&jl_sancao"] = "三曹",
	["#jl_sancao"] = "建安风骨",
	["designer:jl_sancao"] = "lua学生",
	["illustrator:jl_sancao"] = "lua学生",
	["jl_qizi"] = "七子",
	["&jl_qizi"] = "七子",
	["#jl_qizi"] = "  ",
	["jl_caoshi1"] = "曹",
	["jl_caoyi"] = "曹裔",
	["&jl_caoyi"] = "曹裔",
	["#jl_caoyi"] = "大魏帝裔",
	["jl_caoshi"] = "曹式",
	[":jl_caoshi"] = "  ",
	["jl_liubei"] = "刘备",
--	["&jl_liubei"] = "刘备",
	["#jl_liubei"] = "乱世的强盗",
	["designer:jl_liubei"] = "lua学生",
	["illustrator:jl_liubei"] = "",
	["jl_deren"] = "得仁",
	[":jl_deren"] = "出牌阶段，你可以令一名其他角色将任意张手牌交给你，若其于本阶段内以此法首次给出的手牌数少于两张，其失去1点体力。",
	["@jl_deren"] = "你可以交给 %src 任意张手牌",
	["jl_qiangji"] = "枪激",
	[":jl_qiangji"] = "当其他角色需要使用或打出【杀】时，你可以替其使用或打出【杀】。",
	["@jl_qiangji"] = "你可以替 %src 使用或打出【杀】",
	["jl_qiangjiVS"] = "枪激",
	[":jl_qiangjiVS"] = "当你需要使用或打出【杀】时，“枪激”角色可以替你使用或打出【杀】。",
	["  "] = "  ",
	["jl_wangba"] = "王八狮子甲",
	[":jl_wangba"] = "装备牌·防具<br /><b>装备效果</b>：锁定技。【南蛮入侵】、【万箭齐发】和普通【杀】对你无效；每当你受到火焰伤害时，此伤害+1；黑色【杀】对你无效；每当你受到伤害时，若此伤害大于1点，防止多余的伤害，每当你失去装备区里的【王八狮子甲】后，你回复1点体力。<br />每当你需要使用或打出一张【闪】时，你可以进行一次判定：若结果为红色，视为你使用或打出了一张【闪】。",
	["jl_guanbingcj"] = "贯冰插菊剑",
	[":jl_guanbingcj"] = "装备牌·武器<br /><b>装备效果</b>：你的【杀】无视目标的防具，且造成伤害时，若目标没有手牌，此伤害+1。你使用【杀】为最后的手牌时，可以额外选择至多两名目标；每当你使用的【杀】被【闪】抵消后，你可以弃置两张牌令此【杀】继续造成伤害；每当你使用【杀】对目标角色造成伤害时，若该角色有牌，你可以防止此伤害，然后依次弃置其两张牌。",
	["jl_guanbingcj:choice4"] = "你可以发动“贯冰插菊剑”防止此伤害，然后弃置 %src 的两张牌",
	["jl_sstj"] = "杀闪桃酒",
	[":jl_sstj"] = "基本牌<br /><b>卡牌效果</b>：此牌可视为【杀】、【闪】、【桃】、【酒】使用或打出。",
	["jl_bajun"] = "八骏",
	[":jl_bajun"] = "装备牌·坐骑<br /><b>装备效果</b>：装备【八骏】时，弃置装备区里的其它牌；卸载【八骏】时，可以从其他角色装备区里获得任意张牌。<br />锁定技。你计算与其他角色的距离-8；其他角色计算与你的距离+8",
	["@jl_bajun"] = "八骏：请选择能够获得装备",
	["#bajuncard"] = "其他角色装备",
	["jl_bingyuegong"] = "冰月弓",
	[":jl_bingyuegong"] = "装备牌·武器<br /><b>装备效果</b>：锁定技。你于出牌阶段内使用【杀】无次数限制；你的【杀】无视目标的防具；你使用【杀】对没有手牌的目标造成伤害+1。<br />你可以将两张手牌当【杀】使用或打出；你使用【杀】为最后的手牌时，可以额外选择至多两名目标；你可以将一张普通【杀】当火【杀】使用；当你指定异性角色为【杀】的目标后，你可以令其选择一项：弃置一张手牌，或令你摸一张牌；当你使用的【杀】被【闪】抵消后，你可以弃置两张牌令此【杀】继续造成伤害，或对该角色再使用一张【杀】（无距离限制且不能选择额外目标）；每当你使用【杀】对目标角色造成伤害时，你可以弃置其装备区内的一张坐骑牌；每当你使用【杀】对目标角色造成伤害时，若该角色有牌，你可以防止此伤害，然后依次弃置其两张牌。你的回合外，每当你使用或打出了一张黑色牌时，你可以使用一张【杀】",
	["@guanbing"] = "%src：你可以弃置两张牌令此 %dest 依然命中",
	["@bingyuegong-slash"] = "你可以立即再对 %src 使用一张【杀】",
	["jl_bingyuegong:choice1"] = "你可以发动“冰月弓”令 %src 选择弃一张牌或令你摸一张牌",
	["jl_bingyuegong:choice2"] = "你可以发动“冰月弓”令此 【%src】 转化为【火杀】",
	["jl_bingyuegong:choice3"] = "你可以发动“冰月弓”弃置 %src 的坐骑牌",
	["jl_bingyuegong:choice4"] = "你可以发动“冰月弓”防止此伤害，然后弃置 %src 的两张牌",
	["jl_yushanss"] = "羽扇双蛇刀",
	[":jl_yushanss"] = "装备牌·武器<br /><b>装备效果</b>：你可以将两张手牌当【杀】使用或打出；你可以将一张普通【杀】当火【杀】使用；每当你指定异性角色为【杀】的目标后，你可以令其选择一项：弃置一张手牌，或令你摸一张牌；每当你使用的【杀】被【闪】抵消后，你可以对该角色再使用一张【杀】（无距离限制且不能选择额外目标）；",
	["jl_yushanss:choice2"] = "你可以发动“羽扇双蛇刀”令此 【%src】 转化为【火杀】",
	["jl_yushanss:choice1"] = "你可以发动“羽扇双蛇刀”令 %src 选择弃一张牌或令你摸一张牌",
	["jl_yanlinmao"] = "古诸葛偃釭麒麟画冰石羽矛",--偃麟矛
	[":jl_yanlinmao"] = "装备牌·武器<br /><b>装备效果</b>：你于出牌阶段内使用【杀】无次数限制；你的【杀】无视目标角色的防具；你使用【杀】对没有手牌的目标造成伤害+1。你可以将两张手牌当【杀】使用或打出；你使用【杀】为最后的手牌时，可以额外选择至多两名目标；你可以将一张普通【杀】当火【杀】使用；每当你指定异性角色为【杀】的目标后，你可以令其选择一项：弃置一张手牌，或令你摸一张牌；每当你使用的【杀】被【闪】抵消后，你可以弃置两张牌令此【杀】继续造成伤害，或对该角色再使用一张【杀】（无距离限制且不能选择额外目标）；每当你使用【杀】对目标角色造成伤害时，你可以弃置其装备区内的一张坐骑牌；每当你使用【杀】对目标角色造成伤害时，若该角色有牌，你可以防止此伤害，然后依次弃置其两张牌。",
	["jl_yanlinmao:choice1"] = "你可以发动“古诸葛偃釭麒麟画冰石羽矛”令 %src 选择弃一张牌或令你摸一张牌",
	["jl_yanlinmao:choice2"] = "你可以发动“古诸葛偃釭麒麟画冰石羽矛”令此 【%src】 转化为【火杀】",
	["jl_yanlinmao:choice3"] = "你可以发动“古诸葛偃釭麒麟画冰石羽矛”弃置 %src 的坐骑牌",
	["jl_yanlinmao:choice4"] = "你可以发动“古诸葛偃釭麒麟画冰石羽矛”防止此伤害，然后弃置 %src 的两张牌",
	["jl_liushen"] = "陆神",
	[":jl_liushen"] = "装备牌·防具<br /><b>装备效果</b>：若你的武将牌为关羽，吕布，吕蒙，诸葛亮，曹操，周瑜，装备后变为对应神武将牌",
	["jl_wanxiangqq"] = "万象齐侵",
	[":jl_wanxiangqq"] = "锦囊牌·AOE锦囊<br /><b>卡牌效果</b>：出牌阶段，对所有其他角色使用<br />目标需打出【杀】和【闪】，否则受到1点伤害。",
	["@jl_wanxiangqq"] = "万象齐侵：请打出一张 %src ，否则将受到1点伤害",
	["jl_lebucq"] = "乐不拆桥",
	[":jl_lebucq"] = "锦囊牌·延时锦囊<br /><b>卡牌效果</b>：出牌阶段，对一名判定区没有【乐不拆桥】的其他角色使用。将此牌置于目标判定区，然后弃置其一张牌；其判定阶段进行判定，若结果不为♥，其跳过此回合的出牌阶段。",
	["jl_shunshoubl"] = "顺手兵粮",
	[":jl_shunshoubl"] = "锦囊牌·延时锦囊<br /><b>卡牌效果</b>：出牌阶段，对一名与你距离为1且判定区没有【顺手兵粮】的其他角色使用。将此牌置于目标判定区，然后获得其一张牌；其判定阶段进行判定，若结果不为♣，其跳过此回合的摸牌阶段。",
	["jl_taoyuanfd"] = "桃园丰登",
	[":jl_taoyuanfd"] = "锦囊牌·全局锦囊<br /><b>卡牌效果</b>：出牌阶段，对所有角色使用。展示牌堆顶等于目标数的牌，则每名已受伤的目标回复1点体力并选择其中一张获得之，然后其余的牌置入弃牌堆。",
	["jl_huodou"] = "火斗",
	[":jl_huodou"] = "锦囊牌·单目标锦囊<br /><b>卡牌效果</b>：出牌阶段，对一名其他角色使用。目标需打出一张【杀】，然后你需弃置一张与此【杀】花色相同的手牌并重复此流程，直至一方未能执行，然后未能执行的角色受到1点火焰伤害。",
	["jlhuodou1"] = "火斗：请打出一张【杀】，否则将受到1点火焰伤害",
	["jlhuodou2"] = "火斗：请弃置一张与此【杀】花色相同的手牌，否则将受到1点火焰伤害",
	["jl_wuxiesy"] = "无懈生有",
	[":jl_wuxiesy"] = "锦囊牌·被动锦囊<br /><b>卡牌效果</b>：出牌阶段，对你使用。若【无懈生有】被抵消，则目标摸两张牌。<br />当一张锦囊牌生效时，你可以使用【无懈生有】抵消其效果，然后摸两张牌。",
	["jl_qiefudao"] = "切腹刀",
	[":jl_qiefudao"] = "装备牌·武器<br /><b>装备效果</b>：你使用【杀】的目标只能指定自己。<br />注：装备后点击武器使用",
	["@jl_bingyuegong"] = "%src:你可以使用一张【杀】",
	["@bingyueg"] = "%src：你可以弃置一张手牌，否则 %dest 将摸一张牌",
	["jl_wuzijiang"] = "五子良将",
--	["&jl_wuzijiang"] = "颌辽禁进晃",
	["#jl_wuzijiang"] = "魏之壁垒",
	["designer:jl_wuzijiang"] = "lua学生",
	["illustrator:jl_wuzijiang"] = "lua学生",
	["jl_lianhuansr"] = "连环杀人",
	[":jl_lianhuansr"] = "锦囊牌·单目标锦囊<br /><b>卡牌效果</b>：出牌阶段，对一名有武器的其他角色使用。选择目标攻击范围内的一名角色，横置这两名角色，然后目标需对选择的角色使用一张【杀】，否则你获得目标装备区的武器牌。",
	["jl_dianshan"] = "电闪",
	[":jl_dianshan"] = "锦囊牌·延时锦囊<br /><b>卡牌效果</b>：当【电闪】不为从延时锦囊区置入弃牌堆时，将之置于此回合角色判定区。判定阶段时进行一次判定，若结果不为♠，其受到1点雷电伤害；判定结束后将【电闪】移至上家判定区。",
	["jl_beiju"] = "杯具",
	[":jl_beiju"] = "装备牌·宝物<br /><b>装备效果</b>：锁定技。当【杯具】移出装备区时，此回合角色失去X点体力（X为其体力值且至多为2）；当你受到伤害后，若此伤害大于1，你弃置【杯具】。",
	["@jl_hongfa-card"] = "请使用已选择的基本牌【%src】",
	["jl_shusixiang"] = "蜀汉四相",
--	["&jl_shusixiang"] = "亮琬允祎",
	["#jl_shusixiang"] = "竭忠尽智",
	["designer:jl_shusixiang"] = "lua学生",
	["illustrator:jl_shusixiang"] = "lua学生",
	["jl_guancheng"] = "观城",
	[":jl_guancheng"] = "你可以发动技能“观星”；若你没有手牌，你不能成为【杀】或【决斗】的目标。",
	["jl_zhencui"] = "镇瘁",
	[":jl_zhencui"] = "你可以发动技能“镇庭”和“尽瘁”（限一次）。",
	["jl_bingyan"] = "秉宴",
	[":jl_bingyan"] = "你可以发动技能“秉正”和“舍宴”。",
	["jl_jianxi"] = "谏息",
	[":jl_jianxi"] = "你可以发动技能“谏喻”和“生息”。",
	["jl_jianyu"] = "谏喻",
	["jl_jincui"] = "尽瘁",
	["mobileyanzhenting:zhenting0"] = "镇庭：你可以将此【%arg】的目标由 %src 转移给你",
	["zhenting1:zhenting2"] = "镇庭：你可以摸一张牌，否则弃置 %src 一张手牌",
	["$jl_wuxiesy0"] = "%arg 抵消了 %arg2 对 %to 的效果",
	["  "] = "  ",
	["from"] = "来源",
	["to"] = "目标",
	["  "] = "  ",
	["jl_sicai"] = "四才",
--	["&jl_sicai"] = "亮统徽庶",
	["#jl_sicai"] = "成名于世",
	["designer:jl_sicai"] = "lua学生",
	["illustrator:jl_sicai"] = "lua学生",
	["jl_wolong"] = "卧龙",
	[":jl_wolong"] = "你可以发动技能“八阵”、“火计”和“看破”。",
	["jl_fengcu"] = "凤雏",
	[":jl_fengcu"] = "你可以发动技能“连环”和“涅槃”（限一次）。",
	["jl_shuijing"] = "水镜",
	[":jl_shuijing"] = "你可以发动技能“称好”和“隐士”。",
	["jl_xuanjian"] = "玄剑",
	[":jl_xuanjian"] = "你可以发动技能“诛害”和“荐言”。",
	["@xuanjian"] = "%src 此回合造成了伤害，你可以对其使用一张【杀】",
	["jl_jianyan"] = "荐言",
	["@jianyan"] = "请选择一名男性角色获得此 %src",
	["jl_simahuini"] = "司马徽-逆",
	["&jl_simahuini"] = "司马徽",
	["#jl_simahuini"] = "神经先生",
	["designer:jl_simahuini"] = "lua学生",
	["illustrator:jl_simahuini"] = "lua学生",
	["jl_jianjie"] = "荐劫",
	[":jl_jianjie"] = "准备阶段，若场上没有“聋印”和“疯印”，你可以令两名角色各获得“聋印”和“疯印”,否则你可以转移“聋印”或“疯印”；拥有“聋印”/“疯印”的角色拥有“止息”/“无谋”，同时拥有“聋印”和“疯印”的角色拥有“崩坏”。",
	["jl_chencha"] = "称差",
	[":jl_chencha"] = "当一名角色使用一张伤害类牌后，若此牌未造成伤害，你可以令其失去1点体力。",
	["jl_yinshi"] = "淫士",
	[":jl_yinshi"] = "锁定技。你受到的同性角色伤害-1，异性角色伤害+1；你对同性角色造成的伤害+1，异性角色伤害-1",
	["jl_longyin"] = "聋印",
	["jl_fengyin"] = "疯印",
	["#jl_jianjie"] = "请选择令一名角色获得“%src”",
	["@jl_jianjie"] = "你可以分配或转移“聋印”*“疯印”",
	["jl_liuzhang"] = "刘璋",
--	["&jl_liuzhang"] = "刘璋",
	["#jl_liuzhang"] = "青出于蓝",
	["designer:jl_liuzhang"] = "lua学生",
	["illustrator:jl_liuzhang"] = "lua学生",
	["jl_fuhun"] = "父魂",
	[":jl_fuhun"] = "限定技。准备阶段你可以将武将牌替换为“刘焉”。",
	["jl_jutu"] = "据矛",
	[":jl_jutu"] = "回合开始时，你从牌堆或弃牌堆中获得并使用【丈八蛇矛】。",
	["jl_jugong"] = "沮宫",
--	["&jl_jugong"] = "沮宫",
	["#jl_jugong"] = "破防了",
	["designer:jl_jugong"] = "lua学生",
	["illustrator:jl_jugong"] = "lua学生",
	["jl_zhangjiao"] = "张餃",
--	["&jl_zhangjiao"] = "张角",
	["designer:jl_zhangjiao"] = "lua学生",
	["illustrator:jl_zhangjiao"] = "",
	["#jl_zhangjiao"] = "甜供酱菌",
	["jl_leiji"] = "泪击",
	[":jl_leiji"] = "当你指定或成为【杀】的目标后，你可以进行判定，若为♥，你可以令一名角色回复2点体力。",
	["jl_leiji0"] = "泪击：你可以选择令一名角色回复2点体力",
	["jl_guidao"] = "闺道",
	[":jl_guidao"] = "当一张判定牌生效前，你可以打出一张红色牌替换之。",
	["jl_guidao0"] = "闺道：你可以打出一张红色牌替换此判定牌",
	["jl_huangtian"] = "凰天",
	[":jl_huangtian"] = "<b>公主技</b>。其他男性角色出牌阶段限一次，其可以交给你一张【杀】。",
	["jl_huangtianvs"] = "凰天",
	[":jl_huangtianvs"] = "<b>公主技</b>。男性角色出牌阶段限一次，你可以交给“凰天”角色一张【杀】。",
	["jl_sunbb"] = "笨笨",
	["#jl_sunbb"] = "自欠毒打",
	["designer:jl_sunbb"] = "lua学生",
	["illustrator:jl_sunbb"] = "",
	["jl_jiang"] = "激昂",
	[":jl_jiang"] = "当你指定或成为【决斗】或红色【杀】的目标后，你可以摸一张牌，则此牌结算后，你可以将一张同花色手牌当作对应牌名的牌再对对方使用之。",
	["jl_yingzi"] = "英姿",
	[":jl_yingzi"] = "摸牌阶段，你可以额外摸一张牌，然后再次执行前面的效果。 ",
	["jl_yinghun"] = "英魂",
	[":jl_yinghun"] = "准备阶段开始时，你可以令一名其他角色将手牌摸至X或弃至X。（X为你已损失的体力）",
	["jl_jianzheng"] = "谏征",
	[":jl_jianzheng"] = "当其他角色使用红色【杀】指定目标时，若你不是目标，你可以将一张手牌置于牌堆顶，然后将目标改为你。",
	["jl_jiang0"] = "激昂：你可以将一张%dest手牌当作【%src】再对对方使用",
	["jl_yinghun0"] = "英魂：你可以令一名其他角色将手牌摸至 %src 或弃至 %src ",
	["jl_jianzheng0"] = "你可以将一张手牌置于牌堆顶，然后将此【%src】的目标改为你。",
	["  "] = "  ",
	["  "] = "  ",
	["@jl_leidaocard"] = "你可以打出一张黑色牌替换 %src 的判定牌",
	["jl_leidaoinvoke"] = "你可以选择一名角色进行判定，若为黑桃，其受到2点雷电伤害",
	["@jl_lianhuansr"] = "请对 %src 使用一张【杀】，否则 %dest 将获得你的武器",
	["@jl_guikui-card"] = "你可以打出一张手牌代替 %src 的判定牌",
	["jl_lvmeng"] = "吕蒙",
--	["&jl_lvmeng"] = "吕蒙",
	["#jl_lvmeng"] = "恐惧魔王",
	["designer:jl_lvmeng"] = "lua学生",
	["illustrator:jl_lvmeng"] = "lua学生",
	["jl_weihe"] = "威吓",
	[":jl_weihe"] = "一名其他“恐惧”角色死亡时，你摸X张牌（X为其拥有的“恐惧”标记数）；若你的手牌数不小于100，你的“后期”视为满足条件。",
	["jl_kongju"] = "恐惧",
	["jl_keji"] = "克己",
	[":jl_keji"] = "出牌阶段结束后，若你未于此阶段使用或打出过【杀】，你可以跳过弃牌阶段，然后令场上所有其他角色各获得1枚“恐惧”标记。",
	["jl_houqi"] = "后期",
	[":jl_houqi"] = "觉醒技。当场上的“恐惧”标记数不小于100时，你获得游戏胜利。",
	["jl_caoang"] = "曹昂",
--	["&jl_caoang"] = "曹昂",
	["#jl_caoang"] = "犯大吴疆土者",
	["designer:jl_caoang"] = "lua学生",
	["illustrator:jl_caoang"] = "",
	["jl_yangguang"] = "阳光",
	[":jl_yangguang"] = "当一名角色成为【杀】的目标后，你可以从摸牌堆或弃牌堆中随机获得一张【闪】，则你可以交给其一张牌，然后其可以使用【闪】抵消此【杀】的伤害。",
	["@jl_yangguang"] = "阳光：你可以交给 %src 一张牌",
	["@jl_yangguang1"] = "阳光：你可以使用【闪】抵消此【%src】的伤害",
	["jl_zhenggong"] = "争功",
	[":jl_zhenggong"] = "一名其他角色回合开始前，若你正面朝上，你可以执行一个额外回合，此额外回合结束后你翻面。",
	["jl_sanyinxiang"] = "三音响",
--	["&jl_sanyinxiang"] = "衡攸赞",
	["#jl_sanyinxiang"] = "吵死你",
	["designer:jl_sanyinxiang"] = "lua学生",
	["illustrator:jl_sanyinxiang"] = "",
	["jl_kuangcai"] = "狂才",
	[":jl_kuangcai"] = "出牌阶段开始时，你可以令你此阶段使用牌无次数与距离限制，且使用时摸一张牌；累计摸5张后结束此阶段。",
	["$jl_kuangcai1"] = "博古揽今，信手拈来。",
	["$jl_kuangcai2"] = "功名为尘，光阴为金。",
	["jl_yuanyan"] = "袁焉",
--	["&jl_yuanyan"] = "袁焉",
	["#jl_yuanyan"] = "高贵之宗",
	["designer:jl_yuanyan"] = "",
	["illustrator:jl_yuanyan"] = "lua学生",
	["jl_jiangj"] = "姜姜",
--	["&jl_jiangj"] = "姜姜",
	["#jl_jiangj"] = "生气了",
	["designer:jl_jiangj"] = "lua学生",
	["illustrator:jl_jiangj"] = "",
	["jl_kunfen"] = "坤愤",
	[":jl_kunfen"] = "出牌阶段，你可以弃置两张牌对一名角色造成1点伤害。",
	["jl_fengliang"] = "缝靓",
	[":jl_fengliang"] = "限定技。回合结束时，若你此回合累计造成的伤害大于你的体力，你可以扣减1点体力上限并回复1点体力，然后令一名角色获得“吊屑”。",
	["jl_diaoxie"] = "吊屑",
	[":jl_diaoxie"] = "锁定技。其他角色使用的单目标伤害类牌只能指定你为目标（无视距离）。",
	["#jl_fengliang"] = "缝靓：请选择令一名角色获得“%src”",
	["jl_gouhuo"] = "苟或",
	["#jl_gouhuo"] = "阅读理解",
	["designer:jl_gouhuo"] = "沃矢逆蝶",
	["illustrator:jl_gouhuo"] = "沃矢逆蝶",
	["jl_yedu"] = "阅读",
	[":jl_yedu"] = "出牌阶段限一次。你可以令一名其他角色摸一张牌，然后与其拼点；根据以下结果执行对应效果：1.若你赢且未对去发动过“阅读”，其选择一项："..
	"弃一张牌并失去1点体力且本回合你可以额外使用一张【杀】，或翻面并与你摸等同于自己已损失的体力值的牌，然后你可以弃置一张牌，失去1点体力，额外发动一"..
	"次此技能并将手牌补至体力上限；2.若你没赢且未对其发动过“阅读”，其选择一项：翻面并摸等同于自己已损失的体力值的牌，或将一张♣或♦置于自己判定区，♣视为"..
	"【兵粮寸断】♦视为【乐不思蜀】并回复1点体力，然后你可以翻面，将一张手牌当作【铁索连环】对你使用，并再次发动此技能且本回合手牌上限+1；3.若你赢且对其"..
	"发动过“阅读”，则你选择一项：对其造成1点伤害你与其各摸一张牌，然后其中手牌少的获得手牌多的角色一张手牌并展示之，然后根据类型执行对应效果：基本牌，使"..
	"用之或失去1点体力，锦囊牌，交给对方一张锦囊或弃置两张非锦囊，装备牌，使用之并失去1点体力；或者获得其区域内所有的牌，然后本回合结束按照每个装备栏，判"..
	"定区,体力，各分配给其一张手牌；4.若你没赢且对其发动过“阅读”，则其选择一项：交给你其区域内各一张牌，然后本回合你不能再对其他角色使用牌，且其下回合黑色"..
	"手牌不计入上限直到回合结束，或者令你获得双方拼点牌，交给你一张牌并失去1点体力，你立即结束出牌阶段且本回合手牌上限-1，并且其下回合获得的牌在回合内不计入"..
	"手牌上限。一切结算完成后，双方根据拼点牌执行以下效果：♠，失去1点体力，摸一张牌；♥，回复1点体力，弃置一张牌；♣，弃置两张牌，执行一个额外回合，♦，摸两张牌"..
	"并翻面。最后你选择一项：令其横置并摸一张牌；弃置其3张牌并令其摸两张牌；对其造成1点伤害并令其摸3张牌；获得其所有手牌并令其摸4张牌。然后若你的手牌数大于5，"..
	"则你选择：将手牌数弃到5或失去体力值至1；若你的手牌数小于5，则你选择：将手牌数补至5或回复体力至上限。",
	["jl_lijie"] = "理解",
	[":jl_lijie"] = "游戏开始时，如果你实在看不懂“阅读”技能说明，你可以将武将牌替换为“荀彧”进行游戏。",
	["@jl_yedu"] = "你可以弃置一张牌并失去1点体力，否则你翻面并摸等同于已损失体力数的牌",
	["@jl_yedu1"] = "你可以弃置一张牌，失去1点体力，额外发动一次此技能并将手牌补至体力上限",
	["@jl_yedu2"] = "你选择：翻面并摸等同于自己已损失的体力值的牌，或将一张♣或♦置于自己判定区，♣视为【兵粮寸断】♦视为【乐不思蜀】并回复1点体力",
	["@jl_yedu3"] = "请选择将一张手牌当作【铁索连环】对你使用",
	["@jl_yedu4"] = "请再次发动 %src",
	["@jl_yedu5"] = "请使用【%src】，否则失去1点体力",
	["@jl_yedu6"] = "请选择一张锦囊交给 %src ，否则弃置两张非锦囊",
	["@jl_yedu7"] = "请选择弃置两张非锦囊",
	["@jl_yedu8"] = "请交给 %src 你区域内各一张牌，否则 %src 获得双方拼点牌",
	["@jl_yedu9"] = "请交给 %src 一张手牌",
	["@jl_yedu10"] = "请弃置 %src 张牌，否则将失去体力值至1点",
	["jl_yeduchoice1"] = "对其造成1点伤害你与其各摸一张牌",
	["jl_yeduchoice2"] = "获得其区域内所有的牌",
	["jl_yeduchoice3"] = "令其横置并摸一张牌",
	["jl_yeduchoice4"] = "弃置其3张牌并令其摸两张牌",
	["jl_yeduchoice5"] = "对其造成1点伤害并令其摸3张牌",
	["jl_yeduchoice6"] = "获得其所有手牌并令其摸4张牌",
	["jl_yeduchoice7"] = "将手牌数补至5张",
	["jl_yeduchoice8"] = "回复体力至上限",
	["jl_lijie:@jl_lijie"] = "理解：若你未看懂“阅读”技能说明，你可以将武将牌替换为“荀彧”",
	["jl_sunben"] = "孙笨",
	["#jl_sunben"] = "作文之王",
	["designer:jl_sunben"] = "",
	["illustrator:jl_sunben"] = "",
	["jl_yedus"] = "阅读",
	[":jl_yedus"] = "限定技。出牌阶段，你可以令所有角色依次弃置一张牌，然后你可以令此牌点数+X/-X，且该角色可以猜测其下家弃置的牌类别是否和他相同（不公布），若猜对："..
	"其摸一张牌；猜错，其下家获得“蛊惑”且其获得“缠怨”直到回合结束。若其以此法弃置的牌是基本牌，其可以将之置于牌堆顶，然后从牌堆底摸一张牌；若为锦囊牌，则该角色可以把"..
	"此牌当作【杀】使用，然后将此牌交给此【杀】目标；若为装备牌，则其选择交给你或置于牌堆顶。然后比较其弃置的牌的点数和其上家弃置的牌的点数，若比其上家点数大，则该角色"..
	"需选择1项：1.交给你一张牌，若此牌为装备牌或延时锦囊牌，则你可以使用之，若此牌为基本牌或普通锦囊牌，则该角色视为使用之；以此法使用或打出的牌结算完毕后，若此牌目标"..
	"角色是此技能目标且尚未因此技能弃牌，则令其获得1枚“复”标记；2.失去1点体力，然后若其体力值与手牌数之和不小于其弃置的牌的点数，你令其获得1枚“复”标记。若比其上家点数"..
	"小：你令其摸一张牌并展示之，若此牌与其弃置的牌花色相同，你摸两张牌或弃置其两张牌，否则你令其获得1枚“复”标记；此技能结算完成后，你摸X张牌，然后若你的手牌数不大于其"..
	"他角色手牌数之和，你令所有拥有“复”标记的角色移去1枚“复”标记，然后你以这些角色为目标再次发动此技能；若你的手牌数大于其他所有角色手牌数之和，你令所有角色弃置区域1内"..
	"所有的牌,然后亮出牌堆顶X张牌，并令所有角色依次获得其中一张；若这些牌没有被玩家全部获得，你依次使用其中任意张，将其余牌置于弃牌堆或牌堆顶。若有角色于此技能结算过程"..
	"中体力值归零，则其先不进行濒死结算，让这些角色先以体力值为0的状态继续游戏，在此技能结算完成后再依次结算这些角色的濒死状态。（X为场上的“复”标记数量）",
	["jl_lijies"] = "理解",
	[":jl_lijies"] = "游戏开始时，如果你实在看不懂“阅读”技能说明，你可以将武将牌替换为“孙策”进行游戏。",
	["jl_yedus0"] = "阅读：请弃置一张牌",
	["jl_yedus:jl_yedus1"] = "阅读：令此牌点数+%src",
	["jl_yedus:jl_yedus2"] = "阅读：令此牌点数-%src",
	["jl_yedus3"] = "阅读：猜测你弃置的牌与下家弃置的相同",
	["jl_yedus4"] = "阅读：猜测你弃置的牌与下家弃置的不同",
	["jl_yeduscard:jl_yedus5"] = "阅读：你可以将此 %src 置于牌堆顶，否则 %dest 获得之",
	["jl_yedus6"] = "阅读：你可以将 %src 当作【杀】使用",
	["jl_yeduscard:jl_yedus7"] = "阅读：你可以将此 %src 置于牌堆顶，然后从牌堆底摸一张牌",
	["jl_yedus8"] = "阅读：你可以交给 %src 一张牌，否则失去1点体力",
	["jl_yedus9"] = "阅读：你可以使用此 %src ",
	["jl_yedus10"] = "阅读：你可以视为使用 %src ",
	["jl_yeduscard:jl_yedus11"] = "阅读：你可以摸两张牌，否则弃置 %src 两张牌",
	["jl_yedus12"] = "阅读：请选择一张牌使用之",
	["jl_yedus13"] = "阅读：你可以将这些牌置于牌堆顶，否则置入弃牌堆",
	["jl_lijies:@jl_lijies"] = "理解：如果你实在看不懂“阅读”技能说明，你可以将武将牌替换为“孙策”进行游戏",
	["jl_fus"] = "复",
	["AskUseCard"] = "出牌",
	["jl_shengsheng"] = "盛盛",
	["#jl_shengsheng"] = "江东的爹地",
	["designer:jl_shengsheng"] = "lua学生",
	["illustrator:jl_shengsheng"] = "",
	["jl_pojun"] = "破君",
	[":jl_pojun"] = "锁定技。你使用伤害类牌指定唯一目标后，你获得其所有牌，然后此牌结算后，你按其体力值交给其等量的牌；你对没有牌的角色造成的伤害+1。",
	["$jl_pojun1"] = "犯吾疆土者，盛盛必鸡儿破之",
	["$jl_pojun2"] = "若敢来饭，盛盛必叫你大饱而归",
	["jl_caodun"] = "曹吨",
	["#jl_caodun"] = "唬抱稽手",
	["designer:jl_caodun"] = "lua学生",
	["illustrator:jl_caodun"] = "",
	["jl_shanjia"] = "善假",
	[":jl_shanjia"] = "出牌阶段开始时，你弃置所有牌，然后摸双倍的牌；若你弃置的牌数大于场上其他角色数，你视为对所有其他角色使用一张【杀】（不计次数且无距离限制）。",
	["jl_luxun"] = "陆逊",
	["#jl_luxun"] = "辱生凶才",
	["designer:jl_luxun"] = "lua学生",
	["illustrator:jl_luxun"] = "",
	["jl_qianxun"] = "纤逊",
	[":jl_qianxun"] = "锁定技。当你成为【乐不思蜀】或【顺手牵羊】的目标时，你变换来源与目标。",
	["jl_lianying"] = "连赢",
	[":jl_lianying"] = "当你于回合内/回合外失去最后一张手牌后，你可以随机摸一张可以主动/被动使用的牌。",
	["jl_sunce"] = "孙策",
	["#jl_sunce"] = "江东小白板",
	["designer:jl_sunce"] = "lua学生",
	["illustrator:jl_sunce"] = "杜总",
	["jl_baiban"] = "白板",
	[":jl_baiban"] = "锁定技。防止你跳过阶段；防止你翻面；防止你横置；你的摸牌数始终为2；你拥有此技能时失去所有其他技能；你失去此技能时恢复所有以此法失去的技能。",
	["jl_caojinyu"] = "草金鱼",
	["#jl_caojinyu"] = "阴间制裁",
	["designer:jl_caojinyu"] = "lua学生",
	["illustrator:jl_caojinyu"] = "",
	["jl_jinghun"] = "惊魂",
	[":jl_jinghun"] = "当你距离[1]以内的角色造成伤害时，你可以观看牌堆顶[1]张牌，则你分配给其至少[1]张牌，分配给你至多[1]张牌，然后伤害改为目标失去1点体力并将剩余的牌置回牌堆顶",
	[":jl_jinghun2"] = "当你距离[%arg1]以内的角色造成伤害时，你可以观看牌堆顶[%arg2]张牌，则你分配给其至少[%arg3]张牌，分配给你至多[%arg4]张牌，然后伤害改为目标失去1点体力并将剩余的牌置回牌堆顶",
	["jl_guiying"] = "鬼影",
	[":jl_guiying"] = "准备阶段或一名角色濒死时，你可以令“惊魂”[ ]中的一个数字+1（数字至多为5）；若你已受伤，你再次执行前面的效果。",
	["jl_jinghun_1"] = "距离以内+1",
	["jl_jinghun_2"] = "观看牌堆顶牌+1",
	["jl_jinghun_3"] = "分配给其至少牌+1",
	["jl_jinghun_4"] = "分配给你至多牌+1",
	["#jinghuncard"] = "惊魂观看牌堆",
	["jl_jinghun0"] = "惊魂：请将至少 %dest 张观看牌交给 %src",
	["jl_jinghun1"] = "惊魂：请将至多 %dest 张观看牌交给 %src",
	["jl_sangg"] = "三公公",
--	["&jl_sangg"] = "让昏皓",
	["#jl_sangg"] = "乱朝三公",
	["designer:jl_sangg"] = "lua学生",
	["illustrator:jl_sangg"] = "lua学生",
	["jl_shehuo"] = "奢祸",
	[":jl_shehuo"] = "你可以发动“极奢”且会触发“链祸”。",
	["jl_huiqing"] = "贿情",
	[":jl_huiqing"] = "你可以发动“寝情”和“贿生”。",
	["jl_siyishou"] = "四夷首",
--	["&jl_siyishou"] = "获居吉顿",
	["#jl_siyishou"] = "四方扰壤",
	["designer:jl_siyishou"] = "lua学生",
	["illustrator:jl_siyishou"] = "lua学生",
	["jl_huoqi"] = "祸起",
	[":jl_huoqi"] = "你可以发动“再起”且会触发“祸首”",
	["jl_qiangxuan"] = "羌悬",
	[":jl_qiangxuan"] = "你可以发动“车悬”且会触发“羌首”",
	["jl_kouren"] = "寇认",
	[":jl_kouren"] = "你可以发动“寇略”和“随认”",
	["jl_chaiqiandui"] = "拆迁队",
	["#jl_chaiqiandui"] = "扒光你",
	["designer:jl_chaiqiandui"] = "lua学生",
	["illustrator:jl_chaiqiandui"] = "lua学生",
	["jl_chaixie"] = "拆卸",
	[":jl_chaixie"] = "你可以发动以下技能：<br />“奇袭”、“英魂”、“归心”、“突袭”、“刚烈”、“急袭”、“趫猛”、“挑衅”、“反馈”和“猛进”；然后将以此法弃置的牌当作“田”置于武将牌上。",
	["jl_shuapaiji"] = "刷牌姬",
--	["&jl_shuapaiji"] = "英华香逊",
	["#jl_shuapaiji"] = "信仰之力",
	["designer:jl_shuapaiji"] = "lua学生",
	["illustrator:jl_shuapaiji"] = "lua学生",
	["jl_jixi"] = "急袭",
	["jl_baxianding"] = "八限定",
	["#jl_baxianding"] = "惊世之变",
	["designer:jl_baxianding"] = "lua学生",
	["illustrator:jl_baxianding"] = "lua学生",
	["jl_xianfa"] = "限发",
	[":jl_xianfa"] = "你可以发动以下技能：<br />“雄异”、“间书”、“拥嫡”、“伏枥”、“焚城”、“焚心”、“乱武”、“涅槃”。（每个技能限一次）",
	["jl_xianfa0"] = "限发:你可以发动“%src”",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
	["  "] = "  ",
}

return {extension,extensioncard,extensionBingfen}