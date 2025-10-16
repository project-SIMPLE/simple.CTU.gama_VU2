/**
* Name: websocketsender
* Based on the internal empty template. 
* Author: ltmloan
* Tags: 
*/


model websocketsender

global {
    init {
    	float time_step <- 1; // 1 cycle = 1 giây mô phỏng
        create sender number: 1;
    }
}

species sender skills: [network] {
    init {
        // Kết nối đến server WebSocket
        do connect protocol: "websocket_client" to: "localhost" port: 3001 with_name: "sender" raw: true;
    }
    
    reflex send_data when: (cycle mod 20) = 0 {  
        // Tạo map dữ liệu 
        map data <- ["farmid"::1, "salinity"::12.5, "crop_type"::"rice"];
        
        // Gửi đến server
        string json_string <- to_json(data);
        do send to: "server" contents: json_string;
        
        write "Đã gửi dữ liệu: " + data; 
                
    }
}

experiment my_experiment type: gui {
	//parameter "Step duration (seconds)" var: step <- 0.2; // mỗi cycle 0.2 giây thật (10 bước = 2s)
    output {
        display my_display {
            species sender;
        }
    }
}
