/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Territories/myRecent')
global with sharing class RestPrmTerritoryMyRecentController { 
    @HttpGet
    global static List<RestPrmTerritoryController.Territory> doGet() {
    	Integer pageSize = uRestController.getPageSize(10);
        Integer offset = uRestController.offset;

    	List<RecentlyViewed> recents = [Select Id, Name From RecentlyViewed where Type = 'HC4__Territory__c' ORDER BY LastViewedDate DESC LIMIT :pageSize OFFSET :offset];       
        List<RestPrmTerritoryController.Territory> response = new List<RestPrmTerritoryController.Territory>();
         
        for(RecentlyViewed t : recents) {
           response.add(new RestPrmTerritoryController.Territory(t));
        } 
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }    
}