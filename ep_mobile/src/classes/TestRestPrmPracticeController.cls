/* Copyright (c) 2008-2014 Evariant */
@isTest(SeeAllData=false)
private with sharing class TestRestPrmPracticeController {
    static testMethod void doGet_RetrievesObjectById() {
    	Account a = new Account(
    	   Name = '__Test__'
    	);
    	
    	insert a;

    	RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + a.Id;
        request.resourcePath = '/mobile/prm/v1/Practices/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmPracticeController.Practice> practices = RestPrmPracticeController.doGet();
        
        System.assertEquals(1, practices.size());
        System.assertEquals(a.ID, practices[0].id);
    }
    
    static testMethod void doGet_ReturnsNothingOnInvalidId() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/a02j00000020jpBAAQ';
        request.resourcePath = '/mobile/prm/v1/Practices/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmPracticeController.Practice> practices = RestPrmPracticeController.doGet();
        
        System.assertEquals(0, practices.size());
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doGet_RetrievesAllWhenNoIdOrParams() {
        Account a = new Account(
            Name = '__TEST_PRACTICE__'
        );
        insert a;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices';
        request.resourcePath = '/mobile/prm/v1/Practices/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmPracticeController.Practice> practices = RestPrmPracticeController.doGet();
        
        System.assert(1 <= practices.size());
    }
    
    static testMethod void doGet_RetrievesMatchingPracticesOnNameWithQValue() {
        Account a = new Account(
            Name = '__TEST_PRACTICE__'
        );
        insert a;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices';
        request.params.put('q', a.Name);
        request.resourcePath = '/mobile/prm/v1/Practices/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmPracticeController.Practice> practices = RestPrmPracticeController.doGet();
        
        System.assertEquals(1, practices.size());
        System.assertEquals(a.ID, practices[0].id);
    }
}