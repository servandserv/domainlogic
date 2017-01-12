<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="urn:com:servandserv:docs:domain"
	xmlns:d="urn:com:servandserv:docs:domain"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:toc="urn:com:servandserv:docs:toc"
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
	
	<xsl:param name="NS" select="'ns'" />
	<xsl:param name="BASE" />
	
	<!-- глобальные переменные сделаем UPPERCASE  чтобы отличать их в коде  -->
	<xsl:variable name="ROOT" select="/d:domains" />
	<xsl:variable name="DOMAIN-ID" select="/d:domains/@ID" />
	<xsl:variable name="DOMAIN-TITLE" select="/d:domains/@xlink:title" />
	<xsl:variable name="DOMAIN-HREF" select="/d:domains/@xlink:href" />
	<!-- путь от файла пакета до корня проекта  -->
	<!--xsl:variable name="PROJECT-BASE">
		<xsl:call-template name="get-base">
			<xsl:with-param name="path" select="$DOMAIN-ID"/>
		</xsl:call-template>
	</xsl:variable-->
	
	<!-- контейнер для терминов проекта, собираем все термины проекта в контейнер -->
	<xsl:variable name="DOMAINS">
		<!-- достаем корневой  пакет  domain и начиная с него собираем все термины проекта  -->
		<!--xsl:variable name="domains" select="document('temp.xml', /)/d:domains"></xsl:variable-->
		<xsl:element name="d:domains">
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="$DOMAIN-TITLE"/>
			</xsl:attribute>
			<xsl:attribute name="ID">
				<xsl:value-of select="$DOMAIN-ID" />
			</xsl:attribute>
			<!--xsl:apply-templates select="$domain/d:*" mode="include-entity">
				<xsl:with-param name="package" select="$domain/@ID" />
				<xsl:with-param name="package-path" select="concat($PROJECT-BASE,domain.xml)" />
			</xsl:apply-templates-->
			<xsl:apply-templates select="$ROOT/d:domain[@xlink:type='locator']" mode="include-domains">
				<xsl:with-param name="parent-package" select="''" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:variable>
	
	<xsl:template match="d:domain" mode="include-domains">
		<xsl:param name="parent-package" />
		<xsl:variable name="package-path" select="@xlink:href" />
		<xsl:variable name="package">
			<xsl:apply-templates select="." mode="package">
				<xsl:with-param name="parent-package" select="$parent-package" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="included" select="document(concat($BASE,'/',$package-path))/d:domain"></xsl:variable>
		<xsl:element name="d:domain">
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="$included/@xlink:title"/>
			</xsl:attribute>
			<xsl:attribute name="URN">
				<xsl:value-of select="$package" />
			</xsl:attribute>
			<xsl:apply-templates select="$included/d:entity" mode="include-entity">
				<xsl:with-param name="package" select="$package" />
			</xsl:apply-templates>
			<xsl:apply-templates select="$included/d:domain[@xlink:type='locator']" mode="include-domains">
				<xsl:with-param name="parent-package" select="$package" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="d:entity" mode="include-entity">
		<xsl:param name="package" />
		<xsl:element name="d:entity">
			<xsl:attribute name="ID"><xsl:value-of select="@ID"/></xsl:attribute>
			<xsl:if test="@isValueObject">
				<xsl:attribute name="isValueObject">true</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="package"><xsl:value-of select="$package"/></xsl:attribute>
			<xsl:attribute name="URN"><xsl:value-of select="concat($package,':',@ID)"/></xsl:attribute>
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="@xlink:title"/>
			</xsl:attribute>
			<xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
				<xsl:call-template name="url">
					<xsl:with-param name="urn" select="concat($package,':',@ID)" />
				</xsl:call-template>
			</xsl:attribute>
			<xsl:apply-templates mode="include-entity-info">
				<xsl:with-param name="package" select="$package" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="html:*" mode="include-entity-info">
		<xsl:param name="package" />
		<xsl:element name="html:{local-name()}">
			<xsl:copy-of select="@*" />
			<xsl:apply-templates mode="include-entity-info" >
				<xsl:with-param name="package" select="$package" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="d:has-a | d:has-many | d:is-a" mode="include-entity-info">
		<xsl:param name="package" />
		<xsl:element name="d:{local-name()}">
			<xsl:attribute name="xlink:href">
				<xsl:apply-templates select="." mode="url">
					<xsl:with-param name="package" select="$package" />
				</xsl:apply-templates>
			</xsl:attribute>
			<xsl:attribute name="URN">
				<xsl:apply-templates select="." mode="urn">
					<xsl:with-param name="package" select="$package" />
				</xsl:apply-templates>
			</xsl:attribute>
			<xsl:apply-templates mode="include-entity-info">
				<xsl:with-param name="package" select="$package" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="d:*" mode="include-entity-info">
		<xsl:param name="package" />
		<xsl:element name="d:{local-name()}">
			<xsl:apply-templates mode="include-entity-info" >
				<xsl:with-param name="package" select="$package" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="*" mode="include-entity-info">
		<xsl:param name="package" />
		<xsl:copy-of select="." />
	</xsl:template>
	
	<xsl:variable name="DOMAINS-SET" select="exsl:node-set($DOMAINS)" />
	<xsl:variable name="ENTITIES-SET" select="$DOMAINS-SET//d:entity" />
	
	<xsl:template match="d:domains">
		<!-- проверяем связи по ссылкам  -->
		<!--xsl:for-each select="$ENTITIES-SET//d:is-a">
			<xsl:variable name="urn">
				<xsl:apply-templates select="." mode="urn" />
			</xsl:variable>
			<xsl:if test="not($ENTITIES-SET[@URN = $urn])">
				<xsl:message terminate="yes">Не определен термин '<xsl:value-of select="$urn" />'</xsl:message>
			</xsl:if>
		</xsl:for-each-->
		<!--xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>href="../../ITDocumentation/stylesheets/docs/domain.xsl" type="text/xsl"</xsl:text>
		</xsl:processing-instruction-->
		<xsl:copy-of select="$DOMAINS-SET" />
	</xsl:template>
	
	<!-- utils -->
	<xsl:template match="d:*[@xlink:href]" mode="urn">
		<xsl:param name="package" />
		<xsl:choose>
			<xsl:when test="substring-after(@xlink:href,'#')">
				<xsl:value-of select="concat($package,':',substring-after(@xlink:href,'#'))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@xlink:href" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="d:*[@xlink:href]" mode="url">
		<xsl:param name="package" />
		<xsl:variable name="urn">
			<xsl:apply-templates select="." mode="urn" >
				<xsl:with-param name="package" select="$package" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="url">
			<xsl:with-param name="urn" select="$urn" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="url">
		<xsl:param name="urn" />
		<!--xsl:text>../../</xsl:text>
		<xsl:value-of select="substring-before($urn,':')" /-->
		<xsl:text>domain.html#</xsl:text>
		<xsl:value-of select="$urn" />
	</xsl:template>
	
	<xsl:template match="d:domain[@xlink:href]" mode="package">
		<xsl:param name="parent-package" />
		<xsl:if test="$parent-package">
			<xsl:value-of select="$parent-package" />
			<xsl:text>:</xsl:text>
		</xsl:if>
		<xsl:choose>
		    <xsl:when test="substring-after(@xlink:href,'/')">
		        <xsl:value-of select="substring-before(substring-after(@xlink:href,'/'),'.')" />
		    </xsl:when>
		    <xsl:otherwise>
		        <xsl:value-of select="substring-before(@xlink:href,'.')" />
		    </xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
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
