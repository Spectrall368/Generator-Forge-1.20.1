<#assign attr = generator.map(field$attribute, "attributes")>
if (${input$entity} instanceof LivingEntity _entity) {
	AttributeModifier modifier = new AttributeModifier(UUID.fromString("${w.getUUID(field$name)}"), "${modid + ':' + field$name}", ${input$value}, AttributeModifier.Operation.${field$operation?replace("ADD_VALUE", "ADDITION")?replace("ADD_MULTIPLIED_BASE", "MULTIPLY_BASE")?replace("ADD_MULTIPLIED_TOTAL", "MULTIPLY_TOTAL")});
	if (!_entity.getAttribute(${attr}).hasModifier(modifier)) {
		<#if field$permanent == "TRUE">
			_entity.getAttribute(${attr}).addPermanentModifier(modifier);
		<#else>
			_entity.getAttribute(${attr}).addTransientModifier(modifier);
		</#if>
	}
}