<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />


<!--- 
manage friendly urls for a particular object id
 --->

<cfparam name="fatalerrormessage" default="" />
<cfparam name="errormessage" default="" />
<cfparam name="bFormSubmitted" default="no" />
<cfparam name="friendly_url" default="" />
<cfparam name="additional_params" default="" />
<cfparam name="lArchiveObjectID" default="" />
<cfparam name="fuStatus" default="2" />
<cfparam name="redirectionType" default="301" />
<cfparam name="redirectTo" default="system" />


<cfset stRefObject = application.coapi.coapiUtilities.getContentObject(objectid="#stObj.objectid#") />

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
			<skin:bubble title="Alternative Friendly URL Created" autoHide="true" tags="type,farFU,created,info">
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


<cfset qFUCurrent = application.fc.factory.farFU.getFUList(objectid=stObj.objectid, fuStatus="current") />
<cfset qFUArchived = application.fc.factory.farFU.getFUList(objectid=stObj.objectid, fuStatus="archived") />


<cfoutput>
	<h1>
		<cfif len(application.stCOAPI[stobj.typename].icon)>
			<i class="fa #application.stCOAPI[stobj.typename].icon#"></i>
		<cfelse>
			<i class="fa fa-file"></i>
		</cfif>
		#stobj.label#
	</h1>
</cfoutput>


<admin:tabs id="fu-tabs">
	<admin:tabItem id="create-alternative" title="Add Alternative URL">
		<ft:form>
			<ft:object typename="farFU" key="newFU" lexcludeFields="label,refObjectID,fuStatus,querystring,applicationname" includeFieldSet="false" />
			<ft:buttonPanel>
				<ft:button value="Add" selectedObjectID="#stObj.objectid#" />
				<cfoutput><a href="##" class="btn" onclick="$fc.closeBootstrapModal(); return false;">Close</a></cfoutput>
			</ft:buttonPanel>
		</ft:form>	
	</admin:tabItem>      
	
	<cfif qFUCurrent.recordCount>
		<admin:tabItem id="current" title="Default URL">
			<ft:form>
				<cfoutput><table class="table table-striped"></cfoutput>
				
				<cfoutput query="qFUCurrent" group="fuStatus">
					<cfset stPropMetdata="#structNew()#" />
					<cfset stPropMetdata.redirectionType="#structNew()#" />
					<cfset stPropMetdata.friendlyurl.ftStyle="width:280px;" />
					<cfset stPropMetdata.redirectionType="#structNew()#" />
					<cfset stPropMetdata.redirectionType.ftStyle="width:210;" />
					<cfset stPropMetdata.redirectTo="#structNew()#" />
					<cfset stPropMetdata.redirectTo.ftStyle="width:210px;" />
					
					<ft:object objectid="#qFUCurrent.objectid[currentRow]#" typename="farFU" r_stFields="stFields" stPropMetadata="#stPropMetdata#" r_stPrefix="prefix" />
					
					<thead>
						<tr>
							<td colspan="5" style="border-top:0 none transparent;">
								<h3 style="margin-bottom:0">
									<cfif qFUCurrent.fuStatus EQ 1>
										System Generated URL
									<cfelseif qFUCurrent.fuStatus EQ 2>
										Alternative URLs
									</cfif>
								</h3>
							</td>
						</tr>
						<tr>
							<th style="border-top:0 none transparent;">&nbsp;</th>
							<th style="border-top:0 none transparent;">Friendly URL</th>
							<th style="border-top:0 none transparent;">Redirection</th>
							<th style="border-top:0 none transparent;">Redirect To</th>
							<th style="border-top:0 none transparent;">Default</th>
						</tr>
					</thead>
					<tbody>
						<cfoutput>
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
								
								<td>#stFields.redirectionType.html#</td>
								<td>
									<span id="#prefix#-redirect-to-wrap" style="<cfif qFUCurrent.redirectionType[currentRow] EQ 'none'>display:none;</cfif>"
										#stFields.redirectTo.html#
									</span>
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
									<td><ft:button value="Make Default" selectedObjectID="#qFUCurrent.objectid#" /></td>
								</cfif>
								
							</tr>
						</cfoutput>
						<tr><td colspan="5">&nbsp;</td></tr>
					</tbody>
				</cfoutput>
				
				<cfoutput></table></cfoutput>
				
				<ft:buttonPanel indentForLabel="false">
					<ft:button class="btn-primary" value="Save Changes" />
					<ft:button class="btn-primary" value="Archive Selected" />
					<cfoutput><a href="##" class="btn" onclick="$fc.closeBootstrapModal(); return false;">Close</a></cfoutput>
				</ft:buttonPanel>
			
			</ft:form>
		</admin:tabItem>     
	</cfif>
	
	<cfif qFUArchived.recordCount>
		<admin:tabItem id="archived" title="Archived URLs">
			<ft:form>
				<cfoutput query="qFUArchived" group="fuStatus">
					<h3>Archived</h3>
					<table class="table table-striped" cellspacing="0" id="table_friendlyurl">
					<thead>
					<tr>
						<th style="width:20px;">&nbsp;</th>
						<th>Friendly URL</th>
					</tr>
					</head>

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
					<cfoutput><a href="##" class="btn" onclick="$fc.closeBootstrapModal(); return false;">Close</a></cfoutput>
				</ft:buttonPanel>
			</ft:form>
		</admin:tabItem>     
	</cfif>	
</admin:tabs>

<cfsetting enablecfoutputonly="false" />