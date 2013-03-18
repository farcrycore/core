<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Display WDDX object --->

<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />

<cfwddx action="wddx2cfml" input="#stObj.objectWDDX#" output="stArchive" />
<cfwddx action="wddx2cfml" input="#stObj.metaWDDX#" output="stMeta" />

<cfif isdefined("stMeta.tree.parent")>
	<cfset request.navid = stMeta.tree.parent />
</cfif>

<!--- Temporarily put the object into session --->
<cfset application.fapi.setData(stProperties=stArchive,bSessionOnly=true) />
<cfset request.stObj = stArchive />

<!--- Display as per usual ala dmNaviation displayPageStandard --->
<nj:display objectid="#stArchive.objectid#" typename="#stArchive.typename#" />

<!--- Remove temporary object from session --->
<cfif structkeyexists(Session.TempObjectStore,stArchive.objectid)>
	<cfset structdelete(Session.TempObjectStore,stArchive.ObjectID) />
</cfif>

<cfsetting enablecfoutputonly="false" />