<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit Profile --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<cfif not len(stObj.userdirectory)>
	<cfset stObj.userdirectory = "CLIENTUD" />
</cfif>

<cfif application.fapi.hasWebskin(typename="dmProfile",webskin="edit#stObj.userdirectory#User")>
	<skin:view stObject="#stObj#" webskin="edit#stObj.userdirectory#User" />
<cfelse>
	<skin:view stObject="#stObj#" webskin="editGenericUser" />
</cfif>

<cfsetting enablecfoutputonly="false" />