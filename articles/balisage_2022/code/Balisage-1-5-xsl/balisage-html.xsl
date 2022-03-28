<?xml version="1.0"?>
<!-- ============================================================= -->
<!-- MODULE:    Balisage Conference Paper Preview XSLT             -->
<!-- VERSION:   1.2                                                -->
<!-- DATE:      March, 2010                                        -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!-- SYSTEM:    Balisage: The Markup Conference papers             -->
<!--                                                               -->
<!-- PURPOSE:   Created for preview display (HTML) of papers       -->
<!--            submitted for Balisage: The Markup Conference      -->
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
  defined by the Balisage-1-2.dtd. It is implemented in XSLT 1.0
  without extensions, and should work in any XSLT 1.0 processor.
  
  As a standalone stylesheet, in conjunction with an associated 
  CSS stylesheet (balisage-preview.css, linked from the result file),
  it specifies processing resulting in a clean "preview" display of 
  a Balisage paper conformant with the 1.2 DTD.
  
  Additionally, this stylesheet is intended to serve as the core
  of the Balisage Proceedings production system and for related
  (ancillary) productions such as peer-review versions of the
  papers, etc.                                                     -->

<!-- ============================================================= -->
<!--                    OWNERSHIP AND LICENSES                     -->
<!-- ============================================================= -->
<!-- 
  
  This stylesheet was developed by, and is copyright 2010 
  Mulberry Technologies, Inc. It is released for use by authors in 
  production of papers submitted to Balisage: The Markup Conference
  (http://www.balisage.net)                                        -->
<!-- ============================================================= -->

  <!--<xsl:output method="html" encoding="UTF-8" indent="no"
    version="5" />-->

  <!--<xsl:output method="xml" encoding="UTF-8" indent="no"
     omit-xml-declaration="yes" version="5" />-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:b="http://www.balisage.net/xslt/util"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="b d xlink xs"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  version="3.0">
  
  
  <xsl:strip-space elements="d:article d:info d:appendix d:bibliography
    d:abstract d:author d:legalnotice d:keywordset d:confgroup
    d:personname d:personblurb d:affiliation d:section d:blockquote
    d:note d:footnote d:caption d:equation d:itemizedlist d:orderedlist
    d:listitem d:variablelist d:varlistentry d:figure d:mediaobject
    d:inlinemediaobject d:imageobject d:imagedata d:footnoteref
    d:xref d:tfoot d:tbody d:informaltable d:table d:col d:colgroup
    d:thead d:tr"/>


  <xsl:key match="*[@xml:id]" name="element-by-id" use="@xml:id"/>

  <xsl:key name="xref-by-linkend" match="*[normalize-space(@linkend)]" use="@linkend"/>
  

<xsl:template match="*">
    <xsl:message>
      <xsl:value-of select="name()"/>
      <xsl:text> not matched in balisage-html</xsl:text>
    </xsl:message>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:param name="css-file">balisage-plain.css</xsl:param>

  <xsl:import href="theme.xsl" />
  
  <xsl:template match="/">
    <html lang="en">
      <head>
        <title>
          <xsl:if test="not(matches(/d:article/d:title, 'Balisage'))">
            <!--* Liam: help people stay oriented: *-->
            <xsl:text>Balisage: </xsl:text>
          </xsl:if>
          <xsl:call-template name="html-title"/>
        </title>
        <xsl:sequence select="$html-extra-head-stuff" />
        <link rel="stylesheet" href="{$css-file}" type="text/css"/>
        <xsl:for-each select="/d:article/d:info/d:keywordset">
          <meta name="keywords">
            <xsl:attribute name="content">
              <xsl:for-each select="d:keyword">
                <xsl:if test="not(position()=1)">, </xsl:if>
                <xsl:value-of select="."/>
              </xsl:for-each>
            </xsl:attribute>
          </meta>
        </xsl:for-each>
        <link id="favicon" rel="shortcut icon" type="image/png" href="http://balisage.net/favicon.ico" />
        <xsl:comment>balisage-html.xsl</xsl:comment>
      </head>
      <body>
        <!--* see series-pages.html for more comments *-->
        <xsl:call-template name="skip-nav" />
        <xsl:call-template name="balisage-header"/>
        <xsl:apply-templates select="/d:article"/>
        <xsl:call-template name="make-image-descriptions" />
        <xsl:call-template name="balisage-footer"/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template name="html-title">
    <xsl:apply-templates select="/d:article/d:title" mode="text-only"/>
  </xsl:template>
  
  <xsl:template name="balisage-header">
    <!--* this template isn't used for the main Web site, but
        * only in standalone mode for proofing perhaps.
        *-->
    <div id="balisage-header" role="banner">
      <h1>
        <xsl:comment>* balisage-html.xsl 519.38 *</xsl:comment>
        <i>Balisage:</i>&#xA0;<small>The Markup Conference</small>
      </h1>
    </div>
  </xsl:template>

  <xsl:template name="make-image-descriptions">
    <xsl:variable name="objects" select="//d:inlinemediaobject[d:textobject[node()]]" />

    <xsl:if test="$objects">
      <div class="image-descriptions">
        <h2>Inline Image Descriptions</h2>
        <ul>
          <xsl:for-each select="$objects">
            <xsl:variable name="textobject" select="d:textobject" />
            <xsl:variable name="item" select=".." />
            <xsl:variable name="id" as="xs:string?">
                <xsl:apply-templates select="." mode="id"/>
            </xsl:variable>

            <li class="one-image-description" id="description-for-{$id}">
              <xsl:apply-templates select="d:textobject/node()"/>
              <xsl:if test="$item">
                <p><a href="#{$id}">Return to the image</a></p>
              </xsl:if>
            </li>
          </xsl:for-each>
        </ul>
      </div><!--* image-descriptions *-->
    </xsl:if>
  </xsl:template>

  <xsl:template name="balisage-footer">
    <!--* this template isn't used for the main Web site, but
        * only in standalone mode for proofing perhaps.
        *-->
    <div id="balisage-footer">
      <h3>
        <xsl:comment>* balisage-html.xsl 519.38 *</xsl:comment>
        <i>Balisage:</i>&#xA0;<small>The Markup Conference</small>
      </h3>
    </div>
  </xsl:template>
 
 
  <xsl:template match="d:article">
    <div lang="en" class="article">
      <xsl:call-template name="titlepage"/>
      <xsl:call-template name="toc"/>
      <xsl:apply-templates/>
      <xsl:call-template name="footnotes"/>
    </div>
  </xsl:template>


  <xsl:template name="titlepage">
    <div class="titlepage">
        <xsl:apply-templates mode="titlepage"
          select="/d:article/d:title | /d:article/d:subtitle"/>
        <xsl:for-each select="/d:article/d:info">
          <xsl:apply-templates mode="titlepage" select="d:author"/>
          <xsl:apply-templates mode="titlepage" select="d:legalnotice"/>
          <xsl:apply-templates mode="titlepage" select="d:abstract"/>
        </xsl:for-each>
      <hr/>
    </div>
  </xsl:template>


  <!-- titlepage mode -->

  <xsl:template match="d:title" mode="titlepage">
      <h1 class="article-title">
        <xsl:call-template name="attach-id"/>
        <xsl:text>Balisage Paper: </xsl:text>
        <xsl:apply-templates/>
      </h1>
  </xsl:template>

  <xsl:template match="d:subtitle" mode="titlepage">
      <h2 class="subtitle"><xsl:apply-templates/></h2>
  </xsl:template>

  <xsl:template match="d:author" mode="titlepage">
    <div class="author">
      <xsl:apply-templates select="d:personname" mode="titlepage"/>
      <xsl:apply-templates select="d:affiliation" mode="titlepage"/>
      <xsl:apply-templates select="d:email" mode="titlepage"/>
      <xsl:apply-templates select="d:uri" mode="titlepage"/>
    </div>
  </xsl:template>
  
  <xsl:template match="d:personname" mode="titlepage">
    <h3 class="author">
      <xsl:apply-templates select="."/>
    </h3>
  </xsl:template>

  <xsl:template match="d:personname">
    <xsl:for-each select="*">
      <xsl:if test="not(position()=1)">
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="d:affiliation" mode="titlepage">
    <div class="affiliation">
      <xsl:for-each select="*">
        <p class="{local-name()}">
          <xsl:apply-templates/>
        </p>
      </xsl:for-each>
    </div>
  </xsl:template>


  <xsl:template match="d:email" mode="titlepage">
    <h5 class="author-email">
      <xsl:apply-templates select="."/>
    </h5>
  </xsl:template>

  <xsl:template match="d:uri" mode="titlepage">
    <div class="orcid">
      <xsl:apply-templates select="." />
    </div>
  </xsl:template>

  <xsl:template match="d:legalnotice" mode="titlepage">
    <div class="legalnotice">
      <xsl:call-template name="attach-id"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>


  <xsl:template match="d:abstract" mode="titlepage">
    <div class="abstract">
      <h2>Abstract</h2>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="d:personblurb" mode="titlepage">
    <div class="personblurb">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  
  <!-- toc mode -->
  
  <xsl:template name="toc">
    <xsl:param name="expanded" as="xs:boolean?" select="false()" />

    <!-- working around how CMSMcQ keynotes will have sections with
         dummy titles -->
    <xsl:variable name="contents">
      <xsl:apply-templates select="d:section | d:appendix" mode="toc"/>
    </xsl:variable>
    <xsl:if test="normalize-space($contents)">
      <details class="toc">
        <xsl:if test="$expanded">
          <xsl:attribute name="open" select=" 'open' " />
        </xsl:if>
        <summary><h2 class="inline-heading">Table of Contents</h2></summary>
        <dl>
          <xsl:copy-of select="$contents"/>
        </dl>
     </details>
    </xsl:if>
  </xsl:template>


  <xsl:template match="d:section | d:appendix" mode="toc">
    <dt>
      <span class="{local-name()}">
        <xsl:variable name="id">
          <xsl:apply-templates select="." mode="id"/>
        </xsl:variable>
        <a href="#{$id}" class="toc">
          <xsl:apply-templates select="self::d:appendix" mode="label-text"/>
          <xsl:if test="self::d:appendix">. </xsl:if>
          <xsl:apply-templates select="d:title" mode="toc"/>
        </a>
      </span>
    </dt>
    <xsl:if test="d:section and not(../parent::d:section|../parent::d:appendix)">
      <!-- we go three levels deep -->
      <dd>
        <dl>
          <xsl:apply-templates select="d:section" mode="toc"/>
        </dl>
      </dd>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="d:title" mode="toc">
    <xsl:apply-templates mode="toc"/>
  </xsl:template>
  
  <xsl:template match="*" mode="toc">
    <xsl:apply-templates select="."/>
  </xsl:template>
  
  <!-- cross-references do not work in the table of contents -->
  <xsl:template match="d:footnote" mode="toc"/>
  
  <!-- default mode -->
  
  <!-- suppress these (they appear in other modes) -->
  <xsl:template match="d:article/d:title | d:article/d:subtitle | d:info"/>
  
  <xsl:template match="d:section | d:appendix">
    <div class="{local-name()}">
      <xsl:call-template name="attach-id"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>


  <xsl:template match="d:section/d:title | d:appendix/d:title">
    <xsl:variable name="level" select="count(ancestor::d:section | ancestor::d:appendix)"/>
    <xsl:if test="$level > 5">
      <xsl:call-template name="runtime-warning">
        <xsl:with-param name="message">
          <xsl:text>Generating 'h</xsl:text>
          <xsl:value-of select="$level + 1"/>
          <xsl:text>' element for section title </xsl:text>
          <xsl:value-of select="$level"/>
          <xsl:text>s deep -- not valid HTML</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <!-- because of browser bugs, we want to avoid emitting an empty tag
         for titles that have no content -->
    <xsl:if test="normalize-space(.)">
      <xsl:element name="h{$level+1}">
        <xsl:attribute name="class">title</xsl:attribute>
        <xsl:attribute name="style">clear: both</xsl:attribute>
        <xsl:apply-templates select="parent::d:appendix" mode="label-text"/>
        <xsl:if test="parent::d:appendix">. </xsl:if>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="d:section/d:subtitle | d:appendix/d:subtitle">
    <xsl:variable name="level" select="count(ancestor::d:section | ancestor::d:appendix)"/>
    <xsl:if test="$level > 4">
      <xsl:call-template name="runtime-warning">
        <xsl:with-param name="message">
          <xsl:text>Generating 'h</xsl:text>
          <xsl:value-of select="$level + 2"/>
          <xsl:text>' element for section title </xsl:text>
          <xsl:value-of select="$level"/>
          <xsl:text>s deep -- not valid HTML</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:element name="h{$level+2}">
      <xsl:attribute name="class">subtitle</xsl:attribute>
      <xsl:attribute name="style">clear: both</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  
  <xsl:template match="d:bibliography">
    <div class="bibliography">
      <xsl:call-template name="attach-id"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  
  <!-- LDW 20160516: changed to References for Google Scholar indexing. -->
  <xsl:template match="d:bibliography/d:title">
    <h2 class="title">
      <xsl:text>References</xsl:text>
    </h2>
  </xsl:template>

  <xsl:template match="d:bibliomixed">
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="label-text"/>
    </xsl:variable>
    <p class="bibliomixed">
      <xsl:call-template name="attach-id"/>
      <xsl:if test="normalize-space($label)">
        <xsl:choose>
          <xsl:when test="key('xref-by-linkend',@xml:id)">
            <a>
              <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:apply-templates select="key('xref-by-linkend',@xml:id)[1]" mode="id"/>
              </xsl:attribute>
              <xsl:text>[</xsl:text>
              <xsl:value-of select="$label"/>
              <xsl:text>] </xsl:text>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>[</xsl:text>
            <xsl:value-of select="$label"/>
            <xsl:text>] </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:apply-templates/>
    </p>
  </xsl:template>


  <xsl:template match="d:note">
    <div class="note">
      <xsl:call-template name="attach-id"/>
      <xsl:apply-templates select="." mode="labeled-title"/>
      <xsl:apply-templates/>
      </div>
  </xsl:template>


  <xsl:template match="d:blockquote">
    <div class="blockquote">
      <blockquote class="blockquote">
        <xsl:apply-templates/>
      </blockquote>
    </div>
  </xsl:template>


  <xsl:template match="d:attribution">
    <p class="attribution">
      <xsl:text>&#x2014; </xsl:text>
      <xsl:apply-templates/>
    </p>
  </xsl:template>


  <xsl:template match="d:equation">
    <div class="equation">
      <xsl:call-template name="attach-id"/>
      <p class="title">
        <xsl:apply-templates select="." mode="label-text"/>
      </p>
      <div class="equation-contents">
        <xsl:apply-templates/>
      </div>
    </div>
  </xsl:template>
  
  
  <xsl:template match="d:figure">
      <!--* Note: for IE earlier than version 9 to support the figure element,
           * the JavaScript has to call document.createelement("figure");
           * see https://xopus.com/devblog/2008/style-unknown-elements.html
           * for information on this. This is done in theme.xsl.
           *-->
    <figure>
      <xsl:call-template name="attach-id"/>
      <xsl:apply-templates select="." mode="labeled-title"/>
      <div class="figure-contents">
        <xsl:apply-templates/>
      </div>
    </figure>
</xsl:template>


  <xsl:template match="d:table">
    <div class="table-wrapper">
      <xsl:call-template name="attach-id"/>
      <p class="title">
        <xsl:apply-templates select="." mode="label-text"/>
      </p>
      <xsl:apply-templates select="d:caption"/>
      <table class="table">
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="table-contents"/>
      </table>
    </div>    
  </xsl:template>


  <xsl:template match="d:caption">
    <div class="caption">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  
  <!-- table captions are moved up into the wrapper div, so
       suppressed here -->
  <xsl:template match="d:caption" mode="table-contents"/>
  
  
  <xsl:template match="d:th/* | d:td/*" mode="table-contents">
    <!-- as soon as we're inside a th or td, we kick out
         of this mode -->
    <xsl:apply-templates select="."/>
  </xsl:template>


  <xsl:template match="*" mode="table-contents">
    <!-- otherwise, we strip the namespace -->
    <xsl:element name="{local-name()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="table-contents"/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="d:informaltable">
    <table class="table">
      <xsl:if test="@summary">
        <xsl:attribute name="summary" select="@summary" />
      </xsl:if>
      <xsl:call-template name="attach-id"/>
      <xsl:apply-templates mode="table-contents"/>
    </table>
  </xsl:template>
  

  <xsl:template match="d:mediaobject">
    <div class="mediaobject">
      <xsl:call-template name="attach-id"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="d:itemizedlist">
    <div class="itemizedlist">
      <xsl:call-template name="attach-id"/>
      <xsl:apply-templates select="." mode="labeled-title"/>
      <ul>
        <xsl:apply-templates/>
      </ul>
    </div>
  </xsl:template>


  <xsl:template match="d:orderedlist">
    <div class="orderedlist">
      <xsl:call-template name="attach-id"/>
      <xsl:apply-templates select="." mode="labeled-title"/>
      <xsl:variable name="list-style">
        <xsl:apply-templates select="." mode="list-style"/>
      </xsl:variable>
      <ol>
        <xsl:if test="@startingnumber|@continuation">
          <xsl:attribute name="start">
            <xsl:choose>
              <xsl:when test="number(@startingnumber)">
                <xsl:value-of select="@startingnumber"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="continued-from">
                  <xsl:apply-templates select="@continuation" mode="continued-list"/>
                </xsl:variable>
                <xsl:value-of select="$continued-from + 1"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space($list-style)">
          <xsl:attribute name="style">
            <xsl:value-of select="normalize-space($list-style)"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
      </ol>
    </div>
  </xsl:template>


  <xsl:template match="d:orderedlist/@continuation[not(.='continues')]" mode="continued-list">
    <xsl:text>0</xsl:text>
  </xsl:template>


  <xsl:template match="d:orderedlist/@continuation[.='continues']" mode="continued-list">
    <xsl:text>0</xsl:text>
    <xsl:apply-templates select="../preceding-sibling::d:orderedlist[1]" mode="continued-list"/>
  </xsl:template>
 
 
  <xsl:template match="d:orderedlist" mode="continued-list">
    <xsl:variable name="count" select="count(d:listitem)"/>
    <xsl:variable name="preceding-count">
      <xsl:text>0</xsl:text>
      <xsl:choose>
        <xsl:when test="number(@startingnumber)">
          <xsl:value-of select="@startingnumber - 1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@continuation" mode="continued-list"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$count + $preceding-count"/>
  </xsl:template>


  <xsl:template match="d:orderedlist" mode="list-style">
    <xsl:variable name="continuing-style">
      <xsl:if test="@continuation='continues'">
        <xsl:apply-templates select="preceding-sibling::d:orderedlist[1]" mode="list-style"/>
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="$continuing-style"/>
    <xsl:if test="not(normalize-space($continuing-style))">
      <xsl:apply-templates select="@numeration" mode="list-style"/>
      <xsl:if test="not(@numeration)">
        <xsl:call-template name="default-list-style"/>
      </xsl:if>     
    </xsl:if>
  </xsl:template>


  <xsl:template match="d:orderedlist/@numeration[.='upperalpha']" mode="list-style">
     <xsl:text>list-style-type: upper-alpha; </xsl:text>    
  </xsl:template>


  <xsl:template match="d:orderedlist/@numeration[.='loweralpha']" mode="list-style">
     <xsl:text>list-style-type: lower-alpha; </xsl:text>    
  </xsl:template>
 
 
  <xsl:template match="d:orderedlist/@numeration[.='upperroman']" mode="list-style">
     <xsl:text>list-style-type: upper-roman; </xsl:text>    
  </xsl:template>
 
 
  <xsl:template match="d:orderedlist/@numeration[.='lowerroman']" mode="list-style">
     <xsl:text>list-style-type: lower-roman; </xsl:text>    
  </xsl:template>
  
  
  <xsl:template match="d:orderedlist/@numeration[.='arabic']" mode="style"
    name="default-list-style">
     <xsl:text>list-style-type: decimal; </xsl:text>    
  </xsl:template>
  
  
  <xsl:template match="d:listitem">
    <li>
      <xsl:call-template name="attach-id"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>


  <xsl:template match="d:variablelist">
    <div class="variablelist">
      <xsl:call-template name="attach-id"/>
      <xsl:apply-templates select="d:title"/>
      <table border="0" class="variablelist">
        <col valign="top" align="left"/>
        <tbody>
          <xsl:apply-templates select="d:varlistentry"/>
        </tbody>
      </table></div>
  </xsl:template>


  <xsl:template match="d:varlistentry">
    <tr>
      <xsl:call-template name="attach-id"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>


  <xsl:template match="d:varlistentry/d:term">
    <td class="varlist-term">
      <p>
        <span class="term">
          <xsl:apply-templates/></span>
      </p>
    </td>
  </xsl:template>


  <xsl:template match="d:varlistentry/d:listitem">
    <td class="varlist-item">
      <xsl:apply-templates/>
    </td>
  </xsl:template>


  <xsl:template match="d:programlisting">
    <pre class="programlisting">
      <xsl:call-template name="attach-id"/>
      <xsl:if test="@language">
        <xsl:comment expand-text="yes">language: {@language}</xsl:comment>
      </xsl:if>
      <xsl:apply-templates/>
    </pre>
  </xsl:template>


  <xsl:template match="d:title">
    <!-- because of browser bugs, we want to avoid emitting an empty tag
         for titles that have no content -->
    <xsl:if test="normalize-space(.)">
      <p class="title">
        <xsl:apply-templates/>
      </p>
    </xsl:if>
  </xsl:template>


  <!-- All these are titled in "labeled-title" mode -->
  <xsl:template match="d:figure/d:title | d:table/d:title | d:note/d:title |
    d:orderedlist/d:title | d:itemizedlist/d:title"/>


  <xsl:template match="d:figure | d:table" mode="labeled-title">
    <p class="title">
      <xsl:apply-templates select="." mode="label-text"/>
      <xsl:for-each select="d:title">
        <xsl:text>: </xsl:text>
        <xsl:apply-templates/>
      </xsl:for-each>
    </p>
  </xsl:template>
 
 
  <xsl:template match="d:orderedlist | d:itemizedlist" mode="labeled-title">
    <xsl:for-each select="d:title">
      <p class="title">
        <xsl:apply-templates/>
      </p>
    </xsl:for-each>
  </xsl:template>
 
 
  <xsl:template match="d:note" mode="labeled-title">
    <h3 class="title">
      <xsl:apply-templates select="." mode="label-text"/>
      <xsl:for-each select="d:title">
        <xsl:text>: </xsl:text>
        <xsl:apply-templates/>
      </xsl:for-each>
    </h3>
  </xsl:template>


  <xsl:template match="d:para">
    <p>
      <xsl:call-template name="attach-id"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>


  <!-- inline elements -->

  <xsl:template match="d:code">
    <code class="code">
      <xsl:apply-templates/>
    </code>
  </xsl:template>


  <xsl:template match="d:email">
    <code class="email">
      <xsl:text>&lt;</xsl:text>
      <a class="email" href="mailto:{.}">
        <xsl:apply-templates/>
      </a>
      <xsl:text>&gt;</xsl:text>
    </code>
  </xsl:template>

  <xsl:template match="d:uri">
    <xsl:text>ORCID ID: </xsl:text>
    <a href="{.}" class="orcid">
      <xsl:apply-templates />
    </a>
  </xsl:template>

  
  <xsl:template match="d:emphasis">
    <span class="ital">
      <xsl:for-each select="@role">
        <xsl:attribute name="class">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="d:quote">
    <q>
      <xsl:apply-templates/>
    </q>  
  </xsl:template>


  <xsl:template match="d:footnote">
    <xsl:param name="primary" select="true()"/>
    <!-- $primary is passed in as false when we process
         a footnote by virtue of an xref to it, instead
         of on its own -->
    <xsl:variable name="id">
      <xsl:apply-templates select="." mode="id"/>
    </xsl:variable>
    <sup class="fn-label">
      <a href="#{$id}" class="footnoteref">
        <xsl:if test="$primary">
          <!-- the primary occurrence gets an ID so the footnote
          can link back here -->
          <xsl:attribute name="id">
            <xsl:value-of select="$id"/>
            <xsl:text>-ref</xsl:text>
          </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="." mode="label-text"/>
      </a>
    </sup>
  </xsl:template>


  <xsl:template match="d:subscript">
    <sub>
      <xsl:apply-templates/>
    </sub>
  </xsl:template>


  <xsl:template match="d:superscript">
    <sup>
      <xsl:apply-templates/>
    </sup>
  </xsl:template>


  <xsl:template match="d:trademark">
    <xsl:apply-templates select="@class[.='copyright']"/>
    <span class="trademark">
      <xsl:apply-templates/>
    </span>
    <xsl:apply-templates select="@class[not(.='copyright')]"/>
    <xsl:if test="not(@class)">
      <xsl:text>&#x2122;</xsl:text>
    </xsl:if>
  </xsl:template>


  <!-- trademark class (copyright | registered | service | trade) -->
                         
  <xsl:template match="d:trademark/@class[.='copyright']">
    <xsl:text>&#xa9;&#xa0;</xsl:text>
  </xsl:template>
  
  <xsl:template match="d:trademark/@class[.='registered']">
    <xsl:text>&#xae;</xsl:text>
  </xsl:template>
  
  <xsl:template match="d:trademark/@class[.='service']">
    <xsl:text>&#x2120;</xsl:text>
  </xsl:template>
  
  <xsl:template match="d:trademark/@class[.='trade']">
    <xsl:text>&#x2122;</xsl:text>
  </xsl:template>


  <xsl:template match="d:citation">
    <xsl:apply-templates/>
    <xsl:if test="not(normalize-space(.))">
      <xsl:call-template name="runtime-warning">
          <xsl:with-param name="message">
            <xsl:text>citation has neither @linkend nor content</xsl:text>
          </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template match="d:citation[@linkend]">
    <xsl:variable name="target"
      select="key('element-by-id',@linkend)/self::d:bibliomixed"/>
    <xsl:choose>
      <xsl:when test="$target">
        <xsl:apply-templates select="$target" mode="xref">
          <xsl:with-param name="xref-id">
            <xsl:apply-templates select="." mode="id"/>
          </xsl:with-param>
          <xsl:with-param name="text-contents">
            <xsl:apply-templates/>
            <xsl:if test="not(normalize-space(.))">
              <xsl:apply-templates select="$target" mode="label-text"/>
            </xsl:if>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="runtime-warning">
          <xsl:with-param name="message">
            <xsl:text>citation with @linkend </xsl:text>
            <xsl:value-of select="@linkend"/>
            <xsl:text> must point to bibliomixed</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
  <xsl:template match="d:link[@xlink:href]">
    <a href="{@xlink:href}" class="link">
      <xsl:apply-templates select="@xlink:title"/>
      <xsl:apply-templates/>
      <xsl:if test="not(normalize-space(.))">
        <xsl:value-of select="normalize-space(@xlink:href)"/>
      </xsl:if>      
    </a>
  </xsl:template>


  <xsl:template match="d:link">
    <a href="#{@linkend}" class="xref">
      <xsl:apply-templates select="@xlink:title"/>
      <xsl:if test="not(@linkend)">
        <xsl:attribute name="class">link</xsl:attribute>
        <xsl:attribute name="target">_new</xsl:attribute>
        <xsl:attribute name="href">
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if test="not(normalize-space(.))">
        <xsl:call-template name="runtime-warning">
          <xsl:with-param name="message">
            <xsl:text>link to internal resource may not be empty; provide content</xsl:text>
            <xsl:text> or use xref for internal cross-reference</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </a>
  </xsl:template>


  <xsl:template match="@xlink:title">
    <xsl:attribute name="title">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
 <!-- xyxy 20170202 trg:  Per new Crossref guidelines, a document should 
 display the entire DOI URL (including "https://doi.org/") rather than 
 just the DOI, e.g., "https://doi.org/10.1002/aris.2009.1440430111" rather 
 than "10.1002/aris.2009.1440430111".  (Note that the URL now uses "https" 
 and no longer includes "dx".)  BUT CrossRef metadata load files 
 apparently still want only the DOI (not the full DOI URL) at least for 
 new DOIs being submitted, though possibly for citation DOIs as well.  
 Accordingly, in addition to generating the full URL for the link (via 
 @href), the full URL needs to be built for display in the citation 
 (rather than showing simply the DOI itself).  The paper's XML file will 
 still contain only the DOI, so it can be pulled for use in our CrossRef 
 metadata load submission file.  -->
<xsl:template match="d:biblioid[@class='doi']">
    <a href="https://doi.org/{.}" class="doi">
     <xsl:text>https://doi.org/</xsl:text> 
      <xsl:apply-templates/> 
    </a>
</xsl:template>

<!-- old 
<xsl:template match="d:biblioid[@class='doi']">
    <a href="http://dx.doi.org/{.}" class="doi" target="_new">
      <xsl:apply-templates/>
    </a>
</xsl:template>
-->

  <xsl:template match="d:biblioid[(@class = 'other') and (@otherclass = 'orcid')]">
    <a href="https://orcid.org/{.}" class="orcid">
      <xsl:apply-templates/> 
    </a>
  </xsl:template>
  
<!-- xyxy 20170202 trg:  The following appears to be a outdated 
template, presumably for use if "biblioid" did not include a 
@class attribute.  The current DTD (v1.3) requires the @class 
attribute, and only one value is permitted ("doi"); moreover, it 
would appear that ALL papers irrespective of conference year now 
validate against the current DTD version.  However, for safety, 
I am leaving this template as is. -->
<!--* 20200706 liam: dtd was changed (1.4) to add "other" but this template
    * is still not needed for documents valid to dtd 1.3 or later.
    *-->
 <xsl:template match="d:biblioid">
    <span class="biblioid">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="d:xref">
    <xsl:variable name="target"
      select="key('element-by-id',@linkend)"/>
    <xsl:apply-templates select="$target" mode="xref">
      <xsl:with-param name="xref-id">
        <xsl:apply-templates select="." mode="id"/>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  

  <!-- utility templates and modes -->


  <xsl:template match="d:inlinemediaobject">
    <xsl:variable name="id">
      <xsl:apply-templates select="." mode="id"/>
    </xsl:variable>
    <span class="inlinemediaobject" id="{$id}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>


  <xsl:template match="d:imageobject">
    <xsl:apply-templates/>
  </xsl:template>

  <!--* alt elements are handled by the b:get-alt-tet(0 function *-->
  <xsl:template match="d:alt" />

  <xsl:template match="d:imagedata">
    <img alt="{b:get-alt-text(.)}" src="{@fileref}">
      <!-- XHTML5/EPUB specifies that width attribute must be an integer, 
        trap here and remove non-numbers -->
      <xsl:choose>
        <xsl:when test="not(@width)" />

        <xsl:when test="matches(@width, '^\s*\d+\s*$')">
          <!--* Liam: you can't just get rid of % or cm,
              * and leave the unconverted number as 10cm
              * is very different from 10px, so use CSS
              * if there is a unit, and a width attribute otherwise:
              *-->
          <xsl:attribute name="width" select="@width" />
        </xsl:when>

        <!--* ignore width attributes with multiple CSS properties or tags
             * in them, not that we really expect malicious content....
             *-->
        <xsl:when test="matches(@width, '[;&gt;&lt;]')" />

        <xsl:otherwise>
          <!--* use CSS for e.g. width: 10cm *-->
          <xsl:attribute name="style" select="'width: ' || @width" />
        </xsl:otherwise>

      </xsl:choose>
    </img>
  </xsl:template>

  <!--* textobject: A wrapper for a text description of an object and
      * its associated meta-information
      *-->

  <!--* If we have one or more children, we should
      * make an image description.
      *
      * Users greatly prefer image descriptions in the same file,
      * so that's what has been done.
      *
      * Liam
      *-->
  <xsl:template match="d:textobject">
    <xsl:variable name="id" as="xs:string?">
      <xsl:apply-templates select=".." mode="id"/>
    </xsl:variable>
    <xsl:if test="$id">
      <!--* We may want to supply an SVG icon, or a font,
          * for information sign; Unicode has ℹ but
          * not sure about portability.
          *-->
      <xsl:choose>
        <xsl:when test="../self::d:inlinemediaobject and node()">
	  <!--* U+2139 INFORMATION SOURCE
	      * should be read out loud as Information
	      *-->
          <a class="smallinfo-inlinemediainfo" href="#description-for-{$id}">&#x2139;</a>
        </xsl:when>
        <xsl:when test="../self::d:mediaobject and node()">
	  <details class="image-description">
	    <summary>Image description</summary>
	    <xsl:apply-templates select="node()" />
	  </details>
        </xsl:when>
        <xsl:otherwise>
          <!--* no link to image description wanted *-->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="d:mathphrase">
    <span class="mathphrase">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="d:phrase[@role = 'emphasis']">
    <i class="emphasis">
      <xsl:apply-templates/>
    </i>
  </xsl:template>

  <xsl:template match="d:phrase">
    <span class="{ (@role, 'phrase')[1] }">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template name="footnotes">
    <xsl:if test="//d:footnote">
    <div class="footnotes">
      <br/>
      <hr width="100" align="left"/>
      <xsl:apply-templates select="//d:footnote" mode="footnote"/>
    </div>
    </xsl:if>    
  </xsl:template>


  <xsl:template match="d:footnote" mode="footnote">
    <xsl:variable name="id">
      <xsl:apply-templates select="." mode="id"/>
    </xsl:variable>
    <div id="{$id}" class="footnote">
      <p>
        <sup class="fn-label">
          <a href="#{$id}-ref" class="footnoteref">      
            <xsl:apply-templates select="." mode="label-text"/>
          </a>
        </sup>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="d:para[1]/node()"/>
      </p>
      <xsl:apply-templates select="d:para[position() &gt; 1]"/>
    </div>
  </xsl:template>


  <xsl:template match="*" mode="xref">
    <xsl:param name="text-contents">
      <xsl:apply-templates/>
    </xsl:param>
    <xsl:call-template name="runtime-warning">
      <xsl:with-param name="message">
        <xsl:text>Sorry: xref not supported to </xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:text>[@xml:id='</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>'] without @xreflabel</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="*[@xreflabel]" mode="xref" priority="99">
    <!-- this template overrides the template that would
         otherwise match a cross-reference target to
         generate content for the link -->
    <xsl:param name="text-contents">
      <xsl:value-of select="@xreflabel"/>
    </xsl:param>
    <xsl:param name="xref-id" select="'xxx'"/>
    <a class="xref" href="#{@xml:id}" id="{$xref-id}">
       <xsl:copy-of select="$text-contents"/>
    </a>
  </xsl:template>


  <xsl:template match="d:footnote" mode="xref">
    <xsl:param name="text-contents"/>
    <xsl:apply-templates select=".">
      <xsl:with-param name="primary" select="false()"/>
    </xsl:apply-templates>
  </xsl:template>


  <xsl:template match="d:bibliomixed" mode="xref">
    <xsl:param name="text-contents">
      <xsl:apply-templates select="." mode="label-text"/>
    </xsl:param>
    <xsl:param name="xref-id" select="'xxx'"/>
    <xsl:variable name="cite-id">
      <xsl:apply-templates select="." mode="id"/>
    </xsl:variable>
    <a class="xlink" href="#{$cite-id}" id="{$xref-id}">
      <xsl:copy-of select="$text-contents"/>
    </a>
  </xsl:template>

  <xsl:template match="d:section | d:appendix |
    d:figure | d:equation | d:table" mode="xref">
    <xsl:param name="text-contents">
      <xsl:apply-templates select="." mode="label-text"/>
    </xsl:param>
    <a class="xref" href="#{@xml:id}">
      <xsl:for-each select="d:title">
        <xsl:attribute name="title">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:copy-of select="$text-contents"/>
    </a>
  </xsl:template>


  <xsl:template match="d:orderedlist/d:listitem" mode="xref">
    <xsl:param name="text-contents">
      <xsl:number level="multiple" format="1.1"/>
    </xsl:param>
    <a class="xref" href="#{@xml:id}">
      <xsl:copy-of select="$text-contents"/>
    </a>
  </xsl:template>


  <xsl:template match="d:section//d:para" mode="xref">
    <xsl:param name="text-contents">
      <xsl:text>in </xsl:text>
      <xsl:apply-templates select="ancestor::d:section[1]" mode="label-text"/>
    </xsl:param>
    <a class="xref" href="#{@xml:id}">
      <xsl:copy-of select="$text-contents"/>
    </a>
  </xsl:template>
 
 
  <xsl:template match="d:itemizedlist | d:orderedlist | d:variablelist" mode="xref">
    <xsl:param name="text-contents">
      <xsl:apply-templates select="." mode="label-text"/>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="normalize-space(d:title)">
        <a class="xref" href="#{@xml:id}">
          <xsl:copy-of select="$text-contents"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="runtime-warning">
          <xsl:with-param name="message">
            <xsl:text>Can't create xref to </xsl:text>
            <xsl:value-of select="local-name(.)"/>
            <xsl:text>[@xml:id='</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>']: it has no title or @xreflabel</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

  <xsl:template match="*[@xml:id]" mode="id">
    <xsl:value-of select="@xml:id"/>
  </xsl:template>


  <xsl:template match="*" mode="id">
    <!-- matches a footnote that doesn't have its own ID -->
    <xsl:value-of select="generate-id(.)"/>
  </xsl:template>

  <xsl:template name="attach-id">
    <xsl:variable name="id">
      <xsl:apply-templates select="." mode="id"/>
    </xsl:variable>
    <xsl:if test="normalize-space($id)">
      <xsl:attribute name="id">
        <xsl:value-of select="$id"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[normalize-space(@xreflabel)]" mode="label-text" priority="99">
    <!-- this template overrides the template that would
      otherwise match to generate label content for the link -->
    <xsl:value-of select="normalize-space(@xreflabel)"/>
  </xsl:template>

  <xsl:template match="d:section" mode="label-text">
    <xsl:text>section</xsl:text>
    <xsl:for-each select="d:title">
      <xsl:text> &#x201c;</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&#x201d;</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="d:appendix" mode="label-text">
    <xsl:text>Appendix </xsl:text>
    <xsl:number level="any" format="A"/>
  </xsl:template>

  <xsl:template match="d:itemizedlist | d:orderedlist | d:variablelist" mode="label-text">
    <xsl:for-each select="d:title">
      <xsl:text>&#x201c;</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&#x201d;</xsl:text>
    </xsl:for-each>
    <xsl:if test="not(d:title)">
      <xsl:call-template name="runtime-warning">
        <xsl:with-param name="message">
        <xsl:text>title needed to label </xsl:text>
        <xsl:value-of select="local-name()"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="d:footnote" mode="label-text">
    <xsl:text>[</xsl:text>
    <xsl:number level="any"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="d:note" mode="label-text">
    <xsl:text>Note</xsl:text>
  </xsl:template>

  <xsl:template match="d:equation" mode="label-text">
    <xsl:text>Equation&#xA0;</xsl:text>
    <xsl:number level="any" format="(a)"/>
  </xsl:template>

  <xsl:template match="d:figure" mode="label-text">
    <xsl:text>Figure&#xA0;</xsl:text>
    <xsl:number level="any"/>
  </xsl:template>

  <xsl:template match="d:table" mode="label-text">
    <xsl:text>Table&#xA0;</xsl:text>
    <xsl:number level="any" format="I"/>
  </xsl:template>
 
  <xsl:template match="d:bibliomixed" mode="label-text">
    <xsl:value-of select="normalize-space(@xml:id)"/>
  </xsl:template>
 
  <xsl:template match="*" mode="text-only">
    <xsl:apply-templates mode="text-only"/>
  </xsl:template>
  
  <xsl:template match="d:footnote" mode="text-only"/>

  <xsl:template match="span|sub|a|q|code" expand-text="yes">
    <!--* HTML elements to copy unchanged *-->
    <xsl:copy-of select="." />
    <!--*
        * Uncomment the message to see where the HTML is:
    <xsl:message>{name()} in {
    string-join(ancestor::* ! name(.), ' in ')
    } in balisage-html
    </xsl:message>
    *-->
  </xsl:template>

  <xsl:function name="b:id-for" as="xs:string?">
    <xsl:param  name="context" as="element(*)" />
    <xsl:apply-templates select="$context" mode="id"/>
  </xsl:function>
  
  <xsl:template name="runtime-warning">
    <xsl:param name="message">RUNTIME WARNING</xsl:param>
    <span class="runtime-warning">
      <xsl:copy-of select="$message"/>
    </span>
    <xsl:message>
      <xsl:value-of select="$message"/>
    </xsl:message>
  </xsl:template>
  
  
</xsl:stylesheet>
