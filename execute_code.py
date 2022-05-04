from lxml import etree
import xml.etree.ElementTree as ET
import subprocess
import os
import sys
import re

tei_namespace = 'http://www.tei-c.org/ns/1.0'
teiExample_namespace = 'http://www.tei-c.org/ns/Examples'
NSMAP = {'tei': tei_namespace, 'teiExample': teiExample_namespace}


def retour_subprocess(i):
    return subprocess.run(i.split(), stdout=subprocess.PIPE).stdout.decode().strip("\n")


# https://stackoverflow.com/questions/4760215/running-shell-command-and-capturing-the-output
# https://stackoverflow.com/questions/45222110/how-can-i-remove-n-and-r-n-from-stdout-in-python


def get_last_commit():
    os.chdir('/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes')
    git_hash = retour_subprocess("git rev-parse --verify HEAD")
    os.chdir('/home/mgl/Bureau/These/Edition/outputs/these')
    return git_hash


def execute():
    '''
    On va chercher à évaluer chaque requête
    :return:
    '''
    parser = etree.XMLParser(load_dtd=True, resolve_entities=True)
    with open("/home/mgl/Bureau/These/Edition/hyperregimiento-de-los-principes/Dedans/XML/corpus/these.xml",
              "r") as these:
        parsed_these = etree.parse(these, parser=parser)

    last_commit_p = parsed_these.xpath("//tei:p[@xml:id='dernier_commit']", namespaces=NSMAP)[0]
    last_commit_p.set("n", get_last_commit())

    liste_instructions = parsed_these.xpath("//tei:code[@lang='xpath'][@rend='execute']", namespaces=NSMAP)

    for instruction in liste_instructions:
        base_document = \
            instruction.xpath("ancestor::node()[self::tei:p[@xml:base] or self::tei:div[@xml:base]][1]/@xml:base | @xml:base",
                              namespaces=NSMAP)[0]
        try:
            base_document = instruction.xpath("@xml:base", namespaces=NSMAP)[0]
        except:
            pass
        with open(base_document, 'r') as target_document:
            parsed_target = etree.parse(target_document, parser=parser)

        if instruction.xpath("boolean(descendant::node())") is False:
            corresponding_request = instruction.xpath(f"@corresp", namespaces=NSMAP)[0]
            corresponding_request = corresponding_request.replace("#", "")
            request = \
                parsed_these.xpath(
                    f"//tei:div[@xml:id='requetes_xpath']//tei:item[@xml:id='{corresponding_request}']/tei:code",
                    namespaces=NSMAP)[0].text

        else:
            request = instruction.text

        # lxml.xpath renvoie des types de données différents: liste, entier, float.
        result = parsed_target.xpath(request, namespaces=NSMAP)
        try:
            result = result[0] if isinstance(result, list) else result
        except:
            pass

        # Quand on a un float ou une chaîne de caractères.
        if isinstance(result, etree._ElementUnicodeResult):
            result = str(result)

        instruction.set('result', gestion_type_donnees(result, round_value=3))

    with open(".tmp/these_tmp.xml", "w") as output_these:
        output = etree.tostring(parsed_these, pretty_print=True, encoding='utf-8', xml_declaration=True).decode('utf8')
        # Test pour gérer l'indentation du xml à imprimer tel quel: échec.
        # element = ET.XML(output)
        # ET.indent(element, level=2)
        # output = ET.tostring(element, encoding='unicode')
        output_these.write(str(output))


def gestion_type_donnees(donnee, round_value: int = 2):
    """
    Cette fonction renvoie une chaîne de caractères si c'est un str, un entier si c'est un float sans décimale,
    un float si c'est un float
    :param donnee: la donnée à traiter
    :param round_value: la valeur d'arrondi
    :return:
    """
    try:
        donnee = round(donnee, round_value)
    except:
        pass
    return str(donnee)


def replace_ampersands():
    """
    Cette fonction permet de remplacer l'échapement des esperluettes
    dû à la production d'un document XML par le moteur de transformation XSL.
    Cette production est dûe à la nécessité de produire en sortie des noeuds XML
    (au niveau des tei:egXML)
    :return:
    """
    fichier = "/home/mgl/Bureau/These/Edition/outputs/these/tex/these.tex"
    with open(fichier, 'r') as fichier_these:
        these_as_string = "".join(fichier_these.readlines())
        translated = these_as_string.replace("&", "\&").replace("&amp;", "&")
        translated = these_as_string
    os.remove(fichier)
    with open(fichier, "w") as output_file:
        output_file.write(translated)


if __name__ == '__main__':
    if sys.argv[1] == "execute":
        execute()
    elif sys.argv[1] == "replace_ampersands":
        replace_ampersands()
