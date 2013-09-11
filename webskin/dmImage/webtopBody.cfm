<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Images Webtop Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">

<ft:objectadmin
	typename="dmImage"
    title="Image Library"
	columnList="ThumbnailImage,title,alt,datetimelastUpdated,catImage" 
	sortableColumns="title,datetimelastUpdated"
	lFilterFields="title,alt,catImage"
	sqlorderby="datetimelastUpdated desc" />

<cfsetting enablecfoutputonly="false">