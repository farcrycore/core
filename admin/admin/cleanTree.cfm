<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/admin/cleanTree.cfm,v 1.7 2005/08/16 05:53:23 pottery Exp $
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

<!--- check permissions --->
<cfscript>
	iCOAPITab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iCOAPITab eq 1>	
	<cfif IsDefined("form.submit")><!--- process the form --->
	    <cfparam name="form.debug" default="0"><!--- if they ask for debug, this is overwritten--->
	    
		<!--- set up return query --->
		<cfset qRogue = queryNew("objectid,data,typename,removeFrom")>
		
		<!--- get tree data --->
		<cfset qTree = request.factory.oTree.getDescendants(objectid=application.navid.root)>
		
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
			<h3>#application.adminBundle[session.dmProfile.locale].debugComplete#</h3>
	     <p>#application.adminBundle[session.dmProfile.locale].objRemovedList#</p></cfoutput>
	       	
			<cfif qRogue.recordcount>
				<!--- show dump --->
	        	<cfdump var="#qRogue#" label="#application.adminBundle[session.dmProfile.locale].rogueTreeObj#"> 
				<cfoutput>
				<form action="cleanTree.cfm" method="post">
		            <input type="submit" name="submit" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].removeObj#" />
		        </form>
				</cfoutput>
			<cfelse>
				<!--- no rogue objects --->
				<cfoutput>#application.adminBundle[session.dmProfile.locale].noRogueTreeObj#</cfoutput>
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
			<div class="formtitle">#application.adminBundle[session.dmProfile.locale].treeFixed#</div>
			#application.adminBundle[session.dmProfile.locale].rogueTreeDataRemoved#</cfoutput>
	    </cfif>
	<cfelse>
		<!--- show the form --->
	    <cfoutput>
	      
	   
			
	        <form action="cleanTree.cfm" method="post" class="f-wrap-1 f-bg-short wider">
			<fieldset>
			 	
				<h3>#application.adminBundle[session.dmProfile.locale].cleanNestedTree#</h3>
				
				<fieldset class="f-checkbox-wrap">
					<b>&nbsp;</b>
						<fieldset>
						<label for="debug">
						<input type="checkbox" name="debug" id="debug" value="1" checked="checked" />
						#application.adminBundle[session.dmProfile.locale].showDebugOnly#
						</label>
						</fieldset>
	        	</fieldset>
				
				<div class="f-submit-wrap">
			    <input type="submit" name="submit" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].submit#" />
	     		</div>
				
		 	</fieldset>
		    </form>
			
			<hr />
			
			<p>#application.adminBundle[session.dmProfile.locale].nestedTreeBlurb#</p>
	    </cfoutput>
	</cfif>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="No">