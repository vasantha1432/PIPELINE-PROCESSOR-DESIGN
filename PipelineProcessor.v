module PipelineProcessor (input clk, reset, output reg [7:0] WB_result);
    
    reg [7:0] PC; 
    reg [7:0] InstructionMemory [0:15]; 
    reg [7:0] RegisterFile [0:3]; 
    reg [7:0] DataMemory [0:15]; 
    
    reg [7:0] IF_ID_instr;
    reg [7:0] ID_EX_op1, ID_EX_op2;
    reg [1:0] ID_EX_rd;
    reg [7:0] EX_MEM_result;
    reg [1:0] EX_MEM_rd;
    reg [7:0] MEM_WB_result;
    reg [1:0] MEM_WB_rd;
    reg [7:0] WB_final_result;
    
    initial begin
      
        InstructionMemory[0] = 8'b00000001; 
        InstructionMemory[1] = 8'b00000010;
        InstructionMemory[2] = 8'b00000011;
        
        
        RegisterFile[1] = 6;
        RegisterFile[2] = 4;
        DataMemory[0] = 7;
    end
    
    
    always @(posedge clk or posedge reset) begin
        if (reset) PC <= 0;
        else begin
            IF_ID_instr <= InstructionMemory[PC];
            PC <= PC + 1;
        end
    end
    
    
    always @(posedge clk) begin
        case (IF_ID_instr)
            8'b00000001: begin // ADD
                ID_EX_op1 <= RegisterFile[1];
                ID_EX_op2 <= RegisterFile[2];
                ID_EX_rd <= 2'b01;
            end
            8'b00000010: begin // SUB 
                if (MEM_WB_rd == 2'b01) 
                    ID_EX_op1 <= MEM_WB_result;
                else 
                    ID_EX_op1 <= RegisterFile[1];
                ID_EX_op2 <= RegisterFile[2];
                ID_EX_rd <= 2'b01;
            end
            8'b00000011: begin // LOAD
                ID_EX_op1 <= DataMemory[0];
                ID_EX_rd <= 2'b01;
            end
        endcase
    end
    
    // Execution (EX) Stage
    always @(posedge clk) begin
        case (IF_ID_instr)
            8'b00000001: EX_MEM_result <= ID_EX_op1 + ID_EX_op2; 
            8'b00000010: EX_MEM_result <= ID_EX_op1 - ID_EX_op2; 
            8'b00000011: EX_MEM_result <= ID_EX_op1; // LOAD (7)
        endcase
        EX_MEM_rd <= ID_EX_rd;
    end
    
    // Memory (MEM) Stage
    always @(posedge clk) begin
        MEM_WB_result <= EX_MEM_result;
        MEM_WB_rd <= EX_MEM_rd;
    end
    
    // Write Back (WB) Stage
    always @(posedge clk) begin
        RegisterFile[MEM_WB_rd] <= MEM_WB_result;
        WB_final_result <= MEM_WB_result; // Store final WB result
        WB_result <= WB_final_result;
    end
    
endmodule

// Testbench
module Testbench;
    reg clk, reset;
    wire [7:0] WB_result;
    PipelineProcessor uut (clk, reset, WB_result);
    
    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;
        
        repeat (20) #5 clk = ~clk; // Generate clock
        
        #200 $finish;
    end
    
    initial begin
        $monitor("Time=%0t | WB_result=%d", $time, WB_result);
    end
endmodule


