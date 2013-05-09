<cfsetting enablecfoutputonly="true" />
<!--- @@viewStack: data --->
<!--- @@mimeType: json --->
<!--- @@fuAlias: remove-favourite --->

<cfimport taglib="/farcry/core/tags/misc" prefix="misc" />

<cfset aErrors = arraynew(1) />
<cfif not structkeyexists(url,"favURL")>
	<cfset arrayappend(aErrors,"Missing parameter [favURL]") />
</cfif>

<cfif arraylen(aErrors)>
	<cfoutput>{ "error" : #serializeJSON(aErrors)# }</cfoutput>
<cfelse>
	<cfset aFavourites = application.fapi.getPersonalConfig("favourites",arraynew(1)) />
	
	<cfset position = 0 />
	<cfloop from="1" to="#arraylen(aFavourites)#" index="i">
		<cfif aFavourites[i].url eq url.favURL>
			<cfset position = i />
			<cfset arraydeleteat(aFavourites,i) />
			<cfbreak>
		</cfif>
	</cfloop>
	
	<cfset application.fapi.setPersonalConfig("favourites",aFavourites) />
	
	<cfoutput>{ "success":true, "position":#i# }</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />