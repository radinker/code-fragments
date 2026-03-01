----------------------------------------------------------------------------------
-- Legacy Fragment 2 -- Some Components of an Ancient LC3 Based SoC
-- Author: Jose Arboleda
-- Date: 2016
-- Copyright: MIT License 2026
--
-- Create Date:    14:10:49 06/02/2010
-- Design Name:
-- Module Name:    practica - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_system is
port(
		clock    :		in		std_logic;
		rst 		: in std_logic;
		REG_DATA : in std_logic_vector(15 downto 0); --data to write to VGA registers
		WE       : in std_logic; --VGA registers write enable
		REG_DIR  : in std_logic_vector (3 downto 0); --VGA register to write
		RGB_out	:		out	std_logic_vector(7 downto 0);
		vsync		:		out std_logic;
		hsync		:		out std_logic
		);
end vga_system;

architecture Behavioral of vga_system is
---------------------------------
--Intenal buses and connections--
---------------------------------
--VGA controller signals
signal	RGB_in_S	   :			std_logic_vector(7 downto 0);
signal	newf_S		:			std_logic;
signal	p_row_S		:			std_logic_vector(9 downto 0);
signal	p_col_S		:			std_logic_vector(9 downto 0);

--VGA register bank (16 registers)
type register_bank is array (0 to 15) of std_logic_vector(15 downto 0);
signal vga_registers: register_bank := (others => (others => '0'));
signal index: std_logic_vector(4 downto 0) := "00000";

--Character controller signals
signal row_addr_s: STD_LOGIC_VECTOR(3 downto 0);
signal tile_addr_s: STD_LOGIC_VECTOR(11 downto 0);
signal bit_sel_0, bit_sel_1, bit_sel_2: STD_LOGIC_VECTOR(2 downto 0);
signal addr_a_s: STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal din_a_s: STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
signal wr_s: STD_LOGIC := '1';
signal font_bit_s: STD_LOGIC;
constant CHAR_REG: integer := 14; --assuming software is writing to registers 14 and 15
constant ADDR_REG: integer := 15;

begin
	--VGA controller
	VGA_CTRL: entity work.vga_800_600
	port map(
			clock=>clock,
			rst=>rst,
			RGB_in=>RGB_in_S,
			RGB_out=>RGB_out,
			vsync=>vsync,
			hsync=>hsync,
			newf=>newf_S,
			pixel_row=>p_row_S,
			pixel_column=>p_col_S
	      );

	--Character controller
	CHAR_CTRL: entity work.char_controller
	Port map( CLK => clock,
			  ROW_ADDR => row_addr_s,
           TILE_ADDR => tile_addr_s,
           BIT_SEL => bit_sel_2,
           ADDR_A => addr_a_s,
           DIN_A => din_a_s,
           WR => wr_s,
           FONT_BIT => font_bit_s
			  );


-----VGA registers control--------------------------------------------
	--Update the index
	index <= conv_std_logic_vector(conv_integer(REG_DIR), 5);

	--Process to update the VGA register bank
	process(WE, index)
		begin
			if rising_edge(WE) then
				vga_registers(conv_integer(index)) <= REG_DATA;
			end if;
	end process;

----------Char controller------------------------------------
	--Tile address to read
	tile_addr_s <= p_row_S(8 downto 4)&p_col_S(9 downto 3);

	--Row address
	row_addr_s <= p_row_S(3 downto 0);

	--Bit selector
	bit_sel_0 <= p_col_S(2 downto 0);

	--2 clk cycles delay for bit selsctor signal
	process(RST, clock, bit_sel_0)
		begin
		if RST = '1' then
			bit_sel_1 <= "000";
			bit_sel_2 <= "000";
		elsif rising_edge(clock) then
			bit_sel_1 <= bit_sel_0;
			bit_sel_2 <= bit_sel_1;
		end if;
	end process;

	--Tile address to write
	addr_a_s <= vga_registers(ADDR_REG)(11 downto 0);

	--Character to write, ASCII code
	din_a_s <= vga_registers(CHAR_REG)(6 downto 0);



-------------------------------Paint the screen---------------------------------
	RGB_in_S <= "00111000" when ((font_bit_s = '1') and (p_row_S(9) = '0')) else
					"00000000";

end Behavioral;
