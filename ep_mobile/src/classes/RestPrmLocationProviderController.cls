/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Locations/*/Providers')
global with sharing class RestPrmLocationProviderController {
    @HttpGet
    global static List<RestPrmProviderController.Provider> doGet() {
        String locationId = uRestController.getParentObjectId('Locations/');
        
         List<HC4__ProviderLocation__c> p = [Select HC4__Provider__c from 
                                             HC4__ProviderLocation__c where HC4__Location__c = :locationId];
         Set<id> providerIds = new Set<Id>();
         for(HC4__ProviderLocation__c pl : p) {
         	providerIds.add(pl.HC4__Provider__c);
         }
         
         List<HC4.uCondition> conditions = new List<HC4.uCondition>();
         conditions.add(new HC4.uCondition('Contact', 'Id', 'IN', HC4.uSet.joinForIn(providerIds)));
         
         return RestPrmProviderController.performGetSearch(conditions, false);
    }
}