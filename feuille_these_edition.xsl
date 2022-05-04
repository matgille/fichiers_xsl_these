<?xml version="1.0" encoding="UTF-8"?>

<!-- IDEE: Gérer les modifications textuelles: Et si je faisais ma transformation en deux temps? D'abord, toutes les grosses transformations EN GARDANT UNE STRUCTURE XML BASIQUE
    et bien formée (une déclaration d'entité, etc) Sur cette transformation, en faire une seconde qui va supprimer tout ce qui est xml et garder que le texte ET qui 
pourra modifier les espaces simplement (translate ou un autre truc) ainsi qu'adapter les détails à LaTeX, comme les - - qui donne un tiret correct, ou transformer tous les e en &, etc-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:chezmoi="https://www.matthiasgillelevenson.fr/ns/1.0"
    xmlns:tex="placeholder.uri" exclude-result-prefixes="tex">

    <!--Cette feuille est adaptée à mon propre document XML-->
    <!--Merci à Arianne Pinche pour son aide précieuse dans cette feuille-->
    <!--Merci à Marjorie Burghart de m'avoir envoyé sa feuille de transformation qui m'a bien aidé-->
    <xsl:output method="text" omit-xml-declaration="no" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="fusion"/>

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



    <xsl:template
        match="tei:note[@subtype = 'lexicale'] | tei:note[@type = 'particulier'] | tei:note[@type = 'general'] | tei:note[@type = 'sources']"
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
        <xsl:choose>
            <xsl:when test="@corresp">
                <xsl:variable name="corresponding_witness" select="@corresp"/>
                <xsl:if test="@type">
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="translate(@corresp, '_#', ' ')"/>
                    <xsl:text>] </xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <!--Debug pour retrouver plus facilement les notes dans le xml-->
                <xsl:text>[Témoin </xsl:text>
                <xsl:value-of select="replace(ancestor::tei:TEI/@xml:id, '_', ' ')"/>
                <xsl:text>]</xsl:text>
                <!--Debug pour retrouver plus facilement les notes dans le xml-->
            </xsl:otherwise>
        </xsl:choose>
        <!--On va chercher dans le fichier source pour ne pas avoir à tout calculer lorsqu'on change une note de bas de page-->
        <xsl:variable name="xml_id" select="@xml:id"/>
        <xsl:variable name="division" select="ancestor::tei:div[not(ancestor::tei:div)]/@n"/>
        <xsl:variable name="corresponding_wit">
            <xsl:choose>
                <xsl:when test="@injected">
                    <xsl:value-of select="translate(@corresp, '#', '')"/>
                </xsl:when>
                <xsl:when test="ancestor::node()[@injected]">
                    <xsl:value-of select="translate(ancestor::node()[@injected]/@corresp, '#', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$temoin_courant"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates
            select="collection('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan?select=*.xml')/descendant::tei:TEI[@xml:id = $corresponding_wit]/descendant::tei:div[@n = $division]/descendant::tei:note[@xml:id = $xml_id]/node()"
            mode="edition"/>
        <!--On fait ça pour ne pas avoir à tout refaire lorsqu'on change une note de bas de page-->
        <xsl:text>
            }</xsl:text>
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

    <xsl:template match="tei:sic[not(@ana = '#omission')]" mode="edition">
        <xsl:apply-templates mode="edition"/>
        <xsl:text>\textsuperscript{\textit{[sic]}}</xsl:text>
    </xsl:template>



    <!--TODO: Ajouter toutes les images en annexe-->
    <xsl:template match="tei:graphic[parent::tei:note]" mode="edition">
        <xsl:text>figure \ref{</xsl:text>
        <xsl:value-of select="@url"/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <!--TODO: Ajouter toutes les images en annexe-->



    <xsl:template match="tei:sic[@ana = '#omission']" mode="edition">
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
    </xsl:template>



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

    <xsl:template match="tei:teiHeader" mode="edition_texte_latin"/>

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
    <xsl:template match="tei:add[not(parent::tei:head)]" mode="edition">
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
            <!--Si le add est inclus dans un apparat-->
            <xsl:if test="ancestor::tei:app">
                <!--Si l'apparat n'est pas un apparat principal mais un apparat de point notables (notable)
                    >> note. On peut accepter la note de bas de page (éviter les notes de bas de page dans un apparat
                    critique...)-->
                <!--Si l'apparat n'est pas un apparat principal mais un apparat de point notables (notable)-->

                <xsl:text>\textit{</xsl:text>
                <xsl:apply-templates mode="edition"/>
                <xsl:text>}</xsl:text>


            </xsl:if>
            <!--Si le add est inclus dans un apparat-->
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
                    <xsl:value-of select="translate(@hand, '#', '')"/>
                    <xsl:text>. </xsl:text>
                </xsl:if>
                <xsl:if test="./tei:note">
                    <xsl:apply-templates select="tei:note" mode="edition"/>
                </xsl:if>
                <xsl:if test="not(@note)"/>
                <xsl:text>}</xsl:text>
            </xsl:if>
        </xsl:if>
        <!--etc-->



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
                    <xsl:otherwise>
                        <xsl:text>\nameref{</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="$target"/>
                <xsl:text>}, page \pageref{</xsl:text>
                <xsl:value-of select="$target"/>
                <xsl:text>}</xsl:text>
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
        <xsl:text>&lt;</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>&gt;</xsl:text>
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

    <xsl:template match="tei:unclear" name="unclear" mode="edition">
        <xsl:apply-templates mode="edition"/>
        <xsl:text>~(?)</xsl:text>
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
    <xsl:template match="tei:del" mode="edition">
        <xsl:variable name="witness">
            <xsl:choose>
                <xsl:when test="@corresp">
                    <xsl:value-of select="chezmoi:witstosigla(@corresp)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="chezmoi:witstosigla($temoin_courant)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text> [[</xsl:text>
        <xsl:value-of select="$witness"/>
        <xsl:text>: </xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>]]</xsl:text>
    </xsl:template>
    <!-- ignorer le text entre balises <del>-->

    <!--Ici on va créer des règles pour afficher les éléments dans les apparats-->



    <!--Ici on va créer des règles pour afficher les éléments dans les apparats-->




    <xsl:template match="tei:div[@type = 'chapitre'][not(@type = 'glose' or @type = 'traduction')]"
        mode="edition">
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
        <xsl:variable name="temoin_courant2" select="substring-after($temoin_courant, '_')"/>
        <xsl:text>\begin{Rightside}</xsl:text>
        <xsl:text>\beginnumbering</xsl:text>
        <xsl:apply-templates mode="edition"/>
        <xsl:text>
        \endnumbering
        \end{Rightside}
        \end{pages}
        \Pages </xsl:text>
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
                            <xsl:value-of select="chezmoi:witstosigla(@corresp)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="chezmoi:witstosigla($temoin_courant)"/>
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




    <!--On ignore les transposition simples: on va imprimer le texte du témoin courant-->
    <xsl:template match="tei:seg[@ana = '#transposition']" mode="edition">
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_courant)]/tei:w"
            mode="edition"/>
    </xsl:template>
    <!--On ignore les transposition simples: on va imprimer le texte du témoin courant-->


    <xsl:template match="tei:cb" mode="edition">
        <xsl:text>\textit{[col. b]}</xsl:text>
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



    <xsl:template match="tei:milestone" mode="edition">

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

    <xsl:template
        match="tei:app[@ana = '#lexicale'][count(descendant::tei:rdg) = 1] | tei:ana[@type = '#morphosyntactique'][count(descendant::tei:rdg) = 1] | tei:app[@ana = '#indetermine'][count(descendant::tei:rdg) = 1]"
        mode="edition">
        <!--Essayer de trouver un moyen de faire apparaître les omissions clairement. Par exemple: dans un niveau de note spécifique.-->
        <!--On omet les omissions pour l'instant-->
        <xsl:apply-templates mode="apparat"/>
    </xsl:template>


    <xsl:template match="tei:app[@ana = '#not_apparat']" mode="edition">
        <xsl:apply-templates mode="edition"/>
    </xsl:template>

    <xsl:template match="
            tei:app[@ana = '#filtre'][count(descendant::tei:rdg) > 1]
            | tei:app[@ana = '#genre'][count(descendant::tei:rdg) > 1]" mode="edition">
        <xsl:apply-templates
            select="descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]"
            mode="apparat"/>
    </xsl:template>



    <!--
    <xsl:template match="tei:seg[@ana = $omission_binaire]" mode="edition">
        <!-\-On rappelle que @exclude indique les témoins qui sont lacunaires-\->
        <!-\-Et que @corresp correspond aux témoins qui partagent le texte de la lacune-\->
        <xsl:choose>
            <xsl:when test="@corresp = concat('#', $temoin_courant)">
                <xsl:text>\edtext{</xsl:text>
                <xsl:apply-templates
                    select="descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]"/>
                <xsl:text>}{\lemma{</xsl:text>
                <xsl:apply-templates
                    select="descendant::tei:app[1]/descendant::tei:rdg[translate(@wit, '#', '') = $temoin_courant]"/>
                <xsl:apply-templates
                    select="descendant::tei:app[2]/descendant::tei:rdg[translate(@wit, '#', '') = $temoin_courant]"/>
                <xsl:text>~\ldots~</xsl:text>
                <xsl:apply-templates
                    select="descendant::tei:app[last()]/descendant::tei:rdg[translate(@wit, '#', '') = $temoin_courant]"/>
                <xsl:text>}\Dfootnote{\textit{</xsl:text>
                <xsl:value-of select="substring-after($temoin_courant, '_')"/>
                <xsl:text>} | \textit{om. </xsl:text>
                <xsl:for-each select="tokenize(@exclude, '\s')">
                    <xsl:value-of select="substring-after(., '_')"/>
                </xsl:for-each>
                <xsl:text>}}}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="preceding_omitted_lemma">
                    <xsl:choose>
                        <xsl:when
                            test="preceding::node()[self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_courant)][node()]][1] | self::tei:w[ancestor::tei:app[@ana = '#not_apparat']]][1]/name() = 'app'">
                            <xsl:apply-templates
                                select="preceding::node()[self::tei:app][descendant::tei:rdg[contains(@wit, $temoin_courant)][node()]][1]/descendant::tei:rdg[contains(@wit, $temoin_courant)]/tei:w"/>

                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="preceding::node()[self::tei:w][1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:text>\edtext{}{</xsl:text>
                <xsl:text>\Cfootnote{[OM3]</xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text> \textit{</xsl:text>
                <xsl:value-of select="chezmoi:witstosigla(@exclude)"/>
                <xsl:text>} | </xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:apply-templates
                    select="descendant::tei:rdg[not(contains(translate(@wit, '#', ''), $temoin_courant))]"/>
                <xsl:text> \textit{</xsl:text>
                <xsl:value-of select="chezmoi:witstosigla(@corresp)"/>
                <xsl:text>}}}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

-->



    <!-- <xsl:template match="tei:seg[@ana = '#omission'][@exclude]" mode="edition">
        <xsl:variable name="wit_to_exclude" select="translate(@exclude, '#', '')"/>
        <xsl:choose>
            <xsl:when test="contains($wit_to_exclude, $temoin_courant)">
                <xsl:variable name="preceding_omitted_lemma">
                    <xsl:choose>
                        <xsl:when
                            test="preceding-sibling::node()[self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_courant)][node()]] | self::tei:w][1]/name() = 'app'">
                            <xsl:apply-templates
                                select="preceding-sibling::node()[self::tei:app][descendant::tei:rdg[contains(@wit, $temoin_courant)][node()]][1]/descendant::tei:rdg[contains(@wit, $temoin_courant)]/tei:w"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="preceding-sibling::node()[self::tei:w][1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="following_omitted_lemma">
                    <xsl:choose>
                        <xsl:when
                            test="following-sibling::node()[self::tei:app | self::tei:w][1]/name() = 'app'">
                            <xsl:apply-templates
                                select="following-sibling::node()[self::tei:app][1]/descendant::tei:rdg[contains(@wit, $temoin_courant)]/tei:w"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="following-sibling::node()[self::tei:w][1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:text>\edtext{}{\Cfootnote{Texte omis entre \enquote{</xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text>} et \enquote{</xsl:text>
                <xsl:value-of select="$following_omitted_lemma"/>
                <xsl:text>} chez \textit{</xsl:text>
                <xsl:value-of select="substring-after($temoin_courant, '_')"/>
                <xsl:text>}: </xsl:text>
                <xsl:apply-templates mode="omission_complexe"/>
                <xsl:text>}}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="starting_omitted_lemma">
                    <xsl:apply-templates
                        select="tei:app[1]/descendant::tei:rdg[contains(@wit, $temoin_courant)]/tei:w"/>
                </xsl:variable>
                <xsl:variable name="ending_omitted_lemma">
                    <xsl:apply-templates
                        select="tei:app[last() - 1]/descendant::tei:rdg[contains(@wit, $temoin_courant)]/tei:w | tei:app[last()]/descendant::tei:rdg[contains(@wit, $temoin_courant)]/tei:w"
                    />
                </xsl:variable>
                <xsl:text>\edtext{}{\Cfootnote{Texte omis à partir de \enquote{</xsl:text>
                <xsl:value-of select="$starting_omitted_lemma"/>
                <xsl:text>} et jusque \enquote{</xsl:text>
                <xsl:value-of select="$ending_omitted_lemma"/>
                <xsl:text>} chez \textit{</xsl:text>
                <xsl:value-of select="chezmoi:witstosigla(@exclude)"/>
                <xsl:text>}.</xsl:text>
                <xsl:text>}}</xsl:text>
                <xsl:apply-templates mode="edition"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-\-Il faut refaire un tour de typologisation des variantes pour les variantes avec omission, ce qui suppose de changer l'attribut et d'utiliser
            plutôt @ana.-\->
    </xsl:template>
-->


    <!--Les apparats de type filtre sont à ignorer-->
    <xsl:template
        match="tei:app[@ana = '#graphique'] | tei:app[@ana = '#filtre'][count(descendant::tei:rdg) = 1] | tei:app[@ana = '#auxiliarite']"
        mode="edition">
        <!--Ajouter un test sur la présence d'une note-->
        <xsl:text> </xsl:text>
        <!--Afficher ici la lecture du témoin courant, voir plus bas-->
        <xsl:apply-templates
            select="descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]"
            mode="apparat"/>
        <xsl:if
            test="descendant::tei:note[not(ancestor::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)])]">
            <xsl:apply-templates
                select="descendant::tei:note[not(ancestor::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)])]"
                mode="apparat"/>
        </xsl:if>
    </xsl:template>




    <!--Trop de footnoteD va tout décaler, dont l'apparat. De toutes façons, ça n'est pas 
    une bonne manière de faire apparaître les omissions.-->
    <!-- <xsl:template match="tei:witEnd" mode="edition">
        <xsl:variable name="wits" select="chezmoi:witstosigla(@corresp)"/>
        <xsl:text>\edtext{}{\footnoteD{Le texte des témoins </xsl:text>
        <xsl:value-of select="$wits"/>
        <xsl:text> s'arrête ici.}}</xsl:text>
    </xsl:template>
    
    
    <xsl:template match="tei:witStart" mode="edition">
        <xsl:variable name="wits" select="chezmoi:witstosigla(@corresp)"/>
        <xsl:text>\edtext{}{\footnoteD{Le texte des témoins </xsl:text>
        <xsl:value-of select="$wits"/>
        <xsl:text> reprend ici.}}</xsl:text>
    </xsl:template>-->
    <!--Trop de footnoteD va tout décaler, dont l'apparat.-->

    <xsl:template match="tei:app[contains(@ana, '#omission')]" mode="edition">
        <xsl:variable name="witnesses" select="descendant::tei:rdg[not(node())]/@wit"/>
        <xsl:choose>
            <!--Si le témoin omis est le témoin base, il faut aller chercher du contexte-->
            <xsl:when test="contains($witnesses, $temoin_courant)">
                <xsl:variable name="preceding_omitted_lemma">
                    <xsl:choose>
                        <xsl:when
                            test="preceding-sibling::node()[self::tei:app[descendant::tei:rdg[contains(@wit, $temoin_courant)][node()]] | self::tei:w][1]/name() = 'app'">
                            <xsl:apply-templates
                                select="preceding-sibling::node()[self::tei:app][descendant::tei:rdg[contains(@wit, $temoin_courant)][node()]][1]/descendant::tei:rdg[contains(@wit, $temoin_courant)]/tei:w"
                                mode="apparat"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="preceding-sibling::node()[self::tei:w][1]"
                                mode="apparat"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="omm_wits"
                    select="chezmoi:witstosigla(descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]/@wit)"/>
                <xsl:text>\edtext{</xsl:text>
                <xsl:text>}{</xsl:text>
                <xsl:text>\Dfootnote{[OM1]</xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text> \textit{</xsl:text>
                <xsl:value-of select="$omm_wits"/>
                <xsl:text>} | </xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text> </xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(@ana, '#graphique')">
                        <xsl:text> [GRAPH]</xsl:text>
                        <xsl:apply-templates
                            select="descendant::tei:rdg[not(contains(translate(@wit, '#', ''), $temoin_courant))][1]"/>
                        <xsl:text> \textit{</xsl:text>
                        <xsl:variable name="grouped_sigla">
                            <xsl:for-each
                                select="descendant::tei:rdgGrp[descendant::tei:rdg[not(contains(translate(@wit, '#', ''), $temoin_courant))]]">
                                <xsl:for-each select="descendant::tei:rdg">
                                    <xsl:value-of select="chezmoi:witstosigla(@wit)"/>
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
                        <xsl:text> [LEX]</xsl:text>
                        <xsl:variable name="grouped_sigla">
                            <xsl:for-each
                                select="descendant::tei:rdgGrp[descendant::tei:rdg[not(contains(translate(@wit, '#', ''), $temoin_courant))]]">
                                <xsl:value-of select="$preceding_omitted_lemma"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates
                                    select="descendant::tei:rdg[not(contains(translate(@wit, '#', ''), $temoin_courant))][1]"/>
                                <xsl:text> \textit{</xsl:text>
                                <xsl:for-each select="descendant::tei:rdg">
                                    <xsl:value-of select="chezmoi:witstosigla(@wit)"/>
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
                            select="descendant::tei:rdg[not(contains(translate(@wit, '#', ''), $temoin_courant))]"/>
                        <xsl:variable name="non_omm_wits"
                            select="chezmoi:witstosigla(descendant::tei:rdg[not(contains(translate(@wit, '#', ''), $temoin_courant))]/@wit)"/>
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
                <xsl:text> </xsl:text>
                <xsl:text> \edtext{</xsl:text>
                <xsl:apply-templates
                    select="descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]"
                    mode="apparat"/>
                <xsl:text>}{\lemma{</xsl:text>
                <xsl:apply-templates
                    select="descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]"
                    mode="apparat"/>
                <xsl:text>}</xsl:text>
                <xsl:text> \Dfootnote{</xsl:text>
                <!--Ici il faut ajouter un omm. dans l'apparat sans que ça se voie dans le corps du texte.-->
                <xsl:text>[OM2] \textit{</xsl:text>
                <!--Pour chaque témoin, ne faire apparaître que la lettre correspondante-->
                <xsl:choose>
                    <!--S'il y a un rdgGrp (= si d'autres leçons sont identiques modulo variation graphique à la leçon base)-->
                    <xsl:when
                        test="boolean(descendant::tei:rdgGrp[descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]])">
                        <xsl:variable name="lemma_wits"
                            select="chezmoi:witstosigla(descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]/@wit)"/>
                        <xsl:variable name="siblings">
                            <xsl:value-of select="
                                    chezmoi:witstosigla(descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]/following-sibling::tei:rdg/@wit |
                                    descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]/preceding-sibling::tei:rdg/@wit)"
                            />
                        </xsl:variable>
                        <!--Il y a parfois des rdgGrp qui ne contiennent qu'un tei:rdg: dans ce cas, n'imprimer que la valeur du témoin base-->
                        <xsl:choose>
                            <xsl:when
                                test="boolean(count(descendant::tei:rdgGrp[descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]]/descendant::tei:rdg) > 1)">

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
                            select="chezmoi:witstosigla(tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]/@wit)"
                        />
                    </xsl:otherwise>
                </xsl:choose>
                <!--Pour chaque témoin, ne faire apparaître que la lettre correspondante-->
                <xsl:text>}\,|\,</xsl:text>
                <!--La même chose mais en utilisant une autre méthode-->
                <xsl:choose>
                    <xsl:when test="descendant::tei:rdgGrp">
                        <xsl:for-each
                            select="descendant::tei:rdgGrp[count(descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]) = 0]">
                            <!--L'idée ici est de raffiner les apparats pour rassembler les variantes graphiques entre elles-->
                            <xsl:for-each select="descendant::tei:rdg">
                                <xsl:variable name="sigle_temoin" select="chezmoi:witstosigla(@wit)"/>
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
                        <xsl:for-each
                            select="tei:rdg[not(contains(translate(@wit, '#', ''), $temoin_courant))]">
                            <xsl:variable name="sigle_temoin" select="chezmoi:witstosigla(@wit)"/>
                            <xsl:choose>
                                <xsl:when test="descendant::text()">
                                    <xsl:apply-templates select="."/>
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
    </xsl:template>


    <xsl:function name="chezmoi:witstosigla">
        <xsl:param name="witnesses"/>
        <xsl:for-each select="tokenize(string-join($witnesses, ' '), '\s')">
            <xsl:value-of select="substring-after(., '_')"/>
        </xsl:for-each>
    </xsl:function>





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
                                select="chezmoi:witstosigla(descendant::tei:rdg[not(node())]/@wit)"/>
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
        <xsl:variable name="temoin_courant2" select="substring-after($temoin_courant, '_')"/>
        <xsl:text> \edtext{</xsl:text>
        <xsl:apply-templates
            select="descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]"
            mode="apparat"/>
        <xsl:text>}{\Dfootnote{</xsl:text>
        <!-- test: UNCLEAR entre crochets avec un ?-->
        <!--Ici il faut ajouter un omm. dans l'apparat sans que ça se voie dans le corps du texte.-->
        <!--Pour chaque témoin, ne faire apparaître que la lettre correspondante-->
        <xsl:choose>
            <!--S'il y a un rdgGrp (= si d'autres leçons sont identiques modulo variation graphique à la leçon base)-->
            <xsl:when
                test="boolean(descendant::tei:rdgGrp[descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]])">
                <xsl:variable name="lemma_wits"
                    select="chezmoi:witstosigla(descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]/@wit)"/>
                <xsl:variable name="siblings">
                    <xsl:value-of
                        select="chezmoi:witstosigla(descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]/following-sibling::tei:rdg)"/>
                    <xsl:value-of
                        select="chezmoi:witstosigla(descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]/preceding-sibling::tei:rdg)"
                    />
                </xsl:variable>

                <!--Il y a parfois des rdgGrp qui ne contiennent qu'un tei:rdg: dans ce cas, n'imprimer que la valeur du témoin base-->
                <xsl:choose>
                    <xsl:when
                        test="boolean(count(descendant::tei:rdgGrp[descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]]/descendant::tei:rdg) > 1)">
                        <xsl:variable name="grouped_sigla">
                            <xsl:for-each
                                select="descendant::tei:rdgGrp[descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]]">
                                <xsl:choose>
                                    <xsl:when test="child::tei:rdg[node()]">
                                        <xsl:text> \textit{</xsl:text>
                                        <xsl:for-each select="descendant::tei:rdg">
                                            <xsl:value-of select="chezmoi:witstosigla(@wit)"/>
                                            <xsl:if test="following-sibling::tei:rdg">
                                                <xsl:text>`</xsl:text>
                                            </xsl:if>
                                        </xsl:for-each>
                                        <xsl:text>}</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>\textit{om.}</xsl:text>
                                        <xsl:text>\,\textit{</xsl:text>
                                        <xsl:value-of select="chezmoi:witstosigla(tei:rdg/@wit)"/>
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
                    select="chezmoi:witstosigla(tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]/@wit)"
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
                        select="descendant::tei:rdgGrp[count(descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]) = 0]">
                        <xsl:choose>
                            <xsl:when test="child::tei:rdg[node()]">
                                <xsl:apply-templates select="descendant::tei:rdg[1]" mode="apparat"/>
                                <xsl:text> \textit{</xsl:text>
                                <xsl:for-each select="descendant::tei:rdg">
                                    <xsl:value-of select="chezmoi:witstosigla(@wit)"/>
                                    <xsl:if test="following-sibling::tei:rdg">
                                        <xsl:text>`</xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                                <xsl:text>}</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>\textit{om.}</xsl:text>
                                <xsl:text>\,\textit{</xsl:text>
                                <xsl:value-of select="chezmoi:witstosigla(tei:rdg/@wit)"/>
                                <xsl:text>}</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="$grouped_sigla"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="tei:rdg[not(contains(translate(@wit, '#', ''), $temoin_courant))]">
                    <xsl:choose>
                        <xsl:when test="descendant::text()">
                            <xsl:apply-templates select="." mode="apparat"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>\textit{om.}</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>\,\textit{</xsl:text>
                    <xsl:value-of select="chezmoi:witstosigla(@wit)"/>
                    <xsl:text>}\,</xsl:text>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>}}</xsl:text>
    </xsl:template>
    <!--STRUCTURE DU TEXTE-->



    <!--Choisir et marquer le chapitre-->

    <!--Choisir et marquer la glose/traduction-->


    <!--Choisir et marquer la glose/traduction-->



    <!--STRUCTURE DU TEXTE-->

    <!--MISE EN PAGE-->
    <!--Marquer les paragraphes par un retour à la ligne-->

    <xsl:template match="tei:p[ancestor::tei:TEI[@xml:id = 'Rome_W']]" mode="edition">
        <xsl:text>\par </xsl:text>
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
                <xsl:apply-templates select="ancestor::tei:div[@type = 'chapitre']/tei:head"
                    mode="titre_edition"/>
                <xsl:text>\pend </xsl:text>
                <xsl:text>\pstart \vspace{1cm}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\pstart </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
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



    <xsl:template match="tei:p[parent::tei:div[@type = 'glose']]" mode="edition">
        <xsl:variable name="div_n" select="ancestor::tei:div[@type = 'chapitre']/@n"/>
        <xsl:choose>
            <xsl:when test="not(preceding::tei:p[ancestor::tei:div[@type = 'chapitre'][@n = $div_n]])">
                <xsl:text>~\\ </xsl:text>
                <xsl:apply-templates select="ancestor::tei:div[@type = 'chapitre']/tei:head"
                    mode="titre_edition"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>~\\ </xsl:text>
            </xsl:otherwise>
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
