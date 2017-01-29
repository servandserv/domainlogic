<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:d="urn:com:servandserv:domainlogic:domain"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	extension-element-prefixes="exsl"
    exclude-result-prefixes="html xlink d xsl">
	
    <xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

    <xsl:param name="PACKAGE" />
	<xsl:variable name="ROOT" select="/d:domain" />
	<xsl:variable name="DOMAIN-URN" select="$PACKAGE" />
	<!--xsl:variable name="PROJECT-BASE">
		<xsl:call-template name="get-base">
			<xsl:with-param name="path" select="$GLOSSARY-ID"/>
		</xsl:call-template>
	</xsl:variable-->
	
	<xsl:variable name="DOMAIN-ENTITIES" select="$ROOT//d:domain[@URN = $PACKAGE]//d:entity" />
	<xsl:variable name="ENTITIES-SET" select="$ROOT//d:entity" />
	
	<!-- prepare node list for dot diagramm -->
	<xsl:variable name="NODES">
		<!--  get entities from selected domain -->
		<xsl:for-each select="$DOMAIN-ENTITIES">
			<!-- select entities from current domain with logic links to other entities -->
			<xsl:choose>
				<xsl:when test=".//d:has-a">
					<xsl:element name="node">
						<xsl:value-of select="@URN" />
					</xsl:element>
				</xsl:when>
				<xsl:when test=".//d:has-many">
				    <xsl:element name="node">
				        <xsl:value-of select="@URN" />
				    </xsl:element>
				</xsl:when>
				<xsl:when test=".//d:is-a">
				    <xsl:element name="node">
				        <xsl:value-of select="@URN" />
				    </xsl:element>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<!-- then find entities from full set witch linked to entities in current domain -->
		<xsl:for-each select="$DOMAIN-ENTITIES//d:is-a">
			<xsl:variable name="tail_urn" select="ancestor::d:entity/@URN" />
			<xsl:variable name="head_urn">
				<xsl:apply-templates select="." mode="urn" />
			</xsl:variable>
			<xsl:for-each select="$ENTITIES-SET[@URN=$head_urn]">
				<xsl:if test="not(.//d:has-a) and not(.//d:has-many) and not(.//d:is-a)">
				    <!-- if hasn't linked entities but has childs -->
					<xsl:element name="node">
						<xsl:value-of select="@URN" />
					</xsl:element>
				</xsl:if>
				<xsl:if test="not($DOMAIN-ENTITIES[@URN=$head_urn])">
					<!-- entities from other domains -->
					<xsl:element name="node">
						<xsl:value-of select="@URN" />
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
		<xsl:for-each select="$DOMAIN-ENTITIES//d:has-many">
			<xsl:variable name="tail_urn" select="ancestor::d:entity/@URN" />
			<xsl:variable name="head_urn">
				<xsl:apply-templates select="." mode="urn" />
			</xsl:variable>
			<xsl:for-each select="$ENTITIES-SET[@URN=$head_urn]">
				<xsl:if test="not(.//d:has-a) and not(.//d:has-many) and not(.//d:is-a)">
					<xsl:element name="node">
						<xsl:value-of select="@URN" />
					</xsl:element>
				</xsl:if>
				<xsl:if test="not($DOMAIN-ENTITIES[@URN=$head_urn])">
					<xsl:element name="node">
						<xsl:value-of select="@URN" />
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
		<xsl:for-each select="$DOMAIN-ENTITIES//d:has-a">
			<xsl:variable name="tail_urn" select="ancestor::d:entity/@URN" />
			<xsl:variable name="head_urn">
				<xsl:apply-templates select="." mode="urn" />
			</xsl:variable>
			<xsl:for-each select="$ENTITIES-SET[@URN=$head_urn]">
				<xsl:if test="not(.//d:has-a) and not(.//d:has-many) and not(.//d:is-a)">
					<xsl:element name="node">
						<xsl:value-of select="@URN" />
					</xsl:element>
				</xsl:if>
				<xsl:if test="not($DOMAIN-ENTITIES[@URN=$head_urn])">
					<xsl:element name="node">
						<xsl:value-of select="@URN" />
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
        <xsl:text>digraph </xsl:text>
        <xsl:value-of select="translate($DOMAIN-URN,':','_')" />
        <xsl:text> {
	labelloc=b;
	labeljust=r;
	fontsize=18;
	fontcolor="#0000cc";
	rankdir=LR;
	compound=true;
	node [shape=none,margin=0];
        </xsl:text>
        <!-- draw selected nodes -->
        <xsl:apply-templates select="$ENTITIES-SET[@URN=$NODES-SET/*]" mode="node" />
        <xsl:text>
	edge [dir="back",arrowtail="odiamond"];
        </xsl:text>
        <xsl:apply-templates select="$DOMAIN-ENTITIES//d:has-a" mode="edge" />
        <xsl:text>
	edge [dir="back",arrowtail="odiamond",headlabel="*"];
		</xsl:text>
		<xsl:apply-templates select="$DOMAIN-ENTITIES//d:has-many" mode="edge" />
		<xsl:text>
	edge [dir="forward",arrowhead="onormal",headlabel=""];
		</xsl:text>
		<xsl:apply-templates select="$DOMAIN-ENTITIES//d:is-a" mode="edge" />
	    <xsl:text>
}
        </xsl:text>
	</xsl:template>
	
	<xsl:template match="d:entity" mode="node">
		<xsl:variable name="term_id" select="@URN" />
		<xsl:value-of select="translate(@URN,':','_')" />
		<xsl:text> [id="</xsl:text>
		<xsl:value-of select="@URN" />
		<xsl:text>",label=&lt;&lt;TABLE BORDER="0" CELLPADDING="8" CELLSPACING="0"&gt;</xsl:text>
		<xsl:call-template name="make-field">
			<xsl:with-param name="urn" select="@URN" />
			<xsl:with-param name="id" select="@URN" />
			<xsl:with-param name="type" select="'domainname'" />
		</xsl:call-template>
		<xsl:if test="d:definition//d:*[local-name()='has-a' or local-name()='has-many']">
			<xsl:for-each select="d:definition//d:*[local-name()='has-a' or local-name()='has-many']">
				<!--xsl:if test="position()=1">
					<xsl:text>&lt;tr&gt;&lt;td border="1"&gt;&lt;/td&gt;&lt;/tr&gt;</xsl:text>
				</xsl:if-->
				<xsl:variable name="field_urn">
					<xsl:apply-templates select="." mode="urn" />
				</xsl:variable>
				<xsl:if test="not($NODES-SET/* = $field_urn)">
					<xsl:call-template name="make-field">
						<xsl:with-param name="urn" select="$field_urn" />
						<xsl:with-param name="id" select="$field_urn" />
						<xsl:with-param name="type" select="'property'" />
					</xsl:call-template>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:text>&lt;/TABLE&gt;&gt;</xsl:text>];
	</xsl:template>
	
	<xsl:template match="d:has-a | d:has-many" mode="edge">
		<xsl:variable name="tail_urn" select="ancestor::d:entity/@URN" />
		<xsl:variable name="head_urn">
			<xsl:apply-templates select="." mode="urn" />
		</xsl:variable>
		<xsl:variable name="port" select="translate($head_urn,':','_')" />
				
		<xsl:if test="$NODES-SET[child::*=$head_urn]">
			<xsl:value-of select="translate($tail_urn,':','_')" />
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
	<xsl:template name="make-field">
		<xsl:param name="urn" />
		<xsl:param name="id" />
		<xsl:param name="type" />
		<xsl:variable name="term_node" select="$ENTITIES-SET[@URN=$urn]" />
		<xsl:variable name="title" select="$term_node/@xlink:title" />
		<xsl:text>&lt;TR&gt;&lt;TD ALIGN="CENTER" HREF="</xsl:text>
		<xsl:value-of select="$urn" />
		<xsl:text>" TITLE="</xsl:text>
		<xsl:value-of select="$term_node/@URN" />
		<xsl:text>" PORT="</xsl:text>
		<xsl:value-of select="translate($id,':','_')" />
		<xsl:text>"</xsl:text>
		<xsl:choose>
			<xsl:when test="$type='domainname'">
				<xsl:text> BGCOLOR="#dddddd"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> BGCOLOR="#ffffff"</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&gt;</xsl:text>
		<xsl:text>&lt;FONT</xsl:text>
		<xsl:choose>
			<xsl:when test="$title">
				<xsl:text> COLOR="#0000cc"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> COLOR="#005A9C"</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&gt;</xsl:text>
		<xsl:choose>
			<xsl:when test="$title"><xsl:value-of select="translate($title,' ','&#160;')" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="$urn" /></xsl:otherwise>
		</xsl:choose>
		<xsl:text>&lt;/FONT&gt;</xsl:text>
		<xsl:text>&lt;/TD&gt;&lt;/TR&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="*[@xlink:href]" mode="urn">
		<xsl:choose>
			<xsl:when test="substring-after(@xlink:href,'#')">
				<xsl:value-of select="concat(ancestor::d:domain[1]/@URN,':',substring-after(@xlink:href,'#'))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@xlink:href" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
