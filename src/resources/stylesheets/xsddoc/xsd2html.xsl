<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:glo="urn:ru:battleship:meta:glossary:glossary"
	xmlns:exsl="http://exslt.org/common"
	extension-element-prefixes="exsl"
    exclude-result-prefixes="html xlink glo xsl">
	
	<xsl:output
        media-type="application/xhtml+xml"
        method="xml"
        encoding="UTF-8"
        indent="yes"
        omit-xml-declaration="no"
        doctype-public="-//W3C//DTD XHTML 1.1//EN"
        doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" />
	
	<xsl:include href="../header.xsl" />
	
	<!-- контейнер для терминов -->
	<!-- находим path для загрузки документов ориентируемся на uri  targetNamespace схемы  -->
	<xsl:variable name="project-root">
		<xsl:text>../</xsl:text>
		<xsl:call-template name="get-root">
			<xsl:with-param name="path" select="substring-after(/xsd:schema/@targetNamespace,'urn:ru:battleship:meta:')"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="glossary">
		<xsl:variable name="source" select="document(concat($project-root,'Glossary.xml'),/)/glo:glossary"  />
		<xsl:apply-templates select="$source/glo:glossary[@xlink:type='locator']" mode="include-glossary" />
	</xsl:variable>

	<xsl:template match="glo:glossary[@xlink:type='locator']" mode="include-glossary">
		<xsl:variable name="included" select="document(@xlink:href, /)/glo:glossary/glo:term"></xsl:variable>
		<xsl:element name="glo:glossary">
			<xsl:attribute name="type" namespace="http://www.w3.org/1999/xlink">resource</xsl:attribute>
			<xsl:attribute name="href" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="@xlink:href"/>
			</xsl:attribute>
			<xsl:attribute name="title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="@xlink:title"/>
			</xsl:attribute>
			<xsl:attribute name="label" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="@xlink:label"/>
			</xsl:attribute>
			<xsl:copy-of select="$included"/>
		</xsl:element>
	</xsl:template>
	
	
	<xsl:template match="/">
		<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ru">
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
				<meta name="keywords" content="xml to html converter"/>
				<title>Documentation</title>
				<link rel="stylesheet" type="text/css" href="{$project-root}/styles/documentation.css" />
				<style type="text/css">
					.xml2html * { color:#000000; font-family:sans-serif; }
					.xml2html { font-family:monospace; background: none; }
					.xml2html div.xml2html { margin: 0 0 0 0.5em; }
					.xml2html .elementcontent { color:#3c3c3c; }
					.xml2html div.comment { white-space: pre; color: #cc9999; }
					.xml2html span.xml2html.starttag, .xml2html span.xml2html.endtag {	
						color:maroon; 
					}
					.xml2html span.xml2html.attributename {
						font-weight:normal; color: black;font-style:italic; 
					}
					.xml2html span.xml2html.attributevalue {
						font-weight: normal; font-style: italic; color: #3c3c3c;
					}
					.term {color:#DB3706;}
				</style>
			</head>
			<body>
				<xsl:call-template name="header">
					<xsl:with-param name="path" select="$project-root" />
				</xsl:call-template>
				<h1>XML Schema Documentation</h1>
				<hr/>
				<h2>Table of Contents</h2>
				<h3>Global declarations</h3>
				<ul>
					<xsl:apply-templates select="xsd:schema/xsd:element" mode="ToC" />
				</ul>
				<h3>Global definitions</h3>
				<ul>
					<xsl:apply-templates select="xsd:schema/xsd:complexType | xsd:schema/xsd:simpleType| xsd:schema/xsd:group | xsd:schema/xsd:attributeGroup" mode="ToC" />
				</ul>
				
				<h2>XML Schema</h2>
				<div class="xml2html root" xml:space="default" >
					<xsl:apply-templates select="*"/>
				</div>
			</body>
		</html>
	</xsl:template>


	<xsl:template match="xsd:element | xsd:simpleType | xsd:complexType | xsd:group | xsd:attributeGroup" mode="ToC">
		<li>
			<a href="#{@name}"><xsl:value-of select="local-name()" />: <xsl:value-of select="@name" /></a>
			<xsl:apply-templates select="." mode="simple" />
		</li>
	</xsl:template>


	<xsl:template match="xsd:simpleType[xsd:restriction/xsd:enumeration]" mode="simple">
		<table>
			<tr>
				<th>Значение</th>
				<xsl:for-each select="xsd:restriction/xsd:enumeration[1]/xsd:annotation/xsd:appinfo/child::*">
					<th>
						<xsl:value-of select="local-name()" /><br/>
						<small style="white-space:nowrap"><xsl:value-of select="namespace-uri()" /></small>
					</th>
				</xsl:for-each>
				<th>Комментарий</th>
			</tr>
			<xsl:for-each select="xsd:restriction/xsd:enumeration">
				<tr>
					<td><xsl:value-of select="@value" /></td>
					<xsl:for-each select="xsd:annotation/xsd:appinfo">
						<td><xsl:value-of select="." /></td>
					</xsl:for-each>
					<td><xsl:value-of select="xsd:annotation/xsd:documentation" /></td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>
	
	<xsl:template match="*" mode="simple" />

	<!-- ==================================================== -->
	<!-- = Processing of elements                           = -->
	<!-- ==================================================== -->
	<xsl:template match="*">
		<div class="element xml2html">
			<xsl:if test="@name">
				<xsl:attribute name="id"><xsl:value-of select="@name" /></xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@xlink:show='embed'">
					<span class="starttag xml2html">
						&lt;<xsl:value-of select="name()"/>
						<xsl:apply-templates select="." mode="process-ns-declarations"/>
						<xsl:apply-templates select="@*"/>&gt;
					</span>
					<xsl:variable name="urn" select="substring-after(@xlink:href,'#')" />
					<xsl:variable name="term" select="exsl:node-set($glossary)/glo:glossary/glo:term[@ID=$urn]" />
					<xsl:apply-templates select="$term" mode="embed" />
					<xsl:if test="*|comment()|processing-instruction()|text()">
						<div class="elementcontent xml2html">
							<xsl:apply-templates select="*|comment()|processing-instruction()|text()"/>
						</div>
					</xsl:if>
					<span class="endtag xml2html">&lt;/<xsl:value-of select="name()"/>&gt;</span>
				</xsl:when>
				<xsl:when test="not(node())">
					<span class="starttag xml2html">
						&lt;<xsl:value-of select="name()"/>
						<xsl:apply-templates select="." mode="process-ns-declarations"/>
						<xsl:apply-templates select="@*"/>&#160;/&gt;
					</span>
				</xsl:when>
				<xsl:otherwise>
					<span class="starttag xml2html">
						<xsl:text>&lt;</xsl:text>
						<xsl:value-of select="name()"/>
						<xsl:apply-templates select="." mode="process-ns-declarations"/>
						<xsl:apply-templates select="@*"/>
						<xsl:text>&gt;</xsl:text>
					</span>
					<xsl:if test="*|comment()|processing-instruction()">
						<div class="elementcontent xml2html">
							<xsl:apply-templates select="*|comment()|processing-instruction()"/>
						</div>
					</xsl:if>
					<xsl:if test="text()">
						<xsl:value-of select="text()" />
					</xsl:if>
					<span class="endtag xml2html">&lt;/<xsl:value-of select="name()"/>&gt;</span>
				</xsl:otherwise>
			</xsl:choose>
		</div>
    </xsl:template>

	<!-- ==================================================== -->
	<!-- = Processing of attributes                         = -->
	<!-- ==================================================== -->
    <xsl:template match="@*">
		<xsl:choose>
			<xsl:when test="local-name()='schemaLocation'">
				<xsl:text> </xsl:text><span class="attributename xml2html"><xsl:value-of select="name()"/></span><xsl:text>="</xsl:text>
					<a href="{.}">
						<xsl:value-of select="." />
					</a><xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:when test="namespace-uri()='http://www.w3.org/1999/xlink' and local-name()='href'">
					<xsl:variable name="urn" select="substring-after(.,'#')" />
					<xsl:variable name="term" select="exsl:node-set($glossary)/glo:glossary/glo:term[@ID=$urn]" />
					<xsl:text> </xsl:text><span class="attributename xml2html"><xsl:value-of select="name()"/></span><xsl:text>="</xsl:text>
					<a href="{$project-root}{$term/ancestor::glo:glossary/@xlink:href}#{$urn}">
						<xsl:value-of select="$term/@xlink:title" />
					</a><xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> </xsl:text><span class="attributename xml2html"><xsl:value-of select="name()"/></span><xsl:text>="</xsl:text><span class="attributevalue xml2html"><xsl:value-of select="."/></span><xsl:text>"</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
    </xsl:template>

	<!-- ==================================================== -->
	<!-- = Processing of PIs                                = -->
	<!-- ==================================================== -->
    <xsl:template match="processing-instruction()">
        <div class="pi xml2html">&lt;?<xsl:value-of select="local-name()"/><xsl:text> </xsl:text><xsl:value-of select="."/>?&gt;</div>
	</xsl:template>
	<!-- ==================================================== -->
	<!-- = Processing of comments                           = -->
	<!-- ==================================================== -->
	<xsl:template match="comment()">
		<div class="comment xml2html">&lt;!-- <xsl:value-of select="."/> --&gt;</div>
	</xsl:template>

	<!-- ==================================================== -->
	<!-- = Processing of namespace declarations             = -->
	<!-- ==================================================== -->
	<xsl:template match="*|@*" mode="process-ns-declarations">
		<!-- Process namespace of the element -->
		<xsl:if test="namespace-uri() != ''">
			<xsl:variable name="ns-prefix">
				<xsl:value-of select="substring-before(substring-before(name(),local-name()),':')"/>
			</xsl:variable>
			<xsl:variable name="ns-prefix-withcolon">
				<xsl:choose>
					<xsl:when test="$ns-prefix = ''"/>
					<xsl:otherwise>
						<xsl:text>:</xsl:text>
						<xsl:value-of select="$ns-prefix"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="not(ancestor::*[(namespace-uri() = namespace-uri(current())) and (substring-before(name(),local-name()) = substring-before(name(current()),local-name(current())))])">
        		<xsl:text> </xsl:text><span class="attributename xml2html">xmlns<xsl:value-of select="$ns-prefix-withcolon"/></span><xsl:text>="</xsl:text><span class="attributevalue xml2html"><xsl:value-of select="namespace-uri()"/></span><xsl:text>"</xsl:text>
			</xsl:if>
		</xsl:if>
		<!-- Process namespaces of the attributes-->
		<xsl:for-each select="./@*">
			<xsl:apply-templates select="." mode="process-ns-declarations"/>
		</xsl:for-each>
	</xsl:template>
	
	<!-- шаблоны для отображения терминов из глоссария -->
	<xsl:template match="glo:glossary" mode="embed">
		<h2 id="{@xlink:label}"><xsl:value-of select="@xlink:title" /></h2>
		<h3>Термины и определения</h3>
		<ul>
			<xsl:apply-templates select="glo:term" mode="ToC" />
		</ul>
		<xsl:apply-templates select="glo:term" mode="embed" />
	</xsl:template>
	
	<xsl:template match="glo:term" mode="embed">
		<p id="{@ID}" class="term">
			<strong>
				<xsl:value-of select="@xlink:title" />
			</strong>
		</p>
		<p><xsl:value-of select="glo:definition" /></p>
		<xsl:if test="glo:sample">
			<p><i>Пример: <xsl:value-of select="glo:sample" /></i></p>
		</xsl:if>
	</xsl:template>
	
	<!-- utils -->
	<xsl:template name="get-root">
		<xsl:param name="path" />
		<xsl:if test="contains($path, ':')">
			<xsl:text>../</xsl:text>
			<xsl:call-template name="get-root">
				<xsl:with-param name="path" select="substring-after($path,':')" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
