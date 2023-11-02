--change

sgs.ai_skill_invoke.xianchangetupo = function(self, data)
	--[[local num = math.random(0,1)
	if (num == 0) then
	    return true
	else
		return false
	end]]
	return false
end

--南华老仙

sgs.ai_skill_invoke.kexianhuoqi = function(self, data)
	return true
end

sgs.ai_skill_choice.kexianhuoqi = function(self, choices, data)
    if self.player:isWeak() then return "recover" end
	return "pindian"
end

sgs.ai_skill_choice.nhlxloser = function(self, choices, data)
    if self.player:isWeak() then return "qipai" end
	return "damage"
end

sgs.ai_skill_invoke.kexianyuli = function(self, data)
	return true
end

--界南华老仙

sgs.ai_skill_invoke.kejiexianhuoqi = function(self, data)
	return true
end

sgs.ai_skill_choice.kejiexianhuoqi = function(self, choices, data)
    if self.player:isWeak() then return "recover" end
	return "pindian"
end



--普净

local kexianchanxin_skill = {}
kexianchanxin_skill.name = "kexianchanxin"
table.insert(sgs.ai_skills, kexianchanxin_skill)
kexianchanxin_skill.getTurnUseCard = function(self)
	if (self.player:hasUsed("#kexianchanxinCard") )
	or ((self.player:getCardsNum("Slash") > 0) and not sgs.Slash_IsAvailable(self.player)) then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local to_throw = sgs.IntList()
	for _, acard in ipairs(cards) do
		if acard:isKindOf("Slash") then
			to_throw:append(acard:getEffectiveId())
		end
	end
	card_id = to_throw:at(0)--(to_throw:length()-1)
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#kexianchanxinCard:"..card_id..":")
	end
end

sgs.ai_skill_use_func["#kexianchanxinCard"] = function(card, use, self)
    if not (self.player:hasUsed("#kexianchanxinCard") ) then 
        use.card = card
	    return
	end
end

function sgs.ai_cardneed.kexianchanxin(to, card, self)
	if (self.player:hasUsed("#kexianchanxinCard")) then return false end
	return true
end

sgs.ai_skill_invoke.kexianhuiyan = function(self, data)
	return true
end

sgs.ai_skill_invoke.kejiexianhuiyan = function(self, data)
	return true
end

sgs.ai_skill_invoke.kejiexianguiyi = function(self, data)
	return true
end

sgs.ai_skill_choice.kejiexianguiyi = function(self, choices, data)
    if self.player:hasFlag("choosehave") then return "have" end
	return "nothave"
end




--左慈

sgs.ai_skill_invoke.kexianlunhui = function(self, data)
	return true
end

local kexianfenshen_skill = {}
kexianfenshen_skill.name = "kexianfenshen"
table.insert(sgs.ai_skills, kexianfenshen_skill)
kexianfenshen_skill.getTurnUseCard = function(self)
	if (self.player:hasUsed("#kexianfenshenCard")) or (self.player:getMark("&xianzuociji")==0) then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local to_throw = sgs.IntList()
	for _, acard in ipairs(cards) do
		to_throw:append(acard:getEffectiveId())
	end
	card_id = to_throw:at(0)--(to_throw:length()-1)
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#kexianfenshenCard:"..card_id..":")
	end
end

sgs.ai_skill_use_func["#kexianfenshenCard"] = function(card, use, self)
    if (self.player:getMark("&xianzuociji")>0) and not (self.player:hasUsed("#kexianfenshenCard")) then 
        use.card = card
	    return
	end
end

function sgs.ai_cardneed.kexianfenshen(to, card, self)
	if (self.player:hasUsed("#kexianfenshenCard")) or (self.player:getMark("&xianzuociji")==0) then return false end
	return true
end

sgs.ai_use_value.kexianfenshenCard = 8.5
sgs.ai_use_priority.kexianfenshenCard = 9.5
sgs.ai_card_intention.kexianfenshenCard = -80

sgs.ai_skill_invoke.kejiexianlunhui = function(self, data)
	return true
end

local kejiexianfenshen_skill = {}
kejiexianfenshen_skill.name = "kejiexianfenshen"
table.insert(sgs.ai_skills, kejiexianfenshen_skill)
kejiexianfenshen_skill.getTurnUseCard = function(self)
	if (self.player:hasUsed("#kejiexianfenshenCard")) 
	or (self.player:getMark("&kexianfenshen")>=3)
	or (self.player:getMark("&jiexianzuociji")==0) then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local to_throw = sgs.IntList()
	for _, acard in ipairs(cards) do
		to_throw:append(acard:getEffectiveId())
	end
	card_id = to_throw:at(0)--(to_throw:length()-1)
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#kejiexianfenshenCard:"..card_id..":")
	end
end

sgs.ai_skill_use_func["#kejiexianfenshenCard"] = function(card, use, self)
    if (self.player:getMark("&kexianfenshen")<3) and (self.player:getMark("&jiexianzuociji")>0) and not (self.player:hasUsed("#kejiexianfenshenCard")) then 
        use.card = card
	    return
	end
end

function sgs.ai_cardneed.kejiexianfenshen(to, card, self)
	if (not (self.player:getMark("&kexianfenshen")<3)) and (self.player:hasUsed("#kejiexianfenshenCard")) or (self.player:getMark("&jiexianzuociji")==0) then return false end
	return true
end

sgs.ai_use_value.kejiexianfenshenCard = 8.5
sgs.ai_use_priority.kejiexianfenshenCard = 9.5
sgs.ai_card_intention.kejiexianfenshenCard = -80

sgs.ai_skill_invoke.kejiexianfeijian = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.kejiexianfeijian = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end


--于吉

sgs.ai_skill_invoke.kexianmabi = function(self, data)
	if self.player:hasFlag("wantusekexianmabi") then
		return false
	else
		local num = math.random(0,1)
		if (num == 0) then
			return true
		else
			return false
		end
	end
end

sgs.ai_skill_invoke.kexianxiuzhen = function(self, data)
	if self.player:hasFlag("wantusekexianxiuzhen") then
		return true
	end
end

sgs.ai_skill_invoke.kejiexianmabi = function(self, data)
	local num = math.random(0,1)
	if (num == 0) then
		return true
	else
		return false
	end
end

sgs.ai_skill_invoke.kejiexianxiuzhenpd = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.kejiexianxiuzhen = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end


--马谡

sgs.ai_skill_playerchosen.kexianhanyan = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) and not p:isNude() then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end

sgs.ai_skill_invoke.kexianxiaocai = function(self, data)
	return true
end

sgs.ai_skill_invoke.kejiexianliwei = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.kejiexianliwei = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) and not p:isNude() then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end

sgs.ai_skill_invoke.kejiexianaoce = function(self, data)
	for _,c in sgs.qlist(self.player:getCards("h")) do
		if c:isKindOf("Jink") then
			return true
		end
	end
	return false
end




--张郃

sgs.ai_skill_invoke.xianchangetupo = function(self, data)
	local num = math.random(0,1)
	if (num == 0) then
	    return true
	else
		return false
	end
end

sgs.ai_skill_playerchosen.kexianbenxi = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) and not p:isKongcheng() then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end

sgs.ai_skill_invoke.kejiexianjibian = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.kejiexianjibian = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) and not p:isKongcheng() then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end

--仙华佗

sgs.ai_skill_invoke.kexianwuqin = function(self, data)
	return true
end


























