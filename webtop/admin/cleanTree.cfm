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
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/admin/cleanTree.cfm,v 1.7 2005/08/16 05:53:23 pottery Exp $
$Author: pottery $
$Date: 2005/08/16 05:53:23 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: tree cleaner. $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="Yes" requesttimeout="600">

<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminCOAPITab">
	<cfif IsDefined("form.submit")><!--- process the form --->
	    <cfparam name="form.debug" default="0"><!--- if they ask for debug, this is overwritten--->
	    
		<!--- set up return query --->
		<cfset qRogue = queryNew("objectid,data,typename,removeFrom")>
		
		<!--- get tree data --->
		<cfset qTree = application.factory.oTree.getDescendants(objectid=application.navid.root)>
		
		<cffunction name="checkRogue">
			<cfargument name="typename" default="dmNavigation">
			<cfargument name="objectid" type="uuid">
			<cfset var qAssoc = "">
			
			<!--- check for associated objects --->
			<cfquery name="qAssoc" datasource="#application.dsn#">
				select type.data, type.objectid, ref.typename
				from #arguments.typename#_aObjectIDs type, refObjects ref
				where type.objectid = '#arguments.objectid#'
					AND ref.objectid = type.data
			</cfquery>	
			
			<cfif qAssoc.recordcount>
				<cfloop query="qAssoc">
					<!--- check associated object exists --->
					<cfquery name="qCheck" datasource="#application.dsn#">
						select objectid
						from #qAssoc.typename#
						where objectid = '#qAssoc.data#'
					</cfquery>
					
					<!--- add rogue objects to query object --->
					<cfif not qCheck.recordcount>
						<cfset queryAddRow(qRogue, 1)>
						<cfset querySetCell(qRogue, "objectid", qAssoc.objectid)>
						<cfset querySetCell(qRogue, "data", qAssoc.data)>
						<cfset querySetCell(qRogue, "typename", qAssoc.typename)>
						<cfset querySetCell(qRogue, "removeFrom", "#arguments.typename#_aObjectIDs")>
					</cfif>		
						
					<!--- check if associated object has associated objects --->
					<cfif structKeyExists(application.types[qAssoc.typename].stProps,"aObjectIds")>
						<!--- check for associated objects --->
						<cfset checkRogue(objectid=qAssoc.data,typename=qAssoc.typename)>
					</cfif>
				</cfloop>
			</cfif>
		</cffunction>
		
		<!--- loop over tree --->
		<cfloop query="qTree">
			<!--- check for associated objects --->
			<cfset checkRogue(objectid=qTree.objectid)>
		</cfloop>
			
		<cfif form.debug eq 1>
			<!--- show debug only, don't fix tree --->
			<cfoutput>
			<h3>#application.rb.getResource("fixtree.headings.debugComplete@text","Debug Complete")#</h3>
	     <p>#application.rb.getResource("fixtree.messages.objRemovedList@text","These are the content items that would be removed if run out of debug mode")#:</p></cfoutput>
	       	
			<cfif qRogue.recordcount>
				<!--- show dump --->
	        	<cfdump var="#qRogue#" label="#application.rb.getResource('fixtree.messages.noRogueTreeObj@text','There are no rogue objects in your tree')#"> 
				<cfoutput>
				<form action="cleanTree.cfm" method="post">
		            <input type="submit" name="submit" class="f-submit" value="#application.rb.getResource('fixtree.messages.removeObj@text','Remove these content items')#" />
		        </form>
				</cfoutput>
			<cfelse>
				<!--- no rogue objects --->
				<cfoutput>#application.rb.getResource('fixtree.messages.noRogueTreeObj@text','There are no rogue objects in your tree')#</cfoutput>
			</cfif>	
	    <cfelse>                
		   	<!--- delete rogue objects --->
			<cfloop query="qRogue">
				<cfquery name="qCheck" datasource="#application.dsn#">
					delete
					from #qRogue.removeFrom#
					where objectid = '#qRogue.objectid#'
					and data = '#qRogue.data#'
				</cfquery>
			</cfloop>
	        <cfoutput>
			<div class="formtitle">#application.rb.getResource('fixtree.messages.treeFixed@text','Tree Fixed')#</div>
			#application.rb.getResource("fixtree.messages.rogueTreeDataRemoved@text","Rogue tree data has been removed.")#</cfoutput>
	    </cfif>
	<cfelse>
		<!--- show the form --->
	    <cfoutput>
	      
	   
			
	        <form action="cleanTree.cfm" method="post" class="f-wrap-1 f-bg-short wider">
			<fieldset>
			 	
				<h3>#application.rb.getResource("fixtree.headings.cleanNestedTree@text","Clean a Nested Tree")#</h3>
				
				<fieldset class="f-checkbox-wrap">
					<b>&nbsp;</b>
						<fieldset>
						<label for="debug">
						<input type="checkbox" name="debug" id="debug" value="1" checked="checked" />
						#application.rb.getResource("fixtree.labels.showDebugOnly@label","Show debug only (don't fix the table)")#
						</label>
						</fieldset>
	        	</fieldset>
				
				<div class="f-submit-wrap">
			    <input type="submit" name="submit" class="f-submit" value="#application.rb.getResource('fixtree.buttons.submit@label','Submit')#" />
	     		</div>
				
		 	</fieldset>
		    </form>
			
			<hr />
			
			<admin:resource key="fixtree.messages.nestedTreeBlurb@text">
				<p>Use this function if your nested tree ever gets corrupted data. It loops through all tree nodes and looks for associated content items that may no longer exist and removes them. You may want to make a backup of your database before fixing the tree. Please be patient, this process can take a few minutes!</p>
			</admin:resource>
	    </cfoutput>
	</cfif>
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="No">