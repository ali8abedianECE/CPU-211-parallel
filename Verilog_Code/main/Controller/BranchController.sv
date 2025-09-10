`define State_Branch_Controller_IDLE 3'd0
`define State_Branch_Controller_Taken 3'd1
`define State_Branch_Controller_Flush1 3'd2
`define State_Branch_Controller_Flush2 3'd3
`define State_Branch_Controller_Flush3 3'd4

module BranchController(opcode, op, cond, PC, sximm8, imJump, imJumpFlag, Flush1, Flush2, Flush3, Z, N, V, clk, reset, StallEX, branch_taken, Rd, Rdspecial); 

    input [2:0] opcode, cond; 
    input [1:0] op; 
    input [8:0] PC; 
    input [15:0] sximm8, Rd, Rdspecial; 
    input Z, N, V, clk, reset; 
    wire branchBX; 
    wire SN; 

    output [8:0] imJump;
    assign imJump = branchBX ? Rd[8:0] : SN ? Rdspecial[8:0] : PC + sximm8[8:0] + 9'd1;

    output reg imJumpFlag; 
    output reg Flush1, Flush2, Flush3, StallEX; 

    reg [2:0] State;
    reg SpecialCaseTracker; 

    output branch_taken;

    assign SN = (({opcode, op} == 5'b01010));

    assign branchBX = (({opcode, op} == 5'b01000));


    assign branch_taken = (
        // Unconditional Branch (B)
        ({opcode, op, cond} == 8'b00100000) ||

        // BEQ (Branch if Equal)
        ({opcode, op, cond} == 8'b00100001 && Z == 1'b1) ||

        // BNE (Branch if Not Equal)
        ({opcode, op, cond} == 8'b00100010 && Z == 1'b0) ||

        // BLT (Branch if Less Than)
        ({opcode, op, cond} == 8'b00100011 && N != V) ||

        // BLE (Branch if Less or Equal)
        ({opcode, op, cond} == 8'b00100100 && (N != V || Z == 1'b1)) ||

        //BL (Branch Taken for return)
        ({opcode, op, cond} == 8'b01011111) ||

        ({opcode, op} == 5'b01000) ||

        ({opcode, op} == 5'b01011) || 

        ({opcode, op} == 5'b01010) 
    );


    always_ff @(posedge clk) begin 
        if (reset) begin
            State <= `State_Branch_Controller_IDLE;
            StallEX <= 1'b0; 
        end else if(State == `State_Branch_Controller_IDLE) begin 
            if(branchBX || SN) begin 
                State <= `State_Branch_Controller_Taken;
                StallEX <= 1'b1;
                SpecialCaseTracker <= branchBX;
            end else begin 
            case({opcode, op, cond})
                // 8'b111xxxxx: State_Transitions <= `State_HALTED;
                8'b00100000: begin 
                    State <= `State_Branch_Controller_Taken;
                    StallEX <= 1'b1;
                end
                8'b00100001: begin 
                    if(Z) begin 
                        State <= `State_Branch_Controller_Taken;
                        StallEX <= 1'b1; 
                    end else begin 
                        State <= `State_Branch_Controller_IDLE;
                        StallEX <= 1'b0;
                    end
                end
                8'b00100010: begin 
                    if(Z === 1'b0) begin 
                        State <= `State_Branch_Controller_Taken;
                        StallEX <= 1'b1;
                    end else begin 
                        State <= `State_Branch_Controller_IDLE;
                        StallEX <= 1'b0;
                    end
                end
                8'b00100011: begin 
                    if(N !== V) begin 
                        State <= `State_Branch_Controller_Taken;
                        StallEX <= 1'b1;
                    end else begin 
                        State <= `State_Branch_Controller_IDLE;
                        StallEX <= 1'b0;
                    end
                end
                8'b00100100: begin
                    if(N !== V || Z === 1'b1) begin 
                        State <= `State_Branch_Controller_Taken;
                        StallEX <= 1'b1; 
                    end else begin 
                        State <= `State_Branch_Controller_IDLE;
                        StallEX <= 1'b0;
                    end
                end
                8'b01011111: begin 
                    State <= `State_Branch_Controller_Taken;
                    StallEX <= 1'b1; 
                end
                // 8'b01000xxx: State_Transitions <= `State_Branch_BX;
                // 8'b01010111: State_Transitions <= `State_Branch_BLX_R7;
                default: begin 
                    State <= `State_Branch_Controller_IDLE; 
                    StallEX <= 1'b0;
                end
            endcase
            SpecialCaseTracker <= 1'b0; 
        end end else if(State == `State_Branch_Controller_Taken) begin 
            State <= `State_Branch_Controller_Flush1;
            StallEX <= 1'b1; 
            SpecialCaseTracker <= SpecialCaseTracker;
        end else if(State === `State_Branch_Controller_Flush1) begin 
            State <= `State_Branch_Controller_Flush2;
            StallEX <= 1'b1;
            SpecialCaseTracker <= SpecialCaseTracker;
        end else if(State === `State_Branch_Controller_Flush2) begin 
            State <= `State_Branch_Controller_Flush3;
            StallEX <= 1'b0;
            SpecialCaseTracker <= SpecialCaseTracker;
        end else if(State === `State_Branch_Controller_Flush3) begin 
            State <= `State_Branch_Controller_IDLE;
            StallEX <= 1'b0;
            SpecialCaseTracker <= SpecialCaseTracker;
        end else begin 
            State <= `State_Branch_Controller_IDLE;
            StallEX <= 1'b0; 
            SpecialCaseTracker <= 1'b0;
        end
    end

    always_comb begin 
        case(State) 
            `State_Branch_Controller_IDLE: begin 
                Flush1 = 1'b0; 
                Flush2 = 1'b0; 
                Flush3 = 1'b0; 
                imJumpFlag = 1'b0;  
            end
            `State_Branch_Controller_Taken: begin 
            // When branch is taken, flush IF/ID and update PC
            Flush1 = 1'b1;  // Flush IF 
            Flush2 = 1'b1;  // Flush ID
            Flush3 = 1'b1;  // Flush EX
            imJumpFlag = 1'b1;  // Update PC to branch target
        end
        `State_Branch_Controller_Flush1: begin 
            // First cycle after branch taken
            Flush1 = 1'b0;  // Allow new instruction fetch
            Flush2 = 1'b1;  // Keep ID flushed
            Flush3 = 1'b1;  // Keep EX flushed
            imJumpFlag = 1'b0;  // PC already updated
        end
        `State_Branch_Controller_Flush2: begin 
            // Second cycle after branch taken
            Flush1 = 1'b0;  // Normal fetch
            Flush2 = 1'b1;  // Allow ID
            Flush3 = 1'b1;  // Final flush of EX
            imJumpFlag = 1'b0;
        end
        `State_Branch_Controller_Flush3: begin 
            // Return to normal operation
            Flush1 = 1'b0;
            Flush2 = 1'b0;
            Flush3 = 1'b1;
            imJumpFlag = 1'b0;
        end
        default: begin 
            Flush1 = 1'b0;
            Flush2 = 1'b0;
            Flush3 = 1'b0;
            imJumpFlag = 1'b0;
        end
        endcase
    end

endmodule : BranchController
