<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmhtml/plpEdit/related.cfm,v 1.7.2.2 2005/04/20 03:43:18 paul Exp $
$Author: paul $
$Date: 2005/04/20 03:43:18 $
$Name: milestone_2-3-2 $
$Revision: 1.7.2.2 $

|| DESCRIPTION || 
$Description: dmHTML PLP for edit handler - Related Links Step $
$TODO: clean up whispace management & formatting, add external links option 20030503 GB$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfprocessingDirective pageencoding="utf-8">

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
<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].relatedObjects#</div>
<div class="FormTable">


<script>
	var selectedIndex = 0;
		
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
				document.getElementById("relatedPages").innerHTML="#application.adminBundle[session.dmProfile.locale].noRelatedNodes#";
				return;
			}
			// download behaviour to get all these object ids
			serverPut(lObjIds);
		}
		
		function getSelectedIndex(radio)
		{
			for(var i = 0;i < radio.length;i++)
			{
				if(radio[i].checked)
					return i;
			}
		}
		
		function getSeqIndex(radioName)
		{	
			var emRadio = document.getElementsByName(radioName);
			for (var i = 0; i < emRadio.length; i++)
			{
			if (emRadio[i].checked)
				return i;
			}
		}

		function selectRadioIndex(radioName,index)
		{
			var emRadio = document.getElementsByName(radioName);
			for (var i = 0; i < emRadio.length; i++)
			{
				if ([i]==index)
					emRadio[i].checked = true;
			}
			
		}
		
		function reArrange(from,to,seq,radioName)
		{
			
			var relatedIds=document.forms['editform'].aRelated.value;
			var ari = relatedIds.split( "," );	
			//return if illegal to destination
			if (to >= ari.length) return;
			if (to < 0) return;
			selectedIndex = to;
				
			//do the switcheroo
			var tmpuuid = ari[to];
			ari[to] = ari[from];
			ari[from] = tmpuuid;
			
			//reset the form val to reflect reorder
			document.forms['editform'].aRelated.value = ari.join(",");
			//refresh display
			drawNode(document.forms['editform'].aRelated.value,seq);
			//set the selected index of radio to reflect new position
		  	return true;
		}
		
		
		function downloadComplete( s )
		{
			eval(s);
			outData = "<table><tr><td>";
			outData+="<table cellpadding=4 border=0><tr><td colspan=3><b>#application.adminBundle[session.dmProfile.locale].currentlyRelatedPages#</b></td></tr>";
			
			var relatedIds=document.forms['editform'].aRelated.value;
			var ari = relatedIds.split( "," );
			
			for( var i=0; i<ari.length; i++ )
			{
				var objId = ari[i].toLowerCase();
				var theData = objectData[objId];
				
				if( theData )
				{
					outData += "<tr><td><span class='frameMenuBullet'>&raquo;</span> "+theData['title']+"</td><Td><input type='button' value='#application.adminBundle[session.dmProfile.locale].preview#' ";
					outData += "onclick=\"window.open('#application.url.webroot#/index.cfm?objectId="+theData['objectid']+"');\"></td>";
					outData += "<td><input type=button value='#application.adminBundle[session.dmProfile.locale].remove#' onclick=\"";
					outData += "removeRelated('"+theData['objectid']+"')";
					outData += "\"></td>";
					outData +="<td><input type='radio' name='seq' value='" + objId + "'></td>";
					outData +="</tr>";
				}
			}
			outData += "</table>";
			outData+="</td><td>";
			if(ari.length > 1)
			{
				outData+="<input type=\"button\" class=\"normalbttnstyle\" value=\"&uarr;\" onClick=\"reArrange(getSelectedIndex(document.forms['editform'].seq),getSelectedIndex(document.forms['editform'].seq) -1,getSeqIndex('seq')-1,'seq');\"><br>";
				outData+="<input type=\"button\" class=\"normalbttnstyle\" value=\"&darr;\" onClick=\"reArrange(getSelectedIndex(document.forms['editform'].seq),getSelectedIndex(document.forms['editform'].seq) +1,getSeqIndex('seq')+1,'seq');\"><br>";
			}
			outData+="</td></tr></table>"
			
			var e=document.getElementById("relatedPages");
			e.innerHTML = outData;
			selectRadioIndex('seq',selectedIndex);
		}
		
		</script>
		#application.adminBundle[session.dmProfile.locale].insertRelatedArticles#<br>
		
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
		 FRAMEBORDER="0" FRAMESPACING="0" MARGINWIDTH="0" MARGINHEIGHT="0" SRC="null">
			<ILAYER NAME="idServer" WIDTH="400" HEIGHT="100" VISIBILITY="Hide" ID="idServer">
			<P>#application.adminBundle[session.dmProfile.locale].browserReqBlurb#</P>
			</ILAYER>
		</IFRAME>
		<input type="hidden" name="aRelated" value="#arrayToList(output.aRelatedIDs)#">
		</cfoutput>
		
		<q4:contentobjectgetmultiple lobjectIDs="#arrayToList(output.aRelatedIDs)#" r_stObjects="r_stObjects">
		
	<cfoutput>
		<br>
		<div id="relatedPages">
			#application.adminBundle[session.dmProfile.locale].loadingCurrentlyRelatedPages#
			
		</div>
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
	<cfparam name="form.aRelated" default="">
	<cfset output.aRelatedIDs = ListToArray( form.aRelated )>

	<tags:plpUpdateOutput>
</cfif>

