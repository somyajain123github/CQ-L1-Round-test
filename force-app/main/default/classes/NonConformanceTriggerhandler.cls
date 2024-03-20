public with sharing class NonConformanceTriggerhandler {
    public void run() {
        if(Trigger.IsBefore && (Trigger.isInsert || trigger.isupdate)) {
            beforeInsert(Trigger.new);
        }
        else if(Trigger.Isafter && Trigger.isInsert) {
            afterInsert(Trigger.new);
        }
        /*    else if(Trigger.isAfter && Trigger.isUpdate) {
Map<id,Case> IdVsCaseMap = (Map<id,Case>)trigger.oldmap;
afterInsertandUpdate(Trigger.new,IdVsCaseMap);
}*/
    }
    void afterInsert(List<SQX_Nonconformance__c> newListofNonConformance){
        try {
            List<case> newcaseLsit = new List<case>();
            Map<string,SQX_Nonconformance__c> stringVsObjectMap = new Map<string,SQX_Nonconformance__c>();
            for(SQX_Nonconformance__c eachnon :newListofNonConformance){
                stringVsObjectMap.put(eachnon.QMS_Reference_Number__c,eachnon);
            }
            for(case eachcase: [select id,SQX_NC_Reference__c ,caseNumber from case where CaseNumber IN: stringVsObjectMap.keyset()]){
                eachCase.SQX_NC_Reference__c = stringVsObjectMap.get(eachCase.CaseNumber).id;
                newcaseLsit.add( eachCase);
            }
            if(!newcaseLsit.isEmpty() && Schema.SObjectType.Case.isUpdateable()) {
                Update newcaseLsit;
            }
            
        } catch(Exception e) {
            System.debug('Message>>' + e.getMessage() + ' at line>>'+e.getLineNumber());
            throw e;
        }
    }
    
    void beforeInsert(List<SQX_Nonconformance__c> newListofNonConformance){
        try {
            List<PermissionSetAssignment> case_admin = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE AssigneeId=: userInfo.getuserid() and PermissionSet.Name = 'Case_Admin' ];
            if(case_admin.size()>0) {
                set<string> stringset = new set<string>();
                Map<string,id> idvsStringMap = new Map<string,id> ();
                for( SQX_Nonconformance__c eachobj:newListofNonConformance){
                    if( eachobj.QMS_Reference_Number__c !=null){
                        stringset.add(eachobj.QMS_Reference_Number__c);
                    }
                }
                for(case eachcase:[select id, SQX_NC_Reference__c,casenumber from case where caseNumber IN:stringset and SQX_NC_Reference__c != null]){
                    idvsStringMap.put(eachcase.casenumber,eachcase.SQX_NC_Reference__c);
                }
                for( SQX_Nonconformance__c eachobj2:newListofNonConformance){
                    if(idvsStringMap.containsKey(eachobj2.QMS_Reference_Number__c)){
                        eachobj2.adderror('NonConformance is already associated with this case Number');
                    }
                }
            }else{
                throw new dmlexception('Insufficient access of his object');
            }
        } catch(Exception e) {
            System.debug('Message>>' + e.getMessage() + ' at line>>'+e.getLineNumber());
            throw e;
        }
        
        
        
    }
    
}