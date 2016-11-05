/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmTerritoryController {
    static testMethod void doGet_RetrievesObjectById() {
        HC4__Territory__c t = new HC4__Territory__c(
           Name = '__TEST__'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Territories/' + t.Id;
        request.resourcePath = '/mobile/prm/v1/Territories/*';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        
        List<RestPrmTerritoryController.Territory> territories = RestPrmTerritoryController.doGet();
        
        System.assertEquals(1, territories.size());
        System.assertEquals(t.ID, territories[0].id);
        System.assertEquals(t.Name, territories[0].name);
    }
    
    static testMethod void doGet_ReturnsNotFoundWhenBadId() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Territories/' + '__BAD_ID__';
        request.resourcePath = '/mobile/prm/v1/Territories/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmTerritoryController.Territory> territories = RestPrmTerritoryController.doGet();
        
        System.assertEquals(0, territories.size());
        System.assertEquals(404, System.RestContext.response.statusCode);
    }
    
    static testMethod void doGet_ReturnsTerritoryWhenSearchByQ() {
    	HC4__Territory__c t = new HC4__Territory__c(
           Name = '__TEST__'
        );
        insert t;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Territories';
        request.resourcePath = '/mobile/prm/v1/Territories/*';
        request.addParameter('pageSize', '2');
        request.addParameter('q', t.Name);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmTerritoryController.Territory> territories = RestPrmTerritoryController.doGet();
        
        System.assertEquals(1, territories.size());
        System.assertEquals(t.ID, territories[0].id);
        System.assertEquals(t.Name, territories[0].name);
    }
}