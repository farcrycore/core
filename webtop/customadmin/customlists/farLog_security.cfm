<cfsetting enablecfoutputonly="true" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- set up page header --->
<admin:header title="Security log" />

<cfset stFilterMetaData = structnew() />

<cfset stFilterMetaData.userid.ftType = "list" />
<cfset stFilterMetaData.userid.ftListData = "getUserList" />

<cfset stFilterMetaData.event.ftType = "list" />
<cfset stFilterMetaData.event.ftListData = "getEventList_Security" />

<cfset stFilterMetaData.datetimecreatedby.default = "" />

<ft:objectadmin 
	typename="farLog"
	title="Security log"
	columnList="userid,event,notes,datetimecreated" 
	sortableColumns="userid,event,notes,datetimecreated"
	lFilterFields="userid,event,notes,datetimecreated"
	stFilterMetaData="#stFilterMetaData#"
	sqlorderby="datetimecreated desc"
	sqlwhere="type='security'"
	module="customlists/farLog_security.cfm" />

<admin:footer />

<cfsetting enablecfoutputonly="false" />