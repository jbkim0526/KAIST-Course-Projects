module EX_MEM_REG (
	input wire EX_MEM_update,
	input wire RSTn,
	input EX_MEM_WE,
	input wire nop_EX,
	input wire is_jmp_EX,
	input wire is_taken_EX, 
	input wire [31:0] ALU_Result_EX,
	input wire [11:0] MEM_ADDR_EX,
	input wire [4:0]  RegDest_EX,
	input wire [31:0] inst_EX,
	input wire [31:0] RD2_EX,
	// control signal 
	input wire RegWrite_EX,
	input wire PCWriteCond_EX,
	input wire MemRead_EX,
	input wire MemWrite_EX,
   	input wire MemtoReg_EX,
	input wire stall_nop_EX,

	output wire stall_nop_MEM,
	output wire is_taken_MEM,
	output wire [31:0] RD2_MEM,
	output wire [31:0]inst_MEM,
	output wire nop_MEM,
	output wire RegWrite_MEM,
	output wire PCWriteCond_MEM,
	output wire MemRead_MEM,
	output wire MemWrite_MEM,
   	output wire MemtoReg_MEM,
	output wire is_jmp_MEM,
	output wire [31:0] ALU_Result_MEM,
	output wire [11:0] MEM_ADDR_MEM,
	output wire [4:0] RegDest_MEM
);
	//Declare the register that will store the data
	reg [31:0] inst;
	reg [31:0] ALU_result;
	reg [11:0] MEM_addr;
	reg [4:0] RegDest;
	reg nop;
	reg stall_nop;
	reg is_taken;
	reg is_jmp;
    	reg RegWrite;
	reg PCWriteCond;
	reg MemRead;
	reg MemWrite;
	reg Memtoreg;
	reg [31:0] rd2;

	//Define asynchronous read
	assign is_taken_MEM = is_taken;
	assign RD2_MEM = rd2;
	assign inst_MEM = inst;
	assign ALU_Result_MEM = ALU_result;
	assign MEM_ADDR_MEM = MEM_addr;
	assign RegDest_MEM = RegDest;
	assign nop_MEM = nop;
	assign is_jmp_MEM = is_jmp;
	assign RegWrite_MEM = RegWrite;
	assign PCWriteCond_MEM = PCWriteCond;
	assign MemRead_MEM = MemRead;
	assign MemWrite_MEM = MemWrite;
	assign Memtoreg_MEM = Memtoreg;
	assign stall_nop_MEM = stall_nop;
	//Define synchronous write
	always @(EX_MEM_update)
	begin
		if(EX_MEM_WE)
		begin
			is_taken <= is_taken_EX;
			rd2 <= RD2_EX;
			inst <= inst_EX;
        		ALU_result <= ALU_Result_EX;
			MEM_addr <= MEM_ADDR_EX;
			RegDest <= RegDest_EX;
			nop <= nop_EX;
			stall_nop <= stall_nop_EX;
			is_jmp <= is_jmp_EX;
			RegWrite <= RegWrite_EX;
			PCWriteCond <= PCWriteCond_EX;
			MemRead <= MemRead_EX;
			MemWrite <= MemWrite_EX;
			Memtoreg <= MemtoReg_EX;

    		end

		else
		begin
			is_taken <= is_taken;
			rd2 <= rd2;
			inst <= inst;
			ALU_result <= ALU_result;
			MEM_addr <= MEM_addr;
			RegDest <= RegDest;
			nop <= nop;
			stall_nop <= stall_nop;
			is_jmp <= is_jmp;
			RegWrite <= RegWrite;
			PCWriteCond <= PCWriteCond;
			MemRead <= MemRead;
			MemWrite <= MemWrite;
			Memtoreg <= Memtoreg;
		end
	end

endmodule
