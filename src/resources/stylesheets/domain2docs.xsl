<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="urn:com:servandserv:domainlogic:domain"
	xmlns:d="urn:com:servandserv:domainlogic:domain"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:toc="urn:com:servandserv:domainlogic:toc"
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
	
	<xsl:variable name="ROOT" select="/d:domain" />
	<xsl:variable name="DOMAIN-ID" select="/d:domain/@ID" />
	<xsl:variable name="DOMAIN-TITLE" select="/d:domain/@xlink:title" />
	<xsl:variable name="DOMAIN-HREF" select="/d:domain/@xlink:href" />
	<xsl:variable name="SOURCE-BASE" select="/d:domain/@base" />
	<!-- package path  -->
	<!--xsl:variable name="PROJECT-BASE">
		<xsl:call-template name="get-base">
			<xsl:with-param name="path" select="$DOMAIN-ID"/>
		</xsl:call-template>
	</xsl:variable-->
	
	<!-- domain models container, group all domain models -->
	<xsl:variable name="DOMAINS">
		<!-- get root domain model and then get his child domains  -->
		<!--xsl:variable name="domain" select="document(concat($PROJECT-BASE,'temp.xml'), /)/d:domain"></xsl:variable-->
		<xsl:element name="d:domain">
		    <xsl:copy-of select="$ROOT/@*" />
		    <xsl:attribute name="URN">
				<xsl:value-of select="$ROOT/@ID"/>
			</xsl:attribute>
			<!--xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="$DOMAIN-TITLE"/>
			</xsl:attribute>
			<xsl:attribute name="ID">
				<xsl:value-of select="$DOMAIN-ID"/>
			</xsl:attribute-->
			<!--xsl:apply-templates select="$domain/d:entity" mode="include-term">
				<xsl:with-param name="package" select="$domain/@ID" />
				<xsl:with-param name="package-path" select="concat($PROJECT-BASE,'domain.xml')" />
			</xsl:apply-templates-->
			<xsl:apply-templates select="$ROOT/d:domain[@xlink:type='locator']" mode="include-domain">
			    <xsl:with-param name="parent-urn" select="$ROOT/@ID" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:variable>
	
	<xsl:template match="d:domain" mode="include-domain">
	    <xsl:param name="parent-urn" />
		<xsl:variable name="package-path" select="@xlink:href" />
		<xsl:variable name="included" select="document($package-path,/)/d:domain"></xsl:variable>
		<xsl:variable name="URN" select="concat($parent-urn,':',$included/@ID)" />
		<xsl:element name="d:domain">
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="$included/@xlink:title"/>
			</xsl:attribute>
			<xsl:attribute name="ID">
				<xsl:value-of select="$included/@ID"/>
			</xsl:attribute>
			<xsl:attribute name="URN">
			    <xsl:value-of select="$URN" />
			</xsl:attribute>
			<xsl:copy-of select="$included/html:*" />
			<xsl:apply-templates select="$included/d:entity" mode="include-entity">
				<xsl:with-param name="parent-urn" select="$URN" />
			</xsl:apply-templates>
			<xsl:apply-templates select="$included/d:domain[@xlink:type='locator']" mode="include-domain">
			    <xsl:with-param name="parent-urn" select="$URN" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="d:entity" mode="include-entity">
		<xsl:param name="parent-urn" />
		<xsl:element name="d:entity">
			<xsl:attribute name="ID">
			    <xsl:value-of select="@ID"/>
			</xsl:attribute>
			<xsl:attribute name="PARENT-URN">
			    <xsl:value-of select="$parent-urn"/>
			</xsl:attribute>
			<xsl:attribute name="URN">
			    <xsl:value-of select="concat($parent-urn,':',@ID)"/>
			</xsl:attribute>
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="@xlink:title"/>
			</xsl:attribute>
			<xsl:copy-of select="*" />
		</xsl:element>
	</xsl:template>
	
	<xsl:variable name="DOMAINS-SET" select="exsl:node-set($DOMAINS)" />
	<xsl:variable name="ENTITIES-SET" select="$DOMAINS-SET//d:entity" />
	
	<xsl:template match="/">
		<!-- проверяем связи по ссылкам  -->
		<xsl:for-each select="$ENTITIES-SET//d:is-a">
			<xsl:variable name="urn">
				<xsl:choose>
					<xsl:when test="substring-after(@xlink:href,'#')">
						<xsl:value-of select="concat(ancestor::d:domain[1]/@URN,':',substring-after(@xlink:href,'#'))" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@xlink:href" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="not($ENTITIES-SET[@URN = $urn])">
				<xsl:message terminate="yes">Model <xsl:value-of select="$urn" /> undefined</xsl:message>
			</xsl:if>
		</xsl:for-each>
		<xsl:copy-of select="$DOMAINS-SET" />
	</xsl:template>
	
</xsl:stylesheet>
