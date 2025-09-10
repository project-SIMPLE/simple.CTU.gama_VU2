/**
* Name: Preprocess
* Based on the internal empty template. 
* Author: hqn
* Tags: 
*/
model Preprocess

global {
	int size_grid <- 30;
	shape_file river0_shape_file <- shape_file("../includes/map/river.shp");
	grid_file background_1_1m_utm48n0_grid_file <- grid_file("../includes/map/background_1_1m_utm48n.tif");
	geometry shape <- envelope(background_1_1m_utm48n0_grid_file);

	init {
		create river from: river0_shape_file {
			ask cell overlapping self {
				grid_value <- grid_value - 20;
				color <- rgb(grid_value-50);
			}

		}

		save cell to: "../results/grid.tif" format: "geotiff";
	}

}

species river {
	aspect default{
		draw shape wireframe:true;
	}
}

grid cell width: size_grid height: size_grid {

	init {
	//		write ""+ self.grid_x+" "+self.grid_y;
		grid_value <- float(size_grid * 10 - (grid_x*5));
		color <- rgb(grid_value-50);
	}

	aspect default {
		draw shape color: color;
		draw "" + grid_value color: #red font: font("Helvetica", 6, #bold);
	}

}

experiment main {
	output {
		display d1 {
			grid cell border: #black;
						species river;
		}

		display d2 {
			species cell;
			//			grid cell border:#black ;
			//			species river;
		}

	}

}