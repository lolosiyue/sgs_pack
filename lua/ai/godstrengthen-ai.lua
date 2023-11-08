--==神将强化计划==--

--电脑有50%的概率更换皮肤
sgs.ai_skill_invoke.GOD_changeFullSkin = function(self, data)
    if math.random() > 0.5 then return true end
	return false
end

--全自动：神关羽、神吕蒙、神曹操(2)、神吕布、神赵云、神司马懿、神刘备、神张辽(2)

--未写：神诸葛亮、新神赵云、神甘宁

--OL神关羽
sgs.ai_skill_invoke["olwushen_pindian"] = true

--神周瑜
sgs.ai_skill_invoke["qinyin_drawcard"] = true

--神陆逊
sgs.ai_skill_invoke["cuike_adjust"] = true