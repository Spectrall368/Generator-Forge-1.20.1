<#include "mcitems_json.ftl">
"items": [
<#if field_list$item?size == 1>
  "${mappedMCItemToRegistryName(w.itemBlock(field_list$item?first))}"
<#else>
  <#list field_list$item as item>"${mappedMCItemToRegistryName(w.itemBlock(item))}"<#sep>,</#list>
</#if>
]