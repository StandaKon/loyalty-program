#!/usr/bin/env python3
"""Generate complete Czech translations from the current B1 source metadata."""
from pathlib import Path
import argparse
import json
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'force-app/main/default'
NS = 'http://soap.sforce.com/2006/04/metadata'
PREFIX = {'m': NS}
# Salesforce Czech object translations persist six cases; vocative is ignored.
CASES = ['Nominative', 'Genitive', 'Dative', 'Accusative', 'Locative', 'Instrumental']
ET.register_namespace('', NS)


def add(parent, name, value=None):
    element = ET.SubElement(parent, f'{{{NS}}}{name}')
    if value is not None:
        element.text = str(value).lower() if isinstance(value, bool) else str(value)
    return element


def save(path, element, check):
    ET.indent(element, space='    ')
    content = ET.tostring(element, encoding='utf-8', xml_declaration=True) + b'\n'
    if check:
        if not path.exists() or path.read_bytes() != content:
            raise ValueError(f'Translation is missing or outdated: {path.relative_to(ROOT)}')
    else:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(content)


def generate(check=False):
    catalog = json.loads(Path(__file__).with_name('b1_cs.json').read_text())
    counts = dict(objects=0, fields=0, picklist_values=0, validation_rules=0, relationships=0, layouts=0, record_types=0)
    used_picklists = set()
    used_relationships = set()
    source_objects = {p.name: p for p in (OUT / 'objects').iterdir()}
    for obj in catalog['recordTypes']:
        source_objects.setdefault(obj, OUT / 'objects' / obj)
    for obj, source_dir in sorted(source_objects.items()):
        fields = sorted((source_dir / 'fields').glob('*.field-meta.xml'))
        if not fields and obj not in catalog['recordTypes']:
            continue
        translation_dir = OUT / 'objectTranslations' / f'{obj}-cs'
        root = ET.Element(f'{{{NS}}}CustomObjectTranslation')
        object_labels = catalog['objects'].get(obj)
        if obj.endswith(('__c', '__mdt')) and not object_labels:
            raise ValueError(f'Missing Czech object label: {obj}')
        if object_labels:
            counts['objects'] += 1
            for plural, key in [(False, 'singular'), (True, 'plural')]:
                if len(object_labels[key]) != len(CASES):
                    raise ValueError(f'{obj}: all six Salesforce Czech cases are required')
                for case, value in zip(CASES, object_labels[key]):
                    item = add(root, 'caseValues')
                    add(item, 'caseType', case)
                    add(item, 'plural', plural)
                    add(item, 'value', value)
            add(root, 'gender', object_labels['gender'])
        for field_path in fields:
            source = ET.parse(field_path).getroot()
            name = source.findtext('m:fullName', namespaces=PREFIX)
            key = f'{obj}.{name}'
            translated = catalog['fieldOverrides'].get(key, catalog['fields'].get(name))
            if not translated:
                raise ValueError(f'Missing Czech field label: {key}')
            field = ET.Element(f'{{{NS}}}CustomFieldTranslation')
            add(field, 'label', translated)
            add(field, 'name', name)
            values = source.findall('m:valueSet/m:valueSetDefinition/m:value', PREFIX)
            if values:
                assigned = catalog['picklistAssignments'].get(key)
                if not assigned:
                    raise ValueError(f'Missing Czech picklist assignment: {key}')
                used_picklists.add(key)
                translations = catalog['picklists'][assigned]
                source_values = {value.findtext('m:fullName', namespaces=PREFIX) for value in values}
                if source_values != set(translations):
                    raise ValueError(f'Picklist value mismatch: {key}: {source_values ^ set(translations)}')
                for value in values:
                    api_value = value.findtext('m:fullName', namespaces=PREFIX)
                    item = add(field, 'picklistValues')
                    add(item, 'masterLabel', value.findtext('m:label', namespaces=PREFIX))
                    add(item, 'translation', translations[api_value])
                    counts['picklist_values'] += 1
            if source.find('m:relationshipLabel', PREFIX) is not None:
                if key not in catalog['relationships']:
                    raise ValueError(f'Missing Czech relationship label: {key}')
                used_relationships.add(key)
                add(field, 'relationshipLabel', catalog['relationships'][key])
                counts['relationships'] += 1
            save(translation_dir / 'fields' / f'{name}.fieldTranslation-meta.xml', field, check)
            counts['fields'] += 1
        if object_labels and 'nameFieldLabel' in object_labels:
            layout_source = ET.parse(OUT / 'layouts' / f'{obj}-Loyalty Layout.layout-meta.xml').getroot()
            sections = [s for s in layout_source.findall('m:layoutSections', PREFIX)
                        if s.findtext('m:customLabel', namespaces=PREFIX) == 'true']
            if sections:
                layout = add(root, 'layouts')
                add(layout, 'layout', f'{obj}-Loyalty Layout')
                for section_source in sections:
                    source_label = section_source.findtext('m:label', namespaces=PREFIX)
                    if source_label != 'Information':
                        raise ValueError(f'Missing Czech layout section label: {obj}.{source_label}')
                    section = add(layout, 'sections')
                    add(section, 'label', 'Informace')
                    add(section, 'section', source_label)
                counts['layouts'] += 1
            add(root, 'nameFieldLabel', object_labels['nameFieldLabel'])
        for name, translated in catalog['recordTypes'].get(obj, {}).items():
            item = add(root, 'recordTypes')
            add(item, 'label', translated)
            add(item, 'name', name)
            counts['record_types'] += 1
        for path in sorted((source_dir / 'validationRules').glob('*.validationRule-meta.xml')):
            rule = ET.parse(path).getroot().findtext('m:fullName', namespaces=PREFIX)
            key = f'{obj}.{rule}'
            translated = catalog['validationRules'].get(key, catalog['validationRules'].get(rule))
            if not translated:
                raise ValueError(f'Missing Czech validation message: {key}')
            item = add(root, 'validationRules')
            add(item, 'errorMessage', translated)
            add(item, 'name', rule)
            counts['validation_rules'] += 1
        save(translation_dir / f'{obj}-cs.objectTranslation-meta.xml', root, check)
    if used_picklists != set(catalog['picklistAssignments']):
        raise ValueError('Picklist assignments refer to missing source fields')
    if used_relationships != set(catalog['relationships']):
        raise ValueError('Relationship translations refer to missing source fields')
    settings = ET.Element(f'{{{NS}}}LanguageSettings')
    add(settings, 'enableEndUserLanguages', True)
    add(settings, 'enableTranslationWorkbench', True)
    save(OUT / 'settings/Language.settings-meta.xml', settings, check)
    return counts


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Check coverage and generated files without writing.')
    args = parser.parse_args()
    print(json.dumps(generate(args.check), ensure_ascii=False, indent=2))
