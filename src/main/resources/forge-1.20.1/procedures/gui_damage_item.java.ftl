if(${input$entity} instanceof Player _player && _player.containerMenu instanceof ${JavaModName}Menus.MenuAccessor _menu) {
	Slot _slot = _menu.getSlots().get(${opt.toInt(input$slotid)});
	ItemStack stack = _slot.getItem();
	if (stack != null && !stack.isEmpty()) {
		if(stack.hurt(${opt.toInt(input$amount)}, RandomSource.create(), null)) {
			stack.shrink(1);
			stack.setDamageValue(0);
		}
		_slot.set(stack);
		_slot.setChanged();
		_player.containerMenu.broadcastChanges();
	}
}