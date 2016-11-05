/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmTerrMyTerrController {
    static testMethod void doGet_RetrievesMyTerritories() {
        HC4__Territory__c t = new HC4__Territory__c(
           Name = '__TEST__'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Territories/myTerritories';
        request.resourcePath = '/mobile/prm/v1/Territories/myTerritories';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmTerritoryController.Territory> territories = RestPrmTerritoryMyTerritoriesController.doGet();
        
        System.assert(1 <= territories.size());
    }
}