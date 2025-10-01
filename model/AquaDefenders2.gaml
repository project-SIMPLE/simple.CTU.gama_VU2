/**
* Name: AquaDefenders1
* Based on the internal empty template. 
* Author: ltmloan
* Tags: 
*/


model AquaDefenders1

global {
	file dem_file   <- file("../results/grid.tif"); 
	file river_file <- file("../includes/map/river.shp");
	file farm_file <- file("../includes/map/farm.shp");

	// Shape của môi trường dựa trên DEM
	geometry shape <- envelope(dem_file);

	// Danh sách ô nguồn
	list<cell> source_fresh_cells;  // biên trái
	list<cell> source_salt_cells;   // biên phải
	list<cell> river_cells;         // ô thuộc sông
float step<-1#day;
	// Tham số mô phỏng
	float diffusion_rate   <- 0.7;   // tăng để flow nhanh hơn
	float total_input      <- 0.3;   // tổng lượng input (constant)
	float input_water      <- 0.2;   // lượng nước ngọt thêm vào mỗi bước (sẽ được parameter hóa)
	float input_salt_water <- 0.1;   // lượng nước mặn thêm vào mỗi bước (tự động tính)

	init {
		create river from: river_file;
		create farm from: farm_file;
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
			saltwater  <- 0.0;

			// nếu là ô sông: nhiều nước ngọt ban đầu, nhưng vẫn cho mặn xâm nhập
			if (self overlaps first(river)) {
				freshwater <- 0.8;  // giảm nhẹ để dễ nhận mặn hơn
				saltwater  <- 0.0;
			}

			// nếu là ô biên phải: nước mặn từ biển
			if (grid_x = 30 - 1) {
				freshwater <- 0.5;
				saltwater  <- 0.15;  // tăng để gradient mặn rõ hơn
			}

			neighbour_cells <- (self neighbors_at 1);
		}
	}

	// Xác định nguồn nước
	action identify_sources {
		source_fresh_cells <- cell where (each.grid_x = 0);
		source_salt_cells  <- cell where (each.grid_x = 30 - 1);
		river_cells        <- cell where (each overlaps first(river));
	}

	// Nạp thêm nước ngọt từ biên trái (sử dụng input_water hiện tại)
	reflex add_freshwater {
		ask source_fresh_cells {
			freshwater <- freshwater + input_water;
		}
	}

	// Nạp thêm nước mặn từ biên phải (tự động tính dựa trên input_water)
	reflex add_saltwater {
		input_salt_water <- total_input - input_water;  // cập nhật mỗi step để phản ánh thay đổi
		ask source_salt_cells {
			saltwater <- saltwater + input_salt_water;
		}
	}

	// Lan truyền nước ngọt + mặn
	reflex diffusion {
		write current_date;
		ask cell {
			do flow;
			do update_color;
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
					float flow_amount <- (total - n_total) * diffusion_rate * 0.7;  // tăng hệ số để flow mạnh hơn

					if (flow_amount > 0) {  // tránh flow zero/âm
						// chia tỷ lệ theo thành phần nước ngọt/mặn
						float flow_fresh <- flow_amount * (freshwater / total);
						float flow_salt  <- min(flow_amount * (saltwater / total), total * 0.2);  // giới hạn salt flow để cân bằng

						// cập nhật cho neighbour
						n.freshwater <- n.freshwater + flow_fresh;
						n.saltwater  <- n.saltwater  + flow_salt;

						// trừ ở ô hiện tại
						freshwater <- freshwater - flow_fresh;
						saltwater  <- saltwater  - flow_salt;
					}
				}
			}
		}
	}

	// Cập nhật màu theo độ mặn
	action update_color {
		float total <- freshwater + saltwater;
		float salinity <- saltwater / max([0.0001, total]);

		int r <- int(255 * salinity);       // đỏ nhiều khi mặn
		int g <- int(180 * (1 - salinity)); // xanh nhiều khi ngọt
		int b <- 200;                       // nền xanh dương nhạt

		color <- rgb(r, g, b);
	}
}

species river {
	aspect default {
		draw shape color: #blue;
	}
}

species farm {
	aspect default {
		draw shape color: #green;
	}
}

experiment AquaDefenders type: gui {
	parameter "Input Water Fresh (%)" var: input_water min: 0.0 max: total_input step: 0.01 category: "Simulation Parameters";
	output {
		display map type: 2d {
			grid cell border: #black;
			species river;
			species farm;
		}
		// Thêm monitor để theo dõi giá trị (user có thể inspect global để thay đổi động)
		monitor "Input Fresh" value: input_water;
		monitor "Input Salt" value: input_salt_water;
	}
}

