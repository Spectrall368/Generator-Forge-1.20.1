private static int insertInBlockInventory(LevelAccessor world, BlockPos pos, int slotId, int amount, ItemStack itemstack, boolean simulate) {
    AtomicReference<Integer> result = new AtomicReference<>(itemstack.getCount());
    BlockEntity entity = world.getBlockEntity(pos);
    if (entity != null && slotId >= 0)
		entity.getCapability(ForgeCapabilities.ITEM_HANDLER, null)
		    .ifPresent(capability -> {
		        if (slotId < capability.getSlots()) {
                    ItemStack inserted = itemstack.copy();
                    inserted.setCount(amount);
                    result.set(capability.insertItem(slotId, inserted, simulate).getCount());
                }
            });

	return result.get();
}