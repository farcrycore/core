<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Standard Mobile Body --->
<!--- @@author: Justin Carter (justin@daemon.com.au)--->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<cfoutput>
<h1>#encodeForHTML(stObj.label)#</h1>
<cfif structKeyExists(stObj, "body")>
	#stObj.body#
</cfif>
</cfoutput>

<cfsetting enablecfoutputonly="false">