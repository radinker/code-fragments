----------------------------------------------------------------------------------
-- Legacy Fragment 2 -- Some Components of an Ancient LC3 Based SoC
-- Author: Jose Arboleda
-- Date: 2016
-- Copyright: MIT License 2026
--
-- Create Date:
-- Design Name:
-- Module Name:    Memory_controller - Behavioral
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
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Memory_controller is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  --data_path interface
           MDR : in  STD_LOGIC_VECTOR (15 downto 0);
           MAR : in  STD_LOGIC_VECTOR (15 downto 0);
           R_W : in  STD_LOGIC;
           MEM_EN : in  STD_LOGIC;
           MEM : out  STD_LOGIC_VECTOR (15 downto 0);
           R : out  STD_LOGIC;
			  --peripheral interface
           VGA_REG : out  STD_LOGIC_VECTOR (3 downto 0);
			  VGA_DATA : out STD_LOGIC_VECTOR (15 downto 0);
           VGA_EN : out  STD_LOGIC;
           LEDS : out  STD_LOGIC_VECTOR (7 downto 0);
           INPUT_REG : in  STD_LOGIC_VECTOR (7 downto 0));
end Memory_controller;

architecture Behavioral of Memory_controller is

----------------------------------------------
---    Constants and data types            ---
----------------------------------------------
type ctrl_state is (idle, RW, reading, writing, waiting, ack, ack_2); --memory controller states
type mem_state is (idle, BRAM_read, in_read, BRAM_write, LED_write, VGA_write, dummy_wr);
constant PROGRAM_OFFSET: unsigned(15 downto 0) := x"3000"; --user program start address
constant IMP_LIMIT: unsigned(15 downto 0) := x"7000"; --implemented memory limit
constant IN_REG: unsigned(15 downto 0) := x"FDEE"; --switchs input register
constant LEDS_REG: unsigned(15 downto 0) := x"FDEF"; --leds output register
constant VGA_END: unsigned(15 downto 0) := x"FDFF"; --VGA module start address
constant VGA_START: unsigned(15 downto 0) := x"FDF0";

----------------------------------------------
---    Internal buses and connections      ---
----------------------------------------------
--BRAM  interface
signal we_sig: std_logic;-- := '0';
signal addr_sig: std_logic_vector(13 downto 0);
signal din_sig: std_logic_vector(15 downto 0);
signal dout_sig: std_logic_vector(15 downto 0);

--registers
--signal cur_state, next_state: ctrl_state := idle; --signal to hold the state
signal cur_state, next_state: mem_state := idle; --signal to hold the state

--unsigned value of input MAR
signal MAR_sig: unsigned(15 downto 0);
signal mem_addr: unsigned(15 downto 0);

--control signals
signal leds_en: std_logic := '0';
signal mem_source: std_logic_vector(1 downto 0) := "00";
signal R_reg: std_logic;
signal VGA_EN_reg: std_logic;

begin
	--Block RAM instance
	BRAM: entity work.xilinx_one_port_ram_sync
		port map(
			clk => CLK,
			we => we_sig,
			addr => addr_sig,
			din => din_sig,
			dout => dout_sig
		);

----------------------------------------------------
---						Data Path                   ---
----------------------------------------------------

	--Unisigned MAR
	MAR_sig <= unsigned(MAR);

	--Ready signal
	R <= R_reg;

	--BRAM signals
	mem_addr <= MAR_sig - PROGRAM_OFFSET;
	addr_sig <= std_logic_vector(mem_addr(13 downto 0));
	din_sig <= MDR;

	--VGA data and register address
	VGA_DATA <= MDR;
	VGA_REG <= MAR(3 downto 0);
	VGA_EN <= VGA_EN_reg;

	--LEDS
	process(CLK)
		begin
		if(CLK'event and CLK = '1') then
			if leds_en = '1' then
				LEDS <= MDR(7 downto 0);
			end if;
		end if;
	end process;

	--Data output to CPU
	MEM <= dout_sig when mem_source = "01" else
			x"00"&INPUT_REG when mem_source = "10" else
			x"0000";



----------------------------------------------------
---				   Control Path                   ---
----------------------------------------------------
--State register
process(CLK, RST)
		begin
		if(RST = '1') then
			cur_state <= idle;
		elsif(CLK'event and CLK = '1') then
			cur_state <= next_state;
		end if;
end process;

--Control signals: R_reg, we_sig, leds_en, mem_source, VGA_EN_reg
process(cur_state, MEM_EN, R_W, MAR_sig, R_reg, we_sig, leds_en, mem_source, VGA_EN_reg)
		begin
			--default
			next_state <= cur_state;
			R_reg <= '0';
			we_sig <= '0';
			leds_en <= '0';
			mem_source <= "00";
			VGA_EN_reg <= '0';

			case cur_state is
				when idle => --wait for CPU request
					if(MEM_EN = '1') then --CPU MEM request
						if(R_W = '0') then --readign
							if((MAR_sig >= PROGRAM_OFFSET) and (MAR_sig < IMP_LIMIT))then --user program memory
								next_state <= BRAM_read;
							elsif(MAR_sig = IN_REG) then --input register
								next_state <= in_read;
							else
								next_state <= dummy_wr;
							end if;
						elsif(R_W = '1') then --writing
							if((MAR_sig >= PROGRAM_OFFSET) and (MAR_sig < IMP_LIMIT))then --writing to BRAM
								next_state <= BRAM_write;
							elsif(MAR_sig = LEDS_REG) then --write to LEDS
								next_state <= LED_write;
							elsif((MAR_sig >= VGA_START) and (MAR_sig <= VGA_END)) then --write to VGA registers
								next_state <= VGA_write;
							else
								next_state <= dummy_wr;
							end if;
					   end if;
				 end if;

				when BRAM_read =>
					R_reg <= '1';
					mem_source <= "01";
					next_state <= idle;

				when IN_read =>
					R_reg <= '1';
					mem_source <= "10";
					next_state <= idle;

				when BRAM_write =>
					R_reg <= '1';
					we_sig <= '1';
					next_state <= idle;

				when LED_write =>
					R_reg <= '1';
					leds_en <= '1';
				   next_state <= idle;

				when VGA_write =>
					R_reg <= '1';
					VGA_EN_reg <= '1';
					next_state <= idle;

				when dummy_wr =>
					R_reg <= '1';
					next_state <= idle;

			end case;
	end process;


end Behavioral;
