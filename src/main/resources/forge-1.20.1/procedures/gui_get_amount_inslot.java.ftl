/*@int*/(new Object(){
	public int getAmount(int sltid) {
		if(entity instanceof Player player && player.containerMenu instanceof ${JavaModName}Menus.MenuAccessor _menu) {
			ItemStack stack = _menu.getSlots().get(sltid).getItem();
			if(stack != null)
				return stack.getCount();
		}
		return 0;
	}
}.getAmount(${opt.toInt(input$slotid)}))