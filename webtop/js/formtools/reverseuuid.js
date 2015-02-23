$j(document).ready(function(){ 
	$j(document).on("click",".reverseuuid-add", function(e) {
		var $formtoolWrap = $j(this).closest('.reverseuuid-wrap');
		var $formtoolWrapFieldname = $formtoolWrap.attr('formtoolWrapFieldname');
		var $formtoolWrapTypename = $formtoolWrap.attr('formtoolWrapTypename');
		var $formtoolWrapObjectID = $formtoolWrap.attr('formtoolWrapObjectID');
		var $formtoolWrapProperty = $formtoolWrap.attr('formtoolWrapProperty');
		var $formtoolWrapJoinTypename = $formtoolWrap.attr('formtoolWrapJoinTypename');
		var $formtoolWrapJoinDisplayname = $formtoolWrap.attr('formtoolWrapJoinDisplayname');
		var $formtoolWrapEditView = $formtoolWrap.attr('formtoolWrapEditView');
		var $formtoolWrapEditBodyView = $formtoolWrap.attr('formtoolWrapEditBodyView');
		var $formtoolWrapAddBodyView = $formtoolWrap.attr('formtoolWrapAddBodyView');
		var $onHidden = function() {
			$fc.refreshProperty( $formtoolWrap.closest('span.propertyRefreshWrap') );
			return true;
		}

		$fc.openBootstrapModal({	title: 'Edit ' + $formtoolWrapJoinDisplayname, 
									onHidden:$onHidden, 
									url: '/index.cfm?type=' + $formtoolWrapTypename + '&objectid=' + $formtoolWrapObjectID + '&view=' + $formtoolWrapEditView + '&bodyView=' + $formtoolWrapAddBodyView + '&reverseUUIDProperty=' + $formtoolWrapProperty + '&iframe=1'
		});

	});

	$j(document).on("click",".reverseuuid-edit", function(e) {
		var $objectid = $j(this).closest('[objectid]').attr('objectid');
		var $formtoolWrap = $j(this).closest('.reverseuuid-wrap');
		var $formtoolWrapFieldname = $formtoolWrap.attr('formtoolWrapFieldname');
		var $formtoolWrapTypename = $formtoolWrap.attr('formtoolWrapTypename');
		var $formtoolWrapObjectID = $formtoolWrap.attr('formtoolWrapObjectID');
		var $formtoolWrapProperty = $formtoolWrap.attr('formtoolWrapProperty');
		var $formtoolWrapJoinTypename = $formtoolWrap.attr('formtoolWrapJoinTypename');
		var $formtoolWrapJoinDisplayname = $formtoolWrap.attr('formtoolWrapJoinDisplayname');
		var $formtoolWrapEditView = $formtoolWrap.attr('formtoolWrapEditView');
		var $formtoolWrapEditBodyView = $formtoolWrap.attr('formtoolWrapEditBodyView');
		var $onHidden = function() {
			$fc.refreshProperty( $formtoolWrap.closest('span.propertyRefreshWrap') );
			return true;
		}

		$fc.openBootstrapModal({	title: 'Edit ' + $formtoolWrapJoinDisplayname, 
									onHidden:$onHidden, 
									url: '/index.cfm?type=' + $formtoolWrapJoinTypename + '&objectid=' + $objectid + '&view=' + $formtoolWrapEditView + '&bodyView=' + $formtoolWrapEditBodyView + '&iframe=1'
		});

	});


	$j(document).on("click",".reverseuuid-delete", function(e) {
		var $row = $j(this).closest('[objectid]');
		var $objectid = $row.attr('objectid');
		var $formtoolWrap = $j(this).closest('.reverseuuid-wrap');
		var $formtoolWrapFieldname = $formtoolWrap.attr('formtoolWrapFieldname');
		var $formtoolWrapTypename = $formtoolWrap.attr('formtoolWrapTypename');
		var $formtoolWrapObjectID = $formtoolWrap.attr('formtoolWrapObjectID');
		var $formtoolWrapProperty = $formtoolWrap.attr('formtoolWrapProperty');
		var $formtoolWrapJoinTypename = $formtoolWrap.attr('formtoolWrapJoinTypename');
		var $formtoolWrapEditView = $formtoolWrap.attr('formtoolWrapEditView');
		var $formtoolWrapEditBodyView = $formtoolWrap.attr('formtoolWrapEditBodyView');
		var $formtoolWrapConfirmDeleteText = $formtoolWrap.attr('formtoolWrapConfirmDeleteText');

		if( !confirm( $formtoolWrapConfirmDeleteText ) ) {
			return false;
		}

		$j.ajax({
			cache: false,
			type: "POST",
 			url: '/index.cfm?ajaxmode=1&type=' + $formtoolWrapJoinTypename + '&objectid=' + $objectid + '&view=editReverseUUIDObjectDelete',
			data: {},
			dataType: "html",
			complete: function(data){
				$j($row).remove();
				var $lSortOrder = $formtoolWrap.find('.reverseuuid-sortable').sortable('toArray',{'attribute':'objectid'}).join(",") ;
				$j('#' + $formtoolWrapFieldname).attr('value', $lSortOrder).trigger('change');
			}
		});	
		
	});

});