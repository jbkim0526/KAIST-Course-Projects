module FU(
    //input
    input wire fu,
    input wire [31:0] inst_MEM,
    input wire [31:0] inst_WB,
    input wire [31:0] inst_EX,
    input wire RegWrite_MEM, 
    input wire MemWrite_MEM,
    input wire RegWrite_WB,
    input wire MemWrite_WB,
    input wire nop_MEM,
    
    //ouput
    output wire [1:0] Foward_A, 
    output wire [1:0] Foward_B
);

    localparam RRAI_opcode = 7'b0110011; //add,sub,and,or,xor,slt,sltu,sra,srl,sll
	localparam RIAI_opcode = 7'b0010011; //addi,andi,ori,xori,slti,sltiu,srai,srli,slli
	localparam LW_opcode = 7'b0000011; // LW
	localparam SW_opcode = 7'b0100011; //SW
	localparam JAL_opcode = 7'b1101111;
	localparam JALR_opcode = 7'b1100111;
	localparam CBI_opcode = 7'b1100011; // BEQ, BNE,BLT,BGE,BLTU,BGEU

    reg [1:0] foward_A;
    reg [1:0] foward_B;
    reg [4:0]RegDest_MEM;
    reg [4:0]RegDest_WB;
    assign Foward_A = foward_A;
    assign Foward_B = foward_B;

    always @(fu) begin

//	$display("inside FU");
    //	$display(inst_WB[6:0]);	
       // if (inst_MEM[6:0] == SW_opcode) RegDest_MEM = inst_MEM[24:20];
        //else 
        RegDest_MEM = inst_MEM[11:7];

        //if (inst_WB[6:0] == SW_opcode) RegDest_WB = inst_WB[24:20];
        //else 
        RegDest_WB = inst_WB[11:7];

        if(inst_EX[6:0] == RIAI_opcode || inst_EX[6:0] ==  JALR_opcode || inst_EX[6:0] ==  LW_opcode|| inst_EX[6:0] == SW_opcode )  begin
	//	$display("RIAI");
	//	$display(inst_EX[19:15]);
	//	$display("RegDest_WB : %d",RegDest_WB);
	//	$display("RegDest_MEM : %d",RegDest_MEM);
	//	$display("RegWrite_WB : %d",RegWrite_WB);
	//	$display("nop_MEM : %d", nop_MEM);
            if (RegWrite_MEM == 1 && RegDest_MEM != 0 && inst_EX[19:15] == RegDest_MEM && nop_MEM != 1) foward_A = 1;
		    else if(RegWrite_WB == 1 && RegDest_WB != 0 && inst_EX[19:15] == RegDest_WB) begin 
                foward_A = 2;
			 	//$display("?Foward A : %d",foward_A);
            end
            else foward_A = 0;
            foward_B = 0;
        end
        else if	(inst_EX[6:0] == RRAI_opcode || inst_EX[6:0] == CBI_opcode) begin
            if (RegWrite_MEM == 1 && RegDest_MEM != 0 && inst_EX[19:15] == RegDest_MEM && nop_MEM != 1) foward_A = 1;
            else if (RegWrite_WB == 1 && RegDest_WB != 0 && inst_EX[19:15] == RegDest_WB) foward_A = 2;
            else foward_A = 0;

            if (RegWrite_MEM == 1 && RegDest_MEM != 0 && inst_EX[24:20] == RegDest_MEM && nop_MEM != 1) foward_B = 1;
            else if (RegWrite_WB == 1 && RegDest_WB != 0 && inst_EX[24:20] == RegDest_WB) foward_B = 2;
            else foward_B = 0;
        end
	else begin
		foward_A = 0;
		foward_B = 0 ;
	end
        
    end
endmodule
