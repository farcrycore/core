<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
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