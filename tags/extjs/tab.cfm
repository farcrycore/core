<cfsetting enablecfoutputonly="true">
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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
<!--- @@displayname:  --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />

<!------------------ 
START TAG
 ------------------>




<cfif thistag.executionMode eq "Start">

	<cfparam name="attributes.id" default="#createUUID()#">
	<cfparam name="attributes.title" default="">
	<cfparam name="attributes.style" default="">
	<cfparam name="attributes.class" default="">
	<cfparam name="attributes.icon" default="">
	<cfparam name="attributes.aPanels" default="#arrayNew(1)#"><!--- An array of Panels --->
	<cfparam name="attributes.stConfig" default="#structNew()#">
	<cfparam name="attributes.stConfig.width" default="">
	<cfparam name="attributes.stConfig.height" default="">
	<cfparam name="attributes.stConfig.autoWidth" default="true">
	<cfparam name="attributes.stConfig.autoHeight" default="true">
	<cfparam name="attributes.stConfig.activeTab" default="0">
	<cfparam name="attributes.stConfig.frame" default="true">
	<cfparam name="attributes.stConfig.autoScroll" default="true">
	<cfparam name="attributes.stConfig.deferredRender" default="false">

		
	
	<skin:htmlHead library="extJS" />
	
</cfif>

<cfif thistag.executionMode eq "End">

	<cfset thisTag.GeneratedContent = "" />
	
	<cfset activeTab = "" />

	<cfoutput>		
		<div id="#attributes.id#" style="#attributes.style#" class="#attributes.class#">			
			<cfloop from="1" to="#arrayLen(attributes.aPanels)#" index="i">
			    <div id="#attributes.aPanels[i].id#" class=" #attributes.aPanels[i].class#" style="#attributes.aPanels[i].style#">
			        <p>#attributes.aPanels[i].html#</p>
			    </div>
			</cfloop>
		</div>
	</cfoutput>					



	<!--- When rendering nested ui elements like tabs and accordions, we need to render the outer elements first. Hence the position="first" attribute. --->
	<skin:htmlHead position="first">
		<cfoutput>
		<script type="text/javascript">	
		Ext.onReady(function() {
			
			
			var tab = new Ext.TabPanel({
						    
			    renderTo: '#attributes.id#',
		        items:[
		            <cfloop from="1" to="#arrayLen(attributes.aPanels)#" index="i">
			            {
				            contentEl:'#attributes.aPanels[i].id#'
				            ,title: '#attributes.aPanels[i].title#'
					        <cfloop list="#structKeyList(attributes.aPanels[i].stConfig)#" index="j">
					        	<cfif len(attributes.aPanels[i].stConfig[j])>
						        	,#j#:#attributes.aPanels[i].stConfig[j]#
					        	</cfif>
					        </cfloop>
						}
			            <cfif i LT arrayLen(attributes.aPanels)>,</cfif>
					</cfloop>
		        ]
		        <cfif not structIsEmpty(attributes.stConfig)>
			        <cfloop list="#structKeyList(attributes.stConfig)#" index="i">
			        	<cfif len(attributes.stConfig[i])>
				        	,#i#:#attributes.stConfig[i]#
			        	</cfif>
			        </cfloop>
			    </cfif>
		        
		    });
			
			
		});
		</script>
		</cfoutput>
	</skin:htmlHead>

	
	



		<!--- Ext.example = function() {
		     var msgCt;
		 
		     function createBox(t, s){
		         return ['<div class="msg">',
		                 '<div class="x-box-tl"><div class="x-box-tr"><div class="x-box-tc"></div></div></div>',
		                 '<div class="x-box-ml"><div class="x-box-mr"><div class="x-box-mc"><h3>', t,
		                 '</h3>', s, '</div></div></div>',
		                 '<div class="x-box-bl"><div class="x-box-br"><div class="x-box-bc"></div></div></div>',
		                 '</div>'].join('');
		     }
		     return {
		         msg : function(title, format){
		             if(!msgCt){
		                 msgCt = Ext.DomHelper.insertFirst(document.body, {id:'msg-div'}, true);
		             }
		             msgCt.alignTo(document, 'bl-bl', [10, -90]);
		             var s = String.format.apply(String, Array.prototype.slice.call(arguments, 1));
		             var m = Ext.DomHelper.append(msgCt, {html:createBox(title, s)}, true);
		             m.slideIn('b').pause(1).ghost("b", {remove:true});
		         }
		     };
		 }();
		 
		 Ext.example.msg('title', 'message'); --->

	
<!--- 
<cfoutput>
<div id="a#attributes.id#" style="height:300px">
  <div id="a#attributes.id#panel-1">
    <div>My first panel</div>
    <div>
      <div class="text-content">#attributes.id#<br />My first panel content</div>
    </div>
  </div>
  <div id="a#attributes.id#panel-2">
    <div>My second panel</div>
    <div>
      <div class="text-content">#attributes.id#<br />My second panel content</div>
    </div>
  </div>
</div>

	<script type="text/javascript">
	Ext.BLANK_IMAGE_URL = '/extjs/resources/images/default/s.gif';
	
	Ext.onReady(function() {
		
	  // create accordion
	  var acc = new Ext.ux.Accordion('a#attributes.id#', {
	    
		title: 'Accordion' 
		, body: 'west-body'
		, fitContainer: true 
		, fitToFrame: true 
		, useShadow: true
		, adjustments: [0, -26]
			    
	  })
	
	  // create panel 1
	  var panel1 = acc.add(new Ext.ux.InfoPanel('a#attributes.id#panel-1', {
	  	collapsed: true
	  }));
	  
	  // create panel 2
	  var panel2 = acc.add(new Ext.ux.InfoPanel('a#attributes.id#panel-2', {
	  	collapsed: false
	  }));
	  
	});
	</script>
	</cfoutput> --->


</cfif>

<cfsetting enablecfoutputonly="false">

