#!/usr/bin/env python3
"""Generate the additive B1 metadata. Existing unrelated files are never removed."""
from pathlib import Path
import json
import re
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'force-app/main/default'
NS = 'http://soap.sforce.com/2006/04/metadata'
FIELDS = {}
RULES = {}


def tag(name, value):
    if isinstance(value, bool):
        value = str(value).lower()
    return f'<{name}>{escape(str(value))}</{name}>'


def write(path, root, body):
    path = OUT / path
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(f'<?xml version="1.0" encoding="UTF-8"?>\n<{root} xmlns="{NS}">\n{body}\n</{root}>\n')


def label(api):
    return api.removesuffix('__c').replace('_', ' ')


def field(obj, name, kind='Text', *, length=80, precision=12, scale=0,
          values=None, default=None, reference=None, relation=None, unique=False,
          formula=None, description=None, history=False):
    data = {'type': kind, 'formula': formula, 'unique': unique}
    FIELDS.setdefault(obj, {})[name] = data
    body = tag('fullName', name)
    if unique:
        body += tag('caseSensitive', False)
    if default is not None:
        body += tag('defaultValue', default)
    if kind == 'Lookup':
        body += tag('deleteConstraint', 'SetNull' if reference in ['User', obj] else 'Restrict')
    body += tag('description', description or f'{label(name)} for the EneOil loyalty program.')
    if unique:
        body += tag('externalId', True)
    if formula:
        body += f'<formula><![CDATA[{formula}]]></formula>'
        body += tag('formulaTreatBlanksAs', 'BlankAsZero' if kind in ['Number', 'Currency'] else 'BlankAsBlank')
    body += tag('label', label(name))
    if kind in ['Text', 'LongTextArea'] and not formula:
        body += tag('length', 32768 if kind == 'LongTextArea' else length)
    if kind in ['Number', 'Currency']:
        body += tag('precision', precision)
    if reference:
        body += tag('referenceTo', reference)
        body += tag('relationshipLabel', label(relation or obj.removesuffix('__c')))
        body += tag('relationshipName', relation or obj.removesuffix('__c'))
        if kind == 'MasterDetail':
            body += tag('relationshipOrder', 0) + tag('reparentableMasterDetail', False)
    if kind in ['Number', 'Currency']:
        body += tag('scale', scale)
    if history:
        body += tag('trackHistory', True)
    body += tag('type', kind)
    if unique:
        body += tag('unique', True)
    if values:
        body += '<valueSet><restricted>true</restricted><valueSetDefinition><sorted>false</sorted>'
        for value in values:
            body += '<value>' + tag('fullName', value) + tag('default', value == default) + tag('label', label(value)) + '</value>'
        body += '</valueSetDefinition></valueSet>'
    if kind == 'LongTextArea':
        body += tag('visibleLines', 3)
    if kind == 'MasterDetail':
        body += tag('writeRequiresMasterRead', False)
    # Picklists express their default inside the value set, not defaultValue.
    if values and default is not None:
        body = body.replace(tag('defaultValue', default), '')
    write(f'objects/{obj}/fields/{name}.field-meta.xml', 'CustomField', body)


def rule(obj, name, formula, message):
    RULES.setdefault(obj, []).append(name)
    body = tag('fullName', name) + tag('active', True) + tag('description', message)
    body += tag('errorMessage', message) + f'<errorConditionFormula><![CDATA[{formula}]]></errorConditionFormula>'
    write(f'objects/{obj}/validationRules/{name}.validationRule-meta.xml', 'ValidationRule', body)


def required(obj, names, condition='TRUE'):
    terms = [f'ISBLANK(TEXT({n}))' if FIELDS[obj][n]['type'] == 'Picklist' else f'ISBLANK({n})' for n in names]
    rule(obj, 'Required_Program_Fields', f'AND({condition}, OR({", ".join(terms)}))', 'Complete all required program fields.')


def custom_object(api, singular, plural, sharing, prefix=None):
    body = tag('deploymentStatus', 'Deployed')
    body += tag('description', f'{singular} records for EneOil Klub. See the B1 data model design.')
    body += tag('enableHistory', True) + tag('enableReports', True) + tag('enableSearch', True)
    body += tag('externalSharingModel', sharing) + tag('label', singular)
    body += '<nameField>'
    if prefix:
        body += tag('displayFormat', prefix + '-{00000000}')
    body += tag('label', singular + (' Number' if prefix else ' Name'))
    if prefix:
        body += tag('startingNumber', 1)
    body += tag('type', 'AutoNumber' if prefix else 'Text') + '</nameField>'
    body += tag('pluralLabel', plural) + tag('sharingModel', sharing) + tag('visibility', 'Public')
    write(f'objects/{api}/{api}.object-meta.xml', 'CustomObject', body)
    write(f'tabs/{api}.tab-meta.xml', 'CustomTab', tag('customObject', True) + tag('motif', 'Custom42: Treasure chest'))


def permissions(name, title, objects, field_access, *, view_all=False, tabs=False, custom_permissions=()):
    objects = dict(objects)
    if 'Account' in objects:
        objects['Contact'] = objects['Account']
    body = tag('description', f'{title}. Additive permissions only; record access remains governed by sharing.')
    for permission in custom_permissions:
        body += '<customPermissions>' + tag('enabled', True) + tag('name', permission) + '</customPermissions>'
    for obj, access in sorted(objects.items()):
        for name_field, data in sorted(FIELDS.get(obj, {}).items()):
            if data['type'] == 'MasterDetail':
                continue
            read, edit = field_access(obj, name_field, data, access)
            if not read:
                continue
            body += '<fieldPermissions>' + tag('editable', edit and data['type'] not in ['MasterDetail', 'Summary'] and not data['formula'])
            body += tag('field', f'{obj}.{name_field}') + tag('readable', True) + '</fieldPermissions>'
    if name in ['Loyalty_Member', 'Loyalty_Manager', 'Loyalty_Back_Office']:
        for standard_field in ['Contact.Email', 'Contact.MobilePhone']:
            body += '<fieldPermissions>' + tag('editable', name == 'Loyalty_Manager')
            body += tag('field', standard_field) + tag('readable', True) + '</fieldPermissions>'
    if name == 'Loyalty_Manager':
        for standard_field in ['AuthorizationFormConsent.Status']:
            body += '<fieldPermissions>' + tag('editable', False) + tag('field', standard_field) + tag('readable', True) + '</fieldPermissions>'
    body += tag('hasActivationRequired', False) + tag('label', title)
    for obj, access in sorted(objects.items()):
        body += '<objectPermissions>' + tag('allowCreate', 'C' in access) + tag('allowDelete', False)
        body += tag('allowEdit', 'U' in access) + tag('allowRead', True)
        body += tag('modifyAllRecords', False) + tag('object', obj)
        body += tag('viewAllRecords', view_all and obj != 'Point_Ledger__c') + '</objectPermissions>'
    if tabs:
        for obj in sorted(set(objects) & set(CUSTOM)):
            body += '<tabSettings>' + tag('tab', obj) + tag('visibility', 'Visible') + '</tabSettings>'
    if name == 'Loyalty_Transaction_Import':
        body += '<userPermissions>' + tag('enabled', True) + tag('name', 'ApiEnabled') + '</userPermissions>'
    write(f'permissionsets/{name}.permissionset-meta.xml', 'PermissionSet', body)


CUSTOM = {
    'Loyalty_Transaction__c': ('Loyalty Transaction', 'Loyalty Transactions', 'Private', 'TX'),
    'Loyalty_Campaign__c': ('Loyalty Campaign', 'Loyalty Campaigns', 'Read', None),
    'Point_Ledger__c': ('Point Ledger Entry', 'Point Ledger Entries', 'ControlledByParent', 'PT'),
    'Reward__c': ('Reward', 'Rewards', 'Read', None),
    'Voucher__c': ('Voucher', 'Vouchers', 'Private', 'VCH'),
}
for api, args in CUSTOM.items():
    custom_object(api, *args)

field('Account', 'Member_Number__c', length=30, unique=True)
field('Account', 'Membership_Status__c', 'Picklist', values=['Active', 'Blocked', 'Cancelled'], history=True)
field('Account', 'Joined_At__c', 'DateTime')
for name in ['Vehicle_Make__c', 'Vehicle_Model__c']:
    field('Account', name)
field('Account', 'Vehicle_Fuel_Type__c', 'Picklist', values=['Petrol', 'Diesel', 'LPG', 'CNG', 'Electric', 'Hybrid', 'Other'])
field('Account', 'Vehicle_Year__c', 'Number', precision=4)
field('Account', 'Vehicle_Registration__c', length=20)
field('Account', 'Profile_Complete__c', 'Checkbox', formula='AND(NOT(ISBLANK(Vehicle_Make__c)), NOT(ISBLANK(Vehicle_Model__c)), NOT(ISBLANK(TEXT(Vehicle_Fuel_Type__c))), NOT(ISBLANK(Vehicle_Year__c)), Vehicle_Year__c >= 1900, Vehicle_Year__c <= YEAR(TODAY()) + 1)')
field('Account', 'Marketing_Consent__c', 'Checkbox', default='false')
field('Account', 'Voucher_Budget_Year__c', 'Number', precision=4)
field('Account', 'Voucher_Budget_CZK__c', 'Currency', precision=16, scale=2)
FIELDS['Account']['Points_Balance__c'] = {'type': 'Summary', 'formula': None}
write('objects/Account/fields/Points_Balance__c.field-meta.xml', 'CustomField',
      tag('fullName', 'Points_Balance__c') + tag('description', 'Signed sum of all immutable loyalty point entries.') + tag('label', 'Points Balance')
      + tag('summarizedField', 'Point_Ledger__c.Points__c') + tag('summaryForeignKey', 'Point_Ledger__c.Member__c') + tag('summaryOperation', 'sum') + tag('type', 'Summary'))
required('Account', ['Membership_Status__c', 'Joined_At__c'], 'NOT(ISBLANK(Member_Number__c))')
rule('Account', 'Member_Must_Be_Person', 'AND(NOT(ISBLANK(Member_Number__c)), NOT(IsPersonAccount))', 'Only a Person Account can be a loyalty member.')
rule('Account', 'Member_Number_Immutable', 'AND(NOT(ISNEW()), NOT(ISBLANK(PRIORVALUE(Member_Number__c))), ISCHANGED(Member_Number__c))', 'A member number cannot be changed or cleared.')
rule('Account', 'Vehicle_Year_Valid', 'AND(NOT(ISBLANK(Vehicle_Year__c)), OR(Vehicle_Year__c < 1900, Vehicle_Year__c > YEAR(TODAY()) + 1))', 'Enter a valid vehicle year.')
rule('Account', 'Balance_Not_Negative', 'Points_Balance__c < 0', 'The points balance cannot be negative.')
rule('Account', 'Budget_Valid', 'OR(Voucher_Budget_CZK__c < 0, AND(ISBLANK(Voucher_Budget_Year__c), NOT(ISBLANK(Voucher_Budget_CZK__c))), AND(NOT(ISBLANK(Voucher_Budget_Year__c)), ISBLANK(Voucher_Budget_CZK__c)), AND(NOT(ISBLANK(Voucher_Budget_Year__c)), OR(IsPersonAccount, Voucher_Budget_Year__c < 1900, Voucher_Budget_Year__c > 9999)))', 'Enter a nonnegative budget and its year on a Business Account.')

T = 'Loyalty_Transaction__c'
field(T, 'Member__c', 'Lookup', reference='Account', relation='Loyalty_Transactions')
field(T, 'POS_Transaction_Id__c', length=100, unique=True)
field(T, 'Purchased_At__c', 'DateTime')
for name in ['Total_Amount__c', 'Fuel_Amount__c', 'Other_Amount__c']:
    field(T, name, 'Currency', precision=16, scale=2)
field(T, 'Liters__c', 'Number', precision=12, scale=3)
field(T, 'Processing_Status__c', 'Picklist', values=['Pending', 'Processed', 'Error'], default='Pending')
field(T, 'Processing_Error__c', 'LongTextArea')
field(T, 'Processed_At__c', 'DateTime')
for name in ['Base_Fuel_Points__c', 'Base_Other_Points__c', 'Campaign_Points__c']:
    field(T, name, 'Number')
field(T, 'Total_Points__c', 'Number', formula='Base_Fuel_Points__c + Base_Other_Points__c + Campaign_Points__c')
required(T, ['Member__c', 'POS_Transaction_Id__c', 'Purchased_At__c', 'Total_Amount__c', 'Fuel_Amount__c', 'Other_Amount__c', 'Liters__c', 'Processing_Status__c'])
rule(T, 'Amounts_Valid', 'OR(Total_Amount__c <= 0, Fuel_Amount__c < 0, Other_Amount__c < 0, Liters__c < 0, Fuel_Amount__c + Other_Amount__c <> Total_Amount__c, AND(Fuel_Amount__c > 0, Liters__c <= 0), AND(Fuel_Amount__c = 0, Liters__c <> 0))', 'Amounts must be nonnegative, add up to the total, and fuel amount must match the presence of liters.')
rule(T, 'Member_Valid', 'OR(NOT(Member__r.IsPersonAccount), ISBLANK(Member__r.Member_Number__c))', 'Select a registered Person Account member.')
rule(T, 'Purchase_Not_Future', 'Purchased_At__c > NOW()', 'The purchase date cannot be in the future.')
rule(T, 'Processing_State_Valid', 'OR(AND(ISPICKVAL(Processing_Status__c, "Processed"), OR(ISBLANK(Processed_At__c), ISBLANK(Base_Fuel_Points__c), ISBLANK(Base_Other_Points__c), ISBLANK(Campaign_Points__c))), AND(ISPICKVAL(Processing_Status__c, "Error"), ISBLANK(Processing_Error__c)), Base_Fuel_Points__c < 0, Base_Other_Points__c < 0, Campaign_Points__c < 0)', 'Complete the processing result or error details; point totals cannot be negative.')
rule(T, 'Processed_Transaction_Immutable', 'AND(NOT(ISNEW()), ISPICKVAL(PRIORVALUE(Processing_Status__c), "Processed"))', 'A processed purchase cannot be edited. Create a correction instead.')

C = 'Loyalty_Campaign__c'
field(C, 'Is_Enabled__c', 'Checkbox', default='false', history=True)
field(C, 'Start_Date__c', 'Date', history=True)
field(C, 'End_Date__c', 'Date', history=True)
field(C, 'Condition_Field__c', 'Picklist', values=['Liters', 'OtherAmount', 'FuelAmount', 'TotalAmount'], history=True)
field(C, 'Threshold__c', 'Number', precision=16, scale=3, history=True)
field(C, 'Reward_Type__c', 'Picklist', values=['FixedBonus', 'BaseMultiplier'], history=True)
field(C, 'Reward_Value__c', 'Number', precision=12, scale=4, history=True)
field(C, 'Member_Description__c', 'LongTextArea')
field(C, 'Is_Portal_Visible__c', 'Checkbox', formula='AND(Is_Enabled__c, Start_Date__c <= TODAY(), End_Date__c >= TODAY())')
required(C, ['Start_Date__c', 'End_Date__c', 'Condition_Field__c', 'Threshold__c', 'Reward_Type__c', 'Reward_Value__c'])
rule(C, 'Campaign_Values_Valid', 'OR(Start_Date__c > End_Date__c, Threshold__c < 0, AND(NOT(ISPICKVAL(Condition_Field__c, "Liters")), Threshold__c <> ROUND(Threshold__c, 2)), AND(ISPICKVAL(Reward_Type__c, "FixedBonus"), OR(Reward_Value__c <= 0, MOD(Reward_Value__c, 1) <> 0)), AND(ISPICKVAL(Reward_Type__c, "BaseMultiplier"), Reward_Value__c < 1))', 'Check the campaign dates, threshold, and reward value.')

L = 'Point_Ledger__c'
field(L, 'Member__c', 'MasterDetail', reference='Account', relation='Point_Ledger_Entries')
field(L, 'Points__c', 'Number')
field(L, 'Entry_Type__c', 'Picklist', values=['PurchaseBase', 'CampaignBonus', 'ProfileBonus', 'MarketingBonus', 'Redemption', 'Refund', 'Adjustment'])
field(L, 'Occurred_At__c', 'DateTime')
field(L, 'Unique_Key__c', length=200, unique=True)
for name, ref, relation in [('Transaction__c', T, 'Point_Entries'), ('Campaign__c', C, 'Point_Entries'), ('Voucher__c', 'Voucher__c', 'Point_Entries'), ('Reverses_Entry__c', L, 'Reversal_Entries')]:
    field(L, name, 'Lookup', reference=ref, relation=relation)
field(L, 'Reason__c', length=255)
field(L, 'Applied_Condition_Field__c', 'Picklist', values=['Liters', 'OtherAmount', 'FuelAmount', 'TotalAmount'])
field(L, 'Applied_Threshold__c', 'Number', precision=16, scale=3)
field(L, 'Applied_Reward_Type__c', 'Picklist', values=['FixedBonus', 'BaseMultiplier'])
field(L, 'Applied_Reward_Value__c', 'Number', precision=12, scale=4)
required(L, ['Points__c', 'Entry_Type__c', 'Occurred_At__c', 'Unique_Key__c'])
rule(L, 'Immutable_Entry', 'NOT(ISNEW())', 'Point entries cannot be edited. Create a compensating entry.')
rule(L, 'Member_Valid', 'OR(NOT(Member__r.IsPersonAccount), ISBLANK(Member__r.Member_Number__c))', 'Select a registered Person Account member.')
rule(L, 'Signs_Valid', 'OR(AND(OR(ISPICKVAL(Entry_Type__c, "PurchaseBase"), ISPICKVAL(Entry_Type__c, "CampaignBonus")), Points__c < 0), AND(OR(ISPICKVAL(Entry_Type__c, "ProfileBonus"), ISPICKVAL(Entry_Type__c, "MarketingBonus"), ISPICKVAL(Entry_Type__c, "Refund")), Points__c <= 0), AND(ISPICKVAL(Entry_Type__c, "Redemption"), Points__c >= 0), AND(ISPICKVAL(Entry_Type__c, "Adjustment"), Points__c = 0))', 'The points sign must match the entry type.')
is_purchase = 'OR(ISPICKVAL(Entry_Type__c, "PurchaseBase"), ISPICKVAL(Entry_Type__c, "CampaignBonus"))'
is_voucher = 'OR(ISPICKVAL(Entry_Type__c, "Redemption"), ISPICKVAL(Entry_Type__c, "Refund"))'
rule(L, 'Source_Required', f'OR(AND({is_purchase}, ISBLANK(Transaction__c)), AND(NOT({is_purchase}), NOT(ISBLANK(Transaction__c))), AND(ISPICKVAL(Entry_Type__c, "CampaignBonus"), ISBLANK(Campaign__c)), AND(NOT(ISPICKVAL(Entry_Type__c, "CampaignBonus")), NOT(ISBLANK(Campaign__c))), AND({is_voucher}, ISBLANK(Voucher__c)), AND(NOT({is_voucher}), NOT(ISBLANK(Voucher__c))), AND(ISPICKVAL(Entry_Type__c, "Refund"), ISBLANK(Reverses_Entry__c)), AND(NOT(ISPICKVAL(Entry_Type__c, "Refund")), NOT(ISBLANK(Reverses_Entry__c))), AND(OR(ISPICKVAL(Entry_Type__c, "Adjustment"), ISPICKVAL(Entry_Type__c, "Refund")), ISBLANK(Reason__c)))', 'Source relationships and reason must match the entry type.')
rule(L, 'Source_Member_Matches', 'OR(AND(NOT(ISBLANK(Transaction__c)), Member__c <> Transaction__r.Member__c), AND(NOT(ISBLANK(Voucher__c)), Member__c <> Voucher__r.Member__c), AND(NOT(ISBLANK(Reverses_Entry__c)), OR(Member__c <> Reverses_Entry__r.Member__c, NOT(ISPICKVAL(Reverses_Entry__r.Entry_Type__c, "Redemption")), Voucher__c <> Reverses_Entry__r.Voucher__c, Points__c <> -Reverses_Entry__r.Points__c)))', 'The source must belong to the same member and a refund must reverse the original redemption.')
rule(L, 'Campaign_Snapshot_Required', 'AND(ISPICKVAL(Entry_Type__c, "CampaignBonus"), OR(ISBLANK(TEXT(Applied_Condition_Field__c)), ISBLANK(Applied_Threshold__c), ISBLANK(TEXT(Applied_Reward_Type__c)), ISBLANK(Applied_Reward_Value__c)))', 'Store the applied campaign condition and reward values.')
rule(L, 'Redemption_Amount_Matches', 'AND(ISPICKVAL(Entry_Type__c, "Redemption"), Points__c <> -Voucher__r.Points_Spent__c)', 'The redemption must equal the voucher points price.')

R = 'Reward__c'
field(R, 'Partner__c', 'Lookup', reference='Account', relation='Loyalty_Rewards', history=True)
field(R, 'Points_Cost__c', 'Number', history=True)
field(R, 'Value_CZK__c', 'Currency', precision=16, scale=2, history=True)
field(R, 'Is_Active__c', 'Checkbox', default='false', history=True)
field(R, 'Description__c', 'LongTextArea')
field(R, 'Sort_Order__c', 'Number', precision=5)
required(R, ['Partner__c', 'Points_Cost__c', 'Value_CZK__c'])
rule(R, 'Reward_Values_Valid', 'OR(Points_Cost__c <= 0, Value_CZK__c < 0, Partner__r.IsPersonAccount, NOT(ISPICKVAL(Partner__r.Type, "Partner")), AND(Is_Active__c, ISBLANK(Description__c)))', 'Use a Business Account partner, a positive points price, and complete the active reward description.')

V = 'Voucher__c'
for name, ref, relation in [('Member__c', 'Account', 'Member_Vouchers'), ('Reward__c', R, 'Issued_Vouchers'), ('Partner__c', 'Account', 'Partner_Vouchers'), ('Redeemed_By__c', 'User', 'Redeemed_Vouchers')]:
    field(V, name, 'Lookup', reference=ref, relation=relation)
field(V, 'Code__c', length=13, unique=True)
field(V, 'Request_Key__c', length=80, unique=True)
field(V, 'Status__c', 'Picklist', values=['Issued', 'Redeemed', 'Cancelled'], default='Issued')
field(V, 'Points_Spent__c', 'Number')
field(V, 'Value_CZK__c', 'Currency', precision=16, scale=2)
field(V, 'Reward_Name__c')
field(V, 'Reward_Description__c', 'LongTextArea')
for name in ['Issued_At__c', 'Redeemed_At__c', 'Cancelled_At__c', 'Email_Sent_At__c']:
    field(V, name, 'DateTime')
field(V, 'Cancellation_Reason__c', length=255)
field(V, 'Email_Status__c', 'Picklist', values=['Pending', 'Sent', 'Error'], default='Pending')
field(V, 'Email_Error__c', length=255)
required(V, ['Member__c', 'Reward__c', 'Partner__c', 'Code__c', 'Request_Key__c', 'Status__c', 'Points_Spent__c', 'Value_CZK__c', 'Reward_Name__c', 'Reward_Description__c', 'Issued_At__c', 'Email_Status__c'])
rule(V, 'Voucher_Values_Valid', 'OR(Points_Spent__c <= 0, Value_CZK__c < 0, NOT(Member__r.IsPersonAccount), ISBLANK(Member__r.Member_Number__c), Partner__r.IsPersonAccount, NOT(REGEX(Code__c, "ENE-[ABCDEFGHJKMNPQRSTUVWXYZ23456789]{4}-[ABCDEFGHJKMNPQRSTUVWXYZ23456789]{4}")))', 'Use a registered member, a Business Account partner, positive points, and a valid ENE voucher code.')
rule(V, 'Issue_Source_Valid', 'AND(ISNEW(), OR(NOT(Reward__r.Is_Active__c), Partner__c <> Reward__r.Partner__c, Points_Spent__c <> Reward__r.Points_Cost__c, Value_CZK__c <> Reward__r.Value_CZK__c, NOT(ISPICKVAL(Member__r.Membership_Status__c, "Active")), NOT(ISPICKVAL(Status__c, "Issued"))))', 'Only an active member can receive an active reward at its current price and partner.')
immutable = ['Member__c', 'Reward__c', 'Partner__c', 'Code__c', 'Request_Key__c', 'Points_Spent__c', 'Value_CZK__c', 'Reward_Name__c', 'Reward_Description__c', 'Issued_At__c']
# ISCHANGED does not support LongTextArea. That field is write-protected by FLS.
rule(V, 'Issue_Details_Immutable', 'AND(NOT(ISNEW()), OR(' + ','.join(f'ISCHANGED({n})' for n in immutable if n != 'Reward_Description__c') + '))', 'Voucher issue details cannot be changed.')
rule(V, 'Status_Transition_Valid', 'AND(NOT(ISNEW()), ISCHANGED(Status__c), NOT(ISPICKVAL(PRIORVALUE(Status__c), "Issued")))', 'A redeemed or cancelled voucher cannot change status again.')
rule(V, 'State_Details_Required', 'OR(AND(ISPICKVAL(Status__c, "Redeemed"), OR(ISBLANK(Redeemed_At__c), ISBLANK(Redeemed_By__c))), AND(ISPICKVAL(Status__c, "Cancelled"), OR(ISBLANK(Cancelled_At__c), ISBLANK(Cancellation_Reason__c))), AND(ISPICKVAL(Email_Status__c, "Sent"), ISBLANK(Email_Sent_At__c)), AND(ISPICKVAL(Email_Status__c, "Error"), ISBLANK(Email_Error__c)))', 'Complete the voucher state and email audit details.')

field('AuthorizationForm', 'Consent_Type__c', 'Picklist', values=['Terms', 'Marketing'])
field('AuthorizationFormConsent', 'Consent_Action__c', 'Picklist', values=['Accepted', 'Declined', 'Withdrawn'])

M = 'Loyalty_Settings__mdt'
write(f'objects/{M}/{M}.object-meta.xml', 'CustomObject', tag('description', 'Global loyalty calculation parameters, maintained by an administrator.') + tag('label', 'Loyalty Settings') + tag('pluralLabel', 'Loyalty Settings') + tag('visibility', 'Public'))
for name, precision, scale in [('Fuel_Points_Per_Liter__c', 8, 0), ('Other_CZK_Per_Point__c', 12, 2), ('Profile_Bonus_Points__c', 12, 0), ('Marketing_Bonus_Points__c', 12, 0)]:
    field(M, name, 'Number', precision=precision, scale=scale)
    path = OUT / f'objects/{M}/fields/{name}.field-meta.xml'
    path.write_text(path.read_text().replace('<label>', '<fieldManageability>DeveloperControlled</fieldManageability><label>', 1))
body = tag('label', 'Default') + tag('protected', False)
for name, value in [('Fuel_Points_Per_Liter__c', 1), ('Other_CZK_Per_Point__c', 20), ('Profile_Bonus_Points__c', 100), ('Marketing_Bonus_Points__c', 50)]:
    body += '<values>' + tag('field', name) + f'<value xsi:type="xsd:double" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">{value}</value></values>'
write('customMetadata/Loyalty_Settings.Default.md-meta.xml', 'CustomMetadata', body)

for api in CUSTOM:
    body = '<layoutSections>' + tag('customLabel', False) + tag('detailHeading', True) + tag('editHeading', True) + tag('label', 'Information')
    for parity in [0, 1]:
        body += '<layoutColumns>'
        names = ['Name'] + list(FIELDS[api])
        for name in names[parity::2]:
            readonly = name == 'Name' and CUSTOM[api][3] or name != 'Name' and FIELDS[api][name]['formula']
            behavior = 'Readonly' if readonly else ('Required' if name == 'Name' or name == 'Member__c' and api == L else 'Edit')
            body += '<layoutItems>' + tag('behavior', behavior) + tag('field', name) + '</layoutItems>'
        body += '</layoutColumns>'
    body += tag('style', 'TwoColumnsTopToBottom') + '</layoutSections>'
    body += tag('showEmailCheckbox', False) + tag('showHighlightsPanel', False) + tag('showInteractionLogPanel', False) + tag('showRunAssignmentRulesCheckbox', False) + tag('showSubmitAndAttachButton', False)
    write(f'layouts/{api}-Loyalty Layout.layout-meta.xml', 'Layout', body)

for api, title in [('Loyalty_Manage_Campaigns', 'Manage Loyalty Campaigns'), ('Loyalty_Service_Operator', 'Verify Loyalty Vouchers')]:
    write(f'customPermissions/{api}.customPermission-meta.xml', 'CustomPermission', tag('description', title) + tag('label', title))

readwrite = lambda obj, name, data, access: (True, 'U' in access or 'C' in access)
member_hidden = {T: {'POS_Transaction_Id__c', 'Processing_Error__c'}, L: {'Unique_Key__c', 'Reason__c', 'Reverses_Entry__c', 'Applied_Condition_Field__c', 'Applied_Threshold__c', 'Applied_Reward_Type__c', 'Applied_Reward_Value__c'}, V: {'Request_Key__c', 'Value_CZK__c', 'Redeemed_By__c', 'Cancellation_Reason__c', 'Email_Error__c'}}
member_account = {'Member_Number__c', 'Membership_Status__c', 'Joined_At__c', 'Points_Balance__c', 'Vehicle_Make__c', 'Vehicle_Model__c', 'Vehicle_Fuel_Type__c', 'Vehicle_Year__c', 'Vehicle_Registration__c', 'Profile_Complete__c', 'Marketing_Consent__c'}
permissions('Loyalty_Member', 'Loyalty Member', {o: 'R' for o in ['Account', *CUSTOM]}, lambda o, n, d, a: ((n in member_account if o == 'Account' else n not in member_hidden.get(o, set())), False))
permissions('Loyalty_Campaign_Manager', 'Loyalty Campaign Manager', {C: 'CRU', R: 'CRU', 'Account': 'R'}, lambda o,n,d,a: (o != 'Account', o in [C,R]), tabs=True, custom_permissions=['Loyalty_Manage_Campaigns'])
permissions('Loyalty_Manager', 'Loyalty Manager', {'Account': 'CRU', T: 'CR', C: 'CRU', R: 'CRU', L: 'R', V: 'R', 'AuthorizationForm': 'R', 'AuthorizationFormText': 'R', 'AuthorizationFormConsent': 'R'}, lambda o,n,d,a: (True, ('U' in a or 'C' in a) and not (o == 'Account' and n in {'Points_Balance__c', 'Member_Number__c', 'Marketing_Consent__c', 'Joined_At__c'}) and not (o == T and n in {'Processing_Status__c', 'Processing_Error__c', 'Processed_At__c', 'Base_Fuel_Points__c', 'Base_Other_Points__c', 'Campaign_Points__c'})), tabs=True, custom_permissions=['Loyalty_Manage_Campaigns'])
permissions('Loyalty_Back_Office', 'Loyalty Back Office', {'Account': 'R', T: 'CR', C: 'R', R: 'R', L: 'R', V: 'R'}, lambda o,n,d,a: (True, o == T and n in {'Member__c', 'POS_Transaction_Id__c', 'Purchased_At__c', 'Total_Amount__c', 'Fuel_Amount__c', 'Other_Amount__c', 'Liters__c'}), tabs=True)
permissions('Loyalty_Transaction_Import', 'Loyalty Transaction Import', {'Account': 'R', T: 'CR'}, lambda o,n,d,a: (n in {'Member_Number__c', 'Membership_Status__c'} if o == 'Account' else True, o == T and n in {'Member__c', 'POS_Transaction_Id__c', 'Purchased_At__c', 'Total_Amount__c', 'Fuel_Amount__c', 'Other_Amount__c', 'Liters__c'}))
report_account = {'Member_Number__c', 'Membership_Status__c', 'Joined_At__c', 'Points_Balance__c', 'Voucher_Budget_Year__c', 'Voucher_Budget_CZK__c'}
permissions('Loyalty_Reporting', 'Loyalty Reporting', {o:'R' for o in ['Account', *CUSTOM]}, lambda o,n,d,a: ((n in report_account if o == 'Account' else n not in {'Code__c','Request_Key__c','Email_Error__c','Processing_Error__c','Reason__c','Cancellation_Reason__c'}), False), view_all=True)
permissions('Loyalty_Service_Operator', 'Loyalty Service Operator', {}, readwrite, custom_permissions=['Loyalty_Service_Operator'])

body = ''
for obj, fieldname in [('Account', 'Id'), (T, 'Member__c'), (V, 'Member__c')]:
    body += '<accessMappings>' + tag('accessLevel', 'Read') + tag('object', obj) + tag('objectField', fieldname) + tag('userField', 'Account') + '</accessMappings>'
body += tag('description', 'Read access to the current member account and its transactions and vouchers. Ledger inherits Account access.')
body += tag('name', 'EneOil Member Data')
for profile in ['EneOil Member', 'Customer Community User', 'Customer Community Login User']:
    body += tag('profiles', profile)
write('sharingSets/EneOil_Member_Data.sharingSet-meta.xml', 'SharingSet', body)

write('groups/Loyalty_Campaign_Managers.group-meta.xml', 'Group', tag('doesIncludeBosses', False) + tag('name', 'Loyalty Campaign Managers'))
for obj, flag in [(C, 'Is_Enabled__c'), (R, 'Is_Active__c')]:
    body = '<sharingCriteriaRules>' + tag('fullName', 'Campaign_Managers_Edit') + tag('accessLevel', 'Edit')
    body += tag('booleanFilter', '1 OR 2')
    body += tag('description', 'Internal campaign managers can maintain all shared catalogue records, without Delete or Modify All.')
    body += tag('label', 'Campaign Managers Edit')
    body += '<sharedTo>' + tag('group', 'Loyalty_Campaign_Managers') + '</sharedTo>'
    for value in ['true', 'false']:
        body += '<criteriaItems>' + tag('field', flag) + tag('operation', 'equals') + tag('value', value) + '</criteriaItems>'
    body += '</sharingCriteriaRules>'
    write(f'sharingRules/{obj}.sharingRules-meta.xml', 'SharingRules', body)

# Only define the approved external restriction; preserve internal access already used by the org.
write('objects/Account/Account.object-meta.xml', 'CustomObject', tag('enableHistory', True) + tag('externalSharingModel', 'Private'))

if __name__ == '__main__':
    from generate_b1_translations import generate
    print(json.dumps({'custom_objects': len(CUSTOM), 'fields': sum(map(len, FIELDS.values())), 'validation_rules': sum(map(len, RULES.values())), 'permission_sets': 7, 'czech_translations': generate()}, indent=2))
