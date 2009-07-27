<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />

<cfimport taglib="/farcry/core/tags/security" prefix="sec" />

<cfset session.fc.trayWebskin = "displayAdminBarDetail" />



<skin:onReady>
<cfoutput>
$j('##hide-tray').click(function(){
	$fc.traySwitch('displayAdminBarHidden');
});
$j('##show-summary').click(function(){
	$fc.traySwitch('displayAdminBarSummary');
});
</cfoutput>
</skin:onReady>

<cfoutput>
<div class="tray-detail" style="display:block;margin-left:15px;margin-right:15px;overflow:visible !important;position:relative;border:1px solid ##B5B5B5;border-width:1px 1px 0px 1px;background-color:##E5E5E5;">
	<div style="display:block;padding:0;border-top:1px solid ##FFFFFF;">
		<div style="">
</cfoutput>




<!--- If the url points to a type webskin, we need to determine the content type. --->
<cfif stObj.typename eq "farCOAPI">
	<cfset contentTypename = stobj.name />
<cfelse>
	<cfset contentTypename = stobj.typename />
</cfif>


	
	<grid:div style="float:left;">
		<cfoutput>
			<a id="hide-tray" class="ui-icon toggletray_icon" style="float:left;"></a>
			<a id="show-summary" class="ui-icon lessdetail_icon" style="float:left;"></a>
		</cfoutput>
	</grid:div>

	<grid:div style="float:left;">
		<cfoutput><img class='traytypeicon' src='#application.url.webtop#/facade/icon.cfm?icon=#contentTypename#&size=48' alt='#stObj.typename#' /></cfoutput>
	</grid:div>
	
	
	<grid:div style="float:left;width:50%;">
		<cfoutput>
		<dl>
			<dt>Type:</dt>
			<dd>#application.fapi.getContentTypeMetadata(typename="#contentTypename#", md="displayName", default="#contentTypename#")#</dd>
			
			<cfif stobj.locked>
				<dt>Locked:</dt>
				<dd>
					<span style='color:red'>#application.rb.formatRBString("workflow.labels.lockedwhen@label",tDT,"Locked ({1})")#</span>
					
					<cfif application.fapi.isLoggedIn()>
						<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(stobj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)#,#stobj.lockedby#')>
						#application.rb.formatRBString('workflow.labels.lockedby@label',subS,'<span style=\"color:red\">Locked ({1})</span> by {2}')#
						
						<cfif application.fapi.getCurrentUsersProfile().userID EQ stobj.lockedby OR iDeveloperPermission>
							<a href='#application.url.webtop#/navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#' onclick='alert("TODO: Unlocking");return false;'>[#application.rb.getResource("workflow.buttons.unlock@label","Unlock")#]</a>
						</cfif>
						
					</cfif>
				</dd>
			</cfif>
			
			<dt>#getI18Property('datetimelastupdated','label')#</dt>
			<dd>#application.thisCalendar.i18nDateFormat(stobj.datetimelastupdated,session.dmProfile.locale,application.mediumF)#</dd>
			
			<dt>#getI18Property('lastupdatedby','label')#</dt>
			<dd>#stobj.lastupdatedby#</dd>
			
			<cfif structkeyexists(stObj,"status")>
				<dt>#getI18Property('Status','label')#</dt>
				<dd>#application.rb.getResource('workflow.constants.#stobj.status#@label',stObj.status)#</dd>
			</cfif>
			
			
			<!--- Editing the object --->
			<sec:CheckPermission objectid="#stObj.objectid#" typename="#stObj.typename#" permission="Edit">
				<cfif not stObj.typename eq "farCOAPI">
					<cfset editurl = "#application.url.webtop#/edittabOverview.cfm?objectid=#stObj.objectid#&typename=#stObj.typename#&method=edit&ref=typeadmin" />
				
					<cfoutput>
						<dt>Edit:</dt>
						<dd><a href="#editurl#">edit</a></dd>
						<!--- 	editContent("#editurl#","Edit #stObj.label#",800,600,true,function(){
							// make sure the object is unlocked
							Ext.Ajax.request({ 
								url: "#application.url.webtop#/navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stObj.typename#",  --->
						
											
					</cfoutput>
		
				</cfif>
			</sec:CheckPermission>
		</dl>
		</cfoutput>
	
	</grid:div>	
		

	
	<grid:div style="float:right;">
		
		<cfoutput>
			<ul>
			
				<cfif request.mode.flushcache>
					<li>
						<skin:buildLink href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=0')#">
							<img class='traytypeicon' src='#application.url.webtop#/facade/icon.cfm?icon=redled&size=16' alt='OFF' />
							Cache
						</skin:buildLink>
					</li>
				<cfelse>
					<li>
						<skin:buildLink href="#cgi.HTTP_REFERER#" urlParameters="flushcache=1">
							<img class='traytypeicon' src='#application.url.webtop#/facade/icon.cfm?icon=greenled&size=16' alt='ON' />
							Cache
						</skin:buildLink>
					</li>
					<!--- <span class='ui-icon ui-icon-triangle-1-e' style='margin-top:-8px;position:absolute;top:50%;'/><span style='padding:0.5em 0.5em 0.5em 2.2em;'>Cache On</span> --->
				</cfif>
				
				
				<cfif request.mode.showdraft>		
					<li><ft:button value="Show Drafts ON" type="button" renderType="link" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=1&showdraft=0')#" /></li>
				<cfelse>
					<li><ft:button value="Show Drafts OFF" type="button" renderType="link" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=0&showdraft=1')#" /></li>
				</cfif>
				
				
				<cfif request.mode.design and request.mode.showcontainers gt 0>
					<li><ft:button value="Edit Rules ON" type="button" renderType="link" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='designmode=0')#" /></li>
				<cfelse>
					<li><ft:button value="Edit Rules OFF" type="button" renderType="link" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='designmode=1')#" /></li>
				</cfif>
										
													
				<cfif findnocase("#cgi.query_string#","bdebug=1")>
					<li><ft:button value="Debug ON" type="button" renderType="link" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='bDebug=0')#" /></li>
				<cfelse>
					<li><ft:button value="Debug OFF" type="button" renderType="link" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='bDebug=1')#" /></li>
				</cfif>
													
				<cfif request.mode.traceWebskins EQ 1>
					<li><ft:button value="Trace Webskins ON" type="button" renderType="link" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='tracewebskins=0')#" /></li>
				<cfelse>
					<li><ft:button value="Trace Webskins OFF" type="button" renderType="link" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='tracewebskins=1')#" /></li>
				</cfif>
			
			</ul>
		</cfoutput>
	</grid:div>
	


<cfoutput>
		</div>
		<br style="clear:both;" />
	</div>
</div>
</cfoutput>
