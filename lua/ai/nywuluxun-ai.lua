--彰才

sgs.ai_skill_invoke.ny_zhangcai = true

--雄幕

sgs.ai_skill_invoke.ny_xiongmu = true

sgs.ai_skill_discard.ny_xiongmu = function(self,max,min)
    local player = self.player
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	local dis = {}
    local n = 12
	for _,card in ipairs(cards) do
        table.insert(dis, card:getEffectiveId())
        n = n - 1
        if n <= 0 then break end
    end
	return dis
end

sgs.ai_ajustdamage_to.ny_xiongmu = function(self, from, to, card, nature)
	if to and to:getMark("ny_xiongmu-Clear") == 0 and to:getHandcardNum() <= to:getHp()
	then
		return -1
	end
end

--儒贤

local ny_ruxian_skill = {}
ny_ruxian_skill.name = "ny_ruxian"
table.insert(sgs.ai_skills, ny_ruxian_skill)
ny_ruxian_skill.getTurnUseCard = function(self, inclusive)
	if self.player:getMark("ny_ruxian_limit") == 0 then
		return sgs.Card_Parse("#ny_ruxian:.:")
	end
end

sgs.ai_skill_use_func["#ny_ruxian"] = function(card, use, self)
    use.card = card
end

sgs.ai_use_priority.ny_ruxian = 10