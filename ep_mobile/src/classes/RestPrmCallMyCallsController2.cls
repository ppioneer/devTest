/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Calls/myCalls')
global with sharing class RestPrmCallMyCallsController2 {
	
	@HttpGet
    global static List<uRestController.GenericGetListResponse> doGet() {
       List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('Task', 'OwnerId', '=', UserInfo.getUserId())); 
                
        return RestPrmCallSearchController.performGetSearch(additionalConditions);
    }
}