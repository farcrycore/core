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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@displayname: extjs Pod Frame --->
<!--- @@description: Places a nice curved border around content.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>


<cfparam name="attributes.id" default="" />
<cfparam name="attributes.title" default="" />
<cfparam name="attributes.class" default="" />
<cfparam name="attributes.style" default="" />

<!------------------ 
START TAG
 ------------------>
<cfif thistag.executionMode eq "start">
<cfoutput>
<div id="#attributes.id#" class="#attributes.class#" style="#attributes.style#">
    <div class="x-box-tl"><div class="x-box-tr"><div class="x-box-tc"></div></div></div>
    <div class="x-box-ml"><div class="x-box-mr"><div class="x-box-mc" id="box-bd">
		<cfif len(attributes.title)>
			<div>#attributes.title#</div>
		</cfif>
		<div>        
</cfoutput>
</cfif>


<cfif thistag.executionMode eq "End">
<cfoutput>
		</div>
    </div></div></div>
    <div class="x-box-bl"><div class="x-box-br"><div class="x-box-bc"></div></div></div>
</div>
<div class="x-form-clear"></div>
</cfoutput>
</cfif>


<cfsetting enablecfoutputonly="false">