/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/ServiceLines/*/SubServiceLines')
global with sharing class RestPrmServiceLineSubServiceLine {
    
    @HttpGet
    global static List<RestPrmSubServiceLineController.SubServiceLine> doGet() {
    	String serviceLineId = uRestController.getParentObjectId('ServiceLines/');
    	
    	List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('HC4__SubServiceLine__c', 'HC4__ServiceLine__c', '=', serviceLineId));
        
        return RestPrmSubServiceLineController.performGetSearch(additionalConditions);
    }
}