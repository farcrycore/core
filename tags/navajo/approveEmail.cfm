<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/fourq/tags/" prefix="q4">

<cfswitch expression="#attributes.status#">

	<cfcase value="approve">
		
		<!--- get object details --->
		<q4:contentobjectget objectId="#attributes.objectId#" r_stObject="stObj">
		
		<!--- get object parent  --->
		<cfquery name="qGetParent" datasource="#application.dsn#" debug="yes">
			SELECT * 
			FROM dmNavigation_aObjectIds 
			WHERE data = '#stObj.objectId#'	
		</cfquery>
		
		<!--- get email addresses
		TODO: only checking against dmUser at the moment
		 --->
		<cfinvoke component="farcry.packages.farcry.workflow" method="getUserDetails" returnvariable="getUserDetailsRet">
			<cfinvokeargument name="userId" value="#stObj.lastupdatedby#"/>
		</cfinvoke>
		
		<!--- send email to lastupdater to let them know object is approved --->
		<cfmail to="#getUserDetailsRet.userEmail#" from="#application.adminMail#" subject="Object Approved" type="html">
		FYI
		
		Object "<a href="http://#cgi.SERVER_NAME##application.url.farcry#/index.cfm?section=site&rootObjectId=#qGetParent.objectID#"><cfif stObj.title neq "">#stObj.title#<cfelse><em>undefined</em></cfif></a>" has been approved.
		
		</cfmail>
	</cfcase>
	
	<cfcase value="request">
		<!--- get object details --->
		<q4:contentobjectget objectId="#attributes.objectId#" r_stObject="stObj">
		
		<!--- get object parent  --->
		<cfquery name="qGetParent" datasource="#application.dsn#" debug="yes">
			SELECT * 
			FROM dmNavigation_aObjectIds 
			WHERE data = '#stObj.objectId#'	
		</cfquery>
				
		<!--- get list of approvers for this object --->
		<cfinvoke component="farcry.packages.farcry.workflow" method="getObjectApprovers" returnvariable="getObjectApproversRet">
			<cfinvokeargument name="objectId" value="#attributes.objectId#"/>
		</cfinvoke>
		
		<cfloop query="getObjectApproversRet">
			<cfif userEmail neq "n/a">
				<!--- send email alerting them to object is waiting approval  --->
				<cfmail to="#userEmail#" from="#application.adminMail#" subject="Object Approval Request" type="html">
				FYI<p></p>
				Object "<a href="http://#cgi.SERVER_NAME##application.url.farcry#/index.cfm?section=site&rootObjectId=#qGetParent.objectID#"><cfif stObj.title neq "">#stObj.title#<cfelse><em>undefined</em></cfif></a>" is waiting for your approval.
				</cfmail>
			</cfif>
		</cfloop>
		
	</cfcase>
	
</cfswitch>

<cfsetting enablecfoutputonly="No">