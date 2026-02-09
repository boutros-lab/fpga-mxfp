--------------------------------------------------------------------------------
--                          IntAdder_19_Freq750_uid5
-- VHDL generated for StratixV @ 750MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2016)
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles
-- Clock period (ns): 1.33333
-- Target frequency (MHz): 750
-- Input signals: X Y Cin
-- Output signals: R
--  approx. input signal timings: X: (c0, 0.000000ns)Y: (c0, 0.000000ns)Cin: (c0, 0.000000ns)
--  approx. output signal timings: R: (c0, 0.747000ns)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_19_Freq750_uid5 is
    port (clk : in std_logic;
          X : in  std_logic_vector(18 downto 0);
          Y : in  std_logic_vector(18 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(18 downto 0)   );
end entity;

architecture arch of IntAdder_19_Freq750_uid5 is
signal Rtmp :  std_logic_vector(18 downto 0);
   -- timing of Rtmp: (c0, 0.747000ns)
begin
   Rtmp <= X + Y + Cin;
   R <= Rtmp;
end architecture;

--------------------------------------------------------------------------------
--                     Normalizer_Z_19_19_19_Freq750_uid7
-- VHDL generated for StratixV @ 750MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, (2007-2020)
--------------------------------------------------------------------------------
-- Pipeline depth: 5 cycles
-- Clock period (ns): 1.33333
-- Target frequency (MHz): 750
-- Input signals: X
-- Output signals: Count R
--  approx. input signal timings: X: (c0, 0.747000ns)
--  approx. output signal timings: Count: (c5, 0.486333ns)R: (c5, 0.919333ns)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity Normalizer_Z_19_19_19_Freq750_uid7 is
    port (clk : in std_logic;
          X : in  std_logic_vector(18 downto 0);
          Count : out  std_logic_vector(4 downto 0);
          R : out  std_logic_vector(18 downto 0)   );
end entity;

architecture arch of Normalizer_Z_19_19_19_Freq750_uid7 is
signal level5, level5_d1 :  std_logic_vector(18 downto 0);
   -- timing of level5: (c0, 0.747000ns)
signal count4, count4_d1, count4_d2, count4_d3, count4_d4 :  std_logic;
   -- timing of count4: (c1, 0.405667ns)
signal level4, level4_d1 :  std_logic_vector(18 downto 0);
   -- timing of level4: (c1, 0.838667ns)
signal count3, count3_d1, count3_d2, count3_d3 :  std_logic;
   -- timing of count3: (c2, 0.453333ns)
signal level3, level3_d1 :  std_logic_vector(18 downto 0);
   -- timing of level3: (c2, 0.886333ns)
signal count2, count2_d1, count2_d2 :  std_logic;
   -- timing of count2: (c3, 0.479000ns)
signal level2, level2_d1 :  std_logic_vector(18 downto 0);
   -- timing of level2: (c3, 0.912000ns)
signal count1, count1_d1 :  std_logic;
   -- timing of count1: (c4, 0.482667ns)
signal level1, level1_d1 :  std_logic_vector(18 downto 0);
   -- timing of level1: (c4, 0.915667ns)
signal count0 :  std_logic;
   -- timing of count0: (c5, 0.486333ns)
signal level0 :  std_logic_vector(18 downto 0);
   -- timing of level0: (c5, 0.919333ns)
signal sCount :  std_logic_vector(4 downto 0);
   -- timing of sCount: (c5, 0.486333ns)
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            level5_d1 <=  level5;
            count4_d1 <=  count4;
            count4_d2 <=  count4_d1;
            count4_d3 <=  count4_d2;
            count4_d4 <=  count4_d3;
            level4_d1 <=  level4;
            count3_d1 <=  count3;
            count3_d2 <=  count3_d1;
            count3_d3 <=  count3_d2;
            level3_d1 <=  level3;
            count2_d1 <=  count2;
            count2_d2 <=  count2_d1;
            level2_d1 <=  level2;
            count1_d1 <=  count1;
            level1_d1 <=  level1;
         end if;
      end process;
   level5 <= X ;
   count4<= '1' when level5_d1(18 downto 3) = (18 downto 3=>'0') else '0';
   level4<= level5_d1(18 downto 0) when count4='0' else level5_d1(2 downto 0) & (15 downto 0 => '0');

   count3<= '1' when level4_d1(18 downto 11) = (18 downto 11=>'0') else '0';
   level3<= level4_d1(18 downto 0) when count3='0' else level4_d1(10 downto 0) & (7 downto 0 => '0');

   count2<= '1' when level3_d1(18 downto 15) = (18 downto 15=>'0') else '0';
   level2<= level3_d1(18 downto 0) when count2='0' else level3_d1(14 downto 0) & (3 downto 0 => '0');

   count1<= '1' when level2_d1(18 downto 17) = (18 downto 17=>'0') else '0';
   level1<= level2_d1(18 downto 0) when count1='0' else level2_d1(16 downto 0) & (1 downto 0 => '0');

   count0<= '1' when level1_d1(18 downto 18) = (18 downto 18=>'0') else '0';
   level0<= level1_d1(18 downto 0) when count0='0' else level1_d1(17 downto 0) & (0 downto 0 => '0');

   R <= level0;
   sCount <= count4_d4 & count3_d3 & count2_d2 & count1_d1 & count0;
   Count <= sCount;
end architecture;

--------------------------------------------------------------------------------
--                             MXFP_E2M3_to_FP32
--                   (Fix2FP_S_M6_12_to_8_23_Freq750_uid2)
-- VHDL generated for StratixV @ 750MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin (2009-2026)
--------------------------------------------------------------------------------
-- Pipeline depth: 6 cycles
-- Clock period (ns): 1.33333
-- Target frequency (MHz): 750
-- Input signals: I
-- Output signals: O
--  approx. input signal timings: I: (c0, 0.000000ns)
--  approx. output signal timings: O: (c6, 0.175000ns)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity MXFP_E2M3_to_FP32 is
    port (clk : in std_logic;
          I : in  std_logic_vector(18 downto 0);
          O : out  std_logic_vector(8+23+2 downto 0)   );
end entity;

architecture arch of MXFP_E2M3_to_FP32 is
   component IntAdder_19_Freq750_uid5 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(18 downto 0);
             Y : in  std_logic_vector(18 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(18 downto 0)   );
   end component;

   component Normalizer_Z_19_19_19_Freq750_uid7 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(18 downto 0);
             Count : out  std_logic_vector(4 downto 0);
             R : out  std_logic_vector(18 downto 0)   );
   end component;

signal sign, sign_d1, sign_d2, sign_d3, sign_d4, sign_d5, sign_d6 :  std_logic;
   -- timing of sign: (c0, 0.000000ns)
signal xoredI :  std_logic_vector(18 downto 0);
   -- timing of xoredI: (c0, 0.000000ns)
signal bigSign :  std_logic_vector(18 downto 0);
   -- timing of bigSign: (c0, 0.000000ns)
signal input :  std_logic_vector(18 downto 0);
   -- timing of input: (c0, 0.747000ns)
signal overflow1 :  std_logic;
   -- timing of overflow1: (c0, 0.000000ns)
signal sticky1 :  std_logic;
   -- timing of sticky1: (c0, 0.000000ns)
signal input1 :  std_logic_vector(18 downto 0);
   -- timing of input1: (c0, 0.747000ns)
signal lzc :  std_logic_vector(4 downto 0);
   -- timing of lzc: (c5, 0.486333ns)
signal mantissa :  std_logic_vector(18 downto 0);
   -- timing of mantissa: (c5, 0.919333ns)
signal sticky :  std_logic;
   -- timing of sticky: (c0, 0.000000ns)
signal lzcP :  std_logic_vector(7 downto 0);
   -- timing of lzcP: (c5, 0.486333ns)
signal zero, zero_d1 :  std_logic;
   -- timing of zero: (c5, 0.919333ns)
signal exponentCorrection, exponentCorrection_d1, exponentCorrection_d2, exponentCorrection_d3, exponentCorrection_d4, exponentCorrection_d5 :  std_logic_vector(7 downto 0);
   -- timing of exponentCorrection: (c0, 0.000000ns)
signal exponentField :  std_logic_vector(7 downto 0);
   -- timing of exponentField: (c5, 0.914333ns)
signal MSB2Signal :  std_logic_vector(7 downto 0);
   -- timing of MSB2Signal: (c0, 0.000000ns)
signal fractionField :  std_logic_vector(22 downto 0);
   -- timing of fractionField: (c5, 0.919333ns)
signal finalExpFrac, finalExpFrac_d1 :  std_logic_vector(30 downto 0);
   -- timing of finalExpFrac: (c5, 0.919333ns)
signal finalOverflow, finalOverflow_d1, finalOverflow_d2, finalOverflow_d3, finalOverflow_d4, finalOverflow_d5, finalOverflow_d6 :  std_logic;
   -- timing of finalOverflow: (c0, 0.000000ns)
signal exc :  std_logic_vector(1 downto 0);
   -- timing of exc: (c6, 0.175000ns)
signal result :  std_logic_vector(33 downto 0);
   -- timing of result: (c6, 0.175000ns)
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            sign_d1 <=  sign;
            sign_d2 <=  sign_d1;
            sign_d3 <=  sign_d2;
            sign_d4 <=  sign_d3;
            sign_d5 <=  sign_d4;
            sign_d6 <=  sign_d5;
            zero_d1 <=  zero;
            exponentCorrection_d1 <=  exponentCorrection;
            exponentCorrection_d2 <=  exponentCorrection_d1;
            exponentCorrection_d3 <=  exponentCorrection_d2;
            exponentCorrection_d4 <=  exponentCorrection_d3;
            exponentCorrection_d5 <=  exponentCorrection_d4;
            finalExpFrac_d1 <=  finalExpFrac;
            finalOverflow_d1 <=  finalOverflow;
            finalOverflow_d2 <=  finalOverflow_d1;
            finalOverflow_d3 <=  finalOverflow_d2;
            finalOverflow_d4 <=  finalOverflow_d3;
            finalOverflow_d5 <=  finalOverflow_d4;
            finalOverflow_d6 <=  finalOverflow_d5;
         end if;
      end process;
   sign <= I(18);
   xoredI <= I when sign='0' else not I;
   bigSign <= (18 downto 1 => '0') & sign;
   negateAdder: IntAdder_19_Freq750_uid5
      port map ( clk  => clk,
                 Cin => '0',
                 X => bigSign,
                 Y => xoredI,
                 R => input);
   overflow1 <= '0';
   sticky1 <= '0';
   input1 <= input(18 downto 0);
   normer: Normalizer_Z_19_19_19_Freq750_uid7
      port map ( clk  => clk,
                 X => input1,
                 Count => lzc,
                 R => mantissa);
   sticky <= sticky1;
   lzcP <= "000"& lzc ;
   zero <= '1' when lzc >= CONV_STD_LOGIC_VECTOR(19,5)   else '0';
   exponentCorrection <= CONV_STD_LOGIC_VECTOR(139,8);
   exponentField <= exponentCorrection_d5-lzcP;
   MSB2Signal<=CONV_STD_LOGIC_VECTOR(11,8);
   fractionField <= mantissa(17 downto 0) & "00000";
   finalExpFrac <= exponentField & fractionField;
   finalOverflow <= overflow1;
   exc <=  "10" when finalOverflow_d6='1' else "00" when zero_d1='1' else "01";
   result <=  exc & sign_d6 & finalExpFrac_d1;
   O <= result;
end architecture;

