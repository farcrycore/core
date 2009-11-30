<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit rule and update page on close --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<admin:header />
<cfoutput>
	#update(objectid=stObj.objectid)#
</cfoutput>

<admin:footer />

<cfsetting enablecfoutputonly="false" />