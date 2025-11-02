if (${input$entity} instanceof LivingEntity _entity) {
	_entity.getAttribute(${generator.map(field$attribute, "attributes")}).getModifiers().forEach((_attribute) -> {
        if(_attribute.name.equals(${'"' + modid + ':' + field$name + '"'})) _entity.getAttribute(${generator.map(field$attribute, "attributes")}).removeModifier(_attribute);
	});
}