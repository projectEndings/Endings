<!--* theme.xsl
    *
    * Included in anything that generates Web-facing HTML.
    *
    * Themes define colours, fonts and icons. They are used so
    * that people can choose a dark or light theme.
    *
    * Right now there is only one theme: "default". And no
    * way for users to switch between them.
    *
    * Liam Quin, Delightful Computing, Jan 2020, for Mulberry Technologies.
    *
    *-->
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:b="http://www.balisage.net/xslt/util"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs b d">

  <xsl:param name="path-to-root" select=" '../' " />

  <!--* included in every HTML page head element : *-->
  <xsl:variable name="html-extra-head-stuff" as="element(*)*" expand-text="no">
    <link href="https://fonts.googleapis.com/css?family=PT+Sans+Narrow&amp;display=swap" rel="stylesheet" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <!--* load the polyill for details/summary ONLY in IE/Edge:
        * some ugliness is used to get $path-to-root interpolated
        * where we need it.
        *-->
    <script type="text/JavaScript">
      var detailsElement = document.createElement("details");
      if (!("open" in detailsElement)) {
          document.write('&lt;script src="<xsl:value-of select="$path-to-root"/>/js/bower_components/better-dom/dist/better-dom.js">&lt;\/script>');
          document.write('&lt;script src="<xsl:value-of select="$path-to-root"/>/js/bower_components/better-details-polyfill/dist/better-details-polyfill.js">&lt;\/script>');
          document.write('&lt;script src="<xsl:value-of select="$path-to-root"/>/js/classname.js">&lt;\/script>');
      }
      /* Enable CSS styling of figure elements in IE:
       * https://xopus.com/devblog/2008/style-unknown-elements.html
       */
      var IEfix = document.createElement('figure');
    </script>
    <!--[endif]-->
    <style type="text/css" id="inverter" media="none">
      html {
        filter: invert(100%);
      }

      * {
        background-color: inherit;
      }

      /* do not invert SVG images */
      img:not([src*=".svg"]),
      [style*="url("] {
        filter: invert(100%);
      }
    </style>
  </xsl:variable>

  <xsl:template name="skip-nav">
    <div class="skipnav">
      <a href="#main">Skip to contents.</a>
    </div>
  </xsl:template>

  <xsl:template name="make-theme-switcher">
    <span class="themeswitchwrapper"> </span>
    <!--* see Heydon Pickering's book, Inclusive Components
        *
        * We will suppot an "inverted" theme using CSS filters;
        * if the browser does not support this, we hide the button.
	*-->
    <script>
      <xsl:text expand-text="no">
        (function () {
          function isDeclarationSupported(property, value) {
            var prop = property + ':',
              el = document.createElement('test'),
              mStyle = el.style;
            el.style.cssText = prop + value;
            return mStyle[property];
          }

          if (!isDeclarationSupported('filter', 'invert(100%)')) {
            document.querySelector('.invertedthemebutton').hidden = true;
            return;
          }

	  // add Dark theme buttons
	  var spans = document.getElementsByClassName('themeswitchwrapper');
          for (var i = 0; i &lt; spans.length; i++) {
	    spans[i].innerHTML = '&lt;label class="invertedthemebutton"&gt;&lt;input type="checkbox" class="invertthemer"/&gt;Dark theme: &lt;span aria-hidden="true"&gt;&lt;/span&gt;&lt;/label&gt;';
	  }

	  // find all the checkboxes for Dark Theme:
          var checkboxes = document.getElementsByClassName('invertthemer');

          /* Liam: use browser local storage to remember theme choice
           * between pages.
           */
          function html5StorageSupported() {
              try {
                var ourTest = 'balisage-test';
                localStorage.setItem(ourTest, ourTest);
                localStorage.removeItem(ourTest);
                return true;
                /* Note: not testing if it actually returns the right
                 * item; we do not need perfection here.
                 *
                 * Downside of this method is it wil raise local storage
                 * events in all open windows/tabs, but since we are
                 * going to save the preference with a write event,
                 * that's not really as big a deal as it sounds.
                 *
                 * Using try/catch because in private browsing, accessing
                 * storage will throw an error - also with some privacy
                 * blockers probably. Liam
                 */
              } catch(e) {
                return false;
              }
              return (window.localStorage !== undefined);
           }

          console.log("establishing theme");

          const internalThemeLabel = 'balisage-theme';
          const storeTheme = html5StorageSupported();

          for (var i = 0; i &lt; checkboxes.length; i++) {
            var checkbox = checkboxes[i];
            checkbox.addEventListener('change', function () {
              // Triggers repaint in most browsers:
              inverter.setAttribute('media', this.checked ? 'screen' : 'none');
              // Forces repaint in Chrome:
              inverter.textContent = inverter.textContent.trim();
              var on = this.checked;
              if (storeTheme) {
                  if (on) {
	  localStorage.setItem(internalThemeLabel, "dark");
                  } else {
	  localStorage.removeItem(internalThemeLabel);
                  }
              }
              console.log("theme switch to " + (this.checked? " dark" : "light"));
              // make all checkboxes the same
              var all = document.getElementsByClassName('invertthemer');
              for (var i = 0; i &lt; all.length; i++) {
                all[i].checked = on;
              }
            });

            if (storeTheme) {
              var themeName = localStorage.getItem(internalThemeLabel);
              if (themeName !== undefined) {
                  if (themeName === "dark") {
	  console.log("initiate dark theme");
	  /* since the light theme is the default, we only
	   * need to do something if it's dark.
	   * Note the use of === in case themeName is false.
	   */
	  checkbox.checked = true;
	  inverter.setAttribute('media', 'screen');
	  // Force repaint in Chrome:
	  inverter.textContent = inverter.textContent.trim();
                  }
              }
            }
         } // foreach checkbox

        })();
      </xsl:text>
    </script>
  </xsl:template>
 
  <!--* The following functions are here because theme.xsl is included
      * everywhere.
      *
      * Ultimately this should be reconciled with utility-functions.xsl,
      * but that file doesn't stand alone - it depends on $control and
      * can't be imported without setting things up, unfortunately.
      * Liam, 2020-070-4
      *-->
  <xsl:function name="b:get-alt-text" as="xs:string?">
    <xsl:param name="context" as="element(*)" />

    <!--* $context should be a mediaobject or inlinemediaobject element,
        * or have one as an ancestor.
        *
        * alt text must not contain markup (since it will go into
        * an attribute) and must be in the same natural language as
        * the image, for the same reason. Values are limited to approx.
        * 120 characters and should normally be much smaller; longer
        * values may be truncated by a text reader.
        *-->
    <xsl:variable name="mediaobject" select="b:find-media-object($context)" />
    <xsl:if test="empty($mediaobject)">
      <xsl:message terminate="yes">b:get-alt-text called on {
          $context/name()}
        outside a media object element [balisage-html.xsl]</xsl:message>
    </xsl:if>

    <xsl:variable name="alt" select="$mediaobject/d:alt" />

    <xsl:choose>
      <xsl:when test="$alt">
        <xsl:sequence select="$alt/text()" />
      </xsl:when>

      <!--* If there is no author-provided alt... *-->
      <xsl:otherwise>
        <!--* Previous versions of the proceedings mentioned the format
            * of the image here. That assumes the server can't change
            * image formats, and that the reader is interested in
            * whether it's PNG or JPEG.
            *
	    * Probably the best we can do is an empty alt attribute in this case.
	    *
            * Liam
            *-->
        <xsl:sequence select=" '' " />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="b:find-media-object" as="element(*)?">
    <xsl:param name="context" as="element(*)" />

    <!--* The caption for a mediaobject could contain an
        * inlinemediaobject, and that might be where we
        * are, so we should not return the grandparent...
        *-->
    <xsl:sequence select="
      (
        $context/ancestor-or-self::d:mediaobject[1], 
        $context/ancestor-or-self::d:inlinemediaobject[1]
      )[1]
      " />
  </xsl:function>
  
</xsl:stylesheet>
