n0<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: extjs IFrame Dialog --->
<!--- @@description: Places a nice curved border around content.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfparam name="attributes.url" type="string" default="" />
<cfparam name="attributes.id" type="string" default="" />
<cfparam name="attributes.event" type="string" default="click" />
<cfparam name="attributes.width" type="integer" default="500" />
<cfparam name="attributes.height" type="integer" default="500" />
<cfparam name="attributes.title" type="string" default="" />
<cfparam name="attributes.resizable" type="boolean" default="false" />

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
	
	
<cfif thistag.executionMode eq "start">
	
	
	<skin:htmlhead library="extJS" />

	<skin:htmlhead id="iframedialog">
	<cfoutput>
		<script language="javascript">
			
			function openScaffoldDialog(url,title,width,height,resizable) {

		        var win = new Ext.Window({
					height:		height,
					width:		width,
					modal:		true,
					resizable:	resizable,
					title:		title,
					collapsible: false,
		            plain:true,
		            modal:'true',
		            autoScroll:'true',		
		            html:"<iframe src='"+url+"' frameborder='0' scrolling='no' id='scaffoldiframe' width='"+(width-37)+"px' height='"+(height-37)+"px'></iframe>"
		        });
		
		        win.show(this);
		
				
			<!--- 	dialog = new Ext.BasicDialog(Ext.DomHelper.insertFirst(Ext.DomQuery.selectNode("body"),"<div></div>",true), {
					height:		height,
					width:		width,
					modal:		true,
					resizable:	resizable,
					title:		title,
					collapsible: false
				});
				dialog.body.dom.innerHTML="<iframe src='"+url+"' frameborder='0' scrolling='no' id='scaffoldiframe' width='"+(width-37)+"px' height='"+(height-37)+"px'></iframe>";
				dialog.addKeyListener(27, dialog.hide, dialog); // ESC can also close the dialog
				dialog.show(); --->
				
				<!--- return false; --->
			}
		</script>
	</cfoutput>
	</skin:htmlhead>
		

	
	
	<!--- If the user has passed an id, attach the event. --->
	<cfif len(attributes.id) and len(attributes.url)>	
			
		<cfif find("?",attributes.url)>
			<cfset attributes.url = attributes.url & "&iframe" />
		<cfelse>
			<cfset attributes.url = attributes.url & "?iframe" />
		</cfif>
		
		<cfoutput>
			<script language="javascript">
				Ext.addBehaviors({ 
					'###attributes.id#@#attributes.event#' : function(e,t){
						openScaffoldDialog('#attributes.url#','#attributes.title#',#attributes.width#,#attributes.height#,#attributes.resizable#);
						e.preventDefault();
					}
				});
			</script>
		</cfoutput>
	</cfif>
</cfif>