<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/objectStatus_dd.cfm,v 1.15.2.4 2004/02/13 02:36:54 brendan Exp $
$Author: brendan $
$Date: 2004/02/13 02:36:54 $
$Name: milestone_2-1-2 $
$Revision: 1.15.2.4 $

|| DESCRIPTION || 
$Description: Changes the status of objects to approved/draft/pending. Intended for use with dynamic data pages $
$TODO: Fix date handling, for we have had to add a hack to convert custom date properties to ODBC$

|| DEVELOPER ||
$Developer: Unknown$

|| ATTRIBUTES ||
$in: url.Objectid$
$out:$
--->

<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfparam name="attributes.lObjectIDs" default=""> <!---objects to have their status changed-required --->
<cfparam name="attributes.status" default=""> <!--- status to change to - required --->
<cfparam name="rMsg" default="msg"> <!--- The message returned to the caller - optional --->
<cfparam name="form.commentlog" default=""> <!--- hack --->

<cfloop index="attributes.objectID" list="#attributes.lObjectIDs#">

	<q4:contentobjectget objectId="#attributes.objectId#" r_stObject="stObj">
		<cfif not structkeyexists(stObj, "status")>
			<cfoutput>
			<script>
				 alert("This object type has no approval process attached to it.");
			</script>
			</cfoutput>
			<cfexit>
		</cfif>

		<cfif attributes.status eq "approved">
			<cfset status = "approved">
			<cfset permission = "approve">
			<cfset active = 1>

			<!--- send out emails informing object has been approved --->
			<cfinvoke component="#application.packagepath#.farcry.versioning" method="approveEmail_approved_dd">
				<cfinvokeargument name="objectId" value="#attributes.objectId#"/>
				<cfinvokeargument name="comment" value="#attributes.commentlog#"/>
				<cfif isDefined("attributes.approveURL")>
					<cfinvokeargument name="approveURL" value="#attributes.approveURL#"/>
				</cfif>
			</cfinvoke>
		<cfelseif trim(attributes.status) IS "draft">
			<cfset status = 'draft'>
			<cfset permission = "approve">
						
			<!--- send out emails informing object is sent back to draft --->
			<cfinvoke component="#application.packagepath#.farcry.versioning" method="approveEmail_draft_dd">
				<cfinvokeargument name="objectId" value="#attributes.objectId#"/>
				<cfinvokeargument name="comment" value="#attributes.commentlog#"/>
				<cfif isDefined("attributes.approveURL")>
					<cfinvokeargument name="approveURL" value="#attributes.approveURL#"/>
				</cfif>
			</cfinvoke>
			

			<cfset active = 0>
		<cfelseif attributes.status eq "requestApproval">
			<cfset status = "pending">
			<cfset permission = "requestApproval">
			<cfset active = 0>

			<!--- send out emails informing object needs approval --->
			<cfinvoke component="#application.packagepath#.farcry.versioning" method="approveEmail_pending_dd">
				<cfinvokeargument name="objectId" value="#attributes.objectId#"/>
				<cfinvokeargument name="comment" value="#attributes.commentlog#"/>
				<cfif isdefined("attributes.lApprovers") and len(attributes.lApprovers)>
					<cfif listLen(attributes.lApprovers) gt 1 and listFind(attributes.lApprovers,"all")>
						<cfinvokeargument name="lApprovers" value="all"/>
					<cfelse>
						<cfinvokeargument name="lApprovers" value="#attributes.lApprovers#"/>
					</cfif>					
				<cfelse>
					<cfinvokeargument name="lApprovers" value="all"/>
				</cfif>
				<cfif isDefined("attributes.approveURL")>
					<cfinvokeargument name="approveURL" value="#attributes.approveURL#"/>
				</cfif>	
			</cfinvoke>
		<cfelse>
			<cfthrow errorcode="navajo" message="Unknown status passed">
		</cfif>
		
		<!--- prepare date fields --->
		<cfloop collection="#stObj#" item="field">
			<cfif StructKeyExists(application.types[stObj.typeName].stProps, field) and application.types[stObj.typeName].stProps[field].metaData.type eq "date">
				<cfset stObj[field] = CreateODBCDateTime(stObj[field])>
			</cfif>
		</cfloop>

		<cfscript>
		// update the structure data for object update
		stObj.datetimelastupdated = now();
					
		//only if the comment log exists - do we actually append the entry
		if (structkeyexists(stObj, "commentLog")){
			buildLog =  "#chr(13)##chr(10)##session.dmSec.authentication.canonicalName#" & "(#dateformat(now(),'dd/mm/yyyy')# #timeformat(now(), 'HH:mm:ss')#):#chr(13)##chr(10)#     Status changed: #stobj.status# -> #status##chr(13)##chr(10)# #attributes.commentLog#";
			stObj.commentLog = buildLog & "#chr(10)##chr(13)#" & stObj.commentLog;
		}
		stObj.status = status;	
		
		// update object	
		oType = createobject("component", application.types[stObj.typename].typePath);
		oType.setData(stProperties=stObj,auditNote="Status changed to #stObj.status#");		
		</cfscript>
		
	</cfloop>
	
	<cfset "caller.#attributes.rMsg#" = "#listLen(attributes.lObjectIds)# object(s) status changed"> 

<cfsetting enablecfoutputonly="No">
