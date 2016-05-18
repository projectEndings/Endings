<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
    xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
    xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
    xmlns:presentation="urn:oasis:names:tc:opendocument:xmlns:presentation:1.0"
    xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
    xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
    xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
    xmlns:math="http://www.w3.org/1998/Math/MathML"
    xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
    xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
    xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
    xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer"
    xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events"
    xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rpt="http://openoffice.org/2005/report"
    xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:grddl="http://www.w3.org/2003/g/data-view#" xmlns:tableooo="http://openoffice.org/2009/table"
    xmlns:drawooo="http://openoffice.org/2010/draw"
    xmlns:calcext="urn:org:documentfoundation:names:experimental:calc:xmlns:calcext:1.0"
    xmlns:loext="urn:org:documentfoundation:names:experimental:office:xmlns:loext:1.0"
    xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0"
    xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0"
    xmlns:css3t="http://www.w3.org/TR/css3-text/"
    exclude-result-prefixes="xs"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 18, 2016</xd:p>
            <xd:p><xd:b>Author:</xd:b> jtakeda</xd:p>
            <xd:p>This transformation splits out worklog files based off
                of which project is mentioned in the cell, thus allowing for multiple worklogs
                to be produced for each project.</xd:p>
        </xd:desc>
        
    </xd:doc>
    <xsl:output encoding="UTF-8" method="text"/>
    
    <xsl:variable name="docs" select="collection('../admin/worklogs/?select=*_expand.fods')"/>
    

    
    <xsl:template match="/">
      <xsl:for-each select="$docs">
          <xsl:variable name="outputUri" select="document-uri(/)"/>
          <xsl:variable name="fName" select="tokenize($outputUri, '[\\/]')[last()]"/>
          <xsl:variable name="person" select="substring-before($fName,'_')"/>
          <xsl:variable name="docPath" select="concat('../admin/worklogs/',$person,'_by_project/',$person)"/>
          <xsl:variable name="doc" select="."/>
          <xsl:variable name="header">
              <xsl:text>&quot;Date&quot;,&quot;Day of the Week&quot;,&quot;Time&quot;,&quot;Hours worked&quot;,&quot;Description&quot;</xsl:text>
          </xsl:variable>
          
          <xsl:result-document href="{$docPath}_endings_log.csv">
              <xsl:message>Creating endings log</xsl:message>
              <xsl:copy-of select="$header"/>
              <xsl:for-each select="$doc//table:table/table:table-row[position() gt 1][string-length(normalize-space(table:table-cell[5])) gt 0]">
                  <xsl:text> &#xa;</xsl:text><xsl:apply-templates select="table:table-cell[position() lt 6]"/>"/>
              </xsl:for-each>
          </xsl:result-document>
          
          <xsl:result-document href="{$docPath}_graves_log.csv">
              <xsl:message>Creating graves log</xsl:message>
              <xsl:copy-of select="$header"/>
              <xsl:for-each select="$doc//table:table/table:table-row[position() gt 1][string-length(normalize-space(table:table-cell[6])) gt 0]">
                  <xsl:text> &#xa;</xsl:text><xsl:apply-templates select="table:table-cell[position() lt 5 or position()=6]"/>
              </xsl:for-each>
          </xsl:result-document>
          
          <xsl:result-document href="{$docPath}_mariage_log.csv">
              <xsl:message>Creating mariage log</xsl:message>
              <xsl:copy-of select="$header"/>
              <xsl:for-each select="$doc//table:table/table:table-row[position() gt 1][string-length(normalize-space(table:table-cell[7])) gt 0]">
                  <xsl:text> &#xa;</xsl:text><xsl:apply-templates select="table:table-cell[position() lt 5 or position()=7]"/>
              </xsl:for-each>
          </xsl:result-document>
          
          <xsl:result-document href="{$docPath}_moeml_log.csv">
              <xsl:message>Creating moeml log</xsl:message>
              <xsl:copy-of select="$header"/>
              <xsl:for-each select="$doc//table:table/table:table-row[position() gt 1][string-length(normalize-space(table:table-cell[8])) gt 0]">
                  <xsl:text> &#xa;</xsl:text><xsl:apply-templates select="table:table-cell[position() lt 5 or position()=8]"/>
              </xsl:for-each>
          </xsl:result-document>
          
          <xsl:result-document href="{$docPath}_moses_log.csv">
              <xsl:message>Creating moses log</xsl:message>
              <xsl:copy-of select="$header"/>
              <xsl:for-each select="$doc//table:table/table:table-row[position() gt 1][string-length(normalize-space(table:table-cell[9])) gt 0]">
                  <xsl:text> &#xa;</xsl:text><xsl:apply-templates select="table:table-cell[position() lt 5 or position()=9]"/>
              </xsl:for-each>
          </xsl:result-document>

      </xsl:for-each>
    </xsl:template>
    
   <!-- <xsl:template name="createLog">
        <xsl:param name="doc"/>
        <xsl:param name="docPath"/>
        
          <xsl:result-document href="{$docPath}_endings_log.csv">
          <xsl:apply-templates select="$doc//table:table/table:table-row[position() gt 1][string-length(normalize-space(table:table-cell[4])) gt 0]"/>
          </xsl:result-document>
        
        <xsl:result-document href="{$docPath}_graves_log.csv">
            <xsl:apply-templates select="$doc//table:table/table:table-row[position() gt 1][string-length(normalize-space(table:table-cell[5])) gt 0]"/>
        </xsl:result-document>
        
        <xsl:result-document href="{$docPath}_mariage_log.csv">
            <xsl:apply-templates select="$doc//table:table/table:table-row[position() gt 1][string-length(normalize-space(table:table-cell[6])) gt 0]"/>
        </xsl:result-document>
        
        <xsl:result-document href="{$docPath}_moeml_log.csv">
            <xsl:apply-templates select="$doc//table:table/table:table-row[position() gt 1][string-length(normalize-space(table:table-cell[7])) gt 0]"/>
        </xsl:result-document>
        
        <xsl:result-document href="{$docPath}_moses_log.csv">
            <xsl:apply-templates select="$doc//table:table/table:table-row[position() gt 1][string-length(normalize-space(table:table-cell[8])) gt 0]"/>
        </xsl:result-document>
    </xsl:template>-->
    
    <xsl:template match="table:table-row">
       <xsl:text> &#xa;</xsl:text><xsl:apply-templates select="table:table-cell"/><xsl:text>&#xa;</xsl:text>
    </xsl:template>
    
    <xsl:template match="table:table-cell">
        <xsl:value-of select="concat('&quot;',text:p,'&quot;,')"/>
    </xsl:template>

    
</xsl:stylesheet>