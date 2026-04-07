if (${input$entity} instanceof LivingEntity _entity) {
	_entity.getAttribute(${generator.map(field$attribute, "attributes")}).removeModifier(UUID.fromString("${w.getUUID(field$name)}"));
}