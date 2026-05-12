--------------------------------------------------------------------------------
--                           IntAdder_19_comb_uid5
-- VHDL generated for DummyFPGA @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2016)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X Y Cin
-- Output signals: R
--  approx. input signal timings: X: 0.000000nsY: 0.000000nsCin: 0.000000ns
--  approx. output signal timings: R: 1.180000ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_19_comb_uid5 is
    port (X : in  std_logic_vector(18 downto 0);
          Y : in  std_logic_vector(18 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(18 downto 0)   );
end entity;

architecture arch of IntAdder_19_comb_uid5 is
signal Rtmp :  std_logic_vector(18 downto 0);
   -- timing of Rtmp: 1.180000ns
begin
   Rtmp <= X + Y + Cin;
   R <= Rtmp;
end architecture;

--------------------------------------------------------------------------------
--                      Normalizer_Z_19_19_19_comb_uid7
-- VHDL generated for DummyFPGA @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, (2007-2020)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X
-- Output signals: Count R
--  approx. input signal timings: X: 1.180000ns
--  approx. output signal timings: Count: 6.220000nsR: 6.770000ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity Normalizer_Z_19_19_19_comb_uid7 is
    port (X : in  std_logic_vector(18 downto 0);
          Count : out  std_logic_vector(4 downto 0);
          R : out  std_logic_vector(18 downto 0)   );
end entity;

architecture arch of Normalizer_Z_19_19_19_comb_uid7 is
signal level5 :  std_logic_vector(18 downto 0);
   -- timing of level5: 1.180000ns
signal count4 :  std_logic;
   -- timing of count4: 1.770000ns
signal level4 :  std_logic_vector(18 downto 0);
   -- timing of level4: 2.320000ns
signal count3 :  std_logic;
   -- timing of count3: 2.890000ns
signal level3 :  std_logic_vector(18 downto 0);
   -- timing of level3: 3.440000ns
signal count2 :  std_logic;
   -- timing of count2: 4.000000ns
signal level2 :  std_logic_vector(18 downto 0);
   -- timing of level2: 4.550000ns
signal count1 :  std_logic;
   -- timing of count1: 5.110000ns
signal level1 :  std_logic_vector(18 downto 0);
   -- timing of level1: 5.660000ns
signal count0 :  std_logic;
   -- timing of count0: 6.220000ns
signal level0 :  std_logic_vector(18 downto 0);
   -- timing of level0: 6.770000ns
signal sCount :  std_logic_vector(4 downto 0);
   -- timing of sCount: 6.220000ns
begin
   level5 <= X ;
   count4<= '1' when level5(18 downto 3) = (18 downto 3=>'0') else '0';
   level4<= level5(18 downto 0) when count4='0' else level5(2 downto 0) & (15 downto 0 => '0');

   count3<= '1' when level4(18 downto 11) = (18 downto 11=>'0') else '0';
   level3<= level4(18 downto 0) when count3='0' else level4(10 downto 0) & (7 downto 0 => '0');

   count2<= '1' when level3(18 downto 15) = (18 downto 15=>'0') else '0';
   level2<= level3(18 downto 0) when count2='0' else level3(14 downto 0) & (3 downto 0 => '0');

   count1<= '1' when level2(18 downto 17) = (18 downto 17=>'0') else '0';
   level1<= level2(18 downto 0) when count1='0' else level2(16 downto 0) & (1 downto 0 => '0');

   count0<= '1' when level1(18 downto 18) = (18 downto 18=>'0') else '0';
   level0<= level1(18 downto 0) when count0='0' else level1(17 downto 0) & (0 downto 0 => '0');

   R <= level0;
   sCount <= count4 & count3 & count2 & count1 & count0;
   Count <= sCount;
end architecture;

--------------------------------------------------------------------------------
--                             MXFP_E2M3_to_FP32
--                     (Fix2FP_S_M6_12_to_8_23_comb_uid2)
-- VHDL generated for DummyFPGA @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin (2009-2026)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: I
-- Output signals: O
--  approx. input signal timings: I: 0.000000ns
--  approx. output signal timings: O: 7.320000ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity MXFP_E2M3_to_FP32 is
    port (I : in  std_logic_vector(18 downto 0);
          O : out  std_logic_vector(8+23+2 downto 0)   );
end entity;

architecture arch of MXFP_E2M3_to_FP32 is
   component IntAdder_19_comb_uid5 is
      port ( X : in  std_logic_vector(18 downto 0);
             Y : in  std_logic_vector(18 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(18 downto 0)   );
   end component;

   component Normalizer_Z_19_19_19_comb_uid7 is
      port ( X : in  std_logic_vector(18 downto 0);
             Count : out  std_logic_vector(4 downto 0);
             R : out  std_logic_vector(18 downto 0)   );
   end component;

signal sign :  std_logic;
   -- timing of sign: 0.000000ns
signal xoredI :  std_logic_vector(18 downto 0);
   -- timing of xoredI: 0.000000ns
signal bigSign :  std_logic_vector(18 downto 0);
   -- timing of bigSign: 0.000000ns
signal input :  std_logic_vector(18 downto 0);
   -- timing of input: 1.180000ns
signal overflow1 :  std_logic;
   -- timing of overflow1: 0.000000ns
signal sticky1 :  std_logic;
   -- timing of sticky1: 0.000000ns
signal input1 :  std_logic_vector(18 downto 0);
   -- timing of input1: 1.180000ns
signal lzc :  std_logic_vector(4 downto 0);
   -- timing of lzc: 6.220000ns
signal mantissa :  std_logic_vector(18 downto 0);
   -- timing of mantissa: 6.770000ns
signal sticky :  std_logic;
   -- timing of sticky: 0.000000ns
signal lzcP :  std_logic_vector(7 downto 0);
   -- timing of lzcP: 6.220000ns
signal zero :  std_logic;
   -- timing of zero: 6.770000ns
signal exponentCorrection :  std_logic_vector(7 downto 0);
   -- timing of exponentCorrection: 0.000000ns
signal exponentField :  std_logic_vector(7 downto 0);
   -- timing of exponentField: 7.290000ns
signal MSB2Signal :  std_logic_vector(7 downto 0);
   -- timing of MSB2Signal: 0.000000ns
signal fractionField :  std_logic_vector(22 downto 0);
   -- timing of fractionField: 6.770000ns
signal finalExpFrac :  std_logic_vector(30 downto 0);
   -- timing of finalExpFrac: 7.290000ns
signal finalOverflow :  std_logic;
   -- timing of finalOverflow: 0.000000ns
signal exc :  std_logic_vector(1 downto 0);
   -- timing of exc: 7.320000ns
signal result :  std_logic_vector(33 downto 0);
   -- timing of result: 7.320000ns
begin
   sign <= I(18);
   xoredI <= I when sign='0' else not I;
   bigSign <= (18 downto 1 => '0') & sign;
   negateAdder: IntAdder_19_comb_uid5
      port map ( Cin => '0',
                 X => bigSign,
                 Y => xoredI,
                 R => input);
   overflow1 <= '0';
   sticky1 <= '0';
   input1 <= input(18 downto 0);
   normer: Normalizer_Z_19_19_19_comb_uid7
      port map ( X => input1,
                 Count => lzc,
                 R => mantissa);
   sticky <= sticky1;
   lzcP <= "000"& lzc ;
   zero <= '1' when lzc >= CONV_STD_LOGIC_VECTOR(19,5)   else '0';
   exponentCorrection <= CONV_STD_LOGIC_VECTOR(139,8);
   exponentField <= exponentCorrection-lzcP;
   MSB2Signal<=CONV_STD_LOGIC_VECTOR(11,8);
   fractionField <= mantissa(17 downto 0) & "00000";
   finalExpFrac <= exponentField & fractionField;
   finalOverflow <= overflow1;
   exc <=  "10" when finalOverflow='1' else "00" when zero='1' else "01";
   result <=  exc & sign & finalExpFrac;
   O <= result;
end architecture;

