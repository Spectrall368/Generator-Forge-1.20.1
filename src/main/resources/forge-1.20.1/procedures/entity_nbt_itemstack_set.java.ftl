<#include "mcitems.ftl">
{
	Entity _entity${cbi} = ${input$entity};
	ItemStack _tagValue = ${mappedMCItemToItemStackCode(input$tagValue, 1)};
	_entity${cbi}.getPersistentData().put(${input$tagName}, !_tagValue.isEmpty() ? _tagValue.save(new CompoundTag()) : new CompoundTag());
}