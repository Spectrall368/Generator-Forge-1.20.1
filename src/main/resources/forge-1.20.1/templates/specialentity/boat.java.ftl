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

<#assign boatEntities = specialentities?filter(e -> e.entityType == "Boat")>

public class ${JavaModName}Boat extends Boat {
	private static final EntityDataAccessor<Integer> DATA_ID_TYPE = SynchedEntityData.defineId(${JavaModName}Boat.class, EntityDataSerializers.INT);

	public ${JavaModName}Boat(EntityType<? extends Boat> entityType, Level level) {
		super(entityType, level);
	}

    <#if boatEntities?size != 0>
    public ${JavaModName}Boat(Level level, double x, double y, double z) {
        this(${JavaModName}Entities.${JavaModName?upper_case}_BOAT.get(), level);
        this.setPos(x, y, z);
        this.xo = x;
        this.yo = y;
        this.zo = z;
    }
    </#if>

	@Override protected Component getTypeName() {
		return Component.translatable("entity.minecraft.boat");
	}

	@Override public Item getDropItem() {
		return switch (getModVariant()) {
		<#list boatEntities as entity>
		    case ${entity.getModElement().getRegistryNameUpper()} -> ${JavaModName}Items.${entity.getModElement().getRegistryNameUpper()}.get();
		</#list>
		    default -> Items.AIR;
		};
	}

	@Override protected void defineSynchedData() {
		super.defineSynchedData();
		<#if boatEntities?has_content>
		this.entityData.define(DATA_ID_TYPE, Type.${boatEntities[0].getModElement().getRegistryNameUpper()}.ordinal());
		<#else>
		this.entityData.define(DATA_ID_TYPE, Type.${specialentities[0].getModElement().getRegistryNameUpper()}.ordinal());
		</#if>
	}

	@Override protected void addAdditionalSaveData(CompoundTag compound) {
		compound.putString("Type", getModVariant().getSerializedName());
	}

	@Override protected void readAdditionalSaveData(CompoundTag compound) {
		if (compound.contains("Type", 8)) {
			setVariant(Type.byName(compound.getString("Type")));
		}
	}

	public void setVariant(Type variant) {
		this.entityData.set(DATA_ID_TYPE, variant.ordinal());
	}

	public Type getModVariant() {
		return Type.byId(this.entityData.get(DATA_ID_TYPE));
	}

	public static enum Type implements StringRepresentable {
        <@javacompress>
            <#list specialentities as entity>
                ${entity.getModElement().getRegistryNameUpper()}(Blocks.OAK_PLANKS, "${entity.getModElement().getRegistryName()}", ${entity.entityType == "ChestBoat"})<#sep>,
            </#list>;
        </@javacompress>

        private final String name;
        private final Block planks;
        private final boolean hasChest;
        public static final StringRepresentable.EnumCodec<${JavaModName}Boat.Type> CODEC = StringRepresentable.fromEnum(${JavaModName}Boat.Type::values);
        private static final IntFunction<${JavaModName}Boat.Type> BY_ID = ByIdMap.continuous(Enum::ordinal, values(), ByIdMap.OutOfBoundsStrategy.ZERO);

        private Type(Block block, String name, boolean hasChest) {
            this.name = name;
            this.planks = block;
            this.hasChest = hasChest;
        }

        public String getSerializedName() {
            return name;
        }

        public String getName() {
            return name;
        }

        public Block getPlanks() {
            return planks;
        }

        public boolean hasChest() {
            return hasChest;
        }

        public String toString() {
            return name;
        }

        public static ${JavaModName}Boat.Type byId(int id) {
            return BY_ID.apply(id);
        }

        public static ${JavaModName}Boat.Type byName(String name) {
        	<#if boatEntities?has_content>
            return CODEC.byName(name, ${boatEntities[0].getModElement().getRegistryNameUpper()});
            <#else>
            return CODEC.byName(name, ${specialentities[0].getModElement().getRegistryNameUpper()});
            </#if>
        }
	}
}
<#-- @formatter:on -->