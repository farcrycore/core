<cfsetting enablecfoutputonly="true">

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<cfset stFilterMetaData = structnew() />

<!--- free-text userid: a dropdown needs "select distinct userid" over the whole farLog table on every page load --->
<cfset stFilterMetaData.userid.ftType = "string" />
<cfset stFilterMetaData.userid.ftFilterMatch = "exact" />

<cfset stFilterMetaData.event.ftType = "list" />
<cfset stFilterMetaData.event.ftListData = "getEventList_Security" />
<cfset stFilterMetaData.event.ftListDataTypeName = "farLog" />
<cfset stFilterMetaData.event.ftRenderType = "dropdown" />
<cfset stFilterMetaData.event.ftselectmultiple = "false" />
<!--- exact, so "login" doesn't also match "loginfailed" --->
<cfset stFilterMetaData.event.ftFilterMatch = "exact" />

<cfset stFilterMetaData.datetimecreatedby.default = "" />


<ft:objectadmin 
	typename="farLog"
	title="Security log"
	columnList="userid,event,notes,datetimecreated" 
	sortableColumns="userid,event,notes,datetimecreated"
	lFilterFields="userid,event,notes"
	stFilterMetaData="#stFilterMetaData#"
	bPreviewCol="false"
	sqlorderby="datetimecreated desc"
	sqlwhere="type='security'" />


<cfsetting enablecfoutputonly="false">