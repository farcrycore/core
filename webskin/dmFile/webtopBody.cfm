<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Files Webtop Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">

<ft:objectAdmin
	typename="dmFile"
	columnList="title,status,datetimecreated,datetimelastupdated,documentDate"
	sortableColumns="title,status,datetimecreated,datetimelastupdated,documentDate"
	lFilterFields="title,catFile"
	bPreviewCol="false"
	sqlOrderBy="datetimelastupdated DESC" />


<cfsetting enablecfoutputonly="false">