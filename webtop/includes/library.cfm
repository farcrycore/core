<cfparam name="librarySection" default="list">
<cfparam name="libraryType" default="">
<cfparam name="primaryObjectID" default="">
<cfparam name="pg" default="1">
<cfset currentpage = pg>
<cfparam name="currentpage" default="#pg#">
<cfparam name="lLibrarySelection" default="">
<cfparam name="bFormSubmission" default="false">
<cfparam name="delaObjectID" default="">
<cfparam name="reposition" default="">
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin"> 
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry"> 
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfinclude template="/farcry/core/admin/includes/libraryFunctions.cfm">

<cfset queryString = "libraryType=#libraryType#&primaryObjectID=#primaryObjectID#">
<cfif libraryType NEQ "" AND primaryObjectID NEQ "">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>FarCry</title><cfoutput>
<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/main.css);</style>
<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/tabs.css);</style>
<!--- DataRequestor Object : used to retrieve xml data via javascript --->
<script src="#application.url.farcry#/includes/lib/DataRequestor.js"></script>
<!--- JSON javascript object --->
<script src="#application.url.farcry#/includes/lib/json.js"></script>

<!--// load the qForm JavaScript API //-->
	<script type="text/javascript" src="#application.url.farcry#/includes/lib/qforms.js"></script>

	<!--// you do not need the code below if you plan on just
		   using the core qForm API methods. //-->
	<!--// [start] initialize all default extension libraries  //-->
	<script type="text/javascript">
	<!--//
	// specify the path where the "/qforms/" subfolder is located
	qFormAPI.setLibraryPath("#application.url.farcry#/includes/lib/");
	// loads all default libraries
	qFormAPI.include("*");
	//-->
	</script>

</cfoutput>
</head>
<!--- show the library list --->
<cfif librarySection EQ "list">
	<cfinclude template="librarylist.cfm">
<cfelse> <!--- show the library uploads --->
	<cfinclude template="libraryupload.cfm">
</cfif>
</html>
<!--- 
<!--- set up page header ---> 
<admin:header>
<script language="javascript">
function reloadOpener(){
	opener.window.location.reload();	
}
</script>
		<cfoutput>
<a href="library.cfm?librarySection=list&#queryString#">list</a>&nbsp;
<a href="library.cfm?librarySection=upload&#queryString#">my computer</a>
		</cfoutput>
		<!--- show the library list --->
		<cfif librarySection EQ "list">
			<cfinclude template="inc_librarylist.cfm">
		<cfelse> <!--- show the library uploads --->
			<cfinclude template="inc_libraryupload.cfm">
		</cfif>
<!--- setup footer ---> 
<admin:footer> 
 --->
</cfif>