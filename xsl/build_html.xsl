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
  
  <xsl:param name="today" as="xs:string"/>
  
  <xsl:output method="xhtml" html-version="5" indent="yes" encoding="UTF-8" normalization-form="NFC"/>
   
  <!-- Main navbar div. -->
  <xsl:template match="div[@id='main-navbar']">
    <div class="collapse navbar-collapse" id="main-navbar">
      <ul class="nav navbar-nav navbar-right">
        <li>
          <a href="about.html">About</a>
        </li>
        <li>
          <a href="principles.html">Principles</a>
        </li>
        <li>
          <a href="accomplishments.html">Accomplishments &amp; Outcomes</a>
        </li>
        <li>
          <a href="symposium.html">Symposium</a>
        </li>
        <li>
          <a href="https://github.com/projectEndings/">Code</a>
        </li>
        <li>
          <a href="projects.html">Projects</a>
        </li>
        <li>
          <a href="people.html">People</a>
        </li>
        <li class="navlinks-container">
          <a class="navlinks-parent" href="javascript:void(0)">Resources</a>
          <div class="navlinks-children">
            <a href="papers.html">Conference Papers</a>
            <a href="articles.html">Journal Articles</a>
            <a href="software.html">Software</a>
            <a href="resources.html">Resources</a>
          </div>
        </li>
        <li>
          <a href="blog.html">News</a>
        </li>
        <li>
          <a href="contact.html">Contact</a>
        </li>
      </ul>
    </div>
  </xsl:template>
  
  <xsl:template match="footer">
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
              2<xsl:value-of select="$today"/>
              &#160;&#x2022;&#160;
              <a href="index.html">endings.uvic.ca</a>
            </p>
            <!-- Please don't remove this, keep my open source work credited :) -->
            <p class="theme-by text-muted">
              Theme by
              <a href="https://deanattali.com/beautiful-jekyll/">beautiful-jekyll</a>
            </p>
          </div>
        </div>
      </div>
    </footer>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>  
  
</xsl:stylesheet>