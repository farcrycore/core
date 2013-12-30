<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
<!--- @@displayname: Webtop Overview Summary --->
<!--- @@description: The default webskin to use to render the object's summary in the webtop overview screen  --->


<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />


<!--- 
 // view 
--------------------------------------------------------------------------------->
<skin:view stObject="#stObj#" webskin="webtopOverviewDevActions" />


<ft:fieldset legend="#application.fapi.getContentTypeMetadata(stobj.typename,'displayname',stobj.typename)# Information">
	
	<!--- If this is the draft version then check to see if there are actually any differences --->
	<cfif structkeyexists(stObj,"status") and stObj.status eq "draft" and structkeyexists(stObj,"versionid") and len(stObj.versionID)>
		<cfset stLocal.stResults = application.fc.lib.diff.getObjectDiff(getData(objectid=stObj.versionID),stObj) />
		<cfif stLocal.stResults.countDifferent eq 0>
			<cfoutput>
				<div class="alert alert-warning" style="margin-top: 0; margin-bottom: 1.5em">
					<i class="fa fa-exclamation-triangle"></i>&nbsp;
					This draft is identical to the approved version.
					<a href="navajo/delete.cfm?ObjectId=#stobj.objectId#&returnto=#application.fc.lib.esapi.encodeForURL('#cgi.script_name#?objectid=#stObj.versionid#&ref=#url.ref#')#&ref=#url.ref#" onclick="if (!confirm('Are you sure you wish to discard this draft version? The approved version will remain.')) return false;">Discard draft</a>?
				</div>
			</cfoutput>
		</cfif>
	</cfif>
	
	<ft:field label="Label" bMultiField="true">
		<cfoutput>#stobj.label#</cfoutput>
	</ft:field>	
	
	
	<!--- breadcrumb for content in the tree --->
	<cfif application.fapi.getContentTypeMetadata(stobj.typename,'bUseInTree',false)>
		
		<nj:getNavigation objectId="#stobj.objectid#" r_objectID="parentID" bInclusive="1">
		
		<cfif len(parentID)>
			<ft:field label="Breadcrumb" bMultiField="true">
			
				<cfif len(parentID)>
					<cfif stobj.typename EQ "dmNavigation">
						<cfset qAncestors = application.factory.oTree.getAncestors(objectid=parentID,bIncludeSelf=false) />
					<cfelse>
						<cfset qAncestors = application.factory.oTree.getAncestors(objectid=parentID,bIncludeSelf=true) />
					</cfif>
					
					<cfif qAncestors.recordCount>
						<cfloop query="qAncestors">
								<skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="typename=dmNavigation&objectID=#qAncestors.objectid#" linktext="#qAncestors.objectName#" />
							<cfoutput>&nbsp;&raquo;&nbsp;</cfoutput>
						</cfloop>
						<cfoutput>#stobj.label#</cfoutput>
					<cfelse>
						<cfoutput>#stobj.label#</cfoutput>
					</cfif>
				</cfif>
			
				
				<ft:fieldHint>
					<cfoutput>
					This shows you the selected content item in the context of your site. 
					You can <ft:button value="create a child" renderType="link" url="#application.url.farcry#/conjuror/evocation.cfm?parenttype=dmNavigation&objectId=#parentID#&typename=dmNavigation&ref=#url.ref#" /> navigation item under this.
					</cfoutput>
				</ft:fieldHint>
			</ft:field>
		<cfelse>

			<ft:field label="Breadcrumb" bMultiField="true">
			
				<cfoutput>--- not in tree ---</cfoutput>
			
				<ft:fieldHint>
					<cfoutput>
					This shows you the selected content item in the context of your site. 
					</cfoutput>
				</ft:fieldHint>
			</ft:field>		
		</cfif>
	</cfif>		
	
	
	<!--- show common properties --->
	<cfif structKeyExists(stobj, "teaser")>
		<ft:field label="Teaser" bMultiField="true">
			<cfoutput><cfif len(stobj.teaser)>#stobj.teaser#<cfelse>-- none --</cfif></cfoutput>
		</ft:field>
	</cfif>
	<cfif structKeyExists(stobj, "displayMethod")>
		<ft:field label="Webskin">
			<cfoutput>#application.fapi.getWebskinDisplayName(stobj.typename, stobj.displayMethod)# (#stobj.displayMethod#)</cfoutput>
		</ft:field>
	</cfif>
	
	
	<!--- Categorization --->
	<cfset lCatProps = "" />
	<cfloop list="#structKeyList(application.stcoapi[stobj.typename].stProps)#" index="iProp">
		<cfif application.fapi.getPropertyMetadata(stobj.typename, iProp, "ftType", "") EQ "category">
			<cfset lCatProps = listAppend(lCatProps, iProp) />
		</cfif>
	</cfloop>
	
	<cfif listLen(lCatProps)>
		<ft:field label="Categories" hint="Categories can allow users to more easily find your content.">
			<cfoutput>
			<cfloop list="#lCatProps#" index="iProp">
				<div>
					<strong>#application.fapi.getPropertyMetadata(stobj.typename, iProp, "ftLabel", iProp)#:</strong>
					<cfset lCats = "none" />
					<cfif listLen(stobj[iProp])>
						<cfloop list="#stobj[iProp]#" index="catid">		
							<cfset lCats = listAppend(lCats,application.factory.oCategory.getCategoryNameByID(catid)) />
						</cfloop>
					</cfif>
					#lCats#
				</div>
			</cfloop>
			</cfoutput>
		</ft:field>
	</cfif>
</ft:fieldset>


<cfsetting enablecfoutputonly="false">