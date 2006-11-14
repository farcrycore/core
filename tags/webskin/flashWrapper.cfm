<!--- start enable output only from cfoutput tags --->
<cfsetting enablecfoutputonly="yes" />

<!--- 
|| DESCRIPTION || 
$Description: flashWrapper tag - leverages swfObject javascript library to allow simple cf tag based embeds of flash assets.
Contains parametres to enable common swf wrapper properties to be defined such as height, width, wmode & background color.
Contains parametres for flashVars to allow for Remote Procedure Call (RPC) values to be passed through to the swf at embed time. $

|| DEVELOPER ||
$Developer: Grae Hall (grae@daemon.com.au) $

|| ATTRIBUTES ||
$in: class -- defines the class of the flashWrapper div $
$in: SWFSource -- defines SWF source $
$in: SWFID -- defines SWF ID $
$in: SWFWidth -- defines SWF width $
$in: SWFHeight -- defines SWF height $
$in: SWFBackgroundColor -- defines window mode of the swf $
$in: SWFVersion -- defines the version of the swf $
$in: SWFWMode -- defines window mode of the swf $
$in: RPCServiceName -- flashVar for use with remoting : defines the remote service $
$in: RPCMethod -- flashVar for use with remoting : defines the remote method to call from the remote service $
$in: RPCObjectID -- flashVar for use with remoting : defines a parametre to pass to a remote method : a FarCry Object ID $
$in: stRPC -- cfStruct containing additional user defined flashVars for use with remoting $
--->

<cfif thistag.executionMode eq "Start">

	<!--- class : defines the class of the flashWrapper div --->
	<cfparam name="attributes.class" default="ruleFlashWrapper" />

	<!--- SWFSource : defines SWF source --->
	<cfparam name="attributes.SWFSource" default="" />
	<!--- SWFID : defines SWF ID --->
	<cfparam name="attributes.SWFID" default="SWFID" />
	<!--- SWFWidth : defines SWF width --->
	<cfparam name="attributes.SWFWidth" default="404" />
	<!--- SWFHeight : defines SWF height --->
	<cfparam name="attributes.SWFHeight" default="326" />
	<!--- SWFVersion : defines the version of the swf --->
	<cfparam name="attributes.SWFVersion" default="8" />
	<!--- SWFBackgroundColor : defines window mode of the swf --->
	<cfparam name="attributes.SWFBackgroundColor" default="" />
	<!--- SWFWMode : defines window mode of the swf --->
	<cfparam name="attributes.SWFWMode" default="transparent" />
	<!--- SWFScriptAccess : defines access permissions of the swf --->
	<cfparam name="attributes.SWFScriptAccess" default="sameDomain" />
	<!--- SWFMenu : defines the presence of the right-click menu --->
	<cfparam name="attributes.SWFMenu" default="false" />

	<!--- containerWidth : defines width of container swf is written to --->
	<cfparam name="attributes.containerWidth" default="" />
	<!--- containerHeight : defines height of container swf is written to --->
	<cfparam name="attributes.containerHeight" default="" />

	<!--- RPCServiceName : flashVar for use with remoting - defines the remote service --->
	<cfparam name="attributes.RPCServiceName" default="facade" />
	<!--- RPCMethod : flashVar for use with remoting - defines the remote method to call from the remote service --->
	<cfparam name="attributes.RPCMethod" default="" />
	<!--- RPCObjectID : flashVar for use with remoting - defines a parametre to pass to a remote method - a FarCry Object ID --->
	<cfparam name="attributes.RPCObjectID" default="" />

	<!--- stRPC : cfStruct containing additional user defined flashVars for use with remoting --->
	<cfparam name="attributes.stRPC" default="#structNew()#" />

	<!--- Request.InHead : caveat to enable use of flashWrapper if request scope is not present --->
	<cfparam name="Request.InHead" default="#structNew()#" />


	<!--- swfObjectJS : sets boolean in request scope to ensure swfObject JS is included in the head of the page --->
	<cfset Request.InHead.swfObjectJS = true />
	<!--- RPCFlashVars : contains output for default flashVars --->
	<cfset variables.RPCFlashVars = "" />
	<!--- additionalFlashVars : contains output for additional user defined flashVars --->
	<cfset variables.additionalFlashVars = "" />


	<!--- if container width is undefined assign width of swf --->
	<cfif not len(trim(attributes.containerWidth))>
		<cfset attributes.containerWidth = attributes.SWFWidth/>
	</cfif>
	<!--- if container height is undefined assign height of swf --->
	<cfif not len(trim(attributes.containerHeight))>
		<cfset attributes.containerHeight = attributes.SWFHeight/>
	</cfif>


	<!--- set contents of RPCFlashVars for output --->
	<cfsavecontent variable="variables.RPCFlashVars">
		<cfif len(trim(attributes.RPCServiceName))>
			<!--- additional ascii characters to ensure readability of output --->
			<cfoutput>#Chr(10)##Chr(9)##Chr(9)##Chr(9)##Chr(9)#</cfoutput>
			<!--- output flashVar --->
			<cfoutput>so.addVariable("RPCServiceName", "#attributes.RPCServiceName#");</cfoutput>
		</cfif>
		<cfif len(trim(attributes.RPCMethod))>
			<!--- additional ascii characters to ensure readability of output --->
			<cfoutput>#Chr(10)##Chr(9)##Chr(9)##Chr(9)##Chr(9)#</cfoutput>
			<!--- output flashVar --->
			<cfoutput>so.addVariable("RPCMethod", "#attributes.RPCMethod#");</cfoutput>
		</cfif>
		<cfif len(trim(attributes.RPCObjectID))>
			<!--- additional ascii characters to ensure readability of output --->
			<cfoutput>#Chr(10)##Chr(9)##Chr(9)##Chr(9)##Chr(9)#</cfoutput>
			<!--- output flashVar --->
			<cfoutput>so.addVariable("RPCObjectID", "#attributes.RPCObjectID#");</cfoutput>
		</cfif>
	</cfsavecontent>


	<!--- set contents of additionalFlashVars for output --->
	<cfif not structIsEmpty(attributes.stRPC)>
		<cfsavecontent variable="variables.additionalFlashVars">
			<cfloop list="#structKeyList(attributes.stRPC)#" index="i">
				<!--- additional ascii characters to ensure readability of output --->
				<cfoutput>#Chr(10)##Chr(9)##Chr(9)##Chr(9)##Chr(9)#</cfoutput>
				<!--- output flashVar --->
				<cfoutput>so.addVariable("#i#", "#attributes.stRPC[i]#");</cfoutput>
			</cfloop>
		</cfsavecontent>
	</cfif>


	<!--- start output html --->
	<cfoutput>
		<div class="#attributes.class#">
			<div id="#attributes.SWFID#Container" style="width: #attributes.containerWidth#px; height: #attributes.containerHeight#px;">
				<p>This content requires the Macromedia Flash Player.</p>
				<p><a href="http://www.macromedia.com/go/getflash/">Get Flash</a>.</p>
			</div>
			<script type="text/javascript">
				var so = new SWFObject("#attributes.SWFSource#", "#attributes.SWFID#", "#attributes.SWFWidth#", "#attributes.SWFHeight#", "#attributes.SWFVersion#", "#attributes.SWFBackgroundColor#");
				so.addParam("quality", "high");
				so.addParam("wmode", "#attributes.SWFWMode#");
				so.addParam("menu", "#attributes.SWFMenu#");
				so.addParam("allowScriptAccess", "#attributes.SWFScriptAccess#");</cfoutput>
				<!--- output contentes of RPCFlashVars --->
				<cfoutput>#RPCFlashVars#</cfoutput>
				<!--- output contentes of additionalFlashVars --->
				<cfoutput>#additionalFlashVars#
				so.write("#attributes.SWFID#Container");
			</script>
		</div>
	</cfoutput>
	<!--- end html output --->

</cfif>

<cfif thistag.executionMode eq "End">
	<!--- null --->
</cfif>

<cfsetting enablecfoutputonly="no" />
<!--- end enable output only from cfoutput tags --->