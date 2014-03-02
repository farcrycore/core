<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
<!--- @@displayname: Edit Container --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/container/" prefix="con">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">

<!--- 
 // process form 
--------------------------------------------------------------------------------->
<ft:processform action="Save">
	<ft:processformobjects typename="container">
		<cfset stProperties.bShared = 1>
		<cfset stObj.label = stProperties.label>
	</ft:processformobjects>
</ft:processform>
<ft:processform action="Cancel" exit="true" />

<ft:processform action="Complete" exit="true" />


<cfif (StructKeyExists(stobj, "mirrorid") AND Len(stobj.mirrorid))>
	<cfset stOriginal = duplicate(stobj) />
	<cfset stConObj = oCon.getData(objectid=stConObj.mirrorid)>
	<cfset containerID = stOriginal.objectid /><!--- Used by rules to reference the container they're a part of --->
<cfelse>
	<cfset stOriginal = structnew() />
	<cfset stConObj = duplicate(stobj) />
	<cfset containerID = stConObj.objectid /><!--- Used by rules to reference the container they're a part of --->
</cfif>

<cfset request.mode.design = 1 />
<cfset request.mode.showcontainers = 1 />

<!--- 
 // view 
--------------------------------------------------------------------------------->
<cfoutput>

	<cfif stObj.label eq "(incomplete)" or stObj.label eq "">
		<cfset stObj.label = "">

		<h1><i class="fa fa-wrench"></i> Create Reflected Container</h1>

		<cfset stMeta = structNew()>
		<cfset stMeta.label = structNeW()>
		<cfset stMeta.label.ftLabel = "Container Label">
		<cfset stMeta.label.ftValidation = "required">

		<ft:form>
			<ft:object typename="container" stObject="#stObj#" lFields="label" stPropMetadata="#stMeta#" />
			<ft:buttonPanel>
				<ft:button value="Save" />
				<ft:button value="Cancel" validate="false" />
			</ft:buttonPanel>
		</ft:form>

	<cfelse>

		<h1><i class="fa fa-wrench"></i> #stObj.label#</h1>

		<con:container objectid="#stObj.objectid#" label="#stObj.label#">

		<ft:form>
			<ft:buttonPanel>
				<ft:button value="Complete" />
			</ft:buttonPanel>
		</ft:form>
		
	</cfif>

</cfoutput>

<cfsetting enablecfoutputonly="false">