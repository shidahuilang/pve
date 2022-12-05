    <style>
    /* 头像圆角 */
    .header-left .hope-image {
        border-radius: 50px !important;
    }

    /* 导航样式 */
    .nav {
        border-radius: 10px !important;
        padding: 3px 10px;
    }

    /* 主体框架 */
    .body {
        min-height: 0% !important;
    }

    /* 隐藏底部信息 */
    .footer {
        display: none !important;
    }

    /* 底部盒子 */
    .footer-box {
        /* color: blueviolet; */
        border-radius: 10px !important;
        text-align: center !important;
        padding: 10px;
    }

    /* 底部框架 */
    .footer-body {
        font-size: 13px !important;
    }

    /* 隐藏登录logo */
    .hope-center .hope-stack .hope-flex .hope-image {
        display: none !important;
    }

    /* ------------------白天模式------------------ */

    /* 背景图片 */
    .hope-ui-light {
        /* 
            樱花：https://www.dmoe.cc
            夏沫：https://cdn.seovx.com
            搏天：https://api.btstu.cn/doc/sjbz.php
            姬长信：https://github.com/insoxin/API
            小歪：https://www.ixiaowai.cn/#works
            保罗：https://api.paugram.com
            墨天逸：https://api.mtyqx.cn
            岁月小筑：https://img.xjh.me
            东方Project：https://img.paulzzh.com
        */
        background-image: url("http://www.pp3.cn/uploads/allimg/120204/1-120204103H5.jpg") !important;
        background-color: rgb(58, 58, 58) !important;
        background-repeat: no-repeat;
        background-size: cover;
        background-attachment: fixed;
        background-position-x: center;
    }

    /* 设置半透明 */
    .hope-ui-light .header-left .hope-image,
    .hope-ui-light .header-right .hope-button,
    .hope-ui-light .left-toolbar,
    .hope-ui-light .nav,
    .hope-ui-light .obj-box,
    .hope-ui-light .hope-c-PJLV-ikSuVsl-css,
    .hope-ui-light .footer-box {
        background-color: rgba(255, 255, 255, .8) !important;
        box-shadow: 0 0 15px 1px rgb(124, 124, 124) !important;
    }

    /* ------------------夜间模式------------------ */

    /* 设置半透明 */
    .hope-ui-dark .header-left .hope-image,
    .hope-ui-dark .header-right .hope-button,
    .hope-ui-dark .left-toolbar,
    .hope-ui-dark .nav,
    .hope-ui-dark .obj-box,
    .hope-ui-dark .hope-c-PJLV-iiuDLME-css,
    .hope-ui-dark .footer-box {
        background-color: rgba(32, 36, 37, 1) !important;
        box-shadow: 0 0 15px 1px #000 !important;
    }
</style>
<link href="//lib.baomitu.com/font-awesome/6.1.2/css/all.css" rel="stylesheet">
<script src="//lib.baomitu.com/jquery/3.3.1/jquery.min.js" charset="utf-8"></script> <!-- 1.12.4 -->
<script src="https://polyfill.io/v3/polyfill.min.js?features=String.prototype.replaceAll"></script>
    <meta charset="utf-8" >
    <meta name="viewport" content="width=device-width, initial-scale=1" >
    <meta name="referrer" content="same-origin" >
    <meta name="generator" content="AList V3" >
    <meta name="theme-color" content="#000000" >
    <meta name="google" content="notranslate" >
    <script       src="https://g.alicdn.com/IMM/office-js/1.1.5/aliyun-web-office-sdk.min.js"
      async
    ></script>
 
    
    <script type="module">try{import.meta.url;import("_").catch(()=>1);}catch(e){}window.__vite_is_modern_browser=true;</script>
    <script type="module">!function(){if(window.__vite_is_modern_browser)return;console.warn("vite: loading legacy build because dynamic import or import.meta.url is unsupported, syntax error above should be ignored");var e=document.getElementById("vite-legacy-polyfill"),n=document.createElement("script");n.src= window.__dynamic_base__+e.getAttribute('data-src'),n.onload=function(){System.import( window.__dynamic_base__+document.getElementById('vite-legacy-entry').getAttribute('data-src'))},document.body.appendChild(n)}();</script>
    <script>
(function(){
var preloads = [{"parentTagName":"head","tagName":"script","attrs":{"type":"module","crossorigin":"","src":"/assets/index.a4a6b1e7.js"}},{"parentTagName":"head","tagName":"link","attrs":{"rel":"stylesheet","href":"/assets/index.659f4289.css"}}];
function setAttribute(target, attrs) {
for (var key in attrs) {
  target.setAttribute(key, attrs[key]);
}
return target;
};
for(var i = 0; i < preloads.length; i++){
var item = preloads[i]
var childNode = document.createElement(item.tagName);
setAttribute(childNode, item.attrs)
if( window.__dynamic_base__) {
  if(item.tagName == 'link') {
    setAttribute(childNode, { href:  window.__dynamic_base__ + item.attrs.href })
  } else if (item.tagName == 'script') {
    setAttribute(childNode, { src:  window.__dynamic_base__ + item.attrs.src })
  }
}
document.getElementsByTagName(item.parentTagName)[0].appendChild(childNode);
}
})();
</script>
</head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>

    
    <div id="root">
    <div class="footer-new hope-c-PJLV hope-c-PJLV-iicyfOA-css" style="display:none;">
        <div class="body hope-c-PJLV hope-c-PJLV-iiHckfM-css">
            <div class="footer-box hope-c-PJLV hope-c-PJLV-ikgiLXI-css">
                <div class="hope-c-PJLV hope-c-PJLV-ihXHbZX-css">
                    <div class="footer-body">
                        
                        <!-- <br> -->
                        <strong><span class="fas fa-layer-group"></span> 本站已稳定运行：</strong>
                        <strong id="day_show">载入中...</strong>
                        <br>
                        <strong>
                            <span class="fas fa-copyright"></span>
                            <a href="/@manage" target="_blank" rel="noopener noreferrer">大灰狼</a>
                            <span>|</span>
                            <span class="fab fa-github"></span>
                            <!-- 注意：如需修改，请保留作者版权信息 -->
                            <a href="https://www.github.com/shidahuilang" target="_blank"
                                rel="noopener noreferrer">GitHub</a>
                            <span>|</span>
                            <span class="fas fa-shield-alt"></span>

                        </strong>
                        <br>
                        <strong><span class="fas fa-clock"></span> 当前时辰:</strong>
                        <strong id="time_show">载入中...</strong>
                        <span>|</span>
                        <strong><span class="fas fa-heart"></span> 页面载入耗时:</strong>
                        <strong id="load_show">载入中...</strong>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- 空白高度块 -->
<div style="height: 18px;"></div>


<!-- 页面加载相关 -->
<script>
    var start = new Date().getTime();
    function timestamp() {
        let outcome = Math.round(new Date().getTime() / 1000).toString();
        return outcome
    }
    function timer(intDiff) {
        myTimer = window.setInterval(function () {
            var day = 0,
                hour = 0,
                minute = 0,
                second = 0;//时间默认值
            if (intDiff > 0) {
                day = Math.floor(intDiff / (60 * 60 * 24));
                hour = Math.floor(intDiff / (60 * 60)) - (day * 24);
                minute = Math.floor(intDiff / 60) - (day * 24 * 60) - (hour * 60);
                second = Math.floor(intDiff) - (day * 24 * 60 * 60) - (hour * 60 * 60) - (minute * 60);
            }
            if (hour <= 9) hour = "0" + hour;
            if (minute <= 9) minute = "0" + minute;
            if (second <= 9) second = "0" + second;

            $('#day_show').html(day + '天 ' + hour + '时 ' + minute + '分 ' + second + '秒');

            var now = new Date();
            var year = now.getFullYear();   // 得到年份
            var month = now.getMonth();     // 得到月份
            var date = now.getDate();       // 得到日期
            var day = now.getDay();         // 得到周几
            var hour = now.getHours();      // 得到小时
            var minu = now.getMinutes();    // 得到分钟
            var sec = now.getSeconds();     // 得到秒钟

            if (hour > 0 && hour <= 2) text = "丑时";
            else if (hour > 2 && hour <= 4) text = "寅时";
            else if (hour > 4 && hour <= 6) text = "卯时";
            else if (hour > 6 && hour <= 8) text = "辰时";
            else if (hour > 8 && hour <= 10) text = "巳时";
            else if (hour > 10 && hour <= 12) text = "午时";
            else if (hour > 12 && hour <= 14) text = "未时";
            else if (hour > 14 && hour <= 16) text = "申时";
            else if (hour > 16 && hour <= 18) text = "酉时";
            else if (hour > 18 && hour <= 20) text = "戌时";
            else if (hour > 20 && hour <= 22) text = "亥时";
            else text = "子时";
            $('#time_show').html('<a href="https://www.beijing-time.org/shichen" target="_blank" rel="noopener noreferrer">' + text + '</a>');

            intDiff++;
        }, 1000);
    }
    var nowtime = timestamp(); // 现行时间戳
    var mytime = 1665140000; // 设置安装时间（安装日期时间戳）
    timer(nowtime - mytime); // 启动循环

    // 页面加载完成后执行
    $(function () {
        // $('.footer-new').hide(); // 隐藏底部
        $('.footer-new').show(); // 显示底部
        $('#load_show').html((new Date().getTime() - start) + 'ms');
    });
</script>

<!--鼠标点击出随机颜色的爱心-->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
 
<body>
    <!-- 网页鼠标点击特效（爱心） -->
    <script type="text/javascript">
         ! function (e, t, a) {
            function r() {
                for (var e = 0; e < s.length; e++) s[e].alpha <= 0 ? (t.body.removeChild(s[e].el), s.splice(e, 1)) : (s[
                        e].y--, s[e].scale += .004, s[e].alpha -= .013, s[e].el.style.cssText = "left:" + s[e].x +
                    "px;top:" + s[e].y + "px;opacity:" + s[e].alpha + ";transform:scale(" + s[e].scale + "," + s[e]
                    .scale + ") rotate(45deg);background:" + s[e].color + ";z-index:99999");
                requestAnimationFrame(r)
            }
            function n() {
                var t = "function" == typeof e.onclick && e.onclick;
                e.onclick = function (e) {
                    t && t(), o(e)
                }
            }
 
            function o(e) {
                var a = t.createElement("div");
                a.className = "heart", s.push({
                    el: a,
                    x: e.clientX - 5,
                    y: e.clientY - 5,
                    scale: 1,
                    alpha: 1,
                    color: c()
                }), t.body.appendChild(a)
            }
 
            function i(e) {
                var a = t.createElement("style");
                a.type = "text/css";
                try {
                    a.appendChild(t.createTextNode(e))
                } catch (t) {
                    a.styleSheet.cssText = e
                }
                t.getElementsByTagName("head")[0].appendChild(a)
            }
 
            function c() {
                return "rgb(" + ~~(255 * Math.random()) + "," + ~~(255 * Math.random()) + "," + ~~(255 * Math
                    .random()) + ")"
            }
            var s = [];
            e.requestAnimationFrame = e.requestAnimationFrame || e.webkitRequestAnimationFrame || e
                .mozRequestAnimationFrame || e.oRequestAnimationFrame || e.msRequestAnimationFrame || function (e) {
                    setTimeout(e, 1e3 / 60)
                }, i(
                    ".heart{width: 10px;height: 10px;position: fixed;background: #f00;transform: rotate(45deg);-webkit-transform: rotate(45deg);-moz-transform: rotate(45deg);}.heart:after,.heart:before{content: '';width: inherit;height: inherit;background: inherit;border-radius: 50%;-webkit-border-radius: 50%;-moz-border-radius: 50%;position: fixed;}.heart:after{top: -5px;}.heart:before{left: -5px;}"
                ), n(), r()
        }(window, document);
    </script>   
