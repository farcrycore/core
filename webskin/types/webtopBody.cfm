<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Default Webtop Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">

<ft:objectAdmin
	typename="#stObj.name#"
	columnList="label,datetimecreated,datetimelastupdated"
	sortableColumns="label,datetimecreated,datetimelastupdated"
	lFilterFields="label"
	sqlOrderBy="datetimelastupdated DESC" />


<cfsetting enablecfoutputonly="false">