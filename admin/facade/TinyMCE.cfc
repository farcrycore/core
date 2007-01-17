<cfcomponent name="tinyMCEImageFields" displayname="tinyMCEImageFields" hint="Used by the farcry Advanced Image TinyMCE Rich Text popup for the ajax callbacks" output="false" > 

<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >

<cffunction name="ajaxGetImageFields" access="remote" output="true" returntype="string">
 	<cfargument name="objectid" required="yes" type="uuid" hint="ObjectID of the object to be rendered.">
 	<cfargument name="typename" required="yes" default="" type="string" hint="typename of the object to be rendered.">
 	<cfargument name="richtextfield" required="yes" type="string" hint="name of the richtext field.">

	<cfset stMetadata = duplicate(application.types[arguments.typename].stprops[arguments.richtextfield].metadata) />
	
	<!--- <cfquery datasource="#application.dsn#" name="qImages">
	select top 10 * 
	from avnImage
	where label <> ''
	</cfquery> --->
	
<!--- 	<cfquery datasource="#application.dsn#" name="qImages">
	select * 
	from #arguments.typename#_#arguments.ftImageTypename#
	where parentid = '#arguments.objectid#'
	</cfquery> --->
	<cfquery datasource="#application.dsn#" name="qImages">
	select top 10 * 
	from avnImage
	where label <> ''
	</cfquery>
	<cfoutput>
		
	<!--- &nbsp; --->
	<select id="imagelistsrc" name="imagelistsrc" onchange="getImageSRC();">
		<option value="">--select a library image--</option>
		<cfloop query="qImages">
			<option value="#qImages.objectid#">#qImages.label#</option>
		</cfloop>
	</select>
	<select id="imagefieldname" name="imagefieldname" onchange="getImageSRC();">
		<option value="standardimage">Standard</option>										
		<option value="thumbnailimage">Thumbnail</option>										
		<option value="sourceimage">Source</option>										
	</select>
	
	<div id="imageSRC" style="display:none;"></div>
	
	</cfoutput>

</cffunction>



<cffunction name="ajaxGetTemplateDropdowns" access="remote" output="true" returntype="string">
 	<cfargument name="objectid" required="yes" type="uuid" hint="ObjectID of the object to be rendered.">
 	<cfargument name="typename" required="yes" default="" type="string" hint="typename of the object to be rendered.">
 	<cfargument name="richtextfield" required="yes" type="string" hint="name of the richtext field.">

	<cfset var stProps = duplicate(application.types[arguments.typename].stprops) />
	<cfset var oObject = createobject("component", application.types[arguments.typename].packagepath)>
	<cfset var stObject = oObject.getData(objectid="#arguments.objectid#") />
	
	
	<!--- <cfquery datasource="#application.dsn#" name="qImages">
	select top 10 * 
	from avnImage
	where label <> ''
	</cfquery> --->
	
<!--- 	<cfquery datasource="#application.dsn#" name="qImages">
	select * 
	from #arguments.typename#_#arguments.ftImageTypename#
	where parentid = '#arguments.objectid#'
	</cfquery> --->
	<cfoutput>
		<div class="tabs">
			<ul>
				<cfset bCurrent = true />
				<cfloop list="#stprops[arguments.richtextfield].metadata.ftTemplateTypeList#" index="templateTypename">
					<li id="#templateTypename#_tab" class="<cfif bCurrent>current</cfif>"><span><a href="javascript:mcTabs.displayTab('#templateTypename#_tab','#templateTypename#_panel');" onmousedown="return false;">#application.types[templateTypename].displayName#</a></span></li>
					<cfset bCurrent = false />
				</cfloop>
				
				<cfif structKeyExists(stProps[arguments.richtextfield].metadata, "ftTemplateGenericWebskinPrefix")>
					<li id="generic_tab"><span><a href="javascript:mcTabs.displayTab('generic_tab','generic_panel');" onmousedown="return false;">Generic Templates</a></span></li>
				</cfif>
			</ul>
		</div>
	</cfoutput>
	


<cfoutput>
	<div class="panel_wrapper">
</cfoutput>


	<cfset bCurrent = true />
	
	
	
	<cfloop list="#stprops[arguments.richtextfield].metadata.ftTemplateTypeList#" index="templateTypename">
	
		<cfif listfind(stprops[arguments.richtextfield].metadata.ftTemplateTypeList,templateTypename) LTE listLen(stprops[arguments.richtextfield].metadata.ftTemplateWebskinPrefixList)>
			<cfset templateWebskinPrefix = listgetat(stprops[arguments.richtextfield].metadata.ftTemplateWebskinPrefixList,listfind(stprops[arguments.richtextfield].metadata.ftTemplateTypeList,templateTypename)) />
		<cfelse>
			<cfset templateWebskinPrefix = listLast(stprops[arguments.richtextfield].metadata.ftTemplateWebskinPrefixList) />
		</cfif>
		
		
		<cfset o = createobject("component", application.types[templatetypename].packagepath) />
		<cfset qWebskins = o.getWebskins(typename="#templateTypename#", prefix="#templateWebskinPrefix#") />
		
		<cfset lRelatedObjectIDs = "" />
		<cfloop list="#structKeyList(stProps)#" index="fieldname">
			<cfif stProps[fieldname].metadata.type EQ "array" OR stProps[fieldname].metadata.type EQ "UUID" AND structKeyExists(stProps[fieldname].metadata, "ftJoin")>
				
				<cfif stProps[fieldname].metadata.type EQ "array">
					<cfif listContainsNoCase(stProps[fieldname].metadata.ftJoin,templateTypename)>
					
						<cfquery datasource="#application.dsn#" name="qRelated">
						SELECT data
						FROM #typename#_#fieldname#
						WHERE parentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#">
						AND typename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#templateTypename#">
						ORDER BY SEQ
						</cfquery>
						
						<cfset lRelatedObjectIDs = listAppend(lRelatedObjectIDs, valueList(qRelated.data)) />
					</cfif>
				<cfelseif stProps[fieldname].metadata.type EQ "UUID">
					<cfif listContainsNoCase(stProps[fieldname].metadata.ftJoin,templateTypename) AND len(stObject[fieldname])>
						<cfset lRelatedObjectIDs = listAppend(lRelatedObjectIDs, stObject[fieldname]) />
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		

		<cfoutput>		
		
			<div id="#templateTypename#_panel" class="panel <cfif bCurrent>current</cfif>">
				
					<cfif listLen(lRelatedObjectIDs)>
						<cfquery datasource="#application.dsn#" name="qObjects">
						select * 
						from #templateTypename#
						where objectid IN (#ListQualify(lRelatedObjectIDs,"'")#)
						</cfquery>
					
						<table class="properties" style="margin-top:20px;">
						<tr> 
							<td class="column1"><label id="#templateTypename#objectidlabel" for="#templateTypename#objectid">Item</label></td> 
							<td>
								<select id="#templateTypename#objectid" name="#templateTypename#objectid" onchange="Element.setStyle('insert#templateTypename#', {display:'none'});">
									<option value="">--select a #templateTypename#--</option>
									<cfloop query="qObjects">
										<option value="#qObjects.objectid#">#qObjects.label#</option>
									</cfloop>
								</select>
							</td> 
						</tr> 
						<tr> 
							<td class="column1"><label id="#templateTypename#webskinlabel" for="#templateTypename#webskin">Template</label></td> 
							<td>
								<select id="#templateTypename#webskin" name="#templateTypename#webskin" onchange="Element.setStyle('insert#templateTypename#', {display:'none'});">
									<option value="">--select a display type--</option>
									<cfloop query="qWebskins">
										<option value="#ReplaceNoCase(qWebskins.name, ".cfm", "", "all")#">#qWebskins.displayname#</option>
									</cfloop>									
								</select>
							</td> 
						</tr> 
						<tr> 
							<td class="column1">&nbsp; </td>
							<td>
								<input type="button" name="preview" value="preview" onclick="setPreview($('#templateTypename#objectid').value, '#templateTypename#', $('#templateTypename#webskin').value, '#templateTypename#');" />
							</td> 
						</tr> 
						</table>
						
						
						
						<fieldset>
							<legend>Preview</legend>
							<div id="prev#templateTypename#DIV">
								<iframe id="prev#templateTypename#" src="" width="100%" height="150" style="border:0px solid ##a0a0a0;">
								
								</iframe>
							</div>
						</fieldset>
						
						
						<div class="mceActionPanel">
							<div style="float: left">
								<input type="button" id="insert#templateTypename#" name="insert#templateTypename#" value="Insert" onclick="insertSomething('#templateTypename#', '#templateTypename#');" style="display:none;" />
							</div>
				
							<div style="float: right">
								<input type="button" id="cancel" name="cancel" value="Cancel" onclick="tinyMCEPopup.close();" />
							</div>
							
						</div>
					
					<cfelse>
						<p>No Related #application.types[TemplateTypename].displayname#(s)</p>
					</cfif>	
						
					
				
						
				
							
			</div>
			
			
			
			
		</cfoutput>
		
		<cfset bCurrent = false />
		
	</cfloop>
	
	
	
	<cfif structKeyExists(stProps[arguments.richtextfield].metadata, "ftTemplateGenericWebskinPrefix")>
		<cfset oObject = createobject("component", application.types[arguments.typename].packagepath) />
		<cfset qObjectWebskins = oObject.getWebskins(typename="#arguments.typename#", prefix="#stProps[arguments.richtextfield].metadata.ftTemplateGenericWebskinPrefix#") />
		
		
		
		<cfoutput>		
			
			<div id="generic_panel" class="panel">
				

						
					
						<table class="properties" style="margin-top:20px;">
						<tr> 
							<td class="column1"><label id="genericwebskinlabel" for="genericwebskin">Template</label></td> 
							<td>
								<select id="genericwebskin" name="genericwebskin" onchange="Element.setStyle('insertgeneric', {display:'none'});">
									<option value="">--select a display type--</option>
									<cfloop query="qObjectWebskins">
										<option value="#ReplaceNoCase(qObjectWebskins.name, ".cfm", "", "all")#">#ReplaceNoCase(qObjectWebskins.name, ".cfm", "", "all")#</option>
									</cfloop>									
								</select>
							</td> 
						</tr> 
						<tr> 
							<td class="column1">&nbsp; </td>
							<td>
								<input type="hidden" id="genericobjectid" name="genericobjectid" value="#arguments.objectid#">
								<input type="button" name="preview" value="preview" onclick="setPreview($('genericobjectid').value, '#arguments.typename#', $('genericwebskin').value, 'generic');" />
							</td> 
						</tr> 
						</table>
						
						
						
						<fieldset>
							<legend>Preview</legend>
							<div id="prevgenericDIV">
								<iframe id="prevgeneric" src="" width="100%" height="150" style="border:0px solid ##a0a0a0;">
								
								</iframe>
							</div>
						</fieldset>
						
						
						<div class="mceActionPanel">
							<div style="float: left">
								<input type="button" id="insertgeneric" name="insertgeneric" value="Insert" onclick="insertSomething('#arguments.typename#', 'generic');" style="display:none;" />
							</div>
				
							<div style="float: right">
								<input type="button" id="cancel" name="cancel" value="Cancel" onclick="tinyMCEPopup.close();" />
							</div>
							
						</div>
					
				
						
				
							
			</div>
			
			
			
			
		</cfoutput>
		
	</cfif>
	
	
<cfoutput>
	</div>
</cfoutput>
	
</cffunction>


<cffunction name="ajaxSetTemplatePreview" access="remote" output="true" returntype="string">
 	<cfargument name="objectid" required="yes" type="uuid" hint="ObjectID of the object to be rendered.">
 	<cfargument name="typename" required="yes" default="" type="string" hint="typename of the object to be rendered.">
 	<cfargument name="webskin" required="yes" type="string" hint="name of the webskin to use to render the object template.">

	<cfset var o = createobject("component", application.types[arguments.typename].packagepath) />
	<cfset var HTML = o.getView(objectid="#arguments.objectid#", template="#arguments.webskin#") />	

	<cfoutput>#HTML#</cfoutput>
	

</cffunction>



</cfcomponent>