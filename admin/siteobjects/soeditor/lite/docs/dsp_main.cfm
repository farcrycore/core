<!---

  SourceSafe: $Header: /cvs/farcry/farcry_core/admin/siteobjects/soeditor/lite/docs/Attic/dsp_main.cfm,v 1.2 2002/09/27 07:29:25 petera Exp $
  Date Created: 12/12/2001
  Author: Don Bellamy
  Project: soEditor Lite
  Description: Main docs page

--->

<a name="top"/>

<font face="verdana,arial,helvetica">

<h1>Browser Based WYSIWYG HTML Editor</h1>

<b><i>soEditor Lite</i></b> can be used to create and maintain html content.

<p>

<pre>
Usage: &lt;cf_soEditor_lite form="formname" field="fieldname" 
           scriptpath="scripturl" [width="width"] [height="height"]
           [cols="int"] [rows="int"] [pageedit="true/false"]
           [singlespaced="true/false"][wordcount="true/false"]
           [baseurl="baseurl"][basefont="basefont"][basefontsize="basefontsize"]
           [basefontcolor="basefontcolor"][basebgcolor="basebgcolor"]
           [validateonsave="true/false"][validationmessage="validationmessage"]
           [html="html"][showborders="true/false"][initialfocus="true/false"][new="true/false"]
           [save="true/false"][cut="true/false"][copy="true/false"][paste="true/false"]
           [delete="true/false"][find="true/false"][undo="true/false"][redo="true/false"]
           [hr="true/false"][image="true/false"][link="true/false"][unlink="true/false"]
           [spellcheck="true/false"][help="true/false"][align="true/false"][list="true/false"]
           [unindent="true/false"][indent="true/false"][fontdialog="true/false"]
           [format="true/false"][formatlist="formatlist"]
           [formatlistlabels="formatlistlables"][font="true/false"]
           [fontlist="fontlist"][fontlistlabels="fontlistlabels"]
           [size="true/false"][sizelist="sizelist"][sizelistlabels="sizelistlabels"]
           [bold="true/false"][italic="true/false"][underline="true/false"]
           [superscript="true/false"][subscript="true/false"][fgcolor="true/false"]
           [bgcolor="true/false"][tables="true/false"][insertcell="true/false"]
           [deletecell="true/false"][insertrow="true/false"][deleterow="true/false"]
           [insertcolumn="true/false"][deletecolumn="true/false"]
           [splitcell="true/false"][mergecell="true/false"][cellprop="true/false"]
           [htmledit="true/false"][borders="true/false"][details="true/false"]&gt;
</pre>

see <a href="index.cfm?method=invocation">Invocation</a>
<p>

<h3>Table of Contents</h3>

<p>

<ul>
<li><a href="#requirements">Requirements</a></li>
<li><a href="#licensing">Licensing</a></li>
<li><a href="#installation">Installation</a></li>
<li><a href="#howitworks">How it works</a></li>
<li><a href="#examples">Example configurations</a></li>
<li><a href="#implementation">Implementation Senarios</a></li>
<li><a href="#spell">Spellchecking</a></li>
<li><a href="#extending">Extending soEditor</a></li>
<li><a href="#support">Support, Feedback and Bug Reporting</a></li>
</ul>

<a href="#top">top</a>

<a name="requirements"><h3>Requirements</h3></a>

<p>

soEditor supports all browsers and operating systems.  
If the browser or OS does not support the advanced editing control a text area will be displayed.

<p>

<b>Server</b>

<ul>
<li>ColdFusion 4.5+</li>
</ul>

<p>

<b>Client</b> <i>(for advanced editing controls)</i>

<ul>
<li>Microsoft Internet Explorer 5.0+</li>
<li>WinX OS</li>
</ul>

<a href="#top">top</a>

<p><a name="licensing"><h3>Licensing</h3></a>
<table border="0" width="500">
<tr bgcolor="#C0C0C0">
<th>version</th><th>encrypted</th><th>price*</th>
</tr>
<tr>
<td>soEditor Lite</td><td align="center">Yes</td><td align="center">FREE!</td>
</tr>
<tr>
<td>&nbsp;</td><td align="center">No</td><td align="center">$99.00 USD</td>
</tr>
<tr>
<td>soEditor Pro</td><td align="center">Yes</td><td align="center">$299.00 USD</td>
</tr>
<tr>
<td>&nbsp;</td><td align="center">No</td><td align="center">$399.00 USD</td>
</tr>
</table>
<p><font size="-1">
<i>* All prices are based per server with no restrictions on the number of users or IP addresses.</i>
<br>
</font></p>

<a href="#top">top</a>

<p>
<a name="installation"><h3>Installation</h3></a>
<ol>
<li>Extract the files of the soEditor package into a directory under your web site root.  The path to these files will then be used as the value of the <i>ScriptPath</i> attribute</li>
<li>Copy <b>soeditor_lite.cfm</b> into a custom tag directory custom tag directory (default c:\cfusion\customtags), OR call soeditor_lite.cfm through CFMODULE using the <i>template</i> attribute.</li>
<li>That's it!  You are ready to <a href="index.cfm?method=invocation">invoke</a> soEditor Lite in your CFML templates.</li>
<li><b>Apache Users</b> You will need to add the following line to your httpd.conf file "AddType text/x-component .htc" without quotes, make sure to restart the Apache daemon.</li>
</ol>
</p>

<a href="#top">top</a>

<p>
<a name="howitworks"><h3>How It Works</h3></a>
soEditor mimics a typical HTML Textarea element in that it must be included inside a FORM element and passes the data through the FORM scope to the template specified in the <i>action</i> attribute of the FORM tag.  To use soEditor one must create a HTML Form and call the soEditor custom tag from within the FORM tag's context.  If the user's browser does not support the advanced editing controls (IE 5+) a textarea element is inserted and HTML source editing is required.  Unless the user's browser is IE 5+ on a Win platform, the user will not have access to the advanced controls.
</p>

<a href="#top">top</a>

<p>
<a name="examples"><h3>Example Configurations</h3></a>

<p><b>Example One</b><p>
Displays the default configuration of soEditor Lite.
<pre>
&lt;cf_soEditor_lite 
    form="documentation" 
    field="soeditor" 
    scriptpath="<cfoutput>#Variables.ScriptPath#</cfoutput>"&gt;
</pre>
<a href="index.cfm?method=exampleone">View</a>
</p>

<p><b>Example Two</b><br/>
<p>Displays a very small soEditor field that is designed specifically to serve as a text entry component.  All HTML toolbar buttons have been removed.  Word count and spell checking also complement this configuration. 
<p>The removal of these buttons also speeds up the display of the editor in the browser.</p>
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
<a href="index.cfm?method=exampletwo">View</a>
</p>
</p>

<a href="#top">top</a>

<p>
<a name="implementation"><h3>Implementation Scenarios</h3></a>
<b>Editing HTML files</b>
<p>
<ol>
  <li>Read the file contents into available using CFFile.</li>
  <li>Invoke soEditor inside a HTML form element.  Make sure to use the specify "post" as the FORM's method.</li>
  <li>Pass file contents into soEditor by way of the <i>html</i> attribute.</li>
  <li>Parse the edited contents in the template specified in the FORM tag's <i>action</i> attribute, by accessing the contents through the FORM scope.  The name of the form variable will match the value specified in soEditor's <i>field</i> attribute.</li>  
  <li>Write the file back to the server hard drive using CFFILE.  PLEASE save all files with the extension of HTML or HTM.  Allowing users to specify the file's extension will expose your server to major security flaws as users will be able to execute dynamic script with extensions such as ASP, CFM, or PHP.</li>
</ol>
Notes:
<ul>
  <li>File name can be passed in a hidden form field when editing an existing file.  This will allow you to write the edited content back to the original file.  It is recommended that you use a hard coded path and do not let users manually set the file's path.</li>
  <li>Make sure to set soEditor's <i>pageEdit</i> attribute to TRUE in able to retain the HTML and HEAD elements.</li>
</ul>
 </p>

<br><b>Editing HTML stored in a database</b>
<p>
<ol>
  <li>Query database for HTML to be edited.</li>
  <li>Invoke soEditor inside a HTML form element.  Make sure to use the specify "post" as the FORM's method.</li>
  <li>Pass in the query variable's contents into soEditor by way of the <i>html</i> attribute.</li>
  <li>Parse the edited contents in the template specified in the FORM tag's <i>action</i> attribute, by accessing the contents through the FORM scope.  The name of the form variable will match the value specified in soEditor's <i>field</i> attribute.</li>  
  <li>Execute UPDATE SQL statement to update database with newly edited content.</li>
</ol>
Notes:
<ul>
  <li>The primary id of the content being edited should be passed in a hidden field.</li>
</ul>
 </p> 
</p>

<a href="#top">top</a>

<p>

<a name="spell"><h3>Spellchecking Support</h3></a>
soEditor currently supports spellchecking by integrating the Spellchecker.net service into the tag.
This is not a free service, you must have an account with Spellchecker.net before using it.
The following describes the steps needed in order to enable spellchecking in soEditor:
<ol>
  <li>Visit <a href="http://www.spellchecker.net/">Spellchecker.net</a> and sign up for an account
  <li>Edit line #12 in spch.js from the soEditor installation with the correct customerid you received from Spellchecker.net:<br>e.g. var customerid = "1:Kfej8-BIuD71-ueCJY-eZUg03-TaquP3-ojrti4-8zSkI2-gbBru1-Xm2AR1-rRRCk1";
  <li>Enable spellchecking in soEditor by setting the attribute Spellcheck to "true"
</ol>

<a href="#top">top</a>

<p>

<a name="extending"><h3>Extending soEditor Lite</h3></a>
soEditor Lite also provides features to allow administrators to extend the functionality to include insertion of specific html blocks through the <i>insertText</i> method of the soEditor control.  
By calling method with JavaScript one can insert specific text or HTML into the document being created or edited.  
This feature can be used to create new functionality based on the soEditor control.
With unencrypted versions of soEditor, custom buttons and toolbars can be created using this funtionality.
<pre>
  soEditor.insertText(sStart, sEnd, asHTML, bAllowEmpty);

    sStart        String to be inserted before the start of the current selection.
  
    sEnd          String to be inserted after the end of the current selection.
  
    asHTML        Boolean variable indicating if the text should be inserted as rendered HTML or as Plain text.
    
    bAllowEmpty   Boolean variable indicating if the text can be inserted without a selection being made.
</pre>

</p> 

<p>

<h4>A Simple Example</h4>

Creating a hyperlink using the code below on a page where soEditor is called will place the text "Hello World!" into the editor when clicked.


<pre>&lt;a href="javascript:soEditor.insertText('Hello World!', '', true,true);"&gt;Click here to say hello&lt;/a&gt;</pre>

</p>

<a href="#top">top</a>

<p><a name="support"><h3>Support, Feedback and Bug Reporting</h3></a>

<p>Visit SiteObjects' Support <a href="http://forums.siteobjects.com/" target="_new">Forums</a></p> 

</font>
