<cfsetting showdebugoutput="No">
<!---

  SourceSafe: $Header: /cvs/farcry/farcry_core/admin/siteobjects/soeditor/lite/docs/Attic/index.cfm,v 1.1.1.1 2002/09/27 06:54:04 petera Exp $
  Date Created: 12/12/2001
  Author: Don Bellamy
  Project: soEditor Lite 2.0
  Description: Index file for docs

--->

<cfparam name="URL.Method" default="">

<!--- Documentation variables --->
<cfscript>
  Variables.ScriptPath = "/siteobjects/soeditor/lite/";
  Variables.DocPath = "/siteobjects/soeditor/lite/docs/";
</cfscript>

<cfswitch expression="#URL.Method#">

<cfcase value="exampleone">
  <cfinclude template="dsp_header.cfm">
  <cfinclude template="dsp_exampleone.cfm">
  <cfinclude template="dsp_footer.cfm">  
</cfcase>

<cfcase value="exampletwo">
  <cfinclude template="dsp_header.cfm">
  <cfinclude template="dsp_exampletwo.cfm">
  <cfinclude template="dsp_footer.cfm">  
</cfcase>

<cfcase value="Invocation">
  <cfinclude template="dsp_header.cfm">
  <cfinclude template="dsp_invocation.cfm">
  <cfinclude template="dsp_footer.cfm">  
</cfcase>

<cfdefaultcase>
  <cfinclude template="dsp_header.cfm">
  <cfinclude template="dsp_main.cfm">
  <cfinclude template="dsp_footer.cfm">
</cfdefaultcase>

</cfswitch>