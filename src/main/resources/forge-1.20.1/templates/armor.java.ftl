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
<#assign helmetCustomModel = data.helmetModelName != "Default" && data.getHelmetModel()?? && data.helmetModelPart?has_content>
<#assign bodyCustomModel = data.bodyModelName != "Default" && data.getBodyModel()?? && data.bodyModelPart?has_content && data.armsModelPartL?has_content && data.armsModelPartR?has_content>
<#assign leggingsCustomModel = data.leggingsModelName != "Default" && data.getLeggingsModel()?? && (data.leggingsModelPartL?has_content || data.leggingsModelPartR?has_content)>
<#assign bootsCustomModel = data.bootsModelName != "Default" && data.getBootsModel()?? && data.bootsModelPartL?has_content && data.bootsModelPartR?has_content>
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

		<@itemAttributeModifiers data.attributeModifiers?filter(e -> e.armorPieces[0]) "helmet" "ArmorItem.Type.HELMET" "EquipmentSlot.HEAD" data.damageValueHelmet/>

		<#if helmetCustomModel>
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

		<@itemAttributeModifiers data.attributeModifiers?filter(e -> e.armorPieces[1]) "chestplate" "ArmorItem.Type.CHESTPLATE" "EquipmentSlot.CHEST" data.damageValueBody/>

		<#if bodyCustomModel>
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

		<@itemAttributeModifiers data.attributeModifiers?filter(e -> e.armorPieces[2]) "leggings" "ArmorItem.Type.LEGGINGS" "EquipmentSlot.LEGS" data.damageValueLeggings/>

		<#if leggingsCustomModel>
		@Override public void initializeClient(Consumer<IClientItemExtensions> consumer) {
			consumer.accept(new IClientItemExtensions() {
                private HumanoidModel armorModel = null;
				@Override @OnlyIn(Dist.CLIENT) public HumanoidModel getHumanoidArmorModel(LivingEntity living, ItemStack stack, EquipmentSlot slot, HumanoidModel defaultModel) {
                    if (armorModel == null) {
                        ${data.leggingsModelName} model = new ${data.leggingsModelName}(Minecraft.getInstance().getEntityModels().bakeLayer(${data.leggingsModelName}.LAYER_LOCATION));
                        armorModel = new HumanoidModel(new ModelPart(Collections.emptyList(), Map.of(
                            "left_leg", <#if data.leggingsModelPartL?has_content>model.${data.leggingsModelPartL}<#else>new ModelPart(Collections.emptyList(), Collections.emptyMap())</#if>,
                            "right_leg", <#if data.leggingsModelPartR?has_content>model.${data.leggingsModelPartR}<#else>new ModelPart(Collections.emptyList(), Collections.emptyMap())</#if>,
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

		<@itemAttributeModifiers data.attributeModifiers?filter(e -> e.armorPieces[3]) "boots" "ArmorItem.Type.BOOTS" "EquipmentSlot.FEET" data.damageValueBoots/>

		<#if bootsCustomModel>
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
<#macro itemAttributeModifiers modifiers armorPart armorType defaultEquipSlot defense>
<#if modifiers?size != 0>
    <#assign hasToughness = data.toughness != 0>
    <#assign hasKnockbackResistance = data.knockbackResistance != 0>

    <#assign slots = [defaultEquipSlot]>
    <#assign hasGlobal = false>
    <#assign defaultModifiers = []>
    <#assign otherModifiers = []>
    <#list modifiers as modifier>
            private static final UUID UUID_${modifier?index} = UUID.fromString("${w.getUUID(registryname + "_" + modifier?index + "." + armorPart)}");

            <#if modifier.equipmentSlot.getUnmappedValue() == "default">
                <#assign eq = defaultEquipSlot>
                <#assign defaultModifiers += [modifier]>
            <#else>
                <#assign eq = modifier.equipmentSlot.getMappedValue(2)>
                <#assign otherModifiers += [modifier]>
            </#if>

            <#if eq?contains("()")>
                <#assign hasGlobal = true>
            <#else>
                <#if !slots?seq_contains(eq)>
                    <#assign slots += [eq]>
                </#if>
            </#if>
    </#list>

    @Override public Multimap<Attribute, AttributeModifier> getAttributeModifiers(EquipmentSlot equipmentSlot, ItemStack stack) {
    <#if slots?size == 1 && !hasGlobal>
        if (equipmentSlot == ${defaultEquipSlot}) {
            ImmutableMultimap.Builder<Attribute, AttributeModifier> builder = ImmutableMultimap.builder();
            builder.putAll(super.getAttributeModifiers(equipmentSlot, stack));
            builder.put(Attributes.ARMOR, new AttributeModifier(ARMOR_MODIFIER_UUID_PER_TYPE.get(${armorType}), "Armor modifier", ${defense}, AttributeModifier.Operation.ADDITION));

            <#if hasToughness>
            builder.put(Attributes.ARMOR_TOUGHNESS, new AttributeModifier(ARMOR_MODIFIER_UUID_PER_TYPE.get(${armorType}), "Armor toughness", ${data.toughness}, AttributeModifier.Operation.ADDITION));
            </#if>
            <#if hasKnockbackResistance>
            builder.put(Attributes.KNOCKBACK_RESISTANCE, new AttributeModifier(ARMOR_MODIFIER_UUID_PER_TYPE.get(${armorType}), "Armor knockback resistance", ${data.knockbackResistance}, AttributeModifier.Operation.ADDITION));
            </#if>

            <#list modifiers as modifier>
            builder.put(${modifier.attribute}, new AttributeModifier(UUID_${modifier?index}, "Armor modifier", ${modifier.amount}, AttributeModifier.Operation.${getAttributeOperation(modifier.operation)}));
            </#list>

            return builder.build();
        }

        return super.getAttributeModifiers(equipmentSlot, stack);
    }
    <#else>
        <#assign sortedModifiers = defaultModifiers + (otherModifiers?sort_by("equipmentSlot"))>

        <#if hasGlobal>
            ImmutableMultimap.Builder<Attribute, AttributeModifier> builder = ImmutableMultimap.builder();
            builder.putAll(super.getAttributeModifiers(equipmentSlot, stack));
        <#else>
            Multimap<Attribute, AttributeModifier> defaultModifiers = super.getAttributeModifiers(equipmentSlot, stack);
            ImmutableMultimap.Builder<Attribute, AttributeModifier> builder = null;
        </#if>

            if (equipmentSlot == ${defaultEquipSlot}) {
                <#if !hasGlobal>
                builder = initializeBuilder(builder, defaultModifiers);
                </#if>
                builder.put(Attributes.ARMOR, new AttributeModifier(ARMOR_MODIFIER_UUID_PER_TYPE.get(${armorType}), "Armor modifier", ${defense}, AttributeModifier.Operation.ADDITION));

                <#if hasToughness>
                builder.put(Attributes.ARMOR_TOUGHNESS, new AttributeModifier(ARMOR_MODIFIER_UUID_PER_TYPE.get(${armorType}), "Armor toughness", ${data.toughness}, AttributeModifier.Operation.ADDITION));
                </#if>
                <#if hasKnockbackResistance>
                builder.put(Attributes.KNOCKBACK_RESISTANCE, new AttributeModifier(ARMOR_MODIFIER_UUID_PER_TYPE.get(${armorType}), "Armor knockback resistance", ${data.knockbackResistance}, AttributeModifier.Operation.ADDITION));
                </#if>

                <#assign currentSlot = defaultEquipSlot>
                <#assign prevIsGlobal = false>

            <#list sortedModifiers as modifier>
                <#if modifier.equipmentSlot.getUnmappedValue() == "default">
                    <#assign eq = defaultEquipSlot>
                <#else>
                    <#assign eq = modifier.equipmentSlot.getMappedValue(2)>
                </#if>

                <#if currentSlot != eq>
                    <#if !prevIsGlobal>
                    }
                    </#if>

                    <#assign prevIsGlobal = eq?contains("()")>
                    <#assign currentSlot = eq>

                    <#if !prevIsGlobal>
                    if (<#if eq?contains(",")>List.of(${eq}).contains(equipmentSlot)<#else>equipmentSlot == ${eq}</#if>) {
                    </#if>

                    <#if !hasGlobal>
                    builder = initializeBuilder(builder, defaultModifiers);
                    </#if>

                </#if>
                builder.put(${modifier.attribute}, new AttributeModifier(UUID_${modifiers?seq_index_of(modifier)}, "Armor modifier", ${modifier.amount}, AttributeModifier.Operation.${getAttributeOperation(modifier.operation)}));
            </#list>

            <#if !prevIsGlobal>
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