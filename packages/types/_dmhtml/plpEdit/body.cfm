<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmhtml/plpEdit/body.cfm,v 1.9 2004/06/17 00:18:23 spike Exp $
$Author: spike $
$Date: 2004/06/17 00:18:23 $
$Name: milestone_2-2-1 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: body step for dmHTML plp. Displays text editor with option to toggle to plain html text area.$
$TODO: clean up formatting -- test in Mozilla 20030503 GB$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="farcry">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<!--- check for toggle option --->
<cfif isdefined("form.toggle")>
	<cfset session.toggleTextArea = 1>
	<cfset onClickEvent = "">
<cfelse>
	<cfset session.toggleTextArea = 0>
	<!--- work out if onClick event needed for specified rich text editor --->
	<cfswitch expression="#application.config.general.richTextEditor#">
		<cfcase value="soEditorPro">
			<cfset onClickEvent = "soEditorbody.updateFormField()">
		</cfcase>
		<cfcase value="soEditor">
			<cfset onClickEvent = "soEditorbody.updateFormField()">
		</cfcase>
		<cfcase value="textArea">
			<cfset onClickEvent = "">
		</cfcase>
		<cfcase value="eopro">
			<cfset onClickEvent= "scriptForm_onsubmit();">
		</cfcase>
		<cfdefaultcase>
			<cfset onClickEvent = "">
		</cfdefaultcase>
	</cfswitch>
</cfif>
	
<!--- copy related items to a list for looping --->
<cfset aRelatedItems = output.aObjectIds>

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<farcry:plpNavigationMove>

<cfif NOT thisstep.isComplete>
	<cfoutput><form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform" style="display:inline">
	<!--- <div class="FormSubTitle">#output.label#</div> --->
	<div class="FormTitle">BODY</div></cfoutput>
	
	<!--- display texteditor (config specified) --->
	<farcry:richTextEditor value="#output.body#">
		
	<cfoutput>
	<table>
	<tr>
		<td>
			<!--- add image option --->
			<select onchange="insertHTML(this.options[this.selectedIndex].value);this.selectedIndex=0;">
				<option value="">--- insert image ---</option>
                </cfoutput>
                <!--- todo: dmHTML.getImages() --->
        		<cfloop from="1" to="#arrayLen(aRelatedItems)#" index="id">
    			<!--- get the objectType --->
	    		<cfinvoke component="farcry.fourq.fourq" returnVariable="typeName" method="findType" objectID="#aRelatedItems[id]#">
    			<cfif typename eq "dmImage">
    				<q4:contentObjectGet objectID="#aRelatedItems[id]#" r_stObject="stImage">
					<cfif stImage.imageFile neq "">
						<!--- check if hi res image exists --->
						<cfif stImage.optimisedImage neq "">
							<!--- display normal image with link to high res image in new window --->
							<cfoutput><option value="&lt;a href='#application.url.webroot#/images/#stImage.optimisedimage#' target='_blank'&gt;&lt;img src='#application.url.webroot#/images/#stImage.imageFile#' border=0 alt='#stImage.alt#'&gt;&lt;/a&gt;">#stImage.title#</option></cfoutput>
						<cfelse>
							<!--- display normal image --->
							<cfoutput><option value="&lt;img src='#application.url.webroot#/images/#stImage.imagefile#' border=0 alt='#stImage.alt#'&gt;">#stImage.title#</option></cfoutput>
						</cfif>
					</cfif>
    			</cfif>
        		</cfloop>
		    <cfoutput>
            </select>
		</td>
		<td>
			<!--- add file option --->
			<select onchange="insertHTML(this.options[this.selectedIndex].value);this.selectedIndex=0;">
			<option value="">--- insert file ---</option></cfoutput>
                <!--- todo: dmHTML.getImages() --->
        		<cfloop from="1" to="#arrayLen(aRelatedItems)#" index="id">
    			<!--- get the objectType --->
	    		<cfinvoke component="farcry.fourq.fourq" returnVariable="typeName" method="findType" objectID="#aRelatedItems[id]#">
    			<cfif typeName eq "dmFile">
    				<q4:contentObjectGet objectID="#aRelatedItems[id]#" r_stObject="stFile">
					<cfif stFile.typeName eq "dmFile">
						<cfif stFile.filename neq "">
							<!--- check whether to link directly to file or use download.cfm --->
							<cfif application.config.general.fileDownloadDirectLink eq "false">
								<cfoutput><option value="<a href='#application.url.webroot#/download.cfm?DownloadFile=#aRelatedItems[id]#' target='_blank'>#stFile.title#</a>">#stFile.title#</option></cfoutput>
							<cfelse>
								<cfoutput><option value="<a href='#application.url.webroot#/files/#stFile.filename#' target='_blank'>#stFile.title#</a>">#stFile.title#</option></cfoutput>
							</cfif>
						</cfif>
					</cfif>
    			</cfif>
        		</cfloop>
			<cfoutput>
            </select>
		</td></cfoutput>
		
		<!--- add templates --->
		<cfdirectory action="LIST" directory="#application.path.project#/webskin/#output.typename#/" name="qGetTemplates" filter="template*.htm" sort="name ASC">
		<cfif qGetTemplates.recordcount>
			<cfoutput><td>
				<select onchange="insertHTML(this.options[this.selectedIndex].value);this.selectedIndex=0;">
				    <option value="">--- insert template ---</option></cfoutput>
					<cfloop query="qGetTemplates">
						<cffile action="READ" file="#application.path.project#/webskin/#output.typename#/#qGetTemplates.name#" variable="i">
					    <!--- get templates--->
					    <cfoutput><option value="#htmleditformat(i)#">#mid(qGetTemplates.name,9,len(qGetTemplates.name))#</option></cfoutput>
				    </cfloop>
				<cfoutput></select>
			</td></cfoutput>	
		</cfif>	
				
		<!--- toggle to textArea instead of editor --->
		<cfoutput><td></cfoutput>
        

		<cfscript>
        oAuthentication = request.dmSec.oAuthentication;
		aUserGroups = oAuthentication.getMultipleGroups(userLogin="#session.dmSec.authentication.userLogin#", userDirectory="#session.dmSec.authentication.userDirectory#");
		</cfscript>

        <cfset bTogglePerm = 0>
        <cfloop index="i" from="1" to="#arrayLen(aUserGroups)#">
            <cfscript>
            stGroup = aUserGroups[i];
            if (stGroup.groupName eq "SiteAdmin" OR stGroup.groupName eq "SysAdmin") {
                bTogglePerm = 1;
                break;
            }
            </cfscript>
        </cfloop>

        <cfif bTogglePerm>
            <cfoutput><input type="checkbox" name="toggle" onClick="javascript:submit();" <cfif isdefined("session.toggleTextArea") and session.toggleTextArea eq 1>checked</cfif>> Toggle text area</cfoutput>
        </cfif>

        <cfoutput>
		</td>
	</tr>
	</table></cfoutput>
	
	<farcry:plpNavigationButtons bDropDown="true" onClick="#onClickEvent#">
	
	<cfoutput></form></cfoutput>
	
<cfelse>
	<farcry:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">