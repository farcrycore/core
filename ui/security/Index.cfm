<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/farcry_core/tags/security/ui" prefix="dmsec">

<cfoutput>
<script>
	if(window.location.href.indexOf("index.cfm")==-1) window.location.href="index.cfm";
</script>
</cfoutput>

<dmsec:dmSecUI_Index>

<cfsetting enablecfoutputonly="No">