<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Nov 26, 2018</xd:p>
      <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
      <xd:p>This transformation tweaks various aspects of the
      Quandary output from source files in this folder in 
      order to fix various issues.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xd:doc>
    <xd:desc>Output is XML; some elements are special.</xd:desc>
  </xd:doc>
  <xsl:output method="xhtml" omit-xml-declaration="yes" html-version="5" encoding="UTF-8" normalization-form="NFC"/>
  
  <xd:doc>
    <xd:desc>Lower-case these name attributes for Dublin Core items.</xd:desc>
  </xd:doc>
  <xsl:template match="meta/@name">
    <xsl:attribute name="name" select="lower-case(.)"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Be careful with JavaScript.</xd:desc>
  </xd:doc>
  <xsl:template match="script">
    <xsl:copy>
      <xsl:value-of disable-output-escaping="yes" select="text()"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Get rid of nbsp entities where they might still be
    hanging about.</xd:desc>
  </xd:doc>
  <xsl:template match="*[not(self::script)]/text()">
    <xsl:value-of select="replace(., '&amp;nbsp;', '&#160;')"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Get rid of the old link element for Dublin Core.</xd:desc>
  </xd:doc>
  <xsl:template match="link[@rel='schema.DC']"/>
  
  <xd:doc>
    <xd:desc>Default identity transform.</xd:desc>
  </xd:doc>
  <xsl:template match="@*|node()" mode="#all" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>