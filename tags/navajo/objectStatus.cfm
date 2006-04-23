

<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

 
<cfparam name="url.objectId">
<cfparam name="url.status" default="0">
<cfparam name="attributes.lObjectIDs" default="#url.objectId#">


<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>


<cfoutput><span class="FormTitle">
<cfif isDefined("URL.draftObjectID")>
	Set object status for underlying draft object to 'request'
<cfelse>	
	Set object status to #url.status#
</cfif>	
</span><p></p></cfoutput>

<cfinvoke component="#application.packagepath#.farcry.versioning" method="getVersioningRules" objectID="#url.objectID#" returnvariable="stRules">

<cfset changestatus = true>

<!--- show comment form --->
<cfif not isdefined("form.commentLog") and listlen(attributes.lObjectIDs) eq 1>
	<!--- get object details --->
	<q4:contentobjectget objectid="#attributes.lobjectIDs#" r_stobject="stObj">
	<cfif isdefined("stObj.status")>
		<cfoutput>
			<form action="" method="post">
			<span class="formLabel">Add your comments:</span><br>
			<textarea rows="8" cols="50"  name="commentLog"></textarea><br>
			<input type="submit" name="submit" value="Submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="button" name="Cancel" value="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='../edittabOverview.cfm?objectid=#attributes.lobjectIDs#';"></div>     
			<!--- display existing comments --->
			<cfif structKeyExists(stObj,"commentLog")>
				<cfif len(trim(stObj.commentLog)) AND structKeyExists(stObj,"commentLog")>
					<p></p><span class="formTitle">Previous Comments</span><P></P>
					#htmlcodeformat(stObj.commentLog)#
				</cfif>
			</cfif>
			</form>
		</cfoutput>
		<cfset changestatus = false>
	</cfif>
</cfif>
<cfif changestatus eq true>
	<cfflush>
	
	<cfloop index="attributes.objectID" list="#attributes.lObjectIDs#">
		
		<q4:contentobjectget objectId="#attributes.objectId#" r_stObject="stObj">
		
		
		<cfif not structkeyexists(stObj, "status")>
			<cfoutput><script> alert("This object type has no approval process attached to it.");
				               window.close();
			</script></cfoutput><cfabort>
		</cfif>
		
		<!--- get the navigation root navigation of this object to check permissions on it --->
		<nj:getNavigation objectId="#stObj.objectID#" bInclusive="1" r_stObject="stNav" r_ObjectId="objectId">

		<cfif url.status eq "approved">
			<cfset status = "approved">
			<cfset permission = "approve">
			<cfset active = 1>
			<!--- send out emails informing object has been approved --->
			<cfinvoke component="#application.packagepath#.farcry.versioning" method="approveEmail_approved">
				<cfinvokeargument name="objectId" value="#stObj.objectID#"/>
				<cfinvokeargument name="comment" value="#form.commentlog#"/>
			</cfinvoke>

			
		<cfelseif url.status eq "draft">
			<cfset status = 'draft'>
			<cfset permission = "approve">
			<!--- send out emails informing object has been sent back to draft --->
			<cfinvoke component="#application.packagepath#.farcry.versioning" method="approveEmail_draft">
				<cfinvokeargument name="objectId" value="#stObj.objectID#"/>
				<cfinvokeargument name="comment" value="#form.commentlog#"/>
			</cfinvoke>
			<cfset active = 0>
			
		<cfelseif url.status eq "requestApproval">
			<cfset status = "pending">
			<cfset permission = "requestApproval">
			<cfset active = 0>
			<!--- send out emails informing object needs approval --->
			<cfif isDefined("URL.draftObjectID")>
				<cfinvoke component="#application.packagepath#.farcry.versioning" method="approveEmail_pending">
					<cfinvokeargument name="objectId" value="#URL.draftObjectID#"/>
					<cfinvokeargument name="comment" value="#form.commentlog#"/>
				</cfinvoke>
			<cfelse>
				<cfinvoke component="#application.packagepath#.farcry.versioning" method="approveEmail_pending">
					<cfinvokeargument name="objectId" value="#stObj.objectID#"/>
					<cfinvokeargument name="comment" value="#form.commentlog#"/>
				</cfinvoke>
			</cfif>
			
	
		<cfelse>
			<cfoutput><b>Unknown status passed. (#url.status#)<b><br></cfoutput><cfabort>
		</cfif>
		<cfscript>
			oAuthorisation = request.dmsec.oAuthorisation;
			iState = oAuthorisation.checkInheritedPermission(permissionName=permission,objectid=stNav.objectId);	
		</cfscript>
		
		<cfif iState neq 1>
			<cfoutput><script> alert("You don't have approval permission on the subnode #stNav.title#");
				               window.close();
			</script></cfoutput><cfabort>
		</cfif>
		
		<cfif url.status eq "approve">
			<cfscript>
				iState = oAuthorisation.checkInheritedPermission(permissionName="CanApproveOwnContent",objectid=stNav.objectId);	
			</cfscript>
		
			<cfif iState neq 1>
	
				<cfif request.bLoggedIn>
					<cfif session.dmSec.authentication.canonicalName eq stObj.attr_lastUpdatedBy>
						<cfoutput>
						<script>
							alert("You don't have permission to approve your own content on #stNav.title#");
							window.close();
						</script>
						</cfoutput>
						<cfabort>
					</cfif>
				<cfelse>
					<cfoutput>
					<script>
						alert("You aren't logged in");
						window.close();
					</script>
					</cfoutput>
					<cfabort>
				</cfif>
				
			</cfif>
		</cfif>
				
		<!--- Call this to get all descendants of this node --->

		<!--- If we are approving the whole branch - then we will be wanting all objectIDS --->
		<cfif isDefined("URL.approveBranch")>
			<cfset keyList = attributes.objectID>
			<cfif isArray(stObj.aObjectIds)>
				<cfset keyList = listAppend(keyList,arrayToList(stObj.aObjectIds))>
			</cfif>
			<cfinvoke  component="#application.packagepath#.farcry.tree" method="getDescendants" returnvariable="qGetDescendants">
				<cfinvokeargument name="dsn" value="#application.dsn#"/>
				<cfinvokeargument name="objectid" value="#attributes.objectID#"/>
			</cfinvoke>
			
			<cfset keyList = listAppend(keyList,valueList(qGetDescendants.objectId))>
			<cfloop query="qGetDescendants">
				<q4:contentobjectget objectId="#qGetDescendants.objectId#" r_stObject="stThisObj">
				<cfif isArray(stThisObj.aObjectIds)>
					<cfset keyList = listAppend(keyList,arrayToList(stThisObj.aObjectIds))>
				</cfif>	
			</cfloop>
		<cfelse>  <!--- else - just get the objectIDS in this nodes aObjects array --->
			<cfif isDefined("URL.draftObjectID")>
				<cfset keyList = URL.draftObjectID>
			<cfelse>	
				<cfset keyList = attributes.objectID>
			</cfif>	
			<cfif isdefined("stObj.aObjectIds") and isArray(stObj.aObjectIds)>
				<cfset keyList = listAppend(keyList,arrayToList(stObj.aObjectIds))>
			</cfif>
		</cfif>
						
		
		<cfoutput>Changing status....<br></cfoutput><cfflush>
		
			<!--- update the structure data for object update --->
			
		
		<cfloop list="#keyList#" index="key">
			<q4:contentobjectget objectId="#key#" r_stObject="stObj">
			<cfscript>
				stObj.datetimecreated = createODBCDateTime("#datepart('yyyy',stObj.datetimecreated)#-#datepart('m',stObj.datetimecreated)#-#datepart('d',stObj.datetimecreated)#");
				stObj.datetimelastupdated = createODBCDateTime(now());
				//only if the comment log exists - do we actually append the entry
				if (isDefined("FORM.commentLog")) {
					if (structkeyexists(stObj, "commentLog")){
						buildLog =  "#chr(13)##chr(10)##session.dmSec.authentication.canonicalName#" & "(#dateformat(now(),'dd/mm/yyyy')# #timeformat(now(), 'HH:mm:ss')#):#chr(13)##chr(10)#     Status changed: #stobj.status# -> #status##chr(13)##chr(10)# #FORM.commentLog#";
						stObj.commentLog = buildLog & "#chr(10)##chr(13)#" & stObj.commentLog;
						}
				}
				stObj.status = status;	
			</cfscript>
			
			<cfinvoke component="#application.packagepath#.farcry.versioning" method="getVersioningRules" objectID="#key#" returnvariable="stRules">
			
			<cfif stRules.bLiveVersionExists and url.status eq "approved">
				 <!--- Then we want to swap live/draft and archive current live --->
				<cfinvoke component="#application.packagepath#.farcry.versioning" method="sendObjectLive" objectID="#key#"  stDraftObject="#stObj#" returnvariable="stRules">
				<cfset returnObjectID=stObj.objectid>
			<cfelse>
				<!--- a normal page, no underlying object --->
				<q4:contentobjectdata objectid="#stObj.objectID#" typename="#application.packagepath#.types.#stObj.typename#"
				 stProperties="#stObj#">
				 <cfif stObj.typename neq "dmImage" and stObj.typename neq "dmFile">
				 	<cfset returnObjectId= url.objectid>
				 </cfif>
			</cfif>
		</cfloop>
		
	</cfloop>
	
	<nj:updateTree ObjectId="#stNav.objectId#">
	
	<cfoutput><script>
		if( window.opener && window.opener.parent )	window.close();
		else location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#returnObjectID#';
	</script></cfoutput>

</cfif>                                                                                
<cfoutput>
</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="No">