`include "FU.v"
`include "IF_ID_REG.v"
`include "ID_EX_REG.v"
`include "EX_MEM_REG.v"
`include "MEM_WB_REG.v"
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
   output wire HALT,                   // if set, terminate program
   output reg [31:0] NUM_INST,         // number of instruction completed
   output wire [31:0] OUTPUT_PORT      // equal RF_WD this port is used for test
   );

   assign OUTPUT_PORT = RF_WD;


   // TODO: implement
   //opcode Constants
   localparam RRAI_opcode = 7'b0110011; //add,sub,and,or,xor,slt,sltu,sra,srl,sll
   localparam RIAI_opcode = 7'b0010011; //addi,andi,ori,xori,slti,sltiu,srai,srli,slli
   localparam LW_opcode = 7'b0000011; // LW
   localparam SW_opcode = 7'b0100011; //SW
   localparam JAL_opcode = 7'b1101111;
   localparam JALR_opcode = 7'b1100111;
   localparam CBI_opcode = 7'b1100011; // BEQ, BNE,BLT,BGE,BLTU,BGEU

   reg IF_ID_we;
   reg ID_EX_we;
   reg EX_MEM_we;
   reg MEM_WB_we;
   reg rf_WE;
   reg mem_wen;
   reg [3:0] be;
   assign RF_WE = rf_WE;
   assign D_MEM_BE = be;
   
   assign D_MEM_WEN = mem_wen;
   // IF_ID_REG
   wire [31:0] inst_IF;
   wire [31:0] inst_ID;
   wire [11:0] pc_IF;
   wire [11:0] pc_ID;
   wire nop_IF;
   wire nop_ID;
   reg nop_IF_r;

   
   reg IF_ID_update_r = 0; 
   reg ID_EX_update_r = 0;
   reg EX_MEM_update_r = 0;
   reg MEM_WB_update_r = 0;

   IF_ID_REG IF_ID_reg(
      .RSTn          (RSTn),
      .IF_ID_update           (IF_ID_update_r),
      .IF_ID_WE      (IF_ID_we),

      .nop_IF         (nop_IF),
      .inst_IF           (inst_IF),
      .pc_IF         (pc_IF),
      
      //output
      .inst_ID      (inst_ID),
      .pc_ID      (pc_ID),
      .nop_ID         (nop_ID)
   );
   

   //ID_EX_REG
   reg [1:0]flag_A_ID;
   reg [1:0]flag_B_ID;

   reg [31:0]fow_data_ID;
   wire [4:0] ra1_ID;
   wire [4:0] ra2_ID;
   wire [4:0] rs_ID;
   wire [4:0] rd_ID;
   wire RegWrite_ID;
   wire PCWriteCond_ID;
   wire ALUSrcA_ID;
   wire [2:0] ALUSrcB_ID;
   wire MemRead_ID;
   wire MemWrite_ID;
   wire MemtoReg_ID;
   wire IRWrite_ID;

   wire [31:0] RD1_EX;
   wire [31:0] RD2_EX;
   wire [4:0] ra1_EX;
   wire [4:0] ra2_EX;
   wire [4:0] rs_EX;
   wire [4:0] rd_EX;

   wire RegWrite_EX;
   wire PCWriteCond_EX;
   wire ALUSrcA_EX;
   wire [2:0] ALUSrcB_EX;
   wire MemRead_EX;
   wire MemWrite_EX;
   wire MemtoReg_EX;
   wire IRWrite_EX;
   wire nop_EX;
   wire [31:0 ]inst_EX;
   wire [11:0] pc_EX;
   wire is_jmp_EX;
      wire [1:0] flag_A_EX;
   wire [1:0] flag_B_EX;
   wire [31:0] fow_data_EX;
wire is_taken_EX;
      CTRL ctrl(
      //input
      .opcode(inst_ID[6:0]),
      .RSTn(RSTn),
      .CLK(CLK),
      //.signal(),

      //ouput
      .RegWrite_ID_EX(RegWrite_ID),
      .PCWriteCond_ID_EX(PCWriteCond_ID),
      .ALUSrcA_ID_EX(ALUSrcA_ID),
      .ALUSrcB_ID_EX(ALUSrcB_ID),
      .MemRead_ID_EX(MemRead_ID),
      .MemWrite_ID_EX(MemWrite_ID),
      .MemtoReg_ID_EX(MemtoReg_ID),
      .IRWrite_ID_EX(IRWrite_ID)   
   );
 reg stall_nop_ID = 0;
 wire stall_nop_EX;
 wire stall_nop_MEM;
 wire stall_nop_WB;

 reg is_taken;  
   ID_EX_REG ID_EX_reg(
      //input
      .RSTn         (RSTn),
      .stall_nop_ID   (stall_nop_ID),
      .ID_EX_update        (ID_EX_update_r),
      .ID_EX_WE      (ID_EX_we),
      .nop_ID         (nop_ID),
      .inst_ID        (inst_ID),
      .pc_ID           (pc_ID),
      .is_taken_ID      (is_taken),
      .RD1_ID         (RF_RD1),
      .RD2_ID         (RF_RD2),
      .ra1_ID         (inst_ID[19:15]), 
      .ra2_ID         (inst_ID[24:20]),
     .rs_ID         (inst_ID[24:20]),      
      .rd_ID         (inst_ID[11:7]),   
           .flag_A_ID       (flag_A_ID),
      .flag_B_ID       (flag_B_ID),
      .fow_data_ID   (fow_data_ID),    

      .RegWrite_ID         (RegWrite_ID),
      .PCWriteCond_ID         (PCWriteCond_ID),
      .ALUSrcA_ID            (ALUSrcA_ID),
      .ALUSrcB_ID            (ALUSrcB_ID),
      .MemRead_ID            (MemRead_ID),
      .MemWrite_ID            (MemWrite_ID),
      .MemtoReg_ID         (MemtoReg_ID),
      .IRWrite_ID            (IRWrite_ID),
      
      //output 
      .stall_nop_EX  (stall_nop_EX),
   .flag_A_EX       (flag_A_EX),
      .flag_B_EX       (flag_B_EX),
      .fow_data_EX   (fow_data_EX),
      .is_taken_EX   (is_taken_EX),
      .is_jmp_EX      (is_jmp_EX),
      .pc_EX         (pc_EX),
      .inst_EX        (inst_EX),
      .RD1_EX         (RD1_EX),
      .RD2_EX         (RD2_EX),
      .ra1_EX         (ra1_EX),
      .ra2_EX         (ra2_EX),
      .rs_EX         (rs_EX),      
      .rd_EX         (rd_EX),
      .nop_EX         (nop_EX),

      .RegWrite_EX      (RegWrite_EX),
      .PCWriteCond_EX      (PCWriteCond_EX),
      .ALUSrcA_EX      (ALUSrcA_EX),
      .ALUSrcB_EX      (ALUSrcB_EX),
      .MemRead_EX      (MemRead_EX),
      .MemWrite_EX      (MemWrite_EX),
      .Memtoreg_EX      (MemtoReg_EX),
      .IRWrite_EX      (IRWrite_EX)
   );

   //EX_MEM_REG
   reg [31:0] ALU_Result_EX;
   wire [31:0] inst_MEM;
   wire [31:0] ALU_Result_MEM;
   wire [11:0] MEM_ADDR_MEM;
   wire [4:0]  RegDest_MEM;
   wire RegWrite_MEM;
   wire PCWriteCond_MEM;
   wire MemRead_MEM;
   wire MemWrite_MEM;
   wire MemtoReg_MEM;
   wire nop_MEM;
   wire is_jmp_MEM;
   wire [31:0]RD2_MEM;

   reg [31:0]srcA;
   reg [31:0]srcB;


wire is_taken_MEM;
   EX_MEM_REG EX_MEM_reg (
      //input   
      .stall_nop_EX   (stall_nop_EX),
      .is_taken_EX      (is_taken_EX),
      .is_jmp_EX         (is_jmp_EX),
      .RSTn            (RSTn),
      .EX_MEM_update    (EX_MEM_update_r),
      .EX_MEM_WE         (EX_MEM_we),
     .nop_EX           (nop_EX),
      .inst_EX         (inst_EX),
     .RD2_EX         (RD2_EX),
      .ALU_Result_EX    (ALU_Result_EX),
      .MEM_ADDR_EX      (ALU_Result_EX[11:0]), //might be wrong
      .RegDest_EX       (rd_EX),  //might be wrong
      .RegWrite_EX      (RegWrite_EX),
      .PCWriteCond_EX   (PCWriteCond_EX),
      .MemRead_EX       (MemRead_EX),
      .MemWrite_EX      (MemWrite_EX),
      .MemtoReg_EX      (MemtoReg_EX),

      
      //output 
      .stall_nop_MEM   (stall_nop_MEM),
      .nop_MEM         (nop_MEM),
      .inst_MEM         (inst_MEM),
      .is_jmp_MEM        (is_jmp_MEM),
      .ALU_Result_MEM      (ALU_Result_MEM),
      .MEM_ADDR_MEM      (MEM_ADDR_MEM),
      .RegDest_MEM      (RegDest_MEM),
      .RD2_MEM         (RD2_MEM),
      .is_taken_MEM     (is_taken_MEM),

      .RegWrite_MEM      (RegWrite_MEM),
      .PCWriteCond_MEM   (PCWriteCond_MEM),
      .MemRead_MEM      (MemRead_MEM),
      .MemWrite_MEM      (MemWrite_MEM),
      .MemtoReg_MEM      (MemtoReg_MEM)
   );


   //MEM_WB_REG

   wire [31:0] Mem_RD_MEM;
   wire [11:0] Mem_Addr_MEM;
   wire is_taken_WB;
   wire [31:0] Mem_RD_WB;
   wire [31:0] ALU_Result_WB;
   wire [4:0] RegDest_WB;
   wire RegWrite_WB;
   wire MemtoReg_WB;
   wire nop_WB;
   wire [31:0] inst_WB;
   wire is_jmp_WB;
   MEM_WB_REG MEM_WB_reg (

      //input
      .stall_nop_MEM   (stall_nop_MEM),
      .is_jmp_MEM      (is_jmp_MEM),
      .RSTn         (RSTn),
      .MEM_WB_update         (MEM_WB_update_r),
      .MEM_WB_WE      (MEM_WB_we),
      .nop_MEM      (nop_MEM),
      .inst_MEM      (inst_MEM),
   .is_taken_MEM     (is_taken_MEM),
      .Mem_RD_MEM         (Mem_RD_MEM),
      .ALU_Result_MEM      (ALU_Result_MEM), //?�좎???�븿
      .RegDest_MEM      (RegDest_MEM),
      .RegWrite_MEM      (RegWrite_MEM),
      .MemtoReg_MEM      (MemtoReg_MEM),

      //output 
      .stall_nop_WB   (stall_nop_WB),
      .is_jmp_WB      (is_jmp_WB),
      .inst_WB      (inst_WB),
      .is_taken_WB     (is_taken_WB),
      .nop_WB         (nop_WB),
      .Mem_RD_WB         (Mem_RD_WB),
      .ALU_Result_WB      (ALU_Result_WB),
       .RegDest_WB         (RegDest_WB),
      .RegWrite_WB      (RegWrite_WB),
      .MemtoReg_WB      (MemtoReg_WB)
   );
   
         //ouput
   wire [1:0] foward_A; 
   wire [1:0] foward_B;
  reg fu = 0;

FU forwarding_unit (
      //input
      .fu      (fu),
       .nop_MEM          (stall_nop_MEM),
      .inst_MEM         (inst_MEM),
      .inst_EX          (inst_EX),
      .inst_WB          (inst_WB),
      .RegWrite_MEM       (RegWrite_MEM),
      .RegWrite_WB      (RegWrite_WB),
      //ouput
      .Foward_A      (foward_A),
      .Foward_B      (foward_B)
   );

   //input 


   reg Icsn;
   reg Dcsn;
   reg halt;
  

   assign I_MEM_CSN = Icsn;
   assign D_MEM_CSN = Dcsn;
   assign HALT = halt;

   initial begin
      Icsn = 0;
      Dcsn = 0;
      halt = 0;
      I_MEM_ADDR = -4;
      nop_IF_r = 0;
      IF_ID_we = 0;
      ID_EX_we = 0;
      EX_MEM_we = 0;
      MEM_WB_we = 0;
      NUM_INST = 0;
      rf_WE = 0;
      be = 4'b1111;
      stall_nop_ID = 0;
   end

   assign inst_IF = I_MEM_DI;
   assign pc_IF = I_MEM_ADDR;
   assign nop_IF = nop_IF_r;


   always @(f) begin
      if(RSTn) begin

         I_MEM_ADDR = I_MEM_ADDR + 4;
    rf_WE = 0;

      end
   end

  // Test stage
  reg a = 0;
  reg b = 0;
  reg c = 0;
  reg d = 0;
  reg e = 0;
  reg f = 0;

  always @(posedge CLK) begin
   if(RSTn) begin

     e <= ~e;  // WB
     d <= ~d;  // MEM  
    
       fu <= ~fu;     
     c <= ~c;  // EX
     b <= ~b;  // ID
     a <= ~a;  // IF
     
   end
  end

  always @(negedge CLK) begin
   if(RSTn) begin
     MEM_WB_update_r = ~MEM_WB_update_r;
           EX_MEM_update_r = ~EX_MEM_update_r ;
        ID_EX_update_r = ~ID_EX_update_r;
     IF_ID_update_r = ~IF_ID_update_r;
     
      f = ~f;
    
   end
  end





   // IF Stage
   always @(a) begin
      if(RSTn) begin

         Icsn  = ~RSTn;   
         IF_ID_we = 1;
    nop_IF_r = 0;
       if(inst_ID == 32'h00008067 && inst_EX == 32'h00c00093 ) halt = 1; //need to change
      end

   end

   assign RF_RA1 = inst_ID[19:15];
   assign RF_RA2 = inst_ID[24:20];   

   // ID Stage
   reg [11:0] imm12;
reg is_stall;
   always @(b) begin




      if(RSTn  && !nop_ID) begin



         if(inst_ID[19:15] == RegDest_WB) begin
            if(inst_WB[6:0] == LW_opcode && inst_ID[6:0] != JAL_opcode ) begin
               fow_data_ID = Mem_RD_WB; 
               flag_A_ID  = 1;
            end
            else if ((inst_WB[6:0] == RRAI_opcode || inst_WB[6:0] == RIAI_opcode) && inst_ID[6:0] != JAL_opcode) begin
              fow_data_ID = ALU_Result_WB;
              flag_A_ID = 1;
            end
         end
         else flag_A_ID = 0;

         if(inst_ID[24:20] == RegDest_WB) begin
            if(inst_WB[6:0] == LW_opcode && inst_ID[6:0] == RRAI_opcode && inst_ID[6:0] == SW_opcode && inst_ID[6:0] == CBI_opcode) begin
               fow_data_ID = Mem_RD_WB; 
               flag_B_ID  = 1;
            end
            else if ((inst_WB[6:0] == RRAI_opcode || inst_WB[6:0] == RIAI_opcode)&& inst_ID[6:0] == RRAI_opcode) begin
              fow_data_ID = ALU_Result_WB;
              flag_B_ID = 1;
            end
         end
         else flag_B_ID = 0;



         Icsn  = ~RSTn;   
         ID_EX_we = 1;
          stall_nop_ID = 0;


//	  $display("RF_RD1 %d",RF_RD1);
//	  $display("RF_RD2 %d",RF_RD2);
         if(inst_ID[6:0] == CBI_opcode) begin
            imm12 = { inst_ID[31], inst_ID[7],  inst_ID[30:25],  inst_ID[11:8], 1'b0};
            case(inst_ID[14:12])
               3'b000 : begin  // BEQ
                  if (RF_RD1 == RF_RD2) begin
                     is_taken = 1;
                  end
                  else is_taken = 0;
               end
               3'b001 : begin // BNE
                  if (RF_RD1 != RF_RD2) begin
                     is_taken = 1;
                  end
                  else is_taken = 0;
               end 
               3'b100 : begin // BLT
                  if ($signed(RF_RD2) < $signed(RF_RD1)) begin
                     is_taken = 1;
                  end
                  else is_taken = 0;
               end
               3'b101 : begin // BGE

		  if(inst_EX[11:7] == inst_ID[19:15]) begin
			if( $signed(ALU_Result_EX) >= $signed(RF_RD1))is_taken = 1;
	  		else is_taken = 0;
		end

		  else if(inst_EX[11:7] == inst_ID[24:20]) begin
			if( $signed(RF_RD2) >=ALU_Result_EX )	is_taken = 1;
	  		else is_taken = 0;
		end
		else begin	  
                  if ($signed(RF_RD2) >= $signed(RF_RD1)) begin
                     is_taken = 1;
                  end
                  else is_taken = 0;
		  end
               end
               3'b110 : begin // BLTU
                  if (RF_RD2 < RF_RD1) begin
                        is_taken = 1;
                  end
                  else is_taken = 0;
               end
               3'b111 : begin // BGEU
                  if (RF_RD2 >= RF_RD1) begin
                        is_taken = 1;
                     end
                  else is_taken = 0;
               end
            endcase
            if(is_taken == 1) begin

               I_MEM_ADDR =  I_MEM_ADDR + {{20{imm12[11]}}, imm12}-4;
               //nop_IF_r = 1; 
            end 
	   else begin
	       nop_IF_r = 1;
	   end
		  
         end
         if(inst_ID[6:0] == JAL_opcode) begin

            I_MEM_ADDR = I_MEM_ADDR + {{11{inst_ID[31]}} ,inst_ID[31],inst_ID[19:12],inst_ID[20], inst_ID[30:21], 1'b0} -4 ;
            nop_IF_r = 1;
         end

         if(inst_ID[6:0] == JALR_opcode) begin
            I_MEM_ADDR = I_MEM_ADDR + inst_ID[31:20]-4;
            nop_IF_r = 1;
         end


	 
          if (MemRead_EX == 1) begin
                     if(inst_ID[6:0] == RIAI_opcode || inst_ID[6:0] == JALR_opcode || inst_ID[6:0] == LW_opcode) begin
			    
                           if (inst_ID[19:15] == rd_EX) is_stall = 1;
                         else is_stall = 0;  
                     end
                   else if (inst_ID[6:0] == RRAI_opcode || inst_ID[6:0] == SW_opcode|| inst_ID[6:0] == CBI_opcode)begin
                if(inst_ID[19:15] == rd_EX || inst_ID[24:20] == rd_EX) begin
                   is_stall = 1;
                end
                         else is_stall = 0;
                     end
                     else is_stall = 1;
                 end
                 else is_stall = 0;
              
         if(is_stall) begin

            stall_nop_ID = 1;
            I_MEM_ADDR = I_MEM_ADDR - 4;
            IF_ID_we = 0;

         end
         
      end
      else begin

      end
   end

   reg [31:0] foward_data_mem;
   reg [31:0] foward_data_wb;

   // EX Stage
   always @(c) begin
      if(RSTn && !nop_EX && !stall_nop_EX) begin



         Icsn  = ~RSTn;     
         EX_MEM_we = 1;

       //  $display("foward A: %d",foward_A);
       //  $display("foward B: %d",foward_B);

      //   $display("rs1 %d",inst_EX[19:15]);
      //   $display("rd %d",inst_EX[11:7]);
      //   $display("imm %b",{{20{ inst_EX[31]}},inst_EX[31:20]});
      //   $display("Reg read data : %d",RD1_EX);
         if (foward_A == 1) srcA = foward_data_mem;
         else if (foward_A == 2) srcA = foward_data_wb;
         else if (flag_A_EX == 1) begin 
            if (inst_EX[6:0] != JAL_opcode && inst_EX[6:0] != JALR_opcode) srcA = fow_data_EX;
         end
         else begin
            case (ALUSrcA_EX)
               0: srcA = RD1_EX;
               1: srcA = pc_EX; //pc input& ouput need in ID/EXE Module
            endcase
            
         end

	 if (foward_B == 1) begin 
		 srcB = foward_data_mem;

	 end
	 else if (foward_B == 2) begin 
		 srcB = foward_data_wb;

	 end
         else if (flag_B_EX == 1) begin 

            if (inst_EX[6:0] == RRAI_opcode) srcB = fow_data_EX;
         end
         else begin
            case (ALUSrcB_EX)
               0:  begin //RRAI 
                  srcB = RD2_EX;
               end
               1:  begin //JAL or JALR
                  srcB = 4;
               end
               2: begin // LW or  RIAI
                  srcB = {{20{ inst_EX[31]}},inst_EX[31:20]};
                  
               end
               3: begin // SW

                  srcB = {{20{inst_EX[31]}},inst_EX[31:25], inst_EX[11:7]};
               end
            endcase
            //$display("scB %d",srcB);
         end
//	  $display("scB %d",srcB);

      //   $display("foward mem : %d",foward_data_mem);
      //   $display("foward wb : %d",foward_data_wb);


         case (inst_EX[6:0])
            RRAI_opcode : begin   
               case(inst_EX[14:12])
                     3'b000 : begin  //add & sub
                           if( inst_EX[30] == 0 )// add   
                              ALU_Result_EX =  srcA + srcB;   
                           else if( inst_EX[30] == 1) // sub   
                              ALU_Result_EX =  srcA - srcB ;
                        end
                     3'b001 : ALU_Result_EX = srcA << srcB[4:0];//SLL
                     3'b010 : begin//SLT set on less than
                           if( srcA >=0 && srcB[31] == 1) ALU_Result_EX = 0; 
                        else begin
                              if(srcA < srcB ) ALU_Result_EX = 1;
                              else ALU_Result_EX = 0;
                        end
                     end
                     3'b011 : begin //SLTU 
                        if( srcA < srcB) ALU_Result_EX = 1;
                           else ALU_Result_EX = 0;
                     end
                     3'b100: ALU_Result_EX = srcA ^ srcB;//XOR
                     3'b101 : begin   //SRL & SRA
                        if(inst_EX[30] == 0  ) // SRL   
                              ALU_Result_EX = srcA >> srcB[4:0];
                        else if( inst_EX[30] == 1) // SRA
                              ALU_Result_EX = srcA >>> srcB[4:0];
                           end
                     3'b110: ALU_Result_EX = srcA | srcB;//OR
                     3'b111: ALU_Result_EX = srcA & srcB;//AND
               endcase
            end

            RIAI_opcode : begin //srcA : read data srcB: Imm
               case(inst_EX[14:12])
                  3'b000 :ALU_Result_EX =  srcA + srcB; //addi   
                  3'b001 : ALU_Result_EX = srcA << srcB[4:0]; //SLLi
                  3'b010 : begin//SLTi set on less than
                     if( srcA >=0 && srcB[31] == 1) ALU_Result_EX = 0; 
                     else begin
                        if(srcA < srcB ) ALU_Result_EX = 1;
                        else ALU_Result_EX = 0;
                     end
                  end
                  3'b011 : begin //SLTUi 
                     if( srcA < srcB) ALU_Result_EX = 1;
                     else ALU_Result_EX = 0;
                  end
                  3'b100: ALU_Result_EX = srcA ^ srcB;//XORi
                  3'b101 : begin   //SRLi & SRAi
                     if(inst_EX[30] == 0  ) // SRLi   
                        ALU_Result_EX = srcA >> srcB[4:0];
                     else if( inst_EX[30] == 1) // SRAi
                        ALU_Result_EX = srcA >>> srcB[4:0];
                  end
                  3'b110: ALU_Result_EX = srcA | srcB;//ORi
                  3'b111: ALU_Result_EX = srcA & srcB;//ANDi
               endcase
            end

            LW_opcode: ALU_Result_EX = srcA + srcB;

            SW_opcode: ALU_Result_EX = srcA + srcB;

            JALR_opcode: ALU_Result_EX = srcA + srcB;

            JAL_opcode : ALU_Result_EX = srcA + srcB;
      endcase


         
      end
      else begin

      end
   end

  
 
   reg [31:0] d_mem_dout;
   reg [31:0] tempdata;

   assign D_MEM_DOUT = d_mem_dout;
   assign D_MEM_ADDR = MEM_ADDR_MEM;
   assign RF_WD = tempdata;
   reg [31:0]foward_data;


   //assign RF_WA1 = RegDest_MEM; //might be wrong
 // MEM Stage
   always @(d) begin
      if(RSTn  && !nop_MEM && !stall_nop_MEM) begin
         foward_data_mem = ALU_Result_MEM;
         MEM_WB_we = 1;
         if (MemRead_MEM) begin
     //  $display("----LOAD");
         mem_wen = 1 ;       
          //LOAD
     //  $display(MEM_ADDR_MEM);
         end
         if (MemWrite_MEM) begin
           	mem_wen = 0 ;
     //  $display("----STORE");
             // STORE
	   
	  //  $display("MEM_ADDR_MEM ",MEM_ADDR_MEM);
	//    $display("d_mem_dout",RD2_MEM);
	    if(RegDest_WB == inst_MEM[24:20]) begin
			d_mem_dout = ALU_Result_WB;
	    end
		    
		    else begin
			    d_mem_dout = RD2_MEM;
			end
         end
    //$display("regWrite MEM : %d", RegWrite_MEM);
      end

            else begin
      end

   end

   // WB Stage

   assign RF_WA1 = RegDest_WB; //might be wrong
   assign Mem_RD_MEM = D_MEM_DI;

   always @(e) begin
      if(RSTn && !nop_WB && !stall_nop_WB) begin
         Icsn  = ~RSTn;
         Dcsn  = ~RSTn;     
    //$display("WE : %d",rf_WE);
          
         if (inst_WB[6:0] == LW_opcode) begin
            rf_WE = 1;
            foward_data_wb = Mem_RD_WB; //maybe wrong(update & read)
            tempdata = Mem_RD_WB;    
             //$display("?NUM_INST increase?");
         end
         else if (RegWrite_WB || is_jmp_WB) begin
            rf_WE = 1;
            foward_data_wb = ALU_Result_WB; //maybe wrong(update & read)
            tempdata = ALU_Result_WB;    
       
            //need to correct this part
         end
         else if (inst_WB[6:0] == CBI_opcode) begin
            if (is_taken_WB) tempdata = 1;
            else tempdata = 0;
         end
    else if(inst_WB[6:0] == SW_opcode) tempdata = ALU_Result_WB;
         NUM_INST = NUM_INST + 1;
         //rf_WE = 0;
      end

            else begin
      end


   end





endmodule //
