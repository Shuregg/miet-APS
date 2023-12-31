//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.09.2023 21:24:01
// Design Name: CYBERcobra 3000 Pro 2.1
// Module Name: CYBERcobra
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CYBERcobra(
 input  logic        clk_i
,input  logic        rst_i
,input  logic [15:0] sw_i
,output logic [31:0] out_o
);

  parameter pc_trans_const = 32'd4;
  
  
//Program counter pins
  logic [31:0] PC_in;
  logic [31:0] PC_out;

//Instruction memory out pin
  logic [31:0] instruction;
  
//REGISTER FILE PINS
  logic        RF_WE_in;
  logic [4:0]  RF_RA1_in;
  logic [4:0]  RF_RA2_in;
  logic [4:0]  RF_WA_in;
  logic [31:0] RF_WD_in;
  logic [31:0] RF_RD1_out;
  logic [31:0] RF_RD2_out;
  
//ALU PINS
  logic        ALU_flag_out;
  logic [31:0] ALU_res_out;
  
//Optional wires
  logic        jump;
  logic        branch_and_flag;
  logic [31:0] pc_trans_value;
  logic [31:0] pc_adder_in;
  
  logic        jump_or_branch;
  program_counter program_counter_inst
  (.clk_i(clk_i), 
   .rst_i(rst_i), 
   .pc_i(PC_in) , 
   .pc_o(PC_out)
   );
  
  assign jump       = instruction[31];
  assign branch_and_flag     = instruction[30] & ALU_flag_out;
  
  assign pc_trans_value   = {{22{instruction[12]}}, {instruction[12:5], 2'b00}};
  
  assign jump_or_branch        = jump || branch_and_flag;
  assign out_o                 = RF_RD1_out; //!!!!!!!!!!!!!
  
  //assign pc_adder_in = (jump | branch) ? pc_trans_value : pc_trans_const;
  always_comb begin
    case(jump_or_branch)
      1'b1:
        pc_adder_in <= pc_trans_value;
      1'b0:
        pc_adder_in <= pc_trans_const;
    endcase
  end
  
  //assign PC_in = pc_adder_in;
  fulladder32 PC_adder
  (.a_i(PC_out)     ,
   .b_i(pc_adder_in),
   .carry_i(1'b0)   ,
   .sum_o(PC_in)    ,
   .carry_o()
  );
//  always_comb begin
//    PC_in <= PC_out + pc_adder_in;
//  end
  
  instr_mem instruction_memory_inst
  (.addr_i(PC_out),
   .read_data_o(instruction)
  ); 

  alu_riscv ALU_inst
  (.a_i(RF_RD1_out)             ,
   .b_i(RF_RD2_out)             ,
   .alu_op_i(instruction[27:23]),
   .flag_o(ALU_flag_out)        ,
   .result_o(ALU_res_out)
   );
  
  rf_riscv register_file_inst
  (.clk_i(clk_i)            ,
   .write_enable_i(RF_WE_in),
   .read_addr1_i(RF_RA1_in) ,
   .read_addr2_i(RF_RA2_in) ,
   .write_addr_i(RF_WA_in)  ,
   .write_data_i(RF_WD_in)  ,
   .read_data1_o(RF_RD1_out),
   .read_data2_o(RF_RD2_out)
   );
  
 
  
  assign RF_WE_in  = ~(instruction[30] | instruction[31]);
  assign RF_RA1_in = instruction[22:18];
  assign RF_RA2_in = instruction[17:13];
  assign RF_WA_in  = instruction[4:0];
  
  //RF Write Data MUX 
  always_comb begin
    case(instruction[29:28])
      2'b00: begin
        RF_WD_in  <= {{9{instruction[27]}}, instruction[27:5]} ;
      end
      
      2'b01: begin
        RF_WD_in        <= ALU_res_out; //ALU
      end
      
      2'b10: begin
        RF_WD_in  <= {{16{sw_i[15]}}, sw_i};
      end
      
      2'b11:
        RF_WD_in        <= 32'd0;
    endcase
  end

endmodule
