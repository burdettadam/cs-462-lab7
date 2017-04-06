ruleset manage_fleet {
	meta {
	     name "Lab 7 manage_fleet Ruleset"
	     description <<CS 462 Lab 7>>
	     author "Christopher Pitts"
	     logging on
	     sharing on
	     use module v1_wrangler alias wrangler
	     provides vehicles, subs
	}
	global {
	       vehicles = function(){wrangler:children();}
	       subs = function(){
	       	    s = wrangler:subscriptions(null, "name_space", "Fleet_Management");
		    s{"subscriptions"}
	       }
	}
	rule create_vehicle {
	  select when car new_vehicle
	    pre {
    	    	random_name = "Vehicle_" + math:random(999);
    	    	vehicle_name = event:attr("name").defaultsTo(random_name);
  	    }
  	    {
	        log "Creating vehicle " + vehicle_name;
		wrangler:createChild(vehicle_name);
	    }
  	    always {
    	    	   log "Created vehicle " + vehicle_name;
  	    }
        }
	rule delete_vehicle {
	     select when car unneeded_vehicle
	     pre {
	     	 name = event:attr("name");
	     }
	     if (not name.isnull()) then {
	     	wrangler:deleteChild(name);		
	     }
	     fired {
	     	   log "Deleted vehicle " + name;
	     }
	     else {
	     	  log "No vehicle named " + name;
	     }
	}
	rule introduce_myself {
  	select when fleet_management subscribe_child
  	pre {
    	    sub_attrs = {
      	    	      "name": event:attr("name"),
      	    	      "name_space": "Fleet",
      		      "my_role": event:attr("my_role"),
      		      "subscriber_role": event:attr("subscriber_role"),
      		      "subscriber_eci": event:attr("subscriber_eci")
        	      };
        }
  	if ( not sub_attrs{"name"}.isnull() && not sub_attrs{"subscriber_eci"}.isnull()) then {
	   send_directive("subscription_introduction_sent")
  	   with options = sub_attrs
	}
  	fired {
    	      raise wrangler event 'subscription' attributes sub_attrs;
    	      log "subcription introduction made"
 	}
	else {
    	     log "missing required attributes " + sub_attrs.encode()
        }
   }
   rule approve_subscription {
   	select when fleet_management subscription_approval_requested
    	pre {
      	    pending_sub_name = event:attr("sub_name");
    	}
    	if ( not pending_sub_name.isnull()) then {
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