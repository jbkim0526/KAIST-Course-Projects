`include "ALU.v"
`include "CTRL.v"

module RISCV_TOP (
	//General Signals
	input wire CLK,
	input wire RSTn,

	//I-Memory Signals
	output wire I_MEM_CSN,
	input wire [31:0] I_MEM_DI,//input from IM
	output reg [11:0] I_MEM_ADDR,//in byte address

	//D-Memory Signals
	output wire D_MEM_CSN,
	input wire [31:0] D_MEM_DI,
	output wire [31:0] D_MEM_DOUT,
	output wire [11:0] D_MEM_ADDR,//in word address
	output wire D_MEM_WEN,
	output wire [3:0] D_MEM_BE,

	//RegFile Signals
	output wire RF_WE,
	output wire [4:0] RF_RA1,
	output wire [4:0] RF_RA2,
	output wire [4:0] RF_WA1,
	input wire [31:0] RF_RD1,
	input wire [31:0] RF_RD2,
	output wire [31:0] RF_WD,
	output wire HALT,
	output reg [31:0] NUM_INST,
	output wire [31:0] OUTPUT_PORT
	);

	// TODO: implement multi-cycle CPU
	reg hflag;
	reg Icsn;
   	reg Dcsn;
	reg halt;
	reg [11:0] imm;
	reg [11:0] imm12;
	reg [31:0] answer;
	reg [11:0] MemAddr;
	reg [31:0] MemWriteData;
	reg MEM_WEN;
	reg [3:0]  be;


	initial begin
		NUM_INST = 0;
		I_MEM_ADDR = 0;
		Icsn  = 0;
		Dcsn = 0;
		rf_WE = 0;
		be = 4'b1111;
   	end
	
	assign  I_MEM_CSN = Icsn;
  	assign  D_MEM_CSN = Dcsn;
	assign  D_MEM_ADDR = MemAddr;
	assign  D_MEM_DOUT = MemWriteData;
	assign  D_MEM_WEN = MEM_WEN;
	assign  RF_WE = rf_WE;
	assign  RF_RA1 = rf_RA1;
	assign  RF_RA2 = rf_RA2;
	assign  RF_WA1 = rf_WA1;
	assign  RF_WD = rf_WD;
	assign  OUTPUT_PORT = answer ;
	assign  HALT = halt;
	assign  D_MEM_BE = be;


	//RegFile registers
	
	reg rf_WE;
	reg [4:0] rf_RA1;
	reg [4:0] rf_RA2;
	reg [4:0] rf_WA1; 
	reg [31:0] rf_WD;
	
	// ALU Signals
	reg [31:0] srcA;
	reg [31:0] srcB;
	wire [31:0] ALUresult;
	wire ALUzero;

	reg [6:0] opcode;
	reg [2:0] funct3;
	reg [6:0] funct7;

	//State register & consts
	reg [2:0] state = 0;
	reg [31:0] InstReg; 
	reg [31:0] MemDataReg;
	reg [11:0] pc;

	// Control Signals
	wire aluSrcA;
	wire [2:0] aluSrcB;
	wire regdest;
	wire regwrite;
	wire [1:0] pcSrc;
	wire pcWriteCond;
	wire memRead;
	wire memWrite;
	wire memtoReg;
	wire iRegWrite;
	

	//initializing Control Logic - CTR signals update
	CTRL ctrl (
		//input
		.state (state),
		.opcode (opcode),
		.RSTn (RSTn),
		.funct3 (funct3),

		//output
		.ALUSrcA (aluSrcA),
		.ALUSrcB (aluSrcB),
		.RegWrite (regwrite),
		.PCWriteCond (pcWriteCond),
		.MemRead (memRead),
		.MemWrite (memWrite),
		.MemtoReg (memtoReg),
		.IRWrite (iRegWrite)
	);


	//initializing ALU - ALU inputs srcA, srcB
	ALU alu (
		//input
		.srcA(srcA),
		.srcB(srcB),
		.RSTn(RSTn),
		.Inst (InstReg),

		//output
		.ALUresult(ALUresult),
		.zero(ALUzero)
	);

 	localparam IF_state = 0;
	localparam ID_state = 1;
 	localparam EX_state = 2;
	localparam MEM_state = 3;
 	localparam WB_state = 4;
  	localparam RRAI_opcode = 7'b0110011; //add,sub,and,or,xor,slt,sltu,sra,srl,sll
  	localparam RIAI_opcode = 7'b0010011; //addi,andi,ori,xori,slti,sltiu,srai,srli,slli
  	localparam LW_opcode = 7'b0000011; // LW
  	localparam SW_opcode = 7'b0100011; //SW
   	localparam JAL_opcode = 7'b1101111;
 	localparam JALR_opcode = 7'b1100111;
  	localparam CBI_opcode = 7'b1100011; // BEQ, BNE,BLT,BGE,BLTU,BGEU
	
	always @(negedge CLK) begin
		if(RSTn) begin
			if(InstReg == 32'h00c00093 && I_MEM_DI ==  32'h00008067) halt = 1; 

			Icsn  = ~RSTn;
			Dcsn  = ~RSTn;     

			case( state )
				IF_state: begin
					rf_WE = 0;
					if(iRegWrite) InstReg  = I_MEM_DI;
					opcode =  InstReg[6:0];
					funct3 =  InstReg[14:12];
					imm = InstReg[31:20];
					imm12 = { InstReg[31], InstReg[7],  InstReg[30:25],  InstReg[11:8], 1'b0};
					I_MEM_ADDR = I_MEM_ADDR + 4;
					pc = I_MEM_ADDR;
					state = ID_state;	
				end

				ID_state: begin
					rf_RA1 = InstReg[19:15];
					rf_RA2 = InstReg[24:20];

					if(opcode == CBI_opcode) begin 
						srcA = RF_RD1;
						srcB = RF_RD2;
					end	
					state = EX_state;
				end

				EX_state : begin					
						if(pcWriteCond == 1) begin // conditional branch 
							srcA = RF_RD1;
							srcB = RF_RD2;

							if(ALUzero==1) begin // if branch taken
								I_MEM_ADDR = pc-4 + {{20{imm12[11]}}, imm12};
								answer = 1;
								state = IF_state;
							end

							else begin  // if branch not taken
								answer = 0; 
								state = IF_state;
							end
							NUM_INST = NUM_INST + 1;
						end

						else begin
							case (aluSrcA)
								0: srcA = RF_RD1;
								1: srcA = pc-4;
							endcase

							case (aluSrcB)
								0:  begin //RRAI
									srcB = RF_RD2;
									state = WB_state;
								end
								2:  begin //JAL
									srcB = {{11{InstReg[31]}} ,InstReg[31],InstReg[19:12],InstReg[20], InstReg[30:21], 1'b0};
									state = WB_state;
								end
								3: begin // JALR
									srcB = imm;
									state = WB_state;
								end	
								4: begin // LW or SW or  RIAI
									if(opcode == SW_opcode ) srcB =  $signed({InstReg[31:25], InstReg[11:7]});
									else	srcB =  {{20{imm[11]}}, imm};
									
									if(opcode == SW_opcode || opcode == LW_opcode) state = MEM_state;
									else state = WB_state;							
								end
							endcase
						end	
				end

				MEM_state : begin
					if(memRead == 1) begin  // Load
						MEM_WEN = 1;
						MemAddr = ALUresult[11:0]&12'hFFF; 
						state = WB_state;
					end

					if(memWrite == 1) begin // Store
						MEM_WEN = 0;
						MemAddr = ALUresult[11:0]&12'hFFF;
						MemWriteData = RF_RD2;
						NUM_INST =  NUM_INST + 1;
						answer = MemAddr;
						state = IF_state;
					end
				end

				WB_state : begin	
					if(opcode == JAL_opcode || opcode == JALR_opcode) begin
						I_MEM_ADDR = ALUresult[11:0]&12'hFFF; 
						if(opcode == JALR_opcode) I_MEM_ADDR[0] = 0;
						rf_WE = 1;
						rf_WA1 = InstReg[11:7];
						rf_WD = pc;
						answer = pc;
						state = IF_state;
					end				
	
					else begin
						if(memtoReg == 0) begin // RRAI, RIAI, CBI, SW, JAL, JALR
							rf_WE = 1;
							rf_WA1 = InstReg[11:7];
							rf_WD = ALUresult; 
							answer = rf_WD;
							state = IF_state;
						end

						else begin  // LW
							rf_WE = 1;
							rf_WA1 = InstReg[11:7];
							rf_WD = D_MEM_DI;
							answer = D_MEM_DI;
							state = IF_state;			
						end
					end
					NUM_INST =  NUM_INST + 1;	
				end	
			endcase
		end
	end
endmodule 
