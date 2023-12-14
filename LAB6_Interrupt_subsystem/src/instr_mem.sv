module instr_mem(
 input logic  [31:0] addr_i
,output logic [31:0] read_data_o
);
  parameter cells_value = 1024;
  
  logic [31:0]  ROM                 [0:cells_value-1]; //1024 cells * 32 bit
  logic [31:0]  byte_addr;
  logic         address_is_valid;
  
  // initial $readmemh("sqareOfNum.txt", ROM);
  // initial $readmemh("program.txt", ROM);
  // initial $readmemh("irq_program.txt", ROM);
  initial $readmemh("lab_12_sw_led_instr.mem", ROM);
  assign byte_addr = addr_i >> 2; //addr/4
  assign address_is_valid = (addr_i <= 4*cells_value-1); 
  
  always_comb begin
    if(address_is_valid)
      read_data_o = ROM[byte_addr];   //      read_data_o <= {RAM[addr_i+3], RAM[addr_i+2], RAM[addr_i+1], RAM[addr_i+0]}; 
    else
      read_data_o = 32'b0;
  end
endmodule