;(function($){
	var stringtruthyness = {
		"" : false, 
		"0" : false,
		"NO" : false,
		"false" : false,
		
		"1" : true,
		"YES" : true,
		"true" : true
	}
	
	$.fn.typeahead = function setupTypeahead(config){
		this.each(function(){
			var self = $(this);
			var fieldname = this.id;
			
			var thisconfig = jQuery.extend({
				typename : self.data("typename"),
				prefix : self.data("prefix"),
				objectid : self.data("objectid"),
				ajaxurl : self.data("ajaxurl"),
				multiple : self.data("multiple"),
				watch : self.data("watch") || "",
				placeholder : self.data("placeholder"),
				values : self.data("value"),
				data : self.data("data") || undefined,
				createoptions : self.data("createoptions") || undefined,
				minimumInputLength : self.data("minimuminputlength")===undefined ? 3 : self.data("minimuminputlength"),
				pagesize : 15
			},config);
			thisconfig.multiple = stringtruthyness[thisconfig.multiple];
			thisconfig.watch = thisconfig.watch.split ? thisconfig.watch.split(",") : [];
			self.data("typeahead-config",thisconfig);
			
			var propertyname = fieldname.slice(thisconfig.prefix.length);
			
			var aValues = (thisconfig.values.length == 0 ? [] : thisconfig.values.split(",").map(function(v){ 
				return {
					id: v.split("|")[0],
					text: v.split("|")[1]
				};
			}));
			if (!thisconfig.multiple && aValues.length) 
				aValues = aValues[0];
			else if (thisconfig.multiple && aValues.length)
				;
			else
				aValues = "";
			
			function formatResult(object,container,query){
				return object.librarySelected || object.text;
			};
			
			function getData(term,page){
				var result = {
					search: term, // search term
					page: page
				};
				
				result[propertyname] = self.select2("val");
				if (result[propertyname].constructor == Array) result[propertyname] = result[propertyname].join();
				
				for (var i=0; i<thisconfig.watch.length; i++){
					result[thisconfig.watch[i]] = [];
					$j("select[name="+thisconfig.prefix+thisconfig.watch[i]+"], input[name="+thisconfig.prefix+thisconfig.watch[i]+"][type=text], input[name="+thisconfig.prefix+thisconfig.watch[i]+"][type=password], input[name="+thisconfig.prefix+thisconfig.watch[i]+"][type=checkbox]:checked, input[name="+thisconfig.prefix+thisconfig.watch[i]+"][type=radio]:checked").each(function(){
						result[thisconfig.watch[i]].push($(this).val());
					});
					result[thisconfig.watch[i]] = result[thisconfig.watch[i]].join();
				}
				
				return result;
			};
			
			if (thisconfig.data) {
				self.select2({
					minimumInputLength: thisconfig.minimumInputLength,
					multiple: thisconfig.multiple,
					allowClear: !thisconfig.multiple,
					placeholder: thisconfig.placeholder,
					formatResult: formatResult,
					query: function(options){
						var result = {
							results : [],
							more : false,
							context : null
						}
						
						for (var i=0; i<thisconfig.data.length; i++)
							if (thisconfig.data[i].text.toString().toLowerCase().indexOf(options.term.toLowerCase()) > -1) result.results.push(thisconfig.data[i]);
						
						if (result.results.length > options.page * thisconfig.pagesize)
							result.more = true;
						
						result.results = result.results.slice((options.page-1) * thisconfig.pagesize,options.page * thisconfig.pagesize)
						
						if (thisconfig.createoptions) result.results = result.results.concat(thisconfig.createoptions);
						
						options.callback(result);
					}
				});
			}
			else {
				self.select2({
					minimumInputLength: thisconfig.minimumInputLength,
					multiple: thisconfig.multiple,
					allowClear: !thisconfig.multiple,
					placeholder: thisconfig.placeholder,
					ajax: { // instead of writing the function to execute the request we use Select2's convenient helper
						url: thisconfig.ajaxurl,
						dataType: 'json',
						data: getData,
						results: function(data, page){ // parse the results into the format expected by Select2.
							// since we are using custom formatting functions we do not need to alter remote JSON data
							return {
								results: data
							};
						}
					},
					formatResult: formatResult
				});
			}

			self.bind("change",function(e){
				if (typeof(e.val)=="string" && e.val.length && e.val.slice(0,1) == "_"){
					$j(this).select2("val","");
					$j("#"+fieldname+"-add-type").val(e.val.slice(1));
					
					fcForm.openLibraryAdd(thisconfig.typename,thisconfig.objectid,propertyname,fieldname);
				}
				else if (e.val.constructor==Array && e.val.length && e.val[e.val.length-1].slice(0,1) == "_"){
					var val = $j(this).select2("val");
					val.pop();
					$j(this).select2("val",val);
					$j("#"+fieldname+"-add-type").val(e.val[e.val.length-1].slice(1));
					e.val.pop();
					$j("#"+fieldname).val(e.val.join(","));
					
					fcForm.openLibraryAdd(thisconfig.typename,thisconfig.objectid,propertyname,fieldname);
				}
			}).select2("data", aValues);

			if (!fcForm.typeaheadOldRefreshProperty){
				fcForm.typeaheadOldRefreshProperty = fcForm.refreshProperty
				fcForm.refreshProperty = function(typename,objectid,property,id){
					if ($j("#"+id).siblings(".select2-container").size()){
						$j.getJSON(thisconfig.ajaxurl,{ resolvelabels:$j("#"+id).val() },function(data){
							var self = $j("#"+id), thisconfig = self.data("typeahead-config");
							if (thisconfig.data) thisconfig.data.push(data[data.length-1]);
							self.select2("data",thisconfig.multiple ? data : data[0]);
						});
					}
					else{
						fcForm.typeaheadOldRefreshProperty(typename,objectid,property,id);
					}
				}
			}
			
			self.siblings(".select2-container").find(".select2-default").bind("click",function(){
				this.value = "";
			});
		});
	};
	
	$(function(){
		$("input.typeahead,select.typeahead").typeahead();
	})
})(jQuery);