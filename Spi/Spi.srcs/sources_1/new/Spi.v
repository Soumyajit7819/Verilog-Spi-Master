`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2023 07:30:57 PM
// Design Name: 
// Module Name: Spi
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



// SPI MASTER IMPLEMENTATION
module Spi(
        input wire clk,                    // System Clock
        input wire reset,                  // System Reset
        input wire [15:0] MISO,            // 16bit Data INPUT From The Slave
        
        // Outputs OF SPI MASTER
        output wire spi_cs_l,              // SPI Active-Low Chip Select
        output wire spi_sclk,              // SPI Clk
        output wire spi_MOSI,              // SPI DATA
        output [4:0] counter               // TO Count how many input bits Sent already
    );
    
    
    reg [15:0] MOSI;                        // Spi shift register
    reg [4:0] count;                        // Control Counter
    reg cs_l;                               // Spi chip select (ACTIVE LOW)
    reg sclk;                               // SPI SCLK
    reg [2:0]state;                         // SPI States
    
    
    always@(posedge clk or posedge reset)
    
    // When Reset Active
    if(reset)
        begin
            MOSI   <= 16'b0;
            count  <=  5'd16;
            cs_l   <=  1'b1;
            sclk   <=  1'b0;
        end
    
    else
        begin
         case (state) 
                  // When CHIP SELECT 1 No Communication
                  0:   begin
                           sclk   <= 1'b0;
                           cs_l   <= 1'b1;  
                           state  <= 1;
                       end
                       
                  // When CHIP SELECT 0 SPI Communication Starts Serially
                  1:   begin
                           sclk   <= 1'b0;
                           cs_l   <= 1'b0;  
                           MOSI   <= MISO[count-1];   // First MSB then LSB Data Input
                           count  <= count-1;
                           state  <= 2;
                       end
                       
                  // When SPI_Clock Becomes 1
                  2:   begin
                           sclk   <= 1'b1;  
                           if (count > 0)
                                state  <= 1;
                           else
                              begin
                                    count <=16;
                                    state <= 0;
                              end
                       end
            default:   state <= 0;    
           endcase    
        end

assign spi_cs_l = cs_l;
assign spi_sclk = sclk;
assign spi_MOSI = MOSI;
assign counter = count;         
        
endmodule