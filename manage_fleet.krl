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
		sub_cids = function(){
	           subs = wrangler:subscriptions(null, "status", "subscribed");
		   t = subs{"subscriptions"};
//		   a = t.map(function(x){x{"Subby"}});
//		   b = a.map(function(x){x{"subscriber_eci"}});
//		   b
		   t
		}
	}
	rule create_vehicle {
		select when car new_vehicle
		pre {
			random_name = "Vehicle_" + math:random(999);
			vehicle_name = event:attr("name").defaultsTo(random_name);
		}
		{
			wrangler:createChild(vehicle_name);
		}
		fired {
		      log "Created vehicle";
		}
	}
	rule delete_vehicle {
		select when car unneeded_vehicle
		pre {
			name = event:attr("name");
		}
		if ( not name.isnull()) then {
			wrangler:deleteChild(name);
		}
		fired {
		      log "Deleted vehicle";
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
		if ( not sub_attrs{"name"}.isnull() 
			&& not sub_attrs{"subscriber_eci"}.isnull()) then {
			send_directive("subscription_introduction_sent") with 
			options = sub_attrs;
		}
		fired {
			raise wrangler event 'subscription' attributes sub_attrs;
			log "Subscription added";
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
			log "Subscription approved";
		}
	}
	rule send_to_subscriber {
	     select when send subscriber
	       foreach sub_cids().klog("sub_cids: ") setting (cid)
	       pre {

	       }
	       {
	         noop();
		 event:send({"cid":cid}, "sent", "subscriber")
		 with attrs = attr.klog("attributes: "); 
	       }
	       always {
	         raise sent event "subscriber_was_sent_too"
		 attributes attr.klog("attributes: ");
	       }
        }
}
