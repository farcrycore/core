<!---
 
  SourceSafe: $Header: /cvs/farcry/farcry_core/admin/siteobjects/soeditor/lite/docs/Attic/dsp_exampleone.cfm,v 1.2 2002/09/27 07:29:25 petera Exp $
  Date Created: 12/12/2001
  Author: Don Bellamy
  Project: soEditor Lite 2.0
  Description: Example two

--->

<cfparam name="Form.soEditor" default="">

<font face="verdana,arial,helvetica">

<h2>Example One</h2>
<p>
Displays the default configuration of soEditor.
<pre>
&lt;cf_soEditor_lite 
    form="documentation" 
    field="soeditor" 
    scriptpath="<cfoutput>#Variables.ScriptPath#</cfoutput>"&gt;
</pre>
<p>Press the save button to post the content to this page.</p>

</font>

<cfif Len(Form.soEditor)>

  <h3 style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;">Submitted HTML:</h3>
  <hr><p><cfoutput>#Form.soEditor#</cfoutput><p><hr>

</cfif>

<form name="documentation" action="index.cfm?method=exampleone" method="post" onsubmit="alert();">
<cf_soEditor_lite form="documentation" field="soeditor" scriptpath="#Variables.ScriptPath#">
</form>
