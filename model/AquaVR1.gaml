/**
* Name: AquaVR1
* Based on the internal empty template. 
* Author: minhloan
* Tags: 
*/


model AquaVR1

import "AquaDefenders5.gaml"

global {
    // Define four PlayLand instances for the four regions
    list<PlayLand> playlands;
    
    // Initialize the simulation
    init {
        // Create four PlayLand instances
        create PlayLand number: 4 {
            playerLand_ID <- int(self);
            playlands << self;
            // Initialize cells, river, and farms for each PlayLand
            do init_region;
        }
    }
    
    // Reflex to update water input based on season for all playlands
    reflex update_seasonal_input {
        int current_month <- month(current_date);
        // Rainy season: May to November
        float input_water <- (current_month >= 5 and current_month <= 11) ? 0.25 : 0.05;
        float input_salt_water <- total_input - input_water;
        ask playlands {
            self.input_water <- input_water;
            self.input_salt_water <- input_salt_water;
        }
    }
    
    // Reflex to trigger diffusion and salinity updates in each PlayLand
    reflex simulate_regions {
        ask playlands {
            do simulate;
        }
    }
}

species PlayLand {
    int playerLand_ID;
    list<cell> my_cells;
    list<river> my_river;
    list<farm> my_farms;
    float input_water <- 0.2;
    float input_salt_water <- 0.1;
    float salinity <- 0.0; // Average salinity for this region
    list<string> crop_types; // Store crop types in this region
    
    // Initialize the region (cells, river, farms)
    action init_region {
        // Create a grid of cells specific to this PlayLand
        create cell number: 30 * 30 { // Assuming a 30x30 grid as in AquaDefenders5
            playerLand_ID <- myself.playerLand_ID;
            my_cells << self;
            freshwater <- 0.5;
            saltwater <- 0.0;
            // Initialize cells on the right border with saltwater
            if (grid_x = 30 - 1) {
                freshwater <- 0.5;
                saltwater <- 0.15;
            }
            neighbour_cells <- (self neighbors_at 1);
        }
        
        // Create a river for this PlayLand
        create river from: river_file {
            playerLand_ID <- myself.playerLand_ID;
            my_river << self;
        }
        
        // Create farms with crop types
        create farm from: farm_file number: 17 {
            playerLand_ID <- myself.playerLand_ID;
            my_farms << self;
            // Assign crop types and properties as in AquaDefenders5
            if (self.index = 0) { crop_type <- "cam"; season_start <- 0; season_end <- 90; img <- image_file("../includes/images/crops/icon_trai cam.png");}
            if (self.index = 1) { crop_type <- "bap"; season_start <- 0; season_end <- 90; img <- image_file("../includes/images/crops/icon_bap.png");}
            if (self.index = 2) { crop_type <- "bap cai"; season_start <- 30; season_end <- 120; img <- image_file("../includes/images/crops/icon_cai bap.png");}
            if (self.index = 3) { crop_type <- "ca chep"; season_start <- 60; season_end <- 150; img <- image_file("../includes/images/aquatic/icon_ca chep.png");}
            if (self.index = 4) { crop_type <- "mia"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/crops/icon_cay mia.png");}
            if (self.index = 5) { crop_type <- "chom chom"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/crops/icon_chom chom.png");}
            if (self.index = 6) { crop_type <- "ca dieu hong"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/aquatic/icon_ca dieu hong.png");}
            if (self.index = 7) { crop_type <- "de"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/animals/icon_de.png");}
            if (self.index = 8) { crop_type <- "ga"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/animals/icon_chicken.png");}
            if (self.index = 9) { crop_type <- "heo"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/animals/icon_pig.png");}
            if (self.index = 10) { crop_type <- "thanh long"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/crops/icon_thanh long.png");}
            if (self.index = 11) { crop_type <- "thom"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/crops/icon_thom.png");}
            if (self.index = 12) { crop_type <- "dua nuoc"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/crops/icon_dua nuoc_1.png");}
            if (self.index = 13) { crop_type <- "tom su"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/aquatic/icon_tom su.png");}
            if (self.index = 14) { crop_type <- "banana"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/crops/icon_banana.png");}
            if (self.index = 15) { crop_type <- "tom cang xanh"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/aquatic/icon_tom cang xanh.png");}
            if (self.index = 16) { crop_type <- "dua"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/crops/icon_coconut.png");}
            myself.crop_types << crop_type;
        }
        
        // Identify source cells for this PlayLand
        do identify_sources;
        
        // Initialize cell colors
        ask my_cells {
            do update_color;
        }
    }
    
    // Identify source cells for fresh and saltwater
    action identify_sources {
        source_fresh_cells <- my_cells where (each.grid_x = 0);
        source_salt_cells <- my_cells where (each.grid_x = 30 - 1);
        river_cells <- my_cells where (each overlaps first(my_river));
    }
    
    // Simulate one step for this PlayLand
    action simulate {
        // Add freshwater
        ask source_fresh_cells {
            freshwater <- freshwater + myself.input_water;
        }
        
        // Add saltwater
        ask source_salt_cells {
            saltwater <- saltwater + myself.input_salt_water;
        }
        
        // Diffusion
        ask my_cells {
            do flow;
            do update_color;
        }
        
        // Update farm salinity
        ask my_farms {
            do update_salinity;
        }
        
        // Calculate average salinity for this PlayLand
        salinity <- mean(my_cells collect (each.saltwater / (each.freshwater + each.saltwater + 0.0001)));
    }
}

species cell {
    int playerLand_ID;
    float freshwater;
    float saltwater;
    list<cell> neighbour_cells;
    
    action flow {
        float total <- freshwater + saltwater;
        if (total > 0) {
            loop n over: neighbour_cells {
                if (n.playerLand_ID = playerLand_ID) { // Only flow within the same PlayLand
                    float n_total <- n.freshwater + n.saltwater;
                    if (total > n_total) {
                        float flow_amount <- (total - n_total) * diffusion_rate * 0.7;
                        if (flow_amount > 0) {
                            float flow_fresh <- flow_amount * (freshwater / total);
                            float flow_salt <- min(flow_amount * (saltwater / total), total * 0.2);
                            n.freshwater <- n.freshwater + flow_fresh;
                            n.saltwater <- n.saltwater + flow_salt;
                            freshwater <- freshwater - flow_fresh;
                            saltwater <- saltwater - flow_salt;
                        }
                    }
                }
            }
        }
    }
    
    action update_color {
        float total <- freshwater + saltwater;
        float salinity <- saltwater / max([0.0001, total]);
        int r <- int(255 * salinity);
        int g <- int(180 * (1 - salinity));
        int b <- 200;
        color <- rgb(r, g, b);
    }
}

species river {
    int playerLand_ID;
    aspect default {
        draw shape color: #blue;
    }
}

species farm {
    int playerLand_ID;
    string crop_type;
    image_file img;
    int season_start;
    int season_end;
    float salinity init: 0.0;
    
    action update_salinity {
        list<cell> overlapping_cells <- cell where (each overlaps self and each.playerLand_ID = myself.playerLand_ID);
        if (!empty(overlapping_cells)) {
            salinity <- mean(overlapping_cells collect (each.saltwater / (each.freshwater + each.saltwater + 0.0001)));
        }
    }
    
    aspect default {
        draw shape color: #green border: #darkgreen;
        point img_pos <- location + {0, -50};
        if (img != nil) {
            draw img at: img_pos size: 50#px anchor: #center;
        }
        point text_pos <- location + {0, 50};
        draw crop_type at: text_pos color: #black font: font("Arial", 15) anchor: #center;
        point sal_pos <- location + {0, 93};
        draw "Sal: " + round(salinity * 100) / 100 at: sal_pos color: #white font: font("Arial", 13) anchor: #center;
    }
}

experiment AquaVR type: gui autorun: true {
    output synchronized: true {
        layout #split consoles: false parameters: false toolbars: false tabs: false controls: false;
        
        // Display for PlayLand 0 (Top-Left)
        display "PlayLand1" type: 2d axes: false {
            camera 'default' location: {world.shape.width / 2, world.shape.height / 2, world.shape.height * 0.5} target: {world.shape.width / 2, world.shape.height / 2, 0.0};
            grid cell where (each.playerLand_ID = 0) border: #black;
            species river where (each.playerLand_ID = 0);
            species farm where (each.playerLand_ID = 0);
            graphics "info" refresh: true {
                draw "PlayLand 1" at: {world.shape.width * 0.1, world.shape.height * 0.05} color: #white font: font("Arial", 16, #bold);
                draw "Salinity: " + round(playlands[0].salinity * 100) / 100 at: {world.shape.width * 0.1, world.shape.height * 0.1} color: #white font: font("Arial", 14);
                draw "Crops: " + playlands[0].crop_types at: {world.shape.width * 0.1, world.shape.height * 0.15} color: #white font: font("Arial", 14);
            }
        }
        
        // Display for PlayLand 1 (Top-Right)
        display "PlayLand2" type: 2d axes: false {
            camera 'default' location: {world.shape.width / 2, world.shape.height / 2, world.shape.height * 0.5} target: {world.shape.width / 2, world.shape.height / 2, 0.0};
            grid cell where (each.playerLand_ID = 1) border: #black;
            species river where (each.playerLand_ID = 1);
            species farm where (each.playerLand_ID = 1);
            graphics "info" refresh: true {
                draw "PlayLand 2" at: {world.shape.width * 0.1, world.shape.height * 0.05} color: #white font: font("Arial", 16, #bold);
                draw "Salinity: " + round(playlands[1].salinity * 100) / 100 at: {world.shape.width * 0.1, world.shape.height * 0.1} color: #white font: font("Arial", 14);
                draw "Crops: " + playlands[1].crop_types at: {world.shape.width * 0.1, world.shape.height * 0.15} color: #white font: font("Arial", 14);
            }
        }
        
        // Display for PlayLand 2 (Bottom-Left)
        display "PlayLand3" type: 2d axes: false {
            camera 'default' location: {world.shape.width / 2, world.shape.height / 2, world.shape.height * 0.5} target: {world.shape.width / 2, world.shape.height / 2, 0.0};
            grid cell where (each.playerLand_ID = 2) border: #black;
            species river where (each.playerLand_ID = 2);
            species farm where (each.playerLand_ID = 2);
            graphics "info" refresh: true {
                draw "PlayLand 3" at: {world.shape.width * 0.1, world.shape.height * 0.05} color: #white font: font("Arial", 16, #bold);
                draw "Salinity: " + round(playlands[2].salinity * 100) / 100 at: {world.shape.width * 0.1, world.shape.height * 0.1} color: #white font: font("Arial", 14);
                draw "Crops: " + playlands[2].crop_types at: {world.shape.width * 0.1, world.shape.height * 0.15} color: #white font: font("Arial", 14);
            }
        }
        
        // Display for PlayLand 3 (Bottom-Right)
        display "PlayLand4" type: 2d axes: false {
            camera 'default' location: {world.shape.width / 2, world.shape.height / 2, world.shape.height * 0.5} target: {world.shape.width / 2, world.shape.height / 2, 0.0};
            grid cell where (each.playerLand_ID = 3) border: #black;
            species river where (each.playerLand_ID = 3);
            species farm where (each.playerLand_ID = 3);
            graphics "info" refresh: true {
                draw "PlayLand 4" at: {world.shape.width * 0.1, world.shape.height * 0.05} color: #white font: font("Arial", 16, #bold);
                draw "Salinity: " + round(playlands[3].salinity * 100) / 100 at: {world.shape.width * 0.1, world.shape.height * 0.1} color: #white font: font("Arial", 14);
                draw "Crops: " + playlands[3].crop_types at: {world.shape.width * 0.1, world.shape.height * 0.15} color: #white font: font("Arial", 14);
            }
        }
        
        // Monitor global parameters
        monitor "Current Month" value: month(current_date);
        monitor "Global Input Fresh" value: playlands[0].input_water;
        monitor "Global Input Salt" value: playlands[0].input_salt_water;
    }
}

