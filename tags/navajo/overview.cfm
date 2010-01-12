<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/navajo/overview.cfm,v 1.115.2.1 2006/02/16 01:21:33 paul Exp $
$Author: paul $
$Date: 2006/02/16 01:21:33 $
$Name: milestone_3-0-1 $
$Revision: 1.115.2.1 $

|| DESCRIPTION || 
$Description: Javascript tree$

|| DEVELOPER ||
$Developer: Paul Harrison (paul@enpresiv.com)$
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<!--- include tag library --->
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">

<!--- include function library --->
<cfinclude template="/farcry/core/webtop/includes/cfFunctionWrappers.cfm">

<!--- optional attributes --->
<cfparam name="attributes.zoom" default="16">
<cfparam name="attributes.nodetype" default="dmNavigation"> <!--- Allows you to have tree of diffenent 'typenames' - useful if you want full site tree functionality, but for other applications such as document management perhaps --->
<cfif isDefined("url.zoom")><cfset attributes.zoom=url.zoom></cfif>
	<cfset fontZoom = int(attributes.zoom/16*9)>
	<cfset menuZoom = int(attributes.zoom/16*120)>
<cfparam name="application.navid.rubbish" default="">
<cfparam name="attributes.lCreateObjects" default="ALL"><!--- This is a list of typenames that you want to restrict to being created in the tree --->

<cfscript>
	//default overivew params structure for further flexibility when using tree functionality with apps other than the 'site overview' - This is very much a work in progress.
	stOverview = structNew();
	st = stOverview;
	st.menu.insert.dmHTML = '#application.url.webroot#/index.cfm'; //default page to insert dmHTML links
	st.popupmenu.URL.createObject = '#application.url.farcry#/conjuror/evocation.cfm';
	st.popupmenu.URL.deleteObject = '#application.url.farcry#/navajo/delete.cfm';
</cfscript>
<cfparam name="attributes.stOverview" default="#stOverview#">

<cfscript>
	stOverview = attributes.stOverview;
	
	function buildTreeCreateTypes(a,lTypes)
	{
		
		aTypes = listToArray(lTypes);
		
		//build core types first
		for(i=1;i LTE arrayLen(aTypes);i = i+1)
		{		
			if (structKeyExists(application.types[aTypes[i]],'bUseInTree') AND application.types[aTypes[i]].bUseInTree AND NOT application.types[aTypes[i]].bcustomType)
			{	stType = structNew();
				stType.typename = aTypes[i];
				if (structKeyExists(application.types[aTypes[i]],'displayname'))   //displayname *seemed* most appropriate without adding new metadata
					stType.description = application.types[aTypes[i]].displayName;
				else
					stType.description = aTypes[i];
				arrayAppend(a,stType);
			}	
		}	
		//now custom types
		for(i=1;i LTE arrayLen(aTypes);i = i+1)
		{		
			if (structKeyExists(application.types[aTypes[i]],'bUseInTree') AND application.types[aTypes[i]].bUseInTree AND application.types[aTypes[i]].bcustomType)
			{	stType = structNew();
				stType.typename = aTypes[i];
				if (structKeyExists(application.types[aTypes[i]],'displayname'))   //displayname *seemed* most appropriate without adding new metadata
					stType.description = application.types[aTypes[i]].displayName;
				else
					stType.description = aTypes[i];
				arrayAppend(a,stType);
			}	
		}	
		
		return a;
	}
	
	aTypesUseInTree = arrayNew(1);
	if(attributes.lCreateObjects is 'ALL')
	{
		lPreferredTypeSeq = '#attributes.nodetype#,dmHTML'; // this list will determine preffered order of objects in create menu - maybe this should be configurable.
		aTypesUseInTree = buildTreeCreateTypes(aTypesUseInTree,lPreferredTypeSeq); 
		lAllTypes = structKeyList(application.types);
		//remove preffered types from *all* list
		aPreferredTypeSeq = listToArray(lPreferredTypeSeq);
		for (i=1;i LTE arrayLen(aPreferredTypeSeq);i=i+1)
		{
			listDeleteAt(lAllTypes,listFindNoCase(lAllTypes,aPreferredTypeSeq[i]));
		}
		aTypesUseInTree = buildTreeCreateTypes(aTypesUseInTree,lAllTypes); 
	}else
		aTypesUseInTree =buildTreeCreateTypes(aTypesUseInTree,attributes.lCreateObjects); 
	//dump(aTypesUseInTree);
		
	PermNavCreate    = application.permission.dmnavigation.Create.permissionId;
	PermNavEdit   = application.permission.dmnavigation.Edit.permissionId;
	PermNavView  = application.permission.dmnavigation.View.permissionId;
	PermNavDelete  = application.permission.dmnavigation.Delete.permissionId;
	PermNavApprove = application.permission.dmnavigation.Approve.permissionId;
	PermNavApproveOwn = application.permission.dmnavigation.CanApproveOwnContent.permissionId;
	PermNavRequestApprove = application.permission.dmnavigation.RequestApproval.permissionId;
	PermContainerManagement = application.permission.dmnavigation.ContainerManagement.permissionId;
	PermSendToTrash = application.permission.dmnavigation.sendToTrash.permissionId;

	//Permissions
	iSecurityManagementState = application.security.checkPermission(permission="SecurityManagement");	
	iRootNodeManagement = application.security.checkPermission(permission="RootNodeManagement");	
	iModifyPermissionsState = application.security.checkPermission(permission="ModifyPermissions");	
	iDeveloperState = application.security.checkPermission(permission="developer");	
	bPermTrash = application.security.checkPermission(permission="create",object=application.navid.rubbish);	
	
	//get Current Loggedin user.
	stUser = application.factory.oAuthentication.getUserAuthenticationData();
		
	menuOnColor="##97ACCD";
	menuOffColor="white";
	menuFlutterOnColor="black";
	menuFlutterOffColor="##97ACCD";
	smallPopupFeatures="width=200,height=200,menubar=no,toolbars=no,";
	customIcons = attributes.customIcons;

</cfscript>

<cfoutput>

<script type="text/javascript">
	var contentFrame = parent.parent['content'];

	//parent.document.getElementById('siteEditEdit').style.display = 'none';
	var ns6=document.getElementById&&!document.all; //test for ns6
	var ie5=document.getElementById && document.all;//test for ie5

	// serverGet() function when it's done
	function serverPut(objID){
		// the URL of the script on the server to run
		strURL = "#application.url.farcry#/navajo/updateTreeData.cfm";
		// if you need to pass any variables to the script, 
		// then populate the following string with a valid query string	
		strQueryString = "lObjectIds=" + objID + "&" + Math.random();
	
		// this will append a random number to the URL string that will 
		// ensure the document isn't cached
		//strURL = strURL + "/" + Math.random();
		// if the query string variable isn't blank, then append it to the URL
		if( strQueryString.length > 0 ){
			strURL = strURL + "?" + strQueryString;
		}
		
		// if IE then change the location of the IFRAME 
		
		if( document.all ){
			// this loads the URL stored in the strURL variable into the 
			// hidden frame
			document.idServer.location = strURL;
	
		// otherwise, change Netscape v6's IFRAME source file
		} else if( document.getElementById ){
			// this loads the URL stored in the strURL variable into the hidden frame
			frames['idServer'].location.href = strURL;
			//document.getElementById("idServer").contentDocument.location = strURL;

		// otherwise, change Netscape v4's ILAYER source file
		} else if( document.layers ){
			// this loads the URL stored in the strURL variable into the 
			// hidden frame
			document.idServer.src = strURL;
		}
		
		return true;
	}

	var objects = new Object();
	var _tl0 = objects;

</script>
</cfoutput>
<cfparam name="application.navid.root" default="">

<!--- find all the root nodes --->

<cfscript>
if (isDefined("URL.rootObjectID"))
	rootObjectID = URL.rootObjectID;
else
{
	qRoot = application.factory.oTree.getRootNode(typename=attributes.nodetype);
	rootobjectid = qRoot.objectid;
}

/*if(NOT isDefined("url.insertonly"))
{
	if (NOT rootobjectid IS application.navid.root AND len(application.navid.root) EQ 35)
	{
		qParent = application.factory.oTree.getParentID(objectid=rootobjectid,dsn=application.dsn);	
		upOneRootobjectid = qParent.parentid;
		if (NOT upOneRootobjectid IS rootobjectid AND iRootNodeManagement EQ 1)
			writeoutput("<div class=""upone""><a href=""#cgi.script_name#?rootobjectid=#upOneRootobjectid#""><img alt='Up one level' src=""#application.url.farcry#/images/treeImages/uponefolder.gif""></a></div>");	
		
	}
}*/
</cfscript>


<!--- get all open nodes + root nodes --->
<cfparam name="cookie.nodestatev2" default="">
<cfset cookie.nodestatev2=listappend(cookie.nodestatev2,"0")>
<nj:treeData
	nodetype="#attributes.nodetype#"
	lObjectIds="#rootObjectID#"
	typename="#attributes.nodetype#"
	get="Children"
	topLevelVariable="objects"
	lStripFields="ORIGINALIMAGEPATH,OPTIMISEDIMAGEPATH,THUMBNAILIMAGEPATH,lNavidAlias,teaserimage,extendedmetadata,teaserimage,metakeywords,displayMethod,objecthistory,teaser,body,PATH"
	r_javascript="jscode">


<!--- convert any lower case keys to uppercase for cfml engines that don't act like cfmx --->
<cfset start = REFind("\[\'", jscode, 0) />
<cfloop condition="start GT 0">
	<cfset end = REFind("\'\]", jscode, start) />
	<cfif end GT 0>
		<cfset found =  Mid(jscode,start,end-start+3) />
		<cfset jscode = Replace(jscode,found,UCase(found),"all") />
		<cfset start = REFind("\[\'", jscode, end) />
	<cfelse>
		<cfset start = 0 />
	</cfif>
</cfloop>
<cfset jscode = replace(jscode,"_TL1", "_tl1", "all") />
<cfset jscode = replace(jscode,"_TL0", "_tl0", "all") />
<cfset jscode = replace(jscode,"NEW OBJECT", "new Object", "all") />



<cfset imageRoot = "nimages">
<cfset customIcons = attributes.customIcons>

<cfset navPermissions = application.security.factory.permission.getAllPermissions('dmNavigation') />

<!-------- PERMISSIONS ------------>
<cfoutput>
	<script type="text/javascript">
		var aPerms = new Array();
		<cfloop from="1" to="#listlen(navPermissions)#" index="i">
		aPerms[#i#] = '#listgetat(navPermissions,i)#';
		</cfloop>
		// permissions objects
		p=new Object();
		
		function hasPermission( id, pid )
		{	var permission = 0;
			var thisPerm = 0;
			var oid=id;
			
			while(permission==0)
			{	
				if( typeof(p[id])=='undefined' || typeof(p[id][pid])=='undefined' ) thisPerm=0; else thisPerm=p[id][pid];
				if( permission==0 && thisPerm != 0) permission=thisPerm;
				if( permission==-1 && thisPerm ==1 ) permission=1;
				
				if( getParentObject(id) != 0 ) id = getParentObject(id)['OBJECTID']; else break;
			}
			
			return permission;
		}
		//this is preparing for the ability to hode nodes that user doesn't have permission to edit
	</script>
</cfoutput>

<cfset nimages = "#application.url.farcry#/images/treeImages">
<cfset cimages = "#nimages#/customIcons">

<cfoutput>
<!--- initial javascript code for tree --->
<script>#jscode#</script>

<div id="popupMenus"></div>

<script>
var localWin = window;
var editFlag = false;
var copyNodeId = '';
var pasteAction = ''//may be a cut or copy

function popupopen(strURL,b,c)
{

	if(document.idServer)
		document.idServer.location = strURL;
	else if(document.getElementById)
		document.getElementById("idServer").contentDocument.location = strURL;	
}

function frameopen(a,b)
{	
	if(contentFrame && !heldEvent.ctrlKey ){
		strLocation = "'" + contentFrame + "'";
		if(b == 'content' && strLocation.toLowerCase().indexOf( "edit.cfm" ) != -1 )
			alert("#application.rb.getResource('sitetree.messages.currentlyEditingObj@text','You are currently editing a content item.\nPlease complete or cancel editing before doing anything else.\n')#" );
		else			
			contentFrame.location = a;
	}
	else popupopen(a,b+"_popup" );
}

var cookieName = "nodeStatev2=";
var rootIds = '#rootObjectId#';

var lastSelectedId = '';
var aSelectedIds = new Array();
var zoom=#attributes.zoom#;
var bEnableDragAndDrop = true;


//pre load images
//pre load images
toggleUpEmpty = new Image(16,16); toggleUpEmpty.src = "#nimages#/nbe.gif";
toggleUpOpen =  new Image(16,16);toggleUpOpen.src  = "#nimages#/bbc.gif";
toggleUpClose =  new Image(16,16);toggleUpClose.src = "#nimages#/bbo.gif";
toggleDownEmpty  = new Image(16,16);toggleDownEmpty.src = "#nimages#/nte.gif";
toggleDownOpen = new Image(16,16); toggleDownOpen.src  = "#nimages#/btc.gif";
toggleDownClose = new Image(16,16);toggleDownClose.src = "#nimages#/bto.gif";
toggleMiddleEmpty = new Image(16,16);toggleMiddleEmpty.src = "#nimages#/nme.gif";
toggleMiddleOpen = new Image(16,16);toggleMiddleOpen.src  = "#nimages#/bmc.gif";
toggleMiddleClose = new Image(16,16);toggleMiddleClose.src = "#nimages#/bmo.gif";
toggleNoneEmpty = new Image(16,16);toggleNoneEmpty.src = "#nimages#/nne.gif";
toggleNoneOpen = new Image(16,16);toggleNoneOpen.src  = "#nimages#/bnc.gif";
toggleNoneClose = new Image(16,16); toggleNoneClose.src = "#nimages#/bno.gif";
s = new Image(16,16);s.src="#nimages#/s.gif";
c = new Image(16,16);c.src="#nimages#/c.gif";
loading = new Image(23,23);loading.src="#nimages#/loading.gif";
subnavmore = new Image(16,11);subnavmore.src = "#nimages#/subnavmore.gif";
subnavmoreDisabled = new Image(16,11);subnavmoreDisabled.src = "#nimages#/subnavmoreDisabled.gif";
defaultObjectDraft = new Image(16,16);defaultObjectDraft.src ="#cimages#/defaultObjectDraft.gif";
defaultObjectLiveDraft = new Image(16,16);defaultObjectLiveDraft.src ="#cimages#/defaultObjectLiveDraft.gif";
defaultObjectLivePendingDraft = new Image(16,16);defaultObjectLivePendingDraft.src ="#cimages#/defaultObjectLivePendingDraft.gif";
defaultObjectPending = new Image(16,16); defaultObjectPending.src = "#cimages#/defaultObjectPending.gif";
defaultObjectApproved = new Image(16,16); defaultObjectApproved.src = "#cimages#/defaultObjectApproved.gif";
webserver = new Image(16,16);webserver.src="#cimages#/webserver.gif";
home = new Image(16,16); home.src="#cimages#/home.gif";
rubbish = new Image(16,16); rubbish.src = "#cimages#/rubbish.gif";
navDraftImg = new Image(16,16);navDraftImg.src = "#cimages#/NavDraft.gif";
navApprovedImg = new Image(16,16);navApprovedImg.src = "#cimages#/NavApproved.gif";
navDraftExternalLinkImg = new Image(16,16);navDraftExternalLinkImg.src = "#cimages#/NavDraftExtLink.gif";
navApprovedExternalLinkImg = new Image(16,16);navApprovedExternalLinkImg.src = "#cimages#/NavApprovedExtLink.gif";
images = new Image(16,16);images.src = "#cimages#/images.gif";
floppyDisk = new Image(16,16);floppyDisk.src="#cimages#/floppyDisk.gif";
navPending = new Image(16,16);navPending.src = "#cimages#/NavPending.gif";
pictureDraft = new Image(16,16); pictureDraft.src = "#cimages#/pictureDraft.gif";
picturePending = new Image(16,16); picturePending.src = "#cimages#/picturePending.gif";
pictureApproved = new Image(16,16); pictureApproved.src = "#cimages#/pictureApproved.gif";
includeDraft = new Image(16,16);includeDraft.src = "#cimages#/includeDraft.gif";
includePending = new Image(16,16); includePending.src = "#cimages#/includePending.gif";
includeApproved = new Image(16,16); includeApproved.src = "#cimages#/includeApproved.gif";
fileDraft = new Image(16,16); fileDraft.src = "#cimages#/fileDraft.gif";
filePending = new Image(16,16);filePending.src="#cimages#/filePending.gif";
fileApproved = new Image(16,16);fileApproved.src="#cimages#/fileApproved.gif";
cssDraft = new Image(16,16); cssDraft.src = "#cimages#/cssDraft.gif";
flashDraft = new Image(16,16); flashDraft.src = "#cimages#/flashApproved.gif";
flashPending = new Image(16,16);flashPending.src="#cimages#/flashApproved.gif";
flashApproved = new Image(16,16);flashApproved.src="#cimages#/flashApproved.gif";
linkDraft = new Image(16,16); linkDraft.src = "#cimages#/linkDraft.gif";
linkPending = new Image(16,16);linkPending.src="#cimages#/linkPending.gif";
linkApproved = new Image(16,16);linkApproved.src="#cimages#/linkApproved.gif";

</cfoutput>
<cfwddx action="CFML2JS" input="#customIcons.type#" output="customIconMap" toplevelvariable="customIconMapType">
<cfoutput>#customIconMap#</cfoutput>
<cfoutput>

function renderObjectToDiv( objId, divId )
{
	var el = document.getElementById( divId );
	var elData=renderObject( objId )
	el.innerHTML = elData;
	
}

function renderObject( objId )
{
	var thisObject = objects[objId];
	
	if( !thisObject ) return "";
	
	var elData="";
	if (hasPermission(objId,'#PermNavView#') >= 0)
	{
		if( rootIds.indexOf(objId)!=-1) elData += "<table class=\"tableNode\" cellspacing=\"0\"><tr><td>";
		else
		{   
			var parent = getParentObject( objId );
			var parentParent = getParentObject( parent['OBJECTID'] );
			if( parentParent['OBJECTID'] 
				&& (nodeIndex(parent['OBJECTID'])!=-1 && nodeIndex(parent['OBJECTID'])!=countNodes(parentParent['OBJECTID'])-1)
				|| (objectIndex(parent['OBJECTID'])!=-1 && objectIndex(parent['OBJECTID'])!=countChildren(parentParent['OBJECTID'])-1) &&  countNodes(parent['OBJECTID']) > 1  )
				elData += "<table id=\""+objId+"_table\" class=\"tableNode\" cellspacing=\"0\"><tr><td style=\"background-image: url("+c.src+");background-repeat : repeat-y;\"><img src=\""+s.src+"\" width=\""+zoom+"\" height=\""+zoom+"\"></td><td>";
			else
				elData += "<table id=\""+objId+"_table\" class=\"tableNode\" cellspacing=\"0\"><tr><td style=\"background-image: url(" + s.src +");background-repeat : repeat-y;\"><img src=\""+s.src+"\" width=\""+zoom+"\" height=\""+zoom+"\"></td><td>";
		}
		
		var jsHighlight=" onclick=\"highlightObjectClick('"+objId+"',event)\" ";
		
		var contextMenu = " oncontextmenu=\"if(!event.ctrlKey)highlightObjectClick('"+objId+"',event);popupObjectMenu(event);return false;\" ";
		var drag = " ondragstart=\"startDrag('"+objId+"','"+thisObject['TYPENAME']+"')\" ondrop=\"dropDrag('"+objId+"')\" ";
		
		//objects can only be dropped under dmNavigation nodes
		if( thisObject['TYPENAME'].toLowerCase()=="#lCase(attributes.nodetype)#" )
			drag += " ondragover='dragOver()'";	
		else if( thisObject['TYPENAME']=="dmHTML")
			drag += " ondragover=\"if(dragTypeId.toLowerCase()=='dmimage' || dragTypeId.toLowerCase()=='dmfile') dragOver();\" ";
			
				
		elData+="<table class=\"tableNode\" "+contextMenu+" cellspacing=\"0\">\n<tr><td class=\"iconText\">"+getToggleImage(objId)+
					"<div id=\"non\""+jsHighlight+" style=\"display:inline\" "+drag+jsHighlight+">"+getTypeImage(objId)+"</div>\n</td>"+
					"<td valign=\"middle\" class=\"iconText\">"+
					"\n<div id=\""+objId+"_text\" "+jsHighlight+" class=\"menu-text\">"+getObjectTitle(objId)+
					"</div>\n</td></tr>\n</table>"+
					"<div id=\""+objId+"\" style=\"display:none;\">\n</div>\n";
		
		elData += "</td></tr>\n</table>";
		return elData;
	}	
	else 
		return "";	
}

var dragObjectId='';
var dragTypeId='';

function enableDragAndDrop()
{
	bEnableDragAndDrop = true;
}

function disableDragAndDrop()
{
	bEnableDragAndDrop = false;
}

function startDrag( aDragObjectId, aDragTypeId )
{	
    <!--- store the source of the object into a string acting as a dummy object so we don't ruin the original object: --->
	dragObjectId = aDragObjectId;
	dragTypeId = aDragTypeId;
	
    <!--- post the data for Windows: --->
    var dragData = window.event.dataTransfer;

    <!--- set the type of data for the clipboard: --->
	dragData.setData('Text', dragObjectId);
	
    <!--- allow only dragging that involves moving the object: --->
    dragData.effectAllowed = 'linkMove';

    <!--- use the special 'move' cursor when dragging: --->
    dragData.dropEffect = 'move';
}

function dragOver()
{
	<!--- tell onOverDrag handler not to do anything: --->
	window.event.returnValue = false;
}

function dropDrag(aDropObjectId)
{	
	if(!bEnableDragAndDrop)
	{
		alert("#application.rb.getResource('sitetree.messages.branchLockoutBlurb@text','Another editor is currently modifying the hierarchy. Please refresh the site overview tree and try again.')#");
		return false;
	}
	<!--- eliminate default action of ondrop so we can customize: --->
	//double checking here - shouldn't ever need to though
	if (objects[dragObjectId]['TYPENAME'] == 'dmHTML' && objects[aDropObjectId]['TYPENAME'].toLowerCase() != '#lCase(attributes.nodetype)#')
	{
		alert('#application.rb.getResource("sitetree.messages.canOnlyDragHTMLObj@text","You may only drag a HTML object to a Navigation node")#');
		window.event.returnValue = false;
		return;
	}
	//check for equal dest/parent objectid
			
	if(aDropObjectId == getParentObject(dragObjectId)['OBJECTID'])
	{
		alert('#application.rb.getResource("sitetree.messages.parentDestinationSame@text","Content Item parent and destination parent cannot be the same")#');
		return;
	}
	
	if(aDropObjectId == '#application.navid.rubbish#')
		permcheck = "hasPermission( lastSelectedId, '#PermSendToTrash#' ) > 0";
	else
		permcheck = "hasPermission( aDropObjectId, '#PermNavCreate#' ) > 0";
	
	if (eval(permcheck))
	{	if( dragObjectId != aDropObjectId && confirm('#application.rb.getResource("sitetree.messages.confirmMoveObj@text","Are you sure you wish to move this item?")#'))
		{		
			disableDragAndDrop();	
			popupopen('#application.url.farcry#/navajo/move.cfm?srcObjectId='+dragObjectId+'&destObjectId='+aDropObjectId,'NavajoExt','#smallPopupFeatures#');
		}
	}	
	else
		alert('#application.rb.getResource("sitetree.messages.noNodePermission@text","You do not have permission to move content items to this node")#');	
	
	window.event.returnValue = false;
}

function renderObjectSubElements( objId )
{
	var thisObject = objects[objId];
	if( !thisObject ) return;
	
	var updateDivEl = document.getElementById( objId );
	var divData = "";
	
	var aObjectIds = thisObject['AOBJECTIDS'];
	if( aObjectIds )
	{
		for( var index=0; index < aObjectIds.length; index++ )
		{
			divData += renderObject( aObjectIds[index] );
		}
	}
	
	var aNodes = thisObject['ANAVCHILD'];
	if( aNodes )
	{
		for( var index=0; index < aNodes.length; index++ )
		{
			divData += renderObject( aNodes[index] );
		}
	}
	
	updateDivEl.innerHTML = divData;
}

function getObjectTitle( objId )
{
	var thisObject = objects[objId];
	
	if( !thisObject || !thisObject['LABEL'] ) return "undefined";
	
	return thisObject['LABEL'];
}

function getToggleImage( objId )
{
	<!--- work out what toggle to put on this node --->
	<!--- if it has children or aObjectIds then we need a toggle --->
	var toggle="Empty";
	
	if( countChildren(objId) ) toggle="Open";
	
	var parent = getParentObject( objId );
	
	var direction = "Middle";
	
	<!--- if this is a root node then the toggle is none --->
	if( parent=='0' ) direction = "None";
	
	<!--- else if this is the last node or object --->
	else if( (objectIndex(objId)!=-1 && objectIndex(objId)==countChildren(parent['OBJECTID'])-1)
			|| (nodeIndex(objId)!=-1 && nodeIndex(objId)==countNodes(parent['OBJECTID'])-1) ) direction = "Up";

	scripting="";	
	if( toggle!="Empty" ) scripting=" onclick=\"toggleObject('"+objId+"')\" ";
	
	return "<img id='"+objId+"_toggle' src=\""+eval( 'toggle'+direction+toggle+'.src' )+"\" width=\""+zoom+"\" height=\""+zoom+"\" "+scripting+">";
			}
			
			function swapToggleImage( src )
			{   
				if( src.indexOf(toggleUpOpen.src) !=-1 ) return toggleUpClose.src;
				if( src.indexOf(toggleUpClose.src) !=-1 ) return toggleUpOpen.src;
				
				if( src.indexOf(toggleDownOpen.src) !=-1 ) return toggleDownClose.src;
				if( src.indexOf(toggleDownClose.src) !=-1 ) return toggleDownOpen.src;
				
				if( src.indexOf(toggleMiddleOpen.src) !=-1 ) return toggleMiddleClose.src;
				if( src.indexOf(toggleMiddleClose.src) !=-1 ) return toggleMiddleOpen.src;
				
				if( src.indexOf(toggleNoneOpen.src) !=-1 ) return toggleNoneClose.src;
				if( src.indexOf(toggleNoneClose.src) !=-1 ) return toggleNoneOpen.src;
				
				return src;
			}
			
			function getTypeImage( objId )
			{
				var thisObject = objects[objId];
				
			
				var tp = thisObject['TYPENAME'].toLowerCase();
				if (tp == '#lCase(attributes.nodetype)#') {
					tp = 'dmnavigation';
				}
				
				var st = 'approved';
				if( thisObject['STATUS'] ) {
			        if (thisObject['BHASDRAFT'] && thisObject['DRAFTSTATUS'] == 'pending')
			            st = 'livependingdraft';
					else if (thisObject['BHASDRAFT'])
						st = 'livedraft';
					else	
						st = thisObject['STATUS'].toLowerCase();
				}		
			
				var cm = customIconMapType['default'][st];
			
				if( customIconMapType[tp] && st ) cm=customIconMapType[tp][st];
				
				var na=thisObject['LNAVIDALIAS'];
				if(na) na=na.toLowerCase();
				
				if( na && customIconMapType[na] ) cm = customIconMapType[na][st];
				
	var el = thisObject['EXTERNALLINK'];
	if (el)  {
		el=el.toLowerCase();
	}
	
	if (el && customIconMapType['externallink']) {
		cm = customIconMapType['externallink'][st];
	}
	
	var alt = "Current Status: "+thisObject['STATUS']+" Created By: "+thisObject['ATTR_CREATEDBY']+" on "+thisObject['ATTR_DATETIMECREATED']+
			"Last Updated By: "+thisObject['ATTR_LASTUPDATEDBY']+" on "+thisObject['ATTR_DATETIMELASTUPDATED'];
			
	
	 return "<img src=\""+cm+"\" width=\""+zoom+"\" height=\""+zoom+"\" alt=\""+alt+"\">"; 
}

function countChildren( objId )
{
	return countNodes(objId) + countObjects(objId);
}

function countNodes( objId )
{
	var theObject = objects[objId];
	
	if(!theObject || !theObject['ANAVCHILD'] ) return 0;
	
	return theObject['ANAVCHILD'].length;
}

//Counts all objects in a navigation node
function countObjects( objId )
{
	
	var theObject = objects[objId];
	
	if(!theObject || !theObject['AOBJECTIDS'] ) return 0;
	
	return theObject['AOBJECTIDS'].length;
}

function objectIndex( objId )
{
	var parent = getParentObject( objId );
	
	if( parent["AOBJECTIDS"] )
	{
		for( var index=0; index < parent["AOBJECTIDS"].length; index++ )
		{
			if( parent[searchKey][index]==objId ) return index;
		}
	}
	
	return -1;
}

function nodeIndex( objId )
{
	var parent = getParentObject( objId );
	
	if( parent["ANAVCHILD"] )
	{
		for( var index=0; index < parent["ANAVCHILD"].length; index++ )
		{
			if( parent["ANAVCHILD"][index]==objId ) return index;
		}
	}
	
	return -1;
}

function deleteObject(objId)
{
	delete objects[objId];
}


function getParentObject( objId )
{
	var theNode = objects[objId];
	
	if( !theNode ) return '0';
	
	<!--- if this is a nav node search aNavChild else search aObjectIds --->
	searchKey="AOBJECTIDS";
	
	if( theNode['TYPENAME'].toLowerCase()=='#lCase(attributes.nodetype)#' ) searchKey="ANAVCHILD";
	
	for( var testObjId in objects )
	{
		var thisObject = objects[testObjId];
		
		if( thisObject && thisObject[searchKey] )
		{
			for( var index=0; index < thisObject[searchKey].length; index++ )
			{
				if( thisObject[searchKey][index]==objId ) return thisObject;
			}
		}
	}
	
	return 0;
}

function toggleObject( objId )
{
	 //if( !countChildren(objId) ) return;  
	
	var toggleImageEl = document.getElementById( objId+"_toggle" );
	if(toggleImageEl)
		toggleImageEl.src = swapToggleImage( toggleImageEl.src ); 
	
	var el = document.getElementById( objId );
	
	if(el && (el.style.display=='none' || el.style.display=='') )
	{
		
		el.innerHTML = "<img src=\""+loading.src+"\" width=\""+(zoom-8)+"\" height=\""+(zoom-8)+"\"><span class=\"iconText\"> Loading...</span>";
		
		allDefined=1;
		
		<!--- Check that we don't already have the data in memory --->
		<!--- and don't have to do a reload  --->
		if( objects[objId] )
		{
			var o = objects[objId];

			if( o['ANAVCHILD'] )
			{
				for( var i=0; i < o['ANAVCHILD'].length; i++ )
				{
					if( !objects[o['ANAVCHILD'][i]] )
					{
						allDefined=0;
						break;
					}
				}
			}
			
			if( allDefined==1 && o['AOBJECTIDS'] )
			{   for( var i=0; i < o['AOBJECTIDS'].length; i++ )
				{   
					if( !objects[o['AOBJECTIDS'][i]] )
					{
						allDefined=0;
						break;
					}
				}
			}
		}
		
		if( allDefined ) 
		{	
			downloadRender( objId );
		}
		else 
		{
			serverPut(objId);
		}
				
	
		storeState( objId, 1 );
		el.style.display = "inline";
		/*else
			//alert(objId);
			//alert(getParentObject(objId)['OBJECTID']);
			document.getElementById(objId).style.display = 'none';	
		*/	
		
	}
	else if (el)
	{
		storeState( objId, 0 );
		el.style.display = "none";
		/*if(ns6)
			el.innerHTML='';*/
	}
	
}

function updateTree(src,dest,srcobjid)
{	//alert('src parend is ' + src + ' dest parent is ' + dest);
		
	srcParent = getParentObject(src);
		
	if(objects[srcobjid]['TYPENAME'].toLowerCase() != 'dmnavigation')
	{		
		delete srcParent['AOBJECTIDS'][objectIndex(src)];
				
		//add to destination array
		if(objects[dest])
		{
			if(objects[dest]['AOBJECTIDS'].length > 0)
				objects[dest]['AOBJECTIDS'].push(src);
			else
				objects[dest]['AOBJECTIDS'] = new Array(src);
		}		
		downloadRender(srcParent['OBJECTID']);	
	}	
	else	
	{
		delete srcParent['ANAVCHILD'][nodeIndex(src)];
		//insert into dest
		if(objects[dest])
		{
			if(objects[dest]['ANAVCHILD'].length)
				objects[dest]['ANAVCHILD'].unshift(src);
			else
				objects[dest]['ANAVCHILD'] = new Array(src);	
		}		
		downloadRender(srcParent['OBJECTID']);		
	}	
	if(objects[dest])
	{		
		getObjectDataAndRender(dest);
		downloadRender(dest);	
	}	
	getObjectDataAndRender(srcParent['OBJECTID']);
	downloadRender(srcParent['OBJECTID']);

}


function downloadDone( s )
{	var objectId = eval(s);
	var parentId = getParentObject(objectId)['OBJECTID'];
	toggleObject(parentId);
	toggleObject(parentId);
		
}


function getObjectDataAndRender( objId )
{	
	var parentObj;
	if( objId && objId !=0 ) parentObj = getParentObject(objId);
	
	if( objId && objId != '0' && parentObj )
	{
		serverPut(objId);
	}
	else
	{
		<!--- reloading the window this way, because of some bug --->
		<!--- in windows causing window.reload to crash --->
		window.location.href = "#cgi.script_name#?i="+(new Date()).getTime()+"&rootObjectID=#rootobjectID#";
	}
}


function downloadRender( objectId )
{
	
	renderObjectSubElements( objectId );

	<!--- loop throught this object children and see if any of them need to be toggled --->
	var theObject = objects[objectId];
	var aCookies = document.cookie.split(";");
	var cookieString="";
	
	for( var i=0; i<aCookies.length; i++ )
	{
		if ( aCookies[i].indexOf( cookieName ) != -1 )
		{
			cookieString = aCookies[i];
			break;
		}
	}
	
	if( theObject['AOBJECTIDS'] )
	{
		for( var cnt=0; cnt < theObject['AOBJECTIDS'].length; cnt++ )
		{
			if( cookieString.indexOf(theObject['AOBJECTIDS'][cnt]) != -1 )
			{
				toggleObject( theObject['AOBJECTIDS'][cnt] );
			}
		}
	}
	
	if( theObject['ANAVCHILD'] )
	{
		for( var cnt=0; cnt < theObject['ANAVCHILD'].length; cnt++ )
		{
			if( cookieString.indexOf(theObject['ANAVCHILD'][cnt]) != -1 )
			{
				toggleObject( theObject['ANAVCHILD'][cnt] );
			}
		}
	}
	
}

function highlightObjectClick( id,e )
{   
	if( !e.ctrlKey )
	{
		// check if already in edit mode, if not show overview page	
		if(contentFrame && contentFrame.document.location.href.indexOf(id) < 0 && contentFrame.document.location.href.indexOf("edittabEdit") < 0 && contentFrame.document.location.href.indexOf("edit.cfm") < 0)
		{
			// load overview page
			contentFrame.document.location = "#application.url.farcry#/edittabOverview.cfm?objectid=" + id + '&ref=overview';
			// make tabs visible in edit frame
			showEditTabs('site',id,'edittabOverview');
			// change title in edit frame
		}
		
		clearHighlightedObjects();
		highlightObject( id );
		
	}
	else toggleObjectHighlight( id );
}

function highlightObject( id )
{
	
	var theDiv = document.getElementById( id+"_text" );
	if( theDiv )
	{
		theDiv.style.backgroundColor="##97ACCD";
		if( !isSelected(id) )
		{
			aSelectedIds[aSelectedIds.length]=id;
			lastSelectedId = id;
		}
	}

	/*var rng = document.body.createTextRange( );
	rng.move('character');
	rng.select();*/
}

function isSelected( id )
{
	for( var i=0; i<aSelectedIds.length; i++ )
	{
		if( aSelectedIds[i]==id ) return 1;
	}
	
	return 0;
}

function clearHighlightedObjects()
{
	for( var i=0; i<aSelectedIds.length; i++ )
	{
		var theDiv = document.getElementById( aSelectedIds[i]+"_text" );
		if( theDiv ) theDiv.style.backgroundColor="";
	}
	
	<!--- clear the array --->
	lastSelectedId = 0;
	aSelectedIds = new Array();

	/*var rng = document.body.createTextRange( );
	rng.move('character');
	rng.select();*/
}

function toggleObjectHighlight( id )
{
	<!--- see if div is already selected --->
	var isSelected = 0;
	var i;
	
	for( i=0; i<aSelectedIds.length; i++ )
	{
		if( aSelectedIds[i]==id )
		{
			isSelected=1;
			break;
		}
	}
	
	if( isSelected )<!--- if it is selected, turn it off --->
	{
		var theDiv = document.getElementById( id+"_text" );
		if( theDiv ) theDiv.style.backgroundColor="";
		
		aSelectedIds.splice( i, 1 );
	}
	else highlightObject( id );<!--- else turn it on --->
	
	/*var rng = document.body.createTextRange( );
	rng.move('character');
	rng.select();*/
}

function storeState( id, state )
{
	if( id == 0 ) return;
	var aCookies = document.cookie.split(";");

	var newCookie=cookieName;
	
	for( var i=0; i<aCookies.length; i++ )
	{
		if ( aCookies[i].indexOf( cookieName ) != -1 )
		{
			var temp = aCookies[i].substring( cookieName.length, aCookies[i].length);
			var nodeids = temp.split(",");
			
			<!--- loop through the cookies and generate the new node state --->
			for( var index=0; index < nodeids.length; index++ )
			{
				var aid = nodeids[index].replace( /\=/g, "" );
				if( aid != id )
				{
					if ( newCookie.length > cookieName.length ) newCookie += ",";
					newCookie += aid;
				}
			}
		}
	}
	
	if(state)
	{
		if ( newCookie.length > cookieName.length ) newCookie += ",";
		newCookie += id;
	}
	
	var aDate = new Date();
	//aDate.setFullYear( aDate.getFullYear()+1 );
	//var expiration = new Date((new Date()).getTime() + 1*3600000);
	//document.cookie = newCookie + "; expires="+aDate.toGMTString();
	document.cookie = newCookie;// + "; expires="+expiration;
}


objectMenu = new Object();
objectMenu.menuInfo = new Object();
objectMenu.menuInfo.name = "ObjectMenu";
<cfif isDefined("url.insertonly")>
o = new Object();
objectMenu['Insert'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.insert@label','Insert')#";
o.js = "menuOption_Insert()";
o.jsvalidate = "(contentFrame.insertObjId || contentFrame.insertObjIds || contentFrame.insertHTML)?1:0";
o.bShowDisabled = 1;
o.bSeperator = 0;

function menuOption_Insert()
{
	// get object
	var theNode = objects[ lastSelectedId ];
	var p = contentFrame;
	
	if( p.insertaObjIds ) p.insertaObjIds( aSelectedIds );
	else if( p.insertObjId ) p.insertObjId( lastSelectedId );
	else switch( theNode['TYPENAME'] )
	{
			<cfparam name="application.config.overviewTree.bUseHiResInsert" default="0">
		case "dmImage":
			if (theNode['OPTIMISEDIMAGE'] && theNode['OPTIMISEDIMAGE'].length && #application.config.overviewTree.bUseHiResInsert#)	
			{
			<cfif isDefined("application.config.overviewTree.insertJSdmImageHiRes")>
				p.insertHTML("#evaluate(DE(application.config.overviewTree.insertJSdmImageHiRes))#");
			<cfelse>
 				p.insertHTML("<img alt='"+theNode['ALT']+"' src='#application.url.webroot#/images/"+theNode['OPTIMISEDIMAGE']+"'>");
			</cfif>
				
			}
			else
			{
			<cfif isDefined("application.config.overviewTree.insertJSdmImage")>
				p.insertHTML("#evaluate(DE(application.config.overviewTree.insertJSdmImage))#");
			<cfelse>
 				p.insertHTML( "<img alt='"+theNode['ALT']+"' src='#application.url.webroot#/images/"+theNode['IMAGEFILE']+"'>" );
			</cfif>
			}
			break;		
		
		case "dmFile":
			<cfif isDefined("application.config.overviewTree.insertJSdmFile")>
				p.insertHTML("#evaluate(DE(application.config.overviewTree.insertJSdmFile))#");
			<cfelse>
				p.insertHTML( "<a href='#application.url.webroot#/download.cfm?DownloadFile="+lastSelectedId+"' target='_blank'>"+theNode['TITLE']+"</a>" );
			</cfif>
			break;		
			
		case "dmFlash":
			<cfif isDefined("application.config.overviewTree.insertJSdmFlash")>
			p.insertHTML("#evaluate(DE(application.config.overviewTree.insertJSdmFlash))#");
			<cfelse>
			p.insertHTML( "<OBJECT classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000' codebase='http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version="+theNode['FLASHVERSION']+"' WIDTH='"+theNode['FLASHWIDTH']+"'  HEIGHT='"+theNode['FLASHHEIGHT']+"'  ALIGN='"+theNode['FLASHALIGN']+"'><PARAM NAME='movie' VALUE='http://#CGI.SERVER_NAME#:#CGI.SERVER_PORT##application.url.webroot#/files/"+theNode['FLASHMOVIE']+"'><PARAM NAME='quality' VALUE='"+theNode['FLASHQUALITY']+"'><PARAM NAME='play' VALUE='"+theNode['FLASHPLAY']+"'><PARAM NAME='menu' VALUE='"+theNode['FLASHMENU']+"'><PARAM NAME='loop' VALUE='"+theNode['FLASHLOOP']+"'><PARAM NAME='FlashVars' VALUE='"+theNode['FLASHPARAMS']+"'><EMBED SRC='http://#CGI.SERVER_NAME#:#CGI.SERVER_PORT#/#application.url.webroot#/files/"+theNode['FLASHMOVIE']+"' QUALITY='"+theNode['FLASHQUALITY']+"' WIDTH='"+theNode['FLASHWIDTH']+"' HEIGHT='"+theNode['FLASHHEIGHT']+"' FLASHVARS='"+theNode['FLASHPARAMS']+"' ALIGN='"+theNode['FLASHALIGN']+"' MENU='"+theNode['FLASHMENU']+"' PLAY='"+theNode['FLASHPLAY']+"' LOOP='"+theNode['FLASHLOOP']+"' TYPE='application/x-shockwave-flash' PLUGINSPAGE='http://www.macromedia.com/go/getflashplayer'></EMBED></OBJECT>" );
			</cfif>
			break;
			
		default:
			<cfif isDefined("application.config.overviewTree.insertJSdmHTML")>
			p.insertHTML("#evaluate(DE(application.config.overviewTree.insertJSdmHTML))#");
			<cfelse>
			p.insertHTML( "<a href='#application.url.webroot#/index.cfm?objectId="+lastSelectedId+"'>"+theNode['TITLE']+"</a>" );
			</cfif>
			break;
	}
} 
<cfelse>
<!--- ***  MENU DATA *** --->


o = new Object();
objectMenu['Edit'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.edit@label','Edit')#";
o.js = "menuOption_Edit();";
o.jsvalidate = "hasPermission( lastSelectedId, '#PermNavEdit#' );";
o.bShowDisabled = "1";

function menuOption_Edit()
{
	// open edit page in edit frame
	frameopen('#application.url.farcry#/edittabEdit.cfm?objectId='+lastSelectedId+'&typename='+objects[lastSelectedId]['TYPENAME'].toLowerCase(), 'content');
	// set edit tab to active
//	showEditTabs('site',lastSelectedId,'edittabEdit');
}

o = new Object();
objectMenu['Copy'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.copy@label','Copy')#";
o.js = "menuOption_Copy();";
o.jsvalidate = "(objects[lastSelectedId]['TYPENAME'].toLowerCase() == '#lCase(attributes.nodetype)#')?1:0";
o.bShowDisabled = "0";

function menuOption_Copy()
{
	copyNodeId = lastSelectedId;
	pasteAction = 'copy';
	return true;
}


o = new Object();
objectMenu['Cut'] = o;
o.text = "Cut";
o.js = "menuOption_Cut();";
o.jsvalidate = "(objects[lastSelectedId]['TYPENAME'].toLowerCase() == '#lCase(attributes.nodetype)#')?1:0";
o.bShowDisabled = "0";


function menuOption_Cut()
{
if( hasPermission( lastSelectedId, '#PermNavCreate#' ) > 0 )
{ copyNodeId = lastSelectedId;
pasteAction = 'cut';
return true; }
else
{ alert('#application.rb.getResource("sitetree.messages.noModifyNodePermission@text","You do not have permission to modify the node.")#');
copyNodeId = 0;
pasteAction = 'cut';
return false; }
}


o = new Object();
objectMenu['Paste'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.paste@label','Paste')#";
o.js = "menuOption_Paste();";
o.jsvalidate = "(copyNodeId.length == 35 && objects[lastSelectedId]['TYPENAME'].toLowerCase() == '#lCase(attributes.nodetype)#')?1:0";
o.bShowDisabled = "1";


function menuOption_Paste()
{
	var pasteMsg = '';
	if(copyNodeId == lastSelectedId)
	{
		return false;
	}

	if( hasPermission( lastSelectedId, '#PermNavCreate#' ) > 0 )
	{
		if (objects[copyNodeId]['TYPENAME'].toLowerCase() == '#lCase(attributes.nodetype)#')
		{
			if(pasteAction == 'copy')
			pasteMsg = 'Do you wish to copy the node ' + getObjectTitle( copyNodeId ) + ' to ' + getObjectTitle( lastSelectedId );
			else if(pasteAction == 'cut')
				pasteMsg = 'Do you wish to cut and paste the node ' + getObjectTitle( copyNodeId ) + ' to ' + getObjectTitle( lastSelectedId );
		}
		if (confirm(pasteMsg))
		{
		if(pasteAction == 'copy')
			popupopen( '#application.url.farcry#/navajo/treeCopyNPaste.cfm?srcObjectId='+copyNodeId+'&destobjectId='+lastSelectedId, '_blank', '#smallpopupfeatures#' );
		else if(pasteAction == 'cut')
			popupopen( '#application.url.farcry#/navajo/move.cfm?srcObjectId='+copyNodeId+'&destobjectId='+lastSelectedId, '_blank', '#smallpopupfeatures#' );
		}
		else
		{
			alert('#application.rb.getResource("sitetree.messages.noModifyNodePermission@text","You do not have permission to modify the node.")#');
		}
	}
}	



o = new Object();
objectMenu['Preview'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.preview@label','Preview')#";
o.js = "menuOption_Preview()";
o.jsvalidate = "hasPermission( lastSelectedId, '#PermNavView#' );";
o.bShowDisabled = 1;

function menuOption_Preview()
{   
	window.open('#application.url.conjurer#?objectId='+lastSelectedId+"&flushcache=1&showDraft=1");
}


o = new Object();
objectMenu['Preview Draft'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.previewDraft@label','Preview Draft')#";
o.js = "menuOption_PreviewDraft()";
o.jsvalidate = "hasDraft(lastSelectedId);";
o.bShowDisabled = 1;

function hasDraft (objectid)
{
	if(objects[objectid]['BHASDRAFT'])
		{permission = 1;}
	else {permission = 0;}
	
	return permission;
}
function menuOption_PreviewDraft()
{   
	window.open('#application.url.conjurer#?objectId='+objects[lastSelectedId]['DRAFTOBJECTID']+"&flushcache=1&showDraft=1");
}


o = new Object();
objectMenu['Move'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.move@label','Move')#";
o.submenu = "Move";
o.jsvalidate = "((objects[lastSelectedId]['TYPENAME'].toLowerCase()=='#lCase(attributes.nodetype)#' && hasPermission(getParentObject(lastSelectedId)['OBJECTID'], '#PermNavEdit#' ) && countNodes(getParentObject(lastSelectedId)['OBJECTID']) > 1) || (hasPermission(getParentObject(lastSelectedId)['OBJECTID'], '#PermNavEdit#' ) && countObjects(getParentObject(lastSelectedId)['OBJECTID']) > 1))?1:0";

//o.jsvalidate = "(hasPermission(getParentObject(lastSelectedId)['OBJECTID'], '#PermNavEdit#' ) && (countObjects(getParentObject(lastSelectedId)['OBJECTID']) > 1 || countNodes(getParentObject(lastSelectedId)['OBJECTID']) > 1 ))?1:0";
//o.jsvalidate = 1;
o.bShowDisabled = 1;
o.bSeperator = 0;

	moveMenu = new Object();
	moveMenu.menuInfo = new Object();
	moveMenu.menuInfo.name = "MoveMenu";

	o = new Object();
	moveMenu['MoveUp'] = o;
	o.text = "#application.rb.getResource('sitetree.contextmenu.moveup@label','Move Up')#";
	o.js = "menuOption_MoveInternal(\\'up\\');";
	o.jsvalidate = "objectIndex(lastSelectedId)>0||nodeIndex(lastSelectedId)>0";
	o.bShowDisabled = 1;
	
	o = new Object();
	moveMenu['MoveDown'] = o;
	o.text = "#application.rb.getResource('sitetree.contextmenu.moveDown@label','Move Down')#";
	o.js = "menuOption_MoveInternal(\\'down\\');";
	o.jsvalidate = 	"(objectIndex(lastSelectedId)!=-1 && objectIndex(lastSelectedId)+1 < countObjects(getParentObject(lastSelectedId)['OBJECTID'])) || "+
					"(nodeIndex(lastSelectedId)!=-1 && nodeIndex(lastSelectedId)+1 < countNodes(getParentObject(lastSelectedId)['OBJECTID']))";
	o.bShowDisabled = 1;
	o.bSeperator = 0;
	
	o = new Object();
	moveMenu['MoveToTop'] = o;
	o.text = "#application.rb.getResource('sitetree.contextmenu.moveToTop@label','Move To Top')#";
	o.js = "menuOption_MoveInternal(\\'top\\');";
	o.jsvalidate = "objectIndex(lastSelectedId)>0||nodeIndex(lastSelectedId)>0";
	o.bShowDisabled = 1;
	
	o = new Object();
	moveMenu['MoveToBottom'] = o;
	o.text = "#application.rb.getResource('sitetree.contextmenu.moveToBottom@label','Move To Bottom')#";
	o.js = "menuOption_MoveInternal(\\'bottom\\');";
	o.jsvalidate = "(objectIndex(lastSelectedId)!=-1 && objectIndex(lastSelectedId)+1 < countObjects(getParentObject(lastSelectedId)['OBJECTID'])) || "+
					"(nodeIndex(lastSelectedId)!=-1 && nodeIndex(lastSelectedId)+1 < countNodes(getParentObject(lastSelectedId)['OBJECTID']))";
	o.bShowDisabled = 1;
	
	function menuOption_MoveInternal(dir)
	{
		popupopen('#application.url.farcry#/navajo/moveInternal.cfm?direction='+dir+'&objectId='+lastSelectedId, '_blank', '#smallpopupfeatures#');
	}

o = new Object();
objectMenu['Create'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.create@label','Create')#";
o.submenu = "Create";
o.jsvalidate = "((hasPermission( lastSelectedId, '#PermNavCreate#' ) >=0) &&  (objects[lastSelectedId]['TYPENAME'].toLowerCase()=='#lcase(attributes.nodetype)#'))";
o.bShowDisabled = 1;

	createMenu = new Object();
	createMenu.menuInfo = new Object();
	createMenu.menuInfo.name = "CreateMenu";

	
	<!-------*************** OBJECT CREATE MENU OPTIONS HERE **************------->
	
	
	<!--- build types to create in tree --->
	<cfloop from="1" to="#arrayLen(aTypesUseInTree)#" index="index">
		<cfset stType = structNew()>
		<Cfset stType.label = "#aTypesUseInTree[index].typename#">
		<Cfset stType.description = "#aTypesUseInTree[index].description#">
		<Cfset i="#aTypesUseInTree[index].typename#">
		<Cfset stType.typeid = i>
		<cfif i IS attributes.nodetype>
			<cfset i = "dmNavigation">
		</cfif>
		
		<cfset defaultImage = customIcons.Type.default.draft>
		<cfif (StructKeyExists(customIcons.Type, i) AND StructKeyExists(customIcons.Type[i], "draft"))>
			<cfset defaultImage = customIcons.Type[i].draft>
		</cfif>
	
		o = new Object();
		createMenu['create#stType.label#'] = o;
		o.text = "<img align='absmiddle' src='#defaultImage#' height="+zoom+">&nbsp;#stType.description#";
		o.js = "menuOption_CreateFramed(\\'#stType.typeId#\\');";
		o.jsvalidate = 1;
		o.bShowDisabled = "";
		
	</cfloop>

function menuOption_CreateFramed(id)
{
	var strURL = '#application.url.farcry#/conjuror/evocation.cfm?parenttype=#attributes.nodetype#&objectId='+lastSelectedId+'&typename='+id;	
	frameopen(strURL, 'content');
	// set edit tab to active
//	showEditTabs('site',lastSelectedId,'edittabEdit');
}

function menuOption_CreatePopup( id )
{
	popupopen( '#application.url.farcry#/conjuror/evocation.cfm?parenttype=#attributes.nodetype#&objectId='+lastSelectedId+'&typename='+id, 'popupEditFrame', '#smallPopupFeatures#' );
}

o = new Object();
objectMenu['Approve'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.status@label','Status')#";
o.submenu = "Approve";
o.jsvalidate = "(objects[lastSelectedId]['STATUS'] && (objects[lastSelectedId]['TYPENAME'].toLowerCase() == '#lCase(attributes.nodetype)#' || objects[lastSelectedId]['TYPENAME'] == 'dmHTML'))?1:0";
o.bShowDisabled = 1;

	approveMenu = new Object();
	approveMenu.menuInfo = new Object();
	approveMenu.menuInfo.name = "ApproveMenu";

	o = new Object();
	approveMenu['ApproveItem'] = o;
	o.text = "#application.rb.getResource('sitetree.contextmenu.approve@label','Approve')#";
	o.js = "menuOption_Approve(\\'approved\\')";
	o.jsvalidate = "((hasPermission( lastSelectedId, '#PermNavApprove#' )> 0 || (hasPermission(lastSelectedId,'#PermNavApproveOwn#') >0 && objects[lastSelectedId]['ATTR_LASTUPDATEDBY'].toLowerCase() == '#lCase(application.security.getCurrentUserID())#')) && (objects[lastSelectedId]['STATUS'] == 'draft' || objects[lastSelectedId]['STATUS'] == 'pending'))?1:0";
	o.bShowDisabled = 1;
	
	o = new Object();
	approveMenu['ApproveDraft'] = o;
	o.text = "#application.rb.getResource('sitetree.contextmenu.approveDraft@label','Approve Draft')#";
	o.js = "menuOption_Approve(\\'approved\\')";
    o.jsvalidate = "( hasPermission(lastSelectedId, '#PermNavApprove#')>0 && (hasDraft(lastSelectedId) && objects[lastSelectedId]['DRAFTSTATUS'] == 'pending') )?1:0";
	o.bShowDisabled = 1;

	o = new Object();
	approveMenu['ApproveBranch'] = o;
	o.text = "#application.rb.getResource('sitetree.contextmenu.approveBranch@label','Approve Branch')#";
	o.js = "menuOption_ApproveBranch(\\'approved\\')";
	o.jsvalidate = "(hasPermission( lastSelectedId, '#PermNavApprove#' )>0 && (objects[lastSelectedId]['STATUS'] == 'draft' || objects[lastSelectedId]['STATUS'] == 'pending') && objects[lastSelectedId]['TYPENAME'].toLowerCase() == '#lCase(attributes.nodetype)#')?1:0";
	o.bShowDisabled = 1;

	function menuOption_Approve(status) {
		var strURL = "";
		if (objects[lastSelectedId]['BHASDRAFT'] && status.toLowerCase() == 'requestapproval')
			strURL = '#application.url.farcry#/navajo/approve.cfm?objectID='+lastSelectedId+'&draftObjectId='+objects[lastSelectedId]['DRAFTOBJECTID']+'&status='+status+'&requestlivedraft=1';
        else if (objects[lastSelectedId]['BHASDRAFT'] && (status.toLowerCase() == 'approved' || status.toLowerCase() == 'draft'))
            strURL = '#application.url.farcry#/navajo/approve.cfm?objectId='+objects[lastSelectedId]['DRAFTOBJECTID']+'&status='+status;
		else
			strURL = '#application.url.farcry#/navajo/approve.cfm?objectId='+lastSelectedId+'&status='+status;
		
		 frameopen(strURL, 'content');
	}

	function menuOption_ApproveBranch( status ) {
		if( confirm('#application.rb.getResource("sitetree.contextmenu.approvebranch@confirmtext","Are you sure you wish to change the status of all content items in this branch?")#' + status))
			//popupopen( 'approve.cfm?approveBranch=1&objectId='+lastSelectedId+'&status='+status, '_blank', '#smallpopupfeatures#' );
			frameopen( '#application.url.farcry#/navajo/approve.cfm?approveBranch=1&objectId='+lastSelectedId+'&status='+status, 'editFrame' );
	}
	
	o = new Object();
	approveMenu['Request'] = o;
	o.text = "#application.rb.getResource('sitetree.contextmenu.requestApproval@label','Request Approval')#";
	o.js = "menuOption_Approve(\\'requestApproval\\')";
	o.jsvalidate = "(hasPermission( lastSelectedId, '#PermNavRequestApprove#' )>=0 && ((objects[lastSelectedId]['STATUS'] == 'draft') || (objects[lastSelectedId]['DRAFTOBJECTID'] && objects[lastSelectedId]['DRAFTSTATUS']=='draft')) )?1:0";
	o.bShowDisabled = 1;
	o.bSeperator = 0;
	
	o = new Object();
	approveMenu['RequestBranch'] = o;
	o.text = "#application.rb.getResource('sitetree.contextmenu.requestApprovalForBranch@label','Request Approval for Branch')#";
	o.js = "menuOption_ApproveBranch(\\'requestApproval\\')";
	o.jsvalidate = "(hasPermission( lastSelectedId, '#PermNavRequestApprove#' )>=0 && (objects[lastSelectedId]['STATUS'] == 'draft') && objects[lastSelectedId]['TYPENAME'].toLowerCase() == '#lCase(attributes.nodetype)#')?1:0";
	o.bShowDisabled = 1;
	
	o = new Object();
	approveMenu['Decline'] = o;
	o.text = "#application.rb.getResource('sitetree.contextmenu.declineDraft@label','Decline Draft')#";
	o.js = "menuOption_Approve(\\'draft\\')";
    o.jsvalidate = "( hasPermission(lastSelectedId, '#PermNavApprove#')>=0 && (hasDraft(lastSelectedId) && objects[lastSelectedId]['DRAFTSTATUS'] == 'pending') )?1:0";
	o.bShowDisabled = 1;

	o = new Object();
	approveMenu['Cancel'] = o;
	o.text = "#application.rb.getResource('sitetree.contextmenu.sendToDraft@label','Send to Draft')#";
	o.js = "menuOption_Approve(\\'draft\\')";
	o.jsvalidate = "((hasPermission( lastSelectedId, '#PermNavApprove#' )>=0 || (hasPermission(lastSelectedId,'#PermNavApproveOwn#') >=0 && objects[lastSelectedId]['ATTR_LASTUPDATEDBY'].toLowerCase() == '#lCase(application.security.getCurrentUserID())#'))&& !hasDraft(lastSelectedId) && (objects[lastSelectedId]['STATUS'] == 'approved' || objects[lastSelectedId]['STATUS'] == 'pending'))?1:0";
	o.bShowDisabled = 1;
	
	o = new Object();
	approveMenu['CancelBranch'] = o;
	o.text = "#application.rb.getResource('sitetree.contextmenu.sendBranch2Draft@label','Send Branch to Draft')#";
	o.js = "menuOption_ApproveBranch(\\'draft\\')";
	o.jsvalidate = "((hasPermission( lastSelectedId, '#PermNavApprove#' )>=0 || (hasPermission(lastSelectedId,'#PermNavApproveOwn#') >=0 && objects[lastSelectedId]['ATTR_LASTUPDATEDBY'].toLowerCase() == '#lCase(application.security.getCurrentUserID())#')) && (objects[lastSelectedId]['STATUS'] == 'approved' || objects[lastSelectedId]['STATUS'] == 'pending') && objects[lastSelectedId]['TYPENAME'].toLowerCase() == '#lCase(attributes.nodetype)#')?1:0";
	o.bShowDisabled = 1;

	
o = new Object();
objectMenu['Insert'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.insert@label','Insert')#";
o.js = "menuOption_Insert()";
o.jsvalidate = "(contentFrame.insertObjId || contentFrame.insertObjIds || contentFrame.insertHTML)?1:0";
o.bShowDisabled = 1;
o.bSeperator = 0;
function menuOption_Insert()
{
	// get object
	var theNode = objects[ lastSelectedId ];
	var p = contentFrame;
	
	if( p.insertaObjIds ) p.insertaObjIds( aSelectedIds );
	else if( p.insertObjId ) p.insertObjId( lastSelectedId );
	else switch( theNode['TYPENAME'] )
	{
		<cfparam name="application.config.overviewTree.bUseHiResInsert" default="0">
		case "dmImage":
			if (theNode['OPTIMISEDIMAGE'] && theNode['OPTIMISEDIMAGE'].length && #application.config.overviewTree.bUseHiResInsert#)	
			{
			<cfif isDefined("application.config.overviewTree.insertJSdmImageHiRes")>
				p.insertHTML("#evaluate(DE(application.config.overviewTree.insertJSdmImageHiRes))#");
			<cfelse>
 				p.insertHTML("<img alt='"+theNode['ALT']+"' src='#application.url.webroot#/images/"+theNode['OPTIMISEDIMAGE']+"'>");
			</cfif>
				
			}
			else
			{
			<cfif isDefined("application.config.overviewTree.insertJSdmImage")>
				p.insertHTML("#evaluate(DE(application.config.overviewTree.insertJSdmImage))#");
			<cfelse>
 				p.insertHTML( "<img alt='"+theNode['ALT']+"' src='#application.url.webroot#/images/"+theNode['IMAGEFILE']+"'>" );
			</cfif>
			}
			break;
		
		case "dmFile":
			<cfif isDefined("application.config.overviewTree.insertJSdmFile")>
				p.insertHTML("#evaluate(DE(application.config.overviewTree.insertJSdmFile))#");
			<cfelse>
				p.insertHTML( "<a href='#application.url.webroot#/download.cfm?DownloadFile="+lastSelectedId+"' target='_blank'>"+theNode['TITLE']+"</a>" );
			</cfif>
			break;
			
		case "dmFlash":
			<cfif isDefined("application.config.overviewTree.insertJSdmFlash")>
			p.insertHTML("#evaluate(DE(application.config.overviewTree.insertJSdmFlash))#");
			<cfelse>
			p.insertHTML( "<OBJECT classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000' codebase='http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version="+theNode['FLASHVERSION']+"' WIDTH='"+theNode['FLASHWIDTH']+"'  HEIGHT='"+theNode['FLASHHEIGHT']+"'  ALIGN='"+theNode['FLASHALIGN']+"'><PARAM NAME='movie' VALUE='http://#CGI.SERVER_NAME#:#CGI.SERVER_PORT##application.url.webroot#/files/"+theNode['FLASHMOVIE']+"'><PARAM NAME='quality' VALUE='"+theNode['FLASHQUALITY']+"'><PARAM NAME='play' VALUE='"+theNode['FLASHPLAY']+"'><PARAM NAME='menu' VALUE='"+theNode['FLASHMENU']+"'><PARAM NAME='loop' VALUE='"+theNode['FLASHLOOP']+"'><PARAM NAME='FlashVars' VALUE='"+theNode['FLASHPARAMS']+"'><EMBED SRC='http://#CGI.SERVER_NAME#:#CGI.SERVER_PORT#/#application.url.webroot#/files/"+theNode['FLASHMOVIE']+"' QUALITY='"+theNode['FLASHQUALITY']+"' WIDTH='"+theNode['FLASHWIDTH']+"' HEIGHT='"+theNode['FLASHHEIGHT']+"' FLASHVARS='"+theNode['FLASHPARAMS']+"' ALIGN='"+theNode['FLASHALIGN']+"' MENU='"+theNode['FLASHMENU']+"' PLAY='"+theNode['FLASHPLAY']+"' LOOP='"+theNode['FLASHLOOP']+"' TYPE='application/x-shockwave-flash' PLUGINSPAGE='http://www.macromedia.com/go/getflashplayer'></EMBED></OBJECT>" );
			</cfif>
			break;
			
		default:
			<cfif isDefined("application.config.overviewTree.insertJSdmHTML")>
			p.insertHTML("#evaluate(DE(application.config.overviewTree.insertJSdmHTML))#");
			<cfelse>
			p.insertHTML( "<a href='#stOverview['menu']['insert']['dmHTML']#?objectId="+lastSelectedId+"'>"+theNode['TITLE']+"</a>" );
			</cfif>
			break;
	}
} 

o = new Object();
objectMenu['Permissions'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.permissions@label','Permissions')#";
o.js = "menuOption_Permissions()";
o.jsvalidate = "(#iModifyPermissionsState# > -1 && objects[lastSelectedId]['TYPENAME'].toLowerCase()=='#lcase(attributes.nodetype)#')?1:0";
o.bShowDisabled = 1;
o.bSeperator = 0;

function menuOption_Permissions()
{
	frameopen( '#application.url.farcry#/conjuror/invocation.cfm?method=adminPermissions&objectid='+lastSelectedId, 'editFrame' );
}

o = new Object();
objectMenu['Dump'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.properties@label','Properties')#";
o.js = "menuOption_Dump();";
o.jsvalidate = "#iDeveloperState#";
o.bShowDisabled = 0;
o.bSeperator = 0;

function menuOption_Dump()
{
	frameopen('#application.url.farcry#/navajo/dump.cfm?lObjectIds='+aSelectedIds.toString(),'content');
}

o = new Object();
objectMenu['Delete'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.delete@label','Delete')#";
o.js = "menuOption_Delete()"; //  && countObjects(lastSelectedId) <=0  && countNodes(lastSelectedId) <=0
o.jsvalidate = "hasPermission(lastSelectedId, '#PermNavDelete#')";
o.bShowDisabled = 1;
o.bSeperator = 0;

function menuOption_Delete()
{
	// if( confirm('Are you sure you wish to delete this object(s)?') ) popupopen( 'delete.cfm?objectId='+lastSelectedId, '_blank', '#smallpopupfeatures#' );
	if(confirm('#application.rb.getResource("sitetree.contextmenu.delete@confirmtext","Are you sure you wish to delete this content item(s)?")#') )
		frameopen('#application.url.farcry#/navajo/delete.cfm?objectId='+lastSelectedId,'content');
}

o = new Object();
objectMenu['Trash'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.sendToTrash@label','Send to trash')#";
o.js = "menuOption_Trash()"; 
o.jsvalidate = "hasPermission( lastSelectedId, '#PermSendToTrash#' );";
o.bShowDisabled = 0;
o.bSeperator = 0;

function menuOption_Trash()
{
	if( confirm('#application.rb.getResource("sitetree.contextmenu.sendToTrash@confirmtext","Are you sure you wish to send this content item to the trash?")#') ) popupopen( '#application.url.farcry#/navajo/move.cfm?srcObjectId='+lastSelectedId+'&destObjectId=#application.navid.rubbish#', '_blank', '#smallpopupfeatures#' );
}


o = new Object();
objectMenu['EmptyTrash'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.emptyTrash@label','Empty Trash')#";
o.js = "menuOption_EmptyTrash()"; 
o.jsvalidate = "(hasPermission( lastSelectedId, '#PermNavDelete#') > 0 && lastSelectedId == '#application.navid.rubbish#')?1:0";
o.bShowDisabled = 0;
o.bSeperator = 0;

function menuOption_EmptyTrash()
{
	if( confirm('#application.rb.getResource("sitetree.contextmenu.emptyTrash@confirmtext","Are you sure you wish to delete all items in the trash?")#') ) popupopen( '#application.url.farcry#/navajo/treeEmptyTrash.cfm', '_blank', '#smallpopupfeatures#' );
}



o = new Object();
objectMenu['Zoom'] = o;
o.text = "#application.rb.getResource('sitetree.contextmenu.zoom@label','Zoom')#";
o.js = "menuOption_Zoom()"; 
o.jsvalidate = "objects[lastSelectedId]['TYPENAME'].toLowerCase()=='#lcase(attributes.nodetype)#'?1:0";
o.bShowDisabled = 0;
o.bSeperator = 0;

function menuOption_Zoom()
{
	<cfif isDefined("URL.rootobjectID") AND NOT URL.rootobjectID IS rootobjectID>
		
		if (lastSelectedId != '#URL.rootobjectID#')
			location.href='#CGI.SCRIPT_NAME#?rootObjectId='+lastSelectedId;
		else
			location.href='#CGI.SCRIPT_NAME#';	
	<cfelse>
		if (lastSelectedId == '#rootObjectID#')
			location.href='#CGI.SCRIPT_NAME#';
		else
			location.href='#CGI.SCRIPT_NAME#?rootObjectId='+lastSelectedId;
				
	</cfif>	
}

</cfif>

function generateMenu( data, bIsSub )
{
	var menuData;
	
	if( bIsSub ) menuData = beginSubMenu(data.menuInfo.name);
		else menuData = beginMainMenu(data.menuInfo.name);
	
	for( var menuItemId in data )
	{
		if( menuItemId != 'menuInfo' )
		{
			var o = data[ menuItemId ];
			if( o.submenu )
			menuData += menuItemPopup( menuItemId, o.text, o.submenu, o.bShowDisabled );
				else
			menuData += menuItemClickable( menuItemId, o.text, o.js, o.bShowDisabled );
			
			if( o.bSeperator ) menuData += menuItemSeperator();
		}
	}
	menuData += endMenu();
	//alert(menuData);
	pm = document.getElementById("popupMenus");
	pm.innerHTML += menuData;
	//document.all.popupMenus.innerHTML += menuData;
}

generateMenu( objectMenu, 0 );
<cfif not IsDefined("url.insertonly")>
generateMenu( moveMenu  , 1 );
generateMenu( createMenu, 1 );
generateMenu( approveMenu, 1 );
</cfif>

function objectCopy( obj )
{
	var newObj = new Object();
	
	newObj.x = obj.x;
	newObj.y = obj.y;
	newObj.ctrlKey = obj.ctrlKey;
	
	return newObj;
}

function beginMainMenu( id )
{
	return "<div id='"+id+"' onClick='event.cancelBubble=true' class='menudiv'>\n<div id='"+id+"_header' class='menuItemHeader'>hello</div>\n";
}

function beginSubMenu( id )
{
	return "<div id='"+id+"' onClick='event.cancelBubble=true'  class='menudiv'>";
}

function endMenu()
{
	return "</div>";
}

function menuItemClickable( id, text, onclick, bShowDisabled )
{
	return	'<div id="'+id+'Item" class="menuItem" onclick="heldEvent=objectCopy(event);flutter(this,\''+onclick+'\');" onMouseOver="fpo(this)" onMouseOut="fpf(this);">'+
			'<table width="100%" class="menuItem" cellspacing="0"><tr><td width=100%><span class="menuText">'+text+'</span></td></table></div>'+
			'<div id="'+id+'_disabled" class="menuItemDisabled">'+
			'<table width=100% class="menuItemDisabled" cellspacing="0"><tr><td width=100%><span class="menuText">'+text+'</span></td></table></div>';
}

function menuItemPopup( id, text, popup, bShowDisabled )
{
	return	'<div id="'+id+'Item" class="menuItem" onMouseOver="fpo(this);popupMenu(\''+popup+'\');" onMouseOut="fpf(this);">\n'+
			'<table width="100%" class="menuItem" cellspacing="0"><tr><td width=100%><span class="menuText">'+text+'...</span></td><td><img align=right src="'+subnavmore.src+'" width="#attributes.zoom#"></td></tr></table></div>'+
			'<div id="'+id+'_disabled" class="menuItemDisabled">\n'+
			'<table width="100%" class="menuItemDisabled" cellspacing="0"><tr><td width=100%><span class="menuText">'+text+'...</span></td><td><img align=right src="'+subnavmoreDisabled.src+'" width="#attributes.zoom#"></td></tr></table></div>';
}

function menuItemSeperator()
{
	return "<hr>";
}

function popupMenu( id )
{
	hideSubMenus();

	var data = eval(id.toLowerCase()+"Menu");
	
	for( var menuItemId in data )
	{
		if( menuItemId != 'menuInfo' )
		{
			var o = data[ menuItemId ];
			
			var menuOptionEnabledDiv = document.getElementById( menuItemId+"Item" );
			var menuOptionDisabledDiv = document.getElementById( menuItemId+"_disabled" );

			if( eval(o.jsvalidate)>0 )
			{
				// make vis
				menuOptionEnabledDiv.style.display = "block";
				menuOptionDisabledDiv.style.display = "none";
			}
			else
			{
				// make invis
				menuOptionEnabledDiv.style.display = "none";
				menuOptionDisabledDiv.style.display = "block";
			}
		}
	}
	
	var menuObject = document.getElementById(id+"Menu");
	var boundingRect = myGetBoundingRect(document.getElementById(id+"Item"));
	
	menuObject.style.left=boundingRect.right+document.body.scrollLeft-4;
	menuObject.style.top=boundingRect.top+document.body.scrollTop;
	
	menuObject.style.visibility="visible";
	
	divOnScreen( id+"Menu" );
}

function popupObjectMenu(e)
{
	// do normal context menu if shift key is down
	if ( e.shiftKey ) return;
	
	// cancel the normal context menu
	e.returnValue = false;
	
	// run through the object menu and run enabled/disabled checks
	var data = objectMenu;
	for( var menuItemId in data )
	{
		if( menuItemId != 'menuInfo' )
		{
			var o = data[menuItemId];
			var menuOptionEnabledDiv = document.getElementById( menuItemId+"Item" );
			var menuOptionDisabledDiv = document.getElementById( menuItemId+"_disabled" );
						
			if( eval(o.jsvalidate)>0 )
			{
				// make vis
				menuOptionEnabledDiv.style.display = "block";
				menuOptionDisabledDiv.style.display = "none";
			}
			else
			{
				// make invis
				menuOptionEnabledDiv.style.display = "none";
				menuOptionDisabledDiv.style.display = "block";
			}
		}
	}

	// set the title
	var title = getObjectTitle( lastSelectedId );
	if( title.length > 16 ) title=title.substr( 0, 15 )+"...";
	document.getElementById( "ObjectMenu_header" ).innerHTML = title;

	var objectMenuDiv = document.getElementById( "ObjectMenu" );
	
	var rightedge=ie5? document.body.clientWidth-event.clientX : window.innerWidth-e.clientX
	var bottomedge=ie5? document.body.clientHeight-event.clientY : window.innerHeight-e.clientY
		
	
	//if the horizontal distance isn't enough to accomodate the width of the context menu
//commented out horizontal offset 	if (rightedge<objectMenuDiv.offsetWidth)
	//move the horizontal position of the menu to the left by it's width
//commented out horizontal offset		objectMenuDiv.style.left=ie5? document.body.scrollLeft+event.clientX-objectMenuDiv.offsetWidth : window.pageXOffset+e.clientX-objectMenuDiv.offsetWidth
//commented out horizontal offset	else
	//position the horizontal position of the menu where the mouse was clicked
//commented out horizontal offset		objectMenuDiv.style.left=ie5? document.body.scrollLeft+event.clientX : window.pageXOffset+e.clientX

	//same concept with the vertical position
	if (bottomedge<objectMenuDiv.offsetHeight)
		objectMenuDiv.style.top=ie5? document.body.scrollTop+event.clientY-objectMenuDiv.offsetHeight : window.pageYOffset+e.clientY-objectMenuDiv.offsetHeight
	else
		objectMenuDiv.style.top=ie5? document.body.scrollTop+event.clientY : window.pageYOffset+e.clientY

	objectMenuDiv.style.visibility = "visible";
	
	//window.event.cancelBubble = true;
	
	divOnScreen( "daemon_object_popupMenu_header" );
	
}

function divOnScreen( divId )
{
	var theDiv = document.getElementById( divId );
	if( theDiv )
	{
		var boundingRect = myGetBoundingRect( theDiv );
		
		if( boundingRect.bottom > document.body.clientHeight )
		{
			var st = theDiv.style;
			st.top = parseInt( st.top ) - (boundingRect.bottom - document.body.clientHeight);
		}
		
		if( boundingRect.right > document.body.clientWidth )
		{
			var st = theDiv.style;
			st.left = parseInt( st.left ) - (boundingRect.right - document.body.clientWidth);
		}
	}
}

function myGetBoundingRect( theDiv )
{
	var boundingRect = new Object();
	
	boundingRect['left'] = -document.body.scrollLeft;
	boundingRect['top'] = -document.body.scrollTop;
	boundingRect['right'] = theDiv.offsetWidth-document.body.scrollLeft;
	boundingRect['bottom'] = theDiv.offsetHeight-document.body.scrollTop;

	while( theDiv )
	{
		
		
		boundingRect['left'] += theDiv.offsetLeft;
		boundingRect['top'] += theDiv.offsetTop;
		boundingRect['right'] += theDiv.offsetLeft;
		boundingRect['bottom'] += theDiv.offsetTop;
		
		theDiv=theDiv.offsetParent;
	}
	
	return boundingRect;
}

<!--- flip menu on/off --->
function fpo( el )  { el.style.backgroundColor='#menuOnColor#'; }
function fpf( el ) { el.style.backgroundColor='#menuOffColor#'; }

function flutter( el, action )
{
	flutterState=-1;
	flutterLength=8;
	flutterSpeed=60;
	flutterElement=el;
	flutterAction=action;
	
	flutterTimeout();
}

function flutterTimeout()
{
	flutterLength--;
	flutterState=-flutterState;

	if( flutterLength==0 )
	{
		documentClick();
		setTimeout("flutterDoAction()", 20 );
	}
	else
	{
		if( flutterState==-1 ) flutterElement.style.backgroundColor='#menuFlutterOnColor#';
		                  else flutterElement.style.backgroundColor='#menuFlutterOffColor#';
		
		setTimeout("flutterTimeout()", flutterSpeed);
	}
}

function flutterDoAction() { eval( flutterAction ); }

function documentClick()
{
	var objectMenuDiv = document.getElementById( "ObjectMenu" );
	objectMenuDiv.style.visibility = "hidden";
	hideSubMenus();
	<cfif not IsDefined("url.insertonly")>
	secureTabs();
	</cfif>
}

function secureTabs()
{
	//add more checks here as necessary
	if ((hasPermission( lastSelectedId, '#PermNavEdit#') > 0) && parent.document.getElementById('siteEditEdit')) 
		parent.document.getElementById('siteEditEdit').style.display = 'inline';
	else if (parent.document.getElementById('siteEditEdit'))	
		parent.document.getElementById('siteEditEdit').style.display = 'none';
	//This will display the container tab if we are dealing with a dmHTML object	
	
	if (objects[lastSelectedId] && objects[lastSelectedId]['TYPENAME'].toLowerCase()=='dmhtml')
	{
		
		if ((hasPermission(lastSelectedId,'#permContainerManagement#') > 0) && parent.document.getElementById('siteEditRules'))
			parent.document.getElementById('siteEditRules').style.display = 'inline';
		else if(parent.document.getElementById('siteEditRules'))	
			parent.document.getElementById('siteEditRules').style.display = 'none';		
	}	
	
	else if (parent.document.getElementById('siteEditRules'))
		parent.document.getElementById('siteEditRules').style.display = 'none';		
		
		
		
}		

function hideSubMenus()
{
	for( var item in objectMenu )
	{
	 	var temp = objectMenu[item].submenu;
		
		if( temp )
		{
			var theMenuDiv = document.getElementById( temp+"Menu" );
			if( theMenuDiv ) theMenuDiv.style.visibility = "hidden";
		}
	}
}

function showEditTabs (tabType, objectid, activeTab)
{
	var elList, i;
	var curList, newList;
   // Set current active link to non active
 
  elList = parent.document.getElementsByTagName("A");
  for (i = 0; i < elList.length; i++)

    // Check if the id contains the tabtype and make tab visible
	
	if (elList[i].id)
	{
		
		if (elList[i].id.indexOf(tabType)!= -1) 
		{
		    elList[i].style.visibility = 'visible'; 
			elList[i].style.zindex = 1; 
			
			// break href into 2 bits, one the file and one the object parameter
			  newList = new Array();
			  curList = elList[i].href.split("=");
			  elList[i].href = curList[0] + "=" + objectid; 
			  
			// set tab to active
			if(elList[i].href.indexOf(activeTab)!=-1)
			{
				elList[i].className = "activesubtab";}
				else {
				elList[i].className = "subtab";
			}
		}
	}
}

document.body.onclick = documentClick;
</script>

<style type="text/css">
##idServer { 
	position:relative; 
	width: 0px; 
	height: 0px; 
	/*display:none;*/
}
</style>

<iframe width="100" height="1" name="idServer" id="idServer" frameborder="0" framespacing="0" marginwidth="0" marginheight="0" src="#application.url.farcry#/admin/blank.cfm">
	
</iframe>

<!--- now go through each unparented node and generate a div for it --->
<cfloop index="objId" list="#rootObjectId#">
	<div id="#objId#_root">
	</div>
<script type="text/javascript">
renderObjectToDiv( '#objId#', '#objId#_root' );
toggleObject( '#objId#' );
</script>
</cfloop>
</cfoutput>

<cfsetting enablecfoutputonly="No">