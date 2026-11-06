Account partner;
List<Account> partners = [SELECT Id, Name FROM Account WHERE Name = 'EneServis, s.r.o.' AND IsPersonAccount = FALSE LIMIT 1];
if (partners.isEmpty()) {
    partner = new Account(Name = 'EneServis, s.r.o.', Type = 'Partner');
    insert partner;
} else {
    partner = partners[0];
}

Map<String, Reward__c> existingByName = new Map<String, Reward__c>();
for (Reward__c reward : [SELECT Id, Name FROM Reward__c WHERE Name IN ('Sleva 200 Kč na přezutí', 'Sleva 500 Kč na servis', 'Servisní prohlídka zdarma')]) {
    existingByName.put(reward.Name, reward);
}

List<Reward__c> rewards = new List<Reward__c>{
    new Reward__c(
        Id = existingByName.get('Sleva 200 Kč na přezutí')?.Id,
        Name = 'Sleva 200 Kč na přezutí', Partner__c = partner.Id, Points_Cost__c = 500,
        Value_CZK__c = 200, Sort_Order__c = 10, Is_Active__c = true,
        Description__c = '200 Kč dolů z ceny přezutí v EneServisu. Nevztahuje se na nákup pneumatik a disků.'
    ),
    new Reward__c(
        Id = existingByName.get('Sleva 500 Kč na servis')?.Id,
        Name = 'Sleva 500 Kč na servis', Partner__c = partner.Id, Points_Cost__c = 1200,
        Value_CZK__c = 500, Sort_Order__c = 20, Is_Active__c = true,
        Description__c = '500 Kč dolů z ceny jedné servisní zakázky v EneServisu. Nevztahuje se na nákup zboží bez servisní práce.'
    ),
    new Reward__c(
        Id = existingByName.get('Servisní prohlídka zdarma')?.Id,
        Name = 'Servisní prohlídka zdarma', Partner__c = partner.Id, Points_Cost__c = 5000,
        Value_CZK__c = 2000, Sort_Order__c = 30, Is_Active__c = true,
        Description__c = 'Práce technika na pravidelné servisní prohlídce je zdarma. Materiál a další opravy se platí zvlášť.'
    )
};
upsert rewards;
