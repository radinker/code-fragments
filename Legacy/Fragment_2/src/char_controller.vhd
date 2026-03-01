----------------------------------------------------------------------------------
-- Legacy Fragment 2 -- Some Components of an Ancient LC3 Based SoC
-- Author: Jose Arboleda
-- Date: 2016
-- Copyright: MIT License 2026
--
-- Create Date:    20:28:23 07/26/2016
-- Design Name:
-- Module Name:    char_controller - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity char_controller is
    Port ( CLK : in  STD_LOGIC;
			  --character selection signals
			  ROW_ADDR : in  STD_LOGIC_VECTOR (3 downto 0);
           TILE_ADDR : in  STD_LOGIC_VECTOR (11 downto 0);
           BIT_SEL : in  STD_LOGIC_VECTOR (2 downto 0);
			  --tile RAM external port
           ADDR_A : in  STD_LOGIC_VECTOR (11 downto 0);
           DIN_A : in  STD_LOGIC_VECTOR (6 downto 0);
           WR : in  STD_LOGIC;
			  --font bit signal
           FONT_BIT : out  STD_LOGIC);
end char_controller;

architecture Behavioral of char_controller is

---------------------------------------------
--		 Internal buses and connections      --
---------------------------------------------

--font ROM addr
signal rom_addr: std_logic_vector(10 downto 0);
--font ROM output
signal font_word: std_logic_vector(7 downto 0);
--tile RAM output
signal char_addr: std_logic_vector(6 downto 0);

begin
	--instantiate tile RAM
	TILE_RAM_UNIT: entity work.xilinx_dual_port_ram_sync
		port map(
			clk => CLK,
			we => WR,
			addr_a => ADDR_A,
			addr_b => TILE_ADDR,
			din_a => DIN_A,
			dout_a => open,
			dout_b => char_addr
		);

	--instantiate font ROM
	FONT_ROM_UNIT: entity work.font_rom
		port map(
			clk => CLK,
			addr => rom_addr,
			data => font_word
		);

	--form the font ROM address
	rom_addr <= char_addr&ROW_ADDR;

	--bit selector MUX
	FONT_BIT <= font_word(to_integer(unsigned(not BIT_SEL)));


end Behavioral;
