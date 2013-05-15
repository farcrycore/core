<cfsetting enablecfoutputonly="true" />
<!--- @@viewStack: data --->
<!--- @@mimeType: json --->
<!--- @@fuAlias: add-favourite --->

<cfimport taglib="/farcry/core/tags/misc" prefix="misc" />

<cfset aErrors = arraynew(1) />
<cfif not structkeyexists(url,"favURL")>
	<cfset arrayappend(aErrors,"Missing parameter [favURL]") />
</cfif>
<cfif not structkeyexists(url,"favLabel")>
	<cfset arrayappend(aErrors,"Missing parameter [favLabel]") />
</cfif>

<cfif arraylen(aErrors)>
	<cfoutput>{ "error" : #serializeJSON(aErrors)# }</cfoutput>
<cfelse>
	<cfset aFavourites = application.fapi.getPersonalConfig("favourites",arraynew(1)) />
	
	<!--- check to see if the page is already favourited --->
	<cfset found = false />
	<cfloop array="#aFavourites#" index="thisfavourite">
		<cfif thisfavourite.url eq url.favURL>
			<cfset found = true />
		</cfif>
	</cfloop>
	
	<cfif found>
		<cfoutput>{ "error":["Page is already favourited"] }</cfoutput>
	<cfelse>
		<cfset stFav = structNew()>
		<cfset stFav["url"] = url.favURL>
		<cfset stFav["label"] = favLabel>
		<cfset arrayappend(aFavourites, stFav) />
		<misc:sort values="#aFavourites#">
			<cfif value1.label lt value2.label>
				<cfset sendback = -1 />
			<cfelseif value1.label eq value2.label>
				<cfset sendback = 0 />
			<cfelse>
				<cfset sendback = 1 />
			</cfif>
		</misc:sort>
		
		<cfset application.fapi.setPersonalConfig("favourites",result) />
		
		<cfset position = 0 />
		<cfloop from="1" to="#arraylen(aFavourites)#" index="i">
			<cfif aFavourites[i].url eq url.favURL>
				<cfset position = i />
			</cfif>
		</cfloop>
		
		<cfoutput>{ "success":true, "position":#position# }</cfoutput>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />