<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="urn:docs:toc"
	xmlns:toc="urn:docs:toc"
	xmlns:d="urn:docs:domain"
	xmlns:uc="urn:docs:ucpackage"
	xmlns:ui="urn:docs:interface"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	
	extension-element-prefixes="exsl"
	exclude-result-prefixes="uc d ui xlink html svg toc xsd">
	
    <xsl:output 
		method="xml"
		encoding="UTF-8"
		indent="yes"
		omit-xml-declaration="no" />
	
	
	<xsl:variable name="DOMAINS" select="document('domain.xml', /)/d:domains" />
	<xsl:variable name="UCPACKAGES" select="document('ucpackage.xml', /)/uc:ucpackages" />
	<!--xsl:variable name="INTERFACES" select="document('interface.xml', /)/ui:interface" /-->
	
	<xsl:template match="/">
		<!--xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>href="stylesheets/glossary/toc.xsl" type="text/xsl"</xsl:text>
		</xsl:processing-instruction-->
		<toc>
			<xsl:apply-templates select="$DOMAINS" />
			<xsl:apply-templates select="$UCPACKAGES" />
			<!--xsl:apply-templates select="$INTERFACES" /-->
		</toc>
	</xsl:template>
	
	<xsl:template match="d:domains | d:domain">
		<chapter href="domain.html#{@URN}" title="{@xlink:title}">
			<xsl:apply-templates select="d:domain" />
		</chapter>
	</xsl:template>
	
	<xsl:template match="uc:ucpackages | uc:ucpackage">
		<chapter href="ucpackage.html#{@URN}" title="{@xlink:title}">
			<xsl:apply-templates select="uc:ucpackage" />
		</chapter>
	</xsl:template>
	
	<!--xsl:template match="ui:interface">
		<chapter href="interface.xml#{substring-after(@ID,'interface:')}" title="{@xlink:title}">
			<xsl:apply-templates select="ui:interface" />
		</chapter>
	</xsl:template-->
	
</xsl:stylesheet>
