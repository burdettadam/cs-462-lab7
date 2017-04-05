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
		wrangler:createChild(name);
		wrangler:installRulesets("b507962x4") with
		  name = vehicle_name
	    }
  	    always {
    	    	   log("create vehicle " + name);
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
	rule subscribe_child {
	     select when fleet_management subscribe_child
	     pre {
	     	 sub_attrs = {
		 	   "name": event:attr("name"),
			   "name_space": "Fleet",
			   "my_role": event_attr("fleet"),
			   "subscriber_role": event:attr("subscriber_role"),
			   "subscriber_eci": event:attr("subscriber_eci")
		 };
	     }
	     if (not sub_attrs{"name"}.isnull() && not sub_attrs{"subscriber_eci"}.isnull()) then {
	     	send_directive("subscription_request") with
		  options = sub_attrs
	     }
	     fired {
	     	   raise wrangeler event "subscription" attributes sub_attrs;
		   log "sent subscription request to new vehicle"
	     }
	     else {
	     	  log "missing required attributes " + sub_attr.encode()
	     }
	}
}