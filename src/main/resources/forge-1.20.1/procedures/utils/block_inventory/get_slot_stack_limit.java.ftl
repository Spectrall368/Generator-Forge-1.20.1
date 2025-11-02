private static int getBlockInventorySlotStackLimit(LevelAccessor world, BlockPos pos, int slotId) {
    AtomicReference<Integer> result = new AtomicReference<>(0);
    BlockEntity entity = world.getBlockEntity(pos);
    if (entity != null && slotId >= 0)
		entity.getCapability(ForgeCapabilities.ITEM_HANDLER, null)
		    .ifPresent(capability -> { if(slotId < capability.getSlots()) result.set(capability.getSlotLimit(slotId));});

	return result.get();
}