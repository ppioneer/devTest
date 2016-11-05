/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Practices/myRecent')
global with sharing class RestPrmPracticeMyRecentController {
    
    @HttpGet
    global static List<RestPrmPracticeController.Practice> doGet() {         
         Integer pageSize = uRestController.getPageSize(10);
        Integer offset = uRestController.offset;
        List<RecentlyViewed> recents = [Select Id From RecentlyViewed where Type = 'Account' ORDER BY LastViewedDate DESC LIMIT :pageSize OFFSET :offset];       
        List<RestPrmPracticeController.Practice> response = new List<RestPrmPracticeController.Practice>();
         
        for(RecentlyViewed t : recents) {
           response.add(new RestPrmPracticeController.Practice(t));
        } 
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }    
}