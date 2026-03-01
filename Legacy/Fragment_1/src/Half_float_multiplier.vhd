----------------------------------------------------------------------------------
-- Legacy Fragment 1 -- Half Float Adder/Multiplier
-- Author: Jose Arboleda
-- Date: 2016
-- Copyright: MIT License 2026
--
-- Create Date:
-- Design Name:
-- Module Name:    Half_float_multiplier - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Half_float_multiplier is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           OP_A : in  STD_LOGIC_VECTOR (15 downto 0);
           OP_B : in  STD_LOGIC_VECTOR (15 downto 0);
           RESULT : out  STD_LOGIC_VECTOR (15 downto 0));
end Half_float_multiplier;

architecture Behavioral of Half_float_multiplier is

-----------------------------------------------
----   Internal buses and connections      ----
-----------------------------------------------
signal sign: std_logic := '0'; --operation sign
signal sig_a, sig_b: unsigned(10 downto 0); --significands
signal exp_a, exp_b: unsigned(4 downto 0); --exponents

signal product: unsigned(21 downto 0); --significands product
signal norm_product: unsigned(10 downto 0); --normalized values
signal norm_exp: unsigned(4 downto 0);

signal excep_result: std_logic_vector(15 downto 0) := (others => '0'); --for special results +/-INF, NaN
signal flags_sig: std_logic_vector(2 downto 0) := (others => '0'); --Flags: NaN/INF_Ov_Un
constant bias: unsigned(4 downto 0) := "01111"; --exponent bias

begin
-----------------------------------------
---           Unpack operands         ---
-----------------------------------------
	UNPACK: process(CLK, RST, OP_A, OP_B) is
	begin
		if(RST = '1') then
			sign <= '0';
			sig_a <= (others => '0');
			sig_b <= (others => '0');
			exp_a <= (others => '0');
			exp_b <= (others => '0');
		elsif(CLK'event and CLK='1') then
			--check if the operands are NaN
			if((OP_A(14 downto 10) = 31) and (OP_A(9 downto 0) /= 0)) then --OP_A is NaN
				excep_result <= OP_A; --NaN, exp = 11111, f /= 0
				flags_sig(2) <= '1'; --signal special result
			elsif((OP_B(14 downto 10) = 31) and (OP_B(9 downto 0) /= 0)) then --OP_B is NaN
				excep_result <= OP_B; --NaN, exp = 11111, f /= 0
				flags_sig(2) <= '1';

			--check if the operands +/-INF
			elsif((OP_A(14 downto 10) = 31)) then --OP_A is INF
				-- +/-INF * 0 = NaN
				if((OP_B(14 downto 10) = 0)) then
					excep_result <= x"7CFF"; --NaN, exp = 11111, f /= 0
				else --
					excep_result <= (OP_A(15) xor OP_B(15))&"11111"&(9 downto 0 => '0');
				end if;
				flags_sig(2) <= '1';
			elsif((OP_B(14 downto 10) = 31)) then --OP_B is INF
				-- +/-INF * 0 = NaN
				if((OP_A(14 downto 10) = 0)) then
					excep_result <= x"7CFF"; --NaN, exp = 11111, f /= 0
				else
					excep_result <= (OP_A(15) xor OP_B(15))&"11111"&(9 downto 0 => '0');
				end if;
				flags_sig(2) <= '1';

			--check if operands are 0 or denormals
			elsif((OP_B(14 downto 10) = 0) or (OP_A(14 downto 10) = 0)) then
				excep_result <= (others => '0');
				flags_sig(2) <= '1';

			--unpack operands
			else
				sign <= (OP_A(15) xor OP_B(15));
				sig_a <= '1' & unsigned(OP_A(9 downto 0));
				sig_b <= '1' & unsigned(OP_B(9 downto 0));
				exp_a <= unsigned(OP_A(14 downto 10));
				exp_b <= unsigned(OP_B(14 downto 10));
				flags_sig(2) <= '0';
			end if;
		end if;
	end process;

-----------------------------------------
---      Multiply significands        ---
-----------------------------------------
product <= sig_a * sig_b;

-----------------------------------------
---    Add exponents and normalize    ---
-----------------------------------------
	ADDNORM: process(CLK, exp_a, exp_b, product) is
	variable exp_a_var, exp_b_var, added_exp: integer range -32 to 31 := 0;
	begin
		exp_a_var := to_integer(exp_a) - 15; --calculate exponents values
		exp_b_var := to_integer(exp_b) - 15;
		added_exp := exp_a_var + exp_b_var;

		if(product(21) = '1') then --normalize
			norm_product <= product(21 downto 11);
			added_exp := added_exp + 1;
		else --no need to normalize
			norm_product <= product(20 downto 10);
		end if;

		--check for overflow/underflow and calculate exp
		if(added_exp > 15) then
			flags_sig(1 downto 0) <= "10";
		elsif(added_exp < -14) then
			flags_sig(1 downto 0) <= "01";
		else
			flags_sig(1 downto 0) <= "00";
			added_exp := added_exp + 15;
			norm_exp <= to_unsigned(added_exp, 5);
		end if;
	end process;


-----------------------------------------
---           Pack the result         ---
-----------------------------------------
	PACK: process(CLK, RST, flags_sig, norm_product, norm_exp, sign) is
	begin
		if(RST = '1') then
			RESULT <= (others => '0');
		elsif(CLK'event and CLK='1') then --form the output vector
			if(flags_sig(2) = '1')then --special result
				RESULT <= excep_result;
			elsif(flags_sig(1) = '1')then --overflow
				RESULT <= sign&"11110"&(9 downto 0 => '1');
			elsif(flags_sig(0) = '1')then --underflow
				RESULT <= sign&(14 downto 0 => '0');
			else
				RESULT(15) <= sign;
				RESULT(14 downto 10) <= std_logic_vector(norm_exp);
				RESULT(9 downto 0) <= std_logic_vector(norm_product(9 downto 0));
			end if;
		end if;
	end process;


end Behavioral;
