<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    xpath-default-namespace="http://docbook.org/ns/docbook"
    xmlns="http://docbook.org/ns/docbook"
    xmlns:hcmc="https://hcmc.uvic.ca/ns/1.0"
    version="3.0">
    
    
    <!--Simple docbook5 to balisage conversion from pandoc-->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:mode name="ref" on-no-match="shallow-copy"/>
    <xsl:mode name="ref_1" on-no-match="shallow-copy"/>
    <xsl:mode name="quote" on-no-match="shallow-copy"/>
    <xsl:mode name="addQuotes" on-no-match="shallow-copy"/>
    <xsl:mode name="cite" on-no-match="shallow-copy"/>
    
    <xsl:accumulator name="xref" initial-value="()">
        <xsl:accumulator-rule match="xref[@linkend]"
            select="distinct-values(($value, @linkend))"/>
    </xsl:accumulator>
    
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">href="balisage-1-5.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="article">
        <xsl:variable name="cited" as="element(article)">
            <xsl:apply-templates select="." mode="cite"/>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="$cited/(@*|node())"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[matches(.,'@')][not(ancestor::code or ancestor::literal)]" mode="cite">
        <xsl:analyze-string select="." regex="@([a-zA-Z0-9]+)">
            <xsl:matching-substring>
                <xsl:message select="'Found cit: ' || regex-group(1)"/>
                <xref linkend="{regex-group(1)}"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
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
    
    <xsl:template match="abstract">
        <xsl:copy>
            <xsl:apply-templates select="root(.)//section[@xml:id='abstract']/para"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="author">
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:if test="not(personblurb)">
                <personblurb>
                    <para>TODO</para>
                </personblurb>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!--Remove the abstract from the regular flow.-->
    <xsl:template match="section[@xml:id='abstract']"/>
    
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
            <xsl:sequence select="objectinfo/title"/>
            <mediaobject>
                <xsl:apply-templates select="imageobject"/>
            </mediaobject>
        </figure>
    </xsl:template>
    
    <xsl:template match="objectinfo"/>
    
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
    
    <xsl:template match="emphasis/@role[. = 'strong']">
        <xsl:attribute name="role" select="'bold'"/>
    </xsl:template>
    
    <xsl:template match="section[@xml:id='appendix'][not(section)] | section[@xml:id='appendix']/section">
        <appendix>
            <xsl:apply-templates/>
        </appendix>
    </xsl:template>
    
    <xsl:template match="section[@xml:id='appendix'][section]">
        <xsl:apply-templates select="section"/>
    </xsl:template>
   
    <xsl:template match="section[@xml:id = 'references']">
        <bibliography>
            <xsl:apply-templates select="node()" mode="ref"/>
        </bibliography>
    </xsl:template>
    
    <xsl:template match="para" mode="ref">
        <xsl:variable name="labeled" select="hcmc:addLabelToPara(.)" as="element(para)"/>
        <xsl:variable name="xreflabel" select="$labeled/label/string(.)" as="xs:string"/>
        <xsl:variable name="id" select="
            replace($xreflabel, ' and ', '')
            => replace('[^A-Za-z0-9]+','')"
            as="xs:string"/>
        <xsl:if test="$id = accumulator-after('xref')">
            <bibliomixed xml:id="{$id}" xreflabel="{$xreflabel}">
                <xsl:apply-templates select="$labeled/content" mode="#current"/>
            </bibliomixed>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="para/content" mode="ref">
        <xsl:variable name="quoted" as="element(content)">
            <xsl:copy>
                <xsl:apply-templates select="node()" mode="quote"/>
            </xsl:copy>
        </xsl:variable>
        <xsl:apply-templates select="$quoted" mode="addQuotes"/>
    </xsl:template>
    
    <xsl:template match="*" mode="addQuotes">
        <xsl:choose>
            <xsl:when test="self::content">
                <xsl:call-template name="group"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:call-template name="group"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template name="group">
        <xsl:for-each-group select="node()" group-starting-with="self::apos">
            <xsl:choose>
                <xsl:when test="current-group()[1]/self::apos[@type='start']">
                    <quote>
                        <xsl:apply-templates select="current-group()" mode="addQuotes"/>
                    </quote>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="current-group()" mode="addQuotes"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="apos" mode="addQuotes"/>
    
    <xsl:template match="text()" mode="quote">
        <xsl:variable name="open" select="'“'"/>
        <xsl:variable name="closed" select="'”'"/>
        <xsl:analyze-string select="." regex="[“”]">
            <xsl:matching-substring>
                <apos type="{if (. = '“') then 'start' else 'end'}"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    
   <xsl:function name="hcmc:addLabelToPara">
       <xsl:param name="para"/>
       <xsl:variable name="firstText" select="$para/text()[1]"/>
       <xsl:variable name="tagged">
           <xsl:analyze-string select="$firstText" regex="\[([^\]]+)\]">
               <xsl:matching-substring>
                   <label>
                       <xsl:value-of select="regex-group(1)"/>
                   </label>
               </xsl:matching-substring>
               <xsl:non-matching-substring>
                   <xsl:value-of select="."/>
               </xsl:non-matching-substring>
           </xsl:analyze-string>
       </xsl:variable>
       <xsl:variable name="combined" select="$tagged, $para/node()[not(. is $firstText)]"/>
       <xsl:variable name="dummy" as="element(para)">
           <para>
               <xsl:sequence select="$combined"/>
           </para>
       </xsl:variable>
       <xsl:variable name="dLabel" select="$dummy/label" as="element(label)"/>
       <para>
           <xsl:sequence select="$dummy/label"/>
           <content>
               <xsl:apply-templates select="$dummy/node()[. &gt;&gt; $dLabel]"/>
           </content>
       </para>
   </xsl:function>
    
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