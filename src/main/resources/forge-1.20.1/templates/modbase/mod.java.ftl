<#-- @formatter:off -->
package ${package};

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@Mod("${modid}") public class ${JavaModName} {

	public static final Logger LOGGER = LogManager.getLogger(${JavaModName}.class);

	public static final String MODID = "${modid}";

	public ${JavaModName}(FMLJavaModLoadingContext context) {
		// Start of user code block mod constructor
		// End of user code block mod constructor

		MinecraftForge.EVENT_BUS.register(this);

		IEventBus bus = context.getModEventBus();
		<@javacompress>
		<#if w.hasSounds()>${JavaModName}Sounds.REGISTRY.register(bus);</#if>
		<#if types["base:blocks"]??>${JavaModName}Blocks.REGISTRY.register(bus);</#if>
		<#if types["base:blockentities"]??>${JavaModName}BlockEntities.REGISTRY.register(bus);</#if>
		<#if types["base:items"]??>${JavaModName}Items.REGISTRY.register(bus);</#if>
		<#if types["base:entities"]??>${JavaModName}Entities.REGISTRY.register(bus);</#if>
		<#if w.hasItemsInTabs()>${JavaModName}Tabs.REGISTRY.register(bus);</#if>
		<#if types["base:features"]??>${JavaModName}Features.REGISTRY.register(bus);</#if>
		<#if w.getElementsOfType("feature")?filter(e -> e.getMetadata("has_nbt_structure")??)?size != 0>StructureFeature.REGISTRY.register(bus);</#if>
		<#if types["paintings"]??>${JavaModName}Paintings.REGISTRY.register(bus);</#if>
		<#if types["potions"]??>${JavaModName}Potions.REGISTRY.register(bus);</#if>
		<#if types["potioneffects"]??>${JavaModName}MobEffects.REGISTRY.register(bus);</#if>
		<#if types["enchantments"]??>${JavaModName}Enchantments.REGISTRY.register(bus);</#if>
		<#if types["guis"]??>${JavaModName}Menus.REGISTRY.register(bus);</#if>
		<#if types["particles"]??>${JavaModName}ParticleTypes.REGISTRY.register(bus);</#if>
		<#if types["villagerprofessions"]??>${JavaModName}VillagerProfessions.PROFESSIONS.register(bus);</#if>
		<#if types["fluids"]??>
			${JavaModName}Fluids.REGISTRY.register(bus);
			${JavaModName}FluidTypes.REGISTRY.register(bus);
		</#if>
		<#if types["attributes"]??>${JavaModName}Attributes.REGISTRY.register(bus);</#if>
		<#if w.hasElementsOfType("bannerpattern")>${JavaModName}BannerPatterns.REGISTRY.register(bus);</#if>
		</@javacompress>

		// Start of user code block mod init
		// End of user code block mod init
	}

	// Start of user code block mod methods
	// End of user code block mod methods

	private static final String PROTOCOL_VERSION = "1";
	public static final SimpleChannel PACKET_HANDLER = NetworkRegistry.newSimpleChannel(
			new ResourceLocation(MODID, MODID),
			() -> PROTOCOL_VERSION,
			PROTOCOL_VERSION::equals,
			<#if settings.isServerSideOnly()>clientVersion -> true<#else>PROTOCOL_VERSION::equals</#if>
	);

	private static int messageID = 0;

	public static <T> void addNetworkMessage(Class<T> messageType, BiConsumer<T, FriendlyByteBuf> encoder, Function<FriendlyByteBuf, T> decoder,
										BiConsumer<T, Supplier<NetworkEvent.Context>> messageConsumer) {
		PACKET_HANDLER.registerMessage(messageID, messageType, encoder, decoder, messageConsumer);
		messageID++;
	}

	private static final Collection<AbstractMap.SimpleEntry<Runnable, Integer>> workQueue = new ConcurrentLinkedQueue<>();

	public static void queueServerWork(int tick, Runnable action) {
		if (Thread.currentThread().getThreadGroup() == SidedThreadGroups.SERVER)
			workQueue.add(new AbstractMap.SimpleEntry<>(action, tick));
	}

	@SubscribeEvent public void tick(TickEvent.ServerTickEvent event) {
		if (event.phase == TickEvent.Phase.END) {
			List<AbstractMap.SimpleEntry<Runnable, Integer>> actions = new ArrayList<>();
			workQueue.forEach(work -> {
				work.setValue(work.getValue() - 1);
				if (work.getValue() == 0)
					actions.add(work);
			});
			actions.forEach(e -> e.getKey().run());
			workQueue.removeAll(actions);
		}
	}

}
<#-- @formatter:on -->