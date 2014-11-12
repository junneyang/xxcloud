var evalscripts = [];
__DIALOG_WRAPPER__ = {};
__ScreenLocker_HandleKey__ = null;

function isUndefined(variable)
{
	return typeof variable=='undefined'?true:false;
}

/**
 * 检查字符串是否是json代码
 */
function is_json(data)
{
	var reg = new RegExp(/^{.*}$/igm);
	return reg.test(data);
}

// 用于ajax返回带有js调用等情况
function evalscript(s)
{
	if(s.indexOf('<script') == -1) return s;
	var p = /<script[^\>]*?>([^\x00]*?)<\/script>/ig;
	var arr = [];
	while(arr = p.exec(s)) {
		var p1 = /<script[^\>]*?src=\"([^\>]*?)\"[^\>]*?(reload=\"1\")?(?:charset=\"([\w\-]+?)\")?><\/script>/i;
		var arr1 = [];
		arr1 = p1.exec(arr[0]);
		if(arr1) {
			appendscript(arr1[1], '', arr1[2], arr1[3]);
			// 防止jquery去加载js文件
			s = s.replace(arr1[0], '');
		} else {
			p1 = /<script(.*?)>([^\x00]+?)<\/script>/i;
			arr1 = p1.exec(arr[0]);
			appendscript('', arr1[2], arr1[1].indexOf('reload=') != -1);
		}
	}
	return s;
}

function appendscript(src, text, reload, charset) {
	var id = hash(src + text);
	if(!reload && in_array(id, evalscripts)) return;
	if(reload && document.getElementById(id)) {
		document.getElementById(id).parentNode.removeChild($(id));
	}

	evalscripts.push(id);
	var scriptNode = document.createElement("script");
	scriptNode.type = "text/javascript";
	scriptNode.id = id;
	scriptNode.charset = charset ? charset : (is_moz ? document.characterSet : document.charset);
	try {
		if(src) {
			scriptNode.src = src;
			scriptNode.onloadDone = false;
			scriptNode.onload = function () {
				scriptNode.onloadDone = true;
				JSLOADED[src] = 1;
			};
			scriptNode.onreadystatechange = function () {
				if((scriptNode.readyState == 'loaded' || scriptNode.readyState == 'complete') && !scriptNode.onloadDone) {
					scriptNode.onloadDone = true;
					JSLOADED[src] = 1;
				}
			};
		} else if(text){
			scriptNode.text = text;
		}
		document.getElementsByTagName('head')[0].appendChild(scriptNode);
	} catch(e) {}
}

function hash(string, length) {
	var length = length ? length : 32;
	var start = 0;
	var i = 0;
	var result = '';
	filllen = length - string.length % length;
	for(i = 0; i < filllen; i++){
		string += "0";
	}
	while(start < string.length) {
		result = stringxor(result, string.substr(start, length));
		start += length;
	}
	return result;
}

function stringxor(s1, s2) {
	var s = '';
	var hash = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var max = Math.max(s1.length, s2.length);
	for(var i=0; i<max; i++) {
		var k = s1.charCodeAt(i) ^ s2.charCodeAt(i);
		s += hash.charAt(k % 52);
	}
	return s;
}

/* IE6有个Bug，如果不给定对话框的宽度的话，在IE6下，对话框将以100%宽度显示 (如果指定了对话框加载内容的width，可以正常显示)*/
DialogManager = {
    'create' : function(id){
        var d = {};
        if (!__DIALOG_WRAPPER__[id]) {
            d = new Dialog(id);
            __DIALOG_WRAPPER__[id] = d;
        } else {
            d = DialogManager.get(id);
        }
        return d;
    },
    'get' : function(id){
        return __DIALOG_WRAPPER__[id];
    },
    'close' : function(id){
		if (__DIALOG_WRAPPER__[id]) {
			if (__DIALOG_WRAPPER__[id].close()) {
				__DIALOG_WRAPPER__[id] = null;
			}
			return true;
		} else {
			return false;
		}
    },
    'onClose' : function (){
        return true;
    },
	'setTitle' : function(id, title) {
		if (__DIALOG_WRAPPER__[id]) {
			__DIALOG_WRAPPER__[id].setTitle(title);
		}
	}
};

//锁屏
ScreenLocker = {
    'style' : {
        'position' : 'absolute',
        'top' : '0px',
        'left' : '0px',
        'backgroundColor' : '#333',
        'opacity' : 0.5,
		'overflow':'hidden',
        'z-index' : 999
    },
    'masker' : null,
    'lock' : function(zIndex){
        if (this.masker !== null) {
            this.masker.width($(document).width()).height($(document).height());
            return true;
        }
        this.masker = $('<div></div>');

        /* IE6 Hack */
        /*if ($.browser.msie) {
            $('select').css('visibility', 'hidden');
        }*/

        /* 样式 */
        this.masker.css(this.style);

        if (zIndex) {
            this.masker.css('zIndex', zIndex);
        }

        /* 整个文档的宽高 */
        this.masker.width($(document).width()).height($(document).height());

        $(document.body).append(this.masker);
    },
    'unlock' : function(){
        if (this.masker === null) {
            return true;
        }
        this.masker.remove();
        this.masker = null;

        /* IE6 Hack */
        /*if ($.browser.msie) {
            $('select').css('visibility', 'visible');
        }*/
    }
};

//拖动
function draggable(m, c)
{
	var MOUSEDOWN_FLG = false;
	var _x, _y;
	$(c).mousedown(function(event){
		MOUSEDOWN_FLG = true;
		var offset = $(m).offset();
		_x = event.pageX - offset.left;
		_y = event.pageY - offset.top;
		$(m).css({left:event.pageX-_x, top:event.pageY-_y});
	});
	
	$(document).mousemove(function(event){
		if(MOUSEDOWN_FLG){
			$(m).css({left:event.pageX-_x, top:event.pageY-_y});
		}
	}).mouseup(function(event){
		MOUSEDOWN_FLG=false;
	});
}

//对话框类
Dialog = function (id){
    /*生成基础对话框*/
    this.id = id;
    this.init();
};
Dialog.prototype = {
    /* 唯一标识 */
    'id' : null,
	/*是否有标题栏*/
	'noTitleBar':false,
    /* 文档对象 */
    'dom' : null,
    'lastPos' : null,
    'status' : 'complete',
    'onClose' : function (){
		/*可执行扩展该函数,拦截标准的对话框关闭函数*/
        return true;
    },
    'tmp' : {},
    /* 初始化 */
    'init' : function(){
        this.dom = {'wrapper' : null, 'body':null, 'head':null, 'title':null, 'close_button':null, 'content':null};

        /* 创建外层容器 */
        this.dom.wrapper = $('<div id="dialog_object_' + this.id + '" class="dialog_wrapper"></div>').get(0);

        /* 创建对话框主体 */
        this.dom.body = $('<div class="dialog_body"></div>').get(0);
		
		//使用自定义标题栏
		if (!this.noTitleBar) {
			/* 创建标题栏 */
			this.dom.head = $('<div class="dialog_head"></div>').get(0);
	
			/* 创建标题文本 */
			this.dom.titletxt = $('<span class="dialog_title_icon"></span>').get(0);
			this.dom.title = $('<div class="dialog_title"></div>').append(this.dom.titletxt);
	
			/* 创建关闭按钮 */
			this.dom.close_button = $('<span class="dialog_close_button">close</span>').get(0);
			
			/* 组合 */
			$(this.dom.head).append(this.dom.title).append(this.dom.close_button);
			$(this.dom.body).append(this.dom.head);
		}
		
		/* 创建内容区域 */
		this.dom.content = $('<div class="dialog_content"></div>').get(0);
		$(this.dom.body).append(this.dom.content);
        $(this.dom.wrapper).append(this.dom.body).append('<div style="clear:both;display:block;"></div>');

        /* 初始化样式 */
        $(this.dom.wrapper).css({
            'z-index' : 9999,
            'display' : 'none',
			'position' : 'absolute'
        });
        $(this.dom.body).css({
            'position' : 'relative'
        });
		
		if (!this.noTitleBar) {
			$(this.dom.head).css({
				'cursor' : 'auto'
			});
			$(this.dom.close_button).css({
				'position' : 'absolute',
				'text-indent' : '-9999px',
				'cursor' : 'pointer',
				'overflow' : 'hidden'
			});
		}
		
        $(this.dom.content).css({
            'margin' : '0px',
            'padding' : '0px'
        });

        var self = this;

		if (!this.noTitleBar) {
			/* 初始化组件事件 */
			$(this.dom.close_button).click(function(){
				DialogManager.close(self.id);
			});
	
			/* 可拖动 */
			draggable(this.dom.wrapper, this.dom.title);
		}

        /* 放入文档流 */
        $(document.body).append(this.dom.wrapper);
    },

    /* 隐藏 */
    'hide' : function(){
        $(this.dom.wrapper).hide();
    },

    /* 显示 */
    'show' : function(pos){
        if (pos) {
            this.setPosition(pos);
        }

        /* 锁定屏幕 */
		if (__ScreenLocker_HandleKey__ == null || __ScreenLocker_HandleKey__ == '') {
        	ScreenLocker.lock(999);
			__ScreenLocker_HandleKey__ = this.id;
		}

        /* 显示对话框 */
        $(this.dom.wrapper).show();
    },

    /* 关闭 */
    'close' : function(){
        if (!this.onClose()) {
            return false;
        }
        /* 关闭对话框 */
        $(this.dom.wrapper).remove();

        /* 解锁屏幕 */
		if (__ScreenLocker_HandleKey__ == this.id) {
        	ScreenLocker.unlock();
			__ScreenLocker_HandleKey__ = null;
		}

        return true;
    },

    /* 对话框标题 */
    'setTitle' : function(title){
        $(this.dom.titletxt).html(title);
    },

    /* 改变对话框内容 */
    'setContents' : function(type, options){
        contents = this.createContents(type, options);
        if (typeof(contents) == 'string') {
			contents = evalscript(contents);
            $(this.dom.content).html(contents);
        } else {
            $(this.dom.content).empty();
            $(this.dom.content).append(contents);
        }
    },

    /* 设置对话框样式 */
    'setStyle' : function(style){
        if (typeof(style) == 'object') {
            /* 否则为CSS */
            $(this.dom.wrapper).css(style);
        } else {
            /* 如果是字符串，则认为是样式名 */
            $(this.dom.wrapper).addClass(style);
        }
    },
    'setWidth' : function(width){
        this.setStyle({'width' : width + 'px'});
    },
    'setHeight' : function(height){
        this.setStyle({'height' : height + 'px'});
    },

    /**
	 * 生成对话框内容
	 * options = {
	 * 		'type'				消息通知类型
	 *		'text'				消息通知文字
	 *		'button_name'		按钮名称
	 *		'yes_button_name'	Yes按钮
	 *		'no_button_name'	No按钮
	 * }
	 */
    'createContents'  : function(type, options){
        var _html = '', self  = this, status= 'complete';
        if (!options) {
            /* 如果只有一个参数，则认为其传递的是HTML字符串 */
            this.setStatus(status);
            return type;
        }
        switch(type){
            case 'ajax':
                /* 通过Ajax取得HTML，显示到页面上*/
				var _ajax_url = options.url;
				var _ajaxResponse = function(data) {
					//窗口加载时候错误情况处理
					if (options.checkerror) {
						if (options.checkerror(data) == false) {
							return false;
						}
					}
                   	self.setContents(data);
                    
					/* 使用上次定位重新定位窗口位置 */
                    self.setPosition(self.lastPos);
				};
				if (options.post) {
					$.post(_ajax_url, options.post, function(data) {
						_ajaxResponse(data);
					});
				} else {
					$.get(_ajax_url, function(data) {
						_ajaxResponse(data);
					});
				}
                /* 先提示正在加载 */
                _html = this.createContents('loading', {'text' : 'loading...'});
            break;
            /* 内置对话框*/
            case 'loading':
				var _css = '';
				if (options.width) {
					_css = "width:"+options.width+"px";
				}
                _html = '<div class="dialog_loading" style="'+_css+'"><div class="dialog_loading_text">' + options.text + '</div></div>';
                status = 'loading';
            break;
            case 'message':
                var type = 'notice';
                if (options.type) {
                    type = options.type;
                }
                _message_body = $('<div class="dialog_message_body"></div>');
                _message_contents = $('<div class="dialog_message_contents dialog_message_' + type + '">' + options.text + '</div>');
                _buttons_bar = $('<div class="dialog_buttons_bar"></div>');
                switch (type){
                    case 'notice':
                    case 'warning':
                        var button_name = "Sure";
                        if (options.button_name) {
                            button_name = options.button_name;
                        }
                        _ok_button = $('<input type="button" class="btn1" value="' + button_name + '" />');
                        $(_ok_button).click(function(){
							if (options.close_first) {
								DialogManager.close(self.id);
							}
                            if (options.onclick) {
                                if(!options.onclick.call()) {
                                    return;
                                }
                            }
							if (!options.close_first) {
                            	DialogManager.close(self.id);
							}
                        });
                        $(_buttons_bar).append(_ok_button);
                    	break;
                    case 'confirm':
                        var yes_button_name = 'Yes';
                        var no_button_name = 'No';
                        if (options.yes_button_name) {
                            yes_button_name = options.yes_button_name;
                        }
                        if (options.no_button_name) {
                            no_button_name = options.no_button_name;
                        }
                        _yes_button = $('<input type="button" class="btn1" value="' + yes_button_name + '" />');
                        _no_button = $('<input type="button" class="btn2" value="' + no_button_name + '" />');
                        $(_yes_button).click(function(){
							DialogManager.close(self.id);						  
                            if (options.onClickYes) {
                                if (options.onClickYes.call() === false) {
                                    return;
                                }
                            }
                        });
                        $(_no_button).click(function(){
                            DialogManager.close(self.id);
                            if (options.onClickNo) {
                                if (!options.onClickNo.call()) {
                                    return;
                                }
                            }
                        });
                        $(_buttons_bar).append(_yes_button).append(_no_button);
                    break;
                }
                _html = $(_message_body).append(_message_contents).append(_buttons_bar);

            break;
        }
        this.setStatus(status);

        return _html;
    },
    /* 定位 */
    'setPosition'   : function(pos){
        /* 上次定位 */
        this.lastPos = pos;
        if (typeof(pos) == 'string')
        {
            switch(pos){
                case 'center':
                    var left = 0;
                    var top  = 0;
                    var dialog_width    = $(this.dom.wrapper).width();
                    var dialog_height   = $(this.dom.wrapper).height();
					
                    /* left=滚动条的宽度  + (当前可视区的宽度 - 对话框的宽度 ) / 2 */
                    left = $(window).scrollLeft() + ($(window).width() - dialog_width) / 2;

                    /* top =滚动条的高度  + (当前可视区的高度 - 对话框的高度 ) / 2 */
                    top  = $(window).scrollTop()  + ($(window).height() - dialog_height) / 2;
                    $(this.dom.wrapper).css({left:left + 'px', top:top + 'px'});
                break;
            }
        }
        else
        {
            var _pos = {};
            if (typeof(pos.left) != 'undefined') {
                _pos.left = pos.left;
            }
            if (typeof(pos.top)  != 'undefined') {
                _pos.top  = pos.top;
            }
            $(this.dom.wrapper).css(_pos);
        }

    },
    /* 设置状态 */
    'setStatus' : function(code){
        this.status = code;
    },
    /* 获取状态 */
    'getStatus' : function(){
        return this.status;
    },
    'disableClose' : function(msg){
        this.tmp['oldOnClose'] = this.onClose;
        this.onClose = function(){
            if(msg)alert(msg);
            return false;
        };
    },
    'enableClose'  : function(){
        this.onClose = this.tmp['oldOnClose'];
        this.tmp['oldOnClose'] = null;
    }
};

/**
 * 对话框
 * 
 * @param handle_key
 *            对话框的唯一标识，确保它的唯一性
 * @param module
 *            对话框的模式。 module='ajax'
 *            :需要设定options={url:'xxxx'},如果加入了post参数则使用post方式请求 module='local'
 *            :需要设定options={html:'xxxx'},对话框内直接显示options.html的值或者使用option.id对话框内会直接显示id中html内容
 *            module='message' :需要设定options中的type， 告警对话框type='warning'
 *            :需要设定options={type:'warning',button_name:'确定',text:'你没有权限进行当前操作',onclick:''}
 *            确认对话框type='confirm'
 *            :需要设定options={type:'warning',yes_button_name:'确定',no_button_name:'取消',
 *            text:'你确定要进行这项操作吗?'，onclick:''} module='loading'
 *            :需要设定options={text:'正在加载'}
 * @param width
 *            对话框宽。
 */
var __DialogHtml__ = new Array();
function showDialog(handle_key, module, title, options, width)
{
	if (!width) {
		width = 400;
	}
	Dialog.prototype.noTitleBar = !options.noTitleBar ? false : true;
	var handle = DialogManager.create(handle_key);
	if (!options.noTitleBar) {
		handle.setTitle(title);
	}
	if (module == 'local') {
		var html = '';
		if (isUndefined(__DialogHtml__[handle_key])) {
			if (options.html) {
				html = options.html;
			} else if (options.id) {
				html = $('#'+ options.id).html();
				$('#'+ options.id).html('');
			} else {
				html = '';
			}
			__DialogHtml__[handle_key] = html;
		} else {
			html = __DialogHtml__[handle_key];
		}
		handle.setContents(html);
	} else if (module == 'ajax') {
		if (!options.checkerror) {
			options.checkerror = function (data) {
				if (is_json(data)) {
					var json = eval('('+data.toString()+')');
					closeDialog(handle_key);
					MessageBox('warning', json.msg);
					return false;
				}
				return true;
			};
		}
		handle.setContents(module, options);
	} else {
		handle.setContents(module, options);
	}    	
	handle.setWidth(width);
	handle.show('center');
	return handle;
}

/**
 * 动态设置对话框的标题
 */
function setDialogTitle(handle_key, title)
{
	DialogManager.setTitle(handle_key, title);
}

/**
 * 关闭对话框
 */
function closeDialog(handle_key)
{
	return DialogManager.close(handle_key);
}

/**
 * 设置对话框关闭事件的侦听
 */
function setDialogOnCloseListener(handle_key, func, options)
{
	__DIALOG_WRAPPER__[handle_key].onClose = function() {
		if (options) {
			func(options);
		} else {
			func();
		}
		Dialog.prototype.onClose = function() {return true;};
		return true;
	};
}

/**
 * 消息提示框
 */
function MessageBox(type, msg, title, options)
{
	if (isUndefined(options)) {
		options = {};
	}
	
	if (type == 'notice') {
		handle_key = 'notice_dialog';
		clickEvent = null;
		close_first = false;
		if (options.onclick) {
			clickEvent = options.onclick;
		}
		if (options.close_first) {
			close_first = options.close_first;
		}
		param = {type:'notice',button_name:'确定',text:msg, onclick:clickEvent, close_first:close_first};
	} else if (type == 'warning') {
		handle_key = 'warning_dialog';
		clickEvent = null;
		close_first = false;
		if (options.onclick) {
			clickEvent = options.onclick;
		}
		if (options.close_first) {
			close_first = options.close_first;
		}
		param = {type:'warning',button_name:'确定',text:msg, onclick:clickEvent, close_first:close_first};
	} else if (type == 'confirm') {
		handle_key = 'confirm_dialog';
		var onClickYes = null;
		var onClickNo = null;
		if (options.onClickYes) {
			onClickYes = options.onClickYes;
		}
		if (options.onClickNo) {
			onClickNo = options.onClickNo;
		}		
		param = {type:'confirm',yes_button_name:'是',no_button_name:'否',text:msg,onClickYes:onClickYes,onClickNo:onClickNo};
	}
	if (!title || title == '') {
		title = '提示';
	}
	showDialog(handle_key, 'message', title, param, 300);
}

/**
 * 通过JS消息提示，在显示设定时间后隐藏
 * 
 * @param show_message
 *            提示的消息内容 如 “发布成功”；默认为空
 * @param show_time
 *            消息显示的时间，单位为秒；默认显示 “3” 秒
 * @param show_title
 *            提示的消息标题，默认为“提示”
 * @param tigBoxClass
 *            消息提示层所使用的样式，默认为“tigBox”
 */
function show_message(show_message,show_time,show_title,tigBoxClass)
{
	var show_message = (undefined==show_message ? '' : show_message);

	if(show_message)
	{
		var show_time = (undefined==show_time ? 1 : show_time);
		var show_title = (undefined==show_title ? '提示' : show_title);
		var tigBoxClass = (undefined==tigBoxClass ? 'tigBox' : tigBoxClass);

		var smaHTML = '<div id="tigBox" class="' + tigBoxClass + '"><ul class="warnBox"><li><div class="tt1">' + show_title + '</div><div class="wWarp"><div class="wwsp">' + show_message + '</div></div></li></ul></div>';
		$('#show_message_area').html(smaHTML);

		var tigBoxObj = document.getElementById("tigBox");

		tigBoxObj.style.visibility = "visible";
		
		var i=0;

		setTimeout(function() {
			i += 1;
			tigBoxObj.style.visibility= "hidden";
		},(show_time * 1000));
	}
}

//包含确定框
function show_message_2(show_message,show_title,tigBoxClass)
{
	var show_message = (undefined==show_message ? '' : show_message);

	if(show_message)
	{
		var show_title = (undefined==show_title ? '提示' : show_title);
		var tigBoxClass = (undefined==tigBoxClass ? 'tigBox' : tigBoxClass);

		var smaHTML = '<div id="tigBox" class="' + tigBoxClass + '">'+
						'<ul class="warnBox"><li><div class="tt1">' + show_title + '</div><div class="wWarp"><div class="wwsp">' + show_message + '</div></div>'+
						'<div id="qr" class="bt_qr">确认</div></li></ul></div>';
		$('#show_message_area').html(smaHTML);

		var tigBoxObj = document.getElementById("tigBox");

		tigBoxObj.style.visibility = "visible";
		$('#qr').click(function(){tigBoxObj.style.visibility= "hidden";});
	}
}