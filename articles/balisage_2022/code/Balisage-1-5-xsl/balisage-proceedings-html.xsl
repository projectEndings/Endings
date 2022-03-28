<?xml version="1.0"?>
<!-- ============================================================= -->
<!-- MODULE:    Balisage Conference Paper XSLT                     -->
<!-- VERSION:   1.2                                                -->
<!-- DATE:      April, 2010                                        -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!-- SYSTEM:    Balisage: The Markup Conference papers             -->
<!--                                                               -->
<!-- PURPOSE:   Created for HTML production of papers in the       -->
<!--            Proceedings of Balisage: The Markup Conference     -->
<!--                                                               -->
<!-- CREATED BY:                                                   -->
<!--            Mulberry Technologies, Inc. (wap)                  -->
<!--            17 West Jefferson Street, Suite 207                -->
<!--            Rockville, MD  20850  USA                          -->
<!--            Phone:  +1 301/315-9631                            -->
<!--            Fax:    +1 301/315-8285                            -->
<!--            e-mail: info@mulberrytech.com                      -->
<!--            WWW:    http://www.mulberrytech.com                -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--                    DESIGN CONSIDERATIONS                      -->
<!-- ============================================================= -->
<!-- 
  This stylesheet is designed to handle the subset of Docbook V5
  defined by the Balisage-1-2.dtd.
  
  This stylesheet depends on balisage-html.xsl (in the same
  subdirectory) to provide for basic display logic; use that 
  stylesheet alone for a simple "preview" rendition of a Balisage 
  paper. Use this stylesheet if you want to see a paper as it 
  would appear in the published Conference Proceedings
  (at http://balisage.net/Proceedings/index.html).                 -->

<!-- ============================================================= -->
<!--                    OWNERSHIP AND LICENSES                     -->
<!-- ============================================================= -->
<!-- 
  
  This stylesheet was developed by, and is copyright 2010 
  Mulberry Technologies, Inc. It is released for use by authors in 
  production of papers submitted to Balisage: The Markup Conference
  (http://www.balisage.net)                                        -->
<!-- ============================================================= -->
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  expand-text="yes"
  exclude-result-prefixes="d xs">

  <xsl:variable name="imported-balisage-production" as="xs:boolean" select="false()" static="yes" />
  <xsl:import href="balisage-html.xsl"/>

  <xsl:output method="html" encoding="UTF-8" version="5" />

  <xsl:param name="css-file" select="'balisage-proceedings.css'"/>

  <xsl:param name="balisage-logo"
    select="'icons/BalisageSeries-logo.png'"/>
  
  <xsl:variable name="stylesheet-version">1.2</xsl:variable>
  
  <xsl:variable name="open-icon" select="'minus.png'"/>
  
  <xsl:variable name="closed-icon" select="'plus.png'"/>

  <xsl:variable name="control" select="/control"/>
  <!-- $control contains a 'control' document element if the source
       document is a control file -->
  
  <xsl:template match="d:article">
    <html lang="en">
      <head>
        <title>
          <xsl:if test="not(matches(d:title, 'Balisage'))">
            <!--* Liam: help people stay oriented: *-->
            <xsl:text>Balisage: </xsl:text>
          </xsl:if>
          <xsl:call-template name="html-title"/>
        </title>
        <link rel="stylesheet" href="{$css-file}" type="text/css"/>
        <xsl:sequence select="$html-extra-head-stuff" />
        <xsl:comment>balisage-proceedings.xsl</xsl:comment>
        <meta name="generator"
          content="Balisage Conference Proceedings XSLT (v{$stylesheet-version})"/>
        <xsl:call-template name="scholar-meta"/>
        <xsl:call-template name="proceedings-meta"/>
        <link id="favicon" rel="shortcut icon" type="image/png" href="http://balisage.net/favicon.ico" />
        <xsl:call-template name="script"/>
      </head>
      <body>
        <!--* see series-pages.html for notes on the contents of body *-->
        <xsl:call-template name="skip-nav"/>
        <xsl:call-template name="page-apparatus"/>
        <main id="main" role="main" aria-label="Main Content">
          <div class="article">
            <xsl:call-template name="article-contents"/>
            <xsl:call-template name="inline-citations"/>
          </div>
	  <xsl:call-template name="make-image-descriptions" />
          <xsl:call-template name="page-footer"/>
        </main>
      </body>
    </html>
  </xsl:template>
  
  <!-- only used in the production stylesheet: -->
  <xsl:template name="proceedings-meta"/>
  <xsl:template name="scholar-meta"/>
  
  <xsl:template name="inline-citations">
    <!-- generates inline popup boxes for citation references -->
    <xsl:apply-templates select="//d:bibliomixed" mode="inline-citation"/>
  </xsl:template>
  
  <xsl:template name="page-apparatus">
    <!--* see series-pages.html for an explanation *-->
    <!--* see balisage-production for the version of this template
        * used for the Proceedings Webb site articles.
        *-->
    <xsl:call-template name="page-header"/>
    <nav id="main-menu" role="navigation">
      <details>
        <!--* hamberger menu *-->
        <summary tabindex="0"><svg role="img" viewBox='0 0 20 20' height="20" width="20">
          <title>Menu</title>
          <path d='m0-0v4h20v-4h-20zm0 8v4h20v-4h-20zm0 8v4h20v-4h-20z' fill='currentColor' />
           </svg> Menu
        </summary>
        <div class="menu">
          <div id="navbar">
            <!-- The navigation bar is blank in this preview -->
          </div>
          <div id="index-mast">
            <xsl:call-template name="mast-contents"/>
          </div>
        </div><!--* /menu *-->
      </details>
    </nav>
    <nav class="navbar wide-mode" role="navigation" xsl:use-when="$imported-balisage-production">
      <xsl:call-template name="navigation"/>
    </nav>
    <nav id="index-mast" class="wide-mode" role="navigation">
      <xsl:call-template name="mast-contents"/>
    </nav>
  </xsl:template>
  
  <xsl:template name="mast-contents">
    <div class="content">
      <xsl:apply-templates mode="titlepage" select="d:title | d:subtitle"/>


<!-- 20200924 trg:  replaced following template using "mode='titlepage'" with
       same template using "mode='mast'" in order for author "preview" processing
       of a paper to include full author info (incl. personblurb); change
       does NOT impact full proceeding processing. -->
<!--  <xsl:apply-templates mode="titlepage" select="/d:article/d:info/d:author"/> -->
      <xsl:apply-templates mode="mast" select="/d:article/d:info/d:author"/>
      <xsl:apply-templates mode="mast" select="/d:article/d:info/d:legalnotice"/>
      <xsl:apply-templates mode="mast" select="/d:article/d:info/d:abstract"/>
      <xsl:call-template name="toc" />
    </div>
  </xsl:template>
  
  <xsl:template name="page-header">
    <div id="balisage-header" role="banner" aria-label="Logo and breadcrumb links">
      <a class="quiet" href="http://www.balisage.net">
        <img style="float:right;border:none" alt="Balisage logo" height="130"
          src="{$balisage-logo}"/>
      </a>
      <h2 class="page-header">Balisage: The Markup Conference</h2>
      <h1 class="page-header">Proceedings preview</h1>
    </div>
  </xsl:template>
  
  <xsl:template name="article-contents">
    <xsl:apply-templates select="d:title | d:subtitle" mode="titlepage"/>
    <xsl:apply-templates/>
    <xsl:call-template name="footnotes"/>
  </xsl:template>
  
  <xsl:template name="page-footer">
    <xsl:call-template name="author-keywords"/>
    <div id="balisage-footer">
      <h3>
        <xsl:text>Balisage Series on Markup Technologies</xsl:text>
      </h3>
    </div>
  </xsl:template>
  
  <xsl:template name="author-keywords">
    <xsl:for-each
      select="/d:article/d:info/d:keywordset[@role='author'][d:keyword[normalize-space(.)]]">
      <div id="author-keywords">
        <h5 class="keywords">Author's keywords for this paper:</h5>
        <xsl:text> </xsl:text>
        <xsl:for-each select="d:keyword[normalize-space()]">
          <span class="keyword">
            <xsl:apply-templates/>
          </span>
          <xsl:if test="not(position() = last())">; </xsl:if>
        </xsl:for-each>
      </div>
    </xsl:for-each>
  </xsl:template>  
  
  <xsl:template match="d:author" mode="mast">
    <xsl:if test="normalize-space(string(d:personname))">
      <details class="mast-box">
        <summary class="title">
          <xsl:apply-templates select="d:personname"/>
        </summary>
  <!-- 20170110 trg:  switched order of affiliation and email -->
        <xsl:apply-templates select="d:affiliation" mode="titlepage"/>
        <xsl:apply-templates select="d:email" mode="titlepage"/>
        <xsl:apply-templates select="d:uri" mode="titlepage"/>
        <xsl:apply-templates select="d:personblurb" mode="titlepage"/>
      </details>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="d:legalnotice" mode="mast">
    <div class="legalnotice-block">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="d:abstract" mode="mast">
    <details class="abstract">
      <summary>
        <h2 class="inline-heading">Abstract</h2>
      </summary>
      <xsl:apply-templates/>
    </details>
  </xsl:template>

  
  
  <!-- overrides templates in balisage-html.xsl to make popups for
       links to bibliographic references -->
  

  <xsl:template match="d:bibliomixed" mode="xref">
    <xsl:param name="xref-id" select="'xxx'"/>
    <xsl:param name="text-contents">
      <xsl:apply-templates select="." mode="label-text"/>
    </xsl:param>
    <xsl:variable name="cite-id">
      <xsl:text>cite-</xsl:text>
      <xsl:apply-templates select="." mode="id"/>
    </xsl:variable>
    <a class="xref" id="{$xref-id}"
      href="javascript:showcite('{$cite-id}','{$xref-id}')">
      <xsl:copy-of select="$text-contents"/>
    </a>
  </xsl:template>
  
  <xsl:template match="d:bibliomixed" mode="inline-citation">
    <xsl:variable name="cite-id">
      <xsl:text>cite-</xsl:text>
      <xsl:apply-templates select="." mode="id"/>
    </xsl:variable>
    <div class="inline-citation" id="{$cite-id}">
      <a class="quiet" href="javascript:hidecite('{$cite-id}')" aria-label="Close Citation Box">×</a>
      <p>
        <xsl:apply-templates/>
      </p>
    </div>
  </xsl:template>
  
  <!--
  <xsl:template match="d:bibliography" mode="popup">
    <xsl:apply-templates select="d:bibliomixed" mode="popup"/>
  </xsl:template>
  <xsl:template match="d:bibliomixed" mode="popup">
    <xsl:variable name="id">
      <xsl:text>cite-</xsl:text>
      <xsl:apply-templates select="." mode="id"/>
    </xsl:variable>   
  </xsl:template>  
  -->

  
  <xsl:template name="script">
    <script type="text/javascript">
      <xsl:text expand-text="no">

   function hidecite(citeID) {
     cite = document.getElementById(citeID);
     cite.style.display = "none";
     return;
   }
   
   function showcite(citeID,anchorID) {
     cite = document.getElementById(citeID);

     citeLeft = cite.style.left;
     citeTop = cite.style.top;
     
     if (citeLeft != (getLeft(anchorID)+"px") ||
         citeTop != (getTop(anchorID)+"px")) {
       cite.style.display = "none";
     }
     
     if (cite.style.display != "table-cell") {
        movebox(citeID, anchorID);
        cite.style.display = "table-cell";
     }
     else {
       cite.style.display = "none";
     };
     return;
   }

   function movebox(citeID, anchorID) {

     cite = document.getElementById(citeID);
     
     // alert(cite.offsetWidth + " by " + cite.offsetHeight)
     
     horizontalOffset = getLeft(anchorID);
     // horizontalOffset = (inMain(anchorID)) ?
     // (horizontalOffset - 260) : (horizontalOffset + 20)
     // (horizontalOffset - (20 + cite.offsetWidth)) : (horizontalOffset + 20)

     verticalOffset = getTop(anchorID);
     // verticalOffset = (inMain(anchorID)) ?
     // (verticalOffset - 20) : (verticalOffset + 20)
     // (verticalOffset - (20 + cite.offsetHeight)) : (verticalOffset + 20)

     /*
     horizontalOffset = getAbsoluteLeft(anchorID) - getScrollLeft(anchorID) + 20;
     if (inMain(anchorID)) {
       horizontalOffset = horizontalOffset - 300;
     }
     verticalOffset = getAbsoluteTop(anchorID) - getScrollTop(anchorID) - 40;
     if (inMain(anchorID)) {
       verticalOffset = verticalOffset - 300;
     }
     */
     
     cite.style.left = horizontalOffset + "px";
     cite.style.top = verticalOffset + "px";
   }
   
   function getLeft(objectID) {
     var left = getAbsoluteLeft(objectID) - getScrollLeft(objectID);
     left = (inMain(objectID)) ? (left - 260) : (left + 20)    
     return left;
   }
   
   function getTop(objectID) {
     var top = getAbsoluteTop(objectID) - getScrollTop(objectID);
     top = (inMain(objectID)) ? (top - 50) : (top + 20)
     return top;     
   }
   
   function getAbsoluteLeft(objectId) {
   // Get an object left position from the upper left viewport corner
     o = document.getElementById(objectId)
     oLeft = o.offsetLeft            // Get left position from the parent object
     while(o.offsetParent!=null) {   // Parse the parent hierarchy up to the document element
       oParent = o.offsetParent    // Get parent object reference
       oLeft += oParent.offsetLeft // Add parent left position
       o = oParent
      }
    return oLeft
    }

    function getAbsoluteTop(objectId) {
    // Get an object top position from the upper left viewport corner
      o = document.getElementById(objectId)
      oTop = o.offsetTop            // Get top position from the parent object
      while(o.offsetParent!=null) { // Parse the parent hierarchy up to the document element
        oParent = o.offsetParent  // Get parent object reference
        oTop += oParent.offsetTop // Add parent top position
        o = oParent
      }
    return oTop
    }

   function getScrollLeft(objectId) {
     // Get a left scroll position
     o = document.getElementById(objectId)
     oLeft = o.scrollLeft            // Get left position from the parent object
     while(o.offsetParent!=null) {   // Parse the parent hierarchy up to the document element
       oParent = o.offsetParent    // Get parent object reference
       oLeft += oParent.scrollLeft // Add parent left position
       o = oParent
      }
    return oLeft
    }

    function getScrollTop(objectId) {
    // Get a right scroll position
      o = document.getElementById(objectId)
      oTop = o.scrollTop            // Get top position from the parent object
      while(o.offsetParent!=null) { // Parse the parent hierarchy up to the document element
        oParent = o.offsetParent  // Get parent object reference
        oTop += oParent.scrollTop // Add parent top position
        o = oParent
      }
    return oTop
    }

    function inMain(objectId) {
    // returns true if in div#main
      o = document.getElementById(objectId)
      while(o.parentNode != null) { // Parse the parent hierarchy up to div#main
        oParent = o.parentNode
        if (o.id == "main") { return true; }
        o = oParent;
      }
    return false;
    }


   /*
   function showcite(citeID) {
      cite = document.getElementById(citeID);
      if (cite.style.display != "table-cell") {
        cite.style.display = "table-cell";
      }
      else {
        cite.style.display = "none";
      };
      return;
    }
    */

      </xsl:text>
    </script>
  </xsl:template>
  
</xsl:stylesheet>
