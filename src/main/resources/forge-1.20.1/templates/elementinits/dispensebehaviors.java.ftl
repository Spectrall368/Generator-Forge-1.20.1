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

<#include "../mcitems.ftl">
<#include "../procedures.java.ftl">

/*
 *	MCreator note: This file will be REGENERATED on each build.
 */

package ${package}.init;

<#assign itemextensions = w.getGElementsOfType("itemextension")?filter(e -> e.hasDispenseBehavior)>
<#assign specialentities = w.getGElementsOfType("specialentity")>
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

<@javacompress>
@Mod.EventBusSubscriber(bus = Mod.EventBusSubscriber.Bus.MOD) public class ${JavaModName}DispenseBehaviors {

	@SubscribeEvent public static void init(FMLCommonSetupEvent event) {
		event.enqueueWork(() -> {
			<#list itemextensions as extension>
			DispenserBlock.registerBehavior(${mappedMCItemToItem(extension.item)},
			<#if hasProcedure(extension.dispenseSuccessCondition)>
			new OptionalDispenseItemBehavior() {
				public ItemStack execute(BlockSource blockSource, ItemStack stack) {
					ItemStack itemstack = stack.copy();
					Level world = blockSource.getLevel();
					Direction direction = blockSource.getBlockState().getValue(DispenserBlock.FACING);
					int x = blockSource.getPos().getX();
					int y = blockSource.getPos().getY();
					int z = blockSource.getPos().getZ();

					this.setSuccess(<@procedureOBJToConditionCode extension.dispenseSuccessCondition/>);

					<#if hasProcedure(extension.dispenseResultItemstack)>
						boolean success = this.isSuccess();
						<#if hasReturnValueOf(extension.dispenseResultItemstack, "itemstack")>
							return <@procedureOBJToItemstackCode extension.dispenseResultItemstack, false/>;
						<#else>
							<@procedureOBJToCode extension.dispenseResultItemstack/>
							if (success) {
								itemstack.shrink(1);
							}
							return itemstack;
						</#if>
					<#else>
						if (this.isSuccess()) {
							itemstack.shrink(1);
						}
						return itemstack;
					</#if>
				}
			}
			<#else>
			new DefaultDispenseItemBehavior() {
				public ItemStack execute(BlockSource blockSource, ItemStack itemstack) {
					<#if hasProcedure(extension.dispenseResultItemstack)>
						<#if hasReturnValueOf(extension.dispenseResultItemstack, "itemstack")>
							return <@procedureCode extension.dispenseResultItemstack, {
								"x": "blockSource.getPos().getX()",
								"y": "blockSource.getPos().getY()",
								"z": "blockSource.getPos().getZ()",
								"itemstack": "itemstack.copy()",
								"world": "blockSource.getLevel()",
								"direction": "blockSource.getBlockState().getValue(DispenserBlock.FACING)",
								"success": "true" <#-- Dispense success condition defaults to true if not specified -->
							}, false/>;
						<#else>
							<@procedureCode extension.dispenseResultItemstack, {
								"x": "blockSource.getPos().getX()",
								"y": "blockSource.getPos().getY()",
								"z": "blockSource.getPos().getZ()",
								"itemstack": "itemstack.copy()",
								"world": "blockSource.getLevel()",
								"direction": "blockSource.getBlockState().getValue(DispenserBlock.FACING)",
								"success": "true" <#-- Dispense success condition defaults to true if not specified -->
							}/>
							itemstack.shrink(1);
							return itemstack;
						</#if>
					<#else>
						itemstack.shrink(1);
						return itemstack;
					</#if>
				}
			}
			</#if>
			);
			</#list>
			<#list specialentities as entity>
			DispenserBlock.registerBehavior(${JavaModName}Items.${entity.getModElement().getRegistryNameUpper()}.get(),
					new ${JavaModName}BoatDispenseItemBehavior(${JavaModName}Boat.Type.${entity.getModElement().getRegistryNameUpper()}));
			</#list>
		});
	}

	<#if specialentities?size != 0>
	public static class ${JavaModName}BoatDispenseItemBehavior extends DefaultDispenseItemBehavior {
	    private final DefaultDispenseItemBehavior defaultDispenseItemBehavior = new DefaultDispenseItemBehavior();
	    private final ${JavaModName}Boat.Type type;
	    private final boolean isChestBoat;

	    public ${JavaModName}BoatDispenseItemBehavior(${JavaModName}Boat.Type type) {
	        this.type = type;
	        this.isChestBoat = type.hasChest();
	    }

	    <#assign executeMethod = mcc.getMethod("net.minecraft.core.dispenser.BoatDispenseItemBehavior", "execute", "BlockSource", "ItemStack")>
	    <#if hasChestBoat>
	    	<#assign executeMethod = executeMethod.replace("new ChestBoat", "new " + JavaModName + "ChestBoat")>
	    </#if>
	    <#if hasBoat>
	    	<#assign executeMethod = executeMethod.replace("new Boat", "new " + JavaModName + "Boat")>
	    </#if>
	    <#assign executeMethod = executeMethod.replace("boat.setVariant(this.type);", variantSetterCode)>
	    @Override ${executeMethod}

	    @Override ${mcc.getMethod("net.minecraft.core.dispenser.BoatDispenseItemBehavior", "playSound", "BlockSource")}
	}
	</#if>
}</@javacompress>