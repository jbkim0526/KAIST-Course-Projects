module IF_ID_REG (
	input wire IF_ID_update,
	input wire RSTn,
	input wire IF_ID_WE,

	
	input wire [11:0] pc_IF,
	input wire [31:0] inst_IF,
	input wire nop_IF,

	output wire [11:0] pc_ID,
	output wire [31:0] inst_ID,
	output wire nop_ID
	
);
	//Declare the register that will store the data
	reg [11:0] pc;
	reg [31:0] inst;
	reg nop;
	//Define asynchronous read

	assign pc_ID = pc;
	assign inst_ID = inst;
	assign nop_ID = nop;

	//Define synchronous write
	always @(IF_ID_update)
	begin
		if(IF_ID_WE)
		begin

			pc <= pc_IF;
			inst <= inst_IF;
			nop <= nop_IF;
			
    		end

		else
		begin
			pc <= pc;
			inst <= inst;
			nop <= nop;
		end
	end

endmodule

