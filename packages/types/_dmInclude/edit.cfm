<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmInclude/edit.cfm,v 1.19.2.1 2006/04/04 05:53:16 gstewart Exp $
$Author: gstewart $
$Date: 2006/04/04 05:53:16 $
$Name: milestone_3-0-1 $
$Revision: 1.19.2.1 $

|| DESCRIPTION || 
$Description: dmInclude edit handler$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/tags/widgets" prefix="widgets">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >

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


<ft:processForm action="Save">
	<ft:processFormObjects objectid="#stobj.objectid#" />
	
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
	
		
</ft:processForm>


<cfoutput>
	<script type="text/javascript">
		function fCancelAction(){
			if(parent['sidebar'].frames['sideTree']){
				parent['sidebar'].frames['sideTree'].location= parent['sidebar'].frames['sideTree'].location;
				parent['content'].location.href = "#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#";
			}
		}
	</script>
</cfoutput>

<ft:form>

	<ft:object stobject="#stObj#" lfields="title,Teaser,include,displayMethod,catInclude" />
	
	<ft:farcryButton value="Save" />
	<ft:farcryButton value="cancel" onClick="fCancelAction();return false;" />
	
</ft:form>
	

<cfsetting enablecfoutputonly="no">