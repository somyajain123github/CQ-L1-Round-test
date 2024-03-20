trigger NonConformancetrigger on SQX_Nonconformance__c (before Insert,after insert) {
  (new NonConformanceTriggerhandler()).run();
}