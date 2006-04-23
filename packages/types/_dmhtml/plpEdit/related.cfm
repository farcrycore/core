<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmhtml/plpEdit/related.cfm,v 1.3 2003/07/10 02:07:06 brendan Exp $
$Author: brendan $
$Date: 2003/07/10 02:07:06 $
$Name: b131 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: dmHTML PLP for edit handler - Related Links Step $
$TODO: clean up whispace management & formatting, add external links option 20030503 GB$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>

<cfoutput>

<script>
// tell the server above the current page; it will call the 
	// serverGet() function when it's done
	function serverPut(lObjIds){
		// the URL of the script on the server to run
		strURL = "#application.url.farcry#/navajo/getNodeData.cfm";
		// if you need to pass any variables to the script, 
		// then populate the following string with a valid query string	
		strQueryString = "lObjectIds="+lObjIds +"&blah=" + Math.random();
		
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

</script>
</cfoutput>



<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/fourq/tags" prefix="q4">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<tags:plpNavigationMove>

<cfif NOT thisstep.isComplete>
<cfform action="#cgi.script_name#?#cgi.query_string#" name="editform">

<cfoutput>
<div class="FormSubTitle">#output.label#</div>
<div class="FormTitle">Related Objects</div>
<div class="FormTable">

<!--- <IE:Download ID="oDownload" STYLE="behavior:url(##default##download)" /> --->
		<script>
		
	function insertObjId( objId )
	{
		// grab the objects and update
		var el=document.forms['editform'].aRelated;

		if( el.value.indexOf(objId) == -1 )
		{
			if( el.value.length != 0 ) el.value+=",";
			el.value+=objId;
			
			drawNode( el.value );
		}
	}
		
		
		
		function removeRelated( anId )
		{
			var el=document.forms['editform'].aRelated;
			el.value=el.value.replace( ""+anId+",", "" );
			el.value=el.value.replace( anId, "" );
			drawNode( el.value );
		}

		function drawNode( lObjIds )
		{	
			if( lObjIds.length == 0 )
			{
				document.getElementById("relatedPages").innerHTML="No related nodes...";
				return;
			}
			// download behaviour to get all these object ids
			serverPut(lObjIds);
	//oDownload.startDownload("#application.url.farcry#/navajo/getNodeData.cfm?lObjectIds="+lObjIds, downloadComplete );
			
		}
		
		function downloadComplete( s )
		{
			eval(s);
			
			outData="<table cellpadding=3 border=0><tr><Td colspan=3><b>Currently Related Pages</b></td></tr>";
			
			var relatedIds=document.forms['editform'].aRelated.value;
			var ari = relatedIds.split( "," );
			
			for( var i=0; i<ari.length; i++ )
			{
				var objId = ari[i].toLowerCase();
				var theData = objectData[objId];
				
				if( theData )
				{
					outData += "<tr><td><span class='frameMenuBullet'>&raquo;</span> "+theData['title']+"</td><Td><input type='button' value='Preview' ";
					outData += "onclick=\"window.open('#application.url.webroot#/index.cfm?objectId="+theData['objectid']+"');\"></td>";
					outData += "<td><input type=button value='Remove' onclick=\"";
					outData += "removeRelated('"+theData['objectid']+"')";
					outData += "\"></td></tr>";
				}
			}
			outData += "</table>";
			
			var e=document.getElementById("relatedPages");
			e.innerHTML = outData;
		}
		
		</script>
		Insert <a href="" onclick="alert('Right click on the node in the tree then select insert.');return false;">?</a> related articles from the Navitron Tree here...<br>
		
		<STYLE TYPE="text/css">
		##idServer { 
			position:relative; 
			width: 0px; 
			height: 0px; 
			clip:rect(0px 1px 1px 0px); 
			visibility: display; 
		}
	</STYLE>

		<IFRAME WIDTH="100" HEIGHT="1" NAME="idServer" ID="idServer" 
		 FRAMEBORDER="0" FRAMESPACING="0" MARGINWIDTH="0" MARGINHEIGHT="0">
			<ILAYER NAME="idServer" WIDTH="400" HEIGHT="100" VISIBILITY="Hide" ID="idServer">
			<P>This page uses a hidden frame and requires either Microsoft 
			Internet Explorer v4.0 (or higher) or Netscape Navigator v4.0 (or 
			higher.)</P>
			</ILAYER>
		</IFRAME>
		<input type="hidden" name="aRelated" value="#arrayToList(output.aRelatedIDs)#">
		</cfoutput>
		
		<q4:contentobjectgetmultiple lobjectIDs="#arrayToList(output.aRelatedIDs)#" r_stObjects="r_stObjects">
		
	<cfoutput>
		<br>
		<div id="relatedPages"><h3>Currently Related Pages</h3>Loading Data...</div>
		</div>
		<script>
		drawNode( '#StructKeyList(r_stObjects)#' );
		</script>
	</div>
	
	<p></p>
	
	<div class="FormTableClear">
		<tags:plpNavigationButtons>
	</div>
	</cfoutput>
	
</cfform>
	
<cfelse>
<!--- 
TODO
get tree working --->
	<cfparam name="form.aRelated" default="">
	<cfset output.aRelatedIDs = ListToArray( form.aRelated )>

	<tags:plpUpdateOutput>
</cfif>

