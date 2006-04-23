<cfsetting enablecfoutputonly="true">
<!--- default properties --->

<cfset oType = createobject("component", application.types[librarytype].typePath)>
<!--- allow the upload to hanlde plp steps --->
<cfset stProps=structNew()>
<cfif isDefined("plpObjectID") AND plpObjectID NEQ "">
	<!--- grab data from db --->
	<cfset stProps.objectid = plpObjectID>
<cfelse>
	<cfset stProps.objectid = createUUID()>
</cfif>
<cfset stProps.label = "(incomplete)">
<cfset stProps.title = "">
<cfset stProps.lastupdatedby = session.dmSec.authentication.userlogin>
<cfset stProps.datetimelastupdated = Now()>
<cfset stProps.createdby = session.dmSec.authentication.userlogin>
<cfset stProps.datetimecreated = Now()>
<cfset stProps.documentDate = Now()>
<!--- dmHTML specific props --->
<cfset stProps.displayMethod = "display">
<cfset stProps.status = "draft">
<!--- dmNews specific props --->
<cfset stProps.publishDate = now()>
<cfset stProps.expiryDate = now()>
<cfset oType.createData(stProperties=stProps)>
<cfset stObj = oType.getData(stProps.objectid)>
<cfparam name="bPLPStorage" default="no">

<cfscript>
// TODO THIS IS SO DODGE! quick and dirty fix, 
// to delete records if the for is not submitted but still have the default values stored in the stobj 
// for use on the form
if(NOT isDefined("form.submit") AND bPLPStorage EQ "yes")
	oType.deleteData(stProps.objectid);
</cfscript>

<cfif librarytype EQ "dmFile">
	<cfset displayLibraryType = "File">
<cfelse>
	<cfset displayLibraryType = "Image">
</cfif>
<cfsetting enablecfoutputonly="false">
<cfoutput>

<body class="popup #displayLibraryType#browse">
<h1>Browse for #displayLibraryType#s...</h1>
<div class="tab-container">
	<ul class="tabs">
	<li id="tab1" class="tab-disabled"><a href="library.cfm?#queryString#">#displayLibraryType# Library</a></li>
	<li id="tab2"><a href="##">My Computer</a></li>
	</ul>
	<div class="tab-panes">
		<div id="utility">
		<h2>Tips</h2>
		<!--- <p> --->
		<cfinclude template="/farcry/farcry_core/admin/includes/#displayLibraryType#_tips.cfm">
		<!--- </p> --->		
		</div>		
		<div id="content">
		<cfset oType.edit(stProps.objectid)>
		</div>
	</div>
</div>
</body>
</html>
</cfoutput>