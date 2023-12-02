sgs.ai_skill_playerchosen.bossdidong = function(self,targets)
	self:sort(self.enemies)
	for _,enemy in sgs.list(self.enemies)do
		if enemy:faceUp() then return enemy end
	end
end

sgs.ai_skill_playerchosen.bossluolei = function(self,targets)
	self:sort(self.enemies)
	for _,enemy in sgs.list(self.enemies)do
		if self:canAttack(enemy,self.player,sgs.DamageStruct_Thunder) then
			return enemy
		end
	end
end

sgs.ai_skill_playerchosen.bossguihuo = function(self,targets)
	self:sort(self.enemies)
	for _,enemy in sgs.list(self.enemies)do
		if self:canAttack(enemy,self.player,sgs.DamageStruct_Fire)
        and (enemy:hasArmorEffect("vine") or enemy:getMark("&kuangfeng")>0)
		then return enemy end
	end
	for _,enemy in sgs.list(self.enemies)do
		if self:canAttack(enemy,self.player,sgs.DamageStruct_Fire)
		then return enemy end
	end
end

sgs.ai_skill_playerchosen.bossxiaoshou = function(self,targets)
	self:sort(self.enemies)
	for _,enemy in sgs.list(self.enemies)do
		if enemy:getHp()>self.player:getHp() and self:canAttack(enemy,self.player) then
			return enemy
		end
	end
end

sgs.ai_armor_value.bossmanjia = function(card,player,self)
	if not card then return sgs.ai_armor_value.vine(player,self,true) end
end

sgs.ai_skill_invoke.bosslianyu = function(self,data)
	local value,avail = 0,0
	for _,enemy in sgs.list(self.enemies)do
		if not self:damageIsEffective(enemy,sgs.DamageStruct_Fire,self.player) then continue end
		avail = avail+1
		if self:canAttack(enemy,self.player,sgs.DamageStruct_Fire) then
			value = value+1
                        if enemy:hasArmorEffect("vine") or enemy:getMark("&kuangfeng")>0 then
				value = value+1
			end
		end
	end
	return avail>0 and value/avail>=2/3
end

sgs.ai_skill_invoke.bosssuoming = function(self,data)
	local value = 0
	for _,enemy in sgs.list(self.enemies)do
		if self:isGoodTarget(enemy,self.enemies) then
			value = value+1
		end
	end
	return value/#self.enemies>=2/3
end

sgs.ai_skill_playerchosen.bossxixing = function(self,targets)
	self:sort(self.enemies)
	for _,enemy in sgs.list(self.enemies)do
		if enemy:isChained() and self:canAttack(enemy,self.player,sgs.DamageStruct_Thunder) then
			return enemy
		end
	end
end

sgs.ai_skill_invoke.bossqiangzheng = function(self,data)
	local value = 0
	for _,enemy in sgs.list(self.enemies)do
		if enemy:getHandcardNum()==1 and (enemy:hasSkill("kongcheng") or (enemy:hasSkill("zhiji") and enemy:getMark("zhiji")==0)) then
			value = value+1
		end
	end
	return value/#self.enemies<2/3
end

sgs.ai_skill_invoke.bossqushou = function(self,data)
	local sa = dummyCard("savage_assault")
	local dummy_use = { isDummy = true }
	self:useTrickCard(sa,dummy_use)
	return (dummy_use.card~=nil)
end

sgs.ai_skill_invoke.bossmojian = function(self,data)
	local aa = dummyCard("archery_attack")
	local dummy_use = { isDummy = true }
	self:useTrickCard(aa,dummy_use)
	return (dummy_use.card~=nil)
end

sgs.ai_skill_invoke.bossdanshu = function(self,data)
	if not self.player:isWounded() then return false end
	local zj = self.room:findPlayerBySkillName("guidao")
	if self.player:getHp()/self.player:getMaxHp()>=0.5 and zj and self:isEnemy(zj) and self:canRetrial(zj) then return false end
	return true
end

local kuangxi_skill = {}
kuangxi_skill.name= "kuangxi"
table.insert(sgs.ai_skills,kuangxi_skill)
kuangxi_skill.getTurnUseCard=function(self)
	if not self.player:hasFlag("KuangxiEnterDying") then
		return sgs.Card_Parse("@KuangxiCard=.")
	end
end

sgs.ai_skill_use_func.KuangxiCard = function(card, use, self)
	self:sort(self.enemies, "hp")
	local can_invoke = false
	for _, friend in ipairs(self.friends) do
		if friend:hasSkill("baoying") and friend:getMark("@baoying") > 0 then
			can_invoke = true
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and self:damageIsEffective(enemy) then
			if self.player:getHp() >= enemy:getHp() and (self.player:getHp() > 1 or can_invoke) then
				use.card = sgs.Card_Parse("@KuangxiCard=.")
				if use.to then
					use.to:append(enemy)
				end
				return
			end
		end
	end
end

sgs.ai_skill_invoke.baoying = function(self, data)
	local dying = data:toDying()
	local peaches = 1 - dying.who:getHp()
	return (peaches > 1  or self:getCardsNum("Peach") + self:getCardsNum("Analeptic") < peaches) and self:isFriend(dying.who)
end

sgs.ai_use_value.KuangxiCard = 2.5
sgs.ai_card_intention.KuangxiCard = 80
sgs.dynamic_value.damage_card.KuangxiCard = true

sgs.ai_skill_askforyiji.huying = function(self,card_ids)
	return self.room:getLord(),card_ids[1]
end

function SmartAI:useCardGodNihilo(card, use)
	local xiahou = self.room:findPlayerBySkillName("yanyu")
	if xiahou and self:isEnemy(xiahou) and xiahou:getMark("YanyuDiscard2") > 0 then return end
	use.card = card
	if use.to then
		use.to:append(self.player)
		for _,p in sgs.list(self.friends_noself)do
			if CanToCard(card,self.player,p,use.to)
			then use.to:append(p) end
		end
	end
end

sgs.ai_card_intention.GodNihilo = -80

sgs.ai_keep_value.GodNihilo = 5
sgs.ai_use_value.GodNihilo = 10
sgs.ai_use_priority.GodNihilo = 1

sgs.dynamic_value.benefit.GodNihilo = true

SmartAI.useCardGodFlower = SmartAI.useCardSnatch

sgs.ai_use_value.GodFlower = 9
sgs.ai_use_priority.GodFlower = 4.3
sgs.ai_keep_value.GodFlower = 3.46
sgs.dynamic_value.control_card.GodFlower = true

sgs.ai_use_value.GodBlade = 5
sgs.ai_use_priority.GodBlade = 3
sgs.ai_use_value.GodDiagram = 8
sgs.ai_use_priority.GodDiagram = 4
sgs.ai_use_value.GodQin = 2
sgs.ai_use_value.GodPao = 8
sgs.ai_use_priority.GodPao = 5
sgs.ai_use_value.GodHalberd = 8
sgs.ai_use_priority.GodHalberd = 5
sgs.ai_use_value.GodHat = 6
sgs.ai_use_value.GodSword = 9
