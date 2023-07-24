sgs.ai_judgestring = {
	indulgence = "heart",
	diamond = "heart",
	supply_shortage = "club",
	spade = "club",
	club = "club",
	lightning = "spade",
}

sgs.ai_skill_guanxing = {}

local function getIdToCard(cards)
	local tocard = {}
	for _,id in sgs.list(cards)do
		table.insert(tocard,sgs.Sanguosha:getCard(id))
	end
	return tocard
end

local function getBackToId(cards)
	local ids = {}
	for _,c in sgs.list(cards)do
		table.insert(ids,c:getEffectiveId())
	end
	return ids
end

--for test--
local function ShowGuanxingResult(self,up,bottom)
	self.room:writeToConsole("----GuanxingResult----")
	self.room:writeToConsole(string.format("up:%d",#up))
	if #up>0 then
		for _,card in pairs(up)do
			self.room:writeToConsole(string.format("(%d)%s[%s%d]",card:getId(),card:getClassName(),card:getSuitString(),card:getNumber()))
		end
	end
	self.room:writeToConsole(string.format("down:%d",#bottom))
	if #bottom>0 then
		for _,card in pairs(bottom)do
			self.room:writeToConsole(string.format("(%d)%s[%s%d]",card:getId(),card:getClassName(),card:getSuitString(),card:getNumber()))
		end
	end
	self.room:writeToConsole("----GuanxingEnd----")
end
--end--

local function GuanXing(self,cards)
	local up,bottom = {},getIdToCard(cards)
	local has_lightning,self_has_judged,willSkipDrawPhase,willSkipPlayPhase
	self:sortByUseValue(bottom,true)
	if self.player:hasSkill("myjincui")
	then
		local cs = {}
		for i,c in sgs.list(table.copyFrom(bottom))do
			if c:getNumber()==7
			then
				table.insert(cs,c)
				table.removeOne(bottom,c)
			end
		end
		table.insertTable(bottom,cs)
	end
	local judged_list = {}
   	local target = self.room:getCurrent() or self.player
	local judge = sgs.QList2Table(target:getJudgingArea())
	if #judge>0 and target:getPhase()<sgs.Player_Play
	and not target:containsTrick("YanxiaoCard")
	then
		local lightning_index
		judge = sgs.reverse(judge)
		for judge_count,jc in sgs.list(judge)do
			judged_list[judge_count] = 0
			if jc:isKindOf("Lightning")
			then
				lightning_index = judge_count
				has_lightning = jc
				continue
			elseif jc:isKindOf("Indulgence")
			then
				willSkipPlayPhase = true
				if target:isSkipped(sgs.Player_Play)
				then continue end
			elseif jc:isKindOf("SupplyShortage")
			then
				willSkipDrawPhase = true
				if target:isSkipped(sgs.Player_Draw)
				then continue end
			end
			local judge_str = sgs.ai_judgestring[jc:objectName()]
			if not judge_str
			then
				self.room:writeToConsole(debug.traceback())
				judge_str = sgs.ai_judgestring[jc:getSuitString()]
			end
			for i,c in sgs.list(table.copyFrom(bottom))do
				local cf = CardFilter(c,target):getSuitString()
				if string.find(judge_str,cf) and self:isFriend(target)
				or not string.find(judge_str,cf) and self:isEnemy(target)
				then
					table.insert(up,c)
					table.removeOne(bottom,c)
					self_has_judged = true
					judged_list[judge_count] = 1
					if jc:isKindOf("SupplyShortage")
					then willSkipDrawPhase = false
					elseif jc:isKindOf("Indulgence")
					then willSkipPlayPhase = false end
					break
				end
			end
		end
		if lightning_index
		then
			for i,c in sgs.list(table.copyFrom(bottom))do
				local cf = CardFilter(c,target)
				local s,n = cf:getSuitString(),cf:getNumber()
				if not (n>=2 and n<=9 and s=="spade") and self:isFriend(target)
				or (n>=2 and n<=9 and s=="spade") and self:isEnemy(target)
				then
					local x = lightning_index>#up and 1 or lightning_index
					table.insert(up,x,c)
					table.removeOne(bottom,c)
					judged_list[lightning_index] = 1
					self_has_judged = true
					break
				end
			end
			if judged_list[lightning_index]==0
			then
				if #up>=lightning_index
				then
					for i=1,#up-lightning_index+1 do
						table.insert(bottom,i,table.remove(up))
					end
				end
				return getBackToId(up),getBackToId(bottom)
			end
		end
		if not self_has_judged
		then return {},cards end
		local index
		if willSkipDrawPhase
		then
			for i=#judged_list,1,-1 do
				if judged_list[i]==0
				then index = i else break end
			end
		end
		for i=1,#judged_list do
			if judged_list[i]==0
			then
				if i==index
				then
					return getBackToId(up),getBackToId(bottom)
				end
				table.insert(up,i,table.remove(bottom,1))
			end
		end
	end
	local conflict,AI_doNotInvoke_luoshen,AI_doNotInvoke_tenyearluoshen
	for _,sname in sgs.list(target:getVisibleSkillList())do
		sname = sname:objectName()
		if sname=="guanxing"
		or sname=="super_guanxing"
		or sname=="tenyearguanxing"
		then conflict = true continue end
		if conflict
		then
			if sname=="tuqi"
			then
				if target:getPile("retinue"):length()>0
				and target:getPile("retinue"):length()<=2
				then
					if #bottom>0 then table.insert(up,1,table.remove(bottom))
					else table.insert(up,1,table.remove(up)) end
				end
			elseif sname=="luoshen"
			then
				if #bottom==0
				then
					target:setFlags("AI_doNotInvoke_luoshen")
				else
					local count = 0
					if not self_has_judged then up = {} end
					for i = 1,#bottom do
						if bottom[i-count]:isBlack()
						then
							table.insert(up,1,table.remove(bottom,i-count))
							count = count+1
						end
					end
					if count==0
					then
						AI_doNotInvoke_luoshen = true
					else
						target:setFlags("AI_Luoshen_Conflict_With_Guanxing")
						target:setMark("AI_loushen_times",count)
					end
				end
			elseif sname=="tenyearluoshen"
			then
				if #bottom==0
				then
					target:setFlags("AI_doNotInvoke_tenyearluoshen")
				else
					local count = 0
					if not self_has_judged then up = {} end
					for i = 1,#bottom do
						if bottom[i-count]:isBlack()
						then
							table.insert(up,1,table.remove(bottom,i-count))
							count = count+1
						end
					end
					if count==0
					then
						AI_doNotInvoke_tenyearluoshen = true
					else
						target:setFlags("AI_TenyearLuoshen_Conflict_With_Guanxing")
						target:setMark("AI_tenyearluoshen_times",count)
					end
				end
			else
				local x = 0
				local reverse
				if sname=="zuixiang"
				and target:getMark("@sleep")>0
				then x = 3
				elseif sname=="guixiu"
				and sgs.ai_skill_invoke.guixiu(self)
				then x = 2
				elseif sname=="qianxi"
				and sgs.ai_skill_invoke.qianxi(self)
				then x = 1 reverse = true
				elseif sname=="yinghun"
				then
					sgs.ai_skill_playerchosen.yinghun(self)
					if self.yinghunchoice=="dxt1"
					then x = target:getLostHp()
					elseif self.yinghunchoice=="d1tx"
					then x = 1 end
					reverse = true
				end
				if x>0
				then
					if #bottom<x
					then
						target:setFlags("AI_doNotInvoke_"..sname)
					else
						for i = 1,x do
							local index = reverse and 1 or #bottom
							table.insert(up,1,table.remove(bottom,index))
						end
					end
				end
			end
		end
	end
	local drawCards = self:ImitateResult_DrawNCards(target,target:getVisibleSkillList(true))
	if willSkipDrawPhase or target:getPhase()>sgs.Player_Draw then drawCards = 0 end
	if #bottom>0 and drawCards>0
	and self:isFriend(target)
	then
		if target:hasSkill("zhaolie")
		then
			local targets = sgs.SPlayerList()
			for _,p in sgs.list(self.room:getOtherPlayers(target))do
				if target:inMyAttackRange(p)
				then targets:append(p) end
			end
			if targets:length()>0
			and sgs.ai_skill_playerchosen.zhaolie(self,targets)
			then
				local basic = {}
				local peach = {}
				local not_basic = {}
				local drawCount = drawCards-1
				for _,gcard in sgs.list(bottom)do
					if gcard:isKindOf("Peach") then table.insert(peach,gcard)
					elseif gcard:isKindOf("BasicCard") then table.insert(basic,gcard)
					else table.insert(not_basic,gcard) end
				end
				if #not_basic>0
				then
					bottom = {}
					for i = 1,drawCount,1 do
						if self:isWeak()
						and #peach>0
						then
							table.insert(up,peach[1])
							table.remove(peach,1)
						elseif #basic>0
						then
							table.insert(up,basic[1])
							table.remove(basic,1)
						elseif #not_basic>0
						then
							table.insert(up,not_basic[1])
							table.remove(not_basic,1)
						end
					end
					for _,card in sgs.list(not_basic)do
						table.insert(up,card)
					end
					if #peach>0
					then
						for _,peach in sgs.list(peach)do
							table.insert(bottom,peach)
						end
					end
					if #basic>0
					then
						for _,card in sgs.list(basic)do
							table.insert(bottom,card)
						end
					end
					if AI_doNotInvoke_luoshen then target:setFlags("AI_doNotInvoke_luoshen") end
					if AI_doNotInvoke_tenyearluoshen then target:setFlags("AI_doNotInvoke_tenyearluoshen") end
					return getBackToId(up),getBackToId(bottom)
				else
					target:setFlags("AI_doNotInvoke_zhaolie")
				end
			end
		end
	end
	if sgs.cardEffect and sgs.cardEffect.card:isKindOf("Dongzhuxianji")
	or sgs.guanXingFriend
	then
		for i,c in sgs.list(table.copyFrom(bottom))do
			if self.player:getPhase()<=sgs.Player_Play
			and (self:getCardsNum(c:getClassName())<2 or self:getUseValue(c)>6)
			and c:isAvailable(self.player) and self:aiUseCard(c).card
			then table.insert(up,c) table.removeOne(bottom,c) end
		end
		sgs.guanXingFriend = false
		for i,c in sgs.list(table.copyFrom(bottom))do
			if self:getUseValue(c)>6
			then
				table.insert(up,c)
				table.removeOne(bottom,c)
			end
		end
	end
	
	local pos = 1
	local next_judge = {}
	local luoshen_flag = false
	local np = target:getNextAlive()
	while np~=target do
		if np:faceUp() then break end
		np = np:getNextAlive()
	end
	judge = sgs.QList2Table(np:getJudgingArea())
	judge = sgs.reverse(judge)
	if has_lightning and not np:containsTrick("lightning") then table.insert(judge,1,has_lightning) end
	local nextplayer_has_judged = false
	judged_list = {}
	while #bottom>0 do
		if pos>#judge then break end
		local judge_str = sgs.ai_judgestring[judge[pos]:objectName()] or sgs.ai_judgestring[judge[pos]:getSuitString()]
		for i,jc in sgs.list(table.copyFrom(bottom))do
			if judge[pos]:isKindOf("Lightning")
			then lightning_index = pos break end
			local cf = CardFilter(jc,np)
			local suit = cf:getSuitString()
			if self:isFriend(np)
			then
				if np:hasSkill("luoshen")
				then
					if cf:isBlack()
					then
						table.insert(next_judge,jc)
						table.removeOne(bottom,jc)
						nextplayer_has_judged = true
						judged_list[pos] = 1
						break
					end
				else
					if string.find(judge_str,suit)
					then
						table.insert(next_judge,jc)
						table.removeOne(bottom,jc)
						nextplayer_has_judged = true
						judged_list[pos] = 1
						break
					end
				end
			else
				if np:hasSkill("luoshen")
				and not luoshen_flag
				and cf:isRed()
				then
					table.insert(next_judge,jc)
					table.removeOne(bottom,jc)
					nextplayer_has_judged = true
					judged_list[pos] = 1
					luoshen_flag = true
					break
				else
					if string.find(judge_str,suit)
					then
						table.insert(next_judge,jc)
						table.removeOne(bottom,jc)
						nextplayer_has_judged = true
						judged_list[pos] = 1
						break
					end
				end
			end
		end
		judged_list[pos] = judged_list[pos] or 0
		pos = pos+1
	end
	if lightning_index
	then
		for x,c in sgs.list(table.copyFrom(bottom))do
			local cf = CardFilter(c,np)
			local s,n = cf:getSuitString(),cf:getNumber()
			if self:isFriend(np) and not (n>=2 and n<=9 and s=="spade")
			or not self:isFriend(np) and n>=2 and n<=9 and s=="spade"
			then
				local i = lightning_index>#next_judge and 1 or lightning_index
				table.insert(next_judge,i,c)
				table.removeOne(bottom,c)
				judged_list[lightning_index] = 1
				nextplayer_has_judged = true
				break
			end
		end
	end
	local nextplayer_judge_failed
	if lightning_index and not nextplayer_has_judged
	then nextplayer_judge_failed = true
	elseif nextplayer_has_judged
	then
		local index
		for i = #judged_list,1,-1 do
			if judged_list[i]==0 then index = i
			else break end
		end
		for i = 1,#judged_list do
			if i==index then nextplayer_judge_failed = true break end
			if judged_list[i]==0
			then
				table.insert(next_judge,i,table.remove(bottom,1))
			end
		end
	end
	self:sortByUseValue(bottom)
	if #bottom>0 and self.player:hasSkill("myjincui")
	then
		local cs = {}
		for i,c in sgs.list(table.copyFrom(bottom))do
			if c:getNumber()==7
			then
				table.insert(cs,c)
				table.removeOne(bottom,c)
			end
		end
		table.insertTable(bottom,cs)
	end
	drawCards = self:ImitateResult_DrawNCards(np,np:getVisibleSkillList(true))
	if drawCards>0 and #bottom>0
	and self:isFriend(np)
	then
		local has_slash = self:getCardsNum("Slash")>0
		local nosfuhun1,nosfuhun2,shuangxiong,has_big
		for index,gcard in sgs.list(bottom)do
			local insert = false
			if np:hasSkill("nosfuhun")
			and drawCards>=2
			then
				if not nosfuhun1 and gcard:isRed()
				then insert = true nosfuhun1 = true end
				if not nosfuhun2 and gcard:isBlack()
				and isCard("Slash",gcard,np)
				then insert = true nosfuhun2 = true end
				if not nosfuhun2 and gcard:isBlack()
				and gcard:getTypeId()==sgs.Card_TypeEquip
				then insert = true nosfuhun2 = true end
				if not nosfuhun2 and gcard:isBlack()
				then insert = true nosfuhun2 = true end
			elseif np:hasSkill("shuangxiong")
			and np:getHandcardNum()>=3
			then
				local rednum,blacknum = 0,0
				for _,card in sgs.list(sgs.QList2Table(np:getHandcards()))do
					if card:isRed() then rednum = rednum+1 else blacknum = blacknum+1 end
				end
				if not shuangxiong
				and (rednum>blacknum and gcard:isBlack() or blacknum>rednum and gcard:isRed())
				and (isCard("Slash",gcard,np) or isCard("Duel",gcard,np))
				then insert = true shuangxiong = true end
				if not shuangxiong
				and ((rednum>blacknum and gcard:isBlack()) or blacknum>rednum and gcard:isRed())
				then insert = true shuangxiong = true end
			elseif np:hasSkills("xianzhen|tianyi|dahe|quhu")
			then
				local maxcard = self:getMaxCard(np)
				has_big = maxcard and maxcard:getNumber()>10
				if not has_big and gcard:getNumber()>10
				then insert = true has_big = true end
				if isCard("Slash",gcard,np)
				then insert = true end
			elseif isCard("Peach",gcard,np) and (np:isWounded()  or self:getCardsNum("Peach")<1)
			then insert = true
			elseif not willSkipPlayPhase
			and isCard("ExNihilo",gcard,np)
			then insert = true
			else
				for _,skill in sgs.list(np:getVisibleSkillList(true))do
					local callback = sgs.ai_cardneed[skill:objectName()]
					if type(callback)=="function" and sgs.ai_cardneed[skill:objectName()](np,gcard,self)
					then insert = true end
				end
				if not insert
				then
					if has_slash
					and not gcard:isKindOf("Slash")
					and not gcard:isKindOf("Jink")
					and self:getCardsNum("Jink")>0
					then insert = true
					elseif not has_slash
					and isCard("Slash",gcard,np)
					and not willSkipPlayPhase
					then
						insert = true
						has_slash = true
					end
				end
			end
			if insert
			then
				drawCards = drawCards-1
				table.insert(up,gcard)
				table.remove(bottom,index)
				if isCard("ExNihilo",gcard,np) then drawCards = drawCards+2 end
				if drawCards==0 then break end
			end
		end
		if #bottom>0 and drawCards>0 then
			if willSkipPlayPhase then np:setFlags("willSkipPlayPhase") end
			for i = 1,#bottom do
				local c = self:getValuableCardForGuanxing(bottom)
				if not c then break end
				for index,card in sgs.list(bottom)do
					if card:getEffectiveId()==c:getEffectiveId()
					then
						table.insert(up,table.remove(bottom,index))
						drawCards = drawCards-1
						if isCard("ExNihilo",card,np) then drawCards = drawCards+2 end
						break
					end
				end
				if drawCards==0 then break end
			end
			np:setFlags("-willSkipPlayPhase")
		end
	end
	if #bottom>drawCards and #bottom>0
	and not nextplayer_judge_failed
	then
		local maxCount = #bottom-drawCards
		if self:isFriend(np)
		then
			local i = 0
			for index = 1,#bottom do
				if bottom[index-i]:isKindOf("Peach") and (np:isWounded() or getCardsNum("Peach",np,self.player)<1)
				or isCard("ExNihilo",bottom[index-i],np)
				then
					table.insert(next_judge,table.remove(bottom,index-i))
					i = i+1
					if maxCount==i then break end
				end
			end
			maxCount = maxCount-i
			if maxCount>0
			then
				i = 0
				for _,skill in sgs.list(np:getVisibleSkillList(true))do
					local callback = sgs.ai_cardneed[skill:objectName()]
					if type(callback)=="function" then
						for index = 1,#bottom do
							if sgs.ai_cardneed[skill:objectName()](np,bottom[index-i],self)
							then
								table.insert(next_judge,table.remove(bottom,index-i))
								i = i+1
								if maxCount==i then break end
							end
						end
						if maxCount==i then break end
					end
				end
			end
		else
			local i = 0
			for index = 1,#bottom do
				if bottom[index-i]:isKindOf("Lightning") and not np:hasSkills("leiji|nosleiji")
				or bottom[index-i]:isKindOf("GlobalEffect")
				then
					table.insert(next_judge,table.remove(bottom,index-i))
					i = i+1
					if maxCount==i then break end
				end
			end
		end
	end
	if #next_judge>0 and drawCards>0
	then
		if #bottom>=drawCards
		then
			for i = 1,#bottom do
				if drawCards<1 then break end
				table.insert(up,table.remove(bottom))
				drawCards = drawCards-1
			end
		else
			table.insertTable(bottom,next_judge)
			next_judge = {}
		end
	end
	for _,c in sgs.list(next_judge)do
		table.insert(up,c)
	end
	if not self_has_judged and not nextplayer_has_judged
	and #up>=drawCards and drawCards>1 and #next_judge<1
	then
		for i = 1,drawCards-1 do
			if isCard("ExNihilo",up[i],np)
			then
				table.insert(up,drawCards,table.remove(up,i))
			end
		end
	end
	if #up>0 and AI_doNotInvoke_luoshen then target:setFlags("AI_doNotInvoke_luoshen") end
	if #up>0 and AI_doNotInvoke_tenyearluoshen then target:setFlags("AI_doNotInvoke_tenyearluoshen") end
	return getBackToId(up),getBackToId(bottom)
end

local function XinZhan(self,cards)
	local judged_list = {}
	local up,bottom = {},getIdToCard(cards)
	local next_player = self.player:getNextAlive()
	local judge = next_player:getCards("j")
	judge = sgs.QList2Table(judge)
	for judge_count,need_judge in sgs.list(sgs.reverse(judge))do
		local index = 1
		local lightning_flag = false
		local judge_str = sgs.ai_judgestring[need_judge:objectName()] or sgs.ai_judgestring[need_judge:getSuitString()]

		for _,for_judge in sgs.list(bottom)do
			local cf = CardFilter(for_judge,next_player)
			local s,n = cf:getSuitString(),cf:getNumber()
			if string.find(judge_str,"spade")
			and not lightning_flag
			then
				if n>=2 and n<=9 then lightning_flag = true end
			end
			if self:isFriend(next_player) then
				if string.find(judge_str,s) then
					if not lightning_flag then
						table.insert(up,for_judge)
						table.remove(bottom,index)
						judged_list[judge_count] = 1
						has_judged = true
						break
					end
				end
			else
				if not string.find(judge_str,s)
				or (string.find(judge_str,s) and string.find(judge_str,"spade") and lightning_flag)
				then
					table.insert(up,for_judge)
					table.remove(bottom,index)
					judged_list[judge_count] = 1
					has_judged = true
				end
			end
			index = index+1
		end
		judged_list[judge_count] = judged_list[judge_count] or 0
	end

	if has_judged then
		for index = 1,#judged_list do
			if judged_list[index]==0 then
				table.insert(up,index,table.remove(bottom))
			end
		end
	end

	while #bottom>0 do
		table.insert(up,table.remove(bottom))
	end

	return getBackToId(up),{}
end

function SmartAI:askForGuanxing(cards,guanxing_type)
	--KOF模式--
	if guanxing_type~=sgs.Room_GuanxingDownOnly
	then
		local func = Tactic("guanxing",self,guanxing_type==sgs.Room_GuanxingUpOnly)
		if func then return func(self,cards) end
	end
	--身份局--
	--[[
	for sg,sk in ipairs(sgs.getPlayerSkillList(self.player))do
		sg = sgs.ai_skill_guanxing[sk:objectName()]
		if type(sg)=="function"
		then
			local up,bottom = sg(self,cards,guanxing_type)
		end
	end--]]
	if guanxing_type==sgs.Room_GuanxingBothSides
	then return GuanXing(self,cards)
	elseif guanxing_type==sgs.Room_GuanxingUpOnly
	then return XinZhan(self,cards)
	elseif guanxing_type==sgs.Room_GuanxingDownOnly
	then return {},cards end
	return cards,{}
end

function SmartAI:getValuableCardForGuanxing(cards)
	local ag = sgs.ai_skill_askforag.amazing_grace(self,getBackToId(cards))
	if ag then return sgs.Sanguosha:getCard(ag) end
end
