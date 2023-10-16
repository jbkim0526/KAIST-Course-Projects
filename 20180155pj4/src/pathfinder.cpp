#include <cstring>
#include <cassert>
#include <iostream>
#include <queue>
#include <cmath>
#include "map.h"

using namespace std;

void print_usage(const char *prog)
{
    cout << "usage: " << prog << " ALGORITHM" << endl;
}

struct PQ_element {
    size_t dist;
    struct map::Crossroad cross;
};

struct cmp{
    bool operator()(PQ_element a, PQ_element b){
        return a.dist > b.dist ; 
    }
};

struct list_element{
    float f; 
    float g;
    float h;
    int cid;
    int parent_cid;
};

struct cmp2{
    bool operator()(list_element a, list_element b){
        return a.f > b.f ; 
    }
};


float getDistance(int a , int b){
	return sqrt(a*a+ b*b);
}

int main(int argc, const char *argv[])
{
    if (argc != 2) {
        print_usage(argv[0]);
        return 1;
    }

    // Load a map.
    struct map::Map m;
    map::load_map(&m);

    // Shortest paths.
    struct map::Path p;

    // Select algorithm.
    if (!strncmp(argv[1], "dijkstra", 9)) {

	// Version 1: Use Dijkstra's algorithm.

	int n_crosses = m.crosses.size();
	int n_roads = m.roads.size();

      	// create nearby roads
      	std::vector<int> nearby_cids[n_crosses];   
      	for(int i = 0 ; i < n_roads; i++){
         	nearby_cids[ m.roads[i].cids[0] ].push_back( m.roads[i].cids[1] );
         	nearby_cids[ m.roads[i].cids[1] ].push_back( m.roads[i].cids[0] );
      	}  

     	// create shortest arrow
      	struct map::Road s_arrow[n_crosses];
      	for(int i = 0 ; i < n_crosses ; i++){	
		s_arrow[i].cids[1] = i;
      	} 

 	for(int i = 0 ; i < m.clients.size() ;i++){  // for each client
        	  
		int src_cid = m.clients[i].src_cid;
        	int dst_cid = m.clients[i].dst_cid;

        	//create priority queue & dist vector
		priority_queue<PQ_element,vector<PQ_element>,cmp> PQ;
		std::vector<int> dist;
		for(int i = 0 ; i < n_crosses ; i++){
			PQ_element p;
        		
			if(i == src_cid){
             			p.dist = 0;   
            			dist.push_back(0);
         		}      
         		else{
            			p.dist = 15000u;
            			dist.push_back(15000u);
         		} 
        		p.cross = m.crosses[i];
         		PQ.push(p);

      		}
      		// create in_cloud array - this array checks if crossroad is in the cloud.
      		int in_cloud[n_crosses] = {0};   


      		// create arrows
      		std::vector<struct map::Road> arrows;

      		// dijkstra
      		PQ_element pq_curr;
      		in_cloud[src_cid] = 1; 
      		s_arrow[src_cid].cids[0] = src_cid;

      		while(!PQ.empty()){
         		pq_curr = PQ.top();
         
         		if(pq_curr.cross.cid == dst_cid){ // found dest. end loop
	    			break; 
  	    			// but we need to free all memory
         		}
	
         		int curr_cid = pq_curr.cross.cid;
        
         		if(pq_curr.dist != dist[curr_cid]){ // this pq_element is old one discard it.
           			PQ.pop();
            			continue;
         		}
            
         		float curr_X = pq_curr.cross.x; 
         		float curr_Y = pq_curr.cross.y;  

         		// for all nearby cid
         		for(int i = 0 ; i < nearby_cids[curr_cid].size(); i++){

	    
            			int nearby_cid = nearby_cids[curr_cid][i];
		
	 	   		if(in_cloud[nearby_cid]) continue;

            			float nearby_X = m.crosses[nearby_cid].x; 
           			float nearby_Y = m.crosses[nearby_cid].y;
 	   			int update_dist = dist[curr_cid] +  getDistance(curr_X - nearby_X, curr_Y - nearby_Y);
           			if( dist[nearby_cid] > update_dist )
           			{
               				dist[nearby_cid] = update_dist;
	       				s_arrow[nearby_cid].cids[0] = curr_cid; 
           			  	// since STL priority queue can't update. we just push the new one - bad effciency
               				PQ_element p;
               				p.dist = update_dist;
               				p.cross = m.crosses[nearby_cid];
               				PQ.push(p);
            			}

         		} 
	 		in_cloud[curr_cid] = 1;   
	
         		PQ.pop();


      		}

      		// find minimum path and fill in path structure 
      		std::vector<size_t> client_path;
      		client_path.push_back(dst_cid);
      		for(int i = dst_cid ; i != src_cid ;){
			client_path.push_back(s_arrow[i].cids[0]);
			i = s_arrow[i].cids[0];
      		}
      		p.paths.push_back(client_path);

	}


   
    } else if (!strncmp(argv[1], "a-star", 7)) {
        // Version 2: Use A* algorithm.

	int n_crosses = m.crosses.size();
	int n_roads = m.roads.size();

	// create nearby roads for given map
	std::vector<int> nearby_cids[n_crosses]; 
	for(int i = 0 ; i < n_roads; i++){
		nearby_cids[ m.roads[i].cids[0] ].push_back( m.roads[i].cids[1] );
		nearby_cids[ m.roads[i].cids[1] ].push_back( m.roads[i].cids[0] );
	} 
	
	for(int i = 0 ; i < m.clients.size() ;i++){
		
		int src_cid = m.clients[i].src_cid;
      		int dst_cid = m.clients[i].dst_cid;


		int in_cloud[n_crosses] = {0}; 

		// create closed lists.
		list_element c_list[n_crosses];

 		priority_queue<list_element,vector<list_element>,cmp2> PQ;
	
		float g_list[n_crosses];

		for(int i = 0 ; i < n_crosses ; i++){
			g_list[i] = 15000u;
		}
		g_list[src_cid] = 0;
		struct list_element src_element;
		src_element.g = 0;
		src_element.f = 0;
		src_element.cid = src_cid;
		src_element.parent_cid = src_cid;

		PQ.push(src_element);

		int dst_X = m.crosses[dst_cid].x; 
		int dst_Y = m.crosses[dst_cid].y; 

		while(1){

			struct list_element pq_curr = PQ.top();
			PQ.pop();

 			int curr_cid = pq_curr.cid;

			if(pq_curr.g != g_list[curr_cid]){	
				continue;
			}

	         	float curr_X = m.crosses[curr_cid].x; 
         		float curr_Y = m.crosses[curr_cid].y;  

			for(int i = 0 ; i < nearby_cids[curr_cid].size(); i++){

			 	int nearby_cid = nearby_cids[curr_cid][i];	
				if(in_cloud[nearby_cid]) continue;

				float nearby_X = m.crosses[nearby_cid].x; 
           			float nearby_Y = m.crosses[nearby_cid].y;

				struct list_element l;
				l.g = pq_curr.g + getDistance(curr_X - nearby_X, curr_Y - nearby_Y);

				if(g_list[nearby_cid] > l.g){

					g_list[nearby_cid] = l.g;
					l.h = getDistance(dst_X - nearby_X, dst_Y - nearby_Y);
					l.f = l.g+l.h;
					l.parent_cid = curr_cid;
					l.cid = nearby_cid;			
					PQ.push(l);
				}
			}
			in_cloud[curr_cid] = 1;
			c_list[curr_cid] = pq_curr;

			if(curr_cid == dst_cid){
				break;
			}
			
		}

		std::vector<size_t> client_path;
     		
      		for(int i = dst_cid ; i != src_cid ;){

			client_path.push_back(c_list[i].cid);
			i = c_list[i].parent_cid;
      		}
		client_path.push_back(src_cid);
      		p.paths.push_back(client_path);


	}





    } else {
        cerr << "ALGORITHM should be either dijkstra or a-star. Given: "
             << argv[1] << "." << endl;
        print_usage(argv[0]);
        return 1;
    }


    // Write results into a file.
    map::store_path(&p);
    return 0;
}
