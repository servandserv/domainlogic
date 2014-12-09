<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:d="urn:docs:domain"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	extension-element-prefixes="exsl"
    exclude-result-prefixes="html xlink d xsl">
	
    <xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
	
	<!-- пространство имен домена  -->
	<xsl:param name="NS" />
	
	<!-- глобальные переменные сделаем UPPERCASE  чтобы отличать их в коде  -->
	<!--xsl:variable name="ROOT" select="/" />
	<xsl:variable name="DOMAIN-ID" select="$NS" /-->
	<!--xsl:variable name="DOMAIN-TITLE" select="/d:domain/@xlink:title" /-->
	<!--xsl:variable name="DOMAIN-HREF" select="/d:domain/@xlink:href" /-->
	<!-- путь от файла пакета до корня проекта  -->
	<!--xsl:variable name="PROJECT-BASE">
		<xsl:call-template name="get-base">
			<xsl:with-param name="path" select="$DOMAIN-ID"/>
		</xsl:call-template>
	</xsl:variable-->
	
	<xsl:variable name="DOMAIN-SET" select="document('domain.xml',/)" />
	<xsl:variable name="DOMAIN-ENTITIES" select="$DOMAIN-SET//d:domain[@URN = $NS]//d:entity" />
	<xsl:variable name="DOMAIN-TITLE" select="$DOMAIN-SET//d:domain[@URN = $NS]/@xlink:title" />
	<xsl:variable name="ENTITIES-SET" select="$DOMAIN-SET//d:entity" />
	
	<xsl:variable name="NODES">
		<!--  выбираем термины для рисования диаграмм -->
		<xsl:for-each select="$DOMAIN-ENTITIES">
			<!-- Из всех терминов текущего глоссария выберем те в тексте которых определены связи типа обобщения и агрегации -->
			<xsl:if test=".//d:has-a or .//d:has-many or .//d:is-a">
				<xsl:element name="node">
					<xsl:value-of select="@URN" />
				</xsl:element>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$DOMAIN-ENTITIES//d:is-a">
			<!-- далее переберем термины  упоминавшиеся в отношениях типа обобшения (is-a) терминов текущего глоссария -->
			<xsl:variable name="tail_urn" select="ancestor::d:entity/@URN" />
			<xsl:variable name="head_urn">
				<xsl:apply-templates select="." mode="urn" />
			</xsl:variable>
			<xsl:for-each select="$ENTITIES-SET[@URN=$head_urn]">
				<!-- среди всех терминов всех глоссариев которые упоминались в текущем -->
				<xsl:if test="not(.//d:has-a) and not(.//d:has-many) and not(.//d:is-a)">
					<!-- добавим те которые не имеют в описании отношений с другими терминами -->
					<xsl:element name="node">
						<xsl:value-of select="@URN" />
					</xsl:element>
				</xsl:if>
				<xsl:if test="not($DOMAIN-ENTITIES[@URN=$head_urn])">
					<!-- добавим те, которые находятся за пределами текущего глоссария -->
					<xsl:element name="node">
						<xsl:value-of select="@URN" />
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
		<xsl:for-each select="$DOMAIN-ENTITIES//d:has-many">
			<!-- Среди терминов текущего глоссария которые содержат отношения типа has-many найдем эти связанные термины-->
			<xsl:variable name="urn">
				<!-- определим их urn -->
				<xsl:apply-templates select="." mode="urn" />
			</xsl:variable>
			<xsl:for-each select="$ENTITIES-SET[@URN=$urn]">
				<!-- Среди всех терминов всех глоссариев найдем совпадение по urn -->
				<xsl:if test="not(.//d:has-a) and not(.//d:has-many) and not(.//d:is-a)">
					<!-- Выберем те которые не имеют в описании отношений с другими терминами -->
					<xsl:element name="node">
						<xsl:value-of select="$urn" />
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:variable name="NODES-SET" select="exsl:node-set($NODES)" />
	
	<xsl:template match="/">
		<xsl:call-template name="domain" />
	</xsl:template>
	
	<!-- dot -->
	<xsl:template name="domain">
		<xsl:text disable-output-escaping="yes">
		digraph domain_</xsl:text>
		<xsl:value-of select="translate($NS,':','_')" />
		<!--xsl:text>{
			label="</xsl:text>
		<xsl:value-of select="$DOMAIN-TITLE" /-->
		<!--URL="images/generated/<xsl:value-of select="translate(substring-after($GLOSSARY-ID,'glossary:'),':','/')" />/domain.svg";-->
		<xsl:text disable-output-escaping="yes">{
			labelloc=b
			labeljust=r;
			fontsize=14;
			fontcolor="#0000cc";
			rankdir=LR;
			compound=true;
			node [shape=none, margin=0,fontname=Tahoma];
			</xsl:text>
		<!-- нарисуем все отобранные узлы -->
		<xsl:apply-templates select="$ENTITIES-SET[@URN=$NODES-SET/*]" mode="node" />
		<xsl:text disable-output-escaping="yes">
			edge [dir="back",arrowtail="odiamond"];
		</xsl:text>
		<xsl:apply-templates select="$DOMAIN-ENTITIES//d:has-a" mode="edge" />
		<xsl:text disable-output-escaping="yes">
			edge [dir="back",arrowtail="odiamond",headlabel="*"];
		</xsl:text>
		<xsl:apply-templates select="$DOMAIN-ENTITIES//d:has-many" mode="edge" />
		<xsl:text disable-output-escaping="yes">
			edge [dir="forward",arrowhead="onormal",headlabel=""];
		</xsl:text>
		<xsl:apply-templates select="$DOMAIN-ENTITIES//d:is-a" mode="edge" />
		<xsl:text>
		}</xsl:text>
	</xsl:template>
	
	<xsl:template match="d:entity" mode="node">
		<xsl:variable name="term_id" select="@ID" />
		<xsl:value-of select="translate(@URN,':','_')" />
		<xsl:text>[label=&lt;&lt;TABLE BORDER="0" CELLPADDING="8" CELLSPACING="0"&gt;</xsl:text>
		<xsl:call-template name="make-field">
			<xsl:with-param name="urn" select="@URN" />
			<xsl:with-param name="type" select="'domainname'" />
		</xsl:call-template>
		<xsl:if test="d:definition//d:*[local-name()='has-a' or local-name()='has-many']">
			<xsl:for-each select="d:definition//d:*[local-name()='has-a' or local-name()='has-many']">
				<xsl:variable name="field_urn">
					<xsl:apply-templates select="." mode="urn" />
				</xsl:variable>
				<!--xsl:if test="not($NODES-SET/* = $field_urn)"-->
					<xsl:call-template name="make-field">
						<xsl:with-param name="urn" select="$field_urn" />
						<xsl:with-param name="type" select="'property'" />
					</xsl:call-template>
				<!--/xsl:if-->
			</xsl:for-each>
		</xsl:if>
		<xsl:text>&lt;/TABLE&gt;&gt;];
			</xsl:text>
	</xsl:template>
	
	<xsl:template match="d:has-a | d:has-many" mode="edge">
		<xsl:variable name="tail_urn" select="ancestor::d:entity/@URN" />
		<xsl:variable name="head_urn">
			<xsl:apply-templates select="." mode="urn" />
		</xsl:variable>
		<xsl:variable name="port" select="translate($head_urn,':','_')" />
		<xsl:if test="$NODES-SET[child::*=$head_urn]">
			<xsl:value-of select="translate($tail_urn,':','_')" />
			<xsl:text>:</xsl:text>
			<xsl:value-of select="$port" />
			<xsl:text> -&gt; </xsl:text>
			<xsl:value-of select="translate($head_urn,':','_')" />;
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="d:is-a" mode="edge">
		<xsl:variable name="tail_urn" select="translate(ancestor::d:entity/@URN,':','_')" />
		<xsl:variable name="head_urn">
			<xsl:apply-templates select="." mode="urn" />
		</xsl:variable>
		<xsl:value-of select="$tail_urn" />:<xsl:value-of select="$tail_urn" />
		<xsl:text> -&gt; </xsl:text>
		<xsl:value-of select="translate($head_urn,':','_')" />;
		
	</xsl:template>
	
	<!-- utils -->
	<!--xsl:template name="get-base">
		<xsl:param name="path" />
		<xsl:if test="contains($path, ':')">
			<xsl:text>../</xsl:text>
			<xsl:call-template name="get-base">
				<xsl:with-param name="path" select="substring-after($path,':')" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template-->
	
	<xsl:template name="make-field">
		<xsl:param name="urn" />
		<xsl:param name="type" />
		<xsl:variable name="entity_node" select="$ENTITIES-SET[@URN=$urn]" />
		<xsl:variable name="title" select="$entity_node/@xlink:title" />
		<xsl:text>&lt;TR&gt;&lt;TD ALIGN="CENTER" HREF="</xsl:text>
		<xsl:choose>
			<xsl:when test="$entity_node">
				<xsl:value-of select="$entity_node/@xlink:href" />
			</xsl:when>		
			<xsl:otherwise>#<xsl:value-of select="$urn" /></xsl:otherwise>
		</xsl:choose>
		<xsl:text>" TITLE="</xsl:text>
		<xsl:choose>
			<xsl:when test="$entity_node"><xsl:value-of select="$entity_node/@URN" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="$urn" /></xsl:otherwise>
		</xsl:choose>
		<xsl:text>" PORT="</xsl:text>
		<xsl:value-of select="translate($urn,':','_')" />
		<xsl:choose>
			<xsl:when test="$type='domainname'">
				<xsl:text>" BGCOLOR="#dddddd"&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>" BGCOLOR="#ffffff"&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&lt;FONT</xsl:text>
		<xsl:choose>
			<xsl:when test="$title">
				<xsl:text> COLOR="#0000cc"&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> COLOR="#3c3c3c"&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="$title">
				<xsl:value-of select="translate($title,' ','&#160;')" />
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="substring-after($urn,concat($NS,':'))" /></xsl:otherwise>
		</xsl:choose>
		<xsl:text>&lt;/FONT&gt;&lt;/TD&gt;&lt;/TR&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="*[@xlink:href]" mode="urn">
		<xsl:choose>
			<xsl:when test="substring-after(@xlink:href,'#')">
				<xsl:value-of select="substring-after(@xlink:href,'#')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>../../</xsl:text>
				<xsl:value-of select="substring-before(@xlink:href,':')" />
				<xsl:text>/docs/domain.html#</xsl:text>
				<xsl:value-of select="@xlink:href" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
