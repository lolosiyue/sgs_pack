
addAiSkills("mobilemouzhiheng").getTurnUseCard = function(self)
	return sgs.Card_Parse("@MobileMouZhihengCard=.")
end

sgs.ai_skill_use_func["MobileMouZhihengCard"] = function(card,use,self)
	local unpreferedCards = {}
	local cards = sgs.QList2Table(self.player:getHandcards())
	if self.player:getHp()<3 then
		local zcards = self.player:getCards("he")
		local use_slash,keep_jink,keep_analeptic,keep_weapon = false,false,false,nil
		local keep_slash = self.player:getTag("JilveWansha"):toBool()
		for _,zcard in sgs.qlist(zcards)do
			if not isCard("Peach",zcard,self.player) and not isCard("ExNihilo",zcard,self.player) then
				local shouldUse = true
				if isCard("Slash",zcard,self.player) and not use_slash then
					local dummy_use = { isDummy = true ,to = sgs.SPlayerList()}
					self:useBasicCard(zcard,dummy_use)
					if dummy_use.card then
						if keep_slash then shouldUse = false end
						if dummy_use.to then
							for _,p in sgs.qlist(dummy_use.to)do
								if p:getHp()<=1 then
									shouldUse = false
									if self.player:distanceTo(p)>1 then keep_weapon = self.player:getWeapon() end
									break
								end
							end
							if dummy_use.to:length()>1 then shouldUse = false end
						end
						if not self:isWeak() then shouldUse = false end
						if not shouldUse then use_slash = true end
					end
				end
				if zcard:getTypeId()==sgs.Card_TypeTrick then
					local dummy_use = { isDummy = true }
					self:useTrickCard(zcard,dummy_use)
					if dummy_use.card then shouldUse = false end
				end
				if zcard:getTypeId()==sgs.Card_TypeEquip and not self.player:hasEquip(zcard) then
					local dummy_use = { isDummy = true }
					self:useEquipCard(zcard,dummy_use)
					if dummy_use.card then shouldUse = false end
					if keep_weapon and zcard:getEffectiveId()==keep_weapon:getEffectiveId() then shouldUse = false end
				end
				if self.player:hasEquip(zcard) and zcard:isKindOf("Armor") and not self:needToThrowArmor() then shouldUse = false end
				if self.player:hasEquip(zcard) and zcard:isKindOf("DefensiveHorse") and not self:needToThrowArmor() then shouldUse = false end
				if self.player:hasEquip(zcard) and zcard:isKindOf("WoodenOx") and self.player:getPile("wooden_ox"):length()>1 then shouldUse = false end
				if isCard("Jink",zcard,self.player) and not keep_jink then
					keep_jink = true
					shouldUse = false
				end
				if self.player:getHp()==1 and isCard("Analeptic",zcard,self.player) and not keep_analeptic then
					keep_analeptic = true
					shouldUse = false
				end
				if shouldUse then table.insert(unpreferedCards,zcard:getId()) end
			end
		end
	end

	if #unpreferedCards==0 then
		local use_slash_num = 0
		self:sortByKeepValue(cards)
		for _,card in ipairs(cards)do
			if card:isKindOf("Slash") then
				local will_use = false
				if use_slash_num<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue,self.player,card) then
					local dummy_use = { isDummy = true }
					self:useBasicCard(card,dummy_use)
					if dummy_use.card then
						will_use = true
						use_slash_num = use_slash_num+1
					end
				end
				if not will_use then table.insert(unpreferedCards,card:getId()) end
			end
		end

		local num = self:getCardsNum("Jink")-1
		if self.player:getArmor() then num = num+1 end
		if num>0 then
			for _,card in ipairs(cards)do
				if card:isKindOf("Jink") and num>0 then
					table.insert(unpreferedCards,card:getId())
					num = num-1
				end
			end
		end
		for _,card in ipairs(cards)do
			if (card:isKindOf("Weapon") and self.player:getHandcardNum()<3) or card:isKindOf("OffensiveHorse")
				or self:getSameEquip(card,self.player) or card:isKindOf("AmazingGrace") then
				table.insert(unpreferedCards,card:getId())
			elseif card:getTypeId()==sgs.Card_TypeTrick then
				local dummy_use = { isDummy = true }
				self:useTrickCard(card,dummy_use)
				if not dummy_use.card then table.insert(unpreferedCards,card:getId()) end
			end
		end

		if self.player:getWeapon() and self.player:getHandcardNum()<3 then
			table.insert(unpreferedCards,self.player:getWeapon():getId())
		end

		if self:needToThrowArmor() then
			table.insert(unpreferedCards,self.player:getArmor():getId())
		end

		if self.player:getOffensiveHorse() and self.player:getWeapon() then
			table.insert(unpreferedCards,self.player:getOffensiveHorse():getId())
		end
	end

	for index = #unpreferedCards,1,-1 do
		if sgs.Sanguosha:getCard(unpreferedCards[index]):isKindOf("WoodenOx") and self.player:getPile("wooden_ox"):length()>1 then
			table.removeOne(unpreferedCards,unpreferedCards[index])
		end
	end

	local use_cards = {}
	for index = #unpreferedCards,1,-1 do
		if not self.player:isJilei(sgs.Sanguosha:getCard(unpreferedCards[index])) then table.insert(use_cards,unpreferedCards[index]) end
	end

	if #use_cards>0 then
		use.card = sgs.Card_Parse("@MobileMouZhihengCard="..table.concat(use_cards,"+"))
		return
	end
end

sgs.ai_use_value.MobileMouZhihengCard = 6.4
sgs.ai_use_priority.MobileMouZhihengCard = sgs.ai_use_priority.ZhihengCard







