//选项卡切换
function setTab(name,cursel,n){
                for(i=1;i<=n;i++){
                var menu=document.getElementById(name+i);
                var con=document.getElementById("con_"+name+"_"+i);
                menu.className=i==cursel?"active":"";
                con.style.display=i==cursel?"block":"none";
                }
                }

$(document).ready(function(){
    $(".searchListS li").click(function(event){  
        if($(".wrapSelectListS").height()<25){         
            $(".wrapSelectListS").animate({height:"200px"},10);
            $(".wrapSelectListS").css({"width":"66px"});
            $(".searchListS").css({"border":"1px solid #ddd","margin-left":"0","margin-top":"-1px"});
            event.stopPropagation();
        }
        else{
            $(".wrapSelectListS").animate({height:"24px"},10);
            $(".searchListS i").remove();
            $(".searchListS li:first-child").html($(this).html()).append('<i class="selectAll"></i>');
            $(".wrapSelectListS").css({"width":"64px"});
            $(".searchListS").css({"border":"none","margin-left":"1px","margin-top":"0px"});
        }
    });
    $(".searchListS").mouseleave(function(){
        $(".wrapSelectListS").animate({height:"24px"},10);
        $(".wrapSelectListS").css({"width":"64px"});
        $(".searchListS").css({"border":"none","margin-left":"1px","margin-top":"0px"});
    });

    // 小搜索hover上去
    $(".searchListS li:not(':first')").mouseenter(function(){ $(this).css({"background-color":"#e83b3b","color":"#FFF"})})
    $(".searchListS li:not(':first')").mouseleave(function(){ $(this).css({"background-color":"#fff","color":"#000"})})
    // 搜索传值
    $(".searchListS li").click(function(){    
        var typeValue=$(this).attr("valueSelect");
        $(".searchHidden").val(typeValue);
    });
    
    // 大搜索展开
    $(".searchListB li").click(function(event){
        if ($(".wrapSelectListB").css('overflow')=='visible') {
            $(".searchListB i").remove();
            $(".searchListB li:last-child").html($(this).html()).append('<i class="selectAll"></i>');
            $("body").click(function(){$(".wrapSelectListB").css({"overflow":"hidden"}); $(".searchListB").css({"border":"none"});});
            $(".wrapSelectListB").css({"overflow":"hidden"});
            $(".searchListB").css({"border":"none"});
        }
        else{
            $(".wrapSelectListB").css({"overflow":"visible"});
            event.stopPropagation();
            $(".searchListB").css({"border":"1px solid #ddd"});
        }
    });

    // 大搜索hover上去
    $(".searchListB li:not(':last')").mouseenter(function(){ $(this).css({"background-color":"#e83b3b","color":"#FFF"})})
    $(".searchListB li:not(':last')").mouseleave(function(){ $(this).css({"background-color":"#fff","color":"#000"})})

    $(".searchListB li").click(function(){
        var typeValue=$(this).attr("valueSelect");
        $(".searchHidden").val(typeValue);
    });
});



//模拟下拉菜单
$(document).ready(function(){
        $(".btn-select").click(function(event){   
                event.stopPropagation();
                $(this).find(".option").toggle();
                $(this).parent().siblings().find(".option").hide();
        });
        $(document).click(function(event){
                var eo=$(event.target);
                if($(".btn-select").is(":visible") && eo.attr("class")!="option" && !eo.parent(".option").length)
                $('.option').hide();									  
        });
        /*赋值给文本框*/
        $(".option a").click(function(){
                var value=$(this).text();
                $(this).parent().siblings(".select-txt").text(value);
                $("#select_value").val(value)
         });
         
         // Store variables
        var accordion_head = $('.accordion > li > a'),
                accordion_body = $('.accordion li > .sub-menu');
        // Open the first tab on load
        accordion_head.first().addClass('active').next().slideDown('normal');
        // Click function
        accordion_head.on('click', function(event) {
                // Disable header links
                event.preventDefault();
                // Show and hide the tabs on click
                if ($(this).attr('class') != 'active'){
                        accordion_body.slideUp('normal');
                        $(this).next().stop(true,true).slideToggle('normal');
                        accordion_head.removeClass('active');
                        $(this).addClass('active');
                }
        });
})
//媒体-轮播图片

jQuery(document).ready(function() {	
		function depois() {
			if(/msie/.test(navigator.userAgent.toLowerCase()))
			{
			  
			}
			else
			{
			  jQuery('.focus ul li .imagem').stop().animate({"opacity":1,"marginTop":0},{
				speed:"fast",
				complete:function(){
					jQuery('.focus ul li .imagem1').stop().animate({"opacity":1,"marginLeft":0},{
						complete:function(){
							jQuery('.focus ul li .imagem2').stop().animate({"opacity":1,"marginLeft":0});
						}
					})
					jQuery('.focus ul li .botao-link').stop().animate({"opacity":1,"marginLeft":0});
				}
			  });
			}
			// jQuery('.focus ul li h3').stop().animate({"marginLeft":0,"opacity":1});
			// jQuery('.focus ul li .checklist').stop().animate({"marginLeft":0, "opacity":1});
			
		}
		
		function antes() {
			if(/msie/.test(navigator.userAgent.toLowerCase()))
			{
			  	
			}
			else
			{
			  jQuery('.focus ul li .imagem').stop().animate({"marginTop":40+"px","opacity":0});
			  jQuery('.focus ul li .imagem1').stop().animate({"marginLeft":"-"+40+"px","opacity":0});
			  jQuery('.focus ul li .imagem2').stop().animate({"marginLeft":"-"+40+"px","opacity":0});
			  jQuery('.focus ul li .botao-link').stop().animate({"marginLeft":"-"+60+"px", "opacity":0});	
			}	
			// jQuery('.focus ul li .checklist').stop().animate({"marginLeft":"+"+40+"px", "opacity":0});
		}
	jQuery('.focus ul').cycle({ 
		sync:	false,
		fx:     'fade', 
		speed:  1000, 
		timeout: 4000, 
		pager:  '.guia .itens',
		prev:	'',
		next:	'',
		before:	antes,
		after:	depois
	});
	jQuery('.focus .guia .itens a').eq(0).addClass('eval');
	jQuery('.focus .guia .itens a').eq(1).addClass('azul');
	jQuery('.focus .guia .itens a').eq(2).addClass('verde');
	
	var setas = jQuery('.focus ul li.azul .use-as-setas');
	var tempo = 300;
	setas.fadeOut(0);
	
	jQuery('.focus .guia .itens').hover(function(){		
		setas.fadeIn(tempo);
	},function(){
		setas.fadeOut(tempo);
	});
	
	jQuery(window).resize(function(){
		var largura = jQuery(window).width();
		jQuery('.focus ul > li').css({"width":largura}, 100);
	});

});




