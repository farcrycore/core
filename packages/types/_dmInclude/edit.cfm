<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmInclude/edit.cfm,v 1.19 2005/10/28 07:22:51 guy Exp $
$Author: guy $
$Date: 2005/10/28 07:22:51 $
$Name: milestone_3-0-0 $
$Revision: 1.19 $

|| DESCRIPTION || 
$Description: dmInclude edit handler$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">

<!--- determine where the edit handler has been called from to provide the right return url --->
<cfparam name="url.ref" default="sitetree" type="string">
<cfif url.ref eq "typeadmin"> 
	<!--- typeadmin redirect --->
	<cfset cancelCompleteURL = "#application.url.farcry#/content/dminclude.cfm">
<cfelse> 
	<!--- site tree redirect --->
	<cfset cancelCompleteURL = "#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#">
</cfif>

<!--- lock the content item for editing --->
<cfif NOT stobj.locked>
	<cfset setlock(locked="true")>
</cfif>

<cfif isDefined("FORM.submit")> <!--- perform the update --->
	<cfscript>
		stProperties = structNew();
		stProperties.objectid = stObj.objectid;
		stProperties.title = form.title;
		stProperties.label = form.title;
		stProperties.teaser = form.teaser;
		stProperties.include = form.include;
		stProperties.displayMethod = form.displayMethod;
		stProperties.datetimelastupdated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
		stProperties.typename = "dmInclude";
		//unlock object
		stProperties.locked = 0;
		stProperties.lockedBy = "";
		// update the OBJECT	
		setData(stProperties=stProperties);
	</cfscript>

	<!--- if not typeadmin edit then refresh JS tree data --->
	<cfif url.ref neq "typeadmin"> 
		<!--- get parent to update site js tree --->
		<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
		<!--- update site js tree --->
		<nj:updateTree objectId="#parentID#">
		<!--- relocate iframes for tree and edit areas using JS --->
		<cfoutput>
		<script type="text/javascript">
		if(parent['sidebar'].frames['sideTree'])
			parent['sidebar'].frames['sideTree'].location= parent['sidebar'].frames['sideTree'].location;
			parent['content'].location.href = "#cancelCompleteURL#"
		</script>
		</cfoutput>
		<cfabort>	

	<cfelse>
		<cflocation url="#cancelCompleteURL#" addtoken="no">
	</cfif>
		
<!--- Show the form --->
<cfelse> 
	<cfoutput>
	<script type="text/javascript">
		function fCancelAction(){
			if(parent['sidebar'].frames['sideTree']){
				parent['sidebar'].frames['sideTree'].location= parent['sidebar'].frames['sideTree'].location;
				parent['content'].location.href = "#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#";
			}
		}
	</script>
	<form name="editform" action="#cgi.script_name#?#cgi.query_string#" method="post" class="f-wrap-1 f-bg-long">
	
	<fieldset>
		<div class="req"><b>*</b>Required</div>
		<!--- TO DO: Change this heading to pick up from resource bundle --->
		<h3>#application.adminBundle[session.dmProfile.locale].generalInfo#: <span class="highlight">#stObj.title#</span></h3>
	
		<label for="title"><b>#application.adminBundle[session.dmProfile.locale].titleLabel#<span class="req">*</span></b>
			<input type="text" name="title" id="title" value="#stObj.title#" /><br />
		</label>
		</cfoutput>
		<cfinvoke component="#application.types.dmInclude.typePath#" method="getIncludes" returnvariable="qGetIncludes"/>
		<cfoutput>

		<label for="include"><b>#application.adminBundle[session.dmProfile.locale].includeLabel#</b>
			<cfif qGetIncludes.recordCount>
			<select name="include" id="include"><cfloop query="qGetIncludes">
				<option value="#qGetIncludes.include#"<cfif qGetIncludes.include EQ stObj.include> selected="selected"</cfif>>#qGetIncludes.include#</option></cfloop>			
			</select><cfelse>
			#application.adminBundle[session.dmProfile.locale].noIncludeFiles#</cfif><br />
		</label>
		</cfoutput>
		<widgets:displayMethodSelector typeName="dmInclude">
		<cfoutput>
		<label for="teaser"><b>#application.adminBundle[session.dmProfile.locale].teaserLabel#</b>
			<textarea name="teaser" id="teaser">#stObj.teaser#</textarea><br />
		</label>
	
		<div class="f-submit-wrap">
		<input type="Submit" name="Submit" value="#application.adminBundle[session.dmProfile.locale].OK#" class="f-submit">
		<input type="Button" name="Cancel" value="#application.adminBundle[session.dmProfile.locale].cancel#" class="f-submit" onClick="fCancelAction();">
		</div>
	</form>
<cfinclude template="/farcry/farcry_core/admin/includes/QFormValidationJS.cfm">
	</cfoutput>
</cfif>	

<cfsetting enablecfoutputonly="no">