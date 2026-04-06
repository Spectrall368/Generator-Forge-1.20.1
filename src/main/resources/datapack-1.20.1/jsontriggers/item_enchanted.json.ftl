"${registryname}_${cbi}": {
  "trigger": "minecraft:enchanted_item",
  "conditions": {
	"item": {
		"items": ${input$item},
		"enchantments": [
			<#list input_list$enchantment as enchantment>
				${enchantment}<#sep>,
			</#list>
		]
	},
	"levels": {
		"min": ${input$levelsSpent}
	}
  }
},