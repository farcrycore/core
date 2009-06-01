<cfsetting enablecfoutputonly="true">

<!--- Make sure that if the user has somehow selected 2 root nodes... only use the first. --->
<cfset session.dmProfile.overviewhome = listFirst(session.dmProfile.overviewhome) />


<!--- This is for backwards compatibility when this was stored as an Alias. --->
<cfif len(session.dmProfile.overviewhome)>
	<cfif NOT IsUUID(session.dmProfile.overviewhome) AND structKeyExists(application.navid, session.dmProfile.overviewhome)>
		<cfset session.dmProfile.overviewhome = application.navid[session.dmProfile.overviewhome] />
	</cfif>
</cfif>

<cfif not len(session.dmProfile.overviewhome)>
	<cfset session.dmProfile.overviewhome = listFirst(application.navid.home) />
</cfif>


<cfparam name="url.rootObjectID" default="#session.dmProfile.overviewhome#">


<!--- Permissions --->
<cfset iSecurityManagementState = application.security.checkPermission(permission="SecurityManagement")>
<cfset iRootNodeManagement = application.security.checkPermission(permission="RootNodeManagement")>	
<cfset iModifyPermissionsState = application.security.checkPermission(permission="ModifyPermissions")>
<cfset iDeveloperState = application.security.checkPermission(permission="developer")>
<cfset bPermTrash = application.security.checkPermission(permission="create")>

<!--- Sub Naviagtion --->


<!--- Get Level 1 Nodes --->
<cfset qAncestors = application.factory.oTree.getAncestors(objectid = url.rootObjectid)>
<cfset getChildrenRet = application.factory.oTree.getChildren(objectid=application.navid.root)>
<cfset odmNav = createObject("component",application.types.dmNavigation.typePath)>
<!--- // Subnaviagtion --->

<cfset qNode = application.factory.oTree.getNode(objectid = url.rootObjectid)>
<cfquery name="qParentSectionId" dbtype="query">
	SELECT objectid
	FROM qAncestors
	WHERE nLevel = 1
</cfquery>
<cfif qnode.nLevel EQ 1>
	<cfset URL.parentSectionId = url.rootObjectId >
<cfelse>	
	<cfif not qParentSectionId.recordCount>
		<cfset URL.parentSectionId = application.navid.root>
	<cfelse>
		<cfset URL.parentSectionID = qParentSectionId.objectid[1]>
	</cfif>		
</cfif>
<!--- Quick Zoom Navigation --->

<cfset lParentCategory = ValueList(getChildrenRet.objectID)>
<cfset iPosition = ListFindNoCase(lParentCategory,url.rootObjectId)>
<cfset parentCategoryName = getChildrenRet.objectName[iPosition]>
	
<!--- prepare quick zoom to display so logic does not happen in html --->
<cfset aZoom = ArrayNew(1)>
<cfset iCounter = 1>
<cfset aZoom[iCounter] = StructNew()>
<cfif URL.rootobjectID EQ application.navid["root"]>
	<cfset aZoom[iCounter].text = "Root">
<cfelse>
	<cfif not len(parentCategoryName)>
		<cfset aZoom[iCounter].text = qNode.Objectname>
	<cfelse>	
		<cfset aZoom[iCounter].text = "#parentCategoryName#">
	</cfif>
	
</cfif>

<cfset aZoom[iCounter].value = URL.rootobjectID>
<cfset iCounter = iCounter + 1>
<cfset qListChildren = application.factory.oTree.getChildren(objectID=url.rootObjectID)>
<cfloop query="qListChildren">
<!--- AND application.navid["#qListChildren.objectname#"] EQ application.navid.hidden --->
	<cfif isdefined("application.navid.hidden")>
		<cfset lPermissions = "Edit,Create,Delete,Approve">
	<cfelse>
		<cfset lPermissions = "View,Edit,Create,Delete,Approve">
	</cfif>
	<cfset bHasPermission = 0>
	<cfloop index="permission" list="#lPermissions#">
		<cfset bHasPermission = application.security.checkPermission(permission=permission,object=qListChildren.objectid)>
		<cfif bHasPermission EQ 1>
			<cfbreak>
		</cfif>
	</cfloop>

	<cfset aNavAlias = StructFindValue(application.navid,qListChildren.objectid)>
	
	<cfif bHasPermission EQ 1 AND ArrayLen(aNavAlias) GT 0> <!--- check if it is in the nav alias to --->
		<cfloop index="i" from="1" to="#ArrayLen(aNavAlias)#">
			<cfset aZoom[iCounter] = StructNew()>
			<cfset aZoom[iCounter].text = "-- " & aNavAlias[i].key>
			<cfset aZoom[iCounter].value = application.navid[aNavAlias[i].key]>
			<cfset iCounter = iCounter + 1>
		</cfloop>
	</cfif>
</cfloop>
<!--- // Quick Zoom Navigation --->


<!--- <cfif isdefined("url.zoomRootObjectID")> --->
<cfset defaultPage="#application.url.farcry#/navajo/overview_frame.cfm?rootobjectid=#url.rootObjectId#">
<!--- <cfelse>
	<cfif len(trim(session.dmProfile.overviewHome)) neq 0>
		<cfset defaultPage="#application.url.farcry#/navajo/overview_frame.cfm?rootobjectid=#application.navid[session.dmProfile.overviewHome]#">
	<cfelse>
		<cfset defaultPage="#application.url.farcry#/navajo/overview_frame.cfm?rootobjectid=#getChildrenRet.objectId#">
	</cfif>
</cfif> --->


<cfset upOneRootobjectid = "">

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>FarCry Sidebar</title>
<style type="text/css" title="default" media="screen">@import url(../css/main.css);</style>
<script type="text/javascript">
function refreshiFrame(iFrameName){
	objiFrame = document.getElementById(iFrameName);
	objiFrame.contentWindow.location.reload() 
	return false;
}	
</script>
</head>
<body class="iframed iframed-tree">

<form style="display:inline" id="subjump" action="" method="get" class="iframe-nav-form" style="margin-bottom:10px">
	<select name="rootObjectID" onchange="document.getElementById('subjump').parentSectionId.value=document.getElementById('subjump').rootObjectID.value;this.form.submit();">
		<option value="#application.navid['root']#"<cfif url.parentSectionId EQ application.navid["root"]> selected="true"</cfif>>Root</option>
		<cfloop query="getChildrenRet">
		<option value="#getChildrenRet.objectID#"<cfif url.parentSectionId EQ getChildrenRet.objectID> selected="true"</cfif>>#getChildrenRet.objectName#</option>
		</cfloop>
	</select>
	<input type="hidden" name="parentSectionId" value="">
</form>
<div class="refreshtree"><a href="##" onclick="return refreshiFrame('iframe-sideTree');"><img alt="refresh tree" src="#application.url.farcry#/images/refresh.gif" /></a></div>
<br />
<!--- display quick links in dropdown for tree --->
<cfif ArrayLen(aZoom)>
<form name="frmZoom" action="" method="get" class="iframe-nav-form-zoom" style="margin-top:10px">
	<small><strong>Quick Zoom:</strong></small>
	 <select name="rootObjectID" onChange="document.forms['frmZoom'].parentSectionId.value=document.getElementById('subjump').rootObjectID.value;this.form.submit();">
		<cfloop from="1" to="#ArrayLen(aZoom)#" index="i">
		<option value="#aZoom[i].value#"<cfif URL.rootObjectid EQ aZoom[i].value>selected="true"</cfif>>#aZoom[i].text#</option></cfloop>
		
		<cfset parentSectionId>
	</select>
	<input type="hidden" name="parentSectionId" value="">
	
</form></cfif>




	<cfif NOT URL.rootObjectid IS application.navid.root>
		
		<cfset qParent = application.factory.oTree.getParentID(objectid=URL.rootObjectid,dsn=application.dsn)>
		<cfif qParent.recordCount>
			<cfset uponeRootobjectid = qParent.parentid>
			<cfset bHasViewPermission = application.security.checkPermission(permission="view",object=upOneRootObjectid)>
			<cfif (NOT upOneRootObjectid is application.navid.root AND bHasViewPermission EQ 1) OR (upOneRootObjectid Is application.navid.root AND iRootNodeManagement EQ 1)>
				<cfoutput><div class="upone"><a href="#cgi.script_name#?rootobjectid=#upOneRootobjectid#"><img alt='Up one level' src="#application.url.farcry#/images/treeImages/uponefolder.gif"></a></div></cfoutput>
			</cfif>
		</cfif>
	</cfif>


<iframe height="100%" src="#defaultpage#" name="sideTree" scrolling="auto" frameborder="0" id="iframe-sideTree">
</iframe>

</body>
</html>
</cfoutput>


<cfscript>
/**
* Returns TRUE if the string is a valid CF UUID.
*
* @param str String to be checked. (Required)
* @return Returns a boolean.
**/

function IsUUID(str) {
return REFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", str);
}
</cfscript>