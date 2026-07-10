<cfsetting enablecfoutputonly="true">
<!--- @@displayname: MFA user cell --->
<!--- @@description: objectadmin custom-column cell: the enrolled user's name, linking to the per-user reset. Prefers the stored userLabel; falls back to a live lookup for CLIENTUD rows created before userLabel existed. --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset displayName = "" />
<cfset stMFAUser = structnew() />

<cfif structKeyExists(stObj, "userLabel") and len(stObj.userLabel)>
	<cfset displayName = stObj.userLabel />
<cfelseif structKeyExists(stObj, "userDirectory") and stObj.userDirectory eq "CLIENTUD">
	<cfset stMFAUser = application.fapi.getContentType("farUser").getData(objectid=stObj.userKey) />
	<cfif not structIsEmpty(stMFAUser) and structKeyExists(stMFAUser, "userid")>
		<cfset displayName = stMFAUser.userid />
	</cfif>
</cfif>

<cfif not len(displayName)>
	<cfset displayName = stObj.userKey />
</cfif>

<cfoutput>
	<cfif structKeyExists(stObj, "userDirectory") and stObj.userDirectory eq "CLIENTUD">
		<a href="##" class="mfa-reset-link" data-userkey="#encodeForHTMLAttribute(stObj.userKey)#">#encodeForHTML(displayName)#</a>
	<cfelse>
		#encodeForHTML(displayName)#
	</cfif>
</cfoutput>

<cfsetting enablecfoutputonly="false">
