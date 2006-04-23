<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/container/" prefix="dm">

<cfparam name="attributes.label" default="">
<cfparam name="attributes.objectID" default="">
<cfparam name="attributes.preHTML" default="">
<cfparam name="attributes.postHTML" default="">
<cfparam name="request.mode" default="false">


<cfif NOT len(attributes.label) AND NOT len(attributes.objectID)>
	<cfthrow type="container" message="Insufficient parameters (label of objectID are required) passed">
</cfif>

<cfinvoke component="#application.packagePath#.rules.container" method="getContainer" returnvariable="qGetContainer" label="#attributes.label#" dsn="#application.dsn#"/>

<!--- stick the results in a list - useful if more than one result is returned and we wanna grab the first only --->
<cfset containerIDList = valueList(qGetContainer.objectID)>

<cfif NOT qGetContainer.recordCount>
	<!--- create new container --->
	<cfscript>
		stProps=structNew();
		//extended fourq specific properties
		stProps.objectid = createUUID();
		stProps.label = attributes.label;
		
		containerID = stProps.objectID;
	</cfscript>	
	<q4:contentobjectcreate typename="#application.packagepath#.rules.container" stproperties="#stProps#">

<cfelseif qGetContainer.recordCount GT 1>
	<cflog file="container.log" text="Duplicate container labels for #attributes.label#">
	<cfset containerID = listGetAt(containerIDList,1)> 
<cfelseif qGetContainer.recordCount EQ 1>
	<cfset containerID = qGetContainer.objectID>	
</cfif>

<!--- display edit widget --->

<cfif request.mode.design and request.mode.showcontainers gt 0>
	<dm:containerControl objectID="#containerID#" label="#attributes.label#" mode="design">
</cfif>	

<q4:contentObjectGet typename="#application.packagepath#.rules.container" objectID="#containerID#" r_stObject="stObj">  

<cfif arrayLen(stObj.aRules)>
    <cfif attributes.preHTML neq ""><cfoutput>#attributes.preHTML#</cfoutput></cfif>
	<cfinvoke component="#application.packagepath#.rules.container" method="populate" aRules="#stObj.aRules#"/>
    <cfif attributes.postHTML neq ""><cfoutput>#attributes.postHTML#</cfoutput></cfif>
</cfif>
