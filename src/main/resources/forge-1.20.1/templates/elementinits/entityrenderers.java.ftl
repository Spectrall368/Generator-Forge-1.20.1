<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2022, Pylo, opensource contributors
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
 *    MCreator note: This file will be REGENERATED on each build.
 */

package ${package}.init;

<#assign specialentities = w.getGElementsOfType("specialentity")>
@Mod.EventBusSubscriber(bus = Mod.EventBusSubscriber.Bus.MOD, value = Dist.CLIENT) public class ${JavaModName}EntityRenderers {

	@SubscribeEvent public static void registerEntityRenderers(EntityRenderersEvent.RegisterRenderers event) {
		<#list entities as entity>
			<#if entity.getModElement().getTypeString() == "projectile">
				<#if entity.isCustomModel()>
				event.registerEntityRenderer(${JavaModName}Entities.${entity.getModElement().getRegistryNameUpper()}.get(), ${entity.getModElement().getName()}Renderer::new);
				<#else>
				event.registerEntityRenderer(${JavaModName}Entities.${entity.getModElement().getRegistryNameUpper()}.get(), ThrownItemRenderer::new);
				</#if>
			<#elseif entity.getModElement().getTypeString() == "livingentity">
				event.registerEntityRenderer(${JavaModName}Entities.${entity.getModElement().getRegistryNameUpper()}.get(), ${entity.getModElement().getName()}Renderer::new);
				<#if entity.hasCustomProjectile()>
				event.registerEntityRenderer(${JavaModName}Entities.${entity.getModElement().getRegistryNameUpper()}_PROJECTILE.get(), ThrownItemRenderer::new);
				</#if>
			</#if>
		</#list>

		<#if specialentities?size != 0>
			<#if specialentities?filter(e -> e.entityType == "Boat")?size != 0>
			event.registerEntityRenderer(${JavaModName}Entities.${JavaModName?upper_case}_BOAT.get(), context -> new ${JavaModName}BoatRenderer(context, false));
			</#if>
			<#if specialentities?filter(e -> e.entityType == "ChestBoat")?size != 0>
			event.registerEntityRenderer(${JavaModName}Entities.${JavaModName?upper_case}_CHEST_BOAT.get(), context -> new ${JavaModName}BoatRenderer(context, true));
			</#if>
		</#if>
	}
}
<#-- @formatter:on -->