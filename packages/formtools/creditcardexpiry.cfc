

<cfcomponent name="creditcardexpiry" displayname="Credit Card Expiry" hint="Field containing a credit card expiry" extends="field"> 
	
	<cfproperty name="dbPrecision" required="false" default="7" hint="Credit card numbers are stored in the format MM/YYYY" />
	
	
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
		<cfif not listfindnocase(arguments.stMetadata.ftValidation,"creditcardexpiry")>
			<cfset arguments.stMetadata.ftValidation = listappend(arguments.stMetadata.ftValidation,"creditcardexpiry") />
		</cfif>
		
		<cfparam name="arguments.stMetadata.ftClass" default="" />
		<cfif not listfindnocase(arguments.stMetadata.ftClass,"creditcardexpiry"," ")>
			<cfset arguments.stMetadata.ftClass = listappend(arguments.stMetadata.ftClass,"creditcardexpiry"," ") />
		</cfif>
		
		<skin:onReady id="ccexpiry_validation"><cfoutput>
			function checkDate(datestring){
				var parts = datestring.split("/"), month = parseInt(parts[0]), year = parseInt(parts[1]), nowdate = new Date(), futureyears = parseInt(nowdate.getFullYear().toString().slice(2)) + 20;
				
				if (parts[1].length === 2){
					year = year < futureyears ? year + 2000 : year + 1900;
				}
				
				return year > nowdate.getFullYear() || (year === nowdate.getFullYear() && month >= nowdate.getMonth()+1);
			};
			$j.validator.addMethod("creditcardexpiry", function(value, element) {
				return this.optional(element) || (/^(0?[1-9]|1[012])\/(\d{2}|\d{4})$/i.test(value) && checkDate(value));
			}, "Not a valid expiry date. Please enter MM/YYYY.");
			$j(document).delegate(".creditcardexpiry input","blur",function(){
				if (/^(0?[1-9]|1[012])\/(\d{2}|\d{4})$/i.test(this.value)){
					var parts = this.value.split("/"), month = parseInt(parts[0]), year = parseInt(parts[1]), nowdate = new Date(), futureyears = parseInt(nowdate.getFullYear().toString().slice(2)) + 20;
					
					if (parts[1].length === 2){
						year = year < futureyears ? year + 2000 : year + 1900;
					}
					
					this.value = (month < 10 ? "0" : "") + month.toString() + "/" + year.toString();
				}
			});
		</cfoutput></skin:onReady>
		
		<cfsavecontent variable="html"><cfoutput>
			<div class="multiField">
				<input type="text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" maxLength="7" placeholder="MM/YYYY" class="textInput #arguments.inputClass# #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#">
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
		<cfset var earliestdate = createdate(year(now()),month(now()),1) />
		<cfset var expiry = "" />
		
		<cfif len(arguments.stFieldPost.value) and not refind("^(0[1-9]|1[012])\/(\d{2}|\d{4})$",arguments.stFieldPost.value)>
			<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="Not a valid expiry date. Please enter MM/YYYY.") />
		<cfelseif len(arguments.stFieldPost.value)>
			<cfset expiry = createdate(listlast(arguments.stFieldPost.value,"/"),listfirst(arguments.stFieldPost.value,"/"),1) />
			<cfset arguments.stFieldPost.value = numberformat(month(expiry),'00') & "/" & year(expiry) />
			
			<cfif len(arguments.stFieldPost.value) eq 6>
				<cfset arguments.stFieldPost.value = "0" & arguments.stFieldPost.value />
			</cfif>
			
			<cfif expiry gte earliestdate>
				<cfset stResult = passed(value=arguments.stFieldPost.value) />
			<cfelse>
				<cfset stResult = failed(value=arguments.stFieldPost.value, message="Not a valid expiry date. Please enter MM/YYYY.") />
			</cfif>
		<cfelse>
			<cfset stResult = super.validate(argumentCollection=arguments) />
		</cfif>
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
	</cffunction>
	
</cfcomponent> 
