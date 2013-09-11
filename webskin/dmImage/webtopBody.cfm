<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Images Webtop Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">

<ft:objectAdmin
	typename="dmImage"
	columnList="title,thumbnailImage,status,datetimecreated,datetimelastupdated"
	sortableColumns="title,status,datetimecreated,datetimelastupdated"
	lFilterFields="title,catImage"
	sqlOrderBy="datetimelastupdated DESC" />


<cfsetting enablecfoutputonly="false">