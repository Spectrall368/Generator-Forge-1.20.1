<#include "procedures.java.ftl">
@Mod.EventBusSubscriber public class ${name}Procedure {
	@SubscribeEvent public static void onPickup(EntityItemPickupEvent event) {
		<#assign dependenciesCode>
			<@procedureDependenciesCode dependencies, {
			"x": "event.getEntity().getX()",
			"y": "event.getEntity().getY()",
			"z": "event.getEntity().getZ()",
			"world": "event.getEntity().level()",
			"entity": "event.getEntity()",
			"itemstack": "event.getItem().getItem()",
			"event": "event"
			}/>
		</#assign>
		execute(event<#if dependenciesCode?has_content>,</#if>${dependenciesCode});
	}