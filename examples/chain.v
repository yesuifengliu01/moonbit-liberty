module chain(input clk, input a, output y);
wire n0, n1;
sky130_fd_sc_hd__inv_1 b0 (.A(a), .Y(n0));
sky130_fd_sc_hd__inv_1 b1 (.A(n0), .Y(n1));
sky130_fd_sc_hd__inv_1 b2 (.A(n1), .Y(y));
endmodule
