--------------------------------------------------------------------------------
--                          IntAdder_15_Freq750_uid5
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
--  approx. output signal timings: R: (c0, 0.703000ns)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_15_Freq750_uid5 is
    port (clk : in std_logic;
          X : in  std_logic_vector(14 downto 0);
          Y : in  std_logic_vector(14 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(14 downto 0)   );
end entity;

architecture arch of IntAdder_15_Freq750_uid5 is
signal Rtmp :  std_logic_vector(14 downto 0);
   -- timing of Rtmp: (c0, 0.703000ns)
begin
   Rtmp <= X + Y + Cin;
   R <= Rtmp;
end architecture;

--------------------------------------------------------------------------------
--                     Normalizer_Z_15_15_15_Freq750_uid7
-- VHDL generated for StratixV @ 750MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, (2007-2020)
--------------------------------------------------------------------------------
-- Pipeline depth: 4 cycles
-- Clock period (ns): 1.33333
-- Target frequency (MHz): 750
-- Input signals: X
-- Output signals: Count R
--  approx. input signal timings: X: (c0, 0.703000ns)
--  approx. output signal timings: Count: (c4, 0.350667ns)R: (c4, 0.783667ns)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity Normalizer_Z_15_15_15_Freq750_uid7 is
    port (clk : in std_logic;
          X : in  std_logic_vector(14 downto 0);
          Count : out  std_logic_vector(3 downto 0);
          R : out  std_logic_vector(14 downto 0)   );
end entity;

architecture arch of Normalizer_Z_15_15_15_Freq750_uid7 is
signal level4, level4_d1 :  std_logic_vector(14 downto 0);
   -- timing of level4: (c0, 0.703000ns)
signal count3, count3_d1, count3_d2, count3_d3 :  std_logic;
   -- timing of count3: (c1, 0.317667ns)
signal level3, level3_d1 :  std_logic_vector(14 downto 0);
   -- timing of level3: (c1, 0.750667ns)
signal count2, count2_d1, count2_d2 :  std_logic;
   -- timing of count2: (c2, 0.343333ns)
signal level2, level2_d1 :  std_logic_vector(14 downto 0);
   -- timing of level2: (c2, 0.776333ns)
signal count1, count1_d1 :  std_logic;
   -- timing of count1: (c3, 0.347000ns)
signal level1, level1_d1 :  std_logic_vector(14 downto 0);
   -- timing of level1: (c3, 0.780000ns)
signal count0 :  std_logic;
   -- timing of count0: (c4, 0.350667ns)
signal level0 :  std_logic_vector(14 downto 0);
   -- timing of level0: (c4, 0.783667ns)
signal sCount :  std_logic_vector(3 downto 0);
   -- timing of sCount: (c4, 0.350667ns)
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
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
   level4 <= X ;
   count3<= '1' when level4_d1(14 downto 7) = (14 downto 7=>'0') else '0';
   level3<= level4_d1(14 downto 0) when count3='0' else level4_d1(6 downto 0) & (7 downto 0 => '0');

   count2<= '1' when level3_d1(14 downto 11) = (14 downto 11=>'0') else '0';
   level2<= level3_d1(14 downto 0) when count2='0' else level3_d1(10 downto 0) & (3 downto 0 => '0');

   count1<= '1' when level2_d1(14 downto 13) = (14 downto 13=>'0') else '0';
   level1<= level2_d1(14 downto 0) when count1='0' else level2_d1(12 downto 0) & (1 downto 0 => '0');

   count0<= '1' when level1_d1(14 downto 14) = (14 downto 14=>'0') else '0';
   level0<= level1_d1(14 downto 0) when count0='0' else level1_d1(13 downto 0) & (0 downto 0 => '0');

   R <= level0;
   sCount <= count3_d3 & count2_d2 & count1_d1 & count0;
   Count <= sCount;
end architecture;

--------------------------------------------------------------------------------
--                             MXFP_E2M1_to_FP32
--                   (Fix2FP_S_M2_12_to_8_23_Freq750_uid2)
-- VHDL generated for StratixV @ 750MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin (2009-2026)
--------------------------------------------------------------------------------
-- Pipeline depth: 5 cycles
-- Clock period (ns): 1.33333
-- Target frequency (MHz): 750
-- Input signals: I
-- Output signals: O
--  approx. input signal timings: I: (c0, 0.000000ns)
--  approx. output signal timings: O: (c5, 0.039333ns)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity MXFP_E2M1_to_FP32 is
    port (clk : in std_logic;
          I : in  std_logic_vector(14 downto 0);
          O : out  std_logic_vector(8+23+2 downto 0)   );
end entity;

architecture arch of MXFP_E2M1_to_FP32 is
   component IntAdder_15_Freq750_uid5 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(14 downto 0);
             Y : in  std_logic_vector(14 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(14 downto 0)   );
   end component;

   component Normalizer_Z_15_15_15_Freq750_uid7 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(14 downto 0);
             Count : out  std_logic_vector(3 downto 0);
             R : out  std_logic_vector(14 downto 0)   );
   end component;

signal sign, sign_d1, sign_d2, sign_d3, sign_d4, sign_d5 :  std_logic;
   -- timing of sign: (c0, 0.000000ns)
signal xoredI :  std_logic_vector(14 downto 0);
   -- timing of xoredI: (c0, 0.000000ns)
signal bigSign :  std_logic_vector(14 downto 0);
   -- timing of bigSign: (c0, 0.000000ns)
signal input :  std_logic_vector(14 downto 0);
   -- timing of input: (c0, 0.703000ns)
signal overflow1 :  std_logic;
   -- timing of overflow1: (c0, 0.000000ns)
signal sticky1 :  std_logic;
   -- timing of sticky1: (c0, 0.000000ns)
signal input1 :  std_logic_vector(14 downto 0);
   -- timing of input1: (c0, 0.703000ns)
signal lzc :  std_logic_vector(3 downto 0);
   -- timing of lzc: (c4, 0.350667ns)
signal mantissa :  std_logic_vector(14 downto 0);
   -- timing of mantissa: (c4, 0.783667ns)
signal sticky :  std_logic;
   -- timing of sticky: (c0, 0.000000ns)
signal lzcP :  std_logic_vector(7 downto 0);
   -- timing of lzcP: (c4, 0.350667ns)
signal zero, zero_d1 :  std_logic;
   -- timing of zero: (c4, 0.783667ns)
signal exponentCorrection, exponentCorrection_d1, exponentCorrection_d2, exponentCorrection_d3, exponentCorrection_d4 :  std_logic_vector(7 downto 0);
   -- timing of exponentCorrection: (c0, 0.000000ns)
signal exponentField :  std_logic_vector(7 downto 0);
   -- timing of exponentField: (c4, 0.778667ns)
signal MSB2Signal :  std_logic_vector(7 downto 0);
   -- timing of MSB2Signal: (c0, 0.000000ns)
signal fractionField :  std_logic_vector(22 downto 0);
   -- timing of fractionField: (c4, 0.783667ns)
signal finalExpFrac, finalExpFrac_d1 :  std_logic_vector(30 downto 0);
   -- timing of finalExpFrac: (c4, 0.783667ns)
signal finalOverflow, finalOverflow_d1, finalOverflow_d2, finalOverflow_d3, finalOverflow_d4, finalOverflow_d5 :  std_logic;
   -- timing of finalOverflow: (c0, 0.000000ns)
signal exc :  std_logic_vector(1 downto 0);
   -- timing of exc: (c5, 0.039333ns)
signal result :  std_logic_vector(33 downto 0);
   -- timing of result: (c5, 0.039333ns)
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            sign_d1 <=  sign;
            sign_d2 <=  sign_d1;
            sign_d3 <=  sign_d2;
            sign_d4 <=  sign_d3;
            sign_d5 <=  sign_d4;
            zero_d1 <=  zero;
            exponentCorrection_d1 <=  exponentCorrection;
            exponentCorrection_d2 <=  exponentCorrection_d1;
            exponentCorrection_d3 <=  exponentCorrection_d2;
            exponentCorrection_d4 <=  exponentCorrection_d3;
            finalExpFrac_d1 <=  finalExpFrac;
            finalOverflow_d1 <=  finalOverflow;
            finalOverflow_d2 <=  finalOverflow_d1;
            finalOverflow_d3 <=  finalOverflow_d2;
            finalOverflow_d4 <=  finalOverflow_d3;
            finalOverflow_d5 <=  finalOverflow_d4;
         end if;
      end process;
   sign <= I(14);
   xoredI <= I when sign='0' else not I;
   bigSign <= (14 downto 1 => '0') & sign;
   negateAdder: IntAdder_15_Freq750_uid5
      port map ( clk  => clk,
                 Cin => '0',
                 X => bigSign,
                 Y => xoredI,
                 R => input);
   overflow1 <= '0';
   sticky1 <= '0';
   input1 <= input(14 downto 0);
   normer: Normalizer_Z_15_15_15_Freq750_uid7
      port map ( clk  => clk,
                 X => input1,
                 Count => lzc,
                 R => mantissa);
   sticky <= sticky1;
   lzcP <= "0000"& lzc ;
   zero <= '1' when lzc >= CONV_STD_LOGIC_VECTOR(15,4)   else '0';
   exponentCorrection <= CONV_STD_LOGIC_VECTOR(139,8);
   exponentField <= exponentCorrection_d4-lzcP;
   MSB2Signal<=CONV_STD_LOGIC_VECTOR(11,8);
   fractionField <= mantissa(13 downto 0) & "000000000";
   finalExpFrac <= exponentField & fractionField;
   finalOverflow <= overflow1;
   exc <=  "10" when finalOverflow_d5='1' else "00" when zero_d1='1' else "01";
   result <=  exc & sign_d5 & finalExpFrac_d1;
   O <= result;
end architecture;

