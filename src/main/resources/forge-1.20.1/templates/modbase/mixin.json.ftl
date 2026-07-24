<#assign mixins = []>
<#if w.getGElementsOfType('biome')?filter(e -> e.spawnBiome || e.spawnInCaves || e.spawnBiomeNether)?size != 0>
  <#assign mixins = mixins + ['NoiseGeneratorSettingsMixin', 'BiomeSourcePresetMixin']>
</#if>
<#if w.getGElementsOfType("block")?filter(e -> e.isSign())?size != 0>
	<#assign mixins = mixins + ['BlockEntityTypeAccessor']>
</#if>
<#if w.getGElementsOfType('enchantment')?filter(e -> e.effectsxml?contains('ench_component_prevent_armor_change') || e.effectsxml?contains('ench_component_prevent_equipment_drop'))?size != 0>
	<#assign mixins = mixins + ['EnchantmentHelperMixin']>
</#if>
{
  "required": true,
  "package": "${package}.mixin",
  "compatibilityLevel": "JAVA_17",
  "refmap": "${modid}.refmap.json",
  "mixins": [
	<#list mixins as mixin>"${mixin}"<#sep>,</#list>
  ],
  "client": [
  ],
  "injectors": {
    "defaultRequire": 1
  },
  "minVersion": "0.8.4"
}