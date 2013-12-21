<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/container/" prefix="con">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">

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
				<ft:button value="Cancel" />
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