<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/security" prefix="sec">

<sec:CheckPermission error="true" permission="ObjectDumpTab">
	<cfdump var="#stObj#" label="#stobj.label#">
</sec:CheckPermission>

<cfsetting enablecfoutputonly="false">