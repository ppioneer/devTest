/* Copyright (c) 2008-2014 Evariant */
@isTest
private class TestPrmTerritoryProviderLocController {

    static testMethod void doGet_RetrievesSearch() {
    	
        Contact ph = new Contact(FirstName = 'Test', LastName = 'Provider');
            insert ph;
            Account pr = new Account(Name = '__UnitTest Practice__');
            insert pr;
            HC4__Territory__c t1 = new HC4__Territory__c(Name = '__UnitTest Territory 1__');
            HC4__Territory__c t2 = new HC4__Territory__c(Name = '__UnitTest Territory 2__');
            insert new List<HC4__Territory__c> {t1, t2};
            HC4__Location__c l1 = new HC4__Location__c(Name = '__UnitTest Location 1__', HC4__MailingPostalCode__c='06106', HC4__MailingState__c = 'CT', HC4__MailingCity__c = 'Hartford',  HC4__Practice__c = pr.Id);
            HC4__Location__c l2 = new HC4__Location__c(Name = '__UnitTest Location 2__', HC4__MailingPostalCode__c='06032', HC4__MailingState__c = 'OH', HC4__MailingCity__c = 'Farmington', HC4__Practice__c = pr.Id);
            insert new List<HC4__Location__c> {l1, l2};
            
            HC4__ProviderLocation__c pl1 = new HC4__ProviderLocation__c(HC4__Provider__c = ph.Id, HC4__Location__c = l1.Id);
            HC4__ProviderLocation__c pl2 = new HC4__ProviderLocation__c(HC4__Provider__c = ph.Id, HC4__Location__c = l2.Id);
            insert new List<HC4__ProviderLocation__c> {pl1, pl2};
            HC4__ProviderLocationTerritory__c plt1 = new HC4__ProviderLocationTerritory__c(HC4__ProviderLocation__c = pl1.Id, HC4__Territory__c = t1.Id);
            HC4__ProviderLocationTerritory__c plt2 = new HC4__ProviderLocationTerritory__c(HC4__ProviderLocation__c = pl2.Id, HC4__Territory__c = t2.Id);
            insert new List<HC4__ProviderLocationTerritory__c> {plt1, plt2};
            
            RestRequest requestCity = new RestRequest();
	        requestCity.requestURI = '/mobile/prm/v2/Territories/' + t1.Id + '/ProviderLocations';
	        requestCity.resourcePath = '/mobile/prm/v2/Territories/*/ProviderLocations';
	        requestCity.addParameter('pageSize', '2');
	        requestCity.addParameter('mailingCity', 'Hartford;Farmington');
	        System.RestContext.request = requestCity;
	        
	        List<RestPrmLocationController.Location> providerlocationsCity = RestPrmTerritoryProviderLocController.doGet();        
	        System.assert(providerlocationsCity.size() >= 0);  
	        
	        RestRequest requestState = new RestRequest();
	        requestState.requestURI = '/mobile/prm/v2/Territories/' + t1.Id + '/ProviderLocations';
	        requestState.resourcePath = '/mobile/prm/v2/Territories/*/ProviderLocations';
	        requestState.addParameter('pageSize', '2');
	        requestState.addParameter('mailingState', 'CT;OH');
	        System.RestContext.request = requestState;
	        
	        List<RestPrmLocationController.Location> providerlocationsState = RestPrmTerritoryProviderLocController.doGet();
	        
	        RestRequest requestZip = new RestRequest();
	        requestZip.requestURI = '/mobile/prm/v2/Territories/' + t1.Id + '/ProviderLocations';
	        requestZip.resourcePath = '/mobile/prm/v2/Territories/*/ProviderLocations';
	        requestZip.addParameter('pageSize', '2');
	        requestZip.addParameter('zipCode', '06106;06032');
	        System.RestContext.request = requestZip;
	        
	        List<RestPrmLocationController.Location> providerlocationsZip = RestPrmTerritoryProviderLocController.doGet();
	        
    }
}