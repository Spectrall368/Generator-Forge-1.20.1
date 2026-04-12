<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2024, Pylo, opensource contributors
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

import java.util.function.Consumer;
import net.minecraft.client.model.Model;

<@javacompress>
public abstract class ${name}Item extends ArmorItem {

	public ${name}Item(ArmorItem.Type type, Item.Properties properties) {
		super(new ArmorMaterial() {
			@Override public int getDurabilityForType(ArmorItem.Type type) {
				return new int[]{13, 15, 16, 11}[type.getSlot().getIndex()] * ${data.maxDamage};
			}

			@Override public int getDefenseForType(ArmorItem.Type type) {
				return new int[] { ${data.damageValueBoots}, ${data.damageValueLeggings}, ${data.damageValueBody}, ${data.damageValueHelmet} }[type.getSlot().getIndex()];
			}

			@Override public int getEnchantmentValue() {
				return ${data.enchantability};
			}

			@Override public SoundEvent getEquipSound() {
				<#if data.equipSound?has_content && data.equipSound.getUnmappedValue()?has_content>
				return ForgeRegistries.SOUND_EVENTS.getValue(new ResourceLocation("${data.equipSound}"));
				<#else>
				return SoundEvents.EMPTY;
				</#if>
			}

			@Override public Ingredient getRepairIngredient() {
				return ${mappedMCItemsToIngredient(data.repairItems)};
			}

			@Override public String getName() {
				return "${registryname}";
			}

			@Override public float getToughness() {
				return ${data.toughness}f;
			}

			@Override public float getKnockbackResistance() {
				return ${data.knockbackResistance}f;
			}
		}, type, properties);
	}

	<#if data.enableHelmet>
	public static class Helmet extends ${name}Item {

		public Helmet() {
			super(ArmorItem.Type.HELMET, new Item.Properties()<#if data.helmetImmuneToFire>.fireResistant()</#if><#if data.rarity != "COMMON">.rarity(Rarity.${data.rarity})</#if>);
		}

		<#if data.helmetModelName != "Default" && data.getHelmetModel()??>
		@Override public void initializeClient(Consumer<IClientItemExtensions> consumer) {
			consumer.accept(new IClientItemExtensions() {
                private HumanoidModel armorModel = null;
				@Override @OnlyIn(Dist.CLIENT) public HumanoidModel getHumanoidArmorModel(LivingEntity living, ItemStack stack, EquipmentSlot slot, HumanoidModel defaultModel) {
                    if (armorModel == null) {
                        armorModel = new HumanoidModel(new ModelPart(Collections.emptyList(), Map.of(
                            "head", new ${data.helmetModelName}(Minecraft.getInstance().getEntityModels().bakeLayer(${data.helmetModelName}.LAYER_LOCATION)).${data.helmetModelPart},
                            "hat", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "body", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "right_arm", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "left_arm", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "right_leg", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "left_leg", new ModelPart(Collections.emptyList(), Collections.emptyMap())
                        )))
                        <#if data.helmetTranslucency>
                        {
                            @Override
                            public void renderToBuffer(PoseStack poseStack, VertexConsumer buffer, int packedLight, int packedOverlay, float r, float g, float b, float alpha) {
                                VertexConsumer translucentTexture = Minecraft.getInstance().renderBuffers().bufferSource().getBuffer(RenderType.entityTranslucent(
                                    new ResourceLocation(
                                    <#if data.helmetModelTexture?has_content && data.helmetModelTexture != "From armor">
                                        ${JavaModName}Items.${REGISTRYNAME}_HELMET.get().getArmorTexture(null, null, null, null)
                                    <#else>
                                        "${modid}:textures/models/armor/${data.armorTextureFile}_layer_1.png"
                                    </#if>)
                                ));
                                super.renderToBuffer(poseStack, translucentTexture, packedLight, packedOverlay, r, g, b, alpha);
                            }
                        }
                        </#if>;
                    }
					armorModel.crouching = living.isShiftKeyDown();
					armorModel.riding = defaultModel.riding;
					armorModel.young = living.isBaby();
					return armorModel;
				}
			});
		}
		</#if>

		@Override public String getArmorTexture(ItemStack stack, Entity entity, EquipmentSlot slot, String type) {
			return "${modid}:textures/<#if data.helmetModelTexture?has_content && data.helmetModelTexture != "From armor">entities/${data.helmetModelTexture}<#else>models/armor/${data.armorTextureFile}_layer_1.png</#if>";
		}

		<@addSpecialInformation data.helmetSpecialInformation, "item." + modid + "." + registryname + "_helmet"/>

		<@hasGlow data.helmetGlowCondition/>

		<@piglinNeutral data.helmetPiglinNeutral/>

		<@onArmorTick data.onHelmetTick/>
	}
	</#if>

	<#if data.enableBody>
	public static class Chestplate extends ${name}Item {

		public Chestplate() {
			super(ArmorItem.Type.CHESTPLATE, new Item.Properties()<#if data.bodyImmuneToFire>.fireResistant()</#if><#if data.rarity != "COMMON">.rarity(Rarity.${data.rarity})</#if>);
		}

		<#if data.bodyModelName != "Default" && data.getBodyModel()??>
		@Override public void initializeClient(Consumer<IClientItemExtensions> consumer) {
			consumer.accept(new IClientItemExtensions() {
                private HumanoidModel armorModel = null;
				@Override @OnlyIn(Dist.CLIENT) public HumanoidModel getHumanoidArmorModel(LivingEntity living, ItemStack stack, EquipmentSlot slot, HumanoidModel defaultModel) {
                    if (armorModel == null) {
                        ${data.bodyModelName} model = new ${data.bodyModelName}(Minecraft.getInstance().getEntityModels().bakeLayer(${data.bodyModelName}.LAYER_LOCATION));
                        armorModel = new HumanoidModel(new ModelPart(Collections.emptyList(), Map.of(
                            "body", model.${data.bodyModelPart},
                            "left_arm", model.${data.armsModelPartL},
                            "right_arm", model.${data.armsModelPartR},
                            "head", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "hat", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "right_leg", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "left_leg", new ModelPart(Collections.emptyList(), Collections.emptyMap())
                        )))
                        <#if data.bodyTranslucency>
                        {
                            @Override
                            public void renderToBuffer(PoseStack poseStack, VertexConsumer buffer, int packedLight, int packedOverlay, float r, float g, float b, float alpha) {
                                VertexConsumer translucentTexture = Minecraft.getInstance().renderBuffers().bufferSource().getBuffer(RenderType.entityTranslucent(
                                    new ResourceLocation(
                                    <#if data.bodyModelTexture?has_content && data.bodyModelTexture != "From armor">
                                        ${JavaModName}Items.${REGISTRYNAME}_CHESTPLATE.get().getArmorTexture(null, null, null, null)
                                    <#else>
                                        "${modid}:textures/models/armor/${data.armorTextureFile}_layer_1.png"
                                    </#if>)
                                ));
                                super.renderToBuffer(poseStack, translucentTexture, packedLight, packedOverlay, r, g, b, alpha);
                            }
                        }
                        </#if>;
                    }
					armorModel.crouching = living.isShiftKeyDown();
					armorModel.riding = defaultModel.riding;
					armorModel.young = living.isBaby();
					return armorModel;
				}
			});
		}
		</#if>

		@Override public String getArmorTexture(ItemStack stack, Entity entity, EquipmentSlot slot, String type) {
			return "${modid}:textures/<#if data.bodyModelTexture?has_content && data.bodyModelTexture != "From armor">entities/${data.bodyModelTexture}<#else>models/armor/${data.armorTextureFile}_layer_1.png</#if>";
		}

		<@addSpecialInformation data.bodySpecialInformation, "item." + modid + "." + registryname + "_chestplate"/>

		<@hasGlow data.bodyGlowCondition/>

		<@piglinNeutral data.bodyPiglinNeutral/>

		<@onArmorTick data.onBodyTick/>
	}
	</#if>

	<#if data.enableLeggings>
	public static class Leggings extends ${name}Item {

		public Leggings() {
			super(ArmorItem.Type.LEGGINGS, new Item.Properties()<#if data.leggingsImmuneToFire>.fireResistant()</#if><#if data.rarity != "COMMON">.rarity(Rarity.${data.rarity})</#if>);
		}

		<#if data.leggingsModelName != "Default" && data.getLeggingsModel()??>
		@Override public void initializeClient(Consumer<IClientItemExtensions> consumer) {
			consumer.accept(new IClientItemExtensions() {
                private HumanoidModel armorModel = null;
				@Override @OnlyIn(Dist.CLIENT) public HumanoidModel getHumanoidArmorModel(LivingEntity living, ItemStack stack, EquipmentSlot slot, HumanoidModel defaultModel) {
                    if (armorModel == null) {
                        ${data.leggingsModelName} model = new ${data.leggingsModelName}(Minecraft.getInstance().getEntityModels().bakeLayer(${data.leggingsModelName}.LAYER_LOCATION));
                        armorModel = new HumanoidModel(new ModelPart(Collections.emptyList(), Map.of(
                            "left_leg", model.${data.leggingsModelPartL},
                            "right_leg", model.${data.leggingsModelPartR},
                            "head", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "hat", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "body", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "right_arm", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "left_arm", new ModelPart(Collections.emptyList(), Collections.emptyMap())
                        )))
                        <#if data.leggingsTranslucency>
                        {
                            @Override
                            public void renderToBuffer(PoseStack poseStack, VertexConsumer buffer, int packedLight, int packedOverlay, float r, float g, float b, float alpha) {
                                VertexConsumer translucentTexture = Minecraft.getInstance().renderBuffers().bufferSource().getBuffer(RenderType.entityTranslucent(
                                    new ResourceLocation(
                                    <#if data.leggingsModelTexture?has_content && data.leggingsModelTexture != "From armor">
                                        ${JavaModName}Items.${REGISTRYNAME}_LEGGINGS.get().getArmorTexture(null, null, null, null)
                                    <#else>
                                        "${modid}:textures/models/armor/${data.armorTextureFile}_layer_2.png"
                                    </#if>)
                                ));
                                super.renderToBuffer(poseStack, translucentTexture, packedLight, packedOverlay, r, g, b, alpha);
                            }
                        }
                        </#if>;
                    }
					armorModel.crouching = living.isShiftKeyDown();
					armorModel.riding = defaultModel.riding;
					armorModel.young = living.isBaby();
					return armorModel;
				}
			});
		}
		</#if>

		@Override public String getArmorTexture(ItemStack stack, Entity entity, EquipmentSlot slot, String type) {
			return "${modid}:textures/<#if data.leggingsModelTexture?has_content && data.leggingsModelTexture != "From armor">entities/${data.leggingsModelTexture}<#else>models/armor/${data.armorTextureFile}_layer_2.png</#if>";
		}

		<@addSpecialInformation data.leggingsSpecialInformation, "item." + modid + "." + registryname + "_leggings"/>

		<@hasGlow data.leggingsGlowCondition/>

		<@piglinNeutral data.leggingsPiglinNeutral/>

		<@onArmorTick data.onLeggingsTick/>
	}
	</#if>

	<#if data.enableBoots>
	public static class Boots extends ${name}Item {

		public Boots() {
			super(ArmorItem.Type.BOOTS, new Item.Properties()<#if data.bootsImmuneToFire>.fireResistant()</#if><#if data.rarity != "COMMON">.rarity(Rarity.${data.rarity})</#if>);
		}

		<#if data.bootsModelName != "Default" && data.getBootsModel()??>
		@Override public void initializeClient(Consumer<IClientItemExtensions> consumer) {
			consumer.accept(new IClientItemExtensions() {
                private HumanoidModel armorModel = null;
				@Override @OnlyIn(Dist.CLIENT) public HumanoidModel getHumanoidArmorModel(LivingEntity living, ItemStack stack, EquipmentSlot slot, HumanoidModel defaultModel) {
                    if (armorModel == null) {
                        ${data.bootsModelName} model = new ${data.bootsModelName}(Minecraft.getInstance().getEntityModels().bakeLayer(${data.bootsModelName}.LAYER_LOCATION));
                        armorModel = new HumanoidModel(new ModelPart(Collections.emptyList(), Map.of(
                            "left_leg", model.${data.bootsModelPartL},
                            "right_leg", model.${data.bootsModelPartR},
                            "head", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "hat", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "body", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "right_arm", new ModelPart(Collections.emptyList(), Collections.emptyMap()),
                            "left_arm", new ModelPart(Collections.emptyList(), Collections.emptyMap())
                        )))
                        <#if data.bootsTranslucency>
                        {
                            @Override
                            public void renderToBuffer(PoseStack poseStack, VertexConsumer buffer, int packedLight, int packedOverlay, float r, float g, float b, float alpha) {
                                VertexConsumer translucentTexture = Minecraft.getInstance().renderBuffers().bufferSource().getBuffer(RenderType.entityTranslucent(
                                    new ResourceLocation(
                                    <#if data.bootsModelTexture?has_content && data.bootsModelTexture != "From armor">
                                        ${JavaModName}Items.${REGISTRYNAME}_BOOTS.get().getArmorTexture(null, null, null, null)
                                    <#else>
                                        "${modid}:textures/models/armor/${data.armorTextureFile}_layer_1.png"
                                    </#if>)
                                ));
                                super.renderToBuffer(poseStack, translucentTexture, packedLight, packedOverlay, r, g, b, alpha);
                            }
                        }
                        </#if>;
                    }
					armorModel.crouching = living.isShiftKeyDown();
					armorModel.riding = defaultModel.riding;
					armorModel.young = living.isBaby();
					return armorModel;
				}
			});
		}
		</#if>

		@Override public String getArmorTexture(ItemStack stack, Entity entity, EquipmentSlot slot, String type) {
			return "${modid}:textures/<#if data.bootsModelTexture?has_content && data.bootsModelTexture != "From armor">entities/${data.bootsModelTexture}<#else>models/armor/${data.armorTextureFile}_layer_1.png</#if>";
		}

		<@addSpecialInformation data.bootsSpecialInformation, "item." + modid + "." + registryname + "_boots"/>

		<@hasGlow data.bootsGlowCondition/>

		<@piglinNeutral data.bootsPiglinNeutral/>

		<@onArmorTick data.onBootsTick/>
	}
	</#if>
}
</@javacompress>
<#-- @formatter:on -->