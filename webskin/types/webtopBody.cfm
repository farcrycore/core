<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Default Webtop Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">

<ft:objectAdmin
	typename="#stObj.name#"
	columnList="label,status,datetimecreated,datetimelastupdated"
	sortableColumns="label,status,datetimecreated,datetimelastupdated"
	lFilterFields="label"
	sqlOrderBy="datetimelastupdated DESC" />


<cfsetting enablecfoutputonly="false">