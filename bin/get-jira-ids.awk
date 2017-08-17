#-----------------------------------------------------------------------------------------------------------------
# get-jira-ids.awk will process each line of data, if match
# found, it will get all the Jira IDs mentioned in the string
# in the following format
#       "Delivers #MI-600"
# An example of commit message would be:"Adding new files Delivers #MI-600, Delivers #MI-591 and Delivers #MI-592"
# In the above example, Jira ids MI-600, MI-591, MI-592 will be picked
#-----------------------------------------------------------------------------------------------------------------


BEGIN{
   FS="\n"
}
{
   mystr=sprintf("%s",$0);

   do{ 
         #print mystr
         where=match(mystr, "Delivers[ ]+#[a-zA-Z]+-[0-9]+");
         if(where == 0)
            break;
         #print where
         split(substr(mystr, RSTART, RLENGTH), a, "#");
         mystr=substr(mystr, RSTART+RLENGTH, length(mystr))

         print a[2]
      }while(length(mystr)>0)
}
