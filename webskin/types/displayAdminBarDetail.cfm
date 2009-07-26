<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

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
<div style="display:block;margin-left:15px;margin-right:15px;overflow:visible !important;position:relative;border:1px solid ##B5B5B5;border-width:1px 1px 0px 1px;background-color:##E5E5E5;">
	<div style="display:block;padding:0;border-top:1px solid ##FFFFFF;">
		<div style="float:left;">
</cfoutput>


<ft:form validation="false">
<cfoutput>
<a id="hide-tray" class="ui-icon toggletray_icon"></a>
<a id="show-summary" class="ui-icon lessdetail_icon"></a>
</cfoutput>

	

	
	<cfif stObj.typename eq "farCOAPI">
		<cfset currenttype = stObj.name />
	<cfelse>
		<cfset currenttype = stObj.typename />
	</cfif>
	
	<cfif structKeyExists(application.stcoapi,"#currenttype#") AND structKeyExists(application.stcoapi[currenttype],"displayname")>
		<cfoutput><p>"#application.stcoapi[currenttype].displayname#"</p></cfoutput>
	<cfelse>
		<cfoutput><p>"#currenttype#"</p></cfoutput>
	</cfif>
	
	
	
				<cfoutput>
					<p>Locking:</p>
				</cfoutput>
					
					<cfif stobj.locked and stobj.lockedby eq session.security.userid>
						<!--- locked by current user --->
						<cfset tDT=application.thisCalendar.i18nDateTimeFormat(stobj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)>
						<cfoutput>
							"<span style='color:red'>#application.rb.formatRBString("workflow.labels.lockedwhen@label",tDT,"Locked ({1})")#</span> <a href='#application.url.webtop#/navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#' onclick='Ext.getBody().mask(\"Working...\");Ext.Ajax.request({url:this.href,success:function(){ location.href=location.href; } });return false;' target='_top'>[#application.rb.getResource("workflow.buttons.unlock@label","Unlock")#]</a>"
						</cfoutput>
					<cfelseif stobj.locked>
						<!--- locked by another user --->
						<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(stobj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)#,#stobj.lockedby#')>
						<cfoutput>"#application.rb.formatRBString('workflow.labels.lockedby@label',subS,'<span style=\"color:red\">Locked ({1})</span> by {2}')#</cfoutput>
						
						<!--- check if current user is a sysadmin so they can unlock --->
						<cfif iDeveloperPermission eq 1><!--- show link to unlock --->
							<cfoutput><a href='#application.url.webtop#/navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#' onclick='Ext.getBody().mask(\"Working...\");Ext.Ajax.request({url:this.href,success:function(){ location.href=location.href; } });return false;' target='_top'>[#application.rb.getResource("workflow.buttons.unlock@label","Unlock")#]</a></cfoutput>
						</cfif>
						
						<cfoutput>"</cfoutput>
					<cfelse><!--- no locking --->
						<cfoutput>"#application.rb.getResource("workflow.labels.unlocked@unlocked","Unlocked")#"</cfoutput>
					</cfif>
				
				<cfoutput>,
				<p>"#getI18Property('datetimelastupdated','label')#"</p>
				<p>"#application.thisCalendar.i18nDateFormat(stobj.datetimelastupdated,session.dmProfile.locale,application.mediumF)#"</p>
				<p>"#getI18Property('lastupdatedby','label')#"</p>
				<p>"#stobj.lastupdatedby#"</p>
				</cfoutput>
				
				<cfif structkeyexists(stObj,"status")>
					<cfoutput>
						<p>"#getI18Property('status','label')#"</p>
						<p>"#application.rb.getResource('workflow.constants.#stobj.status#@label',stObj.status)#"</p>
					</cfoutput>
				</cfif>
				
				<cfif structkeyexists(stObj,"displaymethod")>
					<cfquery dbtype="query" name="qWebskin">
						select		displayname
						from		application.stCOAPI.#stObj.typename#.qWebskins
						where		name='#stObj.displaymethod#.cfm'
					</cfquery>
					
					<cfoutput>
						<p>"#getI18Property('displaymethod','label')#"</p>
						<p>"#qWebskin.displayname#"</p>
					</cfoutput>
				</cfif>
		

	
	
	
	<!--- Editing the object --->
	<sec:CheckPermission objectid="#stObj.objectid#" typename="#stObj.typename#" permission="Edit">
		<cfif not stObj.typename eq "farCOAPI">
			<cfset editurl = "#application.url.webtop#/edittabOverview.cfm?objectid=#stObj.objectid#&typename=#stObj.typename#&method=edit&ref=typeadmin" />
		
			<cfoutput>
				<p>"Edit" </p>
				<p>editContent("#editurl#","Edit #stObj.label#",800,600,true,function(){
									// make sure the object is unlocked
									Ext.Ajax.request({ 
										url: "#application.url.webtop#/navajo/unlock.cfm?objectid=#stObj.objectid#&typename=#stObj.typename#", 
				</p>
									
			</cfoutput>

		</cfif>
	</sec:CheckPermission>
	
	<cfoutput>
		<p><a href='#application.url.webtop#/' class='webtoplink' title='Webtop' target='_top'><img class='traytypeicon' src='#application.url.webtop#/facade/icon.cfm?icon=#stObj.typename#&size=48' alt='#stObj.typename#' /></a></p>
	</cfoutput>	




<cfif request.mode.flushcache>
	<ft:button value="Cache OFF" type="button" class="ui-state-default ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=0')#" />
<cfelse>
	<ft:button value="Cache ON" type="button" class="ui-state-active ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=1')#" />
	<!--- <span class='ui-icon ui-icon-triangle-1-e' style='margin-top:-8px;position:absolute;top:50%;'/><span style='padding:0.5em 0.5em 0.5em 2.2em;'>Cache On</span> --->
</cfif>


<cfif request.mode.showdraft>		
	<ft:button value="Show Drafts ON" type="button" class="ui-state-active ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=1&showdraft=0')#" />
<cfelse>
	<ft:button value="Show Drafts OFF" type="button" class="ui-state-default ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=0&showdraft=1')#" />
</cfif>


<cfif request.mode.design and request.mode.showcontainers gt 0>
	<ft:button value="Edit Rules ON" type="button" class="ui-state-active ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='designmode=0')#" />
<cfelse>
	<ft:button value="Edit Rules OFF" type="button" class="ui-state-default ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='designmode=1')#" />
</cfif>
						
									
<cfif findnocase("#cgi.query_string#","bdebug=1")>
	<ft:button value="Debug ON" type="button" class="ui-state-active ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='bDebug=0')#" />
<cfelse>
	<ft:button value="Debug OFF" type="button" class="ui-state-default ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='bDebug=1')#" />
</cfif>
									
<cfif request.mode.traceWebskins EQ 1>
	<ft:button value="Trace Webskins ON" type="button" class="ui-state-active ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='tracewebskins=0')#" />
<cfelse>
	<ft:button value="Trace Webskins OFF" type="button" class="ui-state-default ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='tracewebskins=1')#" />
</cfif>

</ft:form>


<cfoutput>
		</div>
		<br style="clear:both;" />
	</div>
</div>
</cfoutput>
