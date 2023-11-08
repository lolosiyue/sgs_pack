--“地主之魂”AI
sgs.ai_skill_invoke.xydizhusoul = true --无脑收益就完事了
sgs.ai_skill_invoke["@xydizhusoul_imdz"] = true

--孙悟空
  --“金睛”AI（这个确实写不来，恐怖如斯）

  --“慈悲”AI
sgs.ai_skill_invoke.xycibei = true --无脑慈悲，大慈大悲！

  --“调整”【如意金箍棒】攻击范围（待补充）

--东海龙王
  --“龙宫”AI
sgs.ai_skill_invoke.xylonggong = function(self, data)
	local target = data:toPlayer()
	if self:isFriend(target) and self:isChained() then return false end --帮队友传导铁索伤害
	return true
end

  --“司天”AI（待补充）

--涛神（全自动）

--李白(新杀版本)
  --“酒仙”AI
sjjiuxian_skill = {}
sjjiuxian_skill.name = "sjjiuxian"
table.insert(sgs.ai_skills, sjjiuxian_skill)
sjjiuxian_skill.getTurnUseCard = function(self)
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	local card
	self:sortByUseValue(cards, true)
	for _, acard in ipairs(cards) do
		if acard:isKindOf("AOE") or acard:isKindOf("GlobalEffect") or acard:isKindOf("IronChain") then
			card = acard
			break
		end
	end
	if not card then return nil end
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	local card_str = ("analeptic:sjjiuxian[spade:%s]=%d"):format(number, card_id)
	local analeptic = sgs.Card_Parse(card_str)
	assert(analeptic)
	if sgs.Analeptic_IsAvailable(self.player, analeptic) then
		return analeptic
	end
end

sgs.ai_view_as.sjjiuxian = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place == sgs.Player_PlaceHand then
		if card:isKindOf("AOE") or card:isKindOf("GlobalEffect") or card:isKindOf("IronChain") then
			return ("analeptic:sjjiuxian[%s:%s]=%d"):format(suit, number, card_id)
		end
	end
end

function sgs.ai_cardneed.sjjiuxian(to, card, self)
	return card:isKindOf("AOE") or card:isKindOf("GlobalEffect") or card:isKindOf("IronChain")
end

  --“诗仙”AI
sgs.ai_skill_invoke.sjshixian = true

--李白(欢乐杀版本)
  --“诗仙”AI
sgs.ai_skill_invoke["@sjshixian_joy_getCards"] = true
    --《静夜思/行路难/将进酒》（略）
	--《侠客行》
sgs.ai_skill_invoke.sjshixian_xks = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

-----