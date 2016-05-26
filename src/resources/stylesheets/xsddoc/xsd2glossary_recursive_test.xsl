<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
                xmlns="urn:ru:battleship:meta:glossary:glossary"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

                exclude-result-prefixes="">
	
    <xsl:output
        media-type="text/xml"
        method="xml"
        encoding="UTF-8"
        indent="yes"
        omit-xml-declaration="no" />

    <xsl:variable name="GLO-ID" select="'glossary:xpdl'" />
    <xsl:variable name="GLO-PREFIX" select="concat($GLO-ID,':')" />

    <xsl:template match="/*">
        <glossary ID="{$GLO-ID}" xlink:title="BPMNXPDL">
            <xsl:apply-templates select="*[@name]" mode="elt">
                <xsl:with-param name="parent" select="$GLO-ID" />
            </xsl:apply-templates>
        </glossary>        
    </xsl:template>
	
    <xsl:template match="*" mode="elt">
        <xsl:param name="parent" />
        <xsl:choose>
            <xsl:when test="@name and substring(local-name(),1,3)!='key'">
                <xsl:variable name="urn" select="concat($parent,':',@name)" />
                <xsl:variable name="id" select="substring-after($urn,$GLO-PREFIX)" />
                <term ID="{$id}" xlink:title="{$id}">
                    <definition>
                        <xsl:variable name="type" select="concat('glossary:',@type)" />
                        <xsl:variable name="localtype" select="substring-after($type,$GLO-PREFIX)" />
                        <xsl:if test="local-name()='element' and $localtype">
                            is-a
                            <is-a>
                                <xsl:attribute name="xlink:href">
                                    <xsl:value-of select="concat('#',$localtype)" />
                                </xsl:attribute>
                                <xsl:value-of select="$localtype" />
                            </is-a>
                        </xsl:if>
                        <html:ul>
                            <xsl:apply-templates select="*" mode="attr">
                                <xsl:with-param name="parent" select="$urn" />
                            </xsl:apply-templates>
                        </html:ul>
                    </definition>
                </term>
                <xsl:apply-templates select="*" mode="elt">
                    <xsl:with-param name="parent" select="$urn" />
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="*" mode="elt">
                    <xsl:with-param name="parent" select="$parent" />
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	
    <xsl:template match="*" mode="attr">
        <xsl:param name="parent" />
        <xsl:variable name="urn" select="concat($parent,':',@name)" />
        <xsl:choose>
            <xsl:when test="local-name() = 'element' and substring(@ref,1,11)!='deprecated:' or local-name() = 'attribute' or local-name() = 'group'">
                <xsl:variable name="tag">
                    <xsl:choose>
                        <xsl:when test="@maxOccurs">
                            <xsl:value-of select="'has-many'" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'has-a'" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="href">
                    <xsl:choose>
                        <xsl:when test="@ref">
                            <xsl:value-of select="concat('glossary:',@ref)" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$urn" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="id" select="substring-after($href,$GLO-PREFIX)" />
                <html:li>
                    <xsl:value-of select="$tag" />&#160;
                    <xsl:element name="{$tag}">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="concat('#',$id)" />
                        </xsl:attribute>
                        <xsl:value-of select="$id" />
                    </xsl:element>
                </html:li>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="*" mode="attr">
                    <xsl:with-param name="parent" select="$parent" />
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	
</xsl:stylesheet>
