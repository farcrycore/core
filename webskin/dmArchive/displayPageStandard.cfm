<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Display WDDX object --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfwddx action="wddx2cfml" input="#stObj.objectWDDX#" output="stArchive" />

<cfif structkeyexists(stArchive,"displaymethod") and len(stArchive.displaymethod)>
	<skin:view stobject="#stArchive#" webskin="#stArchive.displaymethod#" />
<cfelse>
	<skin:view stobject="#stArchive#" webskin="displayPageStandard" />
</cfif>

<cfsetting enablecfoutputonly="false" />