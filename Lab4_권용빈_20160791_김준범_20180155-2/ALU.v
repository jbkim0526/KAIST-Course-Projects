

module ALU(
  	input wire [31:0] srcA,
  	input wire [31:0] srcB,
	input wire RSTn,
	input wire [31:0] Inst,

	output wire [31:0] ALUresult,
	output wire zero
 );


	reg [31:0] result;
	reg is_zero;
	
	assign ALUresult = result; 
	assign zero = is_zero;

  	//opcode Constants
  	localparam RRAI_opcode = 7'b0110011; //add,sub,and,or,xor,slt,sltu,sra,srl,sll
  	localparam RIAI_opcode = 7'b0010011; //addi,andi,ori,xori,slti,sltiu,srai,srli,slli
  	localparam LW_opcode = 7'b0000011; // LW
  	localparam SW_opcode = 7'b0100011; //SW
   	localparam JAL_opcode = 7'b1101111;
 	localparam JALR_opcode = 7'b1100111;
  	localparam CBI_opcode = 7'b1100011; // BEQ, BNE,BLT,BGE,BLTU,BGEU


   	always @(*) begin
		
		if(RSTn) begin
			case (Inst[6:0])
				RRAI_opcode : begin	
					case(Inst[14:12])
							3'b000 : begin  //add & sub
									if( Inst[30] == 0 )// add   
										result =  srcA + srcB;   
									else if( Inst[30] == 1) // sub   
										result =  srcA - srcB ;
								end
							3'b001 : result = srcA << srcB[4:0];//SLL
							3'b010 : begin//SLT set on less than
									if( srcA >=0 && srcB[31] == 1) result = 0; 
								else begin
										if(srcA < srcB ) result = 1;
										else result = 0;
								end
							end
							3'b011 : begin //SLTU 
								if( srcA < srcB) result = 1;
									else result = 0;
							end
							3'b100: result = srcA ^ srcB;//XOR
							3'b101 : begin   //SRL & SRA
								if(Inst[30] == 0  ) // SRL   
										result = srcA >> srcB[4:0];
								else if( Inst[30] == 1) // SRA
										result = srcA >>> srcB[4:0];
									end
							3'b110: result = srcA | srcB;//OR
							3'b111: result = srcA & srcB;//AND
					endcase
				end

				RIAI_opcode : begin //srcA : read data srcB: Imm
					case(Inst[14:12])
						3'b000 :result =  srcA + srcB; //addi   
						3'b001 : result = srcA << srcB[4:0]; //SLLi
						3'b010 : begin//SLTi set on less than
							if( srcA >=0 && srcB[31] == 1) result = 0; 
							else begin
								if(srcA < srcB ) result = 1;
								else result = 0;
							end
						end
						3'b011 : begin //SLTUi 
							if( srcA < srcB) result = 1;
							else result = 0;
						end
						3'b100: result = srcA ^ srcB;//XORi
						3'b101 : begin   //SRLi & SRAi
							if(Inst[30] == 0  ) // SRLi   
								result = srcA >> srcB[4:0];
							else if( Inst[30] == 1) // SRAi
								result = srcA >>> srcB[4:0];
						end
						3'b110: result = srcA | srcB;//ORi
						3'b111: result = srcA & srcB;//ANDi
					endcase
				end

				LW_opcode: result = srcA + srcB;

				SW_opcode: result = srcA + srcB;

				JALR_opcode: result = srcA + srcB;

				JAL_opcode : result = srcA + srcB;

				CBI_opcode : begin  // Conditional Branch 
					case(Inst[14:12])
						3'b000 : begin  // BEQ
							if (srcA == srcB) is_zero = 1;
							else is_zero = 0;	
						end
						3'b001 : begin // BNE
							if (srcA != srcB) is_zero = 1;
							else is_zero = 0;
						end 
						3'b100 : begin // BLT
							if ($signed(srcA) < $signed(srcB)) is_zero = 1;
							else is_zero = 0;
						end
						3'b101 : begin // BGE
							if ($signed(srcA) >= $signed(srcB)) is_zero = 1;
							else is_zero = 0;
						end
						3'b110 : begin // BLTU
							if (srcA < srcB) is_zero = 1;
							else is_zero = 0;
						end
						3'b111 : begin // BGEU
							if (srcA >= srcB) is_zero = 1;
							else is_zero = 0;
						end
           			endcase
				end
			endcase
		end
	end
endmodule
