<cfsetting enablecfoutputonly="true">
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
<!--- @@displayname: Webtop Overview --->
<!--- @@description: The default webskin to use to render the object's summary in the webtop overview screen  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />

<!------------------ 
START WEBSKIN
 ------------------>

<cfset qFUCurrent = application.fc.factory.farFU.getFUList(objectid="#stobj.objectid#", fuStatus="current") />

<ft:fieldset legend="Friendly URL">
	
	<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
	
		<ft:fieldsetHelp>
			<cfoutput>
			Please refer to the <skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="typename=#stObj.typename#&versionID=#stobj.versionID#" linktext="approved" /> content item to manage friendly URLs.
			</cfoutput>
		</ft:fieldsetHelp>
		
	<cfelse>

		<ft:buttonPanel style="text-align:left;padding-top:0;padding-left:0;margin-top:0;border-top:0;border-bottom:1px solid ##e3e3e3;">
			<cfoutput>
			<a class="btn btn-primary" href="#application.url.webtop#/index.cfm?typename=#stObj.typename#&objectid=#stobj.objectid#&view=webtopPageModal&bodyView=webtopBodyManageFUs" onclick="$fc.openDialogIFrame('Friendly URLs', this.href); return false;">Manage Friendly URLs</a>
			</cfoutput>
		</ft:buttonPanel>

		<ft:fieldsetHelp>
			<cfoutput>
			A friendly URL is automatically generated to improve your search engine ranking and make it easy for humans to read. 
			You can change the default or add custom friendly URLs to meet your requirements.
			</cfoutput>
		</ft:fieldsetHelp>

		<ft:field label="Default URL" bMultiField="false">
			
			<cfset bHasDefault = false />
			<cfloop query="qFUCurrent">
				<cfif qFUCurrent.bDefault>
					<cfset bHasDefault = true />
					<cfoutput>
						#qFUCurrent.friendlyurl#<br>						
					</cfoutput>
				</cfif>
			</cfloop>
			
			<cfif NOT bHasDefault>
				<cfoutput>#application.fapi.getLink(objectid=stobj.objectid)#</cfoutput>
			</cfif>
			
			<ft:fieldHint>
				<cfif bHasDefault>
					<cfoutput>
					The default friendly URL for this content item.
					</cfoutput>
				<cfelse>
					<cfoutput>
					No friendly URL has been created for this content item. Please note, content items in draft do not have 
					</cfoutput>
				</cfif>
			</ft:fieldHint>
		</ft:field>
		
		<ft:field label="Alternative URLs" bMultiField="true">
		
			<cfset bHasOthers = false />
			<cfloop query="qFUCurrent">
				<cfif NOT qFUCurrent.bDefault>
					<cfset bHasOthers = true />
					<cfoutput>
						#qFUCurrent.friendlyurl#<br>						
					</cfoutput>
				</cfif>
			</cfloop>
			
			<cfif not bHasOthers>
				<cfoutput>-- No alternative friendly URLs ---</cfoutput>
			</cfif>
			
		</ft:field>

	</cfif>
</ft:fieldset>

<cfif structKeyExists(stObj, "extendedMetaData") OR structKeyExists(stObj, "metaKeywords")>
	<ft:fieldset legend="Search Engine Metadata" helpSection="The keywords and description that you enter here will provide search engines with extra information that describes your page. Remember that a good SEO strategy is much more than just a good description and keywords.">
	
		<cfif structKeyExists(stObj, "metaKeywords")>
			<ft:field label="Keywords" hint="An upper limit of 900 characters with spaces - keep it simple and relevant. 10 - 20 Keywords per page.">
				<cfif len(trim(stObj.metaKeywords))>
					<cfoutput>#trim(stObj.metaKeywords)#</cfoutput>
				<cfelse>
					<cfoutput>-- none provided --</cfoutput>
				</cfif>
			</ft:field>
		</cfif>
		
		<cfif structKeyExists(stObj, "extendedMetaData")>
			<ft:field label="Description" hint="Concise summary of the page, an upper limit of perhaps, 170 characters with spaces.">
				<cfif len(trim(stObj.extendedmetadata))>
					<cfoutput>#trim(stObj.extendedmetadata)#</cfoutput>
				<cfelse>
					<cfoutput>-- none provided --</cfoutput>
				</cfif>
			</ft:field>
		</cfif>
	</ft:fieldset>
</cfif>


<cfsetting enablecfoutputonly="false">