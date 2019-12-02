/**
 * @File Name          : ProjectSchedule.cls
 * @Description        : 
 * @Author             : Sean Gray
 * @Group              : 
 * @Last Modified By   : Sean Gray
 * @Last Modified On   : 10/6/2019, 1:21:27 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/7/2019   Sean Gray     Initial Version
**/
public with sharing class ProjectSchedule {
    // @AuraEnabled
    // public static String ProjectScheduleInsert(String schedulename, Id recordId, string ProjectJSON) {
    //     system.debug('JSON is '+ ProjectJSON);
    //     List<inspire1__Project_Tasks__c> tasksToInsert = new List<inspire1__Project_Tasks__c>(); 
    //     inspire1__Project__c proj = new inspire1__Project__c(Name = schedulename, ATI_Job__c = recordId);
    //     insert proj;
    //     JSONWrapper projectWrap = (JSONWrapper)JSON.deserialize(ProjectJSON, JSONWrapper.class);
    //     system.debug('Project Wrap : ' + projectWrap);
    //     List<ATI_Job__c> job = [Select Id, Budget__c FROM ATI_Job__c WHERE Id =:recordId];
    //     if(String.isNotBlank(job[0].budget__c)){
    //     List<Budget__c> bud = [Select Id, ATI_Job__c, Project_manager__c FROM Budget__c WHERE ATI_Job__c =:recordId ORDER BY createdDate DESC LIMIT 1];
    //       for(projectItems project : projectWrap.Budgetlineitems){
    //           date startDate;
    //           date endDate;
    // if(String.isNotBlank(project.startDate)){
    //         startDate = date.valueOf((project.startDate+' 00:00:00'));
    //         endDate = date.valueOf(project.endDate+' 00:00:00');
    // }else{
    //      startDate = system.today();
    //      endDate = system.today();
    // }
    // system.debug('Project start date '+Project.startDate+ '    && startDate : '+startDate );
    
    //         inspire1__Project_Tasks__c taskToInsert = new inspire1__Project_Tasks__c(Name=project.name, inspire1__StartDate__c=startDate, inspire1__FinishDate__c=endDate, inspire1__Name__c=project.name, inspire1__Task_Type__c='Task', inspire1__Project__c=proj.id, createdById=bud[0].project_manager__c);
    //         tasksToInsert.add(taskToInsert);
    //         system.debug('project ' + project);
    //     }
    //     //List<Budget_Line_Item__c> budLineItems = [Select Id, Name, trade__c FROM Budget_Line_Item__c WHERE Budget__c =: bud[0].id];
    //     /*for(Budget_Line_Item__c lineItem : budLineItems ){
    //         inspire1__Project_Tasks__c taskToInsert = new inspire1__Project_Tasks__c(Name=lineItem.trade__c, inspire1__Name__c=lineItem.trade__c, inspire1__Task_Type__c='Task', inspire1__Project__c=proj.id, createdById=bud[0].project_manager__c);
    //         tasksToInsert.add(taskToInsert);
    //     }*/
    //     if(!tasksToInsert.isEmpty()){
    //         insert tasksToInsert;
    //     }
    //     }
    //     return proj.id;
    // }
    // public class JSONWrapper{
    //     public List<ProjectItems> Budgetlineitems;
    // }    
    // public class ProjectItems {
    //     public String name {get;set;}
    //     public String startDate {get;set;}
    //     public String endDate {get;set;}
    
    // }
    // public class RandomTokenWrapperException extends Exception{
    // }

    // @AuraEnabled
    // public static List<String> testBudget(string recordId){
    //     List<String> budgetLineItemList = new List<String>();
    //     List<Budget_Line_Item__c> budList = new List<Budget_Line_Item__c>();
    //     set<string> s = new Set<String>();
    //     List<ATI_Job__c> job = [Select Id, Budget__c FROM ATI_Job__c WHERE Id =:recordId];
    //     system.debug('Job budget is '+ job[0].budget__c);
        
    //     List<Budget__c> bud = [Select Id, ATI_Job__c, Project_manager__c FROM Budget__c WHERE ATI_Job__c =:recordId ORDER BY createdDate DESC];
    //     if(!bud.isEmpty()){
    //         system.debug('hitting this point..' + bud);
    //     List<Budget_Line_Item__c> budLineItems = [Select Id, Name, trade__c FROM Budget_Line_Item__c WHERE Budget__c =: bud[0].id ORDER BY orderNumber__c ASC];
    //     for(Budget_Line_Item__c b : budLineItems){
    //         string nameOfLineItem = b.trade__c;
    //         budgetLineItemList.add(nameOfLineItem);
    //         system.debug('testing');
    //         budList.add(b);
    //     }
    // }
    // system.debug('is this even working?');
    // system.debug(budgetLineItemList);
    // return budgetLineItemList;
    // }
}