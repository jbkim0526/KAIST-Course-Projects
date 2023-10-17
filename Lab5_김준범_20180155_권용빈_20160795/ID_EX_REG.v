module ID_EX_REG (
	input wire ID_EX_update,
	input wire RSTn,
	input wire ID_EX_WE,
	input wire nop_ID,
	input wire is_taken_ID,
	input wire [1:0] flag_A_ID,
	input wire [1:0] flag_B_ID,
	input wire [31:0] fow_data_ID,

	input wire [31:0] RD1_ID,
	input wire [31:0] RD2_ID,
	input wire [4:0] ra1_ID,
	input wire [4:0] ra2_ID,
	input wire [4:0] rs_ID,
	input wire [4:0] rd_ID,
	input wire [31:0] signExtended_ID, 
	input wire [11:0] pc_ID,
	input wire [31:0] inst_ID,
	input wire stall_nop_ID,

	output wire [1:0] flag_A_EX,
	output wire [1:0] flag_B_EX,
	output wire [31:0] fow_data_EX,
	output wire is_taken_EX,
	output wire [11:0] pc_EX,
	output wire [31:0] inst_EX,
	output wire nop_EX,
	output wire [31:0] RD1_EX,
	output wire [31:0] RD2_EX,
	output wire [4:0] ra1_EX, // rs
	output wire [4:0] ra2_EX, // rt	
	output wire [4:0] rs_EX,
	output wire [4:0] rd_EX,
	output wire stall_nop_EX,

	// control signals 
	input wire RegWrite_ID,
	input wire PCWriteCond_ID,
	input wire ALUSrcA_ID,
	input wire [2:0] ALUSrcB_ID,
	input wire MemRead_ID,
	input wire MemWrite_ID,
	input wire MemtoReg_ID,
	input wire IRWrite_ID,

	output wire RegWrite_EX,
	output wire PCWriteCond_EX,
	output wire ALUSrcA_EX,
	output wire [2:0] ALUSrcB_EX,
	output wire MemRead_EX,
	output wire MemWrite_EX,
	output wire Memtoreg_EX,
	output wire IRWrite_EX,
	output wire is_jmp_EX

);
	//Declare the register that will store the data
	reg [1:0]flag_A;
	reg [1:0]flag_B;
	reg [31:0] fow_data;
	reg [31:0] RD1;
	reg [31:0] RD2;
	reg [4:0] ra1;
	reg [4:0] ra2;
	reg [4:0] rs;
	reg [4:0] rd;
	reg nop;
	reg stall_nop;
	reg is_jmp;
	reg RegWrite;
	reg is_taken;
	reg PCWriteCond;
	reg ALUSrcA;
	reg [2:0] ALUSrcB;
	reg MemRead;
	reg MemWrite;
	reg Memtoreg;
	reg IRWrite;
	reg [11:0] pc;
	reg [31:0] inst;

	//Define asynchronous read
	assign fow_data_EX = fow_data;
	assign flag_A_EX = flag_A;
	assign flag_B_EX = flag_B;
	assign is_taken_EX = is_taken; 
	assign is_jmp_EX = is_jmp;
	assign RD1_EX = RD1;
	assign RD2_EX = RD2;
	assign ra1_EX = ra2;
	assign ra2_EX = ra1;
	assign rs_EX = rs;
	assign rd_EX = rd;
	assign nop_EX = nop;
	assign pc_EX = pc;
	assign inst_EX = inst;
	assign RegWrite_EX = RegWrite;
	assign PCWriteCond_EX =PCWriteCond;
	assign ALUSrcA_EX = ALUSrcA;
	assign ALUSrcB_EX = ALUSrcB;
	assign MemRead_EX = MemRead;
	assign MemWrite_EX = MemWrite;
	assign stall_nop_EX = stall_nop;
	assign Memtoreg_EX = Memtoreg;
	assign IRWrite_EX = IRWrite;


	//Define synchronous write
	always @(ID_EX_update)
	begin
		if(ID_EX_WE)
		begin
			is_taken <= is_taken_ID;
			flag_A <= flag_A_ID;
			flag_B <= flag_B_ID;
			fow_data <= fow_data_ID;
			is_jmp <= (inst_ID[6:0]==7'b1101111 || inst_ID[6:0] ==7'b1100111);
			stall_nop <= stall_nop_ID;
			pc <= pc_ID;
			inst <= inst_ID;
			nop <= nop_ID;
			RD1 <= RD1_ID;
			RD2 <= RD2_ID;
			ra1 <= ra1_ID;
			ra2 <= ra2_ID;
			rs <= rs_ID;
			rd <= rd_ID;
			RegWrite <= RegWrite_ID;
			PCWriteCond <= PCWriteCond_ID;
			ALUSrcA <= ALUSrcA_ID;
			ALUSrcB <= ALUSrcB_ID;
			MemRead <= MemRead_ID;
			MemWrite <= MemWrite_ID;
			Memtoreg <= MemtoReg_ID;
			IRWrite <= IRWrite_ID;	

				
    		end

		else
		begin
			flag_A <= flag_A;
			flag_B <= flag_B;
			fow_data <= fow_data;
			is_taken <= is_taken;
			is_jmp <= is_jmp;
			pc <= pc;
			inst <= inst;
			RD1 <= RD1;
			RD2 <= RD2;
			ra1 <= ra1;
			ra2 <= ra2;
			rs <= rs;
			rd <= rd;
			nop <= nop;
			stall_nop <= stall_nop;
			RegWrite <= RegWrite;
			PCWriteCond <= PCWriteCond;
			ALUSrcA <= ALUSrcA;
			ALUSrcB <= ALUSrcB;
			MemRead <= MemRead;
			MemWrite <= MemWrite;
			Memtoreg <= Memtoreg;
			IRWrite <= IRWrite;
		end
	end

endmodule
