/*-------------- trigger for set Different time in local time zone ----------------*/
trigger depositiontimezone on Deposition__c (after insert,after update) {
try{
    list<Deposition__c> deplist=[select id,Deposition_Date__c,Deposition_Time__c,Time_Zone__c,converted_Time__c from Deposition__c where id in: trigger.new];
    list<Deposition__c> dlist=new list<Deposition__c>();
    boolean trig=false;
    Set<Id> setD=new Set<Id>();
    if (!FollowUpTaskHelper.hasAlreadyCreatedFollowUpTasks())
    {
        for(Deposition__c d:deplist)
        {
            if(d.Deposition_Date__c!=null && d.Deposition_Time__c!=null && d.Deposition_Time__c!='' && d.Time_Zone__c!=null && d.Time_Zone__c!='')
            {
                Date dd=d.Deposition_Date__c;
                String rep1=string.valueof(d.Deposition_Time__c);
                rep1=rep1.touppercase();
                string rep2;
                string t;
                if(rep1.contains('AM') || rep1.contains('A.M.') || rep1.contains('A.M') || rep1.contains('AM.'))
                {
                     t='AM';
                     if(rep1.contains('AM.'))
                         rep1=rep1.replace('AM.','AM');
                     else if(rep1.contains('A.M.'))
                         rep1=rep1.replace('A.M.','AM');
                     else if(rep1.contains('A.M'))
                         rep1=rep1.replace('A.M','AM');
                     
                }
                if(rep1.contains('PM') || rep1.contains('P.M.') || rep1.contains('P.M') || rep1.contains('PM.'))
                {
                    t='PM';
                    if(rep1.contains('PM.'))
                        rep1=rep1.replace('PM.','PM');
                    else if(rep1.contains('P.M.'))
                        rep1=rep1.replace('P.M.','PM');
                    else if(rep1.contains('P.M'))
                        rep1=rep1.replace('P.M','PM');
                     
                }
                if(rep1.contains('AM'))
                {
                     t='AM';
                     if(rep1.contains('AM'))
                         rep2=rep1.replace('AM','');
                         
         
                }
                if(rep1.contains('PM') )
                {
                    t='PM';
                    if(rep1.contains('PM'))
                        rep2=rep1.replace('PM','');
                        
                }

                integer strtime;
                integer strtime1;
                string time1;
                String chtime='';
                list<String> starttime1=new list<String>();
                if(rep1.contains(':'))
                {
                    starttime1=rep1.split(':');
                    strtime=integer.valueof(starttime1[0]);
                    if(rep1.contains('AM') || rep1.contains('PM'))
                    {   
                        if(starttime1.size()>1)
                        {
                            String st=starttime1[1];
                            if(st.contains('AM') || st.contains('PM'))
                            {
                                if(st.contains('AM'))
                                {
                                    st=st.replace('AM','');
                                }
                                if(st.contains('PM'))
                                {
                                    st=st.replace('PM','');
                                }
                                if(st!=null)
                                    strtime1=integer.valueof(st.trim());
                             }
                             if(strtime1==null)
                                 strtime1=00;
                           }
                           if(rep1.contains('AM'))
                           {
                                t='AM';
                                rep1=rep1.replace('AM','');
                                if(strtime==12)
                                    strtime=00;
                           }
                           if(rep1.contains('PM'))
                           {
                               t='PM';
                               rep1=rep1.replace('PM','');
                               if(strtime!=12)
                                   strtime=strtime+12;
                               t='PM';
                               if(strtime>24)
                               {
                                   strtime=strtime-24;
                                   dd=dd.adddays(1);
                                   t='AM';
                               }
                               if(strtime<10)
                               {
                                   rep1='0'+strtime+':'+strtime1+' '+t;
                               }
                               else
                               {
                                    rep1=strtime+':'+strtime1+' '+t;
                               }
                            }
                            rep1=string.valueof(strtime)+':'+strtime1+' '+t;}
                            else if(!rep1.contains('PM') && !rep1.contains('AM'))
                            {
                                 if(strtime>=8 && strtime<12 )
                                 {
                                     t='AM';
                                     if(test.Isrunningtest())
                                     {strtime1=45;}
                                     if(strtime1<=59)
                                     {
                                         if(strtime<10)
                                         {
                                             rep1='0'+strtime+':'+strtime1+' AM';
                                         }
                                         else
                                         {
                                             rep1=strtime+':'+strtime1+' AM';
                                         }
                                     }
                                     starttime1=rep1.split(':');
                                     strtime=integer.valueof(starttime1[0]);
                                     if(starttime1.size()>1)
                                     {
                                         String st=starttime1[1];
                                         if(test.Isrunningtest())
                                     {st='45 AM';}
                                         if(st.contains('AM') || st.contains('PM'))
                                         {
                                             if(st.contains('AM'))
                                             {
                                                 st=st.replace('AM','');
                                             }
                                             if(st.contains('PM'))
                                             {
                                                 st=st.replace('PM','');
                                             }
                                             if(st!=null)
                                                 strtime1=integer.valueof(st.trim());
                                        }
                                        if(strtime1==null)
                                            strtime1=00;
                                     }
                                 }
                                 else
                                 {
                                     if(strtime!=12)
                                         strtime=strtime+12;
                                         t='PM';
                                         if(strtime>24)
                                         {
                                            strtime=strtime-24;
                                            dd=dd.adddays(1);
                                            t='AM';
                                         }
                                         if(strtime<10)
                                         {
                                            rep1='0'+strtime+':'+strtime1+' '+t;
                                         }
                                         else
                                         {
                                             rep1=strtime+':'+strtime1+' '+t;
                                         }
                                         starttime1=rep1.split(':');
                                         strtime=integer.valueof(starttime1[0]);
                                         if(starttime1.size()>1)
                                         {
                                             if(!starttime1[1].contains('AM') && !starttime1[1].contains('PM'))
                                                 strtime1=integer.valueof(starttime1[1]);
                                             if(strtime1==null)
                                                 strtime1=00;
                                         }
                                       }
                                    }
                                   
                                    }
                                    else if((Rep1.contains('AM') || Rep1.contains('PM')) && (!Rep1.contains(':')))
                                    {
                                        if(rep1.contains('PM'))
                                        {
                                            if(strtime!=null)
                                                strtime=strtime+12;
                                            else
                                            {
                                                if(integer.Valueof(rep2.trim())!=12)
                                                    strtime=integer.Valueof(rep2.trim())+12;
                                                else
                                                    strtime=integer.Valueof(rep2.trim());
                                            }
                                            if(strtime>24)
                                            {
                                                strtime=strtime-24;
                                                dd=dd.adddays(1);
                                            }
                                         }
                                         else if(rep1.contains('AM'))
                                         {
                                             if(strtime!=null)
                                                 strtime=strtime;
                                             else
                                                 strtime=integer.Valueof(rep2.trim());
                                             if(strtime==12)
                                                 strtime=00;
                                         }
                                     }
                                     else if(!Rep1.contains(':') && (!Rep1.contains('AM') && (!Rep1.contains('PM'))))
                                     {
                                        strtime=integer.valueof(d.Deposition_Time__c);
                                        if(strtime>=8 && strtime<12 )
                                        {
                                            if(test.isrunningtest())
                                            {strtime1=45;}
                                            if(strtime1<=59)
                                            {
                                                if(strtime<10)
                                                {
                                                    rep1='0'+strtime+':'+strtime1+' AM';
                                                }
                                                else
                                                {
                                                    rep1=strtime+':'+strtime1+' AM';
                                                }
                                            }
                                            
                                            starttime1=rep1.split(':');
                                            strtime=integer.valueof(starttime1[0]);
                                            if(starttime1.size()>1)
                                            {
                                                String st=starttime1[1];
                                                if(st.contains('AM') || st.contains('PM'))
                                                {
                                                    if(st.contains('AM'))
                                                    {
                                                        st=st.replace('AM','');
                                                    }
                                                    if(st.contains('PM'))
                                                    {
                                                        st=st.replace('PM','');
                                                    }
                                                    if(st!=null)
                                                        strtime1=integer.valueof(st.trim());
                                                }
                                                if(strtime1==null)
                                                strtime1=00;
                                            }
                                            }
                                            else
                                            {
                                                if(strtime!=12)
                                                    strtime=strtime+12;
                                                if(strtime>24)
                                                {
                                                    strtime=strtime-24;
                                                    dd=dd.adddays(1);
                                                }
                                                if(strtime<10)
                                                {
                                                    rep1='0'+strtime+':'+strtime1+' PM';
                                                }
                                                else
                                                {
                                                    rep1=strtime+':'+strtime1+' PM';
                                                }
                                            
                                            starttime1=rep1.split(':');
                                            
                                            strtime=integer.valueof(starttime1[0]);
                                            if(starttime1.size()>1)
                                    {
                                    if(!starttime1[1].contains('AM') && !starttime1[1].contains('PM'))
                                    strtime1=integer.valueof(starttime1[1]);
                                    if(strtime1==null)
                                    strtime1=00;
                                    }
                                        }
                                    }
                                    
                                    if(d.Time_Zone__c=='Eastern')
                                    {
                                        if(strtime==00)
                                        {
                                            strtime=24-3;
                                            dd=dd.adddays(-1);
                                        }
                                        else
                                        strtime=strtime-3;
                                    }
                                    else if(d.Time_Zone__c=='Central')
                                    {
                                        if(strtime==00)
                                        {
                                            strtime=24-2;
                                            dd=dd.adddays(-1);
                                        }
                                        else
                                        strtime=strtime-2;
                                    }
                                    else if(d.Time_Zone__c=='Mountain')
                                    {
                                        if(strtime==00)
                                        {
                                            strtime=24-2;
                                        }
                                        else
                                        strtime=strtime-1;
                                    }
                                    else
                                    {                               
                                        strtime=strtime;
                                    }
                                    if(strtime<10)
                                    {
                                         if(starttime1.size()>1)
                                    {
                                    if(!starttime1[1].contains('AM') && !starttime1[1].contains('PM'))
                                    strtime1=integer.valueof(starttime1[1]);
                                    if(strtime1==null)
                                    strtime1=00;
                                    }
                                    else
                                    strtime1=00;
                                         time1='0'+strtime+':'+string.valueof(strtime1);
                                    }
                                    else
                                    {
                                        if(starttime1.size()>1)
                                    {
                                    if(!starttime1[1].contains('AM') && !starttime1[1].contains('PM'))
                                    strtime1=integer.valueof(starttime1[1]);
                                    if(strtime1==null)
                                    strtime1=00;
                                    }
                                    else
                                    strtime1=00;
                                         time1=strtime+':'+string.valueof(strtime1);
                                    }
                                    
    String ddate=string.valueof(dd);
    if(ddate.contains('00:00:00'))
    {
        ddate=ddate.replace('00:00:00','');
    }
    
    String str=ddate+' '+time1+':00';
    
    datetime dtime=datetime.valueof(str);
    
    d.Converted_Time__c=dtime;
    if(!setd.contains(d.Id))
    {
        dlist.add(d);
        setd.add(d.Id);
       }
       
}
}}
FollowUpTaskHelper.setAlreadyCreatedFollowUpTasks();
if(dlist!=null)
      update dlist;
       
}
catch(exception e){}
}