module CTRL(
  	input wire [6:0] opcode,
	input wire [2:0] funct3,
  	input wire RSTn,
	input wire [2:0] state,

  	output wire RegWrite,
	output wire PCWriteCond,
	output wire ALUSrcA,
	output wire [2:0] ALUSrcB,
	output wire MemRead ,
	output wire MemWrite,
	output wire MemtoReg,
	output wire IRWrite
 );


  	//opcode Constants
  	localparam RRAI_opcode = 7'b0110011; //add,sub,and,or,xor,slt,sltu,sra,srl,sll
  	localparam RIAI_opcode = 7'b0010011; //addi,andi,ori,xori,slti,sltiu,srai,srli,slli
  	localparam LW_opcode = 7'b0000011; // LW
  	localparam SW_opcode = 7'b0100011; //SW
   	localparam JAL_opcode = 7'b1101111;
 	localparam JALR_opcode = 7'b1100111;
  	localparam CBI_opcode = 7'b1100011; // BEQ, BNE,BLT,BGE,BLTU,BGEU

	//state Constants
	localparam IF_state = 0;
	localparam ID_state = 1;
 	localparam EX_state = 2;
	localparam MEM_state = 3;
 	localparam WB_state = 4;

	//initialization 
	initial begin
		regWrite = 0;
		pcWriteCond = 0;
		memRead = 0;
		memWrite = 0;
		memtoReg = 0;
		iRegWrite = 0; 	
   	end
 

	//registers
	reg regWrite;
	reg pcWriteCond;
	reg memRead;
	reg memWrite;
	reg memtoReg;
	reg iRegWrite;
	reg aluSrcA;
	reg [2:0] aluSrcB;

	//assignment
    assign RegWrite = regWrite;
	assign PCWriteCond = pcWriteCond;
	assign MemRead = memRead;
	assign MemWrite = memWrite;
	assign MemtoReg = memtoReg;
	assign IRWrite = iRegWrite;
	assign ALUSrcA = aluSrcA;
	assign ALUSrcB = aluSrcB;


   	always @(*) begin
		if(RSTn) begin
			case(state)
				IF_state : begin
					regWrite = 0;
					memRead = 0;
					memWrite = 0;
					memtoReg = 0;
					aluSrcA = 1; // pc
					aluSrcB = 1; // 4;
					iRegWrite = 1;
					pcWriteCond = 0;
				end
				ID_state : begin
					// regWrite
					regWrite = 0;
					memRead = 1;
					memWrite = 0;
					memtoReg = 0;
					iRegWrite = 0;
					pcWriteCond = 0;

				end

				EX_state : begin			
					regWrite = 0;
					memRead = 0;
					memWrite = 0;
					memtoReg = 0;
					aluSrcA = 0; // reg1;
					aluSrcB = 0; // reg2;
					iRegWrite = 1; 
					pcWriteCond = 0;
					if(opcode == CBI_opcode) pcWriteCond = 1; //need to update pc without ALU

					if(opcode == JAL_opcode || opcode == JALR_opcode) begin
						if(opcode == JAL_opcode) begin
							aluSrcA = 1; // pc
							aluSrcB = 2; // imm20
						end
						else aluSrcB = 3; // imm12 , need to compute left shift by 1
					end

					if(opcode == SW_opcode || opcode == LW_opcode || opcode == RIAI_opcode) aluSrcB = 4; // $signed(imm12)
				end
				MEM_state : begin
					//memRead
					if(opcode == LW_opcode) memRead = 1;
					else memRead = 0;

					//memWrite
					if(opcode == SW_opcode) memWrite = 1;
					else memWrite = 0;

				end

				WB_state : begin
					if(opcode == RRAI_opcode || opcode == RIAI_opcode || opcode == SW_opcode || opcode == CBI_opcode) regWrite = 1;
					else regWrite = 0;
					pcWriteCond = 0;
					memRead = 0;
					memWrite = 0;
					iRegWrite = 0;
					if(opcode == LW_opcode) memtoReg = 1;
					else memtoReg = 0;
				end				
			endcase
		end
	end
endmodule

