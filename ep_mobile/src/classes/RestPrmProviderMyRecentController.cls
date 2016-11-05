/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Providers/myRecent')
global with sharing class RestPrmProviderMyRecentController {
    
    @HttpGet
    global static List<RestPrmProviderController.Provider> doGet() {
    	/*         
         Tried to do this using Dynamic SOQL like all the other pages but for some reason LastViewedDate
         errors on Salesforce sometimes.  Salesforce throws an error saying that 'LastViewedDate' is not
         a field on Contact which it is.  Using static SOQL on this page for stability.  Will need to be
         investigated later to see if this can be fixed.
        */ 
        List<RestPrmProviderController.Provider> response = new List<RestPrmProviderController.Provider>();
        Integer pageSize = uRestController.getPageSize(10);
        Integer offset = uRestController.offset;
        
        List<Contact> contacts = [SELECT Id, Title, Name, salutation, FirstName, HC4__middleName__c, lastName, HC4__PrimaryAreaOfExpertise__c, HC4__Age__c,
            Department, HC4__Gender__c, Email, HomePhone, MobilePhone, Fax, HC4__PrimaryLocation__c, HC4__Suffix__c, HC4__ProfessionalSuffix__c, HC4__DoNotUpdateFromPrimaryLocation__c,
            DoNotCall, HasOptedOutOfEmail, HasOptedOUtOfFax, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLongitude, MailingLatitude,
            OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherLongitude, OtherLatitude, RecordType.Name, HC4__Affiliation__c,
            CreatedDate, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name FROM Contact 
            WHERE LastViewedDate != NULL 
            ORDER BY LastViewedDate DESC LIMIT :pageSize OFFSET :offset];
        
        
        for(Contact c : contacts) {
            response.add(new RestPrmProviderController.Provider(c, uString.EMPTY));
        } 
  
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }    

}