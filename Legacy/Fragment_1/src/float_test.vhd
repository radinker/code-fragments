--------------------------------------------------------------------------------
-- Legacy Fragment 1 -- Half Float Adder/Multiplier
-- Author: Jose Arboleda
-- Date: 2016
-- Copyright: MIT License 2026
--
-- Create Date:
-- Design Name:
-- Module Name:
-- Project Name:  Half_float_adder
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: Half_float_adder
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

ENTITY float_test IS
END float_test;

ARCHITECTURE behavior OF float_test IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT Half_float_adder
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         OP_A : IN  std_logic_vector(15 downto 0);
         OP_B : IN  std_logic_vector(15 downto 0);
         RESULT : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;


   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   --signal TEST : std_logic := '0';
   signal OP_A : std_logic_vector(15 downto 0) := (others => '0');
   signal OP_B : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal RESULT : std_logic_vector(15 downto 0);
   --signal FLAGS : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant CLK_period: time := 20 ns;


BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: Half_float_adder PORT MAP (
          CLK => CLK,
          RST => RST,
          --TEST => TEST,
          OP_A => OP_A,
          OP_B => OP_B,
          RESULT => RESULT
          --FLAGS => FLAGS
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
	variable test_count: integer := 0;
   begin
      -- hold reset state for 100 ns.
      wait for 100 ns;

      wait for CLK_period*10;

      -- insert stimulus here
		RST <= '0';

--test 0
OP_A <= x"0400";
OP_B <= x"0400";
wait for CLK_period*3;
assert (RESULT = x"0800") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 1
OP_A <= x"0400";
OP_B <= x"22ff";
wait for CLK_period*3;
assert (RESULT = x"2307") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 2
OP_A <= x"0400";
OP_B <= x"41ff";
wait for CLK_period*3;
assert (RESULT = x"41ff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 3
OP_A <= x"0400";
OP_B <= x"60ff";
wait for CLK_period*3;
assert (RESULT = x"60ff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 4
OP_A <= x"0400";
OP_B <= x"7fff";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 5
OP_A <= x"0400";
OP_B <= x"9eff";
wait for CLK_period*3;
assert (RESULT = x"9eef") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 6
OP_A <= x"0400";
OP_B <= x"bdff";
wait for CLK_period*3;
assert (RESULT = x"bdff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 7
OP_A <= x"0400";
OP_B <= x"dcff";
wait for CLK_period*3;
assert (RESULT = x"dcff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 8
OP_A <= x"22ff";
OP_B <= x"0400";
wait for CLK_period*3;
assert (RESULT = x"2307") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 9
OP_A <= x"22ff";
OP_B <= x"22ff";
wait for CLK_period*3;
assert (RESULT = x"26ff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 10
OP_A <= x"22ff";
OP_B <= x"41ff";
wait for CLK_period*3;
assert (RESULT = x"4205") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 11
OP_A <= x"22ff";
OP_B <= x"60ff";
wait for CLK_period*3;
assert (RESULT = x"60ff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 12
OP_A <= x"22ff";
OP_B <= x"7fff";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 13
OP_A <= x"22ff";
OP_B <= x"9eff";
wait for CLK_period*3;
assert (RESULT = x"1f00") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 14
OP_A <= x"22ff";
OP_B <= x"bdff";
wait for CLK_period*3;
assert (RESULT = x"bdf2") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 15
OP_A <= x"22ff";
OP_B <= x"dcff";
wait for CLK_period*3;
assert (RESULT = x"dcff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 16
OP_A <= x"41ff";
OP_B <= x"0400";
wait for CLK_period*3;
assert (RESULT = x"41ff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 17
OP_A <= x"41ff";
OP_B <= x"22ff";
wait for CLK_period*3;
assert (RESULT = x"4205") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 18
OP_A <= x"41ff";
OP_B <= x"41ff";
wait for CLK_period*3;
assert (RESULT = x"45ff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 19
OP_A <= x"41ff";
OP_B <= x"60ff";
wait for CLK_period*3;
assert (RESULT = x"6104") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 20
OP_A <= x"41ff";
OP_B <= x"7fff";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 21
OP_A <= x"41ff";
OP_B <= x"9eff";
wait for CLK_period*3;
assert (RESULT = x"41fc") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 22
OP_A <= x"41ff";
OP_B <= x"bdff";
wait for CLK_period*3;
assert (RESULT = x"3e00") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 23
OP_A <= x"41ff";
OP_B <= x"dcff";
wait for CLK_period*3;
assert (RESULT = x"dcf4") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 24
OP_A <= x"60ff";
OP_B <= x"0400";
wait for CLK_period*3;
assert (RESULT = x"60ff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 25
OP_A <= x"60ff";
OP_B <= x"22ff";
wait for CLK_period*3;
assert (RESULT = x"60ff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 26
OP_A <= x"60ff";
OP_B <= x"41ff";
wait for CLK_period*3;
assert (RESULT = x"6104") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 27
OP_A <= x"60ff";
OP_B <= x"60ff";
wait for CLK_period*3;
assert (RESULT = x"64ff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 28
OP_A <= x"60ff";
OP_B <= x"7fff";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 29
OP_A <= x"60ff";
OP_B <= x"9eff";
wait for CLK_period*3;
assert (RESULT = x"60ff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 30
OP_A <= x"60ff";
OP_B <= x"bdff";
wait for CLK_period*3;
assert (RESULT = x"60fd") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 31
OP_A <= x"60ff";
OP_B <= x"dcff";
wait for CLK_period*3;
assert (RESULT = x"5d00") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 32
OP_A <= x"7fff";
OP_B <= x"0400";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 33
OP_A <= x"7fff";
OP_B <= x"22ff";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 34
OP_A <= x"7fff";
OP_B <= x"41ff";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 35
OP_A <= x"7fff";
OP_B <= x"60ff";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 36
OP_A <= x"7fff";
OP_B <= x"7fff";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 37
OP_A <= x"7fff";
OP_B <= x"9eff";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 38
OP_A <= x"7fff";
OP_B <= x"bdff";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 39
OP_A <= x"7fff";
OP_B <= x"dcff";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 40
OP_A <= x"9eff";
OP_B <= x"0400";
wait for CLK_period*3;
assert (RESULT = x"9eef") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 41
OP_A <= x"9eff";
OP_B <= x"22ff";
wait for CLK_period*3;
assert (RESULT = x"1f00") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 42
OP_A <= x"9eff";
OP_B <= x"41ff";
wait for CLK_period*3;
assert (RESULT = x"41fc") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 43
OP_A <= x"9eff";
OP_B <= x"60ff";
wait for CLK_period*3;
assert (RESULT = x"60ff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 44
OP_A <= x"9eff";
OP_B <= x"7fff";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 45
OP_A <= x"9eff";
OP_B <= x"9eff";
wait for CLK_period*3;
assert (RESULT = x"a2ff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 46
OP_A <= x"9eff";
OP_B <= x"bdff";
wait for CLK_period*3;
assert (RESULT = x"be05") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 47
OP_A <= x"9eff";
OP_B <= x"dcff";
wait for CLK_period*3;
assert (RESULT = x"dcff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 48
OP_A <= x"bdff";
OP_B <= x"0400";
wait for CLK_period*3;
assert (RESULT = x"bdff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 49
OP_A <= x"bdff";
OP_B <= x"22ff";
wait for CLK_period*3;
assert (RESULT = x"bdf2") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 50
OP_A <= x"bdff";
OP_B <= x"41ff";
wait for CLK_period*3;
assert (RESULT = x"3e00") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 51
OP_A <= x"bdff";
OP_B <= x"60ff";
wait for CLK_period*3;
assert (RESULT = x"60fd") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 52
OP_A <= x"bdff";
OP_B <= x"7fff";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 53
OP_A <= x"bdff";
OP_B <= x"9eff";
wait for CLK_period*3;
assert (RESULT = x"be05") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 54
OP_A <= x"bdff";
OP_B <= x"bdff";
wait for CLK_period*3;
assert (RESULT = x"c1ff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 55
OP_A <= x"bdff";
OP_B <= x"dcff";
wait for CLK_period*3;
assert (RESULT = x"dd04") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 56
OP_A <= x"dcff";
OP_B <= x"0400";
wait for CLK_period*3;
assert (RESULT = x"dcff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 57
OP_A <= x"dcff";
OP_B <= x"22ff";
wait for CLK_period*3;
assert (RESULT = x"dcff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 58
OP_A <= x"dcff";
OP_B <= x"41ff";
wait for CLK_period*3;
assert (RESULT = x"dcf4") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 59
OP_A <= x"dcff";
OP_B <= x"60ff";
wait for CLK_period*3;
assert (RESULT = x"5d00") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 60
OP_A <= x"dcff";
OP_B <= x"7fff";
wait for CLK_period*3;
assert ((RESULT(14 downto 10) = "11111") and (RESULT(9 downto 0) /= "0000000000")) report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 61
OP_A <= x"dcff";
OP_B <= x"9eff";
wait for CLK_period*3;
assert (RESULT = x"dcff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 62
OP_A <= x"dcff";
OP_B <= x"bdff";
wait for CLK_period*3;
assert (RESULT = x"dd04") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;

--test 63
OP_A <= x"dcff";
OP_B <= x"dcff";
wait for CLK_period*3;
assert (RESULT = x"e0ff") report "Wrong result at test "&integer'image(test_count);
test_count := test_count + 1;


		report "Total tests: "&integer'image(test_count);

      wait;
   end process;

END;
