<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:loadJS id="formatjson" />
<skin:loadCSS id="formatjson" />

<cfwddx action="wddx2cfml" input="#stObj.wddxDetails#" output="stDetails" />

<cfoutput>
	#stObj.action# <a href="##" class="pull-right" onclick="$j(this).siblings('.details').toggle();return false;">more</a>
	<div class='details' style='display:none;'><pre class="formatjson">#application.fapi.formatJSON(serializeJSON(stDetails))#</pre></div>
</cfoutput>

<cfsetting enablecfoutputonly="false">