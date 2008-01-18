<cfsetting enablecfoutputonly="No">

<cfoutput>

<LINK href="#application.url.farcry#/css/overviewFrame.css" rel="stylesheet" type="text/css">
<style type="text/css">
body {background:##fff}
</style>
<div id="tree" style="position:relative;">
</cfoutput>


<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">

<cfparam name="attributes.zoom" default="16">
<cfif isDefined("url.zoom")><cfset attributes.zoom=url.zoom></cfif>
<cfset fontZoom = int(attributes.zoom/16*9)>
<cfset menuZoom = int(attributes.zoom/16*120)>

<cfparam name="application.navid.rubbish" default="">

 
<cfscript>
nimages = "#application.url.farcry#/images/treeImages";
cimages = "#nimages#/customIcons";
customIcons = StructNew();


customIcons.Type = StructNew();

customIcons.Type = StructNew();
customIcons.Type.default = StructNew();
customIcons.Type.default.draft ="defaultObjectDraft";
customIcons.Type.default.pending ="defaultObjectPending";
customIcons.Type.default.approved ="defaultObjectApproved";
customIcons.Type.default.livedraft ="defaultObjectLiveDraft";
customIcons.Type.default.livependingdraft ="defaultObjectLivePendingDraft";

customIcons.Type.root = StructNew();
customIcons.Type.root.draft = "webserver";
customIcons.Type.root.pending = "webserver";
customIcons.Type.root.approved = "webserver";

if( StructKeyExists( application.types, "dmNavigation" ) )
{
	customIcons.Type.dmnavigation = StructNew();
	customIcons.Type.dmnavigation.draft ="navDraftImg";
	customIcons.Type.dmnavigation.pending ="navPending";
	customIcons.Type.dmnavigation.approved ="navApprovedImg";
}

</cfscript>

 

<cfscript>
	//Permissions
	iSecurityManagementState = application.security.checkPermission(permission="SecurityManagement");	
	iRootNodeManagement = application.security.checkPermission(permission="RootNodeManagement");	
	iModifyPermissionsState = application.security.checkPermission(permission="ModifyPermissions");	
	iDeveloperState = application.security.checkPermission(permission="developer");	
	bPermTrash = application.security.checkPermission(permission="TreeSendToTrash");	
	
	menuOnColor="##dddddd";
	menuOffColor="white";
	menuFlutterOnColor="black";
	menuFlutterOffColor="##cccccc";
	smallPopupFeatures="width=200,height=200,menubar=no,toolbars=no,";
	//customIcons = attributes.customIcons;

</cfscript>

<cfoutput>
<script>
	var ns6=document.getElementById&&!document.all; //test for ns6
	var ie5=document.getElementById && document.all;//test for ie5

	// serverGet() function when it's done
	function serverPut(objID){
		// the URL of the script on the server to run
		strURL = "#application.url.farcry#/navajo/updateTreeData1.cfm";
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
			document.getElementById("idServer").contentDocument.location = strURL;

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


<!--- find all the root nodes --->
<cfif isDefined("URL.rootObjectID")>
	<cfset rootObjectID = URL.rootObjectID>
<cfelseif isDefined("arguments.rootobjectid")>
	<cfset rootobjectid = arguments.rootobjectid>	
<cfelse>
	<cfscript>
		qrootObjectID = application.factory.oTree.getRootNode(typename=arguments.typename,dsn=arguments.dsn);
		rootObjectID = qrootObjectID.objectID;
	</cfscript>
</cfif>

<cfoutput>
	   <br>
</cfoutput>
<!--- get all open nodes + root nodes --->
<cfparam name="cookie.nodestatev2" default="">
<cfset cookie.nodestatev2=listappend(cookie.nodestatev2,"0")>

<cfscript>
	oCat = createObject("component","#application.packagepath#.farcry.category");
	jscode = oCat.getTreeData(objectid=rootObjectID,dsn=arguments.dsn);
</cfscript>
	

<cfset imageRoot = "nimages">


<!-------- PERMISSIONS ------------>
<cfoutput>
	<script>
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
			
			return 1;
		}
	</script>
</cfoutput>

<cfscript>
	nimages = "#application.url.farcry#/images/treeImages";
	cimages = "#nimages#/customIcons";
</cfscript>

<cfoutput>
<!--- initial javascript code for tree --->
<script>#jscode#</script>

<div id="popupMenus" style="position:absolute;"></div>

<script>
var localWin = window;
var editFlag = false;

function popupopen( strURL,b,c )
{
	/*var w;

	if( b && c ) w = window.open( 'javascript:document.write(" Loading....");', b, c );
	else if( b ) w = window.open( 'javascript:document.write(" Loading....");', b );
	else w = window.open( 'javascript:document.write(" Loading....");' );
	
	//w.moveTo( window.screenLeft+200, window.screenTop+50 );
	w.focus();

	w.location=a;*/
	if( document.all )
		document.idServer.location = strURL;
	else if( document.getElementById )
		document.getElementById("idServer").contentDocument.location = strURL;
	
}

function frameopen( a,b )
{
	if( parent[b] && !heldEvent.ctrlKey )
	{
		if( b == 'editFrame' && parent[b].location.href.toLowerCase().indexOf( "edit.cfm" ) != -1 )
		{
			alert("You are currently editing an object.\nPlease complete or cancel editing before doing anything else.\n" );
		}
		else
		{
			//parent[b].document.write(" Loading....");
			parent[b].document.location=a;
		}
	}
	else popupopen( a,b+"_popup" );
}

var cookieName = "nodeStatev2=";
var rootIds = '#rootObjectId#';

var lastSelectedId = '';
var aSelectedIds = new Array();
var zoom=#attributes.zoom#;


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
images = new Image(16,16);images.src = "#cimages#/images.gif";
floppyDisk = new Image(16,16);floppyDisk.src="#cimages#/floppyDisk.gif";
test = new Image(16,16);test.src = "#cimages#/test.gif";
navPending = new Image(16,16);navPending.src = "#cimages#/NavPending.gif";


<cfwddx action="CFML2JS" input="#customIcons.type#" toplevelvariable="customIconMapType">

function renderObjectToDiv( objId, divId )
{
	var el = document.getElementById( divId );
	var elData=renderObject( objId );
	el.innerHTML = elData;
}

var aSelected = new Array()
<cfloop from="1" to="#listLen(arguments.lSelectedCategories)#" index="i">
	aSelected[#i#-1] = "#listGetAt(arguments.lSelectedCategories,i)#";
</cfloop>
//alert(aSelected.length);

function updateCategories(bChecked,objectId)
{
	if(bChecked)
	{
		if(!aSelected.length)
			aSelected[0] = objectId;
		else
			aSelected.push(objectId);	
		//return;	
	}
	else		
	{
		for(var i = 0;i < aSelected.length;i++)
		{
			if (aSelected[i] == objectId)
			{
				aSelected.splice(i,1);
				break;
			} 	
		}	
		//return;
	}	
	return;
}



function renderObject( objId )
{
	var thisObject = objects[objId];
	var bCheckBox = #arguments.bshowcheckbox#;
	var lSelected = aSelected.join();
	if( !thisObject ) return "";
	if (lSelected.indexOf(objId) > -1)
	{
		checked = 'checked';
	}	
	else
		checked = '';	
	
	if(objId != '#rootobjectid#' && bCheckBox)
	{
		checkboxhtml = '<input style="width:auto" onClick=\"updateCategories(this.checked,\''+objId+'\')\" type=\"checkbox\" name=\"categoryid\" value=\"'+objId + '\" ' + checked +'>';
	}else
		checkboxhtml = '';	
	
	var elData="";
	
	if( rootIds.indexOf(objId)!=-1) elData += "<table class=tableNode><tr><td>";
	else
	{   
		var parent = getParentObject( objId );
		var parentParent = getParentObject( parent['OBJECTID'] );
		if( parentParent['OBJECTID'] 
			&& (nodeIndex(parent['OBJECTID'])!=-1 && nodeIndex(parent['OBJECTID'])!=countNodes(parentParent['OBJECTID'])-1)
			|| (objectIndex(parent['OBJECTID'])!=-1 && objectIndex(parent['OBJECTID'])!=countChildren(parentParent['OBJECTID'])-1) &&  countNodes(parent['OBJECTID']) > 1  )
			elData += "<table class='tableNode'><tr><td style='background-image: url(\""+c.src+"\");background-repeat : repeat-y;'><img src='"+s.src+"' width="+zoom+" height="+zoom+"></td><td>";
		else
			elData += "<table class='tableNode'><tr><td style='background-image: url(\"" + s.src +"\");background-repeat : repeat-y;'><img src='"+s.src+"' width="+zoom+" height="+zoom+"></td><td>";
	}
	
	var jsHighlight=' onclick="highlightObjectClick(\''+objId+'\',event)" ';
	
	var contextMenu = ' oncontextmenu="if(!event.ctrlKey)highlightObjectClick(\''+objId+'\',event);popupObjectMenu(event);return false;" ';
	var drag = " ondragstart='\startDrag(\""+objId+"\",\""+thisObject['TYPENAME']+"\")' ondrop='dropDrag(\""+objId+"\")' ";
	if( thisObject['TYPENAME']=="dmNavigation" )
		drag += " ondragover='dragOver()'";	
	else if( thisObject['TYPENAME']=="dmHTML")drag += " ondragover='if(dragTypeId!=\"dmNavigation\") dragOver()' ";
		
	
	elData+='<table class=\"tableNoded\" '+contextMenu+'>\n<tr><td class=iconText>'+getToggleImage(objId)+
				'<div id=\"non'+jsHighlight+'\" style="display:inline" '+drag+jsHighlight+'>'+getTypeImage(objId)+'</div>\n</td>'+
				'<td valign=middle class=iconText>'+ 
				'\n<div id="'+objId+'_text" '+jsHighlight+'>'+checkboxhtml+getObjectTitle(objId)+
				'</div>\n</td></tr>\n</table>'+
				'<div id="'+objId+'" style="display:none;">\n</div>\n';
	
	elData += "</td></tr>\n</table>";
	
	return elData;
}

var dragObjectId='';
var dragTypeId='';

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

function dropDrag( aDropObjectId )
{	
	<!--- eliminate default action of ondrop so we can customize: --->
	if( dragObjectId != aDropObjectId && confirm('Are you sure you wish to move this object?'))
	{
		popupopen('#application.url.farcry#/navajo/keywords/move.cfm?rootobjectid=#rootobjectid#&srcObjectId='+dragObjectId+'&destObjectId='+aDropObjectId,'NavajoExt','#smallPopupFeatures#');
	}
	
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
	
	if( !thisObject || !thisObject['TITLE'] ) return "undefined";
	
	return thisObject['TITLE'];
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
	
	return "<img id='"+objId+"_toggle' src='"+eval( 'toggle'+direction+toggle+'.src' )+"' width="+zoom+" height="+zoom+" "+scripting+">";
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

function updateTree(src,dest,srcobjid)
{	//alert('src parend is ' + src + ' dest parent is ' + dest);
		
	srcParent = getParentObject(src);
		
	
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
		
	if(objects[dest])
	{		
		parentId = getParentObject(dest)['OBJECTID'];
		toggleObject(dest);
		toggleObject(dest);
		downloadRender(dest);	
	}	
	//getObjectDataAndRender(srcParent['OBJECTID']);
	downloadRender(srcParent['OBJECTID']);

}

function getTypeImage( objId )
{
	var thisObject = objects[objId];
	
	var tp = thisObject['TYPENAME'].toLowerCase();
	
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
	
	var alt = "Current Status: "+thisObject['STATUS']+"\nCreated By: "+thisObject['ATTR_CREATEDBY']+" on "+thisObject['ATTR_DATETIMECREATED']+
			"\nLast Updated By: "+thisObject['ATTR_LASTUPDATEDBY']+" on "+thisObject['ATTR_DATETIMELASTUPDATED'];
			
	
	 return "<img src='"+eval(cm+'.src')+"' width="+zoom+" height="+zoom+" alt='"+alt+"'>"; 
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

function getParentObject( objId )
{
	var theNode = objects[objId];
	
	if( !theNode ) return '0';
	
	<!--- if this is a nav node search aNavChild else search aObjectIds --->
	searchKey="AOBJECTIDS";
	
	if( theNode['TYPENAME']=='dmNavigation' ) searchKey="ANAVCHILD";
	
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
	 <!--- if( !hasChildren(objId) ) return;  --->
	 
	var toggleImageEl = document.getElementById( objId+"_toggle" );
	toggleImageEl.src = swapToggleImage( toggleImageEl.src ); 
		
	var el = document.getElementById( objId );
	
	if( el.style.display=='none' || el.style.display=='' )
	{
		el.innerHTML = "<img src='"+loading.src+"' width="+(zoom-8)+" height="+(zoom-8)+"><span class=iconText> Loading...</span>";
		
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
			{downloadRender( objId );}
		else 
		{
			downloadRender( objId );
		
		}
				

		storeState( objId, 1 );
		el.style.display = "inline";
	}
	else
	{
		storeState( objId, 0 );
		el.style.display = "none";
		if(ns6)
			el.innerHTML='';
	}
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
		<!--- this is a gay arse way of reloading the window, because of some bug --->
		<!--- in windows causing window.reload to crash --->
		window.location.href = "#cgi.script_name#?i="+(new Date()).getTime()+"&rootObjectID=#rootobjectID#";
	}
}

function downloadDone( s )
{	var objectId = eval(s);
	var parentId = getParentObject(objectId)['OBJECTID'];
	toggleObject(parentId);
	toggleObject(parentId);
	//toggleObject(objectId);
	
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
		if (parent.cateditframe)
		{
			if(parent['cateditframe'].document.location.href.indexOf(id) < 0)
			{
				// load overview page
				parent['cateditframe'].document.location = "#application.url.farcry#/navajo/keywords/overview.cfm?objectid=" + id;
				// make tabs visible in edit frame
				//showEditTabs('site',id,'edittabOverview');
				// change title in edit frame
			}
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
		theDiv.style.backgroundColor="##aaaaaa";
		if( !isSelected(id) )
		{
			aSelectedIds[aSelectedIds.length]=id;
			lastSelectedId = id;
		}
	}


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

<!--- ***  MENU DATA *** --->
objectMenu = new Object();
objectMenu.menuInfo = new Object();
objectMenu.menuInfo.name = "ObjectMenu";

/*o = new Object();
objectMenu['Edit'] = o;
o.text = "Edit";
o.js = "menuOption_Edit();";
o.jsvalidate = "(objects[lastSelectedId]['OBJECTID'] != '#rootobjectid#')?1:0";
o.bShowDisabled = "1";

function menuOption_Edit()
{
	// open edit page in edit frame
	frameopen( '../edittabEdit.cfm?objectId='+lastSelectedId, 'editFrame' );
	// set edit tab to active
	showEditTabs('site',lastSelectedId,'edittabEdit');
	
}*/

o = new Object();
objectMenu['Insert'] = o;
o.text = "#application.adminBundle[session.dmProfile.locale].insert#";
o.js = "menuOption_Insert()";
o.jsvalidate = "1";
o.bShowDisabled = 1;

function menuOption_Insert()
{   
	var nodename = prompt("Please enter new category name");
	if (nodename)
		frameopen( 'insert.cfm?objectname='+encodeURI(nodename)+'&parentobjectId='+lastSelectedId, 'editFrame' ); 

}

	
		
function menuOption_CreateFramed( id )
{
	frameopen( 'createObject.cfm?objectId='+lastSelectedId+'&typename='+id, 'editFrame' );
	// set edit tab to active
	showEditTabs('site',lastSelectedId,'edittabEdit');
}

function menuOption_CreatePopup( id )
{
	popupopen( 'createObject.cfm?objectId='+lastSelectedId+'&typename='+id, 'popupEditFrame', '#smallPopupFeatures#' );
}


o = new Object();
objectMenu['Delete'] = o;
o.text = "#application.adminBundle[session.dmProfile.locale].delete#";
o.js = "menuOption_Delete()"; //  && countObjects(lastSelectedId) <=0  && countNodes(lastSelectedId) <=0
o.jsvalidate = "(objects[lastSelectedId]['OBJECTID'] != '#rootobjectid#')?1:0";
o.bShowDisabled = 1;
o.bSeperator = 0;

function menuOption_Delete()
{
	
	if( confirm('Are you sure you wish to delete this object(s)?') )
		frameopen('#application.url.farcry#/navajo/keywords/delete.cfm?objectId='+lastSelectedId,'cateditframe');
}

o = new Object();
objectMenu['Move'] = o;
o.text = "#application.adminBundle[session.dmProfile.locale].move#";
o.submenu = "Move";
o.jsvalidate = 1;

o.bShowDisabled = 1;
o.bSeperator = 0;

	moveMenu = new Object();
	moveMenu.menuInfo = new Object();
	moveMenu.menuInfo.name = "MoveMenu";

	o = new Object();
	moveMenu['MoveUp'] = o;
	o.text = "#application.adminBundle[session.dmProfile.locale].moveUp#";
	o.js = "menuOption_MoveInternal(\\'up\\');";
	o.jsvalidate = "objectIndex(lastSelectedId)>0||nodeIndex(lastSelectedId)>0";
	o.bShowDisabled = 1;
	
	o = new Object();
	moveMenu['MoveDown'] = o;
	o.text = "#application.adminBundle[session.dmProfile.locale].moveDown#";
	o.js = "menuOption_MoveInternal(\\'down\\');";
	o.jsvalidate = 	"(objectIndex(lastSelectedId)!=-1 && objectIndex(lastSelectedId)+1 < countObjects(getParentObject(lastSelectedId)['OBJECTID'])) || "+
					"(nodeIndex(lastSelectedId)!=-1 && nodeIndex(lastSelectedId)+1 < countNodes(getParentObject(lastSelectedId)['OBJECTID']))";
	o.bShowDisabled = 1;
	o.bSeperator = 0;
	
	o = new Object();
	moveMenu['MoveToTop'] = o;
	o.text = "#application.adminBundle[session.dmProfile.locale].moveToTop#";
	o.js = "menuOption_MoveInternal(\\'top\\');";
	o.jsvalidate = "objectIndex(lastSelectedId)>0||nodeIndex(lastSelectedId)>0";
	o.bShowDisabled = 1;
	
	o = new Object();
	moveMenu['MoveToBottom'] = o;
	o.text = "#application.adminBundle[session.dmProfile.locale].moveToBottom#";
	o.js = "menuOption_MoveInternal(\\'bottom\\');";
	o.jsvalidate = "(objectIndex(lastSelectedId)!=-1 && objectIndex(lastSelectedId)+1 < countObjects(getParentObject(lastSelectedId)['OBJECTID'])) || "+
					"(nodeIndex(lastSelectedId)!=-1 && nodeIndex(lastSelectedId)+1 < countNodes(getParentObject(lastSelectedId)['OBJECTID']))";
	o.bShowDisabled = 1;
	
	function menuOption_MoveInternal( dir )
	{
		popupopen( '#application.url.webtop#/navajo/keywords/moveinternal.cfm?direction='+dir+'&objectId='+lastSelectedId, '_blank', '#smallpopupfeatures#' );
	}



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
	pm = document.getElementById("popupMenus");
	pm.innerHTML += menuData;

}

<cfif NOT arguments.bShowCheckBox>
generateMenu( objectMenu, 0 );
generateMenu( moveMenu  , 1 );
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
			'<table width=100% class="menuItem"><tr><td width=100%><nobr class="menuText">'+text+'</nobr></td></table></div>'+
			'<div id="'+id+'_disabled" class="menuItemDisabled">'+
			'<table width=100% class="menuItemDisabled"><tr><td width=100%><nobr class="menuText">'+text+'</nobr></td></table></div>';
}

function menuItemPopup( id, text, popup, bShowDisabled )
{
	return	'<div id="'+id+'Item" class="menuItem" onMouseOver="fpo(this);popupMenu(\''+popup+'\');" onMouseOut="fpf(this);">\n'+
			'<table width=100% class="menuItem"><tr><td width=100%><nobr class="menuText">'+text+'...</nobr></td><Td><img align=right src="'+subnavmore.src+'" width="#attributes.zoom#"></td></tr></table></div>'+
			'<div id="'+id+'_disabled" class="menuItemDisabled">\n'+
			'<table width=100% class="menuItemDisabled"><tr><td width=100%><nobr class="menuText">'+text+'...</nobr></td><Td><img align=right src="'+subnavmoreDisabled.src+'" width="#attributes.zoom#"></td></tr></table></div>';
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
		//alert(menuItemId);	
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

	// set the title
	var title = getObjectTitle( lastSelectedId );
	if( title.length > 16 ) title=title.substr( 0, 15 )+"...";
	document.getElementById( "ObjectMenu_header" ).innerHTML = title;

	var objectMenuDiv = document.getElementById( "ObjectMenu" );
	
	var rightedge=ie5? document.body.clientWidth-event.clientX : window.innerWidth-e.clientX
	var bottomedge=ie5? document.body.clientHeight-event.clientY : window.innerHeight-e.clientY
		
	
	//if the horizontal distance isn't enough to accomodate the width of the context menu
	if (rightedge<objectMenuDiv.offsetWidth)
	//move the horizontal position of the menu to the left by it's width
		objectMenuDiv.style.left=ie5? document.body.scrollLeft+event.clientX-objectMenuDiv.offsetWidth : window.pageXOffset+e.clientX-objectMenuDiv.offsetWidth
	else
	//position the horizontal position of the menu where the mouse was clicked
		objectMenuDiv.style.left=ie5? document.body.scrollLeft+event.clientX : window.pageXOffset+e.clientX

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
	<cfif NOT arguments.bshowCheckBox>
	var objectMenuDiv = document.getElementById( "ObjectMenu" );
	if(objectMenuDiv)
	
	objectMenuDiv.style.visibility = "hidden";
	hideSubMenus();
	<cfelse>
	return true;
	</cfif>
	
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
<STYLE TYPE="text/css">
		##idServer { 
			position:relative; 
			width: 0px; 
			height: 0px; 
		}
</STYLE>

<IFRAME WIDTH="100" HEIGHT="1" NAME="idServer" ID="idServer" 
	 FRAMEBORDER="0" FRAMESPACING="0" MARGINWIDTH="0" MARGINHEIGHT="0" SRC="null">
		<ILAYER NAME="idServer" WIDTH="400" HEIGHT="100" VISIBILITY="Hide" 
		 ID="idServer">
		<P>This page uses a hidden frame and requires either Microsoft 
		Internet Explorer v4.0 (or higher) or Netscape Navigator v4.0 (or 
		higher.)</P>
		</ILAYER>
</IFRAME>

<!--- now go through each unparented node and generate a div for it --->

<cfloop index="objId" list="#rootObjectId#">
	<div id="#objId#_root">
	</div>
	<script>
	renderObjectToDiv( '#objId#', '#objId#_root' );
	toggleObject( '#objId#' );
	</script>
</cfloop>

<cfif NOT arguments.bExpand>
	<script>
		toggleObject('#arguments.rootObjectId#');
	</script>
</cfif>
</div>

</cfoutput>

<cfsetting enablecfoutputonly="No">










