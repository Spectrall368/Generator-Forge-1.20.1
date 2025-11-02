private static int getBlockInventorySlotCount(LevelAccessor world, BlockPos pos) {
    AtomicReference<Integer> result = new AtomicReference<>(0);
    BlockEntity entity = world.getBlockEntity(pos);
    if (entity != null)
		entity.getCapability(ForgeCapabilities.ITEM_HANDLER, null)
		    .ifPresent(capability -> result.set(capability.getSlots()));

	return result.get();
}