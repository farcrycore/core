<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit Profile --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--- if no userdirectory assign local farcry directory as default --->
<cfif not len(stObj.userdirectory)>
	<cfset stObj.userdirectory = "CLIENTUD" />
</cfif>

<!--- look for a user directory specific edit handler --->
<cfif application.fapi.hasWebskin(typename="dmProfile",webskin="edit#stObj.userdirectory#User")>
	<skin:view stObject="#stObj#" webskin="edit#stObj.userdirectory#User" onExitProcess="#onExitProcess#" />

<!--- default to a generic edit handler with restricted options --->
<cfelse>
	<skin:view stObject="#stObj#" webskin="editGenericUser" onExitProcess="#onExitProcess#" />
</cfif>

<cfsetting enablecfoutputonly="false" />