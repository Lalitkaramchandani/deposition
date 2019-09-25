global with sharing class ScheduleBatch_Update_Flag implements Schedulable{
    
    global void execute(SchedulableContext sc)
         {
            
            String query='Select id,lastname from Contact';
       
           Batch_Update_Flag_LatestDeposition brd = new Batch_Update_Flag_LatestDeposition();
           brd.query = query;
           Database.executebatch(brd);
         }
    
}