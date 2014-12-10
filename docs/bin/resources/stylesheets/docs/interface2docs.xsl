<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="urn:ru:battleship:meta:glossary:interface"
	xmlns:ui="urn:ru:battleship:meta:glossary:interface"
	xmlns:uc="urn:ru:battleship:meta:glossary:ucpackage"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	
	extension-element-prefixes="exsl"
	exclude-result-prefixes="">
	
    <xsl:output
        media-type="application/xml"
        method="xml"
        encoding="UTF-8"
        indent="yes"
        omit-xml-declaration="no" />
	
	
	<!-- глобальные переменные сделаем UPPERCASE  чтобы отличать их в коде  -->
	<xsl:variable name="ROOT" select="/" />
	<xsl:variable name="INTERFACE-ID" select="/ui:interface/@ID" />
	<xsl:variable name="INTERFACE-TITLE" select="/ui:interface/@xlink:title" />
	<!-- путь от файла пакета до корня проекта  -->
	<xsl:variable name="PROJECT-BASE">
		<xsl:call-template name="get-base">
			<xsl:with-param name="path" select="$INTERFACE-ID"/>
		</xsl:call-template>
	</xsl:variable>
	
	<!-- контейнер для пакетов прецедентов, собираем все в контейнер -->
	<xsl:variable name="UCPACKAGES-SET" select="document(concat($PROJECT-BASE,'ucpackage.xml'), /)/uc:ucpackage" />
	
	<!-- контейнер для пакетов , собираем все в контейнер -->
	<xsl:variable name="INTERFACES">
		<xsl:variable name="interface" select="document(concat($PROJECT-BASE,'temp.xml'), /)/ui:interface"></xsl:variable>
		<xsl:element name="ui:interface">
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="$interface/@xlink:title"/>
			</xsl:attribute>
			<xsl:attribute name="ID">
				<xsl:value-of select="$interface/@ID"/>
			</xsl:attribute>
			<xsl:apply-templates select="$interface/ui:*" mode="include" />
		</xsl:element>
	</xsl:variable>
	
	<xsl:template match="ui:interface" mode="include">
		<xsl:variable name="uipackage-path" select="@xlink:href" />
		<xsl:variable name="included" select="document($uipackage-path,/)/ui:interface"></xsl:variable>
		<xsl:element name="ui:interface">
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="$included/@xlink:title"/>
			</xsl:attribute>
			<xsl:attribute name="ID">
				<xsl:value-of select="$included/@ID"/>
			</xsl:attribute>
			<xsl:attribute name="URN">
				<xsl:value-of select="$included/@ID"/>
			</xsl:attribute>
			<xsl:apply-templates select="$included/ui:*" mode="include" >
				<xsl:with-param name="uipackage" select="$included/@ID" />
				<xsl:with-param name="uipackage-path" select="$uipackage-path" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ui:usecase" mode="include">
		<xsl:variable name="ucpackage-urn" select="@xlink:href" />
		<xsl:if test="not($UCPACKAGES-SET//uc:usecase[@URN=$ucpackage-urn])">
			<xsl:message terminate="yes">потерян пакет: '<xsl:value-of select="$ucpackage-urn" />'</xsl:message>
		</xsl:if>
		<xsl:apply-templates select="$UCPACKAGES-SET//uc:usecase[@URN=$ucpackage-urn]" mode="include" />
	</xsl:template>
	
	<xsl:template match="uc:usecase" mode="include">
		<xsl:element name="ui:usecase" namespace="urn:ru:battleship:meta:glossary:interface">
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="@xlink:title"/>
			</xsl:attribute>
			<xsl:attribute name="ID">
				<xsl:value-of select="@ID"/>
			</xsl:attribute>
			<xsl:attribute name="URN">
				<xsl:value-of select="@URN"/>
			</xsl:attribute>
			<xsl:copy-of select="node()" />
		</xsl:element>
	</xsl:template>
	
	<xsl:variable name="INTERFACES-SET" select="exsl:node-set($INTERFACES)" />
	
	<xsl:template match="ui:interface">
		<xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>href="stylesheets/glossary/interface.xsl" type="text/xsl"</xsl:text>
		</xsl:processing-instruction>
		<xsl:copy-of select="$INTERFACES-SET" />
	</xsl:template>
	
	<!-- utils -->
	<xsl:template name="get-base">
		<xsl:param name="path" />
		<xsl:if test="contains($path, ':')">
			<xsl:text>../</xsl:text>
			<xsl:call-template name="get-base">
				<xsl:with-param name="path" select="substring-after($path,':')" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
