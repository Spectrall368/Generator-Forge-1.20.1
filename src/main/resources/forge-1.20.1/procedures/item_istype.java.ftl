<#include "mcitems.ftl">
<#if field$item_type == "Sword">
(${mappedMCItemToItemStackCode(input$item)}.is(ItemTags.SWORDS))
<#elseif field$item_type == "Pickaxe">
(${mappedMCItemToItemStackCode(input$item)}.is(ItemTags.PICKAXES))
<#else>
(${mappedMCItemToItem(input$item)} instanceof ${generator.map(field$item_type, "itemtypes")}Item)
</#if>