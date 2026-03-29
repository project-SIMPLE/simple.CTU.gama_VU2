/**
* Name: CommonVR
* Based on AquaDefenders5 for sending salinity and crop_type. 
* Author: patricktaillandier (minhloan update rewritten for AquaDefenders5 compatibility)
* Tags: 
*/


model CommonVR

import "AquaDefenders5.gaml"
global { 
	bool let_gama_manage_game ;
	int duration_preparation <- 1; //in seconds;
	int duration_defense<- 240; //in seconds;
}

global {
    // Define update_salinity_refresh_rate if not present in Global.gaml
    float update_salinity_refresh_rate <- 10.0; // Refresh every 10 cycles (adjustable)
}

species unity_linker parent: abstract_unity_linker {
    // Name of the species used to represent a Unity player
    string player_species <- string(unity_player);
    float min_player_position_update_duration <- 0.1;

    // Do not send world info automatically, only specific data (salinity, crop_type)
    bool do_send_world <- false;

    // Max and min number of players
    int max_num_players <- 4; 
    int min_num_players <- 1;

    // Initial locations for players
    list<point> init_locations <- farm collect (any_location_in(each) + {0, 0, 1});

    // Handle new player connection
    action new_connection (string id) {
        if (id in player_agents.keys) {
            if (not let_gama_manage_game) {
                do restart(id);
                ask unity_player(player_agents[id]) {
                    do die;
                }
                remove key: id from: player_agents;
                do create_player(id);
            }
        }
    }

    // Restart a player's farm state
    action restart (string id) {
        unity_player Pl <- player_agents[id];
        ask Pl.myfarm {
            salinity <- 0.0; // Reset salinity
            // Note: crop_type is not reset as it is fixed in AquaDefenders5
        }
        Pl.ready_to_start <- false;
    }

    // Change player state
    action change_state (string idP, string new_state) {
        unity_player Pl <- player_agents[idP];
        Pl.current_state <- new_state;
    }

    // Mark player as ready
    action player_ready (string idP) {
        unity_player Pl <- player_agents[idP];
        Pl.ready_to_start <- true;
    }

    // Handle player finishing the game
    action player_finish_game (string idP) {
        write "END FOR " + idP;
        if (let_gama_manage_game) {
            unity_player Pl <- player_agents[idP];
            Pl.finish_game <- true;
        }
    }

    // Notify players to start
    reflex let_player_start when: not empty(unity_player where !each.ready_to_start) {
        if (not let_gama_manage_game) {
            do send_message(unity_player where !each.ready_to_start, ["readyToStart"::""]);
        } else {
            do send_message(unity_player where !each.ready_to_start, ["startGame"::true, "time_prep"::duration_preparation, "time_def"::duration_defense]);
        }
    }

    // End game sequence
    reflex end_sequence when: (let_gama_manage_game) and empty(unity_player where not each.finish_game) {
        write "END OF GAME";
        ask unity_player {
            finish_game <- false;
        }
        ask world {
            do pause;
        }
    }

    // Send salinity and crop_type information for each farm
    reflex send_salinity_and_crop_type when: every(update_salinity_refresh_rate #cycle) {
        ask unity_player where not (dead(each) and each.ready_to_start) {
            float salinity_value <- myfarm.salinity with_precision 2;
            string crop_type_value <- myfarm.crop_type;
            int farm_id <- myfarm.index;
            ask myself {
            	write ""+[
                	"farmid"::farm_id,
                    "salinity"::salinity_value,
                    "crop_type"::crop_type_value
                ];
                do send_message([myself], [
                	"farmid"::farm_id,
                    "salinity"::salinity_value,
                    "crop_type"::crop_type_value
                ]);
            }
        }
    }

    // Convert Unity coordinates to GAMA coordinates
    point toGAMACoordinate (int x, int y) {
        float xa <- 2426.08;
        float xb <- 181088.094;
        float ya <- -2534.754;
        float yb <- 199992.122;
        return {x / precision * xa + xb, y / precision * ya + yb};
    }

    // Update player position
//    action update_player_pos (string idP, int x, int y, int o, int remaining_time, float score) {
//        unity_player Pl <- player_agents[idP];
//        Pl.location <- toGAMACoordinate(x, y);
//        Pl.heading <- float(o / precision) + 90;
//        Pl.to_display <- true;
//        Pl.myfarm.current_score <- max(0, score);
//    }
}

species unity_player parent: abstract_unity_player {
    float player_size <- 10000.0;
    farm myfarm;
    rgb color;
    float cone_distance <- 5.0 * player_size;
    float cone_amplitude <- 90.0;
    float player_rotation <- -90.0;
    bool to_display <- false;
    bool ready_to_start <- false;
    bool finish_game <- false;
    string current_state;

    init {
        // Link player to farm using index (assuming name is the farm index)
        myfarm <- first(farm where (each.index = int(name)));
        color <- #green; // Use farm color or a default color
        do restart(int(name));
    }

    action restart (int id) {
        ask farm where (each.index = id) {
            salinity <- 0.0;
        }
    }

    float z_offset <- 2.0;

    aspect default {
        if (to_display) {
            draw square(player_size / 2.0) border: #black at: location + {0, 0, z_offset} color: color;
            draw player_perception_cone() border: #black color: rgb(color, 0.5);
        }
    }
}

