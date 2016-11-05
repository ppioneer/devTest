/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmTerritoryMyRecentController {
    /*static testMethod void doGet_RetrievesObjectById() {
        HC4__Territory__c territory = new HC4__Territory__c (
           Name = '__TEST__'
           );
           
        insert territory;
        
        List<HC4__Territory__c> providers = [Select Id From HC4__Territory__c where Id = :territory.Id];
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Territories/myRecent';
        request.resourcePath = '/mobile/prm/v1/Territories/myRecent';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmTerritoryController.Territory> myTerritories = RestPrmTerritoryMyRecentController.doGet();
        
        System.assertEquals(1, myTerritories.size());
        System.assertEquals(territory.ID, myTerritories[0].id);
    }*/
}