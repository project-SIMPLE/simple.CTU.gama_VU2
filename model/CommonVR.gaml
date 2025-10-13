/**
 * Name: CommonVR
 * Based on the internal empty template. 
 * Author: patricktaillandier (rewritten for AquaDefenders5 compatibility)
 * Tags: 
 */
model CommonVR

global {
    // Các global variables cần thiết cho Unity integration
    // Constants cho game (đơn giản hóa cho AquaDefenders5)
    int duration_preparation <- 60;  // Thời gian chuẩn bị
    int duration_defense <- 300;     // Thời gian phòng thủ
    float precision <- 1.0;          // Độ chính xác cho tọa độ
    bool let_gama_manage_game <- false;  // GAMA quản lý game?
    bool collaborating <- false;     // Chế độ hợp tác? (không dùng trong Aqua)
    
    // Thời gian hiện tại cho defense
    float current_time_def <- 0.0;
    
    // Các rates refresh (loại bỏ nếu không cần, giữ cho tương thích)
    int pumper_rate_refresh_rate <- 10;    // Không dùng
    int enemy_genetation_rate_refresh_rate <- 5;  // Không dùng
    int update_subsidence_refresh_rate <- 20;     // Không dùng
}

// Loại bỏ model keyword để làm file import thuần túy, chỉ định nghĩa species và global

species unity_linker parent: abstract_unity_linker {
    //name of the species used to represent a Unity player
    string player_species <- string(unity_player);
    float min_player_position_update_duration <- 0.1;

    //in this model, information about other player will be automatically sent to the Player at every step, so we set do_info_world to true
    bool do_send_world <- false;

    //max number of players that can play the game
    int max_num_players <- 99999;

    //min number of players to start the simulation
    int min_num_players <- 99999;
    list<point> init_locations <- [any_location_in(world) + {0, 0, 1}];

    action new_connection (string id) {
        current_time_def <- gama.machine_time + (duration_defense + duration_preparation) * 1000.0;
        if (id in player_agents.keys) {
            if (not let_gama_manage_game) {
                do restart(id);
                ask unity_player(player_agents[id]) {
                    do die;
                }

                remove key: id from: player_agents;
                do create_player(id);
            } else {
            }

        }

    }

    action restart (string id) {
        unity_player Pl <- player_agents[id];
        // Reset simulation state cho Aqua: có thể reset diffusion hoặc salinity nếu cần
        // Ví dụ: ask farm { salinity <- 0.0; }
        Pl.ready_to_start <- false;
    }

    action change_state (string idP, string new_state) {
        unity_player Pl <- player_agents[idP];
        Pl.current_state <- new_state;
    }

    action player_ready (string idP) {
        unity_player Pl <- player_agents[idP];
        Pl.ready_to_start <- true;
    }

    action player_finish_game (string idP) {
        write "END FOR " + idP;
        if (let_gama_manage_game) {
            unity_player Pl <- player_agents[idP];
            Pl.finish_game <- true;
        }

    }

    reflex let_player_start when: not empty(unity_player where !each.ready_to_start) {
        if (not let_gama_manage_game) {
            do send_message(unity_player where !each.ready_to_start, ["readyToStart"::""]);
        } else {
            do send_message(unity_player where !each.ready_to_start, ["startGame"::true, "time_prep"::duration_preparation, "time_def"::duration_defense]);
        }

    }

    reflex end_sequence when: (let_gama_manage_game) and empty(unity_player where not each.finish_game) {
        write "END OF GAME";
        ask unity_player {
            finish_game <- false;
        }

        current_time_def <- 0.0;
        ask world {
            do pause;
        }

    }

    // Giữ toGAMACoordinate nếu cần tọa độ Unity -> GAMA
    point toGAMACoordinate (int x, int y) {
        float xa <- 2426.08;
        float xb <- 181088.094;
        float ya <- -2534.754;
        float yb <- 199992.122;
        return {x / precision * xa + xb, y / precision * ya + yb};
    }

    // Thêm action nếu cần cho Aqua, ví dụ: update_player_pos đơn giản
    action update_player_pos (string idP, int x, int y, int o) {
        unity_player Pl <- player_agents[idP];
        Pl.location <- toGAMACoordinate(x, y);
        Pl.heading <- float(o / precision) + 90;
        Pl.to_display <- true;
    }

}

species unity_player parent: abstract_unity_player {
    //size of the player in GAMA
    float player_size <- 10000.0;
    // Loại bỏ myland vì không có GPlayLand trong Aqua

    //color of the player in GAMA
    rgb color <- #blue;

    //vision cone distance in GAMA 
    float cone_distance <- 5.0 * player_size;

    //vision cone amplitude in GAMA
    float cone_amplitude <- 90.0;

    //rotation to apply from the heading of Unity to GAMA
    float player_rotation <- -90.0;
    bool to_display <- false;
    bool ready_to_start <- false;
    bool finish_game <- false;
    string current_state;

    init {
        color <- #blue;
        // Không cần Restart vì không có land
    }

    float z_offset <- 2.0;

    aspect default {
        if (to_display) {
            draw square(player_size / 2.0) border: #black at: location + {0, 0, z_offset} color: color;
            draw player_perception_cone() border: #black color: rgb(color, 0.5);
        }

    }
}