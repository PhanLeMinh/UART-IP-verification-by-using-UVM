`ifndef GUARD_UART_ENV_PKG__SV
`define GUARD_UART_ENV_PKG__SV

package env_pkg;
    import uvm_pkg::*;
    import uart_pkg::*;
    import ahb_pkg::*;

    // Include file
    `include "uart_scoreboard.sv"
    `include "uart_enviroment.sv"
endpackage

`endif
