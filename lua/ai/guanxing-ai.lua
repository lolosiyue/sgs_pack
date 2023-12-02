sgs.ai_judgestring = {
	indulgence = ".|heart",
	supply_shortage = ".|club",
	lightning = {".|spade|2~9",false}
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
		local j_c = {}
		for i,jc in sgs.list(sgs.reverse(judge))do
			if jc:isKindOf("Lightning")
			then
				has_lightning = jc
			elseif jc:isKindOf("Indulgence")
			then
				willSkipPlayPhase = true
				if target:isSkipped(sgs.Player_Play) then continue end
			elseif jc:isKindOf("SupplyShortage")
			then
				willSkipDrawPhase = true
				if target:isSkipped(sgs.Player_Draw) then continue end
			end
			local judge_str = sgs.ai_judgestring[jc:objectName()]
			if type(judge_str)~="table"
			then
				if type(judge_str)=="string"
				then
					judge_str = {judge_str,true}
				else
				self.room:writeToConsole(debug.traceback())
					judge_str = {".|"..jc:getSuitString(),true}
			end
			end
			for _,c in sgs.list(table.copyFrom(bottom))do
				local cf = CardFilter(c,target)
				if sgs.Sanguosha:matchExpPattern(judge_str[1],target,cf)==judge_str[2] and self:isFriend(target)
				or sgs.Sanguosha:matchExpPattern(judge_str[1],target,cf)~=judge_str[2] and self:isEnemy(target)
				then
					j_c[jc:objectName()] = c
					table.removeOne(bottom,c)
					if jc:isKindOf("SupplyShortage")
					then willSkipDrawPhase = false
					elseif jc:isKindOf("Indulgence")
					then willSkipPlayPhase = false end
					self_has_judged = true
					break
				end
			end
			end
		for c,jc in sgs.list(sgs.reverse(judge))do
			c = j_c[jc:objectName()]
			if c then table.insert(up,c)
			else table.insert(up,table.remove(bottom,1)) end
		end
	end
	if sgs.cardEffect and sgs.cardEffect.card:isKindOf("Dongzhuxianji")
	or sgs.guanXingFriend
	then
		for _,c in sgs.list(table.copyFrom(bottom))do
			if self.player:getPhase()<=sgs.Player_Play and self:cardNeed(c)>6
			and c:isAvailable(self.player) and self:aiUseCard(c).card
			then table.insert(up,c) table.removeOne(bottom,c) end
		end
		sgs.guanXingFriend = false
		for _,c in sgs.list(table.copyFrom(bottom))do
			if self:cardNeed(c)>6
			then
				table.insert(up,c)
				table.removeOne(bottom,c)
			end
		end
	end
	local drawCards = self:ImitateResult_DrawNCards(target,target:getVisibleSkillList(true))
	if willSkipDrawPhase or target:getPhase()>sgs.Player_Draw then drawCards = 0 end
	
	judged_list = {}
	local np = target:getNextAlive()
	while np~=target do
		if np:faceUp() then break end
		np = np:getNextAlive()
	end
	judge = sgs.QList2Table(np:getJudgingArea())
	if has_lightning and not np:containsTrick("lightning") then table.insert(judge,has_lightning) end
	for i,jc in sgs.list(sgs.reverse(judge))do
		i = i-1
		if #bottom-drawCards-i<1 then break end
		local judge_str = sgs.ai_judgestring[jc:objectName()]
		if type(judge_str)~="table"
			then
			if type(judge_str)=="string"
			then judge_str = {judge_str,true}
				else
				self.room:writeToConsole(debug.traceback())
				judge_str = {".|"..jc:getSuitString(),true}
					end
				end
		for _,c in sgs.list(table.copyFrom(bottom))do
			local cf = CardFilter(c,np)
			if self:isFriend(np)
			then
				if sgs.Sanguosha:matchExpPattern(judge_str[1],np,cf)==judge_str[2]
					then
					judged_list[jc:objectName()] = c
					table.removeOne(bottom,c)
						break
					end
			elseif sgs.Sanguosha:matchExpPattern(judge_str[1],np,cf)~=judge_str[2]
	then
				judged_list[jc:objectName()] = c
				table.removeOne(bottom,c)
				break
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
	for i=1,drawCards do
		if #bottom<1 then break end
		local nocan = true
		for _,c in sgs.list(table.copyFrom(bottom))do
			if self:aiUseCard(c).card
	then
				table.insert(up,c)
				table.removeOne(bottom,c)
				nocan = false
						break
					end
				end
		if nocan
		then
			table.insert(up,table.remove(bottom,1))
				end
			end
	for c,jc in sgs.list(sgs.reverse(judge))do
		c = judged_list[jc:objectName()]
		if c then table.insert(up,c)
		elseif #bottom>0
		then table.insert(up,table.remove(bottom,#bottom)) end
							end
	
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
