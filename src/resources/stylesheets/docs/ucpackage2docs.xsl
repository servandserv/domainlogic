<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="urn:com:servandserv:docs:ucpackage"
	xmlns:uc="urn:com:servandserv:docs:ucpackage"
	xmlns:d="urn:com:servandserv:docs:domain"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:toc="urn:com:servandserv:docs:toc"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:wadl="http://wadl.dev.java.net/2009/02"
	
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
	<xsl:variable name="ROOT" select="/uc:ucpackage" />
	<xsl:variable name="UCPACKAGE-ID" select="/uc:ucpackage/@ID" />
	<xsl:variable name="UCPACKAGE-TITLE" select="/uc:ucpackage/@xlink:title" />
	<xsl:variable name="UCPACKAGE-HREF" select="/uc:ucpackage/@xlink:href" />
	
	<!-- контейнер для терминов проекта, собираем все термины проекта в контейнер -->
	<xsl:variable name="UCPACKAGES">
		<!-- достаем корневой  пакет  glossary и начиная с него собираем все термины проекта  -->
		<!--xsl:variable name="ucpackage" select="document('temp.xml', /)/uc:ucpackage"></xsl:variable-->
		<xsl:element name="uc:ucpackages">
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="$UCPACKAGE-TITLE"/>
			</xsl:attribute>
			<xsl:attribute name="ID">
				<xsl:value-of select="$UCPACKAGE-ID"/>
			</xsl:attribute>
			<xsl:apply-templates select="$ROOT/uc:ucpackage[@xlink:type='locator']" mode="include">
				<xsl:with-param name="parent-package" select="''" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:variable>
	
	<xsl:template match="uc:ucpackage" mode="include">
		<xsl:param name="parent-package" />
		<xsl:variable name="ucpackage-path" select="@xlink:href" />
		<xsl:variable name="included" select="document(concat($BASE,'/',$ucpackage-path))/uc:ucpackage" />
		<xsl:variable name="package">
			<xsl:apply-templates select="." mode="package">
				<xsl:with-param name="parent-package" select="$parent-package" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:element name="uc:ucpackage">
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="$included/@xlink:title"/>
			</xsl:attribute>
			<xsl:attribute name="URN">
				<xsl:value-of select="$package" />
			</xsl:attribute>
			<xsl:apply-templates select="$included/uc:*" mode="include" >
				<xsl:with-param name="parent-package" select="$package" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="uc:actor" mode="include">
		<xsl:param name="parent-package" />
		<xsl:element name="uc:actor">
			<xsl:attribute name="ID"><xsl:value-of select="@xlink:label"/></xsl:attribute>
			<xsl:attribute name="URN"><xsl:value-of select="concat($parent-package,':',@xlink:label)"/></xsl:attribute>
			<xsl:attribute name="package"><xsl:value-of select="$parent-package"/></xsl:attribute>
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="@xlink:title"/>
			</xsl:attribute>
			<xsl:if test="@xlink:href">
				<xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
					<xsl:apply-templates select="." mode="url">
						<xsl:with-param name="type" select="'domain'" />
					</xsl:apply-templates>
				</xsl:attribute>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="uc:usecase" mode="include">
		<xsl:param name="parent-package" />
		<xsl:element name="uc:usecase">
			<xsl:attribute name="ID"><xsl:value-of select="@xlink:label"/></xsl:attribute>
			<xsl:attribute name="URN"><xsl:value-of select="concat($parent-package,':',@xlink:label)"/></xsl:attribute>
			<xsl:attribute name="package"><xsl:value-of select="$parent-package"/></xsl:attribute>
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="@xlink:title"/>
			</xsl:attribute>
			<xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
				<xsl:call-template name="url">
					<xsl:with-param name="urn" select="concat($parent-package,':',@xlink:label)" />
					<xsl:with-param name="type" select="'ucpackage'" />
				</xsl:call-template>
			</xsl:attribute>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="uc:wadl[@xlink:type='locator']" mode="include">
		<xsl:param name="parent-package" />
		<xsl:variable name="included" select="document(@xlink:href, /)/wadl:application" />
		<xsl:for-each select="$included//wadl:resource">
			<xsl:element name="uc:usecase">
				<xsl:attribute name="ID"><xsl:value-of select="@id"/></xsl:attribute>
				<xsl:attribute name="URN"><xsl:value-of select="concat($parent-package,':',@id)"/></xsl:attribute>
				<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
					<xsl:value-of select="wadl:doc/@title"/>
				</xsl:attribute>
				<xsl:attribute name="xlink:label" namespace="http://www.w3.org/1999/xlink">
					<xsl:value-of select="concat($parent-package,':',@id)"/>
				</xsl:attribute>
				<xsl:copy-of select="wadl:doc" />
				<xsl:for-each select="wadl:method">
					<xsl:element name="h4" namespace="http://www.w3.org/1999/xhtml">Method <xsl:value-of select="@name" /></xsl:element>
					<xsl:copy-of select="wadl:request/wadl:doc" />
					<xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
						<xsl:for-each select="wadl:response">
							<xsl:element name="p"  namespace="http://www.w3.org/1999/xhtml">
								<xsl:if test="substring(@status,1,1) &gt; 3">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								(Status <xsl:value-of select="@status" />)
								<xsl:copy-of select="./wadl:representation/wadl:doc"/>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="uc:*" mode="include">
		<xsl:copy-of select="." />
	</xsl:template>
	
	<xsl:variable name="UCPACKAGES-SET" select="exsl:node-set($UCPACKAGES)" />
	
	<xsl:template match="uc:ucpackage">
		<!--xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>href="stylesheets/glossary/ucpackage.xsl" type="text/xsl"</xsl:text>
		</xsl:processing-instruction-->
		<xsl:copy-of select="$UCPACKAGES-SET" />
	</xsl:template>
	
	<!-- utils -->
	<xsl:template match="*[@xlink:href]">
		<xsl:variable name="urn">
			<xsl:apply-templates select="." mode="urn" />
		</xsl:variable>
		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="namespace-uri() = 'urn:com:servandserv:docs:domain'">domain</xsl:when>
				<xsl:when test="namespace-uri() = 'urn:com:servandserv:docs:ucpackage'">ucpackage</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="url">
			<xsl:call-template name="url">
				<xsl:with-param name="urn" select="$urn" />
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:element name="{local-name()}">
			<xsl:attribute name="xlink:href"><xsl:value-of select="$url" /></xsl:attribute>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="*[@xlink:href]" mode="urn">
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
	
	<xsl:template match="*[@xlink:href]" mode="url">
		<xsl:param name="package" />
		<xsl:param name="type" />
		<xsl:variable name="urn">
			<xsl:apply-templates select="." mode="urn" >
				<xsl:with-param name="package" select="$package" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:call-template name="url">
			<xsl:with-param name="urn" select="$urn" />
			<xsl:with-param name="type" select="$type" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="url">
		<xsl:param name="urn" />
		<xsl:param name="type" />
		<!--xsl:text>../../</xsl:text>
		<xsl:value-of select="substring-before($urn,':')" />
		<xsl:text>/docs/</xsl:text-->
		<xsl:value-of select="$type" />
		<xsl:text>.html#</xsl:text>
		<xsl:value-of select="$urn" />
	</xsl:template>
	
	<xsl:template match="uc:ucpackage[@xlink:href]" mode="package">
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
	
</xsl:stylesheet>
