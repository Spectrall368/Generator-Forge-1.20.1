<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2023, Pylo, opensource contributors
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

/*
 *	MCreator note: This file will be REGENERATED on each build.
 */

package ${package}.init;

<#assign livingEffects = enchantments?filter(e -> e.effectsxml?contains('ench_component_mob_experience'))>
<#assign blockEffects = enchantments?filter(e -> e.effectsxml?contains('ench_component_block_experience'))>
<#assign hasEffects = livingEffects?size != 0 || blockEffects?size != 0>

public class ${JavaModName}Enchantments {

	public static final DeferredRegister<Enchantment> REGISTRY = DeferredRegister.create(ForgeRegistries.ENCHANTMENTS, ${JavaModName}.MODID);

	<#list enchantments as enchantment>
	public static final RegistryObject<Enchantment> ${enchantment.getModElement().getRegistryNameUpper()} =
		REGISTRY.register("${enchantment.getModElement().getRegistryName()}", ${enchantment.getModElement().getName()}Enchantment::new);
	</#list>

    <#if hasEffects>
	@Mod.EventBusSubscriber public static class EnchantmentEffectsHandler {
		<#if livingEffects?size != 0>
		@SubscribeEvent public static void onMobExperienceDrop(LivingExperienceDropEvent event) {
            Player player = event.getAttackingPlayer();

		    if (player == null) return;
			ItemStack stack = player.getMainHandItem();

			<#list livingEffects as ench>
                 ${ench.getModElement().getName()}Enchantment.onMobExperienceDrop(stack, event);
			</#list>
		}
		</#if>

		<#if blockEffects?size != 0>
		@SubscribeEvent public static void onBlockExperienceDrop(BlockEvent.BreakEvent event) {
			ItemStack stack = event.getPlayer().getMainHandItem();

			<#list blockEffects as ench>
                 ${ench.getModElement().getName()}Enchantment.onBlockExperienceDrop(stack, event);
			</#list>
		}
		</#if>
    }
    </#if>
}
<#-- @formatter:on -->