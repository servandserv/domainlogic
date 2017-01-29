<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet SYSTEM "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"> 
<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:toc="urn:com:servandserv:domainlogic:toc"
	xmlns:d="urn:com:servandserv:domainlogic:domain"
	xmlns:uc="urn:com:servandserv:domainlogic:ucpackage"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	extension-element-prefixes="exsl"
	exclude-result-prefixes="html xlink d uc xsl xsd">
	
	<!--xsl:output
		media-type="text/xml"
		method="xml"
		encoding="UTF-8"
		indent="yes"
		omit-xml-declaration="no" /-->
	<xsl:output method="html" omit-xml-declaration="yes" indent="yes" />
	<!--xsl:output method="text" omit-xml-declaration="yes" indent="no"/-->
	
	<xsl:include href="common2html.xsl" />
	
	<xsl:param name="APPNAME" />
	<xsl:param name="DEST" />
	
	<xsl:template match="/">
		<xsl:apply-templates select="." mode="content" />
	</xsl:template>
	
	<xsl:template match="d:domain" mode="content">
	<xsl:text disable-output-escaping="yes">
#path: </xsl:text><xsl:value-of select="$DEST" /><xsl:text>/</xsl:text>
        <xsl:value-of select="translate(@URN,':','.')" />
        <xsl:text disable-output-escaping="yes">.html
&lt;!DOCTYPE html&gt;
        </xsl:text>
        
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ru">
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
				<meta name="keywords" content="domainlogic documentation"/>
				<link rel="stylesheet" type="text/css" href="css/domainlogic.css" />
				<title><xsl:value-of select="@xlink:title" /> | Models</title>
			</head>
			<body>
			    <xsl:call-template name="header" />
		        <xsl:variable name="level" select="count(ancestor-or-self::d:domain)" />
		        <xsl:variable name="id" select="@URN" />
		        <xsl:if test="parent::d:domain">
		            <h6>
		                <xsl:for-each select="ancestor::d:domain">
		                    <xsl:variable name="href">
			                    <xsl:call-template name="get-href">
			                        <xsl:with-param name="urn" select="@URN" />
			                    </xsl:call-template>
			                </xsl:variable>
		                    /<a href="{$href}"><xsl:value-of select="@xlink:title" /></a>
		                </xsl:for-each>
			        </h6>
			    </xsl:if>
		        <xsl:element name="h2" namespace="http://www.w3.org/1999/xhtml">
			        <xsl:attribute name="id">
				        <xsl:value-of select="substring-after(@URN,'domain:')" />
			        </xsl:attribute>
			        <xsl:apply-templates select="." mode="autonum" />
			        <xsl:text>.&#160;</xsl:text>
			        <xsl:value-of select="@xlink:title" />
		        </xsl:element>
		        <hr/>
		        <xsl:apply-templates select="html:*" />
			    <xsl:if test="not($level = 1)">
				    <xsl:variable name="domain" select="document(concat('images/',translate(substring-after(@URN,'domain:'),':','/'),'/domain.svg'),/)/svg:svg" />
				    <xsl:if test="$domain">
					    <p>
						    <xsl:apply-templates select="$domain" />
					    </p>
				    </xsl:if>
			    </xsl:if>
		        <xsl:if test="d:domain">
			        <div class="domains">Child domains</div>
			        <ul class="contents">
				        <xsl:apply-templates select="d:domain" mode="ToC" />
			        </ul>
		        </xsl:if>
		        <xsl:if test="d:entity">
			        <div class="entities">Domain models</div>
			        <ul class="contents">
				        <xsl:apply-templates select="d:entity" mode="ToC" />
			        </ul>
		        </xsl:if>
		        <dl>
			        <xsl:apply-templates select="d:entity" mode="content" />
		        </dl>
		        <xsl:apply-templates select="d:domain" mode="content">
			        <xsl:with-param name="level" select="$level + 1" />
		        </xsl:apply-templates>
		    </body>
		</html>
	</xsl:template>
	
	<xsl:template match="d:domain" mode="ToC">
		<li>
			<a href="{translate(@URN,':','.')}.html">
				<xsl:apply-templates select="." mode="autonum" />
				<xsl:text>.&#160;</xsl:text>
				<xsl:value-of select="@xlink:title" />
			</a>
			<xsl:if test="d:domain">
				<ul>
					<xsl:apply-templates select="d:domain" mode="ToC" />
				</ul>
			</xsl:if>
		</li>
	</xsl:template>
	
	<xsl:template match="d:domain" mode="autonum">
		<xsl:apply-templates select="parent::d:domain[parent::d:domain]" mode="autonum" />
		<xsl:if test="parent::d:domain[parent::d:domain]">.</xsl:if>
		<xsl:value-of select="count(preceding-sibling::d:domain) + 1" />
	</xsl:template>
	
	<xsl:template match="d:entity" mode="ToC">
		<li>
			<a href="{translate(@PARENT-URN,':','.')}.html#{@ID}">
				<xsl:value-of select="@xlink:title" />
			</a>
		</li>
	</xsl:template>
	
	<xsl:template match="d:entity" mode="content">
		<dt id="{@ID}">
			<xsl:value-of select="@xlink:title" />
		</dt>
		<dd>
			<p>
				<small>URN: <xsl:value-of select="@URN" /></small>
			</p>
			<p>
				<xsl:apply-templates select="d:definition" />
			</p>
			<xsl:if test="d:type">
				<p>
					<xsl:apply-templates select="d:type" />
				</p>
			</xsl:if>
			<xsl:if test="d:sample">
				<p>
					<i>Example: <xsl:apply-templates select="d:sample" /></i>
				</p>
			</xsl:if>
		</dd>
	</xsl:template>
	
	<xsl:template match="d:entity" mode="embed">
		<p id="{@URN}" class="entity">
			<strong>
				<xsl:value-of select="@xlink:title" />
			</strong>
		</p>
		<p>
			<xsl:value-of select="d:definition" />
		</p>
		<xsl:if test="d:sample">
			<p>
				<i>Example: <xsl:apply-templates select="d:sample" /></i>
			</p>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*[@xlink:href]">
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
		<xsl:variable name="link">
			<xsl:call-template name="get-href">
				<xsl:with-param name="urn" select="$urn" />
			</xsl:call-template>
		</xsl:variable>	
		
		<a href="{$link}" title="{@xlink:title}">
			<xsl:value-of select="text()" />
		</a>
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
	
	<!-- copy SVG for display -->
	<xsl:template match="svg:*">
		<xsl:element name="{local-name()}" namespace="http://www.w3.org/2000/svg">
			<xsl:for-each select="@*">
			    <xsl:choose>
			        <xsl:when test="local-name()='id'"></xsl:when>
			        <xsl:otherwise>
				        <xsl:attribute name="{local-name()}">
					        <xsl:value-of select="."/>
				        </xsl:attribute>
				    </xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<xsl:apply-templates select="node()" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="svg:svg">
		<xsl:element name="{local-name()}" namespace="http://www.w3.org/2000/svg">
			<xsl:for-each select="@*">
				<xsl:choose>
					<xsl:when test="local-name()='width'">
						<xsl:variable name="width" select="substring-before(.,'pt')" />
						<xsl:if test="$width &lt; 1000">
							<xsl:attribute name="{local-name()}">
								<xsl:value-of select="."/>
							</xsl:attribute>
						</xsl:if>
					</xsl:when>
					<xsl:when test="local-name()='height'"></xsl:when>
					<xsl:when test="local-name()='id'"></xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="{local-name()}">
							<xsl:value-of select="."/>
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<!--xsl:copy-of select="svg:*" /-->
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="svg:a[@xlink:href]">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="svg:polygon[ancestor::svg:g/@class='node']">
		<xsl:element name="{local-name()}" namespace="http://www.w3.org/2000/svg">
			<xsl:for-each select="@*">
				<!--xsl:attribute name="stroke">blue</xsl:attribute>
				<xsl:attribute name="fill">blue</xsl:attribute-->
				<xsl:choose>
					<xsl:when test="local-name()='stroke'">
						<xsl:attribute name="stroke">grey</xsl:attribute>
						<xsl:attribute name="stroke-width">2</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="{local-name()}">
							<xsl:value-of select="."/>
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="svg:text[parent::svg:a/@xlink:href]">
		<xsl:variable name="term_id" select="." />
		<xsl:variable name="font-size" select="@font-size" />
		<xsl:element name="{local-name()}" namespace="http://www.w3.org/2000/svg">
			<xsl:for-each select="@*">
			    <xsl:choose>
				    <xsl:when test="not(local-name()='font-size') and not(local-name()='font-family')">
					    <xsl:attribute name="{local-name()}">
						    <xsl:value-of select="."/>
					    </xsl:attribute>
				    </xsl:when>
				</xsl:choose>
			</xsl:for-each>
			<xsl:attribute name="fill">#005B9C</xsl:attribute>
			<xsl:variable name="link">
				<xsl:call-template name="get-href">
					<xsl:with-param name="urn" select="parent::svg:a/@xlink:href"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="title">
				<xsl:choose>
					<xsl:when test="$ENTITIES[@URN=$term_id]">
						<xsl:value-of select="$ENTITIES[@URN=$term_id]/@xlink:title" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$term_id" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="scaled-font-size">
				<xsl:choose>
					<xsl:when test="string-length($term_id) &lt; string-length($title)">
						<xsl:value-of select="$font-size * 0.9 * string-length($term_id) div string-length($title)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$font-size * .9" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:attribute name="font-family">Tahoma,serif</xsl:attribute>
			<xsl:attribute name="font-size">
				<xsl:value-of select="$scaled-font-size"/>
			</xsl:attribute>
			<a xlink:href="{$link}" xlink:title="{$term_id}" style="cursor:pointer;text-decoration:underline;">
				<xsl:value-of select="$title" />
			</a>
		</xsl:element>
	</xsl:template>
	
	<!--xsl:template name="get-link">
		<xsl:param name="urn" />
		<xsl:choose>
			<xsl:when test="starts-with($urn,'glossary:')">
				<xsl:value-of select="concat('glossary.xml#',substring-after($urn,'glossary:'))" />
			</xsl:when>
			<xsl:when test="starts-with(urn,'ucpackage:')">
				<xsl:value-of select="concat('ucpackage.xml#',substring-after($urn,'ucpackage:'))" />
			</xsl:when>
		</xsl:choose>
	</xsl:template-->
	
</xsl:stylesheet>
