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
            <xd:p><xd:b>Created on:</xd:b> Aug 31, 2023</xd:p>
            <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
            <xd:p>This is a replacement for the original build process that
            generated a half-assed site from an old Jekyll collection. This
            builds a website from discrete content documents.</xd:p>
            <xd:p>This file runs on itself and loads the resources it needs.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>Project title</xd:desc>
    </xd:doc>
    <xsl:variable name="projTitle" as="xs:string" select="'The Endings Project'"/>
    
    <xd:doc>
        <xd:desc>We need to put the build date in the footer.</xd:desc>
    </xd:doc>
    <xsl:variable name="today" as="xs:string" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
   
    <xd:doc>
        <xd:desc>Output is HTML.</xd:desc>
    </xd:doc>
    <xsl:output method="xhtml" html-version="5" indent="yes" encoding="UTF-8" normalization-form="NFC" omit-xml-declaration="yes"/>
    
    <xd:doc>
        <xd:desc>Mostly this is an identity transform.</xd:desc>
    </xd:doc>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xd:doc>
        <xd:desc>Where are we?</xd:desc>
    </xd:doc>
    <xsl:param name="projDir" as="xs:string" select="'../'"/>
    
    <xd:doc>
        <xd:desc>Content page location.</xd:desc>
    </xd:doc>
    <xsl:param name="contentDir" as="xs:string" select="concat($projDir, 'pages/')"/>
    
    <xd:doc>
        <xd:desc>Site output location.</xd:desc>
    </xd:doc>
    <xsl:param name="outputDir" as="xs:string" select="concat($projDir, 'products/')"/>
    
    <xd:doc>
        <xd:desc>Template location.</xd:desc>
    </xd:doc>
    <xsl:param name="templateDir" as="xs:string" select="concat($projDir, 'site_templates/')"/>
    
    <xd:doc>
        <xd:desc>Main template used for all the pages.</xd:desc>
    </xd:doc>
    <xsl:param name="mainTemplate" as="document-node()" select="doc($templateDir || 'html_template.html')"/>
    
    <xd:doc>
        <xd:desc>The actual content docs.</xd:desc>
    </xd:doc>
    <xsl:param name="contentDocs" as="document-node()*" select="collection($contentDir || '?select=*.xml;recurse=yes')"/>
    
    <xd:doc>
        <xd:desc>Root template kicks off everything.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:message expand-text="yes">Processing {count($contentDocs)} content pages...</xsl:message>
        <xsl:for-each select="$contentDocs">
            <xsl:variable name="currDoc" as="document-node()" select="."/>
            <xsl:variable name="currDocId" as="xs:string" select="xs:string($currDoc/body/@id)"/>
            <xsl:message expand-text="yes">Processing {$currDocId}...</xsl:message>
            <xsl:apply-templates select="$mainTemplate/html">
                <xsl:with-param name="currDoc" as="document-node()" select="$currDoc" tunnel="yes"/>
                <xsl:with-param name="currDocId" as="xs:string" select="$currDocId" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Template matching the root html element.</xd:desc>
        <xd:param name="currDoc" as="document-node()">The source doc being built into an output page.</xd:param>
        <xd:param name="currDocId" as="xs:string">The id of the current document from its body element.</xd:param>
    </xd:doc>
    <xsl:template match="html">
        <xsl:param name="currDoc" as="document-node()" tunnel="yes"/>
        <xsl:param name="currDocId" as="xs:string" tunnel="yes"/>
        <xsl:message expand-text="yes">Creating {$outputDir}{$currDocId}.html...</xsl:message>
        <xsl:result-document href="{$outputDir}{$currDocId}.html">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:result-document>
    </xsl:template>
    
    <!-- *********** HEADER TEMPLATES *********************** -->
    <xd:doc>
        <xd:desc>The output page title comes from the content.</xd:desc>
    </xd:doc>
    <xsl:template match="head/title">
        <xsl:param name="currDoc" as="document-node()" tunnel="yes"/>
        <xsl:copy>
            <xsl:sequence select="$projTitle || ': '"/>
            <xsl:value-of select="$currDoc//h1"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Configure the metadata tag for the canonical location.</xd:desc>
    </xd:doc>
    <xsl:template match="link[@rel='canonical']">
        <xsl:param name="currDocId" as="xs:string" tunnel="yes"/>
        <xsl:copy>
            <xsl:copy-of select="@*[not(local-name() = 'href')]"/>
            <xsl:attribute name="href" select="$currDocId || '.html'"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Configure the metadata tag for the page title.</xd:desc>
    </xd:doc>
    <xsl:template match="meta[@property='og:title']">
        <xsl:param name="currDoc" as="document-node()" tunnel="yes"/>
        <xsl:copy>
            <xsl:copy-of select="@*[not(local-name() = 'content')]"/>
            <xsl:attribute name="content" select="$projTitle || ': ' || xs:string($currDoc//h1)"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- *********** NAV TEMPLATES *********************** -->
    <xd:doc>
        <xd:desc>Mark the currently-selected page in the menu.</xd:desc>
    </xd:doc>
    <xsl:template match="nav/descendant::a">
        <xsl:param name="currDocId" as="xs:string" tunnel="yes"/>
        <xsl:variable name="currDocLink" as="xs:string" select="$currDocId || '.html'"/>
        <xsl:choose>
            <xsl:when test="@href = $currDocLink">
                <xsl:copy>
                    <xsl:attribute name="class" select="'current-page'"/>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- *********** MAIN TEMPLATES *********************** -->
    
    <xd:doc>
        <xd:desc>This is where we complete the page header.</xd:desc>
    </xd:doc>
    <xsl:template match="h1">
        <xsl:param name="currDoc" as="document-node()" tunnel="yes"/>
        <xsl:sequence select="$currDoc//h1"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>This is where we complete the page subheader.</xd:desc>
    </xd:doc>
    <xsl:template match="h2">
        <xsl:param name="currDoc" as="document-node()" tunnel="yes"/>
        <xsl:sequence select="$currDoc//h2"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>This is where we inject the current document content into the page.</xd:desc>
    </xd:doc>
    <xsl:template match="main">
        <xsl:param name="currDoc" as="document-node()" tunnel="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="$currDoc//main/node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    
    <!-- *********** FOOTER TEMPLATES *********************** -->
    
    
    
    <!-- *********** ATTRIBUTE TEMPLATES *********************** -->
    
    <xd:doc>
        <xd:desc>Put the current doc id on the root element.</xd:desc>
    </xd:doc>
    <xsl:template match="html/@id">
        <xsl:param name="currDocId" as="xs:string" tunnel="yes"/>
        <xsl:attribute name="id" select="$currDocId"/>
    </xsl:template>
    
</xsl:stylesheet>