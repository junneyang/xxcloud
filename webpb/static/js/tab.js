//header下拉菜单效果
(function(){
    $('#js-header').on('mouseenter', '.js-header-dropmenu', function(){
        $(this).find('.js-header-list').slideDown('fast');
    }).on('mouseleave', '.js-header-dropmenu', function(){
        $(this).find('.js-header-list').slideUp('fast');
    })
})();

//左侧梳妆菜单展开收起效果
(function(){
    $('#js-aside').on('click', '.mala-subnavi-lead', function(){
        var target = $(this),
            arrow = target.find('.mala-arrow'),
            is_up = arrow.hasClass('mala-arrow-up'),
            list = target.siblings('.mala-thirdnavi-list');
        if(is_up){
            arrow.removeClass('mala-arrow-up').addClass('mala-arrow-down');
            list.slideUp();
        }else{
            arrow.removeClass('mala-arrow-down').addClass('mala-arrow-up');
            list.slideDown();
        }
    });
})();

//收起/展开左侧菜单
(function(){
    $('.mala-aside-opt').on('click', 'a', function(){
        var target = $(this),
            aside = $('.mala-aside'),
            content = $('.mala-content');
        if(target.attr('id') == 'mala-aside-hide'){
            content.animate({
                left: 0
            }, 50);
            aside.hide();
        }else{
            content.animate({
                left: 180
            }, 50);
            aside.show();
        }
        target.hide();
        target.siblings().show();
    });
})();

//模拟下拉菜单
(function(){
    $('body').on('click', '.js-fake-select', function(){                //js-fake-select上的点击事件
        var target = $(this),
            list = target.siblings('.js-list'),
            height = list.find('.js-select-item').length * 35,
            is_show = target.hasClass('js-show');                       
        if(is_show){                                                    //如果存在js-show表示点击后展开了，此次点击收起下来内容
            target.removeClass('js-show');                              //去掉js-show�?
            list.animate({                                              //高度减少，收起下拉内�?
                height: 0
            }, 50);
        }else{                                                          //如果不存在js-show表示之前没点击过，此次点击展示起下来内容
            target.addClass('js-show');                                 //增加js-show�?
            list.animate({                                              //高度增加，展示起下拉内容
                height: height
            }, 50);
        }
    });
    $('body').on('click', '.js-select-item', function(){                //js-select-item控制下来的每�?
        var target = $(this),
            list = target.parent(),                                     //父类为js-fake-select   
            height = list.find('.js-select-item').length * 35,
            title = list.siblings('.js-fake-select');
        title.text(target.text()).removeClass('js-show');               //选中一项后，下拉单应该收起，所以这里从js-fake-select去掉js-show类，并且把js-fake-select上的title改为此项的title
        target.addClass('active').siblings().removeClass('active');     //选中的项添加fue-active,它的兄弟类去掉fue-active
        list.animate({
            height: 0
        }, 50);
    });
    $('html').on('click', function(e){
        var target = $(e.target),
            closest = target.closest('.mala-fake-select');              //在页面点击时候，找到点击的元素中最近的fue-fake-select
        if(!closest.length){                                            //如果没找到，就是不在fue-fake-select下的元素点击
            $('.js-fake-select.js-show').trigger('click');              //那么就把下拉菜单收起来，操作等同于点击js-fake-select下的选中�?
        }
    });
})();