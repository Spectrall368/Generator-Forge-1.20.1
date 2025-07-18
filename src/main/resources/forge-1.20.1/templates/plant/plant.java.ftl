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
<#include "../boundingboxes.java.ftl">
<#include "../procedures.java.ftl">
<#include "../triggers.java.ftl">
<#include "../mcitems.ftl">

package ${package}.block;

import net.minecraft.world.level.block.state.BlockBehaviour.Properties;

<#compress>
<#assign interfaces = []>
<#if data.hasTileEntity>
	<#assign interfaces += ["EntityBlock"]>
</#if>
<#if data.isBonemealable && data.plantType != "sapling">
	<#assign interfaces += ["BonemealableBlock"]>
</#if>
<#if data.isWaterloggable()>
	<#assign interfaces += ["SimpleWaterloggedBlock"]>
</#if>
public class ${name}Block extends ${getPlantClass(data.plantType)}Block
	<#if interfaces?size gt 0>
		implements ${interfaces?join(",")}
	</#if>{
	<#if data.isWaterloggable()>
		public static final BooleanProperty WATERLOGGED = BlockStateProperties.WATERLOGGED;
	</#if>

	public ${name}Block() {
		super(<#if data.plantType == "normal">
		() -> ${generator.map(data.suspiciousStewEffect, "effects")}, ${data.suspiciousStewDuration},
		<#elseif data.plantType == "sapling">
		new ${name}TreeGrower(),
		</#if>
		BlockBehaviour.Properties.of()
		<#if generator.map(data.colorOnMap, "mapcolors") != "DEFAULT">
		.mapColor(MapColor.${generator.map(data.colorOnMap, "mapcolors")})
		<#else>
		.mapColor(MapColor.PLANT)
		</#if>
		<#if data.plantType == "growapable" || data.plantType == "sapling" || data.forceTicking>
		.randomTicks()
		</#if>
		<#if data.isCustomSoundType>
			.sound(new ForgeSoundType(1.0f, 1.0f,
				() -> ForgeRegistries.SOUND_EVENTS.getValue(ResourceLocation.parse("${data.breakSound}")),
				() -> ForgeRegistries.SOUND_EVENTS.getValue(ResourceLocation.parse("${data.stepSound}")),
				() -> ForgeRegistries.SOUND_EVENTS.getValue(ResourceLocation.parse("${data.placeSound}")),
				() -> ForgeRegistries.SOUND_EVENTS.getValue(ResourceLocation.parse("${data.hitSound}")),
				() -> ForgeRegistries.SOUND_EVENTS.getValue(ResourceLocation.parse("${data.fallSound}"))
			))
		<#else>
			.sound(SoundType.${data.soundOnStep})
		</#if>
		<#if data.unbreakable>
		.strength(-1, 3600000)
		<#elseif (data.hardness == 0) && (data.resistance == 0)>
		.instabreak()
		<#else>
		.strength(${data.hardness}f, ${data.resistance}f)
		</#if>
		<#if data.emissiveRendering>
		.hasPostProcess((bs, br, bp) -> true).emissiveRendering((bs, br, bp) -> true)
		</#if>
		<#if data.speedFactor != 1.0>
		.speedFactor(${data.speedFactor}f)
		</#if>
		<#if data.jumpFactor != 1.0>
		.jumpFactor(${data.jumpFactor}f)
		</#if>
		<#if data.luminance != 0>
		.lightLevel(s -> ${data.luminance})
		</#if>
		<#if data.isSolid>
		.noOcclusion()
			<#if (data.customBoundingBox && data.boundingBoxes??) || (data.offsetType != "NONE")>
			.dynamicShape()
			</#if>
		<#else>
		.noCollission()
		</#if>
		<#if data.isReplaceable>
		.replaceable()
		</#if>
		<#if data.ignitedByLava>
		.ignitedByLava()
		</#if>
		.offsetType(BlockBehaviour.OffsetType.${data.offsetType}).pushReaction(PushReaction.DESTROY)
		);

		<#if data.isWaterloggable()>
		<@initStateProperties/>
		</#if>
	}

	<#if data.isWaterloggable()>
	@Override protected void createBlockStateDefinition(StateDefinition.Builder<Block, BlockState> builder) {
		super.createBlockStateDefinition(builder);
		builder.add(WATERLOGGED);
	}

	@Override
	public BlockState getStateForPlacement(BlockPlaceContext context) {
		BlockState state = super.getStateForPlacement(context);
		return state == null ? null : state.setValue(WATERLOGGED, context.getLevel().getFluidState(context.getClickedPos()).getType() == Fluids.WATER);
	}

	@Override public FluidState getFluidState(BlockState state) {
		return state.getValue(WATERLOGGED) ? Fluids.WATER.getSource(false) : super.getFluidState(state);
	}

	@Override public BlockState updateShape(BlockState state, Direction facing, BlockState facingState, LevelAccessor world, BlockPos currentPos, BlockPos facingPos) {
		if (state.getValue(WATERLOGGED)) {
			world.scheduleTick(currentPos, Fluids.WATER, Fluids.WATER.getTickDelay(world));
		}
		return super.updateShape(state, facing, facingState, world, currentPos, facingPos);
	}
	</#if>

	<#if data.customBoundingBox && data.boundingBoxes??>
	@Override public VoxelShape getShape(BlockState state, BlockGetter world, BlockPos pos, CollisionContext context) {
		<#if data.isBoundingBoxEmpty()>
			return Shapes.empty();
		<#else>
			<#if !data.disableOffset> Vec3 offset = state.getOffset(world, pos); </#if>
			<@boundingBoxWithRotation data.positiveBoundingBoxes() data.negativeBoundingBoxes() data.disableOffset 0/>
		</#if>
	}
	</#if>

	<#if (data.plantType == "normal") && (data.suspiciousStewDuration > 0)>
	@Override public int getEffectDuration() {
		return ${data.suspiciousStewDuration};
	}
	</#if>

	<#if data.flammability != 0>
	@Override public int getFlammability(BlockState state, BlockGetter world, BlockPos pos, Direction face) {
		return ${data.flammability};
	}
	</#if>

	<#if generator.map(data.aiPathNodeType, "pathnodetypes") != "DEFAULT">
	@Override public BlockPathTypes getBlockPathType(BlockState state, BlockGetter world, BlockPos pos, Mob entity) {
		return BlockPathTypes.${generator.map(data.aiPathNodeType, "pathnodetypes")};
	}
	</#if>

	<@addSpecialInformation data.specialInformation, "block." + modid + "." + registryname, true/>

	<#if data.fireSpreadSpeed != 0>
	@Override public int getFireSpreadSpeed(BlockState state, BlockGetter world, BlockPos pos, Direction face) {
		return ${data.fireSpreadSpeed};
	}
	</#if>

	<#if data.creativePickItem?? && !data.creativePickItem.isEmpty()>
	@Override public ItemStack getCloneItemStack(BlockState state, HitResult target, BlockGetter world, BlockPos pos, Player player) {
		return ${mappedMCItemToItemStackCode(data.creativePickItem, 1)};
	}
	<#elseif !data.hasBlockItem>
	@Override public ItemStack getCloneItemStack(BlockState state, HitResult target, BlockGetter world, BlockPos pos, Player player) {
		return ItemStack.EMPTY;
	}
	</#if>

	<#if (data.canBePlacedOn?size > 0) || hasProcedure(data.placingCondition)>
		<#if data.plantType != "growapable">
		@Override public boolean mayPlaceOn(BlockState groundState, BlockGetter worldIn, BlockPos pos) {
			<#if hasProcedure(data.placingCondition)>
			boolean additionalCondition = true;
			if (worldIn instanceof LevelAccessor world) {
				int x = pos.getX();
				int y = pos.getY() + 1;
				int z = pos.getZ();
				BlockState blockstate = world.getBlockState(pos.above());
				additionalCondition = <@procedureOBJToConditionCode data.placingCondition/>;
			}
			</#if>

			return
			<#if (data.canBePlacedOn?size > 0)>
				<@canPlaceOnList data.canBePlacedOn hasProcedure(data.placingCondition)/>
			</#if>
			<#if (data.canBePlacedOn?size > 0) && hasProcedure(data.placingCondition)> && </#if>
			<#if hasProcedure(data.placingCondition)> additionalCondition </#if>;
		}
		</#if>

		@Override public boolean canSurvive(BlockState blockstate, LevelReader worldIn, BlockPos pos) {
			BlockPos blockpos = pos.below();
			BlockState groundState = worldIn.getBlockState(blockpos);

			<#if data.plantType == "normal" || data.plantType == "sapling">
				return this.mayPlaceOn(groundState, worldIn, blockpos)
			<#elseif data.plantType == "growapable">
				<#if hasProcedure(data.placingCondition)>
				boolean additionalCondition = true;
				if (worldIn instanceof LevelAccessor world) {
					int x = pos.getX();
					int y = pos.getY();
					int z = pos.getZ();
					additionalCondition = <@procedureOBJToConditionCode data.placingCondition/>;
				}
				</#if>

				return groundState.is(this) ||
				<#if (data.canBePlacedOn?size > 0)>
					<@canPlaceOnList data.canBePlacedOn hasProcedure(data.placingCondition)/>
				</#if>
				<#if (data.canBePlacedOn?size > 0) && hasProcedure(data.placingCondition)> && </#if>
				<#if hasProcedure(data.placingCondition)> additionalCondition </#if>
			<#else>
				if (blockstate.getValue(HALF) == DoubleBlockHalf.UPPER)
					return groundState.is(this) && groundState.getValue(HALF) == DoubleBlockHalf.LOWER;
				else
					return this.mayPlaceOn(groundState, worldIn, blockpos)
			</#if>;
		}
	</#if>

	<#if !(data.growapableSpawnType == "Plains" && (data.plantType == "normal" || data.plantType == "sapling"))>
	@Override public PlantType getPlantType(BlockGetter world, BlockPos pos) {
		return PlantType.${generator.map(data.growapableSpawnType, "planttypes")};
	}
	</#if>

	<@onBlockAdded data.onBlockAdded, false, 0/>

	<#if data.plantType == "growapable" || hasProcedure(data.onTickUpdate)>
	@Override public void randomTick(BlockState blockstate, ServerLevel world, BlockPos pos, RandomSource random) {
		<#if data.plantType == "growapable">
		<#if data.isWaterloggable()>
		boolean flag = world.getBlockState(pos.above()).is(Blocks.WATER);
		</#if>
		if (world.isEmptyBlock(pos.above()) <#if data.isWaterloggable()>|| flag</#if>) {
			int i = 1;
			for(;world.getBlockState(pos.below(i)).is(this); ++i);
			if (i < ${data.growapableMaxHeight}) {
				int j = blockstate.getValue(AGE);
				if (ForgeHooks.onCropsGrowPre(world, pos, blockstate, true)) {
					if (j == 15) {
						world.setBlockAndUpdate(pos.above(), defaultBlockState()<#if data.isWaterloggable()>.setValue(WATERLOGGED, flag)</#if>);
						world.setBlock(pos, blockstate.setValue(AGE, 0), 4);
					} else {
						world.setBlock(pos, blockstate.setValue(AGE, j + 1), 4);
					}
				}
			}
		}
		<#elseif data.plantType == "sapling">
		super.randomTick(blockstate, world, pos, random);
		</#if>

		<#if hasProcedure(data.onTickUpdate)>
			<@procedureCode data.onTickUpdate, {
			"x": "pos.getX()",
			"y": "pos.getY()",
			"z": "pos.getZ()",
			"world": "world",
			"blockstate": "blockstate"
			}/>
		</#if>
	}
	</#if>

	<@onAnimateTick data.onRandomUpdateEvent/>

	<@onRedstoneOrNeighborChanged "", "", data.onNeighbourBlockChanges/>

	<@onEntityCollides data.onEntityCollides/>

	<@onDestroyedByPlayer data.onDestroyedByPlayer/>

	<@onDestroyedByExplosion data.onDestroyedByExplosion/>

	<@onStartToDestroy data.onStartToDestroy/>

	<@onBlockPlacedBy data.onBlockPlacedBy/>

	<@onBlockRightClicked data.onRightClicked/>

	<@onEntityWalksOn data.onEntityWalksOn/>

	<@onHitByProjectile data.onHitByProjectile/>

	<#if data.isBonemealable && data.plantType != "sapling">
	<@bonemealEvents data.isBonemealTargetCondition, data.bonemealSuccessCondition, data.onBonemealSuccess/>
	</#if>

	<#if data.hasTileEntity>
	@Override public BlockEntity newBlockEntity(BlockPos pos, BlockState state) {
		return new ${name}BlockEntity(pos, state);
	}

	@Override public boolean triggerEvent(BlockState state, Level world, BlockPos pos, int eventID, int eventParam) {
		super.triggerEvent(state, world, pos, eventID, eventParam);
		BlockEntity blockEntity = world.getBlockEntity(pos);
		return blockEntity == null ? false : blockEntity.triggerEvent(eventID, eventParam);
	}
	</#if>

	<#if data.tintType != "No tint">
		@OnlyIn(Dist.CLIENT) public static void blockColorLoad(RegisterColorHandlersEvent.Block event) {
			event.getBlockColors().register((bs, world, pos, index) -> {
				<#if data.tintType == "Default foliage">
					return FoliageColor.getDefaultColor();
				<#elseif data.tintType == "Birch foliage">
					return FoliageColor.getBirchColor();
				<#elseif data.tintType == "Spruce foliage">
					return FoliageColor.getEvergreenColor();
				<#else>
					return world != null && pos != null ?
					<#if data.tintType == "Grass">
						BiomeColors.getAverageGrassColor(world, pos) : GrassColor.get(0.5D, 1.0D);
					<#elseif data.tintType == "Foliage">
						BiomeColors.getAverageFoliageColor(world, pos) : FoliageColor.getDefaultColor();
					<#elseif data.tintType == "Water">
						BiomeColors.getAverageWaterColor(world, pos) : -1;
					<#elseif data.tintType == "Sky">
						Minecraft.getInstance().level.getBiome(pos).value().getSkyColor() : 8562943;
					<#elseif data.tintType == "Fog">
						Minecraft.getInstance().level.getBiome(pos).value().getFogColor() : 12638463;
					<#else>
						Minecraft.getInstance().level.getBiome(pos).value().getWaterFogColor() : 329011;
					</#if>
				</#if>
			}, ${JavaModName}Blocks.${REGISTRYNAME}.get());
		}

		<#if data.isItemTinted && data.hasBlockItem>
		@OnlyIn(Dist.CLIENT) public static void itemColorLoad(RegisterColorHandlersEvent.Item event) {
			event.getItemColors().register((stack, index) -> {
				<#if data.tintType == "Grass">
					return GrassColor.get(0.5D, 1.0D);
				<#elseif data.tintType == "Foliage" || data.tintType == "Default foliage">
					return FoliageColor.getDefaultColor();
				<#elseif data.tintType == "Birch foliage">
					return FoliageColor.getBirchColor();
				<#elseif data.tintType == "Spruce foliage">
					return FoliageColor.getEvergreenColor();
				<#elseif data.tintType == "Water">
					return 3694022;
				<#elseif data.tintType == "Sky">
					return 8562943;
				<#elseif data.tintType == "Fog">
					return 12638463;
				<#else>
					return 329011;
				</#if>
			}, ${JavaModName}Blocks.${REGISTRYNAME}.get());
		}
		</#if>
	</#if>
}
</#compress>
<#-- @formatter:on -->

<#function getPlantClass plantType>
	<#if plantType == "normal"><#return "Flower">
	<#elseif plantType == "growapable"><#return "SugarCane">
	<#elseif plantType == "double"><#return "DoublePlant">
	<#elseif plantType == "sapling"><#return "Sapling">
	</#if>
</#function>

<#macro canPlaceOnList blockList condition>
	<#if (blockList?size > 1) && condition>(</#if>
	<#list blockList as canBePlacedOn>
	<#if canBePlacedOn.getUnmappedValue().startsWith("TAG:")>
	groundState.is(BlockTags.create(ResourceLocation.parse("${canBePlacedOn.getUnmappedValue().replace("TAG:", "").replace("mod:", modid + ":")}")))
	<#elseif canBePlacedOn.getMappedValue(1).startsWith("#")>
	groundState.is(BlockTags.create(ResourceLocation.parse("${canBePlacedOn.getMappedValue(1)?remove_beginning("#")}")))
	<#else>
	groundState.is(${mappedBlockToBlock(canBePlacedOn)})
	</#if><#sep>||
	</#list><#if (blockList?size > 1) && condition>)</#if>
</#macro>

<#macro initStateProperties>
this.registerDefaultState(this.stateDefinition.any()
	<#if data.plantType == "double">
	.setValue(HALF, DoubleBlockHalf.LOWER)
	<#elseif data.plantType == "growapable">
	.setValue(AGE, 0)
	<#elseif data.plantType == "sapling">
	.setValue(STAGE, 0)
	</#if>
	<#if data.isWaterloggable()>
	.setValue(WATERLOGGED, false)
	</#if>
);
</#macro>