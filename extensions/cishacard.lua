extension = sgs.Package("cishacard", sgs.Package_GeneralPack)
local packages = {}
table.insert(packages, extension)

function CanToCard(card,from,to,tos)
	local plist = sgs.PlayerList()
	tos = tos or sgs.SPlayerList()
	for _,p in sgs.list(tos)do
		plist:append(p)
	end
  	return card and card:targetFilter(plist,to,from)
  	and not from:isProhibited(to,card,plist)
	and not plist:contains(to)
end

stabs_slash = sgs.CreateBasicCard
{
    name = "_stabs_slash",
    class_name = "Slash",
    subtype = "attack_card",
    can_recast = false,
	damage_card = true,
    available = function(self,player)
    	for n,to in sgs.list(player:getAliveSiblings())do
			if self:cardIsAvailable(player)
			and CanToCard(self,player,to)
			then
				n = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue,player,self)
				if player:hasWeapon("vscrossbow")
				then
					n = n+3
					if self:isVirtualCard()
					then
						for w,id in sgs.list(self:getSubcards())do
							w = player:getWeapon()
							if w and w:getEffectiveId()==id
							and w:objectName()=="vscrossbow"
							then n = n-3 break end
						end
					end
				end
				if player:hasWeapon("crossbow")
				then
					n = n+999
					if self:isVirtualCard()
					then
						for w,id in sgs.list(self:getSubcards())do
							w = player:getWeapon()
							if w and w:getEffectiveId()==id
							and w:objectName()=="crossbow"
							then n = n-999 break end
						end
					end
				end
				if player:getSlashCount()<=n
				or player:canSlashWithoutCrossbow()
				then return true end
				n = player:property("extra_slash_specific_assignee"):toString():split("+")
				if table.contains(n,to:objectName()) then return true end
			end
		end
    end,
	filter = function(self,targets,to_select,source)
		return source:canSlash(to_select,self)
	   	and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self)
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		local se = sgs.SlashEffectStruct()
        se.from = effect.from
        se.nature = effect.card:property("DamageStruct"):toInt()
		se.nature = se.nature<1 and sgs.DamageStruct_Normal or se.nature
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
	end,
}
stabs_slash:setParent(extension)

stabs_slash_on_trigger = sgs.CreateTriggerSkill{
	name = "stabs_slash_on_trigger",
	frequency = sgs.Skill_Compulsory,
    priority = 4,
    global = true,
    events = {sgs.SlashMissed},
    can_trigger = function(self,target)
        return target and target:isAlive()
    end,
    on_trigger = function(self,event,player,data)
        local room = player:getRoom()
        if event == sgs.SlashMissed then
			local effect = data:toSlashEffect()
			if effect.slash:objectName()=="_stabs_slash"
			and effect.jink
			then
				--Skill_msg("_stabs_slash",effect.from)
				if room:askForDiscard(effect.to,"_stabs_slash",1,1,true,false,"_stabs_slash0")
				then else room:slashResult(effect,nil) end
			end
        end
    end,
}

local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("stabs_slash_on_trigger") then skills:append(stabs_slash_on_trigger) end
sgs.Sanguosha:addSkills(skills)

sgs.LoadTranslationTable{
	["cishacard"] = "刺杀[游戏牌]",
    ["_stabs_slash"] = "刺杀",
    [":_stabs_slash"] = "基本牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：攻击范围内的一名其他角色<br /><b>效果</b>：对目标角色造成1点伤害。<br /><br /><b>额外效果</b>：目标使用【闪】抵消此【刺杀】时，其需弃置一张手牌，否则此【刺杀】依旧造成伤害。",
    ["_stabs_slash0"] = "刺杀:请弃置一张手牌，否则此【刺杀】依旧造成伤害",
}

return packages