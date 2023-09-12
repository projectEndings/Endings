<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Sep 12, 2023</xd:p>
            <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
            <xd:p>This is a utility stylesheet to add lang attributes to the
            content pages to aid in translation.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" encoding="UTF-8" normalization-form="NFC" exclude-result-prefixes="#all"
    indent="yes"/>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:mode name="french" on-no-match="shallow-copy"/>
    
    <xsl:template match="article/*[not(self::main) and not(@lang)] | main/*[not(@lang)]">
        <xsl:if test="@lang or following-sibling::*[@lang]">
            <xsl:message terminate="yes">THIS FILE ALREADY HAS CONTENT DISTINGUISHED BY LANGUAGE. TERMINATING.</xsl:message>
        </xsl:if>
        <xsl:copy>
            <xsl:attribute name="lang" select="'en'"/>
            <xsl:apply-templates/>
        </xsl:copy>
        <xsl:copy>
            <xsl:attribute name="lang" select="'fr'"/>
            <xsl:apply-templates select="@*|node()" mode="french"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[string-length(normalize-space(.)) gt 0]" mode="french">
        <xsl:sequence select="'[À venir...]'"/>
    </xsl:template>
    
</xsl:stylesheet>