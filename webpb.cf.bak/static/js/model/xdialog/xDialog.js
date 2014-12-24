/**
 * @name: xDialog
 * @overview: xDialog是一个JQuery弹出层插件，它拥有简单的界面和友好的接口，压缩后大小仅2K左右。
 * @require: xDialog.css
 * @author: 简(haichong0813@gmail.com)
 */

;(function($){
    var isExist = true; //防止重复弹窗
    $.xDialog = function(){

        //默认参数
        var defaults = {
            width:'auto',            //宽度
            height:'auto',           //高度
            title:"",                //标题
            content:"",              //内容
            opacity:0.5,             //遮罩层透明度
            show:true,               //是否立即显示弹出层
            ok:null,                 //确定按钮回调函数，函数如果返回false将阻止弹出层关闭
            cancel:true,             //取消按钮回调函数，如果为true，调用默认关闭事件，函数如果返回false将阻止弹出层关闭
            overlayClose:false,       //点击遮罩层是否可以关闭
            overlayColor:'#FFFFFF',  //遮罩层颜色
            type:null,               //消息类型：tips，配合time参数使用
            time:1.5,                //多少秒后关闭弹出层，配合type参数使用
            closeBtn:true            //是否显示右上角关闭按钮
        };

        var plugin = this,//避免this混乱
        $element = $(element),//jquery对象
        element = element;//原生对象
        plugin.settings = {};//参数集合
        options = arguments[0];//获取参数

        //初始化
        plugin.init = function(){
            //判断弹窗是否存在
            if(!isExist){
                return;
            }
            isExist = false;

            plugin.settings  = $.extend({},defaults,options);//合并参数
            plugin.create();
            return this;
        };

        //创建弹出层
        plugin.create = function(){

            //初始化弹窗HTML结构
            this.dialog = $('<div>',{'class':"popup fixed"});

            //判断弹窗类型
            if(this.settings.type && this.settings.type == 'tips'){
                $('<div>',{'class':'popup-main clear'}).appendTo(this.dialog);
                this.settings.opacity = false;
            }else{
                this.header = $('<div>',{'class':'popup-header clear'});

                //加入头部
                if(this.settings.title || this.settings.closeBtn){
                    this.header.appendTo(this.dialog);

                    //加入标题
                    if(this.settings.title){
                        $('<span>',{'class':'x-title'}).html(this.settings.title).appendTo(this.header);
                    }
                   
                    //加入右上角关闭按钮
                    if(this.settings.closeBtn){
                        $('<a>',{'class':'fr x-close'}).html('X').appendTo(this.header);
                    }
                }
               
                //加入内容
                $('<div>',{'class':'popup-main pd20'}).appendTo(this.dialog);
                
                //加入确定取消按钮
                if(this.settings.ok && typeof this.settings.ok == 'function'){
                    $('<div>',{'class':'popup-footer clear'}).html('<div><a class=\"btn btn-danger x-ok\" href=\"javascript:;\">确定<\/a>&nbsp;&nbsp;<a href=\"javascript:;\" class=\"btn x-cancel\">取消<\/a><br/><br/><br/><br/></div>').appendTo(this.dialog);
                }
            }

            this.setContent(this.settings.content);//设置内容
            this.dialog.appendTo('body');

            //初始化遮罩层
            if (plugin.settings.opacity){
                if(!plugin.overlay){
                    var view = getViewSize();
                    plugin.overlay = jQuery('<div>', {
                        'class':'x-overlay'
                    }).css({
                        'background-color': plugin.settings.overlayColor,
                        'position': 'absolute',
                        'width':    view.width,
                        'height':   view.height,
                        'left':     0,                                     
                        'top':      0,                               
                        'opacity':  plugin.settings.opacity,      
                        'z-index':  1000,
                        'cursor': 'pointer'                            
                    });

                    //判断点击遮罩层是否可以关闭
                    if(plugin.settings.overlayClose){
                         plugin.overlay.bind('click', function() {plugin.close();});
                    }
                    plugin.overlay.appendTo('body');
                }else{
                    plugin.overlay.show();
                }
            }

            //显示弹出层
            if(this.settings.show){
                this.open();
            }

            //绑定按钮
            $.each(['ok','cancel','close'],function(index, value){
                plugin.dialog.find('.x-' + value).bind('click',function(){
                    if(typeof plugin.settings[value] == 'function'){
                        if(plugin.settings[value]() === false){
                            return false;
                        }
                    }
                    plugin.close();
                });
            });
        };

        //设置位置
        plugin.setPos = function(){
            var width = (this.settings.width == 'auto') ? this.dialog.outerWidth() : this.settings.width,
            height = (this.settings.height == 'auto') ? this.dialog.outerHeight() : this.settings.height,
            left = -(width / 2), top = -(height / 2);

            plugin.dialog.css({
                'margin-top': top,
                'margin-left': left,
                'width': width,
                'height': height
            });
        };

        //设置标题
        plugin.setTitle = function(title){
            var _title = plugin.dialog.find('.x-title');
            //判断标题节点是否存在
            if(_title.length > 0){
                 _title.html(title);
            }else{
                $('<span>',{'class':'x-title'}).html(title).appendTo(plugin.header);
            }
            return this;
        };

        //设置内容
        plugin.setContent = function(obj){
            //判断内容类型
            if(typeof obj != 'string'){
                obj = (obj instanceof jQuery) ? obj[0] : obj;
                obj = obj.cloneNode(true);
                obj.style.display = 'block';
            }
            plugin.dialog.find('.popup-main').append(obj);
            return this;
        };

        //打开弹出层
        plugin.open = function(){
            this.setPos();//重置样式
            plugin.dialog.fadeIn(300);//显示弹出层
           
            //判断弹出层类型
            if(this.settings.type === 'tips' && this.settings.time){
                setTimeout(function(){
                    plugin.close();
                    isExist = true;
                },this.settings.time * 1000);
            }
        };

        //关闭弹出层
        plugin.close = function(){
            plugin.dialog.remove();
            if(this.overlay) this.overlay.hide();
            isExist = true;
        };

        //私有方法：获取文档大小
        var getViewSize = function(){
            //判断文档模式
            if (document.compatMode == "BackCompat"){
                this.width = document.body.clientWidth;
                if(document.body.scrollHeight > document.body.clientHeight){
                    this.height = document.body.scrollHeight;
                }else{
                    this.height = document.body.clientHeight;
                }
            }else{
                this.width = document.documentElement.clientWidth;
                if(document.documentElement.scrollHeight > document.documentElement.clientHeight){
                    this.height = document.documentElement.scrollHeight;
                }else{
                    this.height = document.documentElement.clientHeight;
                } 
            }
            return {width:this.width,height:this.height};
        };
        return plugin.init();
    };
})(jQuery);
