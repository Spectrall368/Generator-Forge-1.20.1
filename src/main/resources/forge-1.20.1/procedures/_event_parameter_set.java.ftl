<#assign floatParameters = ["FALL_DISTANCE", "FALL_DAMAGE_MULTIPLIER", "CRITICAL_DAMAGE_MULTIPLIER", "INCOMING_DAMAGE_AMOUNT_1201"]>
<#assign intParameters = ["DROPPED_EXPERIENCE"]>
if (event instanceof ${eventClass} _event) {
	<#if floatParameters?seq_contains(fieldParameterName)>
		_event.${method}(${opt.toFloat(inputValue)});
    <#elseif intParameters?seq_contains(fieldParameterName)>
		_event.${method}(${opt.toInt(inputValue)});
    <#else>
		_event.${method}(${inputValue});
    </#if>
}
