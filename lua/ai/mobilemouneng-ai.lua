



addAiSkills("mobilemouyangwei").getTurnUseCard = function(self)
	return sgs.Card_Parse("@MobileMouYangweiCard=.")
end

sgs.ai_skill_use_func["MobileMouYangweiCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.MobileMouYangweiCard = 8.4
sgs.ai_use_priority.MobileMouYangweiCard = 5.8














