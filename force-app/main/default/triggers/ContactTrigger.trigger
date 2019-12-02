trigger ContactTrigger on Contact (before insert, before update, after insert, after update ) {
    
    if( trigger.isAfter && Trigger.isUpdate ){
        ContactTriggerUtility.afterContactUpdate( trigger.oldMap, trigger.new );
    }
    
    if( trigger.isAfter && Trigger.isInsert ){
        ContactTriggerUtility.afterContactInsert( trigger.new );
    }
    
    if( trigger.isUpdate && trigger.isBefore ){
        ContactTriggerUtility.beforeContactUpdate(trigger.oldMap, trigger.newMap );
    }
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        for (Contact c : Trigger.New) {
            String street = c.MailingStreet;
            if (street == null) continue;
            
            if (street.contains('\\\\')) {
                List<String> streets = street.split('\\\\');
                if (streets.size() > 1){
                    street = streets[0] + '\n' + streets[2];
                    c.MailingStreet = street;
                }else{
                    if(streets.isEmpty()){
                        c.mailingStreet = '';
                    }else{
                        street = streets[0];
                        c.MailingStreet = street;
                    }
                }
            }
        }
    }
}