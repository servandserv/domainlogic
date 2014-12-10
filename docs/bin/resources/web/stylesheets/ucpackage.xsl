<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:wadl="http://wadl.dev.java.net/2009/02"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:toc="urn:docs:toc"
	xmlns:d="urn:docs:domain"
	xmlns:uc="urn:docs:ucpackage"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	extension-element-prefixes="exsl"
    exclude-result-prefixes="xlink d toc uc xsl wadl">
	
    <xsl:output 
		method="html"
		encoding="UTF-8"
		indent="yes"
		cdata-section-elements="script noscript"
		undeclare-namespaces="yes"
		omit-xml-declaration="yes"
		doctype-system="about:legacy-compat" />
	
	<xsl:include href="header.xsl" />
	
	<xsl:template match="uc:ucpackages">
		<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ru">
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
				<meta name="keywords" content="docs usecases"/>
				<link href='http://jumly.tmtk.net/release/jumly.min.css' rel='stylesheet'/>
				<script src='http://code.jquery.com/jquery-2.1.0.min.js'>;</script>
				<script src='http://coffeescript.org/extras/coffee-script.js'>;</script>
				<script src='http://jumly.tmtk.net/release/jumly.min.js'>;</script>
				<xsl:variable name="styles" select="document('../styles/styles.xml')/html:style" />
				<xsl:copy-of select="$styles" />
				<title>Прецеденты использования</title>
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
				<h1><xsl:value-of select="@xlink:title" /></h1>
				<hr/>
				<xsl:apply-templates select="uc:ucpackage" mode="content" />
			</body>
		</html>
		
	</xsl:template>
	
	<xsl:template match="uc:ucpackage" mode="content">
		<xsl:variable name="level" select="count(ancestor-or-self::uc:ucpackage)" />
		<xsl:element name="h{$level + 1}" namespace="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="id"><xsl:value-of select="@URN" /></xsl:attribute>
			<xsl:value-of select="@xlink:title" />
		</xsl:element>
		<xsl:if test="uc:ucpackage">
			<xsl:element name="h{$level + 2}" namespace="http://www.w3.org/1999/xhtml">
				Пакеты прецедентов
			</xsl:element>
			<ul>
				<xsl:apply-templates select="uc:ucpackage" mode="ToC" />
			</ul>
		</xsl:if>
		<xsl:element name="h{$level + 2}" namespace="http://www.w3.org/1999/xhtml">
				Диаграмма прецедентов
		</xsl:element>
		<xsl:variable 
				name="graph" 
				select="document(concat('tmp/images/',translate(@URN,':','/'),'/ucpackage.svg'),/)/svg:svg" />
		<xsl:apply-templates select="$graph" />
		<xsl:if test="uc:actor">
			<xsl:element name="h{$level + 2}" namespace="http://www.w3.org/1999/xhtml">
				Пользователи
			</xsl:element>
			<ul>
				<xsl:for-each select="uc:actor">
					<li><a href="{@xlink:href}" ><xsl:value-of select="@xlink:title" /></a></li>
				</xsl:for-each>
			</ul>
		</xsl:if>
		<xsl:if test="uc:usecase">
			<xsl:element name="h{$level + 2}" namespace="http://www.w3.org/1999/xhtml">
				Прецеденты пакета
			</xsl:element>
			<ul>
				<xsl:apply-templates select="uc:usecase" mode="ToC" />
			</ul>
		</xsl:if>
		<xsl:apply-templates select="uc:usecase" mode="content"  />
		<xsl:apply-templates select="uc:ucpackage" mode="content"  />
	</xsl:template>
	
	<xsl:template match="uc:ucpackage" mode="ToC">
		<li>
			<a href="#{@URN}"><xsl:value-of select="@xlink:title" /></a>
			<xsl:if test="uc:ucpackage">
				<ul>
					<xsl:apply-templates select="uc:ucpackage" mode="ToC" />
				</ul>
			</xsl:if>
		</li>
	</xsl:template>
	
	<xsl:template match="uc:usecase" mode="ToC">
		<li>
			<a href="#{@URN}"><xsl:value-of select="@xlink:title" /></a>
		</li>
	</xsl:template>
	
	<xsl:template match="uc:usecase" mode="content">
		<xsl:element name="h{count(ancestor::uc:ucpackage)+3}" namespace="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="id">
				<xsl:value-of select="@URN" />
			</xsl:attribute>
			<xsl:value-of select="@xlink:title" />
		</xsl:element>
		<p><small>URN: <xsl:value-of select="@URN" /></small></p>
		<p style="font-size:90%;padding-left:20px;">
			<xsl:apply-templates />
		</p>
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
				<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
			<xsl:apply-templates select="node()" />
		</xsl:element>
	</xsl:template>
	
	<!-- copy SVG for display -->
	<xsl:template match="svg:*">
		<xsl:element name="{local-name()}" namespace="http://www.w3.org/2000/svg">
			<xsl:for-each select="@*">
				<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
			<xsl:apply-templates select="node()" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="svg:svg">
		<xsl:element name="{local-name()}" namespace="http://www.w3.org/2000/svg">
			<xsl:copy-of select="@viewBox" />
			<xsl:attribute name="id">graph<xsl:value-of select="'d'" /></xsl:attribute>
			<xsl:attribute name="class">graph</xsl:attribute>
			<xsl:attribute name="style">max-width:<xsl:value-of select="@width"/>;</xsl:attribute>
			<xsl:apply-templates select="node()" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="svg:a[@xlink:href]">
		<xsl:element name="a" namespace="http://www.w3.org/2000/svg">
			<xsl:for-each select="@*">
				<xsl:choose>
					<xsl:when test="local-name() = 'href'">
						<xsl:attribute name="href" namespace="http://www.w3.org/1999/xlink">
							<xsl:value-of select="." />
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<xsl:apply-templates select="node()" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="svg:text[parent::svg:a/@xlink:href]">
		<xsl:variable name="term_id" select="." />
		<xsl:element name="{local-name()}" namespace="http://www.w3.org/2000/svg">
			<xsl:for-each select="@*">
				<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
			<xsl:attribute name="fill">blue</xsl:attribute>
			<xsl:attribute name="style">text-decoration:underline;</xsl:attribute>
			<xsl:apply-templates select="node()" />
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>
