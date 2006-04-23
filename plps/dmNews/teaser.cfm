<!--- 
dmNews PLP
 - teaser (teaser.cfm)
--->
<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>


<cfimport taglib="/farcry/tags" prefix="tags">
<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<tags:plpNavigationMove>
<cftrace inline="true" text="Completed plpNavigationMove">

<!--- huh? --->
<cfset refObj="Teaser Image">

<cfif NOT thisstep.isComplete>
<cfform action="#cgi.script_name#?#cgi.query_string#" name="editform">

	<cfoutput>
<!--- 	
TODO
get tree working
get images working

<script>
	var validTypeIds = "#Application.daemon_imageTypeId#";
	
	function drawNode( lObjIds )
	{
		if( lObjIds.length == 0 )
		{
			document.getElementById("specobjs").innerHTML="No #refobj#...";
			return;
		}
		
		// download behaviour to get all these object ids
		oDownload.startDownload("#application.url.farcry#/navajo/getNodeData.cfm?lObjectIds="+lObjIds, downloadComplete );
	}
	
	function removeSpecial( anId )
	{
		var el=document.forms['editform'].aIds;
		el.value=el.value.replace( ""+anId+",", "" );
		el.value=el.value.replace( anId, "" );
		drawNode( el.value );
	}
	
	function downloadComplete( s )
	{
		eval(s);
		
		outData="<table border=0>";
		
		var aIds=document.forms['editform'].aIds.value;
		var ari = aIds.split( "," );
		
		for( var i=0; i<ari.length; i++ )
		{
			var objId = ari[i].toLowerCase();

			var theData = objectData[objId];
			
			if( theData && validTypeIds.indexOf( theData['typeid'] ) !=-1 )
			{
				outData += "<tr bgcolor=white><td>"+theData['title']+"</td><Td><input type='button' value='Preview' ";
				outData += "onclick=\"window.open('#application.url.farcry#/navajo/display.cfm?objectId="+theData['objectid']+"');\"></td>";
				outData += "<td><input type=button value='Remove' onclick=\"";
				outData += "removeSpecial('"+theData['objectid']+"')";
				outData += "\"></td></tr>";
			}
		}
		outData += "</table>";
		
		var e=document.getElementById("specobjs");
		e.innerHTML = outData;
		
		// remove no longer existing ids
		for( var i=ari.length-1; i>=0; i-- )
		{
			var objId = ari[i].toLowerCase();

			var theData = objectData[objId];
			
			if( !theData || validTypeIds.indexOf( theData['typeid'] ) ==-1 ) delete ari[i];
		}
		
		var aIds=document.forms['editform'].aIds.value = ari.toString();
	}
	
	function insertObjId( objId )
	{
		// grab the objects and update
		var el=document.forms['editform'].aIds;

		if( el.value.indexOf(objId) == -1 )
		{
			if( el.value.length != 0 ) el.value+=",";
			el.value+=objId;
			
			drawNode( el.value );
		}
	}
	</script>
 --->	
	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">Teaser</div>
	<div class="FormTable">

<!--- 	
TODO
get tree working
get images working

<table class="BorderTable" rules="rows">
	<tr><td><b>Teaser Image</b></td></tr>
	<tr>
	  <td>
	  <div id="specobjs"><h3>#refObj#</h3>Loading Data...</div>
	  </td>
	</tr>
	</table>
	<input type="hidden" name="aIds" value="#arrayToList(output.aTeaserImageIds)#">
	
	<!--- on insert getobjectdata, insert --->
	<script>
	drawNode( '#arrayToList(output.aTeaserImageIds)#' );
	</script>
	
	<Br><br>
 --->
 	<table>
	<tr>
		<td><tags:countertext formname="editform" fieldname="teaser" fieldvalue="#output.teaser#" counter="256"></td>
	</tr>										
	</table>
	</div>
</cfoutput>
	
	<cfoutput>
	<div class="FormTableClear">
	<cftrace inline="true" text="Form complete">
		<tags:PLPNavigationButtons>
	<cftrace inline="true" text="PLP NAvigation buttons rendered">
	</div>
	</cfoutput>
	
</cfform>
	
<cfelse>
	<cfparam name="form.aIds" default="">
	<cfset output.aTeaserImageIds = ListToArray(form.aIds)>

	<!--- <cf_ektron_scrub in="form.teaser"> --->

	<tags:plpUpdateOutput>
</cfif>