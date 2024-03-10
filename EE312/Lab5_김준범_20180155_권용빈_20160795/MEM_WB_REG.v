module MEM_WB_REG (
	input wire MEM_WB_update,
	input wire RSTn,
	input wire MEM_WB_WE,
	input wire nop_MEM,
	input wire is_jmp_MEM,
	input wire is_taken_MEM,
	input wire stall_nop_MEM,

	input wire [31:0] inst_MEM,
	input wire [31:0] Mem_RD_MEM,
	input wire [31:0] ALU_Result_MEM,
	input wire [4:0] RegDest_MEM,
	input wire MemtoReg_MEM,
    input wire RegWrite_MEM,

    	output wire stall_nop_WB,
	output wire is_taken_WB,
	output wire [31:0]inst_WB,
	output wire is_jmp_WB,
	output wire nop_WB,
	output wire [31:0] Mem_RD_WB,
	output wire [31:0] ALU_Result_WB,
	output wire [4:0] RegDest_WB,
	output wire MemtoReg_WB,
    output wire RegWrite_WB

);
	//Declare the register that will store the data
	reg is_taken;
	reg [31:0] inst;
	reg [31:0] Mem_RD;
	reg [11:0] ALU_Result;
	reg [4:0] RegDest;
	reg nop;
	reg stall_nop;
	reg is_jmp;
	reg MemtoReg;
    	reg RegWrite;

	//Define asynchronous read
	assign inst_WB = inst;
	assign stall_nop_WB = stall_nop;
	assign is_taken_WB = is_taken;
	assign is_jmp_WB = is_jmp;
	assign Mem_RD_WB = Mem_RD; 
	assign ALU_Result_WB = ALU_Result;
	assign RegDest_WB = RegDest;	
	assign RegWrite_WB = RegWrite;
	assign Memtoreg_WB = MemtoReg;
	assign nop_WB = nop;
	//Define synchronous write
	always @(MEM_WB_update)
	begin
		if(MEM_WB_WE)
		begin

			is_taken <= is_taken_MEM;
			inst <= inst_MEM;
			is_jmp <= is_jmp_MEM;
			nop <= nop_MEM;
			stall_nop <= stall_nop_MEM;
			Mem_RD <= Mem_RD_MEM;
			ALU_Result <= ALU_Result_MEM;
			RegDest <= RegDest_MEM;
			RegWrite <= RegWrite_MEM;
			MemtoReg <= MemtoReg_MEM;
    		end

		else
		begin
			is_taken <= is_taken;
			inst <= inst;
			is_jmp <= is_jmp;
			nop <= nop;
			stall_nop <= stall_nop;
			Mem_RD <= Mem_RD;
			ALU_Result <= ALU_Result;
			RegDest <= RegDest;
			RegWrite <= RegWrite;
			MemtoReg <= MemtoReg;
		end
	end

endmodule
