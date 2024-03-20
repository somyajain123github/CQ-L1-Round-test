@Istest
public class CaseTriggerhandlerTest {
    @testSetup static void testSetupMethod() {
        
        
        Profile pr = [SELECT id FROM Profile WHERE Name = 'Standard User'];
        User user1 = new User();
        user1.Alias = 'tcase';
        user1.Email = 'tcase@gmail.com';
        user1.Username = 'somyajain98765@gmail.com';
        user1.EmailEncodingKey = 'UTF-8';
        user1.LanguageLocaleKey = 'en_US';
        user1.LastName = 'Case Lastname';
        user1.FirstName = 'Test';
        user1.LocaleSidKey = 'en_US';
        user1.ProfileId = pr.Id;
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        insert user1;
        
        PermissionSet getPerm = [SELECT Id FROM PermissionSet WHERE Name = 'Case_Admin' LIMIT 1];
        PermissionSetAssignment assignPerm = new PermissionSetAssignment();
        assignPerm.AssigneeId = user1.Id;
        assignPerm.PermissionSetId = getPerm.Id;
        insert assignPerm;
    }
    @isTest
    static void testcasetriggermethod() {
        user userobj =[select id from user where username ='somyajain98765@gmail.com'];
        System.runAs(userobj) {
            case each = new case();
            each.origin = 'email';
            each.type ='Problem';
            each.Priority = 'High';
            each.Description = 'Test';
            insert each;
            
            List<case> caselist = [select id,caseNumber,SQX_NC_Reference__c from case where id =: each.id];
            List<SQX_Nonconformance__c> nonconlist = [select id,QMS_Reference_Number__c from SQX_Nonconformance__c where QMS_Reference_Number__c =: caselist[0].caseNumber];
            system.assert(nonconlist.size()>0,'NonConformance should be created');
            system.assert(nonconlist[0].id ==caselist[0].SQX_NC_Reference__c,'NonConformance should be updated on case lookup field');
            
            
            case each1 = new case();
            each1.origin = 'Phone';
            each1.Priority = 'High';
            each1.Description = 'Test';
            insert each1;
            
            each1.type = 'Problem';
            update each1;
            List<case> caselist1 = [select id,caseNumber,SQX_NC_Reference__c from case where id =: each1.id];
            List<SQX_Nonconformance__c> nonconlist1 = [select id,QMS_Reference_Number__c from SQX_Nonconformance__c where QMS_Reference_Number__c =: caselist1[0].caseNumber];
            system.assert(nonconlist1.size()>0,'NonConformance should be created');
            system.assert(nonconlist1[0].id ==caselist1[0].SQX_NC_Reference__c,'NonConformance should be updated on case lookup field');
            
            try{
                each1.SQX_NC_Reference__c = nonconlist[0].id;
                update each1;
                
            }catch(exception e){
                system.assert(e.getmessage().contains('this Nc Reference is already associated with another case'));
                
            }
            try{
                SQX_Nonconformance__c obj = new SQX_Nonconformance__c();
                obj.QMS_Reference_Number__c = caselist[0].caseNumber;
                insert obj;
                
            }catch(exception e){
                system.assert(e.getmessage().contains('NonConformance is already associated with this case Number'));
                
            }
            
            
            
        }
    }
}