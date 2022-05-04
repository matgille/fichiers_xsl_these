<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:chezmoi="https://www.matthiasgillelevenson.fr/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tex="placeholder.uri" exclude-result-prefixes="tex">



    <!---->
    <!---->
    <!--CITATIONS AVEC APPARAT-->
    <!---->
    <!---->



    <!---->
    <!---->
    <!--CITATIONS AVEC APPARAT-->
    <!---->
    <!---->



    <xsl:template match="tei:hi[@rend = 'initiale' or @rend = 'non_initiale']" mode="apparat">
        <xsl:value-of select="."/>
    </xsl:template>


    <xsl:template match="tei:hi[@rend = 'lettre_attente']" mode="apparat"/>


    <xsl:template mode="apparat"
        match="tei:note[@subtype = 'lexicale'][not(parent::tei:head)] | tei:note[@type = 'particulier'] | tei:note[@type = 'general'] | tei:note[@type = 'sources']">
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
                    <!--<xsl:if test="@type = 'particulier'"> Mode debug-->
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="translate(@corresp, '_#', ' ')"/>
                    <!--<xsl:text>. Leçon du témoin: \enquote{</xsl:text>
                    <xsl:for-each
                        select="ancestor::tei:app/descendant::tei:rdg[contains(@wit, $corresponding_witness)]//tei:w">
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                    <xsl:text>}</xsl:text>-->
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
        <!--On fait ça pour ne pas avoir à tout calculer lorsqu'on change une note de bas de page-->
        <xsl:variable name="xml_id" select="@xml:id"/>
        <xsl:variable name="division" select="ancestor::tei:div[not(ancestor::tei:div)]/@n"/>
        <xsl:variable name="corresponding_wit">
            <xsl:choose>
                <xsl:when test="@injected">
                    <xsl:value-of select="translate(@corresp, '#', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="translate(ancestor::tei:div[not(ancestor::tei:div)]/@corresp, '#', '')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates
            select="collection('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan?select=*.xml')//tei:TEI[@xml:id = $corresponding_wit]/descendant::tei:div[@n = $division]/descendant::tei:note[@xml:id = $xml_id]/node()"
            mode="apparat"/>
        <!--On fait ça pour ne pas avoir à tout refaire lorsqu'on change une note de bas de page-->
        <xsl:text>
            }</xsl:text>
    </xsl:template>

    <xsl:template match="tei:quote[@type = 'primaire']" mode="apparat">
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
                                <xsl:apply-templates/>
                                <xsl:text>}\end{otherlanguage}\end{note_quote}</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>\enquote{\begin{otherlanguage}{</xsl:text>
                                <xsl:value-of select="$langue"/>
                                <xsl:text>}\textit{</xsl:text>
                                <xsl:apply-templates/>
                                <xsl:text>}\end{otherlanguage}}</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text>}\end{otherlanguage}\end{quote}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="not(child::tei:l)">
                        <xsl:text>\enquote{</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\begin{quote}</xsl:text>
                        <xsl:apply-templates/>
                        <xsl:text>\end{quote}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--On ignore les transposition simples: on va imprimer le texte du témoin courant-->
    <xsl:template match="tei:seg[@ana = '#transposition']" mode="citation_apparat">
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_courant)]/tei:w"
            mode="citation_apparat"/>
        <!--Incompatibilité avec les omissions, voir comment on gère le problème-->
    </xsl:template>
    <!--On ignore les transposition simples: on va imprimer le texte du témoin courant-->

    <xsl:template match="tei:witEnd" mode="citation_apparat">
        <xsl:param name="temoin_courant"/>
        <xsl:variable name="firstAnchorCorresps" select="@corresp"/>
        <xsl:variable name="lastAnchorCorresps"
            select="following::node()[self::tei:witEnd or self::tei:witStart][1][self::tei:witStart]/@corresp"/>
        <xsl:variable name="firstAnchorID" select="@xml:id"/>
        <xsl:variable name="lastAnchorID"
            select="following::node()[self::tei:witEnd or self::tei:witStart][1][self::tei:witStart]/@xml:id"/>
        <xsl:text>
        </xsl:text>
        <xsl:choose>
            <xsl:when test="$firstAnchorCorresps = $lastAnchorCorresps">
                <xsl:choose>
                    <!--Premier cas: le témoin courant n'omet pas le texte-->
                    <xsl:when test="not(contains($firstAnchorCorresps, $temoin_courant))">
                        <xsl:text>\edtext{</xsl:text>
                        <!--La transposition va poser problème ici dans les cas de suites d'apparats compliqués Passer dans l'@ana des tei:app la transposition.-->
                        <xsl:apply-templates
                            select="following::node()[following::node()[@xml:id = $lastAnchorID]][self::tei:app][not(ancestor::tei:seg[@ana = '#transposition'])]"
                            mode="citation_omission_complexe"/>
                        <xsl:text>}{</xsl:text>
                        <xsl:text>\lemma{</xsl:text>
                        <xsl:apply-templates
                            select="following::node()[following::node()[@xml:id = $lastAnchorID]][self::tei:app][1]"
                            mode="citation_omission_complexe"/>
                        <xsl:text>\ldots ~</xsl:text>
                        <xsl:apply-templates
                            select="following::node()[following::node()[@xml:id = $lastAnchorID]][self::tei:app][last()]"
                            mode="citation_omission_complexe"/>
                        <xsl:text>}\Dfootnote{\,|\,\textit{om.} \textit{</xsl:text>
                        <xsl:value-of select="chezmoi:witstosigla($firstAnchorCorresps)"/>
                        <xsl:text>}}}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="first_preceding_sibling"
                            select="preceding::tei:app[1]/descendant::tei:rdg[contains(@wit, $temoin_courant)][node()]"/>
                        <xsl:variable name="omitted_witnesses">
                            <xsl:choose>
                                <xsl:when test="$first_preceding_sibling/ancestor::tei:rdgGrp">
                                    <xsl:for-each
                                        select="$first_preceding_sibling/ancestor::tei:rdgGrp[descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]]/descendant::tei:rdg">
                                        <xsl:value-of select="chezmoi:witstosigla(@wit)"/>
                                        <xsl:if test="following-sibling::tei:rdg">
                                            <xsl:text>`</xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="chezmoi:witstosigla($first_preceding_sibling/descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]/@wit)"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:text>\edtext{}{\lemma{</xsl:text>
                        <xsl:apply-templates select="$first_preceding_sibling"
                            mode="citation_omission_complexe"/>
                        <xsl:text>}\Dfootnote{\textit{</xsl:text>
                        <xsl:value-of select="$omitted_witnesses"/>
                        <xsl:text>}\,|\,</xsl:text>
                        <xsl:apply-templates select="$first_preceding_sibling"/>
                        <xsl:text> </xsl:text>
                        <xsl:apply-templates
                            select="following::node()[following::node()[@xml:id = $lastAnchorID]][self::tei:app]"
                            mode="citation_omission_complexe"/>
                        <xsl:text>}}</xsl:text>
                    </xsl:otherwise>
                    <!--Premier cas: le témoin courant n'omet pas le texte-->
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:app[@ana = '#not_apparat']" mode="citation_omission_complexe">
        <xsl:apply-templates select="tei:rdg/tei:w"/>
    </xsl:template>





    <xsl:template
        match="tei:app[@ana = '#graphique'][not(contains(@ana, '#omission'))] | tei:app[contains(@ana, '#filtre')][not(contains(@ana, '#omission'))][count(descendant::tei:rdg) = 1] | tei:app[contains(@ana, '#auxiliarite')][not(contains(@ana, '#omission'))]"
        mode="citation_apparat">
        <xsl:param name="temoin_courant"/>
        <!--Ajouter un test sur la présence d'une note-->
        <xsl:text> </xsl:text>
        <!--Afficher ici la lecture du témoin courant, voir plus bas-->
        <xsl:apply-templates select="tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]"
            mode="citation_apparat"/>
    </xsl:template>


    <xsl:template
        match="tei:app[contains(@ana, '#filtre')][count(descendant::tei:rdg) > 1][not(contains(@ana, '#omission'))]"
        mode="citation_apparat">
        <xsl:param name="temoin_courant"/>
        <xsl:apply-templates
            select="descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]"
            mode="citation_apparat"/>
    </xsl:template>

    <xsl:template match="
            tei:app[contains(@ana, '#lexicale')][count(descendant::tei:rdg) = 1]
            | tei:app[contains(@ana, '#morphosyntactique')][count(descendant::tei:rdg) = 1]
            | tei:app[contains(@ana, '#indetermine')][count(descendant::tei:rdg) = 1]"
        mode="citation_apparat">
        <!--Essayer de trouver un moyen de faire apparaître les omissions clairement. Par exemple: dans un niveau de note spécifique.-->
        <!--On omet les omissions pour l'instant-->
        <xsl:apply-templates mode="citation_apparat"/>
    </xsl:template>


    <!--

    <xsl:template match="tei:rdg" mode="citation_omission_complexe">
        <xsl:text> % Ici un mot
        </xsl:text>
        <xsl:apply-templates select="tei:w"/>
    </xsl:template>-->

    <xsl:template match="
            tei:app[contains(@ana, '#entite_nommee')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#lexicale')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#morphosyntactique')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#indetermine')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#personne')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#genre')][count(descendant::tei:rdg) > 1]"
        mode="citation_omission_complexe" priority="3">
        <xsl:text>[ </xsl:text>
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_courant)]"/>
        <xsl:choose>
            <xsl:when test="tei:rdgGrp">
                <xsl:variable name="grouped_sigla">
                    <xsl:for-each
                        select="descendant::tei:rdgGrp[descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]]/descendant::tei:rdg">
                        <xsl:value-of select="chezmoi:witstosigla(@wit)"/>
                        <xsl:if test="following-sibling::tei:rdg">
                            <xsl:text>`</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:text> \textit{</xsl:text>
                <xsl:value-of select="$grouped_sigla"/>
                <xsl:text>} </xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template
        match="tei:app[@ana = '#graphique'] | tei:app[@ana = '#filtre'][count(descendant::tei:rdg) = 1] | tei:app[@ana = '#auxiliarite']"
        mode="citation_omission_complexe">
        <xsl:apply-templates select="descendant::tei:rdg[contains(@wit, $temoin_courant)]"/>
    </xsl:template>


    <xsl:template match="tei:app" priority="2" mode="citation_apparat">
        <!--On crée cette règle qui a la plus grande priorité: on va d'abord aller regarder si le tei:app est entre
        deux ancres tei:witEnd et tei:witStart, pour s'occuper de l'omission.-->
        <xsl:param name="temoin_courant"/>
        <xsl:variable name="precedingWitEnd"
            select="boolean(preceding::node()[self::tei:witEnd or self::tei:witStart][1][self::tei:witEnd])"/>
        <xsl:variable name="followingWitStart"
            select="boolean(following::node()[self::tei:witEnd or self::tei:witStart][1][self::tei:witStart])"/>
        <xsl:variable name="firstAnchorCorresps"
            select="preceding::node()[self::tei:witEnd or self::tei:witStart][1][self::tei:witEnd]/@corresp"/>
        <xsl:variable name="lastAnchorCorresps"
            select="following::node()[self::tei:witEnd or self::tei:witStart][1][self::tei:witStart]/@corresp"/>
        <xsl:variable name="firstAnchorID"
            select="preceding::node()[self::tei:witEnd or self::tei:witStart][1][self::tei:witEnd]/@xml:id"/>
        <xsl:variable name="lastAnchorID"
            select="following::node()[self::tei:witEnd or self::tei:witStart][1][self::tei:witStart]/@xml:id"/>
        <xsl:choose>
            <!--Dans ce cas, on ne fait rien, car c'est géré par une autre template (noeuds textuels entre witEnd et witStart matchant les mêmes témoins-->
            <xsl:when
                test="$precedingWitEnd and $followingWitStart and $firstAnchorCorresps = $lastAnchorCorresps"> </xsl:when>
            <!--Dans ce cas, on ne fait rien, car c'est géré par une autre template-->
            <xsl:otherwise>
                <!--Sinon, on va chercher la template qui a été non appliquée par le jeu des priorités, càd la template plus spécifique: https://stackoverflow.com/a/19316980-->
                <xsl:next-match>
                    <xsl:with-param name="temoin_courant" select="$temoin_courant"/>
                </xsl:next-match>
                <!--Sinon, on va chercher la template qui a été non appliquée par le jeu des priorités-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="tei:app[contains(@ana, '#omission')][contains(@ana, '#graphique')]" priority="1"
        mode="citation_apparat">
        <!--Si #omission est la seule valeur de l'analyse, alors il s'agit d'une omission binaire (un témoin ou un groupe omet du texte;
        les autres témoins concordent complètement)-->
        <xsl:param name="temoin_courant"/>
        <xsl:choose>
            <!--Quand le témoin courant n'est pas omis-->
            <xsl:when
                test="descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)][tei:w]">
                <xsl:text> % Omission avec variante graphique ici, témoin courant présent 
                </xsl:text>
                <xsl:variable name="grouped_sigla">
                    <xsl:for-each
                        select="descendant::tei:rdgGrp[contains(translate(string-join(tei:rdg/@wit), '#', ''), $temoin_courant)]">
                        <xsl:for-each select="descendant::tei:rdg">
                            <xsl:value-of select="chezmoi:witstosigla(@wit)"/>
                            <xsl:if test="following-sibling::tei:rdg">
                                <xsl:text>`</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="sigle" select="substring-after($temoin_courant, '_')"/>
                <xsl:text> \edtext{</xsl:text>
                <xsl:apply-templates
                    select="descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]"
                    mode="citation_apparat"/>
                <xsl:text>}{\Dfootnote{\textit{</xsl:text>
                <xsl:value-of select="$grouped_sigla"/>
                <xsl:text>}\,|\,</xsl:text>
                <xsl:text>\textit{om.} \textit{</xsl:text>
                <xsl:value-of select="chezmoi:witstosigla(descendant::tei:rdg[not(tei:w)]/@wit)"/>
                <xsl:text>}}}</xsl:text>
            </xsl:when>
            <!--Quand le témoin courant est omis-->

            <!--Si le témoin courant est omis-->
            <xsl:otherwise>
                <xsl:text> % Omission binaire ici, témoin courant omis 
                </xsl:text>
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
                <xsl:text> </xsl:text>
                <xsl:variable name="sigle" select="substring-after($temoin_courant, '_')"/>
                <xsl:text> \edtext{</xsl:text>
                <xsl:apply-templates
                    select="descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]"
                    mode="citation_apparat"/>
                <xsl:text>}{\lemma{</xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text>}\Dfootnote{| </xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text> </xsl:text>
                <xsl:apply-templates
                    select="descendant::tei:rdg[not(contains(translate(@wit, '#', ''), $temoin_courant))]"/>
                <xsl:text> \textit{</xsl:text>
                <xsl:value-of
                    select="chezmoi:witstosigla(descendant::tei:rdg[not(contains(translate(@wit, '#', ''), $temoin_courant))]/@wit)"/>
                <xsl:text>}</xsl:text>
                <xsl:text>}}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:app[@ana = '#omission']" mode="citation_apparat" priority="1">
        <!--Si #omission est la seule valeur de l'analyse, alors il s'agit d'une omission binaire (un témoin ou un groupe omet du texte;
        les autres témoins concordent complètement)-->
        <xsl:param name="temoin_courant"/>
        <xsl:choose>
            <!--Quand le témoin courant n'est pas omis-->
            <xsl:when
                test="descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)][tei:w]">
                <xsl:text> % Omission binaire ici, témoin courant présent 
                </xsl:text>
                <xsl:variable name="sigle" select="substring-after($temoin_courant, '_')"/>
                <xsl:text> \edtext{</xsl:text>
                <xsl:apply-templates select="descendant::tei:rdg[tei:w]" mode="citation_apparat"/>
                <xsl:text>}{\Dfootnote{\textit{</xsl:text>
                <xsl:value-of select="chezmoi:witstosigla(descendant::tei:rdg[tei:w]/@wit)"/>
                <xsl:text>}\,|\,</xsl:text>
                <xsl:text>\textit{om.} \textit{</xsl:text>
                <xsl:value-of select="chezmoi:witstosigla(descendant::tei:rdg[not(tei:w)]/@wit)"/>
                <xsl:text>}}}</xsl:text>
            </xsl:when>
            <!--Quand le témoin courant est omis-->

            <!--Si le témoin courant est omis-->
            <xsl:otherwise>
                <xsl:text> % Omission binaire ici, témoin courant omis 
                </xsl:text>
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
                <xsl:text> </xsl:text>
                <xsl:variable name="sigle" select="substring-after($temoin_courant, '_')"/>
                <xsl:text> \edtext{</xsl:text>
                <xsl:apply-templates
                    select="descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]"
                    mode="citation_apparat"/>
                <xsl:text>}{\lemma{</xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text>}\Dfootnote{| </xsl:text>
                <xsl:value-of select="$preceding_omitted_lemma"/>
                <xsl:text> </xsl:text>
                <xsl:apply-templates
                    select="descendant::tei:rdg[not(contains(translate(@wit, '#', ''), $temoin_courant))]"/>
                <xsl:text> \textit{</xsl:text>
                <xsl:value-of
                    select="chezmoi:witstosigla(descendant::tei:rdg[not(contains(translate(@wit, '#', ''), $temoin_courant))]/@wit)"/>
                <xsl:text>}</xsl:text>
                <xsl:text>}}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="tei:sic[not(@ana = '#omission')]" mode="citation_apparat">
        <xsl:apply-templates mode="citation_apparat"/>
        <xsl:text>\textsuperscript{\textit{[sic]}}</xsl:text>
    </xsl:template>




    <xsl:template
        match="tei:app[@ana = '#graphique'] | tei:app[@ana = '#filtre'][count(descendant::tei:rdg) = 1] | tei:app[@ana = '#auxiliarite']"
        mode="citation_apparat" priority="1">
        <xsl:param name="temoin_courant"/>
        <!--Ajouter un test sur la présence d'une note-->
        <xsl:text> </xsl:text>
        <!--Afficher ici la lecture du témoin courant, voir plus bas-->
        <xsl:apply-templates
            select="descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]"
            mode="citation_apparat"/>
        <xsl:if
            test="descendant::tei:note[not(ancestor::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)])]">
            <xsl:apply-templates
                select="descendant::tei:note[not(ancestor::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)])]"
                mode="citation_apparat"/>
        </xsl:if>
    </xsl:template>


    <xsl:template match="
            tei:app[contains(@ana, '#entite_nommee')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#lexicale')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#morphosyntactique')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#indetermine')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#personne')][count(descendant::tei:rdg) > 1]
            | tei:app[contains(@ana, '#genre')][count(descendant::tei:rdg) > 1]
            " mode="citation_apparat">
        <xsl:param name="temoin_courant"/>
        <xsl:text>% Variante de type </xsl:text>
        <xsl:value-of select="@ana"/>
        <xsl:text>; témoin courant: </xsl:text>
        <xsl:value-of select="$temoin_courant"/>
        <xsl:text>
        </xsl:text>
        <xsl:text> </xsl:text>
        <xsl:variable name="temoin_courant2" select="substring-after($temoin_courant, '_')"/>
        <xsl:text> \edtext{</xsl:text>
        <xsl:apply-templates
            select="descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]"
            mode="citation_apparat"/>
        <xsl:text>}{\Dfootnote{</xsl:text>
        <xsl:text>\textit{</xsl:text>
        <!--Pour chaque témoin, ne faire apparaître que la lettre correspondante-->
        <xsl:choose>
            <!--S'il y a un rdgGrp (= si d'autres leçons sont identiques modulo variation graphique à la leçon base)-->
            <xsl:when
                test="descendant::tei:rdgGrp[descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]]">
                <xsl:variable name="grouped_sigla">
                    <xsl:for-each
                        select="descendant::tei:rdgGrp[descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)]]/descendant::tei:rdg">
                        <xsl:value-of select="chezmoi:witstosigla(@wit)"/>
                        <xsl:if test="following-sibling::tei:rdg">
                            <xsl:text>`</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="$grouped_sigla"/>
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
                    select="descendant::tei:rdgGrp[not(descendant::tei:rdg[contains(translate(@wit, '#', ''), $temoin_courant)])]">
                    <xsl:variable name="grouped_sigla">
                        <xsl:for-each select="descendant::tei:rdg">
                            <xsl:value-of select="chezmoi:witstosigla(@wit)"/>
                            <xsl:if test="following-sibling::tei:rdg">
                                <xsl:text>`</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:apply-templates select="tei:rdg[1]" mode="rdg_apparat"/>
                    <xsl:text>\,\textit{</xsl:text>
                    <xsl:value-of select="$grouped_sigla"/>
                    <xsl:text>}\,</xsl:text>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="tei:rdg[not(contains(translate(@wit, '#', ''), $temoin_courant))]">
                    <xsl:variable name="sigle_temoin" select="chezmoi:witstosigla(@wit)"/>
                    <xsl:apply-templates select="." mode="rdg_apparat"/>
                    <xsl:text>\,\textit{</xsl:text>
                    <xsl:value-of select="$sigle_temoin"/>
                    <xsl:text>}\,</xsl:text>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>}}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:rdg" mode="rdg_apparat">
        <xsl:choose>
            <xsl:when test="tei:w">
                <xsl:apply-templates mode="apparat"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\textit{om.} </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="tei:note" mode="citation_apparat"/>


    <xsl:template match="tei:lb[@break = 'yes']" mode="citation_apparat">
        <!--On va ignorer les lb-->
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:witStart" mode="citation_apparat">
        <xsl:text>\footnoteA{Le témoin </xsl:text>
        <xsl:value-of select="chezmoi:witstosigla(@corresp)"/>
        <xsl:text> reprend ici.}</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:cb" mode="citation_apparat">
        <xsl:text>[cb]</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:space" mode="citation_apparat">
        <xsl:text> </xsl:text>
    </xsl:template>
    
    
    
    <xsl:template match="tei:add[@type = 'commentaire']" mode="citation_apparat">
        <xsl:text>\footnoteA{Glose d'une main</xsl:text>
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
        <xsl:text>: \enquote{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}}</xsl:text>
    </xsl:template>
    
    
    <xsl:template match="tei:supplied" mode="citation_apparat">
        <xsl:text>\textit{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
    </xsl:template>


    <xsl:template match="tei:add[@type = 'correction']" mode="citation_apparat">
        <xsl:text>[Correction d'une main:</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="tei:w" mode="#all">
        <xsl:if test="not(parent::tei:del[count(descendant::tei:w) = 1])">
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:variable name="preceding" as="xs:string*"
            select="preceding-sibling::tei:app/descendant::tei:w[position() lt 11]/text()"/>
        <xsl:variable name="following" as="xs:string*"
            select="following-sibling::tei:app/descendant::tei:w[position() lt 11]/text()"/>
        <xsl:choose>
            <xsl:when test="text() = ($preceding, $following)">
                <xsl:text>\sameword{</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="following::tei:pc[1]"/>
            <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
