--==《谋攻篇》==--
extension = sgs.Package("mougong", sgs.Package_GeneralPack)
--extension_c = sgs.Package("mougongCards", sgs.Package_CardPack)
--谋黄忠-七天体验卡
mou_huangzhongg = sgs.General(extension, "mou_huangzhongg", "shu", 4, true)

mouliegongg_nolimit = sgs.CreateTargetModSkill {
	name = "mouliegongg_nolimit",
	frequency = sgs.Skill_NotCompulsory,
	distance_limit_func = function(self, player, card)
		if player:hasSkill("mouliegongg") and card:isKindOf("Slash") then
			local n = card:getNumber()
			return n - 1
		else
			return 0
		end
	end,
}
mouliegongg_record = sgs.CreateTriggerSkill {
	name = "mouliegongg_record",
	global = true,
	priority = { 4, 4, 4 },
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardUsed, sgs.SlashMissed, sgs.TargetConfirmed },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("SkillCard") then return false end
			if use.from:hasSkill("mouliegongg") then
				local suit = use.card:getSuit()
				if suit == sgs.Card_Heart and player:getMark("&mouliegongg+heart") == 0 then
					room:addPlayerMark(player, "&mouliegongg+heart")
				elseif suit == sgs.Card_Diamond and player:getMark("&mouliegongg+diamond") == 0 then
					room:addPlayerMark(player, "&mouliegongg+diamond")
				elseif suit == sgs.Card_Club and player:getMark("&mouliegongg+club") == 0 then
					room:addPlayerMark(player, "&mouliegongg+club")
				elseif suit == sgs.Card_Spade and player:getMark("&mouliegongg+spade") == 0 then
					room:addPlayerMark(player, "&mouliegongg+spade")
				end
			end
		elseif event == sgs.SlashMissed then --使用【闪】也可以记录
			local effect = data:toSlashEffect()
			if effect.to:isAlive() and effect.to:hasSkill("mouliegongg") then
				local suit = effect.jink:getSuit()
				if suit == sgs.Card_Heart and effect.to:getMark("&mouliegongg+heart") == 0 then
					room:addPlayerMark(effect.to, "&mouliegongg+heart")
				elseif suit == sgs.Card_Diamond and effect.to:getMark("&mouliegongg+diamond") == 0 then
					room:addPlayerMark(effect.to, "&mouliegongg+diamond")
				elseif suit == sgs.Card_Club and effect.to:getMark("&mouliegongg+club") == 0 then
					room:addPlayerMark(effect.to, "&mouliegongg+club")
				elseif suit == sgs.Card_Spade and effect.to:getMark("&mouliegongg+spade") == 0 then
					room:addPlayerMark(effect.to, "&mouliegongg+spade")
				end
			end
		elseif event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if use.card:isKindOf("SkillCard") then return false end
			for _, mhz in sgs.qlist(use.to) do
				if mhz:hasSkill("mouliegongg") then
					local suit = use.card:getSuit()
					if suit == sgs.Card_Heart and mhz:getMark("&mouliegongg+heart") == 0 then
						room:addPlayerMark(mhz, "&mouliegongg+heart")
					elseif suit == sgs.Card_Diamond and mhz:getMark("&mouliegongg+diamond") == 0 then
						room:addPlayerMark(mhz, "&mouliegongg+diamond")
					elseif suit == sgs.Card_Club and mhz:getMark("&mouliegongg+club") == 0 then
						room:addPlayerMark(mhz, "&mouliegongg+club")
					elseif suit == sgs.Card_Spade and mhz:getMark("&mouliegongg+spade") == 0 then
						room:addPlayerMark(mhz, "&mouliegongg+spade")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mouliegongg = sgs.CreateTriggerSkill {
	name = "mouliegongg",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.TargetConfirmed, sgs.ConfirmDamage, sgs.Dying, sgs.CardFinished },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if not use.from or not use.from:hasSkill(self:objectName()) or player:objectName() ~= use.from:objectName() or use.to:length() ~= 1 or not use.card:isKindOf("Slash") then return false end
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName())
				local x = -1
				if player:getMark("&mouliegongg+heart") > 0 then x = x + 1 end
				if player:getMark("&mouliegongg+diamond") > 0 then x = x + 1 end
				if player:getMark("&mouliegongg+club") > 0 then x = x + 1 end
				if player:getMark("&mouliegongg+spade") > 0 then x = x + 1 end
				if x >= 1 then
					local card_ids = room:getNCards(x)
					room:fillAG(card_ids)
					for _, c in sgs.qlist(card_ids) do
						local card = sgs.Sanguosha:getCard(c)
						if card:getSuit() == sgs.Card_Heart and player:getMark("&mouliegongg+heart") > 0 then
							room:addPlayerMark(player, "mouliegongg_MoreDamage")
						end
						if card:getSuit() == sgs.Card_Diamond and player:getMark("&mouliegongg+diamond") > 0 then
							room:addPlayerMark(player, "mouliegongg_MoreDamage")
						end
						if card:getSuit() == sgs.Card_Club and player:getMark("&mouliegongg+club") > 0 then
							room:addPlayerMark(player, "mouliegongg_MoreDamage")
						end
						if card:getSuit() == sgs.Card_Spade and player:getMark("&mouliegongg+spade") > 0 then
							room:addPlayerMark(player, "mouliegongg_MoreDamage")
						end
					end
				end
				if player:getMark("mouliegongg_MoreDamage") >= 3 then
					room:doLightbox("mou_huangzhonggAnimate") --阳光老男孩！
				end
				for _, p in sgs.qlist(use.to) do
					if player:getMark("&mouliegongg+heart") > 0 then
						room:setPlayerCardLimitation(p, "use,response", ".|heart|.|.", false)
					end
					if player:getMark("&mouliegongg+diamond") > 0 then
						room:setPlayerCardLimitation(p, "use,response", ".|diamond|.|.", false)
					end
					if player:getMark("&mouliegongg+club") > 0 then
						room:setPlayerCardLimitation(p, "use,response", ".|club|.|.", false)
					end
					if player:getMark("&mouliegongg+spade") > 0 then
						room:setPlayerCardLimitation(p, "use,response", ".|spade|.|.", false)
					end
					if not player:hasFlag("mouliegonggSource") then
						room:setPlayerFlag(player, "mouliegonggSource")
					end
					if not p:hasFlag("mouliegonggTarget") then
						room:setPlayerFlag(p, "mouliegonggTarget")
					end
				end
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			local xhy = damage.damage
			local n = player:getMark("mouliegongg_MoreDamage")
			if damage.to:hasFlag("mouliegonggTarget") and damage.card:isKindOf("Slash") then
				if player:objectName() == damage.from:objectName() and player:getMark("mouliegongg_MoreDamage") > 0 then
					local log = sgs.LogMessage()
					log.type = "$mouliegonggBUFF"
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
			if player:hasFlag("mouliegonggSource") then
				room:removePlayerMark(player, "mouliegongg_MoreDamage", n)
				room:setPlayerFlag(damage.to, "-mouliegonggTarget")
			end
		elseif event == sgs.Dying then
			local dying = data:toDying()
			if player:objectName() == dying.who:objectName() and player:hasFlag("mouliegonggTarget") then --如果该角色是因为受到伤害而进入濒死，那么不会有此标志
				room:removePlayerCardLimitation(player, "use,response", ".|heart|.|.")
				room:removePlayerCardLimitation(player, "use,response", ".|diamond|.|.")
				room:removePlayerCardLimitation(player, "use,response", ".|club|.|.")
				room:removePlayerCardLimitation(player, "use,response", ".|spade|.|.")
				room:setPlayerFlag(player, "-mouliegonggTarget")
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if player:hasFlag("mouliegonggSource") and use.card:isKindOf("Slash") then
				room:clearAG()
				if player:getMark("&mouliegongg+heart") > 0 then
					room:removePlayerMark(player, "&mouliegongg+heart")
				end
				if player:getMark("&mouliegongg+diamond") > 0 then
					room:removePlayerMark(player, "&mouliegongg+diamond")
				end
				if player:getMark("&mouliegongg+club") > 0 then
					room:removePlayerMark(player, "&mouliegongg+club")
				end
				if player:getMark("&mouliegongg+spade") > 0 then
					room:removePlayerMark(player, "&mouliegongg+spade")
				end
				room:setPlayerFlag(player, "-mouliegonggSource")
				local n = player:getMark("mouliegongg_MoreDamage") --确保清除增伤标记
				if n > 0 then
					room:removePlayerMark(player, "mouliegongg_MoreDamage", n)
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
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("mouliegongg_nolimit") then skills:append(mouliegongg_nolimit) end
if not sgs.Sanguosha:getSkill("mouliegongg_record") then skills:append(mouliegongg_record) end
mou_huangzhongg:addSkill(mouliegongg)

--谋黄忠-正式版
mou_huangzhong_formal = sgs.General(extension, "mou_huangzhong_formal", "shu", 4, true)

--削弱点：不再无视距离，没有装武器不能使用属性杀配合铁索连环爆破
--[[mouliegongf_limit = sgs.CreateFilterSkill{
	name = "#mouliegongf_limit",
	view_filter = function(self, to_select)
		local room = sgs.Sanguosha:currentRoom()
		if sgs.Self:getWeapon() ~= nil then return false end
		local place = room:getCardPlace(to_select:getEffectiveId())
		return to_select:isKindOf("Slash")
	end,
	view_as = function(self, originalCard)
		local slash = sgs.Sanguosha:cloneCard("slash", originalCard:getSuit(), originalCard:getNumber())
		slash:setSkillName("mouliegongf_limit")
		local card = sgs.Sanguosha:getWrappedCard(originalCard:getId())
		card:takeOver(slash)
		return card
	end,
}]]
mouliegongf_limit = sgs.CreateTriggerSkill {
	name = "mouliegongf_limit",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.ChangeSlash }, --...朱雀羽扇专用时机？
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
		return player:hasSkill("mouliegongf") and not player:hasFlag("mouliegongf_RMnaturelimit")
	end,
}
mouliegongf_record = sgs.CreateTriggerSkill {
	name = "mouliegongf_record",
	global = true,
	priority = { 4, 4, 4 },
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardUsed, sgs.SlashMissed, sgs.TargetConfirmed },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("SkillCard") then return false end
			if use.from:hasSkill("mouliegongf") then
				local suit = use.card:getSuit()
				if suit == sgs.Card_Heart and player:getMark("&mouliegongf+heart") == 0 then
					room:addPlayerMark(player, "&mouliegongf+heart")
				elseif suit == sgs.Card_Diamond and player:getMark("&mouliegongf+diamond") == 0 then
					room:addPlayerMark(player, "&mouliegongf+diamond")
				elseif suit == sgs.Card_Club and player:getMark("&mouliegongf+club") == 0 then
					room:addPlayerMark(player, "&mouliegongf+club")
				elseif suit == sgs.Card_Spade and player:getMark("&mouliegongf+spade") == 0 then
					room:addPlayerMark(player, "&mouliegongf+spade")
				end
			end
		elseif event == sgs.SlashMissed then --使用【闪】也可以记录
			local effect = data:toSlashEffect()
			if effect.to:isAlive() and effect.to:hasSkill("mouliegongf") then
				local suit = effect.jink:getSuit()
				if suit == sgs.Card_Heart and effect.to:getMark("&mouliegongf+heart") == 0 then
					room:addPlayerMark(effect.to, "&mouliegongf+heart")
				elseif suit == sgs.Card_Diamond and effect.to:getMark("&mouliegongf+diamond") == 0 then
					room:addPlayerMark(effect.to, "&mouliegongf+diamond")
				elseif suit == sgs.Card_Club and effect.to:getMark("&mouliegongf+club") == 0 then
					room:addPlayerMark(effect.to, "&mouliegongf+club")
				elseif suit == sgs.Card_Spade and effect.to:getMark("&mouliegongf+spade") == 0 then
					room:addPlayerMark(effect.to, "&mouliegongf+spade")
				end
			end
		elseif event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if use.card:isKindOf("SkillCard") then return false end
			for _, mhz in sgs.qlist(use.to) do
				if mhz:hasSkill("mouliegongf") then
					local suit = use.card:getSuit()
					if suit == sgs.Card_Heart and mhz:getMark("&mouliegongf+heart") == 0 then
						room:addPlayerMark(mhz, "&mouliegongf+heart")
					elseif suit == sgs.Card_Diamond and mhz:getMark("&mouliegongf+diamond") == 0 then
						room:addPlayerMark(mhz, "&mouliegongf+diamond")
					elseif suit == sgs.Card_Club and mhz:getMark("&mouliegongf+club") == 0 then
						room:addPlayerMark(mhz, "&mouliegongf+club")
					elseif suit == sgs.Card_Spade and mhz:getMark("&mouliegongf+spade") == 0 then
						room:addPlayerMark(mhz, "&mouliegongf+spade")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mouliegongf = sgs.CreateTriggerSkill {
	name = "mouliegongf",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.TargetConfirmed, sgs.ConfirmDamage, sgs.Dying, sgs.CardFinished },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if not use.from or not use.from:hasSkill(self:objectName()) or player:objectName() ~= use.from:objectName() or (use.to:length() ~= 1 and not player:hasFlag("mouliegongf_RMtargetlimit")) or not use.card:isKindOf("Slash") then return false end
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName())
				local x = -1
				if player:getMark("&mouliegongf+heart") > 0 then x = x + 1 end
				if player:getMark("&mouliegongf+diamond") > 0 then x = x + 1 end
				if player:getMark("&mouliegongf+club") > 0 then x = x + 1 end
				if player:getMark("&mouliegongf+spade") > 0 then x = x + 1 end
				if x >= 1 then
					local card_ids = room:getNCards(x)
					room:fillAG(card_ids)
					for _, c in sgs.qlist(card_ids) do
						local card = sgs.Sanguosha:getCard(c)
						if card:getSuit() == sgs.Card_Heart and player:getMark("&mouliegongf+heart") > 0 then
							room:addPlayerMark(player, "mouliegongf_MoreDamage")
						end
						if card:getSuit() == sgs.Card_Diamond and player:getMark("&mouliegongf+diamond") > 0 then
							room:addPlayerMark(player, "mouliegongf_MoreDamage")
						end
						if card:getSuit() == sgs.Card_Club and player:getMark("&mouliegongf+club") > 0 then
							room:addPlayerMark(player, "mouliegongf_MoreDamage")
						end
						if card:getSuit() == sgs.Card_Spade and player:getMark("&mouliegongf+spade") > 0 then
							room:addPlayerMark(player, "mouliegongf_MoreDamage")
						end
					end
				end
				if player:getMark("mouliegongf_MoreDamage") >= 3 then
					room:doLightbox("mou_huangzhong_formalAnimate") --阳光老男孩！
				end
				for _, p in sgs.qlist(use.to) do
					if player:getMark("&mouliegongf+heart") > 0 then
						room:setPlayerCardLimitation(p, "use,response", ".|heart|.|.", false)
					end
					if player:getMark("&mouliegongf+diamond") > 0 then
						room:setPlayerCardLimitation(p, "use,response", ".|diamond|.|.", false)
					end
					if player:getMark("&mouliegongf+club") > 0 then
						room:setPlayerCardLimitation(p, "use,response", ".|club|.|.", false)
					end
					if player:getMark("&mouliegongf+spade") > 0 then
						room:setPlayerCardLimitation(p, "use,response", ".|spade|.|.", false)
					end
					if not player:hasFlag("mouliegongfSource") then
						room:setPlayerFlag(player, "mouliegongfSource")
					end
					if not p:hasFlag("mouliegongfTarget") then
						room:setPlayerFlag(p, "mouliegongfTarget")
					end
				end
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			local xhy = damage.damage
			local n = player:getMark("mouliegongf_MoreDamage")
			if damage.to:hasFlag("mouliegongfTarget") and damage.card:isKindOf("Slash") then
				if player:objectName() == damage.from:objectName() and player:getMark("mouliegongf_MoreDamage") > 0 then
					local log = sgs.LogMessage()
					log.type = "$mouliegongfBUFF"
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
			--[[if player:hasFlag("mouliegongfSource") then
				room:removePlayerMark(player, "mouliegongf_MoreDamage", n)
				room:setPlayerFlag(damage.to, "-mouliegongfTarget")
			end]]
		elseif event == sgs.Dying then
			local dying = data:toDying()
			if player:objectName() == dying.who:objectName() and player:hasFlag("mouliegongfTarget") then --如果该角色是因为受到伤害而进入濒死，那么不会有此标志
				room:removePlayerCardLimitation(player, "use,response", ".|heart|.|.")
				room:removePlayerCardLimitation(player, "use,response", ".|diamond|.|.")
				room:removePlayerCardLimitation(player, "use,response", ".|club|.|.")
				room:removePlayerCardLimitation(player, "use,response", ".|spade|.|.")
				room:setPlayerFlag(player, "-mouliegongfTarget")
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if player:hasFlag("mouliegongfSource") and use.card:isKindOf("Slash") then
				room:clearAG()
				if player:getMark("&mouliegongf+heart") > 0 then
					room:removePlayerMark(player, "&mouliegongf+heart")
				end
				if player:getMark("&mouliegongf+diamond") > 0 then
					room:removePlayerMark(player, "&mouliegongf+diamond")
				end
				if player:getMark("&mouliegongf+club") > 0 then
					room:removePlayerMark(player, "&mouliegongf+club")
				end
				if player:getMark("&mouliegongf+spade") > 0 then
					room:removePlayerMark(player, "&mouliegongf+spade")
				end
				room:setPlayerFlag(player, "-mouliegongfSource")
				local n = player:getMark("mouliegongf_MoreDamage") --确保清除增伤标记
				if n > 0 then
					room:removePlayerMark(player, "mouliegongf_MoreDamage", n)
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
if not sgs.Sanguosha:getSkill("mouliegongf_limit") then skills:append(mouliegongf_limit) end
if not sgs.Sanguosha:getSkill("mouliegongf_record") then skills:append(mouliegongf_record) end
mou_huangzhong_formal:addSkill(mouliegongf)

--FC谋黄忠
fc_mou_huangzhong = sgs.General(extension, "fc_mou_huangzhong", "shu", 4, true)

fcmouliegong = sgs.CreateTriggerSkill {
	name = "fcmouliegong",
	priority = { 4, 4, 4, 4, 4, 4 },
	frequency = sgs.Skill_Frequent,
	events = { sgs.GameStart, sgs.CardUsed, sgs.CardResponded, sgs.RoundStart, sgs.Death, sgs.CardFinished },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			local can_invoke = false
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getGeneralName() == "fc_mou_huangzhong" or p:getGeneral2Name() == "fc_mou_huangzhong" then
					can_invoke = true
					break
				end
			end
			if can_invoke then
				room:broadcastSkillInvoke(self:objectName(), 1)
			end
		elseif event == sgs.CardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.CardUsed then
				local use = data:toCardUse()
				card = use.card
				if card:isKindOf("Slash") then room:setPlayerFlag(player, "fromfcmouliegong") end --触发斩杀语音用
			else
				card = data:toCardResponse().m_card
			end
			if card and not card:isKindOf("SkillCard") then
				local suit = card:getSuit()
				if suit == sgs.Card_Heart then
					if player:getMark("&fcmouliegong+heart") == 0 then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:addPlayerMark(player, "&fcmouliegong+heart")
						local n = 0
						if player:getMark("&fcmouliegong+heart") > 0 then n = n + 1 end
						if player:getMark("&fcmouliegong+diamond") > 0 then n = n + 1 end
						if player:getMark("&fcmouliegong+club") > 0 then n = n + 1 end
						if player:getMark("&fcmouliegong+spade") > 0 then n = n + 1 end
						if n == 1 then room:broadcastSkillInvoke(self:objectName(), 3) end
						if n == 2 then room:broadcastSkillInvoke(self:objectName(), 4) end
						if n == 3 then room:broadcastSkillInvoke(self:objectName(), 5) end
						if n == 4 then room:broadcastSkillInvoke(self:objectName(), 6) end
					elseif player:getMark("&fcmouliegong+heart") > 0 and player:getMark("fcmouliegongheartDrawed_lun") == 0 then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:drawCards(player, 1, self:objectName())
						if player:getMark("fcmouliegongheartDrawed_lun") > 0 and player:getMark("fcmouliegongdiamondDrawed_lun") > 0
							and player:getMark("fcmouliegongclubDrawed_lun") > 0 and player:getMark("fcmouliegongspadeDrawed_lun") > 0 then
							room:broadcastSkillInvoke(self:objectName(), 2)
						end
						room:addPlayerMark(player, "fcmouliegongheartDrawed_lun")
					end
				elseif suit == sgs.Card_Diamond then
					if player:getMark("&fcmouliegong+diamond") == 0 then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:addPlayerMark(player, "&fcmouliegong+diamond")
						local n = 0
						if player:getMark("&fcmouliegong+heart") > 0 then n = n + 1 end
						if player:getMark("&fcmouliegong+diamond") > 0 then n = n + 1 end
						if player:getMark("&fcmouliegong+club") > 0 then n = n + 1 end
						if player:getMark("&fcmouliegong+spade") > 0 then n = n + 1 end
						if n == 1 then room:broadcastSkillInvoke(self:objectName(), 3) end
						if n == 2 then room:broadcastSkillInvoke(self:objectName(), 4) end
						if n == 3 then room:broadcastSkillInvoke(self:objectName(), 5) end
						if n == 4 then room:broadcastSkillInvoke(self:objectName(), 6) end
					elseif player:getMark("&fcmouliegong+diamond") > 0 and player:getMark("fcmouliegongdiamondDrawed_lun") == 0 then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:drawCards(player, 1, self:objectName())
						if player:getMark("fcmouliegongheartDrawed_lun") > 0 and player:getMark("fcmouliegongdiamondDrawed_lun") > 0
							and player:getMark("fcmouliegongclubDrawed_lun") > 0 and player:getMark("fcmouliegongspadeDrawed_lun") > 0 then
							room:broadcastSkillInvoke(self:objectName(), 2)
						end
						room:addPlayerMark(player, "fcmouliegongdiamondDrawed_lun")
					end
				elseif suit == sgs.Card_Club then
					if player:getMark("&fcmouliegong+club") == 0 then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:addPlayerMark(player, "&fcmouliegong+club")
						local n = 0
						if player:getMark("&fcmouliegong+heart") > 0 then n = n + 1 end
						if player:getMark("&fcmouliegong+diamond") > 0 then n = n + 1 end
						if player:getMark("&fcmouliegong+club") > 0 then n = n + 1 end
						if player:getMark("&fcmouliegong+spade") > 0 then n = n + 1 end
						if n == 1 then room:broadcastSkillInvoke(self:objectName(), 3) end
						if n == 2 then room:broadcastSkillInvoke(self:objectName(), 4) end
						if n == 3 then room:broadcastSkillInvoke(self:objectName(), 5) end
						if n == 4 then room:broadcastSkillInvoke(self:objectName(), 6) end
					elseif player:getMark("&fcmouliegong+club") > 0 and player:getMark("fcmouliegongclubDrawed_lun") == 0 then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:drawCards(player, 1, self:objectName())
						if player:getMark("fcmouliegongheartDrawed_lun") > 0 and player:getMark("fcmouliegongdiamondDrawed_lun") > 0
							and player:getMark("fcmouliegongclubDrawed_lun") > 0 and player:getMark("fcmouliegongspadeDrawed_lun") > 0 then
							room:broadcastSkillInvoke(self:objectName(), 2)
						end
						room:addPlayerMark(player, "fcmouliegongclubDrawed_lun")
					end
				elseif suit == sgs.Card_Spade then
					if player:getMark("&fcmouliegong+spade") == 0 then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:addPlayerMark(player, "&fcmouliegong+spade")
						local n = 0
						if player:getMark("&fcmouliegong+heart") > 0 then n = n + 1 end
						if player:getMark("&fcmouliegong+diamond") > 0 then n = n + 1 end
						if player:getMark("&fcmouliegong+club") > 0 then n = n + 1 end
						if player:getMark("&fcmouliegong+spade") > 0 then n = n + 1 end
						if n == 1 then room:broadcastSkillInvoke(self:objectName(), 3) end
						if n == 2 then room:broadcastSkillInvoke(self:objectName(), 4) end
						if n == 3 then room:broadcastSkillInvoke(self:objectName(), 5) end
						if n == 4 then room:broadcastSkillInvoke(self:objectName(), 6) end
					elseif player:getMark("&fcmouliegong+spade") > 0 and player:getMark("fcmouliegongspadeDrawed_lun") == 0 then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:drawCards(player, 1, self:objectName())
						if player:getMark("fcmouliegongheartDrawed_lun") > 0 and player:getMark("fcmouliegongdiamondDrawed_lun") > 0
							and player:getMark("fcmouliegongclubDrawed_lun") > 0 and player:getMark("fcmouliegongspadeDrawed_lun") > 0 then
							room:broadcastSkillInvoke(self:objectName(), 2)
						end
						room:addPlayerMark(player, "fcmouliegongspadeDrawed_lun")
					end
				end
			end
		elseif event == sgs.RoundStart then
			room:setPlayerMark(player, "fcmouliegongheartDrawed_lun", 0)
			room:setPlayerMark(player, "fcmouliegongdiamondDrawed_lun", 0)
			room:setPlayerMark(player, "fcmouliegongclubDrawed_lun", 0)
			room:setPlayerMark(player, "fcmouliegongspadeDrawed_lun", 0)
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then
				local killer
				if death.damage then
					killer = death.damage.from
				else
					killer = nil
				end
				local current = room:getCurrent()
				if killer and killer:hasSkill(self:objectName()) and killer:hasFlag("fromfcmouliegong") and (current:isAlive() or current:objectName() == death.who:objectName()) then
					room:broadcastSkillInvoke(self:objectName(), 10)
				end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") then
				local suit = use.card:getSuit()
				if suit == sgs.Card_Heart and player:getMark("&fcmouliegong+heart") > 0 then
					room:setPlayerMark(player, "&fcmouliegong+heart", 0)
				elseif suit == sgs.Card_Diamond and player:getMark("&fcmouliegong+diamond") > 0 then
					room:setPlayerMark(player, "&fcmouliegong+diamond", 0)
				elseif suit == sgs.Card_Club and player:getMark("&fcmouliegong+club") > 0 then
					room:setPlayerMark(player, "&fcmouliegong+club", 0)
				elseif suit == sgs.Card_Spade and player:getMark("&fcmouliegong+spade") > 0 then
					room:setPlayerMark(player, "&fcmouliegong+spade", 0)
				end
				if player:hasFlag("fromfcmouliegong") then room:setPlayerFlag(player, "-fromfcmouliegong") end
			end
		end
	end,
}
fc_mou_huangzhong:addSkill(fcmouliegong)
--根据已记录的花色数，拥有对应的效果--
--至少1种
fcmouliegong_one = sgs.CreateTargetModSkill {
	name = "fcmouliegong_one",
	frequency = sgs.Skill_NotCompulsory,
	distance_limit_func = function(self, player, card)
		if player:hasSkill("fcmouliegong") and card:isKindOf("Slash") then
			local n = 0
			if player:getMark("&fcmouliegong+heart") > 0 then n = n + 1 end
			if player:getMark("&fcmouliegong+diamond") > 0 then n = n + 1 end
			if player:getMark("&fcmouliegong+club") > 0 then n = n + 1 end
			if player:getMark("&fcmouliegong+spade") > 0 then n = n + 1 end
			if n >= 1 then
				local num = card:getNumber()
				return num - 1
			else
				return 0
			end
		else
			return 0
		end
	end,
}
--至少2种
fcmouliegong_two = sgs.CreateTriggerSkill {
	name = "fcmouliegong_two",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.TargetSpecified },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") and use.from:objectName() == player:objectName() then
			local n = 0
			if player:getMark("&fcmouliegong+heart") > 0 then n = n + 1 end
			if player:getMark("&fcmouliegong+diamond") > 0 then n = n + 1 end
			if player:getMark("&fcmouliegong+club") > 0 then n = n + 1 end
			if player:getMark("&fcmouliegong+spade") > 0 then n = n + 1 end
			if n > 0 and n < 4 then room:broadcastSkillInvoke("fcmouliegong", math.random(7, 8)) end
			if n < 2 then return false end
			room:sendCompulsoryTriggerLog(player, "fcmouliegong")
			local no_respond_list = use.no_respond_list
			for _, xhy in sgs.qlist(use.to) do
				table.insert(no_respond_list, xhy:objectName())
			end
			use.no_respond_list = no_respond_list
			data:setValue(use)
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("fcmouliegong")
	end,
}
--至少3种、四花聚顶
fcmouliegong_threemore = sgs.CreateTriggerSkill {
	name = "fcmouliegong_threemore",
	global = true,
	priority = 1,
	frequency = sgs.Skill_Frequent,
	events = { sgs.ConfirmDamage },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.card:isKindOf("Slash") and damage.from:objectName() == player:objectName() then
			local n = 0
			if player:getMark("&fcmouliegong+heart") > 0 then n = n + 1 end
			if player:getMark("&fcmouliegong+diamond") > 0 then n = n + 1 end
			if player:getMark("&fcmouliegong+club") > 0 then n = n + 1 end
			if player:getMark("&fcmouliegong+spade") > 0 then n = n + 1 end
			if n < 3 then return false end
			if n == 4 then
				local wjqs = damage.card:getNumber()
				if (wjqs == 1 and math.random() <= 0.12) or (wjqs == 2 and math.random() <= 0.16) or (wjqs == 3 and math.random() <= 0.2)
					or (wjqs == 4 and math.random() <= 0.24) or (wjqs == 5 and math.random() <= 0.28) or (wjqs == 6 and math.random() <= 0.32)
					or (wjqs == 7 and math.random() <= 0.36) or (wjqs == 8 and math.random() <= 0.4) or (wjqs == 9 and math.random() <= 0.44)
					or (wjqs == 10 and math.random() <= 0.48) or (wjqs == 11 and math.random() <= 0.52) or (wjqs == 12 and math.random() <= 0.56)
					or (wjqs == 13 and math.random() <= 0.6) then
					local log = sgs.LogMessage()
					log.type = "$fcmouliegongCriticalHit"
					log.from = player
					log.to:append(damage.to)
					room:sendLog(log)
					damage.damage = (damage.damage + 1) * 2
					data:setValue(damage)
					room:broadcastSkillInvoke("fcmouliegong", 9)
					room:setPlayerMark(player, "&fcmouliegong+heart", 0)
					room:setPlayerMark(player, "&fcmouliegong+diamond", 0)
					room:setPlayerMark(player, "&fcmouliegong+club", 0)
					room:setPlayerMark(player, "&fcmouliegong+spade", 0)
					room:loseHp(player, 1)
				else
					damage.damage = damage.damage + 1
					data:setValue(damage)
					room:broadcastSkillInvoke("fcmouliegong", math.random(7, 8))
				end
			elseif n == 3 then
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		end
	end,
	can_trigger = function(self, player)
		return player and player:hasSkill("fcmouliegong")
	end,
}
----
if not sgs.Sanguosha:getSkill("fcmouliegong_one") then skills:append(fcmouliegong_one) end
if not sgs.Sanguosha:getSkill("fcmouliegong_two") then skills:append(fcmouliegong_two) end
if not sgs.Sanguosha:getSkill("fcmouliegong_threemore") then skills:append(fcmouliegong_threemore) end

--谋刘赪
mou_liuchengg = sgs.General(extension, "mou_liuchengg", "qun", 3, false)

moulveyinggVS = sgs.CreateZeroCardViewAsSkill {
	name = "moulveyingg",
	view_as = function(self, card)
		local ghcc = sgs.Sanguosha:cloneCard("dismantlement", sgs.Card_NoSuit, 0)
		ghcc:setSkillName(self:objectName())
		return ghcc
	end,
	response_pattern = "@@moulveyingg",
}
moulveyingg = sgs.CreateTriggerSkill {
	name = "moulveyingg",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardFinished, sgs.TargetConfirming, sgs.EventPhaseEnd },
	view_as_skill = moulveyinggVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.CardFinished then
			if use.card:isKindOf("Slash") and use.from:objectName() == player:objectName() and player:getMark("&mouchui") >= 2 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				player:loseMark("&mouchui", 2)
				room:drawCards(player, 1, self:objectName())
				room:askForUseCard(player, "@@moulveyingg", "@moulveyingg_ghcc")
			end
		elseif event == sgs.TargetConfirming then
			if use.card:isKindOf("Slash") and use.from:hasSkill(self:objectName()) and use.from:getMark("moulveyinggUsed") < 2 and use.from:getPhase() == sgs.Player_Play then
				room:sendCompulsoryTriggerLog(use.from, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				use.from:gainMark("&mouchui", 1)
				room:addPlayerMark(use.from, "moulveyinggUsed")
			end
		elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Play then
			room:setPlayerMark(player, "moulveyinggUsed", 0)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_liuchengg:addSkill(moulveyingg)

mouyingwuuCard = sgs.CreateSkillCard {
	name = "mouyingwuuCard",
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return sgs.Self:canSlash(to_select, nil)
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("mouyingwuu")
		local use = sgs.CardUseStruct()
		use.card = slash
		use.from = source
		for _, p in pairs(targets) do
			use.to:append(p)
		end
		room:useCard(use)
	end,
}
mouyingwuuVS = sgs.CreateZeroCardViewAsSkill {
	name = "mouyingwuu",
	view_as = function()
		return mouyingwuuCard:clone()
	end,
	enabled_at_play = function()
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@mouyingwuu"
	end,
}
mouyingwuu = sgs.CreateTriggerSkill {
	name = "mouyingwuu",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardFinished, sgs.TargetConfirming, sgs.EventPhaseEnd },
	view_as_skill = mouyingwuuVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.CardFinished then
			if use.card:isNDTrick() and not use.card:isDamageCard() and not use.card:isKindOf("Fqizhengxiangsheng") and player:getMark("&mouchui") >= 2 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				player:loseMark("&mouchui", 2)
				room:drawCards(player, 1, self:objectName())
				room:askForUseCard(player, "@@mouyingwuu", "@mouyingwuu_slash")
			end
		elseif event == sgs.TargetConfirming then
			if use.card:isNDTrick() and not use.card:isDamageCard() and not use.card:isKindOf("Fqizhengxiangsheng") and use.from:hasSkill(self:objectName())
				and use.from:getMark("mouyingwuuUsed") < 2 and use.from:getPhase() == sgs.Player_Play then
				if use.from:hasSkill("moulveyingg") then
					room:sendCompulsoryTriggerLog(use.from, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					use.from:gainMark("&mouchui", 1)
					room:addPlayerMark(use.from, "mouyingwuuUsed")
				end
			end
		elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Play then
			room:setPlayerMark(player, "mouyingwuuUsed", 0)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_liuchengg:addSkill(mouyingwuu)




--

--谋华雄-初版
mou_huaxiong_nine = sgs.General(extension, "mou_huaxiong_nine", "qun", 4, true, false, false, 4, 5)

--谋华雄-魔将之泪
mou_huaxiong_GKSM = sgs.General(extension, "mou_huaxiong_GKSM", "qun", 4, true, false, false, 4, 5)

mou_huaxiong_nine:addSkill("tenyearyaowu")
mou_huaxiong_GKSM:addSkill("tenyearyaowu")

mouyangweiiCard = sgs.CreateSkillCard {
	name = "mouyangweiiCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:drawCards(source, 2, "mouyangweii")
		source:gainMark("&mouwei")
		room:addPlayerMark(source, "mouyangweiiUsed")
		room:setPlayerFlag(source, "mouyangweiiNextTurn")
	end,
}
mouyangweii = sgs.CreateZeroCardViewAsSkill {
	name = "mouyangweii",
	view_as = function()
		return mouyangweiiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("mouyangweiiUsed") == 0
	end,
}
mouyangweiiMark = sgs.CreateTriggerSkill {
	name = "mouyangweiiMark",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.GameStart, sgs.EventPhaseEnd, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill("mouyangweii") then
				--player:gainHujia(5)
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Play and player:getMark("&mouwei") > 0 then
				player:loseAllMarks("&mouwei")
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_Finish then
				if player:getMark("mouyangweiiUsed") > 0 and not player:hasFlag("mouyangweiiNextTurn") then
					room:setPlayerMark(player, "mouyangweiiUsed", 0)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_huaxiong_nine:addSkill(mouyangweii)
mou_huaxiong_GKSM:addSkill(mouyangweii)
if not sgs.Sanguosha:getSkill("mouyangweiiMark") then skills:append(mouyangweiiMark) end
--“威”标记效果：
mouyangweiiSlashMore = sgs.CreateTargetModSkill {
	name = "mouyangweiiSlashMore",
	global = true,
	frequency = sgs.Skill_NotCompulsory,
	residue_func = function(self, player, card)
		if player:getMark("&mouwei") > 0 and card:isKindOf("Slash") then
			return 1
		else
			return 0
		end
	end,
}
mouyangweiiSlashNL = sgs.CreateTargetModSkill {
	name = "mouyangweiiSlashNL",
	distance_limit_func = function(self, from, card)
		if from:getMark("&mouwei") > 0 and card:isKindOf("Slash") then
			return 1000
		else
			return 0
		end
	end,
}
mouyangweiiSlashPF = sgs.CreateTriggerSkill {
	name = "mouyangweiiSlashPF",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardUsed, sgs.CardFinished },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.CardUsed and use.from:objectName() == player:objectName() and player:getMark("&mouwei") > 0 and use.card:isKindOf("Slash") then
			player:setFlags("mouyangweiiPFfrom")
			for _, p in sgs.qlist(use.to) do
				p:setFlags("mouyangweiiPFto")
				room:addPlayerMark(p, "Armor_Nullified")
			end
		elseif event == sgs.CardFinished and use.card:isKindOf("Slash") then
			if not player:hasFlag("mouyangweiiPFfrom") then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("mouyangweiiPFto") then
					p:setFlags("-mouyangweiiPFto")
					if p:getMark("Armor_Nullified") then
						room:removePlayerMark(p, "Armor_Nullified")
					end
				end
			end
			player:setFlags("-mouyangweiiPFfrom")
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("mouyangweiiSlashMore") then skills:append(mouyangweiiSlashMore) end
if not sgs.Sanguosha:getSkill("mouyangweiiSlashNL") then skills:append(mouyangweiiSlashNL) end
if not sgs.Sanguosha:getSkill("mouyangweiiSlashPF") then skills:append(mouyangweiiSlashPF) end

mhxtiyan = sgs.CreateTriggerSkill {
	name = "mhxtiyan",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.TurnStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:addPlayerMark(player, self:objectName())
	end,
	can_trigger = function(self, player)
		return player:getMark("mhxmianfei") == 0
	end,
}
if not sgs.Sanguosha:getSkill("mhxtiyan") then skills:append(mhxtiyan) end
mhxmianfei = sgs.CreateTriggerSkill { --6月测试：从4血5护甲削为4血1护甲，9血魔神堕入凡间
	name = "mhxmianfei",
	frequency = sgs.Skill_Wake,
	events = { sgs.EventPhaseStart },
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_RoundStart or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getMark("mhxtiyan") <= 1 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName(), 1)
		room:doSuperLightbox("mou_huaxiong_GKSM", "mhxmianfeiFX")
		player:loseAllHujias()
		player:gainHujia(1)
		room:setPlayerMark(player, "mhxtiyan", 0)
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
mhxmianfeii = sgs.CreateTriggerSkill { --7月“正式”上线：通过做任务免费送，从4血1护甲削为2血4上限1护甲，直接削成下水道狗都不玩，就因为，他免费！？
	name = "mhxmianfeii",
	global = true,
	frequency = sgs.Skill_Wake,
	events = { sgs.Damaged },
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if player:getMark("mhxmianfei") == 0 or player:getMark(self:objectName()) > 0 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.to:objectName() ~= player:objectName() then return false end
		room:broadcastSkillInvoke("mhxmianfei", 2)
		room:doSuperLightbox("mou_huaxiong_GKSQJ", "mhxmianfeiSX")
		if player:getMaxHp() >= 2 then
			room:setPlayerProperty(player, "hp", sgs.QVariant(2))
		else
			room:setPlayerProperty(player, "hp", sgs.QVariant(player:getMaxHp()))
		end
		player:loseAllHujias()
		player:gainHujia(1)
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill("mhxmianfei")
	end,
}
mou_huaxiong_GKSM:addSkill(mhxmianfei)
if not sgs.Sanguosha:getSkill("mhxmianfeii") then skills:append(mhxmianfeii) end
--

--==[[协力]]==--（谋攻篇新机制）
--协力[同仇]：共计造成至少4点伤害。
XL_tongchou = sgs.CreateTriggerSkill {
	name = "XL_tongchou",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.Damage },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		--谋赵云-积著
		if player:getMark("jizhuoFrom") > 0 or player:getMark("jizhuoTo") > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("jizhuoFrom") > 0 then
					room:addPlayerMark(p, "@XL_tongchou", damage.damage)
					if p:getMark("@XL_tongchou") >= 4 then
						room:broadcastSkillInvoke("moujizhuoo", 2)
						room:addPlayerMark(p, "&XL_success") --“协力”成功
						room:setPlayerMark(p, "&XL_tongchou", 0)
						room:setPlayerMark(p, "@XL_tongchou", 0)
						for _, q in sgs.qlist(room:getOtherPlayers(p)) do
							if q:getMark("jizhuoTo") > 0 then
								local log = sgs.LogMessage()
								log.type = "$XL_success"
								log.from = p
								log.to:append(q)
								room:sendLog(log)
								room:setPlayerMark(q, "&XL_tongchou", 0)
								break
							end
						end
					end
					break
				end
			end
		end
		if player:getMark("jizhuoEXFrom") > 0 or player:getMark("jizhuoEXTo") > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("jizhuoEXFrom") > 0 then
					room:addPlayerMark(p, "@XL_tongchou", damage.damage)
					if p:getMark("@XL_tongchou") >= 4 then
						room:broadcastSkillInvoke("moujizhuooEX", 2)
						room:addPlayerMark(p, "&XL_success") --“协力”成功
						room:setPlayerMark(p, "&XL_tongchou", 0)
						room:setPlayerMark(p, "@XL_tongchou", 0)
						for _, q in sgs.qlist(room:getOtherPlayers(p)) do
							if q:getMark("jizhuoEXTo") > 0 then
								local log = sgs.LogMessage()
								log.type = "$XL_success"
								log.from = p
								log.to:append(q)
								room:sendLog(log)
								room:setPlayerMark(q, "&XL_tongchou", 0)
								break
							end
						end
					end
					break
				end
			end
		end
		--谋张飞-协击
		if player:getMark("xiejiFrom") > 0 or player:getMark("xiejiTo") > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("xiejiFrom") > 0 then
					room:addPlayerMark(p, "@XL_tongchou", damage.damage)
					if p:getMark("@XL_tongchou") >= 4 then
						room:broadcastSkillInvoke("mouxiejii", 2)
						room:addPlayerMark(p, "&XL_success") --“协力”成功
						room:setPlayerMark(p, "&XL_tongchou", 0)
						room:setPlayerMark(p, "@XL_tongchou", 0)
						for _, q in sgs.qlist(room:getOtherPlayers(p)) do
							if q:getMark("xiejiTo") > 0 then
								local log = sgs.LogMessage()
								log.type = "$XL_success"
								log.from = p
								log.to:append(q)
								room:sendLog(log)
								room:setPlayerMark(q, "&XL_tongchou", 0)
								break
							end
						end
					end
					break
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&XL_tongchou") > 0
	end,
}
if not sgs.Sanguosha:getSkill("XL_tongchou") then skills:append(XL_tongchou) end
--协力[并进]：共计摸至少八张牌。
XL_bingjin = sgs.CreateTriggerSkill {
	name = "XL_bingjin",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardsMoveOneTime },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if not move.to or move.to:objectName() ~= player:objectName() or not move.from_places:contains(sgs.Player_DrawPile) then return false end
		local can_invoke = false
		for _, id in sgs.qlist(move.card_ids) do
			if room:getCardOwner(id):objectName() == player:objectName() and room:getCardPlace(id) == sgs.Player_PlaceHand then
				can_invoke = true
				break
			end
		end
		--谋赵云-积著
		if can_invoke and player:getMark("jizhuoFrom") > 0 or player:getMark("jizhuoTo") > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("jizhuoFrom") > 0 then
					local n = 0
					for _, i in sgs.qlist(move.card_ids) do
						local card = sgs.Sanguosha:getCard(i)
						if card then
							n = n + 1
						end
					end
					room:addPlayerMark(p, "@XL_bingjin", n)
					if p:getMark("@XL_bingjin") >= 8 then
						room:broadcastSkillInvoke("moujizhuoo", 2)
						room:addPlayerMark(p, "&XL_success") --“协力”成功
						room:setPlayerMark(p, "&XL_bingjin", 0)
						room:setPlayerMark(p, "@XL_bingjin", 0)
						for _, q in sgs.qlist(room:getOtherPlayers(p)) do
							if q:getMark("jizhuoTo") > 0 then
								local log = sgs.LogMessage()
								log.type = "$XL_success"
								log.from = p
								log.to:append(q)
								room:sendLog(log)
								room:setPlayerMark(q, "&XL_bingjin", 0)
								break
							end
						end
					end
					break
				end
			end
		end
		if can_invoke and player:getMark("jizhuoEXFrom") > 0 or player:getMark("jizhuoEXTo") > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("jizhuoEXFrom") > 0 then
					local n = 0
					for _, i in sgs.qlist(move.card_ids) do
						local card = sgs.Sanguosha:getCard(i)
						if card then
							n = n + 1
						end
					end
					room:addPlayerMark(p, "@XL_bingjin", n)
					if p:getMark("@XL_bingjin") >= 8 then
						room:broadcastSkillInvoke("moujizhuooEX", 2)
						room:addPlayerMark(p, "&XL_success") --“协力”成功
						room:setPlayerMark(p, "&XL_bingjin", 0)
						room:setPlayerMark(p, "@XL_bingjin", 0)
						for _, q in sgs.qlist(room:getOtherPlayers(p)) do
							if q:getMark("jizhuoEXTo") > 0 then
								local log = sgs.LogMessage()
								log.type = "$XL_success"
								log.from = p
								log.to:append(q)
								room:sendLog(log)
								room:setPlayerMark(q, "&XL_bingjin", 0)
								break
							end
						end
					end
					break
				end
			end
		end
		--谋张飞-协击
		if can_invoke and player:getMark("xiejiFrom") > 0 or player:getMark("xiejiTo") > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("xiejiFrom") > 0 then
					local n = 0
					for _, i in sgs.qlist(move.card_ids) do
						local card = sgs.Sanguosha:getCard(i)
						if card then
							n = n + 1
						end
					end
					room:addPlayerMark(p, "@XL_bingjin", n)
					if p:getMark("@XL_bingjin") >= 8 then
						room:broadcastSkillInvoke("mouxiejii", 2)
						room:addPlayerMark(p, "&XL_success") --“协力”成功
						room:setPlayerMark(p, "&XL_bingjin", 0)
						room:setPlayerMark(p, "@XL_bingjin", 0)
						for _, q in sgs.qlist(room:getOtherPlayers(p)) do
							if q:getMark("xiejiTo") > 0 then
								local log = sgs.LogMessage()
								log.type = "$XL_success"
								log.from = p
								log.to:append(q)
								room:sendLog(log)
								room:setPlayerMark(q, "&XL_bingjin", 0)
								break
							end
						end
					end
					break
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&XL_bingjin") > 0
	end,
}
if not sgs.Sanguosha:getSkill("XL_bingjin") then skills:append(XL_bingjin) end
--协力[疏财]：共计弃置四种花色的牌。
XL_shucai = sgs.CreateTriggerSkill {
	name = "XL_shucai",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardsMoveOneTime },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if not move.from or move.from:objectName() ~= player:objectName() or move.to_place ~= sgs.Player_DiscardPile then return false end
		if not (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD)  then return false end
		--谋赵云-积著
		if player:getMark("jizhuoFrom") > 0 or player:getMark("jizhuoTo") > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("jizhuoFrom") > 0 then
					for _, i in sgs.qlist(move.card_ids) do
						local card = sgs.Sanguosha:getCard(i)
						if card:getSuit() == sgs.Card_Heart and p:getMark("@XL_shucai_heart") == 0 then
							room:addPlayerMark(p, "@XL_shucai_heart")
						elseif card:getSuit() == sgs.Card_Diamond and p:getMark("@XL_shucai_diamond") == 0 then
							room:addPlayerMark(p, "@XL_shucai_diamond")
						elseif card:getSuit() == sgs.Card_Club and p:getMark("@XL_shucai_club") == 0 then
							room:addPlayerMark(p, "@XL_shucai_club")
						elseif card:getSuit() == sgs.Card_Spade and p:getMark("@XL_shucai_spade") == 0 then
							room:addPlayerMark(p, "@XL_shucai_spade")
						end
					end
					if p:getMark("@XL_shucai_heart") > 0 and p:getMark("@XL_shucai_diamond") > 0 and p:getMark("@XL_shucai_club") > 0 and p:getMark("@XL_shucai_spade") > 0 then
						room:broadcastSkillInvoke("moujizhuoo", 2)
						room:addPlayerMark(p, "&XL_success") --“协力”成功
						room:setPlayerMark(p, "&XL_shucai", 0)
						room:setPlayerMark(p, "@XL_shucai_heart", 0)
						room:setPlayerMark(p, "@XL_shucai_diamond", 0)
						room:setPlayerMark(p, "@XL_shucai_club", 0)
						room:setPlayerMark(p, "@XL_shucai_spade", 0)
						for _, q in sgs.qlist(room:getOtherPlayers(p)) do
							if q:getMark("jizhuoTo") > 0 then
								local log = sgs.LogMessage()
								log.type = "$XL_success"
								log.from = p
								log.to:append(q)
								room:sendLog(log)
								room:setPlayerMark(q, "&XL_shucai", 0)
								break
							end
						end
					end
					break
				end
			end
		end
		if player:getMark("jizhuoEXFrom") > 0 or player:getMark("jizhuoEXTo") > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("jizhuoEXFrom") > 0 then
					for _, i in sgs.qlist(move.card_ids) do
						local card = sgs.Sanguosha:getCard(i)
						if card:getSuit() == sgs.Card_Heart and p:getMark("@XL_shucai_heart") == 0 then
							room:addPlayerMark(p, "@XL_shucai_heart")
						elseif card:getSuit() == sgs.Card_Diamond and p:getMark("@XL_shucai_diamond") == 0 then
							room:addPlayerMark(p, "@XL_shucai_diamond")
						elseif card:getSuit() == sgs.Card_Club and p:getMark("@XL_shucai_club") == 0 then
							room:addPlayerMark(p, "@XL_shucai_club")
						elseif card:getSuit() == sgs.Card_Spade and p:getMark("@XL_shucai_spade") == 0 then
							room:addPlayerMark(p, "@XL_shucai_spade")
						end
					end
					if p:getMark("@XL_shucai_heart") > 0 and p:getMark("@XL_shucai_diamond") > 0 and p:getMark("@XL_shucai_club") > 0 and p:getMark("@XL_shucai_spade") > 0 then
						room:broadcastSkillInvoke("moujizhuooEX", 2)
						room:addPlayerMark(p, "&XL_success") --“协力”成功
						room:setPlayerMark(p, "&XL_shucai", 0)
						room:setPlayerMark(p, "@XL_shucai_heart", 0)
						room:setPlayerMark(p, "@XL_shucai_diamond", 0)
						room:setPlayerMark(p, "@XL_shucai_club", 0)
						room:setPlayerMark(p, "@XL_shucai_spade", 0)
						for _, q in sgs.qlist(room:getOtherPlayers(p)) do
							if q:getMark("jizhuoEXTo") > 0 then
								local log = sgs.LogMessage()
								log.type = "$XL_success"
								log.from = p
								log.to:append(q)
								room:sendLog(log)
								room:setPlayerMark(q, "&XL_shucai", 0)
								break
							end
						end
					end
					break
				end
			end
		end
		--谋张飞-协击
		if player:getMark("xiejiFrom") > 0 or player:getMark("xiejiTo") > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("xiejiFrom") > 0 then
					for _, i in sgs.qlist(move.card_ids) do
						local card = sgs.Sanguosha:getCard(i)
						if card:getSuit() == sgs.Card_Heart and p:getMark("@XL_shucai_heart") == 0 then
							room:addPlayerMark(p, "@XL_shucai_heart")
						elseif card:getSuit() == sgs.Card_Diamond and p:getMark("@XL_shucai_diamond") == 0 then
							room:addPlayerMark(p, "@XL_shucai_diamond")
						elseif card:getSuit() == sgs.Card_Club and p:getMark("@XL_shucai_club") == 0 then
							room:addPlayerMark(p, "@XL_shucai_club")
						elseif card:getSuit() == sgs.Card_Spade and p:getMark("@XL_shucai_spade") == 0 then
							room:addPlayerMark(p, "@XL_shucai_spade")
						end
					end
					if p:getMark("@XL_shucai_heart") > 0 and p:getMark("@XL_shucai_diamond") > 0 and p:getMark("@XL_shucai_club") > 0 and p:getMark("@XL_shucai_spade") > 0 then
						room:broadcastSkillInvoke("mouxiejii", 2)
						room:addPlayerMark(p, "&XL_success") --“协力”成功
						room:setPlayerMark(p, "&XL_shucai", 0)
						room:setPlayerMark(p, "@XL_shucai_heart", 0)
						room:setPlayerMark(p, "@XL_shucai_diamond", 0)
						room:setPlayerMark(p, "@XL_shucai_club", 0)
						room:setPlayerMark(p, "@XL_shucai_spade", 0)
						for _, q in sgs.qlist(room:getOtherPlayers(p)) do
							if q:getMark("xiejiTo") > 0 then
								local log = sgs.LogMessage()
								log.type = "$XL_success"
								log.from = p
								log.to:append(q)
								room:sendLog(log)
								room:setPlayerMark(q, "&XL_shucai", 0)
								break
							end
						end
					end
					break
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&XL_shucai") > 0
	end,
}
if not sgs.Sanguosha:getSkill("XL_shucai") then skills:append(XL_shucai) end
--协力[戮力]：共计使用或打出四种花色的牌。
XL_luli = sgs.CreateTriggerSkill {
	name = "XL_luli",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardUsed, sgs.CardResponded },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local card = nil
		if event == sgs.CardUsed then
			card = data:toCardUse().card
		else
			local resp = data:toCardResponse()
			if resp.m_isUse then
				card = resp.m_card
			end
		end
		if card and not card:isKindOf("SkillCard") then
			--谋赵云-积著
			if player:getMark("jizhuoFrom") > 0 or player:getMark("jizhuoTo") > 0 then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getMark("jizhuoFrom") > 0 then
						if card:getSuit() == sgs.Card_Heart and p:getMark("@XL_luli_heart") == 0 then
							room:addPlayerMark(p, "@XL_luli_heart")
						elseif card:getSuit() == sgs.Card_Diamond and p:getMark("@XL_luli_diamond") == 0 then
							room:addPlayerMark(p, "@XL_luli_diamond")
						elseif card:getSuit() == sgs.Card_Club and p:getMark("@XL_luli_club") == 0 then
							room:addPlayerMark(p, "@XL_luli_club")
						elseif card:getSuit() == sgs.Card_Spade and p:getMark("@XL_luli_spade") == 0 then
							room:addPlayerMark(p, "@XL_luli_spade")
						end
						if p:getMark("@XL_luli_heart") > 0 and p:getMark("@XL_luli_diamond") > 0 and p:getMark("@XL_luli_club") > 0 and p:getMark("@XL_luli_spade") > 0 then
							room:broadcastSkillInvoke("moujizhuoo", 2)
							room:addPlayerMark(p, "&XL_success") --“协力”成功
							room:setPlayerMark(p, "&XL_luli", 0)
							room:setPlayerMark(p, "@XL_luli_heart", 0)
							room:setPlayerMark(p, "@XL_luli_diamond", 0)
							room:setPlayerMark(p, "@XL_luli_club", 0)
							room:setPlayerMark(p, "@XL_luli_spade", 0)
							for _, q in sgs.qlist(room:getOtherPlayers(p)) do
								if q:getMark("jizhuoTo") > 0 then
									local log = sgs.LogMessage()
									log.type = "$XL_success"
									log.from = p
									log.to:append(q)
									room:sendLog(log)
									room:setPlayerMark(q, "&XL_luli", 0)
									break
								end
							end
						end
						break
					end
				end
			end
			if player:getMark("jizhuoEXFrom") > 0 or player:getMark("jizhuoEXTo") > 0 then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getMark("jizhuoEXFrom") > 0 then
						if card:getSuit() == sgs.Card_Heart and p:getMark("@XL_luli_heart") == 0 then
							room:addPlayerMark(p, "@XL_luli_heart")
						elseif card:getSuit() == sgs.Card_Diamond and p:getMark("@XL_luli_diamond") == 0 then
							room:addPlayerMark(p, "@XL_luli_diamond")
						elseif card:getSuit() == sgs.Card_Club and p:getMark("@XL_luli_club") == 0 then
							room:addPlayerMark(p, "@XL_luli_club")
						elseif card:getSuit() == sgs.Card_Spade and p:getMark("@XL_luli_spade") == 0 then
							room:addPlayerMark(p, "@XL_luli_spade")
						end
						if p:getMark("@XL_luli_heart") > 0 and p:getMark("@XL_luli_diamond") > 0 and p:getMark("@XL_luli_club") > 0 and p:getMark("@XL_luli_spade") > 0 then
							room:broadcastSkillInvoke("moujizhuooEX", 2)
							room:addPlayerMark(p, "&XL_success") --“协力”成功
							room:setPlayerMark(p, "&XL_luli", 0)
							room:setPlayerMark(p, "@XL_luli_heart", 0)
							room:setPlayerMark(p, "@XL_luli_diamond", 0)
							room:setPlayerMark(p, "@XL_luli_club", 0)
							room:setPlayerMark(p, "@XL_luli_spade", 0)
							for _, q in sgs.qlist(room:getOtherPlayers(p)) do
								if q:getMark("jizhuoEXTo") > 0 then
									local log = sgs.LogMessage()
									log.type = "$XL_success"
									log.from = p
									log.to:append(q)
									room:sendLog(log)
									room:setPlayerMark(q, "&XL_luli", 0)
									break
								end
							end
						end
						break
					end
				end
			end
			--谋张飞-协击
			if player:getMark("xiejiFrom") > 0 or player:getMark("xiejiTo") > 0 then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getMark("xiejiFrom") > 0 then
						if card:getSuit() == sgs.Card_Heart and p:getMark("@XL_luli_heart") == 0 then
							room:addPlayerMark(p, "@XL_luli_heart")
						elseif card:getSuit() == sgs.Card_Diamond and p:getMark("@XL_luli_diamond") == 0 then
							room:addPlayerMark(p, "@XL_luli_diamond")
						elseif card:getSuit() == sgs.Card_Club and p:getMark("@XL_luli_club") == 0 then
							room:addPlayerMark(p, "@XL_luli_club")
						elseif card:getSuit() == sgs.Card_Spade and p:getMark("@XL_luli_spade") == 0 then
							room:addPlayerMark(p, "@XL_luli_spade")
						end
						if p:getMark("@XL_luli_heart") > 0 and p:getMark("@XL_luli_diamond") > 0 and p:getMark("@XL_luli_club") > 0 and p:getMark("@XL_luli_spade") > 0 then
							room:broadcastSkillInvoke("mouxiejii", 2)
							room:addPlayerMark(p, "&XL_success") --“协力”成功
							room:setPlayerMark(p, "&XL_luli", 0)
							room:setPlayerMark(p, "@XL_luli_heart", 0)
							room:setPlayerMark(p, "@XL_luli_diamond", 0)
							room:setPlayerMark(p, "@XL_luli_club", 0)
							room:setPlayerMark(p, "@XL_luli_spade", 0)
							for _, q in sgs.qlist(room:getOtherPlayers(p)) do
								if q:getMark("xiejiTo") > 0 then
									local log = sgs.LogMessage()
									log.type = "$XL_success"
									log.from = p
									log.to:append(q)
									room:sendLog(log)
									room:setPlayerMark(q, "&XL_luli", 0)
									break
								end
							end
						end
						break
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&XL_luli") > 0
	end,
}
if not sgs.Sanguosha:getSkill("XL_luli") then skills:append(XL_luli) end

XL_death = sgs.CreateTriggerSkill { --处理“协力”发起者或“协力”对象中途死亡的情况
	name = "XL_death",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.Death },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		--积著
		if death.who:getMark("jizhuoFrom") > 0 or death.who:getMark("jizhuoTo") > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "jizhuoFrom", 0)
				room:setPlayerMark(p, "jizhuoTo", 0)
				room:setPlayerMark(p, "&XL_success", 0)
				room:setPlayerMark(p, "&XL_tongchou", 0)
				room:setPlayerMark(p, "@XL_tongchou", 0)
				room:setPlayerMark(p, "&XL_bingjin", 0)
				room:setPlayerMark(p, "@XL_bingjin", 0)
				room:setPlayerMark(p, "&XL_shucai", 0)
				room:setPlayerMark(p, "@XL_shucai_heart", 0)
				room:setPlayerMark(p, "@XL_shucai_diamond", 0)
				room:setPlayerMark(p, "@XL_shucai_club", 0)
				room:setPlayerMark(p, "@XL_shucai_spade", 0)
				room:setPlayerMark(p, "&XL_luli", 0)
				room:setPlayerMark(p, "@XL_luli_heart", 0)
				room:setPlayerMark(p, "@XL_luli_diamond", 0)
				room:setPlayerMark(p, "@XL_luli_club", 0)
				room:setPlayerMark(p, "@XL_luli_spade", 0)
			end
		end
		if death.who:getMark("jizhuoEXFrom") > 0 or death.who:getMark("jizhuoEXTo") > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "jizhuoEXFrom", 0)
				room:setPlayerMark(p, "jizhuoEXTo", 0)
				room:setPlayerMark(p, "&XL_success", 0)
				room:setPlayerMark(p, "&XL_tongchou", 0)
				room:setPlayerMark(p, "@XL_tongchou", 0)
				room:setPlayerMark(p, "&XL_bingjin", 0)
				room:setPlayerMark(p, "@XL_bingjin", 0)
				room:setPlayerMark(p, "&XL_shucai", 0)
				room:setPlayerMark(p, "@XL_shucai_heart", 0)
				room:setPlayerMark(p, "@XL_shucai_diamond", 0)
				room:setPlayerMark(p, "@XL_shucai_club", 0)
				room:setPlayerMark(p, "@XL_shucai_spade", 0)
				room:setPlayerMark(p, "&XL_luli", 0)
				room:setPlayerMark(p, "@XL_luli_heart", 0)
				room:setPlayerMark(p, "@XL_luli_diamond", 0)
				room:setPlayerMark(p, "@XL_luli_club", 0)
				room:setPlayerMark(p, "@XL_luli_spade", 0)
			end
		end
		--协击
		if death.who:getMark("xiejiFrom") > 0 or death.who:getMark("xiejiTo") > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "xiejiFrom", 0)
				room:setPlayerMark(p, "xiejiTo", 0)
				room:setPlayerMark(p, "&XL_success", 0)
				room:setPlayerMark(p, "&XL_tongchou", 0)
				room:setPlayerMark(p, "@XL_tongchou", 0)
				room:setPlayerMark(p, "&XL_bingjin", 0)
				room:setPlayerMark(p, "@XL_bingjin", 0)
				room:setPlayerMark(p, "&XL_shucai", 0)
				room:setPlayerMark(p, "@XL_shucai_heart", 0)
				room:setPlayerMark(p, "@XL_shucai_diamond", 0)
				room:setPlayerMark(p, "@XL_shucai_club", 0)
				room:setPlayerMark(p, "@XL_shucai_spade", 0)
				room:setPlayerMark(p, "&XL_luli", 0)
				room:setPlayerMark(p, "@XL_luli_heart", 0)
				room:setPlayerMark(p, "@XL_luli_diamond", 0)
				room:setPlayerMark(p, "@XL_luli_club", 0)
				room:setPlayerMark(p, "@XL_luli_spade", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("XL_death") then skills:append(XL_death) end
--============--



--

--谋赵云
mou_zhaoyunn = sgs.General(extension, "mou_zhaoyunn", "shu", 4, true)

moulongdann = sgs.CreateOneCardViewAsSkill {
	name = "moulongdann",
	response_or_use = true,
	view_filter = function(self, card)
		local usereason = sgs.Sanguosha:getCurrentCardUseReason()
		if usereason == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			return card:isKindOf("Jink")
		elseif usereason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or usereason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if pattern == "slash" then
				return card:isKindOf("Jink")
			else
				return card:isKindOf("Slash")
			end
		else
			return false
		end
	end,
	view_as = function(self, card)
		if card:isKindOf("Slash") then
			local jink = sgs.Sanguosha:cloneCard("jink", card:getSuit(), card:getNumber())
			jink:addSubcard(card)
			jink:setSkillName(self:objectName())
			return jink
		elseif card:isKindOf("Jink") then
			local slash = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
			slash:addSubcard(card)
			slash:setSkillName(self:objectName())
			return slash
		else
			return nil
		end
	end,
	enabled_at_play = function(self, player)
		return sgs.Slash_IsAvailable(player) and player:getMark("&moulongdannLast") > 0
	end,
	enabled_at_response = function(self, player, pattern)
		return (pattern == "slash" or pattern == "jink") and player:getMark("&moulongdannLast") > 0
	end,
}
--“龙胆”升级版
moulongdannEXCard = sgs.CreateSkillCard {
	name = "moulongdannEX",
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
			return card and card:targetFilter(plist, to_select, sgs.Self) and
				not sgs.Self:isProhibited(to_select, card, plist)
				and not (card:isKindOf("Slash") and not sgs.Self:canSlash(to_select, true, rangefix))
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return false
		end
		local card = sgs.Self:getTag("moulongdannEX"):toCard()
		return card and card:targetFilter(plist, to_select, sgs.Self) and
			not sgs.Self:isProhibited(to_select, card, plist)
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
		local card = sgs.Self:getTag("moulongdannEX"):toCard()
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
		local card = sgs.Self:getTag("moulongdannEX"):toCard()
		return card and card:targetsFeasible(plist, sgs.Self)
	end,
	on_validate = function(self, card_use)
		local player = card_use.from
		local room, to_moulongdannEX = player:getRoom(), self:getUserString()
		if self:getUserString() == "slash" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local moulongdannEX_list = {}
			table.insert(moulongdannEX_list, "slash")
			table.insert(moulongdannEX_list, "fire_slash")
			table.insert(moulongdannEX_list, "thunder_slash")
			table.insert(moulongdannEX_list, "ice_slash")
			to_moulongdannEX = room:askForChoice(player, "moulongdannEX_slash", table.concat(moulongdannEX_list, "+"))
		end
		local card = nil
		if self:subcardsLength() == 1 then card = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(self:getSubcards():first())) end
		local user_str
		if to_moulongdannEX == "slash" then
			if card and card:objectName() == "slash" then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		else
			user_str = to_moulongdannEX
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str, card and card:getSuit() or sgs.Card_SuitToBeDecided,
			card and card:getNumber() or -1)
		use_card:setSkillName("_moulongdannEX")
		use_card:addSubcards(self:getSubcards())
		use_card:deleteLater()
		return use_card
	end,
	on_validate_in_response = function(self, user)
		local room, user_str = user:getRoom(), self:getUserString()
		local to_moulongdannEX
		if user_str == "peach+analeptic" then
			local moulongdannEX_list = {}
			table.insert(moulongdannEX_list, "peach")
			table.insert(moulongdannEX_list, "analeptic")
			to_moulongdannEX = room:askForChoice(user, "moulongdannEX_saveself", table.concat(moulongdannEX_list, "+"))
		elseif user_str == "slash" then
			local moulongdannEX_list = {}
			table.insert(moulongdannEX_list, "slash")
			table.insert(moulongdannEX_list, "fire_slash")
			table.insert(moulongdannEX_list, "thunder_slash")
			table.insert(moulongdannEX_list, "ice_slash")
			to_moulongdannEX = room:askForChoice(user, "moulongdannEX_slash", table.concat(moulongdannEX_list, "+"))
		else
			to_moulongdannEX = user_str
		end
		local card = nil
		if self:subcardsLength() == 1 then card = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(self:getSubcards():first())) end
		local user_str
		if to_moulongdannEX == "slash" then
			if card and card:objectName() == "slash" then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		else
			user_str = to_moulongdannEX
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str, card and card:getSuit() or sgs.Card_SuitToBeDecided,
			card and card:getNumber() or -1)
		use_card:setSkillName("_moulongdannEX")
		use_card:addSubcards(self:getSubcards())
		use_card:deleteLater()
		return use_card
	end,
}
moulongdannEX = sgs.CreateViewAsSkill {
	name = "moulongdannEX",
	n = 1,
	response_or_use = true,
	view_filter = function(self, selected, to_select)
		return to_select:isKindOf("BasicCard")
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local skillcard = moulongdannEXCard:clone()
		skillcard:setSkillName(self:objectName())
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE
			or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			skillcard:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			for _, card in ipairs(cards) do
				skillcard:addSubcard(card)
			end
			return skillcard
		end
		local c = sgs.Self:getTag("moulongdannEX"):toCard()
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
		if player:getMark("&moulongdannLast") == 0 then return false end
		local basic = { "slash", "peach" }
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
		if player:getMark("&moulongdannLast") == 0 then return false end
		if string.startsWith(pattern, ".") or string.startsWith(pattern, "@") then return false end
		if pattern == "peach" and player:getMark("Global_PreventPeach") > 0 then return false end
		return pattern ~= "nullification" and pattern ~= "jl_wuxiesy"
	end,
}
moulongdannEX:setGuhuoDialog("l")
moulongdannTime = sgs.CreateTriggerSkill {
	name = "moulongdannTime",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.GameStart, sgs.EventPhaseChanging, sgs.CardUsed, sgs.CardResponded },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill("moulongdann") or player:hasSkill("moulongdannEX") then
				room:addPlayerMark(player, "&moulongdannLast")
				if player:hasSkill("moulongdannEX") then
					room:addPlayerMark(player, "mou_zhaoyunnEX") --将威力加强版与原版区分开
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				for _, p in sgs.qlist(room:findPlayersBySkillName("moulongdann")) do
					if p:getMark("&moulongdannLast") < 3 then
						room:addPlayerMark(p, "&moulongdannLast")
					end
				end
				for _, p in sgs.qlist(room:findPlayersBySkillName("moulongdannEX")) do
					if p:getMark("&moulongdannLast") < 4 then
						room:addPlayerMark(p, "&moulongdannLast")
					end
				end
				for _, p in sgs.qlist(room:findPlayersBySkillName("moulongdannEXEX")) do
					room:addPlayerMark(p, "&moulongdannLast")
				end
			end
		else
			local card = nil
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				local resp = data:toCardResponse()
				--if resp.m_isUse then
				card = resp.m_card
				--end
			end
			if card and (card:getSkillName() == "moulongdann" or card:getSkillName() == "moulongdannEX" or card:getSkillName() == "moulongdannEXEX") then
				room:removePlayerMark(player, "&moulongdannLast")
				room:drawCards(player, 1, "moulongdann")
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_zhaoyunn:addSkill(moulongdann)
if not sgs.Sanguosha:getSkill("moulongdannEX") then skills:append(moulongdannEX) end
if not sgs.Sanguosha:getSkill("moulongdannTime") then skills:append(moulongdannTime) end

moujizhuoo = sgs.CreateTriggerSkill {
	name = "moujizhuoo",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseProceeding },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase == sgs.Player_Start and player:hasSkill(self:objectName()) then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				local XLto = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(),
					"@XL-jizhuo")
				local choice = room:askForChoice(player, self:objectName(),
					"XL_tongchouu+XL_bingjinn+XL_shucaii+XL_lulii")
				if choice == "XL_tongchouu" then
					room:addPlayerMark(player, "&XL_tongchou")
					room:addPlayerMark(XLto, "&XL_tongchou")
				elseif choice == "XL_bingjinn" then
					room:addPlayerMark(player, "&XL_bingjin")
					room:addPlayerMark(XLto, "&XL_bingjin")
				elseif choice == "XL_shucaii" then
					room:addPlayerMark(player, "&XL_shucai")
					room:addPlayerMark(XLto, "&XL_shucai")
				elseif choice == "XL_lulii" then
					room:addPlayerMark(player, "&XL_luli")
					room:addPlayerMark(XLto, "&XL_luli")
				end
				room:addPlayerMark(player, "jizhuoFrom")
				room:addPlayerMark(XLto, "jizhuoTo")
				room:broadcastSkillInvoke(self:objectName(), 1)
			end
		elseif phase == sgs.Player_Finish and player:getMark("jizhuoTo") > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasSkill("moulongdann") and p:hasSkill(self:objectName()) and p:getMark("jizhuoFrom") > 0 and p:getMark("&XL_success") > 0 then
					room:broadcastSkillInvoke(self:objectName(), 3)
					room:detachSkillFromPlayer(p, "moulongdann", true)
					if not p:hasSkill("moulongdannEX") then
						room:attachSkillToPlayer(p, "moulongdannEX")
					end
					room:setPlayerMark(p, "&XL_success", 0)
					room:setPlayerMark(p, "&XL_success+_flag", 1)
					room:setPlayerMark(p, "jizhuoFrom", 0)
					room:setPlayerMark(player, "jizhuoTo", 0)
				elseif (p:getMark("jizhuoFrom") > 0 or p:getMark("jizhuoTo") > 0) and p:getMark("&XL_success") == 0 then
					room:setPlayerMark(p, "jizhuoFrom", 0)
					room:setPlayerMark(p, "jizhuoTo", 0)
					if p:getMark("&XL_tongchou") > 0 then
						room:setPlayerMark(p, "&XL_tongchou", 0)
						room:setPlayerMark(p, "@XL_tongchou", 0)
					elseif p:getMark("&XL_bingjin") > 0 then
						room:setPlayerMark(p, "&XL_bingjin", 0)
						room:setPlayerMark(p, "@XL_bingjin", 0)
					elseif p:getMark("&XL_shucai") > 0 then
						room:setPlayerMark(p, "&XL_shucai", 0)
						room:setPlayerMark(p, "@XL_shucai_heart", 0)
						room:setPlayerMark(p, "@XL_shucai_diamond", 0)
						room:setPlayerMark(p, "@XL_shucai_club", 0)
						room:setPlayerMark(p, "@XL_shucai_spade", 0)
					elseif p:getMark("&XL_luli") > 0 then
						room:setPlayerMark(p, "&XL_luli", 0)
						room:setPlayerMark(p, "@XL_luli_heart", 0)
						room:setPlayerMark(p, "@XL_luli_diamond", 0)
						room:setPlayerMark(p, "@XL_luli_club", 0)
						room:setPlayerMark(p, "@XL_luli_spade", 0)
					end
				end
			end
		elseif phase == sgs.Player_Finish and player:hasSkill("moulongdannEX") and player:getMark("mou_zhaoyunnEX") == 0 then
			room:detachSkillFromPlayer(player, "moulongdannEX", true)
			if not player:hasSkill("moulongdann") then
				room:attachSkillToPlayer(player, "moulongdann")
				if player:getMark("&moulongdannLast") > 3 then
					room:setPlayerMark(player, "&moulongdannLast", 3) --保证与原版“谋龙胆”中描述[至多剩余可用3次]保持一致
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_zhaoyunn:addSkill(moujizhuoo)

--谋赵云-威力加强版
mou_zhaoyunnEX = sgs.General(extension, "mou_zhaoyunnEX", "shu", 4, true)

mou_zhaoyunnEX:addSkill("moulongdannEX")

--“龙胆”升级再升级版（附加部分已整合在“moulongdannTime”中）
moulongdannEXEXCard = sgs.CreateSkillCard {
	name = "moulongdannEXEX",
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
			return card and card:targetFilter(plist, to_select, sgs.Self) and
				not sgs.Self:isProhibited(to_select, card, plist)
				and not (card:isKindOf("Slash") and not sgs.Self:canSlash(to_select, true, rangefix))
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return false
		end
		local card = sgs.Self:getTag("moulongdannEXEX"):toCard()
		return card and card:targetFilter(plist, to_select, sgs.Self) and
			not sgs.Self:isProhibited(to_select, card, plist)
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
		local card = sgs.Self:getTag("moulongdannEXEX"):toCard()
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
		local card = sgs.Self:getTag("moulongdannEXEX"):toCard()
		return card and card:targetsFeasible(plist, sgs.Self)
	end,
	on_validate = function(self, card_use)
		local player = card_use.from
		local room, to_moulongdannEXEX = player:getRoom(), self:getUserString()
		if self:getUserString() == "slash" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local moulongdannEXEX_list = {}
			table.insert(moulongdannEXEX_list, "slash")
			table.insert(moulongdannEXEX_list, "fire_slash")
			table.insert(moulongdannEXEX_list, "thunder_slash")
			table.insert(moulongdannEXEX_list, "ice_slash")
			to_moulongdannEXEX = room:askForChoice(player, "moulongdannEXEX_slash",
				table.concat(moulongdannEXEX_list, "+"))
		end
		local card = nil
		if self:subcardsLength() == 1 then card = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(self:getSubcards():first())) end
		local user_str
		if to_moulongdannEXEX == "slash" then
			if card and card:objectName() == "slash" then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		else
			user_str = to_moulongdannEXEX
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str, card and card:getSuit() or sgs.Card_SuitToBeDecided,
			card and card:getNumber() or -1)
		use_card:setSkillName("_moulongdannEXEX")
		use_card:addSubcards(self:getSubcards())
		use_card:deleteLater()
		return use_card
	end,
	on_validate_in_response = function(self, user)
		local room, user_str = user:getRoom(), self:getUserString()
		local to_moulongdannEXEX
		if user_str == "peach+analeptic" then
			local moulongdannEXEX_list = {}
			table.insert(moulongdannEXEX_list, "peach")
			table.insert(moulongdannEXEX_list, "analeptic")
			to_moulongdannEXEX = room:askForChoice(user, "moulongdannEXEX_saveself",
				table.concat(moulongdannEXEX_list, "+"))
		elseif user_str == "slash" then
			local moulongdannEXEX_list = {}
			table.insert(moulongdannEXEX_list, "slash")
			table.insert(moulongdannEXEX_list, "fire_slash")
			table.insert(moulongdannEXEX_list, "thunder_slash")
			table.insert(moulongdannEXEX_list, "ice_slash")
			to_moulongdannEXEX = room:askForChoice(user, "moulongdannEXEX_slash", table.concat(moulongdannEXEX_list, "+"))
		else
			to_moulongdannEXEX = user_str
		end
		local card = nil
		if self:subcardsLength() == 1 then card = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(self:getSubcards():first())) end
		local user_str
		if to_moulongdannEXEX == "slash" then
			if card and card:objectName() == "slash" then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		else
			user_str = to_moulongdannEXEX
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str, card and card:getSuit() or sgs.Card_SuitToBeDecided,
			card and card:getNumber() or -1)
		use_card:setSkillName("_moulongdannEXEX")
		use_card:addSubcards(self:getSubcards())
		use_card:deleteLater()
		return use_card
	end,
}
moulongdannEXEX = sgs.CreateViewAsSkill {
	name = "moulongdannEXEX",
	n = 1,
	response_or_use = true,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local skillcard = moulongdannEXEXCard:clone()
		skillcard:setSkillName(self:objectName())
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE
			or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			skillcard:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			for _, card in ipairs(cards) do
				skillcard:addSubcard(card)
			end
			return skillcard
		end
		local c = sgs.Self:getTag("moulongdannEXEX"):toCard()
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
		if player:getMark("&moulongdannLast") == 0 then return false end
		local basic = { "slash", "peach" }
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
		if player:getMark("&moulongdannLast") == 0 then return false end
		if string.startsWith(pattern, ".") or string.startsWith(pattern, "@") then return false end
		if pattern == "peach" and player:getMark("Global_PreventPeach") > 0 then return false end
		return pattern ~= "nullification" and pattern ~= "jl_wuxiesy"
	end,
}
moulongdannEXEX:setGuhuoDialog("l")
if not sgs.Sanguosha:getSkill("moulongdannEXEX") then skills:append(moulongdannEXEX) end

moujizhuooEX = sgs.CreateTriggerSkill {
	name = "moujizhuooEX",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseProceeding },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase == sgs.Player_Start and player:hasSkill(self:objectName()) then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				local XLto = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(),
					"@XL-jizhuoEX")
				local choice = room:askForChoice(player, self:objectName(),
					"XL_tongchouu+XL_bingjinn+XL_shucaii+XL_lulii")
				if choice == "XL_tongchouu" then
					room:addPlayerMark(player, "&XL_tongchou")
					room:addPlayerMark(XLto, "&XL_tongchou")
				elseif choice == "XL_bingjinn" then
					room:addPlayerMark(player, "&XL_bingjin")
					room:addPlayerMark(XLto, "&XL_bingjin")
				elseif choice == "XL_shucaii" then
					room:addPlayerMark(player, "&XL_shucai")
					room:addPlayerMark(XLto, "&XL_shucai")
				elseif choice == "XL_lulii" then
					room:addPlayerMark(player, "&XL_luli")
					room:addPlayerMark(XLto, "&XL_luli")
				end
				room:addPlayerMark(player, "jizhuoEXFrom")
				room:addPlayerMark(XLto, "jizhuoEXTo")
				room:broadcastSkillInvoke(self:objectName(), 1)
			end
		elseif phase == sgs.Player_Finish and player:getMark("jizhuoEXTo") > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasSkill("moulongdannEX") and p:hasSkill(self:objectName()) and p:getMark("jizhuoEXFrom") > 0 and p:getMark("&XL_success") > 0 then
					room:broadcastSkillInvoke(self:objectName(), 3)
					room:addPlayerMark(p, "&moulongdannLast")
					room:detachSkillFromPlayer(p, "moulongdannEX", true)
					if not p:hasSkill("moulongdannEXEX") then
						room:attachSkillToPlayer(p, "moulongdannEXEX")
					end
					room:setPlayerMark(p, "&XL_success", 0)
					room:setPlayerMark(p, "jizhuoEXFrom", 0)
					room:setPlayerMark(player, "jizhuoEXTo", 0)
				elseif (p:getMark("jizhuoEXFrom") > 0 or p:getMark("jizhuoEXTo") > 0) and p:getMark("&XL_success") == 0 then
					room:setPlayerMark(p, "jizhuoEXFrom", 0)
					room:setPlayerMark(p, "jizhuoEXTo", 0)
					if p:getMark("&XL_tongchou") > 0 then
						room:setPlayerMark(p, "&XL_tongchou", 0)
						room:setPlayerMark(p, "@XL_tongchou", 0)
					elseif p:getMark("&XL_bingjin") > 0 then
						room:setPlayerMark(p, "&XL_bingjin", 0)
						room:setPlayerMark(p, "@XL_bingjin", 0)
					elseif p:getMark("&XL_shucai") > 0 then
						room:setPlayerMark(p, "&XL_shucai", 0)
						room:setPlayerMark(p, "@XL_shucai_heart", 0)
						room:setPlayerMark(p, "@XL_shucai_diamond", 0)
						room:setPlayerMark(p, "@XL_shucai_club", 0)
						room:setPlayerMark(p, "@XL_shucai_spade", 0)
					elseif p:getMark("&XL_luli") > 0 then
						room:setPlayerMark(p, "&XL_luli", 0)
						room:setPlayerMark(p, "@XL_luli_heart", 0)
						room:setPlayerMark(p, "@XL_luli_diamond", 0)
						room:setPlayerMark(p, "@XL_luli_club", 0)
						room:setPlayerMark(p, "@XL_luli_spade", 0)
					end
				end
			end
		elseif phase == sgs.Player_Finish and player:hasSkill("moulongdannEXEX") and player:getMark("mou_zhaoyunnEX") > 0 then
			room:detachSkillFromPlayer(player, "moulongdannEXEX", true)
			if not player:hasSkill("moulongdannEX") then
				room:attachSkillToPlayer(player, "moulongdannEX")
				if player:getMark("&moulongdannLast") > 4 then
					room:setPlayerMark(player, "&moulongdannLast", 4)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_zhaoyunnEX:addSkill(moujizhuooEX)





--

--谋张飞
mou_zhangfeii = sgs.General(extension, "mou_zhangfeii", "shu", 4, true)

moupaoxiaoo = sgs.CreateTargetModSkill {
	name = "moupaoxiaoo",
	residue_func = function(self, player, card)
		if player:hasSkill(self:objectName()) and card:isKindOf("Slash") then
			return 1000
		else
			return 0
		end
	end,
}
moupaoxiaooHWtMD = sgs.CreateTargetModSkill {
	name = "moupaoxiaooHWtMD",
	distance_limit_func = function(self, from, card)
		if from:hasSkill("moupaoxiaoo") and from:getWeapon() ~= nil and card:isKindOf("Slash") then
			return 1000
		else
			return 0
		end
	end,
}
moupaoxiaooooo = sgs.CreateTriggerSkill {
	name = "moupaoxiaooooo",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardUsed, sgs.CardFinished, sgs.TargetSpecified, sgs.ConfirmDamage, sgs.Damage, sgs.EventPhaseChanging, sgs.Death },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") or player:getPhase() ~= sgs.Player_Play then return false end
			if not player:hasFlag("moupaoxiaooSlashUsed") then
				room:setPlayerFlag(player, "moupaoxiaooSlashUse")
			else
				room:sendCompulsoryTriggerLog(player, "moupaoxiaoo")
				room:broadcastSkillInvoke("moupaoxiaoo")
				player:setFlags("moupaoxiaooSource")
				for _, p in sgs.qlist(use.to) do
					p:setFlags("moupaoxiaooTarget")
					room:addPlayerMark(p, "@skill_invalidity")
				end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") and player:hasFlag("moupaoxiaooSlashUse") then
				room:setPlayerFlag(player, "-moupaoxiaooSlashUse")
				room:setPlayerFlag(player, "moupaoxiaooSlashUsed")
			end
		elseif event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") and player:hasSkill("moupaoxiaoo") and player:hasFlag("moupaoxiaooSlashUsed") and player:getPhase() == sgs.Player_Play then
				local no_respond_list = use.no_respond_list
				for _, wz in sgs.qlist(use.to) do
					table.insert(no_respond_list, wz:objectName())
				end
				use.no_respond_list = no_respond_list
				data:setValue(use)
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and player:hasSkill("moupaoxiaoo") and player:hasFlag("moupaoxiaooSlashUsed") and player:getPhase() == sgs.Player_Play then
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and player:hasSkill("moupaoxiaoo") and player:hasFlag("moupaoxiaooSlashUsed") and player:getPhase() == sgs.Player_Play and damage.to:isAlive() then
				room:loseHp(player, 1)
				if not player:isKongcheng() then --硬核随机
					if player:getState() == "robot" and damage.to:getState() == "online" then
						local ysws = room:askForCardChosen(player, player, "h", self:objectName())
						room:throwCard(ysws, player, nil)
					else
						local ysws = room:askForCardChosen(damage.to, player, "h", self:objectName())
						room:throwCard(ysws, player, nil)
					end
				end
			end
		else
			if event == sgs.EventPhaseChanging then
				local change = data:toPhaseChange()
				if change.to ~= sgs.Player_NotActive then
					return false
				end
			end
			if event == sgs.Death then
				local death = data:toDeath()
				if death.who:objectName() ~= player:objectName() then
					return false
				end
			end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("moupaoxiaooTarget") then
					p:setFlags("-moupaoxiaooTarget")
					if p:getMark("@skill_invalidity") > 0 then
						room:setPlayerMark(p, "@skill_invalidity", 0)
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player and player:hasSkill("moupaoxiaoo")
	end,
}
mou_zhangfeii:addSkill(moupaoxiaoo)
if not sgs.Sanguosha:getSkill("moupaoxiaooHWtMD") then skills:append(moupaoxiaooHWtMD) end
if not sgs.Sanguosha:getSkill("moupaoxiaooooo") then skills:append(moupaoxiaooooo) end

mouxiejiiCard = sgs.CreateSkillCard {
	name = "mouxiejiiCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		if #targets < 3 then
			return sgs.Self:canSlash(to_select, nil, false)
		end
		return false
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		for _, p in pairs(targets) do
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			slash:setSkillName("mouxiejiiS") --防止乱播报语音
			local use = sgs.CardUseStruct()
			use.card = slash
			use.from = source
			use.to:append(p)
			room:useCard(use)
		end
	end,
}
mouxiejiiVS = sgs.CreateZeroCardViewAsSkill {
	name = "mouxiejii",
	view_as = function()
		return mouxiejiiCard:clone()
	end,
	response_pattern = "@@mouxiejii",
}
mouxiejii = sgs.CreateTriggerSkill {
	name = "mouxiejii",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseProceeding, sgs.Damage },
	view_as_skill = mouxiejiiVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseProceeding then
			local phase = player:getPhase()
			if phase == sgs.Player_Start and player:hasSkill(self:objectName()) then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					local XLto = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(),
						"@XL-xieji")
					local choice = room:askForChoice(player, self:objectName(),
						"XL_tongchouu+XL_bingjinn+XL_shucaii+XL_lulii")
					if choice == "XL_tongchouu" then
						room:addPlayerMark(player, "&XL_tongchou")
						room:addPlayerMark(XLto, "&XL_tongchou")
					elseif choice == "XL_bingjinn" then
						room:addPlayerMark(player, "&XL_bingjin")
						room:addPlayerMark(XLto, "&XL_bingjin")
					elseif choice == "XL_shucaii" then
						room:addPlayerMark(player, "&XL_shucai")
						room:addPlayerMark(XLto, "&XL_shucai")
					elseif choice == "XL_lulii" then
						room:addPlayerMark(player, "&XL_luli")
						room:addPlayerMark(XLto, "&XL_luli")
					end
					room:addPlayerMark(player, "xiejiFrom")
					room:addPlayerMark(XLto, "xiejiTo")
					room:broadcastSkillInvoke(self:objectName(), 1)
				end
			elseif phase == sgs.Player_Finish and player:getMark("xiejiTo") > 0 then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:hasSkill(self:objectName()) and p:getMark("xiejiFrom") > 0 and p:getMark("&XL_success") > 0 then
						room:broadcastSkillInvoke(self:objectName(), 3)
						room:askForUseCard(p, "@@mouxiejii", "@mouxiejii-slash")
						room:setPlayerMark(p, "&XL_success", 0)
						room:setPlayerMark(p, "xiejiFrom", 0)
						room:setPlayerMark(player, "xiejiTo", 0)
					elseif (p:getMark("xiejiFrom") > 0 or p:getMark("xiejiTo") > 0) and p:getMark("&XL_success") == 0 then
						room:setPlayerMark(p, "xiejiFrom", 0)
						room:setPlayerMark(p, "xiejiTo", 0)
						if p:getMark("&XL_tongchou") > 0 then
							room:setPlayerMark(p, "&XL_tongchou", 0)
							room:setPlayerMark(p, "@XL_tongchou", 0)
						elseif p:getMark("&XL_bingjin") > 0 then
							room:setPlayerMark(p, "&XL_bingjin", 0)
							room:setPlayerMark(p, "@XL_bingjin", 0)
						elseif p:getMark("&XL_shucai") > 0 then
							room:setPlayerMark(p, "&XL_shucai", 0)
							room:setPlayerMark(p, "@XL_shucai_heart", 0)
							room:setPlayerMark(p, "@XL_shucai_diamond", 0)
							room:setPlayerMark(p, "@XL_shucai_club", 0)
							room:setPlayerMark(p, "@XL_shucai_spade", 0)
						elseif p:getMark("&XL_luli") > 0 then
							room:setPlayerMark(p, "&XL_luli", 0)
							room:setPlayerMark(p, "@XL_luli_heart", 0)
							room:setPlayerMark(p, "@XL_luli_diamond", 0)
							room:setPlayerMark(p, "@XL_luli_club", 0)
							room:setPlayerMark(p, "@XL_luli_spade", 0)
						end
					end
				end
			end
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if damage.card and damage.card:getSkillName() == "mouxiejiiS" and damage.from:objectName() == player:objectName() and player:hasSkill(self:objectName()) then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:drawCards(player, damage.damage, self:objectName())
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_zhangfeii:addSkill(mouxiejii)

--谋张飞-(5月)爆料版
mou_zhangfeiBN = sgs.General(extension, "mou_zhangfeiBN", "shu", 4, true)

mou_zhangfeiBN:addSkill("moupaoxiaoo") --再次添加同一技能不加引号会导致无法正常返回主菜单（直接闪退）

mouxiejiBN = sgs.CreateTriggerSkill {
	name = "mouxiejiBN",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseProceeding, sgs.ConfirmDamage, sgs.Damage },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseProceeding then
			local phase = player:getPhase()
			if phase == sgs.Player_Start and player:hasSkill(self:objectName()) then
				room:setPlayerMark(player, "&mouxiejiBNDamage", 0)
				if room:askForSkillInvoke(player, self:objectName(), data) then
					local XLto = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName())
					room:addPlayerMark(player, "mouxiejiBNFrom")
					room:setPlayerFlag(player, self:objectName())
					room:addPlayerMark(XLto, "mouxiejiBNHelp")
					room:broadcastSkillInvoke(self:objectName(), 1)
				end
			elseif phase == sgs.Player_Finish and player:getMark("mouxiejiBNHelp") > 0 then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:hasSkill(self:objectName()) and p:getMark("mouxiejiBNFrom") > 0 then
						if p:getMark("&mouxiejiBNDamage") == player:getMark("&mouxiejiBNDamage") then
							room:broadcastSkillInvoke(self:objectName(), 2)
							room:drawCards(p, 2, self:objectName())
							room:drawCards(player, 2, self:objectName())
							room:setPlayerMark(p, "&mouxiejiBNDamage", 0)
							room:setPlayerMark(player, "&mouxiejiBNDamage", 0)
							room:setPlayerMark(p, "mouxiejiBNFrom", 0)
							room:setPlayerMark(player, "mouxiejiBNHelp", 0)
						else
							room:setPlayerMark(p, "&mouxiejiBNDamage", 0)
							room:setPlayerMark(p, "mouxiejiBNFrom", 0)
						end
					end
				end
				room:setPlayerMark(player, "&mouxiejiBNDamage", 0)
				room:setPlayerMark(player, "mouxiejiBNHelp", 0)
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.from:objectName() == player:objectName() and player:hasFlag(self:objectName()) and damage.card:isKindOf("Slash") then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), 2)
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if damage.from and damage.from:objectName() == player:objectName() and (player:getMark("mouxiejiBNFrom") > 0 or player:getMark("mouxiejiBNHelp") > 0) then
				room:addPlayerMark(player, "&mouxiejiBNDamage", damage.damage)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_zhangfeiBN:addSkill(mouxiejiBN)





--

--FC谋关羽
fc_mou_guanyu = sgs.General(extension, "fc_mou_guanyu", "shu", 4, true)

fcmouwusheng = sgs.CreateOneCardViewAsSkill {
	name = "fcmouwusheng",
	response_or_use = true,
	view_filter = function(self, card)
		if not card:isRed() then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
			slash:addSubcard(card:getEffectiveId())
			slash:deleteLater()
			return slash:isAvailable(sgs.Self)
		end
		return true
	end,
	view_as = function(self, card)
		local slash = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
		slash:addSubcard(card:getId())
		slash:setSkillName(self:objectName())
		return slash
	end,
	enabled_at_play = function(self, player)
		return sgs.Slash_IsAvailable(player)
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash"
	end,
}
fcmouwushengDiamond = sgs.CreateTargetModSkill {
	name = "fcmouwushengDiamond",
	distance_limit_func = function(self, from, card)
		if from:hasSkill("fcmouwusheng") and card:isKindOf("Slash") and card:getSuit() == sgs.Card_Diamond then
			return 1000
		else
			return 0
		end
	end,
}
fcmouwushengHeart = sgs.CreateTriggerSkill {
	name = "fcmouwushengHeart",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.ConfirmDamage },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.card and damage.card:isKindOf("Slash") and damage.card:getSuit() == sgs.Card_Heart then
			room:sendCompulsoryTriggerLog(player, "fcmouwusheng")
			room:broadcastSkillInvoke("fcmouwusheng")
			local hurt = damage.damage
			damage.damage = hurt + 1
			data:setValue(damage)
		end
	end,
	can_trigger = function(self, player)
		return player and player:hasSkill("fcmouwusheng")
	end,
}
fc_mou_guanyu:addSkill(fcmouwusheng)
if not sgs.Sanguosha:getSkill("fcmouwushengDiamond") then skills:append(fcmouwushengDiamond) end
if not sgs.Sanguosha:getSkill("fcmouwushengHeart") then skills:append(fcmouwushengHeart) end

fcmouyijueCard = sgs.CreateSkillCard {
	name = "fcmouyijueCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local choiceFrom = room:askForChoice(effect.from, "@MouYi-yijue", "F1+F2") --谋攻篇新机制：“谋弈”
		if choiceFrom == "F1" then
			room:setPlayerFlag(effect.from, "fcmouyijue_wzhx")
		else
			room:setPlayerFlag(effect.from, "fcmouyijue_wmxz")
		end
		local choiceTo = room:askForChoice(effect.to, "@MouYi-yijue", "T1+T2")
		if choiceTo == "T1" then
			room:setPlayerFlag(effect.to, "fcmouyijue_wzhx")
		else
			room:setPlayerFlag(effect.to, "fcmouyijue_wmxz")
		end
		if (effect.from:hasFlag("fcmouyijue_wzhx") and effect.to:hasFlag("fcmouyijue_wmxz")) or (effect.from:hasFlag("fcmouyijue_wmxz") and effect.to:hasFlag("fcmouyijue_wzhx")) then
			--“谋弈”成功
			local log = sgs.LogMessage()
			log.type = "$MouYi_success"
			log.from = effect.from
			log.to:append(effect.to)
			room:sendLog(log)
			room:broadcastSkillInvoke("fcmouyijue", math.random(1, 2))
			effect.from:setFlags("fcmouyijueSource")
			effect.to:gainMark("&fcmouyijue")
			room:addPlayerMark(effect.to, "@skill_invalidity")
			room:setPlayerCardLimitation(effect.to, "use,response", ".|.|.|hand", false)
		else
			--“谋弈”失败
			local log = sgs.LogMessage()
			log.type = "$MouYi_fail"
			log.from = effect.from
			log.to:append(effect.to)
			room:sendLog(log)
			if not effect.to:isAllNude() then
				local EnYi = room:askForCardChosen(effect.from, effect.to, "hej", "fcmouyijue")
				room:obtainCard(effect.from, EnYi, true)
				if effect.to:isWounded() and room:askForSkillInvoke(effect.from, "@fcmouyijue-Recover") then
					room:recover(effect.to, sgs.RecoverStruct(effect.from))
					room:broadcastSkillInvoke("fcmouyijue", math.random(1, 2))
				end
			end
		end
		if effect.from:hasFlag("fcmouyijue_wzhx") then room:setPlayerFlag(effect.from, "-fcmouyijue_wzhx") end
		if effect.from:hasFlag("fcmouyijue_wmxz") then room:setPlayerFlag(effect.from, "-fcmouyijue_wmxz") end
		if effect.to:hasFlag("fcmouyijue_wzhx") then room:setPlayerFlag(effect.to, "-fcmouyijue_wzhx") end
		if effect.to:hasFlag("fcmouyijue_wmxz") then room:setPlayerFlag(effect.to, "-fcmouyijue_wmxz") end
	end,
}
fcmouyijue = sgs.CreateOneCardViewAsSkill {
	name = "fcmouyijue",
	view_filter = function(self, to_select)
		return true
	end,
	view_as = function(self, cards)
		local my_card = fcmouyijueCard:clone()
		my_card:addSubcard(cards)
		return my_card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#fcmouyijueCard") and not player:isNude()
	end,
}
fcmouyijueBuffANDClear = sgs.CreateTriggerSkill {
	name = "fcmouyijueBuffANDClear",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.ConfirmDamage, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.from:objectName() == player:objectName() and player:hasSkill("fcmouyijue") and damage.to:getMark("&fcmouyijue") > 0
				and damage.card:isKindOf("Slash") and damage.card:isRed() then
				room:sendCompulsoryTriggerLog(player, "fcmouyijue")
				room:broadcastSkillInvoke("fcmouyijue", math.random(3, 4))
				local YDJ = damage.damage
				damage.damage = YDJ + 1
				data:setValue(damage)
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("&fcmouyijue") > 0 then
					room:setPlayerMark(p, "&fcmouyijue", 0)
					if p:getMark("@skill_invalidity") > 0 then
						room:setPlayerMark(p, "@skill_invalidity", 0)
					end
					room:removePlayerCardLimitation(p, "use,response", ".|.|.|hand")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
fc_mou_guanyu:addSkill(fcmouyijue)
if not sgs.Sanguosha:getSkill("fcmouyijueBuffANDClear") then skills:append(fcmouyijueBuffANDClear) end

--谋孙尚香
mou_sunshangxiangg = sgs.General(extension, "mou_sunshangxiangg", "shu", 4, false)

mouliangzhuuCard = sgs.CreateSkillCard {
	name = "mouliangzhuuCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and to_select:getEquips():length() > 0
	end,
	on_use = function(self, room, source, targets)
		local brother = targets[1]
		local equip = room:askForCardChosen(source, brother, "e", "mouliangzhuu")
		source:addToPile("mouJiaZhuang", equip)
		for _, h in sgs.qlist(room:getAllPlayers()) do
			if h:getMark("&mouHusband") > 0 then
				local choice = room:askForChoice(h, "mouliangzhuu", "1+2")
				if choice == "1" then
					room:recover(h, sgs.RecoverStruct(h))
				else
					room:drawCards(h, 2, "mouliangzhuu")
				end
			end
		end
	end,
}
mouliangzhuu = sgs.CreateZeroCardViewAsSkill {
	name = "mouliangzhuu",
	view_as = function()
		return mouliangzhuuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#mouliangzhuuCard") and player:getKingdom() == "shu"
	end,
}
mou_sunshangxiangg:addSkill(mouliangzhuu)

function getWinner(room, victim)
	local function contains(plist, role)
		for _, p in sgs.qlist(plist) do
			if p:getRoleEnum() == role then return true end
		end
		return false
	end
	local r = victim:getRoleEnum()
	local sp = room:getOtherPlayers(victim)
	if r == sgs.Player_Lord then
		if (sp:length() == 1 and sp:first():getRole() == "renegade") then
			return "renegade"
		else
			return "rebel"
		end
	else
		if (not contains(sp, sgs.Player_Rebel) and not contains(sp, sgs.Player_Renegade)) then
			return "lord+loyalist"
		else
			return nil
		end
	end
end

moujieyinn = sgs.CreateTriggerSkill {
	name = "moujieyinn",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.GameStart, sgs.EventPhaseStart, sgs.MarkChanged, sgs.GameOverJudge },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill(self:objectName()) then
				local husband = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(),
					"@moujieyinn-start")
				husband:gainMark("&mouHusband", 1)
				room:broadcastSkillInvoke(self:objectName(), 1)
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_Play or not player:hasSkill(self:objectName()) then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if player:getMark("moujieyinn_fail") > 0 then break end
				if p:getMark("&mouHusband") > 0 and not p:hasFlag("cantchoiceMJYnow") then
					local choices = {}
					if not p:isKongcheng() then
						table.insert(choices, "1")
					end
					if p:getMark("&mouHusbandMarkLost") == 0 then
						table.insert(choices, "2")
					elseif p:getMark("&mouHusbandMarkLost") > 0 then
						table.insert(choices, "3")
					end
					local choice = room:askForChoice(p, self:objectName(), table.concat(choices, "+"))
					if choice == "1" then
						if p:getHandcardNum() > 2 then
							local caili = room:askForExchange(p, self:objectName(), 2, 2, false,
								"#moujieyinn:" .. player:getGeneralName())
							if caili then
								room:obtainCard(player, caili,
									sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(),
										p:objectName(), self:objectName(), ""), false)
							end
						else
							room:obtainCard(player, p:wholeHandCards(), false)
						end
						room:broadcastSkillInvoke(self:objectName(), 1)
						p:gainHujia(1)
					elseif choice == "2" then
						local choicee = room:askForChoice(player, self:objectName(), "4+5")
						if choicee == "4" then
							local Next = room:askForPlayerChosen(player, room:getOtherPlayers(p), self:objectName(),
								"@moujieyinn-markmove")
							Next:gainMark("&mouHusband", 1) --先让新目标获得标记，防止触发“sgs.MarkChanged”时机时检测到场上无“助”标记
							room:setPlayerFlag(Next, "cantchoiceMJYnow") --因为处于for循环语句中，防止未执行此循环的角色因获得了“助”标记轮到其时立即开始选择，导致出现错误
							p:loseMark("&mouHusband", 1)
							room:addPlayerMark(p, "&mouHusbandMarkLost")
							room:broadcastSkillInvoke(self:objectName(), 1)
						elseif choicee == "5" then
							p:loseMark("&mouHusband", 1)
						end
					elseif choice == "3" then
						p:loseMark("&mouHusband", 1)
					end
				end
			end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("cantchoiceMJYnow") then
					room:setPlayerFlag(p, "-cantchoiceMJYnow")
				end
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == "&mouHusband" and mark.gain == -1 then
				local n = 0 --用can_invoke判断会出现BUG，不知是什么原因
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getMark("&mouHusband") > 0 then
						n = n + 1
					end
				end
				if n == 0 then
					for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
						if p:getMark("moujieyinn_fail") == 0 then
							--使命失败
							room:broadcastSkillInvoke(self:objectName(), 2)
							room:recover(p, sgs.RecoverStruct(p))
							local JiaZhuang = sgs.Sanguosha:cloneCard("slash")
							JiaZhuang:addSubcards(p:getPile("mouJiaZhuang"))
							room:obtainCard(p, JiaZhuang, false)
							room:setPlayerProperty(p, "kingdom", sgs.QVariant("wu"))
							room:loseMaxHp(p, 1)
							room:addPlayerMark(p, "moujieyinn_fail")
							for _, p in sgs.qlist(room:getAllPlayers()) do
								if p:getMark("&mouHusbandMarkLost") > 0 then
									room:setPlayerMark(p, "&mouHusbandMarkLost", 0)
								end
							end
						end
					end
				end
			end
		elseif event == sgs.GameOverJudge then
			local death = data:toDeath()
			local lord = room:getLord()
			if not lord then return false end --暂时只能排除2v2等无主公的模式，防止闪退
			local winner = getWinner(room, death.who)
			if not winner then return false end
			local can_invoke = false
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("&mouHusband") > 0 then
					can_invoke = true --使命成功
				end
			end
			local mssx = room:findPlayerBySkillName(self:objectName())
			if not mssx then
				can_invoke = false
			end
			if can_invoke then
				room:broadcastSkillInvoke(self:objectName(), 1)
				room:doLightbox("$moujieyinn_success")
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_sunshangxiangg:addSkill(moujieyinn)

mouxiaojii = sgs.CreateTriggerSkill {
	name = "mouxiaojii",
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardsMoveOneTime },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceEquip) then
			if player:getKingdom() ~= "wu" then return false end
			for i = 0, move.card_ids:length() - 1, 1 do
				if not player:isAlive() then return false end
				if move.from_places:at(i) == sgs.Player_PlaceEquip then
					room:broadcastSkillInvoke(self:objectName())
					room:drawCards(player, 2, self:objectName())
					local FJ = sgs.SPlayerList()
					for _, lb in sgs.qlist(room:getAllPlayers()) do
						if lb:getEquips():length() > 0 or lb:getJudgingArea():length() > 0 then
							FJ:append(lb)
						end
					end
					if FJ:isEmpty() then return false end
					local liubei = room:askForPlayerChosen(player, FJ, self:objectName(), "@mouxiaojii-throw", true, true)
					if liubei then
						local card = room:askForCardChosen(player, liubei, "ej", self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						room:throwCard(card, liubei, player)
					end
				end
			end
		end
	end,
}
mou_sunshangxiangg:addSkill(mouxiaojii)

--谋马超
mou_machaoo = sgs.General(extension, "mou_machaoo", "shu", 4, true)

mou_machaoo:addSkill("mashu")

moutieqii = sgs.CreateTriggerSkill {
	name = "moutieqii",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.TargetConfirming },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") and use.from:hasSkill(self:objectName()) then
			if room:askForSkillInvoke(use.from, self:objectName(), data) then
				room:sendCompulsoryTriggerLog(use.from, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), 1)
				use.from:setFlags("moutieqiiSource")
				local no_respond_list = use.no_respond_list
				for _, c in sgs.qlist(use.to) do
					c:setFlags("moutieqiiTarget")
					room:addPlayerMark(c, "@skill_invalidity")
					table.insert(no_respond_list, c:objectName())
					room:broadcastSkillInvoke(self:objectName(), 2)
					if use.from:getState() == "online" then
						local choiceFrom = room:askForChoice(use.from, "@MouYi-tieqi", "F1+F2")
						if choiceFrom == "F1" then
							room:setPlayerFlag(use.from, "moutieqi_zqdy")
						else
							room:setPlayerFlag(use.from, "moutieqi_rzpd")
						end
					elseif use.from:getState() == "robot" then
						local choicesFrom = {}
						if not c:isNude() then --目标无牌，不抢牌
							table.insert(choicesFrom, "F1")
						end
						table.insert(choicesFrom, "F2")
						local choiceFrom = room:askForChoice(use.from, "@MouYi-tieqi", table.concat(choicesFrom, "+"))
						if choiceFrom == "F1" then
							room:setPlayerFlag(use.from, "moutieqi_zqdy")
						else
							room:setPlayerFlag(use.from, "moutieqi_rzpd")
						end
					end
					if c:getState() == "online" then
						local choiceTo = room:askForChoice(c, "@MouYi-tieqi", "T1+T2")
						if choiceTo == "T1" then
							room:setPlayerFlag(c, "moutieqi_gwzz")
						else
							room:setPlayerFlag(c, "moutieqi_czyz")
						end
					elseif c:getState() == "robot" then
						local choicesTo = {}
						if not c:isNude() then --自己无牌对方选抢牌也没用，直接阻止对方摸牌
							table.insert(choicesTo, "T1")
						end
						table.insert(choicesTo, "T2")
						local choiceTo = room:askForChoice(c, "@MouYi-tieqi", table.concat(choicesTo, "+"))
						if choiceTo == "T1" then
							room:setPlayerFlag(c, "moutieqi_gwzz")
						else
							room:setPlayerFlag(c, "moutieqi_czyz")
						end
					end
					--“谋弈”成功
					if use.from:hasFlag("moutieqi_zqdy") and c:hasFlag("moutieqi_czyz") then --抢牌成功
						local log = sgs.LogMessage()
						log.type = "$MouYi_success"
						log.from = use.from
						log.to:append(c)
						room:sendLog(log)
						room:broadcastSkillInvoke(self:objectName(), 3)
						if not c:isNude() then
							local Ying = room:askForCardChosen(use.from, c, "he", self:objectName())
							room:obtainCard(use.from, Ying, false)
						end
					elseif use.from:hasFlag("moutieqi_rzpd") and c:hasFlag("moutieqi_gwzz") then --摸牌成功
						local log = sgs.LogMessage()
						log.type = "$MouYi_success"
						log.from = use.from
						log.to:append(c)
						room:sendLog(log)
						room:broadcastSkillInvoke(self:objectName(), 4)
						room:drawCards(use.from, 2, self:objectName())
					else
						--“谋弈”失败
						local log = sgs.LogMessage()
						log.type = "$MouYi_fail"
						log.from = use.from
						log.to:append(c)
						room:sendLog(log)
						room:broadcastSkillInvoke(self:objectName(), 5)
					end
				end
				use.no_respond_list = no_respond_list
				if use.from:hasFlag("moutieqi_zqdy") then room:setPlayerFlag(use.from, "-moutieqi_zqdy") end
				if use.from:hasFlag("moutieqi_rzpd") then room:setPlayerFlag(use.from, "-moutieqi_rzpd") end
				for _, p in sgs.qlist(use.to) do
					if p:hasFlag("moutieqi_gwzz") then room:setPlayerFlag(p, "-moutieqi_gwzz") end
					if p:hasFlag("moutieqi_czyz") then room:setPlayerFlag(p, "-moutieqi_czyz") end
				end
				data:setValue(use)
			end
		end
	end,
}
moutieqiiClear = sgs.CreateTriggerSkill {
	name = "moutieqiiClear",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.EventPhaseChanging, sgs.Death },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
		end
		if event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then
				return false
			end
		end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("moutieqiiSource") then p:setFlags("-moutieqiiSource") end
			if p:hasFlag("moutieqiiTarget") then
				p:setFlags("-moutieqiiTarget")
				if p:getMark("@skill_invalidity") > 0 then
					room:setPlayerMark(p, "@skill_invalidity", 0)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_machaoo:addSkill(moutieqii)
if not sgs.Sanguosha:getSkill("moutieqiiClear") then skills:append(moutieqiiClear) end





--

--谋杨婉
mou_yangwann = sgs.General(extension, "mou_yangwann", "qun", 3, false)

moumingxuannCard = sgs.CreateSkillCard {
	name = "moumingxuannCard",
	will_throw = false,
	filter = function(self, targets, to_select)
		local n = self:subcardsLength()
		if #targets == n then return false end
		return to_select:getMark("&moumingxuann") == 0
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		local suijigives = {}
		for _, c in sgs.qlist(self:getSubcards()) do
			table.insert(suijigives, c)
		end
		for _, p in pairs(targets) do
			local random_card = suijigives[math.random(1, #suijigives)]
			room:obtainCard(p, random_card, false)
			room:setPlayerFlag(p, "mingxuanedInThisTime")
			table.removeOne(suijigives, random_card)
		end
	end,
}
moumingxuannVS = sgs.CreateViewAsSkill {
	name = "moumingxuann",
	n = 999, --n = 4,
	view_filter = function(self, selected, to_select)
		local n = math.max(1, sgs.Self:getMark("moumingxuannCardGive"))
		if #selected >= n then return false end
		for _, c in sgs.list(selected) do
			if c:getSuit() == to_select:getSuit() then return false end
		end
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		local n = math.max(1, sgs.Self:getMark("moumingxuannCardGive"))
		if #cards >= 1 and #cards <= n then
			local MXC = moumingxuannCard:clone()
			for _, c in ipairs(cards) do
				MXC:addSubcard(c)
			end
			return MXC
		end
		return nil
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@moumingxuann")
	end,
}
moumingxuann = sgs.CreateTriggerSkill {
	name = "moumingxuann",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.EventPhaseStart },
	view_as_skill = moumingxuannVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play and not player:isKongcheng() then
			local can_invoke = false
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getMark("&moumingxuann") == 0 then
					can_invoke = true
					room:addPlayerMark(player, "moumingxuannCardGive") --记录未被记录的角色数
				end
			end
			if can_invoke then
				room:askForUseCard(player, "@@moumingxuann!", "@moumingxuann-card")
				local mingxuaners = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:hasFlag("mingxuanedInThisTime") then
						mingxuaners:append(p)
					end
				end
				for _, p in sgs.qlist(mingxuaners) do
					local use_slash = false
					if p:canSlash(player, nil, false) then
						use_slash = room:askForUseSlashTo(p, player, "@moumingxuann-slash:" .. player:objectName())
						if use_slash then
							p:gainMark("&moumingxuann", 1)
						end
					end
					if not use_slash then
						if not p:isNude() then
							local card = room:askForExchange(p, self:objectName(), 1, 1, true,
								"#moumingxuann:" .. player:getGeneralName())
							if card then
								room:obtainCard(player, card,
									sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(),
										p:objectName(), self:objectName(), ""), false)
							end
						end
						room:drawCards(player, 1, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
					end
					room:setPlayerFlag(p, "-mingxuanedInThisTime")
				end
			end
			room:setPlayerMark(player, "moumingxuannCardGive", 0)
		end
	end,
}
mou_yangwann:addSkill(moumingxuann)

mouxianchouu = sgs.CreateTriggerSkill {
	name = "mouxianchouu",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.Damaged, sgs.Damage, sgs.CardFinished },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			local damage = data:toDamage()
			local wangyi = damage.from
			if damage.to:objectName() ~= player:objectName() or not player:hasSkill(self:objectName()) or not player:isAlive() then return false end
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:setPlayerFlag(player, "mouyangwan") --便于锁定为回血对象
				local plist = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:objectName() ~= wangyi:objectName() then
						plist:append(p)
					end
				end
				if plist:isEmpty() then return false end
				local machao = room:askForPlayerChosen(player, plist, self:objectName(), "@mouxianchouu-fujunAvanger")
				room:broadcastSkillInvoke(self:objectName())
				if room:askForCard(machao, "..", "@mouxianchouu-slash", data, self:objectName()) then
					local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					slash:setSkillName(self:objectName())
					if not machao:canSlash(wangyi, nil, false) then
						slash = nil
						return false
					end
					if room:useCard(sgs.CardUseStruct(slash, machao, wangyi), false) then
						room:addPlayerHistory(machao, "Slash") --区分“无次数限制”与“不计入次数限制”，前者是要占用使用名额的
					end
				end
			end
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and damage.card:getSkillName() == "mouxianchouu"
				and damage.from:objectName() == player:objectName() and not player:hasFlag("mxc_baochou_success") then
				room:setPlayerFlag(player, "mxc_baochou_success")
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card and use.card:isKindOf("Slash") and use.card:getSkillName() == "mouxianchouu"
				and use.from:objectName() == player:objectName() and player:hasFlag("mxc_baochou_success") then
				room:drawCards(player, 2, self:objectName())
				for _, yw in sgs.qlist(room:getAllPlayers()) do
					if yw:hasFlag("mouyangwan") then
						room:recover(yw, sgs.RecoverStruct(yw))
						room:setPlayerFlag(yw, "-mouyangwan")
					end
				end
				room:setPlayerFlag(player, "-mxc_baochou_success")
			end
			for _, yw in sgs.qlist(room:getAllPlayers()) do --确保清除回血目标锁定标志
				if yw:hasFlag("mouyangwan") then
					room:setPlayerFlag(yw, "-mouyangwan")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_yangwann:addSkill(mouxianchouu)

--

--谋孙权
mou_sunquann = sgs.General(extension, "mou_sunquann$", "wu", 4, true)

mouzhihenggCard = sgs.CreateSkillCard {
	name = "mouzhihenggCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		if source:isKongcheng() then --我一度怀疑这样写是不严谨的
			local n = source:getMark("&mouYE")
			if n > 0 then
				room:drawCards(source, self:subcardsLength() + n + 1, "mouzhihengg")
				source:loseMark("&mouYE", 1)
			else
				room:drawCards(source, self:subcardsLength() + 1, "mouzhihengg")
			end
		else
			room:drawCards(source, self:subcardsLength(), "mouzhihengg")
		end
	end,
}
mouzhihengg = sgs.CreateViewAsSkill {
	name = "mouzhihengg",
	n = 999,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local mzh_card = mouzhihenggCard:clone()
		for _, card in pairs(cards) do
			mzh_card:addSubcard(card)
		end
		mzh_card:setSkillName(self:objectName())
		return mzh_card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#mouzhihenggCard") and player:canDiscard(player, "he")
	end,
}
mou_sunquann:addSkill(mouzhihengg)

moutongyee = sgs.CreateTriggerSkill {
	name = "moutongyee",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.EventPhaseProceeding },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase == sgs.Player_Finish then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			local choice = room:askForChoice(player, "@TuiCe-tongye", "change+unchanged")
			if choice == "change" then
				local log = sgs.LogMessage()
				log.type = "$TuiCe_change"
				log.from = player
				room:sendLog(log)
				room:broadcastSkillInvoke(self:objectName())
				room:addPlayerMark(player, "&moutongyee_change")
				local n = 0
				for _, p in sgs.qlist(room:getAllPlayers()) do
					local e = p:getEquips():length()
					n = n + e
				end
				room:setPlayerMark(player, "moutongyee_equiplength", n)
			else
				local log = sgs.LogMessage()
				log.type = "$TuiCe_unchanged"
				log.from = player
				room:sendLog(log)
				room:broadcastSkillInvoke(self:objectName())
				room:addPlayerMark(player, "&moutongyee_unchanged")
				local n = 0
				for _, p in sgs.qlist(room:getAllPlayers()) do
					local e = p:getEquips():length()
					n = n + e
				end
				room:setPlayerMark(player, "moutongyee_equiplength", n)
			end
		elseif phase == sgs.Player_Start then
			if player:getMark("&moutongyee_change") == 0 and player:getMark("&moutongyee_unchanged") == 0 then return false end
			local n = 0
			for _, p in sgs.qlist(room:getAllPlayers()) do
				local e = p:getEquips():length()
				n = n + e
			end
			if (player:getMark("moutongyee_equiplength") ~= n and player:getMark("&moutongyee_change") > 0)
				or (player:getMark("moutongyee_equiplength") == n and player:getMark("&moutongyee_unchanged") > 0) then
				local log = sgs.LogMessage()
				log.type = "$TuiCe_success"
				log.from = player
				room:sendLog(log)
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				if player:getMark("&mouYE") < 2 then
					player:gainMark("&mouYE", 1)
				end
			else
				local log = sgs.LogMessage()
				log.type = "$TuiCe_fail"
				log.from = player
				room:sendLog(log)
				room:sendCompulsoryTriggerLog(player, self:objectName())
				if player:getMark("&mouYE") > 0 then
					player:loseMark("&mouYE", 1)
				end
			end
			room:setPlayerMark(player, "moutongyee_equiplength", 0)
			room:setPlayerMark(player, "&moutongyee_change", 0)
			room:setPlayerMark(player, "&moutongyee_unchanged", 0)
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill(self:objectName())
	end,
}
mou_sunquann:addSkill(moutongyee)

moujiuyuann = sgs.CreateTriggerSkill {
	name = "moujiuyuann$",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardUsed, sgs.TargetConfirmed, sgs.PreHpRecover },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.CardUsed then
			if use.card:isKindOf("Peach") and use.from:objectName() == player:objectName() and player:getKingdom() == "wu" then
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:hasLordSkill(self:objectName()) then
						room:sendCompulsoryTriggerLog(p, self:objectName())
						room:broadcastSkillInvoke(self:objectName(), 1)
						room:drawCards(p, 1, self:objectName())
					end
				end
			end
		elseif event == sgs.TargetConfirmed then
			if use.card:isKindOf("Peach") and use.from and use.from:getKingdom() == "wu" and player:objectName() ~= use.from:objectName()
				and player:hasLordSkill(self:objectName()) and player:hasFlag("Global_Dying") then
				local log = sgs.LogMessage()
				log.type = "$moujiuyuann"
				log.to:append(player)
				room:sendLog(log)
				room:setCardFlag(use.card, self:objectName())
			end
		elseif event == sgs.PreHpRecover then
			local rec = data:toRecover()
			if rec.card and rec.card:hasFlag(self:objectName()) then
				room:broadcastSkillInvoke(self:objectName(), 2)
				rec.recover = rec.recover + 1
				data:setValue(rec)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_sunquann:addSkill(moujiuyuann)

--谋吕蒙
mou_lvmengg = sgs.General(extension, "mou_lvmengg", "wu", 4, true)

moukejiiCard = sgs.CreateSkillCard {
	name = "moukejiiCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local choices = {}
		if not source:hasFlag("moukejii_get1hujia") and not source:isKongcheng() then
			table.insert(choices, "1")
		end
		if not source:hasFlag("moukejii_get2hujias") then
			table.insert(choices, "2")
		end
		table.insert(choices, "cancel")
		local choice = room:askForChoice(source, "moukejii", table.concat(choices, "+"))
		if choice == "1" then
			room:askForDiscard(source, "moukejii", 1, 1)
			source:gainHujia(1)
			room:setPlayerFlag(source, "moukejii_get1hujia")
		elseif choice == "2" then
			local n = source:getHujia()
			if n > 0 then
				source:loseAllHujias() --如果已有护甲，先把所有护甲扣除，防止流失体力扣护甲
			end
			room:loseHp(source, 1)
			if n > 0 then
				source:gainHujia(n) --流失完体力后，再将暂扣的护甲补回来
			end
			source:gainHujia(2)
			room:setPlayerFlag(source, "moukejii_get2hujias")
		end
	end,
}
moukejii = sgs.CreateZeroCardViewAsSkill {
	name = "moukejii",
	view_as = function()
		return moukejiiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not (player:getMark("moudujiangg") == 0 and player:hasFlag("moukejii_get1hujia") and player:hasFlag("moukejii_get2hujias"))
			and not (player:getMark("moudujiangg") > 0 and player:hasUsed("#moukejiiCard"))
	end,
}
moukejiiMaxCards = sgs.CreateMaxCardsSkill {
	name = "moukejiiMaxCards",
	extra_func = function(self, kjmw)
		if kjmw:hasSkill("moukejii") then
			local n = kjmw:getHujia()
			return n
		else
			return 0
		end
	end,
}
moukejiiGuR = sgs.CreateTriggerSkill {
	name = "moukejiiGuR",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.GameStart, sgs.EventPhaseEnd, sgs.EnterDying, sgs.Dying, sgs.QuitDying, sgs.EventLoseSkill, sgs.EventAcquireSkill, sgs.MarkChanged, sgs.HpChanged },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart and player:hasSkill("moukejii") then
			room:setPlayerCardLimitation(player, "use", "Peach", false)
			room:addPlayerMark(player, self:objectName()) --被封非锁定技时识别
		elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Discard and player:hasSkill("moukejii") then
			if player:getHujia() > 0 then room:broadcastSkillInvoke("moukejii") end
		elseif (event == sgs.EnterDying or event == sgs.Dying) and player:hasSkill("moukejii") and player:hasFlag("Global_Dying") then
			room:removePlayerCardLimitation(player, "use", "Peach")
		elseif (event == sgs.QuitDying or (event == sgs.HpChanged and player:getHp() > 0)) and player:hasSkill("moukejii") then
			room:setPlayerCardLimitation(player, "use", "Peach", false)
			--因为封锁卡牌是不会根据技能的变化动态调整的，所以要考虑以下情况（但肯定会存在一些极端情况出现问题）：
		elseif event == sgs.EventLoseSkill then --失去技能，封锁失效
			if data:toString() == "moukejii" then room:removePlayerCardLimitation(player, "use", "Peach") end
		elseif event == sgs.EventAcquireSkill then --获得技能，封锁生效
			if data:toString() == "moukejii" then room:setPlayerCardLimitation(player, "use", "Peach", false) end
		elseif event == sgs.MarkChanged then --[被封/解封]非锁定技，封锁[失效/生效]
			local mark = data:toMark()
			if mark.name == "@skill_invalidity" and mark.who:getMark(self:objectName()) > 0 then
				if mark.who:getMark("@skill_invalidity") > 0 then
					room:removePlayerCardLimitation(player, "use", "Peach")
				elseif mark.who:getMark("@skill_invalidity") == 0 then
					room:setPlayerCardLimitation(player, "use", "Peach", false)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_lvmengg:addSkill(moukejii)
if not sgs.Sanguosha:getSkill("moukejiiMaxCards") then skills:append(moukejiiMaxCards) end
if not sgs.Sanguosha:getSkill("moukejiiGuR") then skills:append(moukejiiGuR) end

moudujiangg = sgs.CreatePhaseChangeSkill {
	name = "moudujiangg",
	frequency = sgs.Skill_Wake,
	waked_skills = "moudj_duojing",
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getHujia() < 3 then return false end
		return true
	end,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:doSuperLightbox("mou_lvmengg", "moudujiangg")
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		if not player:hasSkill("moudj_duojing") then
			room:acquireSkill(player, "moudj_duojing")
		end
	end,
}
mou_lvmengg:addSkill(moudujiangg)
mou_lvmengg:addRelateSkill("moudj_duojing")
--“夺荆”
moudj_duojing = sgs.CreateTriggerSkill {
	name = "moudj_duojing",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.TargetConfirming, sgs.CardFinished, sgs.EventPhaseEnd },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.TargetConfirming then
			if use.card:isKindOf("Slash") and use.from:hasSkill(self:objectName()) and use.from:getHujia() > 0 then
				if room:askForSkillInvoke(use.from, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					use.from:loseHujia(1)
					use.from:setFlags("moudj_duojingPFfrom")
					for _, p in sgs.qlist(use.to) do
						p:setFlags("moudj_duojingPFto")
						room:addPlayerMark(p, "Armor_Nullified")
						if not p:isNude() then
							local id = room:askForCardChosen(use.from, p, "he", self:objectName())
							room:obtainCard(use.from, sgs.Sanguosha:getCard(id), false)
						end
						room:addPlayerMark(use.from, self:objectName())
					end
					data:setValue(use)
				end
			end
		elseif event == sgs.CardFinished and use.card:isKindOf("Slash") then
			if not player:hasFlag("moudj_duojingPFfrom") then
				return false
			end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("moudj_duojingPFto") then
					p:setFlags("-moudj_duojingPFto")
					if p:getMark("Armor_Nullified") then
						room:removePlayerMark(p, "Armor_Nullified")
					end
				end
			end
			player:setFlags("-moudj_duojingPFfrom")
		elseif event == sgs.EventPhaseEnd then
			room:setPlayerMark(player, self:objectName(), 0)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
moudj_duojingg = sgs.CreateTargetModSkill {
	name = "moudj_duojingg",
	residue_func = function(self, kjmw, card)
		if kjmw:hasSkill("moudj_duojing") and kjmw:getMark("moudj_duojing") > 0 and card:isKindOf("Slash") then
			local n = kjmw:getMark("moudj_duojing")
			return n
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("moudj_duojing") then skills:append(moudj_duojing) end
if not sgs.Sanguosha:getSkill("moudj_duojingg") then skills:append(moudj_duojingg) end

--谋徐晃
mou_xuhuangg = sgs.General(extension, "mou_xuhuangg", "wei", 4, true)

mouduanlianggCard = sgs.CreateSkillCard {
	name = "mouduanlianggCard",
	target_fixed = false,
	--mute = true, --防止技能卡牌乱报语音（然而实测整个技能卡都沉默了）
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		room:broadcastSkillInvoke(self:objectName(), 1)
		--注：不想手动设置智能AI了，看脸吧
		local choiceFrom = room:askForChoice(effect.from, "@MouYi-duanliang", "F1+F2")
		if choiceFrom == "F1" then
			room:setPlayerFlag(effect.from, "mouduanliang_wcdl")
		else
			room:setPlayerFlag(effect.from, "mouduanliang_lgjj")
		end
		local choiceTo = room:askForChoice(effect.to, "@MouYi-duanliang", "T1+T2")
		if choiceTo == "T1" then
			room:setPlayerFlag(effect.to, "mouduanliang_qjtj")
		else
			room:setPlayerFlag(effect.to, "mouduanliang_bmsc")
		end
		--“谋弈”成功
		if effect.from:hasFlag("mouduanliang_wcdl") and effect.to:hasFlag("mouduanliang_bmsc") then --兵粮成功
			local log = sgs.LogMessage()
			log.type = "$MouYi_success"
			log.from = effect.from
			log.to:append(effect.to)
			room:sendLog(log)
			room:broadcastSkillInvoke(self:objectName(), 2)
			local n = 0
			if effect.to:getJudgingArea():length() > 0 then
				for _, c in sgs.qlist(effect.to:getJudgingArea()) do
					if c:isKindOf("SupplyShortage") then
						n = n + 1
					end
					break
				end
			end
			if n > 0 then
				if not effect.to:isNude() then
					local get = room:askForCardChosen(effect.from, effect.to, "he", "mouduanliangg")
					room:obtainCard(effect.from, get, false)
				end
			else
				local id = room:getNCards(1, false)
				local card = sgs.Sanguosha:getCard(id:first())
				local shortage = sgs.Sanguosha:cloneCard("supply_shortage", card:getSuit(), card:getNumber())
				shortage:setSkillName("mouduanliangv") --防止乱播报语音
				shortage:addSubcard(card)
				if not effect.from:isProhibited(effect.to, shortage) then
					room:useCard(sgs.CardUseStruct(shortage, effect.from, effect.to))
				else
					shortage:deleteLater()
				end
			end
		elseif effect.from:hasFlag("mouduanliang_lgjj") and effect.to:hasFlag("mouduanliang_qjtj") then --决斗成功
			local log = sgs.LogMessage()
			log.type = "$MouYi_success"
			log.from = effect.from
			log.to:append(effect.to)
			room:sendLog(log)
			room:broadcastSkillInvoke(self:objectName(), 3)
			local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
			duel:setSkillName("mouduanliangv")
			if not effect.from:isProhibited(effect.to, duel) then
				room:useCard(sgs.CardUseStruct(duel, effect.from, effect.to))
			else
				duel:deleteLater()
			end
		else
			--“谋弈”失败
			local log = sgs.LogMessage()
			log.type = "$MouYi_fail"
			log.from = effect.from
			log.to:append(effect.to)
			room:sendLog(log)
			room:broadcastSkillInvoke(self:objectName(), 4)
		end
		if effect.from:hasFlag("mouduanliang_wcdl") then room:setPlayerFlag(effect.from, "-mouduanliang_wcdl") end
		if effect.from:hasFlag("mouduanliang_lgjj") then room:setPlayerFlag(effect.from, "-mouduanliang_lgjj") end
		if effect.to:hasFlag("mouduanliang_qjtj") then room:setPlayerFlag(effect.to, "-mouduanliang_qjtj") end
		if effect.to:hasFlag("mouduanliang_bmsc") then room:setPlayerFlag(effect.to, "-mouduanliang_bmsc") end
	end,
}
mouduanliangg = sgs.CreateZeroCardViewAsSkill {
	name = "mouduanliangg",
	view_as = function()
		return mouduanlianggCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#mouduanlianggCard")
	end,
}
mou_xuhuangg:addSkill(mouduanliangg)

moushipooCard = sgs.CreateSkillCard {
	name = "moushipooCard",
	target_fixed = false,
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		effect.to:obtainCard(self, false)
	end,
}
moushipooVS = sgs.CreateViewAsSkill {
	name = "moushipoo",
	n = 999,
	expand_pile = "moushipoo",
	view_filter = function(self, selected, to_select)
		return sgs.Self:getPile("moushipoo"):contains(to_select:getId())
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local msp_card = moushipooCard:clone()
			for _, card in ipairs(cards) do
				msp_card:addSubcard(card)
			end
			return msp_card
		end
		return nil
	end,
	response_pattern = "@@moushipoo",
}
moushipoo = sgs.CreateTriggerSkill {
	name = "moushipoo",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseProceeding },
	view_as_skill = moushipooVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase ~= sgs.Player_Finish then return false end
		for _, xd in sgs.qlist(room:getOtherPlayers(player)) do
			if xd:getHp() < player:getHp() then
				room:setPlayerFlag(xd, "moushipooWXTarget")
				if not player:hasFlag("moushipooWXSource") then room:setPlayerFlag(player, "moushipooWXSource") end
			end
		end
		for _, dj in sgs.qlist(room:getOtherPlayers(player)) do
			if dj:getJudgingArea():length() > 0 then
				for _, s in sgs.qlist(dj:getJudgingArea()) do
					if s:isKindOf("SupplyShortage") then
						room:setPlayerFlag(dj, "moushipooXGTarget")
						if not player:hasFlag("moushipooXGSource") then room:setPlayerFlag(player, "moushipooXGSource") end
					end
				end
			end
		end
		if not player:hasFlag("moushipooWXSource") and not player:hasFlag("moushipooXGSource") then return false end
		if room:askForSkillInvoke(player, self:objectName(), data) then
			local choices = {}
			if player:hasFlag("moushipooWXSource") then
				table.insert(choices, "1")
			end
			if player:hasFlag("moushipooXGSource") then
				table.insert(choices, "2")
			end
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))

			if choice == "1" then
				local XiaoDi = sgs.SPlayerList()
				for _, x in sgs.qlist(room:getOtherPlayers(player)) do
					if x:hasFlag("moushipooWXTarget") then
						XiaoDi:append(x)
						room:setPlayerFlag(x, "-moushipooWXTarget")
					end
				end
				local to = room:askForPlayerChosen(player, XiaoDi, self:objectName(), "moushipoo_KHxd")
				room:broadcastSkillInvoke(self:objectName(), 1)
				local choicee = room:askForChoice(to, self:objectName(), "3+4")
				if choicee == "3" and not to:isKongcheng() then
					local baohufei = room:askForExchange(to, self:objectName(), 1, 1, false,
						"#moushipoo:" .. player:getGeneralName())
					if baohufei then
						room:obtainCard(player, baohufei,
							sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), to:objectName(),
								self:objectName(), ""), false)
						if room:askForSkillInvoke(player, "@moushipoo-give", data) then
							local gt = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(),
								"moushipoo_givecards")
							room:obtainCard(gt, baohufei, false) --因为只选择了一名角色从而只会获得一张，故直接给该牌即可
						end
					end
				elseif choicee == "4" then
					room:damage(sgs.DamageStruct(self:objectName(), player, to, 1, sgs.DamageStruct_Normal))
				end
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do --清除另一个选项用到的标志
					if p:getMark("-moushipooXGTarget") > 0 then
						room:setPlayerFlag(p, "-moushipooXGTarget")
					end
				end
			elseif choice == "2" then
				room:broadcastSkillInvoke(self:objectName(), 2)
				local DiJun = sgs.SPlayerList()
				for _, d in sgs.qlist(room:getOtherPlayers(player)) do
					if d:hasFlag("moushipooXGTarget") then
						DiJun:append(d)
						room:setPlayerFlag(d, "-moushipooXGTarget")
					end
				end
				for _, p in sgs.qlist(DiJun) do
					local choicee = room:askForChoice(p, self:objectName(), "3+4")
					if choicee == "3" and not p:isKongcheng() then
						local baohufei = room:askForExchange(p, self:objectName(), 1, 1, false,
							"#moushipoo:" .. player:getGeneralName())
						if baohufei then
							room:obtainCard(player, baohufei,
								sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), p:objectName(),
									self:objectName(), ""), false)
							player:addToPile(self:objectName(), baohufei, false)
						end
					elseif choicee == "4" then
						room:damage(sgs.DamageStruct(self:objectName(), player, p, 1, sgs.DamageStruct_Normal))
					end
				end
				if player:getPile(self:objectName()):length() > 0 then
					if room:askForSkillInvoke(player, "@moushipoo-give", data) then
						room:askForUseCard(player, "@@moushipoo", "@moushipoo-card")
					end
				end
				if player:getPile(self:objectName()):length() > 0 then
					local dummy = sgs.Sanguosha:cloneCard("slash")
					dummy:addSubcards(player:getPile(self:objectName()))
					room:obtainCard(player, dummy, false)
					dummy:deleteLater()
				end
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do --清除另一个选项用到的标志
					if p:getMark("-moushipooWXTarget") > 0 then
						room:setPlayerFlag(p, "-moushipooWXTarget")
					end
				end
			end
		end
	end,
}
mou_xuhuangg:addSkill(moushipoo)

--

--谋于禁-初版
mou_yujin_first = sgs.General(extension, "mou_yujin_first", "wei", 4, true)

mouxieyuann = sgs.CreateTriggerSkill {
	name = "mouxieyuann",
	global = true,
	priority = { 100, 100 },
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.DamageInflicted, sgs.Damaged, sgs.RoundStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DamageInflicted then
			if player:getHujia() > 0 then
				local myjf = room:findPlayerBySkillName(self:objectName())
				if not myjf then return false end
				local n = player:getHujia()
				room:setPlayerMark(player, "mouxieyuann_hujiaCount", n)
			end
		elseif event == sgs.Damaged then
			if player:getMark("mouxieyuann_hujiaCount") > 0 then
				if player:getHujia() == 0 then
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if p:hasSkill(self:objectName()) and p:getHandcardNum() >= 2 and p:getMark(self:objectName()) == 0 then
							if not room:askForSkillInvoke(p, self:objectName(), data) then continue end
							room:askForDiscard(p, self:objectName(), 2, 2)
							room:broadcastSkillInvoke(self:objectName())
							local n = player:getMark("mouxieyuann_hujiaCount")
							player:gainHujia(n)
							room:setPlayerMark(player, "mouxieyuann_hujiaCount", 0)
							room:addPlayerMark(p, self:objectName())
						end
					end
				end
			else
				room:setPlayerMark(player, "mouxieyuann_hujiaCount", 0)
			end
		elseif event == sgs.RoundStart then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, self:objectName(), 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_yujin_first:addSkill(mouxieyuann)

moujieyuee = sgs.CreateTriggerSkill {
	name = "moujieyuee",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseProceeding },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase ~= sgs.Player_Finish then
			return false
		end
		if room:askForSkillInvoke(player, self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName())
			local tzs = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(),
				"moujieyuee-givehujia")
			tzs:gainHujia(1)
			room:drawCards(tzs, 2, self:objectName())
			local card = room:askForExchange(tzs, self:objectName(), 2, 2, true, "#moujieyuee:" ..
				player:getGeneralName())
			if card then
				room:obtainCard(player, card,
					sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), tzs:objectName(),
						self:objectName(), ""), false)
			end
		end
	end,
}
mou_yujin_first:addSkill(moujieyuee)

--FC文鸯
fc_wenyang = sgs.General(extension, "fc_wenyang", "wei+wu", 4, true)

local function fcquediCandiscard(player)
	if player:isDead() then return false end
	local can_dis = false
	for _, c in sgs.qlist(player:getHandcards()) do
		if c:isKindOf("BasicCard") and player:canDiscard(player, c:getEffectiveId()) then
			can_dis = true
			break
		end
	end
	return can_dis
end
fcquedi = sgs.CreateTriggerSkill {
	name = "fcquedi",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.TargetSpecified },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (player:getMark("fcbozheWeiMoreQuedi") == 0 and (player:getMark("fcquediUsed-Clear") > player:getMark("&fcchoujue-Clear")))
			or (player:getMark("fcbozheWeiMoreQuedi") > 0 and (player:getMark("fcquediUsed-Clear") > player:getMark("&fcchoujue-Clear") + 1))
		then
			return false
		end
		if not room:hasCurrent() then return false end
		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") and not use.card:isKindOf("Duel") then return false end
		if use.to:length() ~= 1 then return false end
		if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
		local choices, to = {}, use.to:first()
		if not to:isKongcheng() then
			table.insert(choices, "obtain=" .. to:objectName())
		end
		if fcquediCandiscard(player) then
			table.insert(choices, "damage")
		end
		table.insert(choices, "beishui")
		room:broadcastSkillInvoke(self)
		player:addMark("fcquediUsed-Clear")
		local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"), data)
		if choice == "damage" then
			if fcquediCandiscard(player) then
				room:askForDiscard(player, self:objectName(), 1, 1, false, false, "@fcquedi-basic", "BasicCard")
				room:setCardFlag(use.card, "fcquediDamage")
			end
		elseif choice == "beishui" then
			if player:isDead() then return false end
			room:loseMaxHp(player)
			if player:isDead() then return false end
			if not to:isKongcheng() then
				local id = room:askForCardChosen(player, to, "h", self:objectName())
				player:obtainCard(sgs.Sanguosha:getCard(id), false)
			end
			if player:isDead() then return false end
			if fcquediCandiscard(player) then
				room:askForDiscard(player, self:objectName(), 1, 1, false, false, "@fcquedi-basic", "BasicCard")
				room:setCardFlag(use.card, "fcquediDamage")
			end
		else
			if not to:isKongcheng() then
				local id = room:askForCardChosen(player, to, "h", self:objectName())
				player:obtainCard(sgs.Sanguosha:getCard(id), false)
			end
		end
	end,
}
fcquediDamage = sgs.CreateTriggerSkill {
	name = "fcquediDamage",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.DamageCaused },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if not damage.card or (not damage.card:isKindOf("Slash") and not damage.card:isKindOf("Duel")) then return false end
		if not damage.card:hasFlag("fcquediDamage") then return false end
		damage.damage = damage.damage + 1
		data:setValue(damage)
	end,
	can_trigger = function(self, player)
		return player
	end,
}
fc_wenyang:addSkill(fcquedi)
if not sgs.Sanguosha:getSkill("fcquediDamage") then skills:append(fcquediDamage) end

fcchoujue = sgs.CreateTriggerSkill {
	name = "fcchoujue",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.Death },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		if death.who:objectName() == player:objectName() then return false end
		if death.damage and death.damage.from and death.damage.from:objectName() == player:objectName() then
			room:sendCompulsoryTriggerLog(player, self)
			room:gainMaxHp(player)
			player:drawCards(2, self:objectName())
			if room:hasCurrent() and player:isAlive() then
				room:addPlayerMark(player, "&fcchoujue-Clear")
			end
		end
	end,
}
fc_wenyang:addSkill(fcchoujue)

fcchuifengCard = sgs.CreateSkillCard {
	name = "fcchuifengCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and
			not to_select:isProhibited(to_select, duel)
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		duel:setSkillName("fcchuifeng")
		if not effect.from:isCardLimited(duel, sgs.Card_MethodUse) and not effect.from:isProhibited(effect.to, duel) then
			room:loseHp(effect.from, 1)
			room:useCard(sgs.CardUseStruct(duel, effect.from, effect.to))
		else
			duel:deleteLater()
		end
	end,
}
fcchuifeng = sgs.CreateZeroCardViewAsSkill {
	name = "fcchuifeng",
	view_as = function()
		return fcchuifengCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:usedTimes("#fcchuifengCard") < 2 and not player:hasFlag("fcchuifengEnd")
	end,
	enabled_at_response = function(self, player, pattern)
		return string.find(pattern, "Duel")
	end,
}
fcchuifengDamaged = sgs.CreateTriggerSkill {
	name = "fcchuifengDamaged",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.DamageInflicted, sgs.EventPhaseEnd },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DamageInflicted then
			local damage = data:toDamage()
			if damage.card:isKindOf("Duel") and damage.card:getSkillName() == "fcchuifeng" then
				room:sendCompulsoryTriggerLog(player, "fcchuifeng")
				room:broadcastSkillInvoke("fcchuifeng")
				room:setPlayerFlag(player, "fcchuifengEnd")
				return true
			end
		elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Play then
			if player:hasFlag("fcchuifengEnd") then
				room:setPlayerFlag(player, "-fcchuifengEnd")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("fcchuifeng")
	end,
}
fc_wenyang:addSkill(fcchuifeng)
if not sgs.Sanguosha:getSkill("fcchuifengDamaged") then skills:append(fcchuifengDamaged) end

fcchongjianCard = sgs.CreateSkillCard {
	name = "fcchongjianCard",
	handling_method = sgs.Card_MethodUse,
	filter = function(self, targets, to_select)
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card, user_string = nil, self:getUserString()
			if user_string ~= "" then
				card = sgs.Sanguosha:cloneCard(user_string:split("+")[1])
				card:addSubcard(self)
				card:setSkillName("_fcchongjian")
			end
			return card and card:targetFilter(qtargets, to_select, sgs.Self) and
				not sgs.Self:isProhibited(to_select, card, qtargets)
		end
		local card = sgs.Self:getTag("fcchongjian"):toCard()
		card:addSubcard(self)
		card:setSkillName("_fcchongjian")
		if card and card:targetFixed() then
			return card:isAvailable(sgs.Self)
		end
		return card and card:targetFilter(qtargets, to_select, sgs.Self) and
			not sgs.Self:isProhibited(to_select, card, qtargets)
	end,
	feasible = function(self, targets)
		local card = sgs.Self:getTag("fcchongjian"):toCard()
		if card then
			card:setSkillName("_fcchongjian")
			card:addSubcard(self)
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetsFeasible(qtargets, sgs.Self)
	end,
	on_validate = function(self, cardUse)
		local source = cardUse.from
		local room = source:getRoom()
		local user_string = self:getUserString()
		if (string.find(user_string, "slash") or string.find(user_string, "Slash")) and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local slashs = sgs.Sanguosha:getSlashNames()
			user_string = room:askForChoice(source, "fcchongjian", table.concat(slashs, "+"))
		end
		local use_card = sgs.Sanguosha:cloneCard(user_string, self:getSuit(), self:getNumber())
		if not use_card then return nil end
		use_card:setSkillName("fcchongjian")
		use_card:addSubcard(self)
		use_card:deleteLater()
		return use_card
	end,
	on_validate_in_response = function(self, source)
		local room = source:getRoom()
		local user_string = self:getUserString()
		if user_string == "peach+analeptic" then
			user_string = "analeptic"
		end
		local use_card = sgs.Sanguosha:cloneCard(user_string, self:getSuit(), self:getNumber())
		if not use_card then return nil end
		use_card:setSkillName("fcchongjian")
		use_card:addSubcard(self)
		use_card:deleteLater()
		return use_card
	end,
}
fcchongjian = sgs.CreateOneCardViewAsSkill {
	name = "fcchongjian",
	response_or_use = true,
	filter_pattern = "EquipCard",
	view_as = function(self, card)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or
			sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local c = fcchongjianCard:clone()
			c:addSubcard(card)
			c:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			return c
		end
		local ccc = sgs.Self:getTag("fcchongjian"):toCard()
		if ccc and ccc:isAvailable(sgs.Self) then
			local c = fcchongjianCard:clone()
			c:setUserString(ccc:objectName())
			c:addSubcard(card)
			return c
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return true
	end,
	enabled_at_response = function(self, player, pattern)
		return string.find(pattern, "slash") or string.find(pattern, "Slash") or string.find(pattern, "analeptic")
	end,
}
fcchongjian:setJuguanDialog("all_slashs,analeptic")
fcchongjianNL = sgs.CreateTargetModSkill {
	name = "fcchongjianNL",
	distance_limit_func = function(self, from, card)
		if card:isKindOf("Slash") and card:getSkillName() == "fcchongjian" then
			return 1000
		else
			return 0
		end
	end,
}
fcchongjianPFandPE = sgs.CreateTriggerSkill {
	name = "fcchongjianPFandPE",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardUsed, sgs.CardFinished, sgs.Damage },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.CardUsed and use.from:objectName() == player:objectName() and use.card:isKindOf("Slash") and use.card:getSkillName() == "fcchongjian" then
			player:setFlags("fcchongjianPFfrom")
			for _, p in sgs.qlist(use.to) do
				p:setFlags("fcchongjianPFto")
				room:addPlayerMark(p, "Armor_Nullified")
			end
		elseif event == sgs.CardFinished and use.card:isKindOf("Slash") then
			if not player:hasFlag("fcchongjianPFfrom") then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("fcchongjianPFto") then
					p:setFlags("-fcchongjianPFto")
					if p:getMark("Armor_Nullified") then
						room:removePlayerMark(p, "Armor_Nullified")
					end
				end
			end
			player:setFlags("-fcchongjianPFfrom")
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if not damage.card or damage.to:getEquips():length() == 0 or damage.card:getSkillName() ~= "fcchongjian" or not player:hasSkill("fcchongjian") then return false end
			local cj = damage.damage
			local n = 0
			local ec1 = room:askForCardChosen(player, damage.to, "e", "fcchongjian")
			room:obtainCard(player, ec1)
			n = n + 1
			if cj >= 2 and damage.to:getEquips():length() > 0 then
				local ec2 = room:askForCardChosen(player, damage.to, "e", "fcchongjian")
				room:obtainCard(player, ec2)
				n = n + 1
			end
			if cj >= 3 and damage.to:getEquips():length() > 0 then
				local ec3 = room:askForCardChosen(player, damage.to, "e", "fcchongjian")
				room:obtainCard(player, ec3)
				n = n + 1
			end
			if cj >= 4 and damage.to:getEquips():length() > 0 then
				local ec4 = room:askForCardChosen(player, damage.to, "e", "fcchongjian")
				room:obtainCard(player, ec4)
				n = n + 1
			end
			if cj >= 5 and damage.to:getEquips():length() > 0 then
				local ec5 = room:askForCardChosen(player, damage.to, "e", "fcchongjian")
				room:obtainCard(player, ec5)
				n = n + 1
			end
			local log = sgs.LogMessage()
			log.type = "$fcchongjianPlunderEquips"
			log.from = player
			log.to:append(damage.to)
			log.arg2 = n
			room:sendLog(log)
			room:broadcastSkillInvoke("fcchongjian")
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
fc_wenyang:addSkill(fcchongjian)
if not sgs.Sanguosha:getSkill("fcchongjianNL") then skills:append(fcchongjianNL) end
if not sgs.Sanguosha:getSkill("fcchongjianPFandPE") then skills:append(fcchongjianPFandPE) end

local function isSpecialOne(player, name)
	local g_name = sgs.Sanguosha:translate(player:getGeneralName())
	if string.find(g_name, name) then return true end
	if player:getGeneral2() then
		g_name = sgs.Sanguosha:translate(player:getGeneral2Name())
		if string.find(g_name, name) then return true end
	end
	return false
end
fcbozhe = sgs.CreateTriggerSkill {
	name = "fcbozhe",
	priority = { -3, -3, -3 },
	frequency = sgs.Skill_Compulsory,
	events = { sgs.GameStart, sgs.ConfirmDamage, sgs.TargetSpecified },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			local lord = room:getLord()
			if lord:getKingdom() == "wei" and player:getKingdom() == "wei" and player:hasSkill("fcquedi") then
				room:broadcastSkillInvoke(self:objectName(), 1)
				--sgs.Sanguosha:addTranslationEntry(":fcquedi", "" .. string.gsub(sgs.Sanguosha:translate(":fcquedi"), sgs.Sanguosha:translate(":fcquedi"), sgs.Sanguosha:translate(":fcquedii")))
				room:addPlayerMark(player, "fcbozheWeiMoreQuedi")
			elseif lord:getKingdom() == "jin" and room:askForSkillInvoke(player, "@fcbozhe-ChangeToJin", data) then
				room:broadcastSkillInvoke(self:objectName(), 4)
				room:setPlayerProperty(player, "kingdom", sgs.QVariant("jin"))
			end
			if player:getKingdom() == "wu" then
				room:broadcastSkillInvoke(self:objectName(), 3)
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if player:getKingdom() == "wei" and (damage.to:getKingdom() == "jin" or isSpecialOne(damage.to, "司马") and damage.card:isKindOf("BasicCard")) then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), 2)
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		elseif event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.card:isKindOf("TrickCard") and player:getKingdom() == "wei" then
				local no_respond_list = use.no_respond_list
				for _, sm in sgs.qlist(use.to) do
					if (sm:getKingdom() == "jin" or isSpecialOne(sm, "司马")) then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:broadcastSkillInvoke(self:objectName(), 2)
						table.insert(no_respond_list, sm:objectName())
					end
				end
				use.no_respond_list = no_respond_list
				data:setValue(use)
			end
		end
	end,
}
fcbozheWU = sgs.CreateDistanceSkill {
	name = "fcbozheWU",
	correct_func = function(self, from, to)
		if from:hasSkill("fcbozhe") and from:getKingdom() == "wu" and (to:getKingdom() == "wei" or to:getKingdom() == "jin") then
			return -1000
		else
			return 0
		end
	end,
}
fcbozheJIN = sgs.CreateTargetModSkill {
	name = "fcbozheJIN",
	pattern = "Card",
	residue_func = function(self, from, card, to)
		if from:hasSkill("fcbozhe") and from:getKingdom() == "jin" and to and to:getKingdom() ~= "jin" then
			return 1000
		else
			return 0
		end
	end,
}
fc_wenyang:addSkill(fcbozhe)
if not sgs.Sanguosha:getSkill("fcbozheWU") then skills:append(fcbozheWU) end
if not sgs.Sanguosha:getSkill("fcbozheJIN") then skills:append(fcbozheJIN) end

--

--阴间之王
--手杀界徐盛(大宝)+谋黄忠(老宝)
TheKingOfUnderworld = sgs.General(extension, "TheKingOfUnderworld", "wu+shu", 4, true)

--载入技能“手杀界破军”
TheKingOfUnderworld:addSkill("mobilepojun")
--载入技能“(手杀)谋烈弓”
TheKingOfUnderworld:addSkill("mouliegongf")

dabao_sunshineCard = sgs.CreateSkillCard {
	name = "dabao_sunshineCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets < 2
	end,
	on_use = function(self, room, source, targets)
		for _, p in pairs(targets) do
			if not p:isChained() then
				room:setPlayerChained(p)
			end
		end
	end,
}
dabao_sunshineVS = sgs.CreateZeroCardViewAsSkill {
	name = "dabao_sunshine",
	view_as = function()
		return dabao_sunshineCard:clone()
	end,
	response_pattern = "@@dabao_sunshine",
}
dabao_sunshine = sgs.CreateTriggerSkill {
	name = "dabao_sunshine",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart },
	view_as_skill = dabao_sunshineVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getKingdom() ~= "wu" then return false end
		if player:getPhase() == sgs.Player_Start and room:askForSkillInvoke(player, self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName())
			local choice = room:askForChoice(player, self:objectName(), "mathrandom+allin")
			if choice == "mathrandom" then
				local n = math.random(1, 4)
				if n == 1 then
					room:askForUseCard(player, "@@dabao_sunshine", "@dabao_sunshine-Chain")
				elseif n == 2 then
					local analeptic = sgs.Sanguosha:cloneCard("Analeptic", sgs.Card_NoSuit, 0)
					analeptic:setSkillName("dabao_sunshine")
					room:useCard(sgs.CardUseStruct(analeptic, player, player, false))
				elseif n == 3 then
					room:setPlayerFlag(player, "dabao_GuDing")
				elseif n == 4 then
					room:setPlayerFlag(player, "dabao_Nature")
				end
			else
				room:askForUseCard(player, "@@dabao_sunshine", "@dabao_sunshine-Chain")
				local analeptic = sgs.Sanguosha:cloneCard("Analeptic", sgs.Card_NoSuit, 0)
				analeptic:setSkillName("dabao_sunshine")
				room:useCard(sgs.CardUseStruct(analeptic, player, player, false))
				room:setPlayerFlag(player, "dabao_GuDing")
				room:setPlayerFlag(player, "dabao_Nature")
				room:loseHp(player, 4)
			end
		end
	end,
}
dabao_GuDing = sgs.CreateTriggerSkill {
	name = "dabao_GuDing",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.ConfirmDamage },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.to:isKongcheng() then
			room:sendCompulsoryTriggerLog(player, "dabao_sunshine")
			local n = math.random(0, 2)
			if n == 0 then
				room:broadcastSkillInvoke("mobilepojun", 1)
				room:broadcastSkillInvoke("mobilepojun", 1)
				room:broadcastSkillInvoke("mobilepojun", 1)
			elseif n == 1 then
				room:broadcastSkillInvoke("mobilepojun", 2)
				room:broadcastSkillInvoke("mobilepojun", 2)
				room:broadcastSkillInvoke("mobilepojun", 2)
			elseif n == 2 then
				room:broadcastSkillInvoke("dabao_sunshine")
				room:broadcastSkillInvoke("dabao_sunshine")
				room:broadcastSkillInvoke("dabao_sunshine")
			end
			damage.damage = damage.damage + 1
			data:setValue(damage)
		end
	end,
	can_trigger = function(self, player)
		return player and player:hasFlag(self:objectName())
	end,
}
dabao_Nature = sgs.CreateTriggerSkill {
	name = "dabao_Nature",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.ChangeSlash },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") and use.card:isRed() then
			local fs = sgs.Sanguosha:cloneCard("fire_slash")
			fs:setSkillName(self:objectName())
			fs:addSubcards(use.card:getSubcards())
			use.card = fs
			data:setValue(use)
		elseif use.card:isKindOf("Slash") and use.card:isBlack() then
			local ts = sgs.Sanguosha:cloneCard("thunder_slash")
			ts:setSkillName(self:objectName())
			ts:addSubcards(use.card:getSubcards())
			use.card = ts
			data:setValue(use)
		end
	end,
	can_trigger = function(self, player)
		return player:hasFlag(self:objectName())
	end,
}
TheKingOfUnderworld:addSkill(dabao_sunshine)
if not sgs.Sanguosha:getSkill("dabao_GuDing") then skills:append(dabao_GuDing) end
if not sgs.Sanguosha:getSkill("dabao_Nature") then skills:append(dabao_Nature) end

laobao_heai = sgs.CreateTriggerSkill {
	name = "laobao_heai",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getKingdom() ~= "shu" then return false end
		if player:getPhase() == sgs.Player_Start and room:askForSkillInvoke(player, self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName())
			local choices = {}
			if not (player:getMark("&mouliegongf+heart") == 0 and player:getMark("&mouliegongf+diamond") == 0
					and player:getMark("&mouliegongf+club") == 0 and player:getMark("&mouliegongf+spade") == 0) then
				table.insert(choices, "remove")
			end
			if not (player:getMark("&mouliegongf+heart") > 0 and player:getMark("&mouliegongf+diamond") > 0
					and player:getMark("&mouliegongf+club") > 0 and player:getMark("&mouliegongf+spade") > 0) then
				table.insert(choices, "record")
			end
			if player:getMark("&mouliegongf+heart") > 0 and player:getMark("&mouliegongf+diamond") > 0
				and player:getMark("&mouliegongf+club") > 0 and player:getMark("&mouliegongf+spade") > 0 then
				table.insert(choices, "allin")
			end
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "remove" then
				local choicess = {}
				if player:getMark("&mouliegongf+heart") > 0 then
					table.insert(choicess, "removeHeart")
				end
				if player:getMark("&mouliegongf+diamond") > 0 then
					table.insert(choicess, "removeDiamond")
				end
				if player:getMark("&mouliegongf+club") > 0 then
					table.insert(choicess, "removeClub")
				end
				if player:getMark("&mouliegongf+spade") > 0 then
					table.insert(choicess, "removeSpade")
				end
				local choicee = room:askForChoice(player, self:objectName(), table.concat(choicess, "+"))
				if choicee == "removeHeart" then
					room:removePlayerMark(player, "&mouliegongf+heart")
					local peach = sgs.Sanguosha:cloneCard("Peach", sgs.Card_NoSuit, 0)
					peach:setSkillName("laobao_heaii")
					room:useCard(sgs.CardUseStruct(peach, player, player, false))
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						room:setPlayerFlag(p, "laobao_heai_cantusePeach")
						room:setPlayerCardLimitation(p, "use", "Peach", false)
					end
				elseif choicee == "removeDiamond" then
					room:removePlayerMark(player, "&mouliegongf+diamond")
					room:setPlayerFlag(player, "mouliegongf_RMtargetlimit")
				elseif choicee == "removeClub" then
					room:removePlayerMark(player, "&mouliegongf+club")
					room:setPlayerFlag(player, "mouliegongf_RMnaturelimit")
				elseif choicee == "removeSpade" then
					room:removePlayerMark(player, "&mouliegongf+spade")
					room:setPlayerFlag(player, "mouliegongf_nolimit")
				end
			elseif choice == "record" then
				local choicess = {}
				if player:getMark("&mouliegongf+heart") == 0 then
					table.insert(choicess, "recordHeart")
				end
				if player:getMark("&mouliegongf+diamond") == 0 then
					table.insert(choicess, "recordDiamond")
				end
				if player:getMark("&mouliegongf+club") == 0 then
					table.insert(choicess, "recordClub")
				end
				if player:getMark("&mouliegongf+spade") == 0 then
					table.insert(choicess, "recordSpade")
				end
				local choicee = room:askForChoice(player, self:objectName(), table.concat(choicess, "+"))
				if choicee == "recordHeart" then
					room:addPlayerMark(player, "&mouliegongf+heart")
				elseif choicee == "recordDiamond" then
					room:addPlayerMark(player, "&mouliegongf+diamond")
				elseif choicee == "recordClub" then
					room:addPlayerMark(player, "&mouliegongf+club")
				elseif choicee == "recordSpade" then
					room:addPlayerMark(player, "&mouliegongf+spade")
				end
			else
				room:removePlayerMark(player, "&mouliegongf+heart")
				room:removePlayerMark(player, "&mouliegongf+diamond")
				room:removePlayerMark(player, "&mouliegongf+club")
				room:removePlayerMark(player, "&mouliegongf+spade")
				local peach = sgs.Sanguosha:cloneCard("Peach", sgs.Card_NoSuit, 0)
				peach:setSkillName("laobao_heaii")
				room:useCard(sgs.CardUseStruct(peach, player, player, false))
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					room:setPlayerFlag(p, "laobao_heai_cantusePeach")
					room:setPlayerCardLimitation(p, "use", "Peach", false)
				end
				room:setPlayerFlag(player, "mouliegongf_RMtargetlimit")
				room:setPlayerFlag(player, "mouliegongf_RMnaturelimit")
				room:setPlayerFlag(player, "mouliegongf_nolimit")
				room:drawCards(player, 4, self:objectName())
			end
		end
	end,
}
laobao_heaiDS = sgs.CreateTargetModSkill {
	name = "laobao_heaiDS",
	extra_target_func = function(self, from, card, to)
		if from:hasSkill("laobao_heai") and from:hasFlag("mouliegongf_RMtargetlimit") and card:isKindOf("Slash") then
			return 1
		else
			return 0
		end
	end,
	distance_limit_func = function(self, from, card, to)
		if from:hasSkill("laobao_heai") and from:hasFlag("mouliegongf_nolimit") and card:isKindOf("Slash") then
			return 1000
		else
			return 0
		end
	end,
}
laobao_heaiC = sgs.CreateTriggerSkill {
	name = "laobao_heaiC",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardUsed, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if not (use.card:isKindOf("FireSlash") or use.card:isKindOf("ThunderSlash") or use.card:isKindOf("IceSlash"))
				or not player:hasFlag("mouliegongf_RMnaturelimit") then
				return false
			end
			if use.m_addHistory then
				room:addPlayerHistory(player, use.card:getClassName(), -1)
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("laobao_heai_cantusePeach") then
					room:setPlayerFlag(p, "-laobao_heai_cantusePeach")
					room:removePlayerCardLimitation(p, "use", "Peach")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
TheKingOfUnderworld:addSkill(laobao_heai)
if not sgs.Sanguosha:getSkill("laobao_heaiDS") then skills:append(laobao_heaiDS) end
if not sgs.Sanguosha:getSkill("laobao_heaiC") then skills:append(laobao_heaiC) end

--谋黄忠-七天体验卡 垃圾话加载中......
--[[mou_huangzhongg_TrashTalk = sgs.CreateTriggerSkill{
    name = "mou_huangzhongg_TrashTalk",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		
	end,
	can_trigger = function(self, player)
	    return player:getGeneralName() == "mou_huangzhongg" or player:getGeneral2Name() == "mou_huangzhongg"
	end,
}]]





--

--谋·贾逵
--mou_jk = sgs.General(extension, "mou_jk", "wei", 3, true)
mou_jk = sgs.General(extension, "mou_jk", "wei", 3, true, false, false, 3, 2)

mouwl = sgs.CreateTriggerSkill {
	name = "mouwl",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardUsed, sgs.CardResponded, sgs.TurnStart },
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
			if card and card:getHandlingMethod() == sgs.Card_MethodUse and player:hasSkill(self:objectName()) then
				if card:isRed() then
					if player:getMark("mouwl_redused") > 0 then return false end
					local players = sgs.SPlayerList()
					for _, p in sgs.qlist(room:getAllPlayers()) do
						if p:getHp() <= player:getHp() then
							players:append(p)
						end
					end
					if players:isEmpty() then return false end
					local to = room:askForPlayerChosen(player, players, "@mouwlRD", "mouwl_reddraw", true, true)
					if to then
						room:drawCards(to, 1, self:objectName())
						room:broadcastSkillInvoke(self:objectName(), 1)
						room:addPlayerMark(player, "mouwl_redused")
					end
				elseif card:isBlack() then
					if player:getMark("mouwl_blackused") > 0 then return false end
					local players = sgs.SPlayerList()
					for _, p in sgs.qlist(room:getAllPlayers()) do
						if p:getHp() > player:getHp() and not p:isNude() and player:canDiscard(p, "he") then
							players:append(p)
						end
					end
					if players:isEmpty() then return false end
					local to = room:askForPlayerChosen(player, players, "@mouwlBT", "mouwl_blackthrow", true, true)
					if to then
						local card = room:askForCardChosen(player, to, "he", self:objectName(), false,
							sgs.Card_MethodDiscard)
						room:throwCard(card, to, player)
						room:broadcastSkillInvoke(self:objectName(), 2)
						room:addPlayerMark(player, "mouwl_blackused")
					end
				end
			end
		elseif event == sgs.TurnStart then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "mouwl_redused", 0)
				room:setPlayerMark(p, "mouwl_blackused", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_jk:addSkill(mouwl)

--

--谋曹操
mou_doublefuck = sgs.General(extension, "mou_doublefuck$", "wei", 4, true)

moujianxionggCard = sgs.CreateSkillCard {
	name = "moujianxionggCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		source:loseMark("&mouGW", 1)
	end,
}
moujianxionggVS = sgs.CreateZeroCardViewAsSkill {
	name = "moujianxiongg",
	view_as = function()
		return moujianxionggCard:clone()
	end,
	response_pattern = "@@moujianxiongg",
}
moujianxiongg = sgs.CreateTriggerSkill {
	name = "moujianxiongg",
	frequency = sgs.Skill_Frequent,
	events = { sgs.GameStart, sgs.Damaged },
	view_as_skill = moujianxionggVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			local choice = room:askForChoice(player, "@moujx_getMarks", "0+1+2")
			if choice == "1" then
				player:gainMark("&mouGW", 1)
			elseif choice == "2" then
				player:gainMark("&mouGW", 2)
			end
			room:broadcastSkillInvoke(self:objectName())
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			if damage.to:objectName() ~= player:objectName() then return false end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			if damage.card then
				local ids = sgs.IntList()
				if damage.card:isVirtualCard() then
					ids = damage.card:getSubcards()
				else
					ids:append(damage.card:getEffectiveId())
				end
				if ids:isEmpty() then return end
				for _, id in sgs.qlist(ids) do
					if room:getCardPlace(id) ~= sgs.Player_PlaceTable then return end
				end
				data:setValue(damage)
				room:obtainCard(player, damage.card)
			end
			local n = player:getMark("&mouGW")
			local m = 1 - n
			if m < 0 then m = 0 end
			if m > 0 then
				room:drawCards(player, m, self:objectName())
			end
			--调整标记
			if n > 0 then
				room:askForUseCard(player, "@@moujianxiongg", "@moujianxiongg-throwMark")
			end
		end
	end,
}
mou_doublefuck:addSkill(moujianxiongg)

mouqingzhenggCard = sgs.CreateSkillCard {
	name = "mouqingzhenggCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		source:gainMark("&mouGW", 1)
	end,
}
mouqingzhenggVS = sgs.CreateZeroCardViewAsSkill {
	name = "mouqingzhengg",
	view_as = function()
		return mouqingzhenggCard:clone()
	end,
	response_pattern = "@@mouqingzhengg",
}
mouqingzhengg = sgs.CreateTriggerSkill {
	name = "mouqingzhengg",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart },
	view_as_skill = mouqingzhenggVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play then
			for _, c in sgs.qlist(player:getHandcards()) do
				if c:getSuit() == sgs.Card_Heart then room:addPlayerMark(player, "mouqz_heart") end
				if c:getSuit() == sgs.Card_Diamond then room:addPlayerMark(player, "mouqz_diamond") end
				if c:getSuit() == sgs.Card_Club then room:addPlayerMark(player, "mouqz_club") end
				if c:getSuit() == sgs.Card_Spade then room:addPlayerMark(player, "mouqz_spade") end
			end
			local s = 0
			if player:getMark("mouqz_heart") > 0 then s = s + 1 end
			if player:getMark("mouqz_diamond") > 0 then s = s + 1 end
			if player:getMark("mouqz_club") > 0 then s = s + 1 end
			if player:getMark("mouqz_spade") > 0 then s = s + 1 end
			local n = player:getMark("&mouGW")
			local m = 3 - n
			if m < 1 then m = 1 end
			if s >= m then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					--选择目标
					local others = sgs.SPlayerList()
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if not p:isKongcheng() then
							others:append(p)
						end
					end
					if others:isEmpty() then return false end
					local other = room:askForPlayerChosen(player, others, self:objectName(), "mouqingzhenggs")
					--自弃手牌
					while m > 0 do
						local choices = {}
						if player:getMark("mouqz_heart") > 0 then
							table.insert(choices, "heart")
						end
						if player:getMark("mouqz_diamond") > 0 then
							table.insert(choices, "diamond")
						end
						if player:getMark("mouqz_club") > 0 then
							table.insert(choices, "club")
						end
						if player:getMark("mouqz_spade") > 0 then
							table.insert(choices, "spade")
						end
						local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
						if choice == "heart" then
							room:setPlayerMark(player, "mouqz_heart", 0)
							room:addPlayerMark(player, "mouqz_heart_throw")
							m = m - 1
						elseif choice == "diamond" then
							room:setPlayerMark(player, "mouqz_diamond", 0)
							room:addPlayerMark(player, "mouqz_diamond_throw")
							m = m - 1
						elseif choice == "club" then
							room:setPlayerMark(player, "mouqz_club", 0)
							room:addPlayerMark(player, "mouqz_club_throw")
							m = m - 1
						elseif choice == "spade" then
							room:setPlayerMark(player, "mouqz_spade", 0)
							room:addPlayerMark(player, "mouqz_spade_throw")
							m = m - 1
						end
					end
					local x = 0
					local me_throw = sgs.IntList()
					for _, c in sgs.qlist(player:getHandcards()) do
						if (c:getSuit() == sgs.Card_Heart and player:getMark("mouqz_heart_throw") > 0)
							or (c:getSuit() == sgs.Card_Diamond and player:getMark("mouqz_diamond_throw") > 0)
							or (c:getSuit() == sgs.Card_Club and player:getMark("mouqz_club_throw") > 0)
							or (c:getSuit() == sgs.Card_Spade and player:getMark("mouqz_spade_throw") > 0) then
							me_throw:append(c:getEffectiveId())
						end
					end
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					if not me_throw:isEmpty() then
						for _, id in sgs.qlist(me_throw) do
							dummy:addSubcard(id)
							x = x + 1
						end
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(),
							self:objectName(), nil)
						room:throwCard(dummy, reason, player)
						room:broadcastSkillInvoke(self:objectName())
					end
					--观看目标手牌并弃置
					local ids = sgs.IntList()
					for _, c in sgs.qlist(other:getHandcards()) do
						if c:getSuit() == sgs.Card_Heart and not player:hasFlag("mouqz_heart") then
							room:setPlayerFlag(
								player, "mouqz_heart")
						end
						if c:getSuit() == sgs.Card_Diamond and not player:hasFlag("mouqz_diamond") then
							room
								:setPlayerFlag(player, "mouqz_diamond")
						end
						if c:getSuit() == sgs.Card_Club and not player:hasFlag("mouqz_club") then
							room:setPlayerFlag(
								player, "mouqz_club")
						end
						if c:getSuit() == sgs.Card_Spade and not player:hasFlag("mouqz_spade") then
							room:setPlayerFlag(
								player, "mouqz_spade")
						end
						if c then ids:append(c:getEffectiveId()) end
					end
					local card_id = room:doGongxin(player, other, ids)
					if card_id == 0 then return end
					local choicees = {}
					if player:hasFlag("mouqz_heart") then
						table.insert(choicees, "heart")
					end
					if player:hasFlag("mouqz_diamond") then
						table.insert(choicees, "diamond")
					end
					if player:hasFlag("mouqz_club") then
						table.insert(choicees, "club")
					end
					if player:hasFlag("mouqz_spade") then
						table.insert(choicees, "spade")
					end
					local choicee = room:askForChoice(player, self:objectName(), table.concat(choicees, "+"))
					if choicee == "heart" then
						room:setPlayerFlag(player, "-mouqz_heart")
						room:setPlayerFlag(player, "mouqz_heart_throw")
					elseif choicee == "diamond" then
						room:setPlayerFlag(player, "-mouqz_diamond")
						room:setPlayerFlag(player, "mouqz_diamond_throw")
					elseif choicee == "club" then
						room:setPlayerFlag(player, "-mouqz_club")
						room:setPlayerFlag(player, "mouqz_club_throw")
					elseif choicee == "spade" then
						room:setPlayerFlag(player, "-mouqz_spade")
						room:setPlayerFlag(player, "mouqz_spade_throw")
					end
					local y = 0
					local to_throw = sgs.IntList()
					for _, c in sgs.qlist(other:getHandcards()) do
						if (c:getSuit() == sgs.Card_Heart and player:hasFlag("mouqz_heart_throw"))
							or (c:getSuit() == sgs.Card_Diamond and player:hasFlag("mouqz_diamond_throw"))
							or (c:getSuit() == sgs.Card_Club and player:hasFlag("mouqz_club_throw"))
							or (c:getSuit() == sgs.Card_Spade and player:hasFlag("mouqz_spade_throw")) then
							to_throw:append(c:getEffectiveId())
						end
					end
					local dummi = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					if not to_throw:isEmpty() then
						for _, id in sgs.qlist(to_throw) do
							dummi:addSubcard(id)
							y = y + 1
						end
						local reasonn = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, player:objectName(),
							nil, self:objectName(), nil)
						room:throwCard(dummi, reasonn, other, player)
						room:broadcastSkillInvoke(self:objectName())
					end
					--造成伤害
					if x > y then
						room:damage(sgs.DamageStruct(self:objectName(), player, other))
						room:broadcastSkillInvoke(self:objectName())
					end
					--调整标记
					if n < 2 and player:hasSkill("moujianxiongg") then
						room:askForUseCard(player, "@@mouqingzhengg", "@mouqingzhengg-getMark")
					end
				end
			end
			--标记/标志大清除
			room:setPlayerMark(player, "mouqz_heart", 0)
			room:setPlayerMark(player, "mouqz_heart_throw", 0)
			room:setPlayerMark(player, "mouqz_diamond", 0)
			room:setPlayerMark(player, "mouqz_diamond_throw", 0)
			room:setPlayerMark(player, "mouqz_club", 0)
			room:setPlayerMark(player, "mouqz_club_throw", 0)
			room:setPlayerMark(player, "mouqz_spade", 0)
			room:setPlayerMark(player, "mouqz_spade_throw", 0)
			if player:hasFlag("mouqz_heart") then room:setPlayerFlag(player, "-mouqz_heart") end
			if player:hasFlag("mouqz_heart_throw") then room:setPlayerFlag(player, "-mouqz_heart_throw") end
			if player:hasFlag("mouqz_diamond") then room:setPlayerFlag(player, "-mouqz_diamond") end
			if player:hasFlag("mouqz_diamond_throw") then room:setPlayerFlag(player, "-mouqz_diamond_throw") end
			if player:hasFlag("mouqz_club") then room:setPlayerFlag(player, "-mouqz_club") end
			if player:hasFlag("mouqz_club_throw") then room:setPlayerFlag(player, "-mouqz_club_throw") end
			if player:hasFlag("mouqz_spade") then room:setPlayerFlag(player, "-mouqz_spade") end
			if player:hasFlag("mouqz_spade_throw") then room:setPlayerFlag(player, "-mouqz_spade_throw") end
		end
	end,
}
mou_doublefuck:addSkill(mouqingzhengg)

mouhujiaaCard = sgs.CreateSkillCard {
	name = "mouhujiaaCard",
	filter = function(self, selected, to_select)
		return #selected == 0 and to_select:getKingdom() == "wei" and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local damage = effect.from:getTag("mouhujiaaDamage"):toDamage()
		if damage.card and damage.card:isKindOf("Slash") then
			effect.from:removeQinggangTag(damage.card)
		end
		damage.to = effect.to
		damage.transfer = true
		room:damage(damage)
		room:addPlayerMark(effect.from, "mouhujiaa_lun")
	end,
}
mouhujiaaVS = sgs.CreateZeroCardViewAsSkill {
	name = "mouhujiaa",
	view_as = function()
		return mouhujiaaCard:clone()
	end,
	enabled_at_play = function()
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@mouhujiaa"
	end,
}
mouhujiaa = sgs.CreateTriggerSkill {
	name = "mouhujiaa$",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.DamageInflicted, sgs.RoundStart },
	view_as_skill = mouhujiaaVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DamageInflicted then
			if player:hasLordSkill(self:objectName()) and player:getMark(self:objectName()) == 0 then
				player:setTag("mouhujiaaDamage", data)
				if room:askForUseCard(player, "@@mouhujiaa", "@mouhujiaa-card") then
					return true
				end
			end
		elseif event == sgs.RoundStart then
			room:setPlayerMark(player, "mouhujiaa_lun", 0)
		end
	end,
}
mou_doublefuck:addSkill(mouhujiaa)

--

--谋甘宁-初版
mou_ganning_first = sgs.General(extension, "mou_ganning_first", "wu", 4, true)

mouqixii = sgs.CreateOneCardViewAsSkill {
	name = "mouqixii",
	filter_pattern = ".|black",
	view_as = function(self, card)
		local acard = sgs.Sanguosha:cloneCard("dismantlement", card:getSuit(), card:getNumber())
		acard:addSubcard(card:getId())
		acard:setSkillName(self:objectName())
		return acard
	end,
}
mouqixix = sgs.CreateTriggerSkill {
	name = "mouqixix",
	global = true,
	priority = 4, --保证抢先于原效果发动之前发动
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.CardEffected },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local effect = data:toCardEffect()
		if effect.card:isKindOf("Dismantlement") and not effect.card:isVirtualCard() and effect.to:objectName() == player:objectName() then
			local MGN = effect.from
			if not MGN:hasSkill("mouqixii") then return false end
			if room:askForSkillInvoke(MGN, "mouqixii", data) then
				if room:isCanceled(effect) then --给无懈的空间，不然要么是不能无懈直接扒光(优先级>=0)，要么是先执行原效果才能再执行新效果(优先级<0)
					player:setFlags("Global_NonSkillNullify")
					return true
				end
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				local cards = player:getCards("hej")
				for _, card in sgs.qlist(cards) do
					dummy:addSubcard(card)
				end
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, MGN:objectName(), nil,
					"mouqixii", nil)
				room:throwCard(dummy, reason, player, MGN)
				room:broadcastSkillInvoke("mouqixii")
				room:setTag("SkipGameRule", sgs.QVariant(true))
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_ganning_first:addSkill(mouqixii)
if not sgs.Sanguosha:getSkill("mouqixix") then skills:append(mouqixix) end

moufenweiiCard = sgs.CreateSkillCard {
	name = "moufenweiiCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return to_select:hasFlag("moufenweii")
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@moufenweii")
		room:doSuperLightbox("mou_ganning_first", "moufenweii")
		local n = 4
		for _, p in pairs(targets) do
			room:setPlayerFlag(p, "-moufenweii")
			if n > 0 then
				local moufenweii_cards = {}
				local moufenweii_one_basic_count = 0
				for _, id in sgs.qlist(room:getDrawPile()) do
					if sgs.Sanguosha:getCard(id):isKindOf("Dismantlement") and not table.contains(moufenweii_cards, id) and moufenweii_one_basic_count < 1 then
						moufenweii_one_basic_count = moufenweii_one_basic_count + 1
						table.insert(moufenweii_cards, id)
					end
				end
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, id in ipairs(moufenweii_cards) do
					dummy:addSubcard(id)
				end
				room:obtainCard(source, dummy, true)
				n = n - 1
			end
		end
	end,
}
moufenweiiVS = sgs.CreateZeroCardViewAsSkill {
	name = "moufenweii",
	view_as = function()
		return moufenweiiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@moufenweii") > 0 and player:hasFlag("moufenweii_CanUse")
	end,
	response_pattern = "@@moufenweii",
}
moufenweii = sgs.CreateTriggerSkill {
	name = "moufenweii",
	global = true,
	frequency = sgs.Skill_Limited,
	limit_mark = "@moufenweii",
	view_as_skill = moufenweiiVS,
	events = { sgs.CardUsed },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local mgns = room:findPlayersBySkillName(self:objectName())
		if not mgns then return false end
		local use = data:toCardUse()
		if use.card:isKindOf("TrickCard") and use.from and use.to:length() > 1 then
			for _, p in sgs.qlist(use.to) do
				room:setPlayerFlag(p, self:objectName()) --标记所有目标角色
			end
			for _, mgn in sgs.qlist(mgns) do
				if mgn:getMark("@moufenweii") > 0 then
					room:setPlayerFlag(mgn, "moufenweii_CanUse")
					if not room:askForUseCard(mgn, "@@moufenweii", "@moufenweii-card") then
						room:setPlayerFlag(mgn, "-moufenweii_CanUse")
					end
				end
			end

			for _, p in sgs.qlist(use.to) do
				if not p:hasFlag(self:objectName()) then --已经没有该标志了，说明被选为了“奋威”的目标
					local nullified_list = use.nullified_list
					table.insert(nullified_list, p:objectName())
					use.nullified_list = nullified_list
				else
					room:setPlayerFlag(p, "-moufenweii")
				end
			end
			data:setValue(use)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_ganning_first:addSkill(moufenweii)

--谋甘宁(重做版)
mou_ganningg = sgs.General(extension, "mou_ganningg", "wu", 4, true)

mouqixirCard = sgs.CreateSkillCard {
	name = "mouqixirCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and
			not to_select:isAllNude() --对着区域没牌的人发动技能有卵用，明牌吗
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local h, d, c, s = 0, 0, 0, 0
		for _, cd in sgs.qlist(effect.from:getHandcards()) do
			if cd:getSuit() == sgs.Card_Heart then h = h + 1 end
			if cd:getSuit() == sgs.Card_Diamond then d = d + 1 end
			if cd:getSuit() == sgs.Card_Club then c = c + 1 end
			if cd:getSuit() == sgs.Card_Spade then s = s + 1 end
		end
		if h >= d and h >= c and h >= s then room:setPlayerFlag(effect.from, "mqx_heartMAX") end --手牌中♥最多(或之一)
		if d >= h and d >= c and d >= s then room:setPlayerFlag(effect.from, "mqx_diamondMAX") end --手牌中♦最多(或之一)
		if c >= h and c >= d and c >= s then room:setPlayerFlag(effect.from, "mqx_clubMAX") end --手牌中♣最多(或之一)
		if s >= h and s >= d and s >= c then room:setPlayerFlag(effect.from, "mqx_spadeMAX") end --手牌中♠最多(或之一)
		local choices = {}
		table.insert(choices, "heartMAX")
		table.insert(choices, "diamondMAX")
		table.insert(choices, "clubMAX")
		table.insert(choices, "spadeMAX")
		local n = 0
		while not effect.from:hasFlag("mouqixirEND") and n < 4 do
			room:getThread():delay(400)
			local choice = room:askForChoice(effect.to, "mouqixir", table.concat(choices, "+"))
			if (choice == "heartMAX" and effect.from:hasFlag("mqx_heartMAX")) or (choice == "diamondMAX" and effect.from:hasFlag("mqx_diamondMAX"))
				or (choice == "clubMAX" and effect.from:hasFlag("mqx_clubMAX")) or (choice == "spadeMAX" and effect.from:hasFlag("mqx_spadeMAX")) then --猜对
				local log = sgs.LogMessage()
				log.type = "$mouqixirGuess_success"
				log.from = effect.from
				log.to:append(effect.to)
				room:sendLog(log)
				room:broadcastSkillInvoke("mouCaiCaiKan", 1)
				room:showAllCards(effect.from)
				room:setPlayerFlag(effect.from, "mouqixirEND")
			else --猜错
				local log = sgs.LogMessage()
				log.type = "$mouqixirGuess_fail"
				log.from = effect.from
				log.to:append(effect.to)
				room:sendLog(log)
				room:broadcastSkillInvoke("mouCaiCaiKan", 2)
				n = n + 1
				room:setPlayerFlag(effect.from, "mouqixirEND")
				if room:askForUseCard(effect.from, "@@mouqixirAgain", "@mouqixirAgain") then --令其再次猜测
					if choice == "heartMAX" then
						table.removeOne(choices, "heartMAX")
					elseif choice == "diamondMAX" then
						table.removeOne(choices, "diamondMAX")
					elseif choice == "clubMAX" then
						table.removeOne(choices, "clubMAX")
					elseif choice == "spadeMAX" then
						table.removeOne(choices, "spadeMAX")
					end
				end
			end
		end
		if n > 0 then
			room:broadcastSkillInvoke("mouqixir")
			while n > 0 and not effect.to:isAllNude() do
				local card = room:askForCardChosen(effect.from, effect.to, "hej", "mouqixir", false,
					sgs.Card_MethodDiscard)
				room:throwCard(card, effect.to, effect.from)
				n = n - 1
			end
		end
		if effect.from:hasFlag("mqx_heartMAX") then room:setPlayerFlag(effect.from, "-mqx_heartMAX") end
		if effect.from:hasFlag("mqx_diamondMAX") then room:setPlayerFlag(effect.from, "-mqx_diamondMAX") end
		if effect.from:hasFlag("mqx_clubMAX") then room:setPlayerFlag(effect.from, "-mqx_clubMAX") end
		if effect.from:hasFlag("mqx_spadeMAX") then room:setPlayerFlag(effect.from, "-mqx_spadeMAX") end
		if effect.from:hasFlag("mouqixirEND") then room:setPlayerFlag(effect.from, "-mouqixirEND") end
	end,
}
mouqixir = sgs.CreateZeroCardViewAsSkill {
	name = "mouqixir",
	view_as = function()
		return mouqixirCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#mouqixirCard") and not player:isKongcheng()
	end,
}
mouqixirAgainCard = sgs.CreateSkillCard { --询问是否令目标再次猜测
	name = "mouqixirAgainCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:setPlayerFlag(source, "-mouqixirEND")
	end,
}
mouqixirAgain = sgs.CreateZeroCardViewAsSkill {
	name = "mouqixirAgain",
	view_as = function()
		return mouqixirAgainCard:clone()
	end,
	response_pattern = "@@mouqixirAgain",
}
mou_ganningg:addSkill(mouqixir)
if not sgs.Sanguosha:getSkill("mouqixirAgain") then skills:append(mouqixirAgain) end

--承载“猜猜看”正确与错误的语音播报的载体--（目前：谋甘宁“奇袭”、谋周瑜“反间”）
mouCaiCaiKan = sgs.CreateTriggerSkill {
	name = "mouCaiCaiKan",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
if not sgs.Sanguosha:getSkill("mouCaiCaiKan") then skills:append(mouCaiCaiKan) end
----

moufenweirCard = sgs.CreateSkillCard { --选择牌和目标
	name = "moufenweirCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		local n = self:subcardsLength()
		if #targets == n then return false end
		return true
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@moufenweir")
		room:doSuperLightbox("mou_ganningg", "moufenweir")
		for _, p in pairs(targets) do
			room:setPlayerFlag(p, "moufenweirTargets") --标记所有目标，后续置牌(包括判断玩家自己是否被选择)用
		end
		local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if card_id then
			card_id:deleteLater()
			card_id = self
		end
		source:addToPile("MFwei", card_id)
	end,
}
moufenweir = sgs.CreateViewAsSkill {
	name = "moufenweir",
	n = 3,
	frequency = sgs.Skill_Limited,
	limit_mark = "@moufenweir", --20221231版新功能，可以直接在视为技设置limit_mark了。
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local moufenweir_card = moufenweirCard:clone()
			for _, card in pairs(cards) do
				moufenweir_card:addSubcard(card)
			end
			moufenweir_card:setSkillName(self:objectName())
			return moufenweir_card
		end
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@moufenweir") > 0 and not player:isNude()
	end,
}
mou_ganningg:addSkill(moufenweir)
moufenweirPUTCard = sgs.CreateSkillCard { --将牌置于目标武将牌上，称为“威”
	name = "moufenweirPUTCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:hasFlag("moufenweirTargets") and
			to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if card_id then
			card_id:deleteLater()
			card_id = self
		end
		room:broadcastSkillInvoke("moufenweir")
		targets[1]:addToPile("MFwei", card_id)
		room:setPlayerFlag(targets[1], "-moufenweirTargets") --完成放置，将该角色从目标范围内移除
	end,
}
moufenweirPUTVS = sgs.CreateOneCardViewAsSkill {
	name = "moufenweirPUT",
	filter_pattern = ".|.|.|MFwei",
	expand_pile = "MFwei",
	view_as = function(self, originalCard)
		local mfw_card = moufenweirPUTCard:clone()
		mfw_card:addSubcard(originalCard:getId())
		return mfw_card
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@moufenweirPUT")
	end,
}
moufenweirPUT = sgs.CreateTriggerSkill {
	name = "moufenweirPUT",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardFinished, sgs.TargetConfirming },
	view_as_skill = moufenweirPUTVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.CardFinished then
			if use.card:getSkillName() == "moufenweir" then
				local n = player:getPile("MFwei"):length()
				while (player:getPile("MFwei"):length() > 0 and not player:hasFlag("moufenweirTargets"))
					or (player:getPile("MFwei"):length() > 1 and player:hasFlag("moufenweirTargets")) do
					room:askForUseCard(player, "@@moufenweirPUT!", "@moufenweirPUT-card")
				end
				room:drawCards(player, n, "moufenweir")
				if player:hasFlag("moufenweirTargets") then room:setPlayerFlag(player, "-moufenweirTargets") end
			end
		elseif event == sgs.TargetConfirming then
			if use.card:isKindOf("TrickCard") then
				for _, p in sgs.qlist(use.to) do
					if p:getPile("MFwei"):length() > 0 then
						for _, mgn in sgs.qlist(room:findPlayersBySkillName("moufenweir")) do --搁这套娃呢
							local choice = room:askForChoice(mgn, "moufenweir", "1+2")
							if choice == "1" then
								local dummy = sgs.Sanguosha:cloneCard("slash")
								dummy:addSubcards(p:getPile("MFwei"))
								room:obtainCard(p, dummy)
								room:broadcastSkillInvoke("moufenweir")
							else
								local dummy = sgs.Sanguosha:cloneCard("slash")
								dummy:addSubcards(p:getPile("MFwei"))
								room:throwCard(dummy, p, mgn)
								room:setPlayerFlag(p, "moufenweir_nullified")
							end
							if p:getPile("MFwei"):isEmpty() then break end
						end
					end
				end
				for _, p in sgs.qlist(use.to) do
					if p:hasFlag("moufenweir_nullified") then
						local nullified_list = use.nullified_list
						table.insert(nullified_list, p:objectName())
						use.nullified_list = nullified_list
						room:broadcastSkillInvoke("moufenweir")
						room:setPlayerFlag(p, "-moufenweir_nullified")
					end
				end
				data:setValue(use)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("moufenweirPUT") then skills:append(moufenweirPUT) end



--

--谋夏侯氏
mou_xiahoushii = sgs.General(extension, "mou_xiahoushii", "shu", 3, false)

mouyanyuuCard = sgs.CreateSkillCard {
	name = "mouyanyuuCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:drawCards(source, 1, "mouyanyuu")
		room:addPlayerMark(source, "&mouyanyuuDraw", 3)
	end,
}
mouyanyuu = sgs.CreateOneCardViewAsSkill {
	name = "mouyanyuu",
	filter_pattern = "Slash",
	view_as = function(self, originalCard)
		local myy_card = mouyanyuuCard:clone()
		myy_card:addSubcard(originalCard:getId())
		return myy_card
	end,
	enabled_at_play = function(self, player)
		return player:usedTimes("#mouyanyuuCard") < 2
	end,
}
mouyanyuuGiveCards = sgs.CreateTriggerSkill {
	name = "mouyanyuuGiveCards",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseEnd },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play then
			if room:askForSkillInvoke(player, "mouyanyuu", data) then
				room:broadcastSkillInvoke("mouyanyuu")
				local n = player:getMark("&mouyanyuuDraw")
				local zhangfei = room:askForPlayerChosen(player, room:getOtherPlayers(player), "mouyanyuu",
					"mouyanyuu-GiveCardsNum:" .. n)
				room:drawCards(zhangfei, n, "mouyanyuu")
				room:broadcastSkillInvoke("mouyanyuu")
			end
			room:setPlayerMark(player, "&mouyanyuuDraw", 0)
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("mouyanyuu") and player:getMark("&mouyanyuuDraw") > 0
	end,
}
mou_xiahoushii:addSkill(mouyanyuu)
if not sgs.Sanguosha:getSkill("mouyanyuuGiveCards") then skills:append(mouyanyuuGiveCards) end

mouqiaoshii = sgs.CreateTriggerSkill {
	name = "mouqiaoshii",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.Damaged, sgs.TurnStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			local damage = data:toDamage()
			if damage.from and damage.from:objectName() == player:objectName() or damage.to:objectName() ~= player:objectName()
				or not player:hasSkill(self:objectName()) or player:getMark(self:objectName()) > 0 or not player:isAlive() then
				return false
			end
			if room:askForSkillInvoke(damage.from, "@mouqiaoshii_RecoverHer", data) then
				room:recover(player, sgs.RecoverStruct(player, nil, damage.damage))
				room:broadcastSkillInvoke(self:objectName())
				room:drawCards(damage.from, 2, self:objectName())
				room:addPlayerMark(player, self:objectName())
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
mou_xiahoushii:addSkill(mouqiaoshii)

--

--KJ谋夏侯霸
kj_mou_xiahouba = sgs.General(extension, "kj_mou_xiahouba", "wei", 4, true)

kjmoushifengCard = sgs.CreateSkillCard {
	name = "kjmoushifengCard",
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return sgs.Self:canSlash(to_select, nil, false)
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("kjmoushifeng")
		local use = sgs.CardUseStruct()
		use.card = slash
		use.from = source
		for _, p in pairs(targets) do
			use.to:append(p)
		end
		room:useCard(use)
	end,
}
kjmoushifengVS = sgs.CreateZeroCardViewAsSkill {
	name = "kjmoushifeng",
	view_as = function()
		return kjmoushifengCard:clone()
	end,
	enabled_at_play = function()
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@kjmoushifeng"
	end,
}
kjmoushifeng = sgs.CreateTriggerSkill {
	name = "kjmoushifeng",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.CardFinished, sgs.SlashMissed },
	view_as_skill = kjmoushifengVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.from:objectName() ~= player:objectName() or player:getKingdom() ~= "wei" then return false end
			if use.card:isKindOf("Jink") or use.card:isKindOf("Nullification") then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					room:drawCards(player, 1, self:objectName())
					room:askForUseCard(player, "@@kjmoushifeng", "@kjmoushifeng-tuodao")
				end
			end
		elseif event == sgs.SlashMissed then
			local effect = data:toSlashEffect()
			if effect.slash:getSkillName() == "kjmoushifeng" and effect.from:objectName() == player:objectName() and player:hasSkill(self:objectName()) then
				room:loseHp(player, 1)
			end
		end
	end,
}
kj_mou_xiahouba:addSkill(kjmoushifeng)

kjmoujuezhan = sgs.CreateTriggerSkill {
	name = "kjmoujuezhan",
	frequency = sgs.Skill_Wake,
	events = { sgs.TurnStart, sgs.EventPhaseStart },
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart and player:getPhase() ~= sgs.Player_Finish then return false end
		if player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getHp() ~= 1 and not player:isKongcheng() then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getHp() == 1 then
			room:broadcastSkillInvoke(self:objectName(), 1)
		end
		if player:isKongcheng() then
			room:broadcastSkillInvoke(self:objectName(), 2)
		end
		room:doSuperLightbox("kj_mou_xiahouba", "kjmoujuezhan")
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		if player:isWounded() then
			if room:askForChoice(player, self:objectName(), "1+2") == "1" then
				local recover = sgs.RecoverStruct()
				recover.who = player
				room:recover(player, recover)
			else
				room:drawCards(player, 2, self:objectName())
			end
		else
			room:drawCards(player, 2, self:objectName())
		end
		room:setPlayerProperty(player, "kingdom", sgs.QVariant("shu"))
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
kj_mou_xiahouba:addSkill(kjmoujuezhan)

kjmoulijin = sgs.CreateTriggerSkill {
	name = "kjmoulijin",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_RoundStart or not player:isWounded() or player:getKingdom() ~= "shu" then return false end
		if room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "judge+draw+play+discard")

			if choice == "judge" then
				local n = player:getLostHp()
				local players = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if not p:isNude() and player:canDiscard(p, "he") then
						players:append(p)
					end
				end
				if not players:isEmpty() and n > 0 then
					local simawei = room:askForPlayerChosen(player, players, self:objectName(),
						"kjmoulijinTiaoXinS:" .. n)
					room:broadcastSkillInvoke(self:objectName(), 1)
					while n > 0 and not simawei:isNude() do
						local card = room:askForCardChosen(player, simawei, "he", "kjmoulijin", false,
							sgs.Card_MethodDiscard, sgs.IntList(), true)
						if card < 0 then
							n = 0
						else
							room:throwCard(card, simawei, player)
							n = n - 1
						end
					end
				end
				player:setPhase(sgs.Player_Judge)
				room:broadcastProperty(player, "phase")
				local thread = room:getThread()
				if not thread:trigger(sgs.EventPhaseStart, room, player) then
					thread:trigger(sgs.EventPhaseProceeding, room, player)
				end
				thread:trigger(sgs.EventPhaseEnd, room, player)
				player:setPhase(sgs.Player_RoundStart)
				room:broadcastProperty(player, "phase")
			elseif choice == "draw" then
				room:broadcastSkillInvoke(self:objectName(), 2)
				room:setPlayerFlag(player, "kjmoulijinMXC")
				player:setPhase(sgs.Player_Draw)
				room:broadcastProperty(player, "phase")
				local thread = room:getThread()
				if not thread:trigger(sgs.EventPhaseStart, room, player) then
					thread:trigger(sgs.EventPhaseProceeding, room, player)
				end
				thread:trigger(sgs.EventPhaseEnd, room, player)
				player:setPhase(sgs.Player_RoundStart)
				room:broadcastProperty(player, "phase")
			elseif choice == "play" then
				local kjmoulijin_PlaySlash_cards = {}
				local kjmoulijin_one_slash_count = 0
				for _, id in sgs.qlist(room:getDrawPile()) do
					if sgs.Sanguosha:getCard(id):isKindOf("Slash") and not table.contains(kjmoulijin_PlaySlash_cards, id) and kjmoulijin_one_slash_count < 1 then
						kjmoulijin_one_slash_count = kjmoulijin_one_slash_count + 1
						table.insert(kjmoulijin_PlaySlash_cards, id)
					end
				end
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, id in ipairs(kjmoulijin_PlaySlash_cards) do
					dummy:addSubcard(id)
				end
				room:broadcastSkillInvoke(self:objectName(), 3)
				room:obtainCard(player, dummy, false)
				player:setPhase(sgs.Player_Play)
				room:broadcastProperty(player, "phase")
				local thread = room:getThread()
				if not thread:trigger(sgs.EventPhaseStart, room, player) then
					thread:trigger(sgs.EventPhaseProceeding, room, player)
				end
				thread:trigger(sgs.EventPhaseEnd, room, player)
				player:setPhase(sgs.Player_RoundStart)
				room:broadcastProperty(player, "phase")
			elseif choice == "discard" then
				room:broadcastSkillInvoke(self:objectName(), 4)
				player:gainHujia(1)
				player:setPhase(sgs.Player_Discard)
				room:broadcastProperty(player, "phase")
				local thread = room:getThread()
				if not thread:trigger(sgs.EventPhaseStart, room, player) then
					thread:trigger(sgs.EventPhaseProceeding, room, player)
				end
				thread:trigger(sgs.EventPhaseEnd, room, player)
				player:setPhase(sgs.Player_RoundStart)
				room:broadcastProperty(player, "phase")
			end
		end
	end,
}
kjmoulijinMXC = sgs.CreateMaxCardsSkill {
	name = "kjmoulijinMXC",
	extra_func = function(self, player)
		if player:hasFlag("kjmoulijinMXC") then
			return 1
		else
			return 0
		end
	end,
}
kj_mou_xiahouba:addSkill(kjmoulijin)
if not sgs.Sanguosha:getSkill("kjmoulijinMXC") then skills:append(kjmoulijinMXC) end

--谋周瑜
mou_zhouyuu = sgs.General(extension, "mou_zhouyuu", "wu", 3, true)

mouyingzii = sgs.CreateTriggerSkill {
	name = "mouyingzii",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.DrawNCards, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawNCards then
			local n = 0
			if player:getHandcardNum() >= 2 then n = n + 1 end
			if player:getHp() >= 2 then n = n + 1 end
			if player:getEquips():length() >= 1 then n = n + 1 end
			local log = sgs.LogMessage()
			log.type = "$mouyingzii_DrawMore"
			log.from = player
			log.arg2 = player:getHandcardNum()
			log.arg3 = player:getHp()
			log.arg4 = player:getEquips():length()
			log.arg5 = n
			room:sendLog(log)
			if n > 0 then room:broadcastSkillInvoke(self:objectName()) end
			room:setPlayerMark(player, "mouyingziiMXC", n)
			local count = data:toInt() + n
			data:setValue(count)
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			room:setPlayerMark(player, "mouyingziiMXC", 0)
		end
	end,
}
mouyingziiMXC = sgs.CreateMaxCardsSkill {
	name = "mouyingziiMXC",
	extra_func = function(self, player)
		if player:hasSkill("mouyingzii") and player:getMark("mouyingziiMXC") > 0 then
			local n = player:getMark("mouyingziiMXC")
			return n
		else
			return 0
		end
	end,
}
mou_zhouyuu:addSkill(mouyingzii)
if not sgs.Sanguosha:getSkill("mouyingziiMXC") then skills:append(mouyingziiMXC) end

moufanjiannCard = sgs.CreateSkillCard {
	name = "moufanjiannCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		if self:getSuit() == sgs.Card_Heart then room:setPlayerFlag(effect.from, "moufanjiann_heartUsed") end
		if self:getSuit() == sgs.Card_Diamond then room:setPlayerFlag(effect.from, "moufanjiann_diamondUsed") end
		if self:getSuit() == sgs.Card_Club then room:setPlayerFlag(effect.from, "moufanjiann_clubUsed") end
		if self:getSuit() == sgs.Card_Spade then room:setPlayerFlag(effect.from, "moufanjiann_spadeUsed") end
		room:setPlayerFlag(effect.from, "mou_zhouyuu") --AI锁定发起者用
		local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if card_id then
			card_id:deleteLater()
			card_id = self
		end
		effect.from:addToPile("moufanjiann", card_id, false)                                             --你就说这个叫不叫扣置吧
		room:getThread():delay(400)
		local choice = room:askForChoice(effect.from, "@moufanjiann_AnnounceSuit", "heart+diamond+club+spade") --声明
		--==辅助AI判断区==--（让AI知道发起者声明的是什么花色）
		if choice == "heart" then
			room:setPlayerFlag(effect.from, "moufanjiann_chooseHeart")
		elseif choice == "diamond" then
			room:setPlayerFlag(effect.from, "moufanjiann_chooseDiamond")
		elseif choice == "club" then
			room:setPlayerFlag(effect.from, "moufanjiann_chooseClub")
		elseif choice == "spade" then
			room:setPlayerFlag(effect.from, "moufanjiann_chooseSpade")
		end
		--------------------
		if (choice == "heart" and self:getSuit() == sgs.Card_Heart) or (choice == "diamond" and self:getSuit() == sgs.Card_Diamond)
			or (choice == "club" and self:getSuit() == sgs.Card_Club) or (choice == "spade" and self:getSuit() == sgs.Card_Spade) then
			room:setPlayerFlag(effect.from, "moufanjiann_truth")    --声明与扣置一致
		else
			room:setPlayerFlag(effect.from, "moufanjiann_lie")      --声明与扣置不一致
		end
		local choicc = room:askForChoice(effect.to, "moufanjiann", "1+2") --令其选择
		if choicc == "2" then                                       --直接开摆，猜猜猜，我猜nm呢
			effect.to:turnOver()
			room:broadcastSkillInvoke("moufanjiann", 2)
			room:setPlayerFlag(effect.from, "moufanjiann_cantUse")
			local dummy = sgs.Sanguosha:cloneCard("slash")
			dummy:addSubcards(effect.from:getPile("moufanjiann"))
			room:obtainCard(effect.to, dummy)
		else
			local choicx = room:askForChoice(effect.to, "@moufanjiann_guess", "1+2")                                                  --猜测
			if (choicx == "1" and effect.from:hasFlag("moufanjiann_truth")) or (choicx == "2" and effect.from:hasFlag("moufanjiann_lie")) then --猜对
				local log = sgs.LogMessage()
				log.type = "$moufanjiannGuess_success"
				log.from = effect.from
				log.to:append(effect.to)
				room:sendLog(log)
				room:broadcastSkillInvoke("mouCaiCaiKan", 1)
				room:getThread():delay(400)
				room:broadcastSkillInvoke("moufanjiann", 1)
				local dummy = sgs.Sanguosha:cloneCard("slash")
				dummy:addSubcards(effect.from:getPile("moufanjiann"))
				room:obtainCard(effect.to, dummy)
				room:setPlayerFlag(effect.from, "moufanjiann_cantUse")
				--猜错
			else
				local log = sgs.LogMessage()
				log.type = "$moufanjiannGuess_fail"
				log.from = effect.from
				log.to:append(effect.to)
				room:sendLog(log)
				room:broadcastSkillInvoke("mouCaiCaiKan", 2)
				room:getThread():delay(400)
				room:broadcastSkillInvoke("moufanjiann", 2)
				local dummy = sgs.Sanguosha:cloneCard("slash")
				dummy:addSubcards(effect.from:getPile("moufanjiann"))
				room:obtainCard(effect.to, dummy)
				room:loseHp(effect.to, 1)
			end
		end
		room:setPlayerFlag(effect.from, "-mou_zhouyuu")
		if effect.from:hasFlag("moufanjiann_truth") then room:setPlayerFlag(effect.from, "-moufanjiann_truth") end
		if effect.from:hasFlag("moufanjiann_lie") then room:setPlayerFlag(effect.from, "-moufanjiann_lie") end
		if effect.from:hasFlag("moufanjiann_chooseHeart") then room:setPlayerFlag(effect.from, "-moufanjiann_chooseHeart") end
		if effect.from:hasFlag("moufanjiann_chooseDiamond") then
			room:setPlayerFlag(effect.from,
				"-moufanjiann_chooseDiamond")
		end
		if effect.from:hasFlag("moufanjiann_chooseClub") then room:setPlayerFlag(effect.from, "-moufanjiann_chooseClub") end
		if effect.from:hasFlag("moufanjiann_chooseSpade") then room:setPlayerFlag(effect.from, "-moufanjiann_chooseSpade") end
	end,
}
moufanjiann = sgs.CreateViewAsSkill {
	name = "moufanjiann",
	n = 1,
	view_filter = function(self, selected, to_select)
		if (to_select:getSuit() == sgs.Card_Heart and sgs.Self:hasFlag("moufanjiann_heartUsed"))
			or (to_select:getSuit() == sgs.Card_Diamond and sgs.Self:hasFlag("moufanjiann_diamondUsed"))
			or (to_select:getSuit() == sgs.Card_Club and sgs.Self:hasFlag("moufanjiann_clubUsed"))
			or (to_select:getSuit() == sgs.Card_Spade and sgs.Self:hasFlag("moufanjiann_spadeUsed")) then
			return false
		end
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = moufanjiannCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng() and not player:hasFlag("moufanjiann_cantUse")
			and not (player:hasFlag("moufanjiann_heartUsed") and player:hasFlag("moufanjiann_diamondUsed")
				and player:hasFlag("moufanjiann_clubUsed") and player:hasFlag("moufanjiann_spadeUsed"))
	end,
}
mou_zhouyuu:addSkill(moufanjiann)



--

--谋黄盖
mou_huanggaii = sgs.General(extension, "mou_huanggaii", "wu", 4, true)

moukurouu = sgs.CreateTriggerSkill {
	name = "moukurouu",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart, sgs.HpLost },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Play and not player:isNude() then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					if player:getState() == "online" then
						local n = 0
						for _, c in sgs.qlist(player:getCards("he")) do
							if (c:isKindOf("Peach") or c:isKindOf("Analeptic")) then n = n + 1 end
						end
						if n > 0 then
							if room:askForChoice(player, self:objectName(), "gpa+got") == "gpa" then
								room:askForUseCard(player, "@@moukurouuGivePorA", "@moukurouuGivePorA-card")
							else
								room:askForUseCard(player, "@@moukurouuGiveOther", "@moukurouuGiveOther-card")
							end
						else
							room:askForUseCard(player, "@@moukurouuGiveOther", "@moukurouuGiveOther-card")
						end
					elseif player:getState() == "robot" and player:getHp() > 1 then --AI专用
						local zy = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName())
						local id = room:askForCardChosen(player, player, "he", self:objectName())
						local card = sgs.Sanguosha:getCard(id)
						if card:isKindOf("Peach") or card:isKindOf("Analeptic") then
							room:obtainCard(zy, card, false)
							room:broadcastSkillInvoke(self:objectName(), 1)
							local n = player:getHujia()
							if n > 0 then player:loseAllHujias() end
							room:loseHp(player, 2)
							if n > 0 then player:gainHujia(n) end
						else
							room:obtainCard(zy, card, false)
							room:broadcastSkillInvoke(self:objectName(), 1)
							local n = player:getHujia()
							if n > 0 then player:loseAllHujias() end
							room:loseHp(player, 1)
							if n > 0 then player:gainHujia(n) end
						end
					end
				end
			end
		elseif event == sgs.HpLost then
			--local lose = data:toInt()
			local lose = data:toHpLost()
			if not player:isAlive() then return false end
			--for i = 1, lose, 1 do
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName(), 2)
			player:gainHujia(lose.lose * 2)
			--end
		end
	end,
}
mou_huanggaii:addSkill(moukurouu)
--“苦肉”给牌：【桃】/【酒】
moukurouuGivePorACard = sgs.CreateSkillCard {
	name = "moukurouuGivePorACard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		room:obtainCard(effect.to, self, false)
		room:broadcastSkillInvoke("moukurouu", 1)
		local n = effect.from:getHujia()
		if n > 0 then effect.from:loseAllHujias() end
		room:loseHp(effect.from, 2)
		if n > 0 then effect.from:gainHujia(n) end
	end,
}
moukurouuGivePorA = sgs.CreateViewAsSkill {
	name = "moukurouuGivePorA",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isKindOf("Peach") or to_select:isKindOf("Analeptic")
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = moukurouuGivePorACard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	response_pattern = "@@moukurouuGivePorA",
}
if not sgs.Sanguosha:getSkill("moukurouuGivePorA") then skills:append(moukurouuGivePorA) end
--“苦肉”给牌：不为【桃】/【酒】
moukurouuGiveOtherCard = sgs.CreateSkillCard {
	name = "moukurouuGiveOtherCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		room:obtainCard(effect.to, self, false)
		room:broadcastSkillInvoke("moukurouu", 1)
		local n = effect.from:getHujia()
		if n > 0 then effect.from:loseAllHujias() end
		room:loseHp(effect.from, 1)
		if n > 0 then effect.from:gainHujia(n) end
	end,
}
moukurouuGiveOther = sgs.CreateViewAsSkill {
	name = "moukurouuGiveOther",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isKindOf("Peach") and not to_select:isKindOf("Analeptic")
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = moukurouuGiveOtherCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	response_pattern = "@@moukurouuGiveOther",
}
if not sgs.Sanguosha:getSkill("moukurouuGiveOther") then skills:append(moukurouuGiveOther) end

mouzhaxianggWH = sgs.CreateTargetModSkill {
	name = "mouzhaxianggWH",
	pattern = "Card",
	distance_limit_func = function(self, player, card)
		if player:hasSkill("mouzhaxiangg") and card and not card:isKindOf("SkillCard") and player:getMark("mouzhaxianggCardUsed") < player:getMark("&mouzhaxiangg") then
			return 1000
		else
			return 0
		end
	end,
	residue_func = function(self, player, card)
		if player:hasSkill("mouzhaxiangg") and card and not card:isKindOf("SkillCard") and player:getMark("mouzhaxianggCardUsed") < player:getMark("&mouzhaxiangg") then
			return 1000
		else
			return 0
		end
	end,
}
mouzhaxiangg = sgs.CreateTriggerSkill {
	name = "mouzhaxiangg",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardUsed, sgs.CardResponded, sgs.TargetSpecified, sgs.HpChanged, sgs.EventPhaseStart, sgs.EventPhaseChanging, sgs.DrawNCards },
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
			if card and card:getHandlingMethod() == sgs.Card_MethodUse and not card:isKindOf("SkillCard") and player:hasSkill(self:objectName()) then
				if player:getMark("mouzhaxianggCardUsed") < player:getMark("&mouzhaxiangg") then
					room
						:broadcastSkillInvoke(self:objectName())
				end
				room:addPlayerMark(player, "mouzhaxianggCardUsed")
			end
		elseif event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.card and not use.card:isKindOf("SkillCard") and use.from:objectName() == player:objectName() and player:hasSkill(self:objectName())
				and player:getMark("mouzhaxianggCardUsed") - 1 < player:getMark("&mouzhaxiangg") then --需考虑时机优先级问题
				room:broadcastSkillInvoke(self:objectName())
				local no_respond_list = use.no_respond_list
				for _, wj in sgs.qlist(room:getAllPlayers()) do
					table.insert(no_respond_list, wj:objectName())
				end
				use.no_respond_list = no_respond_list
				data:setValue(use)
			end
		elseif event == sgs.HpChanged then --X值随着损失体力值的变化动态调整
			if player:hasSkill(self:objectName()) and player:isAlive() then
				local n = player:getLostHp()
				room:setPlayerMark(player, "&mouzhaxiangg", n)
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					local n = p:getLostHp()
					room:setPlayerMark(p, "&mouzhaxiangg", n)
					room:broadcastSkillInvoke(self:objectName())
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "mouzhaxianggCardUsed", 0)
			end
		elseif event == sgs.DrawNCards then
			if player:hasSkill(self:objectName()) then
				local n = player:getLostHp()
				room:setPlayerMark(player, "&mouzhaxiangg", n)
				local count = data:toInt() + n
				data:setValue(count)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_huanggaii:addSkill(mouzhaxiangg)
if not sgs.Sanguosha:getSkill("mouzhaxianggWH") then skills:append(mouzhaxianggWH) end



--

--[[谋刘备-精简版
mou_liubey = sgs.General(extension, "mou_liubey$", "shu", 5, true)

mourend = sgs.CreateTriggerSkill{
	name = "mourend",
	frequency = sgs.Skill_NotFrequent,
	events = {},
	on_trigger = function()
	end,
}
mou_liubey:addSkill(mourend)

mouzhangw = sgs.CreateTriggerSkill{
	name = "mouzhangw",
	frequency = sgs.Skill_Limited, limit_mark = "@mouzhangw",
	events = {},
	on_trigger = function()
	end,
}
mou_liubey:addSkill(mouzhangw)

moujij = sgs.CreateTriggerSkill{
	name = "moujij$",
	frequency = sgs.Skill_NotFrequent,
	events = {},
	on_trigger = function()
	end,
}
mou_liubey:addSkill(moujij)]]

--谋刘备
mou_liubeii = sgs.General(extension, "mou_liubeii$", "shu", 4, true)

mourendeeCard = sgs.CreateSkillCard {
	name = "mourendeeCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and not to_select:hasFlag("mourendeeCardGet") and
			to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		local hxd = targets[1]
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(), targets[1]:objectName(),
			"mourendee", "")
		room:obtainCard(hxd, self, reason, false)
		room:setPlayerFlag(hxd, "mourendeeCardGet")
		if hxd:getMark("&mourdTOzw") == 0 then room:addPlayerMark(hxd, "&mourdTOzw") end
		local n = self:getSubcards():length()
		local m = source:getMark("&mRenWang")
		if 8 - m >= n then
			source:gainMark("&mRenWang", n)
		else
			source:gainMark("&mRenWang", 8 - m)
		end
	end,
}
mourendee = sgs.CreateViewAsSkill {
	name = "mourendee",
	n = 999,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local mrd_card = mourendeeCard:clone()
		for _, c in ipairs(cards) do
			mrd_card:addSubcard(c)
		end
		return mrd_card
	end,
	enabled_at_play = function(self, player)
		return not player:isNude()
	end,
}
mourendes = sgs.CreateTriggerSkill {
	name = "mourendes",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.GameStart, sgs.EventAcquireSkill, sgs.EventLoseSkill, sgs.EventPhaseStart, sgs.EventPhaseEnd, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill("mourendee") and not player:hasSkill("mourendeee") then
				room:attachSkillToPlayer(player, "mourendeee")
			end
		elseif event == sgs.EventAcquireSkill then
			if data:toString() == "mourendee" and not player:hasSkill("mourendeee") then
				room:attachSkillToPlayer(player, "mourendeee")
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == "mourendee" and player:hasSkill("mourendeee") then
				room:detachSkillFromPlayer(player, "mourendeee", true)
			end
		elseif event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Play and player:hasSkill("mourendee") then
			local n = player:getMark("&mRenWang")
			room:sendCompulsoryTriggerLog(player, "mourendee")
			room:broadcastSkillInvoke("mourendee")
			if n == 7 then
				player:gainMark("&mRenWang", 1)
			elseif n < 7 then
				player:gainMark("&mRenWang", 2)
			end
		elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Play then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("mourendeeCardGet") then room:setPlayerFlag(p, "-mourendeeCardGet") end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "&mRenWangYK", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_liubeii:addSkill(mourendee)
if not sgs.Sanguosha:getSkill("mourendes") then skills:append(mourendes) end
--仁望印基本牌
mourendeeeCard = sgs.CreateSkillCard {
	name = "mourendeeeCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		local players = sgs.PlayerList()
		for i = 1, #targets do
			players:append(targets[i])
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card = nil
			if self:getUserString() and self:getUserString() ~= "" then
				card = sgs.Sanguosha:cloneCard(self:getUserString():split("+")[1])
				return card and card:targetFilter(players, to_select, sgs.Self) and
					not sgs.Self:isProhibited(to_select, card, players)
			end
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return false
		end
		local _card = sgs.Self:getTag("mourendeee"):toCard()
		if _card == nil then
			return false
		end
		local card = sgs.Sanguosha:cloneCard(_card)
		card:setCanRecast(false)
		card:deleteLater()
		return card and card:targetFilter(players, to_select, sgs.Self) and
			not sgs.Self:isProhibited(to_select, card, players)
	end,
	feasible = function(self, targets)
		local players = sgs.PlayerList()
		for i = 1, #targets do
			players:append(targets[i])
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card = nil
			if self:getUserString() and self:getUserString() ~= "" then
				card = sgs.Sanguosha:cloneCard(self:getUserString():split("+")[1])
				return card and card:targetsFeasible(players, sgs.Self)
			end
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return true
		end
		local _card = sgs.Self:getTag("mourendeee"):toCard()
		if _card == nil then
			return false
		end
		local card = sgs.Sanguosha:cloneCard(_card)
		card:setCanRecast(false)
		card:deleteLater()
		return card and card:targetsFeasible(players, sgs.Self)
	end,
	on_validate = function(self, card_use)
		local mlb = card_use.from
		local room = mlb:getRoom()
		mlb:loseMark("&mRenWang", 2)
		room:addPlayerMark(mlb, "&mRenWangYK")
		local user_string = self:getUserString()
		if (string.find(user_string, "slash") or string.find(user_string, "Slash")) and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local slashs = sgs.Sanguosha:getSlashNames()
			user_string = room:askForChoice(mlb, "mourendeee_slash", table.concat(slashs, "+"))
		end
		local use_card = sgs.Sanguosha:cloneCard(user_string)
		if not use_card then return nil end
		use_card:setSkillName("_mourendee")
		use_card:deleteLater()
		return use_card
	end,
	on_validate_in_response = function(self, mlb)
		local room = mlb:getRoom()
		mlb:loseMark("&mRenWang", 2)
		room:addPlayerMark(mlb, "&mRenWangYK")
		local to_mourendeee = ""
		if self:getUserString() == "peach+analeptic" then
			local mourendeee_list = {}
			table.insert(mourendeee_list, "peach")
			local sts = sgs.GetConfig("BanPackages", "")
			if not string.find(sts, "maneuvering") then
				table.insert(mourendeee_list, "analeptic")
			end
			to_mourendeee = room:askForChoice(mlb, "mourendeee_saveself", table.concat(mourendeee_list, "+"))
			mlb:setTag("mourendeeeSaveSelf", sgs.QVariant(to_mourendeee))
		elseif self:getUserString() == "slash" then
			local mourendeee_list = {}
			table.insert(mourendeee_list, "slash")
			local sts = sgs.GetConfig("BanPackages", "")
			if not string.find(sts, "maneuvering") then
				table.insert(mourendeee_list, "normal_slash")
				table.insert(mourendeee_list, "fire_slash")
				table.insert(mourendeee_list, "thunder_slash")
				table.insert(mourendeee_list, "ice_slash")
			end
			to_mourendeee = room:askForChoice(mlb, "mourendeee_slash", table.concat(mourendeee_list, "+"))
			mlb:setTag("mourendeeeSlash", sgs.QVariant(to_mourendeee))
		else
			to_mourendeee = self:getUserString()
		end
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		local user_str = ""
		if to_mourendeee == "slash" then
			if card:isKindOf("Slash") then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		elseif to_mourendeee == "normal_slash" then
			user_str = "slash"
		else
			user_str = to_mourendeee
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str)
		use_card:setSkillName("mourendee")
		use_card:deleteLater()
		return use_card
	end,
}
mourendeee = sgs.CreateZeroCardViewAsSkill {
	name = "mourendeee&",
	response_or_use = true,
	view_as = function(self, cards)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or
			sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local c = mourendeeeCard:clone()
			c:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			return c
		end
		local card = sgs.Self:getTag("mourendeee"):toCard()
		if card and card:isAvailable(sgs.Self) then
			local c = mourendeeeCard:clone()
			c:setUserString(card:objectName())
			return c
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		local current = false
		local players = player:getAliveSiblings()
		players:append(player)
		for _, p in sgs.qlist(players) do
			if p:getPhase() ~= sgs.Player_NotActive then
				current = true
				break
			end
		end
		if not current then return false end
		return player:getMark("&mRenWang") >= 2 and player:getMark("&mRenWangYK") == 0 and player:hasSkill("mourendee")
	end,
	enabled_at_response = function(self, player, pattern)
		local current = false
		local players = player:getAliveSiblings()
		players:append(player)
		for _, p in sgs.qlist(players) do
			if p:getPhase() ~= sgs.Player_NotActive then
				current = true
				break
			end
		end
		if not current then return false end
		if player:getMark("&mRenWang") < 2 or player:getMark("&mRenWangYK") > 0 or not player:hasSkill("mourendee")
			or string.sub(pattern, 1, 1) == "." or string.sub(pattern, 1, 1) == "@" then
			return false
		end
		if (pattern == "peach" and player:getMark("Global_PreventPeach") > 0) or pattern == "nullification" or pattern == "jl_wuxiesy" then return false end
		if string.find(pattern, "[%u%d]") then return false end
		return true
	end,
}
mourendeee:setGuhuoDialog("l")
if not sgs.Sanguosha:getSkill("mourendeee") then skills:append(mourendeee) end

mouzhangwuuCard = sgs.CreateSkillCard {
	name = "mouzhangwuuCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@mouzhangwuu")
		room:doSuperLightbox("mou_liubeii", "mouzhangwuu")
		local n
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:getMark("mouzhangwuuTurn") > 0 then
				n = p:getMark("mouzhangwuuTurn")
				break
			end
		end
		local m = n - 1
		if m > 3 then m = 3 end
		if m > 0 then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("&mourdTOzw") > 0 then
					room:broadcastSkillInvoke("mouzhangwuu")
					room:removePlayerMark(p, "&mourdTOzw")
					if p:isNude() then continue end
					if p:getHandcardNum() + p:getEquips():length() > m then
						room:setPlayerMark(p, "mouzhangwuuGive", m) --用于AI判断该给几张牌
						local card = room:askForExchange(p, "mouzhangwuu", m, m, true, "#mouzhangwuu:" .. m)
						if card then
							room:obtainCard(source, card,
								sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(), p:objectName(),
									"mouzhangwuu", ""), false)
						end
						room:setPlayerMark(p, "mouzhangwuuGive", 0)
					else
						local dummy_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						for _, cd in sgs.qlist(p:getCards("he")) do
							dummy_card:addSubcard(cd)
						end
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, source:objectName(),
							p:objectName(), "mouzhangwuu", nil)
						room:moveCardTo(dummy_card, p, source, sgs.Player_PlaceHand, reason, false)
					end
				end
			end
		end
		room:recover(source, sgs.RecoverStruct(source, nil, 3))
		if source:hasSkill("mourendee") then
			room:detachSkillFromPlayer(source, "mourendee")
		end
	end,
}
mouzhangwuu = sgs.CreateZeroCardViewAsSkill {
	name = "mouzhangwuu",
	frequency = sgs.Skill_Limited,
	limit_mark = "@mouzhangwuu",
	view_as = function()
		return mouzhangwuuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@mouzhangwuu") > 0
	end,
}
mouzhangwuuTurn = sgs.CreateTriggerSkill {
	name = "mouzhangwuuTurn",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.TurnStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local n = 15
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			n = math.min(p:getSeat(), n)
		end
		if player:getSeat() == n and not room:getTag("ExtraTurn"):toBool() then
			room:setPlayerMark(player, self:objectName(), player:getMark("Global_TurnCount") + 1)
			--[[for _, p in sgs.qlist(room:getAlivePlayers()) do
				for _, mark in sgs.list(p:getMarkNames()) do
					if string.find(mark, "_lun") and p:getMark(mark) > 0 then
						room:setPlayerMark(p, mark, 0)
					end
				end
			end]]
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_liubeii:addSkill(mouzhangwuu)
if not sgs.Sanguosha:getSkill("mouzhangwuuTurn") then skills:append(mouzhangwuuTurn) end

moujijiangg = sgs.CreateTriggerSkill {
	name = "moujijiangg$",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseEnd, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Play and player:hasLordSkill(self:objectName()) then
			if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
			local jjto = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName(), "moujijianggto")
			local SJ = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getKingdom() == "shu" and p:objectName() ~= jjto:objectName() and p:inMyAttackRange(jjto) and p:getHp() >= player:getHp() then
					SJ:append(p)
				end
			end
			if SJ:length() == 0 then return false end
			local jjfrom
			if SJ:length() > 1 then
				jjfrom = room:askForPlayerChosen(player, SJ, self:objectName(), "moujijianggfrom")
			elseif SJ:length() == 1 then
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:getKingdom() == "shu" and p:objectName() ~= jjto:objectName() and p:inMyAttackRange(jjto) and p:getHp() >= player:getHp() then
						jjfrom = p
						break
					end
				end
			end
			room:broadcastSkillInvoke(self:objectName())
			local choices = {}
			if jjfrom:canSlash(jjto, nil, false) then
				table.insert(choices, "1=" .. jjto:objectName())
			end
			table.insert(choices, "2")
			local choice = room:askForChoice(jjfrom, self:objectName(), table.concat(choices, "+"))
			if choice == "2" then
				room:addPlayerMark(jjfrom, "moujijianggSL")
			else
				local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				slash:setSkillName("_moujijiangg")
				room:useCard(sgs.CardUseStruct(slash, jjfrom, jjto), false)
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_Play and player:getMark("moujijianggSL") > 0 then
				if room:findPlayerBySkillName(self:objectName()) then
					room:sendCompulsoryTriggerLog(player,
						self:objectName())
				end
				room:broadcastSkillInvoke(self:objectName())
				room:removePlayerMark(player, "moujijianggSL")
				player:skip(change.to)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_liubeii:addSkill(moujijiangg)

--FC谋姜维
fc_mou_jiangwei = sgs.General(extension, "fc_mou_jiangwei", "shu", 4, true)

fcmoutiaoxinStart = sgs.CreateTriggerSkill {
	name = "fcmoutiaoxinStart",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.GameStart },
	on_trigger = function(self, event, player, data, room)
		room:addPlayerMark(player, "@fcXuLi", 4) --初始蓄力点
		room:addPlayerMark(player, "fcXuLiMAX", 4) --蓄力点上限，可叠加
	end,
	can_trigger = function(self, player)
		return player:hasSkill("fcmoutiaoxin")
	end,
}
if not sgs.Sanguosha:getSkill("fcmoutiaoxinStart") then skills:append(fcmoutiaoxinStart) end
fcmoutiaoxinCard = sgs.CreateSkillCard {
	name = "fcmoutiaoxinCard",
	filter = function(self, targets, to_select)
		local n = sgs.Self:getMark("@fcXuLi")
		return #targets < n and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		room:setPlayerFlag(source, "fcmxt_getbazhen")
		room:acquireSkill(source, "bazhen")
		for _, xr in pairs(targets) do
			if xr then
				source:loseMark("@fcXuLi", 1)
				if source:getMark("fcmouzhiji") == 0 then
					room:addPlayerMark(source, "&tofcmouzhiji")
				end
			end
		end
		for _, xr in pairs(targets) do
			local use_slash = false
			if xr:canSlash(source, nil, false) then
				room:setPlayerFlag(xr, "fcmoutiaoxinSource")
				room:setPlayerFlag(source, "fcmoutiaoxinTarget")
				use_slash = room:askForUseSlashTo(xr, source, "@fcmoutiaoxin-slash:" .. source:objectName(), false)
			end
			if not use_slash and not xr:isNude() then
				local card = room:askForCardChosen(source, xr, "he", "fcmoutiaoxin")
				room:obtainCard(source, card, false)
			end
			if xr:hasFlag("fcmoutiaoxinSource") then room:setPlayerFlag(xr, "-fcmoutiaoxinSource") end
			if source:hasFlag("fcmoutiaoxinTarget") then room:setPlayerFlag(source, "-fcmoutiaoxinTarget") end
		end
	end,
}
fcmoutiaoxin = sgs.CreateZeroCardViewAsSkill {
	name = "fcmoutiaoxin",
	view_as = function()
		return fcmoutiaoxinCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#fcmoutiaoxinCard") and player:getMark("@fcXuLi") > 0
	end,
}
fc_mou_jiangwei:addSkill(fcmoutiaoxin)
fcmoutiaoxinTrigger = sgs.CreateTriggerSkill {
	name = "fcmoutiaoxinTrigger",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.SlashMissed, sgs.EventPhaseEnd, sgs.CardsMoveOneTime },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.SlashMissed then
			local effect = data:toSlashEffect()
			if effect.jink and effect.from:hasFlag("fcmoutiaoxinSource") and effect.to:hasFlag("fcmoutiaoxinTarget")
				and not effect.from:isNude() and effect.to:hasSkill("fcmoutiaoxin") then
				local card = room:askForCardChosen(effect.to, effect.from, "he", "fcmoutiaoxin", false,
					sgs.Card_MethodDiscard)
				room:throwCard(card, effect.from, effect.to)
				room:setPlayerFlag(effect.from, "-fcmoutiaoxinSource")
				room:setPlayerFlag(effect.to, "-fcmoutiaoxinTarget")
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Play then
				if player:hasFlag("fcmxt_getbazhen") then
					if player:hasSkill("bazhen") then room:detachSkillFromPlayer(player, "bazhen", false, true) end
					room:setPlayerFlag(player, "-fcmxt_getbazhen")
				end
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() and player:hasSkill("fcmoutiaoxin") and player:getMark("@fcXuLi") < player:getMark("fcXuLiMAX")
				and player:getPhase() == sgs.Player_Discard and bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD then
				room:sendCompulsoryTriggerLog(player, "fcmoutiaoxin")
				room:broadcastSkillInvoke("fcmoutiaoxin")
				local l = move.card_ids:length()
				local m = player:getMark("fcXuLiMAX")
				local n = player:getMark("@fcXuLi")
				if m - n >= l then
					player:gainMark("@fcXuLi", l)
				else
					player:gainMark("@fcXuLi", m - n)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("fcmoutiaoxinTrigger") then skills:append(fcmoutiaoxinTrigger) end

fcmouzhiji = sgs.CreateTriggerSkill {
	name = "fcmouzhiji",
	frequency = sgs.Skill_Wake,
	events = { sgs.EventPhaseProceeding },
	waked_skills = "fcmzj_yaozhi, fcmzj_jiezhuangshen",
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getMark("&tofcmouzhiji") < 4 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:setPlayerMark(player, "&tofcmouzhiji", 0)
		room:broadcastSkillInvoke(self:objectName())
		room:doSuperLightbox("fc_mou_jiangwei", "fcmouzhiji")
		room:loseMaxHp(player, 1)
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		if not player:hasSkill("fcmzj_yaozhi") then
			room:acquireSkill(player, "fcmzj_yaozhi")
		end
		if not player:hasSkill("fcmzj_jiezhuangshen") then
			room:acquireSkill(player, "fcmzj_jiezhuangshen")
		end
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
fc_mou_jiangwei:addSkill(fcmouzhiji)
fc_mou_jiangwei:addRelateSkill("fcmzj_yaozhi")
fc_mou_jiangwei:addRelateSkill("fcmzj_jiezhuangshen")

--==“妖智”(原作者：司马子元)==--
local json = require("json")
function isNormalGameMode(mode_name)
	return mode_name:endsWith("p") or mode_name:endsWith("pd") or mode_name:endsWith("pz")
end

function getZhitianSkills()
	local room = sgs.Sanguosha:currentRoom()
	local Huashens = {}
	local generals = sgs.Sanguosha:getLimitedGeneralNames()
	local banned = { "zuoci", "guzhielai", "dengshizai", "jiangboyue", "bgm_xiahoudun" }
	local zhitian_skills = {}
	local alives = room:getAlivePlayers()
	for _, p in sgs.qlist(alives) do
		if not table.contains(banned, p:getGeneralName()) then
			table.insert(banned, p:getGeneralName())
		end
		if p:getGeneral2() and not table.contains(banned, p:getGeneral2Name()) then
			table.insert(banned, p:getGeneral2Name())
		end
	end
	if (isNormalGameMode(room:getMode()) or room:getMode():find("_mini_") or room:getMode() == "custom_scenario") then
		table.removeTable(generals, sgs.GetConfig("Banlist/Roles", ""):split(","))
	elseif (room:getMode() == "04_1v3") then
		table.removeTable(generals, sgs.GetConfig("Banlist/HulaoPass", ""):split(","))
	elseif (room:getMode() == "06_XMode") then
		table.removeTable(generals, sgs.GetConfig("Banlist/XMode", ""):split(","))
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			table.removeTable(generals, (p:getTag("XModeBackup"):toStringList()) or {})
		end
	elseif (room:getMode() == "02_1v1") then
		table.removeTable(generals, sgs.GetConfig("Banlist/1v1", ""):split(","))
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			table.removeTable(generals, (p:getTag("1v1Arrange"):toStringList()) or {})
		end
	end
	for i = 1, #generals, 1 do
		if table.contains(banned, generals[i]) then
			table.remove(generals, i)
		end
	end
	for i = 1, #generals, 1 do
		local ageneral = sgs.Sanguosha:getGeneral(generals[i])
		if ageneral ~= nil then
			local N = ageneral:getVisibleSkillList():length()
			local x = 0
			for _, pe in sgs.qlist(room:getAlivePlayers()) do
				for _, sk in sgs.qlist(ageneral:getVisibleSkillList()) do
					if pe:hasSkill(sk:objectName()) then x = x + 1 end
				end
			end
			if x == N then table.remove(generals, i) end
		end
	end
	if #generals > 0 then
		for i = 1, #generals, 1 do
			table.insert(Huashens, generals[i])
		end
	end
	if #Huashens > 0 then
		for _, general_name in ipairs(Huashens) do
			local general = sgs.Sanguosha:getGeneral(general_name)
			for _, sk in sgs.qlist(general:getVisibleSkillList()) do
				table.insert(zhitian_skills, sk:objectName())
			end
		end
	end
	if #zhitian_skills > 0 then
		for _, pe in sgs.qlist(room:getAlivePlayers()) do
			for _, gsk in sgs.qlist(pe:getVisibleSkillList()) do
				if table.contains(zhitian_skills, gsk:objectName()) then table.removeOne(zhitian_skills, gsk:objectName()) end
			end
		end
	end
	if #zhitian_skills > 0 then
		return zhitian_skills
	else
		return {}
	end
end

--参数1：n，返回的table中技能的数量，Number类型（比如填3则最终的table里装填3个技能）
--参数2/3/4：description，所需的技能描述，String类型，一般利用string.find(skill:getDescription(), description)判断，彼此为并集。若无描述要求则填-1
--参数5：includeLord，是否包括主公技，Bool类型，true则包括，false则不包括
function getSpecificDescriptionSkills(n, description1, description2, description3, includeLord)
	local skill_table = {} --这个用来存放初选满足函数要求的技能
	local output_table = {} --这个用来存放最终满足函数要求的技能
	local d_paras = { description1, description2, description3 }
	local d_needs = {}
	for i = 1, #d_paras do
		if d_paras[i] ~= -1 then table.insert(d_needs, d_paras[i]) end
	end
	local skills = getZhitianSkills()
	for _, _sk in ipairs(skills) do
		local _skill = sgs.Sanguosha:getSkill(_sk)
		local critical_des = string.sub(_skill:getDescription(), 1, 42)
		if #d_needs > 0 then
			for _, _des in ipairs(d_needs) do
				if string.find(critical_des, _des, 1) then
					if includeLord == false then
						if (not _skill:isLordSkill()) and (not _skill:isAttachedLordSkill()) and _skill:getFrequency() ~= sgs.Skill_Wake then
							table.insert(skill_table, _sk)
							break
						end
					elseif includeLord == true then
						table.insert(skill_table, _sk)
						break
					end
				end
			end
		else
			if includeLord == false then
				if (not _skill:isLordSkill()) and (not _skill:isAttachedLordSkill()) and _skill:getFrequency() ~= sgs.Skill_Wake then
					table.insert(skill_table, _sk)
					break
				end
			elseif includeLord == true then
				table.insert(skill_table, _sk)
				break
			end
		end
	end
	if #skill_table > 0 then --整理，准备导出最终满足的技能table
		for i = 1, n do
			local j = math.random(1, #skill_table)
			table.insert(output_table, skill_table[j])
			table.removeOne(skill_table, skill_table[j])
			if #skill_table == 0 then break end
		end
	end
	return output_table
end

fcmzj_yaozhi = sgs.CreateTriggerSkill {
	name = "fcmzj_yaozhi",
	frequency = sgs.Skill_NotFrequent,
	priority = 5,
	events = { sgs.GameStart, sgs.EventAcquireSkill, sgs.EventLoseSkill, sgs.EventPhaseStart, sgs.Damaged, sgs.DamageComplete, sgs.CardFinished, sgs.EventPhaseEnd, sgs.MarkChanged },
	on_trigger = function(self, event, player, data, room)
		if event == sgs.GameStart then
			local fcmzj_yaozhi_gained = {}
			player:setTag("fcmzj_yaozhi_gained", sgs.QVariant(table.concat(fcmzj_yaozhi_gained, "+")))
		elseif event == sgs.EventAcquireSkill then
			if data:toString() == self:objectName() then
				local fcmzj_yaozhi_gained = {}
				player:setTag("fcmzj_yaozhi_gained", sgs.QVariant(table.concat(fcmzj_yaozhi_gained, "+")))
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == self:objectName() then
				player:removeTag("fcmzj_yaozhi_gained")
				player:removeTag("fcmzj_yaozhi_temp_skill")
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				if player:askForSkillInvoke(self:objectName(), data) then
					room:addPlayerMark(player, self:objectName() .. "engine")
					if player:getMark(self:objectName() .. "engine") > 0 then
						room:broadcastSkillInvoke(self:objectName())
						player:drawCards(1, self:objectName())
						local fcmzj_yaozhi_gained = player:getTag("fcmzj_yaozhi_gained"):toString():split("+")
						local yaozhi_playerstart = getSpecificDescriptionSkills(3, "回合开始阶段，", "准备阶段，", "准备阶段开始时，", false)
						if #yaozhi_playerstart > 0 then
							local yaozhi = room:askForChoice(player, self:objectName(),
								table.concat(yaozhi_playerstart, "+"), data)
							if not table.contains(fcmzj_yaozhi_gained, yaozhi) then
								table.insert(fcmzj_yaozhi_gained,
									yaozhi)
							end
							player:setTag("fcmzj_yaozhi_gained", sgs.QVariant(table.concat(fcmzj_yaozhi_gained, "+")))
							local temp_msg = sgs.LogMessage()
							temp_msg.from = player
							temp_msg.arg = yaozhi
							temp_msg.type = "#ZJYaozhiTempSkill"
							room:sendLog(temp_msg)
							room:acquireSkill(player, yaozhi)
							player:setTag("fcmzj_yaozhi_temp_skill", sgs.QVariant("yaozhi_temp_" .. yaozhi))
						end
						room:removePlayerMark(player, self:objectName() .. "engine")
					end
				end
			end
			if player:getPhase() == sgs.Player_Play then
				if player:askForSkillInvoke(self:objectName(), data) then
					room:addPlayerMark(player, self:objectName() .. "engine")
					if player:getMark(self:objectName() .. "engine") > 0 then
						room:broadcastSkillInvoke(self:objectName())
						player:drawCards(1, self:objectName())
						local fcmzj_yaozhi_gained = player:getTag("fcmzj_yaozhi_gained"):toString():split("+")
						local yaozhi_playerplay = getSpecificDescriptionSkills(3, "阶段技，", "出牌阶段，", "出牌阶段限一次，", false)
						if #yaozhi_playerplay > 0 then
							local yaozhi = room:askForChoice(player, self:objectName(),
								table.concat(yaozhi_playerplay, "+"), data)
							if not table.contains(fcmzj_yaozhi_gained, yaozhi) then
								table.insert(fcmzj_yaozhi_gained,
									yaozhi)
							end
							player:setTag("fcmzj_yaozhi_gained", sgs.QVariant(table.concat(fcmzj_yaozhi_gained, "+")))
							local temp_msg = sgs.LogMessage()
							temp_msg.from = player
							temp_msg.arg = yaozhi
							temp_msg.type = "#ZJYaozhiTempSkill"
							room:sendLog(temp_msg)
							room:acquireSkill(player, yaozhi)
							player:setTag("fcmzj_yaozhi_temp_skill", sgs.QVariant("yaozhi_temp_" .. yaozhi))
						end
						room:removePlayerMark(player, self:objectName() .. "engine")
					end
				end
			end
			if player:getPhase() == sgs.Player_Finish then
				if player:askForSkillInvoke(self:objectName(), data) then
					room:addPlayerMark(player, self:objectName() .. "engine")
					if player:getMark(self:objectName() .. "engine") > 0 then
						room:broadcastSkillInvoke(self:objectName())
						player:drawCards(1, self:objectName())
						local fcmzj_yaozhi_gained = player:getTag("fcmzj_yaozhi_gained"):toString():split("+")
						local yaozhi_playerfinish = getSpecificDescriptionSkills(3, "结束阶段，", "结束阶段开始时，", -1, false)
						if #yaozhi_playerfinish > 0 then
							local yaozhi = room:askForChoice(player, self:objectName(),
								table.concat(yaozhi_playerfinish, "+"), data)
							if not table.contains(fcmzj_yaozhi_gained, yaozhi) then
								table.insert(fcmzj_yaozhi_gained,
									yaozhi)
							end
							player:setTag("fcmzj_yaozhi_gained", sgs.QVariant(table.concat(fcmzj_yaozhi_gained, "+")))
							local temp_msg = sgs.LogMessage()
							temp_msg.from = player
							temp_msg.arg = yaozhi
							temp_msg.type = "#ZJYaozhiTempSkill"
							room:sendLog(temp_msg)
							room:acquireSkill(player, yaozhi)
							player:setTag("fcmzj_yaozhi_temp_skill", sgs.QVariant("yaozhi_temp_" .. yaozhi))
						end
						room:removePlayerMark(player, self:objectName() .. "engine")
					end
				end
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			if damage.damage > 0 and player:askForSkillInvoke(self:objectName(), data) then
				room:addPlayerMark(player, self:objectName() .. "engine")
				if player:getMark(self:objectName() .. "engine") > 0 then
					room:broadcastSkillInvoke(self:objectName())
					player:drawCards(1, self:objectName())
					local fcmzj_yaozhi_gained = player:getTag("fcmzj_yaozhi_gained"):toString():split("+")
					local yaozhi_damaged = getSpecificDescriptionSkills(3, "你受到伤害后", "你受到1点伤害后", "你受到一次伤害", false)
					if #yaozhi_damaged > 0 then
						local yaozhi = room:askForChoice(player, self:objectName(), table.concat(yaozhi_damaged, "+"),
							data)
						if not table.contains(fcmzj_yaozhi_gained, yaozhi) then table.insert(fcmzj_yaozhi_gained, yaozhi) end
						player:setTag("fcmzj_yaozhi_gained", sgs.QVariant(table.concat(fcmzj_yaozhi_gained, "+")))
						local temp_msg = sgs.LogMessage()
						temp_msg.from = player
						temp_msg.arg = yaozhi
						temp_msg.type = "#ZJYaozhiTempSkill"
						room:sendLog(temp_msg)
						room:acquireSkill(player, yaozhi)
						player:setTag("fcmzj_yaozhi_temp_skill", sgs.QVariant("yaozhi_temp_" .. yaozhi))
					end
					room:removePlayerMark(player, self:objectName() .. "engine")
				end
			end
		elseif event == sgs.DamageComplete then
			local temp_ta = player:getTag("fcmzj_yaozhi_temp_skill"):toString():split("+")
			if #temp_ta > 0 then
				local yaozhi_temp = string.sub(temp_ta[1], 13)
				if player:hasSkill(yaozhi_temp) then
					room:handleAcquireDetachSkills(player, "-" .. yaozhi_temp)
					player:removeTag("fcmzj_yaozhi_temp_skill")
				end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			local temp_ta = player:getTag("fcmzj_yaozhi_temp_skill"):toString():split("+")
			if #temp_ta > 0 then
				local yaozhi_temp = string.sub(temp_ta[1], 13)
				if use.card and (use.card:isVirtualCard() or use.card:getTypeId() == sgs.Card_TypeSkill) and string.find(temp_ta[1], use.card:getSkillName()) then
					if player:hasSkill(use.card:getSkillName()) or player:hasSkill(yaozhi_temp) then
						room:handleAcquireDetachSkills(player, "-" .. yaozhi_temp)
						player:removeTag("fcmzj_yaozhi_temp_skill")
					end
				end
			end
		elseif event == sgs.EventPhaseEnd then
			local phase = player:getPhase()
			if phase == sgs.Player_Start or phase == sgs.Player_Play or phase == sgs.Player_Finish then
				local temp_ta = player:getTag("fcmzj_yaozhi_temp_skill"):toString():split("+")
				if #temp_ta > 0 then
					local yaozhi_temp = string.sub(temp_ta[1], 13)
					if player:hasSkill(yaozhi_temp) then room:handleAcquireDetachSkills(player, "-" .. yaozhi_temp) end
				end
				player:removeTag("fcmzj_yaozhi_temp_skill")
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			local temp_ta = player:getTag("fcmzj_yaozhi_temp_skill"):toString():split("+")
			if #temp_ta > 0 then
				local temp_sk = string.sub(temp_ta[1], 13)
				if string.find(mark.name, temp_sk) and mark.gain == -1 and sgs.Sanguosha:getViewAsSkill(temp_sk) == nil then
					room:handleAcquireDetachSkills(player, "-" .. temp_sk)
					room:removeTag("fcmzj_yaozhi_temp_skill")
				end
			end
		end
		return false
	end
}
if not sgs.Sanguosha:getSkill("fcmzj_yaozhi") then skills:append(fcmzj_yaozhi) end
--==“界妆神”(原作者：小珂酱)==--
fcmzj_jiezhuangshen = sgs.CreateTriggerSkill {
	name = "fcmzj_jiezhuangshen", priority = -1,
	frequency = sgs.Skill_Frequent,
	events = { sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_RoundStart then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("jzs_dawu") > 0 then
					local num = p:getMark("jzs_dawu")
					room:setPlayerMark(p, "jzs_dawu", 0)
					room:removePlayerMark(p, "&dawu", num)
				end
				if p:getMark("jzs_kuangfeng") > 0 then
					local numm = p:getMark("jzs_kuangfeng")
					room:setPlayerMark(p, "jzs_kuangfeng", 0)
					room:removePlayerMark(p, "&kuangfeng", numm)
				end
			end
		end
		if (player:getPhase() == sgs.Player_Start) or (player:getPhase() == sgs.Player_Finish) then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				player:drawCards(1)
				local judge = sgs.JudgeStruct()
				judge.pattern = "."
				judge.good = true
				judge.play_animation = true
				judge.who = player
				judge.reason = self:objectName()
				room:judge(judge)
				local suit = judge.card:getSuit()
				if (suit == sgs.Card_Spade) or (suit == sgs.Card_Club) then
					room:broadcastSkillInvoke(self:objectName(), 1)
					local person = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(),
						"fcmzj_jiezhuangshenskill-ask", true, true)
					if person then
						local skill_list = {}
						for _, skill in sgs.qlist(person:getVisibleSkillList()) do
							if (not table.contains(skill_list, skill:objectName())) and not skill:isAttachedLordSkill() then
								table.insert(skill_list, skill:objectName())
							end
						end
						local skill_qc = ""
						if (#skill_list > 0) then
							skill_qc = room:askForChoice(player, self:objectName(), table.concat(skill_list, "+"))
						end
						if (skill_qc ~= "") then
							room:acquireNextTurnSkills(player, self:objectName(), skill_qc)
						end
					end
				end
				if (suit == sgs.Card_Diamond) or (suit == sgs.Card_Heart) then
					room:broadcastSkillInvoke(self:objectName(), 2)
					local person = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName(),
						"fcmzj_jiezhuangshengod-ask", true, true)
					if person then
						local choice = room:askForChoice(player, self:objectName(), "kfc+dwg+cancel")
						if choice == "kfc" then
							room:addPlayerMark(person, "&kuangfeng", 1)
							room:addPlayerMark(person, "jzs_kuangfeng", 1)
						end
						if choice == "dwg" then
							room:addPlayerMark(person, "&dawu", 1)
							room:addPlayerMark(person, "jzs_dawu", 1)
						end
					end
				end
			end
		end
	end,
}
fcmzj_jiezhuangshenDamage = sgs.CreateTriggerSkill {
	name = "fcmzj_jiezhuangshenDamage",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.DamageForseen, sgs.ConfirmDamage },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if event == sgs.DamageForseen then
			local benti = room:findPlayerBySkillName("qixing")
			if not benti then
				if (damage.nature ~= sgs.DamageStruct_Thunder) and (damage.to:getMark("&dawu") > 0) then
					room:sendCompulsoryTriggerLog(player, "fcmzj_jiezhuangshen")
					return true
				end
			end
		end
		if event == sgs.ConfirmDamage then
			local benti = room:findPlayerBySkillName("qixing")
			if not benti then
				if (damage.to:getMark("&kuangfeng") > 0) and (damage.nature == sgs.DamageStruct_Fire) then
					local hurt = damage.damage
					damage.damage = hurt + 1
					room:sendCompulsoryTriggerLog(player, "fcmzj_jiezhuangshen")
					data:setValue(damage)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
fcmzj_jiezhuangshenDeath = sgs.CreateTriggerSkill {
	name = "fcmzj_jiezhuangshenDeath",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.Death },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() == player:objectName() then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getMark("jzs_dawu") > 0 then
						room:removePlayerMark(p, "jzs_dawu")
						room:removePlayerMark(p, "&dawu")
					end
					if p:getMark("jzs_kuangfeng") > 0 then
						room:removePlayerMark(p, "jzs_kuangfeng")
						room:removePlayerMark(p, "&kuangfeng")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("fcmzj_jiezhuangshen")
	end,
}
if not sgs.Sanguosha:getSkill("fcmzj_jiezhuangshen") then skills:append(fcmzj_jiezhuangshen) end
if not sgs.Sanguosha:getSkill("fcmzj_jiezhuangshenDamage") then skills:append(fcmzj_jiezhuangshenDamage) end
if not sgs.Sanguosha:getSkill("fcmzj_jiezhuangshenDeath") then skills:append(fcmzj_jiezhuangshenDeath) end

--谋曹仁
mou_caorenn = sgs.General(extension, "mou_caorenn", "wei", 4, true, false, false, 4, 1)

moujushouuCard = sgs.CreateSkillCard {
	name = "moujushouuCard",
	target_fixed = true,
	mute = true,
	on_use = function(self, room, source, targets)
		source:turnOver()
		local n = source:getHandcardNum() + source:getEquips():length()
		local choices = {}
		table.insert(choices, "00")
		if n >= 1 and source:canDiscard(source, "he") then
			table.insert(choices, "11")
		end
		if n >= 2 and source:canDiscard(source, "he") then
			table.insert(choices, "22")
		end
		local choice = room:askForChoice(source, "moujushouu", table.concat(choices, "+"))
		if choice == "11" then
			room:askForDiscard(source, "moujushouu", 1, 1)
			source:gainHujia(1)
		elseif choice == "22" then
			room:askForDiscard(source, "moujushouu", 2, 2)
			source:gainHujia(2)
		end
	end,
}
moujushouu = sgs.CreateZeroCardViewAsSkill {
	name = "moujushouu",
	view_as = function()
		return moujushouuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#moujushouuCard") and player:faceUp()
	end,
}
moujushouuDamaged = sgs.CreateTriggerSkill {
	name = "moujushouuDamaged",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardUsed, sgs.Damaged, sgs.TurnedOver },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.from:objectName() == player:objectName() and use.card:getSkillName() == "moujushouu" then
				room:broadcastSkillInvoke("moujushouu", 1)
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			if not player:faceUp() then
				local choice = room:askForChoice(player, "moujushouu", "1+2")
				room:broadcastSkillInvoke("moujushouu", 2)
				if choice == "1" then
					player:turnOver()
				elseif choice == "2" then
					player:gainHujia(1)
				end
			end
		elseif event == sgs.TurnedOver then
			if player:faceUp() then
				local n = player:getHujia()
				room:sendCompulsoryTriggerLog(player, "moujushouu")
				room:broadcastSkillInvoke("moujushouu", 3)
				room:drawCards(player, n, "moujushouu")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("moujushouu")
	end,
}
mou_caorenn:addSkill(moujushouu)
if not sgs.Sanguosha:getSkill("moujushouuDamaged") then skills:append(moujushouuDamaged) end

moujieweiiCard = sgs.CreateSkillCard {
	name = "moujieweiiCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and not to_select:isKongcheng() and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		effect.from:loseHujia(1)
		local ids = sgs.IntList()
		for _, card in sgs.qlist(effect.to:getHandcards()) do
			ids:append(card:getEffectiveId())
		end
		local card_id = room:doGongxin(effect.from, effect.to, ids)
		if (card_id == -1) then return end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, effect.from:objectName())
		room:obtainCard(effect.from, sgs.Sanguosha:getCard(card_id), reason,
			room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
	end,
}
moujieweii = sgs.CreateZeroCardViewAsSkill {
	name = "moujieweii",
	view_as = function()
		return moujieweiiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#moujieweiiCard") and player:getHujia() >= 1
	end,
}
mou_caorenn:addSkill(moujieweii)



--

--谋甄姬
mou_zhenjii = sgs.General(extension, "mou_zhenjii", "wei", 3, false)

mouluoshenn = sgs.CreateTriggerSkill {
	name = "mouluoshenn",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseProceeding },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase ~= sgs.Player_Start then return false end
		if room:askForSkillInvoke(player, self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName())
			local cz = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName())
			local n = room:alivePlayerCount() / 2 --(room:alivePlayerCount() + 1) / 2
			local lovers = cz
			while n > 0 do
				if not lovers:isKongcheng() then
					local card = room:askForCardShow(lovers, lovers, self:objectName())
					local cd = card:getEffectiveId()
					room:showCard(lovers, cd)
					if card:isBlack() or card:isRed() then room:broadcastSkillInvoke(self:objectName()) end
					if card:isBlack() then
						room:setCardFlag(card, self:objectName())
						room:obtainCard(player, card, true)
					elseif card:isRed() then
						room:throwCard(card, lovers, nil)
					end
				end
				lovers = lovers:getNextAlive()
				n = n - 1
			end
		end
	end,
}
mouluoshennMaxCards = sgs.CreateMaxCardsSkill { --擦边球ta不香吗
	name = "mouluoshennMaxCards",
	extra_func = function(self, player)
		local n = 0
		if not player:hasSkill("mouluoshenn") then return n end
		for _, card in sgs.list(player:getHandcards()) do
			if card:hasFlag("mouluoshenn") then
				n = n + 1
			end
		end
		return n
	end,
}
mou_zhenjii:addSkill(mouluoshenn)
if not sgs.Sanguosha:getSkill("mouluoshennMaxCards") then skills:append(mouluoshennMaxCards) end

mouqingguoo = sgs.CreateOneCardViewAsSkill {
	name = "mouqingguoo",
	response_pattern = "jink",
	filter_pattern = ".|black|.|hand",
	response_or_use = true,
	view_as = function(self, card)
		local jink = sgs.Sanguosha:cloneCard("jink", card:getSuit(), card:getNumber())
		jink:setSkillName(self:objectName())
		jink:addSubcard(card:getId())
		return jink
	end,
}
mou_zhenjii:addSkill(mouqingguoo)





--

--谋法正
mou_fazhengg = sgs.General(extension, "mou_fazhengg", "shu", 3, true)

mouxuanhuooCard = sgs.CreateSkillCard {
	name = "mouxuanhuooCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:getMark("&mXuan") == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		room:obtainCard(effect.to, self, false)
		--room:setPlayerMark(effect.from, "mouxuanhuoo"..effect.to:objectName().."Source", 1) --通过将目标名字写入标记中，精准把控“眩惑”发动者与目标的关系
		--room:setPlayerMark(effect.to, "mouxuanhuoo"..effect.to:objectName().."Target", 1) --同上
		room:setPlayerMark(effect.from, "mouxuanhuoo-" .. effect.to:objectName() .. "-GCSource", 0) --自其获得“眩”标记开始
		effect.to:gainMark("&mXuan", 1)
	end,
}
mouxuanhuoo = sgs.CreateOneCardViewAsSkill {
	name = "mouxuanhuoo",
	view_filter = function(self, to_select)
		return true
	end,
	view_as = function(self, card)
		local mxh_card = mouxuanhuooCard:clone()
		mxh_card:addSubcard(card)
		return mxh_card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#mouxuanhuooCard") and not player:isNude()
	end,
}
mouxuanhuooGC = sgs.CreateTriggerSkill {
	name = "mouxuanhuooGC",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.MarkChanged, sgs.CardsMoveOneTime },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.who:objectName() == player:objectName() and mark.name == "&mXuan" then
				if mark.gain > 0 then
					room:setPlayerMark(player, "&mLastXuan", 5)
				elseif mark.gain < 0 then
					room:setPlayerMark(player, "&mLastXuan", 0)
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						room:setPlayerMark(p, "mouxuanhuoo-" .. player:objectName() .. "-GCSource", 0)
					end
				end
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.to and move.to:objectName() == player:objectName() and player:getPhase() ~= sgs.Player_Draw and not player:isKongcheng()
				and player:getMark("&mXuan") > 0 and player:getMark("&mLastXuan") > 0 then
				local can_invoke = false
				for _, id in sgs.qlist(move.card_ids) do
					if room:getCardOwner(id):objectName() == player:objectName()
						and room:getCardPlace(id) == sgs.Player_PlaceHand then
						can_invoke = true
					end
				end
				if can_invoke then
					local suijiget = {}
					for _, c in sgs.qlist(player:getHandcards()) do
						table.insert(suijiget, c)
					end
					for _, mfz in sgs.qlist(room:getOtherPlayers(player)) do
						if player:isKongcheng() or player:getMark("&mLastXuan") == 0 then break end
						if mfz:hasSkill("mouxuanhuoo") then
							local mxh_card = suijiget[math.random(1, #suijiget)]
							room:sendCompulsoryTriggerLog(mfz, "mouxuanhuoo")
							room:broadcastSkillInvoke("mouxuanhuoo")
							room:obtainCard(mfz, mxh_card, false)
							room:removePlayerMark(player, "&mLastXuan", 1)
						end
					end
				end
			end
			if move.from and move.from:getMark("&mXuan") > 0 and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip))
				and move.to and move.to:objectName() == player:objectName() then
				local mv = move.card_ids:length()
				room:addPlayerMark(player, "mouxuanhuoo-" .. move.from:objectName() .. "-GCSource", mv)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_fazhengg:addSkill(mouxuanhuoo)
if not sgs.Sanguosha:getSkill("mouxuanhuooGC") then skills:append(mouxuanhuooGC) end

mouenyuann = sgs.CreateTriggerSkill {
	name = "mouenyuann",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.EventPhaseProceeding },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase ~= sgs.Player_Start then return false end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:getMark("&mXuan") > 0 then
				if player:getMark("mouxuanhuoo-" .. p:objectName() .. "-GCSource") >= 3 then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName(), 1)
					p:loseAllMarks("&mXuan")
					if player:isNude() then return false end
					local n = player:getCards("he"):length()
					if n > 3 then
						local card = room:askForExchange(player, self:objectName(), 3, 3, true,
							"#mouenyuann:" .. p:getGeneralName())
						if card then
							room:obtainCard(p, card,
								sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, p:objectName(), player:objectName(),
									self:objectName(), ""), false)
						end
					else
						local dummy_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						for _, cd in sgs.qlist(player:getCards("he")) do
							dummy_card:addSubcard(cd)
						end
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, p:objectName(),
							player:objectName(), "mouzhangwuu", nil)
						room:moveCardTo(dummy_card, player, p, sgs.Player_PlaceHand, reason, false)
					end
				else
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName(), 2)
					room:loseHp(p, 1)
					room:recover(player, sgs.RecoverStruct(player))
					if p:isAlive() then
						p:loseAllMarks("&mXuan")
					end
				end
			end
		end
	end,
}
mou_fazhengg:addSkill(mouenyuann)

--

--谋庞统
mou_pangtongg = sgs.General(extension, "mou_pangtongg", "shu", 3, true)

moulianhuann_touse = sgs.CreateViewAsSkill {
	name = "moulianhuann_touse",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped() and to_select:getSuit() == sgs.Card_Club
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local chain = sgs.Sanguosha:cloneCard("iron_chain", cards[1]:getSuit(), cards[1]:getNumber())
			chain:addSubcard(cards[1])
			chain:setSkillName("moulianhuann")
			return chain
		end
	end,
	response_pattern = "@@moulianhuann_touse",
}
moulianhuannCard = sgs.CreateSkillCard {
	name = "moulianhuannCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local choices = {}
		if not source:hasFlag("moulianhuann_ICUsed") then
			table.insert(choices, "1")
		end
		table.insert(choices, "2")
		local choice = room:askForChoice(source, "moulianhuann", table.concat(choices, "+"))
		if choice == "1" then
			room:askForUseCard(source, "@@moulianhuann_touse", "@moulianhuann_touse-card")
		else
			local card_id = room:askForCard(source, ".|club|.|hand", "@moulianhuann-recast", sgs.QVariant(),
				sgs.Card_MethodRecast)
			if card_id then
				room:moveCardTo(card_id, source, nil, sgs.Player_DiscardPile,
					sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECAST, source:objectName(), "moulianhuann", ""))
				local log = sgs.LogMessage()
				log.type = "#UseCard_Recast"
				log.from = source
				log.card_str = card_id:toString()
				room:sendLog(log)
				source:drawCards(1, "recast")
			end
		end
	end,
}
moulianhuann = sgs.CreateZeroCardViewAsSkill {
	name = "moulianhuann",
	view_as = function()
		return moulianhuannCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng()
	end,
}
moulianhuannsCard = sgs.CreateSkillCard {
	name = "moulianhuannsCard",
	mute = true,
	filter = function(self, targets, to_select)
		return to_select:hasFlag("moulianhuanns")
	end,
	feasible = function(self, targets)
		return true
	end,
	about_to_use = function(self, room, use)
		for _, p in sgs.qlist(use.to) do
			room:setPlayerFlag(p, "moulianhuannsEXT")
		end
	end,
}
moulianhuannsVS = sgs.CreateZeroCardViewAsSkill {
	name = "moulianhuanns",
	view_as = function()
		return moulianhuannsCard:clone()
	end,
	response_pattern = "@@moulianhuanns",
}
moulianhuanns = sgs.CreateTriggerSkill {
	name = "moulianhuanns",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.CardUsed, sgs.PreCardUsed, sgs.EventPhaseEnd },
	view_as_skill = moulianhuannsVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.CardUsed then
			if use.from and use.from:objectName() == player:objectName() and use.card and use.card:isKindOf("IronChain") then
				if use.card:getSkillName() == "moulianhuann" and not player:hasFlag("moulianhuann_ICUsed") then
					room:setPlayerFlag(player, "moulianhuann_ICUsed")
				end
				if player:hasSkill("moulianhuann") then
					if room:askForSkillInvoke(player, "moulianhuann", data) then
						room:broadcastSkillInvoke("moulianhuann")
						if player:getMark("mouniepanned") == 0 then
							room:loseHp(player, 1)
						end
						if player:isAlive() then
							for _, p in sgs.qlist(use.to) do
								if p:isChained() or p:isKongcheng() then continue end
								local suijithrow = {}
								for _, c in sgs.qlist(p:getHandcards()) do
									table.insert(suijithrow, c)
								end
								local random_card = suijithrow[math.random(1, #suijithrow)]
								local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER,
									p:objectName(), "moulianhuann", "")
								room:throwCard(random_card, reason, nil)
							end
						end
					end
				end
			end
		elseif event == sgs.PreCardUsed then
			if use.from and use.from:objectName() == player:objectName() and player:getMark("mouniepanned") > 0 and player:hasSkill("moulianhuann")
				and use.card and use.card:isKindOf("IronChain") then
				local extra_targets = room:getCardTargets(player, use.card, use.to)
				if extra_targets:isEmpty() then return false end
				for _, p in sgs.qlist(extra_targets) do
					room:setPlayerFlag(p, self:objectName())
				end
				room:askForUseCard(player, "@@moulianhuanns",
					"@moulianhuanns-excard:" .. use.card:objectName() .. "::" .. 1, -1, sgs.Card_MethodNone)
				local adds = sgs.SPlayerList()
				for _, p in sgs.qlist(extra_targets) do
					room:setPlayerFlag(p, "-moulianhuanns")
					if p:hasFlag("moulianhuannsEXT") then
						room:setPlayerFlag(p, "-moulianhuannsEXT")
						use.to:append(p)
						adds:append(p)
					end
				end
				if adds:isEmpty() then return false end
				room:sortByActionOrder(adds)
				room:sortByActionOrder(use.to)
				data:setValue(use)
				local log = sgs.LogMessage()
				log.type = "#QiaoshuiAdd"
				log.from = player
				log.to = adds
				log.card_str = use.card:toString()
				log.arg = "moulianhuann"
				room:sendLog(log)
				for _, p in sgs.qlist(adds) do
					room:doAnimate(1, player:objectName(), p:objectName())
				end
				room:notifySkillInvoked(player, "moulianhuann")
				room:broadcastSkillInvoke("moulianhuann")
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Play and player:hasFlag("moulianhuann_ICUsed") then
				room:setPlayerFlag(player, "-moulianhuann_ICUsed")
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_pangtongg:addSkill(moulianhuann)
if not sgs.Sanguosha:getSkill("moulianhuann_touse") then skills:append(moulianhuann_touse) end
if not sgs.Sanguosha:getSkill("moulianhuanns") then skills:append(moulianhuanns) end

mouniepann = sgs.CreateTriggerSkill {
	name = "mouniepann",
	frequency = sgs.Skill_Limited,
	limit_mark = "@mouniepann",
	events = { sgs.AskForPeaches },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying_data = data:toDying()
		if dying_data.who:objectName() == player:objectName() then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				player:loseMark("@mouniepann")
				room:broadcastSkillInvoke(self:objectName())
				room:doSuperLightbox("mou_pangtongg", self:objectName())
				player:throwAllCards()
				room:drawCards(player, 2, self:objectName())
				local maxhp = player:getMaxHp()
				local recover = math.min(2 - player:getHp(), maxhp - player:getHp())
				room:recover(player, sgs.RecoverStruct(player, nil, recover))
				if player:isChained() then
					local damage = dying_data.damage
					if damage == nil or damage.nature == sgs.DamageStruct_Normal then
						room:setPlayerProperty(player, "chained", sgs.QVariant(false))
					end
				end
				if not player:faceUp() then
					player:turnOver()
				end
				room:addPlayerMark(player, "mouniepanned")
				if player:hasSkill("moulianhuann") then
					room:changeTranslation(player, "moulianhuann", 11)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill(self:objectName()) and player:getMark("@mouniepann") > 0
	end,
}
mou_pangtongg:addSkill(mouniepann)

--谋貂蝉
mou_diaochann = sgs.General(extension, "mou_diaochann", "qun", 3, false)

moulijiannCard = sgs.CreateSkillCard {
	name = "moulijiannCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		local n = self:subcardsLength() + 1
		if #targets == n then return false end
		return to_select:objectName() ~= sgs.Self:objectName()
	end,
	feasible = function(self, targets)
		return #targets == self:subcardsLength() + 1
	end,
	on_use = function(self, room, source, targets)
		if #targets > 3 then --触发全屏特效
			room:doSuperLightbox("mou_diaochann_lj", "moulijiann")
		end
		local lj, st, f, t = 1, 1, nil, nil
		for _, p in pairs(targets) do
			room:setPlayerMark(p, "moulijiannTargets", lj)
			--找到第一个和最后一个，最终最后一个将会向第一个发起决斗，形成闭环
			if p:getMark("moulijiannTargets") == 1 then
				t = p
			elseif p:getMark("moulijiannTargets") == #targets then
				f = p
				break
			end
			lj = lj + 1
		end
		while lj > 0 do
			local from, to = nil, nil
			for _, p in sgs.qlist(room:getOtherPlayers(source)) do
				if p:getMark("moulijiannTargets") == st then
					from = p
				elseif p:getMark("moulijiannTargets") == st + 1 then
					to = p
				end
				if from ~= nil and to ~= nil then break end
			end
			if from ~= nil and to ~= nil then
				local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
				duel:setSkillName("moulijiann")
				if not from:isCardLimited(duel, sgs.Card_MethodUse) and not from:isProhibited(to, duel) then
					room:useCard(sgs.CardUseStruct(duel, from, to))
				else
					duel:deleteLater()
				end
			end
			st = st + 1
			lj = lj - 1
		end
		if f:isAlive() and t:isAlive() then --最终的闭环：最后一个向第一个发起决斗
			local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
			duel:setSkillName("moulijiann")
			if not f:isCardLimited(duel, sgs.Card_MethodUse) and not f:isProhibited(t, duel) then
				room:useCard(sgs.CardUseStruct(duel, f, t))
			else
				duel:deleteLater()
			end
		end

		for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			room:setPlayerMark(p, "moulijiannTargets", 0)
		end
	end,
}
moulijiann = sgs.CreateViewAsSkill {
	name = "moulijiann",
	n = 999,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local MLJ_card = moulijiannCard:clone()
			for _, card in pairs(cards) do
				MLJ_card:addSubcard(card)
			end
			MLJ_card:setSkillName(self:objectName())
			return MLJ_card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isNude() and not player:hasUsed("#moulijiannCard")
	end,
}
mou_diaochann:addSkill(moulijiann)

moubiyuee = sgs.CreatePhaseChangeSkill {
	name = "moubiyuee",
	frequency = sgs.Skill_Compulsory,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Finish then
			local n = 1
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("moubiyuee_damagedTargets") then
					room:setPlayerFlag(p, "-moubiyuee_damagedTargets")
					n = n + 1
				end
			end
			if n > 4 then n = 4 end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			if n == 4 then room:doSuperLightbox("mou_diaochann_by", "moubiyuee") end --触发全屏特效
			room:drawCards(player, n, self:objectName())
		end
	end,
}
moubiyueeRaC = sgs.CreateTriggerSkill {
	name = "moubiyueeRaC",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.Damaged, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			local damage = data:toDamage()
			if damage.to:objectName() == player:objectName() and not player:hasFlag("moubiyuee_damagedTargets") then
				room:setPlayerFlag(player, "moubiyuee_damagedTargets")
			end
		elseif event == sgs.EventPhaseChanging then --双保险
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("moubiyuee_damagedTargets") then
					room:setPlayerFlag(p, "-moubiyuee_damagedTargets")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_diaochann:addSkill(moubiyuee)
if not sgs.Sanguosha:getSkill("moubiyueeRaC") then skills:append(moubiyueeRaC) end

--谋袁绍
mou_yuanshaoo = sgs.General(extension, "mou_yuanshaoo$", "qun", 4, true)

mouluanjii = sgs.CreateViewAsSkill {
	name = "mouluanjii",
	n = 2,
	view_filter = function(self, selected, to_select)
		return #selected < 2 and not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 2 then
			local cardA = cards[1]
			local cardB = cards[2]
			--local suit = cardA:getSuit()
			local aa = sgs.Sanguosha:cloneCard("archery_attack", sgs.Card_SuitToBeDecided, 0)
			aa:addSubcard(cardA)
			aa:addSubcard(cardB)
			aa:setSkillName(self:objectName())
			return aa
		end
	end,
	enabled_at_play = function(self, player)
		return player:getHandcardNum() >= 2 and not player:hasFlag("mouluanjiiUsed")
	end,
}
mouluanjiiDC = sgs.CreateTriggerSkill {
	name = "mouluanjiiDC",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardUsed, sgs.CardFinished, sgs.CardResponded, sgs.EventPhaseEnd, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed or event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.from and use.from:objectName() == player:objectName() then
				if event == sgs.CardUsed then
					if use.card and use.card:getSkillName() == "mouluanjii" and not player:hasFlag("mouluanjiiUsed") then
						room:setPlayerFlag(player, "mouluanjiiUsed")
					end
					if player:hasSkill("mouluanjii") and not player:hasFlag("mouluanjiiAA")
						and use.card and use.card:isKindOf("ArcheryAttack") then
						room:setPlayerFlag(player, "mouluanjiiAA")
					end
				elseif event == sgs.CardFinished and player:hasFlag("mouluanjiiAA")
					and use.card and use.card:isKindOf("ArcheryAttack") then
					room:setPlayerFlag(player, "-mouluanjiiAA")
				end
				--“血裔”摸牌
				if event == sgs.CardUsed and player:hasLordSkill("mouxueyii") and player:getMark("mouxueyiiDC") < 2
					and use.card and not use.card:isKindOf("SkillCard") then
					local can_draw = false
					for _, p in sgs.qlist(use.to) do
						if p:getKingdom() == "qun" and p:objectName() ~= player:objectName() then
							can_draw = true
						end
					end
					if can_draw then
						room:addPlayerMark(player, "mouxueyiiDC")
						room:sendCompulsoryTriggerLog(player, "mouxueyii")
						room:broadcastSkillInvoke("mouxueyii")
						room:drawCards(player, 1, "mouxueyii")
					end
				end
			end
		elseif event == sgs.CardResponded then
			local resp = data:toCardResponse()
			if resp.m_card:isKindOf("Jink") and resp.m_who and resp.m_who:hasSkill("mouluanjii")
				and resp.m_who:hasFlag("mouluanjiiAA") and resp.m_who:getMark(self:objectName()) < 3 then
				room:addPlayerMark(resp.m_who, self:objectName())
				room:sendCompulsoryTriggerLog(resp.m_who, "mouluanjii")
				room:broadcastSkillInvoke("mouluanjii")
				room:drawCards(resp.m_who, 1, "mouluanjii")
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Play and player:hasFlag("mouluanjiiUsed") then
				room:setPlayerFlag(player, "-mouluanjiiUsed")
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, self:objectName(), 0)
				room:setPlayerMark(p, "mouxueyiiDC", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_yuanshaoo:addSkill(mouluanjii)
if not sgs.Sanguosha:getSkill("mouluanjiiDC") then skills:append(mouluanjiiDC) end

mouxueyii = sgs.CreateMaxCardsSkill {
	name = "mouxueyii$",
	extra_func = function(self, player)
		local sssg = 0
		if player:hasLordSkill(self:objectName()) then
			for _, p in sgs.qlist(player:getAliveSiblings()) do
				if p:getKingdom() == "qun" then
					sssg = sssg + 1
				end
			end
			return sssg * 2
		end
		return sssg
	end
}
mou_yuanshaoo:addSkill(mouxueyii)

--谋孙策
mou_suncee = sgs.General(extension, "mou_suncee$", "wu", 4, true)

moujianggCard = sgs.CreateSkillCard { --“奇策”yyds
	name = "moujianggCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		local card = sgs.Sanguosha:cloneCard("duel", sgs.Card_SuitToBeDecided, 0)
		card:addSubcards(sgs.Self:getHandcards())
		card:setSkillName("moujiangg")
		if card and card:targetFixed() then return false end
		local jatargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			jatargets:append(p)
		end
		return card and card:targetFilter(jatargets, to_select, sgs.Self)
			and not sgs.Self:isProhibited(to_select, card, jatargets) and sgs.Self:canSlash(to_select, nil)
	end,
	feasible = function(self, targets)
		local card = sgs.Sanguosha:cloneCard("duel", sgs.Card_SuitToBeDecided, 0)
		card:addSubcards(sgs.Self:getHandcards())
		card:setSkillName("moujiangg")
		local jatargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			jatargets:append(p)
		end
		if card and card:canRecast() and #targets == 0 then return false end
		return card and card:targetsFeasible(jatargets, sgs.Self)
	end,
	on_validate = function(self, card_use)
		local msc = card_use.from
		local room = msc:getRoom()
		local jaduel = sgs.Sanguosha:cloneCard("duel", sgs.Card_SuitToBeDecided, 0)
		jaduel:addSubcards(msc:getHandcards())
		jaduel:setSkillName("moujiangg")
		local available = true
		for _, p in sgs.qlist(card_use.to) do
			if msc:isProhibited(p, jaduel) then
				available = false
				break
			end
		end
		available = available and jaduel:isAvailable(msc)
		if not available then return nil end
		return jaduel
	end,
}
moujiangg = sgs.CreateViewAsSkill {
	name = "moujiangg",
	n = 0,
	view_filter = function(self, selected, to_select)
		return false
	end,
	view_as = function(self, cards)
		local card = moujianggCard:clone()
		card:setUserString("duel")
		return card
	end,
	enabled_at_play = function(self, player)
		if player:getMark("mzbBUFFmja") == 0 then
			return not player:hasUsed("#moujianggCard") and not player:isKongcheng()
		else
			local wu = 0
			if player:getKingdom() == "wu" then wu = wu + 1 end
			for _, w in sgs.qlist(player:getAliveSiblings()) do
				if w:getKingdom() == "wu" then wu = wu + 1 end
			end
			return player:usedTimes("#moujianggCard") < wu and not player:isKongcheng()
		end
	end,
}
moujiangdCard = sgs.CreateSkillCard {
	name = "moujiangdCard",
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:hasFlag("moujiangd")
	end,
	feasible = function(self, targets)
		return true
	end,
	about_to_use = function(self, room, use)
		for _, p in sgs.qlist(use.to) do
			room:setPlayerFlag(p, "moujiangdEXT")
		end
		room:loseHp(use.from, 1)
	end,
}
moujiangdVS = sgs.CreateZeroCardViewAsSkill {
	name = "moujiangd",
	view_as = function()
		return moujiangdCard:clone()
	end,
	response_pattern = "@@moujiangd",
}
moujiangd = sgs.CreateTriggerSkill {
	name = "moujiangd",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.PreCardUsed, sgs.TargetConfirmed, sgs.TargetSpecified },
	view_as_skill = moujiangdVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.PreCardUsed then
			if use.from and use.from:objectName() == player:objectName() and player:hasSkill("moujiangg")
				and use.card and use.card:isKindOf("Duel") then
				local extra_targets = room:getCardTargets(player, use.card, use.to)
				if extra_targets:isEmpty() then return false end
				for _, p in sgs.qlist(extra_targets) do
					room:setPlayerFlag(p, self:objectName())
				end
				room:askForUseCard(player, "@@moujiangd", "@moujiangd-excard:" .. use.card:objectName() .. "::" .. 1, -1,
					sgs.Card_MethodNone)
				if not player:isAlive() then return false end
				local adds = sgs.SPlayerList()
				for _, p in sgs.qlist(extra_targets) do
					room:setPlayerFlag(p, "-moujiangd")
					if p:hasFlag("moujiangdEXT") then
						room:setPlayerFlag(p, "-moujiangdEXT")
						use.to:append(p)
						adds:append(p)
					end
				end
				if adds:isEmpty() then return false end
				room:sortByActionOrder(adds)
				room:sortByActionOrder(use.to)
				data:setValue(use)
				local log = sgs.LogMessage()
				log.type = "#QiaoshuiAdd"
				log.from = player
				log.to = adds
				log.card_str = use.card:toString()
				log.arg = "moujiangg"
				room:sendLog(log)
				for _, p in sgs.qlist(adds) do
					room:doAnimate(1, player:objectName(), p:objectName())
				end
				room:notifySkillInvoked(player, "moujiangg")
				room:broadcastSkillInvoke("moujiangg")
			end
		elseif (event == sgs.TargetSpecified or (event == sgs.TargetConfirmed and use.to:contains(player))) and player:hasSkill("moujiangg") then
			if use.card and use.card:isKindOf("Duel") or (use.card:isKindOf("Slash") and use.card:isRed()) then
				for _, p in sgs.qlist(use.to) do
					room:sendCompulsoryTriggerLog(player, "moujiangg")
					room:broadcastSkillInvoke("moujiangg")
					room:drawCards(player, 1, "moujiangg")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_suncee:addSkill(moujiangg)
if not sgs.Sanguosha:getSkill("moujiangd") then skills:append(moujiangd) end

mouhunzii = sgs.CreateTriggerSkill {
	name = "mouhunzii",
	frequency = sgs.Skill_Wake,
	events = { sgs.QuitDying },
	waked_skills = "mouyingzii, yinghun",
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if dying.who:objectName() ~= player:objectName() or player:getMark(self:objectName()) > 0 then return false end
		return true --if player:canWake(self:objectName()) then return true end --神郭嘉：扶不动，溜了溜了
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if dying.who and dying.who:objectName() == player:objectName() then
			room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
			room:doSuperLightbox("mou_suncee", self:objectName())
			room:loseMaxHp(player, 1)
			room:addPlayerMark(player, self:objectName())
			room:addPlayerMark(player, "@waked")
			room:drawCards(player, 2, self:objectName())
			if not player:hasSkill("mouyingzii") then
				room:acquireSkill(player, "mouyingzii")
			end
			if not player:hasSkill("yinghun") then
				room:acquireSkill(player, "yinghun")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
mouhunziiAudio = sgs.CreateTriggerSkill {
	name = "mouhunziiAudio",
	global = true,
	priority = 11,
	frequency = sgs.Skill_Frequent,
	events = { sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Draw and player:hasSkill("mouyingzii") then
			room:broadcastSkillInvoke("mouhunzii", math.random(3, 4))
		elseif player:getPhase() == sgs.Player_Start and player:hasSkill("yinghun") then
			room:broadcastSkillInvoke("mouhunzii", math.random(5, 6))
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("mouhunzii") > 0
	end,
}
mou_suncee:addSkill(mouhunzii)
mou_suncee:addRelateSkill("mouyingzii")
mou_suncee:addRelateSkill("yinghun")
if not sgs.Sanguosha:getSkill("mouhunziiAudio") then skills:append(mouhunziiAudio) end

mouzhibaa = sgs.CreateTriggerSkill {
	name = "mouzhibaa$",
	frequency = sgs.Skill_Limited,
	limit_mark = "@mouzhibaa",
	events = { sgs.Dying },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if dying.who:objectName() == player:objectName() then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				player:loseMark("@mouzhibaa")
				room:broadcastSkillInvoke(self:objectName())
				room:doSuperLightbox("mou_suncee", self:objectName())
				local wu = 0
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getKingdom() == "wu" then
						wu = wu + 1
					end
				end
				if wu > 0 then
					room:recover(player, sgs.RecoverStruct(player, nil, wu))
				end
				room:addPlayerMark(player, "mzbBUFFmja")
				for _, q in sgs.qlist(room:getOtherPlayers(player)) do
					if q:getKingdom() == "wu" then
						room:damage(sgs.DamageStruct(self:objectName(), nil, q))
						if q:isDead() then
							room:sendCompulsoryTriggerLog(player, self:objectName())
							room:broadcastSkillInvoke(self:objectName())
							room:drawCards(player, 3, self:objectName())
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill(self:objectName()) and player:getMark("@mouzhibaa") > 0
	end,
}
mou_suncee:addSkill(mouzhibaa)





--

--谋孙策-第二版
mou_sunces = sgs.General(extension, "mou_sunces$", "wu", 4, true)

mou_sunces:addSkill("moujiangg")

mouhunzis = sgs.CreateTriggerSkill {
	name = "mouhunzis",
	frequency = sgs.Skill_Wake,
	events = { sgs.QuitDying },
	waked_skills = "mouyingzii, yinghun",
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if dying.who:objectName() ~= player:objectName() or player:getMark(self:objectName()) > 0 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if dying.who and dying.who:objectName() == player:objectName() then
			room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
			room:doSuperLightbox("mou_suncee", self:objectName())
			room:loseMaxHp(player, 1)
			room:addPlayerMark(player, self:objectName())
			room:addPlayerMark(player, "@waked")
			player:gainHujia(1)
			room:drawCards(player, 3, self:objectName())
			if not player:hasSkill("mouyingzii") then
				room:acquireSkill(player, "mouyingzii")
			end
			if not player:hasSkill("yinghun") then
				room:acquireSkill(player, "yinghun")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
mouhunzisAudio = sgs.CreateTriggerSkill {
	name = "mouhunzisAudio",
	global = true,
	priority = 11,
	frequency = sgs.Skill_Frequent,
	events = { sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Draw and player:hasSkill("mouhunzis") then
			room:broadcastSkillInvoke("mouhunzis", math.random(3, 4))
		elseif player:getPhase() == sgs.Player_Start and player:hasSkill("yinghun") then
			room:broadcastSkillInvoke("mouhunzis", math.random(5, 6))
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("mouhunzis") > 0
	end,
}
mou_sunces:addSkill(mouhunzis)
mou_sunces:addRelateSkill("mouyingzii")
mou_sunces:addRelateSkill("yinghun")
if not sgs.Sanguosha:getSkill("mouhunzisAudio") then skills:append(mouhunzisAudio) end

mouzhibas = sgs.CreateTriggerSkill {
	name = "mouzhibas$",
	frequency = sgs.Skill_Limited,
	limit_mark = "@mouzhibas",
	events = { sgs.Dying },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if dying.who:objectName() == player:objectName() then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				player:loseMark("@mouzhibas")
				room:broadcastSkillInvoke(self:objectName())
				room:doSuperLightbox("mou_suncee", self:objectName())
				local wu = -1
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getKingdom() == "wu" then
						wu = wu + 1
					end
				end
				if wu > 0 then
					room:recover(player, sgs.RecoverStruct(player, nil, wu))
				end
				room:addPlayerMark(player, "mzbBUFFmja")
				for _, q in sgs.qlist(room:getOtherPlayers(player)) do
					if q:getKingdom() == "wu" then
						room:damage(sgs.DamageStruct(self:objectName(), nil, q))
						if q:isDead() then
							room:sendCompulsoryTriggerLog(player, self:objectName())
							room:broadcastSkillInvoke(self:objectName())
							room:drawCards(player, 3, self:objectName())
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill(self:objectName()) and player:getMark("@mouzhibas") > 0
	end,
}
mou_sunces:addSkill(mouzhibas)





--

--FC谋孙策
fc_mou_sunce = sgs.General(extension, "fc_mou_sunce$", "wu", 8, true, false, false, 4)

fcmoujiangCard = sgs.CreateSkillCard {
	name = "fcmoujiangCard",
	filter = function(self, targets, to_select)
		return to_select:hasFlag("fcmoujiang")
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	about_to_use = function(self, room, use)
		for _, p in sgs.qlist(use.to) do
			room:setPlayerFlag(p, "fcmoujiangEXT")
		end
	end,
}
fcmoujiangVS = sgs.CreateZeroCardViewAsSkill {
	name = "fcmoujiang",
	view_as = function()
		return fcmoujiangCard:clone()
	end,
	response_pattern = "@@fcmoujiang",
}
fcmoujiang = sgs.CreateTriggerSkill {
	name = "fcmoujiang",
	frequency = sgs.Skill_Frequent,
	events = { sgs.PreCardUsed, sgs.TargetConfirmed, sgs.TargetSpecified },
	view_as_skill = fcmoujiangVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.PreCardUsed then
			if use.from and use.from:objectName() == player:objectName() and use.card
				and (use.card:isRed() and use.card:isKindOf("Slash")) or use.card:isKindOf("Duel") then
				local extra_targets = room:getCardTargets(player, use.card, use.to)
				if extra_targets:isEmpty() then return false end
				for _, p in sgs.qlist(extra_targets) do
					room:setPlayerFlag(p, self:objectName())
				end
				room:askForUseCard(player, "@@fcmoujiang", "@fcmoujiang-excard:" .. use.card:objectName() .. "::" .. 1,
					-1, sgs.Card_MethodNone)
				--if not player:isAlive() then return false end --带亡语
				local adds = sgs.SPlayerList()
				for _, p in sgs.qlist(extra_targets) do
					room:setPlayerFlag(p, "-fcmoujiang")
					if p:hasFlag("fcmoujiangEXT") then
						room:setPlayerFlag(p, "-fcmoujiangEXT")
						use.to:append(p)
						adds:append(p)
					end
				end
				if adds:isEmpty() then return false end
				room:sortByActionOrder(adds)
				room:sortByActionOrder(use.to)
				data:setValue(use)
				local log = sgs.LogMessage()
				log.type = "#QiaoshuiAdd"
				log.from = player
				log.to = adds
				log.card_str = use.card:toString()
				log.arg = self:objectName()
				room:sendLog(log)
				for _, p in sgs.qlist(adds) do
					room:doAnimate(1, player:objectName(), p:objectName())
				end
				room:notifySkillInvoked(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
			end
		elseif (event == sgs.TargetSpecified or (event == sgs.TargetConfirmed and use.to:contains(player))) then
			if use.card and use.card:isKindOf("Duel") or (use.card:isKindOf("Slash") and use.card:isRed()) then
				if event == sgs.TargetSpecified then
					for _, p in sgs.qlist(use.to) do
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						room:loseHp(player, 1)
						if player:isAlive() then
							room:drawCards(player, 1, self:objectName())
						end
					end
				elseif event == sgs.TargetConfirmed then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					if player:isWounded() then
						room:recover(player, sgs.RecoverStruct(player))
					end
					room:drawCards(player, 1, self:objectName())
				end
			end
		end
	end,
}
fc_mou_sunce:addSkill(fcmoujiang)

fcmouhunzi = sgs.CreateTriggerSkill {
	name = "fcmouhunzi",
	priority = 9500,
	frequency = sgs.Skill_Wake,
	events = { sgs.GameOverJudge }, --sgs.Death},
	waked_skills = "fcmhz_yinzi, fcmhz_yinhun",
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() or player:getMark(self:objectName()) > 0 then return false end
		--if player:canWake(self:objectName()) then return true end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		if death.who and death.who:objectName() == player:objectName() then
			room:broadcastSkillInvoke(self:objectName(), 1)
			room:doSuperLightbox("fc_mou_sunce", self:objectName())
			room:getThread():delay(5500)
			room:revivePlayer(player)
			room:broadcastSkillInvoke(self:objectName(), 2)
			room:loseMaxHp(player, 2)
			room:addPlayerMark(player, self:objectName())
			room:addPlayerMark(player, "@waked")
			local recover = math.min(2 - player:getHp(), player:getMaxHp() - player:getHp())
			room:recover(player, sgs.RecoverStruct(player, nil, recover))
			local n = player:getMaxHp() - player:getHandcardNum()
			if n > 0 then
				room:drawCards(player, n, self:objectName())
			end
			if not player:hasSkill("fcmhz_yinzi") then
				room:acquireSkill(player, "fcmhz_yinzi")
			end
			if not player:hasSkill("fcmhz_yinhun") then
				room:acquireSkill(player, "fcmhz_yinhun")
			end
			room:setTag("SkipGameRule", sgs.QVariant(true)) --不加这个代码的话如果游戏要结束了复活了也没用
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill(self:objectName())
	end,
}
fc_mou_sunce:addSkill(fcmouhunzi)
fc_mou_sunce:addRelateSkill("fcmhz_yinzi")
fc_mou_sunce:addRelateSkill("fcmhz_yinhun")
--“阴资”
fcmhz_yinzi = sgs.CreateTriggerSkill {
	name = "fcmhz_yinzi",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.DrawNCards, sgs.EventPhaseStart, sgs.EventPhaseEnd },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawNCards then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			local count = math.random(player:getHp(), player:getMaxHp())
			data:setValue(count)
		elseif event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Discard then
			local st = 0
			for _, p in sgs.qlist(room:getAllPlayers(true)) do
				if p:isDead() then
					st = st + 1
				end
			end
			if st > 0 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:setPlayerMark(player, self:objectName(), st)
			end
		elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Discard then
			room:setPlayerMark(player, self:objectName(), 0)
		end
	end,
}
fcmhz_yinzi_MaxCards = sgs.CreateMaxCardsSkill {
	name = "fcmhz_yinzi_MaxCards",
	extra_func = function(self, player)
		if player:hasSkill("fcmhz_yinzi") then
			local n = player:getMark("fcmhz_yinzi")
			return n
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("fcmhz_yinzi") then skills:append(fcmhz_yinzi) end
if not sgs.Sanguosha:getSkill("fcmhz_yinzi_MaxCards") then skills:append(fcmhz_yinzi_MaxCards) end
--“阴魂”
fcmhz_yinhun = sgs.CreateTriggerSkill {
	name = "fcmhz_yinhun",
	frequency = sgs.Skill_Limited,
	limit_mark = "@fcmhz_yinhun",
	events = { sgs.EventPhaseProceeding },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Judge and player:getJudgingArea():length() > 0 and player:canDiscard(player, "j") then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				player:loseMark("@fcmhz_yinhun")
				room:broadcastSkillInvoke(self:objectName())
				room:doSuperLightbox("fc_mou_sunces", self:objectName())
				local doublefuck = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName(),
					"fcmhz_yinhun_choice")
				if doublefuck:isLord() then
					if player:getJudgingArea():length() < 2 then return false end
					local j1 = room:askForCardChosen(player, player, "j", self:objectName(), false,
						sgs.Card_MethodDiscard)
					room:throwCard(sgs.Sanguosha:getCard(j1), player, player)
					local j2 = room:askForCardChosen(player, player, "j", self:objectName(), false,
						sgs.Card_MethodDiscard)
					room:throwCard(sgs.Sanguosha:getCard(j2), player, player)
				else
					local jc = room:askForCardChosen(player, player, "j", self:objectName(), false,
						sgs.Card_MethodDiscard)
					room:throwCard(sgs.Sanguosha:getCard(jc), player, player)
				end
				local hp = doublefuck:getHp()
				local hc = doublefuck:getHandcardNum()
				room:killPlayer(doublefuck) --死生之地，不可不察
				room:revivePlayer(doublefuck) --死而复生，反复横跳
				if doublefuck:getHp() ~= hp then
					room:setPlayerProperty(doublefuck, "hp", sgs.QVariant(hp))
				end
				local hcd = hc - doublefuck:getHandcardNum()
				if hcd > 0 then
					room:drawCards(doublefuck, hcd, self:objectName())
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill(self:objectName()) and player:getMark("@fcmhz_yinhun") > 0
	end,
}
if not sgs.Sanguosha:getSkill("fcmhz_yinhun") then skills:append(fcmhz_yinhun) end

fcmouzhibaCard = sgs.CreateSkillCard {
	name = "fcmouzhibaCard",
	target_fixed = false,
	mute = true,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isKongcheng()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		effect.from:pindian(effect.to, "fcmouzhiba", nil)
	end,
}
fcmouzhiba = sgs.CreateZeroCardViewAsSkill {
	name = "fcmouzhiba$",
	waked_skills = "fc_mou_sunceWIN",
	view_as = function()
		return fcmouzhibaCard:clone()
	end,
	enabled_at_play = function(self, player)
		if player:isKongcheng() then return false end
		local n = 0
		if player:getKingdom() == "wu" and player:isAlive() then n = n + 1 end
		for _, p in sgs.qlist(player:getAliveSiblings()) do
			if p:getKingdom() == "wu" then
				n = n + 1
			end
		end
		return player:usedTimes("#fcmouzhibaCard") < n
	end,
}
fcmouzhiba_pd = sgs.CreateTriggerSkill {
	name = "fcmouzhiba_pd",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardUsed, sgs.Pindian },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card and use.card:getSkillName() == "fcmouzhiba" then
				room:broadcastSkillInvoke("fcmouzhiba", 1)
			end
		elseif event == sgs.Pindian then
			local pindian = data:toPindian()
			if pindian.reason == "fcmouzhiba" then
				local fromNumber = pindian.from_card:getNumber()
				local toNumber = pindian.to_card:getNumber()
				if fromNumber ~= toNumber then
					local winner
					local loser
					if fromNumber > toNumber then
						winner = pindian.from
						loser = pindian.to
						if fromNumber - toNumber >= 3 and math.random() <= 0.25 then --触发胜点彩蛋
							sgs.Sanguosha:playAudioEffect("audio/skill/fcmouzhiba_success.ogg", false)
							room:doLightbox("fcmouzhiba_successAnimate", 5000)
						end
					else
						winner = pindian.to
						loser = pindian.from
						room:broadcastSkillInvoke("fcmouzhiba", 2)
					end
				else --平点彩蛋：FC谋孙策播放专属音乐，并获得两张拼点牌！
					local log = sgs.LogMessage()
					log.type = "$fcmouzhiba_same"
					log.from = pindian.from
					log.to:append(pindian.to)
					room:sendLog(log)
					room:broadcastSkillInvoke("fc_mou_sunceWIN")
					room:obtainCard(pindian.from, pindian.from_card)
					room:obtainCard(pindian.from, pindian.to_card)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
fc_mou_sunce:addSkill(fcmouzhiba)
fc_mou_sunce:addRelateSkill("fc_mou_sunceWIN")
if not sgs.Sanguosha:getSkill("fcmouzhiba_pd") then skills:append(fcmouzhiba_pd) end
--胜利专属音乐：
fc_mou_sunceWIN = sgs.CreateTriggerSkill {
	name = "fc_mou_sunceWIN",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.GameOver },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local winner = data:toString():split("+")
		for _, p in sgs.list(room:getAllPlayers()) do
			if (table.contains(winner, p:objectName()) or table.contains(winner, p:getRole()))
				and isSpecialOne(p, "FC谋孙策") then
				room:broadcastSkillInvoke(self:objectName())
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("fc_mou_sunceWIN") then skills:append(fc_mou_sunceWIN) end

--谋大乔
mou_daqiaoo = sgs.General(extension, "mou_daqiaoo", "wu", 3, false)

mouguoseeCard = sgs.CreateSkillCard {
	name = "mouguoseeCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			for _, j in sgs.qlist(to_select:getJudgingArea()) do
				if j:isKindOf("Indulgence") then
					return true
				end
			end
		end
		return false
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local used = false
		for _, idg in sgs.qlist(effect.to:getJudgingArea()) do
			if idg:isKindOf("Indulgence") then
				room:throwCard(idg, effect.to, effect.from)
				used = true
			end
		end
		if not used then
			room:setPlayerFlag(effect.from, "non_mouguoseeUsed")
		end
	end,
}
mouguosee = sgs.CreateViewAsSkill {
	name = "mouguosee",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:getSuit() == sgs.Card_Diamond
	end,
	view_as = function(self, cards)
		if #cards == 0 then --弃乐
			return mouguoseeCard:clone()
		elseif #cards == 1 then --贴乐
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local id = card:getId()
			local indulgence = sgs.Sanguosha:cloneCard("indulgence", suit, point)
			indulgence:addSubcard(id)
			indulgence:setSkillName(self:objectName())
			return indulgence
		end
	end,
	enabled_at_play = function(self, player)
		return player:getMark("mouguoseeUsed") < 4
	end,
}
mouguoseeDraw = sgs.CreateTriggerSkill {
	name = "mouguoseeDraw",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardUsed, sgs.EventPhaseEnd },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card and use.card:getSkillName() == "mouguosee" then
				if player:hasSkill("mouguosee") then
					room:sendCompulsoryTriggerLog(player, "mouguosee")
					room:broadcastSkillInvoke("mouguosee")
					room:drawCards(player, 1, "mouguosee")
				end
				if not player:hasFlag("non_mouguoseeUsed") then
					room:addPlayerMark(player, "mouguoseeUsed")
				else
					room:setPlayerFlag(player, "-non_mouguoseeUsed")
				end
			end
		else
			if player:getPhase() == sgs.Player_Play and player:getMark("mouguoseeUsed") > 0 then
				room:setPlayerMark(player, "mouguoseeUsed", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_daqiaoo:addSkill(mouguosee)
if not sgs.Sanguosha:getSkill("mouguoseeDraw") then skills:append(mouguoseeDraw) end

mouliuliiCard = sgs.CreateSkillCard {
	name = "mouliuliiCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets > 0 then return false end
		if to_select:hasFlag("mllSlashSource") or to_select:objectName() == sgs.Self:objectName() then return false end
		local from
		for _, p in sgs.qlist(sgs.Self:getSiblings()) do
			if p:hasFlag("mllSlashSource") then
				from = p
				break
			end
		end
		local slash = sgs.Card_Parse(sgs.Self:property("mouliulii"):toString())
		if from and (not from:canSlash(to_select, slash, false)) then return false end
		local card_id = self:getSubcards():first()
		local range_fix = 0
		if sgs.Self:getWeapon() and (sgs.Self:getWeapon():getId() == card_id) then
			local weapon = sgs.Self:getWeapon():getRealCard():toWeapon()
			range_fix = range_fix + weapon:getRange() - 1
		elseif sgs.Self:getOffensiveHorse() and (sgs.Self:getOffensiveHorse():getId() == card_id) then
			range_fix = range_fix + 1
		end
		return sgs.Self:distanceTo(to_select, range_fix) <= sgs.Self:getAttackRange()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		effect.to:setFlags("mllTarget")

		if effect.from:getMark("mouliulii") == 0 then
			local id = self:getSubcards():first()
			local card = sgs.Sanguosha:getCard(id)
			if card:getSuit() == sgs.Card_Heart and not effect.from:hasFlag("mouliulii") then
				room:setPlayerFlag(effect.from, "mouliulii")
			end
		end
	end,
}
mouliuliiVS = sgs.CreateOneCardViewAsSkill {
	name = "mouliulii",
	response_pattern = "@@mouliulii",
	filter_pattern = ".!",
	view_as = function(self, card)
		local mll_card = mouliuliiCard:clone()
		mll_card:addSubcard(card)
		return mll_card
	end,
}
mouliulii = sgs.CreateTriggerSkill {
	name = "mouliulii",
	frequency = sgs.Skill_Frequent,
	events = { sgs.TargetConfirming },
	view_as_skill = mouliuliiVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card and use.card:isKindOf("Slash") and use.to:contains(player) and player:canDiscard(player, "he") and room:alivePlayerCount() > 2 then
			local players = room:getOtherPlayers(player)
			players:removeOne(use.from)
			room:setPlayerFlag(use.from, "mouliulii_DontChooseMe") --为了AI
			local can_invoke = false
			for _, p in sgs.qlist(players) do
				if use.from:canSlash(p, use.card) and player:inMyAttackRange(p) then
					can_invoke = true
					break
				end
			end
			if can_invoke then
				local prompt = "@liuli:" .. use.from:objectName()
				room:setPlayerFlag(use.from, "mllSlashSource")
				room:setPlayerProperty(player, "mouliulii", sgs.QVariant(use.card:toString()))
				if room:askForUseCard(player, "@@mouliulii", prompt, -1, sgs.Card_MethodDiscard) then
					room:broadcastSkillInvoke(self:objectName())
					if player:hasFlag(self:objectName()) then
						room:setPlayerFlag(player, "-mouliulii")
						local sunce = room:askForPlayerChosen(player, players, self:objectName(), "mouliulii-extraEffect",
							true, true)
						room:setPlayerFlag(use.from, "-mouliulii_DontChooseMe")
						if sunce then
							room:addPlayerMark(player, self:objectName())
							room:broadcastSkillInvoke(self:objectName())
							for _, p in sgs.qlist(room:getAllPlayers()) do
								if p:getMark("&mouliulii") > 0 then
									p:loseAllMarks("&mouliulii")
								end
							end
							room:setPlayerFlag(sunce, "non_mlletivk") --防止立刻就发动效果
							sunce:gainMark("&mouliulii")
						end
					end
					room:setPlayerProperty(player, "mouliulii", sgs.QVariant())
					room:setPlayerFlag(use.from, "-mllSlashSource")
					for _, p in sgs.qlist(players) do
						if p:hasFlag("non_mlletivk") then
							p:setFlags("-non_mlletivk")
						end
						if p:hasFlag("mllTarget") then
							p:setFlags("-mllTarget")
							use.to:removeOne(player)
							use.to:append(p)
							room:sortByActionOrder(use.to)
							data:setValue(use)
							room:getThread():trigger(sgs.TargetConfirming, room, p, data)
						end
					end
				else
					room:setPlayerProperty(player, "mouliulii", sgs.QVariant())
					room:setPlayerFlag(use.from, "-mllSlashSource")
				end
			end
		end
	end,
}
mouliuliiextraEffect = sgs.CreateTriggerSkill {
	name = "mouliuliiextraEffect",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_RoundStart
			and player:getMark("&mouliulii") > 0 and not player:hasFlag("-non_mlletivk") then
			if room:askForSkillInvoke(player, "mouliuliiextraPlay", data) then
				local mdq = room:findPlayerBySkillName("mouliulii")
				if mdq then
					room:sendCompulsoryTriggerLog(mdq, "mouliulii")
					room:broadcastSkillInvoke("mouliulii")
				end
				player:loseAllMarks("&mouliulii")
				player:setPhase(sgs.Player_Play)
				room:broadcastProperty(player, "phase")
				local thread = room:getThread()
				if not thread:trigger(sgs.EventPhaseStart, room, player) then
					thread:trigger(sgs.EventPhaseProceeding, room, player)
				end
				thread:trigger(sgs.EventPhaseEnd, room, player)
				player:setPhase(sgs.Player_RoundStart)
				room:broadcastProperty(player, "phase")
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "mouliulii", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mou_daqiaoo:addSkill(mouliulii)
if not sgs.Sanguosha:getSkill("mouliuliiextraEffect") then skills:append(mouliuliiextraEffect) end

sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable {
	["mougong"] = "谋攻篇",
	["mougongCards"] = "谋攻篇专属卡牌",
	["mougong_queen"] = "谋攻篇·女王的恩赐(不要勾选)", --谋祝融专属

	--谋黄忠
	--七天体验卡
	["mou_huangzhongg"] = "谋黄忠-七天体验卡",
	["&mou_huangzhongg"] = "谋黄忠",
	["#mou_huangzhongg"] = "没金铩羽",
	["designer:mou_huangzhongg"] = "官方",
	["cv:mou_huangzhongg"] = "官方",
	["illustrator:mou_huangzhongg"] = "佚名",
	--烈弓
	["mouliegongg"] = "烈弓",
	["mouliegongg_nolimit"] = "烈弓",
	["mouliegongg_record"] = "烈弓",
	[":mouliegongg"] = "你使用【杀】可以选择在此【杀】点数距离内的角色为目标。你使用牌时或成为其他角色使用牌的目标后，若此牌的花色未被“烈弓”记录，则记录此种花色。当你使用【杀】指定唯一目标后，你可以亮出牌堆顶的X张牌（X为你记录的花色数-1，且至少为0），每有一张牌花色与“烈弓”记录的花色相同，你令此【杀】伤害+1，且其不能使用“烈弓”记录花色的牌响应此【杀】。若如此做，此【杀】结算结束后，清除“烈弓”记录的花色。",
	["mouliegongg_MoreDamage"] = "",
	["mou_huangzhonggAnimate"] = "image=image/animate/mou_huangzhongg.png",
	["$mouliegonggBUFF"] = "因为“<font color='yellow'><b>烈弓</b></font>”的加成，%from 使用的 %card 对 %to 造成的伤害 + %arg2",
	["$mouliegongg1"] = "矢贯坚石，劲冠三军！",
	["$mouliegongg2"] = "吾虽年迈，箭矢犹锋！",
	--["$mouliegongg"] = "吾虽年迈....无双，万军取首！",
	--阵亡
	["~mou_huangzhongg"] = "弦断弓藏，将老孤亡......",

	--正式版
	["mou_huangzhong_formal"] = "谋黄忠",
	["#mou_huangzhong_formal"] = "没金铩羽",
	["designer:mou_huangzhong_formal"] = "官方",
	["cv:mou_huangzhong_formal"] = "官方",
	["illustrator:mou_huangzhong_formal"] = "佚名",
	--烈弓
	["mouliegongf"] = "烈弓",
	["mouliegongf_limit"] = "烈弓",
	["mouliegongf_record"] = "烈弓",
	[":mouliegongf"] = "若你的装备区里没有武器牌，你的所有【杀】封印为普通【杀】。你使用牌时或成为其他角色使用牌的目标后，若此牌的花色未被“烈弓”记录，则记录此种花色。当你使用【杀】指定[唯一]目标后，你可以亮出牌堆顶的X张牌（X为你记录的花色数-1，且至少为0），每有一张牌花色与“烈弓”记录的花色相同，你令此【杀】伤害+1，且其不能使用“烈弓”记录花色的牌响应此【杀】。若如此做，此【杀】结算结束后，清除“烈弓”记录的花色。",
	["mouliegongf_MoreDamage"] = "",
	["mou_huangzhong_formalAnimate"] = "image=image/animate/mou_huangzhong_formal.png",
	["$mouliegongfBUFF"] = "因为“<font color='yellow'><b>烈弓</b></font>”的加成，%from 使用的 %card 对 %to 造成的伤害 + %arg2",
	["$mouliegongf1"] = "矢贯坚石，劲冠三军！",
	["$mouliegongf2"] = "吾虽年迈，箭矢犹锋！",
	--阵亡
	["~mou_huangzhong_formal"] = "弦断弓藏，将老孤亡......",

	--FC谋黄忠
	["fc_mou_huangzhong"] = "FC谋黄忠",
	["&fc_mou_huangzhong"] = "☆谋黄忠",
	["#fc_mou_huangzhong"] = "丹心见苍天",
	["designer:fc_mou_huangzhong"] = "时光流逝FC",
	["cv:fc_mou_huangzhong"] = "屠洪刚",
	["illustrator:fc_mou_huangzhong"] = "屠洪刚",
	--烈弓
	["fcmouliegong"] = "烈弓",
	["fcmouliegong_one"] = "烈弓",
	["fcmouliegong_two"] = "烈弓",
	["fcmouliegong_threemore"] = "烈弓",
	[":fcmouliegong"] = "当你使用或打出牌后，若此牌的花色未被“烈弓”记录，你记录此种花色，否则你摸一张牌（每轮每种花色限触发一次以此法摸牌）。若你以此法已记录的花色数至少为：\
    <font color=\"#66FF66\">1，你的【杀】可以选择此【杀】点数距离内的角色为目标；</font>\
    <font color=\"#00CCFF\">2，你的【杀】不可被响应；</font>\
    <font color='purple'>3，你的【杀】伤害+1；</font>\
    <font color='orange'>4，你的【杀】根据其点数造成伤害时有概率暴击<b>(概率表：A-12%,K-60%,每多一点加4%)</b>，且若暴击成功，你清除所有已记录的花色并失去1点体力。</font>\
    你使用的【杀】结算结束后，你移除与此【杀】相同花色的记录。",
	["fcmouliegongheartDrawed_lun"] = "",
	["fcmouliegongdiamondDrawed_lun"] = "",
	["fcmouliegongclubDrawed_lun"] = "",
	["fcmouliegongspadeDrawed_lun"] = "",
	["$fcmouliegongCriticalHit"] = "<font color='red'><b>丹心见苍天</b></font>！%from 对 %to <font color='orange'><b>暴击</b></font>，此【<font color='yellow'>杀</b></font>】<font color='yellow'>伤害翻倍</b></font>！",
	["$fcmouliegong1"] = "黄忠将近古稀年，犹开弯弓射月满；众人笑我我不言，背朝尔等喝牙官。", --游戏开始
	["$fcmouliegong2"] = "抬宝刀，备宝鞍，随我纵马定军山；西风烈，吹长髯，须发如雪铁甲玄。", --当轮每种花色皆触发一次摸牌
	["$fcmouliegong3"] = "头通鼓，战饭造", --记录至1种花色
	["$fcmouliegong4"] = "二通鼓，紧战袍", --记录至2种花色
	["$fcmouliegong5"] = "三通鼓，刀出鞘", --记录至3种花色
	["$fcmouliegong6"] = "四通鼓，把兵交", --记录至4种花色
	["$fcmouliegong7"] = "定军山！大丈夫舍身不问年；百战余勇，我以丹心见苍天！", --出杀后记录有花色
	["$fcmouliegong8"] = "定军山！念人生如同雕翎箭；来去如烟，唯有恩义不离弦！", --出杀后记录有花色
	["$fcmouliegong9"] = "丹心见苍天！今日换余年！", --暴击
	["$fcmouliegong10"] = "定军山！我愿以今日换余年，也当回报平生知遇汉王前！", --通过发动技能使得目标死亡
	--阵亡
	["~fc_mou_huangzhong"] = "定军山！待到那灯火满长安，征衣轻弹拜见我一统江山......",

	--谋刘赪
	["mou_liuchengg"] = "谋刘赪",
	["#mou_liuchengg"] = "泣梧的湘女",
	["designer:mou_liuchengg"] = "官方",
	["cv:mou_liuchengg"] = "官方",
	["illustrator:mou_liuchengg"] = "佚名",
	--掠影
	["moulveyingg"] = "掠影",
	[":moulveyingg"] = "当你使用【杀】结算结束后，若你的“椎”标记数不小于2，你移去2枚“椎”标记，摸一张牌，然后可以视为使用一张【过河拆桥】。<font color='green'><b>出牌阶段限两次，</b></font>当你使用【杀】指定其他角色为目标时，你获得1枚“椎”标记。",
	["mouchui"] = "椎",
	["@moulveyingg_ghcc"] = "你可以视为使用一张【过河拆桥】",
	["moulveyinggUsed"] = "",
	["$moulveyingg1"] = "避实击虚，吾可不惮尔等蛮力！",
	["$moulveyingg2"] = "疾步如风，谁人可视吾影！",
	--莺舞
	["mouyingwuu"] = "莺舞",
	[":mouyingwuu"] = "当你使用非伤害类普通锦囊牌结算结束后，若你的“椎”标记数不小于2，你移去2枚“椎”标记，摸一张牌，然后可以视为使用一张【杀】（不计次）。<font color='green'><b>出牌阶段限两次，</b></font>当你使用非伤害类普通锦囊牌指定一名角色为目标时，若你有技能“掠影”，你获得1枚“椎”标记。",
	["@mouyingwuu_slash"] = "你可以视为使用一张不计入次数的【杀】",
	["mouyingwuuUsed"] = "",
	["$mouyingwuu1"] = "莺舞曼妙，杀机亦藏其中！",
	["$mouyingwuu2"] = "莺翼之羽，便是诛汝之锋！",
	--阵亡
	["~mou_liuchengg"] = "此番寻药未果，怎医叙儿之疾......",

	--谋华雄
	--初版（耀武+扬威）
	["mou_huaxiong_nine"] = "谋华雄-初版",
	["&mou_huaxiong_nine"] = "谋华雄",
	["#mou_huaxiong_nine"] = "跋扈雄狮",
	["designer:mou_huaxiong_nine"] = "官方",
	["cv:mou_huaxiong_nine"] = "官方",
	["illustrator:mou_huaxiong_nine"] = "佚名",
	--阵亡
	["~mou_huaxiong_nine"] = "小小马弓手，竟(然)..啊......",

	--魔将之泪
	["mou_huaxiong_GKSM"] = "谋华雄-魔将之泪",
	["&mou_huaxiong_GKSM"] = "谋华雄",
	["#mou_huaxiong_GKSM"] = "日落雄狮",
	["designer:mou_huaxiong_GKSM"] = "死吗√咔,时光流逝FC",
	["cv:mou_huaxiong_GKSM"] = "官方",
	["illustrator:mou_huaxiong_GKSM"] = "佚名",
	--耀武（同界华雄）
	--扬威
	["mouyangweii"] = "扬威",
	["mouyangweiiMark"] = "扬威",
	["mouyangweiiSlashMore"] = "扬威",
	["mouyangweiiSlashNL"] = "扬威",
	["mouyangweiiSlashPF"] = "扬威",
	[":mouyangweii"] = "出牌阶段限一次，你可以摸两张牌且本阶段获得“威”标记，然后此技能失效直到下个回合的结束阶段（拥有“威”标记的角色使用【杀】的次数上限+1、使用【杀】无距离限制且无视防具）。",
	["mouwei"] = "威",
	["mouyangweiiUsed"] = "",
	["$mouyangweii1"] = "哈哈哈哈！现在谁不知我华雄？",
	["$mouyangweii2"] = "定要关外诸侯，知我威名！",
	--免费
	["mhxmianfei"] = "免费",
	["mhxmianfeii"] = "免费",
	["mhxtiyan"] = "",
	["mou_huaxiong_GKSQJ"] = "谋华雄-魔将之泪",
	[":mhxmianfei"] = "觉醒技，①你的第二个回合开始时，你将护甲重置为1；②当你受到伤害后，你将体力值重置为2(体力上限小于2则重置为体力上限值)并将护甲重置为1。（数字为觉醒先后次序）",
	["mhxmianfeiFX"] = "狗卡NM$L",
	["mhxmianfeiSX"] = "√裃泉伽豹避",
	["$mhxmianfei1"] = "俞涉小儿，岂是我的对手！", --一重醒(削成马)
	["$mhxmianfei2"] = "上将潘凤？哼！还不是死在我刀下！", --二重醒(削到狗都不玩)
	--阵亡
	["~mou_huaxiong_GKSM"] = "小小马弓手，竟(然)..啊......", --音源到了“然”处有刺音，故作删减。

	--[协力]--
	["XL_tongchou"] = "协力[同仇]",
	["@XL_tongchou"] = "协力[同仇]",
	[":&XL_tongchou"] = "共计造成至少4点伤害",
	["XL_tongchouu"] = "协力[同仇](共计造成至少4点伤害)",
	["XL_bingjin"] = "协力[并进]",
	["@XL_bingjin"] = "协力[并进]",
	[":&XL_bingjin"] = "共计摸至少八张牌",
	["XL_bingjinn"] = "协力[并进](共计摸至少八张牌)",
	["XL_shucai"] = "协力[疏财]",
	[":&XL_shucai"] = "共计弃置四种花色的牌",
	["XL_shucaii"] = "协力[疏财](共计弃置四种花色的牌)",
	["@XL_shucai_heart"] = "",
	["@XL_shucai_diamond"] = "",
	["@XL_shucai_club"] = "",
	["@XL_shucai_spade"] = "",
	["XL_luli"] = "协力[戮力]",
	[":&XL_luli"] = "共计使用或打出四种花色的牌",
	["XL_lulii"] = "协力[戮力](共计使用或打出四种花色的牌)",
	["@XL_luli_heart"] = "",
	["@XL_luli_diamond"] = "",
	["@XL_luli_club"] = "",
	["@XL_luli_spade"] = "",
	["XL_success"] = "协力成功",
	["$XL_success"] = "在 %from 与 %to 的共同努力下，%from <font color='yellow'><b>协力</b></font> <font color='red'><b>成功</b></font>！",
	["XL_death"] = "协力失效",
	----------

	--谋赵云
	--标准版
	["mou_zhaoyunn"] = "谋赵云",
	["#mou_zhaoyunn"] = "七进七出",
	["designer:mou_zhaoyunn"] = "官方",
	["cv:mou_zhaoyunn"] = "官方",
	["illustrator:mou_zhaoyunn"] = "佚名",
	--龙胆
	["moulongdann"] = "龙胆",
	[":moulongdann"] = "剩余可用X次，你可以以【杀】当【闪】，以【闪】当【杀】使用或打出，然后摸一张牌。（X初始为1且至多为3；每名角色的回合结束时，X加1）",
	["moulongdannLast"] = "龙胆剩余",
	["$moulongdann1"] = "长坂沥赤胆，佑主成忠名！",
	["$moulongdann2"] = "龙驹染碧血，银枪照丹心！",
	--积著
	["moujizhuoo"] = "积著",
	[":moujizhuoo"] = "准备阶段，你可以选择一名其他角色，与其进行“协力”。其结束阶段，若你与其“协力”成功，直到你的下一个结束阶段，你将“龙胆”改为：" ..
		"剩余可用X次，你可以将一张基本牌当任意一种基本牌使用或打出，然后摸一张牌。（X初始为1且至多为<font color='red'><b>4</b></font>；每名角色的回合结束时，X加1）",
	["@XL-jizhuo"] = "请选择一名其他角色与你进行“协力”，“协力”成功可升级“龙胆”",
	["jizhuoFrom"] = "",
	["jizhuoTo"] = "",
	["$moujizhuoo1"] = "义贯金石，忠以卫上！", --开始协力
	["$moujizhuoo2"] = "兴汉伟功，从今始成！", --协力成功
	["$moujizhuoo3"] = "遵奉法度，功效可书！", --升级龙胆
	--龙胆升级版/威力加强版原版
	["moulongdannEX"] = "龙胆",
	[":moulongdannEX"] = "剩余可用X次，你可以将一张基本牌当任意一种基本牌使用或打出，然后摸一张牌。（X初始为1且至多为<font color='red'><b>4</b></font>；每名角色的回合结束时，X加1）",
	["moulongdannEX_list"] = "龙胆",
	["moulongdannEX_slash"] = "龙胆",
	["moulongdannEX_saveself"] = "龙胆",
	["$moulongdannEX1"] = "长坂沥赤胆，佑主成忠名！",
	["$moulongdannEX2"] = "龙驹染碧血，银枪照丹心！",
	--阵亡
	["~mou_zhaoyunn"] = "汉室未兴，功业未成......",

	--威力加强版
	["mou_zhaoyunnEX"] = "谋赵云-威力加强版",
	["&mou_zhaoyunnEX"] = "谋赵云",
	["#mou_zhaoyunnEX"] = "七进七出",
	["designer:mou_zhaoyunnEX"] = "时光流逝FC",
	["cv:mou_zhaoyunnEX"] = "官方",
	["illustrator:mou_zhaoyunnEX"] = "(皮肤:桃灼鹊跃)",
	--龙胆（同原版的升级版）
	--["moulongdannEXLast"] = "龙胆剩余",
	--积著
	["moujizhuooEX"] = "积著",
	[":moujizhuooEX"] = "准备阶段，你可以选择一名其他角色，与其进行“协力”。其结束阶段，若你与其“协力”成功，你令“龙胆”中的X+1，且直到你的下一个结束阶段，你将“龙胆”改为：" ..
		"剩余可用X次，你可以将一张手牌当任意一种基本牌使用或打出，然后摸一张牌。（X初始为1且无上限；每名角色的回合结束时，X加1）",
	["@XL-jizhuoEX"] = "请选择一名其他角色与你进行“协力”，“协力”成功可增加“龙胆”可使用次数并升级“龙胆”",
	["jizhuoEXFrom"] = "",
	["jizhuoEXTo"] = "",
	["$moujizhuooEX1"] = "义贯金石，忠以卫上！", --开始协力
	["$moujizhuooEX2"] = "兴汉伟功，从今始成！", --协力成功
	["$moujizhuooEX3"] = "遵奉法度，功效可书！", --升级龙胆
	--龙胆威力加强升级版
	["moulongdannEXEX"] = "龙胆",
	[":moulongdannEXEX"] = "剩余可用X次，你可以将一张手牌当任意一种基本牌使用或打出，然后摸一张牌。（X初始为1且无上限；每名角色的回合结束时，X加1）",
	["moulongdannEXEX_list"] = "龙胆",
	["moulongdannEXEX_slash"] = "龙胆",
	["moulongdannEXEX_saveself"] = "龙胆",
	["$moulongdannEXEX1"] = "长坂沥赤胆，佑主成忠名！",
	["$moulongdannEXEX2"] = "龙驹染碧血，银枪照丹心！",
	--阵亡
	["~mou_zhaoyunnEX"] = "汉室未兴，功业未成......",

	--谋张飞
	--正式版
	["mou_zhangfeii"] = "谋张飞",
	["#mou_zhangfeii"] = "义付桃园",
	["designer:mou_zhangfeii"] = "官方",
	["cv:mou_zhangfeii"] = "官方",
	["illustrator:mou_zhangfeii"] = "佚名",
	--咆哮
	["moupaoxiaoo"] = "咆哮",
	["moupaoxiaooHWtMD"] = "咆哮",
	["moupaoxiaooooo"] = "咆哮",
	[":moupaoxiaoo"] = "锁定技，你使用【杀】无次数限制；若你装备有武器牌，你使用【杀】无距离限制。若你于出牌阶段使用过【杀】，你于此阶段使用【杀】指定的目标本回合非锁定技失效，且此【杀】不可被响应、伤害+1。此【杀】造成伤害后，若目标角色未死亡，你失去1点体力并随机弃置一张手牌。",
	["$moupaoxiaoo1"] = "我乃燕人张飞，尔等休走！",
	["$moupaoxiaoo2"] = "战又不战，退又不退，却是何故！",
	--协击
	["mouxiejii"] = "协击",
	[":mouxiejii"] = "准备阶段，你可以选择一名其他角色，与其进行“协力”。其结束阶段，若你与其“协力”成功，你可以选择至多三名角色，依次视为对这些角色使用一张【杀】（无视距离），且此【杀】造成伤害后，你摸等同于伤害值的牌。",
	["@XL-xieji"] = "请选择一名其他角色与你进行“协力”，“协力”成功可白嫖三张【杀】",
	["xiejiFrom"] = "",
	["xiejiTo"] = "",
	["@mouxiejii-slash"] = "你可以选择至多三名角色，依次视为对他们使用【杀】",
	["~mouxiejii"] = "按技能描述来说，其实你可以选自己？",
	["mouxiejiiS"] = "协击",
	["$mouxiejii1"] = "二哥，俺来助你！", --开始协力
	["$mouxiejii2"] = "兄弟三人协力，破敌只在须臾！", --协力成功
	["$mouxiejii3"] = "吴贼害我手足，此仇今日当报！", --开杀
	--阵亡
	["~mou_zhangfeii"] = "不恤士卒，终为小人所害！...",

	--爆料版(5月)
	["mou_zhangfeiBN"] = "谋张飞-爆料版",
	["&mou_zhangfeiBN"] = "谋张飞",
	["#mou_zhangfeiBN"] = "当阳绝勇",
	["designer:mou_zhangfeiBN"] = "官方",
	["cv:mou_zhangfeiBN"] = "官方",
	["illustrator:mou_zhangfeiBN"] = "佚名",
	--咆哮（同正式版）
	--协击
	["mouxiejiBN"] = "协击",
	[":mouxiejiBN"] = "准备阶段，你可以选择一名其他角色。若如此做，本回合你使用的【杀】造成的伤害+1，且其下回合结束时，若你与其于此期间造成过的伤害值相同，你与其各摸两张牌。",
	["mouxiejiBNFrom"] = "协击",
	["mouxiejiBNHelp"] = "协击",
	["mouxiejiBNDamage"] = "协击伤害",
	["$mouxiejiBN1"] = "二哥，俺来助你！", --选择角色
	["$mouxiejiBN2"] = "兄弟三人协力，破敌只在须臾！", --成功摸牌
	["$mouxiejiBN3"] = "吴贼害我手足，此仇今日当报！", --加伤
	--阵亡
	["~mou_zhangfeiBN"] = "不恤士卒，终为小人所害！...",

	--FC谋关羽
	["fc_mou_guanyu"] = "FC谋关羽",
	["&fc_mou_guanyu"] = "☆谋关羽",
	["#fc_mou_guanyu"] = "名传千古",
	["designer:fc_mou_guanyu"] = "时光流逝FC",
	["cv:fc_mou_guanyu"] = "官方",
	["illustrator:fc_mou_guanyu"] = "白",
	--武圣
	["fcmouwusheng"] = "武圣",
	["fcmouwushengDiamond"] = "武圣",
	["fcmouwushengHeart"] = "武圣",
	[":fcmouwusheng"] = "你可以将一张红色牌当【杀】使用或打出；你使用方块【杀】无距离限制、红桃【杀】伤害+1。",
	["$fcmouwusheng1"] = "青龙知酒温，饮尽贼酋血！",
	["$fcmouwusheng2"] = "刀饮青龙血，马踏佞鬼魂！",
	--义绝
	["fcmouyijue"] = "义绝",
	["fcmouyijueBuffANDClear"] = "义绝",
	[":fcmouyijue"] = "出牌阶段限一次，你可以弃置一张牌，与一名其他角色进行“谋弈”：\
	<font color='red'><b>成功</b></font>：该角色视为被你“义绝”（非锁定技失效、不能使用或打出手牌、你使用红色【杀】对其造成的伤害+1）直到回合结束；\
	<font color='black'><b>失败</b></font>：你展示该角色区域里的一张牌并获得之，然后你可以令其回复1点体力。",
	["@MouYi-yijue"] = "谋弈：义绝",
	["@MouYi-yijue:F1"] = "威震华夏，红牌当杀",
	["@MouYi-yijue:F2"] = "无名小卒，一轮八十牌",
	["@MouYi-yijue:T1"] = "威震华夏，义薄云天",
	["@MouYi-yijue:T2"] = "无名小卒，被无双万军取首",
	["$MouYi_success"] = "%from 对 %to <font color='yellow'><b>谋弈</b></font> <font color='red'><b>成功</b></font>！",
	["$MouYi_fail"] = "%from 对 %to <font color='yellow'><b>谋弈</b></font> <font color='blue'><b>失败</b></font>",
	["@fcmouyijue-Recover"] = "[义绝]令其回复体力",
	["$fcmouyijue1"] = "降汉不降曹，斩佞不斩忠！", --谋弈
	["$fcmouyijue2"] = "心念桃园兄弟义，不背屯土忠君誓！", --谋弈
	["$fcmouyijue3"] = "青龙嬉江海，虎将破敌酋！", --增伤
	["$fcmouyijue4"] = "黯云从龙，啸风从虎！", --增伤
	--阵亡
	["~fc_mou_guanyu"] = "哈哈哈哈哈哈哈哈哈！有死而已，何必多言。",

	--谋孙尚香
	["mou_sunshangxiangg"] = "谋孙尚香",
	["#mou_sunshangxiangg"] = "骄豪明俏",
	["designer:mou_sunshangxiangg"] = "官方",
	["cv:mou_sunshangxiangg"] = "官方",
	["illustrator:mou_sunshangxiangg"] = "佚名",
	--良助
	["mouliangzhuu"] = "良助",
	[":mouliangzhuu"] = "蜀势力技，出牌阶段限一次，你可以将其他角色装备区里的一张牌置于你的武将牌上，称为“妆”，然后令拥有“助”标记的角色选择一项：1.回复1点体力；2.摸两张牌。",
	["mouJiaZhuang"] = "妆",
	["mouliangzhuu:1"] = "回复1点体力",
	["mouliangzhuu:2"] = "摸两张牌",
	["$mouliangzhuu1"] = "助君得胜战，跃马提缨枪！",
	["$mouliangzhuu2"] = "平贼成君业，何惜上沙场！",
	--结姻
	["moujieyinn"] = "结姻", --使命成功是我自己编的，其实官方技能描述中并没有
	[":moujieyinn"] = "<font color='red'><b>使</b></font><font color='green'><b>命</b></font><b>技</b>。游戏开始时，你令一名其他角色获得1枚“助”标记。出牌阶段开始时，你令有“助”标记的角色选择一项：" ..
		"1.若其有手牌，交给你两张手牌(不足则全给)，然后其获得1点护甲；2.令你移交或移除其“助”标记（若其不为第一次失去“助”标记，则只能选择移除）。\
	使命<font color='red'><b>成功</b></font>：直到游戏结束，场上的“助”标记都未被移除，“婚姻”圆满持续下去；\
	使命<font color='green'>失败</b></font>：当场上的(所有)“助”标记被移除出游戏时，“婚姻”破裂，你将要“返乡”：回复1点体力并获得你武将牌上的所有“妆”，然后你将势力变更为“吴”并减1点体力上限。",
	["mouHusband"] = "助",
	["@moujieyinn-start"] = "请选择一名其他角色，令其获得1枚“助”标记",
	["moujieyinn:1"] = "交给其两张手牌(不足则全给)并获得1点护甲",
	["moujieyinn:2"] = "令其移交或移除你的“助”标记",
	["moujieyinn:3"] = "令其移除你的“助”标记",
	["moujieyinn:4"] = "你移交其“助”标记给另一名角色",
	["moujieyinn:5"] = "你移除其“助”标记(若如此做,你的使命将失败)",
	["mouHusbandMarkLost"] = "已失去过[助]标记",
	["#moujieyinn"] = "请交给 %src 两张手牌，然后获得1点护甲",
	["@moujieyinn-markmove"] = "请将该角色的“助”标记移交给除其之外的一名角色",
	["moujieyinn_fail"] = "",
	["$moujieyinn_success"] = "上邪！我欲与君相知，长命无绝衰。\
	山无陵，江水为竭，冬雷震震，\
	夏雨雪，天地合，乃敢与君绝。",
	["$moujieyinn1"] = "君若不负吾心，妾自随君千里！", --一名角色得到“助”标记/护甲
	["$moujieyinn2"] = "夫妻之情既断，何必再问归期！", --使命失败
	--枭姬
	["mouxiaojii"] = "枭姬",
	[":mouxiaojii"] = "吴势力技，当你失去装备区里的一张牌时，你摸两张牌，然后你可以弃置场上的一张牌。",
	["@mouxiaojii-throw"] = "你可以弃置场上的一张牌",
	["$mouxiaojii1"] = "吾之所通，何止十八般兵刃！",
	["$mouxiaojii2"] = "既如此，就让尔等见识一番！",
	--阵亡
	["~mou_sunshangxiangg"] = "此去一别，竟无再见之日......",

	--谋马超
	["mou_machaoo"] = "谋马超",
	["#mou_machaoo"] = "阻戎负勇",
	["designer:mou_machaoo"] = "官方",
	["cv:mou_machaoo"] = "官方",
	["illustrator:mou_machaoo"] = "佚名",
	--马术（-1马）
	--铁骑
	["moutieqii"] = "铁骑",
	["moutieqiiClear"] = "铁骑",
	[":moutieqii"] = "当你使用【杀】指定一名角色为目标时，你可以令其非锁定失效直到回合结束，且其不能使用【闪】响应此【杀】，然后你与其进行“谋弈”：\
	<b>直取敌营</b>：若成功，你获得其一张牌；\
	<b>扰阵疲敌</b>：若成功，你摸两张牌。",
	["@MouYi-tieqi"] = "谋弈：铁骑",
	["@MouYi-tieqi:F1"] = "直取敌营(获得目标的一张牌)",
	["@MouYi-tieqi:F2"] = "扰阵疲敌(摸两张牌)",
	["@MouYi-tieqi:T1"] = "拱卫中军(防止对手获得你的牌)",
	["@MouYi-tieqi:T2"] = "出阵迎战(防止对手摸牌)",
	["$moutieqii1"] = "你可闪得过此一击！！", --锁技能+强命
	["$moutieqii2"] = "厉马秣兵，只待今日！", --谋弈
	["$moutieqii3"] = "敌军防备空虚，出击直取敌营！", --抢牌成功
	["$moutieqii4"] = "敌军早有防备，先行扰阵疲敌！", --摸牌成功
	["$moutieqii5"] = "全军速撤回营，以期再觅良机！", --谋弈失败
	--阵亡
	["~mou_machaoo"] = "父兄妻儿俱丧，吾有何面目活于世间......", --父亲！不能为汝报仇雪恨矣......

	--谋杨婉
	["mou_yangwann"] = "谋杨婉",
	["#mou_yangwann"] = "迷计惑心",
	["designer:mou_yangwann"] = "官方",
	["cv:mou_yangwann"] = "官方",
	["illustrator:mou_yangwann"] = "佚名",
	--暝眩
	["moumingxuann"] = "暝眩",
	[":moumingxuann"] = "锁定技，出牌阶段开始时，若你有手牌且有未被“暝眩”记录的其他角色，你选择至多X张花色各不相同的手牌（X为未被“暝眩”记录的其他角色数），将这些牌随机交给等量未被“暝眩”记录的其他角色各一张，然后依次令这些角色选择一项：1.对你使用一张【杀】，然后你记录其；2.交给你一张牌，并令你摸一张牌。",
	--["moumingxuann:1"] = "对其使用一张【杀】，然后被记录为“暝眩”对象",
	--["moumingxuann:2"] = "交给其一张牌并令其摸一张牌",
	["moumingxuannCardGive"] = "",
	["@moumingxuann-card"] = "请选择至多为未被“暝眩”记录的其他角色数的花色各不相同的手牌，并选择你想将这些牌交予的可选择对象",
	["~moumingxuann"] = "选好手牌后，点场上未有“暝眩”标记的若干名其他角色，选好后点【确定】",
	["@moumingxuann-slash"] = "请对 %src 使用一张【杀】（会被记录为“暝眩”对象），否则你交给 %src 一张牌并令 %src 摸一张牌",
	["#moumingxuann"] = "请交给 %src 一张牌，然后令 %src 摸一张牌",
	["$moumingxuann1"] = "闻汝节行俱佳，今特设宴相请。",
	["$moumingxuann2"] = "百闻不如一见，夫人果真非凡。",
	--陷仇
	["mouxianchouu"] = "陷仇",
	[":mouxianchouu"] = "当你受到伤害后，你可以选择一名不为伤害来源的其他角色，其可以弃置一张牌，视为对伤害来源使用一张无距离与次数限制的【杀】。此【杀】结算结束后，若此【杀】造成过伤害，其摸两张牌，你回复1点体力。",
	["@mouxianchouu-fujunAvanger"] = "请选择一名不为伤害来源的其他角色为你报仇",
	["@mouxianchouu-slash"] = "你可以弃置一张牌，视为对伤害来源使用一张无距离与次数限制的【杀】",
	["$mouxianchouu1"] = "夫君勿忘，杀妻害子之仇！",
	["$mouxianchouu2"] = "吾母子之仇，便全靠夫君来报了！",
	--阵亡
	["~mou_yangwann"] = "引狗入寨，悔恨交加啊......",

	--谋孙权
	["mou_sunquann"] = "谋孙权",
	["#mou_sunquann"] = "江东大帝",
	["designer:mou_sunquann"] = "官方",
	["cv:mou_sunquann"] = "官方",
	["illustrator:mou_sunquann"] = "佚名",
	--制衡
	["mouzhihengg"] = "制衡",
	[":mouzhihengg"] = "出牌阶段限一次，你可以弃置任意张牌，然后摸等量的牌。若你以此法弃置了所有手牌，你额外摸X+1张牌（X为你的“业”标记数），然后你弃置1枚“业”标记。",
	["$mouzhihengg1"] = "稳坐山河，但观事变！",
	["$mouzhihengg2"] = "身处惊涛，犹可弄潮！",
	--统业
	["moutongyee"] = "统业",
	[":moutongyee"] = "锁定技，结束阶段，你进行一次“推测”：直到你下个回合的准备阶段，场上的装备数[变/不变]。则你下个回合的准备阶段，若你“推测”正确，你获得1枚“业”标记，否则你弃置1枚“业”标记（“业”标记至多2枚）。",
	["mouYE"] = "业",
	["@TuiCe-tongye"] = "推测：统业",
	["@TuiCe-tongye:change"] = "变",
	["@TuiCe-tongye:unchanged"] = "不变",
	["$TuiCe_change"] = "%from 推测，从此阶段到其下个回合的准备阶段，场上的装备数 <font color='red'><b>变</b></font>",
	["$TuiCe_unchanged"] = "%from 推测，从此阶段到其下个回合的准备阶段，场上的装备数 <font color='yellow'><b>不变</b></font>",
	["moutongyee_change"] = "统业-变",
	["moutongyee_unchanged"] = "统业-不变",
	["moutongyee_equiplength"] = "",
	["$TuiCe_success"] = "%from <font color='yellow'><b>推测</b></font> <font color='red'><b>正确</b></font>！",
	["$TuiCe_fail"] = "%from <font color='yellow'><b>推测</b></font> <font color='blue'><b>错误</b></font>",
	["$moutongyee1"] = "上下一心，君臣同志！",
	["$moutongyee2"] = "胸有天下者，必可得其国！",
	--救援
	["moujiuyuann"] = "救援",
	[":moujiuyuann"] = "主公技，锁定技，当其他“吴”势力角色使用【桃】时，你摸一张牌，且若目标角色为你，此【桃】回复值+1。",
	["$moujiuyuann"] = "因为“<font color='yellow'><b>救援</b></font>”的效果，此【<font color='yellow'><b>桃</b></font>】对 %to 的回复值+1",
	["$moujiuyuann1"] = "诸位将军，快快拦住贼军！", --其他“吴”势力角色使用【桃】
	["$moujiuyuann2"] = "汝救护有功，吾必当厚赐！", --回复值+1
	--阵亡
	["~mou_sunquann"] = "风疾噱发，命不久矣......",

	--谋吕蒙
	["mou_lvmengg"] = "谋吕蒙",
	["#mou_lvmengg"] = "苍江一笠",
	["designer:mou_lvmengg"] = "官方",
	["cv:mou_lvmengg"] = "官方",
	["illustrator:mou_lvmengg"] = "佚名",
	--克己
	["moukejii"] = "克己",
	["moukejiiMaxCards"] = "克己",
	["moukejiiGuR"] = "克己的孤儿",
	[":moukejii"] = "<font color='green'><b>出牌阶段<font color='red'><b>每个选项各</b></font>限一次</b></font>（若你已触发“渡江”的觉醒，红字部分将无效化）：\
	1.弃置一张手牌，获得1点护甲；\
	2.失去1点体力(无视护甲)，获得2点护甲。\
	你的手牌上限+X；当你不处于濒死状态时，你不能使用【桃】。（X为你的护甲数）",
	--<font color='purple'>◆特别注意：神杀的护甲机制与手杀官方有所区别，可以挡体力流失，故在无护甲时发动此技能，如若想叠更多的护甲请一定记得先2后1，以防止白白浪费1点护甲拖延觉醒进度。</font>",
	["moukejii:1"] = "弃置一张手牌，获得1点护甲",
	["moukejii:2"] = "失去1点体力，获得2点护甲",
	["cancel"] = "取消",
	["$moukejii1"] = "事事克己，步步虚心。",
	["$moukejii2"] = "勤学潜习，始觉自新。",
	--渡江
	["moudujiangg"] = "渡江",
	[":moudujiangg"] = "觉醒技，准备阶段，若你的护甲不少于3，你获得技能“夺荆”。",
	["$moudujiangg1"] = "大军浮江，昼夜驰上！",
	["$moudujiangg2"] = "白衣摇橹，昼夜兼行！",
	--夺荆
	["moudj_duojing"] = "夺荆",
	["moudj_duojingg"] = "夺荆",
	[":moudj_duojing"] = "当你使用【杀】指定一名角色为目标时，你可以失去1点护甲，令此【杀】无视防具，然后你获得目标的一张牌且你本阶段使用【杀】的次数上限+1。",
	["$moudj_duojing1"] = "快舟轻甲，速袭其后！",
	["$moudj_duojing2"] = "复取荆州，尽在掌握！",
	--阵亡
	["~mou_lvmengg"] = "义封胆略过人，主公可任之......",

	--谋徐晃
	["mou_xuhuangg"] = "谋徐晃",
	["#mou_xuhuangg"] = "径行截辎",
	["designer:mou_xuhuangg"] = "官方",
	["cv:mou_xuhuangg"] = "官方",
	["illustrator:mou_xuhuangg"] = "佚名",
	--断粮
	["mouduanliangg"] = "断粮",
	[":mouduanliangg"] = "出牌阶段限一次，你可以与一名其他角色进行“谋弈”：\
	<b>围城断粮</b>：若成功，你将牌堆顶的一张牌当无距离限制的【兵粮寸断】对其使用（若其判定区中已有【兵粮寸断】，则改为获得其一张牌）；\
	<b>擂鼓进军</b>：若成功，你视为对其使用一张【决斗】。",
	["@MouYi-duanliang"] = "谋弈：断粮",
	["@MouYi-duanliang:F1"] = "围城断粮(直接饿死你不多哔哔)",
	["@MouYi-duanliang:F2"] = "擂鼓进军(有本事就与老子单挑)",
	["@MouYi-duanliang:T1"] = "全军突击(防止对手断你粮草)",
	["@MouYi-duanliang:T2"] = "闭门守城(防止对手决斗你)",
	["mouduanliangv"] = "断粮",
	["$mouduanliangg1"] = "常读兵法，终有良策也！", --谋弈
	["$mouduanliangg2"] = "烧敌粮草，救主于危急！", --成功使用兵粮
	["$mouduanliangg3"] = "敌陷混乱之机，我军可长驱直入！", --成功发起决斗
	["$mouduanliangg4"] = "敌既识破吾计，则断不可行矣！", --谋弈失败
	--势迫
	["moushipoo"] = "势迫",
	[":moushipoo"] = "结束阶段，你可以令一名体力值小于你的角色或所有判定区里有【兵粮寸断】的其他角色依次选择一项：1.交给你一张手牌；2.受到1点伤害。若你以此法获得了牌，则你可以将其中任意张牌交给一名其他角色。",
	["moushipoo:1"] = "威胁一名体力比你少的角色",
	["moushipoo:2"] = "对所有判定区有【兵粮寸断】的其他角色发出宣告",
	["moushipoo:3"] = "交给其一张手牌",
	["moushipoo:4"] = "受到其对你造成的1点伤害",
	["moushipoo_KHxd"] = "请选择一名体力值小于你的角色",
	["#moushipoo"] = "请交给 %src 一张手牌",
	["@moushipoo-give"] = "[势迫]给牌",
	["moushipoo_givecards"] = "请选择一名其他角色，将你获得的这张牌交予之",
	["@moushipoo-card"] = "请选择任意张你获得的牌，交给一名其他角色",
	["~moushipoo"] = "点击你想交予的可被选择的牌，点【确定】",
	["$moushipoo1"] = "已向尔等陈明利害，奉劝尔等早日归降！", --威胁
	["$moushipoo2"] = "此时归降或可封赏，及至城破立斩无赦！", --宣告
	--阵亡
	["~mou_xuhuangg"] = "为主效劳，何畏生死......",

	--谋于禁
	["mou_yujin_first"] = "谋于禁-初版", --和谋华雄一样，正式版我不会去写。
	["&mou_yujin_first"] = "谋于禁",
	["#mou_yujin_first"] = "威严毅重",
	["designer:mou_yujin_first"] = "官方",
	["cv:mou_yujin_first"] = "官方",
	["illustrator:mou_yujin_first"] = "佚名",
	--狭援
	["mouxieyuann"] = "狭援",
	[":mouxieyuann"] = "每轮限一次，当其他角色受到伤害后，若此次伤害令其失去了全部的护甲，你可以弃置两张手牌，令其重新获得因此失去的护甲。",
	["mouxieyuann_hujiaCount"] = "",
	["$mouxieyuann1"] = "速置粮草，驰援天柱山！",
	["$mouxieyuann2"] = "援军既至，定攻克此地！",
	--节钺
	["moujieyuee"] = "节钺",
	[":moujieyuee"] = "结束阶段，你可以令一名其他角色获得1点护甲，然后其<font color='red'><b>摸两张牌并交给你两张牌</b></font>。",
	["moujieyuee-givehujia"] = "请选择一名其他角色给其套盾",
	["#moujieyuee"] = "请交给 %src 两张牌作为回报，感谢！",
	["$moujieyuee1"] = "调兵遣将，以御敌势！",
	["$moujieyuee2"] = "侧翼迎敌，拱卫中军！", --嗯？就是你小子单防的谋神？
	--阵亡
	["~mou_yujin_first"] = "禁......愧于丞相......",

	--FC文鸯
	["fc_wenyang"] = "FC文鸯<谋攻篇附赠>",
	["&fc_wenyang"] = "☆文鸯",
	["#fc_wenyang"] = "合二为一",
	["designer:fc_wenyang"] = "时光流逝FC",
	["cv:fc_wenyang"] = "官方",
	["illustrator:fc_wenyang"] = "时光流逝FC",
	--却敌
	["fcquedi"] = "却敌",
	["fcquediDamage"] = "却敌",
	[":fcquedi"] = "<font color='green'><b>每个回合限一次<font color='blue'>（可通过“波折”加为两次）</font>，</b></font>当你使用【杀】或【决斗】指定唯一目标后，你可以选择一项：1.获得其一张手牌；2.弃置一张基本牌令此牌伤害+1；3.[背水]减1点体力上限，然后依次执行前两项。",
	--["fcquedii"] = "却敌",
	--[":fcquedii"] = "<font color='green'><b>每个回合限两次，</b></font>当你使用【杀】或【决斗】指定唯一目标后，你可以选择一项：1.获得其一张手牌；2.弃置一张基本牌令此牌伤害+1；3.[背水]减1点体力上限，然后依次执行前两项。",
	["fcquedi:obtain"] = "获得%src一张手牌",
	["fcquedi:damage"] = "此牌伤害+1",
	["fcquedi:beishui"] = "[背水]减1点体力上限，依次执行前两项",
	["@fcquedi-basic"] = "请弃置一张基本牌",
	["$fcquedi1"] = "力摧敌阵，如视天光破云！",
	["$fcquedi2"] = "让尔等有命追，无命回！",
	--仇决
	["fcchoujue"] = "仇决",
	[":fcchoujue"] = "锁定技，当你杀死一名其他角色时，你加1点体力上限，摸两张牌，本回合可额外发动一次“却敌”。",
	[":&fcchoujue"] = "本回合你可以额外发动%src次“却敌”",
	["$fcchoujue1"] = "血海深仇，便在今日来报！",
	["$fcchoujue2"] = "取汝之头，以祭先父！",
	--棰锋
	["fcchuifeng"] = "棰锋",
	["fcchuifengDamaged"] = "棰锋",
	[":fcchuifeng"] = "<font color='green'><b>出牌阶段限两次，</b></font>你可以失去1点体力，视为使用一张【决斗】，然后若你因此受到伤害，你防止此伤害且本阶段此技能失效。",
	["$fcchuifeng1"] = "率军冲锋，不惧刀枪所阻！",
	["$fcchuifeng2"] = "登锋履刃，何妨马革裹尸！",
	--冲坚
	["fcchongjian"] = "冲坚",
	["fcchongjianNL"] = "冲坚",
	["fcchongjianPFandPE"] = "冲坚",
	[":fcchongjian"] = "你可以将一张装备牌当【酒】或无距离限制且无视防具的任意一种【杀】使用。你以此法使用的【杀】对目标角色造成伤害后，你获得该角色装备区里等同于此次伤害值数的牌。",
	["$fcchongjianPlunderEquips"] = "通过发动“<font color='yellow'><b>冲坚</b></font>”，%from 总计斩获了 %to 的 %arg2 张装备区里的牌作为<font color='red'>战利品</font>",
	["$fcchongjian1"] = "尔等良将，于我不堪一击！",
	["$fcchongjian2"] = "此等残兵，破之何其易也！",
	--波折
	["fcbozhe"] = "波折",
	["fcbozheWU"] = "波折",
	["fcbozheJIN"] = "波折",
	[":fcbozhe"] = "魏势力技，锁定技，<b>联动技，</b>游戏开始后，若主公为“魏”势力，你将“却敌”改为“每个回合限两次”；你对“晋”势力角色或名字带有“司马”的角色使用的基本牌伤害+1、锦囊牌不可被响应；\
	吴势力技，锁定技，你与“魏”势力和“晋”势力角色的距离视为1；\
	游戏开始后，若主公为“晋”势力，你可以变更为“晋”势力。晋势力技，锁定技，你对非“晋”势力角色使用牌无次数限制。",
	["fcbozheWeiMoreQuedi"] = "",
	["@fcbozhe-ChangeToJin"] = "[波折]更换为“晋”势力",
	["$fcbozhe1"] = "姿器膂力，万人之雄！", --魏（登场）
	["$fcbozhe2"] = "此击若中，万念俱灰！", --魏（加伤、强命）
	["$fcbozhe3"] = "家仇未报，怎可独安！", --吴
	["$fcbozhe4"] = "清蛮夷之乱，剿不臣之贼！", --晋
	--阵亡
	["~fc_wenyang"] = "半生功业，而见疑于一家之言，岂能无怨！...",

	--阴间之王
	["TheKingOfUnderworld"] = "阴间之王<谋攻篇附赠>",
	["&TheKingOfUnderworld"] = "大宝老宝",
	["#TheKingOfUnderworld"] = "三国杀最可爱的两个人",
	["designer:TheKingOfUnderworld"] = "时光流逝FC",
	["cv:TheKingOfUnderworld"] = "官方",
	["illustrator:TheKingOfUnderworld"] = "戏子多殇`",
	--手杀界破军+正式版谋烈弓
	--阳光
	["dabao_sunshine"] = "阳光",
	["dabao_GuDing"] = "阳光",
	["dabao_Nature"] = "阳光",
	[":dabao_sunshine"] = "吴势力技，准备阶段开始时，你可以随机执行其中一种效果：\
	1.横置至多两名角色；\
	2.视为使用了一张【酒】；\
	3.本回合对没有手牌的角色造成的伤害+1；\
	4.本回合使用的红/黑【杀】转化为火/雷【杀】。\
	你也可以改为依次执行以上所有效果，然后你失去4点体力。",
	["dabao_sunshine:mathrandom"] = "随机执行一种效果",
	["dabao_sunshine:allin"] = "我全都要(注意:会失去4点体力)",
	["@dabao_sunshine-Chain"] = "你可以横置至多两名角色",
	["~dabao_sunshine"] = "铁索连舟而行，东吴水师可破",
	["$dabao_sunshine"] = "这长江天险后，便是江东铁壁！",
	--和蔼
	["laobao_heai"] = "和蔼",
	["laobao_heaiDS"] = "和蔼",
	["laobao_heaiC"] = "和蔼",
	[":laobao_heai"] = "蜀势力技，准备阶段开始时，你可以移除一个你已记录的花色，或记录一个你未记录的花色。若你移除的记录花色为：\
	红桃，你视为使用了一张【桃】且本回合所有其他角色无法使用【桃】；\
	方块，本回合“烈弓”中的描述“唯一”无效且你使用【杀】可多指定一名目标；\
	梅花，本回合“烈弓”封印【杀】的负面效果无效且你使用属性【杀】不计入次数限制；\
	黑桃，本回合你使用【杀】无距离限制。\
	若此阶段开始前你所有花色皆已记录，你也可以改为清除所有已记录的花色，获得以上所有效果，然后你摸四张牌。",
	["laobao_heai:remove"] = "移除一个已记录的花色，获得相应效果",
	["laobao_heai:removeHeart"] = "移除【红桃♥】",
	["laobao_heai:removeDiamond"] = "移除【方块♦】",
	["laobao_heai:removeClub"] = "移除【梅花♣】",
	["laobao_heai:removeSpade"] = "移除【黑桃♠】",
	["laobao_heai:record"] = "记录一个未记录的花色",
	["laobao_heai:recordHeart"] = "记录【红桃♥】",
	["laobao_heai:recordDiamond"] = "记录【方块♦】",
	["laobao_heai:recordClub"] = "记录【梅花♣】",
	["laobao_heai:recordSpade"] = "记录【黑桃♠】",
	["laobao_heai:allin"] = "我全都要(注意:会清除所有已记录的花色)",
	["laobao_heaii"] = "和蔼",
	["$laobao_heai"] = "吾虽年迈，万军取首！",
	--阵亡
	["~TheKingOfUnderworld"] = "终归，还是难逃断杀的宿命........",

	--谋黄忠-七天体验卡 垃圾话
	["mou_huangzhongg_TrashTalk"] = "垃圾话",
	--==垃圾话内容栏==--
	--[[
	1.大家好！我叫界黄忠，是一个和善的老头（游戏开始）
	2.为什么要这样针对我？我只是一个核善的老头（一血贴乐失败）
	3.你几个桃啊，敢这么跟我说话？（回合外被砍，-2）
	4.敢这么跟我说话，你的桃是批发的？（回合外被砍，癫狂屠戮）
	5.老夫，也有被无双万军取首的一天......（回合外被砍，万军取首）
	6.[♥♦♣♠]核密码输入完成，准备随机将一位幸运玩家移除出游戏（回合内凑齐四花色）
	7.小崽子，桃挺多的啊！（回合内第二次万军取首）
	8.神周瑜？老子就是神周瑜（装上朱雀羽扇）
	--
	9.闹够了没有！界徐盛！（一刀砍死大宝）
	10.界徐盛有多远爬多远，以后阴曹地府归我管（万军取首且场上有大宝）
	11.像神甘宁这种素将以后别玩了（一刀砍死大鬼）
	12.敢看我牌，活腻了是吧？（被大鬼魄袭/被神吕蒙攻心）
	13.搁那要操作老半天，还不是老夫一刀的事情（一刀砍死大妖）
	14.我点几下鼠标你就寄了，你行不行啊？（一刀砍死大狗）
	15.推土机？下去推吧！（一刀砍死吴鸟）
	16.小崽子，可以了你别唱了，下去阴间唱吧（一刀砍到歌王进濒死）
	17.我一刀帮你觉醒，你该怎么谢我啊？（一刀砍到(界)钟会进濒死）
	18.你该不会以为我是大宝吧？（杀砍中曹昂）
	19.冲儿！我是你黄爷爷啊！（一刀砍到曹冲进濒死）
	20.小崽子，喜欢闪是吧，该吃的无双还是要吃（杀被对手闪避但仍然无双）
	--------------------
	]]


	--谋贾逵（赠送2护甲，不然适应不了现在的环境了）
	["mou_jk"] = "谋·贾逵<谋攻篇附赠>",
	["&mou_jk"] = "谋贾逵",
	["#mou_jk"] = "正气贯五州",
	["designer:mou_jk"] = "KayaK",
	["cv:mou_jk"] = "官方",
	["illustrator:mou_jk"] = "KayaK",
	--挽澜
	["mouwl"] = "挽澜",
	[":mouwl"] = "<font color='green'><b>每个回合各限一次，</b></font>1.当你使用红色牌时，你可以令一名体力值不大于你的一名角色摸一张牌；2.当你使用黑色牌时，你可以弃置一名体力值大于你的角色的一张牌。",
	["@mouwlRD"] = "挽澜-摸牌",
	["@mouwlBT"] = "挽澜-弃牌",
	["mouwl_redused"] = "",
	["mouwl_blackused"] = "",
	["mouwl_reddraw"] = "你可以令一名体力值不大于你的一名角色摸一张牌",
	["mouwl_blackthrow"] = "你可以弃置一名体力值大于你的角色的一张牌",
	["$mouwl1"] = "安民赴政，为保曹魏之兴！", --使用红色牌、摸牌
	["$mouwl2"] = "戍边定域，以巩万里河山！", --使用黑色牌、弃牌
	--阵亡
	["~mou_jk"] = "生怀死忠之心，死必为报国之鬼......",

	--谋曹操
	["mou_doublefuck"] = "谋曹操",
	["#mou_doublefuck"] = "魏武大帝",
	["designer:mou_doublefuck"] = "官方",
	["cv:mou_doublefuck"] = "官方",
	["illustrator:mou_doublefuck"] = "佚名",
	--奸雄
	["moujianxiongg"] = "奸雄",
	[":moujianxiongg"] = "游戏开始时，你可以选择获得至多2枚“治世”标记。当你受到伤害后，你可以获得对你造成伤害的牌并摸1-X张牌（X为你的“治世”标记数且不大于2；1-x>=0），然后你可以弃置1枚“治世”标记。",
	["mouGW"] = "治世",
	["@moujx_getMarks"] = "请选择你开局拥有的“治世”标记数",
	["@moujx_getMarks:0"] = "0枚",
	["@moujx_getMarks:1"] = "1枚",
	["@moujx_getMarks:2"] = "2枚",
	["@moujianxiongg-throwMark"] = "你可以弃置1枚“治世”标记，增加后续触发“奸雄”的收益",
	["$moujianxiongg1"] = "古今英雄盛世，尽赴沧海东流！",
	["$moujianxiongg2"] = "骖六龙行御九州，行四海路下八邦！",
	--清正
	["mouqingzhengg"] = "清正",
	[":mouqingzhengg"] = "出牌阶段开始时，你可以弃置手牌中3-X种花色的所有牌并选择一名有手牌的其他角色，你查看其手牌，弃置其中一种花色的所有牌，若弃置的牌数少于你弃置的牌数，你对其造成1点伤害。然后若你的“治世”标记数少于2且你有技能“奸雄”，你可以获得1枚“治世”标记。",
	["mouqingzhenggs"] = "请选择一名其他角色，之后你将查看其手牌并弃置其中一种花色的所有牌",
	["mouqingzhengg:heart"] = "弃置手牌中的所有【♥红桃】牌",
	["mouqingzhengg:diamond"] = "弃置手牌中的所有【♦方块】牌",
	["mouqingzhengg:club"] = "弃置手牌中的所有【♣梅花】牌",
	["mouqingzhengg:spade"] = "弃置手牌中的所有【♠黑桃】牌",
	["@mouqingzhengg-getMark"] = "你可以获得1枚“治世”标记，减少后续发动“清正”的代价",
	["$mouqingzhengg1"] = "立威行严法，肃佞正国纲！",
	["$mouqingzhengg2"] = "悬杖分五色，治法扬清名。",
	--护驾
	["mouhujiaa"] = "护驾",
	[":mouhujiaa"] = "主公技，每轮限一次，当你受到伤害时，你可以选择一名魏势力其他角色，你将此伤害转移给该角色。",
	["@mouhujiaa-card"] = "你可以选择一名魏势力其他角色，将伤害转移给其",
	["~mouhujiaa"] = "选择一名魏势力其他角色，点【确定】",
	["$mouhujiaa1"] = "虎贲三千，堪当敌万余！",
	["$mouhujiaa2"] = "壮士八百，足护卫吾身！",
	--阵亡
	["~mou_doublefuck"] = "狐死归首丘，故乡安可忘！",

	--谋甘宁
	--初版
	["mou_ganning_first"] = "谋甘宁-初版",
	["&mou_ganning_first"] = "谋甘宁",
	["#mou_ganning_first"] = "兴王定霸",
	["designer:mou_ganning_first"] = "官方",
	["cv:mou_ganning_first"] = "官方",
	["illustrator:mou_ganning_first"] = "佚名",
	--奇袭
	["mouqixii"] = "奇袭",
	["mouqixix"] = "奇袭",
	[":mouqixii"] = "你可以将一张黑色牌当【过河拆桥】使用。你使用的非转化非虚拟的【过河拆桥】的效果可以改为：出牌阶段，对一名区域里有牌的其他角色使用。你弃置其区域里的所有牌。",
	["$mouqixii1"] = "击敌不备，奇袭拔寨！",
	["$mouqixii2"] = "轻羽透重铠，奇袭溃坚城！",
	--奋威
	["moufenweii"] = "奋威",
	[":moufenweii"] = "限定技，当一张锦囊牌指定两个或更多目标后，你可令此牌对其中任意名目标角色无效。你每选择一名角色，就从牌堆中获得一张【过河拆桥】（至多以此法获得四张）。",
	["@moufenweii"] = "奋威",
	["@moufenweii-card"] = "你可以发动技能“奋威”",
	["~moufenweii"] = "选择任意名成为该锦囊牌目标的角色，点【确定】",
	["$moufenweii1"] = "舍身护主，扬吴将之风！",
	["$moufenweii2"] = "袭军挫阵，奋江东之威！",
	--阵亡
	["~mou_ganning_first"] = "蛮将休得猖狂！呃...呃啊！......",

	--重做版
	["mou_ganningg"] = "谋甘宁",
	["#mou_ganningg"] = "兴王定霸",
	["designer:mou_ganningg"] = "官方",
	["cv:mou_ganningg"] = "官方",
	["illustrator:mou_ganningg"] = "佚名",
	--奇袭
	["mouqixir"] = "奇袭",
	["mouqixirAgain"] = "奇袭",
	["mouqixiragain"] = "奇袭",
	[":mouqixir"] = "出牌阶段限一次，你可以选择一名其他角色，令其猜测你手牌中某种花色的牌最多（或之一）。若其猜错，你可令其再次猜测（其无法选择此阶段已猜测过的花色）；否则你展示所有手牌。然后你弃置其区域内X张牌。（X为其此阶段猜错的次数，若不足则全弃）",
	["mouqixir:heartMAX"] = "猜测其手牌中【♥红桃】花色为最多之一",
	["mouqixir:diamondMAX"] = "猜测其手牌中【♦方块】花色为最多之一",
	["mouqixir:clubMAX"] = "猜测其手牌中【♣梅花】花色为最多之一",
	["mouqixir:spadeMAX"] = "猜测其手牌中【♠黑桃】花色为最多之一",
	["$mouqixirGuess_success"] = "面对由 %from 发起的“<font color='yellow'><b>奇袭</b></font>”猜猜看，%to 沉着应对，猜测 <font color=\"#4DB873\"><b>正确</b></font>！",
	["$mouqixirGuess_fail"] = "面对由 %from 发起的“<font color='yellow'><b>奇袭</b></font>”猜猜看，%to 顾虑重重，猜测 <font color='red'><b>错误</b></font>",
	["@mouqixirAgain"] = "你是否令其再次猜测？这样有机会弃置其更多牌",
	["~mouqixirAgain"] = "【注意】若对方连续猜错三次就可以收手了，不然直接就要展示手牌了",
	["$mouqixir1"] = "击敌不备，奇袭拔寨！",
	["$mouqixir2"] = "轻羽透重铠，奇袭溃坚城！",
	["mouCaiCaiKan"] = "",
	--奋威
	["moufenweir"] = "奋威",
	["moufenweirPUT"] = "奋威",
	["moufenweirput"] = "奋威",
	[":moufenweir"] = "限定技，出牌阶段，你可以将至多三张牌置于等量角色的武将牌上各一张，称为“威”，然后你摸等同于“威”数量的牌。有“威”的角色成为锦囊牌的目标时，你须选择一项：1.令其获得“威”牌；2.弃置其“威”牌，取消其作为此锦囊牌的目标。",
	["@moufenweir"] = "奋威",
	["MFwei"] = "威",
	["@moufenweirPUT-card"] = "请选择一名已选择为目标的其他角色，将“威”中的一张牌置于其武将牌上",
	["~moufenweirPUT"] = "若自己也为目标之一，未置出去的“威”牌即置于自己武将牌上",
	["moufenweir:1"] = "令其获得“威”牌",
	["moufenweir:2"] = "弃置其“威”牌，取消其作为此锦囊牌的目标",
	["$moufenweir1"] = "舍身护主，扬吴将之风！",
	["$moufenweir2"] = "袭军挫阵，奋江东之威！",
	--阵亡
	["~mou_ganningg"] = "蛮将休得猖狂！呃...呃啊！......",

	--谋夏侯氏
	["mou_xiahoushii"] = "谋夏侯氏",
	["#mou_xiahoushii"] = "燕语呢喃",
	["designer:mou_xiahoushii"] = "官方",
	["cv:mou_xiahoushii"] = "官方",
	["illustrator:mou_xiahoushii"] = "佚名",
	--燕语
	["mouyanyuu"] = "燕语",
	["mouyanyuuGiveCards"] = "燕语",
	[":mouyanyuu"] = "<font color='green'><b>出牌阶段限两次，</b></font>你可以弃置一张【杀】并摸一张牌。出牌阶段结束时，你可以令一名其他角色摸3X张牌（X为你本回合以此法弃置的【杀】数）。",
	["mouyanyuuDraw"] = "燕语补牌",
	["mouyanyuu-GiveCardsNum"] = "请选择一名其他角色，其摸 %src 张牌",
	["$mouyanyuu1"] = "燕语呢喃唤君归！",
	["$mouyanyuu2"] = "燕燕于飞，差池其羽。",
	--樵拾
	["mouqiaoshii"] = "樵拾",
	[":mouqiaoshii"] = "每个回合限一次，当你受到其他角色造成的伤害后，伤害来源可选择令你回复等同于此次伤害值的体力，若如此做，其摸两张牌。",
	["@mouqiaoshii_RecoverHer"] = "[樵拾]令其补回体力",
	["$mouqiaoshii1"] = "拾樵城郭边，似有苔花开。",
	["$mouqiaoshii2"] = "拾樵采薇，怡然自足。",
	--阵亡
	["~mou_xiahoushii"] = "玄鸟不曾归，君亦不再来......",

	--KJ谋夏侯霸
	["kj_mou_xiahouba"] = "KJ谋夏侯霸",
	["&kj_mou_xiahouba"] = "○谋夏侯霸",
	["#kj_mou_xiahouba"] = "来之坎坎",
	["designer:kj_mou_xiahouba"] = "小珂酱", --(卯兔包投稿)",
	["cv:kj_mou_xiahouba"] = "官方",
	["illustrator:kj_mou_xiahouba"] = "琛·美弟奇",
	--试锋
	["kjmoushifeng"] = "试锋",
	[":kjmoushifeng"] = "魏势力技，每当你使用【闪】或【无懈可击】结算完毕后，你可以摸一张牌并视为使用一张无距离限制的【杀】（不计次），当此【杀】被【闪】响应后，你失去1点体力。",
	["@kjmoushifeng-tuodao"] = "你可以视为使用一张无距离限制的【杀】",
	["~kjmoushifeng"] = "副作用：如若此【杀】被【闪】回避，你将失去1点体力",
	["$kjmoushifeng1"] = "尔等，也配与本将军对阵？",
	["$kjmoushifeng2"] = "取你头颅，亦如探囊取物！",
	--绝辗
	["kjmoujuezhan"] = "绝辗",
	[":kjmoujuezhan"] = "觉醒技，<font color='red'><b>回合开始前</b></font>或结束阶段开始时，若你的体力值为1或没有手牌，你回复1点体力或摸两张牌，然后将势力改为“蜀”。",
	["kjmoujuezhan:1"] = "回复1点体力",
	["kjmoujuezhan:2"] = "摸两张牌",
	--["$kjmoujuezhan1"] = "父亲在上，魂佑大汉(夏侯渊:?)；伯约在旁，智定天下！", --体力值为1觉醒
	["$kjmoujuezhan1"] = "丞相在上，魂佑大汉；伯约在旁，谋定天下！", --体力值为1觉醒
	["$kjmoujuezhan2"] = "先帝之志，丞相之托，不可忘也！", --没有手牌觉醒
	--励进
	["kjmoulijin"] = "励进",
	["kjmoulijinMXC"] = "励进",
	[":kjmoulijin"] = "蜀势力技，回合开始时，若你已受伤，你可以选择并执行一个阶段，若你选择了：\
	○判定阶段，你弃置一名其他角色的至多X张牌（X为你已损失的体力值；弃牌时，点【取消】即中止弃牌流程）；\
	○摸牌阶段，你本回合手牌上限+1；\
	○出牌阶段，你从牌堆获得一张【杀】；\
	○弃牌阶段，你获得1点护甲。",
	["kjmoulijin:judge"] = "执行一个【判定阶段】",
	["kjmoulijin:draw"] = "执行一个【摸牌阶段】",
	["kjmoulijin:play"] = "执行一个【出牌阶段】",
	["kjmoulijin:discard"] = "执行一个【弃牌阶段】",
	["kjmoulijinTiaoXinS"] = "请选择一名其他角色，弃置其至多 %src 张牌",
	["$kjmoulijin1"] = "汝等小儿，可敢杀我？", --执行判定阶段
	["$kjmoulijin2"] = "屯粮事大，暂不与尔等计较。", --执行摸牌阶段
	["$kjmoulijin3"] = "老将虽白发，宝刀刃犹锋！", --执行出牌阶段
	["$kjmoulijin4"] = "勤学潜习，始觉自新。", --执行弃牌阶段
	--阵亡
	["~kj_mou_xiahouba"] = "终是..逃不过这一劫....呃......",
	--==作者的设计思路==--
	--[[基本思路（历史契合度）
	【试锋】夏侯霸虽是夏侯渊后代，初次上阵还是略显青涩，曹真任命其为先锋，作战不利，夏侯霸亲临阵前防御，所以将此时机设计为使用防御牌之后，并且可以看到父亲夏侯渊的影子，但却不那么从容。“杀”未造成伤害代表作战失败，而失去体力则体现了魏国朝廷对夏侯霸的排挤和打压，一步一步将夏侯霸推向悬崖边缘。
	【绝辗】顾名思义，在绝境中辗转，夏侯霸继续留在魏国必被小人所害，不得已而投降蜀国。
	【励进】夏侯霸的史料记载并不多，但我们可以看出他的一生并不安稳，夏侯霸在蜀汉连一个朋友也交不得，但却一点一滴得到晋升，正所谓“棘途壮志”——故将此技能发动限制设计为跟受伤有关，根据不同的情形采用不同的手段，体现人物处世机敏和智慧。
	※（设计彩蛋）：关于【励进】，我选择了众多与夏侯霸有着或多或少联系的武将作为参考：例如，判定阶段的效果对应蜀将姜维的挑衅弃牌，摸牌阶段对应钟会的手牌上限，出牌阶段的效果对应张飞的多刀，弃牌阶段我则是参考了游戏“真·三国无双”里夏侯霸的形象：有着不让其父的性格与异常年轻的容貌，因此以盔甲来掩饰。所以设计为增添护甲。
	※（一些思考）我曾想过在【试锋】中去掉“魏势力技，”这样这个武将的强度将获得提升，但我认为既然在魏国受到排挤投靠蜀国之后，就应当与以往一刀两断，最终放弃了这个想法。]]
	--==================--

	--谋周瑜
	["mou_zhouyuu"] = "谋周瑜",
	["#mou_zhouyuu"] = "江淮之杰",
	["designer:mou_zhouyuu"] = "官方",
	["cv:mou_zhouyuu"] = "官方",
	["illustrator:mou_zhouyuu"] = "佚名",
	--英姿
	["mouyingzii"] = "英姿",
	["mouyingziiMXC"] = "手牌上限+",
	[":mouyingzii"] = "锁定技，摸牌阶段，你以下的数值每满足一项，你摸牌数与本回合手牌上限就+1：1.你的手牌数不少于2；2.你的体力值不低于2；3.你装备区的牌数不低于1。",
	["$mouyingzii_DrawMore"] = "%from 的手牌数为 %arg2，体力值为 %arg3，装备区的牌数为 %arg4，满足“<font color='yellow'><b>英姿</b></font>”的 %arg5 项增益，将多摸 %arg5 张牌，且本回合手牌上限 + %arg5",
	["$mouyingzii1"] = "交之总角，付之九州！",
	["$mouyingzii2"] = "定策分两治，纵马饮三江！",
	--反间
	["moufanjiann"] = "反间",
	[":moufanjiann"] = "出牌阶段，你可以选择一名其他角色，扣置一张本回合未以此法扣置过的花色的手牌，并声明一个花色，其须选择一项：1.猜测此牌花色与声明花色是否一致；2.其翻面，且此技能失效直到回合结束。" ..
		"然后你展示此牌令其获得之。若其选择猜测，则：若<font color='green'><b>猜对</b></font>，此技能失效直到回合结束；若<font color='red'><b>猜错</b></font>，其失去1点体力。",
	["@moufanjiann_AnnounceSuit"] = "反间:请选择你要声明的花色",
	["@moufanjiann_AnnounceSuit:heart"] = "声明你扣置的这张牌花色为【♥红桃】",
	["@moufanjiann_AnnounceSuit:diamond"] = "声明你扣置的这张牌花色为【♦方块】",
	["@moufanjiann_AnnounceSuit:club"] = "声明你扣置的这张牌花色为【♣梅花】",
	["@moufanjiann_AnnounceSuit:spade"] = "声明你扣置的这张牌花色为【♠黑桃】",
	["moufanjiann:1"] = "猜测其声明的花色是否与其扣置的牌花色一致",
	["moufanjiann:2"] = "翻面，让其本回合不能再发动“反间”",
	["@moufanjiann_guess"] = "反间:猜测",
	["@moufanjiann_guess:1"] = "其声明的花色与其扣置的牌花色一致",
	["@moufanjiann_guess:2"] = "其声明的花色与其扣置的牌花色不一致",
	["$moufanjiannGuess_success"] = "面对由 %from 发起的“<font color='yellow'><b>反间</b></font>”猜猜看，%to 接受挑战、沉着应对，猜测 <font color=\"#4DB873\"><b>正确</b></font>！",
	["$moufanjiannGuess_fail"] = "面对由 %from 发起的“<font color='yellow'><b>反间</b></font>”猜猜看，%to 接受挑战，但顾虑重重，猜测 <font color='red'><b>错误</b></font>",
	["$moufanjiann1"] = "比之自内，不自失也。", --未“得逞”
	["$moufanjiann2"] = "若不念汝三世之功，今日定斩不赦！", --“得逞”
	--阵亡
	["~mou_zhouyuu"] = "余虽不惧曹军，但惧白驹过隙......",

	--谋黄盖
	["mou_huanggaii"] = "谋黄盖",
	["#mou_huanggaii"] = "轻身为国",
	["designer:mou_huanggaii"] = "官方",
	["cv:mou_huanggaii"] = "官方",
	["illustrator:mou_huanggaii"] = "佚名",
	--苦肉
	["moukurouu"] = "苦肉",
	["moukurouuGivePorA"] = "苦肉",
	["moukurouugivepora"] = "苦肉",
	["moukurouuGiveOther"] = "苦肉",
	["moukurouugiveother"] = "苦肉",
	[":moukurouu"] = "出牌阶段开始时，你可以交给其他角色一张牌，然后失去1点体力（若你交出的牌是【桃】或【酒】，则改为失去2点体力）。当你失去1点体力后，你获得2点护甲。",
	["moukurouu:gpa"] = "给【桃】或【酒】",
	["moukurouu:got"] = "给其他的",
	["@moukurouuGivePorA-card"] = "请选择一名其他角色，给其一张【桃】或【酒】",
	["~moukurouuGivePorA"] = "你将失去2点体力，获得4点护甲",
	["@moukurouuGiveOther-card"] = "请选择一名其他角色，给其一张不为【桃】和【酒】的牌",
	["~moukurouuGiveOther"] = "你将失去1点体力，获得2点护甲",
	["$moukurouu1"] = "既不能破，不如依张子布之言，投降便罢！", --给牌
	["$moukurouu2"] = "周瑜小儿！破曹不得，便欺吾三世老臣乎？", --失去体力
	--诈降
	["mouzhaxiangg"] = "诈降",
	["mouzhaxianggWH"] = "诈降",
	[":mouzhaxiangg"] = "锁定技，你于每个回合使用的前X张牌无距离和次数限制且不可被响应。摸牌阶段，你多摸X张牌。（X为你已损失体力值）",
	["mouzhaxianggCardUsed"] = "",
	["$mouzhaxiangg1"] = "江东六郡之卒，怎敌丞相百万雄师！",
	["$mouzhaxiangg2"] = "闻丞相虚心纳士，盖愿率众归降！",
	--阵亡
	["~mou_huanggaii"] = "哈哈哈哈，公瑾计成，老夫死也无憾了......",

	--[[谋刘备-精简版
	["mou_liubey"] = "谋刘备-精简版",
	["&mou_liubey"] = "谋刘备",
	["#mou_liubey"] = "季汉大白板",
	["designer:mou_liubey"] = "死吗√咔",
	["cv:mou_liubey"] = "无",
	["illustrator:mou_liubey"] = "KayaK,戏子多殇`",
	  --仁德
	["mourend"] = "仁德",
	[":mourend"] = "出牌阶段开始时，取豿鉲马，有如探囊取物！", --出处：神关羽“武神”语音
	  --章武
	["mouzhangw"] = "章武",
	["@mouzhangw"] = "章武",
	[":mouzhangw"] = "限定技，豿鉲不两立，季汉不偏安！", --出处：谋刘备本技能语音
	  --激将
	["moujij"] = "激将",
	[":moujij"] = "主公技，出牌阶段结束时，豿鉲贪嗔痴戾疑，马受鞭笞斧灼烹！", --出处：新杀神张飞“神裁”语音
	  --阵亡
	["~mou_liubey"] = ":)",]]
	----
	--谋刘备
	["mou_liubeii"] = "谋刘备",
	["#mou_liubeii"] = "雄才盖世",
	["designer:mou_liubeii"] = "官方",
	["cv:mou_liubeii"] = "官方",
	["illustrator:mou_liubeii"] = "佚名",
	--仁德
	["mourendee"] = "仁德",
	["mourendes"] = "仁德",
	["mourendeee"] = "仁德基本牌",
	["mourendeee_list"] = "仁德",
	["mourendeee_slash"] = "仁德",
	["mourendeee_saveself"] = "仁德",
	[":mourendee"] = "出牌阶段开始时，你获得2枚“仁望”标记。出牌阶段，你可以将任意张牌交给一名本阶段未获得过“仁德”牌的其他角色，然后你获得等量的“仁望”标记（你至多拥有8枚“仁望”标记）。" ..
		"每个回合限一次，当你需要使用或打出一张基本牌时，你可以弃置2枚“仁望”标记视为使用或打出之。",
	["mourdTOzw"] = "本局已仁德",
	["mRenWang"] = "仁望",
	["mRenWangYK"] = "已印仁望卡",
	["$mourendee1"] = "仁德为政，自得民心！",
	["$mourendee2"] = "民心所望，乃吾政所向！",
	--章武
	["mouzhangwuu"] = "章武",
	["mouzhangwuuTurn"] = "章武",
	[":mouzhangwuu"] = "限定技，出牌阶段，你可以令本局游戏中所有获得过“仁德”牌的角色依次交给你X张牌（X为游戏轮数-1，且最大为3），若如此做，你回复3点体力，然后失去“仁德”。",
	["@mouzhangwuu"] = "章武",
	["mouzhangwuuGive"] = "",
	["#mouzhangwuu"] = "请交给其%src张牌",
	["$mouzhangwuu1"] = "破联盟，屠吴狗！", --取自极略三国神刘备“激诏”台词
	["$mouzhangwuu2"] = "汉贼不两立，王业不偏安！",
	--激将
	["moujijiangg"] = "激将",
	[":moujijiangg"] = "主公技，出牌阶段结束时，你可指定一名角色，并令另一名攻击范围内含有该角色且体力值不小于你的其他蜀势力角色选择一项：1.视为对你指定的角色使用一张普通【杀】；2.跳过下一个出牌阶段。",
	["moujijianggto"] = "请选择一名角色作为你“激将”的目标",
	["moujijianggfrom"] = "请选择一名符合要求的角色作为你“激将”的对象",
	["moujijiangg:1"] = "视为对%src使用一张【杀】",
	["moujijiangg:2"] = "跳过下一个出牌阶段",
	["moujijianggSL"] = "不敢战",
	[":&moujijianggSL"] = "将跳过下一个出牌阶段",
	["$moujijiangg1"] = "匡扶汉室，岂能无诸将之助！",
	["$moujijiangg2"] = "大汉将士，何人敢战？",
	--阵亡
	["~mou_liubeii"] = "汉室之兴，皆仰望丞相了......",

	--FC谋姜维
	["fc_mou_jiangwei"] = "FC谋姜维",
	["&fc_mou_jiangwei"] = "☆谋姜维",
	["#fc_mou_jiangwei"] = "最后的汉臣", --“见危授命”
	["designer:fc_mou_jiangwei"] = "时光流逝FC",
	["cv:fc_mou_jiangwei"] = "官方", --谋姜维语音(主体,阵亡)+标姜维语音(衍生技)
	["illustrator:fc_mou_jiangwei"] = "鬼画符", --没用谋姜维原画，个人不太喜欢
	--挑衅
	["fcmoutiaoxin"] = "挑衅",
	["fcmoutiaoxinStart"] = "挑衅",
	["fcmoutiaoxinTrigger"] = "挑衅",
	[":fcmoutiaoxin"] = "<b><font color='yellow'>蓄</font><font color='orange'>力</font><font color='red'>技</font>（<font color='red'>4</font>/<font color='red'>4</font>）</b>，" ..
		"出牌阶段限一次，你可以获得技能“八阵”直到此阶段结束并选择至多X名其他角色（X为你拥有的蓄力点数），令这些角色依次选择一项：\
	1.对你使用一张无距离限制的【杀】，且若此【杀】被你的【闪】响应，你弃置其一张牌；\
	2.令你获得其一张牌。\
	然后你每选择一名角色，蓄力点就-1。弃牌阶段，你每弃置一张牌，蓄力点+1（不能超过上限）。",
	["@fcXuLi"] = "蓄力点",
	["fcXuLiMAX"] = "", --体现蓄力点上限的标记
	["tofcmouzhiji"] = "挑衅角色",
	--["fcmoutiaoxin:1"] = "对其使用一张【杀】（无距离限制）",
	--["fcmoutiaoxin:2"] = "令其获得你一张牌",
	["@fcmoutiaoxin-slash"] = "请对 %src 使用一张【杀】（无距离限制）",
	["$fcmoutiaoxin1"] = "汝等小儿，还不快跨马来战！",
	["$fcmoutiaoxin2"] = "哼！既匹夫不战，不如归耕陇亩！",
	--志继
	["fcmouzhiji"] = "志继",
	[":fcmouzhiji"] = "觉醒技，准备阶段，若你发动“挑衅”选择过至少四名角色，你减1点体力上限，获得技能" ..
		"“<font color='purple'><b>妖智</b>(魂烈SP包-SP神诸葛亮<b>[作者:司马子元]</b>)</font>”、“<font color=\"#66FFFF\"><b>界妆神</b>(鬼包-界鬼诸葛亮<b>[作者:小珂酱]</b>)</font>”。",
	["$fcmouzhiji1"] = "丞相之志，维岂敢忘之！",
	["$fcmouzhiji2"] = "北定中原终有日！",
	--妖智(极略三国-SP神诸葛亮)
	["fcmzj_yaozhi"] = "妖智",
	[":fcmzj_yaozhi"] = "准备阶段，结束阶段，出牌阶段限一次，当你受到伤害后，你可以摸一张牌，然后从随机三个能在此时机发动的技能中选择一个并发动。",
	["#ZJYaozhiTempSkill"] = "%from 于此阶段可以发动技能“%arg”",
	["$fcmzj_yaozhi1"] = "继丞相之遗志，讨篡汉之逆贼！",
	["$fcmzj_yaozhi2"] = "克复中原，指日可待！",
	--界妆神(民间鬼包界限突破-界鬼诸葛亮)
	["fcmzj_jiezhuangshen"] = "妆神",
	["fcmzj_jiezhuangshenDamage"] = "妆神",
	["fcmzj_jiezhuangshenDeath"] = "妆神",
	[":fcmzj_jiezhuangshen"] = "准备阶段开始时或结束阶段开始时，你可以摸一张牌并判定，若结果为黑色，你可以选择一名其他角色的一个技能，你拥有此技能直到你下回合开始；若结果为红色，你可以对一名角色发动“狂风”或“大雾”。",
	["fcmzj_jiezhuangshenskill-ask"] = "你可以选择一名其他角色，获得其一个技能",
	["fcmzj_jiezhuangshengod-ask"] = "你可以选择发动“狂风”或“大雾”的角色",
	["fcmzj_jiezhuangshen:kfc"] = "狂风",
	["fcmzj_jiezhuangshen:dwg"] = "大雾",
	["jzs_kuangfeng"] = "狂风",
	["jzs_dawu"] = "大雾",
	["$fcmzj_jiezhuangshen1"] = "贼将早降，可免一死。", --判黑
	["$fcmzj_jiezhuangshen2"] = "汝等小儿，可敢杀我？", --判红
	--阵亡
	["~fc_mou_jiangwei"] = "市井鱼龙易一统，护国麒麟难擎天......",

	--谋曹仁
	["mou_caorenn"] = "谋曹仁",
	["#mou_caorenn"] = "固若金汤",
	["designer:mou_caorenn"] = "官方",
	["cv:mou_caorenn"] = "官方",
	["illustrator:mou_caorenn"] = "佚名",
	--据守
	["moujushouu"] = "据守",
	["moujushouuDamaged"] = "据守",
	[":moujushouu"] = "出牌阶段限一次，若你正面向上，你可以翻面、弃置至多两张牌并获得等量的护甲。当你受到伤害后，若你背面向上，你可以选择一项：1.翻回；2.获得1点护甲。" ..
		"当你翻回(武将牌从背面翻至正面)时，你摸等同于你护甲值的牌。",
	["moujushouu:00"] = "不弃置牌，无事发生",
	["moujushouu:11"] = "弃置一张牌，获得1点护甲",
	["moujushouu:22"] = "弃置两张牌，获得2点护甲",
	["moujushouu:1"] = "给我翻过来！",
	["moujushouu:2"] = "叠甲，过",
	["$moujushouu1"] = "白马沉河共歃誓，怒涛没城亦不悔！", --出牌阶段发动技能
	["$moujushouu2"] = "山水速疾来去易，襄樊镇固永难开！", --选择
	["$moujushouu3"] = "汉水溢流断归路，守城之志穷且坚！", --翻回摸牌
	--解围
	["moujieweii"] = "解围",
	[":moujieweii"] = "出牌阶段限一次，你可以失去1点护甲并选择一名其他角色，你查看其手牌并获得其中一张。",
	["$moujieweii1"] = "同袍之谊，断不可弃之！",
	["$moujieweii2"] = "贼虽势盛，若吾出马，亦可解之！",
	--阵亡
	["~mou_caorenn"] = "吾身可殉，然襄樊之地万不可落于吴蜀之手......",

	--谋甄姬
	["mou_zhenjii"] = "谋甄姬",
	["#mou_zhenjii"] = "薄幸幽兰",
	["designer:mou_zhenjii"] = "官方",
	["cv:mou_zhenjii"] = "官方",
	["illustrator:mou_zhenjii"] = "佚名",
	--洛神
	["mouluoshenn"] = "洛神",
	["mouluoshennMaxCards"] = "洛神",
	[":mouluoshenn"] = "准备阶段，你可以选择一名角色，自其开始X名不同的其他角色依次展示一张手牌（X为场上存活人数的一半，向上取整），若为黑色，你获得之，且此牌本回合不计入手牌上限。若为红色，其弃置之。",
	["$mouluoshenn1"] = "晨张兮细帷，夕茸兮兰櫋。",
	["$mouluoshenn2"] = "商灵缤兮恭迎，伞盖纷兮若云。",
	--倾国
	["mouqingguoo"] = "倾国",
	[":mouqingguoo"] = "你可以将一张黑色手牌当【闪】使用或打出。",
	["$mouqingguoo1"] = "辛夷展兮修裙，紫藤舒兮绣裳。",
	["$mouqingguoo2"] = "凌波荡兮微步，香罗袜兮生尘。",
	--阵亡
	["~mou_zhenjii"] = "秀目回兮难得，徒逍遥兮莫离......",

	--谋法正
	["mou_fazhengg"] = "谋法正",
	["#mou_fazhengg"] = "经学思谋",
	["designer:mou_fazhengg"] = "官方",
	["cv:mou_fazhengg"] = "官方",
	["illustrator:mou_fazhengg"] = "佚名",
	--眩惑
	["mouxuanhuoo"] = "眩惑",
	["mouxuanhuooGC"] = "眩惑",
	[":mouxuanhuoo"] = "出牌阶段限一次，你可以交给一名没有“眩”标记的其他角色一张牌并令其获得“眩”标记。有“眩”标记的角色于摸牌阶段外获得牌时，你随机获得其一张手牌（每枚“眩”标记最多令你获得五张牌）。",
	["mXuan"] = "眩",
	["mLastXuan"] = "“眩”效果剩余",
	["$mouxuanhuoo1"] = "虚名虽无实用，可沽万人之心。",
	["$mouxuanhuoo2"] = "效金台碣馆之事，布礼贤仁德之名。",
	--恩怨
	["mouenyuann"] = "恩怨",
	[":mouenyuann"] = "锁定技，准备阶段，你令有“眩”标记的角色执行以下效果：自其获得“眩”标记开始，若你获得其至少三张牌，则你移除其“眩”标记，然后交给其三张牌<font color='red'><b>(若不足则全给)</b></font>；否则其失去1点体力，然后你回复1点体力并移除其“眩”标记。",
	["#mouenyuann"] = "请交给 %src 三张牌",
	["$mouenyuann1"] = "恩如泰山，当还以东海！", --恩
	["$mouenyuann2"] = "汝既负我，哼哼，休怪军法无情！", --怨
	--阵亡
	["~mou_fazhengg"] = "蜀翼双折，吾主王业，就靠孔明了......",

	--谋庞统
	["mou_pangtongg"] = "谋庞统",
	["#mou_pangtongg"] = "铁索连舟",
	["designer:mou_pangtongg"] = "官方",
	["cv:mou_pangtongg"] = "官方",
	["illustrator:mou_pangtongg"] = "佚名",
	--连环
	["moulianhuann"] = "连环",
	["moulianhuann_touse"] = "连环",
	["moulianhuanns"] = "连环",
	[":moulianhuann"] = "出牌阶段，你可以将一张梅花手牌当【铁索连环】使用（每个出牌阶段限一次），或重铸一张梅花手牌。你使用【铁索连环】时，你可以失去1点体力，若如此做，" ..
		"你指定一名角色为目标后，若其不处于连环状态，随机弃置其一张手牌。",
	["moulianhuann11"] = "连环",
	[":moulianhuann11"] = "【升级版】出牌阶段，你可以将一张梅花手牌当【铁索连环】使用（每个出牌阶段限一次），或重铸一张梅花手牌。你使用【铁索连环】可以额外指定任意名目标。" ..
		"你使用【铁索连环】指定一名角色为目标后，若其不处于连环状态，随机弃置其一张手牌。",
	["moulianhuann:1"] = "使用", --"使用或重铸",
	["moulianhuann:2"] = "重铸", --"仅重铸",
	["@moulianhuann_touse-card"] = "[连环]你可以将一张梅花手牌当【铁索连环】使用",
	["@moulianhuann-recast"] = "[连环]你可以重铸一张梅花手牌",
	["@moulianhuanns-excard"] = "[连环-升级版]你可以为【%src】选择任意名额外目标",
	["$moulianhuann1"] = "并排横江，可利水战！",
	["$moulianhuann2"] = "任凭潮涌，连环无惧！",
	--涅槃
	["mouniepann"] = "涅槃",
	[":mouniepann"] = "限定技，当你处于濒死状态时，你可以弃置区域里的所有牌，若如此做，你摸两张牌、将体力回复至2点并复原武将牌，然后升级“连环”" ..
		"（<font color='red'><b>【升级版】</b>出牌阶段，你可以将一张梅花手牌当【铁索连环】使用（每个出牌阶段限一次），或重铸一张梅花手牌。你使用【铁索连环】可以额外指定任意名目标</font>）。",
	["@mouniepann"] = "涅槃",
	["mouniepanned"] = "",
	["$mouniepann1"] = "烈火焚身，凤羽更丰！",
	["$mouniepann2"] = "凤雏涅槃，只为再生！",
	--阵亡
	["~mou_pangtongg"] = "落凤坡，果真为我葬身之地......",

	--谋貂蝉
	["mou_diaochann"] = "谋貂蝉",
	["#mou_diaochann"] = "离间计",
	["designer:mou_diaochann"] = "官方",
	["cv:mou_diaochann"] = "官方",
	["illustrator:mou_diaochann"] = "佚名,云涯",
	--离间
	["moulijiann"] = "离间",
	[":moulijiann"] = "出牌阶段限一次，你可以选择至少两名其他角色并弃置X张牌（X为你选择的角色数-1），然后这些角色依次视为对在你此次选择范围内的逆时针最近座次的另一名角色使用一张【决斗】。",
	["moulijiannTargets"] = "",
	["$moulijiann1"] = "贱妾污浊之身，岂可复侍将军...",
	["$moulijiann2"] = "太师若献妾于吕布，妾宁死不受此辱！",
	--闭月
	["moubiyuee"] = "闭月",
	["moubiyueeRaC"] = "闭月",
	[":moubiyuee"] = "锁定技，结束阶段，你摸X张牌。（X为本回合受到伤害的角色数+1，至多为4）",
	["moubiyuee_damagedTargets"] = "",
	["$moubiyuee1"] = "芳草更芊芊，荷池映玉颜。",
	["$moubiyuee2"] = "薄酒醉红颜，广袂羞掩面。",
	--阵亡
	["~mou_diaochann"] = "终不负阿父之托......",

	--谋袁绍
	["mou_yuanshaoo"] = "谋袁绍",
	["#mou_yuanshaoo"] = "虚伪的袁神",
	["designer:mou_yuanshaoo"] = "官方",
	["cv:mou_yuanshaoo"] = "官方",
	["illustrator:mou_yuanshaoo"] = "佚名",
	--乱击
	["mouluanjii"] = "乱击",
	["mouluanjiiDC"] = "乱击",
	[":mouluanjii"] = "出牌阶段限一次，你可以将两张手牌当【万箭齐发】使用。其他角色因响应你使用的【万箭齐发】而打出【闪】时，你摸一张牌（每回合你至多以此法获得三张牌）。",
	["$mouluanjii1"] = "与我袁本初为敌，下场只有一个！",
	["$mouluanjii2"] = "弓弩手，乱箭齐下，射杀此贼！",
	--血裔
	["mouxueyii"] = "血裔",
	[":mouxueyii"] = "主公技，锁定技，你的手牌上限+X（X为其他“群”势力角色数的两倍）；你使用牌指定其他“群”势力角色为目标后，你摸一张牌（每回合你至多以此法获得两张牌）。",
	["mouluanjiiDC"] = "血裔",
	["$mouxueyii1"] = "四世三公之贵，岂是尔等寒门可及？",
	["$mouxueyii2"] = "吾袁门名冠天下，何须奉天子为傀？",
	--阵亡
	["~mou_yuanshaoo"] = "我不可能输给曹阿瞒，不可能！......",

	--谋孙策
	["mou_suncee"] = "谋孙策",
	["#mou_suncee"] = "江东小王霸",
	["designer:mou_suncee"] = "官方",
	["cv:mou_suncee"] = "官方",
	["illustrator:mou_suncee"] = "佚名",
	--激昂
	["moujiangg"] = "激昂",
	["moujiangd"] = "激昂",
	[":moujiangg"] = "你使用【决斗】可以额外指定一名目标，若如此做，你失去1点体力。当你使用【决斗】或红色【杀】指定一名目标后，或成为【决斗】或红色【杀】的目标后，你摸一张牌。" ..
		"<font color='green'><b>出牌阶段限X次（X初始为1；若你已发动“制霸”修改X值，则改为场上“吴”势力角色数），</b></font>你可以将所有手牌当【决斗】使用。",
	["@moujiangd-excard"] = "[激昂]你可以为【%src】指定一名额外目标",
	["$moujiangg1"] = "义武奋扬，荡尽犯我之寇！",
	["$moujiangg2"] = "锦绣江东，岂容小丑横行！",
	--魂姿
	["mouhunzii"] = "魂姿",
	["mouhunziiAudio"] = "魂姿",
	[":mouhunzii"] = "觉醒技，当你脱离濒死状态时，你减1点体力上限并摸两张牌，获得技能“谋英姿”、“英魂”。",
	["$mouhunzii1"] = "群雄逐鹿之时，正是吾等崭露头角之日！", --觉醒
	["$mouhunzii2"] = "胸中远志几时立，正逢建功立业时！", --觉醒
	--
	["$mouhunzii3"] = "今与公瑾相约，共图天下霸业！", --发动“谋英姿”的时机
	["$mouhunzii4"] = "空言岂尽意，跨马战沙场！", --发动“谋英姿”的时机
	["$mouhunzii5"] = "父亲英魂犹在，助我定乱平贼！", --发动“英魂”的时机
	["$mouhunzii6"] = "扫尽门庭之寇，贼自畏我之威！", --发动“英魂”的时机
	--制霸
	["mouzhibaa"] = "制霸",
	[":mouzhibaa"] = "主公技，限定技，当你进入濒死状态时，你可以回复Y点体力（Y为场上“吴”势力角色数）并将“激昂”中的X值改为：<font color='green'><b>场上“吴”势力角色数</b></font>，" ..
		"然后其他“吴”势力角色依次受到1点无来源伤害。若有角色因此伤害死亡，则其死亡后，你摸三张牌。",
	["@mouzhibaa"] = "制霸",
	["$mouzhibaa1"] = "知君英豪，望来归效！",
	["$mouzhibaa2"] = "孰胜孰负，犹未可知！",
	--阵亡
	["~mou_suncee"] = "大志未展，权弟当继......",

	--谋孙策-第二版
	["mou_sunces"] = "谋孙策-第二版",
	["&mou_sunces"] = "谋孙策",
	["#mou_sunces"] = "江东小霸王",
	["designer:mou_sunces"] = "官方",
	["cv:mou_sunces"] = "官方",
	["illustrator:mou_sunces"] = "佚名",
	--激昂（同正式初版）
	--魂姿
	["mouhunzis"] = "魂姿",
	["mouhunzisAudio"] = "魂姿",
	[":mouhunzis"] = "觉醒技，当你脱离濒死状态时，你减1点体力上限、获得1点护甲并摸三张牌，获得技能“谋英姿”、“英魂”。",
	["$mouhunzis1"] = "群雄逐鹿之时，正是吾等崭露头角之日！", --觉醒
	["$mouhunzis2"] = "胸中远志几时立，正逢建功立业时！", --觉醒
	--
	["$mouhunzis3"] = "今与公瑾相约，共图天下霸业！", --发动“谋英姿”的时机
	["$mouhunzis4"] = "空言岂尽意，跨马战沙场！", --发动“谋英姿”的时机
	["$mouhunzis5"] = "父亲英魂犹在，助我定乱平贼！", --发动“英魂”的时机
	["$mouhunzis6"] = "扫尽门庭之寇，贼自畏我之威！", --发动“英魂”的时机
	--制霸
	["mouzhibas"] = "制霸",
	[":mouzhibas"] = "主公技，限定技，当你进入濒死状态时，你可以回复Y点体力（Y为场上“吴”势力角色数-1）并将“激昂”中的X值改为：<font color='green'><b>场上“吴”势力角色数</b></font>，" ..
		"然后其他“吴”势力角色依次受到1点无来源伤害。若有角色因此伤害死亡，则其死亡后，你摸三张牌。",
	["@mouzhibas"] = "制霸",
	["$mouzhibas1"] = "知君英豪，望来归效！",
	["$mouzhibas2"] = "孰胜孰负，犹未可知！",
	--阵亡
	["~mou_sunces"] = "大志未展，权弟当继......",

	--FC谋孙策
	["fc_mou_sunce"] = "FC谋孙策", ["fc_mou_sunces"] = "幽冥大帝·孙策",
	["&fc_mou_sunce"] = "☆谋孙策",
	["#fc_mou_sunce"] = "阴霸",
	["designer:fc_mou_sunce"] = "时光流逝FC",
	["cv:fc_mou_sunce"] = "新三国,Rarondo9,Jack Swagger",
	["illustrator:fc_mou_sunce"] = "沙溢,Rarondo9",
	--激昂
	["fcmoujiang"] = "激昂",
	[":fcmoujiang"] = "你使用【决斗】或红色【杀】无目标数限制；当你使用【决斗】或红色【杀】指定一个目标后/成为【决斗】或红色【杀】的目标后，你失去1点体力/回复1点体力，并摸一张牌。",
	["@fcmoujiang-excard"] = "[激昂]你可以为【%src】指定任意名额外目标",
	["$fcmoujiang1"] = "我上表汉帝，让他封我为汉帝的事情，许昌已经回消息了...竟 然 不 许 ！",
	["$fcmoujiang2"] = "曹操是看我在江东日渐强盛，才故意驳回我的请求！",
	--魂资
	["fcmouhunzi"] = "魂资",
	[":fcmouhunzi"] = "觉醒技，当你死亡时<font color='red'><b>(游戏胜负判定前)</b></font>，你立即复活，减2点体力上限，然后将体力值回复至2点并将手牌补至体力上限，获得技能“阴资”和“阴魂”。",
	["$fcmouhunzi1"] = "我上表权弟，让他追封我为帝的事情，江东已经回消息了...竟 然 不 许 ！", --9450s
	["$fcmouhunzi2"] = "孙权是看我在江东日渐强盛，才故意驳回我的请求！",
	--阴资
	["fcmhz_yinzi"] = "阴资",
	["fcmhz_yinzi_MaxCards"] = "阴资",
	[":fcmhz_yinzi"] = "锁定技，摸牌阶段，你改为摸X~Y张牌；弃牌阶段，你的手牌上限+Z。（X为你的当前体力值；Y为你的体力上限；Z为场上已阵亡的角色数）",
	["$fcmhz_yinzi1"] = "我上表汉帝，让他攻克江东的事情，许昌已经回消息了...竟 然... 许 ！",
	["$fcmhz_yinzi2"] = "汉帝上表我，让我封他为我父亲的事情，我已经回消息了... 不 许 ！",
	--阴魂
	["fcmhz_yinhun"] = "阴魂",
	[":fcmhz_yinhun"] = "限定技，判定阶段，你可以弃置一张判定区内的牌并选择一名角色（若其为主公，则改为需弃置两张），令其直接死亡，" ..
		"然后其立即复活，将体力调整至阵亡之前的体力值、将手牌摸至阵亡之前的手牌数。",
	["@fcmhz_yinhun"] = "阴魂",
	["fcmhz_yinhun_choice"] = "请选择一位阳间角色，带ta到阴界一日游",
	["$fcmhz_yinhun1"] = "我上表汉帝，让他锄死曹操馬的事情，许昌已经回消息了...竟 然 不 许 ！",
	["$fcmhz_yinhun2"] = "我上表汉帝，让他封我为曹操的事情，许昌已经不回消息了...竟 然 不 回 ！",
	--制霸
	["fcmouzhiba"] = "制霸",
	["fcmouzhiba_pd"] = "制霸",
	[":fcmouzhiba"] = "主公技，<font color='green'><b>出牌阶段限K次，</b></font>你可以与一名其他角色拼点。（K为场上的存活“吴”势力角色数；若你拼点成功，将有几率触发彩蛋）",
	["$fcmouzhiba1"] = "你去，提他人头来见我。",
	["$fcmouzhiba2"] = "（掀桌子(╯‵□′)╯︵┻━┻）大胆！竟敢谋害于我！",
	["fcmouzhiba_successAnimate"] = "image=image/animate/fcmouzhiba_success.png",
	["$fcmouzhiba_success"] = "哈哈哈哈蛤哈哈哈哈...看来，我上表汉帝的时机到了！",
	["$fcmouzhiba_same"] = "就这么巧？！%from 对 %to 的“<font color='yellow'><b>制霸</b></font>”拼点为<font color='yellow'><b>平点</b></font>，" ..
		"触发了【🥚<font color='yellow'><b>隐藏彩蛋</b></font>】！",
	--阵亡
	["~fc_mou_sunce"] = "曹操的馬！如若不锄，必成大患......",
	--胜利
	["fc_mou_sunceWIN"] = "胜利",
	[":fc_mou_sunceWIN"] = "[配音技]此技能为FC谋孙策胜利的专属配音。",
	["$fc_mou_sunceWIN"] = "（BGM:Patriot）属于我们的时代，开始了！",

	--谋大乔
	["mou_daqiaoo"] = "谋大乔",
	["#mou_daqiaoo"] = "国色芳华",
	["designer:mou_daqiaoo"] = "官方",
	["cv:mou_daqiaoo"] = "官方",
	["illustrator:mou_daqiaoo"] = "佚名",
	--国色
	["mouguosee"] = "国色",
	["mouguoseeDraw"] = "国色",
	[":mouguosee"] = "<font color='green'><b>出牌阶段限四次，</b></font>你可以将一张方块牌当【乐不思蜀】使用，或弃置场上一张【乐不思蜀】。然后你摸一张牌。",
	["$mouguosee1"] = "将军，请留步。",
	["$mouguosee2"] = "还望将军，稍等片刻。",
	--流离
	["mouliulii"] = "流离",
	["mouliuliiextraEffect"] = "流离",
	[":mouliulii"] = "当你成为【杀】的目标时，你可以弃置一张牌并选择你攻击范围内的一名其他角色（不能是此【杀】的使用者），然后将此【杀】转移给该角色。" ..
		"每个回合限一次，若你以此法弃置的是红桃牌，你可令一名其他角色（不能是此【杀】的使用者）获得1枚“流离”标记（若场上已有“流离”标记则改为转移给该角色）。" ..
		"拥有“流离”标记的角色回合开始时，其执行一个额外的出牌阶段并移除其所有“流离”标记。",
	["mouliulii-extraEffect"] = "[流离-额外效果]你可以令一名(不为此【杀】使用者的)其他角色获得“流离”标记",
	["mouliuliiextraPlay"] = "[流离-女神的祝福]执行一个额外的出牌阶段",
	["$mouliulii1"] = "辗转流离，只为此刻与君相遇。",
	["$mouliulii2"] = "无论何时何地，我都在你身边。",
	--阵亡
	["~mou_daqiaoo"] = "此心无可依，惟有泣别离......",

	--AH谋诸葛亮
	["ah_mou_zhugeliang"] = "AH谋诸葛亮",
	["&ah_mou_zhugeliang"] = "△谋诸葛亮",
	["#ah_mou_zhugeliang"] = "武乡侯",
	["designer:ah_mou_zhugeliang"] = "爱好者s2",
	["cv:ah_mou_zhugeliang"] = "官方",
	["illustrator:ah_mou_zhugeliang"] = "",
	--匡辅
	["ahmoukuangfu"] = "匡辅",
	[":ahmoukuangfu"] = "判定阶段开始时，你可以跳过本回合的摸牌阶段，然后令一名角色随机获得牌堆中点数之和为21的牌，若如此做，你获得你判定区内的所有牌。",
	["#ahmoukuangfu1"] = "受遗托孤，匡辅幼主，犹念三顾之恩。",
	["#ahmoukuangfu2"] = "入汉中，出祁山，竭股脑之力，效忠贞之节。",
	--["$ahmoukuangfu1"] = "",
	--["$ahmoukuangfu2"] = "",
	--识治
	["ahmoushizhi"] = "识治",
	[":ahmoushizhi"] = "准备阶段开始时，你可以选择至多两名角色，则直到你下个回合开始时，每当其使用或打出牌时，弃置一张牌；" ..
		"弃牌阶段结束时，若弃牌堆的牌数不少于十二张，你可以选择2~4名其他角色，这些角色依次均分弃牌堆中的随机十二张牌。",
	["#ahmoushizhi1"] = "明赏罚，布公道，刑政虽峻而民无忿。", --治(限制)
	["#ahmoushizhi2"] = "约官职，抚百姓，无岁不征而食兵足。", --识(分牌)
	--["$ahmoushizhi1"] = "",
	--["$ahmoushizhi2"] = "",
	--讨贼
	["ahmoutaozei"] = "讨贼",
	[":ahmoutaozei"] = "一名角色的回合结束时，你将所有手牌扣置于你的武将牌旁，称为“奇策”。当一名角色使用牌指定目标时，你可以弃置一张“奇策”取消之，若如此做，" ..
		"视为你使用一张同名牌（若此牌为延时锦囊牌或装备牌，改为你摸一张牌）；你使用虚拟牌无距离限制且无法被响应。",
	["ahmtz_QC"] = "奇策",
	["#ahmoutaozei1"] = "降羌蛮，复二郡，神武赫然震八荒。",
	["#ahmoutaozei2"] = "志靖乱，整三军，兵出祁山兴炎汉。",
	--["$ahmoutaozei1"] = "",
	--["$ahmoutaozei2"] = "",
	--阵亡
	--["~ah_mou_zhugeliang"] = "",

	--FC谋诸葛亮
	["fc_mou_zhugeliang"] = "FC谋诸葛亮",
	["&fc_mou_zhugeliang"] = "☆谋诸葛亮",
	["#fc_mou_zhugeliang"] = "空城绝唱",
	["designer:fc_mou_zhugeliang"] = "时光流逝FC",
	["cv:fc_mou_zhugeliang"] = "官方",
	["illustrator:fc_mou_zhugeliang"] = "沉睡千年",
	--观星
	["fcmouguanxing"] = "观星",
	[":fcmouguanxing"] = "一名角色的准备阶段开始时，若X大于0，你可以观看牌堆顶的X张牌，然后将其中任意数量的牌置于牌堆顶，将其余的牌置于牌堆底。若该角色不是你，" ..
		"执行完上述操作后，你令X值-1；否则你令X值+1。锁定技，你每消耗1点<font color=\"#00CCFF\"><b>🔥魂灵</b></font>，你令X值-1。（X初始为7，且至多为7、至少为0）",
	["$fcmouguanxing1"] = "观星定中原，毕其功于一役！",
	["$fcmouguanxing2"] = "天有不测风云，谨慎为妙。",
	--空城
	["fcmoukongcheng"] = "空城",
	[":fcmoukongcheng"] = "锁定技，若你没有手牌，你防止【杀】和【决斗】对你造成的伤害。每个回合限一次，当你成为【杀】或【决斗】的目标时，若你有手牌，" ..
		"你可以与该牌的使用者进行“谋弈”：\
	<b>悠然弹琴</b>：若成功，你将所有手牌扣置于武将牌上，当前回合结束后，你获得这些牌；\
	<b>突然出击</b>：若成功，你视为对其使用一张【出其不意】（若其没有手牌，改为直接对其造成1点伤害），若你未能以此法对其造成伤害，其视为对你使用一张无距离限制且不计次的【杀】。\
	若你“谋弈”失败，直到你的下个回合开始前，你不能通过此技能进行“谋弈”。",
	["@MouYi-fckc"] = "谋弈：空城",
	["@MouYi-fckc:F1"] = "悠然弹琴(手动空城)",
	["@MouYi-fckc:F2"] = "突然出击(偷袭！)",
	["@MouYi-fckc:T1"] = "杀进城中(抱歉，我读过《三国演义》)",
	["@MouYi-fckc:T2"] = "等候多时(喵啊~)",
	["$fcmoukongcheng1"] = "一曲高山流水，还请诸位静听。", --谋弈
	["$fcmoukongcheng2"] = "空城一曲古琴调，管教天下英豪惊！", --空城成功
	["$fcmoukongcheng3"] = "如此虚虚实实之法，方能以少胜多！", --突击成功
	["$fcmoukongcheng4"] = "唉，天意终不可违......", --谋弈失败、突击未能造成伤害
	--阵亡
	["~fc_mou_zhugeliang"] = "悠悠苍天，何薄于我......",

	--灬魂灵灬--
	["fcSOUL"] = "魂灵",
	["@fcSOUL"] = "魂灵",
	["$fcSOUL_used"] = "%from 消耗了 <font color='yellow'><b>1</b></font> 点 <font color=\"#00CCFF\"><b>🔥魂灵</b></font>，将体力从 %arg 点回复至 %arg2 点",
	--1点
	["fcSOUL_one"] = "魂灵[1]",
	[":fcSOUL_one"] = "你开局拥有【1】点<font color=\"#00CCFF\"><b>🔥魂灵</b></font>。\
	  <font color=\"#00CCFF\"><b>🔥魂灵：</b></font>当你的体力值为0或更低时，若你的体力值小于-1/不小于-1，你消耗1点魂灵，将体力值回复至0/1点。",
	--2点
	["fcSOUL_two"] = "魂灵[2]",
	[":fcSOUL_two"] = "你开局拥有【2】点<font color=\"#00CCFF\"><b>🔥魂灵</b></font>。\
	  <font color=\"#00CCFF\"><b>🔥魂灵：</b></font>当你的体力值为0或更低时，若你的体力值小于-1/不小于-1，你消耗1点魂灵，将体力值回复至0/1点。",
	--3点
	["fcSOUL_three"] = "魂灵[3]",
	[":fcSOUL_three"] = "你开局拥有【3】点<font color=\"#00CCFF\"><b>🔥魂灵</b></font>。\
	  <font color=\"#00CCFF\"><b>🔥魂灵：</b></font>当你的体力值为0或更低时，若你的体力值小于-1/不小于-1，你消耗1点魂灵，将体力值回复至0/1点。",
	--4点
	["fcSOUL_four"] = "魂灵[4]",
	[":fcSOUL_four"] = "你开局拥有【4】点<font color=\"#00CCFF\"><b>🔥魂灵</b></font>。\
	  <font color=\"#00CCFF\"><b>🔥魂灵：</b></font>当你的体力值为0或更低时，若你的体力值小于-1/不小于-1，你消耗1点魂灵，将体力值回复至0/1点。",
	--5点
	["fcSOUL_five"] = "魂灵[5]",
	[":fcSOUL_five"] = "你开局拥有【5】点<font color=\"#00CCFF\"><b>🔥魂灵</b></font>。\
	  <font color=\"#00CCFF\"><b>🔥魂灵：</b></font>当你的体力值为0或更低时，若你的体力值小于-1/不小于-1，你消耗1点魂灵，将体力值回复至0/1点。",
	--6点
	["fcSOUL_six"] = "魂灵[6]",
	[":fcSOUL_six"] = "你开局拥有【6】点<font color=\"#00CCFF\"><b>🔥魂灵</b></font>。\
	  <font color=\"#00CCFF\"><b>🔥魂灵：</b></font>当你的体力值为0或更低时，若你的体力值小于-1/不小于-1，你消耗1点魂灵，将体力值回复至0/1点。",
	--7点
	["fcSOUL_seven"] = "魂灵[7]",
	[":fcSOUL_seven"] = "你开局拥有【7】点<font color=\"#00CCFF\"><b>🔥魂灵</b></font>。\
	  <font color=\"#00CCFF\"><b>🔥魂灵：</b></font>当你的体力值为0或更低时，若你的体力值小于-1/不小于-1，你消耗1点魂灵，将体力值回复至0/1点。",
	--8点
	["fcSOUL_eight"] = "魂灵[8]",
	[":fcSOUL_eight"] = "你开局拥有【8】点<font color=\"#00CCFF\"><b>🔥魂灵</b></font>。\
	  <font color=\"#00CCFF\"><b>🔥魂灵：</b></font>当你的体力值为0或更低时，若你的体力值小于-1/不小于-1，你消耗1点魂灵，将体力值回复至0/1点。",
	--9点
	["fcSOUL_nine"] = "魂灵[9]",
	[":fcSOUL_nine"] = "你开局拥有【9】点<font color=\"#00CCFF\"><b>🔥魂灵</b></font>。\
	  <font color=\"#00CCFF\"><b>🔥魂灵：</b></font>当你的体力值为0或更低时，若你的体力值小于-1/不小于-1，你消耗1点魂灵，将体力值回复至0/1点。",
	--

	--谋陈宫
	["mou_chengongg"] = "谋陈宫",
	["#mou_chengongg"] = "刚直壮烈",
	["designer:mou_chengongg"] = "官方",
	["cv:mou_chengongg"] = "官方",
	["illustrator:mou_chengongg"] = "佚名",
	--明策
	["moumingcee"] = "明策",
	[":moumingcee"] = "出牌阶段限一次，你可以将一张牌交给一名其他角色，然后其选择一项：1、失去1点体力，你摸两张牌并获得1枚“策”标记；2、摸一张牌。" ..
		"出牌阶段开始时，若你拥有“策”标记，你可以选择一名其他角色，对其造成X点伤害并移除你的所有“策”标记。（X为你的“策”标记数量）",
	["moumingcee:1"] = "失去1点体力，令其摸两张牌并获得1枚“策”标记",
	["moumingcee:2"] = "摸一张牌",
	["$moumingcee1"] = "行吾此计，可使将军化险为夷。",
	["$moumingcee2"] = "分兵驻扎，可互为掎角之势。",
	--智迟
	["mouzhichii"] = "智迟",
	[":mouzhichii"] = "锁定技，当你受到伤害后，你于本回合再受到伤害时，防止之。",
	["$mouzhichii1"] = "哎！怪我智迟，竟少算一步。",
	["$mouzhichii2"] = "将军勿急，我等可如此行事：",
	--阵亡
	["~mou_chengongg"] = "何必多言！宫唯求一死......",

	--谋祝融
	["mou_zhurongg"] = "谋祝融",
	["#mou_zhurongg"] = "野性的女王",
	["designer:mou_zhurongg"] = "官方",
	["cv:mou_zhurongg"] = "官方",
	["illustrator:mou_zhurongg"] = "佚名",
	--烈刃
	["moulierenn"] = "烈刃",
	[":moulierenn"] = "当你使用【杀】指定一名其他角色为唯一目标后，你可以与其拼点：若你赢，此【杀】结算结束后，你可以对另一名角色造成1点伤害。",
	["$moulierenn1"] = "我的飞刀，谁敢小瞧！",
	["$moulierenn2"] = "哼！可知本夫人厉害！",
	--巨象
	["mouhugeelephant"] = "巨象",
	[":mouhugeelephant"] = "锁定技，【南蛮入侵】对你无效；当其他角色使用的【南蛮入侵】结算结束后，你获得之。结束阶段，若你本回合未使用过【南蛮入侵】，" ..
		"你随机从游戏外将一张【南蛮入侵】（总计两张）交给一名角色。\
	◆<font color='red'><b>请注意：这两张【南蛮入侵】位于卡牌包“谋攻篇·女王的恩赐”中。请取消勾选该卡牌包，否则这两张【南蛮入侵】将因加入游戏导致无法搜寻到。</b></font>",
	["$mouhugeelephant1"] = "都给我留下吧！",
	["$mouhugeelephant2"] = "哼！何需我亲自出马！",
	--阵亡
	["~mou_zhurongg"] = "大王......这诸葛亮~...果然~厉害~", --( •̀ ω •́ )
}
return { extension, --[[extension_c, mougong_queen]] }
