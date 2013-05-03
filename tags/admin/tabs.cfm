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
<!--- @@displayname:  --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />

<!------------------ 
START TAG
 ------------------>




<cfif thistag.executionMode eq "Start">

	<cfparam name="attributes.id">
	<cfparam name="attributes.class" default="">
	<cfparam name="attributes.default" default="">
	<cfparam name="attributes.aTabs" default="#arrayNew(1)#">
	<cfparam name="attributes.bSticky" default="false">
	<cfparam name="attributes.action" default="">

	
	<cfif structKeyExists(form, "#attributes.id#-tab-current") and len(form['#attributes.id#-tab-current']) >
		<cfset url['#attributes.id#-tab'] = form['#attributes.id#-tab-current'] >
	</cfif>
	
	<cfparam name="url['#attributes.id#-tab']" default="#attributes.default#">
	<cfparam name="session.fc['#attributes.id#-tab']" default="#url['#attributes.id#-tab']#">
	
	
	<cfif structKeyExists(url, '#attributes.id#-tab') and len(url['#attributes.id#-tab'])>
		<cfset request.fc['#attributes.id#-tab'] = url['#attributes.id#-tab']>
	<cfelseif attributes.bSticky>
		<cfset request.fc['#attributes.id#-tab'] = session.fc['#attributes.id#-tab']>
	<cfelse>	
		<cfset request.fc['#attributes.id#-tab'] = attributes.default>
	</cfif>
	
	<cfif attributes.bSticky>
		<cfset session.fc['#attributes.id#-tab'] = request.fc['#attributes.id#-tab']>
	</cfif>
	
	

</cfif>

<cfif thistag.executionMode eq "End">

	<cfif structKeyExists(form, "#attributes.id#-tab-new") and len(form['#attributes.id#-tab-new']) AND form['#attributes.id#-tab-new'] NEQ url['#attributes.id#-tab']>
	
		<cfset refreshURL = application.fapi.fixURL(addValues="#attributes.id#-tab=#form['#attributes.id#-tab-new']#")>
		<skin:location href="#refreshURL#" />
	</cfif>
	
	
	<cfset htmlContent = thisTag.GeneratedContent />
	<cfset panelStyle = "">
	<cfset thisTag.GeneratedContent = "" />

	<cfset currentTab = "">
	<cfif arrayLen( attributes.aTabs )>
		<cfloop from="1" to="#arrayLen( attributes.aTabs )#" index="i">
			<cfif attributes.aTabs[i].bCurrent>
				<cfset currentTab = attributes.aTabs[i].id>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfif not len(currentTab) AND arrayLen( attributes.aTabs )>
		<cfset refreshURL = application.fapi.fixURL(addValues="#attributes.id#-tab=#attributes.aTabs[1].id#")>
		<skin:location href="#refreshURL#" />		
	</cfif>
	
	
<cfoutput>
<div id="#attributes.id#" class="tabbable #attributes.class#"> <!-- Only required for left/right tabs -->
  <ul class="nav nav-tabs">
    <!--- <li class="active"><a href="##tab1" data-toggle="tab">Section 1</a></li> --->
 
  
	<cfloop from="1" to="#arrayLen( attributes.aTabs )#" index="i">
		
		<cfif attributes.aTabs[i].id EQ currentTab>
			<cfset itemClass = "active">
			<cfset htmlContent = "#attributes.aTabs[i].html##htmlContent#" />
		<cfelse>
			<cfset itemClass = "">
		</cfif>
		
		<li class="#itemClass#" tabID="#attributes.aTabs[i].id#">
			<cfif len(attributes.action)>
				<skin:buildLink href="##" onClick="$j('###attributes.id#-tab-new').val('#attributes.aTabs[i].id#');btnSubmit( $j(this).parents('form').attr('id'), '#attributes.action#');return false;">
					#attributes.aTabs[i].title#
				</skin:buildLink>
				<!--- <ft:button value="#attributes.action#" renderType="link" text="#attributes.aTabs[i].title#" onclick="$j('###attributes.id#-tab').val('#attributes.aTabs[i].id#')" /> --->
			<cfelseif len(attributes.aTabs[i].href)>
				<skin:buildLink href="#attributes.aTabs[i].href#" urlParameters="#attributes.id#-tab=#attributes.aTabs[i].id#">
					#attributes.aTabs[i].title#
				</skin:buildLink>
			<cfelse>
				<skin:buildLink href="#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#" urlParameters="#attributes.id#-tab=#attributes.aTabs[i].id#">
					#attributes.aTabs[i].title#
				</skin:buildLink>
			</cfif>
		</li>
	 </cfloop>
  </ul>	 
		 	  
  <div class="tab-content">
    <div class="tab-pane active">
      #htmlContent#
    </div>
  </div>
</div>
	<input type="hidden" id="#attributes.id#-tab-current" name="#attributes.id#-tab-current" value="#request.fc['#attributes.id#-tab']#" />
	<input type="hidden" id="#attributes.id#-tab-new" name="#attributes.id#-tab-new" value="" />
</cfoutput>
	
	<!--- 
	
	<cfoutput>
	<div id="#attributes.id#" class="ui-tabs ui-widget ui-widget-content ui-corner-all #attributes.class#" style="width:100%;">
		<ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="border-width:0 0 1px 0;">
			<cfloop from="1" to="#arrayLen( attributes.aTabs )#" index="i">
				
				<cfif attributes.aTabs[i].id EQ currentTab>
					<cfset itemStyle = "background-color:##fff;">
					<cfset itemClass = "ui-tabs-selected ui-state-active">
					<cfset htmlContent = "#attributes.aTabs[i].html##htmlContent#" />
					<cfset panelStyle = "#attributes.aTabs[i].panelStyle#">
				<cfelse>
					<cfset itemStyle = "">
					<cfset itemClass = "">
				</cfif>
				
				<li style="#itemStyle#" class="ui-state-default ui-corner-top #itemClass#" tabID="#attributes.aTabs[i].id#">
					<cfif len(attributes.action)>
						<skin:buildLink href="##" onClick="$j('###attributes.id#-tab-new').val('#attributes.aTabs[i].id#');btnSubmit( $j(this).parents('form').attr('id'), '#attributes.action#');return false;">
							#attributes.aTabs[i].title#
						</skin:buildLink>
						<!--- <ft:button value="#attributes.action#" renderType="link" text="#attributes.aTabs[i].title#" onclick="$j('###attributes.id#-tab').val('#attributes.aTabs[i].id#')" /> --->
					<cfelseif len(attributes.aTabs[i].href)>
						<skin:buildLink href="#attributes.aTabs[i].href#" urlParameters="#attributes.id#-tab=#attributes.aTabs[i].id#">
							#attributes.aTabs[i].title#
						</skin:buildLink>
					<cfelse>
						<skin:buildLink href="#application.fapi.getLink()#" urlParameters="#attributes.id#-tab=#attributes.aTabs[i].id#">
							#attributes.aTabs[i].title#
						</skin:buildLink>
					</cfif>
				</li>
			 </cfloop>
		</ul>
		
		<div class="ui-tabs-panel ui-widget-content ui-corner-bottom" style="#panelStyle#">
			#htmlContent#
		</div>
	</div>
	<input type="hidden" id="#attributes.id#-tab-current" name="#attributes.id#-tab-current" value="#request.fc['#attributes.id#-tab']#" />
	<input type="hidden" id="#attributes.id#-tab-new" name="#attributes.id#-tab-new" value="" />
	</cfoutput> --->
</cfif>

<cfsetting enablecfoutputonly="false">

