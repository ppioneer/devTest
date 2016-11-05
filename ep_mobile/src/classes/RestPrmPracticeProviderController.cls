/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Practices/*/Providers')
global with sharing class RestPrmPracticeProviderController {
	 @HttpGet
    global static List<RestPrmProviderController.Provider> doGet() {
    	String practiceId = uRestController.getParentObjectId('Practices/');
    	
    	List<HC4__ProviderPractice__c> p = [Select HC4__Provider__c from 
                                             HC4__ProviderPractice__c where HC4__Practice__c = :practiceId];
         Set<id> providerIds = new Set<Id>();
         for(HC4__ProviderPractice__c pl : p) {
            providerIds.add(pl.HC4__Provider__c);
         }
         
         List<HC4.uCondition> conditions = new List<HC4.uCondition>();
         conditions.add(new HC4.uCondition('Contact', 'Id', 'IN', HC4.uSet.joinForIn(providerIds)));
         
         return RestPrmProviderController.performGetSearch(conditions, true);
    }
}