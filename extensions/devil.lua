  --新势力：魔
do
	require "lua.config"
	local config = config
	table.insert(config.kingdoms, "devil")
	config.kingdom_colors["devil"] = "#CC33CC"
end
sgs.LoadTranslationTable{
	["devil"] = "魔",
}