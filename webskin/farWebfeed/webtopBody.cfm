<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Manage web feeds --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfset aCustomColumns = arraynew(1) />
<cfset aCustomColumns[1] = structnew() />
<cfset aCustomColumns[1].title = "Generate XML Files"/>
<cfset aCustomColumns[1].webskin = "displayScheduledTask" />

<ft:objectadmin 
	typename="farWebfeed" 
	columnList="title,itemtype" 
	title="Manage Web Feeds" 
	aCustomColumns="#aCustomColumns#" />

<cfsetting enablecfoutputonly="false">