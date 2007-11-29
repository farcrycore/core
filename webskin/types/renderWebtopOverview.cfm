<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Render Webtop Overview --->
<!--- @@description: Renders the Tabs for each status of the object for the Webtop Overview Page  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">

<!------------------ 
START WEBSKIN
 ------------------>
<cfif structKeyExists(stobj,"versionID") AND stobj.versionID NEQ "">
	<!--- IF THIS IS A VERSION OF ANOTHER OBJECT, RUN THIS WEBSKIN WITH THE MAIN VERSION --->
	<cfset html = getView(objectid="#stobj.versionid#", template="renderWebtopOverview", alternateHTML="") />
	<cfif len(html)>
		<cfoutput>#html#</cfoutput>
	<cfelse>
		<cfoutput><h1>OBJECT REVERENCES A VERSION THAT DOES NOT EXIST</h1></cfoutput>
	</cfif>
<cfelse>

	<!--- grab draft object overview --->
	<cfset stDraftObject = StructNew()>
	
	<cfif structKeyExists(stobj,"versionID") AND structKeyExists(stobj,"status") AND stobj.status EQ "approved">
		<cfset qDraft = createObject("component", "#application.packagepath#.farcry.versioning").checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
		<cfif qDraft.recordcount>
			<cfset stDraftObject = getData(qDraft.objectid)>
		</cfif>
	</cfif>



	<extjs:layout id="webtopOverviewViewport" container="Viewport" layout="border">
		<extjs:item region="center" container="TabPanel" activeTab="0">
			
			<cfif StructKeyExists(stobj,"status")>
			
				<cfif len(stobj.status)>
					<cfset mainTabStatus = stobj.status />
				<cfelse>
					<cfset mainTabStatus = "NO STATUS" />
				</cfif>
				
				
				<cfif stobj.status NEQ "" AND NOT structIsEmpty(stDraftObject)>
					<extjs:item title="#stDraftObject.status#" container="Panel" layout="border">
	
 						<extjs:item region="center" container="Panel" layout="border">			
							<extjs:item region="center" autoScroll="true">
								<skin:view objectid="#stDraftObject.objectid#" webskin="webtopOverviewSummary" />
							</extjs:item>
						</extjs:item>	
						<extjs:item region="east" layout="accordion" width="250" cls="webtopOverviewActions">
							<skin:view objectid="#stDraftObject.objectid#" webskin="webtopOverviewActions" />
						</extjs:item>	
						
						
					</extjs:item>
				</cfif>	
			<cfelse>
				<cfset mainTabStatus = "Approved/Live" />
			</cfif>
			<extjs:item title="#mainTabStatus#" container="Panel" layout="border">
				<extjs:item region="center" container="Panel" layout="border">			
					<extjs:item region="center" autoScroll="true">
						<skin:view objectid="#stobj.objectid#" webskin="webtopOverviewSummary" />
					</extjs:item>
				</extjs:item>			
				<extjs:item region="east" layout="accordion" width="250" cls="webtopOverviewActions">
					<skin:view objectid="#stobj.objectid#" webskin="webtopOverviewActions" />
				</extjs:item>	
				
				
			</extjs:item>
		</extjs:item>		
	</extjs:layout>

<!--- 
	<cfset iCounter = 1>
	<cfoutput><!--- all good to display --->
	<div class="tab-container" id="container1">
		<!--- TODO: i18n --->
		<ul class="tabs">
		<cfif StructKeyExists(stobj,"status") AND stobj.status NEQ "">
			<cfif NOT structIsEmpty(stDraftObject)>
				<li onclick="return showPane('pane#iCounter#', this)" id="tab#iCounter#"><a href="##pane1-ref">#stDraftObject.status#</a></li>
				<cfset iCounter = iCounter + 1>
			</cfif>
			<li onclick="return showPane('pane#iCounter#', this)" id="tab#iCounter#"><a href="##pane2-ref">#stobj.status#</a></li>
		<cfelse>
			<li onclick="return showPane('pane#iCounter#', this)" id="tab#iCounter#"><a href="##pane2-ref">Approved/Live</a></li>
		</cfif>
		</ul>
		<div class="tab-panes"> <!--- panes tabs div --->
		<cfset iCounter = 1>
			<cfif NOT structIsEmpty(stDraftObject)>
				<a name="pane#iCounter#-ref"></a> <!--- show draft pane --->
				<div id="pane#iCounter#"> <!--- pane1 --->
				
					
					<div style="float:right;width:200px;"> 
						<skin:view objectid="#stDraftObject.objectid#" webskin="webtopOverviewActions" />
					</div>
					
					<skin:view objectid="#stDraftObject.objectid#" webskin="webtopOverviewSummary" />

					<br style="clear:both;" />
<!--- 						<admin:objectOverview stObject="#stDraftObject#">
							<admin:objectOverviewMenuGroup title="Draft Actions" collapsed="false" icon="/extAccordion/img/silk/accept.png">
								<admin:objectOverviewMenuItem action="EDIT" url="" permissionname="delete" />
								<admin:objectOverviewMenuItem action="APPROVE" url="http://www.news.com.au" />		
							</admin:objectOverviewMenuGroup>
							
							<admin:objectOverviewMenuGroup title="Workflow" collapsed="true" icon="/extAccordion/img/silk/add.png">
								<admin:objectOverviewMenuItem action="button 1" url="" />
								<admin:objectOverviewMenuItem action="News" url="http://www.news.com.au" />	
								<admin:objectOverviewMenuItem action="button 2" url="" />
								<admin:objectOverviewMenuItem action="button 3" url="" />					
							</admin:objectOverviewMenuGroup>
							
						</admin:objectOverview> --->
					
					<!--- #fDisplayObjectOverview(stDraftObject,stLocal.stPermissions)# --->
					
					
				</div> <!--- // pane1 --->
				<cfset iCounter = iCounter + 1>
			</cfif>
	
			<a name="pane#iCounter#-ref"></a> <!--- show approved pane --->
			<div id="pane#iCounter#">
				
				<div style="float:right;width:200px;"> 
					<skin:view objectid="#stobj.objectid#" webskin="webtopOverviewActions" />
				</div>
				
				<skin:view objectid="#stobj.objectid#" webskin="webtopOverviewSummary" />
				
				<br style="clear:both;" />
				
<!--- 					<admin:objectOverview stObject="#stobj#" summaryWebskin="webtopOveriewsomthing">
					
						<admin:objectOverviewMenuGroup title="Main Actions" collapsed="false" icon="/extAccordion/img/silk/accept.png">
							<admin:objectOverviewMenuItem action="EDIT" url="" permissionname="delete" />
							<admin:objectOverviewMenuItem action="APPROVE" url="http://www.news.com.au" />		
						</admin:objectOverviewMenuGroup>
						
						<admin:objectOverviewMenuGroup title="Workflow" collapsed="true" icon="/extAccordion/img/silk/add.png">
							<admin:objectOverviewMenuItem action="button 1" url="" />
							<admin:objectOverviewMenuItem action="News" url="http://www.news.com.au" />	
							<admin:objectOverviewMenuItem action="button 2" url="" />
							<admin:objectOverviewMenuItem action="button 3" url="" />					
						</admin:objectOverviewMenuGroup>
						
						<admin:objectOverviewMenuGroup title="Miscellaneous" collapsed="true" icon="/extAccordion/img/silk/anchor.png">
							<admin:objectOverviewMenuItem action="button 1" url="" />
							<admin:objectOverviewMenuItem action="News" url="http://www.news.com.au" />
							<admin:objectOverviewMenuItem action="button 2" url="" />
							<admin:objectOverviewMenuItem action="button 3" url="" />
							<admin:objectOverviewMenuItem action="button 1" url="" />
							<admin:objectOverviewMenuItem action="News" url="http://www.news.com.au" />
							<admin:objectOverviewMenuItem action="button 2" url="" />
							<admin:objectOverviewMenuItem action="button 3" url="" />
							
						</admin:objectOverviewMenuGroup>
					</admin:objectOverview> --->
				<!--- #fDisplayObjectOverview(stobj,stLocal.stPermissions)# --->
			</div>
		</div> <!--- //panes tabs div --->
	</div>
	</cfoutput> --->

	
</cfif>


<cfsetting enablecfoutputonly="false">

