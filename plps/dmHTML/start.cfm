<!--- 
dmHTML PLP
 - start (start.cfm)
--->

<cfimport taglib="/farcry/tags" prefix="tags">
<cfimport taglib="/farcry/tags/navajo" prefix="nj">
<cfimport taglib="/farcry/tags/display/" prefix="display">
<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<tags:plpNavigationMove>
<cftrace inline="true" text="Completed plpNavigationMove">

<cfif NOT thisstep.isComplete>
<cfform action="#cgi.script_name#?#cgi.query_string#" name="editform">
	<cfoutput>

	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">General Info</div>
	<div class="FormTable">
	<table width="400" border="0" cellspacing="0" cellpadding="5">
	<tr>
		<td nowrap class="FormLabel">Title:</td>
		<td width="100%"><input type="text" name="Title" value="#output.Title#" class="FormTextBox"></td>
	</tr>
	<tr>
		<td nowrap class="FormLabel">Metadata Keywords:</td>
		<td width="100%"><input type="text" name="metakeywords" value="#output.metakeywords#" class="FormTextBox"></td>
	</tr>

	<!--- get the templates for this type --->
	<nj:listTemplates typename="dmHTML" prefix="displayPage" r_qMethods="qMethods">
	<tr>
		<td nowrap class="FormLabel">Display Method:</td>
		<td width="100%" class="FormLabel">
		<select name="DisplayMethod" size="1">
		</cfoutput>
		<cfoutput query="qMethods">
		<option value="#qMethods.methodname#" <cfif qMethods.methodname eq output.displaymethod>SELECTED</cfif>>#qMethods.displayname#</option>
		</cfoutput>
		<cfoutput>
		</select>
		</td>
	</tr>
	<tr>
		<td colspan="2"><strong>Teaser</strong><br><tags:countertext formname="editform" fieldname="teaser" fieldvalue="#output.teaser#" counter="256"></td>
	</tr>	
	</table>
	</div>
	</cfoutput>	
	
<!---  display commentlog for this object  --->
	<div class="FormTableClear">
	<display:openlayer width="100%" title="Comment Log" isClosed="Yes" border="no">
		<cfif len(output.CommentLog)>
		<cfoutput>
		<textarea rows="10" style="width: 100%;">#output.CommentLog#</textarea>
		</cfoutput>
		<cfelse>
		<cfoutput>
		There are no comments available.
		</cfoutput>
		</cfif>
	</display:openlayer>
	</div>
	
	<cfif len(output.versionID)>
	<cfinvoke  component="#application.packagepath#.farcry.versioning" method="getArchives" returnvariable="qGetArchives">
		<cfinvokeargument name="objectID" value="#output.versionID#"/>
	</cfinvoke>		
	<!--- display past archived versions of this object --->
	<div class="FormTableClear">
	<display:openlayer width="100%" title="Archived Versions" isClosed="Yes" border="no">
		
		<cfif NOT qGetArchives.recordCount>
			<cfoutput>No records returned</cfoutput>
		<cfelse>
			<table width="100%" border="0" cellspacing="1" bgcolor="##999999">
	        <tr> 
    	      <td class="rowsHeader"> View </td>
	          <td class="rowsHeader"> Label </td>
    	      <td class="rowsHeader"> Archive Date </td>
	          <td class="rowsHeader"> By </td>
    	    </tr>	
			<tr>
			<cfoutput query="qGetArchives" > 
			<cfscript>
				previewURL = "#application.url.farcry#/navajo/displayArchive.cfm?objectID=#qGetArchives.objectID#";
			</cfscript>
        	  <tr> 
            	<td class="rows" align="center"> 
        	      <a href="#previewURL#" target="_blank"><img src="#application.url.farcry#/navajo/nimages/preview.gif" border="0"></a> 
            	</td>
	            <td class="rows"> 
		             <a href="#previewURL#">#label#</a>
				</td>
            	<td class="rows"> 
              		#dateFormat(dateTimeCreated,"dd-mmm-yyyy")#
				</td>
            	<td class="rows"> 
              		#lastUpdatedBy# 
			 	</td>
          	</tr>
	        </cfoutput>
			</table>
		</cfif>

	
	</display:openlayer>
	</div>
	</cfif>
	<cfoutput>
	<div class="FormTableClear">
	<cftrace inline="true" text="Form complete">
		<tags:PLPNavigationButtons>
	<cftrace inline="true" text="PLP NAvigation buttons rendered">
	</div>
	</cfoutput>
	
</cfform>
<cfelse>
	<tags:plpUpdateOutput>
</cfif>
