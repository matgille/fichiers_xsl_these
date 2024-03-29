<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:myfunctions="https://www.matthiasgillelevenson.fr/ns/1.0" xmlns:tex="placeholder.uri" exclude-result-prefixes="tex">
    <!--Cette feuille est adaptée à mon propre document XML-->
    <!--Merci à Arianne Pinche pour son aide précieuse dans cette feuille-->
    <!--Merci à Marjorie Burghart de m'avoir envoyé sa feuille de transformation qui m'a bien aidé-->
    <xsl:output method="text" omit-xml-declaration="no" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="fusion"/>
    <!--Plusieurs modes ici: 
    - édition: tout ce qui gère globalement le texte de l'édition
    - apparat: tout ce qui gère le fonctionnement de apparats
    - édition_texte_latin: le fonctionnement particulier du texte latin en annexe-->


    <xsl:function name="myfunctions:get_first_wit">
        <xsl:param name="text"/>
        <xsl:choose>
            <xsl:when test="substring-before(substring-after(translate(string-join($text), ' ', ''), '#'), '#') = ''">
                <xsl:value-of select="$text"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring-before(substring-after(translate(string-join($text), ' ', ''), '#'), '#')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="myfunctions:place">
        <xsl:param name="place"/>
        <xsl:param name="end_space"/>
        <xsl:choose>
            <xsl:when test="$place = 'inline'">
                <xsl:text> en ligne</xsl:text>
            </xsl:when>
            <xsl:when test="$place = 'margin'">
                <xsl:text> en marge</xsl:text>
            </xsl:when>
            <xsl:when test="$place = 'above'">
                <xsl:text> au dessus de la ligne</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="$end_space = true()">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:function>

    <xsl:function name="myfunctions:witstosigla">
        <xsl:param name="witnesses"/>
        <xsl:for-each select="tokenize(string-join($witnesses, ' '), '\s')">
            <xsl:value-of select="substring-after(., '_')"/>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="myfunctions:base_witness">
        <!--Cette fonction retourne le sigle à partir d'un noeud donné.-->
        <xsl:param name="node"/>
        <xsl:value-of select="$node/ancestor::tei:TEI[1]/@xml:id"/>
    </xsl:function>
    <!--Fonction simple qui imprime un texte si le mode debug est activé.-->

    <xsl:function name="myfunctions:debug">
        <xsl:param name="text"/>
        <xsl:if test="$debug = 'True'">
            <xsl:value-of select="$text"/>
        </xsl:if>
    </xsl:function>
    <!--Fonction simple qui imprime un texte si le mode debug est activé.-->

    <xsl:function name="myfunctions:get_apparatus_omission_simple_base_wit">
        <!--Cette fonction permet de sortir l'apparat pour une omission simple qui concerne le témoin base-->
        <xsl:param name="node" as="node()"/>
        <xsl:param name="temoin_base_edition"/>
        <xsl:param name="temoin_base_citation"/>
        <xsl:variable name="present_witnesses" select="$node/descendant::tei:rdg[node()]/@wit"/>
        <xsl:variable name="first_preceding_wit">
            <xsl:value-of select="myfunctions:get_first_wit($present_witnesses)"/>
        </xsl:variable>
        <xsl:variable name="all_presents_wits" select="tokenize(string-join($present_witnesses), '#')"/>
        <xsl:variable name="full_preceding_wits"
            select="myfunctions:witstosigla($node/preceding::tei:rdg[node()][contains(@wit, $first_preceding_wit)][1]/parent::tei:rdgGrp/descendant::tei:rdg/@wit)"/>
        <xsl:choose>
            <xsl:when
                test="$node/preceding::tei:rdg[node()][contains(@wit, $first_preceding_wit)][1]/ancestor::tei:app[not(contains(@ana, 'not_apparat')) and not(contains(@ana, 'graphique'))]">
                <xsl:text>[</xsl:text>
                <xsl:for-each
                    select="$node/preceding::tei:rdg[node()][contains(@wit, $first_preceding_wit)][1]/ancestor::tei:app/descendant::tei:rdgGrp">
                    <xsl:apply-templates select="descendant::tei:rdg[1]" mode="omission_simple">
                        <xsl:with-param name="temoin_base_edition" select="$first_preceding_wit" tunnel="yes"/>
                        <xsl:with-param name="temoin_base_citation" select="$temoin_base_citation" tunnel="yes"/>
                    </xsl:apply-templates>
                    <xsl:text> \textit{</xsl:text>
                    <xsl:value-of select="myfunctions:witstosigla(descendant::tei:rdg/@wit)"/>
                    <xsl:text>}</xsl:text>
                    <xsl:if test="following-sibling::tei:rdgGrp">
                        <xsl:text> | </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text>]</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$node/preceding::tei:rdg[node()][contains(@wit, $first_preceding_wit)][1]"
                    mode="omission_simple">
                    <xsl:with-param name="temoin_base_edition" select="$first_preceding_wit" tunnel="yes"/>
                    <xsl:with-param name="temoin_base_citation" select="$temoin_base_citation" tunnel="yes"/>
                </xsl:apply-templates>
                <xsl:text> \textit{</xsl:text>
                <xsl:value-of select="myfunctions:witstosigla($present_witnesses)"/>
                <xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="not(contains($node/@ana, '#graphique')) and not(contains($node/@ana, '#filtre'))">
                <xsl:text>[</xsl:text>
                <xsl:for-each select="$node/descendant::tei:rdgGrp">
                    <xsl:apply-templates select="descendant::tei:rdg[1]" mode="omission_simple">
                        <xsl:with-param name="temoin_base_edition" select="$first_preceding_wit" tunnel="yes"/>
                        <xsl:with-param name="temoin_base_citation" select="$temoin_base_citation" tunnel="yes"/>
                    </xsl:apply-templates>
                    <xsl:text> \textit{</xsl:text>
                    <xsl:value-of select="myfunctions:witstosigla(descendant::tei:rdg/@wit)"/>
                    <xsl:text>}</xsl:text>
                    <xsl:if test="following-sibling::tei:rdgGrp">
                        <xsl:text> | </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text>]</xsl:text>
            </xsl:when>
            <!--
            <xsl:when test="$node/@ana = '#graphique'">
                <xsl:apply-templates select="$node/descendant::tei:rdg[contains(@wit, $first_preceding_wit)]" mode="edition"/>
            </xsl:when>-->
            <xsl:otherwise>
                <xsl:apply-templates select="$node/descendant::tei:rdg[contains(@wit, $first_preceding_wit)]"
                    mode="omission_simple"/>
                <xsl:text> \textit{</xsl:text>
                <xsl:value-of select="myfunctions:witstosigla($node/descendant::tei:rdg[node()]/@wit)"/>
                <xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>

    <xsl:template match="tei:persName[@type = 'auteur']" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:text>\textsc{</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <!--

    <xsl:template match="tei:alt" mode="edition"><xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:variable name="proba">
            <xsl:analyze-string select="@weights" regex="([\.][\d])\s([\.][\d])">
                <xsl:matching-substring>
                    <xsl:value-of select="concat(number(regex-group(1)) * 100, '%')"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <!-\-pour l'instant ça ne marche que pour deux alternatives-\->
        <xsl:variable name="alt1">
            <xsl:analyze-string select="@target" regex="(#.+)\s(.+)">
                <xsl:matching-substring>
                    <xsl:value-of select="translate(regex-group(1), '#', '')"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:variable name="alt2">
            <xsl:analyze-string select="@target" regex="(#.+)\s(.+)">
                <xsl:matching-substring>
                    <xsl:value-of select="translate(regex-group(2), '#', '')"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:if test="//*[@xml:id = $alt1]">
            <xsl:if test="//*[@xml:id = $alt1] = tei:mod">
                <xsl:if test="tei:mod[@xml:id = $alt1]/tei:del/tei:space">
                    <xsl:text>Le terme </xsl:text>
                    <xsl:value-of select="tei:mod[@xml:id = $alt1]//tei:add"/>
                    <xsl:text>a été ajouté sur un blanc.</xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:text> Il existe une autre possibilité (</xsl:text>
            <xsl:value-of select="$proba"/>
            <xsl:text> de probabilité):</xsl:text>
            <xsl:if test="//*[@xml:id = $alt2] = tei:subst">
                <xsl:if test="//*[@xml:id = $alt2]/tei:del//not(text())">
                    <xsl:text>Un mot inconnu a été remplacé par</xsl:text>
                    <xsl:value-of select="//*[@xml:id = $alt2]/tei:add"/>
                </xsl:if>
            </xsl:if>
        </xsl:if>
<xsl:value-of select="concat($alt1,$alt2)"/>
    </xsl:template>
    -->
    <!--Notes en bas de page. -->
    <!--Est ce que je me complique pas la vie à écrire deux fois les mêmes règles?-->
    <!--Si la note est thématique, second niveau de notes, appel en chiffres arabes-->



    <xsl:template match="tei:note[ancestor::tei:del]" mode="edition"/>
    <!--
    <xsl:template match="tei:note[parent::tei:del]" mode="edition"><xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text>\footnoteB{\label{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}\edlabel{ed:</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
        <xsl:variable name="witness">
            <xsl:text> (</xsl:text>
            <xsl:choose>
                <xsl:when test="@corresp">
                    <xsl:value-of select="myfunctions:witstosigla(@corresp)"/>
                </xsl:when>
                <xsl:when test="ancestor::node()[@corresp]">
                    <xsl:value-of select="myfunctions:witstosigla(ancestor::node()[@corresp][1]/@corresp)"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-\-Debug pour retrouver plus facilement les notes dans le xml-\->
                    <xsl:value-of select="myfunctions:witstosigla(ancestor::tei:TEI/@xml:id)"/>
                    <!-\-Debug pour retrouver plus facilement les notes dans le xml-\->
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>) </xsl:text>
        </xsl:variable>
        <xsl:value-of select="myfunctions:debug($witness)"/>
        <!-\-On va chercher dans le fichier source pour ne pas avoir à tout calculer lorsqu'on change une note de bas de page-\->
        <xsl:variable name="xml_id" select="@xml:id"/>
        <xsl:variable name="division" select="ancestor::tei:div[not(ancestor::tei:div)]/@n"/>
        <xsl:variable name="corresponding_wit">
            <xsl:choose>
                <xsl:when test="@ana = '#injected'">
                    <xsl:value-of select="translate(@corresp, '#', '')"/>
                </xsl:when>
                <xsl:when test="ancestor::node()[@ana = '#injected']">
                    <xsl:value-of select="translate(ancestor::node()[@ana = '#injected']/@corresp, '#', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="ancestor::tei:TEI[@subtype = 'version_a']">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates
                    select="collection('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan?select=*.xml')/descendant::tei:TEI[@xml:id = $corresponding_wit]/descendant::tei:div[@n = $division]/descendant::tei:note[@xml:id = $xml_id]/node()"
                    mode="edition"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-\-On fait ça pour ne pas avoir à tout refaire lorsqu'on change une note de bas de page-\->
        <xsl:text>}
        </xsl:text>
    </xsl:template>
-->


    <xsl:template
        match="tei:note[@subtype = 'lexicale'] | tei:note[@type = 'general'] | tei:note[@type = 'sources'][not(parent::tei:del)]"
        mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>

        <!--On se sert de cette variable pour déterminer le mode choisi. 
            Permet d'éviter de multiplier les règles selon le mode-->
        <xsl:variable name="mode_citation">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:text>False</xsl:text>
                </xsl:when>
                <xsl:otherwise>True</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!--On imprime pas de notes en mode citation.-->
            <xsl:when test="$mode_citation = 'False'">
                <xsl:text>\footnote</xsl:text>
                <xsl:choose>
                    <xsl:when test="ancestor::tei:TEI[@subtype = 'version_a']">
                        <xsl:text>A</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'sources'">
                        <xsl:text>C</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>B</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>{\label{</xsl:text>
                <xsl:value-of select="@xml:id"/>
                <xsl:text>}\edlabel{ed:</xsl:text>
                <xsl:value-of select="@xml:id"/>
                <xsl:text>}</xsl:text>
                <xsl:variable name="witness">
                    <xsl:text> (</xsl:text>
                    <xsl:choose>
                        <xsl:when test="@corresp">
                            <xsl:value-of select="myfunctions:witstosigla(@corresp)"/>
                        </xsl:when>
                        <xsl:when test="ancestor::node()[@corresp]">
                            <xsl:value-of select="myfunctions:witstosigla(ancestor::node()[@corresp][1]/@corresp)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--Debug pour retrouver plus facilement les notes dans le xml-->
                            <xsl:value-of select="myfunctions:witstosigla(ancestor::tei:TEI/@xml:id)"/>
                            <!--Debug pour retrouver plus facilement les notes dans le xml-->
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>) </xsl:text>
                </xsl:variable>
                <xsl:value-of select="myfunctions:debug(@xml:id)"/>
                <xsl:value-of select="myfunctions:debug($witness)"/>
                <!--On va chercher dans le fichier source pour ne pas avoir à tout calculer lorsqu'on change une note de bas de page-->
                <xsl:variable name="xml_id" select="@xml:id"/>
                <xsl:variable name="division" select="ancestor::tei:div[not(ancestor::tei:div)]/@n"/>
                <xsl:variable name="corresponding_wit">
                    <xsl:choose>
                        <xsl:when test="@ana = '#injected'">
                            <xsl:value-of select="translate(@corresp, '#', '')"/>
                        </xsl:when>
                        <xsl:when test="ancestor::node()[@ana = '#injected']">
                            <xsl:value-of select="translate(ancestor::node()[@ana = '#injected']/@corresp, '#', '')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$temoin_base_edition"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="ancestor::tei:TEI[@subtype = 'version_a']">
                        <xsl:apply-templates mode="edition"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates
                            select="collection('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan?select=*.xml')/descendant::tei:TEI[@xml:id = $corresponding_wit]/descendant::tei:div[@n = $division]/descendant::tei:note[@xml:id = $xml_id]/node()"
                            mode="edition"/>
                    </xsl:otherwise>
                </xsl:choose>
                <!--On fait ça pour ne pas avoir à tout refaire lorsqu'on change une note de bas de page-->
                <xsl:text>}</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>




    <xsl:template match="tei:ref[@type = 'document_exterieur']" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:text>\color{blue}</xsl:text>
        <xsl:value-of select="replace(replace(@target, '_', '\\_'), '../../../', '')"/>
        <xsl:text>\color{black}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:soCalled" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:text>``</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>''</xsl:text>
    </xsl:template>


    <xsl:template match="tei:sic[not(@ana = '#omission')][not(preceding-sibling::tei:corr or following-sibling::tei:corr)]"
        mode="#all">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:apply-templates mode="#current"/>
        <xsl:text>\textsuperscript{\textit{[sic]}}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:sic[not(@ana = '#omission')][preceding-sibling::tei:corr or following-sibling::tei:corr]" mode="#all"/>


    <!--TODO: Ajouter toutes les images en annexe-->
    <xsl:template match="tei:graphic[parent::tei:note][@rend = 'annexe']" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:text>figure \ref{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}, page \pageref{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>} de l'annexe</xsl:text>
    </xsl:template>
    <!--TODO: Ajouter toutes les images en annexe-->
    <!--<xsl:template match="tei:sic[@ana = '#omission']" mode="edition"><xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>\footnote</xsl:text>
        <xsl:choose>
            <xsl:when test="ancestor::tei:TEI[@subtype = 'version_a']">
                <xsl:text>A</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>B</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>{Omission chez le témoin.}</xsl:text>
    </xsl:template>-->
    <xsl:template match="tei:lg" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:apply-templates mode="edition"/>
    </xsl:template>
    <xsl:template match="tei:l" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:apply-templates mode="edition"/>
        <xsl:if test="following-sibling::tei:l">
            <xsl:text>~\\</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:lb[@break = 'yes']" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <!--On va ignorer les lb-->
        <xsl:text> </xsl:text>
    </xsl:template>


    <!--Édition du texte latin en annexe-->
    <xsl:template match="tei:div[@type = 'partie']" mode="edition_texte_latin">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:apply-templates mode="edition_texte_latin"/>
    </xsl:template>
    <xsl:template match="tei:teiHeader | tei:head[not(ancestor::tei:div[@type = 'chapitre'])]" mode="edition_texte_latin"/>


    <xsl:template match="tei:div[@type = 'chapitre']" mode="edition_texte_latin">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:text>
            \phantomsection
            \section*{</xsl:text>
        <xsl:apply-templates select="tei:head"/>
        <xsl:if test="ancestor::tei:TEI[@xml:id = 'Rome_W']">
            <xsl:text>\footnoteA{Le chapitre correspondant de l'édition se trouve p. \pageref{chapter:</xsl:text>
            <xsl:value-of select="@n"/>
            <xsl:text>}.}</xsl:text>
        </xsl:if>
        <xsl:text>}\label{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
        <xsl:text>\stepcounter{section}</xsl:text>
        <xsl:text>\addcontentsline{toc}{section}{</xsl:text>
        <xsl:choose>
            <xsl:when test="ancestor::tei:TEI[@xml:id = 'Rome_W']">
                <xsl:text>Chapitre </xsl:text>
                <xsl:value-of select="@n"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Fragment \arabic{section}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>}</xsl:text>
        <xsl:apply-templates select="child::tei:*[not(self::tei:head)]" mode="edition"/>
    </xsl:template>

    <xsl:template match="tei:desc" mode="omission_simple apparat"/>

    <xsl:template match="tei:figure[descendant::tei:desc]" mode="edition apparat">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <!--Continuer et continuer la fonction d'impression des images-->
        <xsl:variable name="side_of_note">
            <xsl:choose>
                <xsl:when test="ancestor::tei:TEI[@xml:id = 'Val_S']">
                    <xsl:text>A</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>B</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text>\footnote</xsl:text>
        <xsl:value-of select="$side_of_note"/>
        <xsl:text>{Une figure apparaît ici</xsl:text>
        <xsl:value-of select="myfunctions:place(@place, true())"/>
        <xsl:choose>
            <xsl:when test="@ana = '#injected'">
                <xsl:text> pour le témoin </xsl:text>
                <xsl:value-of select="myfunctions:witstosigla(@corresp)"/>
                <xsl:text>. </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>. </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="descendant::tei:desc" mode="edition"/>
        <xsl:text> Elle est reproduite en annexe: figure \ref{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}, page \pageref{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}.}</xsl:text>
    </xsl:template>
    <!--Édition du texte latin en annexe-->
    <!--A terme remplace les tei:hi pour de l'istruction de mise en page dans les notes-->
    <xsl:template match="tei:foreign" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:text>\textit{</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <!--A terme remplace les tei:hi pour de l'istruction de mise en page dans les notes-->
    <!--MISE EN PAGE-->
    <xsl:template match="tei:ab" mode="edition"/>
    <!--AJOUTS-->
    <!--ajouts du copiste en exposant (interlinéaire) ou en note (marge): deuxième niveau de 
        notes ou ajout en exposation. Si appartient à un apparat, simple indication avec le 
        terme ajouté en italique-->

    <xsl:template match="descendant::tei:add[ancestor::tei:w][not(ancestor::tei:subst)][ancestor::tei:TEI[1]/@xml:id = 'Val_S']"
        priority="2" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:variable name="added_fragment" select="text()"/>
        <xsl:variable name="corresponding_lemma">
            <xsl:value-of select="ancestor::tei:w/descendant::text()"/>
        </xsl:variable>
        <xsl:variable name="place" select="myfunctions:place(@place, false())"/>
        <xsl:text>\edtext{</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>}{\lemma{</xsl:text>
        <xsl:value-of select="$corresponding_lemma"/>
        <!--Reprendre la règle pour les ajouts dans S-->
        <xsl:text>}\Dfootnote{ -- \enquote{</xsl:text>
        <!--Reprendre la règle pour les ajouts dans S-->
        <xsl:value-of select="$added_fragment"/>
        <xsl:text>} est inséré </xsl:text>
        <xsl:value-of select="$place"/>
        <xsl:text>.}}</xsl:text>
    </xsl:template>

    <xsl:template
        match="tei:app[descendant::tei:add[ancestor::tei:w][not(ancestor::tei:subst)]][not(ancestor::tei:TEI[1]/@xml:id = 'Val_S')]"
        priority="6" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:message>
            <xsl:value-of select="$temoin_base_edition"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$temoin_base_citation"/>
        </xsl:message>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:next-match>
            <xsl:with-param name="temoin_base_citation" select="$temoin_base_citation"/>
        </xsl:next-match>
        <xsl:variable name="added_fragment" select="descendant::tei:add[ancestor::tei:w][not(ancestor::tei:subst)]/text()"/>
        <xsl:variable name="corresponding_lemma">
            <xsl:value-of
                select="descendant::tei:add[ancestor::tei:w][not(ancestor::tei:subst)]/ancestor::tei:w/descendant::text()"/>
        </xsl:variable>
        <xsl:variable name="place"
            select="myfunctions:place(descendant::tei:add[ancestor::tei:w][not(ancestor::tei:subst)]/@place, true())"/>
        <xsl:variable name="corresp"
            select="descendant::tei:add[ancestor::tei:w][not(ancestor::tei:subst)]/ancestor::tei:rdg/@wit"/>
        <xsl:variable name="string_current_wit">
            <xsl:apply-templates mode="apparat"
                select="descendant::tei:add[ancestor::tei:w][not(ancestor::tei:subst)]/ancestor::tei:rdg/tei:w"/>
        </xsl:variable>
        <xsl:variable name="string_base_witness">
            <xsl:apply-templates mode="apparat" select="descendant::tei:rdg[contains(@wit, $temoin_base)]/tei:w"/>
        </xsl:variable>
        <xsl:text>\edtext{}{\lemma{</xsl:text>
        <xsl:text>}\Bfootnote[nonum]{ -- </xsl:text>
        <xsl:if test="(contains(@ana, 'graphique') or contains(@ana, 'filtre')) and $string_current_wit != $string_base_witness">
            <xsl:text>\textit{</xsl:text>
            <xsl:value-of select="$string_current_wit"/>
            <xsl:text>}: </xsl:text>
        </xsl:if>
        <xsl:text>\enquote{</xsl:text>
        <!--Reprendre la règle pour les ajouts dans S-->
        <xsl:value-of select="$added_fragment"/>
        <xsl:text>} est inséré </xsl:text>
        <xsl:value-of select="$place"/>
        <xsl:text> dans le témoin </xsl:text>
        <!--Pour l'instant ce n'est que le témoin-base de l'édition qui peut rendre ces ajouts-->
        <xsl:value-of select="myfunctions:witstosigla($corresp)"/>
        <!--Pour l'instant ce n'est que le témoin-base qui peut rendre ces ajouts-->
        <xsl:text>.}}</xsl:text>
    </xsl:template>

    <xsl:template
        match="tei:add[@type = 'correction'][ancestor::tei:TEI[1]/@xml:id = 'Val_S'][descendant::tei:w][not(ancestor::tei:subst)]"
        mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:variable name="place" select="myfunctions:place(@place, true())"/>
        <xsl:apply-templates mode="edition"/>
        <xsl:variable name="corresp" select="@corresp"/>
        <xsl:text>\edtext{}{\lemma{</xsl:text>
        <xsl:apply-templates mode="ajout"/>
        <xsl:text>}\Dfootnote{| </xsl:text>
        <xsl:choose>
            <xsl:when test="count(descendant::tei:app) > 1">
                <xsl:text>Ce passage </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Ce mot </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>est ajouté </xsl:text>
        <xsl:value-of select="$place"/>
        <!--Pour l'instant ce n'est que le témoin-base qui peut rendre ces ajouts-->
        <xsl:text>.}}</xsl:text>
    </xsl:template>


    <xsl:template
        match="tei:add[@type = 'correction'][not(ancestor::tei:TEI[1]/@xml:id = 'Val_S')][descendant::tei:w][not(ancestor::tei:subst)]"
        mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="place" select="myfunctions:place(@place, true())"/>
        <xsl:apply-templates mode="edition"/>
        <xsl:variable name="corresp" select="@corresp"/>
        <xsl:text>\edtext{}{\lemma{</xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base)][node()]" mode="ajout"/>
        <xsl:text>}\Bfootnote{| </xsl:text>
        <xsl:choose>
            <xsl:when test="count(descendant::tei:app) > 1">
                <xsl:text>Ce passage </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Ce mot </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>est ajouté </xsl:text>
        <xsl:value-of select="$place"/>
        <xsl:text> dans le témoin </xsl:text>
        <!--Pour l'instant ce n'est que le témoin-base de l'édition qui peut rendre ces ajouts-->
        <xsl:value-of select="myfunctions:witstosigla($temoin_base_edition)"/>
        <!--Pour l'instant ce n'est que le témoin-base qui peut rendre ces ajouts-->
        <xsl:text>.}}</xsl:text>
    </xsl:template>

    <xsl:template match="node()[@rend = 'cacher'] | tei:add[@type = 'commentaire'][not(@rend = 'cacher')]"
        mode="edition citation_apparat apparat" priority="5"/>




    <xsl:template match="tei:quote" priority="3" mode="#all">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="not(@type)">
                <xsl:text>\enquote{</xsl:text>
                <xsl:apply-templates mode="#current"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template match="tei:ref[@type = 'edition']" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <!--Créer une règle pour gérer les multiples appels de références, avec un analyse-string-->
        <xsl:choose>
            <xsl:when test="parent::tei:note">
                <xsl:if test="parent::tei:quote[@xml:lang][not(@xml:lang = 'fr')]">
                    <xsl:text> {\normalfont </xsl:text>
                </xsl:if>
                <xsl:text> [\cite</xsl:text>
                <xsl:if test="@n">
                    <xsl:text>[</xsl:text>
                    <xsl:apply-templates select="@n"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
                <xsl:text>{</xsl:text>
                <xsl:value-of select="translate(translate(@target, ' ', ','), '#', '')"/>
                <xsl:text>}]</xsl:text>
                <xsl:if test="parent::tei:quote[@xml:lang][not(@xml:lang = 'fr')]">
                    <xsl:text>}</xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\footcite</xsl:text>
                <xsl:if test="@n">
                    <xsl:text>[</xsl:text>
                    <xsl:apply-templates select="@n"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
                <xsl:text>{</xsl:text>
                <xsl:value-of select="translate(translate(@target, ' ', ','), '#', '')"/>
                <xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:ref[@type = 'url'][not(parent::tei:note)]" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:variable name="echappement_url" select="replace(@target, '#', '\\#')"/>
        <xsl:choose>
            <xsl:when test="node()">
                <xsl:text>\href{</xsl:text>
                <xsl:value-of select="$echappement_url"/>
                <xsl:text>}{</xsl:text>
                <xsl:apply-templates mode="edition"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\footnote</xsl:text>
                <xsl:choose>
                    <xsl:when test="ancestor::tei:TEI[@subtype = 'version_a']">
                        <xsl:text>A</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>B</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>{\url{</xsl:text>
                <xsl:value-of select="$echappement_url"/>
                <xsl:text>}}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!--  <xsl:template match="tei:ref[@type = 'interne']" mode="edition"><xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:variable name="target" select="translate(@target, '#', '')"/>
        <xsl:choose>
            <xsl:when test="not(document($corpus_path)//tei:*[@xml:id = $target][ancestor-or-self::tei:graphic])">
                <xsl:choose>
                    <xsl:when test="document($corpus_path)//tei:*[@xml:id = $target][self::tei:note]">
                        <xsl:choose>
                            <xsl:when test="document($corpus_path)//tei:*[@xml:id = $target][self::tei:note[@type = 'codico']]">
                                <xsl:text>note codicologique, page \edpageref{</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>note \ref{</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="document($corpus_path)//tei:*[@xml:id = $target][self::tei:anchor[@type = 'ligne']]">
                        <xsl:text>page \edpageref{</xsl:text>
                        <xsl:value-of select="$target"/>
                        <xsl:text>}, </xsl:text>
                        <xsl:text>ligne \edlineref{</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\nameref{</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="$target"/>
                <xsl:text>}</xsl:text>
                <xsl:choose>
                    <xsl:when test="
                            not(document($corpus_path)//tei:*[@xml:id = $target][self::tei:anchor[@type = 'ligne']])
                            and not(document($corpus_path)//tei:*[@xml:id = $target][self::tei:note[@type = 'codico']])">
                        <xsl:text>, page \pageref{</xsl:text>
                        <xsl:value-of select="$target"/>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>figure \ref{</xsl:text>
                <xsl:value-of select="$target"/>
                <xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
-->



    <xsl:template match="tei:code[@lang = 'tagset'] | tei:code[@rend = 'show']" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <!--À revoir plus tard à tête reposée-->
        <!--<xsl:text>\codeword{</xsl:text>
        <!-\-On supprime les espaces surnuméraires qui forment un saut de ligne 
            d'une façon ou d'une autre. codeword (verbatim) n'acceptent que des éléments en ligne.-\->
        <xsl:value-of select="replace(., '\s+', ' ')"/>
        <xsl:text>}</xsl:text>-->
        <xsl:text>\footnote</xsl:text>
        <xsl:choose>
            <xsl:when test="ancestor::tei:TEI[@subtype = 'version_a']">
                <xsl:text>A</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>B</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>{[ICI DU CODE]}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:ref[@type = 'biblio'][not(@rend)]" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:if test="parent::tei:quote[@xml:lang][not(@xml:lang = 'fr')]">
            <xsl:text> {\normalfont [</xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="ancestor::tei:note">
                <xsl:text>\cite</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::tei:quote and not(node())">
                <xsl:text>\footcite</xsl:text>
            </xsl:when>
            <xsl:when test="node()">
                <xsl:text>\footnote</xsl:text>
                <xsl:choose>
                    <xsl:when test="ancestor::tei:TEI[@subtype = 'version_a']">
                        <xsl:text>A</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>B</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>{\cite</xsl:text>
            </xsl:when>
            <xsl:otherwise> [\cite</xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="@n">
                <xsl:text>[</xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>]</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>{</xsl:text>
        <xsl:value-of select="translate(translate(@target, ' ', ','), '#', '')"/>
        <xsl:text>}</xsl:text>
        <xsl:choose>
            <xsl:when test="node() and not(ancestor::tei:note)">
                <xsl:text>, </xsl:text>
                <xsl:apply-templates mode="edition"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:when test="node() and ancestor::tei:note">
                <xsl:text>, </xsl:text>
                <xsl:apply-templates mode="edition"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="not(node() | ancestor::tei:note | ancestor::tei:quote)">
            <xsl:text>]</xsl:text>
        </xsl:if>
        <xsl:if test="parent::tei:quote[@xml:lang][not(@xml:lang = 'fr')]">
            <xsl:text>]}</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:ref[@type = 'biblio'][@rend = 'print_title']" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <!--Créer une règle pour gérer les multiples appels de références, avec un analyse-string-->
        <xsl:choose>
            <xsl:when test="parent::tei:note">
                <xsl:text>\citetitle</xsl:text>
                <xsl:text>{</xsl:text>
                <xsl:value-of select="translate(translate(@target, ' ', ','), '#', '')"/>
                <xsl:text>} </xsl:text>
                <xsl:text>[\cite</xsl:text>
                <xsl:if test="@n">
                    <xsl:text>[</xsl:text>
                    <xsl:apply-templates select="@n"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
                <xsl:text>{</xsl:text>
                <xsl:value-of select="translate(translate(@target, ' ', ','), '#', '')"/>
                <xsl:text>}]</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\citetitle</xsl:text>
                <xsl:text>{</xsl:text>
                <xsl:value-of select="translate(translate(@target, ' ', ','), '#', '')"/>
                <xsl:text>}\footcite</xsl:text>
                <xsl:if test="@n">
                    <xsl:text>[</xsl:text>
                    <xsl:apply-templates select="@n"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
                <xsl:text>{</xsl:text>
                <xsl:value-of select="translate(translate(@target, ' ', ','), '#', '')"/>
                <xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--Les ajouts de ma part sont entre crochets-->
    <xsl:template match="tei:supplied" name="supplied" mode="edition citation_apparat sans_apparat">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:text>[</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <!--Les ajouts de ma part sont entre crochets-->
    <!--AJOUTS-->
    <!--MODIFICATIONS CORRECTIONS-->

    <xsl:template match="tei:space[@ana = '#tokenisation']" mode="edition">
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="tei:space" mode="marques_lecture">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="@ana = '#tokenisation' or @ana = '#tokenisation #agglutination-pct'">
                <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="corresp" select="@corresp"/>
                <xsl:text>\edtext{}{\lemma{}\Bfootnote[nonum]{-- Un espace est laissé en blanc après ce mot dans le témoin </xsl:text>
                <xsl:choose>
                    <xsl:when test="not(@ana = '#injected')">
                        <xsl:value-of select="myfunctions:witstosigla($temoin_base)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="myfunctions:witstosigla(@corresp)"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>.}}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>





    <xsl:template match="tei:teiHeader" mode="edition"/>

    <xsl:template match="tei:title" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="not(ancestor::tei:note) and ancestor::tei:TEI[@xml:id = 'Val_S']">
                <xsl:apply-templates mode="edition"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="@type = 'section'">
                    <xsl:text>\enquote{</xsl:text>
                </xsl:if>
                <xsl:text>\textit{</xsl:text>
                <xsl:apply-templates mode="edition"/>
                <xsl:text>}</xsl:text>
                <xsl:if test="@type = 'section'">
                    <xsl:text>}</xsl:text>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:unclear[not(node())]" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:text>$\dagger\dagger$</xsl:text>
    </xsl:template>


    <xsl:template match="tei:unclear[node()]" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--        <xsl:text>~</xsl:text>-->
        <xsl:apply-templates mode="edition"/>
        <xsl:text>(?)</xsl:text>
        <xsl:if test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base)][node()]]]">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>



    <xsl:template match="tei:damage" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:text>[</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>]</xsl:text>
    </xsl:template>




    <xsl:template match="tei:gap" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:text>\indent </xsl:text>
        <xsl:apply-templates mode="edition"/>
    </xsl:template>
    <!-- ignorer le text entre balises <del>-->

    <xsl:template match="tei:del[not(ancestor::tei:subst)]" mode="edition apparat omission_simple">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="witness">
            <xsl:choose>
                <xsl:when test="@corresp">
                    <xsl:value-of select="myfunctions:witstosigla(@corresp)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="myfunctions:witstosigla($temoin_base)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text> [</xsl:text>
        <xsl:if test="not(ancestor::tei:TEI[1]/@xml:id = 'Val_S')">
            <xsl:value-of select="$witness"/>
            <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:text>\textit{del.} </xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <!-- ignorer le text entre balises <del>-->
    <!--Ici on va créer des règles pour afficher les éléments dans les apparats-->


    <!--Ici on va créer des règles pour afficher les éléments dans les apparats-->
    <xsl:template match="tei:div[@type = 'chapitre'][not(@type = 'glose' or @type = 'traduction')]" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:message>Début chapitre <xsl:value-of select="@n"/></xsl:message>
        <xsl:message>Nombre de paragraphes: <xsl:value-of select="count(descendant::tei:p)"/></xsl:message>
        <xsl:variable name="div_n" select="@n"/>
        <xsl:text>\begin{pages}&#10;</xsl:text>
        <xsl:text>\phantomsection&#10;</xsl:text>
        <xsl:text>\label{chapter:</xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>}</xsl:text>
        <xsl:text>\stepcounter{section}&#10;</xsl:text>
        <xsl:text>\addcontentsline{toc}{section}{Chapitre </xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>}&#10;</xsl:text>
        <xsl:text>\begin{Leftside}&#10;</xsl:text>
        <xsl:text>\beginnumbering&#10;</xsl:text>
        <xsl:apply-templates
            select="document('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan/Val_S.xml')/descendant::tei:div[@n = $div_n][@type = 'chapitre']/node()"
            mode="edition"/>
        <!--Test pour mieux gérer la mémoire-->
        <!--<xsl:for-each select="tei:div[@type = 'glose']/tei:p[following-sibling::tei:p]">
            <xsl:text>%Found you &#10;</xsl:text>
            <xsl:text>\pstart\pend</xsl:text>
        </xsl:for-each>-->
        <!--Test pour mieux gérer la mémoire-->
        <xsl:text>\endnumbering&#10;</xsl:text>
        <xsl:text>\end{Leftside}&#10;</xsl:text>
        <xsl:text>\begin{Rightside}</xsl:text>
        <xsl:text>\beginnumbering</xsl:text>
        <xsl:text>\stepcounter{section}&#10;</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>
        \endnumbering
        \end{Rightside}
        \end{pages}
        \Pages </xsl:text>
        <xsl:message>Fin chapitre <xsl:value-of select="@n"/></xsl:message>
    </xsl:template>
    <!--Foliation en exposant entre crochets -->



    <xsl:template match="tei:pb" mode="edition apparat citation_apparat marques_lecture">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="ancestor::tei:TEI[@xml:id = 'Rome_W']">
                <xsl:text>\textsuperscript{[p. </xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>]}</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::tei:TEI[@xml:id = 'comunidad_escorial']">
                <xsl:text>\textsuperscript{[fol. </xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>]}</xsl:text>
            </xsl:when>
            <xsl:when
                test="ancestor::tei:quote[@xml:lang = 'lat'] | ancestor::tei:TEI[@xml:id = 'Val_S'] | ancestor::tei:note[@type = 'sources']">
                <xsl:text>\textsuperscript{[fol. </xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>]}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="witness">
                    <xsl:choose>
                        <xsl:when test="@corresp">
                            <xsl:value-of select="myfunctions:witstosigla(@corresp)"/>
                        </xsl:when>
                        <xsl:when test="ancestor::tei:rdg">
                            <xsl:value-of select="myfunctions:witstosigla(ancestor::tei:rdg/@wit)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="myfunctions:witstosigla($temoin_base)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:text>\textsuperscript{[</xsl:text>
                <xsl:value-of select="$witness"/>
                <xsl:text>: fol. </xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>]}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--Foliation en exposant entre crochets -->
    <!-- <xsl:template match="tei:app" mode="transposition"><xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_edition"/>
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:variable name="temoin_courant">
            <xsl:choose>
                <xsl:when test="not($temoin_base_edition)">
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_courant)]"/>
        <xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_courant)][node()]]]">
            <xsl:text> %&#10;</xsl:text>
        </xsl:if>
    </xsl:template>-->
    <xsl:template match="tei:cb[not(@corresp)]" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:if test="not(ancestor::tei:rdg[contains(@wit, $temoin_base_edition)])">
            <xsl:text>\textsuperscript{[col. b]}</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--Foliation-->
    <!---->
    <xsl:template match="tei:milestone" mode="edition apparat omission_simple citation_apparat sans_apparat">
        <xsl:if test="@unit = 'item_rang_1'">
            <xsl:text> \textbf{ </xsl:text>
            <xsl:value-of select="@n"/>
            <xsl:text>}~</xsl:text>
        </xsl:if>
        <xsl:if test="@unit = 'item_rang_2'">
            <xsl:text> \textbf{ </xsl:text>
            <xsl:value-of select="preceding::tei:milestone[@unit = 'item_rang_1'][1]/@n"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="@n"/>
            <xsl:text>}~</xsl:text>
        </xsl:if>
        <xsl:if test="@unit = 'item_rang_3'">
            <xsl:text> \textbf{ </xsl:text>
            <xsl:value-of select="preceding::tei:milestone[@unit = 'item_rang_1'][1]/@n"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="preceding::tei:milestone[@unit = 'item_rang_2'][1]/@n"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="@n"/>
            <xsl:text>}~</xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template match="tei:hi[@rend = 'initiale'] | tei:hi[@rend = 'non_initiale']" mode="#all">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <!--Avec les liens c'est moche-->
        <!--<xsl:text>\lettrine[lines=3]{</xsl:text>
        <xsl:value-of select="upper-case(.)"/>
        <xsl:text>}</xsl:text>-->
        <xsl:value-of select="upper-case(.)"/>
    </xsl:template>
    <!--<xsl:template match="tei:hi[@rend = 'non_initiale']" mode="edition"><xsl:param name="temoin_base_edition" tunnel="yes"/>
        <!-\-<xsl:text>\lettrine[lines=3]{\textcolor{white}{</xsl:text>
        <xsl:value-of select="upper-case(.)"/>
        <xsl:text>}}</xsl:text>-\->
<!-\-        <xsl:value-of select="upper-case(.)"/>-\->
    </xsl:template>-->
    <xsl:template match="tei:hi[@rend = 'lettre_attente']" mode="#all"/>
    <xsl:template match="tei:hi[@rend = 'lettre_capitulaire']" mode="#all">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:value-of select="lower-case(.)"/>
    </xsl:template>
    <!--    <xsl:template match="tei:app[contains(@ana, '#codico')][]"></xsl:template>-->



    <xsl:template
        match="tei:app[@ana = '#lexicale'][count(descendant::tei:rdg) = 1] | tei:ana[@type = '#morphosyntaxique'][count(descendant::tei:rdg) = 1] | tei:app[@ana = '#indetermine'][count(descendant::tei:rdg) = 1]"
        mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <!--Essayer de trouver un moyen de faire apparaître les omissions clairement. Par exemple: dans un niveau de note spécifique.-->
        <!--On omet les omissions pour l'instant-->
        <xsl:text> </xsl:text>
        <xsl:apply-templates mode="edition"/>
    </xsl:template>


    <xsl:template
        match="tei:note[@type = 'variante'] | tei:note[@type = 'codico'][not(ancestor::tei:del)] | tei:note[@type = 'codico'][ancestor::tei:handShift]"
        mode="edition apparat omission_simple"/>

    <xsl:template match="tei:subst" mode="edition apparat">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:apply-templates select="tei:add" mode="#current"/>
    </xsl:template>

    <xsl:template match="tei:add[ancestor::tei:subst]" mode="edition"/>

    <xsl:template match="tei:app[descendant::tei:subst]" mode="edition" priority="2">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:next-match/>
        <xsl:text> </xsl:text>
        <xsl:variable name="corresp" select="@corresp"/>
        <xsl:text>\edtext{}{\Bfootnote[nonum]{</xsl:text>
        <xsl:text>-- </xsl:text>
        <xsl:choose>
            <xsl:when test="count(tei:rdgGrp) != 1">
                <xsl:apply-templates select="ancestor::tei:rdg/tei:w" mode="edition"/>
                <xsl:text> </xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text> \textit{</xsl:text>
        <xsl:value-of select="myfunctions:witstosigla(descendant::tei:rdg[descendant::tei:subst]/@wit)"/>
        <xsl:text> orig.} </xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[descendant::tei:subst]/tei:w" mode="orig"/>
        <xsl:choose>
            <xsl:when test="descendant::tei:rdg[descendant::tei:subst]/descendant::tei:del">
                <xsl:text>, \textit{del.} </xsl:text>
                <xsl:for-each select="descendant::tei:del">
                    <xsl:apply-templates/>
                    <xsl:if test="../following-sibling::tei:subst/tei:del">
                        <xsl:text> \textit{et} </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text> \textit{et}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>, </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text> \textit{add.} </xsl:text>
        <xsl:for-each select="descendant::tei:add">
            <xsl:apply-templates/>
            <xsl:if test="../following-sibling::tei:subst/tei:add">
                <xsl:text> \textit{et} </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>. </xsl:text>
        <!--On ne fait apparaître aucune note dans les citations-->
        <xsl:if test="$temoin_base_citation = ''">
            <xsl:apply-templates select="descendant::tei:subst/tei:note"/>
        </xsl:if>
        <xsl:text>}}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:space" mode="orig">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:text>[espace]</xsl:text>
    </xsl:template>
    <xsl:template match="tei:w" mode="orig">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:apply-templates mode="orig"/>
    </xsl:template>

    <xsl:template match="tei:add" mode="orig"/>


    <xsl:template match="tei:note" mode="orig"/>

    <xsl:template match="tei:handShift" mode="sans_apparat">
        <xsl:text>\footnoteA{</xsl:text>
        <xsl:apply-templates select="tei:desc" mode="these"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template
        match="tei:app[descendant::tei:add[@type = 'commentaire'][not(@rend = 'cacher')] or descendant::tei:space or descendant::tei:note[@type = 'variante'] or descendant::tei:handShift or descendant::tei:note[@type = 'codico'][not(ancestor::tei:subst)]]"
        priority="5" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--On imprime l'apparat, et on imprime la note dans un deuxième niveau d'apparat.-->
        <xsl:next-match/>
        <xsl:text> </xsl:text>
        <xsl:variable name="corresp" select="@corresp"/>
        <!--<xsl:text>\edtext{}{\lemma{</xsl:text>
        <xsl:apply-templates
            select="ancestor::tei:app/descendant::tei:rdg[contains(@wit, $temoin_base_edition)]"
            mode="edition"/>
        <xsl:text>}\Afootnote{</xsl:text>
        <xsl:text> \textit{</xsl:text>
        <xsl:value-of
            select="myfunctions:witstosigla(descendant::tei:rdgGrp[contains(string-join(descendant::tei:rdg/@wit), $temoin_base_edition)]/descendant::tei:rdg/@wit)"/>
        <xsl:text>} | </xsl:text>
        <xsl:for-each select="tei:rdgGrp">
            <xsl:apply-templates select="tei:rdg[1]" mode="edition"/>
            <xsl:text> \textit{</xsl:text>
            <xsl:value-of select="myfunctions:witstosigla(descendant::tei:rdg/@wit)"/>
            <xsl:text>} </xsl:text>
        </xsl:for-each>
        <xsl:for-each select="descendant::tei:note[@type = 'variante']">
            <xsl:apply-templates mode="edition"/>
            <!-\-<xsl:text>[\textit{</xsl:text>
            <xsl:value-of
                select="myfunctions:witstosigla(ancestor::tei:rdgGrp/descendant::tei:rdg[contains(@wit, $corresp)]/@wit)"/>
            <xsl:text>}]  </xsl:text>-\->
        </xsl:for-each>
        <xsl:text>}}</xsl:text>-->
        <xsl:for-each select="descendant::tei:add[@type = 'commentaire'][not(@rend = 'cacher')]">
            <xsl:variable name="id" select="@xml:id"/>
            <xsl:variable name="wit" select="myfunctions:witstosigla(@corresp)"/>
            <xsl:text>\edtext{</xsl:text>
            <xsl:text>\edlabel{</xsl:text>
            <!--On veut distinguer les notes dans les citations avec apparat, pour renvoyer à l'édition-->
            <xsl:if test="$temoin_base_citation != ''">
                <xsl:text>apparat_</xsl:text>
            </xsl:if>
            <!--On veut distinguer les notes dans les citations avec apparat, pour renvoyer à l'édition-->
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
            <xsl:text>}{\lemma{</xsl:text>
            <!--            <xsl:value-of select="ancestor::tei:app/descendant::tei:rdg[contains(@wit, $temoin_base_edition)]/tei:w"/>-->
            <xsl:text>}\Bfootnote[nonum]{</xsl:text>
            <!--<xsl:choose>
                <xsl:when test="
                        not(ancestor::tei:rdgGrp/descendant::tei:rdg[contains(@wit, $temoin_base_edition)])
                        and not(ancestor::tei:rdg[contains(@wit, $temoin_base_edition)])">
                    <xsl:text>| </xsl:text>
                    <xsl:apply-templates select="ancestor::tei:rdg/tei:w" mode="apparat"/>
                    <xsl:text> </xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>-->
            <xsl:text>-- Ajout <!--(\textit{--></xsl:text>
            <!--<xsl:value-of select="myfunctions:witstosigla(@corresp | ancestor::node()/@corresp[1])"/>-->
            <xsl:text><!--})--> d'une main</xsl:text>
            <xsl:choose>
                <xsl:when test="@place = 'margin'">
                    <xsl:text> en marge</xsl:text>
                </xsl:when>
                <xsl:when test="@place = 'intercolumn'">
                    <xsl:text> dans l'intercolonne</xsl:text>
                </xsl:when>
                <xsl:when test="@place = 'bottom'">
                    <xsl:text> en bas de page</xsl:text>
                </xsl:when>
                <xsl:when test="@place = 'inline'">
                    <xsl:text> en ligne</xsl:text>
                </xsl:when>
            </xsl:choose>
            <xsl:text> sur le témoin </xsl:text>
            <xsl:value-of select="$wit"/>
            <xsl:text>: \enquote{</xsl:text>
            <xsl:apply-templates mode="edition"/>
            <xsl:text>}}}</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="descendant::tei:handShift">
            <xsl:variable name="type">
                <xsl:choose>
                    <xsl:when test="@medium = 'encre'">
                        <xsl:text>d'encre</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>de main</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:text>\edtext{</xsl:text>
            <xsl:text>\edlabel{ed:</xsl:text>
            <!--On veut distinguer les notes dans les citations avec apparat, pour renvoyer à l'édition-->
            <xsl:if test="$temoin_base_citation != ''">
                <xsl:text>apparat_</xsl:text>
            </xsl:if>
            <!--On veut distinguer les notes dans les citations avec apparat, pour renvoyer à l'édition-->
            <xsl:value-of select="tei:desc/@xml:id"/>
            <xsl:text>}\label{</xsl:text>
            <!--On veut distinguer les notes dans les citations avec apparat, pour renvoyer à l'édition-->
            <xsl:if test="$temoin_base_citation != ''">
                <xsl:text>apparat_</xsl:text>
            </xsl:if>
            <xsl:value-of select="tei:desc/@xml:id"/>
            <xsl:text>}}{</xsl:text>
            <xsl:text>\Bfootnote[nonum]{</xsl:text>
            <!--On veut distinguer les notes dans les citations avec apparat, pour renvoyer à l'édition-->
            <xsl:text> -- Changement </xsl:text>
            <xsl:value-of select="$type"/>
            <xsl:text> pour le manuscrit </xsl:text>
            <xsl:choose>
                <xsl:when test="@ana = '#injected'">
                    <xsl:value-of select="myfunctions:witstosigla(@corresp)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="myfunctions:witstosigla($temoin_base)"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>.</xsl:text>
            <xsl:if test="tei:desc and $temoin_base_citation = ''">
                <xsl:text> </xsl:text>
                <xsl:apply-templates mode="edition" select="tei:desc"/>
            </xsl:if>
            <xsl:text>}}</xsl:text>
        </xsl:for-each>
        <xsl:for-each
            select="descendant::tei:space[not(ancestor::tei:w)][not(@ana = '#tokenisation' or @ana = '#tokenisation #agglutination-pct')]">
            <xsl:text>\edtext{}{\lemma{}\Bfootnote[nonum]{-- Un espace est laissé en blanc après ce mot dans le témoin </xsl:text>
            <xsl:value-of select="myfunctions:witstosigla(@corresp)"/>
            <xsl:text>.}}</xsl:text>
        </xsl:for-each>
        <xsl:if test="$temoin_base_citation = ''">
            <!--On ne veut pas imprimer les notes ecdotiques dans les citations avec apparat-->
            <xsl:for-each
                select="descendant::tei:note[@type = 'codico' or @type = 'variante'][not(ancestor::tei:subst) and not(ancestor::tei:del)]">
                <xsl:text>\edtext{</xsl:text>
                <xsl:text>\edlabel{</xsl:text>
                <!--On veut distinguer les notes dans les citations avec apparat, pour renvoyer à l'édition-->
                <xsl:if test="$temoin_base_citation != ''">
                    <xsl:text>apparat_</xsl:text>
                </xsl:if>
                <!--On veut distinguer les notes dans les citations avec apparat, pour renvoyer à l'édition-->
                <xsl:value-of select="@xml:id"/>
                <xsl:text>}</xsl:text>
                <xsl:text>}{\lemma{</xsl:text>
                <!--            <xsl:value-of select="ancestor::tei:app/descendant::tei:rdg[contains(@wit, $temoin_base_edition)]/tei:w"/>-->
                <xsl:text>}\Bfootnote[nonum]{</xsl:text>
                <!-- <xsl:choose>
                <xsl:when test="
                        not(ancestor::tei:rdgGrp/descendant::tei:rdg[contains(@wit, $temoin_base_edition)])
                        and not(ancestor::tei:rdg[contains(@wit, $temoin_base_edition)])">
                    <xsl:text>| </xsl:text>
                    <xsl:apply-templates select="ancestor::tei:rdg/tei:w" mode="apparat"/>
                    <xsl:text> </xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>-->
                <xsl:text>-- \textbf{Nota}</xsl:text>
                <xsl:if test="@type = 'codico'">
                    <xsl:text> (\textit{</xsl:text>
                    <xsl:value-of select="myfunctions:witstosigla(@corresp | ancestor::node()/@corresp[1])"/>
                    <xsl:text>})</xsl:text>
                </xsl:if>
                <xsl:text>: </xsl:text>
                <xsl:apply-templates select="node()" mode="edition"/>
                <xsl:text>}}</xsl:text>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>



    <!--Décommenter cette règle quand la ponctuation sera transférée-->
    <xsl:template match="tei:pc" mode="edition apparat citation_apparat edition_texte_latin omission_simple these orig ajout">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="contains(@corresp, $temoin_base)">
            <xsl:value-of select="."/>
        </xsl:if>
    </xsl:template>


    <xsl:template match="tei:w[ancestor::tei:app]" mode="edition citation_apparat apparat omission_simple">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="contains(@ana, '#same_word') and not(tei:*)">
                <!--On évite d'utiliser la commande quand il y a des noeuds à l'intérieur, ça casse tout-->
                <!--C'est pas propre mais on est plus à ça près. Trouvé dans le manuel de reledmac.-->
                <xsl:text>\sameword[1]{</xsl:text>
                <xsl:apply-templates mode="#current"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="#current"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when
                test="ancestor::tei:app[not(contains(@ana, 'omission'))][contains(@ana, 'not_apparat') or contains(@ana, 'filtre') or contains(@ana, 'graphique')] and following::node()[self::tei:pc | self::tei:app | self::tei:witStart][1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base)][node()]]]">
                <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>




    <xsl:template
        match="tei:app[@ana = '#genre'] | tei:app[contains(@ana, '#not_apparat')] | tei:app[@ana = '#normalisation'] | tei:app[@ana = '#graphique'] | tei:app[contains(@ana, '#transposition')] | tei:app[@ana = '#filtre'] | tei:app[@ana = '#auxiliarite'] | tei:app[@ana = '#numerale']"
        mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text> </xsl:text>
        <xsl:choose>
            <!--Les notes de type codico dans un non-apparat vont finalement dans l'apparat, qui va rendre des informations codico comme textuelles-->
            <xsl:when
                test="descendant::tei:add[@type = 'correction'][ancestor::tei:w][not(ancestor::tei:subst)] or descendant::tei:note or descendant::tei:add[@type = 'commentaire'][not(@rend = 'cacher')] or descendant::tei:subst or descendant::tei:handShift or descendant::tei:space[not(@ana = '#tokenisation')]">
                <xsl:choose>
                    <!--On ne veut pas d'apparat qui indique les notes dans les citations avec apparat-->
                    <xsl:when
                        test="$temoin_base_citation = '' or descendant::tei:add[@type = 'correction'][ancestor::tei:w][not(ancestor::tei:subst)] or descendant::tei:add[@type = 'commentaire'][not(@rend = 'cacher')] or descendant::tei:subst or descendant::tei:handShift or descendant::tei:space[not(@ana = '#tokenisation')]">
                        <xsl:text>\edtext{</xsl:text>
                        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base)]" mode="apparat"/>
                        <xsl:text>}{\Bfootnote{</xsl:text>
                        <xsl:text>}}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base)]" mode="edition"/>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base)]" mode="edition"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template match="tei:rdg[not(ancestor::tei:app[contains(@ana, 'transposition')])]" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="descendant::tei:w">
                <xsl:apply-templates mode="edition"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\textit{om.}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="tei:rdg[ancestor::tei:app[contains(@ana, 'transposition')]]" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="descendant::tei:w">
                <xsl:apply-templates mode="apparat"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="tei:rdg" mode="ajout">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="descendant::tei:w">
                <xsl:apply-templates mode="apparat"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\textit{om.}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <!--Reprendre ici-->
        <xsl:if test="ancestor::tei:app/following-sibling::tei:app">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template match="tei:witStart" mode="edition citation_apparat apparat ajout omission_simple">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:variable name="temoin_base_citation" select="myfunctions:base_witness(.)"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="not($temoin_base_citation)">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not(contains(@corresp, $temoin_base))">
                <xsl:variable name="wits" select="lower-case(string-join(myfunctions:witstosigla(@corresp)))"/>
                <xsl:text>\textsuperscript{</xsl:text>
                <xsl:value-of select="$wits"/>
                <xsl:text>}</xsl:text>
                <xsl:text> </xsl:text>
            </xsl:when>
        </xsl:choose>
        <!--<xsl:variable name="previous" select="translate(@previous, '#', '')"/>-->
        <!--<xsl:if test="preceding::tei:witEnd[contains(@xml:id, $previous)][@ana = '#homeoteleuton']">
            <xsl:text>\footnoteB{Saut du même au même ici pour </xsl:text>
            <xsl:value-of select="myfunctions:witstosigla(@corresp)"/>
            <xsl:text>.}</xsl:text>
        </xsl:if>-->
    </xsl:template>


    <xsl:template match="tei:witEnd" mode="edition citation_apparat apparat ajout omission_simple">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text>%</xsl:text>
        <xsl:value-of select="$temoin_base"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:variable name="div_n" select="ancestor::tei:div[@type = 'chapitre']/@n"/>
        <xsl:choose>
            <!--Quand le témoin de base n'est pas concerné, c'est le cas le plus simple: on n'a qu'à indiquer par une lettre en exposant
            le ou les témoins où le texte s'arrête.-->
            <xsl:when test="not(contains(@corresp, $temoin_base))">
                <xsl:text>% Cas 1 &#10;</xsl:text>
                <xsl:variable name="wits" select="myfunctions:witstosigla(@corresp)"/>
                <xsl:text>\textsuperscript{</xsl:text>
                <xsl:value-of select="$wits"/>
                <xsl:text>}</xsl:text>
                <xsl:text> </xsl:text>
            </xsl:when>
            <!--Dans le cas contraire, ça se complique: il faut aller indiquer qu'à un point précis il y a un bout de texte que
            le témoin base ne propose pas. On va donc devoir travailler sur du contexte à gauche pour produire un apparat compréhensible-->
            <xsl:otherwise>
                <xsl:text>% Omission: Cas 2 &#10;</xsl:text>
                <xsl:variable name="wits" select="@xml:id"/>
                <xsl:choose>
                    <!--Omission simple-->
                    <xsl:when test="following::tei:witStart[contains($wits, translate(@previous, '#', ''))]">
                        <xsl:variable name="following_witstart_id"
                            select="following::tei:witStart[contains($wits, translate(@previous, '#', ''))]/@xml:id"/>
                        <xsl:variable name="next_node_div_n"
                            select="following::tei:witStart[contains($wits, translate(@previous, '#', ''))]/ancestor::tei:div[@type = 'chapitre']/@n"/>
                        <xsl:variable name="corresponding_nodes">
                            <!--Essayer de simplifier l'expression.-->
                            <xsl:copy-of
                                select="following::tei:app[ancestor::tei:div[@type = 'chapitre'][@n &gt; $div_n - 1][@n &lt; $next_node_div_n + 1]][following::tei:witStart[@xml:id = $following_witstart_id]]"
                            />
                        </xsl:variable>
                        <xsl:variable name="preceding_omitted_lemma">
                            <xsl:choose>
                                <xsl:when
                                    test="preceding-sibling::node()[self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base)][node()]] | self::tei:w][1]/name() = 'app'">
                                    <xsl:apply-templates
                                        select="preceding-sibling::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base)][node()]][1]/descendant::tei:rdg[contains(@wit, $temoin_base)]/tei:w"
                                        mode="apparat"/>
                                    <xsl:value-of select="myfunctions:debug(concat('Wit:', translate($temoin_base, '_', '')))"/>
                                    <xsl:value-of select="myfunctions:debug('[Code OM TRUE]')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="not(preceding-sibling::node()[self::tei:w])">
                                            <xsl:text>ø</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="myfunctions:debug('[Code OM FALSE]')"/>
                                            <xsl:apply-templates select="preceding-sibling::node()[self::tei:w][1]" mode="apparat"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="preceding_omitted_witnesses">
                            <xsl:choose>
                                <xsl:when
                                    test="preceding-sibling::node()[self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base)][node()]] | self::tei:w][1]/name() = 'app'">
                                    <xsl:value-of
                                        select="myfunctions:witstosigla(preceding-sibling::node()[self::tei:app][descendant::tei:rdg[contains(@wit, $temoin_base)][node()]][1]/descendant::tei:rdgGrp[contains(string-join(descendant::tei:rdg/@wit), $temoin_base)]/descendant::tei:rdg/@wit)"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="substring-after($temoin_base, '_')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <!--Il faut choisir un autre témoin base. On prend le premier de la liste, arbitrairement.-->
                        <!--https://stackoverflow.com/a/25405132-->
                        <xsl:variable name="other_base_witness">
                            <xsl:value-of
                                select="replace(following::tei:app[1]/descendant::tei:rdg[descendant::tei:w][1]/@wit, '^.*#', '')"
                            />
                        </xsl:variable>
                        <xsl:text>%Temoin base autre choisi: </xsl:text>
                        <xsl:value-of select="$other_base_witness"/>
                        <xsl:text>&#10;</xsl:text>
                        <!--Il faut choisir un autre témoin base. On prend le premier de la liste, arbitrairement.-->

                        <xsl:variable name="preceding_omitted_lemma_other_witness">
                            <xsl:choose>
                                <xsl:when
                                    test="preceding-sibling::node()[self::tei:app[descendant::tei:rdg[contains(@wit, $other_base_witness)][node()]] | self::tei:w][1]/name() = 'app'">
                                    <!--<xsl:apply-templates
                                        select="preceding-sibling::node()[self::tei:app][descendant::tei:rdg[contains(@wit, $other_base_witness)][node()]][1]/descendant::tei:rdg[contains(@wit, $other_base_witness)]/tei:w"
                                        mode="apparat"/>-->
                                    <xsl:apply-templates
                                        select="preceding-sibling::tei:app[descendant::tei:rdg[contains(@wit, $other_base_witness)]][1]/descendant::tei:rdg[contains(@wit, $other_base_witness)]"
                                        mode="omission_simple"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of
                                        select="myfunctions:debug(concat('[other base witness: ', string-join(myfunctions:witstosigla($other_base_witness)), ']'))"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="preceding-sibling::node()[self::tei:w][1]" mode="apparat"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:text>\edtext{}{\lemma{</xsl:text>
                        <xsl:value-of select="$preceding_omitted_lemma"/>
                        <xsl:text>}\Bfootnote{\textit{</xsl:text>
                        <xsl:value-of select="$preceding_omitted_witnesses"/>
                        <xsl:text>} | </xsl:text>
                        <!--<xsl:if test="@ana = '#homeoteleuton'">
                            <!-\-<xsl:text> Saut du même au même pour le témoin base: </xsl:text>-\->
                        </xsl:if>-->
                        <xsl:value-of select="$preceding_omitted_lemma_other_witness"/>
                        <!--On remet le lemme du témoin base, il faudra peut être changer cela par la suite.-->
                        <xsl:text> </xsl:text>
                        <xsl:apply-templates select="$corresponding_nodes" mode="omission_simple">
                            <xsl:with-param name="temoin_base_edition" select="$other_base_witness" tunnel="yes"/>
                        </xsl:apply-templates>
                        <xsl:text>~\textit{</xsl:text>
                        <xsl:value-of
                            select="myfunctions:witstosigla(following::tei:app[1]/descendant::tei:rdg[descendant::tei:w]/@wit)"/>
                        <xsl:text>}}}</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--Globalement ça marche, mais il faut que l'alignement soit parfait.-->




    <xsl:template match="tei:date" mode="these">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:text>\textsc{</xsl:text>
        <xsl:value-of select="text()"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="tei:hi[@rend = 'exposant']">
            <xsl:text>\textsuperscript{</xsl:text>
            <xsl:value-of select="tei:hi[@rend = 'exposant']"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:rdg[not(node())]" mode="omission_simple">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:text>ø \textit{</xsl:text>
        <xsl:value-of select="myfunctions:witstosigla(tei:rdg[not(node())]/@wit)"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:app[not(contains(@ana, 'lexicale')) and not(contains(@ana, 'morphosyntaxique'))]"
        mode="omission_simple">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_edition)]" mode="omission_simple">
            <xsl:with-param name="temoin_base_edition" select="$temoin_base_edition"/>
        </xsl:apply-templates>
        <!--<xsl:text>% Mode omission simple - variante </xsl:text>
        <xsl:value-of select="@ana"/>
        <xsl:text> Témoin base </xsl:text>
        <xsl:value-of select="$temoin_base"/>
        <xsl:text>&#10;</xsl:text>-->
    </xsl:template>

    <xsl:template match="tei:subst" mode="omission_simple" priority="2">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base"/>
        <xsl:variable name="corresp" select="@corresp"/>
        <xsl:text> [\textit{</xsl:text>
        <xsl:value-of select="myfunctions:witstosigla(ancestor::tei:rdg/@wit)"/>
        <xsl:text>} </xsl:text>
        <xsl:text>\textit{del.} </xsl:text>
        <xsl:apply-templates select="descendant::tei:del"/>
        <xsl:text> \textit{et add.} </xsl:text>
        <xsl:apply-templates select="descendant::tei:add"/>
        <xsl:text>] </xsl:text>
    </xsl:template>


    <xsl:template match="tei:app[contains(@ana, 'lexicale') or contains(@ana, 'morphosyntaxique')]" mode="omission_simple">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base"/>
        <xsl:text> [</xsl:text>
        <xsl:for-each select="descendant::tei:rdgGrp">
            <xsl:variable name="grouped_sigla">
                <xsl:value-of select="myfunctions:witstosigla(descendant::tei:rdg/@wit)"/>
            </xsl:variable>
            <!--On prend le premier.-->
            <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_edition)]" mode="omission_simple">
                <xsl:with-param name="temoin_base_edition" select="$temoin_base_edition"/>
            </xsl:apply-templates>
            <xsl:text> \textit{</xsl:text>
            <xsl:value-of select="$grouped_sigla"/>
            <xsl:text>}</xsl:text>
            <xsl:if test="following-sibling::tei:rdgGrp">
                <xsl:text> | </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>] </xsl:text>
        <!--<xsl:text>% Mode omission simple - variante </xsl:text>
        <xsl:value-of select="@ana"/>
        <xsl:text> Témoin base </xsl:text>
        <xsl:value-of select="$temoin_base"/>
        <xsl:text>&#10;</xsl:text>-->
    </xsl:template>



    <!--On va ignorer tous les éléments qui ne sont pas dans le texte.-->
    <xsl:template match="tei:app" priority="3" mode="edition citation_apparat">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="not(contains(string-join(descendant-or-self::tei:rdg/@wit), $temoin_base))"/>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--On va ignorer tous les éléments qui ne sont pas dans le texte.-->


    <xsl:template match="tei:app[contains(@ana, '#omission')][not(contains(@ana, '#transposition'))]" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="witnesses" select="descendant::tei:rdg[not(node())]/@wit"/>
        <xsl:variable name="present_witnesses" select="descendant::tei:rdg[node()]/@wit"/>
        <xsl:text> </xsl:text>
        <xsl:choose>
            <!--Si le témoin omis est le témoin base, il faut aller chercher du contexte-->
            <!--TODO: affiner la fonction pour aller chercher du contexte cohérent et ne pas mélanger les témoins.-->
            <xsl:when test="contains($witnesses, $temoin_base)">
                <!--Il faut reprendre le code ici, ça ne marche pas tout le temps.-->
                <!--On récupère le lemme précédent du témoin base.-->
                <xsl:variable name="preceding_omitted_lemma">
                    <xsl:choose>
                        <xsl:when
                            test="preceding-sibling::node()[self::tei:app[descendant::tei:rdg[not(contains(@wit, $temoin_base))][node()] | self::tei:w]][1]/name() = 'app'">
                            <xsl:apply-templates
                                select="preceding-sibling::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base)][node()]][1]/descendant::tei:rdg[contains(@wit, $temoin_base)]/tei:w"
                                mode="apparat">
                                <xsl:with-param name="temoin_base_edition" select="$temoin_base_edition" tunnel="yes"/>
                                <xsl:with-param name="temoin_base_citation" select="$temoin_base_citation" tunnel="yes"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="preceding::tei:app[1]/descendant::tei:w[1]" mode="apparat"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="omm_wits"
                    select="myfunctions:witstosigla(descendant::tei:rdg[contains(@wit, $temoin_base)]/@wit)"/>
                <xsl:text>\edtext{</xsl:text>
                <xsl:text>}{</xsl:text>
                <xsl:text>\Bfootnote{</xsl:text>
                <xsl:value-of select="myfunctions:debug('[OM1]')"/>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text> \textit{</xsl:text>
                <xsl:value-of select="$omm_wits"/>
                <xsl:text>} | </xsl:text>
                <!--On va chercher du contexte avec cette fonction-->
                <xsl:value-of
                    select="myfunctions:get_apparatus_omission_simple_base_wit(., $temoin_base_edition, $temoin_base_citation)"/>
                <!--On va chercher du contexte avec cette fonction-->
                <xsl:text>}}</xsl:text>
            </xsl:when>
            <!--Si le témoin omis est le témoin base-->
            <!--Sinon, un peu plus simple-->
            <xsl:otherwise>
                <xsl:text>\edtext{</xsl:text>
                <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base)]" mode="apparat"/>
                <xsl:text>}{\lemma{</xsl:text>
                <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base)]" mode="apparat"/>
                <xsl:text>}</xsl:text>
                <xsl:text> \Bfootnote{</xsl:text>
                <!--Ici il faut ajouter un omm. dans l'apparat sans que ça se voie dans le corps du texte.-->
                <xsl:value-of select="myfunctions:debug('[OM2] ')"/>
                <xsl:text>\textit{</xsl:text>
                <!--Pour chaque témoin, ne faire apparaître que la lettre correspondante-->
                <xsl:choose>
                    <!--S'il y a un rdgGrp (= si d'autres leçons sont identiques modulo variation graphique à la leçon base)-->
                    <xsl:when test="boolean(descendant::tei:rdgGrp[descendant::tei:rdg[contains(@wit, $temoin_base)]])">
                        <xsl:variable name="lemma_wits"
                            select="myfunctions:witstosigla(descendant::tei:rdg[contains(@wit, $temoin_base)]/@wit)"/>
                        <xsl:variable name="siblings">
                            <xsl:value-of select="
                                    myfunctions:witstosigla(descendant::tei:rdg[contains(@wit, $temoin_base)]/following-sibling::tei:rdg/@wit |
                                    descendant::tei:rdg[contains(@wit, $temoin_base)]/preceding-sibling::tei:rdg/@wit)"
                            />
                        </xsl:variable>
                        <!--Il y a parfois des rdgGrp qui ne contiennent qu'un tei:rdg: dans ce cas, n'imprimer que la valeur du témoin base-->
                        <xsl:choose>
                            <xsl:when
                                test="boolean(count(descendant::tei:rdgGrp[descendant::tei:rdg[contains(@wit, $temoin_base)]]/descendant::tei:rdg) > 1)">
                                <xsl:value-of select="concat(string-join($lemma_wits), $siblings)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$lemma_wits"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!--Il y a parfois des rdgGrp qui ne contiennent qu'un tei:rdg: dans ce cas, n'imprimer que la valeur du témoin base-->
                    </xsl:when>
                    <!--S'il y a un rdgGrp (= si d'autres leçons sont identiques modulo variation graphique à la leçon base)-->
                    <xsl:otherwise>
                        <xsl:value-of select="myfunctions:witstosigla(tei:rdg[contains(@wit, $temoin_base)]/@wit)"/>
                    </xsl:otherwise>
                </xsl:choose>
                <!--Pour chaque témoin, ne faire apparaître que la lettre correspondante-->
                <xsl:text>} |\,</xsl:text>
                <!--La même chose mais en utilisant une autre méthode-->
                <xsl:choose>
                    <xsl:when test="descendant::tei:rdgGrp">
                        <xsl:for-each
                            select="descendant::tei:rdgGrp[count(descendant::tei:rdg[contains(@wit, $temoin_base)]) = 0]">
                            <!--L'idée ici est de raffiner les apparats pour rassembler les variantes graphiques entre elles-->
                            <xsl:for-each select="descendant::tei:rdg">
                                <xsl:variable name="sigle_temoin" select="myfunctions:witstosigla(@wit)"/>
                                <xsl:choose>
                                    <xsl:when test="descendant::text()">
                                        <xsl:if test="not(preceding-sibling::tei:rdg)">
                                            <xsl:apply-templates select="." mode="apparat"/>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>\textit{om.}</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text> \textit{</xsl:text>
                                <xsl:value-of select="$sigle_temoin"/>
                                <!--<xsl:if
                            test="not(count(ancestor::tei:rdgGrp/descendant::tei:rdg) = 1) and not(following-sibling::tei:rdg)">
                            <xsl:text>~c.v.</xsl:text>
                            </xsl:if>-->
                                <xsl:text>} </xsl:text>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="tei:rdg[not(contains(@wit, $temoin_base))]">
                            <xsl:variable name="sigle_temoin" select="myfunctions:witstosigla(@wit)"/>
                            <xsl:choose>
                                <xsl:when test="descendant::text()">
                                    <xsl:apply-templates select="." mode="edition"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>\textit{om.}</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>\textit{</xsl:text>
                            <xsl:value-of select="$sigle_temoin"/>
                            <xsl:text>} </xsl:text>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>}}</xsl:text>
            </xsl:otherwise>
            <!--Sinon, un peu plus simple-->
        </xsl:choose>
        <!--<xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base)][node()]]]">
            <xsl:text> %&#10;</xsl:text>
        </xsl:if>-->
    </xsl:template>


    <xsl:template match="tei:choice[tei:corr]" mode="citation_apparat edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:apply-templates select="tei:corr" mode="#current"/>
    </xsl:template>



    <xsl:template match="tei:anchor[@type = 'ligne' or @type = 'citation']" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <!--https://tex.stackexchange.com/a/321814-->
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$temoin_base_citation = ''">
                <xsl:if test="@type = 'citation' and $debug = 'True'">
                    <xsl:text>\textsuperscript{[Cit:</xsl:text>
                    <xsl:value-of select="@xml:id"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="translate(@corresp, '#_', '')"/>
                    <xsl:text>]}</xsl:text>
                </xsl:if>
                <xsl:text>\phantomsection\edlabel{</xsl:text>
                <xsl:if test="$temoin_base_citation != ''">
                    <xsl:message>Found you</xsl:message>
                    <xsl:text>apparat_</xsl:text>
                </xsl:if>
                <xsl:value-of select="@xml:id"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:anchor[@type = 'reference']" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <!--https://tex.stackexchange.com/a/321814-->
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:text>\phantomsection\edlabel{</xsl:text>
        <xsl:if test="$temoin_base_citation != ''">
            <xsl:text>apparat_</xsl:text>
        </xsl:if>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:lb" mode="edition"/>
    <!--Règle principale sur les apparats-->


    <xsl:template match="
            tei:app[@ana = '#entite_nommee'][count(descendant::tei:rdg) > 1]
            | tei:app[@ana = '#lexicale'][count(descendant::tei:rdg) > 1]
            | tei:app[@ana = '#morphosyntaxique'][count(descendant::tei:rdg) > 1]
            | tei:app[@ana = '#indetermine'][count(descendant::tei:rdg) > 1]
            | tei:app[@ana = '#personne'][count(descendant::tei:rdg) > 1]
            " mode="edition">
        <!-- | tei:app[descendant::tei:rdg[descendant::node()[self::tei:del]]]-->
        <!--Ici la dernière règle cherche en réalité les variantes matérielles pas encore identifiées dans le xml. ça passe.-->
        <xsl:param name="temoin_base_citation" tunnel="yes"/>
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:variable name="temoin_base">
            <xsl:choose>
                <xsl:when test="$temoin_base_citation = ''">
                    <xsl:value-of select="$temoin_base_edition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_citation"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text> </xsl:text>
        <xsl:text>\edtext{</xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base)]" mode="apparat"/>
        <xsl:text>}{</xsl:text>
        <xsl:if
            test="descendant::tei:rdg[contains(@wit, $temoin_base)]/parent::tei:rdgGrp/descendant::tei:rdg[not(contains(@wit, $temoin_base))][tei:del]">
            <!--Règle sur les suppressions de texte à changer en amont au niveau de collator (identification des variantes matérielles)-->
            <xsl:text>\lemma{</xsl:text>
            <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base)]" mode="apparat"/>
            <xsl:apply-templates
                select="descendant::tei:rdg[contains(@wit, $temoin_base)]/parent::tei:rdgGrp/descendant::tei:rdg[not(contains(@wit, $temoin_base))]/tei:del"
                mode="edition"/>
            <!--Règle sur les suppressions de texte à changer en amont au niveau de collator (identification des variantes matérielles)-->
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>\Bfootnote{</xsl:text>
        <xsl:if test="count(descendant::tei:rdgGrp) > 1">
            <!--Ici il faut ajouter un omm. dans l'apparat sans que ça se voie dans le corps du texte.-->
            <!--Pour chaque témoin, ne faire apparaître que la lettre correspondante, avec le témoin base en premier.-->
            <xsl:text> \textit{</xsl:text>
            <xsl:value-of select="myfunctions:witstosigla($temoin_base)"/>
            <xsl:value-of select="
                    translate(
                    string-join(
                    myfunctions:witstosigla(
                    descendant::tei:rdgGrp[descendant::tei:rdg[contains(@wit, $temoin_base)]]/tei:rdg/@wit
                    )
                    ),
                    myfunctions:witstosigla($temoin_base),
                    '')"/>
            <xsl:text>}</xsl:text>
            <!--Pour chaque témoin, ne faire apparaître que la lettre correspondante-->
            <xsl:text>\,|\,</xsl:text>
        </xsl:if>
        <!--La même chose mais en utilisant une autre méthode-->
        <xsl:variable name="grouped_sigla">
            <xsl:for-each select="descendant::tei:rdgGrp[not(descendant::tei:rdg[contains(@wit, $temoin_base)])]">
                <xsl:choose>
                    <xsl:when test="child::tei:rdg[node()]">
                        <xsl:value-of select="myfunctions:debug('[rdg1]')"/>
                        <xsl:apply-templates select="descendant::tei:rdg[1]" mode="apparat"/>
                        <xsl:text> \textit{</xsl:text>
                        <xsl:value-of select="myfunctions:witstosigla(descendant::tei:rdg[1]/@wit)"/>
                        <xsl:value-of select="myfunctions:witstosigla(descendant::tei:rdg[position() > 1]/@wit)"/>
                        <xsl:text>} </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\textit{om.}</xsl:text>
                        <xsl:text> \textit{</xsl:text>
                        <xsl:value-of select="myfunctions:witstosigla(tei:rdg/@wit)"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$grouped_sigla"/>
        <xsl:text>}}</xsl:text>
        <!--<xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_edition)][node()]]]">
            <xsl:text> %&#10;</xsl:text>
        </xsl:if>-->
    </xsl:template>
    <!--STRUCTURE DU TEXTE-->
    <!--Choisir et marquer le chapitre-->
    <!--Choisir et marquer la glose/traduction-->
    <!--Choisir et marquer la glose/traduction-->
    <!--STRUCTURE DU TEXTE-->
    <!--MISE EN PAGE-->
    <!--Marquer les paragraphes par un retour à la ligne-->
    <xsl:template match="tei:p[ancestor::tei:TEI[@xml:id = 'Rome_W']]" mode="edition">
        <xsl:variable name="div_n" select="ancestor::tei:div[@type = 'chapitre']/@n"/>
        <xsl:variable name="paragraph_ident" select="@n"/>
        <xsl:text>\par \phantomsection\label{latin</xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="$s_doc/descendant::tei:div[@type = 'chapitre'][@n = $div_n]/descendant::tei:p[@n = $paragraph_ident]/node()">
            <xsl:text>\hyperref[val_s_</xsl:text>
            <xsl:value-of select="@n"/>
            <xsl:text>]{$\Delta$} </xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="edition"/>
    </xsl:template>

    <xsl:template match="tei:head" mode="titre_edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:message>
            <xsl:text>X</xsl:text>
        </xsl:message>
        <xsl:message select="$temoin_base_edition"/>
        <xsl:text>{\LARGE </xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:if test="ancestor::tei:TEI[@xml:id = 'Val_S']">
            <xsl:text>\footnoteA{On trouvera le chapitre correspondant de l'imprimé latin en annexe, p. \pageref{Rome_W_3_3_</xsl:text>
            <xsl:value-of select="parent::tei:div/@n"/>
            <xsl:text>}.}</xsl:text>
        </xsl:if>
        <xsl:text>}</xsl:text>
    </xsl:template>


    <xsl:template match="tei:head" mode="edition"/>


    <xsl:template match="tei:p[parent::tei:div[@type = 'traduction']]" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:variable name="div_n" select="ancestor::tei:div[@type = 'chapitre']/@n"/>
        <xsl:variable name="paragraph_ident" select="@n"/>
        <xsl:choose>
            <xsl:when test="not(preceding::tei:p[ancestor::tei:div[@type = 'chapitre'][@n = $div_n]])">
                <xsl:text>\pstart </xsl:text>
                <xsl:text>\phantomsection\label{</xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>}</xsl:text>
                <xsl:apply-templates select="ancestor::tei:div[@type = 'chapitre']/tei:head" mode="titre_edition"/>
                <xsl:text>\pend</xsl:text>
                <!--<xsl:if test="not(ancestor::tei:TEI[@xml:id = 'Val_S'])">
                    <xsl:text>\memorybreak</xsl:text>
                </xsl:if>-->
                <xsl:text>\pstart \vspace{1cm}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <!-- <xsl:if test="following-sibling::tei:p and not(ancestor::tei:TEI[@xml:id = 'Val_S'])">
                    <xsl:text>% TEST &#10;</xsl:text>
                    <xsl:text>\memorybreak</xsl:text>
                </xsl:if>-->
                <!--Cette commande permet de gérer les problèmes de mémoire de LaTeX. Voir le manuel de reledmac-->
                <xsl:text>\pstart </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if
            test="ancestor::tei:TEI[@subtype = 'version_a'] and $latin_doc/descendant::tei:div[@type = 'chapitre'][@n = $div_n]/descendant::tei:p[@n = $paragraph_ident]/node()">
            <!--On teste si le paragraphe correspondant du texte latin est vide-->
            <xsl:text>\hyperref[</xsl:text>
            <xsl:value-of select="concat('latin', @n)"/>
            <xsl:text>]{$\nabla$} </xsl:text>
        </xsl:if>
        <xsl:text>\phantomsection\label{</xsl:text>
        <xsl:choose>
            <xsl:when test="ancestor::tei:TEI[@xml:id = 'Val_S']">
                <xsl:value-of select="concat('val_s_', @n)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@n"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>}</xsl:text>
        <xsl:choose>
            <xsl:when test="not(preceding-sibling::tei:p) and not(ancestor::tei:TEI[@subtype = 'version_a'])">
                <xsl:text> {\ledrightnote{\hspace{.6cm}\textbf{[Trad.]}}}</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
        <xsl:if
            test="ancestor::tei:TEI[@xml:id = 'Val_S'] or ancestor::tei:TEI[@xml:id = 'Rome_W'] or descendant::tei:rdg[node()][contains(@wit, $temoin_base_edition)] or @rend = 'show'">
            <xsl:apply-templates mode="edition"/>
        </xsl:if>
        <xsl:text>\pend</xsl:text>
    </xsl:template>




    <xsl:template match="tei:p[parent::tei:div[@type = 'glose']]" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:variable name="corresponding_xml_document"
            select="document(concat('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan/', $temoin_base_edition, '.xml'))"/>
        <!--Passer à un test sur le document non tokénisé, c'est trop long ici.-->
        <xsl:variable name="p_n" select="@n"/>
        <xsl:variable name="div_n" select="ancestor::tei:div[@type = 'chapitre']/@n"/>
        <xsl:if test="$corresponding_xml_document/descendant::tei:p[@n = $p_n]">
            <!--<xsl:if test="preceding-sibling::tei:p[ancestor::tei:div[@type = 'glose']]">
                <xsl:text>\pend\memorybreak\pstart</xsl:text>
            </xsl:if>
            <xsl:text> \phantomsection\label{</xsl:text>-->
            <xsl:if test="not(preceding-sibling::tei:p)">
                <xsl:text>~</xsl:text>
            </xsl:if>
            <xsl:text>\\\phantomsection\label{</xsl:text>
            <xsl:value-of select="@n"/>
            <xsl:text>}\indent</xsl:text>
            <xsl:if test="not(preceding::tei:p[ancestor::tei:div[@type = 'chapitre'][@n = $div_n]])">
                <xsl:apply-templates select="ancestor::tei:div[@type = 'chapitre']/tei:head" mode="titre_edition"/>
            </xsl:if>
            <xsl:if test="not(preceding-sibling::tei:p) and not(ancestor::tei:TEI[@subtype = 'version_a'])">
                <xsl:text>{\ledrightnote{\hspace{.6cm}\textbf{[Glose]}}}</xsl:text>
            </xsl:if>
            <xsl:if test="descendant::tei:rdg[node()][contains(@wit, $temoin_base_edition)] or @rend = 'show'">
                <xsl:apply-templates mode="edition"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>



    <!--TODO: idée pour les omissions. Pour chaque début d'omission. aller chercher tous les witEnd qui ne suivent pas un witEnd; aller jusqu'au prochain witStart 
    appliquer toutes les règles. Puis on va chercher le suivant, et on applique les règles dans la même note, en indiquant: tel témoin continue l'omission; etc etc-->
    <xsl:template match="tei:div[@type = 'glose']" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:variable name="base_wit">
            <xsl:value-of select="myfunctions:get_base_wit(.)"/>
        </xsl:variable>
        <xsl:text>\pstart </xsl:text>
        <xsl:apply-templates mode="edition">
            <xsl:with-param name="temoin_base_edition" select="$base_wit" tunnel="yes"/>
        </xsl:apply-templates>
        <xsl:text>\pend </xsl:text>
    </xsl:template>




    <xsl:function name="myfunctions:get_base_wit">
        <xsl:param name="node"/>
        <xsl:choose>
            <xsl:when test="$node[@corresp]">
                <xsl:value-of select="translate($node/@corresp, '#', '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$base_witness_edition"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>




    <xsl:template match="tei:div[@type = 'traduction']" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:variable name="base_wit">
            <xsl:value-of select="myfunctions:get_base_wit(.)"/>
        </xsl:variable>
        <xsl:message>
            <xsl:text>Division trouvée. Témoin base:</xsl:text>
            <xsl:value-of select="$base_wit"/>
        </xsl:message>
        <xsl:apply-templates mode="edition">
            <xsl:with-param name="temoin_base_edition" select="$base_wit" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>




    <xsl:template match="tei:fw" mode="edition"/>
    <xsl:template match="text()" mode="edition">
        <xsl:param name="temoin_base_edition" tunnel="yes"/>
        <xsl:variable name="remplacement1" select="replace(., '&amp;', '\\&amp;')"/>
        <xsl:value-of select="$remplacement1"/>
    </xsl:template>







</xsl:stylesheet>
