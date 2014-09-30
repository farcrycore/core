<cfsetting enablecfoutputonly="true" />

<cfheader statuscode="500" statustext="Internal Server Error" />

<!--- rudimentary error handler --->
<cfoutput>
	<html>
		<head>
			<title><cfif isdefined("application.fapi") and isdefined("application.rb")>#application.fapi.getResource('error.500@title','There was a problem with that last request')#<cfelse>There was a problem with that last request</cfif></title>
			<style type="text/css">
				body { 
					margin:0px; 
					background-color:##FFFFFF; 
					padding:15px; 
					font-family: Arial, Helvetica, sans-serif;
				}
				table, td, th {
					border: 0 none;
					border-collapse:collapse;
				}
				th { 
					text-align:right;
					vertical-align:top;
				}
				td, th {
					padding:5px;
				}
				h1 {
					margin-top: 0;
				}
				
				.formatjson .key {
					color:##a020f0;
				}
				.formatjson .number {
					color:##ff0000;
				}
				.formatjson .string {
					color:##000000;
				}
				.formatjson .boolean {
					color:##ffa500;
				}
				.formatjson .null {
					color:##0000ff;
				}
			</style>
			<script type="text/javascript" src="#application.url.webtop#/thirdparty/jquery/js/jquery-1.9.1.min.js"></script>
			<script type="text/javascript">
				window.$fc = window.$fc || {};
				
				$fc.syntaxHighlight = function(json) {
					if (typeof json != 'string')
						json = JSON.stringify(json, undefined, 2);
					
					json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
					return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
						var cls = 'number';
						if (/^"/.test(match)) {
							if (/:$/.test(match)) {
								cls = 'key';
							} else {
								cls = 'string';
							}
						} else if (/true|false/.test(match)) {
							cls = 'boolean';
						} else if (/null/.test(match)) {
							cls = 'null';
						}
						return '<span class="' + cls + '">' + match + '</span>';
					});
				}
				
				if (jQuery){
					jQuery.fn.formatJSON = function(){
						return this.each(function(){
							var el = jQuery(this);
							
							el.html($fc.syntaxHighlight(el.html()));
						});
					}
					
					jQuery(function(){
						jQuery(".formatjson").formatJSON();
					});
				}
			</script>
		</head>
		<body>
			<cfif isdefined("application.fapi") and isdefined("application.rb")>
				<h1>#application.fapi.getResource('error.500@title','There was a problem with that last request')#</h1>
				#application.fapi.getResource('error.goback@html','<p>Please push "back" on your browser or go back <a style="text-decoration:underline" href="/">home</a></p>')#
			<cfelse>
				<h1>There was a problem with that last request</h1>
				<p>Please push "back" on your browser or go back <a style="text-decoration:underline" href="/">home</a></p>
			</cfif>
			<cfif showError>
				#errorHTML#
			</cfif>
		</body>
	</html>		
</cfoutput>

<cfsetting enablecfoutputonly="false" />