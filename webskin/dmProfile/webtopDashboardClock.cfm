<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Dashboard Clock --->
<!--- @@viewstack: fragment --->
<!--- @@viewbinding: type --->
<!--- @@cardClass: fc-dashboard-card-small --->
<!--- @@cardHeight: 200px --->

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">

<cfoutput>

<div style="padding: 0 6px; color: ##999;">
	#dateFormat(now(), "dddd")#
</div>
<div style="margin-top: 30px; font-size: 56px; line-height: 1; padding: 4px;">
	#timeFormat(now(), "h:mm")#<small style="font-size: 40%;"> #timeFormat(now(), "tt")#</small>
</div>
<div style="padding: 0 6px; color: ##999;">
	#dateFormat(now(), "d mmmm yyyy")#
</div>

</cfoutput>


<cfsetting enablecfoutputonly="false" />