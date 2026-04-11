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
package ${package}.entity;

import net.minecraft.network.syncher.EntityDataAccessor;

<#assign chestBoatEntities = specialentities?filter(e -> e.entityType == "ChestBoat")>
public class ${JavaModName}ChestBoat extends ChestBoat {
	private static final EntityDataAccessor<Integer> DATA_ID_TYPE = SynchedEntityData.defineId(${JavaModName}Boat.class, EntityDataSerializers.INT);

	public ${JavaModName}ChestBoat(EntityType<? extends Boat> entityType, Level level) {
		super(entityType, level);
	}

	public ${JavaModName}ChestBoat(Level level, double x, double y, double z) {
		this(${JavaModName}Entities.${JavaModName?upper_case}_CHEST_BOAT.get(), level);
		this.setPos(x, y, z);
		this.xo = x;
		this.yo = y;
		this.zo = z;
	}

	@Override protected Component getTypeName() {
		return Component.translatable("entity.minecraft.chest_boat");
	}

	@Override public Item getDropItem() {
		return switch (getModVariant()) {
		<#list chestBoatEntities as entity>
		    case ${entity.getModElement().getRegistryNameUpper()} -> ${JavaModName}Items.${entity.getModElement().getRegistryNameUpper()}.get();
		</#list>
		    default -> Items.AIR;
		};
	}

	@Override protected void defineSynchedData() {
		super.defineSynchedData();
		this.entityData.define(DATA_ID_TYPE, ${JavaModName}Boat.Type.${chestBoatEntities[0].getModElement().getRegistryNameUpper()}.ordinal());
	}

	@Override protected void addAdditionalSaveData(CompoundTag compound) {
		compound.putString("Type", getModVariant().getSerializedName());
	}

	@Override protected void readAdditionalSaveData(CompoundTag compound) {
		if (compound.contains("Type", 8)) {
			setVariant(${JavaModName}Boat.Type.byName(compound.getString("Type")));
		}
	}

	public void setVariant(${JavaModName}Boat.Type variant) {
		this.entityData.set(DATA_ID_TYPE, variant.ordinal());
	}

	public ${JavaModName}Boat.Type getModVariant() {
		return ${JavaModName}Boat.Type.byId(this.entityData.get(DATA_ID_TYPE));
	}

}
<#-- @formatter:on -->