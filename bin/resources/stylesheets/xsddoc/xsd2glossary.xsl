<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns="urn:ru:battleship:meta:glossary:glossary"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:glo="urn:ru:battleship:meta:glossary:glossary"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"
                exclude-result-prefixes="glo xsd xsl exsl">
	
    <xsl:output
        media-type="text/xml"
        method="xml"
        encoding="UTF-8"
        indent="yes"
        omit-xml-declaration="no"/>
	
    <xsl:template match="/xsd:schema">
        <glossary ID=""
          xmlns="urn:ru:battleship:meta:glossary:glossary"
          xlink:title="">
            <xsl:apply-templates select="xsd:element | xsd:simpleType | xsd:complexType | xsd:group | xsd:attributeGroup" mode="ToGlossary" />
        </glossary>

    </xsl:template>


    <xsl:template match="xsd:element | xsd:simpleType | xsd:complexType | xsd:group | xsd:attributeGroup" mode="ToGlossary">

    <term ID="Process:{@name}" xlink:title="{@name}">
        <definition>
            <xsl:value-of select="xsd:annotation/xsd:documentation"/>
            <type xlink:href="schemas/xpdl/bpmnxpdl_40a.xsd#{@name}" xlink:title="(XSD схема)" />
        </definition>
    </term>

    </xsl:template>


	
</xsl:stylesheet>
