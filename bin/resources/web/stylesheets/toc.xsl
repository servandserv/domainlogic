<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:glo="urn:ru:battleship:meta:glossary:glossary"
	xmlns:toc="urn:ru:battleship:meta:glossary:toc"
	xmlns:pac="urn:ru:battleship:meta:glossary:ucpackage"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	extension-element-prefixes="exsl"
    exclude-result-prefixes="xhtml xlink glo xsl">
	
    <xsl:output
        media-type="application/xhtml+xml"
        method="xml"
        encoding="UTF-8"
        indent="yes"
        omit-xml-declaration="no"
        doctype-public="-//W3C//DTD XHTML 1.0 Frameset//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd" />
	
	<xsl:include href="header.xsl" />
	
	<xsl:variable name="newline">
        <xsl:text>
        </xsl:text>
    </xsl:variable>
	
	<xsl:template match="xhtml:div[@id='header']">
		<xsl:call-template name="header" />
	</xsl:template>
	
	<xsl:template match="xhtml:div[@id='toc']">
		<xsl:call-template name="table-of-content" />
	</xsl:template>
	
	<xsl:template match="xhtml:div[@class='contents']">
        <div class="contents">
            <h4 id="ToC">Содержание</h4>
            <ol>
                <xsl:apply-templates select="//xhtml:h2" mode="ToC"/>
            </ol>
        </div>
    </xsl:template>
	
	<!-- copy HTML for display -->
	<xsl:template match="xhtml:*">
		<!-- remove the prefix on HTML elements -->
		<xsl:element name="{local-name()}">
			<xsl:for-each select="@*">
				<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
			<!--xsl:if test="local-name() = 'h2' or local-name() = 'h3'">
				<xsl:if test="not(@id)">
					<xsl:attribute name="id">ID<xsl:value-of select="generate-id(.)" /></xsl:attribute>
				</xsl:if>
			</xsl:if-->
			<xsl:apply-templates select="node()"/>
			
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="xhtml:h2 | xhtml:h3">
		<!-- remove the prefix on HTML elements -->
		<xsl:element name="{local-name()}">
			<xsl:for-each select="@*">
				<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
			<xsl:if test="not(@id)">
				<xsl:attribute name="id">ID<xsl:value-of select="generate-id(.)" /></xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()"/>
			<xsl:element name="a">
				<xsl:attribute name="class">ToCLink</xsl:attribute>
				<xsl:attribute name="href">#ToC</xsl:attribute>
				<xsl:attribute name="title">На содержание</xsl:attribute>
				<xsl:text>&#8593;</xsl:text>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<!-- create ToC entry -->
	<xsl:template match="xhtml:h2" mode="ToC">
		<xsl:value-of select="$newline"/>
		<xsl:variable name="link">
			<xsl:choose>
				<xsl:when test="@id"><xsl:value-of select="@id" /></xsl:when>
				<xsl:otherwise>ID<xsl:value-of select="generate-id(.)" /></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="myId">
			<xsl:value-of select="generate-id(.)"/>
		</xsl:variable>
		<li>
			<a id="ToC-{$link}" href="#{$link}">
				<xsl:apply-templates select="node()"/>
			</a>
			<xsl:if test="following::xhtml:h3[1][preceding::xhtml:h2[1]]">
				<xsl:value-of select="$newline"/>
				<ol>
					<xsl:apply-templates select="following::xhtml:h3[preceding::xhtml:h2[1][generate-id() = $myId]]" mode="ToC"/>
					<xsl:value-of select="$newline"/>
				</ol>
				<xsl:value-of select="$newline"/>
			</xsl:if>
		</li>
	</xsl:template>

	<xsl:template match="xhtml:h3" mode="ToC">
		<xsl:value-of select="$newline"/>
		<xsl:variable name="link">
			<xsl:choose>
				<xsl:when test="@id"><xsl:value-of select="@id" /></xsl:when>
				<xsl:otherwise>ID<xsl:value-of select="generate-id(.)" /></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<li>
			<a id="ToC-{$link}" href="#{$link}">
				<xsl:apply-templates select="node()"/>
			</a>
		</li>
	</xsl:template>

	<!-- h1 and xxhtmlh2's should point back to the ToC for easy navigation -->
	<xsl:template match="xhtml:h2[@class='backlink']">
		<xsl:variable name="link">
			<xsl:value-of select="@id"/>
		</xsl:variable>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<a href="#ToC-{$link}">&#160;&#8617;</a>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xhtml:h3[@class='backlink']">
		<xsl:variable name="link">
			<xsl:value-of select="@id"/>
		</xsl:variable>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<a href="#ToC-{$link}">&#160;&#8617;</a>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>