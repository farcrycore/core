<cfcomponent name="tinyMCEImageFields" displayname="tinyMCEImageFields" hint="Used by the farcry Advanced Image TinyMCE Rich Text popup for the ajax callbacks" output="false" > 

	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />	
	
	
	<cffunction name="ajaxGetTemplateDropdowns" access="remote" output="true" returntype="string">
	 	<cfargument name="objectid" required="yes" type="uuid" hint="ObjectID of the object to be rendered.">
	 	<cfargument name="typename" required="yes" default="" type="string" hint="typename of the object to be rendered.">
	 	<cfargument name="richtextfield" required="yes" type="string" hint="name of the richtext field.">
	
		<cfset var stProps = duplicate(application.stcoapi[arguments.typename].stprops) />
		<cfset var oObject = createobject("component", application.stcoapi[arguments.typename].packagepath)>
		<cfset var stObject = oObject.getData(objectid="#arguments.objectid#") />
		<cfset var templateTypename = "" />
		<cfset var templateDisplayname = "" />
		
		<cfparam name="stprops[arguments.richtextfield].metadata.ftTemplateTypeList" default="" />
		<cfparam name="stprops[arguments.richtextfield].metadata.ftTemplateSnippetWebskinPrefix" default="insertSnippet" />
		<cfparam name="stprops[arguments.richtextfield].metadata.ftTemplateWebskinPrefixList" default="insertHTML" />
				
		<!--- Get wizard data if exists --->
		<cfif structKeyExists(form,"wizardid") and len(form.wizardid)>
			<cfset form.wizardid = listFirst(form.wizardid)> <!--- got the wizard id twice sometimes --->
			<cfset owizard = createObject("component",application.stcoapi['dmWizard'].packagepath)>
			<cfset stwizard = owizard.Read(wizardID=form.wizardid)>
			<cfset stObject = stwizard.Data[stObject.objectid]>
		</cfif>
		
		<!--- Overwrite data if user currently changing some relations - Hidden fields passed in via ajax --->
		<cfloop list="#structKeyList(stProps)#" index="fieldname">
			<cfset fcFormFieldName = "fc#replace(stObject.objectid,"-","","all")##fieldname#">
			<cfif structKeyExists(form,fcFormFieldName)>
				<cfif stProps[fieldname].metadata.type EQ "array">
					<cfset stObject[fieldname] = listToArray(form[fcFormFieldName])>
				<cfelse>
					<!--- don't replace objectid --->
					<cfif fieldname NEQ 'ObjectID'>
						<cfset stObject[fieldname] = form[fcFormFieldName]>
					</cfif>
				</cfif>
			</cfif>
		</cfloop> 

		<cfoutput>
			<div class="tabs">
				<ul>
					<cfset bCurrent = true />
					<cfloop list="#stprops[arguments.richtextfield].metadata.ftTemplateTypeList#" index="templateTypename">
						<li id="#templateTypename#_tab" class="<cfif bCurrent>current</cfif>"><span><a href="javascript:mcTabs.displayTab('#templateTypename#_tab','#templateTypename#_panel');" onmousedown="return false;">#application.stcoapi[templateTypename].displayName#</a></span></li>
						<cfset bCurrent = false />
					</cfloop>
					
					<cfif structKeyExists(stProps[arguments.richtextfield].metadata, "ftTemplateSnippetWebskinPrefix")>
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
			
			<cfif structKeyExists(application.stcoapi[templateTypename], "displayname")>
				<cfset templateDisplayname = application.stcoapi[templateTypename].displayname />
			<cfelse>
				<cfset templateDisplayname = templateTypename />
			</cfif>
			
			<cfif listfind(stprops[arguments.richtextfield].metadata.ftTemplateTypeList,templateTypename) LTE listLen(stprops[arguments.richtextfield].metadata.ftTemplateWebskinPrefixList)>
				<cfset templateWebskinPrefix = listgetat(stprops[arguments.richtextfield].metadata.ftTemplateWebskinPrefixList,listfind(stprops[arguments.richtextfield].metadata.ftTemplateTypeList,templateTypename)) />
			<cfelse>
				<cfset templateWebskinPrefix = listLast(stprops[arguments.richtextfield].metadata.ftTemplateWebskinPrefixList) />
			</cfif>
			
			
			<cfset o = createobject("component", application.stcoapi[templatetypename].packagepath) />
			<cfset qWebskins = o.getWebskins(typename="#templateTypename#", prefix="#templateWebskinPrefix#") />
			
			<cfset lRelatedObjectIDs = "" />
			<cfloop list="#structKeyList(stProps)#" index="fieldname">
				<cfif stProps[fieldname].metadata.type EQ "array" OR stProps[fieldname].metadata.type EQ "UUID" AND structKeyExists(stProps[fieldname].metadata, "ftJoin")>
					
					<cfif stProps[fieldname].metadata.type EQ "array">
						<cfif listContainsNoCase(stProps[fieldname].metadata.ftJoin,templateTypename)>
							<cfset lRelatedObjectIDs = listAppend(lRelatedObjectIDs, arrayToList(stObject[fieldname])) />
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
					<cfif NOT qWebskins.recordcount>
						<p>No Webskins: #application.stcoapi[TemplateTypename].displayname#</p>
					<cfelseif listLen(lRelatedObjectIDs)>
						<cfquery datasource="#application.dsn#" name="qObjects">
						select * 
						from #templateTypename#
						where objectid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lRelatedObjectIDs#" />)
						</cfquery>
						
						<cfif qObjects.recordcount>
							<table class="properties" style="margin-top:20px;">
							<tr> 
								<td class="column1"><label id="#templateTypename#objectidlabel" for="#templateTypename#objectid">Item</label></td> 
								<td>
									<select id="#templateTypename#objectid" name="#templateTypename#objectid">
										<option value="">-- Select #templateDisplayname# --</option>
										<cfloop query="qObjects">
											<option value="#qObjects.objectid#">#qObjects.label#</option>
										</cfloop>
									</select>
								</td> 
							</tr> 
							<tr> 
								<td class="column1"><label id="#templateTypename#webskinlabel" for="#templateTypename#webskin">Template</label></td> 
								<td>
									<select id="#templateTypename#webskin" name="#templateTypename#webskin" onchange="$j('##insert#templateTypename#').css('display','');setPreview($j('###templateTypename#objectid').attr('value'), '#templateTypename#', $j('###templateTypename#webskin').attr('value'), '#templateTypename#');"> 
										<option value="">-- Select a display type --</option>
										<cfloop query="qWebskins">
											<option value="#ReplaceNoCase(qWebskins.name, ".cfm", "", "all")#">#qWebskins.displayname#</option>
										</cfloop>									
									</select>
								</td> 
							</tr> 
							<tr> 
								<td class="column1">&nbsp; </td>
								<td>
									<input type="button" name="preview" value="preview" onclick="setPreview($j('###templateTypename#objectid').attr('value'), '#templateTypename#', $j('###templateTypename#webskin').attr('value'), '#templateTypename#');" />
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
							<p>No Related #application.stcoapi[TemplateTypename].displayname#(s)</p>
						</cfif>
					<cfelse>
						<p>No Related #application.stcoapi[TemplateTypename].displayname#(s)</p>
					</cfif>	
							
				</div>
				
			</cfoutput>
			
			<cfset bCurrent = false />
			
		</cfloop>
		
		<cfif structKeyExists(stProps[arguments.richtextfield].metadata, "ftTemplateSnippetWebskinPrefix")>
			<cfset oObject = createobject("component", application.stcoapi[arguments.typename].packagepath) />
			<cfset qObjectWebskins = oObject.getWebskins(typename="#arguments.typename#", prefix="#stProps[arguments.richtextfield].metadata.ftTemplateSnippetWebskinPrefix#") />
				
			<cfoutput>		
				
				<div id="generic_panel" class="panel">
	
					<table class="properties" style="margin-top:20px;">
					<tr> 
						<td class="column1"><label id="genericwebskinlabel" for="genericwebskin">Template</label></td> 
						<td>
							<cfif qObjectWebskins.recordCount>
								<select id="genericwebskin" name="genericwebskin" onchange="$j('##insertgeneric').css('display','');">
									<option value="">--select a display type--</option>
									<cfloop query="qObjectWebskins">
										<option value="#ReplaceNoCase(qObjectWebskins.name, ".cfm", "", "all")#">#ReplaceNoCase(qObjectWebskins.displayname, ".cfm", "", "all")#</option>
									</cfloop>									
								</select>
							<cfelse>
								-- No Generic Templates Available --
							</cfif>
						</td> 
					</tr> 
					<cfif qObjectWebskins.recordCount>
						<tr> 
							<td class="column1">&nbsp; </td>
							<td>
								<input type="hidden" id="genericobjectid" name="genericobjectid" value="#arguments.objectid#">
								<input type="button" name="preview" value="preview" onclick="setPreview($j('##genericobjectid').attr('value'), '#arguments.typename#', $j('##genericwebskin').attr('value'), 'generic');" />
							</td> 
						</tr> 
						
					</cfif>
					</table>
					
					<cfif qObjectWebskins.recordCount>
						<fieldset>
							<legend>Preview</legend>
							<div id="prevgenericDIV">
								<iframe id="prevgeneric" src="" width="100%" height="150" style="border:0px solid ##a0a0a0;">
								
								</iframe>
							</div>
						</fieldset>
					</cfif>
					
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
	
	
	<cffunction name="ajaxSetTemplatePreview" access="remote" output="true" returntype="void">
	 	<cfargument name="objectid" required="yes" type="uuid" hint="ObjectID of the object to be rendered.">
	 	<cfargument name="typename" required="yes" default="" type="string" hint="typename of the object to be rendered.">
	 	<cfargument name="webskin" required="yes" type="string" hint="name of the webskin to use to render the object template.">
	
		<cfset var o = createobject("component", application.stcoapi[arguments.typename].packagepath) />
		<cfset var HTML = o.getView(objectid="#arguments.objectid#", template="#arguments.webskin#") />	
	
		<cfoutput>#trim(HTML)#</cfoutput>	
	
	</cffunction>


</cfcomponent>