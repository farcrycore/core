<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
<!--- @@displayname: Group Webtop Body --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<ft:objectadmin 
	typename="farGroup"
	title="Group Administration"
	columnList="title" 
	sortableColumns="title"
	lFilterFields="title"
    bPreviewCol="false"
	sqlorderby="title asc" />

<cfsetting enablecfoutputonly="false">