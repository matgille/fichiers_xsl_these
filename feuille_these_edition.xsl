<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:myfunctions="https://www.matthiasgillelevenson.fr/ns/1.0" xmlns:tex="placeholder.uri"
    exclude-result-prefixes="tex">

    <!--Cette feuille est adaptée à mon propre document XML-->
    <!--Merci à Arianne Pinche pour son aide précieuse dans cette feuille-->
    <!--Merci à Marjorie Burghart de m'avoir envoyé sa feuille de transformation qui m'a bien aidé-->
    <xsl:output method="text" omit-xml-declaration="no" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="fusion"/>

    <!--Plusieurs modes ici: 
    - édition: tout ce qui gère globalement le texte de l'édition
    - apparat: tout ce qui gère le fonctionnement de apparats
    - édition_texte_latin: le fonctionnement particulier du texte latin en annexe
    - omission_complexe: (marche pas trop) gère les omissions complexes-->

    <!--Variables concernant les omissions-->
    <xsl:variable name="omission_binaire">
        <xsl:text>#omission #binary</xsl:text>
    </xsl:variable>
    <!--Variables concernant les omissions-->



    <xsl:template match="tei:persName[@type = 'auteur']" mode="edition">
        <xsl:text>\textsc{</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <!--

    <xsl:template match="tei:alt" mode="edition">
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


    <xsl:template match="tei:note[parent::tei:del]" mode="edition">
        <xsl:text>\footnoteB{\label{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
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
        <!--On va chercher dans le fichier source pour ne pas avoir à tout calculer lorsqu'on change une note de bas de page-->
        <xsl:variable name="xml_id" select="@xml:id"/>
        <xsl:variable name="division" select="ancestor::tei:div[not(ancestor::tei:div)]/@n"/>
        <xsl:variable name="corresponding_wit">
            <xsl:choose>
                <xsl:when test="@ana = '#injected'">
                    <xsl:value-of select="translate(@corresp, '#', '')"/>
                </xsl:when>
                <xsl:when test="ancestor::node()[@ana = '#injected']">
                    <xsl:value-of
                        select="translate(ancestor::node()[@ana = '#injected']/@corresp, '#', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_base_edition"/>
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
        <!--On fait ça pour ne pas avoir à tout refaire lorsqu'on change une note de bas de page-->
        <xsl:text>}
        </xsl:text>
    </xsl:template>


    <xsl:template
        match="tei:note[@subtype = 'lexicale'] | tei:note[@type = 'general'] | tei:note[@type = 'sources'][not(parent::tei:del)]"
        mode="edition">
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
        <xsl:text>}</xsl:text>
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
        <!--On va chercher dans le fichier source pour ne pas avoir à tout calculer lorsqu'on change une note de bas de page-->
        <xsl:variable name="xml_id" select="@xml:id"/>
        <xsl:variable name="division" select="ancestor::tei:div[not(ancestor::tei:div)]/@n"/>
        <xsl:variable name="corresponding_wit">
            <xsl:choose>
                <xsl:when test="@ana = '#injected'">
                    <xsl:value-of select="translate(@corresp, '#', '')"/>
                </xsl:when>
                <xsl:when test="ancestor::node()[@ana = '#injected']">
                    <xsl:value-of
                        select="translate(ancestor::node()[@ana = '#injected']/@corresp, '#', '')"/>
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
    </xsl:template>



    <xsl:template match="tei:ref[@type = 'document_exterieur']" mode="edition">
        <xsl:text>\color{blue}</xsl:text>
        <xsl:value-of select="replace(replace(@target, '_', '\\_'), '../../../', '')"/>
        <xsl:text>\color{black}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:soCalled" mode="edition">
        <xsl:text>``</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>''</xsl:text>
    </xsl:template>

    <xsl:template match="tei:sic[not(@ana = '#omission')]" mode="#all">
        <xsl:apply-templates mode="edition"/>
        <xsl:text>\textsuperscript{\textit{[sic]}}</xsl:text>
    </xsl:template>



    <!--TODO: Ajouter toutes les images en annexe-->
    <xsl:template match="tei:graphic[parent::tei:note]" mode="edition">
        <xsl:text>figure \ref{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <!--TODO: Ajouter toutes les images en annexe-->



    <!--<xsl:template match="tei:sic[@ana = '#omission']" mode="edition">
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
        <xsl:apply-templates mode="edition"/>
    </xsl:template>


    <xsl:template match="tei:l" mode="edition">
        <xsl:apply-templates mode="edition"/>
        <xsl:if test="following-sibling::tei:l">
            <xsl:text>~\\</xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template match="tei:lb[@break = 'yes']" mode="edition">
        <xsl:text> </xsl:text>
    </xsl:template>



    <!--Édition du texte latin en annexe-->

    <xsl:template match="tei:div[@type = 'partie']" mode="edition_texte_latin">
        <xsl:apply-templates mode="edition_texte_latin"/>
    </xsl:template>

    <xsl:template match="tei:teiHeader | tei:head[not(ancestor::tei:div[@type = 'chapitre'])]"
        mode="edition_texte_latin"/>


    <xsl:template match="tei:div[@type = 'chapitre']" mode="edition_texte_latin">
        <xsl:text>
            \section*{</xsl:text>
        <xsl:apply-templates select="tei:head"/>
        <xsl:text>}\label{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
        <xsl:text>\phantomsection</xsl:text>
        <xsl:text>\stepcounter{section}</xsl:text>
        <xsl:text>\addcontentsline{toc}{section}{Chapitre </xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>}</xsl:text>
        <xsl:apply-templates select="child::tei:*[not(self::tei:head)]" mode="edition"/>
    </xsl:template>


    <xsl:template match="tei:figure[descendant::tei:desc]" mode="edition">
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
        <xsl:text>. Elle est reproduite en annexe: \ref{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}.}</xsl:text>
    </xsl:template>



    <!--Édition du texte latin en annexe-->

    <!--A terme remplace les tei:hi pour de l'istruction de mise en page dans les notes-->
    <xsl:template match="tei:foreign" mode="edition">
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

    <xsl:template match="tei:add[@type = 'correction'][not(ancestor::tei:subst)]" mode="edition">
        <xsl:variable name="preceding_lemma">
            <xsl:choose>
                <xsl:when
                    test="preceding-sibling::node()[self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_edition)][node()]] | self::tei:w][1]/name() = 'app'">
                    <xsl:apply-templates
                        select="preceding-sibling::node()[self::tei:app][descendant::tei:rdg[contains(@wit, $temoin_base_edition)][node()]][1]/descendant::tei:rdg[contains(@wit, $temoin_base_edition)]/tei:w"
                        mode="apparat"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="preceding-sibling::node()[self::tei:w][1]"
                        mode="apparat"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="place">
            <xsl:choose>
                <xsl:when test="@place = 'margin'">
                    <xsl:text> en marge</xsl:text>
                </xsl:when>
                <xsl:when test="@place = 'inline'">
                    <xsl:text>en ligne</xsl:text>
                </xsl:when>
                <xsl:when test="@place = 'above'">
                    <xsl:text>au dessus de la ligne</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates mode="edition"/>
        <xsl:variable name="corresp" select="@corresp"/>
        <xsl:text>\edtext{}{\lemma{</xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_edition)]"
            mode="ajout"/>
        <xsl:text>}\Afootnote{| </xsl:text>
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
        <xsl:value-of select="myfunctions:witstosigla($temoin_base_edition)"/>
        <xsl:text>.}}</xsl:text>
    </xsl:template>

    <!--<xsl:template
        match="tei:add[not(parent::tei:head)][not(@type = 'correction')][not(@type = 'commentaire')]"
        mode="edition">
        <xsl:if test="not(@place)">
            <xsl:value-of select="."/>
        </xsl:if>
        <xsl:if test="@place = 'inline'">
            <xsl:if test="ancestor::tei:app">
                <xsl:text>\textit{</xsl:text>
                <xsl:apply-templates mode="edition"/>
                <xsl:text>}</xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="@place = 'above'">
            <xsl:text>\textit{</xsl:text>
            <xsl:apply-templates mode="edition"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:if test="@place = 'margin'">
            <!-\-Si le add est inclus dans un apparat-\->
            <xsl:if test="ancestor::tei:app">
                <!-\-Si l'apparat n'est pas un apparat principal mais un apparat de point notables (notable)
                    >> note. On peut accepter la note de bas de page (éviter les notes de bas de page dans un apparat
                    critique...)-\->
                <!-\-Si l'apparat n'est pas un apparat principal mais un apparat de point notables (notable)-\->

                <xsl:text>\textit{</xsl:text>
                <xsl:apply-templates mode="edition"/>
                <xsl:text>}</xsl:text>


            </xsl:if>
            <!-\-Si le add est inclus dans un apparat-\->
            <xsl:if test="not(ancestor::tei:app)">
                <xsl:text>\footnote</xsl:text>
                <xsl:choose>
                    <xsl:when test="ancestor::tei:TEI[@subtype = 'version_a']">
                        <xsl:text>A</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>B</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>{</xsl:text>
                <xsl:if test="@corresp">
                    <xsl:text> [Ms. </xsl:text>
                    <xsl:value-of select="translate(@corresp, '#', '')"/>
                    <xsl:text>] </xsl:text>
                </xsl:if>
                <xsl:text>Ajouté </xsl:text>
                <xsl:text>(marge)</xsl:text>
                <xsl:text>: ``\textit{</xsl:text>
                <xsl:value-of select="text()"/>
                <xsl:text>}''</xsl:text>
                <xsl:if test="@hand">
                    <xsl:text> Main </xsl:text>
                    <xsl:value-of select="translate(@hand, '#_', '')"/>
                    <xsl:text>. </xsl:text>
                </xsl:if>
                <xsl:if test="./tei:note">
                    <xsl:apply-templates select="tei:note" mode="edition"/>
                </xsl:if>
                <xsl:if test="not(@note)"/>
                <xsl:text>}</xsl:text>
            </xsl:if>
        </xsl:if>
        <!-\-etc-\->
    </xsl:template>-->

    <xsl:template match="tei:add[@type = 'commentaire'][@rend = 'cacher']"
        mode="edition citation_apparat apparat">
        <xsl:message>Found you: <xsl:value-of select="@xml:id"/></xsl:message>
    </xsl:template>

    <xsl:template match="tei:add[@type = 'commentaire'][not(@rend = 'cacher')]"
        mode="edition apparat citation_apparat omission_simple">
        <xsl:variable name="wit" select="myfunctions:witstosigla(@corresp)"/>
        <xsl:text>\footnoteB{Glose d'une main</xsl:text>
        <xsl:choose>
            <xsl:when test="@place = 'margin'">
                <xsl:text> en marge</xsl:text>
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
        <xsl:text>}}</xsl:text>
    </xsl:template>


    <xsl:template match="tei:quote" priority="3" mode="#all">
        <xsl:choose>
            <xsl:when test="not(@type)">
                <xsl:text>\enquote{</xsl:text>
                <xsl:apply-templates mode="edition"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="tei:ref[@type = 'edition']" mode="edition">
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

    <xsl:template match="tei:ref[@type = 'interne']" mode="edition">
        <xsl:variable name="target" select="translate(@target, '#', '')"/>
        <xsl:choose>
            <xsl:when test="not(//tei:*[@xml:id = $target][ancestor-or-self::tei:graphic])">
                <xsl:choose>
                    <xsl:when test="//tei:*[@xml:id = $target][self::tei:note]">
                        <xsl:text>note \ref{</xsl:text>
                    </xsl:when>
                    <xsl:when test="//tei:*[@xml:id = $target][self::tei:anchor[@type = 'ligne']]">
                        <xsl:text>ligne \edlineref{</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\nameref{</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="$target"/>
                <xsl:text>}</xsl:text>
                <xsl:choose>
                    <xsl:when test="not(//tei:*[@xml:id = $target][self::tei:anchor[@type = 'ligne']])">
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
        <!--
        <xsl:if
            test="//tei:*[@xml:id = $target][ancestor-or-self::tei:graphic][node()]">
            <xsl:apply-templates mode="edition"/>
            <xsl:text> (figure \ref{</xsl:text>
            <xsl:value-of select="$target"/>
            <xsl:text>}, page \pageref{</xsl:text>
            <xsl:value-of select="$target"/>
            <xsl:text>})</xsl:text>
        </xsl:if>-->
    </xsl:template>

    <xsl:template match="tei:code[@lang = 'tagset'] | tei:code[@rend = 'show']" mode="edition">
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
    <xsl:template match="tei:supplied" name="supplied" mode="edition">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <!--Les ajouts de ma part sont entre crochets-->
    <!--AJOUTS-->


    <!--MODIFICATIONS CORRECTIONS-->
    <xsl:template match="tei:space" name="space" mode="edition">
        <xsl:text>\indent </xsl:text>
        <xsl:apply-templates mode="edition"/>
    </xsl:template>

    <xsl:template match="tei:teiHeader" mode="edition"/>

    <xsl:template match="tei:title" mode="edition">
        <xsl:if test="@type = 'section'">
            <xsl:text>\enquote{</xsl:text>
        </xsl:if>
        <xsl:text>\textit{</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@type = 'section'">
            <xsl:text>}</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:unclear" mode="edition">
        <xsl:text>~</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>(?)</xsl:text>
        <xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_edition)][node()]]]">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:choice" mode="edition">
        <xsl:value-of select="tei:corr"/>
        <xsl:value-of select="tei:reg"/>
        <xsl:value-of select="tei:expan"/>
    </xsl:template>


    <!--<xsl:template match="tei:damage" name="damage" mode="edition">
        <xsl:choose>
            <xsl:when test="text() = ''">
                <xsl:text>&#x2020; &#x2020;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\underline{</xsl:text>
                <xsl:apply-templates mode="edition"/>
                <xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->

    <xsl:template match="tei:gap" mode="edition">
        <xsl:text>\indent </xsl:text>
        <xsl:apply-templates mode="edition"/>
    </xsl:template>



    <!-- ignorer le text entre balises <del>-->
    <xsl:template match="tei:del[not(ancestor::tei:subst)]" mode="edition apparat omission_simple">
        <xsl:param name="temoin_base_edition"/>
        <xsl:variable name="temoin_base" select="myfunctions:base_witness(.)"/>
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
        <xsl:value-of select="$witness"/>
        <xsl:text>: </xsl:text>
        <xsl:text>\textit{del.} </xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <!-- ignorer le text entre balises <del>-->

    <!--Ici on va créer des règles pour afficher les éléments dans les apparats-->



    <!--Ici on va créer des règles pour afficher les éléments dans les apparats-->




    <xsl:template match="tei:div[@type = 'chapitre'][not(@type = 'glose' or @type = 'traduction')]"
        mode="edition">
        <xsl:message>Début chapitre <xsl:value-of select="@n"/></xsl:message>
        <xsl:variable name="div_n" select="@n"/>
        <xsl:text>\section*{}&#10;</xsl:text>
        <xsl:text>\phantomsection&#10;</xsl:text>
        <xsl:text>\stepcounter{section}&#10;</xsl:text>
        <xsl:text>\addcontentsline{toc}{section}{Chapitre </xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>}&#10;</xsl:text>
        <xsl:text>\begin{pages}&#10;</xsl:text>
        <xsl:text>\begin{Leftside}&#10;</xsl:text>
        <xsl:text>\beginnumbering&#10;</xsl:text>
        <xsl:apply-templates
            select="document('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan/Val_S.xml')/descendant::tei:div[@n = $div_n][@type = 'chapitre']/node()"
            mode="edition"/>
        <xsl:text>\endnumbering&#10;</xsl:text>
        <xsl:text>\end{Leftside}&#10;</xsl:text>
        <xsl:variable name="temoin_base_edition2" select="substring-after($temoin_base_edition, '_')"/>
        <xsl:text>\begin{Rightside}</xsl:text>
        <xsl:text>\beginnumbering</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>
        \endnumbering
        \end{Rightside}
        \end{pages}
        \Pages </xsl:text>
        <xsl:message>Fin chapitre <xsl:value-of select="@n"/></xsl:message>
    </xsl:template>

    <!--Foliation en exposant entre crochets -->
    <xsl:template match="tei:pb" mode="edition">
        <xsl:choose>
            <xsl:when test="ancestor::tei:TEI[@xml:id = 'Rome_W']">
                <xsl:text>\textsuperscript{[p. </xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>]}</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::tei:TEI[@xml:id = 'Val_S']">
                <xsl:text>\textsuperscript{[fol. </xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>]}</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::tei:quote[@xml:lang = 'lat']">
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
                            <xsl:value-of select="myfunctions:witstosigla($temoin_base_edition)"/>
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






    <!-- <xsl:template match="tei:app" mode="transposition">
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


    <xsl:template
        match="tei:cb[not(@corresp) and not(ancestor::tei:rdg[contains(@wit, $temoin_base_edition)])]"
        mode="edition">
        <xsl:text>\textsuperscript{[col. b]}</xsl:text>
    </xsl:template>
    <!--Foliation-->


    <xsl:template match="tei:quote[@type = 'secondaire'][ancestor::tei:note][not(@subtype = 'vers')]"
        mode="edition">
        <xsl:variable name="langue">
            <xsl:choose>
                <xsl:when test="@xml:lang = 'lat'">latin</xsl:when>
                <xsl:when test="@xml:lang = 'eng'">english</xsl:when>
                <xsl:when test="@xml:lang = 'spo' or @xml:lang = 'esp'">spanish</xsl:when>
                <xsl:otherwise>french</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$langue = 'french'">
                <xsl:choose>
                    <xsl:when test="string-length(string-join(descendant::text())) > 400">
                        <xsl:text>\begin{quote}</xsl:text>
                        <xsl:apply-templates mode="edition"/>
                        <xsl:text> \end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{</xsl:text>
                        <xsl:apply-templates mode="edition"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length(string-join(descendant::text())) > 400">
                        <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates mode="edition"/>
                        <xsl:text>}\end{otherlanguage}\end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates mode="edition"/>
                        <xsl:text>}\end{otherlanguage}}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template
        match="tei:quote[@type = 'secondaire'][not(ancestor::tei:note)][not(@subtype = 'vers')]"
        mode="edition">
        <xsl:variable name="langue">
            <xsl:choose>
                <xsl:when test="@xml:lang = 'lat'">latin</xsl:when>
                <xsl:when test="@xml:lang = 'eng'">english</xsl:when>
                <xsl:when test="@xml:lang = 'fra'">french</xsl:when>
                <xsl:when test="@xml:lang = 'spo' or @xml:lang = 'esp'">spanish</xsl:when>
                <xsl:otherwise>french</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$langue = 'french'">
                <xsl:choose>
                    <xsl:when test="string-length(.) &gt; 100">
                        <xsl:text>\begin{quote}</xsl:text>
                        <xsl:apply-templates mode="edition"/>
                        <xsl:text> \end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{</xsl:text>
                        <xsl:apply-templates mode="edition"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length(string-join(descendant::text())) &gt; 200">
                        <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates mode="edition"/>
                        <xsl:text>}\end{otherlanguage}\end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates mode="edition"/>
                        <xsl:text>}\end{otherlanguage}}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="tei:quote[@type = 'primaire'][parent::tei:note]" mode="edition">
        <xsl:variable name="langue">
            <xsl:choose>
                <xsl:when test="@xml:lang = 'lat'">latin</xsl:when>
                <xsl:when test="@xml:lang = 'eng'">english</xsl:when>
                <xsl:when test="@xml:lang = 'spo' or @xml:lang = 'esp'">spanish</xsl:when>
                <xsl:otherwise>french</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$langue != 'french'">
                <xsl:choose>
                    <xsl:when test="not(child::tei:l)">
                        <xsl:choose>
                            <xsl:when test="string-length(string-join(descendant::text())) &gt; 200">
                                <xsl:text>\begin{note_quote}\begin{otherlanguage}{</xsl:text>
                                <xsl:value-of select="$langue"/>
                                <xsl:text>}\textit{</xsl:text>
                                <xsl:apply-templates mode="edition"/>
                                <xsl:text>}\end{otherlanguage}\end{note_quote}</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>\enquote{\begin{otherlanguage}{</xsl:text>
                                <xsl:value-of select="$langue"/>
                                <xsl:text>}\textit{</xsl:text>
                                <xsl:apply-templates mode="edition"/>
                                <xsl:text>}\end{otherlanguage}}</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates mode="edition"/>
                        <xsl:text>}\end{otherlanguage}\end{quote}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="not(child::tei:l)">
                        <xsl:text>\enquote{</xsl:text>
                        <xsl:apply-templates mode="edition"/>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\begin{quote}</xsl:text>
                        <xsl:apply-templates mode="edition"/>
                        <xsl:text>\end{quote}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template match="tei:milestone" mode="edition apparat omission_simple citation_apparat">

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



    <xsl:template match="tei:hi[@rend = 'initiale']" mode="edition">
        <xsl:text>\lettrine[lines=3]{</xsl:text>
        <xsl:value-of select="upper-case(.)"/>
        <xsl:text>}</xsl:text>
    </xsl:template>


    <xsl:template match="tei:hi[@rend = 'non_initiale']" mode="edition">
        <xsl:text>\lettrine[lines=3]{\textcolor{white}{</xsl:text>
        <xsl:value-of select="upper-case(.)"/>
        <xsl:text>}}</xsl:text>
    </xsl:template>




    <xsl:template match="tei:hi[@rend = 'lettre_attente']" mode="edition"/>

    <xsl:template match="tei:hi[@rend = 'lettre_capitulaire']" mode="edition">
        <xsl:value-of select="lower-case(.)"/>
    </xsl:template>

    <!--    <xsl:template match="tei:app[contains(@ana, '#codico')][]"></xsl:template>-->

    <xsl:template
        match="tei:app[@ana = '#lexicale'][count(descendant::tei:rdg) = 1] | tei:ana[@type = '#morphosyntactique'][count(descendant::tei:rdg) = 1] | tei:app[@ana = '#indetermine'][count(descendant::tei:rdg) = 1]"
        mode="edition">
        <!--Essayer de trouver un moyen de faire apparaître les omissions clairement. Par exemple: dans un niveau de note spécifique.-->
        <!--On omet les omissions pour l'instant-->
        <xsl:text> </xsl:text>
        <xsl:apply-templates mode="edition"/>
    </xsl:template>

    <xsl:template
        match="tei:note[@type = 'variante'] | tei:note[@type = 'codico'][not(ancestor::tei:del)]"
        mode="edition apparat omission_simple"/>



    <!--<xsl:template match="tei:app[contains(@ana, 'codico')]" mode="edition" priority="2">
        Pas une bonne méthode. Passer par l'apparat textuel. 
        <xsl:next-match/>
        <xsl:if test="descendant::tei:pb">
            <xsl:text>\edtext{}{\Afootnote{</xsl:text>
            <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_edition)]"/>
            <xsl:choose>
                <xsl:when test="count(tei:rdgGrp) != 1">
                    <xsl:text>| </xsl:text>
                    <xsl:apply-templates select="ancestor::tei:rdg/tei:w" mode="edition"/>
                    <xsl:text> </xsl:text>
                </xsl:when>
            </xsl:choose>
            <xsl:text> \textit{</xsl:text>
            <xsl:value-of
                select="myfunctions:witstosigla(descendant::tei:rdg[descendant::tei:subst]/@wit)"/>
            <xsl:text>} </xsl:text>
            <xsl:text>\textit{del.} </xsl:text>
            <xsl:apply-templates select="descendant::tei:del"/>
            <xsl:text> \textit{et add.} </xsl:text>
            <xsl:apply-templates select="descendant::tei:add"/>
            <xsl:text>}}</xsl:text>
        </xsl:if>
    </xsl:template>
-->

    <xsl:template match="tei:subst" mode="#all">
        <xsl:apply-templates select="tei:add" mode="edition"/>
    </xsl:template>

    <xsl:template match="tei:app[descendant::tei:subst]" mode="edition" priority="2">
        <xsl:next-match/>
        <xsl:text> </xsl:text>
        <xsl:variable name="corresp" select="@corresp"/>
        <xsl:text>\edtext{}{\Afootnote{</xsl:text>
        <xsl:apply-templates
            select="descendant::tei:rdg[contains(@wit, $temoin_base_edition)]/descendant::tei:add"/>
        <xsl:choose>
            <xsl:when test="count(tei:rdgGrp) != 1">
                <xsl:text> | </xsl:text>
                <xsl:apply-templates select="ancestor::tei:rdg/tei:w" mode="edition"/>
                <xsl:text> </xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text> \textit{</xsl:text>
        <xsl:value-of select="myfunctions:witstosigla(descendant::tei:rdg[descendant::tei:subst]/@wit)"/>
        <xsl:text>} </xsl:text>
        <xsl:text>\textit{del.} </xsl:text>
        <xsl:apply-templates select="descendant::tei:del"/>
        <xsl:text> \textit{et add.} </xsl:text>
        <xsl:apply-templates select="descendant::tei:add"/>
        <xsl:text>. </xsl:text>
        <xsl:apply-templates select="descendant-or-self::tei:note"/>
        <xsl:text>}}</xsl:text>
    </xsl:template>


    <xsl:template
        match="tei:app[descendant::tei:note[@type = 'variante'] | descendant::tei:note[@type = 'codico'][not(ancestor::tei:subst)]]"
        priority="1" mode="edition">
<!--TODO: Les variantes dans un apparat d'omission ne sont PAS gérées-->
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

        <xsl:for-each
            select="descendant::tei:note[@type = 'codico' or @type = 'variante'][not(ancestor::tei:subst) or not(ancestor::tei:del)]">
            <xsl:text>\edtext{}{\lemma{</xsl:text>
            <xsl:value-of
                select="ancestor::tei:app/descendant::tei:rdg[contains(@wit, $temoin_base_edition)]/tei:w"/>
            <xsl:text>}\Afootnote{</xsl:text>
            <xsl:choose>
                <xsl:when test="
                        not(ancestor::tei:rdgGrp/descendant::tei:rdg[contains(@wit, $temoin_base_edition)])
                        and not(ancestor::tei:rdg[contains(@wit, $temoin_base_edition)])">
                    <xsl:text>| </xsl:text>
                    <xsl:apply-templates select="ancestor::tei:rdg/tei:w" mode="edition"/>
                    <xsl:text> </xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:text>[\textit{</xsl:text>
            <xsl:value-of select="myfunctions:witstosigla(@corresp)"/>
            <xsl:text>}]  </xsl:text>
            <xsl:apply-templates mode="edition"/>
            <xsl:text>}}</xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="tei:app[contains(@ana, '#not_apparat')]" mode="edition">
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_edition)]"
            mode="edition"/>
        <!--Il existe avec l'injection des non apparats qui contiennent tout de mêmes des différences matérielles (subst p.ex.)-->
        <!--<!-\-<xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_edition)][node()]]]">
            <xsl:text> </xsl:text>
        </xsl:if>-\->
        <xsl:text>% Pas d'apparat ici. </xsl:text>
        <xsl:value-of select="$temoin_base_edition"/>-->
        <!--<xsl:text>&#10;</xsl:text>-->
    </xsl:template>

    <!--<xsl:template match="tei:pc[not(@corresp)]" mode="edition citation_apparat apparat">
        <xsl:value-of select="."/>
        <xsl:text> </xsl:text>
        <xsl:text>% Mode </xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>-->

    <xsl:template match="tei:pc" mode="edition citation_apparat apparat">
        <xsl:value-of select="."/>
        <!--<xsl:text> </xsl:text>-->
        <!--
        <xsl:text>% Mode </xsl:text>
        <xsl:text>&#10;</xsl:text>-->
    </xsl:template>

    <!--    <xsl:template match="tei:pc[@corresp]" mode="edition citation_apparat apparat"/>-->

    <xsl:template match="tei:pc[@corresp]" mode="omission_simple">
        <!--Dans un cas d'omission on peut pouvoir insérer la ponctuation du témoin base pour rendre le texte plus lisible.-->
        <xsl:param name="temoin_base"/>
        <xsl:choose>
            <xsl:when test="translate(@corresp, '#', '') = $temoin_base">
                <xsl:value-of select="."/>
                <!--<xsl:text> </xsl:text>-->
                <!--                <xsl:text>&#10;</xsl:text>-->
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:w" mode="edition citation_apparat apparat omission_simple">
        <xsl:param name="temoin_base_edition"/>
        <xsl:variable name="temoin_base" select="myfunctions:base_witness(.)"/>
        <xsl:choose>
            <xsl:when test="contains(@ana, '#same_word')">
                <xsl:text>\sameword{</xsl:text>
                <xsl:apply-templates/>
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

    <xsl:template match="
            tei:app[@ana = '#filtre'][count(descendant::tei:rdg) > 1]
            | tei:app[@ana = '#genre'][count(descendant::tei:rdg) > 1]" mode="edition">
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_edition)]"
            mode="edition"/>
    </xsl:template>






    <!--Les apparats de type filtre sont à ignorer-->
    <xsl:template
        match="tei:app[@ana = '#normalisation'] | tei:app[@ana = '#graphique'] | tei:app[contains(@ana, '#transposition')] | tei:app[@ana = '#filtre'][count(descendant::tei:rdg) = 1] | tei:app[@ana = '#auxiliarite'] | tei:app[@ana = '#numerale']"
        mode="edition" priority="1">
        <xsl:variable name="temoin_base" select="myfunctions:base_witness(.)"/>
        <!--<xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base)][node()]]]">
            <xsl:text> </xsl:text>
        </xsl:if>-->
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base)]" mode="edition"/>
        <!--<xsl:text>% Témoin base: </xsl:text>
        <xsl:value-of select="$temoin_base_edition"/>
        <xsl:text> variante </xsl:text>
        <xsl:value-of select="@ana"/>-->
        <!--<xsl:text>&#10;</xsl:text>-->
    </xsl:template>

    <xsl:template match="tei:rdg[not(ancestor::tei:app[contains(@ana, 'transposition')])]" mode="edition">
        <xsl:param name="temoin_base_edition"/>
        <xsl:choose>
            <xsl:when test="descendant::tei:w">
                <xsl:apply-templates mode="apparat"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\textit{om.}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="tei:rdg[ancestor::tei:app[contains(@ana, 'transposition')]]" mode="edition">
        <xsl:param name="temoin_base_edition"/>
        <xsl:choose>
            <xsl:when test="descendant::tei:w">
                <xsl:apply-templates mode="apparat"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="tei:rdg" mode="ajout">
        <xsl:param name="temoin_base_edition"/>
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



    <xsl:template match="tei:witStart" mode="#all">
        <xsl:param name="temoin_base_edition"/>
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
                <xsl:variable name="wits"
                    select="lower-case(string-join(myfunctions:witstosigla(@corresp)))"/>
                <xsl:text>\textsuperscript{</xsl:text>
                <xsl:value-of select="$wits"/>
                <xsl:text>}</xsl:text>
                <xsl:text> </xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:variable name="previous" select="translate(@previous, '#', '')"/>
        <xsl:if test="preceding::tei:witEnd[contains(@xml:id, $previous)][@ana = '#homeoteleuton']">
            <xsl:text>\footnoteB{Saut du même au même ici pour </xsl:text>
            <xsl:value-of select="myfunctions:witstosigla(@corresp)"/>
            <xsl:text>.}</xsl:text>
        </xsl:if>
    </xsl:template>



    <xsl:template match="tei:witEnd" mode="#all">
        <xsl:param name="temoin_base_edition"/>
        <xsl:variable name="div_n" select="ancestor::tei:div[@type = 'chapitre']/@n"/>
        <xsl:message>
            <xsl:value-of select="$div_n"/>
        </xsl:message>
        <xsl:variable name="temoin_base" select="myfunctions:base_witness(.)"/>
        <xsl:choose>
            <!--Quand le témoin de base n'est pas concerné, c'est le cas le plus simple: on n'a qu'à indiquer par une lettre en exposant
            le ou les témoins où le texte s'arrête.-->
            <xsl:when test="not(contains(@corresp, $temoin_base))">
                <xsl:variable name="wits" select="myfunctions:witstosigla(@corresp)"/>
                <xsl:text>\textsuperscript{</xsl:text>
                <xsl:value-of select="$wits"/>
                <xsl:text>}</xsl:text>
                <xsl:text> </xsl:text>
            </xsl:when>

            <!--Dans le cas contraire, ça se complique: il faut aller indiquer qu'à un point précis il y a un bout de texte que
            le témoin base ne propose pas. On va donc devoir travailler sur du contexte à gauche pour produire un apparat compréhensible-->
            <xsl:otherwise>
                <xsl:variable name="wits" select="@corresp"/>
                <xsl:choose>
                    <!--Omission simple-->
                    <xsl:when test="following::tei:witStart[1][@corresp = $wits]">
                        <xsl:variable name="following_witstart_id"
                            select="following::tei:witStart[1]/@xml:id"/>
                        <xsl:variable name="next_node_div_n"
                            select="following::tei:witStart[@xml:id = $following_witstart_id]/ancestor::tei:div[@type = 'chapitre']/@n"/>
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
                                        select="preceding-sibling::node()[self::tei:app][descendant::tei:rdg[contains(@wit, $temoin_base)][node()]][1]/descendant::tei:rdg[contains(@wit, $temoin_base)]/tei:w"
                                        mode="apparat"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates
                                        select="preceding-sibling::node()[self::tei:w][1]" mode="apparat"
                                    />
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
                        <xsl:text>\edtext{}{\lemma{</xsl:text>
                        <xsl:value-of select="$preceding_omitted_lemma"/>
                        <xsl:text>}\Afootnote{\textit{</xsl:text>
                        <xsl:value-of select="$preceding_omitted_witnesses"/>
                        <xsl:text>} | </xsl:text>
                        <xsl:if test="@ana = '#homeoteleuton'">
                            <xsl:text> Saut du même au même pour le témoin base: </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$preceding_omitted_lemma"/>
                        <xsl:text> </xsl:text>
                        <xsl:apply-templates select="$corresponding_nodes" mode="omission_simple">
                            <xsl:with-param name="temoin_base">
                                <!--Il faut choisir un autre témoin base. On prend le premier-->
                                <!--https://stackoverflow.com/a/25405132-->
                                <xsl:value-of
                                    select="replace(following::tei:app[1]/descendant::tei:rdg[descendant::tei:w][1]/@wit, '^.*#', '')"
                                />
                            </xsl:with-param>
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

    <xsl:template match="tei:date" mode="#all">
        <xsl:text>\textsc{</xsl:text>
        <xsl:value-of select="text()"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="tei:hi[@rend = 'exposant']">
            <xsl:text>\textsuperscript{</xsl:text>
            <xsl:value-of select="tei:hi[@rend = 'exposant']"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template
        match="tei:app[not(contains(@ana, 'lexicale')) and not(contains(@ana, 'morphosyntactique'))]"
        mode="omission_simple">
        <xsl:param name="temoin_base"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base)]"
            mode="omission_simple">
            <xsl:with-param name="temoin_base" select="$temoin_base"/>
        </xsl:apply-templates>
        <!--<xsl:text>% Mode omission simple - variante </xsl:text>
        <xsl:value-of select="@ana"/>
        <xsl:text> Témoin base </xsl:text>
        <xsl:value-of select="$temoin_base"/>
        <xsl:text>&#10;</xsl:text>-->
    </xsl:template>

    <xsl:template match="tei:subst" mode="omission_simple" priority="2">
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


    <xsl:template match="tei:app[contains(@ana, 'lexicale') or contains(@ana, 'morphosyntactique')]"
        mode="omission_simple">
        <xsl:param name="temoin_base"/>
        <xsl:text> [</xsl:text>
        <xsl:for-each select="descendant::tei:rdgGrp">
            <xsl:variable name="grouped_sigla">
                <xsl:for-each select="descendant::tei:rdg">
                    <xsl:value-of select="myfunctions:witstosigla(@wit)"/>
                    <xsl:if test="following-sibling::tei:rdg">
                        <xsl:text>`</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <!--On prend le premier.-->
            <xsl:apply-templates select="descendant::tei:rdg[1]" mode="omission_simple">
                <xsl:with-param name="temoin_base" select="$temoin_base"/>
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
    <xsl:template
        match="tei:app[not(contains(string-join(descendant-or-self::tei:rdg/@wit), $temoin_base_edition))]"
        priority="3" mode="edition"/>
    <!--On va ignorer tous les éléments qui ne sont pas dans le texte.-->


    <xsl:template match="tei:app[contains(@ana, '#omission')][not(contains(@ana, '#transposition'))]"
        mode="edition">
        <xsl:variable name="witnesses" select="descendant::tei:rdg[not(node())]/@wit"/>
        <xsl:text> </xsl:text>
        <xsl:choose>
            <!--Si le témoin omis est le témoin base, il faut aller chercher du contexte-->
            <!--TODO: affiner la fonction pour aller chercher du contexte cohérent et ne pas mélanger les témoins.-->
            <xsl:when test="contains($witnesses, $temoin_base_edition)">
                <!--TODO <xsl:variable name="omitted_wit_sigla">
                    <xsl:value-of select="myfunctions:witstosigla(descendant::tei:rdg[not(descendant::tei:w)]/@wit)"/>
                </xsl:variable>
                <xsl:variable name="preceding_non_omitted_wits">
                    <xsl:choose>
                        <xsl:when
                            test="preceding-sibling::node()[self::tei:app[descendant::tei:rdg[not(contains(@wit, $temoin_base_edition))][node()]] | self::tei:w][1]/name() = 'app'">
                            <xsl:apply-templates
                                select="preceding-sibling::node()[self::tei:app][descendant::tei:rdg[not(contains(@wit, $temoin_base_edition))][node()]][1]/descendant::tei:rdg[contains(@wit, $temoin_base_edition)]/tei:w"
                                mode="apparat"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="preceding-sibling::node()[self::tei:w][1]"
                                mode="apparat"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>-->

                <!--Il faut reprendre le code ici, ça ne marche pas tout le temps.-->
                <xsl:variable name="preceding_omitted_lemma">
                    <xsl:choose>
                        <xsl:when
                            test="preceding-sibling::node()[self::tei:app[descendant::tei:rdg[not(contains(@wit, $temoin_base_edition))][node()]] | self::tei:w][1]/name() = 'app'">
                            <xsl:apply-templates
                                select="preceding-sibling::node()[self::tei:app][descendant::tei:rdg[contains(@wit, $temoin_base_edition)][node()]][1]/descendant::tei:rdg[contains(@wit, $temoin_base_edition)]/tei:w"
                                mode="apparat"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="preceding-sibling::node()[self::tei:w][1]"
                                mode="apparat"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="omm_wits"
                    select="myfunctions:witstosigla(descendant::tei:rdg[contains(@wit, $temoin_base_edition)]/@wit)"/>
                <xsl:text>\edtext{</xsl:text>
                <xsl:text>}{</xsl:text>
                <xsl:text>\Bfootnote{</xsl:text>
                <xsl:value-of select="myfunctions:debug('[OM1]')"/>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text> \textit{</xsl:text>
                <xsl:value-of select="$omm_wits"/>
                <xsl:text>} | </xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text> </xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(@ana, '#graphique')">
                        <xsl:value-of select="myfunctions:debug('[GRAPH]')"/>
                        <xsl:text> </xsl:text>
                        <xsl:apply-templates
                            select="descendant::tei:rdg[not(contains(@wit, $temoin_base_edition))][1]"/>
                        <xsl:text> \textit{</xsl:text>
                        <xsl:variable name="grouped_sigla">
                            <xsl:for-each
                                select="descendant::tei:rdgGrp[descendant::tei:rdg[not(contains(@wit, $temoin_base_edition))]]">
                                <xsl:for-each select="descendant::tei:rdg">
                                    <xsl:value-of select="myfunctions:witstosigla(@wit)"/>
                                    <xsl:if test="following-sibling::tei:rdg">
                                        <xsl:text>`</xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:value-of select="$grouped_sigla"/>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(@ana, '#lexicale')">
                        <xsl:value-of select="myfunctions:debug('[LEX]')"/>
                        <xsl:variable name="grouped_sigla">
                            <xsl:for-each
                                select="descendant::tei:rdgGrp[descendant::tei:rdg[not(contains(@wit, $temoin_base_edition))]]">
                                <xsl:value-of select="$preceding_omitted_lemma"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates
                                    select="descendant::tei:rdg[not(contains(@wit, $temoin_base_edition))][1]"/>
                                <xsl:text> \textit{</xsl:text>
                                <xsl:for-each select="descendant::tei:rdg">
                                    <xsl:value-of select="myfunctions:witstosigla(@wit)"/>
                                    <xsl:if test="following-sibling::tei:rdg">
                                        <xsl:text>`</xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                                <xsl:text>}</xsl:text>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:value-of select="$grouped_sigla"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates
                            select="descendant::tei:rdg[not(contains(@wit, $temoin_base_edition))][1]"/>
                        <xsl:variable name="non_omm_wits"
                            select="myfunctions:witstosigla(descendant::tei:rdg[not(contains(@wit, $temoin_base_edition))]/@wit)"/>
                        <xsl:text> \textit{</xsl:text>
                        <xsl:value-of select="$non_omm_wits"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>}}</xsl:text>
            </xsl:when>
            <!--Si le témoin omis est le témoin base-->
            <!--Sinon, un peu plus simple-->
            <xsl:otherwise>
                <xsl:text>\edtext{</xsl:text>
                <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_edition)]"
                    mode="apparat"/>
                <xsl:text>}{\lemma{</xsl:text>
                <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_edition)]"
                    mode="apparat"/>
                <xsl:text>}</xsl:text>
                <xsl:text> \Bfootnote{</xsl:text>
                <!--Ici il faut ajouter un omm. dans l'apparat sans que ça se voie dans le corps du texte.-->
                <xsl:value-of select="myfunctions:debug('[OM2] ')"/>
                <xsl:text>\textit{</xsl:text>
                <!--Pour chaque témoin, ne faire apparaître que la lettre correspondante-->
                <xsl:choose>
                    <!--S'il y a un rdgGrp (= si d'autres leçons sont identiques modulo variation graphique à la leçon base)-->
                    <xsl:when
                        test="boolean(descendant::tei:rdgGrp[descendant::tei:rdg[contains(@wit, $temoin_base_edition)]])">
                        <xsl:variable name="lemma_wits"
                            select="myfunctions:witstosigla(descendant::tei:rdg[contains(@wit, $temoin_base_edition)]/@wit)"/>
                        <xsl:variable name="siblings">
                            <xsl:value-of select="
                                    myfunctions:witstosigla(descendant::tei:rdg[contains(@wit, $temoin_base_edition)]/following-sibling::tei:rdg/@wit |
                                    descendant::tei:rdg[contains(@wit, $temoin_base_edition)]/preceding-sibling::tei:rdg/@wit)"
                            />
                        </xsl:variable>
                        <!--Il y a parfois des rdgGrp qui ne contiennent qu'un tei:rdg: dans ce cas, n'imprimer que la valeur du témoin base-->
                        <xsl:choose>
                            <xsl:when
                                test="boolean(count(descendant::tei:rdgGrp[descendant::tei:rdg[contains(@wit, $temoin_base_edition)]]/descendant::tei:rdg) > 1)">

                                <xsl:value-of select="concat(string-join($lemma_wits), '`', $siblings)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$lemma_wits"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!--Il y a parfois des rdgGrp qui ne contiennent qu'un tei:rdg: dans ce cas, n'imprimer que la valeur du témoin base-->
                    </xsl:when>
                    <!--S'il y a un rdgGrp (= si d'autres leçons sont identiques modulo variation graphique à la leçon base)-->
                    <xsl:otherwise>
                        <xsl:value-of
                            select="myfunctions:witstosigla(tei:rdg[contains(@wit, $temoin_base_edition)]/@wit)"
                        />
                    </xsl:otherwise>
                </xsl:choose>
                <!--Pour chaque témoin, ne faire apparaître que la lettre correspondante-->
                <xsl:text>}\,|\,</xsl:text>
                <!--La même chose mais en utilisant une autre méthode-->
                <xsl:choose>
                    <xsl:when test="descendant::tei:rdgGrp">
                        <xsl:for-each
                            select="descendant::tei:rdgGrp[count(descendant::tei:rdg[contains(@wit, $temoin_base_edition)]) = 0]">
                            <!--L'idée ici est de raffiner les apparats pour rassembler les variantes graphiques entre elles-->
                            <xsl:for-each select="descendant::tei:rdg">
                                <xsl:variable name="sigle_temoin" select="myfunctions:witstosigla(@wit)"/>
                                <xsl:choose>
                                    <xsl:when test="descendant::text()">
                                        <xsl:if test="not(preceding-sibling::tei:rdg)">
                                            <xsl:apply-templates select="."/>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>\textit{om.}</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>\,\textit{</xsl:text>
                                <xsl:value-of select="$sigle_temoin"/>
                                <!--<xsl:if
                            test="not(count(ancestor::tei:rdgGrp/descendant::tei:rdg) = 1) and not(following-sibling::tei:rdg)">
                            <xsl:text>~c.v.</xsl:text>
                            </xsl:if>-->
                                <xsl:text>}\,</xsl:text>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="tei:rdg[not(contains(@wit, $temoin_base_edition))]">
                            <xsl:variable name="sigle_temoin" select="myfunctions:witstosigla(@wit)"/>
                            <xsl:choose>
                                <xsl:when test="descendant::text()">
                                    <xsl:apply-templates select="." mode="edition"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>\textit{om.}</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>\,\textit{</xsl:text>
                            <xsl:value-of select="$sigle_temoin"/>
                            <xsl:text>}\,</xsl:text>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>}}</xsl:text>
            </xsl:otherwise>
            <!--Sinon, un peu plus simple-->
        </xsl:choose>
        <!--<xsl:if
            test="following::node()[1][self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_edition)][node()]]]">
            <xsl:text> %&#10;</xsl:text>
        </xsl:if>-->
    </xsl:template>


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

    <xsl:template match="element()" priority="5" mode="edition">
        <xsl:message>Matching <xsl:value-of select="name(self::element())"/></xsl:message>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template match="tei:anchor[@type = 'ligne']" mode="edition">
        <!--https://tex.stackexchange.com/a/321814-->
        <xsl:text>\edlabel{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
    </xsl:template>


    <xsl:template match="tei:anchor[@type = 'reference']" mode="edition">
        <xsl:text>\phantomsection\label{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
    </xsl:template>




    <xsl:template match="tei:app" mode="omission_complexe">
        <xsl:variable name="omitted_wit" select="ancestor-or-self::tei:seg/@exclude"/>
        <xsl:choose>
            <xsl:when
                test="count(descendant::tei:rdg) != 2 and count(descendant::tei:rdgGrp[descendant::tei:rdg[node()]]) > 1">
                <xsl:text> [</xsl:text>
                <xsl:choose>
                    <xsl:when
                        test="descendant::tei:rdgGrp and count(descendant::tei:rdgGrp[descendant::tei:rdg[node()]]) > 1">
                        <xsl:for-each
                            select="descendant::tei:rdgGrp[descendant::tei:rdg[node()]]/tei:rdg[1]">
                            <xsl:variable name="sigla">
                                <xsl:for-each
                                    select="tokenize(string-join(ancestor::tei:rdgGrp/descendant::tei:rdg/@wit, ' '), '\s')">
                                    <xsl:value-of select="substring-after(., '_')"/>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:apply-templates mode="apparat"/>
                            <xsl:text> \textit{</xsl:text>
                            <xsl:value-of select="$sigla"/>
                            <xsl:text>}</xsl:text>
                            <xsl:if
                                test="parent::tei:rdgGrp/following-sibling::tei:rdgGrp[descendant::tei:rdg[node()]]">
                                <xsl:text> | </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <!--Parfois il y a une omission au sein de l'omission-->
                        <xsl:if test="descendant::tei:rdg[not(node())][@wit != $omitted_wit]">
                            <xsl:text> | \textit{om.} </xsl:text>
                            <xsl:value-of
                                select="myfunctions:witstosigla(descendant::tei:rdg[not(node())]/@wit)"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates
                            select="descendant::tei:rdgGrp[descendant::tei:rdg[node()]]/tei:rdg[1]"
                            mode="apparat"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>]</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <!--S'il y a deux enfants directs tei:rdg, logiquement, tous les témoins concordent face au témoin qui omet-->
                <xsl:choose>
                    <xsl:when test="descendant::tei:rdg[not(node())][@wit != $omitted_wit]">
                        <xsl:text> [</xsl:text>
                        <xsl:apply-templates select="descendant::tei:rdg[node()][1]"/>
                        <xsl:text> | \textit{om.} </xsl:text>
                        <xsl:for-each
                            select="tokenize(replace(string-join(descendant::tei:rdg[not(node())]/@wit), $omitted_wit, ''), '\s')">
                            <xsl:value-of select="substring-after(., '_')"/>
                        </xsl:for-each>
                        <xsl:text>]</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="descendant::tei:rdg[node()][1]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:lb" mode="omission_complexe edition"/>





    <!--Règle principale sur les apparats-->
    <xsl:template match="
            tei:app[@ana = '#entite_nommee'][count(descendant::tei:rdg) > 1]
            | tei:app[@ana = '#lexicale'][count(descendant::tei:rdg) > 1]
            | tei:app[@ana = '#morphosyntactique'][count(descendant::tei:rdg) > 1]
            | tei:app[@ana = '#indetermine'][count(descendant::tei:rdg) > 1]
            | tei:app[@ana = '#personne'][count(descendant::tei:rdg) > 1]
            " mode="edition">
        <xsl:text> </xsl:text>
        <xsl:variable name="temoin_base_edition2" select="substring-after($temoin_base_edition, '_')"/>
        <xsl:text>\edtext{</xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_base_edition)]"
            mode="apparat"/>
        <xsl:text>}{\Bfootnote{</xsl:text>
        <!-- test: UNCLEAR entre crochets avec un ?-->
        <!--Ici il faut ajouter un omm. dans l'apparat sans que ça se voie dans le corps du texte.-->
        <!--Pour chaque témoin, ne faire apparaître que la lettre correspondante-->
        <xsl:choose>
            <!--S'il y a un rdgGrp (= si d'autres leçons sont identiques modulo variation graphique à la leçon base)-->
            <xsl:when
                test="boolean(descendant::tei:rdgGrp[descendant::tei:rdg[contains(@wit, $temoin_base_edition)]])">
                <xsl:variable name="lemma_wits"
                    select="myfunctions:witstosigla(descendant::tei:rdg[contains(@wit, $temoin_base_edition)]/@wit)"/>
                <xsl:variable name="siblings">
                    <xsl:value-of
                        select="myfunctions:witstosigla(descendant::tei:rdg[contains(@wit, $temoin_base_edition)]/following-sibling::tei:rdg)"/>
                    <xsl:value-of
                        select="myfunctions:witstosigla(descendant::tei:rdg[contains(@wit, $temoin_base_edition)]/preceding-sibling::tei:rdg)"
                    />
                </xsl:variable>

                <!--Il y a parfois des rdgGrp qui ne contiennent qu'un tei:rdg: dans ce cas, n'imprimer que la valeur du témoin base-->
                <xsl:choose>
                    <xsl:when
                        test="boolean(count(descendant::tei:rdgGrp[descendant::tei:rdg[contains(@wit, $temoin_base_edition)]]/descendant::tei:rdg) > 1)">
                        <xsl:variable name="grouped_sigla">
                            <xsl:for-each
                                select="descendant::tei:rdgGrp[descendant::tei:rdg[contains(@wit, $temoin_base_edition)]]">
                                <xsl:choose>
                                    <xsl:when test="child::tei:rdg[node()]">
                                        <xsl:text> \textit{</xsl:text>
                                        <xsl:for-each select="descendant::tei:rdg">
                                            <xsl:value-of select="myfunctions:witstosigla(@wit)"/>
                                            <xsl:if test="following-sibling::tei:rdg">
                                                <xsl:text>`</xsl:text>
                                            </xsl:if>
                                        </xsl:for-each>
                                        <xsl:text>}\,</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>\textit{om.}</xsl:text>
                                        <xsl:text>\,\textit{</xsl:text>
                                        <xsl:value-of select="myfunctions:witstosigla(tei:rdg/@wit)"/>
                                        <xsl:text>}</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:value-of select="$grouped_sigla"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$lemma_wits"/>
                    </xsl:otherwise>
                </xsl:choose>
                <!--Il y a parfois des rdgGrp qui ne contiennent qu'un tei:rdg: dans ce cas, n'imprimer que la valeur du témoin base-->
            </xsl:when>
            <!--S'il y a un rdgGrp (= si d'autres leçons sont identiques modulo variation graphique à la leçon base)-->
            <xsl:otherwise>
                <xsl:value-of
                    select="myfunctions:witstosigla(tei:rdg[contains(@wit, $temoin_base_edition)]/@wit)"
                />
            </xsl:otherwise>
        </xsl:choose>
        <!--Pour chaque témoin, ne faire apparaître que la lettre correspondante-->
        <xsl:text>\,|\,</xsl:text>
        <!--La même chose mais en utilisant une autre méthode-->
        <xsl:choose>
            <xsl:when test="descendant::tei:rdgGrp">
                <xsl:variable name="grouped_sigla">
                    <xsl:for-each
                        select="descendant::tei:rdgGrp[count(descendant::tei:rdg[contains(@wit, $temoin_base_edition)]) = 0]">
                        <xsl:choose>
                            <xsl:when test="child::tei:rdg[node()]">
                                <xsl:value-of select="myfunctions:debug('[rdg1]')"/>
                                <xsl:apply-templates select="descendant::tei:rdg[1]" mode="apparat"/>
                                <xsl:text> \textit{</xsl:text>
                                <xsl:for-each select="descendant::tei:rdg">
                                    <xsl:value-of select="myfunctions:witstosigla(@wit)"/>
                                    <xsl:if test="following-sibling::tei:rdg">
                                        <xsl:text>`</xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                                <xsl:text>} </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>\textit{om.}</xsl:text>
                                <xsl:text>\,\textit{</xsl:text>
                                <xsl:value-of select="myfunctions:witstosigla(tei:rdg/@wit)"/>
                                <xsl:text>}</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="$grouped_sigla"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="tei:rdg[not(contains(@wit, $temoin_base_edition))]">
                    <xsl:choose>
                        <xsl:when test="descendant::text()">
                            <xsl:apply-templates select="." mode="apparat"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>\textit{om.}</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>\,\textit{</xsl:text>
                    <xsl:value-of select="myfunctions:witstosigla(@wit)"/>
                    <xsl:text>}\,</xsl:text>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
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
        <xsl:message>Found you</xsl:message>
        <xsl:text>\par \label{</xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>}</xsl:text>
        <xsl:apply-templates mode="edition"/>
    </xsl:template>



    <xsl:template match="tei:head" mode="titre_edition">
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
        <xsl:variable name="div_n" select="ancestor::tei:div[@type = 'chapitre']/@n"/>
        <xsl:choose>
            <xsl:when test="not(preceding::tei:p[ancestor::tei:div[@type = 'chapitre'][@n = $div_n]])">
                <xsl:text>\pstart </xsl:text>
                <xsl:text>\phantomsection\label{</xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>}</xsl:text>
                <xsl:apply-templates select="ancestor::tei:div[@type = 'chapitre']/tei:head"
                    mode="titre_edition"/>
                <xsl:text>\pend </xsl:text>
                <xsl:text>\pstart \vspace{1cm}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\pstart </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>\phantomsection\label{</xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>}</xsl:text>
        <xsl:choose>
            <xsl:when
                test="not(preceding-sibling::tei:p) and not(ancestor::tei:TEI[@subtype = 'version_a'])">
                <xsl:text> {\ledrightnote{\hspace{.6cm}\textbf{[Trad.]}}}</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>\pend </xsl:text>
    </xsl:template>

    <xsl:variable name="corresponding_xml_document"
        select="document(concat('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan/', $temoin_base_edition, '.xml'))"/>


    <xsl:template match="tei:p[parent::tei:div[@type = 'glose']]" mode="edition">
        <!--Passer à un test sur le document non tokénisé, c'est trop long ici.-->
        <xsl:variable name="p_n" select="@n"/>
        <xsl:variable name="div_n" select="ancestor::tei:div[@type = 'chapitre']/@n"/>
        <xsl:choose>
            <xsl:when test="$corresponding_xml_document/descendant::tei:p[@n = $p_n][node()]">
                <xsl:message>Found you</xsl:message>
                <xsl:text>~\\\phantomsection\label{</xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>}</xsl:text>
                <xsl:choose>
                    <xsl:when
                        test="not(preceding::tei:p[ancestor::tei:div[@type = 'chapitre'][@n = $div_n]])">
                        <xsl:apply-templates select="ancestor::tei:div[@type = 'chapitre']/tei:head"
                            mode="titre_edition"/>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when
                        test="not(preceding-sibling::tei:p) and not(ancestor::tei:TEI[@subtype = 'version_a'])">
                        <xsl:text>\pagestyle{edition_glose}</xsl:text>
                        <xsl:text>{\ledrightnote{\hspace{.6cm}\textbf{[Glose]}}}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
                <xsl:apply-templates mode="edition"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!--TODO: idée pour les omissions. Pour chaque début d'omission. aller chercher tous les witEnd qui ne suivent pas un witEnd; aller jusqu'au prochain witStart 
    appliquer toutes les règles. Puis on va chercher le suivant, et on applique les règles dans la même note, en indiquant: tel témoin continue l'omission; etc etc-->


    <xsl:template match="tei:div[@type = 'glose']" mode="edition">
        <xsl:text>\pstart </xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>\pend </xsl:text>
    </xsl:template>


    <xsl:template match="tei:div[@type = 'traduction']" mode="edition">
        <xsl:apply-templates mode="edition"/>
    </xsl:template>

    <xsl:template match="tei:fw" mode="edition"/>


    <xsl:template match="text()" mode="edition">
        <xsl:variable name="remplacement1" select="replace(., '&amp;', '\\&amp;')"/>
        <xsl:value-of select="$remplacement1"/>
    </xsl:template>


</xsl:stylesheet>
