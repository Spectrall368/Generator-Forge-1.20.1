<#include "procedures.java.ftl">
@Mod.EventBusSubscriber public class ${name}Procedure {
	@SubscribeEvent public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
		if (event.phase == TickEvent.Phase.END) {
			<#assign dependenciesCode>
			<@procedureDependenciesCode dependencies, {
				"x": "event.player.getX()",
				"y": "event.player.getY()",
				"z": "event.player.getZ()",
				"world": "event.player.level()",
				"entity": "event.player",
				"event": "event"
				}/>
			</#assign>
			execute(event<#if dependenciesCode?has_content>,</#if>${dependenciesCode});
		}
	}