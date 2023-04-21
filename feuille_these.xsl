<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:teiExample="http://www.tei-c.org/ns/Examples" xmlns:myfunctions="https://www.matthiasgillelevenson.fr/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xalan="http://xml.apache.org/xalan" xmlns:java="http://www.java.com/"
    exclude-result-prefixes="java xs" version="3.0">

    <xsl:output method="xml" omit-xml-declaration="yes" indent="no" xalan:indent-amount="2"/>
    <!--https://stackoverflow.com/a/5443647-->
    <!--On sort du XML pour pouvoir imprimer les noeuds des éléments teiExample-->
    <!--Du coup ça semble poser un problème dans la production de l'esperluette.-->

    <xsl:variable name="temoin_base_edition" select="'Mad_B'"/>
    <xsl:variable name="tous_les_temoins">Mad_A Mad_B Mad_G Esc_Q Phil_U Sal_J Sev_R Sev_Z</xsl:variable>
    <xsl:variable name="tous_les_temoins_tokenise">
        <xsl:value-of select="tokenize($tous_les_temoins, '\s')"/>
    </xsl:variable>

    <xsl:variable name="debug" select="'False'"/>

    <xsl:strip-space elements="*"/>

    <!--https://our.umbraco.com/forum/developers/xslt/3116-How-to-get-the-Ampersand-output-as-single-char#comment-10435-->
    <xsl:variable name="and"><![CDATA[&]]></xsl:variable>
    <!--https://our.umbraco.com/forum/developers/xslt/3116-How-to-get-the-Ampersand-output-as-single-char#comment-10435-->
    <xsl:variable name="corpus_path"
        >/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/corpus/corpus.xml</xsl:variable>


    <xsl:variable name="edition_path"
        >/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/edition</xsl:variable>

    <xsl:variable name="latin_path"
        >/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/latin/Rome_W.xml</xsl:variable>

    <xsl:variable name="s_path"
        >/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan/Val_S.xml</xsl:variable>

    <xsl:variable name="corpus" select="document($corpus_path)"/>
    <xsl:variable name="latin_doc" select="document($latin_path)"/>
    <xsl:variable name="s_doc" select="document($s_path)"/>


    <xsl:variable name="chemin_temoin_base_edition"
        select="concat('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/edition/temoins/', $temoin_base_edition, '.xml')"/>

    <xsl:template match="/">
        <xsl:result-document
            href="/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/corpus/biblio_mss.bib">
            <xsl:text>% Document produit automatiquement à partir de la xsl feuille_these, il faut modifier les informations directement dans le XML.
            </xsl:text>
            <xsl:for-each
                select="collection('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan?select=*.xml')//tei:TEI">
                <xsl:apply-templates mode="biblio_temoins_corpus"/>
            </xsl:for-each>
            <xsl:text>&#009;&#009;</xsl:text>
            <xsl:for-each select="$corpus//tei:TEI[@xml:id = 'hors_corpus']">
                <xsl:apply-templates select="descendant::tei:witness" mode="biblio_temoins_autres"/>
            </xsl:for-each>
            <xsl:text>&#009;&#009;</xsl:text>
            <xsl:apply-templates select="$corpus/descendant::tei:TEI[@xml:id = 'Rome_W']" mode="biblio_temoins_corpus"/>
        </xsl:result-document>
        <xsl:text>&#10;&#10;
        \newpage
        \thispagestyle{empty}
        \hspace{13cm}\vfill\vfill
        \hfill\hfill </xsl:text>
        <xsl:value-of select="//tei:div[@type = 'exergue']"/>
        <xsl:text>&#10;
        \newpage
        \pagestyle{commentaire} </xsl:text>
        <!--        <xsl:apply-templates select="//tei:TEI[@type = 'these']/descendant::tei:front" mode="these"/>-->
        <xsl:apply-templates select="//tei:TEI[@type = 'these']/descendant::tei:body" mode="these"/>
        <xsl:text>&#10;&#10;\cleardoublepage&#10;&#10;
        % On a un fonctionnement différent entre la thèse et l'édition.&#10;</xsl:text>
        <xsl:text>\part{Édition du texte selon le manuscrit </xsl:text>
        <xsl:value-of select="myfunctions:witstosigla($temoin_base_edition)"/>
        <xsl:text>}&#10;\setcounter{section}{0}&#10;</xsl:text>
        <xsl:apply-templates select="//tei:div[@xml:id = 'SYJfTfmQOF']" mode="these"/>
        <xsl:text>\cleardoublepage
        \onlysideX[B]{R}
        \onlysideX[D]{R}
        \Xonlyside[B]{R}
        \Xonlyside[D]{L}&#10;&#10;
        \setcounter{section}{0}&#10;</xsl:text>
        <xsl:text> \thispagestyle{empty}\cleardoublepage&#10;</xsl:text>
        <xsl:text>\pagestyle{edition_vis_a_vis}&#10;</xsl:text>
        <!-- <xsl:apply-templates
            select="document($chemin_temoin_base_edition)/descendant::tei:body/descendant::tei:div[@type = 'chapitre']"
            mode="edition"/>-->
        <!--<xsl:apply-templates
            select="document($chemin_temoin_base_edition)/descendant::tei:body/descendant::tei:div[@type = 'chapitre'][@n = '17' or @n = '18' or @n = '19' or @n = '20' or @n = '21' or @n = '22' or @n = '23']"
            mode="edition"/>-->
        <xsl:apply-templates
            select="document($chemin_temoin_base_edition)/descendant::tei:body/descendant::tei:div[@type = 'chapitre'][@n = '80' or @n = '140' or @n = '70']"
            mode="edition"/>
        <xsl:text>\hfill\vfill Ce document est le fruit d'une compilation sur les fichiers de la version </xsl:text>
        <xsl:text>\href[pdfnewwindow=true]{https://gitlab.huma-num.fr/mgillelevenson/hyperregimiento-de-los-principes/-/tree/</xsl:text>
        <xsl:value-of select="substring(//tei:p[@xml:id = 'dernier_commit']/@n, 0, 10)"/>
        <xsl:text>}{</xsl:text>
        <xsl:value-of select="substring(//tei:p[@xml:id = 'dernier_commit']/@n, 0, 8)"/>
        <xsl:text>}  du dépôt. </xsl:text>
        <xsl:text>\pagestyle{annexes}</xsl:text>
        <xsl:text>\setcounter{page}{1}</xsl:text>
        <xsl:text>&#10;\titleformat{\chapter}{}{}{0em}{\LARGE\bfseries}</xsl:text>
        <!--À supprimer lors de la production de la thèse: on cite tous les témoins des teiHeader-->
        <!--                <xsl:apply-templates select="//tei:TEI[@type = 'these']/descendant::tei:back" mode="these"/>-->
        <xsl:text>\pagestyle{bibliographie}</xsl:text>
        <xsl:text>\nocite{</xsl:text>
        <xsl:value-of
            select="string-join($corpus/descendant::tei:TEI[@xml:id = 'hors_corpus']/descendant::tei:sourceDesc/descendant::tei:listWit/tei:witness/@xml:id | collection('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan?select=*.xml')/descendant::tei:TEI/@xml:id, ',')"/>
        <xsl:text>}
            \hfill\vfill Ce document est le fruit d'une compilation sur les fichiers de la version </xsl:text>
        <xsl:text>\href[pdfnewwindow=true]{https://gitlab.huma-num.fr/mgillelevenson/hyperregimiento-de-los-principes/-/tree/</xsl:text>
        <xsl:value-of select="substring(//tei:p[@xml:id = 'dernier_commit']/@n, 0, 10)"/>
        <xsl:text>}{</xsl:text>
        <xsl:value-of select="substring(//tei:p[@xml:id = 'dernier_commit']/@n, 0, 8)"/>
        <xsl:text>}  du dépôt. </xsl:text>
        <!--À supprimer lors de la production de la thèse: on cite tous les témoins des teiHeader-->
    </xsl:template>




    <xsl:import href="mode_apparat.xsl"/>
    <xsl:import href="feuille_these_edition.xsl"/>

    <!--Production du fichier .bib contenant les informations des manuscrits-->


    <xsl:template match="tei:teiHeader" mode="biblio_temoins_corpus">
        <xsl:variable name="id">
            <xsl:value-of select="ancestor::tei:TEI[1]/@xml:id"/>
        </xsl:variable>
        <xsl:text>@manuscript{</xsl:text>
        <xsl:value-of select="ancestor::tei:TEI[1]/@xml:id"/>
        <xsl:text>,&#10;&#009;&#009;shorthand = {</xsl:text>
        <xsl:value-of select="descendant::tei:msName"/>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;shelfmark = {</xsl:text>
        <xsl:value-of select="replace(descendant::tei:witness/descendant::tei:idno, '&amp;', concat('\\', $and))"
            disable-output-escaping="true"/>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;library = {</xsl:text>
        <xsl:value-of select="descendant::tei:repository"/>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;Dating = {</xsl:text>
        <xsl:choose>
            <xsl:when test="descendant::tei:origDate[@notBefore][not(@notAfter)]">
                <xsl:value-of select="concat('après ', descendant::tei:origDate/@notBefore)"/>
            </xsl:when>
            <xsl:when test="descendant::tei:origDate[not(@notBefore)][@notAfter]">
                <xsl:value-of select="concat('avant ', descendant::tei:origDate/@notAfter)"/>
            </xsl:when>
            <xsl:when test="descendant::tei:origDate[@notBefore][@notAfter]">
                <xsl:value-of select="concat(descendant::tei:origDate/@notBefore, ' - ', descendant::tei:origDate/@notAfter)"/>
            </xsl:when>
            <xsl:when test="descendant::tei:origDate[@when]">
                <xsl:value-of select="descendant::tei:origDate/@when"/>
            </xsl:when>
        </xsl:choose>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;Columns = {</xsl:text>
        <xsl:value-of select="descendant::tei:layout/@columns"/>
        <xsl:text>},</xsl:text>
        <xsl:if test="descendant::tei:msContents/tei:p[node()]">
            <xsl:text>&#10;&#009;&#009;Contents = {</xsl:text>
            <xsl:apply-templates select="descendant::tei:msContents/tei:p/node()" mode="these"/>
            <xsl:text>},</xsl:text>
        </xsl:if>
        <xsl:if test="descendant::tei:witness[@facs]">
            <xsl:text>&#10;&#009;&#009;url = {</xsl:text>
            <xsl:value-of select="descendant::tei:witness/@facs"/>
            <xsl:text>},</xsl:text>
        </xsl:if>
        <xsl:text>&#10;&#009;&#009;Bookpagination = {</xsl:text>
        <xsl:choose>
            <xsl:when test="descendant::tei:foliation/@ana = '#folioté'">
                <xsl:text>folio</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>page</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;Support = {</xsl:text>
        <xsl:choose>
            <xsl:when test="descendant::tei:material/@type = 'parchemin'">
                <xsl:text>pergament</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>paper</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;Pagetotal = {</xsl:text>
        <xsl:value-of select="descendant::tei:extent/descendant::tei:measure/@quantity"/>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;Pages = {</xsl:text>
        <xsl:value-of select="
                concat(myfunctions:normalize_folios(ancestor-or-self::tei:TEI[1]/descendant::tei:pb[not(preceding::tei:pb[ancestor::tei:TEI[@xml:id = $id]])]/@n),
                '-',
                myfunctions:normalize_folios(ancestor-or-self::tei:TEI[1]/descendant::tei:pb[not(following::tei:pb[ancestor::tei:TEI[@xml:id = $id]])]/@n))"/>
        <xsl:text>},</xsl:text>
        <xsl:choose>
            <xsl:when test="ancestor::tei:TEI[1]/@xml:id = 'Rome_W'">
                <xsl:text>&#10;&#009;&#009;keywords = {lat},</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::tei:TEI[1]/@xml:id = 'Val_S'">
                <xsl:text>&#10;&#009;&#009;keywords = {mss_omega},</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#10;&#009;&#009;keywords = {mss_B},</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#10;&#009;&#009;Address = {</xsl:text>
        <xsl:value-of select="descendant::tei:settlement"/>
        <xsl:text>}&#10;}&#10;&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="tei:witness" mode="biblio_temoins_autres">
        <xsl:variable name="id">
            <xsl:value-of select="ancestor::tei:TEI[1]/@xml:id"/>
        </xsl:variable>
        <xsl:text>@manuscript{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>,&#10;&#009;&#009;shorthand = {</xsl:text>
        <xsl:value-of select="descendant::tei:msName"/>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;shelfmark = {</xsl:text>
        <xsl:value-of select="replace(descendant::tei:idno, '&amp;', concat('\\', $and))" disable-output-escaping="true"/>
        <xsl:text>},</xsl:text>
        <xsl:if test="descendant::tei:msContents/tei:p[node()]">
            <xsl:text>&#10;&#009;&#009;Contents = {</xsl:text>
            <xsl:apply-templates select="descendant::tei:msContents/tei:p/node()" mode="these"/>
            <xsl:text>},</xsl:text>
        </xsl:if>
        <xsl:if test="@facs">
            <xsl:text>&#10;&#009;&#009;url = {</xsl:text>
            <xsl:value-of select="@facs"/>
            <xsl:text>},</xsl:text>
        </xsl:if>
        <xsl:text>&#10;&#009;&#009;Bookpagination = {</xsl:text>
        <xsl:choose>
            <xsl:when test="descendant::tei:foliation/@ana = '#folioté'">
                <xsl:text>folio</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>page</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;library = {</xsl:text>
        <xsl:value-of select="descendant::tei:repository"/>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;dating = {</xsl:text>
        <xsl:choose>
            <xsl:when test="descendant::tei:origDate[@notBefore][not(@notAfter)]">
                <xsl:value-of select="concat('après ', descendant::tei:origDate/@notBefore)"/>
            </xsl:when>
            <xsl:when test="descendant::tei:origDate[not(@notBefore)][@notAfter]">
                <xsl:value-of select="concat('avant ', descendant::tei:origDate/@notAfter)"/>
            </xsl:when>
            <xsl:when test="descendant::tei:origDate[@notBefore][@notAfter]">
                <xsl:value-of select="concat(descendant::tei:origDate/@notBefore, ' - ', descendant::tei:origDate/@notAfter)"/>
            </xsl:when>
        </xsl:choose>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;columns = {</xsl:text>
        <xsl:value-of select="descendant::tei:layout/@columns"/>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;Pagetotal = {</xsl:text>
        <xsl:value-of select="descendant::tei:extent/descendant::tei:measure/@quantity"/>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;Pages = {</xsl:text>
        <xsl:value-of select="
                concat(myfunctions:normalize_folios(//tei:TEI[@xml:id = $id]/descendant::tei:pb[not(preceding::tei:pb[ancestor::tei:TEI[@xml:id = $id]])]/@n),
                '-',
                myfunctions:normalize_folios(//tei:TEI[@xml:id = $id]/descendant::tei:pb[not(following::tei:pb[ancestor::tei:TEI[@xml:id = $id]])]/@n))"/>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;Support = {</xsl:text>
        <xsl:choose>
            <xsl:when test="descendant::tei:material/@type = 'parchemin'">
                <xsl:text>pergament</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>paper</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;Address = {</xsl:text>
        <xsl:value-of select="descendant::tei:settlement"/>
        <xsl:text>},</xsl:text>
        <xsl:text>&#10;&#009;&#009;keywords = {hors_corpus}
            &#10;}&#10;&#10;</xsl:text>
    </xsl:template>

    <!--Bibliographie-->


    <xsl:function name="myfunctions:normalize_folios">
        <xsl:param name="input_string"/>
        <xsl:variable name="recto" select="replace($input_string, 'r', '\\recto')"/>
        <xsl:variable name="verso" select="replace($recto, 'v', '\\verso')"/>
        <xsl:value-of select="$verso"/>
    </xsl:function>
    <xsl:template match="tei:text | tei:head" mode="biblio_temoins_autres biblio_temoins_corpus"/>





    <!--  <xsl:template mode="these" match="tei:TEI[@xml:id = 'Sal_J']">
        <xsl:result-document href="/home/gille-levenson/Bureau/These/Edition/Edition_Pseudojeriz/Statistiques/statistiques_glose_trad_j.csv"/>
    </xsl:template>-->

    <!-- <xsl:template mode="these" match="tei:div[@xml:id = 'images_manuscrits']">
        <xsl:for-each
            select="$corpus/descendant::tei:body/descendant::tei:div[@type = 'chapitre']/descendant::tei:note[descendant::tei:figure]/descendant::tei:figure">
            <xsl:text>\begin{figure}</xsl:text>
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="descendant::tei:graphic/@url"/>
            <xsl:text>}</xsl:text>
            <xsl:text>\includegraphics{</xsl:text>
            <xsl:value-of select="descendant::tei:graphic/@url"/>
            <xsl:text>}</xsl:text>
            <xsl:text>\caption</xsl:text>
        <xsl:if test="tei:desc[@type = 'short']">
            <xsl:text>[</xsl:text>
            <xsl:apply-templates mode="these" select="tei:desc[@type = 'short']"/>
            <xsl:text>]</xsl:text>
        </xsl:if>
        <xsl:text>{</xsl:text>
            <xsl:apply-templates select="descendant::tei:desc"/>
            <xsl:text>}</xsl:text>
            <xsl:text>\end{figure}</xsl:text>
            <xsl:text>&#10;&#10;&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>-->


    <!--La partie de description de l'édition est gérée au niveau de la template racine-->
    <xsl:template match="tei:div[@xml:id = 'edition']" mode="these" priority="5"/>
    <!--La partie de description de l'édition est gérée au niveau de la template racine-->


    <xsl:template mode="these" match="tei:div[@type = 'partie']">
        <xsl:text>&#10;&#10;\part{</xsl:text>
        <xsl:apply-templates mode="these" select="tei:head"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="these" select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>

    <xsl:template mode="these" match="tei:div[@type = 'non_partie']">
        <xsl:text>&#10;&#10;\part*{</xsl:text>
        <xsl:apply-templates mode="these" select="tei:head"/>
        <xsl:text>}
        \addcontentsline{toc}{part}{</xsl:text>
        <xsl:value-of select="tei:head"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="these" select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>





    <xsl:template mode="these"
        match="tei:div[@type = 'section'][not(@xml:id = 'figures_tableaux')][not(@xml:id = 'requetes_xpath')][not(ancestor::tei:div[@xml:id = 'annexe'])]">
        <xsl:choose>
            <xsl:when test="@rend = 'unnumbered'">
                <xsl:text>&#10;\section*</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#10;\section</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="tei:head[@type = 'short']">
                <xsl:text>[</xsl:text>
                <xsl:apply-templates select="tei:head[@type = 'short']" mode="these"/>
                <xsl:text>]</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>{</xsl:text>
        <xsl:apply-templates mode="these" select="tei:head[not(@type = 'short')]"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@rend = 'unnumbered'">
            <xsl:text>% Unnumbered section&#10;\phantomsection</xsl:text>
            <xsl:text>\addcontentsline{toc}{section}{</xsl:text>
            <xsl:apply-templates mode="these" select="tei:head"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="these" select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>

    <xsl:template mode="these"
        match="tei:div[@type = 'section'][not(@xml:id = 'images_texte')][not(@xml:id = 'requetes_xpath')][not(@xml:id = 'figures_tableaux')][not(@xml:id = 'transcr_impr_latin')][ancestor::tei:div[@xml:id = 'annexe']]">
        <xsl:if test="preceding-sibling::tei:div[@type = 'section']">
            <xsl:text>\newpage</xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="@rend = 'unnumbered'">
                <xsl:text>&#10;\section*{</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#10;\section{</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates mode="these" select="tei:head"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@rend = 'unnumbered'">
            <xsl:text>% Unnumbered section&#10;</xsl:text>
            <xsl:text>\phantomsection</xsl:text>
            <xsl:text>\addcontentsline{toc}{section}{</xsl:text>
            <xsl:apply-templates mode="these" select="tei:head"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="these" select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>



    <xsl:template mode="these" match="tei:div[@xml:id = 'requetes_xpath']">
        <xsl:if test="preceding-sibling::tei:div[@type = 'section']">
            <xsl:text>\newpage</xsl:text>
        </xsl:if>
        <xsl:text>
            \chapter{</xsl:text>
        <xsl:apply-templates mode="these" select="tei:head"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>
            
        \definecolor{gray}{rgb}{0.4,0.4,0.4}
        \definecolor{darkblue}{rgb}{0.0,0.0,0.6}
        \definecolor{cyan}{rgb}{0.0,0.6,0.6}
        \lstset{frame=tb,
          language=xml,
          aboveskip=3mm,
          belowskip=3mm,
          showstringspaces=false,
          columns=flexible,
          basicstyle={\small\ttfamily},
          numbers=none,
          numberstyle=\tiny\color{gray},
          keywordstyle=\color{cyan},
          stringstyle=\color{black},
          identifierstyle=\color{darkblue},
          morekeywords={count, concat},
          breaklines=true,
          breakatwhitespace=true,
          tabsize=3
        }
        </xsl:text>
        <xsl:for-each select="descendant::tei:item[not(self::tei:head)]">
            <xsl:sort select="@xml:id"/>
            <xsl:apply-templates mode="these" select="."/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template mode="these" match="tei:div[@xml:id = 'transcr_impr_latin']">
        <xsl:text>&#10;&#10;\chapter{</xsl:text>
        <xsl:apply-templates mode="these" select="descendant::tei:head"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>\setcounter{section}{0}&#10;</xsl:text>
        <!--<xsl:text>\chapter*{Transcription de l'imprimé latin de 1607 (\textit{cura} Laura
        Albiero)}
        \phantomsection\stepcounter{chapter}\addcontentsline{toc}{chapter}{Transcription de l'imprimé latin de 1607}
        \setcounter{section}{0}</xsl:text>-->
        <xsl:apply-templates mode="these" select="descendant::tei:p"/>
        <xsl:apply-templates select="$corpus/descendant::tei:TEI[@xml:id = 'Rome_W']" mode="edition_texte_latin"/>
    </xsl:template>

    <xsl:template match="tei:div[@xml:id = 'marques_lecture']" priority="10" mode="these">
        <xsl:text>\chapter{Marques de lecture}</xsl:text>
        <xsl:text>\label{marques_lecture}</xsl:text>
        <xsl:apply-templates mode="these"/>
        <xsl:for-each select="$corpus//tei:TEI[@type = 'transcription'][descendant::tei:anchor[@type = 'marque_lecture']]">
            <xsl:variable name="witness" select="@xml:id"/>
            <xsl:variable name="sigla" select="myfunctions:witstosigla($witness)"/>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>\section{Manuscrit </xsl:text>
            <xsl:value-of select="$sigla"/>
            <xsl:text>}</xsl:text>
            <xsl:text>\label{marques_lecture_</xsl:text>
            <xsl:value-of select="lower-case($sigla)"/>
            <xsl:text>}</xsl:text>
            <xsl:text>&#10;</xsl:text>
            <xsl:for-each select="descendant::tei:anchor[@type = 'marque_lecture'][@next]">
                <xsl:variable name="type_de_marque">
                    <xsl:choose>
                        <xsl:when test="@subtype = 'souligne'">
                            <xsl:text>Texte souligné</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>Trait vertical en marge</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="id" select="@xml:id"/>
                <xsl:variable name="chapter" select="ancestor::tei:div[@type = 'chapitre']/@n"/>
                <xsl:variable name="next_anchor" select="translate(@next, '#', '')"/>
                <xsl:text>\subsection[</xsl:text>
                <xsl:text>Folio </xsl:text>
                <xsl:value-of select="preceding::tei:pb[1]/@n"/>
                <xsl:text> - chapitre </xsl:text>
                <xsl:value-of select="ancestor::tei:div[@type = 'chapitre']/@n"/>
                <xsl:text> - </xsl:text>
                <xsl:value-of select="ancestor::tei:div[1]/@type"/>
                <xsl:text>]</xsl:text>
                <xsl:text>{</xsl:text>
                <xsl:value-of select="$type_de_marque"/>
                <xsl:text> - Folio </xsl:text>
                <xsl:value-of select="preceding::tei:pb[1]/@n"/>
                <xsl:text> - chapitre </xsl:text>
                <xsl:value-of select="ancestor::tei:div[@type = 'chapitre']/@n"/>
                <xsl:text> - </xsl:text>
                <xsl:value-of select="ancestor::tei:div[1]/@type"/>
                <xsl:text>}</xsl:text>
                <xsl:text>[...] </xsl:text>

                <!--On présuppose que les marques de lecture ne courent pas d'un chapitre à l'autre-->
                <xsl:variable name="tokenized_file_path"
                    select="concat('/home/mgl/Bureau/These/Edition/collator/temoins_tokenises/', $witness, '.xml')"/>
                <xsl:apply-templates
                    select="document($tokenized_file_path)/descendant::tei:div[@type = 'chapitre'][@n = $chapter]/descendant::node()[self::tei:note or self::tei:w or self::tei:add or self::tei:pc][preceding::tei:anchor[@xml:id = $id]][following::tei:anchor[@xml:id = $next_anchor]]"
                    mode="marques_lecture">
                    <xsl:with-param name="temoin_base_citation" select="$witness" tunnel="yes"/>
                </xsl:apply-templates>
                <xsl:text> [...]</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <xsl:template mode="these" match="tei:div[@xml:id = 'comunidad_escurial_chevalerie']">
        <xsl:text>&#10;&#10;\chapter{</xsl:text>
        <xsl:apply-templates mode="these" select="descendant::tei:head"/>
        <xsl:text>}&#10;</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>\setcounter{section}{0}&#10;</xsl:text>
        <!--<xsl:text>\chapter*{Transcription de l'imprimé latin de 1607 (\textit{cura} Laura
        Albiero)}
        \phantomsection\stepcounter{chapter}\addcontentsline{toc}{chapter}{Transcription de l'imprimé latin de 1607}
        \setcounter{section}{0}</xsl:text>-->
        <xsl:apply-templates mode="these" select="descendant::tei:p"/>
        <xsl:apply-templates select="$corpus/descendant::tei:TEI[@xml:id = 'comunidad_escorial']" mode="edition_texte_latin"/>
    </xsl:template>


    <xsl:template mode="these"
        match="tei:div[@type = 'chapitre'][not(@xml:id = 'comunidad_escurial_chevalerie')][not(@xml:id = 'transcr_impr_latin')][not(@xml:id = 'images_texte')][not(@xml:id = 'figures_tableaux')][not(@xml:id = 'requetes_xpath')]">
        <xsl:text>&#10;&#10;\chapter{</xsl:text>
        <xsl:apply-templates mode="these" select="tei:head"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="these" select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>


    <xsl:template match="tei:div[@xml:id = 'seuils_colophons']" priority="10" mode="these">
        <xsl:text>\chapter{</xsl:text>
        <xsl:apply-templates select="tei:head" mode="these"/>
        <xsl:text>}</xsl:text>
        <xsl:text>\onlysideX[B]{}</xsl:text>
        <xsl:text/>
        <xsl:text>\label{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
        <xsl:apply-templates select="tei:p/node()" mode="these"/>
        <xsl:for-each select="$corpus//descendant::tei:div[@type = 'seuil']">
            <xsl:sort select="myfunctions:witstosigla(ancestor::tei:TEI[1]/@xml:id)"/>
            <xsl:variable name="corresponding_wit_id" select="ancestor::tei:TEI[1]/@xml:id"/>
            <xsl:variable name="corresponding_pb" select="preceding::tei:pb[1]/@n"/>
            <xsl:variable name="folio_or_page">
                <xsl:choose>
                    <xsl:when test="ancestor::tei:TEI[1]/descendant::tei:foliation/@ana = '#paginé'">
                        <xsl:text>p. </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>fol. </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:text>\section{</xsl:text>
            <xsl:value-of select="myfunctions:witstosigla($corresponding_wit_id)"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$folio_or_page"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$corresponding_pb"/>
            <xsl:text>}</xsl:text>

            <xsl:text>
            \begin{minipage}{0.93\textwidth}
            \begin{ledgroupsized}[c]{0.97\textwidth}
                  \beginnumbering
                  \pstart 
                  \setline{1}%&#10;</xsl:text>
            <!--<xsl:apply-templates mode="citation_apparat">
                <xsl:with-param name="temoin_base_citation" tunnel="yes" select="$corresponding_wit_id"/>
            </xsl:apply-templates>-->
            <xsl:apply-templates mode="edition">
                <xsl:with-param name="temoin_base_citation" tunnel="yes" select="$corresponding_wit_id"/>
            </xsl:apply-templates>

            <xsl:text>\pend
                        \endnumbering
                         \end{ledgroupsized}
                        \end{minipage}
                        \vspace{0.4cm}
        </xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="tei:div[@xml:id = 'images_texte']" mode="these">
        <!--Gestion des illustrations dans le texte-->
        <xsl:text>\chapter{</xsl:text>
        <xsl:apply-templates select="tei:head" mode="these"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:for-each select="document($chemin_temoin_base_edition)/descendant::tei:div[@type = 'chapitre']">
            <xsl:variable name="chapter" select="@n"/>
            <xsl:if
                test="document($chemin_temoin_base_edition)/descendant::tei:div[@type = 'chapitre'][@n = $chapter]/descendant::tei:figure | document('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan/Val_S.xml')/descendant::tei:div[@type = 'chapitre'][@n = $chapter]/descendant::tei:figure">
                <xsl:text>\section{Chapitre </xsl:text>
                <xsl:value-of select="$chapter"/>
                <xsl:text>}</xsl:text>
            </xsl:if>
            <xsl:for-each
                select="document($chemin_temoin_base_edition)/descendant::tei:div[@type = 'chapitre'][@n = $chapter]/descendant::tei:figure | document('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan/Val_S.xml')/descendant::tei:div[@type = 'chapitre'][@n = $chapter]/descendant::tei:figure">
                <xsl:variable name="id" select="@xml:id"/>
                <xsl:variable name="corresponding_page">
                    <xsl:choose>
                        <xsl:when
                            test="document('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/corpus/corpus.xml')/descendant::tei:figure[@xml:id = $id]/ancestor::tei:TEI[1]/descendant::tei:foliation[@ana = '#paginé']">
                            <xsl:text>p. </xsl:text>
                        </xsl:when>
                        <xsl:when
                            test="document('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/corpus/corpus.xml')/descendant::tei:figure[@xml:id = $id]/ancestor::tei:TEI[1]/descendant::tei:foliation[@ana = '#folioté']">
                            <xsl:text>fol. </xsl:text>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:value-of
                        select="document('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/corpus/corpus.xml')/descendant::tei:figure[@xml:id = $id]/preceding::tei:pb[1]/@n"
                    />
                </xsl:variable>
                <xsl:variable name="chapter"
                    select="document('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/corpus/corpus.xml')/descendant::tei:figure[@xml:id = $id]/ancestor::tei:div[@type = 'chapitre']/@n"/>
                <xsl:variable name="witness"
                    select="myfunctions:witstosigla(document('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/corpus/corpus.xml')/descendant::tei:figure[@xml:id = $id]/ancestor::tei:TEI[1]/@xml:id)"/>

                <!--aller chercher dans le témoin original les informations codicologiques. TODO-->
                <xsl:text>\begin{figure}[!ht]
                      \centering </xsl:text>
                <xsl:text>\includegraphics[</xsl:text>
                <xsl:text>width=.8</xsl:text>
                <xsl:text>\textwidth</xsl:text>
                <xsl:text>]{</xsl:text>
                <xsl:value-of select="@facs"/>
                <xsl:text>}</xsl:text>
                <xsl:text>\caption</xsl:text>
                <xsl:if test="tei:desc[@type = 'short']">
                    <xsl:text>[</xsl:text>
                    <xsl:apply-templates mode="these" select="tei:desc[@type = 'short']"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
                <xsl:text>{</xsl:text>
                <xsl:apply-templates mode="these" select="descendant::tei:desc[not(@type = 'short')]"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="$witness"/>
                <xsl:text>, chapitre </xsl:text>
                <xsl:value-of select="$chapter"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="$corresponding_page"/>
                <xsl:text>.}</xsl:text>
                <xsl:if test="@xml:id">
                    <xsl:text>\label{</xsl:text>
                    <xsl:value-of select="@xml:id"/>
                    <xsl:text>}</xsl:text>
                </xsl:if>
                <xsl:text>\end{figure}</xsl:text>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:text>\clearpage</xsl:text>
        <xsl:text>\chapter{Images de phénomènes propres aux témoins}</xsl:text>
        <xsl:for-each select="$corpus/descendant::tei:graphic[contains(@rend, 'annexe')][not(ancestor::tei:figure)]">
            <xsl:variable name="id" select="@xml:id"/>
            <xsl:variable name="corresponding_page">
                <xsl:choose>
                    <xsl:when test="ancestor::tei:TEI[1]/descendant::tei:foliation[@ana = '#paginé']">
                        <xsl:text>p. </xsl:text>
                    </xsl:when>
                    <xsl:when test="ancestor::tei:TEI[1]/descendant::tei:foliation[@ana = '#folioté']">
                        <xsl:text>fol. </xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of select="preceding::tei:pb[1]/@n"/>
            </xsl:variable>
            <xsl:variable name="chapter" select="ancestor::tei:div[@type = 'chapitre']/@n"/>
            <xsl:variable name="witness" select="myfunctions:witstosigla(ancestor::tei:TEI[1]/@xml:id)"/>

            <xsl:text>\begin{figure}[!htp]
            \centering</xsl:text>
            <xsl:call-template name="images"/>
            <xsl:text>\caption</xsl:text>
            <xsl:if test="tei:desc[@type = 'short']">
                <xsl:text>[</xsl:text>
                <xsl:apply-templates mode="these" select="tei:desc[@type = 'short']"/>
                <xsl:text>]</xsl:text>
            </xsl:if>
            <xsl:text>{</xsl:text>
            <xsl:apply-templates mode="these" select="tei:desc[not(@type = 'short')]"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$witness"/>
            <xsl:text>, chapitre </xsl:text>
            <xsl:value-of select="$chapter"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$corresponding_page"/>
            <xsl:text>.}</xsl:text>
            <xsl:if test="@xml:id">
                <xsl:text>\label{</xsl:text>
                <xsl:value-of select="@xml:id"/>
                <xsl:text>}</xsl:text>
            </xsl:if>
            <xsl:text>\end{figure}&#10;</xsl:text>
        </xsl:for-each>
        <xsl:text>\clearpage</xsl:text>
        <!--Puis les images prises des manuscrits-->
    </xsl:template>


    <xsl:template match="tei:div[@xml:id = 'figures_tableaux']" mode="these">
        <xsl:text>\chapter{</xsl:text>
        <xsl:apply-templates select="tei:head" mode="these"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>




        <!--Puis les images prises des manuscrits-->
        <xsl:text>\section{Figures de la thèse renvoyées en annexes}</xsl:text>
        <xsl:for-each
            select="//tei:TEI[not(@type = 'transcription')]/descendant::tei:figure[contains(@rend, 'annexe')][tei:graphic]">
            <xsl:text>\begin{figure}[!htp]
            \centering</xsl:text>
            <xsl:choose>
                <xsl:when test="self::tei:figure">
                    <xsl:apply-templates mode="these" select="tei:graphic"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="self::node()" mode="these"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>\caption</xsl:text>
            <xsl:if test="tei:desc[@type = 'short']">
                <xsl:text>[</xsl:text>
                <xsl:apply-templates mode="these" select="tei:desc[@type = 'short']"/>
                <xsl:text>]</xsl:text>
            </xsl:if>
            <xsl:text>{</xsl:text>
            <xsl:apply-templates mode="these" select="tei:desc[not(@type = 'short')]"/>
            <xsl:text>}</xsl:text>
            <xsl:if test="@xml:id">
                <xsl:text>\label{</xsl:text>
                <xsl:value-of select="@xml:id"/>
                <xsl:text>}</xsl:text>
            </xsl:if>
            <xsl:text>\end{figure}&#10;</xsl:text>
        </xsl:for-each>
        <xsl:text>\clearpage</xsl:text>





        <!--D'abord les tableaux en mode portrait-->
        <xsl:text>\section{Tableaux}</xsl:text>
        <!--On va chercher tous les enfants de cette section (qui sont des tableaux forcément)-->
        <xsl:apply-templates select="descendant::node()[not(contains(@rend, 'paysage'))]" mode="annexe"/>
        <xsl:apply-templates select="//tei:table[contains(@rend, 'annexe')][not(contains(@rend, 'paysage'))]" mode="annexe"/>
        <!--D'abord les tableaux en mode portrait-->


        <!--Puis les tableaux en mode paysages-->
        <xsl:text>
            \begin{landscape}\pagestyle{empty}</xsl:text>
        <xsl:apply-templates select="descendant::node()[contains(@rend, 'paysage')]" mode="annexe"/>
        <xsl:apply-templates select="//tei:table[contains(@rend, 'annexe')][contains(@rend, 'paysage')]" mode="annexe"/>
        <xsl:text>
        \end{landscape}\clearpage\pagestyle{commentaire}</xsl:text>
        <!--Puis les tableaux en mode paysages-->

    </xsl:template>




    <xsl:template mode="these" match="tei:div[@type = 'sous_section'][not(ancestor::tei:div[@xml:id = 'resume_outils'])]">
        <xsl:choose>
            <xsl:when test="@rend = 'unnumbered'">
                <xsl:text>&#10;\subsection*</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#10;\subsection</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="tei:head[@type = 'short']">
                <xsl:text>[</xsl:text>
                <xsl:apply-templates select="tei:head[@type = 'short']"/>
                <xsl:text>]</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>{</xsl:text>
        <xsl:apply-templates mode="these" select="tei:head[not(@type = 'short')]"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@rend = 'unnumbered'">
            <xsl:text>% Unnumbered section&#10;
                \phantomsection</xsl:text>
            <xsl:text>\addcontentsline{toc}{section}{</xsl:text>
            <xsl:apply-templates mode="these" select="tei:head"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="these" select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>

    <xsl:template mode="these" match="tei:div[@type = 'sous_section'][ancestor::tei:div[@xml:id = 'resume_outils']]">
        <xsl:text>&#10;&#10;\paragraph*{</xsl:text>
        <xsl:value-of select="tei:head"/>
        <xsl:text>}\label{</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>}</xsl:text>
        <xsl:apply-templates mode="these" select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>


    <xsl:template mode="these" match="tei:div[@type = 'sous_sous_section']">
        <xsl:text>&#10;&#10;\subsubsection</xsl:text>
        <xsl:choose>
            <xsl:when test="tei:head[@type = 'short']">
                <xsl:text>[</xsl:text>
                <xsl:apply-templates select="tei:head[@type = 'short']" mode="these"/>
                <xsl:text>]</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>{</xsl:text>
        <xsl:apply-templates mode="these" select="tei:head[not(@type = 'short')]"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="these" select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>


    <xsl:template mode="these" match="tei:div[@type = 'sous_sous_sous_section']">
        <xsl:text>&#10;&#10;\paragraph</xsl:text>
        <xsl:choose>
            <xsl:when test="tei:head[@type = 'short']">
                <xsl:text>[</xsl:text>
                <xsl:apply-templates select="tei:head[@type = 'short']" mode="these"/>
                <xsl:text>]</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>{</xsl:text>
        <xsl:apply-templates select="tei:head[not(@type = 'short')]" mode="these"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="these" select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>


    <xsl:template mode="these" match="tei:div[@type = 'sous_sous_sous_sous_section']">
        <xsl:text>&#10;&#10;\subparagraph</xsl:text>
        <xsl:choose>
            <xsl:when test="tei:head[@type = 'short']">
                <xsl:text>[</xsl:text>
                <xsl:apply-templates select="tei:head[@type = 'short']" mode="these"/>
                <xsl:text>]</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>{</xsl:text>
        <xsl:apply-templates select="tei:head[not(@type = 'short')]" mode="these"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="these" select="child::tei:*[not(self::tei:head)]"/>
    </xsl:template>


    <xsl:template mode="these" match="tei:div[@xml:id = 'remerciements']">
        <xsl:text>&#10;&#10;\section{Remerciements}&#10;&#10;</xsl:text>
        <xsl:text>Mes remerciements à </xsl:text>
        <xsl:apply-templates mode="these" select="tei:p"/>
        <xsl:for-each select="descendant::tei:item">
            <xsl:value-of select="."/>
            <xsl:choose>
                <xsl:when test="following-sibling::tei:item">
                    <xsl:text>, </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>.</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>


    <xsl:template mode="these" match="tei:formula[@notation = 'variable']">
        <xsl:text>\textit{</xsl:text>
        <xsl:apply-templates mode="these"/>
        <xsl:text>}</xsl:text>
    </xsl:template>



    <xsl:template mode="these" match="tei:formula[@notation = 'tex']">
        <xsl:choose>
            <xsl:when test="@rend = 'inline'">
                <xsl:text>$</xsl:text>
                <xsl:apply-templates mode="these"/>
                <xsl:text>$</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\begin{displaymath}</xsl:text>
                <xsl:apply-templates mode="these"/>
                <xsl:text>\end{displaymath}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template mode="these annexe" match="tei:ptr[@type = 'inclusion']">
        <xsl:choose>
            <!--Si le parent est du code, qu'on veut faire apparaître, il faut parser un fichier en mode texte-->
            <xsl:when test="ancestor::tei:code">
                <xsl:text>\lstinputlisting[caption=</xsl:text>
                <xsl:value-of select="ancestor::tei:code/tei:desc"/>
                <xsl:text>, style=custom]{</xsl:text>
                <xsl:value-of select="@target"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\input{</xsl:text>
                <xsl:value-of select="@target"/>
                <xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="these" match="tei:quote[not(attribute())]">
        <xsl:text>\enquote{</xsl:text>
        <xsl:apply-templates mode="these"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template mode="these" match="tei:quote[@type = 'traduction']">
        <xsl:text>\enquote{</xsl:text>
        <xsl:apply-templates mode="these"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template mode="these edition"
        match="tei:quote[@type = 'secondaire'][ancestor::tei:note][not(@subtype = 'vers') and not(@subtype = 'diplomatique')]">
        <xsl:variable name="threshold">300</xsl:variable>
        <xsl:variable name="langue" select="myfunctions:iso_lang_to_language(@xml:lang)"/>
        <xsl:choose>
            <xsl:when test="$langue = 'french'">
                <xsl:choose>
                    <xsl:when test="string-length(string-join(child::text())) &gt; $threshold and not(@rend = 'inline')">
                        <xsl:text>\begin{quote}</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text> \end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length(string-join(child::text())) > $threshold and not(@rend = 'inline')">
                        <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}\end{otherlanguage}\end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\foreignquote{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}{\textit{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="these edition"
        match="tei:quote[@type = 'secondaire'][not(ancestor::tei:note)][not(@subtype = 'vers') and not(@subtype = 'diplomatique')]">
        <xsl:variable name="threshold">200</xsl:variable>
        <xsl:variable name="langue" select="myfunctions:iso_lang_to_language(@xml:lang)"/>
        <xsl:choose>
            <xsl:when test="$langue = 'french'">
                <xsl:choose>
                    <xsl:when test="not(@rend = 'inline') and string-length(.) &gt; $threshold">
                        <xsl:text>\begin{quote}</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text> \end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="not(@rend = 'inline') and string-length(string-join(descendant::text())) > $threshold">
                        <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}\end{otherlanguage}\end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\foreignquote{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}{\textit{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>&#10; </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="these edition"
        match="tei:quote[@type = 'primaire'][not(parent::tei:note)][not(@subtype = 'vers') and not(@subtype = 'diplomatique')]">
        <xsl:variable name="threshold">200</xsl:variable>
        <xsl:variable name="langue" select="myfunctions:iso_lang_to_language(@xml:lang)"/>
        <xsl:choose>
            <xsl:when test="$langue = 'french'">
                <xsl:choose>
                    <xsl:when test="ancestor::tei:table[@rend = 'cote_a_cote']">
                        <xsl:apply-templates mode="these"/>
                    </xsl:when>
                    <xsl:when test="not(ancestor::tei:table[@rend = 'cote_a_cote']) and @rend = 'bloc'">

                        <xsl:text>\begin{quote}</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text> \end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="not(ancestor::tei:table[@rend = 'cote_a_cote']) and string-length(replace(string-join(child::text()), '\s+', ' ')) > $threshold">
                        <!--Ici on ne tient pas en compte les notes éventuelles: on veut calculer la taille de la citation uniquement.-->
                        <xsl:text>\begin{quote}</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text> \end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="ancestor::tei:table[@rend = 'cote_a_cote']">
                        <xsl:text>\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}\end{otherlanguage}</xsl:text>
                    </xsl:when>
                    <xsl:when test="not(ancestor::tei:table[@rend = 'cote_a_cote']) and @rend = 'bloc'">

                        <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}\end{otherlanguage}\end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="not(ancestor::tei:table[@rend = 'cote_a_cote']) and string-length(replace(string-join(child::text()), '\s+', ' ')) > $threshold">
                        <!--String-length n'ignore pas les espaces multiples causés par l'indentation...-->
                        <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}\end{otherlanguage}\end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\foreignquote{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}{\textit{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="these"
        match="tei:quote[@type = 'corpus'][not(parent::tei:note)][not(@subtype = 'vers') and not(@subtype = 'diplomatique')]">
        <xsl:variable name="threshold">50</xsl:variable>
        <xsl:variable name="langue" select="myfunctions:iso_lang_to_language(@xml:lang)"/>
        <xsl:choose>
            <xsl:when test="$langue = 'french'">
                <xsl:choose>
                    <xsl:when test="string-length(replace(string-join(child::text()), '\s+', ' ')) > $threshold">
                        <!--Ici on ne tient pas en compte les notes éventuelles: on veut calculer la taille de la citation uniquement.-->
                        <xsl:text>\begin{quote}</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text> \end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when
                        test="string-length(replace(string-join(descendant::text()[not(ancestor-or-self::tei:ref)]), '\s+', ' ')) > $threshold">
                        <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>\end{otherlanguage}\end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>\end{otherlanguage}}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template mode="these edition"
        match="tei:quote[@type = 'primaire'][not(parent::tei:note)][@subtype = 'vers' or @subtype = 'diplomatique']">
        <xsl:text>\begin{adjustwidth}{4.5cm}{2cm}</xsl:text>
        <xsl:variable name="langue" select="myfunctions:iso_lang_to_language(@xml:lang)"/>
        <xsl:choose>
            <xsl:when test="$langue = 'french'">
                <xsl:choose>
                    <xsl:when test="string-length(replace(string-join(child::text()), '\s+', ' ')) > 200">
                        <xsl:text>\begin{quote}</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text> \end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length(replace(string-join(child::text()), '\s+', ' ')) > 200">
                        <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}\end{otherlanguage}\end{quote}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\foreignquote{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}{\textit{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>\end{adjustwidth}</xsl:text>
    </xsl:template>

    <xsl:template mode="these" match="tei:lg">
        <xsl:apply-templates mode="these"/>
    </xsl:template>


    <xsl:template mode="these edition" match="tei:quote[@type = 'primaire'][parent::tei:note]">
        <xsl:variable name="threshold">130</xsl:variable>
        <xsl:variable name="langue" select="myfunctions:iso_lang_to_language(@xml:lang)"/>
        <xsl:choose>
            <xsl:when test="$langue != 'french'">
                <xsl:choose>
                    <xsl:when test="ancestor::tei:note[@type = 'sources'] and not(@rend = 'inline')">
                        <xsl:choose>
                            <xsl:when
                                test="string-length(replace(string-join(descendant::text()[not(ancestor-or-self::tei:ref)]), '\s+', ' ')) &lt; $threshold">
                                <xsl:text>\foreignquote{</xsl:text>
                                <xsl:value-of select="$langue"/>
                                <xsl:text>}{\textit{</xsl:text>
                                <xsl:apply-templates mode="#current"/>
                                <xsl:text>}}</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                                <xsl:value-of select="$langue"/>
                                <xsl:text>}\textit{</xsl:text>
                                <xsl:apply-templates mode="#current"/>
                                <xsl:text>}\end{otherlanguage}\end{quote}</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="not(child::tei:l) or @rend = 'inline'">
                        <xsl:text>\foreignquote{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}{\textit{</xsl:text>
                        <xsl:apply-templates mode="#current"/>
                        <xsl:text>}}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\begin{quote}\begin{otherlanguage}{</xsl:text>
                        <xsl:value-of select="$langue"/>
                        <xsl:text>}\textit{</xsl:text>
                        <xsl:apply-templates mode="#current"/>
                        <xsl:text>}\end{otherlanguage}\end{quote}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="not(child::tei:l)">
                        <xsl:text>\enquote{</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\begin{quote}</xsl:text>
                        <xsl:apply-templates mode="these"/>
                        <xsl:text>\end{quote}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template mode="these" match="tei:soCalled">
        <xsl:text>\enquote{</xsl:text>
        <xsl:apply-templates mode="these"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template mode="these" match="tei:list[not(ancestor::tei:div[@xml:id = 'requetes_xpath'])][not(@rend = 'enumerated')]">
        <xsl:variable name="env">
            <xsl:choose>
                <xsl:when test="@rend = 'inline'">
                    <xsl:text>inparaenum</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="option"/>
                    <xsl:text>itemize</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="option">
            <xsl:choose>
                <xsl:when test="@rend = 'inline'">
                    <xsl:text>[1)]</xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>


        <xsl:text>\begin{</xsl:text>
        <xsl:value-of select="$env"/>
        <xsl:text>}</xsl:text>
        <xsl:value-of select="$option"/>
        <xsl:for-each select="tei:item">
            <xsl:text> \item </xsl:text>
            <xsl:apply-templates mode="these" select="."/>
        </xsl:for-each>
        <xsl:text>\end{</xsl:text>
        <xsl:value-of select="$env"/>
        <xsl:text>}</xsl:text>
    </xsl:template>


    <xsl:template mode="these" match="tei:list[not(ancestor::tei:div[@xml:id = 'requetes_xpath'])][@rend = 'enumerated']">
        <xsl:text>\begin{enumerate}</xsl:text>
        <xsl:for-each select="tei:item">
            <xsl:text>\item </xsl:text>
            <xsl:apply-templates mode="these" select="."/>
        </xsl:for-each>
        <xsl:text>\end{enumerate}</xsl:text>
    </xsl:template>

    <xsl:template mode="these" match="tei:div[@xml:id = 'PUIRiBQepM']">
        <xsl:text>\includepdf[scale=1]{../tableau_resume.pdf}</xsl:text>
    </xsl:template>

    <xsl:template mode="these" match="tei:foreign[parent::tei:quote]">
        <xsl:choose>
            <xsl:when test="not(contains(., ' '))">
                <xsl:text>\textit{</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="langue">
                    <xsl:choose>
                        <xsl:when test="@xml:lang = 'la'">latin</xsl:when>
                        <xsl:when test="@xml:lang = 'en'">english</xsl:when>
                        <xsl:otherwise>spanish</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:text>\begin{otherlanguage}{</xsl:text>
                <xsl:value-of select="$langue"/>
                <xsl:text>}\textit{</xsl:text>
                <xsl:apply-templates mode="these"/>
                <xsl:text>}\end{otherlanguage}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="these" match="tei:l">
        <xsl:apply-templates mode="these"/>
        <xsl:choose>
            <xsl:when test="following-sibling::tei:l">
                <xsl:text>~\\</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>


    <xsl:template mode="these" match="tei:figure[tei:table][not(contains(@rend, 'annexe'))]">
        <xsl:text>
        \begin{figure}</xsl:text>
        <xsl:if test="not(contains(@rend, 'float'))">
            <xsl:text>[!htp]</xsl:text>
        </xsl:if>
        <xsl:text>\centering</xsl:text>
        <xsl:apply-templates mode="these" select="node()[not(self::tei:desc)]"/>
        <xsl:if test="descendant::tei:desc[descendant::tei:code]">
            <!--https://tex.stackexchange.com/a/8814-->
            <xsl:text>\cprotect</xsl:text>
        </xsl:if>
        <xsl:text>\caption</xsl:text>
        <xsl:if test="tei:desc[@type = 'short']">
            <xsl:text>[</xsl:text>
            <xsl:apply-templates mode="these" select="tei:desc[@type = 'short']"/>
            <xsl:text>]</xsl:text>
        </xsl:if>
        <xsl:text>{</xsl:text>
        <xsl:apply-templates mode="these" select="tei:desc[not(@type = 'short')]"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>\end{figure}</xsl:text>
        <xsl:if test="descendant::tei:note">
            <xsl:for-each select="descendant::tei:note">
                <xsl:text>\footnotetext{</xsl:text>
                <xsl:apply-templates mode="these"/>
                <xsl:text>}</xsl:text>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:g" mode="#all">
        <xsl:text>\textbf{</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template mode="these" match="tei:figure[not(@rend = 'cote_a_cote')][tei:graphic][not(@rend = 'annexe')]">
        <xsl:text>
        \begin{figure}[!htp]
        \centering</xsl:text>
        <xsl:for-each select="tei:graphic">
            <xsl:apply-templates mode="these" select="."/>
            <xsl:if test="following-sibling::tei:graphic">
                <xsl:text>\hspace{.1cm}</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:if test="descendant::tei:desc[descendant::tei:code]">
            <!--https://tex.stackexchange.com/a/8814-->
            <xsl:text>\cprotect</xsl:text>
        </xsl:if>
        <xsl:text>\caption</xsl:text>
        <xsl:if test="tei:desc[@type = 'short']">
            <xsl:text>[</xsl:text>
            <xsl:apply-templates select="tei:desc[@type = 'short']" mode="these"/>
            <xsl:text>]</xsl:text>
        </xsl:if>
        <xsl:text>{</xsl:text>
        <xsl:apply-templates mode="these" select="tei:desc[not(@type = 'short')]"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>\end{figure}</xsl:text>
    </xsl:template>


    <xsl:template mode="these"
        match="tei:figure[not(@rend = 'cote_a_cote')][not(tei:table)][not(tei:graphic)][not(@rend = 'annexe')]">
        <xsl:text>
        \begin{figure}[!htp]
        \centering</xsl:text>
        <xsl:apply-templates mode="these" select="node()[not(self::tei:desc)]"/>
        <xsl:if test="descendant::tei:desc[descendant::tei:code]">
            <!--https://tex.stackexchange.com/a/8814-->
            <xsl:text>\cprotect</xsl:text>
        </xsl:if>
        <xsl:text>\caption</xsl:text>
        <xsl:if test="descendant::tei:desc[@type = 'short']">
            <xsl:text>[</xsl:text>
            <xsl:apply-templates mode="these" select="descendant::tei:desc[@type = 'short']"/>
            <xsl:text>]</xsl:text>
        </xsl:if>
        <xsl:text>{</xsl:text>
        <xsl:apply-templates mode="these" select="tei:desc[not(@type = 'short')]"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>\end{figure}</xsl:text>
    </xsl:template>


    <xsl:template mode="these" match="tei:figure[@rend = 'cote_a_cote'][not(@rend = 'annexe')]">
        <xsl:text>\begin{figure}[!htb]</xsl:text>
        <xsl:text>\centering</xsl:text>
        <xsl:for-each select="tei:graphic">
            <xsl:text>
        \begin{minipage}{.4\textwidth}
        \centering
        </xsl:text>
            <xsl:text>\includegraphics[</xsl:text>
            <xsl:choose>
                <xsl:when test="@scale">
                    <xsl:text>width=</xsl:text>
                    <xsl:value-of select="@scale"/>
                    <xsl:text>\linewidth,</xsl:text>
                </xsl:when>
                <xsl:when test="not(@width)">
                    <xsl:text>width=0.5\linewidth</xsl:text>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="@width">
                <xsl:text>width=</xsl:text>
                <xsl:value-of select="@width"/>
                <xsl:text>\textwidth,</xsl:text>
            </xsl:if>
            <xsl:if test="@angle">
                <xsl:text>,angle={</xsl:text>
                <xsl:value-of select="@angle"/>
                <xsl:text>},</xsl:text>
            </xsl:if>
            <xsl:if test="@crop">
                <xsl:text>,trim={</xsl:text>
                <xsl:value-of select="@crop"/>
                <xsl:text>}, clip</xsl:text>
            </xsl:if>
            <xsl:text>]</xsl:text>
            <xsl:text>{</xsl:text>
            <xsl:value-of select="@url"/>
            <xsl:text>}
            <!--https://tex.stackexchange.com/a/210733-->
                \captionsetup{justification=centering}</xsl:text>
            <xsl:if test="tei:desc">
                <xsl:text>\captionof{figure}</xsl:text>
                <xsl:if test="tei:desc[@type = 'short']">
                    <xsl:text>[</xsl:text>
                    <xsl:apply-templates select="tei:desc[@type = 'short']" mode="these"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
                <xsl:text>{</xsl:text>
                <xsl:apply-templates mode="these" select="tei:desc[not(@type = 'short')]"/>
                <xsl:text>}</xsl:text>
                <xsl:text><!--\captionlistentry{} -->\label{</xsl:text>
                <xsl:value-of select="ancestor::tei:figure/@xml:id"/>
                <xsl:text>}</xsl:text>
            </xsl:if>
            <xsl:text>\end{minipage}</xsl:text>
        </xsl:for-each>
        <xsl:if test="tei:desc">
            <xsl:text>\caption{</xsl:text>
            <xsl:apply-templates mode="these" select="tei:desc[not(@type = 'short')]"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>\end{figure}</xsl:text>
        <xsl:if test="descendant::tei:note">
            <xsl:for-each select="descendant::tei:note">
                <xsl:text>\footnotetext{</xsl:text>
                <xsl:apply-templates mode="these"/>
                <xsl:text>}</xsl:text>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>


    <xsl:template mode="these" match="tei:table[@rend = 'cote_a_cote']">
        <xsl:text>\vspace{.5cm}\par
                \sidebyside[.47]
            </xsl:text>
        <xsl:for-each select="descendant::tei:quote">
            <xsl:text>{</xsl:text>
            <xsl:apply-templates select="." mode="these"/>
            <xsl:text>}</xsl:text>
        </xsl:for-each>
        <xsl:text>\vspace{.5cm}\par\noindent 
        </xsl:text>
    </xsl:template>





    <xsl:template mode="these" match="tei:foreign[not(parent::tei:quote)]">
        <xsl:text>\textit{</xsl:text>
        <xsl:apply-templates mode="these"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <!--Gestion des notes de bas de page2: fonctionne bien si on crée un document unique.
    À modifier si on veut inclure le tableau dans le document de thèse.-->
    <xsl:template mode="these" match="tei:note[ancestor::tei:div[@type = 'resume_par_chapitre']]">
        <xsl:text>\footnotemark </xsl:text>
    </xsl:template>
    <!--Gestion des notes de bas de page: fonctionne bien si on crée un document unique-->


    <xsl:template mode="these" match="tei:note[not(ancestor::tei:*[@xml:lang != 'fr'])]">
        <xsl:text>\footnote{</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="these"/>
        <xsl:text>}</xsl:text>
    </xsl:template>


    <!--Éviter d'avoir des notes de bas de page avec règles en anglais ou en espagnol-->
    <xsl:template mode="these" match="tei:note[ancestor::tei:*[@xml:lang != 'fr']]">
        <xsl:text>\footnote{\begin{otherlanguage}{french}</xsl:text>
        <xsl:apply-templates mode="these"/>
        <xsl:text>\end{otherlanguage}}</xsl:text>
    </xsl:template>

    <xsl:template mode="these" match="tei:choice">
        <xsl:apply-templates mode="these" select="tei:reg | tei:expan"/>
    </xsl:template>

    <xsl:template mode="these" match="tei:expan[ancestor::tei:quote[@type = 'primaire']]">
        <xsl:text>\textit{</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>}</xsl:text>
    </xsl:template>


    <xsl:template match="tei:code[@type = 'last_revision']" mode="these">
        <xsl:text>\href[pdfnewwindow=true]{https://gitlab.huma-num.fr/mgillelevenson/hyperregimiento-de-los-principes/-/tree/</xsl:text>
        <xsl:value-of select="substring(//tei:p[@xml:id = 'dernier_commit']/@n, 0, 10)"/>
        <xsl:text>}{</xsl:text>
        <xsl:value-of select="substring(//tei:p[@xml:id = 'dernier_commit']/@n, 0, 8)"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template mode="these edition" match="tei:code[contains(@rend, 'show')][not(@type = 'last_revision')]">
        <!--À revoir plus tard à tête reposée-->
        <!--<xsl:text>\codeword{</xsl:text>
        <!-\-On supprime les espaces surnuméraires qui forment un saut de ligne 
            d'une façon ou d'une autre. codeword (verbatim) n'acceptent que des éléments en ligne.-\->
        <xsl:value-of select="replace(., '\s+', ' ')"/>
        <xsl:text>}</xsl:text>-->

        <xsl:choose>
            <xsl:when test="contains(@rend, 'long')">
                <xsl:apply-templates mode="these"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\textnormal{\texttt{\frenchspacing </xsl:text>
                <xsl:value-of select="myfunctions:escape_code(.)" disable-output-escaping="yes"/>
                <xsl:text>}}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!--<xsl:template mode="these" match="tei:code[parent::tei:note]">
        <!-\-À revoir plus tard à tête reposée-\->
        <xsl:text>\texttt{</xsl:text>
        <!-\-On supprime les espaces surnuméraires qui forment un saut de ligne 
            d'une façon ou d'une autre. codeword (verbatim) n'acceptent que des éléments en ligne.-\->
        <xsl:value-of select="myfunctions:escape_code(.)" disable-output-escaping="yes"/>
        <xsl:text>}</xsl:text>
    </xsl:template>-->




    <xsl:template mode="these" match="tei:item[ancestor::tei:div[@xml:id = 'requetes_xpath']]">
        <xsl:text>\begin{absolutelynopagebreak}
            \noindent\textbf{</xsl:text>
        <xsl:value-of select="tei:title"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="@xml:id">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@xml:id"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>\begin{lstlisting}
        </xsl:text>
        <xsl:apply-templates mode="these" select="replace(descendant::tei:code, '\s+', ' ')"/>
        <xsl:text>
            \end{lstlisting}
            \textit{
        </xsl:text>
        <xsl:apply-templates mode="these" select="tei:desc"/>
        <xsl:text>}
            \end{absolutelynopagebreak}~\newline</xsl:text>
    </xsl:template>





    <xsl:template mode="these" match="tei:code[@lang = 'xpath'][@rend = 'execute']">
        <!--Voir avec xsl:evaluate si on peut se passer de python-->
        <xsl:variable name="base">
            <xsl:choose>
                <xsl:when test="@xml:base">
                    <xsl:value-of select="@xml:base"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ancestor::node()[self::tei:p[@xml:base] or self::tei:div[@xml:base]][1]/@xml:base"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="preceding-base">
            <xsl:choose>
                <xsl:when test="preceding::tei:code[@lang = 'xpath'][@type = 'execute'][1][@xml:base]">
                    <xsl:value-of select="preceding::tei:code[@lang = 'xpath'][@type = 'execute'][1][@xml:base]/@xml:base"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="preceding::tei:code[@lang = 'xpath'][@type = 'execute'][1]/ancestor::node()[self::tei:p[@xml:base] or self::tei:div[@xml:base]][1]/@xml:base"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!--Si la requête précédente concerne le même fichier-->
            <xsl:when test="$base eq $preceding-base">
                <xsl:value-of select="."/>
                <!--<xsl:text>\footnote{Expression xpath \hyperref[</xsl:text>
                <xsl:value-of select="translate(@corresp, '#', '')"/>
                <xsl:text>]{en annexe}, évaluée sur le même fichier.}</xsl:text>-->
            </xsl:when>
            <!--Si la requête précédente concerne le même fichier-->
            <xsl:otherwise>
                <xsl:value-of select="."/>
                <!--<xsl:text>\footnote{Expression xpath \hyperref[</xsl:text>
                <xsl:value-of select="translate(@corresp, '#', '')"/>
                <xsl:text>]{en annexe}</xsl:text>
                <xsl:choose>
                    <xsl:when test="@xml:base">
                        <!-\-https://stackoverflow.com/a/8136129-\->
                        <xsl:variable name="unescaped_basename" select="tokenize(@xml:base, '/')[last()]"/>
                        <xsl:text>, évaluée sur \href{</xsl:text>
                        <xsl:value-of select="replace(@xml:base, '_', '\\_')"/>
                        <xsl:text>}{\mintinline{XML}{</xsl:text>
                        <xsl:choose>
                            <xsl:when test="contains(@xml:base, 'temoins_tokenises')">
                                <xsl:value-of select="$unescaped_basename"/>
                                <xsl:text>} tokénisé</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(@xml:base, 'temoins')">
                                <xsl:value-of select="$unescaped_basename"/>
                                <xsl:text>} édité</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(@xml:base, 'analyse_linguistique')">
                                <xsl:value-of select="$unescaped_basename"/>
                                <xsl:text>} diplomatique</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-\-https://stackoverflow.com/a/8136129-\->
                        <xsl:variable name="unescaped_full-uri"
                            select="ancestor::node()[self::tei:p[@xml:base] or self::tei:div[@xml:base]][1]/@xml:base"/>
                        <xsl:variable name="escaped_full-uri"
                            select="replace($unescaped_full-uri, '_', '\\_')"/>
                        <xsl:variable name="unescaped_basename"
                            select="tokenize(ancestor::node()[self::tei:p[@xml:base] or self::tei:div[@xml:base]][1]/@xml:base, '/')[last()]"/>
                        <xsl:text>, évaluée sur:  \href{</xsl:text>
                        <xsl:value-of select="$escaped_full-uri"/>
                        <xsl:text>}{\mintinline{XML}{</xsl:text>
                        <xsl:choose>
                            <xsl:when test="contains($unescaped_full-uri, 'temoins_tokenises')">
                                <xsl:value-of select="$unescaped_basename"/>
                                <xsl:text>} tokénisé</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($unescaped_full-uri, 'temoins')">
                                <xsl:value-of select="$unescaped_basename"/>
                                <xsl:text>} édité</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($unescaped_full-uri, 'analyse_linguistique')">
                                <xsl:value-of select="$unescaped_basename"/>
                                <xsl:text>} diplomatique</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>.}</xsl:text>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="these" match="tei:ab">
        <xsl:apply-templates mode="these"/>
    </xsl:template>


    <xsl:template mode="these" match="tei:orig">
        <xsl:apply-templates mode="these"/>
    </xsl:template>

    <xsl:template mode="these" match="tei:p[not(ancestor::teiExample:egXML)]">
        <xsl:text>&#10;\par </xsl:text>
        <xsl:if test="contains(@rend, 'sans_indentation')">
            <xsl:text>\noindent </xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="these"/>
    </xsl:template>







    <xsl:template mode="these" match="tei:fw | tei:teiHeader"/>

    <xsl:template mode="these" match="tei:head">
        <!--<xsl:text>~~</xsl:text>-->
        <xsl:apply-templates mode="these"/>
    </xsl:template>

    <xsl:template mode="these" match="tei:ref[@type = 'document_exterieur']">
        <xsl:text>\color{blue}</xsl:text>
        <xsl:value-of select="replace(replace(@target, '_', '\\_'), '../../../', '')"/>
        <xsl:text>\color{black}</xsl:text>
    </xsl:template>


    <xsl:template mode="these" match="tei:ref[@type = 'edition']">
        <!--Créer une règle pour gérer les multiples appels de références, avec un analyse-string-->
        <xsl:text>OBSOLÈTE, CHANGER ICI LE TYPE DE REFERENCE</xsl:text>
    </xsl:template>


    <xsl:template mode="#all" match="tei:ref[@type = 'chapitre']">
        <xsl:variable name="target" select="translate(@target, '#', '')"/>
        <!--Créer une règle pour gérer les multiples appels de références, avec un analyse-string-->
        <xsl:text>\hyperref[chapter:</xsl:text>
        <xsl:value-of select="$target"/>
        <xsl:text>]{chapitre </xsl:text>
        <xsl:value-of select="$target"/>
        <xsl:text>}, page \pageref{</xsl:text>
        <xsl:text>chapter:</xsl:text>
        <xsl:value-of select="$target"/>
        <xsl:text>}</xsl:text>
    </xsl:template>




    <xsl:template mode="these" match="tei:ref[@type = 'biblio'][not(@rend)]">
        <xsl:if test="preceding::node()[1][self::tei:quote]">
            <xsl:text>~</xsl:text>
        </xsl:if>
        <xsl:if test="parent::tei:quote[@xml:lang][not(@xml:lang = 'fr')]">
            <xsl:text>{\normalfont\begin{otherlanguage}{french}</xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="ancestor::tei:note or ancestor::tei:desc or ancestor::tei:head">
                <xsl:if test="ancestor::tei:desc">
                    <xsl:text>\protect </xsl:text>
                </xsl:if>
                <xsl:text>\cite</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::tei:table[@rend = 'cote_a_cote']">
                <xsl:text>[\cite</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::tei:quote and not(node())">
                <xsl:text>\footcite</xsl:text>
            </xsl:when>
            <xsl:when test="node()">
                <xsl:text>\footnote{\cite</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="not(@subtype = 'manuscrit')">
                    <xsl:text>[</xsl:text>
                </xsl:if>
                <xsl:text>\cite</xsl:text>
            </xsl:otherwise>
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
            <!--<xsl:when test="node() and not(ancestor::tei:note)">-->
            <xsl:when test="node() and not(ancestor::tei:note)">
                <xsl:text>, </xsl:text>
                <xsl:apply-templates mode="these"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:when test="node() and ancestor::tei:note">
                <xsl:text>, </xsl:text>
                <xsl:apply-templates mode="these"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if
            test="not(node() | ancestor::tei:note | ancestor::tei:quote | ancestor::tei:desc | ancestor::tei:head | ancestor::tei:table[@rend = 'cote_a_cote']) and not(@subtype = 'manuscrit')">
            <xsl:text>]</xsl:text>
        </xsl:if>
        <xsl:if test="parent::tei:quote[@xml:lang][not(@xml:lang = 'fr')]">
            <xsl:text>\end{otherlanguage}}</xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template match="tei:val" mode="#all">
        <xsl:text>`</xsl:text>
        <xsl:apply-templates mode="#current"/>
        <xsl:text>'</xsl:text>
    </xsl:template>

    <xsl:template mode="these" match="tei:ref[@type = 'biblio'][@rend = 'print_title']">
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
                    <xsl:apply-templates mode="these" select="@n"/>
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
                    <xsl:apply-templates mode="these" select="@n"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
                <xsl:text>{</xsl:text>
                <xsl:value-of select="translate(translate(@target, ' ', ','), '#', '')"/>
                <xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template mode="these" match="tei:ref[@type = 'biblio'][@rend = 'full']">
        <!--Créer une règle pour gérer les multiples appels de références, avec un analyse-string-->
        <xsl:choose>
            <xsl:when test="parent::tei:note">
                <xsl:text>\fullcite</xsl:text>
                <xsl:if test="@n">
                    <xsl:text>[</xsl:text>
                    <xsl:apply-templates mode="these" select="@n"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
                <xsl:text>{</xsl:text>
                <xsl:value-of select="translate(translate(@target, ' ', ','), '#', '')"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\footfullcite</xsl:text>
                <xsl:if test="@n">
                    <xsl:text>[</xsl:text>
                    <xsl:apply-templates mode="these" select="@n"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
                <xsl:text>{</xsl:text>
                <xsl:value-of select="translate(translate(@target, ' ', ','), '#', '')"/>
                <xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template mode="these" match="teiExample:*[ancestor::teiExample:egXML]">
        <!--Gestion des noeud teiExample > on supprime le préfixe et on imprime tel quel-->
        <!--Il reste à gérer l'indentation pour un résultat correct sur le pdf-->
        <xsl:element name="{local-name()}">
            <xsl:apply-templates mode="these"/>
        </xsl:element>
    </xsl:template>




    <xsl:template mode="these" match="teiExample:egXML">
        <xsl:text>
            \usemintedstyle{friendly}
            \begin{minted}[bgcolor=grisclair,
            frame=single,
            framesep=10pt,
            breaklines=true, 
            breakindent=.1cm,
            breakautoindent=false, 
            breaksymbolleft= ,
            breaksymbolright= ,
            breakafter=>]{xml}
        </xsl:text>
        <xsl:copy-of select="node()" copy-namespaces="false"/>
        <xsl:text>
            \end{minted}
        </xsl:text>
    </xsl:template>

    <xsl:template mode="these" match="tei:title[not(@type) or @type = 'programme']">
        <xsl:choose>
            <xsl:when test="not(ancestor::tei:quote[@xml:lang != 'fra'])">
                <xsl:text>\textit{</xsl:text>
                <xsl:if test="@xml:lang">
                    <xsl:text>\begin{otherlanguage}{</xsl:text>
                    <xsl:value-of select="myfunctions:iso_lang_to_language(@xml:lang)"/>
                    <xsl:text>}</xsl:text>
                </xsl:if>
                <xsl:apply-templates mode="these"/>
                <xsl:if test="@xml:lang">
                    <xsl:text>\end{otherlanguage}</xsl:text>
                </xsl:if>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\textnormal{</xsl:text>
                <xsl:apply-templates mode="edition"/>
                <xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




    <xsl:template mode="these" match="tei:title[@type = 'article'] | tei:title[@type = 'section'] | tei:title[@type = 'journal']">
        <xsl:text>\enquote{</xsl:text>
        <xsl:if test="@xml:lang">
            <xsl:text>\begin{otherlanguage}{</xsl:text>
            <xsl:value-of select="myfunctions:iso_lang_to_language(@xml:lang)"/>
            <xsl:text>}\textit{</xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="these"/>
        <xsl:if test="@xml:lang">
            <xsl:text>}\end{otherlanguage}</xsl:text>
        </xsl:if>
        <xsl:text>}</xsl:text>
    </xsl:template>


    <xsl:template mode="these" match="tei:ref[@type = 'interne'][@rend = 'numero']">
        <xsl:variable name="target" select="translate(@target, '#', '')"/>
        <xsl:text>\ref{</xsl:text>
        <xsl:value-of select="$target"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template mode="these" match="tei:ref[@type = 'interne'][@rend = 'page']">
        <xsl:variable name="target" select="translate(@target, '#', '')"/>
        <xsl:text>p. \pageref{</xsl:text>
        <xsl:value-of select="$target"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template mode="#all" match="tei:ref[@type = 'interne'][not(@rend = 'numero') and not(@rend = 'page')]">
        <xsl:variable name="target" select="translate(@target, '#', '')"/>
        <xsl:choose>
            <xsl:when test="not(document($corpus_path)/descendant::node()[@xml:id = $target])">
                <xsl:choose>
                    <xsl:when test="document($corpus_path)//tei:p[@n = $target]">
                        <xsl:text>page \edpageref{</xsl:text>
                        <xsl:value-of select="$target"/>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\vref{</xsl:text>
                        <xsl:value-of select="$target"/>
                        <xsl:text>}</xsl:text>
                        <!--<xsl:text>, p. \pageref{</xsl:text>
                        <xsl:value-of select="$target"/>
                        <xsl:text>}</xsl:text>-->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="not(document($corpus_path)//tei:*[@xml:id = $target][ancestor-or-self::tei:figure])">
                <xsl:choose>
                    <!--À adapter pour pouvoir citer les notes de l'édition en temps voulu.-->
                    <xsl:when test="@rend = 'section'">
                        <xsl:text>section \ref{</xsl:text>
                        <xsl:value-of select="$target"/>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="document($corpus_path)/descendant::tei:*[@xml:id = $target][self::tei:desc[parent::tei:handShift]]">
                        <xsl:choose>
                            <xsl:when
                                test="document($corpus_path)/descendant::tei:*[@xml:id = $target][ancestor::tei:TEI[@type = 'transcription' or @type = 'edition']]">
                                <!--Hack rapide, les références aux numéro de notes familières ne marchent pas correctement sinon.-->
                                <xsl:text>note n°\ref*{</xsl:text>
                                <xsl:value-of select="$target"/>
                                <xsl:text>}, page \edpageref{ed:</xsl:text>
                                <xsl:value-of select="$target"/>
                                <xsl:text>}</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>note n°\ref{</xsl:text>
                                <xsl:value-of select="$target"/>
                                <xsl:text>}, page \pageref{</xsl:text>
                                <xsl:value-of select="$target"/>
                                <xsl:text>}</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="document($corpus_path)/descendant::tei:*[@xml:id = $target][self::tei:note]">
                        <xsl:choose>
                            <xsl:when
                                test="document($corpus_path)/descendant::tei:*[@xml:id = $target][ancestor::tei:TEI[@type = 'transcription' or @type = 'edition']]">
                                <xsl:choose>
                                    <xsl:when
                                        test="document($corpus_path)/descendant::tei:*[@xml:id = $target][self::tei:note[@type = 'codico' or @type = 'variante']]">
                                        <xsl:text>page \edpageref{</xsl:text>
                                        <xsl:value-of select="$target"/>
                                        <xsl:text>}, ligne \edlineref{</xsl:text>
                                        <xsl:value-of select="$target"/>
                                        <xsl:text>}</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!--Hack rapide, les références aux numéro de notes familières ne marchent pas correctement sinon.-->
                                        <xsl:text>note n°\ref*{</xsl:text>
                                        <xsl:value-of select="$target"/>
                                        <xsl:text>}, page \edpageref{ed:</xsl:text>
                                        <xsl:value-of select="$target"/>
                                        <xsl:text>}</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>note n°\ref{</xsl:text>
                                <xsl:value-of select="$target"/>
                                <xsl:text>}, page \pageref{</xsl:text>
                                <xsl:value-of select="$target"/>
                                <xsl:text>}</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when
                        test="document($corpus_path)//tei:*[@xml:id = $target][self::tei:anchor[@type = 'citation' or @type = 'ligne']]">
                        <xsl:variable name="tei_id"
                            select="document($corpus_path)//tei:*[@xml:id = $target]/ancestor::tei:TEI[1]/@xml:id"/>
                        <xsl:variable name="collated_path">
                            <xsl:value-of
                                select="concat('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/edition/temoins/', $temoin_base_edition, '.xml')"/>
                            <!--Changer ici pour utiliser l'arbre reconstruit-->
                        </xsl:variable>
                        <xsl:variable name="collated_doc" select="document($collated_path)"/>
                        <xsl:variable name="context">7</xsl:variable>
                        <!--[descendant::tei:rdg[contains(@wit, $tei_id)]]-->

                        <!--IL RESTE A GÉRER LES TEMOINS SANS APPARAT-->
                        <xsl:text>page \edpageref{</xsl:text>
                        <xsl:value-of select="$target"/>
                        <xsl:text>}, </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$tei_id = 'Val_S' or $tei_id = 'Rome_W'">
                                <xsl:text>ligne \edlineref{</xsl:text>
                                <xsl:value-of select="$target"/>
                                <xsl:text>}</xsl:text>
                            </xsl:when>
                            <xsl:when test="@subtype = 'debut'">
                                <xsl:text>à partir de \enquote{\textit{</xsl:text>
                                <xsl:apply-templates mode="sans_apparat"
                                    select="$collated_doc/descendant::tei:anchor[@xml:id = $target]/following-sibling::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_edition) and node()]][position() &lt; $context]">
                                    <xsl:with-param name="temoin_base_citation" select="$temoin_base_edition" tunnel="yes"/>
                                </xsl:apply-templates>
                                <xsl:text>}}</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>ligne \edlineref{</xsl:text>
                                <xsl:value-of select="$target"/>
                                <xsl:text>}, </xsl:text>
                                <xsl:text>jusque \enquote{\textit{</xsl:text>
                                <xsl:apply-templates mode="sans_apparat"
                                    select="$collated_doc/descendant::tei:anchor[@xml:id = $target]/preceding-sibling::tei:app[descendant::tei:rdg[contains(@wit, $temoin_base_edition) and node()]][position() &lt; $context]">
                                    <xsl:with-param name="temoin_base_citation" select="$temoin_base_edition" tunnel="yes"/>
                                </xsl:apply-templates>
                                <xsl:text>}}</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="document($corpus_path)//tei:*[@xml:id = $target][self::tei:anchor[@type = 'reference']]">
                        <xsl:text>page \pageref{</xsl:text>
                        <xsl:value-of select="$target"/>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="//tei:*[@xml:id = $target][ancestor::tei:TEI[@type = 'transcription']][ancestor-or-self::tei:div[@type = 'chapitre']]">
                        <xsl:text>chapitre </xsl:text>
                        <xsl:value-of select="//tei:*[@xml:id = $target]/ancestor-or-self::tei:div[@type = 'chapitre']/@n"/>
                        <xsl:text>, page \pageref{</xsl:text>
                        <xsl:value-of select="$target"/>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:when test="//tei:*[@xml:id = $target][self::tei:table]">
                        <xsl:text>tableau \vref{</xsl:text>
                        <xsl:value-of select="$target"/>
                        <xsl:text>}</xsl:text>
                        <xsl:if test="//tei:*[@xml:id = $target][contains(@rend, 'annexe')]">
                            <xsl:text>, en annexe</xsl:text>
                        </xsl:if>
                        <!--<xsl:text>, p. \pageref{</xsl:text>
                        <xsl:value-of select="$target"/>
                        <xsl:text>}</xsl:text>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\enquote{\nameref{</xsl:text>
                        <xsl:value-of select="$target"/>
                        <xsl:text>}}, page \pageref{</xsl:text>
                        <xsl:value-of select="$target"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="//tei:*[@xml:id = $target][ancestor-or-self::tei:figure][descendant::tei:graphic]">
                <xsl:text>figure \vref{</xsl:text>
                <xsl:value-of select="$target"/>
                <xsl:text>}</xsl:text>
                <xsl:if test="//tei:*[@xml:id = $target][@rend = 'annexe' or ancestor::tei:TEI[@type = 'transcription']]">
                    <xsl:text>, en annexe</xsl:text>
                </xsl:if>
                <!--<xsl:text>, p. \pageref{</xsl:text>
                <xsl:value-of select="translate(@target, '#', '')"/>
                <xsl:text>}</xsl:text>-->
            </xsl:when>
            <xsl:when test="//tei:*[@xml:id = $target][ancestor-or-self::tei:table]">
                <xsl:text>tableau \vref{</xsl:text>
                <xsl:value-of select="$target"/>
                <xsl:text>}</xsl:text>
                <xsl:if test="//tei:*[@xml:id = $target][contains(@rend, 'annexe')]">
                    <xsl:text>, en annexe</xsl:text>
                </xsl:if>
                <!--<xsl:text>, p. \pageref{</xsl:text>
                <xsl:value-of select="$target"/>
                <xsl:text>}</xsl:text>-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>figure \vref{</xsl:text>
                <xsl:value-of select="$target"/>
                <xsl:text>}</xsl:text>
                <xsl:if test="//tei:*[@xml:id = $target][contains(@rend, 'annexe')]">
                    <xsl:text>, en annexe</xsl:text>
                </xsl:if>
                <!--<xsl:text>, p. \pageref{</xsl:text>
                <xsl:value-of select="translate(@target, '#', '')"/>
                <xsl:text>}</xsl:text>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="these" match="tei:ref[@type = 'programme']">
        <xsl:text>\verb|</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>|\footnote{Fichier présent dans le dépôt principal de la thèse:</xsl:text>
        <xsl:value-of select="replace(@target, '_', '\\_')"/>
        <xsl:text>~(commit </xsl:text>
        <xsl:value-of select="@corresp"/>
        <xsl:text>).}</xsl:text>
    </xsl:template>

    <xsl:template mode="these" match="tei:ref[@type = 'ref_textuelle']">
        <xsl:text>\footnote{\textit{Regimiento}, témoin </xsl:text>
        <xsl:value-of select="translate(substring-before(@target, '_'), '#', '')"/>
        <xsl:text>, chapitre </xsl:text>
        <xsl:variable name="paragraphe" select="substring-after(translate(@target, '#', ''), '_')"/>
        <xsl:variable name="temoin" select="substring-before(translate(@target, '#', ''), '_')"/>
        <xsl:value-of
            select="//tei:TEI[substring-after(@xml:id, '_') = $temoin]/descendant::tei:div[@type = 'chapitre'][not(@subtype)][descendant::tei:p/@n = $paragraphe]/@n"/>
        <xsl:text>, paragraphe </xsl:text>
        <!--Quand les identifiants de paragraphes seront fixés, 
            ajouter une règle pour récupérer le numéro de chapitre-->
        <xsl:value-of select="translate(substring-after(@target, '_'), '#', '')"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>.}</xsl:text>
    </xsl:template>




    <xsl:template mode="these" match="tei:emph">
        <xsl:choose>
            <xsl:when test="not(parent::tei:foreign)">
                <xsl:text>\emph{</xsl:text>
                <xsl:apply-templates mode="these"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>}</xsl:text>
                <xsl:apply-templates mode="these"/>
                <xsl:text>\textit{</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="these" match="tei:ref[@type = 'url'][ancestor::tei:note]">
        <xsl:variable name="echappement_url" select="replace(replace(@target, '#', '\\#'), '%', '\\%')"/>
        <xsl:variable name="echappement_texte_url">
            <xsl:value-of
                select="replace(replace(replace(replace(replace(@target, '#', '\\#'), '&amp;', concat('\\', $and)), '_', '\\_'), '%', '\\%'), '~', '\\~')"
                disable-output-escaping="true"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="node()">
                <xsl:text>\href{</xsl:text>
                <xsl:value-of select="$echappement_url"/>
                <xsl:text>}{</xsl:text>
                <xsl:apply-templates mode="these"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\href{</xsl:text>
                <xsl:value-of select="$echappement_url"/>
                <xsl:text>}{\csname NoAutoSpacing\endcsname </xsl:text>
                <xsl:value-of select="$echappement_texte_url"/>
                <xsl:text>}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template mode="these" match="tei:ref[@type = 'url'][not(ancestor::tei:note)]">
        <xsl:variable name="echappement_url" select="replace(replace(@target, '#', '\\#'), '%', '\\%')"/>
        <xsl:variable name="echappement_texte_url">
            <xsl:value-of
                select="replace(replace(replace(replace(@target, '#', '\\#'), '&amp;', concat('\\', $and)), '_', '\\_'), '%', '\\%')"
                disable-output-escaping="true"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="node()">
                <xsl:text>\href{</xsl:text>
                <xsl:value-of select="$echappement_url"/>
                <xsl:text>}{</xsl:text>
                <xsl:apply-templates mode="these"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\footnote{\href{</xsl:text>
                <xsl:value-of select="$echappement_url"/>
                <xsl:text>}{\csname NoAutoSpacing\endcsname </xsl:text>
                <xsl:value-of select="$echappement_texte_url"/>
                <xsl:text>}}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="node()[contains(@rend, 'annexe')]" mode="these" priority="3"/>

    <xsl:template mode="these" match="tei:graphic[not(parent::tei:figure[@rend = 'cote_a_cote'])]" name="images">
        <!--https://tex.stackexchange.com/a/8633-->
        <xsl:text>\adjincludegraphics[</xsl:text>
        <xsl:choose>
            <xsl:when test="contains(ancestor::tei:div[1]/@xml:id, 'allographes_')">
                <xsl:text>width=1cm, </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="@scale">
                    <xsl:text>scale=</xsl:text>
                    <xsl:value-of select="@scale"/>
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="@width">
                        <xsl:text>width=</xsl:text>
                        <xsl:value-of select="@width"/>
                        <xsl:text>\textwidth</xsl:text>
                    </xsl:when>
                    <xsl:when test="not(@width) and not(@scale)">
                        <xsl:text>width=.8\textwidth</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@angle">
            <xsl:text>,angle={</xsl:text>
            <xsl:value-of select="@angle"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:if test="@crop">
            <xsl:text>,trim={</xsl:text>
            <xsl:value-of select="@crop"/>
            <xsl:text>}, clip</xsl:text>
        </xsl:if>
        <xsl:text>]{</xsl:text>
        <xsl:value-of select="@url"/>
        <xsl:text>}</xsl:text>
    </xsl:template>



    <xsl:template match="node()[@rend = 'annexe']" mode="these"/>



    <xsl:template mode="these annexe" match="tei:table[not(contains(@rend, 'paysage'))][not(@rend = 'cote_a_cote')]">
        <xsl:variable name="table_type">
            <xsl:choose>
                <xsl:when test="contains(@rend, 'long')">
                    <xsl:text>longtable</xsl:text>
                </xsl:when>
                <xsl:otherwise>tabular</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="table_conf">
            <xsl:choose>
                <xsl:when test="contains(@rend, 'adapt')">
                    <xsl:message>Found your adaptative table</xsl:message>
                    <!--We want an adaptative column width-->
                    <xsl:choose>
                        <xsl:when test="descendant::tei:row[@role = 'label'][tei:cell[@rend]]">
                            <!--Des fois on veut contrôler l'alignement dans chaque colonne-->
                            <xsl:value-of select="
                                    concat('|',
                                    string-join(for $rend in descendant::tei:row[@role = 'label']/tei:cell/@rend
                                    return
                                        concat($rend, '|'))
                                    )"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--Des fois on veut juste que chaque colonne soit centrée et de taille adaptée-->
                            <xsl:value-of select="
                                    concat('|',
                                    string-join(for $integer in 1 to @cols
                                    return
                                        ' c|')
                                    )"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="8 > number(@cols)">
                    <!--On général on veut que chaque colonne soit de taille fixe et égale.-->
                    <xsl:variable name="cell_width">
                        <xsl:text>{</xsl:text>
                        <xsl:value-of select="0.9 div @cols"/>
                        <xsl:text>\textwidth}</xsl:text>
                    </xsl:variable>
                    <xsl:value-of select="
                            concat('|',
                            string-join(for $integer in 1 to @cols
                            return
                                concat(' p{', $cell_width, '}|')))"/>
                    <!--https://en.wikibooks.org/wiki/LaTeX/Tables pour p{largeur}-->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="
                            concat('|',
                            string-join(for $integer in 1 to @cols
                            return
                                'c|'))"/>
                    <!--https://en.wikibooks.org/wiki/LaTeX/Tables pour p{largeur}-->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="not(contains(@rend, 'long'))">
            <xsl:text>\begin{table}[!htp]</xsl:text>
            <xsl:text>\begin{center}</xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="ancestor::tei:figure">
                <!--https://tex.stackexchange.com/a/446612-->
                <xsl:text>\begin{</xsl:text>
                <xsl:value-of select="$table_type"/>
                <xsl:text>}{</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\begin{</xsl:text>
                <xsl:value-of select="$table_type"/>
                <xsl:text>}{</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$table_conf"/>
        <xsl:text>}</xsl:text>
        <xsl:choose>
            <xsl:when test="tei:row[@role = 'label']">
                <xsl:text>\hline </xsl:text>
                <xsl:for-each select="tei:row[@role = 'label']/tei:cell">
                    <xsl:text>\textbf{</xsl:text>
                    <xsl:apply-templates mode="these"/>
                    <xsl:text>}</xsl:text>
                    <xsl:if test="following-sibling::tei:cell">
                        <!--https://our.umbraco.com/forum/developers/xslt/3116-How-to-get-the-Ampersand-output-as-single-char#comment-10435-->
                        <xsl:value-of select="$and" disable-output-escaping="true"/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text>\\ </xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>\hline </xsl:text>
        <xsl:for-each select="tei:row[not(@role = 'label')]">
            <xsl:for-each select="tei:cell">
                <xsl:if test="@role = 'label'">
                    <xsl:text>\textbf{</xsl:text>
                </xsl:if>
                <xsl:apply-templates mode="these"/>
                <xsl:if test="@role = 'label'">
                    <xsl:text>}</xsl:text>
                </xsl:if>
                <xsl:if test="following-sibling::tei:cell">
                    <xsl:value-of select="$and" disable-output-escaping="true"/>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>\\</xsl:text>
            <xsl:text>\hline </xsl:text>
        </xsl:for-each>
        <xsl:choose>
            <xsl:when test="ancestor::tei:figure">
                <xsl:text>\end{</xsl:text>
                <xsl:value-of select="$table_type"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="not(contains(@rend, 'long'))">
                        <xsl:text>\end{</xsl:text>
                        <xsl:value-of select="$table_type"/>
                        <xsl:text>}</xsl:text>
                        <xsl:if test="descendant::tei:desc">
                            <xsl:text>\caption</xsl:text>
                            <xsl:if test="tei:desc[@type = 'short']">
                                <xsl:text>[</xsl:text>
                                <xsl:apply-templates mode="these" select="tei:desc[@type = 'short']"/>
                                <xsl:text>]</xsl:text>
                            </xsl:if>
                            <xsl:text>{</xsl:text>
                            <xsl:apply-templates select="descendant::tei:desc[not(@type = 'short')]" mode="these"/>
                            <xsl:text>}</xsl:text>
                        </xsl:if>
                        <xsl:if test="@xml:id">
                            <xsl:text>\label{</xsl:text>
                            <xsl:value-of select="@xml:id"/>
                            <xsl:text>}</xsl:text>
                        </xsl:if>
                        <xsl:text>\end{center}</xsl:text>
                        <xsl:text>\end{table}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="descendant::tei:desc">
                            <xsl:text>\caption</xsl:text>
                            <xsl:if test="tei:desc[@type = 'short']">
                                <xsl:text>[</xsl:text>
                                <xsl:apply-templates mode="these" select="tei:desc[@type = 'short']"/>
                                <xsl:text>]</xsl:text>
                            </xsl:if>
                            <xsl:text>{</xsl:text>
                            <xsl:apply-templates select="descendant::tei:desc[not(@type = 'short')]" mode="these"/>
                            <xsl:text>}</xsl:text>
                        </xsl:if>
                        <xsl:if test="@xml:id">
                            <xsl:text>\label{</xsl:text>
                            <xsl:value-of select="@xml:id"/>
                            <xsl:text>}</xsl:text>
                        </xsl:if>
                        <xsl:text>\end{</xsl:text>
                        <xsl:value-of select="$table_type"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="descendant::tei:note">
            <xsl:for-each select="descendant::tei:note">
                <xsl:text>\footnotetext{</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>}</xsl:text>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>


    <xsl:template mode="these annexe" match="tei:table[contains(@rend, 'paysage')][not(@rend = 'cote_a_cote')]">
        <xsl:variable name="table_type">
            <xsl:choose>
                <xsl:when test="contains(@rend, 'long')">
                    <xsl:text>longtable</xsl:text>
                </xsl:when>
                <xsl:otherwise>tabular</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="table_conf">
            <xsl:choose>
                <xsl:when test="contains(@rend, 'adapt')">
                    <!--We want an adaptative column width-->
                    <xsl:choose>
                        <xsl:when test="descendant::tei:row[@role = 'label'][tei:cell[@rend]]">
                            <!--Des fois on veut contrôler l'alignement dans chaque colonne-->
                            <xsl:value-of select="
                                    concat('|',
                                    string-join(for $rend in descendant::tei:row[@role = 'label']/tei:cell/@rend
                                    return
                                        concat($rend, '|'))
                                    )"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--Des fois on veut juste que chaque colonne soit centrée et de taille adaptée-->
                            <xsl:value-of select="
                                    concat('|',
                                    string-join(for $integer in 1 to @cols
                                    return
                                        ' c|')
                                    )"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="8 > number(@cols)">
                    <!--On général on veut que chaque colonne soit de taille fixe et égale.-->
                    <xsl:variable name="cell_width">
                        <xsl:text>{</xsl:text>
                        <xsl:value-of select="0.9 div @cols"/>
                        <xsl:text>\textwidth}</xsl:text>
                    </xsl:variable>
                    <xsl:value-of select="
                            concat('|',
                            string-join(for $integer in 1 to @cols
                            return
                                concat(' p{', $cell_width, '}|')))"/>
                    <!--https://en.wikibooks.org/wiki/LaTeX/Tables pour p{largeur}-->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="
                            concat('|',
                            string-join(for $integer in 1 to @cols
                            return
                                'c|'))"/>
                    <!--https://en.wikibooks.org/wiki/LaTeX/Tables pour p{largeur}-->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="not(contains(@rend, 'annexe'))">
            <xsl:text>\begin{landscape}\pagestyle{empty}</xsl:text>
        </xsl:if>
        <xsl:if test="not(contains(@rend, 'long'))">
            <xsl:text>\begin{table}[!htp]</xsl:text>
            <xsl:text>\begin{center}</xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="ancestor::tei:figure">
                <!--https://tex.stackexchange.com/a/446612-->
                <xsl:text>\begin{</xsl:text>
                <xsl:value-of select="$table_type"/>
                <xsl:text>}{</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\begin{</xsl:text>
                <xsl:value-of select="$table_type"/>
                <xsl:text>}{</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$table_conf"/>
        <xsl:text>}</xsl:text>
        <xsl:choose>
            <xsl:when test="tei:row[@role = 'label']">
                <xsl:text>\hline </xsl:text>
                <xsl:for-each select="tei:row[@role = 'label']/tei:cell">
                    <xsl:text>\textbf{</xsl:text>
                    <xsl:apply-templates mode="these"/>
                    <xsl:text>}</xsl:text>
                    <xsl:if test="following-sibling::tei:cell">
                        <!--https://our.umbraco.com/forum/developers/xslt/3116-How-to-get-the-Ampersand-output-as-single-char#comment-10435-->
                        <xsl:value-of select="$and" disable-output-escaping="true"/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text>\\ </xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>\hline </xsl:text>
        <xsl:for-each select="tei:row[not(@role = 'label')]">
            <xsl:for-each select="tei:cell">
                <xsl:apply-templates mode="these"/>
                <xsl:if test="following-sibling::tei:cell">
                    <xsl:value-of select="$and" disable-output-escaping="true"/>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>\\</xsl:text>
            <xsl:text>\hline </xsl:text>
        </xsl:for-each>
        <xsl:choose>
            <xsl:when test="ancestor::tei:figure">
                <xsl:text>\end{</xsl:text>
                <xsl:value-of select="$table_type"/>
                <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="not(contains(@rend, 'long'))">
                        <xsl:text>\end{</xsl:text>
                        <xsl:value-of select="$table_type"/>
                        <xsl:text>}</xsl:text>
                        <xsl:if test="descendant::tei:desc">
                            <xsl:text>\caption</xsl:text>
                            <xsl:if test="tei:desc[@type = 'short']">
                                <xsl:text>[</xsl:text>
                                <xsl:apply-templates mode="these" select="tei:desc[@type = 'short']"/>
                                <xsl:text>]</xsl:text>
                            </xsl:if>
                            <xsl:text>{</xsl:text>
                            <xsl:apply-templates select="descendant::tei:desc[not(@type = 'short')]" mode="these"/>
                            <xsl:text>}</xsl:text>
                        </xsl:if>
                        <xsl:if test="@xml:id">
                            <xsl:text>\label{</xsl:text>
                            <xsl:value-of select="@xml:id"/>
                            <xsl:text>}</xsl:text>
                        </xsl:if>
                        <xsl:text>\end{center}</xsl:text>
                        <xsl:text>\end{table}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="descendant::tei:desc">
                            <xsl:text>\caption</xsl:text>
                            <xsl:if test="tei:desc[@type = 'short']">
                                <xsl:text>[</xsl:text>
                                <xsl:apply-templates mode="these" select="tei:desc[@type = 'short']"/>
                                <xsl:text>]</xsl:text>
                            </xsl:if>
                            <xsl:text>{</xsl:text>
                            <xsl:apply-templates select="descendant::tei:desc[not(@type = 'short')]" mode="these"/>
                            <xsl:text>}</xsl:text>
                        </xsl:if>
                        <xsl:if test="@xml:id">
                            <xsl:text>\label{</xsl:text>
                            <xsl:value-of select="@xml:id"/>
                            <xsl:text>}</xsl:text>
                        </xsl:if>
                        <xsl:text>\end{</xsl:text>
                        <xsl:value-of select="$table_type"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="descendant::tei:note">
            <xsl:for-each select="descendant::tei:note">
                <xsl:text>\footnotetext{</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>}</xsl:text>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="not(contains(@rend, 'annexe'))">
            <xsl:text>\end{landscape}</xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template mode="these" match="tei:note" priority="2">
        <xsl:choose>
            <xsl:when test="ancestor::tei:figure">
                <xsl:text>\footnotemark </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="these" match="tei:gi">
        <xsl:text>\textnormal{\texttt{</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>}}</xsl:text>
    </xsl:template>

    <xsl:template mode="these" match="tei:att">
        <xsl:text>\textnormal{\texttt{@</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>}}</xsl:text>
    </xsl:template>


    <xsl:template mode="these" match="tei:div[@type = 'exergue']"/>


    <xsl:template mode="these" match="tei:code[@rend = 'fonction']">
        <!--Cette règle est pensée pour produire des requêtes et imprimer des images. Voir la fonction myfunctions:print_abbr_usages-->
        <xsl:variable name="funct_name" select="translate(@corresp, '#', '')"/>
        <xsl:variable name="funct_call_expression">
            <xsl:value-of select="concat('myfunctions:', $funct_name, '(', @param1, ',', @param2, ')')"/>
        </xsl:variable>
        <xsl:value-of select="myfunctions:print_abbr_usages('Mad_A', '#npoint_A')"/>
        <!--Pas universel, voir comment régler ça.-->
    </xsl:template>

    <xsl:function name="myfunctions:iso_lang_to_language">
        <xsl:param name="iso_lang"/>
        <xsl:choose>
            <xsl:when test="$iso_lang = 'lat'">latin</xsl:when>
            <xsl:when test="$iso_lang = 'eng'">english</xsl:when>
            <xsl:when test="$iso_lang = 'spo' or $iso_lang = 'spa' or $iso_lang = 'cat'">spanish</xsl:when>
            <xsl:otherwise>french</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="myfunctions:escape_code">
        <xsl:param name="input"/>
        <xsl:variable name="v1">
            <xsl:value-of select="replace($input, '&amp;', concat('\\', $and))" disable-output-escaping="yes"/>
        </xsl:variable>
        <xsl:variable name="v2">
            <xsl:value-of select="replace($v1, '\s+', ' ')" disable-output-escaping="yes"/>
        </xsl:variable>
        <xsl:variable name="v3">
            <xsl:value-of select="replace($v2, '%', '\\%')" disable-output-escaping="yes"/>
        </xsl:variable>
        <xsl:variable name="v4">
            <xsl:value-of select="replace($v3, '\{', '\\{')" disable-output-escaping="yes"/>
        </xsl:variable>
        <xsl:variable name="v5">
            <xsl:value-of select="replace($v4, '\^', '\\^ ')" disable-output-escaping="yes"/>
        </xsl:variable>
        <xsl:variable name="v6">
            <xsl:value-of select="replace($v5, '_', '\\_')" disable-output-escaping="yes"/>
        </xsl:variable>
        <xsl:variable name="v7">
            <xsl:value-of select="replace($v6, '\}', '\\}')" disable-output-escaping="yes"/>
        </xsl:variable>
        <xsl:value-of select="$v7" disable-output-escaping="yes"/>
    </xsl:function>

    <xsl:function name="myfunctions:print_abbr_usages">
        <xsl:param name="witness"/>
        <!--The witness to treat-->
        <xsl:param name="grapheme"/>
        <!--The abreviation to output-->
        <xsl:variable name="path_to_file">
            <xsl:value-of
                select="concat('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/analyse_linguistique/', $witness, '.xml')"
            />
        </xsl:variable>
        <!-- //tei:graphic[ancestor::tei:surface][//tei:lb/translate(@facs, '#', '') = @xml:id]-->
        <xsl:for-each select="doc($path_to_file)//tei:choice[descendant::tei:g[@ref = $grapheme]]">
            <xsl:variable name="preceding_lb_id" select="preceding::tei:lb[1]/translate(@facs, '#', '')"/>
            <xsl:if test="//tei:surface[@xml:id = $preceding_lb_id]">
                <xsl:variable name="image_url">
                    <!--                [following-sibling::tei:choice[descendant::tei:g[@ref='#npoint_A']]-->
                    <xsl:value-of select="//tei:surface[@xml:id = $preceding_lb_id]/tei:graphic/@url"/>
                </xsl:variable>
                <xsl:text>
                    \begin{figure}[!htp]
                    \includegraphics[scale=0.5]{</xsl:text>
                <xsl:value-of
                    select="replace($image_url, '../../', '/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/')"/>
                <xsl:text>}</xsl:text>
                <xsl:text>\caption{Fol. </xsl:text>
                <xsl:value-of select="preceding::tei:pb[1]/@n"/>
                <xsl:text>}</xsl:text>
                <xsl:text>\end{figure}</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>



    <xsl:template match="tei:space" mode="these">
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template mode="these" match="tei:quote[@type = 'edition'][not(contains(@source, ' '))]">
        <!--Cette fonction permet de récupérer les noeuds entre deux tei:anchor lorsque l'on veut citer un texte, 
        et cela permet ainsi de produire un texte qui est accompagné de l'apparat dans le corps de la thèse. En test.-->
        <!--Il faudra refaire les chemins une fois les éditions complètes produites-->
        <xsl:variable name="anchor" select="translate(@source, '#', '')"/>

        <xsl:variable name="corresponding_element"
            select="doc($corpus_path)/descendant::tei:body/descendant::node()[@xml:id = $anchor]"/>

        <xsl:variable name="corresponding_wit_id">
            <xsl:value-of select="$corresponding_element/ancestor::tei:TEI[1]/@xml:id"/>
        </xsl:variable>

        <xsl:variable name="file_path">
            <xsl:value-of select="base-uri(doc($corpus_path)/descendant::tei:body/tei:div/descendant::node()[@xml:id = $anchor])"
            />
        </xsl:variable>


        <xsl:variable name="corresponding_wit_n" select="$corresponding_element/ancestor::tei:div[@type = 'chapitre']/@n"/>
        <xsl:variable name="glose_ou_traduction"
            select="$corresponding_element/ancestor::tei:div[@type = 'glose' or @type = 'traduction']/@type"/>
        <xsl:variable name="collated_file_path">
            <xsl:choose>
                <xsl:when test="$corresponding_wit_id = 'Val_S'">
                    <xsl:value-of
                        select="'/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan/Val_S.xml'"
                    />
                </xsl:when>
                <xsl:when test="$corresponding_wit_id = 'Rome_W'">
                    <xsl:value-of
                        select="'/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/latin/Rome_W.xml'"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat('/home/mgl/Bureau/These/Edition/collator/results/', $corresponding_wit_id, '.xml')"/>
                    <!--Changer ici pour utiliser l'arbre reconstruit-->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="corresponding_pb" select="$corresponding_element/preceding::tei:pb[1]/@n"/>

        <xsl:variable name="folio_or_page">
            <xsl:choose>
                <xsl:when test="doc($file_path)/descendant::tei:foliation/@ana = '#paginé'">
                    <xsl:text>p. </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>fol. </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:text>\par
            %
            \vspace{0.1cm}
            \begin{minipage}{0.93\textwidth}
            \begin{ledgroupsized}[c]{0.97\textwidth}
                  \beginnumbering
                  \pstart 
                  \setline{1}%</xsl:text>
        <xsl:value-of select="$collated_file_path"/>
        <xsl:text>&#10;</xsl:text>

        <!--On va donc chercher dans le fichier xml source, en attendant la collation.-->
        <!--                <xsl:text>Cas 2&#10;</xsl:text>-->
        <!--<xsl:apply-templates select="doc($file_path)/descendant::node()[@xml:id = $anchor]/node()" mode="citation_apparat">
            <xsl:with-param tunnel="yes" name="temoin_base_citation" select="$corresponding_wit_id"/>
        </xsl:apply-templates>-->
        <xsl:apply-templates select="doc($file_path)/descendant::node()[@xml:id = $anchor]/node()" mode="edition">
            <xsl:with-param tunnel="yes" name="temoin_base_citation" select="$corresponding_wit_id"/>
        </xsl:apply-templates>

        <xsl:choose>
            <xsl:when test="
                    document($corpus_path)/descendant::node()[@xml:id = $anchor]/ancestor-or-self::tei:head
                    | document($corpus_path)/descendant::tei:TEI[@xml:id = 'Val_S']/descendant::node()[@xml:id = $anchor]">
                <xsl:text> \lbrack\cite{</xsl:text>
                <xsl:value-of select="$corresponding_wit_id"/>
                <xsl:text>}, III‑3‑</xsl:text>
                <xsl:value-of select="$corresponding_wit_n"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="$folio_or_page"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$corresponding_pb"/>
                <xsl:choose>
                    <xsl:when test="contains(@rend, 'sans_apparat') and not($temoin_base_edition = $corresponding_wit_id)"/>
                    <xsl:otherwise>
                        <xsl:text>, éd. p. \edpageref{</xsl:text>
                        <xsl:value-of select="$anchor"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>\rbrack </xsl:text>
            </xsl:when>
            <xsl:when test="document($corpus_path)/descendant::tei:TEI[@xml:id = 'Rome_W']/descendant::node()[@xml:id = $anchor]">
                <xsl:text> \lbrack\cite{</xsl:text>
                <xsl:value-of select="$corresponding_wit_id"/>
                <xsl:text>}, III‑3‑</xsl:text>
                <xsl:value-of select="$corresponding_wit_n"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="$folio_or_page"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$corresponding_pb"/>
                <xsl:text>, transcription ann. p. \edpageref{</xsl:text>
                <xsl:value-of select="$anchor"/>
                <xsl:text>}\rbrack </xsl:text>
            </xsl:when>
            <xsl:when
                test="document($corpus_path)/descendant::tei:TEI[@xml:id = 'hors_corpus']/descendant::node()[@xml:id = $anchor]">
                <xsl:text> \lbrack\cite{</xsl:text>
                <xsl:value-of select="doc($file_path)/descendant::tei:witness/@xml:id"/>
                <xsl:text>}, </xsl:text>
                <xsl:value-of select="$folio_or_page"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$corresponding_pb"/>
                <xsl:text>\rbrack </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> \lbrack\cite{</xsl:text>
                <xsl:value-of select="$corresponding_wit_id"/>
                <xsl:text>}, III‑3‑</xsl:text>
                <xsl:value-of select="$corresponding_wit_n"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="$glose_ou_traduction"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="$folio_or_page"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$corresponding_pb"/>
                <xsl:choose>
                    <xsl:when test="contains(@rend, 'sans_apparat') and not($temoin_base_edition = $corresponding_wit_id)"/>
                    <xsl:otherwise>
                        <xsl:text>, éd. p. \edpageref{</xsl:text>
                        <xsl:value-of select="$anchor"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>\rbrack </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="tei:note">
            <xsl:text>\footnotemark</xsl:text>
        </xsl:if>
        <xsl:text>
        \pend
        \endnumbering
         \end{ledgroupsized}
        \end{minipage}
        \vspace{0.4cm}
        </xsl:text>
        <xsl:if test="tei:note">
            <xsl:text>\footnotetext{</xsl:text>
            <xsl:apply-templates mode="these" select="tei:note/node()"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>~\\\noindent </xsl:text>
    </xsl:template>

    <xsl:template mode="these" match="tei:quote[@type = 'edition'][contains(@source, ' ')]">
        <!--Cette fonction permet de récupérer les noeuds entre deux tei:anchor lorsque l'on veut citer un texte, 
        et cela permet ainsi de produire un texte qui est accompagné de l'apparat dans le corps de la thèse. En test.-->
        <!--Il faudra refaire les chemins une fois les éditions complètes produites-->
        <xsl:variable name="anchors" select="tokenize(@source, '\s')"/>
        <xsl:variable name="beginning_anchor" select="translate($anchors[1], '#', '')"/>
        <xsl:variable name="ending_anchor" select="translate($anchors[2], '#', '')"/>

        <!--Demande beaucoup de ressources computationnelles: essayer de réduire cela en apportant l'information de division et/ou de témoin
        à la main dans l'élément tei:quote ?-->
        <xsl:variable name="corresponding_element"
            select="doc($corpus_path)/descendant::tei:body/tei:div/descendant::tei:anchor[@xml:id = $beginning_anchor]"/>



        <xsl:variable name="corresponding_wit_id">
            <xsl:choose>
                <xsl:when test="@corresp">
                    <xsl:value-of select="translate(@corresp, '#', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$corresponding_element/ancestor::tei:TEI[1]/@xml:id"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="file_path">
            <xsl:value-of
                select="base-uri(doc($corpus_path)/descendant::tei:body/tei:div/descendant::tei:anchor[@xml:id = $beginning_anchor])"/>
            <!--<xsl:choose>
                <xsl:when test="$corresponding_wit_id = 'Rome_W'">
                    <xsl:value-of
                        select="concat('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/latin/', $corresponding_wit_id, '.xml')"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan/', $corresponding_wit_id, '.xml')"
                    />
                </xsl:otherwise>
            </xsl:choose>-->
        </xsl:variable>
        <xsl:variable name="corresponding_wit_n" select="$corresponding_element/ancestor::tei:div[@type = 'chapitre']/@n"/>
        <xsl:variable name="glose_ou_traduction"
            select="$corresponding_element/ancestor::tei:div[@type = 'glose' or @type = 'traduction']/@type"/>
        <xsl:variable name="collated_file_path">
            <xsl:choose>
                <xsl:when test="$corresponding_wit_id = 'Val_S'">
                    <xsl:value-of
                        select="'/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/castillan/Val_S.xml'"
                    />
                </xsl:when>
                <xsl:when test="$corresponding_wit_id = 'Rome_W'">
                    <xsl:value-of
                        select="'/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/temoins/latin/Rome_W.xml'"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/edition/temoins/', $corresponding_wit_id, '.xml')"/>
                    <!--Changer ici pour utiliser l'arbre reconstruit-->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="corresponding_pb" select="$corresponding_element/preceding::tei:pb[1]/@n"/>

        <xsl:variable name="folio_or_page">
            <xsl:choose>
                <xsl:when test="doc($file_path)/descendant::tei:foliation/@ana = '#paginé'">
                    <xsl:text>p. </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>fol. </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="@rend = 'inline'">\enquote{\begin{otherlanguage}{spanish}\textit{</xsl:when>
            <xsl:when test="not(ancestor::tei:table[@rend = 'cote_a_cote'])">
                <xsl:text>\par
            %
            \vspace{-.05cm}
            \begin{minipage}{0.93\textwidth}
            \begin{ledgroupsized}[c]{0.97\textwidth}
                  \beginnumbering
                  \pstart 
                  \setline{1}%</xsl:text>
                <xsl:value-of select="$collated_file_path"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\begin{otherlanguage}{spanish}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <!--Il y a un problème avec les variantes graphiques, trouver pourquoi.-->

        <xsl:choose>
            <!--On va tester si trois conditions sont présentes: 
                    1) on veut faire apparaître les apparats; 
                    2), le document collationé existe et 
                    3) les tei:anchor sont présents dans le document collationé-->
            <xsl:when
                test="not($corresponding_wit_id = 'Val_S') and not($corresponding_wit_id = 'Rome_W') and not(@rend = 'sans_apparat') and doc-available($collated_file_path) and boolean(doc($collated_file_path)/descendant::tei:anchor[@xml:id = $beginning_anchor])">


                <!--Ancienne règle, plus propre-->
                <!--<xsl:apply-templates
                        select="doc($collated_file_path)/descendant::node()[ancestor::tei:p/@n = $corresponding_div][preceding-sibling::tei:anchor[@xml:id = $beginning_anchor]][following-sibling::tei:anchor[@xml:id = $ending_anchor]]"
                        mode="citation_apparat"/>-->
                <!--Ancienne règle, plus propre-->
                <!--Ne marche pas à cause de réinjections qui overlappent. Il faut régler ça dans collator avant tout, ce n'est qu'un patch.-->

                <xsl:text>% Cas 1&#10;</xsl:text>

                <xsl:variable name="corresponding_div"
                    select="doc($file_path)/descendant::tei:anchor[@xml:id = $beginning_anchor]/ancestor::tei:p/@n"/>
                <!--On présuppose que la citation ne mène pas à overlapping.-->
                <!--<xsl:apply-templates
                    select="doc($collated_file_path)/descendant::node()[self::tei:p[@n = $corresponding_div] | self::tei:head[ancestor::tei:div[@type = 'chapitre'][@n = $corresponding_wit_n]]]/child::node()[preceding::tei:anchor[@xml:id = $beginning_anchor]][following::tei:anchor[@xml:id = $ending_anchor]]"
                    mode="citation_apparat">
                    <xsl:with-param name="temoin_base_citation" select="$corresponding_wit_id" tunnel="yes"/>
                    <xsl:with-param name="debug" tunnel="yes" select="$debug"/>
                </xsl:apply-templates>-->
                <xsl:apply-templates
                    select="doc($collated_file_path)/descendant::node()[self::tei:p[@n = $corresponding_div] | self::tei:head[ancestor::tei:div[@type = 'chapitre'][@n = $corresponding_wit_n]]]/child::node()[preceding::tei:anchor[@xml:id = $beginning_anchor]][following::tei:anchor[@xml:id = $ending_anchor]]"
                    mode="edition">
                    <xsl:with-param name="temoin_base_citation" select="$corresponding_wit_id" tunnel="yes"/>
                    <xsl:with-param name="debug" tunnel="yes" select="$debug"/>
                </xsl:apply-templates>
            </xsl:when>
            <!--Sinon, on va appliquer le mode sans_apparat.-->
            <xsl:otherwise>
                <!--                <xsl:text>Cas 2&#10;</xsl:text>-->
                <xsl:variable name="corresponding_div"
                    select="doc($file_path)/descendant::tei:anchor[@xml:id = $beginning_anchor]/ancestor::tei:p/@n"/>
                <xsl:choose>
                    <!--Ce cas est celui des fichiers autres que le fichier de l'édition: la Communidad par exemple-->
                    <xsl:when test="not(@rend = 'sans_apparat')">
                        <xsl:text>% Cas 2&#10;</xsl:text>
                        <xsl:choose>
                            <xsl:when
                                test="doc($collated_file_path)/descendant::node()[self::tei:p[@n = $corresponding_div] | self::tei:head[ancestor::tei:div[@type = 'chapitre'][@n = $corresponding_wit_n]]]/descendant::tei:anchor[@xml:id = $beginning_anchor]">
                                <xsl:apply-templates
                                    select="doc($collated_file_path)/descendant::node()[self::tei:p[@n = $corresponding_div] | self::tei:head[ancestor::tei:div[@type = 'chapitre'][@n = $corresponding_wit_n]]]/child::node()[preceding::tei:anchor[@xml:id = $beginning_anchor]][following::tei:anchor[@xml:id = $ending_anchor]]"
                                    mode="sans_apparat">
                                    <xsl:with-param name="temoin_base_citation" tunnel="yes" select="$corresponding_wit_id"/>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates
                                    select="doc($file_path)/descendant::node()[self::tei:p[@n = $corresponding_div] | self::tei:head[ancestor::tei:div[@type = 'chapitre'][@n = $corresponding_wit_n]]]/child::node()[preceding::tei:anchor[@xml:id = $beginning_anchor]][following::tei:anchor[@xml:id = $ending_anchor]]"
                                    mode="sans_apparat">
                                    <xsl:with-param name="temoin_base_citation" tunnel="yes" select="$corresponding_wit_id"/>
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>% Cas 3&#10;</xsl:text>
                        <xsl:try>
                            <xsl:apply-templates
                                select="doc($collated_file_path)/descendant::node()[preceding-sibling::tei:anchor[@xml:id = $beginning_anchor]][following-sibling::tei:anchor[@xml:id = $ending_anchor]]"
                                mode="sans_apparat">
                                <xsl:with-param name="temoin_base_citation" tunnel="yes" select="$corresponding_wit_id"/>
                            </xsl:apply-templates>
                            <xsl:catch>
                                <xsl:text>% Exception raised B: there is not collated file with these anchors. &#10;</xsl:text>
                                <xsl:apply-templates
                                    select="doc($file_path)/descendant::node()[preceding-sibling::tei:anchor[@xml:id = $beginning_anchor]][following-sibling::tei:anchor[@xml:id = $ending_anchor]]"
                                    mode="sans_apparat">
                                    <xsl:with-param name="temoin_base_citation" tunnel="yes" select="$corresponding_wit_id"/>
                                </xsl:apply-templates>
                            </xsl:catch>
                        </xsl:try>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="@rend = 'inline'">
                <xsl:text>\footnote{\cite{</xsl:text>
                <xsl:value-of select="$corresponding_wit_id"/>
                <xsl:text>}, III‑3‑</xsl:text>
                <xsl:value-of select="$corresponding_wit_n"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="$folio_or_page"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$corresponding_pb"/>
                <xsl:text>, éd. p. \edpageref{</xsl:text>
                <xsl:value-of select="$beginning_anchor"/>
                <xsl:text>}</xsl:text>
                <xsl:text>.}</xsl:text>
            </xsl:when>
            <xsl:when test="
                    document($corpus_path)/descendant::tei:head/descendant::tei:anchor[@xml:id = $beginning_anchor]
                    | document($corpus_path)/descendant::tei:TEI[@xml:id = 'Val_S']/descendant::tei:anchor[@xml:id = $beginning_anchor]">
                <xsl:text> \lbrack\cite{</xsl:text>
                <xsl:value-of select="$corresponding_wit_id"/>
                <xsl:text>}, III‑3‑</xsl:text>
                <xsl:value-of select="$corresponding_wit_n"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="$folio_or_page"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$corresponding_pb"/>
                <xsl:choose>
                    <xsl:when test="contains(@rend, 'sans_apparat') and not($temoin_base_edition = $corresponding_wit_id)"/>
                    <xsl:otherwise>
                        <xsl:text>, éd. p. \edpageref{</xsl:text>
                        <xsl:value-of select="$beginning_anchor"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>\rbrack </xsl:text>
            </xsl:when>
            <xsl:when
                test="document($corpus_path)/descendant::tei:TEI[@xml:id = 'Rome_W']/descendant::tei:anchor[@xml:id = $beginning_anchor]">
                <xsl:text> \lbrack\cite{</xsl:text>
                <xsl:value-of select="$corresponding_wit_id"/>
                <xsl:text>}, III‑3‑</xsl:text>
                <xsl:value-of select="$corresponding_wit_n"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="$folio_or_page"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$corresponding_pb"/>
                <xsl:text>, transcr. ann. p. \edpageref{</xsl:text>
                <xsl:value-of select="$beginning_anchor"/>
                <xsl:text>}\rbrack </xsl:text>
            </xsl:when>
            <xsl:when
                test="document($corpus_path)/descendant::tei:TEI[@xml:id = 'hors_corpus']/descendant::tei:anchor[@xml:id = $beginning_anchor]">
                <xsl:text> \lbrack\cite{</xsl:text>
                <xsl:value-of select="doc($file_path)/descendant::tei:witness/@xml:id"/>
                <xsl:text>}, </xsl:text>
                <xsl:value-of select="$folio_or_page"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$corresponding_pb"/>
                <xsl:text>\rbrack </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> \lbrack\cite{</xsl:text>
                <xsl:value-of select="$corresponding_wit_id"/>
                <xsl:text>}, III‑3‑</xsl:text>
                <xsl:value-of select="$corresponding_wit_n"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="$glose_ou_traduction"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="$folio_or_page"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$corresponding_pb"/>
                <xsl:choose>
                    <xsl:when test="contains(@rend, 'sans_apparat') and not($temoin_base_edition = $corresponding_wit_id)"/>
                    <xsl:otherwise>
                        <xsl:text>, éd. p. \edpageref{</xsl:text>
                        <xsl:value-of select="$beginning_anchor"/>
                        <xsl:text>}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>\rbrack </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="tei:note">
            <xsl:text>\footnotemark</xsl:text>
        </xsl:if>

        <xsl:choose>
            <xsl:when test="@rend = 'inline'">}\end{otherlanguage}}</xsl:when>
            <xsl:when test="not(ancestor::tei:table[@rend = 'cote_a_cote'])">
                <xsl:text>  
        \pend
        \endnumbering
         \end{ledgroupsized}
        \end{minipage}
        \vspace{0.4cm}
        ~\\\noindent 
        </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>\end{otherlanguage}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="tei:note">
            <xsl:text>\footnotetext{</xsl:text>
            <xsl:apply-templates mode="these" select="tei:note/node()"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template match="tei:hi[@rend = 'superscript']" mode="these">
        <xsl:text>\textsuperscript{</xsl:text>
        <xsl:apply-templates mode="these"/>
        <xsl:text>}</xsl:text>
    </xsl:template>


    <xsl:template match="tei:hi[@rend = 'gras']" mode="these">
        <xsl:text>\textbf{</xsl:text>
        <xsl:apply-templates mode="these"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'subscript']" mode="these">
        <xsl:text>\textsubscript{</xsl:text>
        <xsl:apply-templates mode="these"/>
        <xsl:text>}</xsl:text>
    </xsl:template>


    <xsl:template match="tei:pb" mode="these">
        <xsl:text>\textsuperscript{[pb]}</xsl:text>
    </xsl:template>


    <xsl:template mode="these" match="comment()"/>

    <xsl:template mode="#all" match="text()[not(ancestor::teiExample:*)]">
        <!--<xsl:variable name="sub1" select="replace(., '⁊', 'e')"/>-->
        <xsl:variable name="sub2" select="replace(., ' ', ' ')"/>
        <xsl:variable name="sub3">
            <xsl:value-of select="replace($sub2, '&amp;', concat('\\', $and))" disable-output-escaping="yes"/>
        </xsl:variable>
        <xsl:variable name="sub4" select="replace($sub3, '%', '\\%')"/>
        <xsl:variable name="sub5" select="replace($sub4, '_', '\\_')"/>
        <!--On échappe les accolades parce que ça doit être considéré comme de la REGEX sinon-->
        <xsl:variable name="sub6" select="replace($sub5, '\{', '\\{')"/>
        <xsl:variable name="sub7" select="replace($sub6, '\}', '\\}')"/>
        <xsl:variable name="sub8" select="replace($sub7, 'α ', '\\textalpha\\ ')"/>
        <xsl:variable name="sub9" select="replace($sub8, 'β ', '\\textbeta\\ ')"/>
        <xsl:variable name="sub10" select="replace($sub9, 'α([,;\}\.!\?])', '\\textalpha$1')"/>
        <xsl:variable name="sub11" select="replace($sub10, 'β([,;\}\.!\?])', '\\textbeta$1')"/>
        <xsl:variable name="sub12" select="replace($sub11, '#', '\\#')"/>
        <!--On échappe les accolades parce que ça doit être considéré comme de la REGEX sinon-->
        <xsl:value-of select="$sub12"/>
    </xsl:template>

    <xsl:template match="tei:lb" mode="these">
        <xsl:text>\\</xsl:text>
    </xsl:template>


    <xsl:template mode="these" match="tei:unclear">
        <xsl:text>?`</xsl:text>
        <xsl:apply-templates mode="these"/>
        <xsl:text>?</xsl:text>
    </xsl:template>

</xsl:stylesheet>
