/**
* @description       : Case Creation and Nonconformance
* @author            : Somya jain
* @group             : 
* @last modified on  : 19-03-2024
* @LastModifiedBy    : Somya jain
**/
public with sharing class CaseTriggerHandler {
    /**
* @description this method is used to call the trigger events method
**/
    public void run() {
        if(Trigger.isbefore && Trigger.isInsert) {
            beforeInsertandUpdate(Trigger.new,null);
        }
        else if(Trigger.isAfter && Trigger.isInsert) {
            afterInsertandUpdate(Trigger.new,null);
        }
        else if(Trigger.isAfter && Trigger.isUpdate) {
            Map<id,Case> IdVsCaseMap = (Map<id,Case>)trigger.oldmap;
            afterInsertandUpdate(Trigger.new,IdVsCaseMap);
        }
        else if(Trigger.isbefore && Trigger.isUpdate) {
            Map<id,Case> IdVsCaseMap = (Map<id,Case>)trigger.oldmap;
            beforeInsertandUpdate(Trigger.new,IdVsCaseMap);
        }
    }
    /**
* @description execute on after insert and update to create associated Nonconformance of Case
* @author Somya Jain| 19-03-2024
* @param newCaseList new case list from trigger.new
* @param IdVsCaseMap new map of id and case

**/
    void afterInsertandUpdate(List<Case> newCaseList, Map<id,Case> IdVsCaseMap) {
        try {
            List<PermissionSetAssignment> case_admin = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE AssigneeId=: userInfo.getuserid() and PermissionSet.Name = 'Case_Admin' ];
            if(case_admin.size()>0) {
                List<SQX_Nonconformance__c> associatedNonconformance = new List<SQX_Nonconformance__c>();
                for(Case eachCase :newCaseList) {
                    if((eachCase.Type == 'Problem' && trigger.isInsert) || (trigger.isupdate && eachCase.Type == 'Problem' && eachCase.type != IdVsCaseMap.get(eachCase.id).type) ){
                        associatedNonconformance.add(new SQX_Nonconformance__c(Title__c = eachcase.Subject,  Priority__c= eachcase.Priority, Description__c = eachcase.description, QMS_Reference_Number__c = eachcase.caseNumber));
                    } 
                }
                
                if(!associatedNonconformance.isEmpty() && Schema.SObjectType.SQX_Nonconformance__c.isCreateable()) {
                    insert associatedNonconformance;
                }
            }
        } catch(Exception e) {
            System.debug('Message>>' + e.getMessage() + ' at line>>'+e.getLineNumber());
            throw e;
        }
    }
      /**
* @description execute on before insert and update 
* @author Somya Jain| 19-03-2024
* @param newCaseList new account list from trigger.new
* @param IdVsCaseMap new map of id and case
**/
    void beforeInsertandUpdate(List<Case> newCaseList, Map<id,Case> IdVsCaseMap) {
        try {
            set<id> ncId = new set<id>();
            for(case eachcase:newCaseList){
                if(eachcase.SQX_NC_Reference__c !=null){
                    ncId.add(eachcase.SQX_NC_Reference__c);
                }
            }
            Map<Id,SQX_Nonconformance__c> idVSobjMap = new Map<id,SQX_Nonconformance__c>([select id,(select id from cases__r) from SQX_Nonconformance__c where id IN: ncId]);
            for(case caseobj:newCaseList){
                if(caseobj.SQX_NC_Reference__c!=null && (trigger.isInsert || (trigger.isupdate && caseobj.SQX_NC_Reference__c != IdVsCaseMap.get(caseobj.id).SQX_NC_Reference__c)) && idVSobjMap.containskey(caseobj.SQX_NC_Reference__c) &&  idVSobjMap.get(caseobj.SQX_NC_Reference__c).cases__r.size()>0){
                    caseobj.adderror('this Nc Reference is already associated with another case');
                }
            }
            
            
        } catch(Exception e) {
            System.debug('Message>>' + e.getMessage() + ' at line>>'+e.getLineNumber());
            throw e;
        }
    }
    
}