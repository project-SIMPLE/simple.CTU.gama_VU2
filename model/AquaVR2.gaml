/**
* Name: AquaVR2
* Based on the internal empty template. 
* Author: minhloan
* Tags: 
*/
model AquaVR2

import "AquaCommonVR.gaml"
experiment multi_regions type: unity {

//    init {
//        // Tạo 4 mô hình AquaDefenders5 độc lập
//        create simulation with:[region_name::"Region 1"];
//        create simulation with:[region_name::"Region 2"];
//        create simulation with:[region_name::"Region 3"];
//        create simulation with:[region_name::"Region 4"];
//    }
	float minimum_cycle_duration <- 0.01;

	//name of the species used for the unity_linker
	string unity_linker_species <- string(unity_linker);

	//allow to hide the "map" display and to only display the displayVR display 
	list<string> displays_to_hide <- ["Digital Elevation Model", "W1", "Subsidence - Groundwater extracted"];
	parameter "let_gama_manage_time" var: let_gama_manage_game <- false among: [false];
	//	parameter collaborating var: collaborating <- false among: [false];
	//action called by the middleware when a player connects to the simulation
	action create_player (string id) {
		ask unity_linker {
		//			any(GPlayLand where(each.rootPID="")).rootPID<-id;
			do create_player(id);
		}

		//		write ((unity_player));
	}

	//action called by the middleware when a plyer is remove from the simulation
	action remove_player (string id_input) {
		if (not empty(unity_player)) {
			ask unity_linker {
				if (id_input in player_agents.keys) {
					do restart(id_input);
					ask unity_player(player_agents[id_input]) {
					//						myland.rootPID<-"";
						do die;
					}

					remove key: id_input from: player_agents;
				}

			}

		}

	}

	output {
		layout horizontal([vertical([0::5000, 1::5000])::5000, vertical([2::5000, 3::5000])::5000]) tabs: false;
		display "Region 1" {
		//grid color:#gray;
		//            ask AquaDefenders5_model[0] {
		//                species river;
		//                species farm;
		//                species crop;
		//            }
		}

		display "Region 2" {
		// grid cell lines: #gray;
		//            ask AquaDefenders5_model[1] {
		//                species river;
		//                species farm;
		//                species crop;
		//            }
		}

		display "Region 3" {
		//grid cell lines: #gray;
		//          //  ask AquaDefenders5_model[2] {
		//                species river;
		//                species farm;
		//                species crop;
		//            }
		}

		display "Region 4" {
		// grid cell lines: #gray;
		//            ask AquaDefenders5_model[3] {
		//                species river;
		//                species farm;
		//                species crop;
		//            }
		}

	}

}