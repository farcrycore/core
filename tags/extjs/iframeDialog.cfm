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
	
	
	<skin:htmlHead library="extJS" />

	<skin:htmlHead id="iFrameDialogJS">
	<cfoutput>
		<script language="javascript">
			Ext.ux.IFrameComponent = Ext.extend(Ext.BoxComponent, {
			     onRender : function(ct, position){
			          this.el = ct.createChild({tag: 'iframe', id: 'iframe-'+ this.id, frameBorder: 0, src: this.url });
			     }
			});
			
			var iFrameDialog;
			function openScaffoldDialog(url,title,width,height,resizable,onclose) {
		        iFrameDialog = new Ext.Window({
		        	
					height:		height,
					width:		width,
					resizable:	resizable,
					layout:		"fit",
					title:		title,
					collapsible: false,
		            plain:		true,
		            modal:		false,
		            autoScroll:	false,
		            id:			"iframedialog",
		            items: 		[ new Ext.ux.IFrameComponent({ id: "iframedialog", url: url, width:'100%', height:'100%' }) ]
		        });
				if (onclose) iFrameDialog.on("close",onclose);
		        iFrameDialog.show('');
		        iFrameDialog.alignTo(Ext.getBody(), 't-t');
				Ext.select("##iframedialog .x-window-body").setStyle("overflow","auto");
			}
			function closeDialog() {
				iFrameDialog.close();
			}
		</script>
	</cfoutput>
	</skin:htmlHead>
		

	
	
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