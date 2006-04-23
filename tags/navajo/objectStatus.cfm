

<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">

 
<cfparam name="url.objectId">
<cfparam name="url.status" default="0">
<cfparam name="attributes.lObjectIDs" default="#url.objectId#">


<!--- set up page header --->
<cfimport taglib="/farcry/tags/admin/" prefix="admin">
<admin:header>


<cfoutput><span class="FormTitle">Set object status to #url.status#</span><p></p></cfoutput>

<cfinvoke component="#application.packagepath#.farcry.versioning" method="getVersioningRules" objectID="#url.objectID#" returnvariable="stRules">

<cfset changestatus = true>

<cfif isdefined("form.cancel")>
	<script>
		window.close();
	</script>
</cfif>

<cfif not isdefined("form.commentLog") and listlen(attributes.lObjectIDs) eq 1>
	<q4:contentobjectget objectid="#attributes.lobjectIDs#" r_stobject="stObj">
	<cfif isdefined("stObj.status")>
		<cfoutput>
			<form action="" method="post">
			<span class="formLabel">Add your comments:</span><br>
			<textarea rows="8" cols="50"  name="commentLog"></textarea><br>
			<input type="submit" name="submit" value="Submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="submit" name="Cancel" value="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="window.close();"></div>     
			<cfif structKeyExists(stObj,"commentLog")>
				<cfif len(trim(stObj.commentLog)) AND structKeyExists(stObj,"commentLog")>
					<p></p><span class="formTitle">Previous Comments</span><P></P>
					<!--- <textarea cols="58" rows="12">#stObj.commentLog#</textarea> --->
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
			<cf_approveEmail status="approve" objectId="#stObj.objectID#">
			
		<cfelseif url.status eq "draft">
			<cfset status = 'draft'>
			<cfif stObj.status eq "approved">
				<cfset permission = "approve">
			<cfelse>
				<cfset permission = "requestApproval">
			</cfif>
			
			<cfset active = 0>
			
		<cfelseif url.status eq "requestApproval">
			<cfset status = "pending">
			<cfset permission = "requestApproval">
			<cfset active = 0>
			<!--- send out emails informing object needs approval --->
			<cf_approveEmail status="request" objectId="#stObj.objectID#">
	
		<cfelse>
			<cfoutput><b>Unknown status passed. (#url.status#)<b><br></cfoutput><cfabort>
		</cfif>
		
		<cf_dmSec2_PermissionCheck reference1="dmNavigation" permissionName="#permission#" objectId="#stNav.objectId#" r_iState="iState">
			
		<cfif iState neq 1>
			<cfoutput><script> alert("You don't have approval permission on the subnode #stNav.title#");
				               window.close();
			</script></cfoutput><cfabort>
		</cfif>
		
		<cfif url.status eq "approve">
			<cf_dmSec2_PermissionCheck reference1="dmNavigation" permissionName="CanApproveOwnContent" objectId="#stNav.objectId#" r_iState="iState">
		
			<cfif iState neq 1>
	
				<cfif request.bLoggedIn>
					<cfif request.stLoggedInUser.canonicalName eq stObj.attr_lastUpdatedBy>
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
			<cfinvoke  component="fourq.utils.tree.tree" method="getDescendants" returnvariable="qGetDescendants">
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
			<cfset keyList = attributes.objectID>
			<cfif isArray(stObj.aObjectIds)>
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
						buildLog =  "#chr(13)##chr(10)##request.stLoggedInUser.canonicalName#" & "(#dateformat(now(),'dd/mm/yyyy')# #timeformat(now(), 'HH:mm:ss')#):#chr(13)##chr(10)#     Status changed: #stobj.status# -> #status##chr(13)##chr(10)# #FORM.commentLog#";
						stObj.commentLog = buildLog & "#chr(10)##chr(13)#" & stObj.commentLog;
						}
				}
				stObj.status = status;	
			</cfscript>
			<cfinvoke component="#application.packagepath#.farcry.versioning" method="getVersioningRules" objectID="#key#" returnvariable="stRules">
			<cfif stRules.bLiveVersionExists> <!--- Then we want to swap live/draft and archive current live --->
				<cfinvoke component="#application.packagepath#.farcry.versioning" method="sendObjectLive" objectID="#key#"  stDraftObject="#stObj#" returnvariable="stRules">
			<cfelse>
				<q4:contentobjectdata objectid="#stObj.objectID#" typename="#application.packagepath#.types.#stObj.typename#"
				 stProperties="#stObj#">
				
			</cfif>
		</cfloop>
		
	

		<cfif isdefined("request.noArchiving") and request.noArchiving eq false and active eq 1>
			<nj:archiveContent objectid="#stObj.objectID#">
		</cfif>
		
	</cfloop>
	
	<nj:updateTree ObjectId="#stNav.objectId#">
	<cfoutput><script>window.close();</script></cfoutput>

</cfif>                                                                                
<cfoutput>
</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="No">