module CTRL(
  	input wire [6:0] opcode,
  	input wire RSTn,
    input wire CLK,

    output wire RegWrite_ID_EX,
	output wire PCWriteCond_ID_EX,
	output wire ALUSrcA_ID_EX,
	output wire [2:0] ALUSrcB_ID_EX,
	output wire MemRead_ID_EX,
	output wire MemWrite_ID_EX,
	output wire MemtoReg_ID_EX,
	output wire IRWrite_ID_EX
 );

  	//opcode Constants
  	localparam RRAI_opcode = 7'b0110011; //add,sub,and,or,xor,slt,sltu,sra,srl,sll
  	localparam RIAI_opcode = 7'b0010011; //addi,andi,ori,xori,slti,sltiu,srai,srli,slli
  	localparam LW_opcode = 7'b0000011; // LW
  	localparam SW_opcode = 7'b0100011; //SW
   	localparam JAL_opcode = 7'b1101111;
 	localparam JALR_opcode = 7'b1100111;
  	localparam CBI_opcode = 7'b1100011; // BEQ, BNE,BLT,BGE,BLTU,BGEU

	//initialization 
	initial begin
		regWrite_ID_EX= 0;
		pcWriteCond_ID_EX= 0;                                   
		memRead_ID_EX= 0;
		memWrite_ID_EX= 0;
		memtoReg_ID_EX= 0;
		iRegWrite_ID_EX= 0; 	
   	end
 
    // ID_EX registers
	reg regWrite_ID_EX;
	reg pcWriteCond_ID_EX;
	reg memRead_ID_EX;
	reg memWrite_ID_EX;
	reg memtoReg_ID_EX;
	reg iRegWrite_ID_EX;
	reg aluSrcA_ID_EX;
	reg [2:0] aluSrcB_ID_EX;



	//assignment
    assign RegWrite_ID_EX = regWrite_ID_EX;
	assign PCWriteCond_ID_EX = pcWriteCond_ID_EX;
	assign MemRead_ID_EX = memRead_ID_EX;
	assign MemWrite_ID_EX = memWrite_ID_EX;
	assign MemtoReg_ID_EX = memtoReg_ID_EX;
	assign IRWrite_ID_EX = iRegWrite_ID_EX;
	assign ALUSrcA_ID_EX = aluSrcA_ID_EX;
	assign ALUSrcB_ID_EX = aluSrcB_ID_EX;



   	always @(posedge CLK) begin
		if(RSTn) begin
            iRegWrite_ID_EX= 1;

            if(opcode == CBI_opcode) pcWriteCond_ID_EX= 1; //need to update pc without ALU
            else pcWriteCond_ID_EX= 0;

            aluSrcA_ID_EX= 0; // reg 1
            aluSrcB_ID_EX= 0; // reg 2
            if(opcode == JAL_opcode || opcode == JALR_opcode) begin
                aluSrcA_ID_EX= 1; // pc
                aluSrcB_ID_EX= 1; // 4
            end

            if(opcode == LW_opcode || opcode == RIAI_opcode) aluSrcB_ID_EX= 2; // $signed(imm12)

            if(opcode == SW_opcode) aluSrcB_ID_EX = 3; //imm20

            if(opcode == LW_opcode) memRead_ID_EX= 1;
                else memRead_ID_EX= 0;

            if(opcode == SW_opcode) memWrite_ID_EX= 1;
                else memWrite_ID_EX= 0;

            if(opcode == RRAI_opcode || opcode == RIAI_opcode|| opcode == LW_opcode) regWrite_ID_EX= 1; //opcode == SW_opcode || opcode ==CBI_opcode
                else regWrite_ID_EX= 0;

            if(opcode == LW_opcode) memtoReg_ID_EX= 1;
                else memtoReg_ID_EX= 0;

		end
	end

    /*always @(negedge CLK) begin
            regWrite_EX_MEM = regWrite_ID_EX;
            pcWriteCond_EX_MEM = pcWriteCond_ID_EX;
            memRead_EX_MEM = memRead_ID_EX;
            memWrite_EX_MEM = memWrite_ID_EX;
            memtoReg_EX_MEM = memtoReg_ID_EX;

            regWrite_MEM_WB = regWrite_EX_MEM;
            memtoReg_MEM_WB = memtoReg_EX_MEM;
    end*/
endmodule

