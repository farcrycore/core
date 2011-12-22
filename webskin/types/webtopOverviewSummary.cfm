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
<!--- @@displayname: Webtop Overview --->
<!--- @@description: The default webskin to use to render the object's summary in the webtop overview screen  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />

<!------------------ 
START WEBSKIN
 ------------------>

<skin:htmlHead id="select-text"><cfoutput><script type="text/javascript">
	function selectText(element) {
	    var doc = document;
	    if (typeof(element) == "String") element = doc.getElementById(element);    
	    if (doc.body.createTextRange) { // ms
	        var range = doc.body.createTextRange();
	        range.moveToElementText(element);
	        range.select();
	    } else if (window.getSelection) {
	        var selection = window.getSelection();
	        if (selection.setBaseAndExtent) { // webkit
	            selection.setBaseAndExtent(element, 0, element, 1);
	        } else { // moz, opera
	            var range = doc.createRange();
	            range.selectNodeContents(element);
	            selection.removeAllRanges();
	            selection.addRange(range);
	        }
	    }
	}
</script></cfoutput></skin:htmlHead>
<cfoutput>
	<div class="developer-actions">
		<div class="objectid" style="display:none;">#stObj.objectid#</div>
		<a onclick="var oid = $j(this).siblings('.objectid').toggle();selectText(oid[0]);return false;" title="See objectid" class="ui-icon ui-icon-tag">&nbsp;</a>
		<a onclick="$fc.openDialog('Property Dump', '#application.url.farcry#/object_dump.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#');return false;" title="Open a window containing all the raw data of this content item" class="ui-icon ui-icon-calculator">&nbsp;</a>
	</div>
</cfoutput>

<ft:fieldset legend="#application.fapi.getContentTypeMetadata(stobj.typename,'displayname',stobj.typename)# Information">
	
	<!--- If this is the draft version then check to see if there are actually any differences --->
	<cfif structkeyexists(stObj,"status") and stObj.status eq "draft" and structkeyexists(stObj,"versionid") and len(stObj.versionID)>
		<cfset stLocal.stResults = application.fc.lib.diff.performObjectDiff(getData(objectid=stObj.versionID),stObj) />
		<cfif stLocal.stResults.countDifferent eq 0>
			<cfoutput>
				<div id="OKMsg"><p>
					<span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;">&nbsp;</span>
					Your draft is identical to the approved version. 
					<a href="navajo/delete.cfm?ObjectId=#stobj.objectId#&returnto=#urlencodedformat('#cgi.script_name#?objectid=#stObj.versionid#&ref=#url.ref#')#&ref=#url.ref#" onclick="if (!confirm('Are you sure you wish to discard this draft version? The approved version will remain.')) return false;">Discard draft</a>?
				</p></div>
			</cfoutput>
		</cfif>
	</cfif>
	
	<ft:field label="Label" bMultiField="true">
		<cfoutput>#stobj.label#</cfoutput>
	</ft:field>	
	
	
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
								<skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="objectID=#qAncestors.objectid#" linktext="#qAncestors.objectName#" />
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