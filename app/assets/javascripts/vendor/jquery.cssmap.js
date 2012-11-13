/*
 * CSSMap plugin
 * version: 4.4
 * web: http://cssmapsplugin.com
 * email: support@cssmapsplugin.com
 * author: Łukasz Popardowski { Winston_Wolf }
 * license: http://cssmapsplugin.com/license
 */
(function (a) {
  a.fn.cssMap = function (h) {
    var g = {
      size: "850",
      tooltips: true,
      tooltipArrowHeight: 5,
      cities: false,
      visibleList: false,
      loadingText: "Loading ...",
      multipleClick: false,
      searchUrl: "search.php",
      searchLink: "Search",
      searchLinkVar: "region",
      searchLinkSeparator: "|",
      clicksLimit: 0,
      clicksLimitAlert: "You can select only %d region! || regions!",
      agentsListId: "",
      agentsListSpeed: 0,
      agentsListOnHover: false,
      onHover: function (d) {},
      onClick: function (d) {},
      onLoad: function (d) {}
    };
    if (h) {
      var c = a.extend(true, g, h),
        f = a(window).width(),
        b = a(window).height();
      a(window).resize(function () {
        f = a(window).width();
        b = a(window).height()
      });
      return this.each(function (m) {
        if (!a(this).attr("id")) {
          a(this).attr("id", "css-map" + (m + 1))
        }
        var j = "#" + a(this).attr("id"),
          d = a(j).find("ul").eq(0),
          i = a(d).attr("class"),
          q = a(d).find("li"),
          l = 0,
          p = false,
          k = "",
          r = "",
          o = c.tooltips.toString(),
          n = {
            init: function () {
              n.clearMap();
              a(j).addClass("css-map-container m" + c.size);
              var s = d.css("background-image").replace(/^url\("?([^\"\))]+)"?\)$/i, "$1");
              this.loader(s)
            },
            loader: function (u) {
              var t = new Image(),
                s = a("<span />", {
                  "class": "map-loader",
                  text: c.loadingText
                }).appendTo(a(j));
              s.css({
                left: a(j).outerWidth() / 2,
                "margin-left": s.outerWidth() / -2,
                "margin-top": s.outerHeight() / -2,
                top: a(j).outerHeight() / 2
              });
              a(j).addClass("m" + c.size);
              a(d).addClass("css-map");
              a(c.agentsListId).find("li").hide();
              a(t).load(function () {
                if (a.browser.msie && parseInt(a.browser.version) <= 7) {
                  var v = true
                }
                if (c.cities && !v) {
                  a(j).append('<span class="cities ' + i + '-cities" />')
                }
                if (v) {
                  a(j).addClass("ie")
                }
                n.regions.init();
                if (a(c.agentsListId).length) {
                  n.agentslist.init()
                }
                if (c.multipleClick) {
                  n.searchButton()
                }
                s.fadeOut("slow");
                c.onLoad(a(j))
              }).error(function () {
                s.fadeOut();
                a(d).removeClass()
              }).attr("src", u)
            },
            regions: {
              init: function () {
                var s = n.regions;
                s.hideTooltips();
                q.each(function () {
                  var v = a(this),
                    w = v.attr("class").split(" ")[0],
                    x = v.children("a").eq(0),
                    u = a(x).attr("href");
                  if (typeof u == "undefined" || u.length < 2) {
                    a(v).remove()
                  }
                  s.copyList(a(v), w, x, u);
                  s.createSpans(a(v), w);
                  n.selectRegion.init(a(v), w, x)
                });
                if (c.visibleList) {
                  s.createList(k);
                  n.selectRegion.initVisibleList()
                }
                s.autoSelectRegion()
              },
              createSpans: function (u, w) {
                var t = '<span class="m">',
                  x = [],
                  B = "",
                  y = u.children("a"),
                  z = a('<span class="tooltip-arrow" />').appendTo(y);
                switch (i) {
                  case "argentina":
                    B = "ar";
                    x = [3, 18, 18, 17, 12, 17, 15, 14, 21, 13, 12, 17, 18, 8, 19, 22, 22, 17, 11, 20, 20, 12, 10, 9, 2];
                    break;
                  case "australia":
                    B = "au";
                    x = [3, 21, 5, 15, 8, 6, 15, 13];
                    break;
                  case "austria":
                  case "osterreich":
                    B = "at";
                    x = [15, 18, 30, 25, 24, 28, 22, 8, 4];
                    break;
                  case "belgium":
                    B = "be";
                    x = [13, 6, 19, 28, 25, 29, 22, 29, 24, 16, 23];
                    break;
                  case "brazil":
                  case "brasil":
                    B = "br";
                    x = [12, 8, 11, 34, 28, 13, 3, 5, 22, 19, 23, 18, 30, 34, 9, 11, 19, 17, 9, 10, 15, 13, 14, 12, 21, 6, 23];
                    break;
                  case "canada":
                    B = "ca";
                    x = [8, 11, 10, 3, 19, 20, 6, 31, 17, 2, 21, 3, 12];
                    break;
                  case "chile":
                    B = "cl";
                    x = [11, 4, 10, 13, 9, 8, 12, 7, 9, 7, 20, 7, 11, 7, 9];
                    break;
                  case "colombia":
                    B = "co";
                    x = [22, 30, 8, 5, 6, 21, 21, 11, 30, 18, 23, 13, 23, 12, 17, 18, 16, 18, 11, 14, 23, 15, 12, 15, 5, 6, 2, 16, 11, 13, 14, 21, 14];
                    break;
                  case "continents":
                    B = "c";
                    x = [12, 23, 11, 18, 21, 10, 3];
                    break;
                  case "cuba":
                    B = "cu";
                    x = [8, 20, 18, 7, 12, 10, 4, 16, 9, 12, 11, 5, 14, 15, 11, 15];
                    break;
                  case "czech-republic":
                  case "cesko":
                    B = "cs";
                    x = [5, 15, 21, 10, 18, 16, 12, 16, 25, 19, 14, 28, 14, 15];
                    break;
                  case "denmark":
                  case "danmark":
                    B = "dk";
                    x = [15, 40, 37, 24, 30, 2];
                    break;
                  case "europe":
                    B = "eu";
                    x = [5, 2, 9, 10, 5, 6, 7, 10, 4, 9, 9, 5, 15, 22, 7, 14, 12, 8, 7, 7, 2, 24, 2, 7, 2, 7, 2, 4, 3, 7, 2, 4, 8, 30, 12, 4, 11, 42, 6, 5, 5, 11, 26, 6, 10, 20, 17, 10, 2, 6, 9, 3];
                    break;
                  case "europe-russia":
                    B = "euru";
                    x = [4, 2, 8, 14, 8, 7, 8, 13, 3, 10, 8, 6, 21, 20, 9, 14, 10, 10, 4, 6, 21, 5, 8, 2, 7, 2, 4, 2, 9, 2, 5, 5, 27, 14, 7, 12, 82, 2, 9, 8, 4, 18, 21, 8, 14, 25, 14, 6, 10, 45, 16, 32, 14, 18, 28];
                    break;
                  case "finland":
                    B = "fi";
                    x = [8, 22, 28, 22, 26, 14, 15, 29, 15, 43, 21, 23, 28, 48, 24, 18, 15, 19, 18];
                    break;
                  case "france":
                    B = "fr";
                    x = [13, 25, 25, 14, 27, 14, 25, 21, 8, 19, 12, 13, 28, 15, 18, 27, 11, 26, 17, 25, 24, 34, 2, 2, 2, 2, 2];
                    break;
                  case "france-departments":
                  case "departements-francais":
                    B = "frd";
                    x = [10, 8, 9, 11, 9, 8, 11, 8, 9, 8, 11, 9, 7, 7, 7, 9, 15, 10, 9, 7, 7, 8, 7, 7, 10, 11, 8, 9, 10, 5, 13, 16, 11, 15, 10, 8, 9, 10, 12, 9, 10, 12, 10, 9, 11, 10, 10, 8, 7, 9, 8, 9, 10, 9, 11, 7, 7, 8, 9, 10, 5, 10, 8, 9, 6, 10, 5, 8, 6, 7, 8, 12, 9, 12, 7, 9, 9, 7, 5, 8, 7, 7, 8, 8, 7, 10, 10, 9, 10, 12, 3, 4, 9, 10, 10, 4, 2, 2, 2, 2, 2];
                    break;
                  case "germany":
                  case "deutschland":
                    B = "de";
                    x = [31, 41, 7, 38, 6, 8, 38, 25, 64, 37, 24, 9, 25, 31, 20, 33];
                    break;
                  case "baden-wurttemberg":
                    B = "dea";
                    x = [26, 8, 25, 16, 17, 29, 17, 14, 18, 13, 7, 15, 12, 6, 11, 25, 5, 18, 21, 6, 14, 11, 18, 13, 5, 16, 19, 15, 6, 21, 19, 14, 19, 20, 15, 16, 18, 22, 9, 14, 16, 7, 13, 15];
                    break;
                  case "bayern":
                    B = "deb";
                    x = [8, 8, 16, 3, 17, 5, 10, 3, 9, 6, 10, 11, 17, 3, 17, 4, 9, 11, 12, 3, 9, 11, 7, 13, 14, 8, 14, 7, 2, 14, 8, 10, 9, 7, 6, 3, 8, 8, 13, 13, 4, 5, 2, 4, 12, 10, 6, 9, 10, 15, 4, 7, 4, 12, 4, 10, 7, 12, 13, 6, 6, 8, 14, 11, 15, 6, 12, 11, 19, 14, 3, 10, 11, 15, 3, 8, 16, 2, 14, 12, 3, 13, 14, 4, 6, 4, 14, 9, 14, 14, 4, 14, 11, 6, 14, 4];
                    break;
                  case "berlin":
                    B = "dec";
                    x = [18, 15, 21, 15, 17, 18, 19, 17, 22, 16, 17, 25];
                    break;
                  case "brandenburg":
                    B = "ded";
                    x = [16, 11, 8, 31, 16, 3, 16, 18, 20, 18, 25, 22, 4, 28, 15, 20, 23, 18];
                    break;
                  case "bremen":
                    B = "dee";
                    x = [14, 11, 12, 8, 8, 17, 7, 12, 18, 14, 7, 31, 11, 11, 11, 8, 6, 12, 9, 10, 9, 8, 12, 8];
                    break;
                  case "hamburg":
                    B = "def";
                    x = [14, 21, 17, 24, 23, 36, 23];
                    break;
                  case "hessen":
                    B = "deg";
                    x = [13, 6, 14, 13, 14, 16, 12, 19, 13, 19, 4, 17, 12, 19, 10, 18, 8, 4, 9, 11, 21, 22, 15, 14, 21, 6];
                    break;
                  case "mecklenburg-vorpommern":
                    B = "deh";
                    x = [28, 26, 15, 29, 8, 5, 19, 16];
                    break;
                  case "niedersachsen":
                    B = "dei";
                    x = [10, 11, 4, 13, 14, 13, 3, 17, 4, 18, 11, 12, 11, 7, 9, 10, 9, 17, 10, 10, 13, 12, 11, 14, 13, 13, 12, 2, 15, 3, 9, 7, 9, 21, 17, 6, 8, 15, 11, 10, 9, 8, 3, 10, 12, 4];
                    break;
                  case "nordrhein-westfalen":
                    B = "dej";
                    x = [12, 6, 5, 4, 15, 5, 16, 7, 6, 13, 6, 10, 7, 11, 4, 15, 7, 6, 10, 9, 4, 15, 12, 15, 9, 4, 5, 14, 12, 14, 8, 7, 4, 9, 12, 3, 12, 15, 16, 3, 13, 12, 18, 13, 11, 12, 6, 14, 11, 14, 14, 19, 7];
                    break;
                  case "rheinland-pfalz":
                    B = "dek";
                    x = [16, 17, 20, 16, 19, 21, 16, 16, 16, 16, 4, 11, 19, 8, 5, 13, 7, 6, 7, 21, 27, 5, 14, 4, 19, 16, 15, 4, 23, 20, 9, 26, 17, 19, 6, 4];
                    break;
                  case "saarland":
                    B = "del";
                    x = [21, 22, 26, 28, 29, 19];
                    break;
                  case "sachsen":
                    B = "dem";
                    x = [24, 8, 9, 23, 19, 17, 8, 17, 27, 14, 18, 15, 17];
                    break;
                  case "sachsen-anhalt":
                    B = "den";
                    x = [20, 25, 26, 14, 11, 6, 17, 19, 7, 21, 23, 23, 28, 12];
                    break;
                  case "schleswig-holstein":
                    B = "deo";
                    x = [14, 4, 20, 8, 9, 5, 15, 18, 12, 14, 24, 26, 22, 12, 15];
                    break;
                  case "thuringen":
                    B = "dep";
                    x = [8, 10, 5, 10, 6, 20, 21, 18, 15, 5, 19, 8, 16, 14, 21, 17, 10, 17, 8, 17, 21, 5, 17];
                    break;
                  case "greece":
                    B = "gr";
                    x = [13, 24, 17, 13, 15, 16, 14, 5, 8, 16, 27, 21, 18, 13];
                    break;
                  case "hungary":
                    B = "hu";
                    x = [26, 12, 18, 19, 5, 11, 15, 15, 16, 18, 21, 9, 11, 27, 15, 19, 16, 13, 15, 12];
                    break;
                  case "ireland":
                    B = "ie";
                    x = [44, 12, 44, 43, 49, 43, 29, 41];
                    break;
                  case "ireland-counties":
                    B = "iec";
                    x = [14, 19, 19, 30, 2, 13, 5, 2, 11, 27, 2, 17, 16, 18, 14, 16, 17, 2, 15, 10, 21, 21, 13, 20, 21, 20, 17, 5, 18, 16, 2, 18, 13, 15];
                    break;
                  case "italy":
                  case "italia":
                    B = "it";
                    x = [16, 12, 13, 18, 29, 10, 24, 16, 27, 15, 12, 22, 23, 9, 27, 28, 15, 14, 6, 24];
                    break;
                  case "mexico":
                    B = "mx";
                    x = [3, 9, 10, 10, 12, 16, 13, 5, 3, 13, 7, 10, 7, 16, 7, 7, 4, 8, 12, 11, 8, 5, 7, 11, 13, 11, 11, 12, 3, 15, 8, 14];
                    break;
                  case "netherlands":
                  case "nederland":
                    B = "nl";
                    x = [23, 18, 23, 34, 20, 16, 23, 22, 25, 23, 15, 24];
                    break;
                  case "norway":
                  case "norge":
                    B = "no";
                    x = [10, 10, 14, 14, 13, 10, 13, 12, 19, 17, 3, 7, 10, 13, 16, 16, 9, 18, 7, 4];
                    break;
                  case "norway-divided":
                  case "norge-delt":
                    B = "nod";
                    x = [15, 19, 21, 14, 23, 16, 17, 17, 21, 25, 3, 9, 15, 18, 26, 13, 15, 19, 12, 4];
                    break;
                  case "poland":
                  case "polska":
                    B = "pl";
                    x = [31, 31, 28, 25, 36, 22, 47, 22, 28, 30, 30, 27, 24, 29, 46, 26];
                    break;
                  case "portugal":
                    B = "pt";
                    x = [17, 28, 16, 15, 23, 26, 28, 15, 27, 23, 13, 24, 14, 32, 23, 8, 17, 22, 5, 3];
                    break;
                  case "slovakia":
                  case "slovensko":
                    B = "sk";
                    x = [33, 16, 29, 32, 27, 29, 32, 25];
                    break;
                  case "south-africa":
                    B = "za";
                    x = [20, 19, 11, 14, 14, 21, 34, 24, 24];
                    break;
                  case "spain":
                  case "espana":
                    B = "es";
                    x = [18, 11, 12, 16, 14, 16, 23, 9, 12, 24, 12, 16, 2, 21, 19, 21, 15, 17, 11, 16, 17, 7, 12, 18, 14, 10, 13, 8, 19, 14, 14, 20, 2, 13, 12, 17, 11, 15, 8, 15, 7, 13, 18, 15, 11, 21, 25, 15, 14, 8, 12, 28];
                    break;
                  case "spain-autonomies":
                  case "espana-autonomias":
                    B = "esa";
                    x = [24, 30, 12, 7, 12, 11, 48, 57, 17, 2, 24, 27, 14, 11, 16, 2, 18, 16, 12];
                    break;
                  case "sweden":
                  case "sverige":
                    B = "se";
                    x = [7, 30, 20, 6, 13, 39, 14, 17, 13, 30, 11, 15, 7, 9, 11, 10, 19, 34, 28, 10, 18];
                    break;
                  case "switzerland":
                    B = "ch";
                    x = [27, 12, 7, 22, 4, 61, 34, 11, 14, 35, 17, 24, 17, 12, 12, 10, 15, 31, 28, 22, 19, 16, 31, 47, 6, 20];
                    break;
                  case "turkey":
                  case "turkiye":
                    B = "tr";
                    x = [16, 8, 12, 12, 7, 11, 19, 17, 7, 7, 9, 12, 5, 10, 6, 6, 8, 10, 8, 10, 10, 8, 9, 13, 13, 13, 6, 7, 10, 10, 18, 8, 11, 9, 10, 6, 6, 4, 11, 9, 13, 10, 8, 14, 8, 10, 13, 4, 6, 8, 9, 7, 23, 10, 12, 11, 9, 12, 13, 10, 7, 10, 8, 6, 8, 6, 10, 12, 8, 7, 16, 7, 8, 10, 6, 8, 6, 8, 3, 10, 5];
                    break;
                  case "united-kingdom":
                    B = "uk";
                    x = [31, 23, 10, 18, 24, 28, 30, 31, 24, 9, 8, 9, 10, 12, 12, 14, 17, 8, 16, 23, 11, 6, 14, 17, 7, 28, 19, 14, 19, 20];
                    break;
                  case "uruguay":
                    B = "uy";
                    x = [17, 13, 25, 12, 28, 15, 21, 23, 17, 5, 22, 21, 22, 23, 20, 17, 21, 30, 20];
                    break;
                  case "usa":
                    B = "usa";
                    x = [5, 6, 8, 6, 18, 2, 4, 5, 10, 9, 5, 11, 11, 4, 5, 5, 12, 6, 7, 9, 6, 9, 14, 7, 10, 10, 5, 14, 6, 7, 3, 10, 10, 3, 7, 6, 4, 5, 4, 8, 3, 6, 15, 3, 5, 10, 5, 3, 11, 8, 2, 2];
                    break;
                  case "venezuela":
                    B = "ve";
                    x = [20, 17, 19, 8, 19, 29, 2, 4, 9, 18, 11, 5, 18, 15, 11, 6, 12, 3, 11, 8, 7, 6, 4, 8, 23];
                    break
                }
                for (var v = 0; v < x.length; v++) {
                  var A = v + 1;
                  if (w == B + A) {
                    for (var C = 1; C < x[v]; C++) {
                      t += '<span class="s' + C + '" />'
                    }
                    break
                  }
                }
                t += "</span>";
                u.prepend(t).append('<span class="bg" />')
              },
              showTooltip: function (u) {
                var w = d.find(u).children("a")[0];
                if (o == "true" || o == "sticky") {
                  var t = d.outerWidth(),
                    x = Math.ceil(a(w).outerHeight() * -1) - c.tooltipArrowHeight,
                    A = Math.ceil(a(w).outerWidth() / -2),
                    z = a(w).position().left,
                    v = a(w).position().top;
                  if ((A * -1) > z) {
                    a(w).addClass("tooltip-left").css("left", 0);
                    A = 0
                  }
                  if ((A * -1) + z > t) {
                    a(w).addClass("tooltip-right");
                    A = 0
                  }
                  if ((x * -1) > v) {
                    a(w).addClass("tooltip-top");
                    x = c.tooltipArrowHeight
                  }
                  if (a(w).hasClass("tooltip-middle")) {
                    x = a(w).outerHeight() / -2
                  }
                  w.style.marginLeft = A + "px";
                  w.style.marginTop = x + "px"
                } else {
                  if (o != "false") {
                    var s = a(w).html(),
                      y = a("<div />", {
                        id: "map-tooltip",
                        html: s
                      }).appendTo("body")
                  }
                }
              },
              hideTooltips: function () {
                if (o == "true" || o == "sticky") {
                  for (var s = 0; s < d.find("a").length; s++) {
                    d.find("a")[s].style.marginTop = "-9999px"
                  }
                } else {
                  if (o.split("-")[0] == "floating") {
                    a("#map-tooltip").remove()
                  }
                }
              },
              copyList: function (t, u, v, s) {
                var w = v.html();
                if (typeof s != "undefined" && s.length >= 2) {
                  k += '<li class="' + u + '"><a href="' + s + '">' + w + "</a></li>"
                }
              },
              createList: function (s) {
                a(d).after('<ul class="map-visible-list">' + s + "</ul>")
              },
              autoSelectRegion: function () {
                var s = a(j).find(".active-region"),
                  t = j + " ." + s.parent("li").attr("class");
                if (s.length) {
                  n.selectRegion.activated(a(t))
                }
              }
            },
            selectRegion: {
              init: function (s, t, x) {
                var v = n.selectRegion,
                  t = j + " ." + t,
                  w = a(t).children("span").eq(0),
                  u = null;
                v.autoSelect(x);
                w.hover(function () {
                  v.onHover(a(t))
                }, function () {
                  v.unHover(a(t))
                }).mousemove(function (y) {
                  if (o.split("-")[0] == "floating") {
                    v.onMouseMove(a(t), y)
                  }
                }).click(function (y) {
                  v.clicked(a(t));
                  y.preventDefault()
                });
                a(x).focus(function () {
                  v.onHover(a(t))
                }).blur(function () {
                  v.unHover(a(t))
                }).keypress(function (y) {
                  u = (y.keyCode ? y.keyCode : y.which);
                  if (u === 13) {
                    v.clicked(a(t))
                  }
                }).click(function (y) {
                  v.clicked(a(t));
                  y.preventDefault()
                })
              },
              initVisibleList: function () {
                var t = n.selectRegion,
                  s = a(j + " .map-visible-list").find("li");
                s.each(function () {
                  var v = a(this).children("a"),
                    u = j + " ." + a(this).attr("class");
                  v.hover(function () {
                    t.onHover(a(u))
                  }, function () {
                    t.unHover(a(u))
                  }).focus(function () {
                    t.onHover(a(u))
                  }).blur(function () {
                    t.unHover(a(u))
                  }).click(function () {
                    t.clicked(a(u));
                    return false
                  }).keypress(function () {
                    code = (e.keyCode ? e.keyCode : e.which);
                    if (code === 13) {
                      t.clicked(a(u));
                      return false
                    }
                  })
                })
              },
              onHover: function (t) {
                var s = t.children("a").eq(0).attr("href");
                n.regions.hideTooltips();
                n.regions.showTooltip(t);
                t.addClass("focus");
                c.onHover(t);
                if (c.agentsListOnHover) {
                  n.agentslist.showAgent(s)
                }
              },
              onMouseMove: function (x, y) {
                var B = a("#map-tooltip").eq(0),
                  v = c.tooltipArrowHeight,
                  s = 10,
                  A = 15 + v,
                  w = a(B).outerHeight(),
                  C = a(B).outerWidth(),
                  t = a(window).scrollTop(),
                  u = y.pageY - w - v,
                  z = y.pageX - (C / 2);
                if (v < 3) {
                  v = 3
                }
                switch (o) {
                  case "floating-left":
                  case "floating-left-top":
                  case "floating-top-left":
                    if (y.clientX - C <= s) {
                      z = y.pageX + s
                    } else {
                      z = y.pageX - C - s
                    }
                    break;
                  case "floating-right":
                  case "floating-right-top":
                  case "floating-top-right":
                    if (f <= y.clientX + C + s) {
                      z = y.pageX - C - s
                    } else {
                      z = y.pageX + s
                    }
                    break;
                  case "floating-middle":
                  case "floating-middle-right":
                  case "floating-right-middle":
                    if (f <= y.clientX + C + s) {
                      z = y.pageX - C - s
                    } else {
                      z = y.pageX + s
                    }
                    if (t >= y.pageY - (w / 2) - v) {
                      u = y.pageY + A - v
                    } else {
                      if (y.clientY + (w / 2) >= b) {
                        u = y.pageY - w - v
                      } else {
                        u = y.pageY - (w / 2)
                      }
                    }
                    break;
                  case "floating-middle-left":
                  case "floating-left-middle":
                    if (y.clientX - C <= s) {
                      z = y.pageX + s
                    } else {
                      z = y.pageX - C - s
                    }
                    if (t >= y.pageY - (w / 2) - v) {
                      u = y.pageY + A - v
                    } else {
                      if (y.clientY + (w / 2) >= b) {
                        u = y.pageY - w - v
                      } else {
                        u = y.pageY - (w / 2)
                      }
                    }
                    break;
                  case "floating-bottom-left":
                  case "floating-left-bottom":
                    if (y.clientX - C < s) {
                      z = y.pageX + s
                    } else {
                      z = y.pageX - C - s
                    }
                    u = y.pageY + A;
                    break;
                  case "floating-bottom":
                  case "floating-bottom-center":
                  case "floating-center-bottom":
                    if (y.clientX - (C / 2) + s <= s) {
                      z = y.pageX + s
                    } else {
                      if (f <= y.clientX + (C / 2)) {
                        z = y.pageX - C - s
                      } else {
                        z = y.pageX - (C / 2)
                      }
                    }
                    u = y.pageY + A;
                    break;
                  case "floating-bottom-right":
                  case "floating-right-bottom":
                    if (f <= y.clientX + C + s) {
                      z = y.pageX - C - s
                    } else {
                      z = y.pageX + s
                    }
                    u = y.pageY + A;
                    break;
                  default:
                    if (y.clientX - (C / 2) + s <= s) {
                      z = y.pageX + s
                    } else {
                      if (f <= y.clientX + (C / 2)) {
                        z = y.pageX - C - s
                      } else {
                        z = y.pageX - (C / 2)
                      }
                    }
                }
                if (t >= y.pageY - w - v) {
                  u = y.pageY + A
                }
                if (y.clientY + w + A >= b) {
                  u = y.pageY - w - v
                }
                B.css({
                  left: z + "px",
                  top: u + "px"
                })
              },
              unHover: function (t) {
                var s = t.children("a").eq(0).attr("href");
                n.regions.hideTooltips();
                t.removeClass("focus");
                if (c.agentsListOnHover) {
                  n.agentslist.hideAgents(s);
                  a(d).find(".active-region").each(function () {
                    var u = a(this).children("a").eq(0).attr("href");
                    n.agentslist.showAgent(u)
                  })
                }
              },
              activated: function (x) {
                var w = c.clicksLimitAlert.split(" %d ")[0],
                  u = c.clicksLimitAlert.split(" %d ")[1],
                  v = x.children("a"),
                  s = v.attr("href"),
                  t = "";
                if (c.clicksLimit == 0 || !c.multipleClick) {
                  c.clicksLimit = Infinity
                }
                if (c.clicksLimit == 1) {
                  t = u.split(" || ")[0]
                } else {
                  t = u.split(" || ")[1]
                }
                if (x.hasClass("active-region")) {
                  n.agentslist.hideAgents(s);
                  x.removeClass("active-region");
                  l--;
                  p = false
                } else {
                  if (!c.multipleClick) {
                    a(j).find(".active-region").removeClass("active-region")
                  }
                  if (l < c.clicksLimit) {
                    if (a(c.agentsListId).length && s.charAt(0) == "#") {
                      n.agentslist.showAgent(s)
                    }
                    x.addClass("active-region");
                    l++
                  } else {
                    alert(w + " " + c.clicksLimit + " " + t);
                    p = true
                  }
                }
              },
              clicked: function (w) {
                var u = w.children("a"),
                  t = u.attr("href"),
                  v = u.attr("target"),
                  s = u.attr("rel");
                n.selectRegion.activated(w);
                if (p == false) {
                  c.onClick(w);
                  if (typeof v !== "undefined" && v !== false) {
                    window.open(t, v)
                  } else {
                    if (t.charAt(0) == "#") {
                      if (a(c.agentsListId).length || c.multipleClick) {
                        return false
                      } else {
                        if (s != "nofollow") {
                          window.location.hash = t
                        }
                      }
                    } else {
                      if (s != "nofollow") {
                        window.location.href = t
                      } else {
                        return false
                      }
                    }
                  }
                }
              },
              multiple: function () {
                var s = [],
                  t = a(j).find(".map-search-link");
                q.each(function () {
                  var w = a(this).children("a"),
                    v = w.attr("href"),
                    u;
                  if (v.charAt(0) == "#") {
                    u = v.slice(1)
                  } else {
                    if (/&/i.test(v)) {
                      u = v.slice(v.indexOf("?") + (c.searchLinkVar.length) + 2, v.indexOf("&"))
                    } else {
                      u = v.slice(v.indexOf("?") + (c.searchLinkVar.length) + 2)
                    }
                  }
                  if (a(this).hasClass("active-region")) {
                    s.push(u)
                  }
                });
                if (s.length) {
                  t.attr("href", c.searchUrl + "?" + c.searchLinkVar + "=" + s.join(c.searchLinkSeparator))
                } else {
                  t.attr("href", c.searchUrl)
                }
              },
              autoSelect: function (u) {
                var t = u.attr("href"),
                  s = window.location.hash;
                if (t.charAt(0) == "#" && t == s) {
                  u.addClass("active-region");
                  return false
                }
              }
            },
            searchButton: function () {
              var s = n.selectRegion,
                t = a("<a />", {
                  href: c.searchUrl,
                  "class": "map-search-link",
                  text: c.searchLink
                });
              a(d).after(t);
              t.hover(function () {
                s.multiple()
              }).focus(function () {
                s.multiple()
              }).click(function () {
                s.multiple()
              }).keypress(function () {
                code = (e.keyCode ? e.keyCode : e.which);
                if (code == 13) {
                  s.multiple()
                }
              })
            },
            agentslist: {
              init: function () {
                a(d).find(".active-region").each(function () {
                  var s = a(this).children("a").eq(0).attr("href");
                  n.agentslist.showAgent(s)
                })
              },
              showAgent: function (s) {
                if (!c.multipleClick) {
                  a(c.agentsListId).find("li").hide()
                }
                if (!c.agentsListOnHover) {
                  a(s + "," + s + " li").fadeIn(c.agentsListSpeed)
                } else {
                  a(s + "," + s + " li").show()
                }
              },
              hideAgents: function (s) {
                if (!c.agentsListOnHover) {
                  a(s + "," + s + " li").fadeOut(c.agentsListSpeed)
                } else {
                  a(s + "," + s + " li").hide()
                }
              }
            },
            clearMap: function () {
              for (var s = 100; s < 2050; s += 5) {
                r += " m" + s
              }
              a(j).removeClass(r).removeClass("css-map-container");
              a(d).removeClass("css-map");
              a(j).find("span, .map-visible-list, .map-search-link").remove();
              a(j).find("li").removeClass("focus").removeClass("active-region")
            }
          };
        n.init()
      })
    } else {
      return this.html("<b>Error:</b> map size must be set!")
    }
  }
})(jQuery);