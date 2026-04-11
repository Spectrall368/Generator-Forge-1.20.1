<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2025, Pylo, opensource contributors
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
<#assign hasBoat = specialentities?filter(e -> e.entityType == "Boat")?size != 0>
<#assign hasChestBoat = specialentities?filter(e -> e.entityType == "ChestBoat")?size != 0>
package ${package}.client.renderer;

import com.mojang.datafixers.util.Pair;

@OnlyIn(Dist.CLIENT)
public class ${JavaModName}BoatRenderer extends BoatRenderer {
	private final Map<${JavaModName}Boat.Type, Pair<ResourceLocation, ListModel<Boat>>> boatResources;

	public ${JavaModName}BoatRenderer(EntityRendererProvider.Context context, boolean hasChest) {
		super(context, hasChest);
		this.boatResources = Stream.of(${JavaModName}Boat.Type.values()).filter(type -> type.hasChest() == hasChest).collect(ImmutableMap.toImmutableMap(type -> type,
		    type -> Pair.of(new ResourceLocation("${modid}", getTextureLocation(type, hasChest)), createBoatModel(context, type, hasChest))));
	}

	private static String getTextureLocation(${JavaModName}Boat.Type type, boolean hasChest) {
		return hasChest ? "textures/entity/chest_boat/" + type.getName() + ".png" : "textures/entity/boat/" + type.getName() + ".png";
	}

	private ListModel<Boat> createBoatModel(EntityRendererProvider.Context context, ${JavaModName}Boat.Type type, boolean hasChest) {
		ModelLayerLocation modellayerlocation = hasChest ? createChestBoatModelName(type) : createBoatModelName(type);
		ModelPart modelpart = context.bakeLayer(modellayerlocation);
		return hasChest ? new ChestBoatModel(modelpart) : new BoatModel(modelpart);
	}

	private static ModelLayerLocation createBoatModelName(${JavaModName}Boat.Type type) {
		return createLocation("boat/" + type.getName(), "main");
	}

	private static ModelLayerLocation createChestBoatModelName(${JavaModName}Boat.Type type) {
		return createLocation("chest_boat/" + type.getName(), "main");
	}

	private static ModelLayerLocation createLocation(String path, String model) {
		return new ModelLayerLocation(new ResourceLocation("${modid}", path), model);
	}

	@Override public Pair<ResourceLocation, ListModel<Boat>> getModelWithLocation(Boat boat) {
		<#if hasBoat && hasChestBoat>
		return boat instanceof ${JavaModName}Boat modBoat ? this.boatResources.get(modBoat.getModVariant()) : (boat instanceof ${JavaModName}ChestBoat modChestBoat ? this.boatResources.get(modChestBoat.getModVariant()) : null);
		<#elseif hasBoat>
		return boat instanceof ${JavaModName}Boat modBoat ? this.boatResources.get(modBoat.getModVariant()) : null;
		<#else>
		return boat instanceof ${JavaModName}ChestBoat modChestBoat ? this.boatResources.get(modChestBoat.getModVariant()) : null;
		</#if>
	}
}
<#-- @formatter:on -->