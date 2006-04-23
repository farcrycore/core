<cfoutput>
<html></html>
<body>
</cfoutput>
<cfsetting enablecfoutputonly="no">

<!--- 
dmNews PLP
 - related objects (related.cfm)
--->
<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 


<STYLE TYPE="text/css">
		.input { width: 400px; }
		##idText { position: absolute ; left: 150px; top: 175px; width: 400px; height: 120px; background-color: ffffff; border: thin solid ##003399; z-index: 1; padding: 5px 5px 5px 5px;}
		##idForm1 { position: absolute ; left: 150px; top: 175px; width: 400px; height: 120px; background-color: ffffff; border: thin solid ##003399; z-index: 2; padding: 5px 5px 5px 5px; visibility: hidden;}
		##idForm2 { position: absolute ; left: 150px; top: 175px; width: 400px; height: 120px; background-color: ffffff; border: thin solid ##003399; z-index: 2; padding: 5px 5px 5px 5px; visibility: hidden;}
</STYLE>
</cfoutput>

<cfimport taglib="/farcry/tags" prefix="tags">


<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<tags:plpNavigationMove>
<cftrace inline="true" text="Completed plpNavigationMove">

<cfif NOT thisstep.isComplete>
<cfoutput>

<script>
	
	selectedDiv = "form1";
	function selectForm( policyGroup )
	{
		el = document.getElementById(selectedDiv);
		el.style.display="none";
		
		el = document.getElementById(policyGroup);
		el.style.display="inline";
		
		selectedDiv = policyGroup;
	}
</script>
</cfoutput>
<cfoutput>
[<A HREF="javascript:void(0);" onClick="selectForm('form1');">div 1</A>]
[<A HREF="javascript:void(0);" onClick="selectForm('form2');">Form 2</A>]



<span class="FormTitle">Related Objects (to be completed later)</span>


<div id="form1" style="display:inline;">
	<table border="0">
	
	<tr>
  	 <td><span class="FormLabel">Title:</span></td>
   	 <td><input type="text" name="title" value="" class="FormTextBox"></td>
	</tr>
	
	<tr>	
  	 <td><span class="FormLabel">File:</span></td>
   	 <td><input type="file" name="filename" class="FormFileBox"></td>
	</tr>
	
	<tr>
  	 <td valign="top"><span class="FormLabel">Description:</span></td>
   	 <td><textarea cols="30" rows="4" name="description" class="FormTextArea"></textarea></td>
	</tr>
	<tr>
		<td colspan="2" align="center">
			<input type="Submit" name="Submit" value="Done!" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Submit" name="Cancel" value="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
		</td>
	</tr>
		
	</table>
</div> 
<div id="form2" style="display:none;">
	YAR YAR
</div>
 

</cfoutput>


<cfform action="#cgi.script_name#?#cgi.query_string#" name="editform">

<!--- 
<cfoutput>
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
			oDownload.startDownload("#application.url.farcry#/navajo/getNodeData.cfm?lObjectIds="+lObjIds, downloadComplete );
		}
		
		function downloadComplete( s )
		{
			eval(s);

			outData="<table border=1 bgcolor=FFCC00><tr><Td colspan=3><b>Currently Related Pages</b></td></tr>";
			
			var relatedIds=document.forms['editform'].aRelated.value;
			var ari = relatedIds.split( "," );
			
			for( var i=0; i<ari.length; i++ )
			{
				var objId = ari[i].toLowerCase();
				var theData = objectData[objId];
				
				if( theData )
				{
					outData += "<tr bgcolor=white><td>"+theData['title']+"</td><Td><input type='button' value='Preview' ";
					outData += "onclick=\"window.open('#application.url.farcry#/navajo/display.cfm?objectId="+theData['objectid']+"');\"></td>";
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
		
		
		<input type="hidden" name="aRelated" value="#arrayToList(output.aRelatedIDs)#">
		</cfoutput>
		
		<cfa_contentobjectgetmultiple dataSource="#request.cfa.datasource.dsn#" lobjectIDs="#arrayToList(output.aRelatedIDs)#" r_stObjects="stRelated">
		
	<cfoutput>
		<br>
		<b>Related Objects</b><br>
		<div id="relatedPages"><h3>Currently Related Pages</h3>Loading Data...</div>
		</div>
		<script>
		drawNode( '#StructKeyList(stRelated)#' );
		</script>

	</cfoutput>
 --->	
	
	<cfoutput>
	<cftrace inline="true" text="Form complete">
		<tags:PLPNavigationButtons>
	<cftrace inline="true" text="PLP NAvigation buttons rendered">
	</cfoutput>
	
</cfform>
	
<cfelse>
<!--- 
TODO
get tree working
	<cfparam name="form.aRelated" default="">
	<cfset output.aRelatedIDs = ListToArray( form.aRelated )>
 --->
	<tags:plpUpdateOutput>
</cfif>

</body>
</htmL>
