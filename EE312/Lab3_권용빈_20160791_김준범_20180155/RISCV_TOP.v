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

   initial begin
      NUM_INST <= 0;
   end

   // Only allow for NUM_INST
    always @ (negedge CLK) begin
        if (RSTn) NUM_INST <= NUM_INST + 1;
    end

    // TODO: implement
    reg [31:0] pc;
    reg [31:0] daddr;

   // initializing
   initial begin
      I_MEM_ADDR = 0;
      Icsn  = 0;
      Dcsn = 0;
      pc = 0;
      daddr = 0;
   end

   // Variables
    reg [6:0] opcode;
    reg [4:0] funct3;
    reg [4:0] funct7;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [11:0] imm12;
    reg [20:0] imm20;
    reg [31:0] readdata1;
    reg [31:0] readdata2;
    reg [31:0] tempdata;
    reg [11:0] memAdd;
    reg [31:0] memDout;
    reg [3:0] mem_be;

   
   //signals
   reg Icsn;
   reg Dcsn;
   reg halt;
   reg rfwe;
   reg wen; 

   assign  I_MEM_CSN = Icsn;
   assign  D_MEM_CSN = Dcsn;
   assign  RF_WD = tempdata;
   assign  HALT = halt;
   assign  RF_WE = rfwe;
   assign  D_MEM_WEN = wen;
   assign RF_WA1 = rd;
   assign RF_RA1 = rs1;
   assign RF_RA2 = rs2;
   assign  D_MEM_ADDR = memAdd ;
   assign  D_MEM_DOUT = memDout;
   assign D_MEM_BE = mem_be;

   // Constants
   localparam RRAI_opcode = 7'b0110011; //add,sub,and,or,xor,slt,sltu,sra,srl,sll
   localparam RIAI_opcode = 7'b0010011; //addi,andi,ori,xori,slti,sltiu,srai,srli,slli
   localparam lui_opcode = 7'b0110111; //lui
   localparam auipc_opcode = 7'b0010111; //auipc
   localparam LW_opcode = 7'b0000011; // LB, LH, LW,LBU,LHU
   localparam SW_opcode = 7'b0100011; //SB,SH,SW
   localparam JAL_opcode = 7'b1101111;
   localparam JALR_opcode = 7'b1100111;
   localparam CBI_opcode = 7'b1100011; // BEQ, BNE,BLT,BGE,BLTU,BGEU


   always @ (posedge CLK) begin // Instruction adress update
        if(RSTn) begin
            I_MEM_ADDR = pc[11:0]&12'hFFF;
        end
    end

   always @ (negedge CLK) begin // Instruction execution
      if(RSTn) begin
         case( opcode )
         SW_opcode : begin 
            imm12 = {I_MEM_DI[31:25], I_MEM_DI[11:7]};
            case(funct3 )
               3'b000 : begin// SB
                daddr= RF_RD1 + {{20{imm12[11]}},imm12};
                memAdd =  daddr[11:0]&12'hFFF;
                memDout = {{24{RF_RD2[7]}}, RF_RD2[7:0]};
                tempdata = memAdd;
               end
               3'b001 : begin// SH
                daddr= RF_RD1 + {{20{imm12[11]}},imm12};
                memAdd =  daddr[11:0]&12'hFFF;
                memDout = {{16{RF_RD2[15]}}, RF_RD2[15:0]};
                tempdata = memAdd;
               end
               3'b010 : begin // SW     
                daddr = RF_RD1 + $signed(imm12);
                memAdd =  daddr[11:0]&12'hFFF;
                memDout = RF_RD2;
                tempdata = memAdd;
               end   
            endcase
            pc = pc +4;
         end
         
         LW_opcode : begin  
            imm12 = I_MEM_DI[31:20]; 
            case(funct3)
               3'b000 : tempdata = {{24{D_MEM_DI[7]}}, D_MEM_DI[7:0]};// LB
               3'b001 : tempdata = {{16{D_MEM_DI[15]}}, D_MEM_DI[15:0]};// LH
               3'b010 : tempdata = D_MEM_DI; // LW
               3'b011 : tempdata = {{24{1'b0}}, D_MEM_DI[7:0]}; // LBU
               3'b100 : tempdata = {{16{1'b0}}, D_MEM_DI[15:0]};//LHU
            endcase
            pc = pc + 4;
         end

         RRAI_opcode : begin // Register-Register Arth
            case(funct3 )
                3'b000 : begin  //add & sub
                    if( I_MEM_DI[30] == 0 )// add   
                        tempdata =  readdata1 + readdata2;   
                    else if( I_MEM_DI[30] == 1) // sub   
                        tempdata =  readdata1 - readdata2 ;
                end
                3'b001 : tempdata = readdata1 << readdata2[4:0];//SLL
                3'b010 : begin//SLT set on less than
                    if( readdata1>=0 && readdata2[31] == 1) tempdata = 0; 
                    else begin
                        if(readdata1 < readdata2) tempdata = 1;
                        else tempdata = 0;
                    end
                end
                3'b011 : begin //SLTU 
                    if(readdata1 < readdata2) tempdata = 1;
                    else tempdata = 0;
                end
                3'b100: tempdata = readdata1 ^ readdata2;//XOR
                3'b101 : begin   //SRL & SRA
                  if(I_MEM_DI[30] == 0  ) // SRL   
                     tempdata = readdata1 >> readdata2[4:0];
                  else if( I_MEM_DI[30] == 1) // SRA
                     tempdata = readdata1 >>> readdata2[4:0];
                end
                3'b110: tempdata =  readdata2 | readdata1;//OR
                3'b111: tempdata =readdata2 &  readdata1;//AND
            endcase
            pc = pc + 4;
         end

         RIAI_opcode : begin  // Register-Immediate Arth            
            imm12 = I_MEM_DI[31:20]; 
            case(funct3 )
                3'b000 : tempdata = readdata1 + {{20{imm12[11]}}, imm12};//addI    
                3'b001 : tempdata = readdata1 << imm12[4:0];//SLLI
                3'b101 : begin // SRLI SRAI
                    if( I_MEM_DI[30] == 0 )  // SRLI
                        tempdata = readdata1 >> imm12[4:0];
                    else if( I_MEM_DI[30] == 1 )   // SRAI
                        tempdata = readdata1 >>> imm12[4:0];    
                    end
                3'b010 : begin //SLTI
                    if(imm12[11] == 1 && readdata1 >= 0) tempdata = 0;
                    else begin
                        if(readdata1 <  { {20{imm12[11]}}, imm12} ) tempdata = 1;
                        else tempdata = 0;
                    end
                end
                3'b011 : begin //SLTIU
                        if(RF_RD1 <  { {20{imm12[11]}}, imm12} ) tempdata = 1;
                        else tempdata = 0;
                end
                3'b100 : tempdata =  { {20{imm12[11]}}, imm12} ^ readdata1; //XORI
                3'b110 : tempdata =  { {20{imm12[11]}}, imm12} | readdata1; //ORI
                3'b111 : tempdata =  { {20{imm12[11]}}, imm12} &  readdata1; //ANDI
            endcase
            pc  = pc + 4;
         end

        auipc_opcode: begin //auipc
            imm20 = I_MEM_DI[31:12]; 
            tempdata = pc + {imm20, {12{1'b0}}};
            pc = pc + 4;
        end

        lui_opcode : begin  //lui
            imm20 = I_MEM_DI[31:12]; 
            tempdata = {imm20, {12{1'b0}}};
            pc = pc + 4;
        end

         JAL_opcode : begin //jal
            tempdata = pc +4;
            pc = pc + {{11{I_MEM_DI[31]}} ,I_MEM_DI[31], I_MEM_DI[19:12], I_MEM_DI[20], I_MEM_DI[30:21], 1'b0};
         end

         JALR_opcode : begin //jalr
            imm12 = I_MEM_DI[31:20]; 
            tempdata = pc+4;
            pc = RF_RD1 + imm12;
            pc[0] = 1'b0;
         end
         
         CBI_opcode : begin  // Conditional Branch 
            imm12 = {I_MEM_DI[31], I_MEM_DI[7], I_MEM_DI[30:25], I_MEM_DI[11:8], 1'b0}; // offset
            tempdata = 0;
            case(funct3)
                3'b000 : begin  // BEQ
                    if (RF_RD1 == RF_RD2) begin
                        tempdata = 1;
                        pc = pc + {{20{imm12[11]}}, imm12};
                        end
                    else
                        pc = pc + 4;
                end
                3'b001 : begin // BNE
                    if (RF_RD1 != RF_RD2) begin
                        tempdata = 1;
                        pc = pc + {{20{imm12[11]}}, imm12};
                    end
                    else
                        pc = pc + 4;
                end 
                3'b100 : begin // BLT
                    if ($signed(RF_RD1) < $signed(RF_RD2)) begin
                        tempdata = 1;
                        pc = pc + {{20{imm12[11]}}, imm12};
                    end
                    else
                        pc = pc + 4;
                end
                3'b101 : begin // BGE
                    if ($signed(RF_RD1) >= $signed(RF_RD2)) begin
                        tempdata = 1;
                        pc = pc + {{20{imm12[11]}}, imm12};
                        end
                    else
                        pc = pc + 4;
                end
                3'b110 : begin // BLTU
                    if (RF_RD1 < RF_RD2) begin
                        tempdata = 1;
                        pc = pc + {{20{imm12[11]}}, imm12};
                        end
                    else
                        pc = pc + 4;
                end
                
                3'b111 : begin // BGEU
                    if (RF_RD1 >= RF_RD2) begin
                        tempdata = 1;
                        pc = pc + {{20{imm12[11]}}, imm12};
                        end
                    else
                        pc = pc + 4;
                end
            endcase
         end
      endcase
   end
   end

   always @ (*) begin 
      if(RSTn) begin
      //halt condition
        if(I_MEM_DI == 32'h00c00093 || I_MEM_DI == 32'h00008067 ) halt = 1; // 여기서 always문 나가야됨.
        // Control Signals part    
        Icsn  = ~RSTn;
        Dcsn  = ~RSTn;       

        // Instruction Decode Part
        opcode = I_MEM_DI[6:0];
        funct3 = I_MEM_DI[14:12];
        funct7 = I_MEM_DI[31:25];
        rs1 = I_MEM_DI[19:15];
        rs2 = I_MEM_DI[24:20];
        rd = I_MEM_DI[11:7];
        readdata1 = RF_RD1;
        readdata2 = RF_RD2;  

        //Control signal
        wen = 1;
        case (opcode) 
            SW_opcode: begin
                wen = 0;
                rfwe = 0;
                case(funct3)
                    3'b000 : mem_be = 4'b0001;// SB
                    3'b001 : mem_be = 4'b0011;// SH
                    3'b010 : mem_be = 4'b1111;// SW     
                endcase
            end
            LW_opcode : begin  
                    wen = 1;
                    rfwe = 1;
                    imm12 = I_MEM_DI[31:20]; 
                    daddr= RF_RD1 + {{20{imm12[11]}},imm12};
                case(funct3)
                3'b000 : begin// LB
                    mem_be = 4'b0001;
                    memAdd = daddr[11:0]&12'hFFF;
                    end
                3'b001 : begin// LH
                    mem_be = 4'b0011;
                    memAdd =  daddr[11:0]&12'hFFF;
                    end
                3'b010 : begin // LW
                    mem_be = 4'b1111; 
                    memAdd =  daddr[11:0]&12'hFFF;
                end
                3'b011 : begin// LBU
                    mem_be = 4'b0001;
                    memAdd =  daddr[11:0]&12'hFFF;
                end
                3'b100 : begin// LHU
                    mem_be = 4'b0011;
                    memAdd =  daddr[11:0]&12'hFFF;
                end
                endcase
                end
            CBI_opcode: begin
              wen = 1;
              rfwe = 1;
            end
            default: begin
                wen = 1;
                rfwe = 1;
            end
        endcase
    end      
   end
endmodule //

