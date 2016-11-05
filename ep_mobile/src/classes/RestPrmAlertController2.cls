/* Copyright (c) 2008-2014 Evariant */
global with sharing class RestPrmAlertController2 {
	
	global class AlertFeed {
    	
        public List<uRestController.GenericGetListResponse> openIssues { get; private set; }
        public List<uRestController.GenericGetListResponse> overdueTasks { get; private set; }
        
        public AlertFeed () {
            this.openIssues = new List<uRestController.GenericGetListResponse>();
            this.overdueTasks = new List<uRestController.GenericGetListResponse>();
        }
    }

}