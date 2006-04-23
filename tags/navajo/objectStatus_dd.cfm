<!--- objectStatus_dd.cfm

Changes the status of objects to approved/draft/pending. Intended for use with dynamic data pages

 --->

<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">

<cfparam name="attributes.lObjectIDs" default=""> <!---objects to have their status changed-required --->
<cfparam name="attributes.status" default=""> <!--- status to change to - required --->
<cfparam name="rMsg" default="msg"> <!--- The message returned to the caller - optional --->

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
		<cfscript>
			if (attributes.status is "approved")
			{
				status = "approved";
				permission = "approve";
				active = 1;
			}
			else if (attributes.status is "draft")
			{
				status = 'draft';
				if (stObj.status eq "approved")
					permission = "approve";
				else	
					permission = "requestApproval";
				active = 0;
			}
			else if (attributes.status is "requestApproval")
			{
				status = 'pending';
				permission = 'requestApproval';
				active = 0;
			}
			else
				unknownStatus = true;
					 		
		
		</cfscript>
		
		<cfif isDefined("unknownStatus")>
			<cfthrow errorcode="navajo" message="Unknown status passed">
		</cfif>
		<!--- update the structure data for object update --->
		<cfscript>
			stObj.datetimecreated = createODBCDateTime("#datepart('yyyy',stObj.datetimecreated)#-#datepart('m',stObj.datetimecreated)#-#datepart('d',stObj.datetimecreated)#");
			stObj.datetimelastupdated = now();
			stObj.expirydate = createODBCDateTime("#datepart('yyyy',stObj.expirydate)#-#datepart('m',stObj.expirydate)#-#datepart('d',stObj.expirydate)#");
			stObj.publishdate = createODBCDateTime("#datepart('yyyy',stObj.publishdate)#-#datepart('m',stObj.publishdate)#-#datepart('d',stObj.publishdate)#");

			//only if the comment log exists - do we actually append the entry
			if (isDefined("FORM.commentLog")) {
				if (structkeyexists(stObj, "commentLog")){
					buildLog =  "#chr(13)##chr(10)##request.stLoggedInUser.canonicalName#" & "(#dateformat(now(),'dd/mm/yyyy')# #timeformat(now(), 'HH:mm:ss')#):#chr(13)##chr(10)#     Status changed: #stobj.status# -> #status##chr(13)##chr(10)# #FORM.commentLog#";
					stObj.commentLog = buildLog & "#chr(10)##chr(13)#" & stObj.commentLog;
					}
			}
			stObj.status = status;	
		</cfscript>
		
		<q4:contentobjectdata objectid="#stObj.objectID#"
		typename="#application.packagepath#.types.#stObj.typename#"
		 stProperties="#stObj#">		

		<cfif isdefined("request.noArchiving") and request.noArchiving eq false and active eq 1>
			<nj:archiveContent objectid="#stObj.objectID#">
		</cfif>
		
	</cfloop>
	
	<cfset "caller.#attributes.rMsg#" = "#listLen(attributes.lObjectIds)# object(s) status changed"> 

<cfsetting enablecfoutputonly="No">
