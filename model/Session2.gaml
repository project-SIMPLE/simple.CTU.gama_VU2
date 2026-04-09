model Session1

import "./AquaCommonVR.gaml"
import "./AquaGlobal.gaml"
experiment Session2 autorun: true type: unity {
//minimal time between two simulation step
	float minimum_cycle_duration <- 0.01;

	//name of the species used for the unity_linker
	string unity_linker_species <- string(unity_linker);

	//allow to hide the "map" display and to only display the displayVR display 
	list<string> displays_to_hide <- ["Digital Elevation Model", "W1", "Subsidence - Groundwater extracted"];
	parameter "let_gama_manage_time" var: let_gama_manage_game <- false among: [false];
	//parameter collaborating var: collaborating <- false among: [false];
	//action called by the middleware when a player connects to the simulation
	action create_player (string id) {
		ask unity_linker {
			any(GPlayLand where (each.rootPID = "")).rootPID <- id;
			do create_player(id);
		}

		write ("unity_player: " + (unity_player));
	}

	//action called by the middleware when a plyer is remove from the simulation
	action remove_player (string id_input) {
		if (not empty(unity_player)) {
			ask unity_linker {
				if (id_input in player_agents.keys) {
					do restart(id_input);
					ask unity_player(player_agents[id_input]) {
					//myland.rootPID<-"";
						do die;
					}

					remove key: id_input from: player_agents;
				}

			}

		}

	}

	//	point player_size <- {0.45, 0.45};
	//	point p_size <- {0.75, 0.75};
	//	point player_1_position <- {0.025, 0.025};
	//	point p1_position <- {-1e2, 2e4};
	//	point player_2_position <- {0.525, 0.025};
	//	point player_3_position <- {0.025, 0.525};
	//	point player_4_position <- {0.525, 0.525};
	font f <- font("Helvetica", 16, #bold);
	rgb c <- #white;
	output synchronized: true {
	//		layout #split consoles: false parameters: false toolbars: false tabs: false controls: false;	
		display "P1" type: 3d axes: false {
		//camera 'default' location: {908, 1122, 2053} target: {908, 1122, 0.0};
			graphics "image11" refresh: true {
				draw rectangle(world.shape.width * 1.5, world.shape.height) texture: image_file("../includes/images/land/sceneland1.jpg");
				float font_size <- (world.shape.width) / 500;
				draw session at: {400, 1100} color: #white font: font("Arial", font_size * 1.5 #px) anchor: #top_left;
				list<point>
				positions <- [{21, 500}, {318, 500}, {600, 500}, {-4, 750}, {28, 1351}, {340, 750}, {591, 1351}, {16, 1642}, {318, 1642}, {607, 1642}, {1252, 450}, {1262, 643}, {1131, 915}, {1336, 876}, {1154, 1303}, {1346, 1277}, {1179, 1642}];
				//draw farm[1].img at: positions[0] size: 50 #px;
				loop i from: 0 to: length(farm) - 1 {
					farm fr <- farm[i];
					point img_pos <- positions[i];
					draw fr.img at: img_pos size: font_size * 10 #px anchor: #center;
					draw "Sal: " + string(round(fr.salinity * 100) / 100) at: img_pos + {80, 80} color: #white font: font("Arial", font_size #px) anchor: #center;
				}

				draw "REMAINING TIME" at: {1950, 290} color: #white font: font("Arial", font_size * 2 #px) anchor: #right_center;
				draw "" + unity_player[0].remainingtime at: {1950, 350} color: #white font: font("Arial", font_size * 2 #px) anchor: #right_center;
				//Show Rice
				draw "" + unity_player[0].name_crop[0] + ": " + unity_player[0].quanlity_tree[0] at: {1950, 410} color: #white font: font("Arial", font_size * 1.3 #px) anchor: #top_left;
				//Show Durian
				draw "" + unity_player[0].name_crop[1] + ": " + unity_player[0].quanlity_tree[1] at: {1950, 470} color: #white font: font("Arial", font_size * 1.3 #px) anchor: #top_left;
				//Show Shrimp
				draw "" + unity_player[0].name_crop[2] + ": " + unity_player[0].quanlity_tree[2] at: {1950, 530} color: #white font: font("Arial", font_size * 1.3 #px) anchor: #top_left;
			}

			graphics "image12" refresh: true {
			//draw circle(50) color: #blue at: {815,815, 0};				
			//				draw circle(50) color: #green at: {0,0, 0};
			//				draw circle(50) color: #blue at: {100,0, 0};
			//				draw circle(50) color: #yellow at: {0,-100, 0};

			//				write "unity_player[0].location: " + unity_player[0].location;
			//				write "Players: " + length(unity_player);
				ask unity_player {
					draw circle(25) color: #red at: location;
					draw player_perception_cone() border: #black color: rgb(color, 0.5);
				}

				//Note
				//draw circle(25) color: #red at: unity_player[0].location;
				//write "Location: "+ unity_player[0].location;
				//write "Players: " + string(length(unity_player));


				//			graphics "image12" refresh: true rotate: -90 size: {0.45, 0.45} position: {900,1122} {
				//				draw circle(100) color: #blue at: {1122,900, 0};
				//				
			}
			//agents "P1" value: unity_player[0]  transparency: 0.25;

		}

		//		display "P2" type: 3d axes: false {
		//			graphics "image22" refresh: true {
		//				draw rectangle(world.shape.width * 1.5, world.shape.height) texture: image_file("../includes/images/land/sceneland1.jpg");
		//				float font_size <- (world.shape.width) / 500;
		//				draw session at: {400, 1100} color: #white font: font("Arial", font_size * 1.3 #px) anchor: #top_left;
		//
		//				//				ask farm {
		//				//					draw img at: img_pos size: 50 #px anchor: #center;
		//				//					draw "Sal: " + string(round(salinity * 100) / 100) at: sal_pos color: #white font: font("Arial", font_size #px) anchor: #center;
		//				//				}
		//				list<point>
		//				positions <- [{21, 500}, {318, 500}, {600, 500}, {-4, 750}, {28, 1351}, {340, 750}, {591, 1351}, {16, 1642}, {318, 1642}, {607, 1642}, {1252, 450}, {1262, 643}, {1131, 915}, {1336, 876}, {1154, 1303}, {1346, 1277}, {1179, 1642}];
		//				draw farm[1].img at: positions[0] size: 50 #px;
		//				loop i from: 0 to: length(farm) - 1 {
		//					farm fr <- farm[i];
		//					point img_pos <- positions[i];
		//					draw fr.img at: img_pos size: 50 #px anchor: #center;
		//					draw "Sal: " + string(round(fr.salinity * 100) / 100) at: img_pos + {80, 80} color: #white font: font("Arial", font_size #px) anchor: #center;
		//				}
		//
		//			}
		//
		//		}
		//
		//		display "P3" type: 3d axes: false {
		//			graphics "image33" refresh: true {
		//				draw rectangle(world.shape.width * 1.5, world.shape.height) texture: image_file("../includes/images/land/sceneland1.jpg");
		//				float font_size <- (world.shape.width ) / 500;
		//				draw session at: {400, 1100} color: #white font: font("Arial", font_size * 1.3 #px) anchor: #top_left;
		//
		//				//				ask farm {
		//				//					draw img at: img_pos size: 50 #px anchor: #center;
		//				//					draw "Sal: " + string(round(salinity * 100) / 100) at: sal_pos color: #white font: font("Arial", font_size #px) anchor: #center;
		//				//				}
		//				list<point>
		//				positions <- [{21, 500}, {318, 500}, {600, 500}, {-4, 750}, {28, 1351}, {340, 750}, {591, 1351}, {16, 1642}, {318, 1642}, {607, 1642}, {1252, 450}, {1262, 643}, {1131, 915}, {1336, 876}, {1154, 1303}, {1346, 1277}, {1179, 1642}];
		//				draw farm[1].img at: positions[0] size: 50 #px;
		//				loop i from: 0 to: length(farm) - 1 {
		//					farm fr <- farm[i];
		//					point img_pos <- positions[i];
		//					draw fr.img at: img_pos size: 50 #px anchor: #center;
		//					draw "Sal: " + string(round(fr.salinity * 100) / 100) at: img_pos + {80, 80} color: #white font: font("Arial", font_size #px) anchor: #center;
		//				}
		//
		//			}
		//
		//		}
		//
		//		display "P4" type: 3d axes: false {
		//			graphics "image44" refresh: true {
		//				draw rectangle(world.shape.width * 1.5, world.shape.height) texture: image_file("../includes/images/land/sceneland1.jpg");
		//				float font_size <- (world.shape.width) / 500;
		//				draw session at: {400, 1100} color: #white font: font("Arial", font_size * 1.3 #px) anchor: #top_left;
		//
		//				//				ask farm {
		//				//					draw img at: img_pos size: 50 #px anchor: #center;
		//				//					draw "Sal: " + string(round(salinity * 100) / 100) at: sal_pos color: #white font: font("Arial", font_size #px) anchor: #center;
		//				//				}
		//				list<point>
		//				positions <- [{21, 500}, {318, 500}, {600, 500}, {-4, 750}, {28, 1351}, {340, 750}, {591, 1351}, {16, 1642}, {318, 1642}, {607, 1642}, {1252, 450}, {1262, 643}, {1131, 915}, {1336, 876}, {1154, 1303}, {1346, 1277}, {1179, 1642}];
		//				draw farm[1].img at: positions[0] size: 50 #px;
		//				loop i from: 0 to: length(farm) - 1 {
		//					farm fr <- farm[i];
		//					point img_pos <- positions[i];
		//					draw fr.img at: img_pos size: 50 #px anchor: #center;
		//					draw "Sal: " + string(round(fr.salinity * 100) / 100) at: img_pos + {80, 80} color: #white font: font("Arial", font_size #px) anchor: #center;
		//				}
		//
		//			}
		//
		//		}

		/* 
		display "P2" type: 3d axes: false {
			camera 'default' location: {182997.1146, 136750.0, 165319.368} target: {183000.0, 136750.0, 0.0};

			/////P2
			//			agents "P2 background" value: [GPlayLand[1]] size: {0.5, 0.5} position: {0.5, 0} refresh: false;
			graphics "image21" refresh: false {
				draw rectangle(world.shape.height * 1177 / 1421, world.shape.height) texture: image_file("../includes/scene.png");
			}

			graphics "image22" refresh: true rotate: -90 size: {0.45, 0.45} position: {9e4, 6e4, 0.01} {
				int nP <- 1;
				int xx <- -70000;
				int yy <- 0;
				//draw rectangle(yy + (18000 * 6), yy + (18000 * 8)) color: #grey at: {(yy + (18000 * 8) / 5), (yy + (18000 * 8)) / 3};
				draw "P2 " + GPlayLand[nP].rootPID at: {xx, yy} font: f color: c;
				yy <- yy + 18000;
				draw "Time: " + GPlayLand[nP].cntTime at: {xx, yy} font: f color: c;
				yy <- yy + 18000; //78000
				draw "Cây chết: " + ((GPlayLand[nP].deadtrees)) font: f at: {xx, yy} color: c;
				yy <- yy + 18000; //98000
				draw "Nước sạch: " + ((GPlayLand[nP].numberWater)) font: f at: {xx, yy} color: c;
				yy <- yy + 18000; //38000
				draw "Máy bơm: " + (length(GPlayLand[nP].pumpers.values)) font: f at: {xx, yy} color: c;
				yy <- yy + 18000; //58000
				draw "Sụt lún: " + (mean(cell collect each.subsidence(GPlayLand[nP].playerLand_ID)) with_precision 2) at: {xx, yy} font: f color: c;
				yy <- yy + 18000; //58000
				draw "Score: " + ((GPlayLand[nP].current_score) with_precision 2) at: {xx, yy} font: f color: c;
			}

			agents "P2 Tree" value: GPlayLand[1].trees.values;
			agents "P2 warning" value: GPlayLand[1].enemy_spawners.values;
			agents "P2 Pumper" value: GPlayLand[1].pumpers.values;
			agents "P2 enemy" value: GPlayLand[1].enemies.values;
			agents "P2 fresh water" value: GPlayLand[1].fresh_waters.values;
			agents "P2" value: unity_player where (each.myland = GPlayLand[1]) transparency: 0.5;
		}

		display "P3" type: 3d axes: false {
			camera 'default' location: {182997.1146, 136750.0, 165319.368} target: {183000.0, 136750.0, 0.0};

			/////P3
			//			agents "P3 background" value: [GPlayLand[2]] size: {0.5, 0.5} position: {0.0, 0.5} refresh: false;
			graphics "image31" refresh: false {
				draw rectangle(world.shape.height * 1177 / 1421, world.shape.height) texture: image_file("../includes/scene.png");
			}

			graphics "image32" refresh: true rotate: -90 size: {0.45, 0.45} position: {9e4, 6e4, 0.01} {
				int nP <- 2;
				int xx <- -70000;
				int yy <- 0;
				//draw rectangle(yy + (18000 * 6), yy + (18000 * 8)) color: #grey at: {(yy + (18000 * 8) / 5), (yy + (18000 * 8)) / 3};
				draw "P3 " + GPlayLand[nP].rootPID at: {xx, yy} font: f color: c;
				yy <- yy + 18000;
				draw "Time: " + GPlayLand[nP].cntTime at: {xx, yy} font: f color: c;
				yy <- yy + 18000; //78000
				draw "Cây chết: " + ((GPlayLand[nP].deadtrees)) font: f at: {xx, yy} color: c;
				yy <- yy + 18000; //98000
				draw "Nước sạch: " + ((GPlayLand[nP].numberWater)) font: f at: {xx, yy} color: c;
				yy <- yy + 18000; //38000
				draw "Máy bơm: " + (length(GPlayLand[nP].pumpers.values)) font: f at: {xx, yy} color: c;
				yy <- yy + 18000; //58000
				draw "Sụt lún: " + (mean(cell collect each.subsidence(GPlayLand[nP].playerLand_ID)) with_precision 2) at: {xx, yy} font: f color: c;
				yy <- yy + 18000; //58000
				draw "Score: " + ((GPlayLand[nP].current_score) with_precision 2) at: {xx, yy} font: f color: c;
			}

			agents "P3 Tree" value: GPlayLand[2].trees.values;
			agents "P3 warning" value: GPlayLand[2].enemy_spawners.values;
			agents "P3 Pumper" value: GPlayLand[2].pumpers.values;
			agents "P3 enemy" value: GPlayLand[2].enemies.values;
			agents "P3 fresh water" value: GPlayLand[2].fresh_waters.values;
			agents "P3" value: unity_player where (each.myland = GPlayLand[2]) transparency: 0.5;
		}

		display "P4" type: 3d axes: false {
			camera 'default' location: {182997.1146, 136750.0, 165319.368} target: {183000.0, 136750.0, 0.0};

			/////P4
			//			agents "P4 background" value: [GPlayLand[3]] size: {0.5, 0.5} position: {0.5, 0.5} refresh: false;
			graphics "image41" refresh: false {
				draw rectangle(world.shape.height * 1177 / 1421, world.shape.height) texture: image_file("../includes/scene.png");
			}

			graphics "image42" refresh: true rotate: -90 size: {0.45, 0.45} position: {9e4, 6e4, 0.01} {
				int nP <- 3;
				int xx <- -70000;
				int yy <- 0;
				//draw rectangle(yy + (18000 * 6), yy + (18000 * 8)) color: #grey at: {(yy + (18000 * 8) / 5), (yy + (18000 * 8)) / 3};
				draw "P4 " + GPlayLand[nP].rootPID at: {xx, yy} font: f color: c;
				yy <- yy + 18000;
				draw "Time: " + GPlayLand[nP].cntTime at: {xx, yy} font: f color: c;
				yy <- yy + 18000; //78000
				draw "Cây chết: " + ((GPlayLand[nP].deadtrees)) font: f at: {xx, yy} color: c;
				yy <- yy + 18000; //98000
				draw "Nước sạch: " + ((GPlayLand[nP].numberWater)) font: f at: {xx, yy} color: c;
				yy <- yy + 18000; //38000
				draw "Máy bơm: " + (length(GPlayLand[nP].pumpers.values)) font: f at: {xx, yy} color: c;
				yy <- yy + 18000; //58000
				draw "Sụt lún: " + (mean(cell collect each.subsidence(GPlayLand[nP].playerLand_ID)) with_precision 2) at: {xx, yy} font: f color: c;
				yy <- yy + 18000; //58000
				draw "Score: " + ((GPlayLand[nP].current_score) with_precision 2) at: {xx, yy} font: f color: c;
			}

			agents "P4 Tree" value: GPlayLand[3].trees.values;
			agents "P4 warning" value: GPlayLand[3].enemy_spawners.values;
			agents "P4 Pumper" value: GPlayLand[3].pumpers.values;
			agents "P4 enemy" value: GPlayLand[3].enemies.values;
			agents "P4 fresh water" value: GPlayLand[3].fresh_waters.values;
			agents "P4" value: unity_player where (each.myland = GPlayLand[3]) transparency: 0.5;
		}
*/
	}

}
