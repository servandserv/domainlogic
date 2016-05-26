<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
				xmlns="http://www.w3.org/1999/xhtml"
				xmlns:html="http://www.w3.org/1999/xhtml"
				xmlns:xlink="http://www.w3.org/1999/xlink"
				xmlns:toc="urn:docs:toc"
				xmlns:d="urn:docs:domain"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:exsl="http://exslt.org/common"
				xmlns:svg="http://www.w3.org/2000/svg"
				xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	
				extension-element-prefixes="exsl"
				exclude-result-prefixes="html xlink d toc xsl xsd">
	
	<xsl:output 
		method="html"
		encoding="UTF-8"
		indent="yes"
		cdata-section-elements="script noscript"
		undeclare-namespaces="yes"
		omit-xml-declaration="yes"
		doctype-system="about:legacy-compat"/>
	
	<xsl:include href="header.xsl" />
	
	<xsl:variable name="ENTITIES" select="//d:entity" />
	
	<xsl:template match="/">
		<html xml:lang="ru">
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
				<meta name="keywords" content="domain docs"/>
				<link href='http://jumly.tmtk.net/release/jumly.min.css' rel='stylesheet'/>
				<script src='http://code.jquery.com/jquery-2.1.0.min.js'>;</script>
				<script src='http://coffeescript.org/extras/coffee-script.js'>;</script>
				<script src='http://jumly.tmtk.net/release/jumly.min.js'>;</script>
				<xsl:variable name="styles" select="document('../styles/styles.xml')/html:style" />
				<xsl:copy-of select="$styles" />
				<title>Термины и определения</title>
				<script type="text/javascript">
					window.onload = function(){
						var clName, svgEls;
						if (document.location.hash) {
							document.location = document.location;
						}
						svgEls = document.getElementsByTagName('svg');
						for(var i=0;i &lt; svgEls.length; i++) {
							clName = svgEls[i].getAttribute('class');
							if(clName == 'graph') {
								svgEls[i].onclick = function() {
									if(this.style.width) {
										this.style.width = null;
									} else {
										this.style.width = '20%';
									}
								}
								svgEls[i].onclick();
							}
						}
					}
				</script>
			</head>
			<body>
				<xsl:call-template name="header" />
				<xsl:apply-templates select="d:domains" mode="content" />
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="d:domains" mode="content">
		<h1><xsl:value-of select="@xlink:title" /></h1>
		<hr/>
		<xsl:apply-templates select="d:domain" mode="content" />
	</xsl:template>
	
	<xsl:template match="d:domain" mode="content">
		<xsl:variable name="level" select="count(ancestor-or-self::d:domain)" />
		<xsl:variable name="id" select="@URN" />
		<xsl:element name="h{$level + 1}" namespace="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="id">
				<xsl:value-of select="@URN" />
			</xsl:attribute>
			<xsl:value-of select="@xlink:title" />
		</xsl:element>
		<xsl:element name="h{$level + 2}" namespace="http://www.w3.org/1999/xhtml">Диаграмма предметной области</xsl:element>
		<p>
			<xsl:variable name="domain-addr" select="concat('images/',translate(@URN,':','/'),'/domain.svg')" />
			<xsl:variable 
				name="domain" 
				select="document($domain-addr,/)/svg:svg" />
			<xsl:apply-templates select="$domain" />
		</p>
		<xsl:if test="d:domain">
			<xsl:element name="h{$level + 2}" namespace="http://www.w3.org/1999/xhtml">Разделы</xsl:element>
			<ul>
				<xsl:apply-templates select="d:domain" mode="ToC" />
			</ul>
		</xsl:if>
		<xsl:if test="d:entity">
			<xsl:element name="h{$level + 2}" namespace="http://www.w3.org/1999/xhtml">Термины и определения</xsl:element>
			<ul>
				<xsl:apply-templates select="d:entity" mode="ToC" />
			</ul>
		</xsl:if>
		<dl>
			<xsl:apply-templates select="d:entity" mode="content" />
		</dl>
		<xsl:apply-templates select="d:domain" mode="content" />
	</xsl:template>
	
	<xsl:template match="d:domain" mode="ToC">
		<li>
			<a href="#{@URN}">
				<xsl:value-of select="@xlink:title" />
			</a>
			<xsl:if test="d:domain">
				<ul>
					<xsl:apply-templates select="d:domain" mode="ToC" />
				</ul>
			</xsl:if>
		</li>
	</xsl:template>
	
	<xsl:template match="d:entity" mode="ToC">
		<li>
			<a href="#{@URN}">
				<xsl:value-of select="@xlink:title" />
			</a>
		</li>
	</xsl:template>
	
	<xsl:template match="d:entity" mode="content">
		<dt id="{@URN}">
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
					<i>Пример: <xsl:apply-templates select="d:sample" /></i>
				</p>
			</xsl:if>
		</dd>
	</xsl:template>
	
	<xsl:template match="d:entity" mode="embed">
		<p id="{@URN}" class="term">
			<strong>
				<xsl:value-of select="@xlink:title" />
			</strong>
		</p>
		<p>
			<xsl:value-of select="d:definition" />
		</p>
		<xsl:if test="d:sample">
			<p>
				<i>Пример: <xsl:apply-templates select="d:sample" /></i>
			</p>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*[@xlink:href]">
		<a href="{@xlink:href}" title="{@xlink:title}">
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
			<xsl:copy-of select="@*" />
			<!--xsl:for-each select="@*">
				<xsl:attribute name="{local-name()}">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:for-each-->
			<xsl:apply-templates select="node()" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="svg:svg">
		<xsl:element name="{local-name()}" namespace="http://www.w3.org/2000/svg">
			<xsl:copy-of select="@viewBox" />
			<xsl:attribute name="class">graph</xsl:attribute>
			<xsl:attribute name="style">max-width:<xsl:value-of select="@width"/></xsl:attribute>
			<xsl:apply-templates select="node()" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="svg:a[@xlink:href]">
		<xsl:apply-templates select="svg:*" />
	</xsl:template>
	
	<xsl:template match="svg:text[parent::svg:a/@xlink:href]">
		<xsl:variable name="entity_id" select="." />
		<xsl:variable name="urn" select="substring-after(parent::svg:a/@xlink:href,'#')" />
		<xsl:variable name="font-size" select="@font-size" />
		<xsl:element name="{local-name()}" namespace="http://www.w3.org/2000/svg">
			<xsl:for-each select="@*">
				<xsl:if test="not(local-name()='font-size')">
					<xsl:attribute name="{local-name()}">
						<xsl:value-of select="."/>
					</xsl:attribute>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="$ENTITIES[@URN=$urn]">
				<xsl:attribute name="fill">#005A9C</xsl:attribute>
			</xsl:if>
			<xsl:variable name="title">
				<xsl:choose>
					<xsl:when test="$ENTITIES[@URN=$urn]">
						<xsl:value-of select="$ENTITIES[@URN=$urn]/@xlink:title" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$entity_id" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="scaled-font-size">
				<xsl:choose>
					<xsl:when test="string-length($entity_id) &lt; string-length($title)">
						<xsl:value-of select="number($font-size * string-length($entity_id) div string-length($title))" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$font-size" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:attribute name="font-size">
				<xsl:value-of select="$scaled-font-size"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$ENTITIES[@URN=$urn]">
					<xsl:element name="a">
						<xsl:attribute name="onclick">
							document.location='<xsl:value-of select="parent::svg:a/@xlink:href" />';
						</xsl:attribute>
						<xsl:attribute name="href">
							<xsl:value-of select="parent::svg:a/@xlink:href" />
						</xsl:attribute>
						<xsl:attribute name="title">
							<xsl:value-of select="$urn" />
						</xsl:attribute>
						<xsl:attribute name="style">text-decoration:underline;cursor:pointer;</xsl:attribute>
						<xsl:value-of select="$title" />
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$title" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	
</xsl:stylesheet>
