`include "vending_machine_def.v"

module vending_machine (

	clk,							// Clock signal
	reset_n,						// Reset signal (active-low)

	i_input_coin,				// coin is inserted.
	i_select_item,				// item is selected.
	i_trigger_return,			// change-return is triggered

	o_available_item,			// Sign of the item availability
	o_output_item,			// Sign of the item withdrawal
	o_return_coin,				// Sign of the coin return
	stopwatch,
	current_total,
	return_temp,
);

	// Ports Declaration
	// Do not modify the module interface
	input clk;
	input reset_n;

	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0] i_select_item;
	input i_trigger_return;

	output reg [`kNumItems-1:0] o_available_item;
	output reg [`kNumItems-1:0] o_output_item;
	output reg [`kNumCoins-1:0] o_return_coin;

	output [3:0] stopwatch;
	output [`kTotalBits-1:0] current_total;
	output [`kTotalBits-1:0] return_temp;
	// Normally, every output is register,
	//   so that it can provide stable value to the outside.

//////////////////////////////////////////////////////////////////////	/

	//we have to return many coins
	reg [`kCoinBits-1:0] returning_coin_0;
	reg [`kCoinBits-1:0] returning_coin_1;
	reg [`kCoinBits-1:0] returning_coin_2;
	reg block_item_0;
	reg block_item_1;
	//check timeout
	reg [3:0] stopwatch;
	//when return triggered
	reg have_to_return;
	reg  [`kTotalBits-1:0] return_temp;
	reg [`kTotalBits-1:0] temp;
////////////////////////////////////////////////////////////////////////

	// Net constant values (prefix kk & CamelCase)
	// Please refer the wikepedia webpate to know the CamelCase practive of writing.
	// http://en.wikipedia.org/wiki/CamelCase
	// Do not modify the values.
	wire [31:0] kkItemPrice [`kNumItems-1:0];	// Price of each item
	wire [31:0] kkCoinValue [`kNumCoins-1:0];	// Value of each coin
	assign kkItemPrice[0] = 400;
	assign kkItemPrice[1] = 500;
	assign kkItemPrice[2] = 1000;
	assign kkItemPrice[3] = 2000;
	assign kkCoinValue[0] = 100;
	assign kkCoinValue[1] = 500;
	assign kkCoinValue[2] = 1000;


	// NOTE: integer will never be used other than special usages.
	// Only used for loop iteration.
	// You may add more integer variables for loop iteration.
	integer i, j, k,l,m,n;

	// Internal states. You may add your own net & reg variables.
	reg [`kTotalBits-1:0] current_total;
	reg [`kItemBits-1:0] num_items [`kNumItems-1:0];
	reg [`kCoinBits-1:0] num_coins [`kNumCoins-1:0];

	// Next internal states. You may add your own net and reg variables.
	reg [`kTotalBits-1:0] current_total_nxt;
	reg [`kItemBits-1:0] num_items_nxt [`kNumItems-1:0];
	reg [`kCoinBits-1:0] num_coins_nxt [`kNumCoins-1:0];

	// Variables. You may add more your own registers.
	reg [`kTotalBits-1:0] input_total, output_total, return_total_0,return_total_1,return_total_2;
	reg index = 0;

	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).
		
		

		if(i_trigger_return == 0 && stopwatch > 0 ) begin
			input_total = 0;

			for(i = 0 ; i < `kNumCoins; i = i+1) 
			begin
				input_total = input_total +  i_input_coin[i]*kkCoinValue[i];
				if(i_input_coin[i] == 1) begin 
					num_coins_nxt[i] = num_coins[i] + 1;
					
				end
			end

			output_total = 0;

			for(j = 0 ; j < `kNumItems ; j = j+1) begin

				
					if(i_select_item[j] == 1) begin
						if(block_item_0 == 1) begin
							block_item_0 = 0;
						end
						else begin
							if(current_total >= kkItemPrice[j] && num_items[j]>0) begin
								output_total = output_total + kkItemPrice[j];
								num_items_nxt[j] = num_items[j] - 1 ;
								block_item_0 = 1;
							
							end
						end
					
					end
				

			end

			current_total_nxt = current_total + input_total - output_total;
			

			if(input_total != 0 || output_total != 0) stopwatch = `kWaitTime;
			
			
			
		end
		else begin
			
			while(current_total >= kkCoinValue[2] && num_coins[2] > 0) begin
				current_total = current_total - kkCoinValue[2];
				num_coins[2] = num_coins[2] - 1;
        			returning_coin_2 = returning_coin_2 + 1;
			end
			
			while(current_total >= kkCoinValue[1] && num_coins[1] > 0) begin
				current_total =  current_total -  kkCoinValue[1];
				num_coins[1] = num_coins[1] - 1;
        			returning_coin_1 = returning_coin_1 + 1;
			end
			
			while(current_total >=  kkCoinValue[0] && num_coins[0] > 0) begin
				current_total =  current_total - kkCoinValue[0];
				num_coins[0] = num_coins[0]- 1;
        			returning_coin_0 =  returning_coin_0 + 1;
			end
			current_total_nxt = current_total;

		end
		



		// Calculate the next current_total state. current_total_nxt =


	end


	// Combinational logic for the outputs
	always @(*) begin
	// TODO: o_available_item
		for(k = 0 ; k < `kNumItems ; k = k +1) begin


			if((current_total >= kkItemPrice[k]) && num_items[k]>0 ) o_available_item[k] = 1;
			else o_available_item[k] = 0;
			
		end
	// TODO: o_output_item

		for(k = 0 ; k < `kNumItems ; k = k +1) begin			
			if (o_available_item[k]==1 && i_select_item[k] ==1)
                 		o_output_item[k] = 1;
            		else
                 		o_output_item[k] = 0;
		end
	end

	// Sequential circuit to reset or update the states
	always @(posedge clk) begin
		if (!reset_n) begin
			// TODO: reset all states.
			returning_coin_0 = 0;
			returning_coin_1 = 0;
			returning_coin_2 = 0;
			block_item_0 = 0;
			block_item_1 = 0;
			have_to_return = 0;
			return_temp = 0;
			current_total = 0;
			current_total_nxt = 0;
			input_total = 0;
			output_total = 0;
			return_total_0 = 0;
			return_total_1 = 0;
			return_total_2 = 0;
			stopwatch = `kWaitTime;
			
			for (i=0;i<`kNumItems;i= i+1) begin
				num_items[i] = 10;
				num_items_nxt[i] = 10;
			end

			for (i=0;i<`kNumCoins;i= i+1) begin
				num_coins_nxt[i] = 5;
				num_coins[i] = 5;
			end





			
		end
		else begin
			// TODO: update all states.

			for(i = 0 ; i < `kNumCoins; i = i+1 ) begin
				num_coins[i] = num_coins_nxt[i];
			end
			for(i = 0 ; i < `kNumItems; i = i+1 ) begin
				num_items[i] = num_items_nxt[i];
			end
			current_total = current_total_nxt;			
			

/////////////////////////////////////////////////////////////////////////

			// decrease stopwatch
			stopwatch = stopwatch - 1 ;
			if(stopwatch == 0 ) o_return_coin = 1;

			//if you have to return some coins then you have to turn on the bit


/////////////////////////////////////////////////////////////////////////
		end		   //update all state end
	end	   //always end

endmodule
