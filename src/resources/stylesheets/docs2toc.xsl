<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="urn:com:servandserv:domainlogic:toc"
	xmlns:toc="urn:com:servandserv:domainlogic:toc"
	xmlns:d="urn:com:servandserv:domainlogic:domain"
	xmlns:uc="urn:com:servandserv:domainlogic:ucpackage"
	xmlns:ui="urn:com:servandserv:domainlogic:interface"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	
	extension-element-prefixes="exsl"
	exclude-result-prefixes="uc d ui xlink html svg toc xsd">
	
    <xsl:output
        media-type="application/xml"
        method="xml"
        encoding="UTF-8"
        indent="yes"
        omit-xml-declaration="no" />
	
	<xsl:param name="APPNAME" />
	<xsl:variable name="GLOSSARIES" select="document('domains.xml')/d:domain" />
	<xsl:variable name="UCPACKAGES" select="document('ucpackage.xml')/uc:ucpackage" />
	
	<xsl:template match="/">
		<toc appname="{$APPNAME}">
			<xsl:apply-templates select="$GLOSSARIES" />
			<xsl:apply-templates select="$UCPACKAGES" />
			<!--xsl:apply-templates select="$INTERFACES" /-->
		</toc>
	</xsl:template>
	
	<xsl:template match="d:domain">
		<chapter id="{@URN}" href="{@URN}" title="{@xlink:title}">
			<xsl:apply-templates select="d:domain" />
		</chapter>
	</xsl:template>
	
	<xsl:template match="uc:ucpackage">
		<chapter id="{@URN}" href="{@URN}" title="{@xlink:title}">
			<xsl:apply-templates select="uc:ucpackage" />
		</chapter>
	</xsl:template>
	
	
</xsl:stylesheet>
