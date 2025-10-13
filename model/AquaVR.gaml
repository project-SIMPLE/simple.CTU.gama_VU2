/**
* Name: AquaVR
* Based on the internal empty template. 
* Author: ltmloan
* Tags: 
*/


model AquaVR

import "AquaDefenders5.gaml"
import "CommonVR.gaml"

/* Không định nghĩa lại unity_linker và unity_player vì đã import từ CommonVR.gaml.
   Sử dụng trực tiếp các species và reflex từ CommonVR, bao gồm send_farm_data đã được sửa.
   Nếu cần override, thêm vào species tương ứng, nhưng ở đây không cần để tránh xung đột.
*/

experiment AquaVR type: unity {
	//minimal time between two simulation step
	float minimum_cycle_duration <- 0.01;

	//name of the species used for the unity_linker
	string unity_linker_species <- string(unity_linker);

	//allow to hide the "map" display and to only display the displayVR display 
	list<string> displays_to_hide <- ["map"];
	parameter "let_gama_manage_time" var: let_gama_manage_game <- false among: [false];
	parameter collaborating var: collaborating <- false among: [false];

	//action called by the middleware when a player connects to the simulation
	action create_player (string id) {
		ask unity_linker {
			do create_player(id);
		}

	}

	//action called by the middleware when a plyer is remove from the simulation
	action remove_player (string id_input) {
		if (not empty(unity_player)) {
			ask unity_linker {
				if (id_input in player_agents.keys) {
					do restart(id_input);
					ask unity_player(player_agents[id_input]) {
						do die;
					}

					remove key: id_input from: player_agents;
				}

			}

		}

	}

	font f <- font("Helvetica", 16, #bold);
	rgb c <- #white;
	
	output synchronized: true {
		display "Aqua Map" type: 2d {
			grid cell border: #black;
			species river;
			species farm;
			species crop;
			species unity_player;
		}
	}

}