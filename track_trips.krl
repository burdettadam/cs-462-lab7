ruleset track_trips{
	meta {
	     name "Lab 6 track_trips Ruleset"
	     description <<CS 462 Lab 6>>
	     author "Christopher Pitts"
	     logging on
	     sharing on
	     use module v1_wrangler alias wrangler
	}
	global {
	       get_long_trip_distance = function(){
	       			      	d = 1000;
					d
	       			      }
	}
	rule process_trip {
	     select when car new_trip mileage re#([0-9]+)# setting (miles)
	     pre {
	     	 long_trip = ent:long_trip.defaultsTo(1000).klog("long trip distance was: ");
	     }
	     {
		send_directive("trip") with
		len = miles;
	     }
	     fired {
	     	   raise explicit event 'trip_processed'
		   attributes event:attrs();
	     }
	}
	rule find_long_trips {
	     select when explicit trip_processed
	     pre {
	     	 miles = event:attr("mileage").klog("checking mileage: ");
	     }
	     fired {
	     	   raise explicit event 'found_long_trip'
		   attributes event:attrs()
		   if (miles > get_long_trip_distance());
	     }
	}
	rule found_a_long_trip {
	     select when explicit found_long_trip
	     pre {
	     	 t = event:attr("mileage").klog("longest trip was: ");
	     }
	}
	rule approve_subscription {
   	     select when fleet_management subscription_approval_requested
    	     pre {
      	     	 pending_sub_name = event:attr("sub_name");
    	     }
    	     if ( not pending_sub_name.isnull()) then
	     {
		send_directive("subscription_approved")
         	with options = {"pending_sub_name" : pending_sub_name}
	     }
   	     fired {
	     	   raise wrangler event 'pending_subscription_approval'
                   with channel_name = pending_sub_name;
     	       	   log "Approving subscription " + pending_sub_name;
   	     }
	     else {
     	      	  log "No subscription name provided"
   	     }
	}
}