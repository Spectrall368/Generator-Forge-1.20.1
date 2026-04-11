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
package ${package}.item;

import net.minecraft.world.entity.EntitySelector;

<#assign hasBoat = specialentities?filter(e -> e.entityType == "Boat")?size != 0>
<#assign hasChestBoat = specialentities?filter(e -> e.entityType == "ChestBoat")?size != 0>

<#assign variantSetterCode>
<#if hasChestBoat && hasBoat>
if(boat instanceof ${JavaModName}ChestBoat chestBoat) {
    chestBoat.setVariant(this.type);
} else if(boat instanceof ${JavaModName}Boat boatt) {
    boatt.setVariant(this.type);
}
<#elseif hasChestBoat>
if(boat instanceof ${JavaModName}ChestBoat chestBoat)
    chestBoat.setVariant(this.type);
<#else>
if(boat instanceof ${JavaModName}Boat boatt)
    boatt.setVariant(this.type);
</#if>
</#assign>

public class ${JavaModName}BoatItem extends Item {
	private static final Predicate<Entity> ENTITY_PREDICATE = EntitySelector.NO_SPECTATORS.and(Entity::isPickable);
	private final ${JavaModName}Boat.Type type;
	private final boolean hasChest;

	public ${JavaModName}BoatItem(${JavaModName}Boat.Type type) {
		super(new Item.Properties().stacksTo(1));
		this.hasChest = type.hasChest();
		this.type = type;
	}

	<#assign useMethod = mcc.getMethod("net.minecraft.world.item.BoatItem", "use", "Level", "Player", "InteractionHand")>
	<#assign useMethod = useMethod.replace("boat.setVariant(this.type);", variantSetterCode)>
	@Override ${useMethod}

	private Boat getBoat(Level level, HitResult hitResult) {
		<#if hasBoat && hasChestBoat>
		return hasChest ? new ${JavaModName}ChestBoat(level, hitResult.getLocation().x, hitResult.getLocation().y, hitResult.getLocation().z) : new ${JavaModName}Boat(level, hitResult.getLocation().x, hitResult.getLocation().y, hitResult.getLocation().z);
		<#elseif hasChestBoat>
		return new ${JavaModName}ChestBoat(level, hitResult.getLocation().x, hitResult.getLocation().y, hitResult.getLocation().z);
		<#else>
		return new ${JavaModName}Boat(level, hitResult.getLocation().x, hitResult.getLocation().y, hitResult.getLocation().z);
		</#if>
	}
}
<#-- @formatter:on -->