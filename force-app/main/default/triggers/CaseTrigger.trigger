/**
 * @description       : Case Trigger
 * @author            : Somya jain
 * @group             : 
 * @last modified on  : 19-03-2024
**/
trigger CaseTrigger on Case (before insert,before update,after insert,after update) {
  (new CaseTriggerHandler()).run();
}