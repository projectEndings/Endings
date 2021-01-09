<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Jan 7, 2021</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>Builds the HTML site.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:variable name="today" as="xs:string" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  
  <xsl:output method="xhtml" html-version="5" indent="yes" encoding="UTF-8" normalization-form="NFC" omit-xml-declaration="yes"/>
  
  <!-- This is the main menu. Edit here to change menus on all pages. -->
  <xsl:variable name="mainMenu" as="element(nav)">
    <nav class="navbar navbar-default navbar-fixed-top navbar-custom"> 
      <script>
        function showHideMobileNav(sender){
        let nav = document.querySelector('nav'), div = document.querySelector('#main-navbar');
          nav.classList.toggle('top-nav-expanded');
          div.classList.toggle('in');
          div.getAttribute('aria-expanded')? div.removeAttribute('aria-expanded') : div.setAttribute('aria-expanded', 'true');
          sender.getAttribute('aria-expanded')? sender.removeAttribute('aria-expanded') : sender.setAttribute('aria-expanded', 'true');
        }
      </script>
      <div class="container-fluid"> 
        <div class="navbar-header"> <button onclick="showHideMobileNav(this)" type="button" class="navbar-toggle" data-toggle="collapse" data-target="#main-navbar"> <span class="sr-only">Toggle navigation</span> <span class="icon-bar"></span> <span class="icon-bar"></span> <span class="icon-bar"></span> </button> <a class="navbar-brand navbar-brand-logo" href="index.html"><img src="img/endingsProjectLogo4.png" alt="Endings project logo"/></a> 
        </div> 
        <xsl:comment>Do not edit directly. Make changes in the XSLT.</xsl:comment>
        <div class="collapse navbar-collapse" id="main-navbar">
          <ul class="nav navbar-nav navbar-right">
            <li><a href="about.html">About</a></li>
            <li><a href="principles.html">Principles</a></li>
            <li><a href="accomplishments.html">Accomplishments &amp; Outcomes</a></li>
            <li><a href="symposium.html">Symposium</a></li>
            <li><a href="https://github.com/projectEndings/">Code</a></li>
            <li><a href="projects.html">Projects</a></li>
            <li><a href="people.html">People</a></li>
            <li class="navlinks-container"><a class="navlinks-parent" onclick="this.parentNode.classList.toggle('show-children')" href="javascript:void(0)">Resources</a><div class="navlinks-children"><a href="papers.html">Conference Papers</a><a href="articles.html">Journal Articles</a><a href="software.html">Software</a><a href="resources.html">Resources</a></div>
            </li>
            <li><a href="blog.html">News</a></li>
            <li><a href="contact.html">Contact</a></li>
          </ul>
        </div> 
      </div> 
    </nav> 
  </xsl:variable>
  
  <xsl:variable name="footer" as="element(footer)">
    <footer>
      <div class="container beautiful-jekyll-footer">
        <div class="row">
          <div class="col-lg-8 col-lg-offset-2 col-md-10 col-md-offset-1">
            <ul class="list-inline text-center footer-links"><li><a href="mailto:mholmes@uvic.ca" title="Email me"><span class="fa-stack fa-lg" aria-hidden="true">
              <i class="fa fa-circle fa-stack-2x"></i>
              <i class="fa fa-envelope fa-stack-1x fa-inverse"></i>
            </span>
              <span class="sr-only">Email me</span>
            </a>
            </li><li><a href="https://github.com/projectEndings" title="GitHub"><span class="fa-stack fa-lg" aria-hidden="true">
              <i class="fa fa-circle fa-stack-2x"></i>
              <i class="fa fa-github fa-stack-1x fa-inverse"></i>
            </span>
              <span class="sr-only">GitHub</span>
            </a>
            </li><li><a href="https://twitter.com/EndingsProject" title="Twitter"><span class="fa-stack fa-lg" aria-hidden="true">
              <i class="fa fa-circle fa-stack-2x"></i>
              <i class="fa fa-twitter fa-stack-1x fa-inverse"></i>
            </span>
              <span class="sr-only">Twitter</span>
            </a>
            </li></ul>
            <p class="copyright text-muted">
              The Endings Project Team
              &#160;&#x2022;&#160;
              <xsl:value-of select="$today"/>
              &#160;&#x2022;&#160;
              <a href="index.html">endings.uvic.ca</a>
            </p>
            <xsl:comment>Please don't remove this, keep my open source work credited :)</xsl:comment>
            <p class="theme-by text-muted">
              Theme by
              <a href="https://deanattali.com/beautiful-jekyll/">beautiful-jekyll</a>
            </p>
          </div>
        </div>
      </div>
    </footer>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:variable name="docName" as="xs:string" select="tokenize(document-uri(.), '/')[last()]"/>
    <xsl:message>Processing file <xsl:value-of select="$docName"/> on <xsl:value-of select="$today"/>. </xsl:message>
    <xsl:apply-templates>
      <xsl:with-param name="docName" select="$docName" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
   
  <!-- Main menu nav. -->
  <xsl:template match="nav[contains(@class, 'navbar')]">
    <xsl:copy select="$mainMenu">
      <xsl:apply-templates select="$mainMenu/@*"/>
    <xsl:comment>Do not edit directly. Make changes in the XSLT.</xsl:comment>
      <xsl:apply-templates select="$mainMenu/node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- We want to highlight the chosen menu item. -->
  <xsl:template match="a[ancestor::div[@id='main-navbar']]">
    <xsl:param tunnel="yes" name="docName" as="xs:string"/>
    <xsl:copy select=".">
      <xsl:apply-templates select="@*"/>
    <xsl:if test="@href = $docName">
      <xsl:attribute name="class" select="'current-page'"/>
    </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="footer">
    <xsl:copy>
      <xsl:apply-templates select="$footer/@*"/>
      <xsl:comment>Do not edit directly. Make changes in the XSLT.</xsl:comment>
      <xsl:apply-templates select="$footer/node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text()[normalize-space(.) = '']">
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>  
  
</xsl:stylesheet>