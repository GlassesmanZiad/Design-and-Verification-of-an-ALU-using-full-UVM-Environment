/*************************************************************
 * User defined package
 
 * created by: Ziad Ahmed Mamdouh
 * Si_Vision Academey 2025
 *
 * Package Name: MyPackage
 *
 * Description:
 * This package contains a collection of SystemVerilog classes
 * and UVM components related to the testing of an Arithmetic
 * Logic Unit (ALU). The package includes sequences, tests,
 * monitors, agents, scoreboards, subscribers, drivers, and
 * various configuration and packet definitions necessary for
 * verifying the functionality of an ALU design.
 * 
 * Components in the package:
 * - **Sequences**: Various sequences like `Edge_Cases_sequence`, 
 *   `MSB_sequence`, `Operand1_basic_sequence`, etc., which are 
 *   used to generate transactions for different ALU operations.
 * - **Tests**: Multiple test classes like `Initialize_Test` and 
 *   operand set tests (`Operand1_set_test`, `Operand2_set1_test`, 
 *   etc.) that define different test scenarios.
 * - **UVM Components**: Includes standard UVM components like 
 *   `ALU_Monitor`, `ALU_Scoreboard`, `ALU_Subscriber`, and `ALU_Env`.
 * - **Configuration & Packet Definitions**: Includes classes like 
 *   `ALU_config` for configuring the ALU settings, and `ALU_Packet`
 *   for defining the structure of the packets being sent/received 
 *   during testing.
 * - **Custom Report Server**: Custom `custom_report_server` for
 *   handling customized report formatting.
 * 
 * Usage:
 * This package can be imported into UVM testbenches to simulate and 
 * verify various ALU functionalities using UVM sequences, drivers, 
 * monitors, scoreboards, and other UVM components.
 * 
 * Dependencies:
 * - `uvm_pkg` (UVM standard library)
 * - Various `.sv` files containing the ALU-specific classes and 
 *   sequences.
 * 
 ************************************************************/


package MyPackage;

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ALU_Macros.sv"
`include "./UVM_Objects/custom_report_server.sv"
`include "./UVM_Objects/ALU_Packet.sv"
`include "./UVM_Objects/ALU_config.sv"
`include "./UVM_Components/ALU_Sequencer.sv"
`include "./UVM_Components/ALU_Driver.sv"
`include "./UVM_Objects/ALU_en_sequence.sv"
`include "./UVM_Objects/Edge_Cases_sequence.sv"
`include "./UVM_Objects/Operand1_basic_sequence.sv"
`include "./UVM_Objects/Operand2_set1_basic_sequence.sv"
`include "./UVM_Objects/Operand2_set2_basic_sequence.sv"
`include "./UVM_Objects/MSB_sequence.sv"
`include "./UVM_Objects/Repeat_Operation_sequence.sv"
`include "./UVM_Objects/State_Transation_sequence.sv"
`include "./UVM_Objects/Test1_Virtual_Sequence.sv"
`include "./UVM_Objects/Test2_Virtual_Sequence.sv"
`include "./UVM_Objects/Test3_Virtual_Sequence.sv"
`include "./UVM_Objects/Test4_Virtual_Sequence.sv"
`include "./UVM_Components/ALU_Monitor.sv"
`include "./UVM_Components/ALU_Agent.sv"
`include "./UVM_Components/ALU_Scoreboard.sv"
`include "./UVM_Components/ALU_Subscriber.sv"
`include "./UVM_Components/ALU_Env.sv"
`include "./UVM_Components/Operand1_set_test.sv"
`include "./UVM_Components/Operand2_set1_test.sv"
`include "./UVM_Components/Operand2_set2_test.sv"
`include "./UVM_Components/Initialize_Test.sv"

endpackage
