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
<!--- @@displayname: Render a form  --->
<!--- @@description: Renders the farcry form with relevent css and markup.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>

<cfparam name="attributes.Name" default="farcryForm#randrange(1,999999999)#">
<cfparam name="attributes.Target" default="">
<cfparam name="attributes.Action" default="">
<cfparam name="attributes.method" default="post">
<cfparam name="attributes.onsubmit" default="">
<cfparam name="attributes.Class" default="">
<cfparam name="attributes.Style" default="">
<cfparam name="attributes.Validation" default="1">
<cfparam name="attributes.bAjaxSubmission" default="false">
<cfparam name="attributes.ajaxMaskMsg" default="Form Submitting, please wait...">
<cfparam name="attributes.ajaxMaskCls" default="x-mask-loading">
<cfparam name="attributes.ajaxTimeout" default="30">
<cfparam name="attributes.ajaxTarget" default=""><!--- jQuery selector specifying the target element for the form response. Defaults to the FORM element. --->
<cfparam name="attributes.bAddFormCSS" default="true" /><!--- Uses uniform (http://sprawsm.com/uni-form/) --->
<cfparam name="attributes.bFieldHighlight" default="true"><!--- Highlight fields when focused --->
<cfparam name="attributes.bFocusFirstField" default="false" /><!--- Focus on first form element. --->
<cfparam name="attributes.defaultAction" default="" /><!--- The default action to be used if user presses enter key on browser that doesn't fire onClick event of first button. --->
<cfparam name="attributes.autoSave" default="false" /><!--- Enter boolean to toggle default autosave values on properties --->
<cfparam name="attributes.autoSaveToSessionOnly" default="false" /><!--- If there are any autosave fields, should they save to the session only? --->

<cfif thistag.ExecutionMode eq "start">
	<!--- Do Nothing --->
</cfif>



<cfif thistag.ExecutionMode eq "end">


	<cfset innerHTML = "" />
	<cfif len(thisTag.generatedContent)>
		<cfset innerHTML = thisTag.generatedContent />
		<cfset thisTag.generatedContent = "" />
	</cfif>
	
	<cfif attributes.bAddFormCSS>
		<skin:loadCSS id="farcry-form" />
	</cfif>

	<cfoutput>
	<form 	action="#application.fc.lib.esapi.encodeForHTMLAttribute(attributes.Action)#" 
			method="#attributes.Method#" 
			id="#attributes.Name#" 
			name="#attributes.Name#" 
			<cfif len(attributes.Target)> target="#attributes.Target#"</cfif> 
			enctype="multipart/form-data" 
			class="#attributes.class#"  
			style="#attributes.style#" >
		
			#innerHTML#


	        <!--- If we are validating this form, load and initialise the validation engine.  --->
	        <cfif attributes.validation>
	            <skin:loadJS id="fc-jquery-validate" />

	            <!--- set up validation selectors and classes based on the form theme --->
	            <cfset stValConfig = application.fapi.getContentType(typename="formTheme" & attributes.formtheme).getValidationConfig()>

	            <!--- Setup farcry form validation (fv) --->
	            <skin:onReady>
	                <cfoutput>
	                if(typeof $j('###attributes.Name#').validate != "undefined") {
	                    $fc.fv#attributes.Name# = $j("###attributes.Name#").validate({
	                        onsubmit: false, // let the onsubmit function handle the validation
	                        errorElement: "#stValConfig.errorElement#",
	                        errorClass: "#stValConfig.errorElementClass#",
	                        <cfif len(stValConfig.wrapper)>
	                            wrapper: "#stValConfig.wrapper#",  // a wrapper around the error message                       
	                        </cfif>                       
	                        errorPlacement: function(error, element) {
	                              error.prependTo( element.closest("#stValConfig.errorPlacementSelector#") );
	                        },
	                        highlight: function(element, errorClass) {
	                           $j(element).closest("#stValConfig.fieldContainerSelector#").addClass('#stValConfig.fieldContainerClass#');
	                        },
	                        unhighlight: function(element, errorClass) {
	                           $j(element).closest("#stValConfig.fieldContainerSelector#").removeClass('#stValConfig.fieldContainerClass#');
	                        }
	                    });
	                }
	                
	                </cfoutput>
	            </skin:onReady>
	        </cfif>
	            
	        <!--- If we have anything in the onsubmit, use jquery to run it --->
	        <skin:onReady>
	            <cfoutput>
	            $j('###attributes.Name#').submit(function(){    
	                var valid = true;            
	                <cfif attributes.validation EQ 1>
	                    if ( $j("###attributes.Name#").attr('fc:validate') == 'false' ) {
	                        $j("###attributes.Name#").attr('fc:validate',true);                    
	                    } else {
	                        valid = $j('###attributes.Name#').valid();
	                    }
	                </cfif>            
	                     
	                if(valid){
	                    
	                    #attributes.onSubmit#;
	                    
	                    $j("###attributes.Name# .fc-btn, ###attributes.Name# .fc-btn-link").each(function(index,el){
	                        
	                        if( $j(el).attr('fc:disableOnSubmit') ) {
	                             $j(el).attr('disabled', 'disabled');
	                        };
	                        
	                    });
	                    
	                } else {
	                    $fc.fv#attributes.Name#.focusInvalid();
	                    return false;
	                }
	            });
	            <cfif len(Request.farcryForm.defaultAction)>
	                $j('###attributes.Name# input,select').on("keypress",function(e){
	                if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
	                    $j('button[value="#replace(replacelist(Request.farcryForm.defaultAction,"\,!,"",##,$,%,&,',(,),*,+,.,/,:,;,<,=,>,?,@,[,],^,`,{,|,},~","\\\,\\!,\\"",\\##,\\$,\\%,\\&,\\',\\(,\\),\\*,\\+,\\.,\\/,\\:,\\;,\\<,\\=,\\>,\\?,\\@,\\[,\\],\\^,\\`,\\{,\\|,\\},\\~"), ",", "\\,", "ALL")#"]').click();
	                    return false;
	                } else {
	                    return true;
	                }
	            });</cfif>
	            </cfoutput>                
	        </skin:onReady>



			
	</form>
		
	</cfoutput>
</cfif>

