

<cfcomponent name="creditcardnumber" displayname="Credit Card Number" hint="Field containing a credit card number" extends="field"> 
	
	<cfproperty name="dbPrecision" required="false" default="16" hint="Credit card numbers are maximum 16 characters" />
	
	
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
		<cfargument name="inputClass" required="false" type="string" default="" hint="This is the class value that will be applied to the input field.">

		<cfset var html = "" />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<skin:loadJS id="fc-jquery" />
		
		<cfparam name="arguments.stMetadata.ftValidation" default="" />
		<cfif not listfindnocase(arguments.stMetadata.ftValidation,"creditcard")>
			<cfset arguments.stMetadata.ftValidation = listappend(arguments.stMetadata.ftValidation,"creditcard") />
		</cfif>
		
		<cfparam name="arguments.stMetadata.ftClass" default="" />
		<cfif not listfindnocase(arguments.stMetadata.ftClass,"creditcard"," ")>
			<cfset arguments.stMetadata.ftClass = listappend(arguments.stMetadata.ftClass,"creditcard"," ") />
		</cfif>
		
		<cfsavecontent variable="html"><cfoutput>
			<div class="multiField">
				<input type="text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#application.fc.lib.esapi.encodeForHTMLAttribute(arguments.stMetadata.value)#" class="textInput #arguments.inputClass# #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" maxLength="#arguments.stMetadata.dbPrecision#" />
				
				<script type="text/javascript">
					(function($){
						function validateLuhn(ccnumber){
							ccnumber = ccnumber.replace(/[^\w]/g,"").split("");
							
							// Checksum ("Mod 10")
							// Add even digits in even length strings or odd digits in odd length strings.
							var checksum = 0;
							for (var i=(2-(ccnumber.length % 2)); i<=ccnumber.length; i+=2) {
								checksum += parseInt(ccnumber[i-1]);
							}
							
							// Analyze odd digits in even length strings or even digits in odd length strings.
							for (var i=(ccnumber.length % 2) + 1; i<ccnumber.length; i+=2) {
								var digit = parseInt(ccnumber[i-1]) * 2;
								
								checksum += (digit < 10 ? digit : digit-9);
							}
							
							return checksum % 10 === 0;
						};
						
						$j("###arguments.fieldname#").bind("change",function ccNumberChange(result){
							var self = $j(this), value = this.value;
							
							if (value.length === 0)
								self.trigger("no-creditcard",this.value);
							else if (!validateLuhn(value))
								self.trigger("invalid-creditcard",value);
							else
								self.trigger("valid-creditcard",value);
						}).bind("valid-creditcard",function(event,creditcardnumber){
							//var self = $j(this), buffer = (self.height() - 16) / 2;
							//self.css("background","url('#application.url.webtop#/images/creditcards/yes.png') no-repeat scroll "+Math.floor(self.width()-16-buffer).toString()+"px center transparent");
						}).bind("invalid-creditcard",function ccNumberInvalidNumber(event,creditcardnumber){
							//var self = $j(this), buffer = (self.height() - 16) / 2;
							//self.css("background","url('#application.url.webtop#/images/creditcards/no.png') no-repeat scroll "+Math.floor(self.width()-16-buffer).toString()+"px center transparent");
						});
						
						$j(function(){
							$j("###arguments.fieldname#").trigger("change");
						});
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
		
		<cfif len(arguments.stMetadata.value)>
			<cfsavecontent variable="html">
				<cfoutput>#repeatstring("*",len(arguments.stMetadata.value)-4)##right(arguments.stMetadata.value,4)#</cfoutput>
			</cfsavecontent>
		</cfif>
		
		<cfreturn html>
	</cffunction>

	
	<cffunction name="validateLuhn" access="public" output="false" returntype="boolean">
		<cfargument name="ccnumber" type="string" required="true" />
		
		<cfset var checksum = 0 />
		<cfset var i = 0 />
		<cfset var digit = 0 />
		<cfset var cclen = len(arguments.ccnumber) />
		
		<cfset arguments.ccnumber = rereplace(arguments.ccnumber,"[^\w]","","all") />
		
		<!--- Checksum ("Mod 10") --->
		<!--- Add even digits in even length strings or odd digits in odd length strings. --->
		<cfloop from="#2-(cclen mod 2)#" to="#cclen#" index="i" step="2">
			<cfset checksum = checksum + mid(arguments.ccnumber,i,1) />
		</cfloop>
		
		<!--- Analyze odd digits in even length strings or even digits in odd length strings. --->
		<cfloop from="#(cclen mod 2) + 1#" to="#cclen - 1#" index="i" step="2">
			<cfset digit = mid(ccnumber,i,1) * 2 />
			
			<cfif digit lt 10>
				<cfset checksum = checksum + digit />
			<cfelse>
				<cfset checksum = checksum + digit - 9 />
			</cfif>
		</cfloop>
		
		<cfreturn checksum mod 10 eq 0 />
	</cffunction>
	
	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="objectid" required="true" type="string" hint="The objectid of the object that this field is part of.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>
		
		<cfif len(arguments.stFieldPost.value) and not validateLuhn(arguments.stFieldPost.value)>
			<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="Please enter a valid credit card number.") />
		<cfelse>
			<cfset stResult = super.validate(argumentCollection=arguments) />
		</cfif>
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
	</cffunction>
	
</cfcomponent> 
