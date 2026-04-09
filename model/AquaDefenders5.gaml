/**
* Name: AquaDefenders5
* Based on the internal empty template. 
* Author: ltmloan
* Tags: 
*/
model AquaDefenders5

global {
	file dem_file <- file("../results/grid.tif");
	file river_file <- file("../includes/map/river.shp");
	file farm_file <- file("../includes/map/farm.shp");
	csv_file farm0_csv_file <- csv_file("../includes/farm.csv");

	// Shape của môi trường dựa trên DEM
	geometry shape <- envelope(dem_file);
	string region_name <- "Default Region";
	string session <- "";

	// Danh sách ô nguồn
	list<cell> source_fresh_cells; // biên trái
	list<cell> source_salt_cells; // biên phải
	list<cell> river_cells; // ô thuộc sông
	float step <- 1 #day;
	// Tham số mô phỏng
	float diffusion_rate <- 0.7; // tăng để flow nhanh hơn
	float total_input <- 0.3; // tổng lượng input (constant)
	float input_water <- 0.2; // lượng nước ngọt thêm vào mỗi bước (sẽ thay đổi theo mùa)
	float input_salt_water <- 0.1; // lượng nước mặn thêm vào mỗi bước (sẽ thay đổi theo mùa)
	init {
		create river from: river_file;
		//create farm from: farm_file;
		// ví dụ: tạo 4 vùng trồng
		create farm from: farm_file number: 17;
		matrix data <- matrix(farm0_csv_file);
		//loop on the matrix rows (skip the first header line)
		loop i from: 1 to: data.rows - 1 {
			write int(data[0, i]);
			ask (farm where (each.index = int(data[0, i]))) {
				crop_type <- data[1, i];
				season_start <- int(data[2, i]);
				season_end <- int(data[3, i]);
				img <- image_file(data[4, i]);
			}

		}
		//        create farm from: farm_file number: 17 {
		//            if (self.index = 0) { crop_type <- "Ổi-Guava"; season_start <- 0; season_end <- 90; img <- image_file("../includes/images/crops/icon_oi.png");}
		//            if (self.index = 1) { crop_type <- "Bắp-Corn"; season_start <- 0; season_end <- 90; img <- image_file("../includes/images/crops/icon_bap.png");}
		//            if (self.index = 2) { crop_type <- "Dâu tằm-Mulberry"; season_start <- 30; season_end <- 120; img <- image_file("../includes/images/crops/icon_dau tam.png");}
		//            if (self.index = 3) { crop_type <- "Cá-Fish"; season_start <- 60; season_end <- 150; img <- image_file("../includes/images/aquatic/icon_ca chep.png");}
		//            if (self.index = 4) { crop_type <- "Mía-Sugarcane"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/crops/icon_cay mia.png");}
		//            if (self.index = 5) { crop_type <- "Lúa-Rice"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/crops/icon_lua.png");}
		//            if (self.index = 6) { crop_type <- "Cá-Fish"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/aquatic/icon_ca dieu hong.png");}
		//            if (self.index = 7) { crop_type <- "Dê-Goat"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/animals/icon_de.png");}
		//            if (self.index = 8) { crop_type <- "Gà-Chicken"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/animals/icon_chicken.png");}
		//            if (self.index = 9) { crop_type <- "Heo-Pig"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/animals/icon_pig.png");}
		//            if (self.index = 10) { crop_type <- "Thanh Long-Dragon fruit"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/crops/icon_thanh long.png");}
		//            if (self.index = 11) { crop_type <- "Khóm-Pineapple"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/crops/icon_thom.png");}
		//            if (self.index = 12) { crop_type <- "Mít-Jackfruit"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/crops/icon_mit.png");}
		//            if (self.index = 13) { crop_type <- "Tôm-Shrimp"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/aquatic/icon_tom su.png");}
		//            if (self.index = 14) { crop_type <- "Chuối-Banana"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/crops/icon_banana.png"); }
		//            if (self.index = 15) { crop_type <- "Cua-Crab"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/aquatic/icon_cua bien.png");}   
		//            if (self.index = 16) { crop_type <- "Dừa-Coconut"; season_start <- 100; season_end <- 200; img <- image_file("../includes/images/crops/icon_coconut.png"); }      
		//            
		//            // Tạo crop trong vùng farm
		////            create crop {
		////                crop_type <- myself.crop_type;
		////                if (crop_type = "rice") { img <- file("../includes/images/crops/icon_banana.png"); }
		////                if (crop_type = "corn") { img <- file("../includes/images/crops/icon_banana.png"); }
		////                if (crop_type = "potato") { img <- file("../includes/images/crops/icon_banana.png"); }
		////                if (crop_type = "cassava") { img <- file("../includes/images/crops/icon_banana.png"); }
		////                location <- one_of(myself); // đặt crop vào trong geometry của farm
		////            }
		//		}
		do init_cells;
		do identify_sources;

		// cập nhật màu ban đầu
		ask cell {
			do update_color;
		}

	}

	// Khởi tạo freshwater, saltwater cho từng ô
	action init_cells {
		ask cell {
			freshwater <- 0.5;
			saltwater <- 0.0;

			// nếu là ô sông: nhiều nước ngọt ban đầu, nhưng vẫn cho mặn xâm nhập
			if (self overlaps first(river)) {
				freshwater <- 0.8; // giảm nhẹ để dễ nhận mặn hơn
				saltwater <- 0.0;
			}

			// nếu là ô biên phải: nước mặn từ biển
			if (grid_x = 30 - 1) {
				freshwater <- 0.5;
				saltwater <- 0.15; // tăng để gradient mặn rõ hơn
			}

			neighbour_cells <- (self neighbors_at 1);
		}

	}

	// Xác định nguồn nước
	action identify_sources {
		source_fresh_cells <- cell where (each.grid_x = 0);
		source_salt_cells <- cell where (each.grid_x = 30 - 1);
		river_cells <- cell where (each overlaps first(river));
	}

	// Nạp thêm nước ngọt từ biên trái (sử dụng input_water hiện tại)
	reflex add_freshwater {
	// Điều chỉnh input theo mùa
		int current_month <- month(current_date);
		//Mùa mưa từ tháng 5-10
		if (current_month >= 5 and current_month <= 10) {
			session <- "Rainy Season";
			input_water <- 0.25; // Mùa mưa: nước ngọt lớn
		} else {
			session <- "Dry Season";
			input_water <- 0.05; // Mùa khô: nước ngọt nhỏ
		}

		//write input_water;
		input_salt_water <- total_input - input_water;
		ask source_fresh_cells {
			freshwater <- freshwater + input_water;
		}

	}

	// Nạp thêm nước mặn từ biên phải (tự động tính dựa trên input_water)
	reflex add_saltwater {
		ask source_salt_cells {
			saltwater <- saltwater + input_salt_water;
		}

	}

	// Lan truyền nước ngọt + mặn
	reflex diffusion {
		write "Month: "+month(current_date);
		ask cell {
			do flow;
			do update_color;
		}

	}

	// Cập nhật salinity cho farm dựa trên cell overlapping (sau diffusion)
	reflex update_farm_salinity {
		ask farm {
			do update_salinity;
		}

	}

}

grid cell file: dem_file neighbors: 8 use_regular_agents: false {
	float freshwater;
	float saltwater;
	list<cell> neighbour_cells;

	// Lan truyền cả nước ngọt và mặn
	action flow {
		float total <- freshwater + saltwater;
		if (total > 0) {
			loop n over: neighbour_cells {
				float n_total <- n.freshwater + n.saltwater;

				// tính chênh lệch tổng nước
				if (total > n_total) {
					float flow_amount <- (total - n_total) * diffusion_rate * 0.7; // tăng hệ số để flow mạnh hơn
					if (flow_amount > 0) { // tránh flow zero/âm
					// chia tỷ lệ theo thành phần nước ngọt/mặn
						float flow_fresh <- flow_amount * (freshwater / total);
						float flow_salt <- min(flow_amount * (saltwater / total), total * 0.2); // giới hạn salt flow để cân bằng

						// cập nhật cho neighbour
						n.freshwater <- n.freshwater + flow_fresh;
						n.saltwater <- n.saltwater + flow_salt;

						// trừ ở ô hiện tại
						freshwater <- freshwater - flow_fresh;
						saltwater <- saltwater - flow_salt;
					}

				}

			}

		}

	}

	// Cập nhật màu theo độ mặn
	action update_color {
		float total <- freshwater + saltwater;
		float salinity <- saltwater / max([0.0001, total]);
		int r <- int(255 * salinity); // đỏ nhiều khi mặn
		int g <- int(180 * (1 - salinity)); // xanh nhiều khi ngọt
		int b <- 200; // nền xanh dương nhạt
		color <- rgb(r, g, b);
	}

}

species river {

	aspect default {
		draw shape color: #blue;
	}

}

species farm {
	string crop_type; // loại cây
	image_file img;
	int season_start;
	int season_end;
	float salinity init: 0.0;
	point img_pos;
	point sal_pos;

	// Cập nhật salinity dựa trên cell overlapping
	action update_salinity {
		list<cell> overlapping_cells <- cell where (each overlaps self);
		if (!empty(overlapping_cells)) {
			salinity <- mean(overlapping_cells collect (each.saltwater / (each.freshwater + each.saltwater + 0.0001)));
		}

	}

	aspect default {
		draw shape color: #green border: #darkgreen;

		// Vị trí image
		img_pos <- location + {0, -50};
		if (img != nil) {
			draw img at: img_pos size: 50 #px anchor: #center;
		}

		// Vị trí text crop_type phía trên
		point text_pos <- location + {0, 45};
		draw crop_type at: text_pos color: #black font: font("Arial", 15) anchor: #center;

		// Vị trí salinity phía dưới crop_type
		sal_pos <- location + {0, 90};
		draw "Sal: " + round(salinity * 100) / 100 at: sal_pos color: #white font: font("Arial", 13) anchor: #center;
	}

	aspect visual {
		img_pos <- location + {0, -50};
		draw img at: img_pos size: 50 #px anchor: #center;
		sal_pos <- location + {0, 90};
		draw "Sal: " + string(round(salinity * 100) / 100) at: sal_pos color: #white font: font("Arial", 13 #px) anchor: #center;
	}

}

species crop {
	string crop_type;
	file img;

	aspect default {
		draw circle(1.0) color: #orange;
	}

}

experiment AquaDefenders5 type: gui {
//parameter "Input Water Fresh (%)" var: input_water min: 0.0 max: total_input step: 0.01 category: "Simulation Parameters";
	output {
		display map type: 2d {
			grid cell border: #black;
			species river;
			species farm;
			species crop;
			// Hiển thị mùa ở góc trên bên trái
			graphics "Session" position: {0.01, 0.01} {
				draw session color: #white font: font("Arial", 14 #px) anchor: #top_left;
			}

		}

		// Thêm monitor để theo dõi giá trị (user có thể inspect global để thay đổi động)
		//monitor "Input Fresh" value: input_water;
		//monitor "Input Salt" value: input_salt_water;
	}

}