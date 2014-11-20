function dis_pagelist(items,itemsOnPage,currentPage) {
	$('#query_id_test_page_list').pagination({
		items: items,
		itemsOnPage: itemsOnPage,
		cssStyle: 'light-theme',
		currentPage: currentPage,
		onPageClick: pageselectCallback
	});
}
function dis_pagelist_proto(items,itemsOnPage,currentPage) {
	$('#query_id_test_page_list').pagination({
		items: items,
		itemsOnPage: itemsOnPage,
		cssStyle: 'light-theme',
		currentPage: currentPage,
		onPageClick: pageselectCallback_proto
	});
}
function query_testdata(page,datatype) {
	var limit=5;
	var offset=(page-1)*5;
	var belong=document.getElementById("id_user_name").innerHTML;
	var retdata;
	$.ajax({
		type: "post",//使用post方法访问后台
		dataType: "json",//返回json格式的数据
		url: "/pb/query_testdata/",//要访问的后台地址
		contentType: "application/json; charset=utf-8",
		cache: false,
		async: false,
		data: {limit:limit,offset:offset,belong:belong,datatype:datatype},//要发送的数据
		//start : function(){},
		//complete :function(){$("#load").hide();},//AJAX请求完成时隐藏loading提示
		success: function(data){//msg为返回的数据，在这里做数据绑定
			retdata=data;
		}
	});
	return retdata;
}
function dis_datalist(retdata,datatype) {
	datalist=retdata.ret_dict;
	var len=datalist.length;
	if (len == 0){
		document.getElementById("id_datalist").innerHTML = "";
		var t="";
		if (datatype != -1) {
			t+="<td>&nbsp;</td><td>&nbsp;</td>";
			t+="<td style='text-align:center;font-size:16px;'>您还没添加测试数据，<br/><a href='/pb/conf/?conftype=adddata'><b>立即添加</b></a></td>";
			t+="<td>&nbsp;</td>";
		} else {
			t+="<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>";
			t+="<td style='text-align:center;font-size:16px;'>您还没添加测试数据，<br/><a href='/pb/conf/?conftype=adddata'><b>立即添加</b></a></td>";
			t+="<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>";
		}
		$("#id_datalist").append(t);
	} else {
		if (datatype == -1) {
			var t="";
			$.each(datalist, function(i,n){
				t+="<tr><td>";
				t+=n.id;
				t+="</td><td>";
				t+=n.name;
				t+="</td><td>";
				t+=n.type;
				t+="</td><td>";
				t+=n.belong;
				t+="</td><td>";
				t+=n.filenum;
				t+="</td><td>";
				t+=n.descpt;
				t+="</td><td class='i-operate'><a href='javascript:list_testdata("+n.id+");' title='查看'>查看</a><a href='javascript:del_testdata("+n.id+");' title='删除'>删除</a></td>";
			});
			document.getElementById("id_datalist").innerHTML = "";
			$("#id_datalist").append(t);
		} else{
			var t="";
			$.each(datalist, function(i,n){
				t+="<tr><td  style='padding-top:2px;padding-bottom:2px;'>";
				if (i == 0) {
					t+="<input type='radio' name='testdata' checked='checked' value=";
				} else {
					t+="<input type='radio' name='testdata' value=";
				}
				t+=n.id;
				t+=" />";
				t+="</td><td>";
				t+=n.id;
				t+="</td><td>";
				t+=n.name;
				t+="</td><td>";
				t+=n.descpt;
				t+="</td></tr>";
			});
			document.getElementById("id_datalist").innerHTML = "";
			$("#id_datalist").append(t);
		}
	}
}
function pageselectCallback_proto (page, jq) {
	var retdata=query_testdata(page,0);
	dis_datalist(retdata,0);
	dis_pagelist(retdata.data_totalcnt,5,page);
}
function pageselectCallback (page, jq) {
	var retdata=query_testdata(page,-1);
	dis_datalist(retdata,-1);
	dis_pagelist(retdata.data_totalcnt,5,page);
}
function del_testdata(id) {
	$.ajax({
		type: "post",//使用post方法访问后台
		dataType: "json",//返回json格式的数据
		url: "/pb/del_testdata/",//要访问的后台地址
		contentType: "application/json; charset=utf-8",
		cache: false,
		async: false,
		data: {id:id},//要发送的数据
		//start : function(){},
		//complete :function(){$("#load").hide();},//AJAX请求完成时隐藏loading提示
		success: function(data){//msg为返回的数据，在这里做数据绑定
			if (data.errcoden == 1 && data.errcodem >= 1) {
				//show_message('删除成功',0.5,'消息提示');
				MessageBox('warning', '删除成功');
				var retdata=query_testdata(1,-1);
				dis_datalist(retdata,-1);
				dis_pagelist(retdata.server_totalcnt,5,1);
			} else {
				MessageBox('warning', '删除失败');
			}
		}
	});
}
function list_testdata(id){
	MessageBox('warning', '还未实现');
}

function handle_select() {
	var toottype = document.getElementById('id_tooltype').selectedIndex;
	if (toottype == 1 || toottype == 3) {
		//dis test data table and page list
		var retdata=query_testdata(1,0);
		dis_datalist(retdata,0);
		dis_pagelist(retdata.data_totalcnt,5,1);
		document.getElementById('query_id_test_page_list').style.visibility = "visible"; 
		//dis table
		document.getElementById('id_proto_testdata').style.visibility = "visible"; 
	} else {
		document.getElementById('id_proto_testdata').style.visibility = "hidden"; 
		document.getElementById('query_id_test_page_list').style.visibility = "hidden"; 
	}
}


/////////////////test srv
function dis_pagelist_srv(items,itemsOnPage,currentPage) {
	$('#query_id_testsrv_page_list').pagination({
		items: items,
		itemsOnPage: itemsOnPage,
		cssStyle: 'light-theme',
		currentPage: currentPage,
		onPageClick: pageselectCallback_srv
	});
}
function query_server(page) {
	var limit=5;
	var offset=(page-1)*5;
	var belong=document.getElementById("id_user_name").innerHTML;
	var retdata;
	$.ajax({
		type: "post",//使用post方法访问后台
		dataType: "json",//返回json格式的数据
		url: "/pb/query_server/",//要访问的后台地址
		contentType: "application/json; charset=utf-8",
		cache: false,
		async: false,
		data: {limit:limit,offset:offset,belong:belong},//要发送的数据
		//start : function(){},
		//complete :function(){$("#load").hide();},//AJAX请求完成时隐藏loading提示
		success: function(data){//msg为返回的数据，在这里做数据绑定
			retdata=data;
		}
	});
	return retdata;
}
function query_server_workspace(id) {
	var workspace;
	$.ajax({
		type: "post",//使用post方法访问后台
		dataType: "json",//返回json格式的数据
		url: "/pb/query_server_workspace/",//要访问的后台地址
		contentType: "application/json; charset=utf-8",
		cache: false,
		async: false,
		data: {id:id},//要发送的数据
		//start : function(){},
		//complete :function(){$("#load").hide();},//AJAX请求完成时隐藏loading提示
		success: function(data){//msg为返回的数据，在这里做数据绑定
			workspace=data.workspace;
		}
	});
	return workspace;
}

function download_testtool(tooltype) {
	var proto=$("input[name='testdata']:checked").val();
	var srv=$("input[name='testsrv']:checked").val();
	var path=$('#id_path').val();
	var belong=document.getElementById("id_user_name").innerHTML;
	$.ajax({
		type: "post",//使用post方法访问后台
		dataType: "json",//返回json格式的数据
		url: "/pb/download_testtool/",//要访问的后台地址
		contentType: "application/json; charset=utf-8",
		cache: false,
		async: false,
		data: {tooltype:tooltype,proto:proto,srv:srv,path:path,belong:belong},//要发送的数据
		beforeSend : function(){
			document.getElementById('id_loading').style.visibility = "visible"; 
		},
		//complete :function(){$("#load").hide();},//AJAX请求完成时隐藏loading提示
		success: function(data){//msg为返回的数据，在这里做数据绑定
			retdata=data.msg;
			document.getElementById('id_loading').style.visibility = "hidden"; 
			//alert(retdata);
			MessageBox('warning', retdata);
		}
	});
}


function dis_serverlist(retdata,type) {
	serverlist=retdata.ret_dict;
	var len=serverlist.length;
	if (len == 0){
		document.getElementById("id_serverlist").innerHTML = "";
		var t="";
		if (type == 1) {
			t+="<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>";
			t+="<td style='text-align:center;font-size:16px;'>您还没添加机器，<br/><a href='/pb/conf/?conftype=addsrv'><b>立即添加</b></a></td>";
			t+="<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>";
		} else {
			t+="<td>&nbsp;</td><td>&nbsp;</td>";
			t+="<td style='text-align:center;font-size:16px;'>您还没添加机器，<br/><a href='/pb/conf/?conftype=addsrv'><b>立即添加</b></a></td>";
			t+="<td>&nbsp;</td>";
		}
		$("#id_serverlist").append(t);
	} else {
		var t="";
		$.each(serverlist, function(i,n){
			if (type == 1) {
				t+="<tr><td>";
				t+=n.id;
				t+="</td><td>";
				t+=n.name;
				t+="</td><td>";
				t+=n.ip;
				t+="</td><td>";
				t+=n.workspace;
				t+="</td><td>";
				t+=n.belong;
				t+="</td><td>";
				t+=n.descpt;
				t+="</td><td class='i-operate'><a href='javascript:mod_server("+n.id+");' title='修改'>修改</a><a href='javascript:del_server("+n.id+");' title='删除'>删除</a></td>";
			} else {
				t+="<tr><td  style='padding-top:2px;padding-bottom:2px;'>";
				if (i == 0) {
					t+="<input type='radio' name='testsrv' checked='checked' value=";
				} else {
					t+="<input type='radio' name='testsrv' value=";
				}
				t+=n.id;
				t+=" />";
				t+="</td><td>";
				t+=n.id;
				t+="</td><td>";
				t+=n.name;
				t+="</td><td>";
				t+=n.ip;
				t+="</td><td>";
				t+=n.descpt;
				t+="</td></tr>";
			}
		});
		document.getElementById("id_serverlist").innerHTML = "";
		$("#id_serverlist").append(t);
	}
}
function pageselectCallback_srv (page, jq) {
	var retdata=query_server(page);
	dis_serverlist(retdata,1);
	dis_pagelist_srv(retdata.server_totalcnt,5,page);
}
function del_server(id) {
	$.ajax({
		type: "post",//使用post方法访问后台
		dataType: "json",//返回json格式的数据
		url: "/pb/del_server/",//要访问的后台地址
		contentType: "application/json; charset=utf-8",
		cache: false,
		async: false,
		data: {id:id},//要发送的数据
		//start : function(){},
		//complete :function(){$("#load").hide();},//AJAX请求完成时隐藏loading提示
		success: function(data){//msg为返回的数据，在这里做数据绑定
			if (data.errcode == 1) {
				//show_message('删除成功',0.5,'消息提示');
				MessageBox('warning', '删除成功');
				var retdata=query_server(1);
				dis_serverlist(retdata,1);
				dis_pagelist_srv(retdata.server_totalcnt,5,1);
			} else {
				MessageBox('warning', '删除失败');
			}
		}
	});
}
function mod_server(id){
	MessageBox('warning', '还未实现');
}
