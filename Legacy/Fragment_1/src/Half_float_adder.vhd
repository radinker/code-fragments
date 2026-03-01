----------------------------------------------------------------------------------
-- Legacy Fragment 1 -- Half Float Adder/Multiplier
-- Author: Jose Arboleda
-- Date: 2016
-- Copyright: MIT License 2026

-- Create Date:
-- Design Name:
-- Module Name:    Half_float_adder - Behavioral
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

entity Half_float_adder is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           OP_A : in  STD_LOGIC_VECTOR (15 downto 0);
           OP_B : in  STD_LOGIC_VECTOR (15 downto 0);
           RESULT : out  STD_LOGIC_VECTOR (15 downto 0));
end Half_float_adder;

architecture Behavioral of Half_float_adder is

-----------------------------------------------
----   Internal buses and connections      ----
-----------------------------------------------
signal exp: unsigned(4 downto 0); --dominant exponent
signal exp_diff: unsigned(4 downto 0); --exponents difference
signal big_s, small_s: unsigned(10 downto 0); --big and small significands
signal sign_b, sign_s: std_logic := '0'; --signs

signal shifted_small: unsigned(10 downto 0); --aligned operand
signal sum: unsigned(11 downto 0); --significant addition result
signal zero_count: unsigned(3 downto 0); --leading zeros count
signal norm_exp: unsigned(4 downto 0); --normilized values
signal norm_sum: unsigned(10 downto 0);
signal excep_result: std_logic_vector(15 downto 0) := (others => '0'); --for special results +/-INF, NaN
signal flags_sig: std_logic_vector(2 downto 0) := (others => '0'); --Flags: NaN/INF_Ov_Un

begin
-----------------------------------------
---           Unpack operands         ---
-----------------------------------------
	UNPACK: process(CLK, RST, OP_A, OP_B) is
	begin
		if(RST = '1')then
			exp <= (others => '0');
			exp_diff <= (others => '0');
			big_s <= (others => '0');
			small_s <= (others => '0');
			sign_b <= '0';
			sign_s <= '0';
			flags_sig(2) <= '0';
			excep_result <= (others => '0');
		elsif (CLK'event and CLK='1') then
			--check if the operands are NaN
			if((OP_A(14 downto 10) = 31) and (OP_A(9 downto 0) /= 0)) then --OP_A is NaN
				excep_result <= OP_A; --NaN, exp = 11111, f /= 0
				flags_sig(2) <= '1'; --signal special result
			elsif((OP_B(14 downto 10) = 31) and (OP_B(9 downto 0) /= 0)) then --OP_B is NaN
				excep_result <= OP_B; --NaN, exp = 11111, f /= 0
				flags_sig(2) <= '1';

			--OP_A is +/- INF
			elsif((OP_A(14 downto 10) = 31) and (OP_A(9 downto 0) = 0)) then
				if((OP_B(14 downto 10) = 31) and (OP_B(9 downto 0) = 0)) then
					if(OP_A(15) /= OP_B(15)) then --OP_B is also INF and signs differ
						excep_result <= x"7CFF"; --NaN, exp = 11111, f /= 0
					else
						excep_result <= OP_A(15)&"11111"&(9 downto 0 => '0'); -- +/-INF
					end if;
				else
					excep_result <= OP_A(15)&"11111"&(9 downto 0 => '0'); -- +/-INF
				end if;
				flags_sig(2) <= '1';

			--OP_B is +/- INF
			elsif((OP_B(14 downto 10) = 31) and (OP_B(9 downto 0) = 0)) then
				excep_result <= OP_B(15)&"11111"&(9 downto 0 => '0'); -- +/-INF
				flags_sig(2) <= '1';
			else
				--unpack operands
				if(unsigned(OP_A(14 downto 0)) >= unsigned(OP_B(14 downto 0))) then --OP_A is dominant
					exp <= unsigned(OP_A(14 downto 10));
					exp_diff <= unsigned(OP_A(14 downto 10)) - unsigned(OP_B(14 downto 10));
					--Special case where OP_A is 0 or denormal
					if(OP_A(14 downto 10) = 0) then
						big_s <= (others => '0');
					else
						big_s <= ('1' & unsigned(OP_A(9 downto 0)));
					end if;
					--Special case where OP_B is 0 or denormal
					if(OP_B(14 downto 10) = 0) then
						small_s <= (others => '0');
					else
						small_s <= ('1' & unsigned(OP_B(9 downto 0)));
					end if;
					sign_b <= OP_A(15);
					sign_s <= OP_B(15);
				else --OP_B is dominant
					exp <= unsigned(OP_B(14 downto 10));
					exp_diff <= unsigned(OP_B(14 downto 10)) - unsigned(OP_A(14 downto 10));
					--Special case where OP_B denormal
					if(OP_B(14 downto 10) = 0) then
						big_s <= (others => '0');
					else
						big_s <= ('1' & unsigned(OP_B(9 downto 0)));
					end if;
				   --Special case where OP_A is 0 or denormal
					if(OP_A(14 downto 10) = 0) then
						small_s <= (others => '0');
					else
						small_s <= ('1' & unsigned(OP_A(9 downto 0)));
					end if;
					sign_b <= OP_B(15);
					sign_s <= OP_A(15);
				end if;
				flags_sig(2) <= '0';
			end if;
		end if;
	end process;


-----------------------------------------
---          Align the operands       ---
-----------------------------------------
	shifted_small <= small_s srl to_integer(exp_diff);

-----------------------------------------
---           Add significands        ---
-----------------------------------------
	sum <= ('0' & big_s) + ('0' & shifted_small) when (sign_b = sign_s) else
			 ('0' & big_s) - ('0' & shifted_small);

-----------------------------------------
---        Normilize the result       ---
-----------------------------------------
	--count leading zeros in the sum
	zero_count <= "0000" when (sum(10)='1') else
					  "0001" when (sum(9)='1') else
					  "0010" when (sum(8)='1') else
					  "0011" when (sum(7)='1') else
					  "0100" when (sum(6)='1') else
					  "0101" when (sum(5)='1') else
					  "0110" when (sum(4)='1') else
					  "0111" when (sum(3)='1') else
					  "1000" when (sum(2)='1') else
					  "1001" when (sum(1)='1') else
					  "1010";

	--normilize process
	NORMALIZE: process(CLK, zero_count) is
	variable norm_exp_var: unsigned(4 downto 0);
	variable norm_sum_var: unsigned(10 downto 0);

	begin
		if(CLK'event and CLK='1') then
			if(sum(11) = '1') then --there is a carry in the sum
				norm_sum_var := sum(11 downto 1);
				norm_exp_var := exp + 1;
				flags_sig(1 downto 0) <= "00";
				if(norm_exp_var > 30) then --overflow
					flags_sig(1 downto 0) <= "10";
				end if;
			elsif(sum(10 downto 0) = "00000000000") then --result is zero
				norm_sum_var := (others => '0');
				norm_exp_var := "00000";
				flags_sig(1 downto 0) <= "00";
			elsif(zero_count = 0) then --no need to normilize
				norm_exp_var := exp;
				norm_sum_var := sum(10 downto 0);
			else --normalize shifting the significant left
				norm_sum_var := sum(10 downto 0) sll to_integer(zero_count);
				if(exp > zero_count) then
					norm_exp_var := exp - zero_count;
					flags_sig(1 downto 0) <= "00";
				else --underflow
					flags_sig(1 downto 0) <= "01";
				end if;
			end if;
		end if;
		norm_exp <= norm_exp_var;
		norm_sum <= norm_sum_var;
	end process;



-----------------------------------------
---           Pack the result         ---
-----------------------------------------
	--pack process
	PACK: process(CLK, RST, flags_sig, excep_result, norm_sum, norm_exp, sign_b) is
	begin
		if(RST = '1') then
			RESULT <= (others => '0');
		elsif(CLK'event and CLK='1') then --form the output vector
			if(flags_sig(2) = '1')then --special result
				RESULT <= excep_result;
			elsif(flags_sig(1) = '1')then --overflow
				RESULT <= sign_b&"11110"&(9 downto 0 => '1');
			elsif(flags_sig(0) = '1')then --underflow
				RESULT <= sign_b&(14 downto 0 => '0');
			else
				RESULT(15) <= sign_b;
				RESULT(14 downto 10) <= std_logic_vector(norm_exp);
				RESULT(9 downto 0) <= std_logic_vector(norm_sum(9 downto 0));
			end if;
		end if;
	end process;

end Behavioral;
