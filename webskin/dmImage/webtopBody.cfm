<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Images Webtop Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">

<ft:objectAdmin
	typename="#stObj.name#"
	columnList="label,thumbnailImage,status,datetimecreated,datetimelastupdated"
	sortableColumns="label,status,datetimecreated,datetimelastupdated"
	lFilterFields="label"
	sqlOrderBy="datetimelastupdated DESC" />


<cfsetting enablecfoutputonly="false">