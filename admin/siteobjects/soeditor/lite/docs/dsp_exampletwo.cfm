<!---

  SourceSafe: $Header: /cvs/farcry/farcry_core/admin/siteobjects/soeditor/lite/docs/Attic/dsp_exampletwo.cfm,v 1.1.1.1 2002/09/27 06:54:04 petera Exp $
  Date Created: 12/12/2001
  Author: Don Bellamy
  Project: soEditor Lite 2.0
  Description: Example one

--->

<cfparam name="Form.soEditor" default="">

<font face="verdana,arial,helvetica">
<h1>Example Two</h1>
<p>Displays a very small soEditor field that is designed specifically to serve as a text entry component.  All HTML toolbar buttons have been removed.  Wordcount and spell checking also complement this configuration. 
<p>Removing excess buttons also speeds up the display of the editor in the browser.</p>
<pre>
&lt;cf_soEditor_lite 
    form="documentation" 
    field="soeditor" 
    scriptpath="<cfoutput>#Variables.ScriptPath#</cfoutput>"
    width="350"
    height="100"
    singlespaced="true"
    wordcount="true" 
    validateonsave="true"
    find="false"
    hr="false"
    image="false" 
    link="false"
    unlink="false"
    align="false" 
    list="false" 
    unindent="false" 
    indent="false"
    fontdialog="false"
    format="false" 
    font="false"
    size="false" 
    bold="false" 
    italic="false" 
    underline="false"
    superscript="false"
    subscript="false"
    fgcolor="false" 
    bgcolor="false"
    tables="false"
    htmledit="false"
    borders="false" 
    details="false"&gt;
</pre>

<p>Press the save button to post the content to this page.</p>

</font>

<cfif Len(Form.soEditor)>

  <h3 style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;">Submitted HTML:</h3>
  <hr><p><cfoutput>#Form.soEditor#</cfoutput><p><hr>

</cfif>

<form name="documentation" action="index.cfm?method=exampletwo" method="post" onsubmit="alert();">
<cf_soEditor_lite 
  form="documentation" 
  field="soeditor" 
  scriptpath="#Variables.ScriptPath#"
  width="350"
  height="100"
  singlespaced="true"
  wordcount="true" 
  validateonsave="true"
  find="false"
  hr="false"
  image="false" 
  link="false"
  unlink="false"
  align="false" 
  list="false" 
  unindent="false" 
  indent="false"
  fontdialog="false"
  format="false" 
  font="false"
  size="false" 
  bold="false" 
  italic="false" 
  underline="false"
  superscript="false"
  subscript="false"
  fgcolor="false" 
  bgcolor="false"
  tables="false"
  htmledit="false"
  borders="false" 
  details="false"
  html="#Form.soEditor#">
</form>
