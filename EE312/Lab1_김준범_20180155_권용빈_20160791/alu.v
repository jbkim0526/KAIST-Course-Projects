`timescale 1ns / 100ps

module ALU(A,B,OP,C,Cout);

	input [15:0]A;
	input [15:0]B;
	input [3:0]OP;
	output [15:0]C;
	output Cout;

	//TODO
	reg [15:0]X;
	reg Xout;
	reg temp;
	
	always @(A or B or OP) 
	begin
		case(OP)
			4'b0000: begin
				X = A + B;
				if( A[15] == 0 && B[15] == 0 && X[15] == 1 ) Xout = 1;
				else if(  A[15] == 1 && B[15] == 1 && X[15] == 0 ) Xout = 1;
				else Xout =0;
				end
			4'b0001: begin
				X = A - B;
				if( A[15] == 0 && B[15] == 1 && X[15] == 1 ) Xout = 1;
				else if(  A[15] == 1 && B[15] == 0 && X[15] == 0 ) Xout = 1;
				else Xout =0;
				end
			4'b0010: begin
				X = A&B;
				Xout = 0;
				end	
			4'b0011: begin
				X = A|B;
				Xout = 0;
				end
			4'b0100: begin
				X = A~&B;
				Xout = 0;
				end
			4'b0101: begin
				 X = A~|B;
				Xout = 0;
				end
			4'b0110: begin
				X = A^B;
				Xout = 0;
				end
			4'b0111: begin
				X = A~^B;
				Xout = 0;
				end
			4'b1000:
				begin
				X = A;
				Xout = 0;
				end
			4'b1001: 
				begin
				X = ~A;
				Xout = 0;
				end
			4'b1010: 
				begin
				X = A>>1;
				Xout = 0;
				end
			4'b1011: begin
				X = A>>>1;
				if(A[15] == 1) X[15] = 1;
				Xout = 0;
				end
			4'b1100: begin
				temp = A[0];
				X = A>>1;
				X[15] = temp;
				Xout = 0;
				end
			4'b1101: 
				begin
				X = A<<1;
				Xout = 0;
				end
			4'b1110: 
				begin
				X = A<<<1;
				Xout = 0;
				end
			4'b1111: begin
				temp = A[15];
				X = A<<1;
				X[0] = temp;
				Xout = 0;
				end
		endcase
	end
	assign C = X;
	assign Cout = Xout;
	
endmodule
