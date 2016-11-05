/* Copyright (c) 2008-2014 Evariant */
global with sharing class RestPrmActivityController2 {
	
	global class ActivityFeed {
        public List<uRestController.GenericGetListResponse> calls { get; private set; }
        public List<uRestController.GenericGetListResponse> issues { get; private set; }
        public List<uRestController.GenericGetListResponse> notes { get; private set; }
        public List<uRestController.GenericGetListResponse> tasks { get; private set; }
        
        public ActivityFeed () {
            this.calls = new List<uRestController.GenericGetListResponse>();
            this.issues = new List<uRestController.GenericGetListResponse>();
            this.notes = new List<uRestController.GenericGetListResponse>();
            this.tasks = new List<uRestController.GenericGetListResponse>();
        }
    }

}