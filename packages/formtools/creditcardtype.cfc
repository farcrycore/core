

<cfcomponent name="creditcardtype" displayname="Credit Card Type" hint="Field containing a credit card type" extends="field"> 
	
	<cfproperty name="dbPrecision" required="false" default="16" hint="Credit card numbers are maximum 16 characters" />
	<cfproperty name="ftAcceptTypes" required="false" default="visa,mastercard,amex,dinersclub,discover,jcb,laser,maestro,solo" />
	<cfproperty name="ftClickable" required="false" default="" hint="By default if ftWatch=ccnumber, then clickable=false, otherwise clicable=true" />
	
	
	<!--- Test credit card numbers:
	American Express			378282246310005
	American Express			371449635398431
	American Express Corporate	378734493671000
	Australian BankCard			5610591081018250
	Diners Club					30569309025904
	Diners Club					38520000023237
	Discover					6011111111111117
	Discover					6011000990139424
	JCB							3530111333300000
	JCB							3566002020360505
	MasterCard					5555555555554444
	MasterCard					5105105105105100
	Visa						4111111111111111
	Visa						4012888888881881
	Visa						4222222222222
	Switch/Solo (Paymentech)	6331101999990016
	 --->
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.field" output="false" hint="Returns a copy of this initialised object">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var thistype = "" />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<skin:loadJS id="fc-jquery" />
		
		<cfif not len(arguments.stMetadata.ftClickable)>
			<cfif structkeyexists(arguments.stMetadata,"ftWatch") and len(arguments.stMetadata.ftWatch)>
				<cfset arguments.stMetadata.ftClickable = false />
			<cfelse>
				<cfset arguments.stMetadata.ftClickable = true />
			</cfif>
		</cfif>
		
		<cfparam name="arguments.stMetadata.ftValidation" default="" />
		<cfif not listfindnocase(arguments.stMetadata.ftValidation,"creditcardtype_#arguments.fieldname#")>
			<cfset arguments.stMetadata.ftValidation = listappend(arguments.stMetadata.ftValidation,"creditcardtype_#arguments.fieldname#") />
		</cfif>
		
		<cfparam name="arguments.stMetadata.ftClass" default="" />
		<cfif not listfindnocase(arguments.stMetadata.ftClass,"creditcardtype_#arguments.fieldname#"," ")>
			<cfset arguments.stMetadata.ftClass = listappend(arguments.stMetadata.ftClass,"creditcardtype_#arguments.fieldname#"," ") />
		</cfif>
		
		<skin:onReady><cfoutput>
			$j.validator.addMethod("creditcardtype_#arguments.fieldname#", function(value, element) {
				return this.optional(element) || /^(#replace(arguments.stMetadata.ftAcceptTypes,',','|','all')#)$/i.test(value);
			}, "Not an accepted credit card type. Valid types are shown below.");
		</cfoutput></skin:onReady>
		
		<cfsavecontent variable="html"><cfoutput>
			<div class="multiField">
				<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" class="#arguments.stMetadata.ftClass#">
				<div id="#arguments.fieldname#-images">
					<cfloop list="#arguments.stMetadata.ftAcceptTypes#" index="thistype">
						<img class="creditcard-#lcase(thistype)#" src="#application.url.webtop#/images/creditcards/#thistype#.png" data-type="#lcase(thistype)#" width="40px" alt="#ucase(left(thistype,1))##lcase(mid(thistype,2,100))#" title="#ucase(left(thistype,1))##lcase(mid(thistype,2,100))#">
					</cfloop>
				</div>
				
				<script type="text/javascript">
					(function($){
						$("###arguments.fieldname#-images img").fadeTo(0,0.3);
						
						var cctypes = {
							"visa" : /^4[0-9]{12}(?:[0-9]{3})?$/,
							"mastercard" : /^5[1-5][0-9]{14}$/,
							"amex" : /^3[47][0-9]{13}$/,
							"dinersclub" : /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
							"discover" : /^6(?:011|5[0-9]{2})[0-9]{12}$/,
							"jcb" : /^(?:2131|1800|35\d{3})\d{11}$/,
							"laser" : /^6(?:304|706|771|709)[0-9]{12,15}$/,
							"maestro" : /^(?:5018|5020|5038|6304|6759|6761|6763)[0-9]{8,15}$/,
							"solo" : /^(?:(?:6334|6767)[0-9]{12}|(?:6334|6767)[0-9]{14,15})$/,
							"unionpay" : /^62[01356][0-9]{13,16}$/
						};
						var acceptedtypes = #serializeJSON(listtoarray(lcase(arguments.stMetadata.ftAcceptTypes)))#;
						
						function getCardType(ccnumber){
							for (var k in cctypes){
								if (ccnumber.match(cctypes[k]))
									return k
							}
							
							return "";
						};
						
						
						function selectCard(type,validate){
							var current = $("###arguments.fieldname#-images .active");
							
							if (!current.is(".creditcard-"+type)){
								if (type.length && acceptedtypes.indexOf(type) === -1){
									// invalid type
									current.fadeTo(300,0.3).removeClass("active");
									//$("###arguments.fieldname#-error").html("That credit card type is not accepted. Accepted types are shown below.").show();
								}
								else{
									current.fadeTo(300,0.3).removeClass("active");
									$("###arguments.fieldname#-images .creditcard-"+type).fadeTo(300,1.0).addClass("active");
									//$("###arguments.fieldname#-error").html("").hide();
								}
							}
							
							$("###arguments.fieldname#").val(type)
							
							if (validate)
								$("###arguments.fieldname#").parents("form").first().validate().element("###arguments.fieldname#");
						};
						
						<cfif structkeyexists(arguments.stMetadata,"ftWatch") and len(arguments.stMetadata.ftWatch)>
							$("###arguments.prefix##arguments.stMetadata.ftWatch#").bind("valid-creditcard",function(event,creditcardnumber){
								selectCard(getCardType(creditcardnumber));
							}).bind("invalid-creditcard",function ccNumberInvalidNumber(event,creditcardnumber){
								selectCard("");
							});
						</cfif>
						
						<cfif arguments.stMetadata.ftClickable>
							$("###arguments.fieldname#-images img").bind("click",function(){
								selectCard($(this).data("type"));
							}).css("cursor","pointer");
						</cfif>
						
						selectCard('#arguments.stMetadata.value#',false);
					})($j);
				</script>
			</div>
		</cfoutput></cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var thistype = arguments.stMetadata.value />
		
		<cfif len(thistype)>
			<cfsavecontent variable="html">
				<cfoutput><img class="creditcard-#lcase(thistype)#" src="#application.url.webtop#/images/creditcards/#thistype#.png" data-type="#lcase(thistype)#" width="40px" alt="#ucase(left(thistype,1))##lcase(mid(thistype,2,100))#" title="#ucase(left(thistype,1))##lcase(mid(thistype,2,100))#"> #ucase(left(thistype,1))##lcase(mid(thistype,2,100))#</cfoutput>
			</cfsavecontent>
		</cfif>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="objectid" required="true" type="string" hint="The objectid of the object that this field is part of.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>
		
		<cfif len(arguments.stFieldPost.value) and not listfindnocase(arguments.stMetadata.ftAcceptTypes,arguments.stFieldPost.value)>
			<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="Not an accepted credit card type. Valid types are shown below.") />
		<cfelse>
			<cfset stResult = super.validate(argumentCollection=arguments) />
		</cfif>
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="addWatch" access="public" output="true" returntype="string" hint="Adds ajax update functionality for the field">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="html" type="string" required="true" hint="The html to wrap" />
		
		<cfreturn arguments.html />
	</cffunction>
	
</cfcomponent> 