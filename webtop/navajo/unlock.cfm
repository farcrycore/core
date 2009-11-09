<cfprocessingDirective pageencoding="utf-8">

<!--- unlock object --->
<cfinvoke component="#application.packagepath#.farcry.locking" method="unlock" returnvariable="unlockRet">
	<cfinvokeargument name="objectId" value="#url.objectid#"/>
	<cfinvokeargument name="typename" value="#url.typename#"/>
</cfinvoke>


<cfparam name="url.ref" default="overview" />

<cfif unlockRet.bsuccess>
	<cfif isdefined("url.return")>
		<cflocation url="#application.url.farcry#/index.cfm?section=home" addtoken="no">
	<cfelse>
		<!--- return to overview page --->
		<cflocation url="#application.url.farcry#/edittabOverview.cfm?objectid=#url.objectid#&ref=#url.ref#" addtoken="no">
	</cfif>
<cfelse>
	<!--- display error message --->
	<cfdump var="#unlockRet#">
</cfif>
