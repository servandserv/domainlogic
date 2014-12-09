<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	extension-element-prefixes="exsl"
    exclude-result-prefixes="html xlink xsl xsd">
	
    <xsl:output
        media-type="application/xhtml+xml"
        method="xml"
        encoding="UTF-8"
        indent="yes"
        omit-xml-declaration="no"
        doctype-public="-//W3C//DTD XHTML 1.1//EN"
        doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" />
	
	<xsl:template match="*[@xlink:href]">
		<xsl:choose>
			<xsl:when test="@xlink:show='embed'">
				<xsl:choose>
					<xsl:when test="local-name()='has-a' or local-name()='is-a'">
						<xsl:variable name="urn" select="substring-after(@xlink:href,'#')" />
						<xsl:variable name="term" select="exsl:node-set($glossary)/glo:glossary/glo:term[@ID=$urn]" />
						<xsl:apply-templates select="$term" mode="content" />
					</xsl:when>
					<xsl:when test="local-name()='graph'">
						<a href="{@xlink:href}" title="{@xlink:title}">
							<xsl:value-of select="@xlink:title" />
						</a>
						<p>
							<img src="{@xlink:href}" acl="{@xlink:title}" />
						</p>
					</xsl:when>
					<xsl:otherwise>
						
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
					<xsl:attribute name="href"><xsl:value-of select="@xlink:href" /></xsl:attribute>
					<xsl:choose>
						<xsl:when test="text()">
							<xsl:attribute name="title">
								<xsl:value-of select="@xlink:title" />
							</xsl:attribute>
							<xsl:value-of select="." />
						</xsl:when>
						<xsl:when test="@xlink:title">
							<xsl:value-of select="@xlink:title" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="urn" select="substring-after(@xlink:href,'#')" />
							<xsl:variable name="term" select="exsl:node-set($glossary)/glo:glossary/glo:term[@ID=$urn]" />
							<xsl:choose>
								<xsl:when test="$term/@xlink:title">
									<xsl:value-of select="$term/@xlink:title" />
								</xsl:when>
								<xsl:otherwise><xsl:value-of select="$urn" /></xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
