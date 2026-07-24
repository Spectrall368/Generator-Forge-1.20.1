<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2026, Pylo, opensource contributors
 #
 # This program is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program.  If not, see <https://www.gnu.org/licenses/>.
 #
 # Additional permission for code generator templates (*.ftl files)
 #
 # As a special exception, you may create a larger work that contains part or
 # all of the MCreator code generator templates (*.ftl files) and distribute
 # that work under terms of your choice, so long as that work isn't itself a
 # template for code generation. Alternatively, if you modify or redistribute
 # the template itself, you may (at your option) remove this special exception,
 # which will cause the template and the resulting code generator output files
 # to be licensed under the GNU General Public License without this special
 # exception.
-->

<#-- @formatter:off -->
package ${package}.mixin;

<#assign bindingCurse = enchantments?filter(e -> e.effectsxml?contains('ench_component_prevent_armor_change'))>
<#assign vanishingCurse = enchantments?filter(e -> e.effectsxml?contains('ench_component_prevent_equipment_drop'))>

@Mixin(EnchantmentHelper.class) public class EnchantmentHelperMixin {

    <#if bindingCurse?size != 0>
    @Inject(method = "hasBindingCurse", at = @At("RETURN"), cancellable = true)
    private static void hasBindingCurse(ItemStack stack, CallbackInfoReturnable<Boolean> cir) {
		<#list bindingCurse as ench>
        if (getItemEnchantmentLevel(${JavaModName}Enchantments.${ench.getModElement().getRegistryNameUpper()}.get(), stack) > 0) {
            cir.setReturnValue(true);
        }<#sep>else
        </#list>
    }
    </#if>

    <#if vanishingCurse?size != 0>
    @Inject(method = "hasVanishingCurse", at = @At("RETURN"), cancellable = true)
    private static void hasVanishingCurse(ItemStack stack, CallbackInfoReturnable<Boolean> cir) {
		<#list vanishingCurse as ench>
        if (getItemEnchantmentLevel(${JavaModName}Enchantments.${ench.getModElement().getRegistryNameUpper()}.get(), stack) > 0) {
            cir.setReturnValue(true);
        }<#sep>else
        </#list>
    }
    </#if>

   @Shadow
   public static int getItemEnchantmentLevel(Enchantment ench, ItemStack stack) {
      return -1;
   }
}