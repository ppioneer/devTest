/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Calls/myCalls')
global with sharing class RestPrmCallMyCallsController {
    @HttpGet
    global static List<RestPrmCallController.Call> doGet() {
       List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('Task', 'OwnerId', '=', UserInfo.getUserId()));
        //additionalConditions.add(new HC4.uCondition('Task', 'IsClosed', '=', 'false')); //T2565
        
        return RestPrmCallController.performGetSearch(additionalConditions);
    }
}