model AquaGlobal

global { 
	
	float totalGroundVolumeUsed <- 0.0;

	//salt water quantity level
	float saltwaterQuantity <- 1.0; 

	bool let_gama_manage_game ;
	
	float current_time_def <- 0.0;
	
	
	bool collaborating<-false;
	
	float pump_per_step <-  0.5;//pumVolumeHour * pumHourperDay * pumDayperMonth * pumMonthperYear / pixelSize; 
	init {
		create GPlayLand number: 4  {
			playerLand_ID <- int(self); 			
		}	
		if(collaborating){
//			GPlayLand[0].downstream<-GPlayLand[2];
//			GPlayLand[1].downstream<-GPlayLand[3];
//			
//			GPlayLand[2].upstream<-GPlayLand[0];
//			GPlayLand[3].upstream<-GPlayLand[1];


			GPlayLand[0].downstream<-GPlayLand[1];
			GPlayLand[2].downstream<-GPlayLand[3];
			
			GPlayLand[1].upstream<-GPlayLand[0];
			GPlayLand[3].upstream<-GPlayLand[2];
			
//			refill_rates <- [0.001,0.0001,0.001,0.0001];
			
		}
	} 
}

species GPlayLand {
	GPlayLand upstream;
	GPlayLand downstream;
	int playerLand_ID;
	string rootPID <- "";
//	map<string, Pumper> pumpers;
//	map<string, tree> trees;
	int deadtrees <- 0;
//	map<string, freshwater> fresh_waters;
//	map<string, enemy> enemies;
//	map<string, enemy_spawner> enemy_spawners;
	bool subside <- false;
	int cntDem <- 0;
	int numberWater <- 0;
	int numberPumper <- 1;
	int numberLake <- 1;
	int numberSluice <- 1;
	float volumePump <- 0.0;
	//has the player finished ? 
	bool started <- false;
	bool finished <- false;
	rgb color;
//	team my_team;
	int remaining_time <- 18000;
	float current_score;
	int rot <- 0;
	int cntTime;

//	aspect default {
//		draw world.shape color: my_team.color;
//	}

}
