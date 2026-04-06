<#-- @formatter:off -->
<#include "../mcitems_json.ftl">
{
    "type": "minecraft:stonecutting",
    <#if data.group?has_content>"group": "${data.group}",</#if>
    "count": ${data.recipeRetstackSize},
    "ingredient": {
        ${mappedMCItemToItemObjectJSON(data.stoneCuttingInputStack)}
    },
    "result": "${mappedMCItemToRegistryName(data.stoneCuttingReturnStack)}"
}
<#-- @formatter:on -->