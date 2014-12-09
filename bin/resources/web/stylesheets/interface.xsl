<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:wadl="http://wadl.dev.java.net/2009/02"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:glo="urn:ru:battleship:meta:glossary:glossary"
	xmlns:uc="urn:ru:battleship:meta:glossary:ucpackage"
	xmlns:ui="urn:ru:battleship:meta:glossary:interface"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	extension-element-prefixes="exsl"
    exclude-result-prefixes="xlink glo uc ui xsl wadl">
	
    <xsl:output
        media-type="application/xhtml+xml"
        method="xml"
        encoding="UTF-8"
        indent="yes"
        omit-xml-declaration="no"
        doctype-public="-//W3C//DTD XHTML 1.1//EN"
        doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" />
	
	<xsl:include href="header.xsl" />
	
	<xsl:template match="ui:interface">
		<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ru">
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
				<meta name="keywords" content="interfaces"/>
				<link rel="stylesheet" type="text/css" href="styles/documentation.css" />
				<title><xsl:value-of select="@xlink:title" /></title>
				<script type="text/javascript">
					function init() {
						if (document.location.hash) {
							document.location = document.location;
						}
					}
				</script>
			</head>
			<body onload="init();">
				<xsl:call-template name="header" />
				<xsl:apply-templates select="." mode="content" />
			</body>
		</html>
		
	</xsl:template>
	
	<xsl:template match="ui:interface" mode="content">
		<xsl:variable name="level" select="count(ancestor-or-self::ui:interface)" />
		<xsl:element name="h{$level}" namespace="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="id">
				<xsl:value-of select="substring-after(@URN,'interface:')" />
			</xsl:attribute>
			<xsl:value-of select="@xlink:title" />
		</xsl:element>
		<xsl:if test="$level = 1"><hr/></xsl:if>
		<xsl:if test="ui:doc">
			<xsl:element name="h{$level+1}" namespace="http://www.w3.org/1999/xhtml">
				Краткое описание
			</xsl:element>
			<xsl:apply-templates select="ui:doc" />
		</xsl:if>
		<xsl:if test="ui:interface">
			<xsl:element name="h{$level+1}" namespace="http://www.w3.org/1999/xhtml">
				Дочерние интерфейсы
			</xsl:element>
			<ul>
				<xsl:apply-templates select="ui:interface" mode="ToC" />
			</ul>
		</xsl:if>
		<xsl:if test="ui:usecase">
			<xsl:element name="h{$level+1}" namespace="http://www.w3.org/1999/xhtml">
				Реализуемые прецеденты
			</xsl:element>
			<ul>
				<xsl:apply-templates select="ui:usecase" mode="ToC" />
			</ul>
			<xsl:apply-templates select="ui:usecase" mode="content" />
		</xsl:if>
		<xsl:apply-templates select="ui:interface" mode="content" />
	</xsl:template>
	
	<xsl:template match="ui:doc" mode="content">
		<p>
			<xsl:apply-templates select="." />
		</p>
	</xsl:template>
	
	<xsl:template match="ui:interface" mode="ToC">
		<li>
			<a href="#{substring-after(@URN,'interface:')}"><xsl:value-of select="@xlink:title" /></a>
			<xsl:if test="ui:interface">
				<ul>
					<xsl:apply-templates select="ui:interface" mode="ToC" />
				</ul>
			</xsl:if>
		</li>
	</xsl:template>
	
	<xsl:template match="ui:usecase" mode="ToC">
		<li>
			<a href="ucpackage.xml#{substring-after(@URN,'ucpackage:')}"><xsl:value-of select="@xlink:title" /></a>
		</li>
	</xsl:template>
	
	<xsl:template match="ui:usecase" mode="content">
		<xsl:variable name="level" select="count(ancestor-or-self::ui:interface)" />
		<xsl:element name="h{$level+2}" namespace="http://www.w3.org/1999/xhtml">
			<xsl:value-of select="@xlink:title" />
		</xsl:element>
		<xsl:apply-templates select="node()" />
	</xsl:template>
	
	<xsl:template match="ui:*[ancestor::ui:usecase]">
		<strong style="background:yellow;padding:1px 2px;border:solid 1px tomato;"><xsl:apply-templates select="node()" /></strong>
	</xsl:template>
	
	<xsl:template match="glo:*[ancestor::ui:usecase]">
		<strong style="background:tomato;padding:1px 2px;border:solid 1px cyan;">
			<xsl:variable name="link">
				<xsl:call-template name="get-link">
					<xsl:with-param name="urn" select="@xlink:href" />
				</xsl:call-template>
			</xsl:variable>
			<a href="{$link}">
				<xsl:apply-templates select="node()" />
			</a>
		</strong>
	</xsl:template>
	
	<!-- copy HTML for display -->
	<xsl:template match="html:*">
		<!-- remove the prefix on HTML elements -->
		<xsl:element name="{local-name()}">
			<xsl:for-each select="@*">
				<xsl:attribute name="{local-name()}">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:for-each>
			<xsl:apply-templates select="node()" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="get-link">
		<xsl:param name="urn" />
		<xsl:choose>
			<xsl:when test="starts-with($urn,'glossary:')">
				<xsl:value-of select="concat('glossary.xml#',substring-after($urn,'glossary:'))" />
			</xsl:when>
			<xsl:when test="starts-with(urn,'ucpackage:')">
				<xsl:value-of select="concat('ucpackage.xml#',substring-after($urn,'ucpackage:'))" />
			</xsl:when>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
