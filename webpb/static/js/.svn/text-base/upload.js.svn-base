$(document).ready(function() {
	$("#file_upload_1").uploadify({
		height        : 30,
		swf           : '/static/js/model/uploadify/uploadify.swf',
		uploader      : '/pb/upload/',
		queueID       : 'fileQueue',
		folder        : 'UploadFile',
		width         : 240,
		auto          : false,
		fileTypeExts  : '*.proto',
		fileTypeDesc  : '请选择proto类型文件',
		buttonText    : '请选择...',
		hideButton    : true,
		multi         : true,
		cancelImg     : '/static/js/model/uploadify/uploadify-cancel.png'/*,
		onUploadSuccess : function(file, data, response) {
			var jsondata = JSON.parse(data); 
			alert(jsondata.msg);
		}*/
	});
}); 



