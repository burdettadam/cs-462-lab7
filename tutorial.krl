ruleset tutorial {
	meta {
	     name "Lab 7 Tutorials"
	     author "Christopher Pitts"
	     description <<Lab 7 Tutorial>>
	     logging on
	     sharing on
	     use module v1_wrangler alias wrangler
	     provides show_children
	     provides subs
	     provides good_subs
	     provides sub_cids
	}
	global {
	       show_children = function() {wrangler:children();}
	       subs = function() {
  	       	    subs = wrangler:subscriptions(null, "name_space", "Closet");
  		    subs{"subscriptions"}
	       }
	       good_subs = function(){
	           subs = wrangler:subscriptions(null, "status", "subscribed");
		   subs{"subscriptions"}
	       }
	       sub_cids = function(){
	           subs = wrangler:subscriptions(null, "status", "subscribed");
		   t = subs{"subscriptions"};
		   t[0];
	       }
	}
	rule createAChild {
  	     select when pico_systems child_requested
  	     pre {
		 random_name = "Test_Child_" + math:random(999);
    	     	 name = event:attr("name").defaultsTo(random_name);
  	     }
  	     {
		wrangler:createChild(name);
	     }
  	     always {
    	     	    log("create child names " + name);
  		    }
	}
	rule deleteAChild {
  	     select when pico_systems child_deletion_requested
  	     pre {
    	     	 name = event:attr("name").klog("got name: ");
  	     }
  	     if(not name.isnull()) then {
    	     	    wrangler:deleteChild(name)
  	     }
  	     fired {
    	     	   log "Deleted child named " + name;
  	     } else {
    	       log "No child named " + name;
  	     }
        }
	rule installRulesetInChild {
 	 select when pico_systems ruleset_install_requested
  	 pre {
    	     rid = event:attr("rid");
    	     pico_name = event:attr("name");
  	 }
  	 wrangler:installRulesets(rid) with
    	   name = pico_name
        }
	rule CreateFurnaceSystem {
	     select when pico_systems create_furnace_system
  	     {
		wrangler:createChild("Furnace");
		wrangler:createChild("TempSensor");
		wrangler:createChild("Thermostat");
		wranglet:installRulesets("b16x30") with
		  name = "Thermostat"
	     }	     
	}
	rule introduce_myself {
 	  select when pico_systems introduction_requested
  	    pre {
	      sub_attrs = {
	        "name": event:attr("name"),
      		"name_space": "Closet",
		"my_role": event:attr("my_role"),
		"subscriber_role": event:attr("subscriber_role"),
		"subscriber_eci": event:attr("subscriber_eci")
	      };
  	    }
	    if ( not sub_attrs{"name"}.isnull() && not sub_attrs{"subscriber_eci"}.isnull()) then
  		     send_directive("subscription_introduction_sent")
			with options = sub_attrs
      	    fired {
	      raise wrangler event 'subscription' attributes sub_attrs;
    	      log "subcription introduction made"
  	    } else {
	      log "missing required attributes " + sub_attr.encode()
  	  }       
	}
	rule approve_subscription {
    	     select when pico_systems subscription_approval_requested
    	     pre {
      	     	 pending_sub_name = event:attr("sub_name");
    	     }
    	     if ( not pending_sub_name.isnull()) then
       	     	send_directive("subscription_approved")
         	with options = {"pending_sub_name" : pending_sub_name}
   	     fired {
     	     	   raise wrangler event 'pending_subscription_approval'
           	   with channel_name = pending_sub_name;
     		   log "Approving subscription " + pending_sub_name;
   	     } else {
     	       log "No subscription name provided"
   	       }
        }
	rule test_subscription {
	     select when notification status
	     pre {
	     	 t = event:attr("t");
		 parent = event:attr("parent");
	     }
	     if (not t.isnull()) then {
	     	send_directive("fired_rule") with x = "yup"
	     }
	     fired {
	       log "rule totally fired"
	     }
	}
	rule notify_children {
	     select when pico_systems notify_children
	     pre {
	     	 cid = event:attr("cid");
	     	 sm = {
		   "name": "testing...",
		   "cid": cid
		 };
	     }
	     event:send(sm, "notification", "status") with
	       attrs = {
	       	     "t": "something",
		     "parent": "t"
	       }
	}
	rule test_looping {
	     select when testing looping
	     pre {
	     	 t = good_subs();
		 a = t.map(function(x){x{"Subby"}});
		 b = a.map(function(x){x{"subscriber_eci"}});
	     }
	     send_directive("result") with
	       options= {
	         "resa": a,
		 "resb": b
	       }
        }
}