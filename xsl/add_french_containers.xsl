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
            <xd:p><xd:b>Created on:</xd:b> Sept 20, 2023</xd:p>
            <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
            <xd:p>This is a quick utility stylesheet for adding elements ready 
            to incorporate block-by-block French translations into a page that 
            doesn't have them yet.</xd:p>
        </xd:desc>
    </xd:doc>
   
    <xd:doc>
        <xd:desc>Output is HTML.</xd:desc>
    </xd:doc>
    <xsl:output method="xhtml" html-version="5" indent="yes" encoding="UTF-8" normalization-form="NFC" 
        omit-xml-declaration="yes" include-content-type="no"/>
    
    <xd:doc>
        <xd:desc>Mostly this is an identity transform.</xd:desc>
    </xd:doc>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xd:doc>
        <xd:desc>The meat template.</xd:desc>
    </xd:doc>
    <xsl:template match="*[self::h1 or self::h2 or self::h3 or self::p or self::li][not(@lang)]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="lang" select="'en'"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="lang" select="'fr'"/>
            <xsl:comment>[French here]</xsl:comment>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>