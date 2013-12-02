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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@displayname: Webtop Overview Developer Actions --->


<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">


<skin:htmlHead id="select-text"><cfoutput><script type="text/javascript">
	function selectText(element) {
	    var doc = document;
	    if (typeof(element) == "String") element = doc.getElementById(element);    
	    if (doc.body.createTextRange) { // ms
	        var range = doc.body.createTextRange();
	        range.moveToElementText(element);
	        range.select();
	    } else if (window.getSelection) {
	        var selection = window.getSelection();
	        if (selection.setBaseAndExtent) { // webkit
	            selection.setBaseAndExtent(element, 0, element, 1);
	        } else { // moz, opera
	            var range = doc.createRange();
	            range.selectNodeContents(element);
	            selection.removeAllRanges();
	            selection.addRange(range);
	        }
	    }
	}
</script></cfoutput></skin:htmlHead>

<cfoutput>
	<div class="developer-actions">
		<div class="objectid" style="display:none;">#stObj.objectid#</div>
		<a onclick="var oid = $j(this).siblings('.objectid').toggle();selectText(oid[0]);return false;" title="See objectid"><i class="fa fa-tag"></i></a>
		<a onclick="$fc.openDialog('Property Dump', '#application.url.webtop#/index.cfm?objectid=#stObj.objectid#&typename=#stObj.typename#&view=webtopDump');return false;" title="Open a window containing all the raw data of this content item"><i class="fa fa-list"></i></a>
	</div>
</cfoutput>


<cfsetting enablecfoutputonly="false">