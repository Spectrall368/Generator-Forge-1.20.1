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
<#include "mcitems.ftl">
<#include "procedures.java.ftl">
<#include "triggers.java.ftl">
package ${package}.item;

<@javacompress>
<#if data.toolType == "Pickaxe" || data.toolType == "Axe" || data.toolType == "Sword" || data.toolType == "Spade"
		|| data.toolType == "Hoe" || data.toolType == "Shears" || data.toolType == "Shield" || data.toolType == "MultiTool">
public class ${name}Item extends ${data.toolType?replace("Spade", "Shovel")?replace("MultiTool", "Tiered")}Item {
	public ${name}Item () {
		super(<#if data.toolType == "Pickaxe" || data.toolType == "Axe" || data.toolType == "Sword"
				|| data.toolType == "Spade" || data.toolType == "Hoe" || data.toolType == "MultiTool">
			new Tier() {
				public int getUses() {
					return ${data.usageCount};
				}

				public float getSpeed() {
					return ${data.efficiency}f;
				}

				public float getAttackDamageBonus() {
					<#if data.toolType == "Sword">
					return ${data.damageVsEntity - 4}f;
					<#elseif data.toolType == "Hoe">
					return ${data.damageVsEntity - 1}f;
					<#else>
					return ${data.damageVsEntity - 2}f;
					</#if>
				}

				public int getLevel() {
					<#if data.blockDropsTier == "WOOD" || data.blockDropsTier == "GOLD">
					return 0;
					<#elseif data.blockDropsTier == "STONE">
					return 1;
					<#elseif data.blockDropsTier == "IRON">
					return 2;
					<#elseif data.blockDropsTier == "DIAMOND">
					return 3;
					<#else>
					return 4;
					</#if>
				}

				public int getEnchantmentValue() {
					return ${data.enchantability};
				}

				public Ingredient getRepairIngredient() {
					return ${mappedMCItemsToIngredient(data.repairItems)};
				}
			},
			<#if data.toolType!="MultiTool">
				<#if data.toolType=="Sword">3<#elseif data.toolType=="Hoe">0<#else>1</#if>,${data.attackSpeed - 4}f,
			</#if>
		</#if>
				new Item.Properties()
				<#if data.toolType == "Shears" || data.toolType == "Shield">
				.durability(${data.usageCount})
				</#if>
				<#if data.rarity != "COMMON">
				.rarity(Rarity.${data.rarity})
				</#if>
				<#if data.immuneToFire>
				.fireResistant()
				</#if>
				<#if data.stayInGridWhenCrafting && data.usageCount != 0>
				.setNoRepair()
				</#if>
		);
	}

	<#if hasProcedure(data.additionalDropCondition)>
	@Override public boolean isCorrectToolForDrops(ItemStack itemstack, BlockState blockstate) {
		return super.isCorrectToolForDrops(itemstack, blockstate) && <@procedureCode data.additionalDropCondition, {
			"itemstack": "itemstack",
			"blockstate": "blockstate"
		}, false/>;
	}
	</#if>

	<#if (data.toolType == "Shield" || data.toolType == "Shears") && data.repairItems?has_content>
	@Override public boolean isValidRepairItem(ItemStack itemstack, ItemStack repairitem) {
		return ${mappedMCItemsToIngredient(data.repairItems)}.test(repairitem);
	}
	</#if>

	<#if data.toolType=="Shears">
        <#if data.enchantability != 0>
        @Override public int getEnchantmentValue(ItemStack itemstack) {
            return ${data.enchantability};
        }
        </#if>

		@Override public float getDestroySpeed(ItemStack stack, BlockState blockstate) {
			return ${data.efficiency}f;
		}
	<#elseif data.toolType=="MultiTool">
		@Override public boolean isCorrectToolForDrops(BlockState blockstate) {
			<#if hasProcedure(data.additionalDropCondition)>
				if(!<@procedureCode data.additionalDropCondition, {
					"itemstack": "this.getDefaultInstance()",
					"blockstate": "blockstate"
				}, false/>) return false;
			</#if>
			<#if data.blockDropsTier == "WOOD" || data.blockDropsTier == "GOLD">
			return !blockstate.is(BlockTags.NEEDS_STONE_TOOL) && !blockstate.is(BlockTags.NEEDS_IRON_TOOL) && !blockstate.is(BlockTags.NEEDS_DIAMOND_TOOL);
			<#elseif data.blockDropsTier == "STONE">
			return !blockstate.is(BlockTags.NEEDS_IRON_TOOL) && !blockstate.is(BlockTags.NEEDS_DIAMOND_TOOL);
			<#elseif data.blockDropsTier == "IRON">
			return !blockstate.is(BlockTags.NEEDS_DIAMOND_TOOL);
			<#else>
			return blockstate.is(BlockTags.MINEABLE_WITH_AXE) || blockstate.is(BlockTags.MINEABLE_WITH_HOE) || blockstate.is(BlockTags.MINEABLE_WITH_PICKAXE) || blockstate.is(BlockTags.MINEABLE_WITH_SHOVEL);
			</#if>
		}

		@Override public boolean canPerformAction(ItemStack stack, ToolAction toolAction) {
			return ToolActions.DEFAULT_AXE_ACTIONS.contains(toolAction) ||
					ToolActions.DEFAULT_HOE_ACTIONS.contains(toolAction) ||
					ToolActions.DEFAULT_SHOVEL_ACTIONS.contains(toolAction) ||
					ToolActions.DEFAULT_PICKAXE_ACTIONS.contains(toolAction) ||
					ToolActions.DEFAULT_SWORD_ACTIONS.contains(toolAction);
		}

		@Override public float getDestroySpeed(ItemStack itemstack, BlockState blockstate) {
			return ${data.efficiency}f;
		}
	</#if>

	<#if data.toolType == "MultiTool" || data.attributeModifiers?size gt 0>
	<@itemAttributeModifiers (data.toolType != "Shield" && data.toolType != "Shears")/>
	</#if>

	<#if data.toolType=="MultiTool">
		<@onBlockDestroyedWith data.onBlockDestroyedWithTool, true/>

		<@onEntityHitWith data.onEntityHitWith, true/>
	<#else>
		<@onBlockDestroyedWith data.onBlockDestroyedWithTool/>

		<@onEntityHitWith data.onEntityHitWith/>
	</#if>

	<@onRightClickedInAir data.onRightClickedInAir/>

	<@commonMethods/>

}
<#elseif data.toolType=="Special">
public class ${name}Item extends Item {

	public ${name}Item() {
		super(new Item.Properties()
			.durability(${data.usageCount})
			<#if data.rarity != "COMMON">
			.rarity(Rarity.${data.rarity})
			</#if>
			<#if data.immuneToFire>
			.fireResistant()
			</#if>
			<#if data.stayInGridWhenCrafting && data.usageCount != 0>
			.setNoRepair()
			</#if>
		);
	}

	@Override public float getDestroySpeed(ItemStack itemstack, BlockState blockstate) {
		return <#if data.blocksAffected?has_content>${containsAnyOfBlocks(data.blocksAffected "blockstate")} ? ${data.efficiency}f : </#if>1;
	}

	<@onBlockDestroyedWith data.onBlockDestroyedWithTool, true/>

	<@onEntityHitWith data.onEntityHitWith, true/>

	<@onRightClickedInAir data.onRightClickedInAir/>

	<#if data.enchantability != 0>
	@Override public int getEnchantmentValue(ItemStack itemstack) {
		return ${data.enchantability};
	}
	</#if>

	<@itemAttributeModifiers true/>

	<#if data.repairItems?has_content>
		@Override public boolean isValidRepairItem(ItemStack itemstack, ItemStack repairitem) {
			return ${mappedMCItemsToIngredient(data.repairItems)}.test(repairitem);
		}
	</#if>

	<@commonMethods/>
}
<#elseif data.toolType=="Fishing rod">
public class ${name}Item extends FishingRodItem {

	public ${name}Item() {
		super(new Item.Properties()
			.durability(${data.usageCount})
			<#if data.rarity != "COMMON">
			.rarity(Rarity.${data.rarity})
			</#if>
			<#if data.immuneToFire>
			.fireResistant()
			</#if>
			<#if data.stayInGridWhenCrafting && data.usageCount != 0>
			.setNoRepair()
			</#if>
		);
	}

	<#if data.repairItems?has_content>
    	@Override public boolean isValidRepairItem(ItemStack itemstack, ItemStack repairitem) {
			return ${mappedMCItemsToIngredient(data.repairItems)}.test(repairitem);
    	}
	</#if>

	<#if data.enchantability != 1>
	@Override public int getEnchantmentValue(ItemStack itemstack) {
		return ${data.enchantability};
	}
	</#if>

	<@onBlockDestroyedWith data.onBlockDestroyedWithTool/>

	<@onEntityHitWith data.onEntityHitWith/>

	<#if hasProcedure(data.onRightClickedInAir)>
	@Override public InteractionResultHolder<ItemStack> use(Level world, Player entity, InteractionHand hand) {
		super.use(world, entity, hand);
		ItemStack itemstack = entity.getItemInHand(hand);
		<@procedureCode data.onRightClickedInAir, {
			"x": "entity.getX()",
			"y": "entity.getY()",
			"z": "entity.getZ()",
			"world": "world",
			"entity": "entity",
			"itemstack": "itemstack"
		}/>

		return InteractionResultHolder.sidedSuccess(itemstack, world.isClientSide());
	}
	</#if>

	<#if data.attributeModifiers?size gt 0>
	<@itemAttributeModifiers/>
	</#if>

	<@commonMethods/>
}
</#if>
</@javacompress>

<#macro itemAttributeModifiers includeMeleeAttributes=false>
    <#assign slots = []>
    <#assign hasGlobal = false>
    <#assign validModifiers = []>
    <#list data.attributeModifiers as modifier>
        <#if modifier.amount != 0>
            <#assign validModifiers += [modifier]>
            private static final UUID UUID_${validModifiers?size-1} = UUID.fromString("${w.getUUID(registryname + "_" + (validModifiers?size-1))}");

            <#assign eq = generator.map(modifier.equipmentSlot, "equipmentslots", 2)>
            <#if eq?contains("()")>
                <#assign hasGlobal = true>
            <#else>
                <#if !slots?seq_contains(eq)>
                    <#assign slots += [eq]>
                </#if>
            </#if>
        </#if>
    </#list>

    <#assign validDamage = (data.damageVsEntity - 1) != 0 && (data.damageVsEntity - 1)?string != "-0">
    <#assign validAtkSpeed = (data.attackSpeed - 4) != 0 && (data.attackSpeed - 4)?string != "-0">
    <#assign hasMelee = includeMeleeAttributes && (validDamage || validAtkSpeed)>

    <#if hasMelee>
        <#if !slots?seq_contains("EquipmentSlot.MAINHAND")>
            <#assign slots += ["EquipmentSlot.MAINHAND"]>
        </#if>
    </#if>

    <#assign isSingleSlot = (slots?size == 1) && !hasGlobal>

    <#if isSingleSlot>
    <#assign singleEq = slots[0]>

    @Override public Multimap<Attribute, AttributeModifier> getAttributeModifiers(EquipmentSlot equipmentSlot, ItemStack stack) {
        <#if !singleEq?contains("()")>
        if (<#if singleEq?contains(",")>List.of(${singleEq}).contains(equipmentSlot)<#else>equipmentSlot == ${singleEq}</#if>) {
        </#if>

        ImmutableMultimap.Builder<Attribute, AttributeModifier> builder = ImmutableMultimap.builder();
        builder.putAll(super.getAttributeModifiers(equipmentSlot, stack));

        <#if hasMelee>
            <#if validDamage>
            builder.put(Attributes.ATTACK_DAMAGE, new AttributeModifier(BASE_ATTACK_DAMAGE_UUID, "Tool modifier", ${data.damageVsEntity - 1}, AttributeModifier.Operation.ADDITION));
            </#if>

            <#if validAtkSpeed>
            builder.put(Attributes.ATTACK_SPEED, new AttributeModifier(BASE_ATTACK_SPEED_UUID, "Tool modifier", ${data.attackSpeed - 4}, AttributeModifier.Operation.ADDITION));
            </#if>
        </#if>

        <#list validModifiers as modifier>
        builder.put(${modifier.attribute}, new AttributeModifier(UUID_${modifier?index}, "Tool modifier", ${modifier.amount}, AttributeModifier.Operation.${getAttributeOperation(modifier.operation)}));
        </#list>

        return builder.build();

        <#if !singleEq?contains("()")>
        }
        return super.getAttributeModifiers(equipmentSlot, stack);
        </#if>
    }
    <#else>
        <#assign hasAnyModifier = (validModifiers?size > 0)>
        <#if hasAnyModifier || hasMelee>
        @Override public Multimap<Attribute, AttributeModifier> getAttributeModifiers(EquipmentSlot equipmentSlot, ItemStack stack) {
            <#if hasGlobal>
            ImmutableMultimap.Builder<Attribute, AttributeModifier> builder = ImmutableMultimap.builder();
            builder.putAll(super.getAttributeModifiers(equipmentSlot, stack));
            <#else>
            Multimap<Attribute, AttributeModifier> defaultModifiers = super.getAttributeModifiers(equipmentSlot, stack);
            ImmutableMultimap.Builder<Attribute, AttributeModifier> builder = null;
            </#if>

            <#if hasMelee>
            if (equipmentSlot == EquipmentSlot.MAINHAND) {
                <#if !hasGlobal>
                builder = initializeBuilder(builder, defaultModifiers);
                </#if>

                <#if validDamage>
                builder.put(Attributes.ATTACK_DAMAGE, new AttributeModifier(BASE_ATTACK_DAMAGE_UUID, "Tool modifier", ${data.damageVsEntity - 1}, AttributeModifier.Operation.ADDITION));
                </#if>

                <#if validAtkSpeed>
                builder.put(Attributes.ATTACK_SPEED, new AttributeModifier(BASE_ATTACK_SPEED_UUID, "Tool modifier", ${data.attackSpeed - 4}, AttributeModifier.Operation.ADDITION));
                </#if>
            }
            </#if>

            <#assign sortedModifiers = validModifiers?sort_by("equipmentSlot")>
            <#assign currentSlot = "">

            <#list sortedModifiers as modifier>
                <#assign eq = generator.map(modifier.equipmentSlot, "equipmentslots", 2)>

                <#if modifier.equipmentSlot != currentSlot>

                    <#if currentSlot != "" && !prevGlobal>
                }
                    </#if>

                    <#assign currentSlot = modifier.equipmentSlot>
                    <#assign prevGlobal = eq?contains("()")>

                    <#if !prevGlobal>
                if (<#if eq?contains(",")>List.of(${eq}).contains(equipmentSlot)<#else>equipmentSlot == ${eq}</#if>) {
                    </#if>

                    <#if !hasGlobal>
                    builder = initializeBuilder(builder, defaultModifiers);
                    </#if>

                </#if>

                builder.put(${modifier.attribute}, new AttributeModifier(UUID_${validModifiers?seq_index_of(modifier)}, "Tool modifier", ${modifier.amount}, AttributeModifier.Operation.${getAttributeOperation(modifier.operation)}));
            </#list>

            <#if currentSlot != "" && !prevGlobal>
            }
            </#if>

            <#if hasGlobal>
            return builder.build();
            <#else>
            return builder != null ? builder.build() : defaultModifiers;
            </#if>
        }

            <#if !hasGlobal>
            private static ImmutableMultimap.Builder<Attribute, AttributeModifier> initializeBuilder(ImmutableMultimap.Builder<Attribute, AttributeModifier> builder,Multimap<Attribute, AttributeModifier> defaults) {
                if (builder == null) {
                    builder = ImmutableMultimap.builder();
                    builder.putAll(defaults);
                }

                return builder;
            }
            </#if>
        </#if>
    </#if>
</#macro>

<#macro commonMethods>
	<#if data.stayInGridWhenCrafting>
		@Override public boolean hasCraftingRemainingItem(ItemStack stack) {
			return true;
		}

		<#if data.damageOnCrafting && data.usageCount != 0>
			@Override public ItemStack getCraftingRemainingItem(ItemStack itemstack) {
				ItemStack retval = new ItemStack(this);
				retval.setDamageValue(itemstack.getDamageValue() + 1);
				if(retval.getDamageValue() >= retval.getMaxDamage()) {
					return ItemStack.EMPTY;
				}
				return retval;
			}
		<#else>
			@Override public ItemStack getCraftingRemainingItem(ItemStack itemstack) {
				return new ItemStack(this);
			}
		</#if>
	</#if>

	<@addSpecialInformation data.specialInformation, "item." + modid + "." + registryname/>

	<@onItemUsedOnBlock data.onRightClickedOnBlock/>

	<@onCrafted data.onCrafted/>

	<@onEntitySwing data.onEntitySwing/>

	<@onItemTick data.onItemInUseTick, data.onItemInInventoryTick/>

	<@onDroppedByPlayer data.onDroppedByPlayer/>

	<@onItemEntityDestroyed data.onItemEntityDestroyed/>

	<@hasGlow data.glowCondition/>

</#macro>
<#-- @formatter:on -->
<#function getAttributeOperation operation>
 	<#if operation == "ADD_VALUE">
 		<#return "ADDITION">
 	<#elseif operation == "ADD_MULTIPLIED_BASE">
 		<#return "MULTIPLY_BASE">
 	<#else>
 		<#return "MULTIPLY_TOTAL">
 	</#if>
</#function>