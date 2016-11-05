/* Copyright (c) 2008-2014 Evariant */
@isTest(SeeAllData=false) 
private class TestRestPrmReferencedDataController {
    
    static testMethod void doGet_RetrievesUserData() {
        
        Profile pf = [select id from profile where name =: 'System Administrator' limit 1];

        User u = new User(alias = 'ux28', email='987test234@testorg.com',
                                emailencodingkey='UTF-8', 
                                lastname='Testing', 
                                languagelocalekey='en_US',
                                localesidkey='en_US', 
                                profileid = pf.Id,  
                                country='United States', 
                                CommunityNickname = 'u1',
                                timezonesidkey='America/Los_Angeles', 
                                username='987test234@testorg.com');
                                
        insert u;                       
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Reference/Search/';
        request.resourcePath = '/mobile/prm/v2/Reference/Search/*';        
        request.addParameter('objectName', 'User');
        System.RestContext.request = request;        
        List<RestPrmReferencedDataController.RestPrmReferencedData> results = RestPrmReferencedDataController.doGet();
        
        System.assert(1 <= results.size());         
    }
    
    static testMethod void doGet_RetrievesProvidersData() {
        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Contact provider1 = new Contact (
           FirstName = '__Test__',
           LastName = '__Provider__'
        );
        insert provider1;               
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Reference/Search/';
        request.resourcePath = '/mobile/prm/v2/Reference/Search/';        
        request.addParameter('objectName', 'Contact');
        System.RestContext.request = request;
        
        List<RestPrmReferencedDataController.RestPrmReferencedData> results = RestPrmReferencedDataController.doGet();
        
        System.assert(2 >= results.size());         
    }
    
    static testMethod void doGet_RetrievesPracticesData() {
        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;                        
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Reference/Search/';
        request.resourcePath = '/mobile/prm/v2/Reference/Search/';        
        request.addParameter('objectName', 'Account');
        System.RestContext.request = request;
        
        List<RestPrmReferencedDataController.RestPrmReferencedData> results = RestPrmReferencedDataController.doGet();
        
        System.assert(1 <= results.size());         
    }
    
    static testMethod void doGet_RetrievesPracticesDataWithQuery() {
        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;                        
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Reference/Search/';
        request.resourcePath = '/mobile/prm/v2/Reference/Search/';        
        request.addParameter('objectName', 'Account');
        request.addParameter('q', 'pr');
        System.RestContext.request = request;
        
        List<RestPrmReferencedDataController.RestPrmReferencedData> results = RestPrmReferencedDataController.doGet();
        
        System.assert(1 <= results.size());         
    }

}