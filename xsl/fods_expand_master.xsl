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
            <xd:p><xd:b>Created on:</xd:b> Oct 5, 2015</xd:p>
            <xd:p><xd:b>Author:</xd:b> jtakeda</xd:p>
            <xd:p>Based off of stylesheet by mholmes for the Landscapes of Injustice project.
                The purpose of this stylesheet is to expand a generic FODS file (a flat-file version of
                a ODS spreadsheet) to add empty cells where they're signalled by attribute values
                and to explicitly name style attributes when necessary. The result is much easier to process
                into other types of output.</xd:p>
        </xd:desc>
        
    </xd:doc>
   
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all"/>
   
    <xsl:variable name="docs" select="collection('../admin/worklogs/?select=*.fods')"/>
    
    <xsl:template match="/">
        <xsl:for-each select="$docs">
           <xsl:variable name="outputUri" select="document-uri(/)"/>
           <xsl:variable name="fName" select="tokenize($outputUri, '[\\/]')[last()]"/>
           <xsl:result-document href="../admin/worklogs/{substring-before($fName,'.')}_expand.fods" method="xml" encoding="UTF-8" normalization-form="NFC" indent="yes" exclude-result-prefixes="#all">
               <xsl:message>Expanding out <xsl:value-of select="count(//*[@table:number-columns-repeated])"/> cells in the FODS...</xsl:message>
            <xsl:variable name="firstPass" as="node()*">
                <xsl:apply-templates mode="expand"/>
            </xsl:variable>
            <xsl:apply-templates select="$firstPass" mode="style"/>
            <xsl:message>Adding style...</xsl:message>
            <xsl:message>Done!</xsl:message></xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    

    <!--Expand elements that say they should repeat in the attributes-->
    <xsl:template match="table:table-cell[@table:number-columns-repeated] | table:table-column[@table:number-columns-repeated]" exclude-result-prefixes="#all" mode="expand">
        <xsl:variable name="columnNums" select="@*:number-columns-repeated" as="xs:integer"/>
        <xsl:variable name="currNode" as="element()"><xsl:copy-of select="."/></xsl:variable>
        <!--Iterate through the desired number and just copy the whole node-->
        <xsl:for-each select="1 to $columnNums">
            <xsl:element name="{name($currNode)}">
                <!--We don't want the number columns repeated attribute-->
                <xsl:copy-of select="$currNode/@*[not(ends-with(name(),'number-columns-repeated'))]" exclude-result-prefixes="#all"/>
                <xsl:apply-templates select="$currNode/node()" exclude-result-prefixes="#all" mode="#current"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="table:table-row" exclude-result-prefixes="#all" mode="style">
        <!--Reconstruct the table-row-->
        <xsl:copy copy-namespaces="no" exclude-result-prefixes="#all">
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="table:table-cell">
                <xsl:copy copy-namespaces="no">
                    <xsl:copy-of select="@*[not(ends-with(name(.),'style-name'))]" copy-namespaces="no" exclude-result-prefixes="#all"/>
                    <xsl:variable name="currPos" select="number(position())"/>
                    <xsl:variable name="cellStyle" select="@table:default-cell-style-name"/>
                    <xsl:variable name="columnNode" as="element()*">
                        <xsl:copy-of select="ancestor::table:table/table:table-column[$currPos]" exclude-result-prefixes="#all"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="not(@table:style-name)">
                            <xsl:attribute name="table:style-name">
                                <xsl:choose>
                                    <xsl:when test="$columnNode[@table:default-cell-style-name]">
                                        <xsl:value-of select="$columnNode/@table:default-cell-style-name"/>
                                    </xsl:when>
                                    <xsl:otherwise>Default</xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="@table:style-name" exclude-result-prefixes="#all"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="node()" exclude-result-prefixes="#all" mode="current"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!-- Copy everything else as-is. -->
    <xsl:template match="@*|node()" priority="-1" exclude-result-prefixes="#all" mode="#all">
        <xsl:copy exclude-result-prefixes="#all">
            <xsl:apply-templates select="node()|@*" exclude-result-prefixes="#all" mode="#current"/>
        </xsl:copy>
    </xsl:template>
     
    
</xsl:stylesheet>