----------------------------------------------------------------------------------
-- Legacy Fragment 2 -- Some Components of an Ancient LC3 Based SoC
-- Author: Jose Arboleda
-- Date: 2016
-- Copyright: MIT License 2026
--
-- Create Date:    15:49:55 09/22/2016
-- Design Name:
-- Module Name:    System - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity System is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  --VGA
			  RGB : out STD_LOGIC_VECTOR(7 downto 0);
			  H_SYNC : out STD_LOGIC;
			  V_SYNC : out STD_LOGIC;
			  --I/O
           SWITCHS : in  STD_LOGIC_VECTOR (7 downto 0);
           LEDS : out  STD_LOGIC_VECTOR (7 downto 0));
end System;

architecture Behavioral of System is
----------------------------------------------
---    Internal buses and connections      ---
----------------------------------------------
--CPU inteface with memory controller
signal MDR_sig: std_logic_vector(15 downto 0);
signal MAR_sig: std_logic_vector(15 downto 0);
signal R_W_sig: std_logic;
signal MEM_EN_sig: std_logic;
signal MEM_sig: std_logic_vector(15 downto 0);
signal R_sig: std_logic;

--VGA interface with memory controller
signal VGA_REG_sig: std_logic_vector(3 downto 0);
signal VGA_DATA_sig: std_logic_vector(15 downto 0);
signal VGA_EN_sig: std_logic;


begin

	--The memory controller
	MEM_CTRL: entity work.Memory_controller
	Port map(
			  CLK => CLK,
			  RST => RST,
			  --data_path interface
			  MDR => MDR_sig,
			  MAR => MAR_sig,
			  R_W => R_W_sig,
			  MEM_EN => MEM_EN_sig,
			  MEM => MEM_sig,
			  R => R_sig,
			  --peripheral interface
			  VGA_REG => VGA_REG_sig,
			  VGA_DATA => VGA_DATA_sig,
			  VGA_EN => VGA_EN_sig,
			  LEDS => LEDS,
			  INPUT_REG => SWITCHS
			  );

	--The CPU
	LC3_CPU: entity  work.LC_3_data_path
	port map(
			 Clock => CLK,
			 Reset => RST,
			 --Memory interface
			 MDR_out => MDR_sig,
			 MAR_out => MAR_sig,
			 R_W_out => R_W_sig,
			 MEM_EN_out => MEM_EN_sig,
			 MEM_in => MEM_sig,
			 R_in => R_sig
			);

	--The VGA system
	VGA_SYSTEM: entity vga_system
	port map(
			clock => CLK,
			rst => RST,
			REG_DATA => VGA_DATA_sig,
			WE => VGA_EN_sig,
			REG_DIR => VGA_REG_sig,
			RGB_out => RGB,
			vsync	=> V_SYNC,
			hsync => H_SYNC
		);

end Behavioral;
