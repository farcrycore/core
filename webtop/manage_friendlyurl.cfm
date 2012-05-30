<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />


<!--- 
manage friendly urls for a particular object id
 --->

<cfparam name="url.objectid" default="" />
<cfparam name="fatalerrormessage" default="" />
<cfparam name="errormessage" default="" />
<cfparam name="bFormSubmitted" default="no" />
<cfparam name="friendly_url" default="" />
<cfparam name="additional_params" default="" />
<cfparam name="lArchiveObjectID" default="" />
<cfparam name="fuStatus" default="2" />
<cfparam name="redirectionType" default="301" />
<cfparam name="redirectTo" default="system" />


<cfset stRefObject = application.coapi.coapiUtilities.getContentObject(objectid="#url.objectid#") />

<ft:processForm action="Save Changes,Make Default,Archive Selected,Delete Selected Archives">
	<ft:processFormObjects typename="farFU">
		<cfif structKeyExists(stProperties, "friendlyURL")>
			<cfset stProperties.friendlyURL = application.fc.factory.farFU.cleanFU(friendlyURL="#stProperties.friendlyURL#",fuID="#stProperties.objectid#", bCheckUnique="true") />
		</cfif>
		<cfset application.fc.factory.farFU.setMapping(objectid="#stProperties.objectid#") />
		
	</ft:processFormObjects>
</ft:processForm>

<ft:processForm action="Add" url="refresh">
	
	<ft:processFormObjects typename="farFU">
		
		<cfset stProperties.refObjectID = form.selectedObjectID />
		
		<cfset stResult = application.fc.factory.farFU.createCustomFU(argumentCollection="#stProperties#") />
		
		<cfif not stResult.bSuccess>
			<skin:bubble title="#stResult.message#" autoHide="false" tags="type,farFU,error" />
		<cfelse>
			<skin:bubble title="Alternative Friendly URL Created" autoHide="true" tags="type,farFU,created,information">
				<cfoutput>Your Friendly URL (#stProperties.friendlyURL#) has been created.</cfoutput>
			</skin:bubble>
		</cfif>
		
		<ft:break />
	</ft:processFormObjects>
</ft:processForm>

<ft:processForm action="Archive Selected" url="refresh">
	
	<cfif structKeyExists(form, "lArchiveObjectID") AND len(form.lArchiveObjectID)>
		<cfloop list="#form.lArchiveObjectID#" index="i">
			<cfset returnstruct = application.fc.factory.farFU.archiveFU(objectID="#i#")>
			<cfset returnstruct = application.fc.factory.farFU.delete(objectID="#i#")>
		</cfloop>

	</cfif>
</ft:processForm>


<ft:processForm action="Delete Selected Archives" url="refresh">
	
	<cfif structKeyExists(form, "lDeleteObjectID") AND len(form.lDeleteObjectID)>
		<cfloop list="#form.lDeleteObjectID#" index="i">
			<cfset returnstruct = application.fc.factory.farFU.delete(objectID="#i#")>
		</cfloop>

	</cfif>
</ft:processForm>



<ft:processForm action="Make Default" url="refresh">
	<cfif structKeyExists(form, "selectedObjectID") AND len(form.selectedObjectID)>
		<cfset returnstruct = application.fc.factory.farFU.setDefaultFU(objectID="#form.selectedObjectID#")>
	</cfif>
</ft:processForm>



<ft:processForm action="Save Changes" url="refresh" />


<cfif not len(url.objectid)>
	<skin:bubble title="Invalid ObjectID" autoHide="false" tags="type,farFU,error" />
</cfif>


<admin:header title="Manage Friendly URL's">
	
	
	<cfset qFUCurrent = application.fc.factory.farFU.getFUList(objectid="#url.objectid#", fuStatus="current") />
	<cfset qFUArchived = application.fc.factory.farFU.getFUList(objectid="#url.objectid#", fuStatus="archived") />
	
	
	<skin:loadJS id="jquery" />
	<skin:loadJS id="jquery-ui" />
	<skin:loadCSS id="jquery-ui" />
	
	<skin:onReady>
		<cfoutput>$j("##fu-tabs").tabs();</cfoutput>
	</skin:onReady>
	
	<grid:div id="fu-tabs" style="width:100%;height:100%;">
		<cfoutput>
		<ul>
			<li><a href="##tabs-1">Create Alternative</a></li>
			<cfif qFUCurrent.recordCount>
				<li><a href="##tabs-2">Current</a></li>
			</cfif>
			<cfif qFUArchived.recordCount>
				<li><a href="##tabs-3">Archived</a></li>
			</cfif>
		</ul>
		</cfoutput>
	
		<grid:div id="tabs-1">
	
			<ft:form name="frm">
				
				<ft:object typename="farFU" key="newFU" lexcludeFields="label,refObjectID,fuStatus,querystring,applicationname" includeFieldSet="false" />
				<ft:buttonPanel>
					<ft:button value="Add" selectedObjectID="#url.objectid#" />
				</ft:buttonPanel>
	
			</ft:form>	
		</grid:div>
		
		<cfif qFUCurrent.recordCount>
			<grid:div id="tabs-2">
	
					<ft:form bUniFormHighlight="false">
						
						
						<cfoutput query="qFUCurrent" group="fuStatus">
							<h3>
								<cfif qFUCurrent.fuStatus EQ 1>
									System Generated
								<cfelseif qFUCurrent.fuStatus EQ 2>
									Alternative
								</cfif>
							</h3>
							<table class="table-2" cellspacing="0" id="table_friendlyurl">
							<tr>
								<th style="width:20px;">&nbsp;</th>
								<th style="width:40%;">Friendly URL</th>
								<th style="width:30%;">Redirection</th>
								<th>Default</th>
							</tr>
							
							<cfset stPropMetdata="#structNew()#" />
							<cfset stPropMetdata.redirectionType="#structNew()#" />
							<cfset stPropMetdata.friendlyurl.ftStyle="width:100%" />
							<cfset stPropMetdata.redirectionType="#structNew()#" />
							<cfset stPropMetdata.redirectionType.ftStyle="width:90%" />
							<cfset stPropMetdata.redirectTo="#structNew()#" />
							<cfset stPropMetdata.redirectTo.ftStyle="width:100%" />
							
							<cfoutput>
							<ft:object objectid="#qFUCurrent.objectid[currentRow]#" typename="farFU" r_stFields="stFields" stPropMetadata="#stPropMetdata#" r_stPrefix="prefix" />
							<tr class="alt">
								<cfif qFUCurrent.bDefault EQ 1>
									<td>&nbsp;</td>
								<cfelse>
									<td><input type="checkbox" name="lArchiveObjectID" value="#qFUCurrent.objectid#"></td>
								</cfif>
								
								<cfif qFUCurrent.fuStatus EQ 1>
									<td>#stFields.friendlyurl.value#</td>
								<cfelse>
									<td>#stFields.friendlyurl.html#</td>
								</cfif>
								
								<td>
									#stFields.redirectionType.html#
									<div id="#prefix#-redirect-to-wrap" style="<cfif qFUCurrent.redirectionType[currentRow] EQ 'none'>display:none;</cfif>">#stFields.redirectTo.html#</div>
									
									
									<skin:onReady>
										var el = $j('###stFields.redirectionType.FORMFIELDNAME#');	
										$j('###stFields.redirectionType.FORMFIELDNAME#').change(function(){
											var currentValue = $j('###stFields.redirectionType.FORMFIELDNAME#').val();
											if (currentValue != 'none') {												
												$j('###prefix#-redirect-to-wrap').show('blind',{},500);
											} else {
												$j('###prefix#-redirect-to-wrap').hide('blind',{},500);
											}										
										});
									</skin:onReady>
								</td>
								<cfif qFUCurrent.bDefault>
									<td>>>>DEFAULT<<<</td>
								<cfelse>
									<td><ft:button value="Make Default" selectedObjectID="#qFUCurrent.objectid#" size="small" /></td>
								</cfif>
								
							</tr>
							</cfoutput>
							
							
							</table>
						</cfoutput>
						
						<ft:buttonPanel indentForLabel="false">
							<ft:button value="Archive Selected" />
							<ft:button value="Save Changes" />
						</ft:buttonPanel>
					
					</ft:form>	
			</grid:div>
		</cfif>
		
		
		
		
		<cfif qFUArchived.recordCount>
			<grid:div id="tabs-3">
			
					<ft:form bUniFormHighlight="false">
						
						<cfoutput query="qFUArchived" group="fuStatus">
							<h3>Archived</h3>
							<table class="table-2" cellspacing="0" id="table_friendlyurl">
							<tr>
								<th style="width:20px;">&nbsp;</th>
								<th>Friendly URL</th>
							</tr>
							
							<cfoutput>
							<tr class="alt">
								<td><input type="checkbox" name="lDeleteObjectID" value="#qFUArchived.objectid#"></td>
								<td>#qFUArchived.friendlyurl#</td>							
							</tr>
							</cfoutput>
							
							
							</table>
						</cfoutput>
						
						
						<ft:buttonPanel indentForLabel="false">
							<ft:button value="Delete Selected Archives" />
						</ft:buttonPanel>
					
					</ft:form>
					
					
			</grid:div>
		</cfif>
	</grid:div>	
	

<admin:footer>
<cfsetting enablecfoutputonly="false" />