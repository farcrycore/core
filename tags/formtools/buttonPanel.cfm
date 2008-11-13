<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: farcryButtonPanel --->
<!--- @@Description: Wrapper for farcry buttons. --->
<!--- @@Developer: Matthew Bryant (mbryant@daemon.com.au) --->


<!--- Import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>

<cfparam name="attributes.id" default="#application.fc.utils.createJavaUUID()#" />
<cfparam name="attributes.indentForLabel" default="true" />

<cfif thistag.ExecutionMode EQ "Start">
	<cfoutput>
		<div id="#attributes.id#" class="farcryButtonPanel">
			<cfif attributes.indentForLabel>
			<div class="fieldSection">
				<label class="fieldsectionlabel">&nbsp;</label>
				<div class="fieldAlign">
			</cfif>
	</cfoutput>
</cfif>

<cfif thistag.ExecutionMode EQ "End">

	<cfoutput>
			<cfif attributes.indentForLabel>
					</div>
				</div>
			</cfif>
			<br style="height:0px;clear:both;" />
		</div>
	</cfoutput>

</cfif>


<cfsetting enablecfoutputonly="false">
