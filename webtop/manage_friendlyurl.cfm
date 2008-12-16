<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs">


<!--- 
manage friednly urls for a particular object id
 --->

<cfparam name="url.objectid" default="">
<cfparam name="fatalerrormessage" default="">
<cfparam name="errormessage" default="">
<cfparam name="bFormSubmitted" default="no">
<cfparam name="friendly_url" default=""><!--- #application.config.fusettings.urlpattern# --->
<cfparam name="additional_params" default="">
<cfparam name="lArchiveObjectID" default="">
<cfparam name="fuStatus" default="2">
<cfparam name="redirectionType" default="301">
<cfparam name="redirectTo" default="system">


<cfset stRefObject = application.coapi.coapiUtilities.getContentObject(objectid="#url.objectid#") />

<ft:processForm action="Save Changes,Make Default,Archive Selected,Delete Selected Archives">
	<ft:processFormObjects typename="farFU">
		<cfset stProperties.friendlyURL = application.fc.factory.farFU.cleanFU(friendlyURL="#stProperties.friendlyURL#",objectid="#stProperties.objectid#") />
		
		<cfset application.fc.factory.farFU.setMapping(objectid="#stProperties.objectid#") />
		
	</ft:processFormObjects>
</ft:processForm>

<ft:processForm action="Add" url="refresh">
	
	<ft:processFormObjects typename="farFU">
		
		<cfset stProperties.refObjectID = form.selectedObjectID />
		
		<cfset stResult = application.fc.factory.farFU.createCustomFU(argumentCollection="#stProperties#") />
		
		<cfif not stResult.bSuccess>
			<extjs:bubble title="#stResult.message#" autoHide="false" />
		<cfelse>
			<extjs:bubble title="Custom Friendly URL Created" autoHide="true">
				<cfoutput>Your Friendly URL (#stProperties.friendlyURL#) has been created.</cfoutput>
			</extjs:bubble>
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
	<extjs:bubble title="Invalid ObjectID" autoHide="false" />
</cfif>


<admin:header title="Manage Friendly URL's">
	

	<cfoutput><h1>Manage Friendly URL's for #stRefObject.label# (#stRefObject.typename#)</h1></cfoutput>
	
	<extjs:tab id="manageFriendlyURLs">
		<extjs:tabPanel id="createCustom" title="Create Custom" autoheight="true" style="padding:10px;">
			<ft:form name="frm">
				
				<ft:object typename="farFU" key="newFU" lexcludeFields="label,refObjectID,fuStatus" includeFieldSet="false" />
				<ft:farcryButtonPanel>
					<ft:button value="Add" selectedObjectID="#url.objectid#" />
				</ft:farcryButtonPanel>

			</ft:form>
		</extjs:tabPanel>

		
		<cfset qFUList = application.fc.factory.farFU.getFUList(objectid="#url.objectid#", fuStatus="current") />
		
		<cfif qFUList.recordCount>
			<extjs:tabPanel id="current" title="Current" autoheight="true" style="padding:10px;">

				<ft:form>
					
					
					<cfoutput query="qFUList" group="fuStatus">
						<h3>
							<cfif qFUList.fuStatus EQ 1>
								System Generated
							<cfelseif qFUList.fuStatus EQ 2>
								Custom
							</cfif>
						</h3>
						<table class="table-2" cellspacing="0" id="table_friendlyurl">
						<tr>
							<th>&nbsp;</th>
							<th>Friendly URL</th>
							<th>Query String</th>
							<th>Redirection</th>
							<th>Default</th>
						</tr>
						
						<cfoutput>
						<ft:object objectid="#qFUList.objectid[currentRow]#" typename="farFU" r_stFields="stFields" r_stPrefix="prefix" />
						<tr class="alt">
							<td><input type="checkbox" name="lArchiveObjectID" value="#qFUList.objectid#"></td>
							<td>#stFields.friendlyurl.html#</td>
							<td>#stFields.queryString.html#</td>
							<td>
								#stFields.redirectionType.html#
								<div id="#prefix#-redirect-to-wrap" style="<cfif qFUList.redirectionType[currentRow] EQ 'none'>display:none;</cfif>">#stFields.redirectTo.html#</div>
								
								<extjs:onReady>
									var el = Ext.get('#stFields.redirectionType.FORMFIELDNAME#');	
									el.on('change', function(n,c) {
										var currentValue = Ext.getDom('#stFields.redirectionType.FORMFIELDNAME#').value;
										if (currentValue != 'none') {
											
											Ext.get('#prefix#-redirect-to-wrap').slideIn('t', {
											    easing: 'easeIn',
											    duration: .5,
											    useDisplay: true
											});
										} else {
											Ext.get('#prefix#-redirect-to-wrap').slideOut('t', {
											    easing: 'easeOut',
											    duration: .5,
											    useDisplay: true
											});
										}
									});	
								</extjs:onReady>
							</td>
							<cfif qFUList.bDefault>
								<td>>>>DEFAULT<<<</td>
							<cfelse>
								<td><ft:button value="Make Default" selectedObjectID="#qFUList.objectid#" size="small" /></td>
							</cfif>
							
						</tr>
						</cfoutput>
						
						
						</table>
					</cfoutput>
					
					<ft:farcryButtonPanel indentForLabel="false">
						<ft:button value="Archive Selected" />
						<ft:button value="Save Changes" />
					</ft:farcryButtonPanel>
				
				</ft:form>
			</extjs:tabPanel>
		</cfif>
		
		
		<cfset qFUList = application.fc.factory.farFU.getFUList(objectid="#url.objectid#", fuStatus="archived") />
		
		<cfif qFUList.recordCount>
			<extjs:tabPanel id="archive" title="Archive" autoheight="true" style="padding:10px;">
		
				
				<ft:form>
					
					<cfoutput query="qFUList" group="fuStatus">
						<h3>Archived</h3>
						<table class="table-2" cellspacing="0" id="table_friendlyurl">
						<tr>
							<th>&nbsp;</th>
							<th>Friendly URL</th>
							<th>Query String</th>
						</tr>
						
						<cfoutput>
						<tr class="alt">
							<td><input type="checkbox" name="lDeleteObjectID" value="#qFUList.objectid#"></td>
							<td>#qFUList.friendlyurl#</td>
							<td>#qFUList.queryString#</td>
							
						</tr>
						</cfoutput>
						
						
						</table>
					</cfoutput>
					
					
					<ft:farcryButtonPanel indentForLabel="false">
						<ft:button value="Delete Selected Archives" />
					</ft:farcryButtonPanel>
				
				</ft:form>
			</extjs:tabPanel>
		</cfif>
	</extjs:tab>

<admin:footer>
<cfsetting enablecfoutputonly="false">
