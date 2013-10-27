<cfsetting enablecfoutputonly="true" />
<!--- @@description: 
	<p>The pop tag is useed to handle bubble'd messages.</p>
	<p>NOTE: Core uses the following tags in it's messages:</p>
	<ul>
		<li>type</li>
		<li>[typename]</li>
		<li>container</li>
		<li>rule</li>
		<li>security</li>
		<li>updated</li>
		<li>created</li>
		<li>deleted</li>
		<li>workflow</li>
		<li>information</li>
		<li>warning</li>
		<li>error</li>
		<li>system</li>
		<li>updateapp</li>
	</ul>
 --->
<!--- @@examples:
	<p>This tag has two modes: custom output and automatic output.</p>
	<p>Custom output</p>
	<code>
		<skin:pop start="<ul>" end="</ul>">
			<li><strong>#message.title#</strong> #message.message#</li>
		</skin:pop>
	</code>
	<p>Automatic output:</p>
	<code>
		<skin:pop format="headerblock" />
	</code>
	<p>Only handling messages with specific tags:</p>
	<code>
		<skin:pop format="headerblock" tags="error" />
	</code>
 --->

<cfparam name="attributes.tags" default="" type="string" /><!--- Messages with any of these tags will be popped. All messages are popped by default. --->
<cfparam name="attributes.variable" default="message" type="string" /><!--- The variable that the message information will be stored in --->
<cfparam name="attributes.start" default="" type="string" /><!--- String to output at the start ONLY if there is at least one matching message --->
<cfparam name="attributes.end" default="" type="string" /><!--- String to output at the end ONLY if there is at least one matching message --->
<cfparam name="attributes.format" default="" type="string" /><!--- Automatically process the output using "gritter" or "headerblock" --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not thistag.HasEndTag>
	<cfthrow message="skin:pop must have an end tag" />
<cfelseif not isdefined("session.aGritterMessages")>
	<cfexit method="exittag" />
</cfif>

<cfif thistag.ExecutionMode eq "start">
	<cfparam name="session.aGritterMessages" default="#arraynew(1)#" />
	
	<cfset thistag.thismessage = 1 />
	<cfset thistag.tagregex = "(^|,)(#replace(attributes.tags,',','|','ALL')#)($|,)" />
	<cfset thistag.allout = "" />
	
	<!--- Find next message that matches the tags --->
	<cfloop condition="thistag.thismessage lte arraylen(session.aGritterMessages) and attributes.tags neq '' and not refindnocase(thistag.tagregex,session.aGritterMessages[thistag.thismessage].tags)">
		<cfset thistag.thismessage = thistag.thismessage + 1 />
	</cfloop>
	
	<!--- No messages found that match the criteria, so exit --->
	<cfif thistag.thismessage gt arraylen(session.aGritterMessages)>
		<cfexit method="exittag" />
	</cfif>
	
	<!--- Intialisation of built in message formats --->
	<cfswitch expression="#attributes.format#">
		<cfcase value="gritter">
			<skin:loadJS id="fc-jquery" />
			<skin:loadJS id="gritter" />
			<skin:loadCSS id="gritter" />
		</cfcase>
		<cfcase value="headerblock">
			<skin:loadJS id="fc-jquery" />
			<skin:loadJS id="fc-jquery-ui" />
			<skin:loadCSS id="jquery-ui" />
			<skin:loadCSS id="headerblock" />
		</cfcase>
	</cfswitch>
	
	<!--- This code is only run if there is at least one message --->
	<cfif len(attributes.start)><cfoutput>#attributes.start#</cfoutput></cfif>
	
	<!--- Clean up the title and message --->
	<cfset session.aGritterMessages[thistag.thismessage].title = replace(session.aGritterMessages[thistag.thismessage].title,"&nbsp;"," ","ALL") />
	<cfset session.aGritterMessages[thistag.thismessage].title = reReplace(session.aGritterMessages[thistag.thismessage].title,"[\r\n]"," ","ALL") />
	<cfset session.aGritterMessages[thistag.thismessage].message = replace(session.aGritterMessages[thistag.thismessage].message,"&nbsp;"," ","ALL") />
	<cfset session.aGritterMessages[thistag.thismessage].message = reReplace(session.aGritterMessages[thistag.thismessage].message,"[\r\n]"," ","ALL") />
	
	<!--- Pass the message back to the tag contents --->
	<cfset "caller.#attributes.variable#" = duplicate(session.aGritterMessages[thistag.thismessage]) />
</cfif>

<cfif thistag.ExecutionMode eq "end">
	<!--- Output for built in message formats --->
	<cfswitch expression="#attributes.format#">
		<cfcase value="gritter">
			<cfsavecontent variable="thistag.thisout">
				<cfoutput>
					$j.gritter.add({
						// (string | mandatory) the heading of the notification
						title: '#jsstringformat(session.aGritterMessages[thistag.thismessage].title)#',
						// (string | mandatory) the text inside the notification
						text: '#jsstringformat(session.aGritterMessages[thistag.thismessage].message)#',
						// (string | optional) the image to display on the left
						image: '#session.aGritterMessages[thistag.thismessage].image#',
						// (bool | optional) if you want it to fade out on its own or just sit there
						sticky: #session.aGritterMessages[thistag.thismessage].sticky#, 
						// (int | optional) the time you want it to be alive for before fading out (milliseconds)
						time: #session.aGritterMessages[thistag.thismessage].pause#
					});
				</cfoutput>
			</cfsavecontent>
			<cfset thistag.allout = thistag.allout & thistag.thisout />
		</cfcase>
		
		<cfcase value="headerblock">
			<cfset thistag.allout = listappend(thistag.allout,serializeJSON(session.aGritterMessages[thistag.thismessage])) />
		</cfcase>
	</cfswitch>
	
	<!--- Remove processed message --->
	<cfset arraydeleteat(session.aGritterMessages,thistag.thismessage) />
	
	<!--- Find next message that matches the tags (NOTE: since we just removed a message, the next potential message is at the same index as the old one) --->
	<cfloop condition="thistag.thismessage lte arraylen(session.aGritterMessages) and attributes.tags neq '' and not refindnocase(thistag.tagregex,session.aGritterMessages[thistag.thismessage].tags)">
		<cfset thistag.thismessage = thistag.thismessage + 1 />
	</cfloop>
	
	<!--- No more messages --->
	<cfif thistag.thismessage gt arraylen(session.aGritterMessages)>
		<!--- Conclusion of built in message formats --->
		<cfswitch expression="#attributes.format#">
			<cfcase value="gritter">
				<skin:onReady><cfoutput>#thistag.allout#</cfoutput></skin:onReady>
			</cfcase>
			<cfcase value="headerblock">
				<skin:loadCSS id="fc-fontawesome" />
				<skin:onReady><script type="text/javascript"><cfoutput>
					$j("body").prepend("<div id='header-message-block'></div>");
					$j("span.close-message").on("click",function(){
						$j(this).parents(".message").slideUp();
						return false;
					});
					$j([#thistag.allout#]).each(function(index){
						var i = index;
						$j("##header-message-block").append("<div id='message-"+i.toString()+"' class='message "+(this.TAGS!==""?this.TAGS.replace(/(^|,)/g,"tag-"):"")+"'>"+(this.TITLE.search(/\w/)>-1?"<strong>"+this.TITLE+"</strong>":"")+(this.TITLE.search(/\w/)>-1 && this.MESSAGE.search(/\w/)>-1?": ":"")+(this.MESSAGE.search(/\w/)>-1?this.MESSAGE:"")+"<span href='##' title='OK' class='fa fa-times-circle-o close-message'></span></div>");
						if (!this.STICKY) setTimeout(function(){ $j("##message-"+i.toString()+":visible").slideUp(); },this.PAUSE);
					});
				</cfoutput></script></skin:onReady>
			</cfcase>
		</cfswitch>
		
		<!--- This code is only run if there was at least one message --->
		<cfif len(attributes.end)><cfoutput>#attributes.end#</cfoutput></cfif>
		
		<!--- Exit tag --->
		<cfexit method="exittag" />
	</cfif>
	
	<!--- Clean up the title and message --->
	<cfset session.aGritterMessages[thistag.thismessage].title = replace(session.aGritterMessages[thistag.thismessage].title,"&nbsp;"," ","ALL") />
	<cfset session.aGritterMessages[thistag.thismessage].title = reReplace(session.aGritterMessages[thistag.thismessage].title,"[\r\n]"," ","ALL") />
	<cfset session.aGritterMessages[thistag.thismessage].message = replace(session.aGritterMessages[thistag.thismessage].message,"&nbsp;"," ","ALL") />
	<cfset session.aGritterMessages[thistag.thismessage].message = reReplace(session.aGritterMessages[thistag.thismessage].message,"[\r\n]"," ","ALL") />
	
	<!--- Pass the message back to the tag contents --->
	<cfset "caller.#attributes.variable#" = duplicate(session.aGritterMessages[thistag.thismessage]) />
	
	<cfexit method="loop" />
</cfif>

<cfsetting enablecfoutputonly="false" />