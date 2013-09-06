<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Shows only library selected --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />

<cfset request.fc.inwebtop = true />

<!------------------ 
START WEBSKIN
 ------------------>

	
	<cfparam name="url.property" type="string" />

	
	<cfset formAction = application.fapi.getLink(type='#stobj.typename#', objectid='#stobj.objectid#', view='displayLibrarySelected', urlParameters="property=#url.property#&ajaxmode=1") />
	
	<ft:form name="#stobj.typename#_#url.property#" bAjaxSubmission="true" action="#formAction#">
	
	<grid:col id="utility" span="20" />
		
	<grid:col span="1" />
	
	<grid:col span="60">
		
		
		<!--- DISPLAY THE SELECTION OPTIONS --->
		<cfoutput>
		<!-- summary pod with green arrow -->
		<div class="summary-pod">
				
					
			
					<cfset formAction = application.fapi.getLink(type='#stobj.typename#', objectid='#stobj.objectid#', view='displayLibrary', urlParameters="property=#url.property#&ajaxmode=1") />
					<ft:button value="Select More" renderType="link" type="button" onclick="farcryForm_ajaxSubmission('#request.farcryform.name#','#formAction#')" class="red" />
		
			
					<span id="librarySummary-#stobj.typename#-#url.property#"><p>&nbsp;</p></span>	
			
				
				
				
			
		</div>
		<!-- summary pod end -->
		</cfoutput>
		
		<cfif stobj.typename EQ "farFilterProperty">
			<cfset stFilter = application.fapi.getContentObject(objectid="#stobj.filterID#", typename="farFilter") />
			<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stFilter.filterTypename#", property="#stobj.property#") />
		<cfelse>
			<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />
		</cfif>
		<cfset stMetadata = application.fapi.getFormtool(stMetadata.type).prepMetadata(stObject = stobj, stMetadata = stMetadata) />

		<!--- DETERMINE THE SELECTED ITEMS --->
		<cfif stobj.typename EQ "farFilterProperty">
			<cfif isWDDX(stobj.wddxDefinition)>
				<cfwddx	action="wddx2cfml" 
					input="#stobj.wddxDefinition#" 
					output="stProps" />
			<cfelse>
				<cfset stProps = structNew() />
			</cfif>
			
			<cfparam name="stProps.relatedTo" default="">
			
			<cfif isArray(stProps.relatedTo)>
				<cfset lSelected = arrayToList(stProps.relatedTo) />
			<cfelse>
				<cfset lSelected = stProps.relatedTo />
			</cfif>
		<cfelse>
			<cfif isArray(stobj[url.property])>
				<cfloop array="#stobj[url.property]#"  index="i">
					<cfif isStruct(i) and StructKeyExists(i,"data")>
						<cfset lSelected = listappend(lSelected,i.data)>
					<cfelse>
						<cfset lSelected = listappend(lSelected,i)>
					</cfif>
				</cfloop>
			<cfelse>
				<cfset lSelected = stobj[url.property] />
			</cfif>			
		</cfif>
		
		<!--- Turn item into an array so we can paginate --->
		<cfset aPaginatedData = arrayNew(1) />
		<cfloop list="#lSelected#" index="stLocal.i">
			<cfset arrayAppend(aPaginatedData,stLocal.i) />
		</cfloop>
		
				
		
		<skin:pagination array="#aPaginatedData#" submissionType="form">
			<cfoutput>
				<div class="ctrlHolder #stObject.currentRowClass#" style="padding:3px;margin:3px;">
					<div style="float:left;width:20px;">
						<input type="checkbox" id="selected_#stobject.currentRow#" name="selected" class="checker" value="#stobject.objectID#" <cfif listFindNoCase(lSelected,stobject.objectid)>checked="checked"</cfif> />
					</div>
					<div style="margin-left: 30px;">
						<skin:view objectid="#stobject.objectid#" webskin="librarySelected" bIgnoreSecurity="true" />
					</div>					
				</div>
			</cfoutput>
		</skin:pagination>
		
		<cfoutput>
		<script type="text/javascript">
		$j(function(){
			fcForm.initLibrary('#stobj.typename#','#stobj.objectid#','#url.property#');	
		});
		</script>
		</cfoutput>
		
	</grid:col>	
	</ft:form>

<cfsetting enablecfoutputonly="false">