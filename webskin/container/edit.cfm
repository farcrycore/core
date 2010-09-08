<cfsetting enablecfoutputonly="true" />
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


<!--- Import tag libraries --->
<cfimport taglib="/farcry/core/tags/container/" prefix="con">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />

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

<grid:div style="max-width:800px;_width:800px;border:1px dashed ##CACACA;padding:10px;">


	<ft:form>
		<ft:buttonPanel>
			<ft:button value="Complete" />
		</ft:buttonPanel>
	</ft:form>
	
	<skin:view objectid="#stobj.objectid#" webskin="displayAdminToolbar" alternatehtml="" original="#stOriginal#" />
	
	
	<cfoutput><div id="#replace(containerID,'-','','ALL')#"></cfoutput>
	
	<skin:view stObject="#stConObj#" webskin="displayContainer" alternatehtml="" original="#stOriginal#" />
	
	<cfoutput></div></cfoutput>

	<ft:form>
		<ft:buttonPanel>
			<ft:button value="Complete" />
		</ft:buttonPanel>
	</ft:form>
	
</grid:div>
<cfsetting enablecfoutputonly="false" />