<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    xpath-default-namespace="http://docbook.org/ns/docbook"
    xmlns="http://docbook.org/ns/docbook"
    version="3.0">
    
    
    <!--Simple docbook5 to balisage conversion from pandoc-->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">href="balisage-1-5.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
        <xsl:next-match/>
    </xsl:template>
    
    
    <xsl:template match="article/@version">
        <xsl:attribute name="version">5.0-subset Balisage-1.5</xsl:attribute>
    </xsl:template>
    
    
    <xsl:template match="info">
        <xsl:apply-templates select="title"/>
        <xsl:copy>
            <xsl:apply-templates select="*[not(self::title)]"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="authorgroup">
        <abstract>
            <para>TODO</para>
        </abstract>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="author">
        <xsl:copy>
            <xsl:apply-templates/>
            <personblurb>
                <para>TODO</para>
            </personblurb>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="para[count(*) = 1][inlinemediaobject]">
        <xsl:variable name="text" select="replace(string-join(text()),'\s','')" as="xs:string?"/>
        <xsl:variable name="widthRex">\{width=(\d+%)\}</xsl:variable>
        <xsl:variable name="width" select="replace($text, $widthRex, '$1')" as="xs:string?"/>
        <xsl:apply-templates select="*">
            <xsl:with-param name="width" tunnel="yes" select="$width"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="inlinemediaobject">
        <figure>
            <xsl:apply-templates select="imageobject//title"/>
            <mediaobject>
                <xsl:apply-templates select="imageobject/imagedata"/>
            </mediaobject>
        </figure>
    </xsl:template>
    
    <xsl:template match="imagedata">
        <xsl:param name="width" tunnel="yes" as="xs:string?"/>
        <xsl:copy>
            <xsl:where-populated>
                <xsl:attribute name="width" select="$width"/>
            </xsl:where-populated>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="orderedlist/@spacing"/>
    
    <xsl:template match="informaltable">
        <table>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    
    <xsl:template match="tgroup">
        <xsl:where-populated>
            <colgroup>
                <xsl:apply-templates select="colspec"/>
            </colgroup>
        </xsl:where-populated>
        <xsl:apply-templates select="*[not(self::colspec)]"/>
    </xsl:template>
    
    <xsl:template match="colspec">
        <col>
            <xsl:apply-templates select="@*|node()"/>
        </col>
    </xsl:template>
    
    <xsl:template match="row">
        <tr>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    
    <xsl:template match="row/entry">
        <td>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
    
    <xsl:template match="literal">
        <code>
            <xsl:apply-templates/>
        </code>
    </xsl:template>
    
    <!--Handling for footnotes-->
    <xsl:template match="text()">
        <xsl:analyze-string select="." regex="\[\^\d+:([^\\]+)\]">
            <xsl:matching-substring>
                <footnote>
                    <para>
                        <xsl:value-of select="regex-group(1)"/>
                    </para>
                </footnote>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
</xsl:stylesheet>