/* 
 * Do not change Module name 
*/
module main;
    localparam NUM_OPS = 9;
    localparam DATA_WIDTH = 8;
  reg signed [NUM_OPS-1:0][DATA_WIDTH-1:0] operands;
  wire signed [DATA_WIDTH+$clog2(NUM_OPS)-1:0] sum_value, sum_value2;
  integer idx;
  integer run_number;
  
  reg clk;
  
  initial begin
    clk = 1;
    forever begin
        clk = ~clk;
        #5;
    end
  end
    
  initial 
    begin
      $display("Hello, World");
      for(run_number=0; run_number<5; run_number++) begin
        for (idx=0;idx<NUM_OPS;idx++) begin
            operands[idx] = idx;
        end
        @(posedge clk);
        
      end
      
      #1000;
      $finish;
    end
    
    always @(posedge clk) begin
        $display("%0t Sum result is %d | %d", $time,  sum_value, sum_value2);
    end
    
    ADDER_TREE #(.NUM_OPERANDS(NUM_OPS), .DATA_WIDTH(DATA_WIDTH), .DO_PIPELINE(1)) dut_p (.clk(clk), .operands(operands), .result(sum_value));
    
    ADDER_TREE #(.NUM_OPERANDS(NUM_OPS), .DATA_WIDTH(DATA_WIDTH), .DO_PIPELINE(0)) dut_comb (.clk(clk), .operands(operands), .result(sum_value2));
endmodule


module ADDER_TREE #(parameter NUM_OPERANDS=2, parameter DATA_WIDTH=8, parameter DO_PIPELINE=1) (
        input wire clk,
        input wire [NUM_OPERANDS-1:0][DATA_WIDTH-1:0] operands,
        output wire [DATA_WIDTH+$clog2(NUM_OPERANDS)-1:0] result
);

if (NUM_OPERANDS == 1) begin
        reg [DATA_WIDTH-1:0] operand_reg;
        if (DO_PIPELINE) always @(posedge clk) operand_reg <= operands[0];
        else             always @*             operand_reg <= operands[0];   
        assign result = operand_reg;
end else if (NUM_OPERANDS == 2) begin
        reg [1:0][DATA_WIDTH-1:0] operand_reg;

        if (DO_PIPELINE) always @(posedge clk) begin
            operand_reg[0] <= operands[0];
            operand_reg[1] <= operands[1];
        end else always @* begin
            operand_reg[0] <= operands[0];
            operand_reg[1] <= operands[1];
        end
        
        assign result = operand_reg[0] + operand_reg[1];
        //assign result = operand_reg[0] > operand_reg[1] ? operand_reg[0] : operand_reg[1];
end else begin
        wire [DATA_WIDTH+$clog2(NUM_OPERANDS/2)-1:0] tmp1, tmp2;
        ADDER_TREE #(.NUM_OPERANDS(NUM_OPERANDS/2), .DATA_WIDTH(DATA_WIDTH), .DO_PIPELINE(DO_PIPELINE)) 
            u1(.clk(clk), .operands(operands[NUM_OPERANDS-1:(NUM_OPERANDS+1)/2]), .result(tmp1));
            
        ADDER_TREE #(.NUM_OPERANDS(NUM_OPERANDS-(NUM_OPERANDS/2)), .DATA_WIDTH(DATA_WIDTH), .DO_PIPELINE(DO_PIPELINE)) 
            u2(.clk(clk), .operands(operands[(NUM_OPERANDS+1)/2-1:0]), .result(tmp2));
        
        reg [DATA_WIDTH+$clog2(NUM_OPERANDS/2)-1:0] tmp1_reg, tmp2_reg;
        if (DO_PIPELINE) always @(posedge clk) begin
            tmp1_reg <= tmp1;
            tmp2_reg <= tmp2;
        end else always @* begin
            tmp1_reg <= tmp1;
            tmp2_reg <= tmp2;
        end
        
        assign result = tmp1_reg +tmp2_reg;
        //assign result = tmp1_reg > tmp2_reg ? tmp1_reg : tmp2_reg;
end

endmodule
