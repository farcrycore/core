<cfsetting enablecfoutputonly="yes">
<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
<!--- TODO
$Description: $
$TODO: This legacy code needs to be revisited 
- should have a more generic object invocation methodology GB
- indeed; this must fall in a well and die GB 20140102
 --->

<cfif thistag.ExecutionMode eq "end">
	<cfsetting enablecfoutputonly="false" />
	<cfexit method="exittag">
</cfif>

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<!--- import function libraries --->
<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm">
<cfinclude template="/farcry/core/webtop/includes/cfFunctionWrappers.cfm">

<!--- required attributes --->
<!--- 	looks like refs to URL params are everywhere... 
	  	will have to hack this in the interim till we 
		refactor the lot. 20050728 GB	--->
<cfif isdefined("url.objectid")><cfset attributes.objectid=url.objectid></cfif>
<cfif isdefined("url.typename")><cfset attributes.typename=url.typename></cfif>
<cfparam name="attributes.objectid" type="uuid" default="#application.fc.utils.createJavaUUID()#">
<cfparam name="attributes.typename" default="" type="string">

<!--- Legacy support for old pages referring to URL.type--->
<cfif isDefined("URL.type") AND NOT isDefined("URL.typename")>
	<cfset URL.typename = URL.type>
	<farcry:deprecated message="../tags/navajo/edit.cfm referencing type when typename required." />
</cfif>

<!--- auto-type lookup if required --->
<cfif not len(attributes.typename)>
	<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq") />
	<cfset attributes.typename = q4.findType(objectid=attributes.objectid) />
	
	<!--- its possible that missing objects will kill this so we only want to create object if we actually get a typename result --->
	<cfif not len(attributes.typename)>
		<cfabort />
	</cfif>
</cfif>

<!--- First check tree permissions --->
<sec:CheckPermission typepermission="Edit" type="#url.typename#" objectpermission="edit" objectid="#attributes.objectid#" error="true" errormessage="You do not have permission to edit this item">

	<!--- work out packagee path --->
	<cfset oType = createObject("component", application.stCOAPI[attributes.typename].packagepath)>
	<cfset stObj = oType.getData(objectid=attributes.objectid,dsn=application.dsn)>
	
	<!--- delete underlying draft --->
	<cfif isDefined("URL.deleteDraftObjectID")>
		<!--- Delete the copied draft object containers --->
		<cfset oCon = createObject('component','#application.packagepath#.rules.container') />
		<cfset oCon.delete(objectid="#URL.deleteDraftObjectID#") />
		
		<!--- Delete the copied draft object --->
		<cfset oType.deletedata(objectId="#URL.deleteDraftObjectID#") />
		
		<!--- Log this activity against live object --->
		<farcry:logevent object="#attributes.objectid#" type="types" event="delete" notes="Deleted Draft Object (#stObj.label#)" />
		
		<cfswitch expression="#url.ref#">
			<cfcase value="iframe">
				<!--- reload overview page --->
				<cfoutput><script type="text/javascript">
					location = '#application.url.farcry#/edittabOverview.cfm?typename=#attributes.typename#&objectid=#attributes.objectid#&ref=#url.ref#';
				</script></cfoutput>
			</cfcase>
			
			<cfcase value="refresh">
				<!--- reload overview page --->
				<cfoutput><script type="text/javascript">
					location = window.location;
				</script></cfoutput>
			</cfcase>
			
			<cfcase value="closeDialog">
				<!--- reload overview page --->
				<cfoutput><script type="text/javascript">
					if (parent && parent.$fc && parent.$fc.closeBootstrapModal)
						parent.$fc.closeBootstrapModal();
				</script></cfoutput>
			</cfcase>
			
			<cfdefaultcase>
				<!--- reload overview page --->
				<cfoutput><script type="text/javascript">
					window.location = '#application.url.farcry#/edittabOverview.cfm?typename=#attributes.typename#&objectid=#attributes.objectid#&ref=#url.ref#';
				</script></cfoutput>
			</cfdefaultcase>
		</cfswitch>
	</cfif>
	
	<!--- See if we can edit this object --->
	<cfset bAllowEdit = false />
	<cfset oLocking = createObject("component","#application.packagepath#.farcry.locking") />
	<cfif structKeyExists(stObj,"versionID") AND structKeyExists(stObj,"status")>
		<cfset stRules = application.factory.oVersioning.getVersioningRules(objectid=attributes.objectid) />
		<cfset application.factory.oVersioning.checkEdit(stRules=stRules,stObj=stObj) />
	</cfif>
	
	<cfif structCount(stObj)>		
		<cfset checkForLockRet=oLocking.checkForLock(objectid=attributes.objectid) />
		<cfif checkForLockRet.bSuccess>
			<cfset lockRet = oLocking.lock(objectid=attributes.objectid,typename=attributes.typename) />
			<cfif lockRet.bSuccess>
				<cfset bAllowEdit = true />
			<cfelse>
				<cfdump var="#packagepath#" />
				<cfabort />
			</cfif>
		<cfelseif not checkForLockRet.bSuccess and checkForLockRet.lockedBy eq session.security.userid>
			<cfset bAllowEdit = true />
		<cfelse>
			<cfoutput>
				#checkForLockRet.message#
			</cfoutput>
			<cfdump var="#checkForLockRet#" />
			<cfabort />
		</cfif>
	</cfif>
	
	<cfset onExitProcess = structNew() />
	<cfset onExitProcess.Type = "HTML" />
	<cfsavecontent variable="onExitProcess.Content">
		<cfoutput>
		<script type="text/javascript">
			location.href = '#application.url.farcry#/edittabOverview.cfm?typename=#attributes.typename#&objectid=#stObj.ObjectID#&ref=#url.ref#';
		</script>
		</cfoutput>
	</cfsavecontent>

	<cfset html = oType.getView(stObject=stobj, template="edit", onExitProcess="#onExitProcess#", alternateHTML="") />
	
	<cfif len(html)>
		<cfoutput>#html#</cfoutput>
	<cfelse>
		<cfset oType.edit(objectid=attributes.objectid, onExitProcess="#onExitProcess#") />
	</cfif>
	
</sec:CheckPermission>

<cfsetting enablecfoutputonly="No">
