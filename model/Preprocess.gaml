/**
* Name: Preprocess
* Based on the internal empty template. 
* Author: hqn
* Tags: 
*/


model Preprocess
global{
	
	grid_file background_1_1m_utm48n0_grid_file <- grid_file("../includes/map/background_1_1m_utm48n.tif");
	geometry shape<-envelope(background_1_1m_utm48n0_grid_file);
	init{
		save cell to:"../results/grid.tif" format:"geotiff";
	}
}
grid cell width:20 height:20{
	
}
experiment main{
	output{
		display d1{
			
		}
	}
}