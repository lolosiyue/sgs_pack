--==《新武将》==--
extension = sgs.Package("kearjsrgrcheng", sgs.Package_GeneralPack)
local skills = sgs.SkillList()

--buff集中
kechengslashmore = sgs.CreateTargetModSkill{
	name = "kechengslashmore",
	pattern = ".",
	residue_func = function(self, from, card, to)
		local n = 0
		if (from:getMark("&kechengbiaozhaofrom")>0) and to and (to:getMark("&kechengbiaozhaoto")>0) then
			n = n + 1000
		end
		if from:hasSkill("kechengxianzhu") and (card:getSkillName() == "kechengxianzhuslash") then
			n = n + 1000
		end
		return n
	end,
	extra_target_func = function(self, from, card)
		local n = 0
		if (from:getMark("&kechengneifaNotBasic") > 0 and card:isNDTrick()) then
			n = n + 1
		end
		return n
	end,
	distance_limit_func = function(self, from, card, to)
		local n = 0
		if (from:getMark("&kechengbiaozhaofrom")>0) and to and (to:getMark("&kechengbiaozhaoto")>0) then
			n = n + 1000
		end
		return n
	end
}
if not sgs.Sanguosha:getSkill("kechengslashmore") then skills:append(kechengslashmore) end


kechengsunce = sgs.General(extension, "kechengsunce$", "wu", 4)

kechengduxingCard = sgs.CreateSkillCard{
	name = "kechengduxingCard",
	target_fixed = false,
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		return (to_select:objectName() ~= sgs.Self:objectName()) --and (#targets > 0)
	end,
	on_use = function(self, room, player, targets)
		local players = sgs.SPlayerList()
		if targets[1] then players:append(targets[1]) end
		if targets[2] then players:append(targets[2]) end
		if targets[3] then players:append(targets[3]) end
		if targets[4] then players:append(targets[4]) end
		if targets[5] then players:append(targets[5]) end
		if targets[6] then players:append(targets[6]) end
		if targets[7] then players:append(targets[7]) end
		if targets[8] then players:append(targets[8]) end
		if targets[9] then players:append(targets[9]) end
		room:sortByActionOrder(players)
		for _,p in sgs.qlist(players) do
			room:handleAcquireDetachSkills(p, "kechengduxingex")
		end
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		duel:setSkillName("kechengduxing")
		local card_use = sgs.CardUseStruct()
		card_use.from = player
		card_use.to = players
		card_use.card = duel
		room:useCard(card_use, false)
		duel:deleteLater()	  
		for _,p in sgs.qlist(room:getAllPlayers()) do
			room:handleAcquireDetachSkills(p, "-kechengduxingex")
		end
	end
}
--主技能
kechengduxingVS = sgs.CreateViewAsSkill{
	name = "kechengduxing",
	n = 0,
	view_as = function(self, cards)
		return kechengduxingCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#kechengduxingCard")
	end, 
}

kechengduxing = sgs.CreateTriggerSkill{
	name = "kechengduxing",
	view_as_skill = kechengduxingVS,
	events = {sgs.TargetSpecified,sgs.CardFinished,sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		--[[if (event == sgs.TargetSpecified) and player:hasSkill(self:objectName()) then
			local use = data:toCardUse()
		    if (use.card:getSkillName() == "kechengduxing") then
				for _,p in sgs.qlist(use.to) do
					room:setPlayerFlag(p,"intheduxingduel")
					--room:handleAcquireDetachSkills(p, "kechengduxingex")
					for _,card in sgs.qlist(p:getCards("h")) do
						local transcard = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
						transcard:setSkillName(self:objectName())
						local newcard = sgs.Sanguosha:getWrappedCard(card:getId())
						newcard:takeOver(transcard)
					end
				end
			end
		end]]
		if (event == sgs.CardFinished) and player:hasSkill(self:objectName())  then
			local use = data:toCardUse()
		    if (use.card:getSkillName() == "kechengduxing") then
				for _,p in sgs.qlist(room:getAllPlayers()) do
					if p:hasSkill("kechengduxingex") then
				    	room:handleAcquireDetachSkills(p, "-kechengduxingex")
					end
					--[[if p:hasFlag("intheduxingduel") then
					    room:filterCards(p, p:getCards("he"), true)
						room:setPlayerFlag(p,"-intheduxingduel")
				    end]]
				end
			end
		end
		--[[if (event == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if move.to and (move.to:objectName() == player:objectName()) 
			and player:hasFlag("intheduxingduel")
			and (move.to_place == sgs.Player_PlaceHand) then
				for _,card in sgs.qlist(player:getCards("h")) do
					local transcard = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
					transcard:setSkillName(self:objectName())
					local newcard = sgs.Sanguosha:getWrappedCard(card:getId())
					newcard:takeOver(transcard)
				end
			end
		end]]
	end,
	can_trigger = function(self, player)
		return player
	end,
}
kechengsunce:addSkill(kechengduxing)

kechengduxingex = sgs.CreateFilterSkill{
	name = "kechengduxingex&", 
	view_filter = function(self,to_select)
		local room = sgs.Sanguosha:currentRoom()
		local place = room:getCardPlace(to_select:getEffectiveId())
		return (place == sgs.Player_PlaceHand) 
	end,
	view_as = function(self, originalCard)
		local slash = sgs.Sanguosha:cloneCard("slash", originalCard:getSuit(), originalCard:getNumber())
		slash:setSkillName(self:objectName())
		local card = sgs.Sanguosha:getWrappedCard(originalCard:getId())
		card:takeOver(slash)
		return card
	end
}
if not sgs.Sanguosha:getSkill("kechengduxingex") then skills:append(kechengduxingex) end

kechengzhiheng = sgs.CreateTriggerSkill{
	name = "kechengzhiheng",
	events = {sgs.CardResponded,sgs.CardUsed,sgs.DamageCaused},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.DamageCaused) then
			local damage = data:toDamage()
			if damage.from:hasSkill(self:objectName()) and (damage.to:getMark("&kechengzhiheng-Clear") > 0) then
				room:sendCompulsoryTriggerLog(damage.from,self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local hurt = damage.damage
				damage.damage = hurt + 1
				data:setValue(damage)
			end
		end
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			local resto = use.from
			--resto就是出杀的人
			local scs = room:findPlayersBySkillName(self:objectName())
			for _, sc in sgs.qlist(scs) do  
				if resto and (sc:objectName() == player:objectName()) or (sc:objectName() == resto:objectName()) and not (resto:objectName() == player:objectName()) then
					local players = sgs.SPlayerList()
					if (resto:objectName() == sc:objectName()) then
						if (player:objectName() ~= sc:objectName()) then
						    room:setPlayerMark(player,"&kechengzhiheng-Clear",1)
						end
					end
				end
			end
		end
		if (event == sgs.CardResponded) then
			local response = data:toCardResponse()
			local restocard = response.m_toCard
			local rescard = response.m_card
			local resto = room:getCardUser(response.m_toCard)
			local scs = room:findPlayersBySkillName(self:objectName())
			for _, sc in sgs.qlist(scs) do  
				if (sc:objectName() == player:objectName()) or (sc:objectName() == resto:objectName()) and not (resto:objectName() == player:objectName()) then
					local players = sgs.SPlayerList()
					if (resto:objectName() == sc:objectName()) then
						if (player:objectName() ~= sc:objectName()) then
						    room:setPlayerMark(player,"&kechengzhiheng-Clear",1)
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
kechengsunce:addSkill(kechengzhiheng)

kechengzhasi = sgs.CreateTriggerSkill{
    name = "kechengzhasi",
	frequency = sgs.Skill_Limited,
	limit_mark = "@kechengzhasi",
	waked_skills = "tenyearzhiheng",
	events = {sgs.DamageInflicted,sgs.Damaged,sgs.CardUsed},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if not ((use.to:length() == 1) and (use.to:contains(player))) then
				if (player:getMark("&inzhasi") > 0) then
					room:setPlayerMark(player,"&inzhasi",0)
					room:addDistance(player, -9999, false, false)
				end
			end
		end
		if (event == sgs.Damaged) then
			if (player:getMark("&inzhasi") > 0) then
				room:setPlayerMark(player,"&inzhasi",0)
				room:addDistance(player, -9999, false, false)
			end
		end
		if (event == sgs.DamageInflicted) and (player:getMark("@kechengzhasi") > 0) then
			local damage = data:toDamage()
			if (damage.damage >= player:getHp()) and room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName())
			    room:doSuperLightbox("kechengsunce", "kechengzhasi")
				room:removePlayerMark(player,"@kechengzhasi")
				room:handleAcquireDetachSkills(player, "-kechengzhiheng|tenyearzhiheng")
				room:addDistance(player, 9999, false, false)
				room:setPlayerMark(player,"&inzhasi",1)
				return true		
			end
		end
	end,
}
kechengsunce:addSkill(kechengzhasi)

kechengbashi = sgs.CreateTriggerSkill{
	name = "kechengbashi$",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardAsked,sgs.TargetSpecified,sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.TargetSpecified) then
			local use = data:toCardUse()
			local scs = room:findPlayersBySkillName(self:objectName())
			for _, sc in sgs.qlist(scs) do
				if use.to:contains(sc) and use.card:isKindOf("Slash") and sc:hasLordSkill(self:objectName()) then
					room:setCardFlag(use.card,"banbashislash")
					room:setPlayerMark(sc,"banbashijink",1)
				end
			end
		end
		if (event == sgs.CardFinished) then
			local use = data:toCardUse()
			local scs = room:findPlayersBySkillName(self:objectName())
			for _, sc in sgs.qlist(scs) do
				if use.to:contains(sc) and use.card:hasFlag("banbashislash") then
					room:setPlayerMark(sc,"banbashijink",0)
				end
			end
		end
		if (event == sgs.CardAsked) and player:hasLordSkill(self:objectName()) and (player:getMark("usetimebashi-Clear") < 3) then
			local pattern = data:toStringList()[1]
			if (pattern == "jink") and (player:getMark("banbashijink") == 0) then 
				local lieges = room:getLieges("wu", player)
				if lieges:isEmpty() then return false end
				if not room:askForSkillInvoke(player,"keshengbashiusejink", data) then return false end

				local log = sgs.LogMessage()
				log.type = "$usekechengbashi"
				log.from = player
				room:sendLog(log)
				room:broadcastSkillInvoke(self:objectName())
				local tohelp = sgs.QVariant()
				tohelp:setValue(player)
				for _, p in sgs.qlist(lieges) do
					if (p:getState() ~= "online") and p:isYourFriend(player) 
					or ((p:isYourFriend(player)) or ((player:isYourFriend(p))) and player:getHp()+player:getHp()+player:getHandcardNum()<=8) then
						local jink = room:askForCard(p, "jink", "kechengbashijink-ask", tohelp, sgs.Card_MethodResponse, player, false,"", true)
						if jink then
							room:addPlayerMark(player,"usetimebashi-Clear",1)
							room:provide(jink)
							return true
						end
					elseif (p:getState() ~= "online") and not p:isYourFriend(player) then
						local jink = room:askForCard(p, "mbxks", "kechengbashijink-ask", tohelp, sgs.Card_MethodResponse, player, false,"", true)
						if jink then
							room:addPlayerMark(player,"usetimebashi-Clear",1)
							room:provide(jink)
							return true
						end
					elseif p:getState() == "online" then
						local jink = room:askForCard(p, "jink", "kechengbashijink-ask", tohelp, sgs.Card_MethodResponse, player, false,"", true)
						if jink then
							room:addPlayerMark(player,"usetimebashi-Clear",1)
							room:provide(jink)
							return true
						end
					end
				end
			end
			if (pattern == "slash") then 
				local lieges = room:getLieges("wu", player)
				if lieges:isEmpty() then return false end
				if not room:askForSkillInvoke(player, "keshengbashiuseslash", data) then return false end
				local log = sgs.LogMessage()
				log.type = "$usekechengbashi"
				log.from = player
				room:sendLog(log)
				room:broadcastSkillInvoke(self:objectName())
				local tohelp = sgs.QVariant()
				tohelp:setValue(player)
				for _, p in sgs.qlist(lieges) do
					if ((p:getState() ~= "online") and p:isYourFriend(player)) 
					or ((p:isYourFriend(player)) or ((player:isYourFriend(p))) and player:getHp()+player:getHp()+player:getHandcardNum()<=8) then
						local slash = room:askForCard(p, "slash", "kechengbashislash-ask", tohelp, sgs.Card_MethodResponse, player, false,"", true)
						if slash then
							room:addPlayerMark(player,"usetimebashi-Clear",1)
							room:provide(slash)
							return true
						end
					elseif p:getState() ~= "online" and not p:isYourFriend(player) then
						local slash = room:askForCard(p, "mbxks", "kechengbashislash-ask", tohelp, sgs.Card_MethodResponse, player, false,"", true)
						if slash then
							room:addPlayerMark(player,"usetimebashi-Clear",1)
							room:provide(slash)
							return true
						end
					elseif p:getState() == "online" then
						local slash = room:askForCard(p, "slash", "kechengbashislash-ask", tohelp, sgs.Card_MethodResponse, player, false,"", true)
						if slash then
							room:addPlayerMark(player,"usetimebashi-Clear",1)
							room:provide(slash)
							return true
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end
}
kechengsunce:addSkill(kechengbashi)




kechengchendeng = sgs.General(extension, "kechengchendeng", "qun", 3)

kechenglunshiCard = sgs.CreateSkillCard{
	name = "kechenglunshiCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return (#targets == 0)
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		local num = 0
		for _, p in sgs.qlist(room:getOtherPlayers(target)) do
			if target:inMyAttackRange(p) then
				num = num + 1
			end
		end
		if (target:getHandcardNum() < 5) then
			if (num > (5-target:getHandcardNum())) then
				num = 5 - target:getHandcardNum()
			end
			target:drawCards(num)
		end
		local qi = 0
		for _, p in sgs.qlist(room:getOtherPlayers(target)) do
			if p:inMyAttackRange(target) then
				qi = qi + 1
			end
		end
		if (math.min(target:getCardCount(),qi) > 0) then
		    room:askForDiscard(target,"kechenglunshi", math.min(target:getCardCount(),qi), math.min(target:getCardCount(),qi), false, true, "kechenglunshi-discard")
		end
	end
}
--主技能
kechenglunshi = sgs.CreateViewAsSkill{
	name = "kechenglunshi",
	n = 0,
	view_as = function(self, cards)
		return kechenglunshiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#kechenglunshiCard")
	end, 
}
kechengchendeng:addSkill(kechenglunshi)



kechengguitu = sgs.CreateTriggerSkill{
	name = "kechengguitu",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Start) then
				local players = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getWeapon() ~= nil) then
						players:append(p)
					end
				end
				if (players:length() > 1) then
					if (player:getState() ~= "online") then
						local aiplayers = sgs.SPlayerList()
						for _, p in sgs.qlist(players) do
							if ((p:isYourFriend(player) and player:isYourFriend(p)) or (p:objectName() == player:objectName()))
							and p:isWounded() then
								aiplayers:append(p)
								for _, pp in sgs.qlist(players) do
									if (pp:getAttackRange() < p:getAttackRange()) then
										aiplayers:append(pp)
										break
									end
								end
							end
						end
						if (aiplayers:length() == 2) then
							local exs = room:askForPlayersChosen(player, aiplayers, self:objectName(), 2, 2, "kechengguitu-ask", false, true)
							room:broadcastSkillInvoke(self:objectName())
							for _, p in sgs.qlist(room:getAllPlayers()) do
								room:setPlayerMark(p,"kechengguitucount",p:getAttackRange())
							end
							local theone = exs:at(0)
							local thetwo = exs:at(1)
							local exchangeMove = sgs.CardsMoveList()
							local move1 = sgs.CardsMoveStruct(theone:getWeapon():getId(), thetwo, sgs.Player_PlaceEquip, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, theone:objectName(), thetwo:objectName(), self:objectName(), ""))
							local move2 = sgs.CardsMoveStruct(thetwo:getWeapon():getId(), theone, sgs.Player_PlaceEquip, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, thetwo:objectName(), theone:objectName(), self:objectName(), ""))
							exchangeMove:append(move1)
							exchangeMove:append(move2)
							room:moveCardsAtomic(exchangeMove, false)
							for _, p in sgs.qlist(room:getAllPlayers()) do
								if (p:getAttackRange() < p:getMark("kechengguitucount")) then
									room:recover(p, sgs.RecoverStruct())
								end
								room:setPlayerMark(p,"kechengguitucount",0)
							end
						end
					elseif (player:getState() == "online") then
						local exs = room:askForPlayersChosen(player, players, self:objectName(), 0, 2, "kechengguitu-ask", false, true)
						if (exs:length() > 1) then
							room:broadcastSkillInvoke(self:objectName())
							for _, p in sgs.qlist(room:getAllPlayers()) do
								room:setPlayerMark(p,"kechengguitucount",p:getAttackRange())
							end
							local theone = exs:at(0)
							local thetwo = exs:at(1)
							local exchangeMove = sgs.CardsMoveList()
							local move1 = sgs.CardsMoveStruct(theone:getWeapon():getId(), thetwo, sgs.Player_PlaceEquip, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, theone:objectName(), thetwo:objectName(), self:objectName(), ""))
							local move2 = sgs.CardsMoveStruct(thetwo:getWeapon():getId(), theone, sgs.Player_PlaceEquip, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, thetwo:objectName(), theone:objectName(), self:objectName(), ""))
							exchangeMove:append(move1)
							exchangeMove:append(move2)
							room:moveCardsAtomic(exchangeMove, false)
							for _, p in sgs.qlist(room:getAllPlayers()) do
								if (p:getAttackRange() < p:getMark("kechengguitucount")) then
									room:recover(p, sgs.RecoverStruct())
								end
								room:setPlayerMark(p,"kechengguitucount",0)
							end
						end
					end
				end
			end
		end
			
	end,

}
kechengchendeng:addSkill(kechengguitu)



kechengguanyu = sgs.General(extension, "kechengguanyu", "shu", 5)


kechengguanjue = sgs.CreateTriggerSkill{
	name = "kechengguanjue",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed,sgs.CardResponded,sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardResponded) then
			local response = data:toCardResponse()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if (response.m_card:getSuit() == sgs.Card_Spade) then
					room:setPlayerMark(p,"kechengguanjueht-Clear",1)
					room:setPlayerMark(player,"@kechengguanjueht-Clear",1)
				end
				if (response.m_card:getSuit() == sgs.Card_Club) then
					room:setPlayerMark(p,"kechengguanjuemh-Clear",1)
					room:setPlayerMark(player,"@kechengguanjuemh-Clear",1)
				end
				if (response.m_card:getSuit() == sgs.Card_Heart) then
					room:setPlayerMark(p,"kechengguanjuehongt-Clear",1)
					room:setPlayerMark(player,"@kechengguanjuehongt-Clear",1)
				end
				if (response.m_card:getSuit() == sgs.Card_Diamond) then
					room:setPlayerMark(p,"kechengguanjuefp-Clear",1)
					room:setPlayerMark(player,"@kechengguanjuefp-Clear",1)
				end
			end
		end
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if (use.card:getSuit() == sgs.Card_Spade) then
					room:setPlayerMark(p,"kechengguanjueht-Clear",1)
					room:setPlayerMark(player,"@kechengguanjueht-Clear",1)
				end
				if (use.card:getSuit() == sgs.Card_Club) then
					room:setPlayerMark(p,"kechengguanjuemh-Clear",1)
					room:setPlayerMark(player,"@kechengguanjuemh-Clear",1)
				end
				if (use.card:getSuit() == sgs.Card_Heart) then
					room:setPlayerMark(p,"kechengguanjuehongt-Clear",1)
					room:setPlayerMark(player,"@kechengguanjuehongt-Clear",1)
				end
				if (use.card:getSuit() == sgs.Card_Diamond) then
					room:setPlayerMark(p,"kechengguanjuefp-Clear",1)
					room:setPlayerMark(player,"@kechengguanjuefp-Clear",1)
				end
			end
		end
	end,
}
kechengguanyu:addSkill(kechengguanjue)

kechengguanjueex = sgs.CreateCardLimitSkill{
	name = "kechengguanjueex",
	limit_list = function(self, player)
		if (player:getMark("kechengguanjueht-Clear")>0) 
		or (player:getMark("kechengguanjuemh-Clear")>0) 
		or(player:getMark("kechengguanjuehongt-Clear")>0) 
		or (player:getMark("kechengguanjuefp-Clear")>0) then
			return "use,response"
		else
			return ""
		end
	end,
	limit_pattern = function(self, player)
		--真的我会疯掉的，有人知道珂酱的精神状态吗？？？？？#@%#￥@#%@￥#……@￥% ！！！！  开摆开摆！！！！
		--单花色
		if (player:getMark("kechengguanjueht-Clear")>0) and (player:getMark("kechengguanjuemh-Clear")==0) 
		and (player:getMark("kechengguanjuehongt-Clear")==0) and (player:getMark("kechengguanjuefp-Clear")==0) then
			return ".|spade|.|."
		elseif (player:getMark("kechengguanjueht-Clear")==0) and (player:getMark("kechengguanjuemh-Clear")>0) 
		and (player:getMark("kechengguanjuehongt-Clear")==0) and (player:getMark("kechengguanjuefp-Clear")==0) then
			return ".|club|.|."
		elseif (player:getMark("kechengguanjueht-Clear")==0) and (player:getMark("kechengguanjuemh-Clear")==0) 
		and (player:getMark("kechengguanjuehongt-Clear")>0) and (player:getMark("kechengguanjuefp-Clear")==0) then
			return ".|heart|.|."
		elseif (player:getMark("kechengguanjueht-Clear")==0) and (player:getMark("kechengguanjuemh-Clear")==0) 
		and (player:getMark("kechengguanjuehongt-Clear")==0) and (player:getMark("kechengguanjuefp-Clear")>0) then
			return ".|diamond|.|."
        --2花色
	    elseif (player:getMark("kechengguanjueht-Clear")>0) and (player:getMark("kechengguanjuemh-Clear")>0) 
		and (player:getMark("kechengguanjuehongt-Clear")==0) and (player:getMark("kechengguanjuefp-Clear")==0) then
			return ".|spade,club|.|."
		elseif (player:getMark("kechengguanjueht-Clear")>0) and (player:getMark("kechengguanjuemh-Clear")==0) 
		and (player:getMark("kechengguanjuehongt-Clear")>0) and (player:getMark("kechengguanjuefp-Clear")==0) then
			return ".|spade,heart|.|."
		elseif (player:getMark("kechengguanjueht-Clear")>0) and (player:getMark("kechengguanjuemh-Clear")==0) 
		and (player:getMark("kechengguanjuehongt-Clear")==0) and (player:getMark("kechengguanjuefp-Clear")>0) then
			return ".|spade,diamond|.|."
		elseif (player:getMark("kechengguanjueht-Clear")==0) and (player:getMark("kechengguanjuemh-Clear")>0) 
		and (player:getMark("kechengguanjuehongt-Clear")>0) and (player:getMark("kechengguanjuefp-Clear")==0) then
			return ".|club,heart|.|."
		elseif (player:getMark("kechengguanjueht-Clear")==0) and (player:getMark("kechengguanjuemh-Clear")>0) 
		and (player:getMark("kechengguanjuehongt-Clear")==0) and (player:getMark("kechengguanjuefp-Clear")>0) then
			return ".|club,diamond|.|."
		elseif (player:getMark("kechengguanjueht-Clear")==0) and (player:getMark("kechengguanjuemh-Clear")==0) 
		and (player:getMark("kechengguanjuehongt-Clear")>0) and (player:getMark("kechengguanjuefp-Clear")>0) then
			return ".|diamond,heart|.|."
        --三花色
		elseif (player:getMark("kechengguanjueht-Clear")>0) and (player:getMark("kechengguanjuemh-Clear")>0) 
		and (player:getMark("kechengguanjuehongt-Clear")>0) and (player:getMark("kechengguanjuefp-Clear")==0) then
			return ".|spade,club,heart|.|."
		elseif (player:getMark("kechengguanjueht-Clear")>0) and (player:getMark("kechengguanjuemh-Clear")==0) 
		and (player:getMark("kechengguanjuehongt-Clear")>0) and (player:getMark("kechengguanjuefp-Clear")>0) then
			return ".|spade,heart,diamond|.|."
		elseif (player:getMark("kechengguanjueht-Clear")>0) and (player:getMark("kechengguanjuemh-Clear")>0) 
		and (player:getMark("kechengguanjuehongt-Clear")==0) and (player:getMark("kechengguanjuefp-Clear")>0) then
			return ".|spade,diamond,club|.|."
		elseif (player:getMark("kechengguanjueht-Clear")==0) and (player:getMark("kechengguanjuemh-Clear")>0) 
		and (player:getMark("kechengguanjuehongt-Clear")>0) and (player:getMark("kechengguanjuefp-Clear")>0) then
			return ".|diamond,club,heart|.|."
		--四花色
		elseif (player:getMark("kechengguanjueht-Clear")>0) and (player:getMark("kechengguanjuemh-Clear")>0) 
		and (player:getMark("kechengguanjuehongt-Clear")>0) and (player:getMark("kechengguanjuefp-Clear")>0) then
			return ".|spade,diamond,club,heart|.|."
		else
			return ""
		end
	
	end
}
if not sgs.Sanguosha:getSkill("kechengguanjueex") then skills:append(kechengguanjueex) end
--[[if (event == sgs.EventPhaseChanging) then
	local change = data:toPhaseChange()
	if (change.to == sgs.Player_NotActive) then
		for _, p in sgs.qlist(room:getAllPlayers()) do
			room:removePlayerCardLimitation(p, "use,response", ".|spade|.|hand")
			room:removePlayerCardLimitation(p, "use,response", ".|club|.|hand")
			room:removePlayerCardLimitation(p, "use,response", ".|heart|.|hand")
			room:removePlayerCardLimitation(p, "use,response", ".|diamond|.|hand")
		end
	end
end
is_prohibited = function(self, from, to, card)
		return (
			((from:getMark("kechengguanjueht-Clear") > 0) and (card:getSuit() == sgs.Card_Spade))
		or ((from:getMark("kechengguanjuemh-Clear") > 0) and (card:getSuit() == sgs.Card_Club))
		or ((from:getMark("kechengguanjuehongt-Clear") > 0) and (card:getSuit() == sgs.Card_Heart))
		or ((from:getMark("kechengguanjuefp-Clear") > 0) and (card:getSuit() == sgs.Card_Diamond))
	)
if (event == sgs.CardResponded) then
	local response = data:toCardResponse()
	for _, p in sgs.qlist(room:getOtherPlayers(player)) do
		if (response.m_card:getSuit() == sgs.Card_Spade) then
			room:setPlayerCardLimitation(p, "use,response", ".|spade|.|hand", false)
			room:setPlayerMark(player,"@kechengguanjueht-Clear",1)
		end
		if (response.m_card:getSuit() == sgs.Card_Club) then
			room:setPlayerCardLimitation(p, "use,response", ".|club|.|hand", false)
			room:setPlayerMark(player,"@kechengguanjuemh-Clear",1)
		end
		if (response.m_card:getSuit() == sgs.Card_Heart) then
			room:setPlayerCardLimitation(p, "use,response", ".|heart|.|hand", false)
			room:setPlayerMark(player,"@kechengguanjuehongt-Clear",1)
		end
		if (response.m_card:getSuit() == sgs.Card_Diamond) then
			room:setPlayerCardLimitation(p, "use,response", ".|diamond|.|hand", false)
			room:setPlayerMark(player,"@kechengguanjuefp-Clear",1)
		end
	end
end
if (event == sgs.CardUsed) then
	local use = data:toCardUse()
	for _, p in sgs.qlist(room:getOtherPlayers(player)) do
		if (use.card:getSuit() == sgs.Card_Spade) then
			local pattern = ".|spade|.|hand"
			room:setPlayerCardLimitation(p, "use,response", pattern, false)
			room:setPlayerMark(player,"@kechengguanjueht-Clear",1)
		end
		if (use.card:getSuit() == sgs.Card_Club) then
			local pattern = ".|club|.|hand"
			room:setPlayerCardLimitation(p, "use,response", pattern, false)
			room:setPlayerMark(player,"@kechengguanjuemh-Clear",1)
		end
		if (use.card:getSuit() == sgs.Card_Heart) then
			local pattern = ".|heart|.|hand"
			room:setPlayerCardLimitation(p, "use,response", pattern, false)
			room:setPlayerMark(player,"@kechengguanjuehongt-Clear",1)
		end
		if (use.card:getSuit() == sgs.Card_Diamond) then
			local pattern = ".|diamond|.|hand"
			room:setPlayerCardLimitation(p, "use,response", pattern, false)
			room:setPlayerMark(player,"@kechengguanjuefp-Clear",1)
		end
	end
end]]

kechengnianenCard = sgs.CreateSkillCard{
	name = "kechengnianen",
	will_throw = false,
	mute = true,
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
				and not (card:isKindOf("Slash") and not sgs.Self:canSlash(to_select, true, rangefix))
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return false
		end
		local card = sgs.Self:getTag("kechengnianen"):toCard()
		return card and card:targetFilter(plist, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, plist)
			and not (card:isKindOf("Slash") and not sgs.Self:canSlash(to_select, true, rangefix))
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
		local card = sgs.Self:getTag("kechengnianen"):toCard()
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
		local card = sgs.Self:getTag("kechengnianen"):toCard()
		return card and card:targetsFeasible(plist, sgs.Self)
	end,
	on_validate = function(self, card_use)
		local player = card_use.from
		local room, to_kechengnianen = player:getRoom(), self:getUserString()
		if self:getUserString() == "slash" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local kechengnianen_list = {}
			table.insert(kechengnianen_list, "slash")
			table.insert(kechengnianen_list, "fire_slash")
			table.insert(kechengnianen_list, "thunder_slash")
			table.insert(kechengnianen_list, "ice_slash")
			to_kechengnianen = room:askForChoice(player, "kechengnianen_slash", table.concat(kechengnianen_list, "+"))
		end
		local card = nil
		if self:subcardsLength() == 1 then card = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(self:getSubcards():first())) end
		local user_str
		if to_kechengnianen == "slash" then
			--if card and card:isKindOf("Slash")and not (card:isKindOf("FireSlash") or card:isKindOf("ThunderSlash") or card:isKindOf("IceSlash")) then
			if card and card:objectName() == "slash" then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		else
			user_str = to_kechengnianen
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str, card and card:getSuit() or sgs.Card_SuitToBeDecided, card and card:getNumber() or -1)
		use_card:setSkillName("kechengnianen")
		use_card:addSubcards(self:getSubcards())
		use_card:deleteLater()
		return use_card
	end,
	on_validate_in_response = function(self, user)
		local room, user_str = user:getRoom(), self:getUserString()
		local to_kechengnianen
		if user_str == "peach+analeptic" then
			local kechengnianen_list = {}
			table.insert(kechengnianen_list, "peach")
			table.insert(kechengnianen_list, "analeptic")
			to_kechengnianen = room:askForChoice(user, "kechengnianen_saveself", table.concat(kechengnianen_list, "+"))
		elseif user_str == "slash" then
			local kechengnianen_list = {}
			table.insert(kechengnianen_list, "slash")
			table.insert(kechengnianen_list, "fire_slash")
			table.insert(kechengnianen_list, "thunder_slash")
			table.insert(kechengnianen_list, "ice_slash")
			to_kechengnianen = room:askForChoice(user, "kechengnianen_slash", table.concat(kechengnianen_list, "+"))
		else
			to_kechengnianen = user_str
		end
		local card = nil
		if self:subcardsLength() == 1 then card = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(self:getSubcards():first())) end
		local user_str
		if to_kechengnianen == "slash" then
			if card and card:objectName() == "slash" then
			--if card and card:isKindOf("Slash") and not (card:isKindOf("FireSlash") or card:isKindOf("ThunderSlash") or card:isKindOf("IceSlash"))then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		else
			user_str = to_kechengnianen
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str, card and card:getSuit() or sgs.Card_SuitToBeDecided, card and card:getNumber() or -1)
		use_card:setSkillName("kechengnianen")
		use_card:addSubcards(self:getSubcards())
		use_card:deleteLater()
		return use_card
	end,
}
kechengnianenVS = sgs.CreateViewAsSkill{
	name = "kechengnianen",
	n = 1,
	response_or_use = true,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local skillcard = kechengnianenCard:clone()
		skillcard:setSkillName(self:objectName())
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE
			or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			skillcard:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			for _, card in ipairs(cards) do
				skillcard:addSubcard(card)
			end
			return skillcard
		end
		local c = sgs.Self:getTag("kechengnianen"):toCard()
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
		if (player:getMark("&bannianen-Clear") > 0) then return false end
		local basic = {"slash", "peach"}
		table.insert(basic, "fire_slash")
		table.insert(basic, "thunder_slash")
		table.insert(basic, "ice_slash")
		table.insert(basic, "analeptic")
		for _, patt in ipairs(basic) do
			local poi = sgs.Sanguosha:cloneCard(patt, sgs.Card_NoSuit, -1)
			if poi and poi:isAvailable(player) and not (patt == "peach" and not player:isWounded()) then
				return true
			end
		end
		return false
	end,
	enabled_at_response = function(self, player, pattern)
        if (player:getMark("&bannianen-Clear") > 0) then return false end
		if string.startsWith(pattern, ".") or string.startsWith(pattern, "@") then return false end
        if pattern == "peach" and player:getMark("Global_PreventPeach") > 0 then return false end
        return pattern ~= "nullification" and pattern ~= "jl_wuxiesy"
	end,
}

kechengnianen = sgs.CreateTriggerSkill{
	name = "kechengnianen",
	view_as_skill = kechengnianenVS,
	waked_skills = "mashu",
	events = {sgs.CardUsed,sgs.CardResponded,sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("kechengnianenoneturnmashu")>0) then
						room:handleAcquireDetachSkills(p, "-mashu")
						room:setPlayerMark(p,"kechengnianenoneturnmashu",0)
					end
				end
			end
		end
		if (event == sgs.CardResponded) and player:hasSkill(self:objectName()) then
			local response = data:toCardResponse()
			if (response.m_card:getSkillName() == "kechengnianen") then
				if (not response.m_card:isRed()) or (response.m_card:objectName() ~= "slash") then
				--if (not response.m_card:isRed()) or (not response.m_card:isKindOf("Slash"))
				--or response.m_card:isKindOf("FireSlash") or response.m_card:isKindOf("ThunderSlash") or response.m_card:isKindOf("IceSlash") then
					room:handleAcquireDetachSkills(player, "mashu")
					room:setPlayerMark(player,"kechengnianenoneturnmashu",1)
					room:setPlayerMark(player,"&bannianen-Clear",1)
				end
			end
		end
		if (event == sgs.CardUsed) and player:hasSkill(self:objectName()) then
			local use = data:toCardUse()
			if (use.card:getSkillName() == "kechengnianen") then
				if (not use.card:isRed()) or (use.card:objectName() ~= "slash") then
					room:handleAcquireDetachSkills(player, "mashu")
					room:setPlayerMark(player,"kechengnianenoneturnmashu",1)
					room:setPlayerMark(player,"&bannianen-Clear",1)
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end,
}
kechengnianen:setGuhuoDialog("l")
kechengguanyu:addSkill(kechengnianen)



kechengxugong = sgs.General(extension, "kechengxugong", "wu", 3)

kechengbiaozhao = sgs.CreateTriggerSkill{
	name = "kechengbiaozhao",
	frequency = sgs.Skill_Frequent ,
	events = {sgs.EventPhaseStart,sgs.ConfirmDamage,sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Death) then
			local death = data:toDeath()
			if (death.who:objectName() == player:objectName()) and player:hasSkill(self:objectName()) then 
				for _, p in sgs.qlist(room:getAllPlayers()) do
					room:setPlayerMark(p,"&kechengbiaozhaofrom",0)
					room:setPlayerMark(p,"&kechengbiaozhaoto",0)
				end
			end
		end
		if (event == sgs.ConfirmDamage) then
			local damage = data:toDamage()
			if damage.card and (damage.from:getMark("&kechengbiaozhaoto")>0) and (damage.to:getMark("kechengbiaozhaoself")>0) then
				room:sendCompulsoryTriggerLog(damage.from, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local hurt = damage.damage
				damage.damage = hurt + 1
				data:setValue(damage)
			end
		end
		if (event == sgs.EventPhaseStart) and player:hasSkill(self:objectName()) then
			if (player:getPhase() == sgs.Player_RoundStart) then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					room:setPlayerMark(p,"&kechengbiaozhaofrom",0)
					room:setPlayerMark(p,"&kechengbiaozhaoto",0)
					room:setPlayerMark(p,"kechengbiaozhaoself",0)
				end
			end
			if (player:getPhase() == sgs.Player_Start) then
				if player:getState() ~= "online" then
					local aiplayers = sgs.SPlayerList()
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if (p:isYourFriend(player) and player:isYourFriend(p)) then
							if (p:getHandcardNum() > (player:getHandcardNum()+2)) then
					            aiplayers:append(p)
								break
							end
						end
					end
					if aiplayers:length() == 0 then
						aiplayers:append(player)
					end
					local enys = sgs.SPlayerList()
					local pre = sgs.SPlayerList()
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if not (p:isYourFriend(player) and player:isYourFriend(p)) then
							enys:append(p)
						end
					end
					for _, enemy in sgs.qlist(enys) do
						if pre:isEmpty() then
							pre:append(enemy)
						else
							local yes = 1
							for _,p in sgs.qlist(pre) do
								if (enemy:getHp()+enemy:getHp()+enemy:getHandcardNum()) >= (p:getHp()+p:getHp()+p:getHandcardNum()) then
									yes = 0
								end
							end
							if (yes == 1) then
								pre:removeOne(pre:at(0))
								pre:append(enemy)
							end
						end
					end
					for _, p in sgs.qlist(pre) do
						aiplayers:append(p)
					end
					if not (aiplayers:length() == 2) then return false end
					local players = room:askForPlayersChosen(player, aiplayers, self:objectName(), 2, 2, "kechengbiaozhao-ask", true, false)
					room:broadcastSkillInvoke(self:objectName())
					room:setPlayerMark(players:at(0),"&kechengbiaozhaofrom",1)
					room:setPlayerMark(players:at(1),"&kechengbiaozhaoto",1)
					room:setPlayerMark(player,"kechengbiaozhaoself",1)
				else
					local players = room:askForPlayersChosen(player, room:getAllPlayers(), self:objectName(), 0, 2, "kechengbiaozhao-ask", true, false)
					if (players:length() == 2) then
						room:broadcastSkillInvoke(self:objectName())
						room:setPlayerMark(players:at(0),"&kechengbiaozhaofrom",1)
						room:setPlayerMark(players:at(1),"&kechengbiaozhaoto",1)
						room:setPlayerMark(player,"kechengbiaozhaoself",1)
					end
				end
			end
		end

	end,
	can_trigger = function(self, target)
		return target
	end,
}
kechengxugong:addSkill(kechengbiaozhao)

kechengyechou = sgs.CreateTriggerSkill{
	name = "kechengyechou",
	events = {sgs.Death} ,
	frequency = sgs.Skill_Frequent ,
	can_trigger = function(self, target)
		return target ~= nil and target:hasSkill(self:objectName())
	end ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Death) then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then return false end
			local one = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "kechengyechou-ask", true, true)
			if one then
				room:broadcastSkillInvoke(self:objectName())
				room:setPlayerMark(one,"&kechengyechou",1)
			end
		end
	end
}
kechengxugong:addSkill(kechengyechou)


kechengyechouex = sgs.CreateTriggerSkill{
	name = "kechengyechouex",
	events = {sgs.DamageInflicted} ,
	global = true,
	priority = -10,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.DamageInflicted) then
			local damage = data:toDamage()
			if (damage.to:hasSkill(self:objectName()) or (damage.to:getMark("&kechengyechou") > 0))
			and (damage.damage >= damage.to:getHp()) then
				room:broadcastSkillInvoke("kechengyechou")
				room:sendCompulsoryTriggerLog(damage.to,self:objectName())
				local hurt = damage.damage
				for i = 0, damage.to:getMark("&kechengyechou") - 1, 1 do
				    damage.damage = hurt + hurt
					hurt = damage.damage
				end
				data:setValue(damage)
			end
		end
	end,
	can_trigger = function(self, target)
		return (target:getMark("&kechengyechou") > 0) 
	end ,
}
if not sgs.Sanguosha:getSkill("kechengyechouex") then skills:append(kechengyechouex) end



kechenglvbu = sgs.General(extension, "kechenglvbu", "qun+shu", 5)

kechengwuchang = sgs.CreateTriggerSkill{
	name = "kechengwuchang" ,
	events = {sgs.CardsMoveOneTime, sgs.DamageCaused} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if move.to and (move.to:objectName() == player:objectName()) and move.from and move.from:isAlive()
					and (move.from:objectName() ~= move.to:objectName()) and (move.to:getKingdom() ~= move.from:getKingdom())
					and (move.card_ids:length() >= 1)
					and (move.reason.m_reason ~= sgs.CardMoveReason_S_REASON_PREVIEWGIVE) then
				room:broadcastSkillInvoke(self:objectName())
				room:setPlayerProperty(player, "kingdom", sgs.QVariant(move.from:getKingdom()))
				room:sendCompulsoryTriggerLog(player,self:objectName())
				local log = sgs.LogMessage() log.type = "$kechengwuchangchange" log.from = player log.to:append(move.from)
				room:sendLog(log)
			end
		end
		if (event == sgs.DamageCaused) then
			local damage = data:toDamage()
			if (damage.from:objectName() == player:objectName()) 
			and (damage.card:isKindOf("Slash") or damage.card:isKindOf("Duel")) 
			and (damage.from:getKingdom() == damage.to:getKingdom()) then
				room:sendCompulsoryTriggerLog(damage.from, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local hurt = damage.damage
				damage.damage = hurt + 1
				data:setValue(damage)
				room:setPlayerProperty(damage.from, "kingdom", sgs.QVariant("qun"))
			end
		end
	end
}
kechenglvbu:addSkill(kechengwuchang)

--推心置腹
KCTuixinzhifu = sgs.CreateTrickCard{
	name = "_kecheng_tuixinzhifu",
	class_name = "KCTuixinzhifu",
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
		and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self,to_select)
	end,
	on_effect = function(self,effect)
		local from,to,room = effect.from,effect.to,effect.to:getRoom()
		local flags = to:getCards("ej"):length()<1 and "h" or "hej"
		local dc = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		--local dc = dummyCard()
		for i=1,2 do
			if from:isAlive()
			and to:getCardCount(true,true)>dc:subcardsLength()
			then
				i = dc:getSubcards()
				local id = room:askForCardChosen(from,to,flags,self:objectName(),false,sgs.Card_MethodNone,i,true)
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
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION,from:objectName(),to:objectName(),"_kecheng_tuixinzhifu","")
			room:obtainCard(from,dc,reason,false)
			if from:isAlive() and to:isAlive() then
	    	   	local givenum = dc:subcardsLength()
				--from:setTag("_kecheng_tuixinzhifu",ToData(to))
				local dccard = room:askForExchange(from,"_kecheng_tuixinzhifu",givenum,givenum,false,"kechengtuixinzhifuask")
				room:giveCard(from,to,dccard,"_kecheng_tuixinzhifu")
			end
		end
		dc:deleteLater()
	end,
}
local card = KCTuixinzhifu:clone()
card:setSuit(-1)
card:setNumber(-1)
card:setParent(extension)

--趁火打劫
KCChenhuodajie = sgs.CreateTrickCard{
	name = "_kecheng_chenhuodajie",
	class_name = "KCChenhuodajie",
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
	    return to_select:getHandcardNum()>0 and to_select:objectName()~=source:objectName()
		and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self,to_select)
	end,
	on_effect = function(self,effect)
		local from,to,room = effect.from,effect.to,effect.to:getRoom()
		if to:getHandcardNum()<1 then return end
		local id = room:askForCardChosen(from,to,"h",self:objectName())
		if id>=0
		then
			room:showCard(to,id)
			local c = sgs.Sanguosha:getCard(id)
			local _data = sgs.QVariant()
			_data:setValue(effect)
			if room:askForCard(to,id,"_kecheng_chenhuodajie0:"..c:objectName()..":"..from:objectName(),_data ,sgs.Card_MethodNone) then 
				room:obtainCard(from,c) 
			else 
				room:damage(sgs.DamageStruct(self,from,to)) 
			end
			--[[local result = room:askForChoice(effect.to, "kechengchenhuodajieask","givepai+shanghai")
			if result == "givepai" then
			    room:obtainCard(from,c) 
			else 
				room:damage(sgs.DamageStruct(self,from,to)) 
			end]]
		end
		return false
	end,
}
local card = KCChenhuodajie:clone()
card:setSuit(-1)
card:setNumber(-1)
card:setParent(extension)

kechengqingjiaoCard = sgs.CreateSkillCard{
	name = "kechengqingjiaoCard",
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		return ((to_select:getHandcardNum() > sgs.Self:getHandcardNum()) and (sgs.Self:getMark("&useqingjiaotxzf-Clear")<1) and (sgs.Self:distanceTo(to_select)<=1))
		or  ((to_select:getHandcardNum() < sgs.Self:getHandcardNum()) and (sgs.Self:getMark("&useqingjiaochdj-Clear")<1))
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local usethis = 0
		if (target:getHandcardNum() > source:getHandcardNum()) then
			usethis = 1
			local card = sgs.Sanguosha:getCard(self:getSubcards():first())
			local txzf = sgs.Sanguosha:cloneCard("_kecheng_tuixinzhifu", card:getSuit(), card:getNumber())
			txzf:setSkillName("kechengqingjiao") 
			txzf:addSubcard(card)
			if not source:isProhibited(target, txzf) then
				room:useCard(sgs.CardUseStruct(txzf, source, target))
				room:setPlayerMark(source,"&useqingjiaotxzf-Clear",1)
			end
			txzf:deleteLater()
		end
		if (target:getHandcardNum() < source:getHandcardNum()) and (usethis == 0) then
			local card = sgs.Sanguosha:getCard(self:getSubcards():first())
			local chdj = sgs.Sanguosha:cloneCard("_kecheng_chenhuodajie", card:getSuit(), card:getNumber())
			chdj:setSkillName("kechengqingjiao") 
			chdj:addSubcard(card)
			if not source:isProhibited(target, chdj) then
				room:useCard(sgs.CardUseStruct(chdj, source, target))
				room:setPlayerMark(source,"&useqingjiaochdj-Clear",1)
			end
			chdj:deleteLater()
		end
	end,
}

kechengqingjiao = sgs.CreateViewAsSkill{
	name = "kechengqingjiao",
	n = 1,
	view_filter = function(self, selected, to_select)
		return true
	end ,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = kechengqingjiaoCard:clone()
			card:addSubcard(cards[1])
			return card
		else 
			return nil
		end
	end,
	enabled_at_play = function(self, player)
		return (player:getKingdom() == "qun") and not ((player:getMark("&useqingjiaotxzf-Clear")>0) and (player:getMark("&useqingjiaochdj-Clear")>0))
	end, 
}
kechenglvbu:addSkill(kechengqingjiao)


kechengchengxu = sgs.CreateTriggerSkill{
	name = "kechengchengxu",
	frequency = sgs.Skill_Compulsory, 
	events = {sgs.TargetSpecified},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if (event == sgs.TargetSpecified) and (player:getKingdom() == "shu") then
			local use = data:toCardUse()
			if use.card:isKindOf("SkillCard") then return false end
			if not (use.to:contains(player) and (use.to:length() == 1) ) then 	
				local no_respond_list = use.no_respond_list
				for _, p in sgs.qlist(use.to) do
					if (p:objectName() ~= player:objectName()) and (p:getKingdom() == player:getKingdom()) then
					    table.insert(no_respond_list, p:objectName())
					end
				end
				use.no_respond_list = no_respond_list
				data:setValue(use)
				if #no_respond_list > 0 then
					room:sendCompulsoryTriggerLog(player,self:objectName())
					room:broadcastSkillInvoke("kechengwuchang")
				end
			end
		end
	end,
}
kechenglvbu:addSkill(kechengchengxu)



KCStabs_slash = sgs.CreateBasicCard{
	name = "_kecheng_stabs_slash",
	class_name = "KeSlash",
	subtype = "attack_card",
    can_recast = false,
	damage_card = true,
    available = function(self,player)
    end,
	filter = function(self,targets,to_select,source)
	end,
	on_use = function(self,room,source,targets)
	end,
	on_effect = function(self,effect)
	end,
}

--local cscard = sgs.Sanguosha:cloneCard("Slash",-1,-1)
--cscard:setObjectName("_kecheng_stabs_slash")
--cscard:setParent(extension)


local card = KCStabs_slash:clone()
card:setSuit(-1)
card:setNumber(-1)
card:setParent(extension)


kechengcisha = sgs.CreateTriggerSkill{
	name = "kechengcisha",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.SlashMissed},
	global = true,
	can_trigger = function(self,target)
		if table.contains(sgs.Sanguosha:getBanPackages(),"kearjsrgrcheng") then
		else 
			return target and target:isAlive() 
		end
	end,
	on_trigger = function(self,event,player,data,room)
		if (event == sgs.SlashMissed) then
			local effect = data:toSlashEffect()
			if effect.slash:objectName()=="_kecheng_stabs_slash"
			and effect.to:getHandcardNum()>0
			and effect.jink
			then
				--Skill_msg("_kecheng_stabs_slash",effect.from)
				if (effect.to:getState() ~= "online") and (effect.to:getHandcardNum()>1) then
					if room:askForDiscard(effect.to,"_kecheng_stabs_slash",1,1,false,false,"_kecheng_stabs_slash0:")
					then else room:slashResult(effect,nil) end
				else
					if room:askForDiscard(effect.to,"_kecheng_stabs_slash",1,1,true,false,"_kecheng_stabs_slash0:")
					then else room:slashResult(effect,nil) end
				end
			end
		end
	end
}
if not sgs.Sanguosha:getSkill("kechengcisha") then skills:append(kechengcisha) end


kechengxuyou = sgs.General(extension, "kechengxuyou", "qun+wei", 3)

kechenglipan = sgs.CreateTriggerSkill{
	name = "kechenglipan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()		
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					if player:getState() == "online" then
						local kd = room:askForKingdom(player)
						if (player:getKingdom() ~= kd) then
							room:broadcastSkillInvoke(self:objectName())
							room:setPlayerProperty(player, "kingdom", sgs.QVariant(kd))
						end
					else
						room:broadcastSkillInvoke(self:objectName())
						if (player:getKingdom() ~= "qun") then
							local log = sgs.LogMessage()
							log.type = "$kechenglipanqun"
							log.from = player
							room:sendLog(log)
							room:setPlayerProperty(player, "kingdom", sgs.QVariant("qun"))
							room:setPlayerFlag(player,"alreadylipan")
						elseif (player:getKingdom() ~= "wei") and not player:hasFlag("alreadylipan") then
							local log = sgs.LogMessage()
							log.type = "$kechenglipanwei"
							log.from = player
							room:sendLog(log)
							room:setPlayerProperty(player, "kingdom", sgs.QVariant("wei"))
						end
						room:setPlayerFlag(player,"-alreadylipan")
					end
					local num = 0
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if (p:getKingdom() == player:getKingdom()) then
							num = num + 1
						end
					end
					if (num > 0) then
						player:drawCards(num)
					end
					room:setPlayerMark(player,"&kechenglipan",1)
					player:setPhase(sgs.Player_Play)
					room:broadcastProperty(player, "phase")
					local thread = room:getThread()
					if not thread:trigger(sgs.EventPhaseStart, room, player) then
						thread:trigger(sgs.EventPhaseProceeding, room, player)
					end
					thread:trigger(sgs.EventPhaseEnd, room, player)
					player:setPhase(sgs.Player_NotActive)
					room:broadcastProperty(player, "phase")
					room:setPlayerMark(player,"&kechenglipan",0)
					--ai
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if (not (p:isYourFriend(player) or player:isYourFriend(p)))
						and ((p:getHp()+p:getHp()+p:getCardCount()) > (player:getHp()+player:getHp()+player:getCardCount())) then
							room:setPlayerMark(p,"wantuselipan-Clear",1)
						end
					end
					local pzt = 0
					local playerzt = 0
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if (p:getKingdom() == player:getKingdom()) and not p:isNude() then
							pzt = p:getHp()+p:getHp()+p:getCardCount()
							playerzt = player:getHp()+player:getHp()+player:getCardCount()
							if (p:getState() ~= "online") and (not (p:isYourFriend(player) or player:isYourFriend(p))) 
							and ((pzt > playerzt) or (pzt >= 10)) then
								--local to_duelint = room:askForCardChosen(p, p, "he", self:objectName())
								local to_duelint = room:askForExchange(p, self:objectName(), 1, 1, true, "lipanuseduel"):getSubcards():first()
								local to_duel = sgs.Sanguosha:getCard(to_duelint)
								local juedou = sgs.Sanguosha:cloneCard("duel", to_duel:getSuit(), to_duel:getNumber())
								juedou:setSkillName("kechenglipan") 
								juedou:addSubcard(to_duel)
								if not p:isProhibited(player, juedou) then
									room:useCard(sgs.CardUseStruct(juedou, p, player))
								end
								juedou:deleteLater()	
							elseif (p:getState() == "online") then
								--if room:askForSkillInvoke(p, "lipanuseduel", data) then
									--local to_duelint = room:askForCardChosen(p, p, "he", self:objectName())
									local to_duelint = room:askForExchange(p, self:objectName(), 1, 1, true, "lipanuseduel",true):getSubcards():first()
									if to_duelint then
										local to_duel = sgs.Sanguosha:getCard(to_duelint)
										local juedou = sgs.Sanguosha:cloneCard("duel", to_duel:getSuit(), to_duel:getNumber())
										juedou:setSkillName("kechenglipan") 
										juedou:addSubcard(to_duel)
										if not p:isProhibited(player, juedou) then
											room:useCard(sgs.CardUseStruct(juedou, p, player))
										end
										juedou:deleteLater()	
									end
								--end
							end
						end
					end
					--clear
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						room:setPlayerMark(p,"wantuselipan-Clear",0)
					end			

				end
			end
		end	
	end,

}
kechengxuyou:addSkill(kechenglipan)

kechengqingxiCard = sgs.CreateSkillCard{
	name = "kechengqingxiCard",
	target_fixed = false,
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		return ((#targets == 0) and (to_select:getHandcardNum() < sgs.Self:getHandcardNum()) 
		and (to_select:getMark("beusekechengqingxi-PlayClear") == 0))
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		room:setPlayerMark(target,"beusekechengqingxi-PlayClear",1)
		local cha = player:getHandcardNum() - target:getHandcardNum()
		room:askForDiscard(player, self:objectName(), cha, cha, false, false, "kechengqingxi-discard") 
		--local log = sgs.LogMessage()
		--log.type = "$kechengqingxiCardcisha"
		--log.from = player
		--log.to:append(target) 
		--room:sendLog(log)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("kechengqingxi")
		slash:setObjectName("_kecheng_stabs_slash")
		local card_use = sgs.CardUseStruct()
		card_use.from = player
		card_use.to:append(target)
		card_use.card = slash
		room:useCard(card_use, false)
		slash:deleteLater() 
	end
}
--主技能
kechengqingxi = sgs.CreateViewAsSkill{
	name = "kechengqingxi",
	n = 0,
	view_as = function(self, cards)
		return kechengqingxiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return (player:getKingdom() == "qun")
	end, 
}

--[[kechengqingxi = sgs.CreateTriggerSkill{
	name = "kechengqingxi",
	view_as_skill = kechengqingxiVS,
	events = {sgs.SlashMissed},
	can_trigger = function(self,target)
        return target and target:isAlive() 
	end,
	on_trigger = function(self,event,player,data,room)
		if (event == sgs.SlashMissed) then
			local effect = data:toSlashEffect()
			if (effect.slash:getSkillName() == "kechengqingxi")
			and effect.to:getHandcardNum()>0
			and effect.jink
			then
				--Skill_msg("_kecheng_stabs_slash",effect.from)
				if (effect.to:getState() ~= "online") and (effect.to:getHandcardNum()>1) then
					if room:askForDiscard(effect.to,"_kecheng_stabs_slash",1,1,false,false,"_kecheng_stabs_slash0:")
					then else room:slashResult(effect,nil) end
				else
					if room:askForDiscard(effect.to,"_kecheng_stabs_slash",1,1,true,false,"_kecheng_stabs_slash0:")
					then else room:slashResult(effect,nil) end
				end
			end
		end
	end
}]]
kechengxuyou:addSkill(kechengqingxi)

kechengjinmieCard = sgs.CreateSkillCard{
	name = "kechengjinmieCard",
	target_fixed = false,
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:getHandcardNum() > sgs.Self:getHandcardNum()) 
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		--room:setPlayerFlag(target,"theonejinmie")
		local slash = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("kechengjinmie")
		local card_use = sgs.CardUseStruct()
		card_use.from = player
		card_use.to:append(target)
		card_use.card = slash
		room:useCard(card_use,true)
		--room:setPlayerFlag(target,"-theonejinmie")
		slash:deleteLater() 
	end
}
--主技能
kechengjinmieVS = sgs.CreateViewAsSkill{
	name = "kechengjinmie",
	n = 0,
	view_as = function(self, cards)
		return kechengjinmieCard:clone()
	end,
	enabled_at_play = function(self, player)
		return (player:getKingdom() == "wei") and not player:hasUsed("#kechengjinmieCard") 
	end, 
}
kechengjinmie = sgs.CreateTriggerSkill{
	name = "kechengjinmie",
	view_as_skill = kechengjinmieVS,
	events = {sgs.CardUsed,sgs.Damage,sgs.CardFinished,sgs.DamageForseen},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if (damage.card:getSkillName() == "kechengjinmie") and not damage.chain then
				if ((damage.to:getHandcardNum() - damage.from:getHandcardNum()) > 0) then
				    room:broadcastSkillInvoke(self:objectName())
				end
				local cha = damage.to:getHandcardNum() - damage.from:getHandcardNum()
				while((damage.to:getHandcardNum() - damage.from:getHandcardNum()) > 0)
				do
					local to_throw = room:askForCardChosen(damage.from, damage.to, "h", self:objectName())
					local card = sgs.Sanguosha:getCard(to_throw)
					room:throwCard(card, damage.to, damage.from)
				end	
			end
		end
	end ,
}
kechengxuyou:addSkill(kechengjinmie)



kechengzhanghe = sgs.General(extension, "kechengzhanghe", "qun+wei", 4)

--技能穷途：鸣谢luas
kechengqongtuCard = sgs.CreateSkillCard{
	name = "qongtuCard",
	will_throw = false,
	target_fixed = true,
	on_validate = function(self,use)
--		NotifySkillInvoked("qongtu",use.from,use.to,false)
		use.from:getRoom():addPlayerMark(use.from,"kechengqongtu-Clear")
		use.from:addToPile("kechengqongtu",self)
		local use_card = sgs.Sanguosha:cloneCard("nullification")
		use_card:setSkillName("kechengqongtu")
		return use_card
	end,
	on_validate_in_response = function(self,from)
--		NotifySkillInvoked("qongtu",from,nil,false)
		from:getRoom():addPlayerMark(from,"kechengqongtu-Clear")
		from:addToPile("kechengqongtu",self)
		local use_card = sgs.Sanguosha:cloneCard("nullification")
		use_card:setSkillName("kechengqongtu")
		return use_card
	end
}
kechengqongtuvs = sgs.CreateViewAsSkill{
	name = "kechengqongtu",	
	n = 1,
	view_filter = function(self,selected,to_select)
		return to_select:getTypeId()>1
	end,
	view_as = function(self,cards)
		if #cards<1 then return end
		local new_card = kechengqongtuCard:clone()
		for _,c in ipairs(cards) do
			new_card:addSubcard(c)
		end
		return new_card
	end,
	enabled_at_response = function(self,player,pattern)
		if pattern=="nullification" and player:getMark("kechengqongtu-Clear")<1
		and (player:getHandcardNum()>0 or player:hasEquip())
		and player:getKingdom()=="qun"
		then return true end
	end,
	enabled_at_play = function(self,player)				
		return false
	end,
	enabled_at_nullification = function(self,player)
		return player:getMark("kechengqongtu-Clear")<1
		and player:getKingdom()=="qun"
		and (player:getHandcardNum()>0 or player:hasEquip())
	end
}
kechengqongtu = sgs.CreateTriggerSkill{
	name = "kechengqongtu" ,
	events = {sgs.CardFinished,sgs.PostCardEffected},
	view_as_skill = kechengqongtuvs,
	can_trigger = function(self,target)
		return target and target:isAlive()
	end,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.CardFinished
		then
		   	local use = data:toCardUse()
			if use.card:getTypeId()~=2 or not use.whocard then return end
			for i,owner in sgs.list(room:findPlayersBySkillName("kechengqongtu"))do
				if use.whocard:toString()==owner:getTag("kechengqongtuCard"):toString()
				then
					owner:setTag("kechengqongtuCard",sgs.QVariant(use.card:toString()))
					owner:setTag("kechengqongtuNull",sgs.QVariant(owner:getTag("kechengqongtuNull"):toInt()+1))
				elseif use.card:getSkillName()=="kechengqongtu"
				then
					owner:setTag("kechengqongtuWhocard",sgs.QVariant(room:getTag("NullifyingCard"):toCard():toString()))
					owner:setTag("kechengqongtuCard",sgs.QVariant(use.card:toString()))
					owner:setTag("kechengqongtuNull",sgs.QVariant(1))
				end
			end
		elseif event==sgs.PostCardEffected
		then
            local effect = data:toCardEffect()
			for i,owner in sgs.list(room:findPlayersBySkillName("kechengqongtu"))do
				if effect.card:toString()==owner:getTag("kechengqongtuWhocard"):toString()
				then
					owner:removeTag("kechengqongtuCard")
					owner:removeTag("kechengqongtuWhocard")
					local can = owner:getTag("kechengqongtuNull"):toInt()
					owner:removeTag("kechengqongtuNull")
					if math.mod(can,2)==1
					then
						owner:drawCards(1,"kechengqongtu")
					else
						room:setPlayerProperty(owner,"kingdom",sgs.QVariant("wei"))
						--can = dummyCard()
						local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						dummy:addSubcards(owner:getPile("kechengqongtu"))
						if dummy:subcardsLength()>0 then
							owner:obtainCard(dummy)
							dummy:deleteLater()
						end
					end
				end
			end
		end
		return false
	end
}
kechengzhanghe:addSkill(kechengqongtu)
--[[
kechengxianzhuCard = sgs.CreateSkillCard{
	name = "kechengxianzhuCard",
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		sgs.Self:canSlash(to_select, nil, false)
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		local slash = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
		slash:setSkillName("kechengxianzhu") --防止乱播报语音
		slash:addSubcard(card)
		room:useCard(sgs.CardUseStruct(slash, source, target))
		slash:deleteLater()
	end,
}

kechengxianzhuVS = sgs.CreateViewAsSkill{
	name = "kechengxianzhu",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isNDTrick()
	end ,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = kechengxianzhuCard:clone()
			card:addSubcard(cards[1])
			return card
		else 
			return nil
		end
	end,
	enabled_at_play = function(self, player)
		return true
	end, 
}]]

kechengxianzhuVS = sgs.CreateOneCardViewAsSkill{
	name = "kechengxianzhu",
	response_or_use = true,
	view_filter = function(self, card)
		if not card:isNDTrick() then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
			slash:addSubcard(card:getEffectiveId())
			slash:deleteLater()
			return true--slash:isAvailable(sgs.Self)
		end
		return true
	end,
	view_as = function(self, card)
		local slash = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
		slash:addSubcard(card:getId())
		slash:setSkillName("kechengxianzhuslash")
		return slash
	end,
	enabled_at_play = function(self, player)
		return (player:getKingdom() == "wei")
	end, 
	enabled_at_response = function(self, player, pattern)
		return (player:getKingdom() == "wei") and not pattern
	end
}

kechengxianzhu = sgs.CreateTriggerSkill{
	name = "kechengxianzhu",
	view_as_skill = kechengxianzhuVS,
	events = {sgs.Damage,sgs.CardUsed,sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardFinished) then
			local use = data:toCardUse()
			for _, p in sgs.qlist(use.to) do
				room:setPlayerMark(p,"kechengxianzhutarget",0)
			end
		end
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if (use.card:getSkillName() == "kechengxianzhuslash") then
				room:broadcastSkillInvoke("kechengqongtu")
				if (use.to:length() == 1) then
					for _, p in sgs.qlist(use.to) do
						room:setPlayerMark(p,"kechengxianzhutarget",1)
					end
				end
			end
		end
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if damage.card and (damage.card:getSkillName() == "kechengxianzhuslash")
			and (damage.to:getMark("kechengxianzhutarget") > 0) then
				if damage.to:isAlive() then
					room:broadcastSkillInvoke(self:objectName())
					room:doAnimate(1, damage.from:objectName(), damage.to:objectName())
					room:getThread():delay(500)
					local card = sgs.Sanguosha:getCard(damage.card:getSubcards():first())
					if not card:isKindOf("Nullification") then
						room:broadcastSkillInvoke(self:objectName())
						local xzplayers = sgs.SPlayerList()
						xzplayers:append(damage.to)
						card:use(room, damage.from,xzplayers )
					end
				end
			end
		end
	end,
}
kechengzhanghe:addSkill(kechengxianzhu)


kechengzhangliao = sgs.General(extension, "kechengzhangliao", "qun+wei", 4)

kechengzhengbingCard = sgs.CreateSkillCard{
	name = "kechengzhengbingCard",
	target_fixed = true ,
	will_throw = false,
	on_use = function(self, room, source, targets)
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		room:addPlayerMark(source,"kechengzhengbing-Clear",1)
		local msg = sgs.LogMessage()
		msg.type = "$kechengzhengbingcz"
		msg.from = source
		msg.arg = card:objectName()
		msg.arg2 = source:getGeneralName()
		room:sendLog(msg)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECAST, source:objectName())
		room:moveCardTo(card, source, sgs.Player_DiscardPile, reason)
		source:drawCards(1)
		if card:isKindOf("Slash") then
			room:addMaxCards(source, 2, true)
			room:addPlayerMark(source,"&kechengzhengbingsp-Clear",2)
		elseif card:isKindOf("Jink") then
			source:drawCards(1)
		elseif card:isKindOf("Peach") then
			room:setPlayerProperty(source, "kingdom", sgs.QVariant("wei"))
		end
	end,
}

kechengzhengbing = sgs.CreateViewAsSkill{
	name = "kechengzhengbing",
	n = 1,
	view_filter = function(self, selected, to_select)
		return true
	end ,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = kechengzhengbingCard:clone()
			card:addSubcard(cards[1])
			return card
		else 
			return nil
		end
	end,
	enabled_at_play = function(self, player)
		return (player:getMark("kechengzhengbing-Clear") < 3) and (player:getKingdom() == "qun")
	end, 
}
kechengzhangliao:addSkill(kechengzhengbing)


kechengtuwei = sgs.CreateTriggerSkill{
	name = "kechengtuwei",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart,sgs.EventPhaseChanging,sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Damaged) then
			local damage = data:toDamage()
			if (damage.to:getMark("&kechengtuwei") > 0) then
			    room:setPlayerMark(damage.to,"&kechengtuwei",0)
			end
		end
		if (event == sgs.EventPhaseChanging) and player:hasSkill(self:objectName()) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("&kechengtuwei") > 0) then
						room:sendCompulsoryTriggerLog(player,self:objectName())
						room:setPlayerMark(p,"&kechengtuwei",0)
						local card_id = room:askForCardChosen(p, player, "he", self:objectName())
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, p:objectName())
						room:obtainCard(p, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
					end
				end
			end
		end
		if (event == sgs.EventPhaseStart) 
		and player:hasSkill(self:objectName())
		and (player:getKingdom() == "wei") then
			if (player:getPhase() == sgs.Player_Play) then
				local players = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:objectName() ~= player:objectName()) and player:inMyAttackRange(p) and not p:isNude() then
						players:append(p)
					end
				end
				if players:length() > 0 then
					if (player:getState() ~= "online") then
						local drs = sgs.SPlayerList()
						for _, p in sgs.qlist(players) do
							if not (p:isYourFriend(player) and p:isYourFriend(player)) then
								drs:append(p)
							end
						end
						if (drs:length() > 0) then
							local enys = room:askForPlayersChosen(player, drs, self:objectName(), drs:length(), drs:length(), "kechengtuwei-ask", false, true)
							if (enys:length() > 0) then
								room:broadcastSkillInvoke(self:objectName())
							end
							for _, p in sgs.qlist(enys) do
								if not p:isNude() then
									room:setPlayerMark(p,"&kechengtuwei",1)
									local card_id = room:askForCardChosen(player, p, "he", self:objectName())
									local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
									room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
								end
							end
						end
					else
						local enys = room:askForPlayersChosen(player, players, self:objectName(), 0, 99, "kechengtuwei-ask", false, true)
						if (enys:length() > 0) then
							room:broadcastSkillInvoke(self:objectName())
						end
						for _, p in sgs.qlist(enys) do
							if not p:isNude() then
								room:setPlayerMark(p,"&kechengtuwei",1)
								local card_id = room:askForCardChosen(player, p, "he", self:objectName())
								local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
								room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
							end
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self,target)
		return target
	end
}
kechengzhangliao:addSkill(kechengtuwei)



kechengzoushi = sgs.General(extension, "kechengzoushi", "qun", 3,false)

kechengguyin = sgs.CreateTriggerSkill{
    name = "kechengguyin",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart,sgs.GameStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if (event == sgs.GameStart) and player:hasSkill(self:objectName()) then
			local num = 0
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if (p:getGender() == sgs.General_Male) then
					num = num + 1
				end
			end
			room:setPlayerMark(player,"kechengguyinmale",num)
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Start) then
				room:setPlayerMark(player,"&kechengguyinmale",player:getMark("kechengguyinmale"))
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					player:turnOver()
					local players = sgs.SPlayerList()
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if (p:getGender() == sgs.General_Male) then
							if (player:getMark("kechengguyinmale") >= 2) then
								room:setPlayerFlag(p,"willguyinturnover")
							end
							players:append(p)
						end
					end
					for _, p in sgs.qlist(players) do
						if room:askForSkillInvoke(p, "kechengguyinturnover", data) then
							p:turnOver()
						end
					end
					local allpeople = sgs.SPlayerList()
					allpeople:append(player)
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if not p:faceUp() then
					    	allpeople:append(p)
						end
					end
					local mopai = 0
					while(mopai < player:getMark("&kechengguyinmale"))
					do
						for _, p in sgs.qlist(allpeople) do
							if (mopai < player:getMark("&kechengguyinmale")) then
								p:drawCards(1)
								mopai = mopai + 1
							else
								break
							end
						end
					end
					for _, p in sgs.qlist(room:getAllPlayers()) do
						if (p:hasFlag("willguyinturnover")) then
							room:setPlayerFlag(p,"-willguyinturnover")
						end
					end
				end
				room:setPlayerMark(player,"&kechengguyinmale",0)
			end
		end
	end,
}
kechengzoushi:addSkill(kechengguyin)

kechengzhangdengCard = sgs.CreateSkillCard{
	name = "kechengzhangdengCard",
	target_fixed = true,
	mute = true,
	on_use = function(self, room, source, targets)
		local yse = 0
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if (p:hasSkill("kechengzhangdeng")) and not p:faceUp() then
				room:addPlayerMark(p,"&kechengzhangdeng-Clear",1)
				if (p:getMark("&kechengzhangdeng-Clear") == 2) then
					room:setPlayerMark(p,"&kechengzhangdeng-Clear",0)
					if not p:faceUp() then
						p:turnOver()
					end
				end
				yes = 1
			end
		end
		if (yes == 1) then
			--酒用来回血应该不计次，否则居然会影响下一个回合使用酒。。。
			if source:getHp() <= 0 then
				local analeptic = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				analeptic:setSkillName("kechengzhangdeng")
				local card_use = sgs.CardUseStruct()
				card_use.from = source
				card_use.to:append(source)
				card_use.card = analeptic
				room:useCard(card_use)    
				analeptic:deleteLater() 
			else
				local analeptic = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				analeptic:setSkillName("kechengzhangdeng")
				local card_use = sgs.CardUseStruct()
				card_use.from = source
				card_use.to:append(source)
				card_use.card = analeptic
				room:useCard(card_use,true)    
				analeptic:deleteLater() 
			end
		end
	end
}

kechengzhangdengex = sgs.CreateZeroCardViewAsSkill{
	name = "kechengzhangdengex&",
	view_as = function(self) 
		return kechengzhangdengCard:clone()
	end, 
	enabled_at_play = function(self, player)
		--监测到邹氏并且她处于翻面，则玩家也可以在自己翻面时使用此技能：视为使用酒
		if player:hasSkill("kechengzhangdeng") and (not player:faceUp()) then
			return ((sgs.Analeptic_IsAvailable(player)) and (not player:faceUp()))
		else
			for _, p in sgs.qlist(player:getAliveSiblings()) do
				if p:hasSkill("kechengzhangdeng") and (not p:faceUp()) then
					return ((sgs.Analeptic_IsAvailable(player)) and (not player:faceUp()))
				end
			end
		end
	    return false
	end, 
	enabled_at_response = function(self, player, pattern)
		--这个同理
		if player:hasSkill("kechengzhangdeng") and (not player:faceUp()) then
			return string.find(pattern, "analeptic") and not player:faceUp()
		else
			for _, p in sgs.qlist(player:getAliveSiblings()) do
				if p:hasSkill("kechengzhangdeng") and (not p:faceUp()) then
					return string.find(pattern, "analeptic") and not player:faceUp()
				end
			end
		end
	    return false
	end,
}
if not sgs.Sanguosha:getSkill("kechengzhangdengex") then skills:append(kechengzhangdengex) end

kechengzhangdeng = sgs.CreateTriggerSkill{
    name = "kechengzhangdeng",
	events = {sgs.GameStart,sgs.GameReady},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		--游戏开始前，给邹氏一个“邹氏”标记，，，或者判断有没有此技能其实也可以识别出邹氏
		if (event == sgs.GameReady) and player:hasSkill(self:objectName()) then
			room:setPlayerMark(player,"kechengthezoushi",1)
		end
		--游戏开始时，每个人发一个技能（上边那个），本技能只有邹氏有
		if (event == sgs.GameStart) then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if not p:hasSkill("kechengzhangdengex") then
					room:attachSkillToPlayer(p,"kechengzhangdengex")
				end
			end
		end
	end,
}
kechengzoushi:addSkill(kechengzhangdeng)


kechengchunyuqiong = sgs.General(extension, "kechengchunyuqiong", "qun", 4)

kechengcangchu = sgs.CreateTriggerSkill{
	name = "kechengcangchu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart,sgs.CardsMoveOneTime,sgs.GameStart,sgs.DrawInitialCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.DrawInitialCards) and player:hasSkill(self:objectName()) then
			room:setPlayerMark(player,"banusekechengcangchu",1)
		end
		if (event == sgs.GameStart) and player:hasSkill(self:objectName()) then
			room:setPlayerMark(player,"banusekechengcangchu",0)
		end
		if (event == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if move.to and (move.to:objectName() == player:objectName()) 
			and player:hasSkill(self:objectName())
			and (player:getMark("banusekechengcangchu") == 0)
			and (move.to_place == sgs.Player_PlaceHand) then
				room:addPlayerMark(player,"&kechengcangchu-Clear",move.card_ids:length())
			end
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Finish) then
				local cyqs = room:findPlayersBySkillName(self:objectName())
				for _, cyq in sgs.qlist(cyqs) do
					if cyq:getMark("&kechengcangchu-Clear") > 0 then
						if cyq:getState() ~= "online" then
							local dys = sgs.SPlayerList()
							for _, p in sgs.qlist(room:getAllPlayers()) do
								if (p:isYourFriend(cyq) and p:isYourFriend(cyq)) then
									dys:append(p)
								end
							end
							local fris = room:askForPlayersChosen(cyq,dys , self:objectName(), math.min(dys:length(),cyq:getMark("&kechengcangchu-Clear")),math.min(dys:length(),cyq:getMark("&kechengcangchu-Clear")) , "kechengcangchu-ask", false, true)
							if fris:length() > 0 then
								local log = sgs.LogMessage()
								log.type = "$usekechengcangchu"
								log.from = cyq
								room:sendLog(log)
								room:broadcastSkillInvoke(self:objectName())
							end
							local marknum = cyq:getMark("&kechengcangchu-Clear")
							for _, fri in sgs.qlist(fris) do
								local marknum = cyq:getMark("&kechengcangchu-Clear")
								local livenum = room:getAlivePlayers():length()
								if (marknum <= livenum) then
									fri:drawCards(1)
								else
									fri:drawCards(2)
								end
							end
						else
							local fris = room:askForPlayersChosen(cyq, room:getAllPlayers(), self:objectName(), 0, cyq:getMark("&kechengcangchu-Clear"), "kechengcangchu-ask", false, true)
							if fris:length() > 0 then
								local log = sgs.LogMessage()
								log.type = "$usekechengcangchu"
								log.from = cyq
								room:sendLog(log)
								room:broadcastSkillInvoke(self:objectName())
							end
							local marknum = cyq:getMark("&kechengcangchu-Clear")
							for _, fri in sgs.qlist(fris) do
								local marknum = cyq:getMark("&kechengcangchu-Clear")
								local livenum = room:getAlivePlayers():length()
								if (marknum <= livenum) then
									fri:drawCards(1)
								else
									fri:drawCards(2)
								end
							end
						end
					end
				end
			end
		end
			
	end,
	can_trigger = function(self,target)
        return target
	end,
}
kechengchunyuqiong:addSkill(kechengcangchu)


kechengshishou = sgs.CreateTriggerSkill{
	name = "kechengshishou",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed,sgs.Damaged,sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) then
				room:setPlayerMark(player,"&kechengcangchushixiao",0)
				room:setPlayerMark(player,"banusekechengcangchu",0)
			end
		end
		if (event == sgs.Damaged) then
			local damage = data:toDamage()
			if (damage.nature == sgs.DamageStruct_Fire)
			and (damage.to:objectName() == player:objectName()) then
				room:broadcastSkillInvoke(self:objectName())
				room:setPlayerMark(player,"&kechengcangchushixiao",1)
				room:setPlayerMark(player,"banusekechengcangchu",1)
			end
		end
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if use.card:isKindOf("Analeptic") then
				room:sendCompulsoryTriggerLog(player,self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				player:drawCards(3)
				room:setPlayerMark(player,"&kechengshishou-Clear",1)
			end
		end
	end,
}
kechengchunyuqiong:addSkill(kechengshishou)

kechengshishouex = sgs.CreateCardLimitSkill{
	name = "kechengshishouex",
	limit_list = function(self, player)
		if (player:getMark("&kechengshishou-Clear") > 0) then
			return "use"
		else
			return ""
		end
	end,
	limit_pattern = function(self, player)
		return "."
	end
}
if not sgs.Sanguosha:getSkill("kechengshishouex") then skills:append(kechengshishouex) end



kechengzhenfu = sgs.General(extension, "kechengzhenfu", "qun", 3,false)

kechengjixiangexCard = sgs.CreateSkillCard{
	name = "kechengjixiangexCard",
	target_fixed = true,
	mute = true,
	on_use = function(self, room, source, targets)
		for _, zf in sgs.qlist(room:getAllPlayers()) do
			if zf:hasSkill("kechengjixiang") and (zf:getPhase() ~= sgs.Player_NotActive) then
				local choices = {}
				if (zf:getMark("jixiangtao-Clear") == 0) then table.insert(choices, "peach") end
				if (zf:getMark("jixiangjiu-Clear") == 0) then table.insert(choices, "analeptic") end
				local choice = room:askForChoice(source, "kechengjixiang", table.concat(choices, "+"))
				if choice == "peach" then
					if room:askForDiscard(zf, "kechengjixiang", 1, 1, true,true,"kechengjixiangtao:"..source:objectName()) then
						room:setPlayerMark(zf,"jixiangtao-Clear",1)
						local peach = sgs.Sanguosha:cloneCard("peach", sgs.Card_NoSuit, 0)
						peach:setSkillName("kechengjixiang")
						local card_use = sgs.CardUseStruct()
						card_use.from = source
						card_use.to:append(source)
						card_use.card = peach
						room:useCard(card_use)    
						peach:deleteLater()
					end
				elseif choice == "analeptic" then
					if room:askForDiscard(zf, "kechengjixiang", 1, 1, true,true,"kechengjixiangjiu:"..source:objectName()) then
						room:setPlayerMark(zf,"jixiangjiu-Clear",1)
						local analeptic = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
						analeptic:setSkillName("kechengjixiang")
						local card_use = sgs.CardUseStruct()
						card_use.from = source
						card_use.to:append(source)
						card_use.card = analeptic
						room:useCard(card_use)    
						analeptic:deleteLater() 
					end
				end
			end
		end
	end,
	on_validate = function(self, cardUse) 
		cardUse.m_isOwnerUse = false
		local oplayer = cardUse.from
		local targets = cardUse.to
		room = oplayer:getRoom()
		local slash = nil
		for _, zf in sgs.qlist(room:getAllPlayers()) do
			if zf:hasSkill("kechengjixiang") and (zf:getPhase() ~= sgs.Player_NotActive) and (zf:objectName() ~= oplayer:objectName()) then
				if room:askForDiscard(zf, "kechengjixiang", 1, 1, true,true,"kechengjixiangsha:"..oplayer:objectName()) then
					local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					slash:setSkillName("kechengjixiang")
					return slash
				end
			end
		end
		return nil
	end
}

kechengjixiangex = sgs.CreateZeroCardViewAsSkill{
	name = "kechengjixiangex&",
	view_as = function(self) 
		return kechengjixiangexCard:clone()
	end, 
	enabled_at_play = function(self, player)
	    return false
	end, 
	enabled_at_response = function(self, player, pattern)
		for _, p in sgs.qlist(player:getAliveSiblings()) do
			if p:hasSkill("kechengjixiang") and (p:getPhase() ~= sgs.Player_NotActive) then
				return string.find(pattern, "analeptic") or string.find(pattern, "peach") or (pattern == "slash")
			end
		end	
	    return false
	end,
}
if not sgs.Sanguosha:getSkill("kechengjixiangex") then skills:append(kechengjixiangex) end


kechengjixiang = sgs.CreateTriggerSkill{
	name = "kechengjixiang",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardAsked,sgs.AskForPeaches,sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.GameStart) then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if not p:hasSkill("kechengjixiangex") then
					room:attachSkillToPlayer(p,"kechengjixiangex")
				end
			end
		end
		if (event == sgs.CardAsked) then
			local pattern = data:toStringList()[1]
			local canuse = 0
			for _, p in sgs.qlist(player:getAliveSiblings()) do
				if p:hasSkill(self:objectName()) and (p:getPhase() ~= sgs.Player_NotActive)  then
					canuse = 1
				end
			end		
			if (canuse ~= 1) then return false end 
			if (pattern == "jink") then 
				if room:askForSkillInvoke(player, self:objectName(), data) then
					local zfs = room:findPlayersBySkillName(self:objectName())
					local yes = 1
					for _,zf in sgs.qlist(zfs) do
						if (zf:objectName() ~= player:objectName()) and (zf:getPhase() ~= sgs.Player_NotActive) then
							if (yes == 1) and room:askForDiscard(zf, "kechengjixiang", 1, 1, true,true,"kechengjixiangshan:"..player:objectName()) then
								yes = 0
								local jink = sgs.Sanguosha:cloneCard("jink", sgs.Card_NoSuit, 0)
								jink:setSkillName(self:objectName())
								room:provide(jink)
								zf:drawCards(1)
								room:addPlayerMark(zf,"exusetimekechengchengxian-PlayClear")
								--增加次数！
								return true	
							end
						end
					end
			    end	
			end
			if (pattern == "slash") then 
				if room:askForSkillInvoke(player, self:objectName(), data) then
					local zfs = room:findPlayersBySkillName(self:objectName())
					local yes = 1
					for _,zf in sgs.qlist(zfs) do
						if (zf:objectName() ~= player:objectName()) and (zf:getPhase() ~= sgs.Player_NotActive) then
							if (yes == 1) and room:askForDiscard(zf, "kechengjixiang", 1, 1, true,true,"kechengjixiangsha:"..player:objectName()) then
								yes = 0
								local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
								slash:setSkillName(self:objectName())
								room:provide(slash)
								zf:drawCards(1)
								room:addPlayerMark(zf,"exusetimekechengchengxian-PlayClear")
								--增加次数！
								return true	
							end
						end
					end
			    end	
			end
		end		
	end,
	can_trigger = function(self, player)
	    return player
	end
}
kechengzhenfu:addSkill(kechengjixiang)

kechengchengxianCard = sgs.CreateSkillCard{
	name = "kechengchengxianCard" ,
	target_fixed = true ,
	mute = true,
	will_throw = false,
	about_to_use = function(self,room,use)
		local card = sgs.Sanguosha:getCard(self:getEffectiveId())
		local orinum = room:getCardTargets(use.from,card,sgs.SPlayerList(),true):length()
		if card:isKindOf("AOE") or card:isKindOf("GlobalEffect")
		then elseif card:targetFixed() then orinum = 1 end
		if orinum<1 then return end
		local choices = {}
		for _,id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
			local tcard = sgs.Sanguosha:getEngineCard(id)
			if tcard:isNDTrick()
			then
				if table.contains(choices,tcard:objectName())
				or use.from:getMark(tcard:objectName().."kechengchengxian-Clear")>0
				then continue end
				local transcard = sgs.Sanguosha:cloneCard(tcard:objectName())
				transcard:setSkillName("kechengchengxian")
				transcard:addSubcard(self)
				if not transcard:isAvailable(use.from) then continue end
				local trannum = room:getCardTargets(use.from,tcard,sgs.SPlayerList(),true):length()
				if tcard:isKindOf("AOE") or tcard:isKindOf("GlobalEffect")
				then elseif tcard:targetFixed() then trannum = 1 end
				if trannum==orinum then table.insert(choices,tcard:objectName()) end
			end
		end
		if #choices<1 then return end
		table.insert(choices,"cancel")
		local choice = room:askForChoice(use.from,"kechengchengxian", table.concat(choices, "+"))
		if choice=="cancel" then return end
		for _,id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
			local c = sgs.Sanguosha:getEngineCard(id)
			if c:objectName()==choice then room:setPlayerMark(use.from,"kechengchengxianName",id) break end
		end
		room:setPlayerMark(use.from,"kechengchengxianId",self:getEffectiveId())
		if room:askForUseCard(use.from,"@@kechengchengxian","kechengchengxian-ask:"..choice)
		then
			room:addPlayerMark(use.from,choice.."kechengchengxian-Clear")
			room:addPlayerMark(use.from,"kechengchengxianCard-PlayClear")
		end
	end
}
kechengchengxian = sgs.CreateViewAsSkill{
	name = "kechengchengxian" ,
	n = 1 ,
	view_filter = function(self, cards, to_select)
		if sgs.Sanguosha:getCurrentCardUsePattern()=="@@kechengchengxian" then return end
		return not to_select:isEquipped() and to_select:isAvailable(sgs.Self)
	end ,
	view_as = function(self, cards)
		if sgs.Sanguosha:getCurrentCardUsePattern()=="@@kechengchengxian"
		then
			local c = sgs.Sanguosha:getEngineCard(sgs.Self:getMark("kechengchengxianName"))
			local transcard = sgs.Sanguosha:cloneCard(c:objectName())
			transcard:addSubcard(sgs.Self:getMark("kechengchengxianId"))
			transcard:setSkillName("kechengchengxian")
			return transcard
		elseif #cards==1
		then
			local card = kechengchengxianCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end ,
	enabled_at_response = function(self,player,pattern)
		return pattern=="@@kechengchengxian"
	end,
	enabled_at_play = function(self, player)
		return player:getMark("kechengchengxianCard-PlayClear")-player:getMark("exusetimekechengchengxian-PlayClear")<2
	end

}
kechengzhenfu:addSkill(kechengchengxian)


kechengeryuan = sgs.General(extension, "kechengeryuan", "qun", 4)

kechengneifa = sgs.CreateTriggerSkill{
	name = "kechengneifa",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart,sgs.TargetSpecifying,sgs.CardUsed,sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) and (player:getMark("&kechengneifaNotBasic") > 0) then
				room:removePlayerCardLimitation(player, "use", "BasicCard")
				room:setPlayerMark(player,"&kechengneifaNotBasic",0)
			end
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Play) and room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName())
				player:drawCards(2)
				local card_id = room:askForDiscard(player, self:objectName(), 1, 1, false, true, "kechengneifa-discard"):getSubcards():first() 
				--local card = room:askForCard(player, ".", "kechengneifa-discard", sgs.QVariant(), self:objectName())
				local card = sgs.Sanguosha:getCard(card_id)
				if card then
					room:addPlayerMark(player, "HandcardVisible_ALL-Clear")
					if card:isKindOf("BasicCard") then
						local pren = 0
						for _,c in sgs.qlist(player:getCards("h")) do
							if not player:canUse(c) then
								pren = pren + 1
							end
						end
						room:setPlayerCardLimitation(player, "use", "TrickCard,EquipCard", true)
						local n = 0
						for _,c in sgs.qlist(player:getCards("h")) do
							if not player:canUse(c) then
								n = n + 1
							end
						end
						local nfn = math.max(n - pren,0)
						room:addSlashCishu(player, nfn)
						room:addSlashMubiao(player, 1)
						room:setPlayerMark(player, "&kechengneifaBasic-Clear", nfn)
					else
						room:setPlayerCardLimitation(player, "use", "BasicCard",false)
						room:setPlayerMark(player, "&kechengneifaNotBasic", 1)
					end
				--room:askForDiscard(player,self:objectiveLevel(), math.min(player:getCardCount(),1), math.min(player:getCardCount(),1), false, true, "kechengneifa-discard")
				end
			end
		end
		if (event == sgs.TargetSpecifying) then
			local use = data:toCardUse()
			if use.card:isNDTrick() and (player:getMark("&kechengneifaNotBasic") > 0) then
				--for ai
				if use.card:isKindOf("SavageAssault") or use.card:isKindOf("ArcheryAttack") then
					room:setPlayerFlag(player,"neifaremovefri")
				end
				local one = room:askForPlayerChosen(player, use.to, self:objectName(), "kechengneifa-ask", true, true)
				if one then
					if use.to:contains(one) then
					    use.to:removeOne(one)
					--else
						--use.to:append(one)
					end
					data:setValue(use)
				end
			end
		end
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()		
			if use.card:isKindOf("EquipCard")
			and (player:getMark("banneifafirst-Clear") == 0)
			and (player:getMark("&kechengneifaNotBasic") > 0) then
				room:setPlayerMark(player,"banneifafirst-Clear",1)
				room:removePlayerCardLimitation(player, "use", "BasicCard")
				local pren = 0
				for _,c in sgs.qlist(player:getCards("h")) do
					if not player:canUse(c) then
						pren = pren + 1
					end
				end
				room:setPlayerCardLimitation(player, "use", "BasicCard",false)
				local n = 0
				for _,c in sgs.qlist(player:getCards("h")) do
					if not player:canUse(c) then
						n = n + 1
					end
				end
				local cha = n - pren
				if (cha <= 0) then cha = 1 end
				room:broadcastSkillInvoke(self:objectName())
				player:drawCards(cha)
			end
		end
	end,
}
kechengeryuan:addSkill(kechengneifa)








kechengtaoqian = sgs.General(extension, "kechengtaoqian", "qun", 3)
kechengtaoqian:addSkill("zhaohuo")
kechengtaoqian:addSkill("tenyearyixiang")

kechengyirang = sgs.CreateTriggerSkill{
	name = "kechengyirang",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Play) and not player:isNude() then
				--for ai
				local frinum = 0
				for _,p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:isYourFriend(player) and player:isYourFriend(p) then
						room:setPlayerFlag(p,"kechengyirangflag")
						frinum = frinum + 1
					end
				end
				if frinum > 0 then room:setPlayerFlag(player,"aiuseyirang") end
				--end for ai
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:setPlayerFlag(player,"-aiuseyirang")
					room:showAllCards(player)
					local give = 0
					for _,card in sgs.qlist(player:getCards("he")) do
						if not card:isKindOf("BasicCard") then
							give = 1
							break
						end
					end
					if not (give == 1) then return false end
					local one = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "kechengyirang-ask", false, true)
					if one then
						local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						for _,card in sgs.qlist(player:getCards("he")) do
							if not card:isKindOf("BasicCard") then
								dummy:addSubcard(card:getId())
							end
						end
						local rec = dummy:subcardsLength()
						if (rec>0) and one:isAlive() then
							one:obtainCard(dummy)
						end		
						dummy:deleteLater()
						if (one:getMaxHp() > player:getMaxHp()) then
							room:gainMaxHp(player,one:getMaxHp() - player:getMaxHp())
						end
						if (rec > 0) then
							local recover = sgs.RecoverStruct()
							recover.who = player
							recover.recover = rec
							room:recover(player, recover)
						end
					end
				end
				for _,p in sgs.qlist(room:getAllPlayers()) do
					if p:hasFlag("kechengyirangflag") then
						room:setPlayerFlag(p,"-kechengyirangflag")
					end
				end
			end
		end
	end,

}
kechengtaoqian:addSkill(kechengyirang)






--[[
kechengchengxianCard = sgs.CreateSkillCard{
	name = "kechengchengxianCard" ,
	target_fixed = true ,
	mute = true,
	will_throw = false,
	on_use = function(self, room, player, targets)
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		--room:setCardFlag(card,"readytochengxian")
		--空壳列表用于填充参数
		local kplayers = sgs.SPlayerList()
		--先让系统判断一下目标，过河拆桥，南蛮入侵，杀这些还是可以正常判断的
		local orinum = room:getCardTargets(player,card,kplayers,true):length()
		--修正：否则装备牌判断为可以对所有人使用，闪，酒，桃，无中生有也是
		--手动修正目标数
		if card:isKindOf("Jink")
		or (card:isKindOf("Peach") and not player:isWounded()) 
		or (card:isKindOf("Analeptic") and not sgs.Analeptic_IsAvailable(player))  then 
			orinum = 0
		end
		if (card:isKindOf("Analeptic") and sgs.Analeptic_IsAvailable(player)) 
		or (card:isKindOf("Peach") and player:isWounded()) 
		or card:isKindOf("EquipCard") 
		or card:isKindOf("ExNihilo") then 
			orinum = 1
		end
		player:drawCards(orinum)
		if not (orinum == 0) then
			local choices = {}
			--看这局游戏有哪些锦囊牌
			--local allids = 
			for _, id in sgs.qlist(room:getDrawPile()) do
				local tcard = sgs.Sanguosha:getCard(id)
				if tcard:isNDTrick() then
					local trannum = room:getCardTargets(player,tcard,kplayers,true):length()
					--无中生有目标数修正一下！为1
					if tcard:isKindOf("ExNihilo")  then 
						trannum = 1
					end
					--如果这个牌目标数和用来转换的牌合法目标数相同，就加入选项
					if (trannum == orinum) and (not table.contains(choices, tcard:objectName())) and (not table.contains(player:getTag("Alreadychengxian"):toString():split("+"), tcard:objectName()) ) then
						table.insert(choices, tcard:objectName())
					end
				end
			end
			--加入取消选项
			table.insert(choices, "cancel")
			--玩家选一个牌名
			local choice = room:askForChoice(player, "kechengchengxian", table.concat(choices, "+"))

			local transcard = sgs.Sanguosha:cloneCard( xkscard:getName() , card:getSuit(), card:getNumber())
			transcard:setSkillName(self:objectName())
			local newcard = sgs.Sanguosha:getWrappedCard(card:getId())
			newcard:takeOver(transcard)
			if room:askForUseCard(player, ""..newcard:getId(), "zhuangzhiuse-ask",-1,sgs.Card_MethodUse, false, player, nil) then
				--使用之后就减少剩余可用次数（默认两次和来自另一个技能赠送的
				if (player:getMark("usetimekechengchengxian-PlayClear") > 0) then
					room:removePlayerMark(player,"usetimekechengchengxian-PlayClear",1)
				elseif (player:getMark("exusetimekechengchengxian-PlayClear") > 0) then
					room:removePlayerMark(player,"exusetimekechengchengxian-PlayClear",1)
				end
			end
		end
	end
}
--挑选一张牌
kechengchengxianVS = sgs.CreateViewAsSkill{
	name = "kechengchengxian" ,
	n = 1 ,
	view_filter = function(self, cards, to_select)
		return (not sgs.Self:isJilei(to_select)) and (not to_select:isEquipped())
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local card = kechengchengxianCard:clone()
		card:addSubcard(cards[1])
		card:setSkillName(self:objectName())
		return card
	end ,
	enabled_at_play = function(self, player)
		--默认两次，加上额外次数必须大于0，才能发动
		return ((player:getMark("usetimekechengchengxian-PlayClear") + player:getMark("exusetimekechengchengxian-PlayClear")) > 0)
	end
}
kechengchengxian = sgs.CreateTriggerSkill{
	name = "kechengchengxian",
	view_as_skill = kechengchengxianVS,
	events = {sgs.EventPhaseStart,sgs.EventPhaseChanging,sgs.EventAcquireSkill,sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		--回合结束清除本回合记录的牌名，下回合就能重新用了
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) then
				room:removeTag("Alreadychengxian")
			end
		end
		--出牌阶段开始，给玩家2枚使用次数
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Play) then
				room:setPlayerMark(player,"usetimekechengchengxian-PlayClear",2)
			end
		end
	end,
}
kechengzhenfu:addSkill(kechengchengxian)]]
--[[
kechengchengxianuseVS = sgs.CreateOneCardViewAsSkill{
	name = "kechengchengxianuse", 
	view_filter = function(self, cards, to_select)
		return true--to_select:hasFlag("readytochengxian")
	end ,
	view_as = function(self, card) 
		local pai = sgs.Self:getTag("Chengxianusetag"):toString()
		local cxcard = sgs.Sanguosha:cloneCard(pai, card:getSuit(), card:getNumber())
		cxcard:addSubcard(card:getId())
		cxcard:setSkillName("kechengchengxian")
		return cxcard
	end, 
	response_pattern = "@@kechengchengxianxks",
	enabled_at_play = function(self, player)
		return false
	end
}

--if not sgs.Sanguosha:getSkill("kechengchengxianuse") then skills:append(kechengchengxianuse) end

kechengchengxianuse = sgs.CreateTriggerSkill{
	name = "kechengchengxianuse",
	view_as_skill = kechengchengxianuseVS,
	events = {sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.MarkChanged) then
			local mark = data:toMark()
			if (mark.name == "mbxks_zhenfu") and (mark.who:objectName() == player:objectName()) then
				player:drawCards(5)
				if room:askForUseCard(player, "@@kechengchengxianxks", "kechengchengxian1") then
					--减少使用次数
					if (player:getMark("usetimekechengchengxian-PlayClear") > 0) then
						room:removePlayerMark(player,"usetimekechengchengxian-PlayClear",1)
					elseif (player:getMark("exusetimekechengchengxian-PlayClear") > 0) then
						room:removePlayerMark(player,"exusetimekechengchengxian-PlayClear",1)
					end
					--增加本回合已用过的牌名纪录，结束时清除
					local alreadychengxian = player:getTag("Alreadychengxian"):toString():split("+")
					if not table.contains(alreadychengxian, choice) then
						table.insert(alreadychengxian, choice)
						player:setTag("Alreadychengxian", sgs.QVariant(table.concat(alreadychengxian, "+")))
					end
				end
				room:removeTag("Chengxianusetag")
			end
		end
	end,
}
kechengzhenfu:addSkill(kechengchengxianuse)
]]



kechengquyi = sgs.General(extension, "kechengquyi", "qun", 4,true,true)
kechengquyi:addSkill("fuqi")
kechengquyi:addSkill("jiaozi")

kechengcaosong = sgs.General(extension, "kechengcaosong", "wei", 4,true,true)
kechengcaosong:addSkill("lilu")
kechengcaosong:addSkill("yizhengc")

kechenggaolan = sgs.General(extension, "kechenggaolan", "qun", 4,true,true)
kechenggaolan:addSkill("mobileyongjungong")
kechenggaolan:addSkill("mobileyongdengli")

kechengyanfuren = sgs.General(extension, "kechengyanfuren", "qun", 3,false,true)
kechengyanfuren:addSkill("channi")
kechengyanfuren:addSkill("nifu")







sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable{
    ["kearjsrgrcheng"] = "江山如故·承",

	["_kecheng_chenhuodajie"] = "趁火打劫",
	[":_kecheng_chenhuodajie"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名其他角色<br /><b>效果</b>：你展示其一张手牌，然后其选择一项：将此牌交给你；或受到你造成的1点伤害。",
	["_kecheng_tuixinzhifu"] = "推心置腹",
	[":_kecheng_tuixinzhifu"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：与你距离为1的角色<br /><b>效果</b>：你获得其区域内至多两张牌，然后交给其等量的手牌。",
	["_kecheng_stabs_slash"] = "刺杀",
	["_kecheng_stabs_slash0"] = "刺杀:请弃置一张手牌，否则此【刺杀】依旧造成伤害",
	[":_kecheng_stabs_slash"] = "基本牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：攻击范围内的一名其他角色<br /><b>效果</b>：对目标角色造成1点伤害。\
	<b>额外效果</b>：目标使用【闪】抵消此【刺杀】时，若其有手牌，其需弃置一张手牌，否则此【刺杀】依旧造成伤害。",
	["_kecheng_tuixinzhifu0"] = "推心置腹：请选择 %src 张手牌交给 %dest",
	["_kecheng_chenhuodajie0"] = "趁火打劫：你可以将此【%src】交给 %dest ；或受到 %dest 造成的1点伤害",
	["kechengchenhuodajieask"] = "趁火打劫",
	["kechengchenhuodajieask:givepai"] = "令其获得展示的牌",
	["kechengchenhuodajieask:shanghai"] = "受到其造成的1点伤害",
	["kechengtuixinzhifuask"] = "请选择交给该角色的牌",


	["kechengsunce"] = "孙策-承", 
	["&kechengsunce"] = "孙策",
	["#kechengsunce"] = "问鼎的霸王",
	["designer:kechengsunce"] = "官方",
	["cv:kechengsunce"] = "官方",
	["illustrator:kechengsunce"] = "君桓文化",

	["kechengduxing"] = "独行",
	["kechengduxingCard"] = "独行",
	["kechengduxingex"] = "独行buff",
	[":kechengduxingex"] = "独行：你的手牌均视为【杀】",
	[":kechengduxing"] = "出牌阶段限一次，你可以视为使用一张无目标数限制的【决斗】，目标角色的手牌均视为【杀】直到此牌结算完毕。",

	["kechengzhiheng"] = "猘横",
	[":kechengzhiheng"] = "锁定技，你使用牌对当前回合响应过你使用的牌的角色造成的伤害+1。",
	
	["kechengzhasi"] = "诈死",
	["inzhasi"] = "诈死",
	[":kechengzhasi"] = "限定技，你可以防止你受到的致命伤害，失去“猘横”并获得“制衡”，然后其他角色与你的距离为无限直到你对其他角色使用牌时或当你受到伤害后。",
	
	["kechengbashi"] = "霸世",
	[":kechengbashi"] = "主公技，<font color='green'><b>每个回合限三次，</s></font>其他吴势力角色可以代替你打出【杀】或【闪】。",
	["keshengbashiusejink"] = "霸世：其他吴势力角色替你打出【闪】",
	["keshengbashiuseslash"] = "霸世：其他吴势力角色替你打出【杀】",
	["kechengbashijink-ask"] = "霸世：你可以替其打出【闪】",
	["kechengbashislash-ask"] = "霸世：你可以替其打出【杀】",

	
	["$usekechengbashi"] = "%from 发动了技能<font color='yellow'><b>“霸世”</s></font>",

	["$kechengduxing1"] = "沙场破敌，于我易如反掌！",
	["$kechengduxing2"] = "逢对手，遇良将，快哉快哉！",
	["$kechengzhiheng1"] = "天下之大，我可尽情驰骋！",
	["$kechengzhiheng2"] = "诸位，今日必让天下知我江东男儿勇武！",
	["$kechengzhasi1"] = "承父勇烈，雄踞江东！",
	["$kechengzhasi2"] = "须当谨记，江东英烈之功。",
	["$kechengbashi1"] = "酣阵强敌，正在此时！",
	["$kechengbashi2"] = "将军要与我切磋武艺？有趣！",

	["~kechengsunce"] = "仲谋，孙家基业就要靠你了，呃。",


	["kechengchendeng"] = "陈登-承", 
	["&kechengchendeng"] = "陈登",
	["#kechengchendeng"] = "惊涛弄潮",
	["designer:kechengchendeng"] = "官方",
	["cv:kechengchendeng"] = "官方",
	["illustrator:kechengchendeng"] = "鬼画府，极乐",

	["kechenglunshi"] = "论势",
	[":kechenglunshi"] = "出牌阶段限一次，你可以令一名角色摸X张牌（X为其攻击范围内包含的角色数且至多摸至五张），然后其弃置Y张牌（Y为攻击范围内含有其的角色数）。",

	["kechengguitu"] = "诡图",
	[":kechengguitu"] = "<font color='green'><b>准备阶段，</s></font>你可以交换两名角色装备区的武器牌，然后攻击范围因此减少的角色回复1点体力。",
	
	["kechenglunshi-discard"] = "请选择弃置的牌",
	["kechengguitu-ask"] = "你可以发动“诡图”交换场上的两张武器牌",
	
	

	["$kechenglunshi1"] = "急施援手，救人于危难。",
	["$kechenglunshi2"] = "雪中送炭，扶人于困顿。",
	["$kechengguitu1"] = "动之以情，不若胁之以危。",
	["$kechengguitu2"] = "晓之以理，不如诱之以利。",


	["~kechengchendeng"] = "华元化不在，吾命休矣。",


--关羽
	["kechengguanyu"] = "关羽-承", 
	["&kechengguanyu"] = "关羽",
	["#kechengguanyu"] = "羊左之义",
	["designer:kechengguanyu"] = "官方",
	["cv:kechengguanyu"] = "官方",
	["illustrator:kechengguanyu"] = "鬼画府，极乐",

	["kechengguanjue"] = "冠绝",
	[":kechengguanjue"] = "锁定技，其他角色不能使用或打出与你当前回合使用或打出过的牌花色相同的牌。",

	["kechengnianen"] = "念恩",
	[":kechengnianen"] = "你可以将一张牌当任意基本牌使用或打出，若以此法使用或打出的牌不是红色普通【杀】，本回合你获得“马术”且“念恩”失效。",
	["kechengnianen_slash"] = "念恩",
	["kechengnianen_saveself"] = "念恩",
	["bannianen"] = "禁用念恩",
	

	["$kechengnianen1"] = "手握青龙，跨骑赤兔！",
	["$kechengnianen2"] = "过关斩将，谁能拦我？",


	["~kechengguanyu"] = "马上就能见到大哥了。",


--许贡
	["kechengxugong"] = "许贡-承", 
	["&kechengxugong"] = "许贡",
	["#kechengxugong"] = "独计击流",
	["designer:kechengxugong"] = "官方",
	["cv:kechengxugong"] = "官方",
	["illustrator:kechengxugong"] = "君桓文化",

	["kechengbiaozhao"] = "表召",
	[":kechengbiaozhao"] = "<font color='green'><b>准备阶段，</s></font>你可以依次选择两名角色，直到你下个回合开始时或当你死亡时，第一名角色对第二名角色使用牌无距离和次数限制，且第二名角色使用牌对你造成的伤害+1。",

	["kechengyechou"] = "业仇",
	[":kechengyechou"] = "<font color='green'><b>当你死亡时，</s></font>你可以令一名其他角色本局游戏受到的致命伤害×2。",
	["kechengyechouex"] = "业仇",

	["kechengyechou-ask"] = "你可以选择发动“业仇”的角色",
	["kechengbiaozhao-ask"] = "你可以选择发动“表召”的角色",
	["kechengbiaozhaofrom"] = "表召一",
	["kechengbiaozhaoto"] = "表召二",

	["$kechengbiaozhao1"] = "此密诏，望得丞相重视。",
	["$kechengbiaozhao2"] = "孙策枭雄，若放于外，必作事患。",
	["$kechengyechou1"] = "你的命数也快到尽头了！",
	["$kechengyechou2"] = "今日之仇来日必报！",

	["~kechengxugong"] = "吾身之死，愿得丞相之醒。",


	--吕布
	["kechenglvbu"] = "吕布-承", 
	["&kechenglvbu"] = "吕布",
	["#kechenglvbu"] = "虎视中原",
	["designer:kechenglvbu"] = "官方",
	["cv:kechenglvbu"] = "官方",
	["illustrator:kechenglvbu"] = "鬼画府，极乐",

	["kechengwuchang"] = "无常",
	[":kechengwuchang"] = "锁定技，当你获得其他角色的牌后，你变更势力至与其相同；你使用【杀】或【决斗】对相同势力的角色造成伤害时，你变更势力至“群”且此伤害+1。",
	["$kechengwuchangchange"] = "%from 变更势力至与 %to 相同！",

	["kechengqingjiao"] = "轻狡",
	[":kechengqingjiao"] = "群势力技，<font color='green'><b>出牌阶段各限一次，</s></font>你可以将一张牌当【推心置腹】/【趁火打劫】对一名手牌数大于/小于你的角色使用。",
	["useqingjiaotxzf"] = "轻狡：推心置腹",
	["useqingjiaochdj"] = "轻狡：趁火打劫",

	["kechengchengxu"] = "乘虚",
	[":kechengchengxu"] = "蜀势力技，锁定技，与你势力相同的其他角色不能响应你使用的牌。",

	["$kechengwuchang1"] = "我，才是举世无双之人。",
	["$kechengwuchang2"] = "无双的力量，无人撼动！",
	["$kechengqingjiao1"] = "权利与财富，我都要拿走！",
	["$kechengqingjiao2"] = "唯有利益才能驱使我。",

	["~kechenglvbu"] = "来日再战，要你有去无回！",


	--许攸
	["kechengxuyou"] = "许攸-承", 
	["&kechengxuyou"] = "许攸",
	["#kechengxuyou"] = "毕方矫翼",
	["designer:kechengxuyou"] = "官方",
	["cv:kechengxuyou"] = "官方",
	["illustrator:kechengxuyou"] = "鬼画府，极乐",

	["kechenglipan"] = "离叛",
	[":kechenglipan"] = "<font color='green'><b>回合结束时，</s></font>你可以变更势力并摸X张牌（X为与你势力相同的其他角色数），然后你执行一个额外的出牌阶段，此阶段结束时，与你势力相同的其他角色可以各将一张牌当【决斗】对你使用。",
	["$kechenglipanqun"] = "%from 选择了<font color='yellow'><b> “群” </s></font>势力",
	["$kechenglipanwei"] = "%from 选择了<font color='yellow'><b> “魏” </s></font>势力",

	["kechengqingxi"] = "轻袭",
	["kechengqingxiCard"] = "轻袭",
	[":kechengqingxi"] = "群势力技，<font color='green'><b>出牌阶段每名角色限一次，</s></font>你可以将手牌弃置至与一名手牌数小于你的角色相同，然后你视为对其使用一张刺【杀】。",

	["lipanuseduel"] = "离叛：你可以将一张牌当【决斗】对其使用",
	["kechengqingxi-discard"] = "请选择弃置的牌",

	["kechengjinmie"] = "烬灭",
	[":kechengjinmie"] = "魏势力技，出牌阶段限一次，你可以视为对一名手牌数大于你的角色使用一张火【杀】，此牌对该角色造成伤害后，你弃置其手牌至与你相同。",
	["$kechengqingxiCardcisha"] = "%from 对 %to 使用了刺【杀】！",

	["$kechenglipan1"] = "兵戈伐谋之事，乃某之所长也。",
	["$kechenglipan2"] = "攸之大才事于袁绍，言不听计不从。",
	["$kechengqingxi1"] = "此非为一时之利，乃千秋万载之功！",
	["$kechengqingxi2"] = "汝等皆匹夫尔，何足道哉？",
	["$kechengjinmie1"] = "大略如此，明公速行勿疑。",
	["$kechengjinmie2"] = "若取乌巢焚其粮，袁贼还可坚守几许？",

	["~kechengxuyou"] = "兔死狗烹，天不怜我！",


	--张郃
	["kechengzhanghe"] = "张郃-承", 
	["&kechengzhanghe"] = "张郃",
	["#kechengzhanghe"] = "微子去殷",
	["designer:kechengzhanghe"] = "官方",
	["cv:kechengzhanghe"] = "官方",
	["illustrator:kechengzhanghe"] = "君桓文化，极乐",

	["kechengqongtu"] = "穷途",
	[":kechengqongtu"] = "群势力技，每个回合限一次，你可以将一张非基本牌置于武将牌上视为使用一张【无懈可击】，若此牌生效，你摸一张牌，否则你变更势力至“魏”并获得武将牌上的所有牌。",

	["kechengxianzhu"] = "先著",
	["kechengxianzhuslash"] = "先著",
	[":kechengxianzhu"] = "魏势力技，你可以将一张普通锦囊牌当【杀】使用（无次数限制），当此【杀】对唯一目标角色造成伤害后，你对其执行该锦囊牌的效果。",

	["$kechengqongtu1"] = "时以进而取之，无则磨锋以待。",
	["$kechengqongtu2"] = "知敌之薄弱，略我之计谋。",
	["$kechengxianzhu1"] = "天易之理可胜，知略更甚以往。",


	["~kechengzhanghe"] = "吾筹划而思，奈何还是慢了一步。",


	--张辽
	["kechengzhangliao"] = "张辽-承", 
	["&kechengzhangliao"] = "张辽",
	["#kechengzhangliao"] = "利刃风骑",
	["designer:kechengzhangliao"] = "官方",
	["cv:kechengzhangliao"] = "官方",
	["illustrator:kechengzhangliao"] = "君桓文化，极乐",

	["kechengzhengbing"] = "整兵",
	[":kechengzhengbing"] = "群势力技，<font color='green'><b>出牌阶段限三次，</s></font>你可以重铸一张牌，然后若此牌为：【杀】，你本回合手牌上限+2；【闪】，你摸一张牌；【桃】，你变更势力至“魏”。",
	["kechengzhengbingsp"] = "整兵手牌上限",
	["$kechengzhengbingcz"] = "%arg2 重铸了【%arg】",
	
	["kechengtuwei"] = "突围",
	["kechengtuwei-ask"] = "你可以选择发动“突围”的目标",
	[":kechengtuwei"] = "魏势力技，<font color='green'><b>出牌阶段开始时，</s></font>你可以获得攻击范围内任意名角色的各一张牌，若如此做，此回合结束时，其中本回合没有受到过伤害的角色各获得你的一张牌。",

	["$kechengzhengbing1"] = "调令一出，差者无弗远近！",
	["$kechengzhengbing2"] = "调令在此，尔等皆随差遣！",
	["$kechengtuwei1"] = "传檄募兵，呼无不应！",
	["$kechengtuwei2"] = "凡入伍者，皆干赏蹈利！",


	["~kechengzhangliao"] = "奈何病重，无力再战。",



	--邹氏
	["kechengzoushi"] = "邹氏-承", 
	["&kechengzoushi"] = "邹氏",
	["#kechengzoushi"] = "淯水香魂",
	["designer:kechengzoushi"] = "官方",
	["cv:kechengzoushi"] = "官方",
	["illustrator:kechengzoushi"] = "君桓文化，极乐",

	["kechengguyin"] = "孤吟",
	[":kechengguyin"] = "<font color='green'><b>准备阶段，</s></font>你可以翻面并令其他男性角色依次选择是否翻面，然后你和其他所有翻面的角色轮流摸一张牌直到以此法的摸牌数达到X（X为游戏开始时的男性角色数）。",

	["kechengzhangdeng"] = "帐灯",
	[":kechengzhangdeng"] = "若你的武将牌背面向上，一名武将牌背面向上的角色可以视为使用【酒】，当“帐灯”于一个回合内第二次发动时，你翻至正面向上。",

	["kechengzhangdengex"] = "帐灯酒",
	[":kechengzhangdengex"] = "若邹氏的武将牌背面向上，你可以视为使用【酒】；当“帐灯”于一个回合内第二次发动时，邹氏翻至正面向上。",

	["kechengguyinmale"] = "初始男性数",
	["kechengguyinturnover"] = "孤吟：将武将牌翻面",

	["$kechengguyin1"] = "佳人倾城又倾国，何怨幽王戏诸侯？",
	["$kechengguyin2"] = "武夫以力破阵，佳人凭貌倾城。",
	["$kechengzhangdeng1"] = "三千青丝化弱水，含泪明眸溺英雄。",
	["$kechengzhangdeng2"] = "温柔乡里忘归路，香唇软语最噬人。",

	["~kechengzoushi"] = "生逢乱世，身何由己？",


	--淳于琼
	["kechengchunyuqiong"] = "淳于琼-承", 
	["&kechengchunyuqiong"] = "淳于琼",
	["#kechengchunyuqiong"] = "乌巢酒仙",
	["designer:kechengchunyuqiong"] = "官方",
	["cv:kechengchunyuqiong"] = "官方",
	["illustrator:kechengchunyuqiong"] = "君桓文化",

	["kechengcangchu"] = "仓储",
	[":kechengcangchu"] = "一名角色的<font color='green'><b>结束阶段，</s></font>你可以令至多X名角色各摸一张牌（X为你当前回合获得的牌数），若X大于存活角色数，改为两张。",

	["$usekechengcangchu"] = "%from 发动了<font color='yellow'><b> “仓储” </s></font>",

	["kechengshishou"] = "失守",
	[":kechengshishou"] = "锁定技，你使用【酒】时摸三张牌，然后你当前回合不能使用牌；当你受到火焰伤害后，“仓储”失效直到你的回合结束。",

	["kechengcangchu-ask"] = "你可以选择发动“仓储”摸牌的角色",
	["kechengcangchushixiao"] = "仓储失效",

	["$kechengcangchu1"] = "广积粮草，有备无患。",
	["$kechengcangchu2"] = "吾奉命于此建仓储粮。",
	["$kechengshishou1"] = "腹痛骤发，痛不可当！",
	["$kechengshishou2"] = "火光冲天，悔不当初！",

	["~kechengchunyuqiong"] = "这酒饮不得啊！",

	--甄宓
	["kechengzhenfu"] = "甄宓-承", 
	["&kechengzhenfu"] = "甄宓",
	["#kechengzhenfu"] = "一顾倾国",
	["designer:kechengzhenfu"] = "官方",
	["cv:kechengzhenfu"] = "离瞳鸭",
	["illustrator:kechengzhenfu"] = "君桓文化",

	["kechengjixiang"] = "济乡",
	["kechengjixiangex"] = "济乡",
	[":kechengjixiang"] = "你的回合内每种牌名限一次，当一名其他角色需要使用或打出一张基本牌时，你可以弃置一张牌令其视为使用或打出之，然后你摸一张牌且本回合“称贤”的次数限制+1。",

	["kechengchengxian"] = "称贤",
	[":kechengchengxian"] = "<font color='green'><b>出牌阶段限两次，</s></font>你可以将一张手牌当做本回合未以此法使用过且与此牌的合法目标数相同的普通锦囊牌使用。",

	["kechengjixiangtao"] = "济乡：你可以弃置一张牌令 %src 视为使用【桃】",
	["kechengjixiangjiu"] = "济乡：你可以弃置一张牌令 %src 视为使用【酒】",
	["kechengjixiangshan"] = "济乡：你可以弃置一张牌令 %src 视为使用/打出【闪】",
	["kechengjixiangsha"] = "济乡：你可以弃置一张牌令 %src 视为使用/打出【杀】",
	["kechengchengxian-ask"] = "请选择此【%src】的目标 -> 点击确定",


--CV：离瞳鸭
	["$kechengjixiang1"] = "珠玉不足贵，德行传家久。",
	["$kechengjixiang2"] = "人情一日不食则饥，愿母亲慎思之。",
	["$kechengchengxian1"] = "所愿广求淑媛，以丰继嗣。",
	["$kechengchengxian2"] = "贤妻夫祸少，夫宽妻多福。",

	["~kechengzhenfu"] = "乱世人如苇，随波雨打浮……",


	--袁谭&袁尚
	["kechengeryuan"] = "袁谭＆袁尚-承", 
	["&kechengeryuan"] = "袁谭＆袁尚",
	["#kechengeryuan"] = "操戈同室",
	["designer:kechengeryuan"] = "官方",
	["cv:kechengeryuan"] = "官方",
	["illustrator:kechengeryuan"] = "李秀森",

	["kechengneifa"] = "内伐",
	["kechengneifa-discard"] = "内伐：请弃置一张牌",
	["kechengneifaNotBasic"] = "内伐非基本牌",
	["kechengneifaBasic"] = "内伐基本牌",
	["kechengneifa-ask"] = "内伐：你可以移除一个目标",
	[":kechengneifa"] = "<font color='green'><b>出牌阶段开始时，</s></font>你可以摸两张牌，然后弃置一张牌并令你本回合手牌对其他角色可见，若弃置的牌：是基本牌，本回合你不能使用非基本牌且你可以多使用X张【杀】，你使用【杀】的目标数限制+1；不是基本牌，本回合你不能使用基本牌，你使用普通锦囊牌的目标数限制+1，且使用普通锦囊牌指定目标时可以移除一个目标，且你首次使用装备牌时摸X张牌（X为你手牌中仅因“内伐”不能使用的牌数且至少为1至多为5）。",

	["$kechengneifa1"] = "同室内伐，贻笑外人。",
	["$kechengneifa2"] = "自相恩残，相煎何急？",

	["~kechengeryuan"] = "兄弟难齐心，该有此果。",
	

--陶谦
	["kechengtaoqian"] = "陶谦-承", 
	["&kechengtaoqian"] = "陶谦",
	["#kechengtaoqian"] = "膺秉温仁",
	["designer:kechengtaoqian"] = "官方",
	["cv:kechengtaoqian"] = "官方",
	["illustrator:kechengtaoqian"] = "福州明暗",

	["kechengyirang"] = "揖让",
	[":kechengyirang"] = "<font color='green'><b>出牌阶段开始时，</s></font>你可以展示所有牌并将其中的非基本牌交给一名其他角色，然后你增加体力上限至与其相同并回复X点体力（X为你以此法交给其的牌数）。",

	["~kechengtaoqian"] = "悔不该差使小人，遭此祸患。",

	--麴义
	["kechengquyi"] = "麴义-承", 
	["&kechengquyi"] = "麴义",
	["#kechengquyi"] = "名门的骁将",
	["designer:kechengquyi"] = "官方",
	["cv:kechengquyi"] = "官方",
	["illustrator:kechengquyi"] = "秋呆呆",

	["~kechengquyi"] = "为主公戎马一生，主公为何如此对我！",

	--曹嵩
	["kechengcaosong"] = "曹嵩-承", 
	["&kechengcaosong"] = "曹嵩",
	["#kechengcaosong"] = "依权弼子",
	["designer:kechengcaosong"] = "官方",
	["cv:kechengcaosong"] = "官方",
	["illustrator:kechengcaosong"] = "凝聚永恒",

	["~kechengcaosong"] = "孟德，勿忘汝父之仇！",

	--高览
	["kechenggaolan"] = "高览-承", 
	["&kechenggaolan"] = "高览",
	["#kechenggaolan"] = "绝击坚营",
	["designer:kechenggaolan"] = "官方",
	["cv:kechenggaolan"] = "官方",
	["illustrator:kechenggaolan"] = "兴游",

	["~kechenggaolan"] = "满腹忠肝，难抵一句谮言，唉！",

--严夫人
	["kechengyanfuren"] = "严夫人-承", 
	["&kechengyanfuren"] = "严夫人",
	["#kechengyanfuren"] = "霜天薄裳",
	["designer:kechengyanfuren"] = "官方",
	["cv:kechengyanfuren"] = "官方",
	["illustrator:kechengyanfuren"] = "君桓文化",

	["~kechengyanfuren"] = "妾身，绝不会害将军呀！",










}
return {extension}

