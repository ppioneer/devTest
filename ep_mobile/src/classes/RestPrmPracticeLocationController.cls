/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Practices/*/Locations')
global with sharing class RestPrmPracticeLocationController {
	 @HttpGet
    global static List<RestPrmLocationController.Location> doGet() {
    	String practiceId = uRestController.getParentObjectId('Practices/');
    	List<HC4.uCondition> conditions = new List<HC4.uCondition>();
         conditions.add(new HC4.uCondition('HC4__Location__c', 'HC4__Practice__c', '=', practiceId));
         
         return RestPrmLocationController.performGetSearch(conditions);
    }

}