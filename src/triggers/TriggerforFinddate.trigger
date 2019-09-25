trigger TriggerforFinddate on Deposition__c (before insert,before update) {
List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h where h.ActivityDate>=:system.today() order by h.activitydate desc];
Map<date,Holiday> hmap=new map<date,Holiday>();
map<integer,date> daterecMap=new map<integer,date>();
map<date,boolean> daterecMaph=new map<date,boolean>();
integer i;
for(Holiday h:holidays)
{
    hmap.put(h.activitydate,h);
    
}
date meetdate;
//public static boolean showdate;
for(Deposition__c d:trigger.new)
{
if(d.deposition_date__c!=null)
{
 meetdate=d.deposition_date__c;
date currentDate=system.today();
date dete=system.today();
i=dete.daysbetween(meetdate);
for(date d11=meetdate;d11>system.today();)
    {
    system.debug('!!!!!!!!!!!!!!!!d11!!!!!!'+d11);
    system.debug('!!!!!!!!!!!!!!!!i!!!!!!'+i);
        daterecMap.put(i,d11);
        i--;
        d11=d11.adddays(-1);
    }

    Date weekStart  = currentDate.toStartofWeek();
    Date weekStartset  = meetdate.toStartofWeek();
    map <date,boolean> tmap=new map<date,boolean>();
    //tmap.put(weekstart,false);
    //tmap.put(weekstart.adddays(-1),false);
    tmap.put(weekstartset,false);
    tmap.put(weekstartset.adddays(-1),false);
                 system.debug('!!!!!!!!!!!!!!!!!!!!!!!'+weekStart  );
                 system.debug('!!!!!!!!!!!!!!!!!!!!!!!'+holidays);
                for(Holiday hDay:holidays){
                system.debug('!!!!!!!!!!!!!!!!!!!!!!!'+holidays);
                        if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                                 daterecMaph.put(hDay.ActivityDate,false);
                        }
                }
                if(weekStart.daysBetween(currentDate) ==0 || weekStart.daysBetween(currentDate) == 6){
                       //showdate= false;
                        daterecMaph.put(currentDate,false);
                    
                } else
                   {    //showdate= true;
                   if(!hmap.containskey(currentDate))
                       daterecMaph.put(currentDate,true);
                   }
                system.debug('!!!!!!!!daterecMaph!!!!!!!!!!'+daterecMaph);
                system.debug('!!!!!!!!daterecMap!!!!!!!!!!'+daterecMap);
                system.debug('!!!!!!!!hmap!!!!!!!!!!'+hmap);
                system.debug('!!!!!!!!tmap!!!!!!!!!!'+tmap);
                for(Integer hinte:daterecMap.keyset())
                {
                    DATE dcheck=daterecMap.get(hinte);
                    system.debug('!!!!!!!!dcheck!!!!!!!!!!'+dcheck);
                    for(integer j=0;j<1;){
                    if(hmap.containskey(dcheck.adddays(-1)))
                    {
                    dcheck=dcheck.adddays(-1);
                    d.notification_date__c=dcheck;
                    system.debug('!!!!!!!!chech1!!!!!!!!!!'+dcheck);
                        j=0;}
                    if(tmap.containskey(dcheck.adddays(-1)))
                        {
                        dcheck=dcheck.adddays(-1);
                        d.notification_date__c=dcheck;
                        j=0;
                        system.debug('!!!!!!!!chech2!!!!!!!!!!'+dcheck);}
                        else
                        {
                        
                        
                        j=1;
                        
                        d.notification_date__c=dcheck.adddays(-1);
                        
                        system.debug('!!!!!!!!chech3!!!!!!!!!!'+dcheck);}}
                        
                    //if(daterecMaph.containskey(dcheck.adddays(-1)))
                    //{
                    //if(daterecMaph.get(dcheck.adddays(-1))==true)
                   // d.notification_date__c=dcheck.adddays(-1);}
                    }
                    
                
             /*   system.debug('\\\\\\\\daterecMaph\\\\\\\\\\\''+daterecMaph);
               if(weekStart.daysBetween(currentDate) ==0 || weekStart.daysBetween(currentDate) == 6){
                       //showdate= false;
                        daterecMaph.put(currentDate,false);
                    
                } else
                   {    //showdate= true;
                       daterecMaph.put(currentDate,true);
                   }
                       //if(showdate==true)
                      // d.notification_date__c=currentDate;
                      date dete=system.today();
                       i=dete.daysbetween(meetdate);
                       system.debug('\\\\\\\\\\\\\\\\\\\''+i);
                       system.debug('!!!!!!!!!!!!!!meetdate!!!!!!!'+meetdate);
    
    system.debug('\\\\\\\\daterecMaph\\\\\\\\\\\''+daterecMaph);
    system.debug('\\\\\\\\daterecMap\\\\\\\\\\\''+daterecMap);
    date duse;
    date dd;
    for(integer i1=dete.daysbetween(meetdate);i1>0;)
    {
        dd=daterecMap.get(i1);
        system.debug('\\\\\\\\dd\\\\\\\\\\\''+dd);
        if(daterecMaph.containskey(dd))
        {
        i1--;dd=dd.adddays(-1);}
        else{
        i1=0;
        duse=dd;}
    }
    system.debug('\\\\\\\\ddddd\\\\\\\\\\\''+dd);
    d.notification_date__c=dd;*/
}}}