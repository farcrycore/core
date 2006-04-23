<!---

  SourceSafe: $Header: /cvs/farcry/farcry_core/admin/siteobjects/soeditor/lite/docs/Attic/dsp_invocation.cfm,v 1.1.1.1 2002/09/27 06:54:04 petera Exp $
  Date Created: 12/12/2001
  Author: Don Bellamy
  Project: soEditor Lite 2.0
  Description: Invocation

--->

<font face="verdana,arial,helvetica">

<h1>Calling the editor</h1>

<p>The editor can be called in the following way:

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

<p>

The specified form name <b>form</b> is case sensitive and must match the name attribute of the form the editor is included in.  
It is recommended due to the limitations of GET, that all forms including soEditor use the POST method declared in the FORM tag.

</font>

<pre>
Required:
  Form              Case sensitive name of the form soEditor is included in.  
                    This is declared as the FORM tag's <b>name</b> attribute.
  
  Field             The form field name that the edited HTML is posted as.  This
                    can be read by the template declared as the <b>action</b> of 
                    the FORM as a typical HTML form field.
  
  ScriptPath        Sets the URL pointer to the directory that contains the 
                    files of the soEditor package.  <b>ScriptPath</b> must 
                    include a starting and trailing forward slash. e.g. 
                    <i>"/soeditor/"</i>

Optional: 
  Width             Sets the width of the editor.  This can be a relative 
                    measurement such as <i>"100%"</i> or absolute as in 
                    <i>"500px"</i>.  Defaults to <i>"100%"</i>.

  Height            Sets the height of the editor.  This can be a relative 
                    measurement such as <i>"75%"</i> or absolute as in 
                    <i>"300px"</i>.  Defaults to <i>"250px"</i>.

  Cols              Sets the the number of columns to display for the textarea 
                    field when the editor is viewed by non-supporting browsers. 
                    Defaults to <i>"60"</i>.
                    
  Rows              Sets the the number of rows to display for the textarea field 
                    when the editor is viewed by non-supporting browsers. 
                    Defaults to <i>"10"</i>. 
                 
  PageEdit          Sets whether the html being edited includes the HTML, HEAD, 
                    and BODY elements.  Set this attribute to <i>true</i> if you 
                    are editing an entire HTML document, or set this to 
                    <i>false</i> if you are only editing a section or HTML.  
                    Defaults to <i>false</i>.

  SingleSpaced      When set to <i>true</i>, soEditor will break to the next line 
                    when ENTER is pressed.  If set to <i>false</i>, soEditor will 
                    treat all breaks as new block elements, thus simulating
                    the double spacing effect.  Pressing Sft-Enter will insert 
                    the alterative spacing. Defaults to <i>false</i>.

  WordCount         Toggles whether the word counter is displayed.  
                    Defaults to <i>true</i>.

  BaseURL           Sets the base URL used to resolve relative links.  Use this 
                    in a multi-user/server environment.

  BaseFont          Sets the default font to be used in soEditor.

  BaseFontSize      Sets the default font size to be used in soEditor. Can have
                    a value of between 1 and 7.

  BaseFontColor     Sets the default font color to be used in soEditor.

  BaseBGColor       Sets the default background color soEditor.

  ValidateOnSave    When set to <i>true</i> so editor will throw exception 
                    ValidationMessage if the editor does not contain any 
                    text when the form is submitted.
                    
  ValidationMessage Sets the text displayed to user when trying to submit an 
                    empty editor.  

  HTML              Sets the HTML content to be loaded into the editor to be edited.
  
  ShowBorders       Toggles whether to show table borders by default.
                    Defaults to <i>false</i>.
  
  InitialFocus      Toggles whether to place focus on the editor when the page is loaded. 
                    Defaults to <i>false</i>.

  New               Toggles whether to display the new button.
                    Defaults to <i>true</i>.

  Save              Toggles whether to display the save button. 
                    Defaults to <i>true</i>.
                    
  Cut               Toggles whether to display the cut button.    
                    Defaults to <i>true</i>.           
  
  Copy              Toggles whether to display the copy button.               
                    Defaults to <i>true</i>.
  
  Paste             Toggles whether to display the paste button.               
                    Defaults to <i>true</i>.
  
  Delete            Toggles whether to display the delete button.               
                    Defaults to <i>true</i>.
  
  Find              Toggles whether to display the find button.  
                    Defaults to <i>true</i>.
                    
  Undo              Toggles whether to display the undo button.               
                    Defaults to <i>true</i>.
  
  Redo              Toggles whether to display the redo button.   
                    Defaults to <i>true</i>.
                    
  HR                Toggles whether to display the horizontal rule button.
                    Defaults to <i>true</i>.

  Image             Toggles whether to display the image button. 
                    Defaults to <i>true</i>.
  
  Link              Toggles whether to display the link button. 
                    Defaults to <i>true</i>.
  
  Unlink            Toggles whether to display the unlink button. 
                    Defaults to <i>true</i>.
  
  SpellCheck        Toggles whether to display the spellcheck button.  
                    See instructions on how to enable this feature.
                    Defaults to <i>false</i>.
  
  Help              Toggles whether to display the help button.  
                    Defaults to <i>true</i>.
  
  Align             Toggles whether to display the align button.               
                    Defaults to <i>true</i>.
  
  List              Toggles whether to display the list button.               
                    Defaults to <i>true</i>.
  
  UnIndent          Toggles whether to display the unindent button.    
                    Defaults to <i>true</i>.           
  
  Indent            Toggles whether to display the indent button.      
                    Defaults to <i>true</i>.
  
  FontDialog        Toggles whether to display the font dialog button.
                    Defaults to <i>true</i>.
  
  Format            Toggles whether to display the format button. 
                    Defaults to <i>true</i>.

  FormatList        Sets the format values to be included in the format list pull 
                    down.  Defaults to <i>"none,h1,h2,h3,h4,h5,h6,pre"</i>

  FormatListLabels  Sets the labels of the <b>FormatList</b> in the respective 
                    order.  Defaults to 
                    <i>"Normal,Heading 1,Heading 2,Heading 3,Heading 4,Heading 5,
                    Heading 6,Formatted"</i>
            
  Font              Toggles whether to display the font select box.    
                    Defaults to <i>true</i>.
                    
  FontList          Sets the list of font values to be included in the font pull 
                    down. Defaults to <i>"Arial,Tahoma,Courier New,Times New Roman,Verdana,Wingdings"</i>

  FontListLabels    Sets the labels of the <b>FontList</b> in the respective order.  
                    Defaults to the values of <b>FontList</b>.

  Size              Toggles whether to display the size button.     
                    Defaults to <i>true</i>.

  SizeList          Sets the size values to be included in the size list pull down.  
                    Defaults to <i>"1,2,3,4,5,6,7"</i>

  SizeListLabels    Sets the labels of the <b>SizeList</b> in the respective order.  
                    Defaults to the values of <b>SizeList</b>.                 

  Bold              Toggles whether to display the bold button.               
                    Defaults to <i>true</i>.
  
  Italic            Toggles whether to display the italic button.               
                    Defaults to <i>true</i>.
  
  Underline         Toggles whether to display the underline button.       
                    Defaults to <i>true</i>.
                    
  SuperScript       Toggles whether to display the superscript button.        
                    Defaults to <i>true</i>.

  SubScript         Toggles whether to display the subscript button.   
                    Defaults to <i>true</i>.
  
  FGColor           Toggles whether to display the foreground color button.               
                    Defaults to <i>true</i>.
  
  BGColor           Toggles whether to display the background color button.            
                    Defaults to <i>true</i>.
  
  Tables            Toggles whether to display the table toolbar.   
                    Defaults to <i>true</i>.
  
  InsertCell        Toggles whether to display the insert cell button.
                    Defaults to <i>true</i>.
  
  DeleteCell        Toggles whether to display the delete cell button.            
                    Defaults to <i>true</i>.
  
  InsertRow         Toggles whether to display the insert row button.                   
                    Defaults to <i>true</i>.
  
  DeleteRow         Toggles whether to display the delete row button.                 
                    Defaults to <i>true</i>.
  
  InsertColumn      Toggles whether to display the insert column button.               
                    Defaults to <i>true</i>.
  
  DeleteColumn      Toggles whether to display the delete column button.               
                    Defaults to <i>true</i>.
  
  SplitCell         Toggles whether to display the split cell button.               
                    Defaults to <i>true</i>.
  
  MergeCell         Toggles whether to display the merge cell button.            
                    Defaults to <i>true</i>.
    
  CellProp          Toggles whether to display the cell property button.    
                    Defaults to <i>true</i>.
  
  HTMLEdit          Toggles whether to display the HTML/Text edit button.         
                    Defaults to <i>true</i>.
  
  Borders           Toggles whether to display the border button. 
                    Defaults to <i>true</i>.     

  Details           Toggles whether to display the document details button.             
                    Defaults to <i>true</i>.    
</pre> 