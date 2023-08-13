
sgs.weapon_range.Hongduanqiang = 3
sgs.weapon_range.Liecuidao = 2
sgs.weapon_range.Shuibojian = 2
sgs.weapon_range.Hunduwanbi = 1
sgs.weapon_range.Piliche = 9
sgs.weapon_range.SecondPiliche = 9

sgs.ai_skill_invoke._hongduanqiang = function(self,data)
    return true
end

sgs.ai_skill_use["@@_liecuidao"] = function(self,prompt)
	local to = prompt:split(":")[2]
	to = self.room:findPlayerByObjectName(to)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if h==self.player:getWeapon()
		or not self:isEnemy(to)
		then continue end
		return string.format("@DummyCard=%s:_liecuidao",h:getEffectiveId())
	end
end

sgs.ai_skill_use["@@_shuibojian"] = function(self,prompt)
	local destlist = self.player:getAliveSiblings()
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	local use = self.player:getTag("_shuibojianData"):toCardUse()
	for _,p in sgs.list(destlist)do
		if self:isFriend(p)
		and use.to:contains(self.player)
		and p:hasFlag("_shuibojian_canchoose")
		then
			return ("@ShuibojianCard=.->"..p:objectName())
		end
		if self:isEnemy(p)
		and use.card:isDamageCard()
		and p:hasFlag("_shuibojian_canchoose")
		then
			return ("@ShuibojianCard=.->"..p:objectName())
		end
		if self:isEnemy(p)
		and not self:isFriend(use.to:at(0))
		and p:hasFlag("_shuibojian_canchoose")
		then
			return ("@ShuibojianCard=.->"..p:objectName())
		end
	end
end

sgs.ai_skill_invoke._hunduwanbi = function(self,data)
	local items = data:toString():split(":")
    local target = self.room:findPlayerByObjectName(items[2])
	if target then return not self:isFriend(target) end
end

sgs.ai_skill_invoke._tianleiren = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isFriend(target)
	end
end

sgs.ai_skill_invoke._piliche = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isFriend(target)
	end
end

sgs.ai_skill_invoke._secondpiliche = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isFriend(target)
	end
end

sgs.ai_skill_invoke["_feilunzhanyu"] = function(self,data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

sgs.ai_skill_invoke["_tiejixuanyu"] = function(self,data)
	local target = data:toPlayer()
	return self:isEnemy(target)
	and (target:getHandcardNum()>1
	or target:hasEquip())
end

sgs.ai_skill_invoke["_sichengliangyu"] = function(self,data)
	return true
end

sgs.ai_skill_discard._qiongshu = function(self,x,n)
    local handcards = sgs.QList2Table(self.player:getCards("he"))
    self:sortByKeepValue(handcards) -- 按保留值排序
    for _,s in sgs.list(sgs.getPlayerSkillList(self.player))do
       	local canCard = sgs.ai_skill_cardask[s:objectName()]
	   	if type(canCard)=="function"
		and not self:isWeak()
	   	then return {} end
	end
	local cards = {}
   	for _,h in sgs.list(handcards)do
		if #cards>=n then break end
		if h:objectName()=="_qiongshu" then continue end
		table.insert(cards,h:getEffectiveId())
	end
	return #cards>=n and cards or {}
end

sgs.ai_skill_invoke._qiongshu = function(self,data)
    return true
end

sgs.ai_skill_choice._xishu = function(self,choices)
	local items = choices:split("+")
	if table.contains(items,"judge")
	and self:canDisCard(self.player,"j")
	then return "judge" end
	if table.contains(items,"discard")
	then return "discard" end
end




















