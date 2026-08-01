<cfcomponent name="typeadmin" displayname="Type Admin Component" hint="Supports the ../tags/widgets/typeadmin.cfc custom tag. Not to be used in isolation.">

<!---
environment references (might be nice to clean these up)
	session.dmProfile.locale
	session.dmSec.authentication
	application.url.farcry
	application.adminBundle[session.dmProfile.locale]
	application.thisCalendar
	application.types

	TODO: please refactoring to make cleaner
 --->

<cffunction name="init" hint="Constructor." access="public" returntype="objectadmin" output="true">
	<cfargument name="attributes" type="struct" required="true" displayname="Typeadmin attributes." hint="Structure of attributes for the specific typeadmin page.">
	<cfargument name="stPrefs" type="struct" required="false" displayname="User Preferences" hint="Deprecated and ignored; retained so existing callers that still pass it keep working.">

	<cfset variables.attributes = arguments.attributes>

	<!--- override debug output --->
	<!--- <cfset attributes.bdebug="true"> --->

	
	<cfif structKeyExists(application.stCOAPI, variables.attributes.typename)>
		<cfset variables.PrimaryPackage = application.stCOAPI[variables.attributes.typename] />
		<cfset variables.PrimaryPackagePath = application.stCOAPI[variables.attributes.typename].packagepath />
	</cfif>
		
	
	
	<!--- set default buttons as required --->
	<cfif arrayisempty(variables.attributes.aButtons)>
		<cfset variables.attributes.aButtons=getDefaultButtons()>
	</cfif>

	<cfreturn this />
</cffunction>

<cffunction name="setattribute" output="false" access="public" returntype="void">
	<cfargument name="attribkey" required="true" type="string">
	<cfargument name="attribvalue" required="true" type="any">
	<cfset structUpdate(variables.attributes, arguments.attribkey, arguments.attribvalue)>
</cffunction>

<cffunction name="getPrefs" access="public" output="false" returntype="struct" bDeprecated="true" hint="Deprecated; returns an empty struct. The objectadmin prefs store is no longer used - live filter state is session.objectadminFilterObjects, managed by the ft:objectadmin tag.">
	<cfset application.fapi.deprecated("objectadmin.getPrefs() is deprecated and now returns an empty struct. The objectadmin prefs store is unused; live filter state is session.objectadminFilterObjects.") />
	<cfreturn structNew() />
</cffunction>
<cffunction name="getAttributes" access="public" output="false" returntype="struct" hint="Return structure of all attribute settings.">
	<cfreturn variables.attributes />
</cffunction>

<cffunction name="getBasePermissions">
	<cfset var stPermissions=structnew()>
	
	<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
	
	<sec:CheckPermission permission="Create" type="#attributes.permissionset#" result="stPermissions.iCreate" />
	<sec:CheckPermission permission="Delete" type="#attributes.permissionset#" result="stPermissions.iDelete" />
	<sec:CheckPermission permission="RequestApproval" type="#attributes.permissionset#" result="stPermissions.iRequestApproval" />
	<sec:CheckPermission permission="Approve" type="#attributes.permissionset#" result="stPermissions.iApprove" />
	<sec:CheckPermission permission="Edit" type="#attributes.permissionset#" result="stPermissions.iEdit" />
	<sec:CheckPermission permission="ObjectDumpTab" result="stPermissions.iDumpTab" />
	<sec:CheckPermission permission="Developer" result="stPermissions.iDeveloper" />
	
	<cfreturn stPermissions />
</cffunction>

<cffunction name="getDefaultButtons">
	<cfset var aDefaultButtons=arraynew(1)>
	<cfset var stbut=structnew()>
	<cfset var stpermissions=getBasePermissions()>
	
	<cfparam name="URL.module" default="" type="string" />
	
	<cfscript>
		//This data structure is used to create the buttons
		//remember to delimit dynamic expressions ##
		aDefaultButtons=arrayNew(1);
		editobjectURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=##recordset.objectID[recordset.currentrow]##&typename=#attributes.typename#&ref=typeadmin&module=#url.module#";
		if (structKeyExists(url, "Lib")) editObjectURL = editObjectURL&"&lib="&url.lib;

		//add, delete, unlock, dump, requestapproval, approve, sendtodraft
		// add button
			stBut=structNew();
			stBut.type="button";
			stBut.name="add";
			stBut.value="Add";
			stBut.class="f-submit";
			stBut.onClick="";
			stBut.permission=application.security.checkPermission(permission="Create",type=attributes.permissionset);
			stBut.buttontype="add";
			stBut.icon="fa-plus";
			arrayAppend(aDefaultButtons,stBut);
		
		// Copy button
			stBut=structNew();
			stBut.type="button";
			stBut.name="copy";
			stBut.value="Copy";
			stBut.class="f-submit";
			stBut.onClick="";
			stBut.permission=application.security.checkPermission(permission="Create",type=attributes.permissionset) and application.security.checkPermission(permission="Edit",type=attributes.permissionset);
			stBut.buttontype="copy";
			stBut.icon="fa-copy";
			arrayAppend(aDefaultButtons,stBut);
		
		// delete object(s)
			stBut=structNew();
			stBut.type="button";
			stBut.name="deleteAction";
			stBut.value="Delete";
			stBut.class="f-submit";
			// todo: i18n
			stBut.onClick="";
			stBut.confirmText="Are you sure you wish to delete these objects?";
			stBut.permission=application.security.checkPermission(permission="Delete",type=attributes.permissionset);
			stBut.buttontype="delete";
			stBut.icon="fa-trash-o";
			arrayAppend(aDefaultButtons,stBut);

		stBut=structNew();
		stBut.type="Submit";
		stBut.name="unlock";
		stBut.value="Unlock";
		stBut.class="f-submit";
		stBut.onClick="";
		stBut.permission="";
		stBut.buttontype="unlock";
		stBut.icon="fa-unlock";
		arrayAppend(aDefaultButtons,stBut);
		
		// check if object uses status
		if (structKeyExists(PrimaryPackage.stProps,"status")) {
			// Set status to pending
				stBut=structNew();
				stBut.type="submit";
				stBut.name="status";
				stBut.value="Request Approval";
				stBut.class="f-submit";
				stBut.onClick="";
				stBut.permission=application.security.checkPermission(permission="RequestApproval",type=attributes.permissionset);
				stBut.buttontype="requestapproval";
				arrayAppend(aDefaultButtons,stBut);
			// set status to approved/draft
				//approve
				stBut=structNew();
				stBut.type="submit";
				stBut.name="status";
				stBut.value="Approve";
				stBut.class="f-submit";
				stBut.onClick="";
				stBut.permission=application.security.checkPermission(permission="Approve",type=attributes.permissionset);
				stBut.buttontype="approve";
				arrayAppend(aDefaultButtons,stBut);
				
				//send to draft
				stBut=structNew();
				stBut.type="submit";
				stBut.name="status";
				stBut.value="Send to Draft";
				stBut.class="f-submit";
				stBut.onClick="";
				stBut.permission=application.security.checkPermission(permission="Approve",type=attributes.permissionset);
				stBut.buttontype="sendtodraft";
				arrayAppend(aDefaultButtons,stBut);

		}
		
		if (application.stCOAPI[attributes.typename].bBulkUpload){
			// undelete button
				stBut=structNew();
				stBut.type="button";
				stBut.name="bulkupload";
				stBut.value="Bulk Upload";
				stBut.class="f-submit";
				stBut.onClick="$fc.objectAdminAction('Bulk Upload', '#application.url.webtop#/index.cfm?id=#url.id#&typename=#attributes.typename#&view=webtopPageModal&bodyView=webtopBodyBulkUpload'); return false;";
				stBut.permission=application.security.checkPermission(permission="Create",type=attributes.permissionset);
				stBut.buttontype="bulkupload";
				stBut.icon="fa-cloud-upload";
				arrayAppend(aDefaultButtons,stBut);
		}
		
		if (structkeyexists(application.stCOAPI,attributes.typename) and application.stCOAPI[attributes.typename].bArchive){
			// undelete button
				stBut=structNew();
				stBut.type="button";
				stBut.name="undelete";
				stBut.value="Undelete";
				stBut.class="f-submit";
				stBut.onClick="$fc.objectAdminAction('Undelete', '#application.url.webtop#/index.cfm?id=#url.id#&typename=dmArchive&view=webtopPageModal&bodyView=webtopBody&archivetype=#attributes.typename#'); return false;";
				stBut.permission=application.security.checkPermission(permission="Create",type=attributes.permissionset);
				stBut.buttontype="undelete";
				stBut.icon="fa-undo";
				arrayAppend(aDefaultButtons,stBut);
		}
	</cfscript>
	<cfreturn aDefaultButtons />
</cffunction>

</cfcomponent>